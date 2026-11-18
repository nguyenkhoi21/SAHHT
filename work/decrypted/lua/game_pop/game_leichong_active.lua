local game_leichong_active = {
	m_table_node = nil,
	time_node = nil,
	m_tGameData = nil,
	myIndex = nil,
	selectIndex = nil,
    showCfg = nil,
    m_tableView = nil,
    showCfg = nil,
    m_version = nil,
}

function game_leichong_active:destroy(  )
    cclog("-----------------game_leichong_active destroy-----------------");
	self.m_table_node = nil;
	self.time_node = nil;
	self.m_tGameData = nil;
	self.myIndex = nil;
	self.selectIndex = nil;
    self.showCfg = nil;
    self.m_tableView = nil;
    self.showCfg = nil;
    self.m_version = nil;

end

function game_leichong_active:back(  )
	game_scene:enterGameUi("game_main_scene",{gameData = nil});
    self:destroy();
end

function game_leichong_active:createUi(  )
	local ccbNode = luaCCBNode:create()
	local function onBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 1 then
			self:back()
		elseif btnTag == 2 then
			local function responseMethod(tag,gameData)
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                --game_scene:addPop("ui_vip_show_pop");
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onBtnClick)
	ccbNode:openCCBFile("ccb/ui_leichong_active.ccbi")
	self.m_table_node = ccbNode:nodeForName("m_table_node")
	self.time_node = ccbNode:nodeForName("time_node")
	local m_jihuo_btn = ccbNode:controlButtonForName("m_jihuo_btn")
	local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
	m_jihuo_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 22)
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 22)

    local m_root_layer = ccbNode:layerForName("m_root_layer")
	-- local m_layer = ccbNode:layerForName("m_layer")
	local function onTouch( eventType,x,y )

		if eventType == "began" then
   --          cclog("9999999999")
			-- local realPos = self.m_table_node:getParent():convertToNodeSpace(ccp(x,y))
			-- if self.m_table_node:boundingBox():containsPoint(realPos) then
			-- 	return false
			-- end
			return true
        end
	end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true)
	-- m_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-20,true)
	m_root_layer:setTouchEnabled(true)
	return ccbNode
end

