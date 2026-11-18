

local ui_chat_new_pop = {
    m_ccbNode = nil,            -- 
    m_editNode = nil,           -- 輸入框
    m_socket = nil,
    m_msg = nil,
    m_maxMsg = nil,
    m_curMsg = nil,
    m_curFlag =nil,             -- 分類標記 ， world,世界  guild,工會  friend,好友
    m_conectOk = nil,
    m_tempData = nil,
    m_root_layer = nil,
    m_itemBtn = nil,
    m_closeBtn = nil,
    m_chatBtnPress = nil,
    m_scroll_view = nil,
    m_scroll_fire = nil,
    m_card_btn = nil,
    m_equip_btn = nil,
    m_voice_btn = nil,
    m_item_btn = nil,
    m_share_btn = nil;
    m_showDataTab = nil,
    m_showGuildData = nil,
    m_showFriendData = nil,
    m_list_view_bg = nil,
    m_list_view_bg_friend = nil,
    m_list_view_fire = nil,
    m_editUserChanged = nil,
    m_popUi = nil,
    m_sendToName = nil,
    m_sendToAccid = nil,
    m_ownUID = nil,
    m_share_btn_layer = nil,
    m_openType = nil,
    m_sendToUid = nil,
    m_node_myicon = nil,
    m_node_chatother_board = nil,
    m_node_inputchat_board = nil,

    m_chatState = nil,
    m_chatOtherInfo = nil,

    m_chatObserver = nil,

    m_comeInChatFriendInfo = nil,

    m_avatarID = nil,

    m_friendChatSign = nil,

    m_editNodeBoard = nil,
    enterType = nil,
    m_msg_showtop = nil,
    m_last_tableview_y = nil,
    m_last_show_msgindex = nil,


    m_curShowMsgType = nil,
    m_curShowMsgIndex = nil,
    m_allWorldMsg = nil,
    m_oneChatCellSize = nil,

    m_chat_types = nil,
    m_sort_id = nil,

    m_last_msgIndex = nil,

    m_cur_showType = nil,

    m_sign_table = nil,
    m_history_table = nil,
    m_cur_chat_table = nil,
    m_offset_number = nil;
    m_refreshUI = nil,
    m_menu_items = nil,
    m_last_msgNumbers = nil,
    m_wordDay = nil,
    teamID = nil,
    friend_list = nil,
    m_item_count = nil,
    m_sendCount = nil,
    m_sendTime = nil,
    m_frechat_layer = nil,
}

function ui_chat_new_pop:destroy(  )
    cclog("-----------------ui_chat_pop destroy-----------------");
    -- body
    
    self.m_ccbNode = nil;
    self.m_msg = nil;
    self.m_maxMsg = nil;
    self.m_curMsg = nil;
    self.m_curFlag = nil;
    self.m_conectOk = nil;
    self.m_root_layer = nil;
    self.m_itemBtn = nil;
    self.m_closeBtn = nil;
    self.m_chatBtnPress = nil;
    self.m_scroll_view = nil;
    self.m_scroll_fire = nil;
    self.m_showDataTab = nil;
    self.m_showGuildData = nil;
    self.m_showFriendData = nil;
    self.m_list_view_bg = nil;
    self.m_list_view_bg_friend = nil;
    self.m_list_view_fire = nil;
    self.m_editUserChanged = nil;
    self.m_popUi = nil;
    self.m_sendToName = nil;
    self.m_sendToAccid = nil;
    self.m_ownUID = nil;
    self.m_share_btn_layer = nil;
    self.m_tempData = nil;
    self.m_openType = nil;
    self.m_sendToUid = nil;
    self.m_node_myicon = nil;
    self.m_node_chatother_board = nil;
    self.m_node_inputchat_board = nil;
    self.m_chatState = nil;
    self.m_chatOtherInfo = nil;
    self.m_chatObserver = nil;
    self.m_avatarID = nil;
    self.m_comeInChatFriendInfo = nil;
    self.m_editNodeBoard = nil;

    self.m_friendChatSign = nil;
    self.enterType = nil;
    self.m_msg_showtop = nil;
    self.m_last_tableview_y = nil;
    self.m_last_show_msgindex = nil;
    self.m_curShowMsgType = nil;
    self.m_curShowMsgIndex = nil;
    self.m_oneChatCellSize = nil;

    self.m_tableView = nil;

    self.m_chat_types = nil;
    self.m_menu_items = nil;
    self.m_sort_id = nil;
    self.m_last_msgIndex = nil;

    self.m_cur_showType = nil;
    self.m_sign_table = nil;
    self.m_offset_number = nil;
    self.m_cur_chat_table = nil;
    self.m_refreshUI = nil;
    self.m_last_msgNumbers = nil;
    self.teamID = nil;
    self.m_wordDay = nil;
    self.friend_list = nil;
    self.m_item_count = nil;
    self.m_sendCount = nil;
    self.m_sendTime = nil;
    self.m_frechat_layer = nil;
    cclog("-----------------ui_chat_pop destroy-----------------2");
end

local topMenuTab = {{title = "Xem",type=1},{title = "Chat riêng",type=1},{title = "Thêm bạn",type=1}}
local shieldKeywordTab = {
    "[ GM ]","[ GM]","[G M]","[GM","[GM ]","[GM]","{ GM }","{ GM}","{G M}","{GM","{GM }","{GM}","< GM >","< GM>","<G M>","<GM","<GM >","<GM>","G8","Ｇ８","Ｇ8","g8","ｇ８","ｇ8","干你娘","吊你老母","我操你老母","妳娘卡好","妳娘的","哭腰","臭婊子","基掰","嫩B","靠妖","靠背","一夜情","口交","干死你爸","干你","干你妹","干林娘","中出","叫春","打炮","穴穴","肉棒","我操","官方","性交","炮友","幹","嫩逼","靠么","操b","操死","Bitch","Fuck","大屌","自慰","老娼","老婊","肖查某","性虐待","TMD","生奸","老雞掰",
};


local tttype = {
        type1 = {{sort = 1, flag = "world"}, {sort = 2, flag = "guild"}, {sort = 3, flag = "friend"}},
        type2 = {{sort = 1, flag = "world"}, {sort = 2, flag = "guild"}, {sort = 3, flag = "friend"}, {sort = 4, flag = "guild_war"}},
        type3 = {{sort = 5, flag = "world"}, {sort = 2, flag = "guild"}, {sort = 3, flag = "friend"}},
        type4 = {{sort = 6, flag = "escort"}, {sort = 3, flag = "friend"}},
        type5 = {{sort = 7, flag = "rob"}, {sort = 3, flag = "friend"}},
        type6 = {{sort = 6, flag = "escort"}, {sort = 8, flag = "team"}, {sort = 3, flag = "friend"}},
        type7 = {{sort = 7, flag = "rob"}, {sort = 8, flag = "team"}, {sort = 3, flag = "friend"}},
    }

