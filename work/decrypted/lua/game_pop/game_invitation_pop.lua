--- 活动详细
local SelectMenu = {
    menu1 = 1, -- 专属邀请码
    menu2 = 2 -- 启航礼包
}

local game_invitation_pop = {
    _selectMenu = SelectMenu.menu1, -- 左侧选择按钮
    inviter_open = getConfig(game_config_field.inviter_open) and json.decode(getConfig(game_config_field.inviter_open):getFormatBuffer())["1"] or {},
    reward_list = getConfig(game_config_field.reward_list) and json.decode(getConfig(game_config_field.reward_list):getFormatBuffer()) or {},
    inviter_text = getConfig(game_config_field.inviter_text) and json.decode(getConfig(game_config_field.inviter_text):getFormatBuffer()) or {},
    m_tParams = nil
}

function game_invitation_pop.destroy(self)
    cclog("[邀请码] destroy")
    self.m_rootNode = nil
    self.m_tParams = nil
    self.cfg = nil
end

function game_invitation_pop.back(self, type)
    cclog("[邀请码] back")
    game_scene:removePopByName("game_invitation_pop")
    self:destroy()
end

--[[
    检查当前状态
]]
function game_invitation_pop.checkStatus(self)
    local server_time = game_data:getUserStatusDataByKey("server_time")
    -- 超过一周
    local remainTime = self.regist_time + self.inviter_open.lifetime * 60 * 60 - server_time
    if remainTime <= 0 then
        return false, "Nhân vật không đạt điều kiện HĐ Mời"
    end
    -- 等级达到100级
    local playerLevel = game_data:getUserStatusDataByKey("level") or 1
    if playerLevel >= self.inviter_open.level then
        return false, "Nhân vật không đạt điều kiện HĐ Mời"
    end
    -- 被邀请了
    local acc_invitecode = self.acc_invitecode
    if acc_invitecode and acc_invitecode ~= "" then
        return false, "Đã có nhân vật khác trong tài khoản của bạn nhập Mã Mời"
    end
    return true
end

