---  好友 

local game_friend_scene = {
    m_popUi = nil,
    m_root_layer = nil,
    m_list_view_bg = nil,
    m_search_node = nil,
    m_edit_bg_node = nil,
    m_search_btn = nil,
    m_close_btn = nil,
    m_search_list_view_bg = nil,
    m_tab_btn_1 = nil,
    m_tab_btn_2 = nil,
    m_tab_btn_3 = nil,
    m_showIndex = nil,
    m_tFriendData = nil,
    m_tMessagesData = nil,
    m_tSearchData = nil,
    m_searchUID = nil,
    m_node_topinfo_board = nil,
    m_node_messageboard = nil,
    m_node_friendboard = nil,
    m_conbtn_getrew = nil,
    m_blabel_topfriend = nil,
    m_blabel_topget = nil,
    m_showType = nil,
    m_sel_friendIndex = nil,
    m_sel_messageIndex = nil,
    m_chipID = nil, --新大富翁传来的碎片id
    flag_id =nil, --世界杯收集国旗

};
--local friendMenuTab = {{title = "Tỉ thí",type=1},{title = "Mời vào liên minh",type=1},{title = "Phát Chat riêng",type=1}, {title = "Xóa",type=2}}--,{title = "聊天",type=1}
local friendMenuTab = {{title = "Tỉ thí",type=1},{title = "Mời vào liên minh",type=1}, {title = "Xóa",type=2}}--,{title = "聊天",type=1}
local searchMenuTab = {{title = "Thêm bạn",type=1}, {title = "Mời vào liên minh",type=1}}

--[[--
    銷毀
]]
function game_friend_scene.destroy(self)
    -- body
    -- cclog("-----------------game_friend_scene destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_list_view_bg = nil;
    self.m_search_node = nil;
    self.m_edit_bg_node = nil;
    self.m_search_btn = nil;
    self.m_close_btn = nil;
    self.m_search_list_view_bg = nil;
    self.m_tab_btn_1 = nil;
    self.m_tab_btn_2 = nil;
    self.m_tab_btn_3 = nil;
    self.m_showIndex = nil;
    self.m_tFriendData = nil;
    self.m_tMessagesData = nil;
    self.m_tSearchData = nil;
    self.m_searchUID = nil;
    self.m_node_topinfo_board = nil;
    self.m_node_messageboard = nil;
    self.m_node_friendboard = nil;
    self.m_conbtn_getrew = nil;
    self.m_blabel_topfriend = nil;
    self.m_blabel_topget = nil;
    self.m_showType = nil;
    self.m_sel_friendIndex = nil;
    self.m_sel_messageIndex = nil;
    self.m_chipID = nil;
    self.flag_id =nil;
end
--[[--
    返回
]]
function game_friend_scene.back(self,type)
    if self.m_chipID then
        local function responseMethod(tag,gameData)
           game_scene:enterGameUi("game_newRichMan_main",{gameData = gameData});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_index"), http_request_method.GET, nil,"monopoly_index")
    else
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
    if self.flag_id then
        local function ResponseMethod(tag,gameData)
            game_scene:addPop("game_world_cup_flag",{gameData = gameData})
        end
        local params = {};
        network.sendHttpRequest(ResponseMethod,game_url.getUrlForKey("world_cup_flag_index"), http_request_method.GET, params,"world_cup_flag_index")
    else
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    讀取ccbi創建ui
]]
function game_friend_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--關閉
            self:back();
        elseif btnTag == 2 or btnTag == 3 or btnTag == 4 then--
            self.m_showIndex = btnTag - 1;
            self:refreshTabBtn();
        elseif btnTag == 11 then  -- 一鍵收取
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                self:refreshTab2(gameData)
                game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
            end
            local params = {};
            params.accept_all = 1;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_read_message"), http_request_method.GET, params,"friend_read_message")
        end
    end
    local function onSearchBtnClick( target,event )
        if self.m_searchUID and self.m_searchUID ~= "" then
            -- cclog("self.m_searchUID ========" .. self.m_searchUID)
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                local user = data:getNodeWithKey("user");
                self:initFriendData(gameData)
                self.m_tSearchData.data = json.decode(user:getFormatBuffer()) or {}
                self:refreshTab3();
            end
            --target_id
            local params = {};
            params.target_id = tostring(util.url_encode(self.m_searchUID));
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_search"), http_request_method.GET, params,"friend_search")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:registerFunctionWithFuncName("onSearchBtnClick",onSearchBtnClick);
    ccbNode:openCCBFile("ccb/ui_friend_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_search_node = ccbNode:nodeForName("m_search_node")
    self.m_edit_bg_node = ccbNode:scale9SpriteForName("m_edit_bg_node")
    self.m_search_btn = ccbNode:controlButtonForName("m_search_btn");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_tab_btn_1 = ccbNode:controlButtonForName("m_tab_btn_1");
    self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2");
    self.m_tab_btn_3 = ccbNode:controlButtonForName("m_tab_btn_3");
    self.m_search_list_view_bg = ccbNode:layerForName("m_search_list_view_bg")
    self.m_node_topinfo_board = ccbNode:nodeForName("m_node_topinfo_board")
    self.m_node_messageboard = ccbNode:nodeForName("m_node_messageboard");
    self.m_node_friendboard = ccbNode:nodeForName("m_node_friendboard");
    self.m_conbtn_getrew = ccbNode:controlButtonForName("m_conbtn_getrew")
    self.m_blabel_topget = ccbNode:labelBMFontForName("m_blabel_topget");
    self.m_blabel_topfriend = ccbNode:labelBMFontForName("m_blabel_topfriend");

    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScale(resolution_config:getScale())

    self.m_edit_bg_node:setOpacity(0);
    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_searchUID = edit:getText();
        end
    end
    local editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = self.m_edit_bg_node:getContentSize(),placeHolder="Nhập"});
    editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_edit_bg_node:addChild(editBox);

    self.m_search_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_tab_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_tab_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_tab_btn_3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_conbtn_getrew:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    創建好友列表
]]
function game_friend_scene.lookPlayerInfo(self,uid, isFriend)
    local function responseMethod(tag,gameData)
        game_scene:addPop("game_player_info_pop",{gameData = gameData, isFriend = isFriend})
    end
    local params = {};
    params.uid = uid;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, params,"user_info")
