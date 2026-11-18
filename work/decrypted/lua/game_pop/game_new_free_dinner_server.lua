
--- 活动详细

local game_new_free_dinner_server = {
    m_tGameData=nil,
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,

     m_info_node=nil,
    m_number=nil,
    m_rank=nil,
    m_reward_rank=nil,
    m_need_number=nil,
    m_left_number=nil,
    m_message=nil,
   
   m_freetype=nil,--免费类型   0是霸王餐，1是霸王餐PLUS
   m_isnow=nil,--本期参与  0 本期参与人 1是往期参与人
   m_activeType=nil,
   m_bar_bg =nil,
   currantnamelist="",
   currant_name_list={},
   all_lucky_dict={},
   allluckydict="",
   m_pay_client=nil,
   m_layer_reward = nil,
   text_scroll = nil,
   content_node = nil,
   m_version=nil,
   };
--[[--
    销毁
]]
function game_new_free_dinner_server.destroy(self)
    -- body
    cclog("-----------------game_new_free_dinner_server destroy-----------------");
    self.m_tGameData=nil;
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;

    self.m_info_node = nil;
    self.m_number = nil;
    self.m_rank = nil;
    self.m_reward_rank = nil;
    self.m_need_number = nil;
    self.m_left_number = nil;
    self.m_message = nil;
    self.m_freetype = nil;
    self.m_isnow = nil;
    self.m_activeType=nil;
    self.m_bar_bg =nil;
    self.currantnamelist="";
    self.currant_name_list={};
    self.all_lucky_dict={};
    self.allluckydict="";
    self.m_layer_reward = nil;
    self.m_pay_client=nil;
    self.text_scroll = nil;
    self.content_node = nil;
    self.m_version=nil;
end
--[[--
    返回
]]
function game_new_free_dinner_server.back(self,type)
    -- if self.callBackFunc then
    --     self:callBackFunc()
    -- end
    game_scene:removePopByName("game_new_free_dinner_server");
    --  -- function shopOpenResponseMethod(tag,gameData)
    --         game_scene:enterGameUi("game_free_dinner")
    self:destroy();
    --     -- end
    --     -- network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("get_reward_gacha"), http_request_method.GET, {},"get_reward_gacha")
    -- self:destroy()
end

