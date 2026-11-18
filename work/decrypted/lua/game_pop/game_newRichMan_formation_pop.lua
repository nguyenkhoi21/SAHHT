--新大富翁阵型信息
local game_newRichMan_formation_pop = {
    m_tGameData = nil,
	m_node_tableView = nil,
    m_select_index = nil,
    m_label_type = nil,
    m_openType = nil,
    m_func_callback = nil,
    m_sprite_title = nil,
   
};
--[[--
    销毁ui
]]
function game_newRichMan_formation_pop.destroy(self)
    -- body
    cclog("-----------------game_newRichMan_formation_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_node_tableView = nil;
    self.m_select_index = nil;
    self.m_label_type = nil;
    self.m_openType = nil;
    self.m_func_callback = nil;
    self.m_sprite_title = nil;
end
--[[--
    返回
]]
function game_newRichMan_formation_pop.back(self,type)
	if self.m_func_callback then
		self:m_func_callback()
	end
	game_scene:removePopByName("game_newRichMan_formation_pop")
    -- local function endCallFunc()
    --     self:destroy();
    -- end
    -- game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_newRichMan_formation_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag ==== ")
        if btnTag == 1 then--返回
       		self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_newRichMan_formation_pop.ccbi");
  	self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")
    local m_close_btn = ccbNode:controlButtonForName("m_btn_back")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_label_type = ccbNode:labelTTFForName("m_label_type")
    local m_root_layer = ccbNode:layerForName("m_root_layer")

    self.m_sprite_title = ccbNode:spriteForName("m_sprite_title")
    local spriteTitleName = nil
    if self.m_openType == "prison" then
    	spriteTitleName = "ui_newRichMan_titlePrison.png"

   	elseif self.m_openType == "boss" then
   		spriteTitleName = "ui_newRichMan_titleBoss.png"
   	elseif self.m_openType == "admiral" then
   		spriteTitleName = "ui_newRichMan_admiralTitle.png"
    else
    	self.m_sprite_title:setVisible(false)
    end
    if spriteTitleName then
    	self.m_sprite_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteTitleName))
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
function game_newRichMan_formation_pop.createButton( self,i,parentNode,cid,heroData,myccp ,scale)
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local cardData
        if cid then
            cardData = game_data:getCardDataById(cid[btnTag])
            if cardData then
                game_scene:addPop("game_hero_info_pop",{tGameData = cardData,openType = 3})
            end
        elseif heroData then
			if tolua.type(heroData) == "util_json" then
			   heroData = json.decode(heroData:getFormatBuffer()) or {};
			end
           game_scene:addPop("game_hero_info_pop",{tGameData = heroData,openType = 3})
        end
    end
    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
    button:setAnchorPoint(myccp)

    button:setZoomOnTouchDown(false)
    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    button:setPosition(ccp(45,45));
    button:setOpacity(0)
    button:setScale(1)
    button:setTag(i)
    parentNode:addChild(button,11);
end
function game_newRichMan_formation_pop.createFormationInfo( self, parentNode, formationDataTab )
	parentNode:removeAllChildrenWithCleanup(true)

cclog2(formationDataTab,"formationDataTab-=-------")
	local size = parentNode:getContentSize()
	local width = size.width/5
	local height = size.height
	local combat = 0
	for i=1,#formationDataTab do
	    -- local enemyData = self.new_fight_enemy_cfg:getNodeWithKey(tostring(needTab[i]))
	    local cardData,heroCfg = game_data:getCardDataById(formationDataTab[i])
	    if cardData and heroCfg then
	        headIconSpr = game_util:createCardIconByCfg(heroCfg,cardData);
	        if headIconSpr then
	            headIconSpr:setScale(0.7);
	            headIconSpr:setAnchorPoint(ccp(1,1));
	            parentNode:addChild(headIconSpr,1,1);
	            headIconSpr:setPosition(ccp(width*(i-1)+37,height-10))
	            self:createButton(i,headIconSpr,_,cardData,ccp(1,1),0.75)
	        end
	    end
	    
	end

end

