---  生存大挑戰
local game_activity_live = {
    levels_table = nil,
    bar_node = nil,
    time_label = nil,
    revival_label = nil,
    btn_onrush = nil,
    btn_fight = nil,
    enemy_node = nil,
    reward_node = nil,
    level_node = nil,
    live_data = nil,
    mapConfig= nil,

    curr_level = nil,
    box_table = nil,
    point_sprite = nil,
    progress_sprite = nil,
    clear_flag = nil,
    history_label = nil,
    max_level = nil,
    onrush_level = nil,
    is_anim = nil,
    tableView = nil,
    showPageIndex = nil,
    back_curr_level = nil,
    onrush_max_level = nil,
    onrush_flag = nil,
    cfg_max_level = nil,--配置最大層
};
--[[--
    銷毀ui
]]
function game_activity_live.destroy(self)
    cclog("-----------------game_activity_live destroy-----------------");
    self.levels_table = nil;
    self.bar_node = nil;
    self.time_label = nil;
    self.revival_label = nil;
    self.btn_onrush = nil;
    self.btn_fight = nil;
    self.enemy_node = nil;
    self.reward_node = nil;
    self.level_node = nil;
    self.live_data = nil;
    self.mapConfig = nil;
    self.curr_level = nil;
    self.box_table = nil;
    self.point_sprite = nil;
    self.progress_sprite = nil;
    self.clear_flag = nil;
    self.history_label = nil;
    self.max_level = nil;
    self.onrush_level = nil;
    self.is_anim = nil;
    self.tableView = nil;
    self.showPageIndex = nil;
    self.back_curr_level = nil;
    self.onrush_max_level = nil;
    self.onrush_flag = nil;
    self.cfg_max_level = nil;
end


--[[--
    返回
]]
function game_activity_live.back(self,backType)
    -- local function responseMethod(tag,gameData)
    --     game_scene:enterGameUi("game_activity",{gameData = gameData})
    --     self:destroy()
    -- end
    -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = endCallFunc});
