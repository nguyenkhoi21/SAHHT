---  上半场战斗
local game_goefield_teamBoss = {
    m_tGameData = nil,
    m_cityAutoRaidsScheduler = nil,
    m_ccbNode = nil,
    map_node = nil,
    active_node = nil,
    active_time_label = nil,
    time_label = nil,
    boss_hp_label = nil,
    m_auto_time = nil,
    boss_node = nil,
    hp_bar_node = nil,
    boss_hp_label = nil,
    active_node = nil,
    active_node2 = nil,
    action_flag = nil,--购买行动力flag
    relive_flag = nil,--购买复活flag
    m_rank_node = nil,
    m_btn_jiasu = nil,
    m_open_btn = nil,
};
local autoRefreshTime = 5
--[[--
    销毁
]]
function game_goefield_teamBoss.destroy(self)
    cclog("-----------------game_goefield_teamBoss destroy-----------------");
    if self.m_cityAutoRaidsScheduler then
        scheduler.unschedule(self.m_cityAutoRaidsScheduler)
        self.m_cityAutoRaidsScheduler = nil;
    end
    self.m_tGameData = nil;
    self.m_ccbNode = nil;
    self.map_node = nil;
    self.active_node = nil;
    self.active_time_label = nil;
    self.time_label = nil;
    self.boss_hp_label = nil;
    self.m_auto_time = nil;
    self.boss_node = nil;
    self.hp_bar_node = nil;
    self.boss_hp_label = nil;
    self.active_node = nil;
    self.active_node2 = nil;
    self.action_flag = nil;--购买行动力flag
    self.relive_flag = nil;--购买复活flag
    self.m_rank_node = nil;
    self.m_btn_jiasu = nil;
    self.m_open_btn = nil;
end
--[[--
    返回
]]
function game_goefield_teamBoss.back(self,type)
    local function responseMethod( tag,gameData )
        game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")

end
--[[--
    读取ccbi创建ui
]]
function game_goefield_teamBoss.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag --- ")
        if btnTag == 12 then --返回
            self:back();
        elseif btnTag == 11 then --阵型
            local function responseMethod( tag,gameData )
                local formation = self.m_tGameData.team_pk_formation
                game_scene:addPop("game_godfield_fenzhengzhenxing_pop",{gameData = gameData,formation = formation,openType = "godfield_teamboss"});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_upload_god_formation"), http_request_method.GET, nil,"god_field_upload_god_formation")
        elseif btnTag == 13 then --刷新界面
            local function responseMethod( tag,gameData )
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local data = gameData:getNodeWithKey("data");
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    self:refreshUi()
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
        elseif btnTag == 100 then--弹出弹板
            -- local function responseMethod(tag,gameData)
                local function callBackFunc()
                    self.m_rank_node:setVisible(true)
                    self.open_flag = false
                end
                self.m_rank_node:setVisible(false)
                self.open_flag = true
                game_scene:addPop("game_godfield_fenzhengxiagu_rank",{gameData = self.m_tGameData,callBackFunc = callBackFunc})
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_show_log"), http_request_method.GET, nil,"guild_gvg_show_log")
        elseif btnTag == 201 then--战报
            local function callBackFunc()
               self.open_flag = false
            end
            self.open_flag = true
            game_scene:addPop("game_team_boss_log",{gameData = self.m_tGameData,callBackFunc = callBackFunc})
        -- elseif btnTag == 11 then--阵型
        --     game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_goefield_teamBoss"});
        --     self:destroy();
        elseif btnTag == 999 then--买活
            local function responseMethod( tag,gameData )
                self.netFlag = false;
                -- game_util:closeAlertView();
                if gameData then
                    game_util:closeAlertView();
                    local data = gameData:getNodeWithKey("data")
                    -- cclog2(data,"data")
                    if tolua.type(data) == "util_json" then
                        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    else
                        self.m_tGameData = {};
                    end
                    self.teamInfoData = self.m_tGameData.all_position
                    self:refreshUi()
                else
                    local function responseMethod( tag,gameData )
                        local data = gameData:getNodeWithKey("data")
                        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                        self.teamInfoData = self.m_tGameData.all_position
                        self:refreshUi()
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
                    self.m_auto_time = 5
                end
            end
            local canBuy,payMoney = game_util:getCostCoinBuyTimes(30)
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    self.netFlag = true
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_team_relive_time"), http_request_method.GET, nil,"team_pk_new_team_relive_time",true,true)
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = "Tốn" .. payMoney .. "Xu phục hồi?",      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            game_util:openAlertView(t_params)
        elseif btnTag == 1000 then--买行动力
            local function responseMethod( tag,gameData )
                self.netFlag = false;
                if gameData then
                    game_util:closeAlertView();
                    local data = gameData:getNodeWithKey("data")
                    -- cclog2(data,"data")
                    if tolua.type(data) == "util_json" then
                        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    else
                        self.m_tGameData = {};
                    end
                    self.teamInfoData = self.m_tGameData.all_position
                    self:refreshUi()
                else
                    local function responseMethod( tag,gameData )
                        local data = gameData:getNodeWithKey("data")
                        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                        self.teamInfoData = self.m_tGameData.all_position
                        self:refreshUi()
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
                    self.m_auto_time = 5
                end
            end
            local canBuy,payMoney = game_util:getCostCoinBuyTimes(31)
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    self.netFlag = true
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_team_attack_time"), http_request_method.GET, nil,"team_pk_new_team_attack_time",true,true)
                    -- 
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = "Tốn" .. payMoney .. "Xu mua 1 lần hành động?",      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            game_util:openAlertView(t_params)
        elseif btnTag == 555 then--详情
            game_scene:addPop("game_team_pk_rules_pop",{m_comeInIndex = 0})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_godfield_boss_fight.ccbi");
    
    self.m_ccbNode = ccbNode;
    self.map_node = ccbNode:nodeForName("map_node")
    self.active_node = ccbNode:nodeForName("active_node")
    self.active_time_label = ccbNode:labelTTFForName("active_time_label")
    self.time_label = ccbNode:labelTTFForName("time_label")
    self.boss_hp_label = ccbNode:labelTTFForName("boss_hp_label")
    self.boss_node = ccbNode:nodeForName("boss_node")
    self.hp_bar_node = ccbNode:nodeForName("hp_bar_node")
    self.boss_hp_label = ccbNode:labelTTFForName("boss_hp_label")
    self.boss_hp_label:setVisible(false)
    self.active_node = ccbNode:nodeForName("active_node")
    self.active_node2 = ccbNode:nodeForName("active_node2")
    self.active_time_label2 = ccbNode:labelTTFForName("active_time_label2")
    self.m_rank_node = ccbNode:nodeForName("m_rank_node")
    self.m_btn_jiasu = ccbNode:controlButtonForName("btn_jiasu")
    self.m_open_btn = ccbNode:controlButtonForName("m_open_btn")
    self.m_open_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self:createBossAnim()
    return ccbNode;
