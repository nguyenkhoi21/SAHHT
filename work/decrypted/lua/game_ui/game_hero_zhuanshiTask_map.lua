---  转世第二关地图

local game_hero_zhuanshiTask_map = {
    m_activeChapterId = nil,
    m_activeId = nil,
    m_next_step = nil,
    m_fight_list_count = nil,
    m_checkpoint_name_label = nil,
    m_checkpoint_label = nil,
    m_background_node = nil,
    m_move_ndoe = nil,
    m_backgroundup_node = nil,
    m_card_anim_tab = nil,
    m_card_anim_dfd_tab = nil,
    m_building_node = nil,
    m_building_name = nil,
    m_introduction_label = nil,
    m_reward_label = nil,
    m_ccbNode = nil,        -- 场景ui前景
    m_stageTableData = nil,
    m_advance_btn = nil,
    m_bgMusic = nil,
    m_backgroundName = nil,
    m_pre_battle_btn = nil,
    m_cardid = nil,
    m_battle_Data = nil,
};

--[[--
    销毁
]]
function game_hero_zhuanshiTask_map.destroy(self)
    -- body
    cclog("-----------------game_hero_zhuanshiTask_map destroy-----------------");
    self.m_activeChapterId = nil;
    self.m_activeId = nil;
    self.m_fight_list_count = nil;
    self.m_checkpoint_name_label = nil;
    self.m_checkpoint_label = nil;
    self.m_background_node = nil;
    self.m_move_ndoe = nil;
    self.m_backgroundup_node = nil;
    self.m_card_anim_tab = nil;
    self.m_card_anim_dfd_tab = nil;
    self.m_building_node = nil;
    self.m_building_name = nil;
    self.m_introduction_label = nil;
    self.m_reward_label = nil;
    self.m_stageTableData = nil;
    self.m_advance_btn = nil;
    self.m_backgroundName = nil;
    self.m_pre_battle_btn = nil;
    self.m_cardid = nil;
    self.m_battle_Data = nil;
end
--[[--
    返回
]]
function game_hero_zhuanshiTask_map.back(self,type)
    local gameData,_ = game_data:getCardDataById(self.m_cardid)
    game_scene:enterGameUi("game_hero_zhuanshi",{gameData = gameData});
end
--[[--
    进入战斗场景
]]
function game_hero_zhuanshiTask_map.enterBattleScene(self)
    local gameData,_ = game_data:getCardDataById(self.m_cardid)
     game_data:setZhuanshiTask1Data(gameData)
    local isBlackAll = false--是否整个场景都变黑
    local responseMethod = function(tag,gameData)
        if(gameData == nil) then
            return 
        end
        game_scene:removeGuidePop();
        local has_battled = 1;
        cclog("responseMethod --------------------------------" .. has_battled)
        if has_battled == 1 then
            local function animEndCallFunc()
                game_data:setBattleType("zhuanshiTask2");
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData,stageTableData=nil,backGroundName = self.m_backgroundName});
                self:destroy();
            end
            animEndCallFunc();
            game_scene:runPropertyBarAnim("outer_anim")
        end
    end
    local m_tag = nil
    local isuiRunOut = false
    --运行界面动画
    local uiRunOut = function()
        --创建加载黑影
        if(not isuiRunOut) then
            isuiRunOut = true
        else
            return 
        end
        local params = {}
        params.major = self.m_cardid
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_card_world_fight_2"), http_request_method.GET, params,"active_card_world_fight_2")
    end
    uiRunOut();
    game_data:setUserStatusDataBackup();
end

