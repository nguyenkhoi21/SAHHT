local game_god_escort_bet = {
    selectUniverseId = 1,
    endTimeShare = nil,
    selectMyBetView = false
}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_bet.destroy(self)
    cclog("[神域押镖] game_god_escort_bet.destroy(self)")
    self.isDestroy = true
    if self.endTimeShare then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.endTimeShare)
        self.endTimeShare = nil
    end
    self.selectUniverseId = 1
    self.selectMyBetView = false
end

function game_god_escort_bet.createUi(self)
    self.isDestroy = false
    cclog("[神域押镖] game_god_escort_bet.createUi(self)")
    local ccbNode = luaCCBNode:create()
    local function onBtnClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then --返回
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_godfield_mainBig",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")
        elseif btnTag == 2 then -- 成就
            local function responseMethod(tag, gameData)
                local data = gameData:getNodeWithKey("data")
                local gameData = json.decode(data:getFormatBuffer()) or {}
                game_scene:addPop("game_god_escort_achieve", {gameData = gameData, cb = function(tasks)
                    self.tasks = tasks
                    self:refreshUi()
                end})
            end
            helper.sendHttpRequest(responseMethod, game_url.getUrlForKey("highway_task_index"), http_request_method.GET, nil, "highway_task_index")
        elseif btnTag == 3 then -- 店铺
            local function responseMethod(tag, gameData)
                local data = gameData:getNodeWithKey("data")
                local gameData = json.decode(data:getFormatBuffer()) or {}
                game_scene:enterGameUi("game_god_escort_shop", {gameData = gameData})
                self:destroy()
            end
            helper.sendHttpRequest(responseMethod, game_url.getUrlForKey("highway_shop_index"), http_request_method.GET, {sort = 1}, "highway_shop_index")
        elseif btnTag == 4 then -- 能量
            local function responseMethod(tag, gameData)
                local data = gameData:getNodeWithKey("data")
                local gameData = json.decode(data:getFormatBuffer()) or {}
                game_scene:enterGameUi("game_god_escort_exchange_shop", {gameData = gameData})
            end
            helper.sendHttpRequest(responseMethod, game_url.getUrlForKey("highway_trans_index"), http_request_method.GET, nil, "highway_trans_index")
        elseif btnTag == 5 then -- 详情
            -- game_util:addMoveTips({text = "点击 详情"})
            game_scene:addPop("game_god_escort_detail",{openMsg = helper:getTxtById(55)})
        elseif btnTag == 6 then -- 我要下注
            self.btn_wyxz:setHighlighted(true)
            self.btn_wddz:setHighlighted(false)
            self.nd_wyxz:setVisible(true)
            self.nd_wddz:setVisible(false)
            self.selectMyBetView = false
            self:refreshRight()
        elseif btnTag == 7 then -- 我的押注
            self.btn_wyxz:setHighlighted(false)
            self.btn_wddz:setHighlighted(true)
            self.nd_wyxz:setVisible(false)
            self.nd_wddz:setVisible(true)
            self.selectMyBetView = true
            self:refreshRight()
        elseif btnTag == 8 then -- 前往宇宙
            local function responseMethod(tag, gameData)
                local data = gameData:getNodeWithKey("data")
                local gameData = json.decode(data:getFormatBuffer()) or {}
                game_scene:enterGameUi("game_god_escort_universe", {gameData = gameData})
            end
            helper.sendHttpRequest(responseMethod, game_url.getUrlForKey("highway_all_area_index"), http_request_method.GET, nil, "highway_all_area_index_from_bet")
        elseif btnTag == 9 then -- 排行榜
            local function responseMethod(tag, gameData)
                local data = gameData:getNodeWithKey("data")
                local gameData = json.decode(data:getFormatBuffer()) or {}
                game_scene:addPop("game_god_escort_rank", {gameData = gameData})
            end
            local key = "highway_week_rank_index"
            local params = {}
            helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick)
    ccbNode:openCCBFile("ccb/ui_god_escort_bet.ccbi")
    self.ccbNode = ccbNode

    ----- 翻译
    game_util:setCCControlButtonTitle(ccbNode:controlButtonForName("btn_rank"), helper.txt.god_escort_txt_119)
    ccbNode:labelTTFForName("lb_leftTitle"):setString(helper.txt.god_escort_txt_2)
    ----- 触摸优先级
    ccbNode:controlButtonForName("btn_xq"):setTouchPriority(helper.betTouchPriority)
    ccbNode:controlButtonForName("btn_cj"):setTouchPriority(helper.betTouchPriority)
    ccbNode:controlButtonForName("btn_dp"):setTouchPriority(helper.betTouchPriority)
    ccbNode:controlButtonForName("btn_nl"):setTouchPriority(helper.betTouchPriority)
    ccbNode:controlButtonForName("btn_qwyz"):setTouchPriority(helper.betTouchPriority)
    self.btn_wyxz = ccbNode:controlButtonForName("btn_wyxz")
    self.btn_wyxz:setTouchPriority(helper.betTouchPriority)
    self.btn_wyxz:setHighlighted(true)
    self.btn_wddz = ccbNode:controlButtonForName("btn_wddz")
    self.btn_wddz:setTouchPriority(helper.betTouchPriority)
    self.btn_wddz:setHighlighted(false)
    self.nd_wyxz = ccbNode:nodeForName("nd_wyxz")
    self.nd_wyxz:setVisible(true)
    self.nd_wddz = ccbNode:nodeForName("nd_wddz")
    self.nd_wddz:setVisible(false)
    return ccbNode
