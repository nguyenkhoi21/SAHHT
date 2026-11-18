--- 活动详细

local game_golden_eggs = {
    m_tGameData=nil,
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,

    m_types = nil, -- 1是 金蛋  2是  彩蛋

    m_egg = {},
    m_chuizi1 = {},
    m_btn_egg = {},
    m_btn_caidan = nil,
    m_btn_jindan = nil,
    m_xiangqing = nil,
    m_chongzhi = nil,
    m_refresh = nil,
    m_zuanshi = nil,
    m_leishenchui = nil,
    m_look_reward = nil,
    m_reward = nil,
    m_progress_bar = nil,
    text_scroll1 = nil,
    content_node1 = nil,
    m_num_leishenchui = nil,
    m_num_zuanshi = nil,
    m_select = nil,
    m_scroll_text = nil,
    m_label_name1 = nil,
    m_label_name2 = nil,
    m_label_name3 = nil,
    m_label_name4 = nil,
    m_label_name5 = nil,

    m_version=  nil ,
    m_anim ={},
    m_label_node = nil,
    m_flag = nil,
    m_refresh_num = nil,
   };
--[[--
    销毁
]]
function game_golden_eggs.destroy(self)
    -- body
    cclog("-----------------game_golden_eggs destroy-----------------");
    self.m_tGameData=nil;
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;

    self.m_types = nil;    

    self.m_egg = {};
    self.m_chuizi1 = {};
    self.m_btn_egg = {};
    self.m_btn_caidan = nil;
    self.m_btn_jindan = nil;
    self.m_xiangqing = nil;
    self.m_chongzhi = nil;
    self.m_refresh = nil;
    self.m_zuanshi = nil;
    self.m_leishenchui = nil;
    self.m_look_reward = nil;
    self.m_reward = nil;
    self.m_progress_bar = nil;
    self.text_scroll1 = nil;
    self.content_node1 = nil;
    self.m_num_leishenchui = nil;
    self.m_num_zuanshi = nil;
    self.m_select = nil;
    self.m_scroll_text = nil;
    self.m_label_name1 = nil;
    self.m_label_name2 = nil;
    self.m_label_name3 = nil;
    self.m_label_name4 = nil;
    self.m_label_name5 = nil;
    self.m_version=  nil;
    self.m_anim = {};
    self.m_label_node = nil;
    self.m_flag = nil;
    self.m_refresh_num = nil;
end
--[[--
    返回
]]
function game_golden_eggs.back(self,type)
    game_scene:removePopByName("game_golden_eggs");
    self:destroy();
end