local tabPosYs = {
    pos1 = {72},
    pos2 = {70, 38},
    pos3 = {72, 39, 6},
    pos4 = {75, 50, 25, 1},
}

local typeTitles = {
    world = "Thế giới",
    guild = "Liên minh",
    friend = "Chat riêng",
    guild_war = "Tranh bá",
    outdoor = "Ngoại vực",
    escort = "Áp tiêu",
    rob = "Cướp tiêu",
    team = "Tiểu đội",
}

local tipsFlag = 
{
    friend = { friend = true, world = true},
    guild = { guild = true, world = true},
}


local menuType = 
{
    type1 = {{item = "card" }, { item = "equip"}  },
    type2 = {{item = "card" }, { item = "equip"} },
    type3 = {{item = "card" }, { item = "equip"}  },
    type4 = {{item = "card" }, { item = "equip"} },
    type5 = {{item = "card" }, { item = "equip"} },
    type6 = {{item = "card"}, { item = "equip" }},
    type7 = {{item = "card"}, { item = "equip" }},
}

local menuTitles = {    
    card = "Thẻ bài",
    equip = "Trang bị",
    share = "Shared",
    voice = "Tiếng",
    invite = "Mời",
    item = "Đạo cụ",
}

--[[--
    初始化
]]
function ui_chat_new_pop.back( self )
    require("shared.native_helper").exitCharRoom({})
    game_scene:removePopByName("ui_chat_new_pop");
    self:destroy()
end

