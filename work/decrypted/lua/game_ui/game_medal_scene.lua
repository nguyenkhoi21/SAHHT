---  勋章界面

local game_medal_scene = {
    formationId = nil,
    node_attr_list = nil,
    medal_icon = nil,
    m_ccbNode = nil,
    m_buy_btn = nil,
    m_anim_node = nil,
    m_name_label = nil,
    m_race_label = nil,
    m_life_label = nil,
    m_physical_atk_label = nil,
    m_magic_atk_label = nil,
    m_def_label = nil,
    m_speed_label = nil,
    m_life_label2 = nil,
    m_physical_atk_label2 = nil,
    m_magic_atk_label2 = nil,
    m_def_label2 = nil,
    m_speed_label2 = nil,
    node_intro_msg_board = nil,
    node_skill_list = nil,
    m_occupation_icon = nil,
    m_combatNumberChangeNode = nil,
    heroId = nil,
    backMedalPos = nil,
    m_selcet_index = nil,
    posIndex = nil,
    formationId = nil,
    changeFlag = nil,
    m_tempCombatValue = nil,
    m_combatNumberChangeNode = nil,
    backMedalData = nil,
};
--[[--
    销毁ui
]]
function game_medal_scene.destroy(self)
    -- body
    cclog("-----------------game_medal_scene destroy-----------------");

    self.formationId = nil;
    self.node_attr_list = nil;
    self.medal_icon = nil;
    self.m_ccbNode = nil;
    self.m_buy_btn = nil;
    self.m_anim_node = nil;
    self.m_name_label = nil;
    self.m_race_label = nil;
    self.m_life_label = nil;
    self.m_physical_atk_label = nil;
    self.m_magic_atk_label = nil;
    self.m_def_label = nil;
    self.m_speed_label = nil;
    self.m_life_label2 = nil;
    self.m_physical_atk_label2 = nil;
    self.m_magic_atk_label2 = nil;
    self.m_def_label2 = nil;
    self.m_speed_label2 = nil;
    self.node_intro_msg_board = nil;
    self.node_skill_list = nil;
    self.m_occupation_icon = nil;
    self.m_combatNumberChangeNode = nil; 
    self.heroId = nil;
    self.backMedalPos = nil;
    self.m_selcet_index = nil;
    self.posIndex = nil;
    self.formationId = nil;
    self.changeFlag = nil;
    self.m_tempCombatValue = nil;
    self.m_combatNumberChangeNode = nil;
    self.backMedalData = nil;
end

--[[--
    返回
]]
function game_medal_scene.back(self,backType)
    game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_main_scene",changeFlag = self.changeFlag});
end
--[[
    一键装备
]]
function game_medal_scene.quickEquip(self)
    local medalPosData = game_data:getMedalPos()
    local itemMedalData = nil
    if self.formationId > self.posIndex then
        itemMedalData = medalPosData[tostring(self.posIndex - 1)]
    else
        itemMedalData = medalPosData[tostring(self.posIndex - 2)]
    end
    local positionCfg = getConfig(game_config_field.position)

    local heroData,heroCfg = game_data:getCardDataById(self.heroId)
    local evoLevel = heroData.evo

    local medalList = game_data:getMedalData()
    -- cclog2(medalList,"medalList")
    local medalKey = {}
    for k,v in pairs(medalList) do
        table.insert(medalKey,k)
    end
    local function sortFunc(idOne,idTwo)
        return idOne > idTwo
    end
    table.sort(medalKey,sortFunc)
    -- cclog2(medalKey,"medalKey")
    -- cclog2(medalKey)
        -- cclog2(medalKey)
    local function getOneMedal()
        for i=1,#medalKey do
            local key = medalKey[i] 
            if not game_util:idInTableById(key,itemMedalData) then
                return key
            end
        end
        return "0"
    end
    --直接一键换上最好的勋章
    for i=1,6 do
        local itemOpenCfg = positionCfg:getNodeWithKey(tostring(i))
        local adv_level = itemOpenCfg:getNodeWithKey("adv_level"):toInt()
        if evoLevel >= adv_level then--已开启的
            -- if medalKey[i] then
                local key = getOneMedal()
                cclog2(key,"key")
                if key and key ~= "0" then
                    if itemMedalData[i] == "0" then--为0的，直接换上
                        cclog2(key,"key ==========0")
                        itemMedalData[i] = key
                        self.changeFlag = true
                    else
                        cclog2(key,"key !!!!!!!!!!============0")
                        local medalCfg = getConfig(game_config_field.medal);
                        local itemMedalCfg = medalCfg:getNodeWithKey(itemMedalData[i])
                        local tempMedalCfg = medalCfg:getNodeWithKey(key)
                        local itemQuality = itemMedalCfg:getNodeWithKey("quality"):toInt()
                        local tempQuality = tempMedalCfg:getNodeWithKey("quality"):toInt()
                        if tempQuality > itemQuality then
                            itemMedalData[i] = key
                            self.changeFlag = true
                        end
                    end
                end
            -- end
        end
    end
    --直接一键换上最好的勋章
    -- for i=1,6 do
    --     local itemOpenCfg = positionCfg:getNodeWithKey(tostring(i))
    --     local adv_level = itemOpenCfg:getNodeWithKey("adv_level"):toInt()
    --     if evoLevel >= adv_level then--已开启的
    --         if medalKey[i] then
    --             cclog2(medalKey[i],"medalKey[i]")
    --             itemMedalData[i] = medalKey[i]
    --             self.changeFlag = true
    --         else
    --             itemMedalData[i] = "0"
    --         end
    --     end
    -- end
    self:refreshMedalData()
    self:refreshUi()
