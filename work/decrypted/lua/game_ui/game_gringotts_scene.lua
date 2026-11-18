local game_gringotts_scene = {
	m_screenShoot = nil,
	m_table = nil,
	m_refresh_btn = nil,
	m_wantto_btn = nil,
	m_btn_recharge = nil,
	m_btn_detail = nil,
	m_coin_lab = nil,
	m_get_lab = nil,
	m_rongzi_lab = nil,
	m_refreshTimes_lab = nil,
	m_shengyuTimes_lab = nil,
	text_scroll = nil,
	m_jindutiaoDi_sp = nil,
	m_reward_sp1 = nil,
	m_reward_sp2 = nil,
	content_node = nil,
	charge_reward = nil,
	m_des_lab = nil,
	m_gringotts_config = nil,
	m_gringottsVIP_config = nil,
	m_myNews_node = nil,
	m_version = nil,
	m_freeTime = nil, --免费加速的次数
	m_refreshTime = nil,
	m_buy_investing_times = nil,--充值获得的可购买次数
	investing_times = nil,
	m_logs = nil,
	m_investing_tab = nil,
	m_score = nil,
	m_refresh_lab = nil,
	m_refreshCoin_node = nil,
	m_getReward_btn = nil,
	m_select_index = nil,--选中的投资时限
	m_falg = nil,
	m_get_falg = nil,
	m_full_falg = nil,
	own_coin = nil,
	user_status = nil,
	m_alreadyGet_sp = nil,
	is_bag_reward = nil,
	m_animNode = nil,
	m_touziNews_lab = nil,
	m_jundu_lab = nil,
	m_iconNum_lab1 = nil,
	m_iconNum_lab2 = nil,
	m_temp_num = nil,
	m_cell_tab = nil,
	m_isAnim = nil,
	m_itemSize = nil,
	m_current_index = nil,--选中的cell的index
}
function game_gringotts_scene.destroy( self )
	self.m_screenShoot = nil;
	self.m_table = nil;
	self.m_refresh_btn = nil;
	self.m_wantto_btn = nil;
	self.m_btn_recharge = nil;
	self.m_btn_detail = nil;
	self.m_coin_lab = nil;
	self.m_get_lab = nil;
	self.m_rongzi_lab = nil;
	self.m_refreshTimes_lab = nil;
	self.m_shengyuTimes_lab = nil;
	self.text_scroll = nil;
	self.m_jindutiaoDi_sp = nil;
	self.m_reward_sp1 = nil;
	self.m_reward_sp2 = nil;
	self.content_node = nil;
	self.charge_reward = nil;
	self.m_des_lab = nil;
	self.m_gringotts_config = nil;
	self.m_myNews_node = nil;
	self.m_version = nil;
	self.m_freeTime = nil; --免费加速的次数
	self.m_refreshTime = nil;
	self.m_buy_investing_times = nil; --充值获得的可购买次数
	self.investing_times = nil;
	self.m_logs = nil;
	self.m_gringottsVIP_config = nil;
	self.m_investing_tab = nil;
	self.m_score = nil;
	self.m_refresh_lab = nil;
	self.m_refreshCoin_node = nil;
	self.m_getReward_btn = nil;
	self.m_select_index = nil;
	self.m_falg = nil;
	self.m_full_falg = nil;
	self.m_get_falg = nil;
	self.own_coin = nil;
	self.user_status = nil;
	self.m_alreadyGet_sp = nil;
	self.is_bag_reward = nil;
	self.m_animNode = nil;
	self.m_touziNews_lab = nil;
	self.m_jundu_lab = nil;
	self.m_iconNum_lab1 = nil;
	self.m_iconNum_lab2 = nil;
	self.m_temp_num = nil;
	self.m_cell_tab = nil;
	self.m_isAnim = nil;
	self.m_itemSize = nil;
	self.m_current_index = nil;
end
function game_gringotts_scene.back( self )
	game_scene:enterGameUi("game_main_scene",{gameData = nil});