--[[--
    读取ccbi创建ui
]]
function ui_chat_new_pop.createUi(self)
    -- body
    self.m_showDataTab = {};
    self.m_showGuildData = {};
    self.m_showFriendData = {};
    
    self.m_ccbNode = luaCCBNode:create();
    local function onCancel(target,event)
        -- body
        self:back()
    end

    local message = getConfig(game_config_field.message)
    local message_ban = getConfig(game_config_field.message_ban)
    local vipLevel = game_data:getUserStatusDataByKey("vip") or 0

    local message_data = json.decode(message:getFormatBuffer())
    local message_ban_data = json.decode(message_ban:getFormatBuffer())

    local send_num = 0;
    local send_cd = 5;
    local idx = 0
    local send_text = ""
    local gift = {}
    for k,v in pairs(message_data) do
        send_text = v["text"]
        if v.vip <= vipLevel and tonumber(k) >= idx then
            idx = tonumber(k)
            send_num = v.num
            send_cd = v.cd
        end
        if v.gift then 
            gift = v.gift
        end
    end
    cclog2(send_num,"send_num")

    local blockedWords = {}
    for k,v in pairs(message_ban_data) do
        table.insert(blockedWords,v["ban"])
    end
    cclog2(blockedWords,"blockedWords")
    local function filterWords(text)
        for _, word in ipairs(blockedWords) do
            local pattern = string.format("(%s)", word:lower())
            text = string.gsub(text, pattern, "***",1, "i")
        end
        return text
    end

    local function onOk(target,event)
        local tempstr = self.m_editNode:getText();
        tempstr = filterWords(tempstr)
        if tempstr == nil or tempstr == "" then 
            game_util:addMoveTips({text = "Xin nhập nội dung"});
            return 
        end
        

        local avatarID = game_data:updateLocalData("avatar_id")
        if avatarID == "" then
            local role = game_data:getUserStatusDataByKey("role")
            game_data:updateLocalData("avatar_id", tostring(role), true)
            avatarID = game_data:updateLocalData("avatar_id")
        end
        local tempData = {
            text = tempstr,
            account = self.m_sendToAccid,  --私聊好友的账号
            type = 0,
            teamID = self.teamID,
        }
        if self.m_curFlag == "friend" then 
            if self.m_sendToAccid == "" then
                game_util:addMoveTips({text = "xin nhập uid!"});
                return
            end
            local sendMsg = function(text)
                
            end
            tempData.text = json.encode({text=tempstr,sendToName=self.m_sendToName,avatarID = avatarID,data = self.m_tempData})
            require("shared.native_helper").sendMsg(tempData,sendMsg)
            self.m_editNode:setText("")
            self.m_tempData = {};
        elseif self.m_curFlag == "guild" then  --工会
            tempData.type = 2
            tempData.text = json.encode({text=tempstr,sendToName=self.m_sendToName,avatarID = avatarID,data = self.m_tempData})
            require("shared.native_helper").sendMsg(tempData,chatSendMsg)
            self.m_editNode:setText("")
            self.m_tempData = {};
        else
            cclog2(self.m_sendCount,"self.m_sendCount")
            local function newrefresh()
                self.m_wordDay = true;
            end
            tempData.text = json.encode({text=tempstr,sendToName=self.m_sendToName,avatarID = avatarID,data = self.m_tempData})
            if self.m_wordDay then 
                local item_count = game_data:getItemCountByCid(gift[1][2])
                if self.m_sendCount >= send_num then 
                    if item_count > 0 then  --消耗道具发言
                        require("shared.native_helper").sendRoomMsg(tempData)
                        self.m_editNode:setText("")
                        self.m_tempData = {};
                        self.m_wordDay = false
                        performWithDelay(self.m_node_inputchat_board,newrefresh,send_cd)
                        local function responseMethod(tag,gameData)
                            local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                            cclog2(data,"data")
                            item_count = game_data:getItemCountByCid(gift[1][2])
                            self.m_item_count:setString(tostring(item_count))
                            local time_log = data.time_log or {}
                            self.m_sendCount = #time_log
                            
                        end
                        local params = {
                            use_item = 1,
                        }
                    
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yunxin_send_log"), http_request_method.GET, params,"yunxin_send_log")
                    else 
                        game_util:addMoveTips({text = "Tần suất nói quá cao. Vui lòng sử dụng thuốc hoặc nói chuyện sau."});
                    end

                else 
                    require("shared.native_helper").sendRoomMsg(tempData)
                    self.m_editNode:setText("")
                    self.m_tempData = {};
                    self.m_wordDay = false
                    performWithDelay(self.m_node_inputchat_board,newrefresh,send_cd)

                    local function responseMethod(tag,gameData)
                        local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                        cclog2(data,"data")
                    
                        self.m_item_count:setString(tostring(item_count))
                        local time_log = data.time_log or {}
                        self.m_sendCount = #time_log
                        
                    end
                    local params = {
                        use_item = 0,
                    }
                
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yunxin_send_log"), http_request_method.GET, params,"yunxin_send_log")
                end
                
                
            else 
                game_util:addMoveTips({text = "Nói quá nhanh. Vui lòng chờ vài giây"});
            end
            
        end
        
    end


    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1001  then  -- 選擇頭像
            local endCallFun = function (  )
                self:refreshUi()
            end
            game_scene:addPop("ui_chat_showavatars_pop", {endCallFun = endCallFun})
        else
            self:setSelectTabBtn(btnTag - 200);
            self.m_share_btn_layer:setVisible(false);
        end
    end
    local function onBagCallBack( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        self.m_share_btn_layer:setVisible(false);
        cclog2(btnTag, "btnTag == ")
        local menu_key = self.m_menu_items[ btnTag ] and self.m_menu_items[ btnTag ].item
        cclog2(menu_key, "menu_key == ")
        if menu_key == "card" then
            -- 卡牌
            self:addSelHeroUi();
        elseif menu_key == "equip" then
            -- 装备
            self:addSelEquipUi();
        elseif menu_key == "item" then
            -- 道具
            self:addSelItemUi();
        elseif  menu_key == "share"  then
            -- 分享
            self:addSelBattleInfoUi();
        elseif  menu_key == "invite"  then
            -- 邀请
            self:sendTeamInvite();
        elseif  menu_key == "voice"  then
            --语音
            local function voiceStart(table)
                print("lua voiceStart -------------------------")
                local voiceResult = table.voiceResult
                CCLuaLog(voiceResult)
                self.m_editNode:setText(voiceResult);
            end
            require("shared.voice_helper").voiceStart(voiceStart)
        end
    end
    local function itemBtnPress(target,event)
        
        self.m_share_btn_layer:setVisible(not self.m_share_btn_layer:isVisible())
        
    end
    self.m_ccbNode:registerFunctionWithFuncName("closeBtnPress",onCancel);
    self.m_ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    self.m_ccbNode:registerFunctionWithFuncName("chatBtnPress",onOk);
    self.m_ccbNode:registerFunctionWithFuncName("onBagCallBack",onBagCallBack);
    self.m_ccbNode:registerFunctionWithFuncName("itemBtnPress",itemBtnPress);
    self.m_ccbNode:openCCBFile("ccb/ui_chat2.ccbi");

    self.m_node_chatother_board = self.m_ccbNode:nodeForName("m_node_chatother_board")
    self.m_node_chatother_board:setVisible(false)
    self.m_node_inputchat_board = self.m_ccbNode:nodeForName("m_node_inputchat_board")

    local tempEditNode = self.m_ccbNode:nodeForName("m_edit")
    self.m_scroll_view = self.m_ccbNode:scrollViewForName("m_scroll_view")
    self.m_scroll_fire = self.m_ccbNode:scrollViewForName("m_scroll_fire")
    self.m_closeBtn = self.m_ccbNode:controlButtonForName("m_closeBtn")
    self.m_closeBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
    self.m_chatBtnPress = self.m_ccbNode:controlButtonForName("m_chatBtnPress")
    self.m_chatBtnPress:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
    self.m_itemBtn = self.m_ccbNode:controlButtonForName("m_itemBtn")
    self.m_itemBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);

    self.m_sign_table = {}
    local sortType = self.m_chat_types
    tabPosY = tabPosYs["pos" .. tostring(#sortType)]
    local m_node_tabboar = self.m_ccbNode:nodeForName("m_node_tabboar")
    local node, tempBtn = nil, nil
    for i=1,10 do
        local node = self.m_ccbNode:nodeForName("m_node_chat_tag" .. (i))
        if node and tabPosY[i] == nil then 
            node:setVisible(false)
        elseif node then
            local falg = sortType[i].flag
            node:setPositionY(m_node_tabboar:getContentSize().height * tabPosY[i] * 0.01)
            tempBtn = self.m_ccbNode:controlButtonForName("m_tab_btn_" .. i)
            if tempBtn then 
                local title = typeTitles[falg]
                local m_tab_label = self.m_ccbNode:labelTTFForName("m_tab_label_" .. i)
                if m_tab_label then m_tab_label:setString(tostring(title)) end
                tempBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5)
                self.m_sign_table[falg] = game_util:addTipsAnimByType(tempBtn ,9);
                if #sortType == 4 then
                    tempBtn:setPreferredSize(CCSizeMake(45, 48))
                end
                local tempSize = tempBtn:getContentSize()
                if self.m_sign_table[falg] then 
                    self.m_sign_table[falg]:setVisible(false) 
                    self.m_sign_table[falg]:setPosition( tempSize.width*0.2, tempSize.height*0.6)
                end
            end

        end
    end

    -- 切换头像
    local m_conbtn_selectavatar = self.m_ccbNode:controlButtonForName("m_conbtn_selectavatar")
    m_conbtn_selectavatar:setOpacity(0)
    m_conbtn_selectavatar:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);

    -- 输入选项按钮， 卡牌， 装备  道具 .... 
    local voice_btn = nil
    local menu_items = self.m_menu_items

    local posy = 17
    for i=1,10 do
        local node = self.m_ccbNode:controlButtonForName("m_conbtn_item" .. (i))
        if node and menu_items[i] and i ~= 4 then
            node:setVisible(true)
            node:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
            node:setPositionY(posy)
            posy = posy + 40
            game_util:setCCControlButtonTitle(node, tostring( menuTitles[ menu_items[i].item ] ) )
        elseif node then
            node:setVisible(false)
        end
    end

    self.m_share_btn_layer = self.m_ccbNode:layerForName("m_share_btn_layer")
    self.m_frechat_layer = self.m_ccbNode:layerForName("m_frechat_layer")
    self.m_share_btn_layer:setVisible(false);
    self.m_scroll_view:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
    self.m_scroll_fire:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
    self.m_list_view_bg = self.m_ccbNode:layerForName("m_list_view_bg")
    self.m_list_view_bg_friend = self.m_ccbNode:layerForName("m_list_view_bg_friend")
    self.m_list_view_fire = self.m_ccbNode:layerForName("m_list_view_fire")
    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
        end
    end
    tempEditNode:removeAllChildrenWithCleanup(true);
    self.m_editNode = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = tempEditNode:getContentSize(),placeHolder="Nhấp vào đây để nhập",maxLength = 36});
    self.m_editNode:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
    self.m_editNode:setOpacity(0)
    tempEditNode:addChild(self.m_editNode);

    self.m_editNodeBoard = tempEditNode

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            --self.m_share_btn_layer:setVisible(false);
            return true;--intercept event
        end
    end
    self.m_root_layer = self.m_ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 4,true);
    self.m_root_layer:setTouchEnabled(true);

    local queryRoomMsg = function(text)
        --self.m_showDataTab = util.table_copy(text)
        local data = json.decode(text["data"])
        for k,v in pairs(data) do
            if v.content and v.ext then
                v.ext = json.decode(v.ext)
                v.content = json.decode(v.content)
                table.insert(self.m_showDataTab,v)
            end
            
        end
        table.sort(self.m_showDataTab, function(a, b)
            return a.time < b.time
        end)
        cclog2(self.m_showDataTab,"收到世界历史聊天消息")
        
        self:setShowLabelContent()
    end

    local chatRoomObserver = function(text)
        local data = json.decode(text)
        if data.notification then 
            self.m_showDataTab = {}
            require("shared.native_helper").queryRoomMsg({},queryRoomMsg)
        else
            data.ext = json.decode(data.ext)
            data.content = json.decode(data.content)
            cclog2(data,"收到聊天消息room")
            if data.ext and data.content then 
                table.insert(self.m_showDataTab, data)
                self:setShowLabelContent()
            end
        end
        
        
    end
    require("shared.native_helper").listenBroadCast("chatRoomObserver",chatRoomObserver)

    local chatObserver = function(text)
        local data = json.decode(text)
        cclog2(data,"收到聊天消息")
        data.ext = json.decode(data.ext)
        data.content = json.decode(data.content)
        table.insert(self.m_showDataTab, data)
        self:setShowLabelContent()
    end

    local incomingMessageObserver = function(text)
        local par = json.decode(text)
        local data = json.decode(par["data"])
        local type = 0;
        for k,v in pairs(data) do
            v.ext = json.decode(v.ext)
            
            v.content = json.decode(v.content)
            type = v.type
            if v.type == 2 then  --联盟
                table.insert(self.m_showGuildData, v)
            else
                v.kqgFlag = "friend"
                table.insert(self.m_showFriendData,v)
            end
            
        end
        if type == 2 then 
            table.sort(self.m_showGuildData, function(a, b)
                return a.time < b.time
            end)
            cclog2(self.m_showGuildData,"收到联盟消息")
        else
            table.sort(self.m_showFriendData, function(a, b)
                return a.time < b.time
            end)
        
            cclog2(self.m_showFriendData,"收到好友消息")
        end
        
        self:setShowLabelContent()
    end

    local chatSendMsg = function(text)
        local data = json.decode(text)
        if data.type == 2 then 
            if data.content and data.ext then 
                data.content = json.decode(data.content)
                data.ext = json.decode(data.ext)
                table.insert(self.m_showGuildData, data)
            end
            
        else
            if data.content and data.ext then 
                data.ext = json.decode(data.ext)
                data.kqgFlag = "friend"
                data.content = json.decode(data.content)
                table.insert(self.m_showFriendData, data)
            end
        end
        
        self:setShowLabelContent()
    end

    local enterChatRoom = function(text)
        cclog2(text,"收到聊天室登录成功消息")
        if text["result"] then
            require("game_ui.game_loading").close();
            require("shared.native_helper").queryRoomMsg({},queryRoomMsg)
        else
            game_util:addMoveTips({text = "Đăng nhập trò chuyện thế giới không thành công"});
        end
    end
    cclog2(gift[1][2],"--gift")
    local node_item = self.m_ccbNode:nodeForName("node_item")
    local item = getConfig(game_config_field.item);
    local itemCfg = item:getNodeWithKey(tostring(gift[1][2]));
    cclog2(itemCfg,"itemCfg")
    local icon_str = itemCfg:getNodeWithKey("icon"):toStr()
    cclog2(icon_str,"--cion")
    local icon = game_util:createIconByName(icon_str)
    if icon then 
        icon:setPosition(ccp(0,10))
        node_item:addChild(icon)
    end
    local item_count = game_data:getItemCountByCid(gift[1][2])
    self.m_item_count = game_util:createLabelTTF({text = item_count,color = ccc3(255,255,255),fontSize = 12});
    self.m_item_count:setPosition(ccp(15,0))
    node_item:addChild(self.m_item_count)

    require("shared.native_helper").listenBroadCast("chatObserver",chatObserver) --世界的消息
    require("shared.native_helper").listenBroadCast("chatSendMsg",chatSendMsg)  --收到联盟 或者 好友消息
    require("shared.native_helper").listenBroadCast("incomingMessageObserver",incomingMessageObserver)  --离线消息

    require("shared.native_helper").enterChatRoom({},enterChatRoom)

    local function responseMethod(tag,gameData)
        local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
        cclog2(data,"data")
        local time_log = data.time_log or {}
        self.m_sendCount = #time_log
        
    end
    local params = {
        use_item = 0,
    }
    
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yunxin_user_limit"), http_request_method.GET, params,"yunxin_user_limit")

    self:setSelectTabBtn(1)
    
    return self.m_ccbNode;
