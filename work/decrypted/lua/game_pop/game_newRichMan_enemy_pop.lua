
--新大富翁敌人信息
local game_newRichMan_enemy_pop = {
    m_tGameData = nil,
    m_tGameData2 = nil,
	m_node_tableView = nil,
    m_node_hero = nil,
    m_select_index = nil,
    m_label_name = nil,
    m_label_server = nil,
    m_label_lv = nil,
    m_label_combat = nil,
    m_label_guild = nil,
    m_func_callback = nil,
   
};
--[[--
    销毁ui
]]
function game_newRichMan_enemy_pop.destroy(self)
    -- body
    cclog("-----------------game_newRichMan_enemy_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_tGameData2 = nil;
    self.m_node_tableView = nil;
    self.m_node_hero = nil;
    self.m_select_index = nil;
    self.m_label_name = nil;
    self.m_label_server = nil;
    self.m_label_lv = nil;
    self.m_label_combat = nil;
    self.m_label_guild = nil;
    self.m_func_callback = nil;
    
end
--[[--
    返回
]]
function game_newRichMan_enemy_pop.back(self,type)
    if self.m_func_callback then
        self:m_func_callback()
    end
	game_scene:removePopByName("game_newRichMan_enemy_pop")
    -- local function endCallFunc()
    --     self:destroy();
    -- end
    -- game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_newRichMan_enemy_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
       
        cclog2(btnTag,"btnTag ==== ")
        if btnTag == 1 then--返回
       		self:back()
        elseif btnTag == 2 then
            local function  responseMethod( tag, gameData )
                game_scene:addPop("game_newRichMan_formation_pop",{gameData = gameData, openType = "enemy",popCallBack = self.m_func_callback})
                self:back()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_formation_info"), http_request_method.GET, nil,"monopoly_formation_info")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_newRichMan_enemy_pop.ccbi");
  	self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")
    self.m_node_hero = ccbNode:nodeForName("m_node_hero")

  	self.m_label_name = ccbNode:labelTTFForName("m_label_name")
  	self.m_label_server = ccbNode:labelTTFForName("m_label_server")
  	self.m_label_lv = ccbNode:labelTTFForName("m_label_lv")
  	self.m_label_combat = ccbNode:labelTTFForName("m_label_combat")
  	self.m_label_guild = ccbNode:labelTTFForName("m_label_guild")

    local m_close_btn = ccbNode:controlButtonForName("m_btn_back")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    local m_btn_challenge = ccbNode:controlButtonForName("m_btn_challenge")
    m_btn_challenge:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

function game_newRichMan_enemy_pop.creatFormatTableView( self, viewSize )
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_server_pyramid_n_res.plist");


    local character_detail_cfg = getConfig("character_detail");
    local heroCfg = nil
    local showData = {}
    if next(self.m_tGameData.owner_info[1].alignment_info) then
        for k,v in pairs(self.m_tGameData.owner_info[1].alignment_info ) do
            if next(v) then
                table.insert(showData,v)
            end
        end
    end
    local itemCount = game_util:getTableLen(showData)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 5;
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 2;
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height/params.row);
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
                if heroCfg then
                else
                    local cfg = getConfig("monopoly_enemy");
                    heroCfg = cfg:getNodeWithKey(itemData.c_id);
                end
                -- cclog2(itemData,"itemData ==== ")
                -- cclog2(heroCfg,"heroCfg ==== ")
                if itemData  then
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

                        local sprBoard = CCSprite:createWithSpriteFrameName("monopoly_iconBg.png")
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
                if self.m_tGameData.owner_info[1].name == "npc" then
                else
                    game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 3})
                end
            end
        end
    end
    return TableViewHelper:create(params)
end


function game_newRichMan_enemy_pop.createHeroImg( self )
    local roleId = 1 --self.m_tGameData.role or math.random(1, 5)
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
    local img = game_util:createPlayerBigImgByCfg(itemCfg);
    
    img:setAnchorPoint(ccp(0.5, 0.5))
    img:setPositionX(self.m_node_hero:getContentSize().width * 0.5)
    img:setScale(0.4)
    self.m_node_hero:addChild(img)
end

function game_newRichMan_enemy_pop.refreshLabel( self )
    local name = "Trống"
    local server_name = "Trống"
    local level = "Trống"
    local guild_name = "Trống"
    local combat = "Trống"

    if next(self.m_tGameData.owner_info) then
        name = self.m_tGameData.owner_info[1].name or ""
        server_name = self.m_tGameData.owner_info[1].server_name or ""
        level = self.m_tGameData.owner_info[1].level or ""
        guild_name = self.m_tGameData.owner_info[1].guild_name or ""
        combat = self.m_tGameData.owner_info[1].combat or ""
    end
    self.m_label_name:setString(name)
    self.m_label_server:setString(server_name)
    self.m_label_lv:setString(level)
    self.m_label_combat:setString(combat)
    self.m_label_guild:setString(guild_name)

end
--[[--
    刷新ui
]]
function game_newRichMan_enemy_pop.refreshUi(self)
    self:createHeroImg()
    self:refreshLabel()
    self.m_node_tableView:removeAllChildrenWithCleanup(true)
    local viewSize = self.m_node_tableView:getContentSize()
    self.m_node_tableView:addChild(self:creatFormatTableView(viewSize)) 
	-- self:createFormationInfo(self.m_node_tableView)
	-- self:getFormationData()

end
--[[--
    初始化
]]
function game_newRichMan_enemy_pop.init(self,t_params)
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_vip.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/monopoly.plist")
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
        self.m_tGameData2 = t_params.gameData:getNodeWithKey("data")
    end
    if t_params.popCallBack then
        self.m_func_callback = t_params.popCallBack
    end
    -- cclog2(self.m_tGameData," m_tGameData -=--- ")
    self.m_select_index = 0
end
--[[--
    创建ui入口并初始化数据
]]
function game_newRichMan_enemy_pop.create(self, t_params)
    self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi();

    return  m_popUi;
end
return game_newRichMan_enemy_pop;