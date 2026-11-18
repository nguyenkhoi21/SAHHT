local game_newRichMan_main = {
	m_tGameData = nil,	
	m_node_move = nil,
	m_currentNum = nil,--当前所在的id
	m_rollPoint = nil,--投掷的点数
	m_tab_moveNode = nil,--存放移动的3个node
	m_node_player = nil,
	m_sprite_playerDi = nil,
	m_anim_node = nil, -- 色子
	m_node = nil,
	m_sprite_front1 = nil,
	m_sprite_front2 = nil,
	m_sprite_front3 = nil,
	m_animFlag = nil,--是否正在播放动画
	m_shared = nil,
	m_tab_mapData = nil,
	m_frist_step = nil,--第一次进来的id
	m_reward = nil,
	m_label_score = nil,
	m_btn_reward = nil,
	m_old_step = nil,
	m_btn_boss = nil,
	m_rank_btn = nil,
	m_node_action = nil,
	m_label_action = nil,
	m_scroll_msgBoard = nil,
	m_node_broadcastboard = nil,
	bigbossdata = nil,
}

function game_newRichMan_main.destroy( self )
	self.m_tGameData = nil;
	self.m_node_move = nil;
	self.m_currentNum = nil;
	self.m_rollPoint = nil;
	self.m_tab_moveNode = nil;
	self.m_node_player = nil;
	self.m_sprite_playerDi = nil;
	self.m_anim_node = nil;
	self.m_node = nil;
	self.m_sprite_front1 = nil;
	self.m_sprite_front2 = nil;
	self.m_sprite_front3 = nil;
	self.m_animFlag = nil;
	self.m_shared = nil;
	self.m_tab_mapData = nil;
	self.m_frist_step = nil;
	self.m_reward = nil;
	self.m_label_score = nil;
	self.m_btn_reward = nil;
	self.m_old_step = nil;
	self.m_btn_boss = nil;
	self.m_rank_btn = nil;
	self.m_node_action = nil;
	self.m_label_action = nil;
	self.m_scroll_msgBoard = nil;
	self.m_node_broadcastboard = nil;
	self.bigbossdata = nil;
end
function game_newRichMan_main.back( self )
	if self.m_shared then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared);
		self.m_shared = nil;
	end
	game_scene:enterGameUi("game_main_scene")