function game_golden_eggs.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
            if self.m_flag ==true then 
                return 
            end
        if btnTag == 999 then
            self:back();
        elseif btnTag == 1 then 
            --金蛋变成选中色  （默认金蛋）

            self.m_btn_jindan:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_golden_eggs_btn_jindan1.png"),CCControlStateNormal);
            self.m_btn_caidan:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_golden_eggs_btn_candan2.png"),CCControlStateNormal);
            self.m_types = 1 
            self:refreshUi();
        elseif btnTag == 2  then --彩蛋
            --彩蛋变成选中色。
            self.m_btn_caidan:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_golden_eggs_btn_caidan1.png"),CCControlStateNormal);
            self.m_btn_jindan:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_golden_eggs_btn_jindan2.png"),CCControlStateNormal);
            self.m_types = 2 
            self:refreshUi();

        elseif btnTag ==3 then  --预览
             game_scene:addPop("game_golden_eggs_pop",{typepop = 1,gameData = self.m_tGameData,eggtype = self.m_types,version = self.m_version}) 
        elseif btnTag == 4 then    --活动详情
             game_scene:addPop("game_golden_eggs_pop",{typepop = 2,gameData = self.m_tGameData,eggtype = self.m_types,version = self.m_version}) 
        elseif btnTag ==5 then  --充值
            local function responseMethod(tag,gameData)
                 local data = gameData:getNodeWithKey("data");
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                --game_scene:addPop("ui_vip_show_pop")
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag ==6  then  --刷新
            function responseMethod(tag,gameData )
                    -- body
                if gameData then
                    local data = gameData:getNodeWithKey("data")
                    self.m_tGameData = json.decode(data:getFormatBuffer())
                    if self.m_tGameData.reward_log[1] ~= nil then
                        game_util:createScrollViewTips(self.m_scroll_text,self.m_tGameData.reward_log,true,3,ccc3(100,200,100))
                    end
                end
                    self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("refresh_egg"), http_request_method.GET, {egg_type = self.m_types},"refresh_egg")
        
        elseif btnTag ==7 then  --钻石砸蛋 
            if self.m_select == 100 then 
                    game_util:addMoveTips({text = "Bạn chưa chọn trứng"});
                return  
            end
            if self.m_tGameData.egg_diamond.egg_sort_used_diamond == self.m_select  and self.m_types == 1 then 
                game_util:addMoveTips({text = "Trứng này đã bị đập!"});
                return   --重复不会被砸
            end
            if self.m_tGameData.egg_item.egg_sort_used_item == self.m_select  and self.m_types == 2 then 
                game_util:addMoveTips({text = "Trứng này đã bị đập!"});
                return   --重复不会被砸
            end
            if self.m_flag == true then 
                game_util:addMoveTips({text = "Bạn đang đập trứng!"});
                return   --正在砸蛋
            end
                function responseMethod(tag,gameData )
                    -- body
                    if gameData then
                        local data = gameData:getNodeWithKey("data")
                        self.m_tGameData = json.decode(data:getFormatBuffer())
                        game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"))
                        if self.m_tGameData.reward_log[1]  ~= nil then
                            game_util:createScrollViewTips(self.m_scroll_text,self.m_tGameData.reward_log,true,3,ccc3(100,200,100))
                        end
                        -- game_util:createScrollViewTips(self.m_scroll_view_tips,"aaaaaaa",true,3,ccc3(100,200,100))

                        -- cclog2(self.m_tGameData,"self.m_tGameData.reward-=----------"
                        local  mAnimNode = {}
                        if mAnimNode[self.m_select] ~=nil then 
                            mAnimNode[self.m_select]:removeAllChildrenWithCleanup(true)
                        end
                        self.m_anim[self.m_select]:removeAllChildrenWithCleanup(true)
                        if self.m_types ==1  then -- 金蛋
                            mAnimNode[self.m_select] = game_util:createSortNode("zadan_jin.swf.sam",0,"zadan_jin.plist");
                            game_anim:playSection(mAnimNode[self.m_select] , "impact1");
                            self.m_anim[self.m_select]:addChild(mAnimNode[self.m_select],10,10)

                        elseif  self.m_types ==2 then  --彩蛋
                            mAnimNode[self.m_select] = game_util:createSortNode("zadan_cai.swf.sam",0,"zadan_cai.plist");
                            game_anim:playSection(mAnimNode[self.m_select] , "impact1");
                            self.m_anim[self.m_select]:addChild(mAnimNode[self.m_select],10,10)
                        end
                        for i=1,3 do  ---初始
                            -- self.m_egg[i]:setColor(ccc3(255,255,255))
                            self.m_chuizi1[i]:setVisible(false)
                        end
                        self.m_flag = true
                        self:createTimeDown(self.m_label_node,3)
                        end
                    
                end
                
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("open_egg"), http_request_method.GET, {egg_type = self.m_types,is_super = 0,egg_sort = self.m_select},"open_egg")
        elseif btnTag ==8 then  --雷神锤砸蛋  
            -- if self.m_tGameData.egg_item.egg_sort_used_item == self.m_select  or self.m_tGameData.egg_item.egg_sort_used_item == self.m_select then 
            --     if  self.m_tGameData.refresh_flog ~= 0  then 
            --         game_util:addMoveTips({text = "该蛋已经被砸！"});
            --         return   --重复不会被砸
            --     end
            -- end
            -- -- self:createLogs(self.text_scroll1,self.content_node1,"您用钻石砸了一次蛋")
            if self.m_flag == true then 
                game_util:addMoveTips({text = "Bạn đang đập trứng!"});
                return   --正在砸蛋
            end
            function responseMethod(tag,gameData )
                    -- body
                if gameData then
                    local data = gameData:getNodeWithKey("data")
                    self.m_tGameData = json.decode(data:getFormatBuffer())
                    game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"))
                    if self.m_tGameData.reward_log[1]  ~= nil then
                        game_util:createScrollViewTips(self.m_scroll_text,self.m_tGameData.reward_log,true,3,ccc3(100,200,100))
                    end

                    -- cclog2(self.m_tGameData,"self.m_tGameData.reward-=----------")
                end
                    local  mAnimNode = {}
                    self.m_flag = true
                    if self.m_types ==1  then -- 金蛋
                        for i=1,3 do
                            if mAnimNode[i] ~=nil then 
                                mAnimNode[i]:removeAllChildrenWithCleanup(true)
                            end
                            self.m_anim[i]:removeAllChildrenWithCleanup(true)
                            mAnimNode[i] = game_util:createSortNode("zadan_jin.swf.sam",0,"zadan_jin.plist");
                            game_anim:playSection(mAnimNode[i] , "impact1");
                            self.m_anim[i]:addChild(mAnimNode[i],10,10)
                        end

                    elseif  self.m_types ==2 then  --彩蛋
                        for i=1,3 do
                            if mAnimNode[i] ~=nil then 
                                mAnimNode[i]:removeAllChildrenWithCleanup(true)
                            end
                            self.m_anim[i]:removeAllChildrenWithCleanup(true)
                            mAnimNode[i] = game_util:createSortNode("zadan_cai.swf.sam",0,"zadan_cai.plist");
                            game_anim:playSection(mAnimNode[i] , "impact1");
                            self.m_anim[i]:addChild(mAnimNode[i],10,10)
                        end

                    end
                    for i=1,3 do  ---初始
                        -- self.m_egg[i]:setColor(ccc3(255,255,255))
                        self.m_chuizi1[i]:setVisible(false)
                    end
                    self:createTimeDown(self.m_label_node,3)
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("open_egg"), http_request_method.GET, {egg_type = self.m_types,is_super = 1,egg_sort = self.m_select},"open_egg")
        
        elseif btnTag == 11 then  --1号蛋
            self.m_select = 1
            self.m_chuizi1[1]:setVisible(true)
            self.m_chuizi1[2]:setVisible(false)
            self.m_chuizi1[3]:setVisible(false)
        elseif btnTag == 12 then  --2号蛋
            self.m_select = 2
            self.m_chuizi1[2]:setVisible(true)
            self.m_chuizi1[1]:setVisible(false)
            self.m_chuizi1[3]:setVisible(false)
        elseif btnTag == 13 then  --3号蛋
            self.m_select = 3
            self.m_chuizi1[3]:setVisible(true)
            self.m_chuizi1[2]:setVisible(false)
            self.m_chuizi1[1]:setVisible(false)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_golden_eggs.ccbi");  

    for i=1,3 do
        self.m_egg[i] = ccbNode:spriteForName("m_egg"..i)
        self.m_egg[i]:setVisible(false)
        self.m_chuizi1[i] = ccbNode:spriteForName("m_chuizi"..i)
        self.m_anim[i] =ccbNode:nodeForName("anim"..i)
        self.m_chuizi1[i]:setVisible(false)
        self.m_btn_egg[i] =ccbNode:controlButtonForName("m_btn_egg"..i)
        self.m_btn_egg[i]:setOpacity(0)
        self.m_btn_egg[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    end

    
    -- local anim1 = game_util:createEffectAnim("zadan_jin",1,false)
            -- self.m_anim[1]:addChild(anim1,10,10)
    -- local  mAnimNode = game_util:createSortNode("zadan_jin.swf.sam",0,"zadan_jin.plist");
    -- game_anim:playSection(mAnimNode , "impact");
    -- local  mAnimNode = {}
    -- for i=1,3 do
    --     mAnimNode[i] = game_util:createSortNode("zadan_jin.swf.sam",0,"zadan_jin.plist");
    --     game_anim:playSection(mAnimNode[i] , "impact");
    --     self.m_anim[i]:addChild(mAnimNode[i],10,10)
    -- end
    
    
        
    self.m_btn_caidan = ccbNode:controlButtonForName("m_btn_caidan")
    self.m_btn_jindan = ccbNode:controlButtonForName("m_btn_jindan")
    self.m_xiangqing = ccbNode:controlButtonForName("m_xiangqing")
    self.m_chongzhi = ccbNode:controlButtonForName("m_chongzhi")
    self.m_refresh = ccbNode:controlButtonForName("m_refresh")
    self.m_refresh_num = ccbNode:labelTTFForName("m_refresh_num")
    self.m_zuanshi = ccbNode:controlButtonForName("m_zuanshi")
    self.m_leishenchui = ccbNode:controlButtonForName("m_leishenchui")
    self.m_look_reward = ccbNode:controlButtonForName("m_look_reward")

   
    self.content_node1 = ccbNode:nodeForName("content_node1")
    self.text_scroll1 = ccbNode:scrollViewForName("m_scroll_view_Secret1");
    self.m_scroll_text = ccbNode:scrollViewForName("m_scroll_text");
    self.text_scroll1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

    self.m_reward = ccbNode:nodeForName("m_reward") --奖励icon显示
    self.m_label_node = ccbNode:nodeForName("m_label_node")
    -- cclog2(self.m_label_node,"123-=-321-=-=12-3")
    --进度条
    self.m_progress_bar = ccbNode:nodeForName("m_progress_bar")
    


    self.m_num_leishenchui = ccbNode:labelTTFForName("m_num_leishenchui")
    self.m_num_zuanshi = ccbNode:labelTTFForName("m_num_zuanshi")

    self.m_label_name1 = ccbNode:spriteForName("m_label_name1") --12 是图片。345 是 label
    self.m_label_name2 = ccbNode:spriteForName("m_label_name2")

    self.m_label_name1:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_golden_eggs_wodezuanshi.png"))
    self.m_label_name2:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_wodeleijinchui.png"))

    self.m_label_name3 = ccbNode:labelTTFForName("m_label_name3")
    self.m_label_name4 = ccbNode:labelTTFForName("m_label_name4")
    self.m_label_name5 = ccbNode:labelTTFForName("m_label_name5")

    self.m_label_name5:setString("Mỗi lần Đậpx10 đảm bảo ra Lôi Kim Chùy")

    -- self.m_num_zuanshi:setString("100000")
    -- self.m_num_leishenchui:setString("10个")

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then

        end
    end

    self.m_close_btn=ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_btn_caidan:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_btn_jindan:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_xiangqing:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_chongzhi:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_refresh:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_leishenchui:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_look_reward:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_zuanshi:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

    if self.m_tGameData.reward_log[1]  ~= nil then
        game_util:createScrollViewTips(self.m_scroll_text,self.m_tGameData.reward_log,true,3,ccc3(100,200,100))
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 1,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
-- 


function game_golden_eggs.showeggs( self )
    -- body
    
   
    for i=1,3 do  ---初始
        -- self.m_egg[i]:setColor(ccc3(255,255,255))
        self.m_chuizi1[i]:setVisible(false)
    end

    if  self.m_types == 2 then  --彩蛋界面 
        local  mAnimNode = {}
        for i=1,3 do
            if mAnimNode[i] ~=nil then 
                mAnimNode[i]:removeAllChildrenWithCleanup(true)
            end
            self.m_anim[i]:removeAllChildrenWithCleanup(true)
            mAnimNode[i] = game_util:createSortNode("zadan_cai.swf.sam",0,"zadan_cai.plist");
            game_anim:playSection(mAnimNode[i] , "impact");
            self.m_anim[i]:addChild(mAnimNode[i],10,10)
        end
            -- cclog2(self.m_tGameData.egg_item.egg_sort_used_item,"self.m_tGameData.egg_item.egg_sort_used_itemv-=--------------")
        if self.m_tGameData.egg_item.egg_sort_used_item ~=0 then 
            if mAnimNode[self.m_tGameData.egg_item.egg_sort_used_item] ~=nil then 
                mAnimNode[self.m_tGameData.egg_item.egg_sort_used_item]:removeAllChildrenWithCleanup(true)
            end
                self.m_anim[self.m_tGameData.egg_item.egg_sort_used_item]:removeAllChildrenWithCleanup(true)
                -- cclog2(self.m_tGameData.egg_item.egg_sort_used_item,"self.m_tGameData.123egg_item.egg_sort_used_itemv-=--------------")

                mAnimNode[self.m_tGameData.egg_item.egg_sort_used_item] = game_util:createSortNode("zadan_cai.swf.sam",0,"zadan_cai.plist");
                game_anim:playSection(mAnimNode[self.m_tGameData.egg_item.egg_sort_used_item] , "impact2");
            self.m_anim[self.m_tGameData.egg_item.egg_sort_used_item]:addChild(mAnimNode[self.m_tGameData.egg_item.egg_sort_used_item],10,10)
            -- -- self.m_egg[self.m_tGameData.egg_item.egg_sort_used_item]:setColor(ccc3(100,100,100))
        end

        
        for i=1,3 do
            -- self.m_chuizi1[i]:setVisible(false)
            self.m_chuizi1[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_golden_eggs_chuizi2.png"))
            -- self.m_egg[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_golden_eggs_caidan.png"))
        end
    elseif self.m_types == 1 then 
         --金蛋界面
        local  mAnimNode = {}
        for i=1,3 do
            if mAnimNode[i] ~=nil then 
                mAnimNode[i]:removeAllChildrenWithCleanup(true)
            end
            self.m_anim[i]:removeAllChildrenWithCleanup(true)
            mAnimNode[i] = game_util:createSortNode("zadan_jin.swf.sam",0,"zadan_jin.plist");
            game_anim:playSection(mAnimNode[i] , "impact");
            self.m_anim[i]:addChild(mAnimNode[i],10,10)
        end

         if self.m_tGameData.egg_diamond.egg_sort_used_diamond ~=0 then 

            if mAnimNode[self.m_tGameData.egg_item.egg_sort_used_diamond] ~=nil then 
                mAnimNode[self.m_tGameData.egg_diamond.egg_sort_used_diamond]:removeAllChildrenWithCleanup(true)
            end
            self.m_anim[self.m_tGameData.egg_diamond.egg_sort_used_diamond]:removeAllChildrenWithCleanup(true)
            mAnimNode[self.m_tGameData.egg_diamond.egg_sort_used_diamond] = game_util:createSortNode("zadan_jin.swf.sam",0,"zadan_jin.plist");
            game_anim:playSection(mAnimNode[self.m_tGameData.egg_diamond.egg_sort_used_diamond] , "impact2");

            self.m_anim[self.m_tGameData.egg_diamond.egg_sort_used_diamond]:addChild(mAnimNode[self.m_tGameData.egg_diamond.egg_sort_used_diamond],10,10)
           
        end

        
        for i=1,3 do
            
            self.m_chuizi1[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_golden_eggs_chuizi1.png"))

        end
    end
     self.m_select = 100 --选择置空
end
function game_golden_eggs.refreshUi(self)    
    self:refreshLabel()
    self:showeggs()

end

function game_golden_eggs.createTimeDown( self,parentNode,time_count_down,shwoType,isclose )
    local function timeEndFunc()
        self:refreshUi()
        self.m_flag = false
    end
    parentNode:removeAllChildrenWithCleanup(true)
    local shwoType = shwoType or 3
    local countdownLabel = game_util:createCountdownLabel(time_count_down,timeEndFunc,8, shwoType);
    countdownLabel:setColor(ccc3(74, 249, 69))
    countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    countdownLabel:setOpacity(0)
    local tempcontent = parentNode:getContentSize()
    countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.6))
    parentNode:addChild(countdownLabel,10,10) 
end
function game_golden_eggs.refreshLabel( self ) --更新标签
    -- body
    self.m_progress_bar:removeAllChildrenWithCleanup(true)
    if self.m_types ==1 then 
        self.m_num_zuanshi:setString(self.m_tGameData.egg_diamond.egg_diamond_coin)
        self.m_num_leishenchui:setString(self.m_tGameData.egg_diamond.egg_super_times_diamond)
        local bar_size = self.m_progress_bar:getContentSize();
        local bar = ExtProgressTime:createWithFrameName("ui_golden_eggs_progress2.png","ui_golden_eggs_progress1.png");
        bar:addLabelTTF(CCLabelTTF:create(self.m_tGameData.egg_diamond.egg_used_times_diamond.."/"..self.m_tGameData.egg_diamond.egg_num_diamond,TYPE_FACE_TABLE.Arial_BoldMT,12));
        self.m_progress_bar:addChild(bar,10,10);
        bar:setPositionX(-42)
        bar:setMaxValue(self.m_tGameData.egg_diamond.egg_num_diamond);
        bar:setCurValue(self.m_tGameData.egg_diamond.egg_used_times_diamond,false);
        local tempTable = self:createRewardTable(self.m_reward:getContentSize(),#self.m_tGameData.egg_diamond.reward_best_diamond,self.m_tGameData.egg_diamond.reward_best_diamond)
        self.m_reward:addChild(tempTable)
        --美术字
        self.m_label_name1:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_golden_eggs_wodezuanshi.png"))
        self.m_label_name2:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_wodeleijinchui.png"))
        --label
        self.m_label_name3:setString(self.m_tGameData.egg_diamond.cost_current_diamond)
        self.m_label_name4:setString("1")
        self.m_label_name5:setString("Mỗi lần Đậpx10 đảm bảo ra Lôi Kim Chùy")
        --按钮
        self.m_zuanshi:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_xiaohao_zuanshi.png"),CCControlStateNormal);
        self.m_leishenchui:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_xiaohao_leijinchui.png"),CCControlStateNormal);
        self.m_zuanshi:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_xiaohao_zuanshi.png"),CCControlStateHighlighted);
        self.m_leishenchui:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_xiaohao_leijinchui.png"),CCControlStateHighlighted);
        self.m_zuanshi:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_xiaohao_zuanshi.png"),CCControlStateDisabled);
        self.m_leishenchui:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_xiaohao_leijinchui.png"),CCControlStateDisabled);
            

    elseif self.m_types == 2 then  --彩蛋
        self.m_num_zuanshi:setString(self.m_tGameData.egg_item.egg_times_item)
        self.m_num_leishenchui:setString(self.m_tGameData.egg_item.egg_super_times_item)
        local bar_size = self.m_progress_bar:getContentSize();
        local bar = ExtProgressTime:createWithFrameName("ui_golden_eggs_progress2.png","ui_golden_eggs_progress1.png");
        bar:addLabelTTF(CCLabelTTF:create(self.m_tGameData.egg_item.egg_used_times_item.."/"..self.m_tGameData.egg_item.egg_num_item,TYPE_FACE_TABLE.Arial_BoldMT,12));
        self.m_progress_bar:addChild(bar,10,10);
        bar:setPositionX(-42)
        bar:setMaxValue(self.m_tGameData.egg_item.egg_num_item);
        bar:setCurValue(self.m_tGameData.egg_item.egg_used_times_item,false);
        local tempTable = self:createRewardTable(self.m_reward:getContentSize(),#self.m_tGameData.egg_item.reward_best_item,self.m_tGameData.egg_item.reward_best_item)
        self.m_reward:addChild(tempTable)
        --美术字
        self.m_label_name1:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_wodecaichui.png"))
        self.m_label_name2:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_wodeleicaichui.png"))
        --label
        self.m_label_name3:setString(self.m_tGameData.egg_item.cost_current_item)
        self.m_label_name4:setString("1")
        self.m_label_name5:setString("Mỗi lần Đậpx10 đảm bảo ra Lôi Kim Chùy")
        --按钮
        self.m_zuanshi:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_xiaohao_caichui.png"),CCControlStateNormal);
        self.m_leishenchui:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_xiaohao_leicaichui.png"),CCControlStateNormal);
        self.m_zuanshi:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_xiaohao_caichui.png"),CCControlStateHighlighted);
        self.m_leishenchui:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_xiaohao_leicaichui.png"),CCControlStateHighlighted);
        self.m_zuanshi:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_xiaohao_caichui.png"),CCControlStateDisabled);
        self.m_leishenchui:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_xiaohao_leicaichui.png"),CCControlStateDisabled);
         
    end
    
end
function game_golden_eggs.createRewardTable(self,viewSize,count,rewardList)


    -- local function onBtnCilck( event,target )
    --     local tagNode = tolua.cast(target, "CCNode");
    --     local btnTag = tagNode:getTag();
    --     local itemCfg = rewardList[btnTag+1]
    --     game_util:lookItemDetal(itemCfg)
    -- end

    self.m_reward:removeAllChildrenWithCleanup(true)

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;
    params.column = 2; --列
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-4;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5,0.5))
            node:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            local itemGift = rewardList[index+1]
            local icon,name,count = game_util:getRewardByItemTable(itemGift)
            if icon then
                icon:setScale(0.7)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,0))
                node:addChild(icon,10)
            end
            if count then 
                local  tempLabel = game_util:createLabelTTF({text = "x"..count,color = ccc3(255,255,255),fontSize = 8})
                tempLabel:setPosition(ccp(itemSize.width*0.3, itemSize.height*0.1-15))
                node:addChild(tempLabel,10)
            end

            cell:addChild(node)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)

        if eventType == "ended" and item then
            local itemCfg = rewardList[index+1]
            game_util:lookItemDetal(itemCfg)
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        
    end
    return TableViewHelper:create(params);
end
--[[--
    初始化
]]
function game_golden_eggs.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil then
        local data = t_params.gameData:getNodeWithKey("data");

        -- local value = data:getNodeWithKey("value")
        -- self.m_tGameData = json.decode(value:getFormatBuffer()) or {};
         self.m_tGameData = json.decode(data:getFormatBuffer())
    else
        self.m_tGameData = {};
    end
    -- cclog2(self.m_tGameData.reward_log,"self.m_tGameData-=----------")
    -- self.m_version=self.m_tGameData.version
    --默认是金蛋。 
    self.m_types = 1   --1是金蛋。2 是彩蛋
    self.m_select =100
    self.m_flag =false
    self.m_version=self.m_tGameData.version
end
--[[--
    创建ui入口并初始化数据
]]
function game_golden_eggs.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_golden_eggs.callBackFunc(self)
    local callBackFunc = self.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc();
    end
end

return game_golden_eggs;