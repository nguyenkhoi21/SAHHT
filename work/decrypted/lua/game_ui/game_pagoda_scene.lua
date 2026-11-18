-- 玲珑宝塔
    -- pagoda_pagoda_index =  "/api/?method=pagoda.pagoda_index",      -- 宝塔主页
    -- pagoda_lantern =  "/api/?method=pagoda.lantern",      -- 宝塔点灯
    -- pagoda_get_floor_reward =  "/api/?method=pagoda.get_floor_reward",      -- 宝塔领奖
local game_pagoda_scene = {
    m_tGameData = nil,
    m_root_layer = nil,
    m_root_layer2 = nil,
    m_root_layer3 = nil,
    ------------------------------------
    m_node_rewards_tb = nil,
    m_node_lay2 = nil,
    m_node_big_reward = nil,
    m_node_all_rewards = nil,
    m_node_buttons = nil,
    m_node_rewards = nil,

    m_scroll_rewards = nil,
    m_scroll_bigrewards = nil,
    m_scroll_buttons = nil,
    m_scroll_floor = nil,

    m_sp_chest1 = nil,
    m_sp_chest_light = nil,
    m_sp_chest2 = nil,
    m_sp_toewr = nil,
    m_sp_bg = nil,
    m_sp_iconfire = nil,
    m_9sp_buttons = nil,

    m_lb_lucky = nil,
    m_lb_total = nil,
    m_lb_lasttimes = nil,
    m_lb_cost = nil,

    m_back_btn = nil,
    m_btn_rules = nil,
    m_btn_bigreward = nil,
    m_btn_award = nil,
    -- m_btn_rewards = nil,
    m_btn_how = nil,
    m_btn_needs = nil,
    m_btn_raids = nil,
    m_btn_pay = nil,
    ------------------------------------
    m_version = nil,
    m_layer2_flag = nil,
    m_data_lanterns = nil,
    m_cur_floor = nil,
    m_cur_floor_lantern = nil,

    m_node_lastchoose = nil,
    m_num_lastchoose = nil,
    m_cur_lanternid = nil,
    m_data_floorRewards =nil,
    m_shared = nil,
    m_btn_refresh = nil,
};

--[[
    销毁
]]
function game_pagoda_scene.destroy(self)
    cclog("-----------------game_pagoda_scene destroy-----------------");
    self.m_tGameData = nil
    self.m_root_layer = nil
    self.m_root_layer2 = nil
    self.m_root_layer3 = nil
    ------------------------------------
    self.m_node_rewards_tb = nil
    self.m_node_lay2 = nil
    self.m_node_big_reward = nil
    self.m_node_all_rewards = nil
    self.m_node_buttons = nil
    self.m_node_rewards = nil

    self.m_scroll_rewards = nil
    self.m_scroll_bigrewards = nil
    self.m_scroll_buttons = nil
    self.m_scroll_floor = nil

    self.m_sp_chest1 = nil
    self.m_sp_chest_light = nil
    self.m_sp_chest2 = nil
    self.m_sp_toewr = nil
    self.m_sp_bg = nil
    self.m_sp_iconfire = nil
    self.m_9sp_buttons = nil

    self.m_lb_lucky = nil
    self.m_lb_total = nil
    self.m_lb_lasttimes = nil
    self.m_lb_cost = nil

    self.m_back_btn = nil
    self.m_btn_rules = nil
    self.m_btn_bigreward = nil
    self.m_btn_award = nil
    -- self.m_btn_rewards = nil
    self.m_btn_how = nil
    self.m_btn_needs = nil
    self.m_btn_raids = nil
    self.m_btn_pay = nil
    ------------------------------------
    self.m_version = nil
    self.m_layer2_flag = nil
    self.m_data_lanterns = nil
    self.m_cur_floor = nil
    self.m_cur_floor_lantern = nil

    self.m_node_lastchoose = nil
    self.m_num_lastchoose = nil
    self.m_cur_lanternid = nil
    self.m_data_floorRewards =nil
    self.m_shared = nil
    self.m_btn_refresh = nil
end

--[[
    返回
]]
function game_pagoda_scene.back(self,type)
    if self.m_shared then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
        self.m_shared = nil
    end
    game_scene:enterGameUi("game_main_scene")
end

