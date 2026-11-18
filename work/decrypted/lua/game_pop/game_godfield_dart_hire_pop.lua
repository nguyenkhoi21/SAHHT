local game_godfield_dart_hire_pop = {


}

function game_godfield_dart_hire_pop.destroy( self )
	
end

function game_godfield_dart_hire_pop.back( self )
	
end
--[[
	创建ui
]]
function game_godfield_dart_hire_pop.createUi( self )
	local ccbNode = luaCCBNode:create()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 1 then
			if self.enterType ~= "adjust" then
			game_util:addMoveTips({text = "Xin hãy cài đặt trước chiến thuật！"})
			return 
			end
			self:back()
		elseif btnTag == 3 then
			local count = 0
			for k,v in pairs(self.sel_cards_data) do
				count = count +1
			end
			if self.sel_cards_data and count > 0 then
				game_data:setGuildTableCardsData(self.sel_cards_data)
				game_scene:enterGameUi("game_god_adjustment_formation",{gameData = nil,openType = "game_god_adjustment_formation",enterType = self.openType,my_team = self.my_team})
				else
					game_util:addMoveTips({text = "Chọn hero ra trận!"})
			end
		end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_godfield_dart_doubtful_pop.ccbi")
	self.ccbNode = ccbNode
	self.m_root_layer =ccbNode:layerForName("m_root_layer")
	self.own_table_view_node = ccbNode:nodeForName("own_table_view_node")
	self.other_table_view_node = ccbNode:nodeForName("other_table_view_node")
	self.m_ownteam_count = ccbNode:lableTTFForName("m_ownteam_count")
	self.m_guildteam_count = ccbNode:lableTTFForName("m_guildteam_count")
	self.zhenxing_btn = ccbNode:controlButtomForName("zhenxing_btn")
	self.buzhen_btn = ccbNode:controlButtomForName("buzhen_btn")
	self.canzhan_btn = ccbNode:controlButtomForName("canzhan_btn")
	self.zhenxing_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 101 )
	self.canzhan_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 101)
	self.buzhen_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 101)
	local function onTouch( evnetType,x,y )
		if evnetType == "began" then
			return true
			elseif evnetType == "ended" then
		end
	end
	self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 100, true)
	self.m_root_layer:setTouchEnabled(true)
	return ccbNode
end
--[[
	创建自己阵容列表
]]
function game_godfield_dart_hire_pop.createOwnTable( self , viewSize )
	local my_cards = {}
	for k,v in pairs(self.cards_dict) do
		table.insert(my_cards,v)
	end
	local count = #my_cards
	local params = {}
	params.viewSize = viewSize
	params.row = 4
	params.column = 2
	params.direction = kCCScrollViewDirectionVertical
	params.totalItem = count
	params.touchPriority = GLOBAL_TOUCH_PRIORITY - 102
	local itemSize = CCSizeMake(viewSize.width/params.row,viewSize.height/params.column)
	params.newCell = function ( tableView,index )
		local cell = tableView:dequeueCell()
		if cell == nil then
			cell = CCTableViewCell:create()
			local ccbNode = luaCCBNode:create()
			ccbNode:openCCBFile("ccb/ui_godfield_dart_doubtful_icon_.ccbi")
			local m_zdl = ccbNode:lableTTFForName("m_zhandouli")
			m_zdl:setVisible(false)
			ccbNode:setAnchorPoint(ccp(0.5,0.5))
			ccbNode:setPosition(ccp(itemSize.width/2,itemSize.height/2))
			cell:addChild(ccbNode,10,10)
		end
		if cell then
			local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
			local head_node = ccbNode:nodeForName("icon_node")
			local select_sp = ccbNode:spriteForName("select_sprite")
			select_sp:setScale(1.5)
			head_node:removeAllChildrenWithCleanup(true)
			local lv_lab = ccbNode:lableTTFForName("m_lv")
			if index < count then
				local itemData = my_cards[index+1]
				local level = "Lv." .. itemData.lv
				lv_lab:setString(level)
				local itemId = self:lua_string_split(itemData.id) or "4800"
				local itemcfg = gerConfig(game_config_field.character_detail):getNodeWithKey(itemId)
				local imteName = itemConfig:getNodeWithKey("name"):toStr() or ""
				local icon = game_util:createCardIconByCid(itemId,false)
				if icon then
					local tempSize = head_node:getContentSize();
                    tempIcon:setScale(0.8)
                    tempIcon:setPosition(ccp(tempSize.width*0.5+1, tempSize.height*0.5+1))
                    head_node:addChild(tempIcon)
				end
			end
		end
		return cell
	end
	params.itemOnClick = function ( evnetType,index,item )
		if enterType == "ended" then
			local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
			local select_sp = ccbNode:spriteForName("select_sprite")
			local itemData = my_team[index+1]
			local flag,k = game_util:idInTableById(itemData.id,self.m_guild_teamData)
			if flag and k ~= nil then
				select_sp:setVisible(false)
				table.remove(self.m_guild_teamData,k)
				self.sel_cards_data[tostring(itemData.id)] = nil
			else
				select_sp:setVisible(true)
				table.insert(self.m_guild_teamData,k)
				self.sel_cards_data[tostring(itemData.id)] = itemData
			end
			game_data:setGuildTableCardsData(self.m_guild_teamData)
		end
	end
	return TableViewHelpr:create(params)
