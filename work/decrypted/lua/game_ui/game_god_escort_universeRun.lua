local game_god_escort_universeRun = {
    endTimeShare = nil,
    shouldReCreateShip = true,
    shipRecord = {}
}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_universeRun.destroy(self)
    cclog("[神域押镖] game_god_escort_universeRun:destroy()")
    self.isDestroy = true
    if self.endTimeShare then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.endTimeShare)
        self.endTimeShare = nil
    end
    self.shouldReCreateShip = true
    self.shipRecord = {}
    if self.timeShare then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.timeShare)
        self.timeShare = nil
    end
end

function game_god_escort_universeRun.createUi(self)
    self.isDestroy = false
    cclog("[神域押镖] game_god_escort_universeRun.createUi(self)")
    local ccbNode = luaCCBNode:create()
    local function onMainClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then
            local function responseMethod(tag, gameData)
                local data = gameData:getNodeWithKey("data")
                local gameData = json.decode(data:getFormatBuffer()) or {}
                game_scene:enterGameUi("game_god_escort_universe", {gameData = gameData})
                self:destroy()
            end
            helper.sendHttpRequest(responseMethod, game_url.getUrlForKey("highway_all_area_index"), http_request_method.GET, nil, "highway_all_area_index_from_run")
        elseif btnTag == 2 then
            local serverTime = game_data:getVirtualServerTime()
            if serverTime - self.clickUpdateBtnTime < helper.refreshInterval then
                game_util:addMoveTips({text = helper.txt.god_escort_txt_113})
                return
            end
            self.clickUpdateBtnTime = serverTime
            self:updateNetData()
        elseif btnTag == 3 then -- 点击星球
            local function responseMethod(tag, gameData)
                local data = gameData:getNodeWithKey("data")
                local gameData = json.decode(data:getFormatBuffer()) or {}

                game_scene:addPop("game_god_escort_voyageReward", {area_id = self.area_id, round_id = self.round_id, gameData = gameData, cb = function()
                    self:refreshUi()
                end})
            end
            local key = "highway_reward_index"
            local params = {
                round_id = self.round_id,
                area_id = self.area_id
            }
            helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
        elseif type(btnTag) == "number" and btnTag >= 11 and btnTag <= 16 then
            local id = btnTag - 10
            cclog("[神域押镖] game_god_escort_universeRun 打开宇宙id:" .. id)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainClick)
    ccbNode:openCCBFile("ccb/ui_god_escort_universeRun.ccbi")
    self.ccbNode = ccbNode

    ccbNode:controlButtonForName("btn_clickStar"):setOpacity(0)

    self.timeShare =
        CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(
        function(dt)
            self:refreshShip()
        end,
        1,
        false
    )

    -- sp_universe
    local sp_universe = ccbNode:spriteForName("sp_universe")
    sp_universe:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(helper.universeImg[self.area_id]))

    self.clickUpdateBtnTime = 0

    return ccbNode
end

function game_god_escort_universeRun.init(self, t_params)
    self:updateGameData(t_params.gameData)
    self.area_id = t_params.area_id
    self.betting = t_params.betting
    local betRound = (self.round_id % 2 == 0 and self.round_id ~= 0) and self.round_id - 1 or self.round_id
    local _data = self.betting[tostring(betRound)] or {}
    _data = _data[tostring(self.area_id)] or {}
    if _data then
        self.betShipId = _data.ship_id
    end
    self.maxMileage = 0
    if self.round_id > 0 then
        if self.round_id % 2 == 0 then
            self.maxMileage = helper.cfg.highway_time[self.round_id - 1].point
        else
            self.maxMileage = helper.cfg.highway_time[self.round_id].point
        end
    end
end

function game_god_escort_universeRun:updateGameData(gameData)
    self.gameData = gameData
    self.shipDatas = gameData.data
    self.round_id = gameData.round_id
    self.step = gameData.step
    self.sort = gameData.sort
    self.ts_start = gameData.ts_start
    if gameData.gift_box then
        game_data.m_cacheData.gift_box = gameData.gift_box
    end
end

function game_god_escort_universeRun.create(self, t_params)
    cclog("[神域押镖] game_god_escort_universeRun:create(t_params)")
    self:init(t_params)
    local ui = self:createUi()
    self:refreshUi()
    return ui
