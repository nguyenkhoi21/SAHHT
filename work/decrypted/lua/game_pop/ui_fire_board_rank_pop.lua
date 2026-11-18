local ui_fire_board_rank_pop = {
    m_root_layer = nil,
    m_btn_back = nil,
    m_rewards_node = nil,
    m_ach_node = nil,
    content_node = nil,
    m_no_ach_lab = nil,
    m_no_rank_lab = nil,
    m_my_rank_node = nil,
    m_index_lable = nil,
    m_intergral_lable = nil,
    m_return_lable = nil,
    text_scroll = nil,
    m_btn1 = nil,
    m_btn2 = nil,
    m_btn3 = nil,
    m_btn4 = nil,
    m_btn5 = nil,
    m_btn6 = nil,
    m_achievement_list = nil,
    m_rank_info = nil,
    m_fire_cfg = nil,
    m_tGameData = nil,
    m_rank_list = nil,
    m_diamond_off = nil,
    m_version = nil,
}
function ui_fire_board_rank_pop:destroy()
    self.m_root_layer = nil;
    self.m_btn_back = nil;
    self.m_rewards_node = nil;
    self.m_ach_node = nil;
    self.content_node = nil;
    self.m_no_ach_lab = nil;
    self.m_no_rank_lab = nil;
    self.m_my_rank_node = nil;
    self.m_index_lable = nil;
    self.m_intergral_lable = nil;
    self.m_return_lable = nil;
    self.text_scroll = nil;
    self.m_btn1 = nil;
    self.m_btn2 = nil;
    self.m_btn3 = nil;
    self.m_btn4 = nil;
    self.m_btn5 = nil;
    self.m_btn6 = nil;
    self.m_achievement_list = nil;
    self.m_rank_info = nil;
    self.m_fire_cfg = nil;
    self.m_tGameData = nil;
    self.m_rank_list = nil;
    self.m_diamond_off = nil;
    self.m_version = nil;
end

function ui_fire_board_rank_pop:back()
    cclog(" ------------- ui_fire_board_rank_pop destroy ---------- ")
	game_scene:removePopByName("ui_fire_board_rank_pop")
end


function ui_fire_board_rank_pop:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 1 then
			self:back()
        elseif btnTag == 101 then
            self.m_btn1:setVisible(false)
            self.m_btn2:setVisible(true)
            self.m_btn3:setVisible(true)
            self.m_btn4:setVisible(true)
            self.m_btn5:setVisible(false)
            self.m_btn6:setVisible(false)
            self.m_rewards_node:setVisible(true)
            self.m_ach_node:setVisible(false)
            self.content_node:setVisible(false)
            self.m_no_ach_lab:setVisible(false)
            self.m_rewards_node:removeAllChildrenWithCleanup(true)
            self.m_rewards_node:addChild(self:createRankTableView(self.m_rewards_node:getContentSize()))
        elseif btnTag == 102 then
            self.m_btn1:setVisible(true)
            self.m_btn2:setVisible(false)
            self.m_btn3:setVisible(true)
            self.m_btn4:setVisible(false)
            self.m_btn5:setVisible(true)
            self.m_btn6:setVisible(false)
            self.m_rewards_node:setVisible(false)
            self.m_ach_node:setVisible(true)
            self.content_node:setVisible(false)
            self.m_no_rank_lab:setVisible(false)
            self.m_ach_node:removeAllChildrenWithCleanup(true)
            self.m_ach_node:addChild(self:createAchTableView(self.m_ach_node:getContentSize()))
        elseif btnTag == 103 then 
            self.m_btn1:setVisible(true)
            self.m_btn2:setVisible(true)
            self.m_btn3:setVisible(false)
            self.m_btn4:setVisible(false)
            self.m_btn5:setVisible(false)
            self.m_btn6:setVisible(true)
            self.m_rewards_node:setVisible(false)
            self.m_no_rank_lab:setVisible(false)
            self.m_ach_node:setVisible(false)
            self.content_node:setVisible(true)
            self.m_no_ach_lab:setVisible(false)
		end
	end
	local ccbNode =  luaCCBNode:create();
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_fire_board_ach_pop.ccbi")
	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	self.m_btn_back = ccbNode:controlButtonForName("m_btn_close")
    self.m_rewards_node = ccbNode:nodeForName("m_rewards_node")
	self.m_ach_node = ccbNode:nodeForName("m_ach_node")
    self.content_node = ccbNode:nodeForName("content_node")
    local detail_label = ccbNode:labelTTFForName("detail_label")
    self.m_no_ach_lab = ccbNode:labelTTFForName("no_ach_lab")
    self.m_no_ach_lab:setVisible(false)
    self.m_no_rank_lab = ccbNode:labelTTFForName("no_rank_lab")
    self.m_no_rank_lab:setVisible(false)
    detail_label:setVisible(false)
    self.m_my_rank_node = ccbNode:nodeForName("my_rank_node")
    self.m_index_lable = ccbNode:labelTTFForName("index")
    self.m_intergral_lable = ccbNode:labelTTFForName("integral")
    self.m_return_lable = ccbNode:labelTTFForName("return")
    self.text_scroll = ccbNode:scrollViewForName("text_scroll")
    self.text_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY-9)
	self.m_btn1 = ccbNode:controlButtonForName("m_btn1")
	self.m_btn2 = ccbNode:controlButtonForName("m_btn2")
	self.m_btn3 = ccbNode:controlButtonForName("m_btn3")
    self.m_btn4 = ccbNode:controlButtonForName("m_btn4")
    self.m_btn5 = ccbNode:controlButtonForName("m_btn5")
    self.m_btn6 = ccbNode:controlButtonForName("m_btn6")

	self.m_btn_back:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 9)
	self.m_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 9)
	self.m_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 9)
	self.m_btn3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 9)
    self.m_btn4:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 9)
    self.m_btn5:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 9)
    self.m_btn6:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 9)
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-8,true);
    self.m_root_layer:setTouchEnabled(true);
	return ccbNode
