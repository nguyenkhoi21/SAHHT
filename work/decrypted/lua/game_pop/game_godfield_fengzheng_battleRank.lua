--- 战场即时排名
local game_godfield_fengzheng_battleRank = {
    m_popUi = nil,
    m_root_layer = nil,
    

    m_open_btn = nil,
    rank_node = nil,
};
--[[--
    销毁
]]
function game_godfield_fengzheng_battleRank.destroy(self)
    -- body
    cclog("-----------------game_godfield_fengzheng_battleRank destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;

    self.m_open_btn = nil;
    self.rank_node = nil;
end
--[[--
    返回
]]
function game_godfield_fengzheng_battleRank.back(self,type)
    game_scene:removePopByName("game_godfield_fengzheng_battleRank");
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_fengzheng_battleRank.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 101 then--关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_godfield_fenzheng_battleRank.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    -- self.m_open_btn = ccbNode:controlButtonForName("m_open_btn")
    self.rank_node = ccbNode:nodeForName("rank_node")
    local btn_close = ccbNode:controlButtonForName("m_close_btn")
    btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    self.m_root_layer:setTouchEnabled(true);

    -- local function animCallFunc(animName)
        
    -- end
    -- ccbNode:registerAnimFunc(animCallFunc);
    -- ccbNode:runAnimations("enterAnim")
    return ccbNode;
end

--[[
    排行榜
]]
function game_godfield_fengzheng_battleRank.createRankTable(self,viewSize)
    local colorTable = {ccc3(236,22,20),ccc3(255,213,35),ccc3(91,170,254),ccc3(198,200,150)}
    local rankTable = {}
    if self.m_showType == 1 then
        local tempTable = self.m_tGameData.team_battle_hurt_rank
        for i=1,game_util:getTableLen(tempTable) do
            table.insert( rankTable, {rank = i,name = tempTable[tostring(i)].name,score = tempTable[tostring(i)].hurt} )
        end
    end
    local tabCount = game_util:getTableLen(rankTable)
    local params = {};
    params.viewSize = viewSize;
    params.row = 10;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.totalItem = tabCount;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_active_limit_rank_item2.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local detail_label = ccbNode:labelTTFForName("detail_label");
            local detail_label_score = ccbNode:labelTTFForName("detail_label_score");

            local rankData = rankTable[index+1] or {}
            local name = rankData.name or ""
            local score = rankData.score or ""
            local rank = rankData.rank or ""

            detail_label:setString(tostring(rank) .. ".         " .. name )
            detail_label_score:setString(tostring(score))
            detail_label:setPosition(ccp(-40,0))
            detail_label_score:setPosition(ccp(180,0))
            detail_label:setColor(colorTable[math.min((index+1),4)])
            detail_label_score:setColor(colorTable[math.min((index+1),4)])
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_godfield_fengzheng_battleRank.refreshUi(self)
    --排行榜
    self.rank_node:removeAllChildrenWithCleanup(true)
    local tableView = self:createRankTable(self.rank_node:getContentSize());
    self.rank_node:addChild(tableView,10,10);
end

--[[--
    初始化
]]
function game_godfield_fengzheng_battleRank.init(self,t_params)
    self.m_tParams = t_params or {};
    self.m_tGameData = t_params.gameData
    self.m_showType = t_params.showType or 1;
    self.callBackFunc = t_params.callBackFunc
end
--[[--
    创建ui入口并初始化数据
]]
function game_godfield_fengzheng_battleRank.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end



return game_godfield_fengzheng_battleRank;