function game_leichong_active:createPorTable( viewSize )
    local rechargeData = {}
    cclog2(game_util:getTableLen(self.showCfg),"15656468645154646")
    for i=1,game_util:getTableLen(self.showCfg) do
            rechargeData = self.showCfg
    end
    cclog2(rechargeData,"123456789")
	local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- local charge_type = math.floor(btnTag / 100)
        local index = btnTag % 100

        local params = {}
        -- if 
        params.reward_id = rechargeData[index + 1].id
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local reward = data:getNodeWithKey("reward")
            game_util:rewardTipsByJsonData(reward);
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            self:refreshUi()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("recharge_get"), http_request_method.GET, params,"recharge_get")
    end

    local tabCount = game_util:getTableLen(rechargeData)

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
        local index = math.floor(btnTag / 100)
        local reward = rechargeData[index+1].reward
        local id = btnTag % 100
        local itemData = reward[id]
        game_util:lookItemDetal(itemData)
    end

    local nodeSizeW = 210
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tabCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 11
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_leichong_active_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local tip_word_label = ccbNode:labelTTFForName("tip_word_label")
            local btn_go = ccbNode:controlButtonForName("btn_go")
            btn_go:removeAllChildrenWithCleanup(true)
            btn_go:setScale(1)
            btn_go:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
            local reward_layer = ccbNode:layerForName("reward_layer")

            local rewardNode = {}
            local reward = rechargeData[index+1].reward
            
            local rewardCount = game_util:getTableLen(reward)
            for i=1,5 do
                rewardNode[i] = ccbNode:nodeForName("reward_node_" .. i)

                rewardNode[i]:removeAllChildrenWithCleanup(true)
                rewardNode[i]:setVisible(true)
                local dw = nodeSizeW / rewardCount
                local dx = dw / 2
                if i <= rewardCount then
                    local rewardItem = reward[i]
                    local reward_icon,name,count = game_util:getRewardByItemTable(rewardItem,true);
                    if reward_icon then
                        reward_icon:setAnchorPoint(ccp(0.5,0.5))
                        reward_icon:setScale(0.7)

                        rewardNode[i]:addChild(reward_icon)

                        rewardNode[i]:setPosition(ccp(dx + (i-1)*dw,33))
                        --加查看按钮
                        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                        button:setAnchorPoint(ccp(0.5,0.5))
                        button:setScale(0.7)
                        button:setTag(index * 100 + i)
                        button:setOpacity(0)
                        rewardNode[i]:addChild(button)

                        if count then
                            local nameLabel = game_util:createLabelTTF({text = "x" .. count})
                            nameLabel:setColor(ccc3(250,180,0))
                            nameLabel:setAnchorPoint(ccp(0.5, 0.5))
                            nameLabel:setPosition(reward_icon:getContentSize().width * 0.5, -10)
                            reward_icon:addChild(nameLabel, 11)
                        end
                    end
                    
                else
                    rewardNode[i]:setVisible(false)
                end
            end
            if  game_util:valueInTeam(rechargeData[index+1].id,self.m_tGameData.have_receive) then
                btn_go:setEnabled(false)
                game_util:setCCControlButtonBackground(btn_go,"leichong_yilingqu.png")
            elseif self.m_tGameData.pay_coin >= rechargeData[index+1].num then
                btn_go:setEnabled(true)
                game_util:setCCControlButtonBackground(btn_go,"leichong_lingqu.png")
            else
                btn_go:setEnabled(true)
                game_util:setCCControlButtonBackground(btn_go,"leichong_lingqu.png")
                btn_go:setColor(ccc3(100,100,100))
            end
            local pay_coin = self.m_tGameData.pay_coin or "0"
            local num = rechargeData[index+1].num
            des =   "Nạp thêm (" .. pay_coin .. "/" .. num .. ") Xu sẽ được nhậ"
            tip_word_label:setString(des)
            btn_go:setTag(self.myIndex * 100 + index)           
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then           
        end
    end
    return TableViewHelper:create(params);
end

function game_leichong_active:refreshLabel()
    local function timeEndFunc()
        
    end
    self.time_node:removeAllChildrenWithCleanup(true)
    local showActive = self.m_tGameData.remain_time
    local countdownLabel = game_util:createCountdownLabel(showActive,timeEndFunc,8,1);
    countdownLabel:setAnchorPoint(ccp(0,0.5))
    countdownLabel:setPosition(ccp(15,0))
    countdownLabel:setColor(ccc3(0,250,0))
    self.time_node:addChild(countdownLabel,10,10)
end

function game_leichong_active:refreshUi(  )
	local pX,pY;
    if self.m_tableView then
        pX,pY = self.m_tableView:getContainer():getPosition();
    end
	self.m_table_node:removeAllChildrenWithCleanup(true)
	self.m_tableView = self:createPorTable(self.m_table_node:getContentSize())
	self.m_table_node:addChild(self.m_tableView,10,10)
	if pX and pY then
        self.m_tableView:setContentOffset(ccp(pX,pY), false);
    end
    self:refreshLabel()
end



function game_leichong_active:init( t_params )
	t_params = t_params or {}
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
		local data = t_params.gameData:getNodeWithKey("data")
		self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
	else
		self.m_tGameData = {}
	end
    self.m_version = self.m_tGameData.version
	self.selectIndex = 1
    self.showCfg = {}
	local showCfg = getConfig(game_config_field.limit_gift)
	-- --去服务器数据来确定显示
    for i=1,showCfg:getNodeCount() do
        local itemCfg = showCfg:getNodeWithKey(tostring(i))
        local itemItemCfg = json.decode(itemCfg:getFormatBuffer())
        itemItemCfg.id = i
        if itemItemCfg.version == self.m_version then
            table.insert(self.showCfg,itemItemCfg)--存数据
        end
    end
    if game_util:getTableLen(self.showCfg) > 0 then
        self.myIndex = self.showCfg[self.selectIndex].id
    end
end

function game_leichong_active:create( t_params )
	self:init(t_params)
	local pop = self:createUi()
	self:refreshUi()
	return pop
end

return game_leichong_active