---  超值返利

local game_bigholiday_pop = {

};


--[[--
    销毁uißß
]]
function game_bigholiday_pop.destroy(self)
    self.m_needRefreshViewPos = nil
    self.m_day_tableView = nil
    self.m_lastTableViewPosY = nil
    self.m_day_tableView = nil
    self.m_reward_tableView = nil
    self.m_lastTableViewPosY2 = nil
    self.m_reward_tableView = nil
    -- body
    cclog("----------------- game_bigholiday_pop destroy-----------------");  
end
--[[--
    返回
]]
function game_bigholiday_pop.back(self,backType)
    local function endCallFunc()
        game_scene:removePopByName("game_bigholiday_pop")
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end


--[[--
    读取ccbi创建ui
]]
function game_bigholiday_pop.createUi(self)
    self.m_day_index = 1
    self.m_needRefreshViewPos = true
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_bigholiday_pop.ccbi");

    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_node_days = ccbNode:nodeForName("m_node_days")
    self.m_node_items = ccbNode:nodeForName("m_node_items")
    self.label_time = ccbNode:labelTTFForName("label_time")
    self.label_time:setString("Thời gian HĐ Phản Nạp:")
     -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 11,true);
    self.m_root_layer:setTouchEnabled(true);
    

    self.label_time:setVisible(true)

    self.node_conutdownTime = ccbNode:nodeForName("node_conutdownTime")
    self.node_conutdownTime:removeAllChildrenWithCleanup(true)
    local server_time = game_data:getUserStatusDataByKey("server_time")
    local time_left = self.m_tGameData.end_time - server_time
    local function timeOverCallFun(label,type)
        
    end
    local timeLabel = game_util:createCountdownLabel(time_left,timeOverCallFun,8,1)
    timeLabel:setColor(ccc3(105,238,67))
    timeLabel:setPosition(ccp(self.node_conutdownTime:getContentSize().width/2, self.node_conutdownTime:getContentSize().height/2))
    self.node_conutdownTime:addChild(timeLabel,10,10)

    return ccbNode;
end


--[[--
    刷新ui
]]
function game_bigholiday_pop.refreshUi(self)
    local bigholiday_cfg = getConfig(game_config_field.bigholiday)
    bigholiday_cfg = json.decode(bigholiday_cfg:getFormatBuffer())
    local day_data = {}
    for k,v in pairs(bigholiday_cfg) do
        if v.version == self.m_tGameData.version then
            if not day_data[v.holiday_sort] then
                day_data[v.holiday_sort] = {}
            end
            local data = util.table_copy(v)
            data.id = k

            local record_num = 0
            local record = self.m_tGameData.record[data.holiday_sort]
            if record and record[tostring(data.type)] then
                record_num = record[tostring(data.type)]
            end
            data.index = 2
            if game_util:valueInTeam(data.id, self.m_tGameData.got_reward) then
                data.index = 3
            elseif record_num >= data.num  then
                data.index = 1
            end

            table.insert(day_data[v.holiday_sort], data)
        end
    end

    for k,v in pairs(day_data) do
        table.sort( v, function (data1, data2)
            if data1.index == data2.index then
                if data1.type == data2.type then
                    return tonumber(data1.id) < tonumber(data2.id)
                else
                    return data1.type < data2.type
                end
            else
                return data1.index < data2.index
            end
        end )
    end

    self.m_day_data = day_data
    local day_list = {}
    for k,v in pairs(day_data) do
        table.insert(day_list, k)
    end
    
    table.sort( day_list, function (data1, data2)
        return data1 < data2
    end )

    if self.m_needRefreshViewPos then
        local now_time = self:format_date()
        for i,v in ipairs(day_list) do
            if v == now_time then
                self.m_day_index = i
                break
            end
        end
    end

    if self.m_day_tableView then
        self.m_lastTableViewPosY = self.m_day_tableView:getContentOffset().y
    end

    self.m_node_days:removeAllChildrenWithCleanup(true);
    self.m_day_tableView = self:createDaysTableView(self.m_node_days:getContentSize(), day_list);
    self.m_node_days:addChild(self.m_day_tableView);
    self.m_day_tableView:setScrollBarVisible(false);

    -- 重置位置
    if self.m_lastTableViewPosY then
        local contentSize = self.m_day_tableView:getContentSize()
        self.m_lastTableViewPosY = math.max(-1 * contentSize.height, self.m_lastTableViewPosY)
        self.m_day_tableView:setContentOffset(ccp(0, self.m_lastTableViewPosY), false);
    end



    
    if self.m_needRefreshViewPos then
        self.m_needRefreshViewPos = false
        local bg_height = self.m_node_days:getContentSize().height
        local view_height = self.m_day_tableView:getContentSize().height
        local offy = (self.m_day_index-1) * self.m_ccbNode_size_height 
        local maxOffsetY = view_height - bg_height
        if bg_height > offy then
            offy = math.max(maxOffsetY- offy, maxOffsetY)
        else
            offy = math.max(maxOffsetY- offy, 0)
        end
        self.m_day_tableView:setContentOffset(ccp(0, -offy), false)
    end


    if self.m_reward_tableView then
        self.m_lastTableViewPosY2 = self.m_reward_tableView:getContentOffset().y
    end

    if self.m_day_index2 ~= self.m_day_index then
        self.m_lastTableViewPosY2 = nil
    end

    self.m_node_items:removeAllChildrenWithCleanup(true);
    self.m_reward_tableView = self:createActivitysTableView(self.m_node_items:getContentSize(), self.m_day_data[day_list[self.m_day_index]]);
    self.m_node_items:addChild(self.m_reward_tableView);
    -- self.m_reward_tableView:setScrollBarVisible(false);

    -- 重置位置
    if self.m_lastTableViewPosY2 then
        local contentSize = self.m_reward_tableView:getContentSize()
        self.m_lastTableViewPosY2 = math.max(-1 * contentSize.height, self.m_lastTableViewPosY2)
        self.m_reward_tableView:setContentOffset(ccp(0, self.m_lastTableViewPosY2), false);
    end

    self.m_day_index2 = self.m_day_index

