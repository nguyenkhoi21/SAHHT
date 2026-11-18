--pay--- 支付相关 
local tostring,os,type,pairs,math,tonumber = tostring,os,type,pairs,math,tonumber
local sharedDirector = CCDirector:sharedDirector();

local M = {
    m_notify_urls = nil,
    m_callBack = nil,
    m_buy_index = nil,
}

function M.destory( self )
    self.m_notify_urls = nil;
    self.m_callBack = nil;
    self.m_buy_index = nil;
end 

local platform_channel = ""
if util_system.getPlatformChannel then
    platform_channel = tostring(util_system:getPlatformChannel()); -- 平台渠道号
end


local errorTab = {
    error_500 = "服务器出错了，请稍后再试！",
    error_502 = "服务器出问题了，请稍后再试！",
}

local get_pay_notifyUrl_platform = 
{
    platform_youku = true,
    platform_haima = true,
}
local get_pay_order_platform = {
    platform_dachen = true,
    platform_xiao7 = true,
    androidxiao7 = true,
    downjoy = true,
    downjoy2 = true,
}

--[[
    支付回调
    ZcIapManager.h
    用于ipa支付
]]
function M.registerCallBack( self ,productPriceForiOS)
    local function payEnd( msg )
        if(msg == "pay err")then
            -- iap不成功
        elseif(msg == "pay product err")then
            game_util:addMoveTips({text = "时空传送器又出问题了，请稍候。。。"});
        elseif(msg == "pay data ready")then
            -- 服务器验证成功
        elseif(msg == "pay data err")then
            -- 服务器验证单据错误
        else
            -- cclog2( msg, "payEnd  call back msg =====  pay.lua " )
            local selfUid = game_data:getUserStatusDataByKey('uid');
            local server_data,sindex = game_data:getServer()
            local serverId = server_data.server
            local orderIdCom = tostring(selfUid) .. "-" .. tostring(serverId) .. '-' .. tostring(self.m_buy_index) .. '-' .. tostring(os.time());
            if getPlatFormExt() == "platform_kvgame" then
                self:paySuccess( {order = orderIdCom , uid = selfUid , productPrice=productPriceForiOS})
            else
                self:paySuccess( {order = orderIdCom} )
            end
        end
        require("game_ui.game_loading").close();
    end
    if registerCallBack then
        registerCallBack(payEnd);
    end
end


--[[
    91 ios 支付
]]
function M.startPayBy91IOS( self, index, moneyConfig )
    -- if PLATFORM.isLogined()
    local userInfo = PLATFORM.getUserinfo()
    local selfUid = game_data:getUserStatusDataByKey('uid');
    --拼出91_加loginUin
    local loginUin = "91_"..tostring(selfUid).."_"
    local coin = moneyConfig:getNodeWithKey("price"):toInt()
    local cooOrderSerial = loginUin..tostring(os.time()).."_"..tostring(coin)
    cclog("------------- 91 buy " .. cooOrderSerial);
    local productId = tostring(index)
    local productName = moneyConfig:getNodeWithKey("name"):toStr();
    local productPrice = coin
    local productOrignalPrice = coin
    -- local productPrice = 0.01
    -- local productOrignalPrice = 0.01
    local productCount = 1
    --描述，uid和服务器号
    local server_data,sindex = game_data:getServer()
    local server = server_data.server
    local payDescription = user_token..","..tostring(server)

    local function onPaySuccess()
        self:paySuccess( {order = cooOrderSerial} )
    end
    PLATFORM.addCallback("SDKNDCOM_PAY_SUCCESS",onPaySuccess)

    local function onPayFailed()
        self:payFailed( {order = cooOrderSerial} )
    end
    PLATFORM.addCallback("SDKNDCOM_PAY_FAIL",onPayFailed)

    self:payBegan( {order = cooOrderSerial,productId=productId,productPrice=productPrice,currencyType = "CNY"} )
    PLATFORM.uniPayAsyn(cooOrderSerial,productId,productPrice,productName,productOrignalPrice,productCount,payDescription)
end


