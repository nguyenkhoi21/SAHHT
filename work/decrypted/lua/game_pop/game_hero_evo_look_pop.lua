---  

local game_hero_evo_look_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_list_view_bg = nil,
    m_evo_label = nil,
    m_selHeroId = nil,
    m_skillTab = nil,
    m_evoType = nil,
    m_curr_evo_sprite = nil,
};
--[[--
    销毁
]]
function game_hero_evo_look_pop.destroy(self)
    -- body
    cclog("-----------------game_hero_evo_look_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_list_view_bg = nil;
    self.m_evo_label = nil;
    self.m_selHeroId = nil;
    self.m_skillTab = nil;
    self.m_evoType = nil;
    self.m_curr_evo_sprite = nil;
end
--[[--
    返回
]]
function game_hero_evo_look_pop.back(self,type)
    game_scene:removePopByName("game_hero_evo_look_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_hero_evo_look_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_hero_evo_look.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_evo_label = ccbNode:labelTTFForName("m_evo_label");
    self.m_curr_evo_sprite = ccbNode:spriteForName("m_curr_evo_sprite");
    self.m_evo_label:setString("+0");
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"), "CCControlButton");
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- self:back();
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    
]]
function game_hero_evo_look_pop.createTableView(self,viewSize)
    local cardData,heroCfg = game_data:getCardDataById(tostring(self.m_selHeroId));
    local quality = heroCfg:getNodeWithKey("quality"):toInt();
    local evolutionCfg = game_data:getEvolutionCfgByHeroCfg(heroCfg);--game_util:getEvolutionCfgByQuality(quality);
    if heroCfg == nil or evolutionCfg == nil then
        return nil;
    end
    local race = heroCfg:getNodeWithKey("race"):toInt();
    local currStep = cardData.step
    local currEvo = cardData.evo;
    local level_max = cardData.level_max;
    self.m_evo_label:setString("+" .. currStep);

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag ============= " .. btnTag)
        local tempData = self.m_skillTab[btnTag];
        if tempData and tempData.s ~= nil then
            game_scene:addPop("skills_activation_pop",{skillData=tempData})
        end
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = 4;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_hero_evo_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            ccbNode:controlButtonForName("m_up_attr_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_up_attr_btn = ccbNode:controlButtonForName("m_up_attr_btn")
            m_up_attr_btn:setTag(index);
            local m_next_label = ccbNode:labelTTFForName("m_next_label");
            local m_evo_label = ccbNode:labelTTFForName("m_evo_label");
            local m_skill_up_label = ccbNode:labelTTFForName("m_skill_up_label");
            m_skill_up_label:setString("Không có");
            local m_attr_label_1 = ccbNode:labelTTFForName("m_attr_label_1");
            local m_value_label_1 = ccbNode:labelTTFForName("m_value_label_1");
            local m_icon_node = ccbNode:nodeForName("m_icon_node");
            m_icon_node:removeAllChildrenWithCleanup(true);
            m_icon_node:setScale(0.75);
            m_next_label:setVisible(index == 0)
            local tempEvo = currEvo + index
            local evolutionItemCfg1 = evolutionCfg:getNodeWithKey(tostring(tempEvo))
            local evolutionItemCfg2 = evolutionCfg:getNodeWithKey(tostring(tempEvo + 1))
            if evolutionItemCfg1 and evolutionItemCfg2 then
                m_evo_label:setString(string.format("+%dhiệu quả",evolutionItemCfg2:getNodeWithKey("step"):toInt()));

                local maxlv1 = evolutionItemCfg1:getNodeWithKey("maxlv"):toInt();
                local maxlv2 = evolutionItemCfg2:getNodeWithKey("maxlv"):toInt();
                cclog("maxlv2 =========== " .. maxlv2 .. " ; maxlv1 == " .. maxlv1)
                if maxlv2 > maxlv1 then
                    local tempIcon = CCSprite:createWithSpriteFrameName("hbjj_dengji.png")
                    if tempIcon then
                        m_icon_node:addChild(tempIcon);
                    end
                    m_skill_up_label:setString("Giới hạn cấp độ\n+" .. (maxlv2-maxlv1));
                end
                --技能
                local skill1 = evolutionItemCfg1:getNodeWithKey("skill")
                local skill2 = evolutionItemCfg2:getNodeWithKey("skill")
                local skillIndex = -1;
                local evoStep = -1;
                local evoStep1 = -1;
                for i=1,3 do
                    evoStep = skill2:getNodeAt(i-1):toInt()
                    evoStep1 = skill1:getNodeAt(i-1):toInt();
                    if evoStep ~= evoStep1 then
                        skillIndex = i;
                        break;
                    end
                end
                local skillItem = cardData["s_" .. skillIndex]
                if skillItem then
                    self.m_skillTab[index] = util.table_copy(skillItem);
                    if evoStep == 1 then
                        local tempIcon,skill_name = game_util:createSkillIconByCid(skillItem.s)
                        m_skill_up_label:setString(tostring(skill_name) .. "\nMở kĩ năng");
                        if tempIcon then
                            m_icon_node:addChild(tempIcon);
                        end
                    elseif evoStep > 1 then
                        local tempIcon,skillId,skill_name = self:getSkillEvoIcon(tostring(skillItem.s),evoStep,index,evoStep1)
                        m_skill_up_label:setString(tostring(skill_name) .. "\nMở khóa");
                        self.m_skillTab[index].s = skillId
                        if tempIcon then
                            m_icon_node:addChild(tempIcon);
                        end
                    end
                end
                --属性
                local attrValueTab = nil;
                local attrType1 = evolutionItemCfg1:getNodeWithKey("type" .. race)
                local attrType2 = evolutionItemCfg2:getNodeWithKey("type" .. race)
                if attrType1 and attrType2 then
                    local add_patk = attrType2:getNodeAt(0):toInt() - attrType1:getNodeAt(0):toInt()
                    local add_matk = attrType2:getNodeAt(1):toInt() - attrType1:getNodeAt(1):toInt() 
                    local add_def = attrType2:getNodeAt(2):toInt() - attrType1:getNodeAt(2):toInt()
                    local add_speed = attrType2:getNodeAt(3):toInt() - attrType1:getNodeAt(3):toInt()
                    local add_hp = attrType2:getNodeAt(4):toInt() - attrType1:getNodeAt(4):toInt()
                    attrValueTab = {add_patk,add_matk,add_def,add_speed,add_hp}
                else
                    attrValueTab = {0,0,0,0,0};
                end
                local attrValue,attrIndex = 0,1;
                local attrType11 = evolutionItemCfg1:getNodeWithKey("attr" .. race)
                local attrType22 = evolutionItemCfg2:getNodeWithKey("attr" .. race)
                if attrType11 and attrType22 then
                    for i=1,8 do
                        attrValue = attrType22:getNodeAt(i-1):toInt() - attrType11:getNodeAt(i-1):toInt()
                        if attrValue > 0 then
                            attrIndex = i;
                            break;
                        end
                    end
                end
                local all1 = evolutionItemCfg1:getNodeWithKey("all"):toFloat();
                local all2 = evolutionItemCfg2:getNodeWithKey("all"):toFloat();
                if all2 > all1 then
                    local tempIcon = CCSprite:createWithSpriteFrameName("hbjj_shuxing.png")
                    if tempIcon then
                        m_icon_node:addChild(tempIcon);
                    end
                    m_skill_up_label:setString("Toàn bộ thuộc tính\n+" .. string.format("%.0f",(all2-all1)*100) .. "%");
                end
                local posIndex = 1;
                for i=1,5 do
                    local tempValue = attrValueTab[i]
                    if tempValue > 0 then
                        ccbNode:labelTTFForName("m_attr_label_" .. posIndex):setString(PUBLIC_ABILITY_TABLE["ability_" .. i].name .. ":");
                        ccbNode:labelTTFForName("m_value_label_" .. posIndex):setString("+" .. tempValue);
                        posIndex = posIndex + 1;
                    end
                    if posIndex >= 4 then
                        break;
                    end
                end
                if attrValue > 0 then
                    local attrTypeIndex = COMBAT_ABILITY_TABLE.card_evo[attrIndex]
                    local m_attr_label = ccbNode:labelTTFForName("m_attr_label_4")
                    m_attr_label:setString(PUBLIC_ABILITY_TABLE["ability_" .. attrTypeIndex].name .. ":");
                    local m_value_label = ccbNode:labelTTFForName("m_value_label_4")
                    m_value_label:setString("+" .. attrValue);
                    m_attr_label:setVisible(true)
                    m_value_label:setVisible(true)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));

        end
    end
    return TableViewHelper:create(params);
