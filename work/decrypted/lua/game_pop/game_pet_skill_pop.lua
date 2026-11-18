--- 宠物技能

local game_pet_skill_pop = {
    m_popUi = nil,

    m_icon_node = nil,
    node_progress_exp = nil,
    label_level = nil,
    label_name = nil,
    m_story_label = nil,

    node_starts_board = nil,
    label_limit_info_3 = nil,
    label_limit_info_1 = nil,
    label_limit_info_2 = nil,
    m_petId = nil,
    m_skill_index = nil, 
    icon_node = nil,
    m_callBackFunc = nil,
};
--[[--
    销毁
]]
function game_pet_skill_pop.destroy(self)
    -- body
    cclog("-----------------game_pet_skill_pop destroy-----------------");
    self.m_popUi = nil;

    self.m_icon_node = nil;
    self.node_progress_exp = nil;
    self.label_level = nil;
    self.label_name = nil;
    self.m_story_label = nil;
    self.node_starts_board = nil;
    self.label_limit_info_3 = nil;
    self.label_limit_info_1 = nil;
    self.label_limit_info_2 = nil;
    self.m_petId = nil;
    self.m_skill_index = nil;
    self.icon_node = nil;
    self.m_callBackFunc = nil;
end
--[[--
    返回
]]
function game_pet_skill_pop.back(self,type)
    game_scene:removePopByName("game_pet_skill_pop");
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_pet_skill_pop.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then 
            self:back()
        elseif btnTag == 103 then--level up
            local function responseMethod(tag,gameData)
                self:refreshUi()
                if self.m_callBackFunc then
                    self.m_callBackFunc()
                end
            end
            local params = {}
            params.pet_id = self.m_petId
            params.skill_id = self.skill_id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pets_pet_skill_levelup"), http_request_method.GET, params,"pets_pet_skill_levelup")
        end

    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_pet_skill_pop.ccbi");

    -------------------------   宠物基本信息   ------------------------
    self.m_icon_node = ccbNode:nodeForName("m_icon_node")
    self.node_progress_exp = ccbNode:nodeForName("node_progress_exp")
    self.label_level = ccbNode:labelTTFForName("label_level")
    self.label_name = ccbNode:labelTTFForName("label_name")
    self.m_story_label = ccbNode:labelTTFForName("m_story_label")
    self.node_starts_board = ccbNode:nodeForName("node_starts_board")

    self.label_limit_info_3 = ccbNode:labelTTFForName("label_limit_info_3")
    self.label_limit_info_1 = ccbNode:labelTTFForName("label_limit_info_1")
    self.label_limit_info_2 = ccbNode:labelTTFForName("label_limit_info_2")
    self.num_have = ccbNode:labelTTFForName("num_have")
    self.icon_node = ccbNode:nodeForName("icon_node")

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local m_log_btn = ccbNode:controlButtonForName("m_log_btn")

    self.icon_node:removeAllChildrenWithCleanup(true)
    local icon = game_util:getRewardByItemTable({27,0,1})
    if icon then
        icon:setScale(0.6)
        self.icon_node:addChild(icon)
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-9)
    m_log_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-9)
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-8,true);
    m_root_layer:setTouchEnabled(true);

    return ccbNode;
end

--[[--
    刷新ui
]]
function game_pet_skill_pop.refreshUi(self)
    local cardData,heroCfg = game_data:getPetDataById(tostring( self.m_petId ));

    self:refreshPetBaseInfo( cardData,heroCfg )
end

--[[
    刷新宠物基本信息
]]
function game_pet_skill_pop.refreshPetBaseInfo( self, petData, petCfg )
    ------------------   宠物头像   ---------------------
    self.m_icon_node:removeAllChildrenWithCleanup( true )
    local icon = game_util:createCardIconByCfg( petCfg, petData );
    icon:setPosition( self.m_icon_node:getContentSize().width * 0.5, self.m_icon_node:getContentSize().height * 0.5 )
    self.m_icon_node:addChild( icon )

    self:createStar(petData.star)

    --  等级
    -- local level = petData and petData.lv or 1
    -- self.label_level:setString( "LV." .. tostring(level) )

    --  名字+强化等级
    local s_level = petData and petData.step or 0
    local name_cfg = petCfg and petCfg:getNodeWithKey( "name" )
    local name = name_cfg and name_cfg:toStr() or ""
    if s_level > 0 then
        name = name .. "+" .. tostring(s_level)
    end
    self.label_name:setString( tostring(name) )
    self.label_name:setScale(0.7)


    self:refreshPetStoryInfo(petCfg,petData)

    local pet_skill_stone = game_data:getUserStatusDataByKey("pet_skill_stone") or 0
    self.num_have:setString(pet_skill_stone)
