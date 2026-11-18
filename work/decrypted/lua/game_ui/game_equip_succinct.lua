--- 装备强化

local equipment_succinct = {
    m_anim_node = nil,--动画节点
    m_selEquipId = nil,--选中的heroid
    m_ok_btn = nil,
    m_canStrengthenFlag = nil,
    m_tips_spr_1 = nil,
    m_list_view_bg = nil,
    m_sel_btn = nil,
    m_showType = nil,
    m_selListItem = nil,
    m_needMoney = nil,
    m_back_btn = nil,
    m_ability1_label = nil,
    m_ability2_label = nil,
    m_ability1_name_label = nil,
    m_ability2_name_label = nil,
    m_curPage = nil,
    m_ccbNode = nil,
    m_anim_node_parent = nil,
    m_root_layer = nil,
    m_selFilterSortType = nil,
    cost_node = nil,
    m_metal_total_label = nil,
    m_selEquipDataTab = nil,
    m_guildNode = nil,
    m_upFlag = nil,
    m_levelUpValue = nil,
    m_cost_metal = nil,
    m_scroll_view_tips = nil,
    m_selSortIndex = nil,
    curr_need_metal = nil,
    m_itemFirstShowFlag = nil,
    m_realLevelUpValue = nil,
    m_openType = nil,
    m_tableView = nil,
    m_combatNumberChangeNode = nil,
    m_tempCombatValue = nil,
    m_quick_ok_btn = nil,
    m_material_node_tab = nil,
    m_material_layer = nil,
    m_bottom_node = nil,

    tips1 = nil,
    tips2 = nil,
    m_button = nil,
    succinct_mode = nil,
    status = nil,
    change_label2 = nil,
    change_label1 = nil,
    changeicon1 = nil,
    changeicon2 = nil,
    lockFlag = nil,
    up_label1 = nil,
    up_label2 = nil,
};

--[[--
    销毁ui
]]
function equipment_succinct.destroy(self)
    -- body
    cclog("-----------------equipment_succinct destroy-----------------");
    self.m_anim_node = nil;
    self.m_selEquipId = nil;
    self.m_ok_btn = nil;
    self.m_canStrengthenFlag = nil;
    self.m_tips_spr_1 = nil;
    self.m_list_view_bg = nil;
    self.m_sel_btn = nil;
    self.m_showType = nil;
    self.m_selListItem = nil;
    self.m_needMoney = nil;
    self.m_back_btn = nil;
    self.m_ability1_label = nil;
    self.m_ability2_label = nil;
    self.m_ability1_name_label = nil;
    self.m_ability2_name_label = nil;
    self.m_curPage = nil;
    self.m_ccbNode = nil;
    self.m_anim_node_parent = nil;
    self.m_root_layer = nil;
    self.m_selFilterSortType = nil;
    self.cost_node = nil;
    self.m_metal_total_label = nil;
    self.m_selEquipDataTab = nil;
    self.m_guildNode = nil;
    self.m_upFlag = nil;
    self.m_levelUpValue = nil;
    self.m_cost_metal = nil;
    self.m_scroll_view_tips = nil;
    self.m_selSortIndex = nil;
    self.curr_need_metal = nil;
    self.m_itemFirstShowFlag = nil;
    self.m_realLevelUpValue = nil;
    self.m_openType = nil;
    self.m_tableView = nil;
    self.m_combatNumberChangeNode = nil;
    self.m_tempCombatValue = nil;
    self.m_quick_ok_btn = nil;
    self.m_material_node_tab = nil;
    self.m_material_layer = nil;
    self.m_bottom_node = nil;

    self.tips1 = nil;
    self.tips2 = nil;
    self.m_button = nil;
    self.succinct_mode = nil;
    self.status = nil;
    self.change_label2 = nil;
    self.change_label1 = nil;
    self.changeicon1 = nil;
    self.changeicon2 = nil;
    self.lockFlag = nil;
    self.up_label1 = nil;
    self.up_label2 = nil;
end