end

--[[--
    創建好友列表
]]
function game_friend_scene.createFriendTableView(self,viewSize)
    local tGameData = self.m_tFriendData.data;
    cclog(" #tGameData ==============" ..  #tGameData)
    local selIndex = nil;
    local function menuPopCallFunc(tag)
        game_scene:removePopByName("game_menu_pop")
        if tag == 1 then--切磋
            local function responseMethod(tag,gameData)
                game_data:setBattleType("friend_pk");
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                self:destroy();
            end
            local itemData = tGameData[selIndex+1];
            local params = {};
            params.target_id = itemData.uid;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_battle"), http_request_method.GET, params,"friend_battle")
        elseif tag == 2 then--聯盟邀請
            local itemData = tGameData[selIndex+1];
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local msg = string_config:getTextByKeyAndReplaceOne("guild_send_invite_tips", "PLAYER", itemData.name or "Đối phương")
                game_util:addMoveTips({text = msg});
            end
            local params = {};
            params.target_id = itemData.uid
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_invite"), http_request_method.GET, params,"guild_invite")
        elseif tag == 4 then-- 發起聊天
            -- local itemData = tGameData[selIndex+1];
            -- game_scene:addPop("ui_chat_pop", {openType = 3, friendUID = itemData.uid, friendName = itemData.name});
        elseif tag == 3 then--刪除
            local function responseMethod(tag,gameData)
                game_scene:removePopByName("game_menu_pop")
                local data = gameData:getNodeWithKey("data");
                local friends = data:getNodeWithKey("friends");
                self:initFriendData(gameData)
                self.m_tFriendData.data = json.decode(friends:getFormatBuffer()) or {}
                self.m_list_view_bg:removeAllChildrenWithCleanup(true);
                local tableViewTemp = self:createFriendTableView(self.m_list_view_bg:getContentSize());
                self.m_list_view_bg:addChild(tableViewTemp, 0, 889);
                cclog2(self.m_sel_friendIndex, "self.m_sel_friendIndex ")
                self:setTableViewIndex( self.m_sel_friendIndex or 0, self.m_list_view_bg,  889, 4)
            end
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    local itemData = tGameData[selIndex+1];
                    local params = {};
                    params.target_id = itemData.uid;
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_remove_friend"), http_request_method.GET, params,"friend_remove_friend")
                    game_util:closeAlertView();
                end,   --可缺省
                okBtnText = "Xóa bạn",       --可缺省
                text = "Bạn xác định xóa người bạn này?",      --可缺省
            }
            game_util:openAlertView(t_params);
        end
    end

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag  ===  ", btnTag)
        local index = btnTag - 10000
        self.m_sel_friendIndex = index
        local function responseMethod(tag,gameData)
            cclog2(gameData, "gameData  ===  ")
            if self.m_tFriendData.data[index+1] then
                self.m_tFriendData.data[index+1].has_send_gift = true
            end
            self:refreshTab1()
        end
        local itemData = tGameData[index+1];
        if not itemData then return end
        local params = {};
        params.target_id = itemData.uid;
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_send_gift"), http_request_method.GET, params,"friend_send_gift")
    end


    local function onHeadBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local tGameData = self.m_tFriendData.data;
        local itemData = tGameData[btnTag+1]
        self:lookPlayerInfo(itemData.uid, true);
    end
    local function onBtnCilckRich( target, event )  --changedByZJR  新大富翁赠送好友碎片
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();

        if btnTag >3000 then
            local itemData = tGameData[btnTag-3000]
            local params = {}
            params.friend_id = itemData.uid
            params.flag_id = self.flag_id
            local function responseMethod(tag,gameData)
                cclog("use successful~")
                game_util:addMoveTips({text = "Đã tặng"})
                self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_cup_flag_send_friend"), http_request_method.GET, params,"world_cup_flag_send_friend")
        else
            local params = {}
            local itemData = tGameData[btnTag-300]
            params.target_id = itemData.uid
            params.puzzle = self.m_chipID
            local function responseMethod(tag,gameData)
                cclog("use successful~")
                game_util:addMoveTips({text = "Đã tặng"})
                self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_send_puzzle"), http_request_method.GET, params,"monopoly_send_puzzle")           
        end
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tGameData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();

            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            ccbNode:registerFunctionWithFuncName("onBtnCilckRich",onBtnCilckRich);
            ccbNode:openCCBFile("ccb/ui_friend_list_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = tGameData[index+1];
            
            -- cclog("itemData == " .. json.encode(itemData))

            if ccbNode then
                local m_rank_label = ccbNode:labelTTFForName("m_rank_label")
                local m_player_icon = ccbNode:spriteForName("m_icon_node");
                local m_level_label = ccbNode:labelTTFForName("m_level_label")
                local m_player_label = ccbNode:labelTTFForName("m_player_label")
                local m_online_icon = ccbNode:spriteForName("m_online_icon");
                local m_guild_icon = ccbNode:spriteForName("m_guild_icon");
                local m_guild_label = ccbNode:labelTTFForName("m_guild_label")
                local m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
                local m_btn_send = ccbNode:controlButtonForName("m_btn_send")
                local m_btn_sends = ccbNode:controlButtonForName("m_btn_sends")
                local m_node_sthboard = ccbNode:nodeForName("m_node_sthboard")
                m_btn_send:setTag(index+301)
                m_btn_sends:setTag(index + 3001)
                m_btn_send:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
                m_btn_sends:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
                -- print("itemData =========== " .. tostring(itemData.level) .. " ; m_level_label " .. tostring(tolua.type(m_level_label)));
                m_level_label:setString(tostring(itemData.level))
                m_rank_label:setString(tostring(index+1))
                m_player_label:setString(tostring(itemData.name));
                m_combat_label:setString(tostring(itemData.combat));
                if itemData.online then
                    m_online_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_on.png"))
                else
                    m_online_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_off.png"))
                end
                m_guild_label:setString(tostring(itemData.association_name))
                --頭像
                local role = itemData.role
                local icon = game_util:createPlayerIconByRoleId(tostring(role));
                local icon_alpha = game_util:createPlayerIconByRoleId(tostring(role));
                if icon then
                    m_player_icon:removeAllChildrenWithCleanup(true);
                    icon_alpha:setAnchorPoint(ccp(0.5,0.5))
                    icon_alpha:setPosition(m_player_icon:getContentSize().width * 0.5, m_player_icon:getContentSize().height * 0.6)
                    icon_alpha:setOpacity(100)
                    icon_alpha:setColor(ccc3(0,0,0))
                    m_player_icon:addChild(icon_alpha)
                    icon:setAnchorPoint(ccp(0.5,0.5))
                    icon:setPosition(m_player_icon:getContentSize().width * 0.5, m_player_icon:getContentSize().height * 0.6)
                    m_player_icon:addChild(icon);

                    self:createTouchButton({fun = onHeadBtnCilck, parent = icon, tag = index})
                else
                    -- cclog("tempFrontUser.role " .. user_info.role .. " not found !")
                end

                m_node_sthboard:removeAllChildrenWithCleanup(true)
                if itemData.has_send_gift ~= true then
                    m_node_sthboard:removeAllChildrenWithCleanup(true)
                    self:createTouchButton({fun = onBtnCilck, parent = m_node_sthboard, tag = 10000 + index, sprName = "ui_friend_icon_sende.png", isShow = true})
                end
                cclog2(self.m_chipID,"self.m_chipID-=---------")
                if self.m_chipID then 
                    -- cclog("11111111")
                    m_node_sthboard:setVisible(false)
                    m_btn_send:setVisible(true)
                else
                    -- cclog("2222222")
                    m_node_sthboard:setVisible(true)
                    m_btn_send:setVisible(false)
                end
                if self.flag_id then
                    m_node_sthboard:setVisible(false)
                    m_btn_sends:setVisible(true)
                else
                    m_node_sthboard:setVisible(true)
                    m_btn_sends:setVisible(false)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if self.m_chipID or self.flag_id then--changedByZJR 
        else
            if eventType == "ended" and cell then
                self.m_sel_friendIndex = index
                cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
                local px,py = cell:getPosition();
                local pos = cell:getParent():convertToWorldSpace(ccp(px+itemSize.width*0.5,py+itemSize.height*0.5));
                -- cclog("pos x ,y = " .. pos.x .. " ; " .. pos.y);
                selIndex = index;
                game_scene:addPop("game_menu_pop",{menuTab = friendMenuTab,pos = pos,callFunc = menuPopCallFunc});
            end
        end
    end
    return TableViewHelper:create(params);
end

--[[--

]]
function game_friend_scene.refreshTab1(self)
    self:refreshTabNot(self.m_list_view_bg)
    self.m_showType = "friends"
    self.m_search_node:setVisible(false)
    self.m_list_view_bg:setVisible(true);
    if self.m_tFriendData.init == false then
        local function responseMethod(tag,gameData)
            self.m_tFriendData.init = true;
            self:initFriendData(gameData)
            local data = gameData:getNodeWithKey("data");
            local friends = data:getNodeWithKey("friends");
            self.m_tFriendData.data = json.decode(friends:getFormatBuffer()) or {}
            self.m_list_view_bg:removeAllChildrenWithCleanup(true);
            local tableViewTemp = self:createFriendTableView(self.m_list_view_bg:getContentSize());
            self.m_list_view_bg:addChild(tableViewTemp, 0, 889);
            self:setTableViewIndex( self.m_sel_friendIndex or 0, self.m_list_view_bg,  889, 4)
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_friends"), http_request_method.GET, nil,"friend_friends")
    else
        self.m_list_view_bg:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createFriendTableView(self.m_list_view_bg:getContentSize());
        self.m_list_view_bg:addChild(tableViewTemp, 0, 889);
        self:setTableViewIndex( self.m_sel_friendIndex or 0, self.m_list_view_bg,  889, 4)
    end

    self.m_node_messageboard:setVisible(false);
end


--[[--
    創建消息列表
]]
function game_friend_scene.createMessageTableView(self,viewSize)
    local tGameData = self.m_tMessagesData.data;
    cclog(" #tGameData ==============" ..  #tGameData)
    local selIndex = nil;
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag  ===  ", btnTag)

        local mesgType = math.floor(btnTag % 10000 )
        mesgType = math.floor(mesgType / 100)
        local index = math.floor(btnTag %100)

        if mesgType == 1 then
            local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data");
            self:refreshTab2(gameData)
            game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
        end
        local itemData = tGameData[index+1];
       self.m_sel_messageIndex = index
        if not itemData then return end
        local params = {};
        params.message_id = itemData.id;
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_read_message"), http_request_method.GET, params,"friend_read_message")
        elseif mesgType == 2 then
            local itemData = tGameData[index+1];
           self.m_sel_messageIndex = index
            local function responseMethod(tag,gameData)
                cclog2(gameData, "gameData  ===  ")
                local data = gameData:getNodeWithKey("data");
                self:refreshTab2(gameData)
                self.m_tFriendData.init = false
                local msg = string_config:getTextByKeyAndReplaceOne("friend_hadbeen_friedn_tips", "PLAYER", itemData.send_name or "Đối phương")
                game_util:addMoveTips({text = msg});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_read_message"), http_request_method.GET, {message_id = itemData.id, agree_friend = 1},"friend_read_message")
        elseif mesgType == 3 then
            local itemData = tGameData[index+1];
           self.m_sel_messageIndex = index
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    local function responseMethod(tag,gameData)
                        cclog2(gameData, "gameData  ===  ")
                        local data = gameData:getNodeWithKey("data");
                        self:refreshTab2(gameData)
                    end
                    local params = {};
                    params.message_id = itemData.id;
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_read_message"), http_request_method.GET, params,"friend_read_message")
                    game_util:closeAlertView();
                end,   --可缺省
                okBtnText = "Xác định",       --可缺省
                text = string_config:getTextByKeyAndReplace("friend_beAdd_friend", "PLAYER", itemData.send_name or "");
            }
            game_util:openAlertView(t_params);
        elseif mesgType == 4 then
            local itemData = tGameData[index+1];
            self.m_sel_messageIndex = index
            local function responseMethod(tag,gameData)
                cclog2(gameData, "gameData  ===  ")
                local data = gameData:getNodeWithKey("data");
                self:refreshTab2(gameData)
                self.m_tFriendData.init = false
                local msg = string_config:getTextByKeyAndReplaceOne("guild_hadjoined__tips", "GUILD", itemData.send_association_name or "Liên minh đối phương")
                game_util:addMoveTips({text = msg});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_read_message"), http_request_method.GET, {message_id = itemData.id, agree_friend = 1},"friend_read_message")
        

        end
    end

    local function onHeadBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local tGameData = self.m_tMessagesData.data;
        self.m_sel_messageIndex = btnTag
        local itemData = tGameData[btnTag+1]
        self:lookPlayerInfo(itemData.send_uid);
    end

    local function onRejectBtnClick( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local tGameData = self.m_tMessagesData.data;
        local itemData = tGameData[btnTag+1]
        self.m_sel_messageIndex = btnTag
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data");
            self:refreshTab2(gameData) 
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_read_message"), http_request_method.GET, {message_id = itemData.id, agree_friend = 0},"friend_read_message")
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tGameData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_friend_list_message_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = tGameData[index+1];
            if ccbNode then
                local m_rank_label = ccbNode:labelTTFForName("m_rank_label")
                local m_player_icon = ccbNode:spriteForName("m_icon_node");
                local m_level_label = ccbNode:labelTTFForName("m_level_label")
                local m_player_label = ccbNode:labelTTFForName("m_player_label")
                local m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
                local m_node_sthboard = ccbNode:nodeForName("m_node_sthboard")
                local m_node_sthboard2 = ccbNode:nodeForName("m_node_sthboard2")
                m_node_sthboard2:setVisible(false)
                m_node_sthboard2:removeAllChildrenWithCleanup(true)

                local m_sprite_addfriend = ccbNode:spriteForName("m_sprite_addfriend")
                m_sprite_addfriend:setVisible(false)
                -- print("itemData =========== " .. tostring(itemData.level) .. " ; m_level_label " .. tostring(tolua.type(m_level_label)));
                m_level_label:setString(tostring(itemData.send_level))
                m_rank_label:setString(tostring(index+1))
                m_player_label:setString(tostring(itemData.send_name));
                m_combat_label:setString(tostring(itemData.send_combat));

                --頭像
                local role = itemData.send_role
                local icon = game_util:createPlayerIconByRoleId(tostring(role));
                local icon_alpha = game_util:createPlayerIconByRoleId(tostring(role));
                if icon then
                    m_player_icon:removeAllChildrenWithCleanup(true);
                    icon_alpha:setAnchorPoint(ccp(0.5,0.5))
                    icon_alpha:setPosition(m_player_icon:getContentSize().width * 0.5, m_player_icon:getContentSize().height * 0.6)
                    icon_alpha:setOpacity(100)
                    icon_alpha:setColor(ccc3(0,0,0))
                    m_player_icon:addChild(icon_alpha)
                    icon:setAnchorPoint(ccp(0.5,0.5))
                    icon:setPosition(m_player_icon:getContentSize().width * 0.5, m_player_icon:getContentSize().height * 0.6)
                    m_player_icon:addChild(icon);

                    self:createTouchButton({fun = onHeadBtnCilck, parent = icon, tag = index})

                else
                    cclog("tempFrontUser.role " .. itemData.send_role or "" .. " not found !")
                end
                local message = ""
                local tag = 0
                local btnName = nil
                if itemData.sort == "action_point" then
                    tag = 1
                    btnName = "ui_friend_icon_gete.png"
                elseif itemData.sort == "add_friend" then
                    m_sprite_addfriend:setVisible(true)
                    tag = 2
                    btnName = "ui_friend_icon_agree.png"
                    message = "Gửi cho bạn lời mời kết bạn"

                    m_node_sthboard2:setVisible(true)
                    self:createTouchButton({fun = onRejectBtnClick, parent = m_node_sthboard2, tag = index, isShow = true, sprName = "ui_friend_icon_reject.png"})
                elseif itemData.sort == "agree_friend"  then
                    tag = 3
                    btnName = "ui_friend_icon_lookm.png"
                    message = "Đồng ý kết bạn với bạn"
                elseif itemData.sort == "guild_invite" then
                    tag = 4
                    btnName = "ui_friend_icon_agree.png"
                    message = "Mời bạn vào liên minh:" .. itemData.send_association_name or ""
                    m_node_sthboard2:setVisible(true)
                    self:createTouchButton({fun = onRejectBtnClick, parent = m_node_sthboard2, tag = index , isShow = true, sprName = "ui_friend_icon_reject.png"})
                end
                cclog2(message, "message   ===   ")
                local m_node_messageboard = ccbNode:nodeForName("m_node_messageboard")
                m_node_messageboard:removeChildByTag(898, true)
                local itemSize = CCSizeMake(m_node_messageboard:getContentSize().width , 0)
                local richLabel = game_util:createRichLabelTTF({text = message,dimensions = itemSize,textAlignment = kCCTextAlignmentLeft,
                    verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(255,255,255),fontSize = 11})
                richLabel:setAnchorPoint(ccp(0,1))
                richLabel:setPosition(ccp(0, m_node_messageboard:getContentSize().height))
                m_node_messageboard:addChild(richLabel, 1, 898)

                if btnName then
                    m_node_sthboard:removeAllChildrenWithCleanup(true)
                    self:createTouchButton({fun = onBtnCilck, parent = m_node_sthboard, tag = 10000 + index + tag * 100, isShow = true, sprName = btnName})
                end

            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    加好友回調提示
]]
function game_friend_scene.addFriendBackInfo( self, gameData )
    local data = gameData:getNodeWithKey("data")
    local info = string_config:getTextByKey("friend_send_add_friedn_tips")

    -- info = string_config:getTextByKey("friend_send_hadadd_friedn_tips")
    msg = string.gsub(info, "PLAYER", name )
    game_util:addMoveTips({text = msg});
