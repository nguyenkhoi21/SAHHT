---  宠物列表

local game_pet_list_scene = {

    m_selListItem = nil,        -- 选中的宠物
    m_food_total_label = nil,   -- 现有的食物数量
    m_combatNumberChangeNode = nil,  -- 战斗力显示node
    m_tempCombatValue = nil,         -- 战斗力

    m_sel_btn = nil,        --  选取宠物按钮 -- 宠物展示底板
    node_anim = nil,        --  宠物卡牌像节点
    node_attr_list = nil,   --  宠物属性

    m_story_label = nil,   -- 宠物story文字
    
    m_list_view_bg = nil,
    m_tableView = nil,

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
    m_physical_atk_label2 = nil,
    m_magic_atk_label2 = nil,
    m_def_label2 = nil,
    m_speed_label2 = nil,

    m_cur_select_id = nil,
    m_selcet_index = nil,

    btn_reborn = nil,
    btn_upstar = nil,
    btn_streng = nil,
    btn_upgrade = nil,
};
--[[--
    销毁ui
]]
function game_pet_list_scene.destroy(self)
    -- body
    cclog("-----------------game_pet_list_scene destroy-----------------");

    self.m_food_total_label = nil;
    self.m_selListItem = nil;
    self.m_combatNumberChangeNode = nil;
    self.m_tempCombatValue = nil;

    self.node_anim  = nil;
    self.node_attr_list = nil;

    self.m_list_view_bg = nil;
    self.m_story_label = nil;
    
    self.m_tableView = nil; 

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
    self.m_physical_atk_label2 = nil;
    self.m_magic_atk_label2 = nil;
    self.m_def_label2 = nil;
    self.m_speed_label2 = nil;
    self.m_cur_select_id = nil;
    self.m_selcet_index = nil;

    self.btn_reborn = nil;
    self.btn_upstar = nil;
    self.btn_streng = nil;
    self.btn_upgrade = nil;
end

--[[--
    返回
]]
function game_pet_list_scene.back(self,backType)
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
end

--[[--
    读取ccbi创建ui
]]
function game_pet_list_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2( btnTag, "game_pet_list_scene  btn click and tag is ====  ")
        if btnTag == 1 then 
            game_scene:enterGameUi("game_main_scene");
        elseif btnTag == 3 then 
        elseif btnTag == 103 then   -- 升级
            if self.m_cur_select_id == nil then
                game_util:addMoveTips({text = "chọn  thú nuôi"})
                return
            end
            game_scene:addPop("game_pet_upgrade_pop",{petId = self.m_cur_select_id})
        elseif btnTag == 104 then   -- 强化
            if self.m_cur_select_id == nil then
                game_util:addMoveTips({text = "chọn  thú nuôi"})
                return
            end
            game_scene:addPop("game_pet_strengthen_pop",{petId = self.m_cur_select_id})
        elseif btnTag == 105 then  -- 升星
            if self.m_cur_select_id == nil then
                game_util:addMoveTips({text = "chọn  thú nuôi"})
                return
            end
            game_scene:addPop("game_pet_upstar_pop",{petId = self.m_cur_select_id})
        elseif btnTag == 106 then  --重生
            if self.m_cur_select_id == nil then
                game_util:addMoveTips({text = "Xin chọn thú nuôi!"})
                return
            end
            --判断是下场还是取消跟随
            local isInTeam = game_data:petInTeamById(self.m_cur_select_id)
            --宠物跟随
            local pet_follow_pos = game_data:getPetFollowPos()
            local isFollow,k = game_util:idInTableById(self.m_cur_select_id,pet_follow_pos)
            if isInTeam then
                game_util:addMoveTips({text = "Thú nuôi này đã ra trận!"})
            elseif isFollow then
                game_util:addMoveTips({text = "Thú nuôi này đã đi theo!"})
            else
                -- local function responseMethod(tag,gameData)
                -- local data = gameData:getNodeWithKey("data")
                --     local reward = data:getNodeWithKey("reward")
                --     game_util:rewardTipsByJsonData(reward);
                --     game_util:closeAlertView();
                -- end
                -- local t_params = 
                -- {
                --     title = string_config.m_title_prompt,
                --     okBtnCallBack = function(target,event)
                --         network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pet_rebirth"), http_request_method.GET, {pet_id = self.m_cur_select_id},"pet_rebirth")
                --     end,   --可缺省
                --     okBtnText = string_config.m_btn_sure,       --可缺省
                --     cancelBtnText = string_config.m_btn_cancel,
                --     text = "是否重生该宠物？",      --可缺省
                --     onlyOneBtn = false,
                --     touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                -- }
                -- game_util:openAlertView(t_params)

                --改
                game_scene:addPop("game_pet_rebirth_pop",{pet_id = self.m_cur_select_id})
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pet_scene.ccbi");
    --英雄相关

    ---------------------       玩家信息  食物 战力           -------------------
    self.m_food_total_label = ccbNode:labelBMFontForName("m_food_total_label")     -- 食物
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
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScale(resolution_config:getScale())
    --inreview 控制
    self.btn_reborn = ccbNode:controlButtonForName("btn_reborn")
    self.btn_upstar = ccbNode:controlButtonForName("btn_upstar")
    self.btn_streng = ccbNode:controlButtonForName("btn_streng")
    self.btn_upgrade = ccbNode:controlButtonForName("btn_upgrade")
    if game_data:isViewOpenByID(157) then--
        self.btn_reborn:setVisible(true)
        self.btn_upgrade:setPositionX(22)
        self.btn_streng:setPositionX(90)
        self.btn_upstar:setPositionX(158)
    else
        self.btn_reborn:setVisible(false)
        self.btn_upgrade:setPositionX(45)
        self.btn_streng:setPositionX(125)
        self.btn_upstar:setPositionX(205)
    end

    ---------------------       初始化战斗力显示node        --------------
    self.m_combatNumberChangeNode = game_util:createExtNumberChangeNode({labelType = 2});
    self.m_combatNumberChangeNode:setAnchorPoint(ccp(0, 0.5));
    -- self.m_combatNumberChangeNode:setScale(0.75);
    m_combat_node:addChild(self.m_combatNumberChangeNode);
    self.m_combatNumberChangeNode:setCurValue(0,false);

    ------------------

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(false);
    return ccbNode;
