--- 工会战_zwj

local game_server_guildbattle_toBattle = {
    m_tGameData = nil,
    m_close_btn = nil,

    m_battle_btn = nil,
    m_winTimes_lab = nil,
    m_score_label = nil,
    m_reward_list_node_1 = nil,
    m_reward_list_node_2 = nil,
    m_scroll_view_tips = nil,
    m_battle_btn_2 = nil,
    m_battle_btn_3 = nil,
    word_tips3 = nil,
    word_tips2 = nil,
    m_detail_open_flag = nil,
    status = nil,
    m_enemy_server_lab = nil,
    m_enemy_server_lab2 = nil,
    m_enemy_server_lab3 = nil,
    m_enemy_server_lab4 = nil,
    m_lab_noUse1 = nil,
    m_lab_noUse2 = nil,
    m_lab_noUse3 = nil,
    m_lab_noUse4 = nil,
    m_isenroll = nil,
    m_rank_btn = nil,
    m_zone_num=nil,
    m_sp_back=nil,
    m_sp_title=nil,
    m_flag=nil,
    m_isKong = nil,
    m_anim_node = nil,
    m_purple_node ={},
    m_yellow_node ={},
    m_blue_node ={},
    m_enemy_node ={},
    m_own_node = {},
    m_battle_enemy_node = nil,
    m_enemy_lb = nil,
};
--[[--
    销毁
]]
function game_server_guildbattle_toBattle.destroy(self)
    -- body
    cclog("-----------------game_server_guildbattle_toBattle destroy-----------------");
    self.m_tGameData = nil;
    self.m_close_btn = nil;
    self.m_flag=nil;
    self.m_battle_btn = nil;
    self.m_winTimes_lab = nil;
    self.m_score_label = nil;
    self.m_reward_list_node_1 = nil;
    self.m_reward_list_node_2 = nil;
    self.m_scroll_view_tips = nil;
    self.m_battle_btn_2 = nil;
    self.m_battle_btn_3 = nil;
    self.word_tips3 = nil;
    self.word_tips2 = nil;
    self.m_detail_open_flag = nil;
    self.status = nil;
    self.m_enemy_server_lab = nil;
    self.m_enemy_server_lab2 = nil;
    self.m_enemy_server_lab3 = nil;
    self.m_enemy_server_lab4 = nil;
    self.m_lab_noUse1 = nil;
    self.m_lab_noUse2 = nil;
    self.m_lab_noUse3 = nil;
    self.m_lab_noUse4 = nil;
    self.m_isenroll = nil;
    self.m_rank_btn = nil;
    self.m_buy_btn = nil;
    self.m_zone_num=nil;
    self.m_sp_back=nil;
    self.m_sp_title=nil;
    self.m_isKong = nil;
    self.m_anim_node = nil;
    self.m_purple_node = {};
    self.m_yellow_node = {};
    self.m_blue_node = {};
    self.m_enemy_node = {};
    self.m_own_node = {};
    self.m_battle_enemy_node = nil;
    self.m_enemy_lb = nil;
end


local title={"shengyuyizhi","wujinzhihai","nizhuanweilai","yingxiongjijie","heianzhimen","kongbututeng","ranshaoyuanzheng","fengbao","shenyuzhengfa"}

--[[--
    返回
]]
function game_server_guildbattle_toBattle.back(self,type)
    self:destroy();
    if self.from == "game_godfield_mainBig" then
        game_scene:enterGameUi("game_godfield_mainBig",{})
    else
        require("like_oo.oo_controlBase"):openView("guild");
    end
