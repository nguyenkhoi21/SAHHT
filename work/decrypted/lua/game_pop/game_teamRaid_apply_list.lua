--  团队副本    申请列表
local game_teamRaid_apply_list = {
	
}

function game_teamRaid_apply_list:destroy(  )
	-- body

end

function game_teamRaid_apply_list:back(  )

    local function responseMethod( tag, gameData )
        if gameData then
            if self.m_callfunc then
                self.m_callfunc(gameData)
                game_scene:removePopByName("game_teamRaid_apply_list")
            end
        end
    end
    local params = {}
    params.raid_id = self.m_raid_id
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_persion_raid_index"), http_request_method.GET, params,"team_raid_persion_raid_index")
end

function game_teamRaid_apply_list:createUi(  ) -- test_touch
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then       -- 返回
        	self:back()
    	elseif btnTag == 2 then   -- 刷新

    	elseif btnTag == 3 then   -- 上一页
            if self.m_selectPage == 1 then
                game_util:addMoveTips({text = "Bạn đã đến Trang đầu rồi!",new_color = ccc3(123,255,255)})
                return
            end
            local function responseMethod( tag, gameData )
                if gameData then
                   self.m_selectIndex = 1
                   local data = t_params.gameData:getNodeWithKey("data")
                   self.m_tGameData = json.decode(data:getFormatBuffer())
                   self:refreshUi()
                end
            end
            self.m_selectPage = self.m_selectPage - 1
            local params = {}
            params.raid_id = self.m_tGameData.raid_id
            params.page = self.m_selectPage
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_apply_index"), http_request_method.GET, params,"team_raid_apply_index")
        elseif btnTag == 4 then   -- 下一页
            local max_page = self.m_tGameData.max_page or 1
            max_page = (max_page == 0) and 1
            if self.m_selectPage == max_page then
                game_util:addMoveTips({text = "Bạn đã đến Trang cuối rồi!",new_color = ccc3(123,255,255)})
                return
            end
            local function responseMethod( tag, gameData )
                if gameData then
                    self.m_selectIndex = 1
                    local data = t_params.gameData:getNodeWithKey("data")
                    self.m_tGameData = json.decode(data:getFormatBuffer())
                    self:refreshUi()
                end
            end
            self.m_selectPage = self.m_selectPage + 1
            local params = {}
            params.raid_id = self.m_tGameData.raid_id
            params.page = self.m_selectPage
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_apply_index"), http_request_method.GET, params,"team_raid_apply_index")

    	end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_teamRaid_applyList_pop.ccbi");

    local m_btn_close = ccbNode:controlButtonForName("m_btn_close")
    m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);

    self.m_down_btn = ccbNode:controlButtonForName("m_down_btn")
    self.m_up_btn = ccbNode:controlButtonForName("m_up_btn")
    self.m_down_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
	self.m_up_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);

	self.m_page_lb1 = ccbNode:labelTTFForName("m_page_lb1")
	self.m_page_lb2 = ccbNode:labelTTFForName("m_page_lb2")
    self.m_team_list_node = ccbNode:nodeForName("m_team_list_node")

    self.m_touchLyaer = ccbNode:layerForName("m_touchLyaer")

	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
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
    m_close_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-5,true);
    m_close_layer:setTouchEnabled(true);

    self.m_role_node = ccbNode:nodeForName("m_role_node")
    self.m_card_node = ccbNode:nodeForName("m_card_node")

    self.m_team_number = ccbNode:labelTTFForName("m_team_number")

    self.m_ccbNode = ccbNode;
    return ccbNode
end