end

function ui_chat_new_pop.refreshUi(self)
    self.m_node_myicon = self.m_ccbNode:nodeForName("m_node_myicon")
    local vip = game_data:getUserStatusDataByKey("vip") or 0
    local role = game_data:getUserStatusDataByKey("role") or 1

    local avatarID = game_data:updateLocalData("avatar_id")
    if avatarID == "" then
        local role = game_data:getUserStatusDataByKey("role")
        game_data:updateLocalData("avatar_id", tostring(role), true)
        avatarID = game_data:updateLocalData("avatar_id")
    end
    
    local avatar = self:createPlayerAvatar( avatarID, vip, self.m_node_myicon:getContentSize())
    avatar:setScale(0.8)
    avatar:setPosition(self.m_node_myicon:getContentSize().width * 0.5, self.m_node_myicon:getContentSize().height * 0.5)
    if avatar then
        self.m_node_myicon:addChild(avatar)
    end
end

function ui_chat_new_pop.createTableViewFire(self,viewSize)
    local showData = self.friend_list

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag  ===  ", btnTag)
        
    end

    local itemCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 6;--行
    params.column = 1; --列
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    --params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    self.m_oneChatCellSize = itemSize
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()

            local ccbNode = luaCCBNode:create()
            ccbNode:registerFunctionWithFuncName("onBtnCilck",onBtnCilck);
            ccbNode:openCCBFile("ccb/ui_chat_item_fire.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(itemSize.width*0.5, itemSize.height*0.5)
            cell:addChild(ccbNode, 10, 10)

            local m_conbtn_otherevent = ccbNode:controlButtonForName("m_conbtn_otherevent")
            if m_conbtn_otherevent then
                --m_conbtn_otherevent:setOpacity(200)
                m_conbtn_otherevent:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
            end

        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10), "luaCCBNode")
            local m_label_name = ccbNode:labelTTFForName("m_label_name")
            m_label_name:setString(tostring(showData[index+1]["name"]))
        end

        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        
        if eventType == "ended" and cell then
            cclog(index)
            self.m_share_btn_layer:setVisible(false);
            self.m_sendToAccid = showData[index+1]["accid"]
            self.m_sendToName = showData[index+1]["name"]
            self:setSelectTabBtn(3, showData[index+1]["uid"], showData[index+1]["name"])
        end
    end
    return TableViewHelper:create(params);
