--公会招募
local game_guild_choose_boss_pop = {
	m_tGameData = nil,
	m_root_layer = nil,
	m_close_btn = nil,
	-- boss_node = nil,
	m_node_tableView = nil,
	m_node_reward = nil,
	guild_employ_boss = nil,
    m_tab_flag = nil,
    m_bossId = nil,
  

}
function game_guild_choose_boss_pop.destroy( self )
	self.m_tGameData = nil;
	self.m_root_layer = nil;
	self.m_close_btn = nil;
	-- self.boss_node = nil;
	self.m_node_tableView = nil;
	self.m_node_reward = nil;
	self.guild_employ_boss = nil;
    self.m_tab_flag = nil;
    self.m_bossId = nil;
 
	cclog("--------game_guild_choose_boss_pop.destory-------")
end
function game_guild_choose_boss_pop.back( self )
	game_scene:removePopByName("game_guild_choose_boss_pop");
    self:destroy();
end
function game_guild_choose_boss_pop.createUi( self )
	local ccbNode = luaCCBNode:create()
	local function onMainBtnClick( target,event )
		local ccbNode = tolua.cast(target,"CCNode")
		local btnTag = ccbNode:getTag()
		if btnTag == 1 then 
			self:back()
		elseif btnTag == 13 then
			local function responseMethod(tag,gameData)
				game_scene:addPop("game_guild_choose_employ_pop",{gameData = gameData})
				self:back()
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_employ_ground"), http_request_method.GET, nil,"association_employ_ground")
		elseif btnTag == 14 then
            local params = {}
            params.boss_id = self.m_bossId
            local function responseMethod(tag,gameData)
                local notice = gameData:getNodeWithKey("data"):getNodeWithKey("notice")
                notice = json.decode(notice:getFormatBuffer())
                local length = game_util:getTableLen(notice)
                local m_openMsg = ""
                for i=1,length do
                    m_openMsg = m_openMsg .. "        " .. notice[i] .. "\n"
                end
                game_scene:addPop("game_guild_fuben_battleLog_pop",{openMsg = m_openMsg})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_boss_fight_notice"), http_request_method.GET, params,"association_boss_fight_notice")
        elseif btnTag == 15 then
            game_scene:addPop("game_choose_lookReward") 
        end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_guild_fuben_pop.ccbi")
	self.m_root_layer = ccbNode:layerForName('m_root_layer')
	self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
	self.m_node_reward = ccbNode:nodeForName("m_node_reward")
	-- self.boss_node = ccbNode:nodeForName("boss_node")
	local battle_btn = ccbNode:controlButtonForName("battle_btn")
    battle_btn:setVisible(false)
	self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    battle_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)

    local m_btn_battleLog = ccbNode:controlButtonForName("m_btn_battleLog")
    m_btn_battleLog:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    local m_btn_lookReward = ccbNode:controlButtonForName("m_btn_lookReward")
    m_btn_lookReward:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
	self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")
	-- local animNode = self:createCardAnimByData()
    -- animNode:setScale(0.85)
    -- animNode:setPosition(ccp(180,120))
    -- self.boss_node:removeAllChildrenWithCleanup(true)
    -- self.boss_node:addChild(animNode,10,10);

	local function onTouch(eventType, x, y)
	    if eventType == "began" then
	        return true;
	    elseif eventType == "ended" then
	    end
	end
	self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true)
	self.m_root_layer:setTouchEnabled(true);
	return ccbNode
	-- body
