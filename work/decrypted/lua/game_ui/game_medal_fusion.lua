---  勋章合成

local game_medal_fusion = {
    tableViewTemp = nil,
    m_material_node_tab = nil,
    selectId = nil,
    m_animFlag = nil,
    m_list_view_bg = nil,
    m_item_icon_node = nil,
    m_material_node = nil,
    count_down_node = nil,
    first_name_label = nil,
    m_get_btn = nil,
    m_cancel_btn = nil,
    m_accelerate_btn = nil,
    tips_label = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    last_m_sel_img = nil,
    gameData = nil,
};
--[[--
    销毁ui
]]
function game_medal_fusion.destroy(self)
    -- body
    cclog("-----------------game_medal_fusion destroy-----------------");
    self.tableViewTemp = nil;

    self.m_material_node_tab = nil;
    self.selectId = nil;
    self.m_animFlag = nil;

    self.m_list_view_bg = nil;
    self.m_item_icon_node = nil;
    self.m_material_node = nil;
    self.count_down_node = nil;
    self.first_name_label = nil;
    self.m_get_btn = nil;
    self.m_cancel_btn = nil;
    self.m_accelerate_btn = nil;
    self.tips_label = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.last_m_sel_img = nil;
    self.gameData = nil;
end

local ability_commander_pos_tab = {
    count1 = {{50.0,90.0}},
    count2 = {{50.0,90.0},{50.0,10.0}},
    count3 = {{50.0,90.0},{15.0,25.0},{85.0,25.0}},
    count4 = {{15.0,75.0},{15.0,25.0},{85.0,25.0},{85.0,75.0}},
    count5 = {{50.0,90.0},{10.0,60.0},{25.0,15.0},{75.0,15.0},{85.0,60.0}},
}


--[[--
    返回
]]
function game_medal_fusion.back(self,backType)
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_medal_charts",{gameData = gameData});
        self:destroy()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_index"), http_request_method.GET, nil,"medal_index")
