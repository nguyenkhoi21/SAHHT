local game_god_escort_exchange_confirm = {}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_exchange_confirm.destroy(self)
    cclog("[神域押镖] game_god_escort_exchange_confirm:destroy()")
end

function game_god_escort_exchange_confirm.createUi(self)
    cclog("[神域押镖] game_god_escort_exchange_confirm.createUi(self)")
    local ccbNode = luaCCBNode:create()
    local function onMainClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then
            game_scene:removePopByName("game_god_escort_exchange_confirm");
        elseif btnTag == 2 then -- 确定
            cclog("[神域押镖] game_god_escort_exchange:确定")
            local function responseMethod( tag,gameData )
                if self.cb then
                    self.cb()
                end
                game_scene:removePopByName("game_god_escort_exchange_confirm");
            end
            helper.sendHttpRequest(responseMethod,game_url.getUrlForKey("highway_trans"),http_request_method.GET,{pos_id = self.posId, cost_num = self.curValue},"highway_trans")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainClick", onMainClick)

    ccbNode:openCCBFile("ccb/ui_god_escort_exchange_confirm.ccbi")
    self.ccbNode = ccbNode

    ccbNode:labelForName("lb_notice"):setString(string.format(helper.txt.god_escort_txt_27, self.costNum, self.name, self.getNum))

    return ccbNode
end

function game_god_escort_exchange_confirm.init(self, t_params)
    self.name = t_params.name or ""
    self.costNum = t_params.costNum or 0
    self.getNum = t_params.getNum or 0
    self.cb = t_params.cb
end

function game_god_escort_exchange_confirm.create(self, t_params)
    cclog("[神域押镖] game_god_escort_exchange_confirm:create(t_params)")
    self:init(t_params)
    local ui = self:createUi()
    self:refreshUi()
    return ui
end

function game_god_escort_exchange_confirm.refreshUi(self)
    cclog("[神域押镖] game_god_escort_exchange_confirm:refreshUi()")
end

return game_god_escort_exchange_confirm