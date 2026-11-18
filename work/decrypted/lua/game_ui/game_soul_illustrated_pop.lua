-- 英魂图鉴

local game_soul_illustrated_pop = {
    m_list_view_bg = nil,
    m_tableView = nil,
    m_selSort = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_title_label = nil,
    m_popUi = nil,
    m_func_btn = nil,
    sort = nil ,
    gameData = nil,
};
--[[--
    销毁ui
]]
function game_soul_illustrated_pop.destroy(self)
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
    self.sort = nil;
    self.gameData = nil;
end

--[[--
    读取ccbi创建ui
]]
function game_soul_illustrated_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            -- local function responseMethod(tag,gameData)
            --     game_scene:enterGameUi("game_soul_list",{gameData = gameData});
            --     self:destroy();
            --  end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_all_soul"), http_request_method.GET, nil,"soul_index")   
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local dataTable = json.decode(data:getFormatBuffer()) or {}
                -- cclog2("gameData.statue========",gameData.statue)
                game_scene:enterGameUi("game_soul_gacha",{gameData = gameData, statue = dataTable.statue ,soul_rate= dataTable.soul_rate});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_soul_index"), http_request_method.GET, nil,"soul_index")
        elseif btnTag == 2 then --排序
            local function btnCallBack(btnTag)
                cclog("btnCallBack ===========btnTag===" .. btnTag)
                local function responseMethod(tag,gameData)
                    if btnTag == 2 then
                        self.sort = 0  --按品质排
                    elseif btnTag == 1 then
                        self.sort = 1  --按id排
                    end
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_soul_index"), http_request_method.GET, nil,"soul_index")
            end
            game_scene:addPop("game_sort_pop",{btnTitleTab = {{sortName = "Mặc định",sortType = 1},{sortName = "Phẩm chất",sortType = 0}},btnCallFunc = btnCallBack,currentSortType = self.sort})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_list.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    -- self.m_sort_btn:setVisible(false)
    self.m_func_btn = ccbNode:controlButtonForName("m_func_btn")
    self.m_func_btn:setVisible(true)
    game_util:setCCControlButtonTitle(self.m_func_btn,"Luyện chế HC")
    self.m_func_btn:setVisible(false)
    self.m_title_label = ccbNode:labelBMFontForName("m_title_label")
    self.m_title_label:setString("Hình Anh Hồn")
    return ccbNode;
end

--[[--
    创建装备列表
]]
function game_soul_illustrated_pop.createTableView(self,viewSize)
    local soulCfg = getConfig(game_config_field.soul_detail)
    local dataTable = json.decode(soulCfg:getFormatBuffer()) or {}
    self.soul_id_table = {}  --取英魂id
    for k,v in pairs(dataTable) do
        table.insert(self.soul_id_table,k)
    end
    if self.sort == 0 then
        --根据品质排序
        local function sortFunc(data1,data2)
            local itemData1 = dataTable[data1]
            local itemData2 = dataTable[data2]
            local quality1 = itemData1.quality
            local quality2 = itemData2.quality
                return quality1 < quality2
        end
        table.sort( self.soul_id_table, sortFunc )
    else
        --根据id排序
        local function sortFunc(data1,data2)
            return data1 < data2
        end
        table.sort( self.soul_id_table, sortFunc )
    end
    
    -- local showData = self.gameData["_soul"]
    local showData = game_data:getSoulData()
    local itemsCount = soulCfg:getNodeCount()
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
            ccbNode:openCCBFile("ccb/ui_soul_system_list_item1.ccbi");
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
                local m_soul_lv = ccbNode:labelTTFForName("m_soul_lv")
                local m_node = ccbNode:nodeForName("m_node")
                local m_name_label = ccbNode:labelTTFForName("m_name_label")
                local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
                local label_node = ccbNode:nodeForName("label_node")
                local back_node = ccbNode:nodeForName("back_node")
                local alpha_node = ccbNode:layerColorForName("alpha_node")

                m_buy_btn:setVisible(false)
                label_node:setVisible(true)
                local s_id = self.soul_id_table[index + 1]
                local itemCfg = dataTable[s_id]
                m_node:removeAllChildrenWithCleanup(true);
                back_node:removeAllChildrenWithCleanup(true)
                local icon = game_util:createIconByName(itemCfg.icon) 
                if icon then
                    icon:setScale(1.2)
                    m_node:addChild(icon)
                end

                m_name_label:setString(itemCfg.name)
                m_have_label:setString(tostring(itemCfg.des))
                m_soul_lv:setString("max_lv." .. itemCfg.max_level)

                --判断是否曾经拥有
                if game_util:idInTableById(s_id,self.gameData.soul_book) then
                    -- cclog("111111")
                    alpha_node:setVisible(false)
                else
                    -- cclog("222222")
                    alpha_node:setVisible(true)
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
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新列表
]]
function game_soul_illustrated_pop.refreshTableView(self,sort)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true)
    self.m_selSort = sort;
    -- game_data:gemSortByTypeName(self.m_selSort)
    -- local tempData = game_data:getGemIdTable();

    -- local tempData = self.gameData["_soul"]
    local tempData = game_data:getSoulData()
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--
    刷新ui
]]
function game_soul_illustrated_pop.refreshUi(self)
    self:refreshTableView(self.m_selSort);
end
--[[--
    初始化
]]
function game_soul_illustrated_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    self.sort = 1;
end

--[[--
    创建ui入口并初始化数据
]]
function game_soul_illustrated_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
    
end

return game_soul_illustrated_pop;