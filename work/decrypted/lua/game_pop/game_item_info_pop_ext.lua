--- 信息ext 可选择购买

local game_item_info_pop_ext = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_itemId = nil,
    m_callBackFunc = nil,
    m_openType = nil,
    m_look_flag = nil,
    maxCount = nil,
    alreadyCount = nil,
    tempId = nil,
    buy_call_back = nil,

};

--[[--
    销毁
]]
function game_item_info_pop_ext.destroy(self)
    -- body
    cclog("-----------------game_item_info_pop_ext destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_itemId = nil;
    self.m_callBackFunc = nil;
    self.m_openType = nil;
    self.m_look_flag = nil;
    self.maxCount = nil;
    self.alreadyCount = nil;
    self.tempId = nil;
    self.buy_call_back = nil;
end
--[[--
    返回
]]
function game_item_info_pop_ext.back(self,type)
    game_scene:removePopByName("game_item_info_pop_ext");
end
--[[--
    读取ccbi创建ui
]]
function game_item_info_pop_ext.createUi(self)
    local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(self.m_itemId));
    local itemName = ""
    local itemStory = ""
    local is_use = 0
    if config_date then
        itemName = config_date:getNodeWithKey("name"):toStr();
        itemStory = config_date:getNodeWithKey("story"):toStr();
        is_use = config_date:getNodeWithKey("is_use"):toInt();
    end
    local ccbNode = luaCCBNode:create();
    local itemCount = count;
    local function responseMethod(tag,gameData)
        game_data_statistics:useItem({itemId = self.m_itemId,count = 1})
        if self.m_callBackFunc then
            self.m_callBackFunc();
        end
        local rewardCount = game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("effect"));
        if rewardCount and rewardCount == 0 then
            game_util:addMoveTips({text = tostring(itemName) .. "Dùng thành công!"});
        end
        self:back();
    end
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " .. btnTag)
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then
            if self.need_1 ~= #self.select_table1 then
                game_util:addMoveTips({text = "Xin chọn chính xác số lượng nguyên liệu!"})
            elseif self.need_2 ~= #self.select_table2 then
                game_util:addMoveTips({text = "Xin chọn chính xác số lượng phần thưởng!"})
            else
                local params = "&item_id=" .. self.item_id .. "&num=1"
                for i=1,#self.select_table1 do
                    params = params .. "&type_list=" .. self.select_table1[i]
                end
                for i=1,#self.select_table2 do
                    params = params .. "&type_list_1=" .. self.select_table2[i]
                end
                local function responseMethod(tag,gameData)
                    local reward = json.decode(gameData:getNodeWithKey("data"):getNodeWithKey("effect"):getFormatBuffer())
                    -- game_scene:enterGameUi("items_scene",{gameData = nil});
                    self:callBackFunc()
                    game_util:rewardTipsByDataTable(reward);
                    self:back()
                    self:destroy();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_use"), http_request_method.GET, params,"item_use")
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_item_ext_pop.ccbi");
    m_root_layer = ccbNode:layerForName("m_root_layer")
    
    local function onTouch( eventType,x,y )
        -- body
        if(eventType == "began")then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);

    self.table_node1 = ccbNode:nodeForName("table_node1")
    self.table_node2 = ccbNode:nodeForName("table_node2")
    self.num_label1 = ccbNode:labelTTFForName("num_label1")
    self.num_label2 = ccbNode:labelTTFForName("num_label2")
    self.num_label3 = ccbNode:labelTTFForName("num_label3")
    self.num_label4 = ccbNode:labelTTFForName("num_label4")
    self.num_label4:setString("0")
    self.num_label2:setString("0")

    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local m_left_btn = ccbNode:controlButtonForName("m_left_btn")

    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
    m_left_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)

    local touchLayer = CCLayer:create()
    m_root_layer:addChild(touchLayer)
    local function onTouch( eventType,x,y )
        if(eventType == "began")then
            return true;
        end
    end
    touchLayer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-9,true);
    touchLayer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_item_info_pop_ext.refreshUi(self)
    self.table_node1:removeAllChildrenWithCleanup(true)
    local tempView1 = self:createTableView(self.table_node1:getContentSize(),1)
    self.table_node1:addChild(tempView1)

    self.table_node2:removeAllChildrenWithCleanup(true)
    local tempView2 = self:createTableView(self.table_node2:getContentSize(),2)
    self.table_node2:addChild(tempView2)
