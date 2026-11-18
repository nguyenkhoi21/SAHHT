
--- 装备进化
local game_equip_build_lvup = {
    m_anim_node = nil,--动画节点
    m_selEquipId = nil,--选中的heroid
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
    m_sel_metail = {},
    m_enterType = nil,
};
--[[--
    销毁ui
]]
function game_equip_build_lvup.destroy(self)
    -- body
    cclog("-----------------game_equip_build_lvup destroy-----------------");
    self.m_anim_node = nil;
    self.m_selEquipId = nil;
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
    self.m_sel_metail = {};
    self.m_enterType = nil;
end

--[[--
    返回
]]
function game_equip_build_lvup.back(self,backType)
    if backType == "back" then
        if self.m_enterType == "game_equip_build_main" then
            game_scene:enterGameUi("game_equip_build_main",{gameData = gameData});
        elseif self.m_enterType == "game_equip_build_old_main" then
            game_scene:enterGameUi("game_equip_build_old_main")
        else
            local function endCallFunc()
                self:destroy();
            end
            game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
        end
    end
end
--[[--
    读取ccbi创建ui
]]
function game_equip_build_lvup.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 102 then--开始进阶
        	if not self.m_selEquipId then
        		game_util:addMoveTips({text = "Hãy chọn trang bị cần chế tạo"})
        		return
        	end
            local params = {}
            function responseMethod(tag,gameData)
                if gameData then
                    local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                    if data.is_success == true then
                        game_util:addMoveTips({text = "Chúc mừng bạn, đã chế tạo trang bị thành công!"})
                    elseif data.is_success == false then
                        if data.is_low == true then
                            game_util:addMoveTips({text = "Lần này chế tạo thất bại, level chế tạo giảm còn LV" .. data.build_lv .. ",tiếp tục nỗ lực!"})
                        else
                            game_util:addMoveTips({text = "Lần này chế tạo thất bại, tiếp tục nỗ lực!"})
                        end
                    end
                    self.m_sel_metail = {}
                    self.m_list_tab = nil
                    self:releaseMetail()
                    self:refreshSuccLb()
                    self:refreshEquipInfo(self.m_selEquipId);
                end
            end
            params.fresh_stone = ""
            for i=1,4 do
                local item = self.m_sel_metail[i] or self.m_sel_metail[tostring(i)]
                params.fresh_stone = params.fresh_stone .. ( i==1 and "" or "_") .. (item and item.id or 0)
                params.equip_id = self.m_selEquipId
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_building_up"), http_request_method.GET, params,"equip_building_up")
        elseif btnTag == 101 then--自动添加
        	if not self.m_selEquipId then
        		game_util:addMoveTips({text = "Hãy chọn trang bị cần chế tạo"})
        		return
        	end 
        	self:autoAdd()
        elseif btnTag >= 201 and btnTag <= 204 then--排序
            local selSort = tostring(EQUIP_SORT_TAB[btnTag-200].sortType);
            game_data:equipSortByTypeName(selSort)
            self:refreshSortTabBtn(btnTag-200);
        elseif btnTag > 3000 and btnTag < 3005 then
        	if not self.m_selEquipId then
        		game_util:addMoveTips({text = "Hãy chọn trang bị cần chế tạo"})
        		return
        	end
        	local index = btnTag - 3000
        	local function callback(tab1,tab2,tab3,eventType)
                self:addSelMetail(tab1,tab2,tab3,eventType)
        	end

        	if not self.m_list_tab then
        		self.m_list_tab = game_data:getBuildingMetailListByTab(self.m_exp_up_metail)
        	end

        	game_scene:addPop("game_build_select_pop",{list_tab = util.table_copy(self.m_list_tab) ,pos = index,callback = callback })
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_equip_building_lvup.ccbi");
    --英雄相关
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_shop_btn = ccbNode:controlButtonForName("m_shop_btn")
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_level_label = ccbNode:labelTTFForName("m_level_label")

    self.m_metail_node = ccbNode:nodeForName("m_metail_node")
    self.m_max_node = ccbNode:nodeForName("m_max_node")
    self.next_node = ccbNode:nodeForName("next_node")
    self.m_temp_lb = ccbNode:labelTTFForName("m_temp_lb")
    self.m_temp_lb:setVisible(false)
    self.m_cost_sp_jinglian = ccbNode:spriteForName("m_cost_sp_jinglian")
    self.m_build_addsp1 = ccbNode:spriteForName("m_build_addsp1")
    self.m_sort1 = ccbNode:labelTTFForName("m_sort1")
    self.m_add_lb1 = ccbNode:labelTTFForName("m_add_lb1")
    self.m_refresh_cost_lb = ccbNode:labelTTFForName("m_refresh_cost_lb")
    local count = game_data:getUserStatusDataByKey("metalcore") or 0
    self.m_refresh_cost_lb:setString("×" .. count)
    self.m_build_addsp2 = ccbNode:spriteForName("m_build_addsp2")
    self.m_sort2 = ccbNode:labelTTFForName("m_sort2")
    self.m_add_lb2 = ccbNode:labelTTFForName("m_add_lb2")
    self.m_add_lb1:setString(0)
	self.m_add_lb2:setString(0)
    self.m_succ_lb = ccbNode:labelTTFForName("m_succ_lb")
    self.m_succ_lb:setString(0)
    self.m_refresh_iLb = ccbNode:labelTTFForName("m_refresh_iLb")
    self.m_refresh_iNode = ccbNode:nodeForName("m_refresh_iNode")
    for i=1,4 do
    	local m_mateil_btn = ccbNode:controlButtonForName("m_mateil_btn" .. i)
    	local m_icon_node = ccbNode:nodeForName("m_icon_node" .. i)
    	local m_all_count = ccbNode:labelTTFForName("m_all_count" .. i)
    	m_mateil_btn:setOpacity(0)
    	m_icon_node:removeAllChildrenWithCleanup(true)
    	m_all_count:setString(0)
    end

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    self.m_root_layer:setTouchEnabled(false);
    self.m_ccbNode = ccbNode
    return ccbNode;
