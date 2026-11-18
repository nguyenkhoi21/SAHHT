local game_godtemple_kuangdian = {
	m_btn_close = nil,
	m_tGameData = nil,
	m_root_layer = nil,
	m_ui_tab = nil,
	m_get_sp = nil,
	m_showType = nil,
	temple_number = nil,
	user_team = nil,
	screenShoot = nil,
	temple_robot = nil,
	m_reward_tab = nil,
	m_refresh_btn = nil,
	m_attackCombat_lab = nil,
	m_combat = nil,
	btn_detail = nil,


}
function game_godtemple_kuangdian.destroy( self )

	self.m_btn_close = nil;
	self.m_tGameData = nil;
	self.m_root_layer = nil;
	self.m_ui_tab = nil;
	self.m_get_sp = nil;
	self.m_showType = nil;
	self.temple_number = nil;
	self.user_team = nil;
	self.screenShoot = nil;
	self.temple_robot = nil;
	self.m_reward_tab = nil;
	self.m_refresh_btn = nil;
	self.m_attackCombat_lab = nil;
	self.m_combat = nil;
	self.btn_detail = nil;
end
function game_godtemple_kuangdian.back( self )
	game_scene:enterGameUi("game_godtemple_main",{gameData = nil})
	-- body
end
function game_godtemple_kuangdian.createUi( self )
	-- body
	local ccbNode = luaCCBNode:create()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 100 then
			self:back()
		elseif btnTag == 101 then
			local function responseMethod( tag,gameData )
				local data = gameData:getNodeWithKey("data");
				data = json.decode(data:getFormatBuffer()) or {};
				self.m_tGameData = data
				self:refreshUi()
			end
			local params = {}
			params.temple_level = self.m_showType
			params.team_index = self.user_team
			params.is_refresh = 1
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_temple_select_enemies"), http_request_method.GET, params,"god_field_temple_select_enemies")
		elseif btnTag>=201 and btnTag<=203 then
			local function responseMethod( tag,gameData )
				local data = gameData:getNodeWithKey("data");
				data = json.decode(data:getFormatBuffer()) or {};
				local data2 = {}
				local alignment_info = data.enemy_alignment_info
				local god_field_ids = data.god_field_ids
				data2 = {alignment_info = alignment_info,god_field_ids = god_field_ids}
                game_scene:enterGameUi("game_godfield_battle_big",{gameData = data2,data1 = data,opentype = "godtemple"})
			end
			local params = {}
			local uid = self.m_tGameData.selected_enemies[tostring(btnTag-200)].uid
			local uidType = string.sub(uid,1,5)
			if uidType == "robot" then
				params.enemy_team = 0
			else
				params.enemy_team = self.m_tGameData.selected_enemies[tostring(btnTag-200)].team_index
			end
			params.enemy_id = tostring(uid)
			params.user_team = self.user_team
			params.temple_level = self.m_showType
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_temple_contend_temple"), http_request_method.GET, params,"god_field_temple_contend_temple")
		elseif btnTag == 555 then
			local activeCfg = getConfig(game_config_field.notice_active)
            local itemCfg = activeCfg:getNodeWithKey( tostring(174) )
            itemCfg = json.decode(itemCfg:getFormatBuffer())
            local openMsg = itemCfg.word
            game_scene:addPop("game_godfield_detail_pop",{openMsg = openMsg})
		end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_godtemple_kuangdian.ccbi")
	self.m_get_sp = ccbNode:spriteForName("m_get_sp")
	self.m_root_layer = ccbNode:layerForName("m_root_layer")
	self.btn_detail = ccbNode:controlButtonForName("btn_detail")
	self.m_refresh_btn = ccbNode:controlButtonForName("m_refresh")
	self.m_btn_close = ccbNode:controlButtonForName("m_btn_close")
	self.m_attackCombat_lab = ccbNode:labelTTFForName("m_attackCombat_lab")
	local x =  game_util:getCombatValue();
	self.m_attackCombat_lab:setString(x)
	local spriteName 
	if self.m_showType == 1 then
		spriteName = "godtemple_lowzi.png"
	elseif self.m_showType == 2 then
		spriteName = "godtemple_midzi.png"
	elseif self.m_showType == 3 then
		spriteName = "godtemple_highzi.png"
	end
	self.m_get_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteName));
	local function onTouch(eventType, x, y)
	    if eventType == "began" then
	        return true;--intercept event
	    end
	end
	self.m_reward_tab = {}
	self.m_ui_tab = {}
	local m_icon_sp,m_name_lab,m_combat_lab,m_resName_lab,m_challenge_btn,m_reward_sp,m_count_lab
	for i=1,6 do
		m_reward_sp = ccbNode:spriteForName("m_reward_sp" .. i)
		m_count_lab = ccbNode:labelTTFForName("m_count_lab" .. i)
		self.m_reward_tab[i] = {m_reward_sp = m_reward_sp,m_count_lab = m_count_lab}
	end
	for i=1,3 do
		m_icon_sp = ccbNode:nodeForName("m_icon_sp" .. i)
		m_name_lab = ccbNode:labelTTFForName("m_name_lab" .. i)
		m_combat_lab = ccbNode:labelTTFForName("m_combat_lab" .. i)
		m_resName_lab = ccbNode:labelTTFForName("m_resName_lab" .. i)
		m_challenge_btn = ccbNode:controlButtonForName("m_challenge_btn" .. i)
		m_challenge_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
		self.m_ui_tab[i] = {m_icon_sp = m_icon_sp,m_name_lab = m_name_lab,
							m_combat_lab = m_combat_lab,m_resName_lab = m_resName_lab,m_challenge_btn = m_challenge_btn}

	end
	self.btn_detail:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
	self.m_refresh_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2);
	self.m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2);
	self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
	self.m_root_layer:setTouchEnabled(true);
	return ccbNode
