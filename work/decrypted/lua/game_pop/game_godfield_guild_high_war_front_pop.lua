--- 坠落之地
--- 前线功能
local game_godfield_guild_high_war_front_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_tableView1 = nil,
    m_tableView2 = nil,
};

--[[--
    销毁
]]
function game_godfield_guild_high_war_front_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_front_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_tableView1 = nil;
    self.m_tableView2 = nil;
end
--[[--
    返回
]]
function game_godfield_guild_high_war_front_pop.back(self)
    game_scene:removePopByName("game_godfield_guild_high_war_front_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_front_pop.createUi(self)
    self.m_select_index = 1
    self.m_select_city_index = 1
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag >= 101 and btnTag <= 102 then -- 进攻/防御
            if btnTag- 100 ~= self.m_select_index then
                self.m_select_index = btnTag - 100
                self.m_select_city_index = 1
                self:refreshUi(true)
            end
        elseif btnTag == 300 then -- 保存顺位    
        elseif btnTag == 200 then -- 规则    
            local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
            local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(11))
            if itemCfg == nil then return end
            local openMsg = itemCfg:getNodeWithKey("des"):toStr();
            game_scene:addPop("game_godfield_detail_pop",{openMsg = openMsg, btn_touchPriority = 12, touchPriority = 12})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_front_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    local label_title = ccbNode:labelTTFForName("label_title")
    label_title:setString("Chi tiết tham chiến")

    self.label_tips1 = ccbNode:labelTTFForName("label_tips1")
    self.label_tips1:setString("Giai đoạn dàn trận")
    self.label_tips1:setVisible(false)
    self.label_time = ccbNode:labelTTFForName("label_time")
    self.label_time:setString("00:00:00")
    self.label_time:setVisible(false)
    self.label_tips2 = ccbNode:labelTTFForName("label_tips2")
    self.label_tips2:setString("Kết thúc sau")
    self.label_tips2:setVisible(false)
    self.label_tips3 = ccbNode:labelTTFForName("label_tips3")

    local label_tips = ccbNode:labelTTFForName("label_tips")
    local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
    local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(25))
    local openMsg = itemCfg:getNodeWithKey("des"):toStr();
    label_tips:setString(openMsg)

    
    self.node_teams = ccbNode:nodeForName("node_teams") -- 玩家阵容

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn1 = ccbNode:controlButtonForName("m_btn1")
    self.m_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn2 = ccbNode:controlButtonForName("m_btn2")
    self.m_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.label_btn1 = ccbNode:labelTTFForName("label_btn1")
    self.label_btn1:setString("Tấn công")
    self.label_btn2 = ccbNode:labelTTFForName("label_btn2")
    self.label_btn2:setString("Phòng thủ")

    self.node_citys = ccbNode:nodeForName("node_citys")
    self.node_teams = ccbNode:nodeForName("node_teams")
    self.m_bc_btn = ccbNode:controlButtonForName("m_bc_btn")
    self.m_bc_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    self.m_des_btn = ccbNode:controlButtonForName("m_des_btn")
    self.m_des_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-11,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_godfield_guild_high_war_front_pop.refreshUi(self, flag)
   
    if self.m_select_index == 1 then
        game_util:setCCControlButtonBackground(self.m_btn1,"godfield_Z7.png")
        game_util:setCCControlButtonBackground(self.m_btn2,"godfield_Z6.png")
        self.label_tips3:setString("Chi tiết tham chiến - xem TP tấn công")
    else
        game_util:setCCControlButtonBackground(self.m_btn1,"godfield_Z6.png")
        game_util:setCCControlButtonBackground(self.m_btn2,"godfield_Z7.png")
        self.label_tips3:setString("Chi tiết tham chiến - xem TP phòng thủ")
    end


    local association_id = self.m_tGameData.ass_id
    local def_list, att_list = {}, {}
    for k,v in pairs(self.m_tGameData.map) do
        if (v.def_guild and v.def_guild ~= "" and v.att_guild and v.att_guild ~= "") or (v.att_guild and v.att_guild ~= "") then -- 只展示被宣战的并且和自己有关的城市城市
            if v.def_guild == association_id then
                table.insert(def_list, {city_id = k, city_data = v})
            end
            if v.att_guild == association_id then
                table.insert(att_list, {city_id = k, city_data = v})
            end
        end
    end

    table.sort(def_list,function(data1,data2) return tonumber(data1.city_id) < tonumber(data2.city_id) end)
    table.sort(att_list,function(data1,data2) return tonumber(data1.city_id) < tonumber(data2.city_id) end)

    local city_list = {}
    if self.m_select_index == 1 then
        city_list = att_list
    else
        city_list = def_list
    end
    if self.m_tableView1 and not flag then
        self.m_lastTableViewPosY1 = self.m_tableView1:getContentOffset().y
    end
    self.node_citys:removeAllChildrenWithCleanup(true);
    self.m_tableView1 = self:createTeamsTableView1(self.node_citys:getContentSize(), city_list);
    self.node_citys:addChild(self.m_tableView1);
    self.m_tableView1:setScrollBarVisible(false);

    -- 重置位置
    if self.m_lastTableViewPosY1 and not flag then
        local contentSize = self.m_tableView1:getContentSize()
        self.m_tableView1:setContentOffset(ccp(0, self.m_lastTableViewPosY1), false);
    end

    local team_list = {}
    if city_list[self.m_select_city_index] then
        local city_id = city_list[self.m_select_city_index].city_id
        if self.m_select_index == 1 then
            team_list = city_list[self.m_select_city_index].city_data.att_info
        else
            team_list = city_list[self.m_select_city_index].city_data.def_info
        end
        
        if self.m_tableView2 and not flag then
            self.m_lastTableViewPosY2 = self.m_tableView2:getContentOffset().y
        end
        self.node_teams:removeAllChildrenWithCleanup(true);
        self.m_tableView2 = self:createTeamsTableView2(self.node_teams:getContentSize(), team_list, city_id);
        self.node_teams:addChild(self.m_tableView2);
        self.m_tableView2:setScrollBarVisible(false);

        -- 重置位置
        if self.m_lastTableViewPosY2 and not flag then
            local contentSize = self.m_tableView2:getContentSize()
            self.m_tableView2:setContentOffset(ccp(0, self.m_lastTableViewPosY2 ), false);
        end
    else
        self.node_teams:removeAllChildrenWithCleanup(true);
    end

    if self.m_tGameData.title == "owner" or self.m_tGameData.title == "vp" then
        self.m_bc_btn:setVisible(false)
    else
        self.m_bc_btn:setVisible(false)
    end

