--- 弹框选择

local game_god_equip_select_pop = {
    m_list_view_bg = nil,
    m_tableView = nil,
    m_posIndex = nil,
    m_selSort = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_btnCallFunc = nil,
    m_itemOnClick = nil,
    m_openType = nil,
    m_title_label = nil,
    m_popUi = nil,
    m_sortBtnShow = nil,
    m_guildNode = nil,
    m_EquipPosDataTab = nil,
    m_tempTeamData = nil,
    m_btn_index = nil,
};
--[[--
    销毁ui
]]
function game_god_equip_select_pop.destroy(self)
    -- body
    cclog("-----------------game_god_equip_select_pop destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_tableView = nil;
    self.m_posIndex = nil;
    self.m_selSort = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_btnCallFunc = nil;
    self.m_itemOnClick = nil;
    self.m_openType = nil;
    self.m_title_label = nil;
    self.m_popUi = nil;
    self.m_sortBtnShow = nil;
    self.m_guildNode = nil;
    self.m_EquipPosDataTab = nil;
    self.m_tempTeamData = nil;
    self.m_btn_index = nil;
end

--[[--
    返回
]]
function game_god_equip_select_pop.back(self,type)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("game_god_equip_select_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_god_equip_select_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            if self.m_btnCallFunc then
                self.m_btnCallFunc(target,event)
            end
            self:back();
        elseif btnTag == 2 then
            local function btnCallBack(btnTag)
                cclog("btnCallBack ===========btnTag===" .. btnTag)
                local selSort = tonumber(EQUIP_SORT_TAB[btnTag].sortType);
                self:refreshEquipTableView(selSort);
            end
            game_scene:addPop("game_sort_pop",{btnTitleTab = EQUIP_SORT_TAB,btnCallFunc = btnCallBack,currentSortType = self.m_selSort})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_list.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    self.m_title_label = ccbNode:labelBMFontForName("m_title_label")
    self.m_title_label:setString("List trang bị")
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12);
    self.m_sort_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12);
    game_util:setControlButtonTitleBMFont(self.m_sort_btn)
    -- game_util:setCCControlButtonBackground(self.m_back_btn,"public_backNormal2.png","public_backDown2.png","public_backDown2.png");
    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-11,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建装备列表
]]
function game_god_equip_select_pop.createEquipTableView(self,viewSize,tableData)
    
end

--[[--
    创建装备列表
]]
function game_god_equip_select_pop.createEquipTableView2(self,viewSize,tableData)
    cclog("game_god_equip_select_pop json.encode(tableData) == " .. json.encode(tableData))
    local itemsCount = #tableData + 1;
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = self:createEquipItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < itemsCount then
                if index == 0 then
                    m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg2.png"))
                    m_spr_bg_up:setVisible(true);
                    ccbNode:nodeForName("m_info_node"):setVisible(false);
                else
                    m_spr_bg_up:setVisible(false);
                    local itemData,itemCfg = game_data:getEquipDataById(tableData[index]);
                    self:setEquipItemInfoByTable(ccbNode,itemData);
                    local m_team_img = ccbNode:spriteForName("m_team_img")
                    if not m_team_img:isVisible() then
                        local id = game_guide_controller:getCurrentId();
                        if id == 32 and self.m_guildNode == nil then
                            cell:setContentSize(itemSize);
                            self.m_guildNode = cell;
                        end
                    end
                end
            else
                m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg.png"))
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
            if index == 0 then
                self.m_itemOnClick("unload",nil);
                self:back();
            else
                
                local itemData,itemCfg = game_data:getEquipDataById(tableData[index]);
                if self.m_itemOnClick and itemData then
                    self.m_itemOnClick("exchanged",tableData[index]);
                    -- self:back();
                end
            end
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新列表
]]
function game_god_equip_select_pop.refreshEquipTableView(self,sort)
    self.m_selSort = sort;
    if self.m_tableView ~= nil then
        self.m_tableView:removeFromParentAndCleanup(true);
    end
    local equipData = game_data:getEquipDataByEquipType(self.m_selSort);   
    if self.m_openType == 2 then 
        self.m_tableView = self:createEquipTableView2(self.m_list_view_bg:getContentSize(),equipData);
    else
        self.m_tableView = self:createEquipTableView(self.m_list_view_bg:getContentSize(),equipData);
    end
    self.m_list_view_bg:addChild(self.m_tableView);
    local id = game_guide_controller:getCurrentId();
    if id == 32 then
        self.m_tableView:setTouchEnabled(false);
    end
    local typeName = EQUIP_TYPE_NAME_TABLE["type_" .. self.m_selSort]
    if typeName then
        self.m_title_label:setString(typeName .. "List")
    end
