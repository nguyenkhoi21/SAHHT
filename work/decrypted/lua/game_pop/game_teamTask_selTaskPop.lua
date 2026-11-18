local game_teamTask_selTaskPop = {
	m_boss_type = nil,
    m_btn_join = nil,
    m_btn_create = nil,
    m_btn_refuse = nil,
    m_btn_accept = nil,
    m_fromtype = nil,
    m_fromteamid = nil,
    msg_msg_id = nil,
    m_node_tip = nil,
    m_lb_bosscond = nil,
    m_btn_refresh = nil,
    -- m_label_refresh = nil,
    ticktb = {},


}
function game_teamTask_selTaskPop:destroy( )
	-- body
    self.m_boss_type = nil;
    self.m_btn_join = nil;
    self.m_btn_create = nil;
    self.m_btn_refuse = nil;
    self.m_btn_accept = nil;
    self.m_fromtype = nil;
    self.m_fromteamid = nil;
    self.msg_msg_id = nil;
    self.m_node_tip = nil;
    self.m_lb_bosscond = nil;
    self.m_btn_refresh = nil;
    -- self.m_label_refresh = nil;
    self.ticktb = {};
end

function game_teamTask_selTaskPop:back(  )
    if self.m_fromtype then
        local t_params = 
        {
            title = string_config.m_title_prompt,
            okBtnCallBack = function(target,event)
                self:destroytick()
                local function responseMethod(tag,gameData)
                    game_scene:removePopByName("game_teamTask_selTaskPop")
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_refuse_invitation"), http_request_method.GET, {message_id = self.msg_msg_id},"team_fight_refuse_invitation")
                game_util:closeAlertView();
            end,   --可缺省
            okBtnText = string_config.m_btn_sure,       --可缺省
            text = "Từ chối lời mời?",      --可缺省
            onlyOneBtn = false,
        }
        game_util:openAlertView(t_params);
    else
        self:destroytick()
        game_scene:removePopByName("game_teamTask_selTaskPop")
    end
end

function game_teamTask_selTaskPop:destroytick()
    for i,v in ipairs(self.ticktb) do
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(v.shared)
    end
end

