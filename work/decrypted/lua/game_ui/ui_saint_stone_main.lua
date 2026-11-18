---  圣石主页面

local ui_saint_stone_main = {
     m_screenShoot=nil,
   m_root_layer=nil,
   m_selHeroId=nil,
   m_selListItem=nil,
   m_stoneNodeTab=nil,
   m_tempCombatValue=nil,
   m_changeFlag=nil,
   m_openType=nil,
   m_callFunc=nil,
   m_tempSaintStonePosData=nil;
   m_SaintStonePosDataTab=nil;
   m_list_view_bg=nil,
   m_node_card=nil,
   m_label_name=nil,
   m_label_level=nil,
   m_combatNumberChangeNode=nil,
   m_label_effectTab=nil,
   m_btn_stoneTab=nil,
   m_ccbNode=nil,
   m_cardsTab1=nil,
   m_teamData=nil,
   m_formationId=nil,
   m_btnTag=nil,
   m_teamTag=nil,
   m_heroSaintStoneTable=nil,
   m_selSaintStonePos=nil,
   m_EquipPosDataTab=nil,
   m_GemPosDataTab=nil,
   m_tempSoulPosData=nil,
   m_tempMedalPosData=nil,
   m_tempTeamData=nil,
   m_selFormationId=nil,
};
--[[--
    销毁ui
]]
function ui_saint_stone_main.destroy(self)
    -- body
    cclog("-----------------ui_saint_stone_main destroy-----------------");
   self.m_screenShoot=nil;
   self.m_root_layer=nil;
   self.m_selHeroId=nil;
   self.m_selListItem=nil;
   self.m_stoneNodeTab=nil;
   self.m_tempCombatValue=nil;
   self.m_changeFlag=nil;
   self.m_openType=nil;
   self.m_callFunc=nil;
   self.m_tempSaintStonePosData=nil;
   self.m_SaintStonePosDataTab=nil;
   self.m_list_view_bg=nil;
   self.m_node_card=nil;
   self.m_label_name=nil;
   self.m_label_level=nil;
   self.m_combatNumberChangeNode=nil;
   self.m_label_effectTab=nil;
   self.m_btn_stoneTab=nil;
   self.m_ccbNode=nil;
   self.m_cardsTab1=nil;
   self.m_teamData=nil;
   self.m_formationId=nil;
   self.m_btnTag=nil;
   self.m_teamTag=nil;
   self.m_heroSaintStoneTable=nil;
   self.m_selSaintStonePos=nil;
   self.m_EquipPosDataTab=nil;
   self.m_GemPosDataTab=nil;
   self.m_tempSoulPosData=nil;
   self.m_tempMedalPosData=nil;
   self.m_tempTeamData=nil;
   self.m_selFormationId=nil;
end




--[[--
    返回
]]
function ui_saint_stone_main.back(self,backType)
    -- local function endCallFunc()
    --     self:destroy();
    -- end
    -- game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_main_scene",changeFlag = self.m_changeFlag});

end

function ui_saint_stone_main.aligment(self)
    local function responseMethod(tag,gameData)
        if gameData ~= nil then
            local data = gameData:getNodeWithKey("data");
            cclog2(data,"data inf aligment...")
             game_scene:enterGameUi("saint_stone_upgrade",{gameData = nil});
            game_data:setSaintStonePosDataByJsonData(data:getNodeWithKey("god_stone_pos"));
        else
            game_util:addMoveTips({text = "Yêu cầu thất bại, hãy thử lại!"});
        end
    end
    -- align_1=1_2&align_2=3_4
    -- local teamTable = game_data:getTeamData();
    -- local prarms = "align_1=";
    --圣石
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
    local saintStonePosData = game_data:getSaintStonePosData();
    for i=1,10 do
        -- cclog(" i ================= " .. i)
        -- table.foreach(gemPosData[tostring(i-1)],print)
        if i < 6  then
            prarms = prarms .. "&god_stone_1" .. i .. "="
        else
            prarms = prarms .. "&god_stone_2" .. (i-5) .. "="
        end
        for k,v in pairs(saintStonePosData[tostring(i-1)] or {}) do
            prarms = prarms .. v .. (k == 5 and "" or "_")
        end
    end
     prarms = prarms .. "&formation=" .. self.m_selFormationId;
    cclog2(prarms,"prarms is")
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_stone_alignment"), http_request_method.POST, prarms,"god_stone_alignment")

