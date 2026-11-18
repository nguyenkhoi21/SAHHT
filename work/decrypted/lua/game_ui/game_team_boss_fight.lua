---  上半场战斗
local game_team_boss_fight = {
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
};
local autoRefreshTime = 5
--[[--
    销毁
]]
function game_team_boss_fight.destroy(self)
    cclog("-----------------game_team_boss_fight destroy-----------------");
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
end
--[[--
    返回
]]
function game_team_boss_fight.back(self,type)
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = function (  )
                self:destroy();
            end});
end
--[[--
    读取ccbi创建ui
]]
function game_team_boss_fight.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 12 then --返回
            self:back();
        elseif btnTag == 11 then --阵型
            game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_team_boss_fight"});
            self:destroy();
        elseif btnTag == 100 then--弹出弹板
            -- local function responseMethod(tag,gameData)
                local function callBackFunc()
                   self.open_flag = false
                end
                self.open_flag = true
                game_scene:addPop("game_team_boss_rank",{gameData = self.m_tGameData,callBackFunc = callBackFunc})
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_show_log"), http_request_method.GET, nil,"guild_gvg_show_log")
        elseif btnTag == 201 then--战报
            local function callBackFunc()
               self.open_flag = false
            end
            self.open_flag = true
            game_scene:addPop("game_team_boss_log",{gameData = self.m_tGameData,callBackFunc = callBackFunc})
        elseif btnTag == 11 then--阵型
            game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_team_boss_fight"});
            self:destroy();
        elseif btnTag == 999 then--买活
            local function responseMethod( tag,gameData )
                self.netFlag = false;
                if gameData then
                    local data = gameData:getNodeWithKey("data")
                    -- cclog2(data,"data")
                    if tolua.type(data) == "util_json" then
                        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    else
                        self.m_tGameData = {};
                    end
                    local team_boss_sec_battle = data:getNodeWithKey("team_boss_sec_battle")
                    local rank_result = data:getNodeWithKey("rank_result")
                    local team_boss_all_team = data:getNodeWithKey("team_boss_all_team")
                    if team_boss_sec_battle then
                        self.teamInfoData = self.m_tGameData.team_boss_sec_battle
                        self:refreshUi()
                        game_util:addMoveTips({text = "Hồi sinh thành công!"})--复活成功
                        game_util:closeAlertView()
                    elseif rank_result then--进入捐献界面
                        game_scene:enterGameUi("game_team_boss_donate",{gameData = gameData})   
                        -- self.teamInfoData = self.m_tGameData.team_boss_thd_battle
                    elseif team_boss_all_team then--进入创建队伍界面
                        --再分进入创建队伍，还是直接进入队伍信息
                        local team_id = data:getNodeWithKey("team_id"):toStr()
                        --遍历是否有队伍
                        if team_id == "" or team_id == 0 then
                            game_scene:enterGameUi("game_team_boss_create",{gameData = gameData})
                        else
                            local team_boss_all_teamJson = json.decode(team_boss_all_team:getFormatBuffer()) or {};
                            --直接进入队伍
                            local teamInfo = team_boss_all_teamJson[team_id]
                            game_scene:enterGameUi("game_team_boss_info",{teamInfo = teamInfo,openType = 1})
                        end
                    else--活动已结束，等待
                        game_scene:enterGameUi("game_main_scene",{gameData = nil,  openPop = nil});
                        local msg = data:getNodeWithKey("msg")
                        msg = msg and msg:toStr() or "Thời gian tấn công đã hết, xin đợi trận sau hoặc phát thưởng！" -- 攻击时间已结束，请等待下半场或发奖励
                        self:destroy();
                        game_util:addMoveTips({text = msg})
                    end
                else
                    self.m_auto_time = 5
                end
            end
            local canBuy,payMoney = game_util:getCostCoinBuyTimes(30)
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    self.netFlag = true
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_relive_time"), http_request_method.GET, nil,"team_relive_time",true,true)
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = "Xác nhận dùng" .. payMoney .. "xu hồi sinh",      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            game_util:openAlertView(t_params)
        elseif btnTag == 1000 then--买行动力
            local function responseMethod( tag,gameData )
                self.netFlag = false;
                if gameData then
                    local data = gameData:getNodeWithKey("data")
                    -- cclog2(data,"data")
                    if tolua.type(data) == "util_json" then
                        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    else
                        self.m_tGameData = {};
                    end
                    local team_boss_sec_battle = data:getNodeWithKey("team_boss_sec_battle")
                    local rank_result = data:getNodeWithKey("rank_result")
                    local team_boss_all_team = data:getNodeWithKey("team_boss_all_team")
                    if team_boss_sec_battle then
                        self.teamInfoData = self.m_tGameData.team_boss_sec_battle
                        self:refreshUi()
                        game_util:addMoveTips({text = "Mua điểm hành động thành công!"})--购买行动力成功
                        game_util:closeAlertView()
                    elseif rank_result then--进入捐献界面
                        game_scene:enterGameUi("game_team_boss_donate",{gameData = gameData})   
                    elseif team_boss_all_team then--进入创建队伍界面
                        --再分进入创建队伍，还是直接进入队伍信息
                        local team_id = data:getNodeWithKey("team_id"):toStr()
                        --遍历是否有队伍
                        if team_id == "" or team_id == 0 then
                            game_scene:enterGameUi("game_team_boss_create",{gameData = gameData})
                        else
                            local team_boss_all_teamJson = json.decode(team_boss_all_team:getFormatBuffer()) or {};
                            --直接进入队伍
                            local teamInfo = team_boss_all_teamJson[team_id]
                            game_scene:enterGameUi("game_team_boss_info",{teamInfo = teamInfo,openType = 1})
                        end
                    else--活动已结束，等待
                        game_scene:enterGameUi("game_main_scene",{gameData = nil,  openPop = nil});
                        local msg = data:getNodeWithKey("msg")
                        msg = msg and msg:toStr() or "Thời gian tấn công đã hết, xin đợi trận sau hoặc phát thưởng" --攻击时间已结束，请等待下半场或发奖励！
                        self:destroy();
                        game_util:addMoveTips({text = msg})
                    end
                else
                    self.m_auto_time = 5
                end
            end
            local canBuy,payMoney = game_util:getCostCoinBuyTimes(31)
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    self.netFlag = true
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_attack_time"), http_request_method.GET, nil,"team_attack_time",true,true)
                    -- 
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = "Dùng " .. payMoney .. "Xu mua 1 lần điểm hành động nhé?",      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            game_util:openAlertView(t_params)
        elseif btnTag == 555 then--详情
            game_scene:addPop("game_active_limit_detail_pop",{ enterType = "160"})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_team_boss_fight.ccbi");
    
    self.m_ccbNode = ccbNode;
    self.map_node = ccbNode:nodeForName("map_node")
    self.active_node = ccbNode:nodeForName("active_node")
    self.active_time_label = ccbNode:labelTTFForName("active_time_label")
    self.time_label = ccbNode:labelTTFForName("time_label")
    self.boss_hp_label = ccbNode:labelTTFForName("boss_hp_label")
    self.boss_node = ccbNode:nodeForName("boss_node")
    self.hp_bar_node = ccbNode:nodeForName("hp_bar_node")
    self.boss_hp_label = ccbNode:labelTTFForName("boss_hp_label")
    self.active_node = ccbNode:nodeForName("active_node")
    self.active_node2 = ccbNode:nodeForName("active_node2")
    self.active_time_label2 = ccbNode:labelTTFForName("active_time_label2")

    self:createBossAnim()
    function tick( dt )
        if self.open_flag == false then
            if self.m_auto_time > 0 then
                self:setInfoLabel();
                self.m_auto_time = self.m_auto_time - 1;
            else
                if self.netFlag == false then
                    local function responseMethod(tag,gameData)
                        self.netFlag = false;
                        if gameData then
                            local data = gameData:getNodeWithKey("data")
                            local rank_result = data:getNodeWithKey("rank_result")
                            local team_boss_all_team = data:getNodeWithKey("team_boss_all_team")
                            local team_boss_sec_battle = data:getNodeWithKey("team_boss_sec_battle")
                            local team_boss_thd_battle = data:getNodeWithKey("team_boss_thd_battle")
                                
                            if rank_result then--进入捐献界面
                                game_scene:enterGameUi("game_team_boss_donate",{gameData = gameData})   
                            elseif team_boss_all_team then--进入创建队伍界面
                                --再分进入创建队伍，还是直接进入队伍信息
                                local team_id = data:getNodeWithKey("team_id")
                                team_id = (team_id and team_id:toStr()) or ""
                                --遍历是否有队伍
                                if team_id == "" then
                                    game_scene:enterGameUi("game_team_boss_create",{gameData = gameData})
                                else
                                    local team_boss_all_teamJson = json.decode(team_boss_all_team:getFormatBuffer()) or {};
                                    --直接进入队伍
                                    local teamInfo = team_boss_all_teamJson[team_id]
                                    game_scene:enterGameUi("game_team_boss_info",{teamInfo = teamInfo,openType = 1})
                                end
                            elseif team_boss_sec_battle then
                                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                                self.teamInfoData = self.m_tGameData.team_boss_sec_battle
                                self:refreshUi()
                            elseif team_boss_thd_battle then
                                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                                self.teamInfoData = self.m_tGameData.team_boss_thd_battle
                                self:refreshUi()
                            else        
                                -- game_util:addMoveTips({text = "正在分组，请稍后！"})
                                game_scene:enterGameUi("game_main_scene",{gameData = nil,  openPop = nil});
                                local msg = data:getNodeWithKey("msg")
                                msg = msg and msg:toStr() or "Thời gian tấn công đã hết, xin đợi trận sau hoặc phát thưởng！" --攻击时间已结束，请等待下半场或发奖励
                                self:destroy();
                                game_util:addMoveTips({text = msg})
                            end
                        else
                            self.m_auto_time = 5
                        end
                    end
                    self.netFlag = true
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_index"), http_request_method.GET, nil,"team_boss_index",false,true)
                end
            end
        end
    end
    self.m_cityAutoRaidsScheduler = scheduler.schedule(tick, 1, false)

    return ccbNode;