function game_new_free_dinner_server.createUi(self)
    self.m_freetype = 0
    local ccbNode = luaCCBNode:create();

    -- print("22222222222222222")

    local function onMainBtnClick( target,event )
        print("nazheline ")
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2  then--霸王餐 界面
            self.m_freetype = 0
            function shopOpenResponseMethod(tag,gameData)
                if gameData then
                    local data = gameData:getNodeWithKey("data")
                    self.m_tGameData = json.decode(data:getFormatBuffer())
                    self:refreshUi()
                end

                -- game_scene:addPop("game_active_limitscore_pop",{gameData = gameData})
            end
            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("server_free_dinner"), http_request_method.GET, {price = 200},"server_free_dinner")
        elseif btnTag == 3 then  --霸王餐PLUS
            self.m_freetype = 1
            -- self:refreshUi()
            function shopOpenResponseMethod(tag,gameData)
                if gameData then
                    local data = gameData:getNodeWithKey("data")
                    self.m_tGameData = json.decode(data:getFormatBuffer())
                    self:refreshUi()
                end

                -- game_scene:addPop("game_active_limitscore_pop",{gameData = gameData})
            end
            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("server_free_dinner"), http_request_method.GET, {price = 500},"server_free_dinner")
            -- self:reEnter1()     
        elseif btnTag == 4  then 
            --跳转到我的奖励界面
           -- game_scene:addPop("game_free_dinner_reward_pop")
            function shopOpenResponseMethod(tag,gameData)
                game_scene:addPop("game_free_dinner_reward_pop",{gameData = gameData})
                
                -- game_scene:addPop("game_active_limitscore_pop",{gameData = gameData})
            end
            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("server_free_dinner_my_reward"), http_request_method.GET, {},"server_free_dinner_my_reward")
            
        elseif btnTag == 5 then 
            --显示规则弹框
            game_scene:addPop("game_active_limit_detail_pop",{openType="server_free_dinner",vision=self.m_version})
            -- game_scene:addPop("game_active_limit_detail_pop",{enterType = self.dinner_cfg.notice})
        elseif btnTag == 6 then
            self.m_isnow = 0--本期参与ren
            self:refreshUi();
        elseif btnTag == 7 then 
            self.m_isnow = 1
            self:refreshUi();
        elseif btnTag == 8 then 
            -- self:checkAndPay(self.m_freetype)
            --game_scene:addPop("ui_vip_show_pop")
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        

        elseif btnTag == 10 then  --显示宝箱奖励
            if self.m_freetype ==1 then 
                self:createRewardTipsPop(self.pl_cfg, 1, self.m_box_reward)
            elseif  self.m_freetype == 0  or self.m_freetype ==nil then  --霸王餐
                self:createRewardTipsPop(self.ge_cfg, 1, self.m_box_reward)
            end

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/game_free_dinner.ccbi");


    local free_dinner_cfg=getConfig(game_config_field.server_free_dinner_pub_ios);
    self.dinner_cfg=json.decode(free_dinner_cfg:getFormatBuffer())[tostring(self.m_version)]
    self.ge_cfg=self.dinner_cfg.dinner
    self.pl_cfg=self.dinner_cfg.dinner_plus

    self.lb_remainBuyTimes = ccbNode:labelTTFForName("lb_remainBuyTimes")

    self.text_scroll = ccbNode:scrollViewForName("m_scroll_view_Secret");
    self.content_node = ccbNode:nodeForName("content_node")
    self.m_number=ccbNode:labelTTFForName("m_number")
    self.m_rank=ccbNode:labelTTFForName("m_rank")
    self.m_reward_rank=ccbNode:labelTTFForName("m_reward_rank")
    self.m_need_number=ccbNode:labelTTFForName("m_need_number")
    self.m_left_number=ccbNode:labelTTFForName("m_left_number")
    -- self.m_message=ccbNode:scrollViewForName("m_message")
    self.m_parent_node = CCNode:create()
    -- self.m_message:addChild(self.m_parent_node)
    self.m_bar_bg = ccbNode:nodeForName("m_bar_bg")
    self.m_rank_ss=ccbNode:spriteForName("m_rank_ss")
    self.m_rank_s=ccbNode:spriteForName("m_rank_s")
    self.m_node_rewardboard = ccbNode:nodeForName("m_node_rewardboard")
    -- self.m_node_rewardboard:removeAllChildrenWithCleanup(true)

    -- self.m_message:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

    self.m_close_btn=ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

    -- self.m_parent_node=ccbNode:nodeForName("m_parent_node")

    self.m_bwc=ccbNode:controlButtonForName("m_bwc")
    self.m_bwc:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

    self.m_bwc_plus=ccbNode:controlButtonForName("m_bwc_plus")
    self.m_bwc_plus:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

    self.m_my_reward=ccbNode:controlButtonForName("m_my_reward")
    self.m_my_reward:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

     self.m_regulation=ccbNode:controlButtonForName("m_regulation")
    self.m_regulation:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

     self.m_joining_now=ccbNode:controlButtonForName("m_joining_now")
    self.m_joining_now:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

     self.m_joining_pass=ccbNode:controlButtonForName("m_joining_pass")
    self.m_joining_pass:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

     self.m_join_in=ccbNode:controlButtonForName("m_join_in")
    self.m_join_in:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    
    self.m_box_reward=ccbNode:controlButtonForName("m_box_reward")
    self.m_box_reward:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_layer_reward = ccbNode:layerForName("m_layer_reward")
    self.m_box_reward:setOpacity(0)
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
     local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then

        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 1,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