end

function game_god_equip_select_pop.createEquipItemByCCB(self,itemData)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_equip_list_item.ccbi");
    ccbNode:setAnchorPoint(ccp(0.5,0.5));
    if ccbNode ~= nil and itemData ~= nil then
        self:setEquipItemInfoByTable(ccbNode,itemData);
    end
    return ccbNode
end

function game_god_equip_select_pop.setEquipItemInfoByTable(self,ccbNode,itemData)
    if ccbNode == nil or itemData == nil then return end
    ccbNode:nodeForName("m_info_node"):setVisible(true);
    local equipCfg = getConfig(game_config_field.equip);
    local itemCfg = equipCfg:getNodeWithKey(itemData.c_id);
    local level = itemData.lv;
    local attrName1,value1,attrName2,value2,icon1,icon2 = game_util:getEquipAttributeValue(itemCfg,level,itemData);
    local m_ability1_label = ccbNode:labelBMFontForName("m_ability1_label")
    local recast_icon = ccbNode:spriteForName("recast_icon")
    if  itemData.is_equip_recast then
        recast_icon:setVisible(true)
    else
        recast_icon:setVisible(false)
    end
    local parentNode = m_ability1_label:getParent()
    local value1,unit1 = game_util:formatValueToString2(value1)
    local value2,unit2 = game_util:formatValueToString2(value2)
    ccbNode:labelBMFontForName("m_ability1_label"):setString(value1..unit1);
    ccbNode:labelBMFontForName("m_ability2_label"):setString(value2..unit2);
    -- ccbNode:labelBMFontForName("m_ability1_label"):setString(value1);
    -- ccbNode:labelBMFontForName("m_ability2_label"):setString(value2);
    ccbNode:spriteForName("m_ability1_icon"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon1));
    ccbNode:spriteForName("m_ability2_icon"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon2));
    local sort = itemCfg:getNodeWithKey("sort"):toInt();
    -- ccbNode:labelBMFontForName("m_type_label"):setString(tostring(EQUIP_TYPE_NAME_TABLE["type_" ..tostring(sort)]));
    ccbNode:spriteForName("m_type_icon"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(PUBLIC_ABILITY_TABLE["ability_" .. sort].icon))
    local quality = itemCfg:getNodeWithKey("quality"):toInt()+1;
    if quality > 0 and quality < 10 then
        ccbNode:spriteForName("m_spr_bg"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(HERO_QUALITY_COLOR_TABLE[quality].card_img));
        --装备品质框
        local disPla = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(EQUIP_QUALITY_COLOR_TABLE[quality].img2)
        local m_kuang = ccbNode:spriteForName("m_kuang")
        if disPla and m_kuang then
            m_kuang:setDisplayFrame(disPla);
        end
    end
    -- local equip_strongthen = getConfig(game_config_field.equip_strongthen);
    -- local userLevel = game_data:getUserStatusDataByKey("level") or 1;
    -- ccbNode:labelTTFForName("m_level_label"):setString("Lv." .. level .. "/" .. math.min(equip_strongthen:getNodeCount(),userLevel));
    --装备名称加等级
    -- local m_name_label = ccbNode:labelBMFontForName("m_name_label");
    local m_name_label = ccbNode:labelTTFForName("m_name_label");
    local m_lv = ccbNode:labelTTFForName("m_lv");
    m_name_label:setString(itemCfg:getNodeWithKey("name"):toStr());
    m_lv:setString("Lv." .. level);
    -- game_util:setEquipNameColorByQuality(m_name_label,itemCfg);

    ccbNode:spriteForName("m_sel_img"):setVisible(false);
    local m_team_img = ccbNode:spriteForName("m_team_img")
    -- local m_team_name = ccbNode:labelBMFontForName("m_team_name")
    local m_team_name = ccbNode:labelTTFForName("m_team_name")
    --所属英雄
    local existFlag,cardName = self:equipInEquipPos(itemCfg:getNodeWithKey("sort"):toInt(),itemData.id)
    local isHeroEquipFlag = false
    isHeroEquipFlag = game_data:isEquipInHeroEquipTab(itemData.id)
    if existFlag or isHeroEquipFlag then
        m_team_img:setVisible(true);
        if isHeroEquipFlag then
            m_team_name:setString("已装备");
        else
            m_team_name:setString(cardName);
        end
    else
        m_team_img:setVisible(false);
        m_team_name:setString("");
    end
   local m_god_img = ccbNode:spriteForName("m_god_img")
    local godexistFlag = game_data:godequipInEquipPos(itemCfg:getNodeWithKey("sort"):toInt(),itemData.id,ccbNode) --设置神域标志

    -- if existFlag then
    --     m_team_img:setVisible(true);
    --     m_team_name:setString(cardName);
    -- else
    --     m_team_img:setVisible(false);
    --     m_team_name:setString("");
    -- end

    if godexistFlag  then
        m_god_img:setVisible(true);
        m_god_img:setColor(ccc3(255,255,255));
    else
        m_god_img:setVisible(true);
        m_god_img:setColor(ccc3(50,50,50));
        -- m_god_img:setVisible(false);
    end
    local m_bonus_img = ccbNode:spriteForName("m_bonus_img")
    local existFlag2,pos = game_data:equipInBonus(itemCfg:getNodeWithKey("sort"):toInt(),itemData.id)
    if existFlag2 then 
        m_bonus_img:setVisible(true)
    else
        m_bonus_img:setVisible(false)
    end

    local m_anim_node = ccbNode:nodeForName("m_anim_node")
    m_anim_node:removeAllChildrenWithCleanup(true);
    local icon = game_util:createIconByName(itemCfg:getNodeWithKey("image"):toStr()) --self:createEquipIcon(itemCfg)
    if icon then
        m_anim_node:addChild(icon)
    end
    --英雄星级
    local refining_node = ccbNode:nodeForName("refining_node")
    local refining_sp = ccbNode:spriteForName("refining_sp")
    local refining_level = ccbNode:labelBMFontForName("refining_level")
    local st_lv = itemData.st_lv
    if st_lv > 0 then
        refining_node:setVisible(true)
        refining_sp:setColor(ccc3(255,255,255))
        refining_level:setString(tostring(st_lv))
    else
        refining_level:setString("")
        refining_sp:setColor(ccc3(50,50,50))
        refining_node:setVisible(true)
    end
    --装备锻造等级
    local forge_node = ccbNode:nodeForName("forge_node")
    local forge_sp = ccbNode:spriteForName("forge_sp")
    local forge_level = ccbNode:labelBMFontForName("forge_level")
    -- if st_lv > 0 then 
    --     forge_node:setPosition(ccp(55,116))
    -- else
    --     forge_node:setPosition(ccp(18,116))
    -- end
    local m_sprite_ming = ccbNode:spriteForName("m_sprite_ming")
    if itemData.bind_card and itemData.bind_card ~= "" then
        m_sprite_ming:setVisible(true)
        m_sprite_ming:setColor(ccc3(255,255,255))
        m_team_img:setVisible(true);
        local cardData,cardCfg = game_data:getCardDataById(itemData.bind_card)
        local name = cardCfg:getNodeWithKey("name"):toStr()
        m_team_name:setString(name);

    else
        m_sprite_ming:setVisible(true)
        m_sprite_ming:setColor(ccc3(50,50,50))

        -- m_sprite_ming:setVisible(false)

    end

    if itemData.equip_forge_level then
        local forge_lv = itemData.equip_forge_level.lv
        if forge_lv > 0 then
            forge_node:setVisible(true)
            forge_level:setString(tostring(forge_lv))
            forge_sp:setColor(ccc3(255,255,255))

        else
            forge_sp:setColor(ccc3(50,50,50))
            -- forge_node:setVisible(false)
            forge_node:setVisible(true)
            forge_level:setString("")
        end
    else
        forge_node:setVisible(true)
        forge_level:setString("")
        forge_sp:setColor(ccc3(50,50,50))
    end
    local m_eq_building_node = ccbNode:nodeForName("m_eq_building_node")
    m_eq_building_node:setVisible(false)
    if itemData.is_building and m_eq_building_node then
        local m_building_ab_sp = ccbNode:spriteForName("m_building_ab_sp")
        local m_building_ab_lb = ccbNode:labelBMFontForName("m_building_ab_lb")
        local build_type = itemData.build_type
        if build_type and PUBLIC_ABILITY_NAME_TABLE[build_type] then
            m_eq_building_node:setVisible(true)
            local ablityTab = PUBLIC_ABILITY_NAME_TABLE[build_type]
            local build_value = itemData.build_atts[build_type]
            local value1,unit1 = game_util:formatValueToString2(build_value)
            m_building_ab_lb:setString(value1 .. unit1)
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(ablityTab.icon)
            if tempSpriteFrame then
                m_building_ab_sp:setDisplayFrame(tempSpriteFrame);
            end
        end
    end

    -- 英雄附魔信息
    ccbNode:spriteForName("m_icon_ability_1"):setVisible(false)
    ccbNode:spriteForName("m_icon_ability_2"):setVisible(false)
    ccbNode:labelBMFontForName("m_label_ability_1"):setVisible(false)
    ccbNode:labelBMFontForName("m_label_ability_2"):setVisible(false)
    local atts = itemData.atts
    local is_enchant = itemData.is_enchant
    if is_enchant then -- 已附魔
        ccbNode:spriteForName("m_ability2_icon"):getParent():setPosition(ccp(45,30))
        local tempSpr ={}
        -- local spriteTable = {self.m_property_sprite_add_1,self.m_property_sprite_add_2}
        local i = 0 -- 计数 表示sprite的编号 1 2 
        for k,v in pairs(atts) do
            tempSpr = PUBLIC_ABILITY_NAME_TABLE[k] or {}
            -- cclog2(tempSpr,"tempSpr")
            i = i + 1
            local m_icon_ability = ccbNode:spriteForName("m_icon_ability_"..i)
            local m_label_ability = ccbNode:labelBMFontForName("m_label_ability_"..i)
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(tempSpr.icon))
            
            -- cclog2(tempSpriteFrame,"tempSpriteFrame")
            if tempSpriteFrame then
                m_icon_ability:setDisplayFrame(tempSpriteFrame)
                m_icon_ability:setVisible(true)
                local value,unit = game_util:formatValueToString2(v)
                m_label_ability:setString(value..unit)
                m_label_ability:setVisible(true)
            else

                m_icon_ability:setVisible(false)
                m_label_ability:setVisible(false)
            end
        end
    else
        -- 未附魔

        -- ccbNode:spriteForName("m_ability2_icon"):getParent():setPosition(ccp(45,23))
        ccbNode:spriteForName("m_icon_ability_1"):setVisible(false)
        ccbNode:spriteForName("m_icon_ability_2"):setVisible(false)
        ccbNode:labelBMFontForName("m_label_ability_1"):setVisible(false)
        ccbNode:labelBMFontForName("m_label_ability_2"):setVisible(false)
    end
    local anim_node =  ccbNode:nodeForName("anim_node")
    if anim_node:getChildren() then
        anim_node:removeAllChildrenWithCleanup(true)
    end
    if itemData.is_equip_recast and itemData.heroid then
        local equip_chain_table = getConfig(game_config_field.chain_equip) and json.decode(getConfig(game_config_field.chain_equip):getFormatBuffer()) or {}
        for i,v in ipairs(equip_chain_table[itemData.recast_bind..""].card_id) do
            if v..""  ==  itemData.heroid.."" then 
                local anim1 = game_util:createEffectAnim("jinkuang",1,true)
                anim_node:addChild(anim1,10,1)
                anim1:setScaleX(1.2)
                anim1:setPositionX(10)
                break
            end
        end
    end
