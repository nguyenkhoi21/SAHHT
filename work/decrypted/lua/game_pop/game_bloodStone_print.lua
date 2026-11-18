-------------------- 血石赋能 点化

local game_bloodStone_print = {
    equip_gem_fate_skill = getConfig(game_config_field.equip_gem_fate_skill) and json.decode(getConfig(game_config_field.equip_gem_fate_skill):getFormatBuffer()) or {},
    equip_gem_fate_word = getConfig(game_config_field.equip_gem_fate_word) and json.decode(getConfig(game_config_field.equip_gem_fate_word):getFormatBuffer()) or {},
    m_tParams = nil,
    m_selectGem = nil,
    m_selectPrintStone = nil, -- 选择的点化石
}

function game_bloodStone_print.destroy(self)
    self.m_tParams = nil
    self.m_selectGem = nil
    self.m_selectPrintStone = nil
end

function game_bloodStone_print.back(self, type)
    game_scene:removePopByName("game_bloodStone_print")
    self:destroy()
end

function game_bloodStone_print.createUi(self)
    local ccbNode = luaCCBNode:create()
    local function onMainBtnClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if self.m_flag == true then
            return
        end

        cclog("[血石赋能 - 点化] 点击按钮 --> " .. btnTag)

        if btnTag == 99999 then
            self:back()
        elseif btnTag == 1 then -- 投入
            cclog("[血石赋能 - 点化] 点击投入")
            local itemOnClick = function (status, data)
                if status == "unload" then
                    self.m_selectPrintStone = nil
                end
                if status == "exchanged" then
                    self.m_selectPrintStone = data.id
                end
                self:refreshUi()
            end
            game_scene:addPop("game_select_bloodStone_pop",{itemOnClick = itemOnClick,sortBtnShow = false,openType = 2})
        elseif btnTag == 2 then -- 点化
            self:print()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_bloodStone_reveal.ccbi")

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

function game_bloodStone_print.print(self)
    if not self.m_selectPrintStone then
        game_util:addMoveTips({ text = "Hãy bỏ Đá In vào"});
        return
    end
    local function responseMethod(tag, gameData)
        game_util:addMoveTips({ text = "Điểm Hóa thành công"});
        local _gameData = json.decode(gameData:getFormatBuffer())
        local gem_oid
        if _gameData and _gameData.data and _gameData.data.gem_oid then
            gem_oid = _gameData.data.gem_oid
        end
        self.m_printSucc(gem_oid)
        self:back()
    end
    network.sendHttpRequest(responseMethod, game_url.getUrlForKey("gem_fate_printing"), http_request_method.GET, {gem_id = self.m_selectGem.id, word_id = self.m_selectPrintStone }, "gem_fate_printing")
end

