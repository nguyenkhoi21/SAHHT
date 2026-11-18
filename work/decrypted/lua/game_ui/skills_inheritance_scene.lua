---  技能進階 

local skills_inheritance_scene = {
    m_skill_layer = nil,--技能父節點
    m_anim_node = nil,--動畫節點
    m_selHeroId = nil,--選中的heroid
    m_ok_btn = nil,
    m_currentSkillTable = nil,
    m_material_id_table = nil,
    m_autoSelectFlag = nil,
    m_tips_spr_1 = nil,
    m_tips_spr_2 = nil,
    m_hero_bg_btn = nil,
    m_material_node_tab = nil,
    m_list_view_bg = nil,
    m_sel_btn = nil,
    m_material_node = nil,
    m_showType = nil,
    m_selListItem = nil,
    m_needFood = nil,
    m_up_skill_index = nil,
    m_up_skill_node = nil,
    m_up_skill_node_1 = nil,
    m_up_skill_node_2  =nil,
    m_curPage = nil,
    m_cost_food_label = nil,
    m_food_total_label = nil,
    m_ccbNode = nil,
    m_anim_node_parent = nil,
    m_root_layer = nil,
    m_auto_add_btn = nil,
    m_selFilterCardSortIndex = nil,
    m_selHeroTab = nil,
    m_scroll_view_tips = nil,
    m_mate_tips = nil,
    m_selSortIndex = nil,
    m_showHeroTable = nil,
    m_light_bg_1 = nil,
    m_no_material_tips = nil,
};
--[[--
    銷毀ui
]]
function skills_inheritance_scene.destroy(self)
    -- body
    cclog("-----------------skills_inheritance_scene destroy-----------------");
    self.m_skill_layer = nil;
    self.m_anim_node = nil;
    self.m_selHeroId = nil;
    self.m_ok_btn = nil;
    self.m_currentSkillTable = nil;
    self.m_material_id_table = nil;
    self.m_autoSelectFlag = nil;
    self.m_tips_spr_1 = nil;
    self.m_tips_spr_2 = nil;
    self.m_hero_bg_btn = nil;
    self.m_material_node_tab = nil;
    self.m_list_view_bg = nil;
    self.m_sel_btn = nil;
    self.m_material_node = nil;
    self.m_showType = nil;
    self.m_selListItem = nil;
    self.m_needFood = nil;
    self.m_up_skill_index = nil;
    self.m_up_skill_node = nil;
    self.m_up_skill_node_1 = nil;
    self.m_up_skill_node_2  =nil;
    self.m_curPage = nil;
    self.m_cost_food_label = nil;
    self.m_food_total_label = nil;
    self.m_ccbNode = nil;
    self.m_anim_node_parent = nil;
    self.m_root_layer = nil;
    self.m_auto_add_btn = nil;
    self.m_selFilterCardSortIndex = nil;
    self.m_selHeroTab = nil;
    self.m_scroll_view_tips = nil;
    self.m_mate_tips = nil;
    self.m_selSortIndex = nil;
    self.m_showHeroTable = nil;
    self.m_light_bg_1 = nil;
    self.m_no_material_tips = nil;