end
function game_godtemple_kuangdian.setReward( self,i )
	local function onBtnCilck( event, target)
		local ccbNode = tolua.cast(target,"CCNode")
		local btnTag = ccbNode:getTag()
		-- cclog2(btnTag,"btnTag == ")
		local m,n 
		if btnTag == 1 or btnTag == 2 then
			m = 1
			n = btnTag%2
		elseif btnTag == 3 or btnTag == 4 then
			m = 2
			n = btnTag%2
		elseif btnTag == 5 or btnTag == 6 then
			m = 3
			n = btnTag%2
		end
		if n == 0 then
			n = 2 
		end
		local team_reward = self.m_tGameData.selected_enemies[tostring(m)].reward_type

		local reward = self.temple_number[tostring(self.m_showType)][team_reward]

		local info = reward[n]
		game_util:lookItemDetal(info)
	end
	local x,y
	if i == 1 then
		x = 1
		y = 2
	elseif i == 2 then
		x = 3
		y = 4
	elseif i == 3 then
		x = 5
		y = 6
	end

	local team_reward = self.m_tGameData.selected_enemies[tostring(i)].reward_type
	local rewardinfo = self.temple_number[tostring(self.m_showType)][team_reward]
	local icon1,name1,count1 = game_util:getRewardByItemTable(rewardinfo[1])
	local icon2,name2,count2 = game_util:getRewardByItemTable(rewardinfo[2])
	if icon1 and icon2 then 
		icon1:setPosition(self.m_reward_tab[x].m_reward_sp:getContentSize().width * 0.5, self.m_reward_tab[x].m_reward_sp:getContentSize().height * 0.5 )
		self.m_reward_tab[x].m_reward_sp:addChild(icon1,10,10)


		icon2:setPosition(self.m_reward_tab[y].m_reward_sp:getContentSize().width * 0.5, self.m_reward_tab[y].m_reward_sp:getContentSize().height * 0.5 )
		self.m_reward_tab[y].m_reward_sp:addChild(icon2,10,10)


		icon1:setScale(0.8)
		icon2:setScale(0.8)

		self.m_reward_tab[x].m_count_lab:setString("x" .. tostring(count1))
		self.m_reward_tab[y].m_count_lab:setString("x" .. tostring(count2))


		local button = game_util:createCCControlButton("public_skill.png","",onBtnCilck)
        button:setAnchorPoint(ccp(0.5,0.5))
        button:setZoomOnTouchDown(false)
        button:setPosition( self.m_reward_tab[x].m_reward_sp:getContentSize().width * 0.5, self.m_reward_tab[x].m_reward_sp:getContentSize().height * 0.5 )
        button:setOpacity(0)
        button:setTag(x)
        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
        icon1:addChild(button,10)


		local button1 = game_util:createCCControlButton("public_skill.png","",onBtnCilck)
        button1:setAnchorPoint(ccp(0.5,0.5))
        button1:setZoomOnTouchDown(false)
        button1:setPosition( self.m_reward_tab[y].m_reward_sp:getContentSize().width * 0.5, self.m_reward_tab[y].m_reward_sp:getContentSize().height * 0.5 )
        button1:setOpacity(0)
        button1:setTag(y)
        button1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
        icon2:addChild(button1,10)
	else

	end
	-- body
