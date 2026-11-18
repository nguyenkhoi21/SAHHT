--- 學校訓練選擇 

local game_school_new_select = {
    m_anim_node = nil,
    m_train_time_label = nil,
    m_train_multiple_label = nil,
    m_cost_food_label = nil,
    m_cost_money_label = nil,
    m_table_view = nil,
    m_btn_table = nil,

    m_time_index = nil,
    m_multiple_index = nil,

    m_selHeroId = nil,--訓練英雄的ID
    m_btn_table = nil,--切換排序
    m_posIndex = nil,--坑位
    m_last_select = nil,
    m_level_label_1 = nil,
    m_life_label_1 = nil,
    m_physical_atk_label_1 = nil,
    m_magic_atk_label_1 = nil,
    m_def_label_1 = nil,
    m_speed_label_1 = nil,
    m_guildNode = nil,
    btn_trans = nil,

    time_list = nil,
    rate_list = nil,
    time_need_list = nil,
    rate_need_list = nil,

    need_food = nil,
    need_dimond = nil,
    choose_index = nil,
};
--[[--
    銷毀ui
]]
function game_school_new_select.destroy(self)
    -- body
    cclog("-----------------game_school_new_select destroy-----------------");
    self.m_anim_node = nil;
    self.m_train_time_label = nil;
    self.m_train_multiple_label = nil;
    self.m_cost_food_label = nil;
    self.m_cost_money_label = nil;
    self.m_table_view = nil;
    self.m_btn_table = nil;

    self.m_time_index = nil;
    self.m_multiple_index = nil;
    self.m_selHeroId = nil;
    self.m_btn_table = nil;
    self.m_posIndex = nil;

    self.m_last_select = nil;
    self.m_level_label_1 = nil;
    self.m_life_label_1 = nil;
    self.m_physical_atk_label_1 = nil;
    self.m_magic_atk_label_1 = nil;
    self.m_def_label_1 = nil;
    self.m_speed_label_1 = nil;

    self.m_guildNode = nil;
    self.btn_trans = nil;

    self.time_list = nil;
    self.rate_list = nil;
    self.time_need_list = nil;
    self.rate_need_list = nil;

    self.need_food = nil;
    self.need_dimond = nil;
    self.choose_index = nil;
end
--[[--
    返回
]]
function game_school_new_select.back(self,backType)
    if backType == "back" then
        game_scene:enterGameUi("game_school_new",{gameData = nil});
        self:destroy();
    end