end

--[[--
    判断是否装备上
]]
function game_god_equip_select_pop.equipInEquipPos(self,equipType,equipId)
    equipId = tostring(equipId);
    local existFlag = false;
    local cardName = "";
    local posEquipData = nil;
    local m_tEquipPosData1 = self.m_EquipPosDataTab[1];
    local m_tEquipPosData2 = self.m_EquipPosDataTab[2];
    local m_tEquipPosData3 = self.m_EquipPosDataTab[3];
    if equipType then
        for i=1,10 do
            -- cclog2(tostring(m_tEquipPosData1[tostring(i-1)][equipType]),"tostring(m_tEquipPosData1[tostring(i-1)][equipType])")
            if tostring(m_tEquipPosData1[tostring(i-1)][equipType]) == equipId  then
                posEquipData = m_tEquipPosData1[tostring(i-1)];
                existFlag = true

                local tempTeamD = self.m_tempTeamData[1]
                local _,itemCfg = nil, nil;
                local cardId = tempTeamD[i];
                if cardId and cardId ~= "-1" then
                    _,itemCfg = game_data:getCardDataById(cardId);
                end

                -- local _,itemCfg = self:getTeamCardDataByPos(i);
                if itemCfg then
                    cardName = itemCfg:getNodeWithKey("name"):toStr() .. "\nĐội hình 1，chỗ" .. i;
                else
                    cardName = "Đội hình 1\n" .. i .. "chỗ"
                end
                break;
            end
            if tostring(m_tEquipPosData2[tostring(i-1)][equipType]) == equipId then
                posEquipData = m_tEquipPosData2[tostring(i-1)];
                existFlag = true

                local tempTeamD = self.m_tempTeamData[2]
                local _,itemCfg = nil, nil;
                local cardId = tempTeamD[i];
                if cardId and cardId ~= "-1" then
                    _,itemCfg = game_data:getCardDataById(cardId);
                end
                -- local _,itemCfg = self:getTeamCardDataByPos(i);
                if itemCfg then
                    cardName = itemCfg:getNodeWithKey("name"):toStr() .. "\nĐội hình 2，chỗ" .. i;
                else
                    cardName = "Đội hình 2\n" .. i .. "chỗ"
                end
                break;
            end
            if tostring(m_tEquipPosData3[tostring(i-1)][equipType]) == equipId then
                posEquipData = m_tEquipPosData3[tostring(i-1)];
                existFlag = true

                local tempTeamD = self.m_tempTeamData[3]
                local _,itemCfg = nil, nil;
                local cardId = tempTeamD[i];
                if cardId and cardId ~= "-1" then
                    _,itemCfg = game_data:getCardDataById(cardId);
                end
                -- local _,itemCfg = self:getTeamCardDataByPos(i);
                if itemCfg then
                    cardName = itemCfg:getNodeWithKey("name"):toStr() .. "\nĐội hình 3，chỗ" .. i;
                else
                    cardName = "Đội hình 3\n" .. i .. "chỗ"
                end
                break;
            end
        end
    end
    return existFlag,cardName,posEquipData
