--大富翁
local game_monopoly_server_pop = {
	m_tGameData = nil,
	m_close_btn = nil,
	m_root_layer = nil,
	m_startAnim_node = nil,
	m_anim_node = nil,
	m_heroAnim_node = nil,
	m_surplus_lab = nil,
	m_des_lab1 = nil,
	m_throw_btn = nil,
	m_spDi_tab = nil,
	m_current_index = nil,
	m_shop_btn = nil,
	m_gift_node = nil,
	m_gift_sp = nil,
	m_getGift_btn = nil,
	m_btn_tab = nil,
	m_jindutiaoBg_sp = nil,
	m_richman_plot = nil,
	m_isAnim_Flag = nil,
	m_event_id = nil,
	m_TimeDown_node = nil,
	m_resetTimeDown_node = nil,
}
function game_monopoly_server_pop.destroy( self )
	cclog("--------------game_monopoly_server_pop.destorty-----------")
	self.m_close_btn = nil;
	self.m_root_layer = nil;
	self.m_tGameData = nil;
	self.m_startAnim_node = nil;
	self.m_anim_node = nil;
	self.m_heroAnim_node = nil;
	self.m_surplus_lab = nil;
	self.m_des_lab1 = nil;
	self.m_throw_btn = nil;
	self.m_spDi_tab = nil;
	self.m_current_index = nil;
	self.m_shop_btn = nil;
	self.m_gift_node = nil;
	self.m_gift_sp = nil;
	self.m_getGift_btn = nil;
	self.m_btn_tab = nil;
	self.m_jindutiaoBg_sp = nil;
	self.m_isAnim_Flag = nil;
	self.m_richman_plot = nil;
	self.m_event_id = nil;
	self.m_TimeDown_node = nil;
	self.m_resetTimeDown_node = nil;

end
function game_monopoly_server_pop.back( self )
	game_scene:removePopByName("game_monopoly_server_pop");
	-- body
