---  主题英雄志
local game_hero_legend = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_list_view_bg = nil, --中奖展示
    m_tGameData = nil,
    m_btn_recharge = nil, --充值
    m_btn_detail = nil,  --详情
    m_left_time_node = nil,
    m_coin_label = nil,
    m_icon_scroll_view = nil,
    m_startFlag = nil,
    -- m_active_keyTab = nil,   -- 活动id
    -- m_integral_label = nil,  --积分
    m_iconTab = nil,
    -- hero_icon = {},
    m_hero_theme = nil, --英雄主题
    m_anim_node = nil,
    anim_node = nil,
    m_ok_btn = nil,
    -- rank_node = nil,
    -- reward_table_node = nil,
    m_sort = nil, --选择倍数
    m_ranking_label = nil,--我的排行
    -- rankTable = nil,
    -- notices = nil,
    action_flag = nil,
    m_screenShoot = nil,
    m_start_btn = nil,
    m_version = nil,
    m_jindutiao_sp = nil,
    new_rocker_reward_cfg = nil,
    m_des_lab1 = nil,
    m_des_lab2 = nil,
    m_percent_lab = nil,
    -- m_refresh_lab = nil,
    m_price_lab = nil,
    -- m_change_award = nil,
    -- m_refresh_award = nil,
    m_zhuti_tab = nil,
    m_select_index = nil,
    m_rewardIcon_tab = nil,
    m_rewardIcon_node = nil,
    m_subject = nil,
    m_reward_index = nil,
    m_reward_index2 = nil,
    m_posIndex = nil,
    m_outAnim_falg = nil,
    m_is_special = nil,
    m_guangquan_node = nil,
    m_baojiFalg = nil,
    m_qi_node = nil,
    m_reward_falg = nil,
};
--[[--
    销毁ui
]]
function game_hero_legend.destroy(self)
    -- body
    cclog("----------------- game_sky_star destroy-----------------"); 
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_list_view_bg = nil;
    self.m_tGameData = nil;
    self.m_btn_recharge = nil;
    self.m_btn_detail = nil;
    self.m_left_time_node = nil;
    self.m_coin_label = nil;
    self.m_icon_scroll_view = nil;
    self.m_startFlag = nil;
    -- self.m_active_keyTab = nil;
    -- self.m_integral_label = nil;
    -- self.hero_icon = nil;
    self.m_iconTab = nil;
    self.m_hero_theme = nil;
    self.m_anim_node = nil;
    self.anim_node = nil;
    self.m_ok_btn = nil;
    -- self.rank_node = nil;
    -- self.reward_table_node = nil;
    self.m_sort = nil;
    self.m_ranking_label = nil;
    -- self.rankTable = nil;
    -- self.notices = nil;
    self.action_flag = nil;
    self.m_screenShoot = nil;
    self.m_start_btn = nil;
    self.m_version = nil;
    self.m_jindutiao_sp = nil;
    self.new_rocker_reward_cfg = nil;
    self.m_des_lab1 = nil;
    self.m_des_lab2 = nil;
    self.m_percent_lab = nil;
    self.m_price_lab = nil;
    -- self.m_change_award = nil;
    -- self.m_refresh_award = nil;
    self.m_zhuti_tab = nil;
   
    self.m_select_index = nil;
    self.m_rewardIcon_tab = nil;
    self.m_rewardIcon_node = nil;
    self.m_subject = nil;
    self.m_reward_index = nil;
    self.m_reward_index2 = nil;
    self.m_posIndex = nil;
    self.m_outAnim_falg = nil;
    self.m_is_special = nil;
    self.m_guangquan_node = nil;
    self.m_baojiFalg = nil;
    self.m_qi_node = nil;
    self.m_reward_falg = nil;
end

