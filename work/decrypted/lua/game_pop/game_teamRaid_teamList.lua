-- 团队副本   分组
local game_teamRaid_teamList = {
	m_selectPage = nil,
    m_down_btn = nil,
    m_refresh_btn = nil,
    m_up_btn = nil,
    m_cards_list_node = nil,
    m_team_list_node = nil,
    m_root_layer = nil,
    m_role_node = nil,
    m_card_node = nil,
    m_team_number = nil,
    m_ccbNode = nil,
    m_selectItem = nil,
    m_selectIndex = nil,
    m_showCurPage = nil,
    m_team_list = nil,
    m_tGameData = nil,
    m_EnterFlag = nil,
    m_EnterType = nil,
}

function game_teamRaid_teamList:destroy(  )
	-- body
    cclog("  --------------  game_teamRaid_teamList  destroy  -----------------  ")
    self.m_selectPage = nil;
    self.m_down_btn = nil;
    self.m_refresh_btn = nil;
    self.m_up_btn = nil;
    self.m_cards_list_node = nil;
    self.m_team_list_node = nil;
    self.m_root_layer = nil;
    self.m_role_node = nil;
    self.m_card_node = nil;
    self.m_team_number = nil;
    self.m_ccbNode = nil;
    self.m_selectItem = nil;
    self.m_selectIndex = nil;
    self.m_showCurPage = nil;
    self.m_team_list = nil;
    self.m_tGameData = nil;
    self.m_EnterFlag = nil;
    self.m_EnterType = nil;
end

function game_teamRaid_teamList:back(  )
    game_scene:removePopByName("game_teamRaid_teamList")
end

function game_teamRaid_teamList:createUi(  ) -- test_touch
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then       -- 返回
        	self:back()
    	elseif btnTag == 2 then   -- 刷新
            local function responseMethod( tag, gameData )
                if gameData then
                    self.m_selectIndex = 1
                   local data = gameData:getNodeWithKey("data")
                   self.m_tGameData = json.decode(data:getFormatBuffer())
                   self:refreshUi()
                end
            end
            local params = {}
            params.type = self.m_EnterFlag
            params.page = self.m_selectPage
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_search_raid_index"), http_request_method.GET, params,"team_raid_search_raid_index")
    	elseif btnTag == 3 then   -- 上一页
            if self.m_selectPage == 1 then
                game_util:addMoveTips({text = "Bạn đã đến Trang đầu rồi!",new_color = ccc3(123,255,255)})
                return
            end
            local function responseMethod( tag, gameData )
                if gameData then
                    self.m_selectIndex = 1
                   local data = gameData:getNodeWithKey("data")
                   self.m_tGameData = json.decode(data:getFormatBuffer())
                   self:refreshUi()
                end
            end
            self.m_selectPage = self.m_selectPage - 1
            local params = {}
            params.type = self.m_EnterFlag
            params.page = self.m_selectPage
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_search_raid_index"), http_request_method.GET, params,"team_raid_search_raid_index")
        elseif btnTag == 4 then   -- 下一页
            local max_page = self.m_tGameData.max_page or 1
            max_page = (max_page == 0) and 1 or max_page
            if self.m_selectPage == max_page then
                game_util:addMoveTips({text = "Bạn đã đến Trang cuối rồi!",new_color = ccc3(123,255,255)})
                return
            end
            self.m_selectPage = self.m_selectPage + 1
            local function responseMethod( tag, gameData )
                if gameData then
                   self.m_selectIndex = 1
                   local data = gameData:getNodeWithKey("data")
                   self.m_tGameData = json.decode(data:getFormatBuffer())
                   self:refreshUi()
                end
            end
            local params = {}
            params.type = self.m_EnterFlag
            params.page = self.m_selectPage
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_search_raid_index"), http_request_method.GET, params,"team_raid_search_raid_index")
    	elseif btnTag == 5 then
            -- team_raid_search_one_raid
            local function responseMethod( tag, gameData )
                if gameData then
                   self.m_selectIndex = 1
                   local data = gameData:getNodeWithKey("data")
                   self.m_tGameData = json.decode(data:getFormatBuffer())
                   self:refreshUi()
                end
            end
            local params = {}
            local notice = self.m_editBox:getText()
            params.type = self.m_EnterFlag
            params.owner_uid = util.url_encode(notice)
            self.m_notice = util.url_encode(notice)
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_search_one_raid"), http_request_method.GET, params,"team_raid_search_one_raid")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_teamRaid_list_pop.ccbi");


    self.m_down_btn = ccbNode:controlButtonForName("m_down_btn")
    self.m_refresh_btn = ccbNode:controlButtonForName("m_refresh_btn")
    self.m_up_btn = ccbNode:controlButtonForName("m_up_btn")
    self.m_down_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
	self.m_refresh_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
	self.m_up_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);


    self.m_cards_list_node = ccbNode:nodeForName("m_cards_list_node")
    self.m_team_list_node = ccbNode:nodeForName("m_team_list_node")

    self.m_edit_node = ccbNode:nodeForName("m_edit_node")
    self.m_edit_ok = ccbNode:controlButtonForName("m_edit_ok")
    self.m_edit_ok:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
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
    m_close_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-2,true);
    m_close_layer:setTouchEnabled(true);

    self.m_role_node = ccbNode:nodeForName("m_role_node")
    self.m_card_node = ccbNode:nodeForName("m_card_node")

    self.m_team_number = ccbNode:labelTTFForName("m_team_number")
    self.m_ccbNode = ccbNode;
    return ccbNode
