-- 团队副本   第二阶段   时间裂缝
local game_teamRaid_lastBoss_scene = {
	
	m_map_node = nil,
	m_map_scrollView = nil,
	m_name_label1 = nil,
	m_name_label2 = nil,
	m_combat_label1 = nil,
	m_combat_label2 = nil,
	m_ccbNode = nil,
	m_boss_position = nil,
	m_mapTab = nil,
	m_map_spriteNode = nil,
	m_selectSprite = nil,
	m_selectRow = nil,
	m_selectCol = nil,
	m_tGameData = nil,
	m_selectIndex = nil,
	m_selectBattleType = nil,
	m_EnterFlag = nil,
	m_EnterType = nil,
	m_selectRow = nil,
	m_selectCol = nil,
	m_showPos = nil,
}
local btn_lb = {"I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII"}
local attr_tab = {201,202,203}
local occu_tab = {1,2,3}
function game_teamRaid_lastBoss_scene:destroy(  )
	-- body

	cclog("  -----------  game_teamRaid_lastBoss_scene  destroy  ---------------")
	self.m_mapScroll_node = nil;
	self.m_map_spriteNode = nil;

	self.m_map_node = nil;
	self.m_map_scrollView = nil;
	self.m_name_label1 = nil;
	self.m_name_label2 = nil;
	self.m_combat_label1 = nil;
	self.m_combat_label2 = nil;
	self.m_ccbNode = nil;
	self.m_boss_position = nil;
	self.m_mapTab = nil;
	self.m_map_spriteNode = nil;
	self.m_selectSprite = nil;
	self.m_selectRow = nil;
	self.m_selectCol = nil;
	self.m_tGameData = nil;
	self.m_selectIndex = nil;
	self.m_selectBattleType = nil;
	self.m_EnterFlag = nil;
	self.m_EnterType = nil;
	self.m_selectRow = nil;
	self.m_selectCol = nil;
	self.m_showPos = nil;
