--- 装备列表 

local ui_role_propertryUp = {
	m_back_btn = nil,
	m_list_view_bg = nil,
	role_attri_add_cfg = nil,
	m_ok_btn = nil,
	m_lv_lab = nil, --属性等级
	m_roleLv_lab = nil,--需要玩家的等级
	m_consume_lab = nil,--消耗钻石数
	m_propertry_tab = nil,
	role_attri_level = nil,--玩家当前的属性等级
	m_anim_node = nil,
	m_countTab_num = nil,
	m_role_Lv = nil, -- 玩家当前等级
	m_cell_tab = nil,
	m_anim_flag = nil,
	m_anim_layer = nil,
	m_needNight_lab = nil,
    m_needNight_node = nil,
};
--[[--
    销毁ui
]]
function ui_role_propertryUp.destroy(self)
	self.m_back_btn = nil;
	self.m_list_view_bg = nil;
	self.role_attri_add_cfg = nil;
	self.m_ok_btn = nil;
	self.m_lv_lab = nil;
	self.m_roleLv_lab = nil;
	self.m_consume_lab = nil;
	self.m_propertry_tab = nil;
	self.role_attri_level = nil;
	self.m_anim_node = nil;
	self.m_countTab_num = nil;
	self.m_role_Lv = nil;
	self.m_cell_tab = nil;
	self.m_anim_flag = nil;
	self.m_anim_layer = nil;
	self.m_needNight_lab = nil;
    self.m_needNight_node = nil;

end
--[[--
    返回
]]
function ui_role_propertryUp.back(self,type)
    game_scene:enterGameUi("game_main_scene");
end
--[[--
    读取ccbi创建ui
]]
function ui_role_propertryUp.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
        		self:back()
        elseif btnTag == 101 then--升级
        	local function responseMethod(tag,gameData)
        		-- cclog2(gameData,"gameData --- ")
        		if gameData ~= nil and tolua.type(gameData) == "util_json" then
        		    local temp = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
        		    self.role_attri_level = temp.role_attri_level
        		    self:SuccessAnim()
        		end
        	end
	    	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_role_attri_level_up"), http_request_method.GET, nil,"cards_role_attri_level_up")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_upLevel.ccbi");
   	self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
   	self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg")
	self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
	self.m_lv_lab = ccbNode:labelTTFForName("m_lv_lab");
	self.m_roleLv_lab = ccbNode:labelTTFForName("m_roleLv_lab");
	self.m_consume_lab = ccbNode:labelTTFForName("m_consume_lab");
	self.m_needNight_lab = ccbNode:labelTTFForName("m_needNight_lab");
	self.m_anim_layer = ccbNode:layerForName("m_anim_layer")
    self.m_needNight_node = ccbNode:nodeForName("m_needNight_node")
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScale(resolution_config:getScale())

	self.m_propertry_tab = {}
	local m_propertry_lab = nil;
	for i=1,5 do
		m_propertry_lab = ccbNode:labelTTFForName("m_propertry_lab" .. i)
		self.m_propertry_tab[i] = {m_propertry_lab = m_propertry_lab}
	end

   	self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_anim_node:removeAllChildrenWithCleanup(true);
   	local userStatusData = game_data:getUserStatusData();
   	self.m_role_Lv = userStatusData.level
   	local role_detail_cfg = getConfig(game_config_field.role_detail);
    local role = userStatusData.role;
    if  userStatusData.role_attri_level then
    	self.role_attri_level = userStatusData.role_attri_level
    else
    	self.role_attri_level = 0
    end
    if role and role_detail_cfg then
        local itemCfg = role_detail_cfg:getNodeWithKey(tostring(role));
        local temp_big_img = CCSprite:create("humen/" .. itemCfg:getNodeWithKey("img"):toStr() .. ".png");
        temp_big_img:setAnchorPoint(ccp(0.5, 0));
        temp_big_img:setScale(0.375);
        if temp_big_img then
            self.m_anim_node:addChild(temp_big_img)
        end
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
        	if self.m_anim_flag == false then
        		return false
        	else
        		return true
        	end
        end
    end
    self.m_anim_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-15,true);
    self.m_anim_layer:setTouchEnabled(true);
    self.m_anim_layer:setVisible(true)
    return ccbNode;