end

--[[--
    創建一個接受觸摸事件的button
]]
-- function game_friend_scene.createTouchButton( self, fun, parent, tag , isShow, anchorX, anchorY)
function game_friend_scene.createTouchButton( self, params )
    if not params.parent then return end
    local button = game_util:createCCControlButton(params.sprName or "public_weapon.png","",params.fun)
    local tempSize = params.parent:getContentSize()
    button:setAnchorPoint(ccp(0.5,0.5))
    button:setPosition(ccp(tempSize.width * (anchorX or 0.5), tempSize.height* (anchorY or 0.5)))
    if not params.isShow then
        button:setOpacity(0)
    end
    params.parent:addChild(button)
    button:setTag(params.tag)
end
--[[--

]]
function game_friend_scene.refreshTab2(self, gameData)
    self:refreshTabNot(self.m_list_view_bg)
    self.m_showType = "messages"
    self.m_node_messageboard:setVisible(true);
    self.m_search_node:setVisible(false)
    self.m_list_view_bg:setVisible(true);
    if self.m_tMessagesData.init and gameData then
        self:initFriendData(gameData)
        self.m_list_view_bg:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createMessageTableView(self.m_list_view_bg:getContentSize());
        self.m_list_view_bg:addChild(tableViewTemp);
    elseif self.m_tMessagesData.init == false then
        local function responseMethod(tag,gameData)
            self.m_tMessagesData.init = true;
            self:initFriendData(gameData)
            self.m_list_view_bg:removeAllChildrenWithCleanup(true);
            local tableViewTemp = self:createMessageTableView(self.m_list_view_bg:getContentSize());
            self.m_list_view_bg:addChild(tableViewTemp, 0, 889);
            self:setTableViewIndex( self.m_sel_messageIndex or 0, self.m_list_view_bg,  889, 4)
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_messages"), http_request_method.GET, nil,"friend_messages")
    else
        self.m_list_view_bg:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createMessageTableView(self.m_list_view_bg:getContentSize());
        self.m_list_view_bg:addChild(tableViewTemp, 0, 889);
        self:setTableViewIndex( self.m_sel_messageIndex or 0, self.m_list_view_bg,  889, 4)
    end
