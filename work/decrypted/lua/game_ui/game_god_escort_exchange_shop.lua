local game_god_escort_exchange_shop = {}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_exchange_shop.destroy(self)
    cclog("[神域押镖] game_god_escort_exchange_shop:destroy()")
end

function game_god_escort_exchange_shop.createUi(self)
    cclog("[神域押镖] game_god_escort_exchange_shop.createUi(self)")
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
        elseif btnTag == 5 then
            local fresh_price = helper.cfg.highway_trans[1].flash
            local refresh_times = self.refresh_times + 1
            if refresh_times > #fresh_price then
                refresh_times = #fresh_price
            end
            local icon, name, count = game_util:getRewardByItemTable(fresh_price[refresh_times], nil, true)
            local tx = string.format(helper.txt.god_escort_txt_106, fresh_price[refresh_times][3] .. name)
            game_scene:addPop(
                "game_god_escort_notice",
                {
                    tx = tx,
                    cb = function()
                        local function responseMethod(tag, gameData)
                            local data = gameData:getNodeWithKey("data")
                            local gameData = json.decode(data:getFormatBuffer()) or {}
                            self:init({gameData = gameData})
                            self:refreshUi()
                            game_util:addMoveTips({text = helper.txt.god_escort_txt_87})
                        end
                        local key = "highway_refresh_trans_items"
                        local params = {}
                        helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
                    end
                }
            )
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainClick)
    ccbNode:openCCBFile("ccb/ui_god_escort_exchange_shop.ccbi")
    self.ccbNode = ccbNode

    ccbNode:controlButtonForName("m_back_btn"):setTouchPriority(helper.shopTouchPriority)

    return ccbNode
end

function game_god_escort_exchange_shop.init(self, t_params)
    self.gameData = t_params.gameData
    self.shop_goods = self.gameData.shop_goods or {}
    self.power = self.gameData.power or 0
    game_data.m_cacheData.escort_power = self.power
    self.refresh_times = self.gameData.refresh_times or 0
    self.goods = self.gameData.goods or {}
    self.trans_log = self.gameData.trans_log or {}
end

function game_god_escort_exchange_shop.create(self, t_params)
    cclog("[神域押镖] game_god_escort_exchange_shop:create(t_params)")
    self:init(t_params)
    local ui = self:createUi()
    self:refreshUi()
    return ui
end

function game_god_escort_exchange_shop.refreshUi(self)
    cclog("[神域押镖] game_god_escort_exchange_shop:refreshUi()")
    -- lb_has1
    local lb_has1 = self.ccbNode:labelTTFForName("lb_has1")
    lb_has1:setString(game_data.m_cacheData.escort_power or 0)
    -- lb_has2
    local lb_has2 = self.ccbNode:labelTTFForName("lb_has2")
    lb_has2:setString(game_data:getUserStatusDataByKey("coin") or 0)
    -- nd_icon1
    local nd_icon1 = self.ccbNode:nodeForName("nd_icon1")
    nd_icon1:removeAllChildrenWithCleanup(true)
    local sp = CCSprite:create("icon/th_nl.png")
    sp:setScale(20 / sp:getContentSize().width)
    nd_icon1:addChild(sp)
    -- nd_icon2
    local nd_icon2 = self.ccbNode:nodeForName("nd_icon2")
    nd_icon2:removeAllChildrenWithCleanup(true)
    local sp = CCSprite:createWithSpriteFrameName("public_icon_gold2.png")
    sp:setScale(20 / sp:getContentSize().width)
    nd_icon2:addChild(sp)
    -- lb_use 刷新
    local lb_use = self.ccbNode:labelTTFForName("lb_use")
    local fresh_price = helper.cfg.highway_trans[1].flash
    local refresh_times = self.refresh_times + 1
    if refresh_times > #fresh_price then
        refresh_times = #fresh_price
    end
    lb_use:setString(fresh_price[refresh_times][3])
    -- nd_icon3
    local nd_icon3 = self.ccbNode:nodeForName("nd_icon3")
    nd_icon3:removeAllChildrenWithCleanup(true)
    local icon, name, count = game_util:getRewardByItemTable(fresh_price[refresh_times], nil, true)
    icon:setScale(20 / icon:getContentSize().width)
    nd_icon3:addChild(icon)
    -- 列表
    local showData = {}
    for k, v in pairs(self.goods) do
        v.id = tonumber(k)
        table.insert(showData, v)
    end
    table.sort(
        showData,
        function(a, b)
            return a.id < b.id
        end
    )
    local nd_list = self.ccbNode:nodeForName("nd_list")
    nd_list:removeAllChildrenWithCleanup(true)
    nd_list:addChild(self:createShopItemList(nd_list:getContentSize(), showData))
    -- lb_notice
    local lb_notice = self.ccbNode:labelTTFForName("lb_notice")
    lb_notice:setString(helper.txt.god_escort_txt_103)
    lb_notice:setVisible(#showData == 0)
end

function game_god_escort_exchange_shop.createShopItemList(self, viewSize, rewardList)
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
            local reward = {6, data.item_id, data.num}
            local icon, name, count = game_util:getRewardByItemTable(reward)
            -- lb_name
            ccbNode:labelTTFForName("lb_name"):setString(name)
            -- nd_icon
            local nd_icon = ccbNode:nodeForName("nd_icon")
            nd_icon:removeAllChildrenWithCleanup(true)
            if icon then
                icon:setAnchorPoint(ccp(0.5, 0.5))
                icon:setPosition(ccp(0, 0))
                nd_icon:addChild(icon, 10)
            end
            -- sp_xiangou
            ccbNode:spriteForName("sp_xiangou"):setVisible(false)
            -- lb_count
            ccbNode:labelTTFForName("lb_count"):setString(count)
            -- btn_buy
            local btn_buy = ccbNode:controlButtonForName("btn_buy")
            game_util:setCCControlButtonTitle(btn_buy, helper.txt.god_escort_txt_25)
            btn_buy:setTouchPriority(helper.shopTouchPriority)
            btn_buy:addHandleOfControlEvent(
                function()
                    if data.num == 0 then
                        game_util:addMoveTips({text = helper.txt.god_escort_txt_104})
                        return
                    end
                    game_scene:addPop(
                        "game_god_escort_exchange",
                        {
                            reward = reward,
                            num = data.num,
                            c_id = data.c_id,
                            pos_id = data.id,
                            trans_log = self.trans_log,
                            cb = function(data)
                                self:init(data)
                                self:refreshUi()
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

return game_god_escort_exchange_shop
