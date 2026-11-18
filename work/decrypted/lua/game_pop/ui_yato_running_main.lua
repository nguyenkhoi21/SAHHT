local ui_yato_running_main = {
	m_root_layer = nil,
	m_popUi = nil,
	m_tGameData = nil,
	m_btn_close = nil,
	m_btn_yato = {}, --选择羊驼的按钮
	m_yato_sp = {}, --比赛结果获胜羊驼
	m_player = {}, -- 比赛结果中 获胜玩家
	m_btn_join = nil,
	m_selected = nil,--表示玩家选择羊驼的编Đang đợi...
	m_regulation =nil,
	m_this_reward_node = nil,
	m_lucky_reward_node = nil,
	m_star = {},
	m_star_bg ={},
	m_label1 = nil,
	m_left_time_node = nil,
	anim ={},
	m_win = {},
	m_win_list	= {},
	t_params = {},
	m_version = nil,
};

--[[--销毁ui]]
function ui_yato_running_main.destroy(self )
	-- body
	self.m_root_layer = nil;
	self.m_popUi = nil;
	self.m_tGameData = nil;
	self.m_btn_close = nil;
	self.m_btn_yato = {};
	self.m_yato_sp = {};
	self.m_player = {};
	self.m_btn_join = nil;
	self.m_selected = nil;
	self.m_regulation = nil;
	self.m_this_reward_node = nil;
	self.m_lucky_reward_node = nil;
	self.m_star = {};
	self.m_star_bg = {};
	self.m_label1 = nil;
	self.m_left_time_node = nil;
	self.anim = {};
	self.m_win = {};
	self.m_win_list = {};
	self.t_params = {};
	self.m_version = nil;
end

--[[--返回]]
function ui_yato_running_main.back(self)
	game_scene:removePopByName("ui_yato_running_main");
	self:destroy()
end