end
--[[--
    读取ccbi创建ui
]]
function ui_saint_stone_main.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag==101 then  --升级
            self.aligment(self)
           

        elseif btnTag==102 then --背包
           game_scene:addPop("saint_stone_system_select_pop",{openType=1})

        -- elseif btnTag==103 then --卡牌
        --     local btnCallFunc = function( target,event )
        
        --     end
        --     local itemOnClick = function (id)
        --         self.m_selHeroId=id;
        --         self:refreshCardImag(tostring(id))
        --         self.m_selListItem=nil;
        --         self:refreshTableView()
                
        --     end
        --        game_scene:addPop("game_hero_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,openType = 1});
        elseif btnTag>=201 and btnTag<=205 then
            if self.m_selHeroId~=nil then
                self:addSelGemUi(btnTag)
            else
                game_util:addMoveTips({text="Chọn thẻ bài"})
            end

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_saint_stone_main.ccbi");
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    
    self.m_list_view_bg = ccbNode:nodeForName("node_list_view_bg")
    self.m_root_layer = ccbNode:layerForName("layer_root")
    self.m_node_card=ccbNode:nodeForName("node_card")
    self.m_label_name=ccbNode:labelTTFForName("label_name")
    self.m_label_level=ccbNode:labelTTFForName("label_level")

    local btn_cards=ccbNode:controlButtonForName("btn_cards")
    btn_cards:setVisible(false)

    --comobat
    local m_combat_node = ccbNode:nodeForName("m_combat_node") 
     ---------------------       初始化战斗力显示node        --------------
    self.m_combatNumberChangeNode = game_util:createExtNumberChangeNode({labelType = 2});
    self.m_combatNumberChangeNode:setAnchorPoint(ccp(0, 0.5));
    -- self.m_combatNumberChangeNode:setScale(0.75);
    m_combat_node:addChild(self.m_combatNumberChangeNode);
    self.m_combatNumberChangeNode:setCurValue(0,false);

    --属性label
    self.m_label_effectTab={}
    for i=1,6 do 
        self.m_label_effectTab[i]=ccbNode:labelTTFForName("label_effect"..i)
    end

    --石头装备按钮
    self.m_btn_stoneTab={}
    for i=1,5 do
        self.m_btn_stoneTab[i]=ccbNode:controlButtonForName("btn_stone"..i)
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end

    --石头icon显示node
    self.m_stoneNodeTab={};
    for i=1,5 do 
        self.m_stoneNodeTab[i]=ccbNode:nodeForName("node_stone"..i)
    end

    

    if self.m_screenShoot then
        local tempSize = self.m_root_layer:getContentSize();
        self.m_screenShoot:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        self.m_root_layer:addChild(self.m_screenShoot,-1);
    end

    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    self.m_root_layer:setTouchEnabled(false);
    self.m_ccbNode = ccbNode
    return ccbNode;
end


function ui_saint_stone_main.setCardAnim(self,character_id)
    local function onAnimSectionEnd( animNode, theId,theLabelName )
        if theLabelName=="gongji1" then
            -- game_anim:playSection(animNode,"daiji")
            animNode:playSection("daiji");
        elseif theLabelName == "daiji" then
            animNode:playSection("gongji2");
            -- game_anim:playSection(animNode,"gongji2")
        elseif theLabelName=="gongji2" then
            -- game_anim:playSection(animNode,"gongji1")
            animNode:playSection("gongji1");
        end

    end
    local animNode = nil;
    -- local heroData,heroCfg = game_data:getCardDataById("8400")
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(character_id));
    if  heroCfg then
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        animNode = game_util:createIdelAnim(ainmFile,0,heroData,heroCfg);
        if animNode then
            animNode:setRhythm(1);
            game_anim:playSection(animNode , anim_label_name_cfg.daiji);
             --animNode:registerScriptTapHandler(onAnimSectionEnd)
            local itemSize = animNode:getContentSize();
            animNode:setAnchorPoint(ccp(0.5,0.5));
            animNode:setPosition(ccp(5,27))
        end
    end
    return animNode;
end

