--新大富翁已获得奖励
local game_newRichMan_depot_pop = {
    m_tGameData = nil,
    m_node_reward = nil,

};
--[[--
    销毁ui
]]
function game_newRichMan_depot_pop.destroy(self)
    -- body
    cclog("-----------------game_newRichMan_depot_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_node_reward = nil;

end
--[[--
    返回
]]
function game_newRichMan_depot_pop.back(self,type)
	game_scene:removePopByName("game_newRichMan_depot_pop")
end
--[[--
    读取ccbi创建ui
]]
function game_newRichMan_depot_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if self.m_animFlag == true then
            return
        end
        cclog2(btnTag,"btnTag ==== ")
        if btnTag == 101 then--返回
            self:back();
        
        elseif btnTag == 2 then
            local function  responseMethod( tag, gameData )
                game_scene:addPop("game_newRichMan_formation_pop",{gameData = gameData, openType = "admiral"})
                self:back()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_formation_info"), http_request_method.GET, nil,"monopoly_formation_info")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_worldTree_reward_pop.ccbi");
    
    self.m_node_reward = ccbNode:nodeForName("m_node_reward")
   

    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

    local m_node_ui = ccbNode:nodeForName("m_node_ui")
    m_node_ui:setVisible(false)



    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
function game_newRichMan_depot_pop.createTableView(self,viewSize)
    local length = game_util:getTableLen(self.m_tGameData.reward_log)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 6; --列
    params.totalItem = length;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            -- ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            -- ccbNode:openCCBFile("ccb/ui_arena_rank_item.ccbi");
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            ccbNode:removeAllChildrenWithCleanup(true)
            local reward = self.m_tGameData.reward_log[index+1]
            local icon,name,count = game_util:getRewardByItemTable(reward)
            if icon then
                icon:setScale(0.8)
                ccbNode:addChild(icon)
                local conutlab = "x" .. count
                local labelNum = CCLabelTTF:create(conutlab,TYPE_FACE_TABLE.Arial_BoldMT,10);
                labelNum:setPosition(ccp(10,-15))
                ccbNode:addChild(labelNum)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local reward = self.m_tGameData.reward_log[index+1]
            if reward then
                game_util:lookItemDetal(reward)
            end
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新ui
]]
function game_newRichMan_depot_pop.refreshUi(self)
    self.m_node_reward:removeAllChildrenWithCleanup(true)
    self.m_node_reward:addChild(self:createTableView(self.m_node_reward:getContentSize()))
end
--[[--
    初始化
]]
function game_newRichMan_depot_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_newRichMan_depot_pop.create(self,t_params)
    self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi();

    return  m_popUi;
end
return game_newRichMan_depot_pop;