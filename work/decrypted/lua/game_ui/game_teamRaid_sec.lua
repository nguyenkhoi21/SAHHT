-- 团队副本   分组
local game_teamRaid_sec = {
    m_listTableView = nil,
    m_offY = nil,

}
local btn_lb = {"I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII"}
local attr_tab = {201,202,203,204}
local occu_tab = {1,2,3,4}
function game_teamRaid_sec:destroy(  )
	-- body
    self.m_listTableView = nil;
    self.m_offY = nil;

end
function game_teamRaid_sec:back(  )
	-- body
    if self.m_changed then
        local t_params = 
        {
        title = "Nhắc nhở",
        okBtnCallBack = function(target,event)
            require("game_ui.game_pop_up_box").close(); 
            local function responseMethod( tag, gameData )
                if gameData then
                    game_scene:enterGameUi("game_teamRaid_main",{gameData = gameData,enterFlag = self.m_EnterFlag})
                end
            end
            local params = {}
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_index"), http_request_method.GET, nil,"team_raid_index")
            end,   --可缺省
            cancelBtnCallBack = function(target,event) cclog("rightBtnCallBack") require("game_ui.game_pop_up_box").close(); end,   --可缺省
            okBtnText = "Xác định",       --可缺省
            cancelBtnText = "Hủy",
            onlyOneBtn = false,          --可缺省
            text = "Phân đội Đội Chuyên Công của bạn chưa được lưu, xác định rời khỏi không?",      --可缺省
        }
        require("game_ui.game_pop_up_box").show(t_params);
    else
        local function responseMethod( tag, gameData )
            if gameData then
                game_scene:enterGameUi("game_teamRaid_main",{gameData = gameData,enterFlag = self.m_EnterFlag})
            end
        end
        local params = {}
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_index"), http_request_method.GET, nil,"team_raid_index")
    end
end


