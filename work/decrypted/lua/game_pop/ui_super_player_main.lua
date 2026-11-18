
-- 超级大玩家
local ui_super_player_main = {
	m_root_layer = nil,
	m_btn_back = nil,
	m_tGameData = {},
	my_play_points = nil,
	m_progress_node = nil,
	m_bag_sp1 = nil,
	m_bag_sp2 = nil,
	m_count_1 = nil,
	m_count_2 = nil,
	m_count_3  = nil,
	m_scroll_msgBoard = nil,
	m_node_bmsgboard = nil,
	m_refresh_time_node = nil,
	m_bells = nil,
	m_discount_node1 = nil,
	m_discount_node2  = nil,
	m_discount_node3 = nil,
	m_sunny_node = nil,
	m_shop_goods = nil,
	m_reward_nodes = nil,
	bar = nil,
	m_sunny_sps = nil,
} 

function ui_super_player_main:destroy( )
	self.m_root_layer = nil;
	self.m_btn_back = nil;

	self.m_tGameData = {};
	self.my_play_points = nil;
	self.m_progress_node = nil;
	self.m_bag_sp1 = nil;
	self.m_bag_sp2 = nil;
	self.m_count_1 = nil;
	self.m_count_2 = nil;
	self.m_count_3  = nil;
	self.m_scroll_msgBoard = nil;
	self.m_node_bmsgboard = nil;
	self.m_refresh_time_node = nil;
	self.m_bells = nil;
	self.m_discount_node1 = nil;
	self.m_discount_node2  = nil;
	self.m_discount_node3 = nil;
	self.m_sunny_node = nil;
	self.m_shop_goods = nil;
	self.m_reward_nodes = nil;
	self.bar = nil;
	self.m_sunny_sps = nil;
end

function ui_super_player_main:back()
	game_scene:removePopByName("ui_super_player_main")
end



