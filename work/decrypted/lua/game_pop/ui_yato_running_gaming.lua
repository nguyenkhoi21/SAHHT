local ui_yato_running_gaming = {
	m_popUi = nil,
	m_root_layer = nil,
	m_btn_close = nil,
	m_regulation = nil,
	m_yato = {},
	m_encourage = {},
	m_trouble = {},
	m_yato_speed = {},
	m_yato_distance = {},
	m_stage = nil,
	m_time_node = nil,
	globalcheduler = nil,
	text_scroll = nil,
	content_node = nil,
	m_btn_buy = nil,
	total_list = {},
	complete_list = {},
	m_encourage_num = nil,
	m_trouble_num = nil	,
	m_right = nil,--几Đang đợi...羊驼  赢了
	m_isright = nil,--1表示 猜对  0表示猜错
	m_local_encourage_num = nil,
	m_local_trouble_num = nil,
	m_temp = nil,
	m_msg = "",
	m_N2 = nil,
	m_N3 = nil,
	m_bout = nil,
	m_select = {},
	version_num = nil,
	msg_list =  "",
	m_tGameData = nil,
	m_tGameData2 = nil,
	m_msg_lab = nil,
};
function ui_yato_running_gaming.destroy( self )
	-- body
	cclog("------------- ui_yato_running_gaming destroy --------------")
	self.m_root_layer = nil	;
	self.m_popUi = nil;
	self.m_btn_close = nil;
	self.m_regulation = nil;
	self.m_yato = {};
	self.m_encourage = {};
	self.m_trouble = {}
	self.m_yato_speed = {};--  3只y羊驼 的速度
	self.m_yato_distance = {};-- 羊驼  位置
	self.m_stage = nil; -- 阶段
	self.m_time_node = nil;
	self.globalcheduler = nil;
	self.text_scroll = nil;
	self.content_node = nil;
	self.m_btn_buy = nil;
	self.total_list = {};
	self.complete_list = {};
	self.m_encourage_num = nil;
	self.m_trouble_num = nil;
	self.m_right = nil;
	self.m_local_trouble_num = nil;
	self.m_local_encourage_num = nil;
	self.m_temp = nil;
	self.m_msg ="";
	self.N2 = nil;
	self.n3 = nil;
	self.bout = nil;
	self.m_select = {};
	self.version_num =nil	;
	self.msg_list = "";
	self.m_tGameData = nil;
	self.m_tGameData2 = nil;
	self.m_msg_lab = nil;

end


