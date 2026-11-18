local game_other_fame_scene = {
	m_ccbNode = nil,
	m_tGameData = nil,
	m_back_btn = nil,
	m_sel_card = nil,
	m_animTable = {},
	m_sel_node = nil,
	m_guang_node = nil,
	m_anim_tab_node = nil,
	m_anim_tab_node2 = nil,
	m_list_node = nil,
	m_list_layer = nil,
	m_title_sp = nil,
	m_title_lb1 = nil,
	m_title_lb2 = nil,
	m_touch_layer = nil,

	m_selectd_sp = nil,
	m_selectd_index = nil,

}

function game_other_fame_scene:destroy()
	cclog("--------------------- game_other_fame_scene destroy -------------")
	self.m_ccbNode = nil
	self.m_tGameData = nil
	self.m_back_btn = nil
	self.m_sel_card = nil
	self.m_animTable = {}
	self.m_sel_node = nil;
	self.m_guang_node = nil;
	self.m_anim_tab_node = nil;
	self.m_anim_tab_node2 = nil;
	self.m_list_node = nil;
	self.m_list_layer = nil;
	self.m_title_sp = nil;
	self.m_title_lb1 = nil;
	self.m_title_lb2 = nil;
	self.m_touch_layer = nil;
	self.m_selectd_sp = nil;
	self.m_selectd_index = nil;
end

function game_other_fame_scene:back()
	game_scene:enterGameUi("game_main_scene")
end

local animTab = {
	{sam = "chunyeying.swf.sam",plistName = "chunyeying.plist",Scale = 0.9,ScaleX = 1 ,effect = "daiji"},
	{sam = "lufei.swf.sam",plistName = "lufei.plist",Scale = 0.9,ScaleX = 1 ,effect = "daiji"},
	{sam = "black-wukong.swf.sam",plistName = "black-wukong.plist",Scale = 0.9,ScaleX = 1 ,effect = "daiji"},
	{sam = "dachui.swf.sam",plistName = "dachui.plist",Scale = 0.9,ScaleX = 1 ,effect = "daiji"},
	{sam = "falaozhiying.swf.sam",plistName = "falaozhiying.plist",Scale = 0.9,ScaleX = 1 ,effect = "daiji"},
	{sam = "heshang.swf.sam",plistName = "heshang.plist",Scale = 0.9,ScaleX = 1 ,effect = "daiji"},
}


local position_XY = {
	positionX_1 = {0.5},
	positionX_2 = {0.4 ,0.6},
	positionX_3 = {0.3 ,0.5 ,0.7},
	positionX_4 = {0.2 ,0.4 ,0.6 ,0.8},
	positionX_5 = {0.1 ,0.3 ,0.5 ,0.7 ,0.9 },
	positionY_1 = {0},
	positionY_2 = {0.08 ,0.08 },
	positionY_3 = {0.08 ,0 ,0.08},
	positionY_4 = {0.33 ,0.08 ,0.08 ,0.33,},
	positionY_5 = {0.33 ,0.08 ,0 ,0.08 ,0.33},
	positionX2_1 = {0.5},
	positionX2_2 = {0.25 ,0.75 },
	positionX2_3 = {0.25 ,0.5 ,0.75},
	positionX2_4 = {0.08 ,0.25 ,0.75 ,0.92,},
	positionX2_5 = {0.08 ,0.25 ,0.5,0.75 ,0.92},
}


