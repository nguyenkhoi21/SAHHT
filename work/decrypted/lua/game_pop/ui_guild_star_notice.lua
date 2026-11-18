local ui_guild_star_notice = {
	callback = nil,
	m_editFlag = nil,
	m_notice = nil,
	ccbNode = nil,
	m_edit = nil,
	m_edit_ok = nil,
	m_list_node = nil,
	m_root_layer = nil,
	m_name_label = nil,
	m_tGameData = nil,
} 

function ui_guild_star_notice:destroy()
    cclog("-------- ui_guild_star_notice destroy --------")
	self.callback = nil;
	self.m_editFlag = nil;
	self.m_notice = nil;
	self.ccbNode = nil;
	self.m_edit = nil;
	self.m_edit_ok = nil;
	self.m_list_node = nil;
	self.m_root_layer = nil;
	self.m_name_label = nil;
	self.m_tGameData = nil;
end


function ui_guild_star_notice:back()
	if self.callback then
		self.callback()
	end
	game_scene:removePopByName("ui_guild_star_notice")
end



function ui_guild_star_notice:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 1 then
			self:back()
		elseif btnTag == 2 then
			if self.m_editFlag == false then
				self.m_editFlag = true
				self:refreshUi()
			end
		elseif btnTag == 3 then
			if self.m_editFlag == true then
				self.m_editFlag = false
				local function responseMethod( tag,gameData )
					if gameData then
						local data = gameData:getNodeWithKey("data")
						data = json.decode(data:getFormatBuffer())
						self.m_notice = data.notice
						self:refreshUi()
					end
				end
				local notice = self.m_editBox:getText()
				local t_params = {}
				t_params.notice = util.url_encode(notice)
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_set_notice"), http_request_method.GET, t_params,"guild_robbery_set_notice")
			end
		end
	end
	local ccbNode =  luaCCBNode:create();
	self.ccbNode = ccbNode
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_guild_Star_notice.ccbi")
    ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
    self.m_edit = ccbNode:controlButtonForName("m_edit")
    self.m_edit_ok = ccbNode:controlButtonForName("m_edit_ok")
    self.m_edit:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
    self.m_edit_ok:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)

    self.m_list_node = ccbNode:nodeForName("m_score_reward")

    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.m_name_label = ccbNode:labelTTFForName("m_name_label")
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_root_layer:setTouchEnabled(true);

	return ccbNode
end


function ui_guild_star_notice:refreshUi()
	self.m_list_node:removeAllChildrenWithCleanup(true)
	if self.m_editFlag then
		self.m_edit_ok:setVisible(true)
		self.m_edit:setVisible(false)
		local function editBoxTextEventHandle(strEventName,pSender)
	    end
	    self.m_editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = self.m_list_node:getContentSize(),placeHolder="",maxLength = 999,fontSize = 10,inputMode = kEditBoxInputModeAny});
	    self.m_editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 7);
		self.m_editBox:setFont(TYPE_FACE_TABLE.Arial_BoldMT,10)
	    self.m_editBox:setInputFlag(kEditBoxInputFlagInitialCapsAllCharacters);
	    self.m_list_node:addChild(self.m_editBox);
		self.m_editBox:setText(self.m_notice)
	else
		self.m_edit_ok:setVisible(false)
		self.m_edit:setVisible(true)
		local contentText = "";
	    if self.m_notice then
	    	contentText = self.m_notice
	    end
    	local scrollView = CCScrollView:create(CCSizeMake(230,90));
    	scrollView:setDirection(kCCScrollViewDirectionVertical)
    	scrollView:setTouchPriority(GLOBAL_TOUCH_PRIORITY-7)
    	self.m_list_node:addChild(scrollView)
	    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(230,0),textAlignment = kCCTextAlignmentLeft,
	        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 10})
	    local tempSize = tempLabel:getContentSize();
	    scrollView:setContentSize(CCSizeMake(0,tempSize.height))
	    -- if tempSize.height > 90 then
	        scrollView:setContentOffset(ccp(0, 90 - tempSize.height), false)
	    -- end
	    scrollView:addChild(tempLabel)
	end
	if not self.m_tGameData.can_write then
		self.m_edit_ok:setVisible(false)
		self.m_edit:setVisible(false)
	end

    --159  241  255
end


function ui_guild_star_notice:init(t_params)
	t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_notice = self.m_tGameData.notice
    self.m_editFlag = false
end


function ui_guild_star_notice:create(t_params)
	local scene = CCScene:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end
return ui_guild_star_notice