--[[
    读取ccbi创建ui
]]
function game_pagoda_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog("=======================   btntag ",btnTag)
        if btnTag == 999 then --返回
            self:back();
        elseif btnTag == 101 then
            game_scene:addPop("game_active_limit_detail_pop",{openMsg = self.m_cfg_pagoda.notice})
        elseif btnTag == 102 then
            self:setlayer2(1)
        elseif btnTag == 103 then
            local function ResponseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                data = json.decode(data:getFormatBuffer())
                -- cclog2(data , "gameData =============")
                game_util:rewardTipsByDataTable(data.reward)
                self.m_num_lastchoose = nil
                self.m_node_lastchoose = nil
                game_util:setCCControlButtonBackground(self.m_btn_award,"public_btn_alreadyGet.png")
                self.m_btn_award:setEnabled(false)
                self.m_btn_award:setColor(ccc3(100,100,100))
                -- game_util:setCCControlButtonBackground(self.m_btn_award,"ui_pagoda_btn_award.png")
                self.m_data_floorRewards = {}
                for i=1,5 do
                    self.m_data_floorRewards[i] = data.floor_reward[i..""] and data.floor_reward[i..""] or 0
                end
                self.m_node_lastchoose = nil
                self.m_node_rewards:removeAllChildrenWithCleanup(true);
                local tempTableView = self:createTableView(self.m_node_rewards:getContentSize(),self.m_cfg_pagoda_reward["pagoda_reward"..self.m_cur_floor],self.m_cur_floor)
                self.m_node_rewards:addChild(tempTableView);
                if self.m_cur_floor_lantern==nil or self.m_cur_floor_lantern > self.m_cur_floor then
                    if self.m_data_floorRewards[self.m_cur_floor] == 0 then
                        game_util:setCCControlButtonBackground(self.m_btn_award,"ui_pagoda_btn_award.png")
                    else
                        game_util:setCCControlButtonBackground(self.m_btn_award,"public_btn_alreadyGet.png")
                    end
                else
                    game_util:setCCControlButtonBackground(self.m_btn_award,"public_btn_canotGet.png")
                end
                self.m_btn_award:setEnabled(false)
                self.m_btn_award:setColor(ccc3(100,100,100))
            end
            local params = {};
            params.floor = self.m_cur_floor
            params.reward_id = self.m_num_lastchoose
            -- cclog2(params,"params     pagoda_get_floor_reward ============")
            network.sendHttpRequest(ResponseMethod,game_url.getUrlForKey("pagoda_get_floor_reward"), http_request_method.GET, params,"pagoda_get_floor_reward")
        elseif btnTag == 104 then
        elseif btnTag == 105 then
            self:setlayer2(3)
        elseif btnTag == 106 then
            local function ResponseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                data = json.decode(data:getFormatBuffer())
                -- cclog2(data , "gameData =============")
                game_util:rewardTipsByDataTable(data.reward)
                self.m_lb_lucky:setString("Điểm may mắn: \n             "..data.lucky_num.."%")
                self.m_lb_total:setString("Số lượng bóng lửa nhỏ: "..data.item_num)
                self.m_sp_chest1:setVisible(data.lucky_num < 100)
                self.m_sp_chest2:setVisible(data.lucky_num >= 100)
                self.m_sp_chest_light:setVisible(data.lucky_num >= 100)

                if data.lucky_num >= 100 then
                    local animArr = CCArray:create();
                    animArr:addObject(CCRotateBy:create(5,360));
                    self.m_sp_chest_light:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
                end

                local lastfloor = self.m_cur_floor_lantern

                self.m_cur_lanternid = nil
                for k,v in pairs(self.m_data_lanterns) do
                    for k1,v1 in pairs(v) do
                        if data.lanterns[k..""][k1] then
                            self.m_data_lanterns[k][k1].light = 1
                        else
                            if self.m_cur_lanternid == nil then
                                self.m_cur_lanternid = k1
                                self.m_cur_floor_lantern = k
                            end
                            self.m_data_lanterns[k][k1].light = 0
                        end
                    end
                end
                if self.m_cur_lanternid == nil then
                    self.m_cur_floor_lantern = nil
                end
                self:setLanterns(lastfloor, self.m_scroll_floor[lastfloor], self.m_data_lanterns[lastfloor])
                if self.m_cur_floor_lantern then
                    self.m_sp_iconfire:setVisible(true)
                    self.m_lb_cost:setString("x"..self.m_cfg_pagoda.need_item[self.m_cur_floor_lantern][3])
                else
                    self.m_sp_iconfire:setVisible(false)
                    self.m_lb_cost:setString("")
                    game_util:setCCControlButtonBackground(self.m_btn_needs,"public_btn_alreadyGet_yellow.png")
                    self.m_btn_needs:setEnabled(false)
                    self.m_btn_needs:setColor(ccc3(150,150,150))
                end
                self.m_data_floorRewards = {}
                for i=1,5 do
                    self.m_data_floorRewards[i] = data.floor_reward[i..""] and data.floor_reward[i..""] or 0
                end
                if self.m_cur_floor_lantern==nil or self.m_cur_floor_lantern > self.m_cur_floor then
                    if self.m_data_floorRewards[self.m_cur_floor] == 0 then
                        game_util:setCCControlButtonBackground(self.m_btn_award,"ui_pagoda_btn_award.png")
                    else
                        game_util:setCCControlButtonBackground(self.m_btn_award,"public_btn_alreadyGet.png")
                    end
                else
                    game_util:setCCControlButtonBackground(self.m_btn_award,"public_btn_canotGet.png")
                end
                self.m_btn_award:setEnabled(false)
                self.m_btn_award:setColor(ccc3(100,100,100))

                local lanterns = data.lanterns or {}
                local temp = nil
                for k,v in pairs(lanterns) do
                    if v[1] == nil then
                        lanterns[k] = nil
                    else
                        temp = v
                        lanterns[k] = nil
                        lanterns[tonumber(k)] = temp
                    end
                end
                local count_ = #lanterns
                if count_ > 0 then
                    if #self.m_data_lanterns[count_] == #lanterns[count_] then
                        local function fallcallback(node)
                            game_util:addMoveTips({text = "Tầng"..count_.."đã thắp sáng toàn bộ, chọn 1 phần quà của tầng này ở bên trái"})
                        end
                        local arr = CCArray:create();
                        arr:addObject(CCDelayTime:create(1));
                        arr:addObject(CCCallFuncN:create(fallcallback));
                        self.m_node_rewards:runAction(CCSequence:create(arr));
                        self.m_cur_floor = count_
                        self.m_data_floorRewards = {}
                        for i=1,5 do
                            self.m_data_floorRewards[i] = data.floor_reward[i..""] and data.floor_reward[i..""] or 0
                        end
                        self.m_node_lastchoose = nil
                        self.m_node_rewards:removeAllChildrenWithCleanup(true);
                        local tempTableView = self:createTableView(self.m_node_rewards:getContentSize(),self.m_cfg_pagoda_reward["pagoda_reward"..self.m_cur_floor],self.m_cur_floor)
                        self.m_node_rewards:addChild(tempTableView);
                        if self.m_cur_floor_lantern==nil or self.m_cur_floor_lantern > self.m_cur_floor then
                            if self.m_data_floorRewards[self.m_cur_floor] == 0 then
                                game_util:setCCControlButtonBackground(self.m_btn_award,"ui_pagoda_btn_award.png")
                            else
                                game_util:setCCControlButtonBackground(self.m_btn_award,"public_btn_alreadyGet.png")
                            end
                        else
                            game_util:setCCControlButtonBackground(self.m_btn_award,"public_btn_canotGet.png")
                        end
                        self.m_btn_award:setEnabled(false)
                        self.m_btn_award:setColor(ccc3(100,100,100))
                        for k,v in pairs(self.m_sp_toewr) do
                            if self.m_cur_floor == k then
                                v:setColor(ccc3(255,255,255))
                            else
                                v:setColor(ccc3(155,155,155))
                            end
                        end
                    end
                end
            end
            local params = {};
            params.floor = self.m_cur_floor_lantern
            params.lantern_id = self.m_cur_lanternid
            -- cclog2(params,"params     pagoda_lantern ============")
            network.sendHttpRequest(ResponseMethod,game_url.getUrlForKey("pagoda_lantern"), http_request_method.GET, params,"pagoda_lantern")
        elseif btnTag == 107 then
            if self.m_shared then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
                self.m_shared = nil
            end
            game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = function (  )
                self:destroy();
            end});
        elseif btnTag == 108 then
            function responseMethod(tag,gameData)
                if self.m_shared then
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
                    self.m_shared = nil
                end
                game_scene:enterGameUi("game_charge_active",{gameData = gameData})
                self:destroy()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_active_show"), http_request_method.GET, {},"active_active_show")
        elseif btnTag == 109 then
            if self.m_cur_floor_lantern then
                game_util:addMoveTips({text = "Hãy thắp sáng tháp đèn lồng và tất cả các bên trái\n nhận xong tất cả các giải thưởng sau khi cập nhật!"})
                return
            end
            local flag = 0
            for k,v in pairs(self.m_data_floorRewards) do
                if v == 0 then
                    flag = 1
                end
            end
            if flag == 1 then
                game_util:addMoveTips({text = "Hãy thắp sáng tháp đèn lồng và tất cả các bên trái \nnhận xong tất cả các giải thưởng sau khi cập nhật!"})
                return
            end
            if self.m_shared then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
                self.m_shared = nil
            end
            local function ResponseMethod(tag,gameData)
                game_scene:enterGameUi("game_pagoda_scene",{gameData = gameData})
            end
            local params = {};
            network.sendHttpRequest(ResponseMethod,game_url.getUrlForKey("pagoda_pagoda_index"), http_request_method.GET, params,"pagoda_pagoda_index")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_pagoda_main.ccbi");

    ------------------------------------
    self.m_root_layer = ccbNode:layerColorForName("m_root_layer")
    self.m_root_layer2 = ccbNode:layerColorForName("m_root_layer2")
    self.m_root_layer3 = ccbNode:layerColorForName("m_layer_3")

    self.m_node_rewards_tb = ccbNode:nodeForName("m_node_rewards_tb")
    self.m_node_lay2 = ccbNode:nodeForName("m_node_lay2")
    self.m_node_lay2:setVisible(false)
    self.m_node_big_reward = ccbNode:nodeForName("m_node_big_reward")
    self.m_node_all_rewards = ccbNode:nodeForName("m_node_all_rewards")
    self.m_node_buttons = ccbNode:nodeForName("m_node_buttons")
    self.m_node_rewards = ccbNode:nodeForName("m_node_rewards")

    self.m_scroll_rewards = ccbNode:scrollViewForName("m_scroll_rewards")
    self.m_scroll_bigrewards = ccbNode:scrollViewForName("m_scroll_bigrewards")
    self.m_scroll_buttons = ccbNode:scrollViewForName("m_scroll_buttons")
    self.m_scroll_floor = {}
    for i=1,5 do
        self.m_scroll_floor[i] = ccbNode:scrollViewForName("m_scroll_floor"..i)
        self.m_scroll_floor[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    end

    self.m_sp_chest1 = ccbNode:spriteForName("m_sp_chest1")
    self.m_sp_chest_light = ccbNode:spriteForName("m_sp_chest_light")
    self.m_sp_chest2 = ccbNode:spriteForName("m_sp_chest2")
    self.m_sp_iconfire  =  ccbNode:spriteForName("m_sp_iconfire")
    self.m_sp_chest1:setVisible(true)
    self.m_sp_chest_light:setVisible(false)
    self.m_sp_chest2:setVisible(false)
    self.m_sp_toewr = {}
    for i=1,5 do
        self.m_sp_toewr[i] = ccbNode:spriteForName("m_sp_toewr"..i)
    end

    self.m_sp_bg = ccbNode:spriteForName("m_sp_bg")
    self.m_9sp_buttons = ccbNode:scale9SpriteForName("m_9sp_buttons")

    self.m_lb_lucky = ccbNode:labelTTFForName("m_lb_lucky")
    self.m_lb_total = ccbNode:labelTTFForName("m_lb_total")
    self.m_lb_lasttimes = ccbNode:labelTTFForName("m_lb_lasttimes")
    self.m_lb_cost = ccbNode:labelTTFForName("m_lb_cost")

    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_btn_rules = ccbNode:controlButtonForName("m_btn_rules")
    self.m_btn_bigreward = ccbNode:controlButtonForName("m_btn_bigreward")
    self.m_btn_bigreward:setOpacity(0)
    self.m_btn_award = ccbNode:controlButtonForName("m_btn_award")
    -- self.m_btn_rewards = ccbNode:controlButtonForName("m_btn_rewards")
    self.m_btn_how = ccbNode:controlButtonForName("m_btn_how")
    self.m_btn_needs = ccbNode:controlButtonForName("m_btn_needs")

    self.m_btn_raids = ccbNode:controlButtonForName("m_btn_raids")
    self.m_btn_pay = ccbNode:controlButtonForName("m_btn_pay")
    self.m_btn_refresh = ccbNode:controlButtonForName("m_btn_refresh")

    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 9)
    self.m_btn_rules:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 9)
    self.m_btn_bigreward:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 9)
    self.m_btn_award:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 9)
    self.m_btn_refresh:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 9)
    -- self.m_btn_rewards:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 9)
    self.m_btn_how:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 9)
    self.m_btn_needs:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 9)

    self.m_scroll_bigrewards:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)
    self.m_scroll_buttons:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)
    self.m_btn_pay:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)
    self.m_btn_raids:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)

    local function onTouch(eventType, x, y)
        local pos = self.m_node_lay2:convertToNodeSpace(ccp(x,y));
        if eventType == "began" then
            return true
        end
    end
    local function onTouch3(eventType, x, y)
        local pos = self.m_node_lay2:convertToNodeSpace(ccp(x,y));
        if eventType == "began" then
            local flag = 0
            for i=1,5 do
                if self.m_sp_toewr[i]:boundingBox():containsPoint(pos) then
                    if self.m_cur_floor  ~= i then
                        self.m_cur_floor = i
                        if self.m_node_lastchoose then
                            self.m_node_lastchoose:setVisible(false)
                        end
                        self.m_num_lastchoose = nil
                        self.m_node_lastchoose = nil
                        self.m_node_rewards:removeAllChildrenWithCleanup(true);
                        local tempTableView = self:createTableView(self.m_node_rewards:getContentSize(),self.m_cfg_pagoda_reward["pagoda_reward"..self.m_cur_floor],self.m_cur_floor)
                        self.m_node_rewards:addChild(tempTableView);
                        if self.m_cur_floor_lantern == nil or self.m_cur_floor_lantern > self.m_cur_floor then
                            if self.m_data_floorRewards[self.m_cur_floor] == 0 then
                                game_util:setCCControlButtonBackground(self.m_btn_award,"ui_pagoda_btn_award.png")
                            else
                                game_util:setCCControlButtonBackground(self.m_btn_award,"public_btn_alreadyGet.png")
                            end
                        else
                            game_util:setCCControlButtonBackground(self.m_btn_award,"public_btn_canotGet.png")
                        end
                        self.m_btn_award:setEnabled(false)
                        self.m_btn_award:setColor(ccc3(100,100,100))

                        for k,v in pairs(self.m_sp_toewr) do
                            if self.m_cur_floor == k then
                                v:setColor(ccc3(255,255,255))
                            else
                                v:setColor(ccc3(155,155,155))
                            end
                        end
                    end
                    flag = 1
                    return false
                end
            end
            if flag == 0 then
                return true
            end
        end
    end
    local function onTouch2(eventType, x, y)
        local pos = self.m_node_lay2:convertToNodeSpace(ccp(x,y));
        if eventType == "began" then
            if self.m_layer2_flag == 1 then
                if self.m_node_big_reward:boundingBox():containsPoint(pos) then
                else
                    self.m_root_layer2:setTouchEnabled(false);
                    self.m_node_lay2:setVisible(false)
                    self.m_layer2_flag = nil
                end

            elseif self.m_layer2_flag == 2 then
                if self.m_node_all_rewards:boundingBox():containsPoint(pos) then
                else
                    self.m_root_layer2:setTouchEnabled(false);
                    self.m_node_lay2:setVisible(false)
                    self.m_layer2_flag = nil
                end
            elseif self.m_layer2_flag == 3 then
                if self.m_node_buttons:boundingBox():containsPoint(pos) then
                else
                    self.m_root_layer2:setTouchEnabled(false);
                    self.m_node_lay2:setVisible(false)
                    self.m_layer2_flag = nil
                end
            end
            return true
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY + 1,true);
    self.m_root_layer:setTouchEnabled(true);
    
    self.m_root_layer2:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    self.m_root_layer2:setTouchEnabled(false);
    self.m_root_layer3:registerScriptTouchHandler(onTouch3,false,GLOBAL_TOUCH_PRIORITY - 6,true);
    self.m_root_layer3:setTouchEnabled(true);
    return ccbNode;
