local ui_talent_main = {
	check_hero_skill = nil,
}
function ui_talent_main:destroy()
	self.check_hero_skill = nil;
end

function ui_talent_main:back()
    local function endCallFunc()
		self:destroy();
	end
	local function responseMethod(tag,gameData)
		if tag == "cards_open" and gameData then
            local data = gameData:getNodeWithKey("data");
            game_data:updateCardsOpenByJsonData(data);
	    end
    end

    local params = {};
    params.tel = game_data:getPhoneNum()
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_open"), http_request_method.GET, params, "cards_open",true,true)
	game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end


function ui_talent_main:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 1 then
			self:back()
		end
	end
	local ccbNode =  luaCCBNode:create();
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_talent_main.ccbi")
	self.m_list_node = ccbNode:nodeForName("m_list_node")
	local skill_list = {}
	local sp_list = self:getSpList(ccbNode)
	self.m_sp_list = sp_list
	for i=1,5 do
		skill_list[i] = {}
		for j=1,4 do
			local talent_skill = ccbNode:nodeForName("m_talent_skill_" .. i .. "_" .. j)
			if talent_skill then
				skill_list[i][#skill_list[i]+1] = talent_skill 
			end
		end
	end
	self.m_skill_list = skill_list
	return ccbNode
end


function ui_talent_main:getSpList(ccbNode)

	local list = {}
	local sp_4_2_3_1 = ccbNode:spriteForName("sp_4_2_3_1")
	list.sp_4_2_3_1 = sp_4_2_3_1

	local sp_2_3_3_1 = ccbNode:spriteForName("sp_2_3_3_1")
	list.sp_2_3_3_1 = sp_2_3_3_1

	local sp_4_4_4_3 = ccbNode:spriteForName("sp_4_4_4_3")
	list.sp_4_4_4_3 = sp_4_4_4_3

	local sp_5_2_4_4 = ccbNode:spriteForName("sp_5_2_4_4")
	list.sp_5_2_4_4 = sp_5_2_4_4

	local sp_2_1_2_2 = ccbNode:spriteForName("sp_2_1_2_2")
	list.sp_2_1_2_2 = sp_2_1_2_2

	local sp_1_1_2_1 = ccbNode:spriteForName("sp_1_1_2_1")
	list.sp_1_1_2_1 = sp_1_1_2_1

	local sp_5_1_4_1 = ccbNode:spriteForName("sp_5_1_4_1")
	list.sp_5_1_4_1 = sp_5_1_4_1

	local sp_2_2_3_1 = ccbNode:spriteForName("sp_2_2_3_1")
	list.sp_2_2_3_1 = sp_2_2_3_1

	local sp_1_2_2_4 = ccbNode:spriteForName("sp_1_2_2_4")
	list.sp_1_2_2_4 = sp_1_2_2_4

	local sp_2_4_2_3 = ccbNode:spriteForName("sp_2_4_2_3")
	list.sp_2_4_2_3 = sp_2_4_2_3

	local sp_4_1_4_2 = ccbNode:spriteForName("sp_4_1_4_2")
	list.sp_4_1_4_2 = sp_4_1_4_2

	local sp_4_3_3_1 = ccbNode:spriteForName("sp_4_3_3_1")
	list.sp_4_3_3_1 = sp_4_3_3_1
	return list
end


function ui_talent_main:refreshTalent()
	local function backCallFunc( gameData )
		local data =  json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
		-- cclog2(data,"dadsadasdasdasdadasdsadsa")
		self.check_hero_skill = data.available_talent or nil
		local card_data = self.m_card[tostring(self.m_select_index)]
		self.check_skill = self:refreshSkill(card_data.talent_skill_id,data.available_talent)
		self.m_cost_id = card_data.evo_stone
		self.m_skill_cost = self:getCost(card_data.evo_stone,data.item)
		self:refreshTalent()
	end
	local function onMainBtnClick(target, event)
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		game_scene:addPop("ui_talent_skill_pop",{skill_data = self.check_skill[btnTag],backCallFunc = backCallFunc,check_card_id = self.check_card_id,skill_cost = self.m_skill_cost,cost_id = self.m_cost_id})
	end
	for i=1,#self.check_skill do
		local Can_up = true
		local skill_dataCfg = self.check_skill[i]
		local isCanup = self:getCanup(skill_dataCfg)
		for k,v in pairs(isCanup) do
			if v.canup == false then
				Can_up = false
			end
			if self.m_sp_list[k] then
				local tempSpriteFrame
				if v.zhaunjiao then
					if v.canup then
						tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zhuanjiao01.png")
					else
						tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("talent_zhuanjiao02.png")
					end
				else
					if v.canup then
						tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("guang01.png")
					else
						tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("guang02.png")
					end
				end
				if tempSpriteFrame then
					self.m_sp_list[k]:setDisplayFrame(tempSpriteFrame)
				end
			end
		end
		skill_dataCfg.Can_up = Can_up
		local ccbNode = luaCCBNode:create()
		ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
		ccbNode:openCCBFile("ccb/ui_talent_item.ccbi")
		ccbNode:setPosition(ccp(0,0))
		ccbNode:setAnchorPoint(ccp(0.5,0.5))
		local btn = ccbNode:controlButtonForName("skill_btn")
		local skill_sq = ccbNode:spriteForName("skill_sq")
		local skill_sp = ccbNode:spriteForName("skill_sp")
		local lv_lb = ccbNode:labelTTFForName("lv_lb")
		local tempSpriteFrame
		if Can_up then
			tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(skill_dataCfg.img .. ".png")
		else
			tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(skill_dataCfg.img .. "02.png")
		end	
	    lv_lb:setString(skill_dataCfg.level .. "/" .. skill_dataCfg.max_level)
	    if tempSpriteFrame then
	        skill_sp:setDisplayFrame(tempSpriteFrame)
	    end
	    skill_sq:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("talent_lv_" .. skill_dataCfg.type .. ".png"))
	    btn:setOpacity(0)
	    btn:setTag(i)
	    local x,y = skill_dataCfg.xy[1],skill_dataCfg.xy[2]
	    local parent_node = self.m_skill_list[x][y]
	    parent_node:removeAllChildrenWithCleanup(true)
		parent_node:addChild(ccbNode)
	end
