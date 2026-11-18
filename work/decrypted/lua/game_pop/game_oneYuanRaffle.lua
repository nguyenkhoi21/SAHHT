--[[
    一元夺宝
]]
local game_oneYuanRaffle = {
    inviter_open = getConfig(game_config_field.inviter_open) and json.decode(getConfig(game_config_field.inviter_open):getFormatBuffer())["1"] or {},
    m_params = nil,
    debug = true,
    selectPage = 1,
    m_pay_client = nil,
    list1 = nil,
    list2 = nil,
    list3 = nil,
    list3Data = {},
    netIdx = 0,
}

function game_oneYuanRaffle.destroy(self)
    self.m_rootNode = nil
    self.m_params = nil
    self.selectPage = 1
    self.m_ccbNode = nil
    self.m_pay_client = nil
    self.list1 = nil
    self.list2 = nil
    self.list3 = nil
    self.list3Data = {}
    self.netIdx = 0
end

function game_oneYuanRaffle.back(self, type)
    game_scene:removePopByName("game_oneYuanRaffle")
    self:destroy()
end

function game_oneYuanRaffle.createUi(self)
    local ccbNode = luaCCBNode:create()
    local function onMainBtnClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if self.m_flag == true then
            return
        end

        if btnTag == 999 then
            self:back()
        elseif btnTag == 2 then -- 夺宝
            self:joinRaffle()
        elseif btnTag == 3 then -- 跳转充值
            -- local function responseMethod(tag, gameData)
            --     local data = gameData:getNodeWithKey("data")
            --     game_scene:enterGameUi("ui_vip", {gameData = gameData})
            --     self:destroy()
            -- end
            -- network.sendHttpRequest(responseMethod, game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil, "vip_buy_step")
            -- 
            local serverTime = game_data:getVirtualServerTime()
            if serverTime >= self.reward_time then
                game_util:addMoveTips({text = "Thời gian tham gia đã qua"})
                return
            end
            self:doCharge()
        elseif btnTag == 4 then -- 活动详情
            local cfg = self.cfg.crowdfunding[tostring(self.version)]
            game_scene:addPop("game_active_limit_detail_pop", {m_openMsg = cfg.des})
        elseif btnTag == 5 then -- 参与实况
            self.selectPage = 1
            self:refreshUi()
        elseif btnTag == 6 then -- 我的记录
            self.selectPage = 2
            self:refreshUi()
        elseif btnTag == 7 then -- 开奖名单
            self.selectPage = 3
            self:refreshUi()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_oneYuanRaffle_pop.ccbi")

    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        elseif eventType == "ended" then
        end
    end

    self.m_root_layer:registerScriptTouchHandler(onTouch, false, GLOBAL_TOUCH_PRIORITY - 1, true)
    self.m_root_layer:setTouchEnabled(true)
    self.m_ccbNode = ccbNode

    self.tx = {
        -- oneYuanRaffle1 = "Đếm ngược tham gia: ", -- "活动倒计时"
        oneYuanRaffle2 = "Đã kết thúc", -- "已结束"
        oneYuanRaffle3 = "Số lần tham gia: ", -- "参与次数"
        oneYuanRaffle4 = "Tham gia Đoạt Bảo rồi", -- "参与了夺宝"
        oneYuanRaffle5 = "ID được thưởng đặc biệt", -- "本期大奖id"
        oneYuanRaffle6 = "ID tham gia", -- 参与ID
        oneYuanRaffle7 = "Dấu thời gian", -- 时间戳
        oneYuanRaffle8 = "Người chơi", -- 玩家
        oneYuanRaffle9 = "Tham gia 1 lần", -- 参与一次
        oneYuanRaffle10 = "Tham gia thành công", -- 参与成功
        oneYuanRaffle11 = "Tình hình tham gia", -- 参与实况
        oneYuanRaffle12 = "Lịch sử của tôi", -- 我的记录
        oneYuanRaffle13 = "DS mở thưởng" -- 开奖名单
    }

    ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    ccbNode:controlButtonForName("btn_goVip"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    ccbNode:controlButtonForName("btn_info"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    ccbNode:controlButtonForName("btn_join"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    game_util:setCCControlButtonTitle(ccbNode:controlButtonForName("btn_join"), self.tx.oneYuanRaffle9)
    ccbNode:controlButtonForName("btn_page1"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    game_util:setCCControlButtonTitle(ccbNode:controlButtonForName("btn_page1"), self.tx.oneYuanRaffle11)
    ccbNode:controlButtonForName("btn_page2"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    game_util:setCCControlButtonTitle(ccbNode:controlButtonForName("btn_page2"), self.tx.oneYuanRaffle12)
    ccbNode:controlButtonForName("btn_page3"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    game_util:setCCControlButtonTitle(ccbNode:controlButtonForName("btn_page3"), self.tx.oneYuanRaffle13)

    local crowdfunding = getConfig(game_config_field.crowdfunding)
    self.cfg = {
        crowdfunding = crowdfunding and json.decode(crowdfunding:getFormatBuffer())
    }

    -- 每5秒刷新网络数据
    self.m_root_layer:runAction(
        CCRepeatForever:create(
            CCSequence:createWithTwoActions(
                CCDelayTime:create(5),
                CCCallFunc:create(
                    function()
                        self:refreshNetData()
                    end
                )
            )
        )
    )

    return ccbNode
end
--

function game_oneYuanRaffle.refreshUi(self, list3offset)
    local cfg = self.cfg.crowdfunding[tostring(self.version)]
    -- 倒计时
    self:refreshTime()
    self:refreshPage(list3offset)
    -- nd_reward
    local nd_reward = self.m_ccbNode:nodeForName("nd_reward")
    nd_reward:removeAllChildrenWithCleanup(true)
    local reward_pay = cfg.reward_pay or {}
    local reward = reward_pay[1]
    if reward then
        local icon, name, count = game_util:getRewardByItemTable(reward, true)
        if icon then
            nd_reward:addChild(icon)
            local label = CCLabelTTF:create(tostring(count), TYPE_FACE_TABLE.Arial_BoldMT, 12)
            label:setPosition(ccp(45, 5))
            icon:addChild(label, 999)
        end
    end
    -- lb_count
    local lb_count = self.m_ccbNode:labelTTFForName("lb_count")
    lb_count:setString(self.num)
    -- nd_bg
    local nd_bg = self.m_ccbNode:nodeForName("nd_bg")
    nd_bg:removeAllChildrenWithCleanup(true)
    local image = cfg.image
    if image then
        local bg = CCSprite:create("ccbResources/oneYuanRaffle/" .. image)
        if not bg then
            bg = CCSprite:create("ccbResources/oneYuanRaffle/shoppe_1_1.png")
        end
        if bg then
            nd_bg:addChild(bg)
        end
    end
end

--[[--
    初始化
]]
function game_oneYuanRaffle.init(self, t_params)
end
--[[--
    创建ui入口并初始化数据
]]
function game_oneYuanRaffle.create(self, t_params)
    local gameData = t_params.gameData or {}
    local m_data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
    self:updateNetData(m_data)
    self:init(t_params)
    self.m_params = t_params
    self.m_popUi = self:createUi()
    self:refreshUi()
    return self.m_popUi
end

--[[--
    回调方法
]]
function game_oneYuanRaffle.callBackFunc(self)
    local callBackFunc = self.callBackFunc
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc()
    end
end

function game_oneYuanRaffle.updateNetData(self, data)
    self.flag = data.flag or 0 -- number 是否能触发夺宝
    self.num = data.num or 0 -- number 夺宝剩余次数
    self.lucky_num = data.lucky_num or {} -- table 自己的夺宝号码
    self.reward_time = data.reward_time or 0 -- number 开奖时间
    self.luck_name = data.luck_name or "" -- string 奖励夺主的名称
    self.version = data.version or 1 -- number 版本号
    self.end_time = data.end_time or 0 -- number 结束时间
    self.all_uid = data.all_uid or {} -- table (参与者UID列表)
    self.all_num = data.all_num or 0 -- number (总参与人数)
    self.join_uid = data.join_uid or {} -- table 最近参加活动的玩家
    self.self_num = data.self_num or {} -- table 自己参加的号码
    self.luck_score = data.luck_score or "" -- string 奖励夺主的号码
    self.luck_id = data.luck_id or 0 -- number 中奖的排序id

    for i = 1, #self.all_uid do
        self.list3Data[tonumber(self.all_uid[i].idx)] = self.all_uid[i]
    end
end

--[[
    参加夺宝 
]]
function game_oneYuanRaffle.joinRaffle(self)
    -- 判断活动时间
    local serverTime = game_data:getVirtualServerTime()
    if serverTime > self.end_time then
        cclog("活动已结束")
        game_util:addMoveTips({text = "Hoạt động đã kết thúc"})
        return
    end

    -- 判断次数
    if self.num <= 0 then
        cclog("夺宝次数不足")
        game_util:addMoveTips({text = "Số lần tham gia không đủ"}) -- 夺宝次数不足
        return
    end

    local function responseMethod(tag, gameData)
        local m_data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
        self:updateNetData(m_data)
        self:refreshUi()

        game_util:addMoveTips({text = self.tx.oneYuanRaffle10})
    end
    local params = {}
    network.sendHttpRequest(responseMethod, game_url.getUrlForKey("crowdfunding_add_lucky_num"), http_request_method.GET, params, "crowdfunding_add_lucky_num")
end

--[[
    刷新倒计时
]]
function game_oneYuanRaffle.refreshTime(self)
    local serverTime = game_data:getVirtualServerTime()
    local isOpenBigReward = serverTime >= self.reward_time
    local lb_endTime2 = self.m_ccbNode:labelTTFForName("lb_endTime2")
    local nd_endTime2 = self.m_ccbNode:nodeForName("nd_endTime2")
    nd_endTime2:removeAllChildrenWithCleanup(true)
    local server_time = game_data:getUserStatusDataByKey("server_time")
    local remainTime = (isOpenBigReward and self.end_time or self.reward_time) - server_time -- reward_time
    if remainTime > 0 then
        lb_endTime2:setString("")
        local function timeOverCallFun()
            nd_endTime2:removeAllChildrenWithCleanup(true)
            lb_endTime2:setString(self.tx.oneYuanRaffle2)
        end
        local timeLabel = game_util:createCountdownLabel(remainTime, timeOverCallFun, 8, 1)
        timeLabel:setColor(ccc3(106, 244, 58))
        -- timeLabel:setPosition(ccp(pX + 5, pY))
        nd_endTime2:addChild(timeLabel)
    else
        lb_endTime2:setString(self.tx.oneYuanRaffle2)
    end
end

function game_oneYuanRaffle.refreshPage(self, list3offset)
    local serverTime = game_data:getVirtualServerTime()
    local isOpenBigReward = serverTime >= self.reward_time and self.luck_score ~= "" -- 是否开奖
    local cfg = self.cfg.crowdfunding[tostring(self.version)]

    local nd_page1 = self.m_ccbNode:nodeForName("nd_page1")
    local nd_page2 = self.m_ccbNode:nodeForName("nd_page2")
    local nd_page3 = self.m_ccbNode:nodeForName("nd_page3")

    local btn_page1 = self.m_ccbNode:controlButtonForName("btn_page1")
    btn_page1:setHighlighted(self.selectPage == 1)
    local btn_page2 = self.m_ccbNode:controlButtonForName("btn_page2")
    btn_page2:setHighlighted(self.selectPage == 2)
    local btn_page3 = self.m_ccbNode:controlButtonForName("btn_page3")
    btn_page3:setEnabled(isOpenBigReward)
    btn_page3:setColor(isOpenBigReward and ccc3(255, 255, 255) or ccc3(155, 155, 155))
    btn_page3:setHighlighted(self.selectPage == 3)

    if self.selectPage == 1 then
        nd_page1:setVisible(true)
        nd_page2:setVisible(false)
        nd_page3:setVisible(false)
    elseif self.selectPage == 2 then
        nd_page1:setVisible(false)
        nd_page2:setVisible(true)
        nd_page3:setVisible(false)
    elseif self.selectPage == 3 then
        nd_page1:setVisible(false)
        nd_page2:setVisible(false)
        nd_page3:setVisible(true)
    end

    if self.selectPage == 1 then -- 参与实况
        local nd_page1_1 = self.m_ccbNode:nodeForName("nd_page1_1") -- 开奖前节点
        local nd_page1_2 = self.m_ccbNode:nodeForName("nd_page1_2") -- 开奖后节点

        -- 是否开奖
        if isOpenBigReward then -- 已开奖
            nd_page1_1:setVisible(false)
            nd_page1_2:setVisible(true)

            self.m_ccbNode:labelTTFForName("lb_page1_tx1"):setString(self.tx.oneYuanRaffle5)
            self.m_ccbNode:labelTTFForName("lb_page1_id"):setString(self.luck_id)
            self.m_ccbNode:labelTTFForName("lb_page1_time"):setString(self.luck_score)
        else -- 未开奖
            nd_page1_1:setVisible(true)
            nd_page1_2:setVisible(false)

            local tx = self.tx.oneYuanRaffle3 .. self.all_num .. "/" .. cfg.limit_max
            self.m_ccbNode:labelTTFForName("lb_page1_times1"):setString(tx)

            local offset
            if self.list1 then
                offset = self.list1:getContentOffset()
            end

            local nd_page1_names = self.m_ccbNode:nodeForName("nd_page1_names")
            nd_page1_names:removeAllChildrenWithCleanup(true)
            local tempTable = self:createPage1NamesTb(nd_page1_names:getContentSize(), self.join_uid)
            nd_page1_names:addChild(tempTable)

            self.list1 = tempTable
            if offset then
                if offset.y < nd_page1_names:getContentSize().height - tempTable:getContentSize().height then
                    offset.y = nd_page1_names:getContentSize().height - tempTable:getContentSize().height
                end
                tempTable:setContentOffset(offset)
            end
        end
    end

    if self.selectPage == 2 then -- 我的记录
        self.m_ccbNode:labelTTFForName("lb_page2_tx1"):setString(self.tx.oneYuanRaffle6)
        self.m_ccbNode:labelTTFForName("lb_page2_tx2"):setString(self.tx.oneYuanRaffle7)

        local offset
        if self.list2 then
            offset = self.list2:getContentOffset()
        end

        local nd_page2_list = self.m_ccbNode:nodeForName("nd_page2_list")
        nd_page2_list:removeAllChildrenWithCleanup(true)
        local tempTable = self:createPage2ListTb(nd_page2_list:getContentSize(), self.lucky_num)
        nd_page2_list:addChild(tempTable)

        self.list2 = tempTable
        if offset then
            if offset.y < nd_page2_list:getContentSize().height - tempTable:getContentSize().height then
                offset.y = nd_page2_list:getContentSize().height - tempTable:getContentSize().height
            end
            tempTable:setContentOffset(offset)
        end
    end

    if self.selectPage == 3 then -- 开奖名单
        self.m_ccbNode:labelTTFForName("lb_page3_tx1"):setString(self.tx.oneYuanRaffle6)
        self.m_ccbNode:labelTTFForName("lb_page3_tx2"):setString(self.tx.oneYuanRaffle8)
        self.m_ccbNode:labelTTFForName("lb_page3_tx3"):setString(self.tx.oneYuanRaffle7)

        local offset
        if self.list3 then
            offset = self.list3:getContentOffset()
        end
        local oldContentSize
        if list3offset then
            oldContentSize = self.list3:getContainer():getContentSize()
        end

        local nd_page3_list = self.m_ccbNode:nodeForName("nd_page3_list")
        nd_page3_list:removeAllChildrenWithCleanup(true)
        local tempTable = self:createPage3ListTb(nd_page3_list:getContentSize(), self.list3Data)
        nd_page3_list:addChild(tempTable)

        self.list3 = tempTable
        if offset then
            if offset.y < nd_page3_list:getContentSize().height - tempTable:getContentSize().height then
                offset.y = nd_page3_list:getContentSize().height - tempTable:getContentSize().height
            end
            tempTable:setContentOffset(offset)
        end

        if list3offset and oldContentSize then
            local newContentSize = self.list3:getContainer():getContentSize()
            tempTable:setContentOffset(ccp(0, oldContentSize.height - newContentSize.height + 20))
        end
    end
end

function game_oneYuanRaffle.createPage1NamesTb(self, viewSize, names)
    local params = {}
    params.viewSize = viewSize
    params.row = 5
    params.column = 1 --列
    params.totalItem = #names
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 2
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
            node:setContentSize(itemSize)
            node:setAnchorPoint(ccp(0.5, 0.5))
            node:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5))
            cell:addChild(node)

            -- name
            local name = names[index + 1].name or ""
            local tempLabel = game_util:createLabelTTF({text = name .. self.tx.oneYuanRaffle4, color = game_util.c3b_parse("#F6F7AF"), fontSize = 11})
            tempLabel:setPosition(ccp(node:getContentSize().width * 0.5, node:getContentSize().height * 0.5))
            node:addChild(tempLabel)
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, item)
    end
    params.pageChangedCallFunc = function(totalPage, curPage)
    end
    return TableViewHelper:create(params)
end

-- 刷新数据
function game_oneYuanRaffle.refreshNetData(self, getMoreData)
    local function responseMethod(tag, gameData)
        local m_data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
        self:updateNetData(m_data)
        local list3offset
        if getMoreData then
            list3offset = self.list3:getContentOffset()
        end
        self:refreshUi(list3offset)
    end
    local params = {}
    self.getMoreData = getMoreData
    if getMoreData then
        local startIdx = 0
        if self.list3Data and #self.list3Data > 0 then
            startIdx = self.list3Data[#self.list3Data].idx
        end
        params["start"] = startIdx + 1
        params["end"] = params["start"] + 19
    else
        params["start"] = 1
        params["end"] = 1
    end
    self.netIdx = self.netIdx + 1
    network.sendHttpRequest(responseMethod, game_url.getUrlForKey("crowdfunding_index"), http_request_method.GET, params, "crowdfunding_index" .. self.netIdx, false)
end

function game_oneYuanRaffle.createPage2ListTb(self, viewSize, names)
    local params = {}
    params.viewSize = viewSize
    params.row = viewSize.height / 22
    params.column = 1 --列
    params.totalItem = #names
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 2
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
            node:setContentSize(itemSize)
            node:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5))
            cell:addChild(node)

            -- id
            local idx = names[index + 1].idx or ""
            local tempLabel = game_util:createLabelTTF({text = idx, color = game_util.c3b_parse("#feffff"), fontSize = 9})
            tempLabel:setPosition(ccp(27.5, node:getContentSize().height * 0.5))
            node:addChild(tempLabel)
            -- time
            local score = names[index + 1].score or ""
            local tempLabel = game_util:createLabelTTF({text = score, color = game_util.c3b_parse("#feffff"), fontSize = 9})
            tempLabel:setPosition(ccp(133.5, node:getContentSize().height * 0.5))
            node:addChild(tempLabel)
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, item)
        -- if eventType == "ended" and item and self.selectPage == 1 then
        -- end
    end
    params.pageChangedCallFunc = function(totalPage, curPage)
    end
    return TableViewHelper:create(params)
end

function game_oneYuanRaffle.createPage3ListTb(self, viewSize, names)
    local params = {}
    params.viewSize = viewSize
    params.row = viewSize.height / 22
    params.column = 1 --列
    params.totalItem = #names
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 2
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
            node:setContentSize(itemSize)
            node:setAnchorPoint(ccp(0.5, 0.5))
            node:setPosition(ccp(itemSize.width * 0.5, 11))
            cell:addChild(node)

            -- id
            local idx = names[index + 1].idx or ""
            local tempLabel = game_util:createLabelTTF({text = idx, color = game_util.c3b_parse("#feffff"), fontSize = 9})
            tempLabel:setPosition(ccp(27.1, node:getContentSize().height * 0.5))
            node:addChild(tempLabel)
            -- name
            local name = names[index + 1].name or ""
            local tempLabel = game_util:createLabelTTF({text = name, color = game_util.c3b_parse("#feffff"), fontSize = 9})
            tempLabel:setPosition(ccp(118.5, node:getContentSize().height * 0.5))
            node:addChild(tempLabel)

            -- score
            local score = names[index + 1].score or ""
            local tempLabel = game_util:createLabelTTF({text = score, color = game_util.c3b_parse("#feffff"), fontSize = 9})
            tempLabel:setPosition(ccp(206, node:getContentSize().height * 0.5))
            node:addChild(tempLabel)
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, item)
        if eventType == "ended" and item then
        elseif eventType == "refresh" and item then
            self:refreshNetData(true)
        end
    end
    params.pageChangedCallFunc = function(totalPage, curPage)
    end
    return TableViewHelper:create(params)
end

function game_oneYuanRaffle.closePay(self)
    if self.m_pay_client and self.m_pay_client.destroy then
        self.m_pay_client:destroy()
        self.m_pay_client = nil
    end
end

function game_oneYuanRaffle:doCharge()
    local payCallBack = function(code, msg)
        if code == "success" then
            game_util:addMoveTips({text = "Đã mua"})
            self:refreshNetData()
            game_util:closeAlertView()
        elseif code == "failed" then
            game_util:addMoveTips({text = "Thất bại"})
            game_util:closeAlertView()
        else
            game_util:addMoveTips({text = "Nếu thanh toán xong, hãy tạo mới giao diện"})
            game_util:closeAlertView()
        end
    end

    local cfg = self.cfg.crowdfunding[tostring(self.version)]
    local id = cfg.recharge_id
    self.m_pay_client = game_util:buySthByChargeIndex(id, payCallBack)
end

return game_oneYuanRaffle
