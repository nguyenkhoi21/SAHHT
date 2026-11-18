--- boss战斗结算
local game_team_boss_battle_result = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_list_view_node = nil,
    m_reward_node = nil,
    m_callBackFunc = nil,
    m_tips_label = nil,
};

--[[--
    销毁
]]
function game_team_boss_battle_result.destroy(self)
    -- body
    cclog("-----------------game_team_boss_battle_result destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_list_view_node = nil;
    self.m_reward_node = nil;
    self.m_callBackFunc = nil;
    self.m_tips_label = nil;
end
--[[--
    返回
]]
function game_team_boss_battle_result.back(self,type)
    if self.m_callBackFunc then
        self.m_callBackFunc();
    end
    -- game_scene:removePopByName("game_team_boss_battle_result");
    local function responseMethod(tag,gameData)
        if gameData then
            local data = gameData:getNodeWithKey("data")
            local rank_result = data:getNodeWithKey("rank_result")
            local team_boss_all_team = data:getNodeWithKey("team_boss_all_team")
            local team_boss_sec_battle = data:getNodeWithKey("team_boss_sec_battle")
            local team_boss_thd_battle = data:getNodeWithKey("team_boss_thd_battle")
            if rank_result then--进入捐献界面
                game_scene:enterGameUi("game_team_boss_donate",{gameData = gameData})   
            elseif team_boss_all_team then--进入创建队伍界面
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
                    -- game_scene:enterGameUi("game_team_boss_info",{teamInfo = teamInfo,openType = 1})
                    self.teamInfoData = teamInfo
                    self:refreshUi()
                end
            elseif team_boss_sec_battle then
                game_scene:enterGameUi("game_team_boss_fight",{gameData = gameData,stage = 2})
            elseif team_boss_thd_battle then
                game_scene:enterGameUi("game_team_boss_fight",{gameData = gameData,stage = 3})
            else        
                game_scene:enterGameUi("game_main_scene",{gameData = nil,  openPop = nil});
                local msg = data:getNodeWithKey("msg")
                msg = msg and msg:toStr() or "Thời gian tấn công đã hết, xin đợi trận sau hoặc phát thưởng"
                self:destroy();
                game_util:addMoveTips({text = msg})
            end
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_index"), http_request_method.GET, nil,"team_boss_index",true,true)
end
--[[--
    读取ccbi创建ui
]]
function game_team_boss_battle_result.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_team_boss_battle_result.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    -- local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_list_view_node = ccbNode:nodeForName("m_list_view_node")
    

    self.title_sprite = ccbNode:spriteForName("title_sprite")
    -- m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            local realPos1 = self.m_list_view_node:getParent():convertToNodeSpace(ccp(x,y));
            if not (self.m_list_view_node:boundingBox():containsPoint(realPos1)) then
                self:back();
            end
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[
    信息
]]
function game_team_boss_battle_result.createBattleResultTable(self,viewSize)

    --奇葩结构
    local defend_list = self.m_tGameData.defend_list--防守胜利的列表
    local attack_list = self.m_tGameData.attack_list--攻击胜利的列表
    
    local showData = {}
    for i=3,5 do--合并attlist  和  deflist
        if attack_list[tostring(i)] then
            local itemData = attack_list[tostring(i)]
            itemData.is_win = 1
            showData[tostring(i-2)] = itemData
        end

        if defend_list[tostring(i)] then
            local itemData = defend_list[tostring(i)]
            itemData.is_win = 0
            showData[tostring(i-2)] = itemData
        end
    end
    --最终表  showData[1,1,1]  1表示胜利，0表示失败
    cclog2(showData,"showData")

    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        local itemData = showData[btnTag+1]
        local function responseMethod(tag,gameData)
            game_data:setBattleType("escort_battle_replay");
            game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
        end
        local params = {battle_log = itemData.battle_log}
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_battle_replay"), http_request_method.GET, params,"escort_battle_replay")
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1
    params.totalItem = game_util:getTableLen(showData);
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.itemActionFlag = true;
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_team_boss_battle_result_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_look_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
        end
        if cell then
            local itemData = showData[tostring(index+1)]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_look_btn = ccbNode:controlButtonForName("m_look_btn")
            m_look_btn:setTag(index)
            m_look_btn:setVisible(false)
            local m_name_label_1 = ccbNode:labelTTFForName("m_name_label_1")
            local m_name_label_2 = ccbNode:labelTTFForName("m_name_label_2")
            local m_reslut_sprite_1 = ccbNode:spriteForName("m_reslut_sprite_1")
            local m_reslut_sprite_2 = ccbNode:spriteForName("m_reslut_sprite_2")
            local m_icon_sprite_1 = ccbNode:spriteForName("m_icon_sprite_1")
            local m_icon_sprite_2 = ccbNode:spriteForName("m_icon_sprite_2")
            m_name_label_1:setString(tostring(itemData.attacker_name))
            m_name_label_2:setString(tostring(itemData.defender_name))
            local tempSize = m_icon_sprite_1:getContentSize();
            local tempIcon = game_util:createPlayerIconByRoleId(itemData.attacker_role)
            if tempIcon then
                tempIcon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5))
                m_icon_sprite_1:addChild(tempIcon)
            end
            local tempIcon = game_util:createPlayerIconByRoleId(itemData.defender_role)
            if tempIcon then
                tempIcon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5))
                m_icon_sprite_2:addChild(tempIcon)
            end
            local is_win = itemData.is_win or 0
            local tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_sheng.png")
            local tempSpriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_bai.png")
            if is_win == 1 then
                if tempSpriteFrame1 then
                    m_reslut_sprite_1:setDisplayFrame(tempSpriteFrame1)
                end
                if tempSpriteFrame2 then
                    m_reslut_sprite_2:setDisplayFrame(tempSpriteFrame2)
                end
            else
                if tempSpriteFrame1 then
                    m_reslut_sprite_1:setDisplayFrame(tempSpriteFrame2)
                end
                if tempSpriteFrame2 then
                    m_reslut_sprite_2:setDisplayFrame(tempSpriteFrame1)
                end
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
--[[--
    刷新ui
]]
function game_team_boss_battle_result.refreshUi(self)
    self.m_list_view_node:removeAllChildrenWithCleanup(true)
    local tempTable = self:createBattleResultTable(self.m_list_view_node:getContentSize())
    self.m_list_view_node:addChild(tempTable,10)

    local m_result_sprite = self.m_ccbNode:spriteForName("title_sprite")
    local is_win = self.m_tGameData.is_win or 0
    local tempSpriteFrame = nil;
    if is_win == 1 then
        tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("huilang_win.png")
    else
        tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("huilang_lose.png")
    end
    if tempSpriteFrame then
        self.title_sprite:setDisplayFrame(tempSpriteFrame)
    end
end
--[[--
    初始化
]]
function game_team_boss_battle_result.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {}
    end
    self.m_callBackFunc = t_params.callBackFunc
end

--[[--
    创建ui入口并初始化数据
]]
function game_team_boss_battle_result.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_team_boss_battle_result;