--- 敌人
local game_league_enemy_pop = {
    m_popUi = nil,
    m_root_layer = nil,

    name_label = nil,
    level_label = nil,
    arena_label = nil,
    guild_label = nil,
    m_anim_node = nil,

    gameData = nil,
    win_tips_label = nil,
    enemy_info_node = nil,
    m_combat_label = nil,

    btn_continue = nil,

    tips_label = nil,
    jifen_node = nil,
    enterType = nil,
};

--[[--
    销毁
]]
function game_league_enemy_pop.destroy(self)
    -- body
    cclog("-----------------game_league_enemy_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;

    self.name_label = nil;
    self.level_label = nil;
    self.arena_label = nil;
    self.guild_label = nil;
    self.m_anim_node = nil;

    self.gameData = nil;

    self.win_tips_label = nil;
    self.enemy_info_node = nil;
    self.m_combat_label = nil;
    ---------
    self.btn_continue = nil;

    self.tips_label = nil;
    self.jifen_node = nil;
    self.enterType = nil;
end

--[[--
    返回
]]
function game_league_enemy_pop.back(self,type)
    game_scene:removePopByName("game_league_enemy_pop")
end
--[[--
    读取ccbi创建ui
]]
function game_league_enemy_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then--战斗
            local function responseMethod(tag,gameData)
                game_data:setBattleType("game_league_main");
                local data = gameData:getNodeWithKey("data")
                local stageTableData = {name = "Vòng đấu đỉnh cao",step = 1,totalStep = 1} --巅峰联赛
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData,stageTableData=stageTableData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_battle"), http_request_method.GET, {uid = self.gameData.uid},"world_one_battle")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_league_enemy_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    self.btn_continue = ccbNode:controlButtonForName("btn_continue")
    self.btn_continue:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    self.name_label = ccbNode:labelTTFForName("name_label")
    self.level_label = ccbNode:labelTTFForName("level_label")
    self.arena_label = ccbNode:labelTTFForName("arena_label")
    self.guild_label = ccbNode:labelTTFForName("guild_label")

    self.enemy_info_node = ccbNode:nodeForName("enemy_info_node")

    self.m_combat_label = ccbNode:labelBMFontForName("m_combat_label")

    self.tips_label = ccbNode:labelTTFForName("tips_label")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_anim_node:removeAllChildrenWithCleanup(true)
    self.jifen_node = ccbNode:nodeForName("jifen_node")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_league_enemy_pop.refreshUi(self)
    self:initTeamFormation(self.enemy_info_node);

    self.name_label:setString(self.gameData.name)
    self.level_label:setString(self.gameData.level)
    self.m_combat_label:setString(self.gameData.combat)
    self.m_anim_node:removeAllChildrenWithCleanup(true)
    local big_img = game_util:createPlayerBigImgByRoleId(tonumber(self.gameData.role));
    if big_img then
        self.m_anim_node:addChild(big_img);
        self.m_anim_node:setScale(0.45);
    end
    self.arena_label:setString(self.gameData.rank)
    self.guild_label:setString(self.gameData.win_times)
    if self.enterType == "game_league_rank" then
        self.btn_continue:setVisible(false)
    else
        self.btn_continue:setVisible(true)
    end
end
--[[
    初始化阵型
]]
function game_league_enemy_pop.initTeamFormation(self,parentNode)
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemData = self.gameData.alignment_info[btnTag];
        if itemData then
            game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 3})
        end
    end
    self.enemy_info_node:removeAllChildrenWithCleanup(true)
    local nodeSize = self.enemy_info_node:getContentSize()
    local itemId = nil;
    local itemData = nil;
    local itemIcon = nil;
    local headIconSpr = nil;
    local character_detail_cfg = getConfig("character_detail");
    local dw = nodeSize.width / #self.gameData.alignment_info
    local dx = dw / 2
    for i=1,math.min(5,#self.gameData.alignment_info) do
        itemData = self.gameData.alignment_info[i];
        if itemData and itemData.c_id then
            heroCfg = character_detail_cfg:getNodeWithKey(itemData.c_id);
            if itemData and heroCfg then
                headIconSpr = game_util:createCardIconByCfg(heroCfg,itemData);
                if headIconSpr then
                    headIconSpr:setScale(0.8);
                    headIconSpr:setPosition(ccp(dx + (i-1)*dw,27));
                    self.enemy_info_node:addChild(headIconSpr,1,1);

                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                    button:setTag(i)
                    button:setOpacity(0)
                    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition(ccp(dx + (i-1)*dw,27))
                    self.enemy_info_node:addChild(button);
                end
            end
        end
    end
end
--[[--
    初始化
]]
function game_league_enemy_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.gameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.gameData = {};
    end
    self.enterType = t_params.enterType
end

--[[--
    创建ui入口并初始化数据
]]
function game_league_enemy_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_league_enemy_pop;