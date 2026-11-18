local game_server_guildbattle_battle = {
	m_node = nil,
	tab_ui = nil,
	node_progress = nil,
	node_timeDown = nil,
	m_tGameData = nil,
	label_redGuildName = nil,
	label_blueGuildName = nil,
	m_step = nil, 
	btn_blueBigHome = nil,
	btn_redBigHome = nil,
	m_isManage = nil, --会长标识
	lab_timeDown = nil,
	conut_tab = nil,
	text_scroll = nil,
	content_node = nil,
	node_cdBig = nil,
	node_cd = nil,
	m_openType = nil,
	m_flag = nil,
	m_noPop = nil,
	m_label_midNum = nil,
	m_reward=nil,
	m_anim_node = nil,
	m_anim_node2 = nil,
    m_purple_node ={},
    m_yellow_node ={},
    m_blue_node ={},
    m_enemy_node ={},
    m_own_node = {},
}
function game_server_guildbattle_battle.destroy( self )
	self.m_node = nil;
	self.tab_ui = nil;
	self.node_progress = nil;
	self.node_timeDown = nil;
	self.m_tGameData = nil;
	self.label_redGuildName = nil; 
	self.label_blueGuildName = nil; 
	self.m_step = nil;
	self.btn_blueBigHome = nil;
	self.btn_redBigHome = nil;
	self.m_isManage = nil;
	self.lab_timeDown = nil;
	self.conut_tab = nil;
	self.text_scroll = nil;
	self.content_node = nil;
	self.node_cdBig = nil;
	self.node_cd = nil;
	self.m_openType = nil;
	self.m_flag = nil;
	self.m_noPop = nil;
	self.m_label_midNum = nil;
	self.m_reward=nil;
	self.m_anim_node = nil;
	self.m_anim_node2 = nil;
    self.m_purple_node = {};
    self.m_yellow_node = {};
    self.m_blue_node = {};
    self.m_enemy_node = {};
    self.m_own_node = {};
end
function game_server_guildbattle_battle.back( self )
	local function responseMethod( tag,gameData )
		game_scene:enterGameUi("game_server_guildbattle_toBattle",{gameData = gameData})
	end
	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_new_ui_index"), http_request_method.GET, nil,"new_guild_fight_new_ui_index")
		
