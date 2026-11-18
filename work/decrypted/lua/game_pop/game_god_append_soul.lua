-- 附魂界面

local game_god_append_soul = {
    formationId = nil,
    node_attr_list = nil,
    soul_icon = nil,
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
    backSoulPos = nil,
    m_selcet_index = nil,
    posIndex = nil,
    formationId = nil,
    changeFlag = nil,
    m_tempCombatValue = nil,
    m_combatNumberChangeNode = nil,
    backSoulData = nil,
    attrValueTab =nil,
    soul_sort = {},
    m_openType = {},
    team_index = {},
    m_tGameData = {},
    m_callFunc = nil,
    m_gemData=nil,
};
--[[--
    销毁ui
]]
function game_god_append_soul.destroy(self)
    -- body
    cclog("-----------------game_god_append_soul destroy-----------------");

    self.formationId = nil;
    self.node_attr_list = nil;
    self.soul_icon = nil;
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
    self.backSoulPos = nil;
    self.m_selcet_index = nil;
    self.posIndex = nil;
    self.formationId = nil;
    self.changeFlag = nil;
    self.m_tempCombatValue = nil;
    self.m_combatNumberChangeNode = nil;
    self.backSoulData = nil;
    self.attrValueTab =nil;
    self.m_openType = nil;
    self.team_index = nil;
    self.m_tGameData = nil;
    self.m_callFunc = nil;
    self.m_gemData=nil;
    -- self.soul_sort = {};
end

--[[--
    返回
]]
function game_god_append_soul.back(self,backType)
    if self.m_openType == "game_god_adjustment" then
        if self.m_callFunc and type(self.m_callFunc) == "function" then
            self.m_callFunc(self.changeFlag);
        end
        game_scene:removePopByName("game_god_append_soul");
        self:destroy()
        -- game_scene:enterGameUi("game_god_adjustment",{gameData = self.m_tGameData,changeFlag = self.changeFlag,team_index = self.team_index});
           
    else
        game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_main_scene",changeFlag = self.changeFlag});
    end
end
--[[
    一键装备
]]
function game_god_append_soul.quickEquip(self)
   
end

--[[--
    读取ccbi创建ui
]]
function game_god_append_soul.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then 
            -- game_scene:enterGameUi("game_main_scene");
            self:back()
        elseif btnTag == 103 then   -- 查看英魂
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_soul_list",{gameData = gameData});
                self:destroy();
             end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_all_soul"), http_request_method.GET, nil,"soul_index")   
        elseif btnTag == 104 then   -- 一键装备
            self:quickEquip()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_soul_scene_main.ccbi");
    self.m_ccbNode = ccbNode
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())

    self.node_attr_list = ccbNode:nodeForName("node_attr_list")

    self.soul_icon = {}
    for i=1,6 do
        self.soul_icon[i] = ccbNode:spriteForName("soul_icon" .. i)
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
    local m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);
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
function game_god_append_soul.createHeroProperty(self)
    local cardData,cardCfg = nil,nil;
    local cardData,cardCfg = game_data:getCardDataById(self.heroId)
    self.attrValueTab = {0,0,0,0,0};

    -- cclog2(cardData,"cardData==")
    if cardData and cardCfg then
        self.m_life_label:setString(cardData.hp);
        self.m_physical_atk_label:setString(cardData.patk);
        self.m_magic_atk_label:setString(cardData.matk);
        self.m_def_label:setString(cardData.def);
        self.m_speed_label:setString(cardData.speed);
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
function game_god_append_soul.showSkillInfo( self, roleIndex, index )
    -- local cardData,cardCfg = self:getCardDataByPos(roleIndex)
    local cardData,cardCfg = game_data:getCardDataById(self.heroId)
    -- cclog2(cardData.c_id,"cardData")
    local skill = cardData["s_" .. index]
    game_scene:addPop("skills_activation_pop",{skillData = skill, selHeroId=cardData.id ,posIndex = index}) 
end