end
function game_newRichMan_main.createUi( self, t_params )
	local ccbNode = luaCCBNode:create();
	local function onMainBtnClick( target, event )
		local tagNode = tolua.cast(target, "CCNode");
		local btnTag = tagNode:getTag();
		if not self.m_animFlag then
			if btnTag == 1 then
				self:back()
			elseif btnTag == 101 then
				-- self.m_tGameData.need_fight = nil
				cclog2(self.need_fight,"self.need_fight-=-----------")
				if self.m_tGameData.need_fight then
					if self.m_tGameData.need_donation then
						self:createDonationAlerts()
					else
						self:toPopScene()
					end
				
				else
					local function responseMethod( tag,gameData )
						if gameData then
							local data = gameData:getNodeWithKey("data")
					        data = json.decode(data:getFormatBuffer())
					        self.m_old_step = self.m_tGameData.step
					        self.m_tGameData = data
					        -- cclog2(self.m_tGameData,"m_tGameData ---- ")
							self.m_anim_node:removeAllChildrenWithCleanup(true)
							self.m_anim_node:setPosition(120,30)
							self.m_rollPoint = self.m_tGameData.num
							self.m_currentNum = self.m_tGameData.step
							self:createDiceAnim(self.m_tGameData.num)
							game_util:setPlayerPropertyByCCBAndTableData2(ccbNode)
							self:refreshUi()
							if self.m_tGameData.reward then
								self.m_reward = self.m_tGameData.reward
							end
							if self.m_tGameData.got_puzzles then
								-- cclog2(self.m_tGameData,"self.m_tGameData.got_puzzle ==== ")
								local log = ""
								for i=1,game_util:getTableLen(self.m_tGameData.got_puzzles) do
									log = log .. self.m_tGameData.got_puzzles[i] .. " "
								end
								game_util:addMoveTips({text = "Chúc mừng bạn được Mảnh ghép mới".. log .. ", nhấp nút Mảnh ghép để xem"})
							end
						else
							self.m_animFlag = false
						end
					end
					network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_slot"), http_request_method.GET, nil,"monopoly_slot",true,true)
				end
			elseif btnTag == 102 then
				local function responseMethod( tag,gameData )
					game_scene:addPop("game_newRichMan_puzzles_pop", {gameData = gameData})
				end
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_index"), http_request_method.GET, nil,"monopoly_index")
			elseif btnTag == 103 then -- boss
				local function responseMethod(tag,gameData)
					game_data:setBattleType("newRichMan");
					game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
				end
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_boss_fight"), http_request_method.GET, nil,"monopoly_boss_fight")
			elseif btnTag == 104 then -- 阵型
				local function  responseMethod( tag, gameData )
					local popCallBack = self:createTopopCallBackFunc()
				    game_scene:addPop("game_newRichMan_formation_pop",{gameData = gameData, openType = "formation", popCallBack = popCallBack})
				end
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_formation_info"), http_request_method.GET, nil,"monopoly_formation_info")
			elseif btnTag == 105 then --获奖记录
				local function responseMethod(tag,gameData)
					game_scene:addPop("game_newRichMan_depot_pop",{gameData = gameData})
				end
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_index"), http_request_method.GET, nil,"monopoly_index")
			elseif btnTag == 106 then --boss伤害排行
				local params = {}
				params.tp = "slots"
				params.page = 0
				local function responseMethod( tag,gameData )
				     game_scene:addPop("ui_newRichMan_mainRank_pop",{gameData = gameData})
				end
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_top"), http_request_method.GET, params,"monopoly_top")
			elseif btnTag == 107 then--活动说明
				game_scene:addPop("game_active_limit_detail_pop",{enterType = "184"})
			elseif btnTag == 108 then--地块攻占的log
				local function responseMethod( tag,gameData )
					local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
					local log = data.log
					local msg = ""
					function getTimeStamp(t)
					    return os.date("%X",t)
					end
					for i=1,#log do
						local time = getTimeStamp(log[i]["ts"])
					    msg = msg .. time  .. "    "  .. log[i]["msg"] .. "\n"
					end
				    game_scene:addPop("game_newRichMan_getLog_pop",{gameData = gameData, text = msg })
				end
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_donation_reawrd_log"), http_request_method.GET, nil,"monopoly_donation_reawrd_log")
			end
		end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
	ccbNode:openCCBFile("ccb/ui_newRichMan_main.ccbi");
	game_util:setPlayerPropertyByCCBAndTableData2(ccbNode)
	self.m_node_action = ccbNode:nodeForName("m_node_action")
	self.m_label_action = ccbNode:labelTTFForName("m_label_action")

	self.m_btn_reward = ccbNode:controlButtonForName("m_btn_reward")
	self.m_label_score = ccbNode:labelTTFForName("m_label_score")
	self.m_node_move = ccbNode:nodeForName("m_node_move")
	self.m_node_player = ccbNode:nodeForName("m_node_player")
	self.m_anim_node = ccbNode:nodeForName("m_anim_node")
	self.m_sprite_front1 = ccbNode:spriteForName("m_sprite_front1")
	self.m_sprite_front2 = ccbNode:spriteForName("m_sprite_front2")
	self.m_sprite_front3 = ccbNode:spriteForName("m_sprite_front3")
	self.m_scroll_msgBoard = ccbNode:scrollViewForName("m_scroll_msgBoard")
	self.m_node_broadcastboard = ccbNode:spriteForName("m_node_broadcastboard")
	self.m_btn_boss = ccbNode:controlButtonForName("m_btn_boss")
	self.m_rank_btn = ccbNode:controlButtonForName("m_rank_btn")

	game_util:addTipsAnimByType(self.m_btn_boss,16)
	self:createHeroAnim()
	self.m_sprite_playerDi = CCSprite:createWithSpriteFrameName("ui_richMan_playerDi.png")
	self.m_node_player:addChild(self.m_sprite_playerDi,9,9)
	self.m_sprite_playerDi:setPosition(ccp(3,3))
	local viewSize = ccbNode:getContentSize()
	self.m_sprite_front2:setPosition(ccp(viewSize.width *1.5,51 ))
	self.m_sprite_front3:setPosition(ccp(viewSize.width *2.5,15 ))
	self.m_node = ccbNode 

	local m_sprite_light1 = ccbNode:spriteForName("m_sprite_light1")
	local m_sprite_light2 = ccbNode:spriteForName("m_sprite_light2")
	local m_sprite_Bg = ccbNode:spriteForName("m_sprite_Bg")
	-- self.m_tGameData.night = 1
	local m_node_bgAnim =ccbNode:nodeForName("m_node_bgAnim")
	local anim = game_util:createEffectAnim("changjing1",1,true,"newRichMan2")
	
	if self.m_tGameData.night == 0 then -- 使用白天背景
		m_sprite_light1:setVisible(false)
		m_sprite_light2:setVisible(false)
	 	anim = game_util:createEffectAnim("changjing1",1,true,"newRichMan1")
	else --夜晚背景
		local spriteNightBg = CCSprite:create("ccbResources/ui_richMan_bg2.png")
		local x,y = spriteNightBg:getContentSize()
		m_sprite_Bg:addChild(spriteNightBg)
		spriteNightBg:setAnchorPoint(ccp(0,0))
		spriteNightBg:setPosition(ccp(0,0))
		m_sprite_light1:setVisible(true)
		m_sprite_light2:setVisible(true)
		anim = game_util:createEffectAnim("changjing1",0.1,true,"newRichMan2")
	end	
		
	local tempsize = ccbNode:getContentSize()
	local nodePosX,nodePosY = m_node_bgAnim:getPosition()
	m_node_bgAnim:setPosition(ccp(nodePosX,nodePosY - 20))
	-- anim:setPosition(ccp(tempsize.width * 0.5,tempsize.height * 0.7))
	m_node_bgAnim:addChild(anim,10,10)
	local endPosX,endPosY = self.m_btn_reward:getPosition()
	local endPos = ccp(endPosX,endPosY)
	if t_params.reward then
		game_util:rewardTipsByDataTable(t_params.reward, nil,endPos)
	end
	

	return ccbNode;

end
--[[--
	色子的动画
]]
function game_newRichMan_main.createDiceAnim( self,i )
	self.m_animFlag = true

	self.m_anim_node:setVisible(true)
	self.m_anim_node:removeAllChildrenWithCleanup(true)
	local function RanimCallBack( animNode, theId, theLabelName )
		local parent = animNode:getParent()
		if theLabelName == "tou" then
			animNode:playSection("daiji" .. i) 
	    elseif theLabelName == "daiji" .. i then
        	animNode:playSection(tostring(i))
	    else
	        if self.m_tGameData.add_exp then
				game_util:addMoveTips({text = "Chúc mừng bạn được".. self.m_tGameData.add_exp .. "EXP"})
	        end
			self.m_anim_node:setVisible(false)
        	-- local realPosIndex = self.m_frist_step 
			-- local x,y = self.m_node_player:getPosition()
			local realPosIndex = self:getRealPosIndex(self.m_frist_step)--计算人物在屏幕的第几个地块上
			--[[
				判断当前人物在第几个地块上
				大于等于3时候，人物不动，地图向左移动
				等于2的时候，如果投点小于1，人物向右移动一，再根据投点数目减去1去移动地图
				等于1的时候，看roll点超不超过2 如果不超过2️，只人物移动，超过2，人物移动完地图继续移动
			]]

			if realPosIndex >= 3 then 
				self:upDateMapPos(self.m_rollPoint)
				self.m_frist_step = 3
			elseif realPosIndex == 2 then
				self:heroMove(1,"toUpDateMapPos")
				self.m_frist_step = 3
			elseif realPosIndex == 1 then
				if self.m_rollPoint <= 2 then
					self:heroMove(self.m_rollPoint)
					self.m_frist_step = self.m_frist_step + self.m_rollPoint
				elseif self.m_rollPoint > 2 then
					self:heroMove(2,"toUpDateMapPos")
					self.m_frist_step = 3
				end
			end
	    end
	end
	local z_zjrAnim = game_util:createAnimEffect("touzi","touzi",RanimCallBack,nil,true);
    if z_zjrAnim then
    	local x,y = self.m_node:getContentSize().width,self.m_node:getContentSize().height
    	self.m_anim_node:setPosition(ccp(x/2,y/5))
        local tempsize = self.m_anim_node:getContentSize()
        z_zjrAnim:setAnchorPoint(ccp(-0.5,0.5));
        z_zjrAnim:setPosition(ccp(tempsize.width*0.5,tempsize.height*0.5));
        z_zjrAnim:playSection("tou")
        self.m_anim_node:addChild(z_zjrAnim,10,10)
    end
