local game_equip_build_main = {
    m_select_sp = nil,
    m_select_Param = nil,
    m_building_list_node = nil,
    m_scroll = nil,
    m_exp = nil,
    temp_ParentNode = nil,
    m_msg = nil,
    m_msg_exp = nil,
    m_metail_lb = nil,
    m_anim_node = nil,
    m_ccbNode = nil,
    m_select_suit = nil,
    m_add_sp = nil,
    m_building_suitCfg = nil,
    m_equip_buildingCfg = nil,
    m_equip = nil,
    m_select_Param = {},
}


function game_equip_build_main:destroy()
	self.m_select_sp = nil;
    self.m_select_Param = nil;
    self.m_building_list_node = nil;
    self.m_scroll = nil;
    self.m_exp = nil;
    self.temp_ParentNode = nil;
    self.m_msg = nil;
    self.m_msg_exp = nil;
    self.m_metail_lb = nil;
    self.m_anim_node = nil;
    self.m_ccbNode = nil;
    self.m_select_suit = nil;
    self.m_add_sp = nil;
    self.m_building_suitCfg = nil;
    self.m_equip_buildingCfg = nil;
    self.m_equip = nil;
    self.m_select_Param = {};
end

function game_equip_build_main:back( )
	game_scene:enterGameUi("game_main_scene",{gameData = nil});
end

function game_equip_build_main:createUi(  )
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 10 then
        	self:back()
    	elseif btnTag == 11 then -- 打造属性预览
            if not  (self.m_select_Param and self.m_select_Param.build_id) then
                game_util:addMoveTips({text = "Hãy chọn trang bị"})
                return
            end
            local build_effect = self.m_select_Param.build_id
            local equip_building = self.m_equip_buildingCfg:getNodeWithKey(tostring(build_effect))
            game_scene:addPop("game_equip_building_look",{eq_eff = json.decode(equip_building:getNodeWithKey("add_type"):getFormatBuffer())})
    	elseif btnTag == 12 then -- 打造装备升级
            game_scene:enterGameUi("game_equip_build_lvup",{enterType = "game_equip_build_main"})
		elseif btnTag == 13 then -- 旧装备打造
            game_scene:enterGameUi("game_equip_build_old_main")
    	elseif btnTag == 14 then -- 打造
            if not (self.m_select_Param and self.m_select_Param.build_id) then
                game_util:addMoveTips({text = "Hãy chọn trang bị"})
                return
            end
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local dataTable = json.decode(data:getFormatBuffer()) or {}
                if dataTable.building_equip ~= "" then
                    local building_equip,_ = game_data:getEquipDataById(dataTable.building_equip)
                -- local building_equip = json.decode(data:getNodeWithKey("building_equip"):getFormatBuffer())
                    local function callfun()
                        local is_gift = dataTable.is_gift
                        if is_gift == 1 then
                            game_util:rewardTipsByDataTable(dataTable.reward)
                        end
                        self:refreshRightInfo(self.m_select_Param.build_id)
                    end
                    game_sound:playUiSound("gacha")
                    game_scene:addPop("game_equip_build_pop",{new_att = building_equip,opentype = 1,callfun = callfun})
                else
                    game_util:rewardTipsByDataTable(dataTable.reward)
                    self:refreshRightInfo(self.m_select_Param.build_id)
                end
            end
            local params = self.m_select_Param
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_building"), http_request_method.GET, params,"equip_building")
    	elseif btnTag == 15 then
            game_scene:addPop("game_active_limit_detail_pop",{enterType = "194"})
        elseif btnTag == 16 then
            game_scene:enterGameUi("game_equip_build_again")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_equip_building_old_main.ccbi");
    self.m_building_list_node = ccbNode:nodeForName("m_building_list_node")
    self.m_scroll = ccbNode:scrollViewForName("m_scroll")
    self.m_exp = ccbNode:labelTTFForName("m_exp")
    self.m_cost_sp_jinglian = ccbNode:spriteForName("m_cost_sp_jinglian")
    self.m_cost_sp_jinglian:setVisible(false)
    self.temp_ParentNode = CCNode:create()
    self.temp_ParentNode:setAnchorPoint(ccp(0.5,0.5))
    local viewSize = self.m_building_list_node:getContentSize()
    self.temp_ParentNode:setPosition(ccp(viewSize.width*0.5,viewSize.height))
    self.m_scroll:addChild(self.temp_ParentNode)
    self.m_msg = ccbNode:labelTTFForName("m_msg")
    self.m_msg_exp = ccbNode:labelTTFForName("m_msg_exp")
    self.m_add_sp = ccbNode:spriteForName("m_add_sp")
    self.m_metail_lb = ccbNode:labelTTFForName("m_metail_lb")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_ccbNode = ccbNode
    return ccbNode;
