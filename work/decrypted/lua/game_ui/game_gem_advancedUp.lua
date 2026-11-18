--- 宝石进阶
local game_gem_advancedUp = {
    m_table_view = nil,
    m_sel_btn = nil,
    star_node = nil,

    m_ok_btn = nil,
    cur_property1 = nil,
    next_property1 = nil,
    cur_property2 = nil,
    next_property2 = nil,
    show_node = nil,

    m_select_id = nil,--选中的
    m_select_index = nil,
    m_selEquipDataTab = nil,
    last_m_sel_img = nil,
    table_view_node = nil,
    m_anim_node = nil,
    m_tips_spr_1 = nil,
    m_cost_metal = nil,
    m_btn_table = nil,
    m_advanced_btn = nil,
    m_gemData = nil,
    m_gemId = nil,
    m_idNumTab = nil,
    m_lvTab = nil,

    m_label_rate = nil,
    m_label_loseLv = nil,
    m_label_rate2 = nil,
    m_label_costMetal1 = nil,
    m_label_costMetal2 = nil,
    m_label_costItem1 = nil,
    m_label_costItem2 = nil,
    m_label_metal = nil,
    m_label_coreMetal = nil,

    m_cost_metal = nil,
    m_cost_core = nil,
    m_max_rate = nil,
    m_maxLv = nil,
    m_toIndex = nil,--进阶后需要跳转到的index
    m_sortType = nil,--排序类型
};
--[[--
    销毁ui
]]
function game_gem_advancedUp.destroy(self)
    -- body
    cclog("-----------------game_gem_advancedUp destroy-----------------");
    self.m_table_view = nil;
    self.m_sel_btn = nil;
    self.star_node = nil;
    self.m_ok_btn = nil;
    self.cur_property1 = nil;
    self.next_property1 = nil;
    self.cur_property2 = nil;
    self.next_property2 = nil;
    self.show_node = nil;
    self.m_select_id = nil;
    self.m_select_index = nil;
    self.m_selEquipDataTab = nil;
    self.last_m_sel_img = nil;
    self.table_view_node = nil;
    self.m_anim_node = nil;
    self.m_tips_spr_1 = nil;
    self.m_cost_core = nil;
    self.m_btn_table = nil;
    self.m_advanced_btn = nil;
    self.m_gemData = nil;
    self.m_gemId = nil;
    self.m_idNumTab = nil;
    self.m_lvTab = nil;

    self.m_label_rate = nil;
    self.m_label_loseLv = nil;
    self.m_label_rate2 = nil;
    self.m_label_costMetal1 = nil;
    self.m_label_costMetal2 = nil;
    self.m_label_costItem1 = nil;
    self.m_label_costItem2 = nil;
    self.m_label_metal = nil;
    self.m_label_coreMetal = nil;

    self.m_cost_metal = nil;
    self.m_cost_core = nil;
    self.m_max_rate = nil;
    self.m_maxLv = nil;
    self.m_toIndex = nil;
    self.m_sortType = nil;
end

