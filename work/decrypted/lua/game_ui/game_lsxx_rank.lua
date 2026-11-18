---  乱世枭雄  排行
local game_lsxx_rank = {
    rank_index = nil,
    m_tab_btn_2 = nil,
    m_tab_btn_3 = nil,
    btn_time = nil,
    reward_node = nil,
    people_node = nil,
    time_label = nil,
    table_node = nil,
    time_index = nil,
    m_tGameData = nil,
    large_super_rich_all = nil,
    time_node = nil,
    time_node2 = nil,
};
--[[--
    销毁ui
]]
function game_lsxx_rank.destroy(self)
    cclog("----------------- game_lsxx_rank destroy-----------------"); 

    self.rank_index = nil;
    self.m_tab_btn_2 = nil;
    self.m_tab_btn_3 = nil;
    self.btn_time = nil;
    self.reward_node = nil;
    self.people_node = nil;
    self.time_label = nil;
    self.table_node = nil;
    self.time_index = nil;
    self.m_tGameData = nil;
    self.large_super_rich_all = nil;
    self.time_node = nil;
    self.time_node2 = nil;
end
--[[--
    返回
]]
function game_lsxx_rank.back(self)
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
    self:destroy();
end

function game_lsxx_rank.refreshBtn(self)
    local btn1_flag = true
    local btn2_flag = true
    if self.rank_index == 1 then
        btn1_flag = true
        btn2_flag = false
    else
        btn1_flag = false
        btn2_flag = true
    end
    self.m_tab_btn_2:setHighlighted(btn1_flag);
    self.m_tab_btn_2:setEnabled(not btn1_flag);
    self.m_tab_btn_3:setHighlighted(btn2_flag);
    self.m_tab_btn_3:setEnabled(not btn2_flag);
    self:refreshTableView()
end
--[[--
    读取ccbi创建ui
]]
function game_lsxx_rank.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 3 or btnTag == 4 then
            local index = btnTag - 2
            self.rank_index = index
            self:refreshBtn()
        elseif btnTag == 12 then--详情
            local notice = self.large_super_rich_all["1"].notice
            game_scene:addPop("game_active_limit_detail_pop",{ openMsg = notice})
        elseif btnTag > 100 and btnTag < 104 then
            self.time_index = btnTag - 100
            self:refreshReward()
        elseif btnTag == 201 then--本服奖励
            game_scene:addPop("game_lsxx_rank_reward_pop",{version = self.m_tGameData.version,show_index = 1})
        elseif btnTag == 202 then--跨服奖励
            game_scene:addPop("game_lsxx_rank_reward_pop",{version = self.m_tGameData.version,show_index = 2})
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_lsxx_rank.ccbi");

    self.table_node = ccbNode:nodeForName("table_node")
    self.time_node = ccbNode:nodeForName("time_node")
    self.time_node2 = ccbNode:nodeForName("time_node2")
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScale(resolution_config:getScale())
    
    local m_other_reward_btn2 = ccbNode:controlButtonForName("m_other_reward_btn2")
    m_other_reward_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2);
    self.btn_time = {}
    self.reward_node = {}
    self.people_node = {}
    self.time_label = {}
    for i=1,3 do
        self.btn_time[i] = ccbNode:controlButtonForName("btn_time" .. i)
        self.reward_node[i] = ccbNode:nodeForName("reward_node" .. i)
        self.people_node[i] = ccbNode:nodeForName("people_node" .. i)
        self.time_label[i] = ccbNode:labelTTFForName("time_label" .. i)
    end

    self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2")
    self.m_tab_btn_3 = ccbNode:controlButtonForName("m_tab_btn_3")
    self.m_tab_btn_2:setHighlighted(true)
    self.m_tab_btn_2:setEnabled(false)

    -- local m_root_layer = ccbNode:layerForName("m_root_layer")
    -- local function onTouch(eventType, x, y)
    --     if eventType == "began" then
    --         return true;--intercept event
    --     end
    -- end
    -- m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    -- m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[
    竖的table
]]
function game_lsxx_rank.createRankTable(self,viewSize)
    local showData = {}
    if self.rank_index == 1 then--跨服排行
        showData = self.m_tGameData.all_score_ranks
    else
        showData = self.m_tGameData.own_score_ranks
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = game_util:getTableLen(showData);
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_active_limit_rank_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local detail_label = ccbNode:labelTTFForName("detail_label");
            local detail_label_score = ccbNode:labelTTFForName("detail_label_score");

            local itemData = showData[tostring(index + 1)]
            detail_label:setPositionX(-18)
            local rank = itemData.rank or (index + 1)
            local text = rank .. ". " .. itemData.name
            if itemData.server_name then
                local result = util.stringSplit(itemData.server_name,"-");
                text = rank .. ". " .. itemData.name .. "(" .. result[1] .. ")"
            end
            detail_label:setString(text)

            detail_label_score:setColor(ccc3(0,253,0))
            detail_label_score:setPositionX(138)
            detail_label_score:setString(itemData.score)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            
        end
    end
    return TableViewHelper:create(params);