end

function ui_chat_new_pop.createTableView(self,viewSize)
    local showData = self.m_showDataTab
    if self.m_curFlag == "friend" then 
        showData = self.m_showFriendData
    elseif self.m_curFlag == "guild" then  --工会
        showData = self.m_showGuildData
    end
    local function menuItemClickFun(richLabel,menuItemTag)
        local tag = richLabel:getTag();
       cclog2("btnTag11  ===  ", tag)

       local tempData = showData[tag + 1]["content"]["data"]
        -- local clickTab = itemData.clickTab;
        -- local posIndex = menuItemTag - 524288 + 1;
        -- local tempData = clickTab[posIndex];
        if tempData then
            cclog("tempData.typeName == " .. tempData.typeName)
            if tempData.typeName == "card" then
                game_scene:addPop("game_hero_info_pop",{tGameData = tempData.data,openType = 3 , callBack = function ( ) cclog("Trở lại Chat")end})
            elseif tempData.typeName == "equip" then
                game_scene:addPop("game_equip_info_pop",{tGameData = tempData.data});
            end
        end
    end

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
        local playerInfo = showData[btnTag + 1]
        cclog2("btnTag  ===  ", btnTag)
        if playerInfo then
            local uid = self:splitString(playerInfo.account)
            cclog2(uid,"查询uid信息")
            local backChatFun = function ( other_uid, other_name )
                local tag = self:getTabIdByFlag("friend", true) 
                if tag then
                    local function responseMethod(tag2,gameData)
                        self.m_sendToAccid = gameData:getNodeWithKey("data"):getNodeWithKey("accid"):toStr()
                        self.m_sendToName = other_name
                        self:setSelectTabBtn(tag, other_uid, other_name)
                    end
                    local params = {};
                    params.t_uid = uid;
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yunxin_get_accid"), http_request_method.GET, params,"yunxin_get_accid")
                    
                end
            end
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_chat_playerinfo_pop",{gameData = gameData, backChatFun = backChatFun, playerInfo = playerInfo})
            end
            local params = {};
            params.uid = uid;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, params,"user_info")
        end
    end


    local function onBagCallBack( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local tempData = showData[btnTag + 1]["content"]["data"]
        
    end

   
    local itemCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    self.m_oneChatCellSize = itemSize
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()

            local ccbNode = luaCCBNode:create()
            ccbNode:registerFunctionWithFuncName("onBagCallBack",onBagCallBack);
            if self.m_curFlag == "friend" then 
                ccbNode:openCCBFile("ccb/ui_chat_item2_friend.ccbi");
            else
                ccbNode:openCCBFile("ccb/ui_chat_item2.ccbi");
            end
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(itemSize.width*0.5, itemSize.height*0.5)
            cell:addChild(ccbNode, 10, 10)



            local m_conbtn_otherevent = ccbNode:controlButtonForName("m_conbtn_otherevent")
            if m_conbtn_otherevent then
                m_conbtn_otherevent:setOpacity(200)
                m_conbtn_otherevent:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
            end

        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10), "luaCCBNode")
            self:initChatCellInfo(ccbNode, index, showData , onBtnCilck , menuItemClickFun)
        end

        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        --cclog(index)
        -- if self.m_sign_table[ self.m_curFlag ] then self.m_sign_table[ self.m_curFlag ]:setVisible(false) end
        -- if eventType == "ended" then
        --     local itemData = showData[index + 1] or {}
        --     -- cclog2(itemData, "itemData ======")

        --     if itemData.msg_type == "top" then

        --         self.m_chatObserver:requestHistoryChatLog( self.m_curFlag )
        --         self:refreshChatMsgView( false )

         
        --     end
        -- end
    end
    return TableViewHelper:create(params);
end

function ui_chat_new_pop.splitString(self,str)
    local start = 1
    local count = 0

    while true do
        local found = string.find(str, "_", start)
        if found then
            count = count + 1
            if count == 2 then
                local secondPart = string.sub(str, found + 1)
                return secondPart
            end
            start = found + 1
        else
            break
        end
    end
    return nil
end


