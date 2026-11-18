--- 法宝修炼
local game_magic_evolution = {
    m_anim_node = nil,--动画节点
    m_selMagicId = nil,--选中的heroid
    m_ok_btn = nil,
    m_canStrengthenFlag = nil,
    m_tips_spr_1 = nil,
    m_list_view_bg = nil,
    m_sel_btn = nil,
    m_showType = nil,
    m_selListItem = nil,
    m_back_btn = nil,
    m_level_label = nil,
    m_ability1_label = nil,
    m_ability2_label = nil,
    m_level_new_label = nil,
    m_ability1_new_label = nil,
    m_ability2_new_label = nil,
    m_ability1_name_label = nil,
    m_ability2_name_label = nil,
    m_ability1_new_label_2 = nil,
    m_ability2_new_label_2 = nil,
    m_ability1_name_label_2 = nil,
    m_ability2_name_label_2 = nil,
    m_ability1_label_2 = nil,
    m_ability2_label_2 = nil,
    m_material_layer = nil,
    m_material_node_tab = nil,
    m_materialDataTable = nil,
    m_curPage = nil,
    m_ccbNode = nil,
    m_anim_node_parent = nil,
    m_root_layer = nil,
    m_selFilterSortType = nil,
    m_cost_metal_label = nil,
    m_metal_total_label = nil,
    m_selEquipDataTab = nil,
    m_status = nil,
    m_selSortIndex = nil,
    m_combatNumberChangeNode = nil,
    m_tempCombatValue = nil,
    m_shop_btn = nil,
    daoju_total = nil,
    daoju_need = nil,
    daoju_num = nil,
    m_openType = nil,
    myformation = nil,
    m_tableView = nil,
    m_forging_btn = nil,
};
--[[--
    销毁ui
]]
function game_magic_evolution.destroy(self)
    -- body
    cclog("-----------------game_magic_evolution destroy-----------------");
    self.m_anim_node = nil;
    self.m_selMagicId = nil;
    self.m_ok_btn = nil;
    self.m_canStrengthenFlag = nil;
    self.m_tips_spr_1 = nil;
    self.m_list_view_bg = nil;
    self.m_sel_btn = nil;
    self.m_showType = nil;
    self.m_selListItem = nil;
    self.m_back_btn = nil;
    self.m_level_label = nil;
    self.m_ability1_label = nil;
    self.m_ability2_label = nil;
    self.m_level_new_label = nil;
    self.m_ability1_new_label = nil;
    self.m_ability2_new_label = nil;
    self.m_ability1_name_label = nil;
    self.m_ability2_name_label = nil;
    self.m_ability1_new_label_2 = nil;
    self.m_ability2_new_label_2 = nil;
    self.m_ability1_name_label_2 = nil;
    self.m_ability2_name_label_2 = nil;
    self.m_ability1_label_2 = nil;
    self.m_ability2_label_2 = nil;
    self.m_material_layer = nil;
    self.m_material_node_tab = nil;
    self.m_materialDataTable = nil;
    self.m_curPage = nil;
    self.m_ccbNode = nil;
    self.m_anim_node_parent = nil;
    self.m_root_layer = nil;
    self.m_selFilterSortType = nil;
    self.m_cost_metal_label = nil;
    self.m_metal_total_label = nil;
    self.m_selEquipDataTab = nil;
    self.m_status = nil;
    self.m_selSortIndex = nil;
    self.m_combatNumberChangeNode = nil;
    self.m_tempCombatValue = nil;
    self.m_shop_btn = nil;
    self.daoju_total = nil;
    self.daoju_need = nil;
    self.m_openType = nil;
    self.daoju_num = nil;
    self.myformation = nil;
    self.m_tableView = nil;
    self.m_forging_btn = nil;