end
local multiple_times_table = {"100%","120%","150%","200%","300%"};
local train_time_table = {"01:00:00","02:00:00","04:00:00","08:00:00","12:00:00"}
--[[--
    讀取ccbi創建ui
]]
function game_school_new_select.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 105 then--返回
            self:back("back");
        elseif btnTag == 2 then--返回
            self:refreshByType(1);
        elseif btnTag == 101 then--開始訓練
            if self.m_selHeroId == nil then
                game_util:addMoveTips({text = "Hãy chọn thẻ bài huấn luyện!"});
                return;
            end
            local function responseMethod(tag,gameData)
                -- local id = game_guide_controller:getIdByTeam("4");
                -- if id == 45 then
                --     game_guide_controller:gameGuide("send","4",45);
                -- end
                -- cclog("gameData = " .. gameData:getNodeWithKey("data"):getFormatBuffer())
                game_scene:enterGameUi("game_school_new",{gameData = gameData,showType = 2,time_index = self.m_time_index,selHeroId = self.m_selHeroId,train_type = self.m_multiple_index});
                self:destroy();
            end
            -- stove_key=stove_1&train_type=1&train_time=1&card_id=2
            if self.need_food == true then
                --換成統一的提示
                local t_params = 
                {
                    m_openType = 5,
                    m_call_func = function()
                        self:refreshHeroInfo(self.m_selHeroId)
                    end
                }
                game_scene:addPop("game_normal_tips_pop",t_params)
            elseif self.need_dimond == true then
                --換成統一的提示
                local t_params = 
                {
                    m_openType = 4,
                }
                game_scene:addPop("game_normal_tips_pop",t_params)
            else
                local params = {};
                params.stove_key = self.m_posIndex;
                -- cclog("stove_key == " .. self.m_posIndex)
                params.train_type = self.m_multiple_index;
                params.train_time = self.m_time_index;
                params.card_id = self.m_selHeroId;
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_train"), http_request_method.GET, params,"school_train")
            end
        elseif btnTag == 201 then
            self:setTimeAndMultiple(-1,0)
        elseif btnTag == 202 then
            self:setTimeAndMultiple(1,0)
        elseif btnTag == 203 then
            self:setTimeAndMultiple(0,-1)
        elseif btnTag == 204 then
            self:setTimeAndMultiple(0,1)
        elseif btnTag > 300 and btnTag < 305 then
            self.choose_index = btnTag - 300;
            for i=1,4 do
                self.m_btn_table[i]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_select.png"),CCControlStateNormal);
            end
            self.m_btn_table[self.choose_index]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_selected.png"),CCControlStateNormal);
            --切換table
            local typeTable = {"default","quality","lv","profession",};
            game_data:cardsSortByTypeName3(typeTable[self.choose_index]);
            self:refreshUi();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);

    ccbNode:openCCBFile("ccb/ui_school_select_new.ccbi");

    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())

    self.m_anim_node = ccbNode:nodeForName("train_node");
    self.m_train_time_label = ccbNode:labelTTFForName("train_time_label");
    self.m_train_multiple_label = ccbNode:labelTTFForName("train_multiple_label");
    self.m_cost_food_label = ccbNode:labelBMFontForName("m_cost_food_label");
    self.m_cost_money_label = ccbNode:labelBMFontForName("m_cost_money_label");
    self.m_table_view = ccbNode:nodeForName("table_view_node");
    self.m_level_label_1 = ccbNode:labelTTFForName("m_level_label_1");
    self.m_life_label_1 = ccbNode:labelTTFForName("m_life_label_1");
    self.m_physical_atk_label_1 = ccbNode:labelTTFForName("m_physical_atk_label_1");
    self.m_magic_atk_label_1 = ccbNode:labelTTFForName("m_magic_atk_label_1");
    self.m_def_label_1 = ccbNode:labelTTFForName("m_def_label_1");
    self.m_speed_label_1 = ccbNode:labelTTFForName("m_speed_label_1");

    self.btn_trans = ccbNode:controlButtonForName("btn_trans")

    game_util:setControlButtonTitleBMFont(self.btn_trans)
    self.m_time_index = 1;
    self.m_multiple_index = 1;
    
    self:setTimeAndMultiple(0,0)

    self.m_btn_table = {}
    for i=1,4 do
        self.m_btn_table[i] = ccbNode:controlButtonForName("table_tab_btn_"..i)
        self.m_btn_table[i]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_select.png"),CCControlStateNormal);
    end
    self.m_btn_table[1]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_selected.png"),CCControlStateNormal);

    return ccbNode;
end
--[[
    設置時間和倍數
]]
function game_school_new_select.setTimeAndMultiple(self,index_1,index_2)
    -- cclog("self.m_multiple_index == " .. json.encode(self.rate_need_list))
    local character_train_time_config = getConfig("character_train_time");
    local character_train_rate_config = getConfig("character_train_rate");
    local cfgCount = character_train_time_config:getNodeCount()
    local vipLevel = game_data:getVipLevel()
    if self.m_time_index + index_1 <= cfgCount and self.m_time_index + index_1 > 0 then
        local time_need_vip = self.time_need_list[self.m_time_index+1]
        if index_1 > 0 then
            if vipLevel >= time_need_vip then
                self.m_time_index = self.m_time_index + index_1
            else
                game_util:addMoveTips{text = "Huấn luyện cao cấp cần tăng cấp VIP"}
            end
        else
            self.m_time_index = self.m_time_index + index_1
        end
    end
    if self.m_multiple_index + index_2 <= cfgCount and self.m_multiple_index + index_2 > 0 then
        local rate_need_vip = self.rate_need_list[self.m_multiple_index+1]
        if index_2 > 0 then
            if vipLevel >= rate_need_vip then
                self.m_multiple_index = self.m_multiple_index + index_2 
            else
                game_util:addMoveTips{text = "Huấn luyện cao cấp cần tăng cấp VIP"}
            end
        else
            self.m_multiple_index = self.m_multiple_index + index_2
        end
    end
    -- self.m_train_time_label:setString(train_time_table[self.m_time_index])
    -- self.m_train_multiple_label:setString(multiple_times_table[self.m_multiple_index])
    
    local itemTimeCfg = character_train_time_config:getNodeWithKey(tostring(self.m_time_index))
    local itemName = itemTimeCfg:getNodeWithKey("name"):toStr()
    self.m_train_time_label:setString(itemName)
    local itemRateCfg = character_train_rate_config:getNodeWithKey(tostring(self.m_multiple_index))
    local itemRate = itemRateCfg:getNodeWithKey("exp_rate"):toStr()
    self.m_train_multiple_label:setString(itemRate .. "%")

    if self.m_selHeroId ~= nil then
        self:refreshHeroInfo(self.m_selHeroId);
    end
