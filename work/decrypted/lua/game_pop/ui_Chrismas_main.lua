local ui_chrismas_main = {
	m_root_layer = nil,
	m_btn_back = nil,
	m_progress_node = nil,
	m_snow_node = nil,
	m_scrolllayer = nil,
	m_active_time = nil,
	m_snow_node1 = nil,
	m_snow_node2 = nil,
	m_snowman_list = nil,
	m_select = nil,
	bar = nil,
	m_tGameData = {},
	my_score = nil,
	m_snow_man = nil,
	m_snowmanMsg = {},
	m_sunny_sps = nil,
} 

function ui_chrismas_main:destroy( )
	self.m_root_layer = nil;
	self.m_btn_back = nil;


	self.m_progress_node = nil;
	self.m_snow_node = nil;
	self.m_scrolllayer = nil;
	self.m_active_time = nil;
	self.m_snow_node1 = nil;
	self.m_snow_node2 = nil;
	self.m_snowman_list = {};
	self.m_select = nil;
	self.bar = nil;
	self.m_tGameData = {};
	self.my_score = nil;
	self.m_snow_man = nil;
	self.m_snowmanMsg = {};
	self.m_sunny_sps = nil;
end



function ui_chrismas_main:back()
	game_scene:removePopByName("ui_Chrismas_main")
end



-- 创建ccbi