end
--[[
    战斗地图
]]
function game_goefield_teamBoss.createFightMap(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_team_boss.plist");
    -- self.map_node:removeAllChildrenWithCleanup(true)
    self.m_open_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-20)
    local teamData = {}
    for k,v in pairs(self.teamInfoData) do
        table.insert( teamData, v )
    end
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag == " .. btnTag)
        local function responseMethod(tag,gameData)
            game_util:closeAlertView();
            if gameData then
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                if self.m_tGameData.is_win == 0 then
                    game_util:addMoveTips({text = " Chưa chiếm chỗ này "})
                else
                    game_util:addMoveTips({text = " Đã chiếm được chỗ này "})
                end
                self.teamInfoData = self.m_tGameData.all_position
                self:refreshUi()
            else
                local function responseMethod( tag,gameData )
                    local data = gameData:getNodeWithKey("data")
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    self.teamInfoData = self.m_tGameData.all_position
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
            end
            --弹
        end
        --判断不是自己的队伍才能打
        local uid = game_data:getUserStatusDataByKey("uid")
        local itemData = self.teamInfoData[tostring(btnTag)]
        local params = {}
        params.sort = btnTag
            if self.relive_flag == true then
                game_util:addMoveTips({text = "Đội của bạn đã tử vong, đợi phục hồi!"})
            else
                local mytext = ""
                if itemData then
                    mytext = "Lực chiến của đội này còn" .. itemData.combat .. "\ntấn công chứ?"
                else
                    mytext = "Chiếm chỗ này chứ?"
                end 

                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_select_position"), http_request_method.GET, params,"team_pk_new_select_position")
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,       --可缺省
                    cancelBtnText = string_config.m_btn_cancel,
                    text = mytext, 
                    onlyOneBtn = false,
                    touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                }
                game_util:openAlertView(t_params)
            end
    end
    for i=1,15 do
        local bossShip = CCSprite:createWithSpriteFrameName("team_boss_ship2.png")
        local posX = 10 + 70 * ((i - 1) % 8)
        if i < 8 then
            posX = 40 + 70 * ((i - 1) % 8)
        end
        local posY = 162 - 64 * (math.floor((i-1) / 7))
        if i > 8 then
            posY = 162 - 64 * (math.floor((i-1) / 8))
        end
        -- if i == 15 then
        --     posX = 250 
        -- end
        bossShip:setScale(0.6)
        bossShip:setPosition(ccp(posX,posY))
        self.map_node:addChild(bossShip,10,100 + i)

        local name = ""
        local countdown = ""
        if i <= 15 then
            local itemData = {}
            if self.teamInfoData[tostring(i)] then
                itemData = self.teamInfoData[tostring(i)]
                name = self.teamInfoData[tostring(i)].name
            end

            local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
            button:setPosition(ccp(posX,posY))
            button:setOpacity(0)
            -- button:setAnchorPoint(ccp(0,0))
            button:setPreferredSize(CCSizeMake(42,52))
            self.map_node:addChild(button,11)
            button:setTag(i)

            --加自己队伍标识
            local uid = game_data:getUserStatusDataByKey("uid")
            local is_my_team = false
            local team_player = itemData.uid
            --for i=1,5 do
               -- local player_info = team_player[tostring(i)]
                if team_player then
                    --local play_uid = player_info.play_uid
                    if team_player == uid then
                        is_my_team = true
                    else
                        is_my_team = false
                    end
                end
            --end
            if is_my_team then
                local spriteTip = CCSprite:createWithSpriteFrameName("gvg_select1.png")
                spriteTip:setPosition(ccp(bossShip:getContentSize().width*0.5,bossShip:getContentSize().height+1))
                bossShip:addChild(spriteTip,100)
                local animArr = CCArray:create();
                animArr:addObject(CCMoveTo:create(1,ccp(bossShip:getContentSize().width*0.5, bossShip:getContentSize().height+5)))
                animArr:addObject(CCMoveTo:create(1,ccp(bossShip:getContentSize().width*0.5, bossShip:getContentSize().height+1)))
                spriteTip:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
            end
        end
        local alphaBack = CCScale9Sprite:createWithSpriteFrameName("public_selectBg.png")
        alphaBack:setPreferredSize(CCSizeMake(90,25))
        alphaBack:setPosition(posX,posY-30)
        alphaBack:setOpacity(210)
        self.map_node:addChild(alphaBack,10)        

        local nameLabel = game_util:createLabelTTF({text = name,fontSize = 10})
        nameLabel:setPosition(posX,posY-25)
        self.map_node:addChild(nameLabel,10)                

        local timeLabel = game_util:createLabelTTF({text = countdown,fontSize = 10})
        timeLabel:setColor(ccc3(208,190,70))
        timeLabel:setPosition(posX-20,posY-35)
        self.map_node:addChild(timeLabel,10)
    end 
