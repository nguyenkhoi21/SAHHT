--- game_normal_tips_pop信息
local game_normal_tips_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_itemId = nil,
    m_callBackFunc = nil,
    m_openType = nil,

    itemData = nil,
    hero_id = nil,
    m_tParams = nil,

    m_text_label = nil,
    m_func_btn = nil,
    hero_icon_node = nil,
    m_btn_1 = nil,
    m_btn_2 = nil,
    m_close_btn = nil,

    show_node_btn = nil,
    show_node_label = nil,
    is_max = nil,
    shopId = nil,
    left_value = nil,
    itemCount = nil,
    useId = nil,
    call_func = nil,
    m_ok_func = nil,
    add_call_func = nil,
    m_guildNode = nil,
};

--[[--
    銷毀
]]
function game_normal_tips_pop.destroy(self)
    cclog("-----------------game_normal_tips_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_itemId = nil;
    self.m_callBackFunc = nil;
    self.m_openType = nil;
    self.itemData = nil;
    self.hero_id = nil;
    self.m_tParams = nil;

    self.m_text_label = nil;
    self.m_func_btn = nil;
    self.hero_icon_node = nil;
    self.m_btn_2 = nil;
    self.m_close_btn = nil;

    self.show_node_btn = nil;
    self.show_node_label = nil;
    self.is_max = nil;
    self.shopId = nil;
    self.left_value = nil;

    self.itemCount = nil;
    self.useId = nil;
    self.call_func = nil;
    self.m_ok_func = nil;
    self.add_call_func = nil;
    self.m_guildNode = nil;
end
--[[--
    返回
]]

function game_normal_tips_pop.back(self,type)
    if self.call_func then
        self.call_func()
    end
    game_scene:removePopByName("game_normal_tips_pop");
end

--[[
    買東西的接口
]]
function game_normal_tips_pop.buyItem(self,buyType,item_id)
    item_id = self.useId or nil
    buyType = buyType or 1 --type 是2的買完之後用掉
    --買東西
    local function responseMethod(tag,gameData)
        game_data_statistics:buyItem({shopId = self.shopId,count = 1})
        local data = gameData:getNodeWithKey("data");
        game_data:setShopData(self.shopId,data:getNodeWithKey("bought"):toInt())
        if buyType == 1 then
            game_util:rewardTipsByJsonData(data:getNodeWithKey("goods"));
        else
            --用掉   item id 和 shop id 不是同一個
            local function responseMethod(tag,gameData)
                local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(item_id));
                local itemName = config_date:getNodeWithKey("name"):toStr();
                local rewardCount = game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("effect"));
                if rewardCount and rewardCount == 0 then
                    game_util:addMoveTips({text = tostring(itemName) .. "Dùng thành công!"});
                end
            end
            if item_id then
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_use"), http_request_method.GET, {item_id = item_id,num = 1},"item_use")
            end
        end
        --關閉彈板
        self:back()
    end
    local params = {};
    params.shop_id = self.shopId
    params.count = 1;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("shop_buy"), http_request_method.GET, params,"shop_buy")
end
function game_normal_tips_pop.changeUI(self,tag)
    if tag == "game_offer" then--懸賞
        
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_offer",{gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()),openType = 2})
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_index"), http_request_method.GET, {},"reward_index");  
    elseif tag == "game_card_split_shop" then--塵商店
        if not game_button_open:checkButtonOpen(507) then
            return;
        end
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_card_split_shop",{gameData = gameData,openType = self.m_openType})
            self:destroy()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_open_dirt_shop"), http_request_method.GET, nil,"cards_open_dirt_shop")
    elseif tag == "game_school_new" then--訓練
        if not game_button_open:checkButtonOpen(501) then
            return;
        end
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_school_new",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_open"), http_request_method.GET, nil,"school_open")
    elseif tag == "map_world_scene" then--出戰
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("map_world_scene",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
    elseif tag == "game_hero_list" then--查看夥伴
        game_scene:enterGameUi("game_hero_list",{gameData = nil});
        self:destroy();
    elseif tag == "game_card_split" then--卡牌分解
        if not game_button_open:checkButtonOpen(507) then
            return;
        end
        game_scene:enterGameUi("game_card_split");
        self:destroy();
    elseif tag == "equipment_list" then--查看裝備
        if not game_button_open:checkButtonOpen(601) then
            return;
        end
        game_scene:enterGameUi("equipment_list",{gameData = nil,openType = "game_function_pop",showIndex = 2});
        self:destroy();
    elseif tag == "ui_vip_show_gift_pop" then
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            game_scene:addPop("ui_vip_show_gift_pop",{gameData = json.decode(data:getNodeWithKey("vip_bought"):getFormatBuffer()),openType = 2})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("shop_open"), http_request_method.GET, {},"shop_open")
    elseif tag == "ui_vip" then--充值
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("ui_vip",{gameData = gameData});
            --game_scene:addPop("ui_vip_show_pop");
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
    elseif tag == "skills_strengthen_scene" then--技能升級
        game_scene:enterGameUi("skills_strengthen_scene",{gameData = nil});
        self:destroy();
    end
