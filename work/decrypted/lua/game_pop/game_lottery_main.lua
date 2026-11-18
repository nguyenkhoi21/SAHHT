local game_lottery_main = {
	m_btn_rules = nil,
	m_node_broadcastboard = nil,
	bar = nil,
	m_left_times = nil,
	m_conutdownTime_node = nil,
	m_tGameData = nil,
	m_version = nil,
	m_lucky_lotteryCfg = nil,
	m_max_cost = nil,
	m_selIndex = nil,
	m_selBall = nil,
	m_left = nil,
	m_selBallIndex = nil,
	m_close_btn = nil,
	m_root_layer = nil,
	m_scroll_msgBoard = nil,
	m_node_broadcastboard = nil,
	m_left_times = nil,
	m_count_1 = nil,
	m_count_2 = nil,
	m_count_3 = nil,
	m_count_4 = nil,
	m_count_5 = nil,
	m_discount_node1 = nil,
	m_discount_node2 = nil,
	m_discount_node3 = nil,
	m_discount_node4 = nil,
	m_discount_node5 = nil,
	m_progress_node = nil,
	m_btn_node = nil,
	m_conutdownTime_node = nil,
	m_selBallLabel1 = nil,
	m_selBallLabel2 = nil,
}

function game_lottery_main:destroy(  )
	-- body
	self.m_btn_rules = nil;
	self.m_node_broadcastboard = nil;
	self.bar = nil;
	self.m_left_times = nil;
	self.m_conutdownTime_node = nil;
	self.m_tGameData = nil;
	self.m_version = nil;
	self.m_lucky_lotteryCfg = nil;
	self.m_max_cost = nil;
	self.m_selIndex = nil;
	self.m_selBall = nil;
	self.m_left = nil;
	self.m_selBallIndex = nil;
	self.m_close_btn = nil;
	self.m_root_layer = nil;
	self.m_scroll_msgBoard = nil;
	self.m_node_broadcastboard = nil;
	self.m_left_times = nil;
	self.m_count_1 = nil;
	self.m_count_2 = nil;
	self.m_count_3 = nil;
	self.m_count_4 = nil;
	self.m_count_5 = nil;
	self.m_discount_node1 = nil;
	self.m_discount_node2 = nil;
	self.m_discount_node3 = nil;
	self.m_discount_node4 = nil;
	self.m_discount_node5 = nil;
	self.m_progress_node = nil;
	self.m_btn_node = nil;
	self.m_conutdownTime_node = nil;
	self.m_selBallLabel1 = nil;
	self.m_selBallLabel2 = nil;
end

function game_lottery_main:back(  )
	-- body
    game_scene:removePopByName("game_lottery_main");

