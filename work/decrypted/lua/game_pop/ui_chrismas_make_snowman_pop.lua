local ui_chrismas_make_snowman_pop = {
	m_root_layer = nil,
	m_btn_back = nil,
    callback = nil,
    m_editBox1 = nil,
    m_selected_count1 = nil,
    m_editBox2 = nil,
    m_selected_count2 = nil,
    m_small_ball = nil,
    m_MaxCount = nil,
    m_big_ball = nil,
    m_text_box_node1 = nil,
    m_text_box_node2 = nil,
    m_tGameData = nil,
    m_select_snow = nil,
} 

function ui_chrismas_make_snowman_pop:destroy( )
	self.m_root_layer = nil;
	self.m_btn_back = nil;
    self.callback = nil;
    self.m_editBox1 = nil;
    self.m_selected_count1 = nil;
    self.m_editBox2 = nil;
    self.m_selected_count2 = nil;
    self.m_small_ball = nil;
    self.m_MaxCount = nil;
    self.m_big_ball = nil;
    self.m_text_box_node1 = nil;
    self.m_text_box_node2 = nil;
    self.m_tGameData = nil;
    self.m_select_snow = nil;
end



function ui_chrismas_make_snowman_pop:back()
	if self.callback then
		self.callback()
	end
	game_scene:removePopByName("ui_chrismas_make_snowman_pop")
end



