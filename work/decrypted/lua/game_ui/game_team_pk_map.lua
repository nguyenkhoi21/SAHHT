--- 组队PK  地图
local game_team_pk_map = {
    m_popUi = nil,
    game_data = nil,
    m_cityAutoRaidsScheduler = nil,

    user_post = nil,
    players = nil,
    player_uid = nil,
    m_auto_time = nil,
    open_flag = nil,
    netFlag = nil,
    game_data = nil,
    round_count_down_node = nil,
    num_node = nil,
    anim_node1 = nil,
    anim_node2 = nil,
    map_node = nil,
    count_down_node = nil,
    m_formation_btn = nil,
    btn_change = nil,
    btn_player = nil,
    btn_myteam = nil,
    own_ship = nil,
    enemy_ship = nil,
    sprite_alpha = nil,
};

--[[--
    销毁
]]
function game_team_pk_map.destroy(self)
    -- body
    cclog("-----------------game_team_pk_map destroy-----------------");
    self.m_popUi = nil;
    self.game_data = nil;

    if self.m_cityAutoRaidsScheduler then
        scheduler.unschedule(self.m_cityAutoRaidsScheduler)
        self.m_cityAutoRaidsScheduler = nil;
    end

    self.user_post = nil;
    self.players = nil;
    self.player_uid = nil;
    self.m_auto_time = nil;
    self.open_flag = nil;
    self.netFlag = nil;
    self.game_data = nil;
    self.round_count_down_node = nil;
    self.num_node = nil;
    self.anim_node1 = nil;
    self.anim_node2 = nil;
    self.map_node = nil;
    self.count_down_node = nil;
    self.m_formation_btn = nil;
    self.btn_change = nil;
    self.btn_player = nil;
    self.btn_myteam = nil;
    self.own_ship = nil;
    self.enemy_ship = nil;
    self.sprite_alpha = nil;
end
--[[--
    返回
]]
function game_team_pk_map.back(self,type)
    -- game_scene:enterGameUi("game_main_scene",{});
    -- self:destroy()
    game_scene:setVisibleBroadcastNode(false);
    local function responseMethod( tag,gameData )
        game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, {},"team_pk_new_index")
