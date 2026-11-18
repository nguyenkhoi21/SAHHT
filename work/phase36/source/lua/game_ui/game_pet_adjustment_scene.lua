---  宠物列表

local game_pet_adjustment_scene = {

    m_selListItem = nil,        -- 选中的宠物
    m_combatNumberChangeNode = nil,  -- 战斗力显示node
    m_tempCombatValue = nil,         -- 战斗力

    m_sel_btn = nil,        --  选取宠物按钮 -- 宠物展示底板
    node_anim = nil,        --  宠物卡牌像节点
    node_attr_list = nil,   --  宠物属性

    m_story_label = nil,   -- 宠物story文字

    m_formation_layer = nil,  -- 阵型显示
    
    m_list_view_bg = nil,
    m_tableView = nil,
    m_ccbNode = nil,
    m_posIndex = nil,
    m_tempTeamData = nil,

    m_tips_spr_1 = nil,
    m_light_bg_1 = nil,
    m_sel_btn = nil,
    m_anim_node = nil,
    node_pet_story = nil,
    node_star_board = nil,
    node_attr_list = nil,
    node_skill_list = nil,
    node_intro_msg_board = nil,
    label_pet_name = nil,
    m_life_label = nil,
    m_physical_atk_label = nil,
    m_magic_atk_label = nil,
    m_def_label = nil,
    m_speed_label = nil,
    m_life_label2 = nil,
    m_physical_atk_label = nil,
    m_magic_atk_label2 =nil,
    m_def_label2 = nil,
    m_speed_label2 = nil,
    m_replace_btn = nil,
    m_sel_bg = nil,
    m_cur_select_id = nil,
    m_selcet_index = nil,
    m_tempSelIndex = nil,
};
--[[--
    销毁ui
]]
function game_pet_adjustment_scene.destroy(self)
    -- body
    cclog("-----------------game_pet_adjustment_scene destroy-----------------");

    self.m_selListItem = nil;
    self.m_combatNumberChangeNode = nil;
    self.m_tempCombatValue = nil;

    self.node_anim  = nil;
    self.node_attr_list = nil;

    self.m_list_view_bg = nil;
    self.m_story_label = nil;

    self.m_formation_layer = nil;
    
    self.m_tableView = nil; 
    self.m_ccbNode = nil;
    self.m_posIndex = nil;
    self.m_tempTeamData = nil;

    self.m_tips_spr_1 = nil;
    self.m_light_bg_1 = nil;
    self.m_sel_btn = nil;
    self.m_anim_node = nil;
    self.node_pet_story = nil;
    self.node_star_board = nil;
    self.node_attr_list = nil;
    self.node_skill_list = nil;
    self.node_intro_msg_board = nil;

    self.label_pet_name = nil;
    self.m_life_label = nil;
    self.m_physical_atk_label = nil;
    self.m_magic_atk_label = nil;
    self.m_def_label = nil;
    self.m_speed_label = nil;
    self.m_life_label2 = nil;
    self.m_physical_atk_label = nil;
    self.m_magic_atk_label2 =nil;
    self.m_def_label2 = nil;
    self.m_speed_label2 = nil;
    self.m_replace_btn = nil;
    self.m_sel_bg = nil;
    self.m_cur_select_id = nil;
    self.m_selcet_index = nil;
    self.m_tempSelIndex = nil;
end

local formationPosTab = {{key="position_a",x=0.82,y=0.83},{key="position_b",x=0.82,y=0.5},{key="position_c",x=0.82,y=0.17},{key="position_d",x=0.5,y=0.83},{key="position_e",x=0.5,y=0.5},{key="position_f",x=0.5,y=0.17}};

--[[--
    返回
]]
function game_pet_adjustment_scene.back(self,backType)
    -- game_scene:enterGameUi("game_main_scene",{gameData = nil});
    self:sendChangedData(1)
end

