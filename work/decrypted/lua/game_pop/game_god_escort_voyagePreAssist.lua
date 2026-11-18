--[[
    远航准备
]]
local game_god_escort_voyagePreAssist = {}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_voyagePreAssist.destroy(self)
    cclog("[神域押镖] game_god_escort_voyagePreAssist:destroy()")
end

function game_god_escort_voyagePreAssist.createUi(self)
    cclog("[神域押镖] game_god_escort_voyagePreAssist.createUi(self)")
    local ccbNode = luaCCBNode:create()
    local function onMainClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then
            game_scene:removePopByName("game_god_escort_voyagePreAssist")
        elseif btnTag == 2 then
            -- game_util:addMoveTips({text = "点击问号"})
            game_scene:addPop("game_god_escort_detail",{openMsg = helper:getTxtById(56)})
        elseif btnTag == 3 then -- 能量-100
            self.power = self.power - 100
            if self.power < 0 then
                self.power = 0
            end
            self:refreshUi()
        elseif btnTag == 4 then -- 能量+100
            if self.power + 100 <= game_data.m_cacheData.escort_power then
                self.power = self.power + 100
            else
                game_util:addMoveTips({text = helper.txt.god_escort_txt_117})
            end
            self:refreshUi()
        elseif btnTag == 5 then -- 穿梭器 -1
            self.att1 = self.att1 - 1
            if self.att1 < 0 then
                self.att1 = 0
            end
            self:refreshUi()
        elseif btnTag == 6 then -- 穿梭器 +1
            local has = helper:getHasById(2)
            if self.att1 + 1 <= has then
                self.att1 = self.att1 + 1
            else
                game_util:addMoveTips({text = helper.txt.god_escort_txt_118})
            end
            self:refreshUi()
        elseif btnTag == 7 then -- 量子仓 -1
            self.att2 = self.att2 - 1
            if self.att2 < 0 then
                self.att2 = 0
            end
            self:refreshUi()
        elseif btnTag == 8 then -- 量子仓 +1
            local has = helper:getHasById(3)
            if self.att2 + 1 <= has then
                self.att2 = self.att2 + 1
            else
                game_util:addMoveTips({text = helper.txt.god_escort_txt_118})
            end
            self:refreshUi()
        elseif btnTag == 9 then -- 以太能源 -1
            self.att3 = self.att3 - 1
            if self.att3 < 0 then
                self.att3 = 0
            end
            self:refreshUi()
        elseif btnTag == 10 then -- 以太能源 +1
            local has = helper:getHasById(1)
            if self.att3 + 1 <= has then
                self.att3 = self.att3 + 1
            else
                game_util:addMoveTips({text = helper.txt.god_escort_txt_118})
            end
            self:refreshUi()
        elseif btnTag == 11 then
            if self.power == 0 and self.att3 == 0 and self.att1 == 0 and self.att2 == 0 then
                game_scene:removePopByName("game_god_escort_voyagePreAssist")
                return 
            end

            local _str = self.power .. helper.txt.god_escort_txt_82 -- x能量
            _str = _str .. "," -- ,
            _str = _str .. self.att3 .. helper.txt.god_escort_txt_84 .. helper.txt.god_escort_txt_44 -- x个以太能源
            _str = _str .. ","  -- ,
            _str = _str .. self.att1 .. helper.txt.god_escort_txt_84 .. helper.txt.god_escort_txt_42 -- x个穿梭器
            _str = _str .. ","  -- ,
            _str = _str .. self.att2 .. helper.txt.god_escort_txt_84 .. helper.txt.god_escort_txt_43 -- x个量子仓

            local tx = string.format(helper.txt.god_escort_txt_110, _str)
            game_scene:addPop("game_god_escort_notice",{tx = tx, cb = function()
                local function responseMethod(tag, gameData)
                    local data = gameData:getNodeWithKey("data")
                    local gameData = json.decode(data:getFormatBuffer()) or {}

                    if gameData.power then
                        game_data.m_cacheData.escort_power = gameData.power
                    end
    
                    if self.cb then
                        self.cb({gameData = gameData})
                    end
                    game_scene:removePopByName("game_god_escort_voyagePreAssist")
                end
                local key = "highway_add_power"
                local params = {
                    area_id = self.area_id,
                    num = self.power .. "_" .. self.att3 .. "_" .. self.att1 .. "_" .. self.att2
                }
                helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
            end})
        elseif btnTag == 12 then --  穿梭器 -5
            self.att1 = self.att1 - 5
            if self.att1 < 0 then
                self.att1 = 0
            end
            self:refreshUi()
        elseif btnTag == 13 then -- 穿梭器 +5
            local has = helper:getHasById(2)
            if self.att1 + 5 <= has then
                self.att1 = self.att1 + 5
            else
                game_util:addMoveTips({text = helper.txt.god_escort_txt_118})
            end
            self:refreshUi()
        elseif btnTag == 14 then -- 量子仓 -5
            self.att2 = self.att2 - 5
            if self.att2 < 0 then
                self.att2 = 0
            end
            self:refreshUi()
        elseif btnTag == 15 then -- 量子仓 +5
            local has = helper:getHasById(3)
            if self.att2 + 5 <= has then
                self.att2 = self.att2 + 5
            else
                game_util:addMoveTips({text = helper.txt.god_escort_txt_118})
            end
            self:refreshUi()
        elseif btnTag == 16 then -- 以太能源 -5
            self.att3 = self.att3 - 5
            if self.att3 < 0 then
                self.att3 = 0
            end
            self:refreshUi()
        elseif btnTag == 17 then -- 以太能源 +5
            local has = helper:getHasById(1)
            if self.att3 + 5 <= has then
                self.att3 = self.att3 + 5
            else
                game_util:addMoveTips({text = helper.txt.god_escort_txt_118})
            end
            self:refreshUi()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainClick)
    ccbNode:openCCBFile("ccb/ui_god_escort_voyagePreAssist.ccbi")
    self.ccbNode = ccbNode

    self.ly_di = ccbNode:layerForName("ly_di")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end
    self.ly_di:registerScriptTouchHandler(onTouch, false, helper.voyagePreAssistTouchPriorityBase, true)
    self.ly_di:setTouchEnabled(true)

    ccbNode:controlButtonForName("btn_wenhao"):setTouchPriority(helper.voyagePreAssistTouchPriority)
    ccbNode:controlButtonForName("btn_close"):setTouchPriority(helper.voyagePreAssistTouchPriority)
    ccbNode:controlButtonForName("btn_ok"):setTouchPriority(helper.voyagePreAssistTouchPriority)
    ccbNode:controlButtonForName("btn_powerReduce"):setTouchPriority(helper.voyagePreAssistTouchPriority)
    ccbNode:controlButtonForName("btn_powerAdd"):setTouchPriority(helper.voyagePreAssistTouchPriority)
    ccbNode:controlButtonForName("btn_att1Reduce"):setTouchPriority(helper.voyagePreAssistTouchPriority)
    ccbNode:controlButtonForName("btn_att1Add"):setTouchPriority(helper.voyagePreAssistTouchPriority)
    ccbNode:controlButtonForName("btn_att2Reduce"):setTouchPriority(helper.voyagePreAssistTouchPriority)
    ccbNode:controlButtonForName("btn_att2Add"):setTouchPriority(helper.voyagePreAssistTouchPriority)
    ccbNode:controlButtonForName("btn_att3Reduce"):setTouchPriority(helper.voyagePreAssistTouchPriority)
    ccbNode:controlButtonForName("btn_att3Add"):setTouchPriority(helper.voyagePreAssistTouchPriority)
    ccbNode:controlButtonForName("btn_att1Reduce5"):setTouchPriority(helper.voyagePreAssistTouchPriority)
    ccbNode:controlButtonForName("btn_att1Add5"):setTouchPriority(helper.voyagePreAssistTouchPriority)
    ccbNode:controlButtonForName("btn_att2Reduce5"):setTouchPriority(helper.voyagePreAssistTouchPriority)
    ccbNode:controlButtonForName("btn_att2Add5"):setTouchPriority(helper.voyagePreAssistTouchPriority)
    ccbNode:controlButtonForName("btn_att3Reduce5"):setTouchPriority(helper.voyagePreAssistTouchPriority)
    ccbNode:controlButtonForName("btn_att3Add5"):setTouchPriority(helper.voyagePreAssistTouchPriority)

    self.power = 0
    self.att1 = 0
    self.att2 = 0
    self.att3 = 0

    ccbNode:labelTTFForName("lb_desc1"):setString(helper.txt.god_escort_txt_82)
    ccbNode:labelTTFForName("lb_desc2"):setString(helper.txt.god_escort_txt_83)
    ccbNode:labelTTFForName("lb_desc3"):setString(helper.txt.god_escort_txt_120)
    ccbNode:labelTTFForName("lb_desc4"):setString(helper.txt.god_escort_txt_42)
    ccbNode:labelTTFForName("lb_desc5"):setString(helper.txt.god_escort_txt_43)
    ccbNode:labelTTFForName("lb_desc6"):setString(helper.txt.god_escort_txt_44)

    return ccbNode
end

function game_god_escort_voyagePreAssist.init(self, t_params)
    self.area_id = t_params.area_id
    self.cb = t_params.cb
end

function game_god_escort_voyagePreAssist.create(self, t_params)
    cclog("[神域押镖] game_god_escort_voyagePreAssist:create(t_params)")
    self:init(t_params)
    local ui = self:createUi()
    self:refreshUi()
    return ui
end

function game_god_escort_voyagePreAssist.refreshUi(self)
    cclog("[神域押镖] game_god_escort_voyagePreAssist:refreshUi()")
    self.ccbNode:labelTTFForName("lb_powerValue"):setString(self.power)
    self.ccbNode:labelTTFForName("lb_att1Value"):setString(self.att1)
    self.ccbNode:labelTTFForName("lb_att2Value"):setString(self.att2)
    self.ccbNode:labelTTFForName("lb_att3Value"):setString(self.att3)
end

return game_god_escort_voyagePreAssist
