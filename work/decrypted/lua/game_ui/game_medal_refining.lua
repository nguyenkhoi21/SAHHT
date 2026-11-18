-- 卡牌炼制

local game_medal_refining = {
    m_list_view_bg = nil,
    m_tableView = nil,
    m_sort_btn = nil,
    m_title_label = nil,
    m_popUi = nil,
    m_func_btn = nil,

    gameData = nil,
    material_type = nil,
    material_make_table = nil,
};
--[[--
    销毁ui
]]
function game_medal_refining.destroy(self)
    cclog("-----------------game_medal_refining destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_tableView = nil;
    self.m_sort_btn = nil;
    self.m_title_label = nil;
    self.m_popUi = nil;
    self.m_func_btn = nil;

    self.gameData = nil;
    self.material_type = nil;
    self.material_make_table = nil;
end

--[[--
    返回
]]
function game_medal_refining.back(self,type)
    -- local function endCallFunc()
    --     self:destroy();
    -- end
    -- game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_medal_charts",{gameData = gameData});
        self:destroy()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_index"), http_request_method.GET, nil,"medal_index")
end
--[[--
    读取ccbi创建ui
]]
function game_medal_refining.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 101 then--合成勋章
            local materialCfg = getConfig(game_config_field.material)
            local materialTable = json.decode(materialCfg:getFormatBuffer())
            local showKeys = {}
            for k,v in pairs(materialTable) do
                if (math.floor(k/100) == self.material_type) then
                    table.insert(showKeys,k)
                end
            end
            local function sortFunc(idOne,idTwo)
                return tonumber(idOne) < tonumber(idTwo);
            end
            table.sort(showKeys,sortFunc);
            local showData = self.gameData["material"]
            local medal_count = 0
            for i=1,#showKeys do
                material_key = tostring(showKeys[i])
                if showData[material_key] then
                    medal_count = medal_count + 1
                end
            end
            if medal_count == #showKeys then--满足合成条件
                local function responseMethod(tag,gameData)
                    -- cclog2(gameData,"gameData")
                    local data = gameData:getNodeWithKey("data")
                    self.gameData = json.decode(data:getFormatBuffer()) or {};
                    local reward = data:getNodeWithKey("reward")
                    game_util:rewardTipsByJsonData(reward);
                    self:refreshUi()
                end
                local params = {}
                params.medal_id = self.material_type
                params.num = 1
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_synthesis_medal"), http_request_method.GET, params,"medal_synthesis_medal")
            else
                game_util:addMoveTips({text = "Thiếu nguyên liệu!"})
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_list.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    self.m_sort_btn:setVisible(false)
    self.m_func_btn = ccbNode:controlButtonForName("m_func_btn")
    self.m_func_btn:setVisible(true)
    game_util:setCCControlButtonTitle(self.m_func_btn,"Ghép HC")
    self.m_func_btn:setVisible(false)
    self.m_title_label = ccbNode:labelBMFontForName("m_title_label")
    self.m_title_label:setString("Nguyên liệu HC")
    return ccbNode;
end

--[[--
    创建装备列表
]]
function game_medal_refining.createTableView(self,viewSize)
    local materialCfg = getConfig(game_config_field.material)

    local materialTable = json.decode(materialCfg:getFormatBuffer())

    local showKeys = {}
    for k,v in pairs(materialTable) do
        if (math.floor(k/100) == self.material_type) then
            table.insert(showKeys,k)
        end
    end
    local function sortFunc(idOne,idTwo)
        return tonumber(idOne) < tonumber(idTwo);
    end
    table.sort(showKeys,sortFunc);
    -- cclog2(showKeys,"showKeys")

    local showData = self.gameData["material"]
    local itemsCount = game_util:getTableLen(showKeys)

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local index = btnTag - 100

        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_medal_train",{gameData = gameData});
            self:destroy()
        end
        local params = {}
        local pos = 0
        for i=1,4 do
            local itemTrain = self.gameData["train"][tostring(i)]
            if itemTrain.material_id == "" then--没有材料，可以训练
                pos = i
                break
            end
        end
        if pos > 0 then
            local material_key = tostring(showKeys[index])
            params.material_id = material_key
            params.sort = 1
            params.pos = pos
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_train_material"), http_request_method.GET, params,"medal_train_material")
        else
            game_util:addMoveTips({text = "Không có chỗ huấn luyện!"})
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = itemsCount
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_medal_system_list_item3.ccbi");
            ccbNode:controlButtonForName("m_buy_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            
            if index < itemsCount then
                m_spr_bg_up:setVisible(false);

                local material_key = tostring(showKeys[index + 1])
                local itemCfg = materialCfg:getNodeWithKey(material_key)

                local m_have_label = ccbNode:labelTTFForName("m_have_label")
                local m_node = ccbNode:nodeForName("m_node")
                local m_price_label = ccbNode:labelBMFontForName("m_price_label")
                local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
                local label_node = ccbNode:nodeForName("label_node")
                local price_node = ccbNode:nodeForName("price_node")

                --为练卡准备的
                local material_node = ccbNode:nodeForName("material_node")
                local alpha_layer = ccbNode:layerColorForName("alpha_layer")
                local light_sprite = ccbNode:spriteForName("light_sprite")
                local material_sprite = ccbNode:spriteForName("material_sprite")

                m_buy_btn:setVisible(false)
                label_node:setVisible(false)
                price_node:setVisible(true)
                m_buy_btn:setTag(101 + index)

                m_node:removeAllChildrenWithCleanup(true);
                local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr()) 
                if icon then
                    icon:setScale(1.2)
                    m_node:addChild(icon)
                end

                local count = 0
                if showData[material_key] then
                    count = showData[material_key]
                end
                m_have_label:setString(itemCfg:getNodeWithKey("name"):toStr() .. "(" .. count .. ")")
                m_price_label:setString(itemCfg:getNodeWithKey("price"):toStr())
                if count == 0 then--没有，暗的
                    alpha_layer:setVisible(true)
                else
                    alpha_layer:setVisible(false)
                end
                --炼制
                if self.material_make_table[1] and self.material_make_table[1] == material_key then--主卡
                    material_node:setVisible(true)
                    light_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("medal_select_1.png"))
                    m_buy_btn:setVisible(true)
                    game_util:setCCControlButtonTitle(m_buy_btn,"Luyện thẻ")
                    material_sprite:setVisible(false)
                elseif material_key == self.material_make_table[2] or material_key == self.material_make_table[3] or material_key == self.material_make_table[4] then
                    material_node:setVisible(true)
                    light_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("medal_select_2.png"))
                    material_sprite:setVisible(true)
                else
                    material_node:setVisible(false)
                end
            else
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
            --切换
            local materialCfg = getConfig(game_config_field.material)
            local itemCfg = materialCfg:getNodeWithKey(tostring(showKeys[index + 1]))
            local material = itemCfg:getNodeWithKey("material")
            if material:getNodeCount() == 0 then--不可炼制
                game_util:addMoveTips({text = "Thẻ này không thể luyện chế!"})
            elseif material:getNodeCount() > 0 then--判断材料够不够
                local have_count = 0
                for i=1,material:getNodeCount() do
                    local itemMaterial = material:getNodeAt(i-1):toInt()
                    local materialData = self.gameData["material"]
                    if materialData[tostring(itemMaterial)] and materialData[tostring(itemMaterial)] > 0 then
                        have_count = have_count + 1
                    end
                end
                -- if have_count == material:getNodeCount() then--材料都有
                    self.material_make_table[1] = tostring(showKeys[index + 1])
                    self.material_make_table[2] = material:getNodeAt(0):toStr()
                    self.material_make_table[3] = material:getNodeAt(1):toStr()
                    self.material_make_table[4] = material:getNodeAt(2):toStr()
                    self:refreshUi()
                -- elseif have_count < material:getNodeCount() then--不足
                --     game_util:addMoveTips({text = "材料不足！"})
                -- end
            end
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新列表
]]
function game_medal_refining.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true)
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--
    刷新ui
]]
function game_medal_refining.refreshUi(self)
    self:refreshTableView();
end
--[[--
    初始化
]]
function game_medal_refining.init(self,t_params)
    t_params = t_params or {};
    self.gameData = t_params.gameData
    self.material_type = t_params.material_type--根据id区分是哪个勋章的材料
    self.material_make_table = t_params.material_make_table or {}
end

--[[--
    创建ui入口并初始化数据
]]
function game_medal_refining.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_medal_refining;