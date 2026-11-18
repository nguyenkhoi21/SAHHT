
-- 拆机大玩家
local ui_super_player_envelope = {
	m_root_layer = nil,
	m_btn_back = nil,
    callback = nil,
    m_rank_node = nil,
    m_time_node = nil,
    m_bag_time_node = nil,
    m_bag_info = nil,
    m_tGameData = nil,
} 

function ui_super_player_envelope:destroy( )
    cclog("   -------  ui_super_player_envelope   ----------     destroy  -------")
	self.m_root_layer = nil;
	self.m_btn_back = nil;
    self.callback = nil;
    self.m_rank_node = nil;
    self.m_time_node = nil;
    self.m_bag_time_node = nil;
    self.m_bag_info = nil;
    self.m_tGameData = nil;
end



function ui_super_player_envelope:back()
    if self.callback then
        self.callback()
    end
	game_scene:removePopByName("ui_super_player_envelope")
end



function ui_super_player_envelope:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 1 then
			self:back()
		elseif btnTag == 102 then
		end
	end
	local ccbNode =  luaCCBNode:create();
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_super_player_envelope002.ccbi")
	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	self.m_btn_back = ccbNode:controlButtonForName("btn_back")
	self.m_rank_node = ccbNode:nodeForName("m_rank_node")
    self.m_time_node = ccbNode:nodeForName("m_time_node")
    self.m_bag_time_node = ccbNode:nodeForName("m_bag_time_node")
    self.m_bag_times = ccbNode:labelTTFForName("m_bag_times")
	self.m_btn_back:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)

	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    self.m_root_layer:setTouchEnabled(true);
	return ccbNode

end


function ui_super_player_envelope:createTableView(viewSize)
	local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode")
        local btnTag = tagNode:getTag()
        cclog(" btnTag  -------->>>>>>>   " .. btnTag)
                local function responseMethod(tag,gameData)
            if gameData and tolua.type(gameData) == "util_json" then
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                -- cclog2(self.m_tGameData,"self.m_tGameData   ------ >>>>>>>>>>>>>")
                self.m_bag_info = self.m_tGameData.redbag_info
                game_util:rewardTipsByDataTable(self.m_tGameData.reward)
                self:refreshUi()
            end
        end
        local data = self.m_bag_info[btnTag]
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_player_grab_bag"), http_request_method.GET, {bag_code = data.red_code},"super_player_grab_bag")
    end
    local params = {}
    params.viewSize = viewSize
    params.column = 1
    params.row = 4
    params.direction = kCCScrollViewDirectionVertical
    params.totalItem = game_util:getTableLen(self.m_bag_info)
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row)
    params.newCell = function( tableView,index )
        local cell = tableView:dequeueCell()
        local itemcfg = self.m_bag_info[tostring(index+1)] or self.m_bag_info[index + 1]
        if cell == nil then
            cell=CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
            ccbNode:openCCBFile("ccb/ui_super_player_envelope_item001.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(5,itemSize.height/2))
            cell:addChild(ccbNode,101,101)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(101),"luaCCBNode")
            local m_name = ccbNode:labelTTFForName("m_name")
            local m_server = ccbNode:labelTTFForName("m_server")
            local m_rob_btn = ccbNode:controlButtonForName("m_rob_btn")
            m_rob_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-7)
            m_rob_btn:setTag(index+1)
            m_server:setString(itemcfg.server_name or "")
            m_name:setString(itemcfg.name .. "lì xì lời chúc!!!")
        end
        return cell
    end
    params.itemOnClick=function (eventType,index,item )
    end
    return TableViewHelper:create(params)
end

function ui_super_player_envelope:refreshPage()
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        -- cclog2(self.m_tGameData,"self.m_tGameData   ------ >>>>>>>>>>>>>")
        self.m_bag_info = self.m_tGameData.redbag_info
        self:refreshUi()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_player_get_bag_code"), http_request_method.GET, nil,"super_player_get_bag_code")
end

function ui_super_player_envelope:createTimer()
    local server_time = game_data:getUserStatusDataByKey("server_time")
    cclog2(server_time,"server_time")
    if server_time > self.m_tGameData.grep_time then
        self.m_bag_time_node:setVisible(false)
        return 
    else
        self.m_bag_time_node:setVisible(true)
    end
    local time = self.m_tGameData.grep_time - server_time
    local function timeEndFunc(label,type)
        self:refreshPage()
    end
    self.m_time_node:setVisible(true)
    local countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8);
    countdownLabel:setPosition(ccp(0,0))
    if self.m_time_node ~= nil then
        self.m_time_node:removeAllChildrenWithCleanup(true)
    end
    self.m_time_node:addChild(countdownLabel)
    countdownLabel:setTime(time + 1);
end


function ui_super_player_envelope:refreshUi()
    self.m_rank_node:removeAllChildrenWithCleanup(true)
	self.m_rank_node:addChild(self:createTableView(self.m_rank_node:getContentSize()))
	self.m_rank_node:setVisible(true)
    self.m_bag_times:setString(self.m_tGameData.can_receive_times)
    self:createTimer()
end


function ui_super_player_envelope:init(t_params)
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};    
        -- cclog2(self.m_tGameData,"ui_super_player_envelope   ---------  >>>>>>>>>>>>>>>>") 
    end
    if t_params.callback then
        self.callback = t_params.callback
    end
    self.m_bag_info = self.m_tGameData.redbag_info or {}
end

function ui_super_player_envelope:create(t_params)
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end


return ui_super_player_envelope