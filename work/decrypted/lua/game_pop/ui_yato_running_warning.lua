local  ui_yato_running_warning = {
	m_popUi = nil,
	m_root_layer = nil,
	m_btn_sure = nil,
	m_realsure = nil,  --1是确定 显示第二条提醒   0是显示第一条
 	m_text_1 = nil,
 	m_text_2 = nil,
 	m_select_number = nil,
 	m_tGameData = nil,
 	
};

function ui_yato_running_warning.destroy(self )
	self.m_popUi = nil;
	self.m_root_layer = nil;
	self.m_btn_sure = nil;
	self.m_realsure = nil;
	self.m_text_1 = nil;
	self.m_text_2 = nil;
	self.m_select_number = nil;--随机选择的羊驼Đang đợi...码
	self.m_tGameData = nil;
	
end

function ui_yato_running_warning.back(self )
	game_scene:removePopByName("ui_yato_running_warning")
end

function ui_yato_running_warning.createUi( self )
	local ccbNode = luaCCBNode:create();
	local function onMainBtnClick( target, event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag();
		if btnTag == 101 then --跳转界面
			--判断是第几条提醒
			if self.m_realsure == 0  or self.m_realsure == nil then 
				self.m_realsure = 1
				self.m_text_1:setVisible(false)
				self.m_text_2:setVisible(true)
				--更新 界面
				self.m_btn_sure:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_enter.png"),CCControlStateNormal);
				self.m_btn_sure:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_enter.png"),CCControlStateHighlighted);		
				self.refreshUi();
			elseif self.m_realsure == 1 then 
				local function responseMethod( tag,gameData )
		       		self:back()
		           	game_scene:addPop("ui_yato_running_gaming",{gameData = gameData})
		        end
		        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_index"),http_request_method.GET,nil,"yato_running_index")
	        end
		end 
	end

	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_yato_running_warning.ccbi")	
	local function  onTouch ( eventType ,x,y )
	 	if eventType == "began" then  
	 		return true;
	 	else
	 		-- self:back();
	 	end
	end
	self.m_root_layer = ccbNode:layerForName("m_root_layer")
	self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-998,true)
	self.m_root_layer:setTouchEnabled(true)

	self.m_btn_sure = ccbNode:controlButtonForName("m_btn_sure")
	self.m_btn_sure:setTouchPriority(GLOBAL_TOUCH_PRIORITY-999)

	self.m_text_1 = ccbNode:nodeForName("m_text_1")
	self.m_text_2 = ccbNode:nodeForName("m_text_2")

	 
	 --更新选中的羊驼  todo
	self.m_select_number = ccbNode:labelTTFForName("m_select_number")
	self.m_select_number:setString(self.m_tGameData.sort)

	return ccbNode;
end

--[[--
	刷新界面
]]
function ui_yato_running_warning.refreshUi(self )
 
end


--初始化
function ui_yato_running_warning.init( self ,t_params)
	t_params = t_params or {}
	if	t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json"  then 
		local data = t_params.gameData:getNodeWithKey("data");
		self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
	else
		self.m_tGameData = {};
	end
end

--[[
	创建ui入口 并初始化数据
]]
function  ui_yato_running_warning.create( self ,t_params)
	self:init(t_params);
	self.m_popUi = self:createUi();
	self:refreshUi()
	return self.m_popUi;
end

return ui_yato_running_warning;