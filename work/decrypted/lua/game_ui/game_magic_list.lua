-- 法宝
local game_magic_list = {
    m_list_view_bg = nil,
    m_tableView = nil,
    m_posIndex = nil,
    m_selSort = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_btnCallFunc = nil,
    m_itemOnClick = nil,
    m_openType = nil,
    m_title_label = nil,
    m_curPage = nil,
    m_ok_btn = nil,
    m_tab_btn_1 = nil,
    m_tab_btn_2 = nil,
    m_showIndex = nil,
    m_material_id_table = nil,
    m_sell_node = nil,
    m_gain_value_label = nil,
    m_is_notice = nil,
    m_popUi = nil,
    m_gain_icon = nil,
    m_num_label = nil,
    m_sell_btn = nil,
    m_ccbNode = nil,
    m_func_btn = nil,
    m_zhuanshiData = nil,
};
--[[--
    销毁ui
]]
function game_magic_list.destroy(self)
    -- body
    cclog("-----------------game_magic_list destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_tableView = nil;
    self.m_posIndex = nil;
    self.m_selSort = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_btnCallFunc = nil;
    self.m_itemOnClick = nil;
    self.m_openType = nil;
    self.m_title_label = nil;
    self.m_curPage = nil;
    self.m_ok_btn = nil;
    self.m_tab_btn_1 = nil;
    self.m_tab_btn_2 = nil;
    self.m_showIndex = nil;
    self.m_material_id_table = nil;
    self.m_sell_node = nil;
    self.m_gain_value_label = nil;
    self.m_is_notice = nil;
    self.m_popUi = nil;
    self.m_gain_icon = nil;
    self.m_num_label = nil;
    self.m_sell_btn = nil;
    self.m_ccbNode = nil;
    self.m_func_btn = nil;
    self.m_zhuanshiData = nil;
end

--[[--
    返回
]]
function game_magic_list.back(self,type)
    game_data:resetNewEquipIdTab();
    if self.m_openType == "game_small_map_scene" then
        local function responseMethod(tag,gameData)
            game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
            game_scene:enterGameUi("game_small_map_scene",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, {city = game_data:getSelCityId()},"private_city_open")
    elseif self.m_openType == "zhuanshi" then
        game_scene:enterGameUi("game_hero_zhuanshi_task",{gameData = self.m_zhuanshiData})
        self:destroy();
    elseif self.m_openType == "zhuanshiTask2" then
            local major = self.m_zhuanshiData.id
            game_scene:enterGameUi("game_hero_zhuanshiTask_map",{gameData = nil,major = major})
            self:destroy();
    elseif self.m_openType == "map_building_detail_scene" then
        local function responseMethod(tag,gameData)
            game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
            game_scene:enterGameUi("map_building_detail_scene",{cityId = game_data:getSelCityId(),buildingId = game_data:getSelBuildingId(),gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, {city = game_data:getSelCityId()},"private_city_open")
    elseif self.m_openType == "active_map_building_detail_scene" then
        local activeChapterId = game_data:getSelActiveDataByKey("activeChapterId")
        local activeId = game_data:getSelActiveDataByKey("activeId");
        local nextStep = game_data:getSelActiveDataByKey("nextStep");
        game_scene:enterGameUi("active_map_building_detail_scene",{activeChapterId = activeChapterId,activeId = activeId,next_step = nextStep});
    elseif self.m_openType == "game_neutral_city_map" then
        local city_id = game_data:getSelNeutralCityId();
        local function responseMethod(tag,gameData)
            game_data:setSelNeutralCityDataByJsonData(gameData:getNodeWithKey("data"));
            game_scene:enterGameUi("game_neutral_city_map",{gameData = gameData,city_id = city_id});
            self:destroy();
        end
        -- 公共地图，打开城市 city_id=10001
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_city_open"), http_request_method.GET, {city_id = city_id},"public_city_open")
    elseif self.m_openType == "game_activity_live" then
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local live_data = json.decode(data:getNodeWithKey("active_forever"):getFormatBuffer())
            game_scene:enterGameUi("game_activity_live",{liveData = live_data})
            game_util:rewardTipsByDataTable(reward);
            self:destroy()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
    elseif self.m_openType == "game_pirate_precious" then
        game_scene:enterGameUi("game_pirate_precious",{})
        self:destroy();
    elseif self.m_openType == "map_world_scene" then
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("map_world_scene",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
    else
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui
]]
function game_magic_list.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            if self.m_btnCallFunc then
                self.m_btnCallFunc(target,event)
            else
                self:back();
            end
        elseif btnTag == 2 then
            local function btnCallBack(btnTag)
                cclog("btnCallBack ===========btnTag===" .. btnTag)
                local selSort = tostring(MAGIC_SORT_TAB[btnTag].sortType);
                self:refreshEquipTableView(selSort);
            end
            game_scene:addPop("game_sort_pop",{btnTitleTab = MAGIC_SORT_TAB,btnCallFunc = btnCallBack,currentSortType = self.m_selSort})
        elseif btnTag == 3 then--贩卖
            self:onSureFunc();
        elseif btnTag == 4 then--一键贩卖
            local function callBackFunc()
                self.m_material_id_table = {};
                self:refreshTabBtn();
            end
            game_scene:addPop("game_sell_pop",{showType = 2,callBackFunc = callBackFunc})
        elseif btnTag == 11 then--
            if self.m_showIndex == 2 then
                self.m_ccbNode:runAnimations("anim_1")
            end
            self.m_count_node:setVisible(true)

            self.m_showIndex = 1;
            self:refreshTabBtn();
        elseif btnTag == 12 then--
            -- self.m_func_btn:setVisible(false)
            self.m_ccbNode:runAnimations("anim_2")
            self.m_count_node:setVisible(true)
            self.m_showIndex = 2;
            self:refreshTabBtn();
        elseif btnTag == 13 then
            if self.m_showIndex == 2 then
                self.m_ccbNode:runAnimations("anim_1")
            end
            self.m_count_node:setVisible(false)
            self.m_showIndex = 3;
            self:refreshTabBtn();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_magic_list.ccbi");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    self.m_sell_node = ccbNode:nodeForName("m_sell_node")
    self.m_gain_value_label = ccbNode:labelBMFontForName("m_gain_value_label")
    self.m_num_label = ccbNode:labelTTFForName("m_num_label")
    self.m_title_label:setString("")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_tab_btn_1 = ccbNode:controlButtonForName("m_tab_btn_1")
    self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2")
    self.m_sell_btn = ccbNode:controlButtonForName("m_sell_btn")
    self.m_count_node = ccbNode:nodeForName("m_count_node")
    -- self.m_func_btn = ccbNode:controlButtonForName("m_func_btn")
    -- self.m_func_btn:setVisible(false)
    game_util:setControlButtonTitleBMFont(self.m_sell_btn)
    game_util:setControlButtonTitleBMFont(self.m_sort_btn)
    game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    self.m_gain_icon = ccbNode:spriteForName("m_gain_icon")
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScale(resolution_config:getScale())
    self.m_gain_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_magic_jinghua.png"));
    self.m_gain_icon:setScale(0.4)
    local function animEndFunc(animName)
        -- if animName == "anim_2" then
        --     self.m_func_btn:setVisible(false)
        -- else
        --     self.m_func_btn:setVisible(true)
        -- end
    end
    ccbNode:registerAnimFunc(animEndFunc)
    self.m_ccbNode = ccbNode;
    if self.m_showIndex == 2 then
        -- self.m_func_btn:setVisible(false)
        self.m_ccbNode:runAnimations("anim_2")
    else
        -- self.m_func_btn:setVisible(true)
    end
    return ccbNode;
end

--[[--

]]
function game_magic_list.removePop(self)
    if self.m_popUi then
        self.m_popUi:removeFromParentAndCleanup(true);
        self.m_popUi = nil;
    end
end


--[[--

]]
function game_magic_list.onSureFunc(self)
    if #self.m_material_id_table == 0 then
        game_util:addMoveTips({text = "还没选择出售的装备!"});
        return;
    end

    local function sendRequest()
        local function responseMethod(tag,gameData)
            self.m_material_id_table = {};
            self:refreshTabBtn();
            self:removePop();
            -- cclog2(gameData:getNodeWithKey("data"))
            local sell_metal = gameData:getNodeWithKey("data"):getNodeWithKey("sell_metal"):toInt();
            game_util:rewardTipsByDataTable({lushi = sell_metal});
        end
        --  equip= 
        local params = "";
        table.foreach(self.m_material_id_table,function(k,v)
            params = params .. "talismans=" .. v .. "&";
        end)
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("talisman_sell"), http_request_method.POST, params,"talisman_sell");
    end
    sendRequest();