end
function game_godtemple_kuangdian.refrshLabel( self )
	for i=1,3 do
		local uid = self.m_tGameData.selected_enemies[tostring(i)].uid
		local uidType = string.sub(uid,1,5)
		local user_name,combat,role
		if uidType == "robot" then
			local robotId = string.sub(uid,7)
			local robotInfo = self.temple_robot[robotId]
			role = robotInfo.role or 1
			user_name = robotInfo.name
		else
			user_name = self.m_tGameData.selected_enemies[tostring(i)].user_name
			role = self.m_tGameData.selected_enemies[tostring(i)].role or 1
		end
		combat = self.m_tGameData.selected_enemies[tostring(i)].combat
		self.m_ui_tab[i].m_name_lab:setString(user_name)
		self.m_ui_tab[i].m_name_lab:setScale(0.8)
		self.m_ui_tab[i].m_combat_lab:setString("战斗力：" .. tostring(combat))
		self.m_ui_tab[i].m_combat_lab:setScale(0.8)
		local icon = game_util:createPlayerIconByRoleId(tostring(role));
		local icon_alpha = game_util:createPlayerIconByRoleId(tostring(role));
		if icon then
		    self.m_ui_tab[i].m_icon_sp:removeAllChildrenWithCleanup(true);
		    icon_alpha:setAnchorPoint(ccp(1,1))
		    icon_alpha:setPosition(ccp(41,41))
		    icon_alpha:setOpacity(100)
		    icon_alpha:setColor(ccc3(0,0,0))
		    icon_alpha:setScale(0.7)
		    self.m_ui_tab[i].m_icon_sp:addChild(icon_alpha)
		    icon:setAnchorPoint(ccp(1,1))
		    icon:setPosition(ccp(41,41))
		    icon:setScale(0.7)
		    self.m_ui_tab[i].m_icon_sp:addChild(icon);
		else
		    cclog("tempFrontUser.role " .. role .. " not found !")
		end
		self:setReward(i)
	end
end
function game_godtemple_kuangdian.refreshUi( self )
	self:refrshLabel()
end
function game_godtemple_kuangdian.init( self,t_params )
	-- body
	t_params = t_params or {}
	self.m_showType = t_params.showType or 1
	self.user_team  = t_params.user_team or 1

	self.screenShoot = t_params.screenShoot
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
	    local data = t_params.gameData:getNodeWithKey("data");
	    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
	else
	    self.m_tGameData = {};
	end
	local temple_number = {}

	temple_number = getConfig(game_config_field.temple_number)
	self.temple_number = json.decode(temple_number:getFormatBuffer()) or {};
	self.temple_robot = json.decode(getConfig(game_config_field.temple_robot):getFormatBuffer()) or {}; 
end
function game_godtemple_kuangdian.create( self,params )
	self:init(params)
	local scene = CCScene:create()
	scene = self:createUi(self)
	self:refreshUi()
	return scene
	-- body
end
return game_godtemple_kuangdian