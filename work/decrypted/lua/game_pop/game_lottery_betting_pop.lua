local game_lottery_betting_pop = {
        m_close_btn = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_metal = nil,
    m_cost = nil,
    m_max_cost = nil,
    m_single = nil,
    m_selBall = nil,
    m_callfun = nil,
    m_selCount = nil,
    m_version = nil,
}

function game_lottery_betting_pop:destroy(  )
	-- body
        self.m_close_btn = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_metal = nil;
    self.m_cost = nil;
    self.m_max_cost = nil;
    self.m_single = nil;
    self.m_selBall = nil;
    self.m_callfun = nil;
    self.m_selCount = nil;
    self.m_version = nil;

end

function game_lottery_betting_pop:back(  )
	-- body
    game_scene:removePopByName("game_lottery_betting_pop");

end

function game_lottery_betting_pop:createUi(  )
	-- body
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"      btn    click   is ")
        if btnTag == 1 then
        	self:back()
        elseif btnTag == 2 then -- 投注
        	local numbers = ""
            local numbers2 = ""
        	for i=1,4 do
        		local num = self.m_selBall[i]
                numbers = numbers ..(i ~= 1 and "_" or "" ).. num 
        		numbers2 = numbers2 ..(i ~= 1 and "-" or "" ).. num 
        	end
        	if self.m_selCount < 1 then
	            game_util:addMoveTips({text = "Hãy chọn số lượng mua!"})
        		return
        	end
        	local params = {}
        	params.numbers = numbers
        	params.count = self.m_selCount
        	local function ResponseMethod(tag,gameData)
	            if gameData then
	            	game_util:addMoveTips({text = "Bạn đã mua số(" .. numbers2 .. ")" .. self.m_selCount})
	            	self.m_callfun(gameData)
	            	self:back()
	            end
	        end
	        network.sendHttpRequest(ResponseMethod,game_url.getUrlForKey("lottery_betting"), http_request_method.GET, params,"lottery_betting")
        else
        	if btnTag == 3 then -- 减10
        		self.m_selCount = self.m_selCount - 10
	        elseif btnTag == 4 then -- 加10
        		self.m_selCount = self.m_selCount + 10
	        elseif btnTag == 5 then -- 减1
        		self.m_selCount = self.m_selCount - 1
	        elseif btnTag == 6 then -- 加1
        		self.m_selCount = self.m_selCount + 1
	        end
	        if self.m_selCount < 0 then
	        	self.m_selCount = 0
	        end
    		if self.m_selCount > self.m_max_cost then
    			self.m_selCount = self.m_max_cost
    		end

			self.m_count_lb:setString(self.m_selCount)
			self.m_count_lb1:setString(self.m_selCount*self.m_single)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_lottery_betting.ccbi");
    self.m_close_btn = ccbNode:controlButtonForName("btn_back")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    local m_add = ccbNode:controlButtonForName("m_add")
    local m_add1 = ccbNode:controlButtonForName("m_add1")
    local m_redmain = ccbNode:controlButtonForName("m_redmain")
    local m_redmain1 = ccbNode:controlButtonForName("m_redmain1")
    local m_btn_touzhu = ccbNode:controlButtonForName("m_btn_touzhu")
	m_add:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
	m_add1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
	m_add1:setOpacity(0)
	m_redmain:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
	m_redmain1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
	m_redmain1:setOpacity(0)
	m_btn_touzhu:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
	self.m_count_lb = ccbNode:labelTTFForName("m_count_lb")
	self.m_count_lb1 = ccbNode:labelTTFForName("m_count_lb1")
	self.m_metal = ccbNode:nodeForName("m_metal")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-2,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode
    return ccbNode
end


function game_lottery_betting_pop:refreshUi(  )
	-- body
    local icon = game_util:getRewardByItemTable(self.m_cost)
    self.m_metal:removeAllChildrenWithCleanup(true)
    if icon then
    	icon:setScale(0.4)
    	self.m_metal:addChild(icon)
    end
    self.m_count_lb:setString(self.m_selCount)
	self.m_count_lb1:setString(self.m_selCount*self.m_single)
	for i=1,4 do
		local m_num = self.m_ccbNode:labelTTFForName("m_num" .. i)
		m_num:setString(self.m_selBall[i])
	end
end

function game_lottery_betting_pop:init( t_params )
	-- body
	local lucky_lottery = getConfig(game_config_field.lucky_lottery)
    self.m_version = t_params.version

	local lucky_lotteryCfg = json.decode(lucky_lottery:getNodeWithKey(self.m_version):getFormatBuffer())
	self.m_cost = lucky_lotteryCfg.price[1]
	self.m_max_cost = t_params.maxValue or lucky_lotteryCfg.limit_num or 0
	self.m_single = self.m_cost[3]
	self.m_selBall = t_params.selBall or {}
	self.m_callfun = t_params.callfun
	self.m_selCount = 0
	
end

function game_lottery_betting_pop:create( t_params )
	-- body
	self:init(t_params)
	local pop = self:createUi()
	self:refreshUi()
	return pop
end

return game_lottery_betting_pop