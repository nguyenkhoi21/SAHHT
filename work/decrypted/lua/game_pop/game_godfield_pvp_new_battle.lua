local game_godfield_pvp_new_battle = {
	m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_callBackFunc = nil,
    m_tips_label = nil,
}

function game_godfield_pvp_new_battle.destroy(self)
    -- body
    cclog("-----------------game_godfield_pvp_new_battle destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_callBackFunc = nil;
    self.m_tips_label = nil;
end


function game_godfield_pvp_new_battle.back(self,type)
    game_scene:removePopByName("game_godfield_pvp_new_battle");
end


function game_godfield_pvp_new_battle.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_Arena_new_battle.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_btn = ccbNode:controlButtonForName("m_btn")
    m_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_my_move_node = ccbNode:nodeForName("m_my_move_node")
    self.m_ohter_move_node = ccbNode:nodeForName("m_ohter_move_node")
    self.m_fight_sp = ccbNode:spriteForName("m_fight_sp")
    self.m_vs_node = ccbNode:nodeForName("m_vs_node")
    self.m_my_team_node = ccbNode:nodeForName("m_my_team_node")
    self.m_other_team_node = ccbNode:nodeForName("m_other_team_node")

    self.m_my_name_lb = ccbNode:labelTTFForName("m_my_name_lb")
    self.m_my_score_lb = ccbNode:labelTTFForName("m_my_score_lb")
    self.m_my_win_count_lb = ccbNode:labelTTFForName("m_my_win_count_lb")
    self.m_my_shenglv_lb = ccbNode:labelTTFForName("m_my_shenglv_lb")
    self.my_combat = ccbNode:labelTTFForName("my_combat")
    self.m_other_combat = ccbNode:labelTTFForName("m_other_combat")
    self.m_other_win_count_lb = ccbNode:labelTTFForName("m_other_win_count_lb")
    self.m_other_shenglv_lb = ccbNode:labelTTFForName("m_other_shenglv_lb")
    self.m_other_name_lb = ccbNode:labelTTFForName("m_other_name_lb")

    self.m_ccbNode = ccbNode;
    return ccbNode;
end



function game_godfield_pvp_new_battle:createZhenrongList()

    local show_list = {}
    for k,v in pairs(self.m_tGameData.god_field_ids) do
        if v~="-1" and v ~= "0" then
            show_list[#show_list+1] = v
        end
    end
    local sPosition_x = position_x[#show_list]
    local viewSize = self.m_zhenxing_node:getContentSize()
    for i=1,#show_list do
        local itemData,itemCfg = game_data:getCardDataById(show_list[i])
        local headIconSpr = game_util:createCardIconByCid(itemData.c_id,itemData);
        headIconSpr:setScale(0.7)
        local function onBtnCilck( event,target )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            local itemData = game_data:getCardDataById(show_list[btnTag])
            if itemData then
                game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 3})
            end
        end
        local ccb = luaCCBNode:create()
        ccb:openCCBFile("ccb/ui_godfield_dart_zhenrong_item.ccbi")
        local icon_node = ccb:nodeForName("icon_node")
        icon_node:addChild(headIconSpr,1001,1001)
        headIconSpr:setAnchorPoint(ccp(0.5,0.5))
        headIconSpr:setPosition(ccp(0,0))
        ccb:setAnchorPoint(ccp(0.5,0.5))
        ccb:setPosition(ccp(viewSize.width*sPosition_x[i],viewSize.height*0.5))
        self.m_zhenxing_node:addChild(ccb)
        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        button:setOpacity(0)
        button:setTag(i)
        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY)
        button:setAnchorPoint(ccp(0.5,0.5))
        button:setPosition(ccp(0,0))
        icon_node:addChild(button); 
    end
end




