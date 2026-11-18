--- 组队boss创建队伍
local game_team_boss_info = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_scrollview = nil,
    team_node = nil,
    m_formation_layer = nil,
    openType = nil,
    cellTable = nil,
    teamInfoData = nil,
    
    m_cityAutoRaidsScheduler = nil,
    m_auto_time = nil,
    netFlag = nil,
    moveFlag = nil,
    time_count_down = nil,
    m_daojishi_label = nil,
};

--[[--
    销毁
]]
function game_team_boss_info.destroy(self)
    -- body
    cclog("-----------------game_team_boss_info destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_scrollview = nil;
    self.team_node = nil;
    self.m_formation_layer = nil;
    self.openType = nil;
    self.cellTable = nil;
    self.teamInfoData = nil;
    self.m_daojishi_label = nil;
    
    if self.m_cityAutoRaidsScheduler then
        scheduler.unschedule(self.m_cityAutoRaidsScheduler)
        self.m_cityAutoRaidsScheduler = nil;
    end
    self.m_auto_time = nil;
    self.netFlag = nil;
    self.moveFlag = nil;
    self.time_count_down = nil;
end
--[[--
    返回
]]
function game_team_boss_info.back(self,type)
    if self.openType == 1 then
        game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = function (  )
                self:destroy();
            end});
    else
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
                        if data:getNodeWithKey("time_count_down") then
                            self.time_count_down = data:getNodeWithKey("time_count_down"):toInt()
                        end
                        self:refreshUi()
                    end
                elseif team_boss_sec_battle then
                    game_scene:enterGameUi("game_team_boss_fight",{gameData = gameData,stage = 2})
                elseif team_boss_thd_battle then
                    game_scene:enterGameUi("game_team_boss_fight",{gameData = gameData,stage = 3})
                else        
                    game_scene:enterGameUi("game_main_scene",{gameData = nil,  openPop = nil});
                    local msg = data:getNodeWithKey("msg")
                    msg = msg and msg:toStr() or "Đang chia nhóm, xin đợi!"--正在分组，请稍后再进入活动！
                    self:destroy();
                    game_util:addMoveTips({text = msg})
                end
            else
                self.m_auto_time = 5
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_index"), http_request_method.GET, nil,"team_boss_index",true,true)
    end
    -- cclog2(self.teamInfoData,"self.teamInfoData")
    -- cclog2(self.cellTable,"self.cellTable")
