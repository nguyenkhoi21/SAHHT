local game_god_escort_universe = {
    endTimeShare = nil
}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_universe.destroy(self)
    cclog("[神域押镖] game_god_escort_universe:destroy()")
    self.isDestroy = true
    if self.endTimeShare then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.endTimeShare)
        self.endTimeShare = nil
    end
end

function game_god_escort_universe.createUi(self)
    self.isDestroy = false
    cclog("[神域押镖] game_god_escort_universe.createUi(self)")
    local ccbNode = luaCCBNode:create()
    local function onMainClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then
            local function responseMethod(tag, gameData)
                game_scene:enterGameUi("game_god_escort_bet", {gameData = gameData})
                self:destroy()
            end
            helper.sendHttpRequest(responseMethod, game_url.getUrlForKey("highway_index"), http_request_method.GET, nil, "highway_index_from_universe")
        elseif btnTag == 2 then
            local serverTime = game_data:getVirtualServerTime()
            if serverTime - self.clickUpdateBtnTime < helper.refreshInterval then
                game_util:addMoveTips({text = helper.txt.god_escort_txt_113})
                return
            end
            self.clickUpdateBtnTime = serverTime
            self:updateNetData()
        elseif type(btnTag) == "number" and btnTag >= 11 and btnTag <= 16 then
            local id = btnTag - 10
            if not helper:isUniverseOpen(id) then
                game_util:addMoveTips({text = helper.txt.god_escort_txt_114})
                return
            end
            cclog("[神域押镖] game_god_escort_universe 打开宇宙id:" .. id)
            local function responseMethod(tag, gameData)
                local data = gameData:getNodeWithKey("data")
                local gameData = json.decode(data:getFormatBuffer()) or {}
                game_scene:enterGameUi("game_god_escort_universeRun", {gameData = gameData, area_id = id, betting = self.betting})
            end
            helper.sendHttpRequest(responseMethod, game_url.getUrlForKey("highway_area_index"), http_request_method.GET, {area_id = id}, "highway_area_index")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainClick)
    ccbNode:openCCBFile("ccb/ui_god_escort_universe.ccbi")
    self.ccbNode = ccbNode

    self.clickUpdateBtnTime = 0

    return ccbNode
end

function game_god_escort_universe.init(self, t_params)
    self.gameData = t_params.gameData
    self.round_id = self.gameData.round_id or 0 -- 回合数 对应highway_time的id
    self.step = self.gameData.step or 0 -- 航行阶段  1-5
    self.sort = self.gameData.sort or 0 -- 对应 highway_time 里的timelist
    self.betting = self.gameData.betting or {}
    if self.gameData.gift_box then
        game_data.m_cacheData.gift_box = self.gameData.gift_box
    end
end

function game_god_escort_universe.create(self, t_params)
    cclog("[神域押镖] game_god_escort_universe:create(t_params)")
    self:init(t_params)
    local ui = self:createUi()
    self:refreshUi()
    return ui
end

function game_god_escort_universe.refreshUi(self)
    cclog("[神域押镖] game_god_escort_universe:refreshUi()")
    -- lb_endTime
    local remainTime = helper:getStageRemainTime(self.round_id, self.sort, self.step) + 1
    local lb_endTime = self.ccbNode:labelTTFForName("lb_endTime")
    if self.endTimeShare then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.endTimeShare)
    end
    if remainTime > 0 then
        local hours = math.floor(remainTime / 3600)
        local minutes = math.floor((remainTime - hours * 3600) / 60)
        local seconds = math.floor(remainTime - hours * 3600 - minutes * 60)
        lb_endTime:setString(helper.txt.god_escort_txt_24 .. string.format("%02d:%02d:%02d", hours, minutes, seconds))
        self.endTimeShare =
            CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(
            function(dt)
                if remainTime > 0 then
                    local hours = math.floor(remainTime / 3600)
                    local minutes = math.floor((remainTime - hours * 3600) / 60)
                    local seconds = math.floor(remainTime - hours * 3600 - minutes * 60)
                    lb_endTime:setString(helper.txt.god_escort_txt_24 .. string.format("%02d:%02d:%02d", hours, minutes, seconds))
                else -- 倒计时结束
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.endTimeShare)
                    self.endTimeShare = nil
                    lb_endTime:setString(helper.txt.god_escort_txt_24 .. helper.txt.god_escort_txt_3)
                    self:updateNetData()
                end
                remainTime = remainTime - dt
            end,
            0.5,
            false
        )
    else
        lb_endTime:setString(helper.txt.god_escort_txt_24 .. helper.txt.god_escort_txt_3)
    end
    -- lb_un
    for i = 1, 6 do
        local lb_un = self.ccbNode:labelTTFForName("lb_un" .. i)
        if lb_un then
            lb_un:setString(helper.txt[helper.universeKey[i]])
        end

        local sp_tou = self.ccbNode:nodeForName("sp_tou" .. i)
        sp_tou:setVisible(false)
        local betRound = (self.round_id % 2 == 0 and self.round_id ~= 0) and self.round_id - 1 or self.round_id
        if self.betting[tostring(betRound)] then
            if self.betting[tostring(betRound)][tostring(i)] then
                sp_tou:setVisible(true)
            end
        end
        -- btn_u6 -- 未开启的飞船置灰
        local btn_u = self.ccbNode:controlButtonForName("btn_u" .. i)
        local color = ccc3(100, 100, 100)
        if helper:isUniverseOpen(i) then
            color = ccc3(255, 255, 255)
        end
        btn_u:setColor(color)
        -- btn_u6 -- 红点
        if btn_u:getChildByTag(1) then
            btn_u:removeChildByTag(1, true)
        end
        local hasRed = helper:isRewardRed(0)
        if hasRed and helper:isUniverseOpen(i) then
            local bit = CCSprite:createWithSpriteFrameName("bounty_bit.png")
            bit:setPosition(ccp(75, 50))
            btn_u:addChild(bit, 0, 1)
        end
    end
end

function game_god_escort_universe:updateNetData()
    local function responseMethod(tag, gameData)
        if self.isDestroy then return end
        local data = gameData:getNodeWithKey("data")
        local gameData = json.decode(data:getFormatBuffer()) or {}
        self.init(self, {gameData = gameData})
        self:refreshUi()
    end
    helper.sendHttpRequest(responseMethod, game_url.getUrlForKey("highway_all_area_index"), http_request_method.GET, nil, "highway_all_area_index_from_universe")
end

return game_god_escort_universe