end


function game_teamRaid_teamList:createTableView( viewSize ,tempTable )
	-- body
	local function onMainBtnClick( target,event )
	    local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("press   select    is   " .. btnTag)
        local data = self.m_team_list[btnTag]
        local function responseMethod( tag, gameData )
            if gameData then
                game_scene:enterGameUi("game_teamRaid_signUp_scene",{gameData = gameData,enterFlag = self.m_EnterFlag,enterType = "joinPrivate",raid_id = data.id,page = self.m_selectPage,selectIndex = btnTag})
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_cards_for_team"), http_request_method.GET, nil,"team_raid_cards_for_team")
    end
	local tempTable = tempTable or {}
	local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 3; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tempTable
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 3
    params.showPoint = false
    params.canMoveFlag = false
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
            ccbNode:openCCBFile("ccb/ui_teamRaid_team_list.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setScale(0.9)
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
    		local itemData = tempTable[index+1]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_icon_node = ccbNode:nodeForName("m_icon_node")
            local m_item_di = ccbNode:spriteForName("m_item_di")
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            local m_number_lb = ccbNode:labelTTFForName("m_number_lb")
            local m_apply_btn = ccbNode:controlButtonForName("m_apply_btn")
            m_apply_btn:setTag(index+1)
            game_util:setCCControlButtonEnabled(m_apply_btn,self.m_CanJoinIn)
            m_apply_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4)
            m_name_label:setString(itemData.name)
            local count = game_util:getTableLen(itemData.player_data)
            m_number_lb:setString( count.."/25")
            local fileName = "ui_teamRaid_team_kuang1.png"
            if self.m_selectIndex == index+1 then
				fileName = "ui_teamRaid_team_kuang2.png"
                self.m_selectItem = m_item_di
            else
            end

            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName))
            if tempSpriteFrame then
                m_item_di:setDisplayFrame(tempSpriteFrame)
            end

            local ownerData = itemData.player_data[itemData.owner] or {}
            -- cclog2(ownerData,"ownerData-=------")
            -- cclog2(itemData,"itemData-=------")
            local role = ownerData.role or 1 
            local roleIcon = game_util:createPlayerRoleGardenIconByRoleId(role)
            if roleIcon then
                local viewSize = m_icon_node:getContentSize()
                m_icon_node:addChild(roleIcon)
                roleIcon:setScale(0.5)
                roleIcon:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
            end

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
    	if eventType == "ended" then
    		if self.m_selectIndex ~= index+1 then
	    		local m_item_di = ccbNode:spriteForName("m_item_di")
	        	local itemData = tempTable[index+1]
	        	local tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_teamRaid_team_kuang1.png")
	        	local tempSpriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_teamRaid_team_kuang2.png")
	        	if self.m_selectItem and tempSpriteFrame1 then
					self.m_selectItem:setDisplayFrame(tempSpriteFrame1)
	        	end
	        	if m_item_di and tempSpriteFrame2 then
	        		m_item_di:setDisplayFrame(tempSpriteFrame2)
	        		self.m_selectItem = m_item_di
	        	end
	        	self.m_selectIndex = index+1
	        	self:refreshRightInfo(self.m_selectIndex)
	        end
    	end
    end
    params.pageChangedCallFunc = function (m_nTotalPage,m_nCurPage)
        self.m_showCurPage = m_nCurPage
    end
    return TableViewHelper:createGallery3(params,kCCScrollViewDirectionVertical);
end