--[[--
    返回
]]
function equipment_succinct.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[
    联网
]]
function equipment_succinct.succinct(self,sort,is_save)
    local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipId);
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        local ability = itemCfg:getNodeWithKey("ability1"):toInt();
        local ability2 = itemCfg:getNodeWithKey("ability2"):toInt();
        local attrTab1 = PUBLIC_ABILITY_TABLE["ability_" .. ability]
        local attrTab2 = PUBLIC_ABILITY_TABLE["ability_" .. ability2]

        local equip_refine = data:getNodeWithKey("equip_refine")
        -- local hp = equip_refine:getNodeWithKey("hp"):toInt()
        -- local patk = equip_refine:getNodeWithKey("patk"):toInt()
        -- local matk = equip_refine:getNodeWithKey("matk"):toInt()
        -- local def = equip_refine:getNodeWithKey("def"):toInt()
        -- local speed = equip_refine:getNodeWithKey("speed"):toInt()
        local value1 = equip_refine:getNodeWithKey(attrTab1.attrName):toInt()
        local value2 = equip_refine:getNodeWithKey(attrTab2.attrName):toInt()
        -- self:setChangeIcon(hp,patk,matk,def,speed)
        self:setChangeIcon(value2,value1)
        if is_save == 1 then--保存的话重置status 刷新
            self.status = 0
            self.lockFlag = false
            self:refreshUi()
            self:refreshBtnStatus()
        end
        local refine_stone = game_data:getUserStatusDataByKey("refine_stone") or 0
        self.m_metal_total_label:setString(tostring(refine_stone));
        -- cclog2(json.decode(gameData:getFormatBuffer()),"gameData")
    end
    local params = {}
    params.equip_id = self.m_selEquipId
    params.sort = sort
    params.type = self.succinct_mode
    params.is_save = is_save
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_equip_refine"), http_request_method.GET, params,"equip_equip_refine")
end
--[[
    button status
]]
function equipment_succinct.refreshBtnStatus(self)
    if self.status == 0 then
        game_util:setCCControlButtonTitle(self.m_button[1],"Tẩy luyện 1 lần")
        game_util:setCCControlButtonTitle(self.m_button[2],"Tẩy luyện 5 lần")
        game_util:setCCControlButtonTitle(self.m_button[3],"Tẩy luyện nhanh")
    else
        game_util:setCCControlButtonTitle(self.m_button[2],"Tẩy luyện" .. self.status .. " lần")
        game_util:setCCControlButtonTitle(self.m_button[1],"Hủy")
        game_util:setCCControlButtonTitle(self.m_button[3],"Đổi")
    end