end
function game_gringotts_scene.createUi( self )
	local ccbNode = luaCCBNode:create();
	local function onMainBtnClick( target,event )
	    local tagNode = tolua.cast(target, "CCNode");
	    local btnTag = tagNode:getTag();
	    cclog2(btnTag,"btnTag === ")
	    if btnTag == 1 then--返回
	    	self:back()
	    elseif btnTag == 11 then --充值
	    	local function responseMethod(tag,gameData)
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                --game_scene:addPop("ui_vip_show_pop");
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
       elseif btnTag == 12 then --详情
	    	game_scene:addPop("game_active_limit_detail_pop",{openType = "gringotts"})
	    elseif btnTag == 13 then --刷新
	    	if self.m_isAnim == false then
		    	local function responseMethod(tag,gameData)
		    	   self.m_falg = true
		    	   local data = gameData:getNodeWithKey("data");
		    	   self.user_status = gameData:getNodeWithKey("user_status");
		    	   self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
		    	   self:refreshUi()
		    	   self.m_temp_num = 1
		    	   self.m_isAnim = true
		    	   self:shouyiAnim()
		    	   game_util:addMoveTips({text = "Đã tạo mới"})
		    	end
		    	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gringotts_refresh"), http_request_method.GET, nil,"gringotts_refresh")
	    	end
	    elseif btnTag == 14 then --投资
	    	if self.m_isAnim == false then
		    	if self.m_falg == true  and self.m_select_index ~= nil then
		    		local t_params = 
		    		{
		    		    title = "Nhắc nhở",
		    		    okBtnCallBack = function(target,event)
		    		    	self.m_falg = false
		    		    	local time = self.m_gringotts_config[tostring(self.m_version)][tostring("time" .. self.m_select_index)]
		    		    	local params = {}
		    		    	params.time_long = time
		    		    	local function responseMethod(tag,gameData)
		    		    	   local data = gameData:getNodeWithKey("data");
		    		    	   self.user_status = gameData:getNodeWithKey("user_status");
		    		    	   self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
		    		    	   self.m_isAnim = true
		    		    	   self:TouziAnim()
		    		    	end
		    		    	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gringotts_investing"), http_request_method.GET, params,"gringotts_investing")
		    		        require("game_ui.game_pop_up_box").close();
		    		    end,   --可缺省
		    		    cancelBtnCallBack = function(target,event)
		    		    	require("game_ui.game_pop_up_box").close();
		    		    end,  
		    		    okBtnText = "Xác nhận",  
		    		    cancelBtnText = "Hủy",     --可缺省
		    		    text = "Đầu tư nhé?",     --可缺省
		    		    onlyOneBtn = false,          --可缺省
		    		}
		    		require("game_ui.game_pop_up_box").show(t_params);
			    	
		    	elseif self.m_select_index == nil then
		    		game_util:addMoveTips({text = "Chọn thời hạn rồi đầu tư"})
		    	elseif self.m_full_falg == true then
		    		game_util:addMoveTips({text = "Số lần đầu tư không đủ"})
		    	else
		    		game_util:addMoveTips({text = "Tạo mới trước"})
		    	end
		    end
	    elseif btnTag == 15 then
	    	local function responseMethod(tag,gameData)
	    	    local data = gameData:getNodeWithKey("data");
	    	    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
	    	    self.user_status = gameData:getNodeWithKey("user_status")
	    	    self:refreshUi()
	    	    local reward = data:getNodeWithKey("reward")
	    	    game_util:rewardTipsByJsonData(reward);
	    	    self.m_alreadyGet_sp:setVisible(true)
	    	end
	    	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gringotts_get_big_reward"), http_request_method.GET, nil,"gringotts_get_big_reward")
	    elseif btnTag >= 201 and btnTag <= 203 then
            local index = btnTag - 200;
            self.m_select_index = index
            for i=1,3 do
            	self.m_table[i].m_shouyi_lab:setColor(ccc3(250,250,250))
            end
            self.m_table[index].m_shouyi_lab:setColor(ccc3(100,250,30))
            for i=1,3 do
                self.m_table[i].m_qixian_btn:setEnabled(true)
                self.m_table[i].m_qixian_btn:setOpacity(0)
            end
            self.m_table[index].m_qixian_btn:setEnabled(false)
            self.m_table[index].m_qixian_btn:setOpacity(255)
	    end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
	ccbNode:openCCBFile("ccb/ui_game_gringotts.ccbi");
	self.m_refresh_btn = ccbNode:controlButtonForName("m_refresh_btn")
	self.m_wantto_btn = ccbNode:controlButtonForName("m_wantto_btn")
	self.m_btn_recharge = ccbNode:controlButtonForName("m_btn_recharge")
	self.m_btn_detail = ccbNode:controlButtonForName("m_btn_detail")
	-- self.m_coin_lab = ccbNode:labelTTFForName("m_coin_lab")
	self.m_get_lab = ccbNode:labelTTFForName("m_get_lab")
	self.m_rongzi_lab = ccbNode:labelTTFForName("m_rongzi_lab")
	self.m_shengyuTimes_lab = ccbNode:labelTTFForName("m_shengyuTimes_lab")
	self.text_scroll = ccbNode:scrollViewForName("m_scroll_view_Secret");
	self.text_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
	self.m_jindutiaoDi_sp = ccbNode:spriteForName("m_jindutiaoDi_sp")
	self.m_reward_sp1 = ccbNode:spriteForName("m_reward_sp1")
	self.m_reward_sp2 = ccbNode:spriteForName("m_reward_sp2")
	self.content_node = ccbNode:nodeForName("content_node")
	self.m_des_lab = ccbNode:labelTTFForName("m_des_lab")
	self.m_myNews_node =ccbNode:nodeForName("m_myNews_node")
	self.m_refresh_lab = ccbNode:labelTTFForName("m_refresh_lab")
	self.m_refreshCoin_node = ccbNode:nodeForName("m_refreshCoin_node")
	self.m_getReward_btn = ccbNode:controlButtonForName("m_getReward_btn")
	self.m_alreadyGet_sp = ccbNode:spriteForName("m_alreadyGet_sp")
	self.m_animNode = ccbNode:nodeForName("m_animNode")
	self.m_jundu_lab = ccbNode:labelTTFForName("m_jundu_lab")
	self.m_iconNum_lab1 = ccbNode:labelTTFForName("m_iconNum_lab1")
	self.m_iconNum_lab2 = ccbNode:labelTTFForName("m_iconNum_lab2")
	self.m_table = {}
	local m_qixian_btn = nil;
	local m_shouyi_lab = nil;
	local m_qixian_lab = nil;
	local m_animGo_node = nil;
	local m_shuaxinAnim_node = nil;
	for i=1,3 do
		m_qixian_btn = ccbNode:controlButtonForName("m_qixian_btn" .. i)
		m_qixian_btn:setOpacity(0)
		m_shouyi_lab = ccbNode:labelTTFForName("m_shouyi_lab" .. i)
		m_qixian_lab = ccbNode:labelTTFForName("m_qixian_lab" .. i)
		m_shuaxinAnim_node = ccbNode:nodeForName("m_shuaxinAnim_node" .. i)
		self.m_table[i] = {
				m_qixian_btn = m_qixian_btn ,
		 		m_shouyi_lab = m_shouyi_lab ,
		  		m_qixian_lab = m_qixian_lab,
		  		m_shuaxinAnim_node = m_shuaxinAnim_node
		  	}
	end
	local m_root_layer = ccbNode:layerForName("m_root_layer")
	if self.m_screenShoot then
	    local tempSize = m_root_layer:getContentSize();
	    self.m_screenShoot:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
	    m_root_layer:addChild(self.m_screenShoot,-1);
	end
	self.ccbNode = ccbNode
	return ccbNode;