end
function game_monopoly_server_pop.createUi( self )
	local ccbNode = luaCCBNode:create();
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag === ")
        if btnTag == 1 then
        	self:back()
        elseif btnTag == 101 then --购买次数
        elseif btnTag == 102 then
        	game_scene:addPop("game_active_limit_detail_pop",{enterType = "177"})
        elseif btnTag == 103 then
    		game_scene:addPop("game_monopoly_shop_server_pop",{gameData = self.m_tGameData});
    		self:back()
        elseif btnTag == 104 then--投色子
        	if self.m_tGameData.current_event == 3 then -- 弹出打boss
        		local t_params = 
        		{
        		    title = string_config.m_title_prompt,
        		    okBtnCallBack = function(target,event)
        		            game_util:closeAlertView();
        		            self:enterFihgtBoss()
        		    end,   --可缺省
        		    cancelBtnCallBack = function(target,event)
        		        game_util:closeAlertView();
        		    end,
        		    okBtnText = "Xác nhận",       --可缺省
        		    cancelBtnText = "Hủy",
        		    onlyOneBtn = false,
        		    text = "Đánh boss có quà, nhấp xác nhận để vào",      --可缺省
        		    touchPriority = GLOBAL_TOUCH_PRIORITY-2,
        		}
        		game_util:openAlertView(t_params);
        	elseif self.m_tGameData.current_event == 4 then --弹出pvp
        		game_scene:addPop("game_monopoly_enemy_server_pop",{gameData = self.m_tGameData.enemy_info});
        	else
        		if self.m_tGameData.left_roll_times == 0 then
        			local m_richman_shop =  json.decode(getConfig(game_config_field.server_richman_shop):getFormatBuffer())
        			local pay 
        			local goods_id
        			for k,v in pairs(m_richman_shop) do
        				if v.value_sorts == 4 then
        					goods_id = k
        					pay = v.need_value
        				end
        			end
        				local t_params = 
        				{
        				    title = string_config.m_title_prompt,
        				    okBtnCallBack = function(target,event)
        				            game_util:closeAlertView();
        				            local function responseMethod( tag,gameData )
        				            	self.m_tGameData.left_roll_times = self.m_tGameData.left_roll_times + 5 
        				            	game_util:addMoveTips({text = "Số lần ném+5"})
        				            	self:refreshUi()
        				            end
        			    			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_super_tycoon_active_buy"), http_request_method.GET, {shop_type = 4,goods_id = goods_id},"server_super_tycoon_active_buy")
        				    end,   --可缺省
        				    cancelBtnCallBack = function(target,event)
        				        game_util:closeAlertView();
        				    end,
        				    okBtnText = "Xác nhận",       --可缺省
        				    cancelBtnText = "Hủy",
        				    onlyOneBtn = false,
        				    text = "Tốn" .. pay .. "Tốn Xu mua 5 lần ném chứ?",      --可缺省
        				    touchPriority = GLOBAL_TOUCH_PRIORITY-2,
        				}
        				game_util:openAlertView(t_params);
        		else
		        	if self.m_isAnim_Flag == true then
		        	else
			        	local function responseMethod( tag,gameData )
			        		if gameData and tolua.type(gameData) == "util_json" then
				        		local data = gameData:getNodeWithKey("data")
			       				data = json.decode(data:getFormatBuffer())
			       				self.m_tGameData = data
			       				self:refreshUi()
					        	local step = data.step
					        	self.m_event_id = data.event_id
				        		self.m_throw_btn:setTouchEnabled(false)
					        	self.m_isAnim_Flag = true
					        	self.m_anim_node:removeAllChildrenWithCleanup(true)
					        	self.m_anim_node:setPosition(120,-50)
					        	self:createDiceAnim(step)
					        else
					        	self.m_isAnim_Flag = false
					        	self.m_throw_btn:setTouchEnabled(true)
					        end
			        	end 
			        	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_super_tycoon_active_roll"), http_request_method.GET, nil,"server_super_tycoon_active_roll",true,true)
				    end
        		end
	        	
        	end
        elseif btnTag >= 201 and btnTag <= 205 then
        	local function responseMethod( tag,gameData )
        	    if gameData ~= nil and tolua.type(gameData) == "util_json" then
        	        local data = gameData:getNodeWithKey("data");
        			local openType = btnTag
        	        self.m_tGameData = json.decode(data:getFormatBuffer()) 
        			game_scene:addPop("game_monopoly_reward_server_pop",{gameData = self.m_tGameData,openType = openType,count = self.m_tGameData.round_count});
        	    end
        	end
        	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_super_tycoon_active_index"), http_request_method.GET, {},"server_super_tycoon_active_index")
        elseif btnTag == 999 then
			local function responseMethod( tag,gameData )
				if gameData and tolua.type(gameData) == "util_json" then
	        		local data = gameData:getNodeWithKey("data")
       				data = json.decode(data:getFormatBuffer())
       				self.m_tGameData = data
       				self:refreshUi()
       			end
			end        	
		    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_super_tycoon_active_clear"), http_request_method.GET, nil,"server_super_tycoon_active_clear",true,true)
        end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
	ccbNode:openCCBFile("ccb/ui_monopoly_main.ccbi")
	self.m_root_layer = ccbNode:layerForName("m_root_layer")
	self.m_startAnim_node = ccbNode:nodeForName("m_startAnim_node")
	self.m_heroAnim_node = ccbNode:nodeForName("m_heroAnim_node")
	self.m_anim_node = ccbNode:nodeForName("m_anim_node")
	self.m_gift_node = ccbNode:nodeForName("m_gift_node")
	self.m_TimeDown_node = ccbNode:nodeForName("m_TimeDown_node")
	self.m_resetTimeDown_node = ccbNode:nodeForName("m_resetTimeDown_node")
	self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
	self.m_getGift_btn  = ccbNode:controlButtonForName("m_getGift_btn")
	self.m_throw_btn = ccbNode:controlButtonForName("m_throw_btn")
	self.m_shop_btn = ccbNode:controlButtonForName("m_shop_btn")
	self.m_gift_sp = ccbNode:spriteForName("m_gift_sp")
	self.m_jindutiaoBg_sp = ccbNode:spriteForName("m_jindutiaoBg_sp")
	self.m_surplus_lab = ccbNode:labelTTFForName("m_surplus_lab")
	self.m_des_lab1 = ccbNode:labelTTFForName("m_des_lab1")
	local m_des_btn = ccbNode:controlButtonForName("m_des_btn")
	local tioahis = ccbNode:controlButtonForName("tioahis")
		tioahis:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)

	self.m_btn_tab = {}
	local m_num_btn
	for i=1,4 do
		m_num_btn = ccbNode:controlButtonForName("m_num_btn" .. i)
		m_num_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
		self.m_btn_tab[i] = m_num_btn
	end
	self.m_getGift_btn:setOpacity(0)
	self.m_getGift_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
	self.m_shop_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
	self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
	self.m_throw_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
	m_des_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
	self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
	self.m_root_layer:setTouchEnabled(true);
	self.m_spDi_tab = {}
	local m_di_sp
	for i=1,28 do
		m_di_sp = ccbNode:spriteForName("m_di_sp" .. i-1)
		self.m_spDi_tab[i] = m_di_sp
	end
	local anim = game_util:createEffectAnim("jiantou",1,true)
	self.m_startAnim_node:addChild(anim,10,10)
	self.m_startAnim_node:setRotation(180)
	local pX,pY = self.m_spDi_tab[self.m_current_index]:getPosition();
	local endPos = self.m_spDi_tab[self.m_current_index]:getParent():convertToWorldSpaceAR(ccp(pX,pY));
	endPos = self.m_heroAnim_node:getParent():convertToNodeSpace(ccp(endPos.x,endPos.y))
	if self.m_current_index < 12 or self.m_current_index > 24 then
		self.m_heroAnim_node:setScaleX(1)
	else
		self.m_heroAnim_node:setScaleX(-1)
	end
	self.m_heroAnim_node:setPosition(endPos)
	return ccbNode;
	-- body
