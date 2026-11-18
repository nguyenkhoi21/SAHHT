--- 神域雇佣
local game_godfield_dart_pop = {

    m_root_layer = nil,
    m_close_btn = nil,
    own_tab_node = nil,
    other_tab_node = nil,
    my_mercenary_count = nil, --自己的数量
    other_mercenary_count = nil,

    teamData = nil,
    m_guild_teamData = nil,
    m_guild_other_teamData = nil,
    params_align_1 = nil,
    m_tGameData = nil,
    sel_cards_data = nil,
    other_id = nil,
    other_data_tab = nil,
    other_team_data = nil,
    openType = nil,
    temp_teamData = nil,
    formation_id = nil,
    guild_employ = nil,
};

--[[--
    销毁
]]
function game_godfield_dart_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_dart_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.own_tab_node = nil;
    self.other_tab_node = nil;
    self.my_mercenary_count = nil;

    self.m_guild_teamData = nil;
    self.m_guild_other_teamData = nil;
    self.params_align_1 = nil;
    self.teamData = nil;
    self.m_tGameData = nil;
    self.sel_cards_data = nil;
    self.other_id = nil;
    self.other_data_tab = nil;
    self.other_team_data = nil;
    self.openType = nil;
    self.temp_teamData = nil;
    self.formation_id = nil;
    self.guild_employ = nil;
end
--[[--
    返回
]]
function game_godfield_dart_pop.back(self,type)
    -- game_scene:removePopByName("game_godfield_dart_pop");

    if self.openType == "escort" then
        local function responseMethod( tag,gameData )
            t_params = {}
            t_params.map_id = gameData.map_index
            local function responseMethod( tag,gameData )
                if gameData == nil then return end
                local temp = {}
                game_data:setGuildSelTeamData({});
                game_data:setGuildTeamData({})
                game_data:setGuildOtherTeamData({})
                game_scene:enterGameUi("game_godfield_dart_routeslist",{gameData = gameData,index = t_params.map_id})
                end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_map_index"),http_request_method.GET,t_params,"god_field_escort_map_index")
        end
        self.my_team.align_1 = self.params_align_1 .. "&formation=" .. self.formation_id .. self.other_team_data;
        local params = self.my_team
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_start_sail"),http_request_method.GET,params,"god_field_escort_start_sail")
    elseif self.openType == "rob"  then
        local function responseMethod( tag,gameData )
            game_data:setGuildSelTeamData({});
            game_data:setGuildOtherTeamData({})
            game_data:setGuildTeamData({})
            game_scene:addPop("game_godfield_dart_result",{gameData = gameData})
        end
        self.my_team.align_1 = self.params_align_1 .. "&formation=" .. self.formation_id .. self.other_team_data;
        local params = self.my_team
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_rob"),http_request_method.GET,params,"god_field_escort_rob")
    end
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_dart_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            if self.enterType == "adjust" then
                local function responseMethod( tag,gameData )
                    game_data:setGuildSelTeamData({});
                    game_data:setGuildTeamData({})
                    game_data:setGuildOtherTeamData({})
                    game_scene:enterGameUi("game_godfield_dart_main",{gameData = gameData})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_dart_mian"),http_request_method.GET,nil,"god_dart_mian")
            else
                game_scene:removePopByName("game_godfield_dart_pop");
            end
        elseif btnTag == 2 then
            if self.enterType ~= "adjust" then game_util:addMoveTips({text="请先选择阵型！"})  return end 
            self:back();  
        elseif btnTag == 3 then
                local count = 0
                for k,v in pairs(self.sel_cards_data) do
                    count = count + 1
                end
                if self.sel_cards_data and count > 0 then
                    game_data:setGuildSelTeamData(self.sel_cards_data)
                    game_scene:enterGameUi("game_god_adjustment_formation",{gameData = nil,openType="game_god_adjustment_formation",enterType=self.openType,my_team = self.my_team});
                else
                    game_util:addMoveTips({text="Chọn hero ra trận!"})
                end
            -- end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_dart_doubtful_pop.ccbi"); 
    self.m_ccbNode = ccbNode;
    self.m_root_layer = ccbNode:layerForName('m_root_layer')
    self.m_own_table_view_node = ccbNode:nodeForName("own_table_view_node")
    self.m_other_table_view_node = ccbNode:nodeForName("other_table_view_node")
    self.m_guildteam_count = ccbNode:labelTTFForName("m_guildteam_count")
    self.m_guildteam_count:setString("0/3")
    self.m_ownteam_count = ccbNode:labelTTFForName("m_ownteam_count")
    self.m_ownteam_count:setString("0/5")
    self.zhenxing_btn = ccbNode:controlButtonForName("zhenxing_btn")
    self.canzhan_btn = ccbNode:controlButtonForName("canzhan_btn")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-8)
    self.zhenxing_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-8)
    self.canzhan_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-8)
    self.canzhan_btn:setVisible(false)
    -- if self.enterType == "adjust" then
    --     self.m_close_btn:setVisible(false)
    -- else 
    --     self.m_close_btn:setVisible(true)
    -- end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-7,true)
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