--[[--
    读取ccbi创建ui
]]
function game_hero_zhuanshiTask_map.createUi(self)
    game_scene:runPropertyBarAnim("outer_anim")
    local gameData,_ = game_data:getCardDataById(self.m_cardid)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCControlButton");
        local btnTag = tagNode:getTag();
        local function callBackFunc()
            if btnTag == 2 then --宝箱 
            elseif btnTag == 3 then --功能
            elseif btnTag == 11 then --撤退
                    self:back();
            elseif btnTag == 12 then --伙伴
                    game_scene:enterGameUi("game_hero_list",{gameData = nil,openType = "zhuanshiTask2",showIndex= 1,zhuanshiData = gameData});
                    self:destroy();
            elseif btnTag == 13 then --阵型
                    game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="zhuanshiTask2",zhuanshiData = gameData});
                    self:destroy();
            elseif btnTag == 100 then--装备
                    game_scene:enterGameUi("equipment_list",{gameData = nil,openType = "zhuanshiTask2",showIndex= 1,zhuanshiData = gameData});
                    self:destroy();
            elseif btnTag == 101 then
                local function responseMethod(tag,gameData)
                    self:setPreBattleStatus();
                end
                local pre_battle = game_data:getUserStatusDataByKey("pre_battle") or 0
                local toggle = pre_battle == 1 and 0 or 1
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_set_pre_battle"), http_request_method.GET, {toggle = toggle},"user_set_pre_battle")
            end
        end
        self:sendChangedData(callBackFunc);
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    local function onNormalBtnClick( target,event ) --向前
        local function callBackFunc()
            local falg = false
            for k,v in pairs(self.m_battle_Data) do
                if self.m_cardid == v then 
                    falg = true
                    break
                end
            end
            if falg == true then
                self:enterBattleScene();
            else
                game_util:addMoveTips({text = "Đặt thẻ muốn chuyển thế lên trận hình"})
            end
        end
        self:sendChangedData(callBackFunc);
    end
    ccbNode:registerFunctionWithFuncName("onNormalBtnClick",onNormalBtnClick);
    ccbNode:openCCBFile("ccb/ui_map_building_detail.ccbi");
    game_util:setPlayerPropertyByCCBAndTableData2(ccbNode)
    self.m_formation_layer = ccbNode:layerColorForName("m_formation_layer")
    self:initAdjustmentFormationTouch(self.m_formation_layer);
    local m_points_layer = ccbNode:layerForName("m_points_layer")
    self.m_checkpoint_name_label = ccbNode:labelTTFForName("m_checkpoint_name_label");
    self.m_checkpoint_name_label:setString("Đất Thí Luyện")
    self.m_checkpoint_label = ccbNode:labelTTFForName("m_checkpoint_label");
    self.m_background_node = ccbNode:nodeForName("m_background_node");
    self.m_backgroundup_node = ccbNode:nodeForName("m_backgroundup_node");
    self.m_building_node = ccbNode:nodeForName("m_building_node");
    self.m_building_name = ccbNode:labelTTFForName("m_building_name");
    self.m_introduction_label = ccbNode:labelTTFForName("m_introduction_label");
    self.m_reward_label = ccbNode:labelTTFForName("m_reward_label");
    self.m_advance_btn = ccbNode:controlButtonForName("m_advance_btn");
    self.m_pre_battle_btn = ccbNode:controlButtonForName("m_pre_battle_btn");
    self.m_pre_battle_btn:setVisible(false)
    self:setPreBattleStatus();
    self.m_ccbNode = ccbNode;
    local mAnimNode = game_util:createUniversalAnim({animFile = "anim_fight",actionName = "impact",loopFlag = true});
    if mAnimNode then
        local pX,pY = self.m_advance_btn:getPosition();
        mAnimNode:setPosition(ccp(pX, pY))
        self.m_advance_btn:getParent():addChild(mAnimNode,1000,1000);
    end
    return ccbNode;
end

function game_hero_zhuanshiTask_map.setPreBattleStatus(self)
    local pre_battle = game_data:getUserStatusDataByKey("pre_battle") or 0
    if pre_battle == 0 then
        game_util:setCCControlButtonBackground(self.m_pre_battle_btn,"yxsz_guanbi.png")
    else
        game_util:setCCControlButtonBackground(self.m_pre_battle_btn,"yxsz_kaiqi.png")
    end
end
local formationPosTab = {{key = "position_a",x = 0.33,y = 0.5 },
                         {key = "position_b",x = 0.28,y = 0.35},
                         {key = "position_c",x = 0.23,y = 0.2 },
                         {key = "position_d",x = 0.18, y = 0.5 },
                         {key = "position_e",x = 0.13,y = 0.35},
                         {key = "position_f",x = 0.08, y = 0.2 }};