--[[--
    返回
]]
function game_hero_legend.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_hero_legend.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )

        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog2(btnTag,"btn === ")
        if btnTag == 1 then -- 关闭
             if self.action_flag == true and self.m_reward_falg == true then
             else
                 self:back()
             end
           
        elseif btnTag == 11 then--充值
            if self.action_flag == true and self.m_reward_falg == true then
            else
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data");
                    game_scene:enterGameUi("ui_vip",{gameData = gameData});
                    --game_scene:addPop("ui_vip_show_pop")
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
            end
           
        elseif btnTag == 12 then--查看详情
            if self.action_flag == true then
            else
                game_scene:addPop("game_active_limit_detail_pop",{enterType = "166"})
                
            end
        elseif btnTag == 101 then--启动
            function responseMethod(tag,gameData)
                if gameData and tolua.type(gameData) == "util_json" then
                    self.action_flag = true
                    self.m_reward_falg = true
                    game_util:setCCControlButtonBackground(self.m_ok_btn,"ztyxz_yaogan2.png")
                    local m_shared = 0;
                    function tick( dt )
                        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);
                        game_util:setCCControlButtonBackground(self.m_ok_btn,"ztyxz_yaogan.png")
                    end
                    m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0.5 , false)
                    if gameData ~= nil and tolua.type(gameData) == "util_json" then
                        local data = gameData:getNodeWithKey("data");
                        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                        -- self.m_is_special = self.m_tGameData.is_special
                        self.m_is_special = self.m_tGameData.is_special
                        self.m_subject = self.m_tGameData.subject
                        self:createNumberUi()
                        self:startActiveAnim()
                       if self.m_is_special == 1 then
                            self.m_baojiFalg = true
                            self.m_reward_index = self.m_tGameData.special_index
                            self:RewardAnim(self.m_posIndex)
                        else
                            self.m_baojiFalg = false
                            self.m_reward_index = self.m_tGameData.reward_index[1]
                            self:RewardAnim(self.m_posIndex)
                        end
                    else
                        self.action_flag = false
                        self.m_tGameData = {};
                    end
                    
                else
                    self.action_flag = false
                end
            end
            if self.action_flag == true and self.m_reward_falg == true then

            else
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("open_rocker_machine"), http_request_method.GET, nil,"open_rocker_machine")
            end
        elseif btnTag == 102 then -- 查看主题
            local subject = self.m_tGameData.subject
            game_scene:addPop("game_hero_legend_theme_pop",{subject = subject,version = self.m_version})
        elseif btnTag >= 201 and btnTag <= 203 then
            if self.action_flag == true  and self.m_reward_falg == true then
            else
                local index = btnTag - 200;
                self.m_select_index = index
                for i=1,3 do
                    self.m_zhuti_tab[i].m_zhuti_btn:setColor(ccc3(100,100,100))
                    self.m_zhuti_tab[i].m_zhuti_btn:setEnabled(true)
                end
                self.m_zhuti_tab[index].m_zhuti_btn:setColor(ccc3(250,250,250))
                self.m_zhuti_tab[index].m_zhuti_btn:setEnabled(false)
                self.m_guangquan_node:removeAllChildrenWithCleanup(true)
                local function responseMethod( tag,gameData )
                     if gameData and tolua.type(gameData) == "util_json" then
                        local data = gameData:getNodeWithKey("data");
                        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                        self.m_is_special = self.m_tGameData.is_special
                        self.m_subject = self.m_tGameData.subject
                        self:refreshUi(true)
                    end
            end
            local params = {}
            params.subject = index
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("rocker_machine_exchange_subject"), http_request_method.GET, params,"rocker_machine_exchange_subject")
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_legend_new.ccbi");
    self.m_left_time_node = ccbNode:nodeForName("m_left_time_node");
    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg");--展示
    self.m_coin_label = ccbNode:labelTTFForName("m_coin_label");--剩余钻石
    self.m_integral_label = ccbNode:labelTTFForName("m_integral_label");
    self.m_icon_scroll_view = ccbNode:scrollViewForName("m_icon_scroll_view"); --转轮
    self.anim_node = ccbNode:nodeForName("anim_node");
    self.m_qi_node = ccbNode:nodeForName("m_qi_node")
    self.m_mask_layer = ccbNode:layerForName("m_mask_layer");
    self.m_mask_layer:setVisible(false);
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_icon_scroll_view:setTouchEnabled(false);
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_start_btn = ccbNode:controlButtonForName("m_start_btn")
    self.m_jindutiao_sp = ccbNode:spriteForName("m_jindutiao_sp")
    self.m_des_lab1 = ccbNode:labelTTFForName("m_des_lab1")
    -- self.m_des_lab2 = ccbNode:labelTTFForName("m_des_lab2")
    self.m_percent_lab = ccbNode:labelTTFForName("m_percent_lab")
    self.m_price_lab = ccbNode:labelTTFForName("m_price_lab")
    self.m_rewardIcon_node = ccbNode:nodeForName("m_rewardIcon_node")
    self.m_guangquan_node = ccbNode:nodeForName("m_guangquan_node")
    self.m_outAnim_falg = false
    -- self.m_change_award = ccbNode:controlButtonForName("m_change_award")
    -- self.m_refresh_award = ccbNode:controlButtonForName("m_refresh_award")
    local m_icon_sp = nil
    self.m_rewardIcon_tab = {}
    for i=1,20 do
        m_icon_sp = ccbNode:spriteForName("m_icon_sp" .. i)
        self.m_rewardIcon_tab[i] = {m_icon_sp = m_icon_sp}
    end
    local m_zhuti_btn = nil
    self.m_zhuti_tab = {}
    for i=1,3 do
       m_zhuti_btn = ccbNode:controlButtonForName("m_zhuti_btn" .. i)
       self.m_zhuti_tab[i] = {m_zhuti_btn = m_zhuti_btn}
    end
    self.m_posIndex = 1;
    -- -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            return true;  
        end 
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(false);
    
    -- 本层阻止触摸传导下一层
    local function onTouch2(eventType, x, y)     
        if eventType == "began" then 
            if self.m_gachaAnimEndFlag == true then
                self.m_cardIdTab = {};
                self.m_mask_layer:setVisible(false);
                self.m_mask_layer:setTouchEnabled(false);
            end
            return true;  
        end 
    end
    self.m_mask_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-2,true);
    self.m_mask_layer:setTouchEnabled(false);
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn");
    self.m_ccbNode = ccbNode;
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    if self.m_screenShoot then
        local tempSize = m_root_layer:getContentSize();
        self.m_screenShoot:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        m_root_layer:addChild(self.m_screenShoot,-1);
    end
    -- self:createNumberUi()
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_tableView:setScrollBarVisible(true);
    self.m_list_view_bg:addChild(self.m_tableView,10,10);
    return ccbNode;