function game_new_free_dinner_server.createLogs( self,logs )
    self.text_scroll:getContainer():removeAllChildrenWithCleanup(true);
    local viewSize = self.content_node:getContentSize()
    local contentText = ""
    -- local openMsg1 = logs
    -- -- local fight_times = self.dispatch_item_cfg[tostring(self.m_select_index)].fight_times
    -- local openMsg = ""
    -- local openMsg_tab = {}
    -- local length = #openMsg1
    -- for k,v in pairs(openMsg1) do
    --     openMsg = openMsg .. v .. "\n"
    -- end
    contentText = logs

    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(169,0),textAlignment = kCCTextAlignmentLeft, verticalTextAlignment = kCCVerticalTextAlignmentCenter,fontSize = 10})
    local tempSize = tempLabel:getContentSize()
    self.text_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.text_scroll:setContentSize(CCSizeMake(170,tempSize.height))
    self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.text_scroll:setDirection(kCCScrollViewDirectionVertical)
    self.text_scroll:addChild(tempLabel)
end
function game_new_free_dinner_server.closePay( self )
    if self.m_pay_client and self.m_pay_client.destroy then
        self.m_pay_client:destroy()
        self.m_pay_client = nil
    end
end
function game_new_free_dinner_server.updatePayData( self )
     function shopOpenResponseMethod(tag,gameData)
                if gameData then
                    local data = gameData:getNodeWithKey("data")
                    self.m_tGameData = json.decode(data:getFormatBuffer())
                    self:refreshUi()
                end

                -- game_scene:addPop("game_active_limitscore_pop",{gameData = gameData})
      end
            if self.m_freetype==0 then 
                network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("free_dinner"), http_request_method.GET, {price = 6},"free_dinner")
            elseif self.m_freetype==1 then 
                network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("free_dinner"), http_request_method.GET, {price = 30},"free_dinner")
            end
end
--[[
    去支付
]]
function game_new_free_dinner_server.checkAndPay( self, payType )
    local payCallBack = function ( code, msg )
        if code == "success" then
            game_util:addMoveTips({text = "Thành công"})
            self.m_buy_flag = 1

            self:updatePayData()
            game_util:closeAlertView()
        elseif code == "failed" then
            game_util:addMoveTips({text = "Thất bại"})
            game_util:closeAlertView()
        else
            game_util:addMoveTips({text = "Nếu thanh toán thành công, hãy tạo mới giao diện"})
            game_util:closeAlertView()
        end
    end 

    -- self:showRefreshTips()
    self:closePay()
    if payType == 1 then --plus 
        self.m_pay_client = game_util:buySthByChargeIndex( 8, payCallBack) --补签
    elseif  payType == 0 or payType == nil   then --普通
        self.m_pay_client = game_util:buySthByChargeIndex( 9, payCallBack) --bawangcan
    end
end
function game_new_free_dinner_server.createRewardTipsPop(self,data, reward_index,clickNode)
    -- if self.m_layer_reward then return end
    local tag = tag
    local data = data
    local reardNode = CCNode:create();
    local rewardHeight = 0;
    if data then
        local reward = data
        if reward then
            local rewardCount = game_util:getTableLen(reward) --reward:getNodeCount();
            rewardHeight = 30*rewardCount
            reardNode:setContentSize(CCSizeMake(100, rewardHeight))
            for i=1,rewardCount do
                local icon,name = game_util:getRewardByItemTable(reward[i],true);
                -- cclog("icon == " .. tostring(icon) .. " name = " .. tostring(icon))
                if icon then
                    icon:setScale(0.5);
                    icon:setPosition(ccp(30, rewardHeight - 30*(0.5 + i - 1)))
                    reardNode:addChild(icon)
                end
                    -- cclog("dsnfgdsnglnwobhrij")

                if name then
                    local tempLabel = game_util:createLabelTTF({text = name,color = ccc3(250,180,0),fontSize = 10});
                    tempLabel:setPosition(ccp(80, rewardHeight - 30*(0.5 + i - 1)))
                    reardNode:addChild(tempLabel)
                end
            end
        end
    end
    local bgSpr = CCScale9Sprite:createWithSpriteFrameName("public_pop_box_back.png");
    local viewSize = CCSizeMake(130,30 + rewardHeight);
    bgSpr:setPreferredSize(viewSize);
    reardNode:setPositionY(10)
    bgSpr:addChild(reardNode)
    local arrow = CCSprite:createWithSpriteFrameName("public_pop_box_arror.png")
    local arrowSize = arrow:getContentSize();
    arrow:setPosition(ccp(viewSize.width*0.5,0));
    arrow:setRotation(-90);
    bgSpr:addChild(arrow);
    local titleLabel = game_util:createLabelTTF({text = "Giải thưởng",color = ccc3(250,180,0),fontSize = 14});
    titleLabel:setPosition(ccp(viewSize.width*0.5, viewSize.height - 10))
    bgSpr:addChild(titleLabel)
    local px,py = clickNode:getPosition();
    local tempSize = clickNode:getContentSize();
    bgSpr:setAnchorPoint(ccp(0.5,0));
    local pos = clickNode:getParent():convertToWorldSpace(ccp(px,py+arrowSize.height));
    bgSpr:setPosition(pos);
    if reward_index == 1 then
        arrow:setPositionX(viewSize.width*0.15 - 2);
        bgSpr:setPositionX(pos.x + bgSpr:getContentSize().width * 0.4 - 2);
    end
    self.m_layer_reward = CCLayer:create();
    self.m_layer_reward:addChild(bgSpr);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            if self.m_layer_reward then
                self.m_layer_reward:removeFromParentAndCleanup(true);
                self.m_layer_reward = nil;
            end
            return true;--intercept event
        
        end
    end
    self.m_layer_reward:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-2,true);
    self.m_layer_reward:setTouchEnabled(true);
    game_scene:getPopContainer():addChild(self.m_layer_reward);
