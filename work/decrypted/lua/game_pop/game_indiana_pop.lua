--一元夺宝
local game_indiana_pop = {
    m_tGameData = nil,
    m_tab_ui = nil,
    m_scroll_view_tips = nil,
    m_node_tips = nil,
    m_tips_buy_cost_1 = nil,
    m_tips_buy_cost_10 = nil,
    m_layer_tips_mask = nil,
    m_node_btn_info = nil,
    m_select_btnTag = nil,
    m_raiders_reward_cfg = nil,
    m_node_time = nil,
    m_lab_jifen = nil,
    buttonState=nil,  --商城和轮盘的控制
};
--[[--
    销毁ui
]]
function game_indiana_pop.destroy(self)
    -- body
    cclog("-----------------game_indiana_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_tab_ui = nil;
    self.m_scroll_view_tips = nil;
    self.m_node_tips = nil;
    self.m_tips_buy_cost_1 = nil;
    self.m_tips_buy_cost_10 = nil;
    self.m_layer_tips_mask = nil;
    self.m_select_btnTag = nil;
    self.m_node_btn_info = nil;
    self.m_raiders_reward_cfg = nil;
    self.m_node_time = nil;
    self.m_lab_jifen = nil;
    self.buttonState=nil;
end
--[[--
    返回
]]
function game_indiana_pop.back(self,type)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
pos = {ccp(124,111),ccp(229,111),ccp(334,111),ccp(439,111)}
--[[--
    读取ccbi创建ui
]]
function game_indiana_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag ==== ")
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 101 then
            local raiders = getConfig(game_config_field.raiders);
            local version = self.m_tGameData.version
            local des = raiders:getNodeWithKey(tostring(version)):getNodeWithKey("des"):toStr()
            game_scene:addPop("game_active_limit_detail_pop",{openMsg = des})
        elseif btnTag == 102 then
           local function responseMethod(tag,gameData)
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag == 104 then
            local function responseMethod(tag,gameData)
                if gameData then
                    self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                    game_util:addMoveTips({text = "Đã tạo mới"})  --刷新成功
                    self:refreshUi()
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("raiders_refresh_index"), http_request_method.GET, nil,"raiders_refresh_index")
        elseif btnTag == 105 then
            if self.buttonState ~= 0 then 
                local function responseMethod( tag,gameData )
                    if gameData ~= nil and tolua.type(gameData) == "util_json" then
                        -- game_scene:addPop("ui_indiana_shop_pop",{gameData = gameData}) --商城
                        game_scene:addPop("game_indianaPan_pop",{gameData = gameData}); --转盘
                    end
                end
                --转盘
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("raiders_roulette_index"), http_request_method.GET, nil,"raiders_roulette_index")
            else
                 local function responseMethod( tag,gameData )
                    if gameData ~= nil and tolua.type(gameData) == "util_json" then
                        game_scene:addPop("ui_indiana_shop_pop",{gameData = gameData}) --商城
                        --game_scene:addPop("game_indianaPan_pop",{gameData = gameData}); --转盘
                    end
                end
                --商城
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("raiders_index"), http_request_method.GET, nil,"raiders_index")
            end
        elseif btnTag >=201 and btnTag <=204 then
            self.m_select_btnTag = btnTag
            local poss = self.m_node_btn_info:getParent():convertToNodeSpace(pos[btnTag-200]);
            self.m_node_btn_info:setPosition(poss)

            local _,_,coin = self:getRewardTab()
            self.m_tips_buy_cost_1:setString(tostring(coin[btnTag-200]))
            self.m_tips_buy_cost_10:setString(tostring(coin[btnTag-200] * 10))
            self.m_node_tips:setVisible(true)
        elseif btnTag == 10001 or btnTag == 10010 then
            self.m_node_tips:setVisible(false)
            local function responseMethod( tag,gameData )
                if gameData then
                    game_util:addMoveTips({text = "Mua thành công"})
                    if gameData ~= nil and tolua.type(gameData) == "util_json" then
                        self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                    end
                    self:refreshUi()
                end
            end
            local params = {}
            params.num = btnTag-10000
            params.pos = self.m_select_btnTag-200
            params.number = self.m_tGameData.raiders_reward[self.m_select_btnTag-200][1]
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("raiders_open_raiders"), http_request_method.GET, params,"raiders_open_raiders")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_indiana.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")

    self.m_tips_buy_cost_1 = ccbNode:labelTTFForName("m_tips_buy_cost_1")
    self.m_tips_buy_cost_10 = ccbNode:labelTTFForName("m_tips_buy_cost_10")
    self.m_layer_tips_mask = nil;
    self.m_lab_jifen = ccbNode:labelTTFForName("m_lab_jifen")
    local m_close_btn  = ccbNode:controlButtonForName("m_close_btn")
    local m_btn_gopay = ccbNode:controlButtonForName("m_btn_gopay")
    local m_btn_goshop = ccbNode:controlButtonForName("m_btn_goshop")
    local m_btn_des = ccbNode:controlButtonForName("m_btn_des")
    local m_btn_refresh = ccbNode:controlButtonForName("btn_refresh")
    self.m_btn_gacha_buy_1 = ccbNode:controlButtonForName("m_btn_gacha_buy_1")
    self.m_btn_gacha_buy_10 = ccbNode:controlButtonForName("m_btn_gacha_buy_10")
    self.m_scroll_view_tips = ccbNode:scrollViewForName("m_scroll_view_tips")
    self.m_layer_tips_mask = ccbNode:layerForName("m_layer_tips_mask")
    self.m_node_btn_info = ccbNode:nodeForName("m_node_btn_info")
    self.m_node_tips = ccbNode:nodeForName("m_node_tips")
    self.m_node_time = ccbNode:nodeForName("m_node_time")
    self.m_node_tips:setVisible(false)

    --轮盘商城按钮控制
    if self.buttonState ==0 then 
        game_util:setCCControlButtonTitle(m_btn_goshop,"Thương Thành")  --商店
    else 
        game_util:setCCControlButtonTitle(m_btn_goshop,"Vòng Tích")  --轮盘
    end

    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    m_btn_goshop:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    m_btn_gopay:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    m_btn_des:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    m_btn_refresh:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_btn_gacha_buy_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    self.m_btn_gacha_buy_10:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    self.m_tab_ui = {}
    local m_btn_buy,m_sprite_type,m_lab_mynum,m_node_icon,m_lab_rate,m_node_anim
    for i=1,4 do
        m_btn_buy = ccbNode:controlButtonForName("m_btn_buy" .. i)
        m_btn_buy:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
        m_sprite_type = ccbNode:spriteForName("m_sprite_type" .. i)
        m_lab_mynum = ccbNode:labelTTFForName("m_lab_mynum" .. i)
        m_lab_rate = ccbNode:labelTTFForName("m_lab_rate" .. i)
        m_node_icon = ccbNode:nodeForName("m_node_icon" .. i)
        m_node_anim = ccbNode:nodeForName("m_node_" .. i)
        self.m_tab_ui[i] = {m_node_anim = m_node_anim,m_btn_buy = m_btn_buy,m_sprite_type = m_sprite_type,m_lab_mynum = m_lab_mynum,m_lab_rate = m_lab_rate,m_node_icon = m_node_icon}
        local posX,posY = m_node_icon:getPosition()
    end
    local function onTipsTouch(eventType, x, y)
        if eventType == "began" then
            if not self.m_node_tips:isVisible() then
                return false
            end
            self.m_node_tips:setVisible(false)
            return true;--intercept event
        end
    end
    self.m_layer_tips_mask:registerScriptTouchHandler(onTipsTouch,false,GLOBAL_TOUCH_PRIORITY - 3,true);
    self.m_layer_tips_mask:setTouchEnabled(true);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