end

function game_god_escort_bet.init(self, t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
    end

    self:updateData(self.m_tGameData)

end

function game_god_escort_bet.create(self, t_params)
    cclog("[神域押镖] game_god_escort_bet.create(self,t_params)")
    game_data.m_cacheData.gift_box = nil
    self:init(t_params)
    local scene = CCScene:create()
    scene:addChild(self:createUi())
    self:refreshUi()
    return scene
end

function game_god_escort_bet.refreshUi(self)
    cclog("[神域押镖] game_god_escort_bet.refreshUi(self)")
    self:refreshLeft()
    self:refreshRight()
end

--[[
    刷新左侧界面
]]
function game_god_escort_bet.refreshLeft(self)
    cclog("[神域押镖] game_god_escort_bet.refreshLeft(self)")
    -- 第x轮
    if self.round_id and self.round_id > 0 then
        local round = self.round_id % 2 == 0 and math.floor(self.round_id / 2) or math.floor(self.round_id / 2) + 1
        self.ccbNode:labelTTFForName("lb_leftRound"):setString(string.format(helper.txt.god_escort_txt_86, round))
    else
        self.ccbNode:labelTTFForName("lb_leftRound"):setString("")
    end
    ----- 翻译
    self.ccbNode:labelTTFForName("lb_leftState"):setString(helper:getSortTx(self.sort))
    -- 倒计时
    local remainTime = helper:getStageRemainTime(self.round_id, self.sort, self.step) + 1
    local lb_leftEndTime = self.ccbNode:labelTTFForName("lb_leftEndTime")
    if self.endTimeShare then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.endTimeShare)
    end
    if remainTime > 0 then
        local hours = math.floor(remainTime / 3600)
        local minutes = math.floor((remainTime - hours * 3600) / 60)
        local seconds = math.floor(remainTime - hours * 3600 - minutes * 60)
        lb_leftEndTime:setString(string.format("%02d:%02d:%02d", hours, minutes, seconds))
        self.endTimeShare =
            CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(
            function(dt)
                if remainTime > 0 then
                    local hours = math.floor(remainTime / 3600)
                    local minutes = math.floor((remainTime - hours * 3600) / 60)
                    local seconds = math.floor(remainTime - hours * 3600 - minutes * 60)
                    lb_leftEndTime:setString(string.format("%02d:%02d:%02d", hours, minutes, seconds))
                else -- 倒计时结束
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.endTimeShare)
                    self.endTimeShare = nil
                    lb_leftEndTime:setString(helper.txt.god_escort_txt_3)
                    self:updateNetData()
                end
                remainTime = remainTime - dt
            end,
            0.5,
            false
        )
    else
        lb_leftEndTime:setString(helper.txt.god_escort_txt_3)
    end
    ----- 翻译
    self.ccbNode:labelTTFForName("lb_leftDesc1"):setString(helper.txt.god_escort_txt_4)
    -- 奖励
    local reward = {}
    for k, v in ipairs(helper.cfg.highway_reward) do
        if v.sort == 1 then
            for k1, v1 in ipairs(v.reward) do
                table.insert(reward, v1)
            end
        end
    end
    local nd_reward = self.ccbNode:nodeForName("nd_reward")
    nd_reward:removeAllChildrenWithCleanup(true)
    nd_reward:addChild(self:createRewardTable(nd_reward:getContentSize(), reward))
    -- 当前能量
    local power = self.power
    local lb_curPower1 = self.ccbNode:labelTTFForName("lb_curPower1")
    lb_curPower1:setString(helper.txt.god_escort_txt_6)
    local lb_curPower2 = self.ccbNode:labelTTFForName("lb_curPower2")
    lb_curPower2:setString(power)
    lb_curPower2:setPositionX(lb_curPower1:getPositionX() + lb_curPower1:getContentSize().width + 5)
    -- btn_cj
    local btn_cj = self.ccbNode:controlButtonForName("btn_cj")
    if btn_cj:getChildByTag(1) then
        btn_cj:removeChildByTag(1, true)
    end
    local hasRed1 = helper:isTaskRed(self.tasks)
    local hasRed2 = helper:isRewardRed(1)
    if hasRed1 or hasRed2 then
        local bit = CCSprite:createWithSpriteFrameName("bounty_bit.png")
        bit:setPosition(ccp(30, 30))
        btn_cj:addChild(bit, 0, 1)
    end
