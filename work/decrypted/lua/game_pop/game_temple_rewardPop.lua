local game_temple_rewardPop = {
	m_close_btn = nil,
	m_reward_node = nil,
	m_get_btn = nil,
	m_reward_tab = nil,
	m_root_layer = nil,
	m_opentype = nil,
	m_des_lab = nil,
}

function game_temple_rewardPop.destroy( self )
	self.m_close_btn = nil;
	self.m_reward_node = nil;
	self.m_get_btn = nil;
	self.m_reward_tab = nil;
	self.m_root_layer = nil;
	self.m_opentype = nil;
	self.m_des_lab = nil;
	-- body
end
function game_temple_rewardPop.back( self )
	if self.m_opentype and self.m_opentype == "templeMain" then
		game_scene:enterGameUi("game_godtemple_main",{gameData = nil})
	else
		local function responseMethod( tag,gameData )
			game_scene:enterGameUi("game_godtemple_getTeam",{gameData = gameData})
		end
		local params = {}
		params.is_reap = 0
		network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_temple_index"), http_request_method.GET, params,"god_field_temple_index")
	end-- body
end
function game_temple_rewardPop.createUi( self )
	-- body
	local ccbNode = luaCCBNode:create()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		cclog2(btnTag,"btnTag -- ")
		if btnTag == 101 then
			self:back()
		elseif btnTag == 102 then
			local reward = self.m_tGameData.products or {};
			game_util:rewardTipsByDataTable(reward);
			self.m_get_btn:setTag(103)
		elseif btnTag == 103 then 
			game_util:addMoveTips({text = "您已领取过奖励了"})
		end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_godtemple_reward_pop.ccbi")
	self.m_root_layer = ccbNode:layerForName("m_root_layer")
	self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
	self.m_get_btn = ccbNode:controlButtonForName("m_get_btn")
	self.m_reward_node = ccbNode:nodeForName("m_reward_node")
	self.m_des_lab = ccbNode:labelTTFForName("m_des_lab")
	local function onTouch(eventType, x, y)
	    if eventType == "began" then
	        return true;--intercept event
	    end
	end
	self.m_get_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
	self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
	self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
	self.m_root_layer:setTouchEnabled(true);

	return ccbNode
end
function game_temple_rewardPop.createTableView( self,viewSize )
	local function onBtnCilck( event, target)
		local ccbNode = tolua.cast(target,"CCNode")
		local btnTag = ccbNode:getTag()
		cclog2(btnTag,"btnTag== ")
	 	local rewardInfo = self.m_reward_tab[btnTag]
		game_util:lookItemDetal(rewardInfo)

		-- if self.m_opentype and self.m_opentype == "templeMain" then
		-- 	game_scene:enterGameUi("game_godtemple_main",{gameData = nil})
		-- else
		-- 	local function responseMethod( tag,gameData )
		-- 		game_scene:enterGameUi("game_godtemple_getTeam",{gameData = gameData})
		-- 	end
		-- 	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_temple_index"), http_request_method.GET, {},"god_field_temple_index")
		-- end-- body
	end

	
	local params = {};
	params.viewSize = viewSize;
	params.row = 1;--行
	params.column = 5; --列
	params.totalItem = #self.m_reward_tab
	params.touchPriority = GLOBAL_TOUCH_PRIORITY-3;
	params.direction = kCCScrollViewDirectionHorizontal;
	local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
	params.newCell = function(tableView,index) 
	    local cell = tableView:dequeueCell()
	    if cell == nil then
	        cell = CCTableViewCell:new();
	        cell:autorelease();
	        local ccbNode = luaCCBNode:create();
	        ccbNode:openCCBFile("ccb/ui_godtemple_rewardInfo.ccbi");
	        ccbNode:setAnchorPoint(ccp(0.5,0.5));
	        ccbNode:ignoreAnchorPointForPosition(false)
	        ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
	        cell:addChild(ccbNode,10,10);
	        -- ccbNode:controlButtonForName("btn_accepted"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
	    end
	    if cell then
	        local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
	        local m_teamIcon_sp = ccbNode:spriteForName("m_teamIcon_sp")
	        local m_count_lab = ccbNode:labelTTFForName("m_count_lab")
	        local rewardInfo = self.m_reward_tab[index+1]
	        local icon1,name1,count1 = game_util:getRewardByItemTable(rewardInfo)
	       	if icon1  then 
	       		icon1:setPosition(m_teamIcon_sp:getContentSize().width * 0.5, m_teamIcon_sp:getContentSize().height * 0.5 )
	       		m_teamIcon_sp:addChild(icon1,10,10)
	       		icon1:setScale(0.75)
	       		m_count_lab:setString("x" .. tostring(count1))
	       		m_count_lab:setScale(0.75)
	       		local button = game_util:createCCControlButton("public_skill.png","",onBtnCilck)
	               button:setAnchorPoint(ccp(0.5,0.5))
	               button:setZoomOnTouchDown(false)
	               button:setPosition( m_teamIcon_sp:getContentSize().width * 0.5, m_teamIcon_sp:getContentSize().height * 0.5 )
	               button:setOpacity(0)
	               button:setTag(index+1)
	               button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
	               icon1:addChild(button,10)
	       	else

	       	end
	    end
	    return cell;
	end
	params.itemOnClick = function(eventType,index,item)

	end
	return TableViewHelper:create(params);
	-- body
end
function game_temple_rewardPop.refreshUi( self )
	self.m_reward_node:removeAllChildrenWithCleanup(true)
	local viewSize = self.m_reward_node:getContentSize()
	self.m_reward_node:addChild(self:createTableView(viewSize))
	if self.m_opentype and self.m_opentype == "templeMain" then
		self.m_des_lab:setString("您共有" .. self.m_tGameData.occupied_sum .. "只队伍成功占领采集点，获得资源如下：")
	else
		self.m_des_lab:setString("您当前队伍成功占领采集点，获得资源如下：")

	end-- body
	if next(self.m_reward_tab) then
		self.m_get_btn:setVisible(true) 
	else
		self.m_des_lab:setString("您当前没有可获得的资源")
		self.m_get_btn:setVisible(false)
	end
	-- cclog2(self.m_reward_tab,"xxx =  ")
end
function game_temple_rewardPop.init( self,t_params )
	t_params = t_params or {};
	self.m_opentype = t_params.openType
	self.m_reward_tab = {}
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
	    local data = t_params.gameData:getNodeWithKey("data");
	    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
	elseif t_params.gameData ~= nil and tolua.type(t_params.gameData) == "table" then
	    self.m_tGameData = t_params.gameData
	end
	self.m_reward_tab  = game_util:rewardTipsByDataTableShow(self.m_tGameData.products)
	-- body
end
function game_temple_rewardPop.create( self,params )
	self:init(params)
	local scene = CCScene:create()
	scene = self:createUi(self)
	self:refreshUi()
	return scene
	-- body
end
return game_temple_rewardPop