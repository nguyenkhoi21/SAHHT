--名人堂   八门强化
local game_fame_bamen_pop = {
	m_ccbNode = nil,
	m_tGameData = nil,
	m_back_btn = nil,
	m_bamen_ziTab = nil,
	m_On_cards = nil,
	m_isChanged = nil,
	m_gate = nil,
	m_famous_id = nil,
	m_Famous_attr = nil,
	m_streng_count = nil,
	m_selectd = nil,
	m_sel_bg = nil,
	m_streng_lb = nil,
	m_sel_ablity_sp = nil,
	m_sel_ablity_lb = nil,
	m_img_node = nil,

}

function game_fame_bamen_pop:destroy()
	cclog("--------------- game_fame_bamen_pop destroy -------------")
	self.m_ccbNode = nil
	self.m_tGameData = nil
	self.m_back_btn = nil
	self.m_bamen_ziTab = nil
	self.m_On_cards = nil;
	self.m_isChanged = nil;

	self.m_gate = nil;
	self.m_famous_id = nil;
	self.m_Famous_attr = nil;
	self.m_streng_count = nil;
	self.m_selectd = nil;
	self.m_sel_bg = nil;
	self.m_streng_lb = nil;
	self.m_sel_ablity_sp = nil;
	self.m_sel_ablity_lb = nil;
	self.m_img_node = nil;
end

function game_fame_bamen_pop:back()
	game_scene:removePopByName("game_fame_bamen_pop")
end

-- 白 绿 蓝 紫 橙 红 黑 彩
local quality_table = {
	"Monster_Summoning_toubai.png",
	"Monster_Summoning_toulv.png",
	"Monster_Summoning_toulan.png",
	"Monster_Summoning_touzi.png",
	"Monster_Summoning_toucheng.png",
	"Monster_Summoning_touhong.png",
	"Monster_Summoning_toujin.png",
	"Monster_Summoning_toujin.png",
	"Monster_Summoning_toujin.png",
	"Monster_Summoning_toujin.png",
	"Monster_Summoning_toujin.png",
	"Monster_Summoning_toujin.png",
	"Monster_Summoning_toujin.png",
	"Monster_Summoning_toujin.png",
	"Monster_Summoning_toujin.png",
	"Monster_Summoning_toujin.png",
	"Monster_Summoning_toujin.png",
	"Monster_Summoning_toujin.png",
	"Monster_Summoning_toujin.png",
	"Monster_Summoning_toujin.png",
}

local icon_tab = {
	"public_icon_phsc.png",
	"public_icon_mgc.png",
	"public_icon_dfs.png",
	"public_icon_speed.png",
	"public_icon_hp.png",

}
--'patk', 'matk', 'def', 'speed', 'hp'
local attrsTab = {
	  "patk",
	  "matk",
	  "def",
	  "speed",
	  "hp",
}

function game_fame_bamen_pop:changedCallBack(callType)
	local function responseMethod(tag,gameData)
        if gameData ~= nil then
        	if callType then
        		self:back()
        	else
		    	local function endCallBack(streng,where)
					self.m_tGameData.strengthen = util.table_copy(streng)
					self:refreshStrengthLabel()
				end
		        self.m_isChanged = false
            	local tempTab = {}
        	  	tempTab.matk  = 0
			  	tempTab.patk  = 0
			  	tempTab.hp    = 0
			  	tempTab.def   = 0
			  	tempTab.speed = 0
			  	self.m_tGameData.strengthen = util.table_copy(tempTab)
			  	self:refreshStrengthLabel()
        		game_scene:addPop("game_fame_qianghua_pop",{famous_id = self.m_famous_id,strengCount = self.m_streng_count, strengthen = util.table_copy(tempTab) ,CallBack = endCallBack})
        	end
        end
    end
	local params = "famous_id=" .. self.m_famous_id .. "&gates="
	for i=1,8 do
		if self.m_gate["gate" .. i] then
			params = params .. self.m_gate["gate" .. i] .. (i == 8 and "" or "_")
		else
			params = params .. (i == 8 and "0" or "0_")
		end
	end
	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_famous_bonus"), http_request_method.POST, params,"cards_famous_bonus")
end


