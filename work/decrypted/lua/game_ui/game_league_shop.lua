---  巅峰联赛商店
local game_league_shop = {
    m_tGameData = nil,
    m_list_view_bg = nil,
    m_num_label = nil,
    m_curPage = nil,
    m_root_layer = nil,
    m_moveFlag = nil,
    money_icon = nil,
};

--[[--
    销毁ui
]]
function game_league_shop.destroy(self)
    -- body
    cclog("-----------------game_league_shop destroy-----------------");
    self.m_tGameData = nil;
    self.m_list_view_bg = nil;
    self.m_num_label = nil;
    self.m_curPage = nil;
    self.m_root_layer = nil;
    self.m_moveFlag = nil;
    self.money_icon = nil;
end
--[[--
    返回
]]
function game_league_shop.back(self,backType)
    -- game_scene:enterGameUi("game_main_scene");
    if self.enterType == "game_league_signup" then
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local stage = data:getNodeWithKey("stage")
            if stage then
                stage = stage:toInt()
            end
            if stage == 2 then 
                game_util:addMoveTips({text = "Đang tự động chia nhóm, vui lòng đợi!"}) --正在自动分组，请稍后！
            elseif stage == 4 then
                game_util:addMoveTips({text = "Đang kết toán, vui lòng đợi!"}) --正在结算，请稍后！
            else
                game_scene:enterGameUi("game_league_signup",{gameData = gameData})
                self:destroy()
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_index"), http_request_method.GET, nil,"world_one_index")
    else
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_league_main",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_enter_game"), http_request_method.GET, nil,"world_one_enter_game")
    end