function game_teamRaid_teamList:createTableView2( viewSize ,tempTable )
	-- body

	local tempTable = tempTable or {}
	local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 3; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = #tempTable
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 3
    params.showPoint = false
    params.canMoveFlag = false
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_teamRaid_team_list.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setScale(0.9)
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
    		local itemData = tempTable[index+1]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            ccbNode:removeAllChildrenWithCleanup(true)
            local c_id = itemData.cards_info.c_id
            local cardIcon = game_util:createCardIconByCid(c_id,itemData.cards_info)
			if cardIcon then
				local viewSize = ccbNode:getContentSize()
				ccbNode:addChild(cardIcon)
				cardIcon:setScale(0.6)
				cardIcon:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5 - 1.2))
			end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
    	if eventType == "ended" then

    	end
    end

    return TableViewHelper:create(params);
end

function game_teamRaid_teamList:refreshTableVIew(  )
	-- body
    local tempTab = self:getTeamList()
    self.m_team_list = util.table_copy(tempTab)
	local tempTableView = self:createTableView(self.m_team_list_node:getContentSize(),tempTab)
	self.m_team_list_node:removeAllChildrenWithCleanup(true)
	if tempTableView then
		self.m_team_list_node:addChild(tempTableView)
	end
	self:refreshRightInfo(self.m_selectIndex)

end

function game_teamRaid_teamList:refreshRightInfo( index )
	-- body
	self.m_role_node:removeAllChildrenWithCleanup(true)
	self.m_card_node:removeAllChildrenWithCleanup(true)
	local teamData = self.m_team_list[index]
    self.m_team_number:setString("Thành viên(0/25)")
    self.m_cards_list_node:removeAllChildrenWithCleanup(true)
    if teamData then
    	local ownerData = teamData.player_data[teamData.owner] or {}
    	local role = ownerData.role or 1 
    	local roleIcon = game_util:createPlayerRoleGardenIconByRoleId(role)
    	if roleIcon then
    		local viewSize = self.m_role_node:getContentSize()
    		self.m_role_node:addChild(roleIcon)
    		roleIcon:setScale(0.6)
    		roleIcon:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
    	end
    	local c_id = ownerData.cards_info.c_id
    	local cardIcon = game_util:createCardIconByCid(c_id,ownerData.cards_info)
    	if cardIcon then
    		local viewSize = self.m_card_node:getContentSize()
    		self.m_card_node:addChild(cardIcon)
    		cardIcon:setScale(0.6)
    		cardIcon:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5 - 1.2))
    	end
    	local tempCardsTab = {}
    	for k,v in pairs(teamData.player_data) do
    		tempCardsTab[#tempCardsTab+1] = v
    	end
        local count = #tempCardsTab
        self.m_team_number:setString("Thành viên(".. count .."/25)")
    	local tempTableView = self:createTableView2(self.m_cards_list_node:getContentSize(),tempCardsTab)
    	self.m_cards_list_node:removeAllChildrenWithCleanup(true)
    	if tempTableView then
    		self.m_cards_list_node:addChild(tempTableView)
    	end
    end
end



function game_teamRaid_teamList:refreshBtn( flag )
	-- body
    local flag = flag or 0
    local function onBtnCilck( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("press button tag is ", btnTag)
        self.m_selectScreenType = btnTag
        self:refreshBtn(btnTag)

    end
    for i=1,4 do
        local fileName1 = "ui_teamRaid_sec_iconbg2.png"
        local fileName2 = "ui_teamRaid_sec_iconbg2.png"
        local attrNode = self.m_ccbNode:spriteForName("m_attr_node" .. i)
        local occuNode = self.m_ccbNode:spriteForName("m_occu_node" .. i)
        if attr_tab[i] and PUBLIC_ABILITY_TABLE["ability_" .. attr_tab[i]] then
            attrNode:setVisible(true)
            attrNode:removeAllChildrenWithCleanup(true)
            local attrIcon = CCSprite:createWithSpriteFrameName(PUBLIC_ABILITY_TABLE["ability_" .. attr_tab[i]].icon);
            if attrIcon then
                attrNode:addChild(attrIcon)
                local viewSize = attrNode:getContentSize()
                attrIcon:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition( attrIcon:getContentSize().width * 0.5, attrIcon:getContentSize().height * 0.5 )
                button:setOpacity(0)
                button:setScale(0.4)
                button:setZoomOnTouchDown(false);
                button:setTag(attr_tab[i])
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
                attrIcon:addChild(button)
            end
            if attr_tab[i] == flag then
                fileName1 = "ui_teamRaid_sec_iconbg22.png"
            end
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName1))
            if tempSpriteFrame then
                attrNode:setDisplayFrame(tempSpriteFrame)
            end
        else
            attrNode:setVisible(false)
        end

        if occu_tab[i] then
            local occuIcon = CCSprite:createWithSpriteFrameName("public_ocupation" .. i-1 .. ".png");
            occuNode:setVisible(true)
            if occuIcon then
                occuNode:addChild(occuIcon)
                local viewSize = occuNode:getContentSize()
                occuIcon:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition( occuIcon:getContentSize().width * 0.5, occuIcon:getContentSize().height * 0.5 )
                button:setOpacity(0)
                button:setScale(0.4)
                button:setZoomOnTouchDown(false);
                button:setTag(occu_tab[i])
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
                occuIcon:addChild(button)
            end
            if occu_tab[i] == flag then
                fileName2 = "ui_teamRaid_sec_iconbg22.png"
            end
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName2))
            if tempSpriteFrame then
                occuNode:setDisplayFrame(tempSpriteFrame)
            end
        else
            occuNode:setVisible(false)
        end
    end
    self:refreshTableVIew()
