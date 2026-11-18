---  英雄列表  

local game_hero_lists = {
    m_list_view_bg = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_tableView = nil,
    m_btnCallFunc = nil,
    m_itemOnClick = nil,
    m_title_label = nil,
    m_curPage = nil,
    m_curPage2 = nil,
    m_ok_btn = nil,
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
    m_newCardsTab = nil,
    m_totalNum_tab = nil,
    num = nil,
    m_openIndex = nil,
    m_itemOnClick = nil,
    m_numtep = nil,
    isDirty = false,

};
--[[--
    销毁
]]
function game_hero_lists.destroy(self)
    -- body
    cclog("-----------------game_hero_lists destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_tableView = nil;
    self.m_btnCallFunc = nil;
    self.m_itemOnClick = nil;
    self.m_title_label = nil;
    self.m_curPage = nil;
    self.m_curPage2 = nil;
    self.m_ok_btn = nil;
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
    self.m_newCardsTab = nil;
    self.m_totalNum_tab = nil;
    self.num = nil;
    self.m_openIndex = nil;
    self.m_itemOnClick = nil;
    self.m_numtep = nil;
    self.isDrity = false
end

--[[--
    返回
]]
function game_hero_lists.back(self,type)
    game_data:resetNewCardIdTab();
    if self.bak_call_back then
        self.bak_call_back()
    end
    game_scene:removePopByName("game_hero_lists")
    
end
--[[--
    读取ccbi创建ui
]]
function game_hero_lists.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then 
            if self.isDrity then
                self.isDrity = false
                if self.endCb then
                    self.endCb()
                end
            end
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_list_new2.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCLayerColor");--
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 14)
    self.m_ccbNode = ccbNode;
    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-13,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--

]]
function game_hero_lists.removePop(self)
    if self.m_popUi then
        self.m_popUi:removeFromParentAndCleanup(true);
        self.m_popUi = nil;
    end
end

--[[--

]]


