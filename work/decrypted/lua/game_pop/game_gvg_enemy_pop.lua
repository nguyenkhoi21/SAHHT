--- 敵人
local game_gvg_enemy_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,

    name_label = nil,
    area_label = nil,
    level_label = nil,
    arena_label = nil,
    guild_label = nil,
    m_anim_node = nil,

    m_callFunc = nil,
    gameData = nil,
    enemy_tips_node = nil,
    win_tips_label = nil,
    enemy_info_node = nil,
    recover_label = nil,
    cardLayer = nil,
    m_next_step = nil,
    m_combat_label = nil,
    fight_flag = nil,
    protect_node = nil,
    tip_label = nil,
    countDownTime = nil,
    buildingId = nil,
    building_cid = nil,

    btn_continue = nil,
    enterType = nil,
    is_def = nil,
    callFunc = nil,
    reboot = nil,
    owner = nil,
    life = nil,

    owner_times = nil,
    cd_flag = nil,
    can_buy_times = nil,
    m_tGameData = nil,
    in_building = nil,
    tips_label = nil,
    occpuyFlag = nil,
    jifen_node = nil,
    sort = nil,
};

--[[--
    銷毀
]]
function game_gvg_enemy_pop.destroy(self)
    -- body
    cclog("-----------------game_gvg_enemy_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;

    self.name_label = nil;
    self.area_label = nil;
    self.level_label = nil;
    self.arena_label = nil;
    self.guild_label = nil;
    self.m_anim_node = nil;

    self.m_callFunc = nil;
    self.gameData = nil;

    self.enemy_tips_node = nil;
    self.win_tips_label = nil;
    self.enemy_info_node = nil;
    self.recover_label = nil;
    self.m_next_step = nil;
    self.m_combat_label = nil;
    self.fight_flag = nil;
    self.protect_node = nil;
    self.tip_label = nil;
    self.countDownTime = nil;
    self.buildingId = nil;
    self.building_cid = nil;
    ---------
    self.btn_continue = nil;
    self.enterType = nil;
    self.is_def = nil;
    self.callFunc = nil;
    self.reboot = nil;
    self.owner = nil;
    self.life = nil;

    self.owner_times = nil;
    self.cd_flag = nil;
    self.can_buy_times = nil;
    self.m_tGameData = nil;
    self.in_building = nil;
    self.tips_label = nil;
    self.occpuyFlag = nil;
    self.jifen_node = nil;
    self.sort = nil;
end
--[[
    購買時間提示
]]
function game_gvg_enemy_pop.buyBattleTime(self)
    local function buyTimeResponseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        local gvgData = data:getNodeWithKey("gvg")
        self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
        game_util:addMoveTips({text = "Bỏ qua nghỉ ngơi thành công!"})  -- 跳過休息成功！
        if self.m_tGameData.owner_time > 0 then
            self.cd_flag = true
        else
            self.cd_flag = false
        end
        self.owner_times = self.m_tGameData.owner_times
        self.can_buy_times = self.m_tGameData.can_buy_times
        game_util:closeAlertView()
        self:fightFunc()
    end
    local t_params = 
    {
        title = string_config.m_title_prompt,
        okBtnCallBack = function(target,event)
            network.sendHttpRequest(buyTimeResponseMethod,game_url.getUrlForKey("guild_gvg_buy_time"), http_request_method.GET, nil,"guild_gvg_buy_time")
        end,   --可缺省
        okBtnText = string_config.m_btn_sure,       --可缺省
        cancelBtnText = string_config.m_btn_cancel,
        -- Bạn mới chiến đấu xong cần nghỉ ngơi, xác nhận dùng 50 xu bỏ qua nghỉ ngơi?  --  您剛剛戰鬥完，需要休息，是否花費50鑽石跳過休息？
        text = " Bạn mới chiến đấu xong cần nghỉ ngơi, xác nhận dùng 50 xu bỏ qua nghỉ ngơi?",      --可缺省
        onlyOneBtn = false,
        touchPriority = GLOBAL_TOUCH_PRIORITY-17,
    }
    game_util:openAlertView(t_params)
end
--[[
    購買次數提示
]]
function game_gvg_enemy_pop.buyBattleTimes(self)
    if self.can_buy_times > 0 then--可購買次數大於0
        local function buyTimeResponseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local gvgData = data:getNodeWithKey("gvg")
            self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
            game_util:addMoveTips({text = "Mua số lần thành công!"})  -- Mua số lần thành công!  --  購買次數成功！
            if self.m_tGameData.owner_time > 0 then
                self.cd_flag = true
            else
                self.cd_flag = false
            end
            self.owner_times = self.m_tGameData.owner_times
            self.can_buy_times = self.m_tGameData.can_buy_times
            game_util:closeAlertView()
        end
        local t_params = 
        {
            title = string_config.m_title_prompt,
            okBtnCallBack = function(target,event)
                network.sendHttpRequest(buyTimeResponseMethod,game_url.getUrlForKey("guild_gvg_buy_times"), http_request_method.GET, nil,"guild_gvg_buy_times")
            end,   --可缺省
            okBtnText = string_config.m_btn_sure,       --可缺省
            cancelBtnText = string_config.m_btn_cancel,
            text = "Số lần chiến đấu của bạn đã dùng hết, xác nhận dùng 50 xu mua thêm số lần?",      --可缺省 您的戰鬥次數已用完，是否花費50鑽石購買額外次數？
            onlyOneBtn = false,
            touchPriority = GLOBAL_TOUCH_PRIORITY-17,
        }
        game_util:openAlertView(t_params)
    else
        game_util:addMoveTips({text = "Số lần chiến đấu của bạn đã dùng hết!"})  --  您的戰鬥次數已全部用完！
    end
end
--[[
    是否放棄提示
]]
function game_gvg_enemy_pop.giveUp(self)
    local function giveUpResponseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        local gvgData = data:getNodeWithKey("gvg")
        self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
        game_util:addMoveTips({text = "Từ bỏ thành công!"})  --  放棄成功！
        self.occpuyFlag = false
        if self.m_tGameData.owner_time > 0 then
            self.cd_flag = true
        else
            self.cd_flag = false
        end
        self.owner_times = self.m_tGameData.owner_times
        self.can_buy_times = self.m_tGameData.can_buy_times
        game_util:closeAlertView()
    end
    local t_params = 
    {
        title = string_config.m_title_prompt,
        okBtnCallBack = function(target,event)
            network.sendHttpRequest(giveUpResponseMethod,game_url.getUrlForKey("guild_gvg_give_up_building"), http_request_method.GET,{},"guild_gvg_give_up_building")
        end,   --可缺省
        okBtnText = string_config.m_btn_sure,       --可缺省
        cancelBtnText = string_config.m_btn_cancel,
        text = "Bạn đã chiếm được một mảnh đất, xác nhận từ bỏ mảnh đất này?",      --可缺省  -- 您已經佔領了一個地塊，是否放棄該地塊？
        onlyOneBtn = false,
        touchPriority = GLOBAL_TOUCH_PRIORITY-17,
    }
    game_util:openAlertView(t_params)
end
--[[
    戰鬥
]]
function game_gvg_enemy_pop.fightFunc(self)
    local gvgCfg = getConfig(game_config_field.guild_fight)
    local itemCfg = gvgCfg:getNodeWithKey(tostring(self.buildingId))
    local function responseMethod(tag,gameData)
        game_data:setBattleType("game_gvg");
        local data = gameData:getNodeWithKey("data")
        local building_name = itemCfg:getNodeWithKey("building_name"):toStr()
        local stageTableData = {name = building_name,step = 1,totalStep = 1}
        --傳背景圖
        -- local backImgCfg = self.liveCfg:getNodeWithKey(tostring(self.curr_level))
        -- local imgName = backImgCfg:getNodeWithKey("background"):toStr();
        game_scene:enterGameUi("game_battle_scene",{gameData = gameData,stageTableData=stageTableData,backGroundName=nil});
    end
    if self.owner_times > 0 then--次數大於0
        if self.cd_flag == false then--次數大於0且不在cd
            if self.occpuyFlag == true then--再加上如果占坑放棄的提示
                self:giveUp()
            else
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_attack"), http_request_method.GET, {building_id = self.buildingId},"guild_gvg_attack")
            end
        else--否則買時間
            self:buyBattleTime()
        end
    else--次數為0，買次數
        self:buyBattleTimes()
    end
end
--[[--
    返回
]]
function game_gvg_enemy_pop.back(self,type)
    -- game_scene:removePopByName("game_gvg_enemy_pop");
    if self.enterType == "perpare" then
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local sort = data:getNodeWithKey("sort"):toInt()
            if sort == 1 then--外圍戰佈陣開啟
                -- game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 1});
                game_scene:enterGameUi("game_gvg_war",{gameData = gameData})--公會戰戰中   佈陣
            elseif sort == 2 then--外圍戰戰爭開始
                game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 2});
            elseif sort == 3 then--內城佈陣開始
                -- game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 3});
                game_scene:enterGameUi("game_gvg_war",{gameData = gameData})--公會戰戰中   佈陣
            elseif sort == 4 then--內城戰開始
                game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 4});
            elseif sort == 5 then
                
            elseif sort == -1 then--公會戰未開啟
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
            else
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = sort});
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_embattle_doing"), http_request_method.GET, nil,"guild_gvg_embattle_doing")
    else
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local sort = data:getNodeWithKey("sort"):toInt()
            if sort == 1 then--外圍戰佈陣開啟
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 1});
            elseif sort == 2 then--外圍戰戰爭開始
                game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 2});
            elseif sort == 3 then--內城佈陣開始
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 3});
            elseif sort == 4 then--內城戰開始
                game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 4});
            elseif sort == 5 then
                
            elseif sort == -1 then--公會戰未開啟
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
            else
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = sort});
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_index"), http_request_method.GET, nil,"guild_gvg_index")
    end