function game_teamTask_selTaskPop:createUi( )
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode")
        local btnTag = tagNode:getTag()
        cclog("  sel  btnTag    is   --------------           " .. btnTag)
        if btnTag == 1 then -- 返回
    		self:back()
    	elseif btnTag ==2 then -- 创建队伍
            local function responseMethod(tag,gameData)
                self:destroytick()
                game_scene:enterGameUi("game_TeamTask_checkHero_scene",{gameData = gameData,boss_langid = self.m_boss_langid,boss_id = self.m_boss_id,boss_level = self.m_selectDiffcult,isMycreate = 1})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_cards_for_team_creat"), http_request_method.GET, {boss_id = self.m_boss_id,boss_level = self.m_selectDiffcult},"team_fight_cards_for_team_creat")
        elseif btnTag == 3 then -- 加入队伍
            --team_fight_cards_for_join_team
            -- local function responseMethod(tag,gameData)
            --     self:destroytick()
            --     game_scene:enterGameUi("game_TeamTask_checkHero_scene",{gameData = gameData,boss_langid = self.m_boss_langid,boss_id = self.m_boss_id,boss_level = self.m_selectDiffcult,isMycreate = 0,team_id = self.m_selectTeamId})
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_cards_for_join_team"), http_request_method.GET, {team_id = self.m_selectTeamId},"team_fight_cards_for_join_team")

        elseif btnTag == 4 then -- 拒绝
            -- team_fight_refuse_invitation = "/api/?method=team_fight.refuse_invitation",          -- 拒接邀请  message_id    

            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    local function responseMethod(tag,gameData)
                        self:destroytick()
                        game_scene:removePopByName("game_teamTask_selTaskPop")
                        game_scene:enterGameUi("game_main_scene",{gameData = nil,  openPop = nil});
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_refuse_invitation"), http_request_method.GET, {message_id = self.msg_msg_id},"team_fight_refuse_invitation")
                    game_util:closeAlertView();
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                text = "Từ chối lời mời?",      --可缺省
                onlyOneBtn = false,
            }
            game_util:openAlertView(t_params);
        elseif btnTag == 5 then -- 同意
            -- team_fight_accept_invitation = "/api/?method=team_fight.accept_invitation",          -- 接受邀请  message_id    team_id
            --team_fight_cards_for_join_team
            local function responseMethod(tag,gameData)
                self:destroytick()
                game_scene:enterGameUi("game_TeamTask_checkHero_scene",{gameData = gameData,boss_langid = self.m_boss_langid,boss_id = self.m_boss_id,boss_level = self.m_selectDiffcult,isMycreate = 0,team_id = self.m_selectTeamId})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_accept_invitation"), http_request_method.GET, {team_id = self.m_selectTeamId,message_id = self.msg_msg_id},"team_fight_accept_invitation")
        elseif btnTag > 10 and btnTag < 20 then
            self.m_selectDiffcult = btnTag - 10
            ccbNode:controlButtonForName("m_taskBtn1"):setScale(0.8)
            ccbNode:controlButtonForName("m_taskBtn2"):setScale(0.8)
            ccbNode:controlButtonForName("m_taskBtn3"):setScale(0.8)
            self:refreshBtn(true)
        elseif btnTag == 23 then
            local function responseMethod(tag,gameData)
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    self.m_gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                else
                    self.m_gameData = {}
                end
                
                self:destroytick()
                self:refreshRefBtn(true)
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_team_index"), http_request_method.GET, {boss_id = self.m_boss_id,boss_level = self.m_selectDiffcult},"team_fight_team_index")
    	end
    end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_teamTask_teamPop.ccbi");
    self.m_teamList_node = ccbNode:nodeForName("m_teamList_node")
    local m_root_layer = ccbNode:layerForName("mn_rootLayer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);

    ccbNode:controlButtonForName("m_taskBtn1"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    ccbNode:controlButtonForName("m_taskBtn2"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    ccbNode:controlButtonForName("m_taskBtn3"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    self.m_btn_create = ccbNode:controlButtonForName("m_btn_create")
    self.m_btn_refuse = ccbNode:controlButtonForName("m_btn_refuse")
    self.m_btn_accept = ccbNode:controlButtonForName("m_btn_accept")
    self.m_btn_join = ccbNode:controlButtonForName("m_btn_join")
    self.m_btn_join:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn_accept:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn_refuse:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn_create:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_bossNode = ccbNode:nodeForName("m_bossNode")
    ccbNode:controlButtonForName("m_taskBtn1"):setScale(1)
    self.m_node_tip = ccbNode:nodeForName("m_node_tip")
    self.m_lb_bosscond = ccbNode:labelTTFForName("m_lb_bosscond")
    self.m_btn_refresh = ccbNode:controlButtonForName("m_btn_refresh")
    -- self.m_label_refresh = ccbNode:nodeForName("m_label_refresh")
    self.m_btn_refresh:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_CCBNode = ccbNode
    return ccbNode
end


function game_teamTask_selTaskPop:refreshRefBtn(flag)
    -- body
    if flag then
        self:refreshUi()
        if self.m_label_refresh then
            self.m_btn_refresh:setEnabled(false)
            self.m_btn_refresh:setColor(ccc3(150,150,150))
            self.m_label_refresh:setVisible(true)
            self.m_label_refresh:removeAllChildrenWithCleanup(true)
            local function timeOverFunc(label,type)
                self:refreshRefBtn()
            end
            local timeOverLabel = game_util:createCountdownLabel(3,timeOverFunc,8,2)
            timeOverLabel:setAnchorPoint(ccp(0,0.5))
            self.m_label_refresh:addChild(timeOverLabel)
        end
    else
        self.m_label_refresh:setVisible(false)
        self.m_label_refresh:removeAllChildrenWithCleanup(true)
        self.m_btn_refresh:setEnabled(true)
        self.m_btn_refresh:setColor(ccc3(255,255,255))
    end
end

--ui_teamTask_teamItem.ccbi
--ui_teamTask_checkHero_scene.ccbi

function game_teamTask_selTaskPop.createTableView(self,viewSize,tableData)
    -- cclog2(tableData)
    tableData = tableData or {}

    local function onClick(target,event)
        local tagNode = tolua.cast(target,"CCNode")
        local btnTag = tagNode:getTag()
        local function responseMethod(tag,gameData)
            self:destroytick()
            game_scene:enterGameUi("game_TeamTask_checkHero_scene",{gameData = gameData,boss_langid = self.m_boss_langid,boss_id = self.m_boss_id,boss_level = self.m_selectDiffcult,isMycreate = 0,team_id = tableData[btnTag].key})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_cards_for_join_team"), http_request_method.GET, {team_id = tableData[btnTag].key},"team_fight_cards_for_join_team")
    end

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
            ccbNode:registerFunctionWithFuncName("onClick",onClick);
            ccbNode:openCCBFile("ccb/ui_teamTask_teamItem.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5 - 10));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ItemData = tableData[index+1]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            self:setInfoByData(ccbNode,ItemData,index)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            -- if self.m_selItemBG then
            --     self.m_selItemBG:setColor(ccc3(80,80,80))
            -- end
            -- local itemData = tableData[index+1]
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
            -- local m_ItemBG = ccbNode:scale9SpriteForName("m_ItemBG")
            -- m_ItemBG:setColor(ccc3(255,255,255))
            -- self.m_selItemBG = m_ItemBG
            -- self.m_selectTeamIndex = index+1
            -- self.m_selectTeamId = itemData.key
        end
    end
    return TableViewHelper:create(params);
end

function game_teamTask_selTaskPop:setInfoByData(ccbNode, itemData,index)
    local m_lb_name = ccbNode:labelTTFForName("m_lb_name")
    local m_node_heroother = ccbNode:nodeForName("m_node_heroother")
    local m_node_heromain = ccbNode:nodeForName("m_node_heromain")
    local m_node_bosslevel = ccbNode:nodeForName("m_node_bosslevel")
    local m_ItemBG = ccbNode:scale9SpriteForName("m_ItemBG")
    local m_btn_jointeam = ccbNode:controlButtonForName("m_btn_jointeam")
    m_btn_jointeam:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    m_btn_jointeam:setTag(index+1)

    local m_node_scroll = ccbNode:nodeForName("m_node_scroll")
    m_node_scroll:removeAllChildrenWithCleanup(true)
    m_node_heroother:removeAllChildrenWithCleanup(true)
    m_node_heromain:removeAllChildrenWithCleanup(true)
    m_node_bosslevel:removeAllChildrenWithCleanup(true)
    m_node_bosslevel:setVisible(self.m_fromtype~=nil)
    m_btn_jointeam:setVisible(self.m_fromtype==nil)

    local scrollwidth = 150
    local scrollheight = 30
    local scrollSize = CCSizeMake(scrollwidth,scrollheight);
    local scrollView = CCScrollView:create(scrollSize)
    m_node_scroll:addChild(scrollView)
    scrollView:setAnchorPoint(ccp(0,0))
    scrollView:setPosition(ccp(0,0))

    -- if self.m_selectTeamIndex == index+1 then
    self.m_selectTeamId = itemData.key
    m_ItemBG:setColor(ccc3(255,255,255))
        -- self.m_selItemBG = m_ItemBG
    -- else
    --     m_ItemBG:setColor(ccc3(80,80,80))
    -- end
    --boss
    if self.m_boss_langid then
        if self.m_fromtype ~= nil then
            local bosslevelicon = CCSprite:createWithSpriteFrameName("ui_new_TeamBoss_team_difficulty"..self.m_selectDiffcult .."2.png") 
            m_node_bosslevel:addChild(bosslevelicon)
            m_node_bosslevel:setScale(0.8)

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
        end

        local str = self:getBossTypeStr(self.m_boss_type)
        local tempLabel = game_util:createLabelTTF({text = "",color = ccc3(255,255,255),fontSize = 8});
        scrollView:addChild(tempLabel)
        tempLabel:setAnchorPoint(ccp(0,0))
        tempLabel:setPosition(ccp(0,0))

        if tempLabel:getContentSize().width>scrollwidth then

            local tempLabel2 = game_util:createLabelTTF({text = str,color = ccc3(255,255,255),fontSize = 8});
            scrollView:addChild(tempLabel2)
            tempLabel2:setAnchorPoint(ccp(0,0))
            tempLabel2:setPosition(ccp(tempLabel:getContentSize().width+5,0))

            function tick( dt )
                cclog("------------- move ------------------ tick ")
                if tempLabel then
                    tempLabel:setPositionX(tempLabel:getPositionX()-1)
                    tempLabel2:setPositionX(tempLabel2:getPositionX()-1)
                    if tempLabel:getPositionX() < -1 * tempLabel:getContentSize().width then
                        tempLabel:setPositionX(tempLabel2:getPositionX()+tempLabel2:getContentSize().width + 5)
                    elseif tempLabel2:getPositionX() < -1 * tempLabel2:getContentSize().width then
                        tempLabel2:setPositionX(tempLabel:getPositionX()+tempLabel:getContentSize().width + 5)
                    end
                else
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared)
                end
            end
            -- local m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0 , false);
            -- table.insert(self.ticktb,{lb1 = tempLabel,lb2 = tempLabel2,shared = m_shared})
        end

        for k,v in pairs(itemData.teams) do
            for k1,v1 in pairs(v) do
                local heroCfg = self.character_detail_cfg:getNodeWithKey(tostring(v1.cards_info.c_id))
                local icon = game_util:createCardIconByCfg(heroCfg,v1.cards_info)

                if k.."" =="1" then 
                    m_node_heromain:addChild(icon)
                    icon:setScale(0.7)
                    icon:setPosition(ccp(0,0))
                    icon:setAnchorPoint(ccp(0.5,0.5))
                    m_lb_name:setString(v1.name)
                else
                    m_node_heroother:addChild(icon)
                    icon:setPosition(ccp((tonumber(k)-1)*30-20,-1))
                    icon:setScale(0.5)
                    icon:setAnchorPoint(ccp(0.5,0.5))
                end
            end

        end
    end
end



function game_teamTask_selTaskPop:getBossTypeStr(boss_type)
    --绿 [color=ff00C000]&[/color]  白 [color=ffFFFFFF]&[/color]  淡蓝 [color=ff6DFFFF]&[/color]  黄 [color=ffFFFF00]&[/color]  红 [color=ffED0000]&[/color]
    local str = ""

    local temp = {}
    for k,v in pairs(boss_type) do
        table.insert(temp,{name = k, value = v})
    end
    for i=1,#temp do
        if #temp == 1 then
        else
            str = str..i.."."
        end
        if temp[i].name == "race" then 
            str = str .. RACE_SORT_TAB["type_" .. temp[i].value].name .."  "
        elseif temp[i].name == "sex" then 
            str = str .. (temp[i].value.."" == "0" and "Nhân vật nữ" or "Nhân vật nam") .."  "
        elseif temp[i].name == "bre" then 
            str = str ..  "Chuyển sinh cao hơn" .. temp[i].value.."  "
        elseif temp[i].name == "super_step" then 
            str = str .. "Siêu tiến hóa cao hơn" .. HERO_QUALITY_COLOR_TABLE_2[temp[i].value].name .."  "
        end
    end
    return str
end


-- function game_teamTask_selTaskPop:getBossTypeStr(boss_type)
--     --绿 [color=ff00C000]&[/color]  白 [color=ffFFFFFF]&[/color]  淡蓝 [color=ff6DFFFF]&[/color]  黄 [color=ffFFFF00]&[/color]  红 [color=ffED0000]&[/color]
--     local str = ""
--     if boss_type["race"] then -- 绿色
--         str = "[color=ff00C000]".. RACE_SORT_TAB["type_" .. boss_type["race"]].name .."[/color]"
--     end
--     if boss_type["sex"] then --淡蓝色
--         str = str .. (str=="" and "" or "[color=ffFFFFFF]&[/color]") .. "[color=ff6DFFFF]" .. (boss_type["sex"] == 0 and "女性角色" or "男性角色") .. "[/color]"
--     end
--     if boss_type["bre"] then --黄色
--         str = str .. (str=="" and "" or "[color=ffFFFFFF]&[/color]") .. "[color=ffFFFF00]转生高于" .. boss_type["bre"] .. "[/color]"
--     end
--     if boss_type["super_step"] then --红色
--         str = str .. (str=="" and "" or "[color=ffFFFFFF]&[/color]") .. "[color=ffED0000]超进化高于" .. HERO_QUALITY_COLOR_TABLE_2[boss_type["super_step"]].name .. "[/color]"
--     end
--     return str
-- end

function game_teamTask_selTaskPop:refreshBtn(flag)
    for i=1,3 do 
        local fileName = "ui_new_TeamBoss_team_difficulty" .. i .. (i == self.m_selectDiffcult and "1" or "2")
        local tempBtn = self.m_CCBNode:controlButtonForName("m_taskBtn" .. i)
        game_util:setCCControlButtonBackground(tempBtn,fileName .. ".png")
    end
    if flag then
        local function responseMethod(tag,gameData)
            if gameData ~= nil and tolua.type(gameData) == "util_json" then
                self.m_gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                self.m_boss_type = self.m_gameData.boss_type or self.m_boss_type 
                self:refreshTableView()
                local str = self:getBossTypeStr(self.m_boss_type)
                self.m_lb_bosscond:setString(str)
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_team_index"), http_request_method.GET, {boss_id = self.m_boss_id,boss_level = self.m_selectDiffcult},"team_fight_team_index")
    end
end

function game_teamTask_selTaskPop:refreshTableView()
    local all_teams = {}
    if self.m_fromtype then
        all_teams[#all_teams+1] = {}
        all_teams[#all_teams].key = self.m_fromteamid
        all_teams[#all_teams].teams = self.m_gameData.teams_all[self.m_fromteamid]
        -- self.m_selectTeamIndex = 1
        -- self.m_selectTeamId = nil
    else
        for k,v in pairs(self.m_gameData.teams_all) do
            all_teams[#all_teams+1] = {}
            all_teams[#all_teams].key = k
            all_teams[#all_teams].teams = v
        end
        -- self.m_selectTeamIndex = 1
        -- self.m_selectTeamId = nil
    end

    local tableView = self:createTableView(self.m_teamList_node:getContentSize(),all_teams)
    if tableView then
        self.m_teamList_node:removeAllChildrenWithCleanup(true)
        self.m_teamList_node:addChild(tableView)
    end
    if self.m_fromtype == nil then
        if #all_teams == 0 then
            self.m_node_tip:setVisible(true)
            -- self.m_btn_join:setColor(ccc3(100,100,100))
            -- self.m_btn_join:setEnabled(false)
        else
            self.m_node_tip:setVisible(false)
            -- self.m_btn_join:setColor(ccc3(255,255,255))
            -- self.m_btn_join:setEnabled(true)
        end
    else
        self.m_node_tip:setVisible(false)
    end
end


function game_teamTask_selTaskPop:refreshUi(  )
    self:refreshBtn()
    self:refreshTableView()
    self.m_bossNode:removeAllChildrenWithCleanup(true)
    local iconFile = self.m_selIcon:getNodeWithKey("icon"):toStr()
    local icon = game_util:createIconByName(iconFile,15)
    if icon then
        self.m_bossNode:addChild(icon)
    end
    self.m_btn_join   : setVisible(false)
    self.m_btn_create : setVisible(self.m_fromtype==nil)
    self.m_btn_refuse : setVisible(self.m_fromtype~=nil)
    self.m_btn_accept : setVisible(self.m_fromtype~=nil)
    self.m_btn_refresh:setVisible(self.m_fromtype==nil)
    -- self.m_label_refresh:setVisible(self.m_fromtype==nil)
    local str = self:getBossTypeStr(self.m_boss_type)
    self.m_lb_bosscond:setString(str)

end

function game_teamTask_selTaskPop:init( t_params )
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    else
        self.m_gameData = {}
    end
    self.m_boss_type = self.m_gameData.boss_type
    -- self.m_selectTeamIndex = 1
    -- self.m_selectTeamId = nil
    self.m_selectDiffcult = t_params.boss_level or 1
    self.m_boss_id = t_params.boss_id
    self.m_boss_langid = t_params.boss_langid
    self.m_selIcon = t_params.selIcon
    self.m_bossInfoCfg = getConfig(game_config_field.boss_info)

    self.m_fromtype = t_params.fromtype
    self.m_fromteamid = t_params.team_id
    self.msg_msg_id = t_params.msg_id

    self.character_detail_cfg = getConfig(game_config_field.character_detail);
    cclog2(self.m_fromtype,"    -------    ")
end

function game_teamTask_selTaskPop:create( t_params )
	self:init(t_params)
	local pop = self:createUi()
	self:refreshUi()
	return pop
end
return game_teamTask_selTaskPop