end
local ball_count = {
{1,2,3},
{4,5,6},
{7,8,9},
{0,1,2,3,4,5,6,7,8,9,},
}
function game_lottery_main:createUi(  )
	-- body
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"      btn    click   is ")
        if btnTag == 1 then
        	self:back()
        elseif btnTag == 2 then -- +
        	local ball = ball_count[self.m_selBallIndex]
        	self.m_selIndex = self.m_selIndex + 1
        	self.m_selIndex = self.m_selIndex > #ball and 1 or self.m_selIndex
        	self.m_selBall[self.m_selBallIndex] = ball[self.m_selIndex]
        	self.m_selBallLabel1:setString(self.m_selBall[self.m_selBallIndex])
			self.m_selBallLabel2:setString(self.m_selBall[self.m_selBallIndex])
    	elseif btnTag == 3 then -- -
        	local ball = ball_count[self.m_selBallIndex]
        	self.m_selIndex = self.m_selIndex - 1
        	self.m_selIndex = self.m_selIndex < 1 and #ball or self.m_selIndex
        	self.m_selBall[self.m_selBallIndex] = ball[self.m_selIndex]
        	self.m_selBallLabel1:setString(self.m_selBall[self.m_selBallIndex])
			self.m_selBallLabel2:setString(self.m_selBall[self.m_selBallIndex])
    	elseif btnTag == 4 then -- 投注
    		cclog2(self.m_selBall)
    		cclog2(self.m_selBall)
    		if self.m_left < 1 then
    			game_util:addMoveTips({text = "Số lần mua của bạn đã đạt tối đa!"})
    			return
    		end
    		local count = game_util:getTableLen(self.m_selBall)
    		if count < 4 then
    			game_util:addMoveTips({text = "Hãy chọn bóng màu trước!"})
    			return
    		end
    		local function refreshCallFun( gamedata )
    			if gamedata then
		    		local data = gamedata:getNodeWithKey("data")
    				if data then
    					self.m_tGameData = json.decode(data:getFormatBuffer())
    					self:refreshUi(true)
    				end
    			end
    		end
    		game_scene:addPop("game_lottery_betting_pop",{version = self.m_version,selBall = self.m_selBall,maxValue = self.m_left,callfun = refreshCallFun})
    	elseif btnTag == 5 then -- 本期奖励
    		game_scene:addPop("game_lottery_reward_pop",{version = self.m_version})
    	elseif btnTag == 6 then -- 投注记录
    		local function ResponseMethod(tag,gameData)
    			if gameData then
            		game_scene:addPop("game_lottery_log_pop",{gameData = gameData})
            	end
	        end
	        network.sendHttpRequest(ResponseMethod,game_url.getUrlForKey("lottery_get_betting_number"), http_request_method.GET, nil,"lottery_get_betting_number")
    	elseif btnTag == 7 then -- 本期大奖
    		local reward = self.m_lucky_lotteryCfg:getNodeWithKey("limit_reward_show")
    		if reward then
    			reward = json.decode(reward:getFormatBuffer())
				game_util:lookItemDetal(reward[1])
    		else
    			game_util:addMoveTips({text = "Tải cấu hình thất bại!"})
    		end
    	elseif btnTag == 8 then  --规则
    		game_scene:addPop("game_lottery_rule_pop",{version = self.m_version})
        elseif btnTag > 10 and btnTag < 20 then -- 选择色球
        	local index = btnTag - 10
        	local ball = ball_count[index]
        	local selNode = ccbNode:nodeForName("m_ball_node" .. index)
        	local x,y = selNode:getPosition()
        	self.m_btn_node:setPositionX(x)
        	self.m_selBallIndex = index

        	self.m_selBallLabel1 = ccbNode:labelTTFForName("m_number" .. index)
			self.m_selBallLabel2 = ccbNode:labelTTFForName("m_num" .. index)
			if not self.m_selBall[index] then
				self.m_selBall[index] = ball[1]
			end
			for k,v in pairs(ball) do
				if v == self.m_selBall[index] then
					self.m_selIndex = k
				end
			end
			self.m_selBallLabel1:setString(self.m_selBall[index])
        elseif btnTag > 500 and btnTag < 510 then -- 奖励
			local index = btnTag - 500
			local join_number = self.m_tGameData.join_number or 0
			local number = self.m_lucky_lottery_achievement[index].number
			if join_number < number then
				local reward = self.m_lucky_lottery_achievement[index].reward[1] or self.m_lucky_lottery_achievement[index].reward[tostring(1)]
				game_util:lookItemDetal(reward)
			else
				local get_reward = self.m_tGameData.get_reward or {}
				local isGot = false
				for k,v in pairs(get_reward) do
					if v == index then
						isGot = true
					end
				end
				if isGot then
					game_util:addMoveTips({text = "Bạn đã nhận phần thưởng này rồi, không thể lặp lại!"})
					return
				else
					local function ResponseMethod(tag,gameData)
		    			if gameData then
		    				local data = gameData:getNodeWithKey("data")
		    				if data then
		    					local reward = data:getNodeWithKey("reward")
		    					game_util:rewardTipsByJsonData(reward)
		    					self.m_tGameData = json.decode(data:getFormatBuffer())
		    					self:refreshUi(true)
		    				end
		            	end
			        end
			       	local params = {}
			       	params.stall = index
			        network.sendHttpRequest(ResponseMethod,game_url.getUrlForKey("lottery_get_join_reward"), http_request_method.GET, params,"lottery_get_join_reward")
				end
			end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_lottery_main.ccbi");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local btnTab = {"m_btn_up",
	    "m_btn_down",
	    "m_btn_BigReward",
	    "m_select_btn1",
	    "m_select_btn2",
	    "m_select_btn3",
	    "m_select_btn4",
	    "",
	}
	for k,v in pairs(btnTab) do
		local btn = ccbNode:controlButtonForName(v)
		if btn then
			btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
			btn:setOpacity(0)
		end
	end

    local m_reward_btn = ccbNode:controlButtonForName("m_reward_btn")
    local m_log_btn = ccbNode:controlButtonForName("m_log_btn")
    local m_btn_touzhu = ccbNode:controlButtonForName("m_btn_touzhu")
	m_reward_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
	m_log_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
	m_btn_touzhu:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
	self.m_scroll_msgBoard = ccbNode:scrollViewForName("m_scroll_msgBoard")
	self.m_node_broadcastboard = ccbNode:nodeForName("m_node_broadcastboard")
	self.m_left_times = ccbNode:nodeForName("m_left_times")
	self.m_count_1 = ccbNode:labelTTFForName("count_1")
	self.m_count_2 = ccbNode:labelTTFForName("count_2")
	self.m_count_3 = ccbNode:labelTTFForName("count_3")
	self.m_count_4 = ccbNode:labelTTFForName("count_4")
	self.m_count_5 = ccbNode:labelTTFForName("count_5")
	self.m_discount_node1 = ccbNode:nodeForName("discount_node1")
	self.m_discount_node2 = ccbNode:nodeForName("discount_node2")
	self.m_discount_node3 = ccbNode:nodeForName("discount_node3")
	self.m_discount_node4 = ccbNode:nodeForName("discount_node4")
	self.m_discount_node5 = ccbNode:nodeForName("discount_node5")
	self.m_progress_node = ccbNode:nodeForName("m_progress_node")
	self.m_btn_rules = ccbNode:controlButtonForName("m_btn_rules")
	self.m_btn_rules:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)	
	self.m_btn_node = ccbNode:nodeForName("m_btn_node")
	self.m_conutdownTime_node = ccbNode:nodeForName("m_conutdownTime_node")
	for i=1,5 do
		local btn = ccbNode:controlButtonForName("m_bell" .. i)
		if btn then
			btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
		end
	end


	self.m_selBallLabel1 = ccbNode:labelTTFForName("m_number1")
	self.m_selBallLabel2 = ccbNode:labelTTFForName("m_num1")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode
    return ccbNode