function game_pet_adjustment_scene.sendChangedData(self,btnTag,t_params)
    local function tempFunction()
        if btnTag == 1 then--返回
            -- self:back();
            game_scene:enterGameUi("game_main_scene",{gameData = nil});
        elseif btnTag == 100 then
            game_scene:enterGameUi("skills_replacement_scene",{gameData = nil,selPosIndex = t_params.posIndex});
            self:destroy();
        end
    end
    if self.m_changeFlag == true then
        local function responseMethod(tag,gameData)
            if gameData ~= nil then
                local data = gameData:getNodeWithKey("data");
                -- game_data:setTeamByJsonData(data:getNodeWithKey("alignment"));
                -- game_data:setFormationDataByJsonData(data:getNodeWithKey("formation"));
                -- game_data:setEquipPosDataByJsonData(data:getNodeWithKey("equip_pos"));
                -- game_data:setAssistantByJsonData(data:getNodeWithKey("assistant"));
                -- game_data:setGemPosDataByJsonData(data:getNodeWithKey("gem_pos"));
                game_data:setPetTeamByJsonData(data:getNodeWithKey("pet_pos"));
                self.m_changeFlag = false;
                tempFunction();
            else
                game_util:addMoveTips({text = "Tư liệu tải thất bại ,xin tạo mới lại !"});
            end
        end
        local prarms = ""
        local pet_pos = ""
        for i=1,#self.m_tempTeamData do
            if i < 9 then
                pet_pos = pet_pos .. self.m_tempTeamData[i] .. "_"
            else
                pet_pos = pet_pos .. self.m_tempTeamData[i]
            end
        end
        prarms = prarms .. "&formation=" .. pet_pos;
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("set_pet_formation"), http_request_method.POST, prarms,"set_pet_formation")
    else
        tempFunction();
    end