end

function game_equip_build_main:createLeftList()
    local sort_name = {"Vũ khí","phụ kiện","giáp sắt","giày"}
    self.temp_ParentNode:removeAllChildrenWithCleanup(true)
    local viewSize = self.m_building_list_node:getContentSize()
    local itemSize = CCSizeMake(viewSize.width,viewSize.height/6)
    local viewSize2 = self.m_scroll:getViewSize();
    local suitTab = {}
    local e_tab = {}
    local select_tab = {}
    -- local tempLayer = CCLayerColor:create(ccc4(100,200,150, 255), viewSize.width, viewSize.height*2);
    -- tempLayer:setPosition(ccp(0,0))
    -- self.temp_ParentNode:addChild(tempLayer)
    local count = 0
    local sele_height = 0
    self.m_select_sp = nil
    for i=1,game_util:getTableLen(self.m_building_suitCfg) do
        local itemCfg = self.m_building_suitCfg[tostring(i)]
        local ccbNode = luaCCBNode:create();
        local function onclick( target,event )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            local tempCCB = suitTab[btnTag]
            local m_open_sp = tempCCB:spriteForName("m_open_sp")
            if self.m_select_suit and self.m_select_suit == btnTag then
                self.m_select_suit = nil
            else
                self.m_select_suit = btnTag
            end
            self:refreshUi()
        end
        ccbNode:registerFunctionWithFuncName("onclick",onclick);
        ccbNode:openCCBFile("ccb/ui_equip_build_item.ccbi");
        suitTab[i] = ccbNode
        local m_click_btn = ccbNode:controlButtonForName("m_click_btn")
        count = count + 1
        m_click_btn:setOpacity(0)
        m_click_btn:setTag(i)
        ccbNode:labelTTFForName("m_name_lb1"):setString(itemCfg.type_name)
        ccbNode:labelTTFForName("m_name_lb2"):setString(itemCfg.type_name)
        ccbNode:setPosition(ccp(0,-(itemSize.height*0.5*(2*count-1))))
        self.temp_ParentNode:addChild(ccbNode)
        if self.m_select_suit ~= nil and self.m_select_suit == i then
            sele_height = itemSize.height*0.5*(2*count-2)
            ccbNode:spriteForName("m_open_sp"):setScaleY(1)
            for i=1,#itemCfg.equip_building do
                local suit_id = itemCfg.equip_building[i]
                local TempSuit = self.m_equip_buildingCfg:getNodeWithKey(tostring(suit_id))
                local equip_tab = json.decode(TempSuit:getNodeWithKey("equip_id"):getFormatBuffer())
                local function onclick1(target,event )
                    local tagNode = tolua.cast(target, "CCNode");
                    local btnTag = tagNode:getTag();
                    local itemData = e_tab[tostring(btnTag)]
                    if self.m_select_sp then
                        self.m_select_sp:setVisible(false)
                    end
                    self.m_select_sp = select_tab[tostring(btnTag)]
                    self.m_select_sp:setVisible(true)
                    self.m_select_Param = {build_id = itemData.suit,equip_cid = btnTag}
                    self:refreshRightInfo(itemData.suit)
                end
                for i=1,#equip_tab do
                    local key = equip_tab[i]
                    local eqCfg = self.m_equip:getNodeWithKey(key)
                    local equip_ccb = luaCCBNode:create();
                    count = count + 1
                    equip_ccb:registerFunctionWithFuncName("onclick",onclick1);
                    equip_ccb:openCCBFile("ccb/ui_equip_build_item2.ccbi");
                    equip_ccb:setPosition(ccp(0,-(itemSize.height*0.5*(2*count-1))))
                    local m_select1 = equip_ccb:spriteForName("m_select1")
                    self.temp_ParentNode:addChild(equip_ccb)
                    equip_ccb:labelTTFForName("m_name"):setString(eqCfg:getNodeWithKey("name"):toStr())
                    equip_ccb:labelTTFForName("m_lv"):setString("Level:" .. tostring(1))
                    local sort = tonumber(eqCfg:getNodeWithKey("sort"):toStr())
                    equip_ccb:labelTTFForName("m_sort"):setString("Loại:" .. sort_name[sort])
                    local m_click_btn = equip_ccb:controlButtonForName("m_click_btn")
                    m_click_btn:setOpacity(0)
                    m_click_btn:setTag(tonumber(key))
                    select_tab[tostring(key)] = m_select1
                    e_tab[tostring(key)] = {suit = suit_id }

                    local m_icon_node = equip_ccb:nodeForName("m_icon_node")
                    local icon = self:createEquipIcon(eqCfg)
                    m_icon_node:removeAllChildrenWithCleanup(true)
                    if icon then
                        icon:setScale(0.63)
                        m_icon_node:addChild(icon)
                    end
                end
            end
        end


    end
    local tHeight = itemSize.height*0.5*(2*count)
    self.temp_ParentNode:setPositionY(tHeight)
    self.m_scroll:setContentSize(CCSizeMake(viewSize.width,tHeight))
    if sele_height == 0 then
        self.m_scroll:setContentOffset(ccp(0,viewSize.height - tHeight), false)
    elseif sele_height > 0 then
        self.m_scroll:setContentOffset(ccp(0,(sele_height + viewSize.height) - tHeight), false)
    end