function game_godfield_dart_pop.refreshTableView( self )
    self.m_own_table_view_node:removeAllChildrenWithCleanup(true)
    local tempRewardTable = self:createTabelView(self.m_own_table_view_node:getContentSize());
    self.m_own_table_view_node:addChild(tempRewardTable,10,10)

    self.m_other_table_view_node:removeAllChildrenWithCleanup(true)
    local tempRewardTable2 = self:createOthersTableView(self.m_other_table_view_node:getContentSize());
    self.m_other_table_view_node:addChild(tempRewardTable2,10,10)
end
--[[
    
]]
function game_godfield_dart_pop.createTabelView(self,viewSize)
    local my_uid = game_data:getUserStatusDataByKey("uid") or nil;
    local my_cards = {};
    for k,v in pairs(self.my_cards_data) do
        table.insert(my_cards,v)
    end
    local cardsCount = #my_cards
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 2; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = cardsCount
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-8;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create() 
            ccbNode:openCCBFile("ccb/ui_godfield_dart_doubtful_icon_.ccbi")
            local m_lv_lab = ccbNode:labelTTFForName("m_zhandouli");
            m_lv_lab:setVisible(false)
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local head_node = ccbNode:nodeForName("icon_node")
            local select_sprite = ccbNode:spriteForName("select_sprite")
            select_sprite:setScale(1.5)
            head_node:removeAllChildrenWithCleanup(true)
            local m_lv_lab = ccbNode:labelTTFForName("m_lv");
            if index < cardsCount then
                local itemData = my_cards[index+1]
                local level = "Lv."..itemData.lv
                m_lv_lab:setString(level)
                local itemId = self:lua_string_split(itemData.id) or "4800"
                local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(itemId);
                local itemName = itemConfig:getNodeWithKey("name"):toStr() or "" --材料卡名字
                local tempIcon = game_util:createCardIconByCid(itemId,false)
                if tempIcon then
                    local tempSize = head_node:getContentSize();
                    tempIcon:setScale(0.8)
                    tempIcon:setPosition(ccp(0, 0))
                    head_node:addChild(tempIcon)
                end
                local curTab = game_data:getGuildTeamData()
                for k,v in pairs(curTab) do
                    if v == itemData.id then
                        select_sprite:setVisible(true)
                        self.sel_cards_data[tostring(itemData.id)] = itemData;
                        self.temp_teamData[tostring(itemData.id)] = self.team_index
                        self.team_index = self.team_index + 1
                        break
                    else
                        select_sprite:setVisible(false)
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local select_sprite = ccbNode:spriteForName("select_sprite")
            -- local itemData,_ = game_data:getCardDataByIndex(index+1);
            local itemData = my_cards[index+1]
            local c_idTab = {};

            for k,v in pairs(self.m_guild_other_teamData) do
                local itemId = self:lua_string_split(v)
                table.insert(c_idTab,itemId)
            end

            local flag,k = game_util:idInTableById(itemData.c_id,c_idTab);
            if flag and k ~= nil then
                game_util:addMoveTips({text = "Không thể chọn hero giống nhau!"});
            else
                local flag,k = game_util:idInTableById(itemData.id,self.m_guild_teamData);
                if flag and k ~= nil then
                    cclog("~~~~~~~~")
                    select_sprite:setVisible(false)
                    table.remove(self.m_guild_teamData,k);
                    self.sel_cards_data[tostring(itemData.id)] = nil;
                    self.temp_teamData[tostring(itemData.id)] = nil;
                else
                    cclog("!!!!!!!!")
                    if #self.m_guild_teamData > 4 then
                        game_util:addMoveTips({text="Tối đa chọn 5 thẻ của mình"})
                        return
                    end
                    select_sprite:setVisible(true)
                    table.insert(self.m_guild_teamData,itemData.id)
                    -- cclog2(itemData,"itemData--------------")
                    self.sel_cards_data[tostring(itemData.id)] = itemData;
                    self.temp_teamData[tostring(itemData.id)] = self.team_index
                    self.team_index = self.team_index + 1 
                end
                self.m_ownteam_count:setString(#self.m_guild_teamData .. "/5")
                game_data:setGuildFormationData(self.temp_teamData)
                game_data:setGuildTeamData(self.m_guild_teamData);        
            end
        end
    end
    return TableViewHelper:create(params);
end


function game_godfield_dart_pop.createOthersTableView(self,viewSize)
    local all_data_tab = {} --有uid
    local other_data_tab = self.other_data_tab; --没有uid

    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #other_data_tab ;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-8;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_godfield_dart_doubtful_item.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5 - 10));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local player_name = ccbNode:labelTTFForName("name")
            local heroIcon = ccbNode:nodeForName("title_sp")
            local lv_lab = ccbNode:labelTTFForName("m_lv")
            local hero_node = ccbNode:nodeForName("list_node")
            local role = 1;
            local my_lv = 100;
            local p_name = "宝宝";
            local uid = self.other_id[index+1]
            local employed = {}
            if self.employed[uid] then
                employed = self.employed[uid]
            end
            if other_data_tab and other_data_tab[tonumber(index+1)] and other_data_tab[tonumber(index+1)]["info"] then
                local info_Data = other_data_tab[tonumber(index+1)]
                role = info_Data["info"]["role"];
                my_lv = "Lv." .. info_Data["info"]["level"];
                p_name = info_Data["info"]["name"];
            end
            if lv_lab and player_name then
                lv_lab:setString(my_lv)
                player_name:setString(p_name)
            end
            local icon = game_util:createPlayerIconByRoleId(tostring(role));
            if icon then
                heroIcon:removeAllChildrenWithCleanup(true);
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,0))
                icon:setScale(0.5)
                heroIcon:addChild(icon);
            else
                cclog("tempFrontUser.role " .. role .. " not found !")
            end
            if other_data_tab and other_data_tab[index+1] and other_data_tab[index+1]["cards"] then
                local cards_data = other_data_tab[index+1]["cards"]
                local cards_list = {}
                for k,v in pairs(cards_data) do
                    local diff = false
                    for m,n in pairs(employed) do
                        if k == n then
                            diff = true
                        end
                    end
                    if diff == false then
                        table.insert(cards_list,v)
                    end
                end
                local alignment_tab = {};
                for k,v in pairs(cards_data) do
                    table.insert(alignment_tab,v)
                    local function onBtnCilck( event,target )
                        local tagNode = tolua.cast(target, "CCNode");
                        local btnTag = tagNode:getTag();
                        if btnTag == 999 then
                            game_util:addMoveTips({text = "Bạn đã thuê thẻ này rồi"})
                        else
                            local itemData = alignment_tab[btnTag];
                            -- cclog2(itemData,"itemData ~~~~~~~~~~~~~")
                            local parentNode = tagNode:getParent();
                            local select_sp = parentNode:getChildByTag(btnTag+10);
                            --  cclog2(self.m_guild_teamData,"self.m_guild_teamData ~~~~~~~~~~~~~~")
                            -- cclog2(self.m_guild_other_teamData,"self.m_guild_other_teamData ~~~~~~~~~~")
                            local c_idTab = {};
                            for k,v in pairs(self.m_guild_teamData) do
                                local itemId = self:lua_string_split(v)
                                table.insert(c_idTab,itemId)
                            end
                            local c_idTab2 = {};
                            for k,v in pairs(self.m_guild_other_teamData) do
                                local itemId = self:lua_string_split(v)
                                table.insert(c_idTab2,itemId)
                            end
                            -- cclog2(c_idTab,"c_idTab~~~~~~~~~~~")
                            -- cclog2(c_idTab2,"c_idTab2~~~~~~~~~~~~")
                            local  flag2,k2 = game_util:idInTableById(itemData.c_id,c_idTab2);

                            --是否在有相同类型雇佣卡牌
                            local flag,k = game_util:idInTableById(itemData.c_id,c_idTab);
                            --是否有与自己卡牌相同类型的
                            local flag1,k1 = game_util:idInTableById(itemData.id,self.m_guild_other_teamData);
                            --该卡牌是否被雇佣
                            cclog(flag,flag1,flag2,"fdssgsgdsfgdfsgdfs")
                            if flag1 and k1 ~= nil then
                                    cclog("false l=====")
                                    select_sp:setVisible(false)
                                    table.remove(self.m_guild_other_teamData,k1);
                                    self.sel_cards_data[tostring(itemData.id)] = nil;
                                    self.temp_teamData[tostring(itemData.id)] = nil;
                            elseif flag and k ~= nil then
                                game_util:addMoveTips({text = "Không thể chọn hero giống nhau!"});
                            elseif flag2 and k2 ~= nil then
                                game_util:addMoveTips({text = "Không thể chọn hero giống nhau!"});
                            elseif game_util:getTableLen(self.m_guild_other_teamData) > 2 then
                                    game_util:addMoveTips({text = "Tối đa thuê 3 thẻ"});
                            else
                                cclog("true l=====")
                                select_sp:setVisible(true)
                                table.insert(self.m_guild_other_teamData,itemData.id)
                                self.sel_cards_data[tostring(itemData.id)] = itemData;
                                self.temp_teamData[tostring(itemData.id)] = self.team_index
                                self.team_index = self.team_index + 1
                            end
                            self.m_guildteam_count:setString(#self.m_guild_other_teamData .. "/3")
                            game_data:setGuildOtherTeamData(self.m_guild_other_teamData)
                            game_data:setGuildFormationData(self.temp_teamData) 
                        end
                    end
                    local character_detail_cfg = getConfig("character_detail");
                    local nodeSize = hero_node:getContentSize()
                    local dw = nodeSize.width / #alignment_tab
                    local dx = dw / 2
                    hero_node:removeAllChildrenWithCleanup(true)
                    for i=1,math.min(5,#alignment_tab) do
                        itemData = alignment_tab[i];
                        local ccbNode = luaCCBNode:create()
                        ccbNode:openCCBFile("ccb/ui_godfield_dart_doubtful_icon_.ccbi")
                        ccbNode:setPosition(ccp(dx + (i-1)*dw - 5,20));
                        ccbNode:setScale(0.7)
                        if costlb then
                            costlb:setPosition(ccp(0,-20))
                            ccbNode:addChild(costlb,20,20)
                        end
                        hero_node:addChild(ccbNode,10,10)
                        local icon_node = ccbNode:nodeForName("icon_node")
                        local m_zhandouli = ccbNode:labelTTFForName("m_zhandouli")
                        local m_lv = ccbNode:labelTTFForName("m_lv")
                        local employed_layer = ccbNode:layerForName("employed_layer")
                        heroCfg = character_detail_cfg:getNodeWithKey(itemData.c_id);
                        if itemData and heroCfg then
                            local call_price = heroCfg:getNodeWithKey("call_price"):toInt() 
                            local count,name = self:getCallPrice(call_price)
                            if count or name then
                                local combatlab_cost = game_util:createLabelTTF({text = name.. "x" ..count ,color = ccc3(255,255,255),fontSize = 8})
                                if combatlab_cost then
                                    combatlab_cost:setPosition(ccp(0,-20))
                                    ccbNode:addChild(combatlab_cost,20,20)
                                end
                            end
                            local headIconSpr = game_util:createCardIconByCfg(heroCfg,itemData);
                            if headIconSpr then
                                headIconSpr:setScale(0.85);
                                headIconSpr:setPosition(ccp(0,0));
                                icon_node:addChild(headIconSpr,1,1);
                                local isem = self:isEmployed(itemData.uid,itemData.id)

                                local select_sp = CCSprite:createWithSpriteFrameName("guild_employ_gou.png");
                                select_sp:setPosition(ccp(2,0))
                                select_sp:setScale(1.5)
                                icon_node:addChild(select_sp, 10);
                                select_sp:setTag(i+10);
                                select_sp:setVisible(false);

                                local flag,k = game_util:idInTableById(itemData.id,self.m_guild_other_teamData);
                                if flag and k ~= nil then
                                    select_sp:setVisible(true)
                                    self.sel_cards_data[tostring(itemData.id)] = itemData;
                                    self.temp_teamData[tostring(itemData.id)] = self.team_index
                                    self.team_index = self.team_index + 1
                                else
                                end

                                local combat = math.floor(itemData.combat)
                                m_zhandouli:setString(combat) 
                                local lv = "Lv."..itemData.lv
                                m_lv:setString(lv)                                
                                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                                if isem then
                                    button:setTag(999)
                                    employed_layer:setVisible(true)
                                else
                                    button:setTag(i)
                                    employed_layer:setVisible(false)
                                end
                                button:setOpacity(0)
                                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-8)
                                button:setAnchorPoint(ccp(0.5,0.5))
                                button:setPosition(ccp(0,0))
                                icon_node:addChild(button);
                            end
                        end
                    end
                end
            end    
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        end
    end
    return TableViewHelper:create(params);
end

function game_godfield_dart_pop.isEmployed( self,uid,id )
    if self.employed[tostring(uid)] then
        for k,v in pairs(self.employed[tostring(uid)]) do
            if tostring(v) == tostring(id) then
                return true
            end
        end
    end
    return false
end

function game_godfield_dart_pop.check_id( self,teamData,id )
    -- body
    if teamData then
        for i,v in ipairs(teamData) do
            if tostring(v) == tostring(id) then
                return true
            end
        end
    end
    return false
end


function game_godfield_dart_pop.getCallPrice( self, call_price )
    local thiscount,thisName = "",""
    local guild_employ_cfg = json.decode(getConfig(game_config_field.guild_employ):getFormatBuffer()) or {}
    for i=1,game_util:getTableLen(guild_employ_cfg) do
        if call_price <= guild_employ_cfg[tostring(i)]["call_price"] then
            local reward = guild_employ_cfg[tostring(i)]["employ_price"]
            local icon,name,count = game_util:getRewardByItemTable(reward[1])
            thiscount = count
            thisName = name
            break
        end
    end
    return thiscount,thisName
end


function game_godfield_dart_pop.lua_string_split(self,str)
    local sub_str_tab = {};
    for mu_id in string.gmatch(str, "(%d+)-*") do
        table.insert(sub_str_tab, mu_id)
    end
    return sub_str_tab[1];
end
--[[--
    刷新ui
]]
function game_godfield_dart_pop.refreshUi(self)

    self.m_ownteam_count:setString(#self.m_guild_teamData .. "/5")
    self.m_guildteam_count:setString(#self.m_guild_other_teamData .. "/3")

    self:refreshTableView()
    local count = 0;
end
--[[--
    初始化
]]
function game_godfield_dart_pop.init(self,t_params)
    t_params = t_params or {}
    self.employed = game_data:getUserStatusDataByKey("employed") or {};
    for k,v in pairs(self.employed) do
        print(k,v)
    end
    self.temp_teamData = {}
    self.m_guild_teamData = game_data:getGuildTeamData() or {};
    self.m_guild_other_teamData = game_data:getGuildOtherTeamData(self.m_guild_other_teamData) or {};
    self.enterType = t_params.enterType or ""
    self.openType = t_params.open or ""
    if self.openType == "escort" then
        self.my_team = t_params.my_team or {}
    elseif self.openType == "rob" then
        self.my_team = t_params.my_team or {}
        if self.my_team.vehicle_captain_uid == nil then
            self.my_team.vehicle_captain_uid = t_params.vehicle_captain_uid
        end
        self.my_team.squad = self.my_team.squad or 1
    end
    if self.enterType == "adjust" and t_params.temp then
        self.my_team = t_params.my_team
        self.formation_id = t_params.formation_id
        self.teamData = game_data:getGuildSelTeamId()
        self.params_align_1=""
        for k = 1,5 do
            self.params_align_1 = self.params_align_1 .. self.teamData[k] .. ( k == 5 and "" or "_")
        end
        self.params_align_1 = self.params_align_1 .. "&align_2="
        for k = 6,10 do
            if self.teamData[k] == nil then
                self.params_align_1 = self.params_align_1 .. "-1" .. (k == 10 and "" or "_") 
            else
                self.params_align_1 = self.params_align_1 .. self.teamData[k] .. (k == 10 and "" or "_") 
            end
        end
    end
    self.m_tGameData = {};
    self.sel_cards_data = {};
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getNodeWithKey("guild_employ"):getFormatBuffer()) or {};
        self.cards_dict = json.decode(data:getNodeWithKey("cards_dict"):getFormatBuffer()) or {};
        game_data:setGuildTableCardsData(self.m_tGameData);
        self.guild_employ = self.m_tGameData.guild_employ
    end
    -- cclog2(self.cards_dict,"--------------------")
    local cardsData = game_data:getTableCardsData()
    self.my_cards_data = {}
    for k,v in pairs(self.cards_dict) do
        table.insert(self.my_cards_data,cardsData[k])
    end
    
    local other_data = {}; --没有uid
    local my_uid = game_data:getUserStatusDataByKey("uid") or nil;
    all_data_tab = self.m_tGameData
    self.other_id={}
    if self.guild_employ then
        for k,v in pairs(self.guild_employ) do
            if k == my_uid then
            else
                table.insert(other_data,v)
                self.other_id[#self.other_id + 1] = k
            end
        end
    end
    self.team_index = 0
    self.other_data_tab=other_data
    self.other_team_data = ""
    if self.teamData then
        for i=1,#self.teamData do
            for j=1,#other_data do
                local cards = other_data[j].cards
                for k,v in pairs(cards) do
                    if self.teamData[i] == k then
                        self.other_team_data = self.other_team_data .. "&employ_cards=" .. k .. "_" .. self.other_id[j]
                    end
                end
            end
        end
    end
end
--[[
    创建ui入口并初始化数据
]]
function game_godfield_dart_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_dart_pop;