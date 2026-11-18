-- 团队副本   结果
local game_teamRaid_result_pop = {
	m_selectPage = nil,
    m_down_btn = nil,
    m_refresh_btn = nil,
    m_up_btn = nil,
    m_cards_list_node = nil,
    m_team_list_node = nil,
    m_root_layer = nil,
    m_role_node = nil,
    m_card_node = nil,
    m_team_number = nil,
    m_ccbNode = nil,
    m_selectItem = nil,
    m_selectIndex = nil,
    m_showCurPage = nil,
    m_team_list = nil,
    m_tGameData = nil,
    m_EnterFlag = nil,
    m_EnterType = nil,
}

function game_teamRaid_result_pop:destroy(  )
	-- body
    cclog("  --------------  game_teamRaid_result_pop  destroy  -----------------  ")
    self.m_selectPage = nil;
    self.m_down_btn = nil;
    self.m_refresh_btn = nil;
    self.m_up_btn = nil;
    self.m_cards_list_node = nil;
    self.m_team_list_node = nil;
    self.m_root_layer = nil;
    self.m_role_node = nil;
    self.m_card_node = nil;
    self.m_team_number = nil;
    self.m_ccbNode = nil;
    self.m_selectItem = nil;
    self.m_selectIndex = nil;
    self.m_showCurPage = nil;
    self.m_team_list = nil;
    self.m_tGameData = nil;
    self.m_EnterFlag = nil;
    self.m_EnterType = nil;
end

function game_teamRaid_result_pop:back(  )
    	-- body
	local function responseMethod( tag, gameData )
        if gameData then
            game_scene:enterGameUi("game_teamRaid_main",{gameData = gameData,enterFlag = self.m_EnterFlag})
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_index"), http_request_method.GET, nil,"team_raid_index")
end

function game_teamRaid_result_pop:createUi(  ) -- test_touch
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();

    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_teamRaid_result_pop.ccbi");

	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            self:back()
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    self.m_root_layer:setTouchEnabled(true);

    self.m_result_node1 = ccbNode:nodeForName("m_result_node1")
    self.m_result_node2 = ccbNode:nodeForName("m_result_node2")

    self.m_ccbNode = ccbNode;
    return ccbNode
end



function game_teamRaid_result_pop:refreshUi(  )
	-- body
	local is_success = self.m_tGameData.is_success or 2
	self.m_result_node1:setVisible(is_success == 1)
	self.m_result_node2:setVisible(is_success == 2)
end



function game_teamRaid_result_pop:init( t_params )
	-- body
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res_add.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");

    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
       local data = t_params.gameData:getNodeWithKey("data")
       self.m_tGameData = json.decode(data:getFormatBuffer())
    end
    self.m_EnterFlag = t_params.enterFlag or 2
    self.m_EnterType = t_params.enterType or ""
end

function game_teamRaid_result_pop:create( t_params )
	-- body
	self:init(t_params)
	local pop = self:createUi()
	self:refreshUi()
	return pop
end

return game_teamRaid_result_pop