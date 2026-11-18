local game_god_escort_achieve = {}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_achieve.destroy(self)
    cclog("[神域押镖] game_god_escort_achieve.destroy(self)")
end

function game_god_escort_achieve.createUi(self)
    cclog("[神域押镖] game_god_escort_achieve.createUi(self)")
    local ccbNode = luaCCBNode:create()
    local function onMainClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then
            if self.cb then
                self.cb(self.tasks)
            end
            game_scene:removePopByName("game_god_escort_achieve")
        elseif btnTag == 2 or btnTag == 3 or btnTag == 4 or btnTag == 5 then
            local boxIdx = btnTag - 1
            cclog("[神域押镖] game_god_escort_achieve 点击宝箱 boxIdx = " .. boxIdx)
            local boxStatus = self:checkBoxStatus(boxIdx)
            if boxStatus == 2 then
                game_util:addMoveTips({text = helper.txt.god_escort_txt_59})
                return
            end
            if boxStatus == 0 then
                game_util:addMoveTips({text = helper.txt.god_escort_txt_58})
                return
            end
            local function responseMethod(tag, gameData)
                local data = gameData:getNodeWithKey("data")
                local gameData = json.decode(data:getFormatBuffer()) or {}

                local reward = gameData.reward or {}
                game_util:rewardTipsByDataTable(reward)

                self:init({gameData = gameData})
                self:refreshUi()
            end
            local key = "highway_get_score_reward"
            local params = {gift_id = boxIdx}
            helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainClick", onMainClick)
    ccbNode:openCCBFile("ccb/ui_god_escort_achieve.ccbi")
    self.ccbNode = ccbNode

    self.m_dont_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true --intercept event
        end
    end
    self.m_dont_layer:registerScriptTouchHandler(onTouch, false, helper.achieveTouchPriorityBase, true)
    self.m_dont_layer:setTouchEnabled(true)

    ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(helper.achieveTouchPriority)

    ccbNode:labelTTFForName("lb_desc1"):setString(helper.txt.god_escort_txt_5)
    ccbNode:labelTTFForName("lb_desc2"):setString(helper.txt.god_escort_txt_20)

    return ccbNode
end

function game_god_escort_achieve.init(self, t_params)
    self.task_score = t_params.gameData.task_score
    self.tasks = t_params.gameData.tasks
    if t_params.gameData.gift_box then
        game_data.m_cacheData.gift_box = t_params.gameData.gift_box
    end
    self.got_score_reward = t_params.gameData.got_score_reward or {}
    if t_params.cb then
        self.cb = t_params.cb
    end 
end

function game_god_escort_achieve.create(self, t_params)
    cclog("[神域押镖] game_god_escort_achieve.create(self,t_params)")
    self:init(t_params)
    local ui = self:createUi()
    self:refreshUi()
    return ui
end

function game_god_escort_achieve.refreshUi(self)
    cclog("[神域押镖] game_god_escort_achieve.refreshUi(self,t_params)")
    local ccbNode = self.ccbNode
    for i = 1, 4 do
        local lb_jf = ccbNode:labelTTFForName("lb_jf" .. i)
        lb_jf:setString(string.format(helper.txt.god_escort_txt_21, i * 30))
        local btn_jf = ccbNode:controlButtonForName("btn_jf" .. i)
        btn_jf:setTouchPriority(helper.achieveTouchPriority)
        local boxStatus = self:checkBoxStatus(i)
        if boxStatus == 2 then
            btn_jf:setColor(ccc3(100, 100, 100))
        elseif boxStatus == 1 then
            btn_jf:setColor(ccc3(255, 255, 255))
        elseif boxStatus == 0 then
            btn_jf:setColor(ccc3(100, 100, 100))
        end
        -- 红点
        if btn_jf:getChildByTag(1) then
            btn_jf:removeChildByTag(1, true)
        end
        local hasRed = boxStatus == 1
        if hasRed then
            local bit = CCSprite:createWithSpriteFrameName("bounty_bit.png")
            bit:setPosition(ccp(30, 25))
            btn_jf:addChild(bit, 0, 1)
        end
    end
    -- nd_progress
    local nd_progress = self.ccbNode:nodeForName("nd_progress")
    nd_progress:removeAllChildrenWithCleanup(true)
    local progress = ExtProgressBar:createWithFrameName("Img_zhouchengjiu_jindu01.png", "Img_zhouchengjiu_jindu02.png", nd_progress:getContentSize())
    progress:setCurValue(self.task_score / 120 * 100, false)
    nd_progress:addChild(progress)
    -- nd_list
    local nd_list = self.ccbNode:nodeForName("nd_list")
    nd_list:removeAllChildrenWithCleanup(true)
    local data = {}
    for k, v in ipairs(helper.cfg.highway_task) do
        table.insert(
            data,
            {
                id = k,
                sort = v.sort,
                des = v.target2 and string.format(v.des, v.target1, v.target2) or string.format(v.des, v.target1),
                num = v.num
            }
        )
    end
    local statusSort = {[1]= 0,[0] = 1,[2]= 2}
    table.sort(data, function(a, b)
        local status1 = self.tasks[tostring(a.id)].status
        local status2 = self.tasks[tostring(b.id)].status
        if status1 == status2 then
            return tonumber(a.id) < tonumber(b.id)
        else
            return statusSort[status1] < statusSort[status2]
        end
    end)
    nd_list:addChild(self:createList(nd_list:getContentSize(), data))