end
function game_gringotts_scene.TouziAnim( self )
	local function sectionEnd( animNode, theId, theLabelName )
		local parent = animNode:getParent()
		parent = tolua.cast(parent,"SortNode")
	    if theLabelName == "touzi" then
	    	self:refreshUi(true,true)
	    	game_anim:playSection(parent,"yidong")
	    	local endPos = ccp(0, 0)
	    	local endNode = nil
	    	local delayTime = 0.1
	    	local moveTime = 0.6
	    	endNode = self.m_cell_tab[self.investing_times]
	    	if endNode then
	    	    local pX,pY = endNode:getPosition();
        		endPos = endNode:getParent():convertToWorldSpace(ccp(pX +self.m_itemSize.width*0.5,pY + self.m_itemSize.height*0.5+1));
	    	end
	    	local animArr = CCArray:create();
	    	if delayTime > 0 then
	    	    animArr:addObject(CCDelayTime:create(delayTime));
	    	end
	    	local itemSize = endNode:getContentSize()
	    	animArr:addObject(CCMoveTo:create(moveTime,ccp(endPos.x + itemSize.width*0.5,endPos.y + itemSize.height*0.5)));
	    	local sequence = CCSequence:create(animArr)
	    	parent:runAction(sequence);
	    elseif theLabelName == "yidong" then
	    	animNode:playSection( theLabelName )
	    	game_anim:playSection(parent,"dakai")
	    	self:refreshUi(true)
	    elseif theLabelName == "dakai" then
	    	self.m_isAnim = false
	    	game_util:addMoveTips({text = "Đã đầu tư, xem thông tin bên phải"})
	    	self.ccbNode:removeChildByTag(10,true)
	    end
	end

	local z_zjrAnim = game_util:createAnimEffect("anim_ui_touzi","anim_ui_touzi",sectionEnd,nil,true);
	if z_zjrAnim then
	    local tempsize = self.m_table[self.m_select_index].m_shuaxinAnim_node:getContentSize()
	    z_zjrAnim:setAnchorPoint(ccp(0.5,0.5));
	    game_anim:playSection(z_zjrAnim,"touzi")
	    local pX,pY = self.m_table[self.m_select_index].m_shuaxinAnim_node:getPosition()
	    local startPos = ccp(0,0)
	    startPos = self.m_table[self.m_select_index].m_shuaxinAnim_node:getParent():convertToWorldSpace(ccp(pX,pY));
	    z_zjrAnim:setPosition(startPos)
	    self.ccbNode:addChild(z_zjrAnim,10,10)
	end
