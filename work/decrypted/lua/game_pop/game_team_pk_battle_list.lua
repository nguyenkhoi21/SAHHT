--- 组队PK  战斗人员列表

local game_team_pk_battle_list = {
    m_popUi = nil,
    m_root_layer = nil,
    game_data = nil,
    user_post = nil,
    tableViewTemp = nil,

    m_listNode = nil,
    battle_member = nil,
    game_data = nil,
    players = nil,
    player_uid = nil,
    last_select = nil,
    m_stage = nil,
};

--[[--
    销毁
]]
function game_team_pk_battle_list.destroy(self)
    -- body
    cclog("-----------------game_team_pk_battle_list destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.game_data = nil;
    self.user_post = nil;
    self.tableViewTemp = nil;

    self.m_listNode = nil;
    self.battle_member = nil;
    self.game_data = nil;
    self.players = nil;
    self.player_uid = nil;
    self.last_select = nil;
    self.m_stage = nil;
end
--[[--
    返回
]]
function game_team_pk_battle_list.back(self,type)
    -- game_scene:removePopByName("game_team_pk_battle_list");
    -- self:destroy()
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        local stage = data:getNodeWithKey("stage"):toInt()
        if stage == 1 then--准备阶段
            
        elseif stage == 3 then--分组时间
            game_util:addMoveTips({text = "Đang chia nhóm"});
        elseif stage == 4 then--手动选择路线时间
            game_scene:enterGameUi("game_team_pk_map_prepare",{gameData = gameData});
        elseif stage == 5 then--自动战斗时间
            game_scene:enterGameUi("game_team_pk_map",{gameData = gameData});
        else
            game_scene:removePopByName("game_team_pk_battle_list");
            self:destroy()
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
end
--[[--
    读取ccbi创建ui
]]
function game_team_pk_battle_list.createUi(self)
    local ccbNode = luaCCBNode:create();

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_pk_battle_list.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    local function onTouch( eventType,x,y )
        if(eventType == "began")then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-12,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_listNode = ccbNode:nodeForName("m_listNode")
    local back_btn = ccbNode:controlButtonForName("back_btn")
    back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-13)

    return ccbNode;
end

--[[--
    刷新ui
]]
function game_team_pk_battle_list.refreshUi(self)
    local pX,pY;
    if self.tableViewTemp then
        pX,pY = self.tableViewTemp:getContainer():getPosition();
    end
    self.tableViewTemp = nil

    self.m_listNode:removeAllChildrenWithCleanup(true);
    self.tableViewTemp = self:createTableView(self.m_listNode:getContentSize());
    self.m_listNode:addChild(self.tableViewTemp,10,10)

    if pX and pY then
        self.tableViewTemp:setContentOffset(ccp(pX,pY), false);
    end
end

function game_team_pk_battle_list:createTableView( viewSize )
    self.last_select = nil;
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");

    local showData = self.game_data.own_team.battle_member
    local function onCellClick( target,event )
        local tagNode = tolua.cast(target, "CCControlButton");
        local btnTag =  tagNode:getTag();
        cclog("btnTag == " .. btnTag)
        local index = btnTag - 100
        local playerId = showData[index]
        local pX,pY = tagNode:getPosition();
        local tempPos = tagNode:getParent():convertToWorldSpace(ccp(pX,pY))
        local tempSize = tagNode:getContentSize()
        local function callBack(gameData)
            if gameData then
                self.game_data = gameData
                self:refreshUi()
            end
        end
        game_scene:addPop("game_team_pk_select_pop",{pos = tempPos,size = tempSize,playerId = playerId,callBack = callBack})
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 5; -- 行
    params.column = 1; -- 列
    params.totalItem = #showData
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-13;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellClick",onCellClick);
            ccbNode:openCCBFile("ccb/ui_guild_pk_battle_list_item.ccbi");
            ccbNode:controlButtonForName("btn_change"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-14)
            cell:addChild(ccbNode,10,10);
        end
        
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local arena_rank = ccbNode:labelTTFForName("arena_rank")
            local name_label = ccbNode:labelTTFForName("name_label")
            local state_label = ccbNode:labelTTFForName("state_label")
            local combat_label = ccbNode:labelTTFForName("combat_label")
            local route_label = ccbNode:labelTTFForName("route_label")

            local btn_change = ccbNode:controlButtonForName("btn_change")
            if self.m_stage == 5 then 
                btn_change:setVisible(false)
            else
                btn_change:setVisible(true)
            end
            local sprite_select = ccbNode:spriteForName("sprite_select")
            sprite_select:setVisible(false)
            
            btn_change:setTag(101 + index)

            local playerId = showData[index + 1]
            local itemData = self.game_data.own_team[tostring(playerId)]

            -- arena_rank:setString(itemData.arena_rank)
            name_label:setString(itemData.name)
            combat_label:setString(itemData.combat)
            -- 在线状态 1 在线 0 不在线 －1离线20天以上
            -- local tempType = "";
            -- if(itemData.online == 1)then
            --     tempType = "在线";
            --     state_label:setColor(ccc3(165,255,6))
            -- elseif(itemData.online == 0)then
            --     tempType = "离线";
            --     state_label:setColor(ccc3(187,178,175))
            -- elseif(itemData.online == -1)then
            --     tempType = "近20天未上线";
            --     state_label:setColor(ccc3(187,178,175))
            -- end
            -- state_label:setString(tempType);
            route_label:setString("Chưa")

            local up_road = self.game_data.own_team["1"]
            local middle_road = self.game_data.own_team["2"]
            local down_road = self.game_data.own_team["3"]
            if game_util:idInTableById(playerId,up_road) then
                route_label:setString("Trên")
            elseif game_util:idInTableById(playerId,middle_road) then
                route_label:setString("Giữa")
            elseif game_util:idInTableById(playerId,down_road) then
                route_label:setString("Dưới")
            else
                route_label:setString("Chưa")
            end
        end
        cell:setTag(index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local sprite_select = ccbNode:spriteForName("sprite_select");
            if self.last_select ~= sprite_select then
                if self.last_select then
                    self.last_select:setVisible(false)
                end
                sprite_select:setVisible(true)
                self.last_select = sprite_select
            end

        end
    end
    return TableViewHelper:create(params);
end

--[[--
    初始化
]]
function game_team_pk_battle_list.init(self,t_params)
    t_params = t_params or {};
    self.battle_member = {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.game_data = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
        -- cclog("self.game_data = " .. json.encode(self.game_data))
        self.battle_member = util.table_copy(self.game_data.own_team.battle_member)
    end
    self.m_stage = self.game_data.stage or 5
    -- local allData = game_data:getGuildData()
    -- local players = allData.player
    -- local player_uid = allData.guild.player
    -- local myUid = game_data:getUserStatusDataByKey("uid");
    -- local user_post = players[tostring(myUid)].title
    -- self.user_post = user_post
    -- self.players = players
    -- self.player_uid = player_uid
    -- cclog("self.user_post = " .. self.user_post)
end

--[[--
    创建ui入口并初始化数据
]]
function game_team_pk_battle_list.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_team_pk_battle_list;