function ui_chat_new_pop.initChatCellInfo( self, ccbNode, cellIndex , showData, btnCallFun , menuItemClickFun)
    showData = showData or {}

    if not ccbNode then return end
    ccbNode:setPositionY(ccbNode:getContentSize().height * 0.5)

    local itemData = showData[cellIndex + 1] or {}
    cclog2(itemData, "itemData ======   ")
    local m_scale9_linebottom = ccbNode:nodeForName("m_scale9_linebottom")
    local m_scale9_linetop = ccbNode:nodeForName("m_scale9_linetop")

    local m_label_date = ccbNode:labelTTFForName("m_label_date")
    if itemData.date and m_label_date then
        m_label_date:setVisible(true)
        m_label_date:setString(tostring(itemData.date))
    elseif m_label_date then
        m_label_date:setVisible(false)
    end 


    print(ccbNode:getPosition())
    -- cclog2("position     ============")
    local showMsg = ""
    if type(itemData["content"]) == "table" then 
        showMsg = itemData["content"]["text"]
    else 
        showMsg =  itemData.content
    end 

     
    local vipLevel = itemData.ext.vip or 0
    -- if itemData.inviteFlag == true and m_msg_back_board3 then
    --     local uid = game_data:getUserStatusDataByKey("uid") or ""
    --     if tostring(itemData.uid) ~= tostring(uid) then
    --         m_msg_back_board3:setVisible(true)
    --     end
    -- end

    local m_node_avatarboard = ccbNode:nodeForName("m_node_avatarboard")
    local m_sprite_vipsign = ccbNode:spriteForName("m_sprite_vipsign")
    local m_node_msgboard = ccbNode:nodeForName("m_node_msgboard")
    local m_sprite_vipsignBottom = ccbNode:spriteForName("m_sprite_vipsignBottom")

    if itemData.kqgFlag == "friend" then
        showMsg = itemData.content and (itemData.content.text or "") or "~~~~~~~~~";
        for i=1,2 do
            local label = ccbNode:labelTTFForName("m_label_othername_" .. i)
            local name = itemData.content.sendToName or ""
            local uid = self:splitString(itemData.account)
            if uid == tostring( game_data:getUserStatusDataByKey("uid") ) then
               -- name = "Tôi"
            end
            local msg = name ~= "" and "nói với " .. name or ""
            if label then
                label:setString(msg or "")
            end
        end
    end
    cclog2(showMsg,"showMsg")

    -- 时间
    local labelTime = ccbNode:labelTTFForName("m_label_time")
    local time = itemData.time and os.date("%H:%M", math.floor(tonumber(itemData.time)/1000)) or ""
    labelTime:setString(time)
    -- 人物等级
    for i=1,2 do
        local label = ccbNode:labelTTFForName("m_label_level_" .. i)
        if label then 
            label:setString(itemData.ext.level  or "?")
        end
    end
    -- 昵称
    for i=1,2 do
        local label = ccbNode:labelTTFForName("m_label_name_" .. i)
        if label then 
            label:setString(itemData.ext.name  or "")
            label:setColor(ccc3(0,255,0))
        end
    end


    m_node_msgboard:removeAllChildrenWithCleanup(true)
    if m_node_avatarboard:getChildByTag(998) then
        m_node_avatarboard:removeChildByTag(998,true)
    end 
  

    local tempData = type(itemData["content"]) == "table" and itemData["content"]["data"] or nil
    if tempData then 
        if tempData.typeName == "card" then
            local tempMsg = "([link bg=ff000000 bg_click=9f00ff00]" .. showMsg .. "[/link])";
            showMsg = tempMsg;
        elseif tempData.typeName == "equip" then
            local tempMsg = "([link bg=ff000000 bg_click=9f00ff00]" .. showMsg .. "[/link])";
            showMsg = tempMsg;
           
        end
    end
    
    local size = m_node_msgboard:getContentSize()
    local chatMsgLabel = game_util:createRichLabelTTF({text = showMsg or "",dimensions = CCSizeMake(size.width,20),
        textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentTop,color = ccc3(221,221,192),fontSize = 10})
    chatMsgLabel:setLinkPriority(GLOBAL_TOUCH_PRIORITY - 7)
    chatMsgLabel:setAnchorPoint(ccp(0, 0.5));
    chatMsgLabel:setPositionY(size.height * 0.5)
    chatMsgLabel:registerScriptTapHandler(menuItemClickFun);
    m_node_msgboard:addChild(chatMsgLabel,0, cellIndex)

    -- local params = {}
    
    -- params.btnImgName="public_enniu.png";
    -- params.btnImgNameSel="public_neiniu_1.png";
    -- params.text=tostring(showMsg)
    -- params.callFunc = menuItemClickFun;
    -- params.touchPriority = GLOBAL_TOUCH_PRIORITY-6
    -- local btnTemp = game_util:createCCControlButtonByTable(params);
    -- btnTemp:setPreferredSize(CCSizeMake(size.width, size.height));
    -- btnTemp:setAnchorPoint(ccp(0, 0.5));
    -- btnTemp:setPositionY(size.height * 0.5);
    -- m_node_msgboard:addChild(btnTemp)

    -- 设置vip标志
    if game_data:isViewOpenByID(101) and vipLevel > 0 then
        m_sprite_vipsign:setVisible(true)
        m_sprite_vipsignBottom:setVisible(true)
    else 
        m_sprite_vipsign:setVisible(false)
        m_sprite_vipsignBottom:setVisible(false)
    end

    local avatarID = 1;
    if type(itemData["content"]) == "table" then 
        avatarID = itemData["content"]["avatarID"]
    end 

    local asize = m_node_avatarboard:getContentSize()
    local avatar = self:createPlayerAvatar(avatarID, itemData.ext.vip, asize)
    if avatar then
        avatar:setPosition(asize.width * 0.5, asize.height * 0.5)
        m_node_avatarboard:addChild(avatar, -1, 998)
        self:createAMainButton( avatar, btnCallFun, "public_weapon.png", cellIndex)
        avatar:setScale(0.7)
    end    


    local m_conbtn_otherevent = ccbNode:controlButtonForName("m_conbtn_otherevent")
    if m_conbtn_otherevent then
        m_conbtn_otherevent:setVisible(false)
        m_conbtn_otherevent:setTag( cellIndex  )
    end

end

--[[--
    创建一个button
]]
function ui_chat_new_pop.createAMainButton( self, parent, onBtnCilck, spriteName, tag )
    local button = game_util:createCCControlButton(spriteName,"",onBtnCilck)
    button:setAnchorPoint(ccp(0.5,0.5))
    button:setPositionY(parent:getContentSize().height * 0.5)
    button:setPositionX(parent:getContentSize().width * 0.5)
    parent:addChild(button)
    button:setTag(tag)
    button:setOpacity(0)
    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
    return button
end

--[[
    获取 falg相应的按钮id
]]
function ui_chat_new_pop.getTabIdByFlag( self, keyFlag, showTips )
    if keyFlag then 
        for k,v in pairs( self.m_chat_types  ) do
            if type(v) == "table" and v.flag == keyFlag then
                return k
            end
        end
    end
    if showTips then
        game_util:addMoveTips({text = "Không thể tán gẫu ở trang này"})
    end
    return nil
end

function ui_chat_new_pop.createPlayerAvatar( self, avatarID, vipLevel, avatarSize )

    local face_cfg = getConfig(game_config_field.face_icon)
    local avatarName  = "icon_ironman.png"
    if face_cfg then
        local avatarInfo =  face_cfg:getNodeWithKey( tostring(avatarID) )
        avatarName = avatarInfo and avatarInfo:getNodeWithKey("icon") and avatarInfo:getNodeWithKey("icon"):toStr() 
    end

    local avatar = game_util:createIconByName(avatarName or "icon_ironman.png")
    local asize = avatarSize 
    if avatar then
        local qualityTab = HERO_QUALITY_COLOR_TABLE[4]
        if vipLevel and vipLevel > 0 then
            qualityTab = HERO_QUALITY_COLOR_TABLE[7]
        end 
        local tempIconSize = avatar:getContentSize();
        local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
        img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
        avatar:addChild(img1,-1,1)
        local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
        img2:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
        avatar:addChild(img2,1,2)
    end    
    return avatar
