--- 敌人信息弹出
local game_server_guildbattle_enemyInfo_pop = {
    table_view_node = nil,
    m_ship_sp = nil,
    name_lable = nil,
    lv_lable = nil,
    qufu_lable = nil,
    combat_lable = nil,
    union_lable = nil,
    m_chexiao_btn = nil,
    building_id = nil,
    m_label_shiqi = nil,
    m_isEminyFlag = nil,

};

--[[--
    销毁
]]
function game_server_guildbattle_enemyInfo_pop:destroy()
    -- body
    cclog("-----------------game_server_guildbattle_enemyInfo_pop destroy-----------------");
    self.table_view_node = nil;
    self.m_ship_sp = nil;
    self.name_lable = nil;
    self.lv_lable = nil;
    self.qufu_lable = nil;
    self.combat_lable = nil;
    self.union_lable = nil;
    self.building_id = nil;
    self.m_label_shiqi = nil;
    self.m_isEminyFlag = nil;
end
--[[--
    返回
]]
function game_server_guildbattle_enemyInfo_pop:back(type)
    game_scene:removePopByName("game_server_guildbattle_enemyInfo_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_server_guildbattle_enemyInfo_pop:createUi()
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog(btnTag,"-------------btnTag" .. btnTag .. "-------------")
        if btnTag == 1 then
            self:back();
        elseif btnTag == 5 then

            local function responseMethod( tag,gameData )
                local building_id = self.building_id
                game_scene:addPop("game_server_guildbattle_point_pop",{gameData = gameData,building_id = building_id, isOnly = true, isEnemy = true}) 
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_formation_info"), http_request_method.GET, nil,"new_guild_fight_formation_info")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_Star_ship_pop.ccbi");
    self.table_view_node=ccbNode:nodeForName("table_view_node")
    self.name_lable = ccbNode:labelTTFForName("name_lable")
    self.lv_lable = ccbNode:labelTTFForName("lv_lable")
    self.qufu_lable = ccbNode:labelTTFForName("qufu_lable")
    self.combat_lable = ccbNode:labelTTFForName("combat_lable")
    self.union_lable = ccbNode:labelTTFForName("union_lable") 
    self.m_sp_node = ccbNode:nodeForName("L_sp_node")
    self.m_sprite_lucksign = ccbNode:spriteForName("m_sprite_lucksign")   
    self.m_root_layer = ccbNode:layerForName('m_root_layer')
    self.rob_btn = ccbNode:controlButtonForName("rob_btn")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_chexiao_btn = ccbNode:controlButtonForName("m_chexiao_btn")
    self.chousha_sp = ccbNode:spriteForName("chousha_sp")
    if self.isEnemy then
        self.chousha_sp:setVisible(true)
    else
        self.chousha_sp:setVisible(false)
    end
    if self.isMine then
        self.rob_btn:setVisible(false)
        self.m_chexiao_btn:setVisible(true)
    else
        self.rob_btn:setVisible(true)
        self.m_chexiao_btn:setVisible(false)
    end
    self.m_label_shiqi = ccbNode:labelTTFForName("m_label_shiqi")
    self.m_label_shiqi:setVisible(true)
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    self.rob_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    self.m_chexiao_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    if self.m_isEminyFlag then
        self.rob_btn:setVisible(true)
    else
        self.rob_btn:setVisible(false)
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then

        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-2,true)
    self.m_root_layer:setTouchEnabled(true)
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