end
--[[--
    读取ccbi创建ui
]]
function game_pet_adjustment_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then 
            -- game_scene:enterGameUi("game_main_scene");
            self:back()
        elseif btnTag == 3 then 

        elseif btnTag == 11 then
            if self.m_posIndex == -1 or self.m_tempTeamData[self.m_posIndex] == "-1" or self.m_tempTeamData[self.m_posIndex] == "0" then return end
            self:addSelHeroUi(self.m_posIndex);
        elseif btnTag == 103 then   -- 升级 
            game_scene:addPop("game_pet_upgrade_pop",{})
        elseif btnTag == 104 then   -- 强化
            game_scene:addPop("game_pet_strengthen_pop",{})
        elseif btnTag == 105 then  -- 升星
            game_scene:addPop("game_pet_upstar_pop",{})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pet_adjustment_scene.ccbi");
    self.m_ccbNode = ccbNode
    --英雄相关
    ---------------------       玩家信息  食物 战力           -------------------
    local m_combat_node = ccbNode:nodeForName("m_combat_node")                   -- 战斗力底板

    ---------------------       宠物列表相关node初始化        -------------------
    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg")   ---- 宠物列表底板

    ---------------------       宠物形象展示  ---------------
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")                      
    self.m_light_bg_1 = ccbNode:scale9SpriteForName("m_light_bg_1");
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn")   -- 
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")

    ---------------------       宠物信息息相关               -------------------------
    self.node_pet_story = ccbNode:nodeForName("node_pet_story")   -- 宠物描述信息底板
    self.node_star_board = ccbNode:nodeForName("node_star_board")   -- 宠物的星级
    self.node_attr_list = ccbNode:nodeForName("node_attr_list")     -- 宠物属性底板
    self.node_skill_list = ccbNode:nodeForName("node_skill_list")   -- 宠物技能底板
    self.node_intro_msg_board = ccbNode:nodeForName("node_intro_msg_board")   -- 宠物描述的底板

    --
    self.label_pet_name = ccbNode:labelTTFForName("label_pet_name")   -- 名字

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

    ---------------------       初始化战斗力显示node        --------------
    self.m_combatNumberChangeNode = game_util:createExtNumberChangeNode({labelType = 2});
    self.m_combatNumberChangeNode:setAnchorPoint(ccp(0, 0.5));
    -- self.m_combatNumberChangeNode:setScale(0.75);
    m_combat_node:addChild(self.m_combatNumberChangeNode);
    self.m_combatNumberChangeNode:setCurValue(0,false);

    ------------------
    self.m_cur_select_id = nil
    self.m_selcet_index = nil                           -- 当前选中的宠物列表的index
    self.m_tempSelIndex = nil

    ------------   右边阵型   --------------------
    self.m_formation_layer = ccbNode:layerColorForName("m_formation_layer")
    self.m_replace_btn = ccbNode:controlButtonForName("m_replace_btn")
    self.m_sel_bg = ccbNode:spriteForName("m_sel_bg")
    self.m_sel_bg:setVisible(false);

    self:initTeamFormation(self.m_formation_layer);
    
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
    刷新宠物技能
]]
function game_pet_adjustment_scene.refreshPetSkills( self, petData, petCfg )
    if petData == nil then return end
    self.node_skill_list:removeAllChildrenWithCleanup(true);
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag  ===  ", btnTag)
        game_scene:addPop("game_pet_skill_pop",{ petId = self.m_cur_select_id, skill_index = btnTag })
    end

    local posxs = {
        {0.5},
        {0.35, 0.65},
        { 0.2, 0.5, 0.8},
        { 0.2, 0.5, 0.8, 10},
    }
    local bgSize = self.node_skill_list:getContentSize()
    local tempSize = CCSizeMake(60, 60);
    local skills = {}
    for i=1,3 do
        local skill = petData["s_" .. i]
        if skill then
            table.insert( skills, skill)
        end
    end
    if #skills > 0 then
        local posx = posxs[ #skills ]
        for i,v in ipairs( skills ) do
            print("skills", i,v)
            local tempNode = CCNode:create()
            tempNode:setContentSize( tempSize )
            local tempIcon = game_util:createPetSkillIconByCid(v.s, v.avail)
            if tempIcon then
                tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
                tempNode:addChild(tempIcon);
                self:createTouchButton(onBtnCilck, tempIcon, i)

                local avail = v.avail;
                local icon_size = tempIcon:getContentSize();

                local lvLabel = nil;
                local tempLabel = nil;
                if avail ~= 2 then
                    local lock_icon_spr = CCSprite:createWithSpriteFrameName("public_lock_icon.png");
                    lock_icon_spr:setPosition(icon_size.width*0.5,icon_size.height*0.5);
                    tempIcon:addChild(lock_icon_spr,5,5);
                else
                end
                local pet_skill_detail = getConfig(game_config_field.pet_skill_detail)
                local skillCfg = pet_skill_detail:getNodeWithKey(tostring(v.s))
                lvLabel = game_util:createLabel({text = "Lv." .. v.lv,color = ccc3(255, 255, 0)})
                lvLabel:setPosition(ccp(icon_size.width*0.5,icon_size.height*0.15));
                tempIcon:addChild(lvLabel,10,10);
                tempLabel = game_util:createLabelTTF({text = skillCfg:getNodeWithKey("skill_name"):toStr()})
                tempLabel:setPosition(ccp(icon_size.width*0.5,icon_size.height*1.2));
                tempIcon:addChild(tempLabel)
            end
            tempNode:setAnchorPoint( ccp( 0.5, 0.5))
            tempNode:setPosition( bgSize.width * (  posx[i] or 10), bgSize.height * 0.5 )
            tempNode:setScale( 0.75 )
            self.node_skill_list:addChild(tempNode)
        end
    end
end

--[[--
    初始化编队信息
]]
function game_pet_adjustment_scene.initTeamFormation(self,formation_layer)
    local level = game_data:getUserStatusDataByKey("level");
    local itemIcon = nil;
    local headIconSpr = nil;
    local tempLock = nil;
    local tempLockIndex,selLevel = -1,100;
    local smallTag1 = 1;
    local smallTag2 = 7;
    local tempTxt = nil;

    local pet_corral_cfg = getConfig(game_config_field.pet_corral);
    local sort = 0;
    for i=1,9 do
        local corral_cfg_item = pet_corral_cfg:getNodeWithKey(tostring(i))
        sort = corral_cfg_item:getNodeWithKey('sort'):toInt();
        itemIcon = self.m_ccbNode:spriteForName("m_pos_" .. i)
        formation_layer:reorderChild(itemIcon,-1000)
        local headIconBgSize = itemIcon:getContentSize();
        itemIcon:removeAllChildrenWithCleanup(true)
        if self.m_tempTeamData[i] ~= "-1" then
            if(sort == 1)then
                smallTag1 = i+1;   
            else
                smallTag2 = i+1;
            end
        else
            tempLock = CCSprite:createWithSpriteFrameName("dw_suo.png");
            tempLock:setPosition(ccp(headIconBgSize.width/2,headIconBgSize.height/2));
            itemIcon:addChild(tempLock);
            local limit_lv = corral_cfg_item:getNodeWithKey("limit_lv"):toInt();
            if level < limit_lv then
                local tempLabel = game_util:createLabelBMFont({text = "cấp mở khóa:" .. limit_lv .. "cấp!",color = ccc3(0, 255, 0)});    
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
        local animNode = self:createPetAnimByPosIndex(i,false)
        if animNode then
            animNode:setPosition(ccp(headIconBgSize.width*0.5,headIconBgSize.height*0.1));
            itemIcon:addChild(animNode,1,1);
        end
        self:setPositionBg(i,true);
    end

    self:initAdjustmentFormationTouch(self.m_formation_layer);
end

--[[--
    编队位置点击的处理
]]
function game_pet_adjustment_scene.initAdjustmentFormationTouch(self,formation_layer)
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
                selItem = self:createPetAnimByPosIndex(tempPosIndex)
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

    local function onTouchEnded( x,y )
        local realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        local smallTag1 = 9;
        local smallTag2 = 9;
        local corral_cfg = getConfig(game_config_field.pet_corral);
        local sort = 0

        for endTag = 1,9 do
            local corral_cfg_item = corral_cfg:getNodeWithKey(tostring(endTag))
            sort = corral_cfg_item:getNodeWithKey('sort'):toInt();
            local tempid = self.m_tempTeamData[endTag]
            if tempid == "-1" then
                -- if(sort == 1)then
                    smallTag1 = math.min(smallTag1,endTag);
                -- else
                --     smallTag2 = math.min(smallTag2,endTag);
                -- end
            end
            endItem = self.m_ccbNode:spriteForName("m_pos_" .. endTag)
            if endItem and endItem:boundingBox():containsPoint(realPos) then
                local beganTag = beganItem:getTag();
                if(endTag == beganTag)then
                    if tempid == "-1" then
                        if(smallTag1 == endTag)then
                            local t_params = {}
                            t_params.okBtnCallBack = function()
                                local function responseMethod(tag,gameData)
                                    game_util:addMoveTips({text = "mở thành công !"});
                                    local petPosData = game_data:getPetTeamData();
                                    local tempData = util.table_copy(self.m_tempTeamData)
                                    self.m_tempTeamData = petPosData
                                    for k,v in pairs(tempData) do
                                        if v ~= "-1" then
                                            self.m_tempTeamData[k] = v;
                                        end
                                    end
                                    self:initTeamFormation(self.m_formation_layer);
                                    game_scene:removePopByName("game_pet_open_pop");
                                end
                                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pets_activate_pos"), http_request_method.GET, {pos = endTag-1},"pets_activate_pos")
                            end
                            t_params.index = endTag
                            game_scene:addPop("game_pet_open_pop",t_params)
                        end
                    elseif tempid == "0" then
                        self:addTeamHeroPop(tempPosIndex);
                    else
                        self.m_posIndex = endTag;
                        self:setPositionBg(endTag,true);
                        self:refreshHeroInfo(endTag);
                    end
                else
                    if selItem then
                        if tempid == "-1" then--未开启
                            game_util:addMoveTips({text = "Vị trí thú nuôi chưa mở !"})
                        else
                            self:exchangeTeamDataByTwoPos(beganTag,endTag)
                            self.m_changeFlag = true;
                            local bgSize = endItem:getContentSize();
                            beganItem:removeAllChildrenWithCleanup(true)
                            local animNode = self:createPetAnimByPosIndex(beganTag,false)
                            if animNode then
                                animNode:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.1));
                                beganItem:addChild(animNode,1,1)
                            end
                            self:setPositionBg(beganTag,true)
                            -- self:refreshFriendPositionAttr(beganTag)
                            endItem:removeAllChildrenWithCleanup(true)
                            local animNode = self:createPetAnimByPosIndex(endTag,false)
                            if animNode then
                                animNode:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.1));
                                endItem:addChild(animNode,1,1)
                            end
                            self:setPositionBg(endTag,true)
                            self.m_posIndex = endTag;
                            self:refreshHeroInfo(endTag);
                            self:refreshCombatLabel();
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
function game_pet_adjustment_scene.setSelPositionBg(self,posIndex)
    if posIndex == -1 or self.m_tempTeamData[posIndex] == "-1" or self.m_tempTeamData[posIndex] == "0" then return end
    local bgSprite = tolua.cast(self.m_formation_layer:getChildByTag(posIndex),"CCSprite");
    if bgSprite == nil then return end
    -- local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dw_characterBgSel.png");
    -- if tempDisplayFrame then
    --     bgSprite:setDisplayFrame(tempDisplayFrame);
        local pX,pY = bgSprite:getPosition();
        local anrPoint = bgSprite:getAnchorPoint()
        pX = pX + bgSprite:getContentSize().width * ( 0.5 - anrPoint.x) 
        pY = pY + bgSprite:getContentSize().height * (0.5 - anrPoint.y)
        local tempPos = self.m_formation_layer:convertToWorldSpace(ccp(pX,pY));
        local bg_real_pos = self.m_sel_bg:getParent():convertToNodeSpace( tempPos );
        self.m_sel_bg:setPosition(bg_real_pos);
        self.m_sel_bg:setVisible(true);
    -- end
