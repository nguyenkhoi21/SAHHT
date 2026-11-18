local game_guild_Star_zhenxing = {
    m_sel = nil,
    L_node = nil,
    m_node = nil,
    m_root_layer = nil,
    m_btn_figth = nil,
    m_close_btn = nil,
    m_msg_lb = nil,
    m_ccbNode = nil,
    m_tGameData = nil,
    god_field_ids = nil,
    team_dat = nil;a = nil,
    m_cards = nil,
    m_boss_times = nil,
    openType = nil,
    m_formation = nil,
    cards_data = nil,
    m_constellation_detail = nil,
    mountain_id = nil,
    pos = nil,
};

--[[--
    销毁
]]
function game_guild_Star_zhenxing:destroy( )
    -- body
    cclog("-----------------game_guild_Star_zhenxing destroy-----------------");
    self.m_sel = nil;
    self.L_node = nil;
    self.m_node = nil;
    self.m_root_layer = nil;
    self.m_btn_figth = nil;
    self.m_close_btn = nil;
    self.m_msg_lb = nil;
    self.m_ccbNode = nil;
    self.m_tGameData = nil;
    self.god_field_ids = nil;
    self.team_data = nil;
    self.m_cards = nil;
    self.m_boss_times = nil;
    self.openType = nil;
    self.m_formation = nil;
    self.cards_data = nil;
    self.m_constellation_detail = nil;
    self.mountain_id = nil;
    self.pos = nil;
end
--[[--
    返回
]]
function game_guild_Star_zhenxing:back( type )
	game_scene:removePopByName("game_guild_Star_zhenxing")
end
--[[--
    读取ccbi创建ui
]]
function game_guild_Star_zhenxing:createUi()
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 105 then
        	if not self.m_sel then
        		game_util:addMoveTips({text = "Hãy chọn đội"})
        		return
        	end
        	local function responseMethod( tag,gameData )
				if gameData then
                    local data = gameData:getNodeWithKey("data")
                    local find_shop = data:getNodeWithKey("find_shop"):toStr()
                    if find_shop == "true" then
                        local shop_id_list = data:getNodeWithKey("shop_id_list")
                        local shop_type = data:getNodeWithKey("shop_type"):toStr()
                        --  cclog2(shop_id_list,"shop_id_list-=-=-----")
                        -- cclog2(shop_type,"shop_type-=-=-----")
                        game_data:setGuildStarShopMsg(shop_id_list,shop_type)
                    else
                        game_data:setGuildStarShopMsg(nil,nil)
                    end
                    local has_battle = gameData:getNodeWithKey("data"):getNodeWithKey("has_battle"):toStr()
                    if has_battle == "1" then
                		game_data:setBattleType("guild_star");
    		            game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                    else
                        local posX,index = game_data:getGuildStarPos()
                        local function responseMethod( tag,gameData )
                            if gameData then
                                game_scene:enterGameUi("ui_guild_star_smallStar",{gameData = gameData,enterType = index,posX = posX})
                            end
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_go_mountain"), http_request_method.GET, { mountain_id= index},"guild_robbery_go_mountain")
                    end
				end
			end
			local params = {}
			params.mountain_id = self.mountain_id
			params.pos = self.pos
			params.team_id = self.m_sel
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_robbery_battle"), http_request_method.GET, params,"guild_robbery_battle")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_Star_select_pop.ccbi");
    self.L_node = ccbNode:nodeForName("L_node")
    self.m_node = ccbNode:nodeForName("L_listnode")
    self.m_root_layer = ccbNode:layerForName('m_root_layer')
    self.m_btn_figth = ccbNode:controlButtonForName("m_btn_figth")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_msg_lb = ccbNode:labelTTFForName("msg_lb")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-9)
    self.m_btn_figth:setTouchPriority(GLOBAL_TOUCH_PRIORITY-9)
    self.m_msg_lb:setVisible(false)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then

        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-8,true)
    self.m_root_layer:setTouchEnabled(true)
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

