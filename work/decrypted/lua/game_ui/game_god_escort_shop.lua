local game_god_escort_shop = {
    selectIdx = 1
}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_shop.destroy(self)
    self.selectIdx = 1
    cclog("[神域押镖] game_god_escort_shop.destroy(self)")
end

function game_god_escort_shop.createUi(self)
    cclog("[神域押镖] game_god_escort_shop.createUi(self)")
    local ccbNode = luaCCBNode:create()
    local function onMainClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then
            local function responseMethod(tag, gameData)
                game_scene:enterGameUi("game_god_escort_bet", {gameData = gameData})
                self:destroy()
            end
            helper.sendHttpRequest(responseMethod, game_url.getUrlForKey("highway_index"), http_request_method.GET, nil, "highway_index")
        elseif type(btnTag) == "number" and btnTag >= 2 and btnTag <= 4 then
            self:switchShop(btnTag - 1)
        elseif btnTag == 5 then
            local tx = string.format(helper.txt.god_escort_txt_106, self.refreshCostTx)
            game_scene:addPop("game_god_escort_notice",{tx = tx, cb = function()
                local function responseMethod(tag, gameData)
                    local data = gameData:getNodeWithKey("data")
                    local gameData = json.decode(data:getFormatBuffer()) or {}
                    local power = gameData.power or 0
                    game_data.m_cacheData.escort_power = power
                    self:init({gameData = gameData})
                    self:refreshUi()
                end
                local key = "highway_refresh_shop"
                local params = {
                    sort = self.selectIdx
                }
                helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
            end})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainClick)
    ccbNode:openCCBFile("ccb/ui_god_escort_shop.ccbi")
    self.ccbNode = ccbNode

    ccbNode:controlButtonForName("m_back_btn"):setTouchPriority(helper.shopTouchPriority)

    self.btn_nlsd = ccbNode:controlButtonForName("btn_nlsd")
    self.btn_nlsd:setTouchPriority(helper.shopTouchPriority)
    self.btn_nlsd:setHighlighted(true)
    self.btn_yhgp = ccbNode:controlButtonForName("btn_yhgp")
    self.btn_yhgp:setTouchPriority(helper.shopTouchPriority)
    self.btn_yhgp:setHighlighted(false)
    self.btn_zsh = ccbNode:controlButtonForName("btn_zsh")
    self.btn_zsh:setTouchPriority(helper.shopTouchPriority)
    self.btn_zsh:setHighlighted(false)

    self.selectIdx = 1

    return ccbNode
end

function game_god_escort_shop.init(self, t_params)
    self.gameData = t_params.gameData
    self.shop_goods = self.gameData.shop_goods or {}
    self.buy_log = self.gameData.buy_log or {}
    self.refresh_times = self.gameData.refresh_times or 0
end

function game_god_escort_shop.create(self, t_params)
    cclog("[神域押镖] game_god_escort_shop.create(self,t_params)")
    self:init(t_params)
    local scene = CCScene:create()
    scene:addChild(self:createUi())
    self:refreshUi()
    return scene
end