end
--[[
	tag：
	101  102   红 蓝 Home
	11 - 15 红 --自己所在的公会
	21 - 25 蓝 --对战的公会
	--中立点
	31 - 35 紫
	41 - 45 金
	51 - 55 蓝

]]
function game_server_guildbattle_battle.createUi( self )
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_gvg_new.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_team_pk.plist")
	local ccbNode = luaCCBNode:create();
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
		local btnTag = tagNode:getTag();
		if btnTag == 1 then
			self:back()
		elseif btnTag == 110 then --战报
			local function responseMethod(tag,gameData)
                if gameData == nil then return end
                game_scene:addPop("game_god_palace_battle_log",{gameData = gameData,logType = "serverGuildBattle"})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_get_battle_log"), http_request_method.GET, nil,"new_guild_fight_get_battle_log",true,true)

		elseif btnTag == 2 then --购买cd
			local new_guild_time = getConfig(game_config_field.new_guild_fight)
			local costData = new_guild_time:getNodeWithKey("3")
			costData = json.decode(costData:getFormatBuffer())
			local costCoin = costData.cost[1][3]
			local function responseMethod( tag, gameData )
				game_util:addMoveTips({text = "Gia tốc thành công~"})
				if gameData and tolua.type(gameData) == "util_json" then
				    local data = gameData:getNodeWithKey("data")
				    data = json.decode(data:getFormatBuffer())
				    self.m_tGameData = data
				    self:refreshUi()
				end
			end
			local t_params = 
			{
			    title = string_config.m_title_prompt,
			    okBtnCallBack = function(target,event)
			    	game_util:closeAlertView();
					network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_clear_cd"), http_request_method.GET, params,"new_guild_fight_clear_cd")
			    end,   --可缺省
			    okBtnText = string_config.m_btn_sure,       --可缺省
			    cancelBtnText = string_config.m_btn_cancel,
			    text = "Tốn" .. costCoin .. "Xu để gia tốc?",      --可缺省
			    onlyOneBtn = false,
			    touchPriority = GLOBAL_TOUCH_PRIORITY-2,
			}
			game_util:openAlertView(t_params)
		elseif btnTag == 3 then --刷新
			local params = {}
			local function responseMethod( tag,gameData )
				if gameData and tolua.type(gameData) == "util_json" then
				    local data = gameData:getNodeWithKey("data")
				    data = json.decode(data:getFormatBuffer())
				    local flag = 1 --刷新的类型 看是在上一阶段 还是新的阶段
				    if self.m_tGameData.prepare_stat then
				    	flag = 1 -- 准备 不弹结果
				    else
				    	flag = 2  --战斗 可以弹结果
				    end
				    self.m_tGameData = data
				    game_scene:enterGameUi("game_server_guildbattle_battle",{gameData = gameData, isManage = self.m_isManage,flag = flag})
				end
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_battlefield_overview"), http_request_method.GET, params,"new_guild_fight_battlefield_overview")
		elseif btnTag == 4 then --阵型
			local function responseMethod(tag,gameData)
			    if gameData then
			        game_scene:enterGameUi("game_god_adjustment",{gameData = gameData,openType="serverGuildBattle",team_index = 1});
			    end
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_upload_god_formation"), http_request_method.GET, nil,"god_field_upload_god_formation",true,true)
		elseif btnTag == 5 then
			local activeCfg = getConfig(game_config_field.notice_active)
			local itemCfg = activeCfg:getNodeWithKey("181")
		    local contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or "Hoạt động đặc sắc, mau tham gia nào!"
			 game_scene:addPop("game_godfield_detail_pop",{openMsg = contentText})

		elseif btnTag == 7 then --个人buff
			local function responseMethod( tag, gameData )
				game_scene:addPop("game_serverGuild_morale_pop", {gameData = gameData})
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_see_user_buff"), http_request_method.GET, nil,"new_guild_fight_see_user_buff",true,true)
		elseif (btnTag > 20 and btnTag < 23) or btnTag == 102 then --查看自己
				local canGo = false
				if self.m_step == 2  or self.m_tGameData.prepare_stat then
					canGo = true
				end
				local params = {}
				local building_id = 0
				local myPointData,enemyPointData,midPointData,bigHomeData = self:getPointData()

				if btnTag < 102 then
					building_id = myPointData[tostring(btnTag -19)] 
					params.building_id = building_id
				else
					params.building_id = bigHomeData[1]
					building_id = bigHomeData[1]
				end
				local num = 0
				local owner = self.m_tGameData["owner_guild_info"]["building_info"][building_id]["owner"]
				num = game_util:getTableLen(owner)
				local sort = self.m_tGameData["owner_guild_info"]["building_info"][building_id]["sort"]
				local cid = self.m_tGameData["owner_guild_info"]["building_info"][building_id]["c_id"]
				local isOnly = true
					params.only_one = 0
					isOnly = false
					local function responseMethod( tag,gameData )
						game_scene:addPop("game_server_guildbattle_point_pop",{gameData = gameData, building_id = building_id, isOnly = isOnly, isManage = self.m_isManage, c_id = cid, step = canGo,}) 
					end
					network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_building_info"), http_request_method.GET, params,"new_guild_fight_building_info")
		elseif (btnTag > 10 and btnTag < 13)  or btnTag == 101 then --查看敌人阵容 
			if self.m_step == 2  or self.m_tGameData.prepare_stat then --准备阶段 
				game_util:addMoveTips({text = "Giai đoạn chuẩn bị, không thể xem thông tin kẻ địch"})
			else
				local params = {}
				local building_id = 0
				local myPointData,enemyPointData,midPointData,bigHomeData = self:getPointData()

				if btnTag < 101 then
					params.building_id = enemyPointData[tostring(btnTag -9)] 
					building_id = enemyPointData[tostring(btnTag -9)] 
				else
					params.building_id = bigHomeData[2]
					building_id = bigHomeData[2]
				end
				local function responseMethod( tag,gameData )
					game_scene:addPop("game_server_guildbattle_enemyInfo_pop",{gameData = gameData, building_id = building_id}) 
				end
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_building_info"), http_request_method.GET, params,"new_guild_fight_building_info")
			end
		elseif btnTag >30 and btnTag < 61 then --中立地图
			if self.m_step == 2 or  self.m_tGameData.prepare_stat then --准备阶段  
				game_util:addMoveTips({text = "Giai đoạn chuẩn bị, không thể xem thông tin kẻ địch"})
			else
				cclog2(btnTag,"btnTag ======")
				local index = 0
				-- if btnTag < 41 then
				-- 	index = btnTag -30 +6
				-- elseif btnTag < 61 then
				-- 	index = btnTag -40 +11
				-- else
				-- 	index = btnTag -50 +16
				-- end
				if btnTag < 46 and btnTag > 40 then
					index = btnTag - 37
				elseif btnTag > 30 and btnTag < 41 then

					index = btnTag - 22
				elseif btnTag > 50 and btnTag < 61 then

					index = btnTag - 32
				end

				local params = {}
				local building_id = 0
				local myPointData,enemyPointData,midPointData,bigHomeData = self:getPointData()
				params.building_id = midPointData[tostring(index)] 
				building_id = midPointData[tostring(index)] 
				-- local buildOwnerGuildId = self.m_tGameData["public_building_info"][building_id].owner_guild_id
				-- local isEminyFlag = false
				-- if buildOwnerGuildId ~= self.m_tGameData.defend_guild then --自己公会占领的中立地块
					
				-- else
				-- 	isEminyFlag = true
				-- end
				local function responseMethod( tag,gameData )
					game_scene:addPop("game_server_guildbattle_enemyInfo_pop",{gameData = gameData, building_id = building_id}) 
				end
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_building_info"), http_request_method.GET, params,"new_guild_fight_building_info")
			end
		elseif btnTag == 303 then --鼓舞
			local new_guild_time = getConfig(game_config_field.new_guild_fight)
			local costData = new_guild_time:getNodeWithKey("5")
			costData = json.decode(costData:getFormatBuffer())
			local costCoin = costData.cost[1][3]
			local t_params = 
			{
			    title = string_config.m_title_prompt,
			    okBtnCallBack = function(target,event)
			    	game_util:closeAlertView();

			    	local function responseMethod( tag,gameData )
			    		if gameData and tolua.type(gameData) == "util_json" then
			    		    local data = gameData:getNodeWithKey("data")
			    		    data = json.decode(data:getFormatBuffer())
			    		    local flag = 1 --刷新的类型 看是在上一阶段 还是新的阶段
			    		    if self.m_tGameData.prepare_stat then
			    		    	flag = 1 -- 准备 不弹结果
			    		    else
			    		    	flag = 2  --战斗 可以弹结果
			    		    end
			    		    self.m_tGameData = data
			    		    game_scene:enterGameUi("game_server_guildbattle_battle",{gameData = gameData, isManage = self.m_isManage,flag = flag})
			    		end
			    	end
			    	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_buy_user_hot"), http_request_method.GET, params,"new_guild_fight_buy_user_hot")
			    	
			    end,   --可缺省
			    okBtnText = string_config.m_btn_sure,       --可缺省
			    cancelBtnText = string_config.m_btn_cancel,
			    text = "Tốn " .. costCoin .. " Xu để cổ vũ?",      --可缺省
			    onlyOneBtn = false,
			    touchPriority = GLOBAL_TOUCH_PRIORITY-2,
			}
			game_util:openAlertView(t_params)

		elseif btnTag == 9999 then --被摧毁
			game_util:addMoveTips({text = "Cứ điểm đã bị hủy"})
		end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
	ccbNode:openCCBFile("ccb/ui_serverGuild_battle.ccbi");
	local label_des = ccbNode:labelTTFForName("label_des")
	label_des:setString("Mua điểm thuộc tính tăng LC cá nhân")
	self.node_progress = ccbNode:nodeForName("node_progress")
	self.btn_blueBigHome = ccbNode:controlButtonForName("btn_blueBigHome")
	self.btn_redBigHome = ccbNode:controlButtonForName("btn_redBigHome")
	self.btn_blueBigHome:setOpacity(0)
	self.btn_redBigHome:setOpacity(0)
	local btn_jiasu = ccbNode:controlButtonForName("btn_jiasu")
	btn_jiasu:setOpacity(0)
	self.label_redGuildName = ccbNode:labelTTFForName("label_redGuildName")
	self.label_blueGuildName = ccbNode:labelTTFForName("label_blueGuildName")
	self.lab_timeDown = ccbNode:labelTTFForName("lab_timeDown")
	self.text_scroll = ccbNode:scrollViewForName("m_scroll_view_Secret");
	self.content_node = ccbNode:nodeForName("content_node")
	local myGuildName = self.m_tGameData.owner_guild_info.guild_name or ""
	local enemyGuildName = self.m_tGameData.enemy_guild_info.guild_name or ""
	self.label_redGuildName:setString(enemyGuildName)
	self.label_blueGuildName:setString(myGuildName)
	self.node_timeDown = ccbNode:nodeForName("node_timeDown")
	self.node_cdBig = ccbNode:nodeForName("node_cdBig")
	self.node_cd = ccbNode:nodeForName("node_cd")
	self.m_label_midNum = ccbNode:labelTTFForName("m_label_midNum")
	self.m_star_node = ccbNode:nodeForName("m_star_node")

	self.tab_ui = {}
	local btn_redPoint,btn_bluePoint,btn_purpleBtn,btn_goldBtn,btn_qingBtn = nil,nil,nil,nil,nil;
	self.m_anim_node = ccbNode:nodeForName("m_anim_node")
	self.m_anim_node2 = ccbNode:nodeForName("m_anim_node2")
	self:createAnim()
	for i=1,10 do
		
		if i < 3 then 
			btn_redPoint = ccbNode:controlButtonForName("btn_redPoint" .. i)
			btn_redPoint:setTouchPriority(-2)
			btn_redPoint:setOpacity(0)
			btn_bluePoint = ccbNode:controlButtonForName("btn_bluePoint" .. i)
			btn_bluePoint:setOpacity(0)
			self.m_enemy_node[i] = ccbNode:nodeForName("m_enemy_node_"..i)
			
        	self:createEnemyAnim(btn_redPoint,1)
        	self.m_own_node[i] = ccbNode:nodeForName("m_own_node"..i)
        	self:createOwnAnim(btn_bluePoint,1)
			
		end
		if i < 6 then
			btn_goldBtn = ccbNode:controlButtonForName("btn_goldBtn" .. i)
			btn_goldBtn:setOpacity(0)
			self.m_yellow_node[i] = ccbNode:nodeForName("m_yellow_node"..i)
        	self:createAnimByFileName(self.m_yellow_node[i],1,"serverGuild_gold")
		end
		btn_purpleBtn = ccbNode:controlButtonForName("btn_purpleBtn" .. i)
		btn_purpleBtn:setOpacity(0)
		btn_qingBtn = ccbNode:controlButtonForName("btn_qingBtn" .. i)
		btn_qingBtn:setOpacity(0)
		self.tab_ui[i] = {btn_redPoint = btn_redPoint, btn_bluePoint = btn_bluePoint, btn_purpleBtn = btn_purpleBtn, btn_goldBtn = btn_goldBtn, btn_qingBtn = btn_qingBtn, }
		self.m_purple_node[i] = ccbNode:nodeForName("m_purple_node"..i)
        self:createAnimByFileName(self.m_purple_node[i],1,"serverGuild_purple")
        self.m_blue_node[i] = ccbNode:nodeForName("m_blue_node"..i)
        self:createAnimByFileName(self.m_blue_node[i],1,"serverGuild_blue")
	end
	self:createAnim2(1)
	self:createAnim3(1)

	
	-- for i=1,2 do
	-- 	print(i)
	-- end
	self.m_node = ccbNode
	return ccbNode;
