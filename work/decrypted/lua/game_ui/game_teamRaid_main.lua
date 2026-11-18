local game_teamRaid_main = {
    m_create_btn = nil,
    m_list_btn = nil,
    m_enter_btn1 = nil,
    m_enter_btn2 = nil,
    content_node = nil,
    text_scroll = nil,
    m_signUp_node = nil,
    m_team_node = nil,
    m_team_node1 = nil,
    m_team_name1 = nil,
    m_team_node2 = nil,
    m_team_name2 = nil,
    m_ccbNode = nil,
    m_tGameData = nil,
    m_enterFlag = nil,
    m_team1 = nil,
    m_team2 = nil,
    m_team3 = nil,
    m_openPopType = nil,
    m_listPage = nil,
    m_selectIndex = nil,
}

function game_teamRaid_main:destroy(  )
	-- body
    cclog("  ----------------  game_teamRaid_main  destroy  ----------------   ")
    self.m_create_btn = nil;
    self.m_list_btn = nil;
    self.m_enter_btn1 = nil;
    self.m_enter_btn2 = nil;
    self.content_node = nil;
    self.text_scroll = nil;
    self.m_signUp_node = nil;
    self.m_team_node = nil;
    self.m_team_node1 = nil;
    self.m_team_name1 = nil;
    self.m_team_node2 = nil;
    self.m_team_name2 = nil;
    self.m_ccbNode = nil;
    self.m_tGameData = nil;
    self.m_enterFlag = nil;
    self.m_team1 = nil;
    self.m_team2 = nil;
    self.m_team3 = nil;
    self.m_openPopType = nil;
    self.m_listPage = nil;
    self.m_selectIndex = nil;
end

function game_teamRaid_main:back(  )
	-- body
    if self.m_enterFlag == 1 then
	   game_scene:enterGameUi("game_main_scene",{gameData = nil})
    elseif self.m_enterFlag == 2 then
        require("like_oo.oo_controlBase"):openView("guild");
    end
end