end

--[[
    刷新右侧界面
]]
function game_god_escort_bet.refreshRight(self)
    cclog("[神域押镖] game_god_escort_bet.refreshRight(self)")

    -- 宇宙状态
    if not self.selectMyBetView then
        -- 宇宙列表
        local universeList = helper:getAllUniverseConfig()
        local nd_universeList = self.ccbNode:nodeForName("nd_universeList")
        nd_universeList:removeAllChildrenWithCleanup(true)
        local showData = {}
        for k, v in ipairs(universeList) do
            if helper:isUniverseOpen(tonumber(k)) then
                table.insert(showData, {id = tonumber(k), name = v})
            end
        end
        if not helper:isUniverseOpen(tonumber(self.selectUniverseId)) then -- 已领取
            self.selectUniverseId = showData[1].id
        end
        nd_universeList:addChild(self:createUniverseList(nd_universeList:getContentSize(), showData))
        -- lb_universeName
        local universeName = helper.txt[helper.universeKey[self.selectUniverseId]]
        universeName = string.gsub(universeName, " Vũ Trụ", "")
        self.ccbNode:labelTTFForName("lb_universeName"):setString(universeName)
        local universeList = {}
        local ship_data = self.ship_data
        local showNotice = true
        local nd_universeStateList = self.ccbNode:nodeForName("nd_universeStateList")
        if ship_data[tostring(self.selectUniverseId)] then
            for k, v in pairs(ship_data[tostring(self.selectUniverseId)]) do
                table.insert(universeList, v)
            end
            table.sort(
                universeList,
                function(a, b)
                    if a.odds == b.odds then
                        return a.ship_id < b.ship_id
                    else
                        return a.odds > b.odds
                    end
                end
            )
            nd_universeStateList:removeAllChildrenWithCleanup(true)
            nd_universeStateList:addChild(self:createUniverseStateList(nd_universeStateList:getContentSize(), universeList))
            showNotice = #universeList == 0
        else
            nd_universeStateList:removeAllChildrenWithCleanup(true)
            showNotice = true
        end
        -- lb_wyxz_notice
        local lb_wyxz_notice = self.ccbNode:labelTTFForName("lb_wyxz_notice")
        lb_wyxz_notice:setString(helper.txt.god_escort_txt_78)
        lb_wyxz_notice:setVisible(showNotice)
    else
        local showData = {}
        for k, v in pairs(self.betting) do
            local round_id = tonumber(k)
            for k1, v1 in pairs(v) do
                v1.round_id = round_id
                v1.universeId = tonumber(k1)
                table.insert(showData, v1)
            end
        end
        table.sort(
            showData,
            function(a, b)
                if a.round_id == b.round_id then
                    return a.universeId < b.universeId
                else
                    return a.round_id < b.round_id
                end
            end
        )
        local nd_wddzList = self.ccbNode:nodeForName("nd_wddzList")
        nd_wddzList:removeAllChildrenWithCleanup(true)
        nd_wddzList:addChild(self:createMyBetList(nd_wddzList:getContentSize(), showData))
    end
    -- btn_qwyz
    local btn_qwyz = self.ccbNode:controlButtonForName("btn_qwyz")
    local hasRed = helper:isRewardRed(0)
    if btn_qwyz:getChildByTag(1) then
        btn_qwyz:removeChildByTag(1, true)
    end
    if hasRed then
        local bit = CCSprite:createWithSpriteFrameName("bounty_bit.png")
        bit:setPosition(ccp(70, 33))
        btn_qwyz:addChild(bit, 0, 1)
    end