end
--[[--
    讀取ccbi創建ui
]]
function game_activity_live.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " .. btnTag)
        if self.onrush_flag == true then
            game_util:addMoveTips({text = "Đang Đột Tiến!"});
        else
            if btnTag == 201 then--返回
                self:back()
            elseif btnTag == 101 then--突進
                local function fightResponseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    local reward = data:getNodeWithKey("reward")
                    -- cclog("data = " .. data:getFormatBuffer())
                    self.live_data = json.decode(data:getNodeWithKey("active_forever"):getFormatBuffer())
                    self:getCurrLevel()
                    if self.back_curr_level ~= self.curr_level then
                        game_util:rewardTipsByJsonData(reward);
                        self.is_anim = true
                        self.showPageIndex = 1
                        self:refreshUi()
                    else
                        game_util:addMoveTips({text = "Đã đột tiến đến tầng cao nhất"});
                    end
                end
                local level = game_data:getUserStatusDataByKey("level") or 1
                local vip_level = game_data:getVipLevel();
                if level >= 30 or vip_level > 0 then
                    if self.clear_flag == true then
                        game_util:addMoveTips({text = "Bạn đã qua ải, xin chờ mở lần sau~"});
                    else
                        --跳轉到戰鬥
                        network.sendHttpRequest(fightResponseMethod,game_url.getUrlForKey("auto_forever_fight"), http_request_method.GET, {},"auto_forever_fight")
                    end 
                else
                    game_util:addMoveTips({text = "Chức năng Đột tiến cần cấp 30 hoặc VIP 1"});
                end
            elseif btnTag == 102 then--戰鬥
                game_data:setUserStatusDataBackup()
                local function fightResponseMethod(tag,gameData)
                    game_data:setBattleType("game_activity_live");
                    local data = gameData:getNodeWithKey("data")
                    local stageTableData = {name = "Thử Thách Sinh Tồn tầng" .. self.curr_level,step = 1,totalStep = 1}
                    --傳背景圖
                    local backImgCfg = self.liveCfg:getNodeWithKey(tostring(self.curr_level))
                    local imgName = backImgCfg:getNodeWithKey("background"):toStr();
                    game_scene:enterGameUi("game_battle_scene",{gameData = gameData,stageTableData=stageTableData,backGroundName=imgName});
                end
                if self.clear_flag == true then
                    game_util:addMoveTips({text = "Bạn đã qua ải, xin chờ mở lần sau~"});
                else
                    local params = {}
                    params.level = self.curr_level
                    --跳轉到戰鬥
                    network.sendHttpRequest(fightResponseMethod,game_url.getUrlForKey("forever_fight"), http_request_method.GET, params,"forever_fight")
                end
            elseif btnTag == 200 then--查看獎勵
                local page = math.floor((self.curr_level - 1) / 5) + 1
                local t_params =
                {
                    openType = 3,
                    page = page,
                }
                game_scene:addPop("game_reward_pop",t_params)
            elseif btnTag == 11 then--陣型
                game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_live"});
                self:destroy();
            elseif btnTag == 12 then--背包
                game_scene:enterGameUi("game_hero_list",{gameData = nil,openType = "game_activity_live",showIndex= 1});
                self:destroy();
            elseif btnTag == 103 then--排行榜
                local function responseMethod(tag,gameData)
                    if gameData then
                        game_scene:enterGameUi("game_new_rank",{gameData = gameData,index = 8})
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_top"), http_request_method.GET, nil,"active_top",true,true)
                -- local ui_all_rank = require("game_ui.ui_all_rank")
                -- ui_all_rank.enterAllRankByRankName( "active_top" )

                -- local function responseMethod(tag,gameData)
                --     local data = gameData:getNodeWithKey("data")
                --     cclog("data = " .. data:getFormatBuffer())
                --     game_scene:enterGameUi("game_live_rank",{gameData = json.decode(data:getFormatBuffer())})
                -- end
                -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_top"), http_request_method.GET, nil,"active_top")
            elseif btnTag == 100 then--裝備
                game_scene:enterGameUi("equipment_list",{gameData = nil,openType = "game_activity_live",showIndex= 1});
                self:destroy();
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_live.ccbi");

    self.levels_table = ccbNode:nodeForName("levels_table")
    self.bar_node = ccbNode:nodeForName("bar_node")
    self.time_label = ccbNode:labelTTFForName("time_label")
    self.revival_label = ccbNode:labelTTFForName("revival_label")
    self.btn_onrush = ccbNode:controlButtonForName("btn_onrush")
    self.btn_fight = ccbNode:controlButtonForName("btn_fight")
    self.enemy_node = ccbNode:nodeForName("enemy_node")
    self.reward_node = ccbNode:nodeForName("reward_node")
    self.level_node = ccbNode:nodeForName("level_node")
    self.point_sprite = ccbNode:spriteForName("point_sprite")
    self.progress_sprite = ccbNode:scale9SpriteForName("progress_sprite")
    self.history_label = ccbNode:labelTTFForName("history_label")
    self.max_level = ccbNode:labelBMFontForName("max_level")
    self.onrush_level = ccbNode:labelBMFontForName("onrush_level")

    self.box_table = {}
    for i=1,10 do
        self.box_table[i] = ccbNode:spriteForName("box_" .. i)
    end

    game_util:setControlButtonTitleBMFont(self.btn_onrush)
    game_util:setControlButtonTitleBMFont(self.btn_fight)

    return ccbNode;
end

--[[
    設置圖片數字
]]
function game_activity_live.createNumIcon(self,num,node)
    node:removeAllChildrenWithCleanup(true);
    if num >= 10 and num < 100 then
        local high = math.floor(num / 10)
        local low = math.floor(num % 10)

        local num_1 = CCSprite:createWithSpriteFrameName("vip_num_" .. high .. ".png")
        local num_2 = CCSprite:createWithSpriteFrameName("vip_num_" .. low .. ".png")

        num_1:setAnchorPoint(ccp(0.5,0.5))
        num_2:setAnchorPoint(ccp(0.5,0.5))

        num_1:setPosition(ccp(-10,0))
        num_2:setPosition(ccp(10,0))

        node:addChild(num_1,10)
        node:addChild(num_2,10)
    elseif num >= 100 then
        local table = {1,0,0}
        local x = math.floor(num / 100)
        local y = math.floor((num - x*100) / 10)
        local z = num - x*100 - y*10
        table[1] = x
        table[2] = y
        table[3] = z
        for i=1,3 do
            local num_sprite = CCSprite:createWithSpriteFrameName("vip_num_" .. table[i] .. ".png")
            num_sprite:setAnchorPoint(ccp(0.5,0.5))
            num_sprite:setPosition(ccp(-15+(i-1)*20,0))
            node:addChild(num_sprite,10)
        end
    else
        local num_sprite = CCSprite:createWithSpriteFrameName("vip_num_" .. num .. ".png")
        num_sprite:setAnchorPoint(ccp(0.5,0.5))
        num_sprite:setPosition(ccp(0,0))
        node:addChild(num_sprite,10)
    end