--[[--
    返回
]]
function game_gem_advancedUp.back(self,backType)
    game_scene:enterGameUi("game_gem_advanced",{})
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_gem_advancedUp.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 101 or btnTag == 102 then--开始精炼
            self:onSureFunc(btnTag);
        elseif btnTag >= 201 and btnTag <= 202 then--排序
            cclog("btnTag === " .. btnTag)
            local index = btnTag - 200;
            for i=1,2 do
                self.m_btn_table[i]:setEnabled(true)
                self.m_btn_table[i]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_select.png"),CCControlStateNormal);
            end
            self.m_btn_table[index]:setEnabled(false)
            self.m_btn_table[index]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_selected.png"),CCControlStateDisabled);
            --切换table
            local typeTable = {"up","down",};
            self.m_sortType = typeTable[btnTag - 200]
            self:refreshUi();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_gem_system_advenced_pop.ccbi");
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    --装备相关
    self.table_view_node = ccbNode:nodeForName("table_view_node");
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn");
    self.star_node = ccbNode:nodeForName("star_node");
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn");
    self.cur_property1 = ccbNode:labelTTFForName("cur_property1");
    self.next_property1 = ccbNode:labelTTFForName("next_property1");
    self.cur_property2 = ccbNode:labelTTFForName("cur_property2");
    self.next_property2 = ccbNode:labelTTFForName("next_property2");
    self.show_node = ccbNode:nodeForName("show_node");
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")

    self.m_advanced_btn = ccbNode:controlButtonForName("m_advanced_btn");
    self.m_btn_table = {}
    for i=1,2 do
        self.m_btn_table[i] = ccbNode:controlButtonForName("m_table_tab_btn_"..i)
        self.m_btn_table[i]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_select.png"),CCControlStateNormal);
    end
    self.m_btn_table[1]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_selected.png"),CCControlStateNormal);
    
    self.m_tips_spr_1:runAction(game_util:createRepeatForeverFade())

    self.m_label_rate = ccbNode:labelTTFForName("m_label_rate")
    self.m_label_loseLv = ccbNode:labelTTFForName("m_label_loseLv")
    self.m_label_rate2 = ccbNode:labelTTFForName("m_label_rate2")
    self.m_label_costMetal1 = ccbNode:labelTTFForName("m_label_costMetal1")
    self.m_label_costMetal2 = ccbNode:labelTTFForName("m_label_costMetal2")
    self.m_label_costItem1 = ccbNode:labelTTFForName("m_label_costItem1")
    self.m_label_costItem2 = ccbNode:labelTTFForName("m_label_costItem2")
    self.m_label_metal = ccbNode:labelTTFForName("m_label_metal")
    self.m_label_coreMetal = ccbNode:labelTTFForName("m_label_coreMetal")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    return ccbNode;
end

--[[
    
]]
function game_gem_advancedUp.onSureFunc(self,btnTag)
    if self.m_select_index == nil then
        game_util:addMoveTips({text = "Chọn Đá Quý để tiến cấp"});
    else
        if self:getGemLvByIndex(self.m_select_index) == self.m_maxLv then
            game_util:addMoveTips({text = "Đá Quý đã đầy cấp!"});    
            return
        end
        local totalMetal = game_data:getUserStatusDataByKey("metal") or 0
        local totalMetalCore = game_data:getItemCountByCid("304") or 0

        local function sendHttpRequest()
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local success = data:getNodeWithKey("success"):toStr()
                local oldLv = self:getGemLvByIndex(self.m_select_index)
                local got_gem = data:getNodeWithKey("got_gem"):toStr()
                local curlv,_ = game_util:getRealGemLvAndCid(got_gem)
                if success == "true" then
                    game_util:addMoveTips({text = "Thành công!"});
                else
                    game_util:addMoveTips({text = "Thất bại!"});
                end
                self.m_toIndex  = self:getGemIndexByLv(tonumber(curlv)) + 1
                self.m_select_index = self.m_toIndex
                self:refreshUi(success)

            end
            local params = {};
            local gemlv = self:getGemLvByIndex(self.m_select_index)
            params.gem_id = self.m_gemId;
            if gemlv > 0 then
                params.gem_id = gemlv .. "-" .. self.m_gemId
            end
            if btnTag == 101 then
                params.super_evo = 0
            else
                params.super_evo = 1
            end
            params.user_token = game_data:getUserStatusDataByKey("uid")
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gem_evolution"), http_request_method.GET, params,"gem_evolution")
        end
        if self.m_cost_metal > totalMetal then--铁不足
            local t_params = 
            {
                m_openType = 6,
                m_call_func = function()
                    self:refreshUi()
                end
            }
            game_scene:addPop("game_normal_tips_pop",t_params)
        elseif (btnTag == 101 and self.m_cost_core > totalMetalCore) or (btnTag == 102 and self.m_max_rate > totalMetalCore) then--进阶道具不足
            game_util:addMoveTips({text = "Đạo cụ tiến cấp không đủ!"});
        else
            sendHttpRequest()
        end

    end
