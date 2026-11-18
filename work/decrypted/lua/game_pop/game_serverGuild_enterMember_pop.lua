
local game_serverGuild_enterMember_pop = {
    m_tGameData = nil,
    m_node_tableView = nil,
    m_curPage = nil,
    m_label_page = nil,
    m_tableView = nil,
    m_nTotalPage = nil,
};
--[[--
    销毁ui
]]
function game_serverGuild_enterMember_pop.destroy(self)
    -- body
    cclog("-----------------game_serverGuild_enterMember_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_node_tableView = nil;
    self.m_curPage = nil;
    self.m_label_page = nil;
    self.m_tableView = nil;
    self.m_nTotalPage = nil;
   
end
--[[--
    返回
]]
function game_serverGuild_enterMember_pop.back(self,backType)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("game_serverGuild_enterMember_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_serverGuild_enterMember_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then
            if self.m_curPage == 1  then
                return
            end
            local posX,posY = self.m_tableView:getContainer():getPosition();
            local tableViewSize = self.m_node_tableView:getContentSize()
            local curOffset = self.m_tableView:getContentOffset()
            self.m_tableView:setContentOffset(ccp(curOffset.x+tableViewSize.width,posY),false);
            self.m_curPage = self.m_curPage - 1
            self.m_label_page:setString("(" .. self.m_curPage .. "/" .. self.m_nTotalPage .. ")")
        elseif btnTag == 102 then
            if self.m_curPage == self.m_nTotalPage or self.m_nTotalPage == 0 then
                return
            end
            local curOffset = self.m_tableView:getContentOffset()
            local posX,posY = self.m_tableView:getContainer():getPosition();
            local tableViewSize = self.m_node_tableView:getContentSize()
            self.m_tableView:setContentOffset(ccp(curOffset.x-tableViewSize.width,posY),false);
            self.m_curPage = self.m_curPage + 1
            self.m_label_page:setString("(" .. self.m_curPage .. "/" .. self.m_nTotalPage .. ")")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_serverGuild_enterMember_pop.ccbi");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    local m_btn_right = ccbNode:controlButtonForName("m_btn_right")
    m_btn_right:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    local m_btn_left = ccbNode:controlButtonForName("m_btn_left")
    m_btn_left:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    
    self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")
    self.m_label_page = ccbNode:labelTTFForName("m_label_page")
    local function onTouch( eventType, x, y )
        if eventType == "began" then
            return true;--intercept event
        end
    end
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    m_root_layer:registerScriptTouchHandler(onTouch, false, GLOBAL_TOUCH_PRIORITY-2, true)
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

function game_serverGuild_enterMember_pop.createTableView(self,viewSize)
    local showData = self.m_tGameData.waiter_detail_list or {}
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = game_util:getTableLen(showData)
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+ 130;
    params.showPageIndex = self.m_curPage;
    params.showPoint = false
    params.direction = kCCScrollViewDirectionHorizontal;
    local onePageCount = params.row * params.column;
    local m_nCurPage = 1;
    local m_nTotalPage = 1;
    m_nTotalPage = ((params.totalItem % onePageCount == 0) and (params.totalItem / onePageCount) or (params.totalItem / onePageCount + 1));
    m_nTotalPage = math.floor(m_nTotalPage);
    if m_nTotalPage == 0 then
        m_nTotalPage = 1
    end
    self.m_nTotalPage = m_nTotalPage
    self.m_label_page:setString("(" .. self.m_curPage .. "/" .. m_nTotalPage .. ")")

    local function onMainBtnClick( target, event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- body
        
        if btnTag > 200 then
            local uid = showData[btnTag - 200].uid
            local params = {}
            params.u_id = uid
            

            local function responseMethod( tag,gameData )
                game_scene:addPop("game_serverGuild_formation_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_users_info"), http_request_method.GET, params,"new_guild_fight_users_info")
           
        elseif btnTag > 100 then
            local function responseMethod( tag,gameData )
                game_util:addMoveTips({text = "雇佣成功"})
                self:back()
                game_scene:addPop("game_serverGuild_employo_pop",{gameData = gameData})
                -- cclog2(gameData,"gameData === ")
            end
            local uid = showData[btnTag - 100].uid
            local params = {}
            params.uid = uid
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_employ_user"), http_request_method.GET, params,"new_guild_fight_employ_user")
        end
    end
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/2);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_serverGuild_enterMember_item.ccbi");
            -- ccbNode:setAnchorPoint(ccp(0.5,0.5));
            -- local offsetY = 0
            -- offsetY = math.floor(index/5)*7
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
           local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
           local itemData = showData[index + 1]
           local m_label_name = ccbNode:labelTTFForName("m_label_name")
           m_label_name:setString(tostring(itemData.name))
           local m_label_combat = ccbNode:labelTTFForName("m_label_combat")
           m_label_combat:setString("战斗力:" .. tostring(itemData.combat ))
           local m_label_num1 = ccbNode:labelTTFForName("m_label_num1")
           m_label_num1:setString("被雇佣:" .. tostring(itemData.employ ))
           local m_label_num2 = ccbNode:labelTTFForName("m_label_num2")
           m_label_num2:setString("联盟已雇佣:" .. tostring(itemData.my_ass_employ ))
            
           local m_btn_formation = ccbNode:controlButtonForName("m_btn_formation")
           local m_btn_employ = ccbNode:controlButtonForName("m_btn_employ")
           m_btn_employ:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
           m_btn_formation:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
           m_btn_employ:setTag(index + 101)
           m_btn_formation:setTag(index + 201)

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
        self.m_label_page:setString("(" .. self.m_curPage .. "/" .. m_nTotalPage .. ")")
    end
    return TableViewHelper:createGallery(params);
end
--[[--
    刷新ui
]]
function game_serverGuild_enterMember_pop.refreshUi(self)
   self.m_node_tableView:removeAllChildrenWithCleanup(true)
   local m_tableView = self:createTableView(self.m_node_tableView:getContentSize())
   self.m_tableView = m_tableView:getChildByTag(10)
   self.m_node_tableView:addChild(m_tableView)
end
--[[--
    初始化
]]
function game_serverGuild_enterMember_pop.init(self,t_params)
    self.m_curPage = 1
    t_params = t_params or {};
    -- body
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer());
    end
    self.m_selGuildId = t_params.guildId;
  
end

--[[--
    创建ui入口并初始化数据
]]
function game_serverGuild_enterMember_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_serverGuild_enterMember_pop;