function ui_super_player_main:createUi()
	local function callBack()
		self:refreshPage()
	end
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		-- cclog2(btnTag)
		if btnTag == 1 then
			self:back()
		elseif btnTag == 101 then
			local function responseMethod(tag,gameData)
				game_scene:addPop("ui_super_player_rank",{gameData = gameData,callback = callBack})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_player_get_rank_info"), http_request_method.GET, nil,"super_player_get_rank_info")
		elseif btnTag == 102 then
			game_scene:addPop("ui_super_player_detail",{gameData = nil,version = self.m_tGameData.version,callback = callBack})
		elseif btnTag == 103 then
			local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_scene:enterGameUi("ui_vip",{gameData = gameData,callback = callBack});     
                --game_scene:addPop("ui_vip_show_pop")
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
		elseif btnTag == 104 then
			if self.m_tGameData.bag_info[1] == nil then
				game_util:addMoveTips({text = "Không có lì xì để cướp, tạo mới xong thử lại"})
				return
			end
			local function responseMethod(tag,gameData)
				game_scene:addPop("ui_super_player_envelope",{gameData = gameData,bag_info = self.m_tGameData.bag_info,callback = callBack})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_player_get_bag_code"), http_request_method.GET, nil,"super_player_get_bag_code")
        elseif btnTag > 500 then
        	local index = btnTag - 500
        	local data = self.my_play_points[index]
			if self.m_tGameData.send_bag_times == data.point or self.m_tGameData.send_bag_times > data.point then
				if self.m_tGameData.reward_step[tostring(index)] == 0 then
					local function responseMethod(tag,gameData)
						local mydata = gameData:getNodeWithKey("data")
				        self.m_tGameData = json.decode(mydata:getFormatBuffer()) or {};
				        -- cclog2(self.m_tGameData)
				        self.m_shop_goods = self.m_tGameData.shop_goods
				        game_util:rewardTipsByDataTable(self.m_tGameData.reward)
				        self:refreshUi()
		            end
		            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_player_get_reward"), http_request_method.GET, {step_id = index,reward_id = data.id},"super_player_get_reward")
				else
					game_util:addMoveTips({text = " Đã nhận quà này, không thể nhận nữa!"})
				end 
			else
				local clickNode = self.m_bells[index]:getParent()
				self:createRewardTipsPop(self.my_play_points[index],1,clickNode)
				-- game_util:lookItemDetal(data.reward[1])
			end
		end
	end
	local ccbNode =  luaCCBNode:create();
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_super_player002.ccbi")


	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	self.m_btn_back = ccbNode:controlButtonForName("btn_back")
	self.m_progress_node = ccbNode:nodeForName("m_progress_node")
	local btn1 = ccbNode:controlButtonForName("m_btn_rank")
	local btn2 = ccbNode:controlButtonForName("m_btn_jieshao")
	local btn3 = ccbNode:controlButtonForName("m_btn_duihuan")
	local btn4 = ccbNode:controlButtonForName("m_btn_map")
	self.m_bag_sp1 = ccbNode:spriteForName("m_bag_sp1")
	self.m_bag_sp2 = ccbNode:spriteForName("m_bag_sp2")
	self.m_count_1 = ccbNode:labelTTFForName("count_1")
    self.m_count_2 = ccbNode:labelTTFForName("count_2")
    self.m_count_3 = ccbNode:labelTTFForName("count_3")
    self.m_scroll_msgBoard = ccbNode:scrollViewForName("m_scroll_msgBoard")
    self.m_node_bmsgboard = ccbNode:nodeForName("m_node_bmsgboard")
    self.m_refresh_time_node = ccbNode:nodeForName("m_refresh_time_node")
    self.m_bells = {}
    self.m_sunny_sps = {}
    for i=1,3 do
    	local bell = ccbNode:controlButtonForName("m_bell" .. i)
    	if bell then
    	 	bell:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    	 	self.m_bells[i] = bell 
    	end
    	local sunny_sp = ccbNode:spriteForName("m_sunny_sp" .. i)
    	if sunny_sp then self.m_sunny_sps[i] = sunny_sp end
    end
    self.m_discount_node1 = ccbNode:nodeForName("discount_node1")
    self.m_discount_node2 = ccbNode:nodeForName("discount_node2")
    self.m_discount_node3 = ccbNode:nodeForName("discount_node3")
    self.m_sunny_node = ccbNode:nodeForName("m_sunny_node")
    self.m_sunny_node:setVisible(false)
    self.m_reward_nodes = {}
    
    for i=1,3 do
    	local reward_node = ccbNode:nodeForName("m_reward_node" .. i)
    	
    	if reward_node then self.m_reward_nodes[i] = reward_node end
    	
    end

	self.m_btn_back:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
	btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
	btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
	btn3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
	btn4:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
	btn4:setOpacity(0)
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-2,true);
    self.m_root_layer:setTouchEnabled(true);
	return ccbNode
end