end

function game_pet_adjustment_scene.formationOpenAnim(self)
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

function game_pet_adjustment_scene.createFormationOpenAnimByPos(self,pos)
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

function game_pet_adjustment_scene.getExchangeTeamDataByTwoPosFlag(self,posIndex1,posIndex2)
    -- local cardNumData = game_data:getBattleCardNumData()
    -- local maxCount1,maxCount2 = cardNumData.position_num or 2,cardNumData.alternate_num or 0;
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
        if cardId ~= "0" then
            count1 = count1 + 1;
        end
    end
    for i=7,9 do
        cardId = self.m_tempTeamData[i]
        if cardId ~= "0" then
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
            if self.m_tempTeamData[posIndex1] ~= "0" and self.m_tempTeamData[posIndex2] == "0" then
                count1 = count1 + 1;
                count2 = count2 - 1;
            end
        elseif posIndex1 < 7 and posIndex2 > 6 then--主站替补
            if self.m_tempTeamData[posIndex1] ~= "0" and self.m_tempTeamData[posIndex2] == "0" then
                count1 = count1 - 1;
                count2 = count2 + 1;
            end
        else
            returnValue = 1--
        end
    end
    if count1 ~= 0 then
        -- if count1 > maxCount1 or count1 > 5 then
        --     returnValue = 2;
        --     game_util:addMoveTips({text = string_config:getTextByKey("m_master_is_max")});
        -- elseif count2 > maxCount2 then
        --     returnValue = 3;
        --     game_util:addMoveTips({text = string_config:getTextByKey("m_substitute_is_max")});
        -- end
    else
        -- returnValue = 4;
        -- game_util:addMoveTips({text = string_config:getTextByKey("m_master_at_least_one")});
    end
    return returnValue;