--[[--
    创建英雄列表
]]
function game_hero_lists.createTableView(self,viewSize)   
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local sorttype = game_data:getCardSortType()
    local sorttype2 = game_data:getCardSortType2()
    local cardData2 = game_data:cardsSortByTypeName2(sorttype,sorttype2)
    if self.datas then
        cardData2 = self.datas
    end
    local cardsCount = game_util:getTableLen(cardData2[self.num])
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-14;
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
            local nd_storeHouseAdd = ccbNode:nodeForName("nd_storeHouseAdd")
            nd_storeHouseAdd:setVisible(false)
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            local m_totalnum_lab1 = ccbNode:labelTTFForName("m_totalnum_lab1")
            local m_totalnum_lab2 = ccbNode:labelTTFForName("m_totalnum_lab2")
            if index < cardsCount then
                if index == 0 then
                    self.m_sel_index_1 = ccbNode
                    self.m_sel_index_2 = ccbNode
                    self.m_sel_index_3 = ccbNode
                end
                m_spr_bg_up:setVisible(false);
                local id = cardData2[self.num][index+1]
                local itemData,_ = game_data:getCardDataById(id)
                if itemData then
                    if itemData["c_id"] == 38200 then 
                    end
                    game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                    if self.m_tGodTeamData then
                        self:setGodHeroListItemInfoByTable(ccbNode,itemData);
                    end
                    
                    local m_new_icon = ccbNode:spriteForName("m_new_icon")
                    if game_data:isNewCardFlagById(itemData.id) then
                        m_new_icon:setVisible(true);
                    else
                        m_new_icon:setVisible(false);
                    end                
                    if (itemData["c_id"] == 74500 or  itemData["c_id"] == 74600 or itemData["c_id"] == 74700 or itemData["c_id"]== 74800 )and itemData.lv>1 then
                        local function onBtnCilck( event,target )
                            game_scene:enterGameUi("game_hero_inherit",{cnm=game_data:getCailiaoCardTab()[index+1]});
                        end
                        local size=ccbNode:getContentSize();
                        local button = game_util:createCCControlButton2("public_btnRed.png","Lấy ra",onBtnCilck,GLOBAL_TOUCH_PRIORITY-110,12)
                        button:setAnchorPoint(ccp(0.5,0.5))
                        button:setPosition(ccp(size.width/2,size.height/2));
                        ccbNode:addChild(button,100,100)
                        --button:setVisible(true)
                    else
                        ccbNode:removeChildByTag(100,true)
                        --button:setVisible(false)
                    end

                    if not game_data:heroInTeamById(itemData.id) and self.m_guildNode == nil then
                        cell:setContentSize(itemSize);
                        self.m_guildNode = cell;
                    end

                    local heroDataTable = itemData;
                    -- 存入功能 -- 上阵、助阵、命运、阵法、时光屋、神域阵型、名人堂 锁定 虫洞
                    local canStore = true
                    -- 上阵检查
                    if game_data:heroInTeamById(heroDataTable.id) then
                        canStore = false
                    end
                    -- 助阵
                    if game_data:heroInAssistantById(heroDataTable.id) then
                        canStore = false
                    end
                    -- 训练
                    if game_util:getCardTrainingFlag(heroDataTable) then
                        canStore = false
                    end
                    -- 锁定检查
                    if game_util:getCardUserLockFlag(heroDataTable) then
                        canStore = false
                    end
                    -- 名人堂
                    if game_data:isInFamousById(heroDataTable.id) then
                        canStore = false
                    end
                    -- 神域
                    if game_data:godheroInTeamById(heroDataTable.id) then
                        canStore = false
                    end
                    -- 佣兵营地
                    if heroDataTable.dispatch then
                        canStore = false
                    end
                    -- 出征卡
                    if game_util:getCarddispatchFlag(heroDataTable) then
                        canStore = false
                    end
                    -- 阵法
                    if game_util:isInFormationBonus2(heroDataTable.id) then
                        canStore = false
                    end
                    -- 命运
                    local isDestiny = false;
                    for k, v in pairs(game_data:getDestiny()) do
                        if v == heroDataTable.id then
                            isDestiny = true;
                            break;
                        end
                    end
                    if isDestiny then
                        canStore = false
                    end
                    -- 虫洞
                    for k1, v1 in pairs(game_data.m_wormholes_field or {}) do
                        local wormholes_formation = v1.wormholes_formation or {}
                        for k2, v2 in pairs(wormholes_formation) do
                            if v2 == heroDataTable.id then
                                canStore = false
                            end
                        end
                    end
                    
                    nd_storeHouseAdd:setVisible(canStore and self.storeHouseType == "storeHouse_save")
                    if canStore then
                        local btn_store = ccbNode:controlButtonForName("btn_store")
                        btn_store:addHandleOfControlEvent(
                            function()
                                cclog("[storeHouse] 点击角色存入仓库按钮")
                                local function responseMethod(tag,gameData)
                                    game_util:addMoveTips({text = "Cất vào thành công!"})
                                    local sorttype = game_data:getCardSortType()
                                    local sorttype2 = game_data:getCardSortType2()
                                    local cardData2 = game_data:cardsSortByTypeName2(sorttype,sorttype2)
                                    if self.datas then
                                        cardData2 = self.datas
                                    end
                                    local cardsCount = game_util:getTableLen(cardData2[self.num])
                                    if cardsCount == 0 then
                                        if self.endCb then
                                            self.endCb()
                                        end
                                        self:back();
                                    else
                                        self.isDrity = true
                                        self:refreshUi();
                                    end
                                end
                                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("storehouse_store_card"), http_request_method.GET,{card_ids = heroDataTable.id},"storehouse_store_card")
                            end
                        ,CCControlEventTouchUpInside);
                        btn_store:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 14)
                    end
                end
            else
                if index == 0 then
                    self.m_sel_index_1 = ccbNode
                    self.m_sel_index_2 = ccbNode
                    self.m_sel_index_3 = ccbNode
                end
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
            local itemData,_ = game_data:getCardDataById(cardData2[self.num][index+1])
            local card_id = itemData.id;
            local tempid = string.sub(itemData.id,1,3)     
            if game_data:godTempleheroInTeamById(card_id)  then
                game_util:addMoveTips({text = "Đang thu thập không thể ra trận"})
            elseif tempid == "50-" or tempid == "51-" or tempid == "52-" or tempid == "53-" or tempid == "54-" or tempid == "55-" then
                game_util:addMoveTips({text = "Thẻ tài liệu không thể ra trận"})
            else
                if self.m_itemOnClick then
                    if game_data.getGuideProcess and game_data:getGuideProcess() == "second_enter_main_scene" then
                        if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(37) end  -- 第一次点击阵型, 选择英雄 点击钢架 步骤37
                    end
                    self.m_itemOnClick("exchanged",card_id);
                    self:back();
                else
                    local function callBack(typeName)
                        typeName = typeName or ""
                        if typeName == "refresh" then
                            self:refreshUi();
                        end
                    end
                    game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 1,callBack = callBack})
                end         
            end
        end

    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