end

--[[--
    创建装备列表
]]
function game_magic_list.createEquipTableView(self,viewSize,tableData)
    local magic_data = game_data:getMagicData()
    local itemsCount = game_data:getMagicCount()
    self.m_num_label:setString(itemsCount);
    local itemsCount =game_util:getTableLen(tableData);
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY + 1;
    params.itemActionFlag = true;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createMagicItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < itemsCount then
                m_spr_bg_up:setVisible(false);
                local tempId = tableData[index+1]
                local itemData,itemCfg = game_data:getMagicDataById(tempId);
                game_util:setMagicItemInfoByTable(ccbNode,itemData);
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
            local tempId = tableData[index+1]
            local itemData,itemCfg = game_data:getMagicDataById(tempId);
            game_scene:addPop("game_magic_info",{tGameData = itemData,magicType = itemCfg.talisman_typem, enterType = "storeHouse_save", endCb = function ()
                self:refreshUi()
            end})
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新列表
]]
function game_magic_list.refreshEquipTableView(self,sort)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true)
    self.m_selSort = sort;
    game_data:magicSortByTypeName(self.m_selSort)
    local magicIdTable = game_data:getMagicIdTable();
    self.m_tableView = self:createEquipTableView(self.m_list_view_bg:getContentSize(),magicIdTable);
    self.m_list_view_bg:addChild(self.m_tableView);