end

function game_hero_legend.createRewardIcon( self )
    self.m_rewardIcon_node:removeAllChildrenWithCleanup(true)
    local m_icon_sp = nil
    for i=1,20 do
        m_icon_sp = self.m_ccbNode:spriteForName("m_icon_sp" .. i)
        self.m_rewardIcon_tab[i] = {m_icon_sp = m_icon_sp}
    end
    local posTab = {}
    local pos = nil
    for i=1,20 do
        posX,posY = self.m_rewardIcon_tab[i].m_icon_sp:getPosition()
        posTab[i] = {posX = posX,posY = posY}
    end
    local info 
    local iconSize = self.m_rewardIcon_tab[1].m_icon_sp:getContentSize()
    local function onBtnClick( event, target  )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("press button tag is ", btnTag)
        
        local tempType = info[btnTag][1]
        if tempType == 6 then--道具
            local itemId = info[btnTag][2]
            game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
        elseif tempType == 7 then--装备
            local equipId = info[btnTag][2]
            local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
            game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
        elseif tempType == 5 then--卡牌
            local cId = info[btnTag][2]
            game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
        else                   -- 食品
            game_scene:addPop("game_food_info_pop",{itemData = info[btnTag]})
        end
    end 
    for i=1,20 do
        local icon,name,count
        if self.m_select_index then 
            -- cclog2(self.new_rocker_reward_cfg[tostring(self.m_version)],"self.new_rocker_reward_cfg[tostring(self.m_version)]")
            icon,name,count = game_util:getRewardByItemTable(self.new_rocker_reward_cfg[tostring(self.m_version)]["theme_reward" .. tostring(self.m_select_index)][i])
            info = self.new_rocker_reward_cfg[tostring(self.m_version)]["theme_reward" .. tostring(self.m_select_index)]
        else
            -- cclog2(self.new_rocker_reward_cfg[tostring(self.m_version)]["theme_reward" .. tostring(self.m_subject)][i],"self.new_rocker_reward_cfg[tostring(self.m_version)]")
            icon,name,count = game_util:getRewardByItemTable(self.new_rocker_reward_cfg[tostring(self.m_version)]["theme_reward" .. tostring(self.m_subject)][i])
            
            info = self.new_rocker_reward_cfg[tostring(self.m_version)]["theme_reward" .. tostring(self.m_subject)]
            -- cclog2(info[i],"i" .. i)
        end
        icon:setPosition(ccp(posTab[i].posX,posTab[i].posY))
        icon:setScale(0.65)

        if info[i][2] == 3102 or info[i][2] == 3103 or info[i][2] == 3104 then
            icon:removeChildByTag(1,true)
            icon:removeChildByTag(2,true)
            icon:setScale(0.85)
        else
            local countlabel = CCLabelTTF:create("x" .. tostring(count),TYPE_FACE_TABLE.Arial_BoldMT,12);
            countlabel:setPosition(iconSize.width * 1,iconSize.height * 0);
            icon:addChild(countlabel,11,11)
        end
        
        local button = game_util:createCCControlButton("public_weapon.png","",onBtnClick)
        button:setAnchorPoint(ccp(0.5,0.5))
        button:setPosition( icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5 )
        button:setOpacity(0)
        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY)
        icon:addChild(button)
        button:setTag( i )
        self.m_rewardIcon_node:addChild(icon,10,10)
    end
    
    -- body
