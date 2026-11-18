-------------------- 赋能大赛 首页 测试

local game_empowerContest_index = {
    funeng_competiton = getConfig(game_config_field.funeng_competiton) and json.decode(getConfig(game_config_field.funeng_competiton):getFormatBuffer()) or {},
    funeng_competiton_task = getConfig(game_config_field.funeng_competiton_task) and json.decode(getConfig(game_config_field.funeng_competiton_task):getFormatBuffer()) or {},
    funeng_competiton_rank = getConfig(game_config_field.funeng_competiton_rank) and json.decode(getConfig(game_config_field.funeng_competiton_rank):getFormatBuffer()) or {},
    funeng_competiton_gacha = getConfig(game_config_field.funeng_competiton_gacha) and json.decode(getConfig(game_config_field.funeng_competiton_gacha):getFormatBuffer()) or {},
    m_tParams = nil,
    m_taskIndexData = {},
    m_rankIndexData = {},
    m_gachaIndexData = {},
    m_selectId = 1,
    m_selectNameArr = {
        {type = "task", name = "千锤百炼", icon = "fnds_ui_14.png"},
        {type = "", name = "赋能巅峰", icon = "fnds_ui_15.png"},
        {type = "gacha", name = "赋能抽奖", icon = "fnds_ui_16.png"}
    },
    selectRankIndex = 1
}

function game_empowerContest_index.destroy(self)
    cclog("[赋能大赛] destroy")
end

function game_empowerContest_index.back(self, type)
    cclog("[赋能大赛] back")
    game_scene:enterGameUi("game_main_scene", {gameData = nil})
    self:destroy()
end