end

function game_new_free_dinner_server.refreshUi(self)
    -- print("44444444444")
    -- self.m_parent_node:removeAllChildrenWithCleanup(true)
    self.m_bwc:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_free_dinner_xuanzhong.png"),CCControlStateNormal);
    -- self.m_message:removeAllChildrenWithCleanup(false)
    self.currantnamelist=""
    self.currant_name_list={}
    self.currant_name_list=self.m_tGameData.currant_name_list
    for i,v in ipairs(self.currant_name_list) do
        for q,j in pairs(v) do
        self.currantnamelist = self.currantnamelist..q.."-"..j.."\n"
        end
    end
    
    self.allluckydict=""
    self.all_lucky_dict={}
    self.all_lucky_dict=self.m_tGameData.all_lucky_dict

     for k,v in pairs(self.all_lucky_dict) do

        for k1,v1 in pairs(v) do
                self.allluckydict=self.allluckydict..k1.."-"..v1.."\n"

        end
    end

    -- self.currantnamelist
    self.m_left_number:setString(self.m_tGameData.remain)
    -- self.m_number:setString(self.m_tGameData.npar)
    if self.m_freetype == 0 then --霸王餐

        self.m_reward_rank:setString("S")
        self.m_rank:setString("s")
        self.m_bwc:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_free_dinner_xuanzhong.png"),CCControlStateNormal);
         self.m_bwc_plus:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_free_dinner_plus_weixuan.png"),CCControlStateNormal);

        self.m_rank_s:setVisible(true)
        self.m_rank_ss:setVisible(false)
    elseif self.m_freetype == 1 then                       --霸王餐PLUS
        self.m_reward_rank:setString("SS")
        self.m_rank:setString("ss")
        self.m_bwc_plus:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_free_dinner_plus_xuanzhong.png"),CCControlStateNormal);
        self.m_bwc:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_free_dinner_weixuan.png"),CCControlStateNormal);
        self.m_rank_s:setVisible(false)
        self.m_rank_ss:setVisible(true)
    end
    --刷新剩余人次  以及进度条  
    self.m_left_number:setString(self.m_tGameData.remain)
    local tempLabel=nil
    if self.m_isnow == 1 then --往期参与
        self:createLogs(self.allluckydict)
    -- cclog("222222222")
    -- --     print("wang期参与人--------wangqicanyuren ")
    --      tempLabel = game_util:createRichLabelTTF({text = self.allluckydict,dimensions = CCSizeMake(210,0),
    --     -- textAlignment = kCCTextAlignmentLeft,
    --     verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 9})
        self.m_joining_now:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_benqicanyu_weixuan.png"),CCControlStateNormal);
        self.m_joining_pass:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_wangqi_xuanzhong.png"),CCControlStateNormal);
    else --ben期参与
        -- print("ben期参与人-------benqicanyuren ")
        -- cclog("555555555")
        self:createLogs(self.currantnamelist)
        --  tempLabel = game_util:createRichLabelTTF({text = self.currantnamelist,dimensions = CCSizeMake(210,0),verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 9})
        self.m_joining_now:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_benqicanyu_xuanzhong.png"),CCControlStateNormal);
         self.m_joining_pass:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_btn_wangqi_weixuan.png"),CCControlStateNormal);
    end  
    -- local viewSize = tempLabel:getContentSize()
    -- cclog("3333333333")
    -- cclog2(self.m_tGameData)
    -- cclog2(self.m_tGameData.all_lucky_dict,"self.m_tGameData.currant_name_list========")
    self.m_bar_bg:removeAllChildrenWithCleanup(true)
    local bar_size = self.m_bar_bg:getContentSize();
    local bar = ExtProgressTime:createWithFrameName("ui_progressbar_bg.png","ui_progressbar.png");
        -- bar:addLabelTTF(CCLabelTTF:create("0/100",TYPE_FACE_TABLE.Arial_BoldMT,10));
    self.m_bar_bg:addChild(bar,10,10);
    self.m_bar_bg:setPositionX(-195)
    bar:setMaxValue(20);
    bar:setCurValue(20 - self.m_tGameData.remain,false);

    
    -- local tempSize = tempLabel:getContentSize();
    -- cclog2(tempSize)
    -- -- self.m_message:removeAllChildrenWithCleanup(true)
    -- cclog2(self.m_message)
    -- cclog2(tempSize.height)
    -- local tempS = CCSizeMake(1,tempSize.height)
    -- cclog2(tempS)
    -- self.m_message:setContentSize(tempS)
    -- cclog2("---------------------")
    -- if tempSize.height > viewSize.height then
    --     self.m_message:setContentOffset(ccp(0, self.m_message:getContentSize().height - tempSize.height), false)
    -- end
    -- tempLabel:setPosition(ccp(65,70))

    -- self.m_parent_node:addChild(tempLabel,10,10)
    --  local function onTouch(eventType, x, y)
    --     if eventType == "began" then
    --         return true;
    --     elseif eventType == "ended" then
    --         self:back()
    --     end
    -- end
    -- self.m_message:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 2,true);

