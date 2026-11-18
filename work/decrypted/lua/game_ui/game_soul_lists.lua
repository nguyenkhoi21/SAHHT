-- 英魂容器

local game_soul_lists = {
	m_list_view_bg = nil,
    m_tableView = nil,
    m_selSort = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_title_label = nil,
    m_popUi = nil,
    m_func_btn = nil,
    m_fuhun_btn =nil,
    m_num_lab=nil, --容器大小
    gameData = nil,
    m_curPage2 = nil,
    m_yinghunData = nil,
    num  = nil,
    listsData  = nil,
};

--[[--
    销毁ui
]]
function game_soul_lists.destroy(self)
    -- body
    cclog("-----------------game_soul_lists destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_tableView = nil;
    self.m_selSort = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_title_label = nil;
    self.m_popUi = nil;
    self.m_func_btn = nil;
    self.m_num_lab=nil;
    self.gameData = nil;
    self.m_curPage2 = nil;
    self.m_yinghunData = nil;
    self.num  = nil;
    self.listsData  = nil;
end

function game_soul_lists.back(self)
    -- game_scene:removePopByName("game_soul_lists")
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_soul_list",{gameData = gameData});
        self:destroy();
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_all_soul"), http_request_method.GET, nil,"soul_index") 
end
--[[--
    读取ccbi创建ui
]]
function game_soul_lists.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back()
            -- local function responseMethod(tag,gameData)
            --     local data = gameData:getNodeWithKey("data")
            --     local dataTable = json.decode(data:getFormatBuffer()) or {}
            --     cclog2("gameData.statue========",gameData.statue)
            --     game_scene:enterGameUi("game_soul_gacha",{gameData = gameData, statue = dataTable.statue ,soul_rate= dataTable.soul_rate});
            --     self:destroy();
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_soul_index"), http_request_method.GET, nil,"soul_index")
        -- elseif btnTag == 101 then  --图鉴
        --     local function responseMethod(tag,gameData)
        --         game_scene:enterGameUi("game_soul_illustrated_pop",{gameData = gameData});
        --         self:destroy();
        --     end
        --     network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_book"), http_request_method.GET, nil,"soul_book")
        -- elseif btnTag == 102 then  -- 进到阵型界面
        --     game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_main_scene"});
        --     self:destroy();
        -- elseif btnTag == 4 then--一键贩卖
        --     local function callBackFunc()
        --         self.m_material_id_table = {};
        --         self:refreshTabBtn();
        --     end
        --     game_scene:addPop("game_sell_pop",{showType = 3,callBackFunc = callBackFunc})
        -- elseif btnTag == 11 then--
        --     self.m_ccbNode:runAnimations("anim_1")
        --     self.m_showIndex = 1;
        --     self:refreshTabBtn();
        -- elseif btnTag == 12 then--
        --     self.m_ccbNode:runAnimations("anim_2")
        --     self.m_showIndex = 2;
        --     self:refreshTabBtn();
        -- elseif btnTag == 3 then--贩卖
        --     self:onSureFunc();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_list_new2.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn");
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 14)
    -- self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn");
    -- self.m_sort_btn:setVisible(false)
    -- self.m_func_btn = ccbNode:controlButtonForName("m_func_btn");
    -- self.tujian_node = ccbNode:nodeForName("tujian_node")
    -- self.m_func_btn:setVisible(true);
    -- self.m_tab_btn_1 = ccbNode:controlButtonForName("m_tab_btn_1")
    -- self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2")
    -- self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    -- self.m_gain_value_label = ccbNode:labelBMFontForName("m_gain_value_label")
    -- self.m_func_btn:setVisible(false)
    -- self.m_num_lab = ccbNode:labelTTFForName("m_num_lab");
    self.m_ccbNode = ccbNode;
    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-13,true);
    m_root_layer:setTouchEnabled(true);
    -- if self.m_showIndex == 2 then
    --     self.m_ccbNode:runAnimations("anim_2")
    -- end
    return ccbNode;
end


--[[--

]]
-- function game_soul_lists.onSureFunc(self)
--     if #self.m_material_id_table == 0 then
--         game_util:addMoveTips({text = "还没选择出售的伙伴!"});
--         return;
--     end