end
function game_monopoly_server_pop.enterFihgtBoss( self )
	local function fightResponseMethod(tag,gameData)
	    if gameData then
	        game_data:setBattleType("server_monopoly_boss");
	        local data = json.decode(gameData:getFormatBuffer())
	        local stageTableData = {name = "Boss Kho Báu",step = 1,totalStep = 1}
	        local imgName = "back_world_boss"
	        game_scene:enterGameUi("game_battle_scene",{gameData = gameData,stageTableData=stageTableData,backGroundName=imgName});
	    else
	    end
	end
	local params = {}
	params.fight_type = 2
	network.sendHttpRequest(fightResponseMethod,game_url.getUrlForKey("server_super_tycoon_active_fight"), http_request_method.GET, params,"server_super_tycoon_active_fight",true,true)
end
--[[--
	人物移动
]]
function game_monopoly_server_pop.createHeroMove( self,x )
	local animArr = CCArray:create()
	local endIndex = self.m_current_index + x
	local tempIndex,tempEndIndex
	for i=self.m_current_index,endIndex do
		tempIndex = self.m_current_index
		local m = math.floor(i/28) 
		if m ~= 0 and i%28 == 0 then
			i = i-((m-1)*28)
		else 
			i = i-(m*28)
		end
		local pX,pY = self.m_spDi_tab[i]:getPosition();
		local endPos = self.m_spDi_tab[i]:getParent():convertToWorldSpaceAR(ccp(pX,pY));
		if i < 12 or i > 24 then
			endPos = self.m_heroAnim_node:getParent():convertToNodeSpace(ccp(endPos.x,endPos.y))
		else
			endPos = self.m_heroAnim_node:getParent():convertToNodeSpace(ccp(endPos.x,endPos.y))
		end
		local function delyFunc( )
			if i < 12 or i > 24 then
				self.m_heroAnim_node:setScaleX(1)
			else
				self.m_heroAnim_node:setScaleX(-1)
			end
		end
		if tempIndex>28 then 
			tempIndex = tempIndex - math.floor(tempIndex/28) * 28
		end
		if i ~= tempIndex then
			animArr:addObject(CCCallFunc:create(delyFunc))
		
			animArr:addObject(CCJumpTo:create(0.3,endPos,30,1))
		end
		tempEndIndex = i
	end
	self.m_heroAnim_node:runAction(CCSequence:create(animArr))
	local function delyFunc2(  )
		self.m_isAnim_Flag = false
	    self.m_throw_btn:setTouchEnabled(true)
		local reward = self.m_tGameData.rewards
	    self:enterBattle(self.m_event_id,reward)
	end
	local arr = CCArray:create();
	arr:addObject(CCDelayTime:create(x*0.3+0.3))
	arr:addObject(CCCallFunc:create(delyFunc2))
	self.m_heroAnim_node:runAction(CCSequence:create(arr))
	self.m_current_index = tempEndIndex

