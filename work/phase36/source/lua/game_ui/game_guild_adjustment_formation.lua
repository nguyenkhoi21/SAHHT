--- 编队信息 

local game_guild_adjustment_formation = {
    m_formation_center_layer = nil,
    m_currentFormationId = nil,
    m_selFormationId = nil,--选择的阵型
    m_changeFlag = nil,
    m_openType = nil,
    m_formation_layer = nil,
    m_root_layer = nil,
    m_formation_label = nil,
    m_selHeroUi = nil,
    m_selEquipUi = nil,
    m_scroll_view_tips = nil,
    m_sel_list_view_item = nil,
    m_combat_label = nil,
    m_guildNode = nil,
    m_back_btn = nil,

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

    m_equip_layer = nil,
    m_gem_layer = nil,
    m_anim_node = nil,
    m_ccbNode = nil,
    m_posIndex = nil,
    m_tempTeamData = nil,
    m_tempEquipPosData = nil,
    m_teamPosNodeTab = nil,
    m_sel_bg = nil,
    m_fate_node = nil,
    m_fate_detail_node = nil,
    m_fate_label = nil,
    m_fate_detail_label = nil,
    m_openTab = nil,
    m_tempSelIndex = nil,
    m_tempCombatValue = nil,

    m_tab_btn_1 = nil,
    m_tab_btn_2 = nil,
    m_tab_btn_3 = nil,
    m_adjust1 = nil,
    m_adjust2 = nil,
    m_scrollView = nil,
    m_tempFriendData = nil,
    m_tempDestinyData = nil,

    m_teamIndex = nil;
    select_temp_id = nil,
    m_title_node = nil,
    m_chainTab = nil,
    m_chainTabBackUp = nil,
    m_combatNumberChangeNode = nil,
    m_selEquipId = nil,
    m_oneFateScrollView = nil,
    m_tempGemPosData = nil,
    m_selGemPos = nil,
    m_guide_step = nil,
    m_spr_mingyunnode = nil,
    m_node_infodetailBoar = nil,
    m_spr_infoBoar = nil,
    m_activation_node = nil,
    m_fate_list_view_bg = nil,
    m_fateDataTab = nil,
    m_replace_btn = nil,
    m_assistant_detail_label = nil,
    m_ability2OpenFlag = nil,
    m_teamGemOpenFlag = nil,
    m_medal_btn = nil,

    m_tempMedalPosData = nil,
    m_tempSoulPosData = nil,
    allUniverseEffect = nil,--宇宙属性加成
    m_soul_btn = nil,
    m_zhuanshiData = nil,
    buzhen_node = nil,
    right_btn = nil,
    m_bossId = nil,
    m_tab_guyongEquip = nil,--存放雇佣来的卡牌的装备数据
};
--阵型的配置
-- local formationConfig = {{0,1,0,1,0},{1,1,1,1,1},{0,0,0,0,0},{1,0,1,0,1},{0,1,1,1,0},{1,0,0,0,1}} 
local tipsStrTab = {"Ấn khung NV để đổi hình NV","Kéo khung NV để đổi vị trí","Đội chủ chiến phải có 1 nhân vật"}
local formationPosTab = {{key="position_a",x=0.82,y=0.83},{key="position_b",x=0.82,y=0.5},{key="position_c",x=0.82,y=0.17},{key="position_d",x=0.5,y=0.83},{key="position_e",x=0.5,y=0.5},{key="position_f",x=0.5,y=0.17}};

--[[--
    销毁
]]
function game_guild_adjustment_formation.destroy(self)
    -- body
    cclog("-----------------game_guild_adjustment_formation destroy-----------------");
    self.m_formation_center_layer = nil;
    self.m_currentFormationId = nil;
    self.m_selFormationId = nil;
    self.m_changeFlag = nil;
    -- self.m_openType = nil;
    self.m_formation_layer = nil;
    self.m_root_layer = nil;
    self.m_formation_label = nil;
    self.m_selHeroUi = nil;
    self.m_selEquipUi = nil;
    self.m_scroll_view_tips = nil;
    self.m_sel_list_view_item = nil;
    self.m_combat_label = nil;
    self.m_guildNode = nil;
    self.m_back_btn = nil;

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
    self.m_equip_layer = nil;
    self.m_anim_node = nil;
    self.m_ccbNode = nil;
    self.m_posIndex = nil;
    self.m_tempTeamData = nil;
    self.m_teamPosNodeTab = nil;
    self.m_sel_bg = nil;
    self.m_fate_node = nil;

    self.m_fate_detail_node = nil;
    self.m_fate_label = nil;
    self.m_fate_detail_label = nil;
    self.m_openTab = nil;
    self.m_tempSelIndex = nil;
    self.m_tempCombatValue = nil;
    self.select_temp_id = nil;
    self.m_title_node = nil;
    self.m_chainTab = nil;
    self.m_chainTabBackUp = nil;
    self.m_combatNumberChangeNode = nil;
    self.m_selEquipId = nil;
    self.m_tempEquipPosData = nil;
    self.m_oneFateScrollView = nil;
    self.m_tempGemPosData = nil;
    self.m_selGemPos = nil;
    self.m_guide_step = nil;
    self.m_gem_layer = nil;
    self.m_spr_mingyunnode = nil;
    self.m_node_infodetailBoar = nil;
    self.m_spr_infoBoar = nil;
    self.m_teamIndex = nil;
    self.m_activation_node = nil;
    self.m_fate_list_view_bg = nil;
    self.m_fateDataTab = nil;
    self.m_replace_btn = nil;
    self.m_assistant_detail_label = nil;
    self.m_ability2OpenFlag = nil;
    self.m_teamGemOpenFlag = nil;
    self.m_medal_btn = nil;

    self.m_tempMedalPosData = nil;
    self.m_tempSoulPosData = nil;
    self.allUniverseEffect = nil;
    self.m_soul_btn = nil;
    self.m_zhuanshiData = nil;
    self.buzhen_node = nil;
    self.right_btn = nil;
    self.m_bossId = nil;
    self.m_tab_guyongEquip = nil;
end
--[[--
    返回
]]
function game_guild_adjustment_formation.back(self,type)
    game_data:setGuildGuildCurTeam({})
    game_data:setGuildTeamData2({}) 
    game_data:setGuildOtherTeamData({}) 
    game_data:setGuildFormationData({})
    game_data:setGuildSelTeamData({})
    local association_id = game_data:getUserStatusDataByKey("association_id");
    if association_id == 0 then
        require("like_oo.oo_controlBase"):openView("guild_join");
    else
        require("like_oo.oo_controlBase"):openView("guild");
    end
    self:destroy();

end

function game_guild_adjustment_formation.sendChangedData(self,btnTag,t_params)
        local function tempFunction()
            if btnTag == 1 then--返回
                self:back();
            elseif btnTag == 100 then
                game_scene:enterGameUi("skills_replacement_scene",{gameData = nil,selPosIndex = t_params.posIndex});
                self:destroy();
            end
        end
        if  btnTag ~= 1 then
            local function responseMethod(tag,gameData)
                if gameData ~= nil then
                    if gameData then
                        local data = gameData:getNodeWithKey("data")
                        game_data:setBattleType("game_choose_boss");
                        local data = gameData:getNodeWithKey("data")
                        local stageTableData = {}

                        stageTableData.name = "stageName"
                        stageTableData.step = 1;
                        stageTableData.totalStep = 3;
                        local stageTableData = {name = "Phó bản Guild",step = 1,totalStep = 3}
                        --传背景图
                        local guild_employ_boss_cfg = json.decode(getConfig(game_config_field.guild_employ_boss):getFormatBuffer()) or {}
                        local imgName = guild_employ_boss_cfg[tostring(self.m_bossId)].background
                        -- cclog("imgName = "..imgName);
                        game_scene:enterGameUi("game_battle_scene",{gameData = gameData,stageTableData=stageTableData,backGroundName=imgName});
                    else
                        self.m_move_flag = false;
                    end
                else
                    game_util:addMoveTips({text = "Yêu cầu dữ liệu thất bại, thử lại!"});
                end
            end
            local teamTable = game_data:getGuildSelTeamId()
            if self.m_changeFlag then
            else
                teamTable = self.m_tempTeamData
            end
            local tempTabData,teamTable2,useTable = {},{},{}
            local prarms = "align_1=";
            for i=1,#teamTable do
                if teamTable[i] ~= "-1" then
                    table.insert(teamTable2,teamTable[i])
                end
            end
            for i=1,10 do
                if teamTable2[i] then
                else
                    teamTable2[i] = "-1"
                end
            end
            if self.m_changeFlag == true then
                useTable  = teamTable
            else
                useTable  = teamTable2
            end
            game_data:setGuildGuildCurTeam(useTable)
            
            
            for k = 1,5 do
                if useTable[k] == nil then
                    prarms = prarms .. "-1" .. (k == 5 and "" or "_")
                else
                    prarms = prarms .. useTable[k] .. (k == 5 and "" or "_")
                end
            end
            prarms = prarms .. "&align_2="
            for k = 6,10 do
                if useTable[k] == nil then
                    prarms = prarms .. "-1" .. (k == 10 and "" or "_") 
                else
                    prarms = prarms .. useTable[k] .. (k == 10 and "" or "_") 
                end
            end 
            game_data:setguildFormationId(self.m_selFormationId)
            prarms = prarms .. "&formation=" ..self.m_selFormationId .. "&boss_id=" .. self.m_bossId .."&is_first=1";
            local tempDataTab = game_data:getGuildSelTeamData();
            local uidTab = {};
            if tempDataTab then

                for k,v in pairs(tempDataTab) do
                    for m=1,#teamTable  do
                        if k == teamTable[m] then
                            if v.uid then
                                uidTab[k] = tostring(v.uid)
                                prarms = prarms .. "&employ_cards=" .. k .. "_" .. v.uid
                            end
                        end
                    end
                end
            end
            prarms = prarms .. "&step_n=0";
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_employ_boss_fight"), http_request_method.POST, prarms,"association_employ_boss_fight")
        else
            tempFunction();
        end
end

--[[--
    读取ccbi创建ui
]]
function game_guild_adjustment_formation.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag ==== ")
        -- cclog2(btnTag, "game_guild_adjustment_formation.createUi onMainBtnClick btnTag  ===  ")
        if btnTag == 1 then
            
            self:sendChangedData(btnTag);
        elseif btnTag == 11 then
            if self.m_teamIndex == 1 then
                if self.m_posIndex == -1 or self.m_tempTeamData[self.m_posIndex] == "-1" then return end
                self:addSelHeroUi(self.m_posIndex);
            else
                if self.m_posIndex == -1 or self.m_tempFriendData[self.m_posIndex] == "-1" then return end
                self:addFriendSelHeroUi(self.m_posIndex);                
            end
        elseif btnTag > 20 and btnTag < 26 then
            if self.m_posIndex == -1 then return end;
            local heroData,heroCfg = nil,nil;
            if self.m_teamIndex == 1 then
                heroData,heroCfg = self:getTeamCardDataByPos(self.m_posIndex);
            else
                heroData,heroCfg = self:getFriendCardDataByPos(self.m_posIndex);
            end
            if heroData then
                game_scene:addPop("game_hero_attr_pop",{selHeroId = heroData.id,posNode=tagNode,attrType = btnTag-20})
            end
        elseif btnTag == 30 then
            local heroData,heroCfg = nil,nil;
            if self.m_teamIndex == 1 then
                heroData,heroCfg = self:getTeamCardDataByPos(self.m_posIndex);
            else
                heroData,heroCfg = self:getFriendCardDataByPos(self.m_posIndex);
            end
            if heroData and heroCfg then
                local function callBack(typeName)

                end
                game_scene:addPop("game_hero_info_pop",{tGameData = heroData,openType = 1,callBack = callBack})
            end
        elseif btnTag == 51 or btnTag == 52 then--命运摘要  命运详情
            self:refreshFateTabBtn(btnTag - 50);
        elseif btnTag == 53 then
            self:sendChangedData();
        elseif btnTag == 177 then
            game_data:setGuildGuildCurTeam(self.m_tempTeamData)
            cclog("----ffffff_employ_pop------")
            local function responseMethod(tag,gameData)
                local temp = {}
                -- game_data:setGuildSelTeamId(temp);
                -- game_data:setGuildOtherTeamData(temp);--把选中的别人的卡也制空
                game_scene:addPop("game_guild_choose_employ_pop",{gameData = gameData,openType = "formAdjustion"})
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_employ_ground"), http_request_method.GET, nil,"association_employ_ground")
    
        elseif btnTag == 61 then--说明 149
            game_scene:addPop("game_active_limit_detail_pop",{enterType = "149"})
        end

    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_adjustment_formation_guild.ccbi");

    self.m_node_infodetailBoar = ccbNode:nodeForName("m_node_infodetailBoar")
    self.m_spr_infoBoar = ccbNode:nodeForName("m_spr_infoBoar")
    self.m_formation_layer = ccbNode:layerColorForName("m_formation_layer")
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_formation_label = ccbNode:labelTTFForName("m_formation_label")
    self.m_scroll_view_tips = ccbNode:scrollViewForName("m_scroll_view_tips")
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
    self.m_spr_mingyunnode = ccbNode:nodeForName("m_spr_mingyunnode")
    self.m_equip_layer = ccbNode:layerForName("m_equip_layer")
    self.m_gem_layer = ccbNode:layerForName("m_gem_layer")
    self.m_activation_node = ccbNode:nodeForName("m_activation_node")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    -- self.m_anim_node:removeAllChildrenWithCleanup(true);
    self.m_sel_bg = ccbNode:spriteForName("m_sel_bg")
    self.m_sel_bg:setVisible(false);
    self.m_fate_node = ccbNode:nodeForName("m_fate_node")
    self.m_fate_detail_node = ccbNode:nodeForName("m_fate_detail_node")
    self.right_btn = ccbNode:controlButtonForName("right_btn")
    local labelsize = self.m_fate_node:getContentSize();
    self.m_fate_label = game_util:createRichLabelTTF({text = "",dimensions = labelsize,textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = nil,color = ccc3(221,221,192)})
    self.m_fate_label:setAnchorPoint(ccp(0, 0.25));
    self.m_fate_node:addChild(self.m_fate_label)
    local labelsize = CCSizeMake(self.m_fate_detail_node:getContentSize().width, self.m_fate_detail_node:getContentSize().height);
    local scrollView = CCScrollView:create(labelsize);
    local gobattle = ccbNode:controlButtonForName("gobattle")

    -- scrollView:setPositionY(5)
    scrollView:setDirection(kCCScrollViewDirectionVertical);
    self.m_fate_detail_node:addChild(scrollView,2,2);
    self.m_oneFateScrollView = scrollView;
    -- self.m_fate_detail_label = game_util:createRichLabelTTF({text = "",dimensions = labelsize,textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = nil,color = ccc3(221,221,192)})
    -- self.m_fate_detail_label:setAnchorPoint(ccp(0, 0));
    -- scrollView:addChild(self.m_fate_detail_label)
    self.m_equip_layer:setVisible(true);
    self.m_fate_label:setVisible(true)
    self.m_activation_node:setVisible(false);
    self.m_fate_detail_node:setVisible(false);

    self.m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
    self.m_combat_label:setVisible(false);
    local pX,pY = self.m_combat_label:getPosition();
    self.m_combatNumberChangeNode = game_util:createExtNumberChangeNode({labelType = 2});
    self.m_combatNumberChangeNode:setPosition(ccp(pX, pY));
    self.m_combatNumberChangeNode:setAnchorPoint(ccp(0, 0.5));
    self.m_combat_label:getParent():addChild(self.m_combatNumberChangeNode);
    self.m_combatNumberChangeNode:setCurValue(0,false);

    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    

    self.m_tab_btn_1 = ccbNode:controlButtonForName("m_tab_btn_1");
    self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2");
    self.m_tab_btn_3 = ccbNode:controlButtonForName("m_tab_btn_3");
    self.m_replace_btn = ccbNode:controlButtonForName("m_replace_btn");
    self.m_replace_btn:setVisible(false)
    self.m_adjust1 = ccbNode:nodeForName("m_adjust1");
    self.m_adjust2 = ccbNode:nodeForName("m_adjust2");
    self.m_scrollView = ccbNode:scrollViewForName("m_scrollView");
    self.m_title_node = ccbNode:nodeForName("m_title_node");
    self.m_fate_list_view_bg = ccbNode:nodeForName("m_fate_list_view_bg")
    -- self:initAdjustmentFormationTouch(self.m_formation_layer);
    -- self:initEquipLayerTouch(self.m_equip_layer);
    -- game_util:createScrollViewTips(self.m_scroll_view_tips,tipsStrTab);
    self.m_tab_btn_1:setVisible(false);
    self.m_tab_btn_2:setVisible(false);
    self.m_tab_btn_3:setVisible(false);

    self.m_adjust1:setVisible(true);
    self.m_adjust2:setVisible(false);

    self.m_ccbNode = ccbNode;

    if not self.m_teamGemOpenFlag then 
        self.m_gem_layer:setVisible(false)
        -- self.m_node_infodetailBoar:setPositionY(self.m_node_infodetailBoar:getPositionY() - 4)
        -- self.m_spr_infoBoar:setPositionY(self.m_spr_infoBoar:getPositionY() - 4)
        self.m_equip_layer:setPositionY(80)
        -- self.m_fate_detail_node:setPositionY(self.m_fate_detail_node:getPositionY() - 15)
        -- self.m_fate_node:setPositionY(self.m_fate_node:getPositionY() - 15)
        -- self.m_spr_mingyunnode:setPositionY(self.m_spr_mingyunnode:getPositionY() - 8)
    end
    self:refreshFateTabBtn(1);

    self.m_medal_btn = ccbNode:controlButtonForName("m_medal_btn")
    self.m_medal_btn:setVisible(false)

    self.m_soul_btn = ccbNode:controlButtonForName("m_soul_btn")
    self.m_soul_btn:setVisible(false)
    return ccbNode;
