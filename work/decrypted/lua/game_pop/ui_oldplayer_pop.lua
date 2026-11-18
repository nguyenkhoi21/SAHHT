---  老玩家回归

local ui_oldplayer_pop = {
    m_root_layer = nil,
    m_btn_tab = nil,
    content = nil,
    m_index = nil,
    m_tGameData = nil,
    m_node_contentboard = nil,
    first_flag = nil,
    is_king = nil,
    is_caller = nil,
    recall_seven_tabel = nil,
    received_reward_dayNum = nil,
    now_days = nil,
    reward_node = nil,
    receive_btn = nil,
    login_reward_avail = nil,
    recall_package_avail = nil,
    sliced_coin_dict = nil,
    history_coin = nil,
    now_days_coin = nil,
    friend_commission_avail = nil,
    caller = nil,
    task_num = nil,
    guang_guang = nil,
    current_version = nil,
    btn_list_bg = nil,
    m_chargeTableView = nil,
    pX = nil,
    pY = nil,
};
--[[--
    销毁ui
]]
function ui_oldplayer_pop.destroy(self)
    -- body
    self.m_root_layer = nil;
    self.m_btn_tab = nil;
    self.content = nil;
    self.m_index = nil;
    self.m_tGameData = nil;
    self.m_node_contentboard = nil;
    self.first_flag = nil;
    self.is_king = nil;
    self.is_caller = nil;
    self.recall_seven_tabel = nil;
    self.received_reward_dayNum = nil;
    self.now_days = nil;
    self.reward_node = nil;
    self.receive_btn = nil;
    self.login_reward_avail = nil;
    self.recall_package_avail = nil;
    self.sliced_coin_dict = nil;
    self.history_coin = nil;
    self.now_days_coin = nil;
    self.friend_commission_avail = nil;
    self.caller = nil;
    self.task_num = nil;
    self.guang_guang = nil;
    self.current_version = nil;
    self.btn_list_bg = nil;
    self.m_chargeTableView = nil;
    self.pX = nil;
    self.pY = nil;
end
--[[--
    返回
]]
function ui_oldplayer_pop.back(self,backType)
    
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
	self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function ui_oldplayer_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        
        if self.m_chargeTableView then
            self.pX,self.pY = self.m_chargeTableView:getContainer():getPosition();
        end
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 10 then
            self:back()
        elseif btnTag == 11 then--每日登陆奖励
            self.m_index = 11
            self:refreshUi()
            local viewSize = self.content:getContentSize()
            self:refreshDailyGiftTableView(viewSize)
            self.m_chargeTableView = nil;
        elseif btnTag == 12 then -- 每日领取奖励
            
            local viewSize = self.content:getContentSize()
            if self.current_version == 0 then
                 game_util:addMoveTips({text = "Sau khi quá hạn event, tính năng sẽ đóng!"})
            else  
                self.m_index = 12
                self:refreshUi()
                self:refreshGiftTableView(viewSize)
                self.m_chargeTableView = nil;

            end

        elseif btnTag == 13 then--回归大礼包
            
            local viewSize = self.content:getContentSize()
            if self.current_version == 0 then
                 game_util:addMoveTips({text = "Sau khi quá hạn event, tính năng sẽ đóng!"})
            else  
                self.m_index = 13
                self:refreshUi()
                self:refreshCBGView(viewSize)
                self.m_chargeTableView = nil;

                
            end
            
        elseif btnTag == 14 then--回归任务
           
            if self.current_version == 0 then
                 game_util:addMoveTips({text = "Sau khi quá hạn event, tính năng sẽ đóng!"})
            else  
                self.m_index = 14
                self:refreshUi()
                self:refreshQRRWGiftTableView(self.content:getContentSize())
                self.m_chargeTableView = nil;
                
            end
            
        elseif btnTag == 15 then--七日返利
            -- cclog2(self.history_coin,"self.history_coin ")
            
            if self.history_coin == 0 then
                game_util:addMoveTips({text = "Bạn không có lịch sử giao dịch, không thể nhận thưởng!"});
            elseif next(self.sliced_coin_dict) == nil then 
                game_util:addMoveTips({text = "Hãy nạp thẻ để kích hoạt tính năng!"});
            else
                self.m_index = 15
                self:refreshUi()
                local viewSize = self.content:getContentSize()
                self:refreshQRZSView(viewSize)
                self.m_chargeTableView = nil;
            end
        elseif btnTag == 16 then --好友邀请
            
            if self.current_version == 0 then
                 game_util:addMoveTips({text = "Sau khi quá hạn event, tính năng sẽ đóng!"})
            else  
                local viewSize = self.content:getContentSize()
                self.m_index = 16
                self:refreshUi()
                self:refreshhHYYQView(viewSize)
                self.m_chargeTableView = nil;
            end
        elseif btnTag == 17 then --累计充值
                local viewSize = self.content:getContentSize()
                self.m_index = 17
                self:refreshUi()
                self:recharge(self.pX,self.pY)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_oldplayer_comeback_pop.ccbi");
    local closeBtn = ccbNode:controlButtonForName("close_btn")
    self.btn_list_bg = ccbNode:nodeForName("btn_list_bg")
    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.content = ccbNode:nodeForName("content");
    self.m_node_contentboard = ccbNode:nodeForName("m_node_contentboard")
    local recall_time = json.decode(getConfig(game_config_field.recall_time):getFormatBuffer()) 
    local id = 0
    for k,v in pairs(recall_time) do
        if id < tonumber(k) then
            id = tonumber(k)
        end
    end
    local rebate_rate = recall_time[tostring(id)].rebate_rate
    if self.is_king then
        for i=1,7 do
            local tempBtn = ccbNode:controlButtonForName("m_btn_"..i)
            self.m_btn_tab[i] = tempBtn
            self.m_btn_tab[i]:setVisible(true)
            if tempBtn then
                local x,y  = self.m_btn_tab[i]:getPosition()
                local tempBtn_size = self.m_btn_tab[i]:getContentSize()
                tempBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
                local bg1 = CCScale9Sprite:createWithSpriteFrameName("a4.png")
                bg1:setOpacity(140)
                bg1:setVisible(true)
                bg1:setContentSize(CCSizeMake(tempBtn_size.width,tempBtn_size.height))
                bg1:setPosition(ccp(x,y))
                bg1:setAnchorPoint(ccp(0.5,0.5))
                bg1:setVisible(false)
                self.btn_list_bg:addChild(bg1,200+i)
                if self.current_version == 0 then
                    if i == 1 or i == 5 then
                        bg1:setVisible(false)
                    else
                        bg1:setVisible(true)
                    end
                end
                -- tempBtn:setColor(1)
                -- cclog2(i,"jskjklsjkfja;kdjfskaljdflj")
            end
        end
        if rebate_rate == 0 then
            self.m_btn_tab[5]:setVisible(false)
        end
    else
        self.m_btn_tab[1] = ccbNode:controlButtonForName("m_btn_1")
        self.m_btn_tab[1]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
        self.m_btn_tab[1]:setVisible(true);
        if self.m_tGameData.caller == "" then
            self.m_btn_tab[2] = ccbNode:controlButtonForName("m_btn_6")
            self.m_btn_tab[2]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
            self.m_btn_tab[2]:setVisible(true);
            self.m_btn_tab[2]:setPosition(ccp(46,179))
        else
            self.m_btn_tab[2] = ccbNode:controlButtonForName("m_btn_3")
            self.m_btn_tab[2]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
            self.m_btn_tab[2]:setVisible(true);
            self.m_btn_tab[2]:setPosition(ccp(46,179))
            self.m_btn_tab[3] = ccbNode:controlButtonForName("m_btn_6")
            self.m_btn_tab[3]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
            self.m_btn_tab[3]:setVisible(true);
            self.m_btn_tab[3]:setPosition(ccp(46,150))
        end
        

    end
    
    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
         if eventType == "began" then 
            -- local realPos = self.m_node_contentboard:getParent():convertToNodeSpace(ccp(x,y));
            -- if self.m_node_contentboard:boundingBox():containsPoint(realPos) then
            --     -- cclog2( "点在子UI界面上面 -- " )
            --     return false;
            -- end
            return true;  
        end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-2,true);
    self.m_root_layer:setTouchEnabled(true);
    closeBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    self:refreshUi()
    return ccbNode;
