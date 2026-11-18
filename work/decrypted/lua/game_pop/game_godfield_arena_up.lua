--- 查看日志
local game_godfield_arena_up = {
    m_enemy_icon = nil,
    m_pipei_lab = nil,
    m_hero_name_lab = nil,
    m_hero_zhanli = nil,
    m_challge_btn = nil,
};

--[[--
    销毁
]]
function game_godfield_arena_up.destroy(self)
    -- body
    cclog("-----------------game_godfield_arena_up destroy-----------------");
    self.m_enemy_icon = nil;
    self.m_pipei_lab = nil;
    self.m_hero_name_lab = nil;
    self.m_hero_zhanli = nil;
    self.m_challge_btn = nil;
end
--[[--
    返回
]]
function game_godfield_arena_up.back(self,type)
    game_scene:removePopByName("game_godfield_arena_up");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_arena_up.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 22 then
            self:back();
        elseif btnTag == 21 then
            
            local function responseMethod( tag,gameData )
                 if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local sort = 1
                    local flag = "game_godfield_arena_up";
                   local data1 = gameData:getNodeWithKey("data");
                   data1 = json.decode(data1:getFormatBuffer())
                   --cclog2(data1,"data1===  ")
                    --data1.sort = sort
                    game_scene:enterGameUi("game_godfield_battle_big",{gameData = self.m_tGameData,data1 = data1,sort = sort,flag = flag})
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_arena_stage_up_battle"), http_request_method.GET, params,"god_arena_stage_up_battle")
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_arena_bat_sel.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer") 
    self.m_hero_icon_1 = ccbNode:nodeForName("m_enemy_icon");
    self.m_pipei_lab_1 = ccbNode:labelTTFForName("m_pipei_lab");
    self.m_hero_name_lab1 = ccbNode:labelTTFForName("m_hero_name_lab");
    self.m_hero_zhanli1 = ccbNode:labelTTFForName("m_hero_zhanli");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);
    local m_challge_btn = ccbNode:controlButtonForName("m_challge_btn");
    m_challge_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

function game_godfield_arena_up.refreshUi( self )
    -- body
    local role = self.m_tGameData.role or math.random(1, 5)
    local tempIcon = game_util:createPlayerIconByRoleId(role);
    if tempIcon then
        tempIcon:setScale(0.75);
        local tempSize = self.m_hero_icon_1:getContentSize();
        tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        self.m_hero_icon_1:addChild(tempIcon)
    end
    local rank = self.m_tGameData.rank
    self.m_pipei_lab_1:setString(rank);
    local name = self.m_tGameData.name
    self.m_hero_name_lab1:setString(name);
    local combat = self.m_tGameData.combat;
    self.m_hero_zhanli1:setString(combat);
end

--[[--
    初始化
]]
function game_godfield_arena_up.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {}
    end
    self.m_logType = t_params.logType or ""
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_arena_up.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_arena_up;