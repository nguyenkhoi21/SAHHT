local game_god_escort_notice = {}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_notice.destroy(self)
    cclog("[神域押镖] game_god_escort_notice:destroy()")
end

function game_god_escort_notice.createUi(self)
    cclog("[神域押镖] game_god_escort_notice.createUi(self)")
    local ccbNode = luaCCBNode:create()
    local function onMainClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then
            game_scene:removePopByName("game_god_escort_notice")
        elseif btnTag == 2 then
            if self.cb then
                self.cb()
            end
            game_scene:removePopByName("game_god_escort_notice")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainClick)

    ccbNode:openCCBFile("ccb/ui_god_escort_notice.ccbi")
    self.ccbNode = ccbNode

    self.ly_di = ccbNode:layerForName("ly_di")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end
    self.ly_di:registerScriptTouchHandler(onTouch, false, helper.noticeTouchPriorityBase, true)
    self.ly_di:setTouchEnabled(true)

    ccbNode:labelTTFForName("lb_tx"):setString(self.tx)

    ccbNode:controlButtonForName("btn_sure"):setTouchPriority(helper.noticeTouchPriority)
    ccbNode:controlButtonForName("btn_cancel"):setTouchPriority(helper.noticeTouchPriority)

    return ccbNode
end

function game_god_escort_notice.init(self, t_params)
    self.cb = t_params.cb
    self.tx = t_params.tx
end

function game_god_escort_notice.create(self, t_params)
    cclog("[神域押镖] game_god_escort_notice:create(t_params)")
    self:init(t_params)
    local ui = self:createUi()
    self:refreshUi()
    return ui
end

function game_god_escort_notice.refreshUi(self)
    cclog("[神域押镖] game_god_escort_notice:refreshUi()")
end

return game_god_escort_notice