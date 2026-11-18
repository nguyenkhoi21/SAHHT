--- 组队PK  地图   我的队伍
local game_team_pk_map_team = {
    m_popUi = nil,
    game_data = nil,
    user_post = nil,

    anim_node1 = nil,
    anim_node2 = nil,
    map_node = nil,
    count_down_node = nil,
    btn_change = nil,
    btn_player = nil,
    btn_myteam = nil,
    m_formation_btn = nil,
    btn_battle_log = nil,
    m_auto_time = nil,
    players = nil,
    player_uid = nil,
    m_auto_time = nil,
    open_flag = nil,
    netFlag = nil,
};

--[[--
    销毁
]]
function game_team_pk_map_team.destroy(self)
    -- body
    cclog("-----------------game_team_pk_map_team destroy-----------------");
    self.m_popUi = nil;
    self.game_data = nil;
    self.user_post = nil;

    self.anim_node1 = nil;
    self.anim_node2 = nil;
    self.map_node = nil;
    self.count_down_node = nil;
    self.btn_change = nil;
    self.btn_player = nil;
    self.btn_myteam = nil;
    self.m_formation_btn = nil;
    self.btn_battle_log = nil;
    self.m_auto_time = nil;
    self.players = nil;
    self.player_uid = nil;
    self.m_auto_time = nil;
    self.open_flag = nil;
    self.netFlag = nil;
end
--[[--
    返回
]]
function game_team_pk_map_team.back(self,type)
    -- game_scene:enterGameUi("game_main_scene",{});
    -- self:destroy()
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        local stage = data:getNodeWithKey("stage"):toInt()
        if stage == 4 then--手动选择路线时间
            game_scene:enterGameUi("game_team_pk_map_prepare",{gameData = gameData});
            self:destroy()
        elseif stage == 5 then--自动战斗时间
            game_scene:enterGameUi("game_team_pk_map",{gameData = gameData});
            self:destroy()
        else
            game_scene:setVisibleBroadcastNode(false);
            game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
end
--[[--
    读取ccbi创建ui
]]
function game_team_pk_map_team.createUi(self)
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

        elseif btnTag == 11 then--阵型
            local function responseMethod(tag,gameData)
                if gameData then
                    game_scene:enterGameUi("game_god_adjustment",{gameData = gameData,openType="game_godfield_fenzhengTeam"});
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_upload_god_formation"), http_request_method.GET, nil,"god_field_upload_god_formation",true,true)
            self:destroy();
        elseif btnTag == 101 then--换线
            local function callBack(gameData)
                if gameData then
                    self.game_data = gameData
                    self:refreshUi()
                end
            end
            game_scene:addPop("game_team_pk_select_pop",{callBack = callBack})
        elseif btnTag == 102 then--联盟成员
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local stage = data:getNodeWithKey("stage"):toInt()
                if stage == 1 then--准备阶段
                    game_scene:setVisibleBroadcastNode(false);
                    game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
                    game_util:addMoveTips({text = "Đang chia nhóm"});
                elseif stage == 3 then--分组时间
                    game_scene:setVisibleBroadcastNode(false);
                    game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
                    game_util:addMoveTips({text = "Đang chia nhóm"});
                elseif stage == 4 then--手动选择路线时间
                    self.open_flag = true
                    game_scene:addPop("game_team_pk_battle_list",{gameData = gameData})
                elseif stage == 5 then--自动战斗时间
                    self.open_flag = true
                    game_scene:addPop("game_team_pk_battle_list",{gameData = gameData})
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
        elseif btnTag == 103 then--我的队伍
            -- game_scene:addPop("game_team_pk_select_pop",{})
        elseif btnTag == 500 or btnTag == 501 then--打boss
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_pk_map.ccbi");

    self.anim_node1 = ccbNode:nodeForName("anim_node1")
    self.anim_node2 = ccbNode:nodeForName("anim_node2")
    self.map_node = ccbNode:nodeForName("map_node")
    self.count_down_node = ccbNode:nodeForName("count_down_node")

    local pos = {
        ccp(175,210),
        ccp(230,170),
        ccp(280,120),
    }

    self.btn_change = ccbNode:controlButtonForName("btn_change")
    self.btn_player = ccbNode:controlButtonForName("btn_player")
    self.btn_myteam = ccbNode:controlButtonForName("btn_myteam")
    self.m_formation_btn = ccbNode:controlButtonForName("m_formation_btn")
    self.btn_battle_log = ccbNode:controlButtonForName("btn_battle_log")

    self.m_formation_btn:setVisible(true)
    self.btn_battle_log:setVisible(false)
    self.btn_change:setVisible(true)
    self.btn_player:setVisible(false)
    self.btn_myteam:setVisible(false)

    local fight_btn = ccbNode:controlButtonForName("fight_btn")
    local fight_btn2 = ccbNode:controlButtonForName("fight_btn2")
    fight_btn:setOpacity(0)
    fight_btn2:setOpacity(0)

    return ccbNode;