function game_teamRaid_apply_list:createTableView( viewSize ,tempTable )
	-- body
	local function onMainBtnClick( target,event )
	    local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("press   select    is   " .. btnTag)
        if btnTag > 100 then  -- 拒绝
        	local index = btnTag - 100
        	local data = self.m_team_list[index]
        	        -- local data = self.m_team_list[btnTag]
	        local function responseMethod( tag, gameData )
	            if gameData then
	            	self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
	            	self:refreshUi()
	                -- game_scene:enterGameUi("game_teamRaid_signUp_scene",{gameData = gameData,enterFlag = 1,enterType = "joinPrivate",raid_id = data.id})
	            end
	        end
	        local params = {}
	        params.page = self.m_selectPage
	        params.player_id = data.uid
	        params.raid_id = self.m_raid_id
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_refuse_apply"), http_request_method.GET, params,"team_raid_refuse_apply")
        else  -- 详情
        	local index = btnTag 
        	local data = self.m_team_list[index]
        	if data then
        		local callback = function ( gameData )
        			if gameData then
						self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
		            	self:refreshUi()
        			end
        		end
        		game_scene:addPop("game_teamRaid_apply_detail",{gameData = data,page = self.m_selectPage,raid_id = self.m_raid_id,callback = callback})
        	end
        end
        -- local data = self.m_team_list[btnTag]
        -- local function responseMethod( tag, gameData )
        --     if gameData then
        --         game_scene:enterGameUi("game_teamRaid_signUp_scene",{gameData = gameData,enterFlag = 1,enterType = "joinPrivate",raid_id = data.id})
        --     end
        -- end
        -- local params = {}
        -- params.type = 2
        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_cards_for_team"), http_request_method.GET, nil,"team_raid_cards_for_team")
    end
	local tempTable = tempTable or {}
	local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tempTable
    -- params.totalItem = 7
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 3
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
            ccbNode:openCCBFile("ccb/ui_teamRaid_apply_item1.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            -- ccbNode:setScale(0.9)
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
    		local itemData = tempTable[index+1]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")

            local m_detail_btn = ccbNode:controlButtonForName("m_detail_btn")
            local m_Refused_btn = ccbNode:controlButtonForName("m_Refused_btn")
            m_detail_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
            m_Refused_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
            m_detail_btn:setTag(index+1)
            m_Refused_btn:setTag(index+101)
            self:refreshCCBInfoByData(ccbNode,itemData)

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
    	if eventType == "ended" then
    		if self.m_selectIndex ~= index+1 then
	    -- 		local m_item_di = ccbNode:spriteForName("m_item_di")
	    --     	local itemData = tempTable[index+1]
	    --     	local tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_teamRaid_team_kuang1.png")
	    --     	local tempSpriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_teamRaid_team_kuang2.png")
	    --     	if self.m_selectItem and tempSpriteFrame1 then
					-- self.m_selectItem:setDisplayFrame(tempSpriteFrame1)
	    --     	end
	    --     	if m_item_di and tempSpriteFrame2 then
	    --     		m_item_di:setDisplayFrame(tempSpriteFrame2)
	    --     		self.m_selectItem = m_item_di
	    --     	end
	    --     	self.m_selectIndex = index+1
	    --     	self:refreshRightInfo(self.m_selectIndex)
	        end
    	end
    end

    return TableViewHelper:create(params);
end


function game_teamRaid_apply_list:refreshCCBInfoByData( ccbNode,data )
	-- body
	local data = data or {}
	if data.uid and data.cardsData and ccbNode then
		local cardsData = data.cardsData
	    local m_icon_node = ccbNode:nodeForName("m_icon_node")
        local m_item_di = ccbNode:spriteForName("m_item_di")
        local m_name_lb12 = ccbNode:labelTTFForName("m_name_lb12")
        local m_name_lb1 = ccbNode:labelTTFForName("m_name_lb1")
        local m_server_lb12 = ccbNode:labelTTFForName("m_server_lb12")
        local m_server_lb1 = ccbNode:labelTTFForName("m_server_lb1")
        local m_guild_lb12 = ccbNode:labelTTFForName("m_guild_lb12")
        local m_guild_lb1 = ccbNode:labelTTFForName("m_guild_lb1")
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


function game_teamRaid_apply_list:refreshTableVIew(  )
	-- body
    local tempTab = self:getTeamList()
    self.m_team_list = util.table_copy(tempTab)
	local tempTableView = self:createTableView(self.m_team_list_node:getContentSize(),tempTab)
	self.m_team_list_node:removeAllChildrenWithCleanup(true)
	if tempTableView then
		self.m_team_list_node:addChild(tempTableView)
	end
    local began = (self.m_selectPage-1)*10+1
    local endCount = (self.m_selectPage-1)*10+(game_util:getTableLen(self.m_team_list))
    if endCount == 0 then
        began = 0
    end
    self.m_page_lb1:setString(began .. "-" .. endCount)
    self.m_page_lb2:setString(began .. "-" .. endCount)
    local maxPage = self.m_tGameData.max_page or 1
    maxPage = (maxPage == 0) and 1 or maxPage
    if self.m_selectPage == 1 then
        game_util:setCCControlButtonEnabled(self.m_down_btn,false)
    else
        game_util:setCCControlButtonEnabled(self.m_down_btn,true)
    end
    if self.m_selectPage == maxPage then
        game_util:setCCControlButtonEnabled(self.m_up_btn,false)
    else
        game_util:setCCControlButtonEnabled(self.m_up_btn,true)
    end
end



function game_teamRaid_apply_list:getTeamList(  )
    -- body
    local tempTab = {}
    for k,v in pairs(self.m_tGameData.apply_dict) do
    	tempTab[#tempTab+1] = {}
    	local cardsData = {}
    	for m,n in pairs(v.card_data) do
    		cardsData[#cardsData+1] = n
    		cardsData[#cardsData].key = m
    	end
    	tempTab[#tempTab].cardsData = cardsData
    	tempTab[#tempTab].uid = k
    	tempTab[#tempTab].guild_name = v.guild_name
    	tempTab[#tempTab].name = v.name
    	tempTab[#tempTab].server = v.server
    end
    return tempTab
end

function game_teamRaid_apply_list:checkValueInTable( value, tempTable )
    -- body
    for k,v in pairs(tempTable) do
        if value == v.uid then
            return true,k
        end
    end
    return false
end

function game_teamRaid_apply_list:refreshUi(  )
	-- body
    self:refreshTableVIew()
end



function game_teamRaid_apply_list:init( t_params )
	-- body
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res_add.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
	self.m_selectTab = {}
    self.m_selectIndex = 1

    self.m_selectPage = 1

    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
       local data = t_params.gameData:getNodeWithKey("data")
       self.m_tGameData = json.decode(data:getFormatBuffer())
    end
    cclog2(self.m_tGameData)
    self.m_team_list = {}
    self.m_raid_id = t_params.raid_id
    self.m_EnterFlag = t_params.enterFlag or 2
    self.m_EnterType = t_params.enterType or ""
    self.m_callfunc = t_params.callfunc
end

function game_teamRaid_apply_list:create( t_params )
	-- body
	self:init(t_params)
	local pop = self:createUi()
	self:refreshUi()
	return pop
end

return game_teamRaid_apply_list