function game_guild_Star_zhenxing:refreshUi( )
    -- self.m_msg_lb:setVisible(false)
    self.m_node:removeAllChildrenWithCleanup(true)
    self:createzhenxinglist(self.m_node,self.m_node:getContentSize())
end

function game_guild_Star_zhenxing:createzhenxinglist( parent_node , viewSize )
	local pos = {0.7,0.45,0.2}
    local selectList = {}
	for i=1,3 do
        local zhenxingdata = self.team_data[tostring(i)]
        local formation = self.m_formation[tostring(i)]
        local ccbNode = luaCCBNode:create()
        local function onMainBtnClick( target,event )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            cclog("btnTag ........................ " .. btnTag)
            if btnTag < 10 then
            elseif btnTag > 10 and  btnTag < 20 then
                local sel = btnTag - 10
                self.m_sel = sel
                for i=1,3 do
                    if i == sel then
                        game_util:setCCControlButtonBackground(selectList[i],"godfen_zhen" .. sel .. sel .. ".png")
                    else
                        game_util:setCCControlButtonBackground(selectList[i],"godfen_zhen" .. i .. ".png")
                    end
                end
            elseif btnTag > 20 then
                    local t_params = {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        game_util:closeAlertView();
                        local function responseMethod( tag,gameData )
                            if gameData and tolua.type(gameData) == "util_json" then
                                local data = gameData:getNodeWithKey("data")
                                self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
                                self.god_field_ids = self.m_tGameData.god_field_ids
                                self.team_data = self.m_tGameData.teams
                                self:refreshUi();
                                game_util:addMoveTips({text="Hủy trận hình thứ" .. btnTag-20})
                            end
                        end
                        local params = {}
                        params.team = btnTag-20
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("zodiac_remove_floor_pos"), http_request_method.GET, params,"zodiac_remove_floor_pos")
                    end,   --可缺省
                    cancelBtnCallBack = function(target,event)
                        game_util:closeAlertView();
                    end,
                    okBtnText = "OK",       --可缺省
                    cancelBtnText = "Hủy",
                    onlyOneBtn = false,
                    text ="    Hủy trận hình thứ"  .. btnTag-20 ,      --可缺省
                    touchPriority = GLOBAL_TOUCH_PRIORITY-12,
                }
                game_util:openAlertView(t_params);
            end
        end
        ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
		ccbNode:openCCBFile("ccb/ui_guild_star_zhenrong_item.ccbi")
		local zhenxing = ccbNode:controlButtonForName("L_zhenxing")
        zhenxing:setTag(10 + i)
		zhenxing:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
        game_util:setCCControlButtonBackground(zhenxing,"godfen_zhen" .. i .. ".png")
		local L_btn = ccbNode:controlButtonForName("L_btn_zhenxing")
        local L_chexiao = ccbNode:controlButtonForName("L_btn_chexiao")
        local combat = ccbNode:labelTTFForName("L_zhadnouli_lb")
        local table_view_node = ccbNode:nodeForName("table_view_node")
        local L_weizhi_sp = ccbNode:spriteForName("L_weizhi_sp")
        local L_weizhi = ccbNode:labelTTFForName("L_weizhi")
        local m_layer = ccbNode:layerForName("L_layer")
        L_btn:setVisible(false)
        L_chexiao:setVisible(false)
        if zhenxingdata.mountain ~= 0 and zhenxingdata.pos ~= 0 then
            m_layer:setVisible(true)
            L_weizhi_sp:setVisible(true)
            L_weizhi:setVisible(true)
            L_weizhi:setString(GUILD_STAR_BTN_ICON[zhenxingdata.mountain].name)
        else 
            m_layer:setVisible(false)
            L_chexiao:setVisible(false)
            L_weizhi_sp:setVisible(false)
            L_weizhi:setVisible(false)
            L_weizhi:setString("")
        end
        selectList[i] = zhenxing 
        combat:setString(formation.combat)
        table_view_node:removeAllChildrenWithCleanup(true)
        self:createZhenRongList(table_view_node,table_view_node:getContentSize(),i)
		ccbNode:setPosition(ccp(10,viewSize.height*pos[i]))
		parent_node:addChild(ccbNode)
	end
