-- 组队邀请界面
local ui_teamTask_invite_pop = {
    m_root_layer = nil,
    m_btn_back = nil,
    m_tGameData = nil,
    m_layer_untouch = nil,
    m_node_table = nil,
    m_teamid = nil,

    -- m_sel_invite = {},
} 

function ui_teamTask_invite_pop:destroy( )
    cclog("   -------  ui_teamTask_invite_pop   ----------     destroy  -------")
    self.m_root_layer = nil;
    self.m_btn_back = nil;
    self.m_tGameData = nil;
    self.m_layer_untouch = nil;
    self.m_node_table = nil;
    self.m_teamid = nil;
    -- self.m_sel_invite = nil;
end

function ui_teamTask_invite_pop:back()
	game_scene:removePopByName("ui_teamTask_invite_pop")
end

function ui_teamTask_invite_pop:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 1 then
			self:back()
        end
	end
	local ccbNode =  luaCCBNode:create();
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_teamTask_invite_pop.ccbi")
	self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-6,true);
    self.m_root_layer:setTouchEnabled(true)

	self.m_btn_back = ccbNode:controlButtonForName("m_close_btn")
    self.m_btn_back:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
    self.m_node_table = ccbNode:nodeForName("m_node_table")
    return ccbNode
end

function ui_teamTask_invite_pop:refreshUi()
    local data = {}
    local i = 1
    for k,v in pairs(self.m_tGameData) do
        v["k_id"] = k
        table.insert(data,v)
    end

    local table_View = self:createTableView(self.m_node_table:getContentSize(),data);
    table_View:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
    if self.m_node_table:getChildren() then
        self.m_node_table:removeAllChildrenWithCleanup(true)
        self.m_node_table:addChild(table_View)
    end
end

function ui_teamTask_invite_pop.setInfoByTable(self,ccbNode,itemData,index)
    local m_sp_face = ccbNode:spriteForName("m_sp_face")
    local m_label_lv = ccbNode:labelTTFForName("m_label_lv")
    local m_label_combat = ccbNode:labelBMFontForName("m_label_combat")
    local btn = ccbNode:controlButtonForName("m_btn_invite")
    local m_label_name = ccbNode:labelTTFForName("m_label_name")
    local m_label_partyname = ccbNode:labelTTFForName("m_label_partyname")

    btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
    btn:setTag(index)
    m_label_lv:setString(itemData.level)
    m_label_combat:setString(itemData.combat)
    m_label_name:setString(itemData.name)
    m_label_partyname:setString(itemData.association_name)

    if m_sp_face:getChildren() then
        m_sp_face:removeAllChildrenWithCleanup(true)
    end
    local icon= CCSprite:create(MAIN_ROLE_ICON_R[tonumber(itemData.role)].icon)
    m_sp_face:addChild(icon)
    if tonumber(itemData.role) == 1 then
        icon:setPosition(ccp(m_sp_face:getContentSize().width/2-4,m_sp_face:getContentSize().height/2+5))
    elseif tonumber(itemData.role) == 2 then
        icon:setPosition(ccp(m_sp_face:getContentSize().width/2+1,m_sp_face:getContentSize().height/2+8))
    elseif tonumber(itemData.role) == 3 then
        icon:setPosition(ccp(m_sp_face:getContentSize().width/2,m_sp_face:getContentSize().height/2+8))
    elseif tonumber(itemData.role) == 4 then
        icon:setPosition(ccp(m_sp_face:getContentSize().width/2-2,m_sp_face:getContentSize().height/2+8))
    elseif tonumber(itemData.role) == 5 then
        icon:setPosition(ccp(m_sp_face:getContentSize().width/2,m_sp_face:getContentSize().height/2+6))
    end
    icon:setScale(0.8)
end

function ui_teamTask_invite_pop.createTableView(self,viewSize,tableData)
    cclog("-----------------game_equip_recast createRecastChargeTableView-----------------");
    -- self.last_m_sel_img2 = nil;
    -- self.m_sel_invite = {}
    local function onItemClick(  target,event  )

        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();

        local uid = tableData[btnTag]["uid"]
        local function sendRequest()
            local function responseMethod(tag,gameData)        
                local tagNode = tolua.cast(target,"CCNode");
                local btnTag = tagNode:getTag();
                game_util:addMoveTips({text = "Gửi lời mời thành công"}) -- 成功发送邀请
                self.m_tGameData[tonumber(tableData[btnTag].k_id)] = nil
                self:refreshUi()
            end

            local params = {};
            params.f_uid = tostring(uid)
            params.team_id = self.m_teamid
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_invit_friend"), http_request_method.GET, params,"team_fight_invit_friend")
        end
        sendRequest();
    end

    local propCount = #tableData;
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 1; --列
    params.totalItem = propCount;
    params.itemActionFlag = true;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onItemClick",onItemClick);
            ccbNode:openCCBFile("ccb/ui_teamTask_invite_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            if index < propCount then
                self:setInfoByTable(ccbNode,tableData[index+1],tonumber(index)+1);
            end
        end
        return cell;
    end
    return TableViewHelper:create(params);
end

function ui_teamTask_invite_pop:init(t_params)
    cclog( "                ui_teamTask_invite_pop ============================                      ")
	self.m_tGameData = {}
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()).friends or {};    
    end
    self.m_teamid = t_params.teamid or ""
end

function ui_teamTask_invite_pop:create(t_params)
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end


return ui_teamTask_invite_pop