end
--[[--
    读取ccbi创建ui
]]
function equipment_succinct.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag >= 500 and btnTag <= 510 then--
            if self.m_selEquipId == nil then
                game_util:addMoveTips({text = "Chọn trang bị cần tẩy luyện!"})
                return
            end
            local index = btnTag - 500
            if self.status == 0 then--选择洗练几次拉
                if index == 10 then
                    self:quickSuccinct()
                else
                    self:succinct(index,0)
                    self.status = index
                end
            else--已经开始洗练了，选择放弃还是保存啦
                if index == 10 then--保存
                    self:succinct(self.status,1)
                elseif index == 5 then--继续洗练
                    self:succinct(self.status,0)
                else--放弃
                    local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            self.status = 0
                            self.lockFlag = false
                            self:setChangeIcon(0,0,0,0,0)
                            self:refreshBtnStatus()
                            self:refreshUi()
                            game_util:closeAlertView();
                        end,   --可缺省
                        okBtnText = string_config.m_btn_sure,       --可缺省
                        text = "Chưa lưu thuộc tính tẩy luyện lần này, hủy chứ?",      --可缺省
                        onlyOneBtn = false,
                    }
                    game_util:openAlertView(t_params);
                end
            end
            self:refreshBtnStatus()
        -- elseif btnTag == 510 then--洗练10次改为一键洗练
        --     self:quickSuccinct()
        elseif btnTag >= 104 and btnTag <= 106 then--select succinct mode
            local index = btnTag - 100
            for i=4,6 do
                game_util:setCCControlButtonBackground(self.m_button[i],"succinct_noselect.png")
            end
            game_util:setCCControlButtonBackground(self.m_button[index],"succinct_selected.png")
            self.succinct_mode = index - 3
            self:refreshTips()
        elseif btnTag >= 201 and btnTag <= 204 then--排序
            cclog("btnCallBack ===========btnTag===" .. btnTag)
            local selSort = tostring(EQUIP_SORT_TAB[btnTag-200].sortType);
            -- game_data:equipSortByTypeName(selSort)
            game_data:equipSortByTypeName(selSort,self.m_selEquipDataTab)
            self:refreshSortTabBtn(btnTag-200);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_equipment_succinct.ccbi");

    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    
    --英雄相关
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_ability1_label = ccbNode:labelTTFForName("m_ability1_label")
    self.m_ability2_label = ccbNode:labelTTFForName("m_ability2_label")
    self.m_ability1_name_label = ccbNode:labelTTFForName("m_ability1_name_label")
    self.m_ability2_name_label = ccbNode:labelTTFForName("m_ability2_name_label")
    self.m_anim_node_parent = ccbNode:nodeForName("m_anim_node_parent")
    self.cost_node = ccbNode:labelBMFontForName("cost_node")
    self.m_metal_total_label = ccbNode:labelBMFontForName("m_metal_total_label")

    self.change_label2 = ccbNode:labelTTFForName("change_label2")
    self.change_label1 = ccbNode:labelTTFForName("change_label1")
    self.changeicon1 = ccbNode:spriteForName("changeicon1")
    self.changeicon2 = ccbNode:spriteForName("changeicon2")

    self.change_label2:setVisible(false)
    self.change_label1:setVisible(false)
    self.changeicon1:setVisible(false)
    self.changeicon2:setVisible(false)

    self.tips1 = ccbNode:labelTTFForName("tips1")
    self.tips2 = ccbNode:labelTTFForName("tips2")
    self.up_label1 = ccbNode:labelTTFForName("up_label1")
    self.up_label2 = ccbNode:labelTTFForName("up_label2")
    self.tips1:setString("")
    self.tips2:setString("")

    self.m_button = {}
    for i=1,6 do
        self.m_button[i] = ccbNode:controlButtonForName("m_button" .. i)
    end
    game_util:setCCControlButtonBackground(self.m_button[4],"succinct_selected.png")

    self.m_ccbNode = ccbNode
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    self.m_root_layer:setTouchEnabled(false);
    local m_combat_node = ccbNode:nodeForName("m_combat_node");
    self.m_combatNumberChangeNode = game_util:createExtNumberChangeNode({labelType = 2});
    self.m_combatNumberChangeNode:setAnchorPoint(ccp(0, 0.5));
    m_combat_node:addChild(self.m_combatNumberChangeNode);
    self.m_combatNumberChangeNode:setCurValue(0,false);

    return ccbNode;