end
--[[
    創建tableview
]]
function game_activity_live.refreshTableView(self)
    self.levels_table:removeAllChildrenWithCleanup(true)
    self.tableView = self:createTableView(self.levels_table:getContentSize())
    -- textTableTemp:setScrollBarVisible(false)
    self.tableView:setTouchEnabled(false)
    self.levels_table:addChild(self.tableView,10,10);
end
--[[--
    刷新ui
]]
function game_activity_live.refreshUi(self)
    self:refreshTableView()
    self:refreshEnemyReward(self.curr_level - 1)
    self.time_label:setString("")

    local function timeOverCallFun()
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local live_data = json.decode(data:getNodeWithKey("active_forever"):getFormatBuffer())
            game_scene:enterGameUi("game_activity_live",{liveData = live_data})
            self:destroy()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
    end

    local timeLabel = game_util:createCountdownLabel(self.live_data.expire,timeOverCallFun)
    timeLabel:setAnchorPoint(ccp(0.5,0.5))
    timeLabel:setPosition(ccp(0,0))
    self.time_label:removeAllChildrenWithCleanup(true)
    self.time_label:addChild(timeLabel)

    self.revival_label:setString((3 - self.live_data.forever_fails))

    local max_level = self.live_data.forever_max_step
    if max_level < 1 then
        max_level = 1
    end
    local combat = game_util:getCombatValue()
    self.max_level:setString(tostring(max_level))
    local onrush_max_level = max_level - 10  
    if onrush_max_level < 1 then
        onrush_max_level = 1
    end
    self.onrush_max_level = onrush_max_level
    -- for i=1,max_level do
    --     local itemCfg = self.liveCfg:getNodeWithKey(tostring(i))
    --     local fight_num = itemCfg:getNodeWithKey("fight_num"):toInt()--掃蕩分數
    --     if combat > fight_num then
    --         onrush_max_level = i
    --     end
    -- end
    self.onrush_level:setString(tostring(onrush_max_level))
end

--[[
    創建活動滑動列表
]]--
function game_activity_live.createTableView( self,viewSize )
    local activityCount = self.liveCfg:getNodeCount()
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 5; --列
    local page = math.floor((self.curr_level - 1) / 5) + 1
    if self.is_anim == false then
        params.showPageIndex = page--當前頁
    else
        params.showPageIndex = self.showPageIndex--突進過去
    end
    params.showPoint = false
    params.totalItem = activityCount;
    params.direction = kCCScrollViewDirectionVertical;--縱向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create()            
            ccbNode:openCCBFile("ccb/ui_live_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            
            local hero_node = ccbNode:nodeForName("hero_node")
            local level_label = ccbNode:labelBMFontForName("level_label")
            local select_sprite = ccbNode:scale9SpriteForName("select_sprite")
            local sprite_break = ccbNode:spriteForName("sprite_break")
            level_label:setString(tostring(index + 1))
            local itemCfg = self.liveCfg:getNodeWithKey(tostring(index+1))
            local animation = itemCfg:getNodeWithKey("animation"):toStr()

            local icon = game_util:createImgByName("image_" .. animation,0,false)
            if icon then
                hero_node:removeAllChildrenWithCleanup(true)
                icon:setScale(0.8)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,10))
                hero_node:addChild(icon,10)
            end
            if index < self.curr_level - 1 then
                if self.is_anim == false then
                    sprite_break:setVisible(true)
                    if icon then
                        icon:setColor(ccc3(151,151,151))
                    end
                else
                    self:onRushAnim(index,sprite_break,icon,tableView)
                end
            elseif index == self.curr_level - 1 then
                sprite_break:setVisible(false)
                if icon then
                    icon:setColor(ccc3(255,255,255))
                end
            else
                sprite_break:setVisible(false)
                if icon then
                    icon:setColor(ccc3(0,0,0))
                end
            end
            if index + 1 == self.curr_level then--當前關
                select_sprite:setSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("live_open.png"));
            else
                select_sprite:setSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("live_closed.png"));
            end
            if self.clear_flag == true then
                sprite_break:setVisible(true)
                if icon then
                    icon:setColor(ccc3(78,76,79))
                end
                select_sprite:setSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("live_closed.png"));
            end
            select_sprite:setPreferredSize(CCSizeMake(60,60));
            if (index+1)%5 == 0 then
                select_sprite:setVisible(false);
                local tempSpr = CCSprite:createWithSpriteFrameName("live_boss_icon_bg.png");
                hero_node:addChild(tempSpr,9);
                local tempSpr = CCSprite:createWithSpriteFrameName("live_boss_icon_bg2.png");
                tempSpr:setPosition(ccp(0,-30))
                hero_node:addChild(tempSpr,11);
            end
        end
        return cell
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
            self:refreshEnemyReward(index,2)
        end
    end
    local tempTable = TableViewHelper:createGallery3(params);
    if self.is_anim == true and self.showPageIndex ~= 1 then
        tempTable:setPosition(ccp(viewSize.width,0))
        tempTable:runAction(CCMoveTo:create(0.5,ccp(0,0)))
    end
    return tempTable
