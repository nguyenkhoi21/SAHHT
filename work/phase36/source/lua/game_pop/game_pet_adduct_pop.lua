--宠物跟随效果加成

local game_pet_adduct_pop = {
	m_selListItem = nil,        -- 选中的宠物
	m_cur_select_id = nil,
	m_combatNumberChangeNode = nil,  -- 战斗力显示node
    m_tempCombatValue = nil,         -- 战斗力

    m_sel_btn = nil,        --  选取宠物按钮 -- 宠物展示底板
    node_anim = nil,        --  宠物卡牌像节点
    node_attr_list = nil,   --  宠物属性

    m_final_add_label = nil, --最终加成
    m_ref_add_label = nil, --刷新效果
    m_ref_btn = nil, --刷新
    cost_label = nil, --消耗
    m_list_view_bg = nil, --宠物列表
    m_selcet_index = nil,

    m_tips_spr_1 = nil, --宠物动画
    m_light_bg_1 = nil,
    m_sel_btn = nil,
    m_anim_node = nil,
    unit_sprite = nil, --消耗碎片
    m_tGameData = nil,
    pet_follow = nil,
    pet_refresh = nil,
    m_explain_btn = nil,
    follow_label = nil,
    last_selecet = nil,
}

function game_pet_adduct_pop.destroy( self )

	cclog("-----------------game_pet_adduct_pop destroy-----------------");

	self.m_selListItem = nil;
	self.m_cur_select_id = nil;
	self.m_combatNumberChangeNode = nil;
	self.m_tempCombatValue = nil;

	self.m_sel_btn = nil;
	self.node_anim = nil;
	self.node_attr_list = nil;

	self.m_final_add_label = nil;
	self.m_ref_add_label = nil;
	self.m_ref_btn = nil;
	self.cost_label = nil;
	self.m_list_view_bg = nil;
	self.m_selcet_index = nil;

	self.m_tips_spr_1 = nil;
    self.m_light_bg_1 = nil;
    self.m_sel_btn = nil;
    self.m_anim_node = nil;
    self.unit_sprite = nil;
    self.m_tGameData = nil;
    self.pet_follow = nil;
    self.pet_refresh = nil;
    self.follow_label = nil;
    self.m_explain_btn = nil;
    self.last_selecet = nil;
end
	
--[[--
    返回
]]
function game_pet_adduct_pop.back(self,backType)

    -- game_scene:removePopByName("game_pet_adduct_pop");
    game_scene:enterGameUi("game_pet_adjustment_scene_new",{gameData = nil});
end	