end

--[[--
    创建英雄列表
]]
function game_pet_list_scene.createPetTableView(self,viewSize)
    cclog2(self.m_cur_select_id,"self.m_cur_select_id")
    self.m_selListItem = nil;
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local cardsCount = game_data:getPetCount();
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = cardsCount -- totalItem;
    params.direction = kCCScrollViewDirectionVertical;
    local moveFlag = true
    local guideFlag = false
    
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createHeroListItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cclog2(ccbNode, "ccbNode  ==================== ")
            if ccbNode then cell:addChild(ccbNode,10,10); end
        end
        if cell then
            cell:setTag(index);
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            if not self.m_selcet_index then 
                self.m_selcet_index = index
            end
            local itemData,itemCfg = game_data:getPetDataByIndex(index+1);
            if itemData then
                local card_id = itemData.id;
                game_util:setPetListItemInfoByTable2(ccbNode,itemData);
                -- cclog2(self.m_cur_select_id,"self.m_cur_select_id")
                -- cclog2(card_id,"card_id")
                if self.m_cur_select_id ~= nil and card_id == self.m_cur_select_id then
                    self.m_cur_select_id = card_id
                    local m_sel_img = ccbNode:spriteForName("sprite_selected")
                    m_sel_img:setVisible( true  );
                    local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                    sprite_back_alpha:setVisible( true  );
                    self.m_selListItem = cell;
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
            local itemData,itemCfg = game_data:getPetDataByIndex(index+1);
            local card_id = itemData.id;
            if self.m_selListItem then
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("sprite_selected")
                m_sel_img:setVisible(false);
                local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                sprite_back_alpha:setVisible(false);
            end
            self.m_selListItem = cell;
            self.m_cur_select_id = card_id;
            self:refreshPetInfo(self.m_cur_select_id);
            self:refreshTips();
            local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
            local m_sel_img = ccbNode:spriteForName("sprite_selected")
            m_sel_img:setVisible(true);
            local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
            sprite_back_alpha:setVisible(true);
        end
    end

    local tableView = TableViewHelper:create(params);
    return tableView
end

--[[
    更新宠物列表的item的状态
]]
function game_pet_list_scene:updatePetListItem( cell, index, petId )
    local ccbNode = cell and tolua.cast(cell:getChildByTag(10),"luaCCBNode");
    if not ccbNode then return end
end

--[[--
    刷新状态
]]
function game_pet_list_scene.refreshTips(self)
    -- game_util:setCCControlButtonEnabled(self.m_auto_add_btn,true);
    local totalFood = game_data:getUserStatusDataByKey("food") or 0
    local value,unit = game_util:formatValueToString(totalFood);
    self.m_food_total_label:setString(value .. unit);
