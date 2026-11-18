---  虫洞 
-- wormholes_index = "/api/?method=wormholes_field.wormholes_index",           -- 首页
-- wormholes_get_rank = "/api/?method=wormholes_field.get_rank",               -- 排行
-- wormholes_get_sort_cards = "/api/?method=wormholes_field.get_sort_cards",   -- 
-- wormholes_set_sort_field = "/api/?method=wormholes_field.set_sort_field",    

local game_wormhole_main = {
    m_tGameData    = nil,  
    m_ccbNode      = nil,

    m_btn_des      = nil,
    m_btn_reward   = nil,
    m_btn_rank     = nil,
                
    m_node_left    = nil,
    m_node_right   = nil,

    m_btn_item    = {},

    m_selmap_id     = nil,

    m_all_map       ={},
    m_version = nil,
    all_sort = {},
    m_is_battle = nil,
};
--[[--
    销毁
]]
function game_wormhole_main.destroy(self)
    -- body
    cclog("-----------------game_wormhole_main destroy-----------------");

    self.m_tGameData    = nil;
    self.m_ccbNode      = nil;

    self.m_btn_des      = nil;
    self.m_btn_reward   = nil;
    self.m_btn_rank     = nil;

    self.m_node_left    = nil;
    self.m_node_right   = nil;

    self.m_btn_item    = nil;


    self.m_selmap_id     = nil;
    self.m_all_map       =nil;
    self.m_version      = nil;
    self.all_sort       = nil;

    self.m_is_battle = nil;
end
--[[--
    返回
]]
function game_wormhole_main.back(self,backType)
    self:destroy();
    game_scene:enterGameUi("game_main_scene");
end
--[[--
    读取ccbi创建ui
]]
function game_wormhole_main.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 99999 then
            self:back("back");
        elseif btnTag == 201 then
            game_scene:addPop("game_active_limit_detail_pop",{enterType = "201",openType = "wormhole"})
        elseif btnTag == 202 then
            game_scene:addPop("game_wormhole_rewards",{version = self.m_version,all_sort = self.all_sort})
        elseif btnTag == 203 then
            local function responseMethod( tag,gameData )
                local data = gameData:getNodeWithKey("data");
                data = json.decode(data:getFormatBuffer()) or {}
                game_scene:addPop("game_wormhole_ranks",{gameData = data,all_sort = self.all_sort})
            end
            local params = {}
            params.sort = self.m_all_map[1].id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_get_rank"), http_request_method.GET, params,"wormholes_get_rank")
        elseif btnTag == 101 or btnTag == 102 or btnTag == 103 or btnTag == 104 then
            local temp = self.m_all_map[tonumber(btnTag) - 100]
            if temp.isfirst == 0 then
                local function responseMethod( tag,gameData )
                    local data = gameData:getNodeWithKey("data");
                    data = json.decode(data:getFormatBuffer()) or {}
                    game_scene:enterGameUi("game_wormhole_adjustment_formation",{gameData = data,opentype = "main",maptype ={id = tonumber(btnTag) - 100,maptype = temp.id }}); --先传一个table吧
                end
                local params = {}
                params.sort = tonumber(temp.id)
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_get_sort_cards"), http_request_method.GET, params,"wormholes_get_sort_cards")
            else
                local temp = self.m_all_map[tonumber(btnTag) - 100]
                local function responseMethod( tag,gameData )
                    local data = gameData:getNodeWithKey("data");
                    data = json.decode(data:getFormatBuffer()) or {}
                    game_scene:enterGameUi("game_wormhole_map",{gameData = data,maptype ={id = tonumber(btnTag) - 100,maptype = temp.id }}); --先传一个table吧
                end
                local params = {}
                params.sort = tonumber(temp.id)
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_go_map"), http_request_method.GET, params,"wormholes_go_map")
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_wormhole_main.ccbi");

    self.m_ccbNode      = ccbNode
    
    self.m_node_left    = ccbNode:nodeForName("m_node_left")
    self.m_node_right   = ccbNode:nodeForName("m_node_right")
    self.m_btn_item = self.m_btn_item or {}
    for i=1,4 do
        self.m_btn_item[i] = ccbNode:controlButtonForName("m_btn_item"..i)
    end

    return ccbNode;
end


--[[--
    刷新ui
]]
function game_wormhole_main.refreshUi(self)
    for i=1,4 do
        self.m_btn_item[i]:setEnabled(self.m_is_battle)
    end

    for k,v in pairs(self.m_all_map) do
        cclog(v.img)

        local anim = game_util:createIdelAnim(v.img,0,nil,nil,nil,nil,nil,true)
        if anim then
            if k <3 then
                self.m_node_left:addChild(anim)
            else
                self.m_node_right:addChild(anim)
            end
            anim:setPositionX(50*(k%2 == 1 and -1 or 1))
        end
    end
end
--[[--
    初始化
]]
function game_wormhole_main.init(self,t_params)
    t_params = t_params.gameData or {};

    -- cclog2(t_params,"t_params")
    self.mainpage_cfg = getConfig(game_config_field.colosseum_limited)

    self.m_version = t_params.version
    self.m_is_battle =  t_params.is_battle
    self.m_all_map = t_params.all_sort or {}
    self.all_sort = t_params.all_sort or {}

    if next(self.m_all_map) then
        for k,v in pairs(self.m_all_map) do
            local id = v
            self.m_all_map[k]={}
            self.m_all_map[k].id = id
            self.m_all_map[k].isfirst = tonumber(t_params.all_sort_state[id..""])  -- 0 open 1 close
            self.m_all_map[k].img = self.mainpage_cfg:getNodeWithKey(id..""):getNodeWithKey("img"):toStr()
        end
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_wormhole_main.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();

    local id = game_guide_controller:getIdByTeam("100");
    -- id = 6801
    self:gameGuide("drama","100",id, t_params)
    return scene;
end

function game_wormhole_main.gameGuide(self,guideType,guide_team,guide_id,t_params)
    -- print(guideType, " ", guide_team, " ", guide_id, " ", t_params, "guideType,guide_team,guide_id,t_params")
    -- cclog2(game_guide_controller:getGuideCompareFlag(guide_team,guide_id), "game_guide_controller:getGuideCompareFlag(guide_team,guide_id)  ===  ")
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "drama" then
        if guide_team == "100" and id == 10001 then
            local function endCallFunc()
                game_guide_controller:sendGuideData(guide_team, id  , {endCallFunc = function ()
                    self:gameGuide("drama", guide_team, id + 1)
                end})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "100" and id == 10002 then
            local function endCallFunc()
                game_guide_controller:sendGuideData(guide_team, id + 1 )
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        end
    end
end
return game_wormhole_main;