--     local function sendRequest()
--         local function responseMethod(tag,gameData)
--             self.m_material_id_table = {};
--             local get_food = gameData:getNodeWithKey("data"):getNodeWithKey("food"):toInt();
--             game_util:rewardTipsByDataTable({food = get_food});
--             self:refreshTabBtn();
--         end
--         local params = "";
--         table.foreach(self.m_material_id_table,function(k,v)
--             params = params .. "metal=" .. v .. "&";
--         end)
--         network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_sell_soul"), http_request_method.POST, params,"soul_sell_soul");
--     end
--     sendRequest();
-- end


function game_soul_lists.refreshTabBtn(self)
    -- local flag1 = self.m_showIndex == 1 and true or false
    -- local flag2 = self.m_showIndex == 2 and true or false
    -- self.m_tab_btn_1:setHighlighted(flag1);
    -- self.m_tab_btn_1:setEnabled(not flag1);
    -- self.m_tab_btn_2:setHighlighted(flag2);
    -- self.m_tab_btn_2:setEnabled(not flag2);
    if self.m_showIndex == 1 then
        self:refreshTab1();
    -- elseif self.m_showIndex == 2 then
    --     self:refreshTab2();
    end
end
--[[--
    创建英魂列表
]]

function game_soul_lists.createSoulTableView(self,viewSize)
    local showDataTable = {}
    local soulCfg = getConfig(game_config_field.soul_detail)

    local allSoul = game_data:getSoulData()
    
    -- local itemsCount = game_data:getSoulCount();
    local itemsCount = game_util:getTableLen(self.listsData)
    
    -- local itemsCount = game_data:getSoulBackpackNum();
    -- local itemsCount = game_data:getSoulCount();
    local soulTotalCount = game_data:getSoulBackpackNum();
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 14;

    self.soul_id_table = {}  --取英魂id
    -- self.s_id_table = {} --取detail表里的id
    -- local allSoul = game_data:getSoulData()
    -- for k,v in pairs(allSoul) do
    --     table.insert(self.soul_id_table,k)
    -- end

    -- local soulPos = {}
    -- for key,soulTable in pairs(game_data:getSoulPos()) do
    --     for k,v in pairs(soulTable) do
    --         if v ~= "0" and v ~= "-1" then
    --             soulPos[v] = 1
    --         end
    --     end
    -- end
    -- --根据id排序
    -- --先判断是否穿在身上
    -- local flag1,flag2
    -- local function sortFunc(data1,data2)
    --     local itemData1 = allSoul[data1]
    --     local itemData2 = allSoul[data2]
    --     local s_id1 = itemData1.s_id
    --     local s_id2 = itemData2.s_id
    --     local itemCfg1 = soulCfg:getNodeWithKey(tostring(s_id1))
    --     local itemCfg2 = soulCfg:getNodeWithKey(tostring(s_id2))
    --     -- local quality1 = itemCfg1:getNodeWithKey("quality"):toInt()
    --     -- local quality2 = itemCfg2:getNodeWithKey("quality"):toInt()
        
    --     local exp1 = showData[data1].exp + showData[data1].pre_exp
    --     local exp2 = showData[data2].exp + showData[data2].pre_exp

    --     flag1 = soulPos[data1] or 0
    --     flag2 = soulPos[data2] or 0
    --     if flag1 == flag2 then
    --         if s_id1 == s_id2 then
    --             -- if s_id1 == s_id2 then
    --             --     return tonumber(s_id1) > tonumber(s_id2)
    --             -- else
    --                 return tonumber(exp1) > tonumber(exp2)
    --             -- end
    --         else
    --             return s_id1 > s_id2
    --         end
    --     else
    --         return flag1 > flag2
    --     end
    -- end
    -- table.sort( self.soul_id_table, sortFunc )
    -- cclog2(self.soul_id_table,"self.s_id_table=======")

    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local index = btnTag - 100
        -- cclog("index == " .. index)

        -- local key = self.soul_id_table[index]
        local key = self.listsData[index]
        -- cclog2(key,"key")
        game_scene:addPop("game_fuse_soul",{soul_id = key})
    end

    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_soul_system_list_item3.ccbi");
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
                local m_name_label = ccbNode:labelTTFForName("m_name_label")
                local m_up_btn = ccbNode:controlButtonForName("m_up_btn")
                m_up_btn:setTag(101 + index)
                m_up_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 14)
                local label_node = ccbNode:nodeForName("label_node")

                label_node:setVisible(true)
                local m_id_num = ccbNode:labelTTFForName("m_id_num")
                m_id_num:setVisible(false)
                local itemData = allSoul[self.listsData[index + 1]]
                local soulId = self.listsData[index + 1]
                cclog2(self.listsData)
                cclog2(soulId,"4564645646464")
                -- local soulId = self.showDataTable[tonumber(index + 1)]
                local itemCfg = allSoul[tostring(soulId)]
                -- local itemsCount = showData[tostring(index + 1)]
                m_node:removeAllChildrenWithCleanup(true);
                local key = itemCfg.s_id
                
                -- showDataTable[#showDataTable+1]= key
                -- cclog2(showDataTable,"showDataTable======")
                local data = json.decode((soulCfg:getNodeWithKey(tostring(key))):getFormatBuffer()) or {}
                local iconName = data.icon
                local icon = game_util:createIconByName(iconName) 
                if icon then
                    icon:setScale(1.2)
                    m_node:addChild(icon)
                else
                    cclog("icon not exist")
                end
                m_name_label:setString((json.decode((soulCfg:getNodeWithKey(tostring(key))):getFormatBuffer()) or {}).name)
                local quality = (json.decode((soulCfg:getNodeWithKey(tostring(key))):getFormatBuffer()) or {}).quality
                m_name_label:setColor(SOUL_QUALITY_COLOR_TABLE[quality].color)

                local level = itemCfg.lv
                local levelMax = data.max_level
                if game_data:getSoulCount() then
                    m_have_label:setString("lv." .. level .. "/" .. levelMax)
                else
                    m_have_label:setString("")
                end

                --判断是否装备
                local m_team_img = ccbNode:spriteForName("m_team_img")
                local m_team_name = ccbNode:labelTTFForName("m_team_name")
                local is_equip,cardName = game_data:soulInSoulPos(soulId)
                if is_equip then
                    m_team_img:setVisible(true)
                    m_team_name:setString(cardName)
                else
                    m_team_img:setVisible(false)
                end
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                m_sel_img:setVisible(false)
            else
                m_spr_bg_up:setVisible(true);
            end

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- if self.m_openType == "game_function_pop" then return end
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
            print("sferfgeswgteswgteswgty")
            -- game_scene:addPop("game_fuse_soul",{selHeroId=self.m_selHeroId,posIndex = self.m_up_skill_index,backupData = self.m_skillBackupData})
        end
    end
    return TableViewHelper:createGallery2(params);
end

-- function game_soul_lists.setdata( self )
--     local itemsCount = game_data:getSoulCount();
--     local soulTotalCount = game_data:getSoulBackpackNum();
--     self.m_num_lab:setString(itemsCount .. "/" .. soulTotalCount);
-- end

--[[--
    刷新列表
]]
function game_soul_lists.refreshTab1(self,sort)
    -- self.m_ok_btn:setVisible(false);
    -- self.m_sort_btn:setVisible(true);
    -- self.tujian_node:setVisible(true)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true)
    self.m_selSort = sort;
    self.m_tableView = self:createSoulTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
    -- self:setdata( )
