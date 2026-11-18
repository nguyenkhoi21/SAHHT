--- 坠落之地
--- 布阵
local game_godfield_guild_high_war_formation_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
};

--[[--
    销毁
]]
function game_godfield_guild_high_war_formation_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_formation_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
end
--[[--
    返回
]]
function game_godfield_guild_high_war_formation_pop.back(self, need_callback)
    if need_callback then
        self:callBackFunc()
    end
    game_scene:removePopByName("game_godfield_guild_high_war_formation_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_formation_pop.createUi(self)
    self.m_select_index = 1
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 200 then -- 规则    
            local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
            local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(3))
            if itemCfg == nil then return end
            local openMsg = itemCfg:getNodeWithKey("des"):toStr();
            game_scene:addPop("game_godfield_detail_pop",{openMsg = openMsg, btn_touchPriority = 13, touchPriority = 13})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_formation_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    self.label_title = ccbNode:labelTTFForName("label_title") 
    self.label_title:setString("Chi tiết đặt đội hình")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
    self.m_des_btn = ccbNode:controlButtonForName("m_des_btn")
    self.m_des_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)

    self.label_tips1 = ccbNode:labelTTFForName("label_tips1")
    self.label_tips1:setString("Giai đoạn dàn trận")
    self.label_tips1:setVisible(false)
    self.conutdownTime = ccbNode:nodeForName("conutdownTime")
    self.label_tips2 = ccbNode:labelTTFForName("label_tips2")
    self.label_tips2:setString("Hãy cử đội ngũ đi trước khi kết thúc giai đoạn Dàn Trận")
    self.label_tips2:setPositionX(self.label_tips1:getPositionX()+self.label_tips1:getContentSize().width)
    self.node_teams = ccbNode:nodeForName("node_teams") -- 玩家阵容

    self.label_des1 = ccbNode:labelTTFForName("label_des1")
    self.label_des1:setString("1.Mỗi đội ngũ ít nhất có 1 Anh Hùng thì mới được kích hoạt tham gia chiến đấu")
    self.label_des2 = ccbNode:labelTTFForName("label_des2")
    self.label_des2:setString("2.Nhấn vào dàn trận để sắp xếp đội hình. Kết thúc giai đoạn dàn trận không thể sắp xếp nữa")
    
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
function game_godfield_guild_high_war_formation_pop.refreshUi(self)
    self.node_teams:removeAllChildrenWithCleanup(true);
    local tableView = self:createTeamTable(self.node_teams:getContentSize());
    self.node_teams:addChild(tableView,10,10);

end

