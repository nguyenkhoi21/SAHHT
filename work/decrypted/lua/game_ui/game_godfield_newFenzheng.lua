---  新纷争峡谷
local game_godfield_newFenzheng = {
	bar_node = nil,
	m_layer_bg = nil,
	m_scroll_view = nil,
	m_root_layer = nil,
    select_building = nil,
    m_buildTab = nil,
    m_node_time = nil,
    m_lab_attack = nil,
    left_time_node = nil,
    m_boss_flag = nil,
    m_lab_rate = nil,
};
--[[--
    销毁ui
]]
function game_godfield_newFenzheng.destroy(self)
    cclog("----------------- game_godfield_newFenzheng destroy-----------------"); 
    self.bar_node = nil;
	self.m_layer_bg = nil;
	self.m_root_layer = nil;
	self.m_scroll_view = nil;
    self.select_building = nil;
    self.m_buildTab = nil;
    self.m_node_time = nil;
    self.m_lab_attack = nil;
    self.left_time_node = nil;
    self.m_boss_flag = nil;
    self.m_lab_rate = nil;

end
local ship_pos_tab = {
    ccp(60,115),
    ccp(228,157),ccp(318,157),ccp(408,157),
    ccp(175,130),ccp(265,130),ccp(355,130),
    ccp(115,90),ccp(205,90),ccp(295,90),
    ccp(55,50),ccp(145,50),ccp(235,50),
    ccp(95,10),ccp(185,10),
    ccp(588,157),ccp(678,157),
    ccp(535,130),ccp(625,130),ccp(715,130),
    ccp(475,90),ccp(565,90),ccp(655,90),
    ccp(415,50),ccp(505,50),ccp(595,50),
    ccp(365,10),ccp(455,10),ccp(545,10),
    ccp(645,21)

}
--[[--
    返回
]]
function game_godfield_newFenzheng.back(self)
	local function responseMethod( tag,gameData )
        game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_newFenzheng.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_team_pk.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_team_boss.plist");
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back()
        elseif btnTag == 101 then --加速
            local team_pk_time_cfg = getConfig(game_config_field.server_pk_time);
            local pay = team_pk_time_cfg:getNodeWithKey("1"):getNodeWithKey("cost"):toInt()
                local t_params = 
                    {
                        title = "提示",
                        okBtnCallBack = function(target,event)
                            game_util:closeAlertView();
                            local function responseMethod(tag,gameData)
                                if gameData then
                                    local data = gameData:getNodeWithKey("data");
                                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                                    self:refreshUi()
                                end
                            end
                            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_cool_down_boss_battle_attack"), http_request_method.GET, nil,"team_pk_new_cool_down_boss_battle_attack",true,true)
                        end,   --可缺省
                        closeCallBack = function(target,event)
                          game_util:closeAlertView();
                            
                        end,
                      okBtnText = "确定",       --可缺省
                      text = "加速需要花费" .. pay .. "钻石，是否进行加速",      --可缺省
                  }
                  game_util:openAlertView(t_params);
           
        elseif btnTag == 102 then -- 刷新
            local function responseMethod( tag,gameData )
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
        elseif btnTag == 103 then
             game_scene:addPop("game_godfield_fengzheng_battleRank",{gameData = self.m_tGameData})
        elseif btnTag == 104 then
            local annoucement_cfg = getConfig(game_config_field.adver_pk)
            local itemCfg = annoucement_cfg:getNodeWithKey(tostring(1))
            if itemCfg == nil then return end
            local openMsg = itemCfg:getNodeWithKey("word"):toStr();
            game_scene:addPop("game_godfield_detail_pop",{openMsg = openMsg})
        elseif btnTag == 105 then --阵型
            local function responseMethod( tag,gameData )
                local formation = self.m_tGameData.team_pk_formation
                game_scene:addPop("game_godfield_fenzhengzhenxing_pop",{gameData = gameData,formation = formation,openType = "new_fenzheng"});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_upload_god_formation"), http_request_method.GET, nil,"god_field_upload_god_formation")
            -- local function responseMethod(tag,gameData)
            --     if gameData then
            --         game_scene:enterGameUi("game_god_adjustment",{gameData = gameData,openType="new_fenzheng",});
            --     end
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_upload_god_formation"), http_request_method.GET, nil,"god_field_upload_god_formation",true,true)
        elseif btnTag == 110 then -- 购买士气
            local teamid = self.m_tGameData.team_id
            local length = game_util:getTableLen(self.m_tGameData.battle_ground.teams)
            local num 
            for i=1,length do
                if self.m_tGameData.battle_ground.teams[i].team_id == teamid then
                    num = game_util:getTableLen(self.m_tGameData.battle_ground.teams[i].members)
                end
            end
            local server_pk_power = getConfig(game_config_field.server_pk_power);
            server_pk_power = json.decode(server_pk_power:getFormatBuffer()) or {};
            local length2 = game_util:getTableLen(server_pk_power)
            local cost = 55
            for i=1,length2 do
                if server_pk_power[tostring(i)].num == num then
                    cost = server_pk_power[tostring(i)].cost
                end
            end
            local t_params = 
                {
                    title = "提示",
                    okBtnCallBack = function(target,event)
                        game_util:closeAlertView();
                        local function responseMethod(tag,gameData)
                            if gameData then
                                local data = gameData:getNodeWithKey("data");
                                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                                self:refreshUi()
                            end
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_recover_morale"), http_request_method.GET, nil,"team_pk_new_recover_morale",true,true)
                    end,   --可缺省
                    closeCallBack = function(target,event)
                        game_util:closeAlertView();
                    end,
                  okBtnText = "确定",       --可缺省
                  text = "提升士气需要花费" .. cost .. "钻石，是否进行提升",      --可缺省
                }
            game_util:openAlertView(t_params);
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_fenzheng_new.ccbi");
    self.m_node_time = ccbNode:nodeForName("m_node_time")
    self.left_time_node = ccbNode:nodeForName("left_time_node")
    self.m_lab_attack = ccbNode:labelTTFForName("m_lab_attack")
    self.m_lab_rate = ccbNode:labelTTFForName("m_lab_rate")
    local m_btn_jiasu = ccbNode:controlButtonForName("m_btn_jiasu")
    local m_btn_refresh = ccbNode:controlButtonForName("m_btn_refresh")
    local m_btn_rank = ccbNode:controlButtonForName("m_btn_rank")
    local m_btn_des = ccbNode:controlButtonForName("m_btn_des")
    m_btn_jiasu:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    m_btn_refresh:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    m_btn_rank:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    m_btn_des:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    self.m_layer_bg = ccbNode:layerForName("m_layer_bg")
    self.bar_node = ccbNode:nodeForName("bar_node")
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    return ccbNode;
end
--[[
    创建boss动画
]]
function game_godfield_newFenzheng.createBossAnim(self,parentNode,boss_hp,max_hp,info,infoType)
    -- local boss_hp = 1
    -- local boss_hp = 100
  
     parentNode:removeAllChildrenWithCleanup(true)
    local boss_node = game_util:createIdelAnim("jingang",0)
    boss_node:setAnchorPoint(ccp(0.5,0.5))

    local hpSprite = CCSprite:createWithSpriteFrameName("teampk_hp.png");
    hpSprite:setPosition(ccp(-50,-35))

    local bar = ExtProgressTime:createWithFrameName("teampk_progressback.png","teampk_progress.png");
    bar:setMaxValue(max_hp)
    bar:setCurValue(boss_hp,false);
    bar:setAnchorPoint(ccp(0.5,0.5))
    bar:setPosition(ccp(0,-35))

    local hpLabel = game_util:createLabelTTF({text = boss_hp,color = ccc3(147,253,60)})
    hpLabel:setPosition(ccp(0,-35))
    boss_node:setTag(#ship_pos_tab+infoType)
    self.m_buildTab[#ship_pos_tab+infoType] = boss_node

    parentNode:addChild(boss_node)
    parentNode:addChild(hpSprite)
    parentNode:addChild(bar)
    parentNode:addChild(hpLabel)
    --加对战双方的名字

    -- if info.server and info.guild_name then
    --     local infoLabel = game_util:createLabelTTF({text = info.server .. " - " .. info.guild_name,color = ccc3(255,216,0)})
    --     local selectBg = CCSprite:createWithSpriteFrameName("public_selectBg.png")
    --     if infoType == 1 then
    --         infoLabel:setPosition(ccp(0,-48))
    --         selectBg:setPosition(ccp(0,-48))
    --     else
    --         infoLabel:setPosition(ccp(0,45))
    --         selectBg:setPosition(ccp(0,45))
    --     end
    --     parentNode:addChild(selectBg)
    --     parentNode:addChild(infoLabel)
    -- end
end


function game_godfield_newFenzheng.createFighship( self )
    -- local effect = game_util:createEffectAnim("zhanling",1.0)
    -- self.m_scroll_view:addChild(effect,10)
    local fightInfoTab = {}
    if self.m_tGameData  and tolua.type(self.m_tGameData.battle_ground) == "table" then
        for k,v in pairs(self.m_tGameData.battle_ground.footholds) do
            fightInfoTab = self.m_tGameData.battle_ground.footholds
        end
    end
	for i=1,#ship_pos_tab do
		-- team_pk_ship
	    local bossShip = CCSprite:createWithSpriteFrameName("team_pk_ship.png")
	    local posX = 40 + 100 * ((i - 1) % 5)
	    local posY = 162 - 64 * (math.floor((i-1) / 5))
	    bossShip:setPosition(ship_pos_tab[i])
	    bossShip:setScale(0.8)
	    self.m_scroll_view:addChild(bossShip,10,100 + i)

	    local countdown = ""
	    local alphaBack = CCScale9Sprite:createWithSpriteFrameName("public_selectBg.png")
	    alphaBack:setPreferredSize(CCSizeMake(90,25))
	    alphaBack:setPosition(posX,posY-30)
	    alphaBack:setOpacity(210)
	    -- self.m_scroll_view:addChild(alphaBack,10)   
        bossShip:setTag(i)
        local color = ccc3(25,150,220)
        local name = ""
        local tempuid = ""
        if i > 15 then
            bossShip:setTag(i-15+100)
            
            if fightInfoTab[tostring(i-15+100)] then
                name = fightInfoTab[tostring(i-15+100)].attacker_name
                if name == "" then
                    name = fightInfoTab[tostring(i-15+100)].defender_name
                    color = ccc3(255,10,10)
                end
                tempuid = fightInfoTab[tostring(i-15+100)].defender
            end
        else
            if fightInfoTab[tostring(i)] then
                color = ccc3(255,10,10)
                name = fightInfoTab[tostring(i)].attacker_name
                if name == "" then
                    name = fightInfoTab[tostring(i)].defender_name
                    color = ccc3(25,150,220)
                end
                tempuid = fightInfoTab[tostring(i)].defender
            end
        end      
        
	    local nameLabel
        nameLabel = game_util:createLabelTTF({text = name,color = color,fontSize = 10})
	    nameLabel:setPosition(ccp(10,-5))
	   --加自己队伍标识
        local uid = game_data:getUserStatusDataByKey("uid")
        local is_my_team = false
        if tempuid then
           if tempuid == uid then
               is_my_team = true
               self.m_boss_flag = i
           else
               is_my_team = false
           end
        end
        if is_my_team then
           local spriteTip = CCSprite:createWithSpriteFrameName("gvg_select1.png")
           spriteTip:setPosition(ccp(bossShip:getContentSize().width*0.5,bossShip:getContentSize().height+1))
           bossShip:addChild(spriteTip,100)
           local animArr = CCArray:create();
           animArr:addObject(CCMoveTo:create(1,ccp(bossShip:getContentSize().width*0.5, bossShip:getContentSize().height+5)))
           animArr:addObject(CCMoveTo:create(1,ccp(bossShip:getContentSize().width*0.5, bossShip:getContentSize().height+1)))
           spriteTip:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
        end       
        bossShip:addChild(nameLabel,10)   
        self.m_buildTab[i] = bossShip
	end 
end
--[[--
    创建触摸
]]
local touchBeginPoint = nil
local touchBeginPoint2 = nil
local scrollviewOffset = ccp(0,0)
function game_godfield_newFenzheng.createTouch( self)
    local touchMoveFlag = false
    local maxOffsetX = 852 - self.m_layer_bg:getContentSize().width
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            local touched = false
            touchMoveFlag = false
            touchBeginPoint = {x = x, y = y}
            touchBeginPoint2 = {x = x, y = y}
            local touched = self.m_layer_bg:boundingBox():containsPoint(ccp(x, y))
            for k,v in pairs(self.m_buildTab) do
                local realPos = v:getParent():convertToNodeSpace(ccp(x,y));
                if v:boundingBox():containsPoint(realPos) then
                    self.select_building = v
                    break
                end
            end
            return touched
        elseif eventType == "moved" then
            scrollviewOffset = self.m_scroll_view:getContentOffset()
            local srcollviewOffsetX = scrollviewOffset.x + (x - touchBeginPoint.x)
            
            if srcollviewOffsetX >= 0 then
                srcollviewOffsetX = 0
            end
            if srcollviewOffsetX < - maxOffsetX then
                srcollviewOffsetX = - maxOffsetX
            end
            if ccpDistance(ccp(touchBeginPoint2.x,touchBeginPoint2.y),ccp(x,y)) > 20 then
                touchMoveFlag = true
            end
            if srcollviewOffsetX >= - maxOffsetX and - maxOffsetX <= 0 then
                self.m_scroll_view:setContentOffset(ccp( srcollviewOffsetX,scrollviewOffset.y))
            end
            if self.select_building then
                local realPos = self.select_building:getParent():convertToNodeSpace(ccp(x,y));
                if self.select_building:boundingBox():containsPoint(realPos) then
                else
                end
            end
            touchBeginPoint = {x=x,y=y}
        else
            if self.select_building then
                local realPos = self.select_building:getParent():convertToNodeSpace(ccp(x,y));
                if self.select_building:boundingBox():containsPoint(realPos) and touchMoveFlag == false then
                    --进入建筑
                    if self.select_building:getTag() == 31 then
                        if self.m_boss_flag < 16 then
                            cclog2("burangda")
                        else
                            cclog2("rangda")
                            local params = {}
                            params.foothold_id = -1
                                local function responseMethod( tag,gameData )
                                    -- cclog2(gameData,"gameData --- ")
                                    if gameData then
                                        local hurt = gameData:getNodeWithKey("data"):getNodeWithKey("hurt"):toStr()
                                        game_util:addMoveTips({text = "恭喜您对boss造成了" .. hurt .. "点伤害"})
                                        local data = gameData:getNodeWithKey("data");
                                        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                                        self:refreshUi()
                                    end
                                end
                                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_boss_battle_v3"), http_request_method.GET, params,"team_pk_boss_battle_v3",true,true)
                        end
                    elseif  self.select_building:getTag() == 32 then
                        if self.m_boss_flag > 15 then
                            cclog2("burangda")
                        else
                            cclog2("rangda")
                            local params = {}
                            params.foothold_id = -1
                            local function responseMethod( tag,gameData )
                               if gameData then
                                    local hurt = gameData:getNodeWithKey("data"):getNodeWithKey("hurt"):toStr()
                                    game_util:addMoveTips({text = "恭喜您对boss造成了" .. hurt .. "点伤害"})
                                    local data = gameData:getNodeWithKey("data");
                                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                                    self:refreshUi()
                               end
                            end
                            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_boss_battle_v3"), http_request_method.GET, params,"team_pk_boss_battle_v3",true,true)
                        end
                    else
                        local params = {}
                        params.foothold_id = self.select_building:getTag()
                        local isChallenge = false   
                        if  self.m_tGameData.battle_ground.footholds[tostring(self.select_building:getTag())] then 
                            local x = self.m_tGameData.battle_ground.footholds[tostring(self.select_building:getTag())].attacker_name
                            if x == "" and self.select_building:getTag()>15 then
                                isChallenge = true   
                            elseif x ~= "" and self.select_building:getTag()<16 then
                                isChallenge = true   
                            else
                                isChallenge = false   
                            end
                            local index = self.select_building:getTag()
                            local function responseMethod( tag,gameData )
                                local function callback( gameData2,is_win,index )
                                    -- body
                                    self.m_tGameData = gameData2
                                    self:refreshUi()
                                    local text2 = ""
                                    if is_win == "true" then
                                        text2 = "恭喜您成功占领据点 "
                                    else
                                        text2 = "很遗憾您未能战胜对手 "
                                    end
                                    game_util:addMoveTips({text = text2})
                                    -- cclog2(is_win,"is_win ==== ")
                                end
                                game_scene:addPop("game_godfield_fenzhengEnemy_pop",{gameData = gameData,isChallenge = isChallenge,index = index,callback = callback})
                            end
                            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_foothold_info"), http_request_method.GET, params,"team_pk_new_foothold_info",true,true)
                        end 
                    end
                else
                    
                end
                self.select_building = nil
            else
            end
        end
    end
    
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY)
    self.m_root_layer:setTouchEnabled(true)
    -- body
end
function game_godfield_newFenzheng.createScrollContent(self,parentNode)
    local container = CCLayer:create()
    local size = parentNode:getContentSize()
    container:setContentSize(CCSizeMake(size.width, size.height))
    local view = CCScrollView:create(size, container)
	self.m_scroll_view = view
	view:setAnchorPoint(ccp(0,0))
	view:setContentSize(CCSizeMake(852, size.height))
	view:setTouchEnabled(false)
    view:setContentOffset(ccp(0,0));
	view:setDirection(kCCScrollViewDirectionHorizontal)

    local bg =  CCSprite:create("ccbResources/godfield_newFenzhengBg.png")
    view:addChild(bg)
    
    return view
end
function game_godfield_newFenzheng.createTimeDown( self,parentNode,time_count_down,shwoType,isclose )
    local function timeEndFunc()
        parentNode:setVisible(false)
        self.m_lab_attack:setVisible(false)
        if isclose == "close" then
            self:back()
        end
        -- local function responseMethod( tag,gameData )
        --     if gameData ~= nil and tolua.type(gameData) == "util_json" then
        --         local data = gameData:getNodeWithKey("data");
        --         self.m_tGameData = json.decode(data:getFormatBuffer()) 
        --         self:refreshUi()
        --     end
        -- end
        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_tycoon_active_index"), http_request_method.GET, {},"super_tycoon_active_index")
    end
    parentNode:removeAllChildrenWithCleanup(true)
    local countdownLabel = game_util:createCountdownLabel(time_count_down,timeEndFunc,8, shwoType);
    countdownLabel:setColor(ccc3(255, 255, 255))
    countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    local tempcontent = parentNode:getContentSize()
    countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.6))
    parentNode:addChild(countdownLabel,10,10) 
    -- body
