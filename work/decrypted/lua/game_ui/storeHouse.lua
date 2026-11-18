---  超级仓库
local storeHouse = {
    m_selectBtnIdx = 1,
    m_curPage = 1,
    m_pageDirty = false,
}

function storeHouse.destroy(self)
    self.m_pageDirty = false
    cclog("-----------------storeHouse destroy-----------------")
end

function storeHouse.back(self, backType)
    game_data:resetNewItemIdTab()
    local function endCallFunc()
        self:destroy()
    end
    game_scene:enterGameUi("game_main_scene", {gameData = nil}, {endCallFunc = endCallFunc})
end
--[[--
    读取ccbi创建ui
]]
function storeHouse.createUi(self)
    local ccbNode = luaCCBNode:create()
    local function onMainBtnClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then
            self:back()
        elseif type(btnTag) == "number" and btnTag >= 11 and btnTag <= 14 then
            if self.m_selectBtnIdx ~= btnTag - 10 then
                self.m_pageDirty = true
            end
            self.m_selectBtnIdx = btnTag - 10
            cclog("[storeHouse] 选择按钮 " .. self.m_selectBtnIdx)
            self:refreshUi()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_storeHouse.ccbi")
    -- self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCLayerColor") --
    -- self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    -- self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    -- self.m_func_btn = ccbNode:controlButtonForName("m_func_btn")
    -- self.m_func_btn:setVisible(true)
    -- self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    -- self.m_sort_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    -- self.m_title_label = ccbNode:labelBMFontForName("m_title_label")
    -- self.m_title_label:setString("道具列表")
    -- game_util:setControlButtonTitleBMFont(self.m_sort_btn)
    -- self.m_sort_btn:setVisible(false)

    self.m_selectBtnIdx = 1

    self.btn_item = ccbNode:controlButtonForName("btn_item") -- 背包
    self.btn_partner = ccbNode:controlButtonForName("btn_partner") -- 伙伴
    self.btn_equipment = ccbNode:controlButtonForName("btn_equipment") -- 装备
    self.btn_magic = ccbNode:controlButtonForName("btn_magic") -- 法宝

    self.m_list_node = ccbNode:nodeForName("m_list_node")
    self.lb_limit = ccbNode:labelTTFForName("lb_limit")

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist")

    return ccbNode
end

function storeHouse.init(self, t_params)
    t_params = t_params or {}
end

function storeHouse.create(self, t_params)
    self:init(t_params)
    local scene = CCScene:create()
    scene:addChild(self:createUi())
    self:refreshUi()
    return scene
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function storeHouse.refreshUi(self)
    self:refreshBtnState() -- 刷新按钮状态
    self:refreshListView() -- 刷新滑动框
end

--[[
    刷新按钮状态
]]
function storeHouse.refreshBtnState(self)
    self.btn_item:setHighlighted(self.m_selectBtnIdx == 1)
    self.btn_partner:setHighlighted(self.m_selectBtnIdx == 2)
    self.btn_equipment:setHighlighted(self.m_selectBtnIdx == 3)
    self.btn_magic:setHighlighted(self.m_selectBtnIdx == 4)
end

--[[
    刷新滑动框
]]
function storeHouse.refreshListView(self)
    self.m_list_node:removeAllChildrenWithCleanup(true)
    if self.m_pageDirty then
        self.m_curPage = 1
        self.m_pageDirty = false
    end
    if self.m_selectBtnIdx == 1 then
        self:createItemListView()
    elseif self.m_selectBtnIdx == 2 then
        self:createPartnerListView()
    elseif self.m_selectBtnIdx == 3 then
        self:createEquipmentListView()
    elseif self.m_selectBtnIdx == 4 then
        self:createMagicListView()
    end
end

