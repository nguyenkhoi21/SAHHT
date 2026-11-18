--- 纷争峡谷

local game_godfield_fenzheng = {
    m_tGameData = nil,
    m_close_btn = nil,
    m_ccbNode = nil,
    m_battle_btn = nil,
    m_winTimes_lab = nil,
    m_score_label = nil,
    m_reward_list_node_1 = nil,
    m_reward_list_node_2 = nil,
    m_scroll_view_tips = nil,
    m_battle_btn_2 = nil,
    m_battle_btn_3 = nil,
    word_tips3 = nil,
    word_tips2 = nil,
    m_detail_open_flag = nil,
    status = nil,
    m_enemy_server_lab = nil,
    m_isenroll = nil,
    m_rank_btn = nil,
    m_buy_btn = nil,
};
--[[--
    销毁
]]
function game_godfield_fenzheng.destroy(self)
    -- body
    cclog("-----------------game_godfield_fenzheng destroy-----------------");
    self.m_tGameData = nil;
    self.m_close_btn = nil;
    self.m_ccbNode = nil;
    self.m_battle_btn = nil;
    self.m_winTimes_lab = nil;
    self.m_score_label = nil;
    self.m_reward_list_node_1 = nil;
    self.m_reward_list_node_2 = nil;
    self.m_scroll_view_tips = nil;
    self.m_battle_btn_2 = nil;
    self.m_battle_btn_3 = nil;
    self.word_tips3 = nil;
    self.word_tips2 = nil;
    self.m_detail_open_flag = nil;
    self.status = nil;
    self.m_enemy_server_lab = nil;
    self.m_isenroll = nil;
    self.m_rank_btn = nil;
    self.m_buy_btn = nil;