end

--[[--
    读取ccbi创建ui
]]
function game_medal_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then 
            -- game_scene:enterGameUi("game_main_scene");
            self:back()
        elseif btnTag == 103 then   -- 查看勋章
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_medal_list",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_index"), http_request_method.GET, nil,"medal_index")
        elseif btnTag == 104 then   -- 一键装备
            self:quickEquip()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_medal_scene_main.ccbi");
    self.m_ccbNode = ccbNode

    self.node_attr_list = ccbNode:nodeForName("node_attr_list")

    self.medal_icon = {}
    for i=1,6 do
        self.medal_icon[i] = ccbNode:spriteForName("medal_icon" .. i)
    end
    self.m_look_btn = ccbNode:controlButtonForName("m_look_btn")
    self.m_look_btn:setVisible(false)
    ---------------------       玩家信息  食物 战力           -------------------
    local m_combat_node = ccbNode:nodeForName("m_combat_node")                   -- 战斗力底板
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_name_label = ccbNode:labelTTFForName("m_name_label")
    self.m_race_label = ccbNode:labelTTFForName("m_race_label")
    --属性
    self.m_life_label = ccbNode:labelBMFontForName("m_life_label")
    self.m_physical_atk_label = ccbNode:labelBMFontForName("m_physical_atk_label")
    self.m_magic_atk_label = ccbNode:labelBMFontForName("m_magic_atk_label")
    self.m_def_label = ccbNode:labelBMFontForName("m_def_label")
    self.m_speed_label = ccbNode:labelBMFontForName("m_speed_label")
    self.m_life_label2 = ccbNode:labelBMFontForName("m_life_label2")
    self.m_physical_atk_label2 = ccbNode:labelBMFontForName("m_physical_atk_label2")
    self.m_magic_atk_label2 = ccbNode:labelBMFontForName("m_magic_atk_label2")
    self.m_def_label2 = ccbNode:labelBMFontForName("m_def_label2")
    self.m_speed_label2 = ccbNode:labelBMFontForName("m_speed_label2")

    self.node_intro_msg_board = ccbNode:nodeForName("node_intro_msg_board")   -- 描述版
    self.node_skill_list = ccbNode:nodeForName("node_skill_list")   -- 技能版
    self.m_occupation_icon = ccbNode:spriteForName("m_occupation_icon")

    ---------------------       初始化战斗力显示node        --------------
    self.m_combatNumberChangeNode = game_util:createExtNumberChangeNode({labelType = 2});
    self.m_combatNumberChangeNode:setAnchorPoint(ccp(0, 0.5));
    -- self.m_combatNumberChangeNode:setScale(0.75);
    m_combat_node:addChild(self.m_combatNumberChangeNode);
    self.m_combatNumberChangeNode:setCurValue(0,false);
    
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    m_root_layer:setTouchEnabled(false);
    return ccbNode;