end

--[[--
    
]]
function game_guild_adjustment_formation.getTeamCardDataByPos(self,posIndex)
    return game_data:getGuildCardDataById(self.m_tempTeamData[posIndex])
end

--[[--
    创建动画
]]
function game_guild_adjustment_formation.createCardAnimByPosIndex(self,posIndex)
    local heroData,heroCfg = self:getTeamCardDataByPos(posIndex)
    return self:createCardAnimByData(heroData,heroCfg);
end

--[[
    获取小伙伴位置上的动画
]]
function game_guild_adjustment_formation.createCardAnimByData( self, heroData,heroCfg,animFlag)
    local animNode = nil;
    local character_ID = -1;
    if heroData and heroCfg then
        character_ID = heroCfg:getNodeWithKey("character_ID"):toInt();
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        animFlag = animFlag == nil and true or animFlag
        if animFlag then
            animNode = game_util:createIdelAnim(ainmFile,0,heroData,heroCfg);
        else
            animNode = game_util:createCardImgByCfg(heroCfg);
        end
        if animNode then
            local itemSize = animNode:getContentSize();
            if animFlag == false then
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dw_light_down.png")
                if spriteFrame then
                    local tempSprite = CCSprite:createWithSpriteFrame(spriteFrame)
                    tempSprite:setAnchorPoint(ccp(0.5,0.1))
                    tempSprite:setPositionX(itemSize.width*0.5)
                    animNode:addChild(tempSprite)
                end
                local spriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dw_light_up.png")
                if spriteFrame2 then
                    local tempSprite = CCSprite:createWithSpriteFrame(spriteFrame2)
                    tempSprite:setAnchorPoint(ccp(0.5,0.1))
                    tempSprite:setPositionX(itemSize.width*0.5)
                    animNode:addChild(tempSprite,1000,1000)
                end
            else
                animNode:setRhythm(1);
            end
            animNode:setAnchorPoint(ccp(0.5,0));
            -- animNode:setScale(0.7);
            local name_after = heroData.step < 1 and "" or ("+" .. heroData.step);
            local tempLabel = CCLabelTTF:create("Lv." .. heroData.lv .. "/" .. heroData.level_max .. "\n" .. name_after,TYPE_FACE_TABLE.Arial_BoldMT,10);
            tempLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
            tempLabel:setPosition(ccp(itemSize.width*0.5 - 50,97));
            tempLabel:setAnchorPoint(ccp(0,0.5));
            animNode:addChild(tempLabel,100,100)
            -- local tempLabel = CCLabelTTF:create(heroCfg:getNodeWithKey("name"):toStr(),TYPE_FACE_TABLE.Arial_BoldMT,10);
            -- tempLabel:setPosition(ccp(itemSize.width*0.5 + 50,95));
            -- tempLabel:setAnchorPoint(ccp(1,0.5));
            -- animNode:addChild(tempLabel,100,100)
            -- game_util:setHeroNameColorByQuality(tempLabel,heroCfg);
            local occupation_cfg = getConfig(game_config_field.occupation);
            local occupation_item_cfg = occupation_cfg:getNodeWithKey(ainmFile)
            if occupation_item_cfg then
                local occupationType = occupation_item_cfg:toInt();
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupationType .. ".png")
                if spriteFrame then
                    local occupation_icon = CCSprite:createWithSpriteFrame(spriteFrame)
                    occupation_icon:setPosition(ccp(itemSize.width*0.5 + 57,98));
                    occupation_icon:setAnchorPoint(ccp(1,0.5));
                    animNode:addChild(occupation_icon);
                end
            end
            animNode:setScale(0.66);
        end
    end
    return animNode,character_ID
end

--[[--
    初始化编队信息
]]
function game_guild_adjustment_formation.initTeamFormation(self,formation_layer)
    self.m_tempSelIndex = -1
    local level = game_data:getUserStatusDataByKey("level");
    local itemIcon = nil;
    local headIconSpr = nil;
    local tempLock = nil;
    local character_detail_cfg = getConfig("character_detail");
    local tempLockIndex,selLevel = -1,100;
    local tempTxt = nil;
    local tempGuildNode = nil;
    local id = game_guide_controller:getCurrentId();
    for i=1,9 do
        itemIcon = self.m_ccbNode:spriteForName("m_pos_" .. i)
        formation_layer:reorderChild(itemIcon,-1000)
        local headIconBgSize = itemIcon:getContentSize();
        itemIcon:removeAllChildrenWithCleanup(true);
        if self.m_openTab[i] == 1 then
        else
            tempLock = CCSprite:createWithSpriteFrameName("dw_suo.png");
            tempLock:setPosition(ccp(headIconBgSize.width/2,headIconBgSize.height/2));
            itemIcon:addChild(tempLock);
            local openLevel = TEAM_LOCK_TIPS_TAB[i].openLevel
            if level < openLevel then
                -- if selLevel > openLevel then
                --     selLevel = openLevel;
                --     tempLockIndex = i;
                --     -- cclog("selLevel ==== " .. selLevel .. " ; tempLockIndex === " .. tempLockIndex)
                -- end
                local headIconSpr = CCSprite:createWithSpriteFrameName(tostring(TEAM_LOCK_TIPS_TAB[i].lockImg));
                if headIconSpr then
                    local headIconBgSize = itemIcon:getContentSize();
                    headIconSpr:setPosition(ccp(headIconBgSize.width*0.5, headIconBgSize.height*0.5))
                    itemIcon:addChild(headIconSpr,2,2)
                end
            end
        end
        local animNode,character_ID = self:createCardAnimByPosIndex(i)
        -- cclog("animNode ================ " .. tostring(animNode))
        if animNode then
            animNode:setPosition(ccp(headIconBgSize.width*0.5,headIconBgSize.height*0.1));
            itemIcon:addChild(animNode,1,1);
            self:setPositionBg(i,true);
            if id == 30 then
                self.m_guide_step = 30
                if self.m_guildNode == nil and character_ID == 53 then
                    self.m_guildNode = itemIcon;
                end
                if tempGuildNode == nil then
                    tempGuildNode = itemIcon;
                end
            end
            if self.m_tempSelIndex == -1 then
                self.m_tempSelIndex = i;
            end
        else
            if id == 19 and self.m_guildNode == nil and self.m_openTab[i] == 1 then
                self.m_guildNode = itemIcon;
            end
            self:setPositionBg(i,false);
        end
    end
    if id == 30 and self.m_guildNode == nil then
        self.m_guildNode = tempGuildNode;
    end
    -- if tempLockIndex ~= -1 then
    --     local itemIcon = self.m_ccbNode:spriteForName("m_pos_" .. tempLockIndex)
    --     local headIconSpr = CCSprite:createWithSpriteFrameName(tostring(TEAM_LOCK_TIPS_TAB[tempLockIndex].lockImg));
    --     if headIconSpr then
    --         local headIconBgSize = itemIcon:getContentSize();
    --         headIconSpr:setPosition(ccp(headIconBgSize.width*0.5, headIconBgSize.height*0.5))
    --         itemIcon:addChild(headIconSpr,2,2)
    --     end
    -- end
    self:formationOpenAnim();

    self:initAdjustmentFormationTouch(self.m_formation_layer);
    self:initEquipLayerTouch(self.m_equip_layer);
    if not self.m_teamGemOpenFlag then 
        self.m_gem_layer:setVisible(false)
    end
end


function game_guild_adjustment_formation.createFormationOpenAnimByPos(self,pos)
    local itemIcon = self.m_ccbNode:spriteForName("m_pos_" .. pos)
    if itemIcon then
        local function callBackFunc()
            if pos == 5 then
                local addSpr = CCSprite:createWithSpriteFrameName("dw_wenzi_tianjia.png");
                if addSpr then
                    local headIconBgSize = itemIcon:getContentSize();
                    addSpr:setPosition(ccp(headIconBgSize.width*0.5, headIconBgSize.height*0.5))
                    itemIcon:addChild(addSpr,2,2)
                end
            end
        end
        local anim_zhandouli = game_util:createEffectAnimCallBack("animi_zhenxing_split",1.0,false,callBackFunc);
        if anim_zhandouli then
            local pX,pY = itemIcon:getPosition();
            anim_zhandouli:setPosition(ccp(pX,pY))
            itemIcon:getParent():addChild(anim_zhandouli,1000);
            game_sound:playUiSound("zhakai2")
        end
    end
end

function game_guild_adjustment_formation.formationOpenAnim(self)
    local cardNumData = game_data:getBattleCardNumData()
    local position_num = math.min(cardNumData.position_num,5)
    local temp_position_num = math.min(cardNumData.temp_position_num,5)
    local alternate_num = math.min(cardNumData.alternate_num,3)
    local temp_alternate_num = math.min(cardNumData.temp_alternate_num,3)
    if position_num > temp_position_num then
        for i=temp_position_num+1,position_num do
            if i == 3 then
                self:createFormationOpenAnimByPos(5);
            elseif i == 4 then
                self:createFormationOpenAnimByPos(6);
            elseif i == 5 then
                self:createFormationOpenAnimByPos(1);
                self:createFormationOpenAnimByPos(4);
            end
        end
    end
    if alternate_num > temp_alternate_num  then
        for i=temp_alternate_num,alternate_num-1 do
            self:createFormationOpenAnimByPos(7+i);
        end
    end
    game_data:resetBattleCardNumData();
end

function game_guild_adjustment_formation.getExchangeTeamDataByTwoPosFlag(self,posIndex1,posIndex2)
    local cardNumData = game_data:getBattleCardNumData()
    local maxCount1,maxCount2 = cardNumData.position_num or 2,cardNumData.alternate_num or 0;
    local returnValue = 0;
    if self.m_openTab[posIndex1] == 0 or self.m_openTab[posIndex2] == 0 then
        returnValue = 5;
        game_util:addMoveTips({text = string_config:getTextByKey("m_team_pos_no_open")});
        return returnValue;
    end
    local count1,count2 = 0,0;
    local cardId = nil;
    for i=1,6 do
        cardId = self.m_tempTeamData[i]
        if cardId ~= "-1" then
            count1 = count1 + 1;
        end
    end
    for i=7,9 do
        cardId = self.m_tempTeamData[i]
        if cardId ~= "-1" then
            count2 = count2 + 1;
        end
    end
    -- cclog("posIndex1 = " .. posIndex1 .. " ; posIndex2 = " .. posIndex2)
    if posIndex1 > 0 and posIndex1 < 10 and posIndex2 > 0 and posIndex2 < 10 then
        if posIndex1 < 7 and posIndex2 < 7 then--主站
            returnValue = 0;
        elseif posIndex1 > 6 and posIndex2 > 6 then--替补
            returnValue = 0;
        elseif posIndex1 > 6 and posIndex2 < 7 then--替补主站
            if self.m_tempTeamData[posIndex1] ~= "-1" and self.m_tempTeamData[posIndex2] == "-1" then
                count1 = count1 + 1;
                count2 = count2 - 1;
            end
        elseif posIndex1 < 7 and posIndex2 > 6 then--主站替补
            if self.m_tempTeamData[posIndex1] ~= "-1" and self.m_tempTeamData[posIndex2] == "-1" then
                count1 = count1 - 1;
                count2 = count2 + 1;
            end
        else
            returnValue = 1--
        end
    end
    if count1 ~= 0 then
        if count1 > maxCount1 or count1 > 5 then
            returnValue = 2;
            game_util:addMoveTips({text = string_config:getTextByKey("m_master_is_max")});
        elseif count2 > maxCount2 then
            returnValue = 3;
            game_util:addMoveTips({text = string_config:getTextByKey("m_substitute_is_max")});
        end
    else
        returnValue = 4;
        game_util:addMoveTips({text = string_config:getTextByKey("m_master_at_least_one")});
    end
    -- cclog("getExchangeTeamDataByTwoPosFlag == returnValue =" .. returnValue .. " ; count1 == " .. count1 .. " ; count2 = " .. count2)
    return returnValue;
end

function game_guild_adjustment_formation.getUnloadPosFlag(self,posIndex)
    local returnValue = 0;
    local count1 = 0;
    if posIndex < 7 then
        local cardId = nil;
        for i=1,6 do
            cardId = self.m_tempTeamData[i]
            if cardId ~= "-1" then
                count1 = count1 + 1;
            end
        end
        if count1 < 2 and self.m_tempTeamData[posIndex] ~= "-1" then
            returnValue = 2;
            game_util:addMoveTips({text = string_config:getTextByKey("m_master_at_least_one")});
        end
    end
    return returnValue;
end

function game_guild_adjustment_formation.updateTeamData(self,posIndex,cardId)
    self.m_tempTeamData[posIndex] = cardId;
    self:setTeamFormationData();
end

function game_guild_adjustment_formation.exchangeTeamDataByTwoPos(self,posIndex1,posIndex2)
    -- cclog2("exchangeTeamDataByTwoPos ------")
    self.m_tempTeamData[posIndex1],self.m_tempTeamData[posIndex2] = self.m_tempTeamData[posIndex2],self.m_tempTeamData[posIndex1]
    self.m_tempEquipPosData[posIndex1],self.m_tempEquipPosData[posIndex2] = self.m_tempEquipPosData[posIndex2],self.m_tempEquipPosData[posIndex1]
    self.m_tempGemPosData[posIndex1],self.m_tempGemPosData[posIndex2] = self.m_tempGemPosData[posIndex2],self.m_tempGemPosData[posIndex1]
    self.m_tempMedalPosData[posIndex1],self.m_tempMedalPosData[posIndex2] = self.m_tempMedalPosData[posIndex2],self.m_tempMedalPosData[posIndex1]
    self.m_tempSoulPosData[posIndex1],self.m_tempSoulPosData[posIndex2] = self.m_tempSoulPosData[posIndex2],self.m_tempSoulPosData[posIndex1]
    -- table.foreach(self.m_tempTeamData,print)
    -- for k,v in pairs(self.m_tempEquipPosData) do
    --     table.foreach(v,print)
    -- end
    self:getExchangeGuyongEquip(posIndex1,posIndex2)
    self:setTeamFormationData();
end
function game_guild_adjustment_formation.getExchangeGuyongEquip( self,posIndex1,posIndex2 )
    if self.m_tab_guyongEquip[tostring(posIndex1)] and self.m_tab_guyongEquip[tostring(posIndex2)] then
        self.m_tab_guyongEquip[tostring(posIndex1)],self.m_tab_guyongEquip[tostring(posIndex2)] = self.m_tab_guyongEquip[tostring(posIndex2)],self.m_tab_guyongEquip[tostring(posIndex1)]
    elseif self.m_tab_guyongEquip[tostring(posIndex1)] then
        self.m_tab_guyongEquip[tostring(posIndex2)] = self.m_tab_guyongEquip[tostring(posIndex1)]
        self.m_tab_guyongEquip[tostring(posIndex1)] = nil
    elseif self.m_tab_guyongEquip[tostring(posIndex2)] then
        self.m_tab_guyongEquip[tostring(posIndex1)] = self.m_tab_guyongEquip[tostring(posIndex2)]
        self.m_tab_guyongEquip[tostring(posIndex2)] = nil
    end

    -- body
end

--[[--
    编队位置点击的处理
]]
function game_guild_adjustment_formation.initAdjustmentFormationTouch(self,formation_layer)
    local selItem = nil;
    local beganItem = nil;
    local endItem = nil;
    local touchBeginPoint = nil;
    local touchMoveFlag = false;
    local realPos = nil;
    local tempPosIndex = nil;
    local function onTouchBegan(x, y)
        if selItem then
            selItem:removeFromParentAndCleanup(true);
            selItem = nil;
        end
        touchMoveFlag = false;
        --cclog("onTouchBegan: %0.2f, %0.2f", x, y)
        touchBeginPoint = {x = x, y = y}
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        -- CCTOUCHBEGAN event must return true
        for tag = 1,9 do
            beganItem = self.m_ccbNode:spriteForName("m_pos_" .. tag)
            if beganItem and beganItem:boundingBox():containsPoint(realPos) then
                tempPosIndex = tag;
                selItem = self:createCardAnimByPosIndex(tempPosIndex)
                if selItem == nil then break end
                local pX,pY = beganItem:getPosition();
                selItem:setPosition(ccp(pX,pY));
                -- selItem:setColor(ccc3(128,128,128));
                formation_layer:addChild(selItem,11,11);
                selItem:setVisible(false);
                break;
            end
        end
        return true
    end
    
    local function onTouchMoved(x, y)
        
        -- cclog("onTouchMoved: %0.2f, %0.2f", x - touchBeginPoint.x, y - touchBeginPoint.y)
        if ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 or touchMoveFlag == true then
            if selItem then
                realPos = formation_layer:convertToNodeSpace(ccp(x,y));
                selItem:setPosition(realPos);
                selItem:setVisible(true);
            end
            touchMoveFlag = true;
        end
    end
    
    local function onTouchEnded(x, y)
        --cclog("onTouchEnded: %0.2f, %0.2f", x, y)
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        self:setPositionBg(self.m_posIndex,true);
        if not touchMoveFlag and tempPosIndex and self.m_posIndex ~= tempPosIndex then
            self:addTeamHeroPop(tempPosIndex);
        end
        if selItem and touchMoveFlag then
            -- self.m_posIndex = -1;
            -- self:refreshHeroInfo(self.m_posIndex);
            for endTag = 1,9 do
                endItem = self.m_ccbNode:spriteForName("m_pos_" .. endTag)
                if endItem and endItem:boundingBox():containsPoint(realPos) then
                    local beganTag = beganItem:getTag();
                    if endTag ~= beganTag and self:getExchangeTeamDataByTwoPosFlag(beganTag,endTag) == 0 then
                        cclog("exchange ----------beganTag = " .. beganTag .. " ; endTag = " .. endTag);
                        self:exchangeTeamDataByTwoPos(beganTag,endTag);
                        self.m_changeFlag = true;
                        local bgSize = endItem:getContentSize();
                        beganItem:removeAllChildrenWithCleanup(true)
                        local animNode = self:createCardAnimByPosIndex(beganTag)
                        if animNode then
                            animNode:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.1));
                            beganItem:addChild(animNode,1,1)
                            self:setPositionBg(beganTag,true);
                        else
                            self:setPositionBg(beganTag,false);
                        end
                        endItem:removeAllChildrenWithCleanup(true)
                        local animNode = self:createCardAnimByPosIndex(endTag)
                        if animNode then
                            animNode:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.1));
                            endItem:addChild(animNode,1,1)
                            self:setPositionBg(endTag,true);
                        else
                            self:setPositionBg(endTag,false);
                        end
                        self.m_posIndex = endTag;
                        self:refreshHeroInfo(endTag);
                        self:refreshCombatLabel("initAdjustmentFormationTouch");
                    end
                    break;
                end
            end
        end
        if selItem then
            selItem:removeFromParentAndCleanup(true);
            selItem = nil;
        end
        touchBeginPoint = nil;
        beganItem = nil;
        endItem = nil;
        tempPosIndex = nil;
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+131)
    formation_layer:setTouchEnabled(true)
