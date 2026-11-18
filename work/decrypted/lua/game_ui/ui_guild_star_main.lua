local ui_guild_star_main = {
	m_open = nil,
	m_previewData = nil,
	m_battleType_sp = nil,
	m_sp_jiantou = nil,
	m_preview_node = nil,
	m_guildReward_node = nil,
	m_lb1 = nil,
	m_lb2 = nil,
	m_lb3 = nil,
	m_lb4 = nil,
	m_timer_label = nil,
	m_timer_label2 = nil,
	m_touchLayer = nil,
	m_ccbNode = nil,
	m_tGameData = nil,
}


function ui_guild_star_main:destroy()
	cclog(" ----------------- ui_guild_star_main destroy ---------------------------")

	self.m_open = nil;
	self.m_previewData = nil;
	self.m_battleType_sp = nil;
	self.m_sp_jiantou = nil;
	self.m_preview_node = nil;
	self.m_guildReward_node = nil;
	self.m_lb1 = nil;
	self.m_lb2 = nil;
	self.m_lb3 = nil;
	self.m_lb4 = nil;
	self.m_timer_label = nil;
	self.m_timer_label2 = nil;
	self.m_touchLayer = nil;
	self.m_ccbNode = nil;
	self.m_tGameData = nil;
end

function ui_guild_star_main:back(  )
	require("like_oo.oo_controlBase"):openView("guild");
end

function ui_guild_star_main:createUi(  )
	local ccbNode = luaCCBNode:create();
	local function onButtonClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
        	self:back()
        elseif btnTag == 2 then
        	game_scene:addPop("game_godfield_public_detail",{enterType= 200})
    	elseif btnTag == 3 then -- 箭头
    		if self.m_open == true then
    			self.m_open = false
    			self:refreshPreview()
    		else
    			self.m_open = true
    			local function responseMethod( tag,gameData )
					if gameData then
						local data = gameData:getNodeWithKey("data")
						self.m_previewData = json.decode(data:getFormatBuffer())
	    				self:refreshPreview()
					end
				end
				network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_see_reward"), http_request_method.GET, nil,"guild_robbery_see_reward",false)
    		end
    	elseif btnTag == 4 then -- 排行榜
			local function responseMethod( tag,gameData )
				if gameData then
    				game_scene:addPop("ui_guild_star_rankPop",{gameData = gameData})
				end
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_get_rank"), http_request_method.GET, nil,"guild_robbery_get_rank")
    	elseif btnTag == 5 then -- 领取奖励
    		local function responseMethod( tag,gameData )
				if gameData then
    				game_scene:addPop("ui_guild_star_rewardGet_pop",{gameData = gameData})
				end
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_see_reward_for_persion"), http_request_method.GET, nil,"guild_robbery_see_reward_for_persion")
    	elseif btnTag == 6 then
			local function responseMethod( tag,gameData )
				if gameData then
    				game_scene:addPop("ui_guild_star_rankPop",{gameData = gameData})
				end
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_get_rank"), http_request_method.GET, nil,"guild_robbery_get_rank")
        elseif btnTag == 7 then
			local function responseMethod( tag,gameData )
				if gameData then
        			game_scene:addPop("ui_guild_star_notice",{gameData= gameData})
				end
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_notice_index"), http_request_method.GET, nil,"guild_robbery_notice_index")
        elseif btnTag == 10 then -- 太阳
        	local function responseMethod( tag,gameData )
				if gameData then
					game_scene:enterGameUi("ui_guild_star_bigStar",{gameData = gameData})
					-- game_scene:enterGameUi("ui_guild_star_smallStar",{gameData = gameData,enterType = btnTag - 9})
				end
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_go_mountain"), http_request_method.GET, { mountain_id= 1},"guild_robbery_go_mountain")
		elseif btnTag > 10 and btnTag < 21 then
			local function responseMethod( tag,gameData )
				if gameData then
					game_scene:enterGameUi("ui_guild_star_smallStar",{gameData = gameData,enterType = btnTag - 9})
				end
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_go_mountain"), http_request_method.GET, { mountain_id= btnTag-9},"guild_robbery_go_mountain")
        end
	end
	ccbNode:registerFunctionWithFuncName( "onMainBtnClick",onButtonClick );
	ccbNode:openCCBFile("ccb/ui_guild_Star_main.ccbi");
	local m_btn_jiantou = ccbNode:controlButtonForName("m_btn_jiantou")
	m_btn_jiantou:setOpacity(0)
	m_btn_jiantou:setTouchPriority(-1)
	ccbNode:controlButtonForName("m_rank_btn"):setTouchPriority(-1)
	ccbNode:controlButtonForName("m_reward_btn"):setTouchPriority(-1)
	self.m_battleType_sp = ccbNode:spriteForName("m_battleType_sp")
	self.m_sp_jiantou = ccbNode:spriteForName("m_sp_jiantou")
	self.m_preview_node = ccbNode:nodeForName("m_preview_node")
	self.m_guildReward_node = ccbNode:nodeForName("m_guildReward_node")
	self.m_lb1 = ccbNode:labelTTFForName("m_lb1")
	self.m_lb2 = ccbNode:labelTTFForName("m_lb2")
	self.m_lb3 = ccbNode:labelTTFForName("m_lb3")
	self.m_lb4 = ccbNode:labelTTFForName("m_lb4")
	self.m_timer_label = ccbNode:nodeForName("m_timer_label")
	self.m_timer_label2 = ccbNode:labelTTFForName("m_timer_label2")

	for i=0,10 do
		local btn = ccbNode:controlButtonForName("m_starBtn" .. i)
		if btn then
			btn:setOpacity(0)
			btn:setTouchPriority(1)
		end
	end
	self.m_touchLayer = ccbNode:layerForName("m_touchLayer")
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then

        end
    end
    self.m_touchLayer:registerScriptTouchHandler(onTouch,false,0,true)
    self.m_touchLayer:setTouchEnabled(false)

	self.m_ccbNode = ccbNode
	return ccbNode
