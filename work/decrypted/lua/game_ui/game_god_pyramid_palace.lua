local game_god_pyramid_palace = {
	m_tGameData = nil,

	m_active_list_node = nil,
	m_noactive_list_node = nil,
	m_reward_node = nil,
	m_noactive_sp = nil,
	m_active_sp = nil,
	m_active_time = nil,
	m_att_time = nil,
	m_my_rank_list_node = nil,
	m_rank_list_node = nil,
	m_no_rank = nil,
	isKill = nil,
	m_fight_btn = nil,
	my_uid = nil,
	pos_info = nil,
	check = nil,
	palace_id = nil,
	lucky_floor = nil,
	isActive =  nil,
	boss_iskill = nil,
	page = nil,
	m_node_broadcastboard = nil,
	m_scroll_msgBoard = nil,
}
function game_god_pyramid_palace:destroy(  )
	cclog("-----------game_god_pyramid_palace destroy--------------")
	self.m_tGameData = nil;
	self.m_active_list_node = nil;
	self.m_noactive_list_node = nil;
	self.m_reward_node = nil;
	self.m_noactive_sp = nil;
	self.m_active_sp = nil;
	self.m_active_time = nil;
	self.m_att_time = nil;
	self.m_my_rank_list_node = nil;
	self.m_rank_list_node = nil;
	self.m_no_rank = nil;
	self.isKill = nil;
	self.m_fight_btn = nil;
	self.my_uid = nil;
	self.pos_info = nil;
	self.check = nil;
	self.palace_id = nil;
	self.lucky_floor = nil;
	self.isActive =  nil;
	self.boss_iskill = nil;
	self.page = nil;
	self.m_node_broadcastboard = nil;
	self.m_scroll_msgBoard = nil;
end

function game_god_pyramid_palace:back()
	local function responseMethod( tag,gameData )
		game_scene:enterGameUi("game_god_pyramid_main",{gameData = gameData})
	end
	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("zodiac_index"),http_request_method.GET,nil,"zodiac_index")
end