end

--[[--
    创建 进攻方/防守方 列表
]]
function game_godfield_guild_high_war_front_pop.createTeamsTableView1(self,viewSize, showData)
    self.m_selListItem = nil;
    local cardsCount = #showData
    local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)
    local totalItem = math.max(cardsCount%3 == 0 and cardsCount or math.floor(cardsCount/3+1)*3,3)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = cardsCount 
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.itemActionFlag = false
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_front_item1.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local label_name = ccbNode:labelTTFForName("label_name")
            local label_guild_name = ccbNode:labelTTFForName("label_guild_name")
            local label_team_num = ccbNode:labelTTFForName("label_team_num")
            local spr_tag = ccbNode:spriteForName("spr_tag")

            local data = showData[index + 1]
            local guild_name, team_num = "", "" 
            local tag_icon = ""
            if self.m_select_index == 1 then
                tag_icon = "gf_icon02.png"
                guild_name = "Phe tấn công:"..data.city_data.att_name
                team_num = "Bố trí đội ngũ:"..#data.city_data.att_info.."Đội"
            else
                tag_icon = "gf_icon01.png"
                guild_name = "Phe phòng thủ:"..data.city_data.def_name
                team_num = "Bố trí đội ngũ:"..#data.city_data.def_info.."Đội"
            end
            local build_info = guild_high_war_build_cfg:getNodeWithKey(data.city_id)
            local city_name = build_info:getNodeWithKey("city_name"):toStr()
            label_name:setString(city_name)
            label_guild_name:setString(guild_name)
            label_team_num:setString(team_num)
            game_util:setSpriteDisplayBySpriteFrameName(spr_tag, tag_icon)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
            self.m_select_city_index = (index+1)
            self:refreshUi(true)
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end

