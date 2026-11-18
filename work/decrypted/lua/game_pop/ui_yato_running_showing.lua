local  ui_yato_running_showing = {
	m_popUi = nil,
	m_root_layer = nil,
	m_time_node = nil,
	m_type = nil, --播放动画的类型  2是加油  1 是捣乱
	m_anim_node = nil,
	num =nil	,	
	Func = nil,
	m_PopType = nil,
	version_num	 = nil,

};

--[[--销毁ui]]
function ui_yato_running_showing.destroy(self )
	-- body
	self.m_popUi = nil;
	self.m_root_layer = nil;
	self.m_time_node = nil;
	self.m_type = nil;
	self.m_anim_node = nil;
	self.num = nil;
	self.Func = nil;
	self.m_PopType = nil;
	self.version_num = nil	;

end
--[[--返回]]
function ui_yato_running_showing.back(self )
	-- body
	local function responseMethod( tag,gameData )
	            -- body
	       
   		-- game_scene:addPop("ui_yato_running_gaming",{gameData = gameData,msg = self.msg})   
   		if	self.m_type == 1 then 
   
          game_scene:addPop("ui_yato_running_message",{Poptype = 1,num = self.num,version = self.version_num})
         elseif self.m_type ==2 then 
         game_scene:addPop("ui_yato_running_message",{Poptype = 2,num = self.num,version = self.version_num})
     	end

		game_scene:removePopByName("ui_yato_running_showing")

	 end
		        
 	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yato_running_index"),http_request_method.GET,nil,"yato_running_index")
	-- self:destroy()
end
function ui_yato_running_showing.createHeroAnim(self,EnorTr,num)
    local m_iAnim = nil;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local character_id = 74800--self.m_richman_plot["1"].character_id
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(character_id));
    if  heroCfg then
    	if num	 ==1 then 
        	m_iAnim = game_util:createIdelAnim("alpaca5",0,heroData,heroCfg);
   		elseif  num ==2  then
        	m_iAnim = game_util:createIdelAnim("alpaca6",0,heroData,heroCfg);
		elseif  num	 == 3 then 
			m_iAnim = game_util:createIdelAnim("alpaca4",0,heroData,heroCfg);
		end
        if m_iAnim then
            m_iAnim:setRhythm(1);
            if EnorTr ==2 then --捣乱 
            self:setHeroAnimName(m_iAnim,"impact1")
           	elseif EnorTr ==1 then -- 加油
            self:setHeroAnimName(m_iAnim,"impact2")

        	end
            local itemSize = m_iAnim:getContentSize();
            m_iAnim:setAnchorPoint(ccp(0.5,0.5));
            m_iAnim:setPosition(ccp(5,7))
        end
    end
    return m_iAnim;
end
function ui_yato_running_showing.setHeroAnimName( self, parentNode, animName )
	
	local function animEnd(animNode,theId,lableName)
	    game_anim:playSection(parentNode,lableName);
	end
	game_anim:playSection(parentNode , animName);
    parentNode:registerScriptTapHandler(animEnd);
end
--[[--读取CCb创建UI]]
function ui_yato_running_showing.createUi( self )
	-- body
	local ccbNode = luaCCBNode:create();
	local function onMainBtnClick( target, event )
		-- body
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag();
		-- m_root_layer
	end

	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_yato_running_showing.ccbi")	
	--设置层级
	
	 local function onTouch(eventType ,x,y )

		if eventType == "began" then 
			return true;
		else
			self:back();
		end
	end
	 self.m_root_layer = ccbNode:layerForName("m_root_layer")
	 self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-12,true)
	 self.m_root_layer:setTouchEnabled(true)
	
	 self.m_time_node = ccbNode:nodeForName("m_time_node")
	 self:createTimeDown(self.m_time_node,1)
	
	 self.m_anim_node = ccbNode:nodeForName("m_anim_node")
	 
	 local anim1 = self:createHeroAnim(self.m_type,self.num)
	 self.m_anim_node:addChild(anim1)
	

	return ccbNode;
end
--[[--
刷新界面]]
function ui_yato_running_showing.refreshUi(self )
-- 	-- body
-- 	
end
function ui_yato_running_showing.createTimeDown( self,parentNode,time_count_down,shwoType,isclose )
    local function timeEndFunc()
    	
    		self:back()
    	
    end
    parentNode:removeAllChildrenWithCleanup(true)
    local shwoType = shwoType or 3
    local countdownLabel = game_util:createCountdownLabel(time_count_down,timeEndFunc,8, shwoType);
    countdownLabel:setColor(ccc3(74, 249, 69))
    countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    local tempcontent = parentNode:getContentSize()
    countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.6))
    parentNode:addChild(countdownLabel,10,10) 
    countdownLabel:setOpacity(0)
end
--初始化
function ui_yato_running_showing.init( self,t_params )
	-- body
	t_params = t_params or {}
	if	t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json"  then 
		local data = t_params.gameData:getNodeWithKey("data");
		self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
	else
		self.m_tGameData = {};
	end
	self.m_type = t_params.showtype  --  播放动画的类型
	self.num = t_params.num --羊驼编Đang đợi...
	self.version_num = t_params.version_num;
	self.m_PopType = t_params.Poptype;
	

end
--[[--创建ui入口 并初始化数据]]
function  ui_yato_running_showing.create( self ,t_params)
	-- body

	self:init(t_params);
	self.m_popUi = self:createUi();

	
	return self.m_popUi;
end
return ui_yato_running_showing;