end
function game_hero_legend.guangquanAnim( self,posIndex,iconTab,totalStep,rewardIndex,falg )
    -- cclog2(posIndex,"posIndex === ")
    self.action_flag = true

    local falg = falg or nil
    rewardIndex = rewardIndex + 1
    local rewardCount = 20
    local stepValue = 1
    local totalStep = totalStep
    local posIndex = posIndex
    local iconTab = iconTab

    local m_shared

    local m_scale9sprite_select = nil
    local iconSize = self.m_rewardIcon_tab[1].m_icon_sp:getContentSize()
    m_scale9sprite_select = CCScale9Sprite:createWithSpriteFrameName("public_light.png");
    self.m_guangquan_node:addChild(m_scale9sprite_select,9,9)
    m_scale9sprite_select:setPreferredSize(CCSizeMake(iconSize.width*1.3, iconSize.height*1.3));
    local posX,posY = self.m_rewardIcon_tab[posIndex].m_icon_sp:getPosition()
    m_scale9sprite_select:setPosition(ccp(posX,posY))

    function tick( dt )   

        -- local posX,posY = self.m_rewardIcon_tab[1].m_icon_sp:getPosition()
        -- m_scale9sprite_select:setPosition(ccp(posX,posY))
        -- self.m_rewardIcon_tab[1].m_icon_sp:addChild(m_scale9sprite_select,9,9)
        if posIndex<totalStep then
            local index = nil
            if posIndex>20 and posIndex<=40 then
                index =posIndex -20
            elseif posIndex>40 and posIndex<=60 then
                index = posIndex - 40
            elseif posIndex>60 then
                index = posIndex - 60
            else
                index = posIndex
            end

            for i=1,20 do
                if i == index then
                    local posX,posY = self.m_rewardIcon_tab[i].m_icon_sp:getPosition()
                    m_scale9sprite_select:setPosition(ccp(posX,posY))
                else

                end
            end
            posIndex = posIndex + 1;
        
        elseif posIndex == totalStep then
           
            stepValue = 2;
        else
            posIndex = posIndex + 1;
        end
        if stepValue == 2 then
            self.m_outAnim_falg = false
            self.m_posIndex = posIndex%rewardCount == 0 and rewardCount or posIndex%rewardCount;
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);
            self:refreshUi()
            -- cclog2(self.m_reward_index,"self.m_reward_index === ")
            -- self.m_rewardIcon_tab[tonumber(self.m_reward_index)].m_scale9sprite_select:setVisible(false)
            local posX,posY = self.m_rewardIcon_tab[tonumber(rewardIndex)].m_icon_sp:getPosition()
            m_scale9sprite_select:setPosition(ccp(posX,posY))
            if falg == true then
                local animArr = CCArray:create();
                local function animEndCallFunc()
                    self.action_flag = false
                    self.m_anim_node:removeAllChildrenWithCleanup(true)
                    if self.m_reward_falg == true then
                        local reward = self.m_tGameData.reward or {};
                        game_util:rewardTipsByDataTable(reward);
                        self.m_reward_falg = false
                        self.m_list_view_bg:removeAllChildrenWithCleanup(true);
                        self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
                        self.m_tableView:setScrollBarVisible(true);
                        self.m_list_view_bg:addChild(self.m_tableView,10,10);
                    end
                end
                animArr:addObject(CCDelayTime:create(1.5));
                animArr:addObject(CCCallFunc:create(animEndCallFunc));
                m_scale9sprite_select:runAction(CCSequence:create(animArr));
            end

        end
    end

    m_shared = scheduler.schedule(tick, 1/30, false)
    -- body
