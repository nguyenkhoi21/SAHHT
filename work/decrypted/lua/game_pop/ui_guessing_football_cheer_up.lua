local ui_guessing_football_cheer_up = {
    m_tGameData=nil,
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    guessing_cfg = nil,
    m_name = nil,
    m_type   = nil,
    m_choose = nil,
    m_select ={},
    m_btn_cheer_up = nil,
    m_count_value = nil,
    m_number_label = nil,

    m_btn_add = nil,
    m_btn_add10 = nil,
    m_btn_minute = nil,
    m_btn_min10 = nil,
    m_max_count = nil,

    m_double = nil,
    m_game_type ={},

    
   };
--[[--
    销毁
]]
function ui_guessing_football_cheer_up.destroy(self)
    -- body
    cclog("-----------------ui_guessing_football_cheer_up destroy-----------------");
    self.m_tGameData=nil;
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.guessing_cfg = nil;
    self.m_name = nil;
    self.m_type = nil;
    self.m_select = {};
    self.m_btn_cheer_up = nil;
    self.m_count_value = nil;
    self.m_number_label = nil;

    self.m_btn_add = nil;
    self.m_btn_add10 = nil;
    self.m_btn_minute = nil;
    self.m_btn_min10 = nil;
    self.m_max_count = nil;

    self.m_double = nil;
    self.m_game_type ={};
end
--[[--
    返回
]]
function ui_guessing_football_cheer_up.back(self,type)
    
    function shopOpenResponseMethod(tag,gameData)
        game_scene:removePopByName("ui_guessing_football_cheer_up");
        self:destroy();
        game_scene:addPop("ui_guessing_football_main",{gameData = gameData})
    end
     network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("world_cup_guess_index"), http_request_method.GET, {},"world_cup_guess_index")

end
function ui_guessing_football_cheer_up.setCount(self,addCount)
    if self.m_count_value + addCount <= self.m_max_count and self.m_count_value + addCount > 0 then
        self.m_count_value = self.m_count_value + addCount;
    elseif self.m_count_value + addCount > self.m_max_count then
        self.m_count_value = self.m_max_count;
    elseif self.m_count_value + addCount < 1 then
        self.m_count_value = 1;
    end
    -- local str = tostring(self.m_count_value*100)
    -- local str2 = tostring(self.guessing_cfg[self.m_type]["cost"]*self.m_count_value*100)
    
    -- if  self.m_count_value>= 10 then 
    --     str = (self.m_count_value/10).."k"
    -- end
    -- if self.guessing_cfg[self.m_type]["cost"]*self.m_count_value*100 >=1000 then 
    --     str2 =
    -- end
    self.m_number_label:setString(self:numtostring(self.m_count_value*100));
    local str = self:numtostring(self.guessing_cfg[self.m_type]["cost"]*self.m_count_value)
    local str2 = self:numtostring(self.guessing_cfg[self.m_type]["cost"]*self.m_count_value*self.guessing_cfg[self.m_type]["double_"..self.m_double]) 
    self.m_tips_label:setString("Tốn"..str.." thùng dầu để cổ vũ đội bóng của bạn!\nQuà dự đoán là:"..str2.." Bình Xăng")

end
function ui_guessing_football_cheer_up:numtostring( num )
        -- body
    local  str  = tostring(num)
    if num >= 1000 then 
         str = (num/1000).."k"
    end
    return str