end

function game_lottery_main:refreshProgress(  )
	-- body
	local msg = {1000,3000,5000,8000,10000}
	msg = self.m_lucky_lottery_achievement
	local maxValue = msg[#self.m_lucky_lottery_achievement].number
	local viewSize = self.m_progress_node:getContentSize()
	self.m_count_1:setString(msg[1].number)
	self.m_count_2:setString(msg[2].number)
	self.m_count_3:setString(msg[3].number)
	self.m_count_4:setString(msg[4].number)
	self.m_count_5:setString(msg[5].number)
	self.m_discount_node1:setPositionX(viewSize.width*(msg[1].number/maxValue))
	self.m_discount_node2:setPositionX(viewSize.width*(msg[2].number/maxValue))
	self.m_discount_node3:setPositionX(viewSize.width*(msg[3].number/maxValue))
	self.m_discount_node4:setPositionX(viewSize.width*(msg[4].number/maxValue))
	self.m_discount_node5:setPositionX(viewSize.width*(msg[5].number/maxValue))
	if not self.bar then
		self.bar = ExtProgressTime:createWithFrameName("ui_lottery_progress1.png","ui_lottery_progress2.png");
	    self.bar:setScaleX(1);
	    self.bar:setMaxValue(maxValue)
	end
    self.bar:setAnchorPoint(ccp(0.5,0.5))
    self.bar:setPosition(ccp(viewSize.width*0.5,10))
    self.m_progress_node:addChild(self.bar,10)

end

function game_lottery_main:refreshBroadCastMsg()
    local msgTab = {}
    local msg = {"Bạn không có tin mới",}
    for k,v in pairs(self.m_tGameData.big_reward_log or msg) do
        table.insert(msgTab, v)
    end
    if #msgTab > 0 and self.m_node_broadcastboard then
    	--scroll_view_tips,tipsStrTab,loopFlag,openType, fontColor, fontSize
        game_util:createScrollViewTips(self.m_scroll_msgBoard, msgTab, true, 1, ccc3(200, 255,255), 8)
        self.m_node_broadcastboard:setVisible(true)
    elseif self.m_node_broadcastboard then
        self.m_node_broadcastboard:setVisible(false)
    end
end


function game_lottery_main:refreshUi( flag )
	-- body
	if not flag then
		self:refreshProgress()
	end
	local join_number = self.m_tGameData.join_number
	self.bar:setCurValue(join_number,false); 

	for i=1,5 do
		local btn = self.m_ccbNode:controlButtonForName("m_bell" .. i)
		local sunny_sp = self.m_ccbNode:spriteForName("m_sunny_sp" .. i)
		local number = self.m_lucky_lottery_achievement[i].number
		if join_number < number then
			btn:setColor(ccc3(150,150,150))
			sunny_sp:setVisible(false)
		else
			btn:setColor(ccc3(255,255,255))
			sunny_sp:setVisible(true)
		end
	end
	for i=1,4 do
		local m_num = self.m_ccbNode:labelTTFForName("m_num" .. i)
		local m_number = self.m_ccbNode:labelTTFForName("m_number" .. i)
		local ball = self.m_selBall[i]
		if not ball then
			local tempBall = ball_count[i]
			ball = tempBall[1]
			m_number:setString(tempBall[1] .. "-" .. tempBall[#tempBall])
		else
			m_number:setString(ball)
		end
		m_num:setString(ball)
	end
	self:refreshBroadCastMsg()
	local times = self.m_tGameData.betting_times or 0
	local left_times = self.m_max_cost - times
	self.m_left = left_times
	if self.m_left_times then
		self.m_left_times:removeAllChildrenWithCleanup(true)
		local label = game_util:createLabelTTF({text = "Số lần mua còn:" .. left_times,color = ccc3(255,255,255),fontSize = 12})
		label:setAnchorPoint(ccp(0,0.5))
		self.m_left_times:addChild(label)
	end


    local function timeOverFunc(label,type)
    	local function ResponseMethod(tag,gameData)
    		if gameData then
	    		local data = gameData:getNodeWithKey("data")
				if data then
    				game_util:addMoveTips({text = "Kết thúc thời gian mua lần này!\nSố trúng giải sẽ được công bố trong vòng 3 phút, công bố xong có thể xem tại log mua"})
					self.m_tGameData = json.decode(data:getFormatBuffer())
					self:refreshUi(true)
				end
    		end
        end
        network.sendHttpRequest(ResponseMethod,game_url.getUrlForKey("lottery_index"), http_request_method.GET, nil,"lottery_index")
    end
    local times = self.m_tGameData.can_betting or 0
    local timeOverLabel = game_util:createCountdownLabel(times,timeOverFunc,8)
    timeOverLabel:setAnchorPoint(ccp(0,0.5))
    self.m_conutdownTime_node:removeAllChildrenWithCleanup(true)
    self.m_conutdownTime_node:addChild(timeOverLabel,10,10)
end

function game_lottery_main:init( t_params )
	-- body
	local t_params = t_params or {}
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
		local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
    end
    cclog2(self.m_tGameData)
    self.m_version = self.m_tGameData.version
	local lucky_lottery_achievement = getConfig(game_config_field.lucky_lottery_achievement)
	if lucky_lottery_achievement then
		lucky_lottery_achievement = json.decode(lucky_lottery_achievement:getFormatBuffer())
	end
	local lucky_lottery = getConfig(game_config_field.lucky_lottery)
	self.m_lucky_lotteryCfg = lucky_lottery:getNodeWithKey(tostring(self.m_version))
	self.m_max_cost = self.m_lucky_lotteryCfg:getNodeWithKey("limit_num"):toInt()
	self.m_lucky_lottery_achievement = {}
	for i=1,game_util:getTableLen(lucky_lottery_achievement) do
		local v = lucky_lottery_achievement[tostring(i)]
		self.m_lucky_lottery_achievement[i] = v
	end
	cclog2(self.m_lucky_lottery_achievement)
	self.m_selBall = {}
	self.m_selBall[1] = ball_count[1][1]
	self.m_selBallIndex = 1
	self.m_selIndex = 1
end

function game_lottery_main:create( t_params )
	-- body
	self:init(t_params)
	local pop = self:createUi()
	self:refreshUi()
	return pop
end

return game_lottery_main