--[[
    PP ios 支付
]]
function M.startPayByPPIOS( self, index, moneyConfig )
    -- 用户uid
    -- serverid
    -- 商品配置id
    -- os.time();
    local selfUid = game_data:getUserStatusDataByKey('uid');
    local server_data,sindex = game_data:getServer()
    local serverId = server_data.server

    local paramPrice = moneyConfig:getNodeWithKey("price"):toInt();
    local paramBillNo = tostring(selfUid) .. "-" .. tostring(serverId) .. '-' .. tostring(index) .. '-' .. tostring(os.time());
    local paramBillTitle = moneyConfig:getNodeWithKey("name"):toStr();
    local paramRoleId = '0';
    local paramZoneId = 0;

    CCUserDefault:sharedUserDefault():setStringForKey("PP_BILL_NO",paramBillNo)
    CCUserDefault:sharedUserDefault():flush()

    self:payBegan( {order = paramBillNo,productId=tostring(index),productPrice=paramPrice,currencyType = "CNY"} )
    PP_CLASS:sharedInstance():exchangeGoods(paramPrice , paramBillNo , paramBillTitle , paramRoleId , paramZoneId);
end

--[[
    PP ios 支付
]]
function M.startPayByItoolsIOS( self, index, moneyConfig )
    local selfUid = game_data:getUserStatusDataByKey('uid');
    local server_data,sindex = game_data:getServer()
    local serverId = server_data.server
    local orderIdCom = tostring(selfUid) .. "-" .. tostring(serverId) .. '-' .. tostring(index) .. '-' .. tostring(os.time());
    local amount = moneyConfig:getNodeWithKey("price"):toInt();
    self:payBegan( {order = orderIdCom,productId=tostring(index),productPrice=amount,currencyType = "CNY"} )
    local des = moneyConfig:getNodeWithKey("name") and moneyConfig:getNodeWithKey("name"):toStr() or "钻石包"
    PLATFORM_ITOOLS.setPayViewAmount(orderIdCom,amount, des)
end

--[[
    PP ios 支付
]]
function M.startPayByCmgeIOS( self, index, moneyConfig )
    local selfUid = game_data:getUserStatusDataByKey('uid');
    local server_data,sindex = game_data:getServer()
    local serverId = server_data.server
    local orderIdCom = tostring(selfUid) .. "-" .. tostring(serverId) .. '-' .. tostring(index) .. '-' .. tostring(os.time());
    local amount = moneyConfig:getNodeWithKey("price"):toInt();
    local name = moneyConfig:getNodeWithKey("name"):toStr()

    local onCmgePaySuccess = function ()
        self:paySuccess( {order = orderIdCom} )
    end
    PLATFORM_CMGE.addCallback("CMGE_NOTIFICATION_PAY_SUCCESS",onCmgePaySuccess)

    self:payBegan( {order = orderIdCom,productId=tostring(index),productPrice=amount,currencyType = "CNY"} )
    PLATFORM_CMGE.enterRechargeCenterView("M1063",orderIdCom,amount,name)
end

