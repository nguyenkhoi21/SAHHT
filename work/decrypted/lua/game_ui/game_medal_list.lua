-- 勋章界面

local game_medal_list = {
    m_list_view_bg = nil,
    m_tableView = nil,
    m_selSort = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_title_label = nil,
    m_popUi = nil,
    m_func_btn = nil,
    gameData = nil,
};
--[[--
    销毁ui
]]
function game_medal_list.destroy(self)
    -- body
    cclog("-----------------game_medal_list destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_tableView = nil;
    self.m_selSort = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_title_label = nil;
    self.m_popUi = nil;
    self.m_func_btn = nil;
    self.gameData = nil;
end

--[[--
    返回
]]
function game_medal_list.back(self,type)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_medal_list.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 101 then--勋章图鉴
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_medal_charts",{gameData = gameData});
                self:destroy()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_index"), http_request_method.GET, nil,"medal_index")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_list.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    self.m_sort_btn:setVisible(false)
    self.m_func_btn = ccbNode:controlButtonForName("m_func_btn")
    self.m_func_btn:setVisible(true)
    game_util:setCCControlButtonTitle(self.m_func_btn,"Nhận huy chương")
    self.m_title_label = ccbNode:labelBMFontForName("m_title_label")
    self.m_title_label:setString("DS huy chương")
    return ccbNode;
end

--[[--
    创建装备列表
]]
function game_medal_list.createTableView(self,viewSize,tableData)
    local itemsCount = game_util:getTableLen(tableData)
    local showDataKey = {}
    for k,v in pairs(tableData) do
        table.insert( showDataKey, k )
    end
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createMedalItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            
            if index < itemsCount then
                m_spr_bg_up:setVisible(false);
                local key = showDataKey[index + 1]
                local itemData = {}
                itemData.c_id = key
                local count = tableData[tostring(key)]
                itemData.count = count
            --     local itemData,itemCfg = game_data:getGemDataById(tableData[index+1]);
                game_util:setMedalItemInfoByTable(ccbNode,itemData);
            else
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
            
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新列表
]]
function game_medal_list.refreshTableView(self,sort)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true)
    self.m_selSort = sort;
    -- game_data:gemSortByTypeName(self.m_selSort)
    -- local tempData = game_data:getGemIdTable();
    local tempData = self.gameData["_medal"]
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize(),tempData);
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--
    刷新ui
]]
function game_medal_list.refreshUi(self)
    self:refreshTableView(self.m_selSort);
end
--[[--
    初始化
]]
function game_medal_list.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_medal_list.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_medal_list;