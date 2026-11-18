---  坠落之地
---  地图
local game_godfield_guild_high_war_map = {
    m_tGameData = nil,
    root_map_node = nil,
    m_scroll_view = nil,
    m_back_btn = nil,
    m_btn_zhenxing = nil,
    m_btn_duihuan = nil,
    bg_layer = nil,
    maxOffsetX = nil,
    building_table = nil,
    select_building = nil,
    --building_tab = nil,
    m_label_timedown = nil,
    -- m_label_score = nil,
    conutdownTime = nil,
    buildingTag_tab = nil,
    touch_buildingTag = nil,
    m_playerAnimNode = nil,
    -- playerLayer = nil,
    win_sort = nil,
    is_enter = nil,
    random_num = nil,
    tobattle = nil,
    m_weekDay = nil,
    -- m_shuaxinshijian_lab = nil,
};

local building_offset = require("building_offset");

--[[--
    销毁
]]
function game_godfield_guild_high_war_map.destroy(self)
    cclog("-----------------game_godfield_guild_high_war_map destroy-----------------");
    self.root_map_node = nil;
    self.m_tGameData = nil;
    self.m_scroll_view = nil;
    self.m_back_btn = nil;
    self.m_btn_zhenxing = nil;
    self.m_btn_duihuan = nil;
    self.bg_layer = nil;
    self.maxOffsetX = nil;
    self.building_table = nil;
    self.select_building = nil;
    --self.building_tab = nil;
    self.m_label_timedown = nil;
    -- self.m_label_score = nil;
    self.conutdownTime = nil;
    self.buildingTag_tab = nil;
    self.touch_buildingTag = nil;
    self.m_playerAnimNode = nil;
    -- self.playerLayer = nil;
    self.win_sort = nil;
    self.is_enter = nil;
    self.random_num = nil;
    self.tobattle = nil;
    self.m_weekDay = nil;
    -- self.m_shuaxinshijian_lab = nil;

end
local building_tab = {  
    {buildingID = "4001", offset = {1030.4,118.0}},
    {buildingID = "4002", offset = {1404.0,119.4}},
    {buildingID = "4003", offset = {1835.9,176.3}},
    {buildingID = "4004", offset = {2419.3,404.1}},
    {buildingID = "4005", offset = {2565.1,758.3}},
    {buildingID = "4006", offset = {2542.9,1070.4}},
    {buildingID = "4007", offset = {2460.9,1373.2}},
    {buildingID = "4008", offset = {1929.0,1632.9}},
    {buildingID = "4009", offset = {1434.6,1653.7}},
    {buildingID = "4010", offset = {927.6,1645.4}},
    {buildingID = "4011", offset = {592.9,1562.1}},
    {buildingID = "4012", offset = {213.7,1299.6}},
    {buildingID = "4013", offset = {138.7,1034.3}},
    {buildingID = "4014", offset = {155.4,782.9}},
    {buildingID = "4015", offset = {251.2,513.4}},
    {buildingID = "4016", offset = {614,180}},

    {buildingID = "3001", offset = {910.9,331.9}},
    {buildingID = "3002", offset = {1481.8,379.1}},
    {buildingID = "3003", offset = {1935.6,459.4}},
    {buildingID = "3004", offset = {2215.1,712.4}},
    {buildingID = "3005", offset = {2187.3,1093.0}},
    {buildingID = "3006", offset = {1952.6,1329.1}},
    {buildingID = "3007", offset = {1550.7,1500.6}},
    {buildingID = "3008", offset = {1054.0,1454.1}},
    {buildingID = "3009", offset = {624.3,1350.8}},
    {buildingID = "3010", offset = {431.8,1116.6}},
    {buildingID = "3011", offset = {435.9,673.6}},
    {buildingID = "3012", offset = {605.9,533.3}},    
    {buildingID = "3013", offset = {553.7,381.9}},
    {buildingID = "3014", offset = {2100.0,380.4}},
    {buildingID = "3015", offset = {2099.8,1462.4}},
    {buildingID = "3016", offset = {424.3,1250.8}},

    {buildingID = "2001", offset = {1238.7,516.6}},
    {buildingID = "2002", offset = {1720.7,659.7}},
    {buildingID = "2003", offset = {1933.2,891.6}},
    {buildingID = "2004", offset = {1654.0,1260.6}},
    {buildingID = "2005", offset = {1300.2,1400.5}},
    {buildingID = "2006", offset = {822.6,1238.8}},
    {buildingID = "2007", offset = {612.9,909.7}},
    {buildingID = "2008", offset = {805.1,686.6}},

    {buildingID = "1001", offset = {1226.8,730.1}},
    {buildingID = "1002", offset = {1483.7,773.6}},
    {buildingID = "1003", offset = {1604.6,935.7}},
    {buildingID = "1004", offset = {1553.2,1120.4}},
    {buildingID = "1005", offset = {1249.2,1186.3}},
    {buildingID = "1006", offset = {1000.4,1220.3}},
    {buildingID = "1007", offset = {932.5,961.3}},
    {buildingID = "1008", offset = {1000.1,798.8}},

    {buildingID = "100", offset = {1278.3,980.7}},
 }
