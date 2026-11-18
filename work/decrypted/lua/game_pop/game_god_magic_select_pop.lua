--- 弹框选择

local game_god_magic_select_pop = {
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
};
--[[--
    销毁ui
]]
function game_god_magic_select_pop.destroy(self)
    -- body
    cclog("-----------------game_god_magic_select_pop destroy-----------------");
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
end

--[[--
    返回
]]
function game_god_magic_select_pop.back(self,type)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_data:resetNewEquipIdTab();
    game_scene:removePopByName("game_god_magic_select_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_god_magic_select_pop.createUi(self)
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
                self:refreshMagicTableView(selSort);
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
    self.m_title_label:setString("装备列表")
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 101);
    self.m_sort_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 101);
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
function game_god_magic_select_pop.createEquipTableView(self,viewSize,tableData)
    local itemsCount = #tableData
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-102;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createMagicItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < itemsCount then
                m_spr_bg_up:setVisible(false);
                local itemData,itemCfg = game_data:getMagicDataById(tableData[index+1]);
                self:setMagicItemInfoByTable(ccbNode,itemData);
                local m_team_img = ccbNode:spriteForName("m_team_img")
                if not m_team_img:isVisible() then
                    -- local id = game_guide_controller:getCurrentId();
                    -- if id == 32 and self.m_guildNode == nil then
                    --     cell:setContentSize(itemSize);
                    --     self.m_guildNode = cell;
                    -- end
                end
            else
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
        	cclog("index -- " .. index .. "     id     " .. tableData[index])
            local itemData,itemCfg = game_data:getMagicDataById(tableData[index+1]);
            if self.m_itemOnClick then
                self.m_itemOnClick(tableData[index+1]);
                self:back();
            end
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    创建装备列表
]]
function game_god_magic_select_pop.createEquipTableView2(self,viewSize,tableData)
    cclog("game_god_magic_select_pop json.encode(tableData) == " .. json.encode(tableData))
    local itemsCount = #tableData + 1;
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-102;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createMagicItemByCCB();
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
                    local itemData,itemCfg = game_data:getMagicDataById(tableData[index]);
                    self:setMagicItemInfoByTable(ccbNode,itemData);
                    local m_team_img = ccbNode:spriteForName("m_team_img")
                    if not m_team_img:isVisible() then
                        -- local id = game_guide_controller:getCurrentId();
                        -- if id == 32 and self.m_guildNode == nil then
                        --     cell:setContentSize(itemSize);
                        --     self.m_guildNode = cell;
                        -- end
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
        -- cclog("index -- " .. index .. "     id     " .. tableData[index])
            if index == 0 then
                self.m_itemOnClick("unload",nil);
                self:back();
            else
                -- if game_data.getGuideProcess and game_data:getGuideProcess() == "guide_second" then
                --     if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(50) end -- 新手引导33步 步骤50
                -- end
                local itemData,itemCfg = game_data:getMagicDataById(tableData[index]);
                -- local existFlag,_ = game_data:magicInMagicPos(itemCfg:getNodeWithKey("talisman_type"):toInt(),itemData.id)
                -- cclog2(existFlag,"existFlag ==== ")
                if self.m_itemOnClick and itemData then
                    if existFlag and self.m_openType == 3 then
                        game_util:addMoveTips({text = "Trang bị đã ra trận"})
                    else
                        self.m_itemOnClick("exchanged",tableData[index]);
                    end
                end
            end
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新列表
]]
function game_god_magic_select_pop.refreshMagicTableView(self,sort)
    self.m_selSort = sort;
    if self.m_tableView ~= nil then
        self.m_tableView:removeFromParentAndCleanup(true);
    end
    local magicData = game_data:getMagicDataByMagicType(self.m_selSort);   
    if self.m_openType == 2 or self.m_openType == 3 then 
        self.m_tableView = self:createEquipTableView2(self.m_list_view_bg:getContentSize(),magicData);
    else
        self.m_tableView = self:createEquipTableView(self.m_list_view_bg:getContentSize(),magicData);
    end
    self.m_list_view_bg:addChild(self.m_tableView);
    local id = game_guide_controller:getCurrentId();
    if id == 32 then
        self.m_tableView:setTouchEnabled(false);
    end
    local typeName = MAGIC_TYPE_NAME_TABLE["type_" .. self.m_selSort]
    if typeName then
        self.m_title_label:setString(typeName .. "列表")
    end
end



function game_god_magic_select_pop.createMagicItemByCCB(self,itemData)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_equip_list_item.ccbi");
    ccbNode:setAnchorPoint(ccp(0.5,0.5));
    if ccbNode ~= nil and itemData ~= nil then
        self:setEquipItemInfoByTable(ccbNode,itemData);
    end
    return ccbNode
end

