--- 红包
local game_server_redpacket_pop = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    select_index = nil,
    tips_label = nil,
    reward_node = nil,
    btn_get = nil,
    m_tGameData = nil,
    text_scroll = nil,
    content_node = nil,
};
--[[--
    销毁
]]
function game_server_redpacket_pop.destroy(self)
    -- body
    cclog("-----------------game_server_redpacket_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.select_index = nil;

    self.table_node = nil;
    self.sprite_select = nil;
    self.btn_type = nil;
    self.tips_label = nil;
    self.reward_node = nil;
    self.btn_get = nil;
    self.m_tGameData = nil;
    self.text_scroll = nil;
    self.content_node = nil;
end
--[[--
    返回
]]
function game_server_redpacket_pop.back(self,type)
    game_scene:removePopByName("game_server_redpacket_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_server_redpacket_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 101 then--  领取
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                local reward = data:getNodeWithKey("reward")
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi()
                game_util:rewardTipsByJsonData(reward);
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("redpacket_server_reward"), http_request_method.GET, {red_id = self.m_tGameData.config_id},"redpacket_server_reward")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_game_redpacket.ccbi");

    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.countdown_node = ccbNode:nodeForName("countdown_node")
    self.btn_get = ccbNode:controlButtonForName("btn_get");
    self.btn_get:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.tips_label = ccbNode:labelTTFForName("tips_label")
    self.reward_node = ccbNode:nodeForName("reward_node")

    self.text_scroll = ccbNode:scrollViewForName("text_scroll")
    self.text_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    self.content_node = ccbNode:nodeForName("content_node")
    
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
function game_server_redpacket_pop.refreshUi(self)
    local remain_time = 100
    self.countdown_node:removeAllChildrenWithCleanup(true)
    local function timeOverCallFun()
        
    end
    local timeLabel = game_util:createCountdownLabel(self.m_tGameData.remain_time,timeOverCallFun)
    timeLabel:setAnchorPoint(ccp(0.5,0.5))
    timeLabel:setColor(ccc3(190,253,60))
    timeLabel:setPosition(ccp(0,0))
    self.countdown_node:addChild(timeLabel)

    local redpacket = getConfig(game_config_field.server_redpacket);
    local itemCfg = redpacket:getNodeWithKey(self.m_tGameData.config_id)
    local reward = itemCfg:getNodeWithKey("reward")
    local word = itemCfg:getNodeWithKey("word"):toStr()

    self.tips_label:setString("")
    self.reward_node:removeAllChildrenWithCleanup(true)
    local tableView = self:createRewardList(self.reward_node:getContentSize(),reward)
    self.reward_node:addChild(tableView,10,10);

    if self.m_tGameData.own == true then--已领取
        self.btn_get:setEnabled(false)
        game_util:setCCControlButtonBackground(self.btn_get,"redpacket_btn_2.png")
    else
        self.btn_get:setEnabled(true)
        game_util:setCCControlButtonBackground(self.btn_get,"redpacket_btn.png")
    end

    local viewSize = self.content_node:getContentSize()
    self.text_scroll:getContainer():removeAllChildrenWithCleanup(true);
    local tempLabel = game_util:createRichLabelTTF({text = word,dimensions = CCSizeMake(240,0),textAlignment = kCCTextAlignmentCenter,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(255,255,255),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    self.text_scroll:setContentSize(CCSizeMake(240,tempSize.height))
    -- if tempSize.height > viewSize.height then
        self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    -- end
    self.text_scroll:addChild(tempLabel)
end
--[[
    奖励列表
]]
function game_server_redpacket_pop.createRewardList(self,viewSize,reward)
    local tempCount = reward:getNodeCount()
    local rewardTab = json.decode(reward:getFormatBuffer())
    local params = {};
    params.row = 1;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = tempCount
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local  num  = tempCount%params.column
    if num == 0 then 
        num = params.column
    end
    local itemSize = CCSizeMake(viewSize.width/ params.column,viewSize.height/params.row);
    -- local itemSize = CCSizeMake(viewSize.width/params.column ,viewSize.height/params.row);
    -- params.viewSize = CCSizeMake(tempCount * itemSize.width, viewSize.height);
    params.viewSize = viewSize
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local icon,name,count = game_util:getRewardByItemTable(rewardTab[index+1],true)
            if icon then
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
                icon:setScale(0.65);
                cell:addChild(icon)
            end
            if name then
                local tempLabel = game_util:createLabelTTF({text = name,color = ccc3(255,255,255),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.15))
                game_util.adaptNodeScaleX(tempLabel, itemSize.width)
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(rewardTab[index+1]);
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    初始化
]]
function game_server_redpacket_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_server_redpacket_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_server_redpacket_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return game_server_redpacket_pop;