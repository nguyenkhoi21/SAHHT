--装备打造结果界面
local game_equip_build_pop = {
	m_root_layer = nil,
	callback = nil,
	m_type_node1 = nil,
	m_type_node2 = nil,
	m_openType = nil,
	m_attr_old = nil,
	m_new_att = nil,
	callback = nil,
} 

function game_equip_build_pop:destroy( )
	cclog("---------- game_equip_build_pop destroy -----------")
	self.m_root_layer = nil;
	self.callback = nil;

	self.m_type_node1 = nil;
	self.m_type_node2 = nil;
	self.m_openType = nil;
	self.m_attr_old = nil;
	self.m_new_att = nil;
	self.callback = nil;
end



function game_equip_build_pop:back()
	if self.callback then
		self.callback()
	end
	game_scene:removePopByName("game_equip_build_pop")
end



function game_equip_build_pop:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 1 then
			self:back()
		else
		end
	end
	local ccbNode =  luaCCBNode:create();
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_equip_building_succ.ccbi")
	self.m_type_node1 = ccbNode:nodeForName("m_type_node1")
	self.m_type_node2 = ccbNode:nodeForName("m_type_node2")
	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        	self:back()
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode
	return ccbNode
end

function game_equip_build_pop:createContentTable(viewSize)
    local contentText = "\n";
	for i=1,#self.m_equip_effect do
		local v = self.m_equip_effect[i]
		local ability_tab = PUBLIC_ABILITY_TABLE["ability_" .. v]
		contentText = contentText .. ability_tab.des .. ":Phạm vi thuộc tính:【" .. self.m_equip_building_qualityCfg[ability_tab.attrName][1] .. "-" .. self.m_equip_building_qualityCfg[ability_tab.attrName][2] .. "】\n\n"
	end
    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(220,0),textAlignment = kCCTextAlignmentCenter,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(255,178,51),fontSize = 11})
    local tempSize = tempLabel:getContentSize();
    self.text_scroll:setContentSize(CCSizeMake(220,tempSize.height))
    self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.text_scroll:addChild(tempLabel)
end

function game_equip_build_pop:refreshInfo1()
	local m_icon_node = self.m_ccbNode:nodeForName("m_icon_node")
	local m_name_lb = self.m_ccbNode:labelTTFForName("m_name_lb")
	local m_lv_lb = self.m_ccbNode:labelTTFForName("m_lv_lb")
	local m_ab_lb1 = self.m_ccbNode:labelTTFForName("m_ab_lb1")
	local m_ability_sp1 = self.m_ccbNode:spriteForName("m_ability_sp1")
	local m_ab_lb2 = self.m_ccbNode:labelTTFForName("m_ab_lb2")
	local m_ability_sp2 = self.m_ccbNode:spriteForName("m_ability_sp2")
	local m_ab_lb3 = self.m_ccbNode:labelTTFForName("m_ab_lb4")
	local m_ability_sp3 = self.m_ccbNode:spriteForName("m_ability_sp3")

	local itemData,itemCfg = game_data:getEquipDataById(self.m_new_att.id)

	local attrName1,value1,attrName2,value2,icon1,icon2 = game_util:getEquipAttributeValue(itemCfg,itemData.lv,itemData);
	m_ab_lb1:setString("+" .. value1)
	m_ab_lb2:setString("+" .. value2)
    local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon1);
    if tempDisplayFrame then
        m_ability_sp1:setDisplayFrame(tempDisplayFrame);
    end
    local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon2);
    if tempDisplayFrame then
        m_ability_sp2:setDisplayFrame(tempDisplayFrame);
    end

	local build_type = itemData.build_type
	local buildTypeTab = PUBLIC_ABILITY_NAME_TABLE[build_type]

    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(buildTypeTab.icon))
    if tempSpriteFrame then
        m_ability_sp3:setDisplayFrame(tempSpriteFrame)
    end
	m_lv_lb:setString("Lv." .. itemData.lv)
    m_name_lb:setString(itemCfg:getNodeWithKey("name"):toStr())
    m_ab_lb3:setString("+" ..  itemData.build_atts[build_type])
    local icon = game_util:createEquipIcon(itemCfg)
    m_icon_node:removeAllChildrenWithCleanup(true)
    if icon then
    	icon:setScale(0.85)
    	m_icon_node:addChild(icon)
    end
end