end

function game_pagoda_scene.setlayer2(self,intag,data)
    self.m_layer2_flag = intag
    self.m_node_lay2:setVisible(true)
    self.m_root_layer2:setTouchEnabled(true);
    self.m_node_big_reward:setVisible(intag == 1)
    self.m_node_all_rewards:setVisible(intag == 2)
    self.m_node_buttons :setVisible(intag == 3)
    if intag == 1 then
        local width = 0
        local sc_height = self.m_scroll_bigrewards:getViewSize().height
        local sc_width = self.m_scroll_bigrewards:getViewSize().width
        local scnode = self.m_scroll_bigrewards:getChildByTag(101)
        if scnode == nil then
            scnode = CCNode:create()
            self.m_scroll_bigrewards:addChild(scnode)
            scnode:setTag(101)
        else
            scnode:removeAllChildrenWithCleanup(true)
        end
        local function onBtnClick( event, target  )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            game_util:lookItemDetal(self.m_cfg_pagoda.final_reward[btnTag])
        end 

        for k,v in pairs(self.m_cfg_pagoda.final_reward) do
            local icon,name,count = game_util:getRewardByItemTable(v)
            local button = game_util:createCCControlButton("public_weapon.png","",onBtnClick)
            button:setTag(tonumber(k))
            button:setOpacity(0)
            scnode:addChild(button)
            scnode:addChild(icon)
            local itemSize = icon:getContentSize()
            icon:setPosition(ccp(itemSize.width * (k-0.5),sc_height/2))
            button:setPosition(ccp(itemSize.width * (k-0.5),sc_height/2))
            icon:setScale(0.7)
            if name then
                local tempLabel = game_util:createLabelTTF({text = name.."x"..count,color = ccc3(250,180,0),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*-0.2))
                icon:addChild(tempLabel)
            end
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
        end
        scnode:setContentSize(CCSizeMake(width,sc_height))
        self.m_scroll_bigrewards:setContentSize(CCSizeMake(width, sc_height))
        self.m_scroll_bigrewards:setContentOffset(ccp(0, 0), false)
    elseif intag == 2 then
        self.m_node_rewards_tb:removeAllChildrenWithCleanup(true)
        local icon,name,count = game_util:getRewardByItemTable(data)
        self.m_node_rewards_tb:addChild(icon)
        icon:setPosition(ccp(self.m_node_rewards_tb:getContentSize().width/2,self.m_node_rewards_tb:getContentSize().height*3/5))
        local itemSize = icon:getContentSize()
        if name then
            local tempLabel = game_util:createLabelTTF({text = name.."x"..count,color = ccc3(250,180,0),fontSize = 8});
            tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*-0.2))
            icon:addChild(tempLabel)
        end

        local function onBtnClick( event, target  )
            game_util:lookItemDetal(data)
        end 
        local button = game_util:createCCControlButton("public_weapon.png","",onBtnClick)
        button:setAnchorPoint(ccp(0.5,0.5))
        button:setPosition(ccp(self.m_node_rewards_tb:getContentSize().width/2,self.m_node_rewards_tb:getContentSize().height*3/5))
        button:setOpacity(0)
        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 21)
        self.m_node_rewards_tb:addChild(button)
    elseif intag == 3 then
    end