--[[ji'yu
    刷新道具列表
]]
function storeHouse.createItemListView(self)
    local parentNode = self.m_list_node
    local viewSize = parentNode:getContentSize()

    local config_date = getConfig(game_config_field.item)
    local itemsData = game_data.m_storeHouseData and game_data.m_storeHouseData.items or {}
    local itemCfg, cfgId = nil
    local showDataTable = {}
    for k, v in pairs(itemsData) do
        itemCfg = config_date:getNodeWithKey(k)
        cfgId = tonumber(k)
        if itemCfg then
            showDataTable[#showDataTable + 1] = {key = cfgId, itemCfg = itemCfg, count = v}
        end
    end
    --根据道具ID排序
    local tonumber = tonumber
    local function sortFunc(data1, data2)
        local cfgId1 = data1.key
        local cfgId2 = data2.key
        local is_use1 = data1.itemCfg:getNodeWithKey("is_use"):toInt()
        local is_use2 = data2.itemCfg:getNodeWithKey("is_use"):toInt()
        local quality1 = data1.itemCfg:getNodeWithKey("quality"):toInt()
        local quality2 = data2.itemCfg:getNodeWithKey("quality"):toInt()
        if is_use1 == is_use2 then
            if quality1 == quality2 then
                return tonumber(cfgId1) < tonumber(cfgId2)
            else
                return tonumber(quality1) > tonumber(quality2)
            end
        else
            return is_use1 > is_use2
        end
    end
    table.sort(showDataTable, sortFunc)
    local itemsCount = #showDataTable
    local totalItem = math.max(itemsCount % 8 == 0 and itemsCount or math.floor(itemsCount / 8 + 1) * 8, 8)

    -- 限制
    local cfg = self:getCfgById(self.m_selectBtnIdx)
    local m_storeHouseData = game_data.m_storeHouseData
    local extends = m_storeHouseData.extends or {}
    local extendLimit = extends[tostring(cfg.sort)] or 0
    local limit = cfg.num + extendLimit
    self.lb_limit:setString("Đến giới hạn: ".. itemsCount .. "/" .. limit)
    local params = {}
    params.viewSize = viewSize
    params.row = 2 --行
    params.column = 4 --列
    params.totalItem = totalItem
    params.showPageIndex = self.m_curPage
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height / params.row)
    params.newCell = function(tableView, index)
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()
            -- ccbNode:registerFunctionWithFuncName("onCellBtnClick", onCellBtnClick)
            ccbNode:openCCBFile("ccb/ui_items_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5))
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10), "luaCCBNode")
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up")
            if index < itemsCount then
                ccbNode:nodeForName("m_info_node"):setVisible(true)
                m_spr_bg_up:setVisible(false)
                local itemData = showDataTable[index + 1]
                if itemData then
                    local iCountText = ccbNode:labelBMFontForName("m_count")
                    local iNameText = ccbNode:labelTTFForName("m_name")
                    local m_imgNode = tolua.cast(ccbNode:objectForName("m_imgNode"), "CCNode")
                    local m_story_label = tolua.cast(ccbNode:objectForName("m_story_label"), "CCLabelTTF")
                    local m_user_btn = tolua.cast(ccbNode:objectForName("m_user_btn"), "CCControlButton")
                    local items = tolua.cast(ccbNode:objectForName("item_sprite"), "CCSprite")

                    game_util:setControlButtonTitleBMFont(m_user_btn)
                    m_user_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY)
                    m_user_btn:setTag(index + 101)

                    local item_id = itemData.key
                    local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(item_id))
                    local itemName = config_date:getNodeWithKey("name"):toStr()
                    local itemStory = config_date:getNodeWithKey("story"):toStr()
                    local is_use = config_date:getNodeWithKey("is_use"):toInt()
                    local use_num = config_date:getNodeWithKey("use_num"):toInt()

                    game_util:setCCControlButtonTitle(m_user_btn, "Lấy ra")
                    m_user_btn:setVisible(true)
                    items:setVisible(false)
                    m_user_btn:addHandleOfControlEvent(
                        function()
                            local itemsData = game_data.m_storeHouseData and game_data.m_storeHouseData.items or {}
                            local itemCount = itemsData[tostring(item_id)] or 0
                            local t_params = 
                            {
                                okBtnCallBack = function(count)
                                    cclog("[storeHouse] 存入道具 - 点击确定,数量:" .. count)
                                    game_util:addMoveTips({text = "Lấy ra thành công!"})
                                    self:refreshUi()
                                end,
                                shopItemId = item_id,
                                maxCount = itemCount,
                                alreadyCount = 1,
                                times_limit = 1,
                                touchPriority = GLOBAL_TOUCH_PRIORITY - 60,
                                enterType = "storeHouse_get",
                                falg = "show",
                            }
                            game_scene:addPop("storeHouseStore",t_params)
                        end,
                        CCControlEventTouchUpInside
                    )
                    local itemCfg = itemData.itemCfg
                    iCountText:setString(tostring("x" .. itemData.count))
                    -- iNameText:setString(itemCfg:getNodeWithKey("name"):toStr());
                    local itemName = itemCfg:getNodeWithKey("name"):toStr()
                    iNameText:setString(itemName)
                    -- iNameText:setString(itemName .. "(" .. itemData.count ..")");

                    m_imgNode:removeAllChildrenWithCleanup(true)
                    local tempIcon = game_util:createItemIconByCfg(itemCfg)
                    if tempIcon then
                        m_imgNode:addChild(tempIcon)
                    end
                    m_story_label:setString(itemCfg:getNodeWithKey("story"):toStr())
                    local m_new_icon = ccbNode:spriteForName("m_new_icon")
                    if game_data:isNewItemFlagById(itemData.key) then
                        m_new_icon:setVisible(true)
                    else
                        m_new_icon:setVisible(false)
                    end
                end
            else
                ccbNode:nodeForName("m_info_node"):setVisible(false)
                m_spr_bg_up:setVisible(true)
            end
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, item)
        if index >= itemsCount then
            return
        end
        if eventType == "ended" and item then
            local itemData = showDataTable[index + 1]
            local item_id, count = itemData.key, itemData.count

            local itemsCfg = getConfig(game_config_field.item)
            local config_date = itemsCfg:getNodeWithKey(tostring(item_id))
            local is_use = config_date:getNodeWithKey("is_use"):toInt()
            if self.m_itemOnClick then
                self.m_itemOnClick(item_id)
            else
                local function callBackFunc()
                    self:refreshUi()
                end
                if is_use == 15 then
                    game_scene:addPop("game_item_info_pop", {itemId = item_id, openType = 101, callBackFunc = callBackFunc, enterType = "storeHouse_get"})
                else
                    game_scene:addPop("game_item_info_pop", {itemId = item_id, flag = "show", callBackFunc = callBackFunc, enterType = "storeHouse_get"})
                end
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage, curPage)
        self.m_curPage = curPage
    end
    local tb = TableViewHelper:createGallery2(params)
    parentNode:addChild(tb)