end


--[[--
    创建筛选的列表
]]
function game_magic_list.createFilterTableView(self,viewSize)

    local magic_data = game_data:getMagicData()
    local itemsCount = game_data:getMagicCount()
    self.m_num_label:setString(itemsCount);
    -- self.m_num_label:setString("");
    local talisman = getConfig(game_config_field.talisman);
    local showDataTable = {};
    local itemCfg = nil;
    for key,itemData in pairs(magic_data) do
        itemCfg = talisman:getNodeWithKey(itemData.c_id);
        -- local existFlag,cardName = game_data:magicInMagicPos(itemCfg:getNodeWithKey("talisman_type"):toInt(),itemData.id)
        -- if itemCfg and not existFlag then
            showDataTable[#showDataTable+1] = {itemData = itemData,itemCfg = itemCfg}
        -- else
        --     cclog("------------------------ not in team -------------------" .. itemData.id)
        -- end
    end
    local function sortFunc(dataOne,dataTwo)
        return dataOne.itemCfg:getNodeWithKey("quality"):toInt() > dataTwo.itemCfg:getNodeWithKey("quality"):toInt();
    end
    table.sort(showDataTable,sortFunc)
    local itemsCount = #showDataTable;
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY + 1;
    params.showPageIndex = self.m_curPage;
    params.itemActionFlag = true;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
        local ccbNode = game_util:createMagicItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < itemsCount then
                m_spr_bg_up:setVisible(false);
                local itemData = showDataTable[index+1].itemData;
                game_util:setMagicItemInfoByTable(ccbNode,itemData);
                local dataId = itemData.id;
                local flag,k = game_util:idInTableById(tostring(dataId),self.m_material_id_table)
                if flag then
                    local m_sel_img = ccbNode:spriteForName("m_sel_img")
                    m_sel_img:setVisible(true);
                end
            else
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item) .. " ; item:getUserData() = " .. tolua.type(item:getUserData()));
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
                local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                local itemData = showDataTable[index+1].itemData;
                local dataId = tostring(itemData.id);
                local flag,k = game_util:idInTableById(dataId,self.m_material_id_table)
                
                local m_tMagicPosData1 = game_data:getGodMagicPosData1();
                local m_tMagicPosData2 = game_data:getGodMagicPosData2();
                local m_tMagicPosData3 = game_data:getGodMagicPosData3();
                local godflag1 = game_util:godEquipeidInTableById(dataId,m_tMagicPosData1)
                local godflag2 = game_util:godEquipeidInTableById(dataId,m_tMagicPosData2)
                local godflag3 = game_util:godEquipeidInTableById(dataId,m_tMagicPosData3)
                
                local existFlag,_ = game_data:magicInMagicPos(itemCfg:getNodeWithKey("talisman_type"):toInt(),dataId)
                local godexistFlag = game_data:godmagicInMagicPos(itemCfg:getNodeWithKey("talisman_type"):toInt(),dataId)
                local BonusFlag,_ = game_data:magicInBonus2(itemCfg:getNodeWithKey("talisman_type"):toInt(),dataId)
                local flag2 = self:isByUsing(dataId)

                if flag and k ~= nil then
                    table.remove(self.m_material_id_table,k);
                    m_sel_img:setVisible(false);
                elseif itemData.bind_card and itemData.bind_card ~= "" then
                    game_util:addMoveTips({text = "Pháp Bảo đã bị khóa, không thể bán"})
                elseif flag2 then
                    game_util:addMoveTips({text = "Pháp Bảo đã ra trận, không thể bán"})   
                    -- cclog("add select material hero id ==========" .. dataId);
                    -- local t_params = 
                    -- {
                    --     title = string_config.m_title_prompt,
                    --     okBtnCallBack = function(target,event)
                    --         table.insert(self.m_material_id_table,dataId);
                    --         m_sel_img:setVisible(true);
                    --         self:refreshGainValue();
                    --         game_util:closeAlertView();
                    --     end,   --可缺省
                    --     cancelBtnCallBack = function(target,event)
                    --         game_util:closeAlertView();
                    --     end,
                    --     okBtnText = "确认",       --可缺省
                    --     cancelBtnText = "取消",
                    --     onlyOneBtn = false,
                    --     text = "该装备在神域上确定要删除吗？",      --可缺省
                    --     touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                    -- }
                    -- game_util:openAlertView(t_params);
                else
                    table.insert(self.m_material_id_table,dataId);
                    m_sel_img:setVisible(true);
                end
                self:refreshGainValue();
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end