end
--[[
    快速洗练
]]
function equipment_succinct.quickSuccinct(self)
    if self.m_selEquipId == nil then
        game_util:addMoveTips({text = "Chọn trang bị cần tẩy luyện!"})
        return
    end
    local function responseMethod(tag,gameData)
        local function responseMethod2(tag,gameData)
            game_util:addMoveTips({text = "Đã tẩy luyện nhanh!"});
            game_util:closeAlertView();
            self:refreshUi()
        end

        local data = gameData:getNodeWithKey("data")
        local can_refine_info = data:getNodeWithKey("can_refine_info")
        local max_refine_info = data:getNodeWithKey("max_refine_info")
        local can_times = can_refine_info:getNodeWithKey("need_times"):toInt()
        local max_times = max_refine_info:getNodeWithKey("need_times"):toInt()
        if can_times == max_times then--可直接升满
            local refine_stone_need = max_refine_info:getNodeWithKey("refine_stone_need"):toInt()
            local coin_need = (max_refine_info:getNodeWithKey("coin_need") and max_refine_info:getNodeWithKey("coin_need"):toInt()) or 0
            local metal_need = (max_refine_info:getNodeWithKey("metal_need") and max_refine_info:getNodeWithKey("metal_need"):toInt()) or 0
            local text = "Trang bị sẽ tẩy luyện max, nếu tiêu hao Đá Tẩy Luyện *" .. refine_stone_need
            if coin_need > 0 then
                text = text .. "，Xu *" .. coin_need
            end
            if metal_need > 0 then
                text = text .. "，Sắt *" .. metal_need
            end
            
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    network.sendHttpRequest(responseMethod2,game_url.getUrlForKey("equip_auto_refine"), http_request_method.GET, {equip_id=self.m_selEquipId,is_buy=1,handle_sort=1,type=self.succinct_mode},"equip_auto_refine")
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = text,      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            game_util:openAlertView(t_params)
        elseif can_times < max_times then--需要花费钻石
            local can_stone_need = can_refine_info:getNodeWithKey("refine_stone_need"):toInt()
            local can_metal = (can_refine_info:getNodeWithKey("metal_need") and can_refine_info:getNodeWithKey("metal_need"):toInt()) or 0
            local text = "Hiện tại tẩy luyện được " .. can_times .. "lần"
            if can_times == 0 then
                can_stone_need = 0
            end
            if can_stone_need > 0 then
                text = text .. "， tiêu hao Đá Tẩy Luyện*" .. can_stone_need
            end
            if can_metal > 0 then
                text = text .. "， Sắt*" .. can_metal
            end
            local can_coin = (can_refine_info:getNodeWithKey("coin_need") and can_refine_info:getNodeWithKey("coin_need"):toInt()) or 0
            if can_coin > 0 then
                text = text .. "， Xu*" .. can_coin
            end

            local max_coin_cost = (max_refine_info:getNodeWithKey("coin_need") and max_refine_info:getNodeWithKey("coin_need"):toInt()) or 0
            local max_metal_cost = (max_refine_info:getNodeWithKey("metal_cost") and max_refine_info:getNodeWithKey("metal_cost"):toInt()) or 0
            local max_sthone_cost = (max_refine_info:getNodeWithKey("refine_stone_cost") and max_refine_info:getNodeWithKey("refine_stone_cost"):toInt()) or 0
            local total_cost = max_coin_cost + max_metal_cost + max_sthone_cost
            text = text .. "，Tốn thêm " .. total_cost .. "Xu để tẩy luyện max?"
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)--最大上限
                    network.sendHttpRequest(responseMethod2,game_url.getUrlForKey("equip_auto_refine"), http_request_method.GET, {equip_id=self.m_selEquipId,is_buy=1,handle_sort=1,type=self.succinct_mode},"equip_auto_refine")
                end,   --可缺省
                extCallBack = function(target,event)--当前上限
                    network.sendHttpRequest(responseMethod2,game_url.getUrlForKey("equip_auto_refine"), http_request_method.GET, {equip_id=self.m_selEquipId,is_buy=1,handle_sort=2,type=self.succinct_mode},"equip_auto_refine")
                end,
                okBtnText = "Đã đạt max",       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                extBtnText = "Đạt max hiện tại",
                btnUseTTF = true,
                text = text,--可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            game_util:openAlertView(t_params)
        end
        
    end
    local params = {}
    params.equip_id = self.m_selEquipId
    params.type = self.succinct_mode
    params.handle_sort = 1
    params.is_buy = 0
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_auto_refine"), http_request_method.GET, params,"equip_auto_refine")
end
--[[--
    装备属性信息
]]
function equipment_succinct.refreshEquipInfo(self,equipId,addLvFlag)
    self.m_selEquipId = equipId;
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    if equipId ~= nil and equipId ~= "-1" then
        local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipId);
        local quality = itemCfg:getNodeWithKey("quality"):toStr();
        local equip_strongthen = getConfig(game_config_field.equip_strongthen);
        local level = itemData.lv
        local errorFlag = false;

        local function setValueFunc()
            local tempLv = level
            local attrName1,value1,attrName2,value2,icon1,icon2,aName,bName = game_util:getEquipAttributeValue(itemCfg,tempLv,itemData);
            self.m_ability1_name_label:setString(attrName1);
            self.m_ability2_name_label:setString(attrName2);

            local temp1 = 0
            local temp2 = 0
            if itemData.equip_refine then
                if itemData.equip_refine[aName] then
                    temp1 = itemData.equip_refine[aName]
                end
                if itemData.equip_refine[bName] then
                    temp2 = itemData.equip_refine[bName]
                end
            end
            self.m_ability1_label:setString(temp1);
            self.m_ability2_label:setString(temp2);

            local refine_id = itemCfg:getNodeWithKey("refine_id"):toInt()
            local equip_refine = getConfig(game_config_field.equip_refine)
            local extra_discrip_1 = equip_refine:getNodeWithKey(tostring(refine_id)):getNodeWithKey("extra_discrip_1"):toStr()
            local extra_discrip_2 = equip_refine:getNodeWithKey(tostring(refine_id)):getNodeWithKey("extra_discrip_2"):toStr()

            local refine_control_1 = equip_refine:getNodeWithKey(tostring(refine_id)):getNodeWithKey("refine_control_1"):getNodeAt(1):toInt()
            local refine_control_2 = equip_refine:getNodeWithKey(tostring(refine_id)):getNodeWithKey("refine_control_2"):getNodeAt(1):toInt()
            self.up_label1:setString(refine_control_2)
            self.up_label2:setString(refine_control_1)

            local extra_break_1 = nil
            local extra_break_2 = nil
            if itemData.equip_refine then
                extra_break_1 = itemData.equip_refine.extra_break_1
                extra_break_2 = itemData.equip_refine.extra_break_2
            end
            -- extra_break_1 extra_break_2 颠倒一下
            -- if extra_break_1 == true then
            --     self.tips1:setColor(ccc3(10,230,10))
            -- else
            --     self.tips1:setColor(ccc3(200,200,200))
            --     extra_discrip_1 = extra_discrip_1 .. "（未激活）"
            -- end
            -- if extra_break_2 == true then
            --     self.tips2:setColor(ccc3(10,230,10))
            -- else
            --     self.tips2:setColor(ccc3(200,200,200))
            --     extra_discrip_2 = extra_discrip_2 .. "（未激活）"
            -- end
            -- self.tips1:setString(extra_discrip_1)
            -- self.tips2:setString(extra_discrip_2)

            if extra_break_1 == true then
                self.tips2:setColor(ccc3(10,230,10))
            else
                self.tips2:setColor(ccc3(200,200,200))
                extra_discrip_1 = extra_discrip_1 .. "\n(Chưa kích hoạt)"
            end
            if extra_break_2 == true then
                self.tips1:setColor(ccc3(10,230,10))
            else
                self.tips1:setColor(ccc3(200,200,200))
                extra_discrip_2 = extra_discrip_2 .. "\n(Chưa kích hoạt)"
            end
            self.tips1:setString(extra_discrip_2)
            self.tips2:setString(extra_discrip_1)

            local tempItemData = util.table_copy(itemData)
            local attrName12,value12,attrName22,value22 = game_util:getEquipAttributeValue(itemCfg,level,tempItemData);
            tempItemData.lv = tempLv;
            local ccbNode = game_util:createEquipItemByCCB(tempItemData);
            self.m_anim_node:addChild(ccbNode,10,10);
        end
        setValueFunc();
        self.m_tips_spr_1:setVisible(false);
    else
        self.m_tips_spr_1:setVisible(true);
    end
    self:refreshTips();