function game_godfield_pvp_new_battle:refreshInfo()

	local position_x = {
        {0.5,},
        {0.35,0.65},
        {0.25,0.5,0.75},
        {0.2,0.4,0.6,0.8},
        {0.1,0.3,0.5,0.7,0.9},
    }

	local attacker = self.m_tGameData.attacker
	local defender = self.m_tGameData.defender
	local battle = self.m_tGameData.battle.init

	local my_teamTab = {}
	local other_teamTab = {}
	for k,v in pairs(attacker.align_1) do
		if v~="0" and v ~= "-1" then
			my_teamTab[#my_teamTab+1] = v
		end	
	end	
	for k,v in pairs(defender.align_1) do
		if v~="0" and v ~= "-1" then
			other_teamTab[#other_teamTab+1] = v
		end	
	end
	local sPosition_x = position_x[#my_teamTab]
	local viewSize = self.m_my_team_node:getContentSize()
	for i=1,#my_teamTab do
		local itemData,itemCfg = game_data:getCardDataById(my_teamTab[i])
        local headIconSpr = game_util:createCardIconByCid(itemData.c_id,itemData);
        headIconSpr:setScale(0.7)
        local ccb = luaCCBNode:create()
        ccb:openCCBFile("ccb/ui_godfield_dart_zhenrong_item.ccbi")
        local icon_node = ccb:nodeForName("icon_node")
        icon_node:addChild(headIconSpr,1001,1001)
        headIconSpr:setAnchorPoint(ccp(0.5,0.5))
        headIconSpr:setPosition(ccp(0,0))
        ccb:setAnchorPoint(ccp(0.5,0.5))
        ccb:setPosition(ccp(viewSize.width*sPosition_x[i],viewSize.height*0.5))
        self.m_my_team_node:addChild(ccb)
	end


	local sPosition_x2 = position_x[#other_teamTab]
	local viewSize2 = self.m_other_team_node:getContentSize()
	for i=1,#other_teamTab do
		local itemData = battle.card_def[defender.uid .. "_" .. other_teamTab[i]]
        local headIconSpr = game_util:createCardIconByCid(itemData.c_id,itemData);
        headIconSpr:setScale(0.7)
        local ccb = luaCCBNode:create()
        ccb:openCCBFile("ccb/ui_godfield_dart_zhenrong_item.ccbi")
        local icon_node = ccb:nodeForName("icon_node")
        icon_node:addChild(headIconSpr,1001,1001)
        headIconSpr:setAnchorPoint(ccp(0.5,0.5))
        headIconSpr:setPosition(ccp(0,0))
        ccb:setAnchorPoint(ccp(0.5,0.5))
        ccb:setPosition(ccp(viewSize2.width*sPosition_x2[i],viewSize2.height*0.5))
        self.m_other_team_node:addChild(ccb)
	end

	self.m_my_name_lb:setString(battle.atk_name)
	self.m_my_score_lb:setString(attacker.score)
	self.m_my_win_count_lb:setString(attacker.vin_times)
	self.m_my_shenglv_lb:setString(math.floor((attacker.vin_times+attacker.fail_times) > 0 and (attacker.vin_times/(attacker.vin_times+attacker.fail_times))*100 or 0) .. "%")
	self.my_combat:setString(attacker.combat)


	self.m_other_name_lb:setString(battle.dfd_name)
	self.m_other_combat:setString(defender.combat)
	self.m_other_win_count_lb:setString(defender.vin_times)
	self.m_other_shenglv_lb:setString(math.floor((defender.vin_times+defender.fail_times) > 0 and (defender.vin_times/(defender.vin_times+defender.fail_times))*100 or 0) .. "%")     --(defender.fail_times)



    local lv1,lv2,next_score = self:getLevel(self.m_tGameData.attacker.score)
    local m_main_sp = self.m_ccbNode:spriteForName("m_main_sp")
    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring("pvp_sec_icon" .. lv1 .. ".png"))
    if tempSpriteFrame then
        m_main_sp:setDisplayFrame(tempSpriteFrame)
    end

    for i=1,5 do
        local xing_sp = self.m_ccbNode:spriteForName("m_xing_sp" .. i)
        if lv2 >= i then
            self:refreshXing(true,xing_sp,i)
        else
            self:refreshXing(false,xing_sp,i)
        end
    end



end

function game_godfield_pvp_new_battle:refreshXing(flag,xing_sp,index)
    local fileName = "pvp_sec_xingxing" .. (index == 3 and "1" or "2")
    fileName = fileName .. (flag and "2" or "1")
    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(fileName .. ".png")
    if tempSpriteFrame and xing_sp then
        xing_sp:setDisplayFrame(tempSpriteFrame)
    end

end


function game_godfield_pvp_new_battle:getLevel(myscore)
    myscore = myscore or self.m_tGameData.attacker.score
    local level = 0
    local next_score = 0
    local universe_arena_grade_cfg = getConfig(game_config_field.universe_arena_grade)
    universe_arena_grade = json.decode(universe_arena_grade_cfg:getFormatBuffer())
    for k,v in pairs(universe_arena_grade) do
        cclog2(k)
        local score = v.score
        if (score[1] <= myscore)  and myscore <= score[2] then
            level = k
            local next_l = universe_arena_grade[tostring(tonumber(k)+1)]
            if next_l~=nil then
                next_score = next_l.score[1]
            end
        end
    end
    local lv1 = math.ceil(level/5)
    local lv2 = level%5
    return lv1,lv2,next_score
end




function game_godfield_pvp_new_battle.refreshUi(self)
	self:refreshInfo()

	local function beginBattle()
		self.m_vs_node:stopAllActions()
	    if self.m_shared then
	        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared);
	    end
	    game_data:setBattleType("game_godfield_pvp_new_battle");
    	game_scene:enterGameUi("game_battle_scene",{gameData = self.m_tGameData,enterType = "game_godfield_pvp_new_battle"});
	end

	local function remove_second()
		self.m_ohter_move_node:stopAllActions()
		self.m_vs_node:setPosition(ccp(460,270))
		self.m_vs_node:setScale(2)
		local arr1 = CCArray:create()
		arr1:addObject(CCScaleTo:create(1,1))
		arr1:addObject(CCEaseIn:create(CCMoveTo:create(1,ccp(240,150)),10))
		local arr2 = CCArray:create()
		arr2:addObject(CCSpawn:create(arr1))
		arr2:addObject(CCScaleTo:create(0.3,1))
		arr2:addObject(CCCallFuncN:create(beginBattle))
		self.m_vs_node:runAction(CCSequence:create(arr2))
	end

	local function remove_first()
		self.m_my_move_node:stopAllActions()
		local x,y = self.m_ohter_move_node:getPosition()
		self.m_ohter_move_node:setPosition(ccp(550,y))
		local remove = CCCallFuncN:create(remove_second);
	    local arr = CCArray:create();
	    arr:addObject(CCEaseIn:create(CCMoveTo:create(1,ccp(172,y)),10))
	    arr:addObject(remove)
	    self.m_ohter_move_node:runAction(CCSequence:create(arr));
	end

	local x,y = self.m_my_move_node:getPosition()
	self.m_my_move_node:setPosition(ccp(-300,y))

	local remove = CCCallFuncN:create(remove_first);
    local arr = CCArray:create();
    arr:addObject(CCEaseIn:create(CCMoveTo:create(1,ccp(10,y)),10))
    arr:addObject(remove)
    self.m_my_move_node:runAction(CCSequence:create(arr));


	local count = 1
	local function tick(dt)
		local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring("pvp_vs_light" .. count .. ".png"))
	  	if tempSpriteFrame then
	     	self.m_fight_sp:setDisplayFrame(tempSpriteFrame)
	  	end
	  	count = count + 1
	  	if count > 3 then
	  		count = 1
	  	end
	end
	self.m_shared = scheduler.schedule(tick, 1/7, false)
end


function game_godfield_pvp_new_battle.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil then
        if tolua.type(t_params.gameData) == "util_json" then
            local data = t_params.gameData:getNodeWithKey("data");
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        else
            self.m_tGameData = t_params.gameData
        end
    else
        self.m_tGameData = {}
    end
    -- cclog2(self.m_tGameData,"")
    self.enterType = t_params.enterType or 1
    local tempTab = {}
    tempTab.teamIndex = self.enterType
    tempTab.isWin = self.m_tGameData.is_win
    tempTab.score = self.m_tGameData.att_score_add
    tempTab.grade_score = self.m_tGameData.get_grade_score
    tempTab.rank_changed = self.m_tGameData.attacker.old_rank - self.m_tGameData.attacker.new_rank 
    game_data:setGodPvpBattleResult(tempTab)
end


function game_godfield_pvp_new_battle.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_pvp_new_battle;