function game_god_escort_shop.refreshUi(self)
    cclog("[神域押镖] game_god_escort_shop.refreshUi(self,t_params)")
    local showData = {}
    for k, v in ipairs(helper.cfg.highway_shop) do
        if v.sort == self.selectIdx then
            for k1, v1 in ipairs(self.shop_goods) do
                if v1 == v.id then
                    table.insert(showData, v)
                    break
                end
            end
        end
    end
    local nd_list = self.ccbNode:nodeForName("nd_list")
    nd_list:removeAllChildrenWithCleanup(true)
    nd_list:addChild(self:createShopItemList(nd_list:getContentSize(), showData))
    --
    local nd_icon1 = self.ccbNode:nodeForName("nd_icon1")
    nd_icon1:removeAllChildrenWithCleanup(true)
    local nd_icon2 = self.ccbNode:nodeForName("nd_icon2")
    nd_icon2:removeAllChildrenWithCleanup(true)
    local lb_has = self.ccbNode:labelTTFForName("lb_has")
    local lb_use = self.ccbNode:labelTTFForName("lb_use")
    if self.selectIdx == 1 then
        local sp = CCSprite:create("icon/th_nl.png")
        sp:setScale(20 / sp:getContentSize().width)
        nd_icon1:addChild(sp)

        local sp = CCSprite:create("icon/th_nl.png")
        sp:setScale(20 / sp:getContentSize().width)
        nd_icon2:addChild(sp)

        lb_has:setString(game_data.m_cacheData.escort_power or 0)
        -- refresh_times
        local fresh_price = showData[1].fresh_price
        local refresh_times = self.refresh_times + 1
        if refresh_times > #fresh_price then
            refresh_times = #fresh_price
        end
        lb_use:setString(fresh_price[refresh_times][3])
        self.refreshCostTx = fresh_price[refresh_times][3] .. helper.txt.god_escort_txt_26
    elseif self.selectIdx == 2 then
        local item_cfg = getConfig(game_config_field.item)
        local itemCfg = item_cfg:getNodeWithKey("9101353")

        local sp = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr())
        sp:setScale(20 / sp:getContentSize().width)
        nd_icon1:addChild(sp)

        local sp = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr())
        sp:setScale(20 / sp:getContentSize().width)
        nd_icon2:addChild(sp)

        local count = game_data:getItemCountByCid(tostring(9101353)) or 0
        lb_has:setString(count)
        -- refresh_times
        local fresh_price = showData[1].fresh_price
        local refresh_times = self.refresh_times + 1
        if refresh_times > #fresh_price then
            refresh_times = #fresh_price
        end
        lb_use:setString(fresh_price[refresh_times][3])
        self.refreshCostTx = fresh_price[refresh_times][3] .. itemCfg:getNodeWithKey("name"):toStr()
    elseif self.selectIdx == 3 then
        local sp = CCSprite:createWithSpriteFrameName("public_icon_gold2.png")
        sp:setScale(20 / sp:getContentSize().width)
        nd_icon1:addChild(sp)

        local sp = CCSprite:createWithSpriteFrameName("public_icon_gold2.png")
        sp:setScale(20 / sp:getContentSize().width)
        nd_icon2:addChild(sp)

        local coin = game_data:getUserStatusDataByKey("coin") or 0
        lb_has:setString(coin)
        -- refresh_times
        local fresh_price = showData[1].fresh_price
        local refresh_times = self.refresh_times + 1
        if refresh_times > #fresh_price then
            refresh_times = #fresh_price
        end
        lb_use:setString(fresh_price[refresh_times][3])
        self.refreshCostTx = fresh_price[refresh_times][3] .. helper.txt.god_escort_txt_107
    end
end