end
function game_server_guildbattle_battle.createStarAnim(self)
	self.m_star_node:removeAllChildrenWithCleanup(true)
	local anim_eff1 = game_util:createEffectAnim("serverGuild_huoxing",1,true);
    anim_eff1:setAnchorPoint(ccp(0.5,0.5))
    anim_eff1:setPositionX(-15)
   
    -- anim_eff:registerScriptTapHandler(onAnimSectionEnd)
    anim_eff1:playSection("impact1");
    self.m_star_node:addChild(anim_eff1,1,1)
    -- self.m_star_node:setScale(1.2)
    -- local anim_eff2 = game_util:createEffectAnim("serverGuild_bg",1,true);
    -- anim_eff2:setAnchorPoint(ccp(0.5,0))
    -- anim_eff2:setPositionY(-160)
    -- -- anim_eff1:setPositionX(-20)
    -- -- anim_eff:registerScriptTapHandler(onAnimSectionEnd)
    -- anim_eff2:playSection("impact@1");
    -- self.m_anim_node:addChild(anim_eff2,2,2)
-- end             
end
function game_server_guildbattle_battle.createAnim(self)
	self.m_anim_node:removeAllChildrenWithCleanup(true)
		local anim_eff1 = game_util:createEffectAnim("serverGuild_bg",1,true);
    anim_eff1:setAnchorPoint(ccp(0.5,0.5))
    -- anim_eff1:setPositionY(-160)
    -- anim_eff1:setPositionX(-20)
    -- anim_eff:registerScriptTapHandler(onAnimSectionEnd)
    anim_eff1:playSection("impact1");
    self.m_anim_node:addChild(anim_eff1,1,1)
    local anim_eff2 = game_util:createEffectAnim("serverGuild_bg",1,true);
    anim_eff2:setAnchorPoint(ccp(0.5,0.5))
    -- anim_eff2:setPositionY(-160)
    -- anim_eff1:setPositionX(-20)
    -- anim_eff:registerScriptTapHandler(onAnimSectionEnd)
    anim_eff2:playSection("impact@1");
    self.m_anim_node:addChild(anim_eff2,2,2)