function game_newRichMan_formation_pop.setLabelDes( self, parentLabel, formationId, parentBtn )
	local btnBgName = nil
	if self.m_openType == "prison" then
	 	btnBgName = "ui_newRichMan_btnBurke.png"
	elseif self.m_openType == "boss" then
		btnBgName = "ui_newRichMan_btnBoss.png"
	elseif self.m_openType == "admiral" then
		btnBgName = "ui_newRichMan_btnChallenge.png"
	end
	if btnBgName then
		game_util:setCCControlButtonBackground(parentBtn,btnBgName)
	end

	local des = ""
	local oldTag = parentBtn:getTag()
	if self.m_tGameData.owner_building[tostring(formationId)] then
		local cid = self.m_tGameData.owner_building[tostring(formationId)].c_id
		local monopoly_cfg = getConfig("monopoly")--json.decode(getConfig(game_config_field.monopoly):getFormatBuffer());
		des = monopoly_cfg:getNodeWithKey(tostring(cid)):getNodeWithKey("name"):toStr()
		parentBtn:setTag(oldTag + 20)
		game_util:setCCControlButtonBackground(parentBtn,"ui_newRichMan_btnChehui.png")
		parentBtn:setVisible(true)
	elseif self.m_tGameData.in_prison[tostring(formationId)] then
		des = "Đất nhà tù"
		parentBtn:setTag(502)
		game_util:setCCControlButtonBackground(parentBtn,"ui_newRichMan_btnChehui.png")
		parentBtn:setVisible(true)

	elseif self.m_tGameData.in_boss_field[tostring(formationId)] then
		des = "Đất Boss"
		parentBtn:setTag(oldTag + 20)
		game_util:setCCControlButtonBackground(parentBtn,"ui_newRichMan_btnChehui.png")
		parentBtn:setVisible(true)
	end

	parentLabel:setString(des)
end

function game_newRichMan_formation_pop.createTableView( self, viewSize )
	local tab_btn = {}
	local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag > 30 and btnTag < 34 then --撤回
        	local params = {}
        	params.formation_id = btnTag - 30
        	local function responseMethod( tag, gameData )
				local data = gameData:getNodeWithKey("data")
		        data = json.decode(data:getFormatBuffer())
		        self.m_tGameData = data
		        self:refreshUi()
        	end
        	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_retreat"), http_request_method.GET, params,"monopoly_retreat")
        elseif btnTag == 502 then --监狱
        	game_util:addMoveTips({text = "10 phút sau mới có thể cử Đội trong Nhà tù"})
        elseif btnTag <4 then
	        for i=1,3 do
	        	game_util:setCCControlButtonBackground(tab_btn[i],"ui_newRichMan_selectDi.png")
	        	tab_btn[i]:setPreferredSize(CCSizeMake(43.5,45))
	        end
	        game_util:setCCControlButtonBackground(tab_btn[btnTag],"ui_newRichMan_select.png")
	       	tab_btn[btnTag]:setPreferredSize(CCSizeMake(49.5,49.5))
	    else
	    	local params = {}
	    	params.formation_id = btnTag - 10
	    	if self.m_openType == "prison" then
		    	local function responseMethod( tag, gameData )
		    		self:back()
		    	end
		    	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_join_prison"), http_request_method.GET, params,"monopoly_join_prison")
			elseif self.m_openType == "boss" then 
				local function responseMethod( tag, gameData )
					self:back()
				end
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_join_boss_field"), http_request_method.GET, params,"monopoly_join_boss_field")
			else
		    	local function responseMethod( tag, gameData )
		    		if gameData then
			    		game_data:setBattleType("newRichMan");
			    		game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
			    	end
		    	end
		    	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_battle"), http_request_method.GET, params,"monopoly_battle")
			end
		end
	end
	local totalItem = 3
	local params = {};
	params.viewSize = viewSize;
	params.row = 3;--行
	params.column = 1; --列
	params.totalItem = totalItem;
	-- params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
	params.direction = kCCScrollViewDirectionVertical
	local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
	params.newCell = function(tableView,index) 
	    local cell = tableView:dequeueCell()
	    if cell == nil then
	        cell = CCTableViewCell:new()
	        cell:autorelease()
	        local ccbNode = luaCCBNode:create();
    		ccbNode:registerFunctionWithFuncName("onBtnClick",onBtnClick);
	        ccbNode:openCCBFile("ccb/ui_newRichMan_formation_item.ccbi")    
	        ccbNode:setPosition(ccp(22,itemSize.height*0.5));
	        cell:addChild(ccbNode,10,10);
	    end
	    if cell then
	    	local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
	    	local m_label_des = ccbNode:labelTTFForName("m_label_des")
	    	-- self:setLabelDes(m_label_des,index + 1)
	    	local sprite_btnTitle = ccbNode:spriteForName("m_sprite_btnTitle")

	    	local node_formation = ccbNode:nodeForName("m_node_formation")
	    	local formationDataTab = self:getFormationData()
	    	cclog2(formationDataTab,"formationDataTab-=-----------")
	    	self:createFormationInfo(node_formation,formationDataTab[index + 1])

	    	local btn_challenge = ccbNode:controlButtonForName("m_btn_challenge")
	    	sprite_btnTitle:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_newRichMan_btnTitle".. index + 1 .. ".png"))
	    	btn_challenge:setTag(index + 11)
	    	btn_challenge:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
	    	if self.m_openType == "formation" then
	    		btn_challenge:setVisible(false)
	    	else
	    		btn_challenge:setVisible(true)
	    	end
	    	self:setLabelDes(m_label_des, index + 1, btn_challenge)

	    	local btn = ccbNode:controlButtonForName("m_btn")
	    	btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
	    	btn:setTag(index + 1)
	    	table.insert(tab_btn,btn)

	    	local label_des2 = ccbNode:labelTTFForName("m_label_des2")
	    	local node_timeDown = ccbNode:nodeForName("m_node_timeDown")
	    	node_timeDown:removeAllChildrenWithCleanup(true)
	    	if self.m_tGameData.in_prison[tostring(index + 1)] then
	    		local time_count_down = self.m_tGameData.in_prison[tostring(index+1)]
	    		self:createTimeDown(node_timeDown,time_count_down)
	    		label_des2:setVisible(true)
	    		label_des2:setString("CD thả")
	    	elseif self.m_tGameData.owner_building[tostring(index + 1)] then
	    		local time_count_down = self.m_tGameData.owner_building[tostring(index+1)].expire
	    		self:createTimeDown(node_timeDown,time_count_down)
	    		-- label_des2:setVisible(true)
	    		label_des2:setVisible(true)
	    		label_des2:setString("CD chiếm")
	    	else
	    		label_des2:setVisible(false)
	    	end
	    end
	    return cell;
	end
	return TableViewHelper:create(params);