end

--[[--
    创建奖励列表
]]
function game_pagoda_scene.createTableView(self,viewSize,tableData,floorid)
    -- cclog2(tableData,"tableData ====================")
    local itemsCount = #tableData
    local totalItem = itemsCount
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionHorizontal
    params.totalItem = totalItem;
    params.showPoint = false
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-9;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_pagoda_choose_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_sp_icon = ccbNode:spriteForName("m_sp_icon");
            local m_sp_point = ccbNode:spriteForName("m_sp_point");
            local m_lb_item = ccbNode:labelTTFForName("m_lb_item");
            m_sp_icon:setOpacity(0)
            local icon,name,count = game_util:getRewardByItemTable(tableData[index+1])
            icon:setAnchorPoint(ccp(0,0))
            m_sp_icon:removeAllChildrenWithCleanup(true)
            m_sp_icon:addChild(icon)
            icon:setScale(0.8)
            icon:setPositionY(10)
            if name then
                local tempLabel = game_util:createLabelTTF({text = name.."x"..count,color = color,fontSize = 8});
                tempLabel:setPositionX(20)
                m_sp_icon:addChild(tempLabel)
            end

            if self.m_data_floorRewards[floorid] == 0 then
                if self.m_node_lastchoose == m_sp_point then
                    m_sp_point:setVisible(true)
                else
                    m_sp_point:setVisible(false)
                end
            else
                icon:setColor(ccc3(100,100,100))
                if index + 1 == self.m_data_floorRewards[floorid] then
                    m_sp_point:setVisible(true)
                    m_sp_point:setColor(ccc3(100,100,100))
                else
                    m_sp_point:setVisible(false)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if index >= itemsCount then return end;
        if eventType == "ended" and item and self.m_data_floorRewards[floorid] == 0 then
            if self.m_node_lastchoose then
                self.m_node_lastchoose:setVisible(false)
            end
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local m_sp_point = ccbNode:labelTTFForName("m_sp_point");
            m_sp_point:setVisible(true)
            self.m_node_lastchoose = m_sp_point
            self.m_num_lastchoose = index+1
            if self.m_cur_floor_lantern==nil or self.m_cur_floor_lantern > self.m_cur_floor then
                if self.m_data_floorRewards[self.m_cur_floor] == 0 then
                    self.m_btn_award:setEnabled(true)
                    self.m_btn_award:setColor(ccc3(255,255,255))
                else
                    self.m_btn_award:setEnabled(false)
                    self.m_btn_award:setColor(ccc3(100,100,100))
                end
            else
                self.m_btn_award:setEnabled(false)
                self.m_btn_award:setColor(ccc3(100,100,100))
            end
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[
    刷新ui
]]
function game_pagoda_scene.refreshUi(self)
    local winsize = CCDirector:sharedDirector():getWinSize()
    local bgsize = self.m_sp_bg:getContentSize()
    local ratio = winsize.width/bgsize.width

    self.m_lb_lucky:setString("Điểm may mắn: \n            "..self.m_tGameData.lucky_num.."%")
    self.m_lb_total:setString("Số lượng bóng lửa nhỏ: "..self.m_tGameData.item_num)
    self.m_sp_bg:setScale(ratio)
    if self.m_cur_floor_lantern then
        self.m_sp_iconfire:setVisible(true)
        self.m_lb_cost:setString("x"..self.m_cfg_pagoda.need_item[self.m_cur_floor_lantern][3])
    else
        self.m_sp_iconfire:setVisible(false)
        self.m_lb_cost:setString("")
        game_util:setCCControlButtonBackground(self.m_btn_needs,"public_btn_alreadyGet_yellow.png")
        self.m_btn_needs:setEnabled(false)
        self.m_btn_needs:setColor(ccc3(150,150,150))
    end

    for i=1,5 do
        self:setLanterns(i, self.m_scroll_floor[i], self.m_data_lanterns[i])
    end
    self.m_sp_chest1:setVisible(self.m_tGameData.lucky_num < 100)
    self.m_sp_chest2:setVisible(self.m_tGameData.lucky_num >= 100)
    self.m_sp_chest_light:setVisible(self.m_tGameData.lucky_num >= 100)

    if self.m_tGameData.lucky_num >= 100 then
        local animArr = CCArray:create();
        animArr:addObject(CCRotateBy:create(5,360));
        self.m_sp_chest_light:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
    end
    self.m_node_lastchoose = nil
    self.m_node_rewards:removeAllChildrenWithCleanup(true);
    local tempTableView = self:createTableView(self.m_node_rewards:getContentSize(),self.m_cfg_pagoda_reward.pagoda_reward1,1)
    self.m_node_rewards:addChild(tempTableView);
    cclog2(self.m_cur_floor_lantern,"self.m_cur_floor_lantern ===================")
    if self.m_cur_floor_lantern == nil or self.m_cur_floor_lantern > 1 then
        if self.m_data_floorRewards[1] == 0 then
            game_util:setCCControlButtonBackground(self.m_btn_award,"ui_pagoda_btn_award.png")
        else
            game_util:setCCControlButtonBackground(self.m_btn_award,"public_btn_alreadyGet.png")
        end
    else
        game_util:setCCControlButtonBackground(self.m_btn_award,"public_btn_canotGet.png")
    end
    self.m_btn_award:setEnabled(false)
    self.m_btn_award:setColor(ccc3(100,100,100))
    for k,v in pairs(self.m_sp_toewr) do
        if self.m_cur_floor == k then
            v:setColor(ccc3(255,255,255))
        else
            v:setColor(ccc3(155,155,155))
        end
    end

    if self.m_tGameData.remain_time > 0 then
        hours = math.floor(self.m_tGameData.remain_time / 3600)
        minutes = math.floor((self.m_tGameData.remain_time - hours * 3600)/ 60)
        seconds = math.floor(self.m_tGameData.remain_time - 3600 * hours - 60 * minutes)
        hours = hours<10 and "0"..hours or ""..hours
        minutes = minutes<10 and "0"..minutes or ""..minutes
        seconds = seconds<10 and "0"..seconds or ""..seconds
        self.m_lb_lasttimes:setString(hours..":"..minutes..":"..seconds)
    else
        self.m_lb_lasttimes:setString("Event đã kết thúc")
    end

    if self.m_shared == nil then
        function tick()
            if self.m_tGameData.remain_time > 0 then
                hours = math.floor(self.m_tGameData.remain_time / 3600)
                minutes = math.floor((self.m_tGameData.remain_time - hours * 3600)/ 60)
                seconds = math.floor(self.m_tGameData.remain_time - 3600 * hours - 60 * minutes)
                hours = hours<10 and "0"..hours or ""..hours
                minutes = minutes<10 and "0"..minutes or ""..minutes
                seconds = seconds<10 and "0"..seconds or ""..seconds
                self.m_lb_lasttimes:setString(hours..":"..minutes..":"..seconds)
                self.m_tGameData.remain_time = self.m_tGameData.remain_time - 1
            else
                self.m_lb_lasttimes:setString("Event đã kết thúc")
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
                self.m_shared = nil
            end
        end
        self.m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1 , false)
    end