function game_god_magic_select_pop.setMagicItemInfoByTable(self,ccbNode,itemData)
    if ccbNode == nil or itemData == nil then return end
    ccbNode:nodeForName("m_info_node"):setVisible(true);
    local magicCfg = getConfig(game_config_field.talisman);
    local itemCfg = magicCfg:getNodeWithKey(itemData.c_id);
    local level = itemData.lv;
    local attTable = game_util:getMagicAbilityValue(itemCfg,level,itemData);
    for k,v in pairs(attTable) do
        ccbNode:spriteForName(v.sp):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(v.icon));
        ccbNode:labelBMFontForName(v.lb):setString(v.value)
    end

    local talisman_type = itemCfg:getNodeWithKey("talisman_type"):toInt();
    ccbNode:spriteForName("m_type_icon"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(PUBLIC_MAGIC_ABILITY_TABLE["ability_" .. talisman_type].icon))
    local quality = itemCfg:getNodeWithKey("quality"):toInt()+1;
    if quality > 0 and quality < 10 then
        ccbNode:spriteForName("m_spr_bg"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(HERO_QUALITY_COLOR_TABLE[quality].card_img)); 
    end
    --装备名称加等级
    local m_name_label = ccbNode:labelTTFForName("m_name_label");
    m_name_label:setString(itemCfg:getNodeWithKey("talisman_name"):toStr() .. "+" .. level);
    -- game_util:setEquipNameColorByQuality(m_name_label,itemCfg);

    ccbNode:spriteForName("m_sel_img"):setVisible(false);
    local m_team_img = ccbNode:spriteForName("m_team_img")
    -- local m_team_name = ccbNode:labelBMFontForName("m_team_name")
    local m_team_name = ccbNode:labelTTFForName("m_team_name")
    --所属英雄
    local existFlag,cardName = self:magicInMagicPos(itemCfg:getNodeWithKey("talisman_type"):toInt(),itemData.id)


    if existFlag then
        m_team_img:setVisible(true);
        m_team_name:setString(cardName);
    else
        m_team_img:setVisible(false);
        m_team_name:setString("");
    end
    local m_anim_node = ccbNode:nodeForName("m_anim_node")
    m_anim_node:removeAllChildrenWithCleanup(true);
    local icon = game_util:createIconByName(itemCfg:getNodeWithKey("image"):toStr()) --self:createEquipIcon(itemCfg)
    if icon then
        m_anim_node:addChild(icon)
    end
    --英雄星级
    local refining_node = ccbNode:nodeForName("refining_node")
    local refining_level = ccbNode:labelBMFontForName("refining_level")
    local string = itemCfg:getNodeWithKey("star"):toStr()
    if string ~= "0" then
        refining_level:setString(string)
        refining_node:setVisible(true)
    else
        refining_node:setVisible(false)
    end
    --装备锻造等级
    ccbNode:nodeForName("forge_node"):setPosition(ccp(18,116))
    ccbNode:spriteForName("m_sprite_ming"):setVisible(false)
end