--[[--创建ui]]
function ui_yato_running_main.createUi( self )
	local ccbNode = luaCCBNode:create();
	local  function onMainBtnClick(target,event)
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag();
		if btnTag == 100 then --根据Tag值来处理按钮点击事件
			self:back();
		elseif btnTag == 101 then  --活动说明
			game_scene:addPop("game_active_limit_detail_pop",{openType = "yato"})
		elseif btnTag == 102  then  -- 报名
			--如果比赛已经开始了  跳转到 提醒界面
			if self.m_selected == nil  then
				if self.m_tGameData.now_step  < 2   then 
				 game_util:addMoveTips({text = "请选择一只羊驼..."});
					return
				end
			end
			if self.m_tGameData.now_step >= 2 then
			  -- game_util:addMoveTips({text = "冲刺阶段无法进入..."});
				self:refreshData()
				
			end
			-- if self.m_tGameData.now_step == 5  and self.m_tGameData.remain_time <= 10 then
			-- 	self:refreshData()
			-- end
			for i=1,3 do
				self.m_btn_yato[i]:setVisible(false)
			end		
			if self.m_tGameData.apply_flag  == 1 and self.m_tGameData.apply == 0 then  --参与
				
					local function responseMethod( tag,gameData )
			            -- body
			            game_scene:addPop("ui_yato_running_warning",{gameData = gameData});
			        end
			        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_apply"),http_request_method.GET,nil,"yato_running_apply") 	
		    elseif self.m_tGameData.apply_flag  == 0 and self.m_tGameData.apply ~= 0 then --已报名 再次进入界面 点击按钮
		    		--选羊了  直接进入
		       			local function responseMethod( tag,gameData )
			            -- body
			           		 game_scene:addPop("ui_yato_running_gaming",{gameData =gameData});
			           		 self:back()
			        	end
			        	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_index"),http_request_method.GET,nil,"yato_running_index")
		   	end
		   	if	self.m_tGameData.apply == 0 then --未报名  按钮 变为 已报名
				local function responseMethod( tag,gameData )
	            -- body
              		if self.m_tGameData.now_step <2 then 
        	        	self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_has_join.png"),CCControlStateNormal);
        				self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_has_join.png"),CCControlStateHighlighted);	
        				self.m_btn_join:setTouchEnabled(false)
        				self:refreshData()
        			end
	       		end
	        	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_apply"),http_request_method.GET,{sort = self.m_selected},"yato_running_apply")	
			end
		elseif btnTag == 111 then 
			--羊驼1Đang đợi... 变亮  23Đang đợi...变暗
			self.m_selected = 1
			cclog("Number1 is  lighting")
			self.m_star[1]:setVisible(true)
			self.m_star[2]:setVisible(false)
			self.m_star[3]:setVisible(false)
			self.anim[1]:setColor(ccc3(255,255,255))	
			self.anim[2]:setColor(ccc3(100,100,100))	
			self.anim[3]:setColor(ccc3(100,100,100))	
		elseif btnTag == 112 then 
			-- 羊驼2Đang đợi... 变亮 13 变暗
			self.m_selected = 2
			cclog("Number2 is  lighting")
			self.m_star[1]:setVisible(false)
			self.m_star[2]:setVisible(true)
			self.m_star[3]:setVisible(false)
			self.anim[2]:setColor(ccc3(255,255,255))	
			self.anim[1]:setColor(ccc3(100,100,100))	
			self.anim[3]:setColor(ccc3(100,100,100))	
		elseif btnTag ==113 then
		 	self.m_star[1]:setVisible(false)
			self.m_star[2]:setVisible(false)
			self.m_star[3]:setVisible(true)
			self.anim[3]:setColor(ccc3(255,255,255))	
			self.anim[1]:setColor(ccc3(100,100,100))	
			self.anim[2]:setColor(ccc3(100,100,100))	

			--羊驼3Đang đợi... 变亮 12 变暗
			self.m_selected = 3
			cclog("Number3 is  lighting")
		end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
	ccbNode:openCCBFile("ccb/ui_yato_running_main.ccbi");
	


	--设置layer层级管理  阻断触摸下一层
	local m_root_layer = ccbNode:layerColorForName("m_root_layer")
	local  function onTouch( eventType,x,y)
		-- body
		if eventType == "began" then 
			return true;
		end
	end
	self.m_root_layer = ccbNode:layerForName("m_root_layer")
	self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-2,true);
	self.m_root_layer:setTouchEnabled(true);

	-- local node1 = ccbNode:nodeForName("node1")

	self.m_btn_close = ccbNode:controlButtonForName("m_btn_close")
	self.m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
	-- self.m_btn_close:setOpacity(0)

	self.m_btn_join = ccbNode:controlButtonForName("m_btn_join")
	self.m_btn_join:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

	self.m_regulation = ccbNode:controlButtonForName("m_regulation")
	self.m_regulation:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
	 for i=1,3 do
	 	self.m_btn_yato[i] = ccbNode:controlButtonForName("m_btn_yato"..i)
	 	self.m_btn_yato[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
	 	self.m_btn_yato[i]:setOpacity(0)
	 	self.m_star[i] = ccbNode:spriteForName("m_star"..i)
	 	self.m_star[i]:setVisible(false)
	 	self.m_star_bg[i] = ccbNode:spriteForName("m_star_bg"..i)
	 end

	 --创建 待机动画  
	 self.m_yato_node1 = ccbNode:nodeForName("m_yato_node1")
	 self.m_yato_node2 = ccbNode:nodeForName("m_yato_node2")
	 self.m_yato_node3 = ccbNode:nodeForName("m_yato_node3")
	 self.anim[1] = self:createHeroAnim1()
	 self.anim[1]:setColor(ccc3(100,100,100))
	 self.m_yato_node1:addChild(self.anim[1])
	 self.anim[2] = self:createHeroAnim2()
	 self.anim[2]:setColor(ccc3(100,100,100))	 
	 self.m_yato_node2:addChild(self.anim[2]) 
	 self.anim[3] = self:createHeroAnim3()
	 self.anim[3]:setColor(ccc3(100,100,100))	
	 self.m_yato_node3:addChild(self.anim[3])
	 for i=1,5 do
	 	self.m_player[i] = ccbNode:labelTTFForName("m_player"..i)
	 	self.m_yato_sp[i] = ccbNode:spriteForName("m_yato"..i)
	 	self.m_win[i] = ccbNode:labelTTFForName("m_win"..i)
	 end

	self.m_label1 = ccbNode:labelTTFForName("m_label1")
	self.m_number = ccbNode:labelTTFForName("m_number")
	self.m_left_time_node = ccbNode:nodeForName("m_left_time_node")
	--读取活动时间
	

		
	self.m_this_reward_node = ccbNode:nodeForName("m_this_reward_node")
	self.m_lucky_reward_node = ccbNode:nodeForName("m_lucky_reward_node")
	
 	if self.m_tGameData.apply == 0 then 
		for i=1,3 do
			self.m_selected = nil
			self.m_btn_yato[i]:setVisible(true)
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_join.png"),CCControlStateNormal);
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_join.png"),CCControlStateHighlighted);
		end		
	end
 	if	self.m_tGameData.apply ~= 0   then 
	 	if	 self.m_tGameData.now_step == 0 then--报名le 
        	self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_has_join.png"),CCControlStateNormal);
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_has_join.png"),CCControlStateHighlighted);	
			self.m_star[self.m_tGameData.apply]:setVisible(true)
			for i=1,3 do
				self.m_btn_yato[i]:setVisible(false)
			end		
		else 
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_join2.png"),CCControlStateNormal);
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_join2.png"),CCControlStateHighlighted);	
		end
	end
		
	--创建奖励icon
 

	self:createReward(self.m_this_reward_node,1)
	self:createReward(self.m_lucky_reward_node,2)

	
	return ccbNode;	
end
function ui_yato_running_main.createRewardIcon( self ,ccbNode,reward)

	if reward and #reward > 0 then -- 有奖励
       ccbNode:setVisible(true)
        ccbNode:removeAllChildrenWithCleanup(true)
        local tempTable = self:createRewardTable(ccbNode:getContentSize(),#reward,reward)
        ccbNode:addChild(tempTable)
    else  -- 无奖励
        sccbNode:setVisible(false)
    end
end
--[[
    奖励列表
]]
function ui_yato_running_main.createRewardTable(self,viewSize,count,rewardList)
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemCfg = rewardList[btnTag+1]
        game_util:lookItemDetal(itemCfg)
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 4; --列
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionHorizontal;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5,0.5))
            node:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            local itemGift = rewardList[index+1]
            local icon,name,count = game_util:getRewardByItemTable(itemGift)
            if icon then
                icon:setScale(0.5)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,2))
                node:addChild(icon,10)
            end

            local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
            button:setAnchorPoint(ccp(0.5,0.5))
            button:setPosition(node:getContentSize().width * 0.5, node:getContentSize().height * 0.5)
            button:setOpacity(0)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
            node:addChild(button)
            button:setTag( index )

            cell:addChild(node)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemCfg = rewardList[index+1]
            game_util:lookItemDetal(itemCfg)
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        
    end
    return TableViewHelper:create(params);
