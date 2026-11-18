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
    m_anim_node = nil,
    m_name_label = nil,
    m_race_label = nil,
    node_starts_board = nil,
    pet_list_node = nil,
    m_occupation_icon = nil,
    m_rest_btn = nil,
    backData = nil,
    m_chuzhan_sprite = nil,
    -- m_explain_btn = nil,
    follow_label = nil,
    follow_node = nil,
    m_ref_btn = nil,
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

    self.m_anim_node = nil;
    self.m_name_label = nil;
    self.m_race_label = nil;
    self.node_starts_board = nil;
    self.pet_list_node = nil;
    self.m_occupation_icon = nil;
    self.m_rest_btn = nil;
    self.backData = nil;
    self.m_chuzhan_sprite = nil;
    -- self.m_explain_btn = nil;
    self.follow_label = nil;
    self.follow_node = nil;
    self.m_ref_btn = nil;
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
    if self.backData == self.m_tempTeamData[1] then
        self.m_changeFlag = false
    else
        self.m_changeFlag = true
    end
    if  self.m_changeFlag == true then
        local function responseMethod(tag,gameData)
            if gameData ~= nil then
                local data = gameData:getNodeWithKey("data");
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
--[[
    设置宠物跟随阵型
]]
function game_pet_adjustment_scene.setPetFollowFormation(self)
    local pet_follow_pos = game_data:getPetFollowPos()
    local params = "&formation="
    for i=1,#pet_follow_pos do
        if i < #pet_follow_pos then
            params = params .. pet_follow_pos[i] .. "_"
        else
            params = params .. pet_follow_pos[i]
        end
    end
    local function responseMethod(tag,gameData)
        -- local data = gameData:getNodeWithKey("data")
        -- cclog2(data,"data")
        self:refreshUi()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("set_pet_follow_formation"), http_request_method.POST, params,"set_pet_follow_formation")
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
        elseif btnTag == 500 then--下场
            --判断是下场还是取消跟随
            local isInTeam = game_data:petInTeamById(self.m_cur_select_id)
            --宠物跟随
            local pet_follow_pos = game_data:getPetFollowPos()
            local isFollow,k = game_util:idInTableById(self.m_cur_select_id,pet_follow_pos)
            if isInTeam then
                self.m_tempTeamData[1] = "0"
                self:setTeamFormationData(self.m_tempTeamData)
                self:refreshUi()
            elseif isFollow then
                pet_follow_pos[k] = "0"
                self:setPetFollowFormation()
            end
        elseif btnTag == 61 then--跟随
            -- self.m_cur_select_id
            local pet_follow_pos = game_data:getPetFollowPos()
            local openCount = 0
            local haveCount = 0
            for i=1,#pet_follow_pos do
                if pet_follow_pos[i] and pet_follow_pos[i] ~= "-1" then
                    openCount = openCount + 1
                    if pet_follow_pos[i] and pet_follow_pos[i] ~= "0" then
                        haveCount = haveCount + 1
                    end
                end
            end
            if haveCount >= openCount then
                game_util:addMoveTips({text = "Số pet bám đuôi đạt max!"})
                return
            end
            for i=1,#pet_follow_pos do
                if pet_follow_pos[i] and pet_follow_pos[i] == "0" then
                    pet_follow_pos[i] = self.m_cur_select_id
                    break
                end
            end
            self:setPetFollowFormation()
        elseif btnTag == 62 then --加成刷新
            self:sendChangedData(2);
            game_scene:addPop("game_pet_adduct_pop",{})
        elseif btnTag == 110 then--增加跟随数量上限
            local payValue = 20
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                cclog2(data,"data")
                game_util:addMoveTips({text = "Đã kích hoạt!"})
                game_util:closeAlertView();
                self:refreshHeroInfo(self.m_cur_select_id)
            end
            local pet_follow = getConfig(game_config_field.pet_follow)
            local pet_follow_pos = game_data:getPetFollowPos()
            local openCount = 0
            for i=1,#pet_follow_pos do
                if pet_follow_pos[i] and pet_follow_pos[i] ~= "-1" then
                    openCount = openCount + 1
                end
            end
            if openCount < #pet_follow_pos then
                local itemCfg = pet_follow:getNodeWithKey(tostring(openCount+1))
                local sort = itemCfg:getNodeWithKey("sort"):toInt()
                local priceType = {"Bụi cường năng","Bụi siêu năng"}
                local price = itemCfg:getNodeWithKey("price"):toInt()
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("activate_pet_follow_pos"), http_request_method.GET, {pos = openCount},"activate_pet_follow_pos")
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,       --可缺省
                    cancelBtnText = string_config.m_btn_cancel,
                    text = "Tốn" .. price .. priceType[sort] .. "Xu kích hoạt 1 chỗ pet bám đuôi?",      --可缺省
                    onlyOneBtn = false,
                    touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                }
                game_util:openAlertView(t_params)
            else
                game_util:addMoveTips({text = "Tất cả vị trí đã kích hoạt!"})
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pet_adjustment_scene_new.ccbi");
    self.m_ccbNode = ccbNode
    --英雄相关
    ---------------------       玩家信息  食物 战力           -------------------
    local m_combat_node = ccbNode:nodeForName("m_combat_node")                   -- 战斗力底板

    ---------------------       宠物信息息相关               -------------------------
    self.node_attr_list = ccbNode:nodeForName("node_attr_list")     -- 宠物属性底板
    self.node_skill_list = ccbNode:nodeForName("node_skill_list")   -- 宠物技能底板
    self.node_intro_msg_board = ccbNode:nodeForName("node_intro_msg_board")   -- 宠物描述的底板

    --

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
    -------------------------新改
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_name_label = ccbNode:labelTTFForName("m_name_label")
    self.m_race_label = ccbNode:labelTTFForName("m_race_label")
    self.node_starts_board = ccbNode:nodeForName("node_starts_board")
    self.pet_list_node = ccbNode:nodeForName("pet_list_node")
    self.m_occupation_icon = ccbNode:spriteForName("m_occupation_icon")
    self.m_rest_btn = ccbNode:controlButtonForName("m_rest_btn")
    self.m_chuzhan_sprite = ccbNode:spriteForName("m_chuzhan_sprite")
    -- self.m_explain_btn = ccbNode:controlButtonForName("m_explain_btn")
    self.follow_label = ccbNode:labelTTFForName("follow_label")
    self.follow_node = ccbNode:nodeForName("follow_node")
    self.m_ref_btn = ccbNode:controlButtonForName("m_ref_btn")
    self.follow_node:setVisible(false)

    ---------------------       初始化战斗力显示node        --------------
    self.m_combatNumberChangeNode = game_util:createExtNumberChangeNode({labelType = 2});
    self.m_combatNumberChangeNode:setAnchorPoint(ccp(0, 0.5));
    -- self.m_combatNumberChangeNode:setScale(0.75);
    m_combat_node:addChild(self.m_combatNumberChangeNode);
    self.m_combatNumberChangeNode:setCurValue(0,false);

    ------------------
    -- self.m_cur_select_id = nil
    -- self.m_selcet_index = nil                           -- 当前选中的宠物列表的index
    -- self.m_tempSelIndex = nil

    ------------   右边阵型   --------------------
    -- self.m_formation_layer = ccbNode:layerColorForName("m_formation_layer")
    -- self.m_replace_btn = ccbNode:controlButtonForName("m_replace_btn")

    -- self:initTeamFormation(self.m_formation_layer);
    
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
        game_scene:addPop("game_pet_skill_pop",{ petId = self.m_cur_select_id, skill_index = btnTag , callBackFunc = petSkillUpCallBack})
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
                tempLabel:setPosition(ccp(icon_size.width*0.5,-8));
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
    获得阵型相关的数据
]]
function game_pet_adjustment_scene.setTeamFormationData(self)
    game_data:setPetTeamData(self.m_tempTeamData);