end
--[[--
    创建列表
]]
function game_gem_advancedUp.createGemTableView(self,viewSize)
    self.last_m_sel_img = nil;
    if self.m_sortType == "up" then
        table.sort(self.m_lvTab)
    elseif self.m_sortType == "down" then
        local function sortFunc( num1,num2 )
            return num1 > num2
        end
        table.sort( self.m_lvTab, sortFunc )
    end
    -- self.m_selEquipDataTab = game_data:getEquipIdTable();
    -- local idNumTab,lvTab = self:getGemNumAndLv()
    local gemCount1 = self.m_idNumTab[tostring(0)] or 0 --未进阶过的宝石数量
    local gemCount2 = game_util:getAllGemConunt(self.m_gemId)--进阶过的宝石数量
    local indexLv = 1 --当前index对应的宝石lv
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = gemCount1+gemCount2;
    params.itemActionFlag = true;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = game_util:createGemItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if self:getGemLvByIndex(index + 1) then
                local curGemLv = self:getGemLvByIndex(index + 1)
                local curGemLvCount = self.m_idNumTab[tostring(curGemLv)]
                
                local itemData,itemCfg = game_data:getGemDataById(self.m_gemId);
                game_util:setGemItemInfoByTable3(ccbNode,{count = 1,c_id = self.m_gemId,curGemLv = self:getGemLvByIndex(index + 1)});
                
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                if index + 1 == self.m_select_index then
                    m_sel_img:setVisible(true);
                    self.last_m_sel_img = m_sel_img
                else
                    m_sel_img:setVisible(false);
                end
                -- local advanced_node = ccbNode:nodeForName("advanced_node")
                
                -- if curGemLv > 0 then
                --     advanced_node:setVisible(true)
                --     local advanced_level = ccbNode:labelBMFontForName("advanced_level")
                --     advanced_level:setString(tostring(curGemLv))
                -- else
                --     advanced_node:setVisible(false)
                -- end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local m_sel_img = ccbNode:spriteForName("m_sel_img")
            -- local itemData,itemCfg = game_data:getGemDataById(self.m_gemId);
            if index + 1 ~= self.m_select_index then
                if self.last_m_sel_img then
                    self.last_m_sel_img:setVisible(false)
                end
                m_sel_img:setVisible(true)
                self.m_select_index = index + 1
                self.last_m_sel_img = m_sel_img
            else
                m_sel_img:setVisible(false)
                self.last_m_sel_img = nil
                self.m_select_index = nil
            end
            self:refreshTips()
        end
    end
    return TableViewHelper:create(params);
end

function game_gem_advancedUp.getCfgAbilityValue( self,itemCfg,ability )
    local abilityTab = itemCfg:getNodeWithKey("ability")
    abilityTab = json.decode(abilityTab:getFormatBuffer())
    -- cclog2(ability,"ability ==== ")
    local nextValue1,nextValue2 = 0,0
    for k,v in pairs(abilityTab) do
        if tonumber(v[1]) == tonumber(ability) then
            nextValue1 = v[2]
            if v[3] then
                nextValue2 = v[3]
            end
        end
    end
    return nextValue1,nextValue2