function game_fame_bamen_pop:createUi()
	local ccbNode = luaCCBNode:create()
	self.m_ccbNode = ccbNode
	local function onMainBtnClick(target,event)
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
        	if self.m_isChanged then
        		self:changedCallBack(true)
    		else
    			self:back()
    		end
       	elseif btnTag == 2 then
       		game_scene:addPop("game_active_limit_detail_pop",{enterType = "189"})
    	elseif btnTag == 3 then
    		local function endCallBack(streng,where)
    			self.m_tGameData.strengthen = util.table_copy(streng) 
    			self:refreshStrengthLabel()
    		end
    		if self.m_isChanged then
				local t_params = 
                {
                    title = "Nhắc nhở",
                    okBtnCallBack = function(target,event)
        				self:changedCallBack()
                        require("game_ui.game_pop_up_box").close(); 
                    end,   --可缺省
                    cancelBtnCallBack = function(target,event) cclog("rightBtnCallBack") require("game_ui.game_pop_up_box").close(); end,   --可缺省
                    okBtnText = "Xác nhận",       --可缺省
                    cancelBtnText = "Hủy",
                    text = "Đã thay đổi thẻ bài vị trí Bát Môn, sẽ reset cường hóa thuộc tính của thẻ chính",      --可缺省
                    onlyOneBtn = true,          --可缺省
                }
                require("game_ui.game_pop_up_box").show(t_params);
			else
    			game_scene:addPop("game_fame_qianghua_pop",{famous_id = self.m_famous_id,strengCount = self.m_streng_count, strengthen = util.table_copy(self.m_tGameData.strengthen) ,CallBack = endCallBack})
			end
        elseif btnTag > 100 then
        	local function callback(event,id)
        		self:addSelHero(event,id)
        	end
        	local index = btnTag - 100
        	for i=1,8 do
        		local tempZ = self.m_bamen_ziTab[i]
		     	local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("fame_bamenzi_" .. i .. "1.png")
		     	if i == index then
		     		tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("fame_bamenzi_" .. i .. "2.png")
		     	end
		     	if tempSpriteFrame then
		         	tempZ:setDisplayFrame(tempSpriteFrame)
		      	end
        	end
    	    local temp_selNode = self.m_ccbNode:nodeForName("m_icon_node" .. index)
			local x,y = temp_selNode:getPosition()
			self.m_sel_bg:setPosition(ccp(x,y))
			self.m_sel_bg:setVisible(true)
			self.m_On_cards = self.m_gate["gate" .. index]
        	if self.m_selectd == index or not self.m_gate["gate" .. index] or self.m_gate["gate" .. index] == "" then
        		self.m_selectd = index
    			-- game_scene:addPop("game_fame_hero_select_pop",{callback = callback,enterType = 2})
				game_scene:addPop("game_hero_select_pop",{itemOnClick = callback,openType = 14}) 
    		else
    			self.m_selectd = index
    			self:refreshSelAdd()
    		end
        end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_fame_bamen_pop.ccbi")
	self.m_img_node	= ccbNode:nodeForName("m_img_node")
	self.m_sel_bg = ccbNode:spriteForName("m_sel_bg")
	self.m_sel_bg:setVisible(false)
	local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
	m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
	local m_rule_btn = ccbNode:controlButtonForName("m_rule_btn")
	m_rule_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
	local m_qianghua_btn = ccbNode:controlButtonForName("m_qianghua_btn")
	m_qianghua_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
	m_qianghua_btn:setOpacity(0)
	self.m_streng_lb = ccbNode:labelTTFForName("m_streng_lb")
	self.m_streng_lb1 = ccbNode:labelTTFForName("m_streng_lb1")
	self.m_sel_ablity_sp = ccbNode:spriteForName("m_sel_ablity_sp")
	self.m_sel_ablity_lb = ccbNode:labelTTFForName("m_sel_ablity_lb")
	self.m_progress_node = ccbNode:nodeForName("m_progress_node")
	local m_tips = ccbNode:labelTTFForName("m_tips")
	self:addAnim(m_tips)
	local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    m_root_layer:setTouchEnabled(true);
    for i=1,8 do
    	local tempBtn = ccbNode:controlButtonForName("m_btn_" .. i)
    	tempBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    	tempBtn:setOpacity(0)
    end
    self.m_bamen_ziTab = {}
    for i=1,8 do
    	local tempZ = ccbNode:spriteForName("m_bamen_zi" .. i)
     	local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("fame_bamenzi_" .. i .. "1.png")
     	if self.m_selectd == i then
     		tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("fame_bamenzi_" .. i .. "2.png")
     	end
     	if tempSpriteFrame then
         	tempZ:setDisplayFrame(tempSpriteFrame)
      	end
    	self.m_bamen_ziTab[i] = tempZ
    end
	return ccbNode
end