--[[--
    返回
]]
function game_godfield_guild_high_war_map.back(self,type)
    local server_time = game_data:getUserStatusDataByKey("server_time")
    local time_left = 0
    if self.m_tGameData and self.m_tGameData.next_step_time then
        time_left = self.m_tGameData.next_step_time - server_time
    end
    if server_time >= self.m_tGameData.end_time then -- 活动已结束
        local t_params = 
            {
            okBtnCallBack = function(target,event)
                game_util:closeAlertView();
                game_scene:enterGameUi("game_godfield_mainBig",{})            
            end,   --可缺省
            okBtnText = "Xác định",       --可缺省
            text = "HĐ đã kết thúc, có quay về Chiến Trường Thần Vực không",      --可缺省
        }
        game_util:openAlertView(t_params);
    else
        function responseMethod( tag,gameData )
            local data = gameData:getNodeWithKey("data");
            data = json.decode(data:getFormatBuffer()) or {};
            game_scene:enterGameUi("game_godfield_guild_high_war_main",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_index"), http_request_method.GET, {},"guild_high_war_index")
    end
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_map.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_wormhole_map.plist");

    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then --返回
            self:back();
        elseif btnTag == 101 then--规则
            local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
            local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(2))
            if itemCfg == nil then return end
            local openMsg = itemCfg:getNodeWithKey("des"):toStr();
            game_scene:addPop("game_godfield_detail_pop",{openMsg = openMsg})
            -- game_scene:addPop("game_godfield_guild_high_war_battle_detail_pop",{gameData = gameData,sort = sort,enemyRank = enemyRank})
        elseif btnTag == 102 then--战报
            -- game_scene:addPop("game_godfield_guild_high_war_player_pop",{gameData = gameData,sort = sort,enemyRank = enemyRank})        
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
        elseif btnTag == 105 then--前线
            if self.m_step == 2 or self.m_step == 3 then -- 准备阶段/宣战阶段
                return game_util:addMoveTips({text = "Chưa đến GĐ Dàn Trận"})
            end

            local function responseMethod( tag,gameData )
                game_scene:addPop("game_godfield_guild_high_war_front_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_map_index"), http_request_method.GET, {group_id = self.m_group_id or self.m_tGameData.group_id},"guild_high_war_map_index")
        elseif btnTag == 201 then--背包
            local offset = self.m_scroll_view:getContentOffset()
            game_scene:enterGameUi("game_godfield_guild_high_war_items_scene",{map_offset = offset, group_id = self.m_group_id or self.m_tGameData.group_id})
        elseif btnTag == 202 then--阵型
            local offset = self.m_scroll_view:getContentOffset()
            local uid = game_data:getUserStatusDataByKey("uid")
            local function responseMethod( tag, gameData )
                game_scene:addPop("game_godfield_guild_high_war_formation_pop",{gameData = gameData, is_formation = true, next_step_time = self.m_tGameData.next_step_time, openType = "game_godfield_guild_high_war_map", group_id = self.m_tGameData.group_id, map_offset = offset})                  
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_alignment_info"), http_request_method.GET, {t_uid = uid},"guild_high_war_alignment_info")
        elseif btnTag == 203 then--奖励
            local function responseMethod( tag, gameData )
                game_scene:addPop("game_godfield_guild_high_war_reward_pop",{gameData = gameData})                  
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_box_index"), http_request_method.GET, nil,"guild_high_war_box_index")


        elseif btnTag == 204 then--科技
            local offset = self.m_scroll_view:getContentOffset()
            local function responseMethod( tag, gameData )
                game_scene:enterGameUi("game_godfield_guild_high_war_keji",{gameData = gameData, map_offset = offset, group_id = self.m_group_id or self.m_tGameData.group_id})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_science_index"), http_request_method.GET, nil,"guild_high_war_science_index")

        else

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_map.ccbi");
   

    local root_map_node = tolua.cast(ccbNode:objectForName("root_map_node"), "CCNode");
    self.bg_layer = ccbNode:layerForName("bg_layer")
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_btn_zhenxing = ccbNode:controlButtonForName("m_btn_zhenxing")
    self.m_btn_duihuan = ccbNode:controlButtonForName("m_btn_duihuan")

    self.m_scroll_rect = self.bg_layer:boundingBox()


    self.label_target_name = ccbNode:labelTTFForName("label_target_name") -- 阶段
    self.conutdownTime = ccbNode:nodeForName("conutdownTime") -- 倒计时
    self.label_time_end_str = ccbNode:labelTTFForName("label_time_end_str") -- 后结束
    self.label_time_end_str:setString("Kết thúc")
    self.node_my_guild_info = ccbNode:nodeForName("node_my_guild_info")
    self.node_player_role = ccbNode:nodeForName("node_player_role") -- 玩家形象
    self.node_guild_icon = ccbNode:nodeForName("node_guild_icon") -- 公会icon
    self.label_guild_name = ccbNode:labelTTFForName("label_guild_name") -- 公会名字
    self.label_guild_text = ccbNode:labelTTFForName("label_guild_text") -- 公会描述
    self.label_guild_text:setString("Nhớ nhận Rương Báu mỗi ngày và Chiến Lệnh miễn phí")
    self.label_guild_combat = ccbNode:labelTTFForName("label_guild_combat") -- 联盟战力
    self.m_btn_zhanbao = ccbNode:controlButtonForName("m_btn_zhanbao")
    self.m_btn_rank = ccbNode:controlButtonForName("m_btn_rank")
    self.m_btn_miling = ccbNode:controlButtonForName("m_btn_miling")
    self.m_btn_zhenxing = ccbNode:controlButtonForName("m_btn_zhenxing")
    self.m_btn_qianxian = ccbNode:controlButtonForName("m_btn_qianxian")
    self.m_btn_bag = ccbNode:controlButtonForName("m_btn_bag")
    self.m_btn_zhenxing = ccbNode:controlButtonForName("m_btn_zhenxing")
    self.m_btn_reward = ccbNode:controlButtonForName("m_btn_reward")
    self.m_btn_keji = ccbNode:controlButtonForName("m_btn_keji")
    self.label_wr_tips = ccbNode:labelTTFForName("label_wr_tips") -- 以太污染抵抗
    self.label_xz_times = ccbNode:labelTTFForName("label_xz_times") -- 剩余宣战次数
    self.m_ccbNode = ccbNode;
    self:onEnter();

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/guild_high_war.plist");


    -- 玩家形象
    self.node_player_role:removeAllChildrenWithCleanup(true);
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    local userStatusData = game_data:getUserStatusData();
    local role = userStatusData.role;
    if role and role_detail_cfg then
        local itemCfg = role_detail_cfg:getNodeWithKey(tostring(role));
        local temp_big_img = CCSprite:create("humen/" .. itemCfg:getNodeWithKey("img"):toStr() .. ".png");
        temp_big_img:setAnchorPoint(ccp(0.5, 0.5));
        temp_big_img:setScale(0.5);
        if temp_big_img then
            self.node_player_role:addChild(temp_big_img)
        end
    end


    local guild_high_war_open = getConfig(game_config_field.guild_high_war_open)
    guild_high_war_open = json.decode(guild_high_war_open:getFormatBuffer()) or {};
    local open_des = ""
    for k,v in pairs(guild_high_war_open) do
        if v.sort == self.m_step then
            open_des = v.open_des
        end
    end
    self.label_target_name:setString(open_des)

    self.conutdownTime:removeAllChildrenWithCleanup(true)
    local server_time = game_data:getUserStatusDataByKey("server_time")
    local time_left = self.m_tGameData.next_step_time - server_time + 1
    local function timeOverCallFun(label,type)
        local function responseMethod( tag,gameData )
            game_scene:enterGameUi("game_godfield_guild_high_war_map",{gameData = gameData, group_id = self.m_group_id, map_offset = self.m_scroll_view:getContentOffset()})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_map_index"), http_request_method.GET, {group_id = self.m_tGameData.group_id},"guild_high_war_map_index")
    end
    local timeLabel = game_util:createCountdownLabel(time_left,timeOverCallFun,8,1)
    timeLabel:setColor(ccc3(0,255,0))
    timeLabel:setPosition(ccp(self.conutdownTime:getContentSize().width/2, self.conutdownTime:getContentSize().height/2))
    self.conutdownTime:addChild(timeLabel,10,10)

    if self.m_group_id and self.m_tGameData.self_group_id and self.m_group_id == self.m_tGameData.self_group_id then -- 从遗迹列表进入，只可在自己的对应分组的遗迹操作
        self.node_guild_icon:removeAllChildrenWithCleanup(true)
        local icon = self:createGuildIcon(self.m_tGameData.icon)
        self.node_guild_icon:addChild(icon)
        self.label_guild_name:setString(self.m_tGameData.ass_name)
    elseif not self.m_group_id and self.m_tGameData.self_group_id and self.m_tGameData.self_group_id ~= 0  then -- 直接从自己的对应分组的遗迹入口进入
        self.node_guild_icon:removeAllChildrenWithCleanup(true)
        local icon = self:createGuildIcon(self.m_tGameData.icon)
        self.node_guild_icon:addChild(icon)
        self.label_guild_name:setString(self.m_tGameData.ass_name)

    else
        self.node_my_guild_info:setVisible(false)
    end

    return ccbNode;