end

-- 获得当天是否有红点
function game_bigholiday_pop.getDayRedPoint(self, day)
    for k,v in pairs(self.m_day_data[day]) do
        local record_num = 0
        local record = self.m_tGameData.record[v.holiday_sort]
        if record and record[tostring(v.type)] then
            record_num = record[tostring(v.type)]
        end
        if not game_util:valueInTeam(v.id, self.m_tGameData.got_reward) and record_num >= v.num then
            return true
        end
    end
end

function game_bigholiday_pop.format_date(self)
    local current_timestamp = game_data:getUserStatusDataByKey("server_time")
    return game_util.timestampToDate(current_timestamp)
end


--[[--
    创建 天数 列表
]]
function game_bigholiday_pop.createDaysTableView(self,viewSize, showData)
    
    local cardsCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = cardsCount --totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.itemActionFlag = false
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_bigholiday_day_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            self.m_ccbNode_size_height = ccbNode:getContentSize().height
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local spr_end = ccbNode:spriteForName("spr_end")
            spr_end:setVisible(false)
            local m_sprite_day_bg = ccbNode:spriteForName("m_sprite_day_bg")
            local spr_day = ccbNode:spriteForName("spr_day")
            local data = showData[index +1]
            local day_data = self.m_day_data[data][1]
            game_util:setSpriteDisplayBySpriteFrameName(spr_day, day_data.icon..".png")
            
            local spr_red = ccbNode:spriteForName("spr_red")            
            local red_flag = self:getDayRedPoint(data)
            spr_red:setVisible(red_flag)

            if self.m_day_index == index +1 then
                game_util:setSpriteDisplayBySpriteFrameName(m_sprite_day_bg, "ui_payplan_xuanzhonganniu.png")
            else
                game_util:setSpriteDisplayBySpriteFrameName(m_sprite_day_bg, "ui_payplan_anniu.png")
            end

            local now_time = self:format_date()
            if now_time >= day_data.holiday_sort then
                m_sprite_day_bg:setColor(ccc3(255,255,255))
                spr_day:setColor(ccc3(255,255,255))
                spr_end:setVisible(now_time > day_data.holiday_sort)
            else
                m_sprite_day_bg:setColor(ccc3(150,150,150))
                spr_day:setColor(ccc3(150,150,150))
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
            local data = showData[index +1]
            local day_data = self.m_day_data[data][1]
            local now_time = self:format_date()
            if now_time >= day_data.holiday_sort then
                self.m_day_index = index +1
                self:refreshUi()
            else
                game_util:addMoveTips({text = "Chưa đến ngày bắt đầu, hãy đợi thêm nhé"})
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
 
    end
    return TableViewHelper:create(params);