end

--[[
    刷新伙伴列表
]]
function storeHouse.createPartnerListView(self)
    local cardData2 = game_data.m_storeHouseData and game_data.m_storeHouseData.cards or {}
    local showData = {}
    for k, v in pairs(cardData2) do
        showData[#showData + 1] = v
    end

    local parentNode = self.m_list_node
    local viewSize = parentNode:getContentSize()
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    -- 排序
    table.sort( showData, function(heroData1, heroData2) 
        local heroCfg1 = character_detail_cfg:getNodeWithKey(tostring(heroData1.c_id));
        local heroCfg2 = character_detail_cfg:getNodeWithKey(tostring(heroData2.c_id)); 
        if heroCfg1 and heroCfg2 then
            local quality1 = heroCfg1:getNodeWithKey("quality"):toInt() + (heroData1.super_step or 0)
            local quality2 = heroCfg2:getNodeWithKey("quality"):toInt() + (heroData2.super_step or 0)
            local c_ID1 = tonumber(heroData1.c_id)
            local c_ID2 = tonumber(heroData2.c_id)
            if quality1 == quality2 then
                if c_ID1 == c_ID2 then
                    return heroData1.lv > heroData2.lv;
                else
                    return c_ID1 > c_ID2;
                end
            else
                return quality1 > quality2;
            end
        else
            return heroData1.id > heroData2.id
        end
    end)

    local cardsCount = #showData

    -- 限制
    local cfg = self:getCfgById(self.m_selectBtnIdx)
    local m_storeHouseData = game_data.m_storeHouseData
    local extends = m_storeHouseData.extends or {}
    local extendLimit = extends[tostring(cfg.sort)] or 0
    local limit = cfg.num + extendLimit
    self.lb_limit:setString("Đến giới hạn: ".. cardsCount .. "/" .. limit)

    local params = {}
    params.viewSize = viewSize
    params.row = 2 --行
    params.column = 4 --列
    params.totalItem = cardsCount
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 14
    params.showPageIndex = self.m_curPage
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height / params.row)
    params.newCell = function(tableView, index)
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createHeroListItemByCCB()
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5))
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10), "luaCCBNode")
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up")
            local m_totalnum_lab1 = ccbNode:labelTTFForName("m_totalnum_lab1")
            local m_totalnum_lab2 = ccbNode:labelTTFForName("m_totalnum_lab2")
            if index < cardsCount then
                m_spr_bg_up:setVisible(false)
                local itemData = showData[index + 1]
                if itemData then
                    game_util:setHeroListItemInfoByTable(ccbNode, itemData)

                    local nd_storeHouseAdd = ccbNode:nodeForName("nd_storeHouseAdd")
                    nd_storeHouseAdd:setVisible(true)
                    local btn_store = ccbNode:controlButtonForName("btn_store")
                    game_util:setCCControlButtonBackground(btn_store, "storeHouse_4.png")
                    btn_store:addHandleOfControlEvent(
                        function()
                            cclog("[storeHouse] 点击角色仓库取出按钮")
                            local function responseMethod(tag, gameData)
                                game_util:addMoveTips({text = "Lấy ra thành công!"})
                                self.isDrity = true
                                self:refreshUi()
                            end
                            network.sendHttpRequest(responseMethod, game_url.getUrlForKey("storehouse_del_card"), http_request_method.GET, {card_ids = itemData.id}, "storehouse_del_card")
                        end,
                        CCControlEventTouchUpInside
                    )
                    btn_store:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 14)
                end
            else
                m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg.png"))
                m_spr_bg_up:setVisible(true)
                ccbNode:nodeForName("m_info_node"):setVisible(false)
            end
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, item)
        if index >= cardsCount then
            return
        end
    end
    params.pageChangedCallFunc = function(totalPage, curPage)
        self.m_curPage = curPage
    end
    local tb = TableViewHelper:createGallery2(params)
    parentNode:addChild(tb)