end
--[[--
    返回
]]
function skills_inheritance_scene.back(self,backType)
    if backType == "back" then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    讀取ccbi創建ui
]]
function skills_inheritance_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 2 then--材料
            if self.m_selHeroId == nil then
                game_util:addMoveTips({text = "Hãy chọn đồng đội muốn cường hóa kĩ năng!"});
                return;
            end
            if not (self.m_up_skill_index and self.m_currentSkillTable[self.m_up_skill_index].upFlag == true) then
                game_util:addMoveTips({text = "Hãy chọn kĩ năng muốn cường hóa!"});
                return;
            end
            if self.m_showType == 2 then
                return;
            end
            self:refreshByType(2);
        elseif btnTag == 3 then--重新選擇
            if self.m_showType ~= 1 then
                self:refreshByType(1);
            end
        elseif btnTag == 101 then--開始進階
            self:onSureFunc();
        elseif btnTag == 102 then--自動選擇
            self:autoSelectMaterial();
        elseif btnTag == 21 then--升級前技能詳細
            if self.m_selHeroId and self.m_up_skill_index then
                game_scene:addPop("skills_activation_pop",{selHeroId=self.m_selHeroId,posIndex = self.m_up_skill_index})
            end
        elseif btnTag == 22 then--升級後技能詳細
            if self.m_selHeroId and self.m_up_skill_index then
                local skill_detail_cfg = getConfig(game_config_field.skill_detail);
                local skillCfg = self.m_currentSkillTable[self.m_up_skill_index].skillCfg;
                local is_evolution = skillCfg:getNodeWithKey("is_evolution"):toStr();
                local skillData = {lv = 1,avail = 2,s = is_evolution,exp = 0};
                game_scene:addPop("skills_activation_pop",{skillData=skillData})
            end
        elseif btnTag >= 201 and btnTag <= 204 then--排序
            self:refreshSortTabBtn(btnTag - 200);
            if self.m_showType == 1 then
                local selSort = tostring(CARD_SORT_TAB[btnTag - 200].sortType);
                game_data:cardsSortByTypeName(selSort);
                self:refreshCardTableView();
            elseif self.m_showType == 2 then
                self:refreshFilterCardTableView();
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);

    ccbNode:openCCBFile("ccb/ui_skills_inheritance.ccbi");
    local m_formation_layer = ccbNode:layerColorForName("m_formation_layer")

    --英雄相關
    self.m_skill_layer = ccbNode:layerColorForName("m_skill_layer")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")
    self.m_tips_spr_2 = ccbNode:spriteForName("m_tips_spr_2")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn")
    self.m_hero_bg_btn = ccbNode:controlButtonForName("m_hero_bg_btn")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_material_node = ccbNode:nodeForName("m_material_node")
    self.m_up_skill_node = ccbNode:nodeForName("m_up_skill_node")
    self.m_up_skill_node_1 = ccbNode:nodeForName("m_up_skill_node_1")
    self.m_up_skill_node_2  =ccbNode:nodeForName("m_up_skill_node_2")
    self.m_cost_food_label = ccbNode:labelBMFontForName("m_cost_food_label")
    self.m_food_total_label = ccbNode:labelBMFontForName("m_food_total_label")
    self.m_anim_node_parent = ccbNode:nodeForName("m_anim_node_parent")
    self.m_auto_add_btn = ccbNode:controlButtonForName("m_auto_add_btn")
    self.m_scroll_view_tips = ccbNode:scrollViewForName("m_scroll_view_tips")
    game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    game_util:setControlButtonTitleBMFont(self.m_auto_add_btn)
    self.m_mate_tips = ccbNode:spriteForName("m_mate_tips")
    self.m_no_material_tips = ccbNode:spriteForName("m_no_material_tips")
    self.m_light_bg_1 = ccbNode:scale9SpriteForName("m_light_bg_1");

    local m_material_node = nil;
    for i=1,1 do
        m_material_node = ccbNode:nodeForName("m_material_node_" .. i);
        self.m_material_node_tab[i] = {m_material_node = m_material_node}
    end
    self:initSkillLayerTouch(self.m_skill_layer);
    self.m_ccbNode = ccbNode;
    game_util:createScrollViewTips2(self.m_scroll_view_tips,{"jnjj_miaoshu.png","jnsj_miaoshu_1.png","jnsj_miaoshu_2.png"});
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    self.m_root_layer:setTouchEnabled(false);
    return ccbNode;
end

--[[--
    自動選擇材料
]]
function skills_inheritance_scene.autoSelectMaterial(self)
    if self.m_selHeroId == nil then
        game_util:addMoveTips({text = "Hãy chọn đồng đội muốn cường hóa kĩ năng!"});
        return;
    end
    if not (self.m_up_skill_index and self.m_currentSkillTable[self.m_up_skill_index].upFlag == true) then
        game_util:addMoveTips({text = "Hãy chọn kĩ năng muốn cường hóa!"});
        return;
    end
    if self.m_showType ~= 2 then
        self.m_showType = 2;
        self:refreshSortTabBtn(self.m_selFilterCardSortIndex);
        self:filterMaterialData();
    end
    self.m_material_id_table[1] = self.m_showHeroTable[1]
    self:refreshMaterial();
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createFilterTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
    self:refreshTips();
end