function game_god_pyramid_palace:createUi( )
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_dart.plist");
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 1 then
			self:back()
		elseif btnTag == 105 then -- 战斗

		elseif btnTag == 500 then
			local god_Star_check_msg = game_data:getGod_Star_check_msg("game_god_pyramid_palace")
			local my_team = nil
			for k,v in pairs(self.m_tGameData.teams) do
				if v.floor == god_Star_check_msg.floor then
					my_team = my_team or {}
					table.insert(my_team,k)
				end
			end
			if my_team == nil then
				game_util:addMoveTips({text = "Ở đây không có đội của bạn, đánh đội khác trước rồi hãy đánh boss"})
			else
				if self.boss_iskill then
					game_util:addMoveTips({text = "Boss đã chết, không thể tấn công"})
					return
				end
				game_data:setGod_Boss_battle_msg({team = my_team,floor = god_Star_check_msg.floor},"  game_god_pyramid_palace  -----------------------------  ")
				local function responseMethod(  tag,gameData )
					game_util:addMoveTips({text = "Đánh boss"})
                	game_scene:addPop("game_godfield_Star_zhenxing",{gameData = gameData,openType = "boss_battle",boss_times = self.m_boss_times})
	            end
	        	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("zodiac_god_field_ids"),http_request_method.GET,nil,"zodiac_god_field_ids")
			end
		end
	end
	local ccbNode = luaCCBNode:create()
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_godfield_Star_palaceL.ccbi")
	local m_xingzuotu = ccbNode:spriteForName("L_xingzuotu")
	self.m_active_list_node = ccbNode:nodeForName("L_active_list_node")
	self.m_noactive_list_node = ccbNode:nodeForName("L_noactive_list_node")
	self.m_reward_node = ccbNode:nodeForName("L_reward_node")
	self.m_noactive_sp = ccbNode:scale9SpriteForName("L_active_sp")
	self.m_active_sp = ccbNode:scale9SpriteForName("L_noactive_sp")
	self.m_active_time = ccbNode:labelTTFForName("L_active_time")
	self.m_att_time = ccbNode:labelTTFForName("L_att_time")
	self.m_my_rank_list_node = ccbNode:nodeForName("my_rank_list_node")
	self.m_rank_list_node = ccbNode:nodeForName("rank_list_node")
	self.m_no_rank = ccbNode:labelTTFForName("no_rank")
	self.isKill = ccbNode:labelTTFForName("isKill")
	self.isKill:setVisible(false)
	local title = ccbNode:spriteForName("L_title")
	local my_rank = ccbNode:spriteForName("my_rank")
	local rank = ccbNode:spriteForName("rank")
	local my_rankttf = ccbNode:labelTTFForName("my_rankttf")
	local rank_ttf = ccbNode:labelTTFForName("rank_ttf")
	self.m_scroll_msgBoard = ccbNode:scrollViewForName("m_scroll_msgBoard")
	self.m_node_broadcastboard = ccbNode:nodeForName("m_node_broadcastboard")

	self.gongzhu_node = ccbNode:nodeForName("gongzhu_node")
	self.gongzhu_liansheng = ccbNode:labelTTFForName("gongzhu_liansheng")
	self.gongzhu_name = ccbNode:labelTTFForName("gongzhu_name")
	self.gongzhu_icon = ccbNode:nodeForName("gongzhu_icon")

	self.zhanshen_node = ccbNode:nodeForName("zhanshen_node")
	self.zhanshen_liansheng = ccbNode:labelTTFForName("zhanshen_lainsheng")
	self.zhanshen_name = ccbNode:labelTTFForName("zhsnehn_name")
	self.zhanshen_icon = ccbNode:nodeForName("zhanshen_icon")

	self.doushen_node = ccbNode:nodeForName("doushen_node")
	self.doushen_liansheng = ccbNode:labelTTFForName("doushen_liansheng")
	self.doushen_name = ccbNode:labelTTFForName("doushen_name")
	self.doushen_icon = ccbNode:nodeForName("icon_sp")
	self.m_lable = ccbNode:labelTTFForName("lable")
	self.m_boss_time = ccbNode:labelTTFForName("boss_time")
	self.m_boss_time_node = ccbNode:nodeForName("m_boss_time_node")
	self.m_time_node = ccbNode:nodeForName("m_time_node")
	self.gongzhu_node:setVisible(false)
	self.zhanshen_node:setVisible(false)
	self.doushen_node:setVisible(false)
	self.m_lable:setVisible(false)
	self.m_boss_time:setVisible(false)
	self.m_boss_time_node:setVisible(false)
	self.m_time_node:setVisible(false)

    if self.m_node_broadcastboard then self.m_node_broadcastboard:setVisible(false) end
	self.m_my_rank_list_node:setVisible(self.isActive)
	self.m_rank_list_node:setVisible(self.isActive)
	self.m_no_rank:setVisible(false)
	my_rank:setVisible(self.isActive)
	rank:setVisible(self.isActive)
	my_rankttf:setVisible(self.isActive)
	rank_ttf:setVisible(self.isActive)

	self.m_fight_btn = ccbNode:controlButtonForName("fight_btn")
    self.m_fight_btn:setOpacity(0);
	title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(GOD_STAR_BTN_ICON[self.palace_id].title))
	local animArr = CCArray:create()
	local rotateBy = CCRotateBy:create(100,360)
	animArr:addObject(rotateBy)
	m_xingzuotu:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
	return ccbNode