end
function game_hero_legend.RewardAnim( self,posIndex,falg )
    local falg = falg or nil
    local stepValue = 1
    local rewardRandom = ((self.m_reward_index or 0) + 1)

    local rewardCount = 20
    local totalStep = rewardCount*3+rewardRandom
    -- cclog2(totalStep,"totalStep ===")
    local m_shared = 0;
    local dtime = 0;
    self.m_outAnim_falg = true
    self.m_guangquan_node:removeAllChildrenWithCleanup(true)
    self:guangquanAnim(posIndex,self.m_rewardIcon_tab,totalStep,self.m_reward_index,falg)
    -- body
end
function game_hero_legend.RewardAnim2( self,posIndex,posIndex2,posIndex3,posIndex4,falg )
    local stepValue = 1
    local falg = falg or nil
    local rewardRandom1 = ((self.m_reward_index2[1] or 0) + 1)
    local rewardRandom2 = ((self.m_reward_index2[2] or 0) + 1)
    local rewardRandom3,totalStep3
    local rewardRandom4,totalStep4
   
    local rewardCount = 20
    local totalStep = rewardCount*3+rewardRandom1
    local totalStep2 = rewardCount*3+rewardRandom2
    -- cclog2(totalStep,"totalStep ===")
    local m_shared = 0;
    local dtime = 0;
    self.m_outAnim_falg = true
    self.m_guangquan_node:removeAllChildrenWithCleanup(true)
    -- cclog2(self.m_reward_index2[1],"self.m_reward_index2[1]")
    -- cclog2(self.m_reward_index2[2],"self.m_reward_index2[2]")
    self:guangquanAnim(posIndex,self.m_rewardIcon_tab,totalStep,self.m_reward_index2[1],falg)
    self:guangquanAnim(posIndex2,self.m_rewardIcon_tab,totalStep2,self.m_reward_index2[2],falg)
    if posIndex3 then
        rewardRandom3 = ((self.m_reward_index2[3] or 0) + 1)
        totalStep3 = rewardCount*3+rewardRandom3
        self:guangquanAnim(posIndex3,self.m_rewardIcon_tab,totalStep3,self.m_reward_index2[3],falg)
    end
    if posIndex4 then
        rewardRandom4 = ((self.m_reward_index2[4] or 0) + 1)
        totalStep4 = rewardCount*3+rewardRandom4
        self:guangquanAnim(posIndex4,self.m_rewardIcon_tab,totalStep4,self.m_reward_index2[4],falg)
    end


end
function game_hero_legend.createNumberUi(self)

    self.m_icon_scroll_view:getContainer():removeAllChildrenWithCleanup(true)
    local viewSize = self.m_icon_scroll_view:getViewSize();
    local itemCount = 5;
    local itemWidth = viewSize.width/itemCount
    local itemHeight = viewSize.height*13
    for i=1,itemCount do
        local numberBatchNode = CCSpriteBatchNode:create("ccbResources/ui_hero_legend_res-hd.pvr.ccz");
        numberBatchNode:setContentSize(CCSizeMake(itemWidth, itemHeight));
        for j=1,13 do
            local numberSpr = CCSprite:createWithSpriteFrameName("ztyxz_" .. j .. ".png");
            numberSpr:setPosition(ccp(itemWidth*0.5, viewSize.height*(j - 0.5)));
            numberBatchNode:addChild(numberSpr);
        end
        numberBatchNode:setPosition(ccp(itemWidth*(i - 1),0))
        numberBatchNode:setTag(i);
        self.m_icon_scroll_view:addChild(numberBatchNode);
        self.m_iconTab[i] = {itemNode = numberBatchNode,itemWidth = itemWidth,itemHeight = itemHeight,numberHeight = viewSize.height,actionFlag = false}
    end