function game_other_fame_scene:createUi()
	local ccbNode = luaCCBNode:create()
	self.m_ccbNode = ccbNode
	local function onMainBtnClick(target,event)
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
        	self:back()
    	elseif btnTag >100 and btnTag ~= 999 then
    		local index = btnTag - 100
    		if self.m_famous_detail[tostring(index)] and self.m_famous_detail[tostring(index)].card_id ~= "" then
				local data = self.m_famous_detail[tostring(index)]
    			local isLike = data.islike
    			local famous_like_times = data.famous_like_times or data.like_times or 0
    			local cardData = data.carddata
    			local str = "×" .. tostring(famous_like_times) .. (isLike and "(已赞)" or "")
    			self.m_like_lb:setString(str)
	    		if self.m_sel_card == index then
	            	game_scene:addPop("game_hero_info_pop",{tGameData = cardData,openType = 3,enterType = "famous"})
		        else
	    			self.m_sel_card = index	
	    			self.m_sel_node:setVisible(true)
	    			local x,y = self.m_animTable[index]:getParent():getParent():getPosition()
	    			self.m_sel_node:setPosition(ccp(x,y))
	    			self.m_guang_node:setPosition(ccp(x,y))
					self.m_guang_node:setVisible(true)
		    	end
		    else
	    		self.m_sel_node:setVisible(false)
	    		self.m_guang_node:setVisible(false)
		    end

	    elseif btnTag == 999 then
	    	local x,y = self.m_list_layer:getPosition()
	    	if y > 300 then
    			self.m_touch_layer:setTouchEnabled(true);
		    	local move = CCMoveTo:create(0.5,ccp(x,y-600))
		    	self.m_list_layer:runAction(move)
		    elseif y < 300 then
    			self.m_touch_layer:setTouchEnabled(false);
		    	local move = CCMoveTo:create(0.5,ccp(x,y+600))
		    	self.m_list_layer:runAction(move)
		    end
		elseif btnTag == 23 then
			local isCanTouchLike = self:isCanTouchLikeBy(self.m_sel_card)
			if not isCanTouchLike then
				game_util:addMoveTips({text = "Mỗi ngày chỉ được Like 1 lần!"})
				return
			end
			local function responseMethod(tag,gameData)
				local data = gameData:getNodeWithKey("data")
				self.m_tGameData = json.decode(data:getFormatBuffer())
				self.m_famous_detail = self.m_tGameData.famous_detail or {}
				self:refreshLikeTimesByFamousId(self.m_sel_card)
				game_util:addMoveTips({text = "Đã ấn Like thành công!"})
	        end
	        local params = {}
	        params.famous_id = self.m_sel_card
	        params.uid = self.m_uid

	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_famous_like"), http_request_method.GET,params,"cards_famous_like")
        end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_fame_scene.ccbi")
	self.m_sel_node = ccbNode:nodeForName("m_sel_node")
	self.m_guang_node = ccbNode:nodeForName("m_guang_node")
	self.m_anim_tab_node = ccbNode:nodeForName("anim_tab_node")
	self.m_anim_tab_node2 = ccbNode:nodeForName("anim_tab_node2")
	self.m_guang_node:setVisible(false)
	self.m_sel_node:setVisible(false)
	self.m_like_lb = ccbNode:labelTTFForName("m_like_lb")
	for i=1,5 do
		ccbNode:controlButtonForName("m_card_btn_" .. i):setTouchPriority(GLOBAL_TOUCH_PRIORITY)
	end


	local m_btn_yulan = ccbNode:controlButtonForName("m_btn_yulan")
	local m_btn_bamen = ccbNode:controlButtonForName("m_btn_bamen")
	m_btn_yulan:setVisible(false)
	m_btn_bamen:setVisible(false)

	local tempNode = self.m_list_node
	local tempNode = ccbNode:nodeForName("m_list_node")
	local viewSize = tempNode:getContentSize()
	self.m_list_node = CCNode:create()
	self.m_list_node:setContentSize(viewSize)
	local m_scrollView = ccbNode:scrollViewForName("m_scrollView")
	self.m_list_layer = CCLayerColor:create(ccc4(0,0,0,150), viewSize.width, viewSize.height);
	self.m_list_layer:setContentSize(viewSize)
	m_scrollView:addChild(self.m_list_layer)
	self.m_list_layer:addChild(self.m_list_node)
	self.m_list_layer:setPositionY(600)
	m_scrollView:setTouchEnabled(false)


	local m_title_spBG = ccbNode:spriteForName("m_title_spBG")
	self:addAnim(m_title_spBG)
	self.m_title_sp = ccbNode:spriteForName("m_title_sp")
	self.m_title_lb1 = ccbNode:labelTTFForName("m_title_lb1")
	self.m_title_lb2 = ccbNode:labelTTFForName("m_title_lb2")
	self.m_touch_layer = ccbNode:layerForName("m_touch_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
        	local realPos1 = self.m_touch_layer:getParent():convertToNodeSpace(ccp(x,y));
            if not self.m_touch_layer:boundingBox():containsPoint(realPos1)then
                return
            end

            return true;
        end
    end
    self.m_touch_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 1,true);
    self.m_touch_layer:setTouchEnabled(false);

	return ccbNode
end


function game_other_fame_scene:getCardIdByfamousId(famousId)
	local Tempfamous = self.famous:getNodeWithKey(tostring(famousId))
	local tempTab = json.decode(Tempfamous:getNodeWithKey("card_id"):getFormatBuffer())
	local tempTab1 = {}
	for k,v in pairs(tempTab) do
		tempTab1[tostring(v)] = 1
	end
	return tempTab[1],tempTab,tempTab1
end


function game_other_fame_scene:isCanTouchLikeBy( famous_id )
	local tempDetail = self.m_famous_detail[tostring(famous_id)] or {}
	if tempDetail.islike then
		return false
	else
		return true
	end
end