end
--[[--
    读取ccbi创建ui
]]
function game_medal_fusion.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then--查看属性
            if self.selectId == nil then return end
            game_scene:addPop("game_medal_pop",{gameData = self.gameData,material_type = self.selectId,openType = 2})
        elseif btnTag == 102 then--勋章图鉴
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_medal_list",{gameData = gameData});
                self:destroy()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_index"), http_request_method.GET, nil,"medal_index")
        elseif btnTag == 103 then -- 加速
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                self.gameData = json.decode(data:getFormatBuffer()) or {};
                local reward = data:getNodeWithKey("reward")
                game_util:rewardTipsByJsonData(reward);
                game_util:closeAlertView();
                -- game_util:addMoveTips({text = "加速成功！"})
                self.m_animFlag = false
                self:refreshUi()
            end
            local params = {}
            params.medal_id = self.selectId
            params.num = 1
            params.sort = 2

            local canBuy,payValue = game_util:getCostCoinBuyTimes(38,self.gameData.quick_train_times)
            local tipsText = ""
            if self.gameData.free_times > 0 then
                tipsText = "Gia tốc miễn phí hôm nay:" .. self.gameData.free_times .. ",dùng chứ?"
            elseif (self.gameData.max_quick_train_times - self.gameData.quick_train_times == 0) then
                game_util:addMoveTips({text = "Đã dùng hết gia tốc miễn phí!"})
                return
            else
                tipsText = "Tốn" .. payValue .. "Xu để gia tốc?"
            end
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_synthesis_medal"), http_request_method.GET, params,"medal_synthesis_medal")
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = tipsText,      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-20,
            }
            game_util:openAlertView(t_params);
        elseif btnTag == 104 then-- 背包
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_medal_list",{gameData = gameData});
                self:destroy()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_index"), http_request_method.GET, nil,"medal_index")
        elseif btnTag >= 201 and btnTag <= 205 then--排序

        elseif btnTag == 500 then--合成
            if self.selectId == nil then
                game_util:addMoveTips({text = "Chọn huy chương!"})
                return
            end
            local medalCfg = getConfig(game_config_field.medal)
            local materialCfg = getConfig(game_config_field.material)
            local materialData = self.gameData.material

            local itemCfg = medalCfg:getNodeWithKey(tostring(self.selectId))
            local material = itemCfg:getNodeWithKey("material")

            local count = 0
            for i=1,material:getNodeCount() do
                local material_id = material:getNodeAt(i-1):toInt()
                --去材料数量
                local itemCount = materialData[tostring(material_id)] or 0
                if itemCount > 0 then
                    count = count + 1
                end
            end
            if count == material:getNodeCount() then--满足合成条件
                --sort      # 1 代表合成 2 代表加速 3 代表停止 4 代表领取
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    self.gameData = json.decode(data:getFormatBuffer()) or {};
                    -- local reward = data:getNodeWithKey("reward")
                    -- game_util:rewardTipsByJsonData(reward);
                    game_util:addMoveTips({text = "Bắt đầu ghép!"})
                    self.m_animFlag = false
                    self:refreshUi()
                end
                local params = {}
                params.medal_id = self.selectId
                params.num = 1
                params.sort = 1
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_synthesis_medal"), http_request_method.GET, params,"medal_synthesis_medal")
            else
                game_util:addMoveTips({text = "Thiếu nguyên liệu!"})
            end
        elseif btnTag == 501 then--领取
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                self.gameData = json.decode(data:getFormatBuffer()) or {};
                local reward = data:getNodeWithKey("reward")
                game_util:rewardTipsByJsonData(reward);
                -- game_util:addMoveTips({text = "领取成功！"})
                self.m_animFlag = false
                self:refreshUi()
            end
            local params = {}
            params.medal_id = self.selectId
            params.num = 1
            params.sort = 4
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_synthesis_medal"), http_request_method.GET, params,"medal_synthesis_medal")
        elseif btnTag == 502 then--取消
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                self.gameData = json.decode(data:getFormatBuffer()) or {};
                local reward = data:getNodeWithKey("reward")
                game_util:rewardTipsByJsonData(reward);
                game_util:closeAlertView();
                -- game_util:addMoveTips({text = "取消成功！"})
                self.m_animFlag = false
                self:refreshUi()
            end
            local params = {}
            params.medal_id = self.selectId
            params.num = 1
            params.sort = 3
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_synthesis_medal"), http_request_method.GET, params,"medal_synthesis_medal")
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = "Dừng ghép chứ?",      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-20,
            }
            game_util:openAlertView(t_params);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_medal_fusion.ccbi");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_item_icon_node = ccbNode:nodeForName("m_item_icon_node")
    self.m_material_node = ccbNode:nodeForName("m_material_node")
    self.count_down_node = ccbNode:nodeForName("count_down_node")--倒计时
    self.first_name_label = ccbNode:labelTTFForName("first_name_label")--第一个合成的玩家名称
    self.m_get_btn = ccbNode:controlButtonForName("m_get_btn")
    self.m_cancel_btn = ccbNode:controlButtonForName("m_cancel_btn")
    self.m_accelerate_btn = ccbNode:controlButtonForName("m_accelerate_btn")
    self.tips_label = ccbNode:labelTTFForName("tips_label")

    self.m_item_icon_node:setScale(0.75)
    local m_material_node,m_mate_tips,m_num_label,parentNode = nil,nil,nil
    for i=1,5 do
        m_material_node = ccbNode:nodeForName("m_material_node_" .. i);
        m_mate_tips = ccbNode:spriteForName("m_mate_tips_" .. i);
        m_num_label = ccbNode:labelBMFontForName("m_num_label_" .. i);
        parentNode = m_material_node:getParent();
        self.m_material_node_tab[i] = {m_material_node = m_material_node,m_mate_tips = m_mate_tips,m_num_label = m_num_label,itemId = -1,count = 0,parentNode = parentNode}
    end

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    self.m_root_layer:setTouchEnabled(false);
    self.m_ccbNode = ccbNode
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_medal_fusion.refreshUi(self)
    local pX,pY;
    if self.tableViewTemp then
        pX,pY = self.tableViewTemp:getContainer():getPosition();
    end
    self.m_list_view_bg:removeAllChildrenWithCleanup(true)
    self.tableViewTemp = nil
    self.tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize());
    self.tableViewTemp:setScrollBarVisible(false);
    self.m_list_view_bg:addChild(self.tableViewTemp);
    if pX and pY then
        self.tableViewTemp:setContentOffset(ccp(pX,pY), false);
    end

    --刷新合成状态
    self:refreshMixtureStatus()