--[[--
    刷新ui
]]
function game_hero_zhuanshiTask_map.refreshUi(self)
    -- local active_detail_cfg = getConfig(game_config_field.active_detail);
    -- local active_detail_item_cfg = active_detail_cfg:getNodeWithKey(tostring(self.m_activeId));
    local winSize = CCDirector:sharedDirector():getWinSize();
    local formationData = game_data:getFormationData();
    self:initTeamFormation(self.m_formation_layer);
    cclog("formationData.current ==" .. formationData.current);
    local formationConfig = getConfig(game_config_field.formation);
    local itemCfg = formationConfig:getNodeWithKey(tostring(formationData.current));
    local iValue = nil;
    local tempTag = 1;
    local tempIndex = 0;
    for i = 1,#formationPosTab do
        local formationPosTabItem = formationPosTab[i];
        local posNode = self.m_ccbNode:spriteForName("m_pos_" .. i)
        posNode:setAnchorPoint(ccp(0.5,0))
        pX,pY = winSize.width*formationPosTabItem.x,winSize.height*formationPosTabItem.y
        posNode:setAnchorPoint(ccp(0.5, 0));
        posNode:setPosition(ccp(pX,pY - 10))
    end
    local enemyCfg = getConfig(game_config_field.afterlife_fight)
    enemyCfg = json.decode(enemyCfg:getFormatBuffer()) or {};
    local afterlife_chapter =  getConfig(game_config_field.afterlife_chapter)
    local heroData,heroCfg = game_data:getCardDataById(self.m_cardid)
    local chapterId = tostring(heroData.c_id)
    afterlife_chapter = afterlife_chapter:getNodeWithKey(chapterId)
    local fightId = afterlife_chapter:getNodeWithKey("fight_ID"):toStr();
    local mapEnemyCfg = enemyCfg[tostring(fightId)]
    local enemy_detail_cfg = getConfig(game_config_field.afterlife_enemy);
    local animDefIndex = 1;
    if mapEnemyCfg then
        local formationId = mapEnemyCfg.formation_id
        itemCfg = formationConfig:getNodeWithKey(tostring(formationId));
        for i = 1,#formationPosTab do
            local formationPosTabItem = formationPosTab[i];
            local iValue = itemCfg:getNodeWithKey(formationPosTabItem.key):toInt();
            if iValue > 0 then
                local position = mapEnemyCfg["position"..iValue] or {}
                local positionCount = #position
                cclog("positionCount ==================== " .. positionCount)
                if positionCount == 1 then
                    enemyIndex = tostring(position[1])
                    local heroCfg = enemy_detail_cfg:getNodeWithKey(enemyIndex)
                    heroCfg = json.decode(heroCfg:getFormatBuffer()) or {};
                    cclog("enemyIndex ==================== " .. enemyIndex)
                    if heroCfg then
                        local ainmFile = tostring(heroCfg.animation)
                        local animNode = game_util:createIdelAnim(ainmFile,0,nil,heroCfg);
                        animNode:setAnchorPoint(ccp(0.5,0));
                        animNode:setPosition(ccp(winSize.width * (1 - formationPosTabItem.x),winSize.height * formationPosTabItem.y))
                        animNode:setFlipX(true)
                        local function animEnd(animNode,theId,lableName)
                            animNode:playSection(lableName);
                        end
                        animNode:registerScriptTapHandler(animEnd);
                        self.m_move_ndoe:addChild(animNode);
                        cclog("enemyIndex->"..(enemyIndex + 99))
                        -- local animTempNode = game_util:createIdelAnim(ainmFile,iValue + 99,nil,heroCfg);
                        -- self.m_card_anim_dfd_tab[animDefIndex] = animTempNode;
                        -- animTempNode:retain();
                        animDefIndex = animDefIndex + 1;
                    end
                elseif positionCount > 1 then
                    local animNode = game_util:createUnknowIdelAnim();
                    animNode:setAnchorPoint(ccp(0.5,0));
                    animNode:setPosition(ccp(winSize.width * (1 - formationPosTabItem.x),winSize.height * formationPosTabItem.y))
                    animNode:setFlipX(true)
                    self.m_move_ndoe:addChild(animNode);
                    animDefIndex = animDefIndex + 1;
                end
            end
        end
    else
        --game_util:addMoveTips({text = "活动id为" .. tostring(self.m_activeId) .. "的fight配置错误"});
    end
end

--[[--
    初始化背景
]]
function game_hero_zhuanshiTask_map.createBackground( self,t_params )
    local background = "back_snow"--just for test
    local battleBg = CCSprite:create("battle_ground/"..background..".jpg")
    self.m_backgroundName = background
    return battleBg;
end