end

function game_guild_Star_zhenxing:createzhenxinglist2( parent_node , viewSize )
    local pos = {0.7,0.45,0.2}
    local battle_teams_data =game_data:getGod_Boss_battle_msg("  game_guild_Star_zhenxing  -----------------------------  ").team
    local selectList = {}
    for i=1,#battle_teams_data do
        local m = battle_teams_data[i]
        local zhenxingdata = self.team_data[m]
        local ccbNode = luaCCBNode:create()
        local function onMainBtnClick( target,event )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            if btnTag < 10 then
                local team_index = 1
                team_index = btnTag
                local function responseMethod(tag,gameData)
                    if gameData then
                        game_scene:enterGameUi("game_god_adjustment",{gameData = gameData,openType="game_guild_Star_zhenxing",team_index = team_index});
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_upload_god_formation"), http_request_method.GET, nil,"god_field_upload_god_formation",true,true)
            elseif btnTag > 10 and  btnTag < 20 then
                local sel = btnTag - 10
                local Boss_battle_team = game_data:getGod_Boss_battle_msg("game_god_pyramid_palace")
                Boss_battle_team.squad = sel
                game_data:setGod_Boss_battle_msg(Boss_battle_team,"game_god_pyramid_palace")
                for i=1,#battle_teams_data do
                    local n =tonumber(battle_teams_data[i]) 
                    if n == sel then
                        game_util:setCCControlButtonBackground(selectList[i],"godfen_zhen" .. n .. n .. ".png")
                    else
                        game_util:setCCControlButtonBackground(selectList[i],"godfen_zhen" .. n .. ".png")
                    end
                end
            end
        end
        ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
        ccbNode:openCCBFile("ccb/ui_guild_star_zhenrong_item.ccbi")
        local zhenxing = ccbNode:controlButtonForName("L_zhenxing")
        game_util:setCCControlButtonBackground(zhenxing,"godfen_zhen" .. m .. ".png")
        local L_btn = ccbNode:controlButtonForName("L_btn_zhenxing")
        local L_chexiao = ccbNode:controlButtonForName("L_btn_chexiao")
        local combat = ccbNode:labelTTFForName("L_zhadnouli_lb")
        local table_view_node = ccbNode:nodeForName("table_view_node")
        local L_weizhi_sp = ccbNode:spriteForName("L_weizhi_sp")
        local L_weizhi = ccbNode:labelTTFForName("L_weizhi")
        local m_layer = ccbNode:layerForName("L_layer")
        L_btn:setVisible(false)
        if #battle_teams_data == 1 then
            game_util:setCCControlButtonBackground(zhenxing,"godfen_zhen" .. m .. m .. ".png")
            local Boss_battle_team = game_data:getGod_Boss_battle_msg("game_god_pyramid_palace")
            Boss_battle_team.squad = m
            game_data:setGod_Boss_battle_msg(Boss_battle_team,"game_god_pyramid_palace")
        end
        if zhenxingdata.mountain ~= 0 and zhenxingdata.pos ~= 0 then
            m_layer:setVisible(false)
            L_btn:setVisible(false)
            L_chexiao:setVisible(false)
            L_weizhi_sp:setVisible(true)
            L_weizhi:setVisible(true)
            L_weizhi:setString(GUILD_STAR_BTN_ICON[zhenxingdata.mountain].name)
        end
        selectList[i] = zhenxing 
        -- combat:setString(self.m_tGameData["god_combat_" .. m])
        table_view_node:removeAllChildrenWithCleanup(true)
        self:createZhenRongList(table_view_node,table_view_node:getContentSize(),m)
        zhenxing:setTag(10 + m)
        L_btn:setTag(m)
        L_chexiao:setTag(20 + m)
        zhenxing:setTouchPriority(GLOBAL_TOUCH_PRIORITY-9)
        L_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-9)
        L_chexiao:setTouchPriority(GLOBAL_TOUCH_PRIORITY-9)
        ccbNode:setPosition(ccp(10,viewSize.height*pos[i]))
        parent_node:addChild(ccbNode)
    end
