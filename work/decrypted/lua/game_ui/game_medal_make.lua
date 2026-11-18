---  变卡
local game_medal_make = {
    gameData = nil,
    m_table_view = nil,
    tips_label1 = nil,
    tips_label2 = nil,
    cost_label1 = nil,
    cost_label2 = nil,
    tip_added_sprite = nil,
    card_add_node = nil,
    card_added_node = nil,
    materialId = nil,
    exchangeId = nil,
    last_m_sel_img = nil,
    material_type = nil,
};
--[[--
    销毁ui
]]
function game_medal_make.destroy(self)
    -- body
    cclog("-----------------game_medal_make destroy-----------------");
    self.gameData = nil;
    self.m_table_view = nil;
    self.tips_label1 = nil;
    self.tips_label2 = nil;
    self.cost_label1 = nil;
    self.cost_label2 = nil;
    self.tip_added_sprite = nil;
    self.card_add_node = nil;
    self.card_added_node = nil;
    self.materialId = nil;
    self.exchangeId = nil;
    self.last_m_sel_img = nil;
    self.material_type = nil;
end
--[[--
    返回
]]
function game_medal_make.back(self,backType)
 --    game_scene:enterGameUi("game_main_scene",{gameData = nil});
	-- self:destroy();
    -- local function responseMethod(tag,gameData)
    --     game_scene:enterGameUi("game_medal_charts",{gameData = gameData});
    --     self:destroy()
    -- end
    -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_index"), http_request_method.GET, nil,"medal_index")
    local function responseMethod(tag,gameData)
        --直接跳转到碎片合成
        game_scene:enterGameUi("game_medal_get_material",{gameData = gameData,material_type = tostring(self.material_type)});
        self:destroy()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_index"), http_request_method.GET, nil,"medal_index")
end
--[[--
    读取ccbi创建ui
]]
function game_medal_make.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 101 or btnTag ==102 then--变卡
            if self.exchangeId == nil then
                game_util:addMoveTips({text = "Thêm thẻ muốn đổi!"})
                return
            end
            local function responseMethod(tag,gameData)
                -- cclog2(gameData,"gameData")
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    self.gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                end
                local data = gameData:getNodeWithKey("data")
                local reward = data:getNodeWithKey("reward")
                local exchange_result = data:getNodeWithKey("exchange_result")
                if exchange_result and exchange_result:toBool() == false then
                    game_util:addMoveTips({text = "Đổi thẻ thất bại!"})
                end
                self.exchangeId = nil
                game_util:rewardTipsByJsonData(reward);
                self:refreshUi()
            end
            local params = {}
            params.num = 1
            params.sort = btnTag - 100
            params.exchange_id = self.materialId
            params.material_id = self.exchangeId
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_exchange_material"), http_request_method.GET, params,"medal_exchange_material")
        elseif btnTag == 105 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_medal_make.ccbi");

    self.m_table_view = ccbNode:nodeForName("table_view_node")
    self.tips_label1 = ccbNode:labelTTFForName("tips_label1")
    self.tips_label2 = ccbNode:labelTTFForName("tips_label2")
    self.cost_label1 = ccbNode:labelBMFontForName("cost_label1")
    self.cost_label2 = ccbNode:labelBMFontForName("cost_label2")
    self.tip_added_sprite = ccbNode:spriteForName("tip_added_sprite")

    self.card_add_node = ccbNode:nodeForName("card_add_node")
    self.card_added_node = ccbNode:nodeForName("card_added_node")

    return ccbNode;