end
function ui_guessing_football_cheer_up.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
            if self.m_flag ==true then 
                return 
            end
        if btnTag == 999 then
            self:back();
        elseif btnTag == 1  or btnTag == 2  or btnTag == 3 then 
           for i=1,3 do
                if btnTag ==2 and self.m_game_type[self.m_type] ==1 then 
                    game_util:addMoveTips({text = "Vòng loại không có mục này!"});   
                end
                if btnTag ~= i then 
                    self.m_select[i].se:setOpacity(0)
                end
                if btnTag == i then 
                    self.m_select[i].se:setOpacity(255)
                end
           end
           self.m_double = btnTag
           self.m_choose =btnTag
           self.m_number_label:setString(self:numtostring(self.m_count_value*100));
            local str = self:numtostring(self.guessing_cfg[self.m_type]["cost"]*self.m_count_value)
            local str2 = self:numtostring(self.guessing_cfg[self.m_type]["cost"]*self.m_count_value*self.guessing_cfg[self.m_type]["double_"..self.m_double]) 
            self.m_tips_label:setString("Tốn"..str.."thùng dầu để cổ vũ đội bóng của bạn!\nQuà dự đoán là:"..str2.."Bình Xăng")

        elseif btnTag ==4 then  --竞猜 投注 多少
            function ResponseMethod(tag,gameData)
                self:refreshUi()    
                game_util:addMoveTips({text = "Cổ vũ thành công!"});

            end
            --参数 为场次 选择队伍 投注几注
            network.sendHttpRequest(ResponseMethod,game_url.getUrlForKey("world_cup_guess_guess_result"), http_request_method.GET, {field_id = self.m_type,team_id = self.m_choose,num =self.m_count_value},"world_cup_guess_guess_result")

        elseif btnTag == 101 then--  +
            if self.m_count_value >=1000 then 
                self.m_count_value =1000
                self:setCount(0)
                game_util:addMoveTips({text = "Đạt giới hạn cổ vũ tối đa!"});
            else
                self:setCount(1)
            end
        elseif btnTag == 102 then--  -
            self:setCount(-1)
        elseif btnTag == 103 then--  +10
            if self.m_count_value >=1000 then 
                self.m_count_value =1000
                self:setCount(0)
                game_util:addMoveTips({text = "Đạt giới hạn cổ vũ tối đa!"});
            else
                self:setCount(10)
            end
        elseif btnTag == 104 then--  -10
            self:setCount(-10)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guessing_football_cheer_up.ccbi");  

    

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then

        end
    end

    self.m_close_btn=ccbNode:controlButtonForName("m_close_btn")
    self.m_btn_cheer_up=ccbNode:controlButtonForName("m_btn_cheer_up")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    self.m_btn_cheer_up:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
   
    self.m_name = ccbNode:labelTTFForName("m_name")
    self.m_name:setString("Hạng"..self.m_type.."   "..self.guessing_cfg[self.m_type]["team_1"].." vs "..self.guessing_cfg[self.m_type]["team_3"])
    self.m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    self.m_tips_label:setString("Tốn"..self.guessing_cfg[self.m_type]["cost"].."thùng dầu để cổ vũ đội bóng của bạn!\nQuà dự đoán là:"..self.guessing_cfg[self.m_type]["cost"]*self.m_count_value*self.guessing_cfg[self.m_type]["double_"..self.m_double].."Bình Xăng")

    -- self.m_number_label = ccbNode:labelBMFontForName("number_label");
    self.m_number_label = ccbNode:labelTTFForName("number_label");
    self.m_btn_add = ccbNode:controlButtonForName("btn_add");
    self.m_btn_minute = ccbNode:controlButtonForName("btn_minute");
    self.m_btn_min10 = ccbNode:controlButtonForName("btn_min10");
    self.m_btn_add10 = ccbNode:controlButtonForName("btn_add10");
    self.m_btn_add:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_btn_minute:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_btn_min10:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_btn_add10:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self:setCount(0);


    for i=1,3 do
        self.m_select[i] = {}
        local  m_select_btn = ccbNode:controlButtonForName("m_select_btn"..i)
        self.m_select[i].btn = m_select_btn
        self.m_select[i].btn:setOpacity(0)
        self.m_select[i].btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
        local m_select_sp1 = ccbNode:spriteForName("m_btn_select_sp"..i)
        self.m_select[i].sp = m_select_sp1
        local m_select = ccbNode:spriteForName("m_select_"..i)
        local m_select_label = ccbNode:labelTTFForName("m_select_label"..i)
        self.m_select[i].label = m_select_label

        self.m_select[i].se = m_select--选中的图片
        if i ~= 2  then 
            local  str= self.guessing_cfg[self.m_type]
            -- cclog2(str,"str-=----------")
            self.m_select[i].sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(str["team_"..i.."_picture"]..".png"))
            self.m_select[i].se :setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_cloth_choose.png"))
            self.m_select[i].label:setString(str["team_"..i])
        else
            self.m_select[i].se :setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_sp_vs2.png"))
            self.m_select[i].label:setString("Hòa")
            
        end
            -- self.m_select[i].se:setOpacity(255)

        
        -- self.m_select[i].label:setOpacity(0)
        
        local  m_reward = ccbNode:labelTTFForName("m_reward"..i)
        self.m_select[i].rewardlabel = m_reward --倍率
        self.m_select[i].rewardlabel:setString("Thưởng gấp "..self.guessing_cfg[self.m_type]["double_"..i].."")
        
        if i == self.m_choose then 
            self.m_select[i].btn :setColor(ccc3(255,255,255))
            self.m_select[i].se:setOpacity(255)
        else
            self.m_select[i].btn :setColor(ccc3(100,100,100))
            self.m_select[i].se:setOpacity(0)
        end
    end
    

    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 4,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