end

function ui_talent_main:getCanup(skill_dataCfg)
	local pre_skill = skill_dataCfg.pre_skill
	local isCanup = {}
	for k,v in pairs(pre_skill) do
		local s,zhaunjiao = self:getName(v,skill_dataCfg.id)
		local canup = true

		if self.check_hero_skill[tostring(v)] == nil or self.check_hero_skill[tostring(v)] < 5 then
			canup = false
		end
		isCanup[s] = {canup = canup, zhaunjiao = zhaunjiao}
	end
	return isCanup
end


function ui_talent_main:getName(pre_id, sk_id)
	local s = "sp_"
	local zhaunjiao = false
	local pre_skill = self.skill[tostring(pre_id)].xy
	-- json.decode(self.skill:getNodeWithKey(tostring(pre_id)):getFormatBuffer()).xy
	local skill = self.skill[tostring(sk_id)].xy
	-- json.decode(self.skill:getNodeWithKey(tostring(sk_id)):getFormatBuffer()).xy
	if pre_skill and skill then
		s = s .. pre_skill[1] .. "_" .. pre_skill[2] .. "_" .. skill[1] .. "_" .. skill[2]
	end
	if pre_skill[1] ~= skill[1] then
		zhaunjiao = true
	end
	return s,zhaunjiao
end