end

--[[
    运行文字动画
]]
function game_hero_legend.runNumberAction(self,index,toNumber,delayTime,actionCallBackFunc,lastFlag)
    self.m_qi_node:setVisible(false)
    local itemCount = #self.m_iconTab;
    local itemData = self.m_iconTab[index];
    itemData.actionFlag = true;
    local pX,pY = itemData.itemNode:getPosition();
    local offsetY = itemData.numberHeight*toNumber + pY;
    local arr = CCArray:create();
    if delayTime > 0 then
        arr:addObject(CCDelayTime:create(delayTime));
    end
    if lastFlag == true then
        arr:addObject(CCEaseOut:create(CCMoveTo:create(offsetY/600,ccp(pX,-itemData.numberHeight*toNumber)),5));
    else
        arr:addObject(CCMoveTo:create(offsetY/800,ccp(pX,-itemData.numberHeight*toNumber)));
    end
    arr:addObject(CCCallFuncN:create(actionCallBackFunc));
    itemData.itemNode:runAction(CCSequence:create(arr));
end
function game_hero_legend.getNumber( self,tag )
    local num = string.byte(tag) - 64
    return num
    -- body
end

--[[
    开始数字滚动动画
]]
function game_hero_legend.startActiveAnim(self)
    if self.m_startFlag == true then
        return;
    end
    local reward = self.m_tGameData.reward or {};
    self.m_startFlag = true;
    local open_num = self.m_tGameData.open_num or {}
    local tempResult = {}
    for i=1,#open_num do
        tempResult[i] = self:getNumber(open_num[i])-1
    end
    local resultTab = tempResult
    local itemCount = #self.m_iconTab;
    local actionIndex = itemCount;
    local roundCount = 0;
    local function actionCallBackFunc( node )
        local index = node:getTag();
        local itemData = self.m_iconTab[index];
        local pX,pY = itemData.itemNode:getPosition();
        if pY <= -itemData.numberHeight*13 then
            pY = 0;
            itemData.itemNode:setPositionY(pY);
        end
        local tempItem = self.m_iconTab[index + 1]
        if (tempItem == nil and roundCount > 1) or (tempItem and tempItem.actionFlag == false) and self.m_outAnim_falg == false then--可以停止
            if -pY == resultTab[index]*itemData.numberHeight then
                itemData.actionFlag = false;
                actionIndex = actionIndex - 1;
                if actionIndex <= 0 then
                    self.m_startFlag = false;
                    self.m_root_layer:setTouchEnabled(false);
                    local m_shared = 0;
                    function tick( dt )
                        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);

                        if self.m_is_special == 1 and self.m_baojiFalg == true then
                            local function sectionEnd( animNode, theId, theLabelName )
                                local parent = animNode:getParent()
                                parent = tolua.cast(parent,"SortNode")
                                if theLabelName == "dakai" then
                                    --animNode:playSection( "daiji" )
                                    game_anim:playSection(parent,"daiji")
                                elseif theLabelName == "daiji" then
                                    --animNode:playSection( theLabelName )
                                    game_anim:playSection(parent,"daiji")
                                end
                            end
                            local z_zjrAnim = game_util:createAnimEffect("anim_baoji","anim_baoji",sectionEnd,nil,true);
                            if z_zjrAnim then
                                local tempsize = self.m_anim_node:getContentSize()
                                z_zjrAnim:setAnchorPoint(ccp(0.5,0.5));
                                z_zjrAnim:setPosition(ccp(tempsize.width*0.5,tempsize.height*0.5));
                                game_anim:playSection(z_zjrAnim,"dakai")
                                self.m_anim_node:addChild(z_zjrAnim,10,10)
                            end
                            game_util:addMoveTips({text = "Bạo kích rồi!"})
                            self.action_flag = true
                            self.m_reward_index2 = self.m_tGameData.reward_index
                            local num = #self.m_reward_index2
                             -- cclog("---------0---------")
                            if num == 2 then
                                local falg = true
                                local posIndex2 = self.m_posIndex+10
                                if posIndex2 > 20 then
                                    posIndex2 = posIndex2 -20
                                end
                                -- cclog("---------1---------")
                                self:RewardAnim2(self.m_posIndex,posIndex2,nil,nil,falg)
                                
                            elseif num == 3 then
                                 -- cclog("---------3---------")
                                local falg = true
                                local posIndex2 = self.m_posIndex+7
                                local posIndex3 = self.m_posIndex+13
                                if posIndex2 > 20 then
                                    posIndex2 = posIndex2 -20
                                end
                                if posIndex3 > 20 then
                                    posIndex3 = posIndex3 -20
                                end
                                self:RewardAnim2(self.m_posIndex,posIndex2,posIndex3,nil,falg)
                            elseif num == 4 then 
                                local falg = true
                                local posIndex2 = self.m_posIndex+5
                                local posIndex3 = self.m_posIndex+10
                                local posIndex4 = self.m_posIndex+15
                                if posIndex2 > 20 then
                                    posIndex2 = posIndex2 -20
                                end
                                if posIndex3 > 20 then
                                    posIndex3 = posIndex3 -20
                                end
                                if posIndex4 > 20 then
                                    posIndex4 = posIndex4 -20
                                end
                                self:RewardAnim2(self.m_posIndex,posIndex2,posIndex3,posIndex4,falg)
                            elseif num == 1 then
                                local falg = true
                                self.m_reward_index = self.m_tGameData.reward_index[1]
                                self:RewardAnim(self.m_posIndex,falg)
                            end
                            self.m_baojiFalg = false
                        else
                            game_util:rewardTipsByDataTable(reward);
                            self.m_reward_falg = false 
                            self.m_list_view_bg:removeAllChildrenWithCleanup(true);
                            self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
                            self.m_tableView:setScrollBarVisible(true);
                            self.m_list_view_bg:addChild(self.m_tableView,10,10);

                        end
                    end
                    m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0.5 , false)
                    self:refreshUi(false);
                end
            else
                local lastFlag = true;
                local toNumber = resultTab[index]
                local tempNumber = toNumber - 2;--
                if tempNumber < 0 then
                    if itemData.realStop == false then
                        tempNumber = 13 + tempNumber;
                        lastFlag = false;
                        toNumber = 13
                        itemData.realStop = true;
                    end
                else
                    itemData.realStop = true;
                end
                pY = -itemData.numberHeight*tempNumber;
                itemData.itemNode:setPosition(ccp(pX, pY))
                self:runNumberAction(index,toNumber,0,actionCallBackFunc,lastFlag); 
            end
        else
            self:runNumberAction(index,13,0,actionCallBackFunc,false);
            if index == itemCount then
                roundCount = roundCount + 1;
            end
        end
    end
    for index=itemCount,1,-1 do
        local itemData = self.m_iconTab[index];
        itemData.realStop = false;
        self:runNumberAction(index,13,(itemCount - index)*0.1,actionCallBackFunc,false);
        if index == itemCount then
            roundCount = roundCount + 1;
        end
    end