function ui_yato_running_gaming.back( self )
	game_scene:removePopByName("ui_yato_running_gaming")
	--停止计时器  羊驼的移动
    scheduler:unscheduleAll()
    self:destroy()
    local function responseMethod( tag,gameData )
        game_scene:enterGameUi("ui_yato_running_main_new",{gameData = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_index"),http_request_method.GET,nil,"yato_running_index")--重新申请数据刷新进入报名界面
end

--[[--创建UI  读取ccb]]
function ui_yato_running_gaming.createUi( self )
	local  ccbNode =luaCCBNode:create();
	local   function onMainBtnClick( target,event )
		-- body
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag();
		cclog(btnTag .. " btn  tag    ----------        " .. btnTag)
		if btnTag == 100  then  --返回按钮
			self:back();
		elseif btnTag == 101 then --规则说明
			--跳转到规则说明界面
			game_scene:addPop("game_active_limit_detail_pop",{openType=""})
		elseif btnTag == 111 then --羊驼1的加油
			--更改速度  
			self:encourage(1)
		elseif btnTag == 112 then  --羊驼2的加油
			self:encourage(2)
		elseif btnTag == 113 then -- 羊驼3的加油
			self:encourage(3)
		elseif btnTag == 121 then -- 羊驼1的捣乱
			self:trouble(1)
		elseif btnTag == 122 then -- 羊驼2的捣乱
			self:trouble(2)
		elseif btnTag == 123 then --羊驼3的捣乱
			self:trouble(3)
		elseif btnTag == 130 then  -- 购买竞猜卷
			if self.m_tGameData.now_step == 6 then
				game_util:addMoveTips({text = "Giai đoạn Xung Kích không thể mua Vé Dự Đoán!"})
				return
			end
            game_scene:addPop("ui_yato_running_message",{Poptype = 3,version = self.version_num,cost = self.m_yato_running_main[tostring(self.m_tGameData.now_step +1)].lottery_price })
			-- scheduler:unscheduleAll()
		end	
	end

	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_yato_running_gaming.ccbi")

	local function onTouch(eventType ,x,y )
		if eventType == "began" then 
			return true;
		end
	end

	self.m_root_layer = ccbNode:layerForName("m_root_layer")
	self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true)
	self.m_root_layer:setTouchEnabled(true)

	self.m_btn_close = ccbNode:controlButtonForName("m_btn_close")
	self.m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10) 
	for i=1,3 do
		self.m_yato[i] = ccbNode:nodeForName("m_yato"..i)
		self.m_yato[i]:setScale(0.8)
		self.m_encourage[i] = ccbNode:controlButtonForName("m_encourage_"..i)
		self.m_encourage[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
		self.m_trouble[i] = ccbNode:controlButtonForName("m_trouble_"..i)
		self.m_trouble[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
		if self.m_tGameData.now_step == 6 then
			local index = self:getFirstByTab(self.total_list)
			self.total_list[index] = 100
		end
		self.m_yato_speed[i]=(self.total_list[i]-self.complete_list[i])/self.m_tGameData.remain_time --sudu
		self.m_yato_distance[i] =  self.complete_list[i] 

		self.m_yato[i]:setPositionX((self.m_yato_distance[i]/100)*350)
		
		self.m_select[i] = ccbNode:spriteForName("m_select"..i)
	end

	if self.m_tGameData.apply ~=0 then
		self.m_select[self.m_tGameData.apply]:setVisible(true)
	end

	local anim1 = self:createHeroAnim1()
	self.m_yato[1]:addChild(anim1)
	local anim2 = self:createHeroAnim2()
	self.m_yato[2]:addChild(anim2) 
	local anim3 = self:createHeroAnim3()
	self.m_yato[3]:addChild(anim3)

	self.text_scroll = ccbNode:scrollViewForName("text_scroll")
	self.content_node = ccbNode:nodeForName("content_node")
	self.m_time_node = ccbNode:nodeForName("m_time_node")

	self:createTimeDown(self.m_time_node,self.m_tGameData.remain_time) --应该为90秒  3只羊驼将比赛跑完
	self.m_stage = 1; -- 起初进入第一阶段

	self.m_jingcai_cost = ccbNode:labelTTFForName("m_jingcai_cost")
	self.m_btn_buy = ccbNode:controlButtonForName("m_btn_buy")
	self.m_btn_buy:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
	self.m_encourage_num = ccbNode:labelTTFForName("m_encourage_num")
	self.m_trouble_num = ccbNode:labelTTFForName("m_trouble_num")

	self.m_encourage_num:setString(self.m_local_encourage_num)
	self.m_trouble_num:setString(self.m_local_trouble_num)
	self.m_bout = ccbNode:labelTTFForName("m_bout")
	self.m_bout:setString(self.m_tGameData.bout)
	-- self:displaying()
	
	return ccbNode;

end

function ui_yato_running_gaming:getFirstByTab(tempTab)
	local tempTab = tempTab or {}
	if tempTab[1] > tempTab[2] and tempTab[1] > tempTab[3] then
		return 1
	elseif tempTab[2] > tempTab[1] and tempTab[2] > tempTab[3] then
		return 2
	elseif tempTab[3] > tempTab[2] and tempTab[3] > tempTab[1] then
		return 3
	else 
		return 0
	end

end





function ui_yato_running_gaming.refreshData( self )
	local function responseMethod( tag,gameData )
	    if gameData then
	        local data = gameData:getNodeWithKey("data")  --重新刷新数据
	        self.m_tGameData = json.decode(data:getFormatBuffer())
			self.m_local_encourage_num = self.m_tGameData.cheer_remain
			self.m_local_trouble_num = self.m_tGameData.mess_remain
	    end
   end
	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_index"),http_request_method.GET,nil,"yato_running_index",false)
end


function ui_yato_running_gaming.createLogs( self )  --游戏log信息显示
    local viewSize = self.content_node:getContentSize()
    local contentText = ""
    local openMsg1 = ""
    self.msg_list = self.msg_list.."\n"..self.m_msg
    local openMsg = self.msg_list
    local openMsg_tab = {}
    local length = #openMsg1 or 0
    contentText = openMsg
    if not self.m_msg_lab then
    	local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(viewSize.width,0),textAlignment = kCCTextAlignmentLeft, verticalTextAlignment = kCCVerticalTextAlignmentCenter,fontSize = 9})
		self.m_msg_lab = tempLabel
    	self.text_scroll:addChild(tempLabel)
	end
	self.m_msg_lab:setString(self.msg_list)
    local tempSize = self.m_msg_lab:getContentSize()
    self.text_scroll:setContentSize(CCSizeMake(viewSize.width,tempSize.height))
    self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height-5), false)
    self.text_scroll:setDirection(kCCScrollViewDirectionVertical)
    self.text_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