end
function ui_role_propertryUp.SuccessAnim( self )
	self.m_anim_flag = true
    self.m_anim_layer:setVisible(true)
	local function particleMoveEndCallFunc()
		if self.m_cell_tab[self.m_countTab_num-self.role_attri_level+1] then
			local function sectionEnd( animNode, theId, theLabelName )
			    if theLabelName == "impact" then
			    	self.m_cell_tab = {}
			    	game_util:addMoveTips({text = "Đã tăng thuộc tính"})
			    	self:refreshUi()
			    end
			end
			local m_zjrAnim = game_util:createAnimEffect("anim_ui_jiacheng","anim_ui_jiacheng",sectionEnd);
			if m_zjrAnim then
			    local tempsize = self.m_cell_tab[self.m_countTab_num-self.role_attri_level+1]:getContentSize()
			    m_zjrAnim:setAnchorPoint(ccp(0,0));
			    m_zjrAnim:setPosition(ccp(0,0));
			    game_anim:playSection(m_zjrAnim,"impact")
			    self.m_cell_tab[self.m_countTab_num-self.role_attri_level+1]:addChild(m_zjrAnim,100)
			end
		else
			self.m_anim_flag = false
		end
	end
	local animFile = "anim_icon_disappear"
	local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
	if mAnimNode then
	    local tempParticle = game_util:createParticleSystemQuad({fileName = "particle_fly_up"});
	    if tempParticle then
	        game_util:addMoveAndRemoveAction({node = tempParticle,startNode = self.m_ok_btn,endNode = self.m_anim_node,endCallFunc = particleMoveEndCallFunc,moveTime = 0.5,delayTime = 0.5})
	        game_scene:getPopContainer():addChild(tempParticle)
	    end
	end
end
function ui_role_propertryUp.createTableView( self,viewSize )
	local attNameTab = {"Vật công","Ma công","Phòng ngự","Tốc độ","HP"}
    local cardsCount = self.m_countTab_num
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = cardsCount
    params.itemActionFlag = true;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_propertry_item.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
        	self.m_cell_tab[index+1] = cell
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_propertry_lv_lab = ccbNode:labelTTFForName("m_propertry_lv_lab")
            local m_property_lab1 = ccbNode:labelTTFForName("m_property_lab1")
            local m_property_lab2 = ccbNode:labelTTFForName("m_property_lab2")
            local m_dwan_layer = ccbNode:spriteForName("m_dwan_layer")
            local m_alreadyUp_sp = ccbNode:spriteForName("m_alreadyUp_sp")
            if cardsCount-index == self.role_attri_level then
            	m_dwan_layer:setOpacity(0)
            	m_alreadyUp_sp:setVisible(true)
            elseif cardsCount-index<self.role_attri_level then
            	m_dwan_layer:setOpacity(0)
            	m_alreadyUp_sp:setVisible(true)
            elseif cardsCount-index>self.role_attri_level then
            	local needLv = self.role_attri_add_cfg[tostring(cardsCount-index)].need_level
            	if self.m_role_Lv >= needLv then
            		m_dwan_layer:setOpacity(0)
            	elseif self.m_role_Lv < needLv then 
            		m_dwan_layer:setOpacity(150)
            	end
            	m_alreadyUp_sp:setVisible(false)
            end
            local tempTab = self.role_attri_add_cfg[tostring(cardsCount-index)].skill_add_level
            m_propertry_lv_lab:setString("Lv" .. cardsCount-index)
            local value1,value2 = 0
            local des1,des2 = ""
            value1 = tempTab[1][2]
            des1 = attNameTab[tempTab[1][1]]
            value2 = tempTab[2][2]
            des2 = attNameTab[tempTab[2][1]]
            m_property_lab1:setString(des1 .. "+" .. value1)
            m_property_lab2:setString(des2 .. "+" .. value2)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then

        end
    end
    return TableViewHelper:create(params);