function game_pet_adduct_pop.createUi( self )
	-- body
	local ccbNode = luaCCBNode:create();
	local function onMainBtnClick( target,event )

		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then 
            -- game_scene:enterGameUi("game_main_scene");
            self:back()
        elseif btnTag == 105 then  -- 属性刷新
            cclog2("gensui lalalala")
        	if self.m_cur_select_id == nil then 
        		game_util:addMoveTips({text = "Xin chọn thú nuôi!"});
            else
                local pet_cfg = getConfig(game_config_field.pet_detail)
                local petData,petCfg = game_data:getPetDataById(tostring(self.m_cur_select_id));
                local cid = petData.c_id
                local petinfo = pet_cfg:getNodeWithKey(tostring(cid))
                local pet_item = json.decode(petinfo:getFormatBuffer()).resolve_id;
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    local _client_cache_update = data:getNodeWithKey("_client_cache_update")
                    local pets = _client_cache_update:getNodeWithKey("pets")
                    local pets = pets:getNodeWithKey("pets")
                    local update = pets:getNodeWithKey("update")
                    
                    self:initPetInfo(self.m_cur_select_id,update)
                    self:refreshCombatLabel();
                    -- self:refreshHeroInfo(self.m_cur_select_id)
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("refresh_pet_follow"), http_request_method.GET, {pet_id = self.m_cur_select_id,item = pet_item },"refresh_pet_follow")
        
        	end
        elseif btnTag == 106 then 
            -- self.m_cur_select_id
            --宠物跟随或取消跟随
            if self.last_selecet == true then
                local pet_follow_pos = game_data:getPetFollowPos()
                local isFollow,k = game_util:idInTableById(self.m_cur_select_id,pet_follow_pos)
                if  isFollow then
                    pet_follow_pos[k] = "0"
                    self:setPetFollowFormation()
                else
                    local pet_follow_pos = game_data:getPetFollowPos()
                    local openCount = 0
                    local haveCount = 0
                    for i=1,#pet_follow_pos do
                        if pet_follow_pos[i] and pet_follow_pos[i] ~= "-1" then
                            openCount = openCount + 1
                            if pet_follow_pos[i] and pet_follow_pos[i] ~= "0" then
                                haveCount = haveCount + 1
                            end
                        end
                    end
                    if haveCount >= openCount then
                        game_util:addMoveTips({text = "Số lượng đi theo đã đạt giới hạn!"})
                        return
                    end
                    for i=1,#pet_follow_pos do
                        if pet_follow_pos[i] and pet_follow_pos[i] == "0" then
                            pet_follow_pos[i] = self.m_cur_select_id
                            break
                        end
                    end
                    self:setPetFollowFormation()
                end
            else
            end
        elseif btnTag == 110 then--增加跟随数量上限
            local payValue = 20
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                -- cclog2(data,"data")
                game_util:addMoveTips({text = "Kích hoạt thành công!"})
                game_util:closeAlertView();
                self:refreshPetInfo(self.m_cur_select_id)
                self:refresh_pet_follow_num();
            end
            local pet_follow = getConfig(game_config_field.pet_follow)
            local pet_follow_pos = game_data:getPetFollowPos()
            local openCount = 0
            for i=1,#pet_follow_pos do
                if pet_follow_pos[i] and pet_follow_pos[i] ~= "-1" then
                    openCount = openCount + 1
                end
            end
            if openCount < #pet_follow_pos then
                local itemCfg = pet_follow:getNodeWithKey(tostring(openCount+1))
                local sort = itemCfg:getNodeWithKey("sort"):toInt()
                local priceType = {"Bụi Cường Năng","Bụi Siêu Năng"}
                local price = itemCfg:getNodeWithKey("price"):toInt()
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("activate_pet_follow_pos"), http_request_method.GET, {pos = openCount},"activate_pet_follow_pos")
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,       --可缺省
                    cancelBtnText = string_config.m_btn_cancel,
                    text = "Xác nhận dùng" .. price .. priceType[sort] .. "kích hoạt 1 vị trí thú nuôi đi theo?",      --可缺省
                    onlyOneBtn = false,
                    touchPriority = GLOBAL_TOUCH_PRIORITY-11,
                }
                game_util:openAlertView(t_params)
            else
                game_util:addMoveTips({text = "Tất cả vị trí đã kích hoạt!"})
            end
        end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pet_adduct_pop.ccbi");

    local m_combat_node = ccbNode:nodeForName("m_combat_node") --战斗力

    ---------------------       宠物列表相关node初始化        -------------------
    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg")   ---- 宠物列表底板

    ---------------------       宠物形象展示  ---------------
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")                      
    self.m_light_bg_1 = ccbNode:scale9SpriteForName("m_light_bg_1");
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn")   -- 
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.unit_sprite = ccbNode:nodeForName("unit_sprite")

    self.m_final_add_label = ccbNode:labelTTFForName("m_final_add_label");
    self.m_final_add_label:setString("")
    self.m_ref_add_label = ccbNode:labelTTFForName("m_ref_add_label");
    self.m_ref_add_label:setString("")
    self.cost_label = ccbNode:labelBMFontForName("cost_label")
    self.follow_label = ccbNode:labelTTFForName("follow_label")
    local openCount = 0
    local haveCount = 0
    local pet_follow_pos = game_data:getPetFollowPos()
    for i=1,9 do
        if pet_follow_pos[i] and pet_follow_pos[i] ~= "-1" then
            openCount = openCount + 1
            if pet_follow_pos[i] and pet_follow_pos[i] ~= "0" then
                haveCount = haveCount + 1
            end
        end
    end
    self.follow_label:setString(haveCount .. "/" .. openCount)
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local btn_use = ccbNode:controlButtonForName("btn_use")
    local btn_buchong = ccbNode:controlButtonForName("btn_buchong")
    self.m_explain_btn = ccbNode:controlButtonForName("m_explain_btn")
    ---------------------       初始化战斗力显示node        --------------
    self.m_combatNumberChangeNode = game_util:createExtNumberChangeNode({labelType = 2});
    self.m_combatNumberChangeNode:setAnchorPoint(ccp(0, 0.5));
    -- self.m_combatNumberChangeNode:setScale(0.75);
    m_combat_node:addChild(self.m_combatNumberChangeNode);
    self.m_combatNumberChangeNode:setCurValue(0,false);

    self.m_sel_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10)
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10)
    btn_use:setTouchPriority(GLOBAL_TOUCH_PRIORITY -10)
    btn_buchong:setTouchPriority(GLOBAL_TOUCH_PRIORITY -10)
    self.m_explain_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY -10)

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    
    return ccbNode;