end


function ui_yato_running_gaming.encourage( self,num )
	if self.m_tGameData.now_step == 6 then
		game_util:addMoveTips({text = "Giai đoạn Xung Kích không thể tiến hành Tiếp Sức!"})
		return
	end
	local function responseMethod( tag,gameData )
  		if gameData then
            local data2 = gameData:getNodeWithKey("user_status")  --重新刷新数据
            self.m_tGameData2 = json.decode(data2:getFormatBuffer())
            local data = gameData:getNodeWithKey("data")  --重新刷新数据
            self.m_tGameData = json.decode(data:getFormatBuffer())
			self.m_local_encourage_num = self.m_tGameData.cheer_remain
			self.m_local_trouble_num = self.m_tGameData.mess_remain
        end
        self.m_msg = self.m_tGameData2.show_name.."Tiến hành Tiếp Sức cho Tuần Lộc số " .. num .. "!" .. "Tuần Lộc số " .. num .. " cảm nhận được một nguồn sức mạnh đang phun trào!"
      	game_scene:addPop("ui_yato_running_showing",{showtype = 1,num = num,Poptype = 1, version_num= self.version_num});--播放捣乱动画
		self:refreshData()
		self.m_encourage_num:setString(self.m_local_encourage_num)
		self.m_trouble_num:setString(self.m_local_trouble_num)
		self:createLogs()--  显示log
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_affect"),http_request_method.GET,{affec = 1,sort = num},"yato_running_affect")
end

function ui_yato_running_gaming.trouble( self,num )	
	if self.m_tGameData.now_step == 6 then
		game_util:addMoveTips({text = "Trong giai đoạn Xung Kích không thể tiến hành Đảo Loạn!"})
		return
	end

	local function responseMethod( tag,gameData )
			if gameData then
	          local data2 = gameData:getNodeWithKey("user_status")  --重新刷新数据
	        self.m_tGameData2 = json.decode(data2:getFormatBuffer())
	        local data = gameData:getNodeWithKey("data")  --重新刷新数据
	        self.m_tGameData = json.decode(data:getFormatBuffer())
			self.m_local_encourage_num = self.m_tGameData.cheer_remain
			self.m_local_trouble_num = self.m_tGameData.mess_remain
	    end

	   	self.m_msg = self.m_tGameData2.show_name.."Tiến hành Tiếp Sức " .. "Thực hiện Ném Đá số "..num.. ".".."Tuần Lộc số " .. num.. " bị trúng đầu gối 1 cú rồi."
	 	game_scene:addPop("ui_yato_running_showing",{showtype = 2,num = num,Poptype = 2,version_num = self.version_num});--播放捣乱动画
		self:refreshData()

		self.m_encourage_num:setString(self.m_local_encourage_num)
		self.m_trouble_num:setString(self.m_local_trouble_num)
		self:createLogs()--  显示log
	end
		
	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_affect"),http_request_method.GET,{affec = -1,sort = num},"yato_running_affect")
end