end
--[[--
    刷新ui
]]
function game_school_new_select.createTimeList(self)
    
end
--[[--
    屬性英雄信息
]]
function game_school_new_select.refreshHeroInfo(self,heroId)
    self.m_selHeroId = heroId;
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    game_util:setCostLable(self.m_cost_food_label,0,0);
    game_util:setCostLable(self.m_cost_money_label,0,0);
    local character_train = getConfig("character_train");
    local character_train_time_config = getConfig("character_train_time");
    local character_train_rate_config = getConfig("character_train_rate");
    if heroId ~= nil and heroId ~= "-1" then
        local cardData,heroCfg = game_data:getCardDataById(tostring(heroId));
        local needFood = 0;
        local needGold = 0;
        local percent = 0;
        local time_need = 0;
        local trainItem = character_train:getNodeWithKey(tostring(cardData.star));
        local extra_food_rate = 0;
        local realNeedFood = 0;
        if trainItem then
            local money = trainItem:getNodeAt(cardData.quality);
            if money then
                needFood = money:toInt();
            end
        end
        realNeedFood = needFood;
        local typeItem = character_train_rate_config:getNodeWithKey(tostring(self.m_multiple_index));
        if typeItem then
            percent = typeItem:getNodeWithKey("exp_rate"):toInt();

            needGold = needGold + typeItem:getNodeWithKey("coin_cost"):toInt();
            extra_food_rate = typeItem:getNodeWithKey("extra_food_rate"):toInt();
            realNeedFood = realNeedFood + needFood * (extra_food_rate*0.01);--需要顯示的food數量
        end
        local timeItem = character_train_time_config:getNodeWithKey(tostring(self.m_time_index));
        
        if timeItem then
            time_need = timeItem:getNodeWithKey("time"):toInt()*60;
            needGold = needGold + timeItem:getNodeWithKey("coin_cost"):toInt();
            extra_food_rate = timeItem:getNodeWithKey("extra_food_rate"):toInt();
            realNeedFood = realNeedFood + needFood * (extra_food_rate*0.01);
        end
        
        local totalFood = game_data:getUserStatusDataByKey("food") or 0
        local totalGold = game_data:getUserStatusDataByKey("coin") or 0
        game_util:setCostLable(self.m_cost_food_label,realNeedFood,totalFood);
        game_util:setCostLable(self.m_cost_money_label,needGold,totalGold);
        if realNeedFood > totalFood then
            self.need_food = true
        else
            self.need_food = false
        end
        if needGold > totalGold then
            self.need_dimond = true
        else
            self.need_dimond = false
        end
        local ccbNode = game_util:createHeroListItemByCCB(cardData);
        ccbNode:setAnchorPoint(ccp(0.5,0.5));
        local itemSize = self.m_anim_node:getContentSize()
        ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
        self.m_anim_node:addChild(ccbNode,10,10);

        local building_base_school = getConfig("building_base_school");
        local level = game_data:getUserStatusDataByKey("level") or 1;
        local schoolItem = building_base_school:getNodeWithKey(tostring(level));
        local gainExp = 0;
        if schoolItem then
            local get_exp_min = schoolItem:getNodeWithKey("get_exp_min");
            if get_exp_min then
                gainExp = time_need*get_exp_min:toInt()*percent*0.01
            end
        end
        -- self.m_exp_label:setString("經驗：+" .. tostring(gainExp));
        -- cclog("cardData == " .. json.encode(cardData))
        local level_max = cardData.level_max
        local addLevel,percentage,addHp,addPatk,addMatk,addDen,addSpeed = self:getLevelUpValua(cardData.lv,cardData.exp + gainExp,cardData.c_id,level_max);
        local toLevel = cardData.lv + addLevel;
        cclog("addLevel == " .. addLevel)
        if addLevel > 0 and toLevel > cardData.lv then
            -- self.m_level_label:setString("等級：" .. cardData.lv .. " -> " .. toLevel);
            game_util:labelChangedRepeatForeverFade(self.m_level_label_1,cardData.lv,toLevel);

            game_util:labelChangedRepeatForeverFade(self.m_life_label_1,cardData.hp,cardData.hp + addHp);
            game_util:labelChangedRepeatForeverFade(self.m_physical_atk_label_1,cardData.patk,cardData.patk + addPatk);
            game_util:labelChangedRepeatForeverFade(self.m_magic_atk_label_1,cardData.matk,cardData.matk + addMatk);
            game_util:labelChangedRepeatForeverFade(self.m_def_label_1,cardData.def,cardData.def + addDen);
            game_util:labelChangedRepeatForeverFade(self.m_speed_label_1,cardData.speed,cardData.speed + addSpeed);
        else
            -- self.m_level_label:setString("等級：" .. cardData.lv);
            game_util:resetAttributeLable2(self.m_level_label_1);
            game_util:resetAttributeLable2(self.m_life_label_1);
            game_util:resetAttributeLable2(self.m_physical_atk_label_1);
            game_util:resetAttributeLable2(self.m_magic_atk_label_1);
            game_util:resetAttributeLable2(self.m_def_label_1);
            game_util:resetAttributeLable2(self.m_speed_label_1);

            self.m_level_label_1:setString(tostring(cardData.lv))

            self.m_life_label_1:setString(tostring(cardData.hp));
            self.m_physical_atk_label_1:setString(tostring(cardData.patk));
            self.m_magic_atk_label_1:setString(tostring(cardData.matk));
            self.m_def_label_1:setString(tostring(cardData.def));
            self.m_speed_label_1:setString(tostring(cardData.speed));
        end
    else
        -- self.m_exp_label:setString("經驗：+0");
        -- self.m_level_label:setString("");
        local typeItem = character_train_rate_config:getNodeWithKey(tostring(self.m_multiple_index));
        if typeItem then
            local percent = typeItem:getNodeWithKey("exp_rate"):toInt();
            -- game_util:setCCControlButtonTitle(self.m_type_btn,tostring(percent) .. "%")
        end
        local timeItem = character_train_time_config:getNodeWithKey(tostring(self.m_time_index));
        
        if timeItem then
            local time_need = timeItem:getNodeWithKey("time"):toInt()*3600;
            -- game_util:setCCControlButtonTitle(self.m_time_btn,game_util:formatTime(time_need));
        end
    end
    self:refreshTips();