end

function game_pet_adjustment_scene.exchangeTeamDataByTwoPos(self,posIndex1,posIndex2)
    self.m_tempTeamData[posIndex1],self.m_tempTeamData[posIndex2] = self.m_tempTeamData[posIndex2],self.m_tempTeamData[posIndex1]

    self:setTeamFormationData();
end

--[[--
    获得阵型相关的数据
]]
function game_pet_adjustment_scene.setTeamFormationData(self)
    game_data:setPetTeamData(self.m_tempTeamData);
end

--[[--
    
]]
function game_pet_adjustment_scene.addTeamHeroPop(self,posIndex)
    if self.m_tempTeamData[posIndex] == "0" then
        if self:judgeAddHero(posIndex) == 0 then
            self:addSelHeroUi(posIndex);
        end
    else
        cclog("posIndex == " .. posIndex)
        self.m_posIndex = posIndex;
        self:refreshHeroInfo(posIndex);
    end
end--[[--
    
]]
function game_pet_adjustment_scene.judgeAddHero(self,posIndex)
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
        if cardId ~= "0" then
            count1 = count1 + 1;
        end
    end
    for i=7,9 do
        cardId = self.m_tempTeamData[i]
        if cardId ~= "0" then
            count2 = count2 + 1;
        end
    end
    if posIndex < 7 then
        count1 = count1 + 1;
    else
        count2 = count2 + 1;
    end
    -- if count1 > maxCount1 or count1 > 5 then
    --     returnValue = 2;
    --     game_util:addMoveTips({text = string_config:getTextByKey("m_master_is_max")});
    -- elseif count2 > maxCount2 then
    --     returnValue = 3;
    --     game_util:addMoveTips({text = string_config:getTextByKey("m_substitute_is_max")});
    -- end
    return returnValue;
end
--[[--
    
]]
function game_pet_adjustment_scene.addSelHeroUi(self,posIndex)
    game_scene:removeGuidePop();
    -- cclog("addSelHeroUi posIndex ==" .. tostring(posIndex))
    local btnCallFunc = function( target,event )
        
    end
    local itemOnClick = function (typeName,id)
        -- cclog("typeName == " .. typeName)
        -- cclog2(id,"id")
        if typeName == "exchanged" then
            -- cclog2(self.m_tempTeamData,"self.m_tempTeamData")
            if (not game_util:heroInTeamById(id,self.m_tempTeamData)) then
                cclog("itemOnClick id ==================== " .. id);
                self:updateTeamData(posIndex,id);
                self.m_changeFlag = true;
                self:initTeamFormation(self.m_formation_layer);
                self.m_posIndex = posIndex;
                self:refreshHeroInfo(posIndex);
                -- self.m_chainTabBackUp = self.m_chainTab == nil and nil or util.table_copy(self.m_chainTab)
                -- self:newChainOpenAnim("card");
                -- cclog2(self.m_tempTeamData,"self.m_tempTeamData")
            end
        elseif typeName == "unload" then
            if self:getUnloadPosFlag(posIndex) == 0 then
                self:updateTeamData(posIndex,"0");
                self.m_changeFlag = true;
                self:initTeamFormation(self.m_formation_layer);
                self.m_posIndex = -1;
                self:refreshHeroInfo(posIndex);
                self:refreshCombatLabel();
            end
        end
    end
    game_scene:addPop("game_pet_select_scene",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,openType = 2})
