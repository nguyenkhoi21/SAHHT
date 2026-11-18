---  挖矿战斗结束

local game_activity_mine_over_pop = {
    m_popUi = nil,
    m_tGameData = nil,
    m_close_btn = nil,
    m_root_layer = nil,
    m_list_view_bg = nil,
    m_layer_mun_label = nil,
    m_kill_num_label = nil,
    m_score_label = nil,
    m_tips_label = nil,
    m_none_reward_label = nil,
};

--[[--
    销毁
]]
function game_activity_mine_over_pop.destroy(self)
    -- body
    cclog("-----------------game_activity_mine_over_pop destroy-----------------");
    self.m_popUi = nil
    self.m_tGameData = nil
    self.m_close_btn = nil
    self.m_root_layer = nil
    self.m_list_view_bg = nil
    self.m_layer_mun_label = nil
    self.m_kill_num_label = nil
    self.m_score_label = nil
    self.m_tips_label = nil
    self.m_none_reward_label = nil
end
--[[--
    返回
]]
function game_activity_mine_over_pop.back(self,type)
    game_scene:removePopByName("game_activity_mine_over_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_activity_mine_over_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            -- self:back()
            local function responseMethod(tag,gameData)
               game_scene:enterGameUi("game_activity_mine_new",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("mining_task_index"), http_request_method.GET, nil,"mining_task_index")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_activity_mine_over_pop.ccbi");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_layer_mun_label = ccbNode:labelTTFForName("m_layer_mun_label")
    self.m_kill_num_label = ccbNode:labelTTFForName("m_kill_num_label")
    self.m_score_label = ccbNode:labelTTFForName("m_score_label")
    self.m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    self.m_none_reward_label = ccbNode:labelTTFForName("m_none_reward_label")
    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg")
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建列表
]]
function game_activity_mine_over_pop.createTableView(self,viewSize)
    local showData = self.m_tGameData.end_fight_reward or {}
    cclog("end_fight_reward",json.encode(showData))
    local totalItem = #showData
    self.m_none_reward_label:setVisible(totalItem == 0)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = math.min(3,totalItem); --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 1
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local itemData = showData[index + 1]
            local icon,name,count = game_util:getRewardByItemTable(itemData,true)
            if icon then
                icon:setScale(0.75)
                icon:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.6))
                cell:addChild(icon)
            end
            if name then
                local tempLabel = game_util:createLabelTTF({text = name,color = ccc3(255,255,255),fontSize = 10})
                tempLabel:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.2))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            local itemData = showData[index + 1]
            game_util:lookItemDetal(itemData)
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function game_activity_mine_over_pop.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tempTableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tempTableView);
end

--[[--
    刷新ui
]]
function game_activity_mine_over_pop.refreshUi(self)
    self:refreshTableView()
    local layer_num = self.m_tGameData.layer_num or 0 -- 当前层数
    local kill_enemy_num = self.m_tGameData.kill_enemy_num or 0 -- 杀死怪物数
    local end_daily_score = self.m_tGameData.end_daily_score or 0 -- 最终得分
    local end_rank = self.m_tGameData.end_rank or 0 -- 最终排名
    self.m_layer_mun_label:setString(tostring(layer_num))
    self.m_kill_num_label:setString(tostring(kill_enemy_num))
    self.m_score_label:setString(tostring(end_daily_score))
    self.m_tips_label:setString("Chúc mừng lọt vào bảng xếp hạng" .. tostring(end_rank))--恭喜进入排行榜
end

--[[--
    初始化
]]
function game_activity_mine_over_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_tGameData = t_params.gameData
end

--[[--
    创建ui入口并初始化数据
]]
function game_activity_mine_over_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_activity_mine_over_pop;