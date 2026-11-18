-- 团队副本   第一阶段   稳定时间乱流
local game_teamRaid_first_scene = {
	m_selectTeamBtn = nil,
	m_content_node = nil,
	m_battleAll_node = nil,
	m_ccbNode = nil,
	m_selectButton = nil,
	m_mapId = nil,
	m_tGameData = nil,
	m_selectIndex = nil,
	m_selectBattleType = nil,
	m_EnterFlag = nil,
	m_EnterType = nil,
	m_heroTimes = nil,
}
local btn_lb = {"I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII"}
local attr_tab = {201,202,203}
local occu_tab = {1,2,3}


function game_teamRaid_first_scene:destroy(  )
	-- body
	cclog("  ------------- game_teamRaid_first_scene  destroy  ------------------  ")
	self.m_selectTeamBtn = nil;
	self.m_content_node = nil;
	self.m_battleAll_node = nil;
	self.m_ccbNode = nil;
	self.m_selectButton = nil;
	self.m_mapId = nil;
	self.m_tGameData = nil;
	self.m_selectIndex = nil;
	self.m_selectBattleType = nil;
	self.m_EnterFlag = nil;
	self.m_EnterType = nil;
	self.m_heroTimes = nil;
end


function game_teamRaid_first_scene:back(  )
	-- body
    local function responseMethod( tag, gameData )
        if gameData then
            game_scene:enterGameUi("game_teamRaid_main",{gameData = gameData,enterFlag = self.m_EnterFlag})
        end
    end
    local params = {}
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_index"), http_request_method.GET, nil,"team_raid_index")
end

-- 创建ccbi
function game_teamRaid_first_scene:createUi(  ) -- test_touch
	-- body
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
        	self:back()
    	elseif btnTag == 2 then  -- 出站
    		local function responseMethod( tag, gameData )
	            if gameData then
	            	game_data:setTeamRaidMsg("enterFlag",self.m_EnterFlag)
	            	game_data:setTeamRaidMsg("battleType",self.m_selectBattleType)
	            	game_data:setTeamRaidMsg("raid_id",self.m_tGameData.raid_id)
    				game_data:setBattleType("teamRaid_Battle");
    				game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
	            end
	        end
	        local params = {}
	        params.raid_id = self.m_tGameData.raid_id
	        params.map_id = self.m_mapId
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_fight_stage_1_1"), http_request_method.GET, params,"team_raid_fight_stage_1_1")

        elseif btnTag == 3 then  -- 阵型
		    local function responseMethod( tag, gameData )
	            if gameData then
	            	game_data:setTeamRaidMsg("battleType",self.m_selectBattleType)
	                game_scene:enterGameUi("game_teamRaid_adjust",{gameData = gameData,enterFlag = self.m_EnterFlag,raid_id = self.m_tGameData.raid_id})
	            end
	        end
	        local params = {}
	        params.raid_id = self.m_tGameData.raid_id
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_get_aligment"), http_request_method.GET, params,"team_raid_get_aligment")
        elseif btnTag == 4 then  -- 介绍
            game_scene:addPop("game_godfield_public_detail",{enterType = 204})
    	
        elseif btnTag == 8 then  -- boss介绍

            game_scene:addPop("game_teamRaid_boss_detail",{notice = self.m_boss_des})
    	elseif btnTag > 200 and btnTag < 300 then  -- 选择队伍
    		local index = btnTag - 200 
    		if self.m_selectIndex == index then
			else
				if self.m_selectTeamBtn then
					self.m_selectTeamBtn:setEnabled(true)
				end
	        	local btn = ccbNode:controlButtonForName("m_btn" .. index)
	        	btn:setEnabled(false)
				self.m_selectTeamBtn = btn
				self.m_selectIndex = index
                self:refreshTeamList()
			end


    	end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_teamRaid_first.ccbi");
    local m_btn_close = ccbNode:controlButtonForName("m_btn_close")
    m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    for i=1,12 do
        local node = ccbNode:nodeForName("m_btn_node_" .. i)
        local btn = ccbNode:controlButtonForName("m_btn" .. i)
        local lb = ccbNode:labelTTFForName("m_lb" .. i)
        local lb2 = ccbNode:labelTTFForName("m_lb2" .. i)
        if lb and lb2 and btn_lb[i] then
            lb:setString(btn_lb[i])
            lb2:setString(btn_lb[i])
        end
        if i > 5 then
            btn:setTouchEnabled(false)
            btn:setColor(ccc3(100,100,100))
        end
    end
    self.m_content_node = ccbNode:nodeForName("content_node")
    self.m_battleAll_node = ccbNode:nodeForName("m_battleAll_node")
    self.m_time_node = ccbNode:nodeForName("m_time_node")
    self.m_cdtime_node = ccbNode:nodeForName("m_cdtime_node")
    self.m_time_node1 = ccbNode:nodeForName("m_time_node1")
    self.m_time_node2 = ccbNode:nodeForName("m_time_node2")
    self.m_time_node3 = ccbNode:nodeForName("m_time_node3")
    self.m_btn_battle = ccbNode:controlButtonForName("m_btn_battle")
    self.m_progress_node1 = ccbNode:nodeForName("m_progress_node1")
    self.m_progress_lb = ccbNode:labelTTFForName("m_progress_lb")
    local m_boss_detail = ccbNode:controlButtonForName("m_boss_detail")
	-- m_boss_detail:setOpacity(0)
    self.m_ccbNode = ccbNode;
    return ccbNode
