local game_god_pyramid_main = {
	m_tGameData = nil,
	check = nil,
	list_node = nil,
	reward_list = nil,
	no_reward = nil,
	my_pos_node = nil,
	no_pos = nil,
	L_title = nil,
}
function game_god_pyramid_main:destroy()
	cclog("-----------game_god_pyramid_main destroy--------------")
	self.m_tGameData = nil;
	self.check = nil;
	self.list_node = nil;
	self.reward_list = nil;
	self.no_reward = nil;
	self.my_pos_node = nil;
	self.no_pos = nil;
	self.L_title = nil;
end

function game_god_pyramid_main:back()
	local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_godfield_mainBig",{gameData = gameData})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")
end

function game_god_pyramid_main:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 1 then
			self:back()
		elseif btnTag == 101 then -- 详情
			game_scene:addPop("game_godfield_detail_pop",{openMsg=self.m_tGameData["regular"]})
		elseif btnTag == 102 then -- 战报
			local function responseMethod(tag,gameData)
                self.m_tickFlag = true;
                if gameData == nil then return end
                game_scene:addPop("game_god_palace_battle_log",{gameData = gameData,logType = "battle_log"})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("zodiac_battle_log"), http_request_method.GET, nil,"zodiac_battle_log",true,true)
        elseif btnTag == 103 then -- 仇人
			local function responseMethod(tag,gameData)
				if gameData then
					game_scene:addPop("game_god_enemy_pop", {gameData = gameData})
				end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("enemy_index"), http_request_method.GET, nil,"enemy_index")
		elseif btnTag == 105 then -- 战斗
			if self.check == 0 then
				game_util:addMoveTips({ text = "Chọn 1 tòa cung điện trước!"})
				return
			end
			local function responseMethod(  tag,gameData )
				game_scene:enterGameUi("game_god_pyramid_palace",{gameData = gameData , palace_id = self.check})
			end
			local params = {}
			params.floor = self.check
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("zodiac_go_fight"),http_request_method.GET,params,"zodiac_go_fight")
		elseif btnTag == 110 then
			local function responseMethod( tag,gameData )
				game_scene:addPop("ui_god_palace_task_pop", {gameData = gameData})
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("zodiac_wanted_index"),http_request_method.GET,nil,"zodiac_wanted_index")
		end
	end
	local ccbNode = luaCCBNode:create()
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_godfield_Star_palace.ccbi")
	local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    
	local m_xingzuotu = ccbNode:spriteForName("L_xingzuotu")
	self.list_node = ccbNode:nodeForName("L_Star_list_node")
	self.reward_list = ccbNode:nodeForName("reward_list")
	self.no_reward = ccbNode:labelTTFForName("no_reward")
	self.m_times_lb = ccbNode:labelTTFForName("times_lb")
	self.my_pos_node = ccbNode:nodeForName("my_posn_ode")
	self.no_pos = ccbNode:labelTTFForName("no_pos")
	self.m_reward_node = ccbNode:nodeForName("m_reward_node")
	self.m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
	self.m_r_node = ccbNode:nodeForName("m_r_node")
	self.m_scroll_msgBoard = ccbNode:scrollViewForName("m_scroll_msgBoard")
	self.m_node_broadcastboard = ccbNode:nodeForName("m_node_broadcastboard")
	self.m_lable = ccbNode:labelTTFForName("lable")
	self.m_boss_time = ccbNode:labelTTFForName("boss_time")
	self.m_zhanshen_node = ccbNode:nodeForName("zhanshen_node")
	self.m_gongzhu_liansheng = ccbNode:labelTTFForName("gongzhu_liansheng")
	self.m_gongzhu_name = ccbNode:labelTTFForName("gongzhu_name")
	self.m_icon_sp = ccbNode:nodeForName("icon_sp")
	self.m_wuxianzhi_sp = ccbNode:spriteForName("m_wuxianzhi_sp")
	self.m_zhanshen_node:setVisible(false)
	self.m_r_node:setVisible(false)
	self.no_reward:setVisible(false)
	self.L_title = ccbNode:spriteForName("L_title")
	local animArr = CCArray:create()
	local rotateBy = CCRotateBy:create(100,360)
	animArr:addObject(rotateBy)
	m_xingzuotu:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
	return ccbNode