function game_god_escort_shop.createShopItemList(self, viewSize, rewardList)
    local item_cfg = getConfig(game_config_field.item)
    local itemCfg = item_cfg:getNodeWithKey("9101353")
    local params = {}
    params.viewSize = viewSize
    params.row = 2
    params.column = 4 --列
    params.totalItem = #rewardList
    params.touchPriority = helper.shopTouchPriority
    params.showPoint = false
    params.itemActionFlag = false
    params.direction = kCCScrollViewDirectionHorizontal --纵向
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
            ccbNode:openCCBFile("ccb/ui_god_escort_shopItem.ccbi")
            node:addChild(ccbNode)

            local data = rewardList[index + 1]
            local type = data.type
            local limit = data.limit
            local reward = data.reward[1]
            local cost = data.price[1][3]
            local remain
            if type == 1 then -- 全服限购
                local server_buy_log = self.gameData.server_buy_log or {}
                local hasBuyTimes = server_buy_log[tostring(data.id)] or 0
                remain = limit - hasBuyTimes
            elseif type == 2 then -- 限购
                local buy_log = self.gameData.buy_log or {}
                local hasBuyTimes = buy_log[tostring(data.id)] or 0
                remain = limit - hasBuyTimes
            end
            local icon, name, count = game_util:getRewardByItemTable(reward)
            -- lb_name
            if type == 1 or type == 2 then
                ccbNode:labelTTFForName("lb_name"):setString(name .. "(" .. remain .. ")")
            else
                ccbNode:labelTTFForName("lb_name"):setString(name)
            end
            -- nd_icon
            local nd_icon = ccbNode:nodeForName("nd_icon")
            nd_icon:removeAllChildrenWithCleanup(true)
            if icon then
                icon:setAnchorPoint(ccp(0.5, 0.5))
                icon:setPosition(ccp(0, 0))
                nd_icon:addChild(icon, 10)

                if count then
                    local label_count = game_util:createLabelTTF({text = "×" .. tostring(count), color = ccc3(255, 255, 255), fontSize = 12})
                    label_count:setAnchorPoint(ccp(0.5, 0.5))
                    label_count:setPosition(ccp(14, -12))
                    nd_icon:addChild(label_count, 20)
                end

            end
            -- sp_xiangou
            local sp_xiangou = ccbNode:spriteForName("sp_xiangou")
            if type == 1 then -- 全服限购
                sp_xiangou:setVisible(true)
                sp_xiangou:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("escort_xiangou1.png"))
            elseif type == 2 then -- 限购
                sp_xiangou:setVisible(true)
                sp_xiangou:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("escort_xiangou2.png"))
            else
                sp_xiangou:setVisible(false)
            end
            -- lb_count
            local lb_count = ccbNode:labelTTFForName("lb_count")
            lb_count:setString(cost)
            -- nd_costIcon
            local nd_costIcon = ccbNode:nodeForName("nd_costIcon")
            nd_costIcon:removeAllChildrenWithCleanup(true)
            if self.selectIdx == 1 then
                local sp = CCSprite:create("icon/th_nl.png")
                sp:setScale(15 / sp:getContentSize().width)
                sp:setPosition(ccp(nd_costIcon:getContentSize().width / 2, nd_costIcon:getContentSize().height / 2))
                nd_costIcon:addChild(sp)
            elseif self.selectIdx == 2 then
                local sp = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr())
                sp:setScale(15 / sp:getContentSize().width)
                sp:setPosition(ccp(nd_costIcon:getContentSize().width / 2, nd_costIcon:getContentSize().height / 2))
                nd_costIcon:addChild(sp)
            elseif self.selectIdx == 3 then
                local sp = CCSprite:createWithSpriteFrameName("public_icon_gold2.png")
                sp:setScale(15 / sp:getContentSize().width)
                sp:setPosition(ccp(nd_costIcon:getContentSize().width / 2, nd_costIcon:getContentSize().height / 2))
                nd_costIcon:addChild(sp)
            end
            game_util:centerTwoNode(nd_costIcon, lb_count)
            -- btn_buy
            local btn_buy = ccbNode:controlButtonForName("btn_buy")
            -- if type == 1 then -- 全服限购
            --     game_util:setCCControlButtonTitle(btn_buy, string.format(helper.txt.god_escort_txt_100, limit, limit))
            --     game_util:setCCControlButtonSize(btn_buy, 9)
            -- elseif type == 2 then -- 限购
            --     game_util:setCCControlButtonTitle(btn_buy, string.format(helper.txt.god_escort_txt_101, limit, limit))
            --     game_util:setCCControlButtonSize(btn_buy, 9)
            -- else
                game_util:setCCControlButtonTitle(btn_buy, helper.txt.god_escort_txt_89)
                game_util:setCCControlButtonSize(btn_buy, 11)
            -- end
            btn_buy:setTouchPriority(helper.shopTouchPriority)
            btn_buy:addHandleOfControlEvent(
                function()
                    if type == 1 or type == 2 then
                        if remain <= 0 then
                            game_util:addMoveTips({text = helper.txt.god_escort_txt_102})
                            return
                        end
                    end
                    -- local has 
                    -- if self.selectIdx == 1 then
                    --     has = game_data.m_cacheData.escort_power or 0
                    -- elseif self.selectIdx == 2 then
                    --     has = game_data:getItemCountByCid(tostring(9101353)) or 0
                    -- elseif self.selectIdx == 3 then
                    --     has = game_data:getUserStatusDataByKey("coin") or 0
                    -- end
                    game_scene:addPop(
                        "game_god_escort_shop_buy",
                        {
                            reward = reward,
                            remain = remain,
                            goods_id = data.id,
                            -- cost = cost,
                            -- has = has,
                            sort = self.selectIdx,
                            cb = function(data)
                                self:init(data)
                                self:refreshUi()
                            end
                        }
                    )

                    -- local function responseMethod(tag, gameData)
                    --     local data = gameData:getNodeWithKey("data")
                    --     local gameData = json.decode(data:getFormatBuffer()) or {}
                    --     game_util:addMoveTips({text = helper.txt.god_escort_txt_64})
                    --     local power = gameData.power or 0
                    --     game_data.m_cacheData.escort_power = power
                    --     self:init({gameData = gameData})
                    --     self:refreshUi()
                    -- end
                    -- local key = "highway_buy"
                    -- local params = {
                    --     sort = self.selectIdx,
                    --     goods_id = data.id
                    -- }
                    -- helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
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

function game_god_escort_shop.switchShop(self, sort)
    if self.selectIdx == sort then
        return
    end

    local function responseMethod(tag, gameData)
        local data = gameData:getNodeWithKey("data")
        local gameData = json.decode(data:getFormatBuffer()) or {}
        self.btn_nlsd:setHighlighted(sort == 1)
        self.btn_yhgp:setHighlighted(sort == 2)
        self.btn_zsh:setHighlighted(sort == 3)
        self.selectIdx = sort
        self:init({gameData = gameData})
        self:refreshUi()
    end
    helper.sendHttpRequest(responseMethod, game_url.getUrlForKey("highway_shop_index"), http_request_method.GET, {sort = sort}, "highway_shop_index")
end

return game_god_escort_shop
