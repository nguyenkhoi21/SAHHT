---  宠物pop

local game_pet_info_pop = {

    m_story_label = nil,   -- 宠物story文字

    m_anim_node = nil,

    node_skill_list = nil,
    node_intro_msg_board = nil,

    m_life_label = nil,
    m_physical_atk_label = nil,
    m_magic_atk_label = nil,
    m_def_label = nil,
    m_speed_label = nil,

    -- m_cur_select_id = nil,
    m_name_label = nil,
    m_short_story_label = nil,
    m_race_label = nil,
    m_occupation_icon = nil,
    node_starts_board = nil,
    m_bar_bg = nil,
};
--[[--
    销毁ui
]]
function game_pet_info_pop.destroy(self)
    -- body
    cclog("-----------------game_pet_info_pop destroy-----------------");

    self.m_story_label = nil;
    
    self.m_anim_node = nil;

    self.node_skill_list = nil;
    self.node_intro_msg_board = nil;
    self.label_pet_name = nil;

    self.m_life_label = nil;
    self.m_physical_atk_label = nil;
    self.m_magic_atk_label = nil;
    self.m_def_label = nil;
    self.m_speed_label = nil;

    -- self.m_cur_select_id = nil;
    self.m_name_label = nil;
    self.m_short_story_label = nil;
    self.m_race_label = nil;
    self.m_occupation_icon = nil;
    self.node_starts_board = nil;
    self.m_bar_bg = nil;
end

--[[--
    返回
]]
function game_pet_info_pop.back(self,backType)
    -- game_scene:enterGameUi("game_main_scene",{gameData = nil});
    game_scene:removePopByName("game_pet_info_pop");
end

--[[--
    读取ccbi创建ui
]]
function game_pet_info_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2( btnTag, "game_pet_info_pop  btn click and tag is ====  ")
        if btnTag == 1 then 
            -- game_scene:enterGameUi("game_main_scene");
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pet_info_pop.ccbi");
    --英雄相关

    ---------------------       宠物形象展示  ---------------
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_occupation_icon = ccbNode:spriteForName("m_occupation_icon")
    self.m_short_story_label = ccbNode:labelTTFForName("m_short_story_label")
    self.m_race_label = ccbNode:labelTTFForName("m_race_label")

    ---------------------       宠物信息息相关               -------------------------
    self.node_skill_list = ccbNode:nodeForName("node_skill_list")   -- 宠物技能底板
    self.node_intro_msg_board = ccbNode:nodeForName("node_intro_msg_board")   -- 宠物描述的底板
    self.m_name_label = ccbNode:labelTTFForName("m_name_label")
    self.m_bar_bg = ccbNode:nodeForName("m_bar_bg")
    self.node_starts_board = ccbNode:nodeForName("node_starts_board")

    --

    --属性
    self.m_life_label = ccbNode:labelBMFontForName("m_life_label")
    self.m_physical_atk_label = ccbNode:labelBMFontForName("m_physical_atk_label")
    self.m_magic_atk_label = ccbNode:labelBMFontForName("m_magic_atk_label")
    self.m_def_label = ccbNode:labelBMFontForName("m_def_label")
    self.m_speed_label = ccbNode:labelBMFontForName("m_speed_label")

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--
    属性宠物信息
]]
function game_pet_info_pop.refreshPetInfo(self)
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    local pet_detail = getConfig(game_config_field.pet_detail);
    local petCfg = pet_detail:getNodeWithKey(tostring(self.tGameData.c_id));
    local petData = {
      lv            = 1,
      exp = 0,
      hp       = petCfg:getNodeWithKey("base_hp"):toInt(),
      id            = "-1",
      rgb_sort      = petCfg:getNodeWithKey("rgb_sort"):toInt(),
      animation     = petCfg:getNodeWithKey("animation"):toStr(),
      c_id          = self.tGameData.c_id,
      quality       = petCfg:getNodeWithKey("quality"):toInt(),
      def      = petCfg:getNodeWithKey("base_def"):toInt(),
      star          = petCfg:getNodeWithKey("star"):toInt(),
      race          = petCfg:getNodeWithKey("race"):toInt(),
      speed    = petCfg:getNodeWithKey("base_speed"):toInt(),
      matk     = petCfg:getNodeWithKey("base_matk"):toInt(),
      s_2           = {
        avail = petCfg:getNodeWithKey("skill_2_source"):getNodeAt(0):getNodeAt(1):toInt(),
        lv    = 1,
        s     = petCfg:getNodeWithKey("skill_2_source"):getNodeAt(0):getNodeAt(0):toInt(),
        exp   = 0,
      },
      patk     = petCfg:getNodeWithKey("base_patk"):toInt(),
      s_1           = {
        avail = petCfg:getNodeWithKey("skill_1_source"):getNodeAt(0):getNodeAt(1):toInt(),
        lv    = 1,
        s     = petCfg:getNodeWithKey("skill_1_source"):getNodeAt(0):getNodeAt(0):toInt(),
        exp   = 0,
      },
      level_max     = petCfg:getNodeWithKey("level_max"):toInt(),
    }

    local ccbNode = self:createCardAnimByData(petData,petCfg)
    self.m_anim_node:addChild(ccbNode,10,10);

    self.m_bar_bg:removeAllChildrenWithCleanup(true)
    local pet_base = getConfig(game_config_field.pet_base)
    local pet_base_item = pet_base:getNodeWithKey(tostring(petData.lv))
    local maxExp = math.floor(pet_base_item:getNodeWithKey("exp"):toInt())
    local bar = ExtProgressTime:createWithFrameName("o_public_jingyan_1.png","o_public_jingyan.png");
    bar:addLabelTTF(CCLabelTTF:create(petData.exp .. "/" .. maxExp,TYPE_FACE_TABLE.Arial_BoldMT,12));
    self.m_bar_bg:addChild(bar,10,10);
    bar:setMaxValue(maxExp);
    bar:setCurValue(petData.exp,false);
    -- 刷新宠物描述
    self:refreshPetStoryInfo( petCfg )

    -- -- 刷新宠物属性信息
    self:refreshPetAttrs( petData, petCfg)

    -- -- 刷新宠物技能
    self:refreshPetSkills( petData, petCfg)

    self:createStar(petCfg:getNodeWithKey("star"):toInt())