end

--[[--
    创建装备列表
]]
function equipment_succinct.createEquipTableView(self,viewSize,tableData)
    self.m_selListItem = nil;
    local itemsCount = #tableData;
    local totalItem = math.max(itemsCount%4 == 0 and itemsCount or math.floor(itemsCount/4+1)*4,4)
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
                local itemData,itemCfg = game_data:getEquipDataById(tempId);
                game_util:setEquipItemInfoByTable2(ccbNode,itemData);
                if self.m_selEquipId and self.m_selEquipId == tempId then
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
            if self.status > 0 then
                game_util:addMoveTips({text = "Chưa lưu thuộc tính tẩy luyện!"})
            else
                if self.m_selEquipId == nil or self.m_selEquipId ~= tempId then
                    self.m_levelUpValue = 0;
                    if self.m_selListItem then
                        local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                        local m_sel_img = ccbNode:spriteForName("m_sel_img")
                        m_sel_img:setVisible(false);
                    end
                    self.m_selListItem = cell;
                    self.m_selEquipId = tempId
                    self.m_upFlag = false;
                    self.lockFlag = true;
                    self:refreshEquipInfo(self.m_selEquipId);
                    self:refreshByType(2);
                    local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                    local m_sel_img = ccbNode:spriteForName("m_sel_img")
                    m_sel_img:setVisible(true);
                end
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
        -- self.m_selListItem = nil;
    end
    local tempTableView = TableViewHelper:create(params);
    return tempTableView