end

function game_friend_scene.refreshTabNot( self, list )
    if list ~= self.m_search_list_view_bg then self.m_search_list_view_bg:removeAllChildrenWithCleanup(true) end
    if list ~= self.m_list_view_bg then self.m_list_view_bg:removeAllChildrenWithCleanup(true) end
end

--[[--
    初始化消息列表
]]
function game_friend_scene.initFriendData( self, gameData)

    if not gameData then return end
    local data = gameData:getNodeWithKey("data")
    if not data then return end
    local friend_top = data:getNodeWithKey("friend_top") and data:getNodeWithKey("friend_top"):toInt() 
    local friend_len = data:getNodeWithKey("friend_len") and data:getNodeWithKey("friend_len"):toInt() 
    local accept_action_point = data:getNodeWithKey("accept_action_point") and data:getNodeWithKey("accept_action_point"):toInt() 
    local accept_action_point_top = data:getNodeWithKey("accept_action_point_top") and data:getNodeWithKey("accept_action_point_top"):toInt() 
    if friend_top and friend_len then
        self.m_blabel_topfriend:setString(friend_len .. "/" .. friend_top)
    end
    if accept_action_point and accept_action_point_top then
        self.m_blabel_topget:setString(accept_action_point .. "/" .. accept_action_point_top)
    end
    local btnFlag = true
    local msgFlag = false
    if accept_action_point and accept_action_point >= accept_action_point_top then
        btnFlag = false
    else
        btnFlag = true
    end


    local messages = data:getNodeWithKey("messages")
    if messages then 
        self.m_tMessagesData.init = true
        self.m_tMessagesData.data = json.decode(messages:getFormatBuffer()) or {}
        if btnFlag then
            for i,v in pairs(self.m_tMessagesData.data ) do
                cclog2(v, "self.m_tMessagesData.data   ========   ")
                if v.sort == "action_point" then
                    msgFlag = true 
                end
            end
        end
    end


    if btnFlag and msgFlag then
        self.m_conbtn_getrew:setVisible(true)
    else
        self.m_conbtn_getrew:setVisible(false)
    end


    local friends = data:getNodeWithKey("friends")
    if friends then
        self.m_tFriendData.init = true;
        self.m_tFriendData.data = json.decode(friends:getFormatBuffer()) or {}
    end