end


--[[--
    创建 活动列表 列表
]]
function game_bigholiday_pop.createActivitysTableView(self,viewSize, showData)

    local function onBtnCilck( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local id = showData[btnTag].id
        local function responseMethod( tag, gameData )
            local data = gameData:getNodeWithKey("data");
            game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            self:refreshUi()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("bigholiday_get_reward"), http_request_method.GET, {reward_id = id},"bigholiday_get_reward")
    end
    local cardsCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = cardsCount --totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.itemActionFlag = false
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onBtnCilck);
            ccbNode:openCCBFile("ccb/ui_bigholiday_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            local label_des = ccbNode:labelTTFForName("label_des")
            local label_num = ccbNode:labelTTFForName("label_num")
            local node_rewards = ccbNode:nodeForName("node_rewards")
            local m_sprite_buyselect = ccbNode:spriteForName("m_sprite_buyselect")
            m_sprite_buyselect:setVisible(false)
            local m_btn1 = ccbNode:controlButtonForName("m_btn1")
            m_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
            m_btn1:setTag(index + 1)
            local label_got = ccbNode:labelTTFForName("label_got")
            label_got:setVisible(false)
            local data = showData[index +1]
            label_des:setString(data.des)

            local record_num = 0
            local record = self.m_tGameData.record[data.holiday_sort]
            if record and record[tostring(data.type)] then
                record_num = record[tostring(data.type)]
            end

            label_num:setString("("..record_num.."/"..data.num..")")

            if record_num >= data.num then
                label_num:setColor(ccc3(93,241,53))
            else
                label_num:setColor(ccc3(255,240,200))
            end

            local spr_red = ccbNode:spriteForName("spr_red")            
            m_btn1:setVisible(true)
            if game_util:valueInTeam(data.id, self.m_tGameData.got_reward)  then -- 已领取
                m_btn1:setVisible(false)
                label_got:setVisible(true)
                spr_red:setVisible(false)
            elseif not game_util:valueInTeam(data.id, self.m_tGameData.got_reward) and record_num >= data.num then -- 可领奖
                game_util:setCCControlButtonBackground(m_btn1,"czfl_btn_01.png")
                spr_red:setVisible(true)
            else
                game_util:setCCControlButtonBackground(m_btn1,"czfl_btn_02.png")
                spr_red:setVisible(false)
            end

            node_rewards:removeAllChildrenWithCleanup(true);
            local tableView = self:createRewardTable(node_rewards:getContentSize(), data.reward)
            node_rewards:addChild(tableView,10,10);

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
           
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        -- self.m_selListItem = nil;
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end

function game_bigholiday_pop.createRewardTable(self,viewSize,rewardList)
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemCfg = rewardList[btnTag+1]
        game_util:lookItemDetal(itemCfg)
    end
    local count = #rewardList
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = count; --列
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionHorizontal;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5,0.5))
            node:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            cell:addChild(node)
            local itemGift = rewardList[index+1]
            
            local icon,name,count = game_util:getRewardByItemTable(itemGift, true)
            if icon then
                icon:setScale(0.8)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,0))
                node:addChild(icon,10)
            end
            if name then
                local nameLabel = game_util:createLabelBMFont({text = "×" .. count});
                nameLabel:setAnchorPoint(ccp(0.5, 0.5))
                nameLabel:setPosition(icon:getContentSize().width * 0.5, 5)
                icon:addChild(nameLabel, 11)
            end 
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemCfg = rewardList[index+1]
            game_util:lookItemDetal(itemCfg)
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        
    end
    return TableViewHelper:create(params);
end

--[[--
    初始化
]]
function game_bigholiday_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_bigholiday_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_bigholiday_pop;
