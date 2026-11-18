-- 团队副本   第二阶段   突破远古魔障
local game_teamRaid_last_scene = {
	m_boss_btn = nil,
	m_selNode1 = nil,
	m_selNode2 = nil,
	m_content_node = nil,
	m_ccbNode = nil,
	m_boss_position = nil,
	m_line1 = nil,
	m_line2 = nil,
	m_selRow = nil,
	m_selCol = nil,
	m_selectTeamBtn = nil,
	m_tGameData = nil,
	m_EnterFlag = nil,
	m_EnterType = nil,
	m_showPos = nil,
	m_selectIndex = nil,
	m_heroTimes = nil,

}
local btn_lb = {"I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII"}
local attr_tab = {201,202,203}
local occu_tab = {1,2,3}
function game_teamRaid_last_scene:destroy(  )
	-- body

	cclog("  -------------  game_teamRaid_last_scene   destroy   -------------- ")
	self.m_boss_btn = nil;
	self.m_selNode1 = nil;
	self.m_selNode2 = nil;
	self.m_content_node = nil;
	self.m_ccbNode = nil;
	self.m_boss_position = nil;
	self.m_line1 = nil;
	self.m_line2 = nil;
	self.m_selRow = nil;
	self.m_selCol = nil;
	self.m_selectTeamBtn = nil;
	self.m_tGameData = nil;
	self.m_EnterFlag = nil;
	self.m_EnterType = nil;
	self.m_showPos = nil;
	self.m_selectIndex = nil;
	self.m_heroTimes = nil;

