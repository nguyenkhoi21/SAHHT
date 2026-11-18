--星域竞技场   评分奖励
local game_godfield_pvp_new_score_rew = {
	m_root_layer = nil,
	m_btn_back = nil,
	callback = nil,

    m_list_node = nil,
    m_tGameData = nil,
    m_enterType = nil,
    m_team_history_score = nil,
    m_rank_reward = nil,
    m_team_score = nil,
    m_reward_Tab = nil,
} 

function game_godfield_pvp_new_score_rew:destroy( )
    cclog("--------- game_godfield_pvp_new_score_rew destroy ---------")
	self.m_root_layer = nil;
	self.m_btn_back = nil;
	self.callback = nil;

    self.m_list_node = nil;
    self.m_tGameData = nil;
    self.m_enterType = nil;
    self.m_team_history_score = nil;
    self.m_rank_reward = nil;
    self.m_team_score = nil;
    self.m_reward_Tab = nil;
end



function game_godfield_pvp_new_score_rew:back()
	if self.callback then
		self.callback()
	end
	game_scene:removePopByName("game_godfield_pvp_new_score_rew")
end
local position_x = {
    {0.5,},
    {0.35,0.65},
    {0.25,0.5,0.75},
    {0.2,0.4,0.6,0.8},
    {0.1,0.3,0.5,0.7,0.9},
}



function game_godfield_pvp_new_score_rew:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 1 then
			self:back()
		else
		end
	end
	local ccbNode =  luaCCBNode:create();
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_godfield_Arena_new_score_rew.ccbi")
	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_list_node = ccbNode:nodeForName("m_list_node")

    self.m_my_score = ccbNode:labelTTFForName("m_my_score")
    local m_back_layer = ccbNode:layerForName("m_back_layer")
    local function onTouch2(eventType, x, y)
        if eventType == "began" then
            local realPos = m_back_layer:getParent():convertToNodeSpace(ccp(x,y));
            if not m_back_layer:boundingBox():containsPoint(realPos) then
            	self:back()
            end
            return true;

        elseif eventType == "ended" then
        end
    end
    m_back_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-5,true);
    m_back_layer:setTouchEnabled(true);
	return ccbNode
end

--ui_godfield_Arena_new_score_rew_Item.ccbi




function game_godfield_pvp_new_score_rew:createTableView(viewSize)

	local function onClick( event,target )
	    local tagNode = tolua.cast(target, "CCNode");
	    local btnTag = tagNode:getTag();
	end
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
        local function responseMethod( tag,gameData )
        	local data = gameData:getNodeWithKey("data");
	        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            self.m_team_history_score = self.m_tGameData.team_history_score and self.m_tGameData.team_history_score[tostring(self.m_enterType)] or 0
	        game_util:rewardTipsByDataTable(self.m_tGameData.reward)
	    	self.m_rank_reward = self.m_tGameData.rank_reward[tostring(self.m_enterType)] or {}
	    	self:refreshUi()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_get_reward"), http_request_method.GET, {team_id = self.m_enterType,reward_id=btnTag},"universe_arena_get_reward")
	end
    local showData = self.m_reward_Tab
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = game_util:getTableLen(showData) --totalItem;
    -- params.totalItem = 5
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
			ccbNode:registerFunctionWithFuncName("onMianClick",onMainBtnClick)
			ccbNode:openCCBFile("ccb/ui_godfield_Arena_new_score_rew_Item.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = showData[index+1]
            local m_rank_lb = ccbNode:labelTTFForName("m_rank_lb")
            local m_get_lb = ccbNode:labelTTFForName("m_get_lb")
            local m_rank_sp = ccbNode:spriteForName("m_rank_sp")
            local m_btn_get = ccbNode:controlButtonForName("m_btn_get")
            m_btn_get:setTouchPriority(GLOBAL_TOUCH_PRIORITY-7)
            local score = itemData.score[1] or 0
            m_rank_lb:setString(score)

            if self.m_team_history_score >= score and not self.m_rank_reward[tostring(itemData.id)] then
            	m_btn_get:setVisible(true)
            	m_get_lb:setVisible(false)
            	m_btn_get:setTag(itemData.id)
            else
            	m_btn_get:setVisible(false)
            	m_get_lb:setVisible(true)
            	if self.m_rank_reward[tostring(itemData.id)] then
            		m_get_lb:setString("Đã nhận")
            	else
            		m_get_lb:setString("Chưa đạt")
            	end
            end
            local reward = itemData.reward
        	local position = position_x[#reward]
        	local m_reward_node = ccbNode:nodeForName("m_reward_node")
        	m_reward_node:removeAllChildrenWithCleanup(true);
        	local viewSize = m_reward_node:getContentSize()
        	for k,v in pairs(reward) do
        		local icon,name,count = game_util:getRewardByItemTable(v);
                if icon then
                    icon:setScale(0.7)
                	icon:setPosition(ccp(viewSize.width*position[k],viewSize.height*0.5))
                    m_reward_node:addChild(icon);
	                local numLab = CCLabelTTF:create("x" .. count,TYPE_FACE_TABLE.Arial_BoldMT,10)
	    	  	    icon:addChild(numLab,10,10)
	    	  	    numLab:setPosition(ccp(50,0))
    	  	        local button = game_util:createCCControlButton("public_weapon.png","",onClick)
				    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
				    local tempSize = icon:getContentSize()
				    button:setAnchorPoint(ccp(0.5,0.5))
				    button:setPosition(ccp(tempSize.width * 0.5, tempSize.height* 0.5))
				    button:setOpacity(0)
				    icon:addChild(button,1)
				    button:setTag(itemData.id)
                end
        	end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
    end
    return TableViewHelper:create(params);
end



function game_godfield_pvp_new_score_rew:refreshUi()
	self.m_list_node:removeAllChildrenWithCleanup(true)
	local tempList = self:createTableView(self.m_list_node:getContentSize())
	if tempList then
		self.m_list_node:addChild(tempList)
	end
    self.m_my_score:setString(self.m_team_history_score)
end


function game_godfield_pvp_new_score_rew:init(t_params)


	t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_enterType = t_params.enterType or 1

    self.m_team_history_score = self.m_tGameData.team_history_score and self.m_tGameData.team_history_score[tostring(self.m_enterType)] or 0

    self.m_rank_reward = self.m_tGameData.rank_reward[tostring(self.m_enterType)] or {}


    local universe_arena_grade = getConfig(game_config_field.universe_arena_grade)
    universe_arena_grade = json.decode(universe_arena_grade:getFormatBuffer())
    local rewTab = {}
    for k,v in pairs(universe_arena_grade) do
    	if v.reward and next(v.reward) then
    		v.id = k
    		rewTab[#rewTab+1] = v
    	end
    end
    table.sort(rewTab,function(data1,data2) return tonumber(data1.id) < tonumber(data2.id) end)
    self.m_reward_Tab = rewTab
end



function game_godfield_pvp_new_score_rew:create(t_params)
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end


return game_godfield_pvp_new_score_rew