--[[--
    初始化
]]
function game_hero_zhuanshiTask_map.init(self,t_params)
    t_params = t_params or {};
    self.m_cardid = t_params.major
    self.m_card_anim_tab = {};
    self.m_card_anim_dfd_tab = {};
    self.m_stageTableData = {};
    self.m_changeFlag = false;
    self.m_tempTeamData = {};
    self.m_tempEquipPosData = {};
    self.m_tempGemPosData = {};
    self.m_bgMusic = t_params.bgMusic or self.m_bgMusic;
    local formationData = game_data:getFormationData();
    local ownFormation = formationData.own
    local ownFormationCount = #ownFormation
    self.m_currentFormationId = formationData.current
    cclog("self.m_currentFormationId=====" .. self.m_currentFormationId);
    self.m_selFormationId = self.m_currentFormationId;
    local teamData = game_data:getTeamData();
    self.m_battle_Data = teamData
    cclog2(teamData,"teamData ===== ")
    local tempEquipPosData = game_data:getEquipPosData()
    local tempGemPosData = game_data:getGemPosData();
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
                tempTag = tempTag + 1;
            else
                self.m_tempTeamData[i] = "-1";
                self.m_tempEquipPosData[i] = {"0","0","0","0"}
                self.m_tempGemPosData[i] = {"0","0","0","0"}
            end
        end
    end
    for i=6,8 do
        self.m_tempTeamData[i+1] = teamData[i];
        self.m_tempEquipPosData[i+1] = util.table_copy(tempEquipPosData[tostring(i-1)]);
        self.m_tempGemPosData[i+1] = util.table_copy(tempGemPosData[tostring(i-1)]);
    end

    local cardNumData = game_data:getBattleCardNumData()
    local maxCount1,maxCount2 = cardNumData.position_num or 2,cardNumData.alternate_num or 0;
    self.m_openTab = TEAM_POS_OPEN_TAB["open" .. maxCount1 .. maxCount2] or {};
end

--[[--
    创建ui入口并初始化数据
]]--
function game_hero_zhuanshiTask_map.create(self,t_params)
    game_scene:runPropertyBarAnim("outer_anim")
    self:init(t_params);
    local rootScene = CCScene:create();
    local bgsp = self:createBackground();
    local winSize = CCDirector:sharedDirector():getWinSize();
    bgsp:setPosition(ccp(winSize.width / 2,winSize.height / 2))
    bgsp:setScale(resolution_config:getScale())
    rootScene:addChild(bgsp);
    self.m_move_ndoe = CCNode:create();
    rootScene:addChild(self.m_move_ndoe);
    rootScene:addChild(self:createUi());
    self:refreshUi();
    return rootScene;
end

function game_hero_zhuanshiTask_map.sendChangedData(self,callBackFunc)
    if self.m_changeFlag == true or self.m_selFormationId ~= self.m_currentFormationId then
        local function responseMethod(tag,gameData)
            if gameData ~= nil then
                local data = gameData:getNodeWithKey("data");
                game_data:setTeamByJsonData(data:getNodeWithKey("alignment"));
                game_data:setFormationDataByJsonData(data:getNodeWithKey("formation"));
                game_data:setEquipPosDataByJsonData(data:getNodeWithKey("equip_pos"));
                game_data:setAssistantByJsonData(data:getNodeWithKey("assistant"));
                game_data:setGemPosDataByJsonData(data:getNodeWithKey("gem_pos"));
            end
            callBackFunc();
        end
        -- align_1=1_2&align_2=3_4
        local teamTable = game_data:getTeamData();
        local prarms = "align_1=";
        for k = 1,5 do
            if teamTable[k] == nil then
                prarms = prarms .. "-1" .. (k == 5 and "" or "_")
            else
                prarms = prarms .. teamTable[k] .. (k == 5 and "" or "_")
            end
        end
        prarms = prarms .. "&align_2="
        for k = 6,10 do
            if teamTable[k] == nil then
                prarms = prarms .. "-1" .. (k == 10 and "" or "_") 
            else
                prarms = prarms .. teamTable[k] .. (k == 10 and "" or "_") 
            end
        end 
        local equipPosData = game_data:getEquipPosData();
        for i=1,10 do
            cclog(" i ================= " .. i)
            table.foreach(equipPosData[tostring(i-1)],print)
            if i < 6 then
                prarms = prarms .. "&equip_1" .. i .. "="
            else
                prarms = prarms .. "&equip_2" .. (i-5) .. "="
            end
            for k,v in pairs(equipPosData[tostring(i-1)]) do
                prarms = prarms .. v .. (k == 4 and "" or "_")
            end
        end
        local gemPosData = game_data:getGemPosData();
        for i=1,10 do
            -- cclog(" i ================= " .. i)
            -- table.foreach(gemPosData[tostring(i-1)],print)
            if i < 6 then
                prarms = prarms .. "&gem_1" .. i .. "="
            else
                prarms = prarms .. "&gem_2" .. (i-5) .. "="
            end
            for k,v in pairs(gemPosData[tostring(i-1)]) do
                prarms = prarms .. v .. (k == 4 and "" or "_")
            end
        end
        prarms = prarms .. "&formation=" .. self.m_selFormationId;
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_set_alignment"), http_request_method.GET, prarms,"cards_set_alignment")
    else
        callBackFunc();
    end