end

--[[
    人物属性
]]
function game_medal_scene.createHeroProperty(self)
    local cardData,cardCfg = nil,nil;
    local cardData,cardCfg = game_data:getCardDataById(self.heroId)
    local attrValueTab = {0,0,0,0,0};
    if cardData and cardCfg then
        self.m_life_label:setString(cardData.hp);
        self.m_physical_atk_label:setString(cardData.patk);
        self.m_magic_atk_label:setString(cardData.matk);
        self.m_def_label:setString(cardData.def);
        self.m_speed_label:setString(cardData.speed);
        -- 1物攻 2魔攻 3防御 4速度 5生命
        -- local equipAttrValueTab = self:getPosEquipAttrValue(posIndex);--装备属性
        -- local petAttrValueTab = game_util:getPetCombatValue(posIndex)
        -- local gemAttrValueTab = {0,0,0,0,0};
        -- local attrValueTab2 = {0,0,0,0,0};
        -- local attrValueTab3 = {0,0,0,0,0};
        -- if self.m_teamIndex == 1 then
        --     gemAttrValueTab = self:getGemBaseAttrValue(posIndex);--宝石的基本属性
        --     attrValueTab2 = game_util:getCommanderCombatValue();--统帅能力
        --     attrValueTab3 = game_util:getAssistantCombatValue();--助威加的属性
        -- end
        -- local cbmTab = game_util:getCombatBonusMultiplierByCfg(cardCfg,cardData.id);--连协属性
        -- for i=1,5 do
        --     local abilityItem = PUBLIC_ABILITY_TABLE["ability_" .. i] or {}
        --     local attrValue = cardData[abilityItem.attrName or ""] or 0
        --     attrValueTab[i] = math.floor(equipAttrValueTab[i] + attrValueTab2[i] + attrValue*cbmTab[i] + gemAttrValueTab[i] + attrValueTab3[i] + petAttrValueTab[i])
        -- end
        -- self.m_life_label2:setString("+" .. attrValueTab[5])
        -- self.m_physical_atk_label2:setString("+" .. attrValueTab[1])
        -- self.m_magic_atk_label2:setString("+" .. attrValueTab[2])
        -- self.m_def_label2:setString("+" .. attrValueTab[3])
        -- self.m_speed_label2:setString("+" .. attrValueTab[4])
    else
        self.m_life_label:setString("---");
        self.m_physical_atk_label:setString("---");
        self.m_magic_atk_label:setString("---");
        self.m_def_label:setString("---");
        self.m_speed_label:setString("---");
        self.m_life_label2:setString("---");
        self.m_physical_atk_label2:setString("---");
        self.m_magic_atk_label2:setString("---");
        self.m_def_label2:setString("---");
        self.m_speed_label2:setString("---");
    end
end
--[[--
    显示技能信息
]]
function game_medal_scene.showSkillInfo( self, roleIndex, index )
    -- local cardData,cardCfg = self:getCardDataByPos(roleIndex)
    local cardData,cardCfg = game_data:getCardDataById(self.heroId)
    cclog2(cardData.c_id,"cardData")
    local skill = cardData["s_" .. index]
    game_scene:addPop("skills_activation_pop",{skillData = skill, selHeroId=cardData.id ,posIndex = index}) 
end

--[[
    人物技能 
]]
function game_medal_scene.createHeroSkills(self)
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag  ===  ", btnTag)
        local roleIndex = 1
        local index = btnTag - 1000
        self:showSkillInfo( roleIndex, index)
    end

    local cardData,cardCfg = game_data:getCardDataById(self.heroId)
    for i=1,3 do
        local skill = cardData["s_" .. i]
        local m_skill_icon_bg = self.node_skill_list:getChildByTag(10 + i)
        local tempSize = m_skill_icon_bg:getContentSize();
        local aminFlag = true;
        if skill then
            local tempIcon = game_util:createSkillIconByCid(skill.s, skill.avail)
            if tempIcon then
                tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
                m_skill_icon_bg:addChild(tempIcon);
                self:createTouchButton(onBtnCilck, tempIcon, 1000 + i)
            end
        end
    end