end
--[[--
    刷新ui
]]
function ui_oldplayer_pop.recharge(self,pX,pY)
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        data = json.decode(data:getFormatBuffer())
        self.content:removeAllChildrenWithCleanup(true);
        self.m_chargeTableView = self:createRecharge(self.content:getContentSize(),data)
        self.content:addChild(self.m_chargeTableView)
        if pX and pY then
            self.m_chargeTableView:setContentOffset(ccp(pX,pY), false);
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_recall_active_show"), http_request_method.GET, nil,"active_recall_active_show")
end
function ui_oldplayer_pop.createRechargeReward( self,node,rewardTab)
    node:removeAllChildrenWithCleanup(true)
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        game_util:lookItemDetal(rewardTab[btnTag])
    end
    local size = node:getContentSize()
    local reward_num = game_util:getTableLen(rewardTab)
    local x = math.ceil(reward_num/2) -- 判断总数是奇数偶数 来决定icon的位置
    local y = reward_num%2
    local width = size.width/reward_num
    for i=1,reward_num do
        local reward = rewardTab[i]
        local icon,name,count = game_util:getRewardByItemTable(reward)
        if icon then
            icon:setScale(0.6)
            local countlab = CCLabelTTF:create("x" .. count,TYPE_FACE_TABLE.Arial_BoldMT,8)
            if y == 0 then
                icon:setPosition(width/2+(i-1)*size.width/reward_num ,18)
                countlab:setPosition(width/2+(i-1)*size.width/reward_num,0)
            elseif y == 1 then
                icon:setPosition(size.width/2 + (i-x)*width,18)
                countlab:setPosition(size.width/2 + (i-x)*width,0)
            end
            node:addChild(icon)
            node:addChild(countlab)
            local button = game_util:createCCControlButton("public_skill.png","",onBtnCilck)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
            button:setAnchorPoint(ccp(0,0))
            button:setZoomOnTouchDown(false)
            button:setOpacity(0)
            button:setScale(0.8)
            button:setTag(i)
            icon:addChild(button)
        end
    end
end
function ui_oldplayer_pop.createRecharge( self,viewSize,data )
    local recall_active_recharge = getConfig(game_config_field.recall_active_recharge)
    local serverData = data.show
    local itemShowData = serverData[tostring(1)]
    local context = itemShowData.context
    local rechargeData = {}
    for k,v in pairs(context) do
        local itemFlag = v.flag
        if itemFlag ~= -1 then
            local itemCfg = recall_active_recharge:getNodeWithKey(tostring(k))
            local itemData = json.decode(itemCfg:getFormatBuffer())
            itemData.id = k
            table.insert(rechargeData,itemData)
        end
    end
    local function sortFunc(itemData1,itemData2)
        local show_id1 = itemData1.show_id
        local show_id2 = itemData2.show_id
        return show_id1 < show_id2
    end
    table.sort( rechargeData, sortFunc )
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local params = {}
        params.active_id = btnTag
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local reward = data:getNodeWithKey("reward")
            game_util:rewardTipsByJsonData(reward);
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            self:recharge()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_recall_active_recharge_receive"), http_request_method.GET, params,"active_recall_active_recharge_receive")
    end
    local viewSize = viewSize;
    local params = {};
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 2
    params.viewSize = viewSize;
    params.totalItem = game_util:getTableLen(rechargeData) or 7;
    params.row = 4;
    params.column = 1;
    params.direction = kCCScrollViewDirectionVertical;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function( tableView,index )
        local cell = tableView:dequeueCell();
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_oldplayer_comeback_denglu_item.ccbi");
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.4));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode") 
            if ccbNode then
                local day_num = ccbNode:labelTTFForName("day_num")
                day_num:setScale(0.8)
                day_num:setPosition(ccp(13,45))
                day_num:setAnchorPoint(ccp(0,0))
                local des = rechargeData[index+1].des
                -- local des = "当日累计充值"
                local consum = "(" .. context[tostring(index+1)].now_value .. "/" .. rechargeData[index+1].num .. ")"
                day_num:setString(des .. consum)

                local m_daily_lab = ccbNode:labelTTFForName("m_daily_lab")
                m_daily_lab:setVisible(true)
                local showtime = rechargeData[index+1].show_time
                local daily = showtime
                m_daily_lab:setString(daily)
                m_daily_lab:getParent():reorderChild(m_daily_lab, 6)
                local m_money_sp = ccbNode:scale9SpriteForName("m_money_sp")
                m_money_sp:setPreferredSize(CCSizeMake(150, 20))
                local gift_nod = ccbNode:nodeForName("gift_nod")
                local rewardTab = rechargeData[index+1].reward
                self:createRechargeReward(gift_nod,rewardTab)

                local receive_btn = ccbNode:controlButtonForName("receive_btn")
                receive_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
                receive_btn:setTag(index + 1)

                local id = rechargeData[index+1].id
                local flag = context[tostring(id)].flag

                if flag == 0 then--可领取
                    receive_btn:setVisible(true)
                    receive_btn:setTouchEnabled(true)
                    receive_btn:setTitleForState(CCString:create("Nhận "),1)
                    game_util:setCCControlButtonBackground(receive_btn,"a1.png")
                elseif flag == 1 then--不可领取
                    receive_btn:setVisible(true)
                    receive_btn:setTouchEnabled(false)
                    receive_btn:setTitleForState(CCString:create("Không thể nhận"),1)
                    game_util:setCCControlButtonBackground(receive_btn,"a1.png")
                else
                    game_util:setCCControlButtonBackground(receive_btn,"4.png")
                    receive_btn:setTitleForState(CCString:create(""),1)
                    receive_btn:setVisible(true)
                    receive_btn:setTouchEnabled(false)
                end
            end
            return cell;
        end
    end
    return TableViewHelper:create(params);