end
--[[
    星星显示
]]
function game_pet_skill_pop.createStar(self,star)
    self.node_starts_board:removeAllChildrenWithCleanup(true)
    for i=1,5 do
        local star_back = CCSprite:createWithSpriteFrameName("ui_pet_xingxing2.png")
        self.node_starts_board:addChild(star_back)
        star_back:setPosition(ccp(20 + (i-1) * 15,9))
        if i <= star then
            local star = CCSprite:createWithSpriteFrameName("ui_pet_xingxing1.png")
            self.node_starts_board:addChild(star)
            star:setPosition(ccp(20 + (i-1) * 15,9))
        end
    end
end
--[[
    刷新宠物描述信息
]]
function game_pet_skill_pop.refreshPetStoryInfo( self, petCfg ,petData )
    local pet_skill_detail = getConfig(game_config_field.pet_skill_detail)
    local s = ""
    local itemSkill = nil
    if petData["s_" .. self.m_skill_index] then
        itemSkill = petData["s_" .. self.m_skill_index]
        s = itemSkill.s
    end
    -- cclog2(petData,"petData")
    self.skill_id = s
    local skillCfg = pet_skill_detail:getNodeWithKey(tostring(s))
    local skill_story = skillCfg:getNodeWithKey("skill_story"):toStr()

    -- self.m_story_label:setString( skill_story )
    local skillLevel = itemSkill.lv or 1
    local cd = skillCfg:getNodeWithKey("cd"):toInt()
    local rate = skillCfg:getNodeWithKey("rate"):toInt()
    local evo_story = skillCfg:getNodeWithKey("evo_story"):toStr()
    self.label_limit_info_2:setString(cd .. "hiệp")
    self.label_limit_info_1:setString(rate .. "%")
    self.label_limit_info_3:setString(evo_story)

    local effect = skillCfg:getNodeWithKey("effect"):toFloat();
    local attr_effect = skillCfg:getNodeWithKey("attr_effect"):toFloat()
    attr_effect = string.format("%.1f",attr_effect)
    skill_story = string.gsub(skill_story,"attr",tostring(attr_effect*100));
    local effect_lvchange = skillCfg:getNodeWithKey("effect_lvchange"):toFloat();
    effect_lvchange = string.format("%.1f",effect_lvchange)
    local tempEffect = string.format("%.1f",effect + effect_lvchange*skillLevel)
    skill_story = string.gsub(skill_story,"effect",tostring(tempEffect));
    self.m_story_label:setString(skill_story);
    --  经验
    local pet_skill_levelup = getConfig(game_config_field.pet_skill_levelup)
    local levelUp = pet_skill_levelup:getNodeWithKey(tostring(itemSkill.lv)):getNodeWithKey("skill_exp")  -- 取出数组，再按品质取

    self.label_level:setString( "LV." .. tostring(itemSkill.lv) )

    local skill_quality = skillCfg:getNodeWithKey("skill_quality"):toInt()
    local exp = itemSkill.exp
    -- cclog2(levelUp,"levelUp")
    local max_exp = levelUp:getNodeAt(tostring(skill_quality)):toInt()

    self.node_progress_exp:removeAllChildrenWithCleanup( true )

    local bar_size = self.node_progress_exp:getContentSize();
    local bar = ExtProgressTime:createWithFrameName("ui_pet_jindutiaoA1.png","ui_pet_jindutiaoA2.png");
    bar:addLabelTTF(CCLabelTTF:create("0/100",TYPE_FACE_TABLE.Arial_BoldMT,12));
    self.node_progress_exp:addChild(bar,10,10);
    bar:setMaxValue(max_exp);
    bar:setCurValue(exp,false);
end

--[[--
    初始化
]]
function game_pet_skill_pop.init(self,t_params)
    t_params = t_params or {};

    self.m_petId = t_params.petId or -1
    self.m_skill_index = t_params.skill_index
    self.skill_id = nil
    self.m_callBackFunc = t_params.callBackFunc
end

--[[--
    创建ui入口并初始化数据
]]
function game_pet_skill_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_pet_skill_pop;