end
--[[--
	人物的动画
]]
function game_newRichMan_main.createHeroAnim(self)
    -- self.m_node_player:removeAllChildrenWithCleanup(true)
    local card_ccbNode = self:setQuanshenxiang();
    card_ccbNode:setScale(0.6)
    self.m_node_player:addChild(card_ccbNode,10,10)
end
function game_newRichMan_main.setQuanshenxiang(self)
    local m_iAnim = nil;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local character_id = 32900--self.m_richman_plot["1"].character_id
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(character_id));
    if  heroCfg then
        m_iAnim = game_util:createIdelAnim("suolong1",0,heroData,heroCfg);
        if m_iAnim then
            m_iAnim:setRhythm(1);
            self:setHeroAnimName(m_iAnim,"daiji")
            local itemSize = m_iAnim:getContentSize();
            m_iAnim:setAnchorPoint(ccp(0.5,0.5));
            m_iAnim:setPosition(ccp(5,27))
        end
    end
    return m_iAnim;
end

function game_newRichMan_main.setHeroAnimName( self, parentNode, animName )
	-- cclog("-----setHeroAnimName----" .. animName)
	local function animEnd(animNode,theId,lableName)
	    game_anim:playSection(parentNode,lableName);
	end
	game_anim:playSection(parentNode , animName);
    parentNode:registerScriptTapHandler(animEnd);
end
--[[--
	设置三个node的初始位置
]]
function game_newRichMan_main.setStartPos( self ) 
	self.m_node_move:removeAllChildrenWithCleanup(true)
	cclog("099867645432")
	local node_move = nil
	self.m_tab_moveNode = {}
	for i=1,3 do
		node_move = luaCCBNode:create();
		node_move:openCCBFile("ccb/ui_newRichMan_moveItem.ccbi");
		table.insert(self.m_tab_moveNode,node_move)
		self.m_node_move:addChild(self.m_tab_moveNode[i],4 - i)
		self:createBuildAndRoad(node_move,self.m_tab_mapData[i])
	end
	local node_moveSize = self.m_tab_moveNode[1]:getContentSize()

	self.m_tab_moveNode[1]:setPosition(ccp(0,0))
	self.m_tab_moveNode[2]:setPosition(ccp(node_moveSize.width - 45,0))
	self.m_tab_moveNode[3]:setPosition(ccp(2 * node_moveSize.width - 90,0))

	-- self.m_animFlag = true
	--设置人物的初始位置
	local playerStartPosX,playerStartPosY = self.m_node_player:getPosition()
	local realPosIndex = self:getRealPosIndex(self.m_frist_step) --当前地块号所在的位置
	if self.m_currentNum > self.m_frist_step + (6-realPosIndex) then
		self:upDateMapPos(self.m_rollPoint)
	elseif realPosIndex  <= 3 then

		local toPos = ccp(playerStartPosX + 184/2 * (realPosIndex - 1),playerStartPosY)
		self.m_node_player:setPosition(toPos)
		-- self:heroMove(realPosIndex - 1, nil, nil, true)
	elseif realPosIndex  <= 6 then
		local toPos = ccp(playerStartPosX + 184/2 * (2),playerStartPosY)
		self.m_node_player:setPosition(toPos)
		local need = 92 * (realPosIndex - 3) 
		for i=1,3 do
			self.m_tab_moveNode[i]:setPosition(self.m_tab_moveNode[i]:getPositionX()-need,0)
		end
		-- self:heroMove(2, "toUpDateMapPos", realPosIndex, true)
	end
end
function game_newRichMan_main.createRoleIcon( self, parentNode, roleId, name )
	local roleId = roleId or 1 
	local sprite_head = game_util:createRoleBigImgHalf(roleId)
	sprite_head:setScale(0.4)
    sprite_head:setAnchorPoint(ccp(0.5, 0))

    local sprite_headBg = CCSprite:createWithSpriteFrameName("ui_richMan_roleBg1.png")
    sprite_head:setPosition(ccp(35,198))
    sprite_headBg:setPosition(ccp(38,210))

    local sprite_headBg2 = CCSprite:createWithSpriteFrameName("ui_richMan_roleBg2.png")
    sprite_headBg2:setPosition(ccp(38,200))
	name = name or ""
	local namelab = CCLabelTTF:create(name,TYPE_FACE_TABLE.Arial_BoldMT,10)
    namelab:setPosition(ccp(35,245))

    parentNode:addChild(namelab)
    parentNode:addChild(sprite_headBg)
    parentNode:addChild(sprite_head)
    parentNode:addChild(sprite_headBg2)
end

