--- 新神域竞技场  

local game_godfield_pvp_new_hero = {
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
function game_godfield_pvp_new_hero.destroy(self)
    -- body
    cclog("-----------------game_godfield_pvp_new_hero destroy-----------------");
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
function game_godfield_pvp_new_hero.back(self,type)
    local function responseMethod( tag,gameData )
        game_scene:enterGameUi("game_godfield_pvp_new",{gameData = gameData})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_index"), http_request_method.GET, {},"universe_arena_index")

end
--[[--
    读取ccbi创建ui
]]
function game_godfield_pvp_new_hero.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            if self.m_shared then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared);
            end
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_Arena_new_hero.ccbi");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/god_pvp.plist");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_ccbNode = ccbNode;
    return ccbNode;
end



function game_godfield_pvp_new_hero.refreshUi( self )
    -- body  
    for i=1,6 do
        self.m_ccbNode:labelTTFForName("m_title_" .. i):setString("Hạng " .. self.m_phase .. " Bảng Đấu Trường Vũ Trụ")
    end
    for i=1,3 do
        local info = self.m_hero_listInfo[i] or {}
        local str = info.name or "Không"
        self.m_ccbNode:labelTTFForName("m_name_lb" .. i):setString(str)
    end
end




--[[--
    初始化
]]
function game_godfield_pvp_new_hero.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        cclog2(self.m_tGameData)
    else
        self.m_tGameData = {};
    end
    self.m_hero_listInfo = self.m_tGameData.info or {}
    self.m_phase = self.m_tGameData.phase or 1
    if self.m_phase == 0 or self.m_phase == "0" then
      self.m_phase = 1
    end  
    self.enemy_info = {}
    self.battle_flag = false;
    self.btnFlag = false;
    
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_pvp_new_hero.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_godfield_pvp_new_hero;