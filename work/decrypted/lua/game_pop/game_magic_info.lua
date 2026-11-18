--- 装备信息
local game_magic_info = {
    m_tGameData = nil,
    m_popUi = nil,
    m_fromUi = nil,
    m_name_label = nil,
    m_icon_spr = nil,
    m_ability1_name_label = nil,
    m_ability2_name_label = nil,
    m_level_label = nil,
    m_ability2_label = nil,
    m_ability1_label = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    m_openType = nil,
    m_callBack = nil,
    m_node = nil,
    m_ability1_icon = nil,
    m_ability2_icon = nil,
    m_ccbNode = nil,
    m_suit_name_label = nil,
    m_posEquipData = nil,
    m_btn_node = nil,
    m_node_getbtn_bg = nil,
    m_conbtn_toget = nil,
    m_togetFun = nil,
    m_suitEquipData = nil,
    m_sel_img = nil,
    m_label_name = nil,
    fateEquipLock = nil,
    m_btn_fate = nil,
    selHeroId = nil,
    m_curEquip_id = nil,
    curEquipData = nil,
    m_unbind_btn = nil,
    isOpen = nil,
    forging_attr = nil,
    m_TempNode1 = nil,
    m_detail_scroll = nil,
};

local tempTable = {
    ability_1 = 
    {
        {text = "物攻",lab = "m_patk_label",ability = "hp",},
        {text = "魔攻",lab = "m_matk_label",ability = "hp",},
        {text = "暴击",lab = "m_crit_label",ability = "hp",},
        {text = "命中",lab = "m_hr_label",ability = "hp" ,},
    },
    ability_0 = {
        {text = "血量",lab = "m_hp_label",ability = "hp",},
        {text = "防御",lab = "m_def",ability = "hp",},
        {text = "速度",lab = "m_speed",ability = "hp",},
        {text = "闪避",lab = "m_dr_label",ability = "hp",},
    },
}

--[[--
    销毁
]]
function game_magic_info.destroy(self)
    -- body
    cclog("-----------------game_magic_info destroy-----------------");
    self.m_tGameData = nil;
    self.m_popUi = nil;
    self.m_fromUi = nil;
    self.m_name_label = nil;
    self.m_icon_spr = nil;
    self.m_ability1_name_label = nil;
    self.m_ability2_name_label = nil;
    self.m_level_label = nil;
    self.m_ability2_label = nil;
    self.m_ability1_label = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_openType = nil;
    self.m_callBack = nil;
    self.m_node = nil;
    self.m_ability1_icon = nil;
    self.m_ability2_icon = nil;
    self.m_ccbNode = nil;
    self.m_suit_name_label = nil;
    self.m_posEquipData = nil;
    self.m_btn_node = nil;
    self.m_node_getbtn_bg = nil;
    self.m_conbtn_toget = nil;
    self.m_togetFun = nil;
    self.m_suitEquipData = nil;
    self.m_sel_img = nil;
    self.m_label_name = nil;
    self.fateEquipLock = nil;
    self.m_btn_fate = nil;
    self.selHeroId = nil;
    self.isOpen = nil;
    self.forging_attr = nil;
    self.m_TempNode1 = nil;
    self.m_detail_scroll = nil;
end
--[[--
    返回
]]
function game_magic_info.back(self,type)
    game_scene:removePopByName("game_magic_info");