function ui_chrismas_make_snowman_pop:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		-- cclog2(btnTag,"btnTag ----------========")
		if btnTag == 1 then
			self:back()
		elseif btnTag == 101 then
            if self.m_selected_count1 == nil then
                game_util:addMoveTips({text = "Nhập số Bóng Tuyết chính xác"})
                return  
            end
            if self.m_small_ball == 0 then
                game_util:addMoveTips({text = "Không đủ Bóng Tuyết"})
                return 
            end
			function responseMethod(tag,gameData)
 				if gameData then
 					game_util:addMoveTips({text = "Đã sử dụng" .. self.m_selected_count1 .. "Bóng Tuyết"})
 					self.m_MaxCount = self.m_MaxCount - self.m_selected_count1
                    if self.m_MaxCount == 0 then
                        self:back()
                        return
                    end
                    if self.m_selected_count2 and self.m_selected_count2 * 10 > self.m_MaxCount then
                        self.m_editBox2:setText(math.floor(self.m_MaxCount/10))
                        self.m_selected_count2 = math.floor(self.m_MaxCount/10)
                    end
 					self.callback()
 					self:refreshSnowCount()
 					self.m_editBox1:setText(0)
 					self.m_selected_count1 = 0
 				end
 			end
	    	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("snow_make_snowman"), http_request_method.GET, {snow_id = self.m_select_snow,ball_id = 511355,num = self.m_selected_count1},"snow_make_snowman")
		elseif btnTag == 102 then
            if self.m_selected_count2 == nil then
                game_util:addMoveTips({text = "Nhập số Bóng Tuyết chính xác"})
                return  
            end
            if self.m_big_ball == 0 then
                game_util:addMoveTips({text = "Không đủ Bóng Tuyết"})
                return 
            end
			function responseMethod(tag,gameData)
 				if gameData then
 					game_util:addMoveTips({text = "Đã sử dụng" .. self.m_selected_count2 .. "Bóng Tuyết"})
 					self.m_MaxCount = self.m_MaxCount - self.m_selected_count2 * 10
                    if self.m_MaxCount == 0 then
                        self:back()
                        return
                    end
                    if self.m_selected_count1 and self.m_selected_count1 > self.m_MaxCount then
                        self.m_editBox1:setText(self.m_MaxCount)
                        self.m_selected_count1 = self.m_MaxCount
                    end
 					self.callback()
 					self:refreshSnowCount()
 					self.m_editBox2:setText(0)
 					self.m_selected_count2 = 0
 				end
 			end
	    	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("snow_make_snowman"), http_request_method.GET, {snow_id = self.m_select_snow,ball_id = 511356,num = self.m_selected_count2},"snow_make_snowman")
		elseif btnTag == 103 then
		    if self.m_MaxCount > self.m_small_ball then
    			self.m_editBox1:setText(self.m_small_ball)
    			self.m_selected_count1 = self.m_small_ball
    		else
    			self.m_editBox1:setText(math.floor(self.m_MaxCount))
    			self.m_selected_count1 = self.m_MaxCount
    		end
		elseif btnTag == 104 then
    		if self.m_MaxCount > self.m_big_ball * 10 then
    			self.m_editBox2:setText(self.m_big_ball)
    			self.m_selected_count2 = self.m_big_ball
    		else
    			self.m_editBox2:setText(math.floor(self.m_MaxCount/10))
    			self.m_selected_count2 = math.floor(self.m_MaxCount/10)
    		end
		end
	end
	local ccbNode =  luaCCBNode:create();
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_Chrismas_snowman_make_pop.ccbi")
	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	self.m_btn_back = ccbNode:controlButtonForName("btn_back")

	self.m_text_box_node1 = ccbNode:nodeForName("m_text_box_node1")
	self.m_text_box_node2 = ccbNode:nodeForName("m_text_box_node2")
	local btn_max_small = ccbNode:controlButtonForName("btn_max_small")
	local btn_max_big = ccbNode:controlButtonForName("btn_max_big")
	local m_btn_ok1 = ccbNode:controlButtonForName("m_btn_ok1")
	local m_btn_ok2 = ccbNode:controlButtonForName("m_btn_ok2")
	self.m_btn_back:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
	btn_max_small:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
	btn_max_big:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
	m_btn_ok1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
	m_btn_ok2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)

	local function editBoxTextEventHandle1(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "began" then
        	local count = tonumber(edit:getText()) or 0
        	if  count > self.m_small_ball or count > self.m_MaxCount then
        		edit:setText(self.m_small_ball)
        		if self.m_MaxCount > self.m_small_ball then
        			edit:setText(self.m_small_ball)
        		else
        			edit:setText(math.floor(self.m_MaxCount))
        		end
        	end
        	self.m_selected_count1 = tonumber(edit:getText()) or 0
        elseif strEventName == "ended" then
            local count = tonumber(edit:getText()) or 0
        	if  count > self.m_small_ball or count > self.m_MaxCount then
        		if self.m_MaxCount > self.m_small_ball then
        			edit:setText(self.m_small_ball)
        		else
        			edit:setText(math.floor(self.m_MaxCount))
        		end
        	end
        	self.m_selected_count1 = tonumber(edit:getText()) or 0
        elseif strEventName == "return" then
            local count = tonumber(edit:getText()) or 0
        	if  count > self.m_small_ball or count > self.m_MaxCount then
        		if self.m_MaxCount > self.m_small_ball then
        			edit:setText(self.m_small_ball)
        		else
        			edit:setText(math.floor(self.m_MaxCount))
        		end
        	end
        	self.m_selected_count1 = tonumber(edit:getText()) or 0
        elseif strEventName == "changed" then
        	local count = tonumber(edit:getText()) or 0
        	if  count > self.m_small_ball or count > self.m_MaxCount then
        		if self.m_MaxCount > self.m_small_ball then
        			edit:setText(self.m_small_ball)
        		else
        			edit:setText(math.floor(self.m_MaxCount))
        		end
        	end
        	self.m_selected_count1 = tonumber(edit:getText()) or 0
        end
    end

	self.m_editBox1 = game_util:createEditBox({bgFileName = "red_envelope_jihuomaDi.png",fontColor = ccc3(255,250,250), scriptEditBoxHandler=editBoxTextEventHandle1,size = self.m_text_box_node1:getContentSize(),placeHolder="Nhập"});
    self.m_editBox1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 7);
    self.m_text_box_node1:addChild(self.m_editBox1);

    local function editBoxTextEventHandle2(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "began" then
        	local count = tonumber(edit:getText()) or 0
        	if  count > self.m_big_ball or count > self.m_MaxCount/10  then
        		if self.m_MaxCount > self.m_big_ball * 10 then
        			edit:setText(self.m_big_ball)
        		else
        			edit:setText(math.floor(self.m_MaxCount/10))
        		end
        	end
        	self.m_selected_count2 = tonumber(edit:getText()) or 0
        elseif strEventName == "ended" then
        	local count = tonumber(edit:getText()) or 0
        	if  count > self.m_big_ball or count > self.m_MaxCount/10  then
        		if self.m_MaxCount > self.m_big_ball * 10 then
        			edit:setText(self.m_big_ball)
        		else
        			edit:setText(math.floor(self.m_MaxCount/10))
        		end
        	end
        	self.m_selected_count2 = tonumber(edit:getText()) or 0
        elseif strEventName == "return" then
            local count = tonumber(edit:getText()) or 0
        	if  count > self.m_big_ball or count > self.m_MaxCount/10  then
        		if self.m_MaxCount > self.m_big_ball * 10 then
        			edit:setText(self.m_big_ball)
        		else
        			edit:setText(math.floor(self.m_MaxCount/10))
        		end
        	end
        	self.m_selected_count2 = tonumber(edit:getText()) or 0
        elseif strEventName == "changed" then
        	local count = tonumber(edit:getText()) or 0
        	if  count > self.m_big_ball or count > self.m_MaxCount/10 then
        		if self.m_MaxCount > self.m_big_ball * 10 then
        			edit:setText(self.m_big_ball)
        		else
        			edit:setText(math.floor(self.m_MaxCount/10))
        		end
        	end
        	self.m_selected_count2 = tonumber(edit:getText()) or 0
        end
    end
	self.m_editBox2 = game_util:createEditBox({bgFileName = "red_envelope_jihuomaDi.png",fontColor = ccc3(255,250,250),scriptEditBoxHandler=editBoxTextEventHandle2,size = self.m_text_box_node2:getContentSize(),placeHolder="Nhập"});
    self.m_editBox2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 7);
    self.m_text_box_node2:addChild(self.m_editBox2);
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


function ui_chrismas_make_snowman_pop:refreshSnowCount()
	self.m_small_ball = game_data:getItemCountByCid(511355)
	self.m_big_ball = game_data:getItemCountByCid(511356)
end

function ui_chrismas_make_snowman_pop:makeCallback(game_data)
	self.callback()
end


function ui_chrismas_make_snowman_pop:refreshUi()
	self:refreshSnowCount()
end


function ui_chrismas_make_snowman_pop:init(t_params)
	self.m_tGameData = t_params.gameData or {}
	self.m_select_snow = t_params.select_snow or 1
	if t_params.callback then
		self.callback = t_params.callback
	end
	self.m_MaxCount = t_params.MaxCount
end

function ui_chrismas_make_snowman_pop:create(t_params)
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end


return ui_chrismas_make_snowman_pop