end
--[[
    突進動畫
]]
function game_activity_live.onRushAnim(self,index,sprite_break,icon,tableView)
    -- local tempTable = tolua.cast(self.levels_table:getChildByTag(10),"TableView")
    local tempTable = tableView
    local contentSize = tempTable:getContentSize()
    local viewSize = tempTable:getViewSize()
    local size = self.levels_table:getContentSize()
    local scaleTime = 0.5
    local function setScrollPos()
        self.showPageIndex = self.showPageIndex + 1
        self:refreshTableView()
    end 
    local function setOver(node)
        game_sound:playUiSound("stamp")
        icon:setColor(ccc3(151,151,151))
        if index + 1 < self.onrush_max_level then
            self.onrush_flag = true
        else
            self.onrush_flag = false
        end
    end
    local function setSpiteVisible(sprite)
        sprite_break:setVisible(true)
    end
    local setOver = CCCallFuncN:create(setOver)
    local setSpiteVisible = CCCallFuncN:create(setSpiteVisible)
    local setScrollPos = CCCallFuncN:create(setScrollPos)
    sprite_break:setScale(4)
    sprite_break:setVisible(false)
    local showIndex = index + 1
    local arr = CCArray:create();
    local delayIndex = index % 5
    arr:addObject(CCDelayTime:create(0.5 + delayIndex*scaleTime));
    arr:addObject(setSpiteVisible)
    arr:addObject(CCScaleBy:create(scaleTime,0.25));
    arr:addObject(setOver);
    if showIndex % 5 == 0 and index > 0 then
        arr:addObject(setScrollPos);
    end
    sprite_break:runAction(CCSequence:create(arr));
