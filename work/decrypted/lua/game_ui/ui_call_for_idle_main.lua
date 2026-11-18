local ui_call_for_idle_main = {
    m_tGameData=nil,
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,
    m_close_btn = nil,
     --规则说明按钮
    m_btn_rule = nil,
    --call按钮
    m_btn_call = nil,
    m_call_sp  = nil,

     --充值按钮
    m_btn_recharge = nil,
        --个人应援值
    m_own_score  = nil,
    --个人应援值进度条node
    m_progress_node1 = nil,
    --time node
    m_time_node = nil,

    --卡牌名字
    m_hero_name = nil,
    --卡牌动画node
    m_role_node  = nil,
    m_xiaohuo_node = nil,
    --偶像人气值进度条node
    m_progress_node2 = nil,
    m_progress_node_p2 = nil,

    --偶像人气值4个node
    m_discount_node = {},
    m_all_count = {},
    m_al_sp ={},
    m_all_btn ={},
    m_per_btn = {},
    m_per_sp ={},
    --个人应援值进度条

    own_node = {},
    own_count = {},
    m_own_reward ={},
    --剩余应援次数
    m_left_number  = nil,    --des
    m_des  = nil,    --今日免费应援次数
    m_today_free_num  = nil,     --今日获取应援次数
    m_today_get_num = nil,    --偶像人气值
    m_idle_all = nil,


    
   };
--[[--
    销毁
]]
function ui_call_for_idle_main.destroy(self)
    -- body
    cclog("-----------------ui_call_for_idle_main destroy-----------------");
    self.m_tGameData=nil;
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;

    --规则说明按钮
    self.m_btn_rule = nil;
    --call按钮
    self.m_btn_call = nil;
    self.m_call_sp  = nil;

     --充值按钮
    self.m_btn_recharge = nil;
    --个人应援值
    self.m_own_score  = nil;
    --个人应援值进度条node
    self.m_progress_node1 = nil;
    --time node
    self.m_time_node = nil;

    --卡牌名字
    self.m_hero_name = nil;
    --卡牌动画node
    self.m_role_node  = nil;
    self.m_xiaohuo_node = nil;
    --偶像人气值进度条node
    self.m_progress_node2 = nil;
    self.m_progress_node_p2 = nil;

    --偶像人气值4个node
    self.m_discount_node = {};
    self.m_all_count = {};
    self.m_al_sp ={};
    self.m_all_btn ={};
    self.m_per_btn = {};
    self.m_per_sp ={};
    --个人应援值进度条

    self.own_node = {};
    self.own_count = {};
    self.m_own_reward ={};
    --剩余应援次数
    self.m_left_number  = nil;
    --des
    self.m_des  = nil;
    --今日免费应援次数
    self.m_today_free_num  = nil;
     --今日获取应援次数
    self.m_today_get_num = nil;
    --偶像人气值
    self.m_idle_all = nil;


  
   
end
--[[--
    返回
]]
function ui_call_for_idle_main.back(self,type)
    game_scene:enterGameUi("game_main_scene",{gameData = nil})
    self:destroy();
end