end

--[[--
    刷新战斗力
]]
function game_pet_list_scene.refreshCombatLabel(self)
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
    刷新
]]
function game_pet_list_scene.refreshPetTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil
    self.m_tableView = self:createPetTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);

end

--[[--
    属性宠物信息
]]
function game_pet_list_scene.refreshPetInfo(self, petId)
    self.m_cur_select_id = petId;
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    self.m_selHeroData = nil;
    if petId ~= nil and petId ~= "-1" then
        self.m_tips_spr_1:setVisible(false);
        -- self.m_tips_spr_2:setVisible(false);
        local petData,petCfg = game_data:getPetDataById(tostring(petId));
        self.m_selHeroData = petData;

        local ccbNode = game_util:createHeroListItemByCCB();
        game_util:setPetListItemInfoByTable(ccbNode,petData)
        self.m_anim_node:addChild(ccbNode,10,10);

        -- cclog2(petData, "petData   ==============     ")
        -- cclog2(petCfg, "petCfg   ==============     ")

        -- 刷新宠物描述
        self:refreshPetStoryInfo( petCfg )

        -- 刷新宠物属性信息
        self:refreshPetAttrs( petData, petCfg)

        -- 刷新宠物技能
        self:refreshPetSkills( petData, petCfg)
    end
    local flag = (self.m_status == 1)
    game_util:setCCControlButtonEnabled(self.m_ok_btn,not flag)

end

--[[
    刷新宠物描述信息
]]
function game_pet_list_scene.refreshPetStoryInfo( self, petCfg )
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

--[[
    刷新宠物技能
]]
function game_pet_list_scene.refreshPetSkills( self, petData, petCfg )
    self.node_skill_list:removeAllChildrenWithCleanup(true);
    local lvLabelTab = {}
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag  ===  ", btnTag)
        local function petSkillUpCallBack()
            local itemData,itemCfg = game_data:getPetDataById(tostring( self.m_cur_select_id ));
            local tempLabel = lvLabelTab[btnTag]
            if itemData and tempLabel then
                local skillData = itemData["s_" .. btnTag]
                if skillData then
                    tempLabel:setString("Lv." .. tostring(skillData.lv))
                end
            end
        end
        game_scene:addPop("game_pet_skill_pop",{ petId = self.m_cur_select_id, skill_index = btnTag, callBackFunc = petSkillUpCallBack })
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
                lvLabelTab[i] = lvLabel
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
    创建一个接受触摸事件的button
]]
function game_pet_list_scene.createTouchButton( self, fun, parent, tag , anchorX, anchorY)
    if not parent then return end
    local button = game_util:createCCControlButton("public_weapon.png","",fun)
    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY)
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
function game_pet_list_scene.refreshPetAttrs( self )
    -- self.node_attr_list:removeAllChildrenWithCleanup(true);
    -- local tableView = self:createPetAttrTableView(self.node_attr_list:getContentSize());
    -- self.node_attr_list:addChild( tableView );
    local petData,petCfg = game_data:getPetDataById(self.m_cur_select_id)
    local attrValueTab = {petData.patk_crystal,petData.matk_crystal,petData.def_crystal,petData.speed_crystal,petData.hp_crystal}
    local attrCfg = {"add_patk","add_matk","add_def","add_speed","add_hp"}
    if petData and petCfg then
        self.m_cur_select_id = petData.id
        self.m_life_label:setString(math.floor(petData.hp));
        self.m_physical_atk_label:setString(math.floor(petData.patk));
        self.m_magic_atk_label:setString(math.floor(petData.matk));
        self.m_def_label:setString(math.floor(petData.def));
        self.m_speed_label:setString(math.floor(petData.speed));

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
    end
end
--[[--
    刷新ui
]]
function game_pet_list_scene.refreshUi(self)
    -- 宠物列表
    self:refreshPetTableView()
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
function game_pet_list_scene.init(self,t_params)
    t_params = t_params or {};
    self.m_cur_select_id = t_params.pet_id or nil 
    self.m_selcet_index = nil                           -- 当前选中的宠物列表的index
end

--[[--
    创建ui入口并初始化数据
]]
function game_pet_list_scene.create(self,t_params)
    -- body
    -- game_data:addOneNewButtonByBtnID(503)   -- 已经了解了技能升级功能
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end

return game_pet_list_scene;
