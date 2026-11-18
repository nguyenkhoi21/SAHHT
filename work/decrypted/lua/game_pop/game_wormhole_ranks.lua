--- 虫洞斗兽场排行榜

local game_wormhole_ranks = {

    m_page = nil,
    m_btn = {},
    rank_all = {},

    m_node_tableview = nil,
    m_node_ranks_self = nil,
    m_node_icons_self = nil,
    m_lb_name_self = nil,
    m_lb_combat_self = nil,
    m_lb_wins_self = nil,
    m_lb_recards_self = nil,
};
--[[--
    销毁
]]
function game_wormhole_ranks.destroy(self)
    -- body
    cclog("-----------------game_wormhole_ranks destroy-----------------");

    self.m_page = nil
    self.m_btn = nil
    self.m_node_tableview = nil
    self.rank_all = nil
    self.m_node_ranks_self = nil
    self.m_node_icons_self = nil
    self.m_lb_name_self = nil
    self.m_lb_combat_self = nil
    self.m_lb_wins_self = nil
    self.m_lb_recards_self = nil
end
--[[--
    返回
]]
function game_wormhole_ranks.back(self,type)
    cclog("------------  remove game_wormhole_ranks")
    game_scene:removePopByName("game_wormhole_ranks");
end
--[[--
    读取ccbi创建ui
]]
function game_wormhole_ranks.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 99999 then--关闭
            self:back();
        elseif btnTag == 101 then
            local function responseMethod( tag,gameData )
                local data = gameData:getNodeWithKey("data");
                data = json.decode(data:getFormatBuffer()) or {}
                self:setdata(data,1)
            end
            local params = {}
            params.sort = self.all_sort[1].id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_get_rank"), http_request_method.GET, params,"wormholes_get_rank")
        elseif btnTag == 102 then
            local function responseMethod( tag,gameData )
                local data = gameData:getNodeWithKey("data");
                data = json.decode(data:getFormatBuffer()) or {}
                self:setdata(data,2)
            end
            local params = {}
            params.sort = self.all_sort[2].id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_get_rank"), http_request_method.GET, params,"wormholes_get_rank")
        elseif btnTag == 103 then
            local function responseMethod( tag,gameData )
                local data = gameData:getNodeWithKey("data");
                data = json.decode(data:getFormatBuffer()) or {}
                self:setdata(data,3)
            end
            local params = {}
            params.sort = self.all_sort[3].id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_get_rank"), http_request_method.GET, params,"wormholes_get_rank")
        elseif btnTag == 104 then
            local function responseMethod( tag,gameData )
                local data = gameData:getNodeWithKey("data");
                data = json.decode(data:getFormatBuffer()) or {}
                self:setdata(data,4)
            end
            local params = {}
            params.sort = self.all_sort[4].id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_get_rank"), http_request_method.GET, params,"wormholes_get_rank")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_game_wormhole_ranks_pop.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn = self.m_btn or {}
    for i=1,4 do
        self.m_btn[i] = ccbNode:controlButtonForName("m_btn_"..i)
        self.m_btn[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    end
    self.m_node_tableview = ccbNode:nodeForName("m_node_tableview")

    self.m_node_ranks_self =  ccbNode:nodeForName("m_node_ranks_self")
    self.m_node_icons_self =  ccbNode:nodeForName("m_node_icons_self")
    self.m_lb_name_self = ccbNode:labelTTFForName("m_lb_name_self")
    self.m_lb_combat_self = ccbNode:labelTTFForName("m_lb_combat_self")
    self.m_lb_wins_self = ccbNode:labelTTFForName("m_lb_wins_self")
    self.m_lb_recards_self = ccbNode:labelTTFForName("m_lb_recards_self")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

function game_wormhole_ranks.setdata(self,data,tarid)
    self.rank_all = self.rank_all or {}
    self.own_rank = self.own_rank or {}
    self.rank_all[tarid] = data.rank.rank_all
    local myrank = 101

    if data.rank.own_rank and data.rank.own_rank ~= 0 then
        if data.rank.own_rank ~= -1 then
            myrank = data.rank.own_rank
        end
    end

    self.own_rank[tarid] = { rank = myrank }
    if  self.own_rank[tarid].rank <= 100 then
        self.own_rank[tarid].win_times = self.rank_all[tarid][self.own_rank[tarid].rank].win_times
        self.own_rank[tarid].combat = self.rank_all[tarid][self.own_rank[tarid].rank].combat
        self.own_rank[tarid].role = self.rank_all[tarid][self.own_rank[tarid].rank].role
        self.own_rank[tarid].score = self.rank_all[tarid][self.own_rank[tarid].rank].score
        self.own_rank[tarid].name = self.rank_all[tarid][self.own_rank[tarid].rank].name
    end
    self.m_page = tarid
    self:refreshUi()
end

--[[--
    刷新ui
]]
function game_wormhole_ranks.refreshUi(self)
    for i=1,#self.m_btn do
        self.m_btn[i]:setEnabled(self.m_page ~= i)
    end
    local data = self.rank_all[self.m_page]
    local tableView = self:createTaskTable(self.m_node_tableview:getContentSize(),data)
    if tableView then
        self.m_node_tableview:removeAllChildrenWithCleanup(true)
        self.m_node_tableview:addChild(tableView)
    end
    
    self.m_node_ranks_self:removeAllChildrenWithCleanup(true)
    self.m_node_icons_self:removeAllChildrenWithCleanup(true)
    if next(self.rank_all[self.m_page]) and self.own_rank[self.m_page] and self.own_rank[self.m_page].rank and self.own_rank[self.m_page].rank < 100 then
        local banner = nil
        if self.own_rank[self.m_page].rank <= 3 then
            banner = CCSprite:createWithSpriteFrameName("ui_wormhole_others_rank_icon"..self.own_rank[self.m_page].rank..".png")
        else
            banner = CCLabelTTF:create(self.own_rank[self.m_page].rank.."",TYPE_FACE_TABLE.Arial_BoldMT,26)
        end
        local icon = game_util:createPlayerRoleGardenIconByRoleId(self.own_rank[self.m_page].role or 1)
        self.m_node_ranks_self:addChild(banner)
        self.m_node_icons_self:addChild(icon)
        icon:setScale(0.6)
        self.m_lb_name_self :setString(self.own_rank[self.m_page].name or "")
        self.m_lb_combat_self :setString(self.own_rank[self.m_page].combat or "")
        self.m_lb_wins_self :setString(self.own_rank[self.m_page].win_times or "")
        self.m_lb_recards_self :setString(self.own_rank[self.m_page].score or "")
    else
        self.m_lb_name_self :setString("Bạn chưa lên BXH")
        self.m_lb_combat_self :setString("")
        self.m_lb_wins_self :setString("")
        self.m_lb_recards_self :setString("")
    end
end

--[[]]
function game_wormhole_ranks:createTaskTable(viewSize, tableData)
    tableData = tableData or {}
    local count = game_util:getTableLen(tableData)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 1
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-20;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionVertical
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_game_wormhole_ranks_items.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then
            local itemData = tableData[index+1] or tableData[tostring(index+1)]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_node_ranks = ccbNode:nodeForName("m_node_ranks")
            local m_node_icons = ccbNode:nodeForName("m_node_icons")

            local m_lb_name = ccbNode:labelTTFForName("m_lb_name")
            local m_lb_combat = ccbNode:labelTTFForName("m_lb_combat")
            local m_lb_wins = ccbNode:labelTTFForName("m_lb_wins")
            local m_lb_recards = ccbNode:labelTTFForName("m_lb_recards")
            m_node_ranks:removeAllChildrenWithCleanup(true)
            m_node_icons:removeAllChildrenWithCleanup(true)
            local banner = nil
            if index < 3 then
                banner = CCSprite:createWithSpriteFrameName("ui_wormhole_others_rank_icon"..(index+1)..".png")
            else
                banner = CCLabelTTF:create((index+1).."",TYPE_FACE_TABLE.Arial_BoldMT,26)
            end
            local icon = game_util:createPlayerRoleGardenIconByRoleId(itemData.role or 1)
            m_node_ranks:addChild(banner)
            m_node_icons:addChild(icon)
            icon:setScale(0.6)
            m_lb_name :setString(itemData.name or "")
            m_lb_combat :setString(itemData.combat or "")
            m_lb_wins :setString(itemData.win_times or "")
            m_lb_recards :setString(itemData.score or "")
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
    end
    return TableViewHelper:create(params);
end
--]]
--[[--
    初始化
]]
function game_wormhole_ranks.init(self,t_params)
    self.all_sort = t_params.all_sort
    t_params = t_params.gameData or {};
    self.m_page = 1
    -- body
    self.rank_all = {}
    self.own_rank = {}
    self.rank_all[1] = t_params.rank.rank_all

    local myrank = 101
    if t_params.rank.own_rank and t_params.rank.own_rank ~= 0 then
        if t_params.rank.own_rank ~= -1 then
            myrank = t_params.rank.own_rank
        end
    end
    self.own_rank[1] = { rank = myrank }
    if self.own_rank[self.m_page].rank <= 100  and next(self.rank_all[self.m_page]) then
        self.own_rank[self.m_page].win_times = self.rank_all[self.m_page][self.own_rank[self.m_page].rank].win_times
        self.own_rank[self.m_page].combat = self.rank_all[self.m_page][self.own_rank[self.m_page].rank].combat
        self.own_rank[self.m_page].role = self.rank_all[self.m_page][self.own_rank[self.m_page].rank].role
        self.own_rank[self.m_page].score = self.rank_all[self.m_page][self.own_rank[self.m_page].rank].score
        self.own_rank[self.m_page].name = self.rank_all[self.m_page][self.own_rank[self.m_page].rank].name
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_wormhole_ranks.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_wormhole_ranks;