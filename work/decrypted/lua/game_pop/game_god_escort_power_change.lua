local game_god_escort_power_change = {}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_power_change.destroy(self)
    cclog("[神域押镖] game_god_escort_power_change:destroy()")
end

function game_god_escort_power_change.createUi(self)
    cclog("[神域押镖] game_god_escort_power_change.createUi(self)")
    local ccbNode = luaCCBNode:create()
    local function onMainClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then
            game_scene:removePopByName("game_god_escort_power_change")
        elseif btnTag == 2 then -- 减少
            if self.tr - 1 <= self.minTr then
                game_util:addMoveTips({text = helper.txt.god_escort_txt_30})
                return
            end
            self.tr = self.tr - 1
            self:refreshUi()
        elseif btnTag == 3 then -- 增加
            if self.tr + 1 > self.has then
                game_util:addMoveTips({text = helper.txt.god_escort_txt_31})
                return
            end
            if self.tr + 1 > self.maxTr then
                game_util:addMoveTips({text = helper.txt.god_escort_txt_126})
                return
            end
            self.tr = self.tr + 1
            self:refreshUi()
        elseif btnTag == 4 then -- 确认
            if self.tr > self.has then
                game_util:addMoveTips({text = helper.txt.god_escort_txt_29})
                return
            end
            local tx = helper.txt.god_escort_txt_108
            game_scene:addPop("game_god_escort_notice",{tx = tx, cb = function()
                local function responseMethod(tag, gameData)
                    -- local data = gameData:getNodeWithKey("data")
                    -- gameData= json.decode(data:getFormatBuffer())
                    game_util:addMoveTips({text = helper.txt.god_escort_txt_34})
                    game_scene:removePopByName("game_god_escort_power_change")
                    if self.cb then
                        self.cb(gameData)
                    end
                end
                local key = "highway_betting"
                local params = {
                    area_id = self.area_id,
                    ship_id = self.ship_id,
                    num = self.tr
                }
                helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
    
            end})
        elseif btnTag == 5 then -- 减少10
            self.tr = self.tr - 10
            if self.tr <= self.minTr then
                self.tr = self.minTr
                game_util:addMoveTips({text = helper.txt.god_escort_txt_30})
            end
            self:refreshUi()
        elseif btnTag == 6 then -- 增加10
            self.tr = self.tr + 10
            if self.tr > self.has then
                self.tr = self.has
                game_util:addMoveTips({text = helper.txt.god_escort_txt_31})
            end
            if self.tr > self.maxTr then
                self.tr = self.maxTr
                game_util:addMoveTips({text = helper.txt.god_escort_txt_126})
            end
            self:refreshUi()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainClick)
    ccbNode:openCCBFile("ccb/ui_god_escort_power_change.ccbi")
    self.ccbNode = ccbNode

    self.ly_di = ccbNode:layerForName("ly_di")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true --intercept event
        end
    end
    self.ly_di:registerScriptTouchHandler(onTouch, false, helper.powerChangeTouchPriorityBase, true)
    self.ly_di:setTouchEnabled(true)

    ccbNode:controlButtonForName("btn_close"):setTouchPriority(helper.powerChangeTouchPriority)
    ccbNode:controlButtonForName("btn_reduce"):setTouchPriority(helper.powerChangeTouchPriority)
    ccbNode:controlButtonForName("btn_add"):setTouchPriority(helper.powerChangeTouchPriority)
    ccbNode:controlButtonForName("btn_reduce5"):setTouchPriority(helper.powerChangeTouchPriority)
    ccbNode:controlButtonForName("btn_add5"):setTouchPriority(helper.powerChangeTouchPriority)
    ccbNode:controlButtonForName("btn_ok"):setTouchPriority(helper.powerChangeTouchPriority)

    self.minTr = 5
    self.tr = self.minTr
    self.maxTr = helper.cfg.highway_time[self.round_id].odd_limit
    -- 彩券数量
    self.has = game_data:getItemCountByCid(tostring(9101353)) or 0

    self.lb_value = ccbNode:labelTTFForName("lb_value")
    self.lb_value:setString(tostring(self.tr))

    -- nd_head
    local nd_head = ccbNode:nodeForName("nd_head")
    nd_head:removeAllChildrenWithCleanup(true)
    local sp = helper:createShipSprite(self.lv)
    sp:setScale(50 / sp:getContentSize().width)
    nd_head:addChild(sp)

    return ccbNode
end

function game_god_escort_power_change.init(self, t_params)
    self.odds = t_params.odds
    self.area_id = t_params.area_id
    self.ship_id = t_params.ship_id
    self.lv = t_params.lv
    self.cb = t_params.cb
    self.round_id = t_params.round_id
    cclog("[神域押镖] game_god_escort_power_change:init(t_params) odds = " .. tostring(self.odds) .. " area_id = " .. tostring(self.area_id) .. " ship_id = " .. tostring(self.ship_id))
end

function game_god_escort_power_change.create(self, t_params)
    cclog("[神域押镖] game_god_escort_power_change:create(t_params)")
    self:init(t_params)
    local ui = self:createUi()
    self:refreshUi()
    return ui
end

function game_god_escort_power_change.refreshUi(self)
    cclog("[神域押镖] game_god_escort_power_change:refreshUi()")
    self.sy = math.floor(self.tr * self.odds / 100)
    self.ccbNode:labelTTFForName("lb_tr"):setString(helper.txt.god_escort_txt_32 .. tostring(self.tr))
    self.ccbNode:labelTTFForName("lb_value"):setString(helper.txt.god_escort_txt_32 .. tostring(self.tr))
    self.ccbNode:labelTTFForName("lb_sy"):setString(helper.txt.god_escort_txt_33 .. tostring(self.sy))
end

return game_god_escort_power_change