end
--[[
    刷新table
]]
function game_lsxx_rank.refreshTableView(self)
    self.table_node:removeAllChildrenWithCleanup(true)
    local rankTable = self:createRankTable(self.table_node:getContentSize())
    self.table_node:addChild(rankTable)
end
--[[--
    刷新ui
]]
function game_lsxx_rank.refreshUi(self)
    self:refreshTableView()

    self:refreshReward()

    --倒计时
    self.time_node:removeAllChildrenWithCleanup(true)
    local function timeEndFunc()
       self.time_node:removeAllChildrenWithCleanup(true)
       local tipsLabel = game_util:createLabelTTF({text = "Đã kết thúc",color = ccc3(0,255,0),fontSize = 10});
        tipsLabel:setAnchorPoint(ccp(0.5,0.5))
        tipsLabel:setPosition(ccp(0,0))
        self.time_node:addChild(tipsLabel,10,12)
    end
    local countdownLabel = game_util:createCountdownLabel(tonumber(self.m_tGameData.time_count_down),timeEndFunc,8, 3);
    countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    countdownLabel:setPosition(ccp(0,0))
    countdownLabel:setColor(ccc3(0,255,0))
    self.time_node:addChild(countdownLabel,10,10)

    if tonumber(self.m_tGameData.time_count_down) <= 0 then
        countdownLabel:setTime(1)
    end

    --阶段结束倒计时
    self.time_node2:removeAllChildrenWithCleanup(true)
    local function timeEndFunc2()
       self.time_node2:removeAllChildrenWithCleanup(true)
       local tipsLabel = game_util:createLabelTTF({text = "Đã kết thúc",color = ccc3(0,255,0),fontSize = 10});
        tipsLabel:setAnchorPoint(ccp(0.5,0.5))
        tipsLabel:setPosition(ccp(0,0))
        self.time_node2:addChild(tipsLabel,10,12)
    end
    local step_time = self.m_tGameData.step_time or 1
    local countdownLabel2 = game_util:createCountdownLabel(tonumber(step_time),timeEndFunc2,8, 3);
    countdownLabel2:setAnchorPoint(ccp(0.5,0.5))
    countdownLabel2:setPosition(ccp(0,0))
    countdownLabel2:setColor(ccc3(0,255,0))
    self.time_node2:addChild(countdownLabel2,10,10)

    if tonumber(step_time) <= 0 then
        countdownLabel2:setTime(1)
    end
