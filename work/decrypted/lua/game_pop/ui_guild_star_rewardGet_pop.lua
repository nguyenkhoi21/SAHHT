local ui_guild_star_rewardGet_pop = {
    ccbNode = nil,
    m_list_node1 = nil,
    m_list_node2 = nil,
    m_icon_node = nil,
    m_rank_sp = nil,
    m_rank_sp2 = nil,
    m_lb1 = nil,
    m_lb2 = nil,
    m_lb3 = nil,
    m_lb4 = nil,
    m_root_layer = nil,
    m_name_label = nil,
    m_tGameData = nil,
} 

function ui_guild_star_rewardGet_pop:destroy()
    cclog("-------- ui_guild_star_rewardGet_pop destroy --------")
    self.ccbNode = nil;
    self.m_list_node1 = nil;
    self.m_list_node2 = nil;
    self.m_icon_node = nil;
    self.m_rank_sp = nil;
    self.m_rank_sp2 = nil;
    self.m_lb1 = nil;
    self.m_lb2 = nil;
    self.m_lb3 = nil;
    self.m_lb4 = nil;
    self.m_root_layer = nil;
    self.m_name_label = nil;
    self.m_tGameData = nil;
end



function ui_guild_star_rewardGet_pop:back()
	if self.callback then
		self.callback()
	end
	game_scene:removePopByName("ui_guild_star_rewardGet_pop")
end



function ui_guild_star_rewardGet_pop:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 1 then
			self:back()
		elseif btnTag == 4 then
			local function responseMethod( tag,gameData )
				if gameData then
    				game_scene:addPop("ui_guild_star_rankPop",{gameData = gameData})
				end
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_get_rank"), http_request_method.GET, nil,"guild_robbery_get_rank")
		end
	end
	local ccbNode =  luaCCBNode:create();
	self.ccbNode = ccbNode
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_guild_Star_rewardGetPop.ccbi")
    ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
    ccbNode:controlButtonForName("m_rank_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)


    self.m_list_node1 = ccbNode:nodeForName("m_score_reward")
    self.m_list_node2 = ccbNode:nodeForName("m_occ_reward")

    self.m_icon_node = ccbNode:nodeForName("m_icon_node")
    self.m_rank_sp = ccbNode:spriteForName("m_rank_sp")
    self.m_rank_sp2 = ccbNode:spriteForName("m_rank_sp2")
    self.m_lb1 = ccbNode:labelTTFForName("m_lb1")
    self.m_lb2 = ccbNode:labelTTFForName("m_lb2")
    self.m_lb3 = ccbNode:labelTTFForName("m_lb3")
    self.m_lb4 = ccbNode:labelTTFForName("m_lb4")
    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.m_name_label = ccbNode:nodeForName("m_name_label")
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_root_layer:setTouchEnabled(true);

	return ccbNode
end


function ui_guild_star_rewardGet_pop:createTableView(viewSize,data)
	
end


function ui_guild_star_rewardGet_pop:createReward(node,tab)
	node:removeAllChildrenWithCleanup(true)
	function onBtnCilck( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
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
                icon:setPosition( width_half*(i*2-1), size.height * 0.4 )
                icon:setScale(0.6)
                node:addChild(icon, -1, 20)

                if name and count then
                    local labelName = game_util:createLabelTTF({text = "x" .. count, fontSize = 12, color = ccc3(255, 255, 255)})
                    labelName:setAnchorPoint(ccp(0.5, 1))
                    labelName:setPosition(icon:getContentSize().width -5,  5 )
                    icon:addChild(labelName, 10)
                end

                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition( icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5 )
                button:setOpacity(0)
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
                icon:addChild(button)
                button:setTag(i)
            end
        end
    end
end

function ui_guild_star_rewardGet_pop:refreshUi()
	self.m_lb1:setString(self.m_tGameData.have_capture)
	self.m_lb2:setString(self.m_tGameData.score_every)
	self.m_lb3:setString(self.m_tGameData.persion_score)
       
    if self.m_tGameData.guild_rank < 4 then
    	self.m_lb4:setVisible(false)
    	self.m_rank_sp:setVisible(true)
    	self.m_rank_sp2:setVisible(true)
        local tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring("pvp_paihang_icon" .. tostring(self.m_tGameData.guild_rank) .. ".png"))
        local tempSpriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring("pvp_paihang_icon" .. tostring(self.m_tGameData.guild_rank) .. ".png"))
        if tempSpriteFrame1 and tempSpriteFrame2 then
            self.m_rank_sp:setDisplayFrame(tempSpriteFrame1)
            self.m_rank_sp2:setDisplayFrame(tempSpriteFrame2)
        end
    else
    	self.m_lb4:setVisible(true)
    	self.m_rank_sp:setVisible(false)
    	self.m_rank_sp2:setVisible(false)
    	self.m_lb4:setString("NO." .. self.m_tGameData.guild_rank + 1)
    end

    local sun_reward = self.m_tGameData.sun_reward or {}
    local rank_reward = self.m_tGameData.rank_reward or {}
    self:createReward(self.m_list_node1,rank_reward)
    self:createReward(self.m_list_node2,sun_reward)
    if #rank_reward == 0 then
    	local label = game_util:createLabelTTF({text = "Tích điểm guild hiện tại không có chiến lợi phẩm", fontSize = 9, color = ccc3(159, 241, 255)})
    	if label then
    		self.m_list_node1:removeAllChildrenWithCleanup(true)
    		label:setAnchorPoint(ccp(0.5,0.5))
    		label:setPosition(ccp(110,20))
    		self.m_list_node1:addChild(label)
    	end
    end
    if #sun_reward == 0 then
    	local label = game_util:createLabelTTF({text = "Chưa chiếm ngân hà chính, hãy nỗ lực tiếp!", fontSize = 11, color = ccc3(159, 241, 255)})
	    self.m_list_node2:removeAllChildrenWithCleanup(true)
		label:setAnchorPoint(ccp(0.5,0.5))
    	label:setPosition(ccp(110,20))
		self.m_list_node2:addChild(label)
    end

    -- self.m_name_label:setString("")
    self.m_name_label:removeAllChildrenWithCleanup(true)
    local nameLabel = game_util:createLabelTTF({text = self.m_tGameData.name, fontSize = 10, color = ccc3(159, 241, 255)})
    self.m_name_label:addChild(nameLabel)
    nameLabel:setAnchorPoint(ccp(0,0.5))
	local roleIcon = game_util:createPlayerRoleGardenIconByRoleId(self.m_tGameData.role or 1)
	if roleIcon then
		self.m_icon_node:removeAllChildrenWithCleanup(true)
		self.m_icon_node:addChild(roleIcon)
	end
    --159  241  255
end


function ui_guild_star_rewardGet_pop:init(t_params)
	t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
end


function ui_guild_star_rewardGet_pop:create(t_params)
	local scene = CCScene:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end
return ui_guild_star_rewardGet_pop