end
local lab_text = {
    attribute_node0 = {
        {old = "m_hp1",new = "m_hp2",name = "生命",base = "hp",},
        {old = "m_def1",new = "m_def1",name = "防御",base = "def",},
        {old = "m_dodge1",new = "m_dodge1",name = "闪避",base = "dr",},
        {old = "m_speed1",new = "m_speed1",name = "速度",base = "speed",},
    },
    attribute_node1 = {
        {old = "m_att1",new = "m_att1",name = "物攻",base = "patk",},
        {old = "m_hr1",new = "m_hr1",name = "魔攻",base = "matk",},
        {old = "m_crit1",new = "m_crit1",name = "暴击",base = "crit",},
        {old = "m_hit1",new = "m_hit1",name = "命中",base = "hr",},
    },
}
--[[--
    返回
]]
function game_magic_evolution.back(self,backType)
    if backType == "back" then
        if  self.m_openType == "new_fenzheng" or  self.m_openType == "game_godfield_main" or self.m_openType == "fenzheng_main" or self.m_openType == "game_godfield_fenzheng" or self.m_openType == "godfield_teamboss" or self.m_openType == "game_godfield_fenzhengTeam" or self.m_openType == "game_god_adjustment" or self.m_openType == "nightmare" or self.m_openType == "expedition" or self.m_openType == "game_godfield_pvp_pop" then 
            local function responseMethod(tag,gameData)
                if gameData then
                    game_scene:enterGameUi("game_god_adjustment",{gameData = gameData,openType=self.m_openType,team_index = 1,myformation = self.myformation});
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_upload_god_formation"), http_request_method.GET, nil,"god_field_upload_god_formation",true,true)
        else
            local function endCallFunc()
                self:destroy();
            end
            game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
        end
    end
end
--[[--
    读取ccbi创建ui    equipSortByTypeName
]]
function game_magic_evolution.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 101 then--开始进阶
            self:onSureFunc();  
        elseif btnTag == 102 then -- 规则介绍
            game_scene:addPop("game_active_limit_detail_pop",{enterType = "185"})
		elseif btnTag >= 201 and btnTag <= 204 then--排序
            -- cclog("btnCallBack ===========btnTag===" .. btnTag)
            local selSort = tostring(EQUIP_SORT_TAB[btnTag-200].sortType);
            game_data:magicSortByTypeName(selSort)
            self:refreshSortTabBtn(btnTag-200);
        elseif btnTag == 301 then -- 淬炼
            game_scene:enterGameUi("game_magic_talisman_forging",{openType = "game_magic_evolution",talisman_id = self.m_selMagicId })
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_magic_evolution.ccbi");
    --英雄相关
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_shop_btn = ccbNode:controlButtonForName("m_shop_btn")
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_level_label = ccbNode:labelTTFForName("m_level_label")
    self.m_ability1_label = ccbNode:labelTTFForName("m_ability1_label")
    self.m_ability2_label = ccbNode:labelTTFForName("m_ability2_label")
    self.m_level_new_label = ccbNode:labelTTFForName("m_level_new_label")

    self.m_scroll_node = ccbNode:nodeForName("m_scroll_node")
    self.m_scroll = ccbNode:scrollViewForName("m_scroll")
    self.m_detail_lb = ccbNode:labelTTFForName("detail_lb")

    self.m_cost_metal_label = ccbNode:labelBMFontForName("m_cost_metal_label")
    self.m_metal_total_label = ccbNode:labelBMFontForName("m_metal_total_label")
    self.m_forging_btn = ccbNode:spriteForName("m_forging_btn")
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScale(resolution_config:getScale())
--self.m_forging_btn:setVisible(true)
    local m_mate_tips = nil;
    local m_material_node,m_mate_cost_label,m_mate_total_label,parentNode = nil;
    self.m_anim_node_parent = ccbNode:nodeForName("m_anim_node_parent")
    game_util:setControlButtonTitleBMFont(self.m_sel_btn)
    game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    game_util:setControlButtonTitleBMFont(self.m_shop_btn)
    self.m_ccbNode = ccbNode


    local m_combat_node = ccbNode:nodeForName("m_combat_node");
    self.m_combatNumberChangeNode = game_util:createExtNumberChangeNode({labelType = 2});
    self.m_combatNumberChangeNode:setAnchorPoint(ccp(0, 0.5));
    -- self.m_combatNumberChangeNode:setScale(0.75);
    m_combat_node:addChild(self.m_combatNumberChangeNode);
    self.m_combatNumberChangeNode:setCurValue(0,false);

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    self.m_root_layer:setTouchEnabled(false);
    return ccbNode;