end

function ui_yato_running_main.getTime(self,now_step,remain_time)
	local   time = 0
	if	now_step == 1 then 
		time = 90+ remain_time
	elseif now_step  == 2 then
		time =70  +remain_time
	elseif now_step == 3 then
		time  = 50 +remain_time
	elseif now_step ==4 then 
		time = 30 +remain_time 
	elseif now_step == 5 then
		time = 10 +remain_time
	elseif now_step == 6 then 
		time =remain_time
	end
	return time;
end

--[[--
    创建卡牌动画
]]
function ui_yato_running_main.createHeroAnim1(self)
    local m_iAnim = nil;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local character_id = 74600--self.m_richman_plot["1"].character_id
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(character_id));
    if  heroCfg then
        m_iAnim = game_util:createIdelAnim("horse5",0,heroData,heroCfg);
        if m_iAnim then
            m_iAnim:setRhythm(1);
            self:setHeroAnimName(m_iAnim,"daiji")
            local itemSize = m_iAnim:getContentSize();
            m_iAnim:setAnchorPoint(ccp(0.5,0.5));
            m_iAnim:setPosition(ccp(5,7))
        end
    end
    return m_iAnim;
end
function ui_yato_running_main.createHeroAnim2(self)
    local m_iAnim = nil;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local character_id = 74700--self.m_richman_plot["1"].character_id
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(character_id));
    if  heroCfg then
        m_iAnim = game_util:createIdelAnim("horse6",0,heroData,heroCfg);
        if m_iAnim then
            m_iAnim:setRhythm(1);
            self:setHeroAnimName(m_iAnim,"daiji")
            local itemSize = m_iAnim:getContentSize();
            m_iAnim:setAnchorPoint(ccp(0.5,0.5));
            m_iAnim:setPosition(ccp(5,7))
        end
    end
    return m_iAnim;
end
function ui_yato_running_main.createHeroAnim3(self)
    local m_iAnim = nil;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    
    local character_id = 74800--self.m_richman_plot["1"].character_id
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(character_id));
    if  heroCfg then
        m_iAnim = game_util:createIdelAnim("horse7",0,heroData,heroCfg);
     
        if m_iAnim then
            m_iAnim:setRhythm(1);
            self:setHeroAnimName(m_iAnim,"daiji")
            local itemSize = m_iAnim:getContentSize();
            m_iAnim:setAnchorPoint(ccp(0.5,0.5));
            m_iAnim:setPosition(ccp(5,7))
        end
    end
    return m_iAnim;
