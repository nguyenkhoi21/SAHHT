
local game_godfield_battle_result = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_list_view_node = nil,
    m_callBackFunc = nil,
    showData = nil,
    m_sort = nil,
    m_screenShoot = nil,
    m_type = nil,
    pvp_reward = nil,
    nightmareReward = nil,
};
 
--[[--
    销毁
]]
function game_godfield_battle_result.destroy(self)
    -- body
    cclog("-----------------game_godfield_battle_result destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_list_view_node = nil;
    self.m_callBackFunc = nil;
    self.showData = nil;
    self.m_sort = nil;
    self.m_screenShoot = nil;
    self.m_type = nil;
    self.pvp_reward = nil;
    self.nightmareReward = nil;
end
--[[--
    返回
]]
function game_godfield_battle_result.back(self,type)
    
    --game_scene:removePopByName("game_godfield_battle_result");
    game_data:setGodfieldData("")
    if self.m_type == "calendar" then
        local function responseMethod( tag,gameData )
            if gameData ~= nil and tolua.type(gameData) == "util_json" then
                local data = gameData:getNodeWithKey("data");
                data = json.decode(data:getFormatBuffer()) or {};
                game_scene:enterGameUi("game_godfield_calendar_pop",{gameData = gameData});
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_see_final_log"), http_request_method.GET, params,"god_field_see_final_log")
    elseif self.m_type == "godtemple" then
        game_scene:enterGameUi("game_godtemple_main",{gameData = nil})
    elseif self.m_type == "game_godfield_pvp" or  self.m_type == "god_pvp" then
        local function responseMethod( tag,gameData )
                game_scene:enterGameUi("game_godfield_pvp",{gameData = gameData,pvp_reward = self.pvp_reward})
            end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_arena"), http_request_method.GET, {},"god_arena")
    elseif self.m_type == "game_godfield_arena_up" then
        local function responseMethod( tag,gameData )
                local function endCallFunc()
                local data = gameData:getNodeWithKey("data")
                local dataTable = json.decode(data:getFormatBuffer()) or {}
                    if dataTable.current_stage ~= 1 and dataTable.has_stage_up_reward == true then
                        game_scene:addPop("game_godfield_arena_success",{gameData = gameData});
                    end
                end
                game_scene:enterGameUi("game_godfield_pvp",{gameData = gameData},{endCallFunc = endCallFunc})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_arena"), http_request_method.GET, {},"god_arena")
    elseif self.m_type == "nightmare" then
        local function responseMethod( tag,gameData )
            game_scene:enterGameUi("game_nightmare_main",{gameData = gameData,reward = self.nightmareReward})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_fight_forever_index"), http_request_method.GET, nil,"new_fight_forever_index")   
    elseif self.m_type == "expedition" then
        local function responseMethod( tag,gameData )
            game_scene:enterGameUi("game_expedition_main",{gameData = gameData,reward = self.nightmareReward});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("nightmare_tower_index"), http_request_method.GET, nil,"nightmare_tower_index")   
    else
        local function responseMethod( tag,gameData )
            game_scene:enterGameUi("game_godfield_arean",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")
    end
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_battle_result.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    if self.m_type == "nightmare" or self.m_type == "expedition" then
        ccbNode:openCCBFile("ccb/ui_godfield_battle_result2.ccbi");
    else
        ccbNode:openCCBFile("ccb/ui_godfield_battle_result.ccbi");
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
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
    if self.m_screenShoot then
        local tempSize = self.m_root_layer:getContentSize();
        self.m_screenShoot:setPosition( tempSize.width*0.5, tempSize.height*0.5 );
        self.m_root_layer:addChild(self.m_screenShoot,-1);
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[
    信息
]]
function game_godfield_battle_result.createBattleResultTable(self,viewSize)
    local log_list = self.m_tGameData["log_dict"].log_list
    self.showData = {}
    for i=1,3 do--合并attlist  和  deflist
        local itemData = log_list[i]
        self.showData[tostring(i)] = itemData
    end

    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        local itemData = self.showData[tostring(btnTag+1)]
        local function responseMethod(tag,gameData)
            if self.m_type == "calendar" then 
                game_data:setBattleType("godfield_calendar");
            elseif self.m_type == "godtemple" then
                game_data:setBattleType("godtemple");
            elseif self.m_type == "game_godfield_pvp" or self.m_type == "god_pvp" then
                game_data:setBattleType("game_godfield_pvp");
            elseif self.m_type == "game_godfield_arena_up" then
                game_data:setBattleType("game_godfield_arena_up");
            elseif self.m_type == "nightmare" then
                game_data:setBattleType("nightmare")
            elseif self.m_type == "expedition" then
                game_data:setBattleType("expedition")
            else
                game_data:setBattleType("godfield_my_replay");
            end
            game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
        end
        local params = {battle_log = itemData.battle_log} 
        if self.m_type == "nightmare" then
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_fight_forever_back_battle"), http_request_method.GET, params,"new_fight_forever_back_battle")
        elseif self.m_type == "expedition" then
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("nightmare_tower_fight_back_battle"), http_request_method.GET, params,"nightmare_tower_fight_back_battle")
        else
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_back_battle"), http_request_method.GET, params,"god_field_back_battle")
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1
    params.totalItem = game_util:getTableLen(self.showData);
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.itemActionFlag = true;
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_godfield_battle_result_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_look_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
        end
        if cell then

            local itemData = self.showData[tostring(index+1)]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_look_btn = ccbNode:controlButtonForName("m_look_btn")
            m_look_btn:setTag(index)
            m_look_btn:setVisible(true)
            if self.m_type == "nightmare" or self.m_type == "expedition" then
                game_util:setCCControlButtonBackground(m_look_btn,"godfield_huifang2.png")
                m_look_btn:setPreferredSize(CCSizeMake(59,30))
            end
            local m_name_label_1 = ccbNode:labelTTFForName("m_name_label_1")
            local m_name_label_2 = ccbNode:labelTTFForName("m_name_label_2")
            local m_reslut_sprite_1 = ccbNode:spriteForName("m_reslut_sprite_1")
            local m_reslut_sprite_2 = ccbNode:spriteForName("m_reslut_sprite_2")
            local m_icon_sprite_1 = ccbNode:spriteForName("m_icon_sprite_1")
            local m_icon_sprite_2 = ccbNode:spriteForName("m_icon_sprite_2")
            m_name_label_1:setString(tostring(itemData.attacker))
            m_name_label_2:setString(tostring(itemData.defender))
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
function game_godfield_battle_result.refreshUi(self)
    self.m_list_view_node:removeAllChildrenWithCleanup(true)
    local tempTable = self:createBattleResultTable(self.m_list_view_node:getContentSize())
    self.m_list_view_node:addChild(tempTable,10)

    local m_result_sprite = self.m_ccbNode:spriteForName("title_sprite")
    local is_win = self.m_tGameData["log_dict"].final_win or 0
    local tempSpriteFrame = nil;
    if is_win == 1 then
        tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("godfield_shengli.png")
    else
        tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("godfield_shibai.png")
    end
    if tempSpriteFrame then
        self.title_sprite:setDisplayFrame(tempSpriteFrame)
    end
end
--[[--
    初始化
]]
function game_godfield_battle_result.init(self,t_params)
    t_params = t_params or {};
    self.m_screenShoot = t_params.screenShoot
    self.m_type = t_params.mType
    self.pvp_reward = t_params.pvp_reward;
    self.nightmareReward = t_params.nightmareReward
    -- cclog2(t_params,"nightmareReward === ")
    local my_flag = t_params.flag or nil;
    if my_flag == "game_godfield_pvp" or my_flag == "game_godfield_arena_up" then
        self.m_type = my_flag
    end
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    elseif tolua.type(t_params.gameData) == "table" then
        self.m_tGameData = t_params.gameData
    else
        self.m_tGameData = {}
    end
    self.m_callBackFunc = t_params.callBackFunc
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_battle_result.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    return rootScene;
end

return game_godfield_battle_result;