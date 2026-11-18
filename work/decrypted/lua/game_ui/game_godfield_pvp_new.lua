--- 新神域竞技场  

local game_godfield_pvp_new = {
    m_tGameData = nil,
    m_close_btn = nil,
    m_ccbNode = nil,
    my_level_icon = nil,
    m_reward_list_node_1 = nil,
    m_my_rank_lab = nil,
    m_hero_icon_1 = nil,
    m_hero_icon_2 = nil,
    m_hero_icon_3 = nil,
    m_pipei_lab_1 = nil,
    m_pipei_lab_2 = nil,
    m_pipei_lab_3 = nil,
    m_hero_name_lab1 = nil,
    m_hero_name_lab2 = nil,
    m_hero_name_lab3 = nil,
    m_hero_zhanli1 = nil,
    m_hero_zhanli2 = nil,
    m_hero_zhanli3 = nil,
    m_shengyu_lab = nil,
    m_enmy_battle_lab = nil,
    m_shop_btn = nil,
    m_rank_btn = nil,
    m_battle_info_btn = nil,
    m_rule_btn = nil,
    m_xiuxian_btn = nil,
    m_jingji_btn = nil,
    m_jinji_btn = nil,
    hero_name_tab = nil,
    hero_battle_tab = nil,
    hero_icon_tab = nil,
    enemy_info = nil,
    enemy_index = nil,
    battle_flag = nil,
    m_jifen_lab = nil,
    m_num_lab = nil,
    m_coin_sp = nil,
    btnFlag = nil,
};
--[[--
    销毁
]]
function game_godfield_pvp_new.destroy(self)
    -- body
    cclog("-----------------game_godfield_pvp_new destroy-----------------");
    self.m_tGameData = nil;
    self.m_close_btn = nil;
    self.m_ccbNode = nil;
    self.my_level_icon = nil;
    self.m_reward_list_node_1 = nil;
    self.m_my_rank_lab = nil;
    self.m_hero_icon_1 = nil;
    self.m_hero_icon_2 = nil;
    self.m_hero_icon_3 = nil;
    self.m_pipei_lab_1 = nil;
    self.m_pipei_lab_2 = nil;
    self.m_pipei_lab_3 = nil;
    self.m_hero_name_lab1 = nil;
    self.m_hero_name_lab2 = nil;
    self.m_hero_name_lab3 = nil;
    self.m_hero_zhanli1 = nil;
    self.m_hero_zhanli2 = nil;
    self.m_hero_zhanli3 = nil;
    self.m_shengyu_lab = nil;
    self.m_enmy_battle_lab = nil;
    self.m_shop_btn = nil;
    self.m_rank_btn = nil;
    self.m_battle_info_btn = nil;
    self.m_rule_btn = nil;
    self.m_xiuxian_btn = nil;
    self.m_jingji_btn = nil;
    self.m_jinji_btn = nil;
    self.hero_name_tab = {};
    self.hero_battle_tab = {};
    self.hero_icon_tab = {};
    self.enemy_info = {};
    self.enemy_index = nil;
    self.battle_flag = nil;
    self.m_jifen_lab = nil;
    self.m_num_lab = nil;
    self.m_coin_sp = nil;
    self.btnFlag = nil;