end

--[[--
    
]]
function game_school_new_select.getLevelUpValua(self,currentLevel,totalExp,c_id,level_max)
    local character_base_cfg = getConfig(game_config_field.character_base);
    local character_base_item = nil;
    local addLevel = 0;
    local percentage = 0;
    local function checkValue()
        local character_base_item = character_base_cfg:getNodeWithKey(tostring(currentLevel + addLevel))
        if character_base_item then
            local maxExp = character_base_item:getNodeWithKey("exp"):toInt();
            if maxExp ~= 0 then
                if totalExp >= maxExp then
                    addLevel = addLevel + 1;
                    totalExp = totalExp - maxExp;
                    checkValue();
                else
                    percentage = 100*totalExp/maxExp
                end
            end
        end
    end
    checkValue();
    if addLevel + currentLevel > level_max then
        addLevel = level_max - currentLevel;
    end
    --成長值
    local character_detail = getConfig(game_config_field.character_detail);
    local item_detail = character_detail:getNodeWithKey(tostring(c_id));
    local addHpBase,addPatkBase,addMatkBase,addDenBase,addSpeedBase = item_detail:getNodeWithKey("growth_hp"):toInt(),item_detail:getNodeWithKey("growth_patk"):toInt(),item_detail:getNodeWithKey("growth_matk"):toInt(),item_detail:getNodeWithKey("growth_def"):toInt(),item_detail:getNodeWithKey("growth_speed"):toInt();
    local addHp,addPatk,addMatk,addDen,addSpeed = addHpBase * addLevel,addPatkBase * addLevel,addMatkBase * addLevel,addDenBase * addLevel,addSpeedBase * addLevel;

    return addLevel,percentage,addHp,addPatk,addMatk,addDen,addSpeed;
end
--[[--
    刷新
]]
function game_school_new_select.refreshByType(self,showType)
    
end

--[[--
    刷新按鈕狀態
]]
function game_school_new_select.refreshTips(self)
    
end
--[[
    創建英雄列表
]]--
function game_school_new_select.createTableView( self,viewSize )
    local typeTable = {"default","quality","lv","profession",};
    game_data:cardsSortByTypeName3(typeTable[self.choose_index or 1]);
    local cardsCount = game_data:getCardsCount();
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = cardsCount;
    params.direction = kCCScrollViewDirectionVertical;--縱向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
