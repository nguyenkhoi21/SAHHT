--- 组队boss创建队伍
local game_team_boss_create = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_tGameData = nil,
    
    team_node = nil,
};

--[[--
    销毁
]]
function game_team_boss_create.destroy(self)
    -- body
    cclog("-----------------game_team_boss_create destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_tGameData = nil;
    
    self.team_node = nil;
end
--[[--
    返回
]]
function game_team_boss_create.back(self,type)
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = function (  )
                self:destroy();
            end});
end
--[[--
    读取ccbi创建ui
]]
function game_team_boss_create.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 12 then--创建队伍
            local function responseMethod(tag,gameData)
                -- local data = gameData:getNodeWithKey("data");
                -- local team_boss_all_team = data:getNodeWithKey("team_boss_all_team")
                -- self.m_tGameData = json.decode(team_boss_all_team:getFormatBuffer()) or {};
                local data = gameData:getNodeWithKey("data")
                local team_boss_all_team = data:getNodeWithKey("team_boss_all_team")
                if team_boss_all_team then
                    --再分进入创建队伍，还是直接进入队伍信息
                    local team_id = data:getNodeWithKey("team_id")
                    team_id = (team_id and team_id:toStr()) or ""
                    --遍历是否有队伍
                    if team_id == "" then
                        game_scene:enterGameUi("game_team_boss_create",{gameData = gameData})
                    else
                        local team_boss_all_teamJson = json.decode(team_boss_all_team:getFormatBuffer()) or {};
                        --直接进入队伍
                        local teamInfo = team_boss_all_teamJson[team_id]
                        local time_count_down = data:getNodeWithKey("time_count_down")
                        if time_count_down then
                            time_count_down = time_count_down:toInt()
                        else
                            time_count_down = 0
                        end
                        game_scene:enterGameUi("game_team_boss_info",{teamInfo = teamInfo,openType = 1,time_count_down = time_count_down})
                    end
                end
                -- self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_create_team"), http_request_method.GET, nil,"team_boss_create_team")
        elseif btnTag == 13 then--刷新
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local rank_result = data:getNodeWithKey("rank_result")
                local team_boss_all_team = data:getNodeWithKey("team_boss_all_team")
                local team_boss_sec_battle = data:getNodeWithKey("team_boss_sec_battle")
                local team_boss_thd_battle = data:getNodeWithKey("team_boss_thd_battle")
                if rank_result then--进入捐献界面
                    game_scene:enterGameUi("game_team_boss_donate",{gameData = gameData})   
                elseif team_boss_all_team then--进入创建队伍界面
                    --再分进入创建队伍，还是直接进入队伍信息
                    local team_id = data:getNodeWithKey("team_id"):toStr()
                    --遍历是否有队伍
                    if team_id == "" or team_id == 0 then
                        game_scene:enterGameUi("game_team_boss_create",{gameData = gameData})
                    else
                        local team_boss_all_teamJson = json.decode(team_boss_all_team:getFormatBuffer()) or {};
                        --直接进入队伍
                        local teamInfo = team_boss_all_teamJson[team_id]
                        game_scene:enterGameUi("game_team_boss_info",{teamInfo = teamInfo,openType = 1})
                    end
                elseif team_boss_sec_battle then
                    game_scene:enterGameUi("game_team_boss_fight",{gameData = gameData,stage = 2})
                elseif team_boss_thd_battle then
                    game_scene:enterGameUi("game_team_boss_fight",{gameData = gameData,stage = 3})
                else        
                    game_scene:enterGameUi("game_main_scene",{gameData = nil,  openPop = nil});
                    self:destroy();
                    game_util:addMoveTips({text = "Đang chia nhóm, xin đợi!"})--正在分组，请稍后进入！
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_index"), http_request_method.GET, nil,"team_boss_index")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_team_boss_create.ccbi");

    self.team_node = ccbNode:nodeForName("team_node")

    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[
    tabel view
]]
function game_team_boss_create:createTabelView(viewSize)
    local tabCount = game_util:getTableLen(self.m_tGameData)

    local showData = {}
    for k,v in pairs(self.m_tGameData) do
        table.insert( showData, v )
    end
    local function onMainCellClick( target,event )
        -- local tagNode = tolua.cast(target,"CCNode");
        -- local btnTag = tagNode:getTag();
        -- cclog("btnTag == " .. btnTag)

        -- local index = btnTag - 100
        -- local function responseMethod(tag,gameData)

        -- end
        -- local itemData = showData[index]
        -- -- cclog2(itemData,"itemData")
        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_join_team"), http_request_method.GET, {team_id = itemData.team_id},"team_boss_join_team")
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 2; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tabCount;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainCellClick",onMainCellClick);
            ccbNode:openCCBFile("ccb/ui_team_boss_team_cell.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            -- ccbNode:controlButtonForName("m_btn_2"):setTouchPriority(GLOBAL_TOUCH_PRIORITY)
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            
            local itemData = showData[index + 1]
            local team_combat = itemData.team_combat
            local team_player = itemData.team_player
            local team_name = itemData.team_name
            local role = itemData.role

            local icon_node = ccbNode:nodeForName("icon_node")
            local name_label = ccbNode:labelTTFForName("name_label")
            local combat_label = ccbNode:labelTTFForName("combat_label")
            local team_label = ccbNode:labelTTFForName("team_label")
            local m_btn_2 = ccbNode:controlButtonForName("m_btn_2")

            icon_node:removeAllChildrenWithCleanup(true)
            local tempIcon = game_util:createPlayerIconByRoleId(role);
            if tempIcon then
                tempIcon:setScale(0.6);
                local tempSize = icon_node:getContentSize();
                tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
                icon_node:addChild(tempIcon)
            end
            name_label:setString(team_name)
            combat_label:setString(team_combat)
            team_label:setString(game_util:getTableLen(team_player) .. "/5")

            m_btn_2:setTag(101 + index)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemData = showData[index + 1]
            -- local team_id = itemData.team_id
            game_scene:enterGameUi("game_team_boss_info",{teamInfo = itemData,openType = 2})
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_team_boss_create.refreshUi(self)
    self.team_node:removeAllChildrenWithCleanup(true)
    local teamTable = self:createTabelView(self.team_node:getContentSize())
    self.team_node:addChild(teamTable)
end
--[[--
    初始化
]]
function game_team_boss_create.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        local team_boss_all_team = data:getNodeWithKey("team_boss_all_team")
        self.m_tGameData = json.decode(team_boss_all_team:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_team_boss_create.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_team_boss_create;