---  组队boss捐献
local game_team_boss_donate = {
    m_root_layer = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_tGameData = nil,
  
    m_rank_data = nil,
    points_label = nil,
    points_rank_label = nil,
    left_dimond_label = nil,
    m_editBox1 = nil,
};
--[[--
    销毁ui
]]
function game_team_boss_donate.destroy(self)
    -- body
    cclog("----------------- game_team_boss_donate destroy-----------------"); 
    self.m_root_layer = nil;
    self.m_popUi = nil;
    self.m_close_btn = nil;
    self.m_tGameData = nil;
  
    self.m_rank_data = nil;
    self.points_label = nil;
    self.points_rank_label = nil;
    self.left_dimond_label = nil;
    self.m_editBox1 = nil;
end
--[[--
    返回
]]
function game_team_boss_donate.back(self,backType)
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = function (  )
                self:destroy();
            end});
end
--[[--
    读取ccbi创建ui
]]
function game_team_boss_donate.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 11 then--充值
            local function responseMethod(tag,gameData)
                --game_scene:addPop("ui_vip_show_pop");
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag == 12 then--查看详情
            game_scene:addPop("game_active_limit_detail_pop",{ enterType = "160"})
        elseif btnTag == 13 then--捐献
            cclog2(self.donateNum,"self.donateNum")
            local number = tonumber(self.donateNum)
            if number then
                local function responseMethod(tag,gameData)
                    game_util:addMoveTips({text = "Cống hiến thành công" .. number .. "Xu！"})--成功捐献
                    local data = gameData:getNodeWithKey("data");
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    self:refreshUi()
                    self.m_editBox1:setText("")
                    self.donateNum = 0--捐献完置0
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_donation"), http_request_method.GET, {num = self.donateNum},"team_boss_donation")
            else
                game_util:addMoveTips({text = "Xin nhập số！"})--请输入数字
            end
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_team_boss_donate.ccbi");

    self.rank_node = ccbNode:nodeForName("rank_node");
    self.points_label = ccbNode:labelTTFForName("points_label");
    self.points_rank_label = ccbNode:labelTTFForName("points_rank_label");
    self.left_dimond_label = ccbNode:labelTTFForName("left_dimond_label");
    self.count_down_node = ccbNode:nodeForName("count_down_node")
    local boxNode = ccbNode:nodeForName("m_editBox1");
    
    local function editBoxTextEventHandle1(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.donateNum = edit:getText();
        end
    end
    self.m_editBox1 = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle1,size = boxNode:getContentSize(),placeHolder=""});
    self.m_editBox1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    boxNode:addChild(self.m_editBox1);

    return ccbNode;
end

--[[--
    创建列表 积分排行榜
]]
function game_team_boss_donate.createTableView(self,viewSize)
    local rankTable = self.m_tGameData.rank_info
    local tabCount = game_util:getTableLen(rankTable)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tabCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
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

            local rankData = rankTable[tostring(index+1)]
            local name = rankData.name
            local score = rankData.score

            detail_label:setString(tostring(index+1) .. "." .. name )
            detail_label_score:setString(tostring(score))
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
--[[--
    刷新ui
]]
function game_team_boss_donate.refreshUi(self)
    self.rank_node:removeAllChildrenWithCleanup(true)
    local tempTableView = self:createTableView(self.rank_node:getContentSize())
    self.rank_node:addChild(tempTableView,10,10)

    self.points_label:setString(self.m_tGameData.score)
    self.points_rank_label:setString(self.m_tGameData.own_rank)
    local coin = game_data:getUserStatusDataByKey("coin") or 0;
    self.left_dimond_label:setString(coin)

    self.count_down_node:removeAllChildrenWithCleanup(true)
    local function timeEndFunc()
        game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = function (  )
                self:destroy();
            end});
        game_util:addMoveTips({text = "Cống hiến kết thúc, xin chờ tổ đội bắt đầu "})--捐献已结束，请等待组队开始
    end
    local countTime = self.m_tGameData.time_count_down or 0
    local countdownLabel = game_util:createCountdownLabel(countTime,timeEndFunc,8,1);
    self.count_down_node:addChild(countdownLabel,11)
end
--[[--
    初始化
]]
function game_team_boss_donate.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        local rank_result = data:getNodeWithKey("rank_result")
        self.m_tGameData = json.decode(rank_result:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_team_boss_donate.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_team_boss_donate;