end
--[[
    设置精炼变化属性
]]
function game_gem_advancedUp.setPropertyChange(self,st_lv)
    local gemCfg = getConfig(game_config_field.gem)
    local myGemCfg = gemCfg:getNodeWithKey(tostring(self.m_gemId))
    local ability = myGemCfg:getNodeWithKey("ability"):toInt()
    local ability2 = 0
    if myGemCfg:getNodeWithKey("ability2") then
        ability2 = myGemCfg:getNodeWithKey("ability2"):toInt()
    end

    local gem_evo_cfg = getConfig(game_config_field.gem_evolution)
    local next_lv = st_lv + 1

    local show_now1,show_now2 = "",""
    local show_next1,show_next2 = "",""
    local cost_metal = 0
    local cost_core,max_rate = 0,0
    local rate = nil
    local false_back = nil

    local itemCfg = gem_evo_cfg:getNodeWithKey(tostring(st_lv))
    local nextCfg = gem_evo_cfg:getNodeWithKey(tostring(next_lv))
    if st_lv == 0 then
        show_now1 = "Thuộc tính hiện tại：Không có"
        show_now2 = "Thuộc tính hiện tại：Không có"
        rate = nextCfg:getNodeWithKey("rate"):toInt()--1
        false_back = 0;--2

        local nextValue1,nextValue2 = 0,0
        nextValue1,nextValue2 = self:getCfgAbilityValue(nextCfg,ability)
        local typeName = PUBLIC_ABILITY_TABLE["ability_" .. ability].name
        -- local next_type = pro_next:getNodeAt(0):toInt()
        -- local next_rate = pro_next:getNodeAt(1):toInt()
        --3
        show_next1 = "Thuộc tính LV sau:" .. typeName .. "+" .. nextValue1 
        show_next2 = "Thuộc tính LV sau:" .. "HP" .. "+" .. nextValue2 
        if nextValue2 == 0 then
            show_next2 = ""
        end

        cost_metal = nextCfg:getNodeWithKey("metal"):toInt()--消耗的铁
        cost_core = nextCfg:getNodeWithKey("gem_material")--消耗的进阶道具
        cost_core = json.decode(cost_core:getFormatBuffer())
        cost_core = cost_core[1][3]
        max_rate = nextCfg:getNodeWithKey("super_multiple")--消耗的进阶道具
        max_rate = max_rate and max_rate:toInt() or 0
    elseif st_lv == self.m_maxLv then
        show_next1 = "Thuộc tính LV sau：Không có"
        show_next2 = "Thuộc tính LV sau：Không có"
    else
        rate = nextCfg:getNodeWithKey("rate"):toInt()--概率
        false_back = nextCfg:getNodeWithKey("false_back"):toInt()--失败

        cost_metal = nextCfg:getNodeWithKey("metal"):toInt()--消耗的铁
        cost_core = nextCfg:getNodeWithKey("gem_material")--消耗的进阶道具
        cost_core = json.decode(cost_core:getFormatBuffer())
        cost_core = cost_core[1][3]
        max_rate = nextCfg:getNodeWithKey("super_multiple")--消耗的进阶道具
        max_rate = max_rate and max_rate:toInt() or 0
        local typeName = PUBLIC_ABILITY_TABLE["ability_" .. ability].name
        local nextValue1,nextValue2,curValue1,curValue2 = 0,0,0,0
        nextValue1,nextValue2 = self:getCfgAbilityValue(nextCfg,ability)
        curValue1,curValue2 = self:getCfgAbilityValue(itemCfg,ability)
        --增加的属性
        show_now1 = "Thuộc tính hiện tại:" .. typeName .. "+" .. curValue1
        show_next1 = "Thuộc tính LV sau:" .. typeName .. "+" .. nextValue1
        show_now2 = "Thuộc tính hiện tại:" .. "HP" .. "+" .. curValue2
        show_next2 = "Thuộc tính LV sau:" .. "HP" .. "+" .. nextValue2
        if curValue2 == 0 then
            show_now2 = ""
        end
        if nextValue2 == 0 then
            show_next2 = ""
        end

    end
    self.cur_property1:setString(show_now1)
    self.next_property1:setString(show_next1)
    self.cur_property2:setString(show_now2)
    self.next_property2:setString(show_next2)

    local totalMetal = game_data:getUserStatusDataByKey("metal") or 0
    local totalMetalCore = game_data:getItemCountByCid("304") or 0
    self.m_label_costMetal1:setString(tostring(cost_metal))
    self.m_label_costMetal2:setString(tostring(cost_metal))
    self.m_label_costItem1:setString(tostring(cost_core))
    self.m_label_costItem2:setString(tostring(cost_core * max_rate))

    self.m_cost_metal = cost_metal
    self.m_cost_core = cost_core
    self.m_max_rate = cost_core * max_rate

    game_util:setCostLable(self.m_label_costMetal1,cost_metal,totalMetal);
    game_util:setCostLable(self.m_label_costMetal2,cost_metal* max_rate,totalMetal);
    game_util:setCostLable(self.m_label_costItem1,cost_core,totalMetalCore);
    game_util:setCostLable(self.m_label_costItem2,cost_core * max_rate,totalMetalCore);

    if rate then
        if rate <= 40 then
            self.m_label_rate:setString("Tỉ lệ thấp")
            self.m_label_rate:setColor(ccc3(0,255,0))
        elseif rate >= 80 then
            self.m_label_rate:setString("Tỉ lệ cao")
            self.m_label_rate:setColor(ccc3(160,32,240))
        else
            self.m_label_rate:setString("Tỉ lệ vừa")
            self.m_label_rate:setColor(ccc3(0,0,255))
        end
    else
        self.m_label_rate:setString("Không có")
        self.m_label_rate:setColor(ccc3(0,255,0))
    end
    if false_back then
        self.m_label_loseLv:setString(tostring(false_back))
    else
        self.m_label_loseLv:setString("Không có")
    end