function game_empowerContest_index.createUi(self)
    local ccbNode = luaCCBNode:create()
    local function onMainBtnClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if self.m_flag == true then
            return
        end
        cclog("[赋能大赛] 点击按钮 --> " .. btnTag)

        if btnTag == 99999 then
            self:back()
        elseif btnTag == 1 then -- 抽奖一次
            if self.node_awardInfo:isVisible() then
                return
            end
            self:getGachaGetNet(1)
        elseif btnTag == 2 then -- 抽奖十次
            self:getGachaGetNet(2)
            if self.node_awardInfo:isVisible() then
                return
            end
        elseif btnTag == 3 then
            game_scene:enterGameUi("game_bloodStone_index", {})
            self:destroy()
        elseif btnTag == 4 then -- 打开抽奖预览
            self.node_awardInfo:setVisible(true)
            self:refreshAwardInfo()
        elseif btnTag == 5 then -- 关闭奖励预览
            self.node_awardInfo:setVisible(false)
            self.node_awardInfos:removeAllChildrenWithCleanup(true)
        elseif btnTag == 6 then -- tips
            local funeng = game_data:getAlertsDataByKey("funeng") or 1 -- 总版本号
            game_scene:addPop("game_active_limit_detail_pop", {enterType = funeng, openType = "empowerContest_tips"})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_empowerContest_index.ccbi")

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_empowerContest_res.plist")

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

    ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    ccbNode:controlButtonForName("btn_gacha1"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    ccbNode:controlButtonForName("btn_gacha10"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    ccbNode:controlButtonForName("btn_closeAwardInfo"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    ccbNode:controlButtonForName("btn_jump"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    ccbNode:controlButtonForName("btn_tips"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    ccbNode:controlButtonForName("btn_openGachaPreview"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)

    self.node_lLIst = ccbNode:nodeForName("node_lLIst")
    self.node_qcbl = ccbNode:nodeForName("node_qcbl")
    self.node_fndf = ccbNode:nodeForName("node_fndf")
    self.node_fncj = ccbNode:nodeForName("node_fncj")
    self.node_awardInfo = ccbNode:nodeForName("node_awardInfo")
    self.node_awardInfo:setVisible(false)
    self.node_awardInfos = ccbNode:nodeForName("node_awardInfos")
    self.lb_endTime = ccbNode:labelTTFForName("lb_endTime")

    self.m_selectId = 1

    return ccbNode
end
--

function game_empowerContest_index.refreshUi(self, scrollToSelect)
    self:refreshLList()
    self:refreshRight()

    local funeng = game_data:getAlertsDataByKey("funeng") or 1 -- 总版本号
    local cfg = self.funeng_competiton[tostring(funeng)] or {}
    local show_end_time = cfg.show_end_time
    -- 将字符串转换为时间戳
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = show_end_time:match(pattern)
    local timeStamp = os.time({year = year, month = month, day = day, hour = hour, min = min, sec = sec})
    -- 使用os.date根据时间戳格式化时间
    local formattedTime = os.date("%H giờ %M phút %S giây ngày %d tháng %m", timeStamp)
    self.lb_endTime:setString(string.format("HĐ đến %s", formattedTime))
end

function game_empowerContest_index:refreshLList()
    local node_lLIst = self.node_lLIst

    local hasTaskRed = self:getTaskRedDot() -- 任务红点
    local hasGachaRed = self:getGachaRedDot() -- 抽奖红点

    node_lLIst:removeAllChildrenWithCleanup(true)
    local params = {
        viewSize = node_lLIst:getContentSize(),
        row = 5, -- 行
        column = 1, -- 列
        totalItem = #self.m_selectNameArr,
        touchPriority = GLOBAL_TOUCH_PRIORITY - 4,
        showPoint = false,
        itemActionFlag = false,
        direction = kCCScrollViewDirectionVertical, --纵向
        newCell = function(tableView, index)
            local cell = tableView:dequeueCell()
            if cell == nil then
                cell = CCTableViewCell:new()
                cell:autorelease()
            end
            local data = self.m_selectNameArr[index + 1]
            cclog2(data, "[赋能大赛] 左边列表item数据")
            cell:removeAllChildrenWithCleanup(true)

            local ccbNode = luaCCBNode:create()
            ccbNode:openCCBFile("ccb/ui_empowerContest_lItem.ccbi")
            cell:addChild(ccbNode)

            -- sp_button
            local sp_button = ccbNode:spriteForName("sp_button")
            sp_button:setDisplayFrame(display.newSpriteFrame(data.icon))
            -- 红点
            if (hasTaskRed and data.type == "task") or (hasGachaRed and data.type == "gacha") then
                local tips_reward = CCSprite:createWithSpriteFrameName("public_new2.png")
                if tips_reward then
                    local tempSize = sp_button:getContentSize()
                    tips_reward:setPosition(ccp(tempSize.width - 30, tempSize.height - 25))
                    sp_button:addChild(tips_reward)
                end
            end
            -- sp_select
            local sp_select = ccbNode:spriteForName("sp_select")
            sp_select:setVisible(self.m_selectId == index + 1)

            return cell
        end,
        itemOnClick = function(eventType, index, item)
            if eventType == "ended" and item then
                self.m_selectId = index + 1
                if index + 1 == 1 then
                    self:getTaskIndexNet()
                elseif index + 1 == 2 then
                    self.selectRankIndex = 1
                    self:getRankIndexNet()
                elseif index + 1 == 3 then
                    self:getGachaIndexNet()
                end
                self.node_awardInfo:setVisible(false)
                self.node_awardInfos:removeAllChildrenWithCleanup(true)
            end
        end,
        pageChangedCallFunc = function(totalPage, curPage)
        end
    }

    local tempTable = TableViewHelper:create(params)
    tempTable:setScrollBarVisible(false)

    node_lLIst:addChild(tempTable)
end

function game_empowerContest_index:refreshRight()
    local isQcbl = self.m_selectId == 1 -- 千锤百炼
    local isFndf = self.m_selectId == 2 -- 赋能巅峰
    local isFncj = self.m_selectId == 3 -- 赋能抽奖

    local node_qcbl = self.node_qcbl
    local node_fndf = self.node_fndf
    local node_fncj = self.node_fncj
    node_qcbl:setVisible(isQcbl)
    node_fndf:setVisible(isFndf)
    node_fncj:setVisible(isFncj)

    if isQcbl then -- 千锤百炼
        local node_qcblContent = self.m_ccbNode:nodeForName("node_qcblContent")
        node_qcblContent:removeAllChildrenWithCleanup(true)

        local showData = {}
        for k, v in pairs(self.funeng_competiton_task) do
            if v.version == self.m_taskIndexData.version then
                v.task_id = tonumber(k)
                table.insert(showData, v)
            end
        end
        table.sort(
            showData,
            function(a, b)
                local taskData1 = self.m_taskIndexData.tasks[tostring(a.task_id)] or {}
                local taskData2 = self.m_taskIndexData.tasks[tostring(b.task_id)] or {}
                local s1 = taskData1.status or 0
                local s2 = taskData2.status or 0
                if s1 == 1 then
                    s1 = 30
                end
                if s1 == 0 then
                    s1 = 20
                end
                if s2 == 1 then
                    s2 = 30
                end
                if s2 == 0 then
                    s2 = 20
                end
                if s1 == s2 then
                    return a.task_id < b.task_id
                else
                    return s1 > s2
                end
            end
        )

        local data = self.funeng_competiton_task or {}
        local params = {
            viewSize = node_qcblContent:getContentSize(),
            row = 4, -- 行
            column = 1, -- 列
            totalItem = #showData,
            touchPriority = GLOBAL_TOUCH_PRIORITY - 4,
            showPoint = false,
            itemActionFlag = false,
            direction = kCCScrollViewDirectionVertical, --纵向
            newCell = function(tableView, index)
                local cell = tableView:dequeueCell()
                if cell == nil then
                    cell = CCTableViewCell:new()
                    cell:autorelease()
                end
                local data = showData[index + 1]
                -- cclog2(data, "[赋能大赛] 千锤百炼 列表item数据")
                cell:removeAllChildrenWithCleanup(true)

                local ccbNode = luaCCBNode:create()
                ccbNode:openCCBFile("ccb/ui_empowerContest_qcblItem.ccbi")
                cell:addChild(ccbNode)

                local taskData = self.m_taskIndexData.tasks[tostring(data.task_id)] or {}

                -- lb_name
                local lb_taskName = ccbNode:labelTTFForName("lb_taskName")
                lb_taskName:setString(string.format(data.task_des, data.task_num1))
                -- node_rewards
                local node_rewards = ccbNode:nodeForName("node_rewards")
                node_rewards:removeAllChildrenWithCleanup(true)
                local tableView = self:createTableView(node_rewards, data.task_reward, 1)
                if tableView then
                    self.m_node_rewards:addChild(tableView)
                end
                -- btn_get
                local btn_get = ccbNode:controlButtonForName("btn_get")
                btn_get:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5)
                btn_get:addHandleOfControlEvent(
                    function()
                        -- 领奖
                        self:getTaskRewardNet(data.task_id)
                    end,
                    CCControlEventTouchUpInside
                )
                btn_get:setVisible(taskData.status == 1)
                -- game_util:setCCControlButtonBackground(self.m_lock_btn, taskData.status == 1 and "fnds_ui_12.png" or "fnds_ui_12_2.png")
                -- 红点
                if taskData.status == 1 then
                    local tips_reward = CCSprite:createWithSpriteFrameName("public_new2.png")
                    if tips_reward then
                        local tempSize = btn_get:getContentSize()
                        tips_reward:setPosition(ccp(tempSize.width - tips_reward:getContentSize().width / 2, tempSize.height - tips_reward:getContentSize().height / 2))
                        btn_get:addChild(tips_reward)
                    end
                end
                -- lb_status
                local lb_status = ccbNode:labelTTFForName("lb_status")
                lb_status:setVisible(taskData.status ~= 1)
                lb_status:setString(taskData.status == 2 and "Đã nhận" or string.format("Tiến độ %s/ %s", taskData.num or 0, data.task_num1))
                return cell
            end,
            itemOnClick = function(eventType, index, item)
                if eventType == "ended" and item then
                end
            end,
            pageChangedCallFunc = function(totalPage, curPage)
            end
        }

        local tempTable = TableViewHelper:create(params)
        tempTable:setScrollBarVisible(false)
        node_qcblContent:addChild(tempTable)
    end

    if isFndf then -- 赋能巅峰
        local node_fndfPlayerList = self.m_ccbNode:nodeForName("node_fndfPlayerList")
        node_fndfPlayerList:removeAllChildrenWithCleanup(true)
        local showData = self.m_rankIndexData.rank_info or {}
        local params = {
            viewSize = node_fndfPlayerList:getContentSize(),
            row = 11, -- 行
            column = 1, -- 列
            totalItem = #showData,
            touchPriority = GLOBAL_TOUCH_PRIORITY - 4,
            showPoint = false,
            itemActionFlag = false,
            direction = kCCScrollViewDirectionVertical, --纵向
            newCell = function(tableView, index)
                local cell = tableView:dequeueCell()
                if cell == nil then
                    cell = CCTableViewCell:new()
                    cell:autorelease()
                end
                local data = showData[index + 1]
                cell:removeAllChildrenWithCleanup(true)

                local ccbNode = luaCCBNode:create()
                ccbNode:openCCBFile("ccb/ui_empowerContest_playerItem.ccbi")
                cell:addChild(ccbNode)

                local taskData = self.m_taskIndexData.tasks[tostring(data.task_id)] or {}

                -- lb_name
                local lb_name = ccbNode:labelTTFForName("lb_name")
                lb_name:setString(data.rank .. "." .. data.name)
                -- lb_score
                ccbNode:labelTTFForName("lb_score"):setString(data.score)
                return cell
            end,
            itemOnClick = function(eventType, index, item)
                if eventType == "ended" and item then
                elseif eventType == "refresh" and item then
                    local max = self.m_rankIndexData.rank_count
                    if self.selectRankIndex * 10 < max then
                        self:getRankListNet(self.selectRankIndex * 10 + 1, (self.selectRankIndex + 1) * 10)
                    end
                -- self:getRankListNet()
                --翻页  4 和 8 无 其他的都有
                -- if self.select_index == 4 or self.select_index == 8 then
                -- if self.select_index == 8 then--改为联盟数据也能翻页了
                -- elseif self.select_index == 4 then
                --     self.cur_page = self.cur_page + 1
                --     self:requestForHttp2()
                -- else
                --     if self.cur_page < 4 then
                --         self.cur_page = self.cur_page + 1
                --         self:requestForHttp()
                --     end
                -- end
                end
            end,
            pageChangedCallFunc = function(totalPage, curPage)
            end
        }

        local tempTable = TableViewHelper:create(params)
        tempTable:setScrollBarVisible(false)
        node_fndfPlayerList:addChild(tempTable, 0, 100)
        local index = (self.selectRankIndex - 1) * 10
        game_util:setTableViewIndex(index, node_fndfPlayerList, 100, 11)
        -- 我的排名
        local lb_fndfMyRank = self.m_ccbNode:labelTTFForName("lb_fndfMyRank")
        lb_fndfMyRank:setString(string.format("XH của tôi: %s", self.m_rankIndexData.self_rank))
        self.m_ccbNode:labelTTFForName("lb_fndfMyScore"):setString(self.m_rankIndexData.self_score)
        -- node_fndfRankAward
        local node_fndfRankAward = self.m_ccbNode:nodeForName("node_fndfRankAward")
        node_fndfRankAward:removeAllChildrenWithCleanup(true)
        local showData = {}
        for k, v in pairs(self.funeng_competiton_rank) do
            if v.version == self.m_rankIndexData.version then
                v.id = tonumber(k)
                table.insert(showData, v)
            end
        end
        table.sort(
            showData,
            function(a, b)
                return a.id < b.id
            end
        )
        local params = {
            viewSize = node_fndfRankAward:getContentSize(),
            row = 3, -- 行
            column = 1, -- 列
            totalItem = #showData,
            touchPriority = GLOBAL_TOUCH_PRIORITY - 4,
            showPoint = false,
            itemActionFlag = false,
            direction = kCCScrollViewDirectionVertical, --纵向
            newCell = function(tableView, index)
                local cell = tableView:dequeueCell()
                if cell == nil then
                    cell = CCTableViewCell:new()
                    cell:autorelease()
                end
                local data = showData[index + 1]
                cell:removeAllChildrenWithCleanup(true)

                local ccbNode = luaCCBNode:create()
                ccbNode:openCCBFile("ccb/ui_empowerContest_rankAwardItem.ccbi")
                cell:addChild(ccbNode)

                local data = showData[index + 1]
                -- lb_rank
                local lb_rank = ccbNode:labelTTFForName("lb_rank")
                local str = ""
                if data.rank_id[1] == data.rank_id[2] then
                    str = string.format("Thứ %s", data.rank_id[1])
                else
                    str = string.format("Thứ %s-%s", data.rank_id[1], data.rank_id[2])
                end
                lb_rank:setString(str)
                -- node_rewards
                local node_rewards = ccbNode:nodeForName("node_rewards")
                node_rewards:removeAllChildrenWithCleanup(true)
                local tableView = self:createTableView(node_rewards, data.rank_reward, 2, 1, 3)
                if tableView then
                    self.m_node_rewards:addChild(tableView)
                end
                return cell
            end,
            itemOnClick = function(eventType, index, item)
                if eventType == "ended" and item then
                end
            end,
            pageChangedCallFunc = function(totalPage, curPage)
            end
        }

        local tempTable = TableViewHelper:create(params)
        tempTable:setScrollBarVisible(false)
        node_fndfRankAward:addChild(tempTable)
    end

    if isFncj then -- 赋能抽奖
        local lb_gacha1 = self.m_ccbNode:labelBMFontForName("lb_gacha1")
        local lb_gacha10Tips = self.m_ccbNode:labelTTFForName("lb_gacha10Tips")
        local lb_tenTimes = self.m_ccbNode:labelTTFForName("lb_tenTimes")
        local cfg
        for k, v in pairs(self.funeng_competiton_gacha) do
            if tonumber(k) == self.m_gachaIndexData.version then
                cfg = v
                break
            end
        end

        local need_2 = cfg.need_2 or 0

        lb_gacha1:setString("x" .. cfg.need_1[1][3])
        lb_gacha10Tips:setString(string.format("Trong thời gian HĐ, tích lũy nạp %s VND nhận được 1 cơ hội rút 10 lần liên tiếp", need_2))
        lb_tenTimes:setString(self.m_gachaIndexData.charge_times)

        -- -- 单抽红点
        -- local btn_gacha1 = self.m_ccbNode:controlButtonForName("btn_gacha1")
        -- local hasRed = self:getOneGachaRedDot()
        -- if btn_gacha1:getChildByTag(1001) then
        --     btn_gacha1:removeChildByTag(1001, true)
        -- end
        -- if hasRed then
        --     local tips_reward = CCSprite:createWithSpriteFrameName("public_new2.png")
        --     if tips_reward then
        --         local tempSize = btn_gacha1:getContentSize()
        --         tips_reward:setPosition(ccp(tempSize.width - tips_reward:getContentSize().width / 2, tempSize.height - tips_reward:getContentSize().height / 2))
        --         btn_gacha1:addChild(tips_reward, 1000, 1001)
        --     end
        -- end
    end
end

function game_empowerContest_index:refreshAwardInfo()
    local cfg
    for k, v in pairs(self.funeng_competiton_gacha) do
        if tonumber(k) == self.m_gachaIndexData.version then
            cfg = v
            break
        end
    end
    -- 所有奖励
    local gacha_reward = cfg.gacha_reward or {}
    local node_awardInfos = self.node_awardInfos
    node_awardInfos:removeAllChildrenWithCleanup(true)
    local tableView = self:createTableView(node_awardInfos, gacha_reward, 3, 3, 5, kCCScrollViewDirectionVertical)
    if tableView then
        node_awardInfos:addChild(tableView)
    end
end

--[[--
    初始化
]]
function game_empowerContest_index.init(self, t_params)
    cclog("[赋能大赛] init")
end
--[[--
    创建ui入口并初始化数据
]]
function game_empowerContest_index.create(self, t_params)
    cclog("[赋能大赛] create")
    local gameData = t_params.gameData or {}
    self:updateTaskIndexData(gameData)

    self:init(t_params)
    local scene = CCScene:create()
    scene:addChild(self:createUi())
    self:refreshUi()
    return scene
end

--[[--
    回调方法
]]
function game_empowerContest_index.callBackFunc(self)
    cclog("[赋能大赛] callBackFunc")
    local callBackFunc = self.callBackFunc
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc()
    end
end

-----------------------------api
function game_empowerContest_index:updateTaskIndexData(data)
    data = json.decode(data:getNodeWithKey("data"):getFormatBuffer())
    self.m_taskIndexData.tasks = data.tasks or {}
    self.m_taskIndexData.version = data.version or 1
end

function game_empowerContest_index:updateRankIndexData(data, isAdd)
    data = json.decode(data:getNodeWithKey("data"):getFormatBuffer())
    self.m_rankIndexData.version = data.version -- 版本号

    -- local _temp = {}
    -- for k = 1, 10 do
    --     table.insert(_temp, {
    --         score =  k + (self.selectRankIndex - 1) * 10,
    --         rank = k + (self.selectRankIndex - 1) * 10,
    --         name =  k + (self.selectRankIndex - 1) * 10,
    --     })
    -- end
    -- data.rank_info =_temp
    if isAdd then
        for k, v in pairs(data.rank_info) do
            table.insert(self.m_rankIndexData.rank_info, v)
        end
    else
        self.m_rankIndexData.rank_info = data.rank_info or {} -- 排行榜信息(首页默认10人)
    end
    if data.self_rank then
        self.m_rankIndexData.self_rank = data.self_rank or {} -- 自己的排行信息
    end
    if data.self_score then
        self.m_rankIndexData.self_score = data.self_score or 0 -- 自己的分数
    end
    self.m_rankIndexData.rank_count = data.rank_count or 0 -- 排行榜总人数
end

function game_empowerContest_index:updateGachaIndexData(data)
    data = json.decode(data:getNodeWithKey("data"):getFormatBuffer())
    self.m_gachaIndexData.version = data.version -- 版本号
    self.m_gachaIndexData.charge_times = data.charge_times or 0 -- 充值抽奖次数
    self.m_gachaIndexData.charge_mod = data.charge_mod or 0 -- 加完充值抽奖次数后, 剩余充值金额
end

--[[
        获取任务首页数据
    ]]
function game_empowerContest_index:getTaskIndexNet()
    local function responseMethod(tag, gameData)
        self:updateTaskIndexData(gameData)
        self.m_selectId = 1
        self:refreshUi()
    end
    network.sendHttpRequest(responseMethod, game_url.getUrlForKey("funeng_task_index"), http_request_method.GET, {}, "funeng_task_index")
end

--[[
    领取任务奖励
]]
function game_empowerContest_index:getTaskRewardNet(task_id)
    local function responseMethod(tag, gameData)
        self:updateTaskIndexData(gameData)
        gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
        local reward = gameData.reward or {} -- 任务奖励
        game_util:rewardTipsByDataTable(reward)
        self:refreshUi()
    end
    network.sendHttpRequest(responseMethod, game_url.getUrlForKey("funeng_task_gift"), http_request_method.GET, {task_id = task_id}, "funeng_task_gift")
end

--[[
    排行榜首页
]]
function game_empowerContest_index:getRankIndexNet()
    local function responseMethod(tag, gameData)
        self:updateRankIndexData(gameData)
        self.m_selectId = 2
        self:refreshUi()
    end
    network.sendHttpRequest(responseMethod, game_url.getUrlForKey("funeng_rank_index"), http_request_method.GET, {}, "funeng_rank_index")
end

--[[
    获取更多排行数据
    ]]
function game_empowerContest_index:getRankListNet(s_rank, e_rank)
    local function responseMethod(tag, gameData)
        self.selectRankIndex = self.selectRankIndex + 1
        self:updateRankIndexData(gameData, true)
        self:refreshUi()
    end
    network.sendHttpRequest(responseMethod, game_url.getUrlForKey("funeng_rank_list"), http_request_method.GET, {s_rank = s_rank, e_rank = e_rank}, "funeng_rank_list")
end

--[[
    抽奖首页
]]
function game_empowerContest_index:getGachaIndexNet()
    local function responseMethod(tag, gameData)
        self:updateGachaIndexData(gameData)
        self.m_selectId = 3
        self:refreshUi()
    end
    network.sendHttpRequest(responseMethod, game_url.getUrlForKey("funeng_gacha_index"), http_request_method.GET, {}, "funeng_gacha_index")
end

--[[
    抽奖
    sort: # 抽奖类型 1: 单抽 2: 10连
]]
function game_empowerContest_index:getGachaGetNet(sort)
    local coin = game_data:getUserStatusDataByKey("coin") or 0
    local cfg
    for k, v in pairs(self.funeng_competiton_gacha) do
        if tonumber(k) == self.m_gachaIndexData.version then
            cfg = v
            break
        end
    end

    local canBuy = true
    if sort == 1 then
        canBuy = self:getOneGachaRedDot()
    end
    if sort == 2 then
        canBuy = self:getTenGachaRedDot()
    end
    if not canBuy then
        if sort == 1 then
            game_util:addMoveTips({text = "道具不足"})
            return
        end
        local function responseMethod(tag, gameData)
            game_scene:enterGameUi("ui_vip", {gameData = gameData})
            self:destroy()
        end
        network.sendHttpRequest(responseMethod, game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil, "vip_buy_step")
        return
    end
    local function responseMethod(tag, gameData)
        self:updateGachaIndexData(gameData)
        gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
        local gifts = gameData.gifts or {} -- 抽奖奖励
        local reward = gameData.reward or {} -- 抽奖奖励
        game_util:rewardTipsByDataTable(reward)
        self:refreshUi()
    end
    network.sendHttpRequest(responseMethod, game_url.getUrlForKey("funeng_get_gacha"), http_request_method.GET, {sort = sort}, "funeng_get_gacha")
end
--[[
    创建横奖励列表
]]
function game_empowerContest_index.createTableView(self, viewBoard, rewardList, toId, row, column, direction)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_server_pyramid_n_res.plist")

    if not rewardList then
        return
    end
    local showData = rewardList
    local viewSize = viewBoard:getContentSize()
    -- cclog2(rewardList, "rewardList ==== ")
    function onBtnClick(event, target)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        print("press button tag is ", btnTag)
        local itemData = rewardList[btnTag + 1]
        if itemData then
            game_util:lookItemDetal(json.decode(itemData:getFormatBuffer()))
        end
    end
    local tempCount = #showData
    local params = {}
    params.viewSize = viewSize
    params.row = row or 1
    params.column = column or 4 --列
    params.totalItem = tempCount
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 4
    params.direction = direction or kCCScrollViewDirectionHorizontal --横向
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
            local itemData = showData[index + 1]
            local icon, name, count = game_util:getRewardByItemTable(itemData)
            if icon then
                icon:setScale(0.7)
                icon:setAnchorPoint(ccp(0.5, 0.5))
                icon:setPosition(ccp(0, 2))
                node:addChild(icon, 10)

                if icon and count then
                    local label_count = game_util:createLabelTTF({text = "×" .. tostring(count), color = ccc3(255, 255, 255), fontSize = 12})
                    label_count:setAnchorPoint(ccp(0.5, 0.5))
                    label_count:setPosition(ccp(0, -10))
                    node:addChild(label_count, 20)
                end

                local node = icon:getChildByTag(1)
                if node then
                    node:setVisible(false)
                end
                local iconSize = icon:getContentSize()
                local sprBoard = CCSprite:createWithSpriteFrameName("ui_pyramid_n_kuang3.png")
                if sprBoard then
                    sprBoard:setPosition(iconSize.width * 0.5, iconSize.height * 0.5)
                    icon:addChild(sprBoard, 20, 20)
                end
            end
            cell:addChild(node)
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, item)
        local canShow = true
        if toId == 3 then
            canShow = self.node_awardInfo:isVisible()
        else
            canShow = self.m_selectId == toId
        end
        if eventType == "ended" and item and viewBoard:isVisible() and canShow then
            local itemData = showData[index + 1]
            if itemData then
                game_util:lookItemDetal(itemData, nil, {useFullName = true})
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage, curPage)
    end
    local tableView = TableViewHelper:create(params)
    if tableView then
        viewBoard:addChild(tableView)
    end
end

--[[
    获取任务红点
]]
function game_empowerContest_index.getTaskRedDot(self)
    local hasTaskRed = false -- 任务红点
    for k, v in pairs(self.m_taskIndexData.tasks or {}) do
        if v.status == 1 then
            hasTaskRed = true
            break
        end
    end
    return hasTaskRed
end

-- 获取单抽红点
function game_empowerContest_index.getOneGachaRedDot(self)
    local cfg
    for k, v in pairs(self.funeng_competiton_gacha) do
        if tonumber(k) == self.m_gachaIndexData.version then
            cfg = v
            break
        end
    end
    local count = game_data:getItemCountByCid(tostring(9101016)) or 0
    return count >= cfg.need_1[1][3]
end
-- 获取十抽红点
function game_empowerContest_index.getTenGachaRedDot(self)
    return self.m_gachaIndexData.charge_times > 0
end

--[[
    获取抽卡红点
]]
function game_empowerContest_index.getGachaRedDot(self)
    local hasGachaRed = false -- 抽卡红点
    if self.m_gachaIndexData.version then
        -- if self:getOneGachaRedDot() then
        --     hasGachaRed = true
        -- end
        if self:getTenGachaRedDot() then
            hasGachaRed = true
        end
    else
        local funeng_red_dot = game_data:getAlertsDataByKey("funeng_red_dot") or {}
        hasGachaRed = funeng_red_dot.gacha == true
    end
    return hasGachaRed
end

return game_empowerContest_index