end
--[[
    好友邀请
]]
function ui_oldplayer_pop.refreshhHYYQView( self ,viewSize)
    local recall_Cfg = getConfig(game_config_field.recall_award)
    local recall_Cfg_daily = recall_Cfg:getNodeAt(2);
    local inputId_des_old = recall_Cfg:getNodeAt(3):getNodeWithKey("des"):toStr();
    local inputId_des_new = recall_Cfg:getNodeAt(4):getNodeWithKey("des"):toStr();
     local showData1 =recall_Cfg_daily:getNodeWithKey("reward") 
    local showData = json.decode( showData1:getFormatBuffer() ) or {}
    -- cclog2(showData,"haoyou  de   data   2  ====  showData")
    local older_uid = nil;
    -- lua sample 输入框
    local function scriptEditBoxHandler(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "began" then
            -- strFmt = string.format("editBox %p DidBegin !", edit)
            -- print(strFmt)
        elseif strEventName == "ended" then
            older_uid = edit:getText();
            -- cclog2(older_uid,"older_uid === ")
        end

    end
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag ==1 then 
            if older_uid == nil then 
                game_util:addMoveTips({text = "Bạn chưa nhập ID người chơi!"});
            else
                
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    -- cclog("data = " .. data:getFormatBuffer())
                    game_util:addMoveTips({text = "Đã thêm thành công!"});
                    self:responseMethod_model(tag,gameData)
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_add_caller"), http_request_method.GET, {target_uid = older_uid},"king_add_caller")
        
            end
        elseif btnTag == 2 then
            local function responseMethod(tag,gameData)
                self:responseMethod_model(tag,gameData)
                -- self.receive_btn:setVisible(false);
                -- local bg1 = CCScale9Sprite:createWithSpriteFrameName("4.png")
                -- bg1:setScale(1.2)
                -- bg1:setPosition(ccp(237,20))
                -- self.reward_node:addChild(bg1,200)
                -- self.receive_btn:setVisible(false);
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_get_normal_reward"), http_request_method.GET, {reward_id = 3},"king_get_normal_reward")
            
        end
    end 
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemKey = showData[btnTag]
        game_util:lookItemDetal(itemKey)
    end

    self.content:removeAllChildrenWithCleanup(true);
    local ccbNode = luaCCBNode:create();
    local itemSize = CCSizeMake(viewSize.width,viewSize.height);
    ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
    ccbNode:openCCBFile("ccb/ui_oldplayer_comeback_invite.ccbi");
    local m_root_layer_uid =  tolua.cast(ccbNode:objectForName("m_root_layer_uid"),"CCLayer")
    self.reward_node = ccbNode:nodeForName("reward_node");
    local reward_allnod = ccbNode:nodeForName("reward_allnod")
    local inputId_des = ccbNode:labelTTFForName("inputId_des");
    -- cclog2(self.is_king,"is_king=== ")
    if self.is_king == true then 
        inputId_des:setString(inputId_des_old)
    else 
        inputId_des:setString(inputId_des_new)
    end 
    local sure_btn = ccbNode:controlButtonForName("sure_btn");
    local zhaohui_des = ccbNode:labelTTFForName("zhaohui_des")
    zhaohui_des:setString(recall_Cfg_daily:getNodeWithKey("des"):toStr())
    sure_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    self.receive_btn = ccbNode:controlButtonForName("receive_btn");
    self.receive_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    -- cclog2(self.friend_commission_avail, "self.friend_commission_avail")
    -- cclog2(self.caller," self.caller")
    if self.friend_commission_avail == true and self.is_caller ~= "" then 
        self.receive_btn:setVisible(true);
        self.receive_btn:setTouchEnabled(true)
        local bg_tiao = CCScale9Sprite:createWithSpriteFrameName("anniuguang.png")
        bg_tiao:setContentSize(CCSizeMake(70,30))
        bg_tiao:setPosition(ccp(200,7))
        bg_tiao:runAction(game_util:createRepeatForeverFade())
        bg_tiao:setAnchorPoint(ccp(0,0))
        self.reward_node:addChild(bg_tiao,100,400)
        -- cclog2("zhaohui le   ande   keling ")
    elseif self.is_caller == true and self.friend_commission_avail == false then 
        self.receive_btn:setVisible(false);
        self.receive_btn:setTouchEnabled(false);
        local bg1 = CCScale9Sprite:createWithSpriteFrameName("4.png")
        bg1:setScale(1.2)
        bg1:setPosition(ccp(237,20))
        self.reward_node:addChild(bg1,200)
        -- cclog2("zhaohui le  ande  lingwan le ")
    elseif self.is_caller == false then 
        self.receive_btn:setVisible(true);
        self.receive_btn:setTouchEnabled(false);
        local bg1 = CCScale9Sprite:createWithSpriteFrameName("a4.png")
        bg1:setOpacity(140)
        -- bg1:setScale(0.9)
        bg1:setContentSize(CCSizeMake(70,30))
        bg1:setPosition(ccp(235,22))
        self.reward_node:addChild(bg1,200)
        -- cclog2("meizhaohui  ne ")
    end
    ccbNode:setAnchorPoint(ccp(0,0));
    ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
    self.content:addChild(ccbNode)
    local m_edit_bg_node = ccbNode:nodeForName("m_edit_bg_node")
    -- local textFieldTTF = nil;
    local m_edit_bg_node_size = m_edit_bg_node:getContentSize();
    -- textFieldTTF = CCTextFieldTTF:textFieldWithPlaceHolder("请输入您好友的ID", m_edit_bg_node_size, kCCTextAlignmentLeft, "", 10);
    -- textFieldTTF:setPosition(ccp(m_edit_bg_node_size.width*0.5,m_edit_bg_node_size.height*0.5-5));
    -- textFieldTTF:setColor(ccc3(255,255,255));
    -- textFieldTTF:setAnchorPoint(ccp(0.5,0.5));
    -- m_edit_bg_node:addChild(textFieldTTF);

    local editBoxTemp = CCEditBox:create(m_edit_bg_node_size,CCScale9Sprite:createWithSpriteFrameName("11.png"));
    editBoxTemp:setPreferredSize(m_edit_bg_node_size);
    editBoxTemp:setPosition(ccp(m_edit_bg_node_size.width*0.5, m_edit_bg_node_size.height*0.5))
    editBoxTemp:setFontColor(ccc3(255,255,255))
    editBoxTemp:setPlaceHolder("Hãy nhập ID bạn bè của bạn")
    editBoxTemp:setPlaceholderFontColor(ccc3(255,255,255))
    editBoxTemp:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    editBoxTemp:setFont("Arial",10)
    if self.is_king == false then
        inputId_des:setVisible(false);
        sure_btn:setVisible(false);
        m_edit_bg_node:setVisible(false)
        zhaohui_des:setString("Bạn phải mời người chơi cũ xong mới được nhận thưởng!")
        reward_allnod:setPositionY(40)
    end
    --Handler
    editBoxTemp:registerScriptEditBoxHandler(scriptEditBoxHandler)
    --添加奖励
    m_edit_bg_node:addChild(editBoxTemp)
    local reward_pos = {
                {0.5},
                {0.2, 0.4},
                {0.2, 0.4, 0.6},
                {0.2, 0.4, 0.6, 0.9},
            }
    local tempSize = self.reward_node:getContentSize()
    local posTable = reward_pos[#showData]
    for i=1,#showData do
        -- cclog2(#reward,"#reward ======= ~~~~~~~~~~~~~~~~~~~~~~")
        local aim_pos = ccp( tempSize.width * posTable[i], tempSize.height * 0.6 )
        -- local bgLayer = CCLayerColor:create(ccc4(255,255,255,255),36,36);
        -- bgLayer:setAnchorPoint(ccp(0.5,0.5))
        -- bgLayer:ignoreAnchorPointForPosition(false);

        local bgSprite = CCSprite:createWithSpriteFrameName("5.png");
        bgSprite:setScale(0.6)
        bgSprite:setAnchorPoint(ccp(0.5,0.5))

        local itemrewardData = showData[i]
        local reward_icon,name,count = game_util:getRewardByItemTable(showData[i],true);
        -- cclog2(count,"reward_icon ======= ~~~~~~~~~~~~~~~~~~~~~~")
        if reward_icon then
            -- cclog2(reward_icon,"reward_icon ======= ~~~~~~~~~~~~~~~~~~~~~~")
                    --加查看按钮
            local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
            -- button:setTag((index) * 10 + i)
            button:setTag(i)
            button:setAnchorPoint(ccp(0.5,0.5))
            button:setPosition( aim_pos )
            button:setOpacity(0)
            self.reward_node:addChild(button)

            reward_icon:setAnchorPoint(ccp(0.5,0.5))
            reward_icon:setScale(0.7)
            reward_icon:setPosition(aim_pos)
            -- if status == 1 then--领奖按钮
                -- reward_node:addChild(bgLayer)
                self.reward_node:addChild(bgSprite)
            -- end
            self.reward_node:addChild(reward_icon)
            bgSprite:setPosition( aim_pos )
            -- 发光

            local board = nil
            board = CCSprite:createWithSpriteFrameName("public_faguang.png");
            board:setAnchorPoint(ccp(0,0))
            board:setPosition(ccp(-14,-14))
            -- board:setScale(0.8)
            board:runAction(game_util:createRepeatForeverFade())
            if board and self.friend_commission_avail == true then 
                reward_icon:addChild(board,-1,500)
            end
            
        end
    end
end
--[[
    刷新七日返利界面
]]
function ui_oldplayer_pop.refreshQRZSView(self)
    self.content:removeAllChildrenWithCleanup(true);
    self:createQRZSTableView(self.content:getContentSize())

end
--[[
    刷新回归大礼包界面
]]
function ui_oldplayer_pop.refreshCBGView(self)
    self.content:removeAllChildrenWithCleanup(true);
    self:createCBGTableView(self.content:getContentSize())

end
--[[
    刷新每日奖励界面
]]
function ui_oldplayer_pop.refreshGiftTableView(self)
    self.content:removeAllChildrenWithCleanup(true);
    self:createGiftTableView2(self.content:getContentSize())

end
--[[
    刷新每日登陆奖励界面
]]
function ui_oldplayer_pop.refreshDailyGiftTableView(self)
    self.content:removeAllChildrenWithCleanup(true);
    local tempTable = self:createGiftTableView(self.content:getContentSize())
    self.content:addChild(tempTable);

end

--[[
    刷新七日任务界面
]]
function ui_oldplayer_pop.refreshQRRWGiftTableView(self)
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        self.content:removeAllChildrenWithCleanup(true);
        local tempTable = self:createGiftTableView3(self.content:getContentSize(),data)
        self.content:addChild(tempTable)
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("recall_reward_index"), http_request_method.GET, nil,"recall_reward_index")
end
--[[
    创建回归大礼包的奖励界面的及描述
]]
function ui_oldplayer_pop.createCBGTableView(self,viewSize)
    local recall_Cfg = getConfig(game_config_field.recall_award)
    local recall_Cfg_daily = recall_Cfg:getNodeAt(1);
     local showData1 =recall_Cfg_daily:getNodeWithKey("reward") 
    local showData = json.decode( showData1:getFormatBuffer() ) or {}
    -- cclog2(showData,"createGiftTableView2  ====  showData")
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local index = btnTag
        local function responseMethod(tag,gameData)
            self:responseMethod_model(tag,gameData)
        end
        if self.recall_package_avail then
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_get_normal_reward"), http_request_method.GET, {reward_id = 2},"king_get_normal_reward")
        end
    end
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemKey = showData[btnTag]
        game_util:lookItemDetal(itemKey)
    end

    local ccbNode = luaCCBNode:create();
    local itemSize = CCSizeMake(viewSize.width,viewSize.height);
    ccbNode:registerFunctionWithFuncName("onCellBtnClick1",onCellBtnClick);
    ccbNode:openCCBFile("ccb/ui_oldplayer_comeback_daily.ccbi");
    ccbNode:setAnchorPoint(ccp(0,0));
    ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
    self.content:addChild(ccbNode)
    local reward_des = ccbNode:labelTTFForName("reward_des")
    self.reward_node = ccbNode:nodeForName("reward_node_2")
    self.receive_btn = ccbNode:controlButtonForName("receive_btn_1")
    self.receive_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    if self.recall_package_avail then 
        self.receive_btn:setVisible(true);
        self.receive_btn:setTouchEnabled(true)
        local bg_tiao = CCScale9Sprite:createWithSpriteFrameName("anniuguang.png")
        bg_tiao:setContentSize(CCSizeMake(70,30))
        bg_tiao:setPosition(ccp(126,-25))
        bg_tiao:runAction(game_util:createRepeatForeverFade())
        self.reward_node:addChild(bg_tiao,100,400)
    elseif self.is_caller or self.is_king then
        self.receive_btn:setVisible(false);
        self.receive_btn:setTouchEnabled(false);
        local bg1 = CCScale9Sprite:createWithSpriteFrameName("4.png")
        bg1:setScale(1.2)
        bg1:setPosition(ccp(213.0,30))
        self.reward_node:addChild(bg1,200)
    end
    local des = recall_Cfg_daily:getNodeWithKey("des"):toStr()
    reward_des:setString(des)
    local reward_pos = {
                {0.2},
                {0.2, 0.4},
                {0.2, 0.4, 0.6},
                {0.2, 0.4, 0.6, 0.8},
            }
    local tempSize = self.reward_node:getContentSize()
    local posTable = reward_pos[#showData]
    for i=1,#showData do
        -- cclog2(#reward,"#reward ======= ~~~~~~~~~~~~~~~~~~~~~~")
        local aim_pos = ccp( tempSize.width * posTable[i], tempSize.height * 0.6 )
        -- local bgLayer = CCLayerColor:create(ccc4(255,255,255,255),36,36);
        -- bgLayer:setAnchorPoint(ccp(0.5,0.5))
        -- bgLayer:ignoreAnchorPointForPosition(false);

        local bgSprite = CCSprite:createWithSpriteFrameName("5.png");
        bgSprite:setScale(0.6)
        bgSprite:setAnchorPoint(ccp(0.5,0.5))
        bgSprite:setPosition( ccp( tempSize.width * posTable[i], tempSize.height * 0.6 ) )

        local itemrewardData = showData[i]
        local reward_icon,name,count = game_util:getRewardByItemTable(showData[i],true);
        -- cclog2(count,"reward_icon ======= ~~~~~~~~~~~~~~~~~~~~~~")
        if reward_icon then
            -- cclog2(reward_icon,"reward_icon ======= ~~~~~~~~~~~~~~~~~~~~~~")
            reward_icon:setAnchorPoint(ccp(0.5,0.5))
            reward_icon:setScale(0.7)
            reward_icon:setPosition(aim_pos)
            -- if status == 1 then--领奖按钮
                -- reward_node:addChild(bgLayer)
            self.reward_node:addChild(bgSprite)
            -- end
            self.reward_node:addChild(reward_icon)
            if reward_icon and count then
                --加查看按钮
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                -- button:setTag((index) * 10 + i)
                button:setTag(i)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition( aim_pos )
                button:setOpacity(0)
                self.reward_node:addChild(button)


                local label = game_util:createLabelTTF({text = "×"..count,color = ccc3(250,250,250),fontSize = 12})
                label:setAnchorPoint(ccp(0.5,0))
                label:setPosition(ccp( reward_icon:getContentSize().width * 0.5 ,-12))
                reward_icon:addChild(label, 10)
                -- cclog2(count,"count ======= ~~~~~~~~~~~~~~~~~~~~~~")
                -- 发光

                local board = nil
                board = CCSprite:createWithSpriteFrameName("public_faguang.png");
                board:setAnchorPoint(ccp(0,0))
                board:setPosition(ccp(-14,-14))
                -- board:setScale(1.4)
                board:runAction(game_util:createRepeatForeverFade())
                if board and self.recall_package_avail then
                    reward_icon:addChild(board,-1,500)
                end
            end
        end
    end
end
--[[
    创建每日奖励界面的及描述
]]
function ui_oldplayer_pop.createGiftTableView2(self,viewSize)
    local reward_pos = {
            {0.2},
            {0.2, 0.4},
            {0.2, 0.4, 0.6},
            {0.2, 0.4, 0.6, 0.8},
            {0,0.2,0.4,0.6,0.8}
        }
    local recall_Cfg = getConfig(game_config_field.recall_award)
    local recall_Cfg_daily = recall_Cfg:getNodeAt(0);
     local showData1 =recall_Cfg_daily:getNodeWithKey("reward") 
    local showData = json.decode( showData1:getFormatBuffer() ) or {}
    -- cclog2(showData,"createGiftTableView2  ====  showData")
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local index = btnTag
        local function responseMethod(tag,gameData)
            -- self.login_reward_avail = false
            -- local data = gameData:getNodeWithKey("data")
            -- cclog("data = " .. data:getFormatBuffer())
            -- local reward = data:getNodeWithKey("reward")
            -- game_util:rewardTipsByJsonData(reward);
            -- self:refreshUi()
            -- self.receive_btn:setVisible(false);
            -- local bg1 = CCScale9Sprite:createWithSpriteFrameName("4.png")
            -- bg1:setScale(1.2)
            -- bg1:setPosition(ccp(213.0,30))
            -- self.reward_node:addChild(bg1,200)
            -- self.receive_btn:setVisible(false);
            self:responseMethod_model(tag, gameData)
        end
        if self.login_reward_avail then
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_get_normal_reward"), http_request_method.GET, {reward_id = 1},"king_get_normal_reward")
        end
    end
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemKey = showData[btnTag]
        game_util:lookItemDetal(itemKey)
    end
    local ccbNode = luaCCBNode:create();
    local itemSize = CCSizeMake(viewSize.width,viewSize.height);
    ccbNode:registerFunctionWithFuncName("onCellBtnClick1",onCellBtnClick);
    ccbNode:openCCBFile("ccb/ui_oldplayer_comeback_daily.ccbi");
    ccbNode:setAnchorPoint(ccp(0,0));
    ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
    self.content:addChild(ccbNode)
    local reward_des = ccbNode:labelTTFForName("reward_des")
    self.reward_node = ccbNode:nodeForName("reward_node_2")
    self.receive_btn = ccbNode:controlButtonForName("receive_btn_1")
    self.receive_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    local des = recall_Cfg_daily:getNodeWithKey("des"):toStr()

    if self.login_reward_avail then 
        self.receive_btn:setVisible(true);
        self.receive_btn:setTouchEnabled(true)
        local bg_tiao = CCScale9Sprite:createWithSpriteFrameName("anniuguang.png")
        bg_tiao:setContentSize(CCSizeMake(70,30))
        bg_tiao:setPosition(ccp(126,-25))
        bg_tiao:runAction(game_util:createRepeatForeverFade())
        self.reward_node:addChild(bg_tiao,100,400)
    elseif self.is_king then
        self.receive_btn:setVisible(false);
        self.receive_btn:setTouchEnabled(false);
        local bg1 = CCScale9Sprite:createWithSpriteFrameName("4.png")
        bg1:setScale(1.2)
        bg1:setPosition(ccp(213.0,30))
        self.reward_node:addChild(bg1,200)
    end
    reward_des:setString(des)
    
    local tempSize = self.reward_node:getContentSize()
    local posTable = reward_pos[#showData]
    for i=1,#showData do
        -- cclog2(#reward,"#reward ======= ~~~~~~~~~~~~~~~~~~~~~~")
        local aim_pos = ccp( tempSize.width * posTable[i], tempSize.height * 0.6 )
        -- local bgLayer = CCLayerColor:create(ccc4(255,255,255,255),36,36);
        -- bgLayer:setAnchorPoint(ccp(0.5,0.5))
        -- bgLayer:ignoreAnchorPointForPosition(false);

        local bgSprite = CCSprite:createWithSpriteFrameName("5.png");
        bgSprite:setScale(0.6)
        bgSprite:setAnchorPoint(ccp(0.5,0.5))

        local itemrewardData = showData[i]
        local reward_icon,name,count = game_util:getRewardByItemTable(showData[i],true);
        -- cclog2(count,"reward_icon ======= ~~~~~~~~~~~~~~~~~~~~~~")
        if reward_icon then
            -- cclog2(reward_icon,"reward_icon ======= ~~~~~~~~~~~~~~~~~~~~~~")
            reward_icon:setAnchorPoint(ccp(0.5,0.5))
            reward_icon:setScale(0.7)
            reward_icon:setPosition(aim_pos)
            -- if status == 1 then--领奖按钮
                -- reward_node:addChild(bgLayer)
                self.reward_node:addChild(bgSprite)
            -- end
            self.reward_node:addChild(reward_icon)
            bgSprite:setPosition( aim_pos )
            if reward_icon and count then
            --加查看按钮
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                -- button:setTag((index) * 10 + i)
                button:setTag(i)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition( aim_pos )
                button:setOpacity(0)
                self.reward_node:addChild(button)

                local label = game_util:createLabelTTF({text = "×"..count,color = ccc3(250,250,250),fontSize = 12})
                label:setAnchorPoint(ccp(0.5,0))
                label:setPosition(ccp( reward_icon:getContentSize().width * 0.5 ,-12))
                reward_icon:addChild(label, 10)
                -- 发光

                local board = nil
                board = CCSprite:createWithSpriteFrameName("public_faguang.png");
                board:setAnchorPoint(ccp(0,0))
                board:setPosition(ccp(-14,-14))
                -- board:setScale(1.4)
                board:runAction(game_util:createRepeatForeverFade())
                if board and self.login_reward_avail then
                    reward_icon:addChild(board,-1,500)
                end
                -- cclog2(count,"count ======= ~~~~~~~~~~~~~~~~~~~~~~")
            end
        end
    end
end
--[[
    创建七日钻石奖励界面的奖励
]]
function ui_oldplayer_pop.createQRZSTableView( self, viewSize )
    local ccbNode = luaCCBNode:create();
    local itemSize = CCSizeMake(viewSize.width,viewSize.height);
    local recall_Cfg = getConfig(game_config_field.recall_award)
    local recall_Cfg_daily = recall_Cfg:getNodeAt(1);
     local showData1 =recall_Cfg_daily:getNodeWithKey("des") 
    -- ccbNode:registerFunctionWithFuncName("onCellBtnClick1",onCellBtnClick);
    ccbNode:openCCBFile("ccb/ui_oldplayer_comeback_seven_gift.ccbi");
    ccbNode:setAnchorPoint(ccp(0,0));
    ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
    self.content:addChild(ccbNode)
    local des = ccbNode:labelTTFForName("reward_des");
    des:setString(showData1:toStr())
    self.reward_node_bg = ccbNode:nodeForName("reward_node_2")
    -- cclog2(self.reward_node_bg,"self.reward_node_bg")
    local recall_sevenZsCfg = getConfig(game_config_field.recall_coin)
    local tempCount = recall_sevenZsCfg:getNodeCount();
    self.recall_seven_tabel = {};
    for i=0,tempCount do
        local itemCfg = recall_sevenZsCfg:getNodeAt(i)
        table.insert(self.recall_seven_tabel,itemCfg)
    end
    -- cclog2(tempCount,"tempCount===")
    -- local showData = self.recall_seven_tabel or {};
    local viewSize1 = self.reward_node_bg:getContentSize();
    -- cclog2(self.recall_seven_tabel,"self.recall_seven_tabelself.recall_seven_tabelself.recall_seven_tabel")
    -- cclog2(showData,"showDatashowDatashowDatashowDatashowDatashowDatashowDatashowDatashowData")
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog("btnTag = " ..btnTag)
        -- if btnTag <= #showData then--领奖按钮
            local index = btnTag
            local function responseMethod(tag,gameData)
                self:responseMethod_model(tag,gameData)
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_get_rebate_coin"), http_request_method.GET, {day_id = index},"king_get_rebate_coin")
        -- end
    end


    local num = 0
    local data_num = {}
    for k,v in pairs(self.sliced_coin_dict) do
        num  =  num + 1 ;
        data_num[k] = v;
    end
    -- cclog2(num,"num");
    -- cclog2(data_num,"data_num")
    local params = {};
    params.viewSize = viewSize1;
    params.row = 2;--行
    params.column = 1; --列
    params.totalItem = num;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    local itemSize = CCSizeMake(viewSize1.width/params.column,viewSize1.height/params.row);
    local nodeTab = {};
    params.newCell = function(tableView,index) 
    -- cclog2(index,"index   =======     ")
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local spriteLand = luaCCBNode:create();
            spriteLand:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            spriteLand:openCCBFile("ccb/ui_oldplayer_comeback_denglu_item.ccbi");
            spriteLand:setAnchorPoint(ccp(0,0));
            spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(spriteLand,10,10);
            cell:setVisible(true);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local day_num = ccbNode:labelTTFForName("day_num")
            self.receive_btn = ccbNode:controlButtonForName("receive_btn")
            self.receive_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
            self.reward_node = ccbNode:nodeForName("gift_nod")
            self.reward_node:removeAllChildrenWithCleanup(true)
            self.receive_btn:setZoomOnTouchDown(false);
            self.receive_btn:setTag(index+1)
            self.receive_btn:setVisible(true)
            self.receive_btn:setTouchEnabled(true)
            -- cclog2(self.now_days,"self.now_daysself.now_daysself.now_days")

            local bg_tiao = CCScale9Sprite:createWithSpriteFrameName("anniuguang.png")
            bg_tiao:setContentSize(CCSizeMake(70,30))
            bg_tiao:setPosition(ccp(224.0,19))
            bg_tiao:runAction(game_util:createRepeatForeverFade())
            self.reward_node:addChild(bg_tiao,100,400)
            if self.now_days_coin ~= index+1 then
                local bg2 = self.reward_node:getChildByTag(400)
                bg2:setVisible(false)
                self.receive_btn:setTouchEnabled(false);
                local bg = CCScale9Sprite:createWithSpriteFrameName("a4.png")
                bg:setOpacity(140)
                -- bg:setScale(0.9)
                bg:setContentSize(CCSizeMake(70,30))
                bg:setPosition(ccp(224.0 ,20))
                self.reward_node:addChild(bg,100,100)
                if next(self.received_coin_dayNum) ~= nil then 
                    -- cclog2(self.received_coin_dayNum,"self.received_coin_dayNum")
                    for i=1,#self.received_coin_dayNum do
                        -- cclog2(index+1,"index+1")
                        if index+1 == self.received_coin_dayNum[i] then
                            local bg1 = CCScale9Sprite:createWithSpriteFrameName("4.png")
                            bg1:setScale(1.2)
                            bg1:setPosition(ccp(223.0,15))
                            self.reward_node:addChild(bg1,200)
                            self.receive_btn:setVisible(false);
                            local bg2 = self.reward_node:getChildByTag(100)
                            bg2:setVisible(false)
                        end
                    end
                end
            elseif self.now_days_coin == #self.received_coin_dayNum then 
                -- cclog2("4.png4.png4.png4.png4.png4.png")
                local bg1 = CCScale9Sprite:createWithSpriteFrameName("4.png")
                bg1:setScale(1.2)
                bg1:setPosition(ccp(223.0,15))
                self.reward_node:addChild(bg1,200)
                self.receive_btn:setVisible(false);
            end
            day_num:setString("Ngày  " .. index+1)
            local tempSize = self.reward_node:getContentSize()
            local aim_pos = ccp( tempSize.width * 0.5, tempSize.height * 0.6 -1)
            local temp_num = 0;
            for k,v in pairs(self.sliced_coin_dict) do
                if k == tostring(index+1) then 
                    temp_num = v
                end
            end
            local icon,name,count = CCSprite:createWithSpriteFrameName("public_icon_gold2.png"),"Xu",temp_num
            
            if icon then
                    -- cclog2(icon,"reward_icon ======= ~~~~~~~~~~~~~~~~~~~~~~")
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setScale(0.5)
                icon:setPosition(aim_pos)
                -- if status == 1 then--领奖按钮
                    -- reward_node:addChild(bgLayer)
                    -- self.reward_node:addChild(bgSprite)
                -- end
                self.reward_node:addChild(icon)
                -- bgSprite:setPosition( aim_pos )
                if icon and count then
                    local label = game_util:createLabelTTF({text = "×"..count,color = ccc3(250,250,250),fontSize = 12})
                    label:setAnchorPoint(ccp(0.5,0))
                    label:setPosition(ccp( icon:getContentSize().width * 0.5 ,-10))
                    icon:addChild(label, 10)
                    icon:setScale(0.7)
                    -- cclog2(count,"count ======= ~~~~~~~~~~~~~~~~~~~~~~")
                    -- 发光

                    local board = nil
                    board = CCSprite:createWithSpriteFrameName("public_faguang.png");
                    board:setAnchorPoint(ccp(0,0))
                    board:setPosition(ccp(-6,-6))
                    board:setScale(0.8)
                    board:runAction(game_util:createRepeatForeverFade())
                    if board then
                        if self.now_days_coin == (index+1) then 
                            icon:addChild(board,-1,500)
                        end
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
   
    end
    -- cclog2(params,"paramsparamsparamsparamsparams")
    local tempTableView = TableViewHelper:create(params)
    -- cclog2(tempTableView,"sss")
    self.reward_node_bg:addChild(tempTableView)
end


--[[
    创建七日任务界面的任务
]]
function ui_oldplayer_pop.createGiftTableView3(self,viewSize,data)
    local recall_Cfg = getConfig(game_config_field.recall_mission)
    -- cclog2(recall_Cfg,"recall_Cfg    ============  ")
    local reward_pos = {
            {0.2},
            {0.2, 0.4},
            {0.2, 0.4, 0.6},
            {0.2, 0.4, 0.6, 0.8},
        }
    local gameData = data:getNodeWithKey("daily_times")
    local showData = json.decode( gameData:getFormatBuffer() ) or {}
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog("btnTag == " .. btnTag)
        local dataIndex = math.floor(btnTag / 1000)
        local rewardIndex = math.floor(btnTag % 10)
        local showData = json.decode( recall_Cfg:getFormatBuffer() ) or {}
        local itemKey = showData[tostring(dataIndex + 1)]
        local reward = itemKey
        reward = reward.reward
        game_util:lookItemDetal(reward[ rewardIndex ])
    end

    local task_id = {}
    local task_data = {}
    -- cclog2(showData,"showData  %%%%%%%%%%%%")
    for k,v in pairs(showData) do
        table.insert(task_id,k)
        table.insert(task_data,v)
        -- self.task_num = self.task_num +　1
    end
    self.task_num = #task_id
    -- cclog2(task_id,"task_id")
    -- cclog2(task_data,"task_data")
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog("btnTag = " ..btnTag)
        -- if btnTag <= #showData then--领奖按钮
            local index = btnTag
            local function responseMethod(tag,gameData)
                self:responseMethod_model(tag,gameData)
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("recall_reward_daily_award"), http_request_method.GET, {daily_ID = btnTag},"recall_reward_daily_award")
        -- end
    end
    -- -- cclog2(#showData,"#showData#showData#showData#showData")
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = self.task_num;
    -- cclog2(#showData,"#showData#showData#showData#showData#showData")
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    local nodeTab = {};
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local spriteLand = luaCCBNode:create();
            spriteLand:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            spriteLand:openCCBFile("ccb/ui_oldplayer_comeback_denglu_item.ccbi");
            spriteLand:setAnchorPoint(ccp(0,0));
            spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5-10));
            cell:addChild(spriteLand,10,10);
            cell:setVisible(true);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local day_num = ccbNode:labelTTFForName("day_num")
            self.receive_btn = ccbNode:controlButtonForName("receive_btn")
            self.receive_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
            self.reward_node = ccbNode:nodeForName("gift_nod")
            self.reward_node:removeAllChildrenWithCleanup(true)
            self.receive_btn:setZoomOnTouchDown(false);
            self.receive_btn:setTag(task_id[index+1])
            self.receive_btn:setVisible(true)
            self.receive_btn:setTouchEnabled(true)
            --添加描述
            
            local  recall_Cfg_value= recall_Cfg:getNodeAt(task_id[index+1]-1)
            -- cclog2(task_id[index+1],"task_id[index+1]")
            -- cclog2(recall_Cfg_value,"recall_Cfg_value    ============  ")
            local name = recall_Cfg_value:getNodeWithKey("name"):toStr()
            day_num:setString(name)
            day_num:setFontSize(8)
            --添加icon和数量
            local reward1 = recall_Cfg_value:getNodeWithKey("reward")
            local reward = json.decode( reward1:getFormatBuffer() ) or {}
            -- cclog2(reward,"reward =====  ")

            local tempSize = self.reward_node:getContentSize()
            local posTable = reward_pos[#reward]
            -- cclog2(reward,"reward ======= ~~~~~~~~~~~~~~~~~~~~~~")
            for i=1,#reward do
                -- cclog2(#reward,"#reward ======= ~~~~~~~~~~~~~~~~~~~~~~")
                local aim_pos = ccp( tempSize.width * posTable[i], tempSize.height * 0.6 -1)
                -- local bgLayer = CCLayerColor:create(ccc4(255,255,255,255),36,36);
                -- bgLayer:setAnchorPoint(ccp(0.5,0.5))
                -- bgLayer:ignoreAnchorPointForPosition(false);

                local bgSprite = CCSprite:createWithSpriteFrameName("5.png");
                bgSprite:setScale(0.6)
                bgSprite:setAnchorPoint(ccp(0.5,0.5))

                local itemrewardData = reward[i]
                local reward_icon,name,count = game_util:getRewardByItemTable(reward[i],true);
                -- cclog2(reward[i],"reward[i] ======= ~~~~~~~~~~~~~~~~~~~~~~")
                if reward_icon then
                    -- cclog2(reward_icon,"reward_icon ======= ~~~~~~~~~~~~~~~~~~~~~~")
                    reward_icon:setAnchorPoint(ccp(0.5,0.5))
                    reward_icon:setScale(0.6)
                    reward_icon:setPosition(aim_pos)
                    -- if status == 1 then--领奖按钮
                        -- reward_node:addChild(bgLayer)
                        self.reward_node:addChild(bgSprite)
                    -- end
                    self.reward_node:addChild(reward_icon)
                    bgSprite:setPosition( aim_pos )

                    if reward_icon and count then
                    --加查看按钮
                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                    -- button:setTag((index) * 10 + i)
                    button:setTag(i + index * 1000)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition( aim_pos )
                    button:setOpacity(0)
                    self.reward_node:addChild(button)

                        local label = game_util:createLabelTTF({text = "×"..count,color = ccc3(250,250,250),fontSize = 12})
                        label:setAnchorPoint(ccp(0.5,0))
                        label:setPosition(ccp( reward_icon:getContentSize().width * 0.5 ,-12))
                        reward_icon:addChild(label, 10)
                        -- cclog2(count,"count ======= ~~~~~~~~~~~~~~~~~~~~~~")

                    end
                    local temp = index+1
                    local  task_data_temp = task_data[temp]
                    -- cclog2(recall_Cfg_value,"task_data_temptask_data_temp")
                    if recall_Cfg_value:getNodeWithKey("target_data"):toInt() > task_data_temp[1] or task_data_temp[2] == 0 then 
                        -- cclog2("jia huikuang  kexian  bukechu ")
                        self.receive_btn:setVisible(true);
                        self.receive_btn:setTouchEnabled(false);
                        local bg = CCScale9Sprite:createWithSpriteFrameName("a4.png")
                        bg:setOpacity(140)
                        bg:setContentSize(CCSizeMake(70,30))
                        bg:setPosition(ccp(224.0,20))
                        self.reward_node:addChild(bg,100,100)
                    elseif task_data_temp[2] and task_data_temp[3] == 0 then 
                        self.receive_btn:setVisible(true);
                        self.receive_btn:setTouchEnabled(true);
                        local bg_tiao = CCScale9Sprite:createWithSpriteFrameName("anniuguang.png")
                        bg_tiao:setContentSize(CCSizeMake(70,30))
                        bg_tiao:setPosition(ccp(224.0,19))
                        bg_tiao:runAction(game_util:createRepeatForeverFade())
                        self.reward_node:addChild(bg_tiao,100,400)
                         -- 发光

                        local board = nil
                        board = CCSprite:createWithSpriteFrameName("public_faguang.png");
                        board:setAnchorPoint(ccp(0,0))
                        board:setPosition(ccp(-14,-14))
                        -- board:setScale(1.4)
                        board:runAction(game_util:createRepeatForeverFade())
                        if board then
                            reward_icon:addChild(board,-1,500)
                        end
                    elseif  task_data_temp[3] then 
                        self.receive_btn:setVisible(false);
                        self.receive_btn:setTouchEnabled(false);
                        local bg = CCScale9Sprite:createWithSpriteFrameName("4.png")
                        bg:setContentSize(CCSizeMake(70,30))
                        bg:setPosition(ccp(224.0,20))
                        self.reward_node:addChild(bg,100,100)
                    end
                end
            end
            -- 将已经领取奖励的条条制灰
            -- for i=1,#self.received_reward_dayNum do
            --     cclog2(self.received_reward_dayNum[i],"self.received_reward_dayNum.i === ") 
            -- end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
   
    end
    return TableViewHelper:create(params);
end
function ui_oldplayer_pop.responseMethod_model( self,tag, gameData )
    local data = gameData:getNodeWithKey("data")
    -- cclog("data = " .. data:getFormatBuffer())
    local reward = data:getNodeWithKey("reward")
    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    self.sliced_coin_dict = self.m_tGameData.sliced_coin_dict;
    self.history_coin = self.m_tGameData.history_coin;
    self.received_reward_dayNum = self.m_tGameData.received_seven_reward
    self.received_coin_dayNum = self.m_tGameData.received_coin_reward
    self.now_days = self.m_tGameData.seven_reward_avail;
    self.now_days_coin = self.m_tGameData.coin_reward_avail;
    self.login_reward_avail = self.m_tGameData.login_reward_avail;
    self.recall_package_avail = self.m_tGameData.recall_package_avail;
    self.friend_commission_avail = self.m_tGameData.friend_commission_avail;
    self.caller = self.m_tGameData.caller;
    game_util:rewardTipsByJsonData(reward);
    self:refreshUi();
end
--[[
    创建每日登陆奖励界面的奖励
]]
function ui_oldplayer_pop.createGiftTableView(self,viewSize)
    local grow_gift_Cfg = getConfig(game_config_field.grow_gift);
    local reward_pos = {
            {0.2},
            {0.2, 0.4},
            {0.2, 0.4, 0.6},
            {0.2, 0.4, 0.6, 0.8},
        }
    local recall_sevenCfg = getConfig(game_config_field.recall_seven)
    local tempCount = recall_sevenCfg:getNodeCount();
    self.recall_seven_tabel = {};
    for i=0,tempCount do
        local itemCfg = recall_sevenCfg:getNodeAt(i)
        table.insert(self.recall_seven_tabel,itemCfg)
    end
    -- cclog2(tempCount,"tempCount===")
    local showData = self.recall_seven_tabel or {};

    -- cclog2(self.recall_seven_tabel,"self.recall_seven_tabelself.recall_seven_tabelself.recall_seven_tabel")
    -- cclog2(showData,"showDatashowDatashowDatashowDatashowDatashowDatashowDatashowDatashowData")
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog("btnTag = " ..btnTag)
        -- if btnTag <= #showData then--领奖按钮
            local index = btnTag
            local function responseMethod(tag,gameData)
                self:responseMethod_model(tag,gameData)
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_get_seven_reward"), http_request_method.GET, {day_id = index},"king_get_seven_reward")
        -- end
    end
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog("btnTag == " .. btnTag)
        local dataIndex = math.floor(btnTag / 1000)
        local rewardIndex = math.floor(btnTag % 10)
        
        local itemKey = showData[dataIndex + 1]
        -- local itemCfg = grow_gift_Cfg:getNodeWithKey( tostring(itemKey) )
        -- cclog2(itemKey,"itemKeyitemKeyitemKey")
        -- cclog2(grow_gift_Cfg,"grow_gift_Cfggrow_gift_Cfggrow_gift_Cfggrow_gift_Cfggrow_gift_Cfg")

        local reward = json.decode( itemKey:getFormatBuffer() ) or {}
        if self.is_king == true then
            reward = reward.reward_old
        else
            reward = reward.reward_new
        end
        -- cclog2(rewardIndex,"rewardIndexrewardIndexrewardIndexrewardIndex")
        game_util:lookItemDetal(reward[ rewardIndex ])
    end
    -- cclog2(#showData,"#showData#showData#showData#showData")
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = #showData;
    -- cclog2(#showData,"#showData#showData#showData#showData#showData")
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    local nodeTab = {};
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local spriteLand = luaCCBNode:create();
            spriteLand:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            spriteLand:openCCBFile("ccb/ui_oldplayer_comeback_denglu_item.ccbi");
            spriteLand:setAnchorPoint(ccp(0,0));
            spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5-10));
            cell:addChild(spriteLand,10,10);
            cell:setVisible(true);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local day_num = ccbNode:labelTTFForName("day_num")
            self.receive_btn = ccbNode:controlButtonForName("receive_btn")
            self.receive_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
            self.reward_node = ccbNode:nodeForName("gift_nod")
            self.reward_node:removeAllChildrenWithCleanup(true)
            self.receive_btn:setZoomOnTouchDown(false);
            self.receive_btn:setTag(index+1)
            self.receive_btn:setVisible(true)
            self.receive_btn:setTouchEnabled(true)
            -- cclog2(self.now_days,"self.now_daysself.now_daysself.now_days")
            local bg_tiao = CCScale9Sprite:createWithSpriteFrameName("anniuguang.png")
            bg_tiao:setContentSize(CCSizeMake(70,30))
            bg_tiao:setPosition(ccp(224.0,19))
            bg_tiao:runAction(game_util:createRepeatForeverFade())
            self.reward_node:addChild(bg_tiao,100,400)
            
            if self.now_days ~= index+1 then
                self.receive_btn:setTouchEnabled(false);
                local bg = CCScale9Sprite:createWithSpriteFrameName("a4.png")
                bg:setOpacity(140)
                bg:setContentSize(CCSizeMake(70,30))
                bg:setPosition(ccp(224.0,20))
                self.reward_node:addChild(bg,100,100)
                local bg_tiao = self.reward_node:getChildByTag(400)
                bg_tiao:setVisible(false)
                -- cclog2(self.received_reward_dayNum,"self.received_reward_dayNum")
                if next(self.received_reward_dayNum) ~= nil then
                    for i=1,#self.received_reward_dayNum do
                        -- cclog2(index+1,"index+1")
                        if index+1 == self.received_reward_dayNum[i] then
                            local bg1 = CCScale9Sprite:createWithSpriteFrameName("4.png")
                            -- bg1:setScale(1.2)
                            bg1:setPosition(ccp(223.0,20))
                            self.reward_node:addChild(bg1,200)
                            self.receive_btn:setVisible(false);
                            local bg2 = self.reward_node:getChildByTag(100)
                            bg2:setVisible(false)
                        end
                    end
                end
            elseif self.now_days == #self.received_reward_dayNum then 
                -- cclog2("shuaxin   lalallalalalll")
                local bg1 = CCScale9Sprite:createWithSpriteFrameName("4.png")
                -- bg1:setScale(1.2)
                bg1:setPosition(ccp(223.0,20))
                self.reward_node:addChild(bg1,200)
                self.receive_btn:setVisible(false);
            end
            -- cclog2(#self.received_reward_dayNum,"#self.received_reward_dayNum  alallalalalll ")
            -- cclog2(self.now_days,"self.now_days   alallalalalll ")
            day_num:setString("Ngày thứ  " .. index+1)
            local reward1 = {}
            if self.is_king then
                reward1 = showData[index+1]:getNodeWithKey("reward_old")
            else
                reward1 = showData[index+1]:getNodeWithKey("reward_new")
            end
            local reward = json.decode( reward1:getFormatBuffer() ) or {}
            -- cclog2(reward,"reward =====  ")

            local tempSize = self.reward_node:getContentSize()
            local posTable = reward_pos[#reward]
            -- cclog2(reward,"reward ======= ~~~~~~~~~~~~~~~~~~~~~~")
            for i=1,#reward do
                -- cclog2(#reward,"#reward ======= ~~~~~~~~~~~~~~~~~~~~~~")
                local aim_pos = ccp( tempSize.width * posTable[i], tempSize.height * 0.6-1 )
                -- local bgLayer = CCLayerColor:create(ccc4(255,255,255,255),36,36);
                -- bgLayer:setAnchorPoint(ccp(0.5,0.5))
                -- bgLayer:ignoreAnchorPointForPosition(false);

                local bgSprite = CCSprite:createWithSpriteFrameName("5.png");
                bgSprite:setScale(0.6)
                bgSprite:setAnchorPoint(ccp(0.5,0.5))

                local itemrewardData = reward[i]
                local reward_icon,name,count = game_util:getRewardByItemTable(reward[i],true);
                -- cclog2(reward[i],"reward[i] ======= ~~~~~~~~~~~~~~~~~~~~~~")
                if reward_icon then
                    -- cclog2(reward_icon,"reward_icon ======= ~~~~~~~~~~~~~~~~~~~~~~")
                    reward_icon:setAnchorPoint(ccp(0.5,0.5))
                    reward_icon:setScale(0.6)
                    reward_icon:setPosition(aim_pos)
                    -- if status == 1 then--领奖按钮
                        -- reward_node:addChild(bgLayer)
                        self.reward_node:addChild(bgSprite)
                    -- end
                    self.reward_node:addChild(reward_icon)
                    bgSprite:setPosition( aim_pos )
                    --加查看按钮
                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                    -- button:setTag((index) * 10 + i)
                    button:setTag(i + index * 1000)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition( aim_pos )
                    button:setOpacity(0)
                    self.reward_node:addChild(button)
                    if reward_icon and count then
                        local label = game_util:createLabelTTF({text = "×"..count,color = ccc3(250,250,250),fontSize = 12})
                        label:setAnchorPoint(ccp(0.5,0))
                        label:setPosition(ccp( reward_icon:getContentSize().width * 0.5 ,-12))
                        reward_icon:addChild(label, 10)
                        -- 发光
                        -- cclog2(index+1,"index+1  ===")
                        if reward_icon then
                            if self.now_days == (index+1) then 
                                local board = nil
                                board = CCSprite:createWithSpriteFrameName("public_faguang.png");
                                board:setAnchorPoint(ccp(0,0))
                                board:setPosition(ccp(-14,-14))
                                -- board:setScale(1.4)
                                board:runAction(game_util:createRepeatForeverFade())
                                if board and self.seven_reward_avail ~= 0 then
                                    reward_icon:addChild(board,-1,500)
                                    self.guang_guang[i] =  board
                                end
                            end
                        end
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
   
    end
    return TableViewHelper:create(params);
end
--[[
    创建竞技场排行榜列表
]]
function ui_oldplayer_pop.createRankTableView(self,viewSize)
   
end
--[[
    刷新
]]
function ui_oldplayer_pop.refreshUi(self)
    for i=1,#self.m_btn_tab do
        local tag = self.m_btn_tab[i]:getTag()
        if tag == self.m_index then            
            game_util:setCCControlButtonBackground(self.m_btn_tab[i],"a1.png")
        else
            game_util:setCCControlButtonBackground(self.m_btn_tab[i],"a3.png")
        end
    end
    local viewSize = self.content:getContentSize()
    if self.m_index == 11 then
        self:refreshDailyGiftTableView();
    elseif self.m_index == 12 then
        if self.current_version == 0 then
             game_util:addMoveTips({text = "活动时间已过，本功能不能开启！"})
        else    
            self:refreshGiftTableView(viewSize)
        end
    elseif self.m_index == 13 then
        if self.current_version == 0 then
             game_util:addMoveTips({text = "活动时间已过，本功能不能开启！"})
        else  
            self:refreshCBGView(viewSize)
        end
    elseif self.m_index == 14 then
        if self.current_version == 0 then
             game_util:addMoveTips({text = "活动时间已过，本功能不能开启！"})
        else  
            self:refreshQRRWGiftTableView(viewSize)
        end
    elseif self.m_index == 15 then
        self:refreshQRZSView(viewSize)
    elseif self.m_index == 16 then 
        if self.current_version == 0 then
             game_util:addMoveTips({text = "活动时间已过，本功能不能开启！"})
        else  
            self:refreshhHYYQView(viewSize)
        end
    end

end

--[[--
    初始化
]]
function ui_oldplayer_pop.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        -- cclog2(self.m_tGameData,"self.m_tGameDataself.m_tGameDataself.m_tGameDataself.m_tGameData")
        if self.m_tGameData.is_caller then
            self.is_caller = true
        else
            self.is_caller = false
        end
        if self.m_tGameData.is_king then
            self.is_king = true
        else
            self.is_king = false
        end
    else
        self.m_tGameData = {};
    end
    self.sliced_coin_dict = self.m_tGameData.sliced_coin_dict;
    self.history_coin = self.m_tGameData.history_coin;
    self.received_reward_dayNum = self.m_tGameData.received_seven_reward
    self.received_coin_dayNum = self.m_tGameData.received_coin_reward
    self.m_root_layer = nil;
    self.m_btn_tab = {};
    self.content = nil;
    self.m_index = 11;
    self.first_flag = true;
    self.recall_seven_tabel = {};
    self.now_days = self.m_tGameData.seven_reward_avail;
    self.now_days_coin = self.m_tGameData.coin_reward_avail;
    self.login_reward_avail = self.m_tGameData.login_reward_avail;
    self.recall_package_avail = self.m_tGameData.recall_package_avail;
    self.friend_commission_avail = self.m_tGameData.friend_commission_avail;
    self.caller = self.m_tGameData.caller;
    self.task_num = 0;
    self.guang_guang = {};
    self.current_version = self.m_tGameData.current_version
end

--[[--
    创建ui入口并初始化数据
]]
function ui_oldplayer_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return ui_oldplayer_pop;