end
--[[
    创建英雄列表
]]--
function game_medal_make.createTableView( self,viewSize )
    self.last_m_sel_img = nil;
    local materialData = self.gameData["material"]
    --选出同一面值的，并剔除掉自己
    local showDataKey = {}
    local materialCfg = getConfig(game_config_field.material)
    local addCfg = materialCfg:getNodeWithKey(self.materialId)
    local addPrice = addCfg:getNodeWithKey("price"):toInt()
    for k,v in pairs(materialData) do
        local itemCfg = materialCfg:getNodeWithKey(k)
        local price = itemCfg:getNodeWithKey("price"):toInt()
        if not ((addPrice ~= price) or (k == self.materialId)) then   
            table.insert( showDataKey, k )
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = game_util:getTableLen(showDataKey)
    params.itemActionFlag = true;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = game_util:createMedalItemByCCB4();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            
            local key = showDataKey[index + 1]
            local itemData = {}
            itemData.c_id = key
            itemData.count = materialData[key]
            game_util:setMedalItemInfoByTable4(ccbNode,itemData);
            m_sel_img = ccbNode:spriteForName("m_sel_img")
            if self.exchangeId == key then
                m_sel_img:setVisible(true);
                self.last_m_sel_img = m_sel_img
            else
                m_sel_img:setVisible(false);
            end
        end
        return cell;
    end

    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local m_sel_img = ccbNode:spriteForName("m_sel_img")
            local key = showDataKey[index + 1]

            if self.exchangeId == nil or self.exchangeId ~= key then
                cclog2(key,"key")
                local materialCfg = getConfig(game_config_field.material)
                local itemCfg = materialCfg:getNodeWithKey(key)
                local price = itemCfg:getNodeWithKey("price"):toInt()
                local addCfg = materialCfg:getNodeWithKey(self.materialId)
                local addPrice = addCfg:getNodeWithKey("price"):toInt()
                if addPrice ~= price then
                    game_util:addMoveTips({text = "Chọn nguyên liệu đồng giá!"})
                elseif key == self.materialId then--提示
                    -- game_util:addMoveTips({text = "目标卡与材料卡一致，是否继续"})
                    local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            if self.last_m_sel_img then
                                self.last_m_sel_img:setVisible(false)
                            end
                            m_sel_img:setVisible(true);
                            self.last_m_sel_img = m_sel_img
                            self.exchangeId = key
                            self.card_added_node:removeAllChildrenWithCleanup(true)
                            local tempSize = self.card_added_node:getContentSize()
                            self.tip_added_sprite:setVisible(false)
                            local tempIcon = game_util:createMedalItemByCCB3({key = self.exchangeId})
                            tempIcon:setPosition(tempSize.width*0.5,tempSize.height*0.5)
                            self.card_added_node:addChild(tempIcon)
                            game_util:closeAlertView();
                        end,   --可缺省
                        okBtnText = string_config.m_btn_sure,       --可缺省
                        cancelBtnText = string_config.m_btn_cancel,
                        text = "Thẻ mục tiêu và nguyên liệu khớp, tiếp tục chứ?",      --可缺省
                        onlyOneBtn = false,
                        touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                    }
                    game_util:openAlertView(t_params)
                else
                    if self.last_m_sel_img then
                        self.last_m_sel_img:setVisible(false)
                    end
                    m_sel_img:setVisible(true);
                    self.last_m_sel_img = m_sel_img
                    
                    self.exchangeId = key
                    self.card_added_node:removeAllChildrenWithCleanup(true)
                    local tempSize = self.card_added_node:getContentSize()
                    self.tip_added_sprite:setVisible(false)
                    local tempIcon = game_util:createMedalItemByCCB3({key = self.exchangeId})
                    tempIcon:setPosition(tempSize.width*0.5,tempSize.height*0.5)
                    self.card_added_node:addChild(tempIcon)
                end
            else
                m_sel_img:setVisible(false)
                self.last_m_sel_img = nil
                self.exchangeId = nil
                self.card_added_node:removeAllChildrenWithCleanup(true)
                self.tip_added_sprite:setVisible(true)
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_medal_make.refreshUi(self)
    self.m_table_view:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_table_view:getContentSize());
    tableViewTemp:setScrollBarVisible(false);
    self.m_table_view:addChild(tableViewTemp);

    self.card_add_node:removeAllChildrenWithCleanup(true)
    local tempSize = self.card_add_node:getContentSize()
    if self.materialId then
        local itemData = {key = self.materialId}
        local tempIcon = game_util:createMedalItemByCCB3(itemData)
        tempIcon:setPosition(tempSize.width*0.5,tempSize.height*0.5)
        self.card_add_node:addChild(tempIcon)
    end

    local materialCfg = getConfig(game_config_field.material);
    local itemCfg = materialCfg:getNodeWithKey(tostring(self.materialId));

    local exchange_item = itemCfg:getNodeWithKey("exchange_item")
    local food = exchange_item:getNodeAt(0):getNodeAt(2):toStr()

    local exchange_coin = itemCfg:getNodeWithKey("exchange_coin"):toStr()

    self.cost_label1:setString(food)
    self.cost_label2:setString(exchange_coin)

    self.card_added_node:removeAllChildrenWithCleanup(true)
    if self.exchangeId then
        self.tip_added_sprite:setVisible(false)
        local tempIcon = game_util:createMedalItemByCCB3({key = self.exchangeId})
        tempIcon:setPosition(tempSize.width*0.5,tempSize.height*0.5)
        self.card_added_node:addChild(tempIcon)
    else
        self.tip_added_sprite:setVisible(true)
    end

    local exchange_rate = self.gameData.exchange_rate or 0
    self.tips_label1:setString("·Thành công：" .. (100 - exchange_rate) .."%")
    self.tips_label2:setString("·Thành công：100%")
end
--[[--
    初始化
]]
function game_medal_make.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    self.materialId = t_params.materialId or nil
    self.material_type = t_params.material_type or 1
    self.exchangeId = nil;--被练卡的ID
end

--[[--
    创建ui入口并初始化数据
]]
function game_medal_make.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_medal_make;