function game_teamRaid_sec:createUi(  ) -- test_touch
	-- body
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
        	self:back()
    	elseif btnTag == 2 then
            if not self.m_changed then
                game_util:addMoveTips({text = "Đoàn Chuyên Công của bạn không có thay đổi",new_color = ccc3(123,255,255)})
                return
            end
            self.m_teamCardsTab[self.m_selectTeam] = util.table_copy(self.m_selectTab)
            local params = {}
            for k,v in pairs(self.m_teamCardsTab) do
                params["team_" .. k] = params["team_" .. k] or ""
                for i=1,5 do
                    params["team_" .. k] = params["team_" .. k] .. (v[i] and v[i].uid or "0") .. (i == 5 and "" or "_")
                end
            end
            local function responseMethod( tag, gameData )
                -- body
                if gameData then
                    self.m_changed = false
                    game_util:addMoveTips({text = "Hoàn thành phân đội",new_color = ccc3(123,255,255)})
                end
            end
            params.raid_id = self.m_tGameData.raid_id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_select_team"), http_request_method.GET, params,"team_raid_select_team")

    	elseif btnTag == 3 then  -- 踢人
            local selData = self.m_tempTab[self.m_selectIndex]
            local t_params = 
            {
                title = "Nhắc nhở",
                okBtnCallBack = function(target,event)
                    require("game_ui.game_pop_up_box").close(); 
                    local function responseMethod( tag, gameData )
                        if gameData then
                            local data = gameData:getNodeWithKey("data")
                            self.m_tGameData = json.decode(data:getFormatBuffer())
                            local player_data = self.m_tGameData.player_data
                            self.m_teamCardsTab[self.m_selectTeam] = util.table_copy(self.m_selectTab)
                            for k,v in pairs(self.m_teamCardsTab) do
                                for m,n in pairs(v) do
                                    if not player_data[n.uid] then
                                        table.remove(self.m_teamCardsTab[k],m)
                                        self.m_all_playerData[n.uid] = nil
                                    end
                                end
                            end
                            if self.m_all_playerData[selData.uid] then
                                self.m_all_playerData[selData.uid] = nil
                            end
                            self.m_selectTab = util.table_copy(self.m_teamCardsTab[self.m_selectTeam])
                            self:refreshTableVIew()
                            self:refreshTeamIcon()
                            game_util:addMoveTips({text = "Đã loại đội viên này khỏi Đội Chuyên Công",new_color = ccc3(123,255,255)})
                        end
                    end
                    local params = {}
                    params.raid_id = self.m_tGameData.raid_id
                    params.player_id = selData.uid
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_get_out_raid"), http_request_method.GET, params,"team_raid_get_out_raid")

                end,   --可缺省
                cancelBtnCallBack = function(target,event) cclog("rightBtnCallBack") require("game_ui.game_pop_up_box").close(); end,   --可缺省
                okBtnText = "Xác định",       --可缺省
                cancelBtnText = "Hủy",
                onlyOneBtn = false,          --可缺省
                text = "Xác nhận muốn loại đội viên này khỏi Đội Chuyên Công không?",      --可缺省
            }
            require("game_ui.game_pop_up_box").show(t_params);

        elseif btnTag == 4 then  -- 申请列表
            local function responseMethod( tag, gameData )
                if gameData then
                    local callfunc = function ( gameData )
                        local data = gameData:getNodeWithKey("data")
                        self.m_tGameData = json.decode(data:getFormatBuffer())
                        local all_player = self.m_tGameData.all_player
                        local player_data = self.m_tGameData.player_data
                        self.m_teamCardsTab[self.m_selectTeam] = util.table_copy(self.m_selectTab)
                        for k,v in pairs(all_player) do
                            if not self.m_all_playerData[k] then
                                local data = player_data[k]
                                if data then
                                    self.m_cards_Tab[#self.m_cards_Tab+1] = data
                                    self.m_all_playerData[k] = data
                                    self.m_all_playerData[k].teamId = 0
                                end
                            end
                        end
                        self.m_have_apply = self.m_tGameData.have_apply
                        if self.m_have_apply then
                            self.m_hongdian_sp:setVisible(true)
                        else
                            self.m_hongdian_sp:setVisible(false)
                        end
                        self:refreshTableVIew()
                        -- self:refreshTeamIcon()
                    end
                    game_scene:addPop("game_teamRaid_apply_list",{gameData = gameData,raid_id = self.m_tGameData.raid_id,callfunc = callfunc})
                end
            end
            local params = {}
            params.raid_id = self.m_tGameData.raid_id
            params.page = 1
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_apply_index"), http_request_method.GET, params,"team_raid_apply_index")

    	elseif btnTag == 5 then  -- 开始攻坚
            if self.m_changed then
                game_util:addMoveTips({text = "Hãy lưu DS Chuyên Công của bạn trước",new_color = ccc3(123,255,255)})
                return
            end
            local function responseMethod( tag, gameData )
                if gameData then
                    game_scene:enterGameUi("game_teamRaid_first_scene",{enterFlag = self.m_EnterFlag,gameData = gameData})
                end
            end
            local params = {}
            params.raid_id = self.m_tGameData.raid_id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_start_raid"), http_request_method.GET, params,"team_raid_start_raid")
        
        elseif btnTag == 6 then -- 解散队伍
            local function responseMethod( tag, gameData )
                if gameData then
                    game_scene:enterGameUi("game_teamRaid_main",{enterFlag = self.m_EnterFlag,gameData = gameData})
                end
            end
            local params = {}
            params.raid_id = self.m_tGameData.raid_id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_dismiss_raid"), http_request_method.GET, params,"team_raid_dismiss_raid")
        elseif btnTag == 7 then -- 刷新
            local owner = self.m_tGameData.owner or ""
            local myUid = game_data:getUserStatusDataByKey("uid")
            local function responseMethod( tag, gameData )
                if gameData then
                    local data = gameData:getNodeWithKey("data")
                    if owner ~= myUid then
                        local stage = data:getNodeWithKey("stage"):toInt()
                        local stage_small = data:getNodeWithKey("stage_small") and data:getNodeWithKey("stage_small"):toInt()
                        if stage and stage ~= 0 then
                            if stage == 1 then
                                if stage_small == 1 then
                                    game_scene:enterGameUi("game_teamRaid_first_scene",{gameData = gameData,enterFlag = self.m_EnterFlag})
                                elseif stage_small == 2 then
                                    game_scene:enterGameUi("game_teamRaid_firstBoss_scene",{gameData = gameData,enterFlag = self.m_EnterFlag})
                                end
                            elseif stage == 2 then
                                if stage_small == 1 then
                                    game_scene:enterGameUi("game_teamRaid_last_scene",{gameData = gameData,enterFlag = self.m_EnterFlag})
                                elseif stage_small == 2 then
                                    game_scene:enterGameUi("game_teamRaid_lastBoss_scene",{gameData = gameData,enterFlag = self.m_EnterFlag})
                                end
                            elseif stage == 3 then
                                game_scene:enterGameUi("game_teamRaid_third_scene",{gameData = gameData,enterFlag = self.m_EnterFlag})
                            elseif stage == 999 then
                                game_scene:addPop("game_teamRaid_result_pop",{gameData = gameData,enterFlag = self.m_EnterFlag})
                            end
                        else
                            local tempData = {}
                            tempData.offY = self.m_listTableView:getContentOffset().y
                            tempData.team = self.m_selectTeam or 1
                            tempData.screenType = self.m_selectScreenType
                            tempData.time = 3
                            game_scene:enterGameUi("game_teamRaid_sec",{gameData = gameData,enterFlag = self.m_EnterFlag,tempData = tempData})
                        end
                    else
                        self.m_have_apply = data and json.decode(data:getFormatBuffer()).have_apply
                        if self.m_have_apply then
                            self.m_hongdian_sp:setVisible(true)
                        end
                        self.m_btn_refresh:setTouchEnabled(false)
                        self.m_btn_refresh:setColor(ccc3(100,100,100))

                        local function timeEndFunc(label,type)
                            self.m_btn_refresh:setTouchEnabled(true)
                            self.m_btn_refresh:setColor(ccc3(255,255,255))
                        end
                        local countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8);
                        countdownLabel:setPosition(ccp(self.m_hongdian_sp:getContentSize().width*0.5,self.m_hongdian_sp:getContentSize().height*0.5))
                        if self.m_hongdian_sp ~= nil then
                            self.m_hongdian_sp:removeAllChildrenWithCleanup(true)
                        end
                        self.m_hongdian_sp:addChild(countdownLabel)
                        countdownLabel:setTime(3);
                        countdownLabel:setVisible(false)
                    end
                end
            end
            local params = {}
            params.raid_id = self.m_tGameData.raid_id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_persion_raid_index"), http_request_method.GET, params,"team_raid_persion_raid_index")
        elseif btnTag == 8 then  -- 退出攻坚队

            local t_params = 
            {
                title = "Nhắc nhở",
                okBtnCallBack = function(target,event)
                    require("game_ui.game_pop_up_box").close(); 
                    local function responseMethod( tag, gameData )
                        if gameData then
                            game_scene:enterGameUi("game_teamRaid_main",{gameData = gameData,enterFlag = self.m_EnterFlag})
                        end
                    end
                    local params = {}
                    params.raid_id = self.m_tGameData.raid_id
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_quit_raid"), http_request_method.GET, params,"team_raid_quit_raid")

                end,   --可缺省
                cancelBtnCallBack = function(target,event) cclog("rightBtnCallBack") require("game_ui.game_pop_up_box").close(); end,   --可缺省
                okBtnText = "Xác định",       --可缺省
                cancelBtnText = "Hủy",
                onlyOneBtn = false,          --可缺省
                text = "Xác nhận muốn rời khỏi Đội Chuyên Công không?",      --可缺省
            }
            require("game_ui.game_pop_up_box").show(t_params);

        elseif btnTag > 100 and btnTag < 200 then
            local owner = self.m_tGameData.owner or ""
            local myUid = game_data:getUserStatusDataByKey("uid")
            if owner ~= myUid then
                return
            end
            local index = btnTag - 100
            local itemData = self.m_selectTab[index]
            if itemData then
                local id = itemData.uid
                if self.m_all_playerData[id] then
                    self.m_all_playerData[id].teamId = 0
                end
                table.remove(self.m_selectTab,index);
                self:refreshTableVIew(true)
                self:refreshTeamIcon()
            end
        elseif btnTag > 200 and btnTag < 300 then  -- 选择队伍
    		local index = btnTag - 200 
    		if self.m_selectTeam == index then
			else
				self.m_teamCardsTab[self.m_selectTeam] = util.table_copy(self.m_selectTab)
				self.m_selectTeamBtn:setEnabled(true)
	        	local btn = ccbNode:controlButtonForName("m_btn" .. index)
	        	btn:setEnabled(false)
				self.m_selectTeamBtn = btn
				self.m_selectTeam = index
				local tempTable = self.m_teamCardsTab[self.m_selectTeam] or {}
				self.m_selectTab = util.table_copy(tempTable)
                self:refreshTeamIcon()
			end
    	elseif btnTag > 300 and btnTag < 400 then  -- 属性筛选

    	elseif btnTag > 400 and btnTag < 500 then  -- 职业筛选

    	end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_teamRaid_sec.ccbi");
    local m_btn_close = ccbNode:controlButtonForName("m_btn_close")
    m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_out_btn = ccbNode:controlButtonForName("m_out_btn")
    self.m_apply_list_btn = ccbNode:controlButtonForName("m_apply_list_btn")
    self.m_btn_sign_up = ccbNode:controlButtonForName("m_btn_sign_up")
    self.m_btn_Memout = ccbNode:controlButtonForName("m_btn_Memout")
    self.m_btn_began = ccbNode:controlButtonForName("m_btn_began")
    self.m_hongdian_sp = ccbNode:spriteForName("m_hongdian_sp")
    self.m_btn_refresh = ccbNode:controlButtonForName("m_btn_refresh")
    for i=1,12 do
        local node = ccbNode:nodeForName("m_btn_node_" .. i)
        local btn = ccbNode:controlButtonForName("m_btn" .. i)
        local lb = ccbNode:labelTTFForName("m_lb" .. i)
        local lb2 = ccbNode:labelTTFForName("m_lb2" .. i)
        if lb and lb2 and btn_lb[i] then
            lb:setString(btn_lb[i])
            lb2:setString(btn_lb[i])
        end
        if self.m_selectTeam == i then
        	btn:setEnabled(false);
        	self.m_selectTeamBtn = btn
        else
        	btn:setEnabled(true);
        end
        if i > 5 then
            btn:setTouchEnabled(false)
            btn:setColor(ccc3(100,100,100))
        end
    end

    for i=1,5 do
        local m_list_btn = ccbNode:controlButtonForName("m_list_btn" .. i)
        if m_list_btn then
            m_list_btn:setOpacity(0)
            m_list_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
        end
    end

    self.m_list_node = ccbNode:nodeForName("m_list_node")
    self.m_btn_dis = ccbNode:controlButtonForName("m_btn_dis")
    self.m_ccbNode = ccbNode;
    return ccbNode