end

--[[--
    
]]
function game_guild_adjustment_formation.setPositionBg(self,posIndex,aninFlag)
    if posIndex == -1 then return end
    local bgSprite = tolua.cast(self.m_formation_layer:getChildByTag(posIndex),"CCSprite");
    if bgSprite == nil then return end;
    local bgName = "";
    if aninFlag and self.m_tempTeamData[posIndex] ~= "-1" then
        if posIndex < 7 then
            bgName = "dw_characterBg.png";
        else
            bgName = "dw_characterBgtibu.png";
        end
    else
        if posIndex < 7 then
            bgName = "dw_characterAdd.png";
        else
            bgName = "dw_characterAddtibu.png";
        end
        
    end
    local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(bgName);
    if tempDisplayFrame then
        bgSprite:setDisplayFrame(tempDisplayFrame);
    end
end

--[[--
    
]]
function game_guild_adjustment_formation.setPositionBg2(self,posIndex)
    if posIndex == -1 then return end
    local bgSprite = tolua.cast(self.m_formation_layer:getChildByTag(posIndex),"CCSprite");
    if bgSprite == nil then return end;
    local bgName = "";
    local tempId = self.m_teamIndex == 2 and self.m_tempFriendData[posIndex] or self.m_tempDestinyData[posIndex]
    -- cclog("tempId ======= " .. tempId .. " ; posIndex ======= " .. posIndex)
    if tempId == "-1" then--未开启
        if posIndex < 7 then
            bgName = "dw_qiang_diban_1.png";
        else
            bgName = "dw_chao_diban_2.png";
        end
    elseif tempId == "0" then--
        bgName = "dw_characterAdd.png";
    else
        bgName = "dw_characterBg.png";
    end
    local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(bgName);
    if tempDisplayFrame then
        bgSprite:setDisplayFrame(tempDisplayFrame);
    end
end

--[[--
    
]]
function game_guild_adjustment_formation.setSelPositionBg(self,posIndex)
    if self.m_teamIndex == 1 then
        if posIndex == -1 or self.m_tempTeamData[posIndex] == "-1" then return end
    else
        if posIndex == -1 or self.m_tempFriendData[posIndex] == "-1" then return end
    end    
    local bgSprite = tolua.cast(self.m_formation_layer:getChildByTag(posIndex),"CCSprite");
    if bgSprite == nil then return end
    -- local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dw_characterBgSel.png");
    -- if tempDisplayFrame then
    --     bgSprite:setDisplayFrame(tempDisplayFrame);
        local pX,pY = bgSprite:getPosition();
        local tempPos = self.m_formation_layer:convertToWorldSpace(ccp(pX,pY));
        self.m_sel_bg:setPosition(ccp(pX,pY));
        self.m_sel_bg:setVisible(true);
    -- end
end

--[[--
    刷新卡牌信息
]]
function game_guild_adjustment_formation.getPosEquipAttrValue(self,posIndex)
    -- 1物攻 2魔攻 3防御 4速度 5生命
    local equip_set_random = getConfig(game_config_field.equip_set_random)
    local attrValueTab = {0,0,0,0,0};
    local posEquips = nil
    if self.m_teamIndex == 1 then
        posEquips = self.m_tempEquipPosData[posIndex]
    else
        posEquips = self.m_tempAssEquipPosData[tostring(posIndex+99)]
    end
    -- cclog("posIndex ==== " .. posIndex .. " ;type(posEquips) == " .. type(posEquips))
    local level,value1,value2;
    local suitTab = {};
    if posEquips and type(posEquips) == "table" then
        for k,v in pairs(posEquips) do
            local equipItemData,itemCfg = game_data:getEquipDataById(v);
            if equipItemData and itemCfg then
                level = equipItemData.lv;
                value1 = itemCfg:getNodeWithKey("value1"):toInt();
                value2 = itemCfg:getNodeWithKey("value2"):toInt();
                local level_add1,level_add2 = itemCfg:getNodeWithKey("level_add1"):toInt(),itemCfg:getNodeWithKey("level_add2"):toInt()
                value1 = value1 + level_add1*(level - 1);
                value2 = value2 + level_add2*(level - 1);
                -- cclog("value1 == " .. value1 .. " ; value2 == " .. value2)
                local ability1 = itemCfg:getNodeWithKey("ability1"):toInt();
                local ability2 = itemCfg:getNodeWithKey("ability2"):toInt();
                local attrName1 = PUBLIC_ABILITY_TABLE["ability_" .. ability1].attrName
                local attrName2 = PUBLIC_ABILITY_TABLE["ability_" .. ability2].attrName
                if equipItemData.equip_refine then
                    if equipItemData.equip_refine[attrName1] then
                        local temp1 = equipItemData.equip_refine[attrName1]
                        value1 = value1 + temp1
                    end
                    if equipItemData.equip_refine[attrName2] then
                        local temp2 = equipItemData.equip_refine[attrName2]
                        value2 = value2 + temp2
                    end
                end
                if attrValueTab[ability1] then
                    attrValueTab[ability1] = attrValueTab[ability1] + value1;
                end
                if attrValueTab[ability2] then
                    attrValueTab[ability2] = attrValueTab[ability2] + value2;
                end
                local suit = itemCfg:getNodeWithKey("suit"):toInt();
                if suitTab[suit] == nil then
                    suitTab[suit] = 0;
                    local suitCount,_,tempAttrValueTab = game_util:getEquipSuit(itemCfg:getNodeWithKey("suit"):toStr(),posEquips);
                    if suitCount > 0 then
                        for i=1,5 do
                            attrValueTab[i] = attrValueTab[i] + tempAttrValueTab[i]
                        end
                    end
                end
                --增加锻造属性值
                if equipItemData.is_equip_forge == true then
                    -- local attrname = 
                    -- local tempValue = {0,0,0,0,0}
                    for key_type,valueTable in pairs(equipItemData.equip_forge) do
                        local itemEquipForgeCfg = json.decode(equip_set_random:getNodeWithKey(tostring(key_type)):getFormatBuffer())
                        local sort = itemEquipForgeCfg.sort
                        local enemy = itemEquipForgeCfg.enemy[1]
                        local value = 0
                        for k,v in pairs(valueTable) do
                            value = v
                        end
                        -- cclog2(value,"equp forge value")
                        if sort > 0 and sort <= 5 then
                            -- tempValue[sort] = value

                            -- attrValueTab[sort] = attrValueTab[sort] * (1 + value)
                            --改成加数不用百分比
                            if enemy ~= -1 then--减敌人的不加
                                attrValueTab[sort] = attrValueTab[sort] + value
                            end
                        end
                    end
                                
                end


             end
        end
    end
    return attrValueTab
end

--[[
    宝石基本能力属性加成
]]
function game_guild_adjustment_formation.getGemBaseAttrValue(self, posIndex)
    local attrValueTab = {0,0,0,0,0}
    local combatValue = 0;
    local gemCfg = getConfig(game_config_field.gem);
    local gemPosItemData = self.m_tempGemPosData[posIndex] or {}
    for k,v in pairs(gemPosItemData) do
        local itemCfg = gemCfg:getNodeWithKey(tostring(v))
        if itemCfg then
            local ability = itemCfg:getNodeWithKey("ability"):toInt();
            local value = itemCfg:getNodeWithKey("value"):toInt();
            if ability > 0 and ability < 6 then
                attrValueTab[ability] = attrValueTab[ability] + value
            end
            local ability2 = itemCfg:getNodeWithKey("ability2")
            if ability2 then
                ability2 = ability2:toInt();
                local value2 = itemCfg:getNodeWithKey("value2"):toInt();
                if ability2 > 0 and ability2 < 6 then
                    attrValueTab[ability2] = attrValueTab[ability2] + value2
                end
            end
        end
    end
    return attrValueTab;
end

--[[
    勋章基本能力属性加成
]]
function game_guild_adjustment_formation.getMedalBaseAttrValue(self, posIndex)
    local attrValueTab = {0,0,0,0,0}
    local combatValue = 0;
    local medalCfg = getConfig(game_config_field.medal);
    local medalPosItemData = self.m_tempMedalPosData[posIndex] or {}

    for k,v in pairs(medalPosItemData) do
        local itemCfg = medalCfg:getNodeWithKey(tostring(v))
        if itemCfg then
            local effect = itemCfg:getNodeWithKey("effect")
            for i=1,3 do
                local itemEffect = effect:getNodeAt(i-1)
                local ability = itemEffect:getNodeAt(0):toInt()
                local value = itemEffect:getNodeAt(1):toInt()

                if ability > 0 and ability < 6 then
                    attrValueTab[ability] = attrValueTab[ability] + value
                end
            end
        end
    end
    return attrValueTab;
end

--[[
    英魂基本能力属性加成
]]
function game_guild_adjustment_formation.getSoulBaseAttrValue(self,posIndex)
    local attrValueTab = {0,0,0,0,0}
    local attrValueTab2 = {0,0,0,0,0}
    local attrValuePercent = {0,0,0,0,0}
    local combatValue = 0;
    local soulCfg = getConfig(game_config_field.soul_detail);
    local soulPosData = self.m_tempSoulPosData[posIndex] or {};
    -- cclog2(soulPosData,"soulPosData")
    -- cclog2(posIndex,"posIndex")
    local soulAllData = game_data:getSoulData()
    for k,v in pairs(soulPosData) do
        -- cclog2(soulPosItemKey,"soulPosItemKey")
        if v ~= "0" and v ~= "-1" then
            local itemSoulData = soulAllData[v]
            local s_id = itemSoulData.s_id
            local itemCfg = soulCfg:getNodeWithKey(tostring(s_id));
            local lv = itemSoulData.lv
            if itemCfg then
                local value = itemCfg:getNodeWithKey("value"):toInt()
                local ability = itemCfg:getNodeWithKey("ability"):toInt()
                local level_add = itemCfg:getNodeWithKey("level_add"):toFloat()
                if itemCfg:getNodeWithKey("value2") and itemCfg:getNodeWithKey("value"):toInt() ~=0 then
                    local value2 = itemCfg:getNodeWithKey("value2"):toInt()
                    local ability2 = itemCfg:getNodeWithKey("ability2"):toInt()
                    local level_add2 = itemCfg:getNodeWithKey("level_add2"):toFloat()
                    if ability2 > 0 and ability2 < 6 then
                        attrValueTab2[ability2] = attrValueTab2[ability2] + math.floor(value2 + level_add2 * lv)
                    end
                end
                if ability > 0 and ability < 6 then
                    attrValueTab[ability] = attrValueTab[ability] + math.floor(value + level_add * lv)
                -- else
                --     attrValueTab[ability] = attrValueTab[ability] + value
                elseif ability > 100 and ability < 106 then--加百分比的
                    local percent = value + level_add * lv
                    attrValuePercent[ability - 100] = percent--家百分比的只能穿一种
                end
            end
        end
    end
    return attrValueTab,attrValuePercent,attrValueTab2;