end
--[[
    创建boss动画
]]--
function game_goefield_teamBoss.createBossAnim(self)
    local function onBtnCilck( event,target )
        local function responseMethod(tag,gameData)
            -- game_data:setBattleType("team_boss");
            -- local stageTableData = {name = "组队boss",step = 1,totalStep = 1}
            -- --传背景图
            -- local imgName = "back_world_boss"
            -- cclog("imgName = "..imgName);
            -- game_scene:enterGameUi("game_battle_scene",{gameData = gameData,stageTableData=stageTableData,backGroundName=imgName});
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_boss_index"), http_request_method.GET, nil,"world_boss_index")
            
            --不进入战斗，只弹伤害
            self.netFlag = false
            if gameData then

                local data = gameData:getNodeWithKey("data")
                data = json.decode(data:getFormatBuffer()) or {};
                self.m_tGameData = data
                local hurt = data.hurt
                game_util:addMoveTips({text = " Bạn đã tạo" .. hurt .. "điểm sát thương cho boss"})
                self.teamInfoData = self.m_tGameData.all_position
                self:refreshUi()
            else
                local function responseMethod( tag,gameData )
                    local data = gameData:getNodeWithKey("data")
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    self.teamInfoData = self.m_tGameData.all_position
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
                self.m_auto_time = 5
            end
        end
        --判断不是自己的队伍才能打
        -- local team_id = self.m_tGameData.team_id
        local params = {}
        -- params.sort = 1
        -- params.team_id = team_id
        if self.action_flag == true then
            game_util:addMoveTips({text = "Đội đã dùng hết hành động, tấn công sau!"})
        else
            self.netFlag = true
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_battle_boss"), http_request_method.GET, params,"team_pk_new_battle_boss",true,true)
        end
    end

    local bossPos = {0,0}
    local anim_node = game_util:createIdelAnim("kuba",0)
    anim_node:setAnchorPoint(ccp(0.5,0.5))
    anim_node:setPosition(ccp(bossPos[1],bossPos[2]));

    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
    button:setPosition(ccp(bossPos[1],bossPos[2]+50))
    button:setOpacity(0)
    -- button:setAnchorPoint(ccp(0,0))
    button:setPreferredSize(CCSizeMake(100,80))
    self.boss_node:addChild(button)

    self.boss_node:addChild(anim_node,10)
    local anim_tip = game_util:createEffectAnim("anim_fight_index",1,true)
    anim_tip:setAnchorPoint(ccp(0.5,0.5))
    anim_tip:setPosition(ccp(bossPos[1]-50,bossPos[2]-25))
    self.boss_node:addChild(anim_tip,11,11)