end
--[[
    人物勋章
]]
function game_medal_scene.createMedalInfo(self)
    --取之前的勋章数据
    local medalPosData = game_data:getMedalPos()
    local itemMedalData = nil
    if self.formationId > self.posIndex then
        itemMedalData = medalPosData[tostring(self.posIndex - 1)]
    else
        itemMedalData = medalPosData[tostring(self.posIndex - 2)]
    end
    local positionCfg = getConfig(game_config_field.position)
    local heroData,heroCfg = game_data:getCardDataById(self.heroId)
    -- cclog2(heroData,"heroData")
    local evoLevel = heroData.evo

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag  ===  ", btnTag)
        local index = btnTag - 10000
        
        local callBackFunc = function (typeName,id)
            cclog2(id,"id")
            if typeName == "unload" then
                self.m_selcet_index = nil
                if itemMedalData[index] ~= "0" then
                    itemMedalData[index] = "0"
                    -- game_data:setMedalPos(medalPosData)
                    self.changeFlag = true
                    cclog("unload  true")
                end
            elseif typeName == "exchange" then
                self.m_selcet_index = index
                if itemMedalData[index] ~= tostring(id) then
                    self.changeFlag = true
                    itemMedalData[index] = id
                    -- game_data:setMedalPos(medalPosData)
                    cclog("exchange  true")
                end
            end
            self:refreshMedalData()
            -- self:createMedalInfo()
            self:refreshUi()
        end
        local function responseMethod(tag,gameData)
            -- game_scene:addPop("game_medal_select_pop",{gameData = gameData,medalPos = index,callBackFunc = callBackFunc,itemMedalData = itemMedalData});
            game_scene:addPop("game_medal_select_pop",{gameData = nil,medalPos = index,callBackFunc = callBackFunc,itemMedalData = itemMedalData});
        end
        function sendChangeMedal()
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_index"), http_request_method.GET, nil,"medal_index")
            responseMethod()
        end
        
        if itemMedalData[index] == "0" then--如果上面没有勋章，直接显示
            sendChangeMedal()
        elseif self.m_selcet_index ~= index then--先选中显示，再点击再可换
            self.m_selcet_index = index
            self:createMedalInfo()
        elseif self.m_selcet_index == index then
            sendChangeMedal()
        end
    end

    local medalCfg = getConfig(game_config_field.medal);
    for i=1,6 do
        self.medal_icon[i]:removeAllChildrenWithCleanup(true)
        local tempSize = self.medal_icon[i]:getContentSize()
        --首先判断开启，是否有勋章，然后判断加框        
        local itemOpenCfg = positionCfg:getNodeWithKey(tostring(i))
        local adv_level = itemOpenCfg:getNodeWithKey("adv_level"):toInt()
        if evoLevel >= adv_level then--已开启的
            self:createTouchButton(onBtnCilck, self.medal_icon[i], 10000 + i)

            local openSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("medal_medal_back1.png")
            if openSpriteFrame then
                self.medal_icon[i]:setDisplayFrame(openSpriteFrame)
            end

            --这里判断是否装备了，没装备的提示
            if itemMedalData[i] == "0" then
                local tipsLabel = game_util:createLabelTTF({text = "Nhấp đeo",color = ccc3(250,250,0)})
                tipsLabel:setPosition(ccp(25,10))
                self.medal_icon[i]:addChild(tipsLabel,10)
            else--已装备了勋章
                -- cclog2(itemMedalData[i],"itemMedalData[i]")
                local itemCfg = medalCfg:getNodeWithKey(itemMedalData[i]);
                local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr())
                icon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                self.medal_icon[i]:addChild(icon,10)
            end
            if self.m_selcet_index == i then--加选择框
                local selectSprite = CCSprite:createWithSpriteFrameName("medal_medal_select.png")
                selectSprite:setAnchorPoint(ccp(0.5,0.5))
                selectSprite:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                self.medal_icon[i]:addChild(selectSprite,100)
            end
        else--未开启的
            local closeSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("medal_medal_back2.png")
            if closeSpriteFrame then
                self.medal_icon[i]:setDisplayFrame(closeSpriteFrame)
            end
            local tipsLabel = game_util:createLabelTTF({text = "Tiến cấp +" .. adv_level .. "\nmở",color = ccc3(188,189,191)})
            tipsLabel:setDimensions(CCSizeMake(50,28))
            tipsLabel:setPosition(ccp(25,20))
            self.medal_icon[i]:addChild(tipsLabel,10)
            --未开启的给屏蔽掉
            if itemMedalData and itemMedalData[i] ~= "0" then
                --并且把该勋章放回勋章背包里
                local medalData = game_data:getMedalData()
                local count = medalData[tostring(itemMedalData[i])] or 0
                medalData[tostring(itemMedalData[i])] = count + 1

                itemMedalData[i] = "0"
                self.changeFlag = true
            end
        end
    end

    --勋章信息
    self.node_intro_msg_board:removeAllChildrenWithCleanup(true)
    if self.m_selcet_index then
        if itemMedalData[self.m_selcet_index] ~= "0" then
            local itemCfg = medalCfg:getNodeWithKey(itemMedalData[self.m_selcet_index])
            local name = itemCfg:getNodeWithKey("name"):toStr()
            local medalNameLabel = game_util:createLabelTTF({text = name,color = ccc3(254,212,11)})
            medalNameLabel:setPosition(ccp(10,60))
            medalNameLabel:setAnchorPoint(ccp(0,0.5))
            self.node_intro_msg_board:addChild(medalNameLabel)

            --属性
            local effect = itemCfg:getNodeWithKey("effect")
            for i=1,3 do
                local itemEffect = effect:getNodeAt(i-1)
                local ability = itemEffect:getNodeAt(0):toInt()
                local value = itemEffect:getNodeAt(1):toInt()

                local abilityItem = PUBLIC_ABILITY_TABLE["ability_" .. ability]
                local abilityLabel = game_util:createLabelTTF({text = abilityItem.name .. "+" .. value})
                if ability > 0 and ability < 6 then
                    abilityLabel:setColor(ccc3(31,231,13))
                else
                    abilityLabel:setColor(ccc3(245,0,10))
                end
                abilityLabel:setPosition(ccp(70,80 - i * 20))
                abilityLabel:setAnchorPoint(ccp(0,0.5))
                self.node_intro_msg_board:addChild(abilityLabel)
            end
        end
    end