end
--[[--
    讀取ccbi創建ui
]]
function game_gvg_enemy_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then--戰鬥
            if self.enterType == "perpare" then--會長踢人
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_gvg_war",{gameData = gameData})--公會戰戰中   佈陣
                    game_util:addMoveTips({text = "Đá thành công!"})  -- 踢除成功！
                    -- local data = json.decode(gameData:getNodeWithKey("data"))
                    -- cclog2(data,"data")
                    -- self.callFunc(data)
                    -- self:back()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_remove_building"), http_request_method.GET, {building_id = self.buildingId},"guild_gvg_remove_building")
            elseif self.enterType == "half" then--上半場戰鬥
                self:fightFunc()
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_gvg_enemy_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    self.btn_continue = ccbNode:controlButtonForName("btn_continue")
    self.btn_continue:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    self.enemy_tips_node = ccbNode:nodeForName("enemy_tips_node")

    self.name_label = ccbNode:labelTTFForName("name_label")
    self.level_label = ccbNode:labelTTFForName("level_label")
    self.arena_label = ccbNode:labelTTFForName("arena_label")
    self.guild_label = ccbNode:labelTTFForName("guild_label")

    self.enemy_info_node = ccbNode:nodeForName("enemy_info_node")

    self.recover_label = ccbNode:labelBMFontForName("recover_label")
    self.m_combat_label = ccbNode:labelBMFontForName("m_combat_label")

    self.tips_label = ccbNode:labelTTFForName("tips_label")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_anim_node:removeAllChildrenWithCleanup(true)
    local big_img = game_util:createPlayerBigImgByRoleId(1);
    if big_img then
        self.m_anim_node:addChild(big_img);
        self.m_anim_node:setScale(0.45);
    end
    self.jifen_node = ccbNode:nodeForName("jifen_node")

    -- self.protect_node = ccbNode:nodeForName("protect_node")--保護時間倒計時
    -- self.tip_label = ccbNode:labelTTFForName("tip_label")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_gvg_enemy_pop.refreshUi(self)
    self.name_label:setString(self.gameData.name)
    self.level_label:setString(self.gameData.level)
    local debuff = self.buildingInfo.debuff + 100
    self.arena_label:setString(debuff .. "%")
    local leftLife = self.buildingInfo.life - 1
    if leftLife <= 0 then
        leftLife = 0
    end
    self.guild_label:setString(leftLife)
    self.m_anim_node:removeAllChildrenWithCleanup(true)
    local big_img = game_util:createPlayerBigImgByRoleId(tonumber(self.gameData.role));
    if big_img then
        self.m_anim_node:addChild(big_img);
        self.m_anim_node:setScale(0.45);
    end

    self:initTeamFormation(self.enemy_info_node);
    self.m_combat_label:setString(self.gameData.combat);
    if self.enterType == "perpare" then--戰前準備，只有會長能夠踢人其他人沒有按鈕
        local myUid = game_data:getUserStatusDataByKey("uid");
        if myUid == self.owner then
            self.btn_continue:setVisible(true)
            -- Hủy bỏ phòng thủ  -- 取消防守
            game_util:setCCControlButtonTitle(self.btn_continue,"Hủy bỏ phòng thủ")
        else
            self.btn_continue:setVisible(false)
        end
    elseif self.enterType == "half" then--上半場
        -- if self.is_def == true then--自己是防守方
        --     if self.buildingId > 100 then--攻擊方的地塊，可以打
        --         self.btn_continue:setVisible(true)
        --     else
        --         self.btn_continue:setVisible(false)
        --     end
        -- else--自己是攻擊方
        --     if self.buildingId > 100 then--
        --         self.btn_continue:setVisible(false)
        --     else
        --         self.btn_continue:setVisible(true)
        --     end
        -- end
        -- if self.life <= 0 then
        --     self.btn_continue:setVisible(false)
        -- end
        -- if self.in_building then--在坑裡，提示
        --     self.btn_continue:setVisible(false)
        --     self.tips_label:setVisible(true)
        -- end
        --[[
        if self.buildingInfo.sort == 1 and self.buildingInfo.is_battle == true then
            if self.in_building == true then--在坑裡，提示
                self.btn_continue:setVisible(false)
                self.tips_label:setVisible(true)
            else
                self.btn_continue:setVisible(true)
            end
        elseif self.buildingInfo.sort == 2 or self.buildingInfo.sort == 3 then--攻擊的是資源點
            self.btn_continue:setVisible(true)
            if self.is_def == true then
                
            else
                self.btn_continue:setVisible(false)
            end
            if self.life <= 0 then
                self.btn_continue:setVisible(false)
            end
            if self.in_building == true then--在坑裡，提示
                self.btn_continue:setVisible(false)
                self.tips_label:setVisible(true)
            end
        -- elseif self.buildingInfo.sort == 1 and self.buildingInfo.is_battle == false then
        --     self.btn_continue:setVisible(true)
        else
            self.btn_continue:setVisible(false)
        end
        ]]
        ---改成只要是對方陣營就顯示    sort 2、3 是資源點   1是防守方地塊
        if self.buildingInfo.sort == 2 or self.buildingInfo.sort == 3 then--打開的是資源點
            if self.is_def == true then
                self.btn_continue:setVisible(true)
            else
                self.btn_continue:setVisible(false)
            end
            if self.life <= 0 then
                self.btn_continue:setVisible(false)
            end
            self.jifen_node:setVisible(true)
            local guild_fight = getConfig(game_config_field.guild_fight)
            local itemCfg = guild_fight:getNodeWithKey(tostring(self.buildingId))
            local score = itemCfg:getNodeWithKey("score"):toInt()
            if self.sort == 4 then
                score = score * 2
            end
            self.guild_label:setString(score)
        elseif self.buildingInfo.sort == 1 then--打開的是防守方地塊
            --guild_sort: 0. 未知. 1. 防守方, 2. 攻擊方
            local guild_sort = self.buildingInfo.guild_sort
            if self.is_def == true and guild_sort == 1 then--防守方打防守方
                self.btn_continue:setVisible(false)
            elseif self.is_def == true and guild_sort == 2 then--防守方打攻擊方
                self.btn_continue:setVisible(true)
            elseif self.is_def == false and guild_sort == 2 then--攻擊方打攻擊方
                -- self.btn_continue:setVisible(false)
                self.btn_continue:setVisible(true)
            elseif self.is_def == false and guild_sort == 1 then--攻擊方打防守方
                self.btn_continue:setVisible(true)
            else
                self.btn_continue:setVisible(true)
            end

        end
    end