function game_bloodStone_print.refreshUi(self)
    local gemQuality = self.m_selectGem.cfg:getNodeWithKey("quality"):toInt()
    local printStoneCfg
    local lack
    local maxSkillCfg
    local maxSkillId
    local success
    ------------------old
    local name = ""
    -- 图标
    local node_stoneIconOld = self.m_ccbNode:nodeForName("node_stoneIconOld")
    node_stoneIconOld:removeAllChildrenWithCleanup(true)
    local icon = game_util:createFateGemIconByCid(self.m_selectGem.id)
    node_stoneIconOld:addChild(icon)
    -- if self.m_selectGem.empowerData then
    --     local icon = game_util.bloodStone.createIcon(gemQuality, self.m_selectGem.empowerData.skill.sid)
    --     node_stoneIconOld:addChild(icon)
    -- end
    -- 名称
    if self.m_selectGem.empowerData then
        name = self.equip_gem_fate_skill[tostring(self.m_selectGem.empowerData.skill.sid)].name
        self.m_ccbNode:labelTTFForName("lb_energyNameOld"):setString(name)
    else
        self.m_ccbNode:labelTTFForName("lb_energyNameOld"):setString("Không có hiệu quả Ban Sức ")
    end
    -- 描述
    if self.m_selectGem.empowerData then
        local power_text = self.equip_gem_fate_skill[tostring(self.m_selectGem.empowerData.skill.sid)].power_text
        self.m_ccbNode:labelTTFForName("lb_energyDesOld"):setString(string.format(power_text, name))
    else
        self.m_ccbNode:labelTTFForName("lb_energyDesOld"):setString("")
    end
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
    -- 通过选中的点化石,在equip_gem_fate_word中找到对应的池子,然后筛选出池子中相同的skill sort,然后展示
    if self.m_selectPrintStone then
        printStoneCfg = self.equip_gem_fate_word[tostring(self.m_selectPrintStone)]
        lack = printStoneCfg['level' .. gemQuality .. "_lack"]
        for k, v in pairs(lack) do -- 取出同sort的最高id的技能
            if self.equip_gem_fate_skill[tostring(v[1])].skill_sort == printStoneCfg.sort then
                if not maxSkillId or maxSkillId < v[1] then
                    maxSkillCfg = self.equip_gem_fate_skill[tostring(v[1])]
                    maxSkillId = v[1]
                    success = v[2]
                end
            end
        end
    end
    -- 图标
    local node_stoneIconNew = self.m_ccbNode:nodeForName("node_stoneIconNew")
    node_stoneIconNew:removeAllChildrenWithCleanup(true)
    node_stoneIconNew:setVisible(self.m_selectPrintStone ~= nil)
    if self.m_selectPrintStone ~= nil then
        local icon = game_util.bloodStone.createIcon(gemQuality, maxSkillId)
        node_stoneIconNew:addChild(icon)
    end
    -- 名称
    local lb_energyNameNew = self.m_ccbNode:labelTTFForName("lb_energyNameNew")
    lb_energyNameNew:setVisible(self.m_selectPrintStone ~= nil)
    if lb_energyNameNew:isVisible() then
        name = self.equip_gem_fate_skill[tostring(maxSkillId)].name
        self.m_ccbNode:labelTTFForName("lb_energyNameNew"):setString(name)
    end
    -- 描述
    local lb_energyDesNew = self.m_ccbNode:labelTTFForName("lb_energyDesNew")
    lb_energyDesNew:setVisible(self.m_selectPrintStone ~= nil)
    if lb_energyDesNew:isVisible() then
        local power_text = self.equip_gem_fate_skill[tostring(maxSkillId)].power_text
        lb_energyDesNew:setString(string.format(power_text, name))
    end
    -- 将文本放入sc
    local sc_2 = self.m_ccbNode:scrollViewForName("sc_2")
    sc_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    local nd_sc2Container = self.m_ccbNode:nodeForName("nd_sc2Container")
    nd_sc2Container:removeFromParentAndCleanup(false)
    nd_sc2Container:setPosition(ccp(0, 0))
    local tempHeight = 3 + self.m_ccbNode:labelTTFForName("lb_energyNameNew"):getContentSize().height + self.m_ccbNode:labelTTFForName("lb_energyDesNew"):getContentSize().height + 20
    sc_2:setContentSize(CCSizeMake(sc_2:getViewSize().width, tempHeight))
    sc_2:setContentOffset(ccp(0, sc_2:getViewSize().height - tempHeight), false)
    sc_2:addChild(nd_sc2Container)
    self.m_ccbNode:labelTTFForName("lb_energyNameNew"):setPositionY(tempHeight - 9)
    self.m_ccbNode:labelTTFForName("lb_energyDesNew"):setPositionY(tempHeight - 17)
    ------------------中间
    local hasSelectPrint = self.m_selectPrintStone ~= nil
    local lb_success = self.m_ccbNode:labelTTFForName("lb_success")
    lb_success:setVisible(hasSelectPrint)
    local lb_success1 = self.m_ccbNode:labelTTFForName("lb_success1")
    lb_success1:setVisible(hasSelectPrint)
    local lb_success2 = self.m_ccbNode:labelTTFForName("lb_success2")
    lb_success2:setVisible(hasSelectPrint)
    local lb_success3 = self.m_ccbNode:labelTTFForName("lb_success3")
    lb_success3:setVisible(hasSelectPrint)
    local lb_success4 = self.m_ccbNode:labelTTFForName("lb_success4")
    lb_success4:setVisible(hasSelectPrint)
    if hasSelectPrint then
        local word_round = game_data.m_formationBloodStoneData.word_round
        local curRound = word_round[tostring(self.m_selectPrintStone)] or 0
        local minimum_name = printStoneCfg.minimum_name
        local maxTimes = 0
        for k, v in pairs(minimum_name) do
            if v[1] == gemQuality then
                maxTimes = v[2]             
            end
        end
        local succ = success + (curRound / maxTimes * (100 - success))
        if succ > 100 then succ = 100 end
        lb_success:setString(string.format("Tỉ lệ thành công %.2f%%", succ))
        local times = maxTimes - curRound
        if times < 0 then times = 0 end
        lb_success3:setString(string.format("Lần %s",times))

        lb_success1:setPosition(ccp(lb_success:getPositionX() + lb_success:getContentSize().width , lb_success:getPositionY()))
        lb_success3:setPosition(ccp(lb_success2:getPositionX() + lb_success2:getContentSize().width , lb_success2:getPositionY()))
        lb_success4:setPosition(ccp(lb_success3:getPositionX() + lb_success3:getContentSize().width , lb_success3:getPositionY()))
    end
    -- btn_1
    local btn_1 = self.m_ccbNode:controlButtonForName("btn_1")
    -- btn_1:setOpacity(hasSelectPrint and 0 or 255)
    -- sp_btnStatus
    local sp_btnStatus = self.m_ccbNode:spriteForName("sp_btnStatus")
    sp_btnStatus:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(hasSelectPrint and "tianjai_msz02.png" or "tianjai_msz01.png"));
    -- node_printIcon
    local node_printIcon = self.m_ccbNode:nodeForName("node_printIcon")
    node_printIcon:removeAllChildrenWithCleanup(true)
    if hasSelectPrint then
        local icon = game_util.bloodStonePrint.createIcon(self.m_selectPrintStone)
        icon:setScale(0.75)
        node_printIcon:addChild(icon)
    end

end


--[[--
    初始化
]]
function game_bloodStone_print.init(self, t_params)
    self.m_selectGem = t_params.m_selectGem
    self.m_printSucc = t_params.m_printSucc
end
--[[--
    创建ui入口并初始化数据
]]
function game_bloodStone_print.create(self, t_params)
    self:init(t_params)
    self.m_popUi = self:createUi()
    self:refreshUi()
    return self.m_popUi
end

--[[--
    回调方法
]]
function game_bloodStone_print.callBackFunc(self)
    local callBackFunc = self.callBackFunc
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc()
    end
end

return game_bloodStone_print
