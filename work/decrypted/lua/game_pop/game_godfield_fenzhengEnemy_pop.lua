
local game_godfield_fenzhengEnemy_pop = {
	m_enemy_node = nil,
	m_anim_node = nil,
	m_label_tab = nil,
    m_gameData = nil,
    m_ischanllge = nil,
    index = nil,
    callback = nil,
    callbackgameData = nil,
    is_win = nil,
};
--[[--
    销毁ui
]]
function game_godfield_fenzhengEnemy_pop.destroy(self)
    -- body
	self.m_enemy_node = nil;
	self.m_anim_node = nil;
	self.m_label_tab = nil;
    self.m_gameData = nil;
    self.m_ischanllge = nil;
    self.index = nil;
    self.callback = nil;
    self.callbackgameData = nil;
    self.is_win = nil;

end
--[[--
    返回
]]
function game_godfield_fenzhengEnemy_pop.back(self)
    if self.callback and type(self.callback) == "function" then
        if self.callbackgameData then
            self.callback(self.callbackgameData,self.is_win,self.index)
        end
    end
    game_scene:removePopByName("game_godfield_fenzhengEnemy_pop")
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_fenzhengEnemy_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 101 then -- 关闭
            self:back()
        elseif btnTag == 102 then  -- 挑战
            local function fightResponseMethod( tag,gameData)
                if gameData then
                    self.is_win = gameData:getNodeWithKey("data"):getNodeWithKey("is_win"):toStr()
                    local data = gameData:getNodeWithKey("data");
                    self.callbackgameData = json.decode(data:getFormatBuffer()) or {};
                    self:back()
                end
            end
            local params = {}
            params.foothold_id = self.index
            network.sendHttpRequest(fightResponseMethod,game_url.getUrlForKey("team_pk_boss_battle_v3"), http_request_method.GET, params,"team_pk_boss_battle_v3",true,true)
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_fenzheng_enemy_pop.ccbi");

    self.m_enemy_node = ccbNode:nodeForName("m_enemy_node")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_label_tab = {}
    local m_enemy_lab 
    for i=1,5 do
    	m_enemy_lab = ccbNode:labelTTFForName("m_enemy_lab" .. i)
    	self.m_label_tab[i] = m_enemy_lab
    end

    -- 本层阻止触摸传导下一层
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            return true;  
        end 
    end
    local layer = CCLayer:create()
    layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-6,true);
    layer:setTouchEnabled(true);
    m_root_layer:addChild(layer)

    -- 重置按钮出米优先级 防止被阻止
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 8);

    local m_challenge_btn = ccbNode:controlButtonForName("m_challenge_btn")
    m_challenge_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 8);
    if self.m_ischanllge == false then
        m_challenge_btn:setVisible(true)
    else
        m_challenge_btn:setVisible(true)
    end
    return ccbNode;
end



--[[--
    刷新ui
]]
function game_godfield_fenzhengEnemy_pop.refreshUi(self)
    local img = self:createBigImg(1)
        img:setScale(0.35)
        self.m_anim_node:addChild(img)
    if self.m_gameData then
        
        self.m_enemy_node:removeAllChildrenWithCleanup(true)
        local formatTableView = self:creatFormatTableView(self.m_enemy_node:getContentSize())
        if formatTableView then
            self.m_enemy_node:addChild(formatTableView, 0, 887)
        end
        self.m_label_tab[1]:setString(tostring(self.m_gameData.name))
        self.m_label_tab[2]:setString(tostring(self.m_gameData.server_name))
        self.m_label_tab[3]:setString(tostring(self.m_gameData.level))
        self.m_label_tab[4]:setString(tostring(self.m_gameData.combat))
        self.m_label_tab[5]:setString(tostring(self.m_gameData.guild_name))
    end
end

--[[--
    创建列表
]]
function game_godfield_fenzhengEnemy_pop.creatFormatTableView( self, viewSize )
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_server_pyramid_n_res.plist");


    local character_detail_cfg = getConfig("character_detail");
    local heroCfg = nil
    local showData = self.m_gameData.alignment_info 

    local itemCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 5;
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
                heroCfg = character_detail_cfg:getNodeWithKey(itemData.c_id);
                if itemData and heroCfg then
                    headIconSpr = game_util:createCardIconByCfg(heroCfg,itemData);
                    if headIconSpr then
                        local itemSize = headIconSpr:getContentSize()
                        headIconSpr:setScale(0.8);
                        headIconSpr:setPosition(itemSize.width * 0.5, itemSize.height * 0.5);
                        cell:addChild(headIconSpr,21,21);

                        local node = headIconSpr:getChildByTag(1)
                        if node then
                            node:setVisible(false)
                        end

                        local sprBoard = CCSprite:createWithSpriteFrameName("ui_pyramid_n_kuang3.png")
                        if sprBoard then
                            sprBoard:setPosition(itemSize.width * 0.5, itemSize.height * 0.5)
                            sprBoard:setScale(0.9);
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

--[[
    创建玩家大图
]]
function game_godfield_fenzhengEnemy_pop.createBigImg(self, roleId)
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    -- cclog("roleId ========================" .. tostring(roleId));
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
    return game_util:createPlayerBigImgByCfg(itemCfg);
end


--[[--
    初始化
]]
function game_godfield_fenzhengEnemy_pop.init(self,t_params)
    t_params = t_params or {}
    cclog2(t_params.isChallenge," === ")
    self.index = t_params.index
    self.m_ischanllge = t_params.isChallenge
    self.callback = t_params.callback
    local gameData = t_params.gameData
    if gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = gameData and gameData:getNodeWithKey("data")
        self.m_gameData = data and json.decode(data:getFormatBuffer()) or {}
    elseif  gameData and tolua.type(t_params.gameData) == "table" then
        self.m_gameData = gameData
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_fenzhengEnemy_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_fenzhengEnemy_pop;

