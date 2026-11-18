local game_god_escort_spaceRoute = {}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_spaceRoute.destroy(self)
    cclog("[神域押镖] game_god_escort_spaceRoute.destroy(self)")
end

function game_god_escort_spaceRoute.createUi(self)
    cclog("[神域押镖] game_god_escort_spaceRoute.createUi(self)")
    local ccbNode = luaCCBNode:create()
    local function onMainClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then
            game_scene:removePopByName("game_god_escort_spaceRoute");
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainClick", onMainClick)
    ccbNode:openCCBFile("ccb/ui_god_escort_achieve.ccbi")
    self.ccbNode = ccbNode

    self.m_dont_layer = ccbNode:layerForName("m_dont_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_dont_layer:registerScriptTouchHandler(onTouch,false,helper.achieveTouchPriorityBase,true);
    self.m_dont_layer:setTouchEnabled(true);

    ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(helper.achieveTouchPriority)

    return ccbNode
end

function game_god_escort_spaceRoute.init(self, t_params)
end

function game_god_escort_spaceRoute.create(self, t_params)
    cclog("[神域押镖] game_god_escort_spaceRoute.create(self,t_params)")
    self:init(t_params)
    local ui = self:createUi()

    return ui
end

function game_god_escort_spaceRoute.refreshUi(self)
    cclog("[神域押镖] game_god_escort_spaceRoute.refreshUi(self,t_params)")
end

return game_god_escort_spaceRoute