function ui_call_for_idle_main.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog(btnTag,"btnTag")
            -- if self.m_flag ==true then 
            --     return 
            -- end
        if btnTag == 999 then
            self:back();
        elseif btnTag ==  1  then --规则说明
             game_scene:addPop("ui_call_for_idle_rules",{version = self.m_version} ) 
        elseif btnTag ==2 then --应援按钮
            local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    self.m_tGameData = json.decode(data:getFormatBuffer())
                    game_util:rewardTipsByJsonData(data:getNodeWithKey("award"))
                     --创建打call动画
                     self.m_call =true
                    
                    -- game_util:addMoveTips({text = "应援成功！"});
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("idol_festival_hit_call"), http_request_method.GET, nil,"idol_festival_hit_call")  
        elseif btnTag ==3 then --充值
            -- local function responseMethod(tag,gameData)
            --         game_scene:enterGameUi("ui_vip",{gameData = gameData});
            --         self:destroy();
            --     end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")  
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                --game_scene:addPop("ui_vip_show_pop")

            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag ==11 or btnTag ==12 or btnTag ==13 or btnTag ==14 then 
            local  id  =btnTag -11
            if id == 0 then
                return  
            end

            -- cclog2(self.m_idol_cfg["all_score_"..id],"self.m_idol_cfg-=---------")
            -- cclog2(self.m_tGameData.score_all_server,"self.m_tGameData.score_all_server-=---------")
            -- cclog2(self.m_tGameData.reward_log_all_server,"self.m_tGameData.reward_log_all_server-=---------")
            -- cclog2(self.reward_log_all_server,"sel。m_tGameData.reward_log_all_server-=---------")

            --三种情况 （1.未达到条件 2.达到条件领取。3.已领取）
            -- 第一种情况
            if self.m_tGameData.score_all_server < self.m_idol_cfg["all_score_"..id] then --未达到条件 查看奖励
                game_util:lookItemDetal(self.m_idol_cfg["all_reward_"..id][1]) 
            elseif  self.m_tGameData.score_all_server >= self.m_idol_cfg["all_score_"..id] and self.m_tGameData.reward_log_all_server[tostring(id)] ==1  then --达到条件 领取过（todo）
                game_util:addMoveTips({text = "Phần quà này đã được nhận！"});
            elseif self.m_tGameData.score_all_server >= self.m_idol_cfg["all_score_"..id] then  --达到条件未领取
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    self.m_tGameData = json.decode(data:getFormatBuffer())
                    game_util:rewardTipsByJsonData(data:getNodeWithKey("award"))
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("idol_festival_get_all_server_awardit_call"), http_request_method.GET, {type_id =id},"idol_festival_get_all_server_awardit_call")  
            end
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_call_for_idle_main.ccbi");  

    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then

        end
    end

    self.m_close_btn=ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    --规则说明按钮
    self.m_btn_rule=ccbNode:controlButtonForName("m_btn_rule")
    self.m_btn_rule:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    --call按钮
    self.m_btn_call=ccbNode:controlButtonForName("m_btn_call")
    self.m_btn_call:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    self.m_call_sp = ccbNode:spriteForName("m_call_sp")
    self.m_call_sp:setVisible(false)

     --充值按钮
    self.m_btn_recharge=ccbNode:controlButtonForName("m_btn_recharge")
    self.m_btn_recharge:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    --个人应援值
    self.m_own_score = ccbNode:labelTTFForName("m_own_score")
    --个人应援值进度条node
    self.m_progress_node1 = ccbNode:nodeForName("m_progress_node1")
    --time node
    self.m_time_node = ccbNode:nodeForName("m_time_node")
    local parent = self.m_time_node:getParent()
    local count = parent:getChildrenCount()
    local array = parent:getChildren()
    for i=1,count-1 do
        local obj = array:objectAtIndex(i)
        local node = tolua.cast(obj, "CCNode")
        local tag = node:getTag()
        if tag == -1 then
            node:setTag(10+i)
        end
        local tag = node:getTag()
        cclog(tag)
    end

    local tiem_node = parent:getChildByTag(15)
    tiem_node:setVisible(false)

    local tiem_node = parent:getChildByTag(29)
    local node = tolua.cast(tiem_node, "CCLabelTTF")
    node:setString("Nhận thêm ứng viện")
    
    -- local tiem_node = parent:getChildByTag(36)
    -- tiem_node:setVisible(false)
  
    --卡牌名字
    self.m_hero_name = ccbNode:labelTTFForName("m_hero_name")
    --卡牌动画node
    self.m_role_node = ccbNode:nodeForName("m_role_node") 
    self.m_xiaohuo_node = ccbNode:nodeForName("m_xiaohuo_node") 
    --偶像人气值进度条node
    self.m_progress_node2 = ccbNode:nodeForName("m_progress_node2")
    self.m_progress_node_p2 = ccbNode:nodeForName("m_progress_node_p2")

    --偶像人气值4个node
    self.m_discount_node = {}
    self.m_all_count = {}
    self.m_al_sp ={}
    self.m_all_btn ={}
    self.m_per_btn = {}
    self.m_per_sp ={}

    for i=1,4 do
        self.m_discount_node[i] = ccbNode:nodeForName("discount_node"..i)
        self.m_discount_node[i]:setVisible(true)
        self.m_all_count[i] = ccbNode:labelTTFForName("count_"..i)
        if i~= 1 then 
            self.m_all_count[i]:setString(self.m_idol_cfg["all_score_"..(i-1)])
        else
            self.m_all_count[i]:setString("0")

        end
        self.m_al_sp[i] =ccbNode:spriteForName("m_al_sp_"..i)
        self.m_all_btn[i] = ccbNode:controlButtonForName("m_all_btn_"..i)
        self.m_all_btn[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
        self.m_all_btn[i]:setOpacity(0)
    end

    --个人应援值进度条

    self.own_node = {}
    self.own_count = {}
    self.m_own_reward ={}
    
    for i=1,5 do
        self.own_node[i] = ccbNode:nodeForName("own_node"..i)
        self.own_count[i] = ccbNode:labelTTFForName("own_count_"..i)
        self.m_own_reward[i] = ccbNode:nodeForName("m_own_reward_"..i)
        -- self.m_own_reward[i]:setOpacity(255)
        if i ==1 then 
            self.own_count[i]:setString("0")
        -- elseif i~=5 then 
        --     self.own_node[i]:setPositionY(pY1+offsetY*(i-1))
        --     self.own_count[i]:setString(tostring(self.m_idol_cfg["personal_score_"..(i-1)]))
        else
            self.own_count[i]:setString(tostring(self.m_idol_cfg["personal_score_"..(i-1)]))
            --创建奖励
             local function onBtnCilck( event,target )
                   local tagNode = tolua.cast(target, "CCNode");
                   local btnTag = tagNode:getTag();
                    -- local itemCfg = rewardList[btnTag+1]
                    --未领取 未达到目标 奖励
                    if self.m_tGameData.all_call_score>= self.m_idol_cfg["personal_score_"..(i-1)] and   self.m_tGameData.reward_log_persion[tostring(i-1)] ~=1 then
                        local function responseMethod(tag,gameData)
                            local data = gameData:getNodeWithKey("data")
                            self.m_tGameData = json.decode(data:getFormatBuffer())
                            game_util:rewardTipsByJsonData(data:getNodeWithKey("award"))
                            self:refreshUi()
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("idol_festival_get_persion_award"), http_request_method.GET, {type_id =i-1},"idol_festival_get_persion_award")  
                    elseif  self.m_tGameData.all_call_score>= self.m_idol_cfg["personal_score_"..(i-1)]  and self.m_tGameData.reward_log_persion[tostring(i-1)] ==1 then 
                        game_util:addMoveTips({text = "Phần quà này đã được nhận！"});
                    else
                        game_util:lookItemDetal(self.m_idol_cfg["personal_reward_"..(i-1)][1])    
                    end 
                end
                local icon,name,count = game_util:getRewardByItemTable(self.m_idol_cfg["personal_reward_"..(i-1)][1])
                if icon then
                    icon:setScale(0.7)
                    icon:setAnchorPoint(ccp(0.5,0.5))
                    icon:setPosition(ccp(40,40))
                    self.m_per_sp[i-1] = icon
                    self.m_per_sp[i-1]:setColor(ccc3(255,255,255))
                    self.m_own_reward[i]:addChild(icon,10)
                    self.m_own_reward[i]:setRotation(-90)
                    self.m_own_reward[i]:setPositionX(60)

                    local txt = "x"..tostring(count)
                    local count_label = CCLabelTTF:create(txt,TYPE_FACE_TABLE.Arial_BoldMT,9)
                    count_label:setPosition(50,25)
                    self.m_own_reward[i]:addChild(count_label,10)
                end
                -- if count then 
                -- local  tempLabel = game_util:createLabelTTF({text = "x"..count,color = ccc3(255,255,255),fontSize = 8})
                -- tempLabel:setPosition(ccp(15,-15))
                -- self.m_reward_node:addChild(tempLabel,10)
                -- end
                -- if name then 
                --     local  tempLabel = game_util:createLabelTTF({text = name.."x"..count,color = ccc3(255,255,255),fontSize = 8})
                --     tempLabel:setPosition(ccp(40,15))
                --     self.m_own_reward[i]:addChild(tempLabel,10)
                -- end
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition(self.m_own_reward[i]:getContentSize().width * 0.5+40, self.m_own_reward[i]:getContentSize().height * 0.5+40)
                button:setOpacity(0)
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
                self.m_own_reward[i]:addChild(button)
                button:setTag( 100 +i)
                self.m_per_btn[i-1] =button
                self.m_per_btn[i-1]:setColor(ccc3(255,255,255))

        end
    end

    local pX1,pY1 = self.own_node[1]:getPosition();
    local pX5,pY5 = self.own_node[5]:getPosition();
    local  offsetY = (pY5 -pY1)/4
    for i=2,5 do --设置234 node 的位置Y
        self.own_node[i]:setPositionY(pY1+offsetY*(i-1))    
    end

    --剩余应援次数
    self.m_left_number = ccbNode:labelTTFForName("m_left_number")
    --des
    self.m_des = ccbNode:labelTTFForName("m_des")

    --今日免费应援次数
    self.m_today_free_num = ccbNode:labelTTFForName("m_today_free_num")
     --今日获取应援次数
    self.m_today_get_num = ccbNode:labelTTFForName("m_today_get_num")
    --偶像人气值
    self.m_idle_all =ccbNode:labelTTFForName("m_idle_all")


    -- 创建偶像动画
    local character_detail_cfg = getConfig(game_config_field.character_detail);
        local heroCfg = character_detail_cfg:getNodeWithKey(tostring(self.m_idol_cfg.show[1][2]));
        
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        local animNode = game_util:createAnimSequence3(ainmFile,0,nil,heroCfg);
        if animNode then
            animNode:setRhythm(1);
            game_anim:playSection(animNode , anim_label_name_cfg.daiji);
            animNode:setAnchorPoint(ccp(0.5,0));
            self.m_role_node:addChild(animNode);
        end
        local icon,name,count = game_util:getRewardByItemTable(self.m_idol_cfg.show[1])
        self.m_hero_name:setString("Idol--"..name)   --本期偶像
       
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 1,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
function ui_call_for_idle_main.createTimeDown( self,parentNode,time_count_down,shwoType,isclose )
    local function timeEndFunc()
       self.m_xiaohuo_node:removeAllChildrenWithCleanup(true)
       -- self.m_xiaohuo_node:setVisible(false)
        self.m_call =false
        self:refreshUi()
    end
    -- parentNode:removeAllChildrenWithCleanup(true)
    local shwoType = shwoType or 3
    local countdownLabel = game_util:createCountdownLabel(time_count_down,timeEndFunc,8, shwoType);
    countdownLabel:setColor(ccc3(174, 49, 69))
    countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    countdownLabel:setOpacity(0)
    local tempcontent = parentNode:getContentSize()
    countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.6))
    parentNode:addChild(countdownLabel,10,10) 