end

function game_pet_adjustment_scene.updateTeamData(self,posIndex,petId)
    self.m_tempTeamData[posIndex] = petId;
    self:setTeamFormationData();
end

--[[--
    
]]
function game_pet_adjustment_scene.getTeamPetDataByPos(self,posIndex)
    return game_data:getPetDataById(self.m_tempTeamData[posIndex])
end

--[[--
    刷新卡牌信息
]]
function game_pet_adjustment_scene.refreshHeroInfo(self,petId)
    if game_data:isViewOpenByID(158) then--
        self.follow_node:setVisible(true)
    else
        self.follow_node:setVisible(false)
    end
    local replaceStr = "Thay thế" 
    -- self.m_sel_bg:setVisible(false);
    self.m_selHeroId = nil;
    local tempNode = nil;
    -- local petData,petCfg = self:getTeamPetDataByPos(posIndex);
    local petData,petCfg = game_data:getPetDataById(petId)

    local fate_detail_label_str = "không có";
    if petData and petCfg then
        local attrValueTab = {petData.patk_crystal,petData.matk_crystal,petData.def_crystal,petData.speed_crystal,petData.hp_crystal}
        --这个是属性改造等级
        local attrCfg = {"add_patk","add_matk","add_def","add_speed","add_hp"}
        -- self:setSelPositionBg(posIndex);
        self.m_cur_select_id = petData.id
        self.m_life_label:setString(math.floor(petData.hp));
        self.m_physical_atk_label:setString(math.floor(petData.patk));
        self.m_magic_atk_label:setString(math.floor(petData.matk));
        self.m_def_label:setString(math.floor(petData.def));
        self.m_speed_label:setString(math.floor(petData.speed));
        local ainmFile = petCfg:getNodeWithKey("animation"):toStr();
        -- 1物攻 2魔攻 3防御 4速度 5生命
        -- local equipAttrValueTab = self:getPosEquipAttrValue(posIndex);--装备属性
        for i=1,5 do
            local abilityItem = PUBLIC_ABILITY_TABLE["ability_" .. i] or {}
            local attrValue = petData[abilityItem.attrName or ""] or 0
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
        -- if self.m_teamIndex == 2 then
        --     self:setSelPositionBg(posIndex);
        -- end
        -- replaceStr = "上阵"
    end
    -- game_util:setCCControlButtonTitle(self.m_replace_btn,replaceStr)

    -- self:refreshPetInfo(self.m_tempTeamData[posIndex])
    self:refreshPetInfo(petId)

    self:createStar(petData.star)

    local ccbNode = self:createCardAnimByData(petData,petCfg)--没有待机动作，暂时用图片代替
    self.m_anim_node:removeAllChildrenWithCleanup(true)
    self.m_anim_node:addChild(ccbNode,10,10);

    local isInTeam = game_data:petInTeamById(petId)
    self.m_rest_btn:setVisible(isInTeam)

    --宠物跟随
    local pet_follow_pos = game_data:getPetFollowPos()
    local isFollow = game_util:idInTableById(petId,pet_follow_pos)

    self.m_chuzhan_sprite:setVisible(isInTeam or isFollow)
    if isFollow then
        self.m_chuzhan_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_pet_gensui.png"))
    elseif isInTeam then
        self.m_chuzhan_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_pet_chuzhan.png"))
    end
    --需判断出战和跟随两种情况    
    -- self.m_explain_btn:setEnabled(not (isFollow or isInTeam))
    self.m_rest_btn:setVisible(isInTeam)--休息和取消跟随两种情况
    if isInTeam then
        game_util:setCCControlButtonTitle(self.m_rest_btn,"Nghỉ")
    end
    local openCount = 0
    local haveCount = 0
    for i=1,9 do
        if pet_follow_pos[i] and pet_follow_pos[i] ~= "-1" then
            openCount = openCount + 1
            if pet_follow_pos[i] and pet_follow_pos[i] ~= "0" then
                haveCount = haveCount + 1
            end
        end
    end
    -- self.follow_label:setString(haveCount .. "/" .. openCount)
