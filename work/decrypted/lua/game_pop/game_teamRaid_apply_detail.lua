--  团队副本    卡牌列表
local game_teamRaid_apply_detail = {
	
}

function game_teamRaid_apply_detail:destroy(  )
	-- body

end

function game_teamRaid_apply_detail:back(  )
    game_scene:removePopByName("game_teamRaid_apply_detail")
end

function game_teamRaid_apply_detail:createUi(  ) -- test_touch
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then       -- 返回
        	self:back()
    	end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_teamRaid_applyDetail_pop.ccbi");

    local m_btn_close = ccbNode:controlButtonForName("m_btn_close")
    m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10);

    self.m_team_list_node = ccbNode:nodeForName("m_team_list_node")

    self.m_touchLyaer = ccbNode:layerForName("m_touchLyaer")

	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-6,true);
    self.m_root_layer:setTouchEnabled(true);


    local m_close_layer = ccbNode:layerForName("m_close_layer")
    local function onTouch2(eventType, x, y)
        if eventType == "began" then
            local realPos = m_close_layer:getParent():convertToNodeSpace(ccp(x,y));
            if not m_close_layer:boundingBox():containsPoint(realPos) then
            	self:back()
            else
            	return
            end
        elseif eventType == "ended" then
        end
    end
    m_close_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_close_layer:setTouchEnabled(true);
    self.m_title1 = ccbNode:labelTTFForName("m_title1")
    self.m_title2 = ccbNode:labelTTFForName("m_title2")
    self.m_ccbNode = ccbNode;
    return ccbNode
end


function game_teamRaid_apply_detail:createTableView( viewSize ,tempTable )
	-- body
	local function onMainBtnClick( target,event )
	    local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("press   select    is   " .. btnTag)
        local data = self.m_team_list[btnTag]
        local function responseMethod( tag, gameData )
            if gameData then
            	if self.m_callback then
            		self.m_callback(gameData)
            		self:back()
                    game_util:addMoveTips({text = "Đội viên này đã gia nhập Đội Chuyên Công thành công",new_color = ccc3(123,255,255)})

            	end
            end
        end
        local params = {}
        params.page = self.m_page
        params.cards_id = data.key
        params.player_id = data.uid
        params.raid_id = self.m_raid_id
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_adopt_apply"), http_request_method.GET, params,"team_raid_adopt_apply")
    end
	local tempTable = tempTable or {}
	local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tempTable
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 7
    params.showPoint = false
    params.touchLayer = self.m_touchLyaer
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
            ccbNode:openCCBFile("ccb/ui_teamRaid_apply_item2.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            -- ccbNode:setScale(0.9)
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
    		local itemData = tempTable[index+1]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")

            local m_agree_btn = ccbNode:controlButtonForName("m_agree_btn")
            m_agree_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 7)
            m_agree_btn:setTag(index+1)

	        local m_name_lb12 = ccbNode:labelTTFForName("m_name_lb12")
	        local m_name_lb1 = ccbNode:labelTTFForName("m_name_lb1")
	        local m_lv_lb1 = ccbNode:labelTTFForName("m_lv_lb1")
	        local m_lv_lb12 = ccbNode:labelTTFForName("m_lv_lb12")
	        local m_combat_lb1 = ccbNode:labelTTFForName("m_combat_lb1")
	        local m_combat_lb12 = ccbNode:labelTTFForName("m_combat_lb12")

	        m_lv_lb1:setString("Lv." .. itemData.cards_info.lv .. "/" .. itemData.cards_info.level_max);
	        m_lv_lb12:setString("Lv." .. itemData.cards_info.lv .. "/" .. itemData.cards_info.level_max);
	        local c_id = itemData.cards_info.c_id
	        local character_detail_cfg = getConfig(game_config_field.character_detail);
	        local heroCfg = character_detail_cfg:getNodeWithKey(tostring(c_id));
	        local name_after = game_util:getCardName(itemData.cards_info,heroCfg)
	        m_name_lb1:setString(name_after);
	        m_name_lb12:setString(name_after);
	        m_combat_lb1:setString(itemData.combat)
	        m_combat_lb12:setString(itemData.combat)
	        local m_icon_node = ccbNode:nodeForName("m_icon_node")
        	local cardIcon = game_util:createCardIconByCid(c_id,itemData.cards_info)
			if cardIcon and m_icon_node then
				local viewSize = m_icon_node:getContentSize()
				m_icon_node:addChild(cardIcon)
				cardIcon:setScale(0.7)
				cardIcon:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5 - 1.2))
			end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
    	if eventType == "ended" then
    		if self.m_selectIndex ~= index+1 then

	        end
    	end
    end

    return TableViewHelper:create(params);
end