end


function game_equip_build_main:createEquipIcon( eqCfg )
    local tempIcon = nil;
    if eqCfg then
        local image = eqCfg:getNodeWithKey("image"):toStr();
        tempIcon = game_util:createIconByName(image)
        if tempIcon == nil then
            cclog(image .. " image is not found");
        end
    else
        cclog("equip config is not found");
    end
    return tempIcon;
end


function game_equip_build_main:refreshRightInfo(key)
    local pos = {c2 = {0,0},c3 = {0,38,-38}}
    local tempData = json.decode(self.m_equip_buildingCfg:getNodeWithKey(tostring(key)):getFormatBuffer())
    local building_need = tempData.building_need
    local pos_y = pos["c" .. #building_need]
    local x,y = self.m_add_sp:getPosition()

    local itemCallFun = function ( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("press button tag is ", btnTag)
        game_util:lookItemDetal( building_need[btnTag] )
    end

    for i=1,3 do
        local itemData = building_need[i]
        local m_mateil_node = self.m_ccbNode:nodeForName("m_mateil_node" .. i)
        if itemData then
            m_mateil_node:setVisible(true)
            m_mateil_node:setPositionY(y + pos_y[i])
            local count = game_data:getItemCountByCid(itemData[2]) or 0
            m_icon_node = self.m_ccbNode:nodeForName("m_icon_node" .. i)
            m_icon_node:removeAllChildrenWithCleanup(true)
            m_all_count = self.m_ccbNode:labelTTFForName("m_all_count" .. i)
            m_need_count = self.m_ccbNode:labelTTFForName("m_need_count" .. i)
            m_all_count:setString(count)
            m_all_count:setColor(count < itemData[3] and ccc3(255,0,0) or ccc3(0,255,0))
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
    self.m_msg:setString(tempData.des)
    self.m_msg_exp:setString("Cộng" .. tempData.building_exp .. " điểm may mắn chế tạo")
    local all_count = game_data:getUserStatusDataByKey("metalcore") or 0
    local value,unit = game_util:formatValueToString2(all_count)
    local material = tempData.building_material[1]
    local _,name,count =game_util:getRewardByItemTable(material)
    self.m_metail_lb:setString("×" .. count .. "/" .. value .. unit)
    self.m_cost_sp_jinglian:setVisible(true)
    local building_exp = game_data:getUserStatusDataByKey("building_exp")
    if self.m_select_suit then
        local exp = building_exp[tostring(self.m_select_suit)]
        exp = (exp > 100) and 100 or exp
        self.m_exp:setString(exp .. " điểm")
    end
end


function game_equip_build_main:refreshUi( )
	self:createLeftList()
    local building_exp = game_data:getUserStatusDataByKey("building_exp")
    if self.m_select_suit then
        local exp = building_exp[tostring(self.m_select_suit)]
        exp = (exp > 100) and 100 or exp
        self.m_exp:setString(exp .. " điểm")
    else
        self.m_exp:setString("0 điểm")
    end
end


function game_equip_build_main:init( t_params )
	local building_suit = getConfig(game_config_field.building_suit)
    self.m_building_suitCfg = json.decode(building_suit:getFormatBuffer())
    self.m_equip_buildingCfg = getConfig(game_config_field.equip_building)
    self.m_equip = getConfig(game_config_field.equip)

end
function game_equip_build_main:create( t_params )
	 self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_equip_build_main