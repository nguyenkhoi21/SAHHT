--- 命运符文
local game_fate_rune = {
  
    m_ccbNode = nil,
    m_curPage = nil,
    m_root_layer = nil,
    m_hero_node_list = nil,
    m_rune_node_list = nil,
    m_itemTab = nil,
    m_data = nil,
    m_fuwenshi_label = nil,
    m_fuwenshi_label2 = nil,
    m_gold_label = nil,
    m_gold_label2 = nil,
    m_anim_node = nil,
    m_name_label = nil,
    m_race_label = nil,
    m_new_lv_label = nil,
    m_occupation_icon = nil,
    m_occupation_icon2 = nil,
    m_img_2 = nil,
    m_pos = nil,
    m_isLock_Tab = nil,
    m_color_tab = nil,
    fate_rune_tab = nil,
    level_tab = nil,
};
--[[--
    销毁ui
]]
function game_fate_rune.destroy(self)
    -- body
    cclog("-----------------game_fate_rune destroy-----------------");
  
    self.m_curPage = nil;
    self.m_ccbNode = nil;
    self.m_root_layer = nil;
    self.m_hero_node_list = nil;
    self.m_rune_node_list = nil;
    self.m_itemTab = nil;
    self.m_data = nil;
    self.m_fuwenshi_label = nil;
    self.m_fuwenshi_label2 = nil;
    self.m_gold_label = nil;
    self.m_gold_label2 = nil;
    self.m_anim_node = nil;
    self.m_name_label = nil;
    self.m_race_label = nil;
    self.m_new_lv_label = nil;
    self.m_occupation_icon = nil;
    self.m_occupation_icon2 = nil;
    self.m_img_2 = nil;
    self.m_pos = nil;
    self.m_isLock_Tab = nil;
    self.m_color_tab = nil;
    self.fate_rune_tab = nil;
    self.level_tab = nil;
end
--[[--
    返回
]]
function game_fate_rune.back(self,backType)
    if backType == "back" then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui    equipSortByTypeName
]]
function game_fate_rune.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 11 then--更换英雄
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) 
                local btnCallFunc = function( target,event )   
                end
                local itemOnClick = function (typeName,id)
                    if typeName == "exchanged" then
                        local params = {}
                        params.pos = self.m_pos
                        params.card_id = id
                        local function responseMethod(tag,gameData)
                            local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) 
                            self.m_data = data
                            --cclog2(self.m_data,"self.m_data")
                            self:removeCard()
                            self:createCard()
                            self:selectCellState(self.m_pos-1)
                            self:refreshUi()
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("fate_rune_set_cards"), http_request_method.GET, params,"fate_rune_set_cards")
                       
                    elseif typeName == "unload" then
                        local params = {}
                        params.pos = self.m_pos
                        params.card_id = ""
                        local function responseMethod(tag,gameData)
                            local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) 
                            self.m_data = data
                            self:removeCard()
                            self:removeIcon()
                            self:refreshUi()
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("fate_rune_set_cards"), http_request_method.GET, params,"fate_rune_set_cards")
                        
                    end
                end
                game_scene:addPop("game_hero_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,data = data.cards_info,openType = 12})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("fate_rune_get_cards"), http_request_method.GET, nil,"fate_rune_get_cards")
        elseif btnTag == 22 then --符文查询
            
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) 
                game_scene:addPop("game_fate_rune_data_pop",{gameData = data,pos = self.m_pos})   --
            end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_fate_rune_query"), http_request_method.GET, params,"cards_fate_rune_query")
        elseif btnTag == 33 then -- 刷新
            local callBackFunc = function()
                local params = {}
                params.pos = self.m_pos
                local function responseMethod(tag,gameData)
                    local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) 
                    self.m_data = data
        
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_refresh_fate_rune"), http_request_method.GET, params,"cards_refresh_fate_rune")
            end
            for k,v in pairs(self.m_data["fate_rune_data"][tostring(self.m_pos)]) do
                if type(v)== "table" and v.quality == 6 and v.is_lock == 0 then
                    game_scene:addPop("game_fate_rune_tips_pop",{callback = callBackFunc})
                    return
                end
            end
            callBackFunc()
                        
		elseif btnTag >= 201 and btnTag <= 204 then--排序
          
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_fate_rune.ccbi");
    --英雄相关
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_name_label = ccbNode:labelTTFForName("m_name_label")
    self.m_race_label = ccbNode:labelTTFForName("m_race_label")
    self.m_new_lv_label = ccbNode:labelTTFForName("m_new_lv_label")
    self.m_occupation_icon = ccbNode:spriteForName("m_occupation_icon")
    self.m_occupation_icon2 = ccbNode:spriteForName("m_occupation_icon2")
    self.m_img_2 = ccbNode:spriteForName("m_img_2")
  
    self.m_hero_node_list = ccbNode:layerForName("m_hero_node_list")
    self.m_rune_node_list = ccbNode:layerForName("m_rune_node_list")
    -- self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    -- self.m_butes_node = ccbNode:nodeForName("m_butes_node")

    -- self.m_scroll_node = ccbNode:nodeForName("m_scroll_node")
    -- self.m_scroll = ccbNode:scrollViewForName("m_scroll")
    self.m_fuwenshi_label = ccbNode:labelBMFontForName("m_fuwenshi_label")
    self.m_gold_label = ccbNode:labelBMFontForName("m_gold_label")
    self.m_fuwenshi_label2 = ccbNode:labelBMFontForName("m_fuwenshi_label2")
    self.m_gold_label2 = ccbNode:labelBMFontForName("m_gold_label2")
   
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())

    self.m_ccbNode = ccbNode
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    self.m_root_layer:setTouchEnabled(false);

    self:refreshCardTableView()
    self:selectCellState(0)

    return ccbNode;
