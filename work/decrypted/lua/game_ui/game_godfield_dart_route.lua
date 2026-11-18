---  神域押镖宇宙航线
local game_godfield_dart_route = {
    m_autoRefreshScheduler = nil,
    m_tickFlag = nil,
    m_auto_time = nil,
    m_route_scroll_view = nil,
    m_transShipTable = nil,
    m_teamUidTab = nil,
    m_list_view_bg = nil,
    m_ship_list_view_node = nil,
    m_list_view_btn = nil,
    m_arrow_sprite = nil,
    m_new_battle_label = nil,
    m_clickFlag = nil,
    jiantou = nil,
};
--[[--
    销毁ui
]]
function game_godfield_dart_route.destroy(self)
    cclog("----------------- game_dart_route destroy-----------------"); 
    if self.m_autoRefreshScheduler ~= nil then
        scheduler.unschedule(self.m_autoRefreshScheduler)
        self.m_autoRefreshScheduler = nil;
    end
    self.m_tickFlag = nil;
    self.m_auto_time = nil;
    self.m_route_scroll_view = nil;
    self.m_transShipTable = nil;
    self.m_teamUidTab = nil;
    self.m_list_view_bg = nil;
    self.m_ship_list_view_node = nil;
    self.m_list_view_btn = nil;
    self.m_arrow_sprite = nil;
    self.m_new_battle_label = nil;
    self.m_clickFlag = nil;
    self.jiantou = nil;
end
--[[--
    返回
]]
function game_godfield_dart_route.back(self)
    local function responseMethod( tag,gameData )
        if gameData == nil then return end
        game_scene:enterGameUi("game_godfield_dart_main",{gameData = gameData})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_dart_mian"),http_request_method.GET,nil,"god_dart_mian")  
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_dart_route.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog(btnTag)
        for i=1,#self.jiantou do
            if i == btnTag then
                self.jiantou[i]:setVisible(true)
            else 
                self.jiantou[i]:setVisible(false)
            end
        end
        if btnTag == 101 then--返回
            self:back()
        elseif btnTag == 102 then--刷新
            local function responseMethod( tag,gameData )
               self:init({gameData=gameData})
               self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_all_map"), http_request_method.GET, nil,"god_field_escort_all_map")
        else
            if self.click == 1 then
                self.click = self.click + 1
                self.ClickBtn = btnTag
            elseif self.click == 2 then
                if self.ClickBtn ==btnTag then
                    self.click = 1 
                    t_params = {}
                    t_params.map_id = btnTag
                    local function responseMethod( tag,gameData )
                        if gameData == nil then return end
                        game_scene:enterGameUi("game_godfield_dart_routeslist",{gameData = gameData,index=btnTag})
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_map_index"),http_request_method.GET,t_params,"god_field_escort_map_index")
                else
                    self.ClickBtn = btnTag
                end
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_dart_universemap.ccbi");
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    
    self.jiantou = {}
    for i=1,6 do
        local s = "m_jiantou_0" .. i
        local x = ccbNode:spriteForName(s)
        self.jiantou[i] = x
    end
    self.label = {}
    for i=1,6 do
        local s = "count_lb" .. i
        local x = ccbNode:labelTTFForName(s)
        self.label[i] = x
    end
    return ccbNode;
end
function game_godfield_dart_route.refreshUi( self )
    for i=1,#self.label do
        local x = self.countlable[i] or "0"
        self.label[i]:setString(x .. "/24")
    end
end
-- --[[--
--     初始化
-- ]]
function game_godfield_dart_route.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {}
    end
    self.countlable = {}
    for i=1,6 do
        self.countlable[i] = self.m_tGameData[tostring(i)]
    end
    self.m_tickFlag = true;
    self.m_auto_time = 5;
    self.m_transShipTable = {};
    self.m_teamUidTab = {};
    self.m_clickFlag = true;
    self.click = 1
end
--[[--
    创建ui入口并初始化数据
]]
function game_godfield_dart_route.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end
return game_godfield_dart_route