function game_fame_bamen_pop:refreshSelAdd()
	local id = self.m_gate["gate" .. self.m_selectd]
	local _,selCardCfg = game_data:getCardDataById(id)
	local data1,data2 = game_data:getFamousPosAtt(self.m_famous_id,"gate" .. self.m_selectd ,selCardCfg)
	local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon_tab[data2[1]])
	if tempSpriteFrame then
		self.m_sel_ablity_sp:setDisplayFrame(tempSpriteFrame)
	end
	local str = data1 and data1[2] or 0
	self.m_sel_ablity_lb:setString(tostring(str) .. "/" .. tostring(data2[2]))
end


function game_fame_bamen_pop:refreshAttrsLabel()
	for i=1,5 do
		local tempLab = self.m_ccbNode:labelTTFForName("m_attrs_lb" .. i)
		local key = attrsTab[i]
		tempLab:setString(self.m_Famous_attr[key] or "0")
	end
	self.m_streng_lb:setString(self.m_streng_count .. "/24")
	self.m_streng_lb1:setString(self.m_streng_count .. "/24")
    self.bar:setCurValue(self.m_streng_count,true);

end


function game_fame_bamen_pop:addSelHero(event,id)
	local tempNode = self.m_ccbNode:nodeForName("m_icon_node" .. self.m_selectd)
	tempNode:removeAllChildrenWithCleanup(true)
	local _,cardCfg = game_data:getCardDataById(self.m_On_cards)
	local data = game_data:getFamousPosAtt(self.m_famous_id,"gate" .. self.m_selectd,cardCfg)
	if data then
		game_data:removeOneDataFromFamousAllData(self.m_On_cards)
		self.m_streng_count = self.m_streng_count - cardCfg:getNodeWithKey("streng"):toInt()
		local key = attrsTab[data[1]]
		self.m_Famous_attr[key] = tonumber((self.m_Famous_attr[key] and self.m_Famous_attr[key] or 0)) - data[2]
		if self.m_Famous_attr[key] < 0 then self.m_Famous_attr[key] = 0 end
	end

	if event == "load" or event == "unload" then
		self.m_gate["gate" .. self.m_selectd] = nil
		self.m_isChanged = true
		self.m_On_cards = nil
	elseif event == "exchanged" then
		if self.m_On_cards ~= id then
			self.m_isChanged = true
			self.m_On_cards = id
		end
		game_data:insertOneDataToFamous(id)
		self.m_gate["gate" .. self.m_selectd] = id
		local _,cardCfg2 = game_data:getCardDataById(id)
		local data2 = game_data:getFamousPosAtt(self.m_famous_id,"gate" .. self.m_selectd,cardCfg2)
		if data2 then
			self.m_streng_count = self.m_streng_count + cardCfg2:getNodeWithKey("streng"):toInt()
			local key = attrsTab[data2[1]]
			self.m_Famous_attr[key] = tonumber(self.m_Famous_attr[key] and self.m_Famous_attr[key] or 0) + data2[2]
		end
		local _,itemCfg = game_data:getCardDataById(id)
		local tempSp = self:createHeroIconByCfg(itemCfg)
		if tempSp then
			tempNode:addChild(tempSp)
		end
	end
	self:refreshSelAdd()
	self:refreshAttrsLabel()
end

function game_fame_bamen_pop:createHeroIconByCfg(cardCfg)
	local tempNode = CCNode:create()
	local tempSp = CCSprite:create("icon/" .. cardCfg:getNodeWithKey("img"):toStr())
	if tempSp then
		tempNode:removeAllChildrenWithCleanup(true)
		tempSp:setScale(0.6)
		local quality = cardCfg:getNodeWithKey("quality"):toInt()
		local tempBG = CCSprite:createWithSpriteFrameName(quality_table[quality+1])
		if tempBG then
			tempBG:setScale(0.6)
			tempNode:addChild(tempBG)
		end
		tempNode:addChild(tempSp)
	end
	return tempNode
end


function game_fame_bamen_pop:refreshStrengthLabel()

	local m_strengTab = self.m_tGameData.strengthen
	for k,v in pairs(attrsTab) do
		local streng = self.m_famous_strengthenCfg[tostring(k)]
		local tempStr = tonumber(m_strengTab[v] or 0)
		local effect = tonumber(streng.strengthen_effect) * tempStr
		local label1 = self.m_ccbNode:labelTTFForName("m_lb_" .. v .. "1")
		local value1 = self.m_tCardData[v]
		value1 = self:resetValue(value1)
		label1:setString(value1)

		local label2 = self.m_ccbNode:labelTTFForName("m_lb_" .. v .. "2")
		local value2 = self.m_tCardData[v] * effect
		value2 = self:resetValue(value2)
		label2:setString("+" .. tostring(effect))
	end