end
function game_godfield_guild_high_war_map:createScrollContent( parentNode )
    local container = CCLayer:create()
    local size = parentNode:getContentSize()

    local view = CCScrollView:create(size, container)
    maxOffsetX = 0
    maxOffsetY = 0
    view:setAnchorPoint(ccp(0,0))
    container:setContentSize(CCSizeMake(size.width, size.height))
    view:setContentSize(CCSizeMake(1136, size.height))
    view:setContentOffset(ccp(0, 0));
    view:setTouchEnabled(false)
    local background = CCSprite:create("ccbResources/godfield_build/ft_map01.png")
    view:addChild(background)
    maxOffsetX = background:getContentSize().width - size.width
    maxOffsetY = background:getContentSize().height - size.height
    return view, background
   
end

function game_godfield_guild_high_war_map:onEnter(  )
    local touchMoveFlag = false
    local selectFlag = false
    local selectIndex = nil
    local scrollviewOffset = nil
    local function layerTouch(eventType, x, y)
        if eventType == "began" then
            cclog("onTouchBegan: ", x, y)
            self.select_building = nil
            touchMoveFlag = false
            self.m_focus_block = nil
            selectFlag = false

            touch_start_x = x
            touch_start_y = y
            local touched = self.m_scroll_rect:containsPoint(ccp(x, y))
            scrollviewOffset = self.m_scroll_view:getContentOffset()
            
            for k,v in pairs(self.building_table) do
                local realPos = v:getParent():convertToNodeSpace(ccp(x,y));
                if v:boundingBox():containsPoint(realPos) then
                    self.touch_buildingTag = v:getTag()
                    self.select_building = v
                    selectFlag = true
                    selectIndex = k
                    break
                end
            end
            if self.select_building then
                local scale = self.select_building:getScale()
                self.select_building:setScale(scale + 0.05)
            end
            cclog2(touched,"touched")
            return touched
        elseif eventType == "moved" then
            -- cclog("onTouchMoved: ", x, y)
            --不让划出图片
            -- if scrollviewOffset.x + (x - touch_start_x) > -1136 and scrollviewOffset.x + (x - touch_start_x) < 0 then
            local srcollviewOffsetX = scrollviewOffset.x + (x - touch_start_x)
            local srcollviewOffsetY = scrollviewOffset.y + (y - touch_start_y)
            -- cclog2(srcollviewOffsetX,"srcollviewOffsetX")
            if srcollviewOffsetX > 0 then
                srcollviewOffsetX = 0
            end
            if srcollviewOffsetY > 0 then
                srcollviewOffsetY = 0
            end
            if srcollviewOffsetX < - maxOffsetX then
                srcollviewOffsetX = - maxOffsetX
            end
            if srcollviewOffsetY < - maxOffsetY then
                srcollviewOffsetY = - maxOffsetY
            end
            if self.select_building then
                local realPos = self.select_building:getParent():convertToNodeSpace(ccp(x,y));
                if self.select_building:boundingBox():containsPoint(realPos) then
                    
                else
                    -- self.select_building:setScale(1)
                    selectFlag = false
                end
            end
            if ccpDistance(ccp(touch_start_x,touch_start_y),ccp(x,y)) > 20 then
                touchMoveFlag = true
            end
            self.m_scroll_view:setContentOffset(ccp( srcollviewOffsetX, srcollviewOffsetY))
        elseif eventType == "ended" then
            if self.select_building then
                local realPos = self.select_building:getParent():convertToNodeSpace(ccp(x,y));
                local scale = self.select_building:getScale()
                self.select_building:setScale(scale -0.05)
                if self.select_building:boundingBox():containsPoint(realPos) and touchMoveFlag == false then
                    --进入建筑
                    local gameData = self.m_tGameData.god_integration_rank
       
                    local function moveEndCallFunc( )
                        self:enterBuilding( self.select_building,self.touch_buildingTag )
                    end 
                    moveEndCallFunc()
                else
                end
                self.select_building = nil
            end
        end
    end
    
    self.bg_layer:registerScriptTouchHandler(layerTouch, false, 2, true)
    self.bg_layer:setTouchEnabled(true)