end

--[[--
    
]]
function game_magic_evolution.onSureFunc(self)
    if self.m_selMagicId == nil then
        game_util:addMoveTips({text = "Hãy chọn Pháp Bảo!"});
        return;
    end
    local itemData,selCfg1 = game_data:getMagicDataById(self.m_selMagicId)
    local talisman_break = getConfig(game_config_field.talisman_break);
    local talisman = getConfig(game_config_field.talisman);
    -- local selCfg1 = json.decode(talisman:getNodeWithKey(itemData.c_id):getFormatBuffer())
    if not selCfg1 then game_util:addMoveTips({text = "Hãy cập nhật cấu hình"}); return end
    local selCfg2 = nil
    if talisman_break:getNodeWithKey(itemData.c_id) then
        selCfg2 = json.decode(talisman_break:getNodeWithKey(itemData.c_id):getFormatBuffer())
    end
    if selCfg1.talisman_break == 0 and (not selCfg2) then
        game_util:addMoveTips({text = "Pháp Bảo đã luyện đến cao nhất!"});
        return;
    end
    game_scene:addPop("game_magic_levelup_pop",{magic_id = self.m_selMagicId})  --magic_id 
end



--[[--
    装备属性信息

    local lab_text = {
    attribute_node0 = {
        {old = "m_hp1",new = "m_hp2",name = "生命",base = "hp"},
        {old = "m_def1",new = "m_def1",name = "防御",base = "def"},
        {old = "m_dodge1",new = "m_dodge1",name = "闪避",base = "dr"},
        {old = "m_speed1",new = "m_speed1",name = "速度",base = "speed"},
    },
    attribute_node1 = {
        {old = "m_att1",new = "m_att1",name = "物攻",base = "patk"},
        {old = "m_hr1",new = "m_hr1",name = "魔攻",base = "matk"},
        {old = "m_crit1",new = "m_crit1",name = "暴击",base = "crit"},
        {old = "m_hit1",new = "m_hit1",name = "命中",base = "hr"},
    },
}
]]
function game_magic_evolution.refreshMagicInfo(self,magicId)
    if self.m_selMagicId then
        local selMagicid = tostring(magicId) or tostring(self.m_selMagicId)
        local itemData,itemCfg = game_data:getMagicDataById(selMagicid)
        local temptype = itemCfg.talisman_type
        self.m_ccbNode:nodeForName("attribute_node0"):setVisible(false)
        self.m_ccbNode:nodeForName("attribute_node1"):setVisible(false)
        for k,v in pairs(lab_text["attribute_node" .. temptype]) do
            self.m_ccbNode:nodeForName("attribute_node" .. temptype):setVisible(true)
            local lb = self.m_ccbNode:labelTTFForName(v.old)
            local index = itemCfg["base_" .. v.base] + itemData.lv * itemCfg["growth_" .. v.base]
            if v.base == "dr" or v.base == "crit" or v.base == "hr" then
                index = tostring(index) .. "%"
            end
            lb:setString(index)
        end
        local Cfgtalisman = json.decode(getConfig(game_config_field.talisman):getFormatBuffer()) or {}
        local ccbNode = game_util:createMagicItemByCCB(itemData)
        if ccbNode then
            self.m_anim_node:addChild(ccbNode)
            if Cfgtalisman[itemData.c_id..""].quality >= 5 then
                self.m_forging_btn:setVisible(true)
            else
                self.m_forging_btn:setVisible(false)
            end
        end
        local story = itemCfg["des"]
        story = string.gsub( story, "effect", itemCfg["effect"], 1)
        self.m_detail_lb:setString(story)
    else
        self.m_detail_lb:setString("")
    end
end