end

-- --[[--
--     通过pos获得位置的卡牌数据
-- ]]
-- function game_god_equip_select_pop.getTeamCardDataByPos(self,posIndex)
--     cclog2(self.m_tempTeamData,"self.m_tempTeamData==234-423=4-324=-4")
--     local tempTeamD = self.m_tempTeamData[1]

--     local cardId = tempTeamD[posIndex];
--     if cardId and cardId ~= "-1" then
--         return game_data:getCardDataById(cardId);
--     end
--     return nil,nil;
-- end

--[[--
    刷新ui
]]
function game_god_equip_select_pop.refreshUi(self)
    self:refreshEquipTableView(self.m_selSort);
    self.m_sort_btn:setVisible(self.m_sortBtnShow);
end
--[[--
    初始化
]]
function game_god_equip_select_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_posIndex = t_params.posIndex;
    self.m_selSort = t_params.selSort or "-1";
    self.m_openType = t_params.openType or 1;
    self.m_btnCallFunc = t_params.btnCallFunc;
    self.m_itemOnClick = t_params.itemOnClick;
    self.m_tempTeamData = t_params.m_tempTeamData;

    self.m_btn_index =t_params.m_btn_index;
    self.m_sortBtnShow = t_params.sortBtnShow or false;
    self.m_EquipPosDataTab = t_params.m_EquipPosDataTab;
end

--[[--
    创建ui入口并初始化数据
]]
function game_god_equip_select_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    local id = game_guide_controller:getCurrentId();
    if self.m_guildNode and id == 32 then
        game_guide_controller:gameGuide("show","2",33,{tempNode = self.m_guildNode})
    end
    return self.m_popUi;
end

return game_god_equip_select_pop;