end
--[[--
    读取ccbi创建ui
]]
function game_magic_info.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if self.enterType == "storeHouse_get" and btnTag ~= 1 and btnTag ~= 311 then
            game_util:addMoveTips({text = "Không thể thao tác trong kho"});
            return
        end
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 12 then
       	 	game_scene:enterGameUi("game_magic_evolution",{gameData = nil,openType = "game_function_pop"});
            self:back();
        elseif btnTag == 13 then
        	game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_main_scene"});
            self:back();
        elseif btnTag == 15 then
            local id = self.m_tGameData.id
            local function refreshCallBack( data)
                local id = self.m_tGameData.id
                local gamedata = game_data:getMagicDataById(id)
                if gamedata then
                    self.m_tGameData = gamedata
                end
                self:refreshUi()
            end
            game_scene:addPop("game_talisman_enchant",{selID = id,callBack = refreshCallBack})
        elseif btnTag == 311 then -- 存入仓库
            if self.enterType == "storeHouse_get" then
                cclog("[storeHouse] 点击存入法宝")
                local function responseMethod(tag,gameData)
                    game_util:addMoveTips({text = "Lấy ra thành công!"})
                    if self.endCb and type(self.endCb) == "function" then
                        self.endCb();
                    end
                    self:back();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("storehouse_del_talisman"), http_request_method.GET, {talisman_ids = self.m_tGameData.id},"storehouse_del_talisman")   
            elseif self.enterType == "storeHouse_save" then
                cclog("[storeHouse] 点击存入法宝")
                local function responseMethod(tag,gameData)
                    game_util:addMoveTips({text = "Cất vào thành công!"})
                    if self.endCb and type(self.endCb) == "function" then
                        self.endCb();
                    end
                    self:back();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("storehouse_store_talisman"), http_request_method.GET, {talisman_ids = self.m_tGameData.id},"storehouse_store_talisman")   
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_magic_info_pop.ccbi");
    ccbNode:controlButtonForName("btn_storeToHouse"):setVisible(false)
    self.m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
    self.m_icon_spr = ccbNode:spriteForName("m_icon_spr")
    self.m_icon_node = ccbNode:nodeForName("m_icon_node")
    self.m_attr_node_1 = ccbNode:nodeForName("m_attr_node_1")
    self.m_attr_node_2 = ccbNode:nodeForName("m_attr_node_2")
    self.m_attr_node_3 = ccbNode:nodeForName("m_attr_node_3")
    self.m_attr_node_4 = ccbNode:nodeForName("m_attr_node_4")
    self.m_level_label = ccbNode:labelTTFForName("m_level_label");
    self.m_label_name = ccbNode:labelTTFForName("m_label_name")
    self.m_label_name:setColor(HERO_QUALITY_COLOR_TABLE_3[self.m_openType+5].color)
    self.m_btn2 = ccbNode:controlButtonForName("m_btn2")
    self.m_btn3 = ccbNode:controlButtonForName("m_btn3")
    self.btn_storeToHouse = ccbNode:controlButtonForName("btn_storeToHouse")
    self.btn_storeToHouse:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 14);
    self.m_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 14);
    self.m_btn3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 14);
    self.m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"), "CCControlButton");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 14);
    -- self.m_button_enchant = tolua.cast(ccbNode:objectForName("m_button_enchant"), "CCControlButton");
    -- self.m_button_enchant:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 14);

    -- if game_data:isViewOpenByID(217) then
    --     self.m_button_enchant:setVisible(true)
    -- else
    --     self.m_button_enchant:setVisible(false)
    -- end
    ccbNode:labelTTFForName("m_des_lab"):setVisible(false)
    self.m_detail_scroll = ccbNode:scrollViewForName("detail_scroll");
    self.m_detail_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 14);

    self.m_sarah_node = ccbNode:nodeForName("m_sarah_node")
    self.m_sarah_add_sp1 = ccbNode:spriteForName("m_sarah_add_sp1")
    self.m_sarah_add_sp2 = ccbNode:spriteForName("m_sarah_add_sp2")
    self.m_sarah_add_lb1 = ccbNode:labelTTFForName("m_sarah_add_lb1")
    self.m_sarah_add_lb2 = ccbNode:labelTTFForName("m_sarah_add_lb2")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-13,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode;
    return ccbNode;
end