end


function game_teamRaid_first_scene:refreshBtn( )
	-- body
	for i=1,4 do
		local attrNode = self.m_ccbNode:nodeForName("m_attr_node" .. i)
		local occuNode = self.m_ccbNode:nodeForName("m_occu_node" .. i)
		if attr_tab[i] and PUBLIC_ABILITY_TABLE["ability_" .. attr_tab[i]] then
			attrNode:setVisible(true)
			attrNode:removeAllChildrenWithCleanup(true)
			local attrIcon = CCSprite:createWithSpriteFrameName(PUBLIC_ABILITY_TABLE["ability_" .. attr_tab[i]].icon);
		    if attrIcon then
		        attrNode:addChild(attrIcon)
		        local viewSize = attrNode:getContentSize()
		        attrIcon:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
		    end
		else
			attrNode:setVisible(false)
		end

		if occu_tab[i] then
			local occuIcon = CCSprite:createWithSpriteFrameName("public_ocupation" .. i-1 .. ".png");
			occuNode:setVisible(true)
			if occuIcon then
		        occuNode:addChild(occuIcon)
		        local viewSize = occuNode:getContentSize()
		        occuIcon:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
		    end
		else
			occuNode:setVisible(false)
		end

	end
end

function game_teamRaid_first_scene:refreshTeamList(  )
	local team = {}
	local all_team = self.m_tGameData.all_team or {}
	local team_data =all_team["team_" .. self.m_selectIndex] or {}
	local player_data = self.m_tGameData.player_data or {}
	for k,v in pairs(team_data) do
		if v ~= "0" and player_data[v] then
			team[#team+1] = player_data[v]
		end
	end
	local tempTableView = self:createTableView(self.m_content_node:getContentSize(),team)
	self.m_content_node:removeAllChildrenWithCleanup(true)
	if tempTableView then
		self.m_content_node:addChild(tempTableView)
	end
end

function game_teamRaid_first_scene:createTableView( viewSize ,tempTable )
	-- body
	local tempTable = tempTable or {}
	local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tempTable
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 1
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_teamRaid_list_item1.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setScale(0.9)
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
    		local hero_data = tempTable[index+1]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
        	local m_icon_node = ccbNode:nodeForName("m_icon_node")
        	local m_name_node = ccbNode:nodeForName("m_name_node")
        	local m_count_lab = ccbNode:labelTTFForName("m_count_lab")
        	local role = hero_data.role or 1
    	    local roleIcon = game_util:createPlayerRoleGardenIconByRoleId(role)
			if roleIcon then
				local viewSize = m_icon_node:getContentSize()
				m_icon_node:addChild(roleIcon)
				roleIcon:setScale(0.6)
				roleIcon:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
            end
            local tempLabel = game_util:createLabelTTF({text = hero_data.name,color = ccc3(123,255,255),fontSize = 8});
            m_name_node:removeAllChildrenWithCleanup(true)
            if tempLabel then
            	tempLabel:setAnchorPoint(ccp(0,0.5))
            	m_name_node:addChild(tempLabel)
            end
            if self.m_heroTimes[hero_data["uid"]] then
            	m_count_lab:setString(self.m_heroTimes[hero_data["uid"]] .. "/1")
            	m_count_lab:setColor(ccc3(123,255,255))
            else
				m_count_lab:setString("0/1")
            	m_count_lab:setColor(ccc3(255,0,0))
            end

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
    	if eventType == "ended" then
        
    	end
    end
    return TableViewHelper:create(params);
end

function game_teamRaid_first_scene:refreshBattleMsg(  )
	-- body

	local clearance_times = self.m_tGameData.clearance_times_1_1 or {}
	local times = {}
	for k,v in pairs(clearance_times) do
		times[v[1]] = v[2]
	end
	local group_outpost_firstCfg = getConfig(game_config_field.group_outpost_first)
	local map_date = self.m_tGameData.map_date
	local map_type = map_date.map_type or 1
    local group_outpost_enemy = getConfig(game_config_field.group_outpost_enemy)

	local group_outpost_first = json.decode(group_outpost_firstCfg:getFormatBuffer())
	local mapTab = {}
	local all_need_times = 0
	local all_clear_times = 0
	for k,v in pairs(group_outpost_first) do
		if tonumber(v.type) == tonumber(map_type) and v.sort == 1 then
			mapTab[#mapTab+1] = v
			mapTab[#mapTab].id = k
			if times[k] then
				mapTab[#mapTab].times = times[k]
			else
				mapTab[#mapTab].times = 0
			end
			all_need_times = all_need_times + mapTab[#mapTab].need_times
			all_clear_times = all_clear_times +  ((mapTab[#mapTab].times > mapTab[#mapTab].need_times) and mapTab[#mapTab].need_times or mapTab[#mapTab].times )
		end
	end
	table.sort( mapTab,function ( data1,data2 )
		return tonumber(data1.id) < tonumber(data2.id)
	end )

    self.m_battleCCBTab = {}
	local function onMainBtnClick( target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local index = btnTag - 100 
        if self.m_selectBattleType ~= index then
        	if self.m_selectButton then
        		self.m_selectButton:setEnabled(true)
        	end
        	local ccb = self.m_battleCCBTab[index]
        	if ccb then
	    		local m_type_btn = ccb:controlButtonForName("m_type_btn")
	    		m_type_btn:setEnabled(false)
	    		self.m_selectButton = m_type_btn
	    	end
	    	self.m_selectBattleType = index
	    	self.m_mapId = mapTab[index].id
	    	local selData = mapTab[self.m_selectBattleType]
			if selData then
				local enemy_id = selData.enemy_list[1]
			    local enemyData = group_outpost_enemy:getNodeWithKey(enemy_id) and json.decode(group_outpost_enemy:getNodeWithKey(enemy_id):getFormatBuffer())
				self.m_battleAll_node:removeAllChildrenWithCleanup(true)
			    local anim = enemyData.animation
	    		self.m_boss_des = enemyData.des or ""
		    	local mAnimNode = game_util:createSortNode(anim .. ".swf.sam", 0, anim.. ".plist");
				local function onAnimSectionEnd(animNode, theId,theLabelName)
			        animNode:playSection(theLabelName)
			    end
				mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
				mAnimNode:playSection("daiji");
				mAnimNode:setScale(0.75)
		    	self.m_battleAll_node:addChild(mAnimNode)
			end
        end
    end
	for i=1,5 do
		local data = mapTab[i]
		local m_battle_node = self.m_ccbNode:nodeForName("m_battle_node" .. i)
		m_battle_node:removeAllChildrenWithCleanup(true)
		--"ui_teamRaid_first_item1.ccbi"
		local ccbNode = luaCCBNode:create();
	    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
	    ccbNode:openCCBFile("ccb/ui_teamRaid_first_item1.ccbi");
	    m_battle_node:addChild(ccbNode)
	    self.m_battleCCBTab[i] = ccbNode
	    local m_shownode1 = ccbNode:nodeForName("m_shownode1")
	    local m_shownode2 = ccbNode:nodeForName("m_shownode2")
	    m_shownode1:setVisible(true)
	    m_shownode2:setVisible(false)
	    local m_type_btn = ccbNode:controlButtonForName("m_type_btn")
	    local m_type_node = ccbNode:nodeForName("m_type_node")
	    local m_progress_node = ccbNode:nodeForName("m_progress_node1")
	    local m_progress_lb1 = ccbNode:labelTTFForName("m_progress_lb1")
		m_progress_node:removeAllChildrenWithCleanup(true)
		m_type_node:removeAllChildrenWithCleanup(true)
	    local attrTab = PUBLIC_ABILITY_TABLE["ability_" .. data.attr]
	    local enemy_id = data.enemy_list[1]
	    local enemyData = group_outpost_enemy:getNodeWithKey(enemy_id) and json.decode(group_outpost_enemy:getNodeWithKey(enemy_id):getFormatBuffer())
	    if attrTab then
		    -- local attrSp = CCSprite:createWithSpriteFrameName(attrTab.icon)
		    local attrSp = CCSprite:create("icon/" .. enemyData.icon)
		    m_type_btn:setTag(100+i)
		    if self.m_selectBattleType == i then
		    	m_type_btn:setEnabled(false)
		    	self.m_selectButton = m_type_btn
		    	self.m_mapId = mapTab[i].id
		    else
		    	m_type_btn:setEnabled(true)
		    end
		    if attrSp then
		    	m_type_node:addChild(attrSp)
		    	attrSp:setScale(0.4)
		    end
		end
	    local bar = ExtProgressTime:createWithFrameName("ui_teamRaid_first_progress1.png","ui_teamRaid_first_progress2.png");
	    if bar then
		    bar:setScaleX(1);
		    local value = math.floor((data.times/data.need_times) *100)
		    value = value > 100 and 100 or value
		    local viewSize = m_progress_node:getContentSize()
		    m_progress_lb1:setString(value .. "%")
		    bar:setMaxValue(100)
		    bar:setCurValue(value)
		    bar:setAnchorPoint(ccp(0.5,0.5))
		    bar:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
		    m_progress_node:addChild(bar,10)
		end
	end
	self.m_battleAll_node:removeAllChildrenWithCleanup(true)
	local selData = mapTab[self.m_selectBattleType]
	if selData then
		local enemy_id = selData.enemy_list[1]
	    local enemyData = group_outpost_enemy:getNodeWithKey(enemy_id) and json.decode(group_outpost_enemy:getNodeWithKey(enemy_id):getFormatBuffer())
	    local anim = enemyData.animation
	    self.m_boss_des = enemyData.des or ""
    	local mAnimNode = game_util:createSortNode(anim .. ".swf.sam", 0, anim.. ".plist");
		local function onAnimSectionEnd(animNode, theId,theLabelName)
	        animNode:playSection(theLabelName)
	    end
		mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
		mAnimNode:playSection("daiji");
		mAnimNode:setScale(0.75)
    	self.m_battleAll_node:addChild(mAnimNode)

	end
	-- local ccbNode = luaCCBNode:create();
 --    ccbNode:openCCBFile("ccb/ui_teamRaid_first_item1.ccbi");
	-- self.m_battleAll_node:addChild(ccbNode)
	-- local m_shownode1 = ccbNode:nodeForName("m_shownode1")
 --    local m_shownode2 = ccbNode:nodeForName("m_shownode2")
 --    m_shownode1:setVisible(false)
 --    m_shownode2:setVisible(true)
 --    local m_progress_node2 = ccbNode:nodeForName("m_progress_node2")
    self.m_progress_node1:removeAllChildrenWithCleanup(true)
   	local bar = ExtProgressTime:createWithFrameName("ui_teamRaid_new_progress22.png","ui_teamRaid_new_progress2.png");
    if bar then
	    bar:setScaleX(1);
	    local viewSize = self.m_progress_node1:getContentSize()
	    local value = math.floor((all_clear_times/all_need_times) *100)
		value = value > 100 and 100 or value

	    self.m_progress_lb:setString(value .. "%")
	    bar:setMaxValue(100)
	    bar:setCurValue(value)
	    bar:setAnchorPoint(ccp(0.5,0.5))
	    bar:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
		self.m_progress_node1:addChild(bar,10)
	end
	-- for i=1,4 do
	-- 	local data = mapTab[i]
	-- 	local m_type = ccbNode:nodeForName("m_type" .. i)
	-- 	local attrTab = PUBLIC_ABILITY_TABLE["ability_" .. data.attr]
	--     local attrSp = CCSprite:createWithSpriteFrameName(attrTab.icon)
	--     m_type:removeAllChildrenWithCleanup(true)
	--     if attrSp then
	--     	m_type:addChild(attrSp)
	--     	local viewSize = m_type:getContentSize()
	--     	attrSp:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
	--     end
	-- end
end

function game_teamRaid_first_scene:goToWhere(  )
	local function responseMethod( tag, gameData )
	    if gameData then
	        local data = gameData:getNodeWithKey("data")
	        local stage = data:getNodeWithKey("stage"):toInt()
	        local stage_small = data:getNodeWithKey("stage_small") and data:getNodeWithKey("stage_small"):toInt()
	        if stage and stage ~= 0 then
	            if stage == 1 then
	                if stage_small == 1 then
	                    game_scene:enterGameUi("game_teamRaid_first_scene",{gameData = gameData,enterFlag = self.m_EnterFlag,battleType = self.m_selectBattleType})
	                elseif stage_small == 2 then
	                    game_scene:enterGameUi("game_teamRaid_firstBoss_scene",{gameData = gameData,enterFlag = self.m_EnterFlag})
	                end
	            elseif stage == 2 then
	                if stage_small == 1 then
	                    game_scene:enterGameUi("game_teamRaid_last_scene",{gameData = gameData,enterFlag = self.m_EnterFlag})
	                elseif stage_small == 2 then
	                    game_scene:enterGameUi("game_teamRaid_lastBoss_scene",{gameData = gameData,enterFlag = self.m_EnterFlag})
	                end
	            elseif stage == 3 then
	                game_scene:enterGameUi("game_teamRaid_third_scene",{gameData = gameData,enterFlag = self.m_EnterFlag})
	            elseif stage == 999 then
	                game_scene:addPop("game_teamRaid_result_pop",{gameData = gameData,enterFlag = self.m_EnterFlag})
	            end
	        end
	    end
	end
	local params = {}
	params.raid_id = self.m_tGameData.raid_id
	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_persion_raid_index"), http_request_method.GET, params,"team_raid_persion_raid_index")
end

function game_teamRaid_first_scene:refreshTimeLabel( )
	local function timeEndFunc(label,type)
		self:goToWhere()
    end
	local remain_time = self.m_tGameData.remain_time or 0
	local active_remain_time = self.m_tGameData.active_remain_time or 0
	if remain_time > 0 and active_remain_time > 0 then
		self.m_time_node:setVisible(true)
		local countdownLabel1 = game_util:createCountdownLabel(0,timeEndFunc,10);
		local countdownLabel2 = game_util:createCountdownLabel(0,timeEndFunc,10);
	    if self.m_time_node1 then
	        self.m_time_node1:removeAllChildrenWithCleanup(true)
	    end
	    if self.m_time_node2 then
	        self.m_time_node2:removeAllChildrenWithCleanup(true)
	    end
	    self.m_time_node1:addChild(countdownLabel1)
	    self.m_time_node2:addChild(countdownLabel2)
	    countdownLabel1:setAnchorPoint(ccp(0,0.5))
	    countdownLabel2:setAnchorPoint(ccp(0,0.5))
	    countdownLabel1:setTime(remain_time + 1);
	    countdownLabel2:setTime(active_remain_time + 1);
	else
		self:goToWhere()
		return
	end
	local cd_remain_time = self.m_tGameData.cd_remain_time or 0
	if cd_remain_time > 0 then
		self.m_cdtime_node:setVisible(true)
		local countdownLabel1 = game_util:createCountdownLabel(0,timeEndFunc,9);
	    countdownLabel1:setPosition(ccp(0,0))
	    if self.m_time_node3 then
	        self.m_time_node3:removeAllChildrenWithCleanup(true)
	    end
	    self.m_time_node3:addChild(countdownLabel1)
	    countdownLabel1:setAnchorPoint(ccp(0,0.5))
	    countdownLabel1:setTime(cd_remain_time + 1);
	    game_util:setCCControlButtonEnabled(self.m_btn_battle,false)
	else
		self.m_cdtime_node:setVisible(false)
	    game_util:setCCControlButtonEnabled(self.m_btn_battle,true)
	end
end


function game_teamRaid_first_scene:refreshUi(  )
	-- body
	self:refreshTeamList()
    local btn = self.m_ccbNode:controlButtonForName("m_btn" .. self.m_selectIndex)
	btn:setEnabled(false)
	self.m_selectTeamBtn = btn
	self:refreshBattleMsg()
	self:refreshTimeLabel()
end

function game_teamRaid_first_scene:init( t_params )
	-- body
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res_add.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");

    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
       local data = t_params.gameData:getNodeWithKey("data")
       self.m_tGameData = json.decode(data:getFormatBuffer())
    end
    self.m_selectIndex = 1
    self.m_selectBattleType = t_params.battleType or 1
    self.m_EnterFlag = t_params.enterFlag or 2
    self.m_EnterType = t_params.enterType or ""
    self.m_heroTimes = {}
    local persion_clearance_times = self.m_tGameData.persion_clearance_times or {}
    for k,v in pairs(persion_clearance_times) do
    	self.m_heroTimes[v[1]] = v[2]
    end
end

function game_teamRaid_first_scene:create( t_params )
	-- body
	local scene = CCLayer:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end

return game_teamRaid_first_scene