end

function ui_guild_star_main:refreshPreview(  ) --刷新预览
	local winSize = CCDirector:sharedDirector():getWinSize()
	local _,y = self.m_preview_node:getPosition()
	if self.m_open then
		self.m_sp_jiantou:setScaleX(-1)
   	 	self.m_touchLayer:setTouchEnabled(true)
   	 	self.m_touchLayer:setVisible(true)
	    self.m_preview_node:runAction(CCMoveTo:create(0.3,ccp(winSize.width - 200 ,y)));
		self.m_lb1:setString(self.m_previewData.hole_num)
		self.m_lb2:setString(self.m_previewData.point_every)
		self.m_lb3:setString(self.m_previewData.guild_score)
		self.m_lb4:setString(self.m_previewData.guild_rank)
	else
		self.m_sp_jiantou:setScaleX(1)
	    self.m_preview_node:runAction(CCMoveTo:create(0.3,ccp(winSize.width - 15 ,y)));
   	 	self.m_touchLayer:setTouchEnabled(false)
   	 	self.m_touchLayer:setVisible(false)
	end
end

function ui_guild_star_main:createTableView(viewSize,data) -- 公会
    local showData = data or {}
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = game_util:getTableLen(showData) 
    -- params.totalItem = 10
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
			ccbNode:openCCBFile("ccb/ui_guild_star_main_rewardItem.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = showData[index+1] or showData[tostring(index+1)]
            local m_reward_node = ccbNode:labelTTFForName("m_reward_node")
            local m_rank_lb = ccbNode:labelTTFForName("m_rank_lb")
            local m_rank_sp = ccbNode:spriteForName("m_rank_sp")
            self:createReward(m_reward_node,itemData.award)
            if index < 3 then
            	m_rank_lb:setVisible(false)
            	m_rank_sp:setVisible(true)
	            local tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring("pvp_paihang_icon" .. tostring(index+1) .. ".png"))
	            if tempSpriteFrame1 then
	                m_rank_sp:setDisplayFrame(tempSpriteFrame1)
	            end
            else
            	m_rank_lb:setVisible(true)
            	m_rank_sp:setVisible(false)
            	m_rank_lb:setString("NO." .. index + 1)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
    end
    return TableViewHelper:create(params);
end