end
--[[--
    刷新卡牌信息
]]
function game_medal_scene.refreshHeroInfo(self)
    --人物属性
    self:createHeroProperty()
    --人物技能
    self:createHeroSkills()
    --人物动画
    self:createCardAnimByData()
    --穿戴的勋章
    self:createMedalInfo()
end

--[[--
    刷新战斗力
]]
function game_medal_scene.refreshCombatLabel(self)
    if self.m_tempCombatValue == nil then
        self.m_tempCombatValue = game_util:getCombatValue()
        self.m_combatNumberChangeNode:setCurValue(self.m_tempCombatValue,false);
    else
        local tempCombatValue = game_util:getCombatValue();
        local changeValue = tempCombatValue - self.m_tempCombatValue
        self.m_tempCombatValue = tempCombatValue;
        game_util:combatChangedValueAnim({combatNode = self.m_combatNumberChangeNode,currentValue = tempCombatValue,changeValue = changeValue});
    end
end

--[[
    获取小伙伴位置上的动画
]]
function game_medal_scene.createCardAnimByData(self)
    local animNode = nil;
    local heroData,heroCfg = game_data:getCardDataById(self.heroId)
    self.m_anim_node:removeAllChildrenWithCleanup(true)
    if heroData and heroCfg then
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        animNode = game_util:createIdelAnim(ainmFile,0,heroData,heroCfg);
        if animNode then
            local itemSize = animNode:getContentSize();
            animNode:setAnchorPoint(ccp(0.5,0));
            animNode:setRhythm(1);
            animNode:setScale(1.1)
            self.m_anim_node:addChild(animNode);
        end

        local name_after = game_util:getCardName(heroData,heroCfg)
        self.m_name_label:setString(name_after);

        local occupation_cfg = getConfig(game_config_field.occupation);
        local occupation_item_cfg = occupation_cfg:getNodeWithKey(ainmFile)
        if occupation_item_cfg then
            local occupationType = occupation_item_cfg:toInt();
            local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupationType .. ".png")
            if spriteFrame then
                self.m_occupation_icon:setDisplayFrame(spriteFrame)
            end
        end
        local race_cfg = getConfig(game_config_field.race);
        local race_item_cfg = race_cfg:getNodeWithKey(heroCfg:getNodeWithKey("race"):toStr());
        if race_item_cfg then
            self.m_race_label:setString(race_item_cfg:getNodeWithKey("name"):toStr());
        else
            self.m_race_label:setString("Vô chủng tộc");
        end
    end