function ui_super_player_main:refreshShop_goods()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		cclog("btnTag    ----------->>>>>>>>>" .. btnTag)
		local index = btnTag - 100
		local shop_goods = self.m_shop_goods[tostring(index)]
		if shop_goods.player_limit - self.m_tGameData.shop_buy_times[tostring(index)] < 1 then
			game_util:addMoveTips({text = "Số lần mua cá nhân của bạn đạt tối đa"})
			return
		elseif shop_goods.limit_type == 1 and shop_goods.limit_num < 1 then
			game_util:addMoveTips({text = "Số lần mua của toàn server đạt tối đa"})
			return
		elseif shop_goods.limit_type == 2 and shop_goods.player_limit - self.m_tGameData.shop_buy_times[tostring(index)]< 1 then
			game_util:addMoveTips({text = "Số lần mua cá nhân đạt tối đa"})
			return
		end
		local function responseMethod(tag,gameData)
			if gameData and tolua.type(gameData) == "util_json" then
		        local data = gameData:getNodeWithKey("data")
		       self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
		       -- cclog2(self.m_tGameData)
		       self.m_shop_goods = self.m_tGameData.shop_goods
		       game_util:rewardTipsByDataTable(self.m_tGameData.reward)
		       self:refreshUi()
		    end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_player_buy_goods"), http_request_method.GET, {sort_id = shop_goods.sort,good_id = shop_goods.id},"super_player_buy_goods")

	end
	function onBtnCilck( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
		cclog("btnTag    ----------->>>>>>>>>" .. btnTag)
		local shop_goods = self.m_shop_goods[tostring(btnTag)] 
		if shop_goods then
			game_util:lookItemDetal(shop_goods.reward[1])
		end
    end
	for i=1,#self.m_reward_nodes do
		local reward_node = self.m_reward_nodes[i]
		local shop_goods = self.m_shop_goods[tostring(i)]
		-- cclog2(shop_goods)
		if reward_node and shop_goods then
			reward_node:removeAllChildrenWithCleanup(true)
			local ccbNode =  luaCCBNode:create();
			ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
			ccbNode:openCCBFile("ccb/ui_super_player_shopitem002.ccbi")
			local m_shoukong_sp = ccbNode:spriteForName("m_shoukong_sp")
			m_shoukong_sp:setVisible(false)
			local icon_node = ccbNode:nodeForName("icon_node")
			local cost_coin = ccbNode:labelTTFForName("cost_coin")
			local sort = ccbNode:labelTTFForName("sort")
			local lost_num = ccbNode:labelTTFForName("lost_num")

			local cost = ccbNode:labelTTFForName("cost")
			local buy_btn = ccbNode:controlButtonForName("buy_btn")
			lost_num:setString(shop_goods.player_limit - self.m_tGameData.shop_buy_times[tostring(i)] .. "lần")
			if shop_goods.limit_type == 1 then 
				sort:setString("Số lần toàn server")
				cost:setString( "Số lượng còn: " .. shop_goods.limit_num)
				if shop_goods.limit_num < 1 then
					m_shoukong_sp:setVisible(true)
				end
			elseif shop_goods.limit_type == 2 then
				sort:setString("Số lần cá nhân")
				cost:setString( "Số lượng còn: " .. shop_goods.player_limit - self.m_tGameData.shop_buy_times[tostring(i)])
				if shop_goods.player_limit - self.m_tGameData.shop_buy_times[tostring(i)] < 1 then
					m_shoukong_sp:setVisible(true)
				end
			end
			-- if shop_goods.limit_num < 1 then
			-- 	m_shoukong_sp:setVisible(true)
			-- end
			buy_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
			buy_btn:setTag(100 + i)
			cost_coin:setString(shop_goods.cost_coin)
			local reward = shop_goods.reward[1]
			if reward then
				local icon,name,count = game_util:getRewardByItemTable(reward,true)
				if icon then
					icon:setScale(1)
					icon_node:addChild(icon)
					-- cost:setString( "剩余数量 : " .. shop_goods.limit_num)
					local itemSize = icon:getContentSize()
	                local tempLabel = game_util:createLabelTTF({text = "×" .. count,color = ccc3(255,255,255),fontSize = 10});
	                tempLabel:setAnchorPoint(ccp(1,0.5))
	                tempLabel:setPosition(ccp(itemSize.width*0.9, itemSize.height*0.15))
	                icon:addChild(tempLabel)
	                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
	                button:setScale(1)
	                button:setAnchorPoint(ccp(0.5,0.5))
	                button:setPosition(ccp(itemSize.width/2,itemSize.height/2))
	                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
	                button:setOpacity(0)
	                button:setTag(i)
	                icon:addChild(button)
				end
			end
			reward_node:addChild(ccbNode)
		end
	end
end



function ui_super_player_main.createRewardTipsPop(self,data, reward_index,clickNode)
    if self.m_rewardTips then return end
    local tag = tag
    local data = data
    local reardNode = CCNode:create();
    local rewardHeight = 0;
    if data then
        local reward = data.reward
        if reward then
            local rewardCount = game_util:getTableLen(reward) --reward:getNodeCount();
            -- cclog("rewardCount===== " .. rewardCount)
            rewardHeight = 30*rewardCount
            reardNode:setContentSize(CCSizeMake(100, rewardHeight))
            for i=1,rewardCount do
                local icon,name = game_util:getRewardByItemTable(reward[i],true);
                -- cclog("icon == " .. tostring(icon) .. " name = " .. tostring(icon))
                if icon then
                    icon:setScale(0.5);
                    icon:setPosition(ccp(30, rewardHeight - 30*(0.5 + i - 1)))
                    reardNode:addChild(icon)
                end
                if name then
                    local tempLabel = game_util:createLabelTTF({text = name,color = ccc3(250,180,0),fontSize = 10});
                    tempLabel:setPosition(ccp(80, rewardHeight - 30*(0.5 + i - 1)))
                    reardNode:addChild(tempLabel)
                end
            end
        end
    end
    local bgSpr = CCScale9Sprite:createWithSpriteFrameName("public_pop_box_back.png");
    local viewSize = CCSizeMake(130,30 + rewardHeight);
    bgSpr:setPreferredSize(viewSize);
    reardNode:setPositionY(10)
    bgSpr:addChild(reardNode)
    local arrow = CCSprite:createWithSpriteFrameName("public_pop_box_arror.png")
    local arrowSize = arrow:getContentSize();
    arrow:setPosition(ccp(viewSize.width*0.5,0));
    arrow:setRotation(-90);
    bgSpr:addChild(arrow);
    local titleLabel = game_util:createLabelTTF({text = "Quà",color = ccc3(250,180,0),fontSize = 14});
    titleLabel:setPosition(ccp(viewSize.width*0.5, viewSize.height - 10))
    bgSpr:addChild(titleLabel)
    local px,py = clickNode:getPosition();
    local tempSize = clickNode:getContentSize();
    bgSpr:setAnchorPoint(ccp(0.5,0));
    local pos = clickNode:getParent():convertToWorldSpace(ccp(px,py+arrowSize.height));
    bgSpr:setPosition(pos);
    if reward_index == 1 then
        arrow:setPositionX(viewSize.width*0.15 - 2);
        bgSpr:setPositionX(pos.x + bgSpr:getContentSize().width * 0.4 - 2);
    end
    self.m_rewardTips = CCLayer:create();
    self.m_rewardTips:addChild(bgSpr);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            if self.m_rewardTips then
                self.m_rewardTips:removeFromParentAndCleanup(true);
                self.m_rewardTips = nil;
            end
            return true;--intercept event
        end
    end
    self.m_rewardTips:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_rewardTips:setTouchEnabled(true);
    game_scene:getPopContainer():addChild(self.m_rewardTips);
end





function ui_super_player_main:refreshPage()
	function responseMethod(tag,gameData)
        if gameData then
            local data = gameData:getNodeWithKey("data")
			self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
			self.m_shop_goods = self.m_tGameData.shop_goods
			self:refreshUi()
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_player_index"), http_request_method.GET, {},"super_player_index")
end

function ui_super_player_main:createTime()
	local server_time = game_data:getUserStatusDataByKey("server_time")
	cclog2(server_time)
    if not self.m_tGameData.next_refresh_time or server_time > self.m_tGameData.next_refresh_time then
        return 
    end
    local time = self.m_tGameData.next_refresh_time - server_time
	local function timeEndFunc(label,type)
		self:refreshPage()
    end
	self.m_refresh_time_node:setVisible(true)
	local countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8);
    countdownLabel:setPosition(ccp(0,0))
    countdownLabel:setColor(ccc3(205,182,0))
    if self.m_refresh_time_node ~= nil then
        self.m_refresh_time_node:removeAllChildrenWithCleanup(true)
    end
    self.m_refresh_time_node:addChild(countdownLabel)
    countdownLabel:setTime(time + 1);