end
function game_god_pyramid_palace:createtable( parentsNode , count , pos)
	local leftbutton,rightbutton = self:createBtn()
	local viewSize = parentsNode:getContentSize()
	leftbutton:setScaleX(-1)
	leftbutton:setPosition(ccp(10,viewSize.height/2))
	rightbutton:setPosition(ccp(viewSize.width-10,viewSize.height/2))
	parentsNode:addChild(leftbutton,100,100)
	parentsNode:addChild(rightbutton,100,100)
	local params = {}
	params.row = 1
	params.column = 1
	params.totalItem = count
	params.touchPriority = GLOBAL_TOUCH_PRIORITY
	params.showPoint = false
	local viewSize = parentsNode:getContentSize()
	params.viewSize = viewSize
	params.direction = kCCScrollViewDirectionHorizontal
	params.newCell = function ( tableView,index )
		local cell = tableView:dequeueCell()
		if cell == nil then
			cell = CCTableViewCell:new()
			cell:autorelease()
			local ccbNode = luaCCBNode:create()
			ccbNode:openCCBFile("ccb/ui_god_Star_shipLayer.ccbi")
			ccbNode:setAnchorPoint(ccp(0.5,0.5))
			if ccbNode == nil then return end
			cell:addChild(ccbNode,10,10)
		end
		if cell then
			local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
			if ccbNode then
				local shipLayer = ccbNode:layerForName("L_shipLayer")
				shipLayer:setContentSize(CCSizeMake(viewSize.width-10,viewSize.height))
				if self.isActive then
					ccbNode:setPosition(ccp(viewSize.width/2+5,viewSize.height))
				else
					ccbNode:setPosition(ccp(viewSize.width/2+5,viewSize.height/2))
				end
				self:createShipTable(parentsNode,shipLayer,pos)
			end
		end
		return cell
	end
	params.pageChangedCallFunc = function(totalPage,curPage)
		self.page = curPage
        if curPage == 1 then
            leftbutton:setVisible(false)
        else
            leftbutton:setVisible(true)
        end
        if curPage < totalPage then
            rightbutton:setVisible(true)
        else
            rightbutton:setVisible(false)
        end
    end
	params.itemOnClick = function ( eventType,index,item )
		if eventType == "began" then
			return
		elseif eventType == "ended" then
		end
	end
	return TableViewHelper:createGallery3(params);
