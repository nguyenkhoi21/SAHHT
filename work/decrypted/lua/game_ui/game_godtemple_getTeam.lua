local game_godtemple_getTeam = {
	m_btn_close = nil,
	m_screenShoot = nil,
	m_root_layer = nil,
	m_touch_layer = nil,
	m_icon_tab = nil,
	m_tGameData = nil,
	farmer_team_info = nil,
	m_cid_tab = nil,
}
function game_godtemple_getTeam.destroy( self )
	self.m_btn_close = nil;
	self.m_screenShoot = nil;
	self.m_root_layer = nil;
	self.m_touch_layer = nil;
	self.m_icon_tab = nil;
	self.m_tGameData = nil;
	self.farmer_team_info = nil;
	self.m_cid_tab = nil;

	-- body
end
function game_godtemple_getTeam.back( self )
	game_scene:enterGameUi("game_godtemple_main",{gameData = nil})
	-- body
end
function game_godtemple_getTeam.createUi( self )
	-- body
	local ccbNode = luaCCBNode:create()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 100 then
			self:back()
		end

		-- body
	end

	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_godtemple_getTeam.ccbi")
	self.m_root_layer = ccbNode:layerForName("m_root_layer")
	self.m_btn_close = ccbNode:controlButtonForName("m_btn_close")
	self.m_touch_layer = ccbNode:layerForName("m_touch_layer")
	if self.m_screenShoot then
	    local tempSize = self.m_root_layer:getContentSize();
	    self.m_screenShoot:setPosition( tempSize.width*0.5, tempSize.height*0.5 );
	    self.m_root_layer:addChild(self.m_screenShoot,-1);
	end
	return ccbNode
