local game_godfield_pvp_new_rank = {
	m_root_layer = nil,
	m_btn_back = nil,
	text_scroll = nil,
	callback = nil,
    m_enterType = nil,
    ccbNode = nil,
    m_list_node = nil,
    m_tGameData = nil,
    m_selectd_index = nil,
} 

function game_godfield_pvp_new_rank:destroy()
    cclog("-------- game_godfield_pvp_new_rank destroy --------")
	self.m_root_layer = nil;
	self.m_btn_back = nil;
	self.text_scroll = nil;
	self.callback = nil;
    self.m_enterType = nil;
    self.ccbNode = nil;
    self.m_list_node = nil;
    self.m_tGameData = nil;
    self.m_selectd_index = nil;
end



function game_godfield_pvp_new_rank:back()
	if self.callback then
		self.callback()
	end
	game_scene:removePopByName("game_godfield_pvp_new_rank")
end



function game_godfield_pvp_new_rank:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		self.m_enterType = btnTag
		self:refreshUi()
	end
	local ccbNode =  luaCCBNode:create();
	self.ccbNode = ccbNode
	ccbNode:registerFunctionWithFuncName("onMainClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_godfield_Arena_new_score.ccbi")
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

    local m_back_layer = ccbNode:layerForName("m_back_layer")
    local function onTouch2(eventType, x, y)
        if eventType == "began" then
            local realPos = m_back_layer:getParent():convertToNodeSpace(ccp(x,y));
            if not m_back_layer:boundingBox():containsPoint(realPos) then
            	self:back()
            else
            	return
            end
        elseif eventType == "ended" then
        end
    end
    m_back_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-4,true);
    m_back_layer:setTouchEnabled(true);
	return ccbNode
end


function game_godfield_pvp_new_rank:createTableView(viewSize)
    local showData = self.m_tGameData[tostring(self.m_enterType < 4 and self.m_enterType or "all")].rank_infos
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #showData--totalItem;
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
			ccbNode:openCCBFile("ccb/ui_godfield_Arena_new_score_item.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = showData[index+1]
            local m_rank_lb = ccbNode:labelTTFForName("m_rank_lb")
            local m_name_lb = ccbNode:labelTTFForName("m_name_lb")
            local m_score_lb = ccbNode:labelTTFForName("m_score_lb")
            local m_rank_sp = ccbNode:spriteForName("m_rank_sp")
            m_name_lb:setString(itemData.name)
            m_score_lb:setString(itemData.score)
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

function game_godfield_pvp_new_rank:refreshTableView()
	self.m_list_node:removeAllChildrenWithCleanup(true)
	local tempList = self:createTableView(self.m_list_node:getContentSize())
	if tempList then
		self.m_list_node:addChild(tempList)
	end
end


function game_godfield_pvp_new_rank:refreshBtn(index)
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
end


function game_godfield_pvp_new_rank:refreshUi()
	self:refreshBtn(self.m_enterType)
	self:refreshTableView()
end


function game_godfield_pvp_new_rank:init(t_params)
	t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_enterType = t_params.enterType or 1
end


function game_godfield_pvp_new_rank:create(t_params)
	local scene = CCScene:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end
return game_godfield_pvp_new_rank
