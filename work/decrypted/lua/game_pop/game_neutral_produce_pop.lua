--- 生产

local game_neutral_produce_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_ok_btn = nil,
    m_list_view_bg_1 = nil,
    m_list_view_bg_2 = nil,
    m_name_label = nil,
    m_time_label = nil,
    m_gain_label = nil,
    m_worker_icon_node = nil,
    m_work_detail_label = nil,
    m_refresh_btn = nil,
    m_cost_coin_label = nil,
    m_sel_seed_id = nil,
    m_map_id = nil,
    m_callBackFunc = nil,
    m_tips_label = nil,
    m_tempTableView = nil,
    m_buy_btn = nil,
    m_spr_icon = nil,
};
--[[--
    销毁ui
]]
function game_neutral_produce_pop.destroy(self)
    -- body
    cclog("-----------------game_neutral_produce_pop destroy-----------------");
    self.m_root_layer = nil
    self.m_close_btn = nil
    self.m_ok_btn = nil
    self.m_list_view_bg_1 = nil
    self.m_list_view_bg_2 = nil
    self.m_name_label = nil
    self.m_time_label = nil
    self.m_gain_label = nil
    self.m_worker_icon_node = nil
    self.m_work_detail_label = nil
    self.m_refresh_btn = nil
    self.m_cost_coin_label = nil
    self.m_sel_seed_id = nil
    self.m_map_id = nil
    self.m_callBackFunc = nil
    self.m_tips_label = nil
    self.m_tempTableView = nil
    self.m_buy_btn = nil
    self.m_spr_icon = nil