end



function ui_super_player_main:refreshUi()
	if not self.bar then self:createProgress() end	
	self.bar:setCurValue(self.m_tGameData.send_bag_times,false);
	local viewSize = self.m_progress_node:getContentSize()
	local Y = self.m_tGameData.send_bag_times/self.my_play_points[3].point
	if Y > 1 then Y = 1 end
	-- self.m_sunny_node:setPositionY(viewSize.height*Y)
	for i=1,3 do
		local point = self.my_play_points[i].point
		if self.m_tGameData.send_bag_times < point then
			self.m_bells[i]:setColor(ccc3(120,120,120))
			self.m_sunny_sps[i]:setVisible(false)
		else
			self.m_bells[i]:setColor(ccc3(255,255,255))
			self.m_sunny_sps[i]:setVisible(true)
		end
	end
	self:refreshShop_goods()
	if self.m_tGameData.bag_info[1] then
		self.m_bag_sp1:setVisible(true)
		self.m_bag_sp2:setVisible(false)
	else
		self.m_bag_sp1:setVisible(false)
		self.m_bag_sp2:setVisible(true)
	end
	self:refreshBroadCastMsg()
	self:createTime()
end



function ui_super_player_main:refreshBroadCastMsg()
    local msgTab = {}
    local msg = {"Bạn không có tin mới",}
    for k,v in pairs(self.m_tGameData.rank_notice or msg) do
    	local str = "Hạng" .. k .. " : " .. v.name .. " Tặng" .. v.score .. "lần lời chúc"               ---------   "第" .. k .. "名: " .. v.server_name or "" .. " "  .. v.name .. " 送出" .. v.score .. "次祝福"
        table.insert(msgTab, str)
    end
    if #msgTab > 0 and self.m_node_bmsgboard then
        game_util:createScrollViewTips(self.m_scroll_msgBoard, msgTab, true, 1, ccc3(255, 255,255), 10)
        self.m_node_bmsgboard:setVisible(true)
    elseif self.m_node_bmsgboard then
        self.m_node_bmsgboard:setVisible(false)
    end