end

--[[--
    创建筛选的列表
]]
-- function game_soul_lists.createFilterTableView(self,viewSize)
--     local showDataTable = {}
--     local soulCfg = getConfig(game_config_field.soul_detail)
--     local showData = game_data:getSoulData() or {} 
--     -- local itemsCount = game_data:getSoulBackpackNum();
--     local itemsCount = game_data:getSoulCount();
--     local soulTotalCount = game_data:getSoulBackpackNum();
--     local totalItem = itemsCount
--     -- params.touchPriority = GLOBAL_TOUCH_PRIORITY + 1;

--     self.soul_id_table = {}  --取英魂id
--     self.s_id_table = {} --取detail表里的id
--     local allSoul = game_data:getSoulData()
--     for k,v in pairs(allSoul) do
--         --排除穿了的
--         local is_equip,cardName = game_data:soulInSoulPos(v.id)
--         if is_equip then
            
--         else
--             table.insert(self.soul_id_table,k)
--         end
--     end
--     local soulPos = {}
--     for key,soulTable in pairs(game_data:getSoulPos()) do
--         for k,v in pairs(soulTable) do
--             if v ~= "0" and v ~= "-1" then
--                 soulPos[v] = 1
--             end
--         end
--     end
--     --根据id排序
--     --先判断是否穿在身上
--     local flag1,flag2
--     local function sortFunc(data1,data2)
--         local itemData1 = allSoul[data1]
--         local itemData2 = allSoul[data2]
--         local s_id1 = itemData1.s_id
--         local s_id2 = itemData2.s_id
--         local itemCfg1 = soulCfg:getNodeWithKey(tostring(s_id1))
--         local itemCfg2 = soulCfg:getNodeWithKey(tostring(s_id2))
--         -- local quality1 = itemCfg1:getNodeWithKey("quality"):toInt()
--         -- local quality2 = itemCfg2:getNodeWithKey("quality"):toInt()
        