--[[--
    创建装备列表
]]
function game_magic_evolution.createMagicTableView(self,viewSize,tableData)
    self.m_selListItem = nil;
    local itemsCount = #tableData;
    local totalItem = math.max(itemsCount%4 == 0 and itemsCount or math.floor(itemsCount/4+1)*4,4)
    local talisman = getConfig(game_config_field.talisman);
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = itemsCount--totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createEquipItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < itemsCount then
                local tempId = tableData[index+1]
                local itemData,itemCfg = game_data:getMagicDataById(tempId);
                local m_name_label = ccbNode:labelTTFForName("m_name_label")
                m_name_label:setString(itemCfg.talisman_name)
                game_util:setMagicItemInfoByTable2(ccbNode,itemData);
                if self.m_selMagicId and self.m_selMagicId == tempId then
                    local m_sel_img = ccbNode:spriteForName("m_sel_img")
                    m_sel_img:setVisible(true);
                    self.m_selListItem = cell;
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= itemsCount then return end;
        if eventType == "ended" and cell then
            local tempId = tableData[index+1]
            if self.m_selMagicId == nil or self.m_selMagicId ~= tempId then
                if self.m_selListItem then
                    local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                    local m_sel_img = ccbNode:spriteForName("m_sel_img")
                    m_sel_img:setVisible(false);
                end
                self.m_selListItem = cell;
                self.m_selMagicId = tostring(tempId)
                self:refreshMagicInfo(self.m_selMagicId);
                self:refreshTips();
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                m_sel_img:setVisible(true);
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
        -- self.m_selListItem = nil;
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新列表
]]
function game_magic_evolution.refreshEquipTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_selMagicDataTab = game_data:getMagicIdTable();

    self.m_tableView = self:createMagicTableView(self.m_list_view_bg:getContentSize(),self.m_selMagicDataTab);
    self.m_list_view_bg:addChild(self.m_tableView);
end


--[[--

]]
function game_magic_evolution.refreshSortTabBtn(self,sortIndex)
    self.m_selSortIndex = sortIndex;
    local tempBtn = nil;
    for i=1,4 do
        tempBtn = self.m_ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
        tempBtn:setHighlighted(self.m_selSortIndex == i);
        tempBtn:setEnabled(self.m_selSortIndex ~= i);
    end
    self:refreshEquipTableView()
end


--[[--
    刷新
]]
function game_magic_evolution.refreshByType(self,showType)
    -- cclog("refreshByType ==============" .. showType);
    self.m_showType = showType;
    if showType == 1 then
        self:refreshSortTabBtn(self.m_selSortIndex);
    elseif showType == 2 then

    end
    self:refreshTips();
end

--[[--
    刷新tips
]]
function game_magic_evolution.refreshTips(self)
    --
    if self.m_selMagicId ~= nil then
        self.m_tips_spr_1:setVisible(false);
    else
        self.m_tips_spr_1:setVisible(true);
    end
    if #self.m_selEquipDataTab == 0 then

    else

    end
    local totalMetal = game_data:getUserStatusDataByKey("metal") or 0
    local lushi_count = game_data:getItemCountByCid(265) or 0
    local value,unit = game_util:formatValueToString(lushi_count);
    self.m_metal_total_label:setString(tostring(value .. unit));
end

--[[--
    刷新
]]
function game_magic_evolution.refreshCombatLabel(self)
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
    刷新ui
]]
function game_magic_evolution.refreshUi(self)
    self:refreshMagicInfo(self.m_selMagicId);
    self:refreshByType(self.m_showType);
    self:refreshCombatLabel();
end
--[[--
    初始化
]]
function game_magic_evolution.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selMagicId = t_params.selEquipId;
    self.m_openType = t_params.openType or "";
    self.myformation = t_params.myformation 
    self.m_showType = 1;
    self.m_curPage = 1;
    self.m_material_node_tab = {};
    self.m_materialDataTable = {};
    self.m_selEquipDataTab = {};
    local selSort = game_data:getEquipSortType();
    for k,v in pairs(EQUIP_SORT_TAB) do
        if v.sortType == selSort then
            self.m_selSortIndex = k;
            break;
        end
    end
    self.m_selSortIndex = self.m_selSortIndex or 1;
    self.daoju_need = 0;
    self.daoju_num = 0;
    self.daoju_total = 0;
end

--[[--
    创建ui入口并初始化数据
]]
function game_magic_evolution.create(self,t_params)
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    local id = game_guide_controller:getIdByTeam("14");
    if id == 1401 then
        game_guide_controller:gameGuide("drama","14",1401)
    end
    game_guide_controller:showEndForceGuide("14")
    return uiNode;
end

return game_magic_evolution;
