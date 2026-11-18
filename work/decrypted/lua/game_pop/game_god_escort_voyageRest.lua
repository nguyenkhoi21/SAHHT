local game_god_escort_voyageRest = {}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_voyageRest.destroy(self)
    cclog("[神域押镖] game_god_escort_voyageRest:destroy()")
end

function game_god_escort_voyageRest.createUi(self)
    cclog("[神域押镖] game_god_escort_voyageRest.createUi(self)")
    local ccbNode = luaCCBNode:create()
    local function onMainClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then
            game_scene:removePopByName("game_god_escort_voyageRest")
        elseif btnTag == 2 then
            -- game_util:addMoveTips({text = "点击问号"})
            if self.sort == 6 then
                game_scene:addPop("game_god_escort_detail",{openMsg = helper:getTxtById(59)})
            else
                game_scene:addPop("game_god_escort_detail",{openMsg = helper:getTxtById(57)})
            end
        elseif type(btnTag) == "number" and btnTag >= 11 and btnTag <= 16 then
            if self.sort == 6 then
                return
            end
            if btnTag >= 11 and btnTag <= 13 and not self.isBetShip then
                game_util:addMoveTips({text = helper.txt.god_escort_txt_115})
                return
            end
            if btnTag >= 14 and btnTag <= 16 and self.isBetShip then
                game_util:addMoveTips({text = helper.txt.god_escort_txt_77})
                return
            end
            self:addBuff(btnTag - 10)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainClick)
    ccbNode:openCCBFile("ccb/ui_god_escort_voyageRest.ccbi")
    self.ccbNode = ccbNode

    self.ly_di = ccbNode:layerForName("ly_di")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end
    self.ly_di:registerScriptTouchHandler(onTouch, false, helper.voyagePreTouchPriorityBase, true)
    self.ly_di:setTouchEnabled(true)

    ccbNode:labelTTFForName("lb_desc1"):setString(helper.txt.god_escort_txt_40)

    if self.sort == 6 then
        local sp_title = ccbNode:spriteForName("sp_title")
        sp_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("escort_yhsg.png"))
    end

    ccbNode:controlButtonForName("btn_wenhao"):setTouchPriority(helper.voyagePreTouchPriority)
    ccbNode:controlButtonForName("btn_close"):setTouchPriority(helper.voyagePreTouchPriority)
    ccbNode:controlButtonForName("btn_ok"):setTouchPriority(helper.voyagePreTouchPriority)
    ccbNode:controlButtonForName("btn_zuli1"):setTouchPriority(helper.voyagePreTouchPriority)
    if self.sort == 6 then
        ccbNode:controlButtonForName("btn_zuli1"):setColor(ccc3(100, 100, 100))
    end
    -- game_util:setCCControlButtonTitle(ccbNode:controlButtonForName("btn_zuli1"), helper.txt.god_escort_txt_48)
    ccbNode:controlButtonForName("btn_zuli2"):setTouchPriority(helper.voyagePreTouchPriority)
    if self.sort == 6 then
        ccbNode:controlButtonForName("btn_zuli2"):setColor(ccc3(100, 100, 100))
    end
    -- game_util:setCCControlButtonTitle(ccbNode:controlButtonForName("btn_zuli2"), helper.txt.god_escort_txt_48)
    ccbNode:controlButtonForName("btn_zuli3"):setTouchPriority(helper.voyagePreTouchPriority)
    if self.sort == 6 then
        ccbNode:controlButtonForName("btn_zuli3"):setColor(ccc3(100, 100, 100))
    end
    -- game_util:setCCControlButtonTitle(ccbNode:controlButtonForName("btn_zuli3"), helper.txt.god_escort_txt_48)
    ccbNode:controlButtonForName("btn_ganrao1"):setTouchPriority(helper.voyagePreTouchPriority)
    if self.sort == 6 then
        ccbNode:controlButtonForName("btn_ganrao1"):setColor(ccc3(100, 100, 100))
    end
    -- game_util:setCCControlButtonTitle(ccbNode:controlButtonForName("btn_ganrao1"), helper.txt.god_escort_txt_48)
    ccbNode:controlButtonForName("btn_ganrao2"):setTouchPriority(helper.voyagePreTouchPriority)
    if self.sort == 6 then
        ccbNode:controlButtonForName("btn_ganrao2"):setColor(ccc3(100, 100, 100))
    end
    -- game_util:setCCControlButtonTitle(ccbNode:controlButtonForName("btn_ganrao2"), helper.txt.god_escort_txt_48)
    ccbNode:controlButtonForName("btn_ganrao3"):setTouchPriority(helper.voyagePreTouchPriority)
    if self.sort == 6 then
        ccbNode:controlButtonForName("btn_ganrao3"):setColor(ccc3(100, 100, 100))
    end
    -- game_util:setCCControlButtonTitle(ccbNode:controlButtonForName("btn_ganrao3"), helper.txt.god_escort_txt_48)

    self.ccbNode:labelTTFForName("lb_desc2"):setString(helper.txt.god_escort_txt_47)
    -- lb_shipName
    local lv = self.shipData.lv
    local name = "Lv." .. lv .. " " .. helper:getTxtById((self.area_id - 1) * 8 + self.ship_id + 6 )
    ccbNode:labelTTFForName("lb_shipName"):setString(name)
    return ccbNode
