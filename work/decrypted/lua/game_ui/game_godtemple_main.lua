local game_godtemple_main = {
	m_tGameData = nil,
	m_getTeam_btn = nil,
	m_revenge_btn = nil,
	m_ui_tab = nil,
	m_temple_number = nil,
};
function game_godtemple_main.destroy( self )
	self.m_tGameData = nil;
	self.m_getTeam_btn = nil;
	self.m_revenge_btn = nil;
	self.m_ui_tab = nil;
	self.m_temple_number = nil;
end
function game_godtemple_main.back( self )
	game_scene:enterGameUi("game_godfield_mainBig")
	-- body
end
function game_godtemple_main.createUi( self )
	local ccbNode = luaCCBNode:create()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
		local btnTag = tagNode:getTag()
		if btnTag == 1 then
			self:back()
		elseif btnTag <= 103 and btnTag >= 101  then

			local function responseMethod( tag,gameData )
				local screenShoot = game_util:createScreenShoot();
				screenShoot:retain();
				local function endCallFunc( )
				    screenShoot:release();
				end
				game_scene:enterGameUi("game_godtemple_goTeam",{gameData = gameData,screenShoot = screenShoot,showType = btnTag-100},{endCallFunc = endCallFunc})
			end
			local params = {}
			params.is_reap = 0
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_temple_index"), http_request_method.GET, params,"god_field_temple_index")
		elseif btnTag == 104 then
			
			local function responseMethod( tag,gameData )
				local screenShoot = game_util:createScreenShoot();
				screenShoot:retain();
				local function endCallFunc( )
					screenShoot:release();
				end

				game_scene:enterGameUi("game_godtemple_getTeam",{gameData = gameData,screenShoot = screenShoot},{endCallFunc = endCallFunc})
			end
			local params = {}
			params.is_reap = 0
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_temple_index"), http_request_method.GET, params,"god_field_temple_index")
		elseif btnTag == 105 then
			local function responseMethod( tag,gameData )
				game_scene:enterGameUi("game_godtemple_revenge",{gameData = gameData})
			end
			local params = {}
			params.is_reap = 0
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_temple_index"), http_request_method.GET, params,"god_field_temple_index")
		end

		-- body
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick);
	ccbNode:openCCBFile("ccb/ui_godtemple_main.ccbi");
	self.m_getTeam_btn = ccbNode:controlButtonForName("m_getTeam_btn")
	local m_get_btn,m_combat_lab
	self.m_ui_tab = {}
	for i=1,3 do
		m_get_btn = ccbNode:controlButtonForName("m_get_btn" .. i)
		m_combat_lab = ccbNode:labelTTFForName("m_combat_lab" .. i)
		self.m_ui_tab[i] = {m_get_btn = m_get_btn,m_combat_lab = m_combat_lab}
	end
	self.m_revenge_btn = ccbNode:controlButtonForName("m_revenge_btn")
	return ccbNode;
	-- body
end
function game_godtemple_main.goReward( self )
	self.m_reward_tab  = game_util:rewardTipsByDataTableShow(self.m_tGameData.products)
	-- cclog2(self.m_reward_tab,"aaaa")
	if next(self.m_tGameData) and next(self.m_tGameData.products) then
		game_scene:addPop("game_temple_rewardPop",{gameData = self.m_tGameData,openType = "templeMain"})
	end
	-- body
end
function game_godtemple_main.goRevenge( self )
	-- if self.m_tGameData and 
	-- body
end
function game_godtemple_main.refreshUi( self )
	if self.m_tGameData and self.m_tGameData.products then
		self:goReward()
	end
	for i=1,3 do
		local des = self.m_temple_number[tostring(i)].temple_battle_need
		self.m_ui_tab[i].m_combat_lab:setString(des)
	end

end
function game_godtemple_main.init( self,t_params )
	self.m_tGameData = t_params or {}
	self.m_reward_tab = {}
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    -- cclog2(self.m_tGameData,"main m_tGameData === ")
    self.m_temple_number = getConfig(game_config_field.temple_number)
    self.m_temple_number = json.decode(self.m_temple_number:getFormatBuffer()) or {};

	-- body
end
function game_godtemple_main.create( self,t_params )
	self:init(t_params)
	local scene = CCScene:create()
	scene = self:createUi()
	self:refreshUi()
	return scene
	-- body
end
return game_godtemple_main