-- 勋章图鉴

local game_medal_charts = {
    m_list_view_bg = nil,
    m_tableView = nil,
    m_selSort = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_title_label = nil,
    m_popUi = nil,
    m_func_btn = nil,

    gameData = nil,
};
--[[--
    销毁ui
]]
function game_medal_charts.destroy(self)
    -- body
    cclog("-----------------game_medal_charts destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_tableView = nil;
    self.m_selSort = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_title_label = nil;
    self.m_popUi = nil;
    self.m_func_btn = nil;

    self.gameData = nil;
end

--[[--
    返回
]]
function game_medal_charts.back(self,type)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_medal_charts.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 101 then
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_medal_train",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_index"), http_request_method.GET, nil,"medal_index")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_list.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    self.m_sort_btn:setVisible(false)
    self.m_func_btn = ccbNode:controlButtonForName("m_func_btn")
    self.m_func_btn:setVisible(true)
    game_util:setCCControlButtonTitle(self.m_func_btn,"Luyện chế HC")
    self.m_func_btn:setVisible(false)
    self.m_title_label = ccbNode:labelBMFontForName("m_title_label")
    self.m_title_label:setString("Hình HC")
    return ccbNode;
end

--[[--
    创建装备列表
]]
function game_medal_charts.createTableView(self,viewSize)
    local medalCfg = getConfig(game_config_field.medal)
    local showData = self.gameData["_medal"]
    local itemsCount = medalCfg:getNodeCount()
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
            -- local ccbNode = game_util:createMedalItemByCCB();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_medal_system_list_item5.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            
            if index < itemsCount then
                m_spr_bg_up:setVisible(false);

                local m_have_label = ccbNode:labelTTFForName("m_have_label")
                local m_node = ccbNode:nodeForName("m_node")
                local m_name_label = ccbNode:labelBMFontForName("m_name_label")
                local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
                local label_node = ccbNode:nodeForName("label_node")
                local back_node = ccbNode:nodeForName("back_node")

                m_buy_btn:setVisible(false)
                label_node:setVisible(true)

                local itemCfg = medalCfg:getNodeWithKey(tostring(index + 1))
                local itemCount = showData[tostring(index + 1)]

                m_node:removeAllChildrenWithCleanup(true);
                back_node:removeAllChildrenWithCleanup(true)
                local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr()) 
                if icon then
                    icon:setScale(1.2)
                    m_node:addChild(icon)
                end

                m_name_label:setString(itemCfg:getNodeWithKey("name"):toStr())
                m_have_label:setString("")
                if itemCount then
                    -- m_name_label:setString(itemCfg:getNodeWithKey("name"):toStr() .. "(" .. itemCount .. ")")
                    m_have_label:setString("Có:" .. itemCount)
                else
                    -- m_name_label:setString(itemCfg:getNodeWithKey("name"):toStr() .. "(" .. 0 .. ")")
                    m_have_label:setString("Có:" .. 0)
                end

                local effect = itemCfg:getNodeWithKey("effect")
                local back = CCSprite:createWithSpriteFrameName("ui_medal_icon_back.png")
                back_node:addChild(back)
                for i=1,3 do
                    local itemEffect = effect:getNodeAt(i-1)
                    local ability = itemEffect:getNodeAt(0):toInt()
                    -- local value = itemEffect:getNodeAt(1):toInt()
                    local attrTab = PUBLIC_ABILITY_TABLE["ability_" .. ability]
                    local iconStr = attrTab.icon
                    local abilityIcon = CCSprite:createWithSpriteFrameName(iconStr)
                    -- abilityIcon:setPosition(ccp(- 50 + i * 25,0))
                    abilityIcon:setPosition(ccp(0,50 - i * 25))
                    back_node:addChild(abilityIcon)
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
            -- game_scene:addPop("game_medal_function_pop",{gameData = self.gameData,material_id = index + 1})

            --原来的跳转到勋章材料
            -- game_scene:enterGameUi("game_medal_material",{gameData = self.gameData,material_type = index + 1})
            --新的直接去显示炼制
            game_scene:addPop("game_medal_pop",{gameData = self.gameData,material_type = index + 1})
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新列表
]]
function game_medal_charts.refreshTableView(self,sort)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true)
    self.m_selSort = sort;
    -- game_data:gemSortByTypeName(self.m_selSort)
    -- local tempData = game_data:getGemIdTable();
    local tempData = self.gameData["_medal"]
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--
    刷新ui
]]
function game_medal_charts.refreshUi(self)
    self:refreshTableView(self.m_selSort);
end
--[[--
    初始化
]]
function game_medal_charts.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_medal_charts.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_medal_charts;