end



--[[--
    創建搜索列表
]]
function game_friend_scene.createSearchTableView(self,viewSize)
    local tGameData = self.m_tSearchData.data;
    cclog(" #tGameData ==============" ..  #tGameData)
    local selIndex = nil;
    local function menuPopCallFunc(tag)
        game_scene:removePopByName("game_menu_pop")
        if tag == 1 then--添加好友
            local function responseMethod(tag,gameData)
                game_scene:removePopByName("game_menu_pop")
                self:addFriendBackInfo(gameData)
            end
            local itemData = tGameData[selIndex+1];
            local params = {};
            params.target_id = itemData.uid;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_apply_friend"), http_request_method.GET, params,"friend_apply_friend")
        elseif tag == 2 then--聯盟邀請
            local itemData = tGameData[selIndex+1];
            if itemData.uid == game_data:getUserStatusDataByKey("uid") then
                game_util:addMoveTips({text = "Không thể mời bản thân vào liên minh!"});
                return;
            end
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local msg = string_config:getTextByKeyAndReplaceOne("guild_send_invite_tips", "PLAYER", itemData.name or "Đối phương")
                game_util:addMoveTips({text = msg});
            end
            local params = {};
            params.target_id = itemData.uid
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_invite"), http_request_method.GET, params,"guild_invite")
        elseif tag == 3 then-- 發起聊天
            local itemData = tGameData[selIndex+1];
            if itemData.uid == game_data:getUserStatusDataByKey("uid") then
                game_util:addMoveTips({text = "Chat riêng với bản thân!"});
                return;
            end
            local itemData = tGameData[selIndex+1];
            game_scene:addPop("ui_chat_pop", {openType = 3, friendUID = itemData.uid, friendName = itemData.name});
        end
    end
    local function onHeadBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local tGameData = self.m_tSearchData.data;
        local itemData = tGameData[btnTag+1]
        self:lookPlayerInfo(itemData.uid);
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tGameData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_friend_list_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = tGameData[index+1];
            if ccbNode then
                local m_rank_label = ccbNode:labelTTFForName("m_rank_label")
                local m_player_icon = ccbNode:spriteForName("m_icon_node");
                local m_level_label = ccbNode:labelTTFForName("m_level_label")
                local m_player_label = ccbNode:labelTTFForName("m_player_label")
                local m_online_icon = ccbNode:spriteForName("m_online_icon");
                local m_guild_icon = ccbNode:spriteForName("m_guild_icon");
                local m_guild_label = ccbNode:labelTTFForName("m_guild_label")
                local m_combat_label = ccbNode:labelBMFontForName("m_combat_label")

                -- print("itemData =========== " .. tostring(itemData.level) .. " ; m_level_label " .. tostring(tolua.type(m_level_label)));
                m_level_label:setString(tostring(itemData.level))
                m_rank_label:setString(tostring(index+1))
                m_player_label:setString(tostring(itemData.name));
                m_combat_label:setString(tostring(itemData.combat));
                m_guild_label:setString(tostring(itemData.association_name))
                if itemData.online then
                    m_online_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_on.png"))
                else
                    m_online_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_off.png"))
                end

                --頭像
                local role = itemData.role
                local icon = game_util:createPlayerIconByRoleId(tostring(role));
                local icon_alpha = game_util:createPlayerIconByRoleId(tostring(role));
                if icon then
                    m_player_icon:removeAllChildrenWithCleanup(true);
                    icon_alpha:setAnchorPoint(ccp(0.5,0.5))
                    icon_alpha:setPosition(m_player_icon:getContentSize().width * 0.5 + 1, m_player_icon:getContentSize().height * 0.6 + 1)
                    icon_alpha:setOpacity(100)
                    icon_alpha:setColor(ccc3(0,0,0))
                    m_player_icon:addChild(icon_alpha)
                    icon:setAnchorPoint(ccp(0.5,0.5))
                    icon:setPosition(m_player_icon:getContentSize().width * 0.5, m_player_icon:getContentSize().height * 0.6)
                    m_player_icon:addChild(icon);
                    self:createTouchButton({fun = onHeadBtnCilck, parent = icon, tag = index})
                else
                    cclog("tempFrontUser.role " .. user_info.role .. " not found !")
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
            selIndex = index;
            local px,py = cell:getPosition();
            local pos = cell:getParent():convertToWorldSpace(ccp(px+itemSize.width*0.5,py+itemSize.height*0.5));
            game_scene:addPop("game_menu_pop",{menuTab = searchMenuTab,pos=pos,callFunc = menuPopCallFunc});
        end
    end
    return TableViewHelper:create(params);
end

--[[--

]]
function game_friend_scene.refreshTab3(self)
    self:refreshTabNot(self.m_search_list_view_bg)
    self.m_showType = "search"
    self.m_search_node:setVisible(true)
    self.m_list_view_bg:setVisible(false);
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_search_list_view_bg:removeAllChildrenWithCleanup(true);    
    local tableViewTemp = self:createSearchTableView(self.m_search_list_view_bg:getContentSize());
    self.m_search_list_view_bg:addChild(tableViewTemp);
end

--[[--

]]
function game_friend_scene.refreshTabBtn(self)
    
    local flag1 = self.m_showIndex == 1 and true or false
    local flag2 = self.m_showIndex == 2 and true or false
    local flag3 = self.m_showIndex == 3 and true or false
    self.m_tab_btn_1:setHighlighted(flag1);
    self.m_tab_btn_1:setEnabled(not flag1);
    self.m_tab_btn_2:setHighlighted(flag2);
    self.m_tab_btn_2:setEnabled(not flag2);
    self.m_tab_btn_3:setHighlighted(flag3);
    self.m_tab_btn_3:setEnabled(not flag3);
    cclog2(self.m_showIndex,"self.m_showIndex-=-----------")
    if self.m_showIndex == 1 then
        self:refreshTab1();
    elseif self.m_showIndex == 2 then
        self:refreshTab2();
    elseif self.m_showIndex == 3 then
        self:refreshTab3();
    end
end

--[[--
    刷新ui
]]
function game_friend_scene.refreshUi(self)
    self:refreshTabBtn();    
end

--[[
    設置table view 的 index
    index 索引 table view 父節點 tag , 一頁顯示幾個cell
]]
function game_friend_scene.setTableViewIndex(self,index,tableNode,tag,cellCount)
    local tempTable = tolua.cast(tableNode:getChildByTag(tag),"TableView")
    local contentSize = tempTable:getContentSize()
    local viewSize = tempTable:getViewSize()
    local size = tableNode:getContentSize()
    -- cclog("contentSize = " .. contentSize.height .. "size = " .. size.height)
    local cellHeight = size.height  / cellCount;--一個cell的高度
    if viewSize.height <= contentSize.height then--如果contentSize 大於 viewSize 則不需要設置偏移
        tempTable:setContentOffset(ccp(0, math.min(viewSize.height - contentSize.height + index * cellHeight, 0)))
    end
end

--[[--
    初始化
]]
function game_friend_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_showIndex = t_params.showIndex or 1;
    self.m_tFriendData = {init = false,data = {}};
    self.m_tMessagesData = {init = false,data = {}}
    self.m_tSearchData = {init = false,data = {}}
    self.m_showType = "friends"
    self.m_chipID =nil
    self.flag_id = nil
    -- cclog2(t_params.chipID,"t_params.chipID=-----------")
    if t_params.chipID then
        self.m_chipID = t_params.chipID
    end
    if t_params.flag_id then
        self.flag_id = t_params.flag_id
    end
end

--[[--
    創建ui入口並初始化數據
]]
function game_friend_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi())
    self:refreshUi();
    return scene;
end

return game_friend_scene;