function game_magic_list:isByUsing(dataId)
    local itemData,itemCfg = game_data:getMagicDataById(dataId)
    local m_tMagicPosData1 = game_data:getGodMagicPosData1();
    local m_tMagicPosData2 = game_data:getGodMagicPosData2();
    local m_tMagicPosData3 = game_data:getGodMagicPosData3();
    local godflag1 = game_util:godEquipeidInTableById(dataId,m_tMagicPosData1)
    local godflag2 = game_util:godEquipeidInTableById(dataId,m_tMagicPosData2)
    local godflag3 = game_util:godEquipeidInTableById(dataId,m_tMagicPosData3)
    
    local existFlag,_ = game_data:magicInMagicPos(tonumber(itemCfg.talisman_type),dataId)
    local godexistFlag = game_data:godmagicInMagicPos(tonumber(itemCfg.talisman_type),dataId)
    local BonusFlag,_ = game_data:magicInBonus2(tonumber(itemCfg.talisman_type),dataId)
    if godflag1 == true or godflag2 == true or godflag3 == true  or ( existFlag or godexistFlag or BonusFlag) then
        return true
    else
        return false
    end
end

--[[--

]]
function game_magic_list.refreshGainValue(self)
    self.m_is_notice = 0;
    -- local talismanCfg = getConfig(game_config_field.talisman);
    local gainValue = 0;
    local itemData,itemCfg;
    table.foreach(self.m_material_id_table,function(k,v)
        itemData,itemCfg = game_data:getMagicDataById(tostring(v));
        if itemData and itemCfg then
            gainValue = gainValue + tonumber(itemCfg.sell_metal);
        end
    end);
    self.m_gain_value_label:setString(gainValue)