end
--[[
    創建獎勵
]]
function game_activity_live.refreshEnemyReward(self,index,operaType)
    operaType = operaType or 1
    local itemCfg = self.liveCfg:getNodeWithKey(tostring(index+1))
    
    local fight = itemCfg:getNodeWithKey("fight"):toStr()--陣型

    local fight_num = itemCfg:getNodeWithKey("fight_num"):toInt()--掃蕩分數
    local reward = itemCfg:getNodeWithKey("reward")

    if operaType == 1 then
        self:createNumIcon(index+1,self.level_node)
        cclog("curr_level ============= " .. index+1)
    end
    -- local enemy_detail_cfg = getConfig(game_config_field.enemy_detail);
    -- self.mapConfig = getConfig(game_config_field.map_fight);
    self.mapConfig = self.live_data.map_fight or {}
    cclog("self.live_data.map_fight ============ " .. tostring(self.live_data.map_fight) .. " ; fight == " .. fight)
    local enemy_detail_cfg = self.live_data.enemy_detail or {}
    local fightCfg = self.mapConfig[fight]
    local function onMainBtnClick( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local positionItem = fightCfg["position" .. btnTag]
        local enemy_detail_item_cfg = enemy_detail_cfg[tostring(positionItem[1])]
        local posX,posY = tagNode:getPosition()
        local tempPos = tagNode:getParent():convertToWorldSpace(ccp(posX,posY+65))
        game_scene:addPop("game_enemy_info_pop",{itemCfg = enemy_detail_item_cfg,pos = tempPos,openType = 2})
    end

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemData = json.decode(reward:getNodeAt(btnTag-1):getFormatBuffer())
        game_util:lookItemDetal(itemData)
    end
    self.reward_node:removeAllChildrenWithCleanup(true);
    self.enemy_node:removeAllChildrenWithCleanup(true)
    for i=1,reward:getNodeCount() do
        local itemData = reward:getNodeAt(i-1)
        local reward_icon,name,count = game_util:getRewardByItem(itemData,true);

        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        button:setTag(i)
        button:setOpacity(0)
        if reward_icon then
            reward_icon:setAnchorPoint(ccp(0.5,0.5))
            reward_icon:setScale(0.8)
            reward_icon:setPosition(ccp((i-1) * 53,0))
            
            self.reward_node:addChild(reward_icon)

            button:setAnchorPoint(ccp(0.5,0.5))
            button:setPosition(ccp((i-1) * 53,0))
            self.reward_node:addChild(button);
            if count then
                local label = game_util:createLabelTTF({text = "×"..count,color = ccc3(250,250,250),fontSize = 12})

                label:setAnchorPoint(ccp(0.5,0.5))
                label:setPosition(ccp((i-1) * 53,-20))
                self.reward_node:addChild(label)
            end
        end
    end

    if fightCfg then
        local positionItem,idCount,tempIcon
        local posIndex = 0;
        for j=1,5 do
            positionItem = fightCfg["position" .. j] or {}
            idCount = #positionItem
            if idCount > 0 then
                local enemy_detail_item_cfg = enemy_detail_cfg[tostring(positionItem[1])]
                local tempIcon = game_util:createIconByName(tostring(enemy_detail_item_cfg.img))

                local button = game_util:createCCControlButton("public_weapon.png","",onMainBtnClick)
                button:setTag(j)
                button:setOpacity(0)

                if tempIcon then
                    tempIcon:setScale(0.75);
                    tempIcon:setAnchorPoint(ccp(0.5,0.5))
                    tempIcon:setPosition(ccp((j-1) * 53,0))
                    self.enemy_node:addChild(tempIcon);

                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition(ccp((j-1) * 53,0))
                    self.enemy_node:addChild(button);
                end
                posIndex = posIndex + 1;
            end
        end
    end
    --[[
    --進度條
    local page = math.floor((self.curr_level - 1) / 5) + 1
    for i=1,10 do
        if i < math.floor(page/2) then
            self.box_table[i]:setVisible(false)
        end
    end
    local doubleCount = math.floor((page - 1) / 2)
    local singelCount = math.floor((page - 1) % 2) + doubleCount
    -- cclog("doubleCount = " .. doubleCount)
    -- cclog("singelCount = " .. singelCount)
    local dw = doubleCount * 26 + singelCount * 19
    self.point_sprite:setPosition(ccp(2+dw,13))
    if page == 1 then
        self.progress_sprite:setVisible(false)
    else
        self.progress_sprite:setVisible(true)
        self.progress_sprite:setPreferredSize(CCSizeMake(dw,12));
    end
    if self.clear_flag == true then
        self.point_sprite:setPosition(ccp(2+dw+26,13))
        self.progress_sprite:setPreferredSize(CCSizeMake(dw+26,12));
    end
    ]]--
end
--[[--
    初始化
]]
function game_activity_live.init(self,t_params)
    t_params = t_params or {};
    self.live_data = t_params.liveData
    -- cclog("self.live_data = " .. json.encode(self.live_data))
    self.liveCfg = getConfig(game_config_field.active_fight_forever);
    self.cfg_max_level = self.liveCfg:getNodeCount();--配置裡的最大層數
    self.mapConfig = getConfig(game_config_field.map_fight);
    self.is_anim = false
    self.showPageIndex = 1
    self:getCurrLevel()
    self.back_curr_level = self.curr_level
    self.onrush_flag = false
end
--[[
    得到當前關卡
]]
function game_activity_live.getCurrLevel(self)
    self.curr_level = 1
    if #self.live_data.done == 0 then
        self.curr_level = 1
    else
        self.curr_level = self.live_data.done[#self.live_data.done] + 1
        if self.curr_level > self.cfg_max_level then
            self.curr_level = self.cfg_max_level
            self.clear_flag = true
        end
    end
    -- self.curr_level = 88
end
--[[--
    創建ui入口並初始化數據
]]
function game_activity_live.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_activity_live;