end
--[[
    刷新奖励
]]
function game_lsxx_rank.refreshReward(self)
    local firstCfg = self.large_super_rich_all["1"]--第1名的
    local secondCfg = self.large_super_rich_all["2"]--第2名的
    local thirdCfg = self.large_super_rich_all["3"]--第3名的

    local showReward = {"show12","show21","show24"}

    local reward1 = firstCfg[showReward[self.time_index]]
    local reward2 = secondCfg[showReward[self.time_index]]
    local reward3 = thirdCfg[showReward[self.time_index]]

    local rewardTable = {reward1,reward2,reward3}
    for i=1,3 do
        local reward = rewardTable[i]
        self.reward_node[i]:removeAllChildrenWithCleanup(true)
        local tempTableView = self:createItemRewardTable(self.reward_node[i]:getContentSize(),reward);
        tempTableView:ignoreAnchorPointForPosition(true);
        tempTableView:setAnchorPoint(ccp(0.5,0.5));
        self.reward_node[i]:addChild(tempTableView)

        self.btn_time[i]:setHighlighted(false)
        self.btn_time[i]:setEnabled(true)
    end

    self.btn_time[self.time_index]:setHighlighted(true)
    self.btn_time[self.time_index]:setEnabled(false)

    --人物
    local step_top_three_users = self.m_tGameData.step_top_three_users
    local ranks = {"12","21","24"}
    for i=1,3 do
        self.people_node[i]:removeAllChildrenWithCleanup(true)
        local itemRanks = step_top_three_users[ranks[self.time_index]]
        if itemRanks[tostring(i)] then
            local itemData = itemRanks[tostring(i)]
            local role = itemData.role
            local nameLabel = game_util:createLabelTTF({text = itemData.name,color = ccc3(0,253,0)})
            local serverLabel = game_util:createLabelTTF({text = itemData.server_name,color = ccc3(0,253,0)})
            nameLabel:setFontSize(8);
            serverLabel:setFontSize(9);
            nameLabel:setPosition(ccp(0,-5))
            serverLabel:setPosition(ccp(0,10))
            self.people_node[i]:addChild(nameLabel)
            self.people_node[i]:addChild(serverLabel)
        else
            local noneLabel = game_util:createLabelTTF({text = "Chưa kết toán",color = ccc3(0,253,0)})
            self.people_node[i]:addChild(noneLabel)
        end
    end
end
function game_lsxx_rank.createItemRewardTable(self,viewSize,rewardTab)
    local rewardTab = rewardTab or {};
    local tempCount = #rewardTab
    local params = {};
    params.row = 1;--行
    params.column = math.min(2,#rewardTab); --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = #rewardTab
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.viewSize = CCSizeMake(2 * itemSize.width, viewSize.height);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local icon,name,count = game_util:getRewardByItemTable(rewardTab[index+1],true)
            if icon then
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
                icon:setScale(0.65);
                cell:addChild(icon)

            end
            if count then
                local tempLabel = game_util:createLabelBMFont({text = "×" .. count,scale = 0.9});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.1))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(rewardTab[index+1]);
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    初始化
]]
function game_lsxx_rank.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.rank_index = 1
    local large_super_rich_all = getConfig(game_config_field.large_super_rich_all)
    self.large_super_rich_all = {}
    large_super_rich_all = json.decode(large_super_rich_all:getFormatBuffer()) or {}

    for k,v in pairs(large_super_rich_all) do
        if v.version == self.m_tGameData.version then--
            local itemCfgTable = v
            itemCfgTable.id = k
            -- table.insert( self.large_super_rich_all, itemCfgTable )
            local rank = itemCfgTable.rank
            --只取前3的
            if rank == 1 or rank == 2 or rank == 3 then
                self.large_super_rich_all[tostring(rank)] = itemCfgTable
            end
        end
    end
    self.time_index = self.m_tGameData.step_id or 1
    local vip_limit = t_params.VIP_limit or nil
    local needVip = t_params.needVip or 3
    if vip_limit and vip_limit == "true" then
        local t_params = 
          {
              title = string_config.m_title_prompt,
              okBtnCallBack = function(target,event)
                  local function responseMethod(tag,gameData)
                      if gameData then
                        game_util:closeAlertView();
                        game_scene:enterGameUi("ui_vip",{gameData = gameData});
                      else
                      end
                  end
                  network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step",true,true)
              end,   --可缺省
              closeCallBack = function(target,event)
                local function responseMethod( tag,gameData )
                    if gameData then
                        game_util:closeAlertView();
                        self:back()
                    else
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("large_super_rich_index"), http_request_method.GET, nil,"large_super_rich_index",true,true)
              end,
              okBtnText = "Xác nhận",       --可缺省
              text = "Cấp VIP của bạn không đủ. Đạt đến VIP" .. needVip ..  "là có thể tham gia vào sự kiện này",      --可缺省
          }
          game_util:openAlertView(t_params);
    else
        cclog("vip等级达到了要求~")
    end
    -- local function sortfunction(data1,data2)
    --     return data1.rank < data2.rank
    -- end
    -- table.sort( self.large_super_rich_all, sortfunction )
    -- cclog2(self.large_super_rich_all,"large_super_rich_all")
end
--[[--
    创建ui入口并初始化数据
]]
function game_lsxx_rank.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_lsxx_rank