end
--[[--
    读取ccbi创建ui
]]
function game_team_pk_map.createUi(self)
    local ccbNode = luaCCBNode:create();

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 12 then--说明
            -- game_scene:addPop("game_active_limit_detail_pop",{ enterType = "160"})
            game_scene:addPop("game_team_pk_rules_pop",{m_comeInIndex = 0})
        elseif btnTag == 201 then--战报
            local function responseMethod(tag,gameData)
                local function callBackFunc()
                    self.open_flag = false    
                end
                self.open_flag = true
                game_scene:addPop("game_team_pk_battle_result_pop",{gameData = gameData,callBackFunc = callBackFunc})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_see_team_pk_log"), http_request_method.GET, nil,"team_pk_new_see_team_pk_log")
        elseif btnTag == 11 then--阵型
            -- game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_team_pk_map"});
            -- self:destroy();
        elseif btnTag == 101 then--换线
            
        elseif btnTag == 102 then--联盟成员
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local stage = data:getNodeWithKey("stage"):toInt()
                if stage == 4 then--手动选择路线时间
                    self.open_flag = true
                    game_scene:addPop("game_team_pk_battle_list",{gameData = gameData})
                elseif stage == 5 then--自动战斗时间
                    self.open_flag = true
                    game_scene:addPop("game_team_pk_battle_list",{gameData = gameData})
                else
                    local last_win = -1
                    if data:getNodeWithKey("last_win") then
                        last_win = data:getNodeWithKey("last_win"):toInt()
                    end
                    if last_win == 1 or last_win == 0 then
                        --弹提示
                        self:createEndPop(last_win)
                    else
                        game_scene:setVisibleBroadcastNode(false);
                        game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
                    end
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
        elseif btnTag == 103 then--我的队伍
            -- game_scene:addPop("game_team_pk_select_pop",{})
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_team_pk_map_team",{gameData = gameData});
                self:destroy()
            end
            self.netFlag = true
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
        elseif btnTag == 501 then--打boss
            local function responseMethod(tag,gameData)
                self.netFlag = false
                if gameData then
                    local data = gameData:getNodeWithKey("data")
                    self.game_data = json.decode(data:getFormatBuffer()) or {};

                    local boss_hp_hurt = data:getNodeWithKey("boss_hp_hurt")
                    boss_hp_hurt = boss_hp_hurt and boss_hp_hurt:toInt() or 100
                    game_util:addMoveTips({text = "Tấn công tạo\n" .. boss_hp_hurt .. "sát thương cho boss"})

                    self:refreshUi()
                end
            end
            self.netFlag = true
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_team_pk_boss_battle"), http_request_method.GET, nil,"team_pk_new_team_pk_boss_battle",true,true)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_pk_map.ccbi");

    self.anim_node1 = ccbNode:nodeForName("anim_node1")
    self.anim_node2 = ccbNode:nodeForName("anim_node2")
    self.map_node = ccbNode:nodeForName("map_node")
    self.count_down_node = ccbNode:nodeForName("count_down_node")
    self.round_count_down_node = ccbNode:nodeForName("round_count_down_node")
    self.tips_label = ccbNode:labelTTFForName("tips_label")
    self.tips_label2 = ccbNode:labelTTFForName("tips_label2")

    self.own_ship = {}
    self.enemy_ship = {}
    self.sprite_alpha = ccbNode:scale9SpriteForName("sprite_alpha")

    self.m_formation_btn = ccbNode:controlButtonForName("m_formation_btn")
    self.m_formation_btn:setVisible(false)

    local pos = {
        ccp(175,210),
        ccp(230,170),
        ccp(280,120),
    }
    self.num_node = {}
    for i=1,3 do
        self.num_node[i] = CCNode:create()
        self.num_node[i]:setPosition(pos[i])
        local attEffect = game_util:createEffectAnim("anim_jiaozhan",1.0,true)
        game_anim:playSection(attEffect,"impact");
        attEffect:setPosition(pos[i])
        self.map_node:addChild(attEffect,10,i)
        self.map_node:addChild(self.num_node[i],11,10+i)
        self.own_ship[i] = ccbNode:spriteForName("sprite_ship" .. i)
        self.enemy_ship[i] = ccbNode:spriteForName("sprite_ship" .. (i+3))
    end

    local fight_btn = ccbNode:controlButtonForName("fight_btn")
    local fight_btn2 = ccbNode:controlButtonForName("fight_btn2")
    fight_btn:setVisible(false)
    fight_btn2:setOpacity(0)

    self.btn_change = ccbNode:controlButtonForName("btn_change")
    self.btn_player = ccbNode:controlButtonForName("btn_player")
    self.btn_myteam = ccbNode:controlButtonForName("btn_myteam")
    local myUid = game_data:getUserStatusDataByKey("uid");
    local captain = self.game_data.own_team.captain or ""
    if captain ~= "" and myUid == self.game_data.own_team.captain then
        self.btn_player:setVisible(true)
    else
        self.btn_player:setVisible(false)
    end
    function tick( dt )
        if self.open_flag == false then
            self:setInfoLabel();
            if self.m_auto_time > 0 then
                self.m_auto_time = self.m_auto_time - 1;
            else
                if self.netFlag == false then
                    self.netFlag = true;
                    local function responseMethod(tag,gameData)
                        self.netFlag = false
                        if gameData then
                            local data = gameData:getNodeWithKey("data")
                            local stage = data:getNodeWithKey("stage"):toInt()
                            if stage == 4 then--手动选择路线时间
                                -- self.game_data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                                -- self:refreshUi()
                                game_scene:enterGameUi("game_team_pk_map_prepare",{gameData = gameData});
                            elseif stage == 5 then--自动战斗时间
                                self.game_data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                                self:refreshUi()

                                local last_win = self.game_data.last_win
                                cclog2(last_win,"last_win === ")
                                if last_win == 1 or last_win == 0 then
                                    --弹提示
                                    self:createEndPop(last_win)
                                end
                            else
                                local last_win = -1
                                if data:getNodeWithKey("last_win") then
                                    last_win = data:getNodeWithKey("last_win"):toInt()
                                end
                                if last_win == 1 or last_win == 0 then
                                    --弹提示
                                    self:createEndPop(last_win)
                                else
                                    game_scene:setVisibleBroadcastNode(false);
                                    game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
                                end
                            end
                        end
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index",false,true)
                end
            end
        end
    end
    self.m_cityAutoRaidsScheduler = scheduler.schedule(tick, 1, false)
    return ccbNode;
end
--[[
    结算
]]
function game_team_pk_map.createEndPop(self,last_win)
    self.open_flag = true
    local is_win = last_win
    game_scene:addPop("game_team_pk_result_pop",{is_win = is_win})
end
function game_team_pk_map.setInfoLabel(self)
    cclog("00:0" .. self.m_auto_time)
end