end

function game_pet_adjustment_scene.updateTeamData(self,posIndex,petId)
    self.m_tempTeamData[posIndex] = petId;
    self:setTeamFormationData();
end

function game_pet_adjustment_scene.getUnloadPosFlag(self,posIndex)
    local returnValue = 0;
    local count1 = 0;
    if posIndex < 7 then
        local petId = nil;
        for i=1,6 do
            petId = self.m_tempTeamData[i]
            if petId ~= "0" then
                count1 = count1 + 1;
            end
        end
        if count1 < 2 and self.m_tempTeamData[posIndex] ~= "0" then
            returnValue = 2;
            game_util:addMoveTips({text = string_config:getTextByKey("m_master_at_least_one")});
        end
    end
    return returnValue;
end

--[[--
    
]]
function game_pet_adjustment_scene.setPositionBg(self,posIndex,aninFlag)
    if posIndex == -1 then return end
    local bgSprite = tolua.cast(self.m_formation_layer:getChildByTag(posIndex),"CCSprite");
    if bgSprite == nil then return end;
    local bgName = "";
    -- cclog2(self.m_tempTeamData,"self.m_tempTeamData----" .. posIndex)
    if self.m_tempTeamData[posIndex] == "0" then
        bgName = "dw_characterAdd.png"
    elseif self.m_tempTeamData[posIndex] == "-1" then
        bgName = "dw_characterAddtibu"
    else
        bgName = "dw_characterBg.png";
    end
    -- cclog2(bgName,"bgName")
    local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(bgName);
    if tempDisplayFrame then
        bgSprite:setDisplayFrame(tempDisplayFrame);
    end
end

--[[--
    创建动画
]]
function game_pet_adjustment_scene.createPetAnimByPosIndex(self,posIndex)
    local petData,petCfg = self:getTeamPetDataByPos(posIndex)
    return self:createPetAnimByData(petData,petCfg);
end

--[[--
    
]]
function game_pet_adjustment_scene.getTeamPetDataByPos(self,posIndex)
    return game_data:getPetDataById(self.m_tempTeamData[posIndex])
end

--[[
    获取小伙伴位置上的动画
]]
function game_pet_adjustment_scene.createPetAnimByData( self, petData,petCfg,animFlag)
    local animNode = nil;
    local pet_id = -1;
    if petData and petCfg then
        pet_id = petCfg:getNodeWithKey("pet_id"):toInt();
        local ainmFile = petCfg:getNodeWithKey("animation"):toStr();
        animFlag = animFlag == nil and true or animFlag
        if animFlag then
            animNode = game_util:createIdelAnim(ainmFile,0,petData,petCfg);
        else
            animNode = game_util:createCardImgByCfg(petCfg);
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
            -- local name_after = petData.step < 1 and "" or ("+" .. petData.step);
            local name = petCfg:getNodeWithKey("name"):toStr()
            local tempLabel = CCLabelTTF:create("Lv." .. petData.lv .. "/" .. petData.level_max .. "\n" .. name,TYPE_FACE_TABLE.Arial_BoldMT,10);
            tempLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
            tempLabel:setPosition(ccp(itemSize.width*0.5 - 50,97));
            tempLabel:setAnchorPoint(ccp(0,0.5));
            animNode:addChild(tempLabel,100,100)
            -- local occupation_cfg = getConfig(game_config_field.occupation);
            -- local occupation_item_cfg = occupation_cfg:getNodeWithKey(ainmFile)
            -- if occupation_item_cfg then
                -- local occupationType = occupation_item_cfg:toInt();
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. 1 .. ".png")
                if spriteFrame then
                    local occupation_icon = CCSprite:createWithSpriteFrame(spriteFrame)
                    occupation_icon:setPosition(ccp(itemSize.width*0.5 + 57,98));
                    occupation_icon:setAnchorPoint(ccp(1,0.5));
                    animNode:addChild(occupation_icon);
                end
            -- end
            animNode:setScale(0.66);
        end
    end
    return animNode,pet_id
end