end




function ui_super_player_main:createProgress()
	local maxValue = self.my_play_points[3].point
	local viewSize = self.m_progress_node:getContentSize()
	self.m_count_1:setString(self.my_play_points[1].point)
	self.m_count_2:setString(self.my_play_points[2].point)
	self.m_count_3:setString(self.my_play_points[3].point)
	self.m_discount_node1:setPositionY(viewSize.height*(self.my_play_points[1].point/maxValue))
	self.m_discount_node2:setPositionY(viewSize.height*(self.my_play_points[2].point/maxValue))
	self.m_discount_node3:setPositionY(viewSize.height*(self.my_play_points[3].point/maxValue))
	-- self.m_discount_node4:setPositionX(viewSize.width*(self.m_snowmanMsg[5][4].point/maxValue))

	if not self.bar then
		-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_Chrismas.plist")
		self.bar = ExtProgressTime:createWithFrameName("chrismas_progress_di.png","chrismas_progress.png");
	    self.bar:setScaleX(0.8);
	    self.bar:setMaxValue(maxValue)
	    self.bar:setRotation(-90)
	end
	self.bar:setCurValue(3,false)
    self.bar:setAnchorPoint(ccp(0,0.5))
    self.bar:setPosition(ccp(viewSize.width/2,0))
    self.m_progress_node:addChild(self.bar,10)
end



function ui_super_player_main:init(t_params)
	if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        -- cclog2(self.m_tGameData,"self.m_tGameDataself.m_tGameData   ------ >>>>>>>>>>>>>")
    end
    self.m_shop_goods = self.m_tGameData.shop_goods
    local version = self.m_tGameData.version or 1
    local play_pointsCfg = json.decode(getConfig(game_config_field.play_points):getFormatBuffer())
    -- cclog2(play_pointsCfg,"play_pointsCfg     -------- >>>>>>>>>>>>")
    self.my_play_points = {}
    for i=1,game_util:getTableLen(play_pointsCfg) do
    	local v = play_pointsCfg[tostring(i)] or play_pointsCfg[i]
    	if v.version == version then
    		self.my_play_points[#self.my_play_points+1] = v
    	end
    end
    -- cclog2(self.my_play_points,"self.my_play_points    =====   >>>>>>>>>>>>>")
end





function ui_super_player_main:create(t_params)
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end
return ui_super_player_main