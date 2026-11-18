--- 坠落之地
--- 战斗详情
local game_godfield_guild_high_war_battle_detail_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
};

--[[--
    销毁
]]
function game_godfield_guild_high_war_battle_detail_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_battle_detail_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
end
--[[--
    返回
]]
function game_godfield_guild_high_war_battle_detail_pop.back(self)
    game_scene:removePopByName("game_godfield_guild_high_war_battle_detail_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_battle_detail_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_battle_detail.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    local label_title = ccbNode:labelTTFForName("label_title")
    label_title:setString("Chi tiết chiến đấu")

    self.node_atk_teams = ccbNode:nodeForName("node_atk_teams")
    self.node_def_teams = ccbNode:nodeForName("node_def_teams")


    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)

    self.spr_dzz = ccbNode:spriteForName("spr_dzz") -- vs
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-12,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_godfield_guild_high_war_battle_detail_pop.refreshUi(self)

    self.node_atk_teams:removeAllChildrenWithCleanup(true);
    self.m_atk_tableView = self:createTeamsTableView(self.node_atk_teams:getContentSize(), self.m_tGameData.info.att_info or {});
    self.node_atk_teams:addChild(self.m_atk_tableView);
    self.m_atk_tableView:setScrollBarVisible(false);


    local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)
    local build_info = guild_high_war_build_cfg:getNodeWithKey(self.m_buildingId)
    local battle_id = build_info:getNodeWithKey("battle_id"):toStr()

    -- local enemy_all_cfg = getConfig(game_config_field.enemy_all)
    -- local enemy_cfg = enemy_all_cfg:getNodeWithKey(battle_id)  
    -- cclog2(enemy_cfg,"enemy_cfgenemy_cfgenemy_cfg=====>")  
    self.node_def_teams:removeAllChildrenWithCleanup(true);
    local def_info = self.m_tGameData.info.def_info
    local is_enemy = false
    if self.m_tGameData.info.def_guild == "" and self.m_tGameData.info.att_guild ~= "" then -- 有进攻方没有防守方就是野怪城
        def_info = {1}
        is_enemy = true
    end

    self.m_def_tableView = self:createTeamsTableView(self.node_def_teams:getContentSize(), def_info or {}, is_enemy);
    self.node_def_teams:addChild(self.m_def_tableView);
    self.m_def_tableView:setScrollBarVisible(false);

    if self.m_step ~= 9 then
        game_util:setSpriteDisplayBySpriteFrameName(self.spr_dzz, "godfield_VS.png")
    end

end

--[[--
    创建 进攻方/防守方 列表
]]
function game_godfield_guild_high_war_battle_detail_pop.createTeamsTableView(self,viewSize, showData, is_enemy)
    -- self.m_selTitleId = 1
    self.m_selListItem = nil;
    local cardsCount = #showData

    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.totalItem = cardsCount 
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.itemActionFlag = true
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_battle_detail_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local data = showData[index + 1]
            local node_player_icon = ccbNode:nodeForName("node_player_icon")
            local label_player_name = ccbNode:labelTTFForName("label_player_name")
            local node_player_team = ccbNode:nodeForName("node_player_team")
            
            if is_enemy then
                label_player_name:setString("Quân phòng thủ")
            else
                label_player_name:setString(data.name)
            end
            
            node_player_icon:removeAllChildrenWithCleanup(true)
            if is_enemy then
                local tempIcon = game_util:createIconByName("icon_matt")
                tempIcon:setScale(0.9)
                node_player_icon:addChild(tempIcon)
                node_player_team:removeAllChildrenWithCleanup(true)
                local viewSize = node_player_team:getContentSize()
                local px = viewSize.width/1
                local character_detail_cfg = getConfig(game_config_field.character_detail);
                local headIconSpr = game_util:createIconByName("icon_matt",1)
                headIconSpr:setScale(0.8)
                local icon_node = CCNode:create()
                icon_node:addChild(headIconSpr,1001,1001)
                headIconSpr:setAnchorPoint(ccp(0.5,0.5))
                headIconSpr:setPosition(ccp(0,0))
                icon_node:setAnchorPoint(ccp(0.5,0.5))
                icon_node:setPosition(ccp(px*(1-0.5),viewSize.height*0.5))
                node_player_team:addChild(icon_node)  
                icon_node:setScale(0.6)
            else
                local tempIcon = game_util:createPlayerIconByRoleId(data.icon)
                tempIcon:setScale(0.65)
                node_player_icon:addChild(tempIcon)
                local function onBtnCilck1( event,target )
                    local function responseMethod( tag, gameData )
                        game_scene:addPop("game_godfield_guild_high_war_player_pop",{gameData = gameData})
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_alignment_info"), http_request_method.GET, {t_uid = data.uid},"guild_high_war_alignment_info")
                end
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck1)
                button:setOpacity(0)
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition(ccp(0,0))
                node_player_icon:addChild(button);  

                local cards = {}
                for k,v in pairs(data.alignment_cards) do
                    if k < 7 and k > 0 and v ~= "0" and v ~= "-1" then
                        table.insert(cards, v)
                    end
                end

                local count = #cards
                node_player_team:removeAllChildrenWithCleanup(true)
                local viewSize = node_player_team:getContentSize()
                local px = viewSize.width/count
                local character_detail_cfg = getConfig(game_config_field.character_detail);
                for k,v in pairs(cards) do
                    local itemData = data.alignment_info[v]
                    itemData.super_quality_1 = itemData.evo
                    local headIconSpr = game_util:createCardIconByCid(itemData.c_id,itemData);
                    headIconSpr:setScale(0.8)
                    local function onBtnCilck( event,target )
                        local function responseMethod( tag, gameData )
                            local data = gameData:getNodeWithKey("data");
                            local gamedata = json.decode(data:getFormatBuffer()) or {};
                            local itemData = gamedata.alignment_info[tostring(v)]
                            if itemData then
                                game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 3})
                            end
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_alignment_info"), http_request_method.GET, {t_uid = data.uid},"guild_high_war_alignment_info")
                    end
                    local icon_node = CCNode:create()
                    icon_node:addChild(headIconSpr,1001,1001)
                    headIconSpr:setAnchorPoint(ccp(0.5,0.5))
                    headIconSpr:setPosition(ccp(0,0))
                    icon_node:setAnchorPoint(ccp(0.5,0.5))
                    icon_node:setPosition(ccp(px*(k-0.5),viewSize.height*0.5))
                    node_player_team:addChild(icon_node)
                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                    button:setOpacity(0)
                    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition(ccp(0,0))
                    icon_node:addChild(button);  
                    icon_node:setScale(0.6)
                end
            end
            

           
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
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end


--[[--
    初始化
]]
function game_godfield_guild_high_war_battle_detail_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_step = t_params.step
    self.m_buildingId = t_params.buildingId
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_guild_high_war_battle_detail_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_guild_high_war_battle_detail_pop;