end
--[[
    设置月亮
]]
function game_gem_advancedUp.setMoonPos(self,index)
    self.star_node:removeAllChildrenWithCleanup(true)
    for i=1,10 do
        local star = nil
        if i < index + 1 then
            star = CCSprite:createWithSpriteFrameName("ui_gem_advenced_moon1.png");
        elseif i == index + 1 then
            star = CCSprite:createWithSpriteFrameName("ui_gem_advenced_moon1.png");
            star:runAction(game_util:createRepeatForeverFade());
        else
            star = CCSprite:createWithSpriteFrameName("ui_gem_advenced_moon2.png");
        end
        if star then
            -- cclog("star is exist----")
            star:setAnchorPoint(ccp(0.5,0.5))
            star:setPosition(ccp(20 * ( (i-1) % 5),32 - 20 * math.floor( (i-1) / 5)))
            self.star_node:addChild(star,10,i)
        end
    end
end
--[[
    按照选中的index 来返回宝石的级别
]]
function game_gem_advancedUp.getGemLvByIndex( self,index )
    local gemNum = 0
    for i=1,#self.m_lvTab do
        local lv = self.m_lvTab[i]
        gemNum = self.m_idNumTab[tostring(lv)] + gemNum
        if index <= gemNum then
            return lv
        end
    end

end

--[[
    按照选中的宝石级别，来确定该级别宝石所在的第一个index
]]
function game_gem_advancedUp.getGemIndexByLv(self, gemLv)
    local realGemid = self.m_gemId
    local curGemData = self:getCurGemData()
    if self.m_sortType == "down" then
        local maxGemlv = self.m_lvTab[1]
        realGemid = maxGemlv .. "-" .. realGemid
        local count = curGemData[tostring(realGemid)]
        if gemLv >= maxGemlv then
            return 0
        else
            local realGemid2 = gemLv .. "-" .. self.m_gemId
            if curGemData[tostring(realGemid2)] then 
            else
                return 0
            end

        end
        for i=gemLv,maxGemlv do
            if i < maxGemlv and i ~= gemLv then
                local realGemid2 = i .. "-" .. self.m_gemId
                local count2 = curGemData[tostring(realGemid2)] or 0
                count = count2 + count
            end
        end
        return count
    end
    local count = curGemData[tostring(realGemid)] or 0
    if gemLv <= 0 then
        return 0
    else
        local realGemid2 = gemLv .. "-" .. realGemid
        if curGemData[tostring(realGemid2)] then 
        else
            return 0
        end

    end
    for i=gemLv,0,-1 do
        if i > 0 and i ~= gemLv then
            local realGemid2 = i .. "-" .. realGemid
            local count2 = curGemData[tostring(realGemid2)] or 0
            count = count2 + count
        end
    end
    return count
end
--[[
    按等级处理宝石数据
]]
function game_gem_advancedUp.getGemNumAndLv( self,gemTab )
    local idNumTab = {} --key 是宝石的级别，value是对应的数量
    local lvTab = {}
    for k,num in pairs(gemTab) do
        local lv,gemId = game_util:getRealGemLvAndCid(k)
        idNumTab[tostring(lv)] = num
        table.insert(lvTab,tonumber(lv)) 
    end
    if self.m_sortType == "up" then
        table.sort(lvTab)
    elseif self.m_sortType == "down" then
        local function sortFunc( num1,num2 )
            return num1 > num2
        end
        table.sort( lvTab, sortFunc )
    end
    self.m_idNumTab = idNumTab
    self.m_lvTab = lvTab
    -- return idNumTab,lvTab