-- end             
end
function game_server_guildbattle_battle.createAnim2(self,m_Type)
    			-- self.m_anim_node2:removeAllChildrenWithCleanup(true)
                 local anim_eff3 = game_util:createEffectAnim("serverGuild_enemyHome",1,true);
                anim_eff3:setAnchorPoint(ccp(0.5,0))
                anim_eff3:setPositionY(-10)
                anim_eff3:setPositionX(-200)
                local anim_eff4 = game_util:createEffectAnim("serverGuild_enemyHome",1,true);
                anim_eff4:setAnchorPoint(ccp(0.5,0))
                anim_eff4:setPositionY(-10)
                anim_eff4:setPositionX(-200)
                -- anim_eff:registerScriptTapHandler(onAnimSectionEnd)
               if m_Type == 1 then 
                	anim_eff3:playSection("impact1");
                	anim_eff4:playSection("impact@1");
                else
                	anim_eff3:playSection("impact3");
                	anim_eff4:playSection("impact@3");
                end
                self.m_anim_node2:addChild(anim_eff3,1,1)                
                self.m_anim_node2:addChild(anim_eff4,1,1)                
end
function game_server_guildbattle_battle.createAnim3(self,m_Type)
	-- self.m_anim_node2:removeAllChildrenWithCleanup(true)
    local anim_eff2 = game_util:createEffectAnim("serverGuild_ownHome",1,true);
    anim_eff2:setAnchorPoint(ccp(0.5,0))
    anim_eff2:setPositionY(-180)
    anim_eff2:setPositionX(200)
    local anim_eff3 = game_util:createEffectAnim("serverGuild_ownHome",1,true);
    anim_eff3:setAnchorPoint(ccp(0.5,0))
    anim_eff3:setPositionY(-180)
    anim_eff3:setPositionX(200)
    -- anim_eff:registerScriptTapHandler(onAnimSectionEnd)
  if m_Type == 1 then 
    	anim_eff2:playSection("impact1");
    	anim_eff3:playSection("impact@1");
    else
    	anim_eff2:playSection("impact3");
    	anim_eff3:playSection("impact@3");
    end
    self.m_anim_node2:addChild(anim_eff2,1,1)                
    self.m_anim_node2:addChild(anim_eff3,1,1)   
         
end


function game_server_guildbattle_battle:createAnimByFileName(node,m_Type,filename)
	node:removeAllChildrenWithCleanup(true)
    local anim_eff1 = game_util:createBlenderAnim(filename,1,true)
    local anim_eff2 = game_util:createBlenderAnim(filename,1,true)
    anim_eff1:setAnchorPoint(ccp(0.5,0.5))
    anim_eff2:setAnchorPoint(ccp(0.5,0.5))
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        animNode:playSection(theLabelName)
    end
    anim_eff1:registerScriptTapHandler(onAnimSectionEnd)
    anim_eff2:registerScriptTapHandler(onAnimSectionEnd)
    if m_Type == 1 then 
    	anim_eff1:playSection("impact");
    	anim_eff2:playSection("impact@1");
    elseif m_Type == 2 then 
    	anim_eff1:playSection("impact3");
    	anim_eff1:setPosition(ccp(28,18))
    	anim_eff2:playSection("impact3@1");
    	anim_eff2:setPosition(ccp(28,18))
    elseif m_Type ==3 then
    	anim_eff1:playSection("impact2");
    	anim_eff1:setPosition(ccp(28,18))
    	anim_eff2:playSection("impact2@1");
    	anim_eff2:setPosition(ccp(28,18))
    end
    node:addChild(anim_eff1,1,1)
    -- node:addChild(anim_eff2,2,2)
end





function game_server_guildbattle_battle.createEnemyAnim(self,node  ,m_Type)
    local anim_eff1 = game_util:createEffectAnim("serverGuild_ownPoint",1,true);
    anim_eff1:setAnchorPoint(ccp(0.5,0.5))
    -- anim_eff1:setPositionY(-160)
    -- anim_eff:registerScriptTapHandler(onAnimSectionEnd)
    cclog2(m_Type,"   ame_server_guildbattle_battle.createEnemyAnim    ")
   	anim_eff1:setPosition(ccp(28,18))

    if m_Type == 1 then 
    	anim_eff1:playSection("impact");
    else
    	anim_eff1:setPosition(ccp(28,18))
    	anim_eff1:playSection("impact3");
    end
    node:removeAllChildrenWithCleanup(true)
    node:addChild(anim_eff1,1,1)