--[[--

]]
function skills_inheritance_scene.onSureFunc(self)
    if self.m_selHeroId == nil then
        game_util:addMoveTips({text = "Hãy chọn thẻ bài thiết lập lại kĩ năng!"});
        return;
    end
    if self.m_up_skill_index and self.m_currentSkillTable[self.m_up_skill_index].upFlag == true then
        if #self.m_material_id_table == 0 then
            game_util:addMoveTips({text = "Hãy chọn thẻ bài nguyên liệu!"});
        else
            local function sendRequest()
                local function responseMethod(tag,gameData)
                    if gameData == nil then
                        self.m_root_layer:setTouchEnabled(false);
                        return;
                    end
                    self:responseSuccess();
                end
                --majoy=1&food=2&skill=s_1  majoy: 主卡id  food: 被吃卡id  skill: 要進化的技能id（s_1, s_2, s_3)
                local params = {};
                params.majoy = self.m_selHeroId;
                params.food = self.m_material_id_table[1];
                params.skill = "s_" .. self.m_up_skill_index;
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_eat_card"), http_request_method.GET, params,"school_eat_card",true,true)
            end
            self.m_root_layer:setTouchEnabled(true);
            sendRequest();
        end
    else
        game_util:addMoveTips({text = "Kĩ năng này không thể bị tiến hóa!"});
    end
end

--[[--
    
]]
function skills_inheritance_scene.responseSuccess(self)
    local function responseEndFunc()
        self.m_root_layer:setTouchEnabled(false);
        self.m_material_id_table = {};
        self:refreshUi();
        self:refreshByType(1);
        game_sound:playUiSound("evo_success")
        game_util:addMoveTips({text = "Tiến hóa kĩ năng thành công!!"});
    end
    local rempveIndex = #self.m_material_id_table
    local animFile = "anim_icon_disappear"
    for i=1,#self.m_material_id_table do
        local m_material_node = self.m_material_node_tab[i].m_material_node;
        local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
        if mAnimNode then
            local function onAnimSectionEnd(animNode, theId,theLabelName)
                if theLabelName == "impact1" then
                    animNode:playSection("impact2");
                    local tempNode = m_material_node:getChildByTag(10)
                    if tempNode then
                        tempNode:setVisible(false);
                    end
                else
                    mAnimNode:removeFromParentAndCleanup(true);
                    rempveIndex = rempveIndex - 1;
                    if rempveIndex == 0 then
                        responseEndFunc();
                        self.m_ccbNode:runAnimations("success_anim")
                    end
                end
            end
            mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
            mAnimNode:playSection("impact1");
            local tempSize = m_material_node:getContentSize();
            mAnimNode:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
            m_material_node:addChild(mAnimNode,100,100);
        else
            responseEndFunc();
        end
    end
end

--[[--
    技能層
]]
function skills_inheritance_scene.initSkillLayerTouch(self,formation_layer)
    local items = formation_layer:getChildren();
    local itemCount = items:count();
    local tempItem = nil;
    local realPos = nil;
    local tag = nil;
    local function onTouchBegan(x, y)
        -- cclog("initSkillLayerTouch onTouchBegan --")
        tempItem = nil;
        tag = nil;
        -- CCTOUCHBEGAN event must return true
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        for i = 1,itemCount do
            tempItem = tolua.cast(items:objectAtIndex(i - 1),"CCSprite");
            if tempItem:boundingBox():containsPoint(realPos) then
                tag = tempItem:getTag();
                if tag < 4 and self.m_currentSkillTable[i] ~= nil and formation_layer:isVisible() then
                else
                    tempItem = nil;
                end
                break;
            end
        end
        return true
    end
    
    local function onTouchMoved(x, y)
    end
    
    local function onTouchEnded(x, y)
        cclog("initSkillLayerTouch onTouchEnded --")
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        if tempItem and tempItem:boundingBox():containsPoint(realPos) and tag and tag < 4 then
            local upFlag = self.m_currentSkillTable[tag].upFlag;
            if self.m_selHeroId then
                local function callFunc(tag,posIndex)
                    self.m_up_skill_index = posIndex;
                    -- self:refreshByType(1);
                    self:refreshEvoSkill(posIndex);
                end
                game_scene:addPop("skills_activation_pop",{selHeroId=self.m_selHeroId,posIndex = tag,posNode = tempItem,openType = "skills_inheritance_scene",callFunc=callFunc,upFlag = upFlag})
            end
            -- if upFlag == true then
            --     if self.m_selHeroId then
            --         self.m_up_skill_index = tag;
            --         self:refreshByType(2);
            --         self:refreshEvoSkill(tag);
            --     end
            -- else
            --     local function callFunc(tag,posIndex)
            --         self.m_up_skill_index = posIndex;
            --         self:refreshByType(2);
            --         self:refreshEvoSkill(posIndex); 
            --     end
            --     game_scene:addPop("skills_activation_pop",{selHeroId=self.m_selHeroId,posIndex = tag,posNode = tempItem,openType = "skills_inheritance_scene",callFunc=callFunc,upFlag = upFlag})
            -- end
        end
    end
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
            elseif eventType == "moved" then
            return onTouchMoved(x, y)
            else
            return onTouchEnded(x, y)
        end
    end
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY)
    formation_layer:setTouchEnabled(true)