end

function game_god_escort_bet.createRewardTable(self, viewSize, rewardList)
    local params = {}
    params.viewSize = viewSize
    params.row = 1
    params.column = 4 --列
    params.totalItem = #rewardList
    params.touchPriority = helper.betTouchPriority
    params.showPoint = false
    params.itemActionFlag = false
    params.direction = kCCScrollViewDirectionVertical --纵向
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height / params.row)
    params.newCell = function(tableView, index)
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5, 0.5))
            node:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5))
            local itemGift = rewardList[index + 1]
            local icon, name, count = game_util:getRewardByItemTable(itemGift)
            if icon then
                icon:setScale(0.7)
                icon:setAnchorPoint(ccp(0.5, 0.5))
                icon:setPosition(ccp(0, 0))
                node:addChild(icon, 10)
            end
            if count then
                local tempLabel = game_util:createLabelTTF({text = "x" .. count, color = ccc3(255, 255, 255), fontSize = 8})
                tempLabel:setPosition(ccp(itemSize.width * 0.3, itemSize.height * 0.1 - 15))
                node:addChild(tempLabel, 10)
            end

            cell:addChild(node)
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, item)
        if eventType == "ended" and item then
            local itemCfg = rewardList[index + 1]
            game_util:lookItemDetal(itemCfg)
        end
    end
    params.pageChangedCallFunc = function(totalPage, curPage)
    end
    return TableViewHelper:create(params)
end

function game_god_escort_bet.createUniverseList(self, viewSize, rewardList)
    local params = {}
    params.viewSize = viewSize
    params.row = 6
    params.column = 1 --列
    params.totalItem = #rewardList
    params.touchPriority = helper.betTouchPriority
    params.showPoint = false
    params.itemActionFlag = false
    params.direction = kCCScrollViewDirectionVertical --纵向
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height / params.row)
    params.newCell = function(tableView, index)
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5, 0.5))
            -- node:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5))
            cell:addChild(node)
            local data = rewardList[index + 1]
            -- 创建底板
            local db = self.selectUniverseId == data.id and "Common_Btn_cebian01.png" or "Common_Btn_cebian02.png"
            local sp = CCSprite:createWithSpriteFrameName(db)
            if sp then
                sp:setAnchorPoint(ccp(0.5, 0.5))
                sp:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5))
                node:addChild(sp)
            end
            -- 创建文本
            local universeName = helper.txt[data.name]
            universeName = string.gsub(universeName, " Vũ Trụ", "")
            local lb_universe = game_util:createLabelTTF({text = universeName, color = game_util.c3b_parse("#beeaff"), fontSize = 10})
            lb_universe:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5))
            node:addChild(lb_universe)
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, item)
        if eventType == "ended" and item then
            if self.selectMyBetView then
                return
            end
            local data = rewardList[index + 1]
            self.selectUniverseId = data.id
            self:refreshRight()
        end
    end
    return TableViewHelper:create(params)
end