end
function game_god_pyramid_palace:createShipTable( parentsNode ,parent, pos )
	local ship_List = self.pos_info
	local viewSize = parent:getContentSize()
	local STindex = {}
	if self.isActive then
		STindex[1] = 0
		STindex[2] = 15
		STindex[3] = 30
		STindex[4] = 45
	else 
		STindex[1] = 0
		STindex[2] = 20
		STindex[3] = 40
	end
	local index = STindex[self.page]
	for i=1,#pos do
		for j=1,#pos[i] do
			index = index + 1
			if not ship_List[tostring(index)] then return end
			local itemCfg = ship_List[tostring(index)]
			local function onMainBtnClick( target,event )
				local tagNode = tolua.cast(target,"CCNode")
				local btnTag = tagNode:getTag()
				local isMine = (ship_List[tostring(btnTag)].uid == self.my_uid)
				local params = {}
				params.floor = self.palace_id
				params.pos = btnTag
				params.uid = ship_List[tostring(btnTag)].uid
				local function responseMethod( tag,gameData )
					local god_Star_check_msg = game_data:getGod_Star_check_msg("game_god_pyramid_palace")
					god_Star_check_msg.pos = btnTag
					game_data:setGod_Star_check_msg(god_Star_check_msg,"game_god_pyramid_palace")
					local isEnemy = false
					if self.enemy_list[params.uid] then
						isEnemy = true
					end
					local isLucky = (btnTag == self.lucky_floor)
					game_scene:addPop("game_godfield_Star_shippop",{gameData = gameData, isMine = isMine, isLucky = isLucky, isEnemy = isEnemy})
				end
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("zodiac_user_info"),http_request_method.GET,params,"zodiac_user_info")
			end
			local ccbNode = luaCCBNode:create()
			ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
			ccbNode:openCCBFile("ccb/ui_godfield_Star_ship_Item.ccbi")
			local my_pos = ccbNode:spriteForName("my_pos")
			local btn = ccbNode:controlButtonForName("btn")
			local m_enemy_sp = ccbNode:spriteForName("m_enemy_sp")
			btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
			my_pos:setVisible(itemCfg.uid == self.my_uid)
			btn:setOpacity(0)
			btn:setTag(index)
			local ship_item = ccbNode:spriteForName("L_ship_sp")
			ship_item:setScale(0.4)
			local nameLb = ccbNode:labelTTFForName("L_name")
			local num = ccbNode:labelTTFForName("L_num")
			local m_node_lucksign = ccbNode:nodeForName("m_node_lucksign")
			local shuangyu = ccbNode:spriteForName("shuangyu")
			shuangyu:setVisible(false)
			if itemCfg then
				cclog2(self.lucky_floor,"self.lucky_floor isisi")
				num:setString(index)
				nameLb:setString(itemCfg.name)
				local isEnemy = false
				if self.enemy_list[itemCfg.uid] then
					isEnemy = true
				end
				if isEnemy then
					m_enemy_sp:setVisible(true)
				else
					m_enemy_sp:setVisible(false)
				end
				if index == self.lucky_floor then
					m_node_lucksign:setVisible(true)
					cclog2("truetruetruetruetrue")
					local lucky_reward = {}
				else 
					m_node_lucksign:setVisible(false)
				end
				local uid = itemCfg.uid
				local team =tonumber(itemCfg.team_id)
				local sp = GOD_STAR_BTN_ICON[self.palace_id].ship_Item
				if self.rank_list[uid] then
					if team == tonumber(self.rank_list[uid].team) then
						sp = "zhanshen_" .. self.rank_list[uid].rank .. ".png"
					elseif team == tonumber(self.rank_list[uid].team2)  then
						sp = "zhanshen_" .. self.rank_list[uid].rank2 .. ".png"	
					elseif team == tonumber(self.rank_list[uid].team3) then
						sp = "zhanshen_" .. self.rank_list[uid].rank3 .. ".png"
					end
					local god_Star_check_msg = game_data:getGod_Star_check_msg("game_god_pyramid_palace")
					if god_Star_check_msg.floor == 12 and sp == "zhanshen_1.png" then
						shuangyu:setVisible(true)
					end
					if sp ~= GOD_STAR_BTN_ICON[self.palace_id].ship_Item then
						ship_item:setScale(1.1)
					else
						ship_item:setScale(0.4)
					end	
				end

				ship_item:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(sp))			
				parent:addChild(ccbNode)
			end
			ccbNode:setAnchorPoint(ccp(0.5,0.5))
			ccbNode:setScale(0.7)
			if #pos == 2 then 
				ccbNode:setPosition(ccp(viewSize.width*pos[i][j],viewSize.height-viewSize.height/#pos*(i-0.5)))
			else 
				ccbNode:setPosition(ccp(viewSize.width*pos[i][j],viewSize.height-viewSize.height/#pos*(i-0.65)))
			end
		end
	end
end

function game_god_pyramid_palace:createBossAnim()
	local anim_node = game_util:createIdelAnim(self.m_tGameData.tiltle_name,0);
	anim_node:setScale(1)
    anim_node:setAnchorPoint(ccp(0.5,0.5))
    local anim_tip = game_util:createEffectAnim("anim_fight_index",1,true)
    anim_tip:setAnchorPoint(ccp(0.5,0.5))
    anim_tip:setPosition(ccp(-50,-120))
    self.m_reward_node:addChild(anim_tip,11,11)
    return anim_node
end
function game_god_pyramid_palace:refreshActivemsg()
	local msg = self.m_tGameData.boss_info
	if msg.self_rank then
		if msg.hp == 0 then
			self.isKill:setVisible(true)
			self.boss_iskill = true
		end
		local rank1 = msg.self_rank
		local check = game_data:getGod_Star_check_msg(" game_god_pyramid_palace ")
		local floor1 = self.palace_id
		local rank2,floor2 =game_data:getGod_Boss_rank_msg("game_god_pyramid_palace")
		if rank2 then
			for i=1,3 do
				if rank1[tostring(i)] > rank2[tostring(i)] and floor1 == floor2 then
					game_util:addMoveTips({text = "Nhóm" .. i .. "của bạn tăng hạng " .. rank1[tostring(i)] .. "sát thương" .. msg.self_hurt[tostring(i)]})
				end
			end
		end
		game_data:setGod_Boss_rank_msg(rank1,self.palace_id,"game_god_pyramid_palace")
		local function timeEndFunc(label,type)
			local check = game_data:getGod_Star_check_msg("game_god_Star_employ")
			local function responseMethod( tag,gameData )
                game_scene:enterGameUi("game_god_pyramid_palace",{gameData = gameData,palace_id = check.floor})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("zodiac_go_fight"),http_request_method.GET,{floor = check.floor},"zodiac_go_fight")
        end
        self.m_boss_time_node:setVisible(true)
		self.m_active_time:setString("")
		local countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8);
        countdownLabel:setPosition(ccp(self.m_boss_time_node:getContentSize().width*0.5,self.m_boss_time_node:getContentSize().height*0.5))
        if self.m_boss_time_node ~= nil then
            self.m_boss_time_node:removeAllChildrenWithCleanup(true)
        end
        self.m_boss_time_node:addChild(countdownLabel)
        countdownLabel:setTime(msg.over_time + 1);
		local bar = ExtProgressTime:createWithFrameName("gvg_def_hp.png","gvg_att_hp.png");
        bar:setScaleX(1.5);
        bar:setMaxValue(msg.max_hp)
        bar:setCurValue(msg.hp,false);
        bar:setAnchorPoint(ccp(0.5,0.5))
        bar:setPosition(ccp(0,10))
        self.m_reward_node:addChild(bar,10)
      	self.m_rank_list_node:addChild(self:createRanklist(self.m_rank_list_node:getContentSize(),msg.user_rank,6,false))
	 	local data = self:refreshMyTeamHurt(msg)
	 	if data[1] == nil then 
	 		self.m_no_rank:setVisible(true)
	 	else
	 		self.m_my_rank_list_node:addChild(self:createRanklist(self.m_my_rank_list_node:getContentSize(),data,3,true))
	 	end
	 end
end

function game_god_pyramid_palace:createBtn()
    local leftbutton = CCSprite:createWithSpriteFrameName("routes_jiantou.png")
    leftbutton:setAnchorPoint(ccp(0.5,0.5))
    local rightbutton = CCSprite:createWithSpriteFrameName("routes_jiantou.png")
    rightbutton:setAnchorPoint(ccp(0.5,0.5))
    return leftbutton,rightbutton
end


function game_god_pyramid_palace:refreshPalaceMsg()
	local rank_info = self.rank_vin_times_info
	if rank_info[1] then
		self.gongzhu_node:setVisible(true)
		self.gongzhu_liansheng:setString("Trận "..rank_info[1].vin_times )
		self.gongzhu_name:setString(rank_info[1].name)
		local humen_role = json.decode(self.role_detail:getNodeWithKey(tostring(rank_info[1].role)):getFormatBuffer())
		local icon_sp = CCSprite:create("humen/" .. humen_role.icon .. "_b.png")
		if icon_sp then
			icon_sp:setPosition(ccp(0,0))
			icon_sp:setScale(0.6)
			self.gongzhu_icon:addChild(icon_sp)
		end
	end
	if rank_info[2] then
		self.zhanshen_node:setVisible(true)
		self.zhanshen_liansheng:setString("Trận "..rank_info[2].vin_times)
		self.zhanshen_name:setString(rank_info[2].name)
		local humen_role = json.decode(self.role_detail:getNodeWithKey(tostring(rank_info[2].role)):getFormatBuffer())
		local icon_sp = CCSprite:create("humen/" .. humen_role.icon .. "_b.png")
		if icon_sp then
			icon_sp:setPosition(ccp(0,0))
			icon_sp:setScale(0.45)
			self.zhanshen_icon:addChild(icon_sp)
		end
	end
	if rank_info[3] then
		self.doushen_node:setVisible(true)
		self.doushen_liansheng:setString("Trận "..rank_info[3].vin_times )
		self.doushen_name:setString(rank_info[3].name)
		local humen_role = json.decode(self.role_detail:getNodeWithKey(tostring(rank_info[3].role)):getFormatBuffer())
		local icon_sp = CCSprite:create("humen/" .. humen_role.icon .. "_b.png")
		if icon_sp then
			icon_sp:setPosition(ccp(0,0))
			icon_sp:setScale(0.45)
			self.doushen_icon:addChild(icon_sp)
		end
	end
	self.m_lable:setVisible(true)
	self.m_boss_time:setVisible(true)
	self.m_boss_time_node:setVisible(true)
	local function timeEndFunc(label,type)
		local check = game_data:getGod_Star_check_msg("game_god_Star_employ")
		local function responseMethod( tag,gameData )
            game_scene:enterGameUi("game_god_pyramid_palace",{gameData = gameData,palace_id = check.floor})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("zodiac_go_fight"),http_request_method.GET,{floor = check.floor},"zodiac_go_fight")
    end
	self.m_boss_time:setString("")
	self.m_time_node:setVisible(true)
	local countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8);
    countdownLabel:setPosition(ccp(0,0))
    if self.m_time_node ~= nil then
        self.m_time_node:removeAllChildrenWithCleanup(true)
    end
    self.m_time_node:addChild(countdownLabel)
    if self.m_tGameData.boss_info.start_time then
    	countdownLabel:setTime(self.m_tGameData.boss_info.start_time + 1);
    end