end
--[[
    星星显示
]]
function game_pet_adjustment_scene.createStar(self,star)
    self.node_starts_board:removeAllChildrenWithCleanup(true)
    for i=1,5 do
        local star_back = CCSprite:createWithSpriteFrameName("ui_pet_xingxing2.png")
        self.node_starts_board:addChild(star_back)
        star_back:setPosition(ccp(9,60 - (i-1) * 15))
        if i <= star then
            local star = CCSprite:createWithSpriteFrameName("ui_pet_xingxing1.png")
            self.node_starts_board:addChild(star)
            star:setPosition(ccp(9,60 - (i-1) * 15))
        end
    end
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
        local cardData,petCfg = game_data:getPetDataById(tostring(petId));
        self.m_selHeroData = cardData;

        -- cclog2(cardData, "cardData   ==============     ")
        -- cclog2(petCfg, "petCfg   ==============     ")

        -- 刷新宠物描述
        self:refreshPetStoryInfo( petCfg )

        -- 刷新宠物属性信息
        -- self:refreshPetAttrs( cardData, petCfg)

        -- 刷新宠物技能
        self:refreshPetSkills( cardData, petCfg)
    end
end

--[[
    获取小伙伴位置上的动画
]]
function game_pet_adjustment_scene.createCardAnimByData( self, petData,petCfg,animFlag)
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
            local name = petCfg:getNodeWithKey("name"):toStr()
            local occupation = 1
            local animation = petCfg:getNodeWithKey("animation"):toStr()
            local occupationCfg = getConfig(game_config_field.occupation)
            if occupationCfg:getNodeWithKey(animation) then
                occupation = occupationCfg:getNodeWithKey(animation):toInt()
            end
            local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupation .. ".png")
            if spriteFrame then
                self.m_occupation_icon:setDisplayFrame(spriteFrame)
            end
            self.m_name_label:setString(name)
            -- self.m_short_story_label:setString("Lv." .. petData.lv .. "/" .. petData.level_max)
            local race_cfg = getConfig(game_config_field.race);
            local race_item_cfg = race_cfg:getNodeWithKey(petCfg:getNodeWithKey("race"):toStr());
            if race_item_cfg then
                self.m_race_label:setString(race_item_cfg:getNodeWithKey("name"):toStr());
            else
                self.m_race_label:setString("không có");
            end
            animNode:setScale(1.2);
        end
    end
    return animNode,pet_id
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
    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 9)
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
function game_pet_adjustment_scene.refreshUi(self)
    -- 宠物列表
    -- self:refreshPetTableView()
    -- 战斗力
    self:refreshTips()
    -- 食物
    self:refreshCombatLabel()
    

    local pX,pY;
    if self.m_tableView then
        pX,pY = self.m_tableView:getContainer():getPosition();
    end
    self.pet_list_node:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil
    self.m_tableView = self:createPetTableView(self.pet_list_node:getContentSize());
    self.pet_list_node:addChild(self.m_tableView);
    if pX and pY then
        self.m_tableView:setContentOffset(ccp(pX,pY), false);
    end

    -- 宠物信息
    -- self:refreshPetInfo(self.m_cur_select_id);
    if self.m_cur_select_id ~= nil and self.m_cur_select_id ~= "0" then
        self:refreshHeroInfo(self.m_cur_select_id);
    end