end

--[[--
    刷新列表
]]
function equipment_succinct.refreshEquipTableView(self)
    local pX,pY;
    if self.m_tableView then
        pX,pY = self.m_tableView:getContainer():getPosition();
    end
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    -- self.m_selEquipDataTab = game_data:getEquipIdTable();
    local tempTable = game_data:getEquipIdTable();
    self.m_selEquipDataTab = {}--每次刷新需要重置一下table表
    --排除不能洗练的装备
    for i=1,#tempTable do
        local equipId = tempTable[i]
        local itemData,itemCfg = game_data:getEquipDataById(equipId);
        local refine_id = itemCfg:getNodeWithKey("refine_id"):toInt()
        if refine_id > 0 then
            table.insert( self.m_selEquipDataTab, equipId )
        end
    end
    self.m_tableView = self:createEquipTableView(self.m_list_view_bg:getContentSize(),self.m_selEquipDataTab);
    self.m_list_view_bg:addChild(self.m_tableView);
    if pX and pY then
        self.m_tableView:setContentOffset(ccp(pX,pY), false);
    end
end

--[[--

]]
function equipment_succinct.refreshSortTabBtn(self,sortIndex)
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
function equipment_succinct.refreshByType(self,showType)
    cclog("refreshByType ==============" .. showType);
    self.m_showType = showType;

    if #self.m_selEquipDataTab == 0 then

    else

    end
    self:refreshTips();
end

--[[--
    刷新tips
]]
function equipment_succinct.refreshTips(self)
    local refine_stone = game_data:getUserStatusDataByKey("refine_stone") or 0
    self.m_metal_total_label:setString(tostring(refine_stone));

    local need_stone = 0
    if self.m_selEquipId then
        local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipId);
        local refine_id = itemCfg:getNodeWithKey("refine_id"):toInt()
        local equip_refine = getConfig(game_config_field.equip_refine)

        local refine_cost = nil
        if self.succinct_mode == 1 then
            refine_cost = equip_refine:getNodeWithKey(tostring(refine_id)):getNodeWithKey("refine_min_cost")
        elseif self.succinct_mode == 2 then
            refine_cost = equip_refine:getNodeWithKey(tostring(refine_id)):getNodeWithKey("refine_mid_cost")
        elseif self.succinct_mode == 3 then
            refine_cost = equip_refine:getNodeWithKey(tostring(refine_id)):getNodeWithKey("refine_max_cost")
        end
        self.cost_node:removeAllChildrenWithCleanup(true)
        local labelPos = {
            {ccp(25,13)},
            {ccp(10,13),ccp(70,13)}
        }
        local iconPos = {
            {ccp(50,13)},
            {ccp(30,13),ccp(90,13)}   
        }
        for i=1,refine_cost:getNodeCount() do
            local costOdd = refine_cost:getNodeAt(i-1)
            local rewardType = costOdd:getNodeAt(0):toInt()
            local count = costOdd:getNodeAt(2):toInt()
            local label = game_util:createLabelTTF({text = count,fontSize = 10})
            local icon = nil
            local currentValue = 0
            if rewardType == 23 then--洗练石
                currentValue = game_data:getUserStatusDataByKey("refine_stone") or 0
                icon = CCSprite:createWithSpriteFrameName("public_icon_succinct.png")
            elseif rewardType == 9 then--钻石
                currentValue = game_data:getUserStatusDataByKey("coin") or 0
                icon = CCSprite:createWithSpriteFrameName("public_icon_gold.png")
            elseif rewardType == 2 then--金属
                currentValue = game_data:getUserStatusDataByKey("metal") or 0
                icon = CCSprite:createWithSpriteFrameName("public_icon_metal.png")
            end
            self.cost_node:addChild(icon)
            self.cost_node:addChild(label)
            if count == 0 then
                label:setColor(ccc3(0,255,0))
            elseif count > currentValue then
                label:setColor(ccc3(255,0,0))
            else
                label:setColor(ccc3(0,255,0))
            end

            label:setPosition(labelPos[refine_cost:getNodeCount()][i])
            icon:setPosition(iconPos[refine_cost:getNodeCount()][i])
        end
    end