--卡牌列表（主阵、命运、助威）
function ui_saint_stone_main.createTableView(self,viewSize)
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
    end
   
    
    local itemCount = #self.m_cardsTab1
   
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 8;
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 5;
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height/params.row);
    -- self.m_cellSize = itemSize
    -- self.m_cellCount = itemCount
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell();
        if cell == nil then 
            cell = CCTableViewCell:new()
            cell:autorelease();
            
        end
        if cell then  
            cell:removeAllChildrenWithCleanup(true)
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_saint_stone_system_synthesis_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);

            local cardId=self.m_cardsTab1[index+1]
            local cardData,heroCfg = game_data:getCardDataById(tostring(cardId));
             
            local c_id=cardData["c_id"]
            --local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_sel_img = ccbNode:spriteForName("m_sel_img")

           
            local icon =game_util:createCardIconByCid(c_id)
            icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
            cell:addChild(icon)

            
            if  self.m_selHeroId == cardId then
                m_sel_img:setVisible(true);
                self.m_selListItem = cell;
            end

        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" then
         
            --刷新选择角色动画
            local cardId=self.m_cardsTab1[index+1]
            -- self.m_selHeroId=cardId;
        
            
            

            if self.m_selHeroId == nil or self.m_selHeroId ~= cardId then

                if self.m_selListItem then --此时self.m_selListItem为上次的cell
                    local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                    local m_sel_img = ccbNode:spriteForName("m_sel_img")
                    m_sel_img:setVisible(false);
               
                end

                --取当前的cell
                self.m_selListItem = cell;

                --当前选择的卡牌id
                self.m_selHeroId = cardId;
                -- cclog2(self.m_selHeroId,"heroid")

                for k,v in pairs(self.m_teamData) do 
                    if v==self.m_selHeroId then
                        self.m_posIndex=k
                    end

                end
                --cclog2( self.m_posIndex," self.m_posIndexsisisi")

                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
            
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                m_sel_img:setVisible(true);
                self:refreshCardImag(cardId)
            end
           
        end
    end
    return TableViewHelper:create(params)

end


--刷新卡牌形象
function ui_saint_stone_main.refreshCardImag(self,cardId)

    self.m_node_card:removeAllChildrenWithCleanup(true)
    local cardData,heroCfg = game_data:getCardDataById(tostring(cardId));
    -- local ccbNode = game_util:createHeroListItemByCCB(cardData);
    -- self.m_node_card:addChild(ccbNode,10,10);
 
    local levelLabel=cardData["lv"];
    local step=cardData["step"]
    local name=heroCfg:getNodeWithKey("name"):toStr();
    if step ==0 then
        self.m_label_name:setString(tostring(name))
    else
        self.m_label_name:setString(tostring(name).."+"..step)
    end
    self.m_label_level:setString("Lv."..tostring(levelLabel))
    local anim=self:setCardAnim(cardData.c_id)
    self.m_node_card:addChild(anim,100,100)



    for k,v in pairs(self.m_teamData) do 
        if self.m_selHeroId==v then
            self.m_posIndex=k
        end
    end
    self:refreshStone(self.m_posIndex)

end


