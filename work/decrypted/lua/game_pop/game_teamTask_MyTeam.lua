local game_teamTask_MyTeam = {
	m_node_mycard = nil,
    m_node_othercard = nil,

    m_sel_team = nil,

    m_btn_lookteam = nil,
    light = nil,
    m_node_tip = nil,

    m_sp_title1 = nil,
    m_sp_title2 = nil,

    m_btn_havedone = nil,
    m_btn_nothavedone = nil,
    all_teams = nil,

    m_tab = nil,
    havedone_teams = nil,

}

function game_teamTask_MyTeam:destroy( )
    self.m_node_mycard = nil;
    self.m_node_othercard = nil;

    self.m_sel_team = nil;

    self.m_btn_lookteam = nil;
    self.light = nil;
    self.m_node_tip = nil;
    self.m_sp_title1 = nil;
    self.m_sp_title2 = nil;

    self.m_btn_havedone = nil;
    self.m_btn_nothavedone = nil;
    self.m_tab = nil;


    self.all_teams = nil;
    self.havedone_teams = nil;
end

function game_teamTask_MyTeam:back(  )
	game_scene:removePopByName("game_teamTask_MyTeam")
end


function game_teamTask_MyTeam:createUi( )
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode")
        local btnTag = tagNode:getTag()
        cclog("  sel  btnTag    is   --------------           " .. btnTag)
        if btnTag == 1 then -- 返回
    		self:back()
    	elseif btnTag ==2 then -- 查看已完成
            self.m_tab = 2
            self:refreshUi()
        elseif btnTag ==4 then -- 查看未完成
            self.m_tab = 1
            self:refreshUi()

        elseif btnTag == 3 then -- 查看队伍
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                data = json.decode(data:getFormatBuffer())
                game_scene:enterGameUi("ui_teamTask_readyScene",{gameData = data,team_id = self.m_sel_team});
            end
            local params = {};
            params.team_id = self.m_sel_team or ""
            cclog(" look team       params.team_id    ------   "..params.team_id)
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_team_data"), http_request_method.GET, params,"team_fight_team_data")
    	end
    end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_teamTask_MyteamPop.ccbi");
    self.m_teamList_node = ccbNode:nodeForName("m_teamList_node")
    local m_root_layer = ccbNode:layerForName("mn_rootLayer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);

    self.m_btn_lookteam = ccbNode:controlButtonForName("m_btn_lookteam")
    self.m_btn_havedone = ccbNode:controlButtonForName("m_btn_havedone")
    self.m_btn_nothavedone = ccbNode:controlButtonForName("m_btn_nothavedone")
    self.m_btn_havedone:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn_lookteam:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn_nothavedone:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_node_mycard = ccbNode:nodeForName("m_node_mycard")
    self.m_node_othercard = ccbNode:nodeForName("m_node_othercard")
    self.m_node_tip = ccbNode:nodeForName("m_node_tip")

    self.m_sp_title1 = ccbNode:spriteForName("m_sp_title1")
    self.m_sp_title2 = ccbNode:spriteForName("m_sp_title2")

    self.m_CCBNode = ccbNode
    return ccbNode
end

function game_teamTask_MyTeam.createTableView(self,viewSize,tableData)
    self.m_node_mycard:removeAllChildrenWithCleanup(true)
    self.m_node_othercard:removeAllChildrenWithCleanup(true)
    tableData = tableData or {}
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tableData ;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_teamTask_MyteamItem.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5 - 10));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_ItemBG = ccbNode:spriteForName("m_ItemBG")
            local m_node_main = ccbNode:nodeForName("m_node_main")
            local m_node_other = ccbNode:nodeForName("m_node_other")
            local m_lb_condition = ccbNode:labelTTFForName("m_lb_condition")
            local m_node_boss = ccbNode:nodeForName("m_node_boss")
            local m_node_bosslevel = ccbNode:nodeForName("m_node_bosslevel")
            m_node_boss:removeAllChildrenWithCleanup(true)
            m_node_main:removeAllChildrenWithCleanup(true)
            m_node_other:removeAllChildrenWithCleanup(true)
            m_node_bosslevel:removeAllChildrenWithCleanup(true)
            -- boss icon
            local iconFile = self.m_bossInfoCfg:getNodeWithKey(tostring(tableData[index+1].teams.boss_id)):getNodeWithKey("icon"):toStr()
            local bossicon = game_util:createIconByName(iconFile,9)
            m_node_bosslevel:addChild(bossicon)
            bossicon:setScale(0.8)

            --boss level
            local bosslevelicon = CCSprite:createWithSpriteFrameName("ui_new_TeamBoss_team_difficulty"..tableData[index+1].teams.boss_level .."2.png") 
            m_node_bosslevel:addChild(bosslevelicon)
            bosslevelicon:setScale(0.4)
            bosslevelicon:setAnchorPoint(ccp(0,1))

            local star1 = CCSprite:createWithSpriteFrameName("ui_new_TeamBoss_team_btn_star.png") 
            bosslevelicon:addChild(star1)
            star1:setScale(0.6)
            star1:setAnchorPoint(ccp(0.5,0.5))
            star1:setPosition(ccp(bosslevelicon:getContentSize().width/2,7))

            if self.m_selectDiffcult > 1  then
                for i=1,2 do
                    local star2 = CCSprite:createWithSpriteFrameName("ui_new_TeamBoss_team_btn_star.png") 
                    bosslevelicon:addChild(star2)
                    star2:setScale(0.6)
                    star2:setAnchorPoint(ccp(0.5,0.5))
                    star2:setPosition(ccp(bosslevelicon:getContentSize().width/2 + ( i==1 and -8 or 8),10))
                end
            end

            if self.m_selectDiffcult > 2  then
                for i=1,2 do
                    local star3 = CCSprite:createWithSpriteFrameName("ui_new_TeamBoss_team_btn_star.png") 
                    bosslevelicon:addChild(star3)
                    star3:setScale(0.6)
                    star3:setAnchorPoint(ccp(0.5,0.5))
                    star3:setPosition(ccp(bosslevelicon:getContentSize().width/2 + ( i==1 and -15 or 15),14))
                end
            end

            --role identity
            m_lb_condition:setString(tableData[index+1].teams.captain==1 and "Thân phận:".. " Đội trưởng" or "Thân phận:".. " Đội viên" )

            --role icon
            local heroCfg = nil
            local quality = nil
            local num = 0
            for k,v in pairs(tableData[index+1].teams.team_info) do
                for k1,v1 in pairs(v) do
                    heroCfg = self.character_detail_cfg:getNodeWithKey(tostring(v1.c_id))
                    local itemCfg = self.character_detail_cfg:getNodeWithKey(v1.c_id)
                    local icon = game_util:createCardIconByCfg(itemCfg,v1)

                    if k.."" == "1" then
                        m_node_main:addChild(icon)
                        icon:setScale(0.8)
                        icon:setPosition(ccp(0,0))
                        icon:setAnchorPoint(ccp(0.5,0.5))
                    else
                        m_node_other:addChild(icon)
                        icon:setPosition(ccp((tonumber(k)-1)*30,0))
                        icon:setScale(0.6)
                        icon:setAnchorPoint(ccp(0.5,0.5))
                    end

                    if index ==0 then
                        local myid = v1.owner_uid
                        if myid.."" == game_data:getUserStatusData().uid.."" then
                            local iconmine = game_util:createCardIconByCfg(itemCfg,v1)
                            self.m_node_mycard:addChild(iconmine)
                            iconmine:setPosition(ccp(0,0))
                            iconmine:setAnchorPoint(ccp(0.5,0.5))
                            iconmine:setScale(0.8)
                        else
                            local iconother = game_util:createCardIconByCfg(itemCfg,v1)
                            self.m_node_othercard:addChild(iconother)
                            iconother:setPosition(ccp(-20,(num*-30)))
                            iconother:setAnchorPoint(ccp(0.5,0.5))
                            iconother:setScale(0.6)
                            
                            local name_after = game_util:getCardName(v1,heroCfg)
                            local tempLabel = game_util:createLabelTTF({text = name_after,color = ccc3(230,160,0),fontSize = 9});
                            iconother:addChild(tempLabel)
                            tempLabel:setAnchorPoint(ccp(0,1))
                            tempLabel:setPosition(ccp(iconother:getContentSize().width*1.1,iconother:getContentSize().height-2))
                            local race_cfg = getConfig(game_config_field.race)
                            local race_item_cfg = race_cfg:getNodeWithKey(v1.race)
                            local raceLabel = game_util:createLabelTTF({text = "",color = ccc3(255,255,255),fontSize = 9});
                            iconother:addChild(raceLabel)
                            raceLabel:setAnchorPoint(ccp(0,0.5))
                            raceLabel:setPosition(ccp(iconother:getContentSize().width*1.1,iconother:getContentSize().height/2-2))
                            if race_item_cfg then
                                raceLabel:setString(race_item_cfg:getNodeWithKey("name"):toStr())
                            else
                                raceLabel:setString("Vô chủng tộc")
                            end

                            local lvLabel = game_util:createLabelTTF({text = "Lv. "..v1.lv,color = ccc3(255,255,255),fontSize = 9});
                            iconother:addChild(lvLabel)
                            lvLabel:setAnchorPoint(ccp(0,0))
                            lvLabel:setPosition(ccp(iconother:getContentSize().width*1.1,2))
                            num  = num +1
                        end
                    end
                end
            end
            if self.m_tab == 1  then
                if self.m_sel_team == nil then
                    self.light = m_ItemBG
                    if index == 0 then
                        self.m_sel_team = tableData[index+1].key
                        m_ItemBG:setColor(ccc3(255,255,255))
                        self.light = m_ItemBG
                    end
                else
                    if self.m_sel_team == tableData[index+1].key then
                        m_ItemBG:setColor(ccc3(255,255,255))
                    else
                        m_ItemBG:setColor(ccc3(100,100,100))
                    end

                end
            else
                m_ItemBG:setColor(ccc3(100,100,100))
            end
            -- cclog2(tableData[index+1])
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            if self.m_tab == 1  then
                cclog("choose cardid :  "..tableData[index+1].key)
                self.m_sel_team = tableData[index+1].key
                self.light:setColor(ccc3(100,100,100))
                local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
                local m_ItemBG = ccbNode:spriteForName("m_ItemBG")
                m_ItemBG:setColor(ccc3(255,255,255))
                self.light = m_ItemBG

                self.m_node_mycard:removeAllChildrenWithCleanup(true)
                self.m_node_othercard:removeAllChildrenWithCleanup(true)

                local heroCfg = nil
                local quality = nil
                local num = 0
                for k,v in pairs(tableData[index+1].teams.team_info) do
                    for k1,v1 in pairs(v) do
                        heroCfg = self.character_detail_cfg:getNodeWithKey(tostring(v1.c_id))
                        quality = v1.quality or heroCfg:getNodeWithKey("quality"):toInt()
                        local myid = v1.owner_uid
                        if myid.."" == game_data:getUserStatusData().uid.."" then
                            local iconmine = game_util:createCardIconByCfg(heroCfg,v1)
                            self.m_node_mycard:addChild(iconmine)
                            iconmine:setPosition(ccp(0,0))
                            iconmine:setAnchorPoint(ccp(0.5,0.5))
                            iconmine:setScale(0.8)
                        else
                            local iconother = game_util:createCardIconByCfg(heroCfg,v1)
                            self.m_node_othercard:addChild(iconother)
                            iconother:setPosition(ccp(-20,(num*-30)))
                            iconother:setAnchorPoint(ccp(0.5,0.5))
                            iconother:setScale(0.6)
                            local name_after = game_util:getCardName(v1,heroCfg)
                            local tempLabel = game_util:createLabelTTF({text = name_after,color = ccc3(230,160,0),fontSize = 9});
                            iconother:addChild(tempLabel)
                            tempLabel:setAnchorPoint(ccp(0,1))
                            tempLabel:setPosition(ccp(iconother:getContentSize().width*1.1,iconother:getContentSize().height-2))
                            local race_cfg = getConfig(game_config_field.race)
                            local race_item_cfg = race_cfg:getNodeWithKey(v1.race)
                            local raceLabel = game_util:createLabelTTF({text = "",color = ccc3(255,255,255),fontSize = 9});
                            iconother:addChild(raceLabel)
                            raceLabel:setAnchorPoint(ccp(0,0.5))
                            raceLabel:setPosition(ccp(iconother:getContentSize().width*1.1,iconother:getContentSize().height/2-2))
                            if race_item_cfg then
                                raceLabel:setString(race_item_cfg:getNodeWithKey("name"):toStr())
                            else
                                raceLabel:setString("Vô chủng tộc")
                            end

                            local lvLabel = game_util:createLabelTTF({text = "Lv. "..v1.lv,color = ccc3(255,255,255),fontSize = 9});
                            iconother:addChild(lvLabel)
                            lvLabel:setAnchorPoint(ccp(0,0))
                            lvLabel:setPosition(ccp(iconother:getContentSize().width*1.1,2))
                            num  = num +1
                        end
                    end
                end
            end
        end
    end
    return TableViewHelper:create(params);