--[[
	move_num  人物node移动的距离
	toUpDateMapPos 人物移动后是否调用地图移动的标识
	fristFlag 是否是第一次进入界面
	fristmove  第一次大于3的时候要移动的

]]
function game_newRichMan_main.heroMove( self, move_num, toUpDateMapPos, fristmove, fristFlag )
	self.m_sprite_playerDi:setVisible(false)
	local x,y = self.m_node_player:getPosition()
	local node_moveSize = self.m_tab_moveNode[1]:getContentSize()

	local function delyFunc( )
		if toUpDateMapPos and toUpDateMapPos == "toUpDateMapPos" then
			if fristmove  then
				self:upDateMapPos(fristmove-3, fristFlag)
			else
				self:upDateMapPos(self.m_rollPoint - move_num,fristFlag)
			end
		else
			self.m_sprite_playerDi:setVisible(true)
			-- self.m_animFlag = false
			local card_ccbNode = self.m_node_player:getChildByTag(10) --改变人物动画的状态
			self:setHeroAnimName(card_ccbNode,"daiji")
			if self.m_old_step > self.m_tGameData.step   then --当地块总数不是6的倍数的时候，完成一圈刷新界面
				if (self.m_tGameData.builing_count % 6) ~= 0 then
					local function responseMethod(tag,gameData)
						-- self:back()
					    game_scene:enterGameUi("game_newRichMan_main",{gameData = gameData,isJump = true});
					end
					network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_index"), http_request_method.GET, nil,"monopoly_index")
				end
			else
			end
			if fristFlag then
			else
				self:toPopScene()
			end
		end
	end
	local card_ccbNode = self.m_node_player:getChildByTag(10) --改变人物动画的状态
	self:setHeroAnimName(card_ccbNode,"qianjin")
	local arrAnim = CCArray:create()
	local moveto = CCMoveTo:create(move_num * 0.75, ccp(x + 184/2 * move_num,y))
	arrAnim:addObject(moveto)
	arrAnim:addObject(CCCallFunc:create(delyFunc))
	self.m_node_player:runAction(CCSequence:create(arrAnim))
end

function game_newRichMan_main.upMapData( self )
	table.insert(self.m_tab_mapData,self.m_tGameData.slots)
	table.insert(self.m_tab_mapData,self.m_tGameData.next_slots)
	table.insert(self.m_tab_mapData,self.m_tGameData.tail_slots)
end
function game_newRichMan_main.createRewardIcon( self, parentNode, cfgId, mapId, mapData)
	self:dealWithType(cfgId, "createIcon", parentNode, mapId, mapData)
end
--[[
	parentNode  地图块
	mapData  当前地图块下六个建筑的数据
]]
function game_newRichMan_main.createBuildAndRoad( self, parentNode, mapData )
	local roadNameTab = {"ui_richMan_mainRoad1.png","ui_richMan_mainRoad1.png"}

	for i=1,6 do
		local cfgId = mapData[i].c_id --获取当前地块的配置id
		local buildName = self.m_monopoly_cfg[tostring(cfgId)].build_name
		local m_sprite_build = parentNode:spriteForName("m_sprite_build" .. i)
		if buildName == "" then
			m_sprite_build:setVisible(false)
		else
			m_sprite_build:setVisible(true)
			m_sprite_build:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(buildName))
		end
		
		local m_sprite_road = parentNode:spriteForName("m_sprite_road" .. i)
		m_sprite_road:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(roadNameTab[i%2 + 1]))
		local num_node = parentNode:nodeForName("m_node_num" .. i)
		self:createNumIcon(mapData[i].id, num_node)
		self:createRewardIcon(m_sprite_road, cfgId, mapData[i].id, mapData[i])
	end
end
--[[
    设置图片数字
]]
function game_newRichMan_main.createNumIcon(self,num,node)
	num = tonumber(num)
    node:removeAllChildrenWithCleanup(true);
    if num >= 10 and num < 100 then
        local high = math.floor(num / 10)
        local low = math.floor(num % 10)

        local num_1 = CCSprite:createWithSpriteFrameName("ui_richMan_" .. high .. ".png")
        local num_2 = CCSprite:createWithSpriteFrameName("ui_richMan_" .. low .. ".png")

        num_1:setAnchorPoint(ccp(0.5,0.5))
        num_2:setAnchorPoint(ccp(0.5,0.5))

        num_1:setPosition(ccp(-2,0))
        num_2:setPosition(ccp(10,0))

        node:addChild(num_1,10)
        node:addChild(num_2,10)
    elseif num >= 100 then
        local table = {1,0,0}
        local x = math.floor(num / 100)
        local y = math.floor((num - x*100) / 10)
        local z = num - x*100 - y*10
        table[1] = x
        table[2] = y
        table[3] = z
        for i=1,3 do
            local num_sprite = CCSprite:createWithSpriteFrameName("ui_richMan_" .. table[i] .. ".png")
            num_sprite:setAnchorPoint(ccp(0.5,0.5))
            num_sprite:setPosition(ccp(-15+(i-1)*20,0))
            node:addChild(num_sprite,10)
        end
    else
        local num_sprite = CCSprite:createWithSpriteFrameName("ui_richMan_" .. num .. ".png")
        num_sprite:setAnchorPoint(ccp(0.5,0.5))
        num_sprite:setPosition(ccp(10,0))
        node:addChild(num_sprite,10)
    end
