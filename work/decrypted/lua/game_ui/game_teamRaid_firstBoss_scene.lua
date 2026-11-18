-- 团队副本   第二阶段   时间裂缝
local game_teamRaid_firstBoss_scene = {
	
	m_map_node = nil,
	m_map_scrollView = nil,
	m_name_label1 = nil,
	m_name_label2 = nil,
	m_combat_label1 = nil,
	m_combat_label2 = nil,
	m_ccbNode = nil,
	m_boss_position = nil,
	m_mapTab = nil,
	m_selectSprite = nil,
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
function game_teamRaid_firstBoss_scene:destroy(  )
	-- body
	cclog("   ----------- game_teamRaid_firstBoss_scene  destroy ----------------    ")

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
	self.m_selectSprite = nil;
	self.m_tGameData = nil;
	self.m_selectIndex = nil;
	self.m_selectBattleType = nil;
	self.m_EnterFlag = nil;
	self.m_EnterType = nil;
	self.m_selectRow = nil;
	self.m_selectCol = nil;
	self.m_showPos = nil;
end
function game_teamRaid_firstBoss_scene:back(  )
	-- body
    local function responseMethod( tag, gameData )
        if gameData then
            game_scene:enterGameUi("game_teamRaid_main",{gameData = gameData,enterFlag = self.m_EnterFlag})
        end
    end
    local params = {}
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_index"), http_request_method.GET, nil,"team_raid_index")
end
function game_teamRaid_firstBoss_scene:createUi(  ) -- test_touch
	-- body
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
        	self:back()
    	elseif btnTag == 2 then -- 地图
    		game_scene:addPop("game_teamRaid_map",{gameData = util.table_copy(self.m_tGameData),enterFlag = 1})
    	elseif btnTag == 3 then -- 阵型
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
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_fight_stage_1_2"), http_request_method.GET, params,"team_raid_fight_stage_1_2")
	    elseif btnTag == 5 then
	    	local group_outpost = getConfig(game_config_field.group_outpost)
	    	local group_outpostCfg = group_outpost:getNodeWithKey("1")
	    	local notice1 = group_outpostCfg:getNodeWithKey("target1"):toStr()
	    	local notice2 = group_outpostCfg:getNodeWithKey("target2"):toStr()
	    	game_scene:addPop("game_teamRaid_bossTarget_pop",{notice1 = notice1,notice2 = notice2})
    	end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_teamRaid_firstBoss.ccbi");
    local m_btn_close = ccbNode:controlButtonForName("m_btn_close")
    local m_btn_map = ccbNode:controlButtonForName("m_btn_map")
    local m_btn_adjjust = ccbNode:controlButtonForName("m_btn_adjjust")
    local m_btn_target = ccbNode:controlButtonForName("m_btn_target")
    m_btn_target:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    m_btn_map:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    m_btn_adjjust:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    self.m_btn_battle = ccbNode:controlButtonForName("m_battle")
    self.m_btn_battle:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
    self.m_map_node = ccbNode:nodeForName("m_map_node")
    self.m_map_scrollView = ccbNode:scrollViewForName("m_map_scrollView")
    local m_map_sp = ccbNode:spriteForName("m_map_sp")
    m_map_sp:setVisible(false)
    self.m_progress_lb = ccbNode:labelTTFForName("m_progress_lb")
	self.m_progress_node = ccbNode:nodeForName("m_progress_node1")
    self.m_name_label1 = ccbNode:labelTTFForName("m_name_label1")
    self.m_name_label2 = ccbNode:labelTTFForName("m_name_label2")
    self.m_combat_label1 = ccbNode:labelTTFForName("m_combat_label1")
    self.m_combat_label2 = ccbNode:labelTTFForName("m_combat_label2")
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

    self.m_ccbNode = ccbNode;
    return ccbNode
end




function game_teamRaid_firstBoss_scene:refreshBtn( )
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

function game_teamRaid_firstBoss_scene:refreshMap(  )
	-- body
	local map_date = self.m_tGameData.map_date or {}
	local maze_id = map_date.maze_id or 1
	self.m_boss_position = map_date.boss_position
	cclog2(self.m_boss_position,"   ------------   self.m_boss_position")
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
	local name  = {"ui_teamRaid_firstBoss_sp_ge3.png","ui_teamRaid_firstBoss_sp_ge1.png","ui_teamRaid_firstBoss_sp_ge2.png","ui_teamRaid_firstBoss_sp_ge32.png","ui_teamRaid_firstBoss_sp_dige.png"}
	local spriteTab = {}
	local selPos = {}
	
	for i=1,#map_tab do
		local tab = map_tab[i]
		local list_id = tab.list_id
		for j=1,13 do
			local column = tab["column"..j] or {}
			local flag = column[1] or 3
			if self.m_showPos[list_id .. "_" .. j] then
				flag = 4
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

			if self.m_showPos[list_id .. "_" .. j] == 1 and self.m_boss_position ==  list_id .. "_" .. j then
				local bossSprite = CCSprite:createWithSpriteFrameName("ui_teamRaid_boss_small.png")
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
		x = x < -185 and -185 or x
		y = y < -253 and -253 or y
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
            		if self.m_selectSprite then
            			local tab1 = map_tab[self.m_selectRow]
						local list_id1 = tab1.list_id
            			self.m_selectSprite:removeAllChildrenWithCleanup(true)
            			if self.m_showPos[list_id1 .. "_" .. self.m_selectCol] == 1 and self.m_boss_position ==  list_id1 .. "_" .. self.m_selectCol then
            				local bossSprite = CCSprite:createWithSpriteFrameName("ui_teamRaid_boss_small.png")
							if bossSprite and self.m_selectSprite then
								local viewSize = self.m_selectSprite:getContentSize()
								self.m_selectSprite:addChild(bossSprite)
								bossSprite:setPosition(ccp(viewSize.width*0.5, viewSize.height*0.5))
							end
            			end
            		end
            		sp:removeAllChildrenWithCleanup(true)
            		local selSp = CCSprite:createWithSpriteFrameName("ui_teamRaid_firstBoss_sel.png")
    				if selSp and sp then
						local viewSize = sp:getContentSize()
						sp:addChild(selSp)
						selSp:setPosition(ccp(viewSize.width*0.5, viewSize.height*0.5))
					end
				    if self.m_showPos[list_id .. "_" .. j] == 1 and self.m_boss_position ==  list_id .. "_" .. j then
        				local bossSprite = CCSprite:createWithSpriteFrameName("ui_teamRaid_boss_small.png")
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


function game_teamRaid_firstBoss_scene:refreshRightInfo( row,col )
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
		end
		if self.m_boss_position == list_id .. "_" .. col then
			monsterType = 3   -- 小怪
		end
	end
	local monsterName,monsterDiff = "???","???"
	if monsterType ~= 0 then
		monsterName = name[monsterType]
		monsterDiff = difficulty[monsterType]
	end
	self.m_name_label1:setString(monsterName)
	self.m_name_label2:setString(monsterName)
	self.m_combat_label1:setString(monsterDiff)
	self.m_combat_label2:setString(monsterDiff)
end

function game_teamRaid_firstBoss_scene:getMapFlag( config, m, n )
	-- body
	
end


function game_teamRaid_firstBoss_scene:goToWhere(  )
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


function game_teamRaid_firstBoss_scene:refreshTimeLabel( )
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
	cclog2(m_cdtime_node,"   -------------------    cd    ")
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

function game_teamRaid_firstBoss_scene:refreshProgress(  )
	-- body
	self.m_progress_node:removeAllChildrenWithCleanup(true)
	local bar = ExtProgressTime:createWithFrameName("ui_teamRaid_new_progress22.png","ui_teamRaid_new_progress2.png");
    if bar then
	    bar:setScaleX(1);
	    local value = self.m_tGameData.boss_hp_percent or 100
	    value = value > 100 and 100 or value
	    local viewSize = self.m_progress_node:getContentSize()
	    self.m_progress_lb:setString(value .. "%")
	    bar:setMaxValue(100)
	    bar:setCurValue(value)
	    bar:setAnchorPoint(ccp(0.5,0.5))
	    bar:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
	    self.m_progress_node:addChild(bar,10)
	end

end


function game_teamRaid_firstBoss_scene:refreshUi(  )
	-- body
	-- self:refreshBtn()
	self:refreshMap()
	self:refreshRightInfo(self.m_selectRow,self.m_selectCol)
	self:refreshTimeLabel()
	self:refreshProgress()
end

function game_teamRaid_firstBoss_scene:init( t_params )
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

function game_teamRaid_firstBoss_scene:create( t_params )
	-- body
	local scene = CCLayer:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end

return game_teamRaid_firstBoss_scene