end
function game_god_pyramid_main:createTableView( viewSize )
	local params = {}
	local list = {}
	params.viewSize = viewSize
	params.row = 1
	params.column = 7
	params.touchPriority = GLOBAL_TOUCH_PRIORITY - 2
	params.totalItem = 12
	params.direction = kCCScrollViewDirectionHorizontal
	local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row)
	params.newCell = function ( tableView,index )
		local cell = tableView:dequeueCell()
		if cell == nil then
			cell = CCTableViewCell:new()
			cell:autorelease()
			local ccbNode = luaCCBNode:create()
			ccbNode:openCCBFile("ccb/ui_godfield_Star_item.ccbi")
			if ccbNode == nil then return end
			ccbNode:setScale(0.7)
			ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
			cell:addChild(ccbNode,10,10)
		end
		if cell then
			local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
			if ccbNode then
				local m_Star_sp1 = ccbNode:spriteForName("L_Star_sp1")
				local m_Star_sp2 = ccbNode:spriteForName("L_Star_sp2")
				if m_Star_sp1 and m_Star_sp2 then
					if index + 1 == self.check then
						m_Star_sp1:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(GOD_STAR_BTN_ICON[index+1].icon_01))
					else
						m_Star_sp1:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(GOD_STAR_BTN_ICON[index+1].icon_02))
					end
					m_Star_sp2:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(GOD_STAR_BTN_ICON[index+1].star))
				end
				list[index+1] = ccbNode
			end
		end
		return cell
	end
	params.itemOnClick = function ( eventType,index,item )
		if eventType == "began" then
			return
		elseif eventType == "ended" then
			self.check = index + 1   
			if self.check ~= 0 then
				self.m_r_node:setVisible(true)
				self:createReward()
			end
			self.L_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(GOD_STAR_BTN_ICON[self.check].title))
			for i=1,#list do
				local ccbNode =list[i]
				if ccbNode then
					local m_Star_sp1 = ccbNode:spriteForName("L_Star_sp1")
					if i == self.check then
						m_Star_sp1:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(GOD_STAR_BTN_ICON[i].icon_01))
						ccbNode:setScale(0.85)
					else
						m_Star_sp1:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(GOD_STAR_BTN_ICON[i].icon_02))
						ccbNode:setScale(0.7)
					end
				end
			end
		end
	end
	return TableViewHelper:create(params); 
end

function game_god_pyramid_main:createReward()
	local reward =json.decode(self.m_constellation_reward:getNodeWithKey(tostring(self.check)):getNodeWithKey("reward_boss1"):getFormatBuffer())
	local palaceCfg = json.decode(self.m_constellation_detail:getNodeWithKey(tostring(self.check)):getFormatBuffer())
	if palaceCfg then
		if palaceCfg.limit_capacity ~= 0 then
			self.m_combat_label:setVisible(true)
			self.m_wuxianzhi_sp:setVisible(false)
			self.m_combat_label:setString(palaceCfg.limit_capacity)
		else
			self.m_wuxianzhi_sp:setVisible(true)
			self.m_combat_label:setVisible(false)
		end
	end
	self.m_reward_node:removeAllChildrenWithCleanup(true)
	if reward then
		local x = self:createReward_List(self.m_reward_node:getContentSize(),reward)
		self.m_reward_node:addChild(x)
	end
	local check_msg = self.vin_times_rank[tostring(self.check)]
	if check_msg then
		self.m_zhanshen_node:setVisible(true)
		self.m_gongzhu_liansheng:setString("Trận "..check_msg.vin_times)
		self.m_gongzhu_name:setString(check_msg.name or "nobody")
		local role = check_msg.role or 1
		local humen_role = json.decode(self.role_detail:getNodeWithKey(tostring(role)):getFormatBuffer())
		local icon_sp = CCSprite:create("humen/" .. humen_role.icon .. "_b.png")
		if icon_sp then
			icon_sp:setPosition(ccp(0,0))
			icon_sp:setScale(0.6)
			self.m_icon_sp:addChild(icon_sp)
		end
	else
		self.m_zhanshen_node:setVisible(false)
	end
