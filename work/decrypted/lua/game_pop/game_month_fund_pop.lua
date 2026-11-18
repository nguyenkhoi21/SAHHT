--月初福利基金
local game_month_fund_pop={
	m_tGameData=nil,
    m_jindutiaoBg_sp=nil,
    m_root_layer=nil,
    day_reward_selected=nil,
    level1Text=nil,
    level2Text=nil,
    level3Text=nil,
    level_buy=nil,
    level_selected=nil,
    m_coin_lab=nil,
    m_time_node=nil,
    m_charge_per_lab=nil,
    m_level1_lab=nil,
    m_level2_lab=nil,
    m_level3_lab=nil,
    m_tips_lab=nil,
    m_detail_btn=nil,
    m_save_btn=nil,
    m_get_btn=nil,
    m_pay_btn=nil,
    m_geted_node=nil,
    m_progress_sp=nil,
    m_ligth_sp=nil,
    m_back_btn=nil,
    m_btn_node=nil,
    m_reward_node=nil,
    m_day_reward_btn_tab=nil,
    m_level_btn_tab=nil,
    mAnimNode=nil,
    m_need_coin=nil,
    m_recharge_coin=nil,
    m_count_node=nil,
    level_text=nil,
    reward_show=nil,
    m_active_id=nil,


};

--[[--
    销毁ui
]]
function game_month_fund_pop.destroy(self)
    -- body
    cclog("-----------------game_month_fund_pop destroy-----------------");
    self.m_tGameData=nil;
    self.m_jindutiaoBg_sp=nil;
    self.m_root_layer=nil;
    self.day_reward_selected=nil;
    self.level1Text=nil;
    self.level2Text=nil;
    self.level3Text=nil;
    self.level_buy=nil;
    self.level_selected=nil;
    self.m_coin_lab=nil;
    self.m_time_node=nil;
    self.m_charge_per_lab=nil;
    self.m_level1_lab=nil;
    self.m_level2_lab=nil;
    self.m_level3_lab=nil;
    self.m_tips_lab=nil;
    self.m_detail_btn=nil;
    self.m_save_btn=nil;
    self.m_get_btn=nil;
    self.m_pay_btn=nil;
    self.m_geted_node=nil;
    self.m_progress_sp=nil;
    self.m_ligth_sp=nil;
    self.m_back_btn=nil;
    self.m_btn_node=nil;
    self.m_reward_node=nil;
    self.m_day_reward_btn_tab=nil;
    self.m_level_btn_tab=nil;
    self.mAnimNode=nil;
    self.m_need_coin=nil;
    self.m_recharge_coin=nil;
    self.m_count_node=nil;
    self.level_text=nil;
    self.reward_show=nil;
     self.m_active_id=nil;
end


function game_month_fund_pop.back(self)

	game_scene:enterGameUi("game_main_scene");
end