--[[
    cell
]]--
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_card_split_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local level_label = ccbNode:labelBMFontForName("m_level_label");
            local name_label = ccbNode:labelBMFontForName("m_name_label");
            local itemData,hero_config = game_data:getCardDataByIndex(index+1);
            --傳參：itemData.id
            local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
            local sprite_selected = ccbNode:spriteForName("sprite_selected");
            game_util:setHeroListItemInfoByTable2(ccbNode,itemData);

            if self.m_selHeroId == itemData.id then
                sprite_selected:setVisible(true);
                sprite_back_alpha:setVisible(true);
            else
                sprite_selected:setVisible(false);
                sprite_back_alpha:setVisible(false);
            end
            if self.m_guildNode == nil and index == 0 then
                cell:setContentSize(itemSize);
                self.m_guildNode = cell;
            end
        end
        return cell;
    end

    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
            local sprite_selected = ccbNode:spriteForName("sprite_selected");
            local itemData,hero_config = game_data:getCardDataByIndex(index+1);

            -- if self.m_last_select and self.m_last_select ~= item then
            --     local lastCcbNode = tolua.cast(self.m_last_select:getChildByTag(10),"luaCCBNode");
            --     local last_back_alpha = lastCcbNode:spriteForName("sprite_back_alpha");
            --     local last_selected = lastCcbNode:spriteForName("sprite_selected");
            --     last_selected:setVisible(false);
            --     last_back_alpha:setVisible(false);
            -- end
            local is_in_train = game_util:getCardTrainingFlag(itemData)
            if self.m_selHeroId ~= itemData.id then--排除訓練中和已選擇的
                if itemData.lv == itemData.level_max then
                    game_util:addMoveTips({text = "Đồng đội này đã đạt cấp tối đa, không cần huấn luyện"});
                else
                    if is_in_train == false then
                        self:refreshHeroInfo(itemData.id)
                        self:refreshUi();
                        -- sprite_selected:setVisible(true);
                        -- sprite_back_alpha:setVisible(true);
                    else
                        game_util:addMoveTips({text = "Đồng đội này đang huấn luyện!"});
                    end
                end
            end

            -- self.m_last_select = item;

            -- local id = game_guide_controller:getIdByTeam("4");
            -- if id == 45 then
            --     game_guide_controller:gameGuide("show","4",45,{tempNode = self.btn_trans})
            -- end

        end
    end
    return TableViewHelper:create(params);
end
--[[--
]]
function game_school_new_select.refreshCardTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
    -- local id = game_guide_controller:getIdByTeam("4");
    -- if id == 44 then
    --     self.m_tableView:setMoveFlag(false);
    --     game_guide_controller:gameGuide("show","4",45,{tempNode = self.m_guildNode})
    -- end
end

--[[--
    刷新ui
]]
function game_school_new_select.refreshUi(self)
    self.m_table_view:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_table_view:getContentSize());
    tableViewTemp:setScrollBarVisible(false);
    self.m_table_view:addChild(tableViewTemp);
    -- local id = game_guide_controller:getIdByTeam("4");
    -- if id == 44 then
    --     tableViewTemp:setMoveFlag(false);
    --     game_guide_controller:gameGuide("show","4",45,{tempNode = self.m_guildNode})
    -- end
end
--[[--
    初始化
]]
function game_school_new_select.init(self,t_params)
    t_params = t_params or {};

    self.m_posIndex = t_params.posIndex;
    self.rate_list = {}
    self.time_list = {}
    self.time_need_list = {}
    self.rate_need_list = {}
    local trainTimeCfg = getConfig(game_config_field.character_train_time)
    local trainRateCfg = getConfig(game_config_field.character_train_rate)
    for i=1,trainTimeCfg:getNodeCount() do
        local timeItemCfg = trainTimeCfg:getNodeWithKey(tostring(i))
        local time = timeItemCfg:getNodeWithKey("time"):toInt()
        local vipTime = timeItemCfg:getNodeWithKey("need_vip"):toInt()
        self.time_list[i] = time
        self.time_need_list[i] = vipTime

        local rateItemCfg = trainRateCfg:getNodeWithKey(tostring(i))
        local exp_rate = rateItemCfg:getNodeWithKey("exp_rate"):toInt()
        local vipRate = rateItemCfg:getNodeWithKey("need_vip"):toInt()

        self.rate_list[i] = exp_rate .. "%"
        self.rate_need_list[i] = vipRate
    end 

    self.need_food = false
    self.need_dimond = false
end

--[[--
    創建ui入口並初始化數據
]]
function game_school_new_select.create(self,t_params)
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end

return game_school_new_select;
