--[[
    远航奖励
]]
local game_god_escort_voyageReward = {}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_voyageReward.destroy(self)
    cclog("[神域押镖] game_god_escort_voyageReward.destroy(self)")
end

function game_god_escort_voyageReward.createUi(self)
    cclog("[神域押镖] game_god_escort_voyageReward.createUi(self)")
    local ccbNode = luaCCBNode:create()
    local function onMainClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then
            if self.cb then
                self.cb()
            end
            game_scene:removePopByName("game_god_escort_voyageReward")
        elseif btnTag == 2 then -- 远航奖励
            local function responseMethod(tag, gameData)
                local data = gameData:getNodeWithKey("data")
                local gameData = json.decode(data:getFormatBuffer()) or {}
                self:setBtnState(btnTag)
                self.netData = gameData
                self:refreshUi()
            end
            local key = "highway_reward_index"
            local params = {
                round_id = self.round_id,
                area_id = self.area_id
            }
            helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
        elseif btnTag == 3 then -- 远航排名
            local function responseMethod(tag, gameData)
                local data = gameData:getNodeWithKey("data")
                local gameData = json.decode(data:getFormatBuffer()) or {}
                self:setBtnState(btnTag)
                self.netData = gameData
                self:refreshUi()
            end
            local key = "highway_rank_index"
            local round_id = self.round_id
            local point 
            if round_id == 0 then
                game_util:addMoveTips({text = helper.txt.god_escort_txt_112})
                return
            else
                point = helper.cfg.highway_time[round_id].point
            end
            if point == 0 then
                round_id = round_id - 1
            end
            local params = {area_id = self.area_id, round_id = round_id}
            helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
        elseif btnTag == 4 then -- 量子仓奖励
            local function responseMethod(tag, gameData)
                local data = gameData:getNodeWithKey("data")
                local gameData = json.decode(data:getFormatBuffer()) or {}
                self:setBtnState(btnTag)
                self.netData = gameData
                self:refreshUi()
            end
            local key = "highway_income_index"
            local params = {}
            helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
        elseif btnTag == 5 then -- 光年里程碑
            local function responseMethod(tag, gameData)
                local data = gameData:getNodeWithKey("data")
                local gameData = json.decode(data:getFormatBuffer()) or {}
                self:setBtnState(btnTag)
                self.netData = gameData
                self:refreshUi()
            end
            local key = "highway_milestone_index"
            local params = {}
            helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainClick)
    ccbNode:openCCBFile("ccb/ui_god_escort_voyageReward.ccbi")
    self.ccbNode = ccbNode

    -- 弹窗底部触摸拦截
    self.ly_main = ccbNode:layerForName("ly_main")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true --intercept event
        end
    end
    self.ly_main:registerScriptTouchHandler(onTouch, false, helper.yhjlTouchPriorityBase, true)
    self.ly_main:setTouchEnabled(true)
    -- 优先级
    ccbNode:controlButtonForName("btn_close"):setTouchPriority(helper.yhjlTouchPriority)
    --
    self.btn_yhjc = ccbNode:controlButtonForName("btn_yhjc") -- 远航奖励
    self.btn_yhjc:setHighlighted(true)
    self.btn_yhjc:setTouchPriority(helper.yhjlTouchPriority)
    game_util:setCCControlButtonTitle(self.btn_yhjc, helper.txt.god_escort_txt_9)
    self.btn_yhpm = ccbNode:controlButtonForName("btn_yhpm") -- 远航排名
    self.btn_yhpm:setHighlighted(false)
    self.btn_yhpm:setTouchPriority(helper.yhjlTouchPriority)
    game_util:setCCControlButtonTitle(self.btn_yhpm, helper.txt.god_escort_txt_10)
    self.btn_lzcjl = ccbNode:controlButtonForName("btn_lzcjl") -- 量子仓奖励
    self.btn_lzcjl:setHighlighted(false)
    self.btn_lzcjl:setTouchPriority(helper.yhjlTouchPriority)
    game_util:setCCControlButtonTitle(self.btn_lzcjl, helper.txt.god_escort_txt_11)
    self.btn_gnlcb = ccbNode:controlButtonForName("btn_gnlcb") -- 光年里程碑
    self.btn_gnlcb:setHighlighted(false)
    self.btn_gnlcb:setTouchPriority(helper.yhjlTouchPriority)
    game_util:setCCControlButtonTitle(self.btn_gnlcb, helper.txt.god_escort_txt_12)

    self.nd_yhjc = ccbNode:nodeForName("nd_yhjc") -- 远航奖励
    self.nd_yhpm = ccbNode:nodeForName("nd_yhpm") -- 远航排名
    self.nd_lzcjl = ccbNode:nodeForName("nd_lzcjl") -- 量子仓奖励
    self.nd_gnlcb = ccbNode:nodeForName("nd_gnlcb") -- 光年里程碑

    ccbNode:labelTTFForName("lb_yhic_jcsl1"):setString(helper.txt.god_escort_txt_14)
    ccbNode:labelTTFForName("lb_yhic_jcsl2"):setString(helper.txt.god_escort_txt_15)
    ccbNode:labelTTFForName("lb_yhic_jcsl3"):setString(helper.txt.god_escort_txt_16)
    ccbNode:labelTTFForName("lb_yhic_gzsm"):setString(helper.txt.god_escort_txt_17)
    ccbNode:labelTTFForName("lb_yhpm_desc1"):setString(helper.txt.god_escort_txt_18)
    ccbNode:labelTTFForName("lb_lzcjl_desc1"):setString(helper.txt.god_escort_txt_19)
    ccbNode:labelTTFForName("lb_gnlcb_desc1"):setString(helper.txt.god_escort_txt_19)
    ccbNode:labelTTFForName("lb_desc1"):setString(helper.txt.god_escort_txt_55)
    ccbNode:labelTTFForName("lb_desc2"):setString(helper.txt.god_escort_txt_56)
    ccbNode:labelTTFForName("lb_desc3"):setString(helper.txt.god_escort_txt_57)

    self.nd_yhpm_list = ccbNode:nodeForName("nd_yhpm_list") -- 远航排名列表
    self.nd_lzcjl_list = ccbNode:nodeForName("nd_lzcjl_list") -- 量子仓奖励列表
    self.nd_gnlcb_list = ccbNode:nodeForName("nd_gnlcb_list") -- 光年里程碑列表

    -- 规则
    local scroll_yhic_gzsmValue = ccbNode:scrollViewForName("scroll_yhic_gzsmValue")
    scroll_yhic_gzsmValue:setTouchPriority(helper.yhjlTouchPriority)
    local viewSize = scroll_yhic_gzsmValue:getViewSize();
    local tempLabel = game_util:createRichLabelTTF({text = helper:getTxtById(2),dimensions = CCSizeMake(320,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(192,247,255),fontSize = 10})
    local tempSize = tempLabel:getContentSize();
    scroll_yhic_gzsmValue:setContentSize(CCSizeMake(210,tempSize.height))
    scroll_yhic_gzsmValue:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    scroll_yhic_gzsmValue:addChild(tempLabel)
    
    self.selectIdx = 1

    return ccbNode
end

function game_god_escort_voyageReward.init(self, t_params)
    self.area_id = t_params.area_id
    self.round_id = t_params.round_id
    self.netData = t_params.gameData
    if self.netData.gift_box then
        game_data.m_cacheData.gift_box = self.netData.gift_box
    end
    self.cb = t_params.cb
end

function game_god_escort_voyageReward.create(self, t_params)
    cclog("[神域押镖] game_god_escort_voyageReward.create(self,t_params)")
    self:init(t_params)
    local ui = self:createUi()
    self:refreshUi()
    return ui
end

function game_god_escort_voyageReward.refreshUi(self)
    cclog("[神域押镖] game_god_escort_voyageReward.refreshUi(self,t_params)")

    if self.selectIdx == 1 then -- 远航奖励
        -- 宇宙图片
        local sp_universe = self.ccbNode:spriteForName("sp_yhjc_universe")
        sp_universe:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(helper.universeImg[self.area_id]))
        -- 宇宙名称
        local lb_yhjc_universe = self.ccbNode:labelTTFForName("lb_yhjc_universe")
        lb_yhjc_universe:setString(helper.txt[helper.universeKey[self.area_id]])
        -- 第一个奖励图片
        local nd_yhjc_icon1 = self.ccbNode:labelTTFForName("nd_yhjc_icon1")
        nd_yhjc_icon1:removeAllChildrenWithCleanup(true)
        local basic_reward = self.netData.basic_reward and self.netData.basic_reward[1]
        if basic_reward then
            local icon, name, count = game_util:getRewardByItemTable(basic_reward, nil, true)
            icon:setScale(30 / icon:getContentSize().width)
            nd_yhjc_icon1:addChild(icon)
            local onBtnCilck = function ( event, target )
                game_util:lookItemDetal( basic_reward )
            end
            local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
            button:setTouchPriority(helper.yhjlTouchPriority)
            button:setOpacity(0)
            nd_yhjc_icon1:addChild(button)
        end
        -- 第一个奖励数值
        local lb_yhic_jcslValue1 = self.ccbNode:labelTTFForName("lb_yhic_jcslValue1")
        lb_yhic_jcslValue1:setString(basic_reward and basic_reward[3] or helper.txt.god_escort_txt_85)
        -- 第二个奖励图片
        local nd_yhjc_icon2 = self.ccbNode:nodeForName("nd_yhjc_icon2")
        nd_yhjc_icon2:removeAllChildrenWithCleanup(true)
        local sp = CCSprite:create("icon/th_nl.png")
        sp:setScale(30 / sp:getContentSize().width)
        nd_yhjc_icon2:addChild(sp)
        -- 第二个奖励数值
        local lb_yhic_jcslValue2 = self.ccbNode:labelTTFForName("lb_yhic_jcslValue2")
        local total = self.netData.total or 0
        lb_yhic_jcslValue2:setString(total)
        -- 第三个奖励图片
        local nd_yhjc_icon3 = self.ccbNode:nodeForName("nd_yhjc_icon3")
        nd_yhjc_icon3:removeAllChildrenWithCleanup(true)
        local sp = CCSprite:create("icon/th_nl.png")
        sp:setScale(30 / sp:getContentSize().width)
        nd_yhjc_icon3:addChild(sp)
        -- 第三个奖励数值
        local lb_yhic_jcslValue3 = self.ccbNode:labelTTFForName("lb_yhic_jcslValue3")
        local self_total = self.netData.self_total or 0
        lb_yhic_jcslValue3:setString(self_total)
    end

    local nd_yhpm = self.nd_yhpm
    nd_yhpm:removeAllChildrenWithCleanup(true)
    if self.selectIdx == 2 then -- 远航排名
        local showData = {}
        local netData = self.netData or {}
        local rank = netData.rank or {}
        for k, v in pairs(rank) do
            v.id = tonumber(k)
            table.insert(showData, v)
        end
        table.sort(
            showData,
            function(a, b)
                return a.id < b.id
            end
        )
        nd_yhpm:addChild(self:createYhpmList(nd_yhpm:getContentSize(), showData))
    end

    local nd_lzcjl = self.nd_lzcjl
    nd_lzcjl:removeAllChildrenWithCleanup(true)
    if self.selectIdx == 3 then -- 量子仓奖励
        local showData = {}
        local statusComp = {[1] = 0,[0] = 1, [2] = 2}
        local netData = self.netData.data
        for k, v in ipairs(helper.cfg.highway_reward) do
            if v.sort == 2 then
                v.id = tonumber(k)
                table.insert(showData, v)
            end
        end
        table.sort(
            showData,
            function(a, b)
                local status1 = netData[tostring(a.id)] and netData[tostring(a.id)].status or 0
                local status2 = netData[tostring(b.id)] and netData[tostring(b.id)].status or 0
                if statusComp[status1] == statusComp[status2] then
                    return a.target1 < b.target1
                else
                    return statusComp[status1] < statusComp[status2]
                end
            end
        )
        nd_lzcjl:addChild(self:createLzcjlList(nd_lzcjl:getContentSize(), showData))
    end

    local nd_gnlcb = self.nd_gnlcb
    nd_gnlcb:removeAllChildrenWithCleanup(true)
    if self.selectIdx == 4 then -- 光年里程碑
        local showData = {}
        local statusComp = {[1] = 0,[0] = 1, [2] = 2}
        local netData = self.netData.data
        for k, v in ipairs(helper.cfg.highway_reward) do
            if v.sort == 3 then
                v.id = tonumber(k)
                table.insert(showData, v)
            end
        end
        table.sort(
            showData,
            function(a, b)
                local status1 = netData[tostring(a.id)] and netData[tostring(a.id)].status or 0
                local status2 = netData[tostring(b.id)] and netData[tostring(b.id)].status or 0
                if statusComp[status1] == statusComp[status2] then
                    return a.target1 < b.target1
                else
                    return statusComp[status1] < statusComp[status2]
                end
            end
        )
        nd_gnlcb:addChild(self:createGnlcbList(nd_gnlcb:getContentSize(), showData))
    end

    -- -- 红点
    local hasRed = helper:isRewardRed(2)
    if self.btn_lzcjl:getChildByTag(1) then
        self.btn_lzcjl:removeChildByTag(1, true)
    end
    if hasRed then
        local bit = CCSprite:createWithSpriteFrameName("bounty_bit.png")
        bit:setPosition(ccp(70,20))
        self.btn_lzcjl:addChild(bit, 0, 1)
    end

    local hasRed = helper:isRewardRed(3)
    if self.btn_gnlcb:getChildByTag(1) then
        self.btn_gnlcb:removeChildByTag(1, true)
    end
    if hasRed then
        local bit = CCSprite:createWithSpriteFrameName("bounty_bit.png")
        bit:setPosition(ccp(70,20))
        self.btn_gnlcb:addChild(bit, 0, 1)
    end