function game_hero_lists.setGodHeroListItemInfoByTable(self,ccbNode,heroDataTable)
    local cardId = heroDataTable.c_id;
    -- cclog("cardId ===" .. tostring(cardId))
    local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(cardId);
    if itemConfig then
        ccbNode:nodeForName("m_info_node"):setVisible(true);
    else
        ccbNode:nodeForName("m_info_node"):setVisible(false);
        return
    end
    if itemConfig:getNodeWithKey("is_skin") then
        if itemConfig:getNodeWithKey("is_skin"):toInt() ~= 0 then
            local skinID = itemConfig:getNodeWithKey("is_skin"):toInt()
            local flag = game_util:isWearSkin(skinID)
            if flag then
                local character_detail_cfg = getConfig(game_config_field.character_detail);
                itemConfig = character_detail_cfg:getNodeWithKey(tostring(skinID));
            end
        end
    end
    local wake_lv = heroDataTable.bre
    tolua.cast(ccbNode:objectForName("m_level_label"),"CCLabelBMFont"):setString("Lv." .. heroDataTable.lv .. "/" .. heroDataTable.level_max);
    local m_anim_node = tolua.cast(ccbNode:objectForName("m_anim_node"),"CCNode");
    m_anim_node:removeAllChildrenWithCleanup(true);
    -- local m_name_label = ccbNode:labelBMFontForName("m_name_label");
    local m_name_label = ccbNode:labelTTFForName("m_name_label");
    -- self:setHeroNameColorByQuality(m_name_label,itemConfig);
    local quality = itemConfig:getNodeWithKey("quality"):toInt();
    local super_quality_1 = heroDataTable.super_quality_1 or 0
    local hero_quality_item = super_quality_1 > 0 and HERO_QUALITY_COLOR_TABLE_2[super_quality_1] or HERO_QUALITY_COLOR_TABLE[quality+1]
    if hero_quality_item then
        ccbNode:spriteForName("m_spr_bg"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(hero_quality_item.card_img));
    end
    local name_after = game_util:getCardName(heroDataTable,itemConfig)
    m_name_label:setString(name_after);
    local animation = itemConfig:getNodeWithKey("animation"):toStr();
    local rgb = itemConfig:getNodeWithKey("rgb_sort"):toInt();

    local animNode = game_util:createImgByName("image_" .. animation,rgb,nil,nil,wake_lv,itemConfig)
    -- local animNode = game_util:createPauseAnim(animation,0,heroDataTable,itemConfig);
    -- cclog("setHeroListItemInfoByTable animNode == " .. tostring(animNode))
    if animNode then
        local animNodeSize = animNode:getContentSize();
        -- local ccbNodeSize = ccbNode:getContentSize();
        -- local scale = math.min(1,animNodeSize.height~=0 and 70/animNodeSize.height or 1);
        -- animNode:setScale(scale);
        animNode:setAnchorPoint(ccp(0.5,0));
        m_anim_node:addChild(animNode);
        -- m_anim_node:getParent():reorderChild(m_anim_node,-1);
    end

    local m_famous_icon = ccbNode:spriteForName("m_famous_icon")
    local flag = game_data:isInFamousById(heroDataTable.id)
    if m_famous_icon then
        m_famous_icon:setVisible(flag)
    end
    local m_sel_img = ccbNode:spriteForName("m_sel_img")
    m_sel_img:setVisible(false)
    local m_team_img = ccbNode:spriteForName("m_team_img")
    local team_flag = self:heroInTeamById(heroDataTable.id)
    local team_index = 0;

    local m_godTemple_img = ccbNode:spriteForName("m_godTemple_img")
    if game_data:godTempleheroInTeamById(heroDataTable.id) then
       m_godTemple_img:setVisible(true)
    else
       m_godTemple_img:setVisible(false)
    end
    if team_flag == true then
        team_flag,team_index = self:heroInTeamById(heroDataTable.id)
        -- cclog2(team_index,"team_index======")
    end
    if  team_flag == true and team_index == 1 then
        m_team_img:setVisible(true);
        m_team_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_played_god1.png"));
    elseif team_flag == true and team_index == 2 then
        m_team_img:setVisible(true);
        m_team_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_played_god2.png"));
    elseif team_flag == true and team_index == 3 then
        m_team_img:setVisible(true);
        m_team_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_played_god3.png"));
    else
          m_team_img:setVisible(false);
    end
    local lockFlag = game_util:getCardUserLockFlag(heroDataTable);
    ccbNode:spriteForName("m_lock_img"):setVisible(lockFlag);
    local m_perfect_img = ccbNode:spriteForName("m_perfect_img")
    m_perfect_img:setVisible(false);
    local bre = math.min(heroDataTable.bre or 0,10)
    local tempSpriteFrame = nil;
    if bre > 5 then
        tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_moon_icon.png")
        bre = bre - 5
    else
        tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_equip_star.png")
    end
    for i=1,5 do
        local m_star_icon = ccbNode:spriteForName("m_star_icon_" .. i)
        if tempSpriteFrame then
            m_star_icon:setDisplayFrame(tempSpriteFrame)
        end
        if i <= bre then
            m_star_icon:setVisible(true);
        else
            m_star_icon:setVisible(false);
        end
    end

    local m_occupation_icon = ccbNode:spriteForName("m_occupation_icon")
    local occupation_cfg = getConfig(game_config_field.occupation);
    local occupation_item_cfg = occupation_cfg:getNodeWithKey(animation)
    if occupation_item_cfg then
        local occupationType = occupation_item_cfg:toInt();
        local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupationType .. ".png")
        if spriteFrame then
            m_occupation_icon:setDisplayFrame(spriteFrame);
        else
            m_occupation_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation5.png"));
        end
    else
        m_occupation_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation5.png"));
    end
    local m_occupation_icon_bg = ccbNode:spriteForName("m_occupation_icon_bg")
    local spriteFrame = super_quality_1 > 0 and CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_race_bg_2.png") or CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_race_bg.png")
    if m_occupation_icon_bg and spriteFrame then
        m_occupation_icon_bg:setDisplayFrame(spriteFrame);
    end
