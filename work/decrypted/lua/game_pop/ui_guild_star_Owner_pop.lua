local ui_guild_star_Owner_pop = {
    ccbNode = nil,
    rob_btn = nil,
    m_img_node = nil,
    m_lb_name = nil,
    m_lb_guild = nil,
    m_combat_lb = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_tGameData = nil,
    m_enterType = nil,
    isMine = nil,
    pos = nil,
} 

function ui_guild_star_Owner_pop:destroy()
    cclog("-------- ui_guild_star_Owner_pop destroy --------")
    self.ccbNode = nil;
    self.rob_btn = nil;
    self.m_img_node = nil;
    self.m_lb_name = nil;
    self.m_lb_guild = nil;
    self.m_combat_lb = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_tGameData = nil;
    self.m_enterType = nil;
    self.isMine = nil;
    self.pos = nil;
end



function ui_guild_star_Owner_pop:back()
	if self.callback then
		self.callback()
	end
	game_scene:removePopByName("ui_guild_star_Owner_pop")
    
end


function ui_guild_star_Owner_pop:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 1 then
			self:back()
		else
            local posX,index = game_data:getGuildStarPos()
            local function responseMethod( tag,gameData )
                if gameData then
                    local data = gameData:getNodeWithKey("data")
                    local find_shop = data:getNodeWithKey("find_shop"):toStr()
                    if find_shop == "true" then
                        local shop_id_list = data:getNodeWithKey("shop_id_list")
                        local shop_type = data:getNodeWithKey("shop_type"):toStr()
                        game_data:setGuildStarShopMsg(shop_id_list,shop_type)
                    else
                        game_data:setGuildStarShopMsg(nil,nil)
                    end
                    game_scene:enterGameUi("ui_guild_star_battle_scene",{gameData = gameData,enterType = index,posX = posX})
                end
            end
            local params = {}
            params.mountain_id = self.m_enterType
            params.pos = self.m_enterType == 1 and self.pos or 100
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_battle"), http_request_method.GET, params,"guild_robbery_battle")
		end
	end
	local ccbNode =  luaCCBNode:create();
	self.ccbNode = ccbNode
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_guild_Star_Owner.ccbi")
    ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
    self.rob_btn = ccbNode:controlButtonForName("rob_btn")
    self.rob_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)

    self.m_img_node = ccbNode:nodeForName("m_img_node")
    self.m_lb_name = ccbNode:nodeForName("m_lb_name")
    self.m_lb_guild = ccbNode:nodeForName("m_lb_guild")
    self.m_combat_lb = ccbNode:labelTTFForName("m_combat_lb")

    self.m_root_layer = ccbNode:layerForName("m_root_layer");
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode
	return ccbNode
end


function ui_guild_star_Owner_pop:createZhenRongList(viewSize,data)
    local character_detail_cfg = getConfig("character_detail")
    local heroCfg = nil
    local team = data or {}
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

function ui_guild_star_Owner_pop:createNpcZhenRongList(viewSize,data)
    local character_detail_cfg = getConfig("character_detail")
    local heroCfg = nil
    local team = data or {}
    local showData = {}
    for k,v in pairs(team) do
        if v.c_id then
            table.insert(showData,v)
        end
    end
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

function ui_guild_star_Owner_pop:refreshTableView()
    for i=1,3 do
        local m_list_node = self.m_ccbNode:nodeForName("m_card_node" .. i)
        m_list_node:removeAllChildrenWithCleanup(true)
        local tableView
        if self.m_tGameData["server"] == "NPC" then
            local cardTab = self.m_tGameData.alignment_info
            tableView = self:createNpcZhenRongList(m_list_node:getContentSize(),cardTab)
        else
            local cardTab = self.m_tGameData.alignment_info[i] or self.m_tGameData.alignment_info[tostring(i)]
            tableView = self:createZhenRongList(m_list_node:getContentSize(),cardTab)
        end
        if tableView then
            m_list_node:addChild(tableView) 
        end
    end
end

function ui_guild_star_Owner_pop:refreshUi()
	self:refreshTableView()
    local animName = nil;
    self.m_img_node:removeAllChildrenWithCleanup(true)
    local roleId = self.m_tGameData.role
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
    if itemCfg then
        animName = itemCfg:getNodeWithKey("animation"):toStr();
    else
        animName = "role_soldier";
    end
    local tempAnim = game_util:createPlayerRoleAnimNew(animName,1)
    tempAnim:setScale(0.8)
    tempAnim:setAnchorPoint(ccp(0.5,0))
    self.m_img_node:addChild(tempAnim)

    local name = self.m_tGameData.name
    local tempLb1 = game_util:createLabelTTF({text = name,color = ccc3(120,255,255),fontSize = 9})
    -- self.m_lb_name:setString("")
    tempLb1:setAnchorPoint(ccp(0.5,0.5))
    -- tempLb1:setPosition(ccp)
    self.m_lb_name:removeAllChildrenWithCleanup(true)
    self.m_lb_name:addChild(tempLb1)

    local guild_name = self.m_tGameData.guild_name
    local tempLb2 = game_util:createLabelTTF({text = guild_name,color = ccc3(120,255,255),fontSize = 9})
    tempLb2:setAnchorPoint(ccp(0.5,0.5))
    -- self.m_lb_guild:setString("")
    self.m_lb_guild:removeAllChildrenWithCleanup(true)
    self.m_lb_guild:addChild(tempLb2)

    self.m_combat_lb:setString("Lực chiến: " .. self.m_tGameData.combat)

    if self.isMine then
        self.rob_btn:setVisible(false)
    else
        self.rob_btn:setVisible(true)
    end
end


function ui_guild_star_Owner_pop:init(t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_server_pyramid_n_res.plist");

	t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_enterType = t_params.enterType or 1
    local uid = game_data:getUserStatusDataByKey("uid") or ""
    self.isMine = (uid == self.m_tGameData.uid)
    self.pos = t_params.pos
end


function ui_guild_star_Owner_pop:create(t_params)
	local scene = CCScene:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end
return ui_guild_star_Owner_pop