--[[--
    创建 进攻方/防守方 列表
]]
function game_godfield_guild_high_war_front_pop.createTeamsTableView2(self,viewSize, showData, city_id)
    local cardsCount = #showData
    local character_detail_cfg = getConfig(game_config_field.character_detail);

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local data = showData[btnTag]
        local set_type = 0
        if self.m_select_index == 1 then
            set_type = 1
        end
        local function responseMethod(tag,gameData)
            if gameData then
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi()
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_set_first_alignment"), http_request_method.GET, {set_type = set_type, city_id = city_id, t_uid = data.uid},"guild_high_war_set_first_alignment",true,true)
    end
    local totalItem = math.max(cardsCount%3 == 0 and cardsCount or math.floor(cardsCount/3+1)*3,3)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = cardsCount --totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.itemActionFlag = false
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_front_item2.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            local data = showData[index + 1]
            local m_btn1 = ccbNode:controlButtonForName("m_btn1")
            m_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
            m_btn1:setTag(index + 1)
            local node_team = ccbNode:nodeForName("node_team")
            local label_name = ccbNode:labelTTFForName("label_name")
            local node_icon = ccbNode:nodeForName("node_icon")
            local spr_tag = ccbNode:spriteForName("spr_tag")
            if self.m_select_index == 1 then
                game_util:setSpriteDisplayBySpriteFrameName(spr_tag, "gf_msz02.png")
            else
                game_util:setSpriteDisplayBySpriteFrameName(spr_tag, "gf_msz01.png")
            end
            local label_tips = ccbNode:labelTTFForName("label_tips")
            label_tips:setString("Đội ngũ:")

            if self.m_step == 4 then -- 布阵阶段
                m_btn1:setVisible(self.m_tGameData.title == "owner" or self.m_tGameData.title == "vp")
            else
                m_btn1:setVisible(false)
            end
            label_name:setString(data.name)
            --玩家头像
            node_icon:removeAllChildrenWithCleanup(true)
            local tempIcon = game_util:createPlayerIconByRoleId(data.icon)
            tempIcon:setScale(0.65)
            node_icon:addChild(tempIcon)
            local function onBtnCilck1( event,target )
                local function responseMethod( tag, gameData )
                    game_scene:addPop("game_godfield_guild_high_war_player_pop",{gameData = gameData})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_alignment_info"), http_request_method.GET, {t_uid = data.uid},"guild_high_war_alignment_info")
            end
            local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck1)
            button:setOpacity(0)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
            button:setAnchorPoint(ccp(0.5,0.5))
            button:setPosition(ccp(0,0))
            node_icon:addChild(button);  

            local cards = {}
            for k,v in pairs(data.alignment_cards) do
                if k < 7 and k > 0 and v ~= "0" and v ~= "-1" then
                    table.insert(cards, v)
                end
            end

            local count = #cards
            node_team:removeAllChildrenWithCleanup(true)
            local viewSize = node_team:getContentSize()
            local px = viewSize.width/count
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
                node_team:addChild(icon_node)
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                button:setOpacity(0)
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition(ccp(0,0))
                icon_node:addChild(button);  
                icon_node:setScale(0.7)
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

function game_godfield_guild_high_war_front_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        self.m_step = self.m_tGameData.step
    else
        self.m_tGameData = {};
    end
end


--[[--
    创建ui入口并初始化数据
]]
function game_godfield_guild_high_war_front_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_guild_high_war_front_pop;