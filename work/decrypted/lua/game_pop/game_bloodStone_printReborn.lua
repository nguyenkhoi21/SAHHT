-------------------- 血石赋能 点化

local game_bloodStone_printReborn = {
    equip_gem_fate_skill = getConfig(game_config_field.equip_gem_fate_skill) and json.decode(getConfig(game_config_field.equip_gem_fate_skill):getFormatBuffer()) or {},
    equip_gem_fate_stone = getConfig(game_config_field.equip_gem_fate_stone) and json.decode(getConfig(game_config_field.equip_gem_fate_stone):getFormatBuffer()) or {},
    m_tParams = nil,
    m_selectGem = nil,
    m_selectRebornStone = nil, -- 选择的点化石
}

function game_bloodStone_printReborn.destroy(self)
    self.m_tParams = nil
    self.m_selectGem = nil
    self.m_selectRebornStone = nil
end

function game_bloodStone_printReborn.back(self, type)
    game_scene:removePopByName("game_bloodStone_printReborn")
    self:destroy()
end

function game_bloodStone_printReborn.createUi(self)
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
        elseif btnTag == 1 then -- 投入
            cclog("[血石赋能 - 拓印] 点击投入")
            local itemOnClick = function (status, data)
                if status == "unload" then
                    self.m_selectRebornStone = nil
                end
                if status == "exchanged" then
                    self.m_selectRebornStone = data.id
                end
                self:refreshUi()
            end
            game_scene:addPop("game_select_bloodStoneReborn_pop",{itemOnClick = itemOnClick,sortBtnShow = false,openType = 2})
        elseif btnTag == 2 then -- 点化
            self:print()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_bloodStone_reborn.ccbi")

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

    ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    ccbNode:controlButtonForName("btn_1"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    ccbNode:controlButtonForName("btn_2"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)

    return ccbNode
end
--

function game_bloodStone_printReborn.print(self)
    if not self.m_selectRebornStone then
        game_util:addMoveTips({ text = "Hãy bỏ Đá Điểm Hóa vào"});
        return
    end
    local function responseMethod(tag, gameData)
        game_util:addMoveTips({ text = "In thành công"});
        self.rebornSucc()
        self:back()
    end
    network.sendHttpRequest(responseMethod, game_url.getUrlForKey("gem_fate_transfer"), http_request_method.GET, {gem_id = self.m_selectGem.id, stone_id = self.m_selectRebornStone }, "gem_fate_transfer")
end

function game_bloodStone_printReborn.refreshUi(self)
    local gemQuality = self.m_selectGem.cfg:getNodeWithKey("quality"):toInt()
    local costRebornStone = self.equip_gem_fate_stone[tostring(gemQuality - 3)]

    local name = self.equip_gem_fate_skill[tostring(self.m_selectGem.empowerData.skill.sid)].name
    local rebornCfg
    ------------------old
    -- 图标
    local node_stoneIconOld = self.m_ccbNode:nodeForName("node_stoneIconOld")
    node_stoneIconOld:removeAllChildrenWithCleanup(true)
    local icon = game_util:createFateGemIconByCid(self.m_selectGem.id)
    node_stoneIconOld:addChild(icon)
    -- 名称
    self.m_ccbNode:labelTTFForName("lb_energyNameOld"):setString(name)
    -- 描述
    local power_text = self.equip_gem_fate_skill[tostring(self.m_selectGem.empowerData.skill.sid)].power_text
    self.m_ccbNode:labelTTFForName("lb_energyDesOld"):setString(string.format(power_text, name))
    -- 将文本放入sc
    -- 将文本放入sc
    local sc_1 = self.m_ccbNode:scrollViewForName("sc_1")
    local nd_sc1Container = self.m_ccbNode:nodeForName("nd_sc1Container")
    nd_sc1Container:removeFromParentAndCleanup(false)
    nd_sc1Container:setPosition(ccp(0, 0))
    local tempHeight = 3 + self.m_ccbNode:labelTTFForName("lb_energyNameOld"):getContentSize().height + self.m_ccbNode:labelTTFForName("lb_energyDesOld"):getContentSize().height + 20
    sc_1:setContentSize(CCSizeMake(sc_1:getViewSize().width, tempHeight))
    sc_1:setContentOffset(ccp(0, sc_1:getViewSize().height - tempHeight), false)
    sc_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    sc_1:addChild(nd_sc1Container)
    self.m_ccbNode:labelTTFForName("lb_energyNameOld"):setPositionY(tempHeight - 9)
    self.m_ccbNode:labelTTFForName("lb_energyDesOld"):setPositionY(tempHeight - 17)
    ------------------new
    -- 图标
    local node_stoneIconNew = self.m_ccbNode:nodeForName("node_stoneIconNew")
    node_stoneIconNew:removeAllChildrenWithCleanup(true)
    local icon = game_util:createFateGemIconByCid(self.m_selectGem.c_id)
    node_stoneIconNew:addChild(icon)
    ------------中间
    local hasSelectPrint = self.m_selectRebornStone ~= nil
    -- sp_btnStatus
    local sp_btnStatus = self.m_ccbNode:spriteForName("sp_btnStatus")
    sp_btnStatus:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(hasSelectPrint and "tianjai_msz02.png" or "tianjai_msz03.png"));
    -- node_printIcon
    local node_printIcon = self.m_ccbNode:nodeForName("node_printIcon")
    node_printIcon:removeAllChildrenWithCleanup(true)
    if hasSelectPrint then
        local icon = game_util.bloodStoneReborn.createIcon(self.m_selectRebornStone)
        icon:setScale(0.75)
        node_printIcon:addChild(icon)
    end
    -- lb_rebornNotice
    local lb_rebornNotice = self.m_ccbNode:labelTTFForName("lb_rebornNotice")
    lb_rebornNotice:setVisible(hasSelectPrint)
end


--[[--
    初始化
]]
function game_bloodStone_printReborn.init(self, t_params)
    self.m_selectGem = t_params.m_selectGem
    self.rebornSucc = t_params.rebornSucc
end
--[[--
    创建ui入口并初始化数据
]]
function game_bloodStone_printReborn.create(self, t_params)
    self:init(t_params)
    self.m_popUi = self:createUi()
    self:refreshUi()
    return self.m_popUi
end

--[[--
    回调方法
]]
function game_bloodStone_printReborn.callBackFunc(self)
    local callBackFunc = self.callBackFunc
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc()
    end
end

return game_bloodStone_printReborn
