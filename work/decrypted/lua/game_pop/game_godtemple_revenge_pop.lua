local game_godtemple_revenge_pop = {
	m_tGameData = nil,
	m_get_btn = nil,
	m_close_btn = nil,
	m_root_layer = nil,
	m_des_lab = nil,

};
function game_godtemple_revenge_pop.destroy( self )
	self.m_tGameData = nil;
	self.m_get_btn = nil;
	self.m_close_btn = nil;
	self.m_root_layer = nil;
	self.m_des_lab = nil;

end
function game_godtemple_revenge_pop.back( self )
	local function responseMethod( tag,gameData )
		game_scene:enterGameUi("game_godtemple_revenge",{gameData = gameData})
	end
	local params = {}
	params.is_reap = 0
	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_temple_index"), http_request_method.GET, params,"god_field_temple_index")
	-- body
end
function game_godtemple_revenge_pop.createUi( self )
	local ccbNode = luaCCBNode:create()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
		local btnTag = tagNode:getTag()
		if btnTag == 101 then
			self:back()
		elseif btnTag == 102 then
			local function responseMethod( tag,gameData )
				local data = gameData:getNodeWithKey("data");
				data = json.decode(data:getFormatBuffer()) or {};
				local data2 = {}
				local alignment_info = data.enemy_alignment_info
				local god_field_ids = data.god_field_ids
				data2 = {alignment_info = alignment_info,god_field_ids = god_field_ids}
                game_scene:enterGameUi("game_godfield_battle_big",{gameData = data2,data1 = data,opentype = "godtemple"})
			end
			local params = {}
			local uid = self.m_tGameData.object_id
			local uidType = string.sub(uid,1,5)
			if uidType == "robot" then
				params.enemy_id = "robot_x"
				params.enemy_team = 0
			else
				params.enemy_id = tostring(uid)
				params.enemy_team = tonumber(self.m_tGameData.object_team)
			end
			params.is_revenge = 1
			params.user_team = self.m_tGameData.my_team
			params.temple_level = self.m_tGameData.temple_level
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_temple_contend_temple"), http_request_method.GET, params,"god_field_temple_contend_temple")
		end

		-- body
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick);
	ccbNode:openCCBFile("ccb/ui_godtemple_revenge_pop.ccbi");
	self.m_get_btn = ccbNode:controlButtonForName("m_get_btn")
	self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
	self.m_root_layer = ccbNode:layerForName("m_root_layer")
	self.m_des_lab = ccbNode:labelTTFForName("m_des_lab")
	return ccbNode;
	-- body
end
function game_godtemple_revenge_pop.refreshUi( self )
	local des = "Bạn bị" .. self.m_tGameData.object_name .. "đánh bại, trả thù không?"
	self.m_des_lab:setString(des)
end
function game_godtemple_revenge_pop.init( self,t_params )
	self.m_tGameData = t_params or {}
	self.m_reward_tab = {}
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
   	elseif t_params.gameData ~= nil and tolua.type(t_params.gameData) == "table" then
   		self.m_tGameData = t_params.gameData
    else
        self.m_tGameData = {};
    end
	-- body
end
function game_godtemple_revenge_pop.create( self,t_params )
	self:init(t_params)
	local scene = CCScene:create()
	scene = self:createUi()
	self:refreshUi()
	return scene
	-- body
end
return game_godtemple_revenge_pop