end
--[[
    创建勋章
]]--
function game_medal_fusion.createTableView( self,viewSize )
    self.last_m_sel_img = nil;
    local medalData = self.gameData["_medal"]
    local medalCfg = getConfig(game_config_field.medal)

    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = medalCfg:getNodeCount()
    params.itemActionFlag = true;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = game_util:createMedalItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            
            local itemData = {}
            local key = tostring(index + 1)
            itemData.c_id = key
            itemData.count = medalData[key] or 0
            game_util:setMedalItemInfoByTable2(ccbNode,itemData);

            m_sel_img = ccbNode:spriteForName("m_sel_img")
            if key == tostring(self.selectId) then
                m_sel_img:setVisible(true)
                self.last_m_sel_img = m_sel_img
            else
                m_sel_img:setVisible(false)
            end
        end
        return cell;
    end

    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local m_sel_img = ccbNode:spriteForName("m_sel_img")
            
            local key = tostring(index + 1)
            if key ~= tostring(self.selectId) then
                self.selectId = key
                m_sel_img:setVisible(true)
                if self.last_m_sel_img then
                    self.last_m_sel_img:setVisible(false)
                end
                self.last_m_sel_img = m_sel_img
                self.m_animFlag = true
                self:refreshMixtureStatus()
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    刷新合成状态
]]
function game_medal_fusion.refreshMixtureStatus(self)
    if self.selectId == nil then return end
    local medalCfg = getConfig(game_config_field.medal)
    local materialCfg = getConfig(game_config_field.material)
    local materialData = self.gameData.material

    local itemCfg = medalCfg:getNodeWithKey(tostring(self.selectId))
    local material = itemCfg:getNodeWithKey("material")
    local materialCount = material:getNodeCount()
    local tempPosTab = ability_commander_pos_tab["count" .. materialCount]
    local material_node_size = self.m_material_node:getContentSize();

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag", btnTag)

        local index = btnTag - 100
        local material_id = material:getNodeAt(index-1):toInt()
        
        game_scene:enterGameUi("game_medal_get_material",{material_type = self.selectId,material_id = material_id,gameData = self.gameData})
    end

    for i=1,#self.m_material_node_tab do
        local itemTab = self.m_material_node_tab[i]
        itemTab.m_material_node:removeAllChildrenWithCleanup(true);

        if i > materialCount then
            itemTab.m_material_node:setVisible(false)
            itemTab.m_mate_tips:setVisible(false)
            itemTab.itemId = -1
            itemTab.count = 0
        else
            itemTab.m_material_node:setVisible(true)
            itemTab.m_mate_tips:setVisible(true)
            itemTab.m_mate_tips:setOpacity(0)

            local material_id = material:getNodeAt(i-1):toInt()
            --去材料数量
            local itemCount = materialData[tostring(material_id)] or 0
            itemTab.count = itemCount
            local itemMaterialCfg = materialCfg:getNodeWithKey(tostring(material_id))
            local tempIcon = game_util:createMedalIcon(itemMaterialCfg)
            if tempIcon then
                local tempSize = itemTab.m_material_node:getContentSize();
                tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                itemTab.m_material_node:addChild(tempIcon)
                if itemCount == 0 then
                    tempIcon:setColor(ccc3(81,81,81))
                end
                self:createTouchButton(onBtnCilck,itemTab.m_material_node,100 + i)
            end
            itemTab.m_num_label:setString("x" .. itemCount)

            local tempPos = tempPosTab[i]
            local tempSize = self.m_material_node:getContentSize();
            if self.m_animFlag == true then
                itemTab.parentNode:stopAllActions();
                itemTab.parentNode:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                itemTab.parentNode:runAction(CCMoveTo:create(0.2,ccp(tempPos[1]*0.01*material_node_size.width, tempPos[2]*0.01*material_node_size.height)));
            else
                itemTab.parentNode:setPosition(ccp(tempPos[1]*0.01*material_node_size.width, tempPos[2]*0.01*material_node_size.height))
            end
        end
    end
    --每个勋章的状态
    local first_receive_uids = self.gameData.first_receive_uids
    local player = first_receive_uids[tostring(self.selectId)]
    local user_name = ""
    if player and player.user_name then
        user_name = player.user_name
    end
    self.first_name_label:setString(user_name)

    --每个勋章的倒计时
    local function timeEndFunc()
       local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            self.gameData = json.decode(data:getFormatBuffer()) or {};
            self:refreshUi()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_index"), http_request_method.GET, nil,"medal_index")
    end
    self.count_down_node:removeAllChildrenWithCleanup(true)
    local pos_count_down = self.gameData.pos_count_down
    local count_down_time = pos_count_down[tostring(self.selectId)] or 0
    --加速次数
    self.tips_label:setString("")
    if self.gameData.free_times > 0 then
        self.tips_label:setString("Số lần miễn phí:" .. self.gameData.free_times)
    else
        if self.gameData.quick_train_times < self.gameData.max_quick_train_times then
            self.tips_label:setString("Số lần gia tốc:" .. (self.gameData.max_quick_train_times - self.gameData.quick_train_times))
        end
    end
    if pos_count_down[tostring(self.selectId)] then
        local countdownLabel = game_util:createCountdownLabel(count_down_time,timeEndFunc,8);
        countdownLabel:setColor(ccc3(238,232,190))
        self.count_down_node:addChild(countdownLabel)

        --按钮显示
        if count_down_time > 0 then
            self.m_get_btn:setVisible(false)
            self.m_cancel_btn:setVisible(true)
            self.m_accelerate_btn:setVisible(true)
            self.tips_label:setVisible(true)
        else
            self.m_get_btn:setVisible(true)
            self.m_cancel_btn:setVisible(false)
            self.m_accelerate_btn:setVisible(false)
            self.tips_label:setVisible(false)
        end
    else
        self.m_cancel_btn:setVisible(false)
        self.m_get_btn:setVisible(false)
        self.m_accelerate_btn:setVisible(false)
        self.tips_label:setVisible(false)
    end
    if self.gameData.free_times == 0 and self.gameData.quick_train_times == self.gameData.max_quick_train_times then--加速完了
        self.m_accelerate_btn:setVisible(false)
        self.tips_label:setVisible(false)
    end
end
--[[--
    创建一个接受触摸事件的button
]]
function game_medal_fusion.createTouchButton( self, fun, parent, tag , anchorX, anchorY)
    if not parent then return end
    local button = game_util:createCCControlButton("public_weapon.png","",fun)
    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
    local tempSize = parent:getContentSize()
    button:setAnchorPoint(ccp(0.5,0.5))
    button:setPosition(ccp(tempSize.width * (anchorX or 0.5), tempSize.height* (anchorY or 0.5)))
    button:setOpacity(0)
    parent:addChild(button)
    button:setTag(tag)
end
--[[--
    初始化
]]
function game_medal_fusion.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    self.m_material_node_tab = {}
    self.selectId = t_params.selectId or nil
    self.m_animFlag = true
end

--[[--
    创建ui入口并初始化数据
]]
function game_medal_fusion.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_medal_fusion;