--[[
    通用支付
]]
function M.startPayCommon( self, index, moneyConfig ,tab )
     print("---------------- pay with platformCommon or coolpay --------------- ")
    local params = {}
    local server_data,sindex = game_data:getServer()
    local serverId = server_data.server
    local orderIdCom = tostring(game_data:getUserStatusDataByKey('uid')) .. "_" .. tostring(serverId) .. '_' .. tostring(index) .. '_' .. tostring(os.time())..'_'..tostring(util_system:getPlatformChannel());

    params.orderid = orderIdCom
    params.ext = orderIdCom
    params.userId = game_data:getUserStatusDataByKey("uid")
    params.unit = moneyConfig:getNodeWithKey("price"):toInt()
    params.description = moneyConfig:getNodeWithKey("name"):toStr()
    params.point_card = moneyConfig:getNodeWithKey("point_card")
    params.pructId = tostring(index)
    params.count = 1
    params.productName = moneyConfig:getNodeWithKey("name"):toStr();
    params.extUrl = game_url.getUrlForKey("get_vivo_order_id") --为vivo使用
    params.queryUrl = game_url.getUrlForKey("get_query_order") --为vivo使用
   -- cclog2(self.m_notify_urls["youku"], "self.m_notify_urls[youku]  ====  ")
    params.youkuUrl = self.m_notify_urls["youku"] or "nil"
    params.allPayNotifyUrl = self.m_notify_urls

    --uczwj 
    params.uc_url = game_url.getUrlForKey("notify_urls") --uc独家专享
    
    -- params.platform = getPlatFormExt() or "nil"
    params.platform = "nil"
    params.roleName = game_data:getUserStatusDataByKey("show_name") or ""-- 兄弟玩 独家专享
    params.roleLevel = game_data:getUserStatusDataByKey("level") or 1--兄弟玩 独家专享
    params.jinliUrl = game_url.getUrlForKey("get_jinli_order") --金立独家专享
    params.server_name = server_data.server_name 
    params.pay_respon_url = game_url.getUrlForKey("pay_respon_url")--动态获得支付回调地址
    params.uservip = game_data:getUserStatusDataByKey("vip") or 0
    params.userOwnCoin = game_data:getUserStatusDataByKey("coin") or 0 
    params.serverId = serverId

    local username = CCUserDefault:sharedUserDefault():getStringForKey("username") or "";
    local str = ""
    if string.sub(username,1,6) == "dachen" then
        str = string.sub(username,8,string.len(username))
    elseif string.sub(username,1,5) == "xiao7" then
        str = string.sub(username,7,string.len(username))
    elseif string.sub(username,1,12) == "androidxiao7" then
        str = string.sub(username,14,string.len(username))
    end
    params.guid = str
    params.sign = tab and tab.sign

    -- if platform_channel == "nduo" or platform_channel == "wanpu" or platform_channel == "kudong" or platform_channel == "nosdk"  or platform_channel == "7ku_yyb" or platform_channel == "7ku_yyb02" or platform_channel == "yyArm"  or platform_channel == "zhangyue" or platform_channel =="qitian" or platform_channel =="qitian1" or platform_channel =="qitian2" or platform_channel =="qitian3" or platform_channel == "android_360" then
    -- local bundle_id = identifier_zjr or ""
    -- local flag,_ = game_util:isKVGames(bundle_id)
    -- if (flag and game_data:isActiveOpenByID(544)) or platform_channel == "nduo" or platform_channel == "wanpu" or platform_channel == "kudong" or platform_channel == "7ku_yyb" or platform_channel == "7ku_yyb02" or platform_channel == "yyArm"  or platform_channel == "zhangyue" or platform_channel =="qitian" or platform_channel =="qitian1" or platform_channel =="qitian2" or platform_channel =="qitian3" or getPlatFormExt() == "platform_iyy" then
    --     game_util:addMoveTips({text = "当前渠道已关闭充值，请联系客服进行账号数据转移~"})
    --     return
    -- end
    if self:isPlatform7ku() then  -- 七酷支付
        self:startPay7KuAndroid( index, moneyConfig, params )  
        return
    elseif self:isPlatformXMW() then  -- 熊猫玩支付
        self:startPayXMWAndroid(  index, moneyConfig, params )
        return
    else
        local function buyResult(data)
            local result = data["result"]
            -- cclog("--- buy result cod %d", result)
            if result == 0 then 
                self:paySuccess( {order = orderIdCom}, result )
            elseif result == 1 then
                self:payFailed( {order = orderIdCom}, result )
            elseif result == -1 then
                self:payFailed( {order = orderIdCom}, result )
            else
                self:payFailed( {order = orderIdCom}, result )
            end
        end
        self:payBegan( {order = orderIdCom,productId=tostring(index),productPrice=moneyConfig:getNodeWithKey("price"):toInt(),currencyType = "CNY"} )

        
        require("shared.native_helper").buyProduct(params,buyResult)
        
        --require("shared.native_helper").buyProduct(params,buyResult)
    end
end



--[[
    检查是否是7ku支付
]]
function M.isPlatform7ku( self )
    -- 检查是否是7酷支付 
    local tempStr = "";
    if string.len(platform_channel) >= 3 then  -- 最开始的包写的channel为 "7ku", 后改为 "7ku_***"
        tempStr = string.sub(platform_channel,0,3)
    end
    if tempStr == "7ku" or tempStr=="ysd" then
        return true
    end
    return false
end

--[[
    检查是否是熊猫玩支付
]]
function M.isPlatformXMW( self )
    if platform_channel == "xmw" or getPlatFormExt()=="platform_xmw" then
        return true
    end
    return false
end