end

--[[--
    判断英雄是否在编队中
]]
function game_hero_lists.heroInTeamById(self,heroId)
    for i=1,3 do
        for k,v in pairs(self.m_tGodTeamData[tostring(i)]) do
            if v ~= "-1" and tostring(v) == tostring(heroId) then
                return true , i;
            end
        end
    end
    
    return false;
end

--[[--

]]
function game_hero_lists.refreshTab1(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tableView);
    local id = game_guide_controller:getCurrentId()
    if id == 9003 then
        game_guide_controller:showGuide("90",9004,{tempNode = self.m_sel_index_1})
    elseif id == 9007 then
        game_guide_controller:showGuide("90",9008,{tempNode = self.m_sel_index_2})
    elseif id == 9011 then
        game_guide_controller:showGuide("90",9012,{tempNode = self.m_sel_index_3})
    end
end



--[[--

]]
function game_hero_lists.refreshTabBtn(self)
    local flag1 = self.m_showIndex == 1 and true or false
    local flag2 = self.m_showIndex == 2 and true or false
    if self.m_showIndex == 1 then
        self:refreshTab1();
    end
end

--[[--
    刷新ui
]]
function game_hero_lists.refreshUi(self)
    self:refreshTabBtn();
end


--[[--
    初始化
]]
function game_hero_lists.init(self,t_params)
    t_params = t_params or {};
    self.num  = t_params.num 
    self.endCb = t_params.endCb
    self.datas = t_params.datas
    self.m_itemOnClick = t_params.itemOnClick
    self.m_tGodTeamData = t_params.m_tGodTeamData
    -- self.m_newCardsTab = game_data:getCailiaoCardTab()
    self.m_totalNum_tab = {}
    -- body

    self.m_showIndex = t_params.showIndex or 1;
    self.m_zhuanshiData = t_params.zhuanshiData or {}
    self.m_material_id_table = {};
    self.m_is_notice = 0;
    self.m_numtep = t_params.m_numtep or "";
    self.bak_call_back = t_params.bak_call_back
    self.m_famousAllData = game_data:getFamousAllData()
    self.storeHouseType = t_params.storeHouseType 
end

--[[--
    创建ui入口并初始化数据
]]
function game_hero_lists.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    -- local scene = CCScene:create();
    -- scene:addChild(self:createUi());
    self:refreshUi();
    local id = game_guide_controller:getCurrentId();
    if id == 21 and self.m_guildNode then
        game_guide_controller:gameGuide("show","1",21,{tempNode = self.m_guildNode,isShowMask = true})
    end
    return self.m_popUi;
end

return game_hero_lists;