end
--[[--
    刷新列表
]]
function game_gem_advancedUp.refreshGemTableView(self, refreshUiFlag)
	
    self.table_view_node:removeAllChildrenWithCleanup(true);
    self.m_selEquipDataTab = game_data:getEquipIdTable();
    self.m_tableView = self:createGemTableView(self.table_view_node:getContentSize(),self.m_selEquipDataTab);
    self.table_view_node:addChild(self.m_tableView,10,10);
    if refreshUiFlag then
        if self.m_toIndex >= 5 then
            self.m_toIndex = self.m_toIndex - 1
        end
        game_util:setTableViewIndex(self.m_toIndex,self.table_view_node,10,5)
    end
end

function game_gem_advancedUp.getCurGemData( self )
	local curGemData = {}
	for k,v in pairs(game_data:getGemData()) do
		if tostring(k) == tostring(self.m_gemId) then
			curGemData[tostring(k)] = v
		elseif string.find(k,"-") then
			local result = util.stringSplit(k,"-")
        	if tostring(self.m_gemId) == tostring(result[2]) then
        		curGemData[tostring(k)] = v
        	end
		end
	end
    self:getGemNumAndLv(curGemData)
    return curGemData
end
--[[--
    刷新tips
]]
function game_gem_advancedUp.refreshTips(self)
    if self.m_select_index then
        self.show_node:setVisible(true)
        -- local itemData,itemCfg = game_data:getEquipDataById(tostring(self.m_select_id));
        -- local st_lv = itemData.st_lv
        -- local sort = itemCfg:getNodeWithKey("sort"):toInt()
        local lv = self:getGemLvByIndex(self.m_select_index)
        self:setMoonPos(lv)
        self:setPropertyChange(lv)

        -- self.show_node:setVisible(true)

        local ccbNode = game_util:createGemItemByCCB({c_id = self.m_gemId,count = 1,curGemLv = lv});
        -- cclog("itemData = " .. json.encode(itemData))
        self.m_anim_node:removeAllChildrenWithCleanup(true)
        self.m_anim_node:addChild(ccbNode,10,10);
        self.m_tips_spr_1:setVisible(false);
    else
        self.m_tips_spr_1:setVisible(true);
        self.m_anim_node:removeAllChildrenWithCleanup(true)
        self.show_node:setVisible(false)
    end
end
--[[--
    刷新ui
]]
function game_gem_advancedUp.refreshUi(self, refreshUiFlag)
    local curgemdata = self:getCurGemData()
    self:refreshGemTableView(refreshUiFlag)
    self:refreshTips()

    local totalMetal = game_data:getUserStatusDataByKey("metal") or 0
    local value,unit = game_util:formatValueToString(totalMetal);
    self.m_label_metal:setString(tostring(value .. unit));

    local totalMetalCore = game_data:getItemCountByCid("304") or 0
    local value2,unit2 = game_util:formatValueToString(totalMetalCore);
    self.m_label_coreMetal:setString(tostring(value2 .. unit2))
end
--[[--
    初始化
]]
function game_gem_advancedUp.init(self,t_params)
    t_params = t_params or {};
    self.m_select_id = nil;
    self.m_select_index = nil;
    self.last_m_sel_img = nil;
    self.m_idNumTab = {}
    self.m_lvTab = {}
    self.m_gemData = {}
    self.m_gemId = 0
    if t_params.gemId then
    	self.m_gemId = t_params.gemId
    end
    
    self.m_maxLv = 0
    local gemCfg = getConfig(game_config_field.gem)
    local myGemCfg = gemCfg:getNodeWithKey(tostring(self.m_gemId))
    self.m_maxLv = myGemCfg:getNodeWithKey("evo_max"):toInt()
    self.m_toIndex = 0
    self.m_sortType = "up"
end

--[[--
    创建ui入口并初始化数据
]]
function game_gem_advancedUp.create(self,t_params)
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end

return game_gem_advancedUp;