function ui_talent_main:createTableView(viewSize)
    local imgSelectTab = {}
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();        
    end
    local length = game_util:getTableLen(self.m_card)
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1; --列
    params.totalItem = length;
    params.direction = kCCScrollViewDirectionVertical;--纵向

    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            ccbNode:removeAllChildrenWithCleanup(true)
            imgSelectTab[ccbNode] = nil
            local curData = self.m_card[tostring(index+1)]
            local imgName = curData.img
            local bossImg = CCSprite:create("ccbResources/card_banner/" ..imgName .. ".png")
            bossImg:setScale(1)
            ccbNode:addChild(bossImg,10,100)

            local imgSelect = CCSprite:createWithSpriteFrameName("dispatch_lightKuang.png")
            imgSelect:setScale(1)
            if self.m_select_index == index + 1 then
                imgSelect:setVisible(true)
            else
                imgSelect:setVisible(false)
            end
            ccbNode:addChild(imgSelect,10,101)
            imgSelectTab[ccbNode] = imgSelect
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
            local imgSelect = ccbNode:getChildByTag(101)
            for k,v in pairs(imgSelectTab) do
            	if k ~= ccbNode then
                	v:setVisible(false)
            	end
            end
            imgSelect:setVisible(true)
            self.m_select_index = index + 1
            local card_data = self.m_card[tostring(self.m_select_index)]
            local params = {}
            params.c_id = card_data.card
            self.check_card_id = card_data.card
            local function responseMethod(tag, gameData)
            	-- cclog2(gameData,"gameData------------")
            	local data =  json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
            	-- cclog2(data,"gameData------------")
            	self.check_hero_skill = data.available_talent or nil
            	self.check_skill = self:refreshSkill(card_data.talent_skill_id,data.available_talent)
            	-- cclog2(skill_data,"skill_data----------")
            	self.m_cost_id = card_data.evo_stone
            	self.m_skill_cost = self:getCost(card_data.evo_stone,data.item)
            	self:refreshTalent()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("talentskill_index"), http_request_method.GET, params,"talentskill_index");
        end
    end
    return TableViewHelper:create(params);
end


function ui_talent_main:refreshSkill(talent_skill, skill_data)
	-- cclog2(self.skill,"self.skill -=-=-=-=-=-=-=-=-=-=-=-=")
	local hero_skill = {}
	for k,v in pairs(talent_skill) do
		local skill = self.skill[tostring(v)]
		if not skill then
			cclog("  error  skill  id  -------->>>>>" .. v)
		end
		if skill_data[tostring(v)] then
			skill.level = skill_data[tostring(v)]
		else
			skill.level = 0
		end
		skill.id = v
		table.insert(hero_skill,skill)
	end
	return hero_skill
end


function ui_talent_main:refreshUi()
	self.m_list_node:addChild(self:createTableView(self.m_list_node:getContentSize())) 
	local card_data = self.m_card[tostring(self.m_select_index)]
    local params = {}
    params.c_id = card_data.card
    self.check_card_id = card_data.card
    local function responseMethod(tag, gameData)
    	local data =  json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
    	self.check_hero_skill = data.available_talent or nil
    	self.check_skill = self:refreshSkill(card_data.talent_skill_id,data.available_talent)
    	self.m_cost_id = card_data.evo_stone
    	self.m_skill_cost = self:getCost(card_data.evo_stone,data.item)
    	self:refreshTalent()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("talentskill_index"), http_request_method.GET, params,"talentskill_index");
end


function ui_talent_main:getCost(evo, gameItem)
	local cost = 0
	if gameItem[tostring(evo)] then
		for k,v in pairs(gameItem[tostring(evo)]) do
			cost = cost + tonumber(v)
		end
	end
	return cost
end


function ui_talent_main:init()
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_dispatch.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/talent.plist");
    self.dispatch_item_cfg = json.decode(getConfig(game_config_field.dispatch_item):getFormatBuffer())
    self.m_card = json.decode(getConfig(game_config_field.talent_card):getFormatBuffer())
	self.skill = json.decode(getConfig(game_config_field.talent_skill):getFormatBuffer())
	-- self.skill = getConfig(game_config_field.talent_skill)
    self.m_select_index = 1
    self.m_cost_id = nil
end


function ui_talent_main:create()
	self:init()
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end

return ui_talent_main