end
--[[--
    返回
]]
function game_godfield_pvp_new.back(self,type)
   local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_godfield_mainBig",{gameData = gameData})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_pvp_new.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            if self.m_shared then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared);
            end
            self:back();
        elseif btnTag > 10 and btnTag < 20 then
            if btnTag == 14 then
                local function responseMethod( tag,gameData )
                    game_scene:enterGameUi("game_godfield_pvp_new_hero",{gameData = gameData})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_hero_rank"), http_request_method.GET, nil,"universe_arena_hero_rank")
            else
                local function responseMethod( tag,gameData )
                    game_scene:enterGameUi("game_godfield_pvp_new_sec",{gameData = gameData,enterType = btnTag - 10})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_team_index"), http_request_method.GET, {team_id = btnTag - 10},"universe_arena_team_index")
            end
        elseif btnTag == 25 then --兑换
            local function responseMethod( tag,gameData )
                game_scene:addPop("game_godfield_pvp_new_shop",{gameData = gameData,enterType = 1})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_shop_index"), http_request_method.GET, {team_id = 1},"universe_arena_shop_index")
        elseif btnTag == 24 then --阵型
            local function responseMethod( tag,gameData )
                game_scene:enterGameUi("game_godfield_pvp_new_adjust",{gameData = gameData,enterType = "game_godfield_pvp_new",enterIndex = 1,team_index = 1})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_upload_god_formation"), http_request_method.GET, nil,"universe_arena_upload_god_formation")
 
        elseif btnTag == 23 then --排行
            local function responseMethod( tag,gameData )
                game_scene:addPop("game_godfield_pvp_new_rank",{gameData = gameData,enterType = 1})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_get_rank_info"), http_request_method.GET, nil,"universe_arena_get_rank_info")
        elseif btnTag == 22 then --战报
            local function responseMethod( tag,gameData )
                game_scene:addPop("game_godfield_pvp_new_battleMsg",{gameData = gameData,enterType = 1})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_get_battle_tips"), http_request_method.GET, {team_id = 1},"universe_arena_get_battle_tips")
        elseif btnTag == 21 then --说明
            game_scene:addPop("game_godfield_public_detail",{enterType = 192})

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_Arena_new.ccbi");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/god_pvp.plist");
    self.m_close_btn = ccbNode:controlButtonForName("m_back_btn");

    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end



function game_godfield_pvp_new:addAnim(tempSp)
    local animArr = CCArray:create();
    animArr:addObject(CCFadeTo:create(1,70))
    animArr:addObject(CCFadeTo:create(1,255))
    tempSp:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
end
function game_godfield_pvp_new:addAnim1(tempSp)
    local animArr = CCArray:create();
    animArr:addObject(CCFadeTo:create(1,200))
    animArr:addObject(CCFadeTo:create(1,50))
    animArr:addObject(CCFadeTo:create(1,255))
    tempSp:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
end
function game_godfield_pvp_new:addAnim2(tempSp)
    local animArr = CCArray:create();
    animArr:addObject(CCFadeTo:create(1,100))
    animArr:addObject(CCFadeTo:create(1,255))
    animArr:addObject(CCFadeTo:create(1,200))
    tempSp:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
end



function game_godfield_pvp_new.refreshUi( self )
    -- body  
    if not self.m_tGameData.all_rank or self.m_tGameData.all_rank == 0 then
        self.m_ccbNode:nodeForName("m_myAllRank_node"):setVisible(false)
    else
        self.m_ccbNode:nodeForName("m_myAllRank_node"):setVisible(true)
        self.m_ccbNode:labelTTFForName("m_my_all_lb"):setString(self.m_tGameData.all_rank)
    end
    if not self.m_tGameData.history_rank or self.m_tGameData.history_rank == 0  then
        self.m_ccbNode:nodeForName("m_myBestRank"):setVisible(false)
    else
        self.m_ccbNode:nodeForName("m_myBestRank"):setVisible(true)
        self.m_ccbNode:labelTTFForName("m_my_best_lb"):setString(self.m_tGameData.history_rank)
    end
    local occupant = self.m_tGameData.occupant
    local team_ranks = self.m_tGameData.team_ranks
    for i=1,3 do
        local tempData = occupant[tostring(i)]
        if tempData.name and tempData.u_id then
            self.m_ccbNode:nodeForName("m_first_node" .. i):setVisible(true)
            self.m_ccbNode:labelTTFForName("m_lb_name" .. i):setString(tempData.name)
        else
            self.m_ccbNode:nodeForName("m_first_node" .. i):setVisible(false)
        end
        local temp_rank = team_ranks[tostring(i)] or "无"
        self.m_ccbNode:labelTTFForName("m_my_rank" .. i):setString(temp_rank)
    end

end




--[[--
    初始化
]]
function game_godfield_pvp_new.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.enemy_info = {}
    self.battle_flag = false;
    self.btnFlag = false;
    
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_pvp_new.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_godfield_pvp_new;