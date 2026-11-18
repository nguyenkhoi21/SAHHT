--新大富翁拼图
local game_newRichMan_puzzles_pop = {
    m_tGameData = nil,
    m_node_tableView = nil,
    m_select_item = nil,
    m_select_index = nil,
    m_tab_chip = nil,--所有的碎片
    m_tab_light = nil,--右边碎片已经点亮
    m_tab_spriteChip = nil,--16个拼图的sprite
};
--[[--
    销毁ui
]]
function game_newRichMan_puzzles_pop.destroy(self)
    -- body
    cclog("-----------------game_newRichMan_puzzles_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_node_tableView = nil;
    self.m_select_item = nil;
    self.m_select_index = nil;
    self.m_tab_chip = nil;--所有的碎片
    self.m_tab_light = nil;--右边碎片已经点亮
    self.m_tab_spriteChip = nil;
end
--[[--
    返回
]]
function game_newRichMan_puzzles_pop.back(self,type)
	game_scene:removePopByName("game_newRichMan_puzzles_pop")
    -- local function endCallFunc()
    --     self:destroy();
    -- end
    -- game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_newRichMan_puzzles_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag ==== ")
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 101 then --奖励展示
            game_scene:addPop("game_newRichMan_reward_pop")
        elseif btnTag == 102 then -- 赠送信息
            local function responseMethod( tag,gameData )
                local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                local log = data.send_puzzle_log
                local msg = ""
                for i=(#log),1,-1 do
                    msg = msg .. "    "  .. log[i] .. "\n"
                end
                game_scene:addPop("game_newRichMan_message_pop",{text = msg,enterType = "rank"})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_index"), http_request_method.GET, nil,"monopoly_index")
        elseif btnTag == 103 then -- 详情
            local activeCfg = getConfig(game_config_field.notice_active)
            local itemCfg = activeCfg:getNodeWithKey( "183" )
            local contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or "Event đặc sắc, hãy nhanh tay tham gia!"
            game_scene:addPop("game_newRichMan_message_pop",{text = contentText,enterType = "detail"})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_newRichMan_pintu_pop.ccbi");
    local m_btn_gift = ccbNode:controlButtonForName("m_btn_gift")
    local m_btn_message = ccbNode:controlButtonForName("m_btn_message")
    local m_btn_des = ccbNode:controlButtonForName("m_btn_des")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_btn_gift:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    m_btn_message:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    m_btn_des:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")

    self.m_tab_spriteChip = {}
    local m_sprite_pintu = nil
    for i=1,16 do
        m_sprite_pintu = ccbNode:spriteForName("m_sprite_pintu" .. i)
        self.m_tab_spriteChip[i] = {m_sprite_pintu = m_sprite_pintu}
    end
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
function game_newRichMan_puzzles_pop.refreshRightPuzzles( self )
    for i=1,16 do
        -- self.m_tab_spriteChip[i].m_sprite_pintu:setColor(ccc3(80,80,80))
        self.m_tab_spriteChip[i].m_sprite_pintu:setVisible(false)
    end
    for k,v in pairs(self.m_tab_light) do
        self.m_tab_spriteChip[v].m_sprite_pintu:setVisible(true)

       -- self.m_tab_spriteChip[v].m_sprite_pintu:setColor(ccc3(255,255,255))
    end
    -- body
end
function game_newRichMan_puzzles_pop.createTableView(self, viewSize )
    local function onCellClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            if self.m_select_index then
                local isIn,k = game_util:idInTableById(self.m_select_index,self.m_tab_light)
                if isIn then
                    cclog("use failed~")
                    game_util:addMoveTips({text = "Mảnh này đã sáng"})
                else
                    local params = {}
                    params.puzzle_id = self.m_select_index
                    local function responseMethod(tag,gameData)
                        cclog("use successful~")
                        self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                        self:refreshUi()
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_use_puzzle"), http_request_method.GET, params,"monopoly_use_puzzle")
                end
            else
            end
        elseif btnTag == 2 then
            game_scene:enterGameUi("game_friend_scene",{chipID = self.m_select_index});
        end
    end
    self.m_select_index = 0
    self.m_select_item = nil;
	local params = {};
	params.viewSize = viewSize;
	params.row = 4;--行
	params.column = 1; --列
	params.totalItem = 16
	params.direction = kCCScrollViewDirectionVertical;
	params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
	local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
	params.newCell = function(tableView,index) 
	    local cell = tableView:dequeueCell()
	    if cell == nil then
	       -- cclog("new index ================================" .. index);
	       cell = CCTableViewCell:new()
	       cell:autorelease()
	       local ccbNode = luaCCBNode:create()    
           ccbNode:registerFunctionWithFuncName("onCellClick",onCellClick);        
	       ccbNode:openCCBFile("ccb/ui_newRichMan_pintu_item.ccbi")
	       ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
	       cell:addChild(ccbNode,10,10);
	    end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local num = 0
            local m_sprite_pintu = ccbNode:spriteForName("m_sprite_pintu")
            if self.m_tab_chip[tostring(index + 1)] and self.m_tab_chip[tostring(index + 1)]  > 0 then
                m_sprite_pintu:setColor(ccc3(255,255,255))
                num = self.m_tab_chip[tostring(index + 1)]
            else
                m_sprite_pintu:setColor(ccc3(120,120,120))
            end

            local m_label_num = ccbNode:labelTTFForName("m_label_num")
            m_label_num:setString("x" .. num)
            local btn_use = ccbNode:controlButtonForName("m_btn_use")
            local btn_send = ccbNode:controlButtonForName("m_btn_send")
            btn_use:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
            btn_send:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
            if self.m_select_index == index + 1 then
                self.m_select_item = cell
                btn_use:setVisible(true)
                btn_send:setVisible(true)
            else
                btn_use:setVisible(false)
                btn_send:setVisible(false)
            end

            -- btn_use:getParent():reorderChild(btn_use,999)
            -- btn_send:getParent():getParent():reorderChild(btn_send,999)
            local m_sprite_pintu = ccbNode:spriteForName("m_sprite_pintu")
            spriteName = "puzzles" .. index+1 .. ".png"
            m_sprite_pintu:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteName))
	    end
	    return cell;
	end
	params.itemOnClick = function(eventType,index,item)
    	if eventType == "ended" and item then
            local tempId = index+1
            if self.m_select_index == 0 or self.m_select_index ~= tempId then
                if self.m_select_item then
                    local ccbNode = tolua.cast(self.m_select_item:getChildByTag(10),"luaCCBNode");
                    local btn_use = ccbNode:controlButtonForName("m_btn_use")
                    local btn_send = ccbNode:controlButtonForName("m_btn_send")
                    btn_use:setVisible(false)
                    btn_send:setVisible(false)
                end
                self.m_select_item = item;
                self.m_select_index = tempId
               
                local ccbNode = tolua.cast(self.m_select_item:getChildByTag(10),"luaCCBNode");
                local btn_use = ccbNode:controlButtonForName("m_btn_use")
                local btn_send = ccbNode:controlButtonForName("m_btn_send")
                btn_use:setVisible(true)
                btn_send:setVisible(true)
                if self.m_tab_chip[tostring(index+1)] then
                    btn_use:setColor(ccc3(255,255,255))
                    btn_send:setColor(ccc3(255,255,255))
                    btn_use:setTouchEnabled(true)
                    btn_send:setTouchEnabled(true)
                else
                    btn_use:setColor(ccc3(150,150,150))
                    btn_send:setColor(ccc3(150,150,150))
                    btn_use:setTouchEnabled(false)
                    btn_send:setTouchEnabled(false)
                end
            elseif self.m_select_index == tempId then
                local ccbNode = tolua.cast(self.m_select_item:getChildByTag(10),"luaCCBNode");
                local btn_use = ccbNode:controlButtonForName("m_btn_use")
                local btn_send = ccbNode:controlButtonForName("m_btn_send")
                btn_use:setVisible(false)
                btn_send:setVisible(false)
                self.m_select_item = nil
                self.m_select_index = 0
            end
        end
	   -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
	end
	return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_newRichMan_puzzles_pop.refreshUi(self)
    self.m_tab_chip = {}
    self.m_tab_chip =  self.m_tGameData.puzzle
    self.m_tab_light = self.m_tGameData.used_puzzle;--右边碎片已经点亮

    local viewSize =  self.m_node_tableView:getContentSize()
    self.m_node_tableView:removeAllChildrenWithCleanup(true)
    self.m_node_tableView:addChild(self:createTableView(viewSize))
    self:refreshRightPuzzles()
end
--[[--
    初始化
]]
function game_newRichMan_puzzles_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    
    
end
--[[--
    创建ui入口并初始化数据
]]
function game_newRichMan_puzzles_pop.create(self,t_params)
    self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi();

    return  m_popUi;
end
return game_newRichMan_puzzles_pop;