function ui_yato_running_gaming:createTimeLab(parentNode,time)
	local time = time or 0
	for i = self.m_tGameData.now_step+1,game_util:getTableLen(self.m_yato_running_main) do
		if self.m_yato_running_main[tostring(i+1)] then
			time = time + self.m_yato_running_main[tostring(i+1)].time
		end
	end
	local function timeEndFunc(  )
		
	end
	local countdownLabel = game_util:createCountdownLabel(time,timeEndFunc,8, 3);
    countdownLabel:setColor(ccc3(74, 249, 69))
    countdownLabel:setAnchorPoint(ccp(0,0.5))
    local tempcontent = parentNode:getContentSize()
    countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.6))
    parentNode:addChild(countdownLabel,11,11) 
end

function ui_yato_running_gaming.createTimeDown( self,parentNode,time_count_down,shwoType,isclose )
	time_count_down = time_count_down + 1
    local function timeEndFunc()
    	if self.m_tGameData.now_step == 6 then  --最后冲刺结束  跳转 结果
            if self.total_list[1] > self.total_list[2] then 
            	if self.total_list[1]> self.total_list[3] then -- 1Đang đợi...最快
            		self.m_right = 1 --1Đang đợi...
            		if self.total_list[2] >self.total_list[3] then 
            			self.m_N2 = 2
            			self.m_N3 = 3
            		else
            			self.m_N2 = 3
            			self.m_N3 = 2
            		end
            	else
            		self.m_right = 3 --3Đang đợi...
            		self.m_N2 = 1
            		self.m_N3 = 2
            	end
            else 
            	if   self.total_list[3]  < self.total_list[2] then 
            		self.m_right = 2 
            		if  self.total_list[3]< self.total_list[1] then 
            			self.m_N2 = 1
            			self.m_N3 = 3
            		else
            			self.m_N2 =3
            			self.m_N3 = 1
            		end
            	else 
            		self.m_right = 3
            		self.m_N2 = 2
            		self.m_N3 = 1
            	end
            end
			if self.m_right == self.m_tGameData.apply  then 
				self.m_isright = 1 
			else
				self.m_isright = 0
			end
	        --yatoNum  羊驼到达终点时  名次
	    	--停止计时器  羊驼的移动
		    scheduler:unscheduleAll()
		    game_scene:addPop("ui_yato_running_result",{gameData = self.m_tGameData,m_isright = self.m_isright,N1 = self.m_right,N2 = self.m_N2,N3 = self.m_N3,bout = self.m_tGameData.bout})
    	elseif  self.m_tGameData.now_step < 6  and self.m_tGameData.now_step >1 then --  否则 重新刷新 time
    		local function responseMethod( tag,gameData )
		         if gameData then
                    local data = gameData:getNodeWithKey("data")  --重新刷新数据
                    self.m_tGameData = json.decode(data:getFormatBuffer())
                    self.m_local_encourage_num = self.m_tGameData.cheer_remain
					self.m_local_trouble_num = self.m_tGameData.mess_remain

            		if self.m_tGameData.now_step == 6 then
						local index = self:getFirstByTab(self.m_tGameData.total_list)
						self.m_tGameData.total_list[index] = 100
					end

                    for i=1,3 do
                    	self.m_yato_speed[i]=(self.m_tGameData.total_list[i]-self.m_tGameData.complete_list[i])/self.m_tGameData.remain_time
                    	self.m_yato_distance[i] = self.m_tGameData.complete_list[i]
						self.m_yato[i]:setPositionX((self.m_yato_distance[i]/100)*350)
                    end
		            self.m_time_node:removeAllChildrenWithCleanup(true)
					self:createTimeDown(self.m_time_node,self.m_tGameData.remain_time) --应该为90秒  3只羊驼将比赛跑完
					scheduler:unscheduleAll()
		  			self:refreshUi()
                end
		    end  
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_index"),http_request_method.GET,nil,"yato_running_index",false)

	  	end
    end
    parentNode:removeAllChildrenWithCleanup(true)
    local shwoType = shwoType or 3
    local countdownLabel = game_util:createCountdownLabel(time_count_down,timeEndFunc,8, shwoType);
    countdownLabel:setColor(ccc3(74, 249, 69))
    countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    local tempcontent = parentNode:getContentSize()
    countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.6))
    parentNode:addChild(countdownLabel,10,10) 
    if self.m_tGameData.now_step ~= 1 then 
    	countdownLabel:setOpacity(0)
	end
	self:createTimeLab(parentNode,time_count_down)