function game_indiana_pop.createTimeDown( self,parentNode,time_count_down,shwoType,isclose )
    local function timeEndFunc()
        parentNode:setVisible(false)
        if isclose == "close" then
            self:back()
        end
    end
    parentNode:removeAllChildrenWithCleanup(true)
    local shwoType = shwoType or 3
    local countdownLabel = game_util:createCountdownLabel(time_count_down,timeEndFunc,8, shwoType);
    countdownLabel:setColor(ccc3(74, 249, 69))
    countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    local tempcontent = parentNode:getContentSize()
    countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.6))
    parentNode:addChild(countdownLabel,10,10) 
    -- body
end
function game_indiana_pop.addAnim( self,i )
    local animNode = CCNode:create()
    self.m_tab_ui[i].m_node_anim:addChild(animNode,10,66) 
    self.m_tab_ui[i].m_node_anim:reorderChild(self.m_tab_ui[i].m_node_anim, 16)
    local function sectionEnd( animNode, theId, theLabelName )
        self.m_tab_ui[i].m_node_anim:removeChildByTag(66,true)
        local function responseMethod( tag,gameData )
            if gameData ~= nil and tolua.type(gameData) == "util_json" then
                self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                self:refreshUi()
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("raiders_index"), http_request_method.GET, nil,"raiders_index")
    end    
    local z_zjrAnim = game_util:createAnimEffect("anim_duobaoqibing","anim_duobaoqibing",sectionEnd,nil,true);
    if z_zjrAnim then
        z_zjrAnim:setAnchorPoint(ccp(0.53,0.48));
        game_anim:playSection(z_zjrAnim,"impact")
        animNode:addChild(z_zjrAnim,10,10)
    end