end

--[[
    刷新装备列表
]]
function storeHouse.createEquipmentListView(self)
    local parentNode = self.m_list_node
    local viewSize = parentNode:getContentSize()

    local function sortFunc(dataOne, dataTwo)
        return dataOne.itemCfg:getNodeWithKey("quality"):toInt() > dataTwo.itemCfg:getNodeWithKey("quality"):toInt()
    end

    local equipCfg = getConfig(game_config_field.equip)
    local showData = {}
    local itemCfg = nil
    local data
    local equips = game_data.m_storeHouseData and game_data.m_storeHouseData.equips or {}

    for k, v in pairs(equips) do
        local data = {}
        data.id = k
        data.itemData = v
        itemCfg = equipCfg:getNodeWithKey(data.itemData.c_id)
        data.itemCfg = itemCfg
        table.insert(showData, data)
    end
    table.sort(showData, sortFunc)
    local itemsCount = #showData
    local totalItem = math.max(itemsCount % 8 == 0 and itemsCount or math.floor(itemsCount / 8 + 1) * 8, 8)

    -- 限制
    local cfg = self:getCfgById(self.m_selectBtnIdx)
    local m_storeHouseData = game_data.m_storeHouseData
    local extends = m_storeHouseData.extends or {}
    local extendLimit = extends[tostring(cfg.sort)] or 0
    local limit = cfg.num + extendLimit
    self.lb_limit:setString("Đến giới hạn: ".. itemsCount .. "/" .. limit)

    local params = {}
    params.viewSize = viewSize
    params.row = 2 --行
    params.column = 4 --列
    params.totalItem = totalItem
    params.touchPriority = GLOBAL_TOUCH_PRIORITY + 1
    params.showPageIndex = self.m_curPage
    params.itemActionFlag = true
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height / params.row)
    params.newCell = function(tableView, index)
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createEquipItemByCCB()
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5))
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10), "luaCCBNode")
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up")
            if index < itemsCount then
                m_spr_bg_up:setVisible(false)
                local data = showData[index + 1]
                local itemData = data.itemData
                local itemCfg = data.itemCfg
                local dataId = itemData.id
                if ccbNode and itemData then
                    itemData.heroid = nil
                    game_util:setEquipItemInfoByTable(ccbNode, itemData)
                end
            else
                m_spr_bg_up:setVisible(true)
                ccbNode:nodeForName("m_info_node"):setVisible(false)
            end
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, item)
        if index >= itemsCount then
            return
        end
        if eventType == "ended" and item then
            local data = showData[index + 1]
            local tempId = data.id
            local itemCfg = data.itemCfg
            local itemData = data.itemData
            local existFlag, cardName, posEquipData = game_data:equipInEquipPos(itemCfg:getNodeWithKey("sort"):toInt(), tempId)
            local function callBack(typeName, t_param)
                if typeName == "storeToHouse_get" then
                    self:refreshUi()
                end
            end
            if existFlag then
                game_scene:addPop("game_equip_info_pop", {tGameData = itemData, callBack = callBack, openType = 3, posEquipData = posEquipData, enterType = "storeHouse_get", tempId = tempId})
            else
                game_scene:addPop("game_equip_info_pop", {tGameData = itemData, callBack = callBack, openType = 3, enterType = "storeHouse_get", tempId = tempId})
            end
        -- local function responseMethod(tag,gameData)
        --     self:refreshUi();
        -- end
        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("storehouse_del_equip"), http_request_method.GET,{equip_ids = itemData.id},"storehouse_del_equip")
        end
    end
    params.pageChangedCallFunc = function(totalPage, curPage)
        self.m_curPage = curPage
    end
    local tb = TableViewHelper:createGallery2(params)
    parentNode:addChild(tb)