end
function game_server_guildbattle_battle.createOwnAnim(self,node ,m_Type )
    local anim_eff1 = game_util:createEffectAnim("serverGuild_enemyPoint",1,true);
    anim_eff1:setAnchorPoint(ccp(0.5,0.5))
    -- anim_eff1:setPositionY(-160)
    -- anim_eff:registerScriptTapHandler(onAnimSectionEnd)
    node:removeAllChildrenWithCleanup(true)
    anim_eff1:setPosition(ccp(28,18))
   if m_Type == 1 then 
    	anim_eff1:playSection("impact");
    else
    	anim_eff1:setPosition(ccp(28,18))
    	anim_eff1:playSection("impact3");
    end
    node:addChild(anim_eff1,1,1)
end
function game_server_guildbattle_battle.createTimeDown( self,parentNode,time_count_down,shwoType,isclose )
    local function timeEndFunc()
    	if isclose == 1 then
    		local function delyFunc2(  )
    			parentNode:setVisible(false)
    			local params = {}
				local function responseMethod(tag,gameData,contentLength,status,new_config_version)
					if gameData and tolua.type(gameData) == "util_json" then
						local flag = 1
						local data = gameData:getNodeWithKey("data")
						if self.m_tGameData.active_step and self.m_tGameData.active_step == 3 then
							if data:getNodeWithKey("prepare_stat"):toBool() then
								flag = 1
							else
								flag = 2

							end
						else
							flag = 2
						end
						game_scene:enterGameUi("game_server_guildbattle_battle",{gameData = gameData,flag = flag})
					end
				end
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_battlefield_overview"), http_request_method.GET, params,"new_guild_fight_battlefield_overview",true,true)
    		end
    		local tempNode = luaCCBNode:create()
    		parentNode:addChild(tempNode)
    		local arr = CCArray:create();
    		arr:addObject(CCDelayTime:create(1))
    		arr:addObject(CCCallFunc:create(delyFunc2))
    		tempNode:runAction(CCSequence:create(arr))
        elseif isclose == 2 then
        	parentNode:getParent():setVisible(false)
        end
    end
    parentNode:removeAllChildrenWithCleanup(true)
    local shwoType = shwoType or 2
    local countdownLabel = game_util:createCountdownLabel(time_count_down,timeEndFunc,8, shwoType);
    countdownLabel:setColor(ccc3(74, 249, 69))
    countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    local tempcontent = parentNode:getContentSize()
    countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.6))
    parentNode:addChild(countdownLabel,10,10) 
    -- body
end
--[[
	存储自己一方的数据
	存储中立点的数据
	存储地方的数据
]]
function game_server_guildbattle_battle.getPointData( self )
	local myPointData = {}
	local midPointData = {}
	local enemyPointData = {}
	local bigHomeData = {}
	local owner_guild_info = self.m_tGameData.owner_guild_info.building_info
	local enemy_guild_info = self.m_tGameData.enemy_guild_info.building_info
	local public_building_info = self.m_tGameData.public_building_info

	if owner_guild_info and next(owner_guild_info) then	
		for k,v in pairs(owner_guild_info) do
			if v.sort == 3 then --大本营
				table.insert(bigHomeData,k)
			elseif v.sort == 2 then --中立区域
				myPointData[tostring(v.c_id)] = k
			else
			end
		end
	end

	if enemy_guild_info and next(enemy_guild_info) then
		for k,v in pairs(enemy_guild_info) do
			if v.sort == 3 then --大本营
				table.insert(bigHomeData,k)
			elseif v.sort == 2  then --中立区域
				enemyPointData[tostring(v.c_id)] = k
			else
			end
		end
	end

	if public_building_info and next(public_building_info) then
		for k,v in pairs(public_building_info) do
			midPointData[tostring(v.c_id)] = k
		end
	end
	return myPointData,enemyPointData,midPointData,bigHomeData

	-- body   self.tempNodeTab[i]:getParent():reorderChild(self.tempNodeTab[i], 5-i)