end
--[[
	通过定时器来实现地图移动 
	在每次三个node的位置交换的时候，需要比较出来最后的那个node，重新设置建筑图片
]]
function game_newRichMan_main.upDateMapPos( self, move_num, fristFlag )
	-- cclog2(move_num,"move_num ===== ")
	self.m_sprite_playerDi:setVisible(false)
	local zorderTab = {1,2,3} --三个node的zorder  在最左边的要在上面
	local time = 0 --定时器需要执行的次数
	local curTime = 0 -- 当前定时器执行了多少次
	local movePx = 0 --需要移动的像素长度
	local leftNode, midNode, rightNode = nil, nil, nil
	local node_moveSize = self.m_tab_moveNode[1]:getContentSize()
	movePx = math.floor(92 * move_num)
	-- cclog2(movePx,"movePx === ")
	time = movePx/5 - 1 --math.ceil(movePx/5)
	-- cclog2(time,"time === ")
 
	local viewSize = self.m_node:getContentSize()
	self.m_shared = 0;
	function tick( dt )
		local need = 5 -- 每次需要移动的像素
	    if curTime > time then
        	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared);
        	need = (1 - (curTime - time) ) * 5
        end
        self.m_sprite_front1:setPositionX(self.m_sprite_front1:getPositionX() - need)
        self.m_sprite_front2:setPositionX(self.m_sprite_front2:getPositionX() - need)
        self.m_sprite_front3:setPositionX(self.m_sprite_front3:getPositionX() - need)
        self.m_tab_moveNode[1]:setPositionX(self.m_tab_moveNode[1]:getPositionX() - need);
        self.m_tab_moveNode[2]:setPositionX(self.m_tab_moveNode[2]:getPositionX() - need);
        self.m_tab_moveNode[3]:setPositionX(self.m_tab_moveNode[3]:getPositionX() - need);
        
        local minNodePosX = math.max(self.m_tab_moveNode[1]:getPositionX(), self.m_tab_moveNode[2]:getPositionX())
        minNodePosX = math.max(minNodePosX,self.m_tab_moveNode[3]:getPositionX()) --获取当前最右边的那个node的横坐标
       	--当最左边的node移动了本身1.5个宽度的坐标时，移动到最右边
        if self.m_tab_moveNode[1]:getPositionX() + self.m_tab_moveNode[1]:getContentSize().width <= -node_moveSize.width/2 then
            --第一张地图的横坐标 = 最后面那个node的坐标 + 第二张地图的宽度
            self.m_tab_moveNode[1]:setPositionX(minNodePosX + node_moveSize.width - 45);

            self.m_tab_moveNode[1]:getParent():reorderChild(self.m_tab_moveNode[1],1) --重新设置三个node的zorder
            self.m_tab_moveNode[2]:getParent():reorderChild(self.m_tab_moveNode[2],3)
            self.m_tab_moveNode[3]:getParent():reorderChild(self.m_tab_moveNode[3],2)
            -- cclog2(self.m_tGameData.next_slots,"1-----------------")

            self.m_sprite_front1:setPositionX(viewSize.width + self.m_sprite_front1:getContentSize().width)
            self:createBuildAndRoad(self.m_tab_moveNode[1],self.m_tGameData.next_slots) --更新地图数据
            -- cclog2(self.m_tGameData.next_slots,"self.m_tGameData.next_slots-=-------")
        end
        	
        if (self.m_tab_moveNode[2]:getPositionX() + self.m_tab_moveNode[2]:getContentSize().width <= -node_moveSize.width/2) then
            --将第二张地图添加到第一张地图后面
            --第二张地图的横坐标 = 最后面那个node的坐标 + 第一张地图的宽度
            self.m_tab_moveNode[2]:setPositionX(minNodePosX + node_moveSize.width - 45);

            self.m_tab_moveNode[1]:getParent():reorderChild(self.m_tab_moveNode[1],2) --重新设置三个node的zorder
            self.m_tab_moveNode[2]:getParent():reorderChild(self.m_tab_moveNode[2],1)
            self.m_tab_moveNode[3]:getParent():reorderChild(self.m_tab_moveNode[3],3)
            -- cclog2(self.m_tGameData.next_slots,"2-----------------")

            self.m_sprite_front2:setPositionX(viewSize.width + self.m_sprite_front1:getContentSize().width)
            self:createBuildAndRoad(self.m_tab_moveNode[2],self.m_tGameData.next_slots) --更新地图数据
            -- cclog2(self.m_tGameData.next_slots,"self.m_tGameData.next_slots-=-------")

		end

        if (self.m_tab_moveNode[3]:getPositionX() + self.m_tab_moveNode[3]:getContentSize().width <= -node_moveSize.width/2) then
            --第三张地图的横坐标 = 最后面那个node的坐标 + 第一张地图的宽度
            self.m_tab_moveNode[3]:setPositionX(minNodePosX + node_moveSize.width - 45);

            self.m_tab_moveNode[1]:getParent():reorderChild(self.m_tab_moveNode[1],3) --重新设置三个node的zorder
            self.m_tab_moveNode[2]:getParent():reorderChild(self.m_tab_moveNode[2],2)
            self.m_tab_moveNode[3]:getParent():reorderChild(self.m_tab_moveNode[3],1)
            -- cclog2(self.m_tGameData.next_slots,"3-----------------")
            
            self.m_sprite_front3:setPositionX(viewSize.width + self.m_sprite_front1:getContentSize().width)
            self:createBuildAndRoad(self.m_tab_moveNode[3],self.m_tGameData.next_slots) --更新地图数据
            -- cclog2(self.m_tGameData.next_slots,"self.m_tGameData.next_slots-=-------")
            
		end  

		if curTime > time then
			local card_ccbNode = self.m_node_player:getChildByTag(10) --改变人物动画的状态
			self:setHeroAnimName(card_ccbNode,"daiji")
			
			if self.m_old_step > self.m_tGameData.step and (self.m_tGameData.builing_count % 6) ~= 0 then --当地块总数不是6的倍数的时候，完成一圈刷新界面
				if (self.m_tGameData.builing_count % 6) ~= 0 then
					local function responseMethod(tag,gameData)
						-- self:back()
					    game_scene:enterGameUi("game_newRichMan_main",{gameData = gameData,isJump = true});
					end
					network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_index"), http_request_method.GET, nil,"monopoly_index")
				end
			else
			end
			if self.m_sprite_playerDi then
				self.m_sprite_playerDi:setVisible(true)
			end
			if fristFlag then
			else
				self:toPopScene()
			end
		end  
	    curTime = curTime + 1
	end
	local card_ccbNode = self.m_node_player:getChildByTag(10) --改变人物动画的状态
	self:setHeroAnimName(card_ccbNode,"qianjin")
	self.m_shared = scheduler.schedule(tick, 1/50, false)
end