end


--[[--
    刷新材料列表
]]
function skills_inheritance_scene.refreshMaterial(self)
    local tempHeadIcon = nil;
    local m_material_node = nil;
    local tempSize = nil;
    self.m_mate_tips:setVisible(true);
    for index=1,#self.m_material_node_tab do
        m_material_node = self.m_material_node_tab[index].m_material_node;
        m_material_node:removeAllChildrenWithCleanup(true);
        if self.m_material_id_table[index] ~= nil then
            self.m_mate_tips:setVisible(false);
            local card_id = tostring(self.m_material_id_table[index])
            local cardData,cardCfg = game_data:getCardDataById(card_id)
            tempHeadIcon = game_util:createCardIconByCfg(cardCfg);
            if tempHeadIcon then
                tempSize = m_material_node:getContentSize();
                tempHeadIcon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                m_material_node:addChild(tempHeadIcon,10,10);
            end
        else
            if self.m_selHeroId ~= nil then

            end
        end
    end
end

--[[--
    屬性英雄信息
]]
function skills_inheritance_scene.refreshHeroInfo(self,heroId)
    self.m_needFood = 0;
    self.m_selHeroId = heroId;
    local tempNode = nil;
    for i=1,6 do
        tempNode = self.m_skill_layer:getChildByTag(i);
        if tempNode then
            tempNode:removeAllChildrenWithCleanup(true);
        end
    end
    self.m_currentSkillTable = {};
    self.m_anim_node:removeAllChildrenWithCleanup(true);
	if heroId ~= nil and heroId ~= "-1" then
        local cardData,heroCfg = game_data:getCardDataById(tostring(heroId));
        local ccbNode = game_util:createHeroListItemByCCB(cardData);
        self.m_anim_node:addChild(ccbNode,10,10);

        local skill_detail_cfg = getConfig(game_config_field.skill_detail);
        local skill_levelup_cfg = getConfig(game_config_field.skill_levelup);
        local skillJsonData = nil;
        local skillItem = nil;
        for i=1,3 do
            skillItem = cardData["s_" .. i]
            if skillItem and skillItem.s ~= 0 then
                local skill_icon_spr_bg = self.m_skill_layer:getChildByTag(i)
                local icon_size = skill_icon_spr_bg:getContentSize();
                local tempStr = "";
                local tempColor = ccc3(255,0,0);
                cclog("skillItem.s ==================================" .. skillItem.s);
                skillJsonData = skill_detail_cfg:getNodeWithKey(tostring(skillItem.s));
                if skillJsonData then
                    self.m_currentSkillTable[i] = {skillCfg = skillJsonData,upFlag = false,skillData = skillItem};
                    local maxLv = skillJsonData:getNodeWithKey("max_lv"):toInt();
                    local lvLabel = CCLabelTTF:create("Lv." .. skillItem.lv,TYPE_FACE_TABLE.Arial_BoldMT,14);
                    lvLabel:setColor(ccc3(255,255,255));
                    lvLabel:setPosition(ccp(icon_size.width*2,icon_size.height*0.7));
                    skill_icon_spr_bg:addChild(lvLabel,10,10);
                    local skill_icon_spr = game_util:createSkillIconByCfg(skillJsonData)
                    if skill_icon_spr then
                        skill_icon_spr:setPosition(ccp(icon_size.width*0.5,icon_size.height*0.5));
                        skill_icon_spr_bg:addChild(skill_icon_spr);
                    end
                    -- 'avail': 1   # 0表示未解鎖，1表示解鎖未激活，2表示激活
                    if skillItem.avail == 2 then
                        if skillItem.lv >= maxLv then
                            if skillJsonData:getNodeWithKey("is_evolution"):toInt() ~=0 then
                                self.m_currentSkillTable[i].upFlag = true;
                                tempStr = "Có thể tiến hóa!";
                                tempColor = ccc3(0, 255, 0);
                            else
                                tempStr = "Không thể tiến hóa!";
                            end
                        else
                            tempStr = "Không đủ cấp";
                        end
                    else
                        local lock_icon_spr = CCSprite:createWithSpriteFrameName("public_lock_icon.png");
                        lock_icon_spr:setPosition(icon_size.width*0.5,icon_size.height*0.5);
                        skill_icon_spr_bg:addChild(lock_icon_spr,5,5);
                        tempStr = "Chưa mở";
                    end
                else
                    tempStr = "Không có kĩ năng";
                end
                local tempLabel = CCLabelTTF:create(tempStr,TYPE_FACE_TABLE.Arial_BoldMT,12);
                tempLabel:setColor(tempColor);
                tempLabel:setPosition(ccp(icon_size.width*2,icon_size.height*0.3));
                skill_icon_spr_bg:addChild(tempLabel,11,11);
            end
        end
	end
    self:refreshTips();
