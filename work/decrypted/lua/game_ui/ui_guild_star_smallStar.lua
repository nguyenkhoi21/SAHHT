--星系霸主   小行星
local ui_guild_star_smallStar = {
	m_sel_UseItem = nil,
	m_guild_count = nil,
	m_score_lb = nil,
	m_add_node = nil,
	m_battleType_sp = nil,
	m_timer_label = nil,
	m_buff_label = nil,
	m_title_sp = nil,
	m_star_node = nil,
	m_ccbNode = nil,
	m_thanos_item = nil,
	m_enterType = nil,
	m_tGameData = nil,
	m_Posx = nil,
	m_sel_UseItem = nil,
	m_openShopType = nil,
	m_notice = nil,
}


function ui_guild_star_smallStar:destroy()
	cclog("---------------- ui_guild_star_smallStar destroy -----------------")
	self.m_sel_UseItem = nil;
	self.m_guild_count = nil;
	self.m_score_lb = nil;
	self.m_add_node = nil;
	self.m_battleType_sp = nil;
	self.m_timer_label = nil;
	self.m_buff_label = nil;
	self.m_title_sp = nil;
	self.m_star_node = nil;
	self.m_ccbNode = nil;
	self.m_thanos_item = nil;
	self.m_enterType = nil;
	self.m_tGameData = nil;
	self.m_Posx = nil;
	self.m_sel_UseItem = nil;
	self.m_openShopType = nil;
	self.m_notice = nil;
end

function ui_guild_star_smallStar:back(  )
	local function responseMethod( tag,gameData )
		if gameData then
			game_scene:enterGameUi("ui_guild_star_main",{gameData = gameData})
		end
	end
	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_index"), http_request_method.GET, nil,"guild_robbery_index")
end

