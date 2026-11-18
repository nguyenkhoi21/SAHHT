
local game_monopoly_reward_server_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_reward_node = nil,
    m_richman_shop = nil,
    m_openType = nil,
    current_count = nil,
    btn_use1 = nil,
    m_id_tab = nil,
    goods_info_label = nil,
    title_label  = nil,
    m_sprite_cost = nil,
    m_label_refresh_cost = nil,
    m_time_node = nil,
    m_rewarddes_lab = nil,
    m_need_value = nil,
    m_tGameData = nil,

};

--[[--
    销毁
]]
function game_monopoly_reward_server_pop.destroy(self)
    cclog("-----------------game_monopoly_reward_server_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_reward_node = nil;
    self.m_richman_shop = nil;
    self.m_openType = nil;
    self.current_count = nil;
    self.btn_use1 = nil;
    self.m_id_tab = nil;
    self.goods_info_label = nil;
    self.title_label  = nil;
    self.m_sprite_cost = nil;
    self.m_label_refresh_cost = nil;
    self.m_time_node = nil;
    self.m_rewarddes_lab = nil;
    self.m_tGameData = nil;
    self.m_need_value = nil;
end
--[[--
    返回
]]
function game_monopoly_reward_server_pop.back(self)
    game_scene:removePopByName("game_monopoly_reward_server_pop");
    local function responseMethod(tag,gameData)
        game_scene:addPop("game_monopoly_server_pop",{gameData = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_super_tycoon_active_index"), http_request_method.GET, nil,"server_super_tycoon_active_index")
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_monopoly_reward_server_pop.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/monopoly.plist");
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then
            self:back();
        elseif btnTag == 106 then
            local tempId = self.m_id_tab[self.m_openType-200]
            
            local shop_type,goods_id
            if self.m_openType == 205 then
                local function responseMethod(tag,gameData)
                    self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                    local reward = self.m_tGameData.rewards or {}
                    game_util:rewardTipsByDataTable(reward)
                    game_util:setCCControlButtonTitle(self.btn_use1, "Đã mua")
                    self.btn_use1:setTouchEnabled(false)
                end
                shop_type = 2
                goods_id = self.m_tGameData.limit_shop_goods[1]
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_super_tycoon_active_buy"), http_request_method.GET, {shop_type = shop_type,goods_id = goods_id},"server_super_tycoon_active_buy")
            else
                local function responseMethod(tag,gameData)
                    self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                    local reward = self.m_tGameData.rewards or {}
                    game_util:rewardTipsByDataTable(reward)
                    game_util:setCCControlButtonTitle(self.btn_use1, "Đã nhận")
                    self.btn_use1:setTouchEnabled(false)
                end
                local round = self.m_need_value
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_super_tycoon_active_round_reward"), http_request_method.GET, {round = round},"server_super_tycoon_active_round_reward")
            end 
        end
    end
    local ccbNode = luaCCBNode:create();
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_reward_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local m_bg_sp1 = ccbNode:spriteForName("m_bg_sp1")
    local m_bg_sp2 = ccbNode:scale9SpriteForName("m_bg_sp2")
    local m_kuang_sp = ccbNode:scale9SpriteForName("m_kuang_sp")
    m_bg_sp1:setVisible(false)
    m_bg_sp2:setVisible(true)
    m_kuang_sp:setVisible(true)
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    self.title_label = ccbNode:labelTTFForName("title_label")
    local goods_alpha_back =  ccbNode:scale9SpriteForName("goods_alpha_back")
    self.goods_info_label = ccbNode:labelTTFForName("goods_info_label")
    self.m_rewarddes_lab= ccbNode:labelTTFForName("m_rewarddes_lab")
    self.btn_use1 = ccbNode:controlButtonForName("btn_use1")
    local btn_use = ccbNode:controlButtonForName("btn_use")
    local icon_node = ccbNode:nodeForName("icon_node")
    self.m_time_node = ccbNode:nodeForName("m_time_node")
    self.m_reward_node = ccbNode:nodeForName("m_reward_node")
    self.m_sprite_cost = ccbNode:spriteForName("m_sprite_cost")
    self.m_label_refresh_cost = ccbNode:labelTTFForName("m_label_refresh_cost")
    icon_node:setVisible(false)
    game_util:setCCControlButtonBackground(self.btn_use1,"monopoly_button.png")
    self.btn_use1:setPreferredSize(CCSizeMake(59,26.5))
    self.btn_use1:setVisible(true)
    btn_use:setVisible(false)
    self.btn_use1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    game_util:setCCControlButtonTitle(self.btn_use1, "Nhận")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
function game_monopoly_reward_server_pop.createReward( self )
    local tempTab = {}
    self.m_id_tab = {}
    local rewardTab
    if self.m_openType == 205 then
        self.title_label:setVisible(false)
        self.m_sprite_cost:setVisible(true)
        game_util:setCCControlButtonTitle(self.btn_use1, "Mua")
        if self.m_tGameData.limit_shop_goods and next(self.m_tGameData.limit_shop_goods) then
            local need_value = self.m_richman_shop[tostring(self.m_tGameData.limit_shop_goods[1])].need_value
            self.m_label_refresh_cost:setString(tostring(need_value))
            self:createTimeDown(self.m_time_node,self.m_tGameData.shop_open_count)
            rewardTab = self.m_richman_shop[tostring(self.m_tGameData.limit_shop_goods[1])].shop_reward
        else
            game_util:setCCControlButtonTitle(self.btn_use1, "Ko thể mua")
            self.btn_use1:setTouchEnabled(false)
        end
    else
        self.m_rewarddes_lab:setString("Đạt số vòng chỉ định sẽ có quà")
        self.title_label:setString("Quà")
        for k,v in pairs( self.m_richman_shop) do
            if v.value_sorts == 3 then
                table.insert(tempTab,v)
                table.insert(self.m_id_tab,k)
            end
        end
        local function sortFunc( v1,v2 )
            return v1.need_value < v2.need_value
        end
        table.sort(tempTab,sortFunc) 
        self.m_need_value = tempTab[self.m_openType-200].need_value

        if self.current_count < tempTab[self.m_openType-200].need_value then
            game_util:setCCControlButtonTitle(self.btn_use1, "Ko thể nhận")
            self.btn_use1:setTouchEnabled(false)
            self.m_rewarddes_lab:setVisible(true)
            self.btn_use1:setVisible(false)

        else
            self.m_rewarddes_lab:setVisible(false)
            self.btn_use1:setVisible(true)
            for k,v in pairs(self.m_tGameData.round_rewarded) do
                if tempTab[self.m_openType-200].need_value == v then
                    game_util:setCCControlButtonTitle(self.btn_use1, "Đã nhận")
                    self.btn_use1:setTouchEnabled(false)
                end
            end
            

        end
        rewardTab = tempTab[self.m_openType-200].shop_reward
    end
    self.m_reward_node:removeAllChildrenWithCleanup(true)
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        game_util:lookItemDetal(rewardTab[btnTag])
    end
    local size = self.m_reward_node:getContentSize()
    
    local reward_num = game_util:getTableLen(rewardTab)
    local x = math.ceil(reward_num/2) -- 判断总数是奇数偶数 来决定icon的位置
    local y = reward_num%2
    local width = size.width/reward_num
    for i=1,reward_num do
        local reward = rewardTab[i]
        local icon,name,count = game_util:getRewardByItemTable(reward)
        if icon then
            icon:setScale(1)
            icon:setAnchorPoint(ccp(0.5,0.5))
            if y == 0 then
                icon:setPosition(width/2+(i-1)*size.width/reward_num ,30)
            elseif y == 1 then
                icon:setPosition(size.width/2 + (i-x)*width,30)
            end
            self.m_reward_node:addChild(icon)
            self.goods_info_label:setString(name .. "x" .. count)
            local button = game_util:createCCControlButton("public_skill.png","",onBtnCilck)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
            button:setAnchorPoint(ccp(0,0))
            button:setZoomOnTouchDown(false)
            button:setOpacity(0)
            button:setScale(0.8)
            button:setTag(i)
            icon:addChild(button)
        end
    end
end
function game_monopoly_reward_server_pop.createTimeDown( self,parentNode,time_count_down )
    local function timeEndFunc()
        local function responseMethod(tag,gameData)
           game_scene:addPop("game_monopoly_server_pop",{gameData = gameData});
           game_scene:removePopByName("game_monopoly_reward_server_pop")
       end
       network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_super_tycoon_active_index"), http_request_method.GET, nil,"server_super_tycoon_active_index")
    end
    parentNode:removeAllChildrenWithCleanup(true)
    local countdownLabel = game_util:createCountdownLabel(time_count_down,timeEndFunc,8,1);
    countdownLabel:setColor(ccc3(255, 255, 255))
    countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    local tempcontent = parentNode:getContentSize()
    countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.6))
    parentNode:addChild(countdownLabel,10,10) 
end
--[[--
    刷新ui
]]
function game_monopoly_reward_server_pop.refreshUi(self)
    self:createReward()
end
--[[--
    初始化
]]
function game_monopoly_reward_server_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_openType = t_params.openType
    self.current_count = t_params.count
    self.m_tGameData = t_params.gameData
    self.m_richman_shop =  json.decode(getConfig(game_config_field.server_richman_shop):getFormatBuffer())
end
--[[--
    创建ui入口并初始化数据
]]
function game_monopoly_reward_server_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_monopoly_reward_server_pop;