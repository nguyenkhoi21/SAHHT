--装备复炼
local game_equip_build_again = {
	m_sel_sort = nil,
	m_attr_old = nil,
	m_exp = nil,
	m_msg = nil,
	m_msg_exp = nil,
	m_add_sp = nil,
	m_metail_lb = nil,
	m_card_node = nil,
	m_list_view_bg = nil,
	m_ccbNode = nil,
	temp_ParentNode = nil,
	m_select_suit = nil,
	m_scroll = nil,
	m_selListItem = nil,
	m_selEquipId = nil,
	m_tableView = nil,
	m_selSortIndex = nil,
	m_building_suitCfg = nil,
	m_equip_buildingCfg = nil,
	m_equip = nil,
    btn_equip_do=nil,
    m_cost_node_jinglian = nil,
}


function game_equip_build_again:destroy()
    cclog(" ------------game_equip_build_again destroy------------ ")
	self.m_selEquipId = nil;
	self.m_sel_sort = nil;
	self.m_attr_old = nil;

	self.m_exp = nil;
	self.m_msg = nil;
	self.m_msg_exp = nil;
	self.m_add_sp = nil;
	self.m_metail_lb = nil;
	self.m_card_node = nil;
	self.m_list_view_bg = nil;
	self.m_ccbNode = nil;
	self.m_select_suit = nil;
	self.temp_ParentNode = nil;
	self.m_scroll = nil;
	self.m_selListItem = nil;
	self.m_tableView = nil;
	self.m_building_suitCfg = nil;
	self.m_equip_buildingCfg = nil;
	self.m_equip = nil;
	self.m_selSortIndex = nil;
    self.btn_equip_do = nil;
    self.m_cost_node_jinglian = nil;
end

function game_equip_build_again:back( )
	game_scene:enterGameUi("game_main_scene",{gameData = nil});
end

function game_equip_build_again:createUi(  )
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 10 then
        	self:back()
    	elseif btnTag == 11 then -- 打造属性预览
            local equip_building_old = getConfig(game_config_field.equip_building_old)
            local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipId);
            local sort = itemCfg:getNodeWithKey("sort"):toStr()
            local costCfg = json.decode(equip_building_old:getNodeWithKey(sort):getFormatBuffer())
            self.m_sel_sort = util.table_copy(costCfg)
    	   	if not self.m_sel_sort or self.m_selEquipId == nil then
                game_util:addMoveTips({text = "Hãy chọn trang bị cần chế tạo"})
    	   		return
    	   	end
    	   	game_scene:addPop("game_equip_building_look",{eq_eff = self.m_sel_sort.add_type,build_lv = itemData.build_lv})
    	elseif btnTag == 12 then -- 打造装备升级
            game_scene:enterGameUi("game_equip_build_lvup",{enterType = "game_equip_build_again"})
    	elseif btnTag == 13 then -- 新装备打造
            game_scene:enterGameUi("game_equip_build_main",{gameData = gameData});
        elseif btnTag == 14 then -- 打造
            if self.m_selEquipId == nil then
                game_util:addMoveTips({text = "Hãy chọn trang bị cần chế tạo"})
                return
            end
            local function responseMethod(tag,gameData)
                self:refreshEquipInfo(self.m_selEquipId)
                game_util:addMoveTips({text = "Phục luyện thành công!"})
            end
            local params = {}
            params.equip_id = self.m_selEquipId
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_building_again"), http_request_method.GET, params,"equip_building_again")
        elseif btnTag == 15 then
            game_scene:addPop("game_active_limit_detail_pop",{enterType = "194"})
        elseif btnTag == 16 then
            game_scene:enterGameUi("game_equip_build_old_main")
        elseif btnTag >= 201 and btnTag <= 204 then--排序
            local selSort = tostring(EQUIP_SORT_TAB[btnTag-200].sortType);
            game_data:equipSortByTypeName(selSort)
            self:refreshSortTabBtn(btnTag-200);
    	end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_equip_building_again.ccbi");
    self.m_cost_sp_jinglian = ccbNode:spriteForName("m_cost_sp_jinglian")
    self.m_cost_sp_jinglian:setVisible(false)
    self.m_exp = ccbNode:labelTTFForName("m_exp")
    self.m_msg = ccbNode:labelTTFForName("m_msg")
    self.m_msg_exp = ccbNode:labelTTFForName("m_msg_exp")
    self.m_add_sp = ccbNode:spriteForName("m_add_sp")
    self.m_metail_lb = ccbNode:labelTTFForName("m_metail_lb")
    self.m_card_node = ccbNode:nodeForName("m_icon_node1")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.btn_equip_do = ccbNode:controlButtonForName("btn_equip_do")
    self.m_cost_node_jinglian = ccbNode:nodeForName("m_cost_node_jinglian")
    self.btn_equip_do:setColor(ccc3(100,100,100))
    self.btn_equip_do:setEnabled(false)
    self.m_ccbNode = ccbNode
    return ccbNode;
end


function game_equip_build_again:resetRightInfo()
    self.m_card_node:removeAllChildrenWithCleanup(true)
    self.m_cost_sp_jinglian:setVisible(false)
    self.m_metail_lb:setString("")
    for i=2,3 do
        local m_icon_node = self.m_ccbNode:nodeForName("m_icon_node" .. i)
        local m_all_count = self.m_ccbNode:labelTTFForName("m_all_count" .. i)
        local m_need_count = self.m_ccbNode:labelTTFForName("m_need_count" .. i)
        m_icon_node:removeAllChildrenWithCleanup(true)
        m_all_count:setString(0)
        m_need_count:setString(0)
    end
