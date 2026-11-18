---  乱世枭雄
local game_lsxx = {
    m_tGameData = nil,
    tips_label = nil,
    table_node = nil,
    reward_node = nil,
    score_label = nil,
    country_node = nil,
    progress_node = nil,
    value_label = nil,
    large_super_all = nil,
    rewardCfg = nil,
    btn_get = nil,
    time_node = nil,
};
--[[--
    销毁ui
]]
function game_lsxx.destroy(self)
    cclog("----------------- game_lsxx destroy-----------------"); 

    self.m_tGameData = nil;
    self.tips_label = nil;
    self.table_node = nil;
    self.reward_node = nil;
    self.score_label = nil;
    self.country_node = nil;
    self.progress_node = nil;
    self.value_label = nil;
    self.large_super_all = nil;
    self.rewardCfg = nil;
    self.btn_get = nil;
    self.time_node = nil;
end
--[[--
    返回
]]
function game_lsxx.back(self)
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_lsxx.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 12 then--详情
            local notice = self.rewardCfg.notice
            game_scene:addPop("game_active_limit_detail_pop",{ openMsg = notice})
        elseif btnTag == 101 then--领取第一名奖励
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                local reward = data:getNodeWithKey("reward")
                game_util:rewardTipsByJsonData(reward);
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("large_super_all_first_complete_reward"), http_request_method.GET, {id = self.rewardCfg.id},"large_super_all_first_complete_reward")
        elseif btnTag == 200 then--排行榜
            game_scene:addPop("game_lsxx_rank_pop",{gameData = self.m_tGameData})
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_lsxx.ccbi");

    self.score_label = ccbNode:labelTTFForName("score_label")
    self.country_node = {}
    for i=1,7 do
        self.country_node[i] = ccbNode:nodeForName("country_node" .. i)
    end
    self.progress_node = ccbNode:nodeForName("progress_node")
    self.value_label = {}
    for i=1,4 do
        self.value_label[i] = ccbNode:labelTTFForName("value_label" .. i)
    end
    self.table_node = ccbNode:nodeForName("table_node")
    self.reward_node = ccbNode:nodeForName("reward_node")

    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScale(resolution_config:getScale())

    self.tips_label = ccbNode:labelTTFForName("tips_label")
    self.btn_get = ccbNode:controlButtonForName("btn_get")
    self.time_node = ccbNode:nodeForName("time_node")
    self.tips_label:setString(self.rewardCfg.des)
    return ccbNode;
end

--[[
    竖的table
]]
function game_lsxx.createRankTable(self,viewSize)
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local index = btnTag - 100
        local itemCfg = self.large_super_all[index + 1]

        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data");
            local reward = data:getNodeWithKey("reward")
            game_util:rewardTipsByJsonData(reward);
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            self:refreshUi()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("large_super_all_get_score_reward"), http_request_method.GET, {id = itemCfg.id},"large_super_all_get_score_reward")
    end
    local now_percent = math.floor(self.m_tGameData.own_country_score / self.m_tGameData.max_score * 100)

    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #self.large_super_all;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_game_lsxx_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            
            local btn_get = ccbNode:controlButtonForName("btn_get")
            btn_get:setTag(100 + index)

            local select_alpha = ccbNode:scale9SpriteForName("select_alpha")
            local show_node = ccbNode:nodeForName("show_node")

            local reward_node = ccbNode:nodeForName("reward_node")
            local task_label = ccbNode:labelTTFForName("task_label")

            local itemCfg = self.large_super_all[index + 1]
            local percent = itemCfg.percent
            local score = math.floor(self.m_tGameData.max_score * (percent / 100))
            task_label:setString("Thu hồi lãnh thổ :" .. score)

            reward_node:removeAllChildrenWithCleanup(true)
            local reward = itemCfg.reward
            local base = itemCfg.base
            local tempTableView = self:createItemRewardTable(reward_node:getContentSize(),reward);
            tempTableView:ignoreAnchorPointForPosition(true);
            tempTableView:setAnchorPoint(ccp(0.5,0.5));
            reward_node:addChild(tempTableView)

            if now_percent >= percent then
                show_node:setVisible(false)
                btn_get:setVisible(true)
                if game_util:idInTableById(tonumber(itemCfg.id),self.m_tGameData.large_super_all_reward) then--已领取
                    game_util:setCCControlButtonTitle(btn_get,"Đã nhận")
                    btn_get:setEnabled(false)
                    game_util:setCCControlButtonBackground(btn_get,"offer_btn_blue.png")
                else
                    game_util:setCCControlButtonTitle(btn_get,"Nhận")
                    btn_get:setEnabled(true)
                    game_util:setCCControlButtonBackground(btn_get,"offer_btn_green.png")
                    if self.m_tGameData.score > base then--大于才能领
                        btn_get:setEnabled(true)
                    else
                        btn_get:setEnabled(false)
                    end
                end
            else
                btn_get:setVisible(false)
                show_node:setVisible(true)
            end
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
function game_lsxx.createItemRewardTable(self,viewSize,rewardTab)
    local rewardTab = rewardTab or {};
    local tempCount = #rewardTab
    local params = {};
    params.row = 1;--行
    params.column = 2; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = #rewardTab
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