-- 下注列表
function game_god_escort_bet.createUniverseStateList(self, viewSize, rewardList)
    local params = {}
    params.viewSize = viewSize
    params.row = 4
    params.column = 1 --列
    params.totalItem = #rewardList
    params.touchPriority = helper.betTouchPriority
    params.showPoint = false
    params.itemActionFlag = false
    params.direction = kCCScrollViewDirectionVertical --纵向
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height / params.row)
    params.newCell = function(tableView, index)
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5, 0.5))
            cell:addChild(node)

            local ccbNode = luaCCBNode:create()
            ccbNode:openCCBFile("ccb/ui_god_escort_universe_state_item.ccbi")
            node:addChild(ccbNode)
            local data = rewardList[index + 1]
            -- lb_idx
            ccbNode:labelTTFForName("lb_idx"):setString(tostring(data.ship_id))
            -- nd_head
            local nd_head = ccbNode:nodeForName("nd_head")
            nd_head:removeAllChildrenWithCleanup(true)
            local sp = helper:createShipSprite(data.lv)
            sp:setScale(30 / sp:getContentSize().width)
            nd_head:addChild(sp)
            -- lb_desc1
            ccbNode:labelTTFForName("lb_desc1"):setString(helper:getTxtById((self.selectUniverseId - 1) * 8 + data.ship_id + 6 ))
            -- 赔率 lb_odds
            local odds = data.odds / 100
            ccbNode:labelTTFForName("lb_odds"):setString(string.format(helper.txt.god_escort_txt_8, odds))
            -- lb_name2
            local randomTx = helper:getRandomTxtBySort(5)
            ccbNode:labelTTFForName("lb_desc2"):setString(randomTx)
            -- btn_xz
            local btn_xz = ccbNode:controlButtonForName("btn_xz")
            game_util:setCCControlButtonTitle(btn_xz, helper.txt.god_escort_txt_121)
            btn_xz:setColor(self.sort == 1 and ccc3(255,255,255) or ccc3(100,100,100))
            btn_xz:addHandleOfControlEvent(
                function()
                    cclog("[神域押镖] 点击下注按钮 id: " .. (index + 1))
                    if not helper:isUniverseOpen(self.selectUniverseId) then
                        game_util:addMoveTips({text = helper.txt.god_escort_txt_114})
                        return
                    end

                    if self.sort ~= 1 then -- 非准备阶段不能押注
                        game_util:addMoveTips({text = helper.txt.god_escort_txt_63})
                        return
                    end
                    if self.betting[tostring(self.round_id)] and self.betting[tostring(self.round_id)][tostring(self.selectUniverseId)] then -- 该宇宙已经存在押注
                        if data.ship_id == self.betting[tostring(self.round_id)][tostring(self.selectUniverseId)].ship_id then
                            game_util:addMoveTips({text = helper.txt.god_escort_txt_111})
                        else
                            game_util:addMoveTips({text = helper.txt.god_escort_txt_74})
                        end
                        return
                    end

                    game_scene:addPop(
                        "game_god_escort_power_change",
                        {
                            id = index + 1,
                            odds = data.odds,
                            area_id = self.selectUniverseId,
                            ship_id = data.ship_id,
                            round_id = self.round_id,
                            lv = data.lv,
                            cb = function(gameData)
                                if gameData then
                                    self:init({gameData = gameData})
                                    self:refreshUi()
                                end
                            end
                        }
                    )
                end,
                CCControlEventTouchUpInside
            )
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, item)
        if eventType == "ended" and item then
        end
    end
    return TableViewHelper:create(params)
end