end

-- function game_teamTask_MyTeam:refreshBtn(flag)
--     for i=1,3 do 
--         local fileName = "ui_new_TeamBoss_team_difficulty" .. i .. (i == self.m_selectDiffcult and "1" or "2")
--         local tempBtn = self.m_CCBNode:controlButtonForName("m_taskBtn" .. i)
--         game_util:setCCControlButtonBackground(tempBtn,fileName .. ".png")
--     end
--     if flag then
--         local function responseMethod(tag,gameData)
--             if gameData ~= nil and tolua.type(gameData) == "util_json" then
--                 self.m_gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
--                 self:refreshTableView()
--             end
--         end
--         network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_team_index"), http_request_method.GET, {boss_id = self.m_boss_id,boss_level = self.m_selectDiffcult},"team_fight_team_index")
--     end
-- end

function game_teamTask_MyTeam:refreshTableView()
    self.all_teams = self.all_teams or  {}
    self.havedone_teams = self.havedone_teams or {}
    self.m_teamList_node:removeAllChildrenWithCleanup(true)

    if self.m_tab == 1 then
        if  next(self.all_teams) then
        else
            for k,v in pairs(self.m_gameData.team_own) do
                self.all_teams[#self.all_teams+1] = {}
                self.all_teams[#self.all_teams].key = k
                self.all_teams[#self.all_teams].teams = v
            end
        end
        if next(self.all_teams) then
            self.m_node_tip:setVisible(false)
            self.m_btn_lookteam:setEnabled(true)
            self.m_btn_lookteam:setColor(ccc3(255,255,255))
            local tableView = self:createTableView(self.m_teamList_node:getContentSize(),self.all_teams)
            if tableView then
                self.m_teamList_node:addChild(tableView)
            end
        else
            self.m_node_tip:setVisible(true)
            self.m_btn_lookteam:setEnabled(false)
            self.m_btn_lookteam:setColor(ccc3(100,100,100))
        end
    else

        self.m_sel_team = nil
        self.light = nil
        if  next(self.havedone_teams) then
        else
            for k,v in pairs(self.m_gameData.teams_win) do
                self.havedone_teams[#self.havedone_teams+1] = {}
                self.havedone_teams[#self.havedone_teams].key = k
                self.havedone_teams[#self.havedone_teams].teams = v
            end
            for k,v in pairs(self.m_gameData.teams_lose) do
                self.havedone_teams[#self.havedone_teams+1] = {}
                self.havedone_teams[#self.havedone_teams].key = k
                self.havedone_teams[#self.havedone_teams].teams = v
            end
        end
        if next(self.havedone_teams) then
            self.m_node_tip:setVisible(false)
            local tableView = self:createTableView(self.m_teamList_node:getContentSize(),self.havedone_teams)
            if tableView then
                self.m_teamList_node:addChild(tableView)
            end
        else
            self.m_node_tip:setVisible(true)
        end
    end
end


function game_teamTask_MyTeam:refreshUi(  )
    self.m_sp_title1:setVisible(self.m_tab == 1)
    self.m_sp_title2:setVisible(self.m_tab == 2)

    self.m_btn_havedone:setVisible(self.m_tab == 1)
    self.m_btn_nothavedone:setVisible(self.m_tab == 2)
    self.m_btn_lookteam:setVisible(self.m_tab == 1)

    self:refreshTableView()
end

function game_teamTask_MyTeam:init( t_params )
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    else
        self.m_gameData = {}
    end

    self.m_tab = 1
    self.m_selectDiffcult = t_params.boss_level or 1
    self.m_boss_id = t_params.boss_id
    self.m_selIcon = t_params.selIcon
    self.m_bossInfoCfg = getConfig(game_config_field.boss_info)

    self.character_detail_cfg = getConfig(game_config_field.character_detail);
end

function game_teamTask_MyTeam:create( t_params )
	self:init(t_params)
	local pop = self:createUi()
	self:refreshUi()
	return pop
end
return game_teamTask_MyTeam