end


function game_equip_build_lvup:refreshLvSpriteByLv(lv)
	local lv = lv or 0
	for i=1,10 do
		local lv_sp = self.m_ccbNode:spriteForName("m_lv" .. i)
		lv_sp:stopAllActions()
		lv_sp:setOpacity(255)
		if i > lv then
			lv_sp:setColor(ccc3(150,150,150))
		else
			lv_sp:setColor(ccc3(255,255,255))
		end
	end

	local next_lv = self.m_ccbNode:spriteForName("m_lv" .. lv+1)
    if next_lv then
	   self:addAnim(next_lv)
    end
end


function game_equip_build_lvup:addAnim(tempSp)
    local animArr = CCArray:create();
    animArr:addObject(CCFadeTo:create(1,100))
    animArr:addObject(CCFadeTo:create(1,255))
    tempSp:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
end
--[[--
    装备属性信息
]]
function game_equip_build_lvup.refreshEquipInfo(self,equipId)
    self.m_selEquipId = equipId;
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    if equipId ~= nil and equipId ~= "-1" then
	    local equip_building_quality = getConfig(game_config_field.equip_building_quality)
        local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipId);
        local ccbNode = game_util:createEquipItemByCCB(itemData);
        self.m_anim_node:addChild(ccbNode,10,10);
        local build_atts = itemData.build_atts
        local build_type = itemData.build_type or ""
        if build_type == "" then
			for k,v in pairs(PUBLIC_ABILITY_NAME_TABLE) do
				if build_atts[k] ~= nil then
					build_type = k
				end
			end
		end
		local buildTypeTab = PUBLIC_ABILITY_NAME_TABLE[build_type]

	    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(buildTypeTab.icon))
	    if tempSpriteFrame then
	        self.m_build_addsp1:setDisplayFrame(tempSpriteFrame)
	    end
	    self.m_sort1:setString(buildTypeTab.name)
	    self.m_add_lb1:setString(build_atts[build_type])

		local nowCfg = equip_building_quality:getNodeWithKey(tostring(itemData.build_lv))
		local nextCfg = equip_building_quality:getNodeWithKey(tostring(itemData.build_lv+1))
        nowCfg = json.decode(nowCfg:getFormatBuffer())
		if nextCfg then
			nextCfg = json.decode(nextCfg:getFormatBuffer())
			self.m_metail_node:setVisible(true)
		 	self.m_max_node:setVisible(false)
			self.next_node:setVisible(true)
		    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(buildTypeTab.icon))
		    if tempSpriteFrame then
		        self.m_build_addsp2:setDisplayFrame(tempSpriteFrame)
		    end
		    self.m_sort2:setString(buildTypeTab.name)
		    local valueT = nextCfg[build_type]
		    local value1,unit1 = game_util:formatValueToString(valueT[1]);
		    local value2,unit2 = game_util:formatValueToString(valueT[2]);
	    	self.m_add_lb2:setString(value1 .. unit1 .. "~" .. value2 .. unit2)
	    	self.m_exp_up_metail = nextCfg.exp_up or {}
		else
			self.m_metail_node:setVisible(false)
		 	self.m_max_node:setVisible(true)
			self.next_node:setVisible(false)
		end
		self.m_chance = nowCfg.exp_low
		self:refreshLvSpriteByLv(itemData.build_lv)

        local count = game_data:getUserStatusDataByKey("metalcore") or 0
        local icon,name,_ = game_util:getRewardByItemTable(nowCfg.refresh_cost[1])
        self.m_refresh_cost_lb:setString("×" .. count)
        self.m_cost_sp_jinglian:setVisible(true)
        self.m_refresh_iLb:setString("×" .. nowCfg.refresh_cost[1][3])
        self.m_refresh_iNode:removeAllChildrenWithCleanup(true)
        self.m_refresh_iNode:addChild(icon)
        icon:setAnchorPoint(ccp(0.5,0.5))
        icon:setScale(0.4)
	end
    self:refreshTips();
    self:refreshSuccLb()