end

--[[--
    创建宠物列表
]]
function game_pet_adjustment_scene.createPetTableView(self,viewSize)
    local function onCellClick(target,event)
        cclog2(self.m_cur_select_id,"self.m_cur_select_id")
        local petData,petCfg = game_data:getPetDataById(self.m_cur_select_id)
        local petId = petData.id
        self.m_tempTeamData[1] = petId
        self:setTeamFormationData(self.m_tempTeamData)
        -- cclog2(self.m_tempTeamData,"self.m_tempTeamData")
        self:refreshUi()
    end
    self.m_selListItem = nil;
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local cardsCount = game_data:getPetCount();
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 3; --列
    params.totalItem = cardsCount -- totalItem;
    params.direction = kCCScrollViewDirectionHorizontal;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellClick",onCellClick);
            ccbNode:openCCBFile("ccb/ui_pet_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- ccbNode:controlButtonForName("m_replace_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-4);
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            cell:setTag(index);
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            if not self.m_selcet_index then 
                self.m_selcet_index = index
            end
            local itemData,itemCfg = game_data:getPetDataByIndex(index+1);
            
            local pet_light = ccbNode:spriteForName("pet_light")
            local pet_node = ccbNode:nodeForName("pet_node")
            local name_label = ccbNode:labelTTFForName("name_label")
            local m_replace_btn = ccbNode:controlButtonForName("m_replace_btn")
            local m_team_img = ccbNode:spriteForName("m_team_img")

            local name_after = itemCfg:getNodeWithKey("name"):toStr()
            name_label:setString(name_after);
            local animation = itemCfg:getNodeWithKey("animation"):toStr();
            local rgb = itemCfg:getNodeWithKey("rgb_sort"):toInt();

            local animNode = game_util:createImgByName("image_" .. animation,rgb,nil,nil,0,itemCfg)
            pet_node:removeAllChildrenWithCleanup(true)
            if animNode then
                local animNodeSize = animNode:getContentSize();
                animNode:setAnchorPoint(ccp(0.5,0));
                animNode:setScale(0.5)
                pet_node:addChild(animNode);
            end

            local isInTeam = game_data:petInTeamById(itemData.id)
            m_team_img:setVisible(isInTeam)
            -- m_replace_btn:setVisible(not isInTeam)
            m_replace_btn:setVisible(false)
            pet_light:setVisible(false)
            if self.m_cur_select_id ~= nil and itemData.id == self.m_cur_select_id then
                self.m_cur_select_id = itemData.id
                pet_light:setVisible(true)
                self.m_selListItem = cell;
                -- m_replace_btn:setVisible(not isInTeam)
            end
            --跟随
            local follow_sprite = ccbNode:spriteForName("follow_sprite")
            local isFollow = game_util:idInTableById(itemData.id,game_data:getPetFollowPos())
            follow_sprite:setVisible(isFollow)
            --m_replace_btn一样
            -- m_replace_btn:setVisible(not (isInTeam or isFollow))
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
                local pet_light = ccbNode:spriteForName("pet_light")
                local m_replace_btn = ccbNode:controlButtonForName("m_replace_btn")
                m_replace_btn:setVisible(false)
                pet_light:setVisible(false);
            end
            self.m_selListItem = cell;
            self.m_cur_select_id = card_id;
            -- self:refreshPetInfo(self.m_cur_select_id);
            self:refreshHeroInfo(self.m_cur_select_id);
            -- self:refreshTips();
            local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
            local pet_light = ccbNode:spriteForName("pet_light")
            pet_light:setVisible(true);

            local isInTeam = game_data:petInTeamById(itemData.id)
            local m_replace_btn = ccbNode:controlButtonForName("m_replace_btn")
            -- m_replace_btn:setVisible(not isInTeam)
            local isFollow = game_util:idInTableById(itemData.id,game_data:getPetFollowPos())
            m_replace_btn:setVisible(not (isInTeam or isFollow))
        end
    end

    local tableView = TableViewHelper:create(params);
    return tableView
end

--[[--
    初始化
]]
function game_pet_adjustment_scene.init(self,t_params)
    t_params = t_params or {};
    self.m_tempTeamData = {};
    self.m_posIndex = -1
    self.backData = game_data:getPetTeamData()[1]
    self.m_tempTeamData = game_data:getPetTeamData();

    self.m_tempTeamData[1] = game_data:getPetTeamData()[1]
    for i=2,9 do
        self.m_tempTeamData[i] = "0"
    end
    self:setTeamFormationData(self.m_tempTeamData)
    -- cclog2(self.m_tempTeamData,"self.m_tempTeamData")
    -- for i=1,#self.m_tempTeamData do
    --     if self.m_tempTeamData[i] ~= "-1" and self.m_tempTeamData[i] ~= "0" then
    --         self.m_posIndex = i
    --     end
    -- end

    for i=1,game_data:getPetCount() do
        local itemData,itemCfg = game_data:getPetDataByIndex(i);
        local isInTeam = game_data:petInTeamById(itemData.id)
        if isInTeam then
            self.m_cur_select_id = itemData.id
        end
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_pet_adjustment_scene.create(self,t_params)
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end

return game_pet_adjustment_scene;