end
--[[--
    读取ccbi创建ui
]]
function game_team_boss_info.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local function responseMethod(tag,gameData)
            self.netFlag = false
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
                        if data:getNodeWithKey("time_count_down") then
                            self.time_count_down = data:getNodeWithKey("time_count_down"):toInt()
                        end
                        self:refreshUi()
                    end
                    if tag == "team_boss_destroy_team" then
                        game_util:addMoveTips({text = "Giải tán thành công "})--解散成功！
                    elseif tag == "team_boss_exit_team" then
                        game_util:addMoveTips({text = "Rời thành công"})--退出成功！
                    elseif tag == "team_boss_index" then
                        game_util:addMoveTips({text = "Tạo mới thành công"})--刷新成功
                    end
                elseif team_boss_sec_battle then
                    game_scene:enterGameUi("game_team_boss_fight",{gameData = gameData,stage = 2})
                elseif team_boss_thd_battle then
                    game_scene:enterGameUi("game_team_boss_fight",{gameData = gameData,stage = 3}) 
                else       
                    game_scene:enterGameUi("game_main_scene",{gameData = nil,  openPop = nil});
                    local msg = data:getNodeWithKey("msg")
                    msg = msg and msg:toStr() or "Đang chia nhóm, xin đợi "--正在分组，请稍后进入！
                    self:destroy();
                    game_util:addMoveTips({text = msg})
                end
            else
                self.m_auto_time = 5
            end
        end
        if btnTag == 1 then
            self:back();
        elseif btnTag == 12 then--解散或退队
            self.netFlag = true
            if game_data:getUserStatusDataByKey("uid") == self.teamInfoData.uid then--解散
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_destroy_team"), http_request_method.GET, nil,"team_boss_destroy_team",true,true)
            else--退队
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_exit_team"), http_request_method.GET, nil,"team_boss_exit_team",true,true)
            end
        elseif btnTag == 13 then--刷新
            self.netFlag = true
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_index"), http_request_method.GET, nil,"team_boss_index",true,true)
        elseif btnTag == 555 then--详情
            game_scene:addPop("game_active_limit_detail_pop",{ enterType = "160"})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_team_boss_teaminfo.ccbi");

    self.team_node = ccbNode:nodeForName("team_node")
    self.m_scrollview = ccbNode:scrollViewForName("m_scrollview")
    self.m_formation_layer = ccbNode:layerColorForName("m_formation_layer")

    self.m_btn_2 = ccbNode:controlButtonForName("m_btn_2")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")

    self.time_label = ccbNode:labelTTFForName("time_label")
    self.m_daojishi_label = ccbNode:labelTTFForName("m_daojishi_label")
    
    function tick( dt )
        if self.openType == 1 then
            --触摸时，不去倒计时
            if self.moveFlag == false then
                if self.m_auto_time > 0 then
                    self:setInfoLabel();
                    self.m_auto_time = self.m_auto_time - 1;
                else
                    if self.netFlag == false then--联网时，不去倒计时
                        self.netFlag = true;
                        local function responseMethod(tag,gameData)
                            self.netFlag = false;
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
                                        if data:getNodeWithKey("time_count_down") then
                                            self.time_count_down = data:getNodeWithKey("time_count_down"):toInt()
                                        end
                                        self:refreshUi()
                                    end
                                elseif team_boss_sec_battle then
                                    game_scene:enterGameUi("game_team_boss_fight",{gameData = gameData,stage = 2})
                                elseif team_boss_thd_battle then
                                    game_scene:enterGameUi("game_team_boss_fight",{gameData = gameData,stage = 3})
                                else        
                                    game_scene:enterGameUi("game_main_scene",{gameData = nil,  openPop = nil});
                                    local msg = data:getNodeWithKey("msg")
                                    msg = msg and msg:toStr() or "Đang chia nhóm, xin đợi "--正在分组，稍后进入！
                                    self:destroy();
                                    game_util:addMoveTips({text = msg})
                                end
                            else
                                self.m_auto_time = 5
                            end
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_index"), http_request_method.GET, nil,"team_boss_index",false,true)
                    end
                end
            end
        end
    end
    self.m_cityAutoRaidsScheduler = scheduler.schedule(tick, 1, false)
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[
    其他人加入队伍
]]
function game_team_boss_info.joinTeam(self,pos)
    local function responseMethod(tag,gameData)
        self.netFlag = false;
        if gameData then
            local data = gameData:getNodeWithKey("data")
            local rank_result = data:getNodeWithKey("rank_result")
            local team_boss_all_team = data:getNodeWithKey("team_boss_all_team")
            local team_boss_sec_battle = data:getNodeWithKey("team_boss_sec_battle")
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
                    self.openType = 1
                    if data:getNodeWithKey("time_count_down") then
                        self.time_count_down = data:getNodeWithKey("time_count_down"):toInt()
                    end
                    self:refreshUi()
                end
            elseif team_boss_sec_battle then
                game_scene:enterGameUi("game_team_boss_fight",{gameData = gameData,stage = 2})
            else        
                game_scene:enterGameUi("game_main_scene",{gameData = nil,  openPop = nil});
                local msg = data:getNodeWithKey("msg")
                msg = msg and msg:toStr() or "Đang chia nhóm, xin đợi"--正在分组，请稍后进入！
                self:destroy();
                game_util:addMoveTips({text = msg})
            end
            game_util:closeAlertView();
        else
            self.m_auto_time = 5
        end
    end
    local params = {}
    params.team_id = self.teamInfoData.team_id
    params.pos = pos
    self.netFlag = true;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_join_team"), http_request_method.GET, params,"team_boss_join_team",true,true)
end
function game_team_boss_info.setInfoLabel(self)
    cclog("00:0" .. self.m_auto_time)
end
--[[
    初始化队员信息
]]
function game_team_boss_info:initInfo(formation_layer)
    local pos = {
        ccp(23,151),ccp(23,85),ccp(233,151),ccp(233,85),ccp(233,19)
    }
    formation_layer:removeAllChildrenWithCleanup(true)
    self.cellTable = {}
    for i=1,5 do
        local itemCell,playerInfo = self:createInfoCell(i)
        self.cellTable[i] = {}
        if itemCell then
            itemCell:setAnchorPoint(ccp(0,0))
            itemCell:setPosition(pos[i])
            itemCell:setTag(i)
            formation_layer:addChild(itemCell)
            self.cellTable[i].cell = itemCell
            self.cellTable[i].playerInfo = playerInfo
        end
    end
