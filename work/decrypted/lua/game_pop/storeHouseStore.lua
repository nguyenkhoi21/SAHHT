--- 商店弹板

local storeHouseStore = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,
    m_goods_sprite = nil,
    m_goods_info_label = nil,
    m_goods_alpha_back = nil,
    m_price_label = nil,
    m_price_alpha_back = nil,
    m_number_label = nil,

    m_count_value = nil,
    m_max_count = nil,

    m_btn_use = nil,
    m_btn_add = nil,
    m_btn_add10 = nil,
    m_btn_minute = nil,
    m_btn_min10 = nil,
    m_close_btn = nil,
    m_icon_node = nil,
    m_money_sprite = nil,
    m_title_spr = nil,
    enterType = nil,
};
--[[--
    销毁
]]
function storeHouseStore.destroy(self)
    -- body
    cclog("-----------------storeHouseStore destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;
    self.m_goods_sprite = nil;
    self.m_goods_info_label = nil;
    self.m_goods_alpha_back = nil;
    self.m_price_label = nil;
    self.m_price_alpha_back = nil;
    self.m_number_label = nil;
    self.m_count_value = nil;
    self.m_max_count = nil;

    self.m_btn_use = nil;
    self.m_btn_add = nil;
    self.m_btn_add10 = nil;
    self.m_btn_minute = nil;
    self.m_btn_min10 = nil;
    self.m_close_btn = nil;
    self.m_icon_node = nil;
    self.m_money_sprite = nil;
    self.m_title_spr = nil;
    self.enterType = nil;
end
--[[--
    返回
]]
function storeHouseStore.back(self,type)
    if self.enterType and self.enterType == "game_worldTree_reward_pop" then
        local function responseMethod(tag,gameData)
            game_scene:addPop("game_worldTree_reward_pop",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_tree_index"), http_request_method.GET, nil,"world_tree_index")
    end
    game_scene:removePopByName("storeHouseStore");

end
--[[
    修改个数和钻石    从竞技场进来，使用的是竞技点
]]--
function storeHouseStore.setCountAndMoney(self,addCount)
    if self.m_count_value + addCount <= self.m_max_count and self.m_count_value + addCount > 0 then
        self.m_count_value = self.m_count_value + addCount;
    elseif self.m_count_value + addCount > self.m_max_count then
        self.m_count_value = self.m_max_count;
    elseif self.m_count_value + addCount < 1 then
        self.m_count_value = 1;
    end
    local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(self.m_tParams.shopItemId));
    config_date = json.decode(config_date:getFormatBuffer())
    if self.m_count_value >= config_date.stack then
        self.m_count_value = config_date.stack
    end
    self.m_number_label:setString(tostring(self.m_count_value));
end
--[[--
    读取ccbi创建ui
]]
function storeHouseStore.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/storeHouse.plist");

    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then--关闭
            self:back();
        elseif btnTag == 101 then--  +
            self:setCountAndMoney(1)
        elseif btnTag == 102 then--  -
            self:setCountAndMoney(-1)
        elseif btnTag == 103 then--  +10
            self:setCountAndMoney(10)
        elseif btnTag == 104 then--  -10
            self:setCountAndMoney(-10)
        elseif btnTag == 105 then--  购买
            if self.enterType and self.enterType == "storeHouse_save" then
                cclog("[storeHouse] 点击道具存入")
                local function responseMethod(tag,gameData)
                    self.m_tParams.okBtnCallBack(self.m_count_value)
                    self:back()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("storehouse_store_item"), http_request_method.GET,{item_id = self.m_tParams.shopItemId, num = self.m_count_value},"storehouse_store_item")
            elseif self.enterType and self.enterType == "storeHouse_get" then
                cclog("[storeHouse] 点击道具取出")
                local function responseMethod(tag,gameData)
                    self.m_tParams.okBtnCallBack(self.m_count_value)
                    self:back()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("storehouse_del_item"), http_request_method.GET,{item_id = self.m_tParams.shopItemId, num = self.m_count_value},"storehouse_del_item")
            else
                self.m_tParams.okBtnCallBack(self.m_count_value)
                self:back()
            end
        elseif btnTag == 106 then --放包里
            local params = {}
            -- local str = self:getArgs()
            params.rewards =  self.m_tParams.itemid .. "_" .. self.m_count_value .. "_" .. "-1"
            params.rewards_type = 1
            local function responseMethod(tag,gameData)
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local data  = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                    local reward = data.request_rewards
                    game_util:rewardTipsByDataTable(reward);
                end
                self:back()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_tree_reward"), http_request_method.GET, params,"world_tree_reward")
        elseif btnTag == 107 then --转换积分
            local params = {}
            -- local str = self:getArgs()
            params.rewards = self.m_tParams.itemid .. "_" .. self.m_count_value .. "_" .. "-1"
            params.rewards_type = 2
            local function responseMethod(tag,gameData)
               if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local data  = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                    local reward_point = data.reward_point or 0
                    game_util:addMoveTips({text = "获得" .. reward_point .. "积分"})
                    self:back()
               end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_tree_reward"), http_request_method.GET, params,"world_tree_reward")
        elseif btnTag == 108 then  --+ max
            self:setCountAndMoney(self.m_max_count)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_use_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.m_icon_node = ccbNode:nodeForName("icon_node");
    self.m_goods_sprite = ccbNode:spriteForName("goods_sprite");
    self.m_goods_info_label = ccbNode:labelTTFForName("goods_info_label");
    self.m_goods_alpha_back = ccbNode:spriteForName("goods_alpha_back");
    -- self.m_price_label = ccbNode:labelBMFontForName("price_label");
    self.m_price_alpha_back = ccbNode:spriteForName("price_alpha_back");
    self.m_number_label = ccbNode:labelBMFontForName("number_label");

    self.m_btn_use = ccbNode:controlButtonForName("btn_use");
    self.m_btn_add = ccbNode:controlButtonForName("btn_add");
    self.m_btn_minute = ccbNode:controlButtonForName("btn_minute");
    self.m_btn_min10 = ccbNode:controlButtonForName("btn_min10");
    self.m_btn_add10 = ccbNode:controlButtonForName("btn_add10");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    local btn_add_max = ccbNode:controlButtonForName("btn_add_max")
    -- self.m_money_sprite = ccbNode:spriteForName("money_sprite");
    self.m_title_spr = ccbNode:spriteForName("m_title_spr");
    if self.enterType and self.enterType == "storeHouse_save" then
        self.m_title_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("storeHouse_5.png"))
    elseif self.enterType and self.enterType == "storeHouse_get" then
        self.m_title_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("storeHouse_3.png"))
    end

    self.m_btn_use:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 999);
    self.m_btn_add:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 999);
    self.m_btn_minute:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 999);
    self.m_btn_min10:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 999);
    self.m_btn_add10:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 999);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 999);
    btn_add_max:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 999)

    
    game_util:setControlButtonTitleBMFont(self.m_btn_add10);
    game_util:setControlButtonTitleBMFont(self.m_btn_min10);
    game_util:setControlButtonTitleBMFont(self.m_btn_add);
    game_util:setControlButtonTitleBMFont(self.m_btn_minute);
    game_util:setControlButtonTitleBMFont(self.m_btn_use);
    game_util:setControlButtonTitleBMFont(btn_add_max);

    self:setCountAndMoney(0);
    local icon,name,count
    if self.enterType and self.enterType == "game_worldTree_reward_pop" then
        icon,name,count = game_util:getRewardByItemTable(self.m_tParams.shopItemId)
        self.m_btn_use:setVisible(false)
    else 
        self.m_btn_use:setVisible(true)  
        icon,name,count = game_util:getItemRewardId(self.m_tParams.shopItemId,1)
    end
    if icon then
        icon:setAnchorPoint(ccp(0.5,0.5));
        local iconSize = self.m_goods_sprite:getContentSize();
        icon:setPosition(ccp(iconSize.width*0.5,iconSize.height*0.5))
        self.m_goods_sprite:addChild(icon,10);
    end
    if name then
        self.m_goods_info_label:setString(name)
    end
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    if self.m_tParams.falg == "show" then
        btn_add_max:setVisible(true)
    else
        btn_add_max:setVisible(false)
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 998,true);
    self.m_root_layer:setTouchEnabled(true);

    if self.enterType and self.enterType == "storeHouse_save" then
        game_util:setCCControlButtonTitle(self.m_btn_use, "Cất vào thành công!");
    elseif self.enterType and self.enterType == "storeHouse_get" then
        game_util:setCCControlButtonTitle(self.m_btn_use, "Lấy ra");
    end
    return ccbNode;
end
--[[--
    刷新ui
]]
function storeHouseStore.refreshUi(self)
    
end
--[[--
    初始化
]]
function storeHouseStore.init(self,t_params)
    self.m_tParams = t_params or {};
    self.m_tParams.m_showType = t_params.showType or 1;
end
--[[--
    创建ui入口并初始化数据
]]
function storeHouseStore.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.enterType = t_params.enterType
    cclog2(self.enterType,"self.enterType ===")
    self.m_count_value = 1;
    if self.m_tParams.maxCount <= 0 then -- 不限次数  设置默认最大值 9999
        self.m_tParams.maxCount = 99;
        self.m_tParams.alreadyCount = 0;
    end
    self.m_max_count = self.m_tParams.maxCount;
    -- cclog("shopItemId == "..self.m_tParams.shopItemId);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function storeHouseStore.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return storeHouseStore;