function game_invitation_pop.createUi(self)
    local ccbNode = luaCCBNode:create()
    local function onMainBtnClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if self.m_flag == true then
            return
        end

        cclog("[邀请码] 点击按钮 --> " .. btnTag)

        if btnTag == 999 then
            self:back()
        elseif btnTag == 1 then
            self._selectMenu = SelectMenu.menu1
            self:refreshUi()
        elseif btnTag == 2 then
            self._selectMenu = SelectMenu.menu2
            self:refreshUi()
        elseif btnTag == 3 then
            if self.tx_invite and self.tx_invite ~= "" then
                local status, tips = self:checkStatus()
                if status then
                    local function responseMethod(tag, gameData)
                        if self.editBox then
                            self.editBox:setText("")
                        end
                        game_util:addMoveTips({text = "Gói quà Khởi Hành đến ngay đây, xin hãy kiểm tra Hòm Thư"})
                    end
                    local params = {}
                    params.invitecode = self.tx_invite
                    network.sendHttpRequest(responseMethod, game_url.getUrlForKey("invite_code_add_invite_code"), http_request_method.GET, params, "invite_code_add_invite_code")
                else
                    game_util:addMoveTips({text = tips})
                end
            else
                game_util:addMoveTips({text = "Hãy nhập Mã Mời"})
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_invitation_pop.ccbi")

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

    local invitecode = self.m_data.invitecode -- 我的邀请码

    self.regist_time = self.m_data.regist_time -- 我的注册时间
    self.acc_invitecode = self.m_data.acc_invitecode -- 被谁邀请
    self.node_zsyqm = ccbNode:nodeForName("node_zsyqm")
    self.node_qhlb = ccbNode:nodeForName("node_qhlb")
    self.sp_i1 = ccbNode:nodeForName("sp_i1")
    self.sp_i2 = ccbNode:nodeForName("sp_i2")

    ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    ccbNode:controlButtonForName("btn_invitation1"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    ccbNode:controlButtonForName("btn_invitation2"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)

    -------------------------- 启航礼包 --------------------------
    -- node_reward
    local inviter_open = self.inviter_open
    cclog2(inviter_open, "[邀请码] inviter_open1")
    local reward1 = inviter_open.reward1
    cclog2(reward1, "[邀请码] reward1")
    local node_reward = self.m_ccbNode:nodeForName("node_reward")
    node_reward:removeAllChildrenWithCleanup(true)
    local tempTable = self:createRewardTable(node_reward:getContentSize(), reward1)
    node_reward:addChild(tempTable)
    -- 输入框-填写邀请码
    local node_editbox = self.m_ccbNode:nodeForName("node_editbox")
    node_editbox:removeAllChildrenWithCleanup(true)
    local function editBoxTextEventHandle(strEventName, pSender)
        local edit = tolua.cast(pSender, "CCEditBox")
        local strFmt
        if strEventName == "changed" then
            self.tx_invite = edit:getText()
        end
    end
    local editBox = game_util:createEditBox({bgFileName = nil, scriptEditBoxHandler = editBoxTextEventHandle, size = node_editbox:getContentSize(), placeHolder = ""})
    editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    self.editBox = editBox
    node_editbox:addChild(editBox)
    -- 倒计时
    local lb_endTime = self.m_ccbNode:labelTTFForName("lb_endTime")
    lb_endTime:removeAllChildrenWithCleanup(true)
    local server_time = game_data:getUserStatusDataByKey("server_time")
    local remainTime = self.regist_time + inviter_open.lifetime * 60 * 60 - server_time
    cclog(string.format("[邀请码] remainTime = %d, serverTime = %d, regist_time = %d, inviter_open.lifetime = %d", remainTime, server_time, self.regist_time, inviter_open.lifetime))
    local status = self:checkStatus()
    if remainTime > 0 and status then
        lb_endTime:setString("")
        local function timeOverCallFun()
            cclog("[邀请码] 已结束]")
            lb_endTime:removeAllChildrenWithCleanup(true)
            lb_endTime:setString("Đã kết thúc")
        end
        local pX, pY = lb_endTime:getPosition()
        local timeLabel = game_util:createCountdownLabel(remainTime, timeOverCallFun, 8, 1)
        timeLabel:setColor(ccc3(106, 244, 58))
        timeLabel:setPosition(ccp(pX + 5, pY))
        lb_endTime:getParent():addChild(timeLabel, 10, 10)
    else
        lb_endTime:setString("Đã kết thúc")
    end
    -- 启航礼包 规则说明
    local sc_qhlb = ccbNode:scrollViewForName("sc_qhlb")
    self.sc_qhlb = sc_qhlb
    sc_qhlb:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 50)
    local _temp = {}
    for k, v in pairs(self.inviter_text) do
        if v.sort == 2 then
            _temp[tonumber(k) - 3] = v.des
        end
    end
    cclog2(_temp, "[邀请码] 启航礼包 _temp")
    local contentText = table.concat(_temp, "\n")
    cclog("[邀请码] 启航礼包 contentText" .. contentText)
    local tempLabel =
        game_util:createRichLabelTTF(
        {
            text = contentText,
            dimensions = CCSizeMake(250, 0),
            textAlignment = kCCTextAlignmentLeft,
            verticalTextAlignment = kCCVerticalTextAlignmentCenter,
            color = ccc3(246, 247, 176),
            fontSize = 11
        }
    )
    local tempSize = tempLabel:getContentSize()
    sc_qhlb:setContentSize(CCSizeMake(210, tempSize.height))
    sc_qhlb:setContentOffset(ccp(0, 50 - tempSize.height), false)
    sc_qhlb:addChild(tempLabel)
    -- btn_sure
    local btn_sure = ccbNode:controlButtonForName("btn_sure")
    btn_sure:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)

    -------------------------- 专属邀请码 --------------------------
    -- 我的专属邀请码
    local lb_inviteCode = ccbNode:labelTTFForName("lb_inviteCode")
    lb_inviteCode:setString(invitecode)
    -- 专属邀请码奖励列表
    local node_list1 = ccbNode:nodeForName("node_list1")
    node_list1:removeAllChildrenWithCleanup(true)
    local params = {}
    local _reawrdList = {}
    for k, v in pairs(self.reward_list) do
        v.id = tonumber(k)
        table.insert(_reawrdList, v)
    end
    table.sort(
        _reawrdList,
        function(a, b)
            return a.id < b.id
        end
    )
    cclog2(_reawrdList, "[邀请码] reward_list")
    local viewSize = node_list1:getContentSize()
    params.viewSize = viewSize
    params.row = 2
    --行
    params.column = 1 --列
    params.direction = kCCScrollViewDirectionVertical
    params.totalItem = #_reawrdList
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 4
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height / params.row)
    params.newCell = function(tableView, index)
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()
            -- ccbNode:registerFunctionWithFuncName("onCellBtnClick", onCellBtnClick)
            ccbNode:openCCBFile("ccb/ui_invitation_pop_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5))
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10), "luaCCBNode")
            -- lb_res1
            local lb_res1 = ccbNode:labelTTFForName("lb_res1")
            lb_res1:setString(_reawrdList[index + 1].des)
            -- node_award
            local node_award = ccbNode:nodeForName("node_award")
            node_award:removeAllChildrenWithCleanup(true)
            local reward = _reawrdList[index + 1].reward
            local posX = 0
            for i = #reward, 1, -1 do
                local rewardItem = reward[i]
                local reward_icon, name, count = game_util:getRewardByItemTable(rewardItem, true)
                if reward_icon then
                    reward_icon:setAnchorPoint(ccp(0.5, 0.5))
                    reward_icon:setScale(0.7)
                    node_award:addChild(reward_icon)
                    reward_icon:setPositionX(posX)

                    posX = posX - reward_icon:getContentSize().width * reward_icon:getScaleX() - 8

                    if count then
                        local tempLabel = game_util:createLabelTTF({text = "x" .. count, color = ccc3(255, 255, 255), fontSize = 9})
                        tempLabel:setPosition(ccp(reward_icon:getContentSize().width / 2 + 15, reward_icon:getContentSize().height * 0.1))
                        reward_icon:addChild(tempLabel, 10)
                    end

                    local function onClick(event, target)
                        local tagNode = tolua.cast(target, "CCNode")
                        local btnTag = tagNode:getTag()
                        game_util:lookItemDetal(rewardItem)
                    end
                    local button = game_util:createCCControlButton("public_weapon.png", "", onClick)
                    reward_icon:addChild(button)
                    button:setAnchorPoint(ccp(0.5, 0.5))
                    button:setScale(0.6)
                    button:setPosition(ccp(reward_icon:getContentSize().width * 0.5, reward_icon:getContentSize().height * 0.5))
                    button:setOpacity(0)
                end
            end
        end
        return cell
    end
    local tb = TableViewHelper:create(params)
    node_list1:addChild(tb, 10, 10)

    -- 专属邀请码 规则说明
    local sc_zsyqm = ccbNode:scrollViewForName("sc_zsyqm")
    self.sc_zsyqm = sc_zsyqm
    sc_zsyqm:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 50)
    local _temp = {}
    for k, v in pairs(self.inviter_text) do
        if v.sort == 1 then
            _temp[tonumber(k)] = v.des
        end
    end
    local contentText = table.concat(_temp, "\n")
    cclog("[邀请码] 专属邀请码 contentText" .. contentText)
    local tempLabel =
        game_util:createRichLabelTTF(
        {
            text = contentText,
            dimensions = CCSizeMake(250, 0),
            textAlignment = kCCTextAlignmentLeft,
            verticalTextAlignment = kCCVerticalTextAlignmentCenter,
            color = ccc3(246, 247, 176),
            fontSize = 11
        }
    )
    local tempSize = tempLabel:getContentSize()
    sc_zsyqm:setContentSize(CCSizeMake(210, tempSize.height))
    sc_zsyqm:setContentOffset(ccp(0, 50 - tempSize.height), false)
    sc_zsyqm:addChild(tempLabel)

    return ccbNode