end
--[[--
     创建卡牌动画
]]
function ui_yato_running_gaming.createHeroAnim1(self)
    local m_iAnim = nil;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local character_id = 74600
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(character_id));
    if  heroCfg then
        m_iAnim = game_util:createIdelAnim("alpaca5",0,heroData,heroCfg);
        if m_iAnim then
            m_iAnim:setRhythm(1);
            self:setHeroAnimName(m_iAnim,"impact")
            local itemSize = m_iAnim:getContentSize();
            m_iAnim:setAnchorPoint(ccp(0.5,0.5));
            m_iAnim:setPosition(ccp(5,7))
        end
    end
    return m_iAnim;
end
function ui_yato_running_gaming.createHeroAnim2(self)
    local m_iAnim = nil;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local character_id = 74700
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(character_id));
    if  heroCfg then
        m_iAnim = game_util:createIdelAnim("alpaca6",0,heroData,heroCfg);
   
        if m_iAnim then
            m_iAnim:setRhythm(1);
            self:setHeroAnimName(m_iAnim,"impact")
            local itemSize = m_iAnim:getContentSize();
            m_iAnim:setAnchorPoint(ccp(0.5,0.5));
            m_iAnim:setPosition(ccp(5,7))
        end
    end
    return m_iAnim;
end
function ui_yato_running_gaming.createHeroAnim3(self)
    local m_iAnim = nil;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local character_id = 74800
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(character_id));
    if  heroCfg then
        m_iAnim = game_util:createIdelAnim("alpaca4",0,heroData,heroCfg);
   
        if m_iAnim then
            m_iAnim:setRhythm(1);
            self:setHeroAnimName(m_iAnim,"impact")
            local itemSize = m_iAnim:getContentSize();
            m_iAnim:setAnchorPoint(ccp(0.5,0.5));
            m_iAnim:setPosition(ccp(5,7))
        end
    end
    return m_iAnim;
end
function ui_yato_running_gaming.setHeroAnimName( self, parentNode, animName )

	local function animEnd(animNode,theId,lableName)
	    game_anim:playSection(parentNode,lableName);
	end
	game_anim:playSection(parentNode , animName);
    parentNode:registerScriptTapHandler(animEnd);
end

--刷新UI
function ui_yato_running_gaming.refreshUi( self )
	self.m_jingcai_cost:setString(self.m_yato_running_main[tostring(self.m_tGameData.now_step +1)].lottery_price) 
	local durTime = 0
 	local function globalSchedulerFunc(dt)
    	durTime = durTime + dt;
    	if durTime >= 0.1 then
	   		if  self.m_tGameData.now_step == 1  or self.m_tGameData.now_step == 0 then 
		   		local function responseMethod( tag,gameData )
		   			scheduler.unscheduleAll()
		            game_scene:enterGameUi("ui_yato_running_main_new",{gameData = gameData});
		        end
		        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_index"),http_request_method.GET,nil,"yato_running_index")
	   			return
	   		else
	        	for i=1,3 do
					self.m_yato_distance[i] =  self.m_yato_distance[i] + self.m_yato_speed[i]/3
					self.m_yato[i]:setPositionX((self.m_yato_distance[i]/100)*350)
				end
	       	end
    	end  
	end
	self.globalcheduler = scheduler.schedule(globalSchedulerFunc,1/3,false,false);
	self.m_bout:setString(self.m_tGameData.bout)
end

--初始化
function  ui_yato_running_gaming.init( self,t_params )
	local t_params = t_params or {}
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then  
		local data = t_params.gameData:getNodeWithKey("data");
		self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
	else
		self.m_tGameData = {};
	end
	self.version_num = self.m_tGameData.version
	self.m_local_encourage_num = self.m_tGameData.cheer_remain
	self.m_local_trouble_num = self.m_tGameData.mess_remain
	self.total_list = self.m_tGameData.total_list
	self.complete_list  = self.m_tGameData.complete_list

	self.m_yato_running_main =json.decode(getConfig(game_config_field.yato_running_main):getFormatBuffer())

	
end

function ui_yato_running_gaming.create( self,t_params )
	self:init(t_params);
	self.m_popUi = self:createUi();
	self:refreshUi();
	return self.m_popUi;
end

return ui_yato_running_gaming;	