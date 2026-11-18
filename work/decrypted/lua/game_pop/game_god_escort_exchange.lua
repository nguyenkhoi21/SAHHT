local game_god_escort_exchange = {}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_exchange.destroy(self)
    self.curValue = 1
    cclog("[神域押镖] game_god_escort_exchange:destroy()")
end

function game_god_escort_exchange.createUi(self)
    cclog("[神域押镖] game_god_escort_exchange.createUi(self)")
    local ccbNode = luaCCBNode:create()
    local function onMainClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then
            game_scene:removePopByName("game_god_escort_exchange")
        elseif btnTag == 2 then -- -10
            self.curValue = self.curValue - 10
            if self.curValue < 1 then
                self.curValue = 1
            end
            self:refreshUi()
        elseif btnTag == 3 then -- -1
            self.curValue = self.curValue - 1
            if self.curValue < 1 then
                self.curValue = 1
            end
            self:refreshUi()
        elseif btnTag == 4 then -- +1
            self.curValue = self.curValue + 1
            local remain = self:getExchangeRemain()
            if self.curValue > remain then
                self.curValue = remain
                game_util:addMoveTips({text = helper.txt.god_escort_txt_122})
            end
            if self.curValue > self.maxValue then
                self.curValue = self.maxValue
            end
            self:refreshUi()
        elseif btnTag == 5 then -- +10
            self.curValue = self.curValue + 10
            local remain = self:getExchangeRemain()
            if self.curValue > remain then
                self.curValue = remain
                game_util:addMoveTips({text = helper.txt.god_escort_txt_122})
            end
            if self.curValue > self.maxValue then
                self.curValue = self.maxValue
            end
            self:refreshUi()
        elseif btnTag == 6 then -- +MAX
            self.curValue = self.maxValue
            local remain = self:getExchangeRemain()
            if self.curValue > remain then
                self.curValue = remain
            end
            self:refreshUi()
        elseif btnTag == 7 then -- 确定
            cclog("[神域押镖] game_god_escort_exchange:确定")
            if self.curValue == 0 then
                game_util:addMoveTips({text = helper.txt.god_escort_txt_122})
                game_scene:removePopByName("game_god_escort_exchange")
                return 
            end
            if self.curValue > self.maxValue then
                game_util:addMoveTips({text = helper.txt.god_escort_txt_104})
                return
            end

            local tx = helper.txt.god_escort_txt_109
            game_scene:addPop(
                "game_god_escort_notice",
                {
                    tx = tx,
                    cb = function()
                        local function responseMethod(tag, gameData)
                            local data = gameData:getNodeWithKey("data")
                            local gameData = json.decode(data:getFormatBuffer()) or {}
                            if self.cb then
                                self.cb({gameData = gameData})
                            end
                            game_scene:removePopByName("game_god_escort_exchange")
                            game_util:addMoveTips({text = helper.txt.god_escort_txt_88})
                        end
                        local key = "highway_trans"
                        local params = {
                            pos_id = self.pos_id,
                            cost_num = self.curValue
                        }
                        helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
                    end
                }
            )
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainClick)
    ccbNode:openCCBFile("ccb/ui_god_escort_exchange.ccbi")
    self.ccbNode = ccbNode

    self.ly_di = ccbNode:layerForName("ly_di")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end
    self.ly_di:registerScriptTouchHandler(onTouch, false, helper.exchangeTouchPriorityBase, true)
    self.ly_di:setTouchEnabled(true)

    ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(helper.exchangeTouchPriority)
    ccbNode:controlButtonForName("btn_1"):setTouchPriority(helper.exchangeTouchPriority)
    ccbNode:controlButtonForName("btn_2"):setTouchPriority(helper.exchangeTouchPriority)
    ccbNode:controlButtonForName("btn_3"):setTouchPriority(helper.exchangeTouchPriority)
    ccbNode:controlButtonForName("btn_4"):setTouchPriority(helper.exchangeTouchPriority)
    ccbNode:controlButtonForName("btn_5"):setTouchPriority(helper.exchangeTouchPriority)
    ccbNode:controlButtonForName("btn_6"):setTouchPriority(helper.exchangeTouchPriority)

    local nd_icon = ccbNode:controlButtonForName("nd_icon")
    nd_icon:removeAllChildrenWithCleanup(true)
    local reward = self.reward
    local icon, name, count = game_util:getRewardByItemTable(reward, nil, true)
    if icon then
        icon:setAnchorPoint(ccp(0.5, 0.5))
        icon:setPosition(ccp(0, 0))
        nd_icon:addChild(icon, 10)
    end
    self.ccbNode:labelTTFForName("lb_name"):setString(name)

    self.curValue = 1
    local remain = self:getExchangeRemain()
    if remain == 0 then
        self.curValue = 0
    end
    self.maxValue = self.num

    return ccbNode
end

function game_god_escort_exchange.init(self, t_params)
    self.reward = t_params.reward
    self.num = t_params.num
    self.c_id = t_params.c_id
    self.cb = t_params.cb
    self.pos_id = t_params.pos_id
    self.trans_log = t_params.trans_log
end

function game_god_escort_exchange.create(self, t_params)
    cclog("[神域押镖] game_god_escort_exchange:create(t_params)")
    self:init(t_params)
    local ui = self:createUi()
    self:refreshUi()
    return ui
end

function game_god_escort_exchange.refreshUi(self)
    cclog("[神域押镖] game_god_escort_exchange:refreshUi()")
    self.ccbNode:labelTTFForName("lb_num"):setString(self.curValue)
    local score = helper.cfg.highway_trans[tonumber(self.c_id)].score
    self.ccbNode:labelTTFForName("lb_change1"):setString(helper.txt.god_escort_txt_65 .. score)
    self.ccbNode:labelTTFForName("lb_change2"):setString(helper.txt.god_escort_txt_66 .. score * self.curValue)
end

function game_god_escort_exchange.getExchangeRemain(self)
    local cfg = helper.cfg.highway_trans[tonumber(self.c_id)]
    local limit = cfg.limit
    local score = cfg.score
    local trans_log = self.trans_log
    local use = trans_log[tostring(self.c_id)] or 0
    local remain = math.floor((limit - use) / score)
    if remain < 0 then
        remain = 0
    end
    return remain
end

return game_god_escort_exchange