end
--[[--
    刷新
]]
function equipment_succinct.refreshCombatLabel(self)
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
function equipment_succinct.setChangeIcon(self,hp,value2)
    local node = CCNode:create()
    if hp > 0 then
        self.changeicon1:setVisible(true)
        self.changeicon1:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("succinct_up.png"))
        self.change_label1:setString(hp)
        self.change_label1:setVisible(true)
        self.change_label1:setColor(ccc3(133,228,78))
    elseif hp < 0 then
        self.changeicon1:setVisible(true)
        self.changeicon1:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("succinct_down.png"))
        self.change_label1:setString(-hp)
        self.change_label1:setVisible(true)
        self.change_label1:setColor(ccc3(198,15,18))
    else
        self.changeicon1:setVisible(false)
        self.change_label1:setVisible(false)
    end
    local tempvalue2 = value2 or 0
    if tempvalue2 > 0 then
        self.changeicon2:setVisible(true)
        self.changeicon2:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("succinct_up.png"))
        self.change_label2:setString(tempvalue2)
        self.change_label2:setVisible(true)
        self.change_label2:setColor(ccc3(133,228,78))
    elseif tempvalue2 < 0 then
        self.changeicon2:setVisible(true)
        self.changeicon2:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("succinct_down.png"))
        self.change_label2:setString(-tempvalue2)
        self.change_label2:setVisible(true)
        self.change_label2:setColor(ccc3(198,15,18))
    else
        self.change_label2:setVisible(false)
        self.changeicon2:setVisible(false)
    end
end
--[[--
    刷新ui
]]
function equipment_succinct.refreshUi(self)
    self:refreshEquipInfo(self.m_selEquipId);
    self:refreshSortTabBtn(self.m_selSortIndex);
    self:refreshByType(self.m_showType);
    self:refreshCombatLabel();
end
--[[--
    初始化
]]
function equipment_succinct.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selEquipId = t_params.selEquipId
    self.m_showType = 1;
    self.m_needMoney = 0;
    self.m_curPage = 1;
    self.m_selFilterSortType = "";
    self.m_selEquipDataTab = {};
    self.m_upFlag = false;
    self.m_levelUpValue = 0;
    self.m_cost_metal = 0;
    local selSort = game_data:getEquipSortType();
    for k,v in pairs(EQUIP_SORT_TAB) do
        if v.sortType == selSort then
            self.m_selSortIndex = k;
            break;
        end
    end
    self.m_selSortIndex = self.m_selSortIndex or 1;
    self.curr_need_metal = 0;
    self.m_itemFirstShowFlag = true;
    self.m_openType = t_params.openType or "";
    self.m_material_node_tab = {};
    self.succinct_mode = 1
    self.status = 0
    self.lockFlag = false
end

--[[--
    创建ui入口并初始化数据
]]
function equipment_succinct.create(self,t_params)
    
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end


return equipment_succinct;
