---  弹框选择

local game_god_hero_select_pop = {
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
    m_tCardsIdTable = {},
    m_tGodTeamData = nil,
    m_newCardsTab = nil,
    m_totalNum_tab = nil,
};
--[[--
    销毁
]]
function game_god_hero_select_pop.destroy(self)
    -- body
    cclog("-----------------game_god_hero_select_pop destroy-----------------");
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
    self.m_tCardsIdTable = nil;
    self.m_tGodTeamData = nil; --已装备id
    self.m_newCardsTab = nil;
    self.m_totalNum_tab = nil;

end

--[[--
    返回
]]
function game_god_hero_select_pop.back(self,type)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    -- game_data:resetNewCardIdTab();
    game_scene:removePopByName("game_god_hero_select_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_god_hero_select_pop.createUi(self)
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
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCLayerColor");--
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    local m_func_btn = ccbNode:controlButtonForName("m_func_btn")
    m_func_btn:setVisible(false)
    self.m_title_label = ccbNode:labelBMFontForName("m_title_label")
    self.m_title_label:setString("伙伴列表")
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12);
    self.m_sort_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12);
    game_util:setControlButtonTitleBMFont(self.m_sort_btn)
    -- game_util:setCCControlButtonBackground(self.m_back_btn,"public_backNormal2.png","public_backDown2.png","public_backDown2.png");

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
function game_god_hero_select_pop.createTableView(self,viewSize)

end