end

--[[--
    刷新傳承的技能
]]
function skills_inheritance_scene.refreshEvoSkill(self,index)
    self.m_skill_layer:setVisible(true);
    self.m_up_skill_node:setVisible(false);
    self.m_up_skill_index = index;
    self.m_up_skill_node_1:removeAllChildrenWithCleanup(true);
    self.m_up_skill_node_2:removeAllChildrenWithCleanup(true);
    self.m_needFood = 0;
    local skill_detail_cfg = getConfig(game_config_field.skill_detail);
    if index ~= nil and  self.m_currentSkillTable[index] ~= nil then

        self.m_skill_layer:setVisible(false);
        self.m_up_skill_node:setVisible(true);
        local skillCfg = self.m_currentSkillTable[index].skillCfg;
        local skill_icon_spr = game_util:createSkillIconByCfg(skillCfg)
        local icon_size = self.m_up_skill_node_1:getContentSize();
        skill_icon_spr:setPosition(ccp(icon_size.width*0.5,icon_size.height*0.5));
        self.m_up_skill_node_1:addChild(skill_icon_spr);
        local lvLabel = CCLabelTTF:create("Lv." .. self.m_currentSkillTable[index].skillData.lv,TYPE_FACE_TABLE.Arial_BoldMT,14);
        lvLabel:setColor(ccc3(255,255,255));
        lvLabel:setPosition(ccp(icon_size.width*2,icon_size.height*0.7));
        self.m_up_skill_node_1:addChild(lvLabel,10,10);
        local rate = skillCfg:getNodeWithKey("rate"):toInt();
        -- local nameLabel = CCLabelTTF:create(skillCfg:getNodeWithKey("skill_name"):toStr(),TYPE_FACE_TABLE.Arial_BoldMT,14);
        local nameLabel = CCLabelTTF:create("Tỉ lệ phát động:" .. rate .. "%",TYPE_FACE_TABLE.Arial_BoldMT,12);
        nameLabel:setColor(ccc3(255,255,255));
        nameLabel:setPosition(ccp(icon_size.width*2,icon_size.height*0.3));
        self.m_up_skill_node_1:addChild(nameLabel,11,11);
        local is_evolution = skillCfg:getNodeWithKey("is_evolution"):toStr();
        local skill_evolution_item = skill_detail_cfg:getNodeWithKey(is_evolution);
        if skill_evolution_item ~= nil then
            self.m_needFood = skill_evolution_item:getNodeWithKey("evo_food"):toInt();
            -- cclog("skill_evolution_item name ===" .. skill_evolution_item:getNodeWithKey("skill_name"):toStr());
            local skill_icon_spr = game_util:createSkillIconByCfg(skill_evolution_item)
            local icon_size = self.m_up_skill_node_2:getContentSize();
            skill_icon_spr:setPosition(ccp(icon_size.width*0.5,icon_size.height*0.5));
            self.m_up_skill_node_2:addChild(skill_icon_spr);
            local lvLabel = CCLabelTTF:create("Lv.1",TYPE_FACE_TABLE.Arial_BoldMT,14);
            lvLabel:setColor(ccc3(255,255,255));
            lvLabel:setPosition(ccp(icon_size.width*2,icon_size.height*0.7));
            self.m_up_skill_node_2:addChild(lvLabel,10,10);
            local rate = skill_evolution_item:getNodeWithKey("rate"):toInt();
            -- local nameLabel = CCLabelTTF:create(skill_evolution_item:getNodeWithKey("skill_name"):toStr(),TYPE_FACE_TABLE.Arial_BoldMT,14);
            local nameLabel = CCLabelTTF:create("Tỉ lệ phát động:" .. rate .. "%",TYPE_FACE_TABLE.Arial_BoldMT,12);
            nameLabel:setColor(ccc3(255,255,255));
            nameLabel:setPosition(ccp(icon_size.width*2,icon_size.height*0.3));
            self.m_up_skill_node_2:addChild(nameLabel,11,11);
        end
    end
    self:refreshTips();