end

function game_god_escort_universeRun.refreshUi(self)
    cclog("[神域押镖] game_god_escort_universeRun:refreshUi()")
    -- lb_round
    local lb_round = self.ccbNode:labelTTFForName("lb_round")
    lb_round:setString(helper:getSortTx(self.sort))
    -- lb_roundEndTIme
    local remainTime = helper:getStageRemainTime(self.round_id, self.sort, self.step) + 1
    local lb_roundEndTIme = self.ccbNode:labelTTFForName("lb_roundEndTIme")
    if self.endTimeShare then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.endTimeShare)
    end
    if remainTime > 0 then
        local hours = math.floor(remainTime / 3600)
        local minutes = math.floor((remainTime - hours * 3600) / 60)
        local seconds = math.floor(remainTime - hours * 3600 - minutes * 60)
        lb_roundEndTIme:setString(helper.txt.god_escort_txt_81 .. string.format("%02d:%02d:%02d", hours, minutes, seconds))
        self.endTimeShare =
            CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(
            function(dt)
                if remainTime > 0 then
                    local hours = math.floor(remainTime / 3600)
                    local minutes = math.floor((remainTime - hours * 3600) / 60)
                    local seconds = math.floor(remainTime - hours * 3600 - minutes * 60)
                    lb_roundEndTIme:setString(helper.txt.god_escort_txt_81 .. string.format("%02d:%02d:%02d", hours, minutes, seconds))
                else -- 倒计时结束
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.endTimeShare)
                    self.endTimeShare = nil
                    lb_roundEndTIme:setString(helper.txt.god_escort_txt_81 .. helper.txt.god_escort_txt_3)
                    self:updateNetData()
                end
                remainTime = remainTime - dt
            end,
            0.5,
            false
        )
    end
    -- lb_un
    for i = 1, 6 do
        local lb_un = self.ccbNode:labelTTFForName("lb_un" .. i)
        if lb_un then
            lb_un:setString(helper.tex[helper.universeKey[i]])
        end
    end
    self:refreshShip()

    -- sp_universe
    local sp_universe = self.ccbNode:spriteForName("sp_universe")
    -- sp_universe -- 红点
    if sp_universe:getChildByTag(1) then
        sp_universe:removeChildByTag(1, true)
    end
    local hasRed = helper:isRewardRed(0)
    if hasRed then
        local bit = CCSprite:createWithSpriteFrameName("bounty_bit.png")
        bit:setPosition(ccp(75, 50))
        sp_universe:addChild(bit, 0, 1)
    end
end

function game_god_escort_universeRun:updateNetData()
    local function responseMethod(tag, gameData)
        if self.isDestroy then return end
        local data = gameData:getNodeWithKey("data")
        local gameData = json.decode(data:getFormatBuffer()) or {}
        self.init(self, {gameData = gameData, area_id = self.area_id, betting = self.betting})
        self:refreshUi()
    end
    helper.sendHttpRequest(responseMethod, game_url.getUrlForKey("highway_area_index"), http_request_method.GET, {area_id = self.area_id}, "highway_area_index")
end