function game_month_fund_pop.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/month_fund.plist");
    local ccbNode=luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode=tolua.cast(target,"CCNode");
        local btnTag=tagNode:getTag();
        if btnTag==1 then
            self:back();
        elseif btnTag ==2 then --存储
            local params={};
            params.level1=self.level1Text; 
            params.level2=self.level2Text;
            params.level3=self.level3Text;
           

            game_scene:addPop("game_month_fund_save_pop",{gameData=params,version=self.m_tGameData.version,coin=self.m_tGameData.coin,level_buy=self.level_buy,active_tab=self.m_active_tab});--参数的传入！

        elseif btnTag ==3 then --领取
            if self.level_buy ~="0" then
                local function responseMethod(tag,gameData)
                     self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                  
                    local reward=self.m_tGameData.reward;
            
                    game_util:rewardTipsByDataTable(reward);
                    self:refreshUi2();

                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("month_foundation_withdraw"), http_request_method.GET, {id= self.m_active_id },"month_foundation_withdraw")
            else
                game_util:addMoveTips({text = "Chưa mua Quỹ!"});

            end

        elseif btnTag ==4 then --detail
            local foundation_cfg = getConfig(game_config_field.month_foundation);
            local itemCfg = foundation_cfg:getNodeAt(0);
            local des = itemCfg:getNodeWithKey("notice"):toStr()
            game_scene:addPop("game_active_limit_detail_pop",{openMsg = des});
        elseif btnTag ==5 then --购买
           -- game_scene:addPop("ui_vip_show_pop",{openType = "game_month_fund_pop"});
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        
        elseif btnTag >=101 and btnTag <=104 then --N日奖励101-104
            --选中效果
            self:setBtnLight(btnTag);
            
            if btnTag==101 then
                 self.day_reward_selected="1";
            elseif btnTag==102 then
                self.day_reward_selected="4"; --方便取对应奖励
            elseif btnTag==103 then
                self.day_reward_selected="7";
            elseif btnTag==104 then
                self.day_reward_selected="10";
            end
            
            --local level=self.level_selected or "1";
            self.level_selected=self.level_selected or "1";
            self:refreshRewards(self.level_selected,self.day_reward_selected);
           

        elseif btnTag >=201 and btnTag<=203 then --X级基金 201-203
            --设置亮光
            self:setBtnLight2(btnTag);
            
            self.level_selected=tostring(btnTag-200);
            --local day=self.day_reward_selected or "1";
            self.day_reward_selected =self.day_reward_selected or "1";
            self:refreshRewards(self.level_selected,self.day_reward_selected);
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_month_fund.ccbi");

    self.m_coin_lab=ccbNode:labelTTFForName("coin_lab"); --钻石
    self.m_time_node=ccbNode:nodeForName("time_node"); --倒计时

    self.m_charge_per_lab=ccbNode:labelTTFForName("charge_per_lab"); --进度条提示
   

    self.m_level1_lab=ccbNode:labelTTFForName("level1_lab") ;--返利提示
    self.m_level2_lab=ccbNode:labelTTFForName("level2_lab");
    self.m_level3_lab=ccbNode:labelTTFForName("level3_lab");
    self.m_tips_lab=ccbNode:labelTTFForName("tips_lab"); --提示

    self.m_detail_btn=ccbNode:controlButtonForName("detail_btn");
    self.m_detail_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2);
    self.m_save_btn=ccbNode:controlButtonForName("save_btn");
    self.m_save_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2);
    self.m_get_btn=ccbNode:controlButtonForName("get_btn");
    self.m_get_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2);
    self.m_pay_btn=ccbNode:controlButtonForName("pay_btn");
    self.m_pay_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2);

    self.m_count_node=ccbNode:labelTTFForName("count_node");


  
   
    self.level1Text=tostring(string.format("%.1f", self.level_text[1])) or "1.2";
    self.m_level1_lab:setString(self.level1Text);

    self.level2Text=tostring(string.format("%.1f", self.level_text[2]))  or "1.5";
    self.m_level2_lab:setString(self.level2Text);

    self.level3Text=tostring(string.format("%.1f", self.level_text[3]))  or "2";
    self.m_level3_lab:setString(self.level3Text);

    self.m_geted_node=ccbNode:nodeForName("geted_node");
    self.m_geted_node:setVisible(false);


    self.m_progress_sp=ccbNode:spriteForName("progress_sp"); --进度条
    self.m_ligth_sp=ccbNode:spriteForName("light_sp");
    self.m_back_btn=ccbNode:controlButtonForName("back_btn");
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2);
    self.m_btn_node=ccbNode:nodeForName("btn_node");
    self.m_reward_node={};
    self.m_day_reward_btn_tab={};
    self.m_level_btn_tab={};
    for i=1,4 do
        self.m_reward_node[i]=ccbNode:nodeForName("reward_node"..i);
        self.m_day_reward_btn_tab[i]=ccbNode:controlButtonForName("day_reward_btn_"..i);
        self.m_day_reward_btn_tab[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2);
    end
    
    for i=1,3 do 
        self.m_level_btn_tab[i]=ccbNode:controlButtonForName("level_btn_"..i);
        self.m_level_btn_tab[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2);
    end

    
    

    --选中动画
    local function onAnimSectionEnd( animNode, theId,theLabelName )
         animNode:playSection(theLabelName);
    end
    self.mAnimNode= game_util:createBlenderAnim("anniuguang",1,true);  --混合高光动画
       self.mAnimNode:registerScriptTapHandler(onAnimSectionEnd);
    --self.mAnimNode = game_util:createUniversalAnim({animFile = "anniuguang",actionName = "impact",loopFlag = true});
    if self.mAnimNode then
        self.mAnimNode:playSection("impact");
        local pX,pY = self.m_day_reward_btn_tab[1]:getPosition(); --默认显示第1天
        self.mAnimNode:setPosition(ccp(pX, pY))
        self.m_btn_node:addChild(self.mAnimNode,999);
    end




    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    self.m_root_layer:setTouchEnabled(true);


    return ccbNode;


