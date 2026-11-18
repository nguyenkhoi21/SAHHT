local ui_indiana_shop_pop = {
    m_tGameData = nil,
    m_curPage = nil,
    m_btn_coin = nil,
    m_btn_jifen = nil,
    btn_back = nil,
    m_select_index = nil,
    m_sp_title = nil,
    m_lab_jifen = nil,
    m_label_coinDes = nil,
    m_node_coin = nil,
    m_lab_coin = nil,
};
--[[--
    销毁ui
]]
function ui_indiana_shop_pop.destroy(self)
    -- body
    cclog("-----------------ui_indiana_shop_pop destroy-----------------");
    --self.m_tGameData = nil;
    self.m_curPage = nil;
    self.m_node_tableView = nil;
    self.m_tGameData = nil;
    self.m_btn_coin = nil;
    self.m_btn_jifen = nil;
    self.btn_back = nil;
    self.m_select_index = nil;
    self.m_sp_title = nil;
    self.m_lab_jifen = nil;
    self.m_label_coinDes = nil;
    self.m_node_coin = nil;
    self.m_lab_coin = nil;
end
--[[--
    返回
]]
function ui_indiana_shop_pop.back(self,backType)
    game_scene:removePopByName("ui_indiana_shop_pop")
end
--[[--
    读取ccbi创建ui
]]
function ui_indiana_shop_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        self.m_select_index = btnTag
        if btnTag == 201 then
            self:back()
        elseif btnTag == 101 then
            self:refreshTableView2()
        elseif btnTag == 102 then
            self:refreshTableView()
        end
        -- if self.m_select_index then
        --     if self.m_select_index == 101 then
        --         game_util:setCCControlButtonBackground(self.m_btn_coin,"ui_indiana_coin1.png")
        --         game_util:setCCControlButtonBackground(self.m_btn_jifen,"ui_indiana_jifen2.png")
        --         self.m_btn_coin:setTouchEnabled(false)
        --         self.m_btn_jifen:setTouchEnabled(true)
        --         self.m_sp_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_indiana_coinT.png"))
        --     elseif self.m_select_index == 102 then
        --         game_util:setCCControlButtonBackground(self.m_btn_coin,"ui_indiana_coin2.png")
        --         game_util:setCCControlButtonBackground(self.m_btn_jifen,"ui_indiana_jifen1.png")
        --         self.m_btn_coin:setTouchEnabled(true)
        --         self.m_btn_jifen:setTouchEnabled(false)
        --         self.m_sp_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_indiana_jifenT.png"))
        --     end
        -- end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_indiana_shop.ccbi");
    self.m_sp_title = ccbNode:spriteForName("m_sp_title")
    self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")
    self.m_btn_coin = ccbNode:controlButtonForName("m_btn_coin")
    self.m_btn_jifen = ccbNode:controlButtonForName("m_btn_jifen")
    self.btn_back = ccbNode:controlButtonForName("btn_back")
    self.m_lab_jifen = ccbNode:labelTTFForName("m_lab_jifen")
    self.m_label_coinDes = ccbNode:labelTTFForName("m_label_coinDes")
    self.m_node_coin = ccbNode:nodeForName("m_node_coin")
    self.m_lab_coin = ccbNode:labelTTFForName("m_lab_coin")
    self.btn_back:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    self.m_btn_jifen:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    self.m_btn_coin:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    local touchBeginPoint = nil;
    local function onTouch(eventType, x, y)
        if eventType == "began" then
             return true;
         elseif eventType == "ended" then
         end
    end
    -- local btn_back = ccbNode:controlButtonForName("btn_back")
    -- btn_back:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    -- self.m_num_lab = ccbNode:labelTTFForName("m_num_lab")
    -- self.m_lab_jifen = ccbNode:labelTTFForName("m_lab_jifen")
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
function ui_indiana_shop_pop.getRewardTab( self )
    local m_raiders_reward_cfg = getConfig(game_config_field.raiders_reward);
     m_raiders_reward_cfg = json.decode(m_raiders_reward_cfg:getFormatBuffer()) or {}
    local rewardTab,rewardPointTab,rewardCoin,bianhao = {},{},{},{}
    local coin = {}
    local old_buy_times = self.m_tGameData.old_buy_times 
    -- cclog2(self.m_tGameData.old_buy_times,"xxxx      ")
    local x = 1
    local length = game_util:getTableLen(old_buy_times)
    if m_raiders_reward_cfg and next(m_raiders_reward_cfg) then
        for k,v in pairs(old_buy_times) do
            bianhao[x] = k
            local rewardId = v[1]
            coin[x] =  v[2]
            local reward = m_raiders_reward_cfg[tostring(rewardId)]["reward"]
            rewardTab[x] = reward
            rewardPointTab[x] = m_raiders_reward_cfg[tostring(rewardId)]["point"]
            rewardCoin[x] = m_raiders_reward_cfg[tostring(rewardId)]["cost_coin"]
            x = x+1
        end
    end
    return rewardTab,coin,rewardPointTab,bianhao