function ui_chrismas_main:createUi()
	local function makeCallback()
		function responseMethod(tag,gameData)
	        if gameData and tolua.type(gameData) == "util_json" then
		        local data = gameData:getNodeWithKey("data")
		        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
			    self.my_score = self.m_tGameData.score
			    local version = self.m_tGameData.version
			    game_data:setSnowManVersion(version)
			    self.m_snow_man = self.m_tGameData.snow_man
			    self.m_all_sowman_score = self.m_tGameData.all_sowman_score
			    self:refreshUi()
				
	        end
	    end
	    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("snow_index"), http_request_method.GET, {},"snow_index")

	end
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		-- cclog2(btnTag)
		if btnTag == 1 then
			self:back()
		elseif btnTag == 105 then
			local MaxCount
			if self.m_select == 5 then
				MaxCount = self.m_snowmanMsg[self.m_select][4].point - self.m_all_sowman_score
			else
				MaxCount = self.m_snowmanMsg[self.m_select][4].point - self.m_snow_man[tostring(self.m_select)]
			end
			game_scene:addPop("ui_chrismas_make_snowman_pop",{gameData = nil,select_snow = self.m_select,callback = makeCallback,MaxCount = MaxCount}) 
		elseif btnTag == 101 then	
			function responseMethod(tag,gameData)
		        if gameData then
		           	game_scene:addPop("ui_chrismas_rank_pop",{gameData = gameData})
		        end
		    end
		    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("snow_rank_info"), http_request_method.GET, {},"snow_rank_info")
		elseif btnTag == 102 then
			game_scene:addPop("ui_chrisms_detail_pop",{gameData = nil,callback = makeCallback})
		elseif btnTag == 103 then
			game_scene:addPop("ui_chrismas_exchange_pop",{gameData = nil,my_score = self.my_score,callback = makeCallback})
		elseif btnTag == 104 then
			function responseMethod(tag,gameData)
		        if gameData then
		            game_scene:addPop("ui_chrismas_snowman_map_pop",{gameData = gameData,callback = makeCallback})
		        end
		    end
		    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("snow_snowman_photo"), http_request_method.GET, {},"snow_snowman_photo")
		elseif btnTag > 500 then
			-- cclog2(btnTag)
			local index = btnTag - 500
			if self.m_reward_five[tostring(index)] ~= 0 then
				game_util:addMoveTips({text = "Đã nhận quà này!"})
				return
			end
			if self.m_all_sowman_score > self.m_snowmanMsg[5][index].point or self.m_all_sowman_score == self.m_snowmanMsg[5][index].point then
				function responseMethod(tag,gameData)
			        if gameData then
			            -- cclog2(gameData:getNodeWithKey("data"))
			            local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
			            self.m_reward_five = data.reward_five
			            game_util:rewardTipsByDataTable(data.reward)
			        end
			    end
			    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("snow_get_reward"), http_request_method.GET, {step_id = index},"snow_get_reward")
			else
				-- cclog2(self.m_snowmanMsg[5][index].reward)
				local reward = self.m_snowmanMsg[5][index].reward[1] or self.m_snowmanMsg[5][index].reward[tostring(1)]
				game_util:lookItemDetal(reward)
			end
		end
	end
	local ccbNode =  luaCCBNode:create();
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_Chrismas_main.ccbi")

	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	self.m_btn_back = ccbNode:controlButtonForName("btn_back")
	self.m_progress_node = ccbNode:nodeForName("m_progress_node")
	self.m_snow_node = ccbNode:nodeForName("m_snow_node")
	self.m_scrolllayer = ccbNode:scrollViewForName("scrolllayer")
	-- self.m_move_layer = ccbNode:layerForName("m_move_layer")
	local btn1 = ccbNode:controlButtonForName("m_btn_rank")
	local btn2 = ccbNode:controlButtonForName("m_btn_jieshao")
	local btn3 = ccbNode:controlButtonForName("m_btn_duihuan")
	local btn4 = ccbNode:controlButtonForName("m_btn_map")
	self.m_btn_make = ccbNode:controlButtonForName("m_btn_make")
	local move_layer = ccbNode:layerForName("m_move_layer")
	self.m_active_time = ccbNode:labelTTFForName("active_time")
	self.m_count_1 = ccbNode:labelTTFForName("count_1")
    self.m_count_2 = ccbNode:labelTTFForName("count_2")
    self.m_count_3 = ccbNode:labelTTFForName("count_3")
    self.m_count_4 = ccbNode:labelTTFForName("count_4")
	cclog("!!!!!!!!!!!!!!!!!!!/")

    self.m_discount_node1 = ccbNode:nodeForName("discount_node1")
    self.m_discount_node2 = ccbNode:nodeForName("discount_node2")
    self.m_discount_node3 = ccbNode:nodeForName("discount_node3")
    self.m_discount_node4 = ccbNode:nodeForName("discount_node4")
    self.m_finished_sp = ccbNode:spriteForName("m_finished_sp")
    self.m_finished_sp:setVisible(false)

	self.m_snow_node1 = CCNode:create()
	self.m_snow_node1:setContentSize(CCSizeMake(0,0))
	self.m_snow_node1:setPosition(ccp(0,0))
	self.m_snow_node2 = CCNode:create()
	self.m_snow_node2:setContentSize(CCSizeMake(0,0))
	self.m_snow_node2:setPosition(ccp(700,0))
	local node2 = CCNode:create()
	node2:setContentSize(CCSizeMake(0,0))
	node2:setPosition(ccp(0,0))
	self.m_scrolllayer:addChild(node2)
	node2:addChild(self.m_snow_node1)
	node2:addChild(self.m_snow_node2)
	self.m_move_layer = CCLayer:create()
	self.m_move_layer:setContentSize(CCSizeMake(420,200))
	self.m_move_layer:setPosition(ccp(0,0))
	self.m_scrolllayer:addChild(self.m_move_layer)
	self.m_scrolllayer:setContentSize(CCSizeMake(420,200))
	self.m_scrolllayer:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
	self.m_btn_back:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
	btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
	btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
	btn3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
	btn4:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
	self.m_bell_list = {}
	self.m_sunny_sps = {}

	for i=1,4 do
		local bell = ccbNode:controlButtonForName("m_bell" .. i)
		if bell then
			bell:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
			self.m_bell_list[i] = bell
			game_util:setCCControlButtonBackground(bell,"chrismas_bell2.png","chrismas_bell2.png");
		end
		local sunny_sp = ccbNode:spriteForName("m_sunny_sp" .. i)
		if sunny_sp then self.m_sunny_sps[i] = sunny_sp end
	end
	self.m_btn_make:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-2,true);
    self.m_root_layer:setTouchEnabled(true);
    self:initLayerTouch(self.m_move_layer);
    self:createSnow(self.m_snow_node1)
    self:createSnow(self.m_snow_node2)

	return ccbNode
end



-- 创建雪人