end

--[[
    获取小伙伴位置上的动画
]]
function game_pet_info_pop.createCardAnimByData( self, petData,petCfg,animFlag)
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
            -- local tempLabel = CCLabelTTF:create("Lv." .. petData.lv .. "/" .. petData.level_max .. "\n" .. name,TYPE_FACE_TABLE.Arial_BoldMT,10);
            -- tempLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
            -- tempLabel:setPosition(ccp(itemSize.width*0.5 - 50,97));
            -- tempLabel:setAnchorPoint(ccp(0,0.5));
            -- animNode:addChild(tempLabel,100,100)
            local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. 1 .. ".png")
            if spriteFrame then
            --     local occupation_icon = CCSprite:createWithSpriteFrame(spriteFrame)
            --     occupation_icon:setPosition(ccp(itemSize.width*0.5 + 57,98));
            --     occupation_icon:setAnchorPoint(ccp(1,0.5));
            --     animNode:addChild(occupation_icon);
                self.m_occupation_icon:setDisplayFrame(spriteFrame)
            end
            self.m_name_label:setString(name)
            self.m_short_story_label:setString("Lv." .. petData.lv .. "/" .. petData.level_max)
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
function game_pet_info_pop.refreshPetStoryInfo( self, petCfg )
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
        m_fate_label:setPosition(ccp( tempSize.width * 0.5 + 5, tempSize.height - 1))
        self.node_intro_msg_board:addChild( m_fate_label )
        self.m_story_label = m_fate_label
        self.m_story_label:setScale(0.7)
    else
        self.m_story_label:setString( story_msg )
        self.m_story_label:setScale(0.7)
    end
end

--[[
    刷新宠物技能
]]
function game_pet_info_pop.refreshPetSkills( self, petData, petCfg )
    self.node_skill_list:removeAllChildrenWithCleanup(true);
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag  ===  ", btnTag)
        -- game_scene:addPop("game_pet_skill_pop",{ petId = self.m_cur_select_id, skill_index = btnTag  })
    end
    local posxs = {
        {0.5},
        {0.25, 0.75},
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

--[[
    刷新宠物属性
]]
function game_pet_info_pop.refreshPetAttrs( self,petData, petCfg )
    if petData and petCfg then
        self.m_life_label:setString(math.floor(petData.hp));
        self.m_physical_atk_label:setString(math.floor(petData.patk));
        self.m_magic_atk_label:setString(math.floor(petData.matk));
        self.m_def_label:setString(math.floor(petData.def));
        self.m_speed_label:setString(math.floor(petData.speed));
    else
        self.m_life_label:setString("---");
        self.m_physical_atk_label:setString("---");
        self.m_magic_atk_label:setString("---");
        self.m_def_label:setString("---");
        self.m_speed_label:setString("---");
    end
end
--[[
    星星显示
]]
function game_pet_info_pop.createStar(self,star)
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
    刷新ui
]]
function game_pet_info_pop.refreshUi(self)
    -- 宠物信息
    self:refreshPetInfo();
end
--[[--
    初始化
]]
function game_pet_info_pop.init(self,t_params)
    t_params = t_params or {};
    self.tGameData = t_params.tGameData
end

--[[--
    创建ui入口并初始化数据
]]
function game_pet_info_pop.create(self,t_params)
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end

return game_pet_info_pop;