end

--[[--
    创建装备列表
]]
function game_equip_build_again.createEquipTableView(self,viewSize,tableData)
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
    装备属性信息
]]
function game_equip_build_again.refreshEquipInfo(self,equipId)

    self.btn_equip_do:setColor(ccc3(100,100,100))
    self.btn_equip_do:setEnabled(false)
	local pos = {{0},{38,-38}}
    self.m_selEquipId = equipId;
    self.m_card_node:removeAllChildrenWithCleanup(true);
    local flagmetal = {false,false}
    if equipId ~= nil and equipId ~= "-1" then
	    local equip_building_again = getConfig(game_config_field.equip_building_again)
        local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipId);
        self.m_attr_old = util.table_copy(itemData)
        local ccbNode = game_util:createEquipItemByCCB(itemData);
        self.m_card_node:addChild(ccbNode,10,10);

        local costCfg = json.decode(equip_building_again:getNodeWithKey(itemData.c_id):getFormatBuffer())
        
		local posY = pos[#costCfg.building_again_need]
		local x,y = self.m_add_sp:getPosition()

        local itemCallFun = function ( event, target )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            print("press button tag is ", btnTag)
            game_util:lookItemDetal( costCfg.building_again_need[btnTag] )
        end

	    for i=1,#costCfg.building_again_need do
	        local itemData = costCfg.building_again_need[i]
	        local m_mateil_node = self.m_ccbNode:nodeForName("m_mateil_node" .. i+1)
	        if itemData then
	            m_mateil_node:setVisible(true)
	            m_mateil_node:setPositionY(y + posY[i])
	            local count = game_data:getItemCountByCid(itemData[2]) or 0
	            m_icon_node = self.m_ccbNode:nodeForName("m_icon_node" .. i+1)
	            m_icon_node:removeAllChildrenWithCleanup(true)
	            m_all_count = self.m_ccbNode:labelTTFForName("m_all_count" .. i+1)
	            m_need_count = self.m_ccbNode:labelTTFForName("m_need_count" .. i+1)
	            m_all_count:setString(count)
	            m_all_count:setColor(count < itemData[3] and ccc3(255,0,0) or ccc3(0,255,0))
                flagmetal[i] = (count >= itemData[3])
	            m_need_count:setString(itemData[3])
	            local icon = game_util:getRewardByItemTable(itemData)
	            if icon then
	                icon:setAnchorPoint(ccp(0.5,0.5))
	                m_icon_node:addChild(icon)
                    local button = game_util:createCCControlButton("public_weapon.png","",itemCallFun)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition( icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5 )
                    button:setOpacity(0)
                    icon:addChild(button)
                    button:setTag(i)
	            end
	        else
	            m_mateil_node:setVisible(false)
	        end
    	end

	    local _ , all_count = game_data:getMetalByTable(costCfg.need_diamond[1])
	    local value1,unit1 = game_util:formatValueToString2(all_count)

	    local icon,name,count =game_util:getRewardByItemTable(costCfg.need_diamond[1])
        local build_again_times = itemData.build_again_times or 0

        if build_again_times > 8 then build_again_times = 8 end 

        local build_again_count = nil 
        for k,v in pairs(costCfg.time_add) do
            if v[1] == build_again_times then
                build_again_count = v[2]
                break
            end
        end

        count = count * tonumber(build_again_count)
        local value2,unit2 = game_util:formatValueToString2(count)

	    self.m_metail_lb:setString(value2 .. unit2.."/"..value1 .. unit1  )
        -- self.m_cost_sp_jinglian:setVisible(true)
        -- self.m_cost_sp_jinglian:setScale(0.3)
        -- self.m_cost_sp_jinglian:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_icon_gold2.png"))


        -- if self.m_cost_node_jinglian:getChildren() then
        --     self.m_cost_node_jinglian:removeAllChildrenWithCleanup(true)
        -- end
        self.m_cost_node_jinglian:addChild(icon)
        icon:setScale(0.4)
        -- _:setScale(0.4)
        -- self.m_cost_sp_jinglian:addChild(_)

	    -- self.m_msg:setString(costCfg.des)

        if flagmetal[1] and flagmetal[2] and all_count >= count then
            self.btn_equip_do:setColor(ccc3(255,255,255))
            self.btn_equip_do:setEnabled(true)
        end
	end

end
--[[--
    刷新列表
]]
function game_equip_build_again.refreshEquipTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_selEquipDataTab = game_data:getTenEquipIdTable2();
    self.m_tableView = self:createEquipTableView(self.m_list_view_bg:getContentSize(),self.m_selEquipDataTab);
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--

]]
function game_equip_build_again.refreshSortTabBtn(self,sortIndex)
    self.m_selSortIndex = sortIndex;
    local tempBtn = nil;
    for i=1,4 do
        tempBtn = self.m_ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
        tempBtn:setHighlighted(self.m_selSortIndex == i);
        tempBtn:setEnabled(self.m_selSortIndex ~= i);
    end
    self:refreshEquipTableView()
end


function game_equip_build_again:refreshUi( )
	self:refreshSortTabBtn(self.m_selSortIndex)
end

function game_equip_build_again:init( t_params )
	local building_suit = getConfig(game_config_field.building_suit)
    self.m_building_suitCfg = json.decode(building_suit:getFormatBuffer())
    self.m_equip_buildingCfg = getConfig(game_config_field.equip_building)
    self.m_equip = getConfig(game_config_field.equip)
	self.m_selSortIndex = self.m_selSortIndex or 1;
end
function game_equip_build_again:create( t_params )
	 self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_equip_build_again