function game_other_fame_scene:refreshLikeTimesByFamousId(famous_id)
	local tempDetail = self.m_famous_detail[tostring(famous_id)] or {}
	local famous_like_times = tempDetail.famous_like_times or tempDetail.like_times or 0
	local str = ""
	if tempDetail.islike then
		str = "×" .. tostring(famous_like_times) .. "(Đã Like)"
	else
		str = "×" .. tostring(famous_like_times)
	end
	self.m_like_lb:setString(str)
end

function game_other_fame_scene:createAnimWithNameAndSkill(samName,id,plistName,ScaleX,Scale,effect)
	local onAnimSectionEnd = function(animNode, theId,theLabelName)
        animNode:playSection(theLabelName)
    end
	local anim = game_anim:create(samName , id , plistName);
    if anim then
        anim:registerScriptTapHandler(onAnimSectionEnd)
        game_anim:playSection(anim,effect)
        anim:setScale(Scale)
    end
    return anim
end


function game_other_fame_scene:refreshAnim()
	self.m_sel_node:setVisible(false)
	self.m_guang_node:setVisible(false)
	local group1 = self.m_famous_group[tostring(self.m_selectd_index)] or {}
	local num1 = #group1.famous_id
	local xT1 = position_XY["positionX_" .. num1]
	local yT1 = position_XY["positionY_" .. num1]
	local viewSize = self.m_anim_tab_node:getContentSize()
	for i=1,5 do
		local id = group1.famous_id[i]
		if id then
			local data = self.m_famous_detail[tostring(id)]
			local tempC_id = self:getCardIdByfamousId(id)
			local tempCfg = self.character_detail_cfg:getNodeWithKey(tostring(tempC_id))
			local animation = tempCfg:getNodeWithKey("animation"):toStr()
			local pNode = self.m_ccbNode:nodeForName("anim_node" .. i)
			local node = self.m_ccbNode:nodeForName("m_anim_node" .. i)
			local xunzhang = self.m_ccbNode:spriteForName("m_xunzhang_sp" .. i)
			xunzhang:setVisible(false)

			pNode:setVisible(true)
			node:removeAllChildrenWithCleanup(true)
			pNode:setPosition(ccp(viewSize.width*xT1[i],viewSize.height*yT1[i]))
			local temp_card_btn = self.m_ccbNode:controlButtonForName("m_card_btn_" .. i)
			temp_card_btn:setOpacity(0)
			temp_card_btn:setVisible(true)
			temp_card_btn:setTag(100+tonumber(id))
			local tempTab = animTab[i]
			local anim = game_util:createIdelAnim(animation)
			if data and data.card_id ~= "" then
				local animation = data.carddata.animation
				anim = game_util:createIdelAnim(animation)
				anim:setColor(ccc3(255,255,255))
			else
				anim:setColor(ccc3(0,0,0))
			end
			self.m_animTable[id] = anim
			anim:setAnchorPoint(ccp(0.5,0))
			anim:setPosition(ccp(0,0))
			node:addChild(anim,2)
		else
			self.m_ccbNode:nodeForName("anim_node" .. i):setVisible(false)
			self.m_ccbNode:nodeForName("m_anim_node" .. i):removeAllChildrenWithCleanup(true)
			self.m_ccbNode:controlButtonForName("m_card_btn_" .. i):setVisible(false)
		end
	end
	local group2 = self.m_famous_group[tostring(self.m_selectd_index +1)] and self.m_famous_group[tostring(self.m_selectd_index +1)] or self.m_famous_group[tostring(1)]
	local num2 = #group2.famous_id
	local xT2 = position_XY["positionX2_" .. num2]
	local viewSize2 = self.m_anim_tab_node:getContentSize()
	for i=1,5 do
		local id = group2.famous_id[i]
		if id then
			local tempC_id = self:getCardIdByfamousId(id)
			local tempCfg = self.character_detail_cfg:getNodeWithKey(tostring(tempC_id))
			local animation = tempCfg:getNodeWithKey("animation"):toStr()
			local node = self.m_ccbNode:nodeForName("anim_node2" .. i)
			node:removeAllChildrenWithCleanup(true)
			node:setVisible(true)

		    local function onAnimSectionEnd( animNode, theId,theLabelName )
		        animNode:playSection(theLabelName);
		    end
			local anim_texiao = game_util:createBlenderAnim("famous_texiao",0, true);
		    anim_texiao:registerScriptTapHandler(onAnimSectionEnd)
		    anim_texiao:playSection("impact");
		    -- anim:playSection("impact@1");
		    anim_texiao:setScale(0.8)
			node:addChild(anim_texiao)
			node:setPositionX(viewSize2.width*xT2[i])
			local tempTab = animTab[i]
			local anim = game_util:createIdelAnim(animation)
			-- local anim = self:createAnimWithNameAndSkill(animation .. ".swf.sam",0,animation .. ".plist",tempTab.ScaleX ,0.5,tempTab.effect)
			if self.m_famous_detail[tostring(id)] and self.m_famous_detail[tostring(id)].card_id ~= "" then
				local data = self.m_famous_detail[tostring(id)]
				local animation = data.carddata.animation
				anim = game_util:createIdelAnim(animation)
				anim:setColor(ccc3(255,255,255))
			else
				anim:setColor(ccc3(0,0,0))
			end
			anim:setScale(0.5)
			node:addChild(anim,2)
		else
			self.m_ccbNode:nodeForName("anim_node2" .. i):setVisible(false)
			self.m_ccbNode:nodeForName("anim_node2" .. i):removeAllChildrenWithCleanup(true)
		end
	end