end
--[[
    战斗地图
]]
function game_team_boss_fight.createFightMap(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_team_boss.plist");
    self.map_node:removeAllChildrenWithCleanup(true)

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
            --弹
            game_scene:addPop("game_team_boss_battle_result",{gameData = gameData})
        end
        --判断不是自己的队伍才能打
        local team_id = self.m_tGameData.team_id
        local itemData = teamData[btnTag]
        local params = {}
        params.sort = 2
        params.team_id = itemData.team_id
        if team_id == itemData.team_id then
            game_util:addMoveTips({text = "Xin đánh đội khác!"})--请攻打其他人的队伍！
        else
            if self.relive_flag == true then
                game_util:addMoveTips({text = "Đội đã bị tiêu diệt, xin chờ hồi sinh!"}) --您的队伍已被摧毁，请等待复活！
            else
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_battle"), http_request_method.GET, params,"team_boss_battle")
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,       --可缺省
                    cancelBtnText = string_config.m_btn_cancel,
                    text = "Đội này có lực chiến" .. itemData.team_combat .. "\n tấn công chứ?",      --可缺省 该队伍的战斗力为  是否攻击该队伍？
                    onlyOneBtn = false,
                    touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                }
                game_util:openAlertView(t_params)
            end
        end
    end
    -- cclog2(teamData,"teamData")

    for i=1,10 do
        local bossShip = CCSprite:createWithSpriteFrameName("team_boss_ship.png")
        local posX = 40 + 100 * ((i - 1) % 5)
        local posY = 162 - 64 * (math.floor((i-1) / 5))
        bossShip:setPosition(ccp(posX,posY))
        self.map_node:addChild(bossShip,10,100 + i)

        local name = ""
        local countdown = ""
        if i <= #teamData then
            local itemData = teamData[i]
            name = itemData.team_name
            countdown = "Thời gian:"-- .. itemData.relive_team_time行动时间:
            --加按钮

            local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
            button:setPosition(ccp(posX,posY))
            button:setOpacity(0)
            -- button:setAnchorPoint(ccp(0,0))
            button:setPreferredSize(CCSizeMake(42,52))
            self.map_node:addChild(button,11)
            button:setTag(i)

            --加特效
            local is_game_over = itemData.is_game_over--队伍是否死亡，1是死亡，0是活着
            if is_game_over == 0 then
                local buildEffect = game_util:createEffectAnim("anim_paodan",1.0,true,delayTime)
                buildEffect:setAnchorPoint(ccp(0.5,0.5))
                buildEffect:setPosition(ccp(bossShip:getContentSize().width*0.5,bossShip:getContentSize().height*0.5))
                bossShip:addChild(buildEffect,100)
            else
                local destroyEffect = game_util:createEffectAnim("anim_gonghui_baozha",1.0,true,delayTime)
                destroyEffect:setAnchorPoint(ccp(0.5,0.5))
                destroyEffect:setPosition(ccp(bossShip:getContentSize().width*0.5,bossShip:getContentSize().height*0.5))
                bossShip:addChild(destroyEffect,100)
            end

            --倒计时
            local countDownNode = CCNode:create()
            local function timeEndFunc()

            end
            local countTime = itemData.relive_count_down or 0
            local countdownLabel = game_util:createCountdownLabel(countTime,timeEndFunc,8,2);
            countDownNode:addChild(countdownLabel)
            countDownNode:setPosition(ccp(posX+20,posY-35))
            self.map_node:addChild(countDownNode,11)

            --五个亮点标志
            local is_attack_times = itemData.is_attack_times or 0
            local starCountq = 5 - is_attack_times
            for i=1,starCountq do 
                local star = CCSprite:createWithSpriteFrameName("team_boss_star.png")
                star:setPosition(ccp(bossShip:getContentSize().width*0.5 - 24 + i * 8,-18))
                bossShip:addChild(star,10,10)
            end

            --加自己队伍标识
            local uid = game_data:getUserStatusDataByKey("uid")
            local is_my_team = false
            local team_player = itemData.team_player
            for i=1,5 do
                local player_info = team_player[tostring(i)]
                if player_info then
                    local play_uid = player_info.play_uid
                    if play_uid == uid then
                        is_my_team = true
                        break
                    end
                end
            end
            if is_my_team then
                local spriteTip = CCSprite:createWithSpriteFrameName("gvg_select1.png")
                spriteTip:setPosition(ccp(bossShip:getContentSize().width*0.5,bossShip:getContentSize().height+10))
                bossShip:addChild(spriteTip,100)
                local animArr = CCArray:create();
                animArr:addObject(CCMoveTo:create(1,ccp(bossShip:getContentSize().width*0.5, bossShip:getContentSize().height+12)))
                animArr:addObject(CCMoveTo:create(1,ccp(bossShip:getContentSize().width*0.5, bossShip:getContentSize().height+8)))
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
function game_team_boss_fight.createBossAnim(self)
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
                local rank_result = data:getNodeWithKey("rank_result")
                local team_boss_all_team = data:getNodeWithKey("team_boss_all_team")
                local team_boss_sec_battle = data:getNodeWithKey("team_boss_sec_battle")
                local team_boss_thd_battle = data:getNodeWithKey("team_boss_thd_battle")
                if rank_result then--进入捐献界面
                    game_scene:enterGameUi("game_team_boss_donate",{gameData = gameData})   
                elseif team_boss_all_team then--进入创建队伍界面
                    --再分进入创建队伍，还是直接进入队伍信息
                    local team_id = data:getNodeWithKey("team_id")
                    team_id = (team_id and team_id:toStr()) or ""
                    --遍历是否有队伍
                    if team_id == "" then
                        game_scene:enterGameUi("game_team_boss_create",{gameData = gameData})
                    else
                        local team_boss_all_teamJson = json.decode(team_boss_all_team:getFormatBuffer()) or {};
                        --直接进入队伍
                        local teamInfo = team_boss_all_teamJson[team_id]
                        game_scene:enterGameUi("game_team_boss_info",{teamInfo = teamInfo,openType = 1})
                    end
                elseif team_boss_sec_battle then
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    self.teamInfoData = self.m_tGameData.team_boss_sec_battle

                    local boss_hp_hurt = data:getNodeWithKey("boss_hp_hurt")
                    boss_hp_hurt = boss_hp_hurt and boss_hp_hurt:toInt() or 100
                    game_util:addMoveTips({text = "Tấn công lần này gây cho boss  \n" .. boss_hp_hurt .. " sát thương"})--本次攻击对boss造成 伤害

                    self:refreshUi()
                elseif team_boss_thd_battle then
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    self.teamInfoData = self.m_tGameData.team_boss_thd_battle
                    self:refreshUi()
                else        
                    -- game_util:addMoveTips({text = "正在分组，请稍后！"})
                    game_scene:enterGameUi("game_main_scene",{gameData = nil,  openPop = nil});
                    local msg = data:getNodeWithKey("msg")
                    msg = msg and msg:toStr() or "Thời gian tấn công đã hết, xin đợi trận sau hoặc phát thưởng "--攻击时间已结束，请等待下半场或发奖励！
                    self:destroy();
                    game_util:addMoveTips({text = msg})
                end
            else
                self.m_auto_time = 5
            end
        end
        --判断不是自己的队伍才能打
        local team_id = self.m_tGameData.team_id
        local params = {}
        params.sort = 1
        params.team_id = team_id
        if self.action_flag == true then
            game_util:addMoveTips({text = "Đang chờ tấn công, xin đợi"})-- 攻击冷却中 请稍后
        else
            self.netFlag = true
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_battle"), http_request_method.GET, params,"team_boss_battle",true,true)
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
function game_team_boss_fight.refreshUi(self)
    self.m_auto_time = 5
    self:createFightMap()

    --血条
    local max_hp = self.m_tGameData.max_boss_hp or 100
    local boss_hp = self.m_tGameData.boss_hp or 100
    self.hp_bar_node:removeAllChildrenWithCleanup(true)
    local bar = ExtProgressTime:createWithFrameName("team_boss_xue.png","team_boss_xue_back.png");
    bar:setMaxValue(max_hp)
    bar:setCurValue(boss_hp,false);
    bar:setAnchorPoint(ccp(0.5,0.5))
    bar:setPosition(ccp(0,0))
    self.hp_bar_node:addChild(bar,10)
    local is_stage = self.m_tGameData.is_stage or 5
    if is_stage == 5 then
        self.boss_hp_label:setString("")
    else
        self.boss_hp_label:setString(boss_hp)
    end

    --倒计时回调函数
    local function timeEndFunc(label,type)

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

    --复活倒计时
    local function timeActiveEndFunc(label,type)
        self.relive_flag = false
    end
    --复活时间
    self.active_time_label:setString("")
    local cdLabel = game_util:createCountdownLabel(0,timeActiveEndFunc,8);
    cdLabel:setPosition(ccp(cdLabel:getContentSize().width*0.5,self.active_time_label:getContentSize().height*0.5))
    if self.active_time_label ~= nil then
        self.active_time_label:removeAllChildrenWithCleanup(true)
    end
    self.active_time_label:addChild(cdLabel)
    local active_cd = self.m_tGameData.relive_count_down
    -- cclog2(active_cd,"active_cd")
    if active_cd > 0 then
        self.active_node:setVisible(true)
        cdLabel:setTime(active_cd);
        self.relive_flag = true
    else
        self.active_node:setVisible(false)
        self.relive_flag = false
    end

    --行动力倒计时
    local function timeActiveEndFunc2(label,type)
        self.action_flag = false
    end
    --行动时间
    self.active_time_label2:setString("")
    local action_time = self.m_tGameData.attack_count_down
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

    --是否弹出结算
    local kill_boss_team = self.m_tGameData.kill_boss_team
    if kill_boss_team then--boss已被打死，弹板显示信息，并发送通知
        if game_util:getTableLen(kill_boss_team) > 0 then
            local kill_boss_rank = self.m_tGameData.kill_boss_rank
            self.open_flag = true
            local t_params = 
            {
                kill_boss_team = kill_boss_team,
                kill_boss_rank = kill_boss_rank,
                kill_boss_hurt = self.m_tGameData.kill_boss_hurt,
                boss_hp = self.m_tGameData.max_boss_hp,
            }
            game_scene:addPop("game_team_boss_result_pop",t_params)
        end
    end
end
function game_team_boss_fight.setInfoLabel(self)
    -- self.auto_time_label:setString("00:0" .. self.m_auto_time)
    cclog("00:0" .. self.m_auto_time)
end
--[[--
    初始化
]]
function game_team_boss_fight.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.stage = t_params.stage
    if self.stage == 2 then
        self.teamInfoData = self.m_tGameData.team_boss_sec_battle
    else
        self.teamInfoData = self.m_tGameData.team_boss_thd_battle
    end
    self.m_auto_time = 5;
    self.netFlag = false;
    self.open_flag = false;
    self.action_flag = false
    self.relive_flag = false
end

--[[--
    创建入口
]]
function game_team_boss_fight.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    return rootScene;
end
return game_team_boss_fight;