end
function ui_yato_running_main.setHeroAnimName( self, parentNode, animName )
	local function animEnd(animNode,theId,lableName)
	    game_anim:playSection(parentNode,lableName);
	end
	game_anim:playSection(parentNode , animName);
    parentNode:registerScriptTapHandler(animEnd);
end
function ui_yato_running_main.createReward( self ,ccbNode,rewardtype)
	-- body
	local  yatocfg = getConfig(game_config_field.yato_running_reward)
	local yatocfg_num = yatocfg:getNodeWithKey(tostring(self.m_version));
	yatocfg_num2 = json.decode(yatocfg_num :getFormatBuffer()) or {};
	if rewardtype == 1 then --竞猜奖励
	local reward = yatocfg_num2.vip_win_reward  -- 配置
	self:createRewardIcon(ccbNode,reward)
	
	elseif rewardtype == 2 then --幸运奖励
	local reward = yatocfg_num2.vip_win_lucky_reward  -- 配置	
	self:createRewardIcon(ccbNode,reward)
	end
end


function ui_yato_running_main.createTimeDown( self,parentNode,time_count_down,shwoType,isclose )
	
    local function timeEndFunc()
    	self:refreshData()
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


function ui_yato_running_main.refreshData( self )
	local function responseMethod( tag,gameData )
       	if gameData then
        	local data = gameData:getNodeWithKey("data")  --重新刷新数据
			cclog2(data,"gameData-=----------------")
        	self.m_tGameData = json.decode(data:getFormatBuffer())
    		if self.m_tGameData.now_step ==2 then
    			game_scene:addPop("ui_yato_running_gaming",{gameData =gameData})
    			self:back()
    		elseif self.m_tGameData.now_step > 2 then 
        		self:refreshUi()
        		if self.m_tGameData.apply ~= 0 then --报名
           		 	game_scene:addPop("ui_yato_running_gaming",{gameData =gameData});
           		 	self:back()
	  			end
	  		elseif self.m_tGameData.now_step == 1 then
	  			self.m_win_list = self.m_tGameData.get_all_win_sort
	  			self:refreshUi()
        	end
    	end
        	-- cclog2(self.m_tGameData,"jhfoishgoahooqtuwo0-=====------------")
    end
	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_index"),http_request_method.GET,nil,"yato_running_index")
end


 --[[--刷新Ui]]
function ui_yato_running_main.refreshUi(self)


	for i = 1,5 do   --显示 到已进行的轮次 获胜羊驼  及Thưởng Lớn người chơi
	 	if i < self.m_tGameData.bout then --读取第几轮
	--显示比赛图标  及 Thưởng Lớn người chơi 的Đang đợi...
			if self.m_tGameData.lucky_list[i]  then 
	 			-- self.m_yato_sp[i]:setVisible(true)
	 				if self.m_tGameData.lucky_list[i] ~= nil then 
	 					self.m_player[i]:setString(self.m_tGameData.lucky_list[i][1].."\n"..self.m_tGameData.lucky_list[i][2])
	 				else
	 					self.m_player[i]:setString("")
	 				end
	 		end
			self.m_win[i]:setVisible(true)
	 		self.m_win[i]:setString("羊驼"..self.m_tGameData.get_all_win_sort[i].."Đang đợi...")

		elseif 	i == self.m_tGameData.bout then 
		 	self.m_player[i]:setString("Đang đợi...")
			self.m_win[i]:setVisible(true)
			-- cclog2(self.m_tGameData.get_all_win_sort[1],"pilipala-------------")
			-- self.m_win[i]:setString("羊驼"..self.m_tGameData.get_all_win_sort[i].."Đang đợi...")
			self.m_win[i]:setString("Đang đợi...")

		 	-- self.m_yato_sp[i]:setVisible(true)
		else
			self.m_player[i]:setString("")
		--  				--图片隐藏掉
			-- self.m_yato_sp[i]:setVisible(false)
			self.m_win[i]:setVisible(false)
		end
	end
	

	if self.m_tGameData.now_step == 0  then --报名阶段
		-- self.m_left_time_node:setVisible(true)
		self.m_label1:setString("Đếm ngược bắt đầu trò chơi:")
		self.m_left_time_node:removeAllChildrenWithCleanup(true)
		self:createTimeDown(self.m_left_time_node,self.m_tGameData.remain_time)
	elseif  self.m_tGameData.now_step  == 1 then 
		-- self.m_left_time_node:setVisible(true)
		self.m_label1:setString("Chuẩn bị đếm ngược:")
	
		-- cclog2(self.m_tGameData.remain_time,"self.m_tGameData.remain_time=---------=-=-=-=-=-=-=-")
		self.m_left_time_node:removeAllChildrenWithCleanup(true)
		self:createTimeDown(self.m_left_time_node,self.m_tGameData.remain_time)--时间
	elseif self.m_tGameData.now_step  ~= 1  and self.m_tGameData.now_step  ~=0 then 
		-- self.m_left_time_node:setVisible(true)--其他阶段时间倒计时
		-- if self.m_tGameData.apply ~= 0 then 
		-- --进入赛场
		-- 		-- local function responseMethod( tag,gameData )
		-- 	 --            -- body
		-- 		--            		game_scene:addPop("ui_yato_running_gaming",{gameData = gameData})
		-- 		--        			-- self:back()
				   	
		-- 		--  end
		        
		--   --       network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_index"),http_request_method.GET,nil,"yato_running_index")
		--   --       cclog("9999999999")
		-- elseif 	self.m_tGameData.apply == 0 then
 			self.m_label1:setString("Đếm ngược kết thúc vòng này:")
			self.m_left_time_node:removeAllChildrenWithCleanup(true)
			self:createTimeDown(self.m_left_time_node,self:getTime(self.m_tGameData.now_step ,self.m_tGameData.remain_time))--时间有后端传入 假定活动需要90秒
		-- end
	end
 	self.m_number:setString(self.m_tGameData.bout)--获取数据  是第几轮

 	