end

-- function game_teamRaid_sec:createMsg(  )
-- 	-- body
-- 	local contentText = "1、联盟内部可直接开放的团推副本，由会长组织开启，会长自行分配人员分队，开放副本需要消耗联盟战旗！\n2、联盟内部可直接开放的团推副本，由会长组织开启，会长自行分配人员分队，开放副本需要消耗联盟战旗！\n3、联盟内部可直接开放的团推副本，由会长组织开启，会长自行分配人员分队，开放副本需要消耗联盟战旗！"
-- 	local tempLabel1 = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(150,0),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(123,255,255),fontSize = 10})
-- 	local tempLabel2 = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(150,0),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(123,255,255),fontSize = 10})
--     local tempSize = tempLabel1:getContentSize();
--     self.text_scroll:setContentSize(CCSizeMake(210,tempSize.height))
--     local viewSize = self.content_node:getContentSize()
--     self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
--     tempLabel1:setPosition(ccp(0,0.3))
--     tempLabel2:setPosition(ccp(0.3,0))
--     self.text_scroll:addChild(tempLabel1)
--     self.text_scroll:addChild(tempLabel2)
-- end


function game_teamRaid_sec:createTableView( viewSize ,tempTable )
	-- body
	local tempTable = tempTable or {}
	local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tempTable
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 1
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_teamRaid_hero_item2.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setScale(0.9)
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
    		local itemData = tempTable[index+1]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_sel_bg = ccbNode:spriteForName("m_sel_bg")
            local m_icon_node = ccbNode:nodeForName("m_icon_node")
            local m_sel_img = ccbNode:spriteForName("m_sel_img")
            local m_name_lb = ccbNode:labelTTFForName("m_name_lb")
            local m_team_lb = ccbNode:labelTTFForName("m_team_lb")
            local m_combat_lb = ccbNode:labelTTFForName("m_combat_lb")
            local m_lv_lb = ccbNode:labelTTFForName("m_lv_lb")
            local m_team_bg = ccbNode:spriteForName("m_team_bg")
            m_combat_lb:setString("Lực Chiến:" .. itemData.combat)
            m_lv_lb:setString("Lv:" .. itemData.level)
            -- m_sel_img:setVisible(false)
            m_sel_bg:setOpacity(100)
            m_sel_bg:setVisible(true)
            m_name_lb:setString(itemData.name)
            if self.m_selectIndex == index+1 then
                m_sel_bg:setOpacity(255)
            	self.m_selSprite = m_sel_bg
            else
                m_sel_bg:setOpacity(100)
            end
            if itemData.teamId and itemData.teamId > 0 then
                m_team_bg:setVisible(true)
                m_team_lb:setString(btn_lb[itemData.teamId])
            else
                m_team_bg:setVisible(false)
                m_team_lb:setString("")
            end
            local icon = game_util:createCardIconByCid(itemData.cards_info.c_id,itemData.cards_info)
            if icon then
                icon:setScale(0.5)
                m_icon_node:addChild(icon)
                local viewSize = m_icon_node:getContentSize()
                icon:setPosition(ccp(viewSize.width*0.5 + 1, viewSize.height*0.5 - 1))
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
    	if eventType == "ended" then
            local itemData = tempTable[index+1]
            local flag,key = self:checkValueInTable(itemData.uid, self.m_selectTab)
            local m_team_bg = ccbNode:spriteForName("m_team_bg")
    		if self.m_selectIndex == index+1 then
                local owner = self.m_tGameData.owner or ""
                local myUid = game_data:getUserStatusDataByKey("uid")
                if owner ~= myUid then
                    return
                end
                local m_team_lb = ccbNode:labelTTFForName("m_team_lb")
                if flag then
                    self.m_changed = true
                    table.remove(self.m_selectTab,key);
                    m_team_lb:setString("")
                    m_team_bg:setVisible(false)
                    tempTable[index+1].teamId = 0
                    local id = itemData.uid
                    if self.m_all_playerData[id] then
                        self.m_all_playerData[id].teamId = 0
                    end
                else
                    if game_util:getTableLen(self.m_selectTab) < 5 then
                        if tempTable[index+1].teamId and tempTable[index+1].teamId > 0 then
                            game_util:addMoveTips({text = "Thẻ này đã ở chi đội thứ" .. btn_lb[tempTable[index+1].teamId] .. "\n Xin hãy về lại đội cho Thẻ này lui trận",new_color = ccc3(123,255,255)})
                            return
                        end
                        self.m_changed = true
                        tempTable[index+1].teamId = self.m_selectTeam
                        self.m_selectTab[#self.m_selectTab+1] = tempTable[index+1]
                        m_team_lb:setString(btn_lb[self.m_selectTeam])
                        m_team_bg:setVisible(true)
                        local id = itemData.uid
                        if self.m_all_playerData[id] then
                            self.m_all_playerData[id].teamId = self.m_selectTeam
                        end
                    else
                        game_util:addMoveTips({text = "Thẻ đã chọn đã đạt giới hạn tối đa!",new_color = ccc3(123,255,255)})
                        return
                    end
                end
                self:refreshTeamIcon()

    		else
    			if self.m_selSprite then
                    self.m_selSprite:setOpacity(100)
    			end
    			local m_sel_bg = ccbNode:spriteForName("m_sel_bg")
    			m_sel_bg:setVisible(true)
                m_sel_bg:setOpacity(255)
    			self.m_selSprite = m_sel_bg
    			self.m_selectIndex = index + 1
                local owner = self.m_tGameData.owner or ""
                local myUid = game_data:getUserStatusDataByKey("uid")
                if owner ~= myUid then
                    return
                end
                local count = game_util:getTableLen(self.m_all_playerData)
                if count > 1 then
                    game_util:setCCControlButtonEnabled(self.m_out_btn,true)
                end
    			-- self:refreshCardInfo()
    		end
    	end
    end
    return TableViewHelper:create(params);
end



function game_teamRaid_sec:refreshTableVIew( flag )
	-- body
    local count = game_util:getTableLen(self.m_all_playerData)
    if  self.m_EnterFlag == 2 then
        if count < 2 then
            game_util:setCCControlButtonEnabled(self.m_btn_dis,true)
        else
            game_util:setCCControlButtonEnabled(self.m_btn_dis,false)
        end
    end
    local offY = 0

    if not flag then 
        self.m_selSprite = nil
        self.m_selectIndex = 0
    else
        if self.m_listTableView then
            offY = self.m_listTableView:getContentOffset().y
        end
    end
    local tempTab = self:selectCardsByType()
    self.m_tempTab = tempTab
	local tempTableView = self:createTableView(self.m_list_node:getContentSize(),tempTab)
	self.m_list_node:removeAllChildrenWithCleanup(true)
	if tempTableView then
		self.m_list_node:addChild(tempTableView)
        self.m_listTableView = tempTableView
        if flag then
	       tempTableView:setContentOffset(ccp(0,offY))
       end
       if self.m_offY then
           tempTableView:setContentOffset(ccp(0,self.m_offY))
           self.m_offY = nil
       end
    end
    if game_util:getTableLen(self.m_all_playerData) <= 1 and self.m_EnterFlag == 2 then
        self.m_btn_dis:setVisible(true)
        self.m_out_btn:setVisible(false)
    else
        self.m_btn_dis:setVisible(false)
        if self.m_selectIndex == 0 then
            game_util:setCCControlButtonEnabled(self.m_out_btn,false)
        else
            game_util:setCCControlButtonEnabled(self.m_out_btn,true)
        end
    end
end



function game_teamRaid_sec:refreshBtn( flag )
	-- body
    local flag = flag or 0
    local function onBtnCilck( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("press button tag is ", btnTag)
        if self.m_selectScreenType == btnTag then
            self.m_selectScreenType = 0
        else
            self.m_selectScreenType = btnTag
        end
        self:refreshBtn(self.m_selectScreenType)
    end
    for i=1,4 do
        local fileName1 = "ui_teamRaid_sec_iconbg2.png"
        local fileName2 = "ui_teamRaid_sec_iconbg2.png"
        local attrNode = self.m_ccbNode:spriteForName("m_attr_node" .. i)
        local occuNode = self.m_ccbNode:spriteForName("m_occu_node" .. i)
        if attr_tab[i] and PUBLIC_ABILITY_TABLE["ability_" .. attr_tab[i]] then
            attrNode:setVisible(true)
            attrNode:removeAllChildrenWithCleanup(true)
            local attrIcon = CCSprite:createWithSpriteFrameName(PUBLIC_ABILITY_TABLE["ability_" .. attr_tab[i]].icon);
            if attrIcon then
                attrNode:addChild(attrIcon)
                local viewSize = attrNode:getContentSize()
                attrIcon:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition( attrIcon:getContentSize().width * 0.5, attrIcon:getContentSize().height * 0.5 )
                button:setOpacity(0)
                button:setScale(0.4)
                button:setZoomOnTouchDown(false);
                button:setTag(attr_tab[i])
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
                attrIcon:addChild(button)
            end
            if attr_tab[i] == flag then
                fileName1 = "ui_teamRaid_sec_iconbg22.png"
            end
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName1))
            if tempSpriteFrame then
                attrNode:setDisplayFrame(tempSpriteFrame)
            end
        else
            attrNode:setVisible(false)
        end

        if occu_tab[i] then
            local occuIcon = CCSprite:createWithSpriteFrameName("public_ocupation" .. i-1 .. ".png");
            occuNode:setVisible(true)
            if occuIcon then
                occuNode:addChild(occuIcon)
                local viewSize = occuNode:getContentSize()
                occuIcon:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition( occuIcon:getContentSize().width * 0.5, occuIcon:getContentSize().height * 0.5 )
                button:setOpacity(0)
                button:setScale(0.4)
                button:setZoomOnTouchDown(false);
                button:setTag(occu_tab[i])
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
                occuIcon:addChild(button)
            end
            if occu_tab[i] == flag then
                fileName2 = "ui_teamRaid_sec_iconbg22.png"
            end
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName2))
            if tempSpriteFrame then
                occuNode:setDisplayFrame(tempSpriteFrame)
            end
        else
            occuNode:setVisible(false)
        end
    end
    self:refreshTableVIew()