end
function game_gringotts_scene.jiaSu( self,time_long,sort)

	local quickly_point = self.m_gringotts_config[tostring(self.m_version)].quickly_point

	local t_params = 
	{
	    title = "Nhắc nhở",
	    okBtnCallBack = function(target,event)
	    	local params = {}
	    		params.sort = sort
	    		local function responseMethod(tag,gameData)
	    		   local data = gameData:getNodeWithKey("data");
	    		   self.user_status = gameData:getNodeWithKey("user_status");
	    		   local reward = data:getNodeWithKey("reward")
	    		   self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
	    		   game_util:rewardTipsByJsonData(reward);
	    		   self:refreshUi()
	    		end
	    		network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gringotts_quickly_reward"), http_request_method.GET, params,"gringotts_quickly_reward")
	        require("game_ui.game_pop_up_box").close();
	    end,   --可缺省
	    cancelBtnCallBack = function(target,event)
	    	require("game_ui.game_pop_up_box").close();
	    end,  
	    okBtnText = "Xác nhận",  
	    cancelBtnText = "Hủy",     --可缺省
	    text = "Tốn thời gian còn dư gia tốc" .. quickly_point .. "%lợi nhuận mỗi giờ?？",     --可缺省
	    onlyOneBtn = false,          --可缺省
	}
	require("game_ui.game_pop_up_box").show(t_params);
end
function game_gringotts_scene.getReward( self,time_long,sort )
	local params = {}
	params.sort = sort
	local function responseMethod(tag,gameData)
	   local data = gameData:getNodeWithKey("data");
	   self.user_status = gameData:getNodeWithKey("user_status");
	   local reward = data:getNodeWithKey("reward")
	   self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
	   game_util:rewardTipsByJsonData(reward);
	   self:refreshUi()
	end
	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gringotts_get_reward"), http_request_method.GET, params,"gringotts_get_reward")
