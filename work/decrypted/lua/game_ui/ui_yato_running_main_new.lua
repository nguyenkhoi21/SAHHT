local ui_yato_running_main_new = {
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
}

function ui_yato_running_main_new:destroy()
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



function ui_yato_running_main_new:back()
	self:destroy()
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
end


function ui_yato_running_main_new:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()

		if btnTag == 100 then --根据Tag值来处理按钮点击事件
			self:back();
		elseif btnTag == 101 then  --活动说明
			game_scene:addPop("game_active_limit_detail_pop",{enterType = 193})
		elseif btnTag == 102  then  -- 报名
			if self.m_selected == nil  then
				if self.m_tGameData.now_step  < 2   then 
				 	game_util:addMoveTips({text = "Hãy chọn một chú Tuần Lộc"});
					return
				end
			end
			for i=1,3 do
				self.m_btn_yato[i]:setVisible(false)
			end
			if self.m_tGameData.apply_flag  == 1 and self.m_tGameData.apply == 0 then  --参与
				local function responseMethod( tag,gameData )
		            game_scene:addPop("ui_yato_running_warning",{gameData = gameData});
		        end
		        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_apply"),http_request_method.GET,nil,"yato_running_apply") 	
		    elseif self.m_tGameData.apply_flag == 0 and self.m_tGameData.apply ~= 0 then --已报名 再次进入界面 点击按钮
       			local function responseMethod( tag,gameData )
	           		 game_scene:addPop("ui_yato_running_gaming",{gameData =gameData});
	        	end
	        	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_index"),http_request_method.GET,nil,"yato_running_index")
		   	elseif self.m_tGameData.apply == 0 then --未报名  按钮 变为 已报名
				local function responseMethod( tag,gameData )
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
			self.m_selected = 1
			cclog("Number1 is  lighting")
			self.m_star[1]:setVisible(true)
			self.m_star[2]:setVisible(false)
			self.m_star[3]:setVisible(false)
			self.anim[1]:setColor(ccc3(255,255,255))	
			self.anim[2]:setColor(ccc3(100,100,100))	
			self.anim[3]:setColor(ccc3(100,100,100))	
		elseif btnTag == 112 then 
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
			self.m_selected = 3
			cclog("Number3 is  lighting")
		end
	end
	local ccbNode = luaCCBNode:create()
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
	ccbNode:openCCBFile("ccb/ui_yato_running_main.ccbi");

	self.m_btn_close = ccbNode:controlButtonForName("m_btn_close")
	self.m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

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

	self.m_this_reward_node = ccbNode:nodeForName("m_this_reward_node")
	self.m_lucky_reward_node = ccbNode:nodeForName("m_lucky_reward_node")

 	if self.m_tGameData.apply == 0 then 
		for i=1,3 do
			self.m_selected = nil
			self.m_btn_yato[i]:setVisible(true)
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_join.png"),CCControlStateNormal);
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_join.png"),CCControlStateHighlighted);
		end		
 	elseif	self.m_tGameData.apply ~= 0   then 
	 	if	self.m_tGameData.now_step == 0 then--报名le 
        	self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_has_join.png"),CCControlStateNormal);
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_has_join.png"),CCControlStateHighlighted);	
			self.m_star[self.m_tGameData.apply]:setVisible(true)
			self.anim[self.m_tGameData.apply]:setColor(ccc3(255,255,255))
        	self.m_btn_join:setTouchEnabled(false)

			for i=1,3 do
				self.m_btn_yato[i]:setVisible(false)
			end		
		else 
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_join2.png"),CCControlStateNormal);
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_join2.png"),CCControlStateHighlighted);	
		end
	end
	self:createReward(self.m_this_reward_node,1)
	self:createReward(self.m_lucky_reward_node,2)

	return ccbNode
end


--[[--
    创建卡牌动画
]]
function ui_yato_running_main_new.createHeroAnim1(self)
    local m_iAnim = nil;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local character_id = 74600
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


function ui_yato_running_main_new.createHeroAnim2(self)
    local m_iAnim = nil;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local character_id = 74700
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


function ui_yato_running_main_new.createHeroAnim3(self)
    local m_iAnim = nil;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    
    local character_id = 74800
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
function ui_yato_running_main_new.setHeroAnimName( self, parentNode, animName )
	local function animEnd(animNode,theId,lableName)
	    game_anim:playSection(parentNode,lableName);
	end
	game_anim:playSection(parentNode , animName);
    parentNode:registerScriptTapHandler(animEnd);
end