end
function game_hero_legend.setProgress( self )
    local expBg = self.m_jindutiao_sp
    local expBgSize = expBg:getContentSize(); 
    local current_score = self.m_tGameData.score or 0
    local score_max =   self.new_rocker_reward_cfg[tostring(self.m_version)].score_max or 10000
    self.m_percent_lab:setString(current_score .. "/" .. score_max)
    local percentage = current_score/score_max * 100 
    if percentage == 100 then
        self.m_des_lab1:setString(self.new_rocker_reward_cfg[tostring(self.m_version)].des2)
        self.m_des_lab1:setColor(ccc3(1,233,1))
    else
        self.m_des_lab1:setString(self.new_rocker_reward_cfg[tostring(self.m_version)].des1)
        self.m_des_lab1:setColor(ccc3(255,255,255))
    end
    local params = {}
    params.percentage = percentage
    params.fileName = "ztyxz_jindutiao.png"
    local expBarAdd = game_util:createProgressTimer(params)
    expBg:removeAllChildrenWithCleanup(true)
    expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
    expBg:addChild(expBarAdd,2,1);
end
--[[--
    创建列表 获奖人
]]
function game_hero_legend.createTableView(self,viewSize)
    self.notices = self.m_tGameData.new_rocker_log or {};
    -- cclog2(notices,"notices=======")
    local tabCount = #self.notices
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tabCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local tempNode = CCNode:create();
            cell:addChild(tempNode,10,10);
            local public_line = CCScale9Sprite:createWithSpriteFrameName("public_line.png");
            public_line:setColor(ccc3(0, 0, 0));
            public_line:setPosition(ccp(itemSize.width*0.5, 0))
            public_line:setPreferredSize(CCSizeMake(itemSize.width*0.9, 1));
            cell:addChild(public_line);
        end
        if cell then
            local itemData = self.notices[index + 1] or {}
            local tempNode = cell:getChildByTag(10)
            tempNode:removeAllChildrenWithCleanup(true);
            local richLabel = game_util:createRichLabelTTF({text = itemData,dimensions = itemSize,textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 8})
            richLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
            tempNode:addChild(richLabel);
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
function game_hero_legend.refreshUi(self,falg)
    self.m_coin_label:setString(self.m_tGameData.own_coin)
    self:setProgress()
    self.m_des_lab1:setString(self.new_rocker_reward_cfg[tostring(self.m_version)].des1)
    -- self.m_des_lab2:setString(self.new_rocker_reward_cfg[tostring(self.m_version)].des2)
    local price = self.new_rocker_reward_cfg[tostring(self.m_version)]["price_" ..  tostring(self.m_subject)]
    self.m_price_lab:setString(tostring(price))
    -- -- cclog2(self.m_subject,"self.m_subject ==")
    -- cclog2(self.m_version,"self.m_version === ")
    -- cclog2(price,"price ==== ")
   
   self.m_left_time_node:removeAllChildrenWithCleanup(true)
   local function timeEndFunc()
      self.m_left_time_node:removeAllChildrenWithCleanup(true)
      local tipsLabel = game_util:createLabelTTF({text = "Đã kết thúc",color = ccc3(255,255,255),fontSize = 10});
       tipsLabel:setAnchorPoint(ccp(0.5,0.5))
       self.m_left_time_node:addChild(tipsLabel,10,12)
   end
   local countdownTime = self.m_tGameData.time_count_down or 0;
   if countdownTime > 0 then
       local countdownLabel = game_util:createCountdownLabel(countdownTime,timeEndFunc,8, 1);
       countdownLabel:setColor(ccc3(255, 255, 255))
       countdownLabel:setAnchorPoint(ccp(0.5,0.5))
       self.m_left_time_node:addChild(countdownLabel,10,10)
   else
       timeEndFunc();
   end
    if falg == true then
        self:createRewardIcon()
    else
    end