end
function game_teamRaid_lastBoss_scene:back(  )
	-- body
    local function responseMethod( tag, gameData )
        if gameData then
            game_scene:enterGameUi("game_teamRaid_main",{gameData = gameData,enterFlag = self.m_EnterFlag})
        end
    end
    local params = {}
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_index"), http_request_method.GET, nil,"team_raid_index")
end
function game_teamRaid_lastBoss_scene:createUi(  ) -- test_touch
	-- body
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
        	self:back()
    	elseif btnTag == 2 then
    		game_scene:addPop("game_teamRaid_map",{gameData = util.table_copy(self.m_tGameData),enterFlag = 2})
		elseif btnTag == 3 then
	        local function responseMethod( tag, gameData )
	            if gameData then
    			    game_data:setTeamRaidMsg("selectRow",self.m_selectRow)
	            	game_data:setTeamRaidMsg("selectCol",self.m_selectCol)
	            	game_data:setTeamRaidMsg("battleType",self.m_selectBattleType)
	                game_scene:enterGameUi("game_teamRaid_adjust",{gameData = gameData,enterFlag = self.m_EnterFlag,raid_id = self.m_tGameData.raid_id})
	            end
	        end
	        local params = {}
	        params.raid_id = self.m_tGameData.raid_id
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_get_aligment"), http_request_method.GET, params,"team_raid_get_aligment")
    	elseif btnTag == 4 then
    		local row = self.m_mapTab[self.m_selectRow].list_id
    		local col = self.m_selectCol--m_selectRow
    		local function responseMethod( tag, gameData )
	            if gameData then
	            	game_data:setTeamRaidMsg("selectRow",self.m_selectRow)
	            	game_data:setTeamRaidMsg("selectCol",self.m_selectCol)
	            	game_data:setTeamRaidMsg("enterFlag",self.m_EnterFlag)
	            	game_data:setTeamRaidMsg("raid_id",self.m_tGameData.raid_id)
    				game_data:setBattleType("teamRaid_Battle");
    				game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
	            end
	        end
	        local params = {}
	        params.raid_id = self.m_tGameData.raid_id
	        params.position = row .. "_" .. col
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_fight_stage_2_2"), http_request_method.GET, params,"team_raid_fight_stage_2_2")
	    elseif btnTag == 5 then
	    	local group_outpost = getConfig(game_config_field.group_outpost)
	    	local group_outpostCfg = group_outpost:getNodeWithKey("2")
	    	local notice1 = group_outpostCfg:getNodeWithKey("target1"):toStr()
	    	local notice2 = group_outpostCfg:getNodeWithKey("target2"):toStr()
	    	game_scene:addPop("game_teamRaid_bossTarget_pop",{notice1 = notice1,notice2 = notice2})
    		-- game_scene:enterGameUi("")
    	elseif btnTag > 200 and btnTag < 300 then  -- 选择队伍

    	elseif btnTag > 300 and btnTag < 400 then  -- 属性筛选

    	elseif btnTag > 400 and btnTag < 500 then  -- 职业筛选

    	end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_teamRaid_lastBoss.ccbi");
    local m_btn_close = ccbNode:controlButtonForName("m_btn_close")
    m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    local m_btn_map = ccbNode:controlButtonForName("m_btn_map")
    local m_btn_adjjust = ccbNode:controlButtonForName("m_btn_adjjust")
    m_btn_map:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);    
    local m_btn_target = ccbNode:controlButtonForName("m_btn_target")
    m_btn_target:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    m_btn_adjjust:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    self.m_btn_battle = ccbNode:controlButtonForName("m_battle")
    self.m_btn_battle:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
    self.m_map_node = ccbNode:nodeForName("m_map_node")
    self.m_map_scrollView = ccbNode:scrollViewForName("m_map_scrollView")
    self.m_reward_node = ccbNode:nodeForName("m_reward_node")
    local m_map_sp = ccbNode:spriteForName("m_map_sp")
    m_map_sp:setVisible(false)

    self.m_name_label1 = ccbNode:labelTTFForName("m_name_label1")
    self.m_name_label2 = ccbNode:labelTTFForName("m_name_label2")
    self.m_combat_label1 = ccbNode:labelTTFForName("m_combat_label1")
    self.m_combat_label2 = ccbNode:labelTTFForName("m_combat_label2")
	self.m_progress_lb = ccbNode:labelTTFForName("m_progress_lb")
	self.m_progress_node = ccbNode:nodeForName("m_progress_node1")
    local m_touchLayer = ccbNode:layerForName("m_touchLayer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- return true;--intercept event
            local realPos = m_touchLayer:getParent():convertToNodeSpace(ccp(x,y));
            if not m_touchLayer:boundingBox():containsPoint(realPos) then
                return true;
            end
            return false;
        end
    end

    m_touchLayer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 2,true);
    m_touchLayer:setTouchEnabled(true);

    self.m_time_node = ccbNode:nodeForName("m_time_node")
    self.m_cdtime_node = ccbNode:nodeForName("m_cdtime_node")
    self.m_time_node1 = ccbNode:nodeForName("m_time_node1")
    self.m_time_node2 = ccbNode:nodeForName("m_time_node2")
    self.m_time_node3 = ccbNode:nodeForName("m_time_node3")

    local m_title_lb1 = ccbNode:labelTTFForName("m_title_lb1")
    local m_title_lb2 = ccbNode:labelTTFForName("m_title_lb2")
	m_title_lb1:setString("Giai đoạn 2")
	m_title_lb2:setString("Giai đoạn 2")
    self.m_ccbNode = ccbNode;
    return ccbNode
end

function game_teamRaid_lastBoss_scene:createMsg(  )
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


function game_teamRaid_lastBoss_scene:refreshBtn( )
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