end
function game_team_pk_map_team.setInfoLabel(self)
    cclog("00:0" .. self.m_auto_time)
end

--[[
    创建pop
]]
function game_team_pk_map_team.createPopScene( self )

end
--[[--
    刷新ui
]]
function game_team_pk_map_team.refreshUi(self)
    self.m_auto_time = 5
    
    local own_boss_hp = self.game_data.own_boss_hp
    local max_boss_hp = self.game_data.boss_max_hp

    local enemy_boss_hp = self.game_data.enemy_boss_hp

    self:createBossAnim(self.anim_node1,own_boss_hp,max_boss_hp)
    self:createBossAnim(self.anim_node2,enemy_boss_hp,max_boss_hp)

    --加一个倒计时，到时间自动跳转
    self.count_down_node:removeAllChildrenWithCleanup(true)
    local function timeEndFunc()
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local stage = data:getNodeWithKey("stage"):toInt()
            if stage == 3 then--手动选择路线时间
                game_scene:enterGameUi("game_team_pk_map_prepare",{gameData = gameData});
            elseif stage == 4 then--自动战斗时间
                game_scene:enterGameUi("game_team_pk_map",{gameData = gameData});
            else
                game_scene:setVisibleBroadcastNode(false);
                local association_id = game_data:getUserStatusDataByKey("association_id");
                if association_id == 0 then
                    require("like_oo.oo_controlBase"):openView("guild_join");
                else
                    require("like_oo.oo_controlBase"):openView("guild");
                end
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
    end
    local countTime = self.game_data.time_count_down
    local countdownLabel = game_util:createCountdownLabel(countTime,timeEndFunc);
    self.count_down_node:addChild(countdownLabel)

    self.map_node:removeAllChildrenWithCleanup(true)
    --加三条路线
    local roarte = {-60,-20,0}
    local scaleY = {-1,1,1}
    local pos = {ccp(66,190),ccp(151,138),ccp(200,86)}
    local spriteName = {"teampk_route2","teampk_route","teampk_route2"}
    for i=1,3 do
        local route = CCSprite:createWithSpriteFrameName(spriteName[i] .. ".png")
        route:setRotation(roarte[i])
        route:setPosition(pos[i])
        route:setScaleY(scaleY[i])
        self.map_node:addChild(route)
        if self.game_data.line_id == i then
            route:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteName[i] .. "_me.png"))
        end
        local num_back = CCSprite:createWithSpriteFrameName("teampk_num_back.png")
        num_back:setPosition(pos[i])
        self.map_node:addChild(num_back)
        --算自己的人数
        if next(self.game_data.own_team) then
            local myTeamNum = self.game_data.own_team[tostring(i)]
            cclog2(myTeamNum,"myTeamNum == ")
            local ownLabel = game_util:createLabelTTF({text = #myTeamNum,color = ccc3(198,33,186),fontSize = 12})
            ownLabel:setPosition(pos[i])
            self.map_node:addChild(ownLabel)
        else
            local myTeamNum = {}
            cclog2(myTeamNum,"myTeamNum == ")
            local ownLabel = game_util:createLabelTTF({text = #myTeamNum,color = ccc3(198,33,186),fontSize = 12})
            ownLabel:setPosition(pos[i])
            self.map_node:addChild(ownLabel)
        end
    end
end
--[[
    创建boss动画
]]
function game_team_pk_map_team.createBossAnim(self,parentNode,boss_hp,max_hp)
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
end
--[[--
    初始化
]]
function game_team_pk_map_team.init(self,t_params)
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
function game_team_pk_map_team.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_team_pk_map_team;