end


--[[--
    初始化
]]
function game_hero_legend.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_version = self.m_tGameData.version or 1
    -- cclog2(self.m_tGameData,"heor data = ")
    self.m_screenShoot = t_params.screenShoot;
    self.m_iconTab = {}
    self.new_rocker_reward_cfg = getConfig(game_config_field.new_rocker_reward)
    self.new_rocker_reward_cfg = json.decode(self.new_rocker_reward_cfg:getFormatBuffer()) or {};
    self.action_flag = false
    self.m_baojiFalg = false
    self.m_reward_falg = false
    self.m_is_special = self.m_tGameData.is_special

    -- cclog2(self.new_rocker_reward_cfg,"self.new_rocker_reward_cfg === ")

end
--[[--
    创建ui入口并初始化数据
]]
function game_hero_legend.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    if self.m_tGameData.subject then 
       self.m_subject  = self.m_tGameData.subject
        
        for i=1,3 do
            self.m_zhuti_tab[i].m_zhuti_btn:setColor(ccc3(100,100,100))
            self.m_zhuti_tab[i].m_zhuti_btn:setEnabled(true)
        end
        self.m_zhuti_tab[tonumber(self.m_subject)].m_zhuti_btn:setColor(ccc3(250,250,250))
        self.m_zhuti_tab[tonumber(self.m_subject)].m_zhuti_btn:setEnabled(false)
    end
    self:refreshUi(true);
    -- self:createColorLayer();
    return scene;
end
return game_hero_legend;