end

function game_teamRaid_teamList:refreshTeamIcon(  )
    -- body
    for i=1,5 do
        local m_team_icon = self.m_ccbNode:nodeForName("m_team_icon" .. i)
        m_team_icon:removeAllChildrenWithCleanup(true)
        if self.m_selectTab[i] then
            local itemData = self.m_selectTab[i]
            local icon = game_util:createCardIconByCid(itemData.cards_info.c_id,itemData.cards_info)
            if icon then
                icon:setScale(0.5)
                m_team_icon:addChild(icon)
                local viewSize = m_team_icon:getContentSize()
                icon:setPosition(ccp(viewSize.width*0.5 + 1, viewSize.height*0.5 - 1))
            end
        end
    end
end

function game_teamRaid_teamList:getTeamList(  )
    -- body
    local tempTab = {}
    local uid = game_data:getUserStatusDataByKey("uid")
    -- cclog2(self.m_tGameData.raid_data,"self.m_tGameData.raid_data-=------")
    -- cclog2(self.m_tGameData.raid_list_sort,"self.m_tGameData.raid_list_sort-=------")
    for i=1,#self.m_tGameData.raid_list_sort do
    --             tempTab[i] = self.m_tGameData.raid_data[tostring(self.m_tGameData.raid_list_sort[i])]
    --             tempTab[i].id = self.m_tGameData.raid_list_sort[i]
    --
       -- for k,v in pairs(self.m_tGameData.raid_data) do
            -- if  k == self.m_tGameData.raid_list_sort[#tempTab+1] then
            local k = self.m_tGameData.raid_list_sort[i]
            -- cclog2(k,"k-=---------")
                tempTab[i] = self.m_tGameData.raid_data[k]
                tempTab[i].id = k
            -- end
        -- end
   end
-- cclog2(tempTab,"tempTab-=---------")

    
    return tempTab
end

function game_teamRaid_teamList:checkValueInTable( value, tempTable )
    -- body
    for k,v in pairs(tempTable) do
        if value == v.uid then
            return true,k
        end
    end
    return false
end


function game_teamRaid_teamList:createEditBox(  )
    -- body
        self.m_edit_node:removeAllChildrenWithCleanup(true)
        local function editBoxTextEventHandle(strEventName,pSender)
        end
        self.m_editBox = game_util:createEditBox({bgFileName = "ui_teamRaid_first_sel.png",scriptEditBoxHandler=editBoxTextEventHandle,size = self.m_edit_node:getContentSize(),placeHolder="输入团长UID",maxLength = 20,fontSize = 10,placeholderFontColor = ccc3(200,200,200),fontColor = ccc3(255,255,255),inputMode = kEditBoxInputModeAny});
        self.m_editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 7);
        self.m_editBox:setFont(TYPE_FACE_TABLE.Arial_BoldMT,8)
        self.m_editBox:setInputFlag(kEditBoxInputFlagInitialCapsAllCharacters);
        self.m_edit_node:addChild(self.m_editBox);
        if self.m_notice then
            self.m_editBox:setText(self.m_notice)
        end
end


function game_teamRaid_teamList:refreshUi(  )
	-- body
    self:refreshTableVIew()
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
    self:createEditBox()
end



function game_teamRaid_teamList:init( t_params )
	-- body
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res_add.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
	self.m_selectTab = {}
    self.m_selectIndex = t_params.selectIndex or 1

    self.m_selectPage =  t_params.page or 1

    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
       local data = t_params.gameData:getNodeWithKey("data")
       self.m_tGameData = json.decode(data:getFormatBuffer())
    end
    local maxPage = self.m_tGameData.max_page or 1
    self.m_team_list = {}

    self.m_EnterFlag = t_params.enterFlag or 1
    self.m_EnterType = t_params.enterType or ""
    self.m_CanJoinIn = t_params.canJoinIn
end

function game_teamRaid_teamList:create( t_params )
	-- body
	self:init(t_params)
	local pop = self:createUi()
	self:refreshUi()
	return pop
end

return game_teamRaid_teamList