end

--[[
    刷新法宝列表
]]
function storeHouse.createMagicListView(self)
    local parentNode = self.m_list_node
    local viewSize = parentNode:getContentSize()

    local talismans = game_data.m_storeHouseData and game_data.m_storeHouseData.talismans or {}
    local showData = {}
    for k, v in pairs(talismans) do
        showData[#showData + 1] = v
    end
    local talismanCfg = getConfig(game_config_field.talisman)

    table.sort(
        showData,
        function(itemData1, itemData2)
            local itemCfg1 = talismanCfg:getNodeWithKey(tostring(itemData1.c_id))
            local itemCfg2 = talismanCfg:getNodeWithKey(tostring(itemData2.c_id))
            local quality1, quality2 = itemCfg1:getNodeWithKey("quality"):toInt(), itemCfg2:getNodeWithKey("quality"):toInt()
            local c_ID1, c_ID2 = tonumber(itemData1.c_id), tonumber(itemData2.c_id)
            if itemCfg1 and itemCfg2 then
                if quality1 == quality2 then
                    return c_ID1 > c_ID2
                else
                    return quality1 > quality2
                end
            else
                return itemData1.id > itemData2.id
            end
        end
    )
    local itemsCount = #showData
    local totalItem = math.max(itemsCount % 8 == 0 and itemsCount or math.floor(itemsCount / 8 + 1) * 8, 8)
    local tableData = showData
    local talisman = getConfig(game_config_field.talisman)

    -- 限制
    local cfg = self:getCfgById(self.m_selectBtnIdx)
    local m_storeHouseData = game_data.m_storeHouseData
    local extends = m_storeHouseData.extends or {}
    local extendLimit = extends[tostring(cfg.sort)] or 0
    local limit = cfg.num + extendLimit
    self.lb_limit:setString("Đến giới hạn: ".. itemsCount .. "/" .. limit)

    local params = {}
    params.viewSize = viewSize
    params.row = 2 --行
    params.column = 4 --列
    params.direction = kCCScrollViewDirectionVertical
    params.totalItem = totalItem
    params.touchPriority = GLOBAL_TOUCH_PRIORITY + 1
    params.itemActionFlag = true
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height / params.row)
    params.newCell = function(tableView, index)
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createMagicItemByCCB()
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5))
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10), "luaCCBNode")
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up")
            if index < itemsCount then
                m_spr_bg_up:setVisible(false)
                local itemData = tableData[index + 1]
                local itemCfg = talisman:getNodeWithKey(tostring(itemData.c_id))
                game_util:setMagicItemInfoByTable(ccbNode, itemData)
            else
                m_spr_bg_up:setVisible(true)
                ccbNode:nodeForName("m_info_node"):setVisible(false)
            end
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, item)
        if index >= itemsCount then
            return
        end
        if eventType == "ended" and item then
            local itemData = tableData[index + 1]
            local itemCfg = talisman:getNodeWithKey(tostring(itemData.c_id))
            itemCfg = json.decode(itemCfg:getFormatBuffer())
            game_scene:addPop(
                "game_magic_info",
                {
                    tGameData = itemData,
                    magicType = itemCfg.talisman_type,
                    enterType = "storeHouse_get",
                    endCb = function()
                        self:refreshUi()
                    end
                }
            )
        end
    end
    local tb = TableViewHelper:createGallery2(params)
    parentNode:addChild(tb)
end

---@param id number 配置项的ID
---@return table|nil 根据提供的ID返回相应的配置数据，如果ID不存在则返回nil
function storeHouse:getCfgById(id)
    -- 解析游戏配置中的日期配置信息
    local storehouse = json.decode(getConfig(game_config_field.storehouse):getFormatBuffer())
    -- 返回ID对应的配置数据
    return storehouse[tostring(id)]
end
return storeHouse