end
--[[--
    刷新ui
]]
function game_goefield_teamBoss.refreshUi(self)
    self.m_auto_time = 5
    self.map_node:removeAllChildrenWithCleanup(true)
    self:createFightMap()

    --倒计时回调函数
    local function timeEndFunc(label,type)
        game_util:addMoveTips({text = "Test sát thương kết thúc, đợi kết quả"})
        local function responseMethod( tag,gameData )
            game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, {},"team_pk_new_index")

    end
    --取时间去倒计时   活动结束
    local expire = self.m_tGameData.time_count_down
    self.time_label:setString("")
    local countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8);
    countdownLabel:setPosition(ccp(countdownLabel:getContentSize().width*0.5,self.time_label:getContentSize().height*0.5))
    if self.time_label ~= nil then
        self.time_label:removeAllChildrenWithCleanup(true)
    end
    self.time_label:addChild(countdownLabel)
    countdownLabel:setTime(expire);

    -- --复活倒计时
    -- local function timeActiveEndFunc(label,type)
    --     self.relive_flag = false
    -- end
    -- --复活时间
    -- self.active_time_label:setString("")
    -- local cdLabel = game_util:createCountdownLabel(0,timeActiveEndFunc,8);
    -- cdLabel:setPosition(ccp(cdLabel:getContentSize().width*0.5,self.active_time_label:getContentSize().height*0.5))
    -- if self.active_time_label ~= nil then
    --     self.active_time_label:removeAllChildrenWithCleanup(true)
    -- end
    -- self.active_time_label:addChild(cdLabel)
    -- local active_cd = self.m_tGameData.relive_count_down
    -- -- cclog2(active_cd,"active_cd")
    -- if active_cd > 0 then
    --     self.active_node:setVisible(true)
    --     cdLabel:setTime(active_cd);
    --     self.relive_flag = true
    -- else
    --     self.active_node:setVisible(false)
    --     self.relive_flag = false
    -- end

    --行动力倒计时
    local function timeActiveEndFunc2(label,type)
        self.action_flag = false
        self.active_node2:setVisible(false)

    end
    --行动时间
    self.active_time_label2:setString("")
    local action_time
    if self.m_tGameData.position_id == 0 then
        action_time = self.m_tGameData.pro_count_down --self.teamInfoData[tostring(self.m_tGameData.position_id)].boss_count_down
        self.m_btn_jiasu:setTag(1000)
        -- cclog2(action_time,"action_time1 === ")
    else
        action_time = self.m_tGameData.boss_count_down
        -- cclog2(action_time,"action_time2 === ")
        self.m_btn_jiasu:setTag(999)
    end
    if action_time > 0 then
        local actionLabel = game_util:createCountdownLabel(action_time,timeActiveEndFunc2,8);
        actionLabel:setPosition(ccp(actionLabel:getContentSize().width*0.5,self.active_time_label2:getContentSize().height*0.5))
        if self.active_time_label2 ~= nil then
            self.active_time_label2:removeAllChildrenWithCleanup(true)
        end
        self.active_time_label2:addChild(actionLabel)
        self.active_node2:setVisible(true)
        self.action_flag = true
    else
        self.active_node2:setVisible(false)
        self.action_flag = false
    end
end
function game_goefield_teamBoss.setInfoLabel(self)
    -- self.auto_time_label:setString("00:0" .. self.m_auto_time)
    cclog("00:0" .. self.m_auto_time)
end
--[[--
    初始化
]]
function game_goefield_teamBoss.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.teamInfoData = self.m_tGameData.all_position
    self.m_auto_time = 5;
    self.netFlag = false;
    self.open_flag = false;
    self.action_flag = false
    self.relive_flag = false
end

--[[--
    创建入口
]]
function game_goefield_teamBoss.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    return rootScene;
end
return game_goefield_teamBoss;