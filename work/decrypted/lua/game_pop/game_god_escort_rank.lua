local game_god_escort_rank = {}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_rank.destroy(self)
    cclog("[神域押镖] game_god_escort_rank:destroy()")
end

function game_god_escort_rank.createUi(self)
    cclog("[神域押镖] game_god_escort_rank.createUi(self)")
    local ccbNode = luaCCBNode:create()
    local function onMainClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then
            game_scene:removePopByName("game_god_escort_rank")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainClick", onMainClick)
    ccbNode:openCCBFile("ccb/ui_god_escort_rank.ccbi")
    self.ccbNode = ccbNode

    self.ly_di = ccbNode:layerForName("ly_di")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end
    self.ly_di:registerScriptTouchHandler(onTouch, false, helper.voyagePreTouchPriorityBase, true)
    self.ly_di:setTouchEnabled(true)

    ccbNode:controlButtonForName("btn_close"):setTouchPriority(helper.voyagePreTouchPriority)

    return ccbNode
end

function game_god_escort_rank.init(self, t_params)
    self.gameData = t_params.gameData or {}
    self.rank = self.gameData.rank or {}
end

function game_god_escort_rank.create(self, t_params)
    cclog("[神域押镖] game_god_escort_rank:create(t_params)")
    self:init(t_params)
    local ui = self:createUi()
    self:refreshUi()
    return ui
end

function game_god_escort_rank.refreshUi(self)
    cclog("[神域押镖] game_god_escort_rank:refreshUi()")
    -- nd_list
    local showData = {}
    for k, v in pairs(self.rank) do
        v.idx = tonumber(k)
        table.insert(showData, v)
    end
    table.sort(
        showData,
        function(a, b)
            return a.idx < b.idx
        end
    )
    local nd_list = self.ccbNode:nodeForName("nd_list")
    nd_list:removeAllChildrenWithCleanup(true)
    nd_list:addChild(self:createRankList(nd_list:getContentSize(), showData))
    -- lb_notice
    local lb_notice = self.ccbNode:labelTTFForName("lb_notice")
    lb_notice:setString(helper.txt.god_escort_txt_105)
    lb_notice:setVisible(#showData == 0)
end

function game_god_escort_rank.createRankList(self, viewSize, rewardList)
    local imgs = {"Common_Img_jin.png", "Common_Img_yin.png", "Common_Img_tong.png"}
    local params = {}
    params.viewSize = viewSize
    params.row = 4
    params.column = 1 --列
    params.totalItem = #rewardList
    params.touchPriority = helper.voyagePreTouchPriority
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
            ccbNode:openCCBFile("ccb/ui_god_escort_rankItem.ccbi")
            node:addChild(ccbNode)

            local data = rewardList[index + 1]
            local id = index + 1
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
            -- lb_name
            local lb_name = ccbNode:labelTTFForName("lb_name")
            lb_name:setString(data.name)
            -- lb_value
            local lb_value = ccbNode:labelTTFForName("lb_value")
            lb_value:setString(data.score)
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, item)
        if eventType == "ended" and item then
            self.selectUniverseId = index + 1
            self:refreshRight()
        end
    end
    return TableViewHelper:create(params)
end

return game_god_escort_rank