end
--[[
    触摸换队员
]]
function game_team_boss_info.initAdjustmentFormationTouch(self,formation_layer)
    local selItem = nil;
    local beganItem = nil;
    local endItem = nil;
    local touchBeginPoint = nil;
    local touchMoveFlag = false;
    self.moveFlag = false;
    local realPos = nil;
    local tempPosIndex = nil;
    local beganTag = nil;
    local function onTouchBegan(x, y)
        if selItem then
            selItem:removeFromParentAndCleanup(true);
            selItem = nil;
        end
        touchMoveFlag = false;
        self.moveFlag = false;
        --cclog("onTouchBegan: %0.2f, %0.2f", x, y)
        touchBeginPoint = {x = x, y = y}
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        for tag = 1,5 do
            beganItem = self.cellTable[tag].cell
            if beganItem and beganItem:boundingBox():containsPoint(realPos) and self.cellTable[tag].playerInfo then--有数据才能动
                tempPosIndex = tag;
                selItem = self:createInfoCell(nil,self.cellTable[tag].playerInfo)
                beganTag = tag
                if selItem == nil then break end
                local pX,pY = beganItem:getPosition();
                selItem:setPosition(ccp(pX,pY));
                -- selItem:setColor(ccc3(128,128,128));
                formation_layer:addChild(selItem,11,11);
                selItem:setVisible(false);
                break;
            end
        end
        return true
    end
    
    local function onTouchMoved(x, y)
        -- cclog("onTouchMoved: %0.2f, %0.2f", x - touchBeginPoint.x, y - touchBeginPoint.y)
        if ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 or touchMoveFlag == true then
            if selItem then
                realPos = formation_layer:convertToNodeSpace(ccp(x,y));
                selItem:setPosition(realPos);
                selItem:setVisible(true);
            end
            touchMoveFlag = true;
            self.moveFlag = true;
        end
    end
    
    local function onTouchEnded(x, y)
        --cclog("onTouchEnded: %0.2f, %0.2f", x, y)
        self.moveFlag = false;
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        if selItem and touchMoveFlag then
            for endTag = 1,5 do
                endItem = self.cellTable[endTag].cell
                if endItem and endItem:boundingBox():containsPoint(realPos) then
                    if endTag ~= beganTag then
                        cclog("exchange ----------beganTag = " .. beganTag .. " ; endTag = " .. endTag);
                        --成功之后在调用
                        local function responseMethod(tag,gameData)
                            self.netFlag = false
                            if gameData then
                                game_util:addMoveTips({text = "Đổi thành công!"})--交换成功！
                                local bgSize = endItem:getContentSize();
                                beganItem:removeAllChildrenWithCleanup(true)
                                local beganCell = self:createInfoCell(nil,self.cellTable[endTag].playerInfo)
                                if beganCell then
                                    beganCell:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5));
                                    beganItem:addChild(beganCell,1,1)
                                end
                                endItem:removeAllChildrenWithCleanup(true)
                                local endCell = self:createInfoCell(nil,self.cellTable[beganTag].playerInfo)
                                if endCell then
                                    endCell:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5));
                                    endItem:addChild(endCell,1,1)
                                end
                                --交换cell位置
                                -- self.cellTable[beganTag],self.cellTable[endTag] = self.cellTable[endTag],self.cellTable[beganTag]
                                self.cellTable[beganTag].playerInfo,self.cellTable[endTag].playerInfo = self.cellTable[endTag].playerInfo,self.cellTable[beganTag].playerInfo
                                --再交换数据位置
                                -- self.teamInfoData.team_player[tostring(beganTag)],self.teamInfoData.team_player[tostring(endTag)] = self.teamInfoData.team_player[tostring(endTag)],self.teamInfoData.team_player[tostring(beganTag)]
                                -- cclog2(self.cellTable,"table")
                            end
                            beganItem = nil;
                            endItem = nil;
                        end
                        local params = {}
                        params.pos = beganTag
                        params.exchange_pos = endTag
                        self.netFlag = true
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_exchange_player"), http_request_method.GET, params,"team_boss_exchange_player",true,true)
                        break;
                    end
                end
            end
        end
        if selItem then
            selItem:removeFromParentAndCleanup(true);
            selItem = nil;
        end
        
        touchBeginPoint = nil;
        tempPosIndex = nil;
    end
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
            elseif eventType == "moved" then
            return onTouchMoved(x, y)
            else
            return onTouchEnded(x, y)
        end
    end
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+131)
    formation_layer:setTouchEnabled(true)