end


function game_fame_bamen_pop:resetValue(value)
	local num1 = math.floor(value/1000)
	local num2 = math.floor(value/10000)
	if num1 < 0  then
		return math.floor(value)
	elseif num1 > 0 and num2 < 0 then
		return tostring(num1) .. "k"
	elseif num2 > 0 then
		return tostring(num1) .. "k"
	else
		return math.floor(value)
	end
end

function game_fame_bamen_pop:createProgress()
	self.bar = ExtProgressTime:createWithFrameName("fame_progress3.png","fame_progress2.png");
    -- self.bar:setScaleY(1.5);
    local viewSize = self.m_progress_node:getContentSize()
    self.bar:setMaxValue(24)
    self.bar:setCurValue(0,false);
    self.bar:setCurValue(self.m_streng_count,true);
    self.bar:setAnchorPoint(ccp(0.5,0.5))
    self.bar:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
    self.m_progress_node:addChild(self.bar,10)
    self.m_progress_node:setScaleY(1.4)
end


function game_fame_bamen_pop:addAnim(tempSp)
    local animArr = CCArray:create();
    animArr:addObject(CCFadeTo:create(1,0))
    animArr:addObject(CCFadeTo:create(1,255))
    tempSp:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
end


function game_fame_bamen_pop:refreshUi()
    local function onAnimSectionEnd( animNode, theId,theLabelName )
        animNode:playSection(theLabelName);
    end
    local anim = game_util:createBlenderAnim("famous_texiao1",0, true);
    anim:registerScriptTapHandler(onAnimSectionEnd)
    anim:playSection("impact@1");
    anim:setScale(1)
	self.m_img_node:addChild(anim)

	local tempData,tempCfg = game_data:getCardDataById(self.m_tGameData.card_id)
	local sp = CCSprite:create("img/image_" .. tempCfg:getNodeWithKey("animation"):toStr() .. ".png")
	if sp then
		sp:setPositionY(5)
		self.m_img_node:addChild(sp)
	end
	local selCardCfg = nil
	for i=1,8 do
		local id = self.m_gate["gate" .. i]
		if id then
			local tempNode = self.m_ccbNode:nodeForName("m_icon_node" .. i)
			tempNode:removeAllChildrenWithCleanup(true)
			local _,item = game_data:getCardDataById(id)
			if self.m_selectd == i then
				selCardCfg = item
			end
			self.m_streng_count = self.m_streng_count + item:getNodeWithKey("streng"):toInt()
			local tempSp = self:createHeroIconByCfg(item)
			if tempSp then
				tempNode:addChild(tempSp)
			end
		end
	end
	self.m_streng_lb:setString(self.m_streng_count .. "/24")
	self.m_streng_lb1:setString(self.m_streng_count .. "/24")
	local data1,data2 = game_data:getFamousPosAtt(self.m_famous_id,"gate" .. self.m_selectd ,selCardCfg)
	local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon_tab[data2[1]])
	if tempSpriteFrame then
		self.m_sel_ablity_sp:setDisplayFrame(tempSpriteFrame)
	end
	local str = data1 and data1[2] or 0
	self.m_sel_ablity_lb:setString(tostring(str) .. "/" .. tostring(data2[2]))
	self:createProgress()
	self:refreshAttrsLabel()
	self:refreshStrengthLabel()
end

function game_fame_bamen_pop:init(t_params)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/Monster_Summoning.plist");
	local famous_strengthenCfg = getConfig(game_config_field.famous_strengthen)
	self.m_famous_strengthenCfg = json.decode(famous_strengthenCfg:getFormatBuffer())
	local t_params = t_params or {}
	if t_params.gameData then
		local data = t_params.gameData:getNodeWithKey("data")
		self.m_tGameData = json.decode(data:getNodeWithKey("famous_detail"):getFormatBuffer())
		self.m_gate = self.m_tGameData.gate or {}
	end
	local card_id = self.m_tGameData.card_id
	local card_Data,cardCfg = game_data:getCardDataById(card_id)
	self.m_tCardData = card_Data
	self.m_famous_id = t_params.famous_id
	local attrs = game_data:getAttrsDataByFame_Id(self.m_famous_id)
	self.m_Famous_attr = game_data:getFamousAttrs()
	self.m_streng_count = 0
	self.m_selectd = self.m_selectd or 1
	self.m_isChanged = false


end

function game_fame_bamen_pop:create(t_params)
	self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;

end
return game_fame_bamen_pop