end

function game_god_escort_voyageReward:setBtnState(btnTag)
    self.btn_yhjc:setHighlighted(btnTag == 2)
    self.btn_yhpm:setHighlighted(btnTag == 3)
    self.btn_lzcjl:setHighlighted(btnTag == 4)
    self.btn_gnlcb:setHighlighted(btnTag == 5)
    self.nd_yhjc:setVisible(btnTag == 2)
    self.nd_yhpm:setVisible(btnTag == 3)
    self.nd_lzcjl:setVisible(btnTag == 4)
    self.nd_gnlcb:setVisible(btnTag == 5)

    self.selectIdx = btnTag - 1
end

function game_god_escort_voyageReward.createYhpmList(self, viewSize, rewardList)
    local params = {}
    local imgs = {"Common_Img_jin.png", "Common_Img_yin.png", "Common_Img_tong.png"}
    params.viewSize = viewSize
    params.row = 4
    params.column = 1 --列
    params.totalItem = #rewardList
    params.touchPriority = helper.yhjlTouchPriority
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
            ccbNode:openCCBFile("ccb/ui_god_escort_yhpmItem.ccbi")
            node:addChild(ccbNode)

            local data = rewardList[index + 1]
            local id = data.id
            local mileage = data.mileage
            local can_reward = data.can_reward
            -- sp_rank
            local sp_rank = ccbNode:spriteForName("sp_rank")
            if id <= 3 then
                sp_rank:setVisible(true)
                sp_rank:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(imgs[id]))
            else
                sp_rank:setVisible(false)
            end
            -- lb_rank
            local lb_rank = ccbNode:labelTTFForName("lb_rank")
            if id <= 3 then
                lb_rank:setString("")
            else
                lb_rank:setString(id)
            end
            -- lb_rank2
            local lb_rank2 = ccbNode:labelTTFForName("lb_rank2")
            if id <= 3 then
                lb_rank2:setString("")
            else
                lb_rank2:setString(helper.txt.god_escort_txt_72)
            end
            -- lb_value
            local ship_id = data.ship_id
            local name = helper:getTxtById((self.area_id - 1) * 8 + ship_id + 6 )
            ccbNode:labelTTFForName("lb_value"):setString(name)
            -- lb_value2
            ccbNode:labelTTFForName("lb_value2"):setString(mileage .. helper.txt.god_escort_txt_45)
            -- lb_desc1
            local value = helper.cfg.highway_lack[1].rank[id]
            ccbNode:labelTTFForName("lb_desc1"):setString(value .. helper.txt.god_escort_txt_73)
            -- lb_status
            local lb_status = ccbNode:labelTTFForName("lb_status")
            if can_reward then
                lb_status:setString(helper.txt.god_escort_txt_70)
                lb_status:setColor(game_util.c3b_parse("#637e9a"))
            else
                lb_status:setString(helper.txt.god_escort_txt_69)
                lb_status:setColor(game_util.c3b_parse("#d3fffa"))
            end
            -- sp_desc1
            local sp_desc1 = ccbNode:spriteForName("sp_desc1")
            sp_desc1:setVisible(not can_reward)
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, item)
        if eventType == "ended" and item then
        end
    end
    return TableViewHelper:create(params)