--[[
    人物技能 
]]
function game_god_append_soul.createHeroSkills(self)
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
    人物英魂
]]
function game_god_append_soul.createSoulInfo(self)
    local soulAllPosData = game_data:getAllGodSoulPosData();
    local soulPosData = soulAllPosData[tonumber(self.team_index)];
    local itemSoulData = nil
    if self.formationId > self.posIndex then
        itemSoulData = soulPosData[tostring(self.posIndex - 1)]
    else
        itemSoulData = soulPosData[tostring(self.posIndex - 1)]
    end
    local positionCfg = getConfig(game_config_field.position)
    local heroData,heroCfg = game_data:getCardDataById(self.heroId)
    local evoLevel = heroData.evo

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local index = btnTag - 10000
        
        local callBackFunc = function (typeName,id)
            if typeName == "unload" then
                self.m_selcet_index = nil
                if itemSoulData[index] ~= "0" then
                    itemSoulData[index] = "0"
                    -- cclog2(soulPosData,"soulPosDataunloadunload")
                    -- game_data:setOneGodSoulPosData(soulPosData,self.team_index)
                    self.changeFlag = true
                    self:refreshCombatLabel()
                    cclog("unload  true")
                end
            elseif typeName == "exchange" then
                self.m_selcet_index = index
                if itemSoulData[index] ~= tostring(id) then
                    self.changeFlag = true
                    -- cclog2(id,"id")
                    itemSoulData[index] = id
                    self:refreshCombatLabel()
                    -- cclog2(soulPosData,"soulPosDataexchangeexchangeexchange")
                    -- game_data:setOneGodSoulPosData(soulPosData,self.team_index)
                    cclog("exchange  true")
                end
            end
            -- self:refreshSoulData()
            -- self:createMedalInfo()
            self:refreshUi()
        end
        -- local function responseMethod(tag,gameData)
        -- end
        function sendChangeSoul(changeType)--1 是上，2是换
            game_scene:addPop("game_soul_select_pop",{gameData = nil,soulPos = index,callBackFunc = callBackFunc,itemSoulData = itemSoulData,changeType = changeType,flag = true});
            -- responseMethod()
        end
        
        if itemSoulData[index] == "0" then--如果上面没有英魂，直接显示
            sendChangeSoul(1)
        elseif self.m_selcet_index ~= index then--先选中显示，再点击再可换
            self.m_selcet_index = index
            self:createSoulInfo()
        elseif self.m_selcet_index == index then
            sendChangeSoul(2)
        end
    end
    -- cclog2(self.backSoulData,"self.backSoulData===============")
    local soulCfg = getConfig(game_config_field.soul_detail);
    local souldata2 = game_data:getSoulData()
    for i=1,6 do
        self.soul_icon[i]:removeAllChildrenWithCleanup(true)
        local tempSize = self.soul_icon[i]:getContentSize()
        --首先判断开启，是否有勋章，然后判断加框        
        local itemOpenCfg = positionCfg:getNodeWithKey(tostring(i))
        local adv_level = itemOpenCfg:getNodeWithKey("adv_level"):toInt()
        if evoLevel >= adv_level then--已开启的
            self:createTouchButton(onBtnCilck, self.soul_icon[i], 10000 + i)

            local openSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("medal_medal_back1.png")
            if openSpriteFrame then
                self.soul_icon[i]:setDisplayFrame(openSpriteFrame)
            end
            --这里判断是否装备了，没装备的提示
            -- cclog2(itemSoulData,"self.itemSoulData")
            if itemSoulData[i] == "0" then
                local tipsLabel = game_util:createLabelTTF({text = "Nhấp để mặc",color = ccc3(250,250,0)})
                tipsLabel:setPosition(ccp(25,10))
                self.soul_icon[i]:addChild(tipsLabel,10)
            else--已装备了英魂
                -- cclog2(i,"i")
                local id = itemSoulData[i]
                local s_id = souldata2[id].s_id
                local itemCfg = soulCfg:getNodeWithKey(tostring(s_id));
                -- cclog2(self.soul_sort,"self.soul_sort====")
                -- self.soul_sort[#self.soul_sort] = itemCfg:getNodeWithKey("sort"):toInt()
                local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr())
                icon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                self.soul_icon[i]:addChild(icon,10)
                --加名字和等级
                local levelLabel = game_util:createLabelTTF({text = "lv. " .. souldata2[id].lv,color = ccc3(0,250,0)})
                levelLabel:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.1))
                self.soul_icon[i]:addChild(levelLabel,10)

                -- local nameLabel = game_util:createLabelTTF({text = itemCfg:getNodeWithKey("name"):toStr()})
                -- nameLabel:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.8))
                -- self.soul_icon[i]:addChild(nameLabel,10)
            end
            if self.m_selcet_index == i then--加选择框
                local selectSprite = CCSprite:createWithSpriteFrameName("medal_medal_select.png")
                selectSprite:setAnchorPoint(ccp(0.5,0.5))
                selectSprite:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                self.soul_icon[i]:addChild(selectSprite,100)
            end
        else--未开启的
            local closeSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("medal_medal_back2.png")
            if closeSpriteFrame then
                self.soul_icon[i]:setDisplayFrame(closeSpriteFrame)
            end
            local tipsLabel = game_util:createLabelTTF({text = "Tiến hóa đến+" .. adv_level .. "\nmở",color = ccc3(188,189,191)})
            tipsLabel:setDimensions(CCSizeMake(50,28))
            tipsLabel:setPosition(ccp(25,20))
            self.soul_icon[i]:addChild(tipsLabel,10)
            --未开启的给屏蔽掉
            if itemSoulData and itemSoulData[i] ~= "0" then
                itemSoulData[i] = "0"
                self.changeFlag = true
            end
        end
    end

    --英魂信息
    self.node_intro_msg_board:removeAllChildrenWithCleanup(true)
    
    --显示所有的而不是选中的
    local j = 0
    for i=1,6 do
        if itemSoulData and itemSoulData[i] ~= "0" then
            j = j + 1
            id = itemSoulData[i]
            local s_id = souldata2[id].s_id
            local lv = souldata2[id].lv
            local itemCfg = soulCfg:getNodeWithKey(s_id)
            local name = itemCfg:getNodeWithKey("name"):toStr()
            local level_add = itemCfg:getNodeWithKey("level_add"):toFloat()
            -- cclog2(level_add,"level_add")
            local soulNameLabel = game_util:createLabelTTF({text = name,color = ccc3(254,212,11)})
            soulNameLabel:setPosition(ccp(10,105 - j * 15))
            soulNameLabel:setAnchorPoint(ccp(0,0.5))
            self.node_intro_msg_board:addChild(soulNameLabel)

            --属性
            local abilityType = itemCfg:getNodeWithKey("ability"):toInt()
            local value = itemCfg:getNodeWithKey("value"):toInt()
            local abilityItem = PUBLIC_ABILITY_TABLE["ability_" .. abilityType]
            --属性2
            local abilityType2 = itemCfg:getNodeWithKey("ability2"):toInt()
            local value2 = itemCfg:getNodeWithKey("value2"):toInt()
            local level_add2 = itemCfg:getNodeWithKey("level_add2"):toFloat()
            local abilityItem2 = PUBLIC_ABILITY_TABLE["ability_" .. abilityType2]
            -- cclog2(abilityType,"abilityType=======")
            local abilityLabel = nil
            if abilityType2 and abilityType2 ~=0 then
                if abilityType2 < 6 or abilityType2>200 then
                    abilityLabel = game_util:createLabelTTF({text = abilityItem.name .. "+" .. math.floor(value+lv*level_add).."  "..abilityItem2.name .. "+" .. math.floor(value2+lv*level_add2)})
                else
                    local percent = string.format("%.1f", value+lv*level_add)
                    local percent2 = string.format("%.1f", value2+lv*level_add2)
                    abilityLabel = game_util:createLabelTTF({text = abilityItem.name .. "+" .. percent .. "%".."  "..abilityItem2.name .. "+" .. percent2 .. "%"})
                end
            else
                if abilityType < 6 or abilityType>200 then
                    abilityLabel = game_util:createLabelTTF({text = abilityItem.name .. "+" .. math.floor(value+lv*level_add)})
                else
                    local percent = string.format("%.1f", value+lv*level_add)

                    abilityLabel = game_util:createLabelTTF({text = abilityItem.name .. "+" .. percent .. "%"})
                end
            end 
            abilityLabel:setPosition(ccp(70,105 - j * 15))
            abilityLabel:setAnchorPoint(ccp(0,0.5))
            self.node_intro_msg_board:addChild(abilityLabel)
        end
    end
    j = 0