function game_magic_info.refreshUi(self)
    local talismanCfg = getConfig(game_config_field.talisman);
    local itemCfg = talismanCfg:getNodeWithKey(self.m_tGameData.c_id);
    local tab = game_util:getMagicAbilityValue(itemCfg,self.m_tGameData.lv)
    cclog2(self.m_tGameData)
    if self.m_magicType == nil then
       self.m_magicType = itemCfg:getNodeWithKey("talisman_type"):toInt();
    end
	if self.m_magicType == 1 then
		self.m_attr_node_1:setVisible(true)
		self.m_attr_node_2:setVisible(true)
		self.m_attr_node_3:setVisible(false)
		self.m_attr_node_4:setVisible(false)
	else
		self.m_attr_node_1:setVisible(false)
		self.m_attr_node_2:setVisible(false)
		self.m_attr_node_3:setVisible(true)
		self.m_attr_node_4:setVisible(true)
	end
    local lab_table = tempTable["ability_" .. self.m_magicType]
    for i=1,#lab_table do
        local v = lab_table[i]
        local lab = self.m_ccbNode:labelTTFForName(v.lab)
        lab:setString(tab[i].value)
    end
    local icon = game_util:createMagicIcon(itemCfg)
    if icon then
        self.m_icon_node:addChild(icon)
    end
    self.m_level_label:setString("Lv." .. self.m_tGameData.lv)
    self.m_label_name:setString(itemCfg:getNodeWithKey("talisman_name"):toStr())
    local str = itemCfg:getNodeWithKey("des"):toStr()
    str = string.gsub( str, "effect", itemCfg:getNodeWithKey("effect"):toStr())