end
function game_gringotts_scene.createMyNews( self,viewSize )
	local getfalg_tab = {}
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
	    local btnTag = tagNode:getTag();
	    if btnTag < 110  and btnTag >100 then
	    	if getfalg_tab[btnTag-100] == true then
	    		local time_long = self.m_investing_tab[tostring(btnTag-100)].time_long
	    		self:getReward(time_long,btnTag-100)
	    	else
	    		game_util:addMoveTips({text = "Hiện chưa thể nhận"})
	    	end
	    elseif  btnTag < 210  and btnTag >200 then
	    	local time_long = self.m_investing_tab[tostring(btnTag-200)].time_long
	    	self:jiaSu(time_long,btnTag-200)
	    elseif btnTag == 300 then
	    	game_util:addMoveTips({text = "Đã nhận"})
	    end
	end
	local totalItem = self.investing_times 
	local params = {};
	local viewSize = viewSize
	params.viewSize = viewSize;
	params.row = 5;--行
	params.column = 1; --列
	params.totalItem = 9;
	params.touchPriority = GLOBAL_TOUCH_PRIORITY-3;
	params.direction = kCCScrollViewDirectionVertical
	local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
	self.m_itemSize = itemSize
	params.newCell = function(tableView,index) 
	    local cell = tableView:dequeueCell()
	    if cell == nil then
	        cell = CCTableViewCell:new()
	        cell:autorelease()
	        local ccbNode = luaCCBNode:create();
	        ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
	        ccbNode:openCCBFile("ccb/ui_game_gringotts_item.ccbi")
	        ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5+17));
	        cell:addChild(ccbNode,10,10);
	    end
	    if cell then
	    	self.m_cell_tab[index+1] = cell
    	  	local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
    	  	local detail = ccbNode:labelTTFForName("m_detail_lab")
    	  	local m_noTouzi_lab = ccbNode:labelTTFForName("m_noTouzi_lab")
    	  	local m_jiasu_btn = ccbNode:controlButtonForName("m_jiasu_btn")
    	  	m_jiasu_btn:setOpacity(0)
    		local m_get_btn2 = ccbNode:controlButtonForName("m_get_btn2")
    		local m_alreadyGet_sp = ccbNode:spriteForName("m_alreadyGet_sp")
    		local daojishi_node = ccbNode:nodeForName("daojishi_node")
    		if index + 1 <= totalItem then
    			m_noTouzi_lab:setVisible(false)
    			detail:setVisible(true)
	    		self.m_get_falg = false
	    		m_jiasu_btn:setTag(200+index+1)
	    		m_get_btn2:setTag(100+index+1)
	    	  	local coin = self.m_investing_tab[tostring(index+1)].coin
	    	  	local time = self.m_investing_tab[tostring(index+1)].time
	    	  	local mytime = os.date("%H%M",time)
	    	  	local mytime1 = string.sub(mytime,1,2)
	    	  	local mytime2 = string.sub(mytime,3,4)
	    	  	detail:setString("Đã đầu tư" .. coin .. "Xu")
	    		local time_down = self.m_tGameData.time_count_down[tostring(index+1)]
	    		local m_timeDown_node = ccbNode:nodeForName("m_timeDown_node")
	    		m_timeDown_node:removeAllChildrenWithCleanup(true)
	    		if time_down == 0 then
	    			self.m_get_falg = true
	    			m_get_btn2:setVisible(true)
	    			daojishi_node:setVisible(false)
	    		else
	    			self.m_get_falg = false
	    			m_get_btn2:setVisible(false)
	    			daojishi_node:setVisible(true)
	    		end
	    		local function timeEndFunc()
	    			self.m_get_falg = true
	    			m_get_btn2:setVisible(true)
	    			daojishi_node:setVisible(false)
	    		end 
	    		local countdownLabel = game_util:createCountdownLabel(time_down,timeEndFunc,8, 1);
	    		countdownLabel:setColor(ccc3(0, 255, 0))
	    		countdownLabel:setAnchorPoint(ccp(0.5,0.5))
	    		local tempcontent = m_timeDown_node:getContentSize()
	    		countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.5))
	    		m_timeDown_node:addChild(countdownLabel,10,10) 
	    		getfalg_tab[index+1] = self.m_get_falg
	    		local getfalg = self.m_investing_tab[tostring(index+1)].flag
	    		if getfalg == 1 then --已领取
	    			m_alreadyGet_sp:setVisible(true)
	    			daojishi_node:setVisible(false)
	    			m_jiasu_btn:setColor(ccc3(150,150,150))
	    			m_jiasu_btn:setEnabled(false)
	    			m_get_btn2:setColor(ccc3(150,150,150))
	    			m_get_btn2:setTag(300)
	    		else
	    			m_alreadyGet_sp:setVisible(false)
	    			m_get_btn2:setColor(ccc3(250,250,250))
	    			m_jiasu_btn:setEnabled(true)
	    			if time_down == 0 then
	    				daojishi_node:setVisible(false)
	    				m_get_btn2:setVisible(true)
	    			else
	    				daojishi_node:setVisible(true)
	    				m_get_btn2:setVisible(false)
	    			end
	    		end
	    	else
	    		m_alreadyGet_sp:setVisible(false)
	    		m_noTouzi_lab:setVisible(true)
	    		detail:setVisible(false)
	    		m_get_btn2:setVisible(false)
	    		daojishi_node:setVisible(false)
	    	end
	    end

	    return cell;
	end
	params.itemOnClick = function(eventType,index,item)
	end
	return TableViewHelper:create(params);
end

function game_gringotts_scene.createHangqing( self )
	self.text_scroll:getContainer():removeAllChildrenWithCleanup(true);
	local viewSize = self.content_node:getContentSize()
	local contentText = ""
	local openMsg = ""
	if self.m_logs then
		for k,v in pairs(self.m_logs) do
	     	openMsg = openMsg .. v .. "\n" .. "\n"
		end
	end
	contentText = openMsg
	local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(110,0),textAlignment = kCCTextAlignmentLeft, verticalTextAlignment = kCCVerticalTextAlignmentCenter,fontSize = 9})
	local tempSize = tempLabel:getContentSize()
	self.text_scroll:setContentSize(CCSizeMake(60,tempSize.height))
	self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
	self.text_scroll:setDirection(kCCScrollViewDirectionVertical)
	self.text_scroll:addChild(tempLabel)