--[[--
    创建英雄列表
]]
function game_god_hero_select_pop.createTableView2(self,viewSize)
    local noTouchCardTab = {}
    local tempCardTab = {}
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    self.m_newCardsTab,self.m_totalNum_tab[1],self.m_totalNum_tab[2],self.m_totalNum_tab[3],self.m_totalNum_tab[4],self.m_totalNum_tab[5],self.m_totalNum_tab[6] = game_data:getCardsDataSimple(nil,true)
    game_data:cardsSortByTypeNameWithTable(self.m_selSortType,self.m_newCardsTab)
    -- local cardsCount = #self.m_newCardsTab+1;
    local showTab = {}
    for i=1,#self.m_newCardsTab do
        local id = self.m_newCardsTab[i]
        if not self.m_famousAllData[id] or self.m_famousAllData[id][2] == "" then 
            showTab[#showTab+1] = id
        end
    end
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
            local ccbNode = game_util:createHeroListItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_totalnum_lab1 = ccbNode:labelTTFForName("m_totalnum_lab1")
            local m_totalnum_lab2 = ccbNode:labelTTFForName("m_totalnum_lab2")
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < cardsCount then
                if index == 0 then
                    m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg2.png"))
                    m_spr_bg_up:setVisible(true);
                    ccbNode:nodeForName("m_info_node"):setVisible(false);
                else
                    m_spr_bg_up:setVisible(false);
                    local itemData,_ = game_data:getCardDataById(self.m_newCardsTab[index])
                    -- cclog2(itemData,"itemData====435345435========")
                    if itemData then
                        if game_data:heroInTeamById(itemData.id) or game_data:heroInAssistantById(itemData.id) or game_data:godheroInTeamById(itemData.id) or game_data:godTempleheroInTeamById(itemData.id) then
                            m_totalnum_lab1:setVisible(false)
                            m_totalnum_lab2:setVisible(false)
                        else
                            game_util:setCailiaoNum(m_totalnum_lab1,m_totalnum_lab2,itemData.id,self.m_totalNum_tab[1],self.m_totalNum_tab[2],self.m_totalNum_tab[3],self.m_totalNum_tab[4],self.m_totalNum_tab[5],self.m_totalNum_tab[6])
                            -- game_util:setCailiaoNum(m_totalnum_lab2,itemData.id,self.m_totalNum_tab[1],self.m_totalNum_tab[2],self.m_totalNum_tab[3],self.m_totalNum_tab[4],self.m_totalNum_tab[5],self.m_totalNum_tab[6])
                        end
                        self:setGodHeroListItemInfoByTable(ccbNode,itemData);
                    end
                    if not self:heroInTeamById(itemData.id) and self.m_guildNode == nil then
                        cell:setContentSize(itemSize);
                        self.m_guildNode = cell;
                    end
                    if m_totalnum_lab2:isVisible() == true then
                        noTouchCardTab[itemData.id] = 1
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
                local itemData,_ = game_data:getCardDataById(self.m_newCardsTab[index])
                local card_id = itemData.id;
                local tempid = string.sub(itemData.id,1,3)
                -- local tempid = string.sub(card_id,1,3）

                if game_data:godTempleheroInTeamById(card_id)  then
                   game_util:addMoveTips({text = "Đang sưu tập không thể ra trận"})
                elseif tempid == "50-" or tempid == "51-" or tempid == "52-" or tempid == "53-" or tempid == "54-" or tempid == "55-" then
                    game_util:addMoveTips({text = "Tài nguyên lag không thể ra trận"})
                else
                   if self.m_itemOnClick then
                       self.m_itemOnClick("exchanged",card_id);
                       self:back();
                   end
                end
                
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

function game_god_hero_select_pop.setGodHeroListItemInfoByTable(self,ccbNode,heroDataTable)
    local cardId = heroDataTable.c_id;
    -- cclog("cardId ===" .. tostring(cardId))
    local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(cardId);
    if itemConfig then
        ccbNode:nodeForName("m_info_node"):setVisible(true);
    else
        ccbNode:nodeForName("m_info_node"):setVisible(false);
        return
    end
    local wake_lv = heroDataTable.bre
    tolua.cast(ccbNode:objectForName("m_level_label"),"CCLabelBMFont"):setString("Lv." .. heroDataTable.lv .. "/" .. heroDataTable.level_max);
    local m_anim_node = tolua.cast(ccbNode:objectForName("m_anim_node"),"CCNode");
    m_anim_node:removeAllChildrenWithCleanup(true);
    -- local m_name_label = ccbNode:labelBMFontForName("m_name_label");
    local m_name_label = ccbNode:labelBMFontForName("m_name_label");
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
    local m_sel_img = ccbNode:spriteForName("m_sel_img")
    m_sel_img:setVisible(false)
    local m_team_img = ccbNode:spriteForName("m_team_img")
    local team_flag = self:heroInTeamById(heroDataTable.id)
    local team_index = 0;

    -- local m_godTemple_img = ccbNode:spriteForName("m_godTemple_img")
    -- if game_data:godTempleheroInTeamById(heroDataTable.id) then
    --    m_godTemple_img:setVisible(true)
    -- else
    --    m_godTemple_img:setVisible(false)
    -- end
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
function game_god_hero_select_pop.heroInTeamById(self,heroId)
    for i=1,3 do
        for k,v in pairs(self.m_tGodTeamData[tostring(i)]) do
            -- cclog2(self.m_tGodTeamData[i],"self.m_tGodTeamData[i]====22=333=")
            if v ~= "-1" and tostring(v) == tostring(heroId) then
                -- cclog2(i,"i======")
                return true , i;
            end
        end
    end
    
    return false;
end

--[[--
    刷新ui
]]
function game_god_hero_select_pop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    if self.m_openType == 2 then
        self.m_tableView = self:createTableView2(self.m_list_view_bg:getContentSize());
    else
        self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    end
    self.m_list_view_bg:addChild(self.m_tableView);
end


--[[--
    初始化
]]
function game_god_hero_select_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_newCardsTab = {}
    self.m_totalNum_tab = {}
    self.m_fromUi = t_params.fromUi;
    self.m_selSortType = "lv";
    self.m_btnCallFunc = t_params.btnCallFunc;
    self.m_itemOnClick = t_params.itemOnClick;
    self.m_openType = t_params.openType or 1;
    self.m_tCardsIdTable = {};
    self.m_tGodTeamData = t_params.m_tGodTeamData;
    self.m_famousAllData = game_data:getFamousAllData()

    -- cclog2(self.m_tGodTeamData,"self.m_tGodTeamDatae12124====")
end

--[[--
    创建ui入口并初始化数据
]]
function game_god_hero_select_pop.create(self,t_params)
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

return game_god_hero_select_pop;