end

function game_hero_zhuanshiTask_map.initLayerTouch(self,touch_layer)
    local tempItem,selItem,realPos,tag,selCardId;
    local function onTouchBegan(x, y)
        -- CCTOUCHBEGAN event must return true
        selItem = nil;
        selCardId = nil;
        realPos = self.m_move_ndoe:convertToNodeSpace(ccp(x,y));
        for k,v in pairs(self.m_touchCardTab) do
            tempItem = v.heroAnimNode
            if tempItem:boundingBox():containsPoint(realPos) then
                selItem = tempItem;
                selCardId = v.cardId;
                break;
            end
        end
        return true
    end
    
    local function onTouchMoved(x, y)
    end
    
    local function onTouchEnded(x, y)
        realPos = self.m_move_ndoe:convertToNodeSpace(ccp(x,y));
        if selItem and selItem:boundingBox():containsPoint(realPos) then
            cclog("heor on click -----------------------------")
            local itemData,_ = game_data:getCardDataById(selCardId);
            if itemData then
                local function callBack(typeName)
                    typeName = typeName or ""
                    if typeName == "refresh" then
                        
                    end
                end
                game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 1,callBack = callBack})
            end
        end
        tempItem = nil;
        tag = nil;
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
    touch_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,false)
    touch_layer:setTouchEnabled(true)
end


function game_hero_zhuanshiTask_map.getTeamCardDataByPos(self,posIndex)
    return game_data:getCardDataById(self.m_tempTeamData[posIndex])
end
function game_hero_zhuanshiTask_map.createCardAnimByPosIndex(self,posIndex)
    local animNode = nil;
    local heroData,heroCfg = self:getTeamCardDataByPos(posIndex)
    if heroData and heroCfg then
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        animNode = game_util:createIdelAnim(ainmFile,0,heroData,heroCfg);
        if animNode then
            animNode:setRhythm(1);
            animNode:setAnchorPoint(ccp(0.5,0));
        end
    end
    return animNode;
end
--[[--
    初始化编队信息
]]
function game_hero_zhuanshiTask_map.initTeamFormation(self,formation_layer)
    local level = game_data:getUserStatusDataByKey("level");
    local itemIcon = nil;
    local headIconSpr = nil;
    local tempLock = nil;
    local character_detail_cfg = getConfig("character_detail");
    local tempLockIndex,selLevel = -1,100;
    for i=1,6 do
        itemIcon = self.m_ccbNode:spriteForName("m_pos_" .. i)
        formation_layer:reorderChild(itemIcon,-1000 + (i - 1)%3)
        local headIconBgSize = itemIcon:getContentSize();
        headIconSpr = itemIcon:getChildByTag(1)
        if headIconSpr then
            headIconSpr:removeFromParentAndCleanup(true);
        end
        headIconSpr = itemIcon:getChildByTag(2)
        if headIconSpr then
            headIconSpr:removeFromParentAndCleanup(true);
        end
        tempLock = itemIcon:getChildByTag(10);
        if self.m_openTab[i] == 1 then
            tempLock:setVisible(false);
        else
            itemIcon:setVisible(false);
        end
        local animNode = self:createCardAnimByPosIndex(i)
        if animNode then
            animNode:setPosition(ccp(headIconBgSize.width*0.5,10));
            itemIcon:addChild(animNode,1,1);
        end
    end
end

function game_hero_zhuanshiTask_map.getExchangeTeamDataByTwoPosFlag(self,posIndex1,posIndex2)
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
    cclog("posIndex1 = " .. posIndex1 .. " ; posIndex2 = " .. posIndex2)
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
    cclog("getExchangeTeamDataByTwoPosFlag == returnValue =" .. returnValue .. " ; count1 == " .. count1 .. " ; count2 = " .. count2)
    return returnValue;
end