end
--[[--
    读取ccbi创建ui
]]
function game_server_guildbattle_toBattle.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 11 then
            if self.m_detail_open_flag == true then
                self.m_detail_msg_bg:setPreferredSize(CCSizeMake(270,105))
                self.m_scroll_view_tips:setViewSize(CCSizeMake(230,70))
            else
                self.m_detail_msg_bg:setPreferredSize(CCSizeMake(270,230))
                self.m_scroll_view_tips:setViewSize(CCSizeMake(230,200))
            end
            self.m_detail_open_flag = not self.m_detail_open_flag;
            self:refreshActivityDetail();
        elseif btnTag == 12 then  --开始挑战
            local function responseMethod(tag,gameData,contentLength,status,new_config_version)
                if  status=="30" then 
                        local t_params = 
                    {
                        title = "Nhắc nhở",
                        okBtnCallBack = function(target,event)
                            require("game_ui.game_pop_up_box").close();
                        end,   
                        okBtnText = "OK", 
                        text = "Đã kết thúc chiến đấu hôm nay!",     
                        onlyOneBtn = true,         
                    }
                    require("game_ui.game_pop_up_box").show(t_params);
                    return;
                end
                local data = gameData:getNodeWithKey("data")

                local step = data:getNodeWithKey("step"):toInt()
                local step_result = data:getNodeWithKey("step_result")
                if step == 100 and step_result then
                    game_util:addMoveTips({text = "Đã kết thúc chiến đấu hôm nay"})
                    return
                end
                if step == 101 then
                    game_util:addMoveTips({text = "Đã kết thúc chiến đấu hôm nay, còn lại sẽ thi đấu vào ngày thứ 2"})
                    return
                end
                --cclog2(data,"data is ????>>>>")
                local can_join = data:getNodeWithKey("can_join"):toBool()
                local enemyGuildName = data:getNodeWithKey("defend_guild"):toStr()
                if step == 1 then
                    game_util:addMoveTips({text = "Giai đoạn trước trận đấu, vui lòng đợi"})
                elseif can_join then
                    local data = gameData:getNodeWithKey("data")
                    local can_join = data:getNodeWithKey("can_join"):toBool()
                    if can_join and enemyGuildName == "" then
                        game_util:addMoveTips({text = "Guild của bạn bỏ lượt, vui lòng đợi trận kế tiếp"})
                    elseif step > 8 then
                        game_util:addMoveTips({text = "Thần Vực Tranh Bá vòng này đã kết thúc, vui lòng chờ kết quả"})
                    else
                        game_scene:enterGameUi("game_server_guildbattle_battle",{gameData = gameData, isManage = self.m_leader,openType = "index",bgMusic = "GuildBattle"})
                    end

                elseif step == 100 then
                    game_util:addMoveTips({text = "Đã kết thúc chiến đấu"})
                --     -- local function responseMethod(tag,gameData)
                --     --     game_scene:enterGameUi("game_server_guildbattle_main",{gameData = gameData})
                --     -- end
                --     -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_index"), http_request_method.GET, nil,"new_guild_fight_index")
                -- else
                --     game_scene:addPop("game_team_pk_result_pop",{is_win = 2,str = "很遗憾，您所在的公会未能进入下一轮"})
                elseif step == 101 then
                    game_util:addMoveTips({text = "Đã kết thúc chiến đấu"})
                else
                    game_util:addMoveTips({text = "Vòng này không có thi đấu"})
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_battlefield_overview"), http_request_method.GET, nil,"new_guild_fight_battlefield_overview")
        elseif btnTag ==13 then --报名
            local function responseMethod(tag,gameData)
                local data=gameData:getNodeWithKey("data")
                -- cclog2(data,"data in baoming >>>>>")
                game_util:setCCControlButtonTitle(self.m_btn_register,"Đã báo danh")
                game_util:addMoveTips({text="Báo danh thành công!"})
                self:refreshUi();
                self.m_btn_register:setVisible(false);
                self.m_btn_giveup:setVisible(true);
            end
            local params={}
            params.num_area=self.m_zone_num
             local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    game_util:closeAlertView()
                    
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_register"), http_request_method.GET, params,"new_guild_fight_register")
                    
                end,   
                closeCallBack = function(target,event)
                    game_util:closeAlertView();
                   
                end,

                okBtnText = "OK",   
                cancelBtnText = "Hủy",    
                text = "Báo danh tiêu hao 50 cờ, xác nhận đánh chiến khu này?",      
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-19,
            }
            game_util:openAlertView(t_params);


        elseif btnTag ==14 then --退出
            local function responseMethod(tag,gameData)
                game_util:addMoveTips({text="Đã thoát!"})
           
                local function delayFunc()
                    self:back()

                end
                performWithDelay(self.m_reward_list_node_1,delayFunc,1)

            end

             local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    game_util:closeAlertView()
                    
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_log_out"), http_request_method.GET, nil,"new_guild_fight_log_out")
                    
                end,   
                closeCallBack = function(target,event)
                    game_util:closeAlertView();
                   
                end,
                okBtnText = "OK",   
                cancelBtnText = "Hủy",    
                text = "Thoát chiến khu hiện tại chứ?",      
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-19,
            }
            game_util:openAlertView(t_params);

        elseif btnTag == 101 then --排行榜
            local function responseMethod(tag,gameData)
                local data=gameData:getNodeWithKey("data")
                game_scene:addPop("game_server_guildbattle_rank",{gameData=data})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_integral_index"), http_request_method.GET,nil,"new_guild_fight_integral_index")
        elseif btnTag == 102 then --分组情况

           
            if self.m_tGameData.active_step and self.m_tGameData.active_step == 3 then
                local function responseMethod( tag,gameData )
                    game_scene:addPop("game_serverGuild_daily_pop", {gameData = gameData,popCallBack = popCallBack,openType = "playoffs"})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_battle_list"), http_request_method.GET, params,"new_guild_fight_battle_list")
                
            else
                local function responseMethod(tag,gameData)
                    game_scene:addPop("game_serverGuild_daily_pop",{gameData=gameData})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_battle_list"), http_request_method.GET,params,"new_guild_fight_battle_list")

            end


            
        elseif btnTag == 201 then --去雇佣
            -- self.m_isKong = true
            if self.m_isKong or self.m_tGameData.is_employed == 1 then
                local function responseMethod( tag,gameData )
                    game_scene:addPop("game_serverGuild_employoJoin_pop",{gameData = gameData})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_employ_pub_ed"), http_request_method.GET, {tp = 1},"new_guild_fight_employ_pub_ed")
            else
                local function responseMethod(tag,gameData)
                    game_scene:addPop("game_serverGuild_employo_pop",{gameData = gameData, isManage = self.m_leader})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_pub_employ_message_index"), http_request_method.GET,params,"new_guild_fight_pub_employ_message_index")
            end 
        elseif btnTag == 202 then
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_serverGuild_task_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_week_reward_index"), http_request_method.GET,params,"new_guild_fight_week_reward_index")
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_battle_main.ccbi");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_battle_btn = ccbNode:controlButtonForName("m_battle_btn");
    
    self.m_scroll_view_tips = ccbNode:scrollViewForName("m_scroll_view_tips");
    self.m_winTimes_lab = ccbNode:labelTTFForName("m_winTimes_lab");
    self.m_score_label = ccbNode:labelTTFForName("m_score_label");
    self.m_score_label2=ccbNode:labelTTFForName("m_score_label2")
    self.m_score_label3=ccbNode:labelTTFForName("m_score_label3")
    self.m_reward_list_node_1 = ccbNode:nodeForName("m_reward_list_node_1");
    -- self.m_reward_list_node_2 = ccbNode:nodeForName("m_reward_list_node_2");
    self.word_tips3 = ccbNode:spriteForName("word_tips3")
    self.word_tips2 = ccbNode:spriteForName("word_tips2")
    self.m_scroll_view_tips:setTouchPriority(GLOBAL_TOUCH_PRIORITY + 1);
    self.m_detail_msg_bg = ccbNode:scale9SpriteForName("m_detail_msg_bg")
    self.m_enemy_server_lab = ccbNode:labelTTFForName("m_enemy_server_lab")
    self.m_enemy_server_lab2=ccbNode:labelTTFForName("m_enemy_server_lab2");
    self.m_enemy_server_lab3=ccbNode:labelTTFForName("m_enemy_server_lab3");
    self.m_enemy_server_lab4=ccbNode:labelTTFForName("m_enemy_server_lab4");
    self.m_battle_enemy_node = ccbNode:nodeForName("m_battle_enemy_node")
    self.m_enemy_lb = ccbNode:labelTTFForName("m_enemy_lb")
    -- self.m_lab_noUse1 = ccbNode:labelTTFForName("m_lab_noUse1")
    -- self.m_lab_noUse2 = ccbNode:labelTTFForName("m_lab_noUse2")
    -- self.m_lab_noUse3 = ccbNode:labelTTFForName("m_lab_noUse3")
    -- self.m_lab_noUse4 = ccbNode:labelTTFForName("m_lab_noUse4")
    self.m_rank_btn = ccbNode:controlButtonForName("m_rank_btn")
    self.m_lab_leader_guild=ccbNode:labelTTFForName("lab_guild");
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self:createAnim()
    for i=1,5 do
        self.m_purple_node[i] = ccbNode:nodeForName("m_purple_node"..i)
        self:createAnimByFileName(self.m_purple_node[i],"serverGuild_purple")
    end
    for i=1,5 do
        self.m_yellow_node[i] = ccbNode:nodeForName("m_yellow_node"..i)
        self:createAnimByFileName(self.m_yellow_node[i],"serverGuild_gold")
    end 
    for i=1,5 do
        self.m_blue_node[i] = ccbNode:nodeForName("m_blue_node"..i)
        self:createAnimByFileName(self.m_blue_node[i],"serverGuild_blue")
    end
    for i=1,5 do
        self.m_enemy_node[i] = ccbNode:nodeForName("m_enemy_node_"..i)
        self:createAnimByFileName(self.m_enemy_node[i],"serverGuild_ownPoint")
    end
    for i=1,5 do
        self.m_own_node[i] = ccbNode:nodeForName("m_own_node"..i)
        self:createAnimByFileName(self.m_own_node[i],"serverGuild_enemyPoint")
    end
    -- self.m_anim_node:addChild(anim)
    -- local anim = game_util:createIdelAnim("serverGuild_bg.swf.sam")
            -- if anim then
                -- anim:setAnchorPoint(ccp(0.5,0))
                -- anim:setScale(0.9)
                -- local function onAnimSectionEnd( animNode, theId,theLabelName )
                --      -- animNode:playSection(theLabelName);
                -- end

    self.m_lab_leader_guild_score=ccbNode:labelTTFForName("lab_guild_score");

    self.m_btn_register=ccbNode:controlButtonForName("btn_register");
    self.m_btn_giveup=ccbNode:controlButtonForName("btn_giveup");

    self.m_leader=game_data:getServerGuildIsManage() or false;

    local btn_enemy = ccbNode:controlButtonForName("btn_enemy")
    if self.m_tGameData.active_step and self.m_tGameData.active_step == 3 then
        btn_enemy:setVisible(false)
    end
    self.m_btn_giveup:setVisible(false)
    self.m_btn_register:setVisible(false)

     --设置title和背景图片
    self.m_sp_back=ccbNode:spriteForName("sp_back");
    self.m_sp_title=ccbNode:spriteForName("sp_title");
    local num=self.m_zone_num 
    local title_name="serverGuild_title.png"
    local back_name="serverGuild_"..title[num]..".png"
    self.m_sp_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(title_name))
    -- self.m_sp_back:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(back_name))
    self.m_sp_back:setScale(2);
    local animName = "enter_anim"
    local function animCallFunc(animName)
        ccbNode:runAnimations(animName)
    end
    ccbNode:registerAnimFunc(animCallFunc);
    ccbNode:runAnimations(animName)

    return ccbNode;