end
function game_newRichMan_formation_pop.getFormationData( self )
	local formationDataTab = {}
	for j=1,game_util:getTableLen(self.m_tGameData.formation) do
		local tempTab = {}
		for i=1,game_util:getTableLen(self.m_tGameData.formation[tostring(j)].card_ids)  do
			if #tempTab >= 5 then
			else
				if self.m_tGameData.formation[tostring(j)].card_ids[i] ~= "0" and self.m_tGameData.formation[tostring(j)].card_ids[i] ~= "-1" then
					table.insert(tempTab,self.m_tGameData.formation[tostring(j)].card_ids[i])
				end
			end
		end
		table.insert(formationDataTab,tempTab)
	end
	return formationDataTab
end
function game_newRichMan_formation_pop.createTimeDown( self,parentNode,time_count_down,shwoType,isclose )
    local function timeEndFunc()
        parentNode:setVisible(false)
       	local function responseMethod( tag, gameData )
			local data = gameData:getNodeWithKey("data")
	        data = json.decode(data:getFormatBuffer())
	        self.m_tGameData = data
	        self:refreshUi()
       	end
       	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_formation_info"), http_request_method.GET, params,"monopoly_formation_info")
    end
    parentNode:removeAllChildrenWithCleanup(true)
    local shwoType = shwoType or 3
    local countdownLabel = game_util:createCountdownLabel(time_count_down,timeEndFunc,8, shwoType);
    countdownLabel:setColor(ccc3(74, 249, 69))
    countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    local tempcontent = parentNode:getContentSize()
    countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.6))
    parentNode:addChild(countdownLabel,10,10) 
end
--[[--
    刷新ui
]]
function game_newRichMan_formation_pop.refreshUi(self)
	self.m_node_tableView:removeAllChildrenWithCleanup(true)
	local viewSize = self.m_node_tableView:getContentSize()
	self.m_node_tableView:addChild(self:createTableView(viewSize))
	local desType = ""
	if self.m_openType == "boss" then
		desType = "Bạn đã vào giao diện Boss Chiến"
	elseif self.m_openType == "enemy" then
		desType = "Bạn đã vào giao diện Kẻ địch"
	
	elseif self.m_openType == "prison" then
		desType = "Bạn đã vào giao diện Nhà tù"
	
	elseif self.m_openType == "formation" then
		desType = "Bạn đã vào giao diện Đội hình"
	end
	self.m_label_type:setString(desType)
	-- self:getFormationData()

end
--[[--
    初始化
]]
function game_newRichMan_formation_pop.init(self,t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_vip.plist")

    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    cclog2(self.m_tGameData," m_tGameData -=--- ")
    self.m_select_index = 0
    if t_params.openType then
    	self.m_openType = t_params.openType
    end
    if t_params.popCallBack then
        self.m_func_callback = t_params.popCallBack
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_newRichMan_formation_pop.create(self, t_params)
    self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi();

    return  m_popUi;
end
return game_newRichMan_formation_pop;