end
--[[--
    读取ccbi创建ui
]]
function game_league_shop.createUi(self)
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
                --game_scene:addPop("ui_vip_show_pop")
                --self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_shop3.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_num_label = ccbNode:labelTTFForName("m_num_label")
    self.money_icon = ccbNode:spriteForName("money_icon")
    self.money_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_league.png"))
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
function game_league_shop.createTableView(self,viewSize)    
    local showData = self.m_shopData
    local itemsCount = #showData
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local level = game_data:getUserStatusDataByKey("level") or 1;
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag == " .. btnTag) 
        local index = btnTag-101
        -- local gameShop = arenaShopConfig:getNodeAt(index)
        local  gameShop = showData[index + 1]
        local up_limit = gameShop:getNodeWithKey("show_level"):getNodeAt(1):toInt()
        local down_limit = gameShop:getNodeWithKey("show_level"):getNodeAt(0):toInt()
        if level >= down_limit and level <= up_limit then
            if(self.m_tGameData.integration<=0)then
                game_util:addMoveTips({text = "Công huân không đủ!"}); --您的联赛功勋不足，无法兑换
                return;
            end
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                cclog("------buy----\n" .. data:getFormatBuffer());
                -- self.m_tGameData.integration = data:getNodeWithKey("point"):toInt();
                game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                self:refreshUi()
            end
            local params = {};
            params.sort = gameShop:getKey()
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_exchange_exchange"), http_request_method.GET, params,"world_one_exchange_exchange")
        else
            game_util:addMoveTips({text = "Cấp của bạn không thể mua!"}); --您的等级不能购买
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.showPoint = false;
    params.totalItem = totalItem;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_pk_buy_pop_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            ccbNode:controlButtonForName("m_buy_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < itemsCount then
                m_spr_bg_up:setVisible(false);
                local iCountText = tolua.cast(ccbNode:objectForName("m_count"),"CCLabelBMFont");
                local iIconNode = tolua.cast(ccbNode:objectForName("m_icon"),"CCLayer");
                local m_limit_label = tolua.cast(ccbNode:objectForName("m_limit_label"),"CCLabelBMFont");
                local m_name_label = tolua.cast(ccbNode:objectForName("m_name_label"),"CCLabelBMFont");
                local btn_buy = tolua.cast(ccbNode:objectForName("m_buy_btn"),"CCControlButton")
                local cd_node = ccbNode:nodeForName("cd_node")
                local m_cdTime = ccbNode:labelTTFForName("m_cdTime")
                local cd_node_2 = ccbNode:nodeForName("cd_node_2")
                local show_icon = ccbNode:spriteForName("show_icon")
                show_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_league.png"))
                m_name_label:setString("");

                local gameShop = showData[index + 1]
                -- cclog("gameShop == " .. gameShop:getFormatBuffer())
                local times = gameShop:getNodeWithKey("times"):toInt();
                
                local up_limit = gameShop:getNodeWithKey("show_level"):getNodeAt(1):toInt()
                local down_limit = gameShop:getNodeWithKey("show_level"):getNodeAt(0):toInt()

                local shop_reward = gameShop:getNodeWithKey("reward")
                iIconNode:removeAllChildrenWithCleanup(true);

                cd_node:setVisible(false)
                cd_node_2:setVisible(false)
                if shop_reward:getNodeCount() > 0 then
                    local icon,name,count = game_util:getRewardByItem(shop_reward:getNodeAt(0));
                    if icon then
                        local size = iIconNode:getContentSize();
                        icon:setPosition(ccp(size.width/2,size.height/2));
                        iIconNode:addChild(icon);
                    end
                    if name then
                        m_name_label:setString(name);
                        if times == -1 then
                            -- m_limit_label:setString("不限次");
                        else
                            local exchange_log_item = self.m_tGameData.exchange_reward[gameShop:getKey()]
                            cclog2(exchange_log_item,"exchange_log_item")
                            if exchange_log_item then
                                -- m_limit_label:setString("兑换限制：" .. exchange_log_item.times .. "/" .. times);
                                m_name_label:setString(name .. "(" .. (times-exchange_log_item) .. ")")

                                if (times-exchange_log_item) == 0 then
                                    local refresh = gameShop:getNodeWithKey("refresh"):toInt()
                                    if refresh == 1 then--每天刷新
                                        cd_node:setVisible(true)
                                        m_cdTime:setString("Ngày mai 00:00 tạo mới") --明日0:00刷新
                                        cd_node_2:setVisible(false)
                                    elseif refresh == 0 then--只能买一次
                                        cd_node:setVisible(false)
                                        cd_node_2:setVisible(true)
                                    else
                                        cd_node:setVisible(false)
                                        cd_node_2:setVisible(false)
                                    end
                                else
                                    cd_node:setVisible(false)
                                    cd_node_2:setVisible(false)
                                end
                            else
                                -- m_limit_label:setString("兑换限制：" .. "0/" .. times);
                                m_name_label:setString(name .. "(" .. times .. ")")
                            end
                        end
                    end
                    if count > 1 then
                        m_limit_label:setString("×" .. count)
                    else
                        m_limit_label:setString("") 
                    end
                end
                if level < down_limit or level > up_limit then
                    m_name_label:setString("lv." .. down_limit .. "~" .. "lv." .. up_limit .. "Có hiệu quả"); --有效
                end
                iCountText:setString(gameShop:getNodeWithKey("cost"):toInt());
                btn_buy:setTag(101 + index)
            else
                m_spr_bg_up:setVisible(true);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local itemCfg = showData[index + 1]
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
function game_league_shop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tableViewTemp);
    self.m_num_label:setString(tostring(self.m_tGameData.integration or 0));
end

--[[--
    初始化
]]
function game_league_shop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
    end
    self.m_tGameData = self.m_tGameData or {};

    self.m_moveFlag = false;
    self:formatShopData()
    self.enterType = t_params.enterType
end
function game_league_shop.formatShopData( self )
    self.m_shopData = {}
    local league_exchange = getConfig(game_config_field.league_exchange);
    local level = game_data:getUserStatusDataByKey("level") or 1;
    local itemsCount = league_exchange:getNodeCount()
    for i=1, itemsCount do
        local itemData = league_exchange:getNodeAt( i - 1)
        if itemData then
            local up_limit = itemData:getNodeWithKey("show_level") and itemData:getNodeWithKey("show_level"):getNodeAt(1):toInt() or nil
            local down_limit = itemData:getNodeWithKey("show_level") and itemData:getNodeWithKey("show_level"):getNodeAt(0):toInt() or nil
            if up_limit == nil or down_limit == nil then
                table.insert(self.m_shopData, itemData)
            elseif level <= up_limit and level >= down_limit then
                table.insert(self.m_shopData, itemData)
            else
                cclog2(itemData, "this item can not show because level limit  ===  ")
            end
        end
    end
    if luaCCBNode.addPublicResource then
        luaCCBNode:addPublicResource("ccbResources/public_res_add.plist");
    end

end
--[[--
    创建ui入口并初始化数据
]]
function game_league_shop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_league_shop;