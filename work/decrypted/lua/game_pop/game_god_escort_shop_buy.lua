local game_god_escort_shop_buy = {}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_shop_buy.destroy(self)
    self.curValue = 1
    cclog("[神域押镖] game_god_escort_shop_buy:destroy()")
end

function game_god_escort_shop_buy.createUi(self)
    cclog("[神域押镖] game_god_escort_shop_buy.createUi(self)")
    local ccbNode = luaCCBNode:create()
    local function onMainClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then
            game_scene:removePopByName("game_god_escort_shop_buy")
        elseif btnTag == 2 then -- -10
            self.curValue = self.curValue - 10
            if self.curValue < 1 then
                self.curValue = 1
            end
            self:refreshUi()
        elseif btnTag == 3 then -- -1
            self.curValue = self.curValue - 1
            if self.curValue < 1 then
                self.curValue = 1
            end
            self:refreshUi()
        elseif btnTag == 4 then -- +1
            self.curValue = self.curValue + 1
            if self.remain and self.curValue > self.remain then -- 商品不足
                self.curValue = self.remain
                game_util:addMoveTips({text = helper.txt.god_escort_txt_123})
            end
            if self.curValue > self.maxSingleValue then -- 单次限制购买99个
                self.curValue = self.maxSingleValue
                game_util:addMoveTips({text = helper.txt.god_escort_txt_124})
            end
            self:refreshUi()
        elseif btnTag == 5 then -- +10
            self.curValue = self.curValue + 10
            if self.remain and self.curValue > self.remain then -- 商品不足
                self.curValue = self.remain
                game_util:addMoveTips({text = helper.txt.god_escort_txt_123})
            end
            if self.curValue > self.maxSingleValue then -- 单次限制购买99个
                self.curValue = self.maxSingleValue
                game_util:addMoveTips({text = helper.txt.god_escort_txt_124})
            end
            self:refreshUi()
        elseif btnTag == 6 then -- +MAX
            self.curValue = self.maxSingleValue
            if self.remain and self.curValue > self.remain then
                self.curValue = self.remain
            end
            self:refreshUi()
        elseif btnTag == 7 then -- 确定
            cclog("[神域押镖] game_god_escort_shop_buy:确定")
            local tx = helper.txt.god_escort_txt_125
            game_scene:addPop(
                "game_god_escort_notice",
                {
                    tx = tx,
                    cb = function()
                        local function responseMethod(tag, gameData)
                            local data = gameData:getNodeWithKey("data")
                            local gameData = json.decode(data:getFormatBuffer()) or {}
                            local power = gameData.power or 0
                            game_data.m_cacheData.escort_power = power
                            if self.cb then
                                self.cb({gameData = gameData})
                            end
                            game_scene:removePopByName("game_god_escort_shop_buy")
                            game_util:addMoveTips({text = helper.txt.god_escort_txt_64})
                        end
                        local key = "highway_buy"
                        local params = {
							sort = self.sort,
							goods_id = self.goods_id,
                            num = self.curValue
                        }
                        helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
                    end
                }
            )
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainClick)
    ccbNode:openCCBFile("ccb/ui_god_escort_shop_buy.ccbi")
    self.ccbNode = ccbNode

    self.ly_di = ccbNode:layerForName("ly_di")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end
    self.ly_di:registerScriptTouchHandler(onTouch, false, helper.exchangeTouchPriorityBase, true)
    self.ly_di:setTouchEnabled(true)

    ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(helper.exchangeTouchPriority)
    ccbNode:controlButtonForName("btn_1"):setTouchPriority(helper.exchangeTouchPriority)
    ccbNode:controlButtonForName("btn_2"):setTouchPriority(helper.exchangeTouchPriority)
    ccbNode:controlButtonForName("btn_3"):setTouchPriority(helper.exchangeTouchPriority)
    ccbNode:controlButtonForName("btn_4"):setTouchPriority(helper.exchangeTouchPriority)
    ccbNode:controlButtonForName("btn_5"):setTouchPriority(helper.exchangeTouchPriority)
    ccbNode:controlButtonForName("btn_6"):setTouchPriority(helper.exchangeTouchPriority)

    local nd_icon = ccbNode:controlButtonForName("nd_icon")
    nd_icon:removeAllChildrenWithCleanup(true)
    nd_icon:setScale(1.3)
    local reward = self.reward
    local icon, name, count = game_util:getRewardByItemTable(reward, nil, true)
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
    self.ccbNode:labelTTFForName("lb_name"):setString(name)

    self.curValue = 1
    self.maxSingleValue = 99

    return ccbNode
end

function game_god_escort_shop_buy.init(self, t_params)
    self.reward = t_params.reward
    self.remain = t_params.remain
    self.cb = t_params.cb
	self.sort = t_params.sort
	self.goods_id = t_params.goods_id
	-- self.has = t_params.has
	-- self.cost = t_params.cost
end

function game_god_escort_shop_buy.create(self, t_params)
     cclog("[神域押镖] game_god_escort_shop_buy:create(t_params)")
    self:init(t_params)
    local ui = self:createUi()
    self:refreshUi()
    return ui
end

function game_god_escort_shop_buy.refreshUi(self)
    cclog("[神域押镖] game_god_escort_shop_buy:refreshUi()")
    self.ccbNode:labelTTFForName("lb_num"):setString(self.curValue)
end

return game_god_escort_shop_buy