--[[--
    刷新卡牌信息
]]
function game_pet_adjustment_scene.refreshHeroInfo(self,posIndex)
    local replaceStr = "thay đổi" 
    self.m_sel_bg:setVisible(false);
    self.m_selHeroId = nil;
    local tempNode = nil;
    local petData,petCfg = self:getTeamPetDataByPos(posIndex);

    local fate_detail_label_str = "không có";
    if petData and petCfg then
        local attrValueTab = {petData.patk_crystal,petData.matk_crystal,petData.def_crystal,petData.speed_crystal,petData.hp_crystal}
        --这个是属性改造等级
        local attrCfg = {"add_patk","add_matk","add_def","add_speed","add_hp"}
        self:setSelPositionBg(posIndex);
        self.m_cur_select_id = petData.id
        self.m_life_label:setString(math.floor(petData.hp));
        self.m_physical_atk_label:setString(math.floor(petData.patk));
        self.m_magic_atk_label:setString(math.floor(petData.matk));
        self.m_def_label:setString(math.floor(petData.def));
        self.m_speed_label:setString(math.floor(petData.speed));
        local ainmFile = petCfg:getNodeWithKey("animation"):toStr();
        -- local animNode = game_util:createHeroListItemByCCB(petData);
        -- self.m_anim_node:addChild(animNode);
        -- 1物攻 2魔攻 3防御 4速度 5生命
        -- local equipAttrValueTab = self:getPosEquipAttrValue(posIndex);--装备属性
        for i=1,5 do
            local abilityItem = PUBLIC_ABILITY_TABLE["ability_" .. i] or {}
            local attrValue = petData[abilityItem.attrName or ""] or 0
            -- attrValueTab[i] = math.floor(equipAttrValueTab[i] + attrValueTab2[i] + attrValue*cbmTab[i] + gemAttrValueTab[i] + attrValueTab3[i])

            --属性改造等级转成值
            if attrValueTab[i] > 0 then--改造属性大于1
                local pet_strengthen = getConfig(game_config_field.pet_strengthen)
                local itemStreng = pet_strengthen:getNodeWithKey(tostring(attrValueTab[i]))
                attrValueTab[i] = itemStreng:getNodeWithKey(attrCfg[i]):toInt()
            end
        end
        self.m_life_label2:setString("+" .. attrValueTab[5])
        self.m_physical_atk_label2:setString("+" .. attrValueTab[1])
        self.m_magic_atk_label2:setString("+" .. attrValueTab[2])
        self.m_def_label2:setString("+" .. attrValueTab[3])
        self.m_speed_label2:setString("+" .. attrValueTab[4])
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
        -- self.m_fate_label:setString("无")
        -- self.m_fate_detail_label:setString("无")
        if self.m_teamIndex == 2 then
            self:setSelPositionBg(posIndex);
        end
        replaceStr = "lên trận"
    end
    game_util:setCCControlButtonTitle(self.m_replace_btn,replaceStr)

    self:refreshPetInfo(self.m_tempTeamData[posIndex])
end
--[[
    更新宠物列表的item的状态
]]
function game_pet_adjustment_scene:updatePetListItem( cell, index, petId )
    local ccbNode = cell and tolua.cast(cell:getChildByTag(10),"luaCCBNode");
    if not ccbNode then return end
end

--[[--
    刷新状态
]]
function game_pet_adjustment_scene.refreshTips(self)

end

--[[--
    刷新战斗力
]]
function game_pet_adjustment_scene.refreshCombatLabel(self)
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

--[[--
    属性宠物信息
]]
function game_pet_adjustment_scene.refreshPetInfo(self, petId)
    self.m_cur_select_id = petId;
    -- self.m_anim_node:removeAllChildrenWithCleanup(true);
    self.m_selHeroData = nil;
    if petId ~= nil and petId ~= "0" then
        -- self.m_tips_spr_1:setVisible(false);
        -- self.m_tips_spr_2:setVisible(false);
        local cardData,heroCfg = game_data:getPetDataById(tostring(petId));
        self.m_selHeroData = cardData;

        -- local ccbNode = game_util:createHeroListItemByCCB(cardData);
        -- self.m_anim_node:addChild(ccbNode,10,10);

        -- cclog2(cardData, "cardData   ==============     ")
        -- cclog2(heroCfg, "heroCfg   ==============     ")

        -- 刷新宠物描述
        self:refreshPetStoryInfo( heroCfg )

        -- 刷新宠物属性信息
        -- self:refreshPetAttrs( cardData, heroCfg)

        -- 刷新宠物技能
        self:refreshPetSkills( cardData, heroCfg)
    end
    local flag = (self.m_status == 1)
    game_util:setCCControlButtonEnabled(self.m_ok_btn,not flag)