end

--[[--
    创建一个接受触摸事件的button
]]
function game_medal_scene.createTouchButton( self, fun, parent, tag , anchorX, anchorY)
    if not parent then return end
    local button = game_util:createCCControlButton("public_weapon.png","",fun)
    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
    local tempSize = parent:getContentSize()
    button:setAnchorPoint(ccp(0.5,0.5))
    button:setPosition(ccp(tempSize.width * (anchorX or 0.5), tempSize.height* (anchorY or 0.5)))
    button:setOpacity(0)
    parent:addChild(button)
    button:setTag(tag)
end

--[[--
    刷新ui
]]
function game_medal_scene.refreshUi(self)
    --刷新战斗力
    self:refreshCombatLabel()
    --刷新人物信息
    self:refreshHeroInfo()
end
--[[
    刷新勋章数据
]]
function game_medal_scene.refreshMedalData(self)
    local tempPos = game_data:getMedalPos()

    local tempMedal = game_data:getMedalData()

    --总共的减去装备的就是剩余的
    local totalMedal = util.table_copy(self.backMedalData)
    for i=1,10 do
        local itemBackMosData = self.backMedalPos[tostring(i-1)]
        for j=1,6 do
            local medalKey = itemBackMosData[j]
            if medalKey ~= "0" then
                if totalMedal[tostring(medalKey)] then
                    totalMedal[tostring(medalKey)] = totalMedal[tostring(medalKey)] + 1
                else
                    totalMedal[tostring(medalKey)] = 1
                end
            end
        end
    end
    -- cclog2(totalMedal,"totalMedal")
    -- cclog2(self.backMedalData,"self.backMedalData")
    -- cclog2(tempMedal,"tempMedal")
    
    local newMedal = util.table_copy(totalMedal)
    for i=1,10 do
        local itemPosData = tempPos[tostring(i-1)]
        for j=1,6 do
            local medalKey = itemPosData[j]
            if medalKey ~= "0" then
                if newMedal[tostring(medalKey)] then
                    newMedal[tostring(medalKey)] = newMedal[tostring(medalKey)] - 1
                end
            end
            if newMedal[tostring(medalKey)] == 0 then--数量已为0的，移除key
                newMedal[tostring(medalKey)] = nil
            end
        end
    end
    -- cclog2(newMedal,"newMedal")
    game_data:setMedalData(newMedal)
    self.backMedalPos = util.table_copy(game_data:getMedalPos())
    self.backMedalData = util.table_copy(game_data:getMedalData())
end

--[[--
    初始化
]]
function game_medal_scene.init(self,t_params)
    t_params = t_params or {};
    self.heroId = t_params.heroId
    self.m_selcet_index = 1
    --根据阵型和选择的第几个来判断取第几个数据，formationId > index ，没有变化，如果formationId < index 则取的index - 1 个数据
    self.posIndex = t_params.posIndex -- 选择的第几个
    self.formationId = t_params.formationId -- 阵型
    self.changeFlag = t_params.changeFlag or false--是否改变了勋章位置

    --先取备份的勋章和勋章位置数据，然后在比较哪些上了哪些下了
    local tempPos = game_data:getMedalPos()
    self.backMedalPos = util.table_copy(tempPos)
    local tempMedal = game_data:getMedalData()
    self.backMedalData = util.table_copy(tempMedal)
end

--[[--
    创建ui入口并初始化数据
]]
function game_medal_scene.create(self,t_params)
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end

return game_medal_scene;