end
function game_pet_adduct_pop.setPetFollowFormation( self )
    local pet_follow_pos = game_data:getPetFollowPos()
    local params = "&formation="
    for i=1,#pet_follow_pos do
        if i < #pet_follow_pos then
            params = params .. pet_follow_pos[i] .. "_"
        else
            params = params .. pet_follow_pos[i]
        end
    end
    local function responseMethod(tag,gameData)
        -- local data = gameData:getNodeWithKey("data")
        -- cclog2(data,"data")
        self:refreshUi()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("set_pet_follow_formation"), http_request_method.POST, params,"set_pet_follow_formation")

end
--[[--
    创建宠物列表
]]
function game_pet_adduct_pop.createPetTableView(self,viewSize)
    self.m_selListItem = nil;
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local cardsCount = game_data:getPetCount();
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = cardsCount -- totalItem;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 11
    local moveFlag = true
    local guideFlag = false
    
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createHeroListItemByCCB2();
            ccbNode:setScaleX(1.3);
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cclog2(ccbNode, "ccbNode  ==================== ")
            if ccbNode then cell:addChild(ccbNode,10,10); end
        end
        if cell then
            cell:setTag(index);
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if not self.m_selcet_index then 
                self.m_selcet_index = index
            end
            local itemData,itemCfg = game_data:getPetDataByIndex(index+1);
            if itemData then
                local card_id = itemData.id;
                game_util:setPetListItemInfoByTable2(ccbNode,itemData);
                -- cclog2(self.m_cur_select_id,"self.m_cur_select_id")
                -- cclog2(card_id,"card_id")
                if self.m_cur_select_id ~= nil and card_id == self.m_cur_select_id then
                    self.m_cur_select_id = card_id
                    local m_sel_img = ccbNode:spriteForName("sprite_selected")
                    m_sel_img:setVisible( true  );
                    local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                    sprite_back_alpha:setVisible( true  );
                    self.m_selListItem = cell;
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        self.last_selecet = true;
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
            local itemData,itemCfg = game_data:getPetDataByIndex(index+1);
            local card_id = itemData.id;
            if self.m_selListItem then
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("sprite_selected")
                m_sel_img:setVisible(false);
                local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                sprite_back_alpha:setVisible(false);
            end
            self.m_selListItem = cell;
            self.m_cur_select_id = card_id;
            self:refreshPetInfo(self.m_cur_select_id);
            local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
            local m_sel_img = ccbNode:spriteForName("sprite_selected")
            m_sel_img:setVisible(true);
            local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
            sprite_back_alpha:setVisible(true);
        end
    end

    local tableView = TableViewHelper:create(params);
    return tableView
end