end
--[[
    创建cell  node
]]
function game_team_boss_info:createInfoCell(tempPosIndex,data)
    local function onCellBtnClick( target,event )
        local playerInfo = nil
        if tempPosIndex ~= nil then
            playerInfo = self.teamInfoData.team_player[tostring(tempPosIndex)]
        else
            playerInfo = data
        end
        local pos = 1
        -- cclog2(tempPosIndex,"tempPosIndex")
        --反向遍历出位置
        for i=1,5 do
            if self.cellTable[i].playerInfo and self.cellTable[i].playerInfo.play_uid == playerInfo.play_uid then
                pos = i
                break
            end
        end
        cclog2(pos,"pos")
        -- cclog2(playerInfo)
        local function responseMethod( tag,gameData )
            self.netFlag = false;
            game_util:closeAlertView()
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

                        if data:getNodeWithKey("time_count_down") then
                          
                            self.time_count_down = data:getNodeWithKey("time_count_down"):toInt()
                            local y = data:getNodeWithKey("time_count_down"):toInt()
                        end
                        self:refreshUi()
                        game_util:addMoveTips({text = "Đá thành công!"})--踢出成功！
                    end
                elseif team_boss_sec_battle then
                    game_scene:enterGameUi("game_team_boss_fight",{gameData = gameData,stage = 2})
                elseif team_boss_thd_battle then
                    game_scene:enterGameUi("game_team_boss_fight",{gameData = gameData,stage = 3})
                else        
                    game_scene:enterGameUi("game_main_scene",{gameData = nil,  openPop = nil});
                    local msg = data:getNodeWithKey("msg")
                    msg = msg and msg:toStr() or "Đang chia nhóm, xin đợi"--正在分组，请稍后进入！ 
                    self:destroy();
                    game_util:addMoveTips({text = msg})
                end
            else
                self.m_auto_time = 5
            end
        end
        local canBuy,payMoney = game_util:getCostCoinBuyTimes(32)
        local t_params = 
        {
            title = string_config.m_title_prompt,
            okBtnCallBack = function(target,event)
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_boss_remove_player"), http_request_method.GET, {pos = pos},"team_boss_remove_player",true,true)
                -- 
            end,   --可缺省
            okBtnText = string_config.m_btn_sure,       --可缺省
            cancelBtnText = string_config.m_btn_cancel,
            text = "Đá thành viên này ra chứ?",      --可缺省是否踢出该队员吗？
            onlyOneBtn = false,
            touchPriority = GLOBAL_TOUCH_PRIORITY-2,
        }
        self.netFlag = true
        game_util:openAlertView(t_params)
    end
    -- name_label:setString(tempPosIndex)
    local playerInfo = tempPosIndex == nil and data or self.teamInfoData.team_player[tostring(tempPosIndex)]
    local ccbNode = luaCCBNode:create();
    ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
    ccbNode:openCCBFile("ccb/ui_team_boss_infocell.ccbi");

    local name_label = ccbNode:labelTTFForName("name_label")
    local combat_label = ccbNode:labelTTFForName("combat_label")
    local m_kick_btn = ccbNode:controlButtonForName("m_kick_btn")
    m_kick_btn:setVisible(false)

    ccbNode:setAnchorPoint(ccp(0.5,0.5))
    if playerInfo then
        name_label:setString(playerInfo.player_name)
        combat_label:setString("Lực chiến:" .. playerInfo.player_combat)--战斗力：
        if game_data:getUserStatusDataByKey("uid") == self.teamInfoData.uid then--只有队长能看见
            if playerInfo.play_uid == self.teamInfoData.uid then--是队长，不显示
                m_kick_btn:setVisible(false)
            else
                m_kick_btn:setVisible(true)
            end
        end
    else
        name_label:setString("")
        combat_label:setString("")
    end
    return ccbNode,playerInfo
    -- return nil