end


function game_godfield_guild_high_war_map.enterBuilding(self,select_building,buildingTag)
    local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)
    local build_info = guild_high_war_build_cfg:getNodeWithKey(self.touch_buildingTag)
    local sort = build_info:getNodeWithKey("sort"):toInt()
    if sort == 4 then
        if not self.m_isSelfFlag then
            return game_util:addMoveTips({text = "Chỉ có người chơi Chiến Trường này có thể vào"})
        end

        local offset = self.m_scroll_view:getContentOffset()
        local function responseMethod( tag, gameData )
            game_scene:enterGameUi("game_godfield_guild_high_war_shop",{gameData = gameData, map_offset = offset, step = self.m_step, group_id = self.m_group_id or self.m_tGameData.group_id})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_shop_index"), http_request_method.GET, nil,"guild_high_war_shop_index")
    else
        local isSelfFlag = false
        if (self.m_tGameData.group_id == self.m_tGameData.self_group_id and self.m_tGameData.self_group_id ~= 0) or -- 从遗迹列表进入，只可在自己的对应分组的遗迹操作
            (not self.m_group_id and self.m_tGameData.self_group_id and self.m_tGameData.self_group_id ~= 0) then -- 直接从自己的对应分组的遗迹入口进入
            isSelfFlag = true
        end

        local function callBackFunc(id, mapData)
            if self.m_step == 9 then -- 关闭单个城市详情时，在战斗阶段重新刷新地图数据
                local function responseMethod( tag,gameData )
                    game_scene:enterGameUi("game_godfield_guild_high_war_map",{gameData = gameData, group_id = self.m_group_id, map_offset = self.m_scroll_view:getContentOffset()})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_map_index"), http_request_method.GET, {group_id = self.m_tGameData.group_id},"guild_high_war_map_index")
            else
                self.m_tGameData.map[tostring(id)] = mapData
                self:refreshUi(true)
            end
        end

        local function responseMethod( tag, gameData )
            game_scene:addPop("game_godfield_guild_high_war_base_pop",{build_id = self.touch_buildingTag, step = self.m_step, gameData = gameData, prev_gameData = self.m_tGameData, isSelfFlag = isSelfFlag, callBackFunc = callBackFunc})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_city_info"), http_request_method.GET, {group_id = self.m_group_id or self.m_tGameData.group_id, city_id = self.touch_buildingTag},"guild_high_war_city_info")
    end
end