end

function game_god_escort_voyageReward.createLzcjlList(self, viewSize, rewardList)
    local params = {}
    params.viewSize = viewSize
    params.row = 4
    params.column = 1 --列
    params.totalItem = #rewardList
    params.touchPriority = helper.yhjlTouchPriority
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
            ccbNode:openCCBFile("ccb/ui_god_escort_lzcjlItem.ccbi")
            node:addChild(ccbNode)

            local data = rewardList[index + 1]
            local netData = self.netData.data
            local target1 = data.target1
            local target2 = data.target2
            local id = data.id
            local value1 = netData[tostring(id)].value1
            local value2 = netData[tostring(id)].value2
            local reward = data.reward
            -- lb_des1
            ccbNode:labelTTFForName("lb_des1"):setString(helper.txt.god_escort_txt_67 .. "*" .. target1 .. "(" .. value1 .. "/" .. target1 .. ")")
            -- lb_des2
            ccbNode:labelTTFForName("lb_des2"):setString(string.format(helper.txt.god_escort_txt_68, target2, value2, target2))
            -- nd_reward
            local nd_reward = ccbNode:nodeForName("nd_reward")
            nd_reward:removeAllChildrenWithCleanup(true)
            nd_reward:addChild(self:createRewardTable(nd_reward:getContentSize(), reward))
            -- -- lb_status
            -- local lb_status = ccbNode:labelTTFForName("lb_status")
            -- if netData[tostring(id)] and netData[tostring(id)].status ~= 0 then
            --     lb_status:setString(helper.txt.god_escort_txt_70)
            --     lb_status:setColor(game_util.c3b_parse("#637e9a"))
            -- else
            --     lb_status:setString(helper.txt.god_escort_txt_69)
            --     lb_status:setColor(game_util.c3b_parse("#d3fffa"))
            -- end
            -- sp_desc1
            local sp_desc1 = ccbNode:spriteForName("sp_desc1")
            sp_desc1:setVisible(netData[tostring(id)].status ~= 1)
            local status = netData[tostring(id)] and netData[tostring(id)].status or 0
            -- btn_lq
            local btn_lq = ccbNode:controlButtonForName("btn_lq")
            btn_lq:setTouchPriority(helper.yhjlTouchPriority)
            btn_lq:setVisible(status == 1)
            btn_lq:addHandleOfControlEvent(
                function()
                    local function responseMethod(tag, gameData)
                        local data = gameData:getNodeWithKey("data")
                        local gameData = json.decode(data:getFormatBuffer()) or {}

                        if gameData.gift_box then
                            game_data.m_cacheData.gift_box = gameData.gift_box
                        end
        
                        local reward = gameData.reward or {}
                        game_util:rewardTipsByDataTable(reward)
                        gameData.data = gameData.gift_box
                        self.netData = gameData
                        self:refreshUi()
                    end
                    local key = "highway_get_score_reward"
                    local params = {gift_id = id}
                    helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
                end,
                CCControlEventTouchUpInside
            )
            -- lb_status
            local lb_status = ccbNode:labelTTFForName("lb_status")
            lb_status:setVisible(status ~= 1)
            if status == 0 then -- 尚未达到
                lb_status:setString(helper.txt.god_escort_txt_69)
            else -- 已领取
                lb_status:setString(helper.txt.god_escort_txt_61)
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