end
--[[--
    刷新卡牌信息
]]
function game_guild_adjustment_formation.refreshHeroInfo(self,posIndex,isFriendEquip)

    if game_data.getGuideProcess and game_data:getGuideProcess() == "guide_second" and self.m_guide_step == 30 then
        if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(48) end -- 第一次点击伙伴招募 步骤48
    end
    local replaceStr = "Thay thế"
    self.m_sel_bg:setVisible(false);
    self.m_selHeroId = nil;
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    local tempNode = nil;
    for i=1,8 do
        tempNode = self.m_ccbNode:spriteForName("m_equip_" .. i)
        if tempNode then
            tempNode:removeAllChildrenWithCleanup(true);
        end
    end
    local cardData,cardCfg = nil,nil;
    if self.m_teamIndex == 1 then
        cardData,cardCfg = self:getTeamCardDataByPos(posIndex);
    else
        cardData,cardCfg = self:getFriendCardDataByPos(posIndex);
    end
    -- cclog("cardData ========" .. tostring(cardData) .. " ; cardCfg ========" .. tostring(cardCfg))
    local fate_detail_label_str = "Không có";
    local attrValueTab = {0,0,0,0,0};
    if cardData and cardCfg then
        self:setSelPositionBg(posIndex);
        self.m_selHeroId = cardData.id
        self.m_life_label:setString(cardData.hp);
        self.m_physical_atk_label:setString(cardData.patk);
        self.m_magic_atk_label:setString(cardData.matk);
        self.m_def_label:setString(cardData.def);
        self.m_speed_label:setString(cardData.speed);
        local ainmFile = cardCfg:getNodeWithKey("animation"):toStr();
        local animNode = game_util:createHeroListItemByCCB(cardData);
        self.m_anim_node:addChild(animNode);
        -- 1物攻 2魔攻 3防御 4速度 5生命
        local equipAttrValueTab = self:getPosEquipAttrValue(posIndex);--装备属性
        local petAttrValueTab = game_util:getPetCombatValue(posIndex)
        local petFollowValueTab = game_util:getPetFollowCombatValue(posIndex)
        local gemAttrValueTab = {0,0,0,0,0};
        local medalAttrValueTab = {0,0,0,0,0}
        local attrValueTab2 = {0,0,0,0,0};
        local attrValueTab3 = {0,0,0,0,0};
        local universeCombatValue = 0
        local universeAttrValueTab = {0,0,0,0,0}
        local soulAttrValueTab = {0,0,0,0,0};
        local soulAttrValueTab2 = {0,0,0,0,0};
        local soulPercentValueTab = {0,0,0,0,0};
        local rolePropertryValueTab = {0,0,0,0,0}
        if self.m_teamIndex == 1 then
            gemAttrValueTab = self:getGemBaseAttrValue(posIndex);--宝石的基本属性
            attrValueTab2 = game_util:getCommanderCombatValue();--统帅能力
            attrValueTab3 = game_util:getAssistantCombatValue();--助威加的属性
            medalAttrValueTab = self:getMedalBaseAttrValue(posIndex);--勋章的基本属性
            soulAttrValueTab,soulPercentValueTab,soulAttrValueTab2 = self:getSoulBaseAttrValue(posIndex,cardData); --英魂基本属性
            -- cclog2(soulAttrValueTab,"soulAttrValueTab")
            -- universeCombatValue,universeAttrValueTab = game_util:getUniverseCombatValue(cardData.id,self.allUniverseEffect)--宇宙属性加成
            rolePropertryValueTab = game_util:getRolePropertryValue()
           
        end
        local cbmTab = game_util:getCombatBonusMultiplierByCfg(cardCfg,cardData.id);--连协属性
        if  cardData.fate_change and next(cardData.fate_change) then
            cbmTab = game_util:getCombatBonusMultiplierByCfg2(cardCfg,cardData.id);--连协刷新过的属性
        end
        local soulPercentCombatTab = {0,0,0,0,0};

        for i=1,5 do
            local abilityItem = PUBLIC_ABILITY_TABLE["ability_" .. i] or {}
            local attrValue = cardData[abilityItem.attrName or ""] or 0
            soulPercentCombatTab[i] = attrValue * soulPercentValueTab[i] * 0.01
            attrValueTab[i] = math.floor(equipAttrValueTab[i] + attrValueTab2[i] + attrValue*cbmTab[i] + gemAttrValueTab[i] + attrValueTab3[i] + petAttrValueTab[i] + medalAttrValueTab[i] + soulAttrValueTab[i] + soulAttrValueTab2[i] + universeAttrValueTab[i] + petFollowValueTab[i] + soulPercentCombatTab[i] + rolePropertryValueTab[i])
        end
        if cardData.bind_equip and next(cardData.bind_equip) then
            local fateTempValueTab = {0,0,0,0,0}
            local fateEquipData = {0,0,0,0,0}

            fateEquipData = game_util:getFateEquipValue(cardData.bind_equip)
            fateTempValueTab[5] = math.floor((attrValueTab[5] + cardData.hp) * fateEquipData[5]/100)
            fateTempValueTab[2] = math.floor((attrValueTab[2] + cardData.matk) * fateEquipData[2]/100)
            fateTempValueTab[3] = math.floor((attrValueTab[3] + cardData.def) * fateEquipData[3]/100)
            fateTempValueTab[4] = math.floor((attrValueTab[4] + cardData.speed) * fateEquipData[4]/100)
            fateTempValueTab[1] = math.floor((attrValueTab[1] + cardData.patk) * fateEquipData[1]/100)
            for i=1,5 do
                attrValueTab[i] = attrValueTab[i] + fateTempValueTab[i]
            end
        end

        self.m_life_label2:setString("+" .. attrValueTab[5])
        self.m_physical_atk_label2:setString("+" .. attrValueTab[1])
        self.m_magic_atk_label2:setString("+" .. attrValueTab[2])
        self.m_def_label2:setString("+" .. attrValueTab[3])
        self.m_speed_label2:setString("+" .. attrValueTab[4])

        local chainTab = game_util:cardChainByCfg(cardCfg,cardData.id)
        ---命运刷新todo
        if  cardData.fate_change and next(cardData.fate_change) then
            
             chainTab = game_util:cardChainByCfg2(cardCfg,cardData.id)
        end
   ---命运刷新todo  
        self.m_chainTab = chainTab;
        if #chainTab > 0 then
            local showStr = ""
            local nameStr = "";
            for i=1,#chainTab do
                showStr = showStr .. chainTab[i].detail .. "\n"
                nameStr = nameStr .. "    " .. chainTab[i].name .. (i == 3 and "\n" or "")
            end
            -- cclog("nameStr ======== " .. nameStr)
            -- print("showStr ======== " .. showStr)
            self.m_fate_label:setString(nameStr);
            -- self.m_fate_detail_label:setString(showStr)
            fate_detail_label_str = showStr;
        else
            self.m_fate_label:setString("Không có");
            -- self.m_fate_detail_label:setString("无")
        end
        if game_data:isViewShowByID(182) == true then
            if isFriendEquip and isFriendEquip == true then

                self:autoMatchFateEquip(self.m_selHeroId,posIndex,isFriendEquip)

            else
                self:autoMatchFateEquip(self.m_selHeroId,posIndex)
            end
        end

        self:refreshEquipPos(posIndex)
        self:refreshGemPos(posIndex)
        -- self:refreshMedalPos(posIndex)--勋章不显示，所以不用加
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
        self.m_fate_label:setString("Không có")
        -- self.m_fate_detail_label:setString("无")
        if self.m_teamIndex == 2 then
            self:setSelPositionBg(posIndex);
        end
        replaceStr = "Ra trận"
    end
    if self.m_teamIndex == 2 then
        self.m_adjust1:setVisible(true);
        self.m_adjust2:setVisible(false);
        local m_cost_title = self.m_ccbNode:spriteForName("m_cost_title")
        local m_cost_label = self.m_ccbNode:labelBMFontForName("m_cost_label")
        local m_cost_icon = self.m_ccbNode:spriteForName("m_cost_icon")
        local m_activation_btn = self.m_ccbNode:controlButtonForName("m_activation_btn")
        local m_attr_refresh_btn = self.m_ccbNode:controlButtonForName("m_attr_refresh_btn")
        local m_assistant_detail_node = self.m_ccbNode:labelTTFForName("m_assistant_detail_node")
        m_assistant_detail_node:removeAllChildrenWithCleanup(true)
        local dimensions = m_assistant_detail_node:getContentSize()
        m_cost_icon:setOpacity(0)
        local active_status = -1
        if posIndex ~= -1 then
            local assistantEffect = game_data:getAssistantEffect()
            local assistantEffectItem = assistantEffect[posIndex] or {}
            active_status = assistantEffectItem.active_status or "-1"  -- "-1"未激活 "0" 激活
            local assistant_cfg = getConfig(game_config_field.assistant);
            local assistant_cfg_item = assistant_cfg:getNodeWithKey(tostring(posIndex))
            local cardlimit = assistant_cfg_item:getNodeWithKey("cardlimit")
            cardlimit = cardlimit and cardlimit:toInt() or 0;
            local att_type = assistant_cfg_item:getNodeWithKey("att_type")
            att_type = att_type and att_type:toInt() or 0;
            local actlv = assistant_cfg_item:getNodeWithKey("actlv")
            actlv = actlv and actlv:toInt() or 0;
            local att_value = assistant_cfg_item:getNodeWithKey("att_value")
            att_value = att_value and att_value:toInt() or 0;
            local abilityItem = PUBLIC_ABILITY_TABLE["ability_" .. att_type] or {};
            local abilityName = tostring(abilityItem.name)
            local tipsStrTab,tipsStrTab2 = {},{}

            if active_status == "-1" then
                table.insert(tipsStrTab,string.format("激活等级：%d",actlv));
                table.insert(tipsStrTab,string.format("\n激活属性：%s+%d%%",abilityName,att_value));
                self.m_assistant_detail_label = game_util:createRichLabelTTF({text = table.concat(tipsStrTab),dimensions = dimensions,textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 8})
                self.m_assistant_detail_label:setAnchorPoint(ccp(0,0))
                m_assistant_detail_node:addChild(self.m_assistant_detail_label)
                self.m_scroll_view_tips:getContainer():removeAllChildrenWithCleanup(true)
            else
                local tempAssistantCardAttrValueTab = {}
                local attrIconAndInfoTab = {}
                local assAttrValueTab,_,_ = game_util:getAssistantAttrTab(posIndex, assistantEffectItem, assistant_cfg_item, false)
                for i=1,#assAttrValueTab do
                    local attrValueItem = assAttrValueTab[i]
                    local att_name = attrValueItem.att_name or ""
                    if att_name ~= "ability2" or (att_name == "ability2" and self.m_ability2OpenFlag) then
                        local temp_att_type = attrValueItem.att_type or 0
                        local abilityItem = PUBLIC_ABILITY_TABLE["ability_" .. temp_att_type]
                        if abilityItem and attrValueItem.open > 0 then
                            local temp_value,temp_att_value = 0,attrValueItem.att_value or 0
                            if att_name == "ability1" then
                                table.insert(tipsStrTab2,string.format("Đồng đội xuất chiến%s Đồng đội tăng trợ uy%s%.2f%%",abilityName,abilityName,temp_att_value));
                            end
                            if cardData then
                                temp_value = (attrValueTab[temp_att_type]+(cardData[tostring(abilityItem.attrName)] or 0))*temp_att_value*0.01
                                local evo = cardData.evo or 0--进阶
                                if evo > cardlimit then
                                    if tempAssistantCardAttrValueTab[att_type] == nil then
                                        tempAssistantCardAttrValueTab[att_type] = game_util:getAssistantCardAttrValue(cardData, cardCfg, temp_att_type, cardlimit)
                                    end
                                    temp_value = tempAssistantCardAttrValueTab[att_type]*temp_att_value*0.01
                                end
                            end
                            local tempStr = nil
                            if att_name == "card" then
                                if attrValueItem.active > 0 then
                                    if temp_att_type > 5 then
                                        tempStr = "[color=ff00ff00]+" .. tostring(math.floor(att_value)) .. "[/color](仅限[color=ffffdc00]" .. tostring(attrValueItem.character_name) .. "[/color])"
                                    else
                                        tempStr = "[color=ff00ff00]+" .. tostring(math.floor(temp_value)) .. "[/color](" .. tostring(attrValueItem.att_value) .. "%" .. ",仅限[color=ffffdc00]" .. tostring(attrValueItem.character_name) .. "[/color])"
                                    end
                                else
                                    if temp_att_type > 5 then
                                        tempStr = "[color=ff8A8A8A]+" .. tostring(math.floor(att_value)) .. "[/color](仅限[color=ff8A8A8A]" .. tostring(attrValueItem.character_name) .. "[/color])"
                                    else
                                        tempStr = "[color=ff8A8A8A]+" .. tostring(math.floor(temp_value)) .. "[/color](" .. tostring(attrValueItem.att_value) .. "%" .. ",仅限[color=ff8A8A8A]" .. tostring(attrValueItem.character_name) .. "[/color])"
                                    end
                                end
                            else
                                tempStr = "[color=ff00ff00]+" .. tostring(math.floor(temp_value)) .. "[/color](" .. tostring(temp_att_value) .. "%)"
                            end
                            if #tipsStrTab == 0 then
                                table.insert(tipsStrTab,tempStr)
                            else
                                table.insert(tipsStrTab,"\n" .. tempStr)
                            end
                            table.insert(attrIconAndInfoTab,{icon = tostring(abilityItem.icon),info = tempStr})
                        end
                    end
                end
                -- table.insert(tipsStrTab2,string.format("出战伙伴%s增加助威伙伴%s的%d%%",abilityName,abilityName,att_value));
                -- table.insert(tipsStrTab2,string.format("\n当前全体出战伙伴%s增加%d",abilityName,math.floor(temp_value)));    
                table.insert(tipsStrTab2,string.format("Vị trí này đồng đội chỉ phát huy thực lực Lv%d",cardlimit));
                local tempCount = #attrIconAndInfoTab
                local startY = dimensions.height*0.5 + 10*tempCount*0.5
                for i=1,tempCount do
                    local itemData = attrIconAndInfoTab[i]
                    local pY = startY - 10*i + 5
                    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(itemData.icon))
                    if tempSpriteFrame then
                        local tempIcon = CCSprite:createWithSpriteFrame(tempSpriteFrame)
                        tempIcon:setScale(0.5)
                        tempIcon:setPosition(ccp(-8,pY))
                        m_assistant_detail_node:addChild(tempIcon)
                    end
                    local m_assistant_detail_label = game_util:createRichLabelTTF({text = itemData.info,textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 8})
                    m_assistant_detail_label:setPosition(ccp(0,pY))
                    m_assistant_detail_label:setAnchorPoint(ccp(0,0.5))
                    m_assistant_detail_node:addChild(m_assistant_detail_label)
                end
                game_util:createScrollViewTips(self.m_scroll_view_tips,tipsStrTab2)
            end
            local activation = assistant_cfg_item:getNodeWithKey("activation")
            if activation and activation:getNodeCount() > 0 then
                local icon,name,count = game_util:getRewardByItem(activation:getNodeAt(0));
                if icon then
                    icon:ignoreAnchorPointForPosition(true)
                    m_cost_icon:addChild(icon)
                end
                m_cost_label:setString(tostring(count))
            end
        end
        m_cost_title:setVisible(active_status == "-1")
        m_cost_label:setVisible(active_status == "-1")
        m_cost_icon:setVisible(active_status == "-1")
        m_activation_btn:setVisible(active_status == "-1")
        if active_status == "-1" then
            -- self.m_scroll_view_tips:setPosition(ccp(0,0))
            -- m_assistant_detail_label:setPosition(ccp(0,0))
        else
            -- self.m_scroll_view_tips:setPosition(ccp(20,-15))
            -- m_assistant_detail_label:setPosition(ccp(0,-12))
        end
        m_attr_refresh_btn:setVisible(active_status ~= "-1")
    end
    game_util:setCCControlButtonTitle(self.m_replace_btn,replaceStr)
    local labelsize = self.m_fate_detail_node:getContentSize();
    self.m_oneFateScrollView:getContainer():removeAllChildrenWithCleanup(true);
    self.m_fate_detail_label = game_util:createRichLabelTTF({text = fate_detail_label_str,dimensions = CCSizeMake(labelsize.width, 0),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = nil,color = ccc3(221,221,192)})
    self.m_fate_detail_label:setAnchorPoint(ccp(0, 0));
    self.m_oneFateScrollView:addChild(self.m_fate_detail_label)
    local contentSize = self.m_fate_detail_label:getContentSize();
    self.m_oneFateScrollView:setContentSize(CCSizeMake(contentSize.width, math.max(contentSize.height,labelsize.height)));
    if contentSize.height < labelsize.height then
        self.m_fate_detail_label:setPosition(ccp(0, labelsize.height - contentSize.height));
        self.m_oneFateScrollView:setContentOffset(ccp(0, 0),false)
    else
        self.m_oneFateScrollView:setContentOffset(ccp(0, labelsize.height - contentSize.height),false)
    end

end
function game_guild_adjustment_formation.autoMatchFateEquip( self,heroId,posIndex,isFriendEquip )
    local cardData,cardCfg = game_data:getCardDataById( heroId );
    if not cardCfg then return end
    local curPosEquip = self.m_tempEquipPosData[tonumber(posIndex)]
    local recommendEquip = {"0","0","0","0"}
    local recommendEquipData = {}
    local equipTable = game_data:getEquipIdTable()
    local equipCfg = getConfig(game_config_field.equip);
    local existFlag,cardName, pos = true, nil, nil
    local itemData, itemCfg = nil, nil
    local toNilFlag = false
    local tempTab = {1,1,1,1}
    local tempEquipPosData = {}
    if isFriendEquip and isFriendEquip == true then
        tempEquipPosData = self.m_tempAssEquipPosData
        posIndex = tostring(posIndex + 99)
    else
        tempEquipPosData = self.m_tempEquipPosData
    end
    -- cclog2(posIndex,"posIndex ====")
    if cardData.bind_equip and next(cardData.bind_equip) then
        -- cclog2(cardData.bind_equip,"cardData.bind_equip[i]==== ")
        for i=1,4 do
            if cardData.bind_equip[i] ~= 0 then
                tempEquipPosData[posIndex][i] = cardData.bind_equip[i]
            else
                local equipData = game_data:getEquipDataById(curPosEquip[i])
                if equipData and equipData.bind_card and equipData.bind_card ~= ""  then
                    -- cclog2(equipData.bind_card,"equipData.bind_card ===")
                    -- cclog2(cardData.id,"cardData.id ===")
                    if equipData.bind_card ~= cardData.id then
                        tempEquipPosData[posIndex][i] = "0"
                    end
                else
                end
            end
        end
    else
        for sort,Id in pairs(curPosEquip) do
            local equipData = game_data:getEquipDataById(Id)
            if equipData and equipData.bind_card and equipData.bind_card ~= ""  then
                if equipData.bind_card ~= cardData.id then
                    tempEquipPosData[posIndex][sort] = "0"
                end
            else
            end
        end
    end
    self.m_chainTabBackUp = self.m_chainTab == nil and nil or util.table_copy(self.m_chainTab)
    self:newChainOpenAnim("equip");
end
--[[
    刷新装备
]]
function game_guild_adjustment_formation.refreshEquipPos(self,posIndex)
    if posIndex and posIndex > 0 and posIndex < 10 then
        local tempNode = nil;
        local equipPosData = nil
        if self.m_teamIndex == 1 then
            equipPosData = self.m_tempEquipPosData[posIndex]
        elseif self.m_teamIndex == 2 then
            equipPosData = self.m_tempAssEquipPosData[tostring(posIndex+99)]
        end
        for k,v in pairs(equipPosData) do
            if v ~= "0" then
                local equipItemData =  game_data:getEquipDataById(v);
                if equipItemData.bind_card and equipItemData.bind_card ~= "" then
                    if equipItemData.bind_card ~= self.m_selHeroId then
                        equipPosData[k] = "0"
                    end
                end
            end

        end

        if equipPosData then
            -- cclog("posIndex == " .. posIndex .. " ; equipPosData ======= " .. json.encode(equipPosData))
            local noUseEquipCountTab = game_data:getNoUseEquipCountTab();
            for i=1,4 do
                tempNode = self.m_ccbNode:spriteForName("m_equip_" .. i)
                local  guyongEquipData = {}  
                if tempNode then
                    local tempNodeSize = tempNode:getContentSize();
                    if game_util:getTableLen(equipPosData) == 5 and next(self.m_tab_guyongEquip) then
                        guyongEquipData = self.m_tab_guyongEquip[tostring(posIndex)][i]
                    end
                    local id = equipPosData[i];
                    if next(guyongEquipData) then
                        id = guyongEquipData[1]
                    end
                    if id and tostring(id) ~= "0" then
                        local  equipItemCfg,equipItemData ={},{}
                        local equipLv = -1
                        if next(guyongEquipData) then
                            equipLv = guyongEquipData[2]
                            local equipCfg = getConfig(game_config_field.equip);
                            equipItemCfg = equipCfg:getNodeWithKey(tostring(id));
                        else
                            equipItemData,equipItemCfg = game_data:getEquipDataById(tostring(id));
                        end
                        local equipIcon = game_util:createEquipIcon(equipItemCfg);
                        if equipIcon then
                            equipIcon:setPosition(ccp(tempNodeSize.width*0.5,tempNodeSize.height*0.5))
                            tempNode:addChild(equipIcon,10,10)
                            if self.m_selEquipId == id then
                                equipIcon:setScale(2.0);
                                local animArr = CCArray:create();
                                animArr:addObject(CCSpawn:createWithTwoActions(CCEaseIn:create(CCScaleTo:create(0.5,1.0),5),CCFadeIn:create(0.5)));
                                animArr:addObject(CCScaleTo:create(0.1,1.2));
                                animArr:addObject(CCScaleTo:create(0.1,1.0));
                                equipIcon:runAction(CCSequence:create(animArr));
                                self.m_selEquipId = nil;
                            end
                            if equipItemData.bind_card and equipItemData.bind_card ~= "" then
                                local temp = CCSprite:createWithSpriteFrameName("public_icon_ming.png")
                                local tempSize = equipIcon:getContentSize()
                                temp:setPosition(ccp(tempSize.width-5,tempSize.height-5))
                                equipIcon:addChild(temp,10,10)
                            end
                        end
                        if equipItemData then
                            local tempLabel = nil
                            if equipLv ~= -1 then
                                tempLabel = game_util:createLabelTTF({text = "Lv." .. equipLv,color = ccc3(250,255,0),fontSize = 16});
                            else
                                tempLabel = game_util:createLabelTTF({text = "Lv." .. equipItemData.lv,color = ccc3(250,255,0),fontSize = 16});

                            end
                            tempLabel:setPosition(ccp(tempNodeSize.width*0.5,-tempNodeSize.height*0.15))
                            tempNode:addChild(tempLabel,11,11)
                        else
                            -- cclog("equipIndex == " .. i .. " ; equipId == " .. tostring(id));
                        end
                    else
                        if noUseEquipCountTab[i] > 0 then
                            local tempSpri = CCSprite:createWithSpriteFrameName("public_kezhuangbei.png")
                            tempSpri:setPosition(ccp(tempNodeSize.width*0.5,tempNodeSize.height*0.5))
                            tempNode:addChild(tempSpri,10,10)
                            tempSpri:setVisible(false)
                        end
                        if i == 1 then
                            local id = game_guide_controller:getCurrentId();
                            if id == 31 then
                                self.m_guide_step = 31
                                game_guide_controller:gameGuide("show","2",32,{tempNode = tempNode})
                            end
                        end
                    end
                end
            end
        end
    end 