end

function game_other_fame_scene:createTableView(viewSize)
	local img = {"famous_blue","famous_green","famous_purple","famous_orange","famous_red","famous_blue","famous_green","famous_purple","famous_orange","famous_red","famous_blue","famous_green","famous_purple","famous_orange","famous_red"}
	local name = {"Vua Hải Tặc","Loạn Thế Anh Hùng","Naruto","Fairy Tail","Dragon Ball","Vua Hải Tặc","Loạn Thế Anh Hùng","Naruto","Fairy Tail","Dragon Ball","Vua Hải Tặc","Loạn Thế Anh Hùng","Naruto","Fairy Tail","Dragon Ball"}
	self.m_imgSelectTab = {}
    local length = game_util:getTableLen(self.m_famous_group)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = length;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 2
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_fame_list_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
        	local item = self.m_famous_group[tostring(index + 1)]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local imgName = item.group_banner or img[index+1]
            local name = item.group_name or name[index+1]
            local img_sp = ccbNode:spriteForName("m_main_sp")
            img_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(imgName .. ".png"))
            local name_lb1 = ccbNode:labelTTFForName("name_lb1")
            local name_lb2 = ccbNode:labelTTFForName("name_lb2")
            name_lb1:setString(name)
            name_lb2:setString(name)
            local imgSelect = ccbNode:spriteForName("m_select_sp")
            if self.m_selectd_index == index + 1 then
            	self.m_selectd_sp = imgSelect
            	imgSelect:stopAllActions()
            	self:addAnim(imgSelect)
                imgSelect:setVisible(true)
                self.m_title_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(imgName .. ".png"))
				self.m_title_lb1:setString(name)
				self.m_title_lb2:setString(name)
            else
                imgSelect:setVisible(false)
            end
            self.m_imgSelectTab[ccbNode] = imgSelect
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
        	local itemData = self.m_famous_group[tostring(index + 1)]
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
            if self.m_selectd_sp ~= nil then
            	-- self.m_selectd_sp:stopAllActions()
            	self.m_selectd_sp:setVisible(false)
            end
            local selectd_sp = self.m_imgSelectTab[ccbNode]
            if selectd_sp then
            	selectd_sp:setVisible(true)
            	selectd_sp:stopAllActions()
            	self:addAnim(selectd_sp)
            	self.m_selectd_sp = selectd_sp
            end
           	self.m_title_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName((itemData.group_banner and itemData.group_banner or img[index+1]) .. ".png"))
			self.m_title_lb1:setString(itemData.group_name and itemData.group_name or name[index+1])
			self.m_title_lb2:setString(itemData.group_name and itemData.group_name or name[index+1])
            self.m_selectd_index = index + 1
            self:refreshAnim()
        end
    end
    return TableViewHelper:create(params);
end


function game_other_fame_scene:addAnim(tempSp)
    local animArr = CCArray:create();
    animArr:addObject(CCFadeTo:create(1,0))
    animArr:addObject(CCFadeTo:create(1,255))
    tempSp:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
end

function game_other_fame_scene:refreshUi()
	local tempTable = self:createTableView(self.m_list_node:getContentSize())
	self.m_list_node:removeAllChildrenWithCleanup(true)
	self.m_list_node:addChild(tempTable)
	self:refreshAnim()
end

function game_other_fame_scene:init(t_params)
	local t_params = t_params or {}
	if t_params.gameData then
		local data = t_params.gameData:getNodeWithKey("data")
		self.m_tGameData = json.decode(data:getFormatBuffer())
		self.m_famous_detail = self.m_tGameData.famous_detail or {}
	end
	self.m_uid = t_params.uid
	local famous_group = json.decode(getConfig(game_config_field.famous_group):getFormatBuffer())
	self.famous = getConfig(game_config_field.famous)
    self.character_detail_cfg = getConfig(game_config_field.character_detail);
    self.m_famous_group = famous_group
    self.m_selectd_index = self.m_selectd_index or 1
end

function game_other_fame_scene:create(t_params)
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end
return game_other_fame_scene