end
function game_godtemple_getTeam.setTeamIcon( self )
	-- local nodeSize = self.m_icon_tab[i][1][1]:getContentSize()
	-- local length = math.min(#self.farmer_team_info[tostring(i)].farmers,5)
	-- local dw = nodeSize.width / length
	-- local dx = dw / 2
	-- for m=1,4 do
	-- 	-- cclog2(self.m_icon_tab[i][1],"icontab == ")
	-- 	-- cclog2(#self.farmer_team_info[tostring(i)].farmers,"length")
	-- 	for i=1,math.min(5,#self.farmer_team_info[tostring(m)].farmers) do
	-- 		cclog2(self.farmer_team_info[tostring(m)].farmers[i],"self.farmer_team_info[tostring(i)][farmers] === ")
	-- 	    local cardData,heroCfg = game_data:getCardDataById(self.farmer_team_info[tostring(m)].farmers[i])
	-- 	    if cardData and heroCfg then
	-- 	        headIconSpr = game_util:createCardIconByCfg(heroCfg,cardData);
	-- 	        if headIconSpr then
	-- 	            headIconSpr:setScale(0.7);
	-- 	            headIconSpr:setAnchorPoint(ccp(0.5,0.5))
	-- 	            headIconSpr:setPosition(ccp( 20,20));
	-- 	            self.m_icon_tab[m][1][i]:addChild(headIconSpr,1,1);
	-- 	            -- local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
	-- 	            -- button:setTag(i)
	-- 	            -- button:setOpacity(0)
	-- 	            -- button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
	-- 	            -- button:setAnchorPoint(ccp(0.5,0.5))
	-- 	            -- button:setPosition(ccp(dx + (i-1)*dw - 5,20))
	-- 	            -- m_btn_node:addChild(button);
	-- 	        end
	-- 	    end
	-- 	end

	-- end
	-- body
end
function game_godtemple_getTeam.createTableView( self,viewSize )
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag<11 then
			game_scene:enterGameUi("game_godtemple_heroList",{showIndex = 2,team_index = btnTag,cidTab = self.m_cid_tab,openType = "getTeam"});
		else
			local function responseMethod( tag,gameData )
				game_scene:addPop("game_temple_rewardPop",{gameData = gameData,callback = callback})
			end
			local team_index = btnTag - 10
			local params = {}
			params.team_index = team_index
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_temple_leave_temple"), http_request_method.GET, params,"god_field_temple_leave_temple")
		end
		-- body
	end

	local function onBtnCilck( event,target )
	    local tagNode = tolua.cast(target, "CCNode");
	    local btnTag = tagNode:getTag();
	    local itemData = {}
	   	local x = math.floor(btnTag/10)
	    itemData = game_data:getCardDataById(self.farmer_team_info[tostring(x)].farmers[btnTag-x*10])
	    if itemData then
	        game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 3})
	    end
	end


	local params = {};
	params.viewSize = viewSize;
	params.row = 3;--行
	params.column = 1; --列
	params.totalItem = 4
	params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
	local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
	params.newCell = function(tableView,index) 
	    local cell = tableView:dequeueCell()
	    if cell == nil then
	        cell = CCTableViewCell:new();
	        cell:autorelease();
	        local ccbNode = luaCCBNode:create();
	        ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
	        ccbNode:openCCBFile("ccb/ui_godtemple_teamInfo2.ccbi");
	        ccbNode:setAnchorPoint(ccp(0.5,0.5));
	        ccbNode:ignoreAnchorPointForPosition(false)
	        ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
	        cell:addChild(ccbNode,10,10);
	        -- ccbNode:controlButtonForName("btn_accepted"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
	    end
	    if cell then
	        local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
	        local m_team_node = ccbNode:nodeForName("m_team1_node")
	        local m_my_comat = ccbNode:labelTTFForName("m_my_comat")
	        local m_status_lab = ccbNode:labelTTFForName("m_status_lab")
	        local m_team_btn = ccbNode:controlButtonForName("m_team_btn")
	        local m_end_btn = ccbNode:controlButtonForName("m_end_btn")
	        local x = self.farmer_team_info[tostring(index+1)].occupied_temple.occupy_time
	        local y = self.farmer_team_info[tostring(index+1)].occupied_temple.leave_time
	        
	        if x ~="" and y == "" then
	        	m_status_lab:setString("Tập hợp")
	        	m_status_lab:setColor(ccc3(250,50,50))
	        	m_team_btn:setVisible(false)
	        	m_end_btn:setVisible(true)
	        elseif x =="" and y ~= "" then

	        	m_status_lab:setString("Tập hợp")
	        	m_status_lab:setColor(ccc3(250,50,50))
	        	m_team_btn:setVisible(false)
	        	m_end_btn:setVisible(true)

	        else
	        	m_status_lab:setString("Rảnh")
	        	m_status_lab:setColor(ccc3(50,150,50))
	        	m_team_btn:setVisible(true)
	        	m_end_btn:setVisible(false)
	        end
	        local m_teamIcon
	        local nodeSize = m_team_node:getContentSize()
	        local length = math.min(#self.farmer_team_info[tostring(index+1)].farmers,5)
	        local dw = nodeSize.width / 5
	        local dx = dw / 2
	        m_team_node:removeAllChildrenWithCleanup(true)
	        for i=1,math.min(5,#self.farmer_team_info[tostring(index+1)].farmers) do
	            local cardData,heroCfg = game_data:getCardDataById(self.farmer_team_info[tostring(index+1)].farmers[i])
	            if cardData and heroCfg then
	                headIconSpr = game_util:createCardIconByCfg(heroCfg,cardData);
	                if headIconSpr then
	                    headIconSpr:setScale(0.7);
	                    headIconSpr:setAnchorPoint(ccp(0.5,0.5))
	                    headIconSpr:setPosition(ccp(dx + (i-1)*dw,20));
	                    m_team_node:addChild(headIconSpr,10,11);
	                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
	                    button:setTag(i+(index+1)*10)
	                    button:setOpacity(0)
	                    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
	                    button:setAnchorPoint(ccp(0.5,0.5))
	                    button:setPosition(ccp(dx + (i-1)*dw,20))
	                    m_team_node:addChild(button);
	                end
	            end
	        end

	        -- local iconTab = {}
	        -- for i=1,5 do
	        -- 	m_teamIcon = ccbNode:spriteForName("m_teamIcon1_" .. i)
	        -- 	local x = "m_teamIcon" .. i
	        -- 	iconTab[i] = m_teamIcon
	        -- end
	        -- self.m_icon_tab[index+1] = {iconTab}
	        m_team_btn:setTag(index+1)
	        m_end_btn:setTag(index+11)
	        local combat = self.farmer_team_info[tostring(index+1)].farmers_combat
	        combat = math.ceil(combat)
	        m_my_comat:setString(tostring(combat))
	    end
	    return cell;
	end
	params.itemOnClick = function(eventType,index,item)

	end
	return TableViewHelper:create(params);
	-- body
end
function game_godtemple_getTeam.refreshUi( self )
	self.m_touch_layer:removeAllChildrenWithCleanup(true)
	local viewSize = self.m_touch_layer:getContentSize()
	local tableView = self:createTableView(viewSize)
	self.m_touch_layer:addChild(tableView,10,10)
	self:setTeamIcon()
	-- body
end
function game_godtemple_getTeam.init( self,t_params )
	self.m_screenShoot = t_params.screenShoot
	self.m_icon_tab = {}
	t_params = t_params or {};
	self.farmer_team_info = {}
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
	    local data = t_params.gameData:getNodeWithKey("data");
	    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
	    self.farmer_team_info = self.m_tGameData.farmer_team_info
	else
	    self.m_tGameData = {};
	end
	self.m_cid_tab = {}
	for i=1,4 do
		for k,v in pairs(self.farmer_team_info[tostring(i)].farmers) do
			table.insert(self.m_cid_tab,v)
		end
	end
	-- body
end
function game_godtemple_getTeam.create( self,params )
	self:init(params)
	local scene = CCScene:create()
	scene = self:createUi(self)
	self:refreshUi()
	return scene
	-- body
end
return game_godtemple_getTeam