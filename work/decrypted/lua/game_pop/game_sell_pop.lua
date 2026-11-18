--- 一鍵出售

local game_sell_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    m_title_label = nil,
    m_sell_btn_1 = nil,
    m_sell_btn_2 = nil,
    m_sell_btn_3 = nil,
    m_tips_label_1 = nil,
    m_tips_label_2 = nil,
    m_tips_label_3 = nil,
    m_tParams = nil,
};
--[[--
    銷毀
]]
function game_sell_pop.destroy(self)
    -- body
    cclog("-----------------game_sell_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_title_label = nil;
    self.m_sell_btn_1 = nil;
    self.m_sell_btn_2 = nil;
    self.m_sell_btn_3 = nil;
    self.m_tips_label_1 = nil;
    self.m_tips_label_2 = nil;
    self.m_tips_label_3 = nil;
    self.m_tParams = nil;
end
--[[--
    返回
]]
function game_sell_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("game_sell_pop");
end
--[[--
    讀取ccbi創建ui
]]
function game_sell_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--關閉
            self:back();
        elseif btnTag == 11 or btnTag == 12 or btnTag == 13 then--
            if self.m_tParams.m_showType == 1 then
                self:sellCards(btnTag - 10);
            elseif self.m_tParams.m_showType == 2 then--装备
                self:sellEquips(btnTag - 10);
            elseif self.m_tParams.m_showType == 3 then--英魂
                self:sellSouls(btnTag - 10)
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_sell_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    self.m_sell_btn_1 = ccbNode:controlButtonForName("m_sell_btn_1")
    self.m_sell_btn_2 = ccbNode:controlButtonForName("m_sell_btn_2")
    self.m_sell_btn_3 = ccbNode:controlButtonForName("m_sell_btn_3")
    self.m_tips_label_1 = ccbNode:labelTTFForName("m_tips_label_1")
    self.m_tips_label_2 = ccbNode:labelTTFForName("m_tips_label_2")
    self.m_tips_label_3 = ccbNode:labelTTFForName("m_tips_label_3")

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_sell_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_sell_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_sell_btn_3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-4,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
]]
function game_sell_pop.sellCards(self,tag)
    local sellQuality = tag - 1;
    local character_detail = getConfig(game_config_field.character_detail);
    local cardsDataTable = game_data:getTableCardsData();
    local showHeroTable = {};
    local itemCfg = nil;
    for key,heroData in pairs(cardsDataTable) do
        if not game_data:heroInTeamById(key) and not game_util:getCardLockFlag(heroData) then
            itemCfg = character_detail:getNodeWithKey(heroData.c_id);
            local godflag = game_util:godheroInTeamById(tostring(heroData.c_id))
            if itemCfg:getNodeWithKey("quality"):toInt() <= sellQuality and godflag ~= true then
                showHeroTable[#showHeroTable+1] = heroData.id
            end
        end
    end
    cclog("sellCards #showHeroTable ====================== " .. #showHeroTable)
    local function sendRequest()
        local function responseMethod(tag,gameData)
            self:callBackFunc();
            self:back();
            -- game_util:addMoveTips({text = "出售夥伴成功!"});
            local get_food = gameData:getNodeWithKey("data"):getNodeWithKey("get_food"):toInt();
            game_util:rewardTipsByDataTable({food = get_food});
        end
        --  card_id= 
        local params = "";
        table.foreach(showHeroTable,function(k,v)
            params = params .. "card_id=" .. v .. "&";
        end)
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_butcher"), http_request_method.POST, params,"cards_butcher");
    end
    if #showHeroTable == 0 then
        game_util:addMoveTips({text = "Không có đồng đội bán phẩm chất này trở xuống!"});
    else
        sendRequest();
    end
end

--[[--
]]
function game_sell_pop.sellEquips(self,tag)
    local sellQuality = tag - 1;
    local equipCfg = getConfig(game_config_field.equip);
    local equipsDataTable = game_data:getEquipData();
    local showDataTable = {};
    local itemCfg = nil;
    for key,itemData in pairs(equipsDataTable) do
        itemCfg = equipCfg:getNodeWithKey(itemData.c_id);
        local dataId = tostring(itemData.id);
        local existFlag,cardName = game_data:equipInEquipPos(itemCfg:getNodeWithKey("sort"):toInt(),itemData.id)
        
        local godexistFlag = game_data:godequipInEquipPos(itemCfg:getNodeWithKey("sort"):toInt(),itemData.id)

        if itemCfg and not existFlag and not godexistFlag then
            if itemCfg:getNodeWithKey("quality"):toInt() <= sellQuality then
                showDataTable[#showDataTable+1] = itemData.id;
            end
        end
    end
    cclog("sellEquips #showDataTable ====================== " .. #showDataTable)
    local function sendRequest()
        local function responseMethod(tag,gameData)
            self:callBackFunc();
            self:back();
            -- game_util:addMoveTips({text = "出售裝備成功!"});
            local sell_metal = gameData:getNodeWithKey("data"):getNodeWithKey("sell_metal"):toInt();
            game_util:rewardTipsByDataTable({metal = sell_metal});
        end
        --  equip= 
        local params = "";
        table.foreach(showDataTable,function(k,v)
            params = params .. "equip=" .. v .. "&";
        end)
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_sell"), http_request_method.POST, params,"equip_sell");
    end
    if #showDataTable == 0 then
        game_util:addMoveTips({text = "Không có trang bị bán phẩm chất này trở xuống!"});
    else
        sendRequest();
    end
end

--[[
    卖英魂
]]

function game_sell_pop.sellSouls(self,tag)
    local sellQuality = tag
    local soulCfg = getConfig(game_config_field.soul_detail)
    local soulData = game_data:getSoulData() or {} 
    local showDataTable = {};
    local itemCfg = nil;
    for key,itemData in pairs(soulData) do
        itemCfg = soulCfg:getNodeWithKey(itemData.s_id);
        local is_equip,cardName = game_data:soulInSoulPos(itemData.id)
        if itemCfg and not is_equip then
            if itemCfg:getNodeWithKey("quality"):toInt() <= sellQuality then
                showDataTable[#showDataTable+1] = itemData.id;
            end
        end
    end
    cclog("sellSouls #showDataTable ====================== " .. #showDataTable)
    local function sendRequest()
        local function responseMethod(tag,gameData)
            self:callBackFunc();
            self:back();
            local food = gameData:getNodeWithKey("data"):getNodeWithKey("food"):toInt();
            game_util:rewardTipsByDataTable({food = food});
        end
        --  equip= 
        local params = "";
        table.foreach(showDataTable,function(k,v)
            params = params .. "metal=" .. v .. "&";
        end)
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_sell_soul"), http_request_method.POST, params,"soul_sell_soul");
    end
    if #showDataTable == 0 then
        game_util:addMoveTips({text = "Chưa có Anh Hồn phẩm chất này trở xuống bán!"});
    else
        sendRequest();
    end
end

--[[--
    刷新ui
]]
function game_sell_pop.refreshUi(self)
    if self.m_tParams.m_showType == 1 then
        self.m_tips_label_1:setString("Bán 1 lần toàn bộ thẻ bài phẩm chất Trắng trong túi thẻ")
        self.m_tips_label_2:setString("Bán 1 lần toàn bộ thẻ phẩm chất Trắng và Lục trong túi thẻ")
        self.m_tips_label_3:setString("Bán 1 lần toàn bộ thẻ phẩm chất Trắng, Lục và Lam trong túi thẻ")
    elseif self.m_tParams.m_showType == 2 then--装备
        self.m_tips_label_1:setString("Bán 1 lần toàn bộ trang bị phẩm chất Trắng trong túi thẻ")
        self.m_tips_label_2:setString("Bán 1 lần toàn bộ trang bị phẩm chất Trắng và Lục trong túi thẻ")
        self.m_tips_label_3:setString("Bán 1 lần toàn bộ trang bị phẩm chất Trắng, Lục và Lam trong túi thẻ")
    elseif self.m_tParams.m_showType == 3 then--英魂
        self.m_tips_label_1:setString("Bán 1 lần toàn bộ Anh Hồn trắng trong máy chứa")
        self.m_tips_label_2:setString("Bán 1 lần toàn bộ Anh Hồn trắng và lục trong máy chứa")
        self.m_tips_label_3:setString("Bán 1 lần toàn bộ Anh Hồn trắng, lục và lam trong máy chứa")
    end
end

--[[--
    初始化
]]
function game_sell_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    self.m_tParams.m_showType = t_params.showType or 1;
end

--[[--
    創建ui入口並初始化數據
]]
function game_sell_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回調方法
]]
function game_sell_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return game_sell_pop;