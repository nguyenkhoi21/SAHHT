--星系霸主   小行星
local ui_guild_star_bigStar = {
    m_star_node = nil,
    m_list_node = nil,
    m_add_effect_node = nil,
    m_owner_IconNode = nil,
    m_owner_name = nil,
    m_lb_name = nil,
    m_lb_guildname = nil,
    m_img_node = nil,
    m_guild_count = nil,
    m_score_lb = nil,
    m_battleType_sp = nil,
    m_ccbNode = nil,
    m_scrollView = nil,
    m_tGameData = nil,
    m_pos = nil,
}


function ui_guild_star_bigStar:destroy()
    cclog(" ----------- ui_guild_star_bigStar destroy -------------- ")
    self.m_star_node = nil;
    self.m_list_node = nil;
    self.m_add_effect_node = nil;
    self.m_owner_IconNode = nil;
    self.m_owner_name = nil;
    self.m_lb_name = nil;
    self.m_lb_guildname = nil;
    self.m_img_node = nil;
    self.m_guild_count = nil;
    self.m_score_lb = nil;
    self.m_battleType_sp = nil;
    self.m_ccbNode = nil;
    self.m_scrollView = nil;
    self.m_tGameData = nil;
    self.m_pos = nil;
end

function ui_guild_star_bigStar:back(  )
	local function responseMethod( tag,gameData )
		if gameData then
			game_scene:enterGameUi("ui_guild_star_main",{gameData = gameData})
		end
	end
	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_index"), http_request_method.GET, nil,"guild_robbery_index")
end