--判断游戏是否开始   
	if self.m_tGameData.now_step >= 2 then  --游戏开始了
		--判断是否报名 
		for i=1,3 do
			self.m_btn_yato[i]:setVisible(false)
		end
		if  self.m_tGameData.apply == 0 then --未报名
			--按钮显示 参与
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_join2.png"),CCControlStateNormal);		
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_join2.png"),CCControlStateHighlighted);	
		elseif self.m_tGameData.apply ~= 0 then   --报名了
			--显示 选择的羊驼  点亮
				self.m_star[self.m_tGameData.apply]:setVisible(true)
				self.anim[self.m_tGameData.apply]:setColor(ccc3(255,255,255))
				self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_enter.png"),CCControlStateNormal);		
				self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_enter.png"),CCControlStateHighlighted);	
				-- local function responseMethod( tag,gameData )
	   --          -- body
	          
	   --          	cclog2(self.m_tGameData,"daodishidsha '[------")
		  --          	game_scene:addPop("ui_yato_running_gaming",{gameData = self.t_params.gameData})
		  --      		self:back()
		   	
		  --       end
		        
		  --       network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_index"),http_request_method.GET,nil,"yato_running_index")
		  --       cclog("88888888")
		end
	else --游戏未开始
		--判断 玩家是否报名 
		
		if self.m_tGameData.apply == 0 then  -- 未报名 	
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_join.png"),CCControlStateNormal);		
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_join.png"),CCControlStateHighlighted);	
			for i=1,3 do
				self.m_btn_yato[i]:setVisible(true)
			end
			--按钮显示  报名
		else --已报名
			--按钮 显示 已报名
			for i=1,3 do
				self.m_btn_yato[i]:setVisible(false)
			end
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_has_join.png"),CCControlStateNormal);
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_has_join.png"),CCControlStateHighlighted);
			
		end
	end
end

 --初始化数据
function ui_yato_running_main.init(self,t_params )
 	-- body
 	self.t_params = t_params or {}
 	if self.t_params.gameData ~= nil and tolua.type(self.t_params.gameData) == "util_json" then 
 		local data = self.t_params.gameData:getNodeWithKey("data");
 		self.m_tGameData = json.decode(data :getFormatBuffer()) or {};
 	else
 		self.m_tGameData = {}
	 end
	 cclog2(self.m_tGameData,"      ui_yato_running_main  ......... init")
	 self.m_version = self.m_tGameData.version
	
	self.m_win_list = self.m_tGameData.get_all_win_sort
	
end

--创建 ui入口  初始化数据
function ui_yato_running_main.create( self,t_params)
 	-- body
 	self:init(t_params);
 	self.m_popUi = self:createUi();
 	self:refreshUi();
 	return self.m_popUi;

end 
return ui_yato_running_main;