function game_server_guildbattle_enemyInfo_pop:refreshUi()
    self.qufu_lable:setString(self.m_tGameData["building_info"]["server_name"] or "无")
    self.name_lable:setString(self.m_tGameData["building_info"]["name"] or "无")
    self.lv_lable:setString(self.m_tGameData["building_info"]["level"] or "无")
    self.combat_lable:setString(self.m_tGameData["building_info"]["combat"] or "无")
    self.union_lable:setString(self.m_tGameData["building_info"]["guild_name"] or "无")
    self.m_sprite_lucksign:setVisible(self.isLucky)
    local roleId = self.m_tGameData.role or math.random(1, 5)
    local img = self:createBigImg(roleId)
    img:setAnchorPoint(ccp(0.5, 0.5))
    img:setPositionX(self.m_sp_node:getContentSize().width * 0.5)
    img:setScale(0.4)
    self.m_sp_node:addChild(img)
    self.table_view_node:removeAllChildrenWithCleanup(true)
    if self.m_tGameData["building_info"].alignment_info then
        self.table_view_node:addChild(self:createZhenRongList(self.table_view_node:getContentSize()))
    end
    local owner_hot = self.m_tGameData["building_info"].owner_hot 
    if owner_hot then
        self.m_label_shiqi:setString("士气值：" .. owner_hot .. "%")
    else
        self.m_label_shiqi:setVisible(false)
    end
end

function game_server_guildbattle_enemyInfo_pop:createBigImg(roleId)
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
    return game_util:createPlayerBigImgByCfg(itemCfg);
end

function game_server_guildbattle_enemyInfo_pop:createZhenRongList(viewSize)
    local character_detail_cfg = getConfig("character_detail")
    local heroCfg = nil
    local team = self.m_tGameData["building_info"].alignment_info or {}
    local showData = {}
    if team and next(team) then
        for k,v in pairs(team) do
            if v.c_id then
                table.insert(showData,v)
            end
        end
    else
        return
    end
    -- cclog2(showData,"showData")
    local itemCount =game_util:getTableLen(showData)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    if itemCount > 5 then
        params.column = 5;
    else
        params.column = itemCount;
    end 
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 3;
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height/params.row);
    self.m_cellSize = itemSize
    self.m_cellCount = itemCount
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell();
        if cell == nil then 
            cell = CCTableViewCell:new()
            cell:autorelease();
        end
        if cell then  
            cell:removeAllChildrenWithCleanup(true)
            local itemData = showData[index + 1]
            -- cclog2(itemData,"itemCount------------")
            if itemData and itemData.c_id then
                heroCfg = character_detail_cfg:getNodeWithKey(itemData.c_id);
                -- cclog2(heroCfg,"heightfdnsajkfhbdbgndflskbhvdas" .. index + 1)
                if itemData and heroCfg then
                    headIconSpr = game_util:createCardIconByCfg(heroCfg,itemData);
                    if headIconSpr then
                        headIconSpr:setScale(0.8);
                        headIconSpr:setPosition(itemSize.width * 0.5, itemSize.height * 0.5);
                        cell:addChild(headIconSpr,1,1);

                        local node = headIconSpr:getChildByTag(1)
                        if node then
                            node:setVisible(false)
                        end

                        local sprBoard = CCSprite:createWithSpriteFrameName("ui_pyramid_n_kuang3.png")
                        if sprBoard then
                            sprBoard:setPosition(itemSize.width * 0.5, itemSize.height * 0.5)
                            sprBoard:setScale(0.8);
                            cell:addChild(sprBoard, 20, 20)
                        end
                    end
                end
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" then
            local itemData = showData[index + 1]
            if itemData then
                game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 3})
            else 
                game_util:addMoveTips({text = "卡片信息错误！"})
            end
        end
    end
    return TableViewHelper:create(params) 
end

--[[--
    初始化
]]
function game_server_guildbattle_enemyInfo_pop:init(t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_server_pyramid_n_res.plist");
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
        self.isMine = t_params.isMine or false
        self.isLucky = t_params.isLucky or false
        self.isEnemy = t_params.isEnemy or true
        if self.m_tGameData.is_same_guild == 1 then
            self.m_isEminyFlag = false
        else
            self.m_isEminyFlag = true
        end
    end
    self.building_id = 0 
    if t_params.building_id then
        self.building_id = t_params.building_id
    end
    
end

--[[--
    创建ui入口并初始化数据
]]
function game_server_guildbattle_enemyInfo_pop:create(t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_server_guildbattle_enemyInfo_pop;