end

--[[
    刷新装备
]]
function game_guild_adjustment_formation.refreshGemPos(self,posIndex)
    if posIndex and posIndex > 0 and posIndex < 10 then
        local tempNode = nil;
        local gemPosData = self.m_tempGemPosData[posIndex]
        if gemPosData then
            -- cclog("posIndex == " .. posIndex .. " ; gemPosData ======= " .. json.encode(gemPosData))
            local noUseGemCountTab = game_data:getNoUseGemCountTab();
            for i=1,4 do
                tempNode = self.m_ccbNode:spriteForName("m_equip_" .. (4+i))  
                if tempNode then
                    local tempNodeSize = tempNode:getContentSize();
                    local id = gemPosData[i];
                    if id and tostring(id) ~= "0" then
                        -- local tempItemData,tempItemCfg = game_data:getGemDataById(tostring(id));
                        -- local tempIcon = game_util:createGemIconByCfg(tempItemCfg);
                        local tempIcon,gemName = game_util:createGemIconByCid(id);
                        if tempIcon then
                            tempIcon:setPosition(ccp(tempNodeSize.width*0.5,tempNodeSize.height*0.5))
                            tempNode:addChild(tempIcon,10,10)
                            if self.m_selGemPos == i then
                                tempIcon:setScale(2.0);
                                local animArr = CCArray:create();
                                animArr:addObject(CCSpawn:createWithTwoActions(CCEaseIn:create(CCScaleTo:create(0.5,1.0),5),CCFadeIn:create(0.5)));
                                animArr:addObject(CCScaleTo:create(0.1,1.2));
                                animArr:addObject(CCScaleTo:create(0.1,1.0));
                                tempIcon:runAction(CCSequence:create(animArr));
                                self.m_selGemPos = nil;
                            end
                        end
                        if gemName then
                            local tempLabel = game_util:createLabelTTF({text = gemName,color = ccc3(250,255,0),fontSize = 16});
                            tempLabel:setPosition(ccp(tempNodeSize.width*0.5,-tempNodeSize.height*0.15))
                            tempNode:addChild(tempLabel,11,11)
                        else
                            -- cclog("equipIndex == " .. i .. " ; equipId == " .. tostring(id));
                        end
                    else
                        if noUseGemCountTab[i] > 0 then
                            local tempSpri = CCSprite:createWithSpriteFrameName("public_kezhuangbei.png")
                            tempSpri:setPosition(ccp(tempNodeSize.width*0.5,tempNodeSize.height*0.5))
                            tempNode:addChild(tempSpri,10,10)
                        end
                        -- if i == 1 then
                        --     local id = game_guide_controller:getCurrentId();
                        --     if id == 31 then
                        --         game_guide_controller:gameGuide("show","2",32,{tempNode = tempNode})
                        --     end
                        -- end
                    end
                end
            end
        end
    end 
end
--判断该装备是否可以命运装备绑定
function game_guild_adjustment_formation.fateEquipLock(self,itemData)
    local fateEquipId = string.sub(itemData.c_id,1,3)
    if tonumber(itemData.c_id) > 100100 then
        fateEquipId = string.sub(itemData.c_id,1,4)
    end
    local fateEquipLock = false
    if self.m_selHeroId then
        local heroData,heroCfg = game_data:getCardDataById(self.m_selHeroId)
        local chain_cfg = getConfig(game_config_field.chain);
        local chain = heroCfg:getNodeWithKey("chain")
        local chainCount = chain:getNodeCount();
        for i=1,chainCount do
            local chainId = chain:getNodeAt(i-1):toStr();
            local chainItemCfg = chain_cfg:getNodeWithKey(chainId);
            local equip_cfg = getConfig(game_config_field.equip);
            if chainItemCfg then
                local data = chainItemCfg:getNodeWithKey("data")
                local dataCount = data:getNodeCount();
                local condition_sort = chainItemCfg:getNodeWithKey("condition_sort"):toInt();
                if dataCount > 0 then
                    if condition_sort == 1 then
                        for i=1,dataCount do
                            local itemCfg = equip_cfg:getNodeWithKey(data:getNodeAt(i-1):toStr())
                            if itemCfg then
                                itemCfg = json.decode(itemCfg:getFormatBuffer())
                                local chain_id = itemCfg.chain_id
                                if chain_id == tonumber(fateEquipId) then
                                    fateEquipLock = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return fateEquipLock
end
--[[--
    装备层
]]
function game_guild_adjustment_formation.initEquipLayerTouch(self,formation_layer)
 
end

--[[--
    
]]
function game_guild_adjustment_formation.judgeAddHero(self,posIndex)
    local cardNumData = game_data:getBattleCardNumData()
    local maxCount1,maxCount2 = cardNumData.position_num or 2,cardNumData.alternate_num or 0;
    local returnValue = 0;
    if self.m_openTab[posIndex] == 0 then
        returnValue = 5;
        game_util:addMoveTips({text = string_config:getTextByKey("m_team_pos_no_open")});
        return returnValue;
    end
    local count1,count2 = 0,0;
    local cardId = nil;
    for i=1,6 do
        cardId = self.m_tempTeamData[i]
        if cardId ~= "-1" then
            count1 = count1 + 1;
        end
    end
    for i=7,9 do
        cardId = self.m_tempTeamData[i]
        if cardId ~= "-1" then
            count2 = count2 + 1;
        end
    end
    if posIndex < 7 then
        count1 = count1 + 1;
    else
        count2 = count2 + 1;
    end
    if count1 > maxCount1 or count1 > 5 then
        returnValue = 2;
        game_util:addMoveTips({text = string_config:getTextByKey("m_master_is_max")});
    elseif count2 > maxCount2 then
        returnValue = 3;
        game_util:addMoveTips({text = string_config:getTextByKey("m_substitute_is_max")});
    end
    return returnValue;
end

--[[--
    
]]
function game_guild_adjustment_formation.addTeamHeroPop(self,posIndex)
    game_scene:removeGuidePop();
    if self.m_tempTeamData[posIndex] == "-1" then
        -- cclog("--------addTeamHeroPop--11-----")
        -- cclog2(posIndex,"posIndex ----")
        if self:judgeAddHero(posIndex) == 0 then
            self:addSelHeroUi(posIndex);
        end
    else
        -- cclog("--------addTeamHeroPop--2-----")

        self.m_posIndex = posIndex;
        self:refreshHeroInfo(posIndex);
    end
end

--[[--
    
]]
function game_guild_adjustment_formation.addSelHeroUi(self,posIndex)

end


--[[--
    
]]
function game_guild_adjustment_formation.newChainOpenAnim(self,typeName)
    local animFlag = false;
    local chainTabBackUp = self.m_chainTabBackUp
    local chainNameTab = {};
    if typeName == "card" then
        if chainTabBackUp and #chainTabBackUp > 0 then
            for i=1,#chainTabBackUp do
                if chainTabBackUp[i].openFlag == true then
                    animFlag = true
                    table.insert(chainNameTab,tostring(chainTabBackUp[i].nameExt))
                end
            end
        end
    else
        local chainTab = self.m_chainTab;
        if chainTab and #chainTab and #chainTabBackUp > 0 and #chainTabBackUp > 0 then
            for i=1,#chainTabBackUp do
                if chainTab[i] and chainTab[i].openFlag == true and chainTabBackUp[i] and chainTabBackUp[i].openFlag == false then
                    animFlag = true
                    table.insert(chainNameTab,tostring(chainTabBackUp[i].nameExt))
                end
            end
        end
    end
    if animFlag == true then
        -- 粒子效果
        local function particleMoveEndCallFunc()
            self:refreshCombatLabel("newChainOpenAnim true");
        end
        local tempParticle = game_util:createParticleSystemQuad({fileName = "particle_fly_up"});
        if tempParticle then
            if self.m_fate_label:isVisible() == true then
                game_util:addMoveAndRemoveAction({node = tempParticle,startNode = self.m_fate_node,endNode = self.m_combat_label,endCallFunc = particleMoveEndCallFunc,moveTime = 0.5,delayTime = 0.5})
            else
                game_util:addMoveAndRemoveAction({node = tempParticle,startNode = self.m_fate_detail_node,endNode = self.m_combat_label,endCallFunc = particleMoveEndCallFunc,moveTime = 0.5,delayTime = 0.5})
            end
            game_scene:getPopContainer():addChild(tempParticle)
        else
            particleMoveEndCallFunc();
        end
        --提示有新的命运开启 chainNameTab 新命运 名称列表
        for i =1,#chainNameTab do  
            local delayTime = (i - 1) * 1.7
            game_util:addQueneOpenTips({text = "Mở vận mệnh <" .. chainNameTab[i] .. "> "},delayTime)
        end
        
    else
        self:refreshCombatLabel("newChainOpenAnim false");
    end
end

--[[--
    判断是否装备上
]]
function game_guild_adjustment_formation.equipInEquipPos(self,equipType,equipId)
    local existFlag = false;
    local posIndex = -1;
    local posType = 1
    if equipType then
        for i=1,9 do
            if self.m_tempEquipPosData[i][equipType] == equipId then
                posIndex = i;
                existFlag = true
                break;
            end
            if self.m_tempAssEquipPosData[tostring(i+99)][equipType] == equipId then
                posIndex = i;
                existFlag = true
                posType = 2
                break;
            end
        end
    end
    return existFlag,posIndex,posType
end

--[[--
    获得位置上的装备ID
]]
function game_guild_adjustment_formation.getPosEquipId(self,equipPos,equipType)
    local tempEquipId = "0";
    if self.m_tempEquipPosData[equipPos] then
        tempEquipId = self.m_tempEquipPosData[equipPos][equipType]
    end
    return tempEquipId;
end

--[[--
    设置阵型相应位置装备数据
]]
function game_guild_adjustment_formation.updateEquipPosData(self,equipPos,equipType,equipId)
    if equipPos > 9 or equipPos < 0 or equipType > 4 or equipType < 1 then return end
    -- cclog("updateEquipPosData equipPos = " .. equipPos .. " ; equipType = " .. equipType .. " ; equipId = " .. equipId);
    self.m_tempEquipPosData[equipPos][equipType] = tostring(equipId);
    -- cclog("updateEquipPosData = " .. json.encode(self.m_tempEquipPosData))
    self:setTeamFormationData();
end

function game_guild_adjustment_formation.exchangeEquipPosDataByTwoPos(self,posIndex1,posIndex2,equipType)
    if posIndex1 == posIndex2 then return end
    if posIndex1 > 9 or posIndex1 < 0 or posIndex2 > 9 or posIndex2 < 0 or equipType > 4 or equipType < 1 then return end
    -- cclog("exchangeEquipPosDataByTwoPos posIndex1 = " .. posIndex1 .. " ; posIndex2 == " .. posIndex2);
    self.m_tempEquipPosData[posIndex1][equipType],self.m_tempEquipPosData[posIndex2][equipType] = self.m_tempEquipPosData[posIndex2][equipType],self.m_tempEquipPosData[posIndex1][equipType]
    self:setTeamFormationData();
end

--[[

]]
function game_guild_adjustment_formation.exchangeTeamAndAssEquipPosDataByTwoPos(self,posIndex1,posIndex2,equipType)
    if posIndex1 > 9 or posIndex1 < 0 or posIndex2 > 9 or posIndex2 < 0 or equipType > 4 or equipType < 1 then return end
    posIndex2 = tostring(posIndex2+99)
    self.m_tempEquipPosData[posIndex1][equipType],self.m_tempAssEquipPosData[posIndex2][equipType] = self.m_tempAssEquipPosData[posIndex2][equipType],self.m_tempEquipPosData[posIndex1][equipType]
    self:setTeamFormationData()
end

-------------------------------------------------------------------------
--[[--
    判断宝石是否装备上
]]
function game_guild_adjustment_formation.gemInGemPos(self,tempType,tempId)
    -- cclog("tempType ====== " .. tostring(tempType) .. " ; tempId ==== " .. tostring(tempId))
    local existFlag = false;
    local posIndex = -1;
    if tempType then
        for i=1,9 do
            if self.m_tempGemPosData[i][tempType] == tempId then
                posIndex = i;
                existFlag = true
                break;
            end
        end
    end
    return existFlag,posIndex;
end

--[[--
    获得位置上的宝石ID
]]
function game_guild_adjustment_formation.getPosGemId(self,tempPos,tempType)
    local tempEquipId = 0;
    if self.m_tempGemPosData[tempPos] then
        tempEquipId = self.m_tempGemPosData[tempPos][tempType]
    end
    return tempEquipId;
end

--[[--
    设置阵型相应位置宝石数据
]]
function game_guild_adjustment_formation.updateGemPosData(self,tempPos,tempType,tempId)
    if tempPos > 9 or tempPos < 0 or tempType > 4 or tempType < 1 then return end
    cclog("updateGemPosData tempPos = " .. tempPos .. " ; tempType = " .. tempType .. " ; tempId = " .. tempId);
    local posGemId = tostring(self.m_tempGemPosData[tempPos][tempType]);
    tempId = tostring(tempId);
    game_data:addGemDataByCid(posGemId,1)
    game_data:minusGemDataCid(tempId,1)
    self.m_tempGemPosData[tempPos][tempType] = tempId;
    -- cclog("updateGemPosData = " .. json.encode(self.m_tempGemPosData))
    self:setTeamFormationData();
end

function game_guild_adjustment_formation.exchangeGemPosDataByTwoPos(self,posIndex1,posIndex2,tempType)
    if posIndex1 == posIndex2 then return end
    if posIndex1 > 9 or posIndex1 < 0 or posIndex2 > 9 or posIndex2 < 0 or tempType > 4 or tempType < 1 then return end
    -- cclog("exchangeGemPosDataByTwoPos posIndex1 = " .. posIndex1 .. " ; posIndex2 == " .. posIndex2);
    self.m_tempGemPosData[posIndex1][tempType],self.m_tempGemPosData[posIndex2][tempType] = self.m_tempGemPosData[posIndex2][tempType],self.m_tempGemPosData[posIndex1][tempType]
    self:setTeamFormationData();
end

-------------------------------------------------------------------------

--[[--
    获得阵型相关的数据
]]
function game_guild_adjustment_formation.setTeamFormationData(self)
    local formationId = 1;
    local tempTeamData = {};
    local tempEquipPosData = {};
    local tempGemPosData = {};
    local tempMedalPosData = {}
    local tempSoulPosData = {}
    local emptyFlag = false;
    local tempCardId = nil;
    local tempEquipItem,tempGemItem,tempMedalItem,tempSoulItem = nil,nil,nil,nil

    local tempCount = 1;
    for i=1,9 do
        tempCardId = self.m_tempTeamData[i]
        -- tempEquipItem = self.m_tempEquipPosData[i];
        -- tempGemItem = self.m_tempGemPosData[i];
        -- tempMedalItem = self.m_tempMedalPosData[i]
        -- tempSoulItem = self.m_tempSoulPosData[i]
        if i < 7 then
            if tempCardId == "-1" and emptyFlag == false then
                emptyFlag = true;
                formationId = i;
            else
                if tempCount < 7 then
                    tempTeamData[tempCount] = tempCardId
                    -- tempEquipPosData[tostring(tempCount-1)] = util.table_copy(tempEquipItem);
                    -- tempGemPosData[tostring(tempCount-1)] = util.table_copy(tempGemItem);
                    -- tempMedalPosData[tostring(tempCount-1)] = util.table_copy(tempMedalItem)
                    -- tempSoulPosData[tostring(tempCount-1)] = util.table_copy(tempSoulItem)
                    tempCount = tempCount + 1;
                end
            end
        else
            tempTeamData[tempCount] = tempCardId
            -- tempEquipPosData[tostring(tempCount-1)] = util.table_copy(tempEquipItem);
            -- tempGemPosData[tostring(tempCount-1)] = util.table_copy(tempGemItem);
            -- tempMedalPosData[tostring(tempCount-1)] = util.table_copy(tempMedalItem);
            -- tempSoulPosData[tostring(tempCount-1)] = util.table_copy(tempSoulItem)
            tempCount = tempCount + 1;
        end
    end
    for i=9,10 do
        tempTeamData[i] = "-1";
        -- tempEquipPosData[tostring(i-1)] = {"0","0","0","0"}
        -- tempGemPosData[tostring(i-1)] = {"0","0","0","0"}
        -- tempMedalPosData[tostring(i-1)] = {"0","0","0","0","0","0"}
        -- tempSoulPosData[tostring(i-1)] = {"0","0","0","0","0","0"}
    end

    cclog("formationId ================== " .. formationId)
    self.m_selFormationId = formationId;
    game_data:setGuildSelTeamId(tempTeamData);

end

function game_guild_adjustment_formation.exchangeEquipPosAlert(self,posIndex,currPos,sort,id,posType)
end

