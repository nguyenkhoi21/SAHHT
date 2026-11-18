--名人堂   八门强化
local game_fame_qianghua_pop = {
	m_ccbNode = nil,
	m_tGameData = nil,
	m_back_btn = nil,
	m_famous_id = nil,
    m_strengCount = nil,
    m_strengthen = nil,
    m_isChanged = nil,
    m_strengthen_value = nil,
    anim_section = nil,
    m_strengUsedCount = nil,
    m_strengCount_lb = nil,
    m_strengCount_lb1 = nil,
    m_famous_strengthenCfg = nil,
    m_CallBack = nil,
    m_CardData = nil,
    m_isReset = nil,
}

function game_fame_qianghua_pop:destroy()
    cclog("  ------------- game_fame_qianghua_pop  destroy -------- ")
	self.m_ccbNode = nil;
	self.m_tGameData = nil;
	self.m_back_btn = nil;
	self.m_famous_id = nil;
    self.m_strengCount = nil;
    self.m_strengthen = nil;
    self.m_isChanged = nil;
    self.m_strengthen_value = nil;
    self.anim_section = nil;
    self.m_strengUsedCount = nil;
    self.m_strengCount_lb = nil;
    self.m_strengCount_lb1 = nil;
    self.m_famous_strengthenCfg = nil;
    self.m_CallBack = nil;
    self.m_CardData = nil;
    self.m_isReset = nil;
end

function game_fame_qianghua_pop:back()
	game_scene:removePopByName("game_fame_qianghua_pop")
end
local attrsTab = {
	{key = "patk",value = "patk_v"},
	{key = "matk",value = "matk_v"},
	{key = "def",value = "def_v"},
    {key = "speed",value = "speed_v"},
	{key = "hp",value = "hp_v"},
}



function game_fame_qianghua_pop:createUi()
	local ccbNode = luaCCBNode:create()
	self.m_ccbNode = ccbNode
	local function onMainBtnClick(target,event)
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
        	self:back()
    	elseif btnTag < 30 and btnTag > 20 then
            if self.m_strengUsedCount >= self.m_strengCount then
                game_util:addMoveTips({text = "Điểm thuộc tính bonus còn lại không đủ!"})
                return
            end
    		self.m_isChanged = true
    		local index = btnTag - 20
    		local value = self.m_strengthen[attrsTab[index].key] or 0
            local str = value + 1
    		self.m_strengthen[attrsTab[index].key] = str
    		local m_change_lb = self.m_ccbNode:labelTTFForName("m_change_lb" .. index)
    		local tt = self.m_famous_strengthenCfg[tostring(index)].strengthen_effect
    		m_change_lb:setString(self.m_strengthen[attrsTab[index].key])
            local s_value = str*tt
            local tempLb2 = self.m_ccbNode:labelTTFForName("m_lb_" .. attrsTab[index].key .. "2")
            tempLb2:setString(s_value)
            self.m_strengthen[attrsTab[index].value] = s_value
            self.m_strengUsedCount = self.m_strengUsedCount + 1
            self.m_strengCount_lb:setString(self.m_strengCount - self.m_strengUsedCount .. "/24")
            self.m_strengCount_lb1:setString(self.m_strengCount - self.m_strengUsedCount .. "/24")
    	elseif btnTag == 31 then  --重置
            if self.m_strengUsedCount == 0 then
                game_util:addMoveTips({text = "Điểm thuộc tính bonus của bạn chưa dùng, không cần reset!"})
                return
            end
    		self.m_isChanged = true
    		local function responseMethod(tag,gameData)
    	    	local data = gameData:getNodeWithKey("data")
                self.m_strengUsedCount = 0
                self.m_strengCount_lb:setString(self.m_strengCount - self.m_strengUsedCount .. "/24")
                self.m_strengCount_lb1:setString(self.m_strengCount - self.m_strengUsedCount .. "/24")
    	    	if self.m_isChanged and self.m_CallBack then
					self.m_CallBack(self.m_strengthen,"  chongzhi ")
                    game_util:addMoveTips({text = "Đã reset"})
				end
                self.m_isChanged = false
                for k,v in pairs(attrsTab) do
                    self.m_strengthen[v.key] = 0
                    local tempLb = self.m_ccbNode:labelTTFForName("m_lb_" .. v.key .. "2")
                    tempLb:setString("0")
                    self:refreshAddLb(k)
                end
            end
      		local params = {}
      		params.famous_id = self.m_famous_id
      		for k,v in pairs(attrsTab) do
      			self.m_strengthen[v.key] = 0
      			local m_change_lb = self.m_ccbNode:labelTTFForName("m_change_lb" .. k)
    			m_change_lb:setString(0)
      		end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_strengthen"), http_request_method.GET, params,"cards_strengthen")
    	elseif btnTag == 32 then  --设置
            if not self.m_isChanged then
                game_util:addMoveTips({text = "Bạn chưa sửa đổi thuộc tính bonus, không cần lưu thiết lập!"})
                return
            end
    		self.m_isChanged = true
    	    local function responseMethod(tag,gameData)
    	    	local data = gameData:getNodeWithKey("data")
	    		if self.m_isChanged and self.m_CallBack then
                    self.m_isChanged = false
					self.m_CallBack(self.m_strengthen,"  xiugai ")
                    game_util:addMoveTips({text = "Đã reset"})
				end
            end
      		local params = {}
      		params.famous_id = self.m_famous_id
      		for k,v in pairs(attrsTab) do
                params[v.key] = self.m_strengthen[v.key] or 0
      		end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_strengthen"), http_request_method.GET, params,"cards_strengthen")
        end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_fame_qianghua_pop.ccbi")
	self.m_img_node	= ccbNode:nodeForName("m_img_node")
	local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
	m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
	local m_btn_chongzhi = ccbNode:controlButtonForName("m_btn_chongzhi")
	m_btn_chongzhi:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
	local m_btn_set = ccbNode:controlButtonForName("m_btn_set")
	m_btn_set:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
	local m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_strengCount_lb = ccbNode:labelTTFForName("strengCount_lb")
    self.m_strengCount_lb1 = ccbNode:labelTTFForName("strengCount_lb1")
    self.m_sp_ballFull = ccbNode:spriteForName("m_sp_ballFull")
    self.m_sp_ballFull:setVisible(false)
    if self.m_strengCount then
        if tonumber(self.m_strengCount) < 7 then
            self.anim_section = "daiji1"
        elseif tonumber(self.m_strengCount) < 13 then
            self.anim_section = "daiji2"
        elseif tonumber(self.m_strengCount) < 19 then
            self.anim_section = "daiji3"
        elseif tonumber(self.m_strengCount) < 24 then
            self.anim_section = "daiji3"
        else
            self.m_sp_ballFull:setVisible(true)
            self.anim_section = "daiji1"
        end
    else
        self.anim_section = "daiji1"
    end
    local function animCallFunc2(animNode, theId,theLabelName)
        animNode:playSection(self.anim_section)
    end
    local anim_node = ccbNode:nodeForName("anim_node")
    anim_node:removeAllChildrenWithCleanup(true)
    local m_chest_anim = game_util:createUniversalAnim({animFile = "anim_jingyancao",rhythm = 1.0,loopFlag = true,animCallFunc = animCallFunc2,actionName = self.anim_section});
    
    anim_node:addChild(m_chest_anim,100,100)
    anim_node:setScale(1.2)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    m_root_layer:setTouchEnabled(true);
    for i=1,5 do
    	local tempBtn = ccbNode:controlButtonForName("changeButton" .. i)
    	tempBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    end
	return ccbNode