end
function game_indiana_pop.getRewardTab( self )
    local rewardTab,rewardPointTab,rewardCoin = {},{},{}
    local length = game_util:getTableLen(self.m_tGameData.raiders_reward)
    if self.m_raiders_reward_cfg and next(self.m_raiders_reward_cfg) then
        for i=1,length do
            local rewardId = self.m_tGameData.raiders_reward[i][2]
            local reward = self.m_raiders_reward_cfg[tostring(rewardId)]["reward"]
            rewardTab[i] = reward
            rewardPointTab[i] = self.m_raiders_reward_cfg[tostring(rewardId)]["point"]
            rewardCoin[i] = self.m_raiders_reward_cfg[tostring(rewardId)]["cost_coin"]
        end
    end
    return rewardTab,rewardPointTab,rewardCoin
end

--[[--
    刷新ui
]]
function game_indiana_pop.refreshUi(self)
    if self.m_tGameData.open_gift_flash and next(self.m_tGameData.open_gift_flash) then
        local length = game_util:getTableLen(self.m_tGameData.open_gift_flash)
        for i=1,length do
            if self.m_tGameData.open_gift_flash[i] ~= 0 then
                self:addAnim(self.m_tGameData.open_gift_flash[i])
                self.m_tGameData.open_gift_flash[i] = 0
            end
        end
    end
    local exp = 10 
    local rewardTab,rewardPointTab,rewardCoin = self:getRewardTab()
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local function responseMethod( tag,gameData )
            game_scene:addPop("game_indiana_info_pop",{gameData = gameData,reward = rewardTab[btnTag][1]})
            -- body
        end
        local params = {}
        params.pos = btnTag
        params.number = self.m_tGameData.raiders_reward[btnTag][1]
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("raiders_raiders_detail"), http_request_method.GET, params,"raiders_raiders_detail")
    end
    for i=1,4 do
        local mynum = self.m_tGameData.cur_buy_times[tostring(i)] or 0
        local exp = self.m_tGameData.all_input_coin[tostring(i)] or 0
        local allexp = rewardPointTab[i]
        self.m_tab_ui[i].m_lab_mynum:setString(tostring(mynum))
        self.m_tab_ui[i].m_lab_rate:setString(exp .. "/" .. allexp)
        local icon,name,count = game_util:getRewardByItemTable(rewardTab[i][1])
        self.m_tab_ui[i].m_node_icon:removeAllChildrenWithCleanup(true)
        if icon then
            icon:setScale(0.8)
            icon:setAnchorPoint(ccp(0.5,0.6))
            self.m_tab_ui[i].m_node_icon:addChild(icon)
            local button = game_util:createCCControlButton("public_skill.png","",onBtnCilck)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
            button:setAnchorPoint(ccp(0,0))
            button:setZoomOnTouchDown(false)
            button:setOpacity(0)
            button:setScale(0.8)
            button:setTag(i)
            icon:addChild(button)
        end
        if count then
            local itemSize = self.m_tab_ui[i].m_node_icon:getContentSize();
            local tempLabel = game_util:createLabelTTF({text = "x"..count,color = ccc3(255,255,255),fontSize = 10});
            tempLabel:setPosition(ccp(itemSize.width*0.7+12, itemSize.height*0.25-15))
            self.m_tab_ui[i].m_node_icon:addChild(tempLabel)
        end

        -- if exp == allexp then
        --     self:addAnim(i)
        -- end
        local tempSpriteFrame
        if rewardCoin[i] == 1 then 
           self.m_tab_ui[i].m_sprite_type:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_indiana_yi.png"))
        elseif rewardCoin[i] == 10 then
           self.m_tab_ui[i].m_sprite_type:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_indiana_shi.png"))
        elseif rewardCoin[i] == 100 then
           self.m_tab_ui[i].m_sprite_type:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_indiana_bai.png"))
        end
    end
    local tipsStrTab = self.m_tGameData.buy_notice
    game_util:createScrollViewTips(self.m_scroll_view_tips,tipsStrTab,true,3,ccc3(100,200,100))
    local timeDown = self.m_tGameData.remainder_time

    self:createTimeDown(self.m_node_time,timeDown,nil,"close")
    local jifen = self.m_tGameData.score or 0
    self.m_lab_jifen:setString("Tích điểm:" .. jifen)
end
--[[--
    初始化
]]
function game_indiana_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    self.m_raiders_reward_cfg = getConfig(game_config_field.raiders_reward);
    self.m_raiders_reward_cfg = json.decode(self.m_raiders_reward_cfg:getFormatBuffer()) or {}
    self.buttonState=0;

   
    --todo

    local  cfg=getConfig(game_config_field.raiders);

    local cfgCount=cfg:getNodeCount();
    for i=1,cfgCount do 
        local tempCfg=cfg:getNodeAt(i-1);
        cclog2(tempCfg,"tempCfg")
        if tempCfg then
            if tempCfg:getNodeWithKey("button")  and i == self.m_tGameData.version then  --配置里没有version字段
                self.buttonState=tempCfg:getNodeWithKey("button"):toInt();
                cclog2(self.buttonState,"buttonState")
            end
        end
    end
    
    
end
--[[--
    创建ui入口并初始化数据
]]
function game_indiana_pop.create(self,t_params)
    self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi();

    return  m_popUi;
end
return game_indiana_pop;