function game_newRichMan_main.createDonationAlerts( self )
	local rewardCfg = getConfig(game_config_field.monopoly_reward)
    rewardCfg = rewardCfg:getNodeWithKey("7"):getNodeWithKey("reward")
	rewardCfg = json.decode(rewardCfg:getFormatBuffer())
	local icon,name,count,rewardType,quality = game_util:getRewardByItemTable(rewardCfg[1],nil,true)
	local t_params = 
	{
	    title = "Nhắc nhở",
	    okBtnCallBack = function(target,event)
	        require("game_ui.game_pop_up_box").close();
	        local function responseMethod( tag, gameData )
	            if gameData and tolua.type(gameData) == "util_json" then
        			local data = gameData:getNodeWithKey("data")
        	        data = json.decode(data:getFormatBuffer())
        	        self.m_tGameData = data
        	        self:refreshUi()
	            	game_util:addMoveTips({text = "Đã đóng góp"})
	            end
	        end
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_donation"), http_request_method.GET, params,"monopoly_donation")
	    end,   --可缺省
	    cancelBtnCallBack = function(target,event) 
	        require("game_ui.game_pop_up_box").close();
	        local function responseMethod(tag,gameData)
	        	self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
	        	self:refreshUi()
	        end
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_index"), http_request_method.GET, nil,"monopoly_index")
	    end,   --可缺省
	    closeCallBack = function(target,event)
	        require("game_ui.game_pop_up_box").close();
	        local function responseMethod(tag,gameData)
	        	self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
	        	self:refreshUi()
	        end
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_index"), http_request_method.GET, nil,"monopoly_index")
	    end,
	    okBtnText = "Xác nhận", 
	    cancelBtnText = "Hủy",      --可缺省
	    text = "Bạn chưa khiêu chiến thành công, phải đóng góp" .. count .. name .. "Đến bái người chơi chiếm đất này, nếu không phải đợi 10p ",      --可缺省
	    onlyOneBtn = false,          --可缺省
	}
	require("game_ui.game_pop_up_box").show(t_params);
end

--[[
	创建一个回调函数，在跳转到pop界面时候传入，在移除pop的时候调用，刷新数据
]]
function game_newRichMan_main.createTopopCallBackFunc( self )
	local function toPopCallBack( self2, reward, isWin )
		self.m_animFlag = false
		if isWin then
			self:createDonationAlerts()
			return
		end

		if reward then
			local endPosX,endPosY = self.m_btn_reward:getPosition()
			local endPos = ccp(endPosX,endPosY)
			game_util:rewardTipsByDataTable(reward, nil,endPos)
		end

		local function responseMethod(tag,gameData)
			self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
			self:refreshUi()
		end
		network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_index"), http_request_method.GET, nil,"monopoly_index")
	end
	return toPopCallBack
end