function game_teamRaid_apply_detail:refreshCCBInfoByData( ccbNode,data )
	-- body
	local data = data or {}
	if data.uid and data.cardsData and ccbNode then
		local cardsData = data.cardsData
	    local m_icon_node = ccbNode:nodeForName("m_icon_node")
        local m_item_di = ccbNode:spriteForName("m_item_di")
        local m_name_lb12 = ccbNode:labelTTFForName("m_name_lb12")
        local m_name_lb1 = ccbNode:labelTTFForName("m_name_lb1")
        local m_lv_lb1 = ccbNode:labelTTFForName("m_lv_lb1")
        local m_lv_lb12 = ccbNode:labelTTFForName("m_lv_lb12")
        local m_combat_lb1 = ccbNode:labelTTFForName("m_combat_lb1")
        local m_combat_lb12 = ccbNode:labelTTFForName("m_combat_lb12")
        m_icon_node:removeAllChildrenWithCleanup(true)
        local role = cardsData[1].role or 1
        local name = data.name or ""
        local guild_name = data.guild_name or ""
        local server = data.server or ""
        m_name_lb1:setString(name)
        m_name_lb12:setString(name)
        m_server_lb12:setString(server)
        m_server_lb1:setString(server)
        m_guild_lb12:setString(guild_name)
        m_guild_lb1:setString(guild_name)
        local roleIcon = game_util:createPlayerRoleGardenIconByRoleId(role)
		if roleIcon then
			local viewSize = m_icon_node:getContentSize()
			m_icon_node:addChild(roleIcon)
			roleIcon:setScale(0.6)
			roleIcon:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
		end
		for i=1,5 do
			local itemData = cardsData[i]
			local icon_node = ccbNode:nodeForName("m_icon_sp" .. i)
			if itemData then
				icon_node:setVisible(true)
				local c_id = itemData.cards_info.c_id
				local cardIcon = game_util:createCardIconByCid(c_id,itemData.cards_info)
				if cardIcon and icon_node then
					local viewSize = icon_node:getContentSize()
					icon_node:addChild(cardIcon)
					cardIcon:setScale(0.7)
					cardIcon:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5 - 1.2))
				end
			else
				icon_node:setVisible(false)
			end
		end
	end
end


function game_teamRaid_apply_detail:refreshTableVIew(  )
	-- body
    local tempTab = self:getTeamList()
    self.m_team_list = util.table_copy(tempTab)
	local tempTableView = self:createTableView(self.m_team_list_node:getContentSize(),tempTab)
	self.m_team_list_node:removeAllChildrenWithCleanup(true)
	if tempTableView then
		self.m_team_list_node:addChild(tempTableView)
	end

end



function game_teamRaid_apply_detail:getTeamList(  )
    -- body
    local tempTab = {}
    return self.m_tGameData.cardsData
    -- for k,v in pairs(self.m_tGameData.c) do
    -- 	tempTab[#tempTab+1] = {}
    -- 	local cardsData = {}
    -- 	for m,n in pairs(v.card_data) do
    -- 		cardsData[#cardsData+1] = n
    -- 		cardsData[#cardsData].key = m
    -- 	end
    -- 	tempTab[#tempTab].cardsData = cardsData
    -- 	tempTab[#tempTab].uid = k
    -- 	tempTab[#tempTab].guild_name = v.guild_name
    -- 	tempTab[#tempTab].name = v.name
    -- 	tempTab[#tempTab].server = v.server
    -- end
    -- return tempTab
end

function game_teamRaid_apply_detail:checkValueInTable( value, tempTable )
    -- body
    for k,v in pairs(tempTable) do
        if value == v.uid then
            return true,k
        end
    end
    return false
end

function game_teamRaid_apply_detail:refreshUi(  )
	-- body
    self:refreshTableVIew()
    self.m_title1:setString(self.m_tGameData.name .. "Thẻ của")
    self.m_title2:setString(self.m_tGameData.name .. "Thẻ của")
end



function game_teamRaid_apply_detail:init( t_params )
	-- body
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res_add.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
	self.m_selectTab = {}
    self.m_selectIndex = 1

    self.m_selectPage = 1
    self.m_tGameData = t_params.gameData
    self.m_page = t_params.page
    self.m_raid_id = t_params.raid_id
    -- if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
    --    local data = t_params.gameData:getNodeWithKey("data")
    --    self.m_tGameData = json.decode(data:getFormatBuffer())
    -- end
    -- cclog2(self.m_tGameData)
    self.m_team_list = {}
    self.m_callback = t_params.callback
    self.m_EnterFlag = t_params.enterFlag or 2
    self.m_EnterType = t_params.enterType or ""
end

function game_teamRaid_apply_detail:create( t_params )
	-- body
	self:init(t_params)
	local pop = self:createUi()
	self:refreshUi()
	return pop
end

return game_teamRaid_apply_detail