end

function game_pagoda_scene.setLanterns(self, floorid, scroll_floor, data_floor)
    local function onClick( event, target  )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag()
        self:setlayer2(2,self.m_data_lanterns[self.m_cur_floor][btnTag])
        if self.m_cur_floor ~= floorid then
            self.m_cur_floor = floorid
            for k,v in pairs(self.m_sp_toewr) do
                if self.m_cur_floor == k then
                    v:setColor(ccc3(255,255,255))
                else
                    v:setColor(ccc3(155,155,155))
                end
            end
        end
    end
    local width = 0
    local fix_width = 0
    local iconwidth = nil
    local icon = nil
    local max_count = 0
    local floor_height = scroll_floor:getViewSize().height
    local floor_width = scroll_floor:getViewSize().width
    local count = #data_floor
    scroll_floor:getContainer():removeAllChildrenWithCleanup(true)
    local scnode = nil
    local isLess = 0
    local is_finallight = 0
    local lessPosTb = {}
    if scnode == nil then
        scnode = CCNode:create()
        scroll_floor:addChild(scnode)
        scnode:setTag(101)
    else
        scnode:removeAllChildrenWithCleanup(true)
    end

    for k,v in pairs(data_floor) do
        if v.light == 0 then
            icon = CCSprite:createWithSpriteFrameName("ui_pagoda_light_1.png")
        else
            icon = CCSprite:createWithSpriteFrameName("ui_pagoda_light_2.png")
        end
        local button = game_util:createCCControlButton("ui_pagoda_light_1.png","",onClick)
        button:setTag(tonumber(k))
        button:setOpacity(0)
        scnode:addChild(button)
        scnode:addChild(icon)
        if iconwidth == nil then
            iconwidth = icon:getContentSize().width
            if iconwidth*count < floor_width then
                isLess = 1
                local fixwidth = (floor_width - count*iconwidth)/(count + 1)

                for k1,v1 in pairs(data_floor) do
                    lessPosTb[#lessPosTb+1] = fixwidth*(#lessPosTb+1) + #lessPosTb*iconwidth
                end
            else
                max_count = floor_width / iconwidth
            end
        end
        icon:setAnchorPoint(ccp(0,0))
        button:setAnchorPoint(ccp(0,0))
        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)

        if isLess == 1 then
            icon:setPosition(ccp(lessPosTb[k],0))
            button:setPosition(ccp(lessPosTb[k],0))
            width = width + lessPosTb[k] 
        else
            icon:setPosition(ccp(width,0))
            button:setPosition(ccp(width,0))
            width = width + iconwidth 
            if v.light == 0 and is_finallight == 0 then
                is_finallight = 1
                if k >= max_count then
                    fix_width = (max_count - k)*iconwidth
                end
            end
        end
    end

    scnode:setContentSize(CCSizeMake(width,floor_height))
    scroll_floor:setContentSize(CCSizeMake(width, floor_height))
    scroll_floor:setContentOffset(ccp(fix_width, 0), true)