end

--[[--
    创建英雄
]]
function game_fate_rune.createCard(self)
    local cardId = self.m_data["fate_rune_data"][tostring(self.m_pos)]["bind_card"]
    if cardId == "" then
        return
    end
    local character_detail_cfg = getConfig(game_config_field.character_detail)
    local cardData, selItemCfg = game_data:getCardDataById(tostring(cardId))
    local c_id = cardData.c_id
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(c_id))

    local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
    local animNode = game_util:createAnimSequence3(ainmFile,0,cardData,heroCfg);
    if animNode then
        animNode:setRhythm(1);
        game_anim:playSection(animNode , anim_label_name_cfg.daiji);
        animNode:setAnchorPoint(ccp(0.5,0));
        self.m_anim_node:addChild(animNode);
    end

    self.m_new_lv_label:setVisible(true)
    self.m_new_lv_label:setString("Lv." .. cardData.lv .. "/" .. cardData.level_max);

    local name_after = game_util:getCardName(cardData,heroCfg)
    self.m_name_label:setString(name_after);

    local race_cfg = getConfig(game_config_field.race);
    local race_item_cfg = race_cfg:getNodeWithKey(heroCfg:getNodeWithKey("race"):toStr());
    if race_item_cfg then
        self.m_race_label:setString(race_item_cfg:getNodeWithKey("name"):toStr());
    else
        self.m_race_label:setString("Không chủng tộc");
    end

    local occupation_cfg = getConfig(game_config_field.occupation);
    local occupation_item_cfg = occupation_cfg:getNodeWithKey(ainmFile)
    local occupation_cfg2 = getConfig(game_config_field.character_detail);
    local occupation_item_cfg2 = occupation_cfg2:getNodeWithKey(tostring(c_id))
    self.m_occupation_icon:setVisible(true)
    self.m_occupation_icon2:setVisible(true)
    self.m_img_2:setVisible(true)
    if occupation_item_cfg then
        local occupationType = occupation_item_cfg:toInt();
        local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupationType .. ".png")
        if spriteFrame then
            self.m_occupation_icon:setDisplayFrame(spriteFrame);
        end
        
        if occupationType >=0 and occupationType < 4 then 
            self.m_occupation_icon2:setVisible(false)
        else
            local occupation_item_cfg22 = occupation_item_cfg2:getNodeWithKey("occupation_shade")
            local occupationType2 = occupation_item_cfg22:toInt();
            -- cclog2(occupationType2,"occupationType2-=---------")
            local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupationType2 .. ".png")
            if spriteFrame then
                self.m_occupation_icon2:setDisplayFrame(spriteFrame);
            else
                self.m_occupation_icon2:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation5.png"));
            end
            if occupationType2 == -1 then 
                self.m_occupation_icon2:setVisible(false)
            end
        end
    end
end

function game_fate_rune.removeCard(self)
    self.m_anim_node:removeAllChildrenWithCleanup(true)
    self.m_race_label:setString("------")
    self.m_name_label:setString("Tên đối tác")
    self.m_new_lv_label:setString("0")
    self.m_new_lv_label:setVisible(false)
    self.m_occupation_icon:setVisible(false)
    self.m_occupation_icon2:setVisible(false)
    self.m_img_2:setVisible(false)