end
function game_server_guildbattle_battle.createNumLabel( self )
	local myPointData,enemyPointData,midPointData,bigHomeData = self:getPointData()
	local parentNode = nil;
	local x = 111
	local function createlabel( i, buttonName, infoData, dataTab, destroyName, createName, nameIndex )
		local posID = dataTab[tostring(i)]
		-- cclog2(posID,"posID-=--------------123")
		-- cclog2(infoData,"infoData-=--------")
		if posID then
		else
			posID = dataTab[i]
		end
		if posID then
			local owner = infoData[posID].owner
			local sort =  infoData[posID].sort
			local countNum = self.conut_tab[tostring(sort)]
			local num = game_util:getTableLen(owner)
			-- cclog2(owner,"owner--=")
			if buttonName == "btn_redBigHome" then
				parentNode = self.btn_redBigHome
			elseif buttonName == "btn_blueBigHome" then
				parentNode = self.btn_blueBigHome
			elseif nameIndex then
				parentNode = self.tab_ui[nameIndex][buttonName]
			else
				parentNode = self.tab_ui[i-1][buttonName]
			end

			local name = ""
			if infoData[posID].owner_name then
				name = infoData[posID].owner_name
			end
			local color = ccc3(100,200,80)
			local  flag = 1 
			if infoData[posID].owner_guild_id == self.m_tGameData.defend_guild then
				color = ccc3(255,155,50)
				flag = 3
			else
				ccc3(100,200,80)
				flag = 2 
			end
			local  destroyflag = 0 
			if destroyName and infoData[posID].destory then
				-- game_util:setCCControlButtonBackground(parentNode,destroyName)
				parentNode:setTag(9999)
				destroyflag = 1 
			 	color = ccc3(220,80,70)
			end
			
			local numLabel = nil
			if createName then
				numLabel = game_util:createLabelTTF({text = name,color = color,fontSize = 9});
				numLabel:setPosition(17,3)
				if name ~= "" then
					if buttonName =="btn_goldBtn" then 
						self:createAnimByFileName(parentNode,flag,"serverGuild_gold")
					elseif buttonName =="btn_purpleBtn" then 
						self:createAnimByFileName(parentNode,flag,"serverGuild_purple")
					elseif buttonName =="btn_qingBtn" then 
						self:createAnimByFileName(parentNode,flag,"serverGuild_blue")
					end
					-- parentNode:setPosition(ccp(21,30))

					--播放  摧毁动画
				elseif self.m_step == 2 or self.m_tGameData.prepare_stat then --准备阶段 
					local animArr2 = CCArray:create();
					animArr2:addObject(CCTintTo:create(1,175,175,175))
					animArr2:addObject(CCTintTo:create(1,255,255,255))
					parentNode:runAction(CCRepeatForever:create(CCSequence:create(animArr2)))
				else
					-- local spriteFight = CCSprite:createWithSpriteFrameName("teampk_fight.png")
					-- spriteFight:setScale(0.5)
					-- spriteFight:setPosition(ccp(21,30))
					-- parentNode:addChild(spriteFight)
					-- local animArr2 = CCArray:create();
					-- animArr2:addObject(CCTintTo:create(1,175,175,175))
					-- animArr2:addObject(CCTintTo:create(1,255,255,255))
					-- spriteFight:runAction(CCRepeatForever:create(CCSequence:create(animArr2)))
					-- parentNode:runAction(CCRepeatForever:create(CCSequence:create(animArr2)))
				end
			else
				numLabel = game_util:createLabelTTF({text = num .. "/" .. countNum,color = color,fontSize = 9});
				numLabel:setPosition(30,0)

				if owner ~= nil and buttonName =="btn_redBigHome" and  destroyflag == 1 then 
					self:createAnim2(2)
				elseif owner ~= nil and buttonName =="btn_blueBigHome" and  destroyflag == 1 then 
					self:createAnim3(2)
				elseif owner ~= nil and buttonName =="btn_redPoint"  and  destroyflag == 1 then 
					self:createEnemyAnim(parentNode,2)
				elseif owner ~= nil and buttonName =="btn_bluePoint"  and  destroyflag == 1 then 
					self:createOwnAnim(parentNode,2)
				end


			end

			if buttonName == "btn_redBigHome" then
				numLabel:setPosition(50,10)
				numLabel:setScale(1.5)

			elseif buttonName == "btn_blueBigHome" then
				numLabel:setPosition(90,80)
				numLabel:setScale(1.5)

			end
			parentNode:addChild(numLabel,10,10)
			numLabel:getParent():getParent():reorderChild(numLabel, x)
			x = x -1
		end
	end
						-- cclog2(buttonName,"buttonName-=-123---")

	for i=2,4 do
		local buttonName = "btn_redPoint"
		local infoData1 = self.m_tGameData["owner_guild_info"].building_info
		local infoData2 =self.m_tGameData["enemy_guild_info"].building_info

		local destroyName = nil
		destroyName = "serverGuild_ownPoint2.png"

		createlabel(i, buttonName, infoData2, enemyPointData, destroyName)

		local buttonName = "btn_bluePoint"
		local destroyName = nil
		destroyName = "serverGuild_enemyPoint2.png"

		createlabel(i, buttonName, infoData1, myPointData, destroyName)
	end

	local indexNum = 4 --记录索引
	local pubilcBtnName = { "btn_goldBtn", "btn_purpleBtn", "btn_qingBtn" }
	for i=1,3 do --紫蓝金
		local xunhuan = 10
		if i == 1 then
			xunhuan = 5
		end
		for j=1,xunhuan do
			local buttonName = pubilcBtnName[i]
			local dataType = "public_building_info"
			local infoData = self.m_tGameData["public_building_info"]
			createlabel(indexNum, buttonName, infoData, midPointData,nil,true,j)
			indexNum = indexNum + 1
		end
	end

	local buttonName = "btn_redBigHome"
	local infoData1 = self.m_tGameData["enemy_guild_info"].building_info
	local destroyName = nil
	destroyName = "serverGuild_enemyHome2.png"
	createlabel(2, buttonName, infoData1, bigHomeData, destroyName)

	local buttonName = "btn_blueBigHome"
	local infoData1 = self.m_tGameData["owner_guild_info"].building_info
	local destroyName = nil
	destroyName = "serverGuild_ownHome2.png"
	createlabel(1, buttonName, infoData1, bigHomeData, destroyName)