end
function ui_indiana_shop_pop.createCanBuy( self,viewSize )
    game_util:setCCControlButtonBackground(self.m_btn_coin,"ui_indiana_coin1.png")
    game_util:setCCControlButtonBackground(self.m_btn_jifen,"ui_indiana_jifen2.png")
    self.m_btn_coin:setTouchEnabled(false)
    self.m_btn_jifen:setTouchEnabled(true)

    self.m_sp_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_indiana_coinT.png"))
    local rewardTab,coin,rewardPointTab,bianhao = self:getRewardTab()

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local function responseMethod( tag,gameData )
            self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
            game_util:rewardTipsByDataTable(self.m_tGameData.reward)
            self:refreshUi()
        end
        local params = {}
        params.number = bianhao[btnTag]
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("raiders_buy_overdue_raiders"), http_request_method.GET, params,"raiders_buy_overdue_raiders")

        
    end
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        game_util:lookItemDetal(rewardTab[btnTag][1])       
    end
    local totalItem = game_util:getTableLen(rewardTab)
    if totalItem > 0 then
        self.m_label_coinDes:setVisible(false)
    else
        self.m_label_coinDes:setVisible(true)
    end
    local params = {};
    local viewSize = viewSize
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-3;
    params.direction = kCCScrollViewDirectionVertical
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    self.m_itemSize = itemSize
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
            ccbNode:openCCBFile("ccb/ui_indiana_coin_item.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0.01,itemSize.height*0.08));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_node_icon = ccbNode:nodeForName("m_node_icon")
            local m_lab_des = ccbNode:labelTTFForName("m_lab_des")
            local m_btn_goshop = ccbNode:controlButtonForName("m_btn_goshop")
            m_btn_goshop:setTag(index+1)
            m_btn_goshop:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
            local m_lab_rate = ccbNode:labelTTFForName("m_lab_rate")
            local m_sp_jindutiao = ccbNode:spriteForName("m_sp_jindutiao")
            local icon,name,count = game_util:getRewardByItemTable(rewardTab[index+1][1])
            if icon then
                icon:setScale(0.8)
                icon:setAnchorPoint(ccp(0.5,0.6))
                m_node_icon:addChild(icon)
                local button = game_util:createCCControlButton("public_skill.png","",onBtnCilck)
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
                button:setAnchorPoint(ccp(0,0))
                button:setZoomOnTouchDown(false)
                button:setOpacity(0)
                button:setScale(0.8)
                button:setTag(index+1)
                icon:addChild(button)
            end
            m_lab_des:setString("Tốn" .. rewardPointTab[index+1] - coin[index+1] .. "Xu để mua")
            self:setProgress(m_sp_jindutiao,m_lab_rate,coin[index+1],rewardPointTab[index+1])
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
    end
    return TableViewHelper:create(params);
end
--[[--
    设置进度条
]]
function ui_indiana_shop_pop.setProgress( self,m_sp_jindutiao,m_lab_rate,current_score,all_score )
    local expBg = m_sp_jindutiao
    local expBgSize = expBg:getContentSize(); 
    local current_score = current_score or 0
    local all_score = all_score or 100
    local percentage = current_score/all_score * 100  
    m_lab_rate:setString(current_score .. "/" .. all_score)
    local params = {}
    params.percentage = percentage
    params.fileName = "ui_indiana_jindutiao1.png"
    local expBarAdd = game_util:createProgressTimer(params)
    expBg:removeAllChildrenWithCleanup(true)
    expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
    expBg:addChild(expBarAdd,2,1);
end
--[[--
    创建列表
]]
function ui_indiana_shop_pop.createTableView(self,viewSize)
    self.m_label_coinDes:setVisible(false)
    game_util:setCCControlButtonBackground(self.m_btn_coin,"ui_indiana_coin2.png")
    game_util:setCCControlButtonBackground(self.m_btn_jifen,"ui_indiana_jifen1.png")
    self.m_btn_coin:setTouchEnabled(true)
    self.m_btn_jifen:setTouchEnabled(false)
    self.m_sp_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_indiana_jifenT.png"))
    -- local exchange_limit = bought_goods or {}
    local adventure_exchange_cfg = getConfig(game_config_field.raiders_shop)
    local showData = {}
    local m_id_table = {}
    local playerLevel = game_data:getUserStatusDataByKey("level") or 1

    local tempCount = adventure_exchange_cfg:getNodeCount()
    for i=1,tempCount do
        local itemCfg = adventure_exchange_cfg:getNodeAt(i-1)
        local limits = itemCfg:getNodeWithKey("limits")
        limits = json.decode(limits:getFormatBuffer())
        table.insert(showData,itemCfg:getKey())
        table.insert(m_id_table,i)
        if playerLevel>=limits[1] and playerLevel<= limits[2] then
           
        end
    end
    table.sort(showData,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
    local itemsCount = #showData
    local function onButtonClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag === ")
        local params = {}
        local tempId = showData[btnTag + 1]

        params.goods_id = tempId
        local function responseMethod(tag,gameData)
            -- cclog2(gameData,"gameData ")
            self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
            local reward = self.m_tGameData.reward or {}
            game_util:rewardTipsByDataTable(reward);
            self:refreshUi()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("raiders_buy"), http_request_method.GET, params,"raiders_buy")
        -- local tempId = showData[btnTag + 1]
        -- local function responseMethod(tag,gameData)
        --     self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
        --     local reward = self.m_tGameData.rewards or {}
        --     game_util:rewardTipsByDataTable(reward)
        --     self:refreshUi()
        -- end
        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_tycoon_active_buy"), http_request_method.GET, {shop_type = 1,goods_id = tempId},"super_tycoon_active_buy")
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = itemsCount;
    params.showPageIndex = self.m_curPage;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-4
    local itemSize = CCSizeMake(viewSize.width/params.column-5,viewSize.height/params.row+10);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onButtonClick",onButtonClick);
            ccbNode:openCCBFile("ccb/pop_guild_shop_item.ccbi");
            ccbNode:setScale(0.9)
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5-5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_iconNode = ccbNode:nodeForName("m_iconNode")
            if index < itemsCount then
            local m_itemCount_label = ccbNode:labelTTFForName("m_itemCount_label")
            local m_needScare = ccbNode:labelTTFForName("m_needScare")
            local m_button = ccbNode:controlButtonForName("m_button")
            m_button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
            m_button:setTag(index);
            local black_bg_sellout = ccbNode:spriteForName("black_bg_sellout")
            local m_jifen_lab = ccbNode:labelTTFForName("m_jifen_lab")
            local m_scale_sp = ccbNode:scale9SpriteForName("m_scale_sp")
            local count_label = ccbNode:labelBMFontForName("count_label")
            local cd_node = ccbNode:nodeForName("cd_node")

            local m_cdTime = ccbNode:labelTTFForName("m_cdTime")
            local open_text = ccbNode:labelTTFForName("open_text")
            m_scale_sp:setScale(0.9)
            m_button:setScale(0.9)
            m_jifen_lab:setString("điểm")
            black_bg_sellout:setVisible(false)
            local tempId = showData[index+1]
            local itemCfg = adventure_exchange_cfg:getNodeWithKey(tempId)
            m_needScare:setString(tostring(itemCfg:getNodeWithKey("cost"):toInt()))
            local refreshType = itemCfg:getNodeWithKey("refresh"):toInt()

            local reward = itemCfg:getNodeWithKey("reward")
            reward = json.decode(reward:getFormatBuffer())
            local icon,name,count = game_util:getRewardByItemTable(reward[1]);
            if icon then 
                m_iconNode:addChild(icon)
                count_label:setString("x" .. tostring(count))
                local bought = 0
                if self.m_tGameData.bought_limit_goods and next(self.m_tGameData.bought_limit_goods) then
                    bought = self.m_tGameData.bought_limit_goods[tostring(m_id_table[index+1])] or 0
                end
                local times = itemCfg:getNodeWithKey("times"):toInt()
                local haveTimes = math.max(0,times-bought)
                if times == -1 then
                    m_itemCount_label:setString(name)
                else
                    m_itemCount_label:setString(name .. "(" .. tostring(haveTimes) .. ")")
                end

                local limits = itemCfg:getNodeWithKey("limits")
                limits = json.decode(limits:getFormatBuffer())
                if playerLevel>=limits[1] and playerLevel<= limits[2] then
                    cd_node:setVisible(false) 
                    m_button:setTouchEnabled(true)
                    if refreshType == 1 and haveTimes <= 0 and times ~= -1 then
                        cd_node:setVisible(true)
                        m_cdTime:setString("Ngày mai tạo mới")
                        -- game_util:setCCControlButtonEnabled(m_buy_btn,false)
                    elseif refreshType == 2 and haveTimes <= 0 and times ~= -1 then
                        cd_node:setVisible(true)
                        m_cdTime:setString("Tuần sau tạo mới")
                        -- game_util:setCCControlButtonEnabled(m_buy_btn,false)
                    elseif refreshType == 3 and haveTimes <= 0 and times ~= -1 then
                        cd_node:setVisible(true)
                        m_cdTime:setString("Tháng sau tạo mới")
                        -- game_util:setCCControlButtonEnabled(m_buy_btn,false)
                    else
                        cd_node:setVisible(false)
                        -- game_util:setCCControlButtonEnabled(m_buy_btn,true)
                    end

                elseif playerLevel<limits[1] then
                    cd_node:setVisible(true)
                    m_cdTime:setString(limits[1] .. "LV  mở")
                    open_text:setString("Mở LV")
                    m_button:setTouchEnabled(false)
                end
            end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= itemsCount then return end;

        if eventType == "ended" and cell and index then
            local tempId = showData[index+1]
            local itemCfg = adventure_exchange_cfg:getNodeWithKey(tempId)
            local reward = itemCfg:getNodeWithKey("reward")
            local rewardCount = reward:getNodeCount()
            if rewardCount > 0 then
                reward = json.decode(reward:getFormatBuffer())
                game_util:lookItemDetal(reward[1])
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新
]]
function ui_indiana_shop_pop.refreshTableView(self)
    self.m_lab_jifen:setVisible(true)
    self.m_node_coin:setVisible(false)
    self.m_node_tableView:removeAllChildrenWithCleanup(true);
    local tempTableView = self:createTableView(self.m_node_tableView:getContentSize());
    self.m_node_tableView:addChild(tempTableView);
