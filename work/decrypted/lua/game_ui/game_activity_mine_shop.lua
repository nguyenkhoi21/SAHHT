---  挖矿商城

local game_activity_mine_shop = {
    m_tGameData = nil,
    m_moveFlag = nil,
    m_curPage = nil,
    m_list_view_bg = nil,
    m_num_label = nil,
};
--[[--
    销毁ui
]]
function game_activity_mine_shop.destroy(self)
    -- body
    cclog("-----------------game_activity_mine_shop destroy-----------------");
    self.m_tGameData = nil
    self.m_moveFlag = nil
    self.m_curPage = nil
    self.m_list_view_bg = nil
    self.m_num_label = nil
end
--[[--
    返回
]]
function game_activity_mine_shop.back(self,backType)
    local function responseMethod(tag,gameData)
       game_scene:enterGameUi("game_activity_mine_new",{gameData = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("mining_task_index"), http_request_method.GET, nil,"mining_task_index")
end
--[[--
    读取ccbi创建ui
]]
function game_activity_mine_shop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_activity_mine_shop.ccbi");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_num_label = ccbNode:labelTTFForName("m_num_label")
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
    创建列表
]]
function game_activity_mine_shop.createTableView(self,viewSize)
    local exchange_limit = self.m_tGameData.exchange_limit or {}
    local adventure_exchange_cfg = getConfig(game_config_field.adventure_exchange)
    local showData = {}
    local tempCount = adventure_exchange_cfg:getNodeCount()
    for i=1,tempCount do
        local itemCfg = adventure_exchange_cfg:getNodeAt(i-1)
        table.insert(showData,itemCfg:getKey())
    end
    table.sort(showData,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
    local itemsCount = #showData
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local function onMainBtnClick(target,event)
        if self.m_moveFlag == false and event == 32 then
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            local tempId = showData[btnTag + 1]
            local function responseMethod(tag,gameData)
                self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                local reward = self.m_tGameData.reward or {}
                game_util:rewardTipsByDataTable(reward)
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("mining_reward_exchange"), http_request_method.GET, {exchange_id = tempId},"mining_reward_exchange")
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    -- params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = totalItem;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_buy_item_list_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
            game_util:setCCControlButtonTitle(m_buy_btn,"Đổi") --兑换
            m_buy_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY+1);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
            m_buy_btn:setTag(index);
            if index < itemsCount then
                m_buy_btn:setVisible(true);
                m_spr_bg_up:setVisible(false);
                local m_node = ccbNode:nodeForName("m_node");
                m_node:removeAllChildrenWithCleanup(true);
                local m_cost_label = ccbNode:labelBMFontForName("m_cost_label")
                local m_name_label = ccbNode:labelTTFForName("m_name_label")
                local m_limit_label = ccbNode:labelBMFontForName("m_limit_label")
                local cd_node = ccbNode:nodeForName("cd_node")
                local m_cdTime = ccbNode:labelTTFForName("m_cdTime")
                local m_cost_icon_spr = ccbNode:spriteForName("m_cost_icon_spr")
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("mining_item_icon6.png")
                if tempSpriteFrame then
                    m_cost_icon_spr:setScale(0.5)
                    m_cost_icon_spr:setDisplayFrame(tempSpriteFrame)
                end
                local tempId = showData[index+1]
                local itemCfg = adventure_exchange_cfg:getNodeWithKey(tempId)
                local bought = exchange_limit[tempId] or 0
                local cost = itemCfg:getNodeWithKey("cost"):toInt()
                local limits = itemCfg:getNodeWithKey("limits"):toInt()
                local des = itemCfg:getNodeWithKey("des"):toStr()
                local reward = itemCfg:getNodeWithKey("reward")
                local haveTimes = math.max(0,limits-bought)
                local rewardCount = reward:getNodeCount()
                if rewardCount > 0 then
                    local icon,name,count = game_util:getRewardByItem(reward:getNodeAt(0));
                    if icon then
                        icon:setScale(0.9)
                        m_node:addChild(icon);
                    end
                    if name then
                        if limits == -1 then
                            m_name_label:setString(name);
                        else
                            m_name_label:setString(name .. "(" .. haveTimes ..")")
                        end
                    end
                    if count > 1 then
                        m_limit_label:setString("×" .. count)
                    else
                        m_limit_label:setString("")
                    end
                end
                m_cost_label:setString(tostring(cost))
                if limits ~= -1 and haveTimes <= 0 then
                    cd_node:setVisible(true)
                    m_cdTime:setString("Ngày mai tạo mới")--明日刷新
                    game_util:setCCControlButtonEnabled(m_buy_btn,false)
                else
                    cd_node:setVisible(false)
                    game_util:setCCControlButtonEnabled(m_buy_btn,true)
                end
            else
                m_buy_btn:setVisible(false);
                m_spr_bg_up:setVisible(true);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= itemsCount then return end;
        if eventType == "ended" and cell then
            local tempId = showData[index+1]
            local itemCfg = adventure_exchange_cfg:getNodeWithKey(tempId)
            local reward = itemCfg:getNodeWithKey("reward")
            local rewardCount = reward:getNodeCount()
            if rewardCount > 0 then
                game_util:lookItemDetal(json.decode(reward:getNodeAt(0):getFormatBuffer()))
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新
]]
function game_activity_mine_shop.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tempTableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tempTableView);
end

--[[--
    刷新ui
]]
function game_activity_mine_shop.refreshUi(self)
    self:refreshTableView()
    local cur_score = self.m_tGameData.cur_score or 0
    local tempValue,_ = game_util:formatValueToString(cur_score,true)
    self.m_num_label:setString(tostring(tempValue))
end
--[[--
    初始化
]]
function game_activity_mine_shop.init(self,t_params)
    t_params = t_params or {};
    self.m_tGameData = t_params.gameData or {}
end

--[[--
    创建ui入口并初始化数据
]]
function game_activity_mine_shop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_activity_mine_shop;