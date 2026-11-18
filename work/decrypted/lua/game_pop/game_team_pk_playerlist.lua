--- 组队PK人员列表

local game_team_pk_playerlist = {
    m_popUi = nil,
    m_root_layer = nil,
    game_data = nil,
    tableViewTemp = nil,

    user_post = nil,
    players = nil,
    player_uid = nil,
    battle_member = nil,
    m_listNode = nil,
    count_down_node = nil,
};

--[[--
    销毁
]]
function game_team_pk_playerlist.destroy(self)
    -- body
    cclog("-----------------game_team_pk_playerlist destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.game_data = nil;
    self.tableViewTemp = nil;

    self.user_post = nil;
    self.players = nil;
    self.player_uid = nil;
    self.battle_member = nil;
    self.m_listNode = nil;
    self.count_down_node = nil;
end
--[[--
    返回
]]
function game_team_pk_playerlist.back(self,type)
    if(self.user_post == "owner" or self.user_post == "vp")then
        local uids = ""
        for i=1,#self.battle_member do
            uids = uids .. self.battle_member[i]
            if i < #self.battle_member then
                uids = uids .. "_"
            end
        end
        local function responseMethod(tag,gameData)
            -- game_util:addMoveTips({text = ""})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_battle_member"), http_request_method.GET, {uids = uids},"team_pk_battle_member")
    end
    game_scene:removePopByName("game_team_pk_playerlist");
end
--[[--
    读取ccbi创建ui
]]
function game_team_pk_playerlist.createUi(self)
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
    ccbNode:openCCBFile("ccb/ui_guild_pk_playerlist.ccbi");
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
    self.count_down_node = ccbNode:nodeForName("count_down_node")

    return ccbNode;
end

--[[--
    刷新ui
]]
function game_team_pk_playerlist.refreshUi(self)
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

    --加一个倒计时，到时间自动跳转
    self.count_down_node:removeAllChildrenWithCleanup(true)
    local function timeEndFunc()
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local stage = data:getNodeWithKey("stage"):toInt()
            if stage == 1 then--准备阶段
                self.game_data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                self:refreshUi()
                -- game_scene:addPop("game_team_pk_playerlist",{gameData = gameData,user_post = self.user_post,players = self.players,player_uid = self.player_uid})
            elseif stage == 2 then--分组时间
                game_scene:removePopByName("game_team_pk_playerlist");
                game_util:addMoveTips({text = "Đang chia nhóm"});
            elseif stage == 3 then--手动选择路线时间
                game_scene:enterGameUi("game_team_pk_map_prepare",{gameData = gameData});
            elseif stage == 4 then--自动战斗时间
                game_scene:enterGameUi("game_team_pk_map",{gameData = gameData});
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
    end
    local countTime = self.game_data.time_count_down + 2
    local countdownLabel = game_util:createCountdownLabel(countTime,timeEndFunc);
    self.count_down_node:addChild(countdownLabel)
end

function game_team_pk_playerlist:createTableView( viewSize )
    self.last_select = nil;
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
    local function onCellClick( target,event )
        local tagNode = tolua.cast(target, "CCControlButton");
        local btnTag =  tagNode:getTag();
        cclog("btnTag == " .. btnTag)
        local index = btnTag - 100
        local itemData = self.players[tostring(self.player_uid[index])]
        if(self.user_post == "owner" or self.user_post == "vp")then
            local flag,k = game_util:idInTableById(itemData.uid,self.battle_member)
            if flag and k ~= nil then--删除它
                if #self.battle_member <= 1 then
                    game_util:addMoveTips({text = "Ít nhất phải có 1 hero trong đội!"})
                else
                    table.remove(self.battle_member,k);
                end
            else--选择它
                if #self.battle_member > 9 then
                    game_util:addMoveTips({text = "Max 10 người "})
                else
                    table.insert(self.battle_member,itemData.uid)
                end
            end
        end
        self:refreshUi()
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 5; -- 行
    params.column = 1; -- 列
    params.totalItem = game_util:getTableLen(self.players)
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
            ccbNode:openCCBFile("ccb/ui_guild_pk_playerlist_item.ccbi");
            ccbNode:controlButtonForName("select_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-14)
            cell:addChild(ccbNode,10,10);
        end
        
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_pPkPost = ccbNode:labelTTFForName("m_pPkPost")
            local m_pName = ccbNode:labelTTFForName("m_pName")
            local m_pScore = ccbNode:labelTTFForName("m_pScore")
            local m_pType = ccbNode:labelTTFForName("m_pType")
            local m_pLv = ccbNode:labelTTFForName("m_pLv")
            local m_pTitle = ccbNode:labelTTFForName("m_pTitle")
            local m_pPower = ccbNode:labelTTFForName("m_pPower")
            local select_btn = ccbNode:controlButtonForName("select_btn")
            local select_sprite = ccbNode:spriteForName("select_sprite")

            --data
            local itemData = self.players[tostring(self.player_uid[index + 1])]

            m_pPkPost:setString(itemData.arena_rank)
            m_pName:setString(itemData.name)
            m_pLv:setString(itemData.level)

            local tempTitle = "";
            if(itemData.title == "owner")then
                tempTitle = "Đội trưởng";
                m_pTitle:setColor(ccc3(255,255,7))
            elseif(itemData.title == "vp")then
                tempTitle = "Đội phó";
                m_pTitle:setColor(ccc3(232,86,7))
            else
                tempTitle = "Thành viên";
                m_pTitle:setColor(ccc3(5,142,60))
            end
            m_pTitle:setString(tostring(tempTitle));

            m_pScore:setString(itemData.dedication)
            m_pPower:setString(itemData.combat)
            -- 在线状态 1 在线 0 不在线 －1离线20天以上
            local tempType = "";
            if(itemData.online == 1)then
                tempType = "Online";
                m_pType:setColor(ccc3(165,255,6))
            elseif(itemData.online == 0)then
                tempType = "Offline";
                m_pType:setColor(ccc3(187,178,175))
            elseif(itemData.online == -1)then
                tempType = "Offline gần 20 ngày";
                m_pType:setColor(ccc3(187,178,175))
            end
            m_pType:setString(tempType);

            select_btn:setTag(101 + index)

            local sprite_select = ccbNode:spriteForName("sprite_select")
            sprite_select:setVisible(false)

            --显示选人
            local battle_member = self.battle_member
            local uid = itemData.uid
            if game_util:idInTableById(uid,battle_member) then
                select_sprite:setVisible(true)
            else
                select_sprite:setVisible(false)
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
function game_team_pk_playerlist.init(self,t_params)
    t_params = t_params or {};
    self.battle_member = {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.game_data = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
        -- cclog("self.game_data = " .. json.encode(self.game_data))
        self.battle_member = util.table_copy(self.game_data.own_team.battle_member)
    end
    self.user_post = t_params.user_post
    self.players = t_params.players
    self.player_uid = t_params.player_uid
    -- cclog("self.user_post = " .. self.user_post)
end

--[[--
    创建ui入口并初始化数据
]]
function game_team_pk_playerlist.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_team_pk_playerlist;