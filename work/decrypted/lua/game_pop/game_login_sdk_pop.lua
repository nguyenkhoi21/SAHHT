--- 帐号登陆
local md5 = require("shared.md5")

--local MAIN_URI = "https://app-t.cn.hi365.com/"  --测试服
local MAIN_URI = "http://app.vn.hi365.com/"  --正式服

local ACCOUNT_LOGIN = MAIN_URI .. "v2/login_account/?app_id=cjyxkv&lang=vn"  --密码登录
local ACCOUNT_LOGIN_WITH_PHONE_CODE = MAIN_URI .. "v2/login_mobile/?app_id=cjyxkv&lang=vn"  --验证码登录
local GET_MOBILE_CODE = MAIN_URI .. "v2/get_mobile_code/?app_id=cjyxkv&lang=vn"  --获取验证码
local ACCOUNT_CERTIFICATION = MAIN_URI .. "v2/real_name_auth/?app_id=cjyxkv&lang=vn"    --实名认证
local CHANGE_NEW_PASSWORD_CHECK_CODE = MAIN_URI .. "v2/change_password/?app_id=cjyxkv&lang=vn"   --修改密码
local CHANGE_NEW_PHONE_CHECK_CODE = MAIN_URI .. "v2/change_mobile/?app_id=cjyxkv&lang=vn" --改绑手机号

