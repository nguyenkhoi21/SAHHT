---  组队boss商店
local game_team_boss_shop = {
    m_tGameData = nil,
    m_list_view_bg = nil,
    m_title_label = nil,
    m_num_label = nil,
    m_curPage = nil,
    m_shopItemIdTab = nil,
    buy_max_count = nil,
    already_count = nil,
    m_root_layer = nil,
    m_moveFlag = nil,

    other_node = nil,--4合1
    m_openType = nil,
};

--[[--
    销毁ui
]]
function game_team_boss_shop.destroy(self)
    -- body
    cclog("-----------------game_team_boss_shop destroy-----------------");
    self.m_tGameData = nil;
    self.m_list_view_bg = nil;
    self.m_title_label = nil;
    self.m_num_label = nil;
    self.m_curPage = nil;
    self.m_shopItemIdTab = nil;
    self.buy_max_count = nil;
    self.already_count = nil;
    self.m_root_layer = nil;
    self.m_moveFlag = nil;

    self.other_node = nil;
    self.m_openType = nil;
end
--[[--
    返回
]]
function game_team_boss_shop.back(self,backType)
    game_scene:enterGameUi("game_main_scene");
end
--[[--
    读取ccbi创建ui
]]
function game_team_boss_shop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 102 then
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_shop3.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_num_label = ccbNode:labelTTFForName("m_num_label")
    self.other_node = ccbNode:nodeForName("other_node")
    self.money_icon = ccbNode:spriteForName("money_icon")
    self.money_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_icon_crown.png"))
    self.buy_max_count = 10;
    self.already_count = 1;
    local touchBeginPoint = nil;
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self.m_moveFlag = false;
            touchBeginPoint = {x = x, y = y}
            return true;--intercept event
        elseif eventType == "moved" then
            if ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 then
                self.m_moveFlag = true;
            end
        end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建购买道具列表
]]
function game_team_boss_shop.createTableView(self,viewSize)    
    local shopCfg = getConfig(game_config_field.team_boss_exchange);

    local function onMainBtnClick(target,event)
        if self.m_moveFlag == false and event == 32 then
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();

            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
                self:refreshUi()
            end
            local params = {};
            params.sort = btnTag
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_per_point_exchange"), http_request_method.GET, params,"team_boss_per_point_exchange")
        end
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 3; --列
    -- params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = shopCfg:getNodeCount();
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_buy_item_list_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            local cd_node = ccbNode:nodeForName("cd_node")
            cd_node:setVisible(false)
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_buy_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY+1);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
            m_buy_btn:setTag(index + 1);
            local itemCfg = shopCfg:getNodeWithKey(tostring(index + 1))

            local m_node = ccbNode:nodeForName("m_node");
            m_node:removeAllChildrenWithCleanup(true);
            local m_cost_label = ccbNode:labelBMFontForName("m_cost_label")
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            local m_limit_label = ccbNode:labelBMFontForName("m_limit_label")

            local cost = itemCfg:getNodeWithKey("cost"):toInt()
            local limits = itemCfg:getNodeWithKey("limits"):toInt()
            local reward = itemCfg:getNodeWithKey("reward"):getNodeAt(0)
            
            local icon,name,count = game_util:getRewardByItem(reward)
            if icon then
                icon:setScale(0.9)
                m_node:addChild(icon,10)
            end

            --去兑换记录
            -- local flag = game_util:idInTableById((index+1),self.m_tGameData.exchange_reward)
            -- if flag then

            -- end
            local buyTimes = 0
            if self.m_tGameData.exchange_reward[tostring(index+1)] then
                buyTimes = self.m_tGameData.exchange_reward[tostring(index+1)]
            else
                buyTimes = 0
            end

            m_name_label:setString(name .. "(" .. (limits - buyTimes) .. ")")
            if limits == -1 then
                m_name_label:setString(name)
            end
            m_cost_label:setString(cost)

            m_limit_label:setString("×" .. count)

            local m_cost_icon_spr = ccbNode:spriteForName("m_cost_icon_spr")
            m_cost_icon_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_icon_crown.png"))
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local itemCfg = shopCfg:getNodeWithKey(tostring(index + 1))
            local reward = json.decode(itemCfg:getNodeWithKey("reward"):getNodeAt(0):getFormatBuffer())
            cclog2(reward,"reward")
            game_util:lookItemDetal(reward)
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新ui
]]
function game_team_boss_shop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tableViewTemp);
    self.m_num_label:setString(tostring(self.m_tGameData.per_point or 0));
end

--[[--
    初始化
]]
function game_team_boss_shop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
    end
    self.m_tGameData = self.m_tGameData or {};

    self.m_moveFlag = false;
    self.m_openType = t_params.openType or ""
end

--[[--
    创建ui入口并初始化数据
]]
function game_team_boss_shop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_team_boss_shop;