-- cclog2("------------========")
    -- self.m_parent_node:addChild(self.m_message,10,10)

    -- 刷新剩余购买次数
    local remain = self:getRemainBuyTimes()
    self.lb_remainBuyTimes:setString("Số lần mua: " .. remain)
    -- m_join_in
    self.m_join_in:setColor(remain > 0 and ccc3(255,255,255) or ccc3(100,100,100))
    self.m_join_in:setEnabled(remain > 0)
end
--[[--
    初始化
]]
function game_new_free_dinner_server.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil then
        local data = t_params.gameData:getNodeWithKey("data");

        -- local value = data:getNodeWithKey("value")
        -- self.m_tGameData = json.decode(value:getFormatBuffer()) or {};
         self.m_tGameData = json.decode(data:getFormatBuffer())
    else
        self.m_tGameData = {};
    end
    self.m_version=self.m_tGameData.version
end
--[[--
    创建ui入口并初始化数据
]]
function game_new_free_dinner_server.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_new_free_dinner_server.callBackFunc(self)
    local callBackFunc = self.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc();
    end
end

function game_new_free_dinner_server:getRemainBuyTimes()
    local times = self.m_tGameData.times or {}
    local limit = 0
    if self.m_freetype == 0 then -- 普通
        times = times.GE or 0
        limit = self.dinner_cfg.dinner_limit or 0
    elseif self.m_freetype == 1 then -- plus
        times = times.PL or 0
        limit = self.dinner_cfg.dinner_plus_limit or 0
    end
    local remain = limit - times
    if remain < 0 then
        remain = 0
    end
    return remain
end
return game_new_free_dinner_server;