end
function ui_call_for_idle_main.createTimeDown1( self,parentNode,time_count_down,shwoType,isclose )
    local function timeEndFunc()
       -- self.m_xiaohuo_node:removeAllChildrenWithCleanup(true)
       -- -- self.m_xiaohuo_node:setVisible(false)
       --  self.m_call =false
       --  self:refreshUi()
    end
    parentNode:removeAllChildrenWithCleanup(true)
    local shwoType = shwoType or 3
    local countdownLabel = game_util:createCountdownLabel(time_count_down,timeEndFunc,8, 1);
    countdownLabel:setColor(ccc3(255,198,0))
    countdownLabel:setAnchorPoint(ccp(0,0.5))
    -- countdownLabel:setOpacity(0)
    local tempcontent = parentNode:getContentSize()
    countdownLabel:setPosition(ccp(tempcontent.width*0.5-40,tempcontent.height*0.5))
    parentNode:addChild(countdownLabel,10,10) 

    local time_label = CCLabelTTF:create("CD event:",TYPE_FACE_TABLE.Arial_BoldMT,11)
    time_label:setPosition(-15,8)
    time_label:setColor(ccc3(241,169,37))
    parentNode:addChild(time_label)
end
function ui_call_for_idle_main.refreshTableView(self)
    -- self.rank_node:removeAllChildrenWithCleanup(true);
    -- self.m_tableView = self:createTableView2(self.rank_node:getContentSize());
    -- self.m_tableView:setScrollBarVisible(true);
    -- self.rank_node:addChild(self.m_tableView,10,10);
