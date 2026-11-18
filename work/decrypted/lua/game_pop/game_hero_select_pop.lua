---  弹框选择

local game_hero_select_pop = {
    m_list_view_bg = nil,
    m_selSortType = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_tableView = nil,
    m_btnCallFunc = nil,
    m_itemOnClick = nil,
    m_title_label = nil,
    m_curPage = nil,
    m_popUi = nil,
    m_guildNode = nil,
    m_openType = nil,
    m_newCardsTab = nil,
    m_totalNum_tab = nil,
    c_id = nil,
    material_id = nil,
    m_data_cards = nil,
    m_readycards = nil,
    others = nil,
    m_tab_dispatch = nil, --离线派遣选中的卡
    m_dispatch_bossID = nil,--离线派遣当前的bossID
    m_data_dispatch = nil,--当前派遣出去的卡
};
--[[--
    销毁
]]
function game_hero_select_pop.destroy(self)
    -- body
    cclog("-----------------game_hero_select_pop destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_selSortType = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_tableView = nil;
    self.m_btnCallFunc = nil;
    self.m_itemOnClick = nil;
    self.m_title_label = nil;
    self.m_curPage = nil;
    self.m_popUi = nil;
    self.m_guildNode = nil;
    self.m_openType = nil;
    self.m_newCardsTab = nil;
    self.m_totalNum_tab = nil;
    self.c_id = nil;
    self.material_id = nil;
    self.m_data_cards = nil;
    self.m_readycards = nil;
    self.others = nil
    self.m_tab_dispatch = nil;
    self.m_dispatch_bossID = nil;--离线派遣当前的bossID
    self.m_data_dispatch = nil;--当前派遣出去的卡
end

--[[--
    返回
]]
function game_hero_select_pop.back(self,type)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_data:resetNewCardIdTab();
    if self.m_openType == 9 then
        local function responseMethod(tag,gameData)
            if gameData ~= nil and tolua.type(gameData) == "util_json" then
                local tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                self.m_itemOnClick("exchanged",self.m_tab_dispatch,tGameData);
                game_scene:removePopByName("game_hero_select_pop");
            end
        end
        local params = {}
        local str = ""
        params.boss_id = self.m_dispatch_bossID
        if self.m_tab_dispatch and next(self.m_tab_dispatch) then
            for k,v in pairs(self.m_tab_dispatch) do
                str = str .. v .. (k == game_util:getTableLen(self.m_tab_dispatch) and "" or "_")
            end
            params.align = str
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("offline_dispatch_set_alignment"), http_request_method.GET, params,"offline_dispatch_set_alignment")
    else
        game_scene:removePopByName("game_hero_select_pop");
    end
end
--[[--
    读取ccbi创建ui
]]
function game_hero_select_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            if self.m_btnCallFunc then
                self.m_btnCallFunc(target,event)
            end
            self:back();
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
    ccbNode:openCCBFile("ccb/ui_hero_list.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCLayerColor");--
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    self.m_title_label = ccbNode:labelBMFontForName("m_title_label")
    self.m_title_label:setString("Danh sách đồng đội")
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12);
    self.m_sort_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12);
    game_util:setControlButtonTitleBMFont(self.m_sort_btn)
    -- game_util:setCCControlButtonBackground(self.m_back_btn,"public_backNormal2.png","public_backDown2.png","public_backDown2.png");

    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScale(resolution_config:getScale())
    
    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-11,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end