end
function game_guild_choose_boss_pop.createBossTableView( self,viewSize)
  
    local totalItem = 3--game_util:getTableLen(collectcardTab)
    local params = {};
    local viewSize = viewSize
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 1; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    params.direction = kCCScrollViewDirectionVertical
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    self.m_cellSize = itemSize
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            -- ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
            ccbNode:openCCBFile("ccb/ui_guild_funben_bossItem.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.6));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local boss_node = ccbNode:nodeForName("boss_node")
            local m_node_bossBg = ccbNode:nodeForName("m_node_bossBg")
            boss_node:removeAllChildrenWithCleanup(true)
            m_node_bossBg:removeAllChildrenWithCleanup(true)
            local bossAnim,bossBg = self:getBossID(index+1)
            local animNode = self:createCardAnimByData(bossAnim)
            local bossbg = CCSprite:create("ccbResources/" .. bossBg .. ".png")
            if bossbg then
                bossbg:setScale(0.75)
                bossbg:setAnchorPoint(ccp(0.5,0.5))
                m_node_bossBg:addChild(bossbg)
            end
            animNode:setPosition(ccp(160,120))

            -- if bossAnim == "shuijiangui" then
            --     animNode:setPosition(ccp(240,120))
            -- end
            animNode:setScale(0.5)
            boss_node:addChild(animNode,10,10);
            local boss_bg_sp = ccbNode:spriteForName("boss_bg_sp")
            boss_bg_sp:setVisible(false)
            -- boss_bg_sp:setScale(1)
            -- boss_bg_sp:addChild(CCSprite:create("ccbResources/" .. bossBg))
            local animArr = CCArray:create()
            local rotateBy =  CCRotateBy:create(5,360)
            animArr:addObject(rotateBy)
            local function delyFunc2(  )
            	local animArr2 = CCArray:create()
            	local rotateBy =  CCRotateBy:create(5,360)
            	animArr2:addObject(rotateBy)
            	animArr2:addObject(CCCallFunc:create(delyFunc2))
            	bossbg:runAction(CCSequence:create(animArr2))
            end
            animArr:addObject(CCCallFunc:create(delyFunc2))
            if bossbg then
                bossbg:runAction(CCSequence:create(animArr))
            end
            local m_num_label = ccbNode:labelTTFForName("m_num_label")
            local allNum = self.guild_employ_boss[tostring(index+1)].fight_time
            local curNum = self.m_tGameData.boss_data[tostring(index+1)]
            -- cclog2(index+1,"index 1111==== ")
            m_num_label:setString("Vượt ải:"..curNum.. "/" .. allNum)
            local m_label_combat = ccbNode:labelTTFForName("m_label_combat")
            local needCombat = self.guild_employ_boss[tostring(index+1)].combat
            m_label_combat:setString("B.R đề cử:" .. needCombat)

            --<<<<<<<<ZWJ
            local m_num_label2 = ccbNode:labelTTFForName("m_num_label2")
            local personNum=self.m_tGameData.per_data[tostring(index+1)] ;
            m_num_label2:setString("Số lần cá nhân:"..personNum .. "/" .. "2")
            -->>>>>>>>>>ZWJ

            if curNum == allNum  and index < 2 then
                self.m_tab_flag[index+1] = true
            else 
                self.m_tab_flag[index+1] = false
            end
        end
        return cell;
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_bossId = curPage
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item  then
        cclog2(index,"index3 ==== ")
            local personNum=self.m_tGameData.per_data[tostring(index+1)] ;
            --<<<<<<<<<<<<<<<<<<<<zwj<<<<<购买次数
           
            if (personNum<=0) then
                local function responseMethod(tag,gameData)
                    local function responseMethod2(tag,gameData)
                        self:back()
                        game_util:addMoveTips({text="Đã mua!"})
                        game_scene:addPop("game_guild_choose_boss_pop",{gameData = gameData})
                        
                    end
                    network.sendHttpRequest(responseMethod2,game_url.getUrlForKey("association_employ_boss_index"), http_request_method.GET, nil,"association_employ_boss_index")
                end
                local cost_coin = getConfig(game_config_field.pay):getNodeWithKey("35"):getNodeWithKey("coin");
                cost_coin=cost_coin:getNodeAt(0):toInt();
                local t_params = 
                {
                    m_openType = 10,
                    coin = cost_coin,
                    m_ok_func = function()
                        game_scene:removePopByName("game_normal_tips_pop");
                        --购买次数
                        params={}
                        params.boss=index + 1;
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_buy_time"), http_request_method.GET,params,"association_buy_time")
                    end
                }
                game_scene:addPop("game_normal_tips_pop",t_params)
                return;
            end
            -->>>>>>>>>>>>>>>>>>>zwj>>>>购买次数


            if index > 0 then
                if self.m_tab_flag[index] then
                
                else
                    game_util:addMoveTips({text = "Vượt ải trước đó đã"})
                    return
                end
            end
            game_data:setGuildBossId(index+1)
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_guild_choose_employ_pop",{gameData = gameData,bossId = index + 1})
                self:back()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_employ_ground"), http_request_method.GET, nil,"association_employ_ground")
        end
    end
    return  TableViewHelper:createGallery2(params);
end

--[[
    获取小伙伴位置上的动画
]]
function game_guild_choose_boss_pop.createCardAnimByData( self,combinerCfg,animFlag)
    -- local animNode = nil;
    -- animNode = game_util:createIdelAnim("penhuolong",0);
    -- return animNode


    local function onAnimSectionEnd( animNode, theId,theLabelName )
    	if theLabelName=="gongji1" then
    		-- game_anim:playSection(animNode,"daiji")
         	animNode:playSection("daiji");
        elseif theLabelName == "daiji" then
        	animNode:playSection("gongji2");
        	-- game_anim:playSection(animNode,"gongji2")
        elseif theLabelName=="gongji2" then
    		-- game_anim:playSection(animNode,"gongji1")
        	animNode:playSection("gongji1");
        end

    end
    local anim = game_util:createAnimEffect(combinerCfg,combinerCfg,onAnimSectionEnd, nil, true);
    anim:registerScriptTapHandler(onAnimSectionEnd)
    
    anim:playSection("gongji1");
    return anim


end
function game_guild_choose_boss_pop.getBossID( self,i)
    local fightIdTab,bossId,tempTab  = {},{},{}
    local guild_employ_position = json.decode(getConfig(game_config_field.guild_employ_position):getFormatBuffer()) or {}
    local guild_employ_enemy = getConfig(game_config_field.guild_employ_enemy)

    self.guild_employ_boss = json.decode(getConfig(game_config_field.guild_employ_boss):getFormatBuffer()) or {}
    for i=1,game_util:getTableLen(self.guild_employ_boss) do
        local fightId = self.guild_employ_boss[tostring(i)].fight_ID[3]
        table.insert(fightIdTab,fightId)
    end
    for k,v in pairs(guild_employ_position) do
        for i=1,game_util:getTableLen(fightIdTab) do
            if tostring(k) == tostring(fightIdTab[i]) then
                table.insert(tempTab,v.position2)
            end
        end
    end
    for i=1,game_util:getTableLen(tempTab) do
        table.insert(bossId,tempTab[i][1])
    end
    table.sort( bossId)
    local bossAnim,bossBg = "",""
    bossAnim = guild_employ_enemy:getNodeWithKey(tostring(bossId[i])):getNodeWithKey("animation"):toStr()
    bossBg = guild_employ_enemy:getNodeWithKey(tostring(bossId[i])):getNodeWithKey("img"):toStr()
    return bossAnim,bossBg
end
function game_guild_choose_boss_pop.refreshUi( self )
	self.m_node_tableView:removeAllChildrenWithCleanup(true)
	local viewSize = self.m_node_tableView:getContentSize()	
	local tableView = self:createBossTableView(viewSize)
	self.m_node_tableView:addChild(tableView)
    -- self:getBossID()
    -- cclog2(self.m_tab_flag,"xx === ")
end

function game_guild_choose_boss_pop.init( self,t_params )
	t_params = t_params or {}
    self.m_tab_flag = {false,false}
	if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
		local data = t_params.gameData:getNodeWithKey("data")
        data = json.decode(data:getFormatBuffer())
        self.m_tGameData = data
	end	
	self.guild_employ_boss = json.decode(getConfig(game_config_field.guild_employ_boss):getFormatBuffer()) or {}
    self.m_bossId = 1

    
end

function game_guild_choose_boss_pop.create( self,t_params )
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
	-- body
end
return game_guild_choose_boss_pop;