--新年红包激活码和领取信息界面
local game_redEnvelope_pop = {
	m_tGameData = nil,
	m_close_btn = nil,
	m_AllcopyA_btn = nil,
	m_sendRed_btn = nil,
	m_Des_btn = nil,
	m_root_layer = nil,
	m_tableView_node = nil,
	content_node = nil,
	text_scroll = nil,
	codes = nil,
	m_jindutiaoBg_sp = nil,
	m_xingyunzhi_label = nil,
	m_left_lab = nil,
	m_config = nil,


}
function game_redEnvelope_pop.destroy( self )
	cclog("--------------game_redEnvelope_pop.destorty-----------")
	self.m_close_btn = nil;
	self.m_AllcopyA_btn = nil;
	self.m_sendRed_btn = nil;
	self.m_Des_btn = nil;
	self.m_root_layer = nil;
	self.m_tableView_node = nil;
	self.content_node = nil;
	self.text_scroll = nil;
	self.m_tGameData = nil;
	self.codes = nil;
	self.m_jindutiaoBg_sp = nil;
	self.m_xingyunzhi_label = nil;
	self.m_left_lab = nil;
	self.m_config = nil;
	-- body

end
function game_redEnvelope_pop.back( self )
	game_scene:removePopByName("game_redEnvelope_pop");
	-- body
end

function game_redEnvelope_pop.createUi( self )
	local ccbNode = luaCCBNode:create();

	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag === ")
        if btnTag == 1 then
        	self:back()
        elseif btnTag == 102 then
        	game_scene:addPop("game_active_limit_detail_pop",{openType = "redEnvelope"})
        elseif btnTag == 103 then
        	local function responseMethod(tag,gameData)
        	    local data = gameData:getNodeWithKey("data");
        	    game_scene:enterGameUi("ui_vip",{gameData = gameData});
        	end
        	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
	
	ccbNode:openCCBFile("ccb/ui_redEnvelope.ccbi")
	
	self.m_root_layer = ccbNode:layerForName("m_root_layer")
	self.m_tableView_node = ccbNode:nodeForName("m_tableView_node")
	self.m_jindutiaoBg_sp = ccbNode:spriteForName("m_jindutiaoBg_sp")
	self.m_xingyunzhi_label = ccbNode:labelTTFForName("m_xingyunzhi_label")
	self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
	self.m_AllcopyA_btn = ccbNode:controlButtonForName("m_AllcopyA_btn")
	self.m_sendRed_btn = ccbNode:controlButtonForName("m_sendRed_btn")
	self.m_Des_btn = ccbNode:controlButtonForName("m_Des_btn")
	self.m_left_lab = ccbNode:labelTTFForName("m_left_lab")
	self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
	self.m_AllcopyA_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
	self.m_AllcopyA_btn:setVisible(false)
	self.m_sendRed_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
	self.m_Des_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
	self.content_node = ccbNode:nodeForName("content_node")
	
    self.text_scroll = ccbNode:scrollViewForName("text_scroll")
    self.text_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
	self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
	self.m_root_layer:setTouchEnabled(true);
  	
	return ccbNode;
	-- body
end
--[[--
	设置进度条
]]
function game_redEnvelope_pop.setProgress( self )

    local expBg = self.m_jindutiaoBg_sp
    local expBgSize = expBg:getContentSize(); 
    local current_score = self.m_tGameData.recharge_mod_cost or 0
    cclog2(current_score,"current_score is ")
    cclog2(self.m_tGameData.code_coin,"self.m_tGameData.code_coin === ")
    local score_max = self.m_tGameData.code_coin or 200
    self.m_xingyunzhi_label:setString(current_score .. "/" .. score_max)
    local percentage = current_score/score_max * 100
    cclog2(percentage,"percentage is ")  
    local params = {}
    params.percentage = percentage
    params.fileName = "red_envelope_jindutiao2.png"
    local expBarAdd = game_util:createProgressTimer(params)
    expBg:removeAllChildrenWithCleanup(true)
    expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
    expBg:addChild(expBarAdd,2,1);
