--- 坠落之地
--- 资源占位详情
local game_godfield_guild_high_war_res_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_team_tableView = nil,
};

--[[--
    销毁
]]
function game_godfield_guild_high_war_res_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_res_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_team_tableView = nil;
end
--[[--
    返回
]]
function game_godfield_guild_high_war_res_pop.back(self)
    game_scene:removePopByName("game_godfield_guild_high_war_res_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_res_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_res_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    local label_title = ccbNode:labelTTFForName("label_title")
    label_title:setString("Thứ tự tài nguyên")

    self.label_tips1 = ccbNode:labelTTFForName("label_tips1")
    self.label_tips1:setString("Giai đoạn dàn trận")
    self.label_tips1:setVisible(false)
    self.label_time = ccbNode:labelTTFForName("label_time")
    self.label_time:setString("00:00:00")
    self.label_time:setVisible(false)
    self.label_tips2 = ccbNode:labelTTFForName("label_tips2")
    self.label_tips2:setString("Sau kết thúc, sau khi kết thúc không thể lại khiêu chiến")
    self.label_tips2:setVisible(false)
    self.node_teams = ccbNode:nodeForName("node_teams") -- 玩家阵容

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)


    
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
function game_godfield_guild_high_war_res_pop.refreshUi(self)
    local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)
    local build_info = guild_high_war_build_cfg:getNodeWithKey(self.m_buildingId)
    local city_level = build_info:getNodeWithKey("city_level"):toInt()
    local guild_high_war_product_cfg = getConfig(game_config_field.guild_high_war_product)
    guild_high_war_product_cfg = json.decode(guild_high_war_product_cfg:getFormatBuffer())
    local product_cfg
    for k,v in pairs(guild_high_war_product_cfg) do
        if v.build_sort == 3 and v.bulid_level == city_level then
            product_cfg = v
            break
        end
    end
    if product_cfg then
        local place_num = product_cfg.place_num
        local show_data = {}
        for i,v in ipairs(place_num) do
            for ii=1,v do
                table.insert(show_data, {type = i})
            end
        end
        self.taxation_cfg = product_cfg.taxation
        if self.m_team_tableView then
            self.m_lastTableViewPosY = self.m_team_tableView:getContentOffset().y
        end

        self.node_teams:removeAllChildrenWithCleanup(true);
        self.m_team_tableView = self:createTeamsTableView(self.node_teams:getContentSize(), show_data, tableViewAnimFlag);
        self.node_teams:addChild(self.m_team_tableView);
        self.m_team_tableView:setScrollBarVisible(false);

        -- 重置位置
        if self.m_lastTableViewPosY then
            local contentSize = self.m_team_tableView:getContentSize()
            self.m_lastTableViewPosY = math.max(-1 * contentSize.height, self.m_lastTableViewPosY)
            self.m_team_tableView:setContentOffset(ccp(0, self.m_lastTableViewPosY), false);
        end
    end
end