end
--[[--
	人物移动后进入场景的判断
]]
function game_monopoly_server_pop.enterBattle( self,i,reward )
	if i == 1 then --没有奖励
		game_util:addMoveTips({text = "Rất tiếc, vị trí hiện tại ko có quà"})
	elseif i == 2 then--直接弹奖励
		game_util:rewardTipsByDataTable(reward);
	elseif i == 3 then--boss战
		local t_params = 
		{
		    title = string_config.m_title_prompt,
		    okBtnCallBack = function(target,event)
		            game_util:closeAlertView();
		            self:enterFihgtBoss()
		    end,   --可缺省
		    cancelBtnCallBack = function(target,event)
		        game_util:closeAlertView();
		    end,
		    okBtnText = "Xác nhận",       --可缺省
		    cancelBtnText = "Hủy",
		    onlyOneBtn = false,
		    text = "Đánh boss có quà, nhấp xác nhận để vào",      --可缺省
		    touchPriority = GLOBAL_TOUCH_PRIORITY-2,
		}
		game_util:openAlertView(t_params);
	elseif i == 4 then--pvp
        game_scene:addPop("game_monopoly_enemy_server_pop",{gameData = self.m_tGameData.enemy_info});
	elseif i == 5 then--翻倍
		game_util:addMoveTips({text = "X2 Quà vị trí hiện tại"})
	elseif i == 6 then--勋章
		-- cclog2(reward,"reward === ")
		game_util:rewardTipsByDataTable(reward);
	elseif i == 7 then--限时售卖
		game_util:addMoveTips({text = "Đã mở Bán tính giờ"})
	end
	-- body
end
--[[--
	人物的动画
]]
function game_monopoly_server_pop.createHeroAnim(self)
    self.m_heroAnim_node:removeAllChildrenWithCleanup(true)
    local card_ccbNode = self:setQuanshenxiang();
    card_ccbNode:setScale(0.5)
    self.m_heroAnim_node:addChild(card_ccbNode,10,10)
end

function game_monopoly_server_pop.setQuanshenxiang(self)
    local animNode = nil;
    -- local heroData,heroCfg = game_data:getCardDataById("8400")
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local character_id = self.m_richman_plot["1"].character_id
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(character_id));
    if  heroCfg then
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        animNode = game_util:createIdelAnim(ainmFile,0,heroData,heroCfg);
        if animNode then
            animNode:setRhythm(1);
            game_anim:playSection(animNode , anim_label_name_cfg.daiji);
            local itemSize = animNode:getContentSize();
            animNode:setAnchorPoint(ccp(0.5,0.5));
            animNode:setPosition(ccp(5,27))
        end
    end
    return animNode;