function ui_chrismas_main:createSnow(parentNode)
	self.m_snowman_list = self.m_snowman_list or {}
	for i=1,5 do
		local function onMainBtnClick( target,event )
			local tagNode = tolua.cast(target,"CCNode")
			local btnTag = tagNode:getTag()
			-- cclog(btnTag)
			self.m_select = btnTag
		end
		local ccbNode =  luaCCBNode:create();
		ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
		ccbNode:openCCBFile("ccb/ui_chrismas_snowman.ccbi")
		local btn = ccbNode:controlButtonForName("m_btn")
		local icon_sp = ccbNode:spriteForName("icon_sp")
		local index = self:getSnowByIndex(i,self.m_snow_man)
		local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring("snowman" .. i .. "_" .. index .. ".png"))
		if tempSpriteFrame then
        	icon_sp:setDisplayFrame(tempSpriteFrame)
		end

		btn:setTag(i)
		btn:setOpacity(0)
		ccbNode:setAnchorPoint(ccp(0.5,0))
		ccbNode:setPosition(ccp(70 * (i * 2 - 1),0))
		local realPos = parentNode:convertToNodeSpace(ccp(70 * (i * 2 - 1),0))
		if i > 5 then
			i = i-5
		end
		local distance = math.abs((140 * (2*i - 3) - realPos.x))
		if distance < 140 then
			local sca = (140 - distance)/140
			if i == 5 then
				ccbNode:setScale(0.7 + sca/2)
			else
				ccbNode:setScale(0.5 + sca/2)
			end
			if sca >0.5 then
				if self.m_select ~= i then
					self.m_select = i
					self:refreshProgressMsg()
				end
			end
		else
			ccbNode:setScale(0.5)
		end
		parentNode:addChild(ccbNode)
		self.m_snowman_list[#self.m_snowman_list+1]= ccbNode
	end
end


-- 刷新进度条信息
function ui_chrismas_main:refreshProgressMsg()
	local value = self.m_snow_man[tostring(self.m_select)]
	if self.m_select == 5 then
		value = self.m_all_sowman_score
		self.m_btn_make:setVisible(false)
	else
		self.m_btn_make:setVisible(true)
	end
	local temp = self.m_snowmanMsg[self.m_select][4].point
	if value > temp or value == temp then
		self.m_finished_sp:setVisible(true)
		self.m_btn_make:setVisible(false)
	else	
		self.m_finished_sp:setVisible(false)
		if self.m_select == 5 then
			self.m_btn_make:setVisible(false)
		else
			self.m_btn_make:setVisible(true)
		end
	end
	
	self.m_active_time:setString(value .. "/" .. temp)
end



-- 滑动雪人位置
function ui_chrismas_main:refreshSnowmanPos(move_x)
	local x1,_ = self.m_snow_node1:getPosition()
	self.m_snow_node1:setPositionX(x1+move_x)
	local x2,_ = self.m_snow_node2:getPosition()
	self.m_snow_node2:setPositionX(x2+move_x)
	if move_x < 0 then
		local xx1,_ = self.m_snow_node1:getPosition()
		local m1 = xx1 - x1
		local xx2,_ = self.m_snow_node2:getPosition()
		local m2 = xx2 - x2
		if xx1 < -700 then
		 	self.m_snow_node1:setPositionX(700 + xx2)
		end
		if xx2 < -700 then
		 	self.m_snow_node2:setPositionX(700 + xx1)
		end
	elseif move_x > 0 then
		local xx1,_ = self.m_snow_node1:getPosition()
		local m1 = xx1 - x1
		local xx2,_ = self.m_snow_node2:getPosition()
		local m2 = xx2 - x2
		if xx1 > 700 then
		 	self.m_snow_node1:setPositionX(xx2-700 )
		end
		if xx2 > 700 then
		 	self.m_snow_node2:setPositionX(xx1-700 )
		end
	end
	for i=1,#self.m_snowman_list do
		local index = i
		local item = self.m_snowman_list[i]
		local x,y = item:getPosition()
		local realPos = item:getParent():convertToNodeSpace(ccp(x,y))
		if i > 5 then
			index = index-5
		end
		local distance = math.abs((140 * (2*index - 3) - realPos.x))
		if distance < 140 then
			local sca = (140 - distance)/140
			if sca >0.5 then
				if self.m_select ~= index then
					self.m_select = index
					self:refreshProgressMsg()
				end
			end
			if self.m_select == 5 then
				sca = sca + 0.3
			end
			item:setScale(0.5 + sca/2)
		else
			item:setScale(0.5)
		end
	end
end



-- 恢复正确位置
function ui_chrismas_main:refreshRightPosition(move_x)
	local x1,_ = self.m_snow_node1:getPosition()
	local x2,_ = self.m_snow_node2:getPosition()
	local temp1 = x1%70
	local temp2 = math.floor(x1/70)
	local distance
	if temp2%2 == 0 then
		distance = 0 - temp1
	else
		distance = 70 - temp1
	end

	local moveBy = CCMoveTo:create(0.5, ccp(x1 + distance, 0 ))
	self.m_snow_node1:runAction(moveBy)
	local moveBy2 = CCMoveTo:create(0.5, ccp(x2 + distance, 0 ))
	self.m_snow_node2:runAction(moveBy2)

	for i=1,#self.m_snowman_list do
		local index = i
		local item = self.m_snowman_list[i]
		local x,y = item:getPosition()
		local realPos = item:getParent():convertToNodeSpace(ccp(x,y))
		if i > 5 then
			index = index-5
		end
		local tempDis = math.abs((140 * (2*index - 3) - (realPos.x-distance)))
		if tempDis < 140 then
			local sca = (140 - tempDis)/140
			if sca >0.5 then
				if self.m_select ~= index then
					self.m_select = index
					self:refreshProgressMsg()
				end
			end
			if self.m_select == 5 then
				sca = sca + 0.3
			end
			item:runAction(CCScaleTo:create(0.5,0.5 + sca/2))
		else
			item:runAction(CCScaleTo:create(0.5,0.5))
		end
	end

end


function ui_chrismas_main:initLayerTouch(touch_layer)
    local tempItem,selItem,realPos
    local posX,posY,beginPosX,endPosX
    local posXX
    local function onTouchBegan(x, y)
        posX = x
        posXX = x
		beginPosX = x
        realPos = self.m_move_layer:convertToNodeSpace(ccp(x,y));
        local is_touch_layer = touch_layer:boundingBox():containsPoint(realPos)
	    return is_touch_layer
    end
    local function onTouchMoved(x, y)
    	local move_X = x - posX
    	posX = x
    	realPos = self.m_move_layer:convertToNodeSpace(ccp(x,y));
    	self:refreshSnowmanPos(move_X)
    end
    local function onTouchEnded(x, y)
    	realPos = self.m_move_layer:convertToNodeSpace(ccp(x,y));
        if self.m_move then
        	self.m_move = false
	        endPosX = x
	        self:refreshRightPosition(endPosX - beginPosX)
    	else

    	end

        tempItem = nil;
    end
    local function onTouch(eventType, x, y)
    	x = math.floor(x)
    	y = math.floor(y)
        if eventType == "began" then
        	self.m_move = false
            return onTouchBegan(x, y)
        elseif eventType == "moved" then
        	self.m_move = true
            return onTouchMoved(x, y)
        else
            return onTouchEnded(x, y)
        end
    end
    touch_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-2,false)
    touch_layer:setTouchEnabled(true)