function ui_guild_star_smallStar:createUi(  )
	local ccbNode = luaCCBNode:create();
	local function onButtonClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local thanos_item = getConfig(game_config_field.thanos_items)
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
        elseif btnTag == 100 then--
        	if self.m_sel_UseItem ~= 0 then
        		game_util:addMoveTips({text = "Vị trí này không thể dùng đạo cụ!"})
        		return
        	end
        	if self.m_tGameData.can_battle ~= 1 then
        		game_util:addMoveTips({text = "Giai đoạn này không thể đánh vị trí này"})
        		return
        	end
        	local posData = self.m_tGameData.pos_datas["100"]
        	if self.m_tGameData.pos_datas["100"].uid == "" then
		        local posX,index = game_data:getGuildStarPos()
                local function responseMethod( tag,gameData )
                    if gameData then
	                    local data = gameData:getNodeWithKey("data")
	                    local find_shop = data:getNodeWithKey("find_shop"):toStr()
	                    if find_shop == "true" then
	                        local shop_id_list = data:getNodeWithKey("shop_id_list")
	                        local shop_type = data:getNodeWithKey("shop_type"):toStr()
	                        game_data:setGuildStarShopMsg(shop_id_list,shop_type)
	                    else
	                        game_data:setGuildStarShopMsg(nil,nil)
	                    end
	                   	local has_battle = gameData:getNodeWithKey("data"):getNodeWithKey("has_battle"):toStr()
	                    if has_battle == "1" then
	                		game_scene:enterGameUi("ui_guild_star_battle_scene",{gameData = gameData,enterType = index,posX = posX})
	                    else
	                        game_scene:enterGameUi("ui_guild_star_smallStar",{gameData = gameData,enterType = index,posX = posX})
	                    end
	                end
                end
	        	local params = {}
				params.mountain_id = self.m_enterType
				params.pos = 100
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_battle"), http_request_method.GET, params,"guild_robbery_battle")
        	else
				local function responseMethod( tag,gameData )
					if gameData then
	        			game_scene:addPop("ui_guild_star_Owner_pop",{gameData = gameData,enterType = self.m_enterType})
					end
				end
				local params = {}
				params.mountain_id = self.m_enterType
				params.pos = 100
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_pos_info"), http_request_method.GET, params,"guild_robbery_pos_info")
        	end
        elseif btnTag > 100 and btnTag < 200 then
			if self.m_sel_UseItem ~= 0 then
				local itemData = thanos_item:getNodeWithKey(tostring(self.m_sel_UseItem))
				itemData = json.decode(itemData:getFormatBuffer())
			    local t_params = 
	            {
	                title = "提示",
	                okBtnCallBack = function(target,event)
	                    local function responseMethod( tag,gameData )
		                    if gameData then
		                    	local posX,index = game_data:getGuildStarPos()
							    local function responseMethod( tag,gameData )
							        if gameData then
							            game_scene:enterGameUi("ui_guild_star_smallStar",{gameData = gameData,enterType = index,posX = posX,notice = "道具已生效！"})
							        end
							    end
							    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_go_mountain"), http_request_method.GET, { mountain_id= index},"guild_robbery_go_mountain")
			                end
		                end
			        	local params = {}
						params.item_id = self.m_sel_UseItem
						params.mountain_id = self.m_enterType
						params.pos_id = btnTag - 100
						network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_user_item"), http_request_method.GET, params,"guild_robbery_user_item")
	                    require("game_ui.game_pop_up_box").close(); 
	                    -- util_system:openUrlOutside(updataUrl);
	                end,   --可缺省
	                cancelBtnCallBack = function(target,event) cclog("rightBtnCallBack") require("game_ui.game_pop_up_box").close(); end,   --可缺省
	                okBtnText = "OK",       --可缺省
	                cancelBtnText = "Hủy",
	                text = "Xác nhận dùng" .. itemData.name .. "đạo cụ này sẽ" .. itemData.msg,      --可缺省
	                onlyOneBtn = true,          --可缺省
	            }
	            require("game_ui.game_pop_up_box").show(t_params);
        		return
        	end
			local function responseMethod( tag,gameData )
				if gameData then
					game_scene:addPop("ui_guild_star_info_pop",{gameData = gameData,mountain_id = self.m_enterType,pos = btnTag - 100})
				end
			end
			local params = {}
			params.mountain_id = self.m_enterType
			params.pos = btnTag - 100
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_pos_info"), http_request_method.GET, params,"guild_robbery_pos_info")
        elseif btnTag == 1001 then
			local itemData = thanos_item:getNodeWithKey(tostring(1))
			itemData = json.decode(itemData:getFormatBuffer())

        	if self.m_sel_UseItem ~= 1 then
        		self.m_sel_UseItem = 1
        		game_util:addMoveTips({text = "Bạn đã chọn" .. itemData.name .. ",\nđạo cụ này sẽ" .. itemData.msg ..",\nhãy chọn đối tượng dùng! (Ấn lần nữa để hủy)"})
        	else
        		self.m_sel_UseItem = 0
        		game_util:addMoveTips({text = "Hủy dùng"})
        	end
			self:refreshItem(true)
        elseif btnTag == 1002 then
        	local thanos_item = getConfig(game_config_field.thanos_items)
			local itemData = thanos_item:getNodeWithKey(tostring(2))
			itemData = json.decode(itemData:getFormatBuffer())
        	if self.m_sel_UseItem ~= 2 then
        		self.m_sel_UseItem = 2
        		game_util:addMoveTips({text = "Bạn đã chọn" .. itemData.name .. ",\nđạo cụ này sẽ" .. itemData.msg ..",\nhãy chọn đối tượng dùng! (Ấn lần nữa để hủy)"})
        	else
        		self.m_sel_UseItem = 0
        		game_util:addMoveTips({text = "Hủy dùng"})
        	end
			self:refreshItem(true)
        elseif btnTag == 1003 then
        	local thanos_item = getConfig(game_config_field.thanos_items)
			local itemData = thanos_item:getNodeWithKey(tostring(3))
			itemData = json.decode(itemData:getFormatBuffer())

		    local t_params = 
            {
                title = "提示",
                okBtnCallBack = function(target,event)
                    local function responseMethod( tag,gameData )
	                    if gameData then
	                    	local posX,index = game_data:getGuildStarPos()
						    local function responseMethod( tag,gameData )
						        if gameData then
						        	game_util:addMoveTips({text=="Đạo cụ đã có hiệu lực!"})
						            game_scene:enterGameUi("ui_guild_star_smallStar",{gameData = gameData,enterType = index,posX = posX,notice = "Đạo cụ đã có hiệu lực!"})
						        end
						    end
							network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_go_mountain"), http_request_method.GET, { mountain_id= index},"guild_robbery_go_mountain")
		                end
	                end
		        	local params = {}
					params.item_id = 3
					params.mountain_id = self.m_enterType
					network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_user_item"), http_request_method.GET, params,"guild_robbery_user_item")
                    require("game_ui.game_pop_up_box").close(); 
                    -- util_system:openUrlOutside(updataUrl);
                end,   --可缺省
                cancelBtnCallBack = function(target,event) cclog("rightBtnCallBack") require("game_ui.game_pop_up_box").close(); end,   --可缺省
                okBtnText = "OK",       --可缺省
                cancelBtnText = "Hủy",
                text = "Xác nhận dùng" .. itemData.name .. "đạo cụ này sẽ" .. itemData.msg,      --可缺省
                onlyOneBtn = true,          --可缺省
            }
            require("game_ui.game_pop_up_box").show(t_params);
        end
	end
	ccbNode:registerFunctionWithFuncName( "onMainBtnClick",onButtonClick );
	ccbNode:openCCBFile("ccb/ui_guild_Star_smallStar.ccbi");
	ccbNode:controlButtonForName("m_back_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY);
	ccbNode:controlButtonForName("m_detail_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY);
	ccbNode:controlButtonForName("m_zhanbao_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY);
	ccbNode:controlButtonForName("m_item_btn1"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-3);
	ccbNode:controlButtonForName("m_item_btn2"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-3);
	ccbNode:controlButtonForName("m_item_btn3"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-3);
	self.m_guild_count = ccbNode:labelTTFForName("m_guild_count")
	self.m_score_lb = ccbNode:labelTTFForName("m_score_lb")
	self.m_add_node = ccbNode:nodeForName("m_add_node")
	self.m_battleType_sp = ccbNode:spriteForName("m_battleType_sp")
	self.m_timer_label = ccbNode:labelTTFForName("m_timer_label")
	self.m_buff_label = ccbNode:labelTTFForName("m_buff_label")
	for i=0,60 do
		local btn = ccbNode:controlButtonForName("m_button" .. i)
		local sp = ccbNode:spriteForName("m_sp" .. i)
		if btn then
			btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY);
			btn:setOpacity(0)
			btn:setTag(i+100)
			game_util:setCCControlButtonTitle(btn,"")
		end
		if sp then
			self:addFlashLightAnimForNode(sp)
		end
	end
	self.m_title_sp = ccbNode:spriteForName("m_title_sp")
	self.m_star_node = ccbNode:nodeForName("m_star_node")
	local m_root_layer = ccbNode:layerForName("m_root_layer")
	self:initTouchLayer(m_root_layer)
	self.m_ccbNode = ccbNode
	return ccbNode
end



function ui_guild_star_smallStar:initTouchLayer(touchLayer)
	local beginX = 0
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            local realPos = touchLayer:getParent():convertToNodeSpace(ccp(x,y));
            if touchLayer:boundingBox():containsPoint(realPos) then
            	beginX = x
                return true;
            end
            return false;
        elseif eventType == "moved" then
        	local moveX = x - beginX
        	beginX = x
        	local node_X,_ = self.m_star_node:getPosition()
        	if not (node_X > 0 and moveX > 0 ) and not (node_X < -650 and moveX < 0 ) then
        		local pos = node_X+(moveX)*0.5
        		pos = pos > 0 and 0 or pos
        		pos = pos < -650 and -650 or pos
        		self.m_star_node:setPositionX(pos)
        	end
        elseif eventType == "ended" then
        	local posX = self.m_star_node:getPositionX()
        	game_data:setGuildStarPos(posX,self.m_enterType) 
        end
    end
    touchLayer:registerScriptTouchHandler(onTouch,false,0,true);
    touchLayer:setTouchEnabled(true);
end


function ui_guild_star_smallStar:refreshUi(  )
	-- body
    local pos_datas = self.m_tGameData.pos_datas or {}
    local guild_id = game_data:getUserStatusDataByKey("association_id") or ""
	for i=1,60 do
		local itemData = pos_datas[tostring(i)]
		if itemData then
			local sp = self.m_ccbNode:spriteForName("m_sp" .. i)
			sp:removeAllChildrenWithCleanup(true)
			if itemData.role ~= "" then
				local roleIcon = game_util:createPlayerRoleGardenIconByRoleId(itemData.role or 1)
				if roleIcon then
					local buff_type1 = 0
					local buff_type2 = 0
					if itemData.reduce_times > 0 then
						buff_type1 = 1
					end
					if itemData.protect_time > 0 then
						buff_type2 = 1
					end

					local file = "ui_guildStar_planet_headbg.png"
					if guild_id ~= itemData.guild_id then
						file = "ui_guildStar_planet_headbg_red.png"
					end
					local di = CCSprite:createWithSpriteFrameName(file);
					if di then
						di:setAnchorPoint(ccp(0.5,0.5))
						di:setPosition(ccp(27,30))
						di:setOpacity(150)
						di:setScale(0.6)
						sp:addChild(di)
						self:addFlashLightAnimForNode(di)
						di:removeAllChildrenWithCleanup(true)
						local diSize = di:getContentSize()
						if buff_type1 ~= 0 then
							local item = json.decode(self.m_thanos_item:getNodeWithKey("2"):getFormatBuffer())
							local icon = game_util:getRewardByItemTable(item.item[1])
							if icon then
								di:addChild(icon)
								icon:setScale(0.5)
								local iconSize = icon:getContentSize()
								icon:setAnchorPoint(ccp(0.5,0.5))
								icon:setPosition(ccp(10,15))
							end
						end
						if buff_type2 ~= 0 then
							local item = json.decode(self.m_thanos_item:getNodeWithKey("1"):getFormatBuffer())
							local icon = game_util:getRewardByItemTable(item.item[1])
							if icon then
								di:addChild(icon)
								icon:setScale(0.5)
								local iconSize = icon:getContentSize()
								icon:setAnchorPoint(ccp(0.5,0.5))
								icon:setPosition(ccp(diSize.width-10,15))
							end
						end
						local tempLb = game_util:createLabelTTF({text = itemData.name,color = ccc3(120,255,255),fontSize = 15})
						if tempLb then
							tempLb:setAnchorPoint(ccp(0.5,0.5))
							tempLb:setPosition(ccp(40,5))
							di:addChild(tempLb)
						end
					end
					sp:addChild(roleIcon)
					roleIcon:setAnchorPoint(ccp(0.5,0.5))
					roleIcon:setScale(0.65)
					roleIcon:setPosition(ccp(27,30))
				end
			end
		end
	end

	local ownerData = pos_datas["100"]
	local m_node0 = self.m_ccbNode:nodeForName("m_node0")
	local m_sp0 = self.m_ccbNode:spriteForName("m_sp0")
	m_sp0:removeAllChildrenWithCleanup(true)
	if ownerData and ownerData.uid ~= "" then
		local roleIcon = game_util:createPlayerRoleGardenIconByRoleId(ownerData.role or 1)
		if roleIcon then
			local file = "ui_guildStar_planet_headbg.png"
			if guild_id ~= ownerData.guild_id then
				file = "ui_guildStar_planet_headbg_red.png"
			end
			local di = CCSprite:createWithSpriteFrameName(file);

			if di then
				di:setAnchorPoint(ccp(0.5,0.5))
				di:setPosition(ccp(44,45))
				di:setScale(0.8)
				di:setOpacity(150)
				m_sp0:addChild(di)
				self:addFlashLightAnimForNode(di)
				local tempLb = game_util:createLabelTTF({text = ownerData.name,color = ccc3(120,255,255),fontSize = 15})
				if tempLb then
					di:removeAllChildrenWithCleanup(true)
					tempLb:setAnchorPoint(ccp(0.5,0.5))
					tempLb:setPosition(ccp(40,0))
					di:addChild(tempLb)
				end
			end
			m_sp0:addChild(roleIcon)
			roleIcon:setAnchorPoint(ccp(0.5,0.5))
			roleIcon:setScale(0.75)
			roleIcon:setPosition(ccp(44,45))
		end

	end
	if self.m_Posx then
		self.m_star_node:setPositionX(self.m_Posx)
	end
   	local posX = self.m_star_node:getPositionX()
	game_data:setGuildStarPos(posX,self.m_enterType) 
	self:refreshPosMsg()
	self:refreshItem(true)
	self:refreshAddEffect()
	self.m_guild_count:setString(self.m_tGameData.guild_people_num)
	self.m_score_lb:setString("Điểm cộng:".. self.m_tGameData.add_point_rate.. "%")
	self:refreshTimerLabel()

	if self.m_openShopType then
		game_scene:addPop("ui_guild_star_shop_pop")
	end

	if self.m_notice then
		game_util:addMoveTips({text = self.m_notice})
	end

	local add_buff_times = self.m_tGameData.add_buff_times or 0
	local item1 = json.decode(self.m_thanos_item:getNodeWithKey("3"):getFormatBuffer())
    local str1 = item1.effect
    str1 = string.gsub(str1,"x",tostring(math.floor(add_buff_times*item1.value)));

	if add_buff_times > 0 then
		self.m_buff_label:setVisible(true)
		self.m_buff_label:setString(str1)
	else
		self.m_buff_label:setVisible(false)
	end
end


function ui_guild_star_smallStar:refreshPosMsg()
	local index = 1
	local teams = self.m_tGameData.teams
	for i=1,3 do
		local temp = teams[i] or teams[tostring(i)]
		if temp.mountain ~= 0 then
			local tempLb = self.m_ccbNode:labelTTFForName("m_pos_lb" .. index)
			tempLb:setString("Đội thứ" .. index .. " ở" .. GUILD_STAR_BTN_ICON[temp.mountain].name)
			index = index + 1
		end
	end
	if index < 4 then
		for j = index,3 do
			self.m_ccbNode:labelTTFForName("m_pos_lb" .. j):setString("")
		end
	end
end

function ui_guild_star_smallStar:addFlashLightAnimForNode(tempNode)
    local animArr = CCArray:create();
    animArr:addObject(CCFadeTo:create(1,80))
    animArr:addObject(CCFadeTo:create(1,180))
    tempNode:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
end

function ui_guild_star_smallStar:refreshAddEffect()
	local add_effect = self.m_tGameData.add_effect
	local addType = ""
	local addNum = 0
	for k,v in pairs(add_effect) do
		addType = PUBLIC_ABILITY_NAME_TABLE[k] and PUBLIC_ABILITY_NAME_TABLE[k].name or nil
		addNum = v
	end
	if addType == "" or not addType then
		addType = "Bonus không thuộc tính"
	else
		addType = addType .. (addNum < 0 and " " or " +") .. addNum .."%"
	end
	self.m_add_node:removeAllChildrenWithCleanup(true)
	local boardSize = self.m_add_node:getContentSize()
	local tempLb = game_util:createLabelTTF({text = addType,color = ccc3(120,255,255),fontSize = 9})
	tempLb:setPosition(ccp(boardSize.width*0.5,boardSize.height*0.5))
    self.m_add_node:addChild(tempLb)

end

function ui_guild_star_smallStar:refreshTimerLabel()
	-- body
	local starCfg = GUILD_STAR_BTN_ICON[self.m_enterType]
	local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(starCfg.title))
    if tempSpriteFrame then
        self.m_title_sp:setDisplayFrame(tempSpriteFrame)
    end

    local fileName2 = "ui_guildStar_main_title1.png"
	if self.m_tGameData.can_battle == 1 then
		fileName2 = "ui_guildStar_main_title2.png"
	end

	local tempSpriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName2))
    if tempSpriteFrame2 then
        self.m_battleType_sp:setDisplayFrame(tempSpriteFrame2)
    end
	local function timeEndFunc(label,type)
		local function responseMethod( tag,gameData )
			if gameData then
				game_scene:enterGameUi("ui_guild_star_main",{gameData = gameData})
			end
		end
		network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_index"), http_request_method.GET, nil,"guild_robbery_index")
    end
	self.m_timer_label:setString("")
	self.m_timer_label:setVisible(true)
	local countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8);
    countdownLabel:setPosition(ccp(0,0))
    countdownLabel:setAnchorPoint(ccp(0,0.5))
    if self.m_timer_label ~= nil then
        self.m_timer_label:removeAllChildrenWithCleanup(true)
    end
    self.m_timer_label:addChild(countdownLabel)
    if self.m_tGameData.expire then
    	countdownLabel:setTime(self.m_tGameData.expire + 1);
    end
    countdownLabel:setVisible(false)
