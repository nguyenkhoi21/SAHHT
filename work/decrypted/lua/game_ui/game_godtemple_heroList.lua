---  英雄列表  

local game_godtemple_heroList = {
    m_list_view_bg = nil,
    m_selSortType = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_tableView = nil,
    m_btnCallFunc = nil,
    m_itemOnClick = nil,
    m_title_label = nil,
    m_curPage = nil,
    m_curPage2 = nil,
    -- m_ok_btn = nil,
    m_tab_btn_1 = nil,
    m_tab_btn_2 = nil,
    m_showIndex = nil,
    m_material_id_table = nil,
    m_sell_node = nil,
    m_gain_value_label = nil,
    m_is_notice = nil,
    m_popUi = nil,
    m_num_label = nil,
    m_sell_btn = nil,
    m_ccbNode = nil,
    m_openType = nil,
    m_func_btn = nil,
    m_sell_id = nil,
    m_zhuanshiData = nil,
    m_team_index = nil,
    cidTab = nil,
};
--[[--
    销毁
]]
function game_godtemple_heroList.destroy(self)
    -- body
    cclog("-----------------game_godtemple_heroList destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_selSortType = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_tableView = nil;
    self.m_btnCallFunc = nil;
    self.m_itemOnClick = nil;
    self.m_title_label = nil;
    self.m_curPage = nil;
    self.m_curPage2 = nil;
    -- self.m_ok_btn = nil;
    self.m_tab_btn_1 = nil;
    self.m_tab_btn_2 = nil;
    self.m_showIndex = nil;
    self.m_material_id_table = nil;
    self.m_sell_node = nil;
    self.m_gain_value_label = nil;
    self.m_is_notice = nil;
    self.m_popUi = nil;
    self.m_num_label = nil;
    self.m_sell_btn = nil;
    self.m_ccbNode = nil;
    self.m_openType = nil;
    self.m_sell_id = nil;
    self.m_func_btn = nil;
    self.m_zhuanshiData = nil;
    self.m_team_index = nil;
    self.cidTab = nil;
end

--[[--
    返回
]]
function game_godtemple_heroList.back(self,type)
    game_data:resetNewCardIdTab();
    local function responseMethod( tag,gameData )
        if self.m_openType == "getTeam" then
            game_scene:enterGameUi("game_godtemple_getTeam",{gameData = gameData})
        elseif self.m_openType == "goTeam" then
            game_scene:enterGameUi("game_godtemple_goTeam",{gameData = gameData,showType = self.m_showIndex})
        else
            game_scene:enterGameUi("game_godtemple_main",{gameData = nil});
        end
    end
    local params = {}
    params.team_index = self.m_team_index
    params.farmers_formation = ""
    if #self.m_material_id_table > 0 then
        for k,v in pairs(self.m_material_id_table) do
            params.farmers_formation = params.farmers_formation .. v .. (k == #self.m_material_id_table and "" or "_")
        end
        network.sendHttpRequest(nil,game_url.getUrlForKey("god_field_temple_set_farmer_team_formation"), http_request_method.GET, params,"god_field_temple_set_farmer_team_formation")
        
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_temple_index"), http_request_method.GET, {},"god_field_temple_index")
    else
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_temple_index"), http_request_method.GET, {},"god_field_temple_index")
    end


end
--[[--
    读取ccbi创建ui
]]
function game_godtemple_heroList.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            if self.m_btnCallFunc then
                self.m_btnCallFunc(target,event)
            else
                self:back();
            end
        elseif btnTag == 2 then
            local function btnCallBack(btnTag)
                cclog("btnCallBack ===========btnTag===" .. btnTag)
                self.m_selSortType = CARD_SORT_TAB[btnTag].sortType;
                game_data:cardsSortByTypeName(self.m_selSortType);
                self:refreshUi();
            end
            local selSortType = game_data:getCardSortType();
            game_scene:addPop("game_sort_pop",{btnTitleTab = CARD_SORT_TAB,btnCallFunc = btnCallBack,currentSortType = selSortType})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godtemple_hero_list_new.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCLayerColor");--
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    self.m_sell_node = ccbNode:nodeForName("m_sell_node")
    self.m_gain_value_label = ccbNode:labelBMFontForName("m_gain_value_label")
    self.m_title_label:setString("")
    -- self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_tab_btn_1 = ccbNode:controlButtonForName("m_tab_btn_1")
    self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2")
    self.m_sell_btn = ccbNode:controlButtonForName("m_sell_btn")
    self.m_func_btn = ccbNode:controlButtonForName("m_func_btn")
    self.m_func_btn:setVisible(false);
    self.m_sell_btn:setVisible(false);
    -- self.m_ok_btn:setVisible(false);
    game_util:setControlButtonTitleBMFont(self.m_sort_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    game_util:setControlButtonTitleBMFont(self.m_sell_btn)
    -- if self.m_openType ~= ""  then
    --     game_util:setCCControlButtonBackground(self.m_back_btn,"public_backNormal2.png","public_backDown2.png")
    -- end
    self.m_ccbNode = ccbNode;

    return ccbNode;
end

--[[--

]]
function game_godtemple_heroList.removePop(self)
    if self.m_popUi then
        self.m_popUi:removeFromParentAndCleanup(true);
        self.m_popUi = nil;
    end
end
function game_godtemple_heroList.getIdTab( self,tab1 )

    local allTab = tab1
    local tempTab = {}
    local realtab = {}
    local i = 1
    for k,v in pairs(self.cidTab) do
        tempTab[v] = 0
    end
    for k,v in pairs(allTab) do
        if tempTab[v] then 
        else
           realtab[i] = v
           i = i+1
        end
    end
    return realtab

    -- body
end
--[[--
    创建筛选的列表
]]
function game_godtemple_heroList.createFilterTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local cardtab1 = game_data:getCardsDataByGodTemple()
    local cardtab = self:getIdTab(cardtab1)
    local cardsCount = #cardtab
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)
    game_data:cardsSortByTypeNameWithTable(self.m_selSortType,cardtab)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.showPageIndex = self.m_curPage2;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    params.itemActionFlag = true;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createHeroListItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < cardsCount then
                m_spr_bg_up:setVisible(false);
                -- local itemData,_ = game_data:getCardDataByIndex(index+1);

                local item1 = game_data:getCardDataById(cardtab[index+1])
                local itemData = cardtab[index+1]
                if itemData then
                    game_util:setHeroListItemInfoByTable(ccbNode,item1);
                    local flag,k = game_util:idInTableById(tostring(itemData.id),self.m_material_id_table)
                    if flag then
                        local m_sel_img = ccbNode:spriteForName("m_sel_img")
                        m_sel_img:setVisible(true);
                    end
                end
            else
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
        -- cclog2(#self.m_material_id_table,"#self.m_material_id_table === ")
                local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("m_sel_img")

                -- local cardtab = game_data:getCardsDataByGodTemple()

                local itemData = cardtab[index+1]
                local heroId = tostring(cardtab[index+1]);
                local flag,k = game_util:idInTableById(heroId,self.m_material_id_table)
                local godflag = game_util:godheroInTeamById(tostring(heroId))
                if flag and k ~= nil then
                    table.remove(self.m_material_id_table,k);
                    m_sel_img:setVisible(false);
                elseif  game_data:heroInTeamById(heroId) or game_data:heroInAssistantById(heroId) then
                     game_util:addMoveTips({text = "Không thể chọn thẻ"})
                elseif game_data:godheroInTeamById(heroId) and heroId ~= "0" then
                    game_util:addMoveTips({text = "Không thể chọn thẻ"})

                else
                    if #self.m_material_id_table <= 4 then
                        table.insert(self.m_material_id_table,heroId);
                        m_sel_img:setVisible(true);
                    else
                        game_util:addMoveTips({text = "Chọn nhiều nhất 5 thẻ"})
                    end
                end

            -- cclog2(self.m_material_id_table,"m_material_id_table =-=== ")
                -- self:refreshGainValue();
                -- print("---------------------------------m_material_id_table-----start");
                -- table.foreach(self.m_material_id_table,print);
                -- print("--------------------------------m_material_id_table------end");
        elseif eventType == "longClick" and item then
            local itemData = showHeroTable[index+1].heroData;
            local function callBack(typeName)
                typeName = typeName or ""
                if typeName == "refresh" then
                    self:refreshTab2();
                end
            end
            game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 1,callBack = callBack})
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage2 = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

function game_godtemple_heroList.refreshTab2(self)
    -- self.m_ok_btn:setVisible(true);
    self.m_sort_btn:setVisible(true);
    -- self.m_sell_node:setVisible(true);
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createFilterTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
    -- self:refreshGainValue();
end

--[[--

]]
function game_godtemple_heroList.refreshTabBtn(self)
    -- local flag1 = self.m_showIndex == 1 and true or false
    -- local flag2 = self.m_showIndex == 2 and true or false
    self.m_tab_btn_1:setVisible(false)
    self.m_tab_btn_2:setVisible(false)
    self:refreshTab2();
end

--[[--
    刷新ui
]]
function game_godtemple_heroList.refreshUi(self)
    self:refreshTabBtn();
end


--[[--
    初始化
]]
function game_godtemple_heroList.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.cidTab = t_params.cidTab
    self.m_selSortType = "default";
    self.m_showIndex = t_params.showIndex or 2;
    self.m_team_index = t_params.team_index or 1;
    self.m_zhuanshiData = t_params.zhuanshiData or {}
    self.m_material_id_table = {};
    self.m_is_notice = 0;
    self.m_openType = t_params.openType or "";
end

--[[--
    创建ui入口并初始化数据
]]
function game_godtemple_heroList.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_godtemple_heroList;