end

--[[--
    
]]
function game_hero_evo_look_pop.getSkillEvoIcon(self,skillId,evoStep,index,evoStep1)
    local tempIcon = nil;
    local skill_detail_cfg = getConfig(game_config_field.skill_detail);

    local function getIconById(tempId)
        local itemCfg = skill_detail_cfg:getNodeWithKey(tostring(tempId));
        if itemCfg then
            local is_evolution = itemCfg:getNodeWithKey("is_evolution"):toStr();
            local tempCfg = skill_detail_cfg:getNodeWithKey(tostring(is_evolution));
            local tempIcon2 = game_util:createSkillIconByCfg(tempCfg)
            return tempIcon2,is_evolution,itemCfg:getNodeWithKey("skill_name"):toStr()
        end
        return nil,nil;
    end
    local tempSkillId = skillId;
    local skill_name = "";
    for i=evoStep1,evoStep-1 do
        tempIcon,tempSkillId,skill_name = getIconById(tempSkillId)
    end
    return tempIcon,tempSkillId,skill_name;
end

--[[--
    刷新
]]
function game_hero_evo_look_pop.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    if tableView then
        tableView:setTouchEnabled(false)
        tableView:setScrollBarVisible(false);
        self.m_list_view_bg:addChild(tableView);
    end
