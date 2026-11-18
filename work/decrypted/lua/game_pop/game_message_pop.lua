--- 消息詳細

local game_message_pop = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,

    title_label = nil,
    content_label = nil,
    award_node = nil,
    m_reward_btn = nil, 
    fuken_node = nil,
    content_node = nil,
    show_node = nil,
    text_scroll = nil,
};
--[[--
    銷毀
]]
function game_message_pop.destroy(self)
    -- body
    cclog("-----------------game_message_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;

    self.title_label = nil;
    self.content_label = nil;
    self.award_node = nil;
    self.m_reward_btn = nil;
    self.fuken_node = nil;
    self.content_node = nil;
    self.show_node = nil;
    self.text_scroll = nil;
end
--[[--
    返回
]]
function game_message_pop.back(self,type)
    game_scene:removePopByName("game_message_pop");
end
--[[--
    讀取ccbi創建ui
]]
function game_message_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
        if btnTag == 100 then
            -- self:receiveAwards(btnTag);
            self.m_tParams.okBtnCallBack()
        elseif btnTag == 101 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_notify_message_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");

    self.title_label = ccbNode:labelTTFForName("title_label")
    self.content_label = ccbNode:labelTTFForName("content_label")
    self.content_node = ccbNode:nodeForName("content_node")
    self.show_node = ccbNode:nodeForName("show_node")
    self.text_scroll = ccbNode:scrollViewForName("text_scroll")
    self.text_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    self.award_node = {}
    for i=1,4 do
        self.award_node[i] = ccbNode:nodeForName("award_node_" .. i)
        cclog("self.award_node[i] == " .. tostring(self.award_node[i]))
    end
    
    self.m_reward_btn = ccbNode:controlButtonForName("m_reward_btn")
    self.fuken_node = ccbNode:nodeForName("fuken_node")

    game_util:setControlButtonTitleBMFont(self.m_reward_btn)
    self.m_reward_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local back_btn = ccbNode:controlButtonForName("back_btn")
    back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)

    local itemData = self.messages
    if itemData.send_name == "sys" then
        self.title_label:setString("Thông tin hệ thống")
    else
        self.title_label:setString(itemData.send_name)
    end

    self.content_label:setString(itemData.content)
    self:createContentTable(self.content_node:getContentSize(),itemData.content)

    local rewardList = itemData.gift
    for i=1,4 do
        self.award_node[i]:removeAllChildrenWithCleanup(true)
    end
    if #rewardList > 0 then
        self.fuken_node:setVisible(true)
        self.m_reward_btn:setTitleForState(CCString:create("Nhận"),CCControlStateNormal)
        --[[
        for i=1,math.min(4,#rewardList) do
            local itemGift = rewardList[i]
            -- cclog("itemGift = " .. json.encode(itemGift))
            local icon,name,count = game_util:getRewardByItemTable(itemGift)
            if icon then
                icon:setScale(0.7)
                icon:setAnchorPoint(ccp(0.5,0.5))
                -- icon:setPosition(ccp(0,25*(i-1)))
                icon:setPosition(ccp(0,0))
                self.award_node[i]:addChild(icon,10)
            end
            if count then
                local label_count = game_util:createLabelTTF({text = "×" .. count,color = ccc3(102,67,35),fontSize = 12})
                label_count:setAnchorPoint(ccp(0.5,0.5))
                -- label_count:setPosition(ccp(35,25*(i-1)))
                label_count:setPosition(ccp(0,-22))
                self.award_node[i]:addChild(label_count,10)
            end
        end
        ]]
        self.show_node:removeAllChildrenWithCleanup(true)
        local tempTable = self:createRewardTable(self.show_node:getContentSize(),#rewardList,rewardList)
        self.show_node:addChild(tempTable)
    else
        self.m_reward_btn:setTitleForState(CCString:create("Xác định"),CCControlStateNormal)
        self.fuken_node:setVisible(false)
    end

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
--[[
    獎勵列表
]]
function game_message_pop.createRewardTable(self,viewSize,count,rewardList)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 4; --列
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionHorizontal;--縱向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5,0.5))
            node:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            local itemGift = rewardList[index+1]
            local icon,name,count = game_util:getRewardByItemTable(itemGift)
            node:removeAllChildrenWithCleanup(true)
            if icon then
                icon:setScale(0.7)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,2))
                node:addChild(icon,10)
            end
            if count then
                local label_count = game_util:createLabelTTF({text = "×" .. count,color = ccc3(102,67,35),fontSize = 12})
                label_count:setAnchorPoint(ccp(0.5,0.5))
                label_count:setPosition(ccp(0,-20))
                node:addChild(label_count,10)
            end
            cell:addChild(node)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        
    end
    return TableViewHelper:createGallery2(params);
end

function game_message_pop.receiveAwards(self,index)
    local tGameData = self.m_tGameData.messages or {};
    local itemData = tGameData[index+1]
    function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
        game_util:rewardTipsByDataTable(self.m_tGameData.reward);
        self:refreshUi();
    end
    local params = {};
    params.message_id = itemData.id;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("notify_read"), http_request_method.GET, params,"notify_read")
end
--[[
    內容列表
]]
function game_message_pop.createContentTable(self,viewSize,contentText)
    -- local textCount = 1;
    -- local params = {};
    -- params.viewSize = viewSize;
    -- params.row = 1;
    -- params.column = 1; --列
    -- params.totalItem = textCount;
    -- params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    -- params.itemActionFlag = false;
    -- params.direction = kCCScrollViewDirectionVertical;--縱向
    -- local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    -- params.newCell = function(tableView,index) 
    --     local cell = tableView:dequeueCell()
    --     if cell == nil then
    --         cell = CCTableViewCell:new();
    --         cell:autorelease();
    --         local tempLabel = game_util:createLabelTTF({text = contentText,color = ccc3(122,84,46),fontSize = 12})
    --         tempLabel:setDimensions(CCSizeMake(190,140))
    --         tempLabel:setAnchorPoint(ccp(0.5,0.5))
    --         tempLabel:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5-2))
    --         tempLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
    --         tempLabel:setVerticalAlignment(kCCVerticalTextAlignmentCenter)
    --         cell:addChild(tempLabel)    
    --     end
    --     return cell;
    -- end
    -- return TableViewHelper:create(params);
    local tempLabel = game_util:createLabelTTF({text = contentText,color = ccc3(122,84,46),fontSize = 12})
    tempLabel:setDimensions(CCSizeMake(200,0))
    tempLabel:setAnchorPoint(ccp(0,0))
    tempLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
    tempLabel:setVerticalAlignment(kCCVerticalTextAlignmentTop)
    local tempSize = tempLabel:getContentSize();
    self.text_scroll:setContentSize(CCSizeMake(200,tempSize.height))
    if tempSize.height > viewSize.height then
        self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    else
        self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height - 20), false)
    end
    self.text_scroll:addChild(tempLabel)
end

--[[--
    刷新ui
]]
function game_message_pop.refreshUi(self)
    
end
--[[--
    初始化
]]
function game_message_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    -- cclog("self.m_tParams == " .. json.encode(self.m_tParams))
    self.messages = t_params.messages
end
--[[--
    創建ui入口並初始化數據
]]
function game_message_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回調方法
]]
function game_message_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return game_message_pop;