end
function game_gringotts_scene.rewardPop( self,i )
	local reward = {}
	reward = self.charge_reward
	local info = reward[i]
	local tempType = info[1]
	if tempType == 6 then--道具
	    local itemId = info[2]
	    game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
	elseif tempType == 7 then--装备
	    local equipId = info[2]
	    local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
	    game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
	elseif tempType == 5 then--卡牌
	    local cId = info[2]
	    game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
	else                   -- 食品
	    game_scene:addPop("game_food_info_pop",{itemData = info})
	end
end
function game_gringotts_scene.createReward( self )
	local function onBtnCilck( event, target)
		local ccbNode = tolua.cast(target,"CCNode")
		local btnTag = ccbNode:getTag()
		if btnTag == 1 then
			self:rewardPop(1)
		elseif btnTag == 2 then
			self:rewardPop(2)
		end
	end
	for i=1,2 do
		local icon,name,count = game_util:getRewardByItemTable(self.charge_reward[i])
		if icon then
			if i == 1 then
				icon:setPosition(self.m_reward_sp1:getContentSize().width * 0.5, self.m_reward_sp1:getContentSize().height * 0.5 )
				self.m_reward_sp1:addChild(icon,10,10)
				local button = game_util:createCCControlButton("public_skill.png","",onBtnCilck)
		        button:setAnchorPoint(ccp(0.5,0.5))
		        button:setZoomOnTouchDown(false)
		        button:setPosition( self.m_reward_sp1:getContentSize().width * 0.5, self.m_reward_sp1:getContentSize().height * 0.5 )
		        button:setOpacity(0)
		        button:setTag(i)
		        self.m_reward_sp1:addChild(button)
		        self.m_iconNum_lab1:setString("x" .. tostring(count))
			elseif i == 2 then
				icon:setPosition(self.m_reward_sp2:getContentSize().width * 0.5, self.m_reward_sp1:getContentSize().height * 0.5 )
				self.m_reward_sp2:addChild(icon,10,10)
				local button = game_util:createCCControlButton("public_skill.png","",onBtnCilck)
		        button:setAnchorPoint(ccp(0.5,0.5))
		        button:setZoomOnTouchDown(false)
		        button:setPosition( self.m_reward_sp1:getContentSize().width * 0.5, self.m_reward_sp1:getContentSize().height * 0.5 )
		        button:setOpacity(0)
		        button:setTag(i)
		        self.m_reward_sp2:addChild(button)
		        self.m_iconNum_lab2:setString("x" .. tostring(count))
			end
		end
	end