--[[--
    创建 进攻方/防守方 列表
]]
function game_godfield_guild_high_war_res_pop.createTeamsTableView(self,viewSize, showData)
    local function callBackFunc()
        local function responseMethod( tag, gameData )
            local data = gameData:getNodeWithKey("data");
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            self.m_tableViewAnimFlag = false
            self:refreshUi()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_city_info"), http_request_method.GET, {group_id = self.m_prev_gameData.group_id, city_id = self.m_buildingId},"guild_high_war_city_info")
    end


    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();

        if self:getSourcePositionFlag(btnTag) then
            return game_util:addMoveTips({text = "Đã dàn trận ở vị trí tài nguyên, không thể thao thác vị trí tài nguyên khác!"});
        end

        local info = self.m_tGameData.info[tostring(btnTag)]
        local uid = game_data:getUserStatusDataByKey("uid")
        local formation_type = 3 ---1.离开 2.挑战 3.驻守
        local alignment
        if self.m_step == 4 or self.m_step == 5 then -- 布阵阶段
            if info and info.def_guild ~= "" and info.def_info[1].uid == uid then
                formation_type = 1
                alignment = info.def_info[1].alignment
            elseif info and info.att_guild ~= "" and info.att_info[1].uid == uid then
                formation_type = 1
                alignment = info.att_info[1].alignment
            elseif info and info.def_guild ~= "" and info.def_info[1].uid ~= uid then
                formation_type = 2
            elseif info and info.def_guild == "" then
                formation_type = 3
            end
        else
            return game_util:addMoveTips({text = "GĐ hiện tại không thể dàn trận!"});
        end

        if formation_type == 1 then
            local uid = game_data:getUserStatusDataByKey("uid")
            local function responseMethod( tag, gameData )
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self.m_tableViewAnimFlag = false
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_down_alignment_source"), http_request_method.GET, {alignment = alignment,city_id=self.m_buildingId,block_id=btnTag},"guild_high_war_down_alignment_source")
            return
        end

        local uid = game_data:getUserStatusDataByKey("uid")
        local function responseMethod( tag, gameData )
            game_scene:addPop("game_godfield_guild_high_war_formation_pop",{gameData = gameData, buildingId = self.m_buildingId, openPopType = "game_godfield_guild_high_war_res_pop", block_id = btnTag, callBackFunc = callBackFunc, formation_type = formation_type})                  
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_alignment_info"), http_request_method.GET, {t_uid = uid},"guild_high_war_alignment_info")
       
    end

    local cardsCount = #showData
    local totalItem = math.max(cardsCount%3 == 0 and cardsCount or math.floor(cardsCount/3+1)*3,3)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = cardsCount --totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.itemActionFlag = self.m_tableViewAnimFlag
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_res_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local spr_team = ccbNode:spriteForName("spr_team")
            local label_guild1 = ccbNode:labelTTFForName("label_guild1")
            local node_team1 = ccbNode:nodeForName("node_team1")
            local spr_icon1 = ccbNode:spriteForName("spr_icon1")
            local node_icon1 = ccbNode:nodeForName("node_icon1")
            local spr_no_tz1 = ccbNode:spriteForName("spr_no_tz1")
            local label_ss = ccbNode:labelTTFForName("label_ss") -- 科技税收

            local label_guild2 = ccbNode:labelTTFForName("label_guild2")
            local node_team2 = ccbNode:nodeForName("node_team2")
            local spr_icon2 = ccbNode:spriteForName("spr_icon2")
            local node_icon2 = ccbNode:nodeForName("node_icon2")
            local spr_no_tz2 = ccbNode:spriteForName("spr_no_tz2")

            local m_btn1 = ccbNode:controlButtonForName("m_btn1")
            m_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
            m_btn1:setTag(index + 1)
            if showData[index+ 1].type == 1 then
                game_util:setSpriteDisplayBySpriteFrameName(spr_team, "yjzt_msz18.png")
            elseif showData[index+ 1].type == 2 then
                game_util:setSpriteDisplayBySpriteFrameName(spr_team, "yjzt_msz17.png")
            else
                game_util:setSpriteDisplayBySpriteFrameName(spr_team, "yjzt_msz16.png")
            end
            m_btn1:setVisible(true)
            label_guild1:setString("")
            label_guild2:setString("")
            label_ss:setString("")

            local def_flag, att_flag = false, false
            spr_no_tz1:setVisible(true)
            node_icon1:removeAllChildrenWithCleanup(true)
            node_team1:removeAllChildrenWithCleanup(true)
            local info = self.m_tGameData.info[tostring(index + 1)]
            if info and info.def_guild ~= "" then
                def_flag = true
                label_guild1:setString(info.def_info[1].name)
                label_ss:setString("Thuế KHKT:"..self.taxation_cfg[showData[index+ 1].type])

                local tempIcon = game_util:createPlayerIconByRoleId(info.def_info[1].icon)
                tempIcon:setScale(0.65)
                node_icon1:addChild(tempIcon)

                local function onBtnCilck1( event,target )
                    local function responseMethod( tag, gameData )
                        game_scene:addPop("game_godfield_guild_high_war_player_pop",{gameData = gameData})
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_alignment_info"), http_request_method.GET, {t_uid = info.def_info[1].uid},"guild_high_war_alignment_info")
                end
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck1)
                button:setOpacity(0)
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition(ccp(0,0))
                node_icon1:addChild(button);  

                spr_no_tz1:setVisible(false)

                local cards = {}
                for k,v in pairs(info.def_info[1].alignment_cards) do
                    if k < 7 and k > 0 and v ~= "0" and v ~= "-1" then
                        table.insert(cards, v)
                    end
                end

                local count = #cards
                
                local viewSize = node_team1:getContentSize()
                local px = viewSize.width/count
                local character_detail_cfg = getConfig(game_config_field.character_detail);
                for k,v in pairs(cards) do
                    local itemData = info.def_info[1].alignment_info[v]
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
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_alignment_info"), http_request_method.GET, {t_uid = info.def_info[1].uid},"guild_high_war_alignment_info")
                    end
                    -- local ccb = luaCCBNode:create()
                    -- ccb:openCCBFile("ccb/ui_godfield_dart_zhenrong_item.ccbi")
                    local icon_node = CCNode:create()
                    icon_node:addChild(headIconSpr,1001,1001)
                    headIconSpr:setAnchorPoint(ccp(0.5,0.5))
                    headIconSpr:setPosition(ccp(0,0))
                    icon_node:setAnchorPoint(ccp(0.5,0.5))
                    icon_node:setPosition(ccp(px*(k-0.5),viewSize.height*0.5))
                    node_team1:addChild(icon_node)
                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                    button:setOpacity(0)
                    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition(ccp(0,0))
                    icon_node:addChild(button);  
                    icon_node:setScale(0.6)
                end
            end

            spr_no_tz2:setVisible(true)
            node_icon2:removeAllChildrenWithCleanup(true)
            node_team2:removeAllChildrenWithCleanup(true)
            local info = self.m_tGameData.info[tostring(index + 1)]
            if info and info.att_guild ~= "" then
                att_flag = true
                label_guild2:setString(info.att_info[1].name)
                
                local tempIcon = game_util:createPlayerIconByRoleId(info.att_info[1].icon)
                tempIcon:setScale(0.6)
                node_icon2:addChild(tempIcon)

                spr_no_tz2:setVisible(false)

                local cards = {}
                for k,v in pairs(info.att_info[1].alignment_cards) do
                    if k < 7 and k > 0 and v ~= "0" and v ~= "-1" then
                        table.insert(cards, v)
                    end
                end

                local count = #cards
                
                local viewSize = node_team2:getContentSize()
                local px = viewSize.width/count
                local character_detail_cfg = getConfig(game_config_field.character_detail);
                for k,v in pairs(cards) do
                    local itemData = info.att_info[1].alignment_info[v]
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
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_alignment_info"), http_request_method.GET, {t_uid = info.att_info[1].uid},"guild_high_war_alignment_info")
                    end
                    local icon_node = CCNode:create()
                    icon_node:addChild(headIconSpr,1001,1001)
                    headIconSpr:setAnchorPoint(ccp(0.5,0.5))
                    headIconSpr:setPosition(ccp(0,0))
                    icon_node:setAnchorPoint(ccp(0.5,0.5))
                    icon_node:setPosition(ccp(px*(k-0.5),viewSize.height*0.5))
                    node_team2:addChild(icon_node)
                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                    button:setOpacity(0)
                    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition(ccp(0,0))
                    icon_node:addChild(button);  
                    icon_node:setScale(0.6)
                end
            end

            local uid = game_data:getUserStatusDataByKey("uid")
            if self.m_step == 2 or self.m_step == 3 then -- 准备阶段/宣战阶段
                m_btn1:setVisible(false)
            elseif self.m_step == 4 or self.m_step == 5 then -- 布阵阶段
                if def_flag and att_flag then
                    if info.def_info[1].uid == uid or info.att_info[1].uid == uid then
                        game_util:setCCControlButtonBackground(m_btn1, "lk_btn.png")
                    else
                        game_util:setCCControlButtonBackground(m_btn1, "godfield_tiaozhan.png")
                        if self.m_step == 5 then
                            m_btn1:setVisible(false)
                        end
                    end
                elseif def_flag and not att_flag then
                    if info.def_info[1].uid == uid then
                        game_util:setCCControlButtonBackground(m_btn1, "lk_btn.png")
                    else
                        game_util:setCCControlButtonBackground(m_btn1, "godfield_tiaozhan.png")
                        if self.m_step == 5 then
                            m_btn1:setVisible(false)
                        end
                    end
                elseif not def_flag and att_flag then
                    if info.att_info[1].uid == uid then
                        game_util:setCCControlButtonBackground(m_btn1, "lk_btn.png")
                    else
                        game_util:setCCControlButtonBackground(m_btn1, "rz_btn.png")
                    end
                else
                    game_util:setCCControlButtonBackground(m_btn1, "rz_btn.png")
                end
            elseif self.m_step == 9 or self.m_step == 8 or self.m_step == 10 or self.m_step == 6 then -- 战斗阶段
                m_btn1:setVisible(false)
            end
            
            if not self.m_isSelfFlag then
                m_btn1:setVisible(false)
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
        -- self.m_selListItem = nil;
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end

--- 是否已经上阵资源位，并且不是当前资源位
function game_godfield_guild_high_war_res_pop.getSourcePositionFlag(self, position)
    local uid = game_data:getUserStatusDataByKey("uid")
    for k,v in pairs(self.m_tGameData.info) do
        local flag
        if (v.def_guild ~= "" and v.def_info[1].uid == uid) or (v.att_guild ~= "" and v.att_info[1].uid == uid) then
            flag = true
        end
        if flag and k ~= tostring(position) then
            return true
        end
    end
end

--[[--
    初始化
]]
function game_godfield_guild_high_war_res_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_buildingId = t_params.buildingId
    self.m_prev_gameData = t_params.prev_gameData or {}
    self.m_step = self.m_prev_gameData.step or 1
    self.m_tableViewAnimFlag = true
    self.m_isSelfFlag = t_params.isSelfFlag
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
function game_godfield_guild_high_war_res_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_guild_high_war_res_pop;