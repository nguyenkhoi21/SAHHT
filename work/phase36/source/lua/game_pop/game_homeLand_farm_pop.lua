--- 家园农场抢夺界面

local game_homeLand_farm_pop = {
    m_popUi = nil,
    m_close_btn = nil,
    m_node_tableView = nil,
    m_tab_btn = nil,
    m_tGameData = nil,
    m_openType = nil,
    m_btn_rule = nil,
    m_btn_refresh = nil,
    m_select_index = nil,
    m_btn_friends = nil,
    m_btn_allServer = nil,
    m_label_stealNum = nil,
};
--[[--
    销毁ui
]]
function game_homeLand_farm_pop.destroy(self)
    -- body
    cclog("-----------------game_homeLand_farm_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_node_tableView = nil;
    self.m_close_btn = nil;
    self.m_tab_btn = nil;
    self.m_tGameData = nil;
    self.m_openType = nil;
    self.m_btn_rule = nil;
    self.m_btn_refresh = nil;
    self.m_select_index = nil;
    self.m_btn_friends = nil;
    self.m_btn_allServer = nil;
    self.m_label_stealNum = nil;
end
--[[--
    返回
]]
function game_homeLand_farm_pop.back(self,backType)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("game_homeLand_farm_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_homeLand_farm_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then --好友的农场
            self.m_openType = "friends"
            self:refreshType()
        elseif btnTag == 102 then --全服农场
            self.m_openType = "allServer"
            self:refreshType()
        elseif btnTag == 103 then --说明
            game_scene:addPop("game_active_limit_detail_pop",{enterType = "190"})
        elseif btnTag == 104 then --刷新
            self:refreshType()
        elseif btnTag == 105 then -- 我的农场
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_homeLand_main",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("homeland_index"), http_request_method.GET, nil,"homeland_index")
        elseif btnTag == 106 then
            local function responseMethod(tag,gameData)
                local msg = ""
                local data = gameData:getNodeWithKey("data")
                local visit_log = json.decode(data:getNodeWithKey("visit_log"):getFormatBuffer())
                for k,v in pairs(visit_log) do
                    msg = msg .. "[color=ff00ff00]" .. v.name .. "[/color]" .. "Đã ghé thăm Farm của bạn" .. "\n"
                   -- cclog2(k,"k ---- ")
                   -- cclog2(v,"v ---- ")
                end
                game_scene:addPop("game_active_limit_detail_pop",{openMsg = msg})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("homeland_index"), http_request_method.GET, nil,"homeland_index")
           
        elseif btnTag > 200 and btnTag < 205 then
            self.m_select_index = btnTag-200
            
            local function responseMethod( tag,gameData )
                if gameData then
                    local data = gameData:getNodeWithKey("data")
                    self.m_tGameData = json.decode(data:getFormatBuffer())
                    self.m_openType = "allServer"
                    self.m_btn_allServer:setHighlighted(true);
                    self.m_btn_allServer:setEnabled(false);
                    self.m_btn_friends:setHighlighted(false);
                    self.m_btn_friends:setEnabled(true);
                    self:refreshUi()
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("homeland_random_users"), http_request_method.GET, {arena = self.m_select_index-1},"homeland_random_users")
            for i = 1, 4 do
                self.m_tab_btn[i]:setHighlighted(i == (btnTag - 200))
                self.m_tab_btn[i]:setEnabled(i ~= (btnTag - 200));
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_homeLand_farm_pop.ccbi");
    self.m_label_stealNum = ccbNode:labelTTFForName("m_label_stealNum")
    self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")
    self.m_tab_btn = {}
    local btnName = {"east", "south", "west", "north"}
    local btn = nil
    for i=1,4 do
        btn = ccbNode:controlButtonForName("m_btn_" .. btnName[i])
        btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
        self.m_tab_btn[i] = btn
    end

    self.m_btn_rule = ccbNode:controlButtonForName("m_btn_rule")
    self.m_btn_refresh = ccbNode:controlButtonForName("m_btn_refresh")
    self.m_btn_rule:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
    self.m_btn_refresh:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);

    self.m_btn_friends = ccbNode:controlButtonForName("m_btn_friends")
    self.m_btn_allServer = ccbNode:controlButtonForName("m_btn_allServer")
    self.m_btn_friends:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
    self.m_btn_allServer:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);

    local m_btn_home = ccbNode:controlButtonForName("m_btn_home")
    m_btn_home:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);

    local m_btn_visit = ccbNode:controlButtonForName("m_btn_visit")
    m_btn_visit:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);

    self.m_openType = "friends"
    self.m_btn_friends:setHighlighted(true);
    self.m_btn_friends:setEnabled(false);

    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
    local m_root_layer = ccbNode:layerColorForName("m_root_layer")


    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