end


--[[--

]]
function game_magic_list.refreshTab1(self)
    self.m_ok_btn:setVisible(false);
    self.m_sort_btn:setVisible(true);
    -- self.m_sell_node:setVisible(false);
    self:refreshEquipTableView(self.m_selSort);
end

--[[--

]]
function game_magic_list.refreshTab2(self)
    self.m_ok_btn:setVisible(true);
    self.m_sort_btn:setVisible(false);
    -- self.m_sell_node:setVisible(true);
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createFilterTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
    self:refreshGainValue();
end



function game_magic_list.refreshTab3(self)
    self.m_ok_btn:setVisible(false);
    self.m_sort_btn:setVisible(false);
    local function responseMethod(tag,gameData)
        self:backData(gameData)
        self.m_list_view_bg:removeAllChildrenWithCleanup(true);
        local tempTableView = self:createTableView(self.m_list_view_bg:getContentSize());
        self.m_list_view_bg:addChild(tempTableView);
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_view"), http_request_method.GET, {},"item_view");
    self:refreshGainValue();
end
--[[--

]]
function game_magic_list.refreshTabBtn(self)

    for i=1,3 do
        local tempBtn = self.m_ccbNode:controlButtonForName("m_tab_btn_" .. i)
        tempBtn:setHighlighted(self.m_showIndex == i);
        tempBtn:setEnabled(self.m_showIndex ~= i);
    end
    if self.m_showIndex == 1 then
        self:refreshTab1();
    elseif self.m_showIndex == 2 then
        self:refreshTab2();
    elseif self.m_showIndex == 3 then
        self:refreshTab3()
    end
end

--[[--

]]
function game_magic_list.onSureFunc2(self,index)
    local itemData = self.m_exchangeData.data[index+1];
    local name = "";
    if itemData and itemData.itemCfg then
        name = itemData.itemCfg:getNodeWithKey("talisman_name"):toStr();
    else
        itemData = nil;
    end
    if itemData == nil then
        game_util:addMoveTips({text = "Số liệu sai!"});
        return;
    end
    if itemData.needCount > itemData.count then
        game_util:addMoveTips({text = "Không đủ mảnh!"});
        return;
    end
    local function sendRequest()
        local function responseMethod(tag,gameData)
            self:backData(gameData);
            self:refreshTabBtn();
            game_guide_controller:gameGuide("send","5",503);
            local allAlertsData = game_data:getAllAlertsData() or {}
            allAlertsData.exchange_card = "";
            -- game_util:addMoveTips({text = "兑换成功!"});
        end
        local params = {};
        params.change_id = itemData.key
        print("need_item_id  ==  ", itemData.need_item_id )
        game_data.m_texchangedCardEquip[tostring(itemData.need_item_id)] = nil
        --碎片弹出框  change_id = 
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_exchange"), http_request_method.GET, params,"item_exchange");
    end

    local exchange_cfg = getConfig(game_config_field.exchange);
    local exc_item_cfg = exchange_cfg:getNodeWithKey(itemData.key);
    local need_food = exc_item_cfg:getNodeWithKey("need_food"):toInt();
    local need_metal = exc_item_cfg:getNodeWithKey("need_metal"):toInt()

    local totalFood = game_data:getUserStatusDataByKey("food") or 0
    local totalMetal = game_data:getUserStatusDataByKey("metal") or 0

    local game_pop_up_box = require("game_ui.game_pop_up_box")
    if need_metal > totalMetal then
        --换成统一的提示
        local t_params = 
        {
            m_openType = 6,
        }
        game_scene:addPop("game_normal_tips_pop",t_params)
    else
        local text = "Tiêu hao" .. itemData.needCount .. "cái" .. itemData.itemName .. "và" .. need_metal .. "Sắt" .. name .. "?";
        local t_params = 
        {
            title = "Đổi",
            okBtnCallBack = function(target,event)
                self:removePop();
                sendRequest();
            end,   --可缺省
            closeCallBack = function(target,event)
                self:removePop();
            end,
            okBtnText = "Xác nhận",       --可缺省
            text = text,      --可缺省
            touchPriority = GLOBAL_TOUCH_PRIORITY-2,
        }
        self.m_popUi = game_pop_up_box.create(t_params)
        game_scene:getPopContainer():addChild(self.m_popUi);
    end

