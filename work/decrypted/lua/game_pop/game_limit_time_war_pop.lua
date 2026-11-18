--- 限时远征
local game_limit_time_war_pop = {
  
    m_ccbNode = nil,
    m_curPage = nil,
    m_root_layer = nil,
    m_cardId = nil,
    m_replace_cfg = nil,
    m_item_node = nil,
    item_count_label = nil,
  
};
--[[--
    销毁ui
]]
function game_limit_time_war_pop.destroy(self)
    -- body
    cclog("-----------------game_limit_time_war_pop destroy-----------------");
  
    self.m_curPage = nil;
    self.m_ccbNode = nil;
    self.m_root_layer = nil;
    self.m_cardId = nil;
    self.m_replace_cfg = nil;
    self.m_item_node = nil;
    self.item_count_label = nil;

    if self.m_shared then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
        self.m_shared = nil
    end
   
end
--[[--
    返回
]]
function game_limit_time_war_pop.back(self,backType)
    if backType == "back" then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui    equipSortByTypeName
]]
function game_limit_time_war_pop.createUi(self)
    local ccbNode = luaCCBNode:create();

    local function callBack(data)
        self.m_data = data
        --cclog2(data,"data22")
        self:refreshUi()
    end

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog(btnTag,"btntag")
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 2 then --规则
            game_scene:addPop("game_limit_time_war_pop_rule",{gameData = self.m_data.version}) 
        elseif btnTag == 3 then --排行榜
            game_scene:addPop("game_limit_time_war_leader",{gameData = self.m_data}) 
        elseif btnTag == 4 then--
           
        elseif btnTag == 5 then -- 1 选择任务
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer()).data
                game_scene:addPop("game_limit_time_war_task",{gameData = data, task_id = self.m_task[1], callback = callBack}) 
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("limit_time_war_choose_task"), http_request_method.GET, {task_id = self.m_task[1]},"limit_time_war_choose_task")
        elseif btnTag == 6 then  --立即完成
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer()).data
                game_util:rewardTipsByDataTable(data["reward"]);
                self.m_data = data
                cclog2(data,"data11")
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("limit_time_war_finish_task"), http_request_method.GET, {task_id = self.m_task[1]},"limit_time_war_finish_task")
        elseif btnTag == 7 then -- 1 选择任务
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer()).data
                game_scene:addPop("game_limit_time_war_task",{gameData = data, task_id = self.m_task[2], callback = callBack}) 
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("limit_time_war_choose_task"), http_request_method.GET, {task_id = self.m_task[2]},"limit_time_war_choose_task")
        elseif btnTag == 8 then --立即完成
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer()).data
                game_util:rewardTipsByDataTable(data["reward"]);
                self.m_data = data
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("limit_time_war_finish_task"), http_request_method.GET, {task_id = self.m_task[2]},"limit_time_war_finish_task")
        elseif btnTag == 9 then -- 1 选择任务
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer()).data
                game_scene:addPop("game_limit_time_war_task",{gameData = data, task_id = self.m_task[3], callback = callBack}) 
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("limit_time_war_choose_task"), http_request_method.GET, {task_id = self.m_task[3]},"limit_time_war_choose_task")
        elseif btnTag == 10 then --立即完成
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer()).data
                game_util:rewardTipsByDataTable(data["reward"]);
                self.m_data = data
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("limit_time_war_finish_task"), http_request_method.GET, {task_id = self.m_task[3]},"limit_time_war_finish_task")
        elseif btnTag == 11 then --领取奖励
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer()).data
                self.m_data = data
                game_util:rewardTipsByDataTable(data["reward"]);
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("limit_time_war_get_reward"), http_request_method.GET, {task_id = self.m_task[1]},"limit_time_war_get_reward")
        elseif btnTag == 12 then  --领取奖励
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer()).data
                self.m_data = data
                game_util:rewardTipsByDataTable(data["reward"]);
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("limit_time_war_get_reward"), http_request_method.GET, {task_id = self.m_task[2]},"limit_time_war_get_reward")
        elseif btnTag == 13 then  --领取奖励
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer()).data
                self.m_data = data
                game_util:rewardTipsByDataTable(data["reward"]);
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("limit_time_war_get_reward"), http_request_method.GET, {task_id = self.m_task[3]},"limit_time_war_get_reward")
        elseif btnTag == 100 then--
           local info1 = self.m_replace_cfg[self.m_task[1]]["reward_s"][1]
           if #info1 > 1 then
               local tempType = info1[1]
               if tempType == 6 then--道具
                   local itemId = info1[2]
                   game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
               elseif tempType == 7 then--装备
                   local equipId = info[2]
                   local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                   game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
               elseif tempType == 5 then--卡牌
                   local cId = info1[2]
                   game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
               else                   -- 食品
                   game_scene:addPop("game_food_info_pop",{itemData = info1})
               end
           end
        elseif btnTag == 101 then--
           local info1 = self.m_replace_cfg[self.m_task[1]]["reward_ss"][1]
           if #info1 > 1 then
               local tempType = info1[1]
               if tempType == 6 then--道具
                   local itemId = info1[2]
                   game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
               elseif tempType == 7 then--装备
                   local equipId = info[2]
                   local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                   game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
               elseif tempType == 5 then--卡牌
                   local cId = info1[2]
                   game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
               else                   -- 食品
                   game_scene:addPop("game_food_info_pop",{itemData = info1})
               end
           end
        elseif btnTag == 102 then--
           local info1 = self.m_replace_cfg[self.m_task[1]]["reward_sss"][1]
           if #info1 > 1 then
               local tempType = info1[1]
               if tempType == 6 then--道具
                   local itemId = info1[2]
                   game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
               elseif tempType == 7 then--装备
                   local equipId = info[2]
                   local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                   game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
               elseif tempType == 5 then--卡牌
                   local cId = info1[2]
                   game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
               else                   -- 食品
                   game_scene:addPop("game_food_info_pop",{itemData = info1})
               end
           end
        elseif btnTag == 103 then--
           local info1 = self.m_replace_cfg[self.m_task[2]]["reward_s"][1]
           if #info1 > 1 then
               local tempType = info1[1]
               if tempType == 6 then--道具
                   local itemId = info1[2]
                   game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
               elseif tempType == 7 then--装备
                   local equipId = info[2]
                   local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                   game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
               elseif tempType == 5 then--卡牌
                   local cId = info1[2]
                   game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
               else                   -- 食品
                   game_scene:addPop("game_food_info_pop",{itemData = info1})
               end
           end
        elseif btnTag == 104 then--
           local info1 = self.m_replace_cfg[self.m_task[2]]["reward_ss"][1]
           if #info1 > 1 then
               local tempType = info1[1]
               if tempType == 6 then--道具
                   local itemId = info1[2]
                   game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
               elseif tempType == 7 then--装备
                   local equipId = info[2]
                   local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                   game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
               elseif tempType == 5 then--卡牌
                   local cId = info1[2]
                   game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
               else                   -- 食品
                   game_scene:addPop("game_food_info_pop",{itemData = info1})
               end
           end
        elseif btnTag == 105 then--
           local info1 = self.m_replace_cfg[self.m_task[2]]["reward_sss"][1]
           if #info1 > 1 then
               local tempType = info1[1]
               if tempType == 6 then--道具
                   local itemId = info1[2]
                   game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
               elseif tempType == 7 then--装备
                   local equipId = info[2]
                   local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                   game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
               elseif tempType == 5 then--卡牌
                   local cId = info1[2]
                   game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
               else                   -- 食品
                   game_scene:addPop("game_food_info_pop",{itemData = info1})
               end
           end
        elseif btnTag == 106 then--
           local info1 = self.m_replace_cfg[self.m_task[3]]["reward_s"][1]
           if #info1 > 1 then
               local tempType = info1[1]
               if tempType == 6 then--道具
                   local itemId = info1[2]
                   game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
               elseif tempType == 7 then--装备
                   local equipId = info[2]
                   local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                   game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
               elseif tempType == 5 then--卡牌
                   local cId = info1[2]
                   game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
               else                   -- 食品
                   game_scene:addPop("game_food_info_pop",{itemData = info1})
               end
           end
        elseif btnTag == 107 then--
           local info1 = self.m_replace_cfg[self.m_task[3]]["reward_ss"][1]
           if #info1 > 1 then
               local tempType = info1[1]
               if tempType == 6 then--道具
                   local itemId = info1[2]
                   game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
               elseif tempType == 7 then--装备
                   local equipId = info[2]
                   local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                   game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
               elseif tempType == 5 then--卡牌
                   local cId = info1[2]
                   game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
               else                   -- 食品
                   game_scene:addPop("game_food_info_pop",{itemData = info1})
               end
           end
        elseif btnTag == 108 then--
           local info1 = self.m_replace_cfg[self.m_task[3]]["reward_sss"][1]
           if #info1 > 1 then
               local tempType = info1[1]
               if tempType == 6 then--道具
                   local itemId = info1[2]
                   game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
               elseif tempType == 7 then--装备
                   local equipId = info[2]
                   local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                   game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
               elseif tempType == 5 then--卡牌
                   local cId = info1[2]
                   game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
               else                   -- 食品
                   game_scene:addPop("game_food_info_pop",{itemData = info1})
               end
           end
        end
  
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_limit_time_war_pop.ccbi");

    local close = ccbNode:controlButtonForName("m_close_btn")
    local m_xiaqg_btn = ccbNode:controlButtonForName("m_xiaqg_btn")
    local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
    self.button1 = ccbNode:controlButtonForName("button1")
    local button2 = ccbNode:controlButtonForName("button2")
    self.button3 = ccbNode:controlButtonForName("button3")
    local button4 = ccbNode:controlButtonForName("button4")
    self.button5 = ccbNode:controlButtonForName("button5")
    local button6 = ccbNode:controlButtonForName("button6")
    self.button7 = ccbNode:controlButtonForName("button7")
    self.button8 = ccbNode:controlButtonForName("button8")
    self.button9 = ccbNode:controlButtonForName("button9")
    local button_100 = ccbNode:controlButtonForName("button_100")
    local button_101 = ccbNode:controlButtonForName("button_101")
    local button_102 = ccbNode:controlButtonForName("button_102")
    local button_103 = ccbNode:controlButtonForName("button_103")
    local button_104 = ccbNode:controlButtonForName("button_104")
    local button_105 = ccbNode:controlButtonForName("button_105")
    local button_106 = ccbNode:controlButtonForName("button_106")
    local button_107 = ccbNode:controlButtonForName("button_107")
    local button_108 = ccbNode:controlButtonForName("button_108")
    button_100:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    button_101:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    button_102:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    button_103:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    button_104:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    button_105:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    button_106:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    button_107:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    button_108:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    button_100:setOpacity(0)
    button_101:setOpacity(0)
    button_102:setOpacity(0)
    button_103:setOpacity(0)
    button_104:setOpacity(0)
    button_105:setOpacity(0)
    button_106:setOpacity(0)
    button_107:setOpacity(0)
    button_108:setOpacity(0)

    close:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_xiaqg_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_buy_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.button1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    button2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.button3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    button4:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.button5:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    button6:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.button7:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.button8:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.button9:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.m_time_label = ccbNode:labelTTFForName("m_label_time")
    self.m_score_label = ccbNode:labelTTFForName("m_score_label")

    self.m_task_nubel = ccbNode:labelTTFForName("m_task_nubel")
    self.m_wav_numbel = ccbNode:labelTTFForName("m_wav_numbel")

    self.time_label1 = ccbNode:labelTTFForName("time_label1")
    self.time_label2 = ccbNode:labelTTFForName("time_label2")
    self.time_label3 = ccbNode:labelTTFForName("time_label3")

    self.name_label = {}
    for i=1,3 do
        local str = "name_label"..i
        local node = ccbNode:labelTTFForName(str)
        self.name_label[#self.name_label + 1] = node
    end
    
    self.m_table_node = {}
    for i=1,3 do
        for j=1,3 do
             local str = "item".. i .."_node"..j
             local node = ccbNode:nodeForName(str)
             self.m_table_node[#self.m_table_node+1] = node
         end 
    end

    local m_possbill_sp = ccbNode:spriteForName("m_possbill_sp")
    local m_leaf_sp = ccbNode:spriteForName("m_leaf_sp")
    local m_hero_name = ccbNode:labelTTFForName("m_hero_name")

    self.m_hero_select_btn = ccbNode:controlButtonForName("m_hero_select_btn")


    self.m_ccbNode = ccbNode
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    --self.m_rank_list = ccbNode:layerForName("m_rank_list")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then

        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);

    return ccbNode;
end

--[[--
    刷新ui
]]
function game_limit_time_war_pop.refreshUi(self)
    local itemsData = game_data:getItemsData()
    local saizi_count = 0
    local gold_count = 0
    for k,v in pairs(itemsData) do
        if k == "92854" then
            for k,v in pairs(v) do
                saizi_count = saizi_count + v
            end
        end
    end

    self.m_score_label:setString(self.m_data.score)
    local index = 0
    local id = 0
    for i, k in ipairs(self.m_task) do
        local v = self.m_replace_cfg[k]
        id = id + 1
        index = index + 1
        local node = self.m_table_node[index]
        local icon,name,count = game_util:getRewardByItemTable(v["reward_s"][1],false)
        local label = CCLabelTTF:create("X"..count,TYPE_FACE_TABLE.Arial_BoldMT,16)
        icon:setScale(0.8)
        label:setPosition(40,10)
        icon:addChild(label,99,99)
        node:addChild(icon)

        index = index + 1
        local node = self.m_table_node[index]
        local icon,name,count = game_util:getRewardByItemTable(v["reward_ss"][1],false)
        local label = CCLabelTTF:create("X"..count,TYPE_FACE_TABLE.Arial_BoldMT,16)
        icon:setScale(0.8)
        label:setPosition(40,10)
        icon:addChild(label,99,99)
        node:addChild(icon)

        index = index + 1
        local node = self.m_table_node[index]
        local icon,name,count = game_util:getRewardByItemTable(v["reward_sss"][1],false)
        local label = CCLabelTTF:create("X"..count,TYPE_FACE_TABLE.Arial_BoldMT,16)
        icon:setScale(0.8)
        label:setPosition(40,10)
        icon:addChild(label,99,99)
        node:addChild(icon)

        self.name_label[id]:setString(v["name"])
    end

    self.m_task_nubel:setString("Số lần chọn NV: "..self.m_data["choose_task_times"].. "lần")
    self.m_wav_numbel:setString("Số lượng bài xuất chinh: "..saizi_count.."lá")

    if self.m_data["tasks"][tostring(self.m_task[1])]["status"] == 0 then
        self.button1:setVisible(true)
        self.button7:setVisible(false)
    else
        self.button1:setVisible(false)
        self.button7:setVisible(true)
    end

    if self.m_data["tasks"][tostring(self.m_task[2])]["status"] == 0 then
        self.button3:setVisible(true)
        self.button8:setVisible(false)
    else
        self.button3:setVisible(false)
        self.button8:setVisible(true)
    end

    if self.m_data["tasks"][tostring(self.m_task[3])]["status"] == 0 then
        self.button5:setVisible(true)
        self.button9:setVisible(false)
    else
        self.button5:setVisible(false)
        self.button9:setVisible(true)
    end

    local hours,minutes,seconds = nil
    local hours1,minutes1,seconds1 = nil
    local hours2,minutes2,seconds2 = nil
    local hours3,minutes3,seconds3 = nil
    
    self.time = self.m_data["tasks"][tostring(self.m_task[1])]["remain_time"]
    self.time1 = self.m_data["tasks"][tostring(self.m_task[2])]["remain_time"]
    self.time2 = self.m_data["tasks"][tostring(self.m_task[3])]["remain_time"]

    if self.m_shared == nil then
        function tick()
            if self.m_data.remain_time > 0 then
                hours = math.floor(self.m_data.remain_time / 3600)
                minutes = math.floor((self.m_data.remain_time - hours * 3600)/ 60)
                seconds = math.floor(self.m_data.remain_time - 3600 * hours - 60 * minutes)
                hours = hours<10 and "0"..hours or ""..hours
                minutes = minutes<10 and "0"..minutes or ""..minutes
                seconds = seconds<10 and "0"..seconds or ""..seconds
                self.m_time_label:setString(""..hours..":"..minutes..":"..seconds)
                self.m_data.remain_time = self.m_data.remain_time - 1
            else
                -- self:back()
                self.m_time_label:setString("活动已结束")
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
                self.m_shared = nil
            end
            
            if self.time > 0 then
                hours1 = math.floor(self.time / 3600)
                minutes1 = math.floor((self.time - hours1 * 3600)/ 60)
                seconds1 = math.floor(self.time - 3600 * hours1 - 60 * minutes1)
                hours1 = hours1<10 and "0"..hours1 or ""..hours1
                minutes1 = minutes1<10 and "0"..minutes1 or ""..minutes1
                seconds1 = seconds1<10 and "0"..seconds1 or ""..seconds1
                self.time_label1:setString("Đếm ngược HĐ:"..hours1..":"..minutes1..":"..seconds1)
                self.time = self.time - 1
                
            else
                if self.m_data["tasks"][tostring(self.m_task[1])]["status"] == 2 then
                    self.time_label3:setString("任务已完成")
                else
                    self.time_label1:setString("NV chưa bắt đầu")
                end
            end
            
            if self.time1 > 0 then
                hours2 = math.floor(self.time1 / 3600)
                minutes2 = math.floor((self.time1 - hours2 * 3600)/ 60)
                seconds2 = math.floor(self.time1 - 3600 * hours2 - 60 * minutes2)
                hours2 = hours2<10 and "0"..hours2 or ""..hours2
                minutes2 = minutes2<10 and "0"..minutes2 or ""..minutes2
                seconds2 = seconds2<10 and "0"..seconds2 or ""..seconds2
                self.time_label2:setString("Đếm ngược HĐ:"..hours2..":"..minutes2..":"..seconds2)
                self.time1 = self.time1 - 1
                
            else
                if self.m_data["tasks"][tostring(self.m_task[2])]["status"] == 2 then
                    self.time_label2:setString("任务已完成")
                else
                    self.time_label2:setString("NV chưa bắt đầu")
                end  
            end

            if self.time2 > 0 then
                hours3 = math.floor(self.time2 / 3600)
                minutes3 = math.floor((self.time2 - hours3 * 3600)/ 60)
                seconds3 = math.floor(self.time2 - 3600 * hours3 - 60 * minutes3)
                hours3 = hours3<10 and "0"..hours3 or ""..hours3
                minutes3 = minutes3<10 and "0"..minutes3 or ""..minutes3
                seconds3 = seconds3<10 and "0"..seconds3 or ""..seconds3
                self.time_label3:setString("Đếm ngược HĐ:"..hours3..":"..minutes3..":"..seconds3)
                self.time2 = self.time2 - 1
                
            else
                if self.m_data["tasks"][tostring(self.m_task[3])]["status"] == 2 then
                    self.time_label1:setString("任务已完成")
                else
                    self.time_label3:setString("NV chưa bắt đầu")
                end
            end

        end
        self.m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1 , false)
    end
end

--[[--
    初始化
]]
function game_limit_time_war_pop.init(self,t_params)
    local params = t_params.gameData or {};
  
    self.m_data = json.decode(params:getNodeWithKey("data"):getFormatBuffer())

    local cfg_rank =  getConfig(game_config_field.chuzheng_task)
    local data = json.decode(cfg_rank:getFormatBuffer())

    local cfg_version =  getConfig(game_config_field.chuzheng_version)
    local version_data = json.decode(cfg_version:getFormatBuffer())

    self.m_task = version_data[tostring(self.m_data["version"])]["task"]

    self.m_replace_cfg = {}
    for i,v in ipairs(self.m_task) do
        self.m_replace_cfg[v] = data[tostring(v)]
    end
    
    --cclog2(self.m_data,"m_data")
    cclog2(self.m_replace_cfg,"m_replace_cfg")
    --cclog2(self.vsr_data,"version_data")
end

--[[--
    创建ui入口并初始化数据
]]
function game_limit_time_war_pop.create(self,t_params)
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end

return game_limit_time_war_pop;
