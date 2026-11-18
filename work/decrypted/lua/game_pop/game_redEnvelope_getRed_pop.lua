--新年红包红包列表界面
local game_redEnvelope_getRed_pop = {
	m_tGameData = nil,
	m_root_layer = nil,
	m_close_btn = nil,
	m_tableView_node = nil,
	m_refresh_btn = nil,
	player_red_bag = nil,
	red_info = nil,
	get_bag = nil,
	m_sortTab = nil,
	m_des_lab = nil,
	m_conutdownTime_node = nil,
	is_refresh = nil,
	m_time = nil,

}
function game_redEnvelope_getRed_pop.destroy( self )
	self.m_tGameData = nil;
	self.m_root_layer = nil;
	self.m_close_btn = nil;
	self.m_tableView_node = nil;
	self.m_refresh_btn = nil;
	self.player_red_bag = nil;
	self.red_info = nil;
	self.get_bag = nil;
	self.m_sortTab = nil;
	self.m_des_lab = nil;
	self.m_conutdownTime_node = nil;
	self.is_refresh = nil;
	self.m_time = nil;
	cclog("--------game_redEnvelope_getRed_pop.destory-------")
end
function game_redEnvelope_getRed_pop.back( self )
	 local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
function game_redEnvelope_getRed_pop.createUi( self )
	local ccbNode = luaCCBNode:create()
	local function onMainBtnClick( target,event )
		local ccbNode = tolua.cast(target,"CCNode")
		local btnTag = ccbNode:getTag()
		if btnTag == 1 then 
			self:back()
		elseif btnTag == 33 then
			if self.is_refresh == true then
				
				local function responseMethod( tag,gameData )
					local data = gameData:getNodeWithKey("data")
					self.m_tGameData = json.decode(data:getFormatBuffer())
					--self.m_time = 10
					self.is_refresh = false
					self.m_conutdownTime_node:setVisible(true)
				    self:refreshData()
				    self:refreshUi()
				end
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("red_bag_refresh_red_bag"), http_request_method.GET, nil,"red_bag_refresh_red_bag")
			else
				game_util:addMoveTips({text = "Vui lòng đợi"})
			end
		end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_redEnvelope_getRed_pop.ccbi")
	self.m_root_layer = ccbNode:layerForName('m_root_layer')
	self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
	self.m_tableView_node = ccbNode:nodeForName("m_tableView_node")
	self.m_refresh_btn = ccbNode:controlButtonForName("m_refresh_btn")
	self.m_des_lab =  ccbNode:labelTTFForName('m_des_lab')
	self.m_conutdownTime_node = ccbNode:nodeForName("m_conutdownTime_node")
	if self.m_time > 0 then
		self.m_conutdownTime_node:setVisible(true) 
		self.is_refresh = false
	else
		self.m_conutdownTime_node:setVisible(false)
	end
	self.m_refresh_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
	self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)

	local function onTouch(eventType, x, y)
	    if eventType == "began" then
	        return true;
	    elseif eventType == "ended" then
	    end
	end
	self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true)
	self.m_root_layer:setTouchEnabled(true);
	return ccbNode
	-- body
end
function game_redEnvelope_getRed_pop.createTableView( self,viewSize )
	local function onBtnClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
		local btnTag = tagNode:getTag();

			local params = {}
			params.key = self.red_info[btnTag+1].uid_time
			local function responseMethod(tag,gameData)
				local data = gameData:getNodeWithKey("data")
				self.m_tGameData = json.decode(data:getFormatBuffer())
			    self:refreshData()
			    self:refreshUi()
			    local is_successful = false
			    if self.m_tGameData.err_code == 1 then
			   		game_scene:addPop("game_redEnvelope_alreadyGet_pop",{gameData = gameData,is_successful = false})
			   	else
			   		game_scene:addPop("game_redEnvelope_alreadyGet_pop",{gameData = gameData,is_successful = true})
			   	end
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("red_bag_open_red_bag"), http_request_method.GET, params,"red_bag_open_red_bag")
	end
	local totalItem = #self.red_info
	local params = {}
	local viewSize = viewSize 
	params.viewSize = viewSize
	params.row = 2
	params.column = 4
	params.totalItem = totalItem
	params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
	params.direction = kCCScrollViewDirectionHorizontal
	local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
	params.newCell = function(tableView,index)
		local cell = tableView:dequeueCell()
		if cell == nil then
			cell = CCTableViewCell:new()
			cell:autorelease()
			local ccbNode = luaCCBNode:create()
			ccbNode:registerFunctionWithFuncName("onBtnClick",onBtnClick);--bind button on click event
			ccbNode:openCCBFile("ccb/ui_redEnvelope_Reditem.ccbi")
			ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
			cell:addChild(ccbNode,10,10);
		end
		if cell then
			local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
			local m_chai_btn = ccbNode:controlButtonForName("m_chai_btn")
			local m_name_lab = ccbNode:labelTTFForName("m_name_lab")
			m_name_lab:setString(self.red_info[index+1].name .. "Lì xì chia sẻ")
			m_chai_btn:setTag(index)
			m_chai_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
			if self.red_info[index+1]["is_get"] == 1 then --红包领过了
				m_chai_btn:setVisible(false)
			end
		end
		return cell;
	end
	params.itemOnClick = function(eventType,index,item)
	end
	return TableViewHelper:create(params);