end
--[[--
	创建格子的底和上面的奖励
]]
function game_monopoly_server_pop.createPlot( self )
	for i=1,28 do
		local sort = self.m_richman_plot[tostring(i)].plot_sort
		local imgName1 = ""
		local imgName2 = ""
		local pos 
		if sort == 1 then --起点
			imgName1 = "monopoly_normalDi.png"

		elseif sort == 2 then--小箱子
			imgName1 = "monopoly_normalDi.png"
			imgName2 = "monopoly_box.png"
			pos = ccp(21,37)

		elseif sort == 3 then--勋章
			imgName1 = "monopoly_medalDi.png"
			imgName2 = self.m_richman_plot["1"].item_icon .. ".png"

		elseif sort == 4 then--双倍
			imgName1 = "monopoly_doubleDi.png"
			imgName2 = "monopoly_titlex2.png"

		elseif sort == 5 then--限时
			imgName1 = "monopoly_normalDi.png"
			imgName2 = "monopoly_limit.png"

		end
		self.m_spDi_tab[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(imgName1));
		self:createUpSp(imgName2,i,pos)
	end
end
function game_monopoly_server_pop.createUpSp( self,imgName2,i,pos )
	local pos = pos or ccp(27,35)
	if imgName2 ~= "" then
		local img
		if imgName2 == self.m_richman_plot["1"].item_icon .. ".png" then
			img = CCSprite:create("icon/" .. imgName2)
		else
			img = CCSprite:createWithSpriteFrameName(imgName2)
		end
		img:setPosition(pos)
		self.m_spDi_tab[i]:removeAllChildrenWithCleanup(true)
		self.m_spDi_tab[i]:addChild(img)
	end
end
--[[--
	色子的动画
]]
function game_monopoly_server_pop.createDiceAnim( self,i )
	-- i = 4
	self.m_anim_node:removeAllChildrenWithCleanup(true)
	local function RanimCallBack( animNode, theId, theLabelName )
		local parent = animNode:getParent()
		if theLabelName == "tou" then
   --      	local px,py = self.m_anim_node:getPosition()
   --      	local bz = ccBezierConfig:new()
			-- bz.endPosition = ccp(-50,20)
			-- bz.controlPoint_1 = ccp(px-25,py+120 )
			-- bz.controlPoint_2 = ccp(px-25,py+120 )
			-- local function delyFunc()
				animNode:playSection("daiji" .. i) 
			-- end
			-- local animArr = CCArray:create()
			-- animArr:addObject(CCBezierTo:create(0.8,bz));
			-- animArr:addObject(CCCallFunc:create(delyFunc));
			-- self.m_anim_node:runAction(CCSequence:create(animArr));
	    elseif theLabelName == "daiji" .. i then
        	animNode:playSection(tostring(i))
	    else
        	self:createHeroMove(i)
	    end
	end
	local z_zjrAnim = game_util:createAnimEffect("touzi2","touzi2",RanimCallBack,nil,true);
    if z_zjrAnim then
    	self.m_anim_node:setPosition(ccp(-50,20))
        local tempsize = self.m_anim_node:getContentSize()
        z_zjrAnim:setAnchorPoint(ccp(-0.5,0.5));
        z_zjrAnim:setPosition(ccp(tempsize.width*0.5,tempsize.height*0.5));
        z_zjrAnim:playSection("tou")
        self.m_anim_node:addChild(z_zjrAnim,10,10)
    end
