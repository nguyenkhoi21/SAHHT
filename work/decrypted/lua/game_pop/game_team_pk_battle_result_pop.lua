--- pk战斗结算
local game_team_pk_battle_result_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_list_view_node = nil,
    m_callBackFunc = nil,
    title_sprite = nil,
    table_tab_btn = nil,
    m_tGameData = nil,
    select_index = nil,
};

--[[--
    销毁
]]
function game_team_pk_battle_result_pop.destroy(self)
    -- body
    cclog("-----------------game_team_pk_battle_result_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_list_view_node = nil;
    self.m_callBackFunc = nil;

    self.title_sprite = nil;
    self.table_tab_btn = nil;
    self.m_tGameData = nil;
    self.select_index = nil;
end
--[[--
    返回
]]
function game_team_pk_battle_result_pop.back(self,type)
    -- game_scene:enterGameUi("game_main_scene",{});
    if self.m_callBackFunc then
        self.m_callBackFunc()
    end
    game_scene:removePopByName("game_team_pk_battle_result_pop");
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_team_pk_battle_result_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then
            self:back();
        elseif btnTag >= 201 and btnTag <= 203 then--分路线
            local index = btnTag - 200 
            if self.select_index ~= index then
                self.select_index = index
                for i=1,3 do
                    game_util:setCCControlButtonBackground(self.table_tab_btn[i],"card_table_select.png")
                end
                game_util:setCCControlButtonBackground(self.table_tab_btn[self.select_index],"card_table_selected.png")
                self:refreshUi()
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_pk_battle_result.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_list_view_node = ccbNode:nodeForName("m_list_view_node")
    

    self.title_sprite = ccbNode:spriteForName("title_sprite")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    self.table_tab_btn = {}
    for i=1,3 do
        self.table_tab_btn[i] = ccbNode:controlButtonForName("table_tab_btn_" .. i)
        self.table_tab_btn[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
        if i == 1 then
            game_util:setCCControlButtonBackground(self.table_tab_btn[i],"card_table_selected.png")
        else
            game_util:setCCControlButtonBackground(self.table_tab_btn[i],"card_table_select.png")
        end
    end
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
function game_team_pk_battle_result_pop.createBattleResultTable(self,viewSize)
    local showRoute = self.m_tGameData[tostring(self.select_index)]
    local log_list = showRoute.log_list
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        
        local index = btnTag - 100
        local itemData = log_list[index]
        local battle_log = itemData.battle_log

        local params = {}
        params.key = battle_log
        local function responseMethod(tag,gameData)
            game_data:setBattleType("team_pk_replay");
            game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_back_battle_pk_log"), http_request_method.GET, params,"team_pk_back_battle_pk_log")
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1
    params.totalItem = game_util:getTableLen(log_list)
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.itemActionFlag = true;
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_guild_pk_battle_result_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_look_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            
            local m_look_btn = ccbNode:controlButtonForName("m_look_btn")
            m_look_btn:setTag(101 + index)

            local m_name_label_1 = ccbNode:labelTTFForName("m_name_label_1")
            local m_name_label_2 = ccbNode:labelTTFForName("m_name_label_2")
            local m_reslut_sprite_1 = ccbNode:spriteForName("m_reslut_sprite_1")
            local m_reslut_sprite_2 = ccbNode:spriteForName("m_reslut_sprite_2")
            local m_icon_sprite_1 = ccbNode:spriteForName("m_icon_sprite_1")
            local m_icon_sprite_2 = ccbNode:spriteForName("m_icon_sprite_2")

            local itemData = log_list[index + 1]
            m_name_label_1:setString(tostring(itemData.attacker))
            m_name_label_2:setString(tostring(itemData.defender))

            m_icon_sprite_1:removeAllChildrenWithCleanup(true)
            m_icon_sprite_2:removeAllChildrenWithCleanup(true)
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
function game_team_pk_battle_result_pop.refreshUi(self)
    self.m_list_view_node:removeAllChildrenWithCleanup(true)
    local tempTable = self:createBattleResultTable(self.m_list_view_node:getContentSize())
    self.m_list_view_node:addChild(tempTable,10)

    local m_result_sprite = self.m_ccbNode:spriteForName("title_sprite")

    local showRoute = self.m_tGameData[tostring(self.select_index)]
    local win_team_id = showRoute.win_team_id or ""
    local tempSpriteFrame = nil;
    self.title_sprite:setVisible(true)
    if win_team_id == "" then--空
        self.title_sprite:setVisible(false)
    elseif win_team_id == self.m_tGameData.team_id then--胜利
        tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("huilang_win.png")
    else--失败
        tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("huilang_lose.png")
    end
    if tempSpriteFrame then
        self.title_sprite:setDisplayFrame(tempSpriteFrame)
    end
end
--[[--
    初始化
]]
function game_team_pk_battle_result_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {}
    end
    self.m_callBackFunc = t_params.callBackFunc
    self.select_index = 1
end

--[[--
    创建ui入口并初始化数据
]]
function game_team_pk_battle_result_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_team_pk_battle_result_pop;