function game_homeLand_farm_pop.refreshType( self )
    if self.m_openType == "allServer" then
        local function responseMethod( tag,gameData )
            if gameData then
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer())
                self.m_openType = "allServer"
                self.m_btn_allServer:setHighlighted(true);
                self.m_btn_allServer:setEnabled(false);
                self.m_btn_friends:setHighlighted(false);
                self.m_btn_friends:setEnabled(true);
                self:refreshUi()
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("homeland_random_users"), http_request_method.GET, {arena = self.m_select_index-1},"homeland_random_users")
    else
        local function responseMethod( tag,gameData )
            if gameData then
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer())
                self.m_openType = "friends"
                self.m_btn_friends:setHighlighted(true);
                self.m_btn_friends:setEnabled(false);
                self.m_btn_allServer:setHighlighted(false);
                self.m_btn_allServer:setEnabled(true);
                self:refreshUi()
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("homeland_friends"), http_request_method.GET, nil,"homeland_friends")
    end    
end

--[[--
    创建列表
]]
function game_homeLand_farm_pop.createTableView(self, viewSize, tableData)
    local tableData = tableData or {}
    local function onCellClick( target, event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local uid = tableData[btnTag].uid
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_homeLand_main",{gameData = gameData, types = "friends", friend_uid = uid})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("homeland_visit"), http_request_method.GET, {friend_uid = uid},"homeland_visit")
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 2; --列
    params.totalItem = #tableData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    params.direction = kCCScrollViewDirectionHorizontal;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()

            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellClick",onCellClick);
            ccbNode:openCCBFile("ccb/ui_homeLand_farm_item.ccbi");
            -- ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(10,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = tableData[index + 1]
            local m_label_name = ccbNode:labelTTFForName("m_label_name")
            local m_label_lv = ccbNode:labelTTFForName("m_label_lv")
            local m_label_rank = ccbNode:labelTTFForName("m_label_rank")
            local m_node_icon = ccbNode:nodeForName("m_node_icon")
            m_label_rank:setString(tostring(index + 1 ))
            m_label_name:setString(itemData.name)
            m_label_lv:setString(itemData.level)
            m_node_icon:removeAllChildrenWithCleanup(true)
            local roleId = itemData.role or 1 
            local sprite_head = game_util:createPlayerIconByRoleId(roleId)
            sprite_head:setScale(0.4)
            m_node_icon:addChild(sprite_head)

            local m_btn_visit = ccbNode:controlButtonForName("m_btn_visit")
            m_btn_visit:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
            m_btn_visit:setTag(index + 1)

            local m_sprite_water = ccbNode:spriteForName("m_sprite_water")
            local m_sprite_hand = ccbNode:spriteForName("m_sprite_hand")
            local can_steal = itemData.can_steal --是否可以偷取
            local can_watering = itemData.can_watering -- 是否可以浇水
            if can_steal and next(can_steal) then 
                m_sprite_hand:setVisible(true)
            else
                m_sprite_hand:setVisible(false)
            end
            if can_watering and next(can_watering) then 
                m_sprite_water:setVisible(true)
            else
                m_sprite_water:setVisible(false)
            end
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
function game_homeLand_farm_pop.getData( self )
    self.m_node_tableView:removeAllChildrenWithCleanup(true);
    local curData = {}
    local btnFlag = false
    -- cclog2(self.m_tGameData, "sellf.m_tGameData --- ")
    if self.m_openType == "friends" then
        curData = self.m_tGameData.friends
        btnFlag = false
    else
        curData = self.m_tGameData.users
        btnFlag = true
    end
    for i=1,4 do
        self.m_tab_btn[i]:setVisible(btnFlag)
    end
    local tableViewTemp = self:createTableView(self.m_node_tableView:getContentSize(), curData);
    self.m_node_tableView:addChild(tableViewTemp);
    tableViewTemp:setScrollBarVisible(false)

end

--[[--
    刷新ui
]]
function game_homeLand_farm_pop.refreshUi(self)
    self:getData()
    -- cclog2(self.m_tGameData.max_steal_times - self.m_tGameData.steal_times,"zz---")
    local str_steal = "Số lần trộm hiện tại" .. tostring(self.m_tGameData.max_steal_times - self.m_tGameData.steal_times) .. "/" .. self.m_tGameData.max_steal_times
    self.m_label_stealNum:setString(str_steal)
  
end
--[[--
    初始化
]]
function game_homeLand_farm_pop.init(self,t_params)
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
    else
        self.m_tGameData = {};
    end
    self.m_select_index = 1
    -- cclog2(self.m_tGameData,"m_tGameData --- ")
end

--[[--
    创建ui入口并初始化数据
]]
function game_homeLand_farm_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return game_homeLand_farm_pop;