end

function ui_guild_star_smallStar:refreshItem( flag )
	-- body
	for i=1,3 do
		local thanos_item = getConfig(game_config_field.thanos_items)
		local icon_node = self.m_ccbNode:nodeForName("icon_node" .. i)
		icon_node:removeAllChildrenWithCleanup(true)
		if flag then
			local itemData = thanos_item:getNodeWithKey(tostring(i))
			itemData = json.decode(itemData:getFormatBuffer())
			local count = game_data:getItemCountByCid(itemData.item[1][2])
			local icon,name,_ = game_util:getRewardByItemTable(itemData.item[1]);
            if icon then
                icon:setScale(0.6)
                icon_node:addChild(icon);
                local label = game_util:createLabelTTF({text = name.. "×" ..count,color = ccc3(120,255,255),fontSize = 10})
            	label:setAnchorPoint(ccp(1,1))
            	local iconSize = icon:getContentSize()
            	label:setPosition(ccp(iconSize.width,0))
            	icon:addChild(label)
            end
		end
		if self.m_sel_UseItem == i then
			local label = game_util:createLabelTTF({text = "Hủy",color = ccc3(120,255,255),fontSize = 9})
			if label then
				icon_node:addChild(label)
			end
		end
	end
end

function ui_guild_star_smallStar:init( t_params )
	-- body
    self.m_thanos_item = getConfig(game_config_field.thanos_items)

	self.m_enterType = t_params.enterType or 1
	if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
	end
	self.m_Posx = t_params.posX
	self.m_sel_UseItem = 0

	self.m_openShopType = t_params.openShopType
	self.m_notice = t_params.notice
end

function ui_guild_star_smallStar:create( t_params )
	local scene = CCScene:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene 
end

return ui_guild_star_smallStar