end

function game_fate_rune.removeIcon(self)
    for k,v in pairs(self.m_itemTab) do
        if self.m_pos == k then
            local ccbNode = tolua.cast(v:getChildByTag(10),"luaCCBNode")
            local m_icon_node = ccbNode:nodeForName("m_icon_node")
            m_icon_node:removeAllChildrenWithCleanup(true);
        end
    end
end

--[[--
    刷新
]]
function game_fate_rune.refreshCardTableView(self)
    self.m_itemTab = {}
    self.m_hero_node_list:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil
    self.m_tableView = self:createTableView(self.m_hero_node_list:getContentSize());
    self.m_hero_node_list:addChild(self.m_tableView);

end

function game_fate_rune.selectCellState(self, index)
    self.m_pos = index + 1
    self:removeCard()
    self:createCard()
    self:refreshUi()
    for k,v in pairs(self.m_itemTab) do
        local ccbNode = tolua.cast(v:getChildByTag(10),"luaCCBNode")
        local m_ct_1 = ccbNode:spriteForName("m_ct_1")
        local m_ct_2 = ccbNode:spriteForName("m_ct_2")
        local m_icon_node = ccbNode:nodeForName("m_icon_node")
        m_icon_node:removeAllChildrenWithCleanup(true);

        local cardId = self.m_data["fate_rune_data"][tostring(k)]["bind_card"]
        if cardId ~= "" then
            local itemData =  game_data:getCardDataById(cardId)
            local c_id = itemData.c_id
            
            local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(c_id)
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
            local tempIcon = game_util:createCardIconByCfg(itemConfig,itemData)
            if tempIcon then
                m_icon_node:setVisible(true)
                local size = m_icon_node:getContentSize()
                tempIcon:setPosition(ccp(size.width*0.5,size.height*0.5))
                tempIcon:setScale(0.75);
                m_icon_node:addChild(tempIcon)
            end
        end
        
        if k == index+1 then
            m_ct_2:setVisible(true)
            m_ct_1:setVisible(true)
        else
            m_ct_2:setVisible(false)
            m_ct_1:setVisible(false)
        end
    end
end