end


function game_god_pyramid_palace:refreshUi()
	self.m_active_list_node:removeAllChildrenWithCleanup(true)
	self.m_active_list_node:setVisible(false)
	self.m_active_sp:setVisible(false)
	self.m_noactive_list_node:removeAllChildrenWithCleanup(true)
	self.m_noactive_list_node:setVisible(false)
	self.m_noactive_sp:setVisible(false)
	local pos1,pos2 = self:refreshPos()
	if self.isActive then
		self.m_reward_node:setVisible(true)
		self.m_active_list_node:setVisible(true)
		self.m_active_sp:setVisible(true)
		self.m_active_list_node:addChild(self:createtable(self.m_active_list_node,4,pos1))
		local boss = self:createBossAnim()
		boss:setPosition(ccp(0,-70))
		self.m_reward_node:addChild(boss,12,12)
		self.m_fight_btn:setVisible(true)
		self:refreshActivemsg()
	else
		self.m_reward_node:setVisible(false)
		self.m_noactive_list_node:setVisible(true)
		self.m_noactive_sp:setVisible(true)
		self.m_noactive_list_node:addChild(self:createtable(self.m_noactive_list_node,3,pos2))
		self.m_fight_btn:setVisible(false)
		self:refreshPalaceMsg()
	end
end

