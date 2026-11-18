--- 卡牌炼制
local game_medal_train = {
    table_node = nil,
    free_times_label = nil,
    gameData = nil,
    m_food_total_label = nil,
    m_money_total_label = nil,
};
--[[--
    销毁
]]
function game_medal_train.destroy(self)
    -- body
    cclog("-----------------game_medal_train destroy-----------------");
    self.table_node = nil;
    self.free_times_label = nil;
    self.m_food_total_label = nil;
    self.m_money_total_label = nil;
    self.gameData = nil;
end
--[[--
    返回
]]
function game_medal_train.back(self,backType)
    if backType == "back" then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui
]]
function game_medal_train.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 201 then--返回
            self:back("back");
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_medal_train.ccbi");

    self.table_node = ccbNode:nodeForName("table_node")
    self.free_times_label = ccbNode:labelTTFForName("free_times_label")
    self.m_food_total_label = ccbNode:labelTTFForName("m_food_total_label")
    self.m_money_total_label = ccbNode:labelTTFForName("m_money_total_label")

    return ccbNode;
end

--[[--
    刷新ui
]]
function game_medal_train.refreshUi(self)
    self.table_node:removeAllChildrenWithCleanup(true)
    local m_tableView = self:createTableView(self.table_node:getContentSize());
    m_tableView:setMoveFlag(false)
    self.table_node:addChild(m_tableView);

    if self.gameData.free_times > 0 then
        self.free_times_label:setString("Gia tốc miễn phí hôm nay:" .. self.gameData.free_times)
    else
        self.free_times_label:setString("Hôm nay gia tốc còn:" .. (self.gameData.max_quick_train_times - self.gameData.quick_train_times))
    end

    local food = game_data:getUserStatusDataByKey("food") or 1;
    local coin = game_data:getUserStatusDataByKey("coin") or 1;

    local value,unit = game_util:formatValueToString(food)
    local value2,unit2 = game_util:formatValueToString(coin)
    self.m_food_total_label:setString(tostring(value .. unit));
    self.m_money_total_label:setString(tostring(value2 .. unit2));