end
function game_guild_Star_zhenxing:createZhenRongList(parend_node , viewSize ,team_index)
    local cards = {}
    cclog2(self.m_formation[tostring(team_index)].card_ids)
    for k,v in pairs(self.m_formation[tostring(team_index)].card_ids) do
        if tonumber(k) < 7 and tonumber(k) > 0 and v ~= "0" and v ~= "-1" then
            local itemData
            if self.m_cards and self.m_cards.v then
                itemData = self.m_cards.v
            else
                itemData = self.cards_data[v]
                -- local heroCfg = character_detail_cfg:getNodeWithKey(tostring(card_data.c_id));
                -- itemData =json.decode(heroCfg:getFormatBuffer())
            end
            if itemData and itemData.c_id then
                table.insert(cards,v)
            end
        end
    end
    -- cclog2(cards)
    local count = #cards
    local px = viewSize.width/count
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    for k,v in pairs(cards) do
        local itemData
        if self.m_cards and self.m_cards.v then
            itemData = self.m_cards.v
        else
            itemData = self.cards_data[v]
            -- local heroCfg = character_detail_cfg:getNodeWithKey(tostring(card_data.c_id));
            -- itemData =json.decode(heroCfg:getFormatBuffer())
        end
        -- cclog2(itemData,"irtetewte")
        local headIconSpr = game_util:createCardIconByCid(itemData.c_id,itemData);
        headIconSpr:setScale(0.8)
        local function onBtnCilck( event,target )
            local itemData = self.m_cards.v
            if itemData then
                game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 3})
            end
        end
        local ccb = luaCCBNode:create()
        ccb:openCCBFile("ccb/ui_godfield_dart_zhenrong_item.ccbi")
        local icon_node = ccb:nodeForName("icon_node")
        icon_node:addChild(headIconSpr,1001,1001)
        headIconSpr:setAnchorPoint(ccp(0.5,0.5))
        headIconSpr:setPosition(ccp(0,0))
        ccb:setAnchorPoint(ccp(0.5,0.5))
        ccb:setPosition(ccp(px*(k-0.5),viewSize.height*0.5))
        parend_node:addChild(ccb)
        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        button:setOpacity(0)
        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
        button:setAnchorPoint(ccp(0.5,0.5))
        button:setPosition(ccp(0,0))
        icon_node:addChild(button);    
    end
end


--[[--
    初始化
]]
function game_guild_Star_zhenxing:init( t_params )
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/god_star_palace.plist");
    t_params = t_params or {}
    self.m_boss_times = t_params.boss_times or nil
    self.openType = t_params.openType
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
    end
    self.m_formation = self.m_tGameData.formation
    -- cclog2(self.god_field_ids)
    -- cclog2(self.m_cards,"elf.m_cardself.m_cardself.m_cards")
    self.team_data = self.m_tGameData.teams
    self.cards_data = game_data:getTableCardsData()
    self.m_constellation_detail = getConfig(game_config_field.constellation_detail) or {}
    self.mountain_id = t_params.mountain_id
    self.pos = t_params.pos
end

--[[--
    创建ui入口并初始化数据
]]
function game_guild_Star_zhenxing:create( t_params )
	cclog("-------------  init  ----------------")
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_guild_Star_zhenxing;