end
--[[--
	左侧激活码
]]
function game_redEnvelope_pop.createTableView( self,viewSize )
		local function onBtnClick( target,event )
			local tagNode = tolua.cast(target, "CCNode");
			local btnTag = tagNode:getTag();
			game_data:setRedEnvelopeJihuoma(self.codes[btnTag+1])
			game_util:addMoveTips({text = "Đã copy mã code đến giao diện nhận lì xì"})	
		end
		local totalItem = #self.codes
		local params = {};
		local viewSize = viewSize
		params.viewSize = viewSize;
		params.row = 5;--行
		params.column = 1; --列
		params.totalItem = totalItem;
		params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
		params.direction = kCCScrollViewDirectionVertical
		local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
		params.newCell = function(tableView,index) 
		    local cell = tableView:dequeueCell()
		    if cell == nil then
		        cell = CCTableViewCell:new()
		        cell:autorelease()
		        local ccbNode = luaCCBNode:create();
		        ccbNode:registerFunctionWithFuncName("onBtnClick",onBtnClick);--bind button on click event
		        ccbNode:openCCBFile("ccb/ui_redEnvelope_item.ccbi")
		        ccbNode:setPosition(ccp(itemSize.width*0.4,itemSize.height*0.5));
		        cell:addChild(ccbNode,10,10);
		    end
		    if cell then
	    	  	local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
	    	  	local m_copy_btn = ccbNode:controlButtonForName("m_copy_btn")
	    	  	m_copy_btn:setTag(index)
	    	  	m_copy_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
	    	  	local m_jihuoma_lab = ccbNode:labelTTFForName("m_jihuoma_lab")
	    	  	if self.codes and self.codes[index+1] then 
	    	  		m_jihuoma_lab:setString(self.codes[index+1])
	    	  	else
	    	  
	    	  	end
		    end
		    return cell;
		end
		params.itemOnClick = function(eventType,index,item)
		end
		return TableViewHelper:create(params);
	-- body
end
--[[--
	右侧奖励信息
]]
function game_redEnvelope_pop.createHistroyNews( self )	
	local viewSize = self.content_node:getContentSize()
	local contentText = "";
	local openMsg = ""
	for k,v in pairs(self.m_tGameData.logs) do
	     openMsg = openMsg .. v .. "\n"
	end
	contentText = openMsg
	local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(200,0),textAlignment = kCCTextAlignmentCenter,
	    verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 10})
	local tempSize = tempLabel:getContentSize();
	self.text_scroll:setContentSize(CCSizeMake(200,tempSize.height))
	self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
	self.text_scroll:addChild(tempLabel)
end
function game_redEnvelope_pop.refreshUi( self )
	self.m_tableView_node:removeAllChildrenWithCleanup(true);
	local viewSize = self.m_tableView_node:getContentSize()
	local tableView = self:createTableView(viewSize)
	self.m_tableView_node:addChild(tableView,10,10)
	self:createHistroyNews()
	self:setProgress()
	if self.m_config.des3 then 
		self.m_left_lab:setString(self.m_config.des3)
	end
	-- body
end
function game_redEnvelope_pop.init( self,t_params )
	t_params = t_params or {};
	self.codes = {}
	if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
	       local data = t_params.gameData:getNodeWithKey("data")
	       self.m_tGameData = json.decode(data:getFormatBuffer())
	       self.codes = self.m_tGameData.codes
	       local version = tostring(self.m_tGameData.version)
	       self.m_config = getConfig(game_config_field.system_red_bag)
	       self.m_config = json.decode(self.m_config:getFormatBuffer())
	       self.m_config = self.m_config[version]
	       
	end

	-- body
end
function game_redEnvelope_pop.create( self,t_params )
	self:init(t_params);
	local scene = CCScene:create();
	scene:addChild(self:createUi());
	self:refreshUi()
	return scene
	-- body
end
return game_redEnvelope_pop;