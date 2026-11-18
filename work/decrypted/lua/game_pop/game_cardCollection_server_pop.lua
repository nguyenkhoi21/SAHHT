--一元夺宝
local game_cardCollection_server_pop = {
    m_tGameData = nil,
    m_tab_ui = nil,
    m_node_tableView = nil,
    card_collection_cfg = nil,
    m_lab_des = nil,
    m_curIdTab = nil,
    m_tishi_label= nil,

};
--[[--
    销毁ui
]]
function game_cardCollection_server_pop.destroy(self)
    -- body
    cclog("-----------------game_cardCollection_server_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_tab_ui = nil;
    self.m_node_tableView = nil;
    self.card_collection_cfg = nil;
    self.m_lab_des = nil;
    self.m_curIdTab = nil;
    self.m_tishi_label = nil;
   

end
--[[--
    返回
]]
function game_cardCollection_server_pop.back(self,type)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_cardCollection_server_pop.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/Gringotts.plist");
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag ==== ")
        if btnTag == 1 then--返回
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onBtnClick",onBtnClick);
    ccbNode:openCCBFile("ccb/ui_cardCollection_pop.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local  m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_tishi_label = ccbNode:labelTTFForName("m_tishi_label")
    self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")
    self.m_lab_des = ccbNode:labelTTFForName("m_lab_des")
  

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    m_root_layer:setTouchEnabled(true);
    self.m_tishi_label:setString("Phải nhận ngay trong ngày mới đc nhận thêm thẻ bài")
    return ccbNode;
end
function game_cardCollection_server_pop.getConfigData( self ) --处理傻策划的奇葩数据
    local cardIdTab = {}
    local collectcardTab = {}
    local exchangeIdTab = {}
    local endTime = ""
    local index = 1
    local length = game_util:getTableLen(self.card_collection_cfg)

    for i=1,length do
        -- cclog2(self.card_collection_cfg[tostring(i)].version,"version")
        if self.m_tGameData.version == self.card_collection_cfg[tostring(i)].version then
            cardIdTab[index] = self.card_collection_cfg[tostring(i)].card
            collectcardTab[index] = self.card_collection_cfg[tostring(i)].collect_card
            endTime = self.card_collection_cfg[tostring(i)].end_time
            exchangeIdTab[index] = i
            self.m_curIdTab[index] = i
            index = index +1

        end
    end
    cclog2(self.m_curIdTab,"curId ==== ")
    return cardIdTab,collectcardTab,endTime,exchangeIdTab
end
function game_cardCollection_server_pop.getCurrentNum( self,cardId )
    local num = 0
    if self.m_tGameData.collection_card and next(self.m_tGameData.collection_card) then
        if self.m_tGameData.collection_card[tostring(cardId)] then
            num = self.m_tGameData.collection_card[tostring(cardId)]
        end
    end
    return num
    -- body
end
--  -9999就是不让显示出来
local nodePosTab = {{ccp(-45,5),ccp(-9999,-9999),ccp(-9999,-9999),ccp(-9999,-9999)},
                    {ccp(-125,5),ccp(35,5),ccp(-9999,-9999),ccp(-9999,-9999)},
                    {ccp(-155,5),ccp(-45,5),ccp(65,5),ccp(-9999,-9999)},
                    {ccp(-180,5),ccp(-90,5),ccp(0,5),ccp(90,5)}}
-- local addSpritePosTab = {ccp(-100,5),ccp(10,5),ccp(-9999,-9999),ccp(-9999,-9999)}
local addSpritePosTab = {
                        {ccp(-9999,-9999),ccp(-9999,-9999),ccp(-9999,-9999),ccp(-9999,-9999)},
                        {ccp(-45,5),ccp(-9999,-9999),ccp(-9999,-9999),ccp(-9999,-9999)},
                        {ccp(-100,5),ccp(10,5),ccp(-9999,-9999),ccp(-9999,-9999)},
                        {ccp(-135,5),ccp(-45,5),ccp(45,5),ccp(-9999,-9999)}
                        }
--[[--
    创建列表
]]
function game_cardCollection_server_pop.createTableView( self,viewSize )
    local cardIdTab,collectcardTab,endTime,exchangeIdTab = self:getConfigData()
    -- self.m_lab_des:setString("本次兑换截止日期为：" .. endTime)
    self.m_lab_des:setVisible(false)
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 11111 then
            game_util:addMoveTips({text = "Chưa đủ điều kiện đổi"})
        elseif btnTag == 999 then
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_gacha_scene",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gacha_get_all_gacha"), http_request_method.GET, nil,"gacha_get_all_gacha")
            -- game_util:addMoveTips({text = "去抽卡"})
        else
            local params = {}
            params.exchange_id = exchangeIdTab[btnTag]
            local function responseMethod(tag,gameData)
                -- cclog2(gameData,"gameData ----- ")
                self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                game_util:rewardTipsByDataTable(self.m_tGameData.reward)
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_card_colection_exchange"), http_request_method.GET, params,"server_card_colection_exchange")

        end
    end
    local totalItem = game_util:getTableLen(collectcardTab)
    local params = {};
    local viewSize = viewSize
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 1; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    params.direction = kCCScrollViewDirectionVertical
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    self.m_cellSize = itemSize
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
            ccbNode:openCCBFile("ccb/ui_cardCollection_item.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.6));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_node_collection = ccbNode:nodeForName("m_node_collection")
            local m_sp_add = ccbNode:spriteForName("m_sp_add")
            local m_btn_exchange = ccbNode:controlButtonForName("m_btn_exchange")
            local m_btn_nohave = ccbNode:controlButtonForName("m_btn_nohave")
            m_btn_exchange:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
            m_btn_nohave:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
            m_btn_nohave:setTag(11111)
            m_btn_exchange:setTag(index+1)
            local cardNodeTab = {}
            local itemNum = game_util:getTableLen(cardIdTab[index+1])
            local m_node_ui,m_sp_add,m_btn_get
            local m_ui_tab = {}
            for i=1,4 do
                m_node_ui = ccbNode:nodeForName("m_node_ui" .. i)
                m_sp_add = ccbNode:spriteForName("m_sp_add" .. i)
                m_btn_get = ccbNode:controlButtonForName("m_btn_get" .. i)
                m_btn_get:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
                m_node_ui:setPosition(nodePosTab[itemNum][i])
                m_sp_add:setPosition(addSpritePosTab[itemNum][i])

            end
            local flagNum  = 0
            for i=1,itemNum do
                local cardID = tostring(cardIdTab[index+1][i][2])
                local cardnode = ccbNode:nodeForName("m_node_card" .. i)
                cardnode:removeAllChildrenWithCleanup(true)
                local tempNode = game_util:setHeroListItemInfoByTableOnlyNeedId(cardID)
                tempNode:setScale(0.75)
                cardnode:addChild(tempNode,10,10)
                local currentNum = self:getCurrentNum(cardID)
                local allNum = tostring(cardIdTab[index+1][i][3])
                local m_label_num = ccbNode:labelTTFForName("m_label_num" .. i)
                m_label_num:setString(currentNum .. "/" .. allNum)
                if tonumber(currentNum) >= tonumber(allNum) then
                    flagNum = flagNum +1
                end 
            end
            if tonumber(flagNum) == tonumber(itemNum) then
                m_btn_exchange:setVisible(true)
                m_btn_nohave:setVisible(false)
            else
                m_btn_exchange:setVisible(false)
                m_btn_nohave:setVisible(true)
            end
            local tempCollectionNode = game_util:setHeroListItemInfoByTableOnlyNeedId(tostring(collectcardTab[index+1][1][2]))
            tempCollectionNode:setScale(0.75)
            m_node_collection:removeAllChildrenWithCleanup(true)
            m_node_collection:addChild(tempCollectionNode)
            local m_sprite_alreadyGet = CCSprite:createWithSpriteFrameName("Gringotts_alreadyGet.png");
            tempCollectionNode:addChild(m_sprite_alreadyGet,10,10)
            m_sprite_alreadyGet:setPosition(ccp(50,50))
            m_sprite_alreadyGet:setVisible(false)
            if self.m_tGameData.exchange_card and next(self.m_tGameData.exchange_card) then
                for k,v in pairs(self.m_tGameData.exchange_card) do

                    if self.m_curIdTab[index+1] == v then
                        m_sprite_alreadyGet:setVisible(true)
                        m_btn_exchange:setTouchEnabled(false)
                        break
                    else
                        m_sprite_alreadyGet:setVisible(false)
                        m_btn_exchange:setTouchEnabled(true)
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
    end
    return  TableViewHelper:createGallery2(params);
end

--[[--
    刷新ui
]]
function game_cardCollection_server_pop.refreshUi(self)
    self.m_node_tableView:removeAllChildrenWithCleanup(true)
    local viewSize = self.m_node_tableView:getContentSize()
    self.m_node_tableView:addChild(self:createTableView(viewSize),10)
    self:getConfigData()
end
--[[--
    初始化
]]
function game_cardCollection_server_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    self.card_collection_cfg = getConfig(game_config_field.server_card_collection);
    self.card_collection_cfg = json.decode(self.card_collection_cfg:getFormatBuffer()) or {}
    self.m_curIdTab = {}
    
end
--[[--
    创建ui入口并初始化数据
]]
function game_cardCollection_server_pop.create(self,t_params)
    self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi();
    return  m_popUi;
end
return game_cardCollection_server_pop;