end
--[[--
    刷新卡牌信息
]]
function game_god_append_soul.refreshHeroInfo(self)
    --穿戴的英魂
    self:createSoulInfo()
    --人物属性
    self:createHeroProperty()
    --人物技能
    self:createHeroSkills()
    --人物动画
    self:createCardAnimByData()
end


--[[--
    刷新战斗力
]]
function game_god_append_soul.refreshCombatLabel(self)
    local tempTeamData = game_data:getGodCardsPosData();
    local m_tEquipPosData1 = game_data:getGodEquipPosData1();
    local m_tEquipPosData2 = game_data:getGodEquipPosData2();
    local m_tEquipPosData3 = game_data:getGodEquipPosData3();
    local m_tGemPosData1 = game_data:getGodGemPosData1();
    local m_tGemPosData2 = game_data:getGodGemPosData2();
    local m_tGemPosData3 = game_data:getGodGemPosData3();
    local tempSoulData = game_data:getAllGodSoulPosData();
    local tempMedalData = game_data:getAllGodMedalPosData();
    local tempEquipData = {m_tEquipPosData1,m_tEquipPosData2,m_tEquipPosData3}
    local tempGemData = {m_tGemPosData1,m_tGemPosData2,m_tGemPosData3}
    if self.m_tempCombatValue == nil then
        self.m_tempCombatValue = game_util:getGodCombatValue(tempTeamData[tostring(self.team_index)],tempEquipData[self.team_index],tempGemData[self.team_index],tempSoulData[self.team_index],tempMedalData[self.team_index]);
        self.m_combatNumberChangeNode:setCurValue(self.m_tempCombatValue,false);
    else
        local tempCombatValue = game_util:getGodCombatValue(tempTeamData[tostring(self.team_index)],tempEquipData[self.team_index],tempGemData[self.team_index],tempSoulData[self.team_index],tempMedalData[self.team_index]);
        local changeValue = tempCombatValue - self.m_tempCombatValue
        self.m_tempCombatValue = tempCombatValue;
        game_util:combatChangedValueAnim({combatNode = self.m_combatNumberChangeNode,currentValue = tempCombatValue,changeValue = changeValue});
    end