end


--[[--
    查看碎片合成后的卡牌信息
]]
function game_magic_list.onLookFunc(self,index)
    local itemData = self.m_exchangeData.data[index+1];
    if itemData == nil then
        game_util:addMoveTips({text = "Số liệu sai!"});
        return;
    end
    local change_sort = itemData.change_sort;
    local cId = itemData.itemCfg:getKey();
    game_scene:addPop("game_magic_info",{tGameData = {lv = 0, c_id = cId},isOpen = true})
end
-- 兑换
function game_magic_list:createTableView( viewSize )
    local showData = {}
    showData = self.m_exchangeData.data;
    local selIndex = nil;
    local function menuPopCallFunc(tag)
        cclog("menuPopCallFunc ============= tag = " .. tag .. " ; selIndex = " .. selIndex)
        if tag == 1 then -- 兑换
            self:onSureFunc2(selIndex);
        elseif tag == 2 then --查看
            self:onLookFunc(selIndex);
        end
        game_scene:removePopByName("game_menu_pop");
    end

    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        local index = btnTag - 101;
        self:onSureFunc2(index);
    end
    local exchange_cfg = getConfig(game_config_field.exchange);
    local itemsCount = #showData;
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+2;
    params.showPageIndex = self.m_curPage;
    params.itemActionFlag = self.m_itemActionFlag;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_exchange_item.ccbi");
            local m_btn = ccbNode:controlButtonForName("m_button")
            m_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY+1);
            game_util:setControlButtonTitleBMFont(m_btn)
            cell:addChild(ccbNode,10,10);
        end
        if cell~=nil then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            local m_button = ccbNode:controlButtonForName("m_button")
            if index < itemsCount then
                m_spr_bg_up:setVisible(false);
                local m_anim_node = tolua.cast(ccbNode:objectForName("m_anim_node"),"CCNode");   -- 图标位置
                m_anim_node:removeAllChildrenWithCleanup(true);
                local m_name = tolua.cast(ccbNode:objectForName("m_name"),"CCLabelTTF");
                local m_item_count = tolua.cast(ccbNode:objectForName("m_item_count"),"CCLabelTTF");
                local m_spr_bg = tolua.cast(ccbNode:objectForName("m_spr_bg"),"CCSprite");
                local m_cost_food_label = ccbNode:labelBMFontForName("m_cost_food_label")
                local tempData = showData[index+1];
                -- cclog("-------------------------------------- 1  " .. tostring(index) .. "  " .. tostring(tempData.key));
                local exc_item_cfg = exchange_cfg:getNodeWithKey(tempData.key);
                local item_sort = exc_item_cfg:getNodeWithKey("change_sort"):toInt();
                local need_food = exc_item_cfg:getNodeWithKey("need_food"):toInt()
                local need_metal = exc_item_cfg:getNodeWithKey("need_metal"):toInt()
                if self.m_openType == 5 or self.m_showIndex == 3 then--兑换装备
                    m_cost_food_label:setString(tostring(need_metal));
                end
                local shade = exc_item_cfg:getNodeWithKey("shade"):toStr();
                if tempData.itemCfg then
                    m_name:setString(tempData.itemCfg:getNodeWithKey("talisman_name"):toStr());
                end
                local item_item_cfg = tempData.item_item_cfg;
                if item_item_cfg then
                    local sprite = game_util:createItemIconByCfg(item_item_cfg)
                    if(sprite~=nil)then
                        m_anim_node:addChild(sprite);
                    end
                end
                -- 所需道具数量
                local add_numAll = tempData.needCount
                local item_name = tempData.itemName;
                -- 已有道具数量
                local has_numAll = tempData.count;
                m_item_count:setString(item_name .. " " .. tostring(has_numAll) .. "/" .. tostring(add_numAll));
                if has_numAll >= add_numAll then
                    game_util:addTipsAnimByType(m_anim_node,2);
                    if self.m_guildNode == nil then
                        local item_id = item_item_cfg:getKey()
                        local totalFood = game_data:getUserStatusDataByKey("food") or 0
                        if item_id == "1038" and totalFood >= need_food then
                            self.m_guildNode = ccbNode:controlButtonForName("m_button");
                        end
                    end
                end
                local icon_sprite = ccbNode:spriteForName("icon_sprite")
                if self.m_openType == 1 then
                    icon_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_icon_food.png"))
                elseif self.m_openType == 2 or self.m_showIndex == 3  then
                    icon_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_icon_metal.png"))
                end
                m_button:setVisible(true)
                m_button:setTag(101 + index)
            else
                m_button:setVisible(false)
                m_spr_bg_up:setVisible(true);
            end
        else
            cclog("---------------new table cell have error ----" .. tostring(index));
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= itemsCount then return end;
        if eventType == "ended" and cell then
            -- local px,py = cell:getPosition();
            -- local pos = cell:getParent():convertToWorldSpace(ccp(px+itemSize.width*0.5,py+itemSize.height*0.5));
            -- cclog("pos x ,y = " .. pos.x .. " ; " .. pos.y);
            selIndex = index;
            -- game_scene:addPop("game_menu_pop",{menuTab = menuTab,pos = pos,callFunc = menuPopCallFunc});
            -- self:onLookFunc(selIndex);
            self:showCardIcon(selIndex)
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end
--[[
    和道具一样，显示查看还是批量兑换    
]]
function game_magic_list.showCardIcon(self,index)
    local function callBackFunc()
        self:refreshTabBtn();
    end
    local itemData = self.m_exchangeData.data[index+1];
    local change_sort = itemData.change_sort
    local params = {
        callBackFunc = callBackFunc,
        itemData = itemData,
        change_sort = change_sort,
        openType = self.m_openType,
    }
    game_scene:addPop("game_item_card_pieces_pop",params)