--[[--
    刷新ui
]]
function game_team_pk_map.refreshUi(self)
    self.m_auto_time = 5
    
    local own_boss_hp = self.game_data.own_boss_hp
    local max_boss_hp = self.game_data.boss_max_hp

    local enemy_boss_hp = self.game_data.enemy_boss_hp

    local own_info = self.game_data.own_info or {}
    local enemy_info = self.game_data.enemy_info or {}
    self:createBossAnim(self.anim_node1,own_boss_hp,max_boss_hp,own_info,1)
    self:createBossAnim(self.anim_node2,enemy_boss_hp,max_boss_hp,enemy_info,2)

    --加一个倒计时，到时间自动跳转
    self.count_down_node:removeAllChildrenWithCleanup(true)
    local function timeEndFunc()
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local stage = data:getNodeWithKey("stage"):toInt()
            if stage == 4 then--手动选择路线时间
                game_scene:enterGameUi("game_team_pk_map_prepare",{gameData = gameData});
            elseif stage == 5 then--自动战斗时间
                --加一个自动弹出战报
                local last_flag = self.game_data.flag
                self.game_data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                local now_flag = self.game_data.flag
                self:refreshUi()
                if last_flag == 2 then--弹战报
                    cclog("-----1-------")
                    self.netFlag = true
                    local function responseMethodLog(tag,gameDataLog)
                        local function callBackFunc()
                            self.open_flag = false    
                            self.netFlag = false
                            self.m_auto_time = 1
                        end
                        self.open_flag = true
                        game_scene:addPop("game_team_pk_battle_result_pop",{gameData = gameDataLog,callBackFunc = callBackFunc})
                    end
                    network.sendHttpRequest(responseMethodLog,game_url.getUrlForKey("team_pk_new_see_team_pk_log"), http_request_method.GET, nil,"team_pk_new_see_team_pk_log")
                end
                local last_win = self.game_data.last_win
                if last_win == 1 or last_win == 0 then
                    --弹提示
                    cclog("-----2-------")
                    self:createEndPop(last_win) 
                end
            else
                local last_win = -1
                if data:getNodeWithKey("last_win") then
                    last_win = data:getNodeWithKey("last_win"):toInt()
                end
                if last_win == 1 or last_win == 0 then
                    --弹提示
                    self:createEndPop(last_win)
                else
                    game_scene:setVisibleBroadcastNode(false);
                    local association_id = game_data:getUserStatusDataByKey("association_id");
                    game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
                end
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
    end
    local countTime = self.game_data.time_count_down
    local countdownLabel = game_util:createCountdownLabel(countTime,timeEndFunc);
    self.count_down_node:addChild(countdownLabel)
    countdownLabel:setColor(ccc3(0,255,84))
    self.tips_label:setString("CD kết thúc event")

    --人数对比
    for i=1,3 do
        --算自己的人数
        local myTeamNum = self.game_data.own_team[tostring(i)]
        self.num_node[i]:removeAllChildrenWithCleanup(true)

        local enemyTeamNum = self.game_data.line_enemy_num[tostring(i)] or 0

        local num_back = CCSprite:createWithSpriteFrameName("teampk_num_back.png")
        local num_back2 = CCSprite:createWithSpriteFrameName("teampk_num_back.png")

        local ownLabel = game_util:createLabelTTF({text = #myTeamNum,color = ccc3(198,33,186),fontSize = 10})

        local enemyLabel = game_util:createLabelTTF({text = enemyTeamNum,color = ccc3(127,224,244),fontSize = 10})

        ownLabel:setPosition(ccp(-30,0))
        num_back:setPosition(ccp(-30,0))
        enemyLabel:setPosition(ccp(30,0))
        num_back2:setPosition(ccp(30,0))
        self.num_node[i]:addChild(num_back)
        self.num_node[i]:addChild(num_back2)
        self.num_node[i]:addChild(ownLabel)
        self.num_node[i]:addChild(enemyLabel)
    end
    self.sprite_alpha:setVisible(true)
    self.round_count_down_node:removeAllChildrenWithCleanup(true)
    if self.game_data.stage == 5 then--第四阶段回合倒计时
        local function timeEndFunc2()
            self.netFlag = true;
            local function responseMethod(tag,gameData)
                self.netFlag = false
                if gameData then
                    local data = gameData:getNodeWithKey("data")
                    local stage = data:getNodeWithKey("stage"):toInt()
                    if stage == 4 then--手动选择路线时间
                        -- self.game_data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                        -- self:refreshUi()
                        game_scene:enterGameUi("game_team_pk_map_prepare",{gameData = gameData});
                    elseif stage == 5 then--自动战斗时间
                        --加一个自动弹出战报
                        local last_flag = self.game_data.flag
                        self.game_data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                        local now_flag = self.game_data.flag
                        self:refreshUi()
                        if last_flag == 2 then--弹战报
                            self.netFlag = true
                            local function responseMethodLog(tag,gameDataLog)
                                local function callBackFunc()
                                    self.open_flag = false    
                                    self.netFlag = false
                                    self.m_auto_time = 1
                                end
                                self.open_flag = true
                                game_scene:addPop("game_team_pk_battle_result_pop",{gameData = gameDataLog,callBackFunc = callBackFunc})
                            end
                            network.sendHttpRequest(responseMethodLog,game_url.getUrlForKey("team_pk_new_see_team_pk_log"), http_request_method.GET, nil,"team_pk_new_see_team_pk_log")
                        end
                        local last_win = self.game_data.last_win
                        if last_win == 1 or last_win == 0 then
                            --弹提示
                            self:createEndPop(last_win)
                        end
                    else
                        local last_win = -1
                        if data:getNodeWithKey("last_win") then
                            last_win = data:getNodeWithKey("last_win"):toInt()
                        end
                        if last_win == 1 or last_win == 0 then
                            --弹提示
                            self:createEndPop(last_win)
                        else
                            game_scene:setVisibleBroadcastNode(false);
                            game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
                        end
                    end
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index",false,true)
        end
        local countTime = self.game_data.round_time or 0
        local countdownLabel = game_util:createCountdownLabel(countTime,timeEndFunc2);
        countdownLabel:setColor(ccc3(0,255,84))
        self.round_count_down_node:addChild(countdownLabel)

        --提示语
        if self.game_data.flag == 1 then--派人阶段
            self.tips_label2:setString("Khởi động vòng" .. self.game_data.round_times)
        elseif self.game_data.flag == 2 then--打人阶段
            self.tips_label2:setString("Đấu Pháo Đài vòng" .. self.game_data.round_times)
        elseif self.game_data.flag == 3 then--打boss阶段    
            self.tips_label2:setString("Đánh boss vòng" .. self.game_data.round_times)
        end    
        self.sprite_alpha:setVisible(true)

        --飞船报废
        if self.game_data.flag == 3 then 
            for i=1,3 do
                self.own_ship[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("team_pk_ship.png"))
                self.enemy_ship[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("team_pk_ship.png"))
                local line_win_team = self.game_data.line_win_team
                local win_team = line_win_team[tostring(i)]
                if win_team and win_team ~= "" then
                    if win_team == self.game_data.team_id then--我方赢
                        -- self.own_ship[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("team_pk_ship.png"))
                        self.enemy_ship[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("team_pk_broken.png"))
                    else
                        self.own_ship[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("team_pk_broken.png"))
                        -- self.enemy_ship[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("team_pk_ship.png"))
                    end
                end
            end
        else
            for i=1,3 do
                self.own_ship[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("team_pk_ship.png"))
                self.enemy_ship[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("team_pk_ship.png"))
                -- local line_win_team = self.game_data.line_win_team
                -- local win_team = line_win_team[tostring(i)]
                -- if win_team and win_team ~= "" then
                --     if win_team == self.game_data.team_id then--我方赢
                --         -- self.own_ship[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("team_pk_ship.png"))
                --         self.enemy_ship[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("team_pk_broken.png"))
                --     else
                --         self.own_ship[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("team_pk_broken.png"))
                --         -- self.enemy_ship[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("team_pk_ship.png"))
                --     end
                -- end
            end
        end
    elseif self.game_data.stage == 6 then--展示阶段
        local last_win = self.game_data.last_win
        if last_win == 1 or last_win == 0 then
            self:createEndPop(last_win)
        end
    end
end
--[[
    创建boss动画
]]
function game_team_pk_map.createBossAnim(self,parentNode,boss_hp,max_hp,info,infoType)
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

    parentNode:addChild(boss_node)
    parentNode:addChild(hpSprite)
    parentNode:addChild(bar)
    parentNode:addChild(hpLabel)

    --加对战双方的名字
    if info.server and info.guild_name then
        local infoLabel = game_util:createLabelTTF({text = info.server .. " - " .. info.guild_name,color = ccc3(255,216,0)})
        local selectBg = CCSprite:createWithSpriteFrameName("public_selectBg.png")
        if infoType == 1 then
            infoLabel:setPosition(ccp(0,-48))
            selectBg:setPosition(ccp(0,-48))
        else
            infoLabel:setPosition(ccp(0,45))
            selectBg:setPosition(ccp(0,45))
        end
        parentNode:addChild(selectBg)
        parentNode:addChild(infoLabel)
    end
end
--[[--
    初始化
]]
function game_team_pk_map.init(self,t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_team_pk.plist");
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.game_data = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
        -- cclog("self.game_data = " .. json.encode(self.game_data))
    end
    -- self.user_post = t_params.user_post
    -- self.players = t_params.players
    -- self.player_uid = t_params.player_uid
    -- local allData = game_data:getGuildData()
    -- local players = allData.player
    -- local player_uid = allData.guild.player
    -- local myUid = game_data:getUserStatusDataByKey("uid");
    -- local user_post = players[tostring(myUid)].title
    -- self.user_post = user_post
    -- self.players = players
    -- self.player_uid = player_uid
    self.m_auto_time = 5
    self.open_flag = false
    self.netFlag = false
end

--[[--
    创建ui入口并初始化数据
]]
function game_team_pk_map.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_team_pk_map;