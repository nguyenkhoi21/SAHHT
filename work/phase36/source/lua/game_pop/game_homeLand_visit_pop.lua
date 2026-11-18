--- 家园拜访界面

local game_homeLand_visit_pop = {
    m_popUi = nil,
    m_close_btn = nil,
    m_node_tableView = nil,
    m_select_tag = nil,
    m_btn_friend = nil,
    m_btn_log = nil,
    m_visitData = nil,
 
};
--[[--
    销毁ui
]]
function game_homeLand_visit_pop.destroy(self)
    -- body
    cclog("-----------------game_homeLand_visit_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_node_tableView = nil;
    self.m_close_btn = nil;
    self.m_select_tag = nil;
    self.m_btn_friend = nil;
    self.m_btn_log = nil;
    self.m_visitData = nil;

end
--[[--
    返回
]]
function game_homeLand_visit_pop.back(self,backType)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("game_homeLand_visit_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_homeLand_visit_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick2( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        
        elseif btnTag == 301 then
            self.m_btn_friend:setHighlighted(true)
            self.m_btn_log:setHighlighted(false)
            self.m_select_tag = btnTag
        elseif btnTag == 302 then
            self.m_btn_friend:setHighlighted(false)
            self.m_btn_log:setHighlighted(true)
            self.m_select_tag = btnTag
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick2",onMainBtnClick2);
    ccbNode:openCCBFile("ccb/ui_homeLand_visit_pop.ccbi");
    self.m_btn_friend = ccbNode:controlButtonForName("m_btn_friend")
    self.m_btn_log = ccbNode:controlButtonForName("m_btn_log")
    self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")
    self.m_btn_friend:setHighlighted(true)
    return ccbNode;
end

--[[--
    创建活动列表
]]
function game_homeLand_visit_pop.createTableView(self,viewSize)
    local function onCellClick( event,target )
        -- body
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 7;--行
    params.column = 1; --列
    params.totalItem = 10;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    params.direction = kCCScrollViewDirectionVertical;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()

            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellClick",onCellClick);
            ccbNode:openCCBFile("ccb/ui_homeLand_visit_item.ccbi");
            -- ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(-3,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
         
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新ui
]]
function game_homeLand_visit_pop.refreshUi(self)
    self.m_node_tableView:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_node_tableView:getContentSize());
    self.m_node_tableView:addChild(tableViewTemp);
    tableViewTemp:setScrollBarVisible(false)
  
end
--[[--
    初始化
]]
function game_homeLand_visit_pop.init(self,t_params)
    self.m_select_tag = 1
end

--[[--
    创建ui入口并初始化数据
]]
function game_homeLand_visit_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return game_homeLand_visit_pop;