end

--[[
    -- 非私聊
]]
function ui_chat_new_pop.willChatWithOthers( self )
    local size = self.m_node_inputchat_board:getContentSize()
    -- self.m_node_inputchat_board:setPositionY(size.height * 0.5)
    -- self.m_editNodeBoard:setPositionY(size.height * 0.5)
    self.m_node_chatother_board:setVisible(false)
end

function ui_chat_new_pop.setSelectTabBtn(self,sortIndex, uid, name)
    self.m_sort_id = sortIndex
    -- cclog2(sortIndex, "sortIndex  ======   ")
    local sortType = self.m_chat_types[sortIndex]
    -- cclog2(sortType, "setSelectTabBtn   +   sortType  ++++++  ")
    if not sortType then return end
    local sortT = sortType["sort"]
    local flag = sortType["flag"]
    local canChat = true

    if sortT == 1 then
        if #self.m_showDataTab == 0 then

        end

        self.m_frechat_layer:setVisible(false)
        cclog("-------------------onWorldCallBack");
        self:willChatWithOthers()
    elseif sortT == 2 then
        cclog("-------------------onGuildCallBack");

        local association_id = game_data:getUserStatusDataByKey("association_id");
        if association_id == 0 then--無聯盟
            game_util:addMoveTips({text = "Bạn chưa vào liên minh!"});
            return
        end
        self.m_node_chatother_board:setVisible(false)
        self.m_frechat_layer:setVisible(false)

        if self.teamID == nil then 
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                self.teamID = data.tid
                cclog2(data,"userinfo")
                self.m_showGuildData = {}
                local queryTeamMsg = function(text)
                    --self.m_showDataTab = util.table_copy(text)
                    local data = json.decode(text["data"])
                    for k,v in pairs(data) do
                        cclog2(k,"self.m_showGuildData")
                        v.ext = json.decode(v.ext)
                        v.content = json.decode(v.content)
                        table.insert(self.m_showGuildData,v)
                    end
                    table.sort(self.m_showGuildData, function(a, b)
                        return a.time < b.time
                    end)
                    cclog2(self.m_showGuildData,"收到历史聊天消息guild")
                    
                    self:setShowLabelContent()
                end
                require("shared.native_helper").queryTeamMsg({teamID=self.teamID,type=2},queryTeamMsg)
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yunxin_get_team"), http_request_method.GET, nil,"yunxin_get_team")
        end
        if self.m_showGuildData == nil then

        end
    elseif sortT == 3 then
        -- body
        cclog("-------------------onFriendCallBack");
        self.m_frechat_layer:setVisible(true)
        if self.friend_list == nil then 
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                self.friend_list = {}
                self.friend_list = data.accids
                cclog2(self.friend_list,"data")
                self.m_list_view_fire:removeAllChildrenWithCleanup(true);
                self.m_tableView = nil
                self.m_tableView = self:createTableViewFire(self.m_list_view_fire:getContentSize());
                self.m_list_view_fire:addChild(self.m_tableView, 1, 997);
            end
        
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("yunxin_friend_list"), http_request_method.GET, {},"yunxin_friend_list")
        end
        if not uid or not name then
           -- game_util:addMoveTips({text = "Xin chọn một đối tượng Chat riêng!"});
        else
            self.m_showFriendData = {}
            local queryMsg = function(text)
                local data = json.decode(text["data"])
                for k,v in pairs(data) do
                    v.ext = json.decode(v.ext)
                    v.kqgFlag = "friend"
                    v.content = json.decode(v.content)
                    table.insert(self.m_showFriendData,v)
                end
                table.sort(self.m_showFriendData, function(a, b)
                    return a.time < b.time
                end)
                cclog2(self.m_showFriendData,"收到历史聊天消息haoyou")
                
                self:setShowLabelContent()
            end
            require("shared.native_helper").queryMsg({accid=self.m_sendToAccid,type=0},queryMsg)
            
            self:willChatWithOtherOne( uid, name)
        end

        
    end
    -- cclog2(self.m_curFlag, "self.m_curFlag ======  ")

    self.m_curFlag = flag;

    if self.m_sign_table[flag] then self.m_sign_table[flag]:setVisible(false) end

    self:refreshTabBtn(sortIndex)
    self:setShowLabelContent();

end

--[[
    -- 私聊
]]
function ui_chat_new_pop.willChatWithOtherOne( self, uid, name )
     cclog2(uid, "uid  ===  ")
    cclog2(uid, "name  ===  ")
    self.m_chatOtherInfo = {uid = uid, name = name}
    self.m_curFlag = "friend"
    local size = self.m_node_inputchat_board:getContentSize()
    local lastY = self.m_node_inputchat_board:getPositionY()
    -- self.m_node_inputchat_board:setPositionY(size.height * 0.4)
    -- self.m_editNodeBoard:setPositionY(size.height * 0.5)
    self.m_node_chatother_board:setVisible(true)

    -- if tostring(uid) == tostring( game_data:getUserStatusDataByKey("uid") ) then
    --     name = "我"
    -- end
    local msg = "nói với " .. (name or "   ")
    for i=1,2 do
        local labelName = self.m_ccbNode:labelTTFForName("m_label_chatother_" .. i)
        if labelName then
            labelName:setString(msg or "")
        end
    end
end

function ui_chat_new_pop.refreshTabBtn(self,sortIndex)
    local tempBtn = nil;
    self.m_last_msgNumbers = {}
    for i=1,4 do
        tempBtn = self.m_ccbNode:controlButtonForName("m_tab_btn_" .. i)
        tempBtn:setHighlighted(sortIndex == i);
        tempBtn:setEnabled(sortIndex ~= i);
    end
end

