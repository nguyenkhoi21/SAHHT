local ui_chrismas_snowman_map_pop = {
	m_root_layer = nil,
	m_btn_back = nil,
	m_maplist_node = nil,
	m_tGameData = nil,
	my_snow_photo = nil,
	m_achievement = nil,
	callback = nil,
	m_snow_photo = nil,
} 

function ui_chrismas_snowman_map_pop:destroy( )
	self.m_root_layer = nil;
	self.m_btn_back = nil;
	self.m_maplist_node = nil;
	self.m_tGameData = nil;
	self.my_snow_photo = nil;
	self.m_achievement = nil;
	self.callback = nil;
	self.m_snow_photo = nil;
end



function ui_chrismas_snowman_map_pop:back()
    game_scene:removePopByName("ui_chrismas_snowman_map_pop")
	if self.callback then
		self.callback()
	end
        	
end



function ui_chrismas_snowman_map_pop:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		-- cclog2(btnTag,"btnTag ----------========")
		if btnTag == 1 then
			self:back()
		else
			-- cclog(btnTag)
		end
	end
	local ccbNode =  luaCCBNode:create();
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_Chrismas_map_pop.ccbi")
	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	self.m_btn_back = ccbNode:controlButtonForName("btn_back")
	self.m_btn_back:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
	self.m_maplist_node = ccbNode:nodeForName("m_maplist_node")
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    self.m_root_layer:setTouchEnabled(true);
	return ccbNode

end



function ui_chrismas_snowman_map_pop:createTableView(viewSize)
	-- local item_data = item_data
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		-- cclog2(btnTag,"btnTag ----------========")
		if btnTag < 10 then
			local data = self.m_snow_photo[tostring(btnTag)]
			local itemData = data.out_item
			game_util:lookItemDetal(itemData[1])
		else
			local index = btnTag - 10
			if not self.m_achievement[index] then
				game_util:addMoveTips({text = "Đã nhận thành tựu hình này, ko thể nhận nữa"})
			elseif self.m_achievement[index] == 1 then
				game_util:addMoveTips({text = "Chưa hoàn thành hình này, ko thể nhận"})
			elseif self.m_achievement[index] == 0 then
				function responseMethod(tag,gameData)
			        if gameData and tolua.type(gameData) == "util_json" then
				        local data = gameData:getNodeWithKey("data")
				        local gamedata = json.decode(data:getFormatBuffer()) or {};
				        self.m_achievement = self:refreshAchievement(gamedata.achievement,gamedata.received_achieve)
				        self.m_tGameData = gamedata
				        game_util:rewardTipsByDataTable(self.m_tGameData.reward)
				    end
			    end
			    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("snow_get_photo_reward"), http_request_method.GET, {id = btnTag - 10},"snow_get_photo_reward")	
			end
		end
	end
    local params = {}
    params.viewSize = viewSize
    params.column = 1
    params.row = 3
    params.direction = kCCScrollViewDirectionVertical
    params.totalItem = game_util:getTableLen(self.m_snow_photo)
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row)
    params.newCell = function( tableView,index )
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell=CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
            ccbNode:openCCBFile("ccb/ui_chrismas_map_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(0,itemSize.height/2))
            cell:addChild(ccbNode,101,101)
        end
        if cell then
        	local data = self.m_snow_photo[tostring(index + 1)]
        	-- cclog2(data.need_item)
			local count = game_util:getTableLen(data.need_item)
        	local ccbNode = tolua.cast(cell:getChildByTag(101),"luaCCBNode")
        	local m_bag = ccbNode:spriteForName("m_bag")
        	if data.icon then
	        	local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(data.icon .. ".png"))
				if tempSpriteFrame then
					m_bag:setDisplayFrame(tempSpriteFrame)
				end
			end
			local add_sp = {}
			local snow_node = {}
			local bag_btn = ccbNode:controlButtonForName("bag_btn")
			local m_okbtn = ccbNode:controlButtonForName("m_okbtn")
			m_okbtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-7)
			bag_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-7)
			m_okbtn:setTag(index + 11)
			bag_btn:setTag(index + 1)
			bag_btn:setOpacity(0)
			for i=1,5 do
				local s_node = ccbNode:nodeForName("m_node" .. i)
				if s_node then snow_node[i] = s_node end 
				local add = ccbNode:spriteForName("sprite_" .. i)
				if add then 
					add_sp[i] = add 
				end
			end
			local sarrow = ccbNode:spriteForName("sarrow")

			-- if count == 5 then cclog("----------->>>>>>>>>>>>>") end
			local x = 240/(count*2)

			for i=1,count do
				snow_node[i]:setPositionX(x*(i*2-1))
				snow_node[i]:removeAllChildrenWithCleanup(true)
				local snow_index =  data.need_item[i]
				local snow_sp = CCSprite:createWithSpriteFrameName("snowman".. snow_index .. "_4.png")
				if self.my_snow_photo[tostring(index+1)][tostring(snow_index)] == 0 then
					snow_sp:setColor(ccc3(50,50,50))
				end
				snow_sp:setAnchorPoint(ccp(0.5,0.5))
				snow_sp:setPosition(ccp(0,0))
				snow_sp:setScale(0.3)
				snow_node[i]:addChild(snow_sp)
				if add_sp[i] then
					add_sp[i]:setPositionX(x*(i*2))
				end
			end
			local sarrow_x = x*(count-0.5)
			for i= 1,5 do
				snow_node[i]:setVisible(true)
				if add_sp[i] then
					add_sp[i]:setVisible(true)
				end
			end
			if count < 5 then
				for i= count+1,5 do
					snow_node[i]:setVisible(false)
					if add_sp[i-1] then
						add_sp[i-1]:setVisible(false)
					end
				end
			end
        end
        return cell
    end
    params.itemOnClick=function (eventType,index,item )
    end
    return TableViewHelper:create(params)
