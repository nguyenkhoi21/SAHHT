--超值签到
local game_superDaily_pop = {
    m_tGameData = nil,
    m_tab_ui = nil,
    m_node_tableView = nil,
    value_sign_cfg = nil,
    m_lab_des = nil,
    m_curIdTab = nil,
    m_monthData_tab = nil,
    anim_section = nil,
    m_node_ball = nil,
    m_sp_ballFull = nil,
    m_sp_jinduitaoBg = nil,
    m_label_charge = nil,
    m_label_des1 = nil,
    m_label_des2 = nil,
    m_label_des3 = nil,
    m_label_des4 = nil,
    m_label_price = nil,
    m_label_rate = nil,
    m_btn_charge = nil,
    m_pay_client = nil,
    m_buy_flag = nil,
    month = nil,
    m_select_index = nil,
    m_cur_selectcell = nil,
    signID_tab = nil,
    m_btn_getDayReward = nil,
    m_node_day = nil,
    m_btn_month = nil,

};
--[[--
    销毁ui
]]
function game_superDaily_pop.destroy(self)
    -- body
    cclog("-----------------game_superDaily_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_tab_ui = nil;
    self.m_node_tableView = nil;
    self.value_sign_cfg = nil;
    self.m_lab_des = nil;
    self.m_curIdTab = nil;
    self.m_monthData_tab = nil;
    self.anim_section = nil;
    self.m_node_ball = nil;
    self.m_sp_ballFull = nil;
    self.m_sp_jinduitaoBg = nil;
    self.m_label_charge = nil;
    self.m_label_des1 = nil;
    self.m_label_des2 = nil;
    self.m_label_des3 = nil;
    self.m_label_des4 = nil;
    self.m_label_price = nil;
    self.m_label_rate = nil;
    self.m_btn_charge = nil;
    self.m_pay_client = nil;
    self.m_buy_flag = nil;
    self.month = nil;
    self.m_select_index = nil;
    self.m_cur_selectcell = nil;
    self.signID_tab = nil;
    self.m_btn_getDayReward = nil;
    self.m_node_day = nil;
    self.m_btn_month = nil;

end
--[[--
    返回
]]
function game_superDaily_pop.back(self,type)
    -- game_scene:removePopByName("game_superDaily_pop")
    -- local function endCallFunc()
    --     self:destroy();
    -- end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_superDaily_pop.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/Gringotts.plist");
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag ==== ")
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 2 then -- 去充值
            self:checkAndPay()
        elseif btnTag == 997 then
            local function responseMethod2( tag,gameData )
                if gameData then
                    self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                    local reward = self.m_tGameData.reward
                    game_util:rewardTipsByDataTable(reward)
                    self:refreshUi()

                end
            end
            network.sendHttpRequest(responseMethod2,game_url.getUrlForKey("pay_sign_get_month_reward"), http_request_method.GET, nil,"pay_sign_get_month_reward",true,true)
        elseif btnTag == 999 then --领取签到奖励
            local function responseMethod2( tag,gameData )
                if gameData then
                    self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                    local reward = self.m_tGameData.reward
                    game_util:rewardTipsByDataTable(reward)
                    self:refreshUi()
                end
            end
            local params = {}
            params.reward_id = self.signID_tab[self.m_tGameData.cur_day]
            network.sendHttpRequest(responseMethod2,game_url.getUrlForKey("pay_sign_get_reward"), http_request_method.GET, params,"pay_sign_get_reward",true,true)
        elseif btnTag == 998 then --已经领取过当日签到奖励
            game_util:addMoveTips({text = "Đã nhận quà rồi"})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_super_daliy.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local  m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_node_day = ccbNode:nodeForName("m_node_day")
    self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")
    self.m_node_ball = ccbNode:nodeForName("m_node_ball")
    self.m_sp_ballFull = ccbNode:spriteForName("m_sp_ballFull")
    self.m_sp_jinduitaoBg = ccbNode:spriteForName("m_sp_jinduitaoBg")
    self.m_label_charge = ccbNode:labelTTFForName("m_label_charge")
    self.m_label_des1 = ccbNode:labelTTFForName("m_label_des1")
    self.m_label_des2 = ccbNode:labelTTFForName("m_label_des2")
    self.m_label_des3 = ccbNode:labelTTFForName("m_label_des3")
    self.m_label_des4 = ccbNode:labelTTFForName("m_label_des4")
    self.m_label_price = ccbNode:labelTTFForName("m_label_price")
    self.m_label_rate = ccbNode:labelTTFForName("m_label_rate")
    self.m_sp_ballFull:setVisible(false)
    self.m_btn_charge = ccbNode:controlButtonForName("m_btn_charge")
    self.m_btn_getDayReward = ccbNode:controlButtonForName("m_btn_getDayReward")
    self.m_btn_charge:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_btn_getDayReward:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_btn_month = ccbNode:controlButtonForName("m_btn_month")
    self.m_btn_month:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

    local charge_num= self.value_sign_cfg["1"]["charge_num"]
    if charge_num then
        self.m_label_price:setString("Nạp xu*"..charge_num.."được nhận")
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    m_root_layer:setTouchEnabled(true);
   
    return ccbNode;
end


--[[--
    创建列表
]]
function game_superDaily_pop.createTableView( self,viewSize )
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- if self.m_buy_flag == 1 then
        --     game_util:addMoveTips( {text = "已补签成功。"} )
        --     return
        -- end
        -- if self.m_tGameData.replenish_sign_times < self.m_tGameData.replenish_pay_times then

        --     game_util:addMoveTips( {text = "今日已成功补签"} )
        --     return
        -- end
        self:checkAndPay(btnTag)
    end
    local totalItem = game_util:getTableLen(self.m_monthData_tab)
    local params = {};
    local viewSize = viewSize
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    params.direction = kCCScrollViewDirectionVertical
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    self.m_cellSize = itemSize
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onBtnClick",onBtnClick);--bind button on click event
            ccbNode:openCCBFile("ccb/ui_super_daliy_item.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.4));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_sp_kuang = ccbNode:spriteForName("m_sp_kuang")
            local m_sp_day1 = ccbNode:spriteForName("m_sp_day1")
            local m_sp_day2 = ccbNode:spriteForName("m_sp_day2")
            local m_sp_tick = ccbNode:spriteForName("m_sp_tick")
            local m_btn_buqian = ccbNode:controlButtonForName("m_btn_buqian")
            local m_layer_black = ccbNode:layerForName("m_layer_black")
            -- m_btn_buqian:setVisible(false)
            m_btn_buqian:setTag(self.signID_tab[index+1])
            m_btn_buqian:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6) 
            if self.m_select_index == index +1 then
                self.m_cur_selectcell = cell
                m_sp_kuang:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_super_daliy_gezi1.png")) 
            else
                m_sp_kuang:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_super_daliy_gezi2.png")) 
            end
            if self.m_tGameData.cur_day == index + 1 then
                m_layer_black:setVisible(false)
            else
                m_layer_black:setVisible(true)

            end
            for i=1,4 do
                local m_node_reward = ccbNode:nodeForName("m_node_reward" .. i)
                local reward = self.m_monthData_tab[(index+1)]["reward"][i] 
                local icon,name,count = game_util:getRewardByItemTable(reward)
                if icon then
                    icon:setScale(0.5)
                    m_node_reward:addChild(icon)
                    local numLab = CCLabelTTF:create("x" .. count,TYPE_FACE_TABLE.Arial_BoldMT,18)
                    icon:addChild(numLab,10,10)
                    numLab:setPosition(ccp(30,10))
                end
            end
            local day1,day2 = 0,0
            if index+1 > 9 then
                day1 = (index+1)/10
                day1 = math.floor(day1)
                day2 = (index+1)%10
            else
                day1 = 0
                day2 = index + 1
            end

            m_sp_day1:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_super_daliy_" .. day1 ..".png")) 
            m_sp_day2:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_super_daliy_" .. day2 ..".png")) 
            if self.m_tGameData.sign_log[tostring(self.month)] and self.m_tGameData.sign_log[tostring(self.month)][tostring(index+1)] then
                m_sp_tick:setVisible(true)
                m_btn_buqian:setVisible(false)
            else
                if index + 1 < self.m_tGameData.cur_day then
                    m_btn_buqian:setVisible(true)
                else
                    m_btn_buqian:setVisible(false)
                end

                m_sp_tick:setVisible(false)
            end

            if self.m_tGameData.sign_log[tostring(self.month)] and self.m_tGameData.sign_log[tostring(self.month)][tostring(index+1)] then

                if self.m_tGameData.sign_log[tostring(self.month)][tostring(index+1)].free_times == 1 and  (index+1) > self.m_tGameData.cur_day then
            --         m_sp_tick:setVisible(false)
            --     elseif self.m_tGameData.sign_log[tostring(self.month)][tostring(index+1)].got_reward then
            --         m_sp_tick:setVisible(true)
            --     else
                    m_sp_tick:setVisible(false)
            --     end
            -- else
            --     if index + 1 < self.m_tGameData.cur_day then
            --         m_btn_buqian:setVisible(true)
                else
                    m_sp_tick:setVisible(true)
                end

            --     m_sp_tick:setVisible(false)
            end
            
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if index >= totalItem then return end;
       
        if eventType == "ended" and item then
                if self.m_cur_selectcell then
                    local ccbNode2 = tolua.cast(self.m_cur_selectcell:getChildByTag(10),"luaCCBNode") 
                    local m_sp_kuang = ccbNode2:spriteForName("m_sp_kuang")
                    -- m_sp_kuang:setVisible(false)
                    m_sp_kuang:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_super_daliy_gezi2.png")) 
                    
                end
                local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
                local m_sp_kuang = ccbNode:spriteForName("m_sp_kuang")
                self.m_select_index = index +1
                self.m_cur_selectcell = item
                m_sp_kuang:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_super_daliy_gezi1.png")) 
                -- self:refreshUi()
                -- game_util:setTableViewIndex(self.m_select_index,self.m_node_tableView,10,12)
        end
    end
    return  TableViewHelper:create(params);
end
function game_superDaily_pop.setProgress( self )
    local expBg = self.m_sp_jinduitaoBg
    local expBgSize = expBg:getContentSize(); 
    local current_score = self:getFreeDays()
    local score_max = 5
    local percentage = current_score/score_max * 100  
    local params = {}
    params.percentage = percentage
    params.fileName = "ui_super_daliy_jindutiao1.png"
    local expBarAdd = game_util:createProgressTimer(params)
    expBg:removeAllChildrenWithCleanup(true)
    expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
    expBg:addChild(expBarAdd,2,1);
    self.m_label_charge:setString("Tổng nạp:(" .. current_score .. "/" .. score_max .. ")")
end
--[[
    获取免费天数
]]
function game_superDaily_pop.getFreeDays( self )
    local alreadyDay = 4 --已充值天数
    local alreadyGetFree = 0 --已领取免费奖励的天数
    local freeDays = 0
    alreadyDay = game_util:getTableLen(self.m_tGameData.sign_log[tostring(self.month)]) 
    local dayNum = {}
    -- if alreadyDay <5 then
    --     freeDays = alreadyDay
    -- else
    --     freeDays = alreadyDay%6
    -- end
    -- return freeDays
    for k,v in pairs(self.m_tGameData.sign_log[tostring(self.month)]) do
        table.insert(dayNum,tonumber(k))
    end
    table.sort( dayNum)

    -- for i=1,alreadyDay do
    --     if self.m_tGameData.sign_log[tostring(self.month)][tostring(dayNum[i])].free_times == 0 then
    --         freeDays = freeDays + 1

    --     elseif  self.m_tGameData.sign_log[tostring(self.month)][tostring(dayNum[i])].free_times == 1 and self.m_tGameData.sign_log[tostring(self.month)][tostring(dayNum[i])].pay_times > 0 and tonumber(dayNum[i]) <= tonumber(self.m_tGameData.cur_day) then
    --         freeDays = 0
    --         freeDays = freeDays + 1

    --     elseif self.m_tGameData.sign_log[tostring(self.month)][tostring(dayNum[i])].free_times ==1 and  tonumber(dayNum[i]) > tonumber(self.m_tGameData.cur_day) then
    --         freeDays = 5

    --     else

    --         freeDays = 0
    --     end
    -- end
    local alreadyDay = 0
    local totalDay = 0
    for k,v in pairs(self.m_tGameData.sign_log[tostring(self.month)]) do
        if v.pay_times > 0 then
            totalDay = totalDay + 1
        end
        if v.free_times > 0 then
            alreadyDay = alreadyDay + 1
        end
    end
    freeDays = totalDay - (alreadyDay * 5)
    return freeDays
end
--[[
    关闭支付
]]
function game_superDaily_pop.closePay( self )
    if self.m_pay_client and self.m_pay_client.destroy then
        self.m_pay_client:destroy()
        self.m_pay_client = nil
    end
end
--[[
    去支付
]]
function game_superDaily_pop.checkAndPay( self,btnTag )
    local payCallBack = function ( code, msg )
        if code == "success" then
            game_util:addMoveTips({text = "Đã mua"})
            self.m_buy_flag = 1

            self:toOwnServer(btnTag)
            game_util:closeAlertView()
        elseif code == "failed" then
            game_util:addMoveTips({text = "Thất bại"})
            game_util:closeAlertView()
        else
            game_util:addMoveTips({text = "Nếu thanh toán xong, hãy tạo mới giao diện"})
            game_util:closeAlertView()
        end
    end 

    -- self:showRefreshTips()
    self:closePay()
    if btnTag then
        CCUserDefault:sharedUserDefault():setStringForKey("superSignId",tostring(btnTag))
        CCUserDefault:sharedUserDefault():flush();
        self.m_pay_client = game_util:buySthByChargeIndex( 17, payCallBack) --补签
        --  local function responseMethod(tag,gameData)
        --     local data = gameData:getNodeWithKey("data");
        --     game_scene:enterGameUi("ui_vip",{gameData = gameData});
        --     --game_scene:addPop("ui_vip_show_pop",{flag=2})
        --     self:destroy()
        -- end
        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
    else
         local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data");
            game_scene:enterGameUi("ui_vip",{gameData = gameData});
            --game_scene:addPop("ui_vip_show_pop",{flag=2})
            self:destroy()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        -- self.m_pay_client = game_util:buySthByChargeIndex( 9, payCallBack) --签到
    end
    -- cclog2("  start checkAndPay  ============================  start ")
end
function game_superDaily_pop.isCanGetReward( self )
    local isBuqian,isFree,isGet,isSign = false,false,false,false
    if self.m_tGameData.sign_log[tostring(self.month)] and self.m_tGameData.sign_log[tostring(self.month)][tostring(self.m_tGameData.cur_day)] then
       
        if self.m_tGameData.sign_log[tostring(self.month)][tostring(self.m_tGameData.cur_day)].free_times ==1 then
            isFree = true
        end
        if self.m_tGameData.sign_log[tostring(self.month)][tostring(self.m_tGameData.cur_day)].got_reward then
            isGet = true --已经领取过奖励
        else
            isGet = false --
        end
    else
        isGet,isBuqian,isFree,isSign = false,false,false,false
    end
    if self.m_tGameData.replenish_sign_times == 0 and self.m_tGameData.replenish_pay_times > 0 then
        isBuqian = true --可以领取补签奖励
    elseif self.m_tGameData.replenish_sign_times > 0 and self.m_tGameData.replenish_pay_times > 0 then 
        isBuqian = false --已经补签过了
    end
    if self.m_tGameData.sign_log[tostring(self.month)] and self.m_tGameData.sign_log[tostring(self.month)][tostring(self.m_tGameData.cur_day)] then
        isSign = true
    else
        isSign = false
    end
    -- cclog2(isSign,"isSign === ")
    return isBuqian,isFree,isGet,isSign
end
function game_superDaily_pop.toOwnServer( self,btnTag ) --充值成功以后 刷新数据 来判断是否有可以领奖
    local function responseMethod( tag,gameData )
        if gameData then
            if gameData ~= nil and tolua.type(gameData) == "util_json" then
                self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                if btnTag then --补签按钮可见 领取奖励
                    local function responseMethod2( tag,gameData )
                        if gameData then
                            self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                            local reward = self.m_tGameData.reward
                            game_util:rewardTipsByDataTable(reward)
                            CCUserDefault:sharedUserDefault():setStringForKey("superSignId","")
                            self:refreshUi()
                        end
                    end
                    local params = {}
                    params.reward_id = btnTag
                    network.sendHttpRequest(responseMethod2,game_url.getUrlForKey("pay_sign_replenish_sign"), http_request_method.GET, params,"pay_sign_replenish_sign",true,true)
                else --签到按钮可见 领取奖励

                end
                self:refreshUi()
            end
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pay_sign_index"), http_request_method.GET, nil,"pay_sign_index",true,true)
   
end
--[[--
    刷新ui
]]
function game_superDaily_pop.refreshUi(self,isDingwei)
    self:setProgress()
    self.m_node_tableView:removeAllChildrenWithCleanup(true)
    local viewSize = self.m_node_tableView:getContentSize()
    self.m_node_tableView:addChild(self:createTableView(viewSize),10,10)
    self.m_node_ball:setVisible(true)
    self.m_sp_ballFull:setVisible(false)
    if self.m_tGameData.double_reward_rate then
        if tonumber(self.m_tGameData.double_reward_rate) < 40 then
            self.anim_section = "daiji1"
        elseif tonumber(self.m_tGameData.double_reward_rate) < 70 then
            self.anim_section = "daiji2"
        elseif tonumber(self.m_tGameData.double_reward_rate) < 100 then
            self.anim_section = "daiji3"
        elseif tonumber(self.m_tGameData.double_reward_rate) == 100 then
            self.m_node_ball:setVisible(false)
            self.m_sp_ballFull:setVisible(true)
        else
            self.anim_section = "daiji1"
        end
    else
        self.anim_section = "daiji1"
    end
    self.m_label_rate:setString(tostring(self.m_tGameData.double_reward_rate))
    local function animCallFunc2(animNode, theId,theLabelName)
        animNode:playSection(self.anim_section)
    end
    self.m_node_ball:removeAllChildrenWithCleanup(true)
    local m_chest_anim = game_util:createUniversalAnim({animFile = "anim_jingyancao",rhythm = 1.0,loopFlag = true,animCallFunc = animCallFunc2,actionName = self.anim_section});
    self.m_node_ball:addChild(m_chest_anim,100,100)


    if isDingwei then
        local x = 0
        if self.m_tGameData.cur_day < 13 then
            x = 0
        end
        if self.m_tGameData.cur_day > 12 and self.m_tGameData.cur_day < 21 then
            x = 12
        else
            x = self.m_tGameData.cur_day
        end
        game_util:setTableViewIndex(x,self.m_node_tableView,10,12)
    end


    local  isBuqian,isFree,isGet,isSign = self:isCanGetReward()
    -- cclog2(isSign,"isSign ==== ")
    if isSign or isFree then --当日已经签到
        self.m_btn_charge:setVisible(false)
        self.m_btn_getDayReward:setVisible(true)
    else
        self.m_btn_charge:setVisible(true)
        self.m_btn_getDayReward:setVisible(false)
    end
    if isGet then
        self.m_btn_getDayReward:setTag(998)
        self.m_btn_getDayReward:setColor(ccc3(150,150,150))
    else
        self.m_btn_getDayReward:setTag(999)
        self.m_btn_getDayReward:setColor(ccc3(255,255,255))

    end
    if self.m_tGameData.has_month_reward then
        self.m_node_day:setVisible(false)
        self.m_btn_month:setVisible(true)
    else
        self.m_node_day:setVisible(true)
        self.m_btn_month:setVisible(false)
    end
    local des = self.m_tGameData.month_reward
    self.m_label_des1:setString(des)
end
--[[--
    初始化
]]
function game_superDaily_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    self.m_select_index = self.m_tGameData.cur_day or 1

    self.value_sign_cfg = getConfig(game_config_field.value_sign);
    self.value_sign_cfg = json.decode(self.value_sign_cfg:getFormatBuffer()) or {}
    self.month = ""
    for k,v in pairs(self.m_tGameData.sign_log) do
        self.month = k
    end
    self.m_monthData_tab,self.signID_tab = {},{}
    for i=1,game_util:getTableLen(self.value_sign_cfg) do
        if self.value_sign_cfg[tostring(i)]["date"][1] == tonumber(self.month) then
            table.insert(self.m_monthData_tab,self.value_sign_cfg[tostring(i)])
            table.insert(self.signID_tab,i)
        end
    end
    local buqianid = CCUserDefault:sharedUserDefault():getStringForKey("superSignId")
    if buqianid and buqianid ~= "" and self.m_tGameData.replenish_sign_times < self.m_tGameData.replenish_pay_times then
        local function responseMethod2( tag,gameData )
            if gameData then
                self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                local reward = self.m_tGameData.reward
                game_util:rewardTipsByDataTable(reward)
                CCUserDefault:sharedUserDefault():setStringForKey("superSignId","")
                CCUserDefault:sharedUserDefault():flush();
            end
        end
        local params = {}
        params.reward_id = tonumber(buqianid)
        network.sendHttpRequest(responseMethod2,game_url.getUrlForKey("pay_sign_replenish_sign"), http_request_method.GET, params,"pay_sign_replenish_sign",true,true)
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_superDaily_pop.create(self,t_params)
    self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi(true);
    return  m_popUi;
end
return game_superDaily_pop;