end
function game_teamRaid_last_scene:back(  )
	-- body
    local function responseMethod( tag, gameData )
        if gameData then
            game_scene:enterGameUi("game_teamRaid_main",{gameData = gameData,enterFlag = self.m_EnterFlag})
        end
    end
    local params = {}
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_index"), http_request_method.GET, nil,"team_raid_index")
end
function game_teamRaid_last_scene:createUi(  ) -- test_touch
	-- body
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
        	self:back()
    	elseif btnTag == 2 then  -- 出站
    		if not self.m_selCol or not self.m_selRow then
    			game_util:addMoveTips({text = "Xin hãy chọn Lộ Tuyến trước!!",new_color = ccc3(123,255,255)})
    			return
    		end
    		local function responseMethod( tag, gameData )
	            if gameData then
	            	game_data:setTeamRaidMsg("enterFlag",self.m_EnterFlag)
	            	game_data:setTeamRaidMsg("raid_id",self.m_tGameData.raid_id)
    				game_data:setBattleType("teamRaid_Battle");
    				game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
	            end
	        end
	        local params = {}
	        params.raid_id = self.m_tGameData.raid_id
	        params.position = self.m_selRow .. "_" .. self.m_selCol
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_fight_stage_2_1"), http_request_method.GET, params,"team_raid_fight_stage_2_1")
    	elseif btnTag == 3 then  -- 阵型
    		local function responseMethod( tag, gameData )
	            if gameData then
	                game_scene:enterGameUi("game_teamRaid_adjust",{gameData = gameData,enterFlag = self.m_EnterFlag,raid_id = self.m_tGameData.raid_id})
	            end
	        end
	        local params = {}
	        params.raid_id = self.m_tGameData.raid_id
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_get_aligment"), http_request_method.GET, params,"team_raid_get_aligment")

    	elseif btnTag == 4 then  -- 介绍
            game_scene:addPop("game_godfield_public_detail",{enterType = 204})
    	elseif btnTag > 10 and btnTag < 100 then  -- 路线1
    		local index = btnTag - 10
    		if index == 1 then
				self.m_selNode1:removeAllChildrenWithCleanup(true)
				self.m_selNode2:removeAllChildrenWithCleanup(true)
        		local selSp = CCSprite:createWithSpriteFrameName("ui_teamRaid_new_select.png")
				if selSp and self.m_selNode1 then
					self.m_selNode1:addChild(selSp)
				end
	    		local map = self.m_line1[index+1]
	    		self.m_selRow = map[4]
				self.m_selCol = map[5]
			end


    	elseif btnTag > 100 and btnTag < 200 then  -- 路线2

    		local index = btnTag - 100
    		if index == 1 then
				self.m_selNode1:removeAllChildrenWithCleanup(true)
				self.m_selNode2:removeAllChildrenWithCleanup(true)
        		local selSp = CCSprite:createWithSpriteFrameName("ui_teamRaid_new_select.png")
				if selSp and self.m_selNode2 then
					self.m_selNode2:addChild(selSp)
				end
	    		local map = self.m_line2[index+1]
	    		self.m_selRow = map[4]
				self.m_selCol = map[5]
			end
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
    ccbNode:openCCBFile("ccb/ui_teamRaid_last.ccbi");
    local m_btn_close = ccbNode:controlButtonForName("m_btn_close")
    m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_boss_btn = ccbNode:controlButtonForName("m_boss_btn")
    self.m_selNode1 = ccbNode:nodeForName("m_selNode1")
    self.m_selNode2 = ccbNode:nodeForName("m_selNode2")
    for i=1,12 do
        local node = ccbNode:nodeForName("m_btn_node_" .. i)
        local btn = ccbNode:controlButtonForName("m_btn" .. i)
        local lb = ccbNode:labelTTFForName("m_lb" .. i)
        local lb2 = ccbNode:labelTTFForName("m_lb2" .. i)
        if lb and lb2 and btn_lb[i] then
            lb:setString(btn_lb[i])
            -- lb2:setVisible(false)
            lb2:setString(btn_lb[i])
        end
        if i > 5 then
            btn:setTouchEnabled(false)
            btn:setColor(ccc3(100,100,100))
        end
    end
    self.m_content_node = ccbNode:nodeForName("content_node")
    self.m_btn_battle = ccbNode:controlButtonForName("m_btn_battle")
    self.m_time_node = ccbNode:nodeForName("m_time_node")
    self.m_cdtime_node = ccbNode:nodeForName("m_cdtime_node")
    self.m_time_node1 = ccbNode:nodeForName("m_time_node1")
    self.m_time_node2 = ccbNode:nodeForName("m_time_node2")
    self.m_time_node3 = ccbNode:nodeForName("m_time_node3")
    self.m_ccbNode = ccbNode;
    return ccbNode
end

function game_teamRaid_last_scene:createMsg(  )
	-- body
	local contentText = "1. Nội bộ Liên Minh có thể trực tiếp mở ra tập thể công Phó Bản, do Hội Trưởng tổ chức mở, Hội Trưởng tự phân phối nhân viên phân đội, phó bản mở ra cần tiêu hao Chiến Kỳ Liên Minh!\n2. Nội bộ Liên Minh có thể trực tiếp mở ra tập thể công Phó Bản, do Hội Trưởng tổ chức mở, Hội Trưởng tự phân phối nhân viên phân đội, phó bản mở ra cần tiêu hao Chiến Kỳ Liên Minh!\n3. Nội bộ Liên Minh có thể trực tiếp mở ra tập thể công Phó Bản, do Hội Trưởng tổ chức mở, Hội Trưởng tự phân phối nhân viên phân đội, phó bản mở ra cần tiêu hao Chiến Kỳ Liên Minh!"
	local tempLabel1 = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(150,0),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(123,255,255),fontSize = 10})
	local tempLabel2 = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(150,0),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(123,255,255),fontSize = 10})
    local tempSize = tempLabel1:getContentSize();
    self.text_scroll:setContentSize(CCSizeMake(210,tempSize.height))
    local viewSize = self.content_node:getContentSize()
    self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    tempLabel1:setPosition(ccp(0,0.3))
    tempLabel2:setPosition(ccp(0.3,0))
    self.text_scroll:addChild(tempLabel1)
    self.text_scroll:addChild(tempLabel2)