function game_godfield_guild_high_war_formation_pop.createTeamTable(self,viewSize)
    local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local team_index = btnTag;

        if self.m_step and self.m_step ~= 4 then -- 布阵阶段
            if (self.m_step == 5 or self.m_step == 6 or self.m_step == 7) then -- 丰收日
                local alignment_status = self.m_tGameData.alignment_status[tostring(btnTag)]
                if alignment_status and alignment_status.city then
                    local build_info = guild_high_war_build_cfg:getNodeWithKey(alignment_status.city)
                    local sort = build_info:getNodeWithKey("sort"):toInt()
                    if sort == 3 then  --被资源占位不能布阵
                        return game_util:addMoveTips({text = "Chưa đến thời gian dàn trận"});
                    end
                end
            else
                return game_util:addMoveTips({text = "Chưa đến thời gian dàn trận"});
            end
        end

        if self.m_is_formation then -- 布阵
            local function responseMethod(tag,gameData)
                if gameData then
                    game_scene:enterGameUi("game_god_adjustment",{gameData = gameData,openType= self.m_openType,team_index = team_index, group_id = self.m_group_id, map_offset = self.m_map_offset});
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_upload_god_formation"), http_request_method.GET, nil,"god_field_upload_god_formation",true,true)
        else
            if self.m_openPopType == "game_godfield_guild_high_war_chance_pop" then
                local url = "guild_high_war_stationed_fate"
                local alignment_status = self.m_tGameData.alignment_status[tostring(btnTag)]
                if self.m_chance_formation_type == 1 and alignment_status and alignment_status.city then
                    url = "guild_high_war_down_alignment_fate"
                end
                local params = {city_id = self.m_buildingId, alignment = team_index}
                local function responseMethod(tag,gameData)
                    self:back(true);
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey(url), http_request_method.GET, params,url,true,true)
            
            elseif self.m_openPopType == "game_godfield_guild_high_war_res_pop" then
                local function responseMethod(tag,gameData)
                    self:back(true);
                end 
                local url
                if self.m_formation_type == 2 then --1.离开 2.挑战 3.驻守
                    url = "guild_high_war_declare_war_source"
                elseif self.m_formation_type == 3 then 
                    url = "guild_high_war_stationed_source"
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey(url), http_request_method.GET, {city_id=self.m_buildingId, block_id=self.m_block_id,alignment=team_index},url,true,true)
            elseif self.m_openPopType == "game_godfield_guild_high_war_base_pop" then
                local params = {city_id = self.m_buildingId, alignment = team_index}
                local function responseMethod(tag,gameData)
                    self:back(true);
                end
                local url
                if self.m_att_type == 1 then
                    url = "guild_high_war_set_fight_alignment"
                else
                    url = "guild_high_war_stationed"
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey(url), http_request_method.GET, params,url,true,true) 
            end
        end
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = 3;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_formation_item.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local label_name = ccbNode:labelTTFForName("label_name")
            label_name:setString("Đội hình"..(index + 1))

            local node_team = ccbNode:nodeForName("node_team")
            local label_tips = ccbNode:labelTTFForName("label_tips")
            local m_btn1 = ccbNode:controlButtonForName("m_btn1")
            m_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
            m_btn1:setTag(index+1)
            m_btn1:setVisible(true)
            if self.m_is_formation then
                game_util:setCCControlButtonBackground(m_btn1,"bz_btn01.png")
            else
                game_util:setCCControlButtonBackground(m_btn1,"rz_btn.png")
            end

            -- label_tips
            local tips_str = ""
            local alignment_status = self.m_tGameData.alignment_status[tostring(index+1)]
            if alignment_status and alignment_status.city then
                local build_info = guild_high_war_build_cfg:getNodeWithKey(alignment_status.city)
                local sort = build_info:getNodeWithKey("sort"):toInt()
                local city_name = build_info:getNodeWithKey("city_name"):toStr()
                if sort == 1 then -- 城市
                    tips_str = "Đã nhập trú"..city_name
                    if tostring(self.m_buildingId) == tostring(alignment_status.city)then
                        game_util:setCCControlButtonEnabled( m_btn1, false )
                    end
                elseif sort == 2 then -- 机遇
                    tips_str = "Đã ở"..city_name.."Tham gia thám hiểm"
                    if self.m_chance_formation_type and self.m_chance_formation_type == 1 then
                        game_util:setCCControlButtonBackground(m_btn1,"lk_btn.png")
                    end
                    -- m_btn1:set(not self.m_hide_btn)
                    if tostring(self.m_buildingId) == tostring(alignment_status.city) and self.m_hide_btn ~= nil then
                        game_util:setCCControlButtonEnabled( m_btn1, not self.m_hide_btn )
                    else
                        game_util:setCCControlButtonEnabled( m_btn1, false )
                    end
                else
                    tips_str = "Đã ở"..city_name.."Chiếm vị trí tài nguyên"
                    if tostring(self.m_buildingId) == tostring(alignment_status.city)then
                        game_util:setCCControlButtonEnabled( m_btn1, false )
                    end
                end
            else
                if self.m_openPopType == "game_godfield_guild_high_war_chance_pop" then
                    if self.m_hide_btn then
                        game_util:setCCControlButtonEnabled( m_btn1, false )
                    end
                end
            end
            label_tips:setString(tips_str)

            

            local cards = {}
            for k,v in pairs(self.m_tGameData.alignments[tostring(index + 1)]) do
                if k < 7 and k > 0 and v ~= "0" and v ~= "-1" then
                    table.insert(cards, v)
                end
            end

            local count = #cards
            if count <= 0 then
                label_tips:setString("Ít nhất đưa ra 1 thẻ bài có thể tham gia ra trận")
                label_tips:setColor(ccc3(244,1,2))
            else
                label_tips:setColor(ccc3(0,249,0))
            end
            local viewSize = node_team:getContentSize()
            local px = viewSize.width/count
            local character_detail_cfg = getConfig(game_config_field.character_detail);
            for k,v in pairs(cards) do
                local itemData = self.m_tGameData.alignment_info[v]
                itemData.super_quality_1 = itemData.evo
                local headIconSpr = game_util:createCardIconByCid(itemData.c_id,itemData);
                headIconSpr:setScale(0.8)
                local function onBtnCilck( event,target )
                    local itemData = self.m_tGameData.alignment_info[v]
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
                node_team:addChild(ccb)
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                button:setOpacity(0)
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition(ccp(0,0))
                icon_node:addChild(button);    
            end

            
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));

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
function game_godfield_guild_high_war_formation_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_tParams = t_params
    self.m_is_formation = t_params.is_formation
    self.m_openType = t_params.openType
    self.m_group_id = t_params.group_id 
    self.m_map_offset = t_params.map_offset 
    self.m_openPopType = t_params.openPopType 
    self.m_buildingId = t_params.buildingId
    self.m_block_id = t_params.block_id
    self.m_att_type = t_params.att_type -- 1.宣战2.被宣战
    self.m_formation_type = t_params.formation_type --1.离开 2.挑战 3.驻守
    self.m_chance_formation_type = t_params.chance_formation_type -- --1.离开 2.驻守
    self.m_hide_btn = t_params.hide_btn
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
function game_godfield_guild_high_war_formation_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_godfield_guild_high_war_formation_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params)
    end
end

return game_godfield_guild_high_war_formation_pop;