--[[
    奖励列表
]]
function ui_yato_running_main_new.createRewardTable(self,viewSize,count,rewardList)

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
function ui_yato_running_main_new.createRewardIcon( self ,ccbNode,reward)

	if reward and #reward > 0 then -- 有奖励
       ccbNode:setVisible(true)
        ccbNode:removeAllChildrenWithCleanup(true)
        local tempTable = self:createRewardTable(ccbNode:getContentSize(),#reward,reward)
        ccbNode:addChild(tempTable)
    else  -- 无奖励
        sccbNode:setVisible(false)
    end
end


function ui_yato_running_main_new.createReward( self ,ccbNode,rewardtype)
	-- body
	local  yatocfg = getConfig(game_config_field.yato_running_reward)
	local yatocfg_num = yatocfg:getNodeWithKey(tostring(self.m_version));
	yatocfg_num2 = json.decode(yatocfg_num:getFormatBuffer()) or {};
	if rewardtype == 1 then --竞猜奖励
	local reward = yatocfg_num2.vip_win_reward  -- 配置
	self:createRewardIcon(ccbNode,reward)
	
	elseif rewardtype == 2 then --幸运奖励
	local reward = yatocfg_num2.vip_win_lucky_reward  -- 配置	
	self:createRewardIcon(ccbNode,reward)
	end
end


function ui_yato_running_main_new.getTime(self,now_step,remain_time)
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


function ui_yato_running_main_new.createTimeDown( self,parentNode,time_count_down,shwoType,isclose )
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



function ui_yato_running_main_new.refreshData( self )
	local function responseMethod( tag,gameData )
       	if gameData then
        	local data = gameData:getNodeWithKey("data")  --重新刷新数据
        	self.m_tGameData = json.decode(data:getFormatBuffer())
        	if self.m_tGameData.now_step < 2 then
	  			self.m_win_list = self.m_tGameData.get_all_win_sort
	  			self:refreshUi()
        	elseif self.m_tGameData.now_step >= 2 then
        		if self.m_tGameData.apply == 0 then
	        		local function responseMethod( tag,gameData )
			            game_scene:addPop("ui_yato_running_warning",{gameData = gameData});
			        end
			        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_apply"),http_request_method.GET,nil,"yato_running_apply") 	
        		else
        			game_scene:addPop("ui_yato_running_gaming",{gameData =gameData})
        		end
			end
    	end
    end
	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_index"),http_request_method.GET,nil,"yato_running_index")
end

function ui_yato_running_main_new.refreshUi(self)

	for i = 1,5 do   --显示 到已进行的轮次 获胜羊驼  及Thưởng Lớn người chơi
	 	if i < self.m_tGameData.bout then --读取第几轮
			if self.m_tGameData.lucky_list[i]  then 
 				if self.m_tGameData.lucky_list[i] ~= nil then 
 					self.m_player[i]:setString(self.m_tGameData.lucky_list[i][1].."\n"..self.m_tGameData.lucky_list[i][2])
 				else
 					self.m_player[i]:setString("")
 				end
	 		end
			self.m_win[i]:setVisible(true)
			self.m_player[i]:setColor(ccc3(255,255,255))
			self.m_win[i]:setColor(ccc3(255,255,255))
	 		self.m_win[i]:setString("Tuần Lộc"..self.m_tGameData.get_all_win_sort[i].."Đang đợi...")
		elseif 	i == self.m_tGameData.bout then 
		 	self.m_player[i]:setString("Đang đợi...")
		 	self.m_player[i]:setColor(ccc3(0,255,0))
			self.m_win[i]:setVisible(true)
			self.m_win[i]:setColor(ccc3(0,255,0))
			self.m_win[i]:setString("Đang đợi...")
		else
			self.m_player[i]:setString("")
			self.m_win[i]:setVisible(false)
		end
	end
	
	if self.m_tGameData.now_step == 0  then --报名阶段
		self.m_label1:setString("Đếm ngược bắt đầu trò chơi:")
		self.m_left_time_node:removeAllChildrenWithCleanup(true)
		self:createTimeDown(self.m_left_time_node,self.m_tGameData.remain_time)
	elseif  self.m_tGameData.now_step  == 1 then 
		self.m_label1:setString("Chuẩn bị đếm ngược:")
		self.m_left_time_node:removeAllChildrenWithCleanup(true)
		self:createTimeDown(self.m_left_time_node,self.m_tGameData.remain_time)--时间
	elseif self.m_tGameData.now_step  ~= 1  and self.m_tGameData.now_step  ~=0 then 
		self.m_label1:setString("Đếm ngược kết thúc vòng này:")
		self.m_left_time_node:removeAllChildrenWithCleanup(true)
		self:createTimeDown(self.m_left_time_node,self:getTime(self.m_tGameData.now_step ,self.m_tGameData.remain_time))--时间有后端传入 假定活动需要90秒
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

		end
	else --游戏未开始
		if self.m_tGameData.apply == 0 then  -- 未报名 	
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_join.png"),CCControlStateNormal);		
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_join.png"),CCControlStateHighlighted);	
			for i=1,3 do
				self.m_btn_yato[i]:setVisible(true)
			end
		else --已报名
			for i=1,3 do
				self.m_btn_yato[i]:setVisible(false)
			end
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_has_join.png"),CCControlStateNormal);
			self.m_btn_join:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_has_join.png"),CCControlStateHighlighted);
        	self.m_btn_join:setTouchEnabled(false)
			
		end
	end

end

 --初始化数据
function ui_yato_running_main_new.init(self,t_params )
 	self.t_params = t_params or {}
 	if self.t_params.gameData ~= nil and tolua.type(self.t_params.gameData) == "util_json" then 
 		local data = self.t_params.gameData:getNodeWithKey("data");
 		self.m_tGameData = json.decode(data :getFormatBuffer()) or {};
 	else
 		self.m_tGameData = {}
	end
	self.m_version = self.m_tGameData.version
	self.m_win_list = self.m_tGameData.get_all_win_sort
end

--创建 ui入口  初始化数据
function ui_yato_running_main_new.create( self,t_params)
	self:init(t_params)
	local scene = CCScene:create()
	scene = self:createUi()
	self:refreshUi()
	return scene
end 
return ui_yato_running_main_new;