--[[--
    属性宠物信息
]]
function game_pet_adduct_pop.refreshPetInfo(self, petId)
    self.m_cur_select_id = petId;
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    if petId ~= nil and petId ~= "-1" then
        self.m_tips_spr_1:setVisible(false);
        local petData,petCfg = game_data:getPetDataById(tostring(petId));
        self:initPetInfo(self.m_cur_select_id)
        petCfg = json.decode(petCfg:getFormatBuffer()) or {};
        local pet_img = petCfg.img or nil;
        local pet_quality = petCfg.quality or nil;
        if pet_img  and pet_quality then
            local rgb = petCfg.rgb_sort;
            -- if rgb then
            --     rgb = rgb:toInt();
            -- else
            --     rgb = 0;
            -- end
            if rgb == 1 then
                tempIcon:setColor(ccc3(47,255,118));
            elseif rgb == 2 then
                tempIcon:setColor(ccc3(67,117,253));
            elseif rgb == 3 then
                tempIcon:setColor(ccc3(171,65,255));
            end
        	local tempIcon= game_util:createIconByName(pet_img,quality);
        	tempIcon:setAnchorPoint(ccp(0,-0.1))
        	tempIcon:setScale(0.7)
            local super_quality_1 = petData.super_quality_1 or 0
            local qualityTab = super_quality_1 > 0 and HERO_QUALITY_COLOR_TABLE_2[super_quality_1] or HERO_QUALITY_COLOR_TABLE[pet_quality+1]
            if qualityTab then
                local tempIconSize = tempIcon:getContentSize();
                local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
                img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
                tempIcon:addChild(img1,-1,-1)
                local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
                img2:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
                tempIcon:addChild(img2,1,1)
            end
        	local shade_icon = CCSprite:create("icon/public_shade_2.png");
        	shade_icon:setAnchorPoint(ccp(0,0));
        	tempIcon:addChild(shade_icon)
        	self.unit_sprite:addChild(tempIcon)
            self.unit_sprite:setScale(0.6)
        end
        local ccbNode = game_util:createHeroListItemByCCB();
        game_util:setPetListItemInfoByTable(ccbNode,petData)
        self.m_anim_node:addChild(ccbNode,10,10);

        --宠物跟随
        local pet_follow_pos = game_data:getPetFollowPos()
        local isFollow = game_util:idInTableById(petId,pet_follow_pos)
        --需判断出战和跟随两种情况   
        cclog2(isFollow,"isFollow ====  ") 
        if isFollow then
            game_util:setCCControlButtonTitle(self.m_explain_btn,"Hủy đi theo")
        else 
            game_util:setCCControlButtonTitle(self.m_explain_btn,"Đi theo")
        end
        local openCount = 0
        local haveCount = 0
        for i=1,9 do
            if pet_follow_pos[i] and pet_follow_pos[i] ~= "-1" then
                openCount = openCount + 1
                if pet_follow_pos[i] and pet_follow_pos[i] ~= "0" then
                    haveCount = haveCount + 1
                end
            end
        end
        self.follow_label:setString(haveCount .. "/" .. openCount)
    end
    local flag = (self.m_status == 1)
    game_util:setCCControlButtonEnabled(self.m_ok_btn,not flag)

end

function game_pet_adduct_pop.refresh_pet_follow_num( self )
    --宠物跟随
    local pet_follow_pos = game_data:getPetFollowPos()
    local openCount = 0
    local haveCount = 0
    for i=1,9 do
        if pet_follow_pos[i] and pet_follow_pos[i] ~= "-1" then
            openCount = openCount + 1
            if pet_follow_pos[i] and pet_follow_pos[i] ~= "0" then
                haveCount = haveCount + 1
            end
        end
    end
    self.follow_label:setString(haveCount .. "/" .. openCount)
end