--[[
	cfgId 对应的配置id
	types 事件的类型
	parentNode  创建icon的父节点
	mapId 当前的所在地块数
	mapData 当前地块的数据
]]
function game_newRichMan_main.dealWithType( self,cfgId, types, parentNode, mapId, mapData )
	if mapId then
	else
		mapId = self.m_tGameData.step
	end
	if mapData then
	else
		local realPosIndex = self:getRealPosIndex(mapId)
		mapData = self.m_tGameData.slots[realPosIndex]
	end
	local fightId = mapData.fight_id
	local function createRewardAndAnim( reward, sort )
		local icon,name,count = game_util:getRewardByItemTable(reward,nil,true)
		if icon then
			parentNode:addChild(icon)
			icon:setScale(0.8)
			icon:setPosition(ccp(60,80))
			local animArr = CCArray:create()
			local x,y = icon:getPosition()
			local tintto1 = CCTintTo:create(1,175,175,175)
			local tintto2 = CCTintTo:create(1,255,255,255)
			local fadeIn = CCFadeIn:create(1)
			local fadeOut = CCFadeOut:create(1)
			local moveto1 = CCMoveTo:create(0.5,ccp(x, y + 2))
			local moveto2 = CCMoveTo:create(0.5,ccp(x, y - 2))
			local spawn1 = CCSpawn:createWithTwoActions(fadeIn,moveto1)
			local spawn2 = CCSpawn:createWithTwoActions(fadeOut,moveto2)
			if reward[1] == 5 or  reward[1] == 6 or reward[1] == 7 then
				spawn1 = CCSpawn:createWithTwoActions(tintto2,moveto1)
				spawn2 = CCSpawn:createWithTwoActions(tintto1,moveto2)
			end
			animArr:addObject(spawn1)
			animArr:addObject(spawn2)
			local countlab = CCLabelTTF:create("x" .. count,TYPE_FACE_TABLE.Arial_BoldMT,10)
			countlab:setScale(2)
			icon:addChild(countlab,99,99)
			countlab:setPosition(ccp(30,5))
			if sort == 3 then
				icon:setScale(0.8)
				countlab:setVisible(false)
			else
				countlab:setVisible(true)
				icon:setScale(0.6)
				icon:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
			end
		end
	end 
	local sort = self.m_monopoly_cfg[tostring(cfgId)].sort 
	sort = tonumber(sort)
	if parentNode then
		parentNode:removeAllChildrenWithCleanup(true)
	end
	if sort == 2 then ----道具奖励 
		if types == "toPop" then
			
		else
			local reward = self.m_monopoly_cfg[tostring(cfgId)].reward[1]
			createRewardAndAnim(reward, sort)
		end
		
	elseif sort == 3 then  --占领
		if types == "toPop" then
			local params = {}
			params.building_id = self.m_tGameData.step
			local function responseMethod(tag,gameData)
				-- cclog2(gameData,"gameData ===== ")
				local popCallBack = self:createTopopCallBackFunc()
				game_scene:addPop("game_newRichMan_enemy_pop", {gameData = gameData, popCallBack = popCallBack})
				-- game_scene:addPop("game_newRichMan_gamble_pop",{gameData = gameData, popCallBack = popCallBack})
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_building_info"), http_request_method.GET, params,"monopoly_building_info")
		else
			local realPosIndex = self:getRealPosIndex(mapId)
			local reward = mapData.common_reward[1]
			createRewardAndAnim(reward, sort)
			local name = mapData.owner_name
			math.randomseed(os.time())
			local roleid = mapData.owner_role
			if name ~= "" then
				self:createRoleIcon(parentNode, roleid, name)
			end
		end
		
	elseif sort == 4 then -- boss战
		if types == "toPop" then
			local function  responseMethod( tag, gameData )
				local popCallBack = self:createTopopCallBackFunc()
			    game_scene:addPop("game_newRichMan_formation_pop",{gameData = gameData, openType = "boss", popCallBack = popCallBack})
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_formation_info"), http_request_method.GET, nil,"monopoly_formation_info")
		else
			local monopoly_enemy_cfg = getConfig(game_config_field.monopoly_enemy)
			-- cclog2(fightId,"fightId ---- ")
			if fightId ~= "" then
				local ainmFile = monopoly_enemy_cfg:getNodeWithKey(tostring(fightId)):getNodeWithKey("animation"):toStr()
				local animNode = game_util:createIdelAnim(ainmFile,0);
				if animNode then
				    animNode:setRhythm(1);
				    game_anim:playSection(animNode , anim_label_name_cfg.daiji);
				    local itemSize = animNode:getContentSize();
				    animNode:setScaleX(-0.5)
				    animNode:setScaleY(0.5)
				    animNode:setAnchorPoint(ccp(0.5,0.5));
				    -- animNode:setPosition(ccp(70,85))
				    animNode:setPosition(ccp(70,120))
				    if fightId == 3800090 then
				    	animNode:setPosition(ccp(80,120))
				    end
				    parentNode:addChild(animNode,999,999)
				end
			end
		end
	elseif sort == 5 then -- 监狱地块
		if types == "toPop" then
			local function  responseMethod( tag, gameData )
				local popCallBack = self:createTopopCallBackFunc()
			    game_scene:addPop("game_newRichMan_formation_pop",{gameData = gameData, openType = "prison", popCallBack = popCallBack})
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_formation_info"), http_request_method.GET, nil,"monopoly_formation_info")
		else
		end
	elseif sort == 6 then --起点
		if types == "toPop" then
		else
			local reward = self.m_monopoly_cfg[tostring(cfgId)].reward[1]
			createRewardAndAnim(reward, sort)
		end
	elseif sort == 7 then -- 赌场
		if types == "toPop" then
			local function responseMethod(tag,gameData)
				local popCallBack = self:createTopopCallBackFunc()
				game_scene:addPop("game_newRichMan_gamble_pop",{gameData = gameData, popCallBack = popCallBack})
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_index"), http_request_method.GET, nil,"monopoly_index")
		else
			local reward = self.m_monopoly_cfg[tostring(cfgId)].reward[1]
			createRewardAndAnim(reward, sort)
		end
	elseif sort == 8  then --神将
		if fightId == "" or not(fightId)  then
		 	fightId = 800002
		end

		local monopoly_fight_cfg = getConfig(game_config_field.monopoly_fight)
		local position1 = monopoly_fight_cfg:getNodeWithKey(tostring(fightId))
		position1 = json.decode(position1:getFormatBuffer())
		local combat = 0
		
		local admiralId = position1["position1"][1]

		local monopoly_enemy_cfg = getConfig(game_config_field.monopoly_enemy)
		local ainmFile = monopoly_enemy_cfg:getNodeWithKey(tostring(admiralId)):getNodeWithKey("animation"):toStr()
		
		for i=1,5 do
			local id = position1["position" .. i][1]
			local battle_point = monopoly_enemy_cfg:getNodeWithKey(tostring(id)):getNodeWithKey("battle_point"):toInt()
			combat = combat +battle_point
		end
		if types == "toPop" then
			local reward = mapData.god_reward[1]
			local popCallBack = self:createTopopCallBackFunc()
			game_scene:addPop("game_newRichMan_admiral_pop",{admiralId = admiralId, god_reward_times = self.m_tGameData.god_reward_times,reward = reward, combat = combat,popCallBack = popCallBack})
		else
			local animNode = game_util:createIdelAnim(ainmFile,0);
			if animNode then
			    animNode:setRhythm(1);
			    game_anim:playSection(animNode , anim_label_name_cfg.daiji);
			    local itemSize = animNode:getContentSize();
			    animNode:setScaleX(-0.9)
			    animNode:setScaleY(0.9)
			    animNode:setAnchorPoint(ccp(0.5,0.5));
			    -- animNode:setPosition(ccp(70,85))
			    animNode:setPosition(ccp(70,120))
			    parentNode:addChild(animNode,999,999)
			end
		end
	elseif sort == 9 then -- 商城
		if types == "toPop" then
			local popCallBack = self:createTopopCallBackFunc()
		    game_scene:addPop("game_newRichMan_shop_pop",{gameData = gameData, openType = "newRichMan", popCallBack = popCallBack})
		else
		end
	elseif sort == 10 then --路霸
		if types == "toPop" then
			local params = {}
			params.building_id = self.m_tGameData.step
			local function responseMethod(tag,gameData)
				local popCallBack = self:createTopopCallBackFunc()
				game_scene:addPop("game_newRichMan_tyrant_pop", {gameData = gameData, popCallBack = popCallBack, mainSelf = self})
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_building_info"), http_request_method.GET, params,"monopoly_building_info")
			
		else
			local realPosIndex = self:getRealPosIndex(mapId)
			local reward = mapData.common_reward[1]
			createRewardAndAnim(reward, sort)
			local name = mapData.owner_name
			math.randomseed(os.time())
			local roleid = mapData.owner_role
			if name ~= "" then
				self:createRoleIcon(parentNode, roleid, name)
			end
		end
	elseif sort == 11 then
		if types == "toPop" then
			local function responseMethod(tag,gameData)
				game_scene:addPop("game_newRichMan_bigBoss_pop",{gameData = gameData})
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("depth_boss_index"), http_request_method.GET, nil,"depth_boss_index")
		else
		    local function sectionEnd( animNode, theId, theLabelName )
		        animNode:playSection(theLabelName)
		    end    
		    local anim = game_util:createAnimEffect("monopoly_dark","monopoly_dark",sectionEnd,nil,true);
		    if anim then
		        anim:setAnchorPoint(ccp(0.5,0.5));
		        game_anim:playSection(anim,"impact")
			    anim:setPosition(ccp(67,65))
		        parentNode:addChild(anim,999,999)
		    end
		end
	end
	if types == "toPop" then
		if  sort > 2 and sort < 11 and sort ~= 6  then
		else
			self.m_animFlag = false
		end
	else

	end
end
--[[
	投完后 根据地块类型去做各种处理
]]
function game_newRichMan_main.toPopScene( self )
	if self.m_reward then
		local endPosX,endPosY = self.m_btn_reward:getPosition()
		local endPos = ccp(endPosX,endPosY)
		game_util:rewardTipsByDataTable(self.m_reward, nil, endPos)
		self.m_reward = nil;
	end
	local realPosIndex = self:getRealPosIndex(self.m_tGameData.step) --当前地块所在位置
	local cfgId = self.m_tGameData.slots[realPosIndex].c_id
	self:dealWithType(cfgId,"toPop")