end
--[[
    训练位
]]
function game_medal_train.createTableView(self,viewSize)
    local trainData = self.gameData["train"]
    local pos_count_down = self.gameData["pos_count_down"]
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local index = 0
        if btnTag > 10 and btnTag < 20 then--领取
            index = btnTag - 10
            local function responseMethod(tag,gameData)
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local data = gameData:getNodeWithKey("data")
                    self.gameData = json.decode(data:getFormatBuffer()) or {};
                    local reward = data:getNodeWithKey("reward")
                    game_util:rewardTipsByJsonData(reward);
                    self:refreshUi()
                end
            end
            local material_key = trainData[tostring(index)].material_id
            local params = {}
            params.material_id = material_key
            params.sort = 4
            params.pos = index
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_train_material"), http_request_method.GET, params,"medal_train_material")
        elseif btnTag > 20 and btnTag < 30 then--停止
            index = btnTag - 20
            local function responseMethod(tag,gameData)
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local data = gameData:getNodeWithKey("data")
                    self.gameData = json.decode(data:getFormatBuffer()) or {};
                    local reward = data:getNodeWithKey("reward")
                    game_util:rewardTipsByJsonData(reward);
                    game_util:closeAlertView();
                    self:refreshUi()
                end
            end
            local material_key = trainData[tostring(index)].material_id
            local params = {}
            params.material_id = material_key
            params.sort = 3
            params.pos = index
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_train_material"), http_request_method.GET, params,"medal_train_material")
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = "Dừng huấn luyện chứ?",      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-20,
            }
            game_util:openAlertView(t_params);
        elseif btnTag > 30 and btnTag < 40 then--加速
            index = btnTag - 30
            local function responseMethod(tag,gameData)
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local data = gameData:getNodeWithKey("data")
                    self.gameData = json.decode(data:getFormatBuffer()) or {};
                    local reward = data:getNodeWithKey("reward")
                    game_util:rewardTipsByJsonData(reward);
                    game_util:closeAlertView();
                    self:refreshUi()
                end
            end
            local material_key = trainData[tostring(index)].material_id
            local params = {}
            params.material_id = material_key
            params.sort = 2
            params.pos = index
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
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_train_material"), http_request_method.GET, params,"medal_train_material")
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = tipsText,      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-20,
            }
            game_util:openAlertView(t_params);
        elseif btnTag > 40 then--选择
            index = btnTag - 40
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_medal_charts",{gameData = gameData});
                self:back();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_index"), http_request_method.GET, nil,"medal_index")
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = 4
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_medal_train_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            local offset = 0
            if index == 1 or index == 2 then
                offset = 15
            end
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5 - offset));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            
            local btn_accelerate = ccbNode:controlButtonForName("btn_accelerate")
            local btn_stop = ccbNode:controlButtonForName("btn_stop")
            local rest_time_label = ccbNode:labelTTFForName("rest_time_label")
            local btn_get = ccbNode:controlButtonForName("btn_get")
            local btn_select = ccbNode:controlButtonForName("btn_select")

            local tips_text = ccbNode:spriteForName("tips_text")
            tips_text:runAction(game_util:createRepeatForeverFade());

            local anim_node = ccbNode:nodeForName("anim_node")
            local open_node = ccbNode:nodeForName("open_node")

            btn_get:setTag(11 + index)
            btn_stop:setTag(21 + index)
            btn_accelerate:setTag(31 + index)
            btn_select:setTag(41 + index)
            btn_select:setOpacity(0)

            local itemData = trainData[tostring(index + 1)]--这里取是否完成和材料id
            local item_pos_count_down = pos_count_down[tostring(index + 1)]--这里单取倒计时

            local material_id = itemData.material_id
            if material_id == "" then--没有训练的
                open_node:setVisible(false)
                tips_text:setVisible(true)
                btn_select:setEnabled(true)
            else
                tips_text:setVisible(false)
                open_node:setVisible(true)
                btn_select:setEnabled(false)
                anim_node:removeAllChildrenWithCleanup(true)
                local tempIcon = game_util:createMedalItemByCCB3({key = material_id})
                if tempIcon then
                    anim_node:addChild(tempIcon)
                end
                local function timeEndFunc(label,type)
                    btn_stop:setVisible(false)
                    btn_accelerate:setVisible(false)
                    btn_get:setVisible(true)

                    --设置绿色
                    rest_time_label:removeAllChildrenWithCleanup(true)
                    local text = game_util:createLabelTTF({text = "Đã xong",color = ccc3(42,227,43),fontSize = 10})
                    text:setAnchorPoint(ccp(0,0.5))
                    text:setPosition(ccp(rest_time_label:getContentSize().width + 3,rest_time_label:getContentSize().height*0.5))
                    rest_time_label:addChild(text)
                    if tempIcon then
                        local tempSprite = tempIcon:getChildByTag(1000)
                        local tempSprite2 = tempIcon:getChildByTag(1100)
                        if tempSprite then
                            tempSprite:removeFromParentAndCleanup(true)
                        end
                        if tempSprite2 then
                            tempSprite2:removeFromParentAndCleanup(true)
                        end
                    end
                end
                local countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8);
                countdownLabel:setColor(ccc3(238,232,190))
                countdownLabel:setAnchorPoint(ccp(0,0.5))
                countdownLabel:setPosition(ccp(rest_time_label:getContentSize().width + 3,rest_time_label:getContentSize().height*0.5))
                rest_time_label:addChild(countdownLabel)
                -- item_pos_count_down = 0
                if item_pos_count_down > 0 then
                    btn_stop:setVisible(true)
                    btn_accelerate:setVisible(true)
                    btn_get:setVisible(false)

                    countdownLabel:setTime(item_pos_count_down)
                    --加正在炼制的tips
                    if tempIcon then
                        local tempSize = tempIcon:getContentSize()
                        local layerColor = CCLayerColor:create(ccc4(0,0,0, 150), tempSize.width, tempSize.height)
                        -- layerColor:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5))
                        local spite = CCSprite:createWithSpriteFrameName("medal_tip2.png");
                        spite:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5))
                        tempIcon:addChild(layerColor,10,1000)
                        tempIcon:addChild(spite,10,1100)
                    end
                else
                    countdownLabel:setTime(0)
                    timeEndFunc()
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    初始化
]]
function game_medal_train.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
end
--[[--
    创建入口
]]
function game_medal_train.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_medal_train;