end
function game_gringotts_scene.shouyiAnim( self )
	local function animEndCallFunc()
		local rongzi = self.m_investing_tab[tostring(self.investing_times+1)].coin 
		local current_shouyi = self.m_investing_tab[tostring(self.investing_times+1)].per
		if self.m_temp_num < 9 then
			for i=1,3 do
				math.randomseed(1000 * self.m_temp_num)
				local random_num = math.random(1,10)
				random_num = random_num/10
				if random_num * 10 > 5 then 
					
					self.m_table[i].m_shouyi_lab:setString(tostring(current_shouyi[i] * 100  - random_num) .. "%")
				else
					self.m_table[i].m_shouyi_lab:setString(tostring(current_shouyi[i] * 100  + random_num) .. "%")
				end
			end
			local random_num = math.random(1,10)
			local rongzinum = 0
			if random_num  > 5 then 
				if rongzi-random_num* 100 < 0 then
					rongzinum = 100
				end
				self.m_rongzi_lab:setString(tostring(rongzinum))
			else
				self.m_rongzi_lab:setString(tostring(rongzi+random_num* 100))
			end
			local animArr = CCArray:create()
			if self.m_temp_num > 5 then
				animArr:addObject(CCDelayTime:create(self.m_temp_num*0.07))
			else
				animArr:addObject(CCDelayTime:create(self.m_temp_num*0.1))
			end
			animArr:addObject(CCCallFunc:create(animEndCallFunc));
			self.m_refreshCoin_node:runAction(CCSequence:create(animArr));
			self.m_temp_num = self.m_temp_num + 1
		else
			for i=1,3 do
				self.m_table[i].m_shouyi_lab:setString(current_shouyi[i] * 100 .. "%")
				self.m_table[i].m_shuaxinAnim_node:removeAllChildrenWithCleanup(true)
			end
			self.m_rongzi_lab:setString(tostring(rongzi))
			self.m_temp_num = 1
			self.m_isAnim = false
			return
		end
	end
	local animArr = CCArray:create();
	for i=1,3 do
		local current_shouyi = self.m_investing_tab[tostring(self.investing_times+1)].per
		math.randomseed(1000 * self.m_temp_num)
		local random_num = math.random(current_shouyi[i] * 100 - 1,current_shouyi[i] * 100 + 1)
		self.m_table[i].m_shouyi_lab:setString(random_num .. "%")
		local function sectionEnd( animNode, theId, theLabelName )
			local parent = animNode:getParent()
			parent = tolua.cast(parent,"SortNode")
		    if theLabelName == "shuaxin" then
		    	game_anim:playSection(parent,"shuaxin")
		    end
		end
		local z_zjrAnim = game_util:createAnimEffect("anim_ui_touzi","anim_ui_touzi",sectionEnd,nil,true);
		if z_zjrAnim then
		    local tempsize = self.m_table[i].m_shuaxinAnim_node:getContentSize()
		    z_zjrAnim:setAnchorPoint(ccp(0.5,0.5));
		    z_zjrAnim:setPosition(ccp(tempsize.width*0.5,tempsize.height*0.5));
		    game_anim:playSection(z_zjrAnim,"shuaxin")
		    self.m_table[i].m_shuaxinAnim_node:addChild(z_zjrAnim,10,10)
		end
	end
	local rongzi = self.m_investing_tab[tostring(self.investing_times+1)].coin 
	self.m_rongzi_lab:setString(tostring(rongzi-100))
	animArr:addObject(CCDelayTime:create(self.m_temp_num*0.1))
	animArr:addObject(CCCallFunc:create(animEndCallFunc));
	self.m_refreshCoin_node:runAction(CCSequence:create(animArr));