--[[--
    
]]
function game_guild_adjustment_formation.addSelEquipUi(self,posIndex,sort)
end
--[[
    
]]
function game_guild_adjustment_formation.exchangeGemPosAlert(self,posIndex,currPos,sort,id)
    if posIndex == currPos then 
        game_util:addMoveTips({text = "该宝石在此位置上！"});
        return 
    end
    local tempText = nil;
    local itemData,itemCfg = self:getTeamCardDataByPos(currPos)
    if itemData and itemCfg then
        tempText = "该宝石正在被" .. itemCfg:getNodeWithKey("name"):toStr() .. "使用,确定更换吗？"
    else
        tempText = "该宝石正在其他位置上使用,确定更换吗？"
    end
    local t_params = 
    {
        title = string_config.m_title_prompt,
        okBtnCallBack = function(target,event)
            self.m_selGemPos = currPos;
            game_scene:removePopByName("gem_system_select_pop");
            game_util:closeAlertView();
            self:exchangeGemPosDataByTwoPos(posIndex,currPos,sort);
            self.m_changeFlag = true;
            self:addTeamHeroPop(posIndex);
        end,   --可缺省
        okBtnText = "宝石更换",       --可缺省
        text = tempText,      --可缺省
    }
    game_util:openAlertView(t_params);
end