--         local exp1 = showData[data1].exp + showData[data1].pre_exp
--         local exp2 = showData[data2].exp + showData[data2].pre_exp

--         flag1 = soulPos[data1] or 0
--         flag2 = soulPos[data2] or 0
--         if flag1 == flag2 then
--             if s_id1 == s_id2 then
--                 -- if s_id1 == s_id2 then
--                 --     return tonumber(s_id1) > tonumber(s_id2)
--                 -- else
--                     return tonumber(exp1) > tonumber(exp2)
--                 -- end
--             else
--                 return s_id1 > s_id2
--             end
--         else
--             return flag1 < flag2
--         end
--     end
--     table.sort( self.soul_id_table, sortFunc )

--     local params = {};
--     params.viewSize = viewSize;
--     params.row = 2;--行
--     params.column = 4; --列
--     params.totalItem = #self.soul_id_table;
--     params.showPageIndex = self.m_curPage2;
--     params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
--     params.itemActionFlag = true;
--     local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
--     params.newCell = function(tableView,index) 
--         local cell = tableView:dequeueCell()
--         if cell == nil then
--             cell = CCTableViewCell:new()
--             cell:autorelease()
--             local ccbNode = luaCCBNode:create();
--             ccbNode:openCCBFile("ccb/ui_soul_system_list_item3.ccbi");
--             ccbNode:setAnchorPoint(ccp(0.5,0.5));
--             ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
--             cell:addChild(ccbNode,10,10);
--         end
--         if cell then
--             local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
--             local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
--             if index < game_data:getSoulCount() then
--                 m_spr_bg_up:setVisible(false);

--                 local m_have_label = ccbNode:labelTTFForName("m_have_label")
--                 local m_node = ccbNode:nodeForName("m_node")
--                 local m_name_label = ccbNode:labelTTFForName("m_name_label")
--                 local m_up_btn = ccbNode:controlButtonForName("m_up_btn")
--                 m_up_btn:setTag(101 + index)
--                 m_up_btn:setVisible(false)
--                 local label_node = ccbNode:nodeForName("label_node")

--                 label_node:setVisible(true)
--                 local itemData = allSoul[self.soul_id_table[index + 1]]
--                 local soulId = self.soul_id_table[index + 1]
--                 -- local soulId = self.showDataTable[tonumber(index + 1)]
--                 local itemCfg = showData[soulId]
--                 local itemsCount = showData[tostring(index + 1)]
--                 m_node:removeAllChildrenWithCleanup(true);
--                 local key = itemCfg.s_id
                