end
function game_god_pyramid_main:createReward_List(viewSize, reward)
	local params = {}
	local list = {}
	for k,v in pairs(reward) do
		table.insert(list,v)
	end
	if #list == 0 then  return  end
 	params.viewSize = viewSize
	params.row = 1
	params.column = 2
	params.touchPriority = GLOBAL_TOUCH_PRIORITY - 3
	params.totalItem = #list
	params.direction = kCCScrollViewDirectionHorizontal
	local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row)
	params.newCell = function ( tableView,index )
		local itemCfg = list[index+1]
		local icon,name,count = game_util:getRewardByItemTable(itemCfg);
		local cell = tableView:dequeueCell()
		if cell == nil then
			cell = CCTableViewCell:new()
			cell:autorelease()
		end
		if cell then
			if icon then
                icon:setAnchorPoint(ccp(0.5, 0.5))
                icon:setPosition( itemSize.width/2, itemSize.height * 0.5 +4)
                icon:setScale(0.7)
                cell:addChild(icon, 10, 20)
                if name and count then
                    local labelName = game_util:createLabelBMFont({text = name .. "x" .. count, scale =1, color = ccc3(255, 255, 255)})
                    labelName:setAnchorPoint(ccp(0.5, 1))
                    labelName:setPosition(icon:getContentSize().width * 0.5,  -4 )
                    icon:addChild(labelName, 10)
                end
            end
		end
		return cell
	end
	params.itemOnClick = function ( eventType,index,item )
		if eventType == "began" then
			return
		elseif eventType == "ended" then
			 game_util:lookItemDetal( list[index + 1] )
		end
	end
	return TableViewHelper:create(params); 
end

function game_god_pyramid_main:createMyPos( viewSize )
	local params = {}
	local list = {}
	local teams = self.m_tGameData.teams
	for i=1,3 do
		if teams[tostring(i)].floor ~= 0 then
			table.insert(list,teams[tostring(i)])
			list[#list].team = i
		end
	end
	if #list == 0 then
		self.no_pos:setVisible(true)
	else 
		self.no_pos:setVisible(false)
	end
	params.viewSize = viewSize
	params.row = 3
	params.column = 1
	params.touchPriority = GLOBAL_TOUCH_PRIORITY - 2
	params.totalItem = #list
	params.direction = kCCScrollViewDirectionVertical
	local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row)
	params.newCell = function ( tableView,index )
		local cell = tableView:dequeueCell()
		local item_data = list[index+1]
		if cell == nil then
			cell = CCTableViewCell:new()
			cell:autorelease()
			local ccbNode = luaCCBNode:create()
			ccbNode:openCCBFile("ccb/ui_god_Star_pos_item.ccbi")
			if ccbNode == nil then return end
			ccbNode:setScale(0.6)
			ccbNode:setAnchorPoint(ccp(0.5,0.5))
			cell:addChild(ccbNode,10,10)
		end
		if cell then
			local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
			if ccbNode then
				ccbNode:setPosition(ccp(0,itemSize.height/2))
				local zhenxing = ccbNode:labelTTFForName("zhenxing")
				local num = ccbNode:labelTTFForName("number")
				local self_rank = ccbNode:labelTTFForName("my_rank")
				local name = ccbNode:labelTTFForName("name")
				local hurt = ccbNode:labelTTFForName("hurt")
				local rank = ccbNode:labelTTFForName("rank")
					name:setVisible(false)
					rank:setVisible(false)
					num:setString(item_data.team)
					hurt:setString(GOD_STAR_BTN_ICON[tonumber(item_data.floor)].name)
					self_rank:setString("Ô" .. item_data.pos)
			end
		end
		return cell
	end
	params.itemOnClick = function ( eventType,index,item )
		if eventType == "began" then
			return
		elseif eventType == "ended" then
			self.check = list[index + 1].floor
			local function responseMethod(  tag,gameData )
				game_scene:enterGameUi("game_god_pyramid_palace",{gameData = gameData , palace_id = self.check})
			end
			local params = {}
			params.floor = self.check
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("zodiac_go_fight"),http_request_method.GET,params,"zodiac_go_fight")
		end
	end
	return TableViewHelper:create(params); 