end
function game_gringotts_scene.refreshLabel( self )
	local des = self.m_gringotts_config[tostring(self.m_version)].des1
	self.m_des_lab:setString(des)
	for i=1,3 do
		local time = self.m_gringotts_config[tostring(self.m_version)][tostring("time" .. i)]
		self.m_table[i].m_qixian_lab:setString("Thời hạn" .. time .. "giờ")
	end

	local refresh_coin = self.m_gringotts_config[tostring(self.m_version)].refresh_coin
	if self.m_refreshTime >= #refresh_coin then
		refresh_coin = refresh_coin[#refresh_coin]
	else
		refresh_coin = refresh_coin[self.m_refreshTime + 1]
	end
	if refresh_coin > 0 then
		self.m_refresh_lab:setString("Tạo mới lần này tốn " .. refresh_coin .. "Xu" )
	else
		self.m_refresh_lab:setString("Tạo mới lần này ko tốn Xu")
	end
	local shengyutime = self.m_buy_investing_times + self.m_gringottsVIP_config.free_times - self.investing_times
	if shengyutime < 0 then
		self.m_shengyuTimes_lab:setString("0")
	else
		self.m_shengyuTimes_lab:setString(shengyutime)
	end
	if self.investing_times and self.investing_times <9 then
		local rongzi = self.m_investing_tab[tostring(self.investing_times+1)].coin or "0"
		self.m_rongzi_lab:setString(rongzi)
		local current_shouyi = self.m_investing_tab[tostring(self.investing_times+1)].per
		if current_shouyi and next(current_shouyi) and shengyutime > 0  then
			for i=1,3 do
				self.m_falg = true
				self.m_table[i].m_shouyi_lab:setString(current_shouyi[i] * 100 .. "%")
				self.m_full_falg = false
			end
		elseif current_shouyi and shengyutime <= 0 and next(current_shouyi)  then
			self.m_full_falg = true
			for i=1,3 do
				self.m_table[i].m_shouyi_lab:setString(current_shouyi[i] * 100 .. "%")
			end
		else
			for i=1,3 do
				self.m_falg = false
				self.m_table[i].m_shouyi_lab:setString("0%")
				self.m_full_falg = false
			end
		end
	else
		for i=1,3 do
			self.m_table[i].m_shouyi_lab:setString("0%")
		end
	end
	local myMoney = 0
	for k,v in pairs(self.m_investing_tab) do
		if v.flag == 0 and v.time_long ~= 0 then
			myMoney = v.in_come+ myMoney
		end
	end
	self.m_get_lab:setString(tostring(myMoney))
end
function game_gringotts_scene.setJindutiao( self )
	self.m_jundu_lab:setString("0/0")
    local expBg = self.m_jindutiaoDi_sp
    local expBgSize = expBg:getContentSize(); 
    local current_score = self.m_score or 0
    local score_max =  self.m_gringotts_config[tostring(self.m_version)].max_coin or 10000
    local percentage = current_score/score_max * 100 
    self.m_jundu_lab:setString(current_score .. "/" .. score_max)
    self.m_animNode:removeAllChildrenWithCleanup(true) 
    if percentage == 100 then
    	self.m_getReward_btn:setVisible(true)
    	expBg:setVisible(false)
    	self.m_jundu_lab:setVisible(false)
    else
    	expBg:setVisible(true)
    	self.m_getReward_btn:setVisible(false)
    	self.m_jundu_lab:setVisible(true)
    end 
    local params = {}
    params.percentage = percentage
    params.fileName = "Gringotts_jindutiao.png"
    local expBarAdd = game_util:createProgressTimer(params)
    expBg:removeAllChildrenWithCleanup(true)
    expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
    expBg:addChild(expBarAdd,2,1);
end
function game_gringotts_scene.refreshData( self )
	self.is_bag_reward = self.m_tGameData.is_bag_reward or 0
	self.m_freeTime = self.m_tGameData.free_times or 0
	self.m_refreshTime = self.m_tGameData.refresh_times or 0
	self.m_buy_investing_times = self.m_tGameData.buy_investing_times or 0
	self.m_logs =  self.m_tGameData.logs
	self.m_investing_tab = self.m_tGameData.investing
	self.m_score = self.m_tGameData.score
	self.investing_times = self.m_tGameData.investing_times
end
function game_gringotts_scene.refreshUi( self,isTouzi,isVisible )
	local isTouzi = isTouzi or false
	local isVisible = isVisible or false
	self:refreshData()
	if self.is_bag_reward and self.is_bag_reward == 1 then
		self.m_alreadyGet_sp:setVisible(true)
		self.m_getReward_btn:setEnabled(false)
	else
		self.m_alreadyGet_sp:setVisible(false)
		self.m_getReward_btn:setEnabled(true)
	end
	if isVisible == false then
		self.m_myNews_node:removeAllChildrenWithCleanup(true)
		self.m_myNews_node:addChild(self:createMyNews(self.m_myNews_node:getContentSize()),10,10)
	end
	if self.investing_times <= 4 then
	    self.m_current_index = 0
	end
	if self.investing_times > 5 then
	    self.m_current_index = 5
	end
	if isTouzi == true and self.investing_times ~= nil then
		game_util:setTableViewIndex(self.m_current_index,self.m_myNews_node,10,5)
	else	
		game_util:setTableViewIndex(0,self.m_myNews_node,10,5)
	end
	self:createHangqing()
	self:createReward()
	self:setJindutiao()
	self:refreshLabel()
end
function game_gringotts_scene.init( self,t_params )
	t_params = t_params or {}
	self.m_investing_tab = {}
	self.m_cell_tab = {}
	self.m_falg = false
	self.m_isAnim = false
	local vip = 0
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
	    local data = t_params.gameData:getNodeWithKey("data");
	    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
	    self.m_version = self.m_tGameData.version
	    self.user_status = t_params.gameData:getNodeWithKey("user_status");
	    local vip_status = json.decode(self.user_status:getFormatBuffer()) or {};
	    vip = vip_status.vip
	else
	    self.m_tGameData = {};
	end
	self.m_screenShoot = t_params.screenShoot;
	local gringottsConfig = getConfig(game_config_field.gringotts)
	gringottsConfig = json.decode(gringottsConfig:getFormatBuffer())
	self.m_gringotts_config = gringottsConfig
	self.charge_reward = gringottsConfig[tostring(self.m_version)].charge_reward
	self.m_gringottsVIP_config = getConfig(game_config_field.gringotts_VIP)
	self.m_gringottsVIP_config = json.decode(self.m_gringottsVIP_config:getFormatBuffer())
	self.m_gringottsVIP_config = self.m_gringottsVIP_config[tostring(vip)]
end
function game_gringotts_scene.create( self,t_params)
	self:init(t_params)
	local scene = CCScene:create()
	scene = self:createUi()
	self:refreshUi()
	return scene
end
return game_gringotts_scene