end


function ui_chrismas_main:refreshUi()
	if not self.bar then self:createProgress() end	
	self.bar:setCurValue(self.m_tGameData.all_sowman_score,false); 
	self:refreshSnowMan(self.m_snow_man,self.m_all_sowman_score)
end


-- 创建进度条
function ui_chrismas_main:createProgress()
	local maxValue = self.m_snowmanMsg[5][4].point
	local viewSize = self.m_progress_node:getContentSize()
	self.m_count_1:setString(self.m_snowmanMsg[5][1].point)
	self.m_count_2:setString(self.m_snowmanMsg[5][2].point)
	self.m_count_3:setString(self.m_snowmanMsg[5][3].point)
	self.m_count_4:setString(self.m_snowmanMsg[5][4].point)
	self.m_discount_node1:setPositionX(viewSize.width*(self.m_snowmanMsg[5][1].point/maxValue))
	self.m_discount_node2:setPositionX(viewSize.width*(self.m_snowmanMsg[5][2].point/maxValue))
	self.m_discount_node3:setPositionX(viewSize.width*(self.m_snowmanMsg[5][3].point/maxValue))
	self.m_discount_node4:setPositionX(viewSize.width*(self.m_snowmanMsg[5][4].point/maxValue))
	if not self.bar then
		self.bar = ExtProgressTime:createWithFrameName("ui_fired_progress2.png","ui_fired_progress1.png");
	    self.bar:setScaleX(1);
	    self.bar:setMaxValue(maxValue)
	end
    self.bar:setAnchorPoint(ccp(0.5,0.5))
    self.bar:setPosition(ccp(125,10))
    self.m_progress_node:addChild(self.bar,10)