--[[--
    创建英雄列表
]]
function game_hero_select_pop.createTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local selSortType = game_data:getCardSortType();
    game_data:cardsSortByTypeName(selSortType);
    local cardsCount = game_data:getCardsCount();
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 100, 120)
            -- spriteLand:ignoreAnchorPointForPosition(false);
            -- spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- cell:addChild(spriteLand)
            local ccbNode = game_util:createHeroListItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < cardsCount then
                m_spr_bg_up:setVisible(false);
                local itemData,_ = game_data:getCardDataByIndex(index+1);
                if itemData then
                    game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                end
                if not game_data:heroInTeamById(itemData.id) and self.m_guildNode == nil then
                    cell:setContentSize(itemSize);
                    self.m_guildNode = cell;
                end
            else
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            local itemData,_ = game_data:getCardDataByIndex(index+1);
            local card_id = itemData.id;
            if self.m_itemOnClick then
                self.m_itemOnClick(card_id);
                self:back();
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    创建英雄列表
]]
function game_hero_select_pop.createTableView2(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    -- game_data:cardsSortByTypeName(selSortType);
    -- self.m_newCardsTab,self.m_totalNum_tab[1],self.m_totalNum_tab[2],self.m_totalNum_tab[3],self.m_totalNum_tab[4],self.m_totalNum_tab[5],self.m_totalNum_tab[6] = game_data:getCardsDataSimple(nil,true)
    -- game_data:cardsSortByTypeNameWithTable(self.m_selSortType,self.m_newCardsTab)
    local showTab = {}
    showTab = self.m_newCardsTab
    -- for i=1,#self.m_newCardsTab do
    --     local id = self.m_newCardsTab[i]
    --     if not self.m_famousAllData[id] or self.m_famousAllData[id][2] == "" then 
    --         showTab[#showTab+1] = id
    --     end
    -- end
    local cardsCount = #showTab+1;

    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 100, 120)
            -- spriteLand:ignoreAnchorPointForPosition(false);
            -- spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- cell:addChild(spriteLand)
            local ccbNode = game_util:createHeroListItemByCCB3();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            local m_totalnum_lab1 = ccbNode:labelTTFForName("m_totalnum_lab1")
            local m_totalnum_lab2 = ccbNode:labelTTFForName("m_totalnum_lab2")
            if index ~= 0 then
                m_totalnum_lab1:setString("x" .. game_util:getTableLen(showTab[index]))
                m_totalnum_lab2:setString("x" .. game_util:getTableLen(showTab[index]))
            end
            if index < cardsCount then
                if index == 0 then
                    m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg2.png"))
                    m_spr_bg_up:setVisible(true);
                    ccbNode:nodeForName("m_info_node"):setVisible(false);
                else
                    m_spr_bg_up:setVisible(false);
                    local id = showTab[index][1]
                    local itemData,_ = game_data:getCardDataById(id)
                    if itemData then
                        -- if game_data:heroInTeamById(itemData.id) or game_data:heroInAssistantById(itemData.id) or game_data:godheroInTeamById(itemData.id) or game_data:godTempleheroInTeamById(itemData.id) then
                        --     m_totalnum_lab1:setVisible(false)
                        --     m_totalnum_lab2:setVisible(false)
                        -- else
                        --     game_util:setCailiaoNum(m_totalnum_lab1,m_totalnum_lab2,itemData.id,self.m_totalNum_tab[1],self.m_totalNum_tab[2],self.m_totalNum_tab[3],self.m_totalNum_tab[4],self.m_totalNum_tab[5],self.m_totalNum_tab[6])
                        --     -- game_util:setCailiaoNum(m_totalnum_lab2,itemData.id,self.m_totalNum_tab[1],self.m_totalNum_tab[2],self.m_totalNum_tab[3],self.m_totalNum_tab[4],self.m_totalNum_tab[5],self.m_totalNum_tab[6])
                        -- end

                        -- if m_itemDatas then
                        --     game_util:setHeroListItemInfoByTable3(ccbNode,m_itemDatas);
                        -- else
                            game_util:setHeroListItemInfoByTable3(ccbNode,itemData);
                        -- end

                    end
                    if not game_data:heroInTeamById(itemData.id) and self.m_guildNode == nil then
                        cell:setContentSize(itemSize);
                        self.m_guildNode = cell;
                    end
                end
            else
                m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg.png"))
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            
            if index == 0 then
                self.m_itemOnClick("unload",nil);
                self:back();
            else
                local bak_call_back_ = function()
                    -- self:refreshUi()
                    self:back()
                end
                game_scene:addPop("game_hero_lists",{num= index,itemOnClick = self.m_itemOnClick,m_numtep = self.m_numtep,bak_call_back = bak_call_back_});
                -- self:destroy();
            --     local itemData,_ = game_data:getCardDataById(showTab[index])
            --     local card_id = itemData.id;
            --     if self.m_itemOnClick then
            --         if game_data.getGuideProcess and game_data:getGuideProcess() == "second_enter_main_scene" then
            --             if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(37) end  -- 第一次点击阵型, 选择英雄 点击钢架 步骤37
            --         end
            --         self.m_itemOnClick("exchanged",card_id);
            --         self:back();
            --     end
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end
--[[--
    创建英雄列表  转世
]]
function game_hero_select_pop.createTableView3(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local selSortType = game_data:getCardSortType();
    game_data:cardsSortByTypeName(selSortType);
    local cardtab = {}
    cardtab = game_data:getCardsDataByEvoAndJinjie();
    local cardsCount = #cardtab
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 100, 120)
            -- spriteLand:ignoreAnchorPointForPosition(false);
            -- spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- cell:addChild(spriteLand)
            local ccbNode = game_util:createHeroListItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < cardsCount then
                m_spr_bg_up:setVisible(false);
                local itemData= cardtab[index+1]
                if itemData then
                    game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                end
                if not game_data:heroInTeamById(itemData.id) and self.m_guildNode == nil then
                    cell:setContentSize(itemSize);
                    self.m_guildNode = cell;
                end
            else
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            --local itemData,_ = cardtab[index+1].id
            local card_id = cardtab[index+1].id
            local dispatchCard = game_data:getDispatchCard()
            for k,v in pairs(dispatchCard) do
                if v == card_id then
                    game_util:addMoveTips({text = "Không thể chuyển thế thẻ đã cử trong nhiệm vụ anh hùng!"})
                    return
                end
            end
            if self.m_itemOnClick then
                self.m_itemOnClick(card_id);
                self:back();
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end
--[[--
    创建英雄列表
]]
function game_hero_select_pop.createTableView4(self,viewSize)
    local tempId = game_data:getZhuanshiCardId(id)
    local tempCardTable = game_data:getTableCardsData()
    local cardIdTable = {}
    for k,v in pairs(tempCardTable) do
        if not self.m_famousAllData[v] or self.m_famousAllData[v][2] == "" then 
        table.insert( cardIdTable, k )
        end
    end

    game_data:cardsSortByTypeNameWithTable("default",cardIdTable)

    local flag,k = game_util:idInTableById(tempId,cardIdTable)
    if flag then
        table.remove(cardIdTable,k)
        table.insert(cardIdTable,2,tempId)
    end

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local selSortType = game_data:getCardSortType();
    game_data:cardsSortByTypeName(selSortType);
    local cardsCount = game_data:getCardsCount() + 1;
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 100, 120)
            -- spriteLand:ignoreAnchorPointForPosition(false);
            -- spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- cell:addChild(spriteLand)
            local ccbNode = game_util:createHeroListItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < cardsCount then
                if index == 0 then
                    m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg2.png"))
                    m_spr_bg_up:setVisible(true);
                    ccbNode:nodeForName("m_info_node"):setVisible(false);
                else
                    m_spr_bg_up:setVisible(false);
                    -- local itemData,_ = game_data:getCardDataByIndex(index);

                    local cardId = cardIdTable[index]
                    local itemData,_ = game_data:getCardDataById(cardId);
                    if itemData then
                        game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                    end
                    if index == 2 then
                        local sp = ccbNode:spriteForName("m_zhuanshi_img")
                        sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_add_zhuanshi.png"))
                        sp:setVisible(true)
                        sp:setPosition(ccp(cell:getContentSize().width* 1+15,cell:getContentSize().height* 1+10))
                    else

                        local sp = ccbNode:spriteForName("m_zhuanshi_img")
                        sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_add_zhuanshi.png"))
                        sp:setVisible(false)
                    end
                    if not game_data:heroInTeamById(itemData.id) and self.m_guildNode == nil then
                        cell:setContentSize(itemSize);
                        self.m_guildNode = cell;
                    end
                end
            else
                m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg.png"))
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            if index == 0 then
                self.m_itemOnClick("unload",nil);
                self:back();
            else
                local card_id = cardIdTable[index]
                local itemData,_ = game_data:getCardDataById(card_id);
                if self.m_itemOnClick then
                    if game_data.getGuideProcess and game_data:getGuideProcess() == "second_enter_main_scene" then
                        if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(37) end  -- 第一次点击阵型, 选择英雄 点击钢架 步骤37
                    end
                    self.m_itemOnClick("exchanged",card_id);
                    self:back();
                end
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    创建英雄列表  召唤兽
]]
function game_hero_select_pop.createTableView5(self,viewSize)
    local tempCardTable = game_data:getCardsDataByCombinerTemple(self.c_id)
    local cardIdTable = {}
    for k,v in pairs(tempCardTable) do
        if not self.m_famousAllData[v] then 
            table.insert( cardIdTable, k )
        end
    end
    game_data:cardsSortByTypeNameWithTable("default",cardIdTable)

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local selSortType = game_data:getCardSortType();
    game_data:cardsSortByTypeName(selSortType);
    local cardsCount = #cardIdTable+1
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPageIndex = self.m_curPage;
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
                if index == 0 then
                    m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg2.png"))
                    m_spr_bg_up:setVisible(true);
                    ccbNode:nodeForName("m_info_node"):setVisible(false);
                else
                    m_spr_bg_up:setVisible(false);
                    local cardId = cardIdTable[index]
                    local itemData,_ = game_data:getCardDataById(cardId);
                    if itemData then
                        game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                    end
                    if tostring(self.material_id) == tostring(cardId) then
                        local m_team_img = ccbNode:spriteForName("m_team_img");
                        m_team_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_xuanze.png"))
                        m_team_img:setVisible(true)
                    end
                    
                    if not game_data:heroInTeamById(itemData.id) and self.m_guildNode == nil then
                        cell:setContentSize(itemSize);
                        self.m_guildNode = cell;
                    end
                end
            else
                m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg.png"))
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            if index == 0 then
                self.m_itemOnClick("unload",nil);
                self:back();
            else
                local card_id = cardIdTable[index]
                local itemData,_ = game_data:getCardDataById(card_id);
                if self.m_itemOnClick then
                    self.m_itemOnClick("exchanged",card_id);
                    self:back();
                end
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end
--[[--
    创建公会阵型英雄列表
]]
function game_hero_select_pop.createTableView7(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local selSortType = game_data:getCardSortType();
    game_data:cardsSortByTypeName(selSortType);
    local teamData = {};
    teamData = game_data:getGuildSelTeamData();
    local count = 0
    for k,v in pairs(teamData) do
        count = count + 1
    end
    local cardsCount = count;
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
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
                local itemData,_ = game_data:getGuildCardDataByIndex(index+1);
                if itemData then
                    game_util:setGuildHeroListItemInfoByTable(ccbNode,itemData);
                end
            else
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            local itemData,_ = game_data:getGuildCardDataByIndex(index+1);
            local card_id = itemData.id;
            if self.m_itemOnClick then
                
                self.m_itemOnClick("exchanged",card_id);
                self:back();
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    虫洞
]]
function game_hero_select_pop.createTableView10(self,viewSize)
    local usedcards  = {}
    for k,v in pairs(self.m_readycards) do
        usedcards[v] = 1
    end
    local showTab = {}
    for i=1,#self.m_data_cards do
        local id = self.m_data_cards[i]
        if not usedcards[id] then 
            showTab[#showTab+1] = id
        end
    end
    local cardsCount = #showTab+1;
    game_data:cardsSortByTypeNameWithTable(self.m_selSortType,showTab)
    
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)
    -- local otherCard = {}--不是当前选择的bossID派遣出去的卡
    -- if self.m_data_dispatch and next(self.m_data_dispatch) then
    --     for k,v in pairs(self.m_data_dispatch) do
    --         if tostring(k) ~= tostring(self.m_dispatch_bossID) then
    --             for i=1,game_util:getTableLen(v) do
    --                 table.insert(otherCard,v[i])
    --             end
    --         end
    --     end
    -- end
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createHeroListItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            local m_totalnum_lab1 = ccbNode:labelTTFForName("m_totalnum_lab1")
            local m_totalnum_lab2 = ccbNode:labelTTFForName("m_totalnum_lab2")
            if index < cardsCount then
                if index == 0 then
                    m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg2.png"))
                    m_spr_bg_up:setVisible(true);
                    ccbNode:nodeForName("m_info_node"):setVisible(false);
                else
                    m_spr_bg_up:setVisible(false);
                    local itemData,_ = game_data:getCardDataById(showTab[index])
                    if itemData then
                        if game_data:heroInTeamById(itemData.id) or game_data:heroInAssistantById(itemData.id) or game_data:godheroInTeamById(itemData.id) or game_data:godTempleheroInTeamById(itemData.id) then
                            m_totalnum_lab1:setVisible(false)
                            m_totalnum_lab2:setVisible(false)
                        else
                            -- game_util:setCailiaoNum(m_totalnum_lab1,m_totalnum_lab2,itemData.id,self.m_totalNum_tab[1],self.m_totalNum_tab[2],self.m_totalNum_tab[3],self.m_totalNum_tab[4],self.m_totalNum_tab[5],self.m_totalNum_tab[6])
                            -- game_util:setCailiaoNum(m_totalnum_lab2,itemData.id,self.m_totalNum_tab[1],self.m_totalNum_tab[2],self.m_totalNum_tab[3],self.m_totalNum_tab[4],self.m_totalNum_tab[5],self.m_totalNum_tab[6])
                        end
                        game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                    end
                    if not game_data:heroInTeamById(itemData.id) and self.m_guildNode == nil then
                        cell:setContentSize(itemSize);
                        self.m_guildNode = cell;
                    end
                end
                ccbNode:spriteForName("m_team_img"):setVisible(false)
                ccbNode:spriteForName("m_god_img"):setVisible(false)
                ccbNode:spriteForName("m_guild_img"):setVisible(false)
                ccbNode:spriteForName("m_bonusAdd_img"):setVisible(false)
                ccbNode:spriteForName("m_bonus_img"):setVisible(false)
                -- ccbNode:spriteForName("m_godTemple_img"):setVisible(false)
                ccbNode:spriteForName("m_zhuanshi_img"):setVisible(false)

            else
                m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg.png"))
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            if index == 0 then
                self.m_itemOnClick("unload",nil);
                self:back();
            else
                local itemData,_ = game_data:getCardDataById(showTab[index])
                local card_id = itemData.id;
                if self.m_itemOnClick then
                    self.m_itemOnClick("exchanged",card_id);
                    self:back();
                end
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    创建英雄列表  召唤兽
]]
function game_hero_select_pop.createTableView5(self,viewSize)
    local tempCardTable = game_data:getCardsDataByCombinerTemple(self.c_id)
    local cardIdTable = {}
    for k,v in pairs(tempCardTable) do
        table.insert( cardIdTable, v )
    end

    game_data:cardsSortByTypeNameWithTable("default",cardIdTable)

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local selSortType = game_data:getCardSortType();
    game_data:cardsSortByTypeName(selSortType);
    local cardsCount = #cardIdTable+1
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPageIndex = self.m_curPage;
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
                if index == 0 then
                    m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg2.png"))
                    m_spr_bg_up:setVisible(true);
                    ccbNode:nodeForName("m_info_node"):setVisible(false);
                else
                    m_spr_bg_up:setVisible(false);
                    local cardId = cardIdTable[index]
                    local itemData,_ = game_data:getCardDataById(cardId);
                    if itemData then
                        game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                    end
                    if tostring(self.material_id) == tostring(cardId) then
                        local m_team_img = ccbNode:spriteForName("m_team_img");
                        m_team_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_xuanze.png"))
                        m_team_img:setVisible(true)
                    end
                    
                    if not game_data:heroInTeamById(itemData.id) and self.m_guildNode == nil then
                        cell:setContentSize(itemSize);
                        self.m_guildNode = cell;
                    end
                end
            else
                m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg.png"))
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            if index == 0 then
                self.m_itemOnClick("unload",nil);
                self:back();
            else
                local card_id = cardIdTable[index]
                    -- cclog2(cardId,"cardId")
                local itemData,_ = game_data:getCardDataById(card_id);
                if self.m_itemOnClick then
                    self.m_itemOnClick("exchanged",card_id);
                    self:back();
                end
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end