function ui_saint_stone_main.addSelGemUi(self,btntag)
    self.m_btnTag=btntag;

    for k,v in pairs(self.m_teamData) do 
        if self.m_selHeroId==v then
            self.m_posIndex=k
        end
    end

   
    local btnCallFunc = function( target,event )

    end

    local itemOnClick = function (typeName,id)
        if typeName == "exchanged" then
            self.m_changeFlag=true;
            self.m_btn_stoneTab[self.m_btnTag-200]:removeChildByTag(10,true)
            self.m_stoneNodeTab[self.m_btnTag-200]:removeChildByTag(10,true)
            game_scene:removePopByName("saint_stone_system_select_pop");
            
            

            for k,v in pairs(self.m_teamData) do 
                if self.m_selHeroId==v then
                    self.m_posIndex=k
                end
            end
            -- if self.m_posIndex>6 then
            --     self.m_posIndex=self.m_posIndex-1
            -- end
            
            self:updateSaintStonePosData(self.m_posIndex,btntag-200,id);
            self:refreshStone(self.m_posIndex)
            -- local tempIcon,gemName = game_util:createSaintStoneIconByCid(id);
            -- if tempIcon then
            --     tempIcon:setAnchorPoint(ccp(0,0))
            --     tempIcon:setPosition(ccp(0,0))
            --     self.m_btn_stoneTab[self.m_btnTag-200]:addChild(tempIcon,10,10)
            -- end

        elseif typeName == "unload" then
            self.m_btn_stoneTab[self.m_btnTag-200]:removeChildByTag(10,true)
            self.m_stoneNodeTab[self.m_btnTag-200]:removeChildByTag(10,true)
            game_scene:removePopByName("saint_stone_system_select_pop");
            self:updateSaintStonePosData(self.m_posIndex,btntag-200,"0");
           -- cclog("itemOnClick remove id ==================== ");
            self.m_changeFlag = true;
            self:refreshStone(self.m_posIndex)
           
        end
    end
    game_scene:addPop("saint_stone_system_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,sortBtnShow = false,tag=self.m_btnTag-200,openType = 2,stoneTable=self.m_heroSaintStoneTable})
end



function ui_saint_stone_main.updateSaintStonePosData(self,tempPos,tempType,tempId)
    if tempPos > 9 or tempPos < 0 or tempType > 5 or tempType < 1 then return end
   -- cclog("updateSaintStonePosData tempPos = " .. tempPos .. " ; tempType = " .. tempType .. " ; tempId = " .. tempId);
    local posGemId = tostring(self.m_tempSaintStonePosData[tempPos][tempType]);
    tempId = tostring(tempId);
    game_data:addSaintStoneDataByCid(posGemId,1)
    game_data:minusSaintStoneDataCid(tempId,1)
    self.m_tempSaintStonePosData[tempPos][tempType] = tempId;
    -- cclog("updateGemPosData = " .. json.encode(self.m_tempGemPosData))
    self:setTeamFormationData();

end

function ui_saint_stone_main.setTeamFormationData(self)
    local formationId = 1;
   local tempTeamData = {};
    local tempSaintStonePosData = {};
    local emptyFlag = false;
    local tempCardId = nil;
    local tempSaintStoneItem = nil

    local tempCount = 1;
    for i=1,9 do
        tempCardId = self.m_teamData[i]
        tempSaintStoneItem = self.m_tempSaintStonePosData[i];

        if i < 7 then
            if tempCardId == "-1" and emptyFlag == false then
                emptyFlag = true;
                formationId = i;
            else
                if tempCount < 7 then
                   
                    tempTeamData[tempCount] = tempCardId
                    tempSaintStonePosData[tostring(tempCount-1)] = util.table_copy(tempSaintStoneItem);
                    tempCount = tempCount + 1;
                end
            end
        else
            tempTeamData[tempCount] = tempCardId
            tempSaintStonePosData[tostring(tempCount-1)] = util.table_copy(tempSaintStoneItem);
            tempCount = tempCount + 1;
        end
    end
    for i=9,10 do
        tempTeamData[i] = "-1";
        tempSaintStonePosData[tostring(i-1)] = {"0","0","0","0","0"}
    end
    self.m_selFormationId = formationId;
 
    game_data:setTeamData(tempTeamData);
    game_data:setSaintStonePosData(tempSaintStonePosData);
  
end

--刷新圣石效果label
function ui_saint_stone_main.refreshEffectLabel( self ,posIndex)
    for i=1,5 do 
        self.m_label_effectTab[i]:setString("")
    end


    local gemCfg=getConfig(game_config_field.god_stone)
    local gemData = self.m_tempSaintStonePosData[posIndex]
    local gemPosData={}
    for k,v in pairs(gemData) do
        if v~="0" then
            table.insert(gemPosData,v)
        end
    end

  
    for i=1,#gemPosData do
        local id=gemPosData[i]
        if id ~="0" then
            local itemCfg = gemCfg:getNodeWithKey(id);
            local attrName1,value1,icon1,attrName2,value2,icon2 = game_util:getSaintStoneAttributeValue(itemCfg);
            self.m_label_effectTab[i]:setString(attrName1.."+"..value1.."%")
        end
    end

    self:refreshCombatLabel();
end

--刷新装备圣石
function ui_saint_stone_main.refreshStone(self,posIndex)
    for i=1,5 do 
        self.m_stoneNodeTab[i]:removeAllChildrenWithCleanup(true)
    end

    if posIndex and posIndex > 0 and posIndex < 10 then
        local tempNode = nil;
        local tempNode2=nil;
        local j=1
        local gemPosData = self.m_tempSaintStonePosData[posIndex]
        self.m_heroSaintStoneTable=gemPosData;
        if gemPosData then
            --cclog("posIndex == " .. posIndex .. " ; gemPosData ======= " .. json.encode(gemPosData))
            local noUseGemCountTab = game_data:getNoUseSaintStoneCountTab();
            for i=1,5 do
                
                tempNode =self.m_btn_stoneTab[i]
                tempNode2=self.m_stoneNodeTab[j]

                if tempNode then
                    tempNode:removeChildByTag(10,true)
                    tempNode:removeChildByTag(11,true)
                    tempNode:removeChildByTag(12,true)
                    tempNode2:removeChildByTag(10,true)
                    tempNode2:removeChildByTag(11,true)
                    local tempNodeSize = tempNode:getContentSize();
                    local id = gemPosData[i];
                    if id and tostring(id) ~= "0" then
                        -- local tempItemData,tempItemCfg = game_data:getGemDataById(tostring(id));
                        -- local tempIcon = game_util:createGemIconByCfg(tempItemCfg);
                        local tempIcon,gemName = game_util:createSaintStoneIconByCid(id);
                        local tempIcon2 = game_util:createSaintStoneIconByCid2(id);
                        if tempIcon then
                            tempIcon:setPosition(ccp(tempNodeSize.width*0.5,tempNodeSize.height*0.5))
                           
                            tempNode:addChild(tempIcon,10,10)
                            tempNode2:addChild(tempIcon2,10,10)
                            j=j+1;
                            if self.m_selSaintStonePos == i then
                                tempIcon:setScale(2.0);
                                local animArr = CCArray:create();
                                animArr:addObject(CCSpawn:createWithTwoActions(CCEaseIn:create(CCScaleTo:create(0.5,1.0),5),CCFadeIn:create(0.5)));
                                animArr:addObject(CCScaleTo:create(0.1,1.2));
                                animArr:addObject(CCScaleTo:create(0.1,1.0));
                                tempIcon:runAction(CCSequence:create(animArr));
                                self.m_selSaintStonePos = nil;
                            end
                        end
                        if gemName then
                            local tempLabel = game_util:createLabelTTF({text = gemName,color = ccc3(250,255,0),fontSize = 10});
                            
                            tempLabel:setPosition(ccp(tempNodeSize.width*0.5,-tempNodeSize.height*0.5))
                            tempNode:addChild(tempLabel,11,11)
                            
                        else
                            -- cclog("equipIndex == " .. i .. " ; equipId == " .. tostring(id));
                        end
                         local gemCfg = getConfig(game_config_field.god_stone);
                         local itemCfg = gemCfg:getNodeWithKey(tostring(id));
                        if itemCfg == nil then return nil,nil end
                        local gemName2=itemCfg:getNodeWithKey("first_name"):toStr()
                        local tempLabel2 = game_util:createLabelTTF({text = gemName2,color = ccc3(250,255,0),fontSize = 10});
                        tempLabel2:setPosition(ccp(tempNodeSize.width*0.5,-tempNodeSize.height*0.25))
                        tempNode:addChild(tempLabel2,12,12)
                    else
                        if noUseGemCountTab[i] > 0 then
                            -- local tempSpri = CCSprite:createWithSpriteFrameName("public_kezhuangbei.png")
                            -- tempSpri:setPosition(ccp(tempNodeSize.width*0.5,tempNodeSize.height*0.5))
                            -- tempNode:addChild(tempSpri,10,10)
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
    self:refreshEffectLabel(posIndex)

end


function ui_saint_stone_main.refreshTableView(self)
    --self:getCardInTeam();
    self.m_list_view_bg:removeAllChildrenWithCleanup(true)
    local viewSize=self.m_list_view_bg:getContentSize()
    local tableView=self:createTableView(viewSize)
    self.m_list_view_bg:addChild(tableView)
end

--[[--
    刷新ui
]]
function ui_saint_stone_main.refreshUi(self)
    self:getCardInTeam();

    local viewSize=self.m_list_view_bg:getContentSize()
    local tableView=self:createTableView(viewSize)
    self.m_list_view_bg:addChild(tableView)

    if self.m_selHeroId then
        self:refreshCardImag(self.m_selHeroId)
    end
    self:refreshCombatLabel();
    

end


--[[--
    刷新战斗力
]]
function ui_saint_stone_main.refreshCombatLabel(self)
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



--获取主阵、命运、助威的卡牌的id table
function ui_saint_stone_main.getCardInTeam(self)
    self.m_cardsTab1={}
    if self.m_openType ==1 then
        local m_cardsTab2={}
        local m_cardsTab3={}
       
       
        local getTeamData=game_data:getTeamData();
        for i=1,#getTeamData do 
            if tostring(getTeamData[i])~= tostring(-1) and tostring(getTeamData[i])~= tostring(0) then
               
                table.insert(self.m_cardsTab1,getTeamData[i])
            end
        end
        -- local getAssistant=game_data:getAssistant();
     
        -- for i=1,#getAssistant do 
        --     if tostring(getAssistant[i])~= tostring(-1) and tostring(getAssistant[i])~= tostring(0) then
              
        --         table.insert(m_cardsTab2,getAssistant[i])
        --     end
        -- end
        -- local getDestiny=game_data:getDestiny();

        -- for i=1,#getDestiny do 
        --     if tostring(getDestiny[i])~= tostring(-1) and tostring(getDestiny[i])~= tostring(0) then
              
        --         table.insert(m_cardsTab3,getDestiny[i])
        --     end

        -- end
        -- for k,v in pairs(m_cardsTab2) do 
        --     table.insert(self.m_cardsTab1,v)
        -- end
        -- for k,v in pairs(m_cardsTab3) do
        --     table.insert(self.m_cardsTab1,v)
        -- end

    elseif self.m_openType==2 then --神域阵

        for k,v in  pairs(self.m_god_teamData) do 
            if v~= tostring(-1) and v~= tostring(0) then
               
                table.insert(self.m_cardsTab1,v)
            end
        end
         
    end

end

local formationPosTab = {{key="position_a",x=0.82,y=0.83},{key="position_b",x=0.82,y=0.5},{key="position_c",x=0.82,y=0.17},{key="position_d",x=0.5,y=0.83},{key="position_e",x=0.5,y=0.5},{key="position_f",x=0.5,y=0.17}};
--[[--
    初始化
]]
function ui_saint_stone_main.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then

    end
    
    self.m_selHeroId=t_params.selectedId or nil;
    self.m_openType=t_params.openType or 1;
    self.m_god_formation_index=t_params.formation or nil;
    self.m_god_teamData=t_params.godTeam or nil
    self.m_posIndex=t_params.posIndex or nil
    self.m_changeFlag=t_params.changeFlag or false
    
    self.m_tempTeamData = {};
    self.m_tempSaintStonePosData = {};
    local formationData = game_data:getFormationData();
    local ownFormation = formationData.own
    local ownFormationCount = #ownFormation
    self.m_currentFormationId = formationData.current
    --cclog("self.m_currentFormationId=====" .. self.m_currentFormationId);
    self.m_selFormationId = self.m_currentFormationId;
    local teamData = game_data:getTeamData();
    --cclog2(teamData,"teamData is")
    local tempSaintStonePosData = game_data:getSaintStonePosData();
    local formationConfig = getConfig(game_config_field.formation);
    local itemCfg = formationConfig:getNodeWithKey(tostring(self.m_selFormationId));
    local tempTag = 1;
    local iValue = nil;
    if itemCfg ~= nil then
        for i=1,#formationPosTab do
            local formationPosTabItem = formationPosTab[i];
            -- cclog(itemCfg:getFormatBuffer())
            -- cclog("formationPosTabItem.key =========" .. formationPosTabItem.key .. " ; itemCfg = " .. tostring(itemCfg))
            iValue = itemCfg:getNodeWithKey(formationPosTabItem.key):toInt();
            if iValue ~= 0 and tempTag < 7 then
                 self.m_tempTeamData[i] = teamData[tempTag]
                self.m_tempSaintStonePosData[i] = util.table_copy(tempSaintStonePosData[tostring(tempTag-1)]);
               
                tempTag = tempTag + 1;
            else
                self.m_tempTeamData[i] = "-1";
                self.m_tempSaintStonePosData[i] = {"0","0","0","0","0"}
             
            end
        end
    end
    for i=6,8 do
         self.m_tempTeamData[i+1] = teamData[i];
        self.m_tempSaintStonePosData[i+1] = util.table_copy(tempSaintStonePosData[tostring(i-1)]);
    end
    game_util:getFormationPos()
    self.m_teamData=self.m_tempTeamData;
    --cclog2(self.m_teamData,"self.m_teamData is")
end

--[[--
    创建ui入口并初始化数据
]]
function ui_saint_stone_main.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    -- game_data:updateShowTips( "cmdr_energy" , "have_show")

    return scene;
end


return ui_saint_stone_main;