---  跨服擂台赛主页
local game_league_main = {
    m_screenShoot = nil,
    m_root_layer = nil,
    
    m_tGameData = nil,

    label_myrank = nil,
    league_type = nil,
    league_rank = nil,
    syn_node = nil,
    label_syn_times = nil,
    label_challenge_times = nil,
    challenge_node = nil,
    table_node = nil,
    countdown_node = nil,
};
--[[--
    销毁ui
]]
function game_league_main.destroy(self)
    cclog("----------------- game_league_main destroy-----------------"); 
    self.m_screenShoot = nil;
    self.m_root_layer = nil;
    
    self.m_tGameData = nil;
    self.label_myrank = nil;
    self.league_type = nil;
    self.league_rank = nil;
    self.syn_node = nil;
    self.label_syn_times = nil;
    self.label_challenge_times = nil;
    self.challenge_node = nil;
    self.table_node = nil;
    self.countdown_node = nil;
end
--[[--
    返回
]]
function game_league_main.back(self)
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_league_main.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- print("press button tag is ", btnTag)
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 101 then--排行榜
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_league_rank",{gameData = gameData,enterType = "game_league_main"})              
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_get_team_rank"), http_request_method.GET, {page = 1},"world_one_get_team_rank")
        elseif btnTag == 102 then--战报
            local function responseMethod(tag,gameData)
                local log_info = json.decode(gameData:getNodeWithKey("data"):getNodeWithKey("logs"):getFormatBuffer())
                game_scene:addPop("ui_batter_info_pop",{log_info = log_info,openType = "game_league_main"})                
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_battle_log"), http_request_method.GET, nil,"world_one_battle_log")
        elseif btnTag == 103 then--同步数据
            if self.m_tGameData.syn_time > 0 then
                local function responseMethod(tag,gameData)
                    game_util:addMoveTips({text = "Tăng tốc thành công!"}) --加速成功！
                    local data = gameData:getNodeWithKey("data");
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    game_util:closeAlertView();
                    self:refreshUi()
                end
                local canBuy,payValue = game_util:getCostCoinBuyTimes(35)
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_remove_syn_time"), http_request_method.GET, nil,"world_one_remove_syn_time")
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,       --可缺省
                    cancelBtnText = string_config.m_btn_cancel,
                    text = "Xác nhận dùng" .. payValue .. "Xu tăng tốc",      --可缺省 是否花费 钻石来加速？
                    onlyOneBtn = false,
                    touchPriority = GLOBAL_TOUCH_PRIORITY-20,
                }
                game_util:openAlertView(t_params);
            else
                local function responseMethod(tag,gameData)
                    game_util:addMoveTips({text = "Tư liệu đồng bộ thành công."}) --同步数据成功！
                    local data = gameData:getNodeWithKey("data");
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_syn_user_info"), http_request_method.GET, nil,"world_one_syn_user_info")
            end
        elseif btnTag == 104 then--换一批
            -- if self.m_tGameData.win_time > 0 then
            --     local function responseMethod(tag,gameData)
            --         game_util:addMoveTips({text = "刷新成功！"})
            --         local data = gameData:getNodeWithKey("data");
            --         self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            --         game_util:closeAlertView();
            --         self:refreshUi()
            --     end
            --     local canBuy,payValue = game_util:getCostCoinBuyTimes(36)
            --     local t_params = 
            --     {
            --         title = string_config.m_title_prompt,
            --         okBtnCallBack = function(target,event)
            --             network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_remove_win_time"), http_request_method.GET, nil,"world_one_remove_win_time")
            --         end,   --可缺省
            --         okBtnText = string_config.m_btn_sure,       --可缺省
            --         cancelBtnText = string_config.m_btn_cancel,
            --         text = "是否花费" .. payValue .. "钻石来减少等待时间",      --可缺省
            --         onlyOneBtn = false,
            --         touchPriority = GLOBAL_TOUCH_PRIORITY-20,
            --     }
            --     game_util:openAlertView(t_params);
            -- else
                local function responseMethod(tag,gameData)
                    game_util:addMoveTips({text = "Tạo mới thành công!"}) --刷新成功！
                    local data = gameData:getNodeWithKey("data");
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_refresh_player"), http_request_method.GET, nil,"world_one_refresh_player")
            -- end
        elseif btnTag == 3 then--兑换
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_league_shop",{gameData = gameData,enterType = "game_league_main"})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_exchange_index"), http_request_method.GET, nil,"world_one_exchange_index")
        elseif btnTag == 4 then--说明
            game_scene:addPop("game_active_limit_detail_pop",{ enterType = "151"})
        elseif btnTag == 500 then--购买次数
            local function responseMethod(tag,gameData)
                game_util:addMoveTips({text = "Mua thành công!"}) --购买成功！
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                game_util:closeAlertView();
                self:refreshUi()
            end
            local canBuy,payValue = game_util:getCostCoinBuyTimes(36,self.m_tGameData.buy_challenge_times)
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_buy_challenge_times"), http_request_method.GET, nil,"world_one_buy_challenge_times")
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = "Xác nhận dùng" .. payValue .. "Xu mua số lần khiêu chiến",      --可缺省 是否花费 钻石来购买挑战次数？
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-20,
            }
            game_util:openAlertView(t_params);
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_league_main.ccbi");

    self.label_myrank = ccbNode:labelTTFForName("label_myrank")
    self.league_type = ccbNode:labelTTFForName("league_type")
    self.league_rank = ccbNode:labelTTFForName("league_rank")
    self.syn_node = ccbNode:nodeForName("syn_node")
    self.label_syn_times = ccbNode:labelTTFForName("label_syn_times")
    self.label_challenge_times = ccbNode:labelTTFForName("label_challenge_times")
    self.challenge_node = ccbNode:nodeForName("challenge_node")
    self.table_node = ccbNode:nodeForName("table_node")
    self.countdown_node = ccbNode:nodeForName("countdown_node")

    return ccbNode;