end
--[[--
    返回
]]
function game_neutral_produce_pop.back(self,backType)
    game_scene:removePopByName("game_neutral_produce_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_neutral_produce_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then--开始生产
            if self.m_map_id == nil then
                game_util:addMoveTips({text = "lỗi dữ liệu"})
                return
            end
            if self.m_sel_seed_id == nil then
                game_util:addMoveTips({text = "không có hạt"})
                return
            end
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                game_data:setDataByKeyAndValue("public_land_data",json.decode(data:getFormatBuffer()))
                game_data:setDataByKeyAndValue("public_land_data_time",os.time())
                if self.m_callBackFunc then
                    self.m_callBackFunc()
                end
                self:back()
            end
            -- map_id=3&seed_id=1
            local params = {}
            params.map_id = self.m_map_id
            params.seed_id = self.m_sel_seed_id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_land_sow_seed"), http_request_method.GET, params,"public_land_sow_seed")
        elseif btnTag == 3 then--工人刷新
            if self.m_map_id == nil then
                game_util:addMoveTips({text = "lỗi dữ liệu"})
                return
            end
            local item = self:getRefreshItem()
            local item_icon,item_name,item_count = game_util:getRewardByItemTable(item);
            local count = game_data:getItemCountByCid(item[2])
            if count < item[3] then 
                game_util:addMoveTips({text = item_name .."là không đủ"})
                return
            end
            local function responseMethod(tag,gameData)
                game_util:addMoveTips({text = "Làm mới thành công!"})
                local data = gameData:getNodeWithKey("data")
                game_data:setDataByKeyAndValue("public_land_data",json.decode(data:getFormatBuffer()))
                game_data:setDataByKeyAndValue("public_land_data_time",os.time())
                if self.m_callBackFunc then
                    self.m_callBackFunc()
                end
                self:refreshUi()
            end
            -- map_id=3&seed_id=1
            local params = {}
            params.map_id = self.m_map_id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_land_refresh_worker"), http_request_method.GET, params,"public_land_refresh_worker")
        elseif btnTag == 4 then--去购买
            function shopOpenResponseMethod(tag,gameData)
                game_scene:enterGameUi("game_buy_item_scene",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("shop_open"), http_request_method.GET, {},"shop_open")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_game_neutral_produce_pop.ccbi")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
    self.m_buy_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_list_view_bg_1 = ccbNode:nodeForName("m_list_view_bg_1")
    self.m_list_view_bg_2 = ccbNode:nodeForName("m_list_view_bg_2")
    self.m_name_label = ccbNode:labelTTFForName("m_name_label")
    self.m_time_label = ccbNode:labelTTFForName("m_time_label")
    self.m_gain_label = ccbNode:labelTTFForName("m_gain_label")
    self.m_gain_label:setString("")
    self.m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    self.m_worker_icon_node = ccbNode:nodeForName("m_worker_icon_node")
    self.m_work_detail_label = ccbNode:labelTTFForName("m_work_detail_label")
    self.m_refresh_btn = ccbNode:controlButtonForName("m_refresh_btn")
    self.m_refresh_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_cost_coin_label = ccbNode:labelTTFForName("m_cost_coin_label")
    self.m_spr_icon = ccbNode:nodeForName("spr_icon")
    self.m_spr_icon:removeAllChildrenWithCleanup(true)
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[
    
]]
function game_neutral_produce_pop.refreshTabelView(self,viewParentNode,own_seed)
    local selTableViewCell = nil
    local seed_cfg = getConfig(game_config_field.seed)
    own_seed = own_seed or {}
    local showData = {}
    for k,v in pairs(own_seed) do
        if v > 0 then
            table.insert(showData,k)
        end
    end
    table.sort(showData,function(data1,data2) 
        local itemCfg1 = seed_cfg:getNodeWithKey(data1)
        local itemCfg2 = seed_cfg:getNodeWithKey(data2)
        if itemCfg1 and itemCfg2 then
            local quality1 = itemCfg1:getNodeWithKey("quality"):toInt()
            local quality2 = itemCfg2:getNodeWithKey("quality"):toInt()
            return quality1 > quality2
        else
            return tostring(itemCfg1) > tostring(itemCfg2)
        end
    end)
    local showCount = #showData
    self.m_tips_label:setVisible(showCount == 0)
    if self.m_sel_seed_id == nil then
        self.m_sel_seed_id = showData[1]
    end
    self:refreshSelectSeed(self.m_sel_seed_id)
    local params = {};
    local viewSize = viewParentNode:getContentSize()
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 2; --列
    params.direction = direction or kCCScrollViewDirectionVertical;
    params.totalItem = showCount
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local key = showData[index+1] or ""
            local count = own_seed[key] or 0
            local itemCfg = seed_cfg:getNodeWithKey(key)
            if itemCfg then
                local quality = itemCfg:getNodeWithKey("quality"):toInt()
                local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr(),quality)
                if icon then
                    -- icon:setScale(0.65);
                    icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
                    cell:addChild(icon)
                end
                if count then
                    local tempLabel = game_util:createLabelBMFont({text = "×" .. count,color = ccc3(0,255,0),fontSize = 8});
                    tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5-20))
                    cell:addChild(tempLabel)
                end
            end
            if self.m_sel_seed_id == key then
                selTableViewCell = cell
                local selSprite = CCSprite:createWithSpriteFrameName("zldt_xuanzhong.png")
                selSprite:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
                cell:addChild(selSprite,10,10)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            -- game_util:lookItemDetal(rewardTab[index+1])
            if selTableViewCell then
                selTableViewCell:removeChildByTag(10,true)
            end
            selTableViewCell = cell
            local key = showData[index+1]
            self.m_sel_seed_id = key
            local selSprite = CCSprite:createWithSpriteFrameName("zldt_xuanzhong.png")
            selSprite:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
            cell:addChild(selSprite,10,10)
            self:refreshSelectSeed(self.m_sel_seed_id)
        end
    end
    local pX,pY = nil,nil
    if self.m_tempTableView then
        pX,pY = self.m_tempTableView:getContainer():getPosition()
    end
    local tempView = TableViewHelper:create(params)
    if pX and pY then
        tempView:setContentOffset(ccp(pX,pY),false)
    end
    self.m_tempTableView = tempView
    viewParentNode:removeAllChildrenWithCleanup(true)
    viewParentNode:addChild(tempView)
end