end
--[[
    初始化陣型
]]
function game_gvg_enemy_pop.initTeamFormation(self,parentNode)
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemData = self.gameData.alignment_info[btnTag];
        if itemData then
            game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 3})
        end
    end
    self.enemy_info_node:removeAllChildrenWithCleanup(true)
    local nodeSize = self.enemy_info_node:getContentSize()
    local itemId = nil;
    local itemData = nil;
    local itemIcon = nil;
    local headIconSpr = nil;
    local character_detail_cfg = getConfig("character_detail");
    local dw = nodeSize.width / #self.gameData.alignment_info
    local dx = dw / 2
    for i=1,math.min(5,#self.gameData.alignment_info) do
        itemData = self.gameData.alignment_info[i];
        if itemData and itemData.c_id then
            heroCfg = character_detail_cfg:getNodeWithKey(itemData.c_id);
            if itemData and heroCfg then
                headIconSpr = game_util:createCardIconByCfg(heroCfg);
                if headIconSpr then
                    headIconSpr:setScale(0.8);
                    headIconSpr:setPosition(ccp(dx + (i-1)*dw,27));
                    self.enemy_info_node:addChild(headIconSpr,1,1);

                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                    button:setTag(i)
                    button:setOpacity(0)
                    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition(ccp(dx + (i-1)*dw,27))
                    self.enemy_info_node:addChild(button);
                end
            end
        end
    end
end
--[[--
    初始化
]]
function game_gvg_enemy_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_callFunc = t_params.callFunc;
    
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        -- self.countDownTime = data:getNodeWithKey("time"):toInt()
        self.is_def = data:getNodeWithKey("is_def"):toBool()
        self.owner = data:getNodeWithKey("owner"):toStr()
        self.reboot = data:getNodeWithKey("reboot"):toInt()
        self.buildingInfo = json.decode(data:getNodeWithKey("building"):getFormatBuffer())
        local gvgData = data:getNodeWithKey("gvg")
        self.gameData = json.decode(gvgData:getFormatBuffer()) or {};
        self.buildingId = t_params.buildingId
        self.building_cid = t_params.building_cid--配置的id
        self.in_building = data:getNodeWithKey("in_building"):toBool()
    else
        self.gameData = {};
    end
    self.enterType = t_params.enterType
    self.callFunc = t_params.callFunc
    self.life = t_params.life
    self.owner_times = t_params.owner_times
    self.cd_flag = t_params.cd_flag
    self.can_buy_times = t_params.can_buy_times
    self.occpuyFlag = self.in_building
    self.occupy_building = t_params.occupy_building
    self.sort = t_params.sort
end

--[[--
    創建ui入口並初始化數據
]]
function game_gvg_enemy_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_gvg_enemy_pop;