end
function game_server_guildbattle_battle.createLogs( self )
    self.text_scroll:getContainer():removeAllChildrenWithCleanup(true);
    local viewSize = self.content_node:getContentSize()
    local contentText = ""
    local openMsg1 = self.m_tGameData.logs or {}
    -- cclog2(self.m_tGameData.logs,"logs === ")
    -- local fight_times = self.dispatch_item_cfg[tostring(self.m_select_index)].fight_times
    local openMsg = "aaaaabbbb"
    local openMsg_tab = {}
    local length = #openMsg1
    for k,v in pairs(openMsg1) do
        openMsg = openMsg .. v .. "\n"
    end

    contentText = openMsg
    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(124,0),textAlignment = kCCTextAlignmentLeft, verticalTextAlignment = kCCVerticalTextAlignmentCenter,fontSize = 9})
    local tempSize = tempLabel:getContentSize()
    self.text_scroll:setContentSize(CCSizeMake(124,tempSize.height))
    self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.text_scroll:setDirection(kCCScrollViewDirectionVertical)
    self.text_scroll:addChild(tempLabel)
end

function game_server_guildbattle_battle.createProgress( self )
    local bar =  ExtProgressTime:createWithFrameName("gvg_def_hp.png","gvg_att_hp.png");
    local max = self.m_tGameData.owner_guild_info.score + self.m_tGameData.enemy_guild_info.score
    bar:setMaxValue(max)
    bar:setCurValue(self.m_tGameData.enemy_guild_info.score,false);
	local itemsize = self.node_progress:getContentSize()
	local wide = itemsize.width
    self:createStarAnim()
    self.m_star_node:setPositionX((self.m_tGameData.enemy_guild_info.score/max)*wide)
    -- self.m_star_node:setPositionY(itemsize.height*0.5)

    bar:setAnchorPoint(ccp(0,0))
    bar:setPosition(ccp(0,0))
    local aa = game_util:createLabelTTF({text = self.m_tGameData.enemy_guild_info.score .. ":" .. self.m_tGameData.owner_guild_info.score,color = ccc3(250,250,250),fontSize = 9});
    self.node_progress:addChild(aa,11,11)
    aa:setPositionX(wide*0.5)
    aa:setPositionY(itemsize.height*0.5)
    -- aa.setPositionY(itemsize.height*0.8)
    self.node_progress:addChild(bar)
end
function game_server_guildbattle_battle.getConutTab( self )
	local new_guild_point = getConfig(game_config_field.new_guild_point)
	new_guild_point = json.decode(new_guild_point:getFormatBuffer())
	self.conut_tab = {}

	for k,v in pairs(new_guild_point) do
		if self.conut_tab[tostring(v.sort)] then
		else
			self.conut_tab[tostring(v.sort)] = v.card_num
		end
	end