-- 



function ui_guessing_football_cheer_up.refreshUi(self)      
    -- for i=1,3 do
    --      --倍率
    --     self.m_select[i].rewardlabel:setString(self.guessing_cfg[self.m_type]["double_"..i].."倍奖励")
    --     if i == self.m_choose then 
    --         self.m_select[i].btn :setColor(ccc3(255,255,255))
    --         self.m_select[i].se:setOpacity(255)
    --     else
    --         self.m_select[i].btn :setColor(ccc3(100,100,100))
    --         self.m_select[i].se:setOpacity(0)
    --     end
    -- end
    -- self.m_name:setString("第"..self.m_type.."场  "..self.guessing_cfg[self.m_type]["team_1"].." vs "..self.guessing_cfg[self.m_type]["team_3"])

end



--[[--
    初始化
]]
function ui_guessing_football_cheer_up.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil then
         self.m_tGameData = t_params.gameData
         self.m_type =t_params.m_type
         self.m_choose = t_params.m_choose
         self.m_max_count = t_params.maxCount;

    else
        self.m_tGameData = {};
    end
    -- cclog2(self.m_tGameData,"self.m_tGameData-=-----=----------")
    self.guessing_cfg = {}
    self.m_id = {}
    self.m_game_type ={}
    -- self.m_bet_list = self.m_tGameData.bet_list
    -- cclog2(self.m_bet_list[self.m_type],"self.m_bet_list[self.m_type]-=------")
    -- local guessing_cfg  = getConfig(game_config_field.world_guessing)
    local guessing_cfg  = json.decode(getConfig(game_config_field.world_guessing):getFormatBuffer())

    for k,v in pairs(guessing_cfg) do
            table.insert(self.m_id,k)
        -- end
    end
    -- for i=1,#self.m_id do
        -- self.guessing_cfg[i] = guessing_cfg[tostring(self.m_id[i])]
        self.guessing_cfg[self.m_type] = guessing_cfg[tostring(self.m_type)]
        self.m_game_type[self.m_type] = self.guessing_cfg[self.m_type].game_type
        -- self.guessing_cfg[i] = guessing_cfg[tostring(i)]
    -- end
    -- cclog2(self.guessing_cfg,"self.guessing_cfg-=-------")
    
    -- self.guessing_cfg[2] = guessing_cfg:getNodeWithKey("2")
    self.m_max_count = 100000
    self.m_count_value = 1;
    self.m_double = self.m_choose

end
--[[--
    创建ui入口并初始化数据
]]
function ui_guessing_football_cheer_up.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function ui_guessing_football_cheer_up.callBackFunc(self)
    local callBackFunc = self.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc();
    end
end

return ui_guessing_football_cheer_up;