function game_teamRaid_lastBoss_scene:refreshMap(  )
	-- body
	local map_date = self.m_tGameData.map_date or {}
	local maze_id = map_date.maze_id or 1
	
	local boss_position = map_date.boss_position or {}
	self.m_boss_position = {}
	for k,v in pairs(boss_position) do
		self.m_boss_position[v] = 1
	end

	local group_outpost_mazeCfg = getConfig(game_config_field.group_outpost_maze)
	local group_outpost_maze = json.decode(group_outpost_mazeCfg:getFormatBuffer())
	local map_tab = {}
	for k,v in pairs(group_outpost_maze) do
		if v.sort == maze_id then
			map_tab[#map_tab+1] = v
		end
	end
	table.sort( map_tab,function ( data1,data2 )
		return data1.list_id > data2.list_id
	end )

	self.m_mapTab = map_tab

	local maxRow, maxCol = 13, 13   --行  列
	local group_outpost_maze = getConfig(game_config_field.group_outpost_maze)
	local viewSize = self.m_map_node:getContentSize()
	if not self.m_mapScroll_node and not self.m_map_spriteNode then
		self.m_mapScroll_node = CCNode:create()
		self.m_mapScroll_node:setContentSize(CCSizeMake(408, 410))
		local sp1 = CCSprite:createWithSpriteFrameName("ui_teamRaid_firstBoss_ge.png")
		local sp2 = CCSprite:createWithSpriteFrameName("ui_teamRaid_firstBoss_ge.png")
		local sp3 = CCSprite:createWithSpriteFrameName("ui_teamRaid_firstBoss_ge.png")
		local sp4 = CCSprite:createWithSpriteFrameName("ui_teamRaid_firstBoss_ge.png")
		if sp1 and sp2 and sp3 and sp4 then
			self.m_mapScroll_node:addChild(sp1)
			self.m_mapScroll_node:addChild(sp2)
			self.m_mapScroll_node:addChild(sp3)
			self.m_mapScroll_node:addChild(sp4)
			sp1:setVisible(false)
			sp2:setVisible(false)
			sp3:setVisible(false)
			sp4:setVisible(false)
			sp1:setAnchorPoint(ccp(0,0))
			sp2:setAnchorPoint(ccp(0,0))
			sp3:setAnchorPoint(ccp(0,0))
			sp4:setAnchorPoint(ccp(0,0))
			sp1:setPosition(ccp(-4,-6))
			sp2:setPosition(ccp(-4,150))
			sp3:setPosition(ccp(216,150))
			sp4:setPosition(ccp(216,-6))
		end
		self.m_map_scrollView:getContainer():addChild(self.m_mapScroll_node)
        self.m_map_scrollView:getContainer():setContentSize(self.m_mapScroll_node:getContentSize())
        self.m_mapScroll_node:setPosition(ccp(0,0))
        self.m_map_spriteNode = CCLayer:create()
        self.m_map_spriteNode:setAnchorPoint(ccp(0,0))
        self.m_map_spriteNode:setPosition(ccp(0,0))   -- 223   157   
        self.m_map_spriteNode:setContentSize(CCSizeMake(223,157))
        self.m_mapScroll_node:addChild(self.m_map_spriteNode)
	end
	self.m_map_spriteNode:removeAllChildrenWithCleanup(true)


	--   3  ui_teamRaid_firstBoss_sp_ge2.png    红色无点      2  ui_teamRaid_firstBoss_sp_ge1.png   碎玻璃，墙      1  ui_teamRaid_firstBoss_sp_ge3.png   蓝色无点    
 

	-- 可打的蓝色灰    墙     初始点红色灰       空   
	local name  = {"ui_teamRaid_firstBoss_sp_ge3.png","ui_teamRaid_firstBoss_sp_ge1.png","ui_teamRaid_firstBoss_sp_ge2.png","ui_teamRaid_firstBoss_sp_ge3.png","ui_teamRaid_firstBoss_sp_ge32.png","ui_teamRaid_firstBoss_sp_dige.png"}
	local spriteTab = {}
	local selPos = {}
	for i=1,#map_tab do
		local tab = map_tab[i]
		local list_id = tab.list_id
		for j=1,13 do
			local column = tab["column"..j] or {}
			local flag = column[1] or 3
			if self.m_showPos[list_id .. "_" .. j] then
				flag = 5
			end

			local sprite = CCSprite:createWithSpriteFrameName(name[flag])
			if sprite then
				self.m_map_spriteNode:addChild(sprite)
				sprite:setPosition(ccp(18+31*(j-1), 20+31*(i-1)))    -- -11.5   -13.5    ccp(-11.5+31.5*(i-1), -13.5+31.35*(j-1)) 
				spriteTab["sp" .. i .. "_" .. j] = sprite   --   i  为行    j  为列  
			end

			if self.m_selectRow == i and self.m_selectCol == j then
				self.m_selectSprite = sprite
				selPos.x = 18+31*(j-1)
				selPos.y = 20+31*(i-1)
			    local selSp = CCSprite:createWithSpriteFrameName("ui_teamRaid_firstBoss_sel.png")
				if selSp then

					local viewSize = sprite:getContentSize()
					sprite:addChild(selSp)
					selSp:setPosition(ccp(viewSize.width*0.5, viewSize.height*0.5))
				end
			end

			if column[1] == 4 then
				local bossSprite = CCSprite:createWithSpriteFrameName("ui_teamRaid_boss_small.png")
				if bossSprite and sprite then
					local viewSize = sprite:getContentSize()
					sprite:addChild(bossSprite)
					bossSprite:setPosition(ccp(viewSize.width*0.5, viewSize.height*0.5))
				end
			end
			if (self.m_boss_position[list_id .. "_" .. j] and (self.m_boss_position[list_id .. "_" .. j] == 1)) and (self.m_showPos[list_id .. "_" .. j] and (self.m_showPos[list_id .. "_" .. j] == 1)) then
				local bossSprite = CCSprite:createWithSpriteFrameName("ui_teamRaid_boss_small2.png")
				if bossSprite and sprite then
					local viewSize = sprite:getContentSize()
					sprite:addChild(bossSprite)
					bossSprite:setPosition(ccp(viewSize.width*0.5, viewSize.height*0.5))
				end
			end
		end
	end
	if selPos.x and selPos.y then
		local x = 110 - selPos.x
		local y = 80 - selPos.y
		x = x > 0 and 0 or x
		y = y > 0 and 0 or y
		self.m_map_scrollView:setContentOffset(ccp(x,y))
	end
	local beganX = 0
	local beganY = 0
 	local moveFlag = false
    local function onTouchBegan(x, y)
        moveFlag = false
        beganX = x
        beganY = y
        local realPos = self.m_map_spriteNode:getParent():convertToWorldSpace(ccp(x,y))
        if self.m_map_spriteNode:boundingBox():containsPoint(realPos) then
        else
        end
    	return true
    end
    
    local function onTouchMoved(x, y)
    	local moveX = x - beganX 
    	local moveY = y - beganY 
    	if math.abs(moveX) > 10 or math.abs(moveY) > 10 then
        	moveFlag = true
    	end
    end

    local function onTouchEnded(x, y)
    	if moveFlag then
    		return
    	end
    	for i=1,13 do
		    local tab = map_tab[i]
			local list_id = tab.list_id
    		for j=1,13 do
    			local sp = spriteTab["sp" .. i .. "_" .. j]
    			local realPos = sp:getParent():convertToNodeSpace(ccp(x,y)); 
            	if sp:boundingBox():containsPoint(realPos) then
            		local map = tab["column" .. j]
            		if self.m_selectSprite then
            			local tab1 = map_tab[self.m_selectRow]
						local list_id1 = tab1.list_id
            			local map1 = tab1["column" .. self.m_selectCol]

            			self.m_selectSprite:removeAllChildrenWithCleanup(true)
						if map1[1] == 4 then
							local bossSprite = CCSprite:createWithSpriteFrameName("ui_teamRaid_boss_small.png")
							if bossSprite then
								local viewSize = self.m_selectSprite:getContentSize()
								self.m_selectSprite:addChild(bossSprite)
								bossSprite:setPosition(ccp(viewSize.width*0.5, viewSize.height*0.5))
							end
						end
            			if self.m_showPos[list_id1 .. "_" .. self.m_selectCol] == 1 and (self.m_boss_position[list_id1 .. "_" .. self.m_selectCol] and (self.m_boss_position[list_id1 .. "_" .. self.m_selectCol] == 1)) then
            				local bossSprite = CCSprite:createWithSpriteFrameName("ui_teamRaid_boss_small2.png")
							if bossSprite then
								local viewSize = self.m_selectSprite:getContentSize()
								self.m_selectSprite:addChild(bossSprite)
								bossSprite:setPosition(ccp(viewSize.width*0.5, viewSize.height*0.5))
							end
            			end
            		end
            		sp:removeAllChildrenWithCleanup(true)
            		local selSp = CCSprite:createWithSpriteFrameName("ui_teamRaid_firstBoss_sel.png")
    				if selSp then
						local viewSize = sp:getContentSize()
						sp:addChild(selSp)
						selSp:setPosition(ccp(viewSize.width*0.5, viewSize.height*0.5))
					end

					if map[1] == 4 then
						local bossSprite = CCSprite:createWithSpriteFrameName("ui_teamRaid_boss_small.png")
						if bossSprite then
							local viewSize = sp:getContentSize()
							sp:addChild(bossSprite)
							bossSprite:setPosition(ccp(viewSize.width*0.5, viewSize.height*0.5))
						end
					end

				    if self.m_showPos[list_id .. "_" .. j] == 1 and  (self.m_boss_position[list_id .. "_" .. j] and (self.m_boss_position[list_id .. "_" .. j] == 1)) then
        				local bossSprite = CCSprite:createWithSpriteFrameName("ui_teamRaid_boss_small2.png")
						if bossSprite and sp then
							local viewSize = sp:getContentSize()
							sp:addChild(bossSprite)
							bossSprite:setPosition(ccp(viewSize.width*0.5, viewSize.height*0.5))
						end
        			end
        			self.m_selectSprite = sp
            		self.m_selectRow = i    --  行   
            		self.m_selectCol = j    --  列
            		self:refreshRightInfo(i,j)
            		return
            	end
    		end
    	end
        return
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
        elseif eventType == "moved" then
            return onTouchMoved(x, y)
        else
            return onTouchEnded(x, y)
        end
    end
    self.m_map_spriteNode:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,false)
    self.m_map_spriteNode:setTouchEnabled(true)

	local name  = {"ui_teamRaid_firstBoss_sp_ge3.png","ui_teamRaid_firstBoss_sp_ge1.png","ui_teamRaid_firstBoss_sp_ge2.png","ui_teamRaid_firstBoss_sp_ge22.png","ui_teamRaid_firstBoss_sp_dige.png"}