end
--[[--
    返回
]]
function game_godfield_fenzheng.back(self,type)
   game_scene:enterGameUi("game_godfield_mainBig");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_fenzheng.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 11 then
            -- game_scene:addPop("game_active_limit_detail_pop",{enterType = "145"})
            if self.m_detail_open_flag == true then
                self.m_detail_msg_bg:setPreferredSize(CCSizeMake(270,105))
                self.m_scroll_view_tips:setViewSize(CCSizeMake(230,70))
            else
                self.m_detail_msg_bg:setPreferredSize(CCSizeMake(270,250))
                self.m_scroll_view_tips:setViewSize(CCSizeMake(230,220))
            end
            self.m_detail_open_flag = not self.m_detail_open_flag;
            self:refreshActivityDetail();
        elseif btnTag == 12 then
            local function responseMethod( tag,gameData )
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self.status = self.m_tGameData.stage
                self.m_isenroll = self.m_tGameData.is_enroll
                if self.status == 1 then
                    local function responseMethod( tag,gameData )
                        local formation = self.m_tGameData.team_pk_formation
                        game_scene:addPop("game_godfield_fenzhengzhenxing_pop",{gameData = gameData,formation = formation,openType = "fenzheng_main"});
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_upload_god_formation"), http_request_method.GET, nil,"god_field_upload_god_formation")
                elseif self.status == 0 then
                        game_util:addMoveTips({text = "未开启"})
                elseif self.status == 2 then
                        game_scene:enterGameUi("game_goefield_teamBoss",{gameData = gameData})
                elseif self.m_isenroll == true then
                    cclog2(self.status,"self.status")
                   
                    if self.status == 3 then
                        game_util:addMoveTips({text = "分组中，请稍后"})
                    
                    elseif self.status == 4 then
                         game_scene:enterGameUi("game_godfield_newFenzheng",{gameData = gameData})
                    elseif self.status == 5 then
                        local is_win = self.m_tGameData.last_win
                        game_scene:addPop("game_team_pk_result_pop",{is_win = is_win})
                        -- game_util:addMoveTips({text = "看结果阶段"})
                    else
                        game_util:addMoveTips({text= "Bạn chưa đạt yêu cầu vào event kế"})
                    end
                else
                    game_util:addMoveTips({text= "您未获得进入下一步活动的资格"})
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
        elseif btnTag == 101 then
            game_scene:enterGameUi("game_fenzheng_rank",{gameData = self.m_tGameData.score_ranks,backtype = "fenzheng"})
        elseif btnTag == 102 then
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_team_pk_shop",{gameData = gameData,openType = "godfield_fenzheng"});
                self:destroy()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_exchange_index"), http_request_method.GET, nil,"team_pk_exchange_index")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_fenzhengxiagu.ccbi");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_battle_btn = ccbNode:controlButtonForName("m_battle_btn");
    self.m_battle_btn_2 = ccbNode:controlButtonForName("m_battle_btn_2");
    self.m_battle_btn_3 = ccbNode:controlButtonForName("m_battle_btn_3");
    self.m_scroll_view_tips = ccbNode:scrollViewForName("m_scroll_view_tips");
    self.m_winTimes_lab = ccbNode:labelTTFForName("m_winTimes_lab");
    self.m_score_label = ccbNode:labelTTFForName("m_score_label");
    self.m_reward_list_node_1 = ccbNode:nodeForName("m_reward_list_node_1");
    self.m_reward_list_node_2 = ccbNode:nodeForName("m_reward_list_node_2");
    self.word_tips3 = ccbNode:spriteForName("word_tips3")
    self.word_tips2 = ccbNode:spriteForName("word_tips2")
    self.m_scroll_view_tips:setTouchPriority(GLOBAL_TOUCH_PRIORITY + 1);
    self.m_detail_msg_bg = ccbNode:scale9SpriteForName("m_detail_msg_bg")
    self.m_enemy_server_lab = ccbNode:labelTTFForName("m_enemy_server_lab")
    self.m_rank_btn = ccbNode:controlButtonForName("m_rank_btn")
    self.m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
    local animName = "enter_anim"
    local function animCallFunc(animName)
        ccbNode:runAnimations(animName)
    end
    ccbNode:registerAnimFunc(animCallFunc);
    ccbNode:runAnimations(animName)

    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    创建列表
]]
function game_godfield_fenzheng.createRewardTableView(self,viewSize)
    -- local showData = {{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000}}
    local team_pk_rewardcfg = getConfig(game_config_field.server_pk_reward)

    team_pk_rewardcfg = json.decode(team_pk_rewardcfg:getNodeWithKey("1"):getNodeWithKey("reward_member"):getFormatBuffer())
    
    local showData = team_pk_rewardcfg or {}
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 3; --列
    params.totalItem = #showData
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    if #showData == 0 then--显示一个提示
        self.word_tips2:setVisible(true)
    else
        self.word_tips2:setVisible(false)
    end
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local icon,name,count = game_util:getRewardByItemTable(showData[index+1],false)
            if icon then
                icon:setScale(0.65);
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
                cell:addChild(icon)
            end
            if count then
                local tempLabel = game_util:createLabelBMFont({text = "×" .. count,color = ccc3(255,255,255),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.2))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(showData[index+1])
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    创建奖励列表
]]
function game_godfield_fenzheng.createRankRewardTableView(self,viewSize)
    local rewardCfg = getConfig(game_config_field.maze_top_reward)
    local myRank = self.m_tGameData.max_rank
    local showData = {}
    if myRank == 0 or myRank > 100 then
        self.word_tips3:setVisible(true)
    else
        self.word_tips3:setVisible(false)
        local itemCfg = rewardCfg:getNodeWithKey(tostring(myRank))
        showData = json.decode(itemCfg:getNodeWithKey("reward"):getFormatBuffer())
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 3; --列
    params.totalItem = #showData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    params.direction = kCCScrollViewDirectionHorizontal;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local icon,name,count = game_util:getRewardByItemTable(showData[index+1],false)
            if icon then
                icon:setScale(0.65);
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
                cell:addChild(icon)
            end
            if count then
                local tempLabel = game_util:createLabelBMFont({text = "×" .. count,color = ccc3(255,255,255),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.2))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(showData[index+1])
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function game_godfield_fenzheng.refreshActivityDetail(self)
    self.m_scroll_view_tips:getContainer():removeAllChildrenWithCleanup(true)
    local activeCfg = getConfig(game_config_field.notice_active)
    local itemCfg = activeCfg:getNodeWithKey( "172" )
    local contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or "Event hấp dẫn, tham gia sôi nổi！"
    local viewSize = self.m_scroll_view_tips:getViewSize();
    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(viewSize.width,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(121,236,236),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    self.m_scroll_view_tips:setContentSize(CCSizeMake(viewSize.width,tempSize.height))
    self.m_scroll_view_tips:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.m_scroll_view_tips:addChild(tempLabel)
end


--[[--
    刷新ui
]]
function game_godfield_fenzheng.refreshUi(self)
    self:refreshActivityDetail();
    self.m_reward_list_node_1:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createRewardTableView(self.m_reward_list_node_1:getContentSize());
    self.m_reward_list_node_1:addChild(tableViewTemp);
    -- self.m_reward_list_node_2:removeAllChildrenWithCleanup(true);
    -- local tableViewTemp = self:createRankRewardTableView(self.m_reward_list_node_2:getContentSize());
    -- self.m_reward_list_node_2:addChild(tableViewTemp)
    local win_times = self.m_tGameData.win_times or 0 
    self.m_winTimes_lab:setString(tostring(win_times) .. "Trận");
    local own_score = self.m_tGameData.own_score or 0
    self.m_score_label:setString(tostring(own_score));
    self.status = self.m_tGameData.stage or 0   --状态0. 没有开启过, 1开启过 
    local enemy_server = self.m_tGameData.enemy_server or ""
    self.m_enemy_server_lab:setString(enemy_server)
    self.m_isenroll = self.m_tGameData.is_enroll or false
end

--[[--
    初始化
]]
function game_godfield_fenzheng.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    -- cclog2(self.m_tGameData,"gameData ==== ")
    self.m_detail_open_flag = false;
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_fenzheng.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_godfield_fenzheng;