end

function game_god_escort_voyageRest.init(self, t_params)
    self.area_id = t_params.area_id
    self.ship_id = t_params.ship_id
    self:updateGameData(t_params.gameData)
    self.isBetShip = t_params.isBetShip
    self.cb = t_params.cb
end

function game_god_escort_voyageRest:updateGameData(gameData)
    self.gameData = gameData
    self.shipDatas = gameData.data
    for k, v in pairs(self.shipDatas) do
        if v.ship_id == self.ship_id then
            self.shipData = v
            break
        end
    end
    self.round_id = gameData.round_id
    self.sort = gameData.sort
    self.step = gameData.step
    self.ts_start = gameData.ts_start
end

function game_god_escort_voyageRest.create(self, t_params)
    cclog("[神域押镖] game_god_escort_voyageRest:create(t_params)")
    self:init(t_params)
    local ui = self:createUi()
    self:refreshUi()
    return ui
end

function game_god_escort_voyageRest.refreshUi(self)
    cclog("[神域押镖] game_god_escort_voyageRest:refreshUi()")
    local all = self.shipData.all or {}
    local d1 = 0
    local d2 = 0
    local d3 = 0
    local d4 = 0
    local d5 = 0
    local d6 = 0
    local _step = self.step
    if _step == 0 then
        _step = 5
    end
    for i = 1, _step do
        local _data = all[tostring(i)] or {}
        d1 = d1 + (_data["1"] or 0)
        d2 = d2 + (_data["2"] or 0)
        d3 = d3 + (_data["3"] or 0)
        d4 = d4 + (_data["4"] or 0)
        d5 = d5 + (_data["5"] or 0)
        d6 = d6 + (_data["6"] or 0)
    end
    self.ccbNode:labelTTFForName("lb_zuli1"):setString(helper.txt.god_escort_txt_42 .. ":" .. d2)
    self.ccbNode:labelTTFForName("lb_zuli2"):setString(helper.txt.god_escort_txt_43 .. ":" .. d3)
    self.ccbNode:labelTTFForName("lb_zuli3"):setString(helper.txt.god_escort_txt_44 .. ":" .. d1)
    self.ccbNode:labelTTFForName("lb_ganrao1"):setString(helper.txt.god_escort_txt_49 .. ":" .. d5)
    self.ccbNode:labelTTFForName("lb_ganrao2"):setString(helper.txt.god_escort_txt_50 .. ":" .. d6)
    self.ccbNode:labelTTFForName("lb_ganrao3"):setString(helper.txt.god_escort_txt_51 .. ":" .. d4)
    local lv = self.shipData.lv
    local highway_ship = helper.cfg.highway_ship
    local cfg = highway_ship[lv]
    -- sp_ship
    local sp_ship = self.ccbNode:spriteForName("sp_ship")
    sp_ship:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_ship_" .. lv .. ".png"))
    -- 累计航行
    local value = helper:getTotalMileage(self.shipData, self.round_id, self.sort, self.step, self.ts_start)
    self.ccbNode:labelTTFForName("lb_attr1"):setString(string.format(helper.txt.god_escort_txt_36, value))
    
    local attrDatas = helper:getAttrDatasBySteps(self.shipData.steps)
    -- 额外收益
    local ship_income_add = attrDatas["ship_income_add"] or 0
    local value = cfg.basic[3] + ship_income_add
    value = value > 0 and value or 0
    self.ccbNode:labelTTFForName("lb_attr2"):setString(string.format(helper.txt.god_escort_txt_37, value))
    -- 初始秒速
    local speed_add1 = attrDatas["speed_add1"] or 0
    local value = cfg.basic[1] + speed_add1
    value = value > 0 and value or 0
    self.ccbNode:labelTTFForName("lb_attr3"):setString(string.format(helper.txt.god_escort_txt_38, value))
    -- 加速秒速
    local speed_add2 = attrDatas["speed_add2"] or 0
    local value = cfg.basic[2] + speed_add2
    value = value > 0 and value or 0
    self.ccbNode:labelTTFForName("lb_attr4"):setString(string.format(helper.txt.god_escort_txt_39, value))
end

function game_god_escort_voyageRest:addBuff(id)
    if self:getHasById(id) <= 0 then
        if id <= 3 then
            game_util:addMoveTips({text = helper.txt["god_escort_txt_53"]})
        else
            game_util:addMoveTips({text = helper.txt["god_escort_txt_54"]})
        end
        return
    end

    local function responseMethod(tag, gameData)
        local data = gameData:getNodeWithKey("data")
        local gameData = json.decode(data:getFormatBuffer()) or {}

        self:updateGameData(gameData)
        game_util:addMoveTips({text = helper.txt["god_escort_txt_52_" .. id]})
        self.cb(gameData)
        self:refreshUi()
    end
    local key = "highway_add_buff"
    local params = {
        area_id = self.area_id,
        ship_id = self.ship_id,
        sort = id
    }
    helper.sendHttpRequest(responseMethod, game_url.getUrlForKey(key), http_request_method.GET, params, key)
end

function game_god_escort_voyageRest:getHasById(id)
    return helper:getHasById(id)
end

return game_god_escort_voyageRest