function game_god_escort_bet.createMyBetList(self, viewSize, rewardList)
    local item_cfg = getConfig(game_config_field.item)
    local params = {}
    params.viewSize = viewSize
    params.row = 3
    params.column = 1 --列
    params.totalItem = #rewardList
    params.touchPriority = helper.betTouchPriority
    params.showPoint = false
    params.itemActionFlag = false
    params.direction = kCCScrollViewDirectionVertical --纵向
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height / params.row)
    params.newCell = function(tableView, index)
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5, 0.5))
            cell:addChild(node)

            local ccbNode = luaCCBNode:create()
            ccbNode:openCCBFile("ccb/ui_god_escort_my_bet_item.ccbi")
            node:addChild(ccbNode)

            local data = rewardList[index + 1]
            local round_id = data.round_id
            local can_reward = data.can_reward
            -- lb_desc1
            local end_time = helper.cfg.highway_time[round_id].end_time
            if can_reward == 0 then
                ccbNode:labelTTFForName("lb_desc1"):setString(string.format(helper.txt.god_escort_txt_79, end_time))
            else
                ccbNode:labelTTFForName("lb_desc1"):setString(helper.txt.god_escort_txt_80)
            end
            -- lb_desc2
            ccbNode:labelTTFForName("lb_desc2"):setString(helper.txt.god_escort_txt_35 .. helper.txt[helper.universeKey[data.universeId]] .. "-" .. helper:getTxtById((data.universeId - 1) * 8 + data.ship_id + 6 ))
            -- lb_desc310
            ccbNode:labelTTFForName("lb_desc3"):setString(helper.txt.god_escort_txt_1)
            -- sp_betDk
            -- local sp_betDk = ccbNode:nodeForName("sp_betDk")
            -- sp_betDk:removeAllChildrenWithCleanup(true)
            -- nd_icon
            local nd_icon = ccbNode:nodeForName("nd_icon")
            nd_icon:removeAllChildrenWithCleanup(true)

            local itemCfg = item_cfg:getNodeWithKey("9101353")
            local sp = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr())
            sp:setScale(30 / sp:getContentSize().width)
            nd_icon:addChild(sp)
            local lb = game_util:createLabelTTF({text = "x" .. data.num, color = ccc3(255, 255, 255), fontSize = 8})
            nd_icon:addChild(lb)
            lb:setPosition(20, -10)
            -- sp_status
            local sp_status = ccbNode:spriteForName("sp_status")
            local can_reward = data.can_reward
            if can_reward == 0 then -- 未开奖
                sp_status:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("Img_tuohuang_dai.png"))
            end
            if can_reward == 1 then -- 中
                sp_status:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("Img_tuohuang_zhong.png"))
            end
            if can_reward == 2 then -- 落
                sp_status:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("Img_tuohuang_luo.png"))
            end
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, item)
        if eventType == "ended" and item then
        end
    end
    return TableViewHelper:create(params)
end

--[[
    更新游戏数据
]]
function game_god_escort_bet:updateData(m_tGameData)
    self.round_id = m_tGameData.round_id or 0 -- 回合数 对应highway_time的id
    self.step = m_tGameData.step or 0 -- 航行阶段  1-5
    self.sort = m_tGameData.sort or 0 -- 对应 highway_time 里的timelist
    self.power = m_tGameData.power or 0 -- 当前能量
    game_data.m_cacheData.escort_power = self.power
    self.ship_data = m_tGameData.ship_data or {} -- 船数据
    self.betting = m_tGameData.betting or m_tGameData.self_betting or {}
    cclog("[神域押镖] game_god_escort_bet:updateData(m_tGameData) self.round_id = " .. self.round_id)
    cclog("[神域押镖] game_god_escort_bet:updateData(m_tGameData) self.step = " .. self.step)
    cclog("[神域押镖] game_god_escort_bet:updateData(m_tGameData) self.sort = " .. self.sort)
    cclog("[神域押镖] game_god_escort_bet:updateData(m_tGameData) self.power = " .. self.power)
    if m_tGameData.tasks then
        self.tasks = m_tGameData.tasks
    end

    if m_tGameData.gift_box then
        game_data.m_cacheData.gift_box = m_tGameData.gift_box
    end
end

--[[
    更新网络数据
]]
function game_god_escort_bet:updateNetData()
    local function responseMethod(tag, gameData)
        if self.isDestroy then return end
        local data = gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
        self:updateData(self.m_tGameData)
        self:refreshUi()
    end
    helper.sendHttpRequest(responseMethod, game_url.getUrlForKey("highway_index"), http_request_method.GET, nil, "highway_index")
end

return game_god_escort_bet