--[[
    奖励列表
]]
function game_lsxx.createRewardTable(self,viewSize)
    --取 large_super_all    -1的奖励
    local reward = self.rewardCfg.reward
    local totalItem = 2
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 2; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = #reward;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.viewSize = CCSizeMake(totalItem * itemSize.width, viewSize.height);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local icon,name,count = game_util:getRewardByItemTable(reward[index + 1],true)
            if icon then
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
                icon:setScale(0.7);
                cell:addChild(icon)
            end
            if count then
                local tempLabel = game_util:createLabelBMFont({text = "×" .. count});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.1))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(reward[index+1]);
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_lsxx.refreshUi(self)
    self.score_label:setString(self.m_tGameData.own_country_score .. "/" .. self.m_tGameData.max_score)
    
    self.reward_node:removeAllChildrenWithCleanup(true)
    local rewardTable = self:createRewardTable(self.reward_node:getContentSize())
    self.reward_node:addChild(rewardTable)

    self.table_node:removeAllChildrenWithCleanup(true)
    local rankTable = self:createRankTable(self.table_node:getContentSize())
    self.table_node:addChild(rankTable)

    local all_country_score = self.m_tGameData.all_country_score
    local perValue = math.floor(self.m_tGameData.max_score / 4)
    for i=1,7 do
        self.country_node[i]:removeAllChildrenWithCleanup(true)
        local itemScore = all_country_score[tostring(i)]
        if itemScore then
            local layerColor = CCSprite:createWithSpriteFrameName("lsxx_back_alpha.png");
            layerColor:setPosition(ccp(0,-5))
            self.country_node[i]:addChild(layerColor)

            local text = CCSprite:createWithSpriteFrameName("lsxx_tips_shoufu.png");
            text:setPosition(ccp(-15,0))
            self.country_node[i]:addChild(text)

            local label = game_util:createLabelTTF({text = itemScore[2],color = ccc3(134,236,72)})
            label:setAnchorPoint(ccp(0,0.5))
            label:setPosition(ccp(0,0))
            self.country_node[i]:addChild(label)

            local server_label = game_util:createLabelTTF({text = itemScore[4],color = ccc3(115,250,150)})
            server_label:setAnchorPoint(ccp(0.5,0.5))
            server_label:setPosition(ccp(0,-10))
            self.country_node[i]:addChild(server_label)
        end
        if i <= 4 then
            local value = perValue * i
            -- self.value_label[i]:setString(value)
            self.value_label[i]:setString("")
        end
        if self.m_tGameData.own_country_id == i then--我的服务器ID
            local ownSprite = CCSprite:createWithSpriteFrameName("lsxx_my.png");
            ownSprite:setPosition(ccp(-40,0))
            self.country_node[i]:addChild(ownSprite,10)
        end
        --第一的服务器
        if self.m_tGameData.first_country_id == i then
            local firstSprite = CCSprite:createWithSpriteFrameName("lsxx_no1.png");
            firstSprite:setPosition(ccp(-15,15))
            self.country_node[i]:addChild(firstSprite,10)
        end
    end

    local scoreTab = {0,0,0,0,0,0}
    self.progress_node:removeAllChildrenWithCleanup(true)
    local bar = ExtProgressTime:createWithFrameName("lsxx_progress_back.png","lsxx_progress.png");
    bar:setMaxValue(self.m_tGameData.max_score)
    bar:setAnchorPoint(ccp(0.5,0.5))
    
    self.progress_node:addChild(bar,10,10)
    local barWidth = bar:getContentSize().width
    for i=1,6 do
        local itemCfg = self.large_super_all[i]
        local percent = itemCfg.percent
        local score = math.floor(self.m_tGameData.max_score * (percent / 100))
        local label = game_util:createLabelTTF({text = score})
        scoreTab[i] = score
        label:setPosition(ccp(((i - 3) * barWidth) / 6,-15))
        local point = CCSprite:createWithSpriteFrameName("lsxx_rank_point.png")
        point:setPosition(ccp(((i - 3) * barWidth) / 6,-5))
        if i < 6 then
            self.progress_node:addChild(label,10)
            self.progress_node:addChild(point,10)
        end
    end
    local value = self.m_tGameData.own_country_score
    value = game_util:getSectionBarValue(self.m_tGameData.own_country_score,scoreTab)
    bar:setCurValue(value,false)
    --第一个达到的奖励
    if self.m_tGameData.own_country_id == self.m_tGameData.first_country_id then
        if game_util:idInTableById(tonumber(self.rewardCfg.id),self.m_tGameData.large_super_all_reward) then
            game_util:setCCControlButtonTitle(self.btn_get,"Đã nhận")
            game_util:setCCControlButtonBackground(self.btn_get,"offer_btn_blue.png")
            self.btn_get:setEnabled(false)
        else
            game_util:setCCControlButtonTitle(self.btn_get,"Nhận")
            game_util:setCCControlButtonBackground(self.btn_get,"offer_btn_green.png")
            self.btn_get:setEnabled(true)
        end
    else
        game_util:setCCControlButtonTitle(self.btn_get,"Nhận")
        game_util:setCCControlButtonBackground(self.btn_get,"offer_btn_blue.png")
        self.btn_get:setEnabled(false)
    end

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
end