end
function game_newRichMan_main.createTimeDown( self,parentNode,time_count_down,shwoType,isclose )
    local function timeEndFunc()
    	self.m_label_action:setVisible(false)
        parentNode:setVisible(false)
       	local function responseMethod( tag, gameData )
			local data = gameData:getNodeWithKey("data")
	        data = json.decode(data:getFormatBuffer())
	        self.m_tGameData = data
       	end
       	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_index"), http_request_method.GET, params,"monopoly_index")
    end
    parentNode:removeAllChildrenWithCleanup(true)
    local shwoType = shwoType or 3
    local countdownLabel = game_util:createCountdownLabel(time_count_down,timeEndFunc,8, shwoType);
    countdownLabel:setColor(ccc3(74, 249, 69))
    countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    local tempcontent = parentNode:getContentSize()
    countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.6))
    parentNode:addChild(countdownLabel,10,10) 
end

function game_newRichMan_main:refreshBroadCastMsg()
    local msgTab = {}
    local msg = {"Bạn chưa có tin mới",}
    local index = 1
    local oldStr = ""
    local noticeTab = {}
    if self.m_tGameData.notice and next(self.m_tGameData.notice) then
    	noticeTab = self.m_tGameData.notice
    else
    	noticeTab = msg
    end
    for k,v in pairs(noticeTab) do
    	if index % 2 == 1 then
    		oldStr = v
    		if index == game_util:getTableLen(noticeTab) then
    			table.insert(msgTab, oldStr)
    		end
    	else
    		oldStr = oldStr .. "\n" .. v
    		table.insert(msgTab, oldStr)
    	end
        index = index + 1
    end
    if #msgTab > 0 and self.m_node_broadcastboard then
    	--scroll_view_tips,tipsStrTab,loopFlag,openType, fontColor, fontSize
        game_util:createScrollViewTips(self.m_scroll_msgBoard, msgTab)
        self.m_node_broadcastboard:setVisible(true)
    elseif self.m_node_broadcastboard then
        self.m_node_broadcastboard:setVisible(false)
    end
end

function game_newRichMan_main.refreshUi( self )
	local score = game_data:getUserStatusDataByKey("monopoly_score") or 0
	self.m_label_score:setString("Tích điểm:" .. score)
	if self.m_tGameData.boss_open then
		self.m_btn_boss:setVisible(true)
		self.m_rank_btn:setVisible(true)
	else
		self.m_rank_btn:setVisible(true)
		self.m_btn_boss:setVisible(false)
	end

	local curSort = 0
	for k,v in pairs(self.m_tGameData.slots) do
		if v.id == tostring(self.m_tGameData.step) then
			curSort = v.sort
		end
	end
	self:refreshBroadCastMsg()
	if self.m_tGameData.wating_time and curSort == 10 and self.m_tGameData.need_fight then
		self.m_label_action:setString("CD hành động:")
		self.m_label_action:setVisible(true)
		self.m_node_action:setVisible(true)
		self:createTimeDown(self.m_node_action, self.m_tGameData.wating_time)

	else
		self.m_label_action:setVisible(false)
		self.m_node_action:setVisible(false)
	end
	-- cclog2(self.m_tGameData.builing_count%6,"aa  =======")
	
	-- local function callfun(  )
	-- 	local function responseMethod(tag,gameData)
	-- 		game_scene:addPop("game_newRichMan_bigBoss_pop",{gameData = gameData})
	-- 	end
	-- 	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("depth_boss_index"), http_request_method.GET, nil,"depth_boss_index")
	-- end

	
	-- local button = game_util:createCCControlButton("public_weapon.png","",callfun)
	-- button:setAnchorPoint(ccp(0.5,0.5))
	-- button:setPosition(ccp( -50,20 ))
	-- button:setOpacity(255)
	-- self.m_rank_btn:addChild(button)


	if self.bigbossdata then
		game_scene:addPop("game_newRichMan_bigBoss_pop",{gameData = self.bigbossdata})
	end
end

--[[
	计算当前step在数组里面的位置 即人物在屏幕的实际位置和地块
	step 当前的地块号
]]
function game_newRichMan_main.getRealPosIndex( self, step )
	-- cclog2(step,"step ==== ")
	local realPosIndex = tonumber(step)
	if realPosIndex > 6 then
		realPosIndex = realPosIndex % 6
		if realPosIndex == 0 then
			realPosIndex = 6
		end
	end
	return realPosIndex
end

function game_newRichMan_main.init( self, t_params )
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_live.plist")
	self.m_tab_mapData = {};
	self.m_tGameData = {};
	t_params = t_params or {};
	if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
		local data = t_params.gameData:getNodeWithKey("data")
        data = json.decode(data:getFormatBuffer())
        self.m_tGameData = data
	end	
	self.m_currentNum = self.m_tGameData.step 
	self.m_frist_step = self.m_tGameData.step
	self.m_rollPoint = 0
	self.m_animFlag = false
	if t_params.openType == "friends" then
		game_scene:addPop("game_newRichMan_puzzles_pop")
	end
	self.m_monopoly_cfg = json.decode(getConfig(game_config_field.monopoly):getFormatBuffer());
	self:upMapData()

	if t_params.isJump then
		self:toPopScene()
	end
	if t_params.needDonation then
		
	end
	
end
	
	function game_newRichMan_main:createDeepSpiral( parentNode )

	    local function onAnimSectionEnd( animNode, theId,theLabelName )
	        animNode:playSection(theLabelName);
	    end
	    local anim_texiao = game_util:createBlenderAnim("famous_texiao",0, true);
	    anim_texiao:registerScriptTapHandler(onAnimSectionEnd)
	    anim_texiao:playSection("impact");
	    -- anim:playSection("impact@1");
	    anim_texiao:setScale(0.8)
	    anim_texiao:setPosition(ccp(-20,10))
		parentNode:addChild(anim_texiao)
	end
function game_newRichMan_main.create( self, t_params )
	self:init(t_params)
	local scene = CCScene:create()
	scene = self:createUi(t_params)
	self:setStartPos()
	self:refreshUi()
	return scene
end
	
return game_newRichMan_main