--[[--
    刷新
]]
function game_neutral_produce_pop.refreshSelectSeed(self,key)
    self.m_list_view_bg_2:removeAllChildrenWithCleanup(true)
    local seed_cfg = getConfig(game_config_field.seed)
    local itemCfg = seed_cfg:getNodeWithKey(tostring(key))
    if itemCfg then
        self.m_name_label:setString(itemCfg:getNodeWithKey("name"):toStr())
        self.m_time_label:setString(game_util:formatTime(itemCfg:getNodeWithKey("time"):toInt()*60))
        local tempStr = ""
        local reward = itemCfg:getNodeWithKey("reward")
        local tempCount = reward:getNodeCount()
        -- for i=1,tempCount do
        --     local icon,name,count = game_util:getRewardByItem(reward:getNodeAt(i-1),true)
        --     tempStr = tempStr .. name .. "\n"
        -- end
        -- self.m_gain_label:setString(tempStr .. "以上奖励随机一种")
        local tempSize = self.m_list_view_bg_2:getContentSize()
        if tempCount == 0 then
            self.m_gain_label:setString("không có")
        elseif tempCount == 1 then            
            local icon,name,count = game_util:getRewardByItem(reward:getNodeAt(0),true)
            if icon then
                icon:setScale(0.75)
                icon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                self.m_list_view_bg_2:addChild(icon)
            end
            local tempLabel = game_util:createLabelTTF({text = "×" .. tostring(count),color = ccc3(0,255,0),fontSize = 8});
            tempLabel:setPosition(ccp(tempSize.width*0.65, tempSize.height*0.1))
            self.m_list_view_bg_2:addChild(tempLabel)
        else
            local quality = itemCfg:getNodeWithKey("quality"):toInt()
            local icon = game_util:createIconByName("icon_nanpingmin4",quality)
            if icon then
                icon:setScale(0.75)
                icon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                local tmepSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zldt_wenhao.png")
                if tmepSpriteFrame then
                    icon:setDisplayFrame(tmepSpriteFrame)
                end
                self.m_list_view_bg_2:addChild(icon)
            end
            local tempLabel = game_util:createLabelTTF({text = "ngẫu nhiên",color = ccc3(0,255,0),fontSize = 8});
            tempLabel:setPosition(ccp(tempSize.width*0.65, tempSize.height*0.1))
            self.m_list_view_bg_2:addChild(tempLabel)
        end
    end
end

--[[--
    刷新ui
]]
function game_neutral_produce_pop.refreshUi(self)
    self.m_worker_icon_node:removeAllChildrenWithCleanup(true)
    local gameData = game_data:getDataByKey("public_land_data") or {}
    self:refreshTabelView(self.m_list_view_bg_1,gameData.own_seed)
    -- local refresh_worker_times = gameData.refresh_worker_times or 0
    -- local canBuy,payValue = game_util:getCostCoinBuyTimes("27",refresh_worker_times)
    -- self.m_cost_coin_label:setString(tostring(payValue))
    local worker_cfg = getConfig(game_config_field.worker)
    local map = gameData.map or {}
    local itemData = map[tostring(self.m_map_id)]
    if itemData then
        local worker_id = itemData.worker_id or 0
        local worker_cfg_item = worker_cfg:getNodeWithKey(tostring(worker_id))
        local iconName,detailMsg,quality = "i_worker_default.png","không có",1
        if worker_cfg_item then
            quality = worker_cfg_item:getNodeWithKey("quality"):toInt()
            iconName = worker_cfg_item:getNodeWithKey("icon"):toStr()
            detailMsg = worker_cfg_item:getNodeWithKey("name"):toStr()
        end
        local icon = game_util:createIconByName(iconName,quality)
        if icon then
            icon:setScale(0.75)
            self.m_worker_icon_node:addChild(icon)
        end
        self.m_work_detail_label:setString(detailMsg)
    else
        self.m_work_detail_label:setString("Id cốt truyện sai")
    end

    local item = self:getRefreshItem()
    local itemcfg = getConfig(game_config_field.item);
    local item_cfg = itemcfg:getNodeWithKey(tostring(item[2]));
    local icon1 = game_util:createIconByName(item_cfg:getNodeWithKey("icon"):toStr())
    icon1:setScale(0.4)
    self.m_spr_icon:addChild(icon1)
    self.m_cost_coin_label:setString(tostring(item[3]))
end

--[[
    获取刷新道具
]]
function game_neutral_produce_pop:getRefreshItem( ... )
    local worker_cfg = getConfig(game_config_field.worker)
    worker_cfg = json.decode(worker_cfg:getFormatBuffer())
    local gameData = game_data:getDataByKey("public_land_data") or {}
    local refresh_worker_times = gameData.refresh_worker_times or 0
    
    local map = gameData.map or {}
    local itemData = map[tostring(self.m_map_id)]
    local worker_id = itemData.worker_id or 0
    local refresh_cfg = {}
    if worker_id == 0 then 
        refresh_cfg = worker_cfg["1"].refresh
    else
        refresh_cfg = worker_cfg[tostring(worker_id)].refresh
    end
    
    if #refresh_cfg == 1 then
        return refresh_cfg[1]
    else
        if refresh_worker_times == 0 then 
            return refresh_cfg[1]
        else
            return refresh_cfg[2]
        end
    end
end
--[[--
    初始化
]]
function game_neutral_produce_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_map_id = t_params.map_id or ""
    self.m_callBackFunc = t_params.callBackFunc
end

--[[--
    创建ui入口并初始化数据
]]
function game_neutral_produce_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return game_neutral_produce_pop;