end

--[[--
    刷新ui
]]
function game_league_main.refreshUi(self)
    --活动倒计时
    self.countdown_node:removeAllChildrenWithCleanup(true)
    local function timeOverCallFun()
        
    end
    local timeLabel = game_util:createCountdownLabel(self.m_tGameData.time_count_down,timeOverCallFun,12,3)
    timeLabel:setAnchorPoint(ccp(0.5,0.5))
    timeLabel:setColor(ccc3(190,253,60))
    timeLabel:setPosition(ccp(0,0))
    self.countdown_node:addChild(timeLabel)
    --次数
    local left_times = self.m_tGameData.max_syn_times - self.m_tGameData.syn_times
    self.label_syn_times:setString(left_times .. "/" .. self.m_tGameData.max_syn_times)

    local server_challenge_times = self.m_tGameData.challenge_times or 0
    local challenge_times = self.m_tGameData.max_win_times - server_challenge_times
    self.label_challenge_times:setString(challenge_times .. "/" .. self.m_tGameData.max_win_times)

    self.label_myrank:setString(self.m_tGameData.own_uid_rank)
    --联赛、场次
    local stage_name = {"Thanh Đồng","Bạch Ngân","Hoàng Kim"} --青铜 白银 黄金
    if self.m_tGameData.stage_id > 0 then
        self.league_type:setString(stage_name[self.m_tGameData.stage_id])
    else
        self.league_type:setString("Thanh Đồng") --青铜
    end
    self.league_rank:setString(self.m_tGameData.win_times)
    --同步倒计时
    self.syn_node:removeAllChildrenWithCleanup(true)
    if self.m_tGameData.syn_time > 0 then
        local function timeOverCallFun2()
            self.m_tGameData.syn_time = 0
            self.syn_node:removeAllChildrenWithCleanup(true)
        end
        local timeLabel2 = game_util:createCountdownLabel(self.m_tGameData.syn_time,timeOverCallFun2)
        timeLabel2:setAnchorPoint(ccp(0.5,0.5))
        timeLabel2:setColor(ccc3(190,253,60))
        timeLabel2:setPosition(ccp(0,0))
        self.syn_node:addChild(timeLabel2)
    end
    --刷新倒计时
    self.challenge_node:removeAllChildrenWithCleanup(true)
    -- if self.m_tGameData.win_time > 0 then
    --     local function timeOverCallFun3()
    --         self.m_tGameData.win_time = 0
    --         self.challenge_node:removeAllChildrenWithCleanup(true)
    --     end
    --     local timeLabel3 = game_util:createCountdownLabel(self.m_tGameData.win_time,timeOverCallFun3)
    --     timeLabel3:setAnchorPoint(ccp(0.5,0.5))
    --     timeLabel3:setColor(ccc3(190,253,60))
    --     timeLabel3:setPosition(ccp(0,0))
    --     self.challenge_node:addChild(timeLabel3)
    -- end
    --敌人table
    self.table_node:removeAllChildrenWithCleanup(true)
    self.tableView = self:createTableView(self.table_node:getContentSize())
    self.table_node:addChild(self.tableView,10,10);