end
--[[--
    讀取ccbi創建ui
]]
function game_normal_tips_pop.createUi(self)
    local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(self.m_itemId));
    local ccbNode = luaCCBNode:create();

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 11 then
            self.m_tParams.okBtnCallBack()
        elseif btnTag == 12 then
            self:back()
        elseif btnTag == 101 then--跳轉1
            if self.m_openType == 13 then--懸賞
                self:changeUI("game_offer")
            elseif self.m_openType == 12 or self.m_openType == 8 then--塵商店
                self:changeUI("game_card_split_shop")
            elseif self.m_openType == 16 then--訓練
                self:changeUI("game_school_new")
            elseif self.m_openType == 14 then--出戰
                self:changeUI("map_world_scene")
            elseif self.m_openType == 1 then--查看夥伴
                -- self:changeUI("game_hero_list")
                --到技能升級
                self:changeUI("skills_strengthen_scene")
            elseif self.m_openType == 4 then--充值
                self:changeUI("ui_vip")
            elseif self.m_openType == 5 then--出戰
                self:changeUI("map_world_scene")
            elseif self.m_openType == 3 then--使用藥劑 增加體力
                local errorCfg = getConfig(game_config_field.error_cfg)
                local itemCfg = errorCfg:getNodeWithKey(tostring("error_" .. self.m_openType))
                local btnCfg = itemCfg:getNodeWithKey("button1"):getNodeAt(1)
                local item_id = nil;
                for i=1,btnCfg:getNodeCount() do
                    local itemId = btnCfg:getNodeAt(i-1):toInt()
                    local count = game_data:getItemCountByCid(tostring(itemId))
                    if count > 0 then
                        item_id = itemId
                        break;
                    end
                end
                local function responseMethod(tag,gameData)
                    local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(item_id));
                    local itemName = config_date:getNodeWithKey("name"):toStr();
                    local rewardCount = game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("effect"));
                    if rewardCount and rewardCount == 0 then
                        game_util:addMoveTips({text = tostring(itemName) .. "Dùng thành công!"});
                    end
                    self.itemCount = self.itemCount - 1
                    self.left_value:setString("Còn lại:"..self.itemCount)
                    self:back()
                end
                if item_id then
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_use"), http_request_method.GET, {item_id = item_id,num = 1},"item_use")
                else
                    game_util:addMoveTips({text = "Thuốc không đủ"});
                end
            elseif self.m_openType == 2 then--查看裝備
                self:changeUI("equipment_list")
            elseif self.m_openType == 6 then--購買金屬
                if self.is_max == true then
                    game_util:addMoveTips({text = "Số lần mua đã đạt giới hạn"})
                else
                    self:buyItem()
                end
            elseif self.m_openType == 9 then--使用挑戰書
                local errorCfg = getConfig(game_config_field.error_cfg)
                local itemCfg = errorCfg:getNodeWithKey(tostring("error_" .. self.m_openType))
                local item_id = itemCfg:getNodeWithKey("button1"):getNodeAt(1):toInt()
                local function responseMethod(tag,gameData)
                    local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(item_id));
                    local itemName = config_date:getNodeWithKey("name"):toStr();
                    local rewardCount = game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("effect"));
                    if rewardCount and rewardCount == 0 then
                        game_util:addMoveTips({text = tostring(itemName) .. "Dùng thành công!"});
                    end
                    self.itemCount = self.itemCount - 1
                    self.left_value:setString("Còn lại:"..self.itemCount)
                    self.add_call_func()
                    self:back()
                end
                if self.itemCount > 0 then
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_use"), http_request_method.GET, {item_id = item_id,num = 1},"item_use")
                else
                    game_util:addMoveTips({text = "Thuốc thư khiêu chiến lôi đài"});
                end
            elseif self.m_openType == 10 then--購買活動次數
                self.m_ok_func()
            elseif self.m_openType == 15 then--戰旗不足
                function shopOpenResponseMethod(tag,gameData)
                    game_scene:enterGameUi("game_buy_item_scene",{gameData = gameData});
                    self:destroy();
                end
                network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("shop_open"), http_request_method.GET, {},"shop_open")
            elseif self.m_openType == 17 then--使用精力道具
                local errorCfg = getConfig(game_config_field.error_cfg)
                local itemCfg = errorCfg:getNodeWithKey(tostring("error_" .. self.m_openType))
                local item_id = itemCfg:getNodeWithKey("button1"):getNodeAt(1):toInt()

                local function responseMethod(tag,gameData)
                    local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(item_id));
                    local itemName = config_date:getNodeWithKey("name"):toStr();
                    local rewardCount = game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("effect"));
                    if rewardCount and rewardCount == 0 then
                        game_util:addMoveTips({text = tostring(itemName) .. "Dùng thành công!"});
                    end
                    self.itemCount = self.itemCount - 1
                    self.m_ok_func()
                    self:back()
                end
                if self.itemCount > 0 then
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_use"), http_request_method.GET, {item_id = item_id,num = 1},"item_use")
                else
                    game_util:addMoveTips({text = "Thuốc tinh lực không đủ"});
                end
            elseif self.m_openType == 18 then--夥伴分解
                self:changeUI("game_card_split")
            elseif self.m_openType == 19 then--夥伴分解
                self:changeUI("game_card_split")
            elseif self.m_openType == 20 then--裝備拆分
                --裝備分解
                if not game_button_open:checkButtonOpen(607) then
                    return
                end
                game_scene:enterGameUi("ui_equip_split");
                self:destroy();
            end
        elseif btnTag == 102 then--跳轉2
            if self.m_openType == 16 then--出戰
                self:changeUI("map_world_scene")
            elseif self.m_openType == 1 then--分解
                self:changeUI("game_card_split")
            elseif self.m_openType == 8 then--競技場商店
                if not game_button_open:checkButtonOpen(200) then
                return;
                end
                local function responseMethod(tag,gameData)
                    local m_game_data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                    game_scene:enterGameUi("game_arena_shop",{m_gameData = m_game_data.exchange_log,point = m_game_data.point})
                    self:destroy();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_index"), http_request_method.GET, {},"arena_index");
            elseif self.m_openType == 5 then--查看夥伴    ------改   技能升級
                self:changeUI("game_hero_list")
                -- self:changeUI("skills_strengthen_scene")

            elseif self.m_openType == 3 then--鑽石買體力
                local buyTimes = game_data:getBuyActionTimes()
                local PayCfg = getConfig(game_config_field.pay):getNodeWithKey("2"):getNodeWithKey("coin")
                local vipLevel = game_data:getVipLevel()
                local buyLimit = getConfig(game_config_field.vip):getNodeWithKey(tostring(vipLevel)):getNodeWithKey("buy_point"):toInt()
            
                if buyTimes < buyLimit then
                if game_data:getActionPointValue() >= 150 then
                    game_util:addMoveTips({text = "Thể lực hiện tại đã đầy!"})
                    else
                        local payValue = 0
                        if buyTimes >= PayCfg:getNodeCount() then
                            payValue = PayCfg:getNodeAt(PayCfg:getNodeCount()-1):toInt()
                        else
                            payValue = PayCfg:getNodeAt(buyTimes):toInt()
                        end
                        local function responseMethod(tag,gameData)
                            local data = gameData:getNodeWithKey("data")
                            local buy_ap_times = data:getNodeWithKey("buy_ap_times"):toInt()
                            game_util:addMoveTips({text = "Mua thể lực thành công~"})
                            game_data:setBuyActionTimes(buy_ap_times)
                            game_util:closeAlertView();
                            self:back()
                        end
                        local t_params = 
                        {
                            title = string_config.m_title_prompt,
                            okBtnCallBack = function(target,event)
                                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("buy_point"), http_request_method.GET, nil,"buy_point")
                            end,   --可缺省
                            okBtnText = string_config.m_btn_sure,       --可缺省
                            cancelBtnText = string_config.m_btn_cancel,
                            text = "Xác định dùng" .. payValue .. " Xu mua thể lực？",      --可缺省
                            onlyOneBtn = false,
                            touchPriority = GLOBAL_TOUCH_PRIORITY-20,
                        }
                        game_util:openAlertView(t_params)
                    end
                else
                    game_util:addMoveTips({text = "Số lần mua thể lực đã dùng hết~"})                
                end
            elseif self.m_openType == 2 then--購買背包  買完之後用掉
                --裝備分解
                if not game_button_open:checkButtonOpen(607) then
                    return
                end
                game_scene:enterGameUi("ui_equip_split");
                self:destroy();
            elseif self.m_openType == 9 then--購買競技場次數
                self.m_ok_func()
            elseif self.m_openType == 17 then--鑽石購買精力
                if self.is_max == true then
                    game_util:addMoveTips({text = "Số lần mua đã đạt giới hạn"})
                else
                    local function responseMethod(tag,gameData)
                        local data = gameData:getNodeWithKey("data")
                        game_util:addMoveTips({text = "Mua tinh lực thành công~"})
                        self.m_ok_func()
                        self:back()
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("buy_cmdr_energy"), http_request_method.GET, nil,"buy_cmdr_energy")
                end
            end
        elseif btnTag == 103 then--跳轉3
            if self.m_openType == 8 then
                if self.is_max == true then--買能晶
                    game_util:addMoveTips({text = "Số lần mua đã đạt giới hạn"})
                else
                    self:buyItem()
                end
            elseif self.m_openType == 1 then
                if self.is_max == true then
                    game_util:addMoveTips({text = "Số lần mua đã đạt giới hạn"})
                else
                    self:buyItem(2)
                end
            elseif self.m_openType == 5 then--買食物
                if self.is_max == true then
                    game_util:addMoveTips({text = "Số lần mua đã đạt giới hạn"})
                else
                    self:buyItem()
                end
            elseif self.m_openType == 4 then
                -- self:changeUI("ui_vip_show_gift_pop")
            elseif self.m_openType == 2 then
                if self.is_max == true then
                    game_util:addMoveTips({text = "Số lần mua đã đạt giới hạn"})
                else
                    self:buyItem(2)
                end
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_wanning_buy_pop.ccbi");
    
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_text_label = ccbNode:labelTTFForName("m_text_label")

    self.hero_icon_node = ccbNode:nodeForName("hero_icon_node")
    self.m_btn_2 = ccbNode:controlButtonForName("m_btn_2")
    self.image_sprite = ccbNode:spriteForName("image_sprite")
    self.tips_sprite = ccbNode:spriteForName("tips_sprite")

    self.show_node_btn = ccbNode:nodeForName("show_node_btn")
    self.show_node_label = ccbNode:nodeForName("show_node_label")
    self.left_value = ccbNode:labelTTFForName("left_value")
    self.dimond_sprite = ccbNode:spriteForName("dimond_sprite")
    self.dimond_value = ccbNode:labelTTFForName("dimond_value")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")

    self.dimond_sprite:setVisible(false)
    self.left_value:setVisible(false)

    self.m_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);

    self.m_func_btn = {}
    
    local errorCfg = getConfig(game_config_field.error_cfg)
    local itemCfg = errorCfg:getNodeWithKey(tostring("error_" .. self.m_openType))
    --提示文字
    local errorText = itemCfg:getNodeWithKey("error_info"):toStr()
    --提示示意圖
    local imgName = itemCfg:getNodeWithKey("image"):toStr()
    local tempSpr = CCSprite:create(tostring("ccbResources/"..imgName..".png"));
    if errorText then
        self.m_text_label:setString(errorText)
    end
    if tempSpr then  
        self.image_sprite:setDisplayFrame(tempSpr:displayFrame())
    end
    --title圖片
    local tipImgName = itemCfg:getNodeWithKey("title"):toStr() .. ".png"
    local tipSpr = CCSprite:createWithSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(tipImgName)))
    if tipSpr then
        self.tips_sprite:setDisplayFrame(tipSpr:displayFrame())
    end

    -- local btn_count = 1
    for i=1,3 do
        self.m_func_btn[i] = ccbNode:controlButtonForName("m_func_btn_" .. i)
        self.m_func_btn[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    end

    if self.m_openType == 1 then --夥伴滿          √√√
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"mbutton_2_2.png")
        game_util:setCCControlButtonBackground(self.m_func_btn[2],"mbutton_5_4.png")
        game_util:setCCControlButtonBackground(self.m_func_btn[3],"btn_add_bag.png")
        local id = game_guide_controller:getIdByTeam("6");
        if id == 601 and self.m_guildNode == nil then
            self.m_guildNode = self.m_func_btn[1]
        end

        self.dimond_sprite:setVisible(true)
        self.dimond_sprite:setPosition(ccp(144,52))
        --設置購買所需鑽石  
        local shopId = itemCfg:getNodeWithKey("button1"):getNodeAt(1):toInt()
        self.shopId = shopId
        local dimond,is_max = self:getNeedDimond(shopId)
        self.is_max = is_max
        self.dimond_value:setString(tostring(dimond))

        --根據shopId 找到 itemId
        local useCfg = getConfig(game_config_field.shop)
        local myItemId = useCfg:getNodeWithKey(tostring(shopId)):getNodeWithKey("shop_reward"):getNodeAt(0):getNodeAt(1):toInt()
        self.useId = myItemId
    elseif self.m_openType == 2 then --裝備滿              √√√
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"mbutton_3_4.png")
        game_util:setCCControlButtonBackground(self.m_func_btn[2],"mbutton_2_split.png")--新增裝備分解
        game_util:setCCControlButtonBackground(self.m_func_btn[3],"btn_add_bag.png")
        -- self:setBtnPos(2)

        self.dimond_sprite:setVisible(true)
        self.dimond_sprite:setPosition(ccp(144,52))
        local shopId = itemCfg:getNodeWithKey("button1"):getNodeAt(1):toInt()

        --根據shopId 找到 itemId
        local useCfg = getConfig(game_config_field.shop)
        local myItemId = useCfg:getNodeWithKey(tostring(shopId)):getNodeWithKey("shop_reward"):getNodeAt(0):getNodeAt(1):toInt()
        self.useId = myItemId
        self.shopId = shopId
        local dimond,is_max = self:getNeedDimond(shopId)
        self.is_max = is_max
        self.dimond_value:setString(tostring(dimond))
    elseif self.m_openType == 3 then --行動力不足            √√√√
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"btn_use_item.png")
        game_util:setCCControlButtonBackground(self.m_func_btn[2],"btn_buy.png")
        self:setBtnPos(2)
        self.left_value:setVisible(true)
        self.dimond_sprite:setVisible(true)
        self.left_value:setPosition(ccp(-1,52))
        self.dimond_sprite:setPosition(ccp(114,52))
        local btnCfg = itemCfg:getNodeWithKey("button1"):getNodeAt(1)
        local itemCount = 0
        for i=1,btnCfg:getNodeCount() do
            local itemId = btnCfg:getNodeAt(i-1):toInt()
            local count = game_data:getItemCountByCid(tostring(itemId))
            itemCount = count + itemCount
        end
        self.itemCount = itemCount
        self.left_value:setString("Còn lại:"..self.itemCount)

        local buyTimes = game_data:getBuyActionTimes()
        local PayCfg = getConfig(game_config_field.pay):getNodeWithKey("2"):getNodeWithKey("coin")
        local vipLevel = game_data:getVipLevel()
        local buyLimit = getConfig(game_config_field.vip):getNodeWithKey(tostring(vipLevel)):getNodeWithKey("buy_point"):toInt()

        local payValue = 0
        if buyTimes >= PayCfg:getNodeCount() then
            payValue = PayCfg:getNodeAt(PayCfg:getNodeCount()-1):toInt()
        else
            payValue = PayCfg:getNodeAt(buyTimes):toInt()
        end
        self.dimond_value:setString(tostring(payValue))
    elseif self.m_openType == 4 then --鑽石不足         √√√
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"mbutton_6_2.png")
        -- game_util:setCCControlButtonBackground(self.m_func_btn[2],"btn_vip_power.png")
        -- game_util:setCCControlButtonBackground(self.m_func_btn[3],"mbutton_m_gift2.png")
        self:setBtnPos(1)
    elseif self.m_openType == 5 then --食物不足       √√√
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"btn_play.png")
        game_util:setCCControlButtonBackground(self.m_func_btn[2],"mbutton_2_5.png")
        game_util:setCCControlButtonBackground(self.m_func_btn[3],"btn_buy.png")
        self.dimond_sprite:setVisible(true)
        self.dimond_sprite:setPosition(ccp(144,52))

        local shopId = itemCfg:getNodeWithKey("button3"):getNodeAt(1):toInt()
        self.shopId = shopId
        cclog2(shopId,"==================shopIdzzzzzzzz===========")
        local dimond,is_max = self:getNeedDimond(shopId)
        self.is_max = is_max
        self.dimond_value:setString(tostring(dimond))
    elseif self.m_openType == 6 then --金屬不足     √√√√
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"btn_buy.png")
        self:setBtnPos(1)

        self.dimond_sprite:setVisible(true)
        self.dimond_sprite:setPosition(ccp(66,52))

        local shopId = itemCfg:getNodeWithKey("button3"):getNodeAt(1):toInt()
        self.shopId = shopId
        local dimond,is_max = self:getNeedDimond(shopId)
        self.is_max = is_max
        self.dimond_value:setString(tostring(dimond))
    elseif self.m_openType == 7 then --能源不足     

    elseif self.m_openType == 8 then --能晶不足     √√√
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"mbutton_5_3.png")
        game_util:setCCControlButtonBackground(self.m_func_btn[2],"btn_honor.png")
        game_util:setCCControlButtonBackground(self.m_func_btn[3],"btn_buy.png")
        self.dimond_sprite:setVisible(true)
        self.dimond_sprite:setPosition(ccp(144,52))
        --設置購買所需鑽石  
        local shopId = itemCfg:getNodeWithKey("button3"):getNodeAt(1):toInt()
        self.shopId = shopId
        local dimond,is_max = self:getNeedDimond(shopId)
        self.is_max = is_max
        self.dimond_value:setString(tostring(dimond))
    elseif self.m_openType == 9 then --競技場不足   √√√
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"btn_use_book.png")
        game_util:setCCControlButtonBackground(self.m_func_btn[2],"btn_buy.png")
        self:setBtnPos(2)

        self.left_value:setVisible(true)
        self.dimond_sprite:setVisible(true)
        self.left_value:setPosition(ccp(-1,52))
        self.dimond_sprite:setPosition(ccp(114,52))

        local itemId = itemCfg:getNodeWithKey("button1"):getNodeAt(1):toInt()
        local count = game_data:getItemCountByCid(tostring(itemId))
        self.itemCount = count
        self.left_value:setString("Còn lại:"..self.itemCount)

        self.dimond_value:setString(tostring(self.coin))
    elseif self.m_openType == 10 then --活動次數不足      √√√
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"btn_buy.png")
        self:setBtnPos(1)

        self.dimond_sprite:setVisible(true)
        self.dimond_value:setString(tostring(self.coin))
        self.dimond_sprite:setPosition(ccp(66,52))
    elseif self.m_openType == 11 then --技能滿級      

    elseif self.m_openType == 12 then --星靈不足     √√√
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"mbutton_5_3.png")
        self:setBtnPos(1)
    elseif self.m_openType == 13 then --金幣不足    √√√
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"btn_wanted.png")
        self:setBtnPos(1)
    elseif self.m_openType == 14 then --等級不足    英雄等級    
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"btn_play.png")
        self:setBtnPos(1)
    elseif self.m_openType == 15 then --戰旗不足    
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"mbutton_5_2.png")
        self:setBtnPos(1)
    elseif self.m_openType == 16 then --卡牌等級不足  
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"mbutton_2_1.png")
        game_util:setCCControlButtonBackground(self.m_func_btn[2],"btn_play.png")
        self:setBtnPos(2)
    elseif self.m_openType == 17 then --精力不足
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"btn_use_yaoji.png")
        game_util:setCCControlButtonBackground(self.m_func_btn[2],"btn_buy.png")
        self:setBtnPos(2)

        local itemId = itemCfg:getNodeWithKey("button1"):getNodeAt(1):toInt()
        local count = game_data:getItemCountByCid(tostring(itemId))
        self.itemCount = count
        self.left_value:setVisible(true)
        self.left_value:setPosition(ccp(-1,52))
        self.left_value:setString("Còn lại:"..self.itemCount)

        self.dimond_sprite:setVisible(true)
        self.dimond_sprite:setPosition(ccp(114,52))
        local buyTimes = self.time
        local PayCfg = getConfig(game_config_field.pay):getNodeWithKey("12"):getNodeWithKey("coin")

        local payValue = 0
        if buyTimes >= PayCfg:getNodeCount() then
            payValue = PayCfg:getNodeAt(PayCfg:getNodeCount()-1):toInt()
        else
            payValue = PayCfg:getNodeAt(buyTimes):toInt()
        end
        self.dimond_value:setString(tostring(payValue))
    elseif self.m_openType == 18 then --超能之塵不足
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"mbutton_5_4.png")
        self:setBtnPos(1)
    elseif self.m_openType == 19 then --強能之塵不足
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"mbutton_5_4.png")
        self:setBtnPos(1)
    elseif self.m_openType == 20 then --精煉石
        game_util:setCCControlButtonBackground(self.m_func_btn[1],"mbutton_2_split.png")
        self:setBtnPos(1)
    end

    game_util:setControlButtonTitleBMFont(self.m_func_btn_1)
    game_util:setControlButtonTitleBMFont(self.m_func_btn_2)
    game_util:setControlButtonTitleBMFont(self.m_btn_2)

    local function onTouch( eventType,x,y )
        if(eventType == "began")then
            return true;
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    self.m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
function game_normal_tips_pop.setBtnPos(self,btnCount)
    if btnCount == 1 then
        self.m_func_btn[1]:setPosition(ccp(63,21));
        self.m_func_btn[2]:setVisible(false)
        self.m_func_btn[3]:setVisible(false)
    elseif btnCount == 2 then
        self.m_func_btn[1]:setPosition(ccp(15,21));
        self.m_func_btn[2]:setPosition(ccp(111,21));
        self.m_func_btn[3]:setVisible(false)
    elseif btnCount == 3 then
        
    end