end

--点击按钮的颜色设置
function game_month_fund_pop.setBtnColor(self,btnName,tag)
    if btnName =="m_day_reward_btn_tab" then
        for i=1,4 do
            if tag ~= i then
                self.m_day_reward_btn_tab[i]:setColor(ccc3(145,145,145));
            else
                self.m_day_reward_btn_tab[i]:setColor(ccc3(255,255,255));
            end
        end


    elseif btnName=="m_level_btn_tab" then
        for i=1,3 do
            if tag~=i then
                self.m_level_btn_tab[i]:setColor(ccc3(145,145,145));
            else
                self.m_level_btn_tab[i]:setColor(ccc3(255,255,255));
            end
        end

    end

end

--设置N天选中的效果
function game_month_fund_pop.setBtnLight(self,btnTag)
    local pX,pY = self.m_day_reward_btn_tab[btnTag-100]:getPosition();
    self.mAnimNode:setPosition(ccp(pX, pY));
    self.m_btn_node:reorderChild(self.mAnimNode,1000);
    self:setBtnColor("m_day_reward_btn_tab",btnTag-100);


end

--设置N级基金选中的效果
function game_month_fund_pop.setBtnLight2(self,btnTag)
    local px,py=self.m_level_btn_tab[btnTag-200]:getPosition();
    self.m_ligth_sp:setPosition(ccp(px,py));
    self:setBtnColor("m_level_btn_tab",btnTag-200);
end
--
function game_month_fund_pop.createBtnForDetail(self,tag,parentNode)
    if parentNode:getChildByTag(tag) then
        parentNode:removeChildByTag(tag,true);
    end

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
      
        
        local info = json.decode(self.reward_show:getNodeAt(btnTag-1):getFormatBuffer())
        
            if info then
             
                local tempType = info[1]
                if tempType == 6 then--道具
                    local itemId = info[2]
                    game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
                elseif tempType == 7 then--装备
                    local equipId = info[2]
                    local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                    game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
                elseif tempType == 5 then--卡牌
                    local cId = info[2]
                  
                    game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
                else      --- 食品
                    game_scene:addPop("game_food_info_pop",{itemData = info})
                end
            end
    end
    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
    button:setZoomOnTouchDown(false)
    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    button:setOpacity(0)
    button:setScale(0.7)
    button:setTag(tag)
    parentNode:addChild(button,11,tag);

end



--倒计时
function game_month_fund_pop.setCountdownTime(self)

    local countdownTime=self.m_tGameData.active_remain_time or 0;  

    self.m_time_node:removeAllChildrenWithCleanup(true);
    local function timeEndFunc()
        self.m_time_node:removeAllChildrenWithCleanup(true);
        self.m_count_node:setVisible(false);
        local tipsLabel=game_util:createLabelTTF({text="Đã hết giờ mua",color=ccc3(0,255,0),fontSize=12});
        local pX,pY=tipsLabel:getPosition();
        tipsLabel:setPosition(ccp(pX-10,pY));
        tipsLabel:setAnchorPoint(ccp(0.5,0.5));

        self.m_time_node:addChild(tipsLabel,10,12);
    end
    if countdownTime>0 then 
        local countdownLabel=game_util:createCountdownLabel(countdownTime,timeEndFunc,8,1);
        countdownLabel:setColor(ccc3(0,255,0));
        countdownLabel:setAnchorPoint(ccp(0.5,0.5));
        self.m_time_node:addChild(countdownLabel,10,10);
    else
        timeEndFunc();
    end