function game_equip_build_pop:refreshInfo2()
	local itemData,itemCfg = game_data:getEquipDataById(self.m_new_att.id)

	local m_icon_node2 = self.m_ccbNode:nodeForName("m_icon_node2")
	local m_name_lb2 = self.m_ccbNode:labelTTFForName("m_name_lb2")
	local m_lv_lb2 = self.m_ccbNode:labelTTFForName("m_lv_lb2")
	local m_ab_lb_new1 = self.m_ccbNode:labelTTFForName("m_ab_lb_new1")
	local m_ability_sp_new1 = self.m_ccbNode:spriteForName("m_ability_sp_new1")
	local m_ab_lb_new2 = self.m_ccbNode:labelTTFForName("m_ab_lb_new2")
	local m_ability_sp_new2 = self.m_ccbNode:spriteForName("m_ability_sp_new2")
	local m_ab_lb_new3 = self.m_ccbNode:labelTTFForName("m_ab_lb_new4")
	local m_ability_sp_new3 = self.m_ccbNode:spriteForName("m_ability_sp_new3")


	local attrName1,value1,attrName2,value2,icon1,icon2 = game_util:getEquipAttributeValue(itemCfg,itemData.lv,itemData);
	m_ab_lb_new1:setString("+" .. value1)
	m_ab_lb_new2:setString("+" .. value2)
    local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon1);
    if tempDisplayFrame then
        m_ability_sp_new1:setDisplayFrame(tempDisplayFrame);
    end
    local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon2);
    if tempDisplayFrame then
        m_ability_sp_new2:setDisplayFrame(tempDisplayFrame);
    end



	local icon2 = game_util:createEquipIcon(itemCfg)
	m_icon_node2:removeAllChildrenWithCleanup(true)
    if icon2 then
    	icon2:setScale(0.85)
    	m_icon_node2:addChild(icon2)
    end
	local build_type = itemData.build_type
	local buildTypeTab = PUBLIC_ABILITY_NAME_TABLE[build_type]

    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(buildTypeTab.icon))
    if tempSpriteFrame then
        m_ability_sp_new3:setDisplayFrame(tempSpriteFrame)
    end
	m_lv_lb2:setString("Lv." .. itemData.lv)
    m_name_lb2:setString(itemCfg:getNodeWithKey("name"):toStr())
    m_ab_lb_new3:setString("+" ..  itemData.build_atts[build_type])


	local m_icon_node1 = self.m_ccbNode:nodeForName("m_icon_node1")
	local m_name_lb1 = self.m_ccbNode:labelTTFForName("m_name_lb1")
	local m_lv_lb1 = self.m_ccbNode:labelTTFForName("m_lv_lb1")
	local m_ab_lb_old1 = self.m_ccbNode:labelTTFForName("m_ab_lb_old1")
	local m_ability_sp_old1 = self.m_ccbNode:spriteForName("m_ability_sp_old1")
	local m_ab_lb_old2 = self.m_ccbNode:labelTTFForName("m_ab_lb_old2")
	local m_ability_sp_old2 = self.m_ccbNode:spriteForName("m_ability_sp_old2")

	local attrName1,value1,attrName2,value2,icon1,icon2 = game_util:getEquipAttributeValue(itemCfg,self.m_attr_old.lv,self.m_attr_old);
	m_ab_lb_old1:setString("+" .. value1)
	m_ab_lb_old2:setString("+" .. value2)
    local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon1);
    if tempDisplayFrame then
        m_ability_sp_old1:setDisplayFrame(tempDisplayFrame);
    end
    local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon2);
    if tempDisplayFrame then
        m_ability_sp_old2:setDisplayFrame(tempDisplayFrame);
    end

	local icon1 = game_util:createEquipIcon(itemCfg)
	m_icon_node1:removeAllChildrenWithCleanup(true)
    if icon1 then
    	icon1:setScale(0.85)
    	m_icon_node1:addChild(icon1)
    end
	m_lv_lb1:setString("Lv." .. self.m_attr_old.lv)
    m_name_lb1:setString(itemCfg:getNodeWithKey("name"):toStr())


end


function game_equip_build_pop:createAnim(parentNode)
    local function onAnimSectionEnd1(animNode, theId,theLabelName)
        animNode:playSection(theLabelName)
    end
    local anim = game_util:createBlenderAnim("biankuanghuoyan", 1, true);
    game_anim:playSection(anim, "impact");
    anim:registerScriptTapHandler(onAnimSectionEnd1)
    anim:setPosition(ccp(0,0))
    parentNode:setScaleX(0.75)
    parentNode:addChild(anim)
end

function game_equip_build_pop:refreshUi()
	if self.m_openType == 1 then
		self.m_type_node1:setVisible(true)
		self.m_type_node2:setVisible(false)
		self:refreshInfo1()
		local animNode = self.m_ccbNode:nodeForName("m_anim_node1")
		self:createAnim(animNode)
	elseif self.m_openType == 2 then
		self.m_type_node1:setVisible(false)
		self.m_type_node2:setVisible(true)
		self:refreshInfo2()
		local animNode = self.m_ccbNode:nodeForName("m_anim_node2")
		self:createAnim(animNode)
	end
 	-- self:createContentTable(self.content_node:getContentSize())
end


function game_equip_build_pop:init(t_params)
	t_params = t_params or {}
    self.m_openType = t_params.opentype or 1
    self.m_attr_old = t_params.old_att
    self.m_new_att = t_params.new_att
    self.callback = t_params.callfun
end



function game_equip_build_pop:create(t_params)
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end


return game_equip_build_pop