end

--[[--
    刷新ui
]]
function game_godfield_newFenzheng.refreshUi(self)
	if self.m_scroll_view then
        self.m_scroll_view:getContainer():removeAllChildrenWithCleanup(true)
    end
    self.m_scroll_view = self:createScrollContent(self.m_layer_bg)
    self.m_layer_bg:addChild(self.m_scroll_view)
    local bar = ExtProgressTime:createWithFrameName("gvg_att_hp.png","gvg_def_hp.png")
    local morale1,morale2 = 0,0
    if tolua.type(self.m_tGameData.battle_ground) == "table" then

        morale1 = self.m_tGameData.battle_ground.teams[1].morale or 0
        morale2 = self.m_tGameData.battle_ground.teams[2].morale or 0
    end
    self.m_lab_rate:setString("士气值 " .. morale1 .. ":" .. morale2)
    bar:setMaxValue(morale2 + morale1);
    bar:setCurValue(morale1,false);
    bar:setAnchorPoint(ccp(0.5,0.5));
    bar:setPosition(ccp(0,-1));
    self.bar_node:addChild(bar,-1,11)
    self:createTouch()
    self:createFighship()
    self:createTimeDown(self.m_node_time,self.m_tGameData.time_count_down,2,"close")
    if self.m_tGameData.v3_boss_cool_down ~= 0 then
        self.m_lab_attack:setVisible(true)
        self.left_time_node:setVisible(true)
        self:createTimeDown(self.left_time_node,self.m_tGameData.v3_boss_cool_down,2)
    else
        self.m_lab_attack:setVisible(false)
        self.left_time_node:setVisible(false)
    end

    local anim_node1 = CCNode:create();
    local anim_node2 = CCNode:create();

    anim_node1:setPosition(ccp(70,195))
    anim_node2:setPosition(ccp(740,60))
    local bosshp1 = self.m_tGameData.own_boss_hp
    local bosshp2 =  self.m_tGameData.enemy_boss_hp
    -- if self.m_boss_flag > 15 then
    --     anim_node2:setPosition(ccp(70,195))
    --     anim_node1:setPosition(ccp(740,60))
    -- else
    --     anim_node1:setPosition(ccp(70,195))
    --     anim_node2:setPosition(ccp(740,60))
        
    -- end
    local max_hp = self.m_tGameData.boss_max_hp or 1000000
    if bosshp1 == 0 then
        game_scene:addPop("game_team_pk_result_pop",{is_win = 0})
    elseif bosshp2 == 0 then
        game_scene:addPop("game_team_pk_result_pop",{is_win = 1})
    else
        if self.m_boss_flag > 15 then
            self:createBossAnim(anim_node1,bosshp2,max_hp,{},1)
            self:createBossAnim(anim_node2,bosshp1,max_hp,{},2)
        else
            self:createBossAnim(anim_node1,bosshp1,max_hp,{},1)
            self:createBossAnim(anim_node2,bosshp2,max_hp,{},2)
        end

    end
    self.m_scroll_view:addChild(anim_node1)
    self.m_scroll_view:addChild(anim_node2)
end
--[[--
    初始化
]]
function game_godfield_newFenzheng.init(self,t_params)
    t_params = t_params or {}
    self.m_buildTab = {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.sort = t_params.sort
end
--[[--
    创建ui入口并初始化数据
]]
function game_godfield_newFenzheng.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_godfield_newFenzheng