end
function ui_role_propertryUp.getPropertryFromConfig( self,id )
	local tempPropertyTab1 = {}
	local tempPropertyTab2 = {}
	local selectTab1 = {}
	local realTab = {}
	if id == 1 then 
		realTab = self.role_attri_add_cfg["1"]
	else
		tempPropertyTab1 = self.role_attri_add_cfg[tostring(id-1)].skill_add
		tempPropertyTab2 = self.role_attri_add_cfg[tostring(id)].skill_add
		for k,v in pairs(tempPropertyTab1) do
			selectTab1[tostring(v[1])] = v[2]
		end
		for k,v in pairs(tempPropertyTab2) do
			if selectTab1[tostring(v[1])] == v[2] then 
			else
				table.insert(realTab,v)
			end
		end
	end
	return realTab
end
function ui_role_propertryUp.refreshLabel( self )
	local countTab = {}
	for k,v in pairs(self.role_attri_add_cfg) do
		table.insert(countTab,k)
	end
	local maxLv = #countTab
	self.m_countTab_num = #countTab
	self.m_lv_lab:setString(tostring(self.role_attri_level));
	local nextLv = 0
	if tonumber(self.role_attri_level) == maxLv then
		self.m_roleLv_lab:setString("--");
		self.m_consume_lab:setString("--");
		self.m_needNight_lab:setString("--")
	else 
		nextLv = self.role_attri_level+1
		local needLv = 0
		needLv = self.role_attri_add_cfg[tostring(nextLv)].need_level
		local needCoin = 0
		needCoin = self.role_attri_add_cfg[tostring(nextLv)].cost_coin
		self.m_roleLv_lab:setString(tostring(needLv));
		self.m_consume_lab:setString(tostring(needCoin));
		local neednight = nil
		neednight = self.role_attri_add_cfg[tostring(nextLv)].fight_level
		if neednight and neednight >= 0 then
			self.m_needNight_node:setVisible(true)
			self.m_needNight_lab:setString(tostring(neednight))
		else
			self.m_needNight_node:setVisible(false)
		end
	end
	local tempPropertyTab = {}
	for i=1,5 do
		self.m_propertry_tab[i].m_propertry_lab:setString("+0")
	end
	if self.role_attri_level > 0 then
		tempPropertyTab = self.role_attri_add_cfg[tostring(self.role_attri_level)].skill_add
		for k,v in pairs(tempPropertyTab) do
			self.m_propertry_tab[v[1]].m_propertry_lab:setString("+" .. tostring(v[2]))
		end
	end
end
--[[--
    刷新ui
]]
function ui_role_propertryUp.refreshUi(self)
	self:refreshLabel()
	self.m_list_view_bg:removeAllChildrenWithCleanup(true)
	local viewSize = self.m_list_view_bg:getContentSize()
	self.m_list_view_bg:addChild(self:createTableView(viewSize),10,10)

	local current_index = 0
	local index =  self.m_countTab_num - self.role_attri_level
	if index < 5 then
	 	current_index = 0
	elseif index >= 5 and index <= 10 then
		current_index = index-2

	elseif index > 10 and index <= 15 then
		current_index = index-5
	elseif index > 15 and index <= 20 then
		current_index = index-5
	end
	local function endDelay( )
		game_util:setTableViewIndex(current_index,self.m_list_view_bg,10,5)
		self.m_anim_flag = false
	end
	local arr = CCArray:create();
	arr:addObject(CCDelayTime:create(0.75));
	arr:addObject(CCCallFuncN:create(endDelay));
	self.m_list_view_bg:runAction(CCSequence:create(arr))
end
--[[--
    初始化
]]
function ui_role_propertryUp.init(self,t_params)
    t_params = t_params or {};
	self.m_cell_tab = {} 
	self.m_anim_flag = false
	self.role_attri_add_cfg = json.decode(getConfig(game_config_field.role_attri_add):getFormatBuffer())
end
--[[--
    创建ui入口并初始化数据
]]
function ui_role_propertryUp.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return ui_role_propertryUp;