function ui_guild_star_main:createReward(node,tab)
	node:removeAllChildrenWithCleanup(true)
	function onBtnCilck( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local day = btnTag/100
        local index = btnTag%100
        game_util:lookItemDetal( tab[btnTag] )
    end

	local size = node:getContentSize()
	local width_half = size.width/(#tab*2)
    for i=1, #tab do
        local rewardItem = tab[i]
        if rewardItem then
        local icon,name,count = game_util:getRewardByItemTable(rewardItem);
            if icon then
                icon:setAnchorPoint(ccp(0.5, 0.5))
                icon:setPosition( width_half*(i*2-1), size.height * 0.5 )
                icon:setScale(0.5)
                node:addChild(icon, -1, 20)

                if name and count then
                    local labelName = game_util:createLabelBMFont({text = "x" .. count, fontSize = 16, color = ccc3(255, 255, 255)})
                    labelName:setAnchorPoint(ccp(0.5, 1))
                    labelName:setPosition(icon:getContentSize().width -5,  5 )
                    icon:addChild(labelName, 10)
                end

                -- local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                -- button:setAnchorPoint(ccp(0.5,0.5))
                -- button:setPosition( icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5 )
                -- button:setOpacity(0)
                -- icon:addChild(button)
                -- button:setTag(i)
            end
        end
    end
end


function ui_guild_star_main:createRewardList()
	local thanos_rankawardCfg = getConfig(game_config_field.thanos_rankaward)
	local thanos_rankaward = json.decode(thanos_rankawardCfg:getFormatBuffer())
	local version = self.m_version
	local rewardTab = {}
	for k,v in pairs(thanos_rankaward) do
		if tonumber(v.version) == tonumber(version) and tonumber(v.rank[1]) == 1 then
			rewardTab[v.guild_rank] = v
		end
	end
	local tableView = self:createTableView(self.m_guildReward_node:getContentSize(),rewardTab)
	self.m_guildReward_node:removeAllChildrenWithCleanup(true)
	if tableView then
		self.m_guildReward_node:addChild(tableView)
	end
end


function ui_guild_star_main:refreshTimerLabel()
	-- body
	local fileName2 = "ui_guildStar_main_title1.png"
	if self.m_tGameData.can_battle == 1 then
		fileName2 = "ui_guildStar_main_title2.png"
	end

	local tempSpriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName2))
    if tempSpriteFrame2 then
        self.m_battleType_sp:setDisplayFrame(tempSpriteFrame2)
    end
	local function timeEndFunc(label,type)
		local function responseMethod( tag,gameData )
			if gameData then
				game_scene:enterGameUi("ui_guild_star_main",{gameData = gameData})
			end
		end
		network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_index"), http_request_method.GET, nil,"guild_robbery_index")
    end
	local labelSize = self.m_timer_label:getContentSize()
	-- self.m_timer_label:setString("")
	self.m_timer_label:setVisible(true)
	local countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8);
    countdownLabel:setPosition(ccp(0,0))
    countdownLabel:setAnchorPoint(ccp(0,0.5))
    if self.m_timer_label ~= nil then
        self.m_timer_label:removeAllChildrenWithCleanup(true)
    end
    self.m_timer_label:addChild(countdownLabel)
    if self.m_tGameData.expire then
    	countdownLabel:setTime(self.m_tGameData.expire + 1);
    end
end


function ui_guild_star_main:refreshUi(  )
	-- body
	local tempSpriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName2))
    if tempSpriteFrame2 then
        self.m_battleType_sp:setDisplayFrame(tempSpriteFrame2)
    end

	local people_name = self.m_tGameData.mountain_people_name or {}
	for i=1,10 do
		local tempNode = self.m_ccbNode:nodeForName("m_owner_node" .. i)
		local name_lb = self.m_ccbNode:nodeForName("m_owner_lb" .. i)
		local name = people_name[tostring(i+1)] or ""
		if name ~= nil and name ~= "" then
			tempNode:setVisible(true)
			-- name_lb:setString("")
			local tempLb = game_util:createLabelTTF({text = name,color = ccc3(120,255,255),fontSize = 9})
			name_lb:removeAllChildrenWithCleanup(true)
			name_lb:addChild(tempLb)
		else
			tempNode:setVisible(false)
		end
	end
	local ownerNode = self.m_ccbNode:nodeForName("m_owner_node0")
	local ownerName = self.m_ccbNode:nodeForName("m_owner_lb0")
	local name = people_name[tostring(1)] or ""
	if name ~= nil and name ~= "" then
		ownerNode:setVisible(true)
		-- ownerName:setString("")
		local tempLb = game_util:createLabelTTF({text = name,color = ccc3(120,255,255),fontSize = 10})
		ownerName:removeAllChildrenWithCleanup(true)
		ownerName:addChild(tempLb)
	else
		ownerNode:setVisible(false)
	end
    self:refreshPreview()
    self:createRewardList()

    self:refreshTimerLabel()
end

function ui_guild_star_main:init( t_params )
	-- body
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
	end
	self.m_version = self.m_tGameData.version or 1
	-- cclog2(self.m_tGameData,"      ----------------   ")
end

function ui_guild_star_main:create( t_params )
	local scene = CCScene:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene 
end

return ui_guild_star_main