--[[--
    刷新ui
]]
function game_godfield_guild_high_war_map.refreshUi(self, flag)
    if self.m_scroll_view then
        self.m_back_offset = self.m_scroll_view:getContentOffset()
        for k,v in pairs(building_tab) do
            v.points_record = nil
        end
    end
    self:createBuilding()

    if self.m_back_offset then
        self.m_scroll_view:setContentOffset(ccp(self.m_back_offset.x, self.m_back_offset.y))
    end

    local function setBtnColorEnabled(btn)
        btn:setColor(ccc3(150,150,150))
        btn:setEnabled(false)
    end

    local isSelfFlag = false
    if (self.m_tGameData.group_id == self.m_tGameData.self_group_id and self.m_tGameData.self_group_id ~= 0) or -- 从遗迹列表进入，只可在自己的对应分组的遗迹操作
        (not self.m_group_id and self.m_tGameData.self_group_id and self.m_tGameData.self_group_id ~= 0) then -- 直接从自己的对应分组的遗迹入口进入
        isSelfFlag = true
    end
    self.m_isSelfFlag = isSelfFlag

    if self.m_step == 2 then -- 准备阶段
        setBtnColorEnabled(self.m_btn_zhanbao)
        -- setBtnColorEnabled(self.m_btn_qianxian)
        self.m_btn_qianxian:setColor(ccc3(150,150,150))
        setBtnColorEnabled(self.m_btn_zhenxing)
    elseif self.m_step == 3 then -- 宣战阶段

        -- setBtnColorEnabled(self.m_btn_qianxian)
        self.m_btn_qianxian:setColor(ccc3(150,150,150))
        setBtnColorEnabled(self.m_btn_zhenxing)
        if not isSelfFlag then
            local x,y = self.m_btn_zhanbao:getPosition()
            self.m_btn_rank:setPosition(ccp(x,y))
        end
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
    end

    
    if not isSelfFlag then
        self.m_btn_keji:setVisible(false)
        self.m_btn_zhanbao:setVisible(false)
        self.m_btn_qianxian:setVisible(false)
        self.m_btn_zhenxing:setVisible(false)
        self.m_btn_miling:setVisible(false)
        self.m_btn_reward:setVisible(false)
        self.m_btn_bag:setVisible(false)    
        local x,y = self.m_btn_zhanbao:getPosition()
        self.m_btn_rank:setPosition(ccp(x,y)) 
    end

    self:setBuildLineColor()

    local guild_high_war_science_cfg = getConfig(game_config_field.guild_high_war_science)
    local science_info = guild_high_war_science_cfg:getNodeWithKey(self.m_tGameData.science_lv)
    if science_info then
        self.label_wr_tips:setString("Liên Minh kháng Aethẻ ".. science_info:getNodeWithKey("rate"):toStr() .."%")
    else
        self.label_wr_tips:setString("Liên Minh kháng Aethẻ 0%")
    end

    local declareTimes = self:getDeclareTimes()
    self.label_xz_times:setString("Số lần Tuyên Chiến còn:"..declareTimes)
    self.label_xz_times:setVisible(self.m_step == 3 and isSelfFlag)

    self.label_guild_combat:setString("Chiến Lực Công Hội:"..self.m_tGameData.combat)
end