end


function game_teamRaid_lastBoss_scene:refreshRightInfo( row,col )
	-- body
	local name = {"Tay Sai Khe Hở","Tinh Anh Khe Hở","Lãnh Chúa Khe Hở"}
	local difficulty = {"YẾU NHƯ GÀ RÙ","TINH ANH XÃ HỘI","KHÔNG GÌ SÁNH ĐƯỢC"}
	local map_data = self.m_mapTab[row] or {}
	local list_id = map_data.list_id or 1
	local col = col or 1
	local monsterType = 0   --未开启
	if self.m_showPos[list_id .. "_" .. col] and self.m_showPos[list_id .. "_" .. col] == 1 then
		if map_data["column" .. col] and (map_data["column" .. col][1] == 1) then
			monsterType = 1   -- 小怪
			elseif map_data["column" .. col] and (map_data["column" .. col][1] == 4) then
			monsterType = 3   -- 大boss
		end

		if self.m_boss_position[list_id .. "_" .. col] == 1 then
			monsterType = 2   -- 小怪
		end
	end
	if  map_data["column" .. col] and (map_data["column" .. col][1] == 4) then
		monsterType = 3   -- 大boss
	end
	local monsterName,monsterDiff = "???","???"
	if monsterType ~= 0 then
		monsterName = name[monsterType]
		monsterDiff = difficulty[monsterType]
	end
	local group_outpost = getConfig(game_config_field.group_outpost)
	local group_outpost_2 = group_outpost and group_outpost:getNodeWithKey("2")
	local limit_times = group_outpost_2 and json.decode(group_outpost_2:getNodeWithKey("limit_times"):getFormatBuffer()) or {}
	if monsterType == 3 then
		local clearance_times = self.m_tGameData.clearance_times_2_2 or {}
		local times = clearance_times[1] and clearance_times[1][2] or 0
		local limit = limit_times[1]
		for i=1,#limit_times do
			if not (times < limit_times[i]) then
				limit = i<#limit_times and limit_times[i+1] or limit_times[i]
			end
		end
		monsterName = monsterName  -- .. "(" .. times .. "/" .. limit .. ")"
	end
	self.m_name_label1:setString(monsterName)
	self.m_name_label2:setString(monsterName)
	self.m_combat_label1:setString(monsterDiff)
	self.m_combat_label2:setString(monsterDiff)