end

--[[
    刷新宠物描述信息
]]
function game_pet_adjustment_scene.refreshPetStoryInfo( self, petCfg )
    local story_cfg = petCfg and petCfg:getNodeWithKey("story")
    local story_msg = story_cfg and story_cfg:toStr() or ""
    if not self.m_story_label then
        self.node_intro_msg_board:removeAllChildrenWithCleanup(true)
        local tempSize = self.node_intro_msg_board:getContentSize()
        local labelsize = CCSizeMake( tempSize.width , 0);
        local m_fate_label = game_util:createRichLabelTTF({text = story_msg, dimensions = labelsize,
                textAlignment = kCCTextAlignmentLeft, verticalTextAlignment = kCCVerticalTextAlignmentTop,
            verticalTextAlignment = nil,color = ccc3(221,221,192)})
        m_fate_label:setAnchorPoint(ccp(0.5, 1));
        m_fate_label:setPosition(ccp( tempSize.width * 0.5 + 5, tempSize.height - 5))
        self.node_intro_msg_board:addChild( m_fate_label )
        self.m_story_label = m_fate_label
    else
        self.m_story_label:setString( story_msg )
    end
end

--[[--
    创建一个接受触摸事件的button
]]
function game_pet_adjustment_scene.createTouchButton( self, fun, parent, tag , anchorX, anchorY)
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

--[[
    刷新宠物属性
]]
function game_pet_adjustment_scene.refreshPetAttrs( self )
    self.node_attr_list:removeAllChildrenWithCleanup(true);
    local tableView = self:createPetAttrTableView(self.node_attr_list:getContentSize());
    self.node_attr_list:addChild( tableView );
end
--[[--
    刷新ui
]]
function game_pet_adjustment_scene.refreshUi(self)
    -- 宠物列表
    -- self:refreshPetTableView()
    -- 战斗力
    self:refreshTips()
    -- 食物
    self:refreshCombatLabel()
    -- 宠物信息
    self:refreshPetInfo(self.m_cur_select_id);
end

--[[--
    初始化
]]
function game_pet_adjustment_scene.init(self,t_params)
    t_params = t_params or {};
    self.m_tempTeamData = {};


    -- local formationData = game_data:getFormationData();
    -- local ownFormation = formationData.own
    -- local ownFormationCount = #ownFormation
    -- self.m_currentFormationId = formationData.current
    -- cclog("self.m_currentFormationId=====" .. self.m_currentFormationId);
    -- self.m_selFormationId = self.m_currentFormationId;

    self.m_posIndex = -1
    self.m_tempTeamData = game_data:getPetTeamData();

    for i=1,#self.m_tempTeamData do
        if self.m_tempTeamData[i] ~= "-1" and self.m_tempTeamData[i] ~= "0" then
            self.m_posIndex = i
        end
    end
    -- local formationConfig = getConfig(game_config_field.formation);
    -- local itemCfg = formationConfig:getNodeWithKey(tostring(self.m_selFormationId));
    local tempTag = 1;
    local iValue = nil;
    -- if itemCfg ~= nil then
    --     for i=1,#formationPosTab do
    --         local formationPosTabItem = formationPosTab[i];
    --         -- cclog(itemCfg:getFormatBuffer())
    --         -- cclog("formationPosTabItem.key =========" .. formationPosTabItem.key .. " ; itemCfg = " .. tostring(itemCfg))
    --         iValue = itemCfg:getNodeWithKey(formationPosTabItem.key):toInt();
    --         if iValue ~= 0 and tempTag < 7 then
    --             self.m_tempTeamData[i] = teamData[tempTag]
    --             tempTag = tempTag + 1;
    --         else
    --             self.m_tempTeamData[i] = "-1";
    --         end
    --     end
    -- end
    -- for i=6,8 do
    --     self.m_tempTeamData[i+1] = teamData[i];
    -- end

    -- local cardNumData = game_data:getBattleCardNumData()
    -- local maxCount1,maxCount2 = cardNumData.position_num or 2,cardNumData.alternate_num or 0;
    self.m_openTab = TEAM_POS_OPEN_TAB["open53"] or {};
end

--[[--
    创建ui入口并初始化数据
]]
function game_pet_adjustment_scene.create(self,t_params)
    -- body
    -- game_data:addOneNewButtonByBtnID(503)   -- 已经了解了技能升级功能
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end

return game_pet_adjustment_scene;