--[[--
    创建卡槽列表
]]
function game_fate_rune.createTableView(self,viewSize)

    local level = game_data:getUserStatusDataByKey("level")
    local rune_cig = getConfig(game_config_field.fate_rune_lv)
    local fate_rune_lv = json.decode(rune_cig:getFormatBuffer())
    local cardsData = game_data:getTableCardsData()
 
    local cardsCount = 8
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 8; --列
    params.totalItem = cardsCount -- totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()
            ccbNode:openCCBFile("ccb/ui_fata_rune_select_btn.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < cardsCount then
                self.m_itemTab[index+1] = cell
                local lv = fate_rune_lv[tostring(index+1)]["lv"]
                local fate_rune_data = self.m_data["fate_rune_data"][tostring(index+1)]
                local cardId = fate_rune_data["bind_card"]
                
                local rank_lock = ccbNode:spriteForName("rank_lock")
                local rank_add = ccbNode:spriteForName("rank_add")
                local m_ct_1 = ccbNode:spriteForName("m_ct_1")
                local m_ct_2 = ccbNode:spriteForName("m_ct_2")
                local m_icon_node = ccbNode:nodeForName("m_icon_node")
                local m_grade_label = ccbNode:labelTTFForName("m_grade_label")

                if level >= lv then
                    rank_lock:setVisible(false)
                    rank_add:setVisible(true)
                    m_grade_label:setVisible(false)
                else
                    rank_lock:setVisible(true)
                    rank_add:setVisible(false)
                    m_grade_label:setVisible(true)
                    m_grade_label:setString("lv."..lv)
                end

                if 0 == index then
                    m_ct_1:setVisible(true)
                    m_ct_2:setVisible(true)
                else
                    m_ct_1:setVisible(false)
                    m_ct_2:setVisible(false)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
            local lv = fate_rune_lv[tostring(index+1)]["lv"]
            if level < lv or index+1 == self.m_pos then
                return
            end
            self:selectCellState(index)

        elseif eventType == "longClick" and cell then
    
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    local tableView = TableViewHelper:create(params);
    return tableView
end

--[[--
    创建属性列表
]]
function game_fate_rune.createTableView2(self,viewSize)
    local cardsCount = 4
    local params = {};
    self.m_isLock_Tab = {}
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.totalItem = cardsCount;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local lock_list = ""
        local prams = {}
        if btnTag>0 and btnTag<5 then
            if not self.m_data["fate_rune_data"][tostring(self.m_pos)]["rune_1"]["attrs"]["team_hurt_add"] then
                game_util:addMoveTips({text = "Giá trị thuộc tính là 0 không thể khóa!"})
                return
            end

            if self.m_isLock_Tab[btnTag] == 1 then
                self.m_isLock_Tab[btnTag] = 0
            else
                self.m_isLock_Tab[btnTag] = 1
            end
            local count = 0
            for i,v in ipairs(self.m_isLock_Tab) do
                if v == 1 then
                    count = count + 1
                end
                lock_list = lock_list..v.."_"
            end
            if count > 3 then
                game_util:addMoveTips({text = "Tối đa khóa 3 dòng thuộc tính!"})
                if self.m_isLock_Tab[btnTag] == 1 then
                    self.m_isLock_Tab[btnTag] = 0
                else
                    self.m_isLock_Tab[btnTag] = 1
                end
                return
            end
            local str = string.sub(lock_list,0,7)
            prams.pos = self.m_pos
            prams.lock_list = str

            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) 
                self.m_data = data
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_lock_fate_rune"), http_request_method.GET, prams,"cards_lock_fate_rune")
        end
    end
    
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
            ccbNode:openCCBFile("ccb/ui_fata_rune_bute.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < cardsCount then
                local fate_rune_data = self.m_data["fate_rune_data"][tostring(self.m_pos)]
                local idx = index + 1
                local rune_data = fate_rune_data["rune_"..idx]
                self.m_isLock_Tab[#self.m_isLock_Tab+1] = rune_data["is_lock"]

                local m_bute1_label = ccbNode:labelTTFForName("m_bute1_label")
                local m_bute2_label = ccbNode:labelTTFForName("m_bute2_label")
                local m_bute3_label = ccbNode:labelTTFForName("m_bute3_label")
                local m_numb1_label = ccbNode:labelTTFForName("m_numb1_label")
                local m_numb2_label = ccbNode:labelTTFForName("m_numb2_label")
                local m_numb3_label = ccbNode:labelTTFForName("m_numb3_label")
                local m_lock_btn = ccbNode:controlButtonForName("m_lock_btn")
                local m_lock2_btn = ccbNode:controlButtonForName("m_lock2_btn")
                local m_weisx_label = ccbNode:labelTTFForName("m_weisx_label")
                local m_icon_node = ccbNode:nodeForName("m_icon_node")
                m_weisx_label:setVisible(false)
                m_weisx_label:setString("Chưa có tác dụng")
                m_icon_node:removeAllChildrenWithCleanup(true)
                m_lock_btn:setTag(idx)
                m_lock2_btn:setTag(idx)
                local rune_spr = ccbNode:spriteForName("rune_spr")

                local quality = rune_data["quality"]
                if quality <= 0 then
                    quality = 1
                end
                if quality > 6 then
                    quality = 6
                end

                --锁定符文
                if rune_data["is_lock"] == 0 then  --未上锁
                    m_lock2_btn:setVisible(false)
                    m_lock2_btn:setEnabled(false)
                    m_lock_btn:setVisible(true)
                    m_lock_btn:setEnabled(true)
                else
                    m_lock2_btn:setVisible(true)
                    m_lock2_btn:setEnabled(true)
                    m_lock_btn:setVisible(false)
                    m_lock_btn:setEnabled(false)
                end

                local str_lvel = self.level_tab[quality]

                m_bute1_label:setString(str_lvel..self.fate_rune_tab[idx])
                m_bute1_label:setColor(self.m_color_tab[quality])
                m_numb1_label:setColor(self.m_color_tab[quality])
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("rune" .. idx .. ".png")
                if spriteFrame then
                    rune_spr:setDisplayFrame(spriteFrame);
                end

                local atab = rune_data["attrs"]
                local iskey = false
                for k,v in pairs(CHAIN_EFFECT_NUM_NAME_DICT) do
                    local attr = v["attrName"]
                    local key = rune_data["attrs"][attr]
                    local ptage = ""
                    if attr=="team_hurt_add" or attr=="team_hurt_def" then
                        ptage = "%"
                    end
                    if key then
                        local name = PUBLIC_ABILITY_NAME_TABLE[attr]["name"]
                        if not iskey then
                            m_bute2_label:setString(name)
                            m_numb2_label:setString("+"..key..ptage)
                            m_numb1_label:setString("("..rune_data["add_percent"].."%)")
                        else
                            m_bute3_label:setString(name)
                            m_numb3_label:setString("+"..key..ptage)
                            m_numb1_label:setString("("..rune_data["add_percent"].."%)")
                        end
                        iskey = true 
                    end
                end

                if not iskey then
                    m_bute2_label:setString("")
                    m_bute3_label:setString("")
                    m_numb1_label:setString("")
                    m_numb2_label:setString("")
                    m_numb3_label:setString("")
                end

                local c_id = rune_data["character_id"]
                if c_id and c_id ~= 0 and idx == 1 then
                    local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(c_id)
                    local fileName = itemConfig:getNodeWithKey("img"):toStr()
                    local cardName = itemConfig:getNodeWithKey("name"):toStr()
                    local tempIcon = game_util:createIconByName(fileName)
                    local size = m_icon_node:getContentSize()
                    tempIcon:setScale(0.75)
                    tempIcon:setPosition(ccp(size.width*0.5,size.height*0.5))
                    m_icon_node:addChild(tempIcon)
                    m_numb1_label:setString(cardName)
                end

                local cardId = self.m_data["fate_rune_data"][tostring(self.m_pos)]["bind_card"]
                if cardId ~= "" and c_id then
                    local itemData =  game_data:getCardDataById(cardId)
                    local character_id = itemData.c_id
                    if character_id == c_id then
                        m_weisx_label:setVisible(false)
                    else
                        m_weisx_label:setVisible(true)
                    end
                elseif c_id then
                    m_weisx_label:setVisible(true)
                end 
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then


        elseif eventType == "longClick" and cell then
    
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    local tableView = TableViewHelper:create(params);
    return tableView
end

--[[--
    刷新ui
]]
function game_fate_rune.refreshUi(self)
    self.m_rune_node_list:removeAllChildrenWithCleanup(true);
    self.m_tableView2 = nil
    self.m_tableView2 = self:createTableView2(self.m_rune_node_list:getContentSize());
    self.m_rune_node_list:addChild(self.m_tableView2);

    -- local totalFood = game_data:getUserStatusDataByKey("rune_stone") or 0
    local totalFood = game_data:getItemCountByCid(tostring(538)) or 0
    local value,unit = game_util:formatValueToString(totalFood);

    local totalCoin = game_data:getUserStatusDataByKey("coin") or 0
    local value2,unit2 = game_util:formatValueToString(totalCoin);
    self.m_fuwenshi_label:setString(value..unit)
    self.m_gold_label:setString(value2..unit2)

    local rune_cig = getConfig(game_config_field.fate_rune)
    local fate_rune_cig = json.decode(rune_cig:getFormatBuffer())
 
    local fate_rune_data = self.m_data["fate_rune_data"][tostring(self.m_pos)]
    local lock_numbel = 0
    for k,v in pairs(fate_rune_data) do
        if type(v) == "table" and v.is_lock and v.is_lock == 1 then
            lock_numbel = lock_numbel + 1
        end
    end

    if lock_numbel > 3 then
        lock_numbel = 0
    end
    local coin = fate_rune_cig["1"]["refine_coin"][lock_numbel+1][3]
    local soul_stone = fate_rune_cig["1"]["refine_soul_stone"][lock_numbel+1][3]
    self.m_gold_label2:setString(coin)
    self.m_fuwenshi_label2:setString(soul_stone)
end

--[[--
    初始化
]]
function game_fate_rune.init(self,t_params)
    local params = t_params.gameData or {};
    self.m_pos = 1
    self.fate_rune_tab = {"Phù văn Đoàn Đội","Phù văn Chiến Đấu","Phù văn Kiên Cố","Phù văn Nguyên Tố"}
    self.level_tab = {"","sơ cấp","trung cấp","cao cấp","đặc cấp","thần cấp"}
    self.m_color_tab = {ccc3(0,255,0), ccc3(9,200,52), ccc3(90,149,255), ccc3(183,113,255), ccc3(255,160,50), ccc3(214,43,43) }
    self.m_data = json.decode(params:getNodeWithKey("data"):getFormatBuffer())
    
    --cclog2(self.m_data,"m_data")
end

--[[--
    创建ui入口并初始化数据
]]
function game_fate_rune.create(self,t_params)
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    self:createCard()
    return uiNode;
end

return game_fate_rune;
