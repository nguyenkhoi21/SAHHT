-- 星域竞技场  排名奖励
local game_godfield_pvp_new_rank_rew = {
	m_root_layer = nil,
	m_btn_back = nil,
	callback = nil,

    ccbNode = nil,
    m_list_node = nil,
    m_universe_arena = nil,
    m_selectd_index = nil,
    m_tGameData = nil,
    m_enterType = nil,
} 

function game_godfield_pvp_new_rank_rew:destroy( )
    cclog(" -------- game_godfield_pvp_new_rank_rew destroy --------- ")
	self.m_root_layer = nil;
	self.m_btn_back = nil;
	self.callback = nil;

    self.ccbNode = nil;
    self.m_list_node = nil;
    self.m_universe_arena = nil;
    self.m_selectd_index = nil;
    self.m_tGameData = nil;
    self.m_enterType = nil;

end


function game_godfield_pvp_new_rank_rew:back()
	if self.callback then
		self.callback()
	end
	game_scene:removePopByName("game_godfield_pvp_new_rank_rew")
end

local position_x = {
    {0.5,},
    {0.35,0.65},
    {0.25,0.5,0.75},
    {0.2,0.4,0.6,0.8},
    {0.1,0.3,0.5,0.7,0.9},
}

function game_godfield_pvp_new_rank_rew:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
        self.m_enterType = btnTag 
        self:refreshUi()
	end
	local ccbNode =  luaCCBNode:create();
	self.ccbNode = ccbNode
	ccbNode:registerFunctionWithFuncName("onMainClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_godfield_Arena_new_rank_rew.ccbi")
	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_root_layer:setTouchEnabled(true);

    for i=1,4 do
        ccbNode:controlButtonForName("m_select_btn" .. i):setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
    	ccbNode:controlButtonForName("m_select_btn" .. i):setOpacity(0)
    end
    self.m_list_node = ccbNode:nodeForName("m_list_node")
    self.m_my_rank = ccbNode:labelTTFForName("m_my_rank")
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
    m_back_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-4,true);
    m_back_layer:setTouchEnabled(true);
	return ccbNode
end

function game_godfield_pvp_new_rank_rew:createTableView(viewSize)

	local function onClick( event,target )
	    local tagNode = tolua.cast(target, "CCNode");
	    local btnTag = tagNode:getTag();
	    local index1 = math.floor(btnTag/100)
	    local index2 = math.floor(btnTag%100)
	    local selectd = self.m_universe_arena[tostring(index1)]
	    local reward = {}
        if self.m_enterType < 4 then
        	reward = selectd["arena_" .. self.m_enterType] 
    	else
    		reward = selectd["arena_all"]
    	end
	    game_util:lookItemDetal(reward[index2])
	end

    local showData = self.m_universe_arena
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = game_util:getTableLen(showData) --totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
			ccbNode:openCCBFile("ccb/ui_godfield_Arena_new_rank_rew_Item.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = showData[tostring(index+1)]
            local m_rank_lb = ccbNode:labelTTFForName("m_rank_lb")
            local m_score_lb = ccbNode:labelTTFForName("m_score_lb")
            local m_rank_sp = ccbNode:spriteForName("m_rank_sp")
            local rank1 = itemData.rank[1]
            local rank2 = itemData.rank[2]
            if rank1 == rank2 then
            	m_rank_lb:setVisible(false)
            	m_rank_sp:setVisible(true)
	            local tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring("pvp_paihang_icon" .. tostring(rank1) .. ".png"))
	            if tempSpriteFrame1 then
	                m_rank_sp:setDisplayFrame(tempSpriteFrame1)
	            else
		            m_rank_lb:setVisible(true)
	            	m_rank_sp:setVisible(false)
	            	m_rank_lb:setString("Hạng " .. rank1 .. " ")
	            end
	        else
            	m_rank_lb:setVisible(true)
            	m_rank_sp:setVisible(false)
            	m_rank_lb:setString("Hạng " .. rank1 .."~" .. rank2 .. " ")
            end
            local reward = {}
            if self.m_enterType < 4 then
            	reward = itemData["arena_" .. self.m_enterType] 
        	else
        		reward = itemData["arena_all"]
        	end
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
				    button:setTag((index+1)*100 + tonumber(k))
                end
        	end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
    end
    return TableViewHelper:create(params);
end
function game_godfield_pvp_new_rank_rew:refreshTableView()
	self.m_list_node:removeAllChildrenWithCleanup(true)
	local tempList = self:createTableView(self.m_list_node:getContentSize())
	if tempList then
		self.m_list_node:addChild(tempList)
	end
end


function game_godfield_pvp_new_rank_rew:refreshBtn(index)
	self.m_selectd_index = index
	local filesName = {"pvp_shop_pier","pvp_shop_wuerlun","pvp_shop_hatuomo","pvp_paihang_all"}
	for i=1,4 do
		local tempSp = self.ccbNode:spriteForName("m_select_sp" .. i)
		local fileName = filesName[i]
		local m_select_btn = self.ccbNode:controlButtonForName("m_select_btn" .. i)
		if i == index then
			fileName = fileName .. "2"
			m_select_btn:setTouchEnabled(false)
		else
			fileName = fileName .. "1"
			m_select_btn:setTouchEnabled(true)
		end
		local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName .. ".png"))
	  	if tempSpriteFrame then
	     	tempSp:setDisplayFrame(tempSpriteFrame)
	  	end
	end

    local tab = {"1","2","3","all"}
    self.m_my_rank:setString(self.m_my_rankTab[tab[self.m_selectd_index]])
end


function game_godfield_pvp_new_rank_rew:refreshUi()
	self:refreshBtn(self.m_enterType)
	self:refreshTableView()
end


function game_godfield_pvp_new_rank_rew:init(t_params)
	t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        cclog2(self.m_tGameData,"  game_godfield_pvp_new_rank_rew   ")
    else
        self.m_tGameData = {};
    end
    local tab = {"1","2","3","all"}
    self.m_my_rankTab = {}
    for i=1,4 do
        self.m_my_rankTab[tab[i]] = self.m_tGameData[tab[i]].my_rank
    end

    self.m_enterType = t_params.enterType or 1
    self.m_universe_arena =  json.decode(getConfig(game_config_field.universe_arena):getFormatBuffer())
end



function game_godfield_pvp_new_rank_rew:create(t_params)
	local scene = CCScene:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end
return game_godfield_pvp_new_rank_rew