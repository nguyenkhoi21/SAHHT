-------------------- 血石赋能 点化

local game_bloodStone_reborn = {
    equip_gem_fate_stone = getConfig(game_config_field.equip_gem_fate_stone) and json.decode(getConfig(game_config_field.equip_gem_fate_stone):getFormatBuffer()) or {},
}

function game_bloodStone_reborn.destroy(self)
end

function game_bloodStone_reborn.back(self, type)
    game_scene:removePopByName("game_bloodStone_reborn")
    self:destroy()
end

function game_bloodStone_reborn.createUi(self)
    local ccbNode = luaCCBNode:create()
    local function onMainBtnClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if self.m_flag == true then
            return
        end

        cclog("[血石赋能 - 拓印] 点击按钮 --> " .. btnTag)

        if btnTag == 99999 then
            self:back()
        elseif btnTag == 1 then -- 确定
            local function responseMethod(tag, gameData)
                cclog("[血石赋能 - 拓印] 拓印结果")
                game_util:addMoveTips({ text = "In thành công"});
                self:back()
                self.rebornSucc()
            end
            local gemQuality = self.m_selectGem.cfg:getNodeWithKey("quality"):toInt()
            local costRebornStone = self.equip_gem_fate_stone[tostring(gemQuality - 3)]
            cclog2({gem_id = self.m_selectGem.id, stone_id = gemQuality - 3 }, "[血石赋能 - 拓印] 拓印")
            network.sendHttpRequest(responseMethod, game_url.getUrlForKey("gem_fate_transfer"), http_request_method.GET, {gem_id = self.m_selectGem.id, stone_id = gemQuality - 3 }, "gem_fate_transfer")
        
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

    local gemQuality = self.m_selectGem.cfg:getNodeWithKey("quality"):toInt()
    local costRebornStone = self.equip_gem_fate_stone[tostring(gemQuality - 3)]
    --lb_content
    local lb_content = self.m_ccbNode:labelTTFForName("lb_content")
    lb_content:setString(string.format("Xác nhận tiêu dùng %s để In Đá Quý không? Dòng chữ của Đá Vận Mệnh sẽ biến mất", costRebornStone.name_stone))


    return ccbNode
end

function game_bloodStone_reborn.refreshUi(self)
   
end


--[[--
    初始化
]]
function game_bloodStone_reborn.init(self, t_params)
    self.m_selectGem = t_params.m_selectGem
    self.rebornSucc = t_params.rebornSucc
    cclog2(self.m_selectGem, "[血石赋能 - 拓印] m_selectGem")
end
--[[--
    创建ui入口并初始化数据
]]
function game_bloodStone_reborn.create(self, t_params)
    cclog2(t_params, "[血石赋能 - 拓印] t_params")
    self:init(t_params)
    self.m_popUi = self:createUi()
    self:refreshUi()
    return self.m_popUi
end

--[[--
    回调方法
]]
function game_bloodStone_reborn.callBackFunc(self)
    local callBackFunc = self.callBackFunc
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc()
    end
end

return game_bloodStone_reborn