--初始化刷新属性
function game_pet_adduct_pop.initPetInfo( self ,cid,date)
	-- body
	local petData,petCfg = nil, nil;
	local pet_base_abi = nil;
	local all_ability = nil;
	local ref_cost = 0;
	local ref_rang = 1;
	if date then
		local update = json.decode(date:getFormatBuffer()) or {};
		local pet_ability = update[cid].refresh_num
		local is_refresh = update[cid].is_refresh or nil;
		petData,petCfg = game_data:getPetDataById(tostring(cid));
		local petinfo = json.decode(self.pet_follow:getFormatBuffer()) or {};
		pet_base_abi = petinfo["1"].value
		
		if is_refresh == true then
			all_ability = tonumber(pet_base_abi)+ tonumber(pet_ability)*100
			if all_ability >50 then
				self.m_final_add_label:setString("+50%")
			elseif all_ability < 10 then
				self.m_final_add_label:setString("+10%")
			else
				self.m_final_add_label:setString("+" .. all_ability .. "%")
			end	
		else
			all_ability = tonumber(pet_base_abi)
			self.m_final_add_label:setString("+" .. all_ability .. "%")
		end
	else
		petData,petCfg = game_data:getPetDataById(tostring(cid));
		local pet_ref = petData.refresh_num or 0;
		if pet_ref and pet_ref ~= 0 then
			local petinfo = json.decode(self.pet_follow:getFormatBuffer()) or {};
			pet_base_abi = petinfo["1"].value
			all_ability = tonumber(pet_base_abi)+ tonumber(pet_ref)*100
			self.m_final_add_label:setString("+" .. all_ability .. "%")
		else
			local petinfo = json.decode(self.pet_follow:getFormatBuffer()) or {};
			pet_base_abi = petinfo["1"].value
			all_ability = tonumber(pet_base_abi)
			self.m_final_add_label:setString("+" .. all_ability .. "%")
		end
	end
    local petinfo = json.decode(self.pet_refresh:getFormatBuffer()) or {};
    local max_all = 19
    local min_all = 11
    for k,v in pairs(petinfo) do
        local lenth = v.value_add[1]
        local min = lenth[1]
        local max = lenth[2]
        if max_all < max then
            max_all = max
        end
        if min_all > min then
            min_all = min
        end
    end
    for k,v in pairs(petinfo) do
        local lenth = v.value_add[1]
        local min = lenth[1]
        local max = lenth[2]
        if all_ability >= min  and all_ability <= max then
            ref_cost = v.refresh_cost
            local m = v.refresh_range[1]
            local x = m[1]
            local y = m[2]
            ref_rang = x/10 .. "%" .. "~" .. y/10 .."%"
            -- cclog2(ref_rang,"ref_rang = ")
        elseif all_ability > max_all then
            ref_cost = petinfo["4"].refresh_cost
            ref_rang = "Đã đạt giới hạn"
        elseif all_ability < min_all then
            ref_cost = petinfo["1"].refresh_cost
            ref_rang = "Đã tới mức sàn, xin tạo mới tiếp"
        end
    end
    local isInTeam = game_data:petInTeamById(cid)
    -- cclog2(isInTeam,"isInTeam  ====   ")
    if isInTeam ~= nil then
        self.m_explain_btn:setEnabled(not (isInTeam));
        -- self.m_explain_btn:
    end
	self.cost_label:setString(ref_cost);
	self.m_ref_add_label:setString(ref_rang);
end

--[[--
    刷新
]]
function game_pet_adduct_pop.refreshPetTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil
    self.m_tableView = self:createPetTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);

end

--[[--
    刷新战斗力
]]
function game_pet_adduct_pop.refreshCombatLabel(self)
    if self.m_tempCombatValue == nil then
        self.m_tempCombatValue = game_util:getCombatValue()
        self.m_combatNumberChangeNode:setCurValue(self.m_tempCombatValue,false);
    else
        local tempCombatValue = game_util:getCombatValue();
        local changeValue = tempCombatValue - self.m_tempCombatValue
        self.m_tempCombatValue = tempCombatValue;
        game_util:combatChangedValueAnim({combatNode = self.m_combatNumberChangeNode,currentValue = tempCombatValue,changeValue = changeValue});
    end
end

--[[--
    刷新ui
]]
function game_pet_adduct_pop.refreshUi(self)
    -- 宠物列表
    self:refreshPetTableView()
    -- 战斗力
    self:refreshCombatLabel()
    -- 宠物信息
    self:refreshPetInfo(self.m_cur_select_id);
   
end

--[[--
    初始化
]]
function game_pet_adduct_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_cur_select_id = t_params.pet_id or nil 
    self.m_selcet_index = nil                           -- 当前选中的宠物列表的index
    self.last_selecet = false;
    self.pet_follow = getConfig(game_config_field.pet_follow)
    self.pet_refresh = getConfig(game_config_field.pet_refresh)
end

--[[--
    创建ui入口并初始化数据
]]
function game_pet_adduct_pop.create(self,t_params)
    -- body
    -- game_data:addOneNewButtonByBtnID(503)   -- 已经了解了技能升级功能
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_pet_adduct_pop;