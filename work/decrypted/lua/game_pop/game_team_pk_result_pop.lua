--- 组队世界boss结算弹出板

local game_team_pk_result_pop = {
    m_popUi = nil,
    m_root_layer = nil, 
    m_tParams = nil,

    m_close_btn = nil,

    is_win = nil,
};
--[[--
    销毁
]]
function game_team_pk_result_pop.destroy(self)
    -- body
    cclog("-----------------game_team_pk_result_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_tParams = nil;

    self.m_close_btn = nil;

    self.is_win = nil;
end
--[[--
    返回
]]
function game_team_pk_result_pop.back(self,type)
    game_scene:setVisibleBroadcastNode(false);
    local function responseMethod(tag,gameData )
        game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})

        -- body
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")

end
--[[--
    读取ccbi创建ui
]]
function game_team_pk_result_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then--关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_guild_pk_result_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");

    local win_label = ccbNode:labelTTFForName("win_label")
    local result_label = ccbNode:labelTTFForName("result_label")
    local winStr = "Chúc mừng đội của bạn đã thắng trong event Vực Chiến lần này, phần thưởng sẽ gửi qua Thư, hãy tiếp tục cố gắng nhé."
    local loseStr = "Rất tiếc đội của bạn chưa đánh bại được đối thủ trong event Vực Chiến, phần thưởng sẽ được gửi qua Thư, chúc bạn may mắn lần sau"
    if self.is_win == 1 then
        win_label:setString("Thắng")
        result_label:setString(winStr)
    else
        win_label:setString("Thua")
        result_label:setString(loseStr)
    end

    
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_team_pk_result_pop.refreshUi(self)
    
end
--[[--
    初始化
]]
function game_team_pk_result_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    self.is_win = t_params.is_win
end
--[[--
    创建ui入口并初始化数据
]]
function game_team_pk_result_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_team_pk_result_pop;