end
--[[--
	设置进度条
]]
function game_monopoly_server_pop.setProgress( self )
    local expBg = self.m_jindutiaoBg_sp
    local expBgSize = expBg:getContentSize(); 
    local current_score = self.m_tGameData.round_count or 0
    local score_max = 20--self.m_tGameData.code_coin or 200
    -- self.m_xingyunzhi_label:setString(current_score .. "/" .. score_max)
    local percentage = current_score/score_max * 100  
    local params = {}
    params.percentage = percentage
    params.fileName = "monopoly_jindutiao1.png"
    params.type =  kCCProgressTimerTypeVerticalBarBT
    params.midpoint = ccp(expBgSize.width*0.5,0)
    params.barChangeRate = ccp(0,1)
    -- params.midpoint = ccp(0,1)
    local expBarAdd = game_util:createProgressTimer(params)
    expBg:removeAllChildrenWithCleanup(true)
    expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
    expBg:addChild(expBarAdd,2,1);
end
function game_monopoly_server_pop.refreshUi( self )
	self:setProgress()
	self:createHeroAnim()
	self:createPlot()
	local surplus = self.m_tGameData.left_roll_times or 0 --剩余次数
	self.m_surplus_lab:setString("Số lần còn:" .. tostring(surplus) .. "/20")
	self.m_gift_node:removeAllChildrenWithCleanup(true)
	self.m_des_lab1:setString(self.m_richman_plot["1"].plot_des)
	-- if surplus == 0 then
	-- 	self.m_throw_btn:setTag(101)
	-- else
	-- 	self.m_throw_btn:setTag(104)

	-- end
	if self.m_tGameData and self.m_tGameData.is_shop_open then
		self.m_getGift_btn:setTouchEnabled(true)
		local anim1 = game_util:createEffectAnim("libao",1,true)
		self.m_gift_node:addChild(anim1,10,10)
		self.m_gift_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("monopoly_gift.png"));
	else
		self.m_getGift_btn:setTouchEnabled(false)
		self.m_gift_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("monopoly_giftBlack.png"));
	end
	self:createTimeDown(self.m_TimeDown_node,self.m_tGameData.active_end_count,1)
	self:createTimeDown(self.m_resetTimeDown_node,self.m_tGameData.reward_roll_time_count,2)
	local need_value = {5,10,15,20}
	for i=1,4 do
		if self.m_tGameData.round_count < need_value[i] then
			game_util:setCCControlButtonBackground(self.m_btn_tab[i],"monopoly_numDi.png")
		
		else
			game_util:setCCControlButtonBackground(self.m_btn_tab[i],"monopoly_numDi2.png")
		end
	end
end
function game_monopoly_server_pop.createTimeDown( self,parentNode,time_count_down,shwoType )
	local function timeEndFunc()
	    local function responseMethod( tag,gameData )
	        if gameData ~= nil and tolua.type(gameData) == "util_json" then
	            local data = gameData:getNodeWithKey("data");
	            self.m_tGameData = json.decode(data:getFormatBuffer()) 
	            self:refreshUi()
	        end
	    end
	    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_super_tycoon_active_index"), http_request_method.GET, {},"server_super_tycoon_active_index")
	end
	parentNode:removeAllChildrenWithCleanup(true)
	local countdownLabel = game_util:createCountdownLabel(time_count_down,timeEndFunc,8, shwoType);
	countdownLabel:setColor(ccc3(255, 255, 255))
	countdownLabel:setAnchorPoint(ccp(0.5,0.5))
	local tempcontent = parentNode:getContentSize()
	countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.6))
	parentNode:addChild(countdownLabel,10,10) 
	-- body
end
function game_monopoly_server_pop.init( self,t_params )
	t_params = t_params or {};
	self.m_isAnim_Flag = false

	if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
       local data = t_params.gameData:getNodeWithKey("data")
       self.m_tGameData = json.decode(data:getFormatBuffer())
	end
	self.m_current_index = self.m_tGameData.current_location

	self.m_richman_plot = json.decode(getConfig(game_config_field.server_richman_plot):getFormatBuffer()) 

end
function game_monopoly_server_pop.create( self,t_params )
	self:init(t_params);
	local scene = CCScene:create();
	scene:addChild(self:createUi());
	self:refreshUi()
	return scene
	-- body
end
return game_monopoly_server_pop;