--[[
    七酷特殊处理
]]
function M.startPay7KuAndroid( self, index, moneyConfig, params )
    local data = _G.global_qiku
    if data == nil then
        game_util:addMoveTipsForNative({text = "数据出问题了，请退出游戏重新进入！"})
        return
    end
    --todo 7ku
    local server_data,sindex = game_data:getServer()
    local serverId = server_data.server
    local server_name = server_data.server_name
    local orderIdCom = tostring(game_data:getUserStatusDataByKey('uid')) .. "-" .. tostring(serverId) .. '-' .. tostring(index) .. '-' .. tostring(os.time());
    

    local params7ku = {}
    params7ku.product_id = tostring(index);
    params7ku.type = "qiku"
    params7ku.zoneid = "1"
    params7ku.openid = data["openid"]
    params7ku.openkey = data["openkey"]
    params7ku.pf = data["pf"]
    params7ku.pfkey = data["pfkey"]
    params7ku.pay_token = data["pay_token"]
    params7ku.login_type = data["login_type"]
    params7ku.count=1;
    params7ku.unit = moneyConfig:getNodeWithKey("price"):toInt()
    params7ku.orderid=orderIdCom;

    --查询用户余额
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        -- cclog2(data, "get_qiku_balance  back data ====  ")
        if data:getNodeWithKey("ret") and data:getNodeWithKey("ret"):toInt() == 0 then
            local userownPrice = data:getNodeWithKey("balance"):toInt();
            params.balance = userownPrice ;
            local productPrice =  params.unit*10 ;
            if productPrice <= userownPrice then
             -- if 1 <= userownPrice then
               params.ownerPrice = 1 ;
            else
               params.ownerPrice = 0 ;
            end
            local function buyResult(data)
                local result = data["result"]
                if result == 0 then 
                    local function responseMethod(tag,gameData)
                        self:paySuccess( {order = params.orderid}  )
                    end
                    if platform_channel == "7ku_msdk" then--七库新渠道，取别的东西                      
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("msdk_pay"), http_request_method.GET, params7ku,"msdk_pay")
                                     --TODO  7KUTEST
                    elseif platform_channel=="ysdk" then 
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("qiku_pay2"), http_request_method.GET, params7ku,"qiku_pay2")
                    else
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("qiku_pay"), http_request_method.GET, params7ku,"qiku_pay")
                    end
                end
            end
            local amount = moneyConfig:getNodeWithKey("price"):toInt()
            self:payBegan( {order = params.orderid ,productId=tostring(index), productPrice=amount,currencyType = "CNY"} )
            require("shared.native_helper").buyProduct(params,buyResult)
            cclog2("success get_qiku_balance   ")
        else
            cclog2("error get_qiku_balance   ")
        end
    end
    if platform_channel == "7ku_msdk" then--七库新渠道，取别的东西
        network.sendHttpRequest( responseMethod , game_url.getUrlForKey("get_msdk_balance") , http_request_method.GET , params7ku , "get_msdk_balance");
                    --TODO  7KUTEST
    elseif platform_channel=="ysdk" then 
        network.sendHttpRequest( responseMethod , game_url.getUrlForKey("get_qiku_balance2") , http_request_method.GET , params7ku , "get_qiku_balance2");
    else
        network.sendHttpRequest( responseMethod , game_url.getUrlForKey("get_qiku_balance") , http_request_method.GET , params7ku , "get_qiku_balance");
    end
end

--[[
    熊猫玩支付
]]
function M.startPayXMWAndroid( self, index, moneyConfig, params)
    cclog2(platform_channel, "error get_xmw_balance 22  ")
    local paramsxmw = {}
    if global_loginData and global_loginData.sdkToken ~= nil then
        paramsxmw.access_token = global_loginData.sdkToken;
    else
        game_util:addMoveTipsForNative({text = "数据出问题了，请退出游戏重新进入！"})
        return
    end

    if getPlatFormExt()=="platform_xmw" then
        paramsxmw.pt_id="ios"
     end
    paramsxmw.order_id = params.orderid;
    --请求数据
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data");
        cclog2(gameData, "gameData  ===  ")
        if data:getNodeWithKey("serial") then
            params.serial = data:getNodeWithKey("serial"):toStr();
            params.app_order_id = data:getNodeWithKey("app_order_id"):toStr();
            params.app_user_id = data:getNodeWithKey("app_user_id"):toStr();
            params.app_subject = data:getNodeWithKey("app_subject"):toStr();
            params.app_description = data:getNodeWithKey("app_description"):toStr();
            params.app_ext1 = data:getNodeWithKey("app_ext1"):toStr();
            params.app_ext2 = data:getNodeWithKey("app_ext2"):toStr();
            local function buyResult(data)
                local result = data["result"]
                if result == 0 then 
                    local function responseMethod(tag,gameData)
                        self:paySuccess( {order = params.orderid}  )
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
                end
            end
            local amount = moneyConfig:getNodeWithKey("price"):toInt()
            self:payBegan( {order = params.orderid ,productId=tostring(index), productPrice=amount,currencyType = "CNY"} )
            require("shared.native_helper").buyProduct(params,buyResult)
        else
            cclog2("error get_xmw_balance   ")
        end
    end
    network.sendHttpRequest(responseMethod , game_url.getUrlForKey("get_xmw2_order") , http_request_method.GET , paramsxmw , "get_xmw2_order");