function game_god_pyramid_palace:createRanklist( viewSize,List_data , row,ismine)
	local params = {}
	params.viewSize = viewSize
	params.row = row
	params.column = 1
	params.touchPriority = GLOBAL_TOUCH_PRIORITY - 3
	params.totalItem = #List_data
	params.direction = kCCScrollViewDirectionVertical
	local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row)
	params.newCell = function ( tableView,index )
		local item_data = List_data[index+1]
		local cell = tableView:dequeueCell()
		if cell == nil then
			cell = CCTableViewCell:new()
			cell:autorelease()
			local ccbNode = luaCCBNode:create()
			ccbNode:openCCBFile("ccb/ui_god_Star_rank_item.ccbi")
			if ccbNode == nil then return end
			ccbNode:setScale(0.6)
			ccbNode:setAnchorPoint(ccp(0.5,0.5))
			cell:addChild(ccbNode,10,10)
		end
		if cell then
			local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
			if ccbNode then
				local zhenxing = ccbNode:labelTTFForName("zhenxing")
				local num = ccbNode:labelTTFForName("number")
				local self_rank = ccbNode:labelTTFForName("my_rank")
				local name = ccbNode:labelTTFForName("name")
				local hurt = ccbNode:labelTTFForName("hurt")
				local rank = ccbNode:labelTTFForName("rank")
				if ismine then
					name:setVisible(false)
					rank:setVisible(false)
					num:setString(item_data.team_id)
					hurt:setString(item_data.hurt)
					self_rank:setString("Top " .. item_data.rank )
					ccbNode:setPosition(ccp(0,itemSize.height*0.5))
				else
					ccbNode:setPosition(ccp(25,itemSize.height*0.5))
					num:setString(item_data.team)
					name:setString(item_data.name)
					rank:setString(index + 1 .. ".")
					hurt:setString(item_data.hurt)
					zhenxing:setVisible(ismine)
					num:setVisible(ismine)
					self_rank:setVisible(ismine)
				end
			end
		end
		return cell
	end
	params.itemOnClick = function ( eventType,index,item )
		if eventType == "began" then
			return
		elseif eventType == "ended" then
		end
	end
	return TableViewHelper:create(params); 