end

function game_equip_build_lvup:releaseMetail()
    for i=1,4 do
        local m_icon_node = self.m_ccbNode:nodeForName("m_icon_node" .. i)
        local m_all_count = self.m_ccbNode:labelTTFForName("m_all_count" .. i)
        m_icon_node:removeAllChildrenWithCleanup(true)
        m_all_count:setString("")
    end
end

function game_equip_build_lvup:autoAdd()
	local list_tab = self.m_list_tab or game_data:getBuildingMetailListByTab(self.m_exp_up_metail)
	local function addMetail()
		for i=1,#list_tab do
			if list_tab[i][3] > 0 then
				list_tab[i][3] = list_tab[i][3] - 1
				return {id = list_tab[i][2],ItemTab = {list_tab[i][1],list_tab[i][2],1,list_tab[i][4]},key = i}
			end
		end
        return nil
	end
	for i=1,4 do
		if self.m_sel_metail[i] then
		else
			self.m_sel_metail[i] = addMetail()
            local m_icon_node = self.m_ccbNode:nodeForName("m_icon_node" .. i)
            local m_all_count = self.m_ccbNode:labelTTFForName("m_all_count" .. i)
            m_icon_node:removeAllChildrenWithCleanup(true)
            m_all_count:setString("0%")
            if self.m_sel_metail[i] then
    	    	local m_icon_node = self.m_ccbNode:nodeForName("m_icon_node" .. i)
    	    	local m_all_count = self.m_ccbNode:labelTTFForName("m_all_count" .. i)
    	    	m_icon_node:removeAllChildrenWithCleanup(true)
    	    	local icon = game_util:getRewardByItemTable(self.m_sel_metail[i].ItemTab)
    	    	if icon then
    	    		icon:setScale(0.95)
    	    		m_icon_node:addChild(icon)
    	    	end
    	    	m_all_count:setString(self.m_sel_metail[i].ItemTab[4] .. "%")
            end
		end
	end
	self.m_list_tab = list_tab
    self:refreshSuccLb()