end


--[[--
    初始化
]]
function game_pagoda_scene.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        data = json.decode(data:getFormatBuffer())
        self.m_tGameData = data
    elseif t_params.gameData and tolua.type(t_params.gameData) == "table" then
        self.m_tGameData = t_params.gameData
    end
    -- cclog2(self.m_tGameData,"game_pagoda_scene.m_tGameData ===========")
    self.m_version = self.m_tGameData.version
    self.m_cfg_pagoda = getConfig(game_config_field.pagoda) and json.decode(getConfig(game_config_field.pagoda):getFormatBuffer()) or {}
    self.m_cfg_pagoda = self.m_cfg_pagoda[self.m_version..""]

    self.m_cfg_lantern_reward = getConfig(game_config_field.lantern_reward) and json.decode(getConfig(game_config_field.lantern_reward):getFormatBuffer()) or {}
    self.m_cfg_lantern_reward = self.m_cfg_lantern_reward[self.m_version..""]

    self.m_cfg_pagoda_reward = getConfig(game_config_field.pagoda_reward) and json.decode(getConfig(game_config_field.pagoda_reward):getFormatBuffer()) or {}
    self.m_cfg_pagoda_reward = self.m_cfg_pagoda_reward[self.m_version..""]
    -- cclog2(self.m_cfg_pagoda ,"self.m_cfg_pagoda ")
    -- cclog2(self.m_cfg_lantern_reward ,"self.m_cfg_lantern_reward ")
    -- cclog2(self.m_cfg_pagoda_reward ,"self.m_cfg_pagoda_reward ")
    self.m_data_lanterns = {}
    self.m_data_lanterns[1] = self.m_cfg_lantern_reward.lantern_reward1
    self.m_data_lanterns[2] = self.m_cfg_lantern_reward.lantern_reward2
    self.m_data_lanterns[3] = self.m_cfg_lantern_reward.lantern_reward3
    self.m_data_lanterns[4] = self.m_cfg_lantern_reward.lantern_reward4
    self.m_data_lanterns[5] = self.m_cfg_lantern_reward.lantern_reward5
    
    self.m_cur_floor = 1
    self.m_data_floorRewards = {}
    for i=1,5 do
        self.m_data_floorRewards[i] = self.m_tGameData.floor_reward[i..""] and self.m_tGameData.floor_reward[i..""] or 0
    end
    self.m_cur_lanternid = nil
    for k,v in pairs(self.m_data_lanterns) do
        for k1,v1 in pairs(v) do
            if self.m_tGameData.lanterns[k..""][k1] then
                self.m_data_lanterns[k][k1].light = 1
            else
                if self.m_cur_lanternid == nil then
                    self.m_cur_lanternid = k1
                    self.m_cur_floor_lantern = k
                end
                self.m_data_lanterns[k][k1].light = 0
            end
        end
    end

    if self.m_cur_lanternid == nil then
        self.m_cur_floor_lantern = nil
    end
end
--[[--
    创建入口
]]
function game_pagoda_scene.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    return rootScene;
end
return game_pagoda_scene;