end

--[[
    ios appstore 支付
]]
function M.startPayByCmgeAppstoreIOS( self, index, moneyConfig )
    local bundle = moneyConfig:getNodeWithKey("cost"):toStr();
    cclog("cmgeapp or appstore")
    -- cclog2( tostring(bundle), "bundle  ========= ")
    local selfUid = game_data:getUserStatusDataByKey('uid');
    local server_data,sindex = game_data:getServer()
    local serverId = server_data.server
    local orderIdCom = tostring(selfUid) .. "-" .. tostring(serverId) .. '-' .. tostring(index) .. '-' .. tostring(os.time());
    local amount = moneyConfig:getNodeWithKey("price"):toInt();
    local payurl = game_url.getUrlForKey("pay_kubi") .. "&product_id=" .. index .. "&receipt-data=";
    if setChackUrl then
        setChackUrl(payurl);
    end
    
    self:payBegan( {order = orderIdCom,productId=tostring(index),productPrice=amount,currencyType = "CNY"} )
    if buy then
        buy(bundle);
        require("game_ui.game_loading").show();
    end
end


--[[
    开始支付
]]
function M.startPay( self, index, moneyConfig )
    local productPriceForiOS = moneyConfig:getNodeWithKey("price") and moneyConfig:getNodeWithKey("price"):toInt()
    local function buysth( tab )
        self:registerCallBack(productPriceForiOS)

        if getPlatForm() == "91" then   -- ios 91 支付
            self:startPayBy91IOS( index, moneyConfig )
        elseif(getPlatForm() == "pp")then
            self:startPayByPPIOS( index, moneyConfig )
        elseif getPlatForm() == "itools" then
            self:startPayByItoolsIOS( index, moneyConfig )
        elseif getPlatForm() == "cmge" then
            self:startPayByCmgeIOS(  index, moneyConfig  )
        elseif getPlatForm() == "cmgeapp" or getPlatForm() == "appstore" or getPlatFormExt() == "platform_kvgame" then
            self:startPayByCmgeAppstoreIOS(  index, moneyConfig  )
        elseif getPlatForm() == "platformCommon" or getPlatForm() == "coolpay" then  -- 普通支付
            self:startPayCommon( index, moneyConfig ,tab)
        end
    end

    local function willBuySth(  )
        local m_shared = 0;
        function tick( dt )
            sharedDirector:getScheduler():unscheduleScriptEntry(m_shared)
            buysth()
        end
        m_shared = sharedDirector:getScheduler():scheduleScriptFunc(tick, 1/64, false)
    end

    if self:isNeedGetPayNotifyUrl( getPlatFormExt() ) then 
        self:getPayCallURLS( willBuySth )
    elseif self:isNeedGetPayOrder(getPlatFormExt()) or self:isNeedGetPayOrder(util_system:getPlatformChannel()) then
        self:getPayOrderAndBuysth(buysth,index)
    else
        willBuySth()
    end
end