end


function game_teamRaid_last_scene:refreshBtn( )
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


function game_teamRaid_last_scene:refreshTeamList(  )
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
function game_teamRaid_last_scene:createTableView( viewSize ,tempTable )
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


function game_teamRaid_last_scene:refreshMap(  )
	-- body
	local map_date = self.m_tGameData.map_date or {}
	local stage_position = self.m_tGameData.stage_2_position or ""
	local maze_id = map_date.maze_id or 1
	self.m_boss_position = map_date.boss_position
	local group_outpost_mazeCfg = getConfig(game_config_field.group_outpost_maze)
	local group_outpost_maze = json.decode(group_outpost_mazeCfg:getFormatBuffer())
	local map_tab = {}
	for k,v in pairs(group_outpost_maze) do
		if v.sort == maze_id then
			map_tab[#map_tab+1] = v
		end
	end
	table.sort( map_tab,function ( data1,data2 )
		return data1.list_id < data2.list_id
	end )

	local line1 = {}
	local line2 = {}
	local began = 0
	for i=1,7 do
		for j=1,#map_tab do
			local tempRow = map_tab[j]
			local col = tempRow["column" .. i]
			if i == 1 and col[1] ~= 2 then
				line1[1] = util.table_copy(col)
				line1[1][4] = j
				line1[1][5] = i
				line2[1] = util.table_copy(col)
				line2[1][4] = j
				line2[1][5] = i
				began = j
			elseif i == 7 and col[1] ~= 2 then
				line1[7] = util.table_copy(col)
				line1[7][4] = j
				line1[7][5] = i
				line2[7] = util.table_copy(col)
				line2[7][4] = j
				line2[7][5] = i
			elseif (i ~= 1) and (i ~= 7) then
				if col[2] == 1 then
					line1[i] = util.table_copy(col)
					line1[i][4] = j
					line1[i][5] = i
				elseif  col[2] == 2 then
					line2[i] = util.table_copy(col)
					line2[i][4] = j
					line2[i][5] = i
				end
			end
		end
	end

	self.m_line1 = line1
	self.m_line2 = line2
	local selType = 0
	local pos = 0
	for i=1,5 do
		local btn1 = self.m_ccbNode:controlButtonForName("m_line_btn1_" .. i)
		local btn2 = self.m_ccbNode:controlButtonForName("m_line_btn2_" .. i)
		if not stage_position or stage_position == "" then
			if i == 1 then
				game_util:setCCControlButtonBackground(btn1,"ui_teamRaid_firstBoss_sp_ge32.png","ui_teamRaid_firstBoss_sp_ge32.png","ui_teamRaid_firstBoss_sp_ge32.png")
				game_util:setCCControlButtonBackground(btn2,"ui_teamRaid_firstBoss_sp_ge22.png","ui_teamRaid_firstBoss_sp_ge22.png","ui_teamRaid_firstBoss_sp_ge22.png")
				game_util:setCCControlButtonEnabled(btn1,true)
				game_util:setCCControlButtonEnabled(btn2,true)
			else
				game_util:setCCControlButtonBackground(btn1,"ui_teamRaid_firstBoss_sp_ge3.png","ui_teamRaid_firstBoss_sp_ge3.png","ui_teamRaid_firstBoss_sp_ge3.png")
				game_util:setCCControlButtonBackground(btn2,"ui_teamRaid_firstBoss_sp_ge2.png","ui_teamRaid_firstBoss_sp_ge2.png","ui_teamRaid_firstBoss_sp_ge2.png")
				game_util:setCCControlButtonEnabled(btn1,false)
				game_util:setCCControlButtonEnabled(btn2,false)
			end
		else
			if selType == 1 and pos == i then
				game_util:setCCControlButtonBackground(btn1,"ui_teamRaid_firstBoss_sp_ge32.png","ui_teamRaid_firstBoss_sp_ge32.png","ui_teamRaid_firstBoss_sp_ge32.png")
				game_util:setCCControlButtonBackground(btn2,"ui_teamRaid_firstBoss_sp_ge2.png","ui_teamRaid_firstBoss_sp_ge2.png","ui_teamRaid_firstBoss_sp_ge2.png")
				game_util:setCCControlButtonEnabled(btn1,true)
				game_util:setCCControlButtonEnabled(btn2,false)
				self:addSelectSprite(btn1)

			elseif selType == 2 and pos == i then
				game_util:setCCControlButtonBackground(btn1,"ui_teamRaid_firstBoss_sp_ge3.png","ui_teamRaid_firstBoss_sp_ge3.png","ui_teamRaid_firstBoss_sp_ge3.png")
				game_util:setCCControlButtonBackground(btn2,"ui_teamRaid_firstBoss_sp_ge22.png","ui_teamRaid_firstBoss_sp_ge22.png","ui_teamRaid_firstBoss_sp_ge22.png")
				game_util:setCCControlButtonEnabled(btn1,false)
				game_util:setCCControlButtonEnabled(btn2,true)
				self:addSelectSprite(btn2)
				
			else
				local map1 = line1[i+1]
				local map2 = line2[i+1]
				if stage_position == map1[4] .. "_" .. map1[5] then
					selType = 1
					pos = i+1
					game_util:setCCControlButtonBackground(btn1,"ui_teamRaid_firstBoss_sp_ge32.png","ui_teamRaid_firstBoss_sp_ge32.png","ui_teamRaid_firstBoss_sp_ge32.png")
					game_util:setCCControlButtonBackground(btn2,"ui_teamRaid_firstBoss_sp_ge2.png","ui_teamRaid_firstBoss_sp_ge2.png","ui_teamRaid_firstBoss_sp_ge2.png")
					game_util:setCCControlButtonEnabled(btn1,false)
					game_util:setCCControlButtonEnabled(btn2,false)
					local mamp = line1[i+2]
					self.m_selRow = mamp[4]
					self.m_selCol = mamp[5]
					self:addGouSprite(btn1)
				elseif stage_position == map2[4] .. "_" .. map2[5] then
					selType = 2
					pos = i+1
					game_util:setCCControlButtonBackground(btn1,"ui_teamRaid_firstBoss_sp_ge3.png","ui_teamRaid_firstBoss_sp_ge3.png","ui_teamRaid_firstBoss_sp_ge3.png")
					game_util:setCCControlButtonBackground(btn2,"ui_teamRaid_firstBoss_sp_ge22.png","ui_teamRaid_firstBoss_sp_ge22.png","ui_teamRaid_firstBoss_sp_ge22.png")
					game_util:setCCControlButtonEnabled(btn1,false)
					game_util:setCCControlButtonEnabled(btn2,false)
					local mamp = line2[i+2]
					self.m_selRow = mamp[4]
					self.m_selCol = mamp[5]
					self:addGouSprite(btn2)

				else
					if self.m_showPos[map1[4] .. "_" .. map1[5]] and self.m_showPos[map1[4] .. "_" .. map1[5]] == 1 then
						game_util:setCCControlButtonBackground(btn1,"ui_teamRaid_firstBoss_sp_ge32.png","ui_teamRaid_firstBoss_sp_ge32.png","ui_teamRaid_firstBoss_sp_ge32.png")
						game_util:setCCControlButtonEnabled(btn1,false)
						game_util:setCCControlButtonBackground(btn2,"ui_teamRaid_firstBoss_sp_ge2.png","ui_teamRaid_firstBoss_sp_ge2.png","ui_teamRaid_firstBoss_sp_ge2.png")
						game_util:setCCControlButtonEnabled(btn2,false)
						self:addGouSprite(btn1)
					elseif self.m_showPos[map2[4] .. "_" .. map2[5]] and self.m_showPos[map2[4] .. "_" .. map2[5]] == 1 then
						game_util:setCCControlButtonBackground(btn1,"ui_teamRaid_firstBoss_sp_ge3.png","ui_teamRaid_firstBoss_sp_ge3.png","ui_teamRaid_firstBoss_sp_ge3.png")
						game_util:setCCControlButtonEnabled(btn1,false)
						game_util:setCCControlButtonBackground(btn2,"ui_teamRaid_firstBoss_sp_ge22.png","ui_teamRaid_firstBoss_sp_ge22.png","ui_teamRaid_firstBoss_sp_ge22.png")
						game_util:setCCControlButtonEnabled(btn2,false)
						self:addGouSprite(btn2)
					else
						game_util:setCCControlButtonBackground(btn1,"ui_teamRaid_firstBoss_sp_ge3.png","ui_teamRaid_firstBoss_sp_ge3.png","ui_teamRaid_firstBoss_sp_ge3.png")
						game_util:setCCControlButtonEnabled(btn1,false)
						game_util:setCCControlButtonBackground(btn2,"ui_teamRaid_firstBoss_sp_ge2.png","ui_teamRaid_firstBoss_sp_ge2.png","ui_teamRaid_firstBoss_sp_ge2.png")
						game_util:setCCControlButtonEnabled(btn2,false)
					end
				end
			end
		end
	end

	if pos == #line1 - 1 then
		game_util:setCCControlButtonEnabled(self.m_boss_btn,true)
	else
		game_util:setCCControlButtonEnabled(self.m_boss_btn,false)
	end
end


function game_teamRaid_last_scene:addGouSprite( btn )
	-- body
	local gou = CCSprite:createWithSpriteFrameName("yinghun_gou.png")
	if gou and btn then
		btn:addChild(gou)
		gou:setScale(1.2)
		local sizeView = btn:getContentSize()
		gou:setPosition(ccp(sizeView.width*0.5,sizeView.height*0.5))
	end
end

function game_teamRaid_last_scene:addSelectSprite( btn )
	-- body
	local gou = CCSprite:createWithSpriteFrameName("ui_teamRaid_new_select.png")
	if gou and btn then
		btn:addChild(gou)
		gou:setScale(1.2)
		local sizeView = btn:getContentSize()
		gou:setPosition(ccp(sizeView.width*0.5,sizeView.height*0.5))
	end
end


function game_teamRaid_last_scene:goToWhere(  )
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
	                    game_scene:enterGameUi("game_teamRaid_firstBoss_scene",{gameData = gameData,enterFlag = self.m_EnterFlag,selectRow = self.m_selectRow,selectCol = self.m_selectCol})
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


function game_teamRaid_last_scene:refreshTimeLabel( )
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





function game_teamRaid_last_scene:refreshUi(  )
	-- body
	-- self:createMsg()
	self:refreshTeamList()
    local btn = self.m_ccbNode:controlButtonForName("m_btn" .. self.m_selectIndex)
	btn:setEnabled(false)
	self.m_selectTeamBtn = btn
	self:refreshMap()
	self:refreshTimeLabel()
end

function game_teamRaid_last_scene:init( t_params )
	-- body
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res_add.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_yinghun.plist");

	if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
       local data = t_params.gameData:getNodeWithKey("data")
       self.m_tGameData = json.decode(data:getFormatBuffer())
    end
    self.m_EnterFlag = t_params.enterFlag or 2
    self.m_EnterType = t_params.enterType or ""

    local light_position_list = self.m_tGameData.light_position_list or {}
    self.m_showPos = {}
    for k,v in pairs(light_position_list) do
    	self.m_showPos[v] = 1
    end
    self.m_selectIndex = 1
    self.m_heroTimes = {}
    local persion_clearance_times = self.m_tGameData.persion_clearance_times or {}
    for k,v in pairs(persion_clearance_times) do
    	self.m_heroTimes[v[1]] = v[2]
    end
end

function game_teamRaid_last_scene:create( t_params )
	-- body
	local scene = CCLayer:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end

return game_teamRaid_last_scene