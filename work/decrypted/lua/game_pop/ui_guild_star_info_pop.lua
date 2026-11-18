--- 星系霸主   坑位信息
local ui_guild_star_info_pop = {
    table_view_node = nil,
    name_lable = nil,
    lv_lable = nil,
    qufu_lable = nil,
    combat_lable = nil,
    union_lable = nil,
    m_sp_node = nil,
    m_sprite_lucksign = nil,
    m_root_layer = nil,
    rob_btn = nil,
    m_close_btn = nil,
    m_chexiao_btn = nil,
    m_chexiao_btn = nil,
    chousha_sp = nil,
    m_buff_node = nil,
    m_buff_label1 = nil,
    m_buff_label2 = nil,
    isEnemy = nil,
    m_ccbNode = nil,
    m_thanos_item = nil,
    m_tGameData = nil,
    isLucky = nil,
    isEnemy = nil,
    mountain_id = nil,
    isMine = nil,
};

--[[--
    销毁
]]
function ui_guild_star_info_pop:destroy()
    -- body
    cclog("-----------------ui_guild_star_info_pop destroy-----------------");
    self.table_view_node = nil;
    self.name_lable = nil;
    self.lv_lable = nil;
    self.qufu_lable = nil;
    self.combat_lable = nil;
    self.union_lable = nil;
    self.m_sp_node = nil;
    self.m_sprite_lucksign = nil;
    self.m_root_layer = nil;
    self.rob_btn = nil;
    self.m_close_btn = nil;
    self.m_chexiao_btn = nil;
    self.m_chexiao_btn = nil;
    self.chousha_sp = nil;
    self.m_buff_node = nil;
    self.m_buff_label1 = nil;
    self.m_buff_label2 = nil;
    self.isEnemy = nil;
    self.m_ccbNode = nil;
    self.m_thanos_item = nil;
    self.m_tGameData = nil;
    self.isLucky = nil;
    self.isEnemy = nil;
    self.mountain_id = nil;
    self.isMine = nil;
end
--[[--
    返回
]]
function ui_guild_star_info_pop:back(type)
    game_scene:removePopByName("ui_guild_star_info_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_guild_star_info_pop:createUi()
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog(btnTag,"-------------btnTag" .. btnTag .. "-------------")
        if btnTag == 1 then
            self:back();
        elseif btnTag == 5 then
            local function responseMethod(  tag,gameData )
                game_scene:addPop("game_guild_Star_zhenxing",{gameData = gameData,mountain_id = self.mountain_id,pos = self.pos})
            end
        	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_formation_info"),http_request_method.GET,nil,"guild_robbery_formation_info")
        elseif btnTag == 6 then
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
    self.m_chexiao_btn:setVisible(false)
    self.chousha_sp = ccbNode:spriteForName("chousha_sp")
    self.m_buff_node = ccbNode:nodeForName("m_buff_node")
    self.m_buff_node:setVisible(false)
    self.m_buff_label1 = ccbNode:labelTTFForName("m_buff_label1")
    self.m_buff_label2 = ccbNode:labelTTFForName("m_buff_label2")
    if self.isEnemy then
        self.chousha_sp:setVisible(true)
    else
        self.chousha_sp:setVisible(false)
    end
    if self.isMine then
        self.rob_btn:setVisible(false)
    else
        self.rob_btn:setVisible(true)
    end
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-7)
    self.rob_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-7)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then

        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-6,true)
    self.m_root_layer:setTouchEnabled(true)
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