--[[
   -- 获取回调地址 
]]
function M.getPayCallURLS( self, getUrlsCallBack )
    cclog2("getPayCallURLS =======  ")
    local method = 0
    local url = game_url.getUrlForKey("pay_respon_url");
    local httpReq = CCHttpRequest:new()
        httpReq:setUrl(url)
    local callback = function ( tag,response,contentLength )
        require("game_ui.game_loading").close();
        contentLength = contentLength or 0;
        cclog("responseMethod --------tag=%s,code=%d  ; callbackTab == %s",tag,response:getResponseCode(),tostring(callbackTab),contentLength);
        if response:isSucceed()==false then
            local responseCode = response:getResponseCode()
            local errorMsg = errorTab["error_" .. tostring(responseCode)];
            if errorMsg then
                require("game_ui.game_pop_up_box").showAlertView(errorMsg);
            else
                require("game_ui.game_pop_up_box").showAlertView(string_config.m_net_req_failed);
            end
            retrunFlag = true;
        else
            local buffer = response:getResponseDataBuffer();
            local gameData = util_json:new(buffer);
            
            if gameData and (not gameData:isEmpty()) then 
                -- cclog2(gameData, "gameData ===  ")
                self.m_notify_urls = gameData:getNodeWithKey("notify_urls") and json.decode(gameData:getNodeWithKey("notify_urls"):getFormatBuffer()) or {}
            end
            if type(getUrlsCallBack) == "function" then
                getUrlsCallBack()
            end
        end
    end
    httpReq:registerScriptTapHandler(callback)
    httpReq:setRequestType(method)
    httpReq:setTag("pay_respon_url")
    CCHttpClient:getInstance():send(httpReq)
    httpReq:release()
    -- game_util:addMoveTips({text = "正在支付"})
    cclog("get http start ----- tag = " .. "pay_respon_url " .. ";url = " .. url);
    require("game_ui.game_loading").show();
end


--[[
    支付之前是否需要请求支付回调地址
]]
function M.isNeedGetPayNotifyUrl( self, platform )
    if get_pay_notifyUrl_platform[tostring(platform)] == true then
        cclog2(platform, " vi vip ,this platform need get pay  notify_urls ")
        return true
    end
    return false
end

function M.isNeedGetPayOrder( self,platform )
    if get_pay_order_platform[tostring(platform)] == true then
        cclog2(platform, " vi vip ,this platform need get pay order ")
        return true
    end
    return false
end

function M.getPayOrderAndBuysth( self, getUrlsCallBack, index )
    -- body
    local method = 0
    local url = game_url.getUrlForKey("notify_urls");

    if platform_channel == "downjoy2" then
        url = "/pay/?method=get_downjoy_order"
    end

    url = self:refreshOrderUrl(url,index)
    cclog2(url)
    local httpReq = CCHttpRequest:new()
        httpReq:setUrl(url)
    local callback = function ( tag,response,contentLength )
        require("game_ui.game_loading").close();
        contentLength = contentLength or 0;
        cclog("responseMethod --------tag=%s,code=%d  ; callbackTab == %s",tag,response:getResponseCode(),tostring(callbackTab),contentLength);
        if response:isSucceed()==false then
            local responseCode = response:getResponseCode()
            local errorMsg = errorTab["error_" .. tostring(responseCode)];
            if errorMsg then
                require("game_ui.game_pop_up_box").showAlertView(errorMsg);
            else
                require("game_ui.game_pop_up_box").showAlertView(string_config.m_net_req_failed);
            end
            retrunFlag = true;
        else
            local buffer = response:getResponseDataBuffer();
            local gameData = util_json:new(buffer);
            local sign = ""
            if gameData and (not gameData:isEmpty()) then 
                cclog2(gameData)
                sign = gameData:getNodeWithKey("sign") and gameData:getNodeWithKey("sign"):toStr()
            end
            if type(getUrlsCallBack) == "function" then
                getUrlsCallBack({sign = sign})
            end
        end
    end
    httpReq:registerScriptTapHandler(callback)
    httpReq:setRequestType(method)
    httpReq:setTag("notify_urls")
    CCHttpClient:getInstance():send(httpReq)
    httpReq:release()
    -- game_util:addMoveTips({text = "正在支付"})
    require("game_ui.game_loading").show();
end