end
function ui_call_for_idle_main:createBroadCastMsg1()
    self.bar1 = ExtProgressTime:createWithFrameName("ui_idle_progress21.png","ui_idle_progess_22.png");
    self.bar1:setScaleX(1.1);

    --进度条设置
    local cur = self.m_tGameData.score_all_server
    local max =self.m_idol_cfg["all_score_3"]

    cclog(cur,self.m_idol_cfg["all_score_1"])
        self.bar1:setMaxValue(max)
        self.bar1:setCurValue(cur,false);

        for i=1,4 do
            if i ==1 then  --第一个是星星
                if cur > 0 then 
                    self.m_al_sp[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_idle_light_star.png"))
                else
                    self.m_al_sp[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_idle_dark_star.png"))
                end
            else
                --点亮箱子条件
                if cur >=self.m_idol_cfg["all_score_"..(i-1)] then
                    self.m_al_sp[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_idle_gift2.png"))
                else
                    self.m_al_sp[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_idle_gift1.png"))
                end
            end
        end
    -- end
    self.bar1:setAnchorPoint(ccp(0.5,0.5))
    self.bar1:setPosition(ccp(100,8))
    self.m_progress_node2:addChild(self.bar1)

end

function ui_call_for_idle_main:createBroadCastMsg2() --个人进度条

    -- self.bar = ExtProgressTime:createWithFrameName("ui_idle_progress11.png","ui_idle_progewss12.png");
    self.bar = ExtProgressTime:createWithFrameName("ui_idle_progress21.png","ui_idle_progess_22.png");

    -- self.bar:setScaleY(1);
    self.bar:setScaleY(1);
    self.bar:setRotation(-90);
    -- if self.m_tGameData.all_count > self.m_first_fire then
    --     self.isChange = false
    --     self.bar:setMaxValue(self.m_first_fire)
    --     self.bar:setCurValue(self.m_first_fire,false); 
    -- else
    --     self.isChange = true
    self.bar:setMaxValue(self.m_idol_cfg["personal_score_4"])
    local  cur =self.m_tGameData.all_call_score
    local temp =0
    for i=1,4 do
        if self.m_idol_cfg["personal_score_"..i]<=cur then 
            temp =i 
        end
    end
    local tempcur  = 0
    if temp >=1 and temp <= 3 then
        tempcur =  temp/4 *self.m_idol_cfg["personal_score_4"] +1/4*self.m_idol_cfg["personal_score_4"] *(cur-self.m_idol_cfg["personal_score_"..(temp)])/(self.m_idol_cfg["personal_score_"..(temp+1)]-self.m_idol_cfg["personal_score_"..(temp)])
    elseif temp >3 then 
        tempcur  = self.m_idol_cfg["personal_score_4"]
    else
        tempcur =  1/4*self.m_idol_cfg["personal_score_4"] *(cur/self.m_idol_cfg["personal_score_"..(temp+1)])
    end
    self.bar:setCurValue(tempcur,false);
    -- end
    self.bar:setAnchorPoint(ccp(0.5,0.5))
    self.bar:setPosition(ccp(0,104))
    self.m_progress_node1:addChild(self.bar)

end
function ui_call_for_idle_main.refreshUi(self)      
    -- self:refreshBroadCastMsg()
    -- self:refreshTableView();
    self:createBroadCastMsg1()
    self:createBroadCastMsg2()
    self:createTimeDown1(self.m_time_node,self.m_tGameData.remain_all)
    self.m_left_number:setString("Số lần tiếp ứng:"..self.m_tGameData.reset_call_num)  --剩余应援次数
    self.m_today_free_num:setString("Số lần ứng viện free:"..tostring(self.m_idol_cfg.free_times - self.m_tGameData.free_call_num))  --今日可用免费应援次数
    self.m_today_get_num:setString("Số lần thu thập ứng viện:"..tostring(self.m_idol_cfg.limit_times - self.m_tGameData.payment_num_day)) --今日还能获取应援次数

    -- 个人应援值 和偶像人气值
    self.m_own_score:setString("Ứng viện cá nhân:"..self.m_tGameData.all_call_score)
    self.m_idle_all:setString("Điểm idol:"..self.m_tGameData.score_all_server)
    --des
    self.m_des:setString(self.m_idol_cfg.des)

    if self.m_tGameData.reset_call_num >0 then 
        self.m_call_sp:setVisible(true)
        self.m_btn_call:setOpacity(0)
    else
        self.m_call_sp:setVisible(false)
        self.m_btn_call:setOpacity(255)
    end

    for i=1,4 do
        if self.m_tGameData.all_call_score >=self.m_idol_cfg["personal_score_"..i] and self.m_tGameData.reward_log_persion[tostring(i)]~=1 then 
            self.m_per_btn[i]:removeAllChildrenWithCleanup(true)
            game_util:addTipsAnimByType(self.m_per_btn[i],103);
        end
        if self.m_tGameData.all_call_score >=self.m_idol_cfg["personal_score_"..i] and self.m_tGameData.reward_log_persion[tostring(i)]==1 then 
            self.m_per_btn[i]:removeAllChildrenWithCleanup(true)
        end
    end
    for i=1,3 do
        if  self.m_tGameData.reward_log_all_server[tostring(i)]==1 then 
            self.m_al_sp[i+1]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_idle_gift1.png"))   
        end
    end

    if self.m_call ==true then 
        self.m_call =false
        local callAnimNode  = game_util:createSortNode("glowstick.swf.sam",0,"glowstick.plist");
        game_anim:playSection(callAnimNode , "impact");
        self.m_xiaohuo_node:addChild(callAnimNode,10,10)
        self.m_xiaohuo_node:setPositionY(10)
        self.m_xiaohuo_node:setVisible(true)
        self:createTimeDown(self.m_xiaohuo_node,2.5)
    else
        self.m_xiaohuo_node:setVisible(false)
    end
    
end

--
--[[--
    初始化
]]
function ui_call_for_idle_main.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil then
        local data = t_params.gameData:getNodeWithKey("data");

        -- local value = data:getNodeWithKey("value")
        -- self.m_tGameData = json.decode(value:getFormatBuffer()) or {};
         self.m_tGameData = json.decode(data:getFormatBuffer())
    else
        self.m_tGameData = {};
    end
        self.m_call = false

    -- cclog2(self.m_tGameData,"self.m_tGameData-=-----=----------")
    -- self.m_bet_list = self.m_tGameData.bet_list
    -- cclog2(self.m_bet_list,"self.m_bet_list-=-----=----------")

    self.m_version= self.m_tGameData.version
    -- self.guessing_cfg = {}
    -- self.m_id = {}
    -- self.m_game_type ={}
    -- self.m_type = 1
    local idol_cfg  = json.decode(getConfig(game_config_field.idol):getFormatBuffer())
    self.m_idol_cfg = idol_cfg[tostring(self.m_version)]
    cclog2(self.m_idol_cfg,"self.m_idol_cfg-=------------")
    
  
end
--[[--
    创建ui入口并初始化数据
]]
function ui_call_for_idle_main.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function ui_call_for_idle_main.callBackFunc(self)
    local callBackFunc = self.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc();
    end
end

return ui_call_for_idle_main;