end
function game_server_guildbattle_toBattle.createAnim(self)
     local anim_eff1 = game_util:createEffectAnim("serverGuild_bg",1,true);
    anim_eff1:setAnchorPoint(ccp(0.5,0))
    anim_eff1:setPositionY(-160)
    -- anim_eff:registerScriptTapHandler(onAnimSectionEnd)
    anim_eff1:playSection("impact");
    self.m_anim_node:addChild(anim_eff1,1,1)
    -- self.m_anim_node:addChild(anim,2,2)
-- end

     local anim_eff2 = game_util:createEffectAnim("serverGuild_ownHome",1,true);
    anim_eff2:setAnchorPoint(ccp(0.5,0))
    anim_eff2:setPositionY(-180)
    anim_eff2:setPositionX(200)
    -- anim_eff:registerScriptTapHandler(onAnimSectionEnd)
    anim_eff2:playSection("impact");
    self.m_anim_node:addChild(anim_eff2,1,1)
     local anim_eff3 = game_util:createEffectAnim("serverGuild_enemyHome",1,true);
    anim_eff3:setAnchorPoint(ccp(0.5,0))
    anim_eff3:setPositionY(-10)
    anim_eff3:setPositionX(-200)
    -- anim_eff:registerScriptTapHandler(onAnimSectionEnd)
    anim_eff3:playSection("impact");
    self.m_anim_node:addChild(anim_eff3,1,1)
end


function game_server_guildbattle_toBattle:createAnimByFileName(node,filename)
    local anim_eff = game_util:createBlenderAnim(filename,1,true)
    local anim_eff1 = game_util:createBlenderAnim(filename,1,true)
    anim_eff:setAnchorPoint(ccp(0.5,0.5))
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        animNode:playSection(theLabelName)
    end
    anim_eff:registerScriptTapHandler(onAnimSectionEnd)
    anim_eff1:registerScriptTapHandler(onAnimSectionEnd)
    if filename == "serverGuild_ownPoint" then
        anim_eff:playSection("impact");
        anim_eff1:playSection("impact@1");
    else
        anim_eff:playSection("impact");
        anim_eff1:playSection("impact@1");
    end
    node:addChild(anim_eff1,1,1)
    node:addChild(anim_eff,2,2)
end

--[[--
    本期胜利奖励》》》》创建列表
]]
function game_server_guildbattle_toBattle.createRewardTableView(self,viewSize)
    -- local team_pk_rewardcfg = self.m_tGameData.guild_info
    -- if team_pk_rewardcfg then 
    --     team_pk_rewardcfg=team_pk_rewardcfg.reward or {}
    -- end
    local showData = self.m_tGameData.reward or {}
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 3; --列
    params.totalItem = #showData
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    if #showData == 0 then--显示一个提示
        self.word_tips2:setVisible(true)
    else
        self.word_tips2:setVisible(false)
    end
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local icon,name,count = game_util:getRewardByItemTable(showData[index+1],false)
            if icon then
                icon:setScale(0.65);
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
                cell:addChild(icon)
            end
            if count then
                local tempLabel = game_util:createLabelBMFont({text = "×" .. count,color = ccc3(255,255,255),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.2))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(showData[index+1])
        end
    end
    return TableViewHelper:create(params);
end

-- --[[--
--     创建奖励列表
-- ]]
-- function game_server_guildbattle_toBattle.createRankRewardTableView(self,viewSize)
--     local rewardCfg = getConfig(game_config_field.maze_top_reward)
--     local myRank = self.m_tGameData.max_rank
--     local showData = {}
--     if myRank == 0 or myRank > 100 then
--         self.word_tips3:setVisible(true)
--     else
--         self.word_tips3:setVisible(false)
--         local itemCfg = rewardCfg:getNodeWithKey(tostring(myRank))
--         showData = json.decode(itemCfg:getNodeWithKey("reward"):getFormatBuffer())
--     end
--     local params = {};
--     params.viewSize = viewSize;
--     params.row = 1;--行
--     params.column = 3; --列
--     params.totalItem = #showData;
--     params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
--     params.direction = kCCScrollViewDirectionHorizontal;
--     local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
--     params.newCell = function(tableView,index) 
--         local cell = tableView:dequeueCell()
--         if cell == nil then
--             cell = CCTableViewCell:new()
--             cell:autorelease()
--         end
--         if cell then
--             cell:removeAllChildrenWithCleanup(true);
--             local icon,name,count = game_util:getRewardByItemTable(showData[index+1],false)
--             if icon then
--                 icon:setScale(0.65);
--                 icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
--                 cell:addChild(icon)
--             end
--             if count then
--                 local tempLabel = game_util:createLabelBMFont({text = "×" .. count,color = ccc3(255,255,255),fontSize = 8});
--                 tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.2))
--                 cell:addChild(tempLabel)
--             end
--         end
--         return cell;
--     end
--     params.itemOnClick = function(eventType,index,item)
--         if eventType == "ended" and item then
--             -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
--             game_util:lookItemDetal(showData[index+1])
--         end
--     end
--     return TableViewHelper:create(params);
-- end

--[[--
    刷新
]]
function game_server_guildbattle_toBattle.refreshActivityDetail(self)
    self.m_scroll_view_tips:getContainer():removeAllChildrenWithCleanup(true)
    local activeCfg = getConfig(game_config_field.notice_active)
    local itemCfg = activeCfg:getNodeWithKey( "181" )
    local contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or "Hoạt động đặc sắc, mau tham gia nào!"
    local viewSize = self.m_scroll_view_tips:getViewSize();
    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(viewSize.width,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(121,236,236),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    self.m_scroll_view_tips:setContentSize(CCSizeMake(viewSize.width,tempSize.height))
    self.m_scroll_view_tips:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.m_scroll_view_tips:addChild(tempLabel)
end


--[[--
    刷新ui
]]
function game_server_guildbattle_toBattle.refreshUi(self)
    self:refreshActivityDetail();
    self.m_reward_list_node_1:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createRewardTableView(self.m_reward_list_node_1:getContentSize());
    self.m_reward_list_node_1:addChild(tableViewTemp);


    local win_times = self.m_tGameData.win_times or 0 
    self.m_winTimes_lab:setString(tostring(win_times)); --胜利场次

    local rank =self.m_tGameData.rank or "Tạm trống"
    self.m_score_label3:setString(rank);
    self.m_score_label:setString(self.m_tGameData.integral or 0)--工会积分
    self.m_score_label2:setString(self.m_tGameData.keep_win or 0) --工会连胜

    if self.m_tGameData.owner_area then 
    
        self.m_lab_leader_guild:setString(self.m_tGameData.owner_area.first_guild or "Tạm trống") --占领工会
        self.m_lab_leader_guild_score:setString((self.m_tGameData.owner_area.guild_score or 0).."Score") --占领工会积分
    end
    -- if self.m_tGameData.active_step and self.m_tGameData.active_step == 3 then
    --     if self.m_tGameData.battle_round then
    --         -- self.m_lab_noUse1:setVisible(false)
    --         -- self.m_lab_noUse2:setVisible(false)
    --         -- self.m_lab_noUse3:setVisible(false)
    --         -- self.m_lab_noUse4:setVisible(false)
    --         self.m_battle_enemy_node:setVisible(false)
    --         self.m_enemy_lb:setVisible(true)
    --         if self.m_tGameData.battle_round.name and self.m_tGameData.battle_round.name ~= "" then
    --             self.m_enemy_lb:setString("本场对战:" .. (self.m_tGameData.battle_round.name or "暂无"))
    --         else
    --             self.m_enemy_lb:setString("!本场没有战斗!")
    --         end
    --         -- self.m_enemy_server_lab2:setVisible(false)
    --         -- self.m_enemy_server_lab3:setVisible(false)
    --         -- self.m_enemy_server_lab4:setVisible(false)
    --         -- self.m_enemy_server_lab:setPosition(ccp(80,55))

    --         -- self.m_enemy_server_lab:setString(self.m_tGameData.battle_round.name or "暂无") --对阵工会
    --     end
    -- else
        if self.m_tGameData.battle_round then
            local nameTab = {"Tạm trống","Tạm trống","Tạm trống","Tạm trống"}
            for i=1,3 do
                if self.m_tGameData.battle_round[tostring(i)] then
                    nameTab[i] = self.m_tGameData.battle_round[tostring(i)].name
                end
            end
            self.m_battle_enemy_node:setVisible(true)
            self.m_enemy_lb:setVisible(false)
            self.m_enemy_server_lab:setString(nameTab[1] or "Tạm trống") --对阵工会
            self.m_enemy_server_lab2:setString(nameTab[2] or "Tạm trống") --对阵工会
            self.m_enemy_server_lab3:setString(nameTab[3] or "Tạm trống") --对阵工会
            -- self.m_enemy_server_lab4:setString(nameTab[4] or "暂无") --对阵工会
        end
    -- end

    if self.m_flag then --报名标记
        game_util:setCCControlButtonTitle(self.m_btn_register,"Đã báo danh")
    else
        self.m_btn_giveup:setVisible(false)
    end

end

--[[--
    初始化
]]
function game_server_guildbattle_toBattle.init(self,t_params)
   CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_serverGuild.plist");
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end

    self.from = t_params.from or "guild"
    
    -- cclog2(self.m_tGameData,"gameData ==== ")
    self.m_detail_open_flag = false;
    self.m_zone_num=tonumber(t_params.num) or 1;
    self.m_flag=t_params.flag or false;
    self.m_isKong = false
    if self.m_tGameData.active_step and self.m_tGameData.active_step == 3 then
       if  self.m_tGameData.battle_round and next(self.m_tGameData.battle_round) then
           self.m_isKong = false
       else
           self.m_isKong = true
       end
    else
        for i=1,4 do
            if  self.m_tGameData.battle_round[tostring(i)] and next(self.m_tGameData.battle_round[tostring(i)]) then
                self.m_isKong = false
                return
            end
            self.m_isKong = true
        end

    end

end

--[[--
    创建ui入口并初始化数据
]]
function game_server_guildbattle_toBattle.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_server_guildbattle_toBattle;