function M:refreshOrderUrl( url,index )
    -- body
    local productPriceForiOS = 0;
    local gameShopConfig = getConfig(game_config_field.charge);
    if identifier_zjr and identifier_zjr ~= "" then
            cclog("identifier_zjr   ----------  ")
            if getConfig(game_config_field.charge_HD) then
            cclog("identifier_zjr   ----------  22222")
            gameShopConfig = getConfig(game_config_field.charge_HD);
        end
    end
    local moneyConfig = gameShopConfig:getNodeWithKey(tostring(index)) 
    productPriceForiOS = moneyConfig:getNodeWithKey("price") and moneyConfig:getNodeWithKey("price"):toInt()

    local server_data,sindex = game_data:getServer()
    local serverId = server_data.server
    local server_name = server_data.server_name
    local username = CCUserDefault:sharedUserDefault():getStringForKey("username") or "";
    local str = ""
    if string.sub(username,1,6) == "dachen" then
        str = string.sub(username,8,string.len(username))
    elseif string.sub(username,1,5) == "xiao7" then
        str = string.sub(username,7,string.len(username))
    elseif string.sub(username,1,12) == "androidxiao7" then
        str = string.sub(username,14,string.len(username))
    end
    local keyTab = {"game_guid","game_area","game_level","game_orderid","game_price","game_role_id","game_role_name","notify_id","subject","extends_info_data","game_umid"}
    local params = {}
    params.game_area = serverId
    params.game_level = game_data:getUserStatusDataByKey("level") or 1
    local time=os.time()
    params.game_orderid = tostring(game_data:getUserStatusDataByKey('uid')) .. "-" .. tostring(serverId) .. '-' .. tostring(index) .. '-' .. tostring(time);
    params.game_price = moneyConfig:getNodeWithKey("price"):toInt()
    params.game_role_id = game_data:getUserStatusDataByKey("uid")
    params.game_umid = CCUserDefault:sharedUserDefault():getStringForKey("userid") or ""

    local myName = game_data:getUserStatusDataByKey("show_name") or ""
    params.game_role_name = util.url_encode(myName)
    params.notify_id = "-1"
    local coinName = moneyConfig:getNodeWithKey("name"):toStr()
    params.subject = util.url_encode(coinName)
    params.game_guid = str
    local extends_info_data = tostring(game_data:getUserStatusDataByKey('uid')) .. "-" .. tostring(serverId) .. '-' .. tostring(index) .. '-' .. tostring(time);        
    params.extends_info_data = extends_info_data
    for k,v in pairs(keyTab) do
        if params[v] then
            url = url .. "&" .. v .. "=" .. params[v]
        end
    end
    return url
end


--[[
    购买 index 支付项id
]]
function M.rechargeByIndex( self, index, callback )
    self.m_notify_urls = {}
    self.m_callBack = callback
    self.m_buy_index = index

    local gameShopConfig = getConfig(game_config_field.charge);
    if identifier_zjr and identifier_zjr ~= "" then
        if getConfig(game_config_field.charge_HD) then
            gameShopConfig = getConfig(game_config_field.charge_HD);
        end
    end
    local moneyConfig = gameShopConfig:getNodeWithKey(tostring( self.m_buy_index ))
    if not moneyConfig then
        self:rechargeCallBack( "no_item" )
    else
        self:startPay( index, moneyConfig )
    end
end

--[[
    回调
]]
function M.rechargeCallBack( self, payCode, payMsg )
    payMsg = payMsg or ""
    if payCode == "no_item" then     -- 没有支付项配置 
        payMsg = "没有支付项"
    elseif true then
    end
    if type( self.m_callBack ) == "function" then
        self.m_callBack( payCode, payMsg )
    end 
    self:destory()
    local offline = game_data:getUserStatusDataByKey('pay_times_today')
    if ( offline and offline == 0 ) and getPlatFormExt() == "platform_kvgame" and payCode == "success" then
        game_scene:addPop("game_offline_pop")
    end

end

--[[
    开始支付
]]
function M.payBegan( self, statistics_data )
    -- cclog2(statistics_data,  "payBegan  ===============  " )
    statistics_data = statistics_data or {}
    if game_data_statistics then
        game_data_statistics:payBegan( statistics_data )
    end
end

--[[
    支付成功
]]
function M.paySuccess( self, statistics_data )
    -- cclog2(statistics_data,  "paySuccess  ===============  " )
    statistics_data = statistics_data or {}
    -- 统计信息
    if game_data_statistics then
        game_data_statistics:paySuccess( statistics_data )
    end
    self:rechargeCallBack( "success", {} )
end

--[[
    支付失败
]]
function M.payFailed( self, statistics_data )
    -- cclog2(statistics_data,  "payFailed  ===============  " )
    statistics_data = statistics_data or {}
    if game_data_statistics then
        game_data_statistics:payFailed( statistics_data )
    end
    self:rechargeCallBack( "failed", {} )
end

--[[
    关闭支付
]]
function M.close( self )
    if self.destory then
        self:destory()
    end
end

return M;