--[[--
    初始化
]]
function game_lsxx.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end

    local large_super_all = getConfig(game_config_field.large_super_all)
    large_super_all = json.decode(large_super_all:getFormatBuffer()) or {}

    self.large_super_all = {}
    for k,v in pairs(large_super_all) do
        if v.version == self.m_tGameData.version then
            local itemCfgTable = util.table_copy(v)
            itemCfgTable.id = k
            if v.percent == -1 then
                self.rewardCfg = itemCfgTable
            else
                table.insert(self.large_super_all,itemCfgTable)
            end
        end
    end
    table.sort(
        self.large_super_all,
        function(data1, data2)
            return data1.percent < data2.percent
        end
    )
    cclog2(self.large_super_all, "dsgestewy=====")
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
                        -- game_scene:enterGameUi("game_main_scene",{gameData = gameData})
                    else
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("large_super_all_index"), http_request_method.GET, nil,"large_super_all_index",true,true)
              end,
              okBtnText = "Xác nhận",       --可缺省
              text = "Cấp VIP của bạn không đủ. Đạt đến VIP" .. needVip ..  "là có thể tham gia vào sự kiện này",      --可缺省
          }
          game_util:openAlertView(t_params);
    else
        cclog("vip等级达到了要求~")
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_lsxx.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_lsxx