end
function game_server_guildbattle_battle.refreshUi( self,flag )
	self:createProgress()
	self:createNumLabel()
	local enemyMidNum,ownMidNum = 0,0
	local public_building_info = self.m_tGameData.public_building_info
	if public_building_info and next(public_building_info) then
		for k,v in pairs(public_building_info) do
			if v.owner and next(v.owner)  then
				if v.owner_guild_id == self.m_tGameData.defend_guild then
					enemyMidNum = enemyMidNum + 1
				else
					ownMidNum = ownMidNum + 1
				end
			end
		end
	end
	self.m_label_midNum:setString(enemyMidNum .. ":" .. ownMidNum)
	local time_count_down = self.m_tGameData.expire
	if self.m_tGameData.step == 100 then
	else
		self:createTimeDown(self.node_timeDown,time_count_down,nil,1)
	end

	if self.m_step == 2 or self.m_tGameData.prepare_stat then
		self.lab_timeDown:setString("CD bố phòng")
	else
		self.lab_timeDown:setString("CD chiến đấu")
	end
	if self.m_tGameData.cd_expire and self.m_tGameData.cd_expire > 0 then
		self.node_cdBig:setVisible(true)
		self:createTimeDown(self.node_cd,self.m_tGameData.cd_expire,nil,2)
	else
		self.node_cdBig:setVisible(false)
	end
	self:createLogs()
	local strLog = {"Chúc mừng liên minh của bạn đã thắng trận đấu cuối cùng của hôm nay", "Rất tiếc, liên minh của bạn đã thua trong trận đấu cuối cùng của hôm nay", "Chúc mừng liên minh của bạn đã thắng Thần Vực Tranh Bá giai đoạn này, hãy chuẩn bị trận hình phòng thủ tham gia giai đoạn kế tiếp","Rất tiếc liên minh của bạn đã thua Thần Vực Tranh Bá lần này, hãy tiếp tục nâng cao lực chiến, hy vọng lần sau bạn sẽ giành chiến thắng!",}
	local strAfterLog = {"Chúc mừng liên minh của bạn đã giành quán quân!", "Rất tiếc, liên minh của bạn đã thua trong trận chung kết!", "Chúc mừng liên minh của bạn đã thắng Thần Vực Tranh Bá trận này, hãy chuẩn bị trận hình phòng thủ tham gia giai đoạn kế tiếp", "Rất tiếc liên minh của bạn đã thua Thần Vực Tranh Bá trận này. ",}
	-- cclog2(self.m_tGameData,"start data --- -z------")
	local useLog = {}
	if self.m_tGameData.active_step and self.m_tGameData.active_step == 3 then
		useLog = strAfterLog
	else
		useLog = strLog
	end
	if self.m_tGameData.step_result  then
		if self.m_tGameData.step == 100 then
			if self.m_tGameData.step_result.last_step_result == "win"   then
				-- game_data:setGuildeResultFlag(true);
				game_scene:addPop("game_team_pk_result_pop",{is_win = 1,str = useLog[1], backType = "serverGuild3"})
			elseif self.m_tGameData.step_result.last_step_result == "lost"  then
				-- game_data:setGuildeResultFlag(true);
				game_scene:addPop("game_team_pk_result_pop",{is_win = 2,str = useLog[2], backType = "serverGuild3"})
			end
		elseif self.m_tGameData.step == 101 then
			if self.m_tGameData.step_result.last_step_result == "win"  then
				-- game_data:setGuildeResultFlag(true);
				game_scene:addPop("game_team_pk_result_pop",{is_win = 1,str = "Chúc mừng liên minh của bạn đã thắng trận chiến này", backType = "serverGuild3"})
			elseif self.m_tGameData.step_result.last_step_result == "lost"  then
				-- game_data:setGuildeResultFlag(true);
				game_scene:addPop("game_team_pk_result_pop",{is_win = 2,str = "Rất tiếc, liên minh của bạn đã thua trong trận chiến này, ngày mai nỗ lực tiếp nhé!", backType = "serverGuild3"})
			end
		elseif self.m_tGameData.prepare_stat and self.m_flag == 2 then
			if self.m_tGameData.step_result.last_step_result == "win"   then
				-- game_data:setGuildeResultFlag(true);
				game_scene:addPop("game_team_pk_result_pop",{is_win = 1,str = "Chúc mừng liên minh của bạn đã thắng trận chiến này, hãy chuẩn bị cho trận kế tiếp", backType = "serverGuild3"})
			elseif self.m_tGameData.step_result.last_step_result == "lost"  then
				-- game_data:setGuildeResultFlag(true);
				game_scene:addPop("game_team_pk_result_pop",{is_win = 2,str = "Chúc mừng liên minh của bạn đã thắng trận chiến này, hãy chuẩn bị cho trận kế tiếp", backType = "serverGuild3"})
			end
		else
			if self.m_tGameData.step_result.cur_step_result == "win"   then
				-- game_data:setGuildeResultFlag(true);
				game_scene:addPop("game_team_pk_result_pop",{is_win = 1,str = useLog[3], backType = "serverGuild3"})
			elseif self.m_tGameData.step_result.cur_step_result == "lost"  then
				-- game_data:setGuildeResultFlag(true);
				game_scene:addPop("game_team_pk_result_pop",{is_win = 2,str = useLog[4], backType = "serverGuild3"})
			end
		end
	end

	-- if self.m_tGameData.step_result  then
	-- 	local flag=game_data:getGuildeResultFlag() or false;
	-- 	if (self.m_tGameData.step > 3 and self.m_tGameData.prepare_stat) or self.m_tGameData.step > 99 then -- 进入到下一轮的准备阶段 看上一轮胜负
	-- 		if self.m_flag and self.m_flag == 1 then
	-- 			self.m_flag = nil
	-- 			return
	-- 		end
	-- 		if self.m_tGameData.step_result.last_step_result == "win" and (not flag) then
	-- 			if self.m_openType and self.m_openType == "index" then
	-- 			else
	-- 				game_data:setGuildeResultFlag(true);
	-- 				game_scene:addPop("game_team_pk_result_pop",{is_win = 1,str = "恭喜您的所在的联盟获得了本阶段神域争霸活动的胜利，请您重新准备，调整防守阵容参与下一阶段的战斗"})
	-- 			end
	-- 		elseif self.m_tGameData.step_result.last_step_result == "lost" and (not flag) then
	-- 			game_data:setGuildeResultFlag(true);
	-- 			game_scene:addPop("game_team_pk_result_pop",{is_win = 2,str = "由于您的联盟很遗憾的在了本次神域争霸活动中失败，请您在接下来继续提高自己战斗力，希望您的联盟下次活动中可以战胜对手"})
	-- 		end
	-- 	else
	-- 		if self.m_tGameData.step_result.cur_step_result == "win" and (not flag) then
	-- 			game_data:setGuildeResultFlag(true);
	-- 			game_scene:addPop("game_team_pk_result_pop",{is_win = 1,str = "恭喜您的所在的联盟获得了本阶段神域争霸活动的胜利，请您重新准备，调整防守阵容参与下一阶段的战斗"})
	-- 		elseif self.m_tGameData.step_result.cur_step_result == "lost" and (not flag) then
	-- 			game_data:setGuildeResultFlag(true);
	-- 			game_scene:addPop("game_team_pk_result_pop",{is_win = 2,str = "由于您的联盟很遗憾的在了本次神域争霸活动中失败，请您在接下来继续提高自己战斗力，希望您的联盟下次活动中可以战胜对手"})
	-- 		end
	-- 	end
		
	-- end 
	self.m_openType = nil


end

function game_server_guildbattle_battle.init( self, t_params )
	self.m_tGameData = {}
	self.conut_tab = {}
	self.m_step = 0
	self.m_isManage = false
	t_params = t_params or {};
	if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
		local data = t_params.gameData:getNodeWithKey("data")
        data = json.decode(data:getFormatBuffer())
        self.m_tGameData = data
        self.m_step = self.m_tGameData.step
	end	
	self.m_isManage = self.m_tGameData.is_owner
	game_data:setServerGuildIsManage(self.m_isManage) 
	self:getConutTab()
	if t_params.toBattle then
		game_util:addMoveTips({text = "Chúc mừng đã tấn công thành công cứ điểm này"})
	end
	if t_params.openType then
		self.m_openType = t_params.openType
	end
	if t_params.flag then
		self.m_flag = t_params.flag
	end
	-- self.m_tGameData.step_result.cur_step_result = "win"
	if  t_params.reward then
		local reward=t_params.reward;
		if reward then
			game_util:rewardTipsByDataTable(reward);
		end
	end

end
	
function game_server_guildbattle_battle.create( self, t_params )
	self:init(t_params)
	local scene = CCScene:create()
	scene = self:createUi()
	self:refreshUi()
	return scene
end
	
return game_server_guildbattle_battle