function game_god_escort_voyageReward.createGnlcbList(self, viewSize, rewardList)
    local params = {}
    params.viewSize = viewSize
    params.row = 4
    params.column = 1 --列
    params.totalItem = #rewardList
    params.touchPriority = helper.yhjlTouchPriority
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
            ccbNode:openCCBFile("ccb/ui_god_escort_gnlcbItem.ccbi")
            node:addChild(ccbNode)

            local data = rewardList[index + 1]
            local netData = self.netData.data
            local target1 = data.target1
            local target2 = data.target2
            local value = netData[tostring(data.id)].value
            local reward = data.reward
            local id = data.id
            -- lb_des1
            ccbNode:labelTTFForName("lb_des1"):setString(helper.txt.god_escort_txt_71)
            -- lb_des2
            ccbNode:labelTTFForName("lb_des2"):setString(value .. "/" .. target1 .. helper.txt.god_escort_txt_45)
            -- nd_reward
            local nd_reward = ccbNode:nodeForName("nd_reward")
            nd_reward:removeAllChildrenWithCleanup(true)
            nd_reward:addChild(self:createRewardTable(nd_reward:getContentSize(), reward))
            -- -- lb_status
            -- local lb_status = ccbNode:labelTTFForName("lb_status")
            -- if netData[tostring(id)] and netData[tostring(id)].status ~= 0 then
            --     lb_status:setString(helper.txt.god_escort_txt_70)
            --     lb_status:setColor(game_util.c3b_parse("#637e9a"))
            -- else
            --     lb_status:setString(helper.txt.god_escort_txt_69)
            --     lb_status:setColor(game_util.c3b_parse("#d3fffa"))
            -- end
            -- sp_desc1
            local sp_desc1 = ccbNode:spriteForName("sp_desc1")
            sp_desc1:setVisible(netData[tostring(id)].status ~= 1)
            local status = netData[tostring(id)] and netData[tostring(id)].status or 0
            -- btn_lq
            local btn_lq = ccbNode:controlButtonForName("btn_lq")
            btn_lq:setTouchPriority(helper.yhjlTouchPriority)
            btn_lq:setVisible(status == 1)
            btn_lq:addHandleOfControlEvent(
                function()
                    local function responseMethod(tag, gameData)
                        local data = gameData:getNodeWithKey("data")
                        local gameData = json.decode(data:getFormatBuffer()) or {}
        
                        if gameData.gift_box then
                            game_data.m_cacheData.gift_box = gameData.gift_box
                        end

                        local reward = gameData.reward or {}
                        game_util:rewardTipsByDataTable(reward)
                        gameData.data = gameData.gift_box
                        self.netData = gameData
                        self:refreshUi()
                    end
                    local key = "highway_get_score_reward"
                    local params = {gift_id = id}
                    helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
                end,
                CCControlEventTouchUpInside
            )
            -- lb_status
            local lb_status = ccbNode:labelTTFForName("lb_status")
            lb_status:setVisible(status ~= 1)
            if status == 0 then -- 尚未达到
                lb_status:setString(helper.txt.god_escort_txt_69)
            else -- 已领取
                lb_status:setString(helper.txt.god_escort_txt_61)
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

function game_god_escort_voyageReward.createRewardTable(self, viewSize, rewardList)
    local params = {}
    params.viewSize = viewSize
    params.row = 1
    params.column = 3--列
    params.totalItem = #rewardList
    params.touchPriority = helper.yhjlTouchPriority
    params.showPoint = false
    params.itemActionFlag = false
    params.direction = kCCScrollViewDirectionHorizontal
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

return game_god_escort_voyageReward