end

--[[
    获取小伙伴位置上的动画
]]
function game_god_append_soul.createCardAnimByData(self)
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
            self.m_race_label:setString("Không có chủng tộc");
        end
    end
end

--[[--
    创建一个接受触摸事件的button
]]
function game_god_append_soul.createTouchButton( self, fun, parent, tag , anchorX, anchorY)
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
function game_god_append_soul.refreshUi(self)
    --刷新战斗力
    self:refreshCombatLabel()
    --刷新人物信息
    self:refreshHeroInfo()
end

--[[--
    初始化
]]
function game_god_append_soul.init(self,t_params)
    t_params = t_params or {};
    self.heroId = t_params.heroId
    self.m_selcet_index = 1
    --根据阵型和选择的第几个来判断取第几个数据，formationId > index ，没有变化，如果formationId < index 则取的index - 1 个数据
    self.posIndex = t_params.posIndex -- 选择的第几个
    self.formationId = t_params.formationId -- 阵型
    self.changeFlag = t_params.changeFlag or false--是否改变了英魂位置
    self.m_callFunc = t_params.m_callFunc or {}

    if t_params.m_openType then
        self.m_openType = t_params.m_openType 
    end
    if t_params.m_btn_index then
        self.team_index = t_params.m_btn_index
    end

   
end

--[[--
    创建ui入口并初始化数据
]]
function game_god_append_soul.create(self,t_params)
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end

return game_god_append_soul;
