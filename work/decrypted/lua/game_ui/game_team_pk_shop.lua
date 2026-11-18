---  组队pk商店
local game_team_pk_shop = {
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
    money_icon = nil,
    m_zhengba_btn = nil,
    m_fenzheng_btn = nil,
    m_jingji_btn = nil,
    m_node_top_diamond = nil,
    m_fenzheng_exchange = nil,
};

--[[--
    销毁ui
]]
function game_team_pk_shop.destroy(self)
    -- body
    cclog("-----------------game_team_pk_shop destroy-----------------");
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
    self.money_icon = nil;
    self.m_zhengba_btn = nil;
    self.m_fenzheng_btn = nil;
    self.m_jingji_btn = nil;
    self.m_node_top_diamond = nil;
    self.m_fenzheng_exchange = nil;
end
--[[--
    返回
]]
function game_team_pk_shop.back(self,backType)
    -- game_scene:enterGameUi("game_main_scene");
    game_scene:setVisibleBroadcastNode(false);
    -- local association_id = game_data:getUserStatusDataByKey("association_id");
    -- if association_id == 0 then
    --     require("like_oo.oo_controlBase"):openView("guild_join");
    -- else
    --     require("like_oo.oo_controlBase"):openView("guild");
    -- end
    if self.m_openType == "godfield_main" then
        local function responseMethod( tag,gameData )
             local data = gameData:getNodeWithKey("data");
                 data = json.decode(data:getFormatBuffer()) or {};
                 game_scene:enterGameUi("game_godfield_main",{gameData = gameData})
             end
         network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")
    elseif self.m_openType == "game_godfield_pvp_shop" then
        local function responseMethod( tag,gameData )
            game_scene:enterGameUi("game_godfield_pvp",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_arena"), http_request_method.GET, {},"god_arena")
    elseif self.m_openType == "godfield_arean" then
        local function  responseMethod( tag,gameData )
            game_scene:enterGameUi("game_godfield_arean",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")--周一到周五的界面
    elseif self.m_openType == "godfield_fenzheng" then 
        local function responseMethod( tag,gameData )
                game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, {},"team_pk_new_index")
    else
        local function responseMethod( tag,gameData )
                game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, {},"team_pk_new_index")
    end
end
--[[--
    读取ccbi创建ui
]]
function game_team_pk_shop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 101 then
            local function responseMethod( tag,gameData )
                -- if self.m_openType ~= nil then
                    game_scene:enterGameUi("game_godfield_shop",{gameData = gameData,openType = self.m_openType});
                -- end
            end
           network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_exchange_index"), http_request_method.GET, nil,"god_field_exchange_index")
        elseif btnTag == 102 then
            local function responseMethod( tag,gameData )
                -- if self.m_openType ~= nil then
                    game_scene:enterGameUi("game_godfield_pvp_shop",{gameData = gameData,openType = self.m_openType});  
                -- end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_arena_shop_index"), http_request_method.GET, params,"god_arena_shop_index")
        end
    end
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_team_pk.plist");
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_shop.ccbi");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_num_label = ccbNode:labelTTFForName("m_num_label")
    self.m_node_top_diamond = ccbNode:nodeForName("m_node_top_diamond");
    self.m_node_top_diamond:setVisible(false)
    self.m_zhengba_btn = ccbNode:controlButtonForName("m_zhengba_btn")
    self.m_fenzheng_btn = ccbNode:controlButtonForName("m_fenzheng_btn");
    self.m_jingji_btn = ccbNode:controlButtonForName("m_jingji_btn");
    self.m_fenzheng_exchange = ccbNode:nodeForName("m_fenzheng_exchange");
    self.m_fenzheng_exchange:setVisible(true)
    self.m_jingji_btn:setColor(ccc3(100,100,100))
    self.m_zhengba_btn:setColor(ccc3(100,100,100))
    self.m_fenzheng_btn:setTouchEnabled(false)
    -- self.other_node = ccbNode:nodeForName("other_node")
    self.money_icon = ccbNode:spriteForName("money_icon")
    self.money_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("teampk_icon.png"))
    self.money_icon:setScale(1.2)
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
function game_team_pk_shop.createTableView(self,viewSize)    
    local shopCfg = getConfig(game_config_field.team_pk_exchange);

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
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_exchange"), http_request_method.GET, params,"team_pk_exchange")
        end
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
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
            ccbNode:openCCBFile("ccb/ui_godfield_buy_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
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
            local times = itemCfg:getNodeWithKey("times"):toInt()
            local reward = itemCfg:getNodeWithKey("reward"):getNodeAt(0)
            
            local icon,name,count = game_util:getRewardByItem(reward)
            if icon then
                icon:setScale(0.9)
                m_node:addChild(icon,10)
            end

            local buyTimes = 0
            -- if self.m_tGameData.exchange_reward[tostring(index+1)] then
            --     buyTimes = self.m_tGameData.exchange_reward[tostring(index+1)]
            -- else
            --     buyTimes = 0
            -- end

            m_name_label:setString(name .. "(" .. (times - buyTimes) .. ")")
            if times == -1 then
                m_name_label:setString(name)
            end
            m_cost_label:setString(cost)

            m_limit_label:setString("×" .. count)

            local m_cost_icon_spr = ccbNode:spriteForName("m_cost_icon_spr")
            m_cost_icon_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("teampk_icon.png"))
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local itemCfg = shopCfg:getNodeWithKey(tostring(index + 1))
            local reward = json.decode(itemCfg:getNodeWithKey("reward"):getNodeAt(0):getFormatBuffer())
            -- cclog2(reward,"reward")
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
function game_team_pk_shop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tableViewTemp);
    self.m_num_label:setString(tostring(self.m_tGameData.pk_score or 0));
end

--[[--
    初始化
]]
function game_team_pk_shop.init(self,t_params)
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
function game_team_pk_shop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_team_pk_shop;