--[[--
    
]]
function game_guild_adjustment_formation.addSelGemUi(self,posIndex,sort)
    game_scene:removeGuidePop();
    cclog("addSelGemUi posIndex ==" .. tostring(posIndex) .. " ; sort = " .. tostring(sort))
    local btnCallFunc = function( target,event )
    end
    local itemOnClick = function (typeName,id)
        if typeName == "exchanged" then
            if id then
                local gemCount,_ = game_data:getGemDataById(id);
                if gemCount < 0 then
                    self:exchangeGemPosAlert(posIndex,currPos,sort,id);
                else
                    self.m_selGemPos = sort;
                    game_scene:removePopByName("gem_system_select_pop");
                    cclog("itemOnClick changed id ==================== " .. id);
                    self:updateGemPosData(posIndex,sort,id);
                    self.m_changeFlag = true;
                    self:addTeamHeroPop(posIndex);
                    self:refreshCombatLabel("addSelGemUi exchanged");
                end
            end
        elseif typeName == "unload" then
            self:updateGemPosData(posIndex,sort,"0");
            cclog("itemOnClick remove id ==================== ");
            self.m_changeFlag = true;
            self:addTeamHeroPop(posIndex);
            self:refreshCombatLabel(" addSelGemUi unload ");
        end
    end
    game_scene:addPop("gem_system_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,sortBtnShow = false,selSort = sort,openType = 2})
end

--[[--
    刷新ui
]]
function game_guild_adjustment_formation.refreshCombatLabel(self,source)
    -- cclog2(source,"source ===========")
  

    -- cclog2(self.m_tempCombatValue,"self.m_tempCombatValue==== ")
    if self.m_tempCombatValue == nil then
        self.m_tempCombatValue = game_util:getGuildCombatValue()
        self.m_combatNumberChangeNode:setCurValue(self.m_tempCombatValue,false);
    else
        local tempCombatValue = game_util:getGuildCombatValue();
        local changeValue = tempCombatValue - self.m_tempCombatValue
        -- cclog2(changeValue,"--------changeValue--------")
        self.m_tempCombatValue = tempCombatValue;
        game_util:combatChangedValueAnim({combatNode = self.m_combatNumberChangeNode,currentValue = tempCombatValue,changeValue = changeValue});
    end
end

--[[--
    刷新ui
]]
function game_guild_adjustment_formation.refreshUi(self)
    self:initTeamFormation(self.m_formation_layer);
    self:refreshCombatLabel("refreshUi");
    local id = game_guide_controller:getCurrentId();
    if id ~= 30 then
        if self.m_posIndex ~= -1 then
            self:refreshHeroInfo(self.m_posIndex);
        else
            self.m_posIndex = self.m_tempSelIndex;
            self:refreshHeroInfo(self.m_tempSelIndex);
        end
    end
end

--[[--
    初始化
]]
function game_guild_adjustment_formation.init(self,t_params)
    t_params = t_params or {};
    self.m_teamPosNodeTab = {};
    -- body
    self.m_bossId = t_params.bossId or 1

    local testTab2 = game_util:getGuildCurFormationId()
    self.m_openType = t_params.openType or self.m_openType;
    cclog2(t_params.changeFlag,"t_params.changeFlag")
    -- self.m_changeFlag = t_params.changeFlag or false
    self.m_posIndex = -1;
    self.m_tempSelIndex = -1;
    self.m_tempTeamData = {};
    self.m_tempFriendData = {};
    self.m_tempEquipPosData = {};
    self.m_tempGemPosData = {};
    self.m_tempMedalPosData = {};
    self.m_tempSoulPosData = {};
    self.m_zhuanshiData = t_params.zhuanshiData or {}
    local formationData = game_data:getFormationData();
    local ownFormation = formationData.own
    local ownFormationCount = #ownFormation
    self.m_currentFormationId = formationData.current
    cclog("self.m_currentFormationId=====" .. self.m_currentFormationId);
    self.m_selFormationId = self.m_currentFormationId;

    local teamData = {"-1","-1","-1","-1","-1","-1","-1","-1","-1","-1"}
    for i=1,#testTab2 do
        teamData[i] = testTab2[i]
    end
    local friendData = game_data:getAssistant();
    local tempEquipPosData = game_data:getEquipPosData()
    local tempGemPosData = game_data:getGemPosData();
    local tempMedalPosData = game_data:getMedalPos()
    local tempSoulPosData = game_data:getSoulPos()
    local formationConfig = getConfig(game_config_field.formation);
    local itemCfg = formationConfig:getNodeWithKey(tostring(self.m_selFormationId));
    local tempTag = 1;
    local iValue = nil;
    if itemCfg ~= nil then
        for i=1,#formationPosTab do
            local formationPosTabItem = formationPosTab[i];
            iValue = itemCfg:getNodeWithKey(formationPosTabItem.key):toInt();
            if iValue ~= 0 and tempTag < 7 then
                self.m_tempTeamData[i] = teamData[tempTag]
                self.m_tempEquipPosData[i] = util.table_copy(tempEquipPosData[tostring(tempTag-1)]);
                self.m_tempGemPosData[i] = util.table_copy(tempGemPosData[tostring(tempTag-1)]);
                self.m_tempMedalPosData[i] = util.table_copy(tempMedalPosData[tostring(tempTag-1)])
                self.m_tempSoulPosData[i] = util.table_copy(tempSoulPosData[tostring(tempTag-1)])
                tempTag = tempTag + 1;
            else
                self.m_tempTeamData[i] = "-1";
                self.m_tempEquipPosData[i] = {"0","0","0","0"}
                self.m_tempGemPosData[i] = {"0","0","0","0"}
                self.m_tempMedalPosData[i] = {"0","0","0","0","0","0"}
                self.m_tempSoulPosData[i] = {"0","0","0","0","0","0"}
            end
        end
    end
    for i=6,8 do
        self.m_tempTeamData[i+1] = teamData[i];
        self.m_tempEquipPosData[i+1] = util.table_copy(tempEquipPosData[tostring(i-1)]);
        self.m_tempGemPosData[i+1] = util.table_copy(tempGemPosData[tostring(i-1)]);
        self.m_tempMedalPosData[i+1] = util.table_copy(tempMedalPosData[tostring(i-1)])
        self.m_tempSoulPosData[i+1] = util.table_copy(tempSoulPosData[tostring(i-1)])
    end
    self.m_tempFriendData = friendData;
    self.m_tempDestinyData = game_data:getDestiny();
    self.m_tempAssEquipPosData = game_data:getAssEquipPosData()

    local cardNumData = game_data:getBattleCardNumData()
    local maxCount1,maxCount2 = cardNumData.position_num or 2,cardNumData.alternate_num or 0;
    self.m_openTab = TEAM_POS_OPEN_TAB["open" .. maxCount1 .. maxCount2] or {};
    self.m_tempSelIndex = -1;
    self.m_tempCombatValue = nil;
    self.m_teamIndex = 1;
    self.allUniverseEffect = game_util:getAllUniverseEffect()
    self.m_tempEquipPosData = self:getCurEquipData()
end
function game_guild_adjustment_formation.getCurEquipData( self )
    self.m_tab_guyongEquip = {}

    local posEquipData = game_data:getEquipPosData()
    local curEquipTab,smallTab = {},{}
    for k,v in pairs(self.m_tempTeamData) do
        local cardData = game_data:getGuildCardDataById(v)
        if cardData then
            if cardData.pos then
                if cardData.uid then
                    -- cclog2(cardData,"cardData ============")
                    curEquipTab[tonumber(k)] = {"0","0","0","0","0"} --雇佣的卡的装备数据长度为5，只为了区别自己的卡，最后一位没实际意义
                    if cardData.equips then
                        self.m_tab_guyongEquip[tostring(k)] = cardData.equips
                    end
                else
                    if cardData.pos < 6 then
                        curEquipTab[tonumber(k)] = posEquipData[tostring(cardData.pos-1)]
                    elseif cardData.pos >5 then
                        if cardData.pos <10 then
                            curEquipTab[tonumber(k)] = posEquipData[tostring(cardData.pos-1)]
                        else
                            curEquipTab[tonumber(k)] = posEquipData[tostring(cardData.pos-6)]
                        end
                    end
                end
            end
        else
            curEquipTab[tonumber(k)] = {"0","0","0","0"}
        end
    end 
    return curEquipTab
    -- body
end
--[[--
    创建ui入口并初始化数据
]]
function game_guild_adjustment_formation.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    local id = game_guide_controller:getCurrentId();
    if id == 19 and self.m_guildNode then
        game_guide_controller:gameGuide("show","1",20,{tempNode = self.m_guildNode})
    elseif id == 30 and self.m_guildNode then
        if game_data.setGuideProcess then game_data:setGuideProcess("guide_second") end
        game_guide_controller:gameGuide("show","2",31,{tempNode = self.m_guildNode})
    elseif id == 47 and self.m_guildNode then
        game_guide_controller:gameGuide("show","3",48,{tempNode = self.m_guildNode})
    elseif id == 50 then
        game_guide_controller:gameGuide("show","3",50,{tempNode = self.m_guildNode})
    else
        if game_guide_controller:getFormationGuideIndex() == 2 then
            cclog("game_guide_controller:getFormationGuideIndex() == 2")
            game_guide_controller:setFormationGuideIndex(3)
            local function onTouch(eventType, x, y)
                if eventType == "began" then
                    return true;--intercept event
                end
            end
            self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
            self.m_root_layer:setTouchEnabled(true);
            local startNode = self.m_ccbNode:spriteForName("m_pos_5")
            local endNode = self.m_ccbNode:spriteForName("m_pos_3")
            local yindao_shouzhi = game_util:createImpactAnim("yindao_shouzhi",1)
            yindao_shouzhi:pause();
            local pX,pY = startNode:getPosition();
            local startPos = startNode:getParent():convertToWorldSpace(ccp(pX,pY));
            local pX,pY = endNode:getPosition();
            local endPos = endNode:getParent():convertToWorldSpace(ccp(pX,pY));
            local animCount = 0;
            local function moveFunc()
                local function animCallbackFunc(node)
                    if animCount == 0 then
                        moveFunc();
                        self.m_root_layer:setTouchEnabled(false);
                    elseif animCount == 3 then
                        yindao_shouzhi:removeFromParentAndCleanup(true);
                    else
                        moveFunc();
                    end
                    animCount = animCount + 1;
                end
                yindao_shouzhi:setPosition(startPos);
                local animArr = CCArray:create();
                animArr:addObject(CCMoveTo:create(1,endPos));
                animArr:addObject(CCCallFuncN:create(animCallbackFunc));
                yindao_shouzhi:runAction(CCSequence:create(animArr));
            end
            moveFunc();
            game_scene:getPopContainer():addChild(yindao_shouzhi)
        end
    end

    local id = game_guide_controller:getIdByTeam("65");
    -- id = 6501
    -- print("game_guide_controller:getIdByTeam(65)", id)
    if id == 6501 then
        -- self:gameGuide("drama","65",6501)
        game_guide_controller:showGuide("65", 6501,{tempNode = self.m_tab_btn_2})
    end

    return scene;
end

--[[
    自动穿装备
]]
function game_guild_adjustment_formation.autoMatchEquip( self, cardIndex )
    if self.m_teamIndex == 1 then
        local cardData,cardCfg = self:getTeamCardDataByPos( cardIndex );
        if not cardCfg then return end

        local curPosEquip = self.m_tempEquipPosData[tonumber(cardIndex)]
        -- cclog2(curPosEquip, "curPosEquip " .. cardIndex .."   ====  1111   ")
        local recommendEquip = {"0","0","0","0"}
        local recommendEquipData = {}

        local chainEquipDataTab = game_util:cardEquipChainByCfg(cardCfg, cardData.id)
        -- cclog2(chainEquipDataTab, "chainEquipDataTab  =====   ")
        local equipTable = game_data:getEquipIdTable()
        -- cclog2(equipTable, "auto equip all equipTable  =====   ")
        local equipCfg = getConfig(game_config_field.equip);
        local existFlag,cardName, pos = true, nil, nil
        local itemData, itemCfg = nil, nil
        for i,v in ipairs(equipTable) do
            itemData, itemCfg = game_data:getEquipDataById(tostring(v));
            -- cclog2(itemData, tostring(i) .. "auto equip  itemData  =====   ")
            -- cclog2(itemCfg, tostring(i) .. "auto equip  itemCfg  =====   ")
            local equipSort = itemCfg:getNodeWithKey("sort") and itemCfg:getNodeWithKey("sort"):toInt() or 0
            local canUseFlag = true
            if equipSort and not self:isEquipCanUse(cardIndex, v, equipSort) then
                -- cclog2(" 这个装备属于 别人装备的")
                canUseFlag = false
            end
            if itemData.bind_card and itemData.bind_card ~= "" then
                canUseFlag = false
            end
            if canUseFlag then -- 可以装备
                if recommendEquip[equipSort] == "0" then  -- 这个位置没有装备任何东西呢
                    recommendEquip[equipSort] = v  
                    recommendEquipData[equipSort] = {itemData = itemData, itemCfg = itemCfg }
                else -- 已经有装备
                    local isThisChainFlag = game_util:isCardChainEquip(itemCfg, chainEquipDataTab ) or false
                    local autoFlag = true
                    if autoFlag and isThisChainFlag == false then
                        local isCurChainFlag = game_util:isCardChainEquip(recommendEquipData[equipSort].itemCfg, chainEquipDataTab ) or false
                        if isCurChainFlag == true then
                            autoFlag = false
                        end
                    elseif autoFlag and isThisChainFlag == true then
                        local isCurChainFlag = game_util:isCardChainEquip(recommendEquipData[equipSort].itemCfg, chainEquipDataTab ) or false
                        if isCurChainFlag == false then
                            autoFlag = false
                            recommendEquip[equipSort] = v  
                            recommendEquipData[equipSort].itemData = itemData
                            recommendEquipData[equipSort].itemCfg = itemCfg
                        end
                    end

                    if autoFlag then 
                        local curEquiplevel = recommendEquipData[equipSort].itemData.lv or 0
                        local curAddHP = game_util:getEquipHPAttributeValue(recommendEquipData[equipSort].itemCfg,curEquiplevel);
                        local thisEquiplevel = itemData.lv or 0
                        local thisAddHP = game_util:getEquipHPAttributeValue(itemCfg,thisEquiplevel);
                        if curAddHP < thisAddHP then
                            recommendEquip[equipSort] = v  
                            recommendEquipData[equipSort].itemData = itemData
                            recommendEquipData[equipSort].itemCfg = itemCfg
                        end
                    end
                end
            end
        end


            self.m_chainTabBackUp = self.m_chainTab == nil and nil or util.table_copy(self.m_chainTab)
            self:newChainOpenAnim("equip");

        for i=1,4 do
            if recommendEquip[i] ~= "0" and recommendEquip[i] ~= curPosEquip[i] then
                self.m_selEquipId = curPosEquip[i];
                self.m_chainTabBackUp = self.m_chainTab == nil and nil or util.table_copy(self.m_chainTab)
                self:updateEquipPosData(cardIndex,i,recommendEquip[i]);
                self.m_changeFlag = true;
                self:addTeamHeroPop(cardIndex);
                self:newChainOpenAnim("equip");
            end
        end
        -- cclog2(self.m_tempEquipPosData, "all equip info m_tempEquipPosData   ===   ")
        -- cclog2(recommendEquipData, "推荐装备信息是  ==========  ")
    elseif self.m_teamIndex == 2 then
        local cardData,cardCfg = self:getFriendCardDataByPos( cardIndex  );
        if not cardCfg then return end

        local curPosEquip = self.m_tempAssEquipPosData[tostring(cardIndex + 99)]
        -- cclog2(curPosEquip, "curPosEquip " .. cardIndex .."   ====   222 ")
        local recommendEquip = {"0","0","0","0"}
        local recommendEquipData = {}

        local chainEquipDataTab = game_util:cardEquipChainByCfg(cardCfg, cardData.id)
        -- cclog2(chainEquipDataTab, "chainEquipDataTab  =====   ")
        local equipTable = game_data:getEquipIdTable()
        -- cclog2(equipTable, "auto equip all equipTable  =====   ")
        local equipCfg = getConfig(game_config_field.equip);
        local existFlag,cardName, pos = true, nil, nil
        local itemData, itemCfg = nil, nil
        local noExchangeTab = {1,1,1,1}
        for i,v in ipairs(equipTable) do
            itemData, itemCfg = game_data:getEquipDataById(tostring(v));
            -- cclog2(itemData, tostring(i) .. "auto equip  itemData  =====   ")
            -- cclog2(itemCfg, tostring(i) .. "auto equip  itemCfg  =====   ")
            local equipSort = itemCfg:getNodeWithKey("sort") and itemCfg:getNodeWithKey("sort"):toInt() or 0
            local canUseFlag = true
            if equipSort and not self:isEquipCanUse(cardIndex, v, equipSort) then
                -- cclog2(" 这个装备属于 别人装备的")
                canUseFlag = false
            end
            if itemData.bind_card and itemData.bind_card ~= "" then
                canUseFlag = false
            end
            if canUseFlag then -- 可以装备
                if recommendEquip[equipSort] == "0" then  -- 这个位置没有装备任何东西呢
                    recommendEquip[equipSort] = v  
                    recommendEquipData[equipSort] = {itemData = itemData, itemCfg = itemCfg }
                else -- 已经有装备
                    local isThisChainFlag = game_util:isCardChainEquip(itemCfg, chainEquipDataTab ) or false
                    local autoFlag = true
                    if autoFlag and isThisChainFlag == false then
                        local isCurChainFlag = game_util:isCardChainEquip(recommendEquipData[equipSort].itemCfg, chainEquipDataTab ) or false
                        if isCurChainFlag == true then
                            autoFlag = false
                        end
                    elseif autoFlag and isThisChainFlag == true then
                        local isCurChainFlag = game_util:isCardChainEquip(recommendEquipData[equipSort].itemCfg, chainEquipDataTab ) or false
                        if isCurChainFlag == false then
                            autoFlag = false
                            recommendEquip[equipSort] = v  
                            recommendEquipData[equipSort].itemData = itemData
                            recommendEquipData[equipSort].itemCfg = itemCfg
                        end
                    end

                    if autoFlag then 
                        local curEquiplevel = recommendEquipData[equipSort].itemData.lv or 0
                        local curAddHP = game_util:getEquipHPAttributeValue(recommendEquipData[equipSort].itemCfg,curEquiplevel);
                        local thisEquiplevel = itemData.lv or 0
                        local thisAddHP = game_util:getEquipHPAttributeValue(itemCfg,thisEquiplevel);
                        if curAddHP < thisAddHP then
                            recommendEquip[equipSort] = v  
                            recommendEquipData[equipSort].itemData = itemData
                            recommendEquipData[equipSort].itemCfg = itemCfg
                        end
                    end
                end
            end
        end
        if cardData.bind_equip and next(cardData.bind_equip) then
            for k,v in pairs(cardData.bind_equip) do
                if v ~= 0 then
                    for i=1,4 do
                        if tonumber(curPosEquip[i]) == v then
                            noExchangeTab[i] = 0
                        end
                    end
                end
            end
        end
        for i=1,4 do
            if recommendEquip[i] ~= "0" and recommendEquip[i] ~= curPosEquip[i] and noExchangeTab[i] ~= 0 then
                self.m_selEquipId = curPosEquip[i];
                self.m_chainTabBackUp = self.m_chainTab == nil and nil or util.table_copy(self.m_chainTab)
                self:updateAssEquipPosData(cardIndex,i,recommendEquip[i]);
                self.m_changeFlag = true;
                self:addTeamHeroPop(cardIndex);
                self:newChainOpenAnim("equip");
            end
        end
        -- self:autoMatchFateEquip(cardData.id,cardIndex)
    end
end

--[[
    -- 判断装备是否被别人装备上了
    -- poxIndex 卡牌位置
    -- equipId 装备id
    -- equipSortIndex 装备的sort
]]
function game_guild_adjustment_formation.isEquipCanUse( self, posIndex, equipId, equipSortIndex )
    local tempEquipTable = nil
    for k,v in pairs(self.m_tempEquipPosData) do
        -- print(k, v, posIndex, " k   v   posIndex =======   ")
        if self.m_teamIndex == 2 or tostring(k) ~= tostring(posIndex) then
            v = v or {}
            -- cclog2(v[equipSortIndex], "v[equipSortIndex]   ==   ")
            -- cclog2(equipId, "equipId  ====  ")
            if v[equipSortIndex] == equipId then
                return false
            end
        end
    end

    if self.m_teamIndex == 2 then posIndex = tostring(posIndex + 99) end
    for k,v in pairs(self.m_tempAssEquipPosData) do
        -- print(k, v, posIndex, " k   v   posIndex =======   ")
        if self.m_teamIndex == 1 or tostring(k) ~= tostring(posIndex) then
            v = v or {}
            -- cclog2(v[equipSortIndex], "v[equipSortIndex]   ==   ")
            -- cclog2(equipId, "equipId  ====  ")
            if v[equipSortIndex] == equipId then
                return false
            end
        end
    end
    return true
end


--[[
    新手引导
]]
function game_guild_adjustment_formation.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    -- id = 6501
    t_params = t_params or {};
    if guideType == "drama" then
        if guide_team == "65" and id == 6501 then
            local function endCallFunc()
                game_guide_controller:gameGuide("send","65",6502);
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        end
    end
end

--[[--
    初始化阵型
]]
function game_guild_adjustment_formation:initTeam(  )
    -- body
    

    self.m_adjust1:setVisible(true);
    self.m_medal_btn:setVisible(true)
    self.m_soul_btn:setVisible(true)
    
    self.m_adjust2:setVisible(false);
    self.m_equip_layer:setVisible(true);
    if not self.m_teamGemOpenFlag then 
        self.m_gem_layer:setVisible(false);
        self.m_equip_layer:setPositionY(80)
    else
        self.m_gem_layer:setVisible(false);
    end
    self.m_activation_node:setVisible(false);
    self.m_title_node:setVisible(true)
    self.m_fate_label:setVisible(true);
    self.m_fate_detail_node:setVisible(false);
    self:clearFateTabView();
    self.m_teamIndex = 1;
    self:initTeamFormation(self.m_formation_layer);
    self.m_sel_bg:setVisible(true);
    self.m_posIndex = self.m_tempSelIndex;
    self:refreshHeroInfo(self.m_posIndex);
end

--[[--
    初始化助威
]]
function game_guild_adjustment_formation:initFriend(  )
 
end

--[[--
    初始化命运小伙伴
]]
function game_guild_adjustment_formation:initDestinyTeam(  )
   
end

------------------------------------- 助威 start -------------------------------------------
--[[--
    初始化小伙伴页面
]]
function game_guild_adjustment_formation:initFriendFormation( formation_layer )
    self.m_tempSelIndex = -1
    local level = game_data:getUserStatusDataByKey("level");
    local itemIcon = nil;
    local headIconSpr = nil;
    local tempLock = nil;
    local character_detail_cfg = getConfig("character_detail");
    local tempLockIndex,selLevel = -1,100;
    local smallTag1 = 1;
    local smallTag2 = 7;
    local tempTxt = nil;
    local assistant_cfg = getConfig(game_config_field.assistant);
    local sort = 0;
    for i=1,9 do
        local assistant_cfg_item = assistant_cfg:getNodeWithKey(tostring(i))
        sort = assistant_cfg_item:getNodeWithKey('sort'):toInt();
        itemIcon = self.m_ccbNode:spriteForName("m_pos_" .. i)
        formation_layer:reorderChild(itemIcon,-1000)
        local headIconBgSize = itemIcon:getContentSize();
        local pX,pY = headIconBgSize.width/2,headIconBgSize.height/2
        itemIcon:removeAllChildrenWithCleanup(true);
        self:refreshFriendPositionAttr(i, assistant_cfg_item)
        if self.m_tempFriendData[i] ~= "-1" then
            if(sort == 1)then
                smallTag1 = i+1;   
            else
                smallTag2 = i+1;
            end
        else
            tempLock = CCSprite:createWithSpriteFrameName("dw_suo.png");
            tempLock:setPosition(ccp(pX,pY));
            itemIcon:addChild(tempLock);
            if(smallTag1 == i and i < 7)then
                local spriteTxt = CCSprite:createWithSpriteFrameName("dw_dianjiwenzi.png");
                spriteTxt:setPosition(ccp(pX,pY));
                itemIcon:addChild(spriteTxt,3,3);
            end
            if(smallTag2 == i and i > 6)then
                local spriteTxt = CCSprite:createWithSpriteFrameName("dw_dianjiwenzi.png");
                spriteTxt:setPosition(ccp(pX,pY));
                itemIcon:addChild(spriteTxt,3,3);
            end
        end
        --全命运开启效果
        --createCardAnimByFriendPos 是助阵的
        -- local backAnimNode = self:createCardAnimByFriendPos(i)--全命运后面的动画
        local animNode = self:createCardAnimByFriendPos(i,false)
        if animNode then
            -- backAnimNode:setScale(2)
            -- backAnimNode:setPosition(ccp(pX,headIconBgSize.height*0.1));
            -- backAnimNode:setColor(ccc3(255,255,0))
            -- itemIcon:addChild(backAnimNode,1,2)
            animNode:setPosition(ccp(pX,headIconBgSize.height*0.1));
            itemIcon:addChild(animNode,1,1);
            if self.m_tempSelIndex == -1 then
                self.m_tempSelIndex = i;
            end
        end
        self:setPositionBg2(i);
    end
    self:initFriendFormationTouch(self.m_formation_layer);
    self:initFriendEquipLayerTouch(self.m_equip_layer);
end
--[[
    
]]
function game_guild_adjustment_formation.refreshFriendPositionAttr( self, posIndex, assistant_cfg_item)
    local assistantEffect = game_data:getAssistantEffect()
    local assistantEffectItem = assistantEffect[posIndex] or {}
    local active_status = assistantEffectItem.active_status or "-1" -- "-1"未激活 "0" 激活
    local cardId = self.m_tempFriendData[posIndex] or ""
    if active_status == "-1" or cardId == "0" then return end
    if assistant_cfg_item == nil then
        local assistant_cfg = getConfig(game_config_field.assistant);
        assistant_cfg_item = assistant_cfg:getNodeWithKey(tostring(posIndex))
    end
    local itemIcon = self.m_ccbNode:spriteForName("m_pos_" .. posIndex)
    local headIconBgSize = itemIcon:getContentSize();
    local pX,pY = headIconBgSize.width/2,headIconBgSize.height/2
    local tempSpriteFrameBg = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dw_heitiao.png")
    if tempSpriteFrameBg then
        local tempSpriteBg = CCSprite:createWithSpriteFrame(tempSpriteFrameBg)
        tempSpriteBg:setAnchorPoint(ccp(1,0))
        tempSpriteBg:setPosition(ccp(pX*2,0))
        itemIcon:addChild(tempSpriteBg,12,12)
    end
    local assAttrValueTab,_,_ = game_util:getAssistantAttrTab(posIndex, assistantEffectItem, assistant_cfg_item, false)
    cclog2(assAttrValueTab,"assAttrValueTab==== v")
    local index = 1
    for i=1,#assAttrValueTab do
        local attrValueItem = assAttrValueTab[i]
        local att_name = attrValueItem.att_name or ""
        local open = attrValueItem.open or 0
        local active = attrValueItem.active or 1
        if open > 0 and active > 0 and (att_name ~= "ability2" or (att_name == "ability2" and self.m_ability2OpenFlag)) then
            local temp_att_type = attrValueItem.att_type or 0
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dw_attr_up_" .. temp_att_type .. ".png")
            if tempSpriteFrame then
                local tempSprite = CCSprite:createWithSpriteFrame(tempSpriteFrame)
                tempSprite:setPosition(ccp(pX*2-9,70-18*index))
                itemIcon:addChild(tempSprite,13,13)
                index = index + 1
            end
        end
    end
end

--[[
    助威阵型触摸
]]
function game_guild_adjustment_formation.initFriendFormationTouch( self,formation_layer )
    -- body
    local beganItem,selItem = nil,nil
    local touchBeginPoint = nil
    local touchMoveFlag = false;
    local function onTouchBegan( x,y )
        if selItem then
            selItem:removeFromParentAndCleanup(true);
            selItem = nil;
        end
        touchMoveFlag = false
        touchBeginPoint = {x = x, y = y}
        local realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        -- CCTOUCHBEGAN event must return true
        for tag = 1,9 do
            beganItem = self.m_ccbNode:spriteForName("m_pos_" .. tag)
            if beganItem and beganItem:boundingBox():containsPoint(realPos) then
                selItem = self:createCardAnimByFriendPos(tag,false)
                if selItem == nil then break end
                local pX,pY = beganItem:getPosition();
                selItem:setPosition(ccp(pX,pY));
                -- selItem:setColor(ccc3(128,128,128));
                formation_layer:addChild(selItem,11,11);
                selItem:setVisible(false);
                break;
            end
        end
        return true
    end
    local function onTouchMoved( x,y )
        if ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 or touchMoveFlag == true then
            if selItem then
                local realPos = formation_layer:convertToNodeSpace(ccp(x,y));
                selItem:setPosition(realPos);
                selItem:setVisible(true);
            end
            touchMoveFlag = true;
        end
    end
    local function onTouchEnded( x,y )
        local realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        local smallTag1 = 9;
        local smallTag2 = 9;
        local assistant_cfg = getConfig(game_config_field.assistant);
        local sort = 0

        for endTag = 1,9 do
            local assistant_cfg_item = assistant_cfg:getNodeWithKey(tostring(endTag))
            sort = assistant_cfg_item:getNodeWithKey('sort'):toInt();
            local tempid = self.m_tempFriendData[endTag]
            if tempid == "-1" then
                if(sort == 1)then
                    smallTag1 = math.min(smallTag1,endTag);
                else
                    smallTag2 = math.min(smallTag2,endTag);
                end
            end
            endItem = self.m_ccbNode:spriteForName("m_pos_" .. endTag)
            if endItem and endItem:boundingBox():containsPoint(realPos) then
                local beganTag = beganItem:getTag();
                if(endTag == beganTag)then
                    if tempid == "-1" then
                        if(smallTag1 == endTag or smallTag2 == endTag)then
                            local t_params = {}
                            t_params.okBtnCallBack = function()
                                local function responseMethod(tag,gameData)
                                    game_util:addMoveTips({text = "成功开启！"});
                                    local assistantData = game_data:getAssistant();
                                    local tempData = util.table_copy(self.m_tempFriendData)
                                    self.m_tempFriendData = assistantData
                                    for k,v in pairs(tempData) do
                                        if v ~= "-1" then
                                            self.m_tempFriendData[k] = v;
                                        end
                                    end
                                    self:initFriendFormation(self.m_formation_layer);
                                    game_scene:removePopByName("game_assistant_pop");
                                end
                                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_activate_assistant"), http_request_method.GET, {position = endTag-1},"cards_activate_assistant")
                            end
                            t_params.index = endTag
                            game_scene:addPop("game_assistant_pop",t_params)
                        end
                    -- elseif tempid == "0" then
                    --     self:addFriendSelHeroUi(endTag);
                    else
                        self.m_posIndex = endTag;
                        self:setPositionBg2(endTag,true);
                        self:refreshHeroInfo(endTag);
                    end
                else
                    if selItem then
                        if tempid == "-1" then--未开启
                            game_util:addMoveTips({text = "Chưa mở ô trợ uy!"})
                        else
                            self:exchangeFriendDataByTwoPos(beganTag,endTag)
                            self.m_changeFlag = true;
                            local bgSize = endItem:getContentSize();
                            beganItem:removeAllChildrenWithCleanup(true)
                            local animNode = self:createCardAnimByFriendPos(beganTag,false)
                            if animNode then
                                animNode:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.1));
                                beganItem:addChild(animNode,1,1)
                            end
                            self:setPositionBg2(beganTag)
                            self:refreshFriendPositionAttr(beganTag)
                            endItem:removeAllChildrenWithCleanup(true)
                            local animNode = self:createCardAnimByFriendPos(endTag,false)
                            if animNode then
                                animNode:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.1));
                                endItem:addChild(animNode,1,1)
                            end
                            self:setPositionBg2(endTag)
                            self:refreshFriendPositionAttr(endTag)
                            self.m_posIndex = endTag;
                            self:refreshHeroInfo(endTag);
                            self:refreshCombatLabel("initFriendFormationTouch");
                        end
                    end
                end
                break;
            end
        end
        if selItem then
            selItem:removeFromParentAndCleanup(true);
            selItem = nil;
        end
        touchBeginPoint = nil;
        beganItem = nil;
        endItem = nil;
        tempPosIndex = nil;
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+131)
    formation_layer:setTouchEnabled(true)
end

--[[--
    
]]
function game_guild_adjustment_formation.addFriendSelHeroUi(self,posIndex)
    cclog("------addFriendSelHeroUi----")

end

function game_guild_adjustment_formation:updateFriendData( posIndex,cardId )
    -- body
    self.m_tempFriendData[posIndex] = cardId;
    -- self:setFriendFormationData();
end

function game_guild_adjustment_formation:exchangeFriendDataByTwoPos( posIndex1,posIndex2 )
    -- body
    self.m_tempFriendData[posIndex1],self.m_tempFriendData[posIndex2] = self.m_tempFriendData[posIndex2],self.m_tempFriendData[posIndex1];
    posIndex1 = tostring(posIndex1+99)
    posIndex2 = tostring(posIndex2+99)
    self.m_tempAssEquipPosData[posIndex1],self.m_tempAssEquipPosData[posIndex2] = self.m_tempAssEquipPosData[posIndex2],self.m_tempAssEquipPosData[posIndex1]
    -- self:setFriendFormationData();
end

function game_guild_adjustment_formation:setFriendFormationData(  )
    -- body
    -- cclog("self.m_tempFriendData = " .. json.encode(self.m_tempFriendData))
end