end



-- 刷新雪人信息
function ui_chrismas_main:refreshSnowMan(snow_man,all_sowman_score)
	self.m_snow_man = snow_man
	self.m_all_sowman_score = all_sowman_score
	local value = snow_man[tostring(self.m_select)]
	if self.m_select == 5 then
		value = all_sowman_score
	end
	local temp = self.m_snowmanMsg[self.m_select][4].point
	self.m_active_time:setString(value .. "/" .. temp)
	if value > temp or value == temp then
		self.m_btn_make:setVisible(false)
		self.m_finished_sp:setVisible(true)
	end
	for i=1,#self.m_snowman_list do
		local ccbNode = self.m_snowman_list[i]
		local icon_sp = ccbNode:spriteForName("icon_sp")
		if i > 5 then
			i = i - 5
		end
		local index = self:getSnowByIndex(i,snow_man)
		local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring("snowman" .. i .. "_" .. index .. ".png"))
		if tempSpriteFrame then
        	icon_sp:setDisplayFrame(tempSpriteFrame)
		end
	end
	for i=1,4 do
		local bell = self.m_bell_list[i]
		if all_sowman_score > self.m_snowmanMsg[5][i].point or all_sowman_score == self.m_snowmanMsg[5][i].point then
			game_util:setCCControlButtonBackground(bell,"chrismas_bell1.png","chrismas_bell1.png");
			if self.m_sunny_sps[i] then self.m_sunny_sps[i]:setVisible(true) end
		else
			game_util:setCCControlButtonBackground(bell,"chrismas_bell2.png","chrismas_bell2.png");
			if self.m_sunny_sps[i] then self.m_sunny_sps[i]:setVisible(false) end
		end
	end
end


-- 初始化信息
function ui_chrismas_main:init(t_params)
	if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        -- cclog2(self.m_tGameData)
    end
    self.my_score = self.m_tGameData.score
    local version = self.m_tGameData.version
    game_data:setSnowManVersion(version)
    self.m_snow_man = self.m_tGameData.snow_man
    self.m_all_sowman_score = self.m_tGameData.all_sowman_score
    self.m_reward_five = self.m_tGameData.reward_five
    -- cclog2(self.m_reward_five)
	local snow_reward_mapping = getConfig(game_config_field.snow_reward_mapping)
	
	local snow_big_reward_mapping = getConfig(game_config_field.snow_big_reward_mapping)

	local snowman = {}
	self.m_snowmanMsg = game_data:getSnowManMsg("ui_chrismas_main")
	if self.m_snowmanMsg == nil then
		-- cclog(">>>>>>>>>>>>>>>>>>>>>>>>>>>>")
		local snowman = {}
		local snowman_mapping = json.decode(getConfig(game_config_field.snowman_mapping):getFormatBuffer())
		-- cclog2(snowman_mapping,"<<<<<<<<<<<<<<<<")
		local count = game_util:getTableLen(snowman_mapping)
		for i=1,count do
			local v = snowman_mapping[tostring(i)]
			-- cclog2(v.reward)
			snowman[v.version] = snowman[v.version] or {}
			snowman[v.version][v.type] = snowman[v.version][v.type] or {}
			snowman[v.version][v.type][#snowman[v.version][v.type] + 1] = v
		end
		game_data:setSnowManMsg(snowman[version],"ui_chrismas_main")
		self.m_snowmanMsg = snowman[version]
	end
end


function ui_chrismas_main:getSnowByIndex(index,snow_man)
	local val = snow_man[tostring(index)]
	if index == 5 then
		val = self.m_all_sowman_score
	end
	local temp = self.m_snowmanMsg[index]
	local index = 1
	for i=1,#temp do
		if val > temp[i].point or  val == temp[i].point then
			index = i
		end
	end
	return index
end



function ui_chrismas_main:create(t_params)
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end
return ui_chrismas_main