end


function ui_chrismas_snowman_map_pop:refreshItem(parentNode,index)
	local ccbNode = parentNode
	local add_sp = {}
	local snow_node = {}
	for i=1,5 do
		local s_node = ccbNode:nodeForName("m_node" .. i)
		if s_node then snow_node[i] = s_node end 
		local add = ccbNode:spriteForName("sprite_" .. i)
		if add then add_sp[i] = s_node end
	end
	local sarrow = ccbNode:spriteForName("sarrow")
	local data = self.m_snow_photo[tostring(index + 1)]
	local count = game_util:getTableLen(data.need_item)
	-- cclog2(count*2)
	local x = 300/(count)
	for i=1,count do
		snow_node[i]:setPositionX(x*(i-1))
		add_sp[i]:setPositionX(x*(i-1)+50)
	end
	if count < 5 then
		for i= count + 1,5 do
			snow_node[i]:setVisible(false)
			if add_sp[i] then
				add_sp[i]:setVisible(false)
			end
		end
	end

end


function ui_chrismas_snowman_map_pop:refreshAchievement(achievement,received_achieve)
	local ach = {}
	local r_ach = {}
	for i=1,game_util:getTableLen(received_achieve) do
		local v = received_achieve[tostring(i)] or received_achieve[i]
		r_ach[v] = v
	end
	for i=1,game_util:getTableLen(achievement) do
		local v = achievement[tostring(i)] or achievement[i]
		if r_ach[v] then
			ach[v] = 1
		else
			ach[v] = 0
		end
	end
	-- cclog2(ach)
	return ach
end



function ui_chrismas_snowman_map_pop:refreshUi()
	self.m_maplist_node:removeAllChildrenWithCleanup(true)
	self.m_maplist_node:addChild(self:createTableView(self.m_maplist_node:getContentSize()))
end


function ui_chrismas_snowman_map_pop:init(t_params)
	if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        self.my_snow_photo = self.m_tGameData.snow_photo
    end
    self.m_achievement = self:refreshAchievement(self.m_tGameData.achievement,self.m_tGameData.received_achieve)
    -- cclog2(self.m_tGameData)
	if t_params.callback then
		self.callback = t_params.callback
	end
	self.m_snow_photo = json.decode(getConfig(game_config_field.snow_photo):getFormatBuffer())
end



function ui_chrismas_snowman_map_pop:create(t_params)
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end


return ui_chrismas_snowman_map_pop