end


function game_god_pyramid_palace:refreshMyTeamHurt(msg)
	local data = {}
	for k,v in pairs(msg.self_rank) do
		if v ~= 0 then
			data[#data+1] ={}
			data[#data].team_id = k
			data[#data].rank = v
		end
	end
	local len = game_util:getTableLen(data)
	for i=1,len do
		data[i].hurt = msg.self_hurt[data[i].team_id]
	end
	return data
end
function game_god_pyramid_palace:refreshPos(  )
	local pos1 = {}
	pos1[1]={}
	pos1[2]={}
	for i=1,7 do
		pos1[1][i] = 1/7*(i-0.5);
	end
	for i=1,8 do
		pos1[2][i] = 1/8*(i-0.5);
	end
	local pos2 = {}
	pos2[1]={}
	pos2[2]={}
	pos2[3]={}
	for i=1,7 do
		pos2[1][i] = 1/7*(i-0.5);
	end
	for i=1,6 do
		pos2[2][i] = 1/6*(i-0.5);
	end
	for i=1,7 do
		pos2[3][i] = 1/7*(i-0.5);
	end
	return pos1,pos2
end
function game_god_pyramid_palace:init( t_params )
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_gvg_new.plist");
	self.role_detail = getConfig(game_config_field.role_detail);
	t_params = t_params or {}
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
		local data = t_params.gameData:getNodeWithKey("data")
		self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
	end
	self.rank_vin_times_info = self.m_tGameData.rank_vin_times_info or {}
	self.enemy_list = {}
	local enemy_info = self.m_tGameData.enemy_info or {}
	for k,v in pairs(enemy_info) do
		self.enemy_list[v] = k
	end
	-- cclog2(self.rank_vin_times_info)
	-- cclog2(self.enemy_info)
	self.rank_list = {}
	for k,v in pairs(self.rank_vin_times_info) do
		if self.rank_list[v.uid] then
			if self.rank_list[v.uid].team2 then
				self.rank_list[v.uid].team3 = v.team
				self.rank_list[v.uid].vin_times3 =v.vin_times
				self.rank_list[v.uid].rank3 = k
			else
				self.rank_list[v.uid].team2 = v.team
				self.rank_list[v.uid].vin_times2 =v.vin_times
				self.rank_list[v.uid].rank2 = k
			end
		else 
			self.rank_list[v.uid] = v
			self.rank_list[v.uid].rank = k
		end
	end
	self.my_uid = game_data:getUserStatusDataByKey("uid") or ""
	self.pos_info = self.m_tGameData.pos_info
	self.check = 0
	self.palace_id = t_params.palace_id
	local god_Star_check_msg = game_data:getGod_Star_check_msg("game_god_pyramid_palace") or {}
	god_Star_check_msg.floor = self.palace_id
	game_data:setGod_Star_check_msg(god_Star_check_msg,"game_god_pyramid_palace")
	local check = game_data:getGod_Star_check_msg(" game_god_pyramid_palace ")
	self.lucky_floor = self.m_tGameData.lucky_situation[check.floor]
	cclog2(self.m_tGameData.lucky_situation,"self.m_tGameData.lucky_situation isisi")
	self.isActive =  self.m_tGameData.isactive
	self.boss_iskill = false
	self.page = 1
	self.m_boss_times = self.m_tGameData.team_fight_boss_times
end




  -- 1 = {
  --   level     = 150
  --   vin_times = 1
  --   uid       = "h12186245"
  --   role      = 4
  --   is_in     = 0
  --   name      = "Ê≤âÈùôÁöÑ‰Ω©‰Ω©"
  --   team      = "1"
  -- }
function game_god_pyramid_palace:create( t_params )
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end

return game_god_pyramid_palace