end
--[[
    得到花多少鑽石來買
    返回當年買需要多少鑽石 和 是否達到最大購買的
]]
function game_normal_tips_pop.getNeedDimond(self,shopId)
    local shopInfo = game_data:getShopData()
    local buyInfo = shopInfo["items"]
    -- cclog("shopId = " .. shopId)
    -- cclog("buyInfo = " .. json.encode(buyInfo))
    local itemInfo = buyInfo[tostring(shopId)]
    local buy_limit = itemInfo.sell_max
    local bought = itemInfo.bought + 1
    local need_value = itemInfo.need_value

    local is_max = false
    if bought > #need_value then
        bought = #need_value
    end
    if bought == buy_limit then
        is_max = true
    end

    local dimond = need_value[bought]
    return dimond,is_max
end
--[[--
    刷新ui
]]
function game_normal_tips_pop.refreshUi(self)

end
--[[--
    初始化
]]
function game_normal_tips_pop.init(self,t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_main_new_res.plist");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_all_tips.plist");
    t_params = t_params or {};
    self.m_tParams = t_params;

    self.hero_id = t_params.hero_id
    self.m_openType = t_params.m_openType
    self.call_func = t_params.m_call_func or nil
    self.m_ok_func = t_params.m_ok_func or nil
    self.time = t_params.time or nil
    self.coin = t_params.coin or nil
    self.add_call_func = t_params.add_call_func or nil
end

--[[--
    創建ui入口並初始化數據
]]
function game_normal_tips_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    if self.m_guildNode then
        game_guide_controller:gameGuide("show","6",601,{tempNode = self.m_guildNode})
    end
    return self.m_popUi;
end

return game_normal_tips_pop;