function ui_guild_star_bigStar:createUi(  )
	local ccbNode = luaCCBNode:create();
	local function onButtonClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
        	self:back()
        elseif btnTag == 2 then
            game_scene:addPop("game_godfield_public_detail",{enterType= 200})
        elseif btnTag == 3 then
                local function responseMethod( tag,gameData )
                    if gameData then
                        game_scene:addPop("ui_guild_star_battle_log",{gameData = gameData})
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_get_logs"), http_request_method.GET, nil,"guild_robbery_get_logs")
        else
            local pos = self.m_scrollView:getContentOffset()
            game_data:setGuildStarPos(pos,1)
            local posData = self.m_tGameData.pos_datas[tostring(1)]
            if posData.uid == "" then
                local function responseMethod( tag,gameData )
                    if gameData then
                        local has_battle = gameData:getNodeWithKey("data"):getNodeWithKey("has_battle"):toStr()
                        if has_battle == "1" then
                            game_scene:enterGameUi("ui_guild_star_battle_scene",{gameData = gameData,enterType = index,posX = posX})
                        else
                            game_scene:enterGameUi("ui_guild_star_bigStar",{gameData = gameData,enterType = index,pos = pos})
                        end
                    end
                end
                local params = {}
                params.mountain_id = 1
                params.pos = 1
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_battle"), http_request_method.GET, params,"guild_robbery_battle")
            else
                local function responseMethod( tag,gameData )
                    if gameData then
                        game_scene:addPop("ui_guild_star_Owner_pop",{gameData = gameData,enterType = 1,mountain_id = 1,pos = 1})
                    end
                end
                local params = {}
                params.mountain_id = 1
                params.pos = 1
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_pos_info"), http_request_method.GET, params,"guild_robbery_pos_info")
            end
        end
	end
	ccbNode:registerFunctionWithFuncName( "onMainBtnClick",onButtonClick );
	ccbNode:openCCBFile("ccb/ui_guild_Star_bigStar.ccbi");
	ccbNode:controlButtonForName("m_back_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY);

	self.m_star_node = ccbNode:nodeForName("m_star_node")
	local m_touchLayer = ccbNode:layerForName("m_touchLayer")
	self.m_list_node = ccbNode:nodeForName("m_list_node")
    local m_owner_btn = ccbNode:controlButtonForName("m_owner_btn")
    local m_detail_btn = ccbNode:controlButtonForName("m_detail_btn")
    local m_paper_btn = ccbNode:controlButtonForName("m_paper_btn")
    m_owner_btn:setOpacity(0)
    self.m_add_effect_node = ccbNode:nodeForName("m_add_effect_node")
    self.m_owner_IconNode = ccbNode:nodeForName("m_owner_IconNode")
    self.m_owner_name = ccbNode:labelTTFForName("m_owner_name")

    self.m_lb_name = ccbNode:labelTTFForName("m_lb_name")
    self.m_lb_guildname = ccbNode:labelTTFForName("m_lb_guildname")
    self.m_img_node = ccbNode:nodeForName("m_img_node")
    self.m_guild_count = ccbNode:labelTTFForName("m_guild_count")
    self.m_score_lb = ccbNode:labelTTFForName("m_score_lb")
    self.m_battleType_sp = ccbNode:spriteForName("m_battleType_sp")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            realPos = m_touchLayer:getParent():convertToNodeSpace(ccp(x,y)); 
            if m_touchLayer:boundingBox():containsPoint(realPos) then
            	self.m_touchFlag = true
            else
            	self.m_touchFlag = false
            end
        end
    end
    m_touchLayer:registerScriptTouchHandler(onTouch,false,0)
    m_touchLayer:setTouchEnabled(true)

	self.m_ccbNode = ccbNode
	return ccbNode
end


function ui_guild_star_bigStar:createStarList(boardSize)
	-- body
	local posTab = {{1},{2,3},{4,5,6},{7,8,9,10},{11,12,13,14,15},{16,17,18,19,20,21}}

	local size = {310,230,160,100,40}
	local size2 = {60,60,60,80,80}

	local function refreshCallFun1(ccbNode,data,index)
		local fileName = "ui_guildStar_StarSp1.png"
		if index == 3 then
			fileName = "ui_guildStar_StarSp2.png"
		end
        local m_spr = ccbNode:spriteForName("bg_sp")
		local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName))
        if tempSpriteFrame then
            m_spr:setDisplayFrame(tempSpriteFrame)
        end
	end

	local function refreshCallFun2(ccbNode,data,index)
		
	end

	local function Mainclick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if not self.m_touchFlag then
        	return
        end
        local pos = self.m_scrollView:getContentOffset()
        game_data:setGuildStarPos(pos,1)
        local posData = self.m_tGameData.pos_datas[tostring(btnTag)]
        if posData.uid == "" then
            local function responseMethod( tag,gameData )
                if gameData then
                    local has_battle = gameData:getNodeWithKey("data"):getNodeWithKey("has_battle"):toStr()
                    if has_battle == "1" then
                        game_scene:enterGameUi("ui_guild_star_battle_scene",{gameData = gameData,enterType = index,posX = posX})
                    else
                        game_scene:enterGameUi("ui_guild_star_bigStar",{gameData = gameData,enterType = index,pos = pos})
                    end
                end
            end
            local params = {}
            params.mountain_id = 1
            params.pos = btnTag
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_battle"), http_request_method.GET, params,"guild_robbery_battle")
        else
            local function responseMethod( tag,gameData )
                if gameData then
                    game_scene:addPop("ui_guild_star_Owner_pop",{gameData = gameData,enterType = 1,mountain_id = 1,pos = btnTag})
                end
            end
            local params = {}
            params.mountain_id = 1
            params.pos = btnTag
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_pos_info"), http_request_method.GET, params,"guild_robbery_pos_info")
        end

	end

	local tab = {
		{scale = 1,name= "Tầng 1",isShow = true,ccbName = "ccb/ui_guild_star_bigStar_smallItem1.ccbi",count = 2,posTab = {0.3,0.7},refreshCallFun = refreshCallFun1},
		{scale = 1,name= "Tầng 2",isShow = true,ccbName = "ccb/ui_guild_star_bigStar_smallItem2.ccbi",count = 3,posTab = {0.2,0.5,0.8},},
		{scale = 0.9,name= "Tầng 3",isShow = true,ccbName = "ccb/ui_guild_star_bigStar_smallItem2.ccbi",count = 4,posTab = {0.3,0.7},},
		{scale = 0.7,name= "Tầng 4",isShow = false,ccbName = "ccb/ui_guild_star_bigStar_smallItem2.ccbi",count = 5,posTab = {0.3,0.7},},
		{scale = 0.6,name= "Tầng 5",isShow = false,ccbName = "ccb/ui_guild_star_bigStar_smallItem2.ccbi",count = 6,posTab = {0.3,0.7},},
	}
	local scrollView = CCScrollView:create(boardSize)
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:getContainer():removeAllChildrenWithCleanup(true)
    scrollView:setTouchEnabled(true)
    scrollView:setTouchPriority(0)
    for i=1,5 do
    	local itemData = tab[i]
    	local ccb = luaCCBNode:create();
    	ccb:openCCBFile("ccb/ui_guild_star_bigStarItem.ccbi");
    	scrollView:addChild(ccb)
    	ccb:setPosition(ccp(0,size[i]))
    	local m_title_lb1 = ccb:labelTTFForName("m_title_lb1")
    	local m_title_lb2 = ccb:labelTTFForName("m_title_lb2")
    	m_title_lb1:setString(itemData.name)
    	m_title_lb2:setString(itemData.name)
    	local m_listNode = ccb:nodeForName("m_listNode")
    	m_listNode:removeAllChildrenWithCleanup(true)
    	local width = boardSize.width - 60
    	local itemWidth = width/(itemData.count*2)
    	for j=1,itemData.count do
            local index = posTab[i+1][j]
            local showData = self.m_tGameData.pos_datas[tostring(index)]
    		local itemCCB = luaCCBNode:create();
			itemCCB:registerFunctionWithFuncName( "Mainclick",Mainclick );
    		itemCCB:openCCBFile(itemData.ccbName);
    		itemCCB:setPosition(ccp(itemWidth*(j*2-1),0))
    		m_listNode:addChild(itemCCB)
    		itemCCB:setScale(itemData.scale)
    		local m_item_btn = itemCCB:controlButtonForName("m_item_btn")
    		m_item_btn:setOpacity(0)
    		m_item_btn:setTag(index)
    		local m_lb_name1 = itemCCB:labelTTFForName("m_lb_name1")
    		-- m_lb_name1:setVisible(itemData.isShow)
            m_lb_name1:setString(showData.name)
    		if itemData.refreshCallFun then
    			itemData.refreshCallFun(itemCCB,itemData,index)
    		end
            local m_icon_node = itemCCB:nodeForName("m_icon_node")
            m_icon_node:removeAllChildrenWithCleanup(true)
            if showData.uid ~= "" then
                local roleIcon = game_util:createPlayerRoleGardenIconByRoleId(showData.role or 1)
                if roleIcon then
                    m_icon_node:addChild(roleIcon)
                    roleIcon:setScale(0.85)
                    roleIcon:setPosition(ccp(0,0))
                end
            end 

    	end
    end

    scrollView:setContentSize(CCSizeMake(boardSize.width, 360))
    if self.m_pos then
        scrollView:setContentOffset(self.m_pos, false)
        
    else
        scrollView:setContentOffset(ccp(0, boardSize.height - 360), false)
    end
    scrollView:setPosition(ccp(0, 0))

    return scrollView
