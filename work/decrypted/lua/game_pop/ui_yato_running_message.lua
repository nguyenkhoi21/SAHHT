local  ui_yato_running_message = {
	m_popUi = nil,
	m_root_layer = nil,
	m_PopType = nil,
	m_num = nil,
	m_trouble_node = nil,
	m_encourage_node = nil,
	m_buy_node = nil,
	m_btn_trouble_sure = nil,
	m_btn_encourage_sure = nil,
	m_btn_back = nil,
	m_btn_buy = nil,
	m_msg = nil,
	m_reward_node =nil,
	version_num = nil,
	m_vision = nil,
}
function ui_yato_running_message.destroy( self )
	-- body
	self.m_popUi = nil;
	self.m_root_layer = nil;
	self.m_PopType = nil;
	self.m_num = nil;
	self.m_trouble_node = nil;
	self.m_encourage_node = nil;
	self.m_buy_node = nil;
	self.m_btn_trouble_sure = nil;
	self.m_btn_encourage_sure = nil;
	self.m_btn_buy = nil;
	self.m_btn_back = nil;
	self.m_msg = nil;
	self.m_reward_node = nil;
	self.version_num = nil	;
	self.m_vision = nil;
end

function  ui_yato_running_message.back( self )
	local function responseMethod( tag,gameData )
		game_scene:removePopByName("ui_yato_running_message")
    end	        
	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_index"),http_request_method.GET,nil,"yato_running_index")
end


function  ui_yato_running_message.back2( self )
	--刷新 数据
	--重新进入赛场界面
	local function responseMethod( tag,gameData )
        game_scene:addPop("ui_yato_running_gaming",{gameData = gameData})
		game_scene:removePopByName("ui_yato_running_message")
	end	        
	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_index"),http_request_method.GET,nil,"yato_running_index")
end

function ui_yato_running_message.createReward( self ,ccbNode)
	local  yatocfg = getConfig(game_config_field.yato_running_reward)
	local yatocfg_num = yatocfg:getNodeWithKey(tostring(self.version_num));
	yatocfg_num2 = json.decode(yatocfg_num :getFormatBuffer()) or {};
	if self.m_PopType == 1 then --加油奖励
		local reward = yatocfg_num2.cheer_reward  -- 配置
		self:createRewardIcon(ccbNode,reward)
	elseif self.m_PopType == 2 then --捣乱奖励
		local reward = yatocfg_num2.mess_reward  -- 配置	
		self:createRewardIcon(ccbNode,reward)
	end
end

function ui_yato_running_message.createRewardIcon( self ,ccbNode,reward)
	for i=1,#reward do
	    local icon,_,count = game_util:getRewardByItemTable(reward[i])
	    if #reward == 1 then
	    	icon:setPosition(ccp(-1,-1))
	    else
	    	local x = i%5
	    	if x == 0 then
	    		x = 5
	    	end

	    	icon:setPosition(ccp(x%6*60-180,35-math.floor(i/6)*60))
	    end
	    if icon then
	    	local ttf = game_util:createLabelTTF({text = "×" .. count,color = ccc3(255,255,255),fontSize = 12});
	    	local size = icon:getContentSize()
			ttf:setAnchorPoint(ccp(0,0))
	        ttf:setPosition(ccp(size.width+2,1))
	        icon:addChild(ttf)
	        ccbNode:addChild(icon)
	        icon:setScale(0.6)
	        icon:setPosition(10,10)
	    end
	end
end


function  ui_yato_running_message.createUi( self )
	local ccbNode = luaCCBNode:create();
	local function onMainBtnClick( target,event )
		local  tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag();
		if btnTag == 100 then 
			self:back()
		elseif btnTag == 101 then 
			-- 加油弹框的确定按钮
			self:back()
		elseif btnTag == 102 then 
			local function responseMethod( tag,gameData )
	            -- body
	         	 self.back2()
	        end
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_buy_lottery"),http_request_method.GET,nil,"yato_running_buy_lottery")
		elseif btnTag == 103 then 
			-- 购买竞猜卷  返回按钮
			self:back()
		end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_yato_running_message.ccbi")
	local function onTouch(eventType ,x,y )
		if eventType == "began" then 
			return true;
		else
		end
	end
	self.m_root_layer = ccbNode:layerForName("m_root_layer")
	self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true)
	self.m_root_layer:setTouchEnabled(true)

	self.m_trouble_node = ccbNode:nodeForName("m_trouble_node")
	self.m_encourage_node = ccbNode:nodeForName("m_encourage_node")
	self.m_buy_node = ccbNode:nodeForName("m_buy_node")
	self.m_btn_trouble_sure = ccbNode:controlButtonForName("m_btn_trouble_sure")
	self.m_btn_trouble_sure:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
	self.m_btn_encourage_sure = ccbNode:controlButtonForName("m_btn_encourage_sure")
	self.m_btn_encourage_sure:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
	self.m_btn_buy = ccbNode:controlButtonForName("m_btn_buy")
	self.m_btn_buy:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
	self.m_btn_back = ccbNode:controlButtonForName("m_btn_back")
	self.m_btn_back:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)

	self.m_reward_node = ccbNode:nodeForName("m_reward_node")	
	self.m_cost_lb = ccbNode:labelTTFForName("m_cost_lb")
	self:switch(self.m_PopType,ccbNode);
	
	return ccbNode;

end
function ui_yato_running_message.switch( self,PopType,ccbNode)
	if PopType == 1 then  --显示鼓励界面
		self.m_encourage_node:setVisible(true)
		self.m_buy_node:setVisible(false)
		self.m_trouble_node:setVisible(false)
		ccbNode:labelTTFForName("lb_gwTx1"):setString(string.format("Tiến hành Tiếp Sức cho Tuần Lộc số %s!\nTuần Lộc số %s cảm nhận được một nguồn sức mạnh đang phun trào!", self.m_num, self.m_num))
		self:createReward(self.m_reward_node,ccbNode)
	elseif PopType == 2 then --显示捣乱界面
		self.m_encourage_node:setVisible(false)
		self.m_buy_node:setVisible(false)
		self.m_trouble_node:setVisible(true)
		ccbNode:labelTTFForName("lb_glTx1"):setString(string.format("Tiến hành Tiếp Sức Thực hiện Ném Đá số %s.\nTuần Lộc số %s bị trúng đầu gối 1 cú rồi.", self.m_num, self.m_num))
		self:createReward(self.m_reward_node,ccbNode)
	elseif PopType == 3 then  --购买界面
		self.m_cost_lb:setString("Tiêu phí" .. self.m_cost .. "Kim Cương mua Vé Dự Đoán *1 (có cơ hội tham gia rút thưởng lớn nha)")
		self.m_encourage_node:setVisible(false)
		self.m_buy_node:setVisible(true)
		self.m_trouble_node:setVisible(false)
	end
end


function ui_yato_running_message:refreshUi()


end


function ui_yato_running_message.init( self,t_params )
	local t_params = t_params or {}
	self.m_num = t_params.num;
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then  
			local data = t_params.gameData:getNodeWithKey("data");
		self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
	else
		self.m_tGameData = {};
	end
	self.version_num = t_params.version;
	self.m_PopType = t_params.Poptype;
	self.m_cost = t_params.cost or 30
end
function ui_yato_running_message.create( self,t_params )
	self:init(t_params);
	self.m_popUi = self:createUi();
	self:refreshUi()
	return self.m_popUi;
end
return ui_yato_running_message;