end
function game_equip_build_lvup:addSelMetail(metail,index,key,event)
    if event == "changed" then
        local tempItem1 = self.m_sel_metail[index]
        local tempItem2 = self.m_list_tab[key]
        if tempItem1 then
            self.m_list_tab[tempItem1.key][3] = self.m_list_tab[tempItem1.key][3] + 1
        end
        self.m_sel_metail[index] = util.table_copy(metail)
        self.m_list_tab[metail.key][3] = self.m_list_tab[metail.key][3] - 1
    elseif event == "unload" then
        local tempItem1 = self.m_sel_metail[index]
        local tempItem2 = self.m_list_tab[key]
        if tempItem1 then
            self.m_list_tab[tempItem1.key][3] = self.m_list_tab[tempItem1.key][3] + 1
        end
        self.m_sel_metail[index] = nil
    end
    local m_icon_node = self.m_ccbNode:nodeForName("m_icon_node" .. index)
    local m_all_count = self.m_ccbNode:labelTTFForName("m_all_count" .. index)
    m_icon_node:removeAllChildrenWithCleanup(true)
    if metail then
        local icon = game_util:getRewardByItemTable(metail.ItemTab)
        if icon then
            icon:setScale(0.95)
            m_icon_node:addChild(icon)
        end
        m_all_count:setString(metail.ItemTab[4] .. "%")
    else
        m_all_count:setString("")
    end
    self:refreshSuccLb()

end

function game_equip_build_lvup:refreshSuccLb()
    local cont = self.m_chance or 0
    for k,v in pairs(self.m_sel_metail) do
        if v then
            cont = cont + v.ItemTab[4]
        end
    end
    self.m_succ_lb:setString(cont .. "%")
end





--[[--
    创建装备列表
]]
function game_equip_build_lvup.createEquipTableView(self,viewSize,tableData)
    self.m_selListItem = nil;
    local itemsCount = #tableData;
    local totalItem = math.max(itemsCount%4 == 0 and itemsCount or math.floor(itemsCount/4+1)*4,4)
    local equipCfg = getConfig(game_config_field.equip);
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
            if self.m_selEquipId == nil or self.m_selEquipId ~= tempId then
                if self.m_selListItem then
                    local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                    local m_sel_img = ccbNode:spriteForName("m_sel_img")
                    m_sel_img:setVisible(false);
                end
                self.m_selListItem = cell;
                self.m_selEquipId = tostring(tempId)
                self:refreshEquipInfo(self.m_selEquipId);
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                m_sel_img:setVisible(true);
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新列表
]]
function game_equip_build_lvup.refreshEquipTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_selEquipDataTab = game_data:getIsCanBuildEquipId();
    self.m_tableView = self:createEquipTableView(self.m_list_view_bg:getContentSize(),self.m_selEquipDataTab);
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--
    刷新tips
]]
function game_equip_build_lvup.refreshTips(self)
    if self.m_selEquipId ~= nil then
        self.m_tips_spr_1:setVisible(false);
    else
        self.m_tips_spr_1:setVisible(true);
    end
end

--[[--

]]
function game_equip_build_lvup.refreshSortTabBtn(self,sortIndex)
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
    刷新ui
]]
function game_equip_build_lvup.refreshUi(self)
	self:refreshSortTabBtn(self.m_selSortIndex)
	self:refreshLvSpriteByLv(0)
    -- self:refreshEquipInfo(self.m_selEquipId);
    -- self:refreshByType(self.m_showType);
    -- self:refreshCombatLabel();
end
--[[--
    初始化
]]
function game_equip_build_lvup.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selEquipId = t_params.selEquipId;
    self.m_enterType = t_params.enterType or "";
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
    self.m_sel_metail = {}
end

--[[--
    创建ui入口并初始化数据
]]
function game_equip_build_lvup.create(self,t_params)
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end

return game_equip_build_lvup;