end

--[[--
    
]]
function skills_inheritance_scene.getEvoSkillCount(self)
    local tempCount = 0;
    local tempItem = nil;
    for i=1,3 do
        tempItem = self.m_currentSkillTable[i]
        if tempItem and tempItem.upFlag == true then
            tempCount = tempCount + 1;
        end
    end
    return tempCount;
end

--[[--
    過慮材料數據材料
]]
function skills_inheritance_scene.filterMaterialData(self)
    local character_ID = -1;
    local heroData = nil;
    local itemConfig = nil;
    local selHeroStar = 0;
    local selQuality = 0;
    local skillItem = nil;
    local skillId = nil;
    local currentSkillTable = {};
    local evoSkillId = -1;

    if self.m_selHeroId ~= nil then
        heroData,itemConfig = game_data:getCardDataById(tostring(self.m_selHeroId));
        selHeroStar = heroData.star
        character_ID = itemConfig:getNodeWithKey("character_ID"):toInt();
        selQuality = itemConfig:getNodeWithKey("quality"):toInt();
        skillItem = heroData["s_" .. tostring(self.m_up_skill_index)];
        if skillItem then
            evoSkillId = skillItem.s
        end
    end

    local character_detail = getConfig(game_config_field.character_detail);
    local cardsDataTable = game_data:getTableCardsData();
    local showHeroTable = {};
    for key,heroData in pairs(cardsDataTable) do
        if key ~= tostring(self.m_selHeroId) and not game_data:heroInTeamById(key) and not game_util:getCardLockFlag(heroData) then
            itemConfig = character_detail:getNodeWithKey(heroData.c_id);
            -- if selHeroStar <= heroData.star then
                for i=1,3 do
                    skillItem = heroData["s_" .. i]
                    skillId = skillItem.s;
                    if skillId and skillId ~= 0 and skillItem.avail == 2 and evoSkillId == skillId then
                        cclog("skillId =============================" .. skillId);
                        showHeroTable[#showHeroTable+1] = heroData.id
                        break;
                    end
                end
            -- end
        end
    end
    game_data:cardsSortByTypeNameWithTable(CARD_SORT_TAB[self.m_selFilterCardSortIndex].sortType,showHeroTable);
    self.m_showHeroTable = showHeroTable;
end

--[[--
    創建篩選的列表
]]
function skills_inheritance_scene.createFilterTableView(self,viewSize)
    self.m_selListItem = nil;
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");

    local showHeroTable = self.m_showHeroTable or {};
    local cardsCount = #showHeroTable;
    if cardsCount == 0 then
        self.m_no_material_tips:setVisible(true);
    end
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = cardsCount --totalItem;
    params.direction = kCCScrollViewDirectionVertical;
    params.itemActionFlag = true;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createHeroListItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < cardsCount then
                local itemData,_ = game_data:getCardDataById(showHeroTable[index+1]);
                if itemData then
                    local heroId = itemData.id;
                    game_util:setHeroListItemInfoByTable2(ccbNode,itemData);
                    local flag,k = game_util:idInTableById(tostring(itemData.id),self.m_material_id_table)
                    if flag then
                        local m_sel_img = ccbNode:spriteForName("sprite_selected")
                        m_sel_img:setVisible(true);
                        local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                        sprite_back_alpha:setVisible(true);
                        self.m_selListItem = cell;
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell) .. " ; cell:getUserData() = " .. tolua.type(cell:getUserData()));
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
            local itemData,_ = game_data:getCardDataById(showHeroTable[index+1]);
            local heroId = tostring(itemData.id);
            if heroId ~= tostring(self.m_material_id_table[1]) then
                if self.m_selListItem then
                    local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                    local m_sel_img = ccbNode:spriteForName("sprite_selected")
                    m_sel_img:setVisible(false);
                    local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                    sprite_back_alpha:setVisible(false);
                end
                self.m_material_id_table[1] = heroId;
                self.m_selListItem = cell;
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("sprite_selected")
                m_sel_img:setVisible(true);
                local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                sprite_back_alpha:setVisible(true);
                self:refreshMaterial();
            end
        elseif eventType == "longClick" and cell then
            local itemData = showHeroTable[index+1].heroData;
            local function callBack(typeName)
                typeName = typeName or ""
                if typeName == "refresh" then
                    self:refreshFilterCardTableView();
                end
            end
            game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 1,callBack = callBack})
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        -- self.m_selListItem = nil;
    end
    return TableViewHelper:create(params);