end
--[[
    敌人列表
]]
function game_league_main.createTableView( self,viewSize )
    local showData = self.m_tGameData.enemy_info
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " .. btnTag)
        if btnTag < 100 then--战斗
            local itemData = showData[tostring(btnTag)]
            local enemy_id = itemData.uid
            local function responseMethod(tag,gameData)
                game_data:setBattleType("game_league_main");
                -- local data = gameData:getNodeWithKey("data")
                local stageTableData = {name = "Vòng đấu đỉnh cao",step = 1,totalStep = 1} --巅峰联赛
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData,stageTableData=stageTableData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_battle"), http_request_method.GET, {uid = enemy_id},"world_one_battle")
        else--查看
            local itemData = showData[tostring(btnTag - 100)]
            local enemy_id = itemData.uid
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_league_enemy_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_see_player_info"), http_request_method.GET, {uid = enemy_id},"world_one_see_player_info")
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 5; --列
    params.totalItem = game_util:getTableLen(showData)
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create()            
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_game_league_main_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            
            local title_back = ccbNode:spriteForName("title_back")
            local title_sprite = ccbNode:spriteForName("title_sprite")
            local icon_node = ccbNode:nodeForName("icon_node")
            local btn_challenge = ccbNode:controlButtonForName("btn_challenge")
            local name_label = ccbNode:labelTTFForName("name_label")
            local combat_label = ccbNode:labelTTFForName("combat_label")
            local rank_label = ccbNode:labelTTFForName("rank_label")
            local btn_look = ccbNode:controlButtonForName("btn_look")
            btn_look:setTag(index + 101)
            btn_look:setOpacity(0)
            btn_challenge:setTag(index + 1)

            local backSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_league_title_back_" .. self.m_tGameData.stage_id .. ".png")
            local titleSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_league_title_" .. self.m_tGameData.stage_id .. ".png")
            if backSpriteFrame then
                title_back:setDisplayFrame(backSpriteFrame)
            end
            if titleSpriteFrame then
                title_sprite:setDisplayFrame(titleSpriteFrame)
            end

            local itemData = showData[tostring(index + 1)]
            local user_combat = itemData.user_combat
            local user_name = itemData.user_name
            local rank = itemData.rank
            local user_role = itemData.user_role

            rank_label:setString(rank)
            name_label:setString(user_name)
            combat_label:setString(user_combat)
            icon_node:removeAllChildrenWithCleanup(true)
            local icon = game_util:createPlayerIconByRoleId(tostring(user_role));
            if icon then
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setScale(0.6)
                icon_node:addChild(icon);
            end
        end
        return cell
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
            
        end
    end
    local tempTable = TableViewHelper:createGallery3(params);
    return tempTable
end
--[[--
    初始化
]]
function game_league_main.init(self,t_params)
    t_params = t_params or {}
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
function game_league_main.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_league_main