end
--

function game_invitation_pop.refreshUi(self)
    cclog("[邀请码] refreshUi")
    if self._selectMenu == SelectMenu.menu1 then
        self.node_zsyqm:setVisible(true)
        self.sp_i1:setVisible(true)
        self.node_qhlb:setVisible(false)
        self.sp_i2:setVisible(false)

        self.sc_zsyqm:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 50)
        self.sc_qhlb:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 49)
    end

    if self._selectMenu == SelectMenu.menu2 then
        self.node_zsyqm:setVisible(false)
        self.sp_i1:setVisible(false)
        self.node_qhlb:setVisible(true)
        self.sp_i2:setVisible(true)

        self.sc_zsyqm:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 49)
        self.sc_qhlb:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 50)
    end
end

--[[--
    初始化
]]
function game_invitation_pop.init(self, t_params)
    cclog("[邀请码] init")
end
--[[--
    创建ui入口并初始化数据
]]
function game_invitation_pop.create(self, t_params)
    cclog("[邀请码] create")
    local params = t_params.gameData or {}
    self.m_data = json.decode(params:getNodeWithKey("data"):getFormatBuffer())

    self:init(t_params)
    self.m_tParams = t_params
    self.m_popUi = self:createUi()
    self:refreshUi()
    return self.m_popUi
end

--[[--
    回调方法
]]
function game_invitation_pop.callBackFunc(self)
    cclog("[邀请码] callBackFunc")

    local callBackFunc = self.callBackFunc
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc()
    end
end

function game_invitation_pop.createRewardTable(self, viewSize, rewardList)
    local params = {}
    params.viewSize = viewSize
    params.row = 1
    params.column = 5 --列
    params.totalItem = #rewardList
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 4
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
        if eventType == "ended" and item and self._selectMenu == SelectMenu.menu2 then
            local itemCfg = rewardList[index + 1]
            game_util:lookItemDetal(itemCfg)
        end
    end
    params.pageChangedCallFunc = function(totalPage, curPage)
    end
    return TableViewHelper:create(params)
end

return game_invitation_pop