--[[--
    创建英雄列表  新助威
]]
function game_hero_select_pop.createTableView6(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local selSortType = game_data:getCardSortType();
    game_data:cardsSortByTypeName(selSortType);
    local cardtab = {}
    local tempTab = game_data:getCardsDataByBonus(self.pos);
    for k,v in pairs(tempTab) do
        if not self.m_famousAllData[v] or self.m_famousAllData[v][2] == ""  then 
            table.insert( cardtab, v )
        end
    end
    game_data:cardsSortByTypeNameWithTable(selSortType,cardtab);
    local cardsCount = #cardtab+1;
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 100, 120)
            -- spriteLand:ignoreAnchorPointForPosition(false);
            -- spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- cell:addChild(spriteLand)
            local ccbNode = game_util:createHeroListItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < cardsCount then
                if index == 0 then
                    m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg2.png"))
                    m_spr_bg_up:setVisible(true);
                    ccbNode:nodeForName("m_info_node"):setVisible(false);
                else
                    m_spr_bg_up:setVisible(false);
                    local cardId = cardtab[index]
                    local itemData,_ = game_data:getCardDataById(cardId);
                    if itemData then
                      game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                    end
                    if not game_data:heroInTeamById(itemData.id) and self.m_guildNode == nil then
                        cell:setContentSize(itemSize);
                        self.m_guildNode = cell;
                    end
                end
            else
                m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg.png"))
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            if index == 0 then
                self.m_itemOnClick("unload",nil);
                self:back();
            else
               local card_id = cardtab[index]
               if self.m_itemOnClick then
                   self.m_itemOnClick("exchanged",card_id);
                   self:back();
               end
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    创建公会雇佣英雄列表
]]
function game_hero_select_pop.createTableView8(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    -- local selSortType = game_data:getCardSortType();
    -- game_data:cardsSortByTypeName(selSortType);
    local typeTable = {"default","quality","lv","profession"}
    game_data:cardsSortByTypeName3(typeTable[1]);
    local teamData = {};
    teamData = game_data:getTeamData();
    local cardsCount = game_data:getTeamCount();
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 100, 120)
            -- spriteLand:ignoreAnchorPointForPosition(false);
            -- spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- cell:addChild(spriteLand)
            local ccbNode = game_util:createHeroListItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < cardsCount then
                m_spr_bg_up:setVisible(false);
                local itemData,_ = game_data:getCardDataByIndex(index+1);
                if itemData then
                    game_util:setGuildHeroListItemInfoByTable(ccbNode,itemData);
                end
                
            else
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            local itemData,_ = game_data:getCardDataByIndex(index+1);
            local card_id = itemData.id;
            if self.m_itemOnClick then
                
                self.m_itemOnClick("exchanged",card_id);
                self:back();
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end
--[[--
    离线派遣
]]
function game_hero_select_pop.createTableView9(self,viewSize)
    local imgSelectTab = {}
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_guild_employ.plist");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    self.m_newCardsTab,self.m_totalNum_tab[1],self.m_totalNum_tab[2],self.m_totalNum_tab[3],self.m_totalNum_tab[4],self.m_totalNum_tab[5],self.m_totalNum_tab[6] = game_data:getCardsDataSimple(nil,true)
    game_data:cardsSortByTypeNameWithTable(self.m_selSortType,self.m_newCardsTab)
    local showTab = {}
    for i=1,#self.m_newCardsTab do
        local id = self.m_newCardsTab[i]
        if not self.m_famousAllData[id] or self.m_famousAllData[id][2] == "" then 
            showTab[#showTab+1] = id
        end
    end
    local cardsCount = #showTab+1;
    -- local cardsCount = #self.m_newCardsTab;
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)
    local otherCard = {}--不是当前选择的bossID派遣出去的卡
    if self.m_data_dispatch and next(self.m_data_dispatch) then
        for k,v in pairs(self.m_data_dispatch) do
            if tostring(k) ~= tostring(self.m_dispatch_bossID) then
                for i=1,game_util:getTableLen(v) do
                    table.insert(otherCard,v[i])
                end
            end
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 100, 120)
            -- spriteLand:ignoreAnchorPointForPosition(false);
            -- spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- cell:addChild(spriteLand)
            local ccbNode = game_util:createHeroListItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            local m_totalnum_lab1 = ccbNode:labelTTFForName("m_totalnum_lab1")
            local m_sel_img = ccbNode:spriteForName("m_sel_img")
            -- table.insert(imgSelectTab,m_sel_img)
            local m_totalnum_lab2 = ccbNode:labelTTFForName("m_totalnum_lab2")
            ccbNode:removeChildByTag(2222,true)
            local sprite_paiqian = CCSprite:createWithSpriteFrameName("guild_employ_yipaiqian.png")
            sprite_paiqian:setPosition(ccp(50,50))
            sprite_paiqian:setVisible(false)
            ccbNode:addChild(sprite_paiqian,222,2222)
            if index < cardsCount then
                m_spr_bg_up:setVisible(false);
                local itemData,_ = game_data:getCardDataById(self.m_newCardsTab[index+1])
                if itemData then
                    if game_data:heroInTeamById(itemData.id) or game_data:heroInAssistantById(itemData.id) or game_data:godheroInTeamById(itemData.id) or game_data:godTempleheroInTeamById(itemData.id) then
                        m_totalnum_lab1:setVisible(false)
                        m_totalnum_lab2:setVisible(false)
                    else
                        game_util:setCailiaoNum(m_totalnum_lab1,m_totalnum_lab2,itemData.id,self.m_totalNum_tab[1],self.m_totalNum_tab[2],self.m_totalNum_tab[3],self.m_totalNum_tab[4],self.m_totalNum_tab[5],self.m_totalNum_tab[6])
                        -- game_util:setCailiaoNum(m_totalnum_lab2,itemData.id,self.m_totalNum_tab[1],self.m_totalNum_tab[2],self.m_totalNum_tab[3],self.m_totalNum_tab[4],self.m_totalNum_tab[5],self.m_totalNum_tab[6])
                    end
                    game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                    if not game_data:heroInTeamById(itemData.id) and self.m_guildNode == nil then
                        cell:setContentSize(itemSize);
                        self.m_guildNode = cell;
                    end
                    local flag2,k2 = game_util:idInTableById(itemData.id,otherCard)
                    if flag2 then
                        sprite_paiqian:setVisible(true)
                    else
                        sprite_paiqian:setVisible(false)
                    end
                    local flag,k = game_util:idInTableById(itemData.id,self.m_tab_dispatch)
                    if flag then
                        m_sel_img:setVisible(true)
                    else
                        m_sel_img:setVisible(false)
                    end
                end
            else
                m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg.png"))
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local itemData,_ = game_data:getCardDataById(self.m_newCardsTab[index+1])
            local m_sel_img = ccbNode:spriteForName("m_sel_img")
            local card_id = itemData.id;
            local cailiaoCard1 = string.sub(card_id,1,3)
            local isCailiao = false
            if cailiaoCard1 == "50-" or cailiaoCard1 == "51-" or cailiaoCard1 == "52-" or cailiaoCard1 == "53-" or cailiaoCard1 == "54-" or cailiaoCard1 == "55-" then
                isCailiao = true
            end 
            if self.m_itemOnClick then
                local flag2,k2 = game_util:idInTableById(itemData.id,otherCard)
                local flag,k = game_util:idInTableById(card_id,self.m_tab_dispatch)
                if flag2 then
                    game_util:addMoveTips({text = "Thẻ đã bị cử ở đội hình khác"})
                elseif isCailiao then
                    game_util:addMoveTips({text = "Thẻ không thể cử"})
                elseif flag then
                    m_sel_img:setVisible(false)
                    -- imgSelectTab[index+1]:setVisible(false)
                    table.remove(self.m_tab_dispatch,k)
                elseif game_util:getTableLen(self.m_tab_dispatch) > 5 then
                    game_util:addMoveTips({text = "Tối đa chọn 6 thẻ"})
                else
                    -- imgSelectTab[index+1]:setVisible(true)
                    m_sel_img:setVisible(true)
                    table.insert(self.m_tab_dispatch,card_id)
                end
                -- self.m_itemOnClick("exchanged",card_id);
                -- self:back();
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    创建英雄列表
]]
function game_hero_select_pop.createTableView12(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local showTab = {}
    showTab = self.m_data_cards
    local cardsCount = #showTab+1;
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createHeroListItemByCCB3();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            local m_totalnum_lab1 = ccbNode:labelTTFForName("m_totalnum_lab1")
            local m_totalnum_lab2 = ccbNode:labelTTFForName("m_totalnum_lab2")
            m_totalnum_lab1:setVisible(false)
            m_totalnum_lab2:setString("X1")
            if index ~= 0 then

            end
            if index < cardsCount then
                if index == 0 then
                    m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg2.png"))
                    m_spr_bg_up:setVisible(true);
                    ccbNode:nodeForName("m_info_node"):setVisible(false);
                else
                    local id = showTab[index]
                    local itemData,_ = game_data:getCardDataById(id)
    
                    m_spr_bg_up:setVisible(false);
                    
                    if itemData then
                        game_util:setHeroListItemInfoByTable3(ccbNode,itemData);
                    end
                    if not game_data:heroInTeamById(itemData.id) and self.m_guildNode == nil then
                        cell:setContentSize(itemSize);
                        self.m_guildNode = cell;
                    end
                end
            else
                m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg.png"))
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            local card_id = showTab[index]
            if index == 0 then
                self.m_itemOnClick("unload",nil);
                self:back();
            else
                if self.m_itemOnClick then
                    self.m_itemOnClick("exchanged",card_id);
                    self:back();
                end 
            end  
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    创建英雄列表
]]
function game_hero_select_pop.createTableView13(self,viewSize)
    local tempId = game_data:getZhuanshiCardId(id)
    local tempCardTable = game_data:getTableCardsData()
    local cardIdTable = {}
    local cardIds = {}
    for k,v in pairs(tempCardTable) do
        if not self.m_famousAllData[v] or self.m_famousAllData[v][2] == "" then 
        table.insert( cardIds, k )
        end
    end

    game_data:cardsSortByTypeNameWithTable("default",cardIds)

    local flag,k = game_util:idInTableById(tempId,cardIds)
    if flag then
        table.remove(cardIds,k)
        table.insert(cardIds,2,tempId)
    end

    for i,v in ipairs(cardIds) do
        local c_id = self:split(v, '-')
        if tonumber(c_id[1]) == self.c_id then
            table.insert( cardIdTable, v )
        end
    end
    
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local selSortType = game_data:getCardSortType();
    game_data:cardsSortByTypeName(selSortType);
    local cardsCount = #cardIdTable + 1;
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 100, 120)
            -- spriteLand:ignoreAnchorPointForPosition(false);
            -- spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- cell:addChild(spriteLand)
            local ccbNode = game_util:createHeroListItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < cardsCount then
                if index == 0 then
                    m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg2.png"))
                    m_spr_bg_up:setVisible(true);
                    ccbNode:nodeForName("m_info_node"):setVisible(false);
                else
                    m_spr_bg_up:setVisible(false);
                    -- local itemData,_ = game_data:getCardDataByIndex(index);

                    local cardId = cardIdTable[index]
                    local itemData,_ = game_data:getCardDataById(cardId);
                    if itemData then
                        game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                    end
                    if index == 2 then
                        local sp = ccbNode:spriteForName("m_zhuanshi_img")
                        sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_add_zhuanshi.png"))
                        sp:setVisible(true)
                        sp:setPosition(ccp(cell:getContentSize().width* 1+15,cell:getContentSize().height* 1+10))
                    else

                        local sp = ccbNode:spriteForName("m_zhuanshi_img")
                        sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_add_zhuanshi.png"))
                        sp:setVisible(false)
                    end
                    if not game_data:heroInTeamById(itemData.id) and self.m_guildNode == nil then
                        cell:setContentSize(itemSize);
                        self.m_guildNode = cell;
                    end
                end
            else
                m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg.png"))
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            if index == 0 then
                self.m_itemOnClick("unload",nil);
                self:back();
            else
                local card_id = cardIdTable[index]
                local itemData,_ = game_data:getCardDataById(card_id);
                if self.m_itemOnClick then
                    if game_data.getGuideProcess and game_data:getGuideProcess() == "second_enter_main_scene" then
                        if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(37) end  -- 第一次点击阵型, 选择英雄 点击钢架 步骤37
                    end
                    self.m_itemOnClick("exchanged",card_id);
                    self:back();
                end
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    创建英雄列表
]]
function game_hero_select_pop.createTableView14(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");

    local showData = game_data:getBagCardsIdTable2()
    local showData = game_data:cidsToDatas(showData)
    showData = game_data:cardsSortByTypeNameWithTable3("default",{"1","2","3","4","5","6","7","8"},showData);

    local cardsCount = #showData
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
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
                if index == 0 then
                    m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg2.png"))
                    m_spr_bg_up:setVisible(true);
                    ccbNode:nodeForName("m_info_node"):setVisible(false);
                else
                    local itemId = showData[index][1]
                    local itemData,itemCfg = game_data:getCardDataById(itemId)
                    if itemData then
                        game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                    end
                    if not game_data:heroInTeamById(itemData.id) and self.m_guildNode == nil then
                        cell:setContentSize(itemSize);
                        self.m_guildNode = cell;
                    end
                end
            else
                m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg.png"))
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            if index == 0 then
                self.m_itemOnClick("unload",nil);
                self:back();
            else
                local bak_call_back_ = function()
                    self:back()
                end
                game_scene:addPop("game_hero_lists",{num= index,itemOnClick = self.m_itemOnClick, datas = showData,m_numtep = self.m_numtep,bak_call_back = bak_call_back_});
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end


--[[--
    刷新ui
]]
function game_hero_select_pop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    if self.m_openType == 2 then
        self.m_tableView = self:createTableView2(self.m_list_view_bg:getContentSize());
    elseif self.m_openType == 3 then
        self.m_tableView = self:createTableView3(self.m_list_view_bg:getContentSize());
    elseif self.m_openType == 4 then
        self.m_tableView = self:createTableView4(self.m_list_view_bg:getContentSize());
    elseif self.m_openType == 5 then
        self.m_tableView = self:createTableView5(self.m_list_view_bg:getContentSize());
    elseif self.m_openType == 6 then
        self.m_tableView = self:createTableView6(self.m_list_view_bg:getContentSize());
    elseif self.m_openType == 7 then
        self.m_tableView = self:createTableView7(self.m_list_view_bg:getContentSize());
    elseif self.m_openType == 8 then
        self.m_tableView = self:createTableView8(self.m_list_view_bg:getContentSize());
    elseif self.m_openType == 9 then
        self.m_tableView = self:createTableView9(self.m_list_view_bg:getContentSize());
    elseif self.m_openType == 10 then
        self.m_tableView = self:createTableView10(self.m_list_view_bg:getContentSize());
    elseif self.m_openType == 12 then
        self.m_tableView = self:createTableView12(self.m_list_view_bg:getContentSize());
    elseif self.m_openType == 13 then
        self.m_tableView = self:createTableView13(self.m_list_view_bg:getContentSize());
    elseif self.m_openType == 14 then
        self.m_tableView = self:createTableView14(self.m_list_view_bg:getContentSize());
    else
        self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    end
    self.m_list_view_bg:addChild(self.m_tableView);
end

function game_hero_select_pop.split(self,s, p)
    if not s then
        return ""
    end
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end

--[[--
    初始化
]]
function game_hero_select_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_newCardsTab = {}
    self.m_selSortType = "default";
    self.m_selSortType2 = {"1","2","3","4","5","6","7","8"}
    self.m_newCardsTab = game_data:cardsSortByTypeName2(self.m_selSortType,self.m_selSortType2);
    self.m_totalNum_tab = {}
    self.others = others
    -- body
    self.m_fromUi = t_params.fromUi;
    self.m_selSortType = "lv";
    self.m_btnCallFunc = t_params.btnCallFunc;
    self.m_itemOnClick = t_params.itemOnClick;
    self.m_openType = t_params.openType or 1;
    self.c_id = t_params.material_cid or nil;
    self.material_id = t_params.material_id or nil;
    self.pos = t_params.pos or nil
    self.m_dispatch_bossID = t_params.bossId or nil;
    self.m_data_dispatch = t_params.dispatch_data or {};
    self.m_tab_dispatch = self.m_data_dispatch[tostring(self.m_dispatch_bossID)] or {};
    cclog2(self.m_tab_dispatch,"  x-------------")
    self.m_famousAllData = game_data:getFamousAllData()

    self.m_data_cards = t_params.data
    self.m_readycards = t_params.readycards
end

--[[--
    创建ui入口并初始化数据
]]
function game_hero_select_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    local id = game_guide_controller:getCurrentId();
    if id == 20 and self.m_guildNode then
        game_guide_controller:gameGuide("show","1",21,{tempNode = self.m_guildNode})
    end
    return self.m_popUi;
end

return game_hero_select_pop;