end

function game_teamRaid_lastBoss_scene:getMapFlag( config, m, n )
	-- body
	
end


function game_teamRaid_lastBoss_scene:goToWhere(  )
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
	                    game_scene:enterGameUi("game_teamRaid_lastBoss_scene",{gameData = gameData,enterFlag = self.m_EnterFlag,battleType = self.m_selectBattleType,selectRow = self.m_selectRow,selectCol = self.m_selectCol})
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


function game_teamRaid_lastBoss_scene:refreshTimeLabel( )
	local function timeEndFunc(label,type)
		self:goToWhere()
    end
	local remain_time = self.m_tGameData.remain_time or 0
	local active_remain_time = self.m_tGameData.active_remain_time or 0
	if remain_time > 0 and active_remain_time > 0 then
		self.m_time_node:setVisible(false)
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


function game_teamRaid_lastBoss_scene:refreshProgress(  )
	-- body

	local group_outpost = getConfig(game_config_field.group_outpost)
	local group_outpost_2 = group_outpost and group_outpost:getNodeWithKey("2")
	local limit_times = group_outpost_2 and json.decode(group_outpost_2:getNodeWithKey("limit_times"):getFormatBuffer()) or {}

	local clearance_times = self.m_tGameData.clearance_times_2_2 or {}
	local times = clearance_times[1] and clearance_times[1][2] or 0
	local limit = limit_times[#limit_times]
	local reward = nil
	local reward_key = {"low_reward","middle_reward","best_reward"}
	local group_outpost_2Cfg = json.decode(group_outpost_2:getFormatBuffer())
	for i=1,#limit_times do
		if not (times < limit_times[i]) then
			reward = reward_key[i] and group_outpost_2Cfg[reward_key[i]] or nil
		end
	end

	self.m_progress_node:removeAllChildrenWithCleanup(true)
	local bar = ExtProgressTime:createWithFrameName("ui_teamRaid_new_progress12.png","ui_teamRaid_new_progress1.png");
    if bar then
	    bar:setScaleX(1);
	    local viewSize = self.m_progress_node:getContentSize()
	    self.m_progress_lb:setString(times .. "/" .. limit)
	    bar:setMaxValue(limit)
	    bar:setCurValue(times)
	    bar:setAnchorPoint(ccp(0.5,0.5))
	    bar:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
	    self.m_progress_node:addChild(bar,10)
	end
	self.m_reward_node:removeAllChildrenWithCleanup(true)
	if reward then
	    function onBtnCilck( event, target )
	        local tagNode = tolua.cast(target, "CCNode");
	        local btnTag = tagNode:getTag();
	        print("press button tag is ", btnTag)
	        game_util:lookItemDetal( reward[1])
	    end
        local icon,name,count = game_util:getRewardByItemTable(reward[1]);
        if icon then
            icon:setAnchorPoint(ccp(0.5, 0.5))
            icon:setScale(0.35)
            self.m_reward_node:addChild(icon)

            local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
            button:setAnchorPoint(ccp(0.5,0.5))
            button:setPosition( icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5 )
            button:setOpacity(0)
            icon:addChild(button)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
        end
	else
		local noReward = game_util:createLabelTTF({text = "None",color = ccc3(255,0,0),fontSize = 9})
		if noReward then
			self.m_reward_node:addChild(noReward)
			noReward:setPositionX(-5)
		end
	end
end

function game_teamRaid_lastBoss_scene:refreshUi(  )
	-- body
	self:refreshMap()
	self:refreshRightInfo(self.m_selectRow,self.m_selectCol)
	self:refreshTimeLabel()
	self:refreshProgress()
end

function game_teamRaid_lastBoss_scene:init( t_params )
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
    self.m_selectRow = t_params.selectRow or 1
	self.m_selectCol = t_params.selectCol or 1
    local light_position_list = self.m_tGameData.light_position_list or {}
    self.m_showPos = {}
    for k,v in pairs(light_position_list) do
    	self.m_showPos[v] = 1
    end
end

function game_teamRaid_lastBoss_scene:create( t_params )
	-- body
	local scene = CCLayer:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end

return game_teamRaid_lastBoss_scene