--[[--
    获得卡牌配置以及数据
]]
function game_guild_adjustment_formation:getFriendCardDataByPos( posIndex )
    -- body
    return game_data:getCardDataById(self.m_tempFriendData[posIndex])
end
--[[
    获取小伙伴位置上的动画
]]
function game_guild_adjustment_formation:createCardAnimByFriendPos( posIndex , animFlag)
    -- body
    local heroData,heroCfg = self:getFriendCardDataByPos(posIndex);
    return self:createCardAnimByData(heroData,heroCfg,animFlag)
end
--[[--
    助威装备层
]]
function game_guild_adjustment_formation.initFriendEquipLayerTouch(self,formation_layer)
 
end

--[[--
    
]]
function game_guild_adjustment_formation.addFriendTeamHeroPop(self,posIndex)
    game_scene:removeGuidePop();
    if self.m_tempFriendData[posIndex] == "-1" then

    else
        self.m_posIndex = posIndex;
        self:refreshHeroInfo(posIndex);
    end
end

function game_guild_adjustment_formation.exchangeAssEquipPosAlert(self,posIndex,currPos,sort,id,posType)
end

--[[

]]
function game_guild_adjustment_formation.exchangeAssEquipPosDataByTwoPos(self,posIndex1,posIndex2,equipType)
    if posIndex1 == posIndex2 then return end
    if posIndex1 > 9 or posIndex1 < 0 or posIndex2 > 9 or posIndex2 < 0 or equipType > 4 or equipType < 1 then return end
    posIndex1 = tostring(posIndex1+99)
    posIndex2 = tostring(posIndex2+99)
    self.m_tempAssEquipPosData[posIndex1][equipType],self.m_tempAssEquipPosData[posIndex2][equipType] = self.m_tempAssEquipPosData[posIndex2][equipType],self.m_tempAssEquipPosData[posIndex1][equipType]
    -- cclog("updateAssEquipPosData = " .. json.encode(self.m_tempAssEquipPosData))
end

--[[

]]
function game_guild_adjustment_formation.exchangeAssAndTeamEquipPosDataByTwoPos(self,posIndex1,posIndex2,equipType)
    if posIndex1 > 9 or posIndex1 < 0 or posIndex2 > 9 or posIndex2 < 0 or equipType > 4 or equipType < 1 then return end
    posIndex1 = tostring(posIndex1+99)
    self.m_tempAssEquipPosData[posIndex1][equipType],self.m_tempEquipPosData[posIndex2][equipType] = self.m_tempEquipPosData[posIndex2][equipType],self.m_tempAssEquipPosData[posIndex1][equipType]
    self:setTeamFormationData()
    -- cclog("exchangeAssAndTeamEquipPosDataByTwoPos = " .. json.encode(self.m_tempAssEquipPosData))
end

--[[--
    设置阵型相应位置装备数据
]]
function game_guild_adjustment_formation.updateAssEquipPosData(self,equipPos,equipType,equipId)
    if equipPos > 9 or equipPos < 0 or equipType > 4 or equipType < 1 then return end
    equipPos = tostring(equipPos+99)
    self.m_tempAssEquipPosData[equipPos][equipType] = tostring(equipId);
    -- cclog("updateAssEquipPosData = " .. json.encode(self.m_tempAssEquipPosData))
end

--[[--
    
]]
function game_guild_adjustment_formation.addSelAssEquipUi(self,posIndex,sort)
end

function game_guild_adjustment_formation:fateTouchShow( x,y )
    if self.m_fate_label:isVisible() == true then
        realPos = self.m_fate_node:getParent():convertToNodeSpace(ccp(x,y));
        if self.m_fate_node:boundingBox():containsPoint(realPos) then
            self.m_fate_label:setVisible(false);
            self.m_equip_layer:setVisible(false);
            self.m_fate_node:setVisible(false);
            if self.m_teamIndex == 1 then
                self.m_gem_layer:setVisible(false)
            else
                self.m_activation_node:setVisible(false);
            end
            self.m_fate_detail_node:setVisible(true);
        end
    elseif self.m_fate_detail_node:isVisible() == true then
        realPos = self.m_fate_detail_node:getParent():convertToNodeSpace(ccp(x,y));
        if self.m_fate_detail_node:boundingBox():containsPoint(realPos) then
            self.m_fate_label:setVisible(true);
            if self.m_teamIndex == 1 then
                self.m_fate_node:setVisible(true);
                if self.m_teamGemOpenFlag then self.m_gem_layer:setVisible(false) end
                self.m_equip_layer:setVisible(false)
            else
                self.m_activation_node:setVisible(true);
                if self.m_ability2OpenFlag then self.m_equip_layer:setVisible(false) end
            end
            self.m_fate_detail_node:setVisible(false);
        end
    end
end

------------------------------------- 助威 end -------------------------------------------

------------------------------------- 命运 start -------------------------------------------
--[[--
    初始化助威页面
]]
function game_guild_adjustment_formation:initDestinyFormation( formation_layer )
    -- body
    local level = game_data:getUserStatusDataByKey("level");
    local itemIcon = nil;
    local headIconSpr = nil;
    local tempLock = nil;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local tempLockIndex,selLevel = -1,100;
    local smallTag1 = 1;
    local smallTag2 = 7;
    local tempTxt = nil;

    local assistant_cfg = getConfig(game_config_field.destiny);
    local sort = 0;
    for i=1,9 do
        local assistant_cfg_item = assistant_cfg:getNodeWithKey(tostring(i))
        sort = assistant_cfg_item:getNodeWithKey('sort'):toInt();
        itemIcon = self.m_ccbNode:spriteForName("m_pos_" .. i)
        formation_layer:reorderChild(itemIcon,-1000)
        local headIconBgSize = itemIcon:getContentSize();
        itemIcon:removeAllChildrenWithCleanup(true)
        if self.m_tempDestinyData[i] ~= "-1" then
            if(sort == 1)then
                smallTag1 = i+1;   
            else
                smallTag2 = i+1;
            end
        else
            tempLock = CCSprite:createWithSpriteFrameName("dw_suo.png");
            tempLock:setPosition(ccp(headIconBgSize.width/2,headIconBgSize.height/2));
            itemIcon:addChild(tempLock);
            local limit_lv = assistant_cfg_item:getNodeWithKey("limit_lv"):toInt();
            if level < limit_lv then
                local tempLabel = game_util:createLabelBMFont({text = "解锁限制：" .. limit_lv .. "级",color = ccc3(0, 255, 0)});    
                tempLabel:setPosition(ccp(headIconBgSize.width/2,10));
                itemIcon:addChild(tempLabel);
            else            
                if(smallTag1 == i and i < 7)then
                    local spriteTxt = CCSprite:createWithSpriteFrameName("dw_dianjiwenzi.png");
                    spriteTxt:setPosition(ccp(headIconBgSize.width/2,headIconBgSize.height/2));
                    itemIcon:addChild(spriteTxt,3,3);
                end
                if(smallTag2 == i and i > 6)then
                    local spriteTxt = CCSprite:createWithSpriteFrameName("dw_dianjiwenzi.png");
                    spriteTxt:setPosition(ccp(headIconBgSize.width/2,headIconBgSize.height/2));
                    itemIcon:addChild(spriteTxt,3,3);
                end
            end
        end
        local animNode = self:createCardAnimByDestinyPos(i,false)
        if animNode then
            animNode:setPosition(ccp(headIconBgSize.width*0.5,headIconBgSize.height*0.1));
            itemIcon:addChild(animNode,1,1);
        end
        self:setPositionBg2(i);
    end
    self:initDestinyFormationTouch(self.m_formation_layer);
end

function game_guild_adjustment_formation.initDestinyFormationTouch( self,formation_layer )
    -- body
    local level = game_data:getUserStatusDataByKey("level");
    local beganItem = nil;
    local touchMoveFlag = false;
    local function onTouchBegan( x,y )
        local touchBeginPoint = {x = x, y = y}
        local realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        -- CCTOUCHBEGAN event must return true
        for tag = 1,9 do
            beganItem = self.m_ccbNode:spriteForName("m_pos_" .. tag)
            if beganItem and beganItem:boundingBox():containsPoint(realPos) then
                break;
            end
        end
        return true
    end
    local function onTouchMoved( x,y )
        -- body
    end
    local function onTouchEnded( x,y )
        local realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        local smallTag1 = 9;
        local smallTag2 = 9;
        local assistant_cfg = getConfig(game_config_field.destiny);
        local sort = 0

        for endTag = 1,9 do
            local assistant_cfg_item = assistant_cfg:getNodeWithKey(tostring(endTag))
            sort = assistant_cfg_item:getNodeWithKey('sort'):toInt();
            if self.m_tempDestinyData[endTag] == "-1" then
                if(sort == 1)then
                    smallTag1 = math.min(smallTag1,endTag);
                else
                    smallTag2 = math.min(smallTag2,endTag);
                end
            end
            endItem = self.m_ccbNode:spriteForName("m_pos_" .. endTag)
            if endItem and endItem:boundingBox():containsPoint(realPos) then
                local beganTag = beganItem:getTag();
                if(endTag == beganTag)then
                    if self.m_tempDestinyData[endTag] == "-1" then
                        if(smallTag1 == endTag or smallTag2 == endTag)then
                            local limit_lv = assistant_cfg_item:getNodeWithKey("limit_lv"):toInt();
                            if level < limit_lv then
                                -- game_util:addMoveTips({text = "等级不够！"})
                                break;
                            end
                            local t_params = {}
                            t_params.okBtnCallBack = function()
                                local function responseMethod(tag,gameData)
                                    game_util:addMoveTips({text = "成功开启！"});
                                    local destinyData = game_data:getDestiny();
                                    local tempData = util.table_copy(self.m_tempDestinyData)
                                    self.m_tempDestinyData = destinyData
                                    for k,v in pairs(tempData) do
                                        if v ~= "-1" then
                                            self.m_tempDestinyData[k] = v;
                                        end
                                    end
                                    self:initDestinyFormation(self.m_formation_layer);
                                    game_scene:removePopByName("game_assistant_pop");
                                end
                                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_activate_destiny"), http_request_method.GET, {position = endTag-1},"cards_activate_destiny")
                            end
                            t_params.index = endTag
                            t_params.openType = 2
                            game_scene:addPop("game_assistant_pop",t_params)
                        end
                    else
                        self:addDestinySelHeroUi(endTag);
                    end
                end
                break;
            end
        end
        touchBeginPoint = nil;
        beganItem = nil;
        endItem = nil;
        tempPosIndex = nil;
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+131)
    formation_layer:setTouchEnabled(true)
end

--[[--
    
]]
function game_guild_adjustment_formation.addDestinySelHeroUi(self,posIndex)
end

function game_guild_adjustment_formation:updateDestinyData( posIndex,cardId )
    -- body
    self.m_tempDestinyData[posIndex] = cardId;
end

--[[
    获取命运小伙伴位置上的动画
]]
function game_guild_adjustment_formation:createCardAnimByDestinyPos( posIndex , animFlag)
    -- body
    local heroData,heroCfg = game_data:getCardDataById(self.m_tempDestinyData[posIndex])
    return self:createCardAnimByData(heroData,heroCfg,animFlag);
end

--[[

]]
function game_guild_adjustment_formation:refreshFateTabBtn( sortIndex )
    sortIndex = sortIndex or 1;
    for i=1,2 do
        local tempBtn = self.m_ccbNode:controlButtonForName("m_fate_tab_btn_" .. i)
        if tempBtn then
            tempBtn:setHighlighted(sortIndex == i);
            tempBtn:setEnabled(sortIndex ~= i);
        end
    end
    if sortIndex == 1 then
        self.m_fate_list_view_bg:setVisible(true)
        self.m_scrollView:setVisible(false)
    elseif sortIndex == 2 then
        self.m_fate_list_view_bg:setVisible(false)
        self.m_scrollView:setVisible(true)
    end
end

--[[
    
]]
function game_guild_adjustment_formation.createFateSummaryTableView(self, viewSize)
    local shwoData = self.m_fateDataTab or {}
    local showCount = #shwoData
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 2; --列
    params.totalItem = showCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionVertical;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create()            
            ccbNode:openCCBFile("ccb/ui_adjustment_fate_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_node = ccbNode:nodeForName("m_node")
            local m_fate_label = ccbNode:labelTTFForName("m_fate_label")
            m_node:removeAllChildrenWithCleanup(true)
            local itemData = shwoData[showCount - index]
            local cardData,cardCfg = game_data:getCardDataById(itemData.cardId)
            local tempIcon = game_util:createCardIconByCfg(cardCfg,cardData);
            if tempIcon then
                tempIcon:setScale(0.75);
                m_node:addChild(tempIcon);
            end
            m_fate_label:setString(tostring(itemData.openChainCount) .. "/" .. tostring(itemData.chainCount))
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            self:refreshFateTabBtn(2)
            local tempHeight = 0;
            for i=1,math.min(showCount - index,showCount) do
                tempHeight = tempHeight + shwoData[i].itemHeight;
            end
            local contentSize = self.m_scrollView:getContentSize();
            local viewSize = self.m_scrollView:getViewSize();
            if tempHeight < viewSize.height then
                self.m_scrollView:setContentOffset(ccp(0,0),false)
            else
                self.m_scrollView:setContentOffset(ccp(0,math.max(-tempHeight+viewSize.height,-contentSize.height+viewSize.height)),false)
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
    end
    return TableViewHelper:create(params);
end
--[[
    
]]
function game_guild_adjustment_formation:refreshFriendScroll(  )
    self.m_scrollView:getContainer():removeAllChildrenWithCleanup(true)
    local layer = self:initFriendScroll();
    self.m_scrollView:addChild(layer,1024,1024);
end

--[[
    
]]
function game_guild_adjustment_formation:initFriendScroll(  )
    -- body
    self.m_fateDataTab = {};
    local layer = CCLayer:create();
    local scrollContent = self.m_scrollView:getContentSize();
    local offsetY = 0;
    for k,v in pairs(self.m_tempFriendData) do
        local cardData,cardCfg = self:getFriendCardDataByPos(k);
        offsetY = self:addChainItemView(layer, cardData, cardCfg, offsetY);
    end
    for k,v in pairs(self.m_tempTeamData) do
        local cardData,cardCfg = self:getTeamCardDataByPos(k);
        offsetY = self:addChainItemView(layer, cardData, cardCfg, offsetY);
    end
    scrollContent.height = offsetY;
    self.m_scrollView:setContentSize(scrollContent);
    self.m_scrollView:setContentOffset(ccp(0,269-offsetY));
    return layer;
end
--[[

]]
function game_guild_adjustment_formation.addChainItemView(self, layer, cardData, cardCfg, offsetY)
    if cardData and cardCfg then
        local chainTab,chainCount,openChainCount = game_util:cardChainByCfg(cardCfg,cardData.id)
        --todo
        if  cardData.fate_change and next(cardData.fate_change) then
            chainTab,chainCount,openChainCount = game_util:cardChainByCfg2(cardCfg,cardData.id)  
        end

        local fate_detail = game_util:createRichLabelTTF({text = "",dimensions = CCSizeMake(170,0),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = nil,color = ccc3(221,221,192)});
        if #chainTab > 0 then
            local showStr = ""
            local nameStr = "";
            for i=1,#chainTab do
                showStr = showStr .. chainTab[i].detail .. "\n"
                nameStr = nameStr .. "    " .. chainTab[i].name .. (i == 3 and "\n" or "")
            end
            fate_detail:setString(showStr)
        else
            fate_detail:setString("无");
        end
        local fateSz = fate_detail:getContentSize();
        local tempHeight = math.max(fateSz.height,50)
        fate_detail:setPosition(ccp(90,offsetY+tempHeight/2));
        layer:addChild(fate_detail);
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dw_zidi.png")
        if tempSpriteFrame then
            local tempSpri = CCScale9Sprite:createWithSpriteFrame(tempSpriteFrame)
            tempSpri:setPreferredSize(CCSizeMake(100, 18));
            tempSpri:setAnchorPoint(ccp(0.5,0))
            tempSpri:setPosition(ccp(55,offsetY + tempHeight+5));
            layer:addChild(tempSpri);
        end
        local name = cardCfg:getNodeWithKey("name"):toStr();
        local tempLabel = game_util:createLabelTTF({text = name,color = ccc3(250,180,0),fontSize = 12});
        tempLabel:setAnchorPoint(ccp(0.5,0))
        tempLabel:setPosition(ccp(55,offsetY + tempHeight+7));
        layer:addChild(tempLabel);
        offsetY = offsetY+tempHeight+30;
        -- local tempIcon = game_util:createCardIconByCfg(cardCfg);
        -- local iconSz = tempIcon:getContentSize();
        -- tempIcon:setPosition(ccp(30,offsetY-iconSz.height/2 - 10));
        -- layer:addChild(tempIcon);
        table.insert(self.m_fateDataTab,{chainCount = chainCount,openChainCount = openChainCount,cardId = cardData.id, itemHeight = tempHeight+30})
    end
    return offsetY;
end

--[[
    
]]
function game_guild_adjustment_formation.refreshFateSummaryTableView(self)
    self.m_fate_list_view_bg:removeAllChildrenWithCleanup(true)
    local tempTableView = self:createFateSummaryTableView(self.m_fate_list_view_bg:getContentSize())
    self.m_fate_list_view_bg:addChild(tempTableView)
end
--[[
    
]]
function game_guild_adjustment_formation.clearFateTabView(self)
    self.m_fate_list_view_bg:removeAllChildrenWithCleanup(true)
    self.m_scrollView:getContainer():removeAllChildrenWithCleanup(true)
end

------------------------------------- 命运 end -------------------------------------------

return game_guild_adjustment_formation;