end

--[[
    创建table
]]
function game_item_info_pop_ext.createTableView(self,viewSize,rewardIndex)
    local itemsCfg = getConfig(game_config_field.item)
    local config_date = itemsCfg:getNodeWithKey(tostring(self.item_id));
    local use_effect = config_date:getNodeWithKey("use_effect"):getNodeAt(0):toStr()
    local boxCfg = getConfig(game_config_field.box)
    local itemBox = boxCfg:getNodeWithKey(tostring(use_effect))
    -- cclog2(itemBox,"itemBox")
    local itemReward = itemBox:getNodeAt(rewardIndex-1)
    local reward = itemReward:getNodeWithKey("reward")
    local num = itemReward:getNodeWithKey("num"):toInt()

    if rewardIndex == 1 then
        self.need_1 = num
        self.num_label1:setString(num)
    else
        self.need_2 = num
        self.num_label3:setString(num)
    end

    local totalItem = reward:getNodeCount()

    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = math.min(totalItem,4); --列
    params.totalItem = totalItem;
    -- params.itemActionFlag = true
    params.showPoint = true
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-21;
    params.direction = kCCScrollViewDirectionHorizontal;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_item_ext_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            local m_node = ccbNode:nodeForName("m_node")
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            local m_limit_label = ccbNode:labelBMFontForName("m_limit_label")
            local cd_node = ccbNode:nodeForName("cd_node")

            m_node:removeAllChildrenWithCleanup(true)
            local itemCfg = reward:getNodeAt(index)
            -- cclog2(itemCfg,"itemCfg")
            local icon,name,count = game_util:getRewardByItem(itemCfg)
            if icon then
                icon:setScale(0.75)
                m_node:addChild(icon)
            end
            m_name_label:setString(name)
            m_limit_label:setString("×" .. count)

            local select_table = {}
            if rewardIndex == 1 then
                select_table = self.select_table1
            else
                select_table = self.select_table2
            end
            local flag,k = game_util:idInTableById(index+1,select_table);
            if flag then
                cd_node:setVisible(true)
            else
                cd_node:setVisible(false)
            end

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)        
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local cd_node = ccbNode:nodeForName("cd_node")

            local select_table = {}
            local text_label = nil
            local num = 0
            if rewardIndex == 1 then
                select_table = self.select_table1
                text_label = self.num_label2
                num = self.need_1
            else
                select_table = self.select_table2
                text_label = self.num_label4
                num = self.need_2
            end
            local flag,k = game_util:idInTableById(index+1,select_table);
            if flag and k ~= nil then
                table.remove(select_table,k);
                cd_node:setVisible(false)
            else
                if #select_table >= num then
                    game_util:addMoveTips({text = "Số lượng chọn đã đạt giới hạn!"})
                else
                    table.insert(select_table,index+1)
                    cd_node:setVisible(true)
                end
            end
            text_label:setString(#select_table)
        end
    end
    return TableViewHelper:createGallery3(params);
end

--[[--
    初始化
]]
function game_item_info_pop_ext.init(self,t_params)
    t_params = t_params or {};
    self.m_tParams = t_params
    self.item_id = t_params.item_id
    self.select_table1 = {}
    self.select_table2 = {}
    self.need_1 = 0
    self.need_2 = 0
end

--[[--
    回调方法
]]
function game_item_info_pop_ext.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params)
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_item_info_pop_ext.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_item_info_pop_ext;