end



function game_fame_qianghua_pop:refreshAddLb(index)
    local tempTab = attrsTab[index]
    local str = self.m_strengthen[tempTab.key] or 0
    local tt = self.m_famous_strengthenCfg[tostring(index)].strengthen_effect
    local tempLb = self.m_ccbNode:labelTTFForName("m_change_lb" .. index)
    tempLb:setString(str)
    local tempLb2 = self.m_ccbNode:labelTTFForName("m_lb_" .. tempTab.key .. "2")
    local s_value = str*tt
    tempLb2:setString(s_value)
end


function game_fame_qianghua_pop:refreshUi()
    self.m_strengUsedCount = 0
	for k,v in pairs(attrsTab) do
		local str = self.m_strengthen[v.key] or 0
        self.m_strengUsedCount = self.m_strengUsedCount + str
        local tempLb = self.m_ccbNode:labelTTFForName("m_lb_" .. v.key .. "1")
        tempLb:setString(self.m_CardData[v.key] or 0)
        self:refreshAddLb(k)
	end
    self.m_strengCount_lb:setString(self.m_strengCount - self.m_strengUsedCount .. "/24")
    self.m_strengCount_lb1:setString(self.m_strengCount - self.m_strengUsedCount .. "/24")
end

function game_fame_qianghua_pop:init(t_params)
	local famous_strengthenCfg = getConfig(game_config_field.famous_strengthen)
	self.m_famous_strengthenCfg = json.decode(famous_strengthenCfg:getFormatBuffer())
	local t_params = t_params or {}
	if t_params.gameData then
		local data = t_params.gameData:getNodeWithKey("data")
		self.m_tGameData = json.decode(data:getFormatBuffer())
	end
    self.m_CallBack = t_params.CallBack
    self.m_famous_id = t_params.famous_id
    local data = game_data:getFamousDetailByF_id(self.m_famous_id)
    cclog2(data,"data-=-------------")
    cclog2(self.m_famous_id,"self.m_famous_id-=-------------")
    self.m_CardData = game_data:getCardDataById(data.card_id)
    self.m_strengCount = t_params.strengCount or 0
    self.m_strengthen = t_params.strengthen or 0
    self.m_isChanged = false
    self.m_isReset = false
end

function game_fame_qianghua_pop:create(t_params)

	self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;

end
return game_fame_qianghua_pop