end
function ui_indiana_shop_pop.refreshTableView2(self)
    self.m_lab_jifen:setVisible(false)
    self.m_node_coin:setVisible(true)
    self.m_node_tableView:removeAllChildrenWithCleanup(true);
    local tempTableView = self:createCanBuy(self.m_node_tableView:getContentSize());
    self.m_node_tableView:addChild(tempTableView);
end
--[[--
    刷新ui
]]
function ui_indiana_shop_pop.refreshUi(self)
    self.m_lab_jifen:setString("Tích điểm:" .. tostring(self.m_tGameData.score))
    if  self.m_select_index then
        if self.m_select_index == 101 then
            self:refreshTableView2()
        elseif self.m_select_index == 102 then
            self:refreshTableView()
        end
    else
        if self.m_tGameData.old_buy_times and next(self.m_tGameData.old_buy_times) then
            self:refreshTableView2()
        else
            self:refreshTableView()
        end
    end
    local coin = game_data:getUserStatusDataByKey("coin") or 0
    self.m_lab_coin:setString(tostring(coin)) 
end
--[[--
    初始化
]]
function ui_indiana_shop_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
    elseif t_params.gameData ~= nil and tolua.type(t_params.gameData) == "table" then
        self.m_tGameData = t_params.gameData
    end
    -- self.m_tGameData.old_buy_times = {{1,10},{2,100},{3,150},{4,200}}
    self.m_openType = t_params.openType or nil
end

--[[--
    创建ui入口并初始化数据
]]
function ui_indiana_shop_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return ui_indiana_shop_pop;