end

function game_teamRaid_sec:refreshTeamIcon(  )
    -- body
    for i=1,5 do
        local m_team_icon = self.m_ccbNode:nodeForName("m_team_icon" .. i)
        m_team_icon:removeAllChildrenWithCleanup(true)
        if self.m_selectTab[i] then
            local itemData = self.m_selectTab[i]
            local icon = game_util:createCardIconByCid(itemData.cards_info.c_id,itemData.cards_info)
            if icon then
                icon:setScale(0.5)
                m_team_icon:addChild(icon)
                local viewSize = m_team_icon:getContentSize()
                icon:setPosition(ccp(viewSize.width*0.5 + 1, viewSize.height*0.5 - 1))
            end
        end
    end
end

function game_teamRaid_sec:selectCardsByType(  )
    -- body
    local tempTab = {}
    local screenType = self.m_selectScreenType or 0
    if screenType == 0 then
        for k,v in pairs(self.m_all_playerData) do
            tempTab[#tempTab+1] = v
        end
        return tempTab
    else
        if screenType > 200 then  -- 属性筛选
            for k,v in pairs(self.m_all_playerData) do
                local cards_info = v.cards_info
                local cardId = cards_info.c_id;
                local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(cardId);
                local card_attr = itemConfig:getNodeWithKey("card_attr") and itemConfig:getNodeWithKey("card_attr"):toInt() or 0
                if screenType == card_attr then
                    tempTab[#tempTab+1] = v
                end
            end
        elseif screenType < 200 and screenType > 0 then  -- 职业筛选
            for k,v in pairs(self.m_all_playerData) do
                local cardId = v.cards_info.c_id;
                local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(cardId);
                if itemConfig:getNodeWithKey("is_skin") then
                    if itemConfig:getNodeWithKey("is_skin"):toInt() ~= 0 then
                        local skinID = itemConfig:getNodeWithKey("is_skin"):toInt()
                        local flag = game_util:isWearSkin(skinID)
                        if flag then
                            local character_detail_cfg = getConfig(game_config_field.character_detail);
                            itemConfig = character_detail_cfg:getNodeWithKey(tostring(skinID));
                        end
                    end
                end
                local animation = itemConfig:getNodeWithKey("animation"):toStr();
                local occupation_cfg = getConfig(game_config_field.occupation);
                local occupation_item_cfg = occupation_cfg:getNodeWithKey(animation)
                local occupation_item_cfg2 = itemConfig:getNodeWithKey("occupation_shade")
                if occupation_item_cfg then
                    local occupationType = occupation_item_cfg:toInt();
                    if occupationType >=0 and occupationType <4 then 
                        if occupationType == screenType-1 then
                            tempTab[#tempTab+1] = v
                        end
                    else
                        local occupationType2 = occupation_item_cfg2:toInt();
                        if occupationType2 == screenType-1 then
                            tempTab[#tempTab+1] = v
                        end
                    end
                end
            end
        end
    end
    return tempTab
end


function game_teamRaid_sec:checkValueInTable( value, tempTable )
    -- body
    for k,v in pairs(tempTable) do
        if value == v.uid then
            return true,k
        end
    end
    return false
end


function game_teamRaid_sec:refreshUi(  )
	-- body
    if self.m_EnterFlag == 2 then
        self.m_btn_dis:setVisible(true)
    else
        self.m_btn_dis:setVisible(false)
    end
	self:refreshBtn(self.m_selectScreenType)
    self:refreshTeamIcon()
    local owner = self.m_tGameData.owner or ""
    local myUid = game_data:getUserStatusDataByKey("uid")
    -- if owner ~= myUid then
        game_util:setCCControlButtonEnabled(self.m_apply_list_btn,(owner == myUid))
        -- game_util:setCCControlButtonEnabled(self.m_btn_sign_up,(owner == myUid))
        self.m_btn_sign_up:setVisible(owner == myUid)
        self.m_btn_Memout:setVisible(owner ~= myUid)
        game_util:setCCControlButtonEnabled(self.m_btn_began,(owner == myUid))
    -- end
    if self.m_hongdian_sp and self.m_have_apply and owner == myUid then
        self.m_hongdian_sp:setVisible(true)
    else
        self.m_hongdian_sp:setVisible(false)
    end
    if self.m_time and self.m_time > 1 then
        self.m_btn_refresh:setTouchEnabled(false)
        self.m_btn_refresh:setColor(ccc3(100,100,100))

        local function timeEndFunc(label,type)
            self.m_btn_refresh:setTouchEnabled(true)
            self.m_btn_refresh:setColor(ccc3(255,255,255))
            self.m_hongdian_sp:removeAllChildrenWithCleanup(true)
        end
        local countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8);
        countdownLabel:setPosition(ccp(self.m_hongdian_sp:getContentSize().width*0.5,self.m_hongdian_sp:getContentSize().height*0.5))
        if self.m_hongdian_sp ~= nil then
            self.m_hongdian_sp:removeAllChildrenWithCleanup(true)
            self.m_hongdian_sp:addChild(countdownLabel)
        end
        countdownLabel:setTime(self.m_time);
        countdownLabel:setVisible(false)
    end
end


function game_teamRaid_sec:init( t_params )
	-- body
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res_add.plist");
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
	self.m_selectTab = {}
    self.m_selectIndex = 0
    self.m_selectTeam = 1
    self.m_teamCardsTab = {}

    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
       local data = t_params.gameData:getNodeWithKey("data")
       self.m_tGameData = json.decode(data:getFormatBuffer())
    end
    local tempData = t_params.tempData
    if tempData then
        self.m_selectTeam = tempData.team
        self.m_offY = tempData.offY
        self.m_selectScreenType = tempData.screenType
        self.m_time = tempData.time
    end
    self.m_have_apply = self.m_tGameData.have_apply
    self.m_player_data = self.m_tGameData.player_data or {}
    local all_player = self.m_tGameData.all_player or {}
    local player_data = self.m_tGameData.player_data
    local all_team = self.m_tGameData.all_team or {}
    for i=1,12 do
        local tab = all_team["team_" .. i] or {}
        for k,v in pairs(tab) do
            if v ~= "0" then
                player_data[v].teamId = i
                self.m_teamCardsTab[i] = self.m_teamCardsTab[i] or {}
                self.m_teamCardsTab[i][#self.m_teamCardsTab[i] + 1] = player_data[v]
            end
        end
    end
    self.m_selectTab = self.m_teamCardsTab[self.m_selectTeam] or {}
    self.m_cards_Tab = {}
    self.m_all_playerData = {}
    for k,v in pairs(all_player) do
        local data = player_data[k]
        if data then
            self.m_cards_Tab[#self.m_cards_Tab+1] = data
            self.m_cards_Tab[#self.m_cards_Tab].index = #self.m_cards_Tab
            -- self.m_cards_Tab[#self.m_cards_Tab].team = 0
            self.m_all_playerData[k] = data
            self.m_all_playerData[k].teamId = data.teamId or 0
        end
    end
    self.m_EnterFlag = t_params.enterFlag or 2
    self.m_EnterType = t_params.enterType or ""
    self.m_changed = false
end

function game_teamRaid_sec:create( t_params )
	-- body
	local scene = CCLayer:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end

return game_teamRaid_sec