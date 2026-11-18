-- 星宫仇人
local game_god_enemy_pop = {
	m_tGameData = nil,
	check = nil,
	list_node = nil,
	reward_list = nil,
	no_reward = nil,
	my_pos_node = nil,
	no_pos = nil,
	L_title = nil,
}
function game_god_enemy_pop:destroy()
	cclog("-----------game_god_enemy_pop destroy--------------")
	self.m_tGameData = nil;
	self.check = nil;
	self.list_node = nil;
	self.reward_list = nil;
	self.no_reward = nil;
	self.my_pos_node = nil;
	self.no_pos = nil;
	self.L_title = nil;
end

function game_god_enemy_pop:back()
	game_scene:removePopByName("game_god_enemy_pop")
end

function game_god_enemy_pop:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 1 then
			self:back()
		end
	end
	local ccbNode = luaCCBNode:create()
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_Star_enemy_list.ccbi")
	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	self.m_node_enemylist = ccbNode:nodeForName("m_node_enemylist")
	self.m_msg_node = ccbNode:nodeForName("m_msg_node")
	self.m_name_lable = ccbNode:labelTTFForName("name_lable")
	self.m_qufu_lable = ccbNode:labelTTFForName("qufu_lable")
	self.m_lv_lable = ccbNode:labelTTFForName("lv_lable")
	self.m_union_lable = ccbNode:labelTTFForName("union_lable")
	self.m_pos_node1 = ccbNode:nodeForName("m_pos_node1")
	self.m_pos_node2 = ccbNode:nodeForName("m_pos_node2")
	self.m_pos_node3 = ccbNode:nodeForName("m_pos_node3")
	self.pos_sp_2 = ccbNode:spriteForName("pos_sp_2")
	self.pos_sp_3 = ccbNode:spriteForName("pos_sp_3")
	self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
	self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10000);
	self.m_msg_node:setVisible(false)
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-9999,true);
    self.m_root_layer:setTouchEnabled(true);
	return ccbNode
end
function game_god_enemy_pop:createTableView( viewSize )
	local params = {}
	local count = game_util:getTableLen(self.m_enemy_list) 
	params.viewSize = viewSize
	params.row = 6
	params.column = 1
	params.touchPriority = GLOBAL_TOUCH_PRIORITY - 10000
	params.totalItem = #self.m_enemy_list
	params.direction = kCCScrollViewDirectionHorizontal
	local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row)
	params.newCell = function ( tableView,index )
		local itemCfg = self.m_enemy_list[index + 1]
		if itemCfg == nil then return end
		local cell = tableView:dequeueCell()
		if cell == nil then
			cell = CCTableViewCell:new()
			cell:autorelease()
			local ccbNode = luaCCBNode:create()
			ccbNode:openCCBFile("ccb/ui_godfield_Star_enemy_list_item.ccbi")
			if ccbNode == nil then return end
			ccbNode:setScale(1)
			ccbNode:setAnchorPoint(ccp(0.5,0.5))
			ccbNode:setPosition(ccp(20,itemSize.height*0.5))
			cell:addChild(ccbNode,10,10)
		end
		if cell then
			local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
			if ccbNode then
				local name_lable = ccbNode:labelTTFForName("m_name_lb")
				local icon_node = ccbNode:nodeForName("icon_node")
				name_lable:setString(itemCfg.name)
     			local humen_role = json.decode(self.role_detail:getNodeWithKey(tostring(itemCfg.role)):getFormatBuffer())
				local icon_sp = CCSprite:create("humen/" .. humen_role.icon .. "_b.png")
				if icon_sp then
					icon_sp:setPosition(ccp(0,0))
					icon_sp:setScale(0.6)
					icon_node:addChild(icon_sp)
				end
			end
		end
		return cell
	end
	params.itemOnClick = function ( eventType,index,item )
		if eventType == "began" then
			return
		elseif eventType == "ended" then
			self.check = index + 1
			self:refreshMsg()
		end
	end
	return TableViewHelper:create(params); 
end


function game_god_enemy_pop:refreshMsg()
	local function responseMethod(tag,gameData)
		if gameData and tolua.type(gameData) == "util_json" then
			local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or nil
			if data then
				self.m_msg_node:setVisible(true)
				self.m_name_lable:setString(data.name)
				self.m_qufu_lable:setString(data.server_name)
				self.m_lv_lable:setString(data.level)
				self.m_union_lable:setString(data.guild)
				self:createEnemyPos(data.teams)
			end
		end
    end
    local params = {}
    if self.check == 0 then return end
    params.enemy_id = self.m_enemy_list[self.check].uid
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("enemy_info"), http_request_method.GET, params,"enemy_info")
end


function game_god_enemy_pop:createEnemyPos(pos_data)
	local list = {}
	for i=1,3 do
		if pos_data[tostring(i)].floor ~= 0 then
			table.insert(list,pos_data[tostring(i)])
		end
	end
	if list[1] then
		local posCfg = list[1]
		local pos = GOD_STAR_BTN_ICON[posCfg.floor].name
		local tempLabel = game_util:createLabelTTF({text = pos,color = ccc3(255,255,255),fontSize = 12});
		tempLabel:setPosition(ccp(0,0))
		self.m_pos_node1:addChild(tempLabel)
	end	
	if list[2] then
		self.pos_sp_2:setVisible(true)
		local posCfg = list[2]
		local pos = GOD_STAR_BTN_ICON[posCfg.floor].name
		local tempLabel = game_util:createLabelTTF({text = pos,color = ccc3(255,255,255),fontSize = 12});
		tempLabel:setPosition(ccp(0,0))
		self.m_pos_node2:addChild(tempLabel)
	else
		self.pos_sp_2:setVisible(false)
	end
	if list[3] then
		self.pos_sp_3:setVisible(true)
		local posCfg = list[3]
		local pos = GOD_STAR_BTN_ICON[posCfg.floor].name
		local tempLabel = game_util:createLabelTTF({text = pos,color = ccc3(255,255,255),fontSize = 12});
		tempLabel:setPosition(ccp(0,0))
		self.m_pos_node3:addChild(tempLabel)
	else
		self.pos_sp_3:setVisible(false)
	end	
	-- for i=1,#list do

	-- 	local posCfg = list[i]
	-- 	local pos = GOD_STAR_BTN_ICON[posCfg.floor].name
	-- 	local tempLabel = game_util:createLabelTTF({text = pos,color = ccc3(255,255,255),fontSize = 12});
	-- 	tempLabel:setPosition(ccp(viewSize.width/2,viewSize.height*(1-1/3*i+0.16)))
	-- 	self.m_pos_node:addChild(tempLabel)
	-- end
end


function game_god_enemy_pop:refreshUi( )
	self.m_node_enemylist:removeAllChildrenWithCleanup(true)
	self.m_node_enemylist:addChild(self:createTableView(self.m_node_enemylist:getContentSize()))
	self:refreshMsg()
end


function game_god_enemy_pop:init( t_params )
	self.role_detail = getConfig(game_config_field.role_detail);
	t_params = t_params or {}
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
		local data = t_params.gameData:getNodeWithKey("data")
		self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
	end
	
	self.m_enemy_list = {}
	for  k,v in pairs(self.m_tGameData) do
		if k ~= "_client_cache_update" then
			table.insert( self.m_enemy_list, v)
		end
	end
	if #self.m_enemy_list > 0 then
		self.check = 1
	else
		self.check = 0
	end
end

function game_god_enemy_pop:create( t_params )
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end

return game_god_enemy_pop