--[[--
    卡牌背包
]]
function ui_chat_new_pop.addSelHeroUi(self)
    if self.m_tempData.typeName then
        game_util:addMoveTips({text = "Một tin nhắn chỉ có thể hiển thị một chi tiết dữ liệu"});
        return;
    end
    local btnCallFunc = function( target,event )
        
    end
    local itemOnClick = function (id)
        if id then
            local cardData,cardCfg = game_data:getCardDataById(id);
            local cardId = cardData.id;
            local name = cardCfg:getNodeWithKey("name"):toStr();
            if #self.m_tempData > 0 then return end
            local str = self.m_editNode:getText();
            str = str .. '&' .. name .. '&'
            local tempLen = self:utf8_length(str);
            cclog("tempLen == " .. tempLen .. " ; string.len(str) = " .. string.len(str))
            if tempLen > 30 then
                game_util:addMoveTips({text = "Độ dài kí tự vượt giới hạn!"});
                return;
            end
            self.m_tempData = {typeName = "card",data = cardData};
            self.m_editNode:setText(str);
        end
    end
    game_scene:addPop("game_hero_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick})
end

function ui_chat_new_pop.utf8_length(self,str)
    local len = 0
    local pos = 1
    local length = string.len(str)
    while true do
        local char = string.sub(str, pos, pos)
        local b = string.byte(char)
        if b >= 128 then
            pos = pos + 3
        else pos = pos + 1
        end len = len + 1
        if pos > length
        then break
        end
    end
    return len
end

--[[--
    装备背包
]]
function ui_chat_new_pop.addSelEquipUi(self)
    if self.m_tempData.typeName then
        game_util:addMoveTips({text = "Một tin nhắn chỉ có thể hiển thị một chi tiết dữ liệu"});
        return;
    end
    local btnCallFunc = function( target,event )

    end
    local itemOnClick = function (id)
        if id then
            local equipData,equipCfg = game_data:getEquipDataById(id);
            local name = equipCfg:getNodeWithKey("name"):toStr();
            if #self.m_tempData>0 then return end
            local str = self.m_editNode:getText();
            str = str .. '&' .. name .. '&'
            local tempLen = self:utf8_length(str);
            cclog("tempLen == " .. tempLen .. " ; string.len(str) = " .. string.len(str))
            if tempLen > 30 then
                game_util:addMoveTips({text = "Độ dài kí tự vượt giới hạn!"});
                return;
            end
            self.m_tempData = {typeName = "equip",data = equipData};
            self.m_editNode:setText(str);
        end
    end
    game_scene:addPop("game_equip_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,sortBtnShow = true})
end

--[[--
    道具背包
]]
function ui_chat_new_pop.addSelItemUi(self)
    local btnCallFunc = function( target,event )

    end
    local itemOnClick = function (id)
        if id then

        end
    end
    game_scene:addPop("game_item_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick})
end

--[[--
    选择战报
]]
function ui_chat_new_pop.addSelBattleInfoUi(self)

        local function responseMethod(tag,gameData)
            -- game_scene:enterGameUi("game_arena",{pk_flag = "pk",gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())});
            local tdata = gameData and json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {}
            game_scene:addPop("ui_batter_info_pop",{log_info = tdata.log,openType = 1, isShowShareBtn = "true"});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_index"), http_request_method.GET, {},"arena_index");
end

function ui_chat_new_pop.updatMsg(self)

    --table.insert(self.m_showDataTab, {content="123nihao "})
    
end

function ui_chat_new_pop.setShowLabelContent(self)
    
    self:updatMsg()
    self:refreshChatMsgView( byNewChat );
end

function ui_chat_new_pop.refreshChatMsgView(self)
    local count = 0
    if self.m_sort_id == 1 then 
        count = #self.m_showDataTab
    elseif self.m_sort_id == 2 then 
        count = #self.m_showGuildData
    else
        count = #self.m_showFriendData
    end
    local offsetBlowY = self.m_tableView and self.m_tableView:getContentOffset().y or 0
    -- local index = self:getCurMsgIndex()
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_list_view_bg_friend:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil
    if self.m_curFlag == "friend" then 
        self.m_tableView = self:createTableView(self.m_list_view_bg_friend:getContentSize());
        self.m_list_view_bg_friend:addChild(self.m_tableView, 1, 997);
    else
        self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
        self.m_list_view_bg:addChild(self.m_tableView, 1, 997);
    end
    
    cclog2(offsetBlowY, "offsetBlowY  ======   ")
    cclog2(self.m_offset_number, "self.m_offset_number   =====   ")
    -- cclog2(index, " cur msg  index  ======   ")

    if offsetBlowY > -3 * self.m_oneChatCellSize.height then
        if self.m_curFlag == "friend" then 
            game_util:setTableViewIndex( count ,self.m_list_view_bg_friend, 997, 4)
        else
            game_util:setTableViewIndex( count ,self.m_list_view_bg, 997, 4)
        end
        
    elseif self.m_offset_number and self.m_offset_number > 0 then
        local offsetBlowY = offsetBlowY - self.m_oneChatCellSize.height * self.m_offset_number
        self.m_tableView:setContentOffset(ccp(0, offsetBlowY))
        if self.m_sign_table[ self.m_curFlag ] then self.m_sign_table[ self.m_curFlag ]:setVisible(true) end
        self.m_refreshUI = true
    else
        if self.m_curFlag == "friend" then 
            game_util:setTableViewIndex( count ,self.m_list_view_bg_friend, 997, 4)
        else
            game_util:setTableViewIndex( count ,self.m_list_view_bg, 997, 4)
        end
    end
    self.m_oneChatCellSize.height = 0 
    local offsetBlowY = self.m_tableView and self.m_tableView:getContentOffset().y or 0
    -- offsetBlowY = math.min(offsetBlowY, self.m_list_view_bg:getContentSize().height - self.m_tableView:getViewSize().height)
    offsetBlowY = math.max(offsetBlowY, -1 * self.m_tableView:getViewSize().height)
    self.m_tableView:setContentOffset(ccp(0, offsetBlowY))
end

function ui_chat_new_pop.init(self,t_params)
    t_params = t_params or {}; 
    self.m_editUserChanged = false;
    self.m_ownUID = game_data:getUserStatusDataByKey("uid");
    self.m_msg = {};
    self.m_maxMsg = 16;
    self.m_curMsg = 1;
    self.m_sendCount = 0;
    self.m_conectOk = false;
    self.m_tempData = {};
    self.m_cur_chat_table = {}
    self.m_history_table = {}
    self.m_showDataTab = {}
    self.m_wordDay = true;

    self.m_openType = t_params.openType or 1;
    self.enterType = t_params.enterType or 1
    self.m_last_msgNumbers = {}

    self.m_comeInChatFriendInfo = {uid = t_params.friendUID , name = t_params.friendName }

    self.m_sendToAccid = ""
    self.m_sendToName = ""

    -- self.m_openType = 6
    self.m_chat_types = tttype[ "type" .. tostring(self.enterType) ] or {}
    self.m_menu_items = util.table_copy( menuType[ "type" .. tostring(self.enterType) ] ) or {}
    -- for k,v in pairs(self.m_menu_items) do
    --     if type(v) == "table" and  v.item == "voice" and not EXTHelper then
    --         table.remove(self.m_menu_items, k)
    --         break
    --     end
    -- end
end

function ui_chat_new_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end



return ui_chat_new_pop;