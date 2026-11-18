--新包
local game_newpackage_getgift_pop = {
	m_root_layer = nil,
	btn_get = nil,
	reward_node = nil,
	tips_label = nil,
	m_close_btn = nil,
	content_node = nil,
	text_scroll = nil,
}
function game_newpackage_getgift_pop.destroy( self )
	-- body
	self.btn_get = nil;
	self.m_root_layer = nil;
	self.reward_node = nil;
	self.tips_label = nil;
	self.m_close_btn = nil;
	self.content_node = nil;
	self.text_scroll = nil;
    cclog("-----------------game_newpackage_getgift_pop destroy-----------------")
end
function game_newpackage_getgift_pop.back( self )
	 -- game_scene:removePopByName("game_newpackage_getgift_pop");
     game_scene:enterGameUi("game_main_scene",{gameData = nil});
end
function game_newpackage_getgift_pop.createUi( self )
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
                -- self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                -- self:back();
                -- cclog2(reward, "reward ==  ycr =====")
                game_util:rewardTipsByJsonData(reward);
                local function endCallFunc()
		            
		        end
		        -- game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
                
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_receive_version_reward"), http_request_method.GET, {},"reward_receive_version_reward")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_game_newpackage_gift.ccbi");

    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.reward_node = ccbNode:nodeForName("reward_node")
    self.tips_label = ccbNode:labelTTFForName("tips_label")
    self.content_node = ccbNode:nodeForName("content_node")
    self.text_scroll = ccbNode:scrollViewForName("text_scroll")
    self.text_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    self.btn_get = ccbNode:controlButtonForName("btn_get");
    self.btn_get:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
   
    -- self:createText(self.text_scroll:getContentSize())
    return ccbNode;
end
function game_newpackage_getgift_pop.createText(self,viewSize)

end
function game_newpackage_getgift_pop.createRewardList(self,viewSize,reward)
 
end
function game_newpackage_getgift_pop.refreshUi( self )

    local version_reward = getConfig(game_config_field.version_reward);
    -- cclog("version_reward" .. version_reward)
    local Count = version_reward:getNodeCount();
    local itemCfg = version_reward:getNodeWithKey(tostring(Count))
    local reward = itemCfg:getNodeWithKey("gift")
    local word = itemCfg:getNodeWithKey("new_version_notice"):toStr()

    self.tips_label:setString("")
    self.reward_node:removeAllChildrenWithCleanup(true)
    local tableView = self:createRewardList(self.reward_node:getContentSize(),reward)
    self.reward_node:addChild(tableView,10,10);

    local viewSize = self.content_node:getContentSize()
    self.text_scroll:getContainer():removeAllChildrenWithCleanup(true);
    if self.is_new_version == false then
		-- word = "您需要更新到最新版本"..itemCfg:getNodeWithKey("version_name"):toStr().."才可以领取奖励～" .. "(您当前版本是：".. CLIENT_VERSION ..")"
		word = itemCfg:getNodeWithKey("old_version_notice"):toStr()
        self.btn_get:setTouchEnabled(false);
		game_util:setCCControlButtonBackground(self.btn_get,"redpacket_btn_hui.png")
	end
	local tempLabel = game_util:createRichLabelTTF({text = word,dimensions = CCSizeMake(240,0),textAlignment = kCCTextAlignmentCenter,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(255,255,255),fontSize = 12})
	local tempSize = tempLabel:getContentSize();
    self.text_scroll:setContentSize(CCSizeMake(240,tempSize.height))
    self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.text_scroll:addChild(tempLabel)

end
--[[
    奖励列表
]]
function game_newpackage_getgift_pop.createRewardList(self,viewSize,reward)
    local tempCount = reward:getNodeCount()
    local rewardTab = json.decode(reward:getFormatBuffer())
    local params = {};
    params.row = 1;--行
    params.column = tempCount; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = tempCount
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.viewSize = CCSizeMake(tempCount * itemSize.width, viewSize.height);
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
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(rewardTab[index+1]);
        end
    end
    return TableViewHelper:create(params);
end
function game_newpackage_getgift_pop.refreshData( self )

end
function game_newpackage_getgift_pop.init( self,t_params )
	self.m_tParams = t_params or {};
    self.is_new_version = self.m_tParams.is_new_version;
    -- cclog2(self.is_new_version,"is_new_versionis_new_version = = = = = = = = = = ")
end
function game_newpackage_getgift_pop.create( self,t_params )
	self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end
--[[--
    回调方法
]]
function game_newpackage_getgift_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end
return game_newpackage_getgift_pop;