--                 -- showDataTable[#showDataTable+1]= key
--                 -- cclog2(showDataTable,"showDataTable======")
--                 local data = json.decode((soulCfg:getNodeWithKey(tostring(key))):getFormatBuffer()) or {}
--                 local iconName = data.icon
--                 local icon = game_util:createIconByName(iconName) 
--                 if icon then
--                     icon:setScale(1.2)
--                     m_node:addChild(icon)
--                 else
--                     cclog("icon not exist")
--                 end
--                 m_name_label:setString((json.decode((soulCfg:getNodeWithKey(tostring(key))):getFormatBuffer()) or {}).name)
--                 local quality = (json.decode((soulCfg:getNodeWithKey(tostring(key))):getFormatBuffer()) or {}).quality
--                 m_name_label:setColor(SOUL_QUALITY_COLOR_TABLE[quality].color)

--                 local level = itemCfg.lv
--                 local levelMax = data.max_level
--                 if game_data:getSoulCount() then
--                     m_have_label:setString("lv." .. level .. "/" .. levelMax)
--                 else
--                     m_have_label:setString("")
--                 end

--                 --判断是否装备
--                 local m_team_img = ccbNode:spriteForName("m_team_img")
--                 local m_team_name = ccbNode:labelTTFForName("m_team_name")
--                 local is_equip,cardName = game_data:soulInSoulPos(soulId)
--                 if is_equip then
--                     m_team_img:setVisible(true)
--                     m_team_name:setString(cardName)
--                 else
--                     m_team_img:setVisible(false)
--                 end

--                 --判断是否选择
--                 local m_sel_img = ccbNode:spriteForName("m_sel_img")
--                 m_sel_img:setVisible(false)
--                 local flag,k = game_util:idInTableById(soulId,self.m_material_id_table)
--                 if flag then
--                     m_sel_img:setVisible(true)
--                 end
--             else
--                 m_spr_bg_up:setVisible(true);
--             end
--         end
--         return cell;
--     end
--     params.itemOnClick = function(eventType,index,item)
--         -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item) .. " ; item:getUserData() = " .. tolua.type(item:getUserData()));
--         if index >= totalItem then return end;
--         if eventType == "ended" and item then
--             local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
--             local m_sel_img = ccbNode:spriteForName("m_sel_img")
--             local soulID = self.soul_id_table[index + 1]
--             local flag,k = game_util:idInTableById(soulID,self.m_material_id_table)
--             if flag and k ~= nil then
--                 table.remove(self.m_material_id_table,k);
--                 m_sel_img:setVisible(false);
--             else
--                 table.insert(self.m_material_id_table,soulID);
--                 m_sel_img:setVisible(true);
--             end
--             self:refreshGainValue();
--         end
--     end
--     params.pageChangedCallFunc = function(totalPage,curPage)
--         self.m_curPage2 = curPage;
--     end
--     return TableViewHelper:createGallery2(params);
-- end


--[[--

]]
function game_soul_lists.refreshGainValue(self)
    self.m_is_notice = 0;
    local gainFood = 0;
    local itemData,itemCfg;
    local character_base_item = nil;
    local character_base_rate_item = nil;
    local is_notice = nil;
    -- table.foreach(self.m_material_id_table,function(k,v)
    for i=1,#self.m_material_id_table do
        local v = self.m_material_id_table[i]
        itemData,itemCfg = game_data:getSoulDataById(tostring(v));
        if itemData and itemCfg then
            local sell_food = itemCfg:getNodeWithKey("sell_food"):toInt()
            gainFood = gainFood + sell_food
        end
    end
    cclog("self.m_is_notice ===============" .. self.m_is_notice)
    self.m_gain_value_label:setString(gainFood)
end

--[[--

]]
function game_soul_lists.refreshTab2(self)
    self.m_ok_btn:setVisible(true);
    -- self.m_sort_btn:setVisible(false);
    self.tujian_node:setVisible(false)
    -- self.m_sell_node:setVisible(true);
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createFilterTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
    self:refreshGainValue()
end

--[[--
    刷新ui
]]
function game_soul_lists.refreshUi(self)
    -- self:refreshTab1(self.m_selSort);
    self:refreshTabBtn()
end
--[[--
    初始化
]]
function game_soul_lists.init(self,t_params)
    t_params = t_params or {};
    self.num  = t_params.num
    -- if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
    --     self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    -- end
    local allSoul = game_data:getSoulData()
    self.listsData = t_params.listsData or {}
    table.sort(self.listsData,function(data1,data2)
        local exp1 = allSoul[data1].exp + allSoul[data1].pre_exp
        local exp2 = allSoul[data2].exp + allSoul[data2].pre_exp
        return tonumber(exp1) > tonumber(exp2)
    end)
    self.m_showIndex = 1;
    self.m_material_id_table = {}
    
end

--[[--
    创建ui入口并初始化数据
]]
function game_soul_lists.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_soul_lists;