end





--刷新奖励

function game_month_fund_pop.refreshRewards(self,level,day)
    

    for i=1,4 do 
        self.m_geted_node:setVisible(false);
    end


    if  self.m_tGameData.already_taken_reward and next(self.m_tGameData.already_taken_reward) then
        table.sort(self.m_tGameData.already_taken_reward,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
        for i =1,#self.m_tGameData.already_taken_reward do
          
            if tostring(self.m_tGameData.already_taken_reward[i]) == day then
            
                self.m_geted_node:setVisible(true);
            end
        end
    end


    for i=1, 4 do 
        self.m_reward_node[i]:removeAllChildrenWithCleanup(true);
    end

   


    local foundation_cfg = getConfig(game_config_field.month_foundation);
    local tempCount = foundation_cfg:getNodeCount();
     for i=1,tempCount do
        local itemCfg = foundation_cfg:getNodeAt(i - 1)
        if itemCfg then
            if  itemCfg:getNodeWithKey("level"):toStr() == level and itemCfg:getNodeWithKey("version") and itemCfg:getNodeWithKey("version"):toInt() == self.m_tGameData.version then

   				 self.reward_show = itemCfg:getNodeWithKey("day" .. day);
   			end
   		end
   	end
    
    

    if self.reward_show:getNodeCount() > 0 then
        for i=1,4 do 
            local reward = json.decode(self.reward_show:getNodeAt(i-1):getFormatBuffer())

            local icon,name,count = game_util:getRewardByItemTable(reward)
            if icon then 
                self.m_reward_node[i]:addChild(icon);
                self.m_reward_node[i]:setScale(1.2);
                local numLab = CCLabelTTF:create("x" .. count,TYPE_FACE_TABLE.Arial_BoldMT,9)
                icon:addChild(numLab,10,10);
                local size = icon:getContentSize()
                numLab:setAnchorPoint(ccp(1,0))
                numLab:setPosition(ccp(size.width-1,1));

            end
        end
    end

   for i=1,4 do 
    --奖励物品点击详情
        self:createBtnForDetail(i,self.m_reward_node[i]);
    end

end




--进度条
function game_month_fund_pop.setProgress(self)
    local expBg=self.m_progress_sp;
    local expBgSize=expBg:getContentSize();
    local currentScore=self.m_tGameData.foundtaion_score or 0; 
    local scoreMax=self.m_tGameData.recharge_coin or 580; 
    local percentage=currentScore/scoreMax*100;
    local params={};
    params.percentage=percentage;

    params.fileName="progress_light.png"; 
    local expBarAdd=game_util:createProgressTimer(params);
    expBg:removeAllChildrenWithCleanup(true);
    expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
    expBg:addChild(expBarAdd,2,1);

end

--刷新
function game_month_fund_pop.refreshUi2(self)


--取出购买的等
     local level=nil;
    if self.m_tGameData.buyable_list[1] then

        for k,v in pairs(self.m_tGameData.buyable_list[1]) do

            self.m_active_id=k;
        end
     
        

        if self.m_active_id then 
            level=tonumber(self.m_active_id)%3;
           if level==0 then
                level=3;
            end
            
        end

    end
    
    
    if level then
        self.level_buy=tostring(level);
        for i=1,3 do
            self.m_level_btn_tab[i]:setTouchEnabled(false);
        end
            --self.m_level_btn_tab[i]:setTouchEnabled(true);
        
    end

    if self.level_buy ~="0" then
        self.level_selected=self.level_buy;
    end

    self.level_selected=self.level_selected or "1"; 
   
--按钮控制
   
    if self.m_tGameData.already_taken_reward and next(self.m_tGameData.already_taken_reward) then
        table.sort(self.m_tGameData.already_taken_reward,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
        local num=#self.m_tGameData.already_taken_reward;
        
        self.day_reward_selected=tostring(self.m_tGameData.already_taken_reward[num]);
    end

    self.day_reward_selected=self.day_reward_selected or "1";


  --充值数额提示
    local score=(self.m_recharge_coin/10)-(self.m_tGameData.foundtaion_score/10) ;
    --if score >0 then 
        self.m_charge_per_lab:setString("Nạp 580 Xu tham gia event Quỹ ngay!")
    --else 
      --  self.m_charge_per_lab:setString("充值数额已达基金开启条件！")
    --end


    --领取第N天奖励提示
    if self.level_buy ~="0" then
        if self.m_tGameData.drawable_funds then
           local m_drawable_funds=nil;
            if self.m_tGameData.drawable_funds[tostring(self.m_active_tab[1])] then
                m_drawable_funds=self.m_tGameData.drawable_funds[tostring(self.m_active_tab[1])];
            elseif self.m_tGameData.drawable_funds[tostring(self.m_active_tab[2])] then
                m_drawable_funds=self.m_tGameData.drawable_funds[tostring(self.m_active_tab[2])];
            elseif self.m_tGameData.drawable_funds[tostring(self.m_active_tab[3])] then
                m_drawable_funds=self.m_tGameData.drawable_funds[tostring(self.m_active_tab[3])];
            end
            if m_drawable_funds==nil then
                self.m_charge_per_lab:setString("")
            else
                self.m_charge_per_lab:setString("Quà ngày"..m_drawable_funds.."đang đợi!")
            end
            
        end
    end


  --钻石
    self.m_coin_lab:setString(tostring(self.m_tGameData.coin));



   self:refreshRewards(self.level_selected,self.day_reward_selected);
  
   local num="1";
   if self.day_reward_selected =="1" then
        num=1;
    elseif self.day_reward_selected=="4" then
        num=2;
    elseif self.day_reward_selected=="7" then
        num=3;
    elseif self.day_reward_selected=="10" then
        num=4;
    end

   self:setBtnLight(num+100);

   self:setBtnLight2(tonumber(self.level_selected)+200);

   self:setProgress();

   self:setCountdownTime();

 
end



--刷新
function game_month_fund_pop.refreshUi(self)





--取出购买的等
    local level=nil;
    if self.m_tGameData.buyable_list[1] then

        for k,v in pairs(self.m_tGameData.buyable_list[1]) do

            self.m_active_id=k;
        end
     
        

        if self.m_active_id then 
            level=tonumber(self.m_active_id)%3;
           if level==0 then
                level=3;
            end
            
        end

    end
    
    
    if level then
        self.level_buy=tostring(level);
        for i=1,3 do
            self.m_level_btn_tab[i]:setTouchEnabled(false);
        end
            --self.m_level_btn_tab[i]:setTouchEnabled(true);
        
    end

    if self.level_buy ~="0" then
        self.level_selected=self.level_buy;
        self.m_progress_sp:setVisible(false);--充值后进度条不可见
    end

    -- if self.m_tGameData.drawable_funds then
    --     if self.m_tGameData.drawable_funds["1"] then
    --         self.level_selected="1";
    --     elseif self.m_tGameData.drawable_funds["2"] then
    --         self.level_selected="2";
    --     elseif self.m_tGameData.drawable_funds["3"] then
    --         self.level_selected="3";
    --     end
    -- else
    --      self.level_selected="1";
    -- end

    self.level_selected=self.level_selected or "1"; 
   
--按钮控制

    local level_selected=self.m_active_tab[tonumber(self.level_selected)];
    if self.m_tGameData.drawable_funds then
        if self.m_tGameData.drawable_funds[tostring(level_selected)] then
            self.day_reward_selected=tostring(self.m_tGameData.drawable_funds[tostring(level_selected)]);
        end
    end

    self.day_reward_selected=self.day_reward_selected or "1";



    --钻石
    self.m_coin_lab:setString(tostring(self.m_tGameData.coin));

    --充值数额提示

    local score=(self.m_recharge_coin/10)-(self.m_tGameData.foundtaion_score/10) ;
    --if score >0 then 
        self.m_charge_per_lab:setString("Nạp 1500 Xu tham gia event Quỹ ngay!")
    --else 
        --self.m_charge_per_lab:setString("充值数额已达基金开启条件！")
    --end
     --领取第N天奖励提示
    if self.level_buy ~="0" then
        if self.m_tGameData.drawable_funds then
            local m_drawable_funds=nil;
            if self.m_tGameData.drawable_funds[tostring(self.m_active_tab[1])] then
                m_drawable_funds=self.m_tGameData.drawable_funds[tostring(self.m_active_tab[1])];
            elseif self.m_tGameData.drawable_funds[tostring(self.m_active_tab[2])] then
                m_drawable_funds=self.m_tGameData.drawable_funds[tostring(self.m_active_tab[2])];
            elseif self.m_tGameData.drawable_funds[tostring(self.m_active_tab[3])] then
                m_drawable_funds=self.m_tGameData.drawable_funds[tostring(self.m_active_tab[3])];
            end
            if m_drawable_funds==nil then
                self.m_charge_per_lab:setString("")
            end
            if m_drawable_funds==nil then
                self.m_charge_per_lab:setString("")
            else
                self.m_charge_per_lab:setString("Quà ngày"..m_drawable_funds.."đang đợi!")
            end            
        end
    end


    

   self:refreshRewards(self.level_selected,self.day_reward_selected);
  

   --设置N级的亮光
   -- self:setBtnColor("m_day_reward_btn_tab",self.day_reward_selected);

   -- self:setBtnColor("m_level_btn_tab",self.day_reward_selected);
   local num="1";
   if self.day_reward_selected =="1" then
        num=1;
    elseif self.day_reward_selected=="4" then
        num=2;
    elseif self.day_reward_selected=="7" then
        num=3;
    elseif self.day_reward_selected=="10" then
        num=4;
    end

   self:setBtnLight(num+100);

   self:setBtnLight2(tonumber(self.level_selected)+200);

   self:setProgress();

   self:setCountdownTime();

   
 
end


function game_month_fund_pop.init(self,t_params)
	t_params=t_params or {};
    self.m_screenShoot = t_params.screenShoot;
	if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
    else
        self.m_tGameData = t_params.gameData or  {};
    end
  
    
	

    self.m_need_coin={};
    self.level_buy="0";
    self.level_text={};
    self.m_active_tab={};

    local foundation_cfg = getConfig(game_config_field.month_foundation)  --获取配置
    local tempCount = foundation_cfg:getNodeCount();

     for i=1,tempCount do
        local itemCfg = foundation_cfg:getNodeAt(i - 1)
        if itemCfg then
            if itemCfg:getNodeWithKey("version") and itemCfg:getNodeWithKey("version"):toInt() == self.m_tGameData.version then
                table.insert(self.m_active_tab,i);  
                

                local need_coin = itemCfg:getNodeWithKey("need_coin"):toInt();
                table.insert(self.m_need_coin,need_coin);

                if itemCfg:getNodeWithKey("recharge_coin") then
                 	self.m_recharge_coin=itemCfg:getNodeWithKey("recharge_coin"):toInt();
                end

                if itemCfg:getNodeWithKey("times")  then
                	local text=itemCfg:getNodeWithKey("times"):toFloat();

                	table.insert(self.level_text,text);
                end
            end
        end
    end
    table.sort(self.m_need_coin,function(data1,data2) return tonumber(data1) < tonumber(data2) end)

    table.sort(self.level_text,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
    table.sort(self.m_active_tab,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
   self.m_recharge_coin=self.m_recharge_coin or 58;



end


function game_month_fund_pop.create(self,t_params)
	 self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi(true);
    return  m_popUi;
end
return game_month_fund_pop;