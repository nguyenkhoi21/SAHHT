--[[
    远航准备
]]
local game_god_escort_voyagePre = {}
local helper = require("lua/game_pop/game_god_escort_helper")

function game_god_escort_voyagePre.destroy(self)
    cclog("[神域押镖] game_god_escort_voyagePre:destroy()")
end

function game_god_escort_voyagePre.createUi(self)
    cclog("[神域押镖] game_god_escort_voyagePre.createUi(self)")
    local ccbNode = luaCCBNode:create()
    local function onMainClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 or btnTag == 3 then
            if self.cb then
                self.cb(self.gameData)
            end
            game_scene:removePopByName("game_god_escort_voyagePre")
        elseif btnTag == 2 then
            -- game_util:addMoveTips({text = "点击问号"})
            game_scene:addPop("game_god_escort_detail",{openMsg = helper:getTxtById(56)})
        elseif btnTag == 4 then
            game_scene:addPop(
                "game_god_escort_voyagePreAssist",
                {
                    area_id = self.area_id,
                    shipData = self.shipData,
                    cb = function(data)
                        local gameData = data.gameData
                        self:updateGameData(gameData)
                        self:refreshUi()
                    end
                }
            )
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainClick)
    ccbNode:openCCBFile("ccb/ui_god_escort_voyagePre.ccbi")
    self.ccbNode = ccbNode

    self.ly_di = ccbNode:layerForName("ly_di")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end
    self.ly_di:registerScriptTouchHandler(onTouch, false, helper.voyagePreTouchPriorityBase, true)
    self.ly_di:setTouchEnabled(true)

    ccbNode:controlButtonForName("btn_wenhao"):setTouchPriority(helper.voyagePreTouchPriority)
    ccbNode:controlButtonForName("btn_close"):setTouchPriority(helper.voyagePreTouchPriority)
    ccbNode:controlButtonForName("btn_ok"):setTouchPriority(helper.voyagePreTouchPriority)
    ccbNode:controlButtonForName("btn_wyzl"):setTouchPriority(helper.voyagePreTouchPriority)

    self.ccbNode:labelTTFForName("lb_desc1"):setString(helper.txt.god_escort_txt_40)
    self.ccbNode:labelTTFForName("lb_desc2"):setString(helper.txt.god_escort_txt_41)

    -- lb_shipName
    ccbNode:labelTTFForName("lb_shipName"):setString(helper:getTxtById((self.area_id - 1) * 8 + self.ship_id + 6 ))

    return ccbNode
end

function game_god_escort_voyagePre.init(self, t_params)
    self.area_id = t_params.area_id
    self.ship_id = t_params.ship_id
    self:updateGameData(t_params.gameData)
    self.cb = t_params.cb
end

function game_god_escort_voyagePre:updateGameData(gameData)
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
    self.add_buff_recard = gameData.add_buff_recard[tostring(self.shipData.ship_id)] or {}
end

function game_god_escort_voyagePre.create(self, t_params)
    cclog("[神域押镖] game_god_escort_voyagePre:create(t_params)")
    self:init(t_params)
    local ui = self:createUi()
    self:refreshUi()
    return ui
end

function game_god_escort_voyagePre.refreshUi(self)
    cclog("[神域押镖] game_god_escort_voyagePre:refreshUi()")
    local lv = 1 -- 准备阶段 - self.shipData.lv
    local highway_ship = helper.cfg.highway_ship
    local cfg = highway_ship[lv]
    -- sp_ship
    local sp_ship = self.ccbNode:spriteForName("sp_ship")
    sp_ship:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_ship_" .. lv .. ".png"))
    -- 累计航行
    local value = helper:getTotalMileage(self.shipData, self.round_id, self.sort, self.step, self.ts_start)
    self.ccbNode:labelTTFForName("lb_attr1"):setString(string.format(helper.txt.god_escort_txt_36, value))

    -- local steps = self.shipData.steps or {}
    -- local step = self.step
    -- local attrDatas = steps[tostring(step)] or {}
    -- if attrDatas == 0 then
    --     attrDatas = {}
    -- end

    local attrDatas = helper:getAttrDatasBySteps(self.shipData.steps)
    -- 额外收益
    local ship_income_add = attrDatas["ship_income_add"] or 0
    local value = cfg.basic[3] -- + ship_income_add 准备阶段不显示额外加成
    self.ccbNode:labelTTFForName("lb_attr2"):setString(string.format(helper.txt.god_escort_txt_37, value))
    -- 初始秒速
    local speed_add1 = attrDatas["speed_add1"] or 0
    local value = cfg.basic[1] -- + speed_add1 准备阶段不显示额外加成
    self.ccbNode:labelTTFForName("lb_attr3"):setString(string.format(helper.txt.god_escort_txt_38, value))
    -- 加速秒速
    local speed_add2 = attrDatas["speed_add2"] or 0
    local value = cfg.basic[2] -- + speed_add2 准备阶段不显示额外加成
    self.ccbNode:labelTTFForName("lb_attr4"):setString(string.format(helper.txt.god_escort_txt_39, value))

    self.ccbNode:labelTTFForName("lb_sx0"):setString(helper.txt.god_escort_txt_26 .. ": " .. (self.add_buff_recard["10"] or 0) .. "/????")
    self.ccbNode:labelTTFForName("lb_sx1"):setString(helper.txt.god_escort_txt_42 .. ": " .. (self.add_buff_recard["2"] or 0) .. "/????")
    self.ccbNode:labelTTFForName("lb_sx2"):setString(helper.txt.god_escort_txt_43 .. ": " .. (self.add_buff_recard["3"] or 0) .. "/????")
    self.ccbNode:labelTTFForName("lb_sx3"):setString(helper.txt.god_escort_txt_44 .. ": " .. (self.add_buff_recard["1"] or 0) .. "/????")
end

return game_god_escort_voyagePre
