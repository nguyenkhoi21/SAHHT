--- 选择线路
local game_team_pk_select_pop = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,

    callBack = nil,
    playerId = nil,
    game_data = nil,
    btn_change = nil,
    btn_down_road = nil,
    btn_middle_road = nil,
    btn_up_road = nil,
    pos = nil,
    size = nil,
};
--[[--
    销毁
]]
function game_team_pk_select_pop.destroy(self)
    -- body
    cclog("-----------------game_team_pk_select_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;

    self.callBack = nil;
    self.playerId = nil;
    self.game_data = nil;
    self.btn_change = nil;
    self.btn_down_road = nil;
    self.btn_middle_road = nil;
    self.btn_up_road = nil;
    self.pos = nil;
    self.size = nil;
end
--[[--
    返回
]]
function game_team_pk_select_pop.back(self,type)
    if self.callBack and self.game_data then
        self.callBack(self.game_data)
    end
    game_scene:removePopByName("game_team_pk_select_pop");
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_team_pk_select_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 101 then--返回
            self:back()
        elseif btnTag >= 102 and btnTag <=104 then--下  中  上
            local params = {}
            if self.playerId then
                params.uid = self.playerId
            end
            params.line_id = 105 - btnTag
            local function responseMethod(tag,gameData)
                self.game_data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                self:back()
                -- game_scene:addPop("game_team_pk_battle_list",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_select_change_line"), http_request_method.GET, params,"team_pk_new_select_change_line")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainClick",onMainClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_guild_pk_select_pop.ccbi");

    self.btn_change = ccbNode:controlButtonForName("btn_change");
    self.btn_down_road = ccbNode:controlButtonForName("btn_down_road");
    self.btn_middle_road = ccbNode:controlButtonForName("btn_middle_road");
    self.btn_up_road = ccbNode:controlButtonForName("btn_up_road");

    self.btn_change:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 21);
    self.btn_down_road:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 21);
    self.btn_middle_road:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 21);
    self.btn_up_road:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 21);

    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 20,true);
    self.m_root_layer:setTouchEnabled(true);

    if self.pos and self.size then
        self.btn_change:setPreferredSize(self.size)
        self.btn_change:setPosition(self.pos)

        local tempSize = self.btn_middle_road:getContentSize()
        self.btn_middle_road:setPosition(ccp(self.pos.x - tempSize.width,self.pos.y))
        self.btn_down_road:setPosition(ccp(self.pos.x - tempSize.width,self.pos.y - tempSize.height))
        self.btn_up_road:setPosition(ccp(self.pos.x - tempSize.width,self.pos.y + tempSize.height))

        game_util:setCCControlButtonTitle(self.btn_up_road,"Đi Trên")
        game_util:setCCControlButtonTitle(self.btn_middle_road,"Đi Giữa")
        game_util:setCCControlButtonTitle(self.btn_down_road,"Đi Dưới")
    end
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_team_pk_select_pop.refreshUi(self)
    
end
--[[--
    初始化
]]
function game_team_pk_select_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    self.pos = t_params.pos
    self.size = t_params.size
    if self.pos and self.size then
        cclog("x == " .. self.pos.x .. ",y == " .. self.pos.y)
        cclog("width == " .. self.size.width .. ",height == " .. self.size.height)
    end
    self.playerId = t_params.playerId or nil
    self.callBack = t_params.callBack or nil
end
--[[--
    创建ui入口并初始化数据
]]
function game_team_pk_select_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_team_pk_select_pop;