end

--[[
	创建雇佣列表
]]
function game_godfield_dart_hire_pop.createOthersTable( self , viewSize )
	local count = #self.other_data
	
end
--[[	
	刷新Ui
]]
function game_godfield_dart_hire_pop.refreshUi( self )
	self.own_table_view_node:removeAllChildrenWithCleanup(true)
	self.own_table_view_node:addChild(self:createOwnTable(self.own_table_view_node:getContentSize()))
end
--[[
	初始化数据
]]
function game_godfield_dart_hire_pop.init( self,t_params )
	t_params = t_params or {}
	self.employed = game_data:getUserStatusDataByKey("employed") or {};
	self.m_tGameData = {}
	self.cards_data = {}
	if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
		local data = t_params.gameData:getNodeWithKey("data")
		self.m_tGameData = json.decode(data:getNodeWithKey("guild_employ"):getFormatBuffer()) or {}
		self.cards_data = json.decode(data:getNodeWithKey("cards_dict"):getFormatBuffer()) or {}
		game_data:setGuildTableCardsData(self.m_tGameData)
		self.guild_employ = self.m_tGameData.guild_employ
		cclog2(self.m_tGameData,"self.m_tGameData")
		cclog2(self.cards_dict,"self.cards_dict")
	end
	self.my_uid = game_data:getUserStatusDataByKey("uid") or nil
	self.other_data = {}
	self.other_id = {}
	if self.guild_employ then
		for k,v in pairs(self.guild_employ) do
			if k == self.my_uid then return end
			table.insert(self.other_data,v)
			self.other_id[#self.other_id+1] = k
		end
	end
	self.m_guild_teamData = t_params.m_guild_teamData or {}
	self.m_guild_other_teamData = {}
	self.enterType = t_params.enterType or ""
	self.openType = t_params.open or ""
	if self.openType == "escort" then
		self.my_team = t_params.my_team
		cclog2(self.my_team,"self.my_team     escort_team")
	elseif self.openType == "rob" then
		self.my_team = t_params.my_team or {}
		if self.my_team.vehicle_captain_uid == nil then
			--打劫飞船uid
			self.my_team.vehicle_captain_uid = t_params.vehicle_captain_uid  
		end
		--打劫所用神域阵型
		self.my_team.squad = self.my_team.squad or 1  
		cclog2(self.my_team,"self.my_team     rob_team")
	end
	if self.enterType == "adjust" and t_params.temp then
		self.my_team = t_params.my_team
		self.formation_id = t_params.formation_id
		self.teamData = t_params.temp
		cclog2(self.teamData,"self.teamData_______adjust")
		self.params_align_1 = ""
		for i=1,5 do
			self.params_align_1 = self.params_align_1 .. self.teamData[i] .. (i==5 and "" or "_")
		end
		for k=6,10 do
			if self.teamData[k] == nil then
                self.params_align_1 = self.params_align_1 .. "-1" .. (k == 10 and "" or "_") 
            else
                self.params_align_1 = self.params_align_1 .. self.teamData[k] .. (k == 10 and "" or "_") 
            end
		end
		self.other_team_data = ""
		if self.teamData then
			for i=1,#self.teamData do
				for j=1,#other_data do
					local cards = other_data[j].cards
					for k,v in pairs(cards) do
						if self.teamData[i] == k then
							self.other_team_data = self.other_team_data .. "&employ_cards=" .. k .. self.other_id[j]
						end
					end
				end
			end
		end
	end
end
--[[
	创建入口并初始化数据
]]
function game_godfield_dart_hire_pop.create( self,t_params )
	self:init(t_params)
	self.m_popUi = self:createUi()
	self:refreshUi()
	return self.m_popUi
end

return game_godfield_dart_hire_pop