function game_teamRaid_main:createUi(  ) -- test_touch
	-- body
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
        	self:back()
    	elseif btnTag == 2 then   --  报名
            local text = ""
            local group_outpost = getConfig(game_config_field.group_outpost) and json.decode(getConfig(game_config_field.group_outpost):getNodeWithKey("1"):getFormatBuffer()) or {}
            if self.m_enterFlag == 1 then
                local ticket_single = group_outpost.ticket_single or {}
                local icon, name, count = game_util:getRewardByItemTable(ticket_single[1])
                text = "Đăng ký tiêu thụ sắp tới" .. count .. name
            elseif self.m_enterFlag == 2 then
                text = "Đăng ký tiêu thụ sắp tới" .. (group_outpost.ticket_guild or 100 ) .. "Chiến Kỳ Công Hội"
            end

            local t_params = 
            {
                title = "Nhắc nhở",
                okBtnCallBack = function(target,event)
                    require("game_ui.game_pop_up_box").close(); 
                    local function responseMethod( tag, gameData )
                        if gameData then
                            game_scene:enterGameUi("game_teamRaid_main",{gameData = gameData,enterFlag = self.m_enterFlag})
                        end
                    end
                    local params = {}
                    params.type = self.m_enterFlag
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_sign_up"), http_request_method.GET, params,"team_raid_sign_up")
                end,   --可缺省
                cancelBtnCallBack = function(target,event) cclog("rightBtnCallBack") require("game_ui.game_pop_up_box").close(); end,   --可缺省
                okBtnText = "Xác định",       --可缺省
                cancelBtnText = "Hủy",
                text = text,      --可缺省
            }
            require("game_ui.game_pop_up_box").show(t_params);
                
        elseif btnTag == 3 then -- 攻坚团列表
            -- search_raid_index
            local canJoinIn = true
            if (self.m_team2.id and self.m_enterFlag == 1 ) or (self.m_team3.id and self.m_enterFlag == 2 ) then
                canJoinIn = false
            end
            cclog2(self.m_team2)
            cclog2(canJoinIn)
            local function responseMethod( tag, gameData )
                if gameData then
                    game_scene:addPop("game_teamRaid_teamList",{gameData = gameData,enterFlag = self.m_enterFlag,page = 1,selectIndex = 1,canJoinIn = canJoinIn})
                end
            end
            local params = {}
            params.type = self.m_enterFlag
            params.page = 1
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_search_raid_index"), http_request_method.GET, params,"team_raid_search_raid_index")

        elseif btnTag == 4 then -- 创建攻坚团
            local function responseMethod( tag, gameData )
                if gameData then
                    game_scene:enterGameUi("game_teamRaid_signUp_scene",{gameData = gameData,enterFlag = self.m_enterFlag,enterType = "createPrivate"})
                end
            end
            local params = {}
            params.type = self.m_enterFlag
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_cards_for_team"), http_request_method.GET, nil,"team_raid_cards_for_team")
        elseif btnTag == 11 then
            game_data:setTeamRaidMsg("enterFlag",self.m_enterFlag)
            if self.m_enterFlag == 1 then   -- 个人团
                local function responseMethod( tag, gameData )
                    if gameData then
                        local data = gameData:getNodeWithKey("data")
                        local stage = data:getNodeWithKey("stage"):toInt()
                        local stage_small = data:getNodeWithKey("stage_small") and data:getNodeWithKey("stage_small"):toInt()
                        if stage and stage ~= 0 then
                            if stage == 1 then
                                if stage_small == 1 then
                                    game_scene:enterGameUi("game_teamRaid_first_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                                elseif stage_small == 2 then
                                    game_scene:enterGameUi("game_teamRaid_firstBoss_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                                end
                            elseif stage == 2 then
                                if stage_small == 1 then
                                    game_scene:enterGameUi("game_teamRaid_last_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                                elseif stage_small == 2 then
                                    game_scene:enterGameUi("game_teamRaid_lastBoss_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                                end
                            elseif stage == 3 then
                                game_scene:enterGameUi("game_teamRaid_third_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                            elseif stage == 999 then
                                game_scene:addPop("game_teamRaid_result_pop",{gameData = gameData,enterFlag = self.m_enterFlag})
                            end
                        else
                            game_scene:enterGameUi("game_teamRaid_sec",{gameData = gameData,enterFlag = self.m_enterFlag})
                        end
                    end
                end
                local params = {}
                params.raid_id = self.m_team1.id or self.m_team2.id
                game_data:setTeamRaidMsg("raid_id",params.raid_id)
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_persion_raid_index"), http_request_method.GET, params,"team_raid_persion_raid_index")
            elseif self.m_enterFlag == 2 then   -- 公会团
                local function responseMethod( tag, gameData )
                    if gameData then
                        local data = gameData:getNodeWithKey("data")
                        local stage = data:getNodeWithKey("stage"):toInt()
                        local stage_small = data:getNodeWithKey("stage_small") and data:getNodeWithKey("stage_small"):toInt()
                        if stage and stage ~= 0 then
                            if stage == 1 then
                                if stage_small == 1 then
                                    game_scene:enterGameUi("game_teamRaid_first_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                                elseif stage_small == 2 then
                                    game_scene:enterGameUi("game_teamRaid_firstBoss_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                                end
                            elseif stage == 2 then
                                if stage_small == 1 then
                                    game_scene:enterGameUi("game_teamRaid_last_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                                elseif stage_small == 2 then
                                    game_scene:enterGameUi("game_teamRaid_lastBoss_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                                end
                            elseif stage == 3 then
                                game_scene:enterGameUi("game_teamRaid_third_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                            elseif stage == 999 then
                                game_scene:addPop("game_teamRaid_result_pop",{gameData = gameData,enterFlag = self.m_enterFlag})
                            end
                        else
                            game_scene:enterGameUi("game_teamRaid_sec",{gameData = gameData,enterFlag = self.m_enterFlag})
                        end
                    end
                end
                local params = {}
                params.raid_id = self.m_team3.id
                game_data:setTeamRaidMsg("raid_id",params.raid_id)
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_persion_raid_index"), http_request_method.GET, params,"team_raid_persion_raid_index")
            end

        elseif btnTag == 12 then
            game_data:setTeamRaidMsg("enterFlag",self.m_enterFlag)
            local function responseMethod( tag, gameData )
                if gameData then
                    local data = gameData:getNodeWithKey("data")
                    local stage = data:getNodeWithKey("stage"):toInt()
                    local stage_small = data:getNodeWithKey("stage_small") and data:getNodeWithKey("stage_small"):toInt()
                    if stage and stage ~= 0 then
                        if stage == 1 then
                            if stage_small == 1 then
                                game_scene:enterGameUi("game_teamRaid_first_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                            elseif stage_small == 2 then
                                game_scene:enterGameUi("game_teamRaid_firstBoss_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                            end
                        elseif stage == 2 then
                            if stage_small == 1 then
                                game_scene:enterGameUi("game_teamRaid_last_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                            elseif stage_small == 2 then
                                game_scene:enterGameUi("game_teamRaid_lastBoss_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                            end
                        elseif stage == 3 then
                            game_scene:enterGameUi("game_teamRaid_third_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                        elseif stage == 999 then
                            game_scene:addPop("game_teamRaid_result_pop",{gameData = gameData,enterFlag = self.m_enterFlag})
                        end
                    else
                        game_scene:enterGameUi("game_teamRaid_sec",{gameData = gameData,enterFlag = self.m_enterFlag})
                    end
                end
            end
            local params = {}
            params.raid_id = self.m_team2.id
            game_data:setTeamRaidMsg("raid_id",params.raid_id)

            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_persion_raid_index"), http_request_method.GET, params,"team_raid_persion_raid_index")
    	end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_teamRaid_main.ccbi");
    local m_btn_close = ccbNode:controlButtonForName("m_btn_close")
    m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.m_create_btn = ccbNode:controlButtonForName("m_create_btn")
    self.m_list_btn = ccbNode:controlButtonForName("m_list_btn")
    ccbNode:controlButtonForName("m_btn_sign_up"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    ccbNode:controlButtonForName("m_list_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    ccbNode:controlButtonForName("m_create_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_enter_btn1 = ccbNode:controlButtonForName("m_enter_btn1")
    self.m_enter_btn2 = ccbNode:controlButtonForName("m_enter_btn2")
    self.m_enter_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_enter_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.content_node = ccbNode:nodeForName("content_node")
    self.text_scroll = ccbNode:scrollViewForName("text_scroll")
    self.text_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY-999)
    self.m_signUp_node = ccbNode:nodeForName("m_signUp_node")
    self.m_team_node = ccbNode:nodeForName("m_team_node")
    self.m_team_node1 = ccbNode:nodeForName("m_team_node1")
    self.m_team_name1 = ccbNode:labelTTFForName("m_team_name1")
    self.m_team_node2 = ccbNode:nodeForName("m_team_node2")
    self.m_team_name2 = ccbNode:labelTTFForName("m_team_name2")


    self.m_ccbNode = ccbNode;
    return ccbNode
end


function game_teamRaid_main:refreshTeamNode(  )
    -- body
    if self.m_enterFlag == 1 then   -- 个人团
        local team1 = {}
        local team2 = {}
        for k,v in pairs(self.m_tGameData.raid_id_head) do
            team1.id = k
            team1.name = v
        end
        for k,v in pairs(self.m_tGameData.raid_id_player) do
            team2.id = k
            team2.name = v
        end
        if self.m_team1.id then
            self.m_team_node1:setVisible(true)
            self.m_team_name1:setString(self.m_team1.name)
            game_util:setCCControlButtonEnabled(self.m_create_btn,false)
            if  self.m_team2.id then
                game_util:setCCControlButtonEnabled(self.m_list_btn,false)
                self.m_team_name1:setPositionY(20)
                self.m_enter_btn1:setPositionY(20)
                self.m_team_name2:setPositionY(-20)
                self.m_enter_btn2:setPositionY(-20)
                self.m_team_node2:setVisible(true)
                self.m_team_name2:setString(self.m_team2.name)
            else
                game_util:setCCControlButtonEnabled(self.m_list_btn,true)
                self.m_team_node2:setVisible(false)
                self.m_team_name1:setPositionY(0)
                self.m_enter_btn1:setPositionY(0)
            end
        elseif self.m_team2.id then
            game_util:setCCControlButtonEnabled(self.m_create_btn,true)
            game_util:setCCControlButtonEnabled(self.m_list_btn,true)

            self.m_team_node1:setVisible(true)
            self.m_team_name1:setPositionY(0)
            self.m_enter_btn1:setPositionY(0)
            self.m_team_node2:setVisible(false)
            self.m_team_name1:setString(self.m_team2.name)
        else
            game_util:setCCControlButtonEnabled(self.m_create_btn,true)
            game_util:setCCControlButtonEnabled(self.m_list_btn,true)

            self.m_team_node1:setVisible(false)
            self.m_team_node2:setVisible(false)
        end
    elseif self.m_enterFlag == 2 then  -- 公会团
        self.m_team_name1:setPositionY(0)
        self.m_enter_btn1:setPositionY(0)
        self.m_team_node2:setVisible(false)
        if self.m_team3.id then
            self.m_team_name1:setString(self.m_team3.name)
            self.m_team_node1:setVisible(true)
        else
            self.m_team_node1:setVisible(false)
        end
        game_util:setCCControlButtonEnabled(self.m_list_btn,true)
        local can_create = self.m_tGameData.can_create
        if self.m_team3.id then
            can_create = false
            -- game_util:setCCControlButtonEnabled(self.m_list_btn,false)
        end
        if can_create then            
            game_util:setCCControlButtonEnabled(self.m_create_btn,true)
        else
            game_util:setCCControlButtonEnabled(self.m_create_btn,false)
        end

    end

end

function game_teamRaid_main:createMsg(  )
    -- body
    local contentText = "1. Nội bộ Liên Minh có thể trực tiếp mở ra tập thể công Phó Bản, do Hội Trưởng tổ chức mở, Hội Trưởng tự phân phối nhân viên phân đội, phó bản mở ra cần tiêu hao Chiến Kỳ Liên Minh!\n2. Nội bộ Liên Minh có thể trực tiếp mở ra tập thể công Phó Bản, do Hội Trưởng tổ chức mở, Hội Trưởng tự phân phối nhân viên phân đội, phó bản mở ra cần tiêu hao Chiến Kỳ Liên Minh!\n3. Nội bộ Liên Minh có thể trực tiếp mở ra tập thể công Phó Bản, do Hội Trưởng tổ chức mở, Hội Trưởng tự phân phối nhân viên phân đội, phó bản mở ra cần tiêu hao Chiến Kỳ Liên Minh!"
    local detailCfg = getConfig(game_config_field.notice_active);
    if detailCfg then
        local detailCfgTab = json.decode(detailCfg:getFormatBuffer())
        if detailCfgTab["204"] then
            local itemCfg = detailCfgTab["204"]
            contentText = itemCfg and itemCfg.word or ""
        end
    end
    local tempLabel1 = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(150,0),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(123,255,255),fontSize = 10})
    local tempLabel2 = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(150,0),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(123,255,255),fontSize = 10})
    local tempSize = tempLabel1:getContentSize();
    self.text_scroll:setContentSize(CCSizeMake(210,tempSize.height))
    local viewSize = self.content_node:getContentSize()
    self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    tempLabel1:setPosition(ccp(0,0.3))
    tempLabel2:setPosition(ccp(0.3,0))
    self.text_scroll:addChild(tempLabel1)
    self.text_scroll:addChild(tempLabel2)
end


function game_teamRaid_main:refreshUi(  )
	-- body
    local have_ticket = self.m_tGameData.have_ticket or 0
    local have_ticket_guild = self.m_tGameData.have_ticket_guild or 0
    if ( have_ticket == 1 and self.m_enterFlag == 1 ) or ( have_ticket_guild == 1 and self.m_enterFlag == 2 )  then
       self.m_signUp_node:setVisible(false)
	   self.m_team_node:setVisible(true)
       self:refreshTeamNode()
    else
        self.m_signUp_node:setVisible(true)
        self.m_team_node:setVisible(false)
        self:createMsg()
    end
    if self.m_openPopType == "team_list" then
        local canJoinIn = true
        if (self.m_team2.id and self.m_enterFlag == 1 ) or (self.m_team3.id and self.m_enterFlag == 2 ) then
            canJoinIn = false
        end
        local function responseMethod( tag, gameData )
            if gameData then
                game_scene:addPop("game_teamRaid_teamList",{gameData = gameData,enterFlag = self.m_enterFlag,page = self.m_listPage,selectIndex = self.m_selectIndex,canJoinIn = canJoinIn})
            end
        end
        local params = {}
        params.type = self.m_enterFlag
        params.page = self.m_listPage or 1
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_search_raid_index"), http_request_method.GET, params,"team_raid_search_raid_index")
    end
end

function game_teamRaid_main:init( t_params )
	-- body
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
       local data = t_params.gameData:getNodeWithKey("data")
       self.m_tGameData = json.decode(data:getFormatBuffer())
    end

    self.m_enterFlag = t_params.enterFlag or 1
    self.m_team1 = {}    -- 个人团   团长
    for k,v in pairs(self.m_tGameData.raid_id_head) do
        self.m_team1.id = k
        self.m_team1.name = v
    end
    self.m_team2 = {}    -- 个人团   团员
    for k,v in pairs(self.m_tGameData.raid_id_player) do
        self.m_team2.id = k
        self.m_team2.name = v
    end
    self.m_team3 = {}    -- 公会团
    for k,v in pairs(self.m_tGameData.raid_id_guild) do
        self.m_team3.id = k
        self.m_team3.name = v
    end
    self.m_openPopType = t_params.openPopType or ""
    self.m_listPage = t_params.page or 1 
    self.m_selectIndex = t_params.selectIndex or 1
end

function game_teamRaid_main:create( t_params )
	-- body
	local scene = CCLayer:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end

return game_teamRaid_main