end
function game_redEnvelope_getRed_pop.refreshUi( self )
	local viewSize = self.m_tableView_node:getContentSize()
	self.m_tableView_node:removeAllChildrenWithCleanup(true)
	local tableView = self:createTableView(viewSize)
	self.m_tableView_node:addChild(tableView,10,10)
	local version = tostring(self.m_tGameData.version)
	local m_config = getConfig(game_config_field.system_red_bag)
	m_config = json.decode(m_config:getFormatBuffer())
	m_config = m_config[version]
	self.m_des_lab:setString(m_config.des2)
	self:createTimeDown()
end
function game_redEnvelope_getRed_pop.createTimeDown( self )
	if self.m_time == 0 then
		self.is_refresh = true
		self.m_conutdownTime_node:setVisible(false)
	end
    self.m_conutdownTime_node:removeAllChildrenWithCleanup(true)
        local function timeEndFunc()
        	 self.m_conutdownTime_node:setVisible(false)
        	 self.is_refresh = true
        end 
        local countdownLabel = game_util:createCountdownLabel(self.m_time,timeEndFunc,8, 1);
        countdownLabel:setColor(ccc3(0, 255, 0))
        countdownLabel:setAnchorPoint(ccp(0.5,0.5))
        local tempcontent = self.m_conutdownTime_node:getContentSize()
        countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.65))
        self.m_conutdownTime_node:addChild(countdownLabel,10,10) 
end
function game_redEnvelope_getRed_pop.refreshData( self )
	self.player_red_bag = self.m_tGameData.player_red_bag
	self.get_bag = self.m_tGameData.get_bag
	self.red_info = self.m_tGameData.red_info
	self.m_time = self.m_tGameData.cd_time or 0
	local function sortFunc(data1,data2)
		local uid_time1 = data1.uid_time
		local uid_time2 = data2.uid_time
		local time1 = util.stringSplit(uid_time1,"_");
		time1 = tonumber(time1[2])
		local time2 = util.stringSplit(uid_time2,"_");
		time2 = tonumber(time2[2])
		return time1>time2
	end
	table.sort(self.red_info,sortFunc)
end
function game_redEnvelope_getRed_pop.init( self,t_params )
	t_params = t_params or {}
	self.player_red_bag = {}
	self.m_sortTab = {}
	self.is_refresh = true
	
	if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
		local data = t_params.gameData:getNodeWithKey("data")
		self.m_tGameData = json.decode(data:getFormatBuffer())
		self.m_time = self.m_tGameData.cd_time or 0
		self.player_red_bag = self.m_tGameData.player_red_bag
		self.get_bag = self.m_tGameData.get_bag
		self.red_info = self.m_tGameData.red_info
		local function sortFunc(data1,data2)
			local uid_time1 = data1.uid_time
			local uid_time2 = data2.uid_time
			local time1 = util.stringSplit(uid_time1,"_");
			time1 = tonumber(time1[2])
			local time2 = util.stringSplit(uid_time2,"_");
			time2 = tonumber(time2[2])
			return time1>time2
		end
		table.sort(self.red_info,sortFunc)
	end
			
end
function game_redEnvelope_getRed_pop.create( self,t_params )
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
	-- body
end
return game_redEnvelope_getRed_pop;