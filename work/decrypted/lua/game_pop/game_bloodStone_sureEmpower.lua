-------------------- 血石赋能 点化

local game_bloodStone_sureEmpower = {
    equip_gem_fate_stone = getConfig(game_config_field.equip_gem_fate_stone) and json.decode(getConfig(game_config_field.equip_gem_fate_stone):getFormatBuffer()) or {},
    equip_gem_fate_succinct = getConfig(game_config_field.equip_gem_fate_succinct) and json.decode(getConfig(game_config_field.equip_gem_fate_succinct):getFormatBuffer()) or {},
}

function game_bloodStone_sureEmpower.destroy(self)
end

function game_bloodStone_sureEmpower.back(self, type)
    game_scene:removePopByName("game_bloodStone_sureEmpower")
    self:destroy()
end

function game_bloodStone_sureEmpower.createUi(self)
    local ccbNode = luaCCBNode:create()
    local function onMainBtnClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if self.m_flag == true then
            return
        end

        cclog("[血石赋能 - 赋能确认] 点击按钮 --> " .. btnTag)

        if btnTag == 99999 then
            self:back()
        elseif btnTag == 1 then -- 确定
            cclog2({gem_id = self.m_selectGem.id},"[血石赋能 - 赋能确认] 赋能")
            local function responseMethod(tag, gameData)
                if gameData then
                    game_util:addMoveTips({ text = "Thành công Ban Sức"});
                    cclog2(gameData,"[血石赋能 - 赋能确认] gameData1")
                    local data = gameData:getNodeWithKey("data")
                    local gem_oid = data:getNodeWithKey("gem_oid"):toStr()
                    cclog2(gem_oid,"[血石赋能 - 赋能确认] gem_oid1")

                    self:back()
                    self.empowerSucc(gem_oid)
                end
            end
            network.sendHttpRequest(responseMethod, game_url.getUrlForKey("gem_fate_empowering"), http_request_method.GET, {gem_id = self.m_selectGem.id}, "gem_fate_empowering")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_bloodStone_reborn1.ccbi")

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

    -- ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    ccbNode:controlButtonForName("btn_1"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    ccbNode:controlButtonForName("btn_2"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)

    -- local gemQuality = self.m_selectGem.cfg:getNodeWithKey("quality"):toInt()
    -- local costRebornStone = self.equip_gem_fate_stone[tostring(gemQuality - 3)]
    --lb_content
    local lb_content = self.m_ccbNode:labelTTFForName("lb_content")
    -- lb_content1
    local lb_content1 = self.m_ccbNode:labelTTFForName("lb_content1")
    local icon, name, count, quality = game_util:getItemRewardId(id, 1)
    lb_content:setString(string.format("Xác nhận tiến hành Ban Sức cho Đá Quý không? Sau khi Ban Sức thì dòng chữ đã có sẽ bị thay thế"))
    local _cost = self.equip_gem_fate_succinct["1"].succinct_need
    local id = _cost[2][2]
    local icon, name, count, quality = game_util:getItemRewardId(id, 1)
    lb_content1:setString(string.format("Tiêu hao lần này: %sx%s Kim Cương: %s", name, _cost[2][3], _cost[1][3]))

    return ccbNode
end

function game_bloodStone_sureEmpower.refreshUi(self)
   
end


--[[--
    初始化
]]
function game_bloodStone_sureEmpower.init(self, t_params)
    self.m_selectGem = t_params.m_selectGem
    self.empowerSucc = t_params.empowerSucc
    cclog2(self.m_selectGem, "[血石赋能 - 赋能确认] m_selectGem")
end
--[[--
    创建ui入口并初始化数据
]]
function game_bloodStone_sureEmpower.create(self, t_params)
    cclog2(t_params, "[血石赋能 - 赋能确认] t_params")
    self:init(t_params)
    self.m_popUi = self:createUi()
    self:refreshUi()
    return self.m_popUi
end

--[[--
    回调方法
]]
function game_bloodStone_sureEmpower.callBackFunc(self)
    local callBackFunc = self.callBackFunc
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc()
    end
end

return game_bloodStone_sureEmpower