function game_god_escort_universeRun:refreshShip()
    local showData = {}
    for k, v in pairs(self.shipDatas) do
        table.insert(showData, v)
    end
    table.sort(
        showData,
        function(a, b)
            return a.ship_id < b.ship_id
        end
    )
    -- 创建船
    for i = 1, 8 do
        local nd_ship = self.ccbNode:nodeForName("nd_ship" .. i)
        local shipData = showData[i] or {}
        function onBtnClick(target, event)
            local tagNode = tolua.cast(target, "CCNode")
            local shipData
            for k, v in pairs(self.shipDatas) do
                if v.ship_id == i then
                    shipData = v
                    break
                end
            end
            local btnTag = tagNode:getTag()
            if btnTag == 2 then
                if not self.betShipId then
                    game_util:addMoveTips({text = helper.txt.god_escort_txt_75})
                    return
                end
                if self.sort == 1 then -- 准备阶段
                    if i ~= self.betShipId then
                        game_util:addMoveTips({text = helper.txt.god_escort_txt_76})
                        return
                    end
                    game_scene:addPop(
                        "game_god_escort_voyagePre",
                        {
                            gameData = self.gameData,
                            area_id = self.area_id,
                            ship_id = shipData.ship_id,
                            cb = function(gameData)
                                -- self.shouldReCreateShip = true
                                self:updateGameData(gameData)
                                self:refreshUi()
                            end
                        }
                    )
                end

                if self.sort == 3 or self.sort == 6 then -- 休整阶段
                    game_scene:addPop(
                        "game_god_escort_voyageRest",
                        {
                            gameData = self.gameData,
                            area_id = self.area_id,
                            ship_id = shipData.ship_id,
                            isBetShip = self.betShipId == i,
                            cb = function(gameData)
                                self:updateGameData(gameData)
                                self:refreshUi()
                            end
                        }
                    )
                end
                if self.sort == 4 then -- 冲刺阶段
                    local achieve_ts = shipData.achieve_ts or 0
                    local mileage = helper:getTotalMileage(shipData, self.round_id, self.sort, self.step, self.ts_start, achieve_ts)
                    local point = helper.cfg.highway_time[tonumber(self.round_id)].point
                    if mileage < point then
                        game_util:addMoveTips({text = helper.txt.god_escort_txt_116})
                        return
                    end
                    game_scene:addPop(
                        "game_god_escort_voyageSprint",
                        {
                            gameData = self.gameData,
                            area_id = self.area_id,
                            ship_id = shipData.ship_id,
                            isBetShip = self.betShipId == i,
                            cb = function(gameData)
                                self:updateGameData(gameData)
                                self:refreshUi()
                            end
                        }
                    )
                end
            end
        end
        local ccbNode
        if self.shouldReCreateShip then
            nd_ship:removeAllChildrenWithCleanup(true)
            ccbNode = luaCCBNode:create()
            ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick)
            ccbNode:openCCBFile("ccb/ui_god_escort_shipItem.ccbi")
            nd_ship:addChild(ccbNode)
            self.shipRecord[i] = ccbNode
        else
            ccbNode = self.shipRecord[i]
        end

        local pos = self.step
        if self.step == 5 then
            pos = 4
        end
        if self.step == 0 then
            pos = 1
        end
        -- sp_ship
        local lv = shipData.lv or 1
        local sp_ship = ccbNode:spriteForName("sp_ship")
        if self.sort == 1 then -- 准备阶段不显示飞机的升级外观
            lv = 1
        end
        sp_ship:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_ship_" .. lv .. ".png"))

        -- 当前里程
        local achieve_ts = shipData.achieve_ts or 0
        local curMileage = helper:getTotalMileage(shipData, self.round_id, self.sort, self.step, self.ts_start, achieve_ts)
        -- max里程
        local maxMileage = self.maxMileage
        -- 飞船起始坐标
        local startPos = helper.shipPos[1][i]
        local endPos = helper.shipPos[4][i]
        local startScale = helper.shipScale[1]
        local endScale = helper.shipScale[4]
        if maxMileage == 0 then
            nd_ship:setPosition(ccp(startPos[1], startPos[2]))
            nd_ship:setScale(startScale)
        else
            local ratio = curMileage / maxMileage
            if ratio > 1 then
                ratio = 1
            end
            local curPos = {
                startPos[1] + (endPos[1] - startPos[1]) * ratio,
                startPos[2] + (endPos[2] - startPos[2]) * ratio
            }
            nd_ship:setPosition(ccp(curPos[1], curPos[2]))
            local curScale = startScale + (endScale - startScale) * ratio
            nd_ship:setScale(curScale)
        end

        -- btn_click
        local btn_click = ccbNode:controlButtonForName("btn_click")
        btn_click:setOpacity(0)
        -- lb_status
        local lb_status = ccbNode:labelTTFForName("lb_status")
        lb_status:setString(helper.txt[helper.shipStatus[self.sort]])
        -- lb_value
        local lb_value = ccbNode:labelTTFForName("lb_value")
        lb_value:setString(curMileage .. helper.txt.god_escort_txt_45)
        -- sp_tou
        ccbNode:spriteForName("sp_tou"):setVisible(shipData.ship_id and self.betShipId == shipData.ship_id or false)
    end

    self.shouldReCreateShip = false
end

return game_god_escort_universeRun