end


--[[--
    
]]
function game_hero_evo_look_pop.createSuperEvoTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/super_evolution_res.plist");
    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("cjh_dangqian.png")
    if tempSpriteFrame and self.m_curr_evo_sprite then
        self.m_curr_evo_sprite:setDisplayFrame(tempSpriteFrame)
    end
    local cardData,heroCfg = game_data:getCardDataById(tostring(self.m_selHeroId));
    local quality = heroCfg:getNodeWithKey("quality"):toInt();
    local super_quality_1 = cardData.super_quality_1 or 0
    local hero_quality_item = super_quality_1 > 0 and HERO_QUALITY_COLOR_TABLE_2[super_quality_1] or HERO_QUALITY_COLOR_TABLE[quality+1]
    if hero_quality_item then
        self.m_evo_label:setString(hero_quality_item.name)
        self.m_evo_label:setColor(hero_quality_item.color)
    else
        self.m_evo_label:setString("")
    end
    local super_evolution_value = (cardData.super_step or 0) + 1--下一阶
    local super_evolution_cfg = getConfig(game_config_field.super_evolution)
    local super_evo = heroCfg:getNodeWithKey("super_evo")
    super_evo = super_evo and super_evo:toInt() or 0
    local super_evolution_cfg = getConfig(game_config_field.super_evolution);
    local super_evolution_cfg_item = super_evolution_cfg:getNodeWithKey(tostring(super_evo))
    if super_evolution_cfg_item == nil then
        game_util:addMoveTips({text = "Siêu tiến hóa thiếu cấu hình" .. tostring(super_evo)});
        return
    end
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag ============= " .. btnTag)
        local tempData = self.m_skillTab[btnTag];
        if tempData and tempData.s ~= nil then
            game_scene:addPop("skills_activation_pop",{skillData=tempData})
        end
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = 4;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_hero_evo_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            ccbNode:controlButtonForName("m_up_attr_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_up_attr_btn = ccbNode:controlButtonForName("m_up_attr_btn")
            m_up_attr_btn:setTag(index);
            local m_next_label = ccbNode:labelTTFForName("m_next_label");
            local m_evo_label = ccbNode:labelTTFForName("m_evo_label");
            local m_skill_up_label = ccbNode:labelTTFForName("m_skill_up_label");
            m_skill_up_label:setString("Không"); --无
            local m_icon_node = ccbNode:nodeForName("m_icon_node");
            m_icon_node:removeAllChildrenWithCleanup(true);
            m_icon_node:setScale(0.75);
            m_next_label:setVisible(index == 0)
            m_next_label:setString("Tiến hóa lần sau")
            local tempEvo = super_evolution_value + index
            local level_add = super_evolution_cfg_item:getNodeWithKey("level_" .. tempEvo .. "_add")
            if level_add then
                local tempShowData = json.decode(level_add:getFormatBuffer())
                local showData = {}
                for i=1,#tempShowData do
                    if tempShowData[i][1] < 501 then
                        table.insert(showData,tempShowData[i])
                    end
                end
                if #showData > 0 then
                    local super_quality_1 = cardData.super_quality_1 or 0
                    super_quality_1 = super_quality_1 + index + 1
                    local hero_quality_item = super_quality_1 > 0 and HERO_QUALITY_COLOR_TABLE_2[super_quality_1] or HERO_QUALITY_COLOR_TABLE[quality+1]
                    if hero_quality_item then
                        m_evo_label:setString(hero_quality_item.name)
                        m_evo_label:setColor(hero_quality_item.color)
                    else
                        m_evo_label:setString("Hiệu quả")
                    end
                end
                for i=1,6 do
                    local m_attr_label = ccbNode:labelTTFForName("m_attr_label_" .. i);
                    local m_value_label = ccbNode:labelTTFForName("m_value_label_" .. i);
                    local itemData = showData[i]
                    if itemData then
                        local attrValue = itemData[1] or 0
                        local attrTab = PUBLIC_ABILITY_TABLE["ability_" .. tostring(attrValue)]
                        if attrTab then
                            m_attr_label:setString(tostring(attrTab.name) .. ":")
                            m_value_label:setString("+" .. tostring(itemData[2]))
                            m_attr_label:setVisible(true)
                            m_value_label:setVisible(true)
                        end
                    end
                end
                local skill4_open = super_evolution_cfg_item:getNodeWithKey("skill4_open"):toInt()
                local skill5_open = super_evolution_cfg_item:getNodeWithKey("skill5_open"):toInt()
                local skillItem = nil
                if skill4_open == tempEvo then
                    skillItem = cardData["s_4"]
                elseif skill5_open == tempEvo then
                    skillItem = cardData["s_5"]
                end
                if skillItem and skillItem.s ~= 0 then
                    self.m_skillTab[index] = util.table_copy(skillItem);
                    local tempIcon,skill_name = game_util:createSkillIconByCid(skillItem.s)
                    m_skill_up_label:setString(tostring(skill_name) .. "\nMở kĩ năng");
                    if tempIcon then
                        m_icon_node:addChild(tempIcon);
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then

        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function game_hero_evo_look_pop.refreshSuperEvoTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableView = self:createSuperEvoTableView(self.m_list_view_bg:getContentSize());
    if tableView then
        tableView:setTouchEnabled(false)
        tableView:setScrollBarVisible(false);
        self.m_list_view_bg:addChild(tableView);
    end
end

--[[--
    刷新ui
]]
function game_hero_evo_look_pop.refreshUi(self)
    if self.m_evoType == 0 then
        self:refreshTableView();
    elseif self.m_evoType == 1 then
        self:refreshSuperEvoTableView()
    end
end

--[[--
    初始化
]]
function game_hero_evo_look_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selHeroId = t_params.selHeroId;
    self.m_evoType = t_params.evoType or 0 -- 0 进阶 1 超进化
    self.m_skillTab = {};
end

--[[--
    创建ui入口并初始化数据
]]
function game_hero_evo_look_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_hero_evo_look_pop;