--===============================
    local _str = ""
    if self.m_tGameData.is_forging then
        local _effect = self.forging_attr.effect
        local _id = self.forging_attr.forging_id

        local forginglistCfg = json.decode(getConfig(game_config_field.talisman_forging_list):getFormatBuffer())
        _str = string.gsub( forginglistCfg[_id..""]["des"], "effect", _effect)
    end
    if not self.m_TempNode1 then
        self.m_TempNode1 = CCNode:create()
        self.m_detail_scroll:addChild(self.m_TempNode1,1001)
    else
        self.m_TempNode1:removeAllChildrenWithCleanup(true)
    end

    local itemlabel1 = game_util:createRichLabelTTF({text = str,dimensions = CCSizeMake(150,0),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(255,255,255),fontSize = 12})
    local itemlabel2 = nil
    if _str ~= ""  then
         itemlabel2 = game_util:createRichLabelTTF({text = _str,dimensions = CCSizeMake(150,0),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(0,255,0),fontSize = 12})
    end

    local viewSize1 = self.m_detail_scroll:getViewSize()
    local height1 = 0

    if _str ~= "" then
        self.m_TempNode1:addChild(itemlabel2)
        itemlabel2:setAnchorPoint(ccp(0.5,0))
        itemlabel2:setPosition(ccp(0,height1))
        height1 = height1 + itemlabel2:getContentSize().height + 4
    end
    self.m_TempNode1:addChild(itemlabel1)
    itemlabel1:setAnchorPoint(ccp(0.5,0))
    itemlabel1:setPosition(ccp(0,height1))
    height1 = height1 + itemlabel1:getContentSize().height

    self.m_TempNode1:setContentSize(CCSizeMake(viewSize1.width,height1))
    self.m_TempNode1:setAnchorPoint(ccp(0,0))
    self.m_TempNode1:setPosition(ccp(self.m_detail_scroll:getViewSize().width/2,0))

    self.m_detail_scroll:setContentSize(CCSizeMake(self.m_detail_scroll:getContentSize().width,height1))
    self.m_detail_scroll:setContentOffset(ccp(0,viewSize1.height-height1),true)

    if self.isOpen ~= nil then
        self.m_btn2:setVisible(false)
        self.m_btn3:setVisible(false)
    else
        self.m_btn2:setVisible(true)
        self.m_btn3:setVisible(true)
    end

    local enchanting = self.m_tGameData.enchanting
    if enchanting and ( (enchanting.hole_1 and enchanting.hole_1.material_id) or (enchanting.hole_2 and enchanting.hole_2.material_id)) then
        -- self.m_sarah_node:setVisible(true)
        local hole_1 = enchanting.hole_1
        if hole_1 and hole_1.effect then
            self.m_sarah_add_sp1:setVisible(true)
            self.m_sarah_add_lb1:setVisible(true)
            local effect = hole_1.effect
            local att = {}
            for k,v in pairs(effect) do
                att.key = k
                att.value = v
            end
            local attTab = PUBLIC_ABILITY_TABLE["ability_" .. att.key]
            local tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(attTab.icon)
            if tempSpriteFrame1 then
                self.m_sarah_add_sp1:setDisplayFrame(tempSpriteFrame1)
            end
            local str = att.value .. (attTab.isPercentage and "%" or "")
            self.m_sarah_add_lb1:setString(str)
        else
            self.m_sarah_add_sp1:setVisible(false)
            self.m_sarah_add_lb1:setVisible(false)
        end
        local hole_2 = enchanting.hole_2
        if hole_2 and hole_2.effect then
            local flag = self.m_sarah_add_sp1:isVisible()

            self.m_sarah_add_sp1:setVisible(true)
            self.m_sarah_add_lb1:setVisible(true)
            local effect = hole_2.effect
            local att = {}
            for k,v in pairs(effect) do
                att.key = k
                att.value = v
            end
            local attTab = PUBLIC_ABILITY_TABLE["ability_" .. att.key]
            local tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(attTab.icon)
            if tempSpriteFrame1 then
                if flag then
                    self.m_sarah_add_sp2:setVisible(true)
                    self.m_sarah_add_lb2:setVisible(true)
                    self.m_sarah_add_sp2:setDisplayFrame(tempSpriteFrame1)
                    local str = att.value .. (attTab.isPercentage and "%" or "")
                    self.m_sarah_add_lb2:setString(str)
                else
                    self.m_sarah_add_sp1:setVisible(true)
                    self.m_sarah_add_lb1:setVisible(true)
                    self.m_sarah_add_sp2:setVisible(false)
                    self.m_sarah_add_lb2:setVisible(false)
                    self.m_sarah_add_sp1:setDisplayFrame(tempSpriteFrame1)
                    local str = att.value .. (attTab.isPercentage and "%" or "")
                    self.m_sarah_add_lb1:setString(str)
                end
            end
        else
            self.m_sarah_add_sp2:setVisible(false)
            self.m_sarah_add_lb2:setVisible(false)
        end
    else
        -- self.m_sarah_node:setVisible(false)
    end

    -- 超级仓库
    if self.enterType == "storeHouse_get" then
        self.btn_storeToHouse:setVisible(true)
        game_util:setCCControlButtonBackground(self.btn_storeToHouse, "storeHouse_4.png")
    elseif self.enterType == "storeHouse_save" then
        local id = self.m_tGameData.id
        local isUsing = game_data:checkMagicInUsing(id)
        self.btn_storeToHouse:setVisible(not isUsing)
        game_util:setCCControlButtonBackground(self.btn_storeToHouse, "storeHouse_2.png")
    else
        self.btn_storeToHouse:setVisible(false)
    end
end

--[[--
    初始化
]]
function game_magic_info.init(self,t_params)
    t_params = t_params or {};
    cclog2(t_params)
    self.m_magicType = t_params.magicType 
    self.m_tGameData = t_params.tGameData;
    self.endCb = t_params.endCb

    self.m_openType = t_params.openType or 1;
    local data = game_data:getMagicDataById(self.m_tGameData.id)
    if data then
        self.m_tGameData = data
    end
    self.forging_attr = t_params.tGameData.forging_attr

    if self.m_openType == 11 then
        self.m_togetFun = self:getGoToGetEquipFun( self.m_tGameData.c_id )
    end
    -- cclog2(t_params.isOpen,"t_params.isOpen -==========")
    if t_params.isOpen ~= nil then
        self.isOpen = t_params.isOpen
    end
    if t_params.itemCfg then
        self.m_itemCfg = t_params.itemCfg
    end
    self.enterType = t_params.enterType
end

--[[--
    创建ui入口并初始化数据
]]
function game_magic_info.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_magic_info;