end




function game_god_pyramid_main:createRewardTableView( viewSize )
	local params = {}
	local list = {}
	local reward_data = self.m_tGameData.team_reward
	for k,v in pairs(reward_data) do
		for m,n in pairs(v) do
			table.insert(list,n)
		end
	end
	if #list == 0 then self.no_reward:setVisible(true) return  end
	 function onBtnCilck( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        game_util:lookItemDetal( list[btnTag] )
    end
 	params.viewSize = viewSize
	params.row = 2
	params.column = 3
	params.touchPriority = GLOBAL_TOUCH_PRIORITY - 3
	params.totalItem = #list
	params.direction = kCCScrollViewDirectionVertical
	local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row)
	params.newCell = function ( tableView,index )
		local itemCfg = list[index+1]
		local icon,name,count = game_util:getRewardByItemTable(itemCfg);
		local cell = tableView:dequeueCell()
		if cell == nil then
			cell = CCTableViewCell:new()
			cell:autorelease()
		end
		if cell then
			if icon then
                icon:setAnchorPoint(ccp(0.5, 0.5))
                icon:setPosition( itemSize.width/2, itemSize.height * 0.5 +4)
                icon:setScale(0.65)
                cell:addChild(icon, 10, 20)
                if name and count then
                    local labelName = game_util:createLabelBMFont({text = name .. "x" .. count, scale = 0.9, color = ccc3(255, 255, 255)})
                    labelName:setAnchorPoint(ccp(0.5, 1))
                    labelName:setPosition(icon:getContentSize().width * 0.5,  -2 )
                    icon:addChild(labelName, 10)
                end
            end
		end
		return cell
	end
	params.itemOnClick = function ( eventType,index,item )
		if eventType == "began" then
			return
		elseif eventType == "ended" then
			 game_util:lookItemDetal( list[index + 1] )
		end
	end
	return TableViewHelper:create(params); 
end



function game_god_pyramid_main:refreshBroadCastMsg()
    local msgTab = {}
    local msg = {"Không có tin mới",}
    for k,v in pairs(self.m_tGameData.zodiac_notice or msg) do
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


function game_god_pyramid_main:refreshUi( )
	self.list_node:removeAllChildrenWithCleanup(true)
	self.list_node:addChild(self:createTableView(self.list_node:getContentSize()))
	self.reward_list:removeAllChildrenWithCleanup(true)
	local team_reward = self:createRewardTableView(self.reward_list:getContentSize())
	if team_reward then	self.reward_list:addChild(team_reward) end
	self.my_pos_node:addChild(self:createMyPos(self.my_pos_node:getContentSize()))
	if self.m_tGameData.challenge_times and self.m_times_lb then
		self.m_times_lb:setString(self.m_tGameData.challenge_times)
	end
	self:refreshBroadCastMsg()
end


function game_god_pyramid_main:init( t_params )
	self.role_detail= getConfig(game_config_field.role_detail);
	t_params = t_params or {}
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
		local data = t_params.gameData:getNodeWithKey("data")
		self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
	end
	self.vin_times_rank = self.m_tGameData.vin_times_rank
	-- cclog2(self.m_tGameData,"game_god_pyramid_main ----------------- self.m_tGameData ")
	-- cclog2(self.vin_times_rank,"game_god_pyramid_main ----------------- self.m_tGameData ")
	self.check = 0
	self.m_constellation_reward = getConfig(game_config_field.constellation_reward) or {};
	self.m_constellation_detail = getConfig(game_config_field.constellation_detail) or {}
end

function game_god_pyramid_main:create( t_params )
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end

return game_god_pyramid_main