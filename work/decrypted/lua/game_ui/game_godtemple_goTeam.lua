local game_godtemple_goTeam = {
	m_btn_close = nil,
	m_screenShoot = nil,
	m_root_layer = nil,
	m_touch_layer = nil,
	m_go_sp = nil,
	m_get_sp = nil,
	m_select_index = nil,
	m_duihao_tab = nil,
	m_attack_btn = nil,
	m_showType = nil,
	farmer_team_info = nil,
	m_tGameData = nil,
	m_cid_tab = nil,



}
function game_godtemple_goTeam.destroy( self )
	self.m_btn_close = nil;
	self.m_screenShoot = nil;
	self.m_root_layer = nil;
	self.m_touch_layer = nil;
	self.m_go_sp = nil;
	self.m_get_sp = nil;
	self.m_select_index = nil;
	self.m_duihao_tab = nil;
	self.m_attack_btn = nil;
	self.m_showType = nil;
	self.m_tGameData = nil;
	self.farmer_team_info = nil;
	self.m_cid_tab = nil;
	-- body
end
function game_godtemple_goTeam.back( self )
	game_scene:enterGameUi("game_godtemple_main",{gameData = nil})
	-- body
end
function game_godtemple_goTeam.createUi( self )
	-- body
	local ccbNode = luaCCBNode:create()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 100 then
			self:back()
		elseif btnTag == 101 then
			if self.m_select_index ~= 0 then
				local function responseMethod( tag,gameData )
					local function endCallFunc()
						game_scene:removePopByName("game_godtemple_goTeam");
					end
					game_scene:addPop("game_godtemple_kuangdian",{gameData = gameData,showType = self.m_showType,user_team = self.m_select_index ,screenShoot = self.m_screenShoot,endCallFunc = endCallFunc})
				end
				local params = {}
				params.temple_level = self.m_showType
				params.team_index = self.m_select_index
				params.is_refresh = 0
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_temple_select_enemies"), http_request_method.GET, params,"god_field_temple_select_enemies")
			else
				game_util:addMoveTips({text = "Xin chọn đội"})
			end
		end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_godtemple_getTeam.ccbi")
	self.m_root_layer = ccbNode:layerForName("m_root_layer")
	self.m_btn_close = ccbNode:controlButtonForName("m_btn_close")
	self.m_touch_layer = ccbNode:layerForName("m_touch_layer")
	self.m_go_sp = ccbNode:spriteForName("m_go_sp")
	self.m_get_sp = ccbNode:spriteForName("m_get_sp")
	self.m_attack_btn = ccbNode:controlButtonForName("m_attack_btn")
	self.m_attack_btn:setVisible(true)
	self.m_go_sp:setVisible(true)
	self.m_get_sp:setVisible(false)
	if self.m_screenShoot then
	    local tempSize = self.m_root_layer:getContentSize();
	    self.m_screenShoot:setPosition( tempSize.width*0.5, tempSize.height*0.5 );
	    self.m_root_layer:addChild(self.m_screenShoot,-1);
	end
	return ccbNode
end
function game_godtemple_goTeam.createTableView( self,viewSize )
	local function onMainBtnClick( target,eventType )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag < 11 then
			self.m_select_index = btnTag
			for k,v in pairs(self.m_duihao_tab) do
				if k == btnTag then
					v:setVisible(true)
				else
					v:setVisible(false)
				end
			end
		else
			game_scene:enterGameUi("game_godtemple_heroList",{showIndex = self.m_showType,team_index = btnTag-10,cidTab = self.m_cid_tab,openType = "goTeam"});
		-- body
		end
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
	params.touchPriority = GLOBAL_TOUCH_PRIORITY;
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
	        local m_select_btn = ccbNode:controlButtonForName("m_select_btn")
	        local m_duihao_sp = ccbNode:spriteForName("m_duihao_sp")
	        local m_isChuzhan_lab = ccbNode:labelTTFForName("m_isChuzhan_lab")
	        local m_team_btn = ccbNode:controlButtonForName("m_team_btn")
	        m_status_lab:setVisible(false)
	        m_select_btn:setVisible(true)
	        m_select_btn:setTag(index+1)
	        self.m_duihao_tab[index+1] = m_duihao_sp

	        local x = self.farmer_team_info[tostring(index+1)].occupied_temple.occupy_time
	        local y = self.farmer_team_info[tostring(index+1)].occupied_temple.leave_time
	        
	         if x ~="" and y == "" then
	        	m_status_lab:setString("Tập hợp")
	        	m_status_lab:setColor(ccc3(250,50,50))
	        	m_team_btn:setVisible(false)
	        	m_status_lab:setVisible(true)
	        	m_select_btn:setVisible(false)
	        elseif x =="" and y ~= "" then
	        	
	        	m_status_lab:setString("Tập hợp")
	        	m_status_lab:setColor(ccc3(250,50,50))
	        	m_team_btn:setVisible(false)
	        	m_status_lab:setVisible(true)
	        	m_select_btn:setVisible(false)


	        else
	        	m_status_lab:setString("Rảnh")
	        	m_status_lab:setColor(ccc3(50,150,50))
	        	 m_status_lab:setVisible(false)
	        	m_team_btn:setVisible(true)
	        	m_select_btn:setVisible(true)

	        end
	        local m_team_btn = ccbNode:controlButtonForName("m_team_btn")
	        local m_teamIcon
	        local nodeSize = m_team_node:getContentSize()
	        local dw = nodeSize.width / 5
	        local dx = dw / 2
	        m_team_node:removeAllChildrenWithCleanup(true)
	        -- cclog2(self.farmer_team_info,"self.farmer_team_info[tostring(index+1)].farmers === ")
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
	                    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY)
	                    button:setAnchorPoint(ccp(0.5,0.5))
	                    button:setPosition(ccp(dx + (i-1)*dw,20))
	                    m_team_node:addChild(button);
	                    -- local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
	                    -- button:setTag(i)
	                    -- button:setOpacity(0)
	                    -- button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
	                    -- button:setAnchorPoint(ccp(0.5,0.5))
	                    -- button:setPosition(ccp(dx + (i-1)*dw - 5,20))
	                    -- m_btn_node:addChild(button);
	                end
	            end
	        end

	        m_team_btn:setTag(index+11)
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
function game_godtemple_goTeam.refreshUi( self )
	self.m_touch_layer:removeAllChildrenWithCleanup(true)
	local viewSize = self.m_touch_layer:getContentSize()
	local tableView = self:createTableView(viewSize)
	self.m_touch_layer:addChild(tableView,10,10)
	-- body
end
function game_godtemple_goTeam.init( self,t_params )
	self.m_showType = t_params.showType or 1
	self.m_select_index = 0;
	self.m_duihao_tab = {};

	self.m_screenShoot = t_params.screenShoot
	self.m_icon_tab = {}
	t_params = t_params or {};
	self.farmer_team_info = {}
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
	    local data = t_params.gameData:getNodeWithKey("data");
	    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
	    self.farmer_team_info = self.m_tGameData.farmer_team_info
	    self.m_cid_tab = {}
	    for i=1,4 do
	    	for k,v in pairs(self.farmer_team_info[tostring(i)].farmers) do
	    		table.insert(self.m_cid_tab,v)
	    	end
	    end
	else
	    self.m_tGameData = {};
	end

	-- body
end
function game_godtemple_goTeam.create( self,params )
	self:init(params)
	local scene = CCScene:create()
	scene = self:createUi(self)
	self:refreshUi()
	return scene
	-- body
end
return game_godtemple_goTeam