end

--[[--
    归类兑换种类
]]
function game_magic_list.backData(self,gameData)
        self.m_exchangeData = {init = true,data = {},data2 = {},data3 = {}}

        local exchange_cfg = getConfig(game_config_field.exchange);
        local talisman_cfg = getConfig(game_config_field.talisman);
        local equip_cfg = getConfig(game_config_field.equip);
        local item_cfg = getConfig(game_config_field.item);
        local pet_cfg = getConfig(game_config_field.pet_detail)

        self.m_exchange_data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
        game_util:rewardTipsByDataTable(self.m_exchange_data.reward);
        local items = self.m_exchange_data.items or {};

        local cfgCount = exchange_cfg:getNodeCount();
        local key,exchSort,need_item_id,ownCount,needCount = nil,nil,nil,nil,nil;
        local change_id,itemCfg,itemName,item_item_cfg,quality = nil,nil,nil,nil,nil;
        for i=1,cfgCount do
            ownCount = 0;
            local tempExch = exchange_cfg:getNodeAt(i-1);
            key = tempExch:getKey();
            exchSort = tempExch:getNodeWithKey("change_sort"):toInt();
            need_item_id = tempExch:getNodeWithKey("need_item"):toInt();
            if items[tostring(need_item_id)] then
                for k,v in pairs(items[tostring(need_item_id)]) do
                    ownCount = ownCount + v;
                end
            end
            if ownCount > 0 then
                needCount = 0;
                local need_num = tempExch:getNodeWithKey("need_num")
                local need_num_count = need_num:getNodeCount();
                if need_num_count > 0 then
                    local tempTimes = self.m_exchange_data.exchange_log[key]
                    if(tempTimes~=nil)then
                        needCount = need_num:getNodeAt(math.min(tempTimes,need_num_count-1)):toInt();
                    else
                        needCount = need_num:getNodeAt(0):toInt();
                    end
                end
                change_id = tempExch:getNodeWithKey("change_id")
                if change_id:getNodeCount() > 0 then
                    local tempItem = change_id:getNodeAt(0)
                    change_id = tempItem:getNodeAt(1):toInt();
                end
                item_item_cfg = item_cfg:getNodeWithKey(tostring(tempExch:getNodeWithKey("need_item"):toInt()));
                itemName = item_item_cfg:getNodeWithKey("name"):toStr();
                cclog("key ====" .. key .. " ; exchSort =======" .. exchSort .. " ; need_item_id ====" .. need_item_id .. " ; ownCount ==" .. ownCount)
                local exchangeFlag = (ownCount >= needCount)
                if(exchSort == 5) then--卡牌   and self.m_openType == 1 
                    itemCfg = talisman_cfg:getNodeWithKey(tostring(change_id));
                    local quality = itemCfg:getNodeWithKey("quality"):toInt()
                    self.m_exchangeData.data[#self.m_exchangeData.data+1] = {key = key,count = ownCount,needCount = needCount,itemCfg = itemCfg,itemName = itemName,item_item_cfg=item_item_cfg,change_sort = exchSort,exchangeFlag = exchangeFlag, need_item_id = need_item_id,quality = quality}
                    game_data.m_texchangedCardEquip[tostring(need_item_id)] = exchangeFlag or nil  -- 记录已经提醒的可兑换卡片
                else
                    -- itemCfg = nil;
                end
            end
        end
    local function sortFunc(itemOne,itemTwo)
        local id1 = itemOne.item_item_cfg:getKey()
        local id2 = itemTwo.item_item_cfg:getKey()
        local quality1 = itemOne.quality
        local quality2 = itemTwo.quality
        if itemOne.exchangeFlag == true and itemTwo.exchangeFlag == false then
            return true;
        elseif itemOne.exchangeFlag == false and itemTwo.exchangeFlag == true then
            return false;
        else
            if id1 == "1038" then
                return true
            elseif id2 == "1038" then
                return false
            else
                if quality1 == quality2 then
                    return id1 > id2;
                else
                    return quality1 > quality2
                end
            end
        end
    end
    -- cclog("self.m_exchangeData.data == " .. json.encode(self.m_exchangeData.data))
    table.sort(self.m_exchangeData.data,sortFunc)
    table.sort(self.m_exchangeData.data2,sortFunc)
end
--[[--
    刷新ui
]]
function game_magic_list.refreshUi(self)
    if self.m_openType == 3 then
        self.m_showIndex = 3
        self.m_count_node:setVisible(false)
    end
    self:refreshTabBtn();
end
--[[--
    初始化
]]
function game_magic_list.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_zhuanshiData = t_params.zhuanshiData or {}
    self.m_posIndex = t_params.posIndex;
    self.m_selSort = game_data:getEquipSortType();
    self.m_openType = t_params.openType or "";
    self.m_showIndex = t_params.showIndex or 1;
    self.m_material_id_table = {};
    self.m_is_notice = 0;
end

--[[--
    创建ui入口并初始化数据
]]
function game_magic_list.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_magic_list;