end
--[[--
    刷新ui
]]
function game_team_boss_info.refreshUi(self)
    --team log
    local team_log = self.teamInfoData.team_log

    local viewSize = self.m_scrollview:getViewSize();
    local scrollMssage = ""
    for i=1,#team_log do
        scrollMssage = scrollMssage .. team_log[i] .. "\n"
    end
    local tempLabel = game_util:createRichLabelTTF({text = scrollMssage,dimensions = CCSizeMake(viewSize.width,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(255,255,255),fontSize = 10})
    local tempSize = tempLabel:getContentSize();
    self.m_scrollview:getContainer():removeAllChildrenWithCleanup(true)
    self.m_scrollview:setContentSize(CCSizeMake(viewSize.width,tempSize.height))
    self.m_scrollview:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.m_scrollview:setDirection(kCCScrollViewDirectionVertical)
    self.m_scrollview:addChild(tempLabel)


    self:initInfo(self.m_formation_layer)
    self.m_btn_2:setVisible(self.openType == 1 or false)
    self.m_ok_btn:setVisible(self.openType == 1 or false)
    --只有自己队伍且是队长，才能触摸
    if self.openType == 1 and game_data:getUserStatusDataByKey("uid") == self.teamInfoData.uid then
        self:initAdjustmentFormationTouch(self.m_formation_layer)
        game_util:setCCControlButtonTitle(self.m_btn_2,"Giải tán ")--解散
    elseif self.openType == 2 then
        self:initJoinTouch(self.m_formation_layer)
    elseif self.openType == 1 and game_data:getUserStatusDataByKey("uid") ~= self.teamInfoData.uid then
        game_util:setCCControlButtonTitle(self.m_btn_2,"Rời đội ")--退队
    end
    self.m_auto_time = 5

    if self.openType == 2 then
        self.time_label:setString("")
        self.m_daojishi_label:setVisible(false)
    else
        --倒计时回调函数
        local function timeEndFunc(label,type)
        end
        --取时间去倒计时   活动结束
        self.m_daojishi_label:setVisible(true)
        local expire = self.time_count_down or 0
        self.time_label:setString("")
        local countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8);
        countdownLabel:setPosition(ccp(countdownLabel:getContentSize().width*0.5,self.time_label:getContentSize().height*0.5))
        if self.time_label ~= nil then
            self.time_label:removeAllChildrenWithCleanup(true)
        end
        self.time_label:addChild(countdownLabel)
        countdownLabel:setTime(expire);
    end
end
--[[
    其他人加入队伍
]]
function game_team_boss_info.initJoinTouch( self,formation_layer )
    local selItem = nil;
    local beganItem = nil;
    local endItem = nil;
    local touchBeginPoint = nil;
    local touchMoveFlag = false;
    local realPos = nil;
    local tempPosIndex = nil;
    local beganTag = nil;
    local function onTouchBegan(x, y)
        --cclog("onTouchBegan: %0.2f, %0.2f", x, y)
        touchBeginPoint = {x = x, y = y}
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        -- CCTOUCHBEGAN event must return true
        for tag = 1,5 do
            beganItem = self.cellTable[tag].cell
            if beganItem and beganItem:boundingBox():containsPoint(realPos) and (not self.cellTable[tag].playerInfo) and self.openType == 2 then--无数据才点
                tempPosIndex = tag;
                beganTag = tag
                local pX,pY = beganItem:getPosition();
                break;
            end
        end
        return true
    end
    
    local function onTouchMoved(x, y)
        
    end
    
    local function onTouchEnded(x, y)
        --cclog("onTouchEnded: %0.2f, %0.2f", x, y)
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        for endTag = 1,5 do
            endItem = self.cellTable[endTag].cell
            if endItem and endItem:boundingBox():containsPoint(realPos) and (not self.cellTable[endTag].playerInfo) and self.openType == 2 then
                if endTag == beganTag then
                    --点击
                    local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            self:joinTeam(endTag)
                        end,   --可缺省
                        okBtnText = string_config.m_btn_sure,       --可缺省
                        cancelBtnText = string_config.m_btn_cancel,
                        text = " Vào đội này chứ",      --可缺省确定加入该队伍吗？
                        onlyOneBtn = false,
                        touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                    }
                    game_util:openAlertView(t_params)
                    break;
                end
            end
        end
    end
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
            elseif eventType == "moved" then
            return onTouchMoved(x, y)
            else
            return onTouchEnded(x, y)
        end
    end
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+131)
    formation_layer:setTouchEnabled(true)
end
--[[--
    初始化
]]
function game_team_boss_info.init(self,t_params)
    t_params = t_params or {};

    self.openType = t_params.openType
    self.teamInfoData = t_params.teamInfo
    self.time_count_down = t_params.time_count_down or 0
    -- cclog2(self.teamInfoData,"self.teamInfoData")
    self.m_auto_time = 5
    self.netFlag = false;
    self.moveFlag = false;
end

--[[--
    创建ui入口并初始化数据
]]
function game_team_boss_info.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_team_boss_info;