---获取宣战次数
function game_godfield_guild_high_war_map.getDeclareTimes(self)
    local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)
    local association_id = self.m_tGameData.ass_id
    local temp_list = {}
    local count = 0
    for k,v in pairs(self.m_tGameData.map) do
        local build_info = guild_high_war_build_cfg:getNodeWithKey(k)
        local city_level = build_info:getNodeWithKey("city_level"):toInt()
        if v.def_guild and v.def_guild == association_id then
            temp_list[#temp_list + 1] = city_level
        end
        if v.att_guild and v.att_guild == association_id then
            count = count + 1
        end
    end

    table.sort( temp_list, function (data1, data2)
        return data1 < data2
    end )

    local times = (temp_list[#temp_list] or 1) - count
    return times
end


--- 设置地图偏移
function game_godfield_guild_high_war_map.setMapOffsetByBuildingId(self, buildingId )    
    local buildingInfo = self:getBuildPosData(tostring(buildingId))
    local offset = ccp(buildingInfo.offset[1]/2,buildingInfo.offset[2]/2)

    local winSize = CCDirector:sharedDirector():getWinSize();
    local offsetX = -offset.x + winSize.width * 0.5
     local offsetY = -offset.y + winSize.height * 0.5
    local offX = offsetX
    local offY = offsetY
    offX = math.min(offX, 0)
    offX = math.max(offX, -maxOffsetX)
    offY = math.min(offY, 0)
    offY = math.max(offY, -maxOffsetY)
    self.m_scroll_view:setContentOffset(ccp(offX, offY))
end


--[[--
    创建建筑物
]]
function game_godfield_guild_high_war_map.createBuilding(self)
    self.building_table = {}
    self.building_line_table = {}
    self.bg_layer:removeAllChildrenWithCleanup(true);
    if self.m_playerAnimNode then
        self.m_playerAnimNode = nil
    end
    self.m_scroll_view, background =  self:createScrollContent(self.bg_layer)

    self.bg_layer:addChild(self.m_scroll_view)


    local scroll_layer  = CCLayer:create()
    scroll_layer:setContentSize(CCSizeMake(background:getContentSize().width, background:getContentSize().height));
    scroll_layer:setAnchorPoint(ccp(0, 0))
    scroll_layer:setPosition(ccp(0, 0))
    self.m_scroll_view:addChild(scroll_layer)

    local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)

    local count = 0
    for k,v in pairs(building_tab) do
        local build_info = guild_high_war_build_cfg:getNodeWithKey(v.buildingID)
        local city_icon = build_info:getNodeWithKey("city_icon"):toStr()
        v.img = "ccbResources/godfield_build/"..city_icon..".png"
        local building = CCSprite:create(v.img)

        building:setAnchorPoint(ccp(0.5,0.5))
        local sort = build_info:getNodeWithKey("sort"):toInt()
        local city_level = build_info:getNodeWithKey("city_level"):toInt()

        if sort > 1 then
            if sort == 4 then
                building:setScale(0.9+(city_level-1)*0.2)
            else
                building:setScale(0.8+(city_level-1)*0.2)
            end
        else
            building:setScale(0.5+(city_level-1)*0.1)
        end
        local buildingSize = building:getContentSize()
        -- building:setPosition(ccp(v.offset[1],v.offset[2]))
        building:setPosition(ccp(v.offset[1]/2,v.offset[2]/2))

        --底部阴影
        local black_bottom = CCSprite:createWithSpriteFrameName("ft_map02.png")
        black_bottom:setPosition(buildingSize.width*0.5, buildingSize.height*0.5-20)
        local scale = building:getScale()
        if sort > 1 then
            black_bottom:setScale(scale-(city_level-1)*0.2)
        end
        building:addChild(black_bottom,-1)
        scroll_layer:addChild(building,1,v.buildingID)

        -- local msgLabel = CCLabelTTF:create(v.buildingID,TYPE_FACE_TABLE.Arial_BoldMT,24)
        -- building:addChild(msgLabel,2)

        local name_bottom = CCSprite:createWithSpriteFrameName("dt_mc_bg01.png")
        name_bottom:setScale(1) 
        local offsetY = 40
        if sort == 3 then
            offsetY = 20
        end
        name_bottom:setPosition(ccp(v.offset[1]/2,v.offset[2]/2-offsetY))
        scroll_layer:addChild(name_bottom,3)
        
        local city_name = build_info:getNodeWithKey("city_name"):toStr()
        local nameLabel = CCLabelTTF:create(city_name,TYPE_FACE_TABLE.Arial_BoldMT,13)
        nameLabel:setColor(ccc3(200, 232, 249))
        nameLabel:setPosition(ccp(name_bottom:getContentSize().width/2, name_bottom:getContentSize().height/2))
        name_bottom:addChild(nameLabel)

        local mapData = self.m_tGameData.map[tostring(v.buildingID)]

        local buildingInfo 
        for _,vv in pairs(self.m_tGameData.info or {}) do
            if tostring(v.buildingID) == tostring(vv.city) then
                buildingInfo = vv
            end
        end

        local function createAtkIcon()
            -- 中间的攻击图标
            local spr_gongji = CCSprite:create("ccbResources/godfield_build/godfield_gongji.png");
            scroll_layer:addChild(spr_gongji,2)
            spr_gongji:setScale(0.65)
            spr_gongji:setPosition(ccp(v.offset[1]/2,v.offset[2]/2-offsetY+40))
        end
        if buildingInfo and (self.m_step == 9 or self.m_step == 8) then -- 在战斗阶段/战斗结算阶段如果有战报特殊显示
            name_bottom:removeAllChildrenWithCleanup(true)
            -- 防守方
            local nameLabel1 = CCLabelTTF:create(buildingInfo.def_guild_name,TYPE_FACE_TABLE.Arial_BoldMT,13)
            nameLabel1:setColor(ccc3(200, 232, 249))
            nameLabel1:setPosition(ccp(name_bottom:getContentSize().width/2, name_bottom:getContentSize().height/2))
            name_bottom:addChild(nameLabel1)

            local icon
            if buildingInfo.def_guild_icon == "" then
                icon = CCSprite:createWithSpriteFrameName("ui_wormhole_map_icon_bigboss1.png")
                icon:setScale(0.3)
            else
                icon = self:createGuildIcon(buildingInfo.def_guild_icon)
            end
            name_bottom:addChild(icon)
            icon:setPosition(ccp(0, name_bottom:getContentSize().height/2))
            name_bottom:setPosition(ccp(v.offset[1]/2,v.offset[2]/2-offsetY+20))
            local gf_msz05 = CCSprite:createWithSpriteFrameName("gf_msz05.png")
            gf_msz05:setAnchorPoint(ccp(1,0))
            name_bottom:addChild(gf_msz05)
            gf_msz05:setPosition(ccp(name_bottom:getContentSize().width, 15))

            -- 进攻方
            local name_bottom2 = CCSprite:createWithSpriteFrameName("dt_mc_bg01.png")
            local offsetY = 40
            -- if sort == 3 then
            --     offsetY = 20
            -- end
            name_bottom2:setPosition(ccp(v.offset[1]/2,v.offset[2]/2-offsetY+60))
            scroll_layer:addChild(name_bottom2,3)
            
            local nameLabel = CCLabelTTF:create(buildingInfo.att_guild_name,TYPE_FACE_TABLE.Arial_BoldMT,13)
            nameLabel:setColor(ccc3(200, 232, 249))
            nameLabel:setPosition(ccp(name_bottom2:getContentSize().width/2, name_bottom2:getContentSize().height/2))
            name_bottom2:addChild(nameLabel)

            local icon = self:createGuildIcon(buildingInfo.att_guild_icon)
            name_bottom2:addChild(icon)
            icon:setPosition(ccp(0, name_bottom2:getContentSize().height/2))

            local gf_msz06 = CCSprite:createWithSpriteFrameName("gf_msz06.png")
            gf_msz06:setAnchorPoint(ccp(1,0))
            name_bottom2:addChild(gf_msz06)
            gf_msz06:setPosition(ccp(name_bottom2:getContentSize().width, 15))

            local win_icon = CCSprite:createWithSpriteFrameName("guild_high_war_sheng.png")
            if buildingInfo.is_win == 1 then
                name_bottom2:addChild(win_icon)
                win_icon:setPosition(ccp(name_bottom2:getContentSize().width-5, 8))
            else
                name_bottom:addChild(win_icon)
                win_icon:setPosition(ccp(name_bottom:getContentSize().width-5, 8))
            end
            -- 中间的攻击图标
            createAtkIcon()
        elseif mapData.def_icon and mapData.def_icon ~= "" and mapData.att_icon and mapData.att_icon == "" then -- 只有防守方
            local icon = self:createGuildIcon(mapData.def_icon)
            name_bottom:addChild(icon)
            icon:setPosition(ccp(0, name_bottom:getContentSize().height/2))
        elseif mapData.def_icon and (mapData.def_icon ~= "" or mapData.def_icon == "") and mapData.att_icon and mapData.att_icon ~= "" then -- 进攻方、防守方
            name_bottom:removeAllChildrenWithCleanup(true)
            local def_name = mapData.def_name
            if mapData.def_icon == "" then
                def_name = "Quân phòng thủ"
            end
            -- 防守方
            local nameLabel1 = CCLabelTTF:create(def_name,TYPE_FACE_TABLE.Arial_BoldMT,13)
            nameLabel1:setColor(ccc3(200, 232, 249))
            nameLabel1:setPosition(ccp(name_bottom:getContentSize().width/2, name_bottom:getContentSize().height/2))
            name_bottom:addChild(nameLabel1) 
            local icon
            if mapData.def_icon == "" then
                icon = CCSprite:createWithSpriteFrameName("ui_wormhole_map_icon_bigboss1.png")
                icon:setScale(0.3)
            else
                icon = self:createGuildIcon(mapData.def_icon)
            end
            name_bottom:addChild(icon)
            icon:setPosition(ccp(0, name_bottom:getContentSize().height/2))
            name_bottom:setPosition(ccp(v.offset[1]/2,v.offset[2]/2-offsetY+20))
            local gf_msz05 = CCSprite:createWithSpriteFrameName("gf_msz05.png")
            gf_msz05:setAnchorPoint(ccp(1,0))
            name_bottom:addChild(gf_msz05)
            gf_msz05:setPosition(ccp(name_bottom:getContentSize().width, 15))


            -- 进攻方
            local name_bottom2 = CCSprite:createWithSpriteFrameName("dt_mc_bg01.png")
            local offsetY = 40
            -- if sort == 3 then
            --     offsetY = 20
            -- end
            name_bottom2:setPosition(ccp(v.offset[1]/2,v.offset[2]/2-offsetY+60))
            scroll_layer:addChild(name_bottom2,3)
            
            local nameLabel = CCLabelTTF:create(mapData.att_name,TYPE_FACE_TABLE.Arial_BoldMT,13)
            nameLabel:setColor(ccc3(200, 232, 249))
            nameLabel:setPosition(ccp(name_bottom2:getContentSize().width/2, name_bottom2:getContentSize().height/2))
            name_bottom2:addChild(nameLabel)

            local icon = self:createGuildIcon(mapData.att_icon)
            name_bottom2:addChild(icon)
            icon:setPosition(ccp(0, name_bottom2:getContentSize().height/2))

            local gf_msz06 = CCSprite:createWithSpriteFrameName("gf_msz06.png")
            gf_msz06:setAnchorPoint(ccp(1,0))
            name_bottom2:addChild(gf_msz06)
            gf_msz06:setPosition(ccp(name_bottom2:getContentSize().width, 15))

            -- 中间的攻击图标
            createAtkIcon()
        elseif mapData.def_guild and mapData.def_guild == "" and mapData.att_guild and mapData.att_guild == "" and sort == 1 then -- 怪物占领的城池
            local enemy_icon = CCSprite:createWithSpriteFrameName("ui_wormhole_map_icon_bigboss1.png")
            enemy_icon:setScale(0.3)
            name_bottom:addChild(enemy_icon)
            enemy_icon:setPosition(ccp(0, name_bottom:getContentSize().height/2))
        end
        
        local association_id = self.m_tGameData.ass_id;
        if mapData.def_guild and mapData.def_guild == association_id then
            local mAnimNode = game_util:createUniversalAnim({animFile = "ui_zhuchengtishi",actionName = "impact",loopFlag = true});
            mAnimNode:setPosition(ccp(v.offset[1]/2,v.offset[2]/2-10))
            scroll_layer:addChild(mAnimNode,2)
        end

        local attack_point = json.decode(build_info:getNodeWithKey("attack_point"):getFormatBuffer())
        local pos1 = ccp(v.offset[1], v.offset[2])
        for i,vv in ipairs(attack_point) do
            local flag = false
            local targetPosData = self:getBuildPosData(tostring(vv))

            for k,vvv in pairs(targetPosData.points_record or {}) do
                if tostring(vv) == tostring(vvv[1]) or tostring(vv) == tostring(vvv[2]) then
                    flag = true 
                    break
                end
            end

            if not flag then
                local targetPosData = self:getBuildPosData(tostring(vv))
                local pos2 = ccp(targetPosData.offset[1],targetPosData.offset[2])
                local angle = self:getAngleByPos(pos1, pos2)

                -- 计算斜线上每个点的坐标
                local tempBg = CCSprite:createWithSpriteFrameName("dt_line02.png")
                local distance = math.sqrt((pos2.x - pos1.x)^2 + (pos2.y - pos1.y)^2)/2
                local count = math.floor(distance/(tempBg:getContentSize().height))
                local numOfSprites = count
                local deltaX = (pos2.x/2 - pos1.x/2) / (numOfSprites - 1.5)
                local deltaY = (pos2.y/2 - pos1.y/2) / (numOfSprites - 1)
                -- 创建精灵并设置位置
                local count2 = numOfSprites-2
                for i = 1, count2 do
                    if i < count2 then
                        local sprite = "dt_line03"
                        if i == 1 then
                            sprite = "dt_line01"
                        elseif count2-1 == i then
                            sprite = "dt_line05"
                        elseif count2-2 == i then
                            sprite = "dt_line04"
                        elseif i == 2 then
                            sprite = "dt_line02"
                        end
                        local tempBg = CCSprite:createWithSpriteFrameName(sprite..".png")
                        tempBg:setScaleY(0.1)
                        tempBg:setColor(ccc3(128, 128, 128))
                        local position = ccp(pos1.x/2 + i * deltaX, pos1.y/2 + i * deltaY)
                        tempBg:setPosition(position)
                        scroll_layer:addChild(tempBg,0)
                        tempBg:setRotation(angle)
                        tempBg:setAnchorPoint(ccp(0,0.5))

                        table.insert(self.building_line_table, {spr = tempBg, build1 = v.buildingID, build2 = vv})
                    end
                end

                if not v.points_record then
                    v.points_record = {}
                end

                table.insert(v.points_record, {v.buildingID, vv})
            end
        end


        table.insert( self.building_table, building )
    end
end


function game_godfield_guild_high_war_map:getBuildPosData(buildingID)  
    for k,v in pairs(building_tab) do
        if v.buildingID == buildingID then
            return v
        end
    end
end

function game_godfield_guild_high_war_map:getAngleByPos(p1,p2)  
    local p = {}  
    p.x = p2.x - p1.x  
    p.y = p2.y - p1.y  

    -- local r = math.atan2(p.y,p.x)*180/math.pi -90
    local r = math.atan2(p.y,p.x)*180/math.pi
    return -r  
end  



function  game_godfield_guild_high_war_map:createGuildIcon(icon)
    local icon_str = ""
    if tonumber(icon) > 9 then
        icon_str = icon
    else
        icon_str = "0"..icon
    end

    local guild_icon = CCSprite:create("ccbResources/guild_high_war/gh_icon" .. icon_str .. "_1.png");
    return guild_icon
end



--[[--
    初始化
]]
function game_godfield_guild_high_war_map.init(self,t_params)
    t_params = t_params or {};
    self.m_group_id = t_params.group_id
    self.m_map_offset = t_params.map_offset
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        self.m_step = self.m_tGameData.step
    else
        self.m_tGameData = {};
    end
end

-- 展示地图要偏移的位置
function game_godfield_guild_high_war_map.showNeedOffset(self)

    if (self.m_tGameData.group_id == self.m_tGameData.self_group_id and self.m_tGameData.self_group_id ~= 0) or -- 从遗迹列表进入，只可在自己的对应分组的遗迹操作
    (not self.m_group_id and self.m_tGameData.self_group_id and self.m_tGameData.self_group_id ~= 0) then -- 直接从自己的对应分组的遗迹入口进入
        self.node_guild_icon:removeAllChildrenWithCleanup(true)
        local icon = self:createGuildIcon(self.m_tGameData.icon)
        self.node_guild_icon:addChild(icon)
        self.label_guild_name:setString(self.m_tGameData.ass_name)

        local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)
        local city_list = {}
        for k,v in pairs(self.m_tGameData.city) do
            local build_info = guild_high_war_build_cfg:getNodeWithKey(k)
            local sort = build_info:getNodeWithKey("sort"):toInt()
            local city_level = build_info:getNodeWithKey("city_level"):toInt()
            if not city_list[city_level] then
                city_list[city_level] = {}
            end
            table.insert(city_list[city_level], k)
        end
        for k,v in pairs(city_list) do
            table.sort(v, function(data1,data2)
                return tonumber(data1) < tonumber(data2)
            end)
        end
        local buildingId = 0
        for i=3,1,-1 do
            if city_list[i] and city_list[i][1] then
                buildingId = city_list[i][1]
            end
        end
        local show_buildingId = buildingId
        if show_buildingId and tonumber(show_buildingId) >0 then
            self:setMapOffsetByBuildingId(show_buildingId)
        end
    else
        self:setMapOffsetByBuildingId(100)
    end 

    if self.m_map_offset then
        self.m_scroll_view:setContentOffset(ccp(self.m_map_offset.x, self.m_map_offset.y))
    end
end   
  
-- 设置路线变亮变暗
function game_godfield_guild_high_war_map.setBuildLineColor(self)
    local function setAnim(icon)
        icon:stopAllActions()
        game_util:setSpriteDisplayBySpriteFrameName(icon, "dt_line06.png")
        icon:setColor(ccc3(255,255,255))
        local animArr = CCArray:create()
        animArr:addObject(CCFadeIn:create(1.0))
        animArr:addObject(CCFadeOut:create(1.0))
        icon:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
    end

    local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)
    for k,v in pairs(self.m_tGameData.city) do
        local build_info = guild_high_war_build_cfg:getNodeWithKey(k)
        local attack_point = json.decode(build_info:getNodeWithKey("attack_point"):getFormatBuffer())

        for kk,vv in pairs(attack_point) do
            local build_info2 = guild_high_war_build_cfg:getNodeWithKey(vv)
            local attack_point2 = json.decode(build_info2:getNodeWithKey("attack_point"):getFormatBuffer())
            for kkk,vvv in pairs(self.building_line_table) do
                if (tostring(vvv.build1) == tostring(k) and tostring(vvv.build2) == tostring(vv)) then
                    setAnim(vvv.spr)
                end

                if (tostring(vvv.build1) == tostring(vv) and tostring(vvv.build2) == tostring(k)) then
                    setAnim(vvv.spr)
                end

                for _,v2 in pairs(attack_point2) do
                    if (tostring(vvv.build1) == tostring(v2) and tostring(vvv.build2) == tostring(k)) then
                        setAnim(vvv.spr)
                    end
                    if (tostring(vvv.build1) == tostring(k) and tostring(vvv.build2) == tostring(v2)) then
                        setAnim(vvv.spr)
                    end
                end
            end
        end 
    end
end


--[[--
    创建入口
]]
function game_godfield_guild_high_war_map.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    self:showNeedOffset();
    return rootScene;
end
return game_godfield_guild_high_war_map;