end

--[[--
    創建英雄列表
]]
function skills_inheritance_scene.createTableView(self,viewSize)
    self.m_selListItem = nil;
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");

    local cardsCount = game_data:getCardsCount();
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = cardsCount -- totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.itemActionFlag = true;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createHeroListItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < cardsCount then
                local itemData,_ = game_data:getCardDataByIndex(index+1);--self.m_selHeroTab[index+1].heroData;
                if itemData then
                    local card_id = itemData.id;
                    game_util:setHeroListItemInfoByTable2(ccbNode,itemData);
                    if self.m_selHeroId and self.m_selHeroId == card_id then
                        local m_sel_img = ccbNode:spriteForName("sprite_selected")
                        m_sel_img:setVisible(true);
                        local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                        sprite_back_alpha:setVisible(true);
                        self.m_selListItem = cell;
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
            local itemData,_ = game_data:getCardDataByIndex(index+1);--self.m_selHeroTab[index+1].heroData;
            local card_id = itemData.id;
            if self.m_selHeroId == nil or self.m_selHeroId ~= card_id then
                if self.m_selListItem then
                    local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                    local m_sel_img = ccbNode:spriteForName("sprite_selected")
                    m_sel_img:setVisible(false);
                    local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                    sprite_back_alpha:setVisible(false);
                end
                self.m_selListItem = cell;
                self.m_selHeroId = card_id;
                self.m_showType = 1;
                self.m_up_skill_index = nil;
                self:refreshHeroInfo(self.m_selHeroId);
                self:refreshMaterial();
                self.m_up_skill_node:setVisible(false);
                self.m_skill_layer:setVisible(true)
                self.m_mate_tips:stopAllActions();
                self.m_mate_tips:setOpacity(255);
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("sprite_selected")
                m_sel_img:setVisible(true);
                local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                sprite_back_alpha:setVisible(true);
            end
        elseif eventType == "longClick" and cell then
            local itemData,_ = game_data:getCardDataByIndex(index+1); -- self.m_selHeroTab[index+1].heroData;
            local function callBack(typeName)
                typeName = typeName or ""
                if typeName == "refresh" then
                    self:refreshCardTableView();
                end
            end
            game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 1,callBack = callBack})
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        -- self.m_selListItem = nil;
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function skills_inheritance_scene.refreshCardTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--
    刷新
]]
function skills_inheritance_scene.refreshFilterCardTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self:filterMaterialData();
    self.m_tableView = self:createFilterTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--

]]
function skills_inheritance_scene.refreshSortTabBtn(self,sortIndex)
    local tempBtn = nil;
    if self.m_showType == 1 then
        self.m_selSortIndex = sortIndex
        for i=1,4 do
            tempBtn = self.m_ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
            tempBtn:setHighlighted(self.m_selSortIndex == i);
            tempBtn:setEnabled(self.m_selSortIndex ~= i);
        end
    elseif self.m_showType == 2 then
        self.m_selFilterCardSortIndex = sortIndex
        for i=1,4 do
            tempBtn = self.m_ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
            tempBtn:setHighlighted(self.m_selFilterCardSortIndex == i);
            tempBtn:setEnabled(self.m_selFilterCardSortIndex ~= i);
        end
    end