end

function ui_fire_board_rank_pop:createAchTableView(viewSize)
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag(); 
        if btnTag < 1000 then
            local itemCfg = self.m_achievement_list[btnTag] 
            if itemCfg.isCanRec then
                local function responseMethod( tag,gameData )
                    if gameData and tolua.type(gameData) == "util_json" then
                        local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {}
                        self:refreshAchData(data)
                        self.m_ach_node:removeAllChildrenWithCleanup(true)
                        self.m_ach_node:addChild(self:createAchTableView(self.m_ach_node:getContentSize()))
                        game_util:rewardTipsByDataTable(data.reward)
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("fire_chess_get_achievement"), http_request_method.GET, {achievement_id = itemCfg.id},"fire_chess_get_achievement")
            else
                game_util:addMoveTips({text = "Không thể nhận"})
            end   
        else
            local tag = btnTag - 1000
            local itemCfg = self.m_achievement_list[tag]
            game_util:lookItemDetal(itemCfg.reward[1])
        end
    end
    if #self.m_achievement_list < 1 then
        self.m_no_ach_lab:setVisible(true)
    else
        self.m_no_ach_lab:setVisible(false)
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 1; --列
    params.totalItem = #self.m_achievement_list;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-9;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        local itemCfg = self.m_achievement_list[index+1]
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_fire_board_ach_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(60,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_lingqu_item = ccbNode:controlButtonForName("m_lingqu_item")
            local m_treasure_btn1 = ccbNode:controlButtonForName("m_treasure_btn1")
            local m_treasure_btn2 = ccbNode:controlButtonForName("m_treasure_btn2")
            local m_zi_lable = ccbNode:labelTTFForName("m_zi_lable")
            if itemCfg.isCanRec == true then
                game_util:setCCControlButtonBackground(m_lingqu_item,"ui_fired_lingqu_zi1.png")
                m_treasure_btn1:setVisible(true)
                m_treasure_btn2:setVisible(false)
            else
                game_util:setCCControlButtonBackground(m_lingqu_item,"ui_fired_lingqu_zi2.png")
                m_treasure_btn1:setVisible(false)
                m_treasure_btn2:setVisible(true)
            end
            m_treasure_btn1:setTag(index + 1001)
            m_treasure_btn2:setTag(index + 1001)
            m_zi_lable:setString("Quà Cá Nhân X " .. itemCfg.number .. "lần")
            m_lingqu_item:setTag(index + 1)
            m_treasure_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
            m_treasure_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
            m_lingqu_item:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
    end
    return TableViewHelper:create(params);
end


function ui_fire_board_rank_pop:createRankTableView(viewSize)
    local imgSelectTab = {}
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();      
    end
    if #self.m_rank_info == 0 then
        self.m_no_rank_lab:setVisible(true)
        self.m_no_rank_lab:setString("Chưa có XH")
    else
        self.m_no_rank_lab:setVisible(false)
    end
    local params = {};
    params.viewSize = viewSize;
    if #self.m_rank_info < 6 then
        params.row = #self.m_rank_info;
    else 
        params.row = 6;
    end
    params.column = 1; --列
    params.totalItem = #self.m_rank_info;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-9;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local itemCfg = self.m_rank_info[index+1]
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_fire_board_rank_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(25,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_index_lable = ccbNode:labelTTFForName("index")
            local m_name_lable = ccbNode:labelTTFForName("name")
            local m_intergral_lable = ccbNode:labelTTFForName("integral")
            local rank = self.m_rank_list[index+1] or itemCfg.number
            m_index_lable:setString("Hạng " .. rank )
            m_name_lable:setString(itemCfg.name)
            m_intergral_lable:setString(itemCfg.score .. "Tích điểm")
            -- local item_lab = game_util:createLabelTTF({text = "第" .. index + 1 .. "名 ----- 洛丽塔 -------- 10000积分 --------- 奖励返钻30%" ,color = ccc3(255,255,255),fontSize = 8})
            -- ccbNode:addChild(item_lab)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
    end
    return TableViewHelper:create(params);
end


function ui_fire_board_rank_pop:createContentTable(viewSize)
    local contentText = ""
    if self.m_fire_cfg then
        contentText = self.m_fire_cfg[tostring(self.m_version)].notice_1;
    end
    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(250,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 10})
    local tempSize = tempLabel:getContentSize();
    self.text_scroll:setContentSize(CCSizeMake(250,tempSize.height))
    self.text_scroll:setContentOffset(ccp(5, viewSize.height - tempSize.height), false)
    self.text_scroll:addChild(tempLabel)
end



function ui_fire_board_rank_pop:refreshUi()
    self.m_rewards_node:addChild(self:createRankTableView(self.m_rewards_node:getContentSize()))
    self.m_rewards_node:setVisible(true)
    self:createContentTable(self.content_node:getContentSize())
    self.content_node:setVisible(false)
    if self.m_tGameData.my_rank ~= 0 and self.m_tGameData.my_score then
        self.m_my_rank_node:setVisible(true)
        self.m_index_lable:setString("Hạng" .. self.m_tGameData.my_rank )
        self.m_intergral_lable:setString(self.m_tGameData.my_score .. "Tích điểm")
        self.m_return_lable:setString("Lãi Xu " .. self.m_tGameData.my_diamond_off .. "%")
    else
        self.m_my_rank_node:setVisible(false)
    end
end



function ui_fire_board_rank_pop:refreshAchData(gameData)
    local fire_achievement = json.decode(getConfig(game_config_field.fire_achievement):getFormatBuffer())
    local fire_achievement_list = {}
    local achievement = gameData.achievement
    local achievement_list = {}
    local received_achieve = gameData.received_achieve
    local received_achieve_list = {}
    for k,v in pairs(achievement) do
        achievement_list[v] = v
    end
    for k,v in pairs(received_achieve) do
        received_achieve_list[v] = v
    end
    self.m_achievement_list = {}
    local count = game_util:getTableLen(fire_achievement)
    for i=1,count do
        local v = fire_achievement[tostring(i)]
        local number = v.number
        if achievement_list[tonumber(number)] then
            if received_achieve_list[tonumber(number)] then
            else
                v.id = i
                v.isCanRec = true
                self.m_achievement_list[#self.m_achievement_list+1] = v
            end
        else
            v.id = i
            v.isCanRec = false
            self.m_achievement_list[#self.m_achievement_list+1] = v
        end
    end
end


function ui_fire_board_rank_pop:refreshRankData(gameData)
    self.m_rank_info = {}
    local rank_info =  gameData.rank_info
    for k,v in pairs(rank_info) do
        v.number = self.m_rank_list[k]
        self.m_rank_info[#self.m_rank_info+1] = v
    end
end

function ui_fire_board_rank_pop:init(t_params)
    self.m_fire_cfg = json.decode(getConfig(game_config_field.fire_reward):getFormatBuffer())
    if t_params.version then
        self.m_version = t_params.version
    end
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    end
    self.m_rank_list = self.m_tGameData.rank_list or {}
    self.m_diamond_off = self.m_tGameData.diamond_off or {}
    self:refreshAchData(self.m_tGameData)
    self:refreshRankData(self.m_tGameData)
end


function ui_fire_board_rank_pop:create(t_params)
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end

return ui_fire_board_rank_pop