--[[--
    判断是否装备上
]]
function game_god_magic_select_pop.magicInMagicPos(self,Type,Id)
    Id = tostring(Id);
    local existFlag = false;
    local cardName = "";
    local posData = nil;
    local m_tMagicPosData1 = self.m_MagicPosDataTab[1];
    local m_tMagicPosData2 = self.m_MagicPosDataTab[2];
    local m_tMagicPosData3 = self.m_MagicPosDataTab[3];
    if Type then
        for i=1,10 do
            if Type == 1 or  Type == "1" then
                if tostring(m_tMagicPosData1[tostring(i-1)][1]) == Id or tostring(m_tMagicPosData1[tostring(i-1)][2]) == Id then
                    existFlag = true;
                    posData = m_tMagicPosData1[tostring(i-1)]
                    local tempTeamD = self.m_tempTeamData[1]
                    local _,itemCfg = nil, nil;
                    local cardId = tempTeamD[i];
                    if cardId and cardId ~= "-1" then
                        _,itemCfg = game_data:getCardDataById(cardId);
                    end
                    if itemCfg then
                        cardName = itemCfg:getNodeWithKey("name"):toStr() .. "\nĐội hình 1，chỗ" .. i;
                    else
                        cardName = "Đội hình 1\n" .. i .. "chỗ"
                    end
                    break;
                elseif tostring(m_tMagicPosData2[tostring(i-1)][1]) == Id or tostring(m_tMagicPosData2[tostring(i-1)][2]) == Id then
                    existFlag = true;
                    posData = m_tMagicPosData1[tostring(i-1)]
                    local tempTeamD = self.m_tempTeamData[2]
                    local _,itemCfg = nil, nil;
                    local cardId = tempTeamD[i];
                    if cardId and cardId ~= "-1" then
                        _,itemCfg = game_data:getCardDataById(cardId);
                    end
                    if itemCfg then
                        cardName = itemCfg:getNodeWithKey("name"):toStr() .. "\nĐội hình 3，chỗ" .. i;
                    else
                        cardName = "Đội hình 3\n" .. i .. "chỗ"
                    end
                    break; 
                elseif tostring(m_tMagicPosData3[tostring(i-1)][1]) == Id or tostring(m_tMagicPosData3[tostring(i-1)][2]) == Id then
                    existFlag = true;
                    posData = m_tMagicPosData1[tostring(i-1)]
                    local tempTeamD = self.m_tempTeamData[3]
                    local _,itemCfg = nil, nil;
                    local cardId = tempTeamD[i];
                    if cardId and cardId ~= "-1" then
                        _,itemCfg = game_data:getCardDataById(cardId);
                    end
                    if itemCfg then
                        cardName = itemCfg:getNodeWithKey("name"):toStr() .. "\nĐội hình 3，chỗ" .. i;
                    else
                        cardName = "Đội hình 3\n" .. i .. "chỗ"
                    end
                    break; 
                end
            elseif Type == 0 or Type == "0" then
                if tostring(m_tMagicPosData1[tostring(i-1)][3]) == Id or tostring(m_tMagicPosData1[tostring(i-1)][4]) == Id then
                    existFlag = true;
                    posData = m_tMagicPosData1[tostring(i-1)]
                    local tempTeamD = self.m_tempTeamData[1]
                    local _,itemCfg = nil, nil;
                    local cardId = tempTeamD[i];
                    if cardId and cardId ~= "-1" then
                        _,itemCfg = game_data:getCardDataById(cardId);
                    end
                    if itemCfg then
                        cardName = itemCfg:getNodeWithKey("name"):toStr() .. "\nĐội hình 1，chỗ" .. i .. " ";
                    else
                        cardName = "Đội hình 1\n" .. i .. "chỗ"
                    end
                    break;
                elseif tostring(m_tMagicPosData2[tostring(i-1)][3]) == Id or tostring(m_tMagicPosData2[tostring(i-1)][4]) == Id then
                    existFlag = true;
                    posData = m_tMagicPosData1[tostring(i-1)]
                    local tempTeamD = self.m_tempTeamData[2]
                    local _,itemCfg = nil, nil;
                    local cardId = tempTeamD[i];
                    if cardId and cardId ~= "-1" then
                        _,itemCfg = game_data:getCardDataById(cardId);
                    end
                    if itemCfg then
                        cardName = itemCfg:getNodeWithKey("name"):toStr() .. "\nĐội hình 2，chỗ" .. i .. " ";
                    else
                        cardName = "Đội hình 2\n" .. i .. "chỗ"
                    end
                    break; 
                elseif tostring(m_tMagicPosData3[tostring(i-1)][3]) == Id or tostring(m_tMagicPosData3[tostring(i-1)][4]) == Id then
                    existFlag = true;
                    posData = m_tMagicPosData1[tostring(i-1)]
                    local tempTeamD = self.m_tempTeamData[3]
                    local _,itemCfg = nil, nil;
                    local cardId = tempTeamD[i];
                    if cardId and cardId ~= "-1" then
                        _,itemCfg = game_data:getCardDataById(cardId);
                    end
                    if itemCfg then
                        cardName = itemCfg:getNodeWithKey("name"):toStr() .. "\nĐội hình 3，chỗ" .. i .. " ";
                    else
                        cardName = "Đội hình 3\n" .. i .. "chỗ"
                    end
                    break; 
                end
            end
        end
    end
    return existFlag,cardName,posData
end



--[[--
    刷新ui
]]
function game_god_magic_select_pop.refreshUi(self)
    self:refreshMagicTableView(self.m_selSort);
    self.m_sort_btn:setVisible(self.m_sortBtnShow);
end
--[[--
    初始化
]]
function game_god_magic_select_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_posIndex = t_params.posIndex;
    self.m_selSort = t_params.selSort or "-1";
    self.m_openType = t_params.openType or 1;
    self.m_btnCallFunc = t_params.btnCallFunc;
    self.m_itemOnClick = t_params.itemOnClick;
    self.m_sortBtnShow = t_params.sortBtnShow or false;


    self.m_tempTeamData = t_params.m_tempTeamData;

    self.m_btn_index =t_params.m_btn_index;
    self.m_MagicPosDataTab = t_params.m_MagicPosDataTab;

end

--[[--
    创建ui入口并初始化数据
]]
function game_god_magic_select_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    -- local id = game_guide_controller:getCurrentId();
    -- if self.m_guildNode and id == 32 then
    --     game_guide_controller:gameGuide("show","2",33,{tempNode = self.m_guildNode})
    -- end
    return self.m_popUi;
end

return game_god_magic_select_pop;