function ui_guild_star_info_pop:refreshUi()
    self.qufu_lable:setString(self.m_tGameData["server"] or "")
    self.name_lable:setString(self.m_tGameData["name"] or "")
    self.lv_lable:setString(self.m_tGameData["level"] or "")
    self.combat_lable:setString(self.m_tGameData["combat"] or "")
    self.union_lable:setString(self.m_tGameData["guild_name"] or "")
    self.m_sprite_lucksign:setVisible(self.isLucky)
    local roleId = self.m_tGameData.role or math.random(1, 5)
    local img = self:createBigImg(roleId)
    img:setAnchorPoint(ccp(0.5, 0.5))
    img:setPositionX(self.m_sp_node:getContentSize().width * 0.5)
    img:setScale(0.4)
    self.m_sp_node:addChild(img)
    self.table_view_node:removeAllChildrenWithCleanup(true)
    if self.m_tGameData["server"] == "NPC" then
        self.table_view_node:addChild(self:createNpcZhenRongList(self.table_view_node:getContentSize()))
    else
        self.table_view_node:addChild(self:createZhenRongList(self.table_view_node:getContentSize()))
    end

    local item1 = json.decode(self.m_thanos_item:getNodeWithKey("1"):getFormatBuffer())
    local item2 = json.decode(self.m_thanos_item:getNodeWithKey("2"):getFormatBuffer())

    local protect_remaining_time = self.m_tGameData.protect_remaining_time or 0
    local reduce_times = self.m_tGameData.reduce_times or 0
    local str1 = item1.effect
    local str2 = item2.effect
    str1 = string.gsub(str1,"x",tostring(math.floor(protect_remaining_time/60)));
    str2 = string.gsub(str2,"x",tostring(reduce_times*item2.value));

    if protect_remaining_time > 0 or reduce_times > 0 then
        self.m_buff_node:setVisible(true)
    else
        self.m_buff_node:setVisible(false)
    end
    if protect_remaining_time > 0 and reduce_times > 0 then
        self.m_buff_label1:setPositionY(5)
        self.m_buff_label2:setPositionY(-5)
        self.m_buff_label1:setVisible(true)
        self.m_buff_label2:setVisible(true)
        self.m_buff_label1:setString(str1)
        self.m_buff_label2:setString(str2)
    else
        self.m_buff_label1:setPositionY(0)
        self.m_buff_label1:setVisible(true)
        self.m_buff_label2:setVisible(false)
        if protect_remaining_time > 0 then
            self.m_buff_label1:setString(str1)
        elseif reduce_times > 0 then
            self.m_buff_label1:setString(str2)
        end
    end
end

function ui_guild_star_info_pop:createBigImg(roleId)
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
    return game_util:createPlayerBigImgByCfg(itemCfg);
end

function ui_guild_star_info_pop:createZhenRongList(viewSize)
    local character_detail_cfg = getConfig("character_detail")
    local heroCfg = nil
    local team = self.m_tGameData.alignment_info
    local showData = {}
    for k,v in pairs(team) do
        if v.c_id then
            table.insert(showData,v)
        end
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
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 8;
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
                game_util:addMoveTips({text = "Lỗi thông tin thẻ!"})
            end
        end
    end
    return TableViewHelper:create(params) 
end

function ui_guild_star_info_pop:createNpcZhenRongList(viewSize)
    local character_detail_cfg = getConfig("character_detail")
    local heroCfg = nil
    local team = self.m_tGameData.alignment_info
    local showData = {}
    for k,v in pairs(team) do
        if v.c_id then
            table.insert(showData,v)
        end
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
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 8;
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
            if itemData and itemData.c_id then
                heroCfg = character_detail_cfg:getNodeWithKey(tostring(itemData.c_id));
                if itemData and heroCfg then
                    headIconSpr = game_util:createCardIconByCfg(heroCfg,heroCfg);
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
            end
        end
    end
    return TableViewHelper:create(params) 
end

--[[--
    初始化
]]
function ui_guild_star_info_pop:init(t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_server_pyramid_n_res.plist");
    self.m_thanos_item = getConfig(game_config_field.thanos_items)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
        self.isLucky = t_params.isLucky or false
        self.isEnemy = t_params.isEnemy or false
    end
    self.mountain_id = t_params.mountain_id
    self.pos = t_params.pos
    local uid = game_data:getUserStatusDataByKey("uid") or ""
    self.isMine = (uid == self.m_tGameData.uid)
end

--[[--
    创建ui入口并初始化数据
]]
function ui_guild_star_info_pop:create(t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return ui_guild_star_info_pop;