function game_hero_zhuanshiTask_map.exchangeTeamDataByTwoPos(self,posIndex1,posIndex2)
    self.m_tempTeamData[posIndex1],self.m_tempTeamData[posIndex2] = self.m_tempTeamData[posIndex2],self.m_tempTeamData[posIndex1]
    self.m_tempEquipPosData[posIndex1],self.m_tempEquipPosData[posIndex2] = self.m_tempEquipPosData[posIndex2],self.m_tempEquipPosData[posIndex1]
    self.m_tempGemPosData[posIndex1],self.m_tempGemPosData[posIndex2] = self.m_tempGemPosData[posIndex2],self.m_tempGemPosData[posIndex1]
    self:setTeamFormationData();
end

function game_hero_zhuanshiTask_map.setTeamFormationData(self)
    local formationId = 1;
    local tempTeamData = {};
    local tempEquipPosData = {};
    local tempGemPosData = {};
    local emptyFlag = false;
    local tempCardId = nil;
    local tempEquipItem,tempGemItem = nil,nil;
    local tempCount = 1;
    for i=1,9 do
        tempCardId = self.m_tempTeamData[i]
        tempEquipItem = self.m_tempEquipPosData[i];
        tempGemItem = self.m_tempGemPosData[i];
        if i < 7 then
            if tempCardId == "-1" and emptyFlag == false then
                emptyFlag = true;
                formationId = i;
            else
                if tempCount < 6 then
                    tempTeamData[tempCount] = tempCardId
                    tempEquipPosData[tostring(tempCount-1)] = util.table_copy(tempEquipItem);
                    tempGemPosData[tostring(tempCount-1)] = util.table_copy(tempGemItem);
                    tempCount = tempCount + 1;
                end
            end
        else
            tempTeamData[tempCount] = tempCardId
            tempEquipPosData[tostring(tempCount-1)] = util.table_copy(tempEquipItem);
            tempGemPosData[tostring(tempCount-1)] = util.table_copy(tempGemItem);
            tempCount = tempCount + 1;
        end
    end

    for i=9,10 do
        tempTeamData[i] = "-1";
        tempEquipPosData[tostring(i-1)] = {"0","0","0","0"}
        tempGemPosData[tostring(i-1)] = {"0","0","0","0"}
    end
    -- table.foreach(tempTeamData,print)
    -- cclog("-------------- equip -----------------")
    -- for k,v in pairs(tempEquipPosData) do
    --     cclog("k ============ " .. k)
    --     table.foreach(v,print)
    -- end
    -- cclog("-------------- equip -----------------")
    cclog("formationId ================== " .. formationId)
    self.m_selFormationId = formationId;
    game_data:setTeamData(tempTeamData);
    game_data:setEquipPosData(tempEquipPosData);
    game_data:setGemPosData(tempGemPosData);
end

function game_hero_zhuanshiTask_map.initAdjustmentFormationTouch(self,formation_layer)
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
        for tag = 1,6 do
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
        -- self:setPositionBg(self.m_posIndex,true);
        if not touchMoveFlag and tempPosIndex then
            -- self:addTeamHeroPop(tempPosIndex);
        end
        if selItem and touchMoveFlag then
            for endTag = 1,6 do
                endItem = self.m_ccbNode:spriteForName("m_pos_" .. endTag)
                if endItem and endItem:isVisible() and endItem:boundingBox():containsPoint(realPos) then
                    local beganTag = beganItem:getTag();
                    if endTag ~= beganTag and self:getExchangeTeamDataByTwoPosFlag(beganTag,endTag) == 0 then
                        cclog("exchange ----------beganTag = " .. beganTag .. " ; endTag = " .. endTag);
                        self:exchangeTeamDataByTwoPos(beganTag,endTag);
                        self.m_changeFlag = true;
                        local bgSize = endItem:getContentSize();
                        local headIconSpr = beganItem:getChildByTag(1)
                        if headIconSpr then
                            headIconSpr:removeFromParentAndCleanup(true)
                        end
                        local animNode = self:createCardAnimByPosIndex(beganTag)
                        if animNode then
                            animNode:setPosition(ccp(bgSize.width*0.5,10));
                            beganItem:addChild(animNode,1,1)
                        --     self:setPositionBg(beganTag,true);
                        -- else
                        --     self:setPositionBg(beganTag,false);
                        end
                        local headIconSpr = endItem:getChildByTag(1)
                        if headIconSpr then
                            headIconSpr:removeFromParentAndCleanup(true)
                        end
                        local animNode = self:createCardAnimByPosIndex(endTag)
                        if animNode then
                            animNode:setPosition(ccp(bgSize.width*0.5,10));
                            endItem:addChild(animNode,1,1)
                        end
                        self.m_posIndex = endTag;

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

return game_hero_zhuanshiTask_map;