end


function ui_guild_star_bigStar:refreshAddEffect()
    local add_effect = self.m_tGameData.add_effect
    local addType = {}
    local addNum = {}
    for k,v in pairs(add_effect) do
        addType[#addType+1] = PUBLIC_ABILITY_NAME_TABLE[k] and PUBLIC_ABILITY_NAME_TABLE[k].name or nil
        addNum[#addNum+1] = v
    end
    -- addType = addType .. (addNum < 0 and "-" or "+") .. addNum
    self.m_add_effect_node:removeAllChildrenWithCleanup(true)
    local boardSize = self.m_add_effect_node:getContentSize()
    local scrollView = CCScrollView:create(boardSize)
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:getContainer():removeAllChildrenWithCleanup(true)
    scrollView:setTouchEnabled(true)
    scrollView:setTouchPriority(0)
    local width_half = boardSize.height/6
    local posY = 0
    -- for i=1,#addType do
    for i=1,#addType do
        local str = addType[i] .. (addNum[i] < 0 and " " or " +") .. addNum[i] .. "%"
        local tempLb = game_util:createLabelTTF({text = str,color = ccc3(120,255,255),fontSize = 9})
        if i%2 ~= 0 then
            tempLb:setPosition(ccp(10,posY+width_half))
        else
            tempLb:setPosition(ccp(80,posY+width_half))
            posY = posY+width_half*2
        end
        scrollView:addChild(tempLb)
    end
    if #addType%2 ~= 0 then
        posY= posY+width_half*2
    end
    scrollView:setContentSize(CCSizeMake(boardSize.width, posY+5))
    scrollView:setContentOffset(ccp(0, boardSize.height - posY-5), true)
    scrollView:setPosition(ccp(0, 0))
    self.m_add_effect_node:addChild(scrollView)
end
function ui_guild_star_bigStar:refreshUi(  )
    local fileName2 = "ui_guildStar_main_title1.png"
    if self.m_tGameData.can_battle == 1 then
        fileName2 = "ui_guildStar_main_title2.png"
    end

    local tempSpriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName2))
    if tempSpriteFrame2 then
        self.m_battleType_sp:setDisplayFrame(tempSpriteFrame2)
    end

    self.m_guild_count:setString(self.m_tGameData.guild_people_num)
    self.m_score_lb:setString("Điểm cộng:".. self.m_tGameData.add_point_rate.. "%")

	local scrollView = self:createStarList(self.m_list_node:getContentSize())
	self.m_list_node:removeAllChildrenWithCleanup(true)
	if scrollView then
        self.m_list_node:addChild(scrollView) 
        self.m_scrollView = scrollView
    end
    self:refreshAddEffect()


    local posData = self.m_tGameData.pos_datas["1"]
    self.m_owner_IconNode:removeAllChildrenWithCleanup(true)
    if posData.uid ~= "" then
        local roleIcon = game_util:createPlayerRoleGardenIconByRoleId(posData.role or 1)
        if roleIcon then
            self.m_owner_IconNode:addChild(roleIcon)
        end
         self.m_owner_name:setString(posData.name)

        -- self.m_lb_name:setString(posData.name)
        -- self.m_lb_guildname:setString(posData.guild_name)
        -- self.m_img_node:removeAllChildrenWithCleanup(true)

        -- local roleId = posData.role
        -- local role_detail_cfg = getConfig(game_config_field.role_detail);
        -- local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
        -- if itemCfg then
        --     animName = itemCfg:getNodeWithKey("animation"):toStr();
        -- else
        --     animName = "role_soldier";
        -- end
        -- local tempAnim = game_util:createPlayerRoleAnimNew(animName,1)
        -- tempAnim:setScale(0.8)
        -- self.m_img_node:addChild(tempAnim)

    end

    local myData = self.m_tGameData.my_info or self.m_tGameData.pos_datas["1"]
    -- self.m_owner_IconNode:removeAllChildrenWithCleanup(true)
    if myData.uid ~= "" then
        -- local roleIcon = game_util:createPlayerRoleGardenIconByRoleId(posData.role or 1)
        -- if roleIcon then
        --     self.m_owner_IconNode:addChild(roleIcon)
        -- end
        --  self.m_owner_name:setString(posData.name)

        self.m_lb_name:setString(myData.name)
        self.m_lb_guildname:setString(myData.guild_name)
        self.m_img_node:removeAllChildrenWithCleanup(true)

        local roleId = myData.role
        local role_detail_cfg = getConfig(game_config_field.role_detail);
        local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
        if itemCfg then
            animName = itemCfg:getNodeWithKey("animation"):toStr();
        else
            animName = "role_soldier";
        end
        local tempAnim = game_util:createPlayerRoleAnimNew(animName,1)
        tempAnim:setScale(0.8)
        self.m_img_node:addChild(tempAnim)

    end
end

function ui_guild_star_bigStar:init( t_params )
	-- body
	t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
    end
    self.m_pos = t_params.pos
end

function ui_guild_star_bigStar:create( t_params )
	local scene = CCScene:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene 
end

return ui_guild_star_bigStar