end

--[[--
    刷新
]]
function skills_inheritance_scene.refreshByType(self,showType)
    self.m_no_material_tips:setVisible(false);
    self.m_showType = showType;
    if showType == 1 then
        self.m_material_id_table = {};
        self:refreshMaterial();
        self.m_up_skill_node:setVisible(false);
        self.m_skill_layer:setVisible(true)
        self:refreshSortTabBtn(self.m_selSortIndex);
        self:refreshCardTableView();
    elseif showType == 2 then
        self.m_up_skill_node:setVisible(true);
        self.m_skill_layer:setVisible(false)
        self:refreshSortTabBtn(self.m_selFilterCardSortIndex);
        self:refreshFilterCardTableView();
    end
    self:refreshTips();
end

--[[--
    刷新按鈕狀態
]]
function skills_inheritance_scene.refreshTips(self)
    game_util:setCCControlButtonEnabled(self.m_auto_add_btn,true);
    if self.m_showType == 1 then
        self.m_cost_food_label:setString("0");
        if self.m_selHeroId == nil then
            self.m_mate_tips:stopAllActions();
            self.m_mate_tips:setOpacity(255);
            self.m_tips_spr_1:setVisible(true);
            self.m_tips_spr_2:setVisible(false);
            game_util:setCCControlButtonEnabled(self.m_auto_add_btn,false);
            self.m_tips_spr_1:runAction(game_util:createRepeatForeverFade())
            self.m_light_bg_1:runAction(game_util:createRepeatForeverFade())
        else
            self.m_tips_spr_1:setVisible(false);
            self.m_tips_spr_2:setVisible(false);
            if (self.m_up_skill_index and self.m_currentSkillTable[self.m_up_skill_index].upFlag == true) then
                self.m_mate_tips:runAction(game_util:createRepeatForeverFade())
            end
        end
    elseif self.m_showType == 2 then
        self.m_tips_spr_1:setVisible(false);
        self.m_tips_spr_2:setVisible(false);
    end
    local totalFood = game_data:getUserStatusDataByKey("food") or 0
    local value,unit = game_util:formatValueToString(totalFood);
    self.m_food_total_label:setString(value .. unit);
    game_util:setCostLable(self.m_cost_food_label,self.m_needFood,totalFood);
end

--[[--
    刷新ui
]]
function skills_inheritance_scene.refreshUi(self)
    self:refreshHeroInfo(self.m_selHeroId);
    self:refreshMaterial();
    self:refreshByType(self.m_showType);
end
--[[--
    初始化
]]
function skills_inheritance_scene.init(self,t_params)
    t_params = t_params or {};
    self.m_selHeroId = t_params.selHeroId;
    self.m_currentSkillTable = {};
    self.m_material_id_table = {};
    if t_params.material_id_table and type(t_params.material_id_table) == "table" then
        self.m_material_id_table = t_params.material_id_table;
    end
    self.m_material_node_tab = {};
    self.m_showType = 1;
    self.m_needFood = 0;
    self.m_up_skill_index = nil;
    self.m_selFilterCardSortIndex = 1;
    self.m_selHeroTab = {};
    local selSort = game_data:getCardSortType();
    for k,v in pairs(CARD_SORT_TAB) do
        if v.sortType == selSort then
            self.m_selSortIndex = k;
            break;
        end
    end
    self.m_selSortIndex = self.m_selSortIndex or 1;
    self.m_showHeroTable = {};
end

--[[--
    創建ui入口並初始化數據
]]
function skills_inheritance_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    local id = game_guide_controller:getIdByTeam("20");
    if id == 78 then
        game_guide_controller:gameGuide("drama","20",78)
    end
    return uiNode;
end

return skills_inheritance_scene;