end

function game_god_escort_achieve.createList(self, viewSize, rewardList)
    local params = {}
    params.viewSize = viewSize
    params.row = 3
    params.column = 2 --列
    params.totalItem = #rewardList
    params.touchPriority = helper.achieveTouchPriority
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

            local ccbNode = luaCCBNode:create()
            ccbNode:openCCBFile("ccb/ui_god_escort_achieveItem.ccbi")
            -- ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5))
            node:addChild(ccbNode)

            local data = rewardList[index + 1]
            local id = data.id

            local lb_desc1 = ccbNode:labelTTFForName("lb_desc1")
            lb_desc1:setString(data.des)
            local lb_desc2 = ccbNode:labelTTFForName("lb_desc2")
            lb_desc2:setString(helper.txt.god_escort_txt_22)
            local lb_desc3 = ccbNode:labelTTFForName("lb_desc3")
            lb_desc3:setString(helper.txt.god_escort_txt_23 .. "x" .. data.num)
            lb_desc3:setPositionX(lb_desc2:getPositionX() + lb_desc2:getContentSize().width + 5)
            -- btn_1
            local btn_1 = ccbNode:controlButtonForName("btn_1")
            local lb_status = ccbNode:labelTTFForName("lb_status")
            if self.tasks[tostring(id)].status == 1 then
                btn_1:setVisible(true)
                lb_status:setVisible(false)
                game_util:setCCControlButtonTitle(btn_1, helper.txt.god_escort_txt_60)
                btn_1:setTouchPriority(helper.achieveTouchPriority)
            elseif self.tasks[tostring(id)].status == 2 then
                btn_1:setVisible(false)
                lb_status:setVisible(true)
                lb_status:setString(helper.txt.god_escort_txt_61)
            else
                btn_1:setVisible(false)
                lb_status:setVisible(true)
                lb_status:setString(helper.txt.god_escort_txt_62)
            end
            btn_1:addHandleOfControlEvent(
                function()
                    if self.tasks[tostring(id)].status == 1 then
                        local function responseMethod(tag, gameData)
                            local data = gameData:getNodeWithKey("data")
                            local gameData = json.decode(data:getFormatBuffer()) or {}
                            local reward = gameData.reward or {}
                            game_util:rewardTipsByDataTable(reward)
                            self:init({gameData = gameData})
                            self:refreshUi()
                        end
                        local key = "highway_get_task_reward"
                        local params = {task_id = id}
                        helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
                    end
                end,
                CCControlEventTouchUpInside
            )
            -- 红点
            if btn_1:getChildByTag(1) then
                btn_1:removeChildByTag(1, true)
            end
            local hasRed = self.tasks[tostring(id)].status == 1
            if hasRed then
                local bit = CCSprite:createWithSpriteFrameName("bounty_bit.png")
                bit:setPosition(ccp(40, 20))
                btn_1:addChild(bit, 0, 1)
            end
            return cell
        end
    end
    params.itemOnClick = function(eventType, index, item)
        if eventType == "ended" and item then
        end
    end
    return TableViewHelper:create(params)
end

--[[
    检查宝箱当前状态
]]
function game_god_escort_achieve.checkBoxStatus(self, idx)
    if game_util:idInTableById(idx, self.got_score_reward) then -- 已领取
        return 2
    end
    if self.task_score >= (idx * 30) then -- 可领取
        return 1
    end
    return 0 -- 不可领取
end

return game_god_escort_achieve
