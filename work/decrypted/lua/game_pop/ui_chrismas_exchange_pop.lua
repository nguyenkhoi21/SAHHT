local ui_chrismas_exchange_pop = {
	m_root_layer = nil,
	m_btn_back = nil,
	callback = nil,
	m_tGameData = nil,
	my_score = nil,
	m_exch_btn1 = nil,
	m_exch_btn2 = nil,
	m_gift_btn1 = nil,
	m_gift_btn2 = nil,
	m_score1 = nil,
	m_score2 = nil,
	m_left_score = nil,
	m_snow_exchange = nil,
} 

function ui_chrismas_exchange_pop:destroy( )
	self.m_root_layer = nil;
	self.m_btn_back = nil;
	self.callback = nil;
	self.m_tGameData = nil;
	self.my_score = nil;
	self.m_exch_btn1 = nil;
	self.m_exch_btn2 = nil;
	self.m_gift_btn1 = nil;
	self.m_gift_btn2 = nil;
	self.m_score1 = nil;
	self.m_score2 = nil;
	self.m_left_score = nil;
	self.m_snow_exchange = nil;
end



function ui_chrismas_exchange_pop:back()
	if self.callback then
		self.callback()
	end
    game_scene:removePopByName("ui_chrismas_exchange_pop")
        	
end




function ui_chrismas_exchange_pop:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()

		if btnTag == 1 then
			self:back()
		elseif btnTag == 101 then
			local reward = self.m_snow_exchange[1].reward
			game_util:lookItemDetal(reward[1])
		elseif btnTag == 102 then
			local reward = self.m_snow_exchange[2].reward
			game_util:lookItemDetal(reward[1])
		elseif btnTag == 103 then
			function responseMethod(tag,gameData)
		        if gameData and tolua.type(gameData) == "util_json" then
			        local data = gameData:getNodeWithKey("data")
			        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
			        game_util:rewardTipsByDataTable(self.m_tGameData.reward)
			        self.my_score = self.m_tGameData.score
			        self:refreshUi()
			    end
		    end
		    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("snow_score_exchange"), http_request_method.GET, {id = self.m_snow_exchange[1].id},"snow_score_exchange")	
		elseif btnTag == 104 then
			function responseMethod(tag,gameData)
		        if gameData and tolua.type(gameData) == "util_json" then
			        local data = gameData:getNodeWithKey("data")
			        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
			        game_util:rewardTipsByDataTable(self.m_tGameData.reward)
			        self.my_score = self.m_tGameData.score
			        self:refreshUi()
			    end
		    end
		    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("snow_score_exchange"), http_request_method.GET, {id = self.m_snow_exchange[2].id },"snow_score_exchange")	
		end
	end
	local ccbNode =  luaCCBNode:create();
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_Chrismas_exchange_pop.ccbi")
	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	self.m_btn_back = ccbNode:controlButtonForName("btn_back")
	self.m_exch_btn1 = ccbNode:controlButtonForName("m_exch_btn1")
	self.m_exch_btn2 = ccbNode:controlButtonForName("m_exch_btn2")
	self.m_gift_btn1 = ccbNode:controlButtonForName("m_gift_btn1")
	self.m_gift_btn2 = ccbNode:controlButtonForName("m_gift_btn2")
	self.m_score1 = ccbNode:labelTTFForName("m_score1")
	self.m_score2 = ccbNode:labelTTFForName("m_score2")
	self.m_left_score = ccbNode:labelTTFForName("m_left_score")
	self.m_exch_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
	self.m_exch_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
	self.m_gift_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
	self.m_gift_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
	self.m_gift_btn1:setOpacity(0)
	self.m_gift_btn2:setOpacity(0)
	self.m_score1:setString(self.snow_exchange_mapping[tostring(1)].point)
	self.m_score2:setString(self.snow_exchange_mapping[tostring(2)].point)
	self.m_btn_back:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)

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



function ui_chrismas_exchange_pop:refreshUi()
	self.m_left_score:setString(self.my_score)
end


function ui_chrismas_exchange_pop:init(t_params)
	self.snow_exchange_mapping = json.decode(getConfig(game_config_field.snow_exchange_mapping):getFormatBuffer())
	self.m_tGameData = t_params.gameData or {}
	self.my_score = t_params.my_score or 0
	if t_params.callback then
		self.callback = t_params.callback
	end
	self.m_snow_exchange = {}
	local version = game_data:getSnowManVersion()
	for i=1,game_util:getTableLen(self.snow_exchange_mapping) do
		local v = self.snow_exchange_mapping[tostring(i)]
		if v.version == version then
			v.id = i
			self.m_snow_exchange[#self.m_snow_exchange+1] = v
		end
	end

end



function ui_chrismas_exchange_pop:create(t_params)
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end
return ui_chrismas_exchange_pop