local game_login_sdk_pop = {
    m_popUi = nil,
    m_fromUi = nil,
    m_root_layer = nil,
    m_user_name_bg = nil,
    m_wjmm_btn = nil,
    m_close_btn = nil,
    m_yzm_btn = nil,
    m_login_btn = nil,
    m_username = nil,
    m_passwrod = nil,
    m_callBackFunc = nil,
    m_requestCount = nil,
    m_passwrodEdit = nil,
    login_status = nil,
    m_yzm_btn = nil,
    m_wjmm_btn = nil,
    m_code = nil,
    session_id = nil,
    m_newpassword = nil,
    m_ok_btn = nil,
    m_forgotPassword_node = nil,
    newpasswordEdit = nil,
    m_shenfen = nil,
    m_name = nil,
    m_shared = nil,
    m_shared1 = nil,
    m_shared2 = nil,
    callBack = nil,
    ghomesuccess = nil,
};
--[[--
    销毁
]]
function game_login_sdk_pop.destroy(self)
    -- body
    cclog("-----------------game_login_sdk_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_fromUi = nil;
    self.m_root_layer = nil;
    self.m_user_name_bg = nil;
    self.m_wjmm_btn = nil;
    self.m_close_btn = nil;
    self.m_yzm_btn = nil;
    self.m_login_btn = nil;
    self.m_username = nil;
    self.m_passwrod = nil;
    self.m_callBackFunc = nil;
    self.m_requestCount = nil;
    self.m_passwrodEdit = nil;
    self.login_status = nil;
    self.m_yzm_btn = nil;
    self.m_wjmm_btn = nil;
    self.m_code = nil;
    self.session_id = nil;
    self.m_newpassword = nil;
    self.m_ok_btn = nil;
    self.m_forgotPassword_node = nil;
    self.newpasswordEdit = nil;
    self.m_name = nil;
    self.m_shenfen = nil;
    self.m_shared = nil;
    self.m_shared1 = nil;
    self.m_shared2 = nil;
    self.m_uid = nil;
    self.m_age = nil;
    self.callBack = nil;
    self.ghomesuccess = nil;
end
--[[--
    返回
]]
function game_login_sdk_pop.back(self,type)
    if self.m_shared then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
    end
    if self.m_shared1 then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared1)
    end
    cclog2(self.m_shared2,"haha2")
    if self.m_shared2 then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared2)
    end
    game_scene:removePopByName("game_login_sdk_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_login_sdk_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag")
        if btnTag == 11 then--实名认证
            local function responseMethod(tag,gameData)
                local data2 = json.decode(gameData:getFormatBuffer())
                --cclog2(data2,"gameData")
                if data2.status == 0 then
                    if self.callBack then
                        local data = {}
                        data.result = true
                        data.session_id =self.session_id
                        data.token = self.m_uid
                        data.age = data2.data.age_level
                        data.needverify = true
                        data.platform = "kvgamesios"
                        data.userID = self.m_uid
                        self.callBack(data)
                        self:back()
                    end
                end
            end
            local params = {}
            params.name = self.m_name
            params.session_id = self.session_id
            params.idcard = self.m_shenfen
            network.sendHttpRequest(responseMethod,ACCOUNT_CERTIFICATION, http_request_method.GET, params,"ACCOUNT_CERTIFICATION");
        elseif btnTag == 1 then--改绑手机
            self.m_login_node:setVisible(false)
            self.m_ghome_node:setVisible(true)

            self.m_passwrodEdit:setVisible(false)
            self.m_codeEdit:setVisible(true)
            self.editBox:setText("")
            self.m_codeEdit:setText("")
            self.m_passwrodEdit:setText("")
            self.editBox:setPlaceHolder("Nhập SĐT ban đầu")

        elseif btnTag == 2 then--手机登录
            self.m_yzm_btn:setVisible(true)
            self.m_wjmm_btn:setVisible(false)
            self.login_status = 1
            self.m_passwrodEdit:setText("")
            self.m_passwrodEdit:setVisible(false)
            self.m_codeEdit:setVisible(true)
            
        elseif btnTag == 3 then--密码登录
            self:passwrodLogin()
        elseif btnTag == 4 then--登录
            if self.login_status == 1 then
                local function responseMethod(tag,gameData)
                    local data = json.decode(gameData:getFormatBuffer())
                    cclog2(data,"gameData")
                    if data then
                        CCUserDefault:sharedUserDefault():setStringForKey("sdk_username",data.data.username);
                        CCUserDefault:sharedUserDefault():flush();
                        self.m_yzm_btn:setEnabled(true)
                        game_util:setCCControlButtonTitle(self.m_yzm_btn, "Lấy mã OTP")
                        if self.m_shared then
                            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
                        end
                        
                        self.session_id = data.data.session_id
                        self.m_uid = data.data.uid
                        self.m_age = data.data.age
                        if data.data.need_real_name == 1 then
                            self.m_login_node:setVisible(false)
                            self.m_shiming_node:setVisible(true)
                            self.m_shenfenEdit:setVisible(true)
                            self.m_nameEdit:setVisible(true)
                            self.m_codeEdit:setText("")
                        else
                            if self.callBack then
                                local data = {}
                                data.result = true
                                data.session_id =self.session_id
                                data.token = self.m_uid
                                data.age = self.m_age
                                data.userID = self.m_uid
                                data.platform = "kvgamesios"
                                data.needverify = true
                                self.callBack(data)
                                self:back()
                            end
                        end
                    end
                end
                local params = {}
                params.phone = self.m_username
                params.account = self.m_username
                params.code = self.m_code
                network.sendHttpRequest(responseMethod,ACCOUNT_LOGIN_WITH_PHONE_CODE, http_request_method.GET, params,"ACCOUNT_LOGIN_WITH_PHONE_CODE");
            else
                local function responseMethod(tag,gameData)
                    local data = json.decode(gameData:getFormatBuffer())
                    cclog2(data,"gameData")
                    if data then
                        self.session_id = data.data.session_id
                        self.m_uid = data.data.uid
                        self.m_age = data.data.age
                        CCUserDefault:sharedUserDefault():setStringForKey("sdk_username",data.data.username);
                        CCUserDefault:sharedUserDefault():setStringForKey("sdk_passwrod",data.data.password);
                        CCUserDefault:sharedUserDefault():flush();

                        if data.data.need_real_name == 1 then
                            self.m_login_node:setVisible(false)
                            self.m_shiming_node:setVisible(true)
                            self.m_shenfenEdit:setVisible(true)
                            self.m_nameEdit:setVisible(true)
                            self.m_codeEdit:setText("")
                        else
                            if self.callBack then
                                local data = {}
                                data.result = true
                                data.session_id =self.session_id
                                data.token = self.m_uid
                                data.age = self.m_age
                                data.userID = self.m_uid
                                data.platform = "kvgamesios"
                                data.needverify = true
                                self.callBack(data)
                                self:back()
                            end
                        end
                    end
                end
                local pass = ""
                local passwrod = CCUserDefault:sharedUserDefault():getStringForKey("sdk_passwrod");
                if passwrod == self.m_passwrod then
                    pass = passwrod
                else
                    local m = md5.new()
                    m:update(self.m_passwrod)
                    pass = md5.tohex(m:finish())
                end 
                
                local params = {}
                params.username = self.m_username
                params.password = pass
                network.sendHttpRequest(responseMethod,ACCOUNT_LOGIN, http_request_method.POST, params,"login_account");
            end
        elseif btnTag == 5 then--忘记密码
            self.m_codeEdit:setText("")
           self.m_forgotPassword_node:setVisible(true)
           self.m_login_node:setVisible(false)
           self.m_passwrodEdit:setVisible(false)
           self.m_codeEdit:setVisible(true)
        elseif btnTag == 6 then--获取验证码
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer())
                --cclog2(data,"gameData")
                if data.status == 0 then
                    local time = 60
                    function tick()
                        time = time - 1
                        if time < 1 then
                            self.m_yzm_btn:setEnabled(true)
                            game_util:setCCControlButtonTitle(self.m_yzm_btn, "Lấy mã OTP")
                            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
                        end
                        game_util:setCCControlButtonTitle(self.m_yzm_btn, time.."giây")
                    end
                    self.m_yzm_btn:setEnabled(false)
                    game_util:setCCControlButtonTitle(self.m_yzm_btn, "60giây")
                    self.m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1 , false)
                end
            end
            local params = {}
            params.phone = self.m_username
            params.type = 1
            network.sendHttpRequest(responseMethod,GET_MOBILE_CODE, http_request_method.GET, params,"GET_MOBILE_CODE");
        elseif btnTag == 7 then--下一步
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer())
                cclog2(data,"gameData")
                if data then
                    self.session_id = data.data.session_id
                    CCUserDefault:sharedUserDefault():setStringForKey("sdk_username",data.data.username);
                    CCUserDefault:sharedUserDefault():flush();
                    self.m_codeEdit:setText("")
                    self.m_yzm2_btn:setVisible(false)
                    self.m_next_btn:setVisible(false)
                    self.m_ok_btn:setVisible(true)
                    self.m_passwrodEdit:setVisible(true)
                    self.m_codeEdit:setVisible(false)
                    self.m_passwrodEdit:setText("")
                    self.m_passwrodEdit:setPlaceHolder("Nhập mật khẩu")
                    self.newpasswordEdit:setVisible(true)
                    self.editBox:setVisible(false)

               end
            end
            local params = {}
            params.phone = self.m_username
            params.account = self.m_username
            params.code = self.m_code
            network.sendHttpRequest(responseMethod,ACCOUNT_LOGIN_WITH_PHONE_CODE, http_request_method.GET, params,"ACCOUNT_LOGIN_WITH_PHONE_CODE");
        elseif btnTag == 8 then--获取验证码 修改密码
           local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer())
                cclog2(data,"gameData")
                if data.status == 0 then
                    local time = 60
                    function tick()
                        time = time - 1
                        if time < 1 then
                            self.m_yzm2_btn:setEnabled(true)
                            game_util:setCCControlButtonTitle(self.m_yzm2_btn, "Lấy mã OTP")
                            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared1)
                        end
                        game_util:setCCControlButtonTitle(self.m_yzm2_btn, time.."giây")
                    end
                    self.m_yzm2_btn:setEnabled(false)
                    game_util:setCCControlButtonTitle(self.m_yzm2_btn, "60giây")
                    self.m_shared1 = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1 , false)
                end
            end
            local params = {}
            params.phone = self.m_username
            params.type = 5
            network.sendHttpRequest(responseMethod,GET_MOBILE_CODE, http_request_method.GET, params,"GET_MOBILE_CODE");

        elseif btnTag == 9 then--返回
            self.m_next_btn:setVisible(true)
            self.m_ok_btn:setVisible(false)
            self.m_yzm2_btn:setVisible(true)
            self.m_forgotPassword_node:setVisible(false)
            self.m_codeEdit:setVisible(false)
            self.m_passwrodEdit:setVisible(true)
            self.m_login_node:setVisible(true)
            self.editBox:setPlaceHolder("Nhập SĐT")
            self.m_passwrodEdit:setPlaceHolder("Nhập mật khẩu")
            self.newpasswordEdit:setText("")
            self.m_passwrodEdit:setText("")
            self.newpasswordEdit:setVisible(false)
            self.editBox:setVisible(true)
            if(self.m_username)then
                 self.editBox:setText(self.m_username);
            end
            if(self.m_passwrod)then
                 self.m_passwrodEdit:setText(self.m_passwrod);
            end

        elseif btnTag == 10 then--确认
            if self.m_newpassword ~= self.m_passwrod then
                game_util:addMoveTips({text = "Hãy nhập chính xác mã OTP"})
                return;
            end
           local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer())
                cclog2(data,"gameData")
                if data then
                    self.m_next_btn:setVisible(true)
                    self.m_ok_btn:setVisible(false)
                    self.m_yzm2_btn:setVisible(true)
                    self.m_forgotPassword_node:setVisible(false)
                    self.m_codeEdit:setVisible(false)
                    self.m_codeEdit:setText("")
                    self.m_passwrodEdit:setVisible(true)
                    self.m_login_node:setVisible(true)
                    self.editBox:setPlaceHolder("Nhập SĐT")
                    self.editBox:setInputFlag(kEditBoxInputFlagSensitive);
                    self.editBox:setText("");
                    if(self.m_username)then
                         self.editBox:setText(self.m_username);
                    end
                    self.newpasswordEdit:setVisible(false)
                    self.editBox:setVisible(true)
                    self:passwrodLogin()
                end
            end
            local m = md5.new()
            m:update(self.m_passwrod)
            local pass = md5.tohex(m:finish())
            local params = {}
            --params.phone = self.m_username
            params.newpassword = pass
            params.session_id = self.session_id
            
            network.sendHttpRequest(responseMethod,CHANGE_NEW_PASSWORD_CHECK_CODE, http_request_method.GET, params,"CHANGE_NEW_PASSWORD_CHECK_CODE");
        elseif btnTag == 12 then--更换手机下一步
            
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer())
                --cclog2(data.data.need_real_name,"gameData")
                if data then
                    if self.m_shared2 then
                        game_util:setCCControlButtonTitle(self.m_yzmhome_btn, "Lấy mã OTP")
                        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared2)
                        self.m_shared2 = nil
                    end
                    
                    self.session_id = data.data.session_id
                    self.editBox:setText("")
                    self.m_codeEdit:setText("")
                    self.editBox:setPlaceHolder("Nhập SĐT")
                    game_util:setCCControlButtonTitle(self.m_yzmhome_btn, "Lấy mã OTP")
                    self.m_nexthome_btn:setVisible(false)
                    self.m_okhome_btn:setVisible(true)
                    self.ghomeCode = 1
                    self.m_yzmhome_btn:setEnabled(true)
                end
            end
            local params = {}
            params.phone = self.m_username
            params.account = self.m_username
            params.code = self.m_code
            network.sendHttpRequest(responseMethod,ACCOUNT_LOGIN_WITH_PHONE_CODE, http_request_method.GET, params,"ACCOUNT_LOGIN_WITH_PHONE_CODE");
        elseif btnTag == 13 then--更换手机获取验证码
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer())
                --cclog2(data,"gameData")
                if data.status == 0 then
                    local time = 60
                    function tick()
                        time = time - 1
                        if time < 1 then
                            self.m_yzmhome_btn:setEnabled(true)
                            game_util:setCCControlButtonTitle(self.m_yzmhome_btn, "Lấy mã OTP")
                            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared2)
                            self.m_shared2 = nil
                        end
                        game_util:setCCControlButtonTitle(self.m_yzmhome_btn, time.."giây")
                    end
                    self.m_yzmhome_btn:setEnabled(false)
                    game_util:setCCControlButtonTitle(self.m_yzmhome_btn, "60giây")
                    self.m_shared2 = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1 , false)
                end
            end
            local type = 3
            if self.ghomeCode == 1 then--如果contentSize
                type = 4
            end
            local params = {}
            params.phone = self.m_username
            params.type = type
            network.sendHttpRequest(responseMethod,GET_MOBILE_CODE, http_request_method.GET, params,"GET_MOBILE_CODE");
        elseif btnTag == 14 then--确认
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer())
                --cclog2(data.data.need_real_name,"gameData")
                if data.status == 0 then
                    self.ghomesuccess = true
                    self:ghomeback()
                end
            end
            local params = {}
            params.phone = self.m_username
            params.account = self.m_username
            params.code = self.m_code
            params.session_id = self.session_id
            network.sendHttpRequest(responseMethod,CHANGE_NEW_PHONE_CHECK_CODE, http_request_method.GET, params,"CHANGE_NEW_PHONE_CHECK_CODE");
        elseif btnTag == 15 then--改绑手机返回
            self:ghomeback()
        end
    end
    self.login_status = 1
    self.ghomeCode = 0
    self.ghomesuccess = false
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_game_login_sdk.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_login_node = ccbNode:nodeForName("m_login_node")
    self.m_shiming_node = ccbNode:nodeForName("m_shiming_node")
    self.m_forgotPassword_node = ccbNode:nodeForName("m_forgotPassword_node")  --忘记密码
    self.m_ghome_node = ccbNode:nodeForName("m_ghome_node") --更改手机
    local line1_spr = ccbNode:spriteForName("line1_spr")
    local line2_spr = ccbNode:spriteForName("line2_spr")
    self.m_yzm_btn = ccbNode:controlButtonForName("m_yzm_btn")
    self.m_wjmm_btn = ccbNode:controlButtonForName("m_wjmm_btn")
    self.m_nexthome_btn = ccbNode:controlButtonForName("m_nexthome_btn")  --更改手机
    self.m_yzmhome_btn = ccbNode:controlButtonForName("m_yzmhome_btn")
    self.m_okhome_btn = ccbNode:controlButtonForName("m_okhome_btn")

    local m_passw_btn = ccbNode:controlButtonForName("m_passw_btn")
    local m_backhome_btn = ccbNode:controlButtonForName("m_backhome_btn")
    local m_home_btn = ccbNode:controlButtonForName("m_home_btn")
    local m_login_btn = ccbNode:controlButtonForName("m_login_btn")
    local m_set_btn = ccbNode:controlButtonForName("m_set_btn")

    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_yzm2_btn = ccbNode:controlButtonForName("m_yzm2_btn")
    self.m_next_btn = ccbNode:controlButtonForName("m_next_btn")
    local m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_shimingok_btn = ccbNode:controlButtonForName("m_shimingok_btn")

    self.m_yzm_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_set_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_wjmm_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_passw_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_home_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_login_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_next_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_yzm2_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_shimingok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.m_nexthome_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_yzmhome_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_okhome_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_backhome_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    -- game_util:setControlButtonTitleBMFont(self.m_login_btn)

    self.m_username = CCUserDefault:sharedUserDefault():getStringForKey("sdk_username");
    self.m_passwrod = CCUserDefault:sharedUserDefault():getStringForKey("sdk_passwrod");

    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            self.m_username = edit:getText();
        end
    end
    local viewSize = CCSizeMake(220,30)

    self.editBox = game_util:createEditBox({bgFileName = "sdk_tishi01_bg.png",scriptEditBoxHandler=editBoxTextEventHandle,size = viewSize,placeHolder="Nhập SĐT",fontSize=10});
    self.editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.editBox:setInputFlag(kEditBoxInputFlagSensitive);
    line1_spr:addChild(self.editBox);
    if(self.m_username)then
        self.editBox:setText(self.m_username);
    end

    local function editBoxTextEventHandle4(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            self.m_newpassword = edit:getText();
        end
    end
    local viewSize = CCSizeMake(220,30)

    self.newpasswordEdit = game_util:createEditBox({bgFileName = "sdk_tishi01_bg.png",scriptEditBoxHandler=editBoxTextEventHandle4,size = viewSize,placeHolder="Nhập mật khẩu",fontSize=10, maxLength = 18});
    self.newpasswordEdit:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.newpasswordEdit:setInputFlag(kEditBoxInputFlagPassword);
    line1_spr:addChild(self.newpasswordEdit);
    self.newpasswordEdit:setVisible(false)

    local function editBoxTextEventHandle2(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_passwrod = edit:getText();
        end
    end
    self.m_passwrodEdit = game_util:createEditBox({bgFileName = "sdk_tishi01_bg.png",scriptEditBoxHandler=editBoxTextEventHandle2,size = viewSize,placeHolder="Nhập mật khẩu",fontSize=10,maxLength = 28});
    self.m_passwrodEdit:setInputFlag(kEditBoxInputFlagPassword);
    self.m_passwrodEdit:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    line2_spr:addChild(self.m_passwrodEdit);
    self.m_passwrodEdit:setVisible(false)
    --editBox:setPositionY(30)
    
    local function editBoxTextEventHandle3(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_code = edit:getText();
        end
    end
    self.m_codeEdit = game_util:createEditBox({bgFileName = "sdk_tishi01_bg.png",scriptEditBoxHandler=editBoxTextEventHandle3,size = CCSizeMake(150,30),placeHolder="Nhập mã OTP",fontSize=20});
    self.m_codeEdit:setInputFlag(kEditBoxInputFlagSensitive);
    self.m_codeEdit:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    line2_spr:addChild(self.m_codeEdit);

    local function editBoxTextEventHandle5(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_name = edit:getText();
        end
    end
    self.m_nameEdit = game_util:createEditBox({bgFileName = "sdk_tishi01_bg.png",scriptEditBoxHandler=editBoxTextEventHandle5,size = viewSize,placeHolder="姓名",fontSize=20});
    self.m_nameEdit:setInputFlag(kEditBoxInputFlagSensitive);
    self.m_nameEdit:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    line1_spr:addChild(self.m_nameEdit);

    local function editBoxTextEventHandle6(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_shenfen = edit:getText();
        end
    end
    self.m_shenfenEdit = game_util:createEditBox({bgFileName = "sdk_tishi01_bg.png",scriptEditBoxHandler=editBoxTextEventHandle6,size = viewSize,placeHolder="身份证号码",fontSize=20,maxLength = 18});
    self.m_shenfenEdit:setInputFlag(kEditBoxInputFlagSensitive);
    self.m_shenfenEdit:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    line2_spr:addChild(self.m_shenfenEdit);
    self.m_shenfenEdit:setVisible(false)
    self.m_nameEdit:setVisible(false)

    self:passwrodLogin()
    if (self.m_passwrod~="") then
        self.m_passwrodEdit:setText(self.m_passwrod);
    else
        cclog("passss")
        local node = CCNode:create()
        node:setTag(5)
        --addChild(node)
        onMainBtnClick(node,"")
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end


function game_login_sdk_pop.passwrodLogin(self)
    self.login_status = 2
    self.m_codeEdit:setText("")
    self.m_yzm_btn:setVisible(false)
    self.m_wjmm_btn:setVisible(true)
    self.m_passwrodEdit:setVisible(true)
    self.m_codeEdit:setVisible(false)
    if(self.m_passwrod)then
        self.m_passwrodEdit:setText(self.m_passwrod);
    end
end    

function game_login_sdk_pop.ghomeback(self)
    self.ghomeCode = 0
    self.m_ghome_node:setVisible(false)
    self.m_nexthome_btn:setVisible(true)
    self.m_okhome_btn:setVisible(false)
    self.m_login_node:setVisible(true)
    if self.ghomesuccess then
        self.editBox:setText("")
    else
        if(self.m_username)then
             self.editBox:setText(self.m_username);
        end
    end
    
    self.m_codeEdit:setText("")
    self.editBox:setPlaceHolder("Nhập SĐT")

    self.m_yzm_btn:setVisible(true)
    self.m_wjmm_btn:setVisible(false)
    self.login_status = 1
    self.m_passwrodEdit:setText("")
    self.m_passwrodEdit:setVisible(false)
    self.m_codeEdit:setVisible(true)
    cclog2(self.m_shared2,"haha1")
    if self.m_shared2 then
        game_util:setCCControlButtonTitle(self.m_yzmhome_btn, "Lấy mã OTP")
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared2)
        self.m_shared2 = nil
    end
end


--[[--
    刷新ui
]]
function game_login_sdk_pop.refreshUi(self)

end

--[[--
    初始化
]]
function game_login_sdk_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    --self.m_fromUi = t_params.fromUi;
    self.callBack = t_params.callFunc
    self.m_username = "";
    self.m_passwrod = "";
    --self.m_callBackFunc = t_params.callBackFunc
    self.m_requestCount = 1;
end

--[[--
    创建ui入口并初始化数据
]]
function game_login_sdk_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_login_sdk_pop;