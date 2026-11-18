---  坠落之地
---  阶段首页
local game_godfield_guild_high_war_main = {
    m_tGameData = nil,
    m_step = nil,
    isOwnerOrVp = nil,
};



--[[--
    销毁
]]
function game_godfield_guild_high_war_main.destroy(self)
    cclog("-----------------game_godfield_guild_high_war_main destroy-----------------");
    self.m_tGameData = nil;
    self.m_step = nil;
end

--[[--
    返回
]]

function game_godfield_guild_high_war_main.back(self,type)
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_godfield_mainBig",{gameData = gameData})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")
end

--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_main.createUi(self)
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/godfield_main_res.plist");
    self.m_select_index = 1
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then --返回
            self:back();
        elseif btnTag == 101 then--规则
            local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
            local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(1))
            if itemCfg == nil then return end
            local openMsg = itemCfg:getNodeWithKey("des"):toStr();
            game_scene:addPop("game_godfield_detail_pop",{openMsg = openMsg})
        elseif btnTag == 102 then--战报
            local function responseMethod( tag,gameData )
                game_scene:addPop("game_godfield_guild_high_war_battle_report_pop",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_get_guild_record"), http_request_method.GET, {group_id = self.m_tGameData.group_id},"guild_high_war_get_guild_record")
        elseif btnTag == 103 then--排行
            local function responseMethod( tag,gameData )
                game_scene:addPop("game_godfield_guild_high_war_rank_pop",{gameData = gameData, select_index = 2, group_id = self.m_tGameData.group_id});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_get_rank"), http_request_method.GET, {group_id = self.m_tGameData.group_id , rank_type = 1},"guild_high_war_get_rank")
        elseif btnTag == 104 then--密令
            local function responseMethod( tag,gameData )
                game_scene:addPop("game_godfield_guild_high_war_miling_pop",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_war_index"), http_request_method.GET, nil,"guild_high_war_war_index")
        elseif btnTag == 202 then--阵型
            local uid = game_data:getUserStatusDataByKey("uid")
            local function responseMethod( tag, gameData )
                game_scene:addPop("game_godfield_guild_high_war_formation_pop",{gameData = gameData, is_formation = true, openType = "game_godfield_guild_high_war_main"})                  
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_alignment_info"), http_request_method.GET, {t_uid = uid},"guild_high_war_alignment_info")
        elseif btnTag == 300 then--进入遗迹

            local function responseMethod( tag,gameData )
                game_scene:enterGameUi("game_godfield_guild_high_war_map",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_map_index"), http_request_method.GET, {group_id = self.m_tGameData.group_id},"guild_high_war_map_index")
        elseif btnTag == 105 then -- 雇佣兵入口
            cclog('[雇佣兵] 点击雇佣兵入口')
            local isOwnerOrVp = self.m_tGameData.title == "owner" or self.m_tGameData.title == "vp"
            if isOwnerOrVp then -- 公会视角
                if self.m_step ~= 1 then
                    return game_util:addMoveTips({text = "Không phải giai đoạn Dự Cáo, không mở chức năng Lính Đánh Thuê"})
                end
                -- A.战场处于预告阶段，且距离预告阶段结束还有一小时
                local server_time = game_data:getUserStatusDataByKey("server_time")
                local time_left = self.m_tGameData.next_step_time - server_time+1
                if time_left <= 60 * 60 * 1 then
                    return game_util:addMoveTips({text = "Trước khi giai đoạn Dự Cáo kết thúc, trong vòng 1 tiếng không mở chức năng Lính Đánh Thuê"})
                end
                -- C.公会人数没有达到上限
                if self.m_tGameData.max_num == 0 then
                    return game_util:addMoveTips({text = "Số người trong Công Hội đã đầy, không thể mở chức năng Lính Đánh Thuê"})
                end
                -- B.该工会入选了任意一战场
                if not self.m_tGameData.group_id or self.m_tGameData.group_id == 0 then
                    return game_util:addMoveTips({text = "Công Hội của bạn chưa chọn Chiến Trường"})
                end

                local function responseMethod( tag,gameData )
                    game_scene:enterGameUi("game_godfield_guild_high_war_employ_guild_index",{gameData = gameData, ext = {
                        -- all_group = self.m_tGameData.all_group
                    }});
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_employ_guild_index"), http_request_method.GET, {},"guild_high_war_get_guild_record")
            else -- 佣兵视角
                if self.m_step ~= 1 then
                    return game_util:addMoveTips({text = "Không phải giai đoạn Dự Cáo, không mở chức năng Lính Đánh Thuê"})
                end
                -- B.战场处于预告阶段，且距离预告阶段结束还有一小时
                local server_time = game_data:getUserStatusDataByKey("server_time")
                local time_left = self.m_tGameData.next_step_time - server_time+1
                if time_left <= 60 * 60 * 1 then
                    return game_util:addMoveTips({text = "Trước khi giai đoạn Dự Cáo kết thúc, trong vòng 1 tiếng không mở chức năng Lính Đánh Thuê"})
                end
                -- B.该工会入选了任意一战场
                if not self.m_tGameData.ass_name or self.m_tGameData.ass_name == "" then
                    return game_util:addMoveTips({text = "Bạn chưa có Công Hội, không thể mở chức năng Lính Đánh Thuê"})
                end
                if self.m_tGameData.group_id_self and self.m_tGameData.group_id_self > 0 then
                    return game_util:addMoveTips({text = "Công Hội của bạn đã có Chiến Trường, không thể mở chức năng Lính Đánh Thuê"})
                end

                local function responseMethod( tag,gameData )
                    game_scene:enterGameUi("game_godfield_guild_high_war_employ_index",{gameData = gameData, ext = {
                        all_group = self.m_tGameData.all_group
                    }});
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_employ_index"), http_request_method.GET, {},"guild_high_war_get_guild_record")
            end
        else

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_main.ccbi");
    
    self.node_yj_list = ccbNode:nodeForName("node_yj_list") 
    self.label_str = ccbNode:labelTTFForName("label_str") 
    local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
    local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(16))
    self.label_str:setString(itemCfg:getNodeWithKey("des"):toStr())

    self.spr_jieduan = ccbNode:spriteForName("spr_jieduan") -- 阶段
    self.label_tips = ccbNode:labelTTFForName("label_tips") 
    self.label_tips:setString("Cách lúc bắt đầu chiến đấu")
    self.label_time = ccbNode:labelTTFForName("label_time") 
    self.countdown_label = ccbNode:nodeForName("countdown_label")
    self.label_yj_name = ccbNode:labelTTFForName("label_yj_name") --当前遗迹的名字
    self.label_guild_name = ccbNode:labelTTFForName("label_guild_name") --工会名字
    self.label_score = ccbNode:labelTTFForName("label_score") --总成绩
    self.label_back_score = ccbNode:labelTTFForName("label_back_score") --上一轮成绩
    self.label_value = ccbNode:labelTTFForName("label_value") --血腥值
    self.spr_end = ccbNode:spriteForName("spr_end") -- 最终战绩

    self.m_btn_zhanbao = ccbNode:controlButtonForName("m_btn_zhanbao")
    self.m_btn_rank = ccbNode:controlButtonForName("m_btn_rank")
    self.m_btn_miling = ccbNode:controlButtonForName("m_btn_miling")
    self.m_btn_zhenxing = ccbNode:controlButtonForName("m_btn_zhenxing")
    self.m_jr_btn = ccbNode:controlButtonForName("m_jr_btn")

    self.m_ccbNode = ccbNode;

    local show_data = {}
    for k,v in pairs(self.m_tGameData.all_group) do
        show_data[tonumber(k)] = v
    end
    self.node_yj_list:removeAllChildrenWithCleanup(true);
    self.m_yiji_tableView = self:createYiJiTableView(self.node_yj_list:getContentSize(), show_data);
    self.node_yj_list:addChild(self.m_yiji_tableView);
    self.m_yiji_tableView:setScrollBarVisible(false);

    self.countdown_label:removeAllChildrenWithCleanup(true)
    local server_time = game_data:getUserStatusDataByKey("server_time")
    local time_left = self.m_tGameData.next_step_time - server_time+1
    local function timeOverCallFun(label,type)
    end
    local timeLabel = game_util:createCountdownLabel(time_left,timeOverCallFun,8,1)
    timeLabel:setColor(ccc3(0,255,0))
    self.countdown_label:addChild(timeLabel,10,10)

    return ccbNode;

end

function game_godfield_guild_high_war_main.createYiJiTableView(self,viewSize, showData)
    local cardsCount = #showData
    local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = cardsCount --totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-10;
    params.itemActionFlag = true
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();

            local function onMainBtnClick( target,event )
                local tagNode = tolua.cast(target, "CCNode");
                local btnTag = tagNode:getTag();
                if btnTag >= 300 and btnTag < 400 then
                    local function responseMethod( tag,gameData )
                        game_scene:enterGameUi("game_godfield_guild_high_war_map",{gameData = gameData, group_id = btnTag-300})
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_map_index"), http_request_method.GET, {group_id = btnTag-300},"guild_high_war_map_index")
                elseif btnTag >= 400 and btnTag < 500 then -- 战场详情
                    local function responseMethod( tag,gameData )
                        game_scene:addPop("game_godfield_guild_high_war_rank_pop",{gameData = gameData, select_index = 2, group_id = btnTag-400});
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_get_rank"), http_request_method.GET, {group_id = btnTag-400 , rank_type = 1},"guild_high_war_get_rank")
                end
            end
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_yiji_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local label_name = ccbNode:labelTTFForName("label_name")
            local label_tips = ccbNode:labelTTFForName("label_tips")
            local label_des = ccbNode:labelTTFForName("label_des")
            local node_icon = ccbNode:nodeForName("node_icon")
            local node_guild_list = ccbNode:nodeForName("node_guild_list")
            local m_btn1 = ccbNode:controlButtonForName("m_btn1")
            m_btn1:setTag(300+index+1)
            local m_btn2 = ccbNode:controlButtonForName("m_btn2")
            m_btn2:setTag(400+index+1)
            node_icon:removeAllChildrenWithCleanup(true)
            local icon = CCSprite:create("ccbResources/godfield_build/godfield_build_6.png")
            icon:setScale(0.6)
            node_icon:addChild(icon)
            label_tips:setString("")
            label_name:setString(tostring(index+1).."Số Chiến Trường")
            if self.m_step == 1 then -- 预告阶段
                m_btn1:setColor(ccc3(150,150,150))
                m_btn1:setEnabled(false)
            end
            
            local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(15))
            local openMsg = itemCfg:getNodeWithKey("des"):toStr();
            label_des:setString(openMsg)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then

        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        -- self.m_selListItem = nil;
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end

function game_godfield_guild_high_war_main:onEnter(  )
    
    --self:refreshUI()
end

--[[--
    刷新ui
]]

--[[
setp
预告阶段
准备阶段
赛事宣战阶段
布阵阶段
战斗阶段
丰收日
丰收日-探索阶段
结算阶段
结算阶段
等待战斗结算阶段
等待战斗阶段
]]


function game_godfield_guild_high_war_main.refreshUi(self)

    local function setBtnColorEnabled(btn)
        btn:setColor(ccc3(150,150,150))
        btn:setEnabled(false)
    end

  
    self.label_time:setVisible(false)
    self.spr_end:setVisible(false)
    if self.m_step == 1 then -- 预告阶段
        setBtnColorEnabled(self.m_btn_zhanbao)
        setBtnColorEnabled(self.m_btn_rank)
        setBtnColorEnabled(self.m_btn_miling)
        setBtnColorEnabled(self.m_jr_btn)
        setBtnColorEnabled(self.m_btn_zhenxing)
    elseif self.m_step == 2 then -- 准备阶段
        setBtnColorEnabled(self.m_btn_zhanbao)
        setBtnColorEnabled(self.m_btn_rank)
        setBtnColorEnabled(self.m_btn_zhenxing)
    elseif self.m_step == 3 then -- 宣战阶段
        setBtnColorEnabled(self.m_btn_zhenxing)
    elseif self.m_step == 4 then -- 布阵阶段
    elseif self.m_step == 9 then -- 战斗阶段
        setBtnColorEnabled(self.m_btn_zhenxing)
    elseif self.m_step == 8 or self.m_step == 10 then -- 战斗结算期/战前阶段
        setBtnColorEnabled(self.m_btn_zhenxing)
    elseif self.m_step == 5 then -- 丰收日阶段
    elseif self.m_step == 11 then -- 丰收夜
    elseif self.m_step == 6 then -- 丰收日-探索阶段
        setBtnColorEnabled(self.m_btn_zhenxing)
    elseif self.m_step == 7 then -- 结算阶段
        setBtnColorEnabled(self.m_btn_zhenxing)
        self.spr_end:setVisible(true)
    end

    if self.m_tGameData.group_id and self.m_tGameData.group_id ~= 0 then
        self.label_yj_name:setString(self.m_tGameData.group_id.."Số Chiến Trường")
        self.label_guild_name:setString("Tên Công Hội:"..self.m_tGameData.ass_name)
        self.label_score:setString("Tổng thành tích:"..self.m_tGameData.self_guild_score)
        self.label_value:setString("Điểm Huyết Tinh:"..self.m_tGameData.self_score)
    else -- 观众
        self.label_yj_name:setString("Chưa tham chiến")
        self.label_guild_name:setString("")
        self.label_score:setString("")
        self.label_value:setString("")
        self.m_btn_zhenxing:setVisible(false)
        self.m_btn_miling:setVisible(false)
        self.m_btn_rank:setVisible(false)
        self.m_btn_zhanbao:setVisible(false)
        self.m_jr_btn:setVisible(false)
    end

    game_util:setSpriteDisplayBySpriteFrameName(self.spr_jieduan, "ghw_open"..self.m_step..".png")

    local guild_high_war_open = getConfig(game_config_field.guild_high_war_open)
    guild_high_war_open = json.decode(guild_high_war_open:getFormatBuffer()) or {};
    local open_des = ""
    for k,v in pairs(guild_high_war_open) do
        if v.sort == self.m_step then
            open_des = v.open_des
        end
    end
    self.label_tips:setString("Cách giai đoạn sau")

    -- 雇佣兵按钮
    self.m_ccbNode:controlButtonForName("btn_employ"):setVisible(self.m_step == 1)
    -- nd_rightBtns 排序
    local nd_rightBtns = self.m_ccbNode:nodeForName('nd_rightBtns')
    local startY = 0
    local items = nd_rightBtns:getChildren();
    local itemCount = items:count();
    for i = 1,itemCount do
        local tempItem = tolua.cast(items:objectAtIndex(i - 1),"CCNode");
        if tempItem and tempItem:isVisible() then
            tempItem:setPosition(ccp(0, startY))
            startY = startY - 40
        end
    end
        
end




--[[--
    初始化
]]
function game_godfield_guild_high_war_main.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        self.m_step = self.m_tGameData.step
    else
        self.m_tGameData = {};
    end

end

     

--[[--
    创建入口
]]
function game_godfield_guild_high_war_main.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    return rootScene;
end
return game_godfield_guild_high_war_main;