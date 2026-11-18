---  跨服擂台排行榜
local game_league_rank = {
    m_tGameData = nil,
    m_tableView = nil,
    m_tableView2 = nil,
    select_node = nil,
    show_table_node = nil,
    title_sprite = nil,
    praise_label = nil,
    variable_label = nil,
    praise = nil,
    select_index = nil,
    first_flag = nil,
    enterType = nil,
};
--[[--
    销毁ui
]]
function game_league_rank.destroy(self)
    cclog("-----------------game_league_rank destroy-----------------");
    self.m_tGameData = nil;
    --排行榜的控件
    self.m_tableView = nil;
    self.m_tableView2 = nil;
    self.select_node = nil;
    self.show_table_node = nil;
    self.title_sprite = nil;
    self.praise_label = nil;
    self.variable_label = nil;
    self.praise = nil;
    self.select_index = nil;
    self.first_flag = nil;
    self.enterType = nil;
end
--[[
   战斗力排行        1
   金字塔           2
   运镖             3
   回廊             4
]]
local rank_name = {
    {title = "rank_combat_title.png",icon = "ui_league_btn_r_3.png",url = "open_door_rank",sort = "combat"},--战斗力排行
    
    {title = "rank_level_title.png",icon = "ui_league_btn_r_2.png",url = "open_door_rank",sort = "pyramid"},--金字塔
    
    {title = "rank_title_arena.png",icon = "ui_league_btn_r_1.png",url = "open_door_rank",sort = "escort"},--运镖

}
--[[--
    返回
]]
function game_league_rank.back(self,backType)
    -- game_scene:enterGameUi("game_main_scene")
    -- self:destroy()
    if self.enterType == "game_league_signup" then
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local stage = data:getNodeWithKey("stage")
            if stage then
                stage = stage:toInt()
            end
            if stage == 2 then 
                game_util:addMoveTips({text = "Đang tự động chia nhóm, vui lòng đợi!"}) --正在自动分组，请稍后！
            elseif stage == 4 then
                game_util:addMoveTips({text = "Đang kết toán, vui lòng đợi!"}) --正在结算，请稍后！
            else
                game_scene:enterGameUi("game_league_signup",{gameData = gameData})
                self:destroy()
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_index"), http_request_method.GET, nil,"world_one_index")
    else
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_league_main",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_enter_game"), http_request_method.GET, nil,"world_one_enter_game")
    end
end
--[[--
    读取ccbi创建ui
]]
function game_league_rank.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_league_rank.ccbi");
    --排行榜的控件
    self.select_node = ccbNode:nodeForName("select_node");
    self.show_table_node = ccbNode:nodeForName("show_tabel_node");
    
    return ccbNode;
end
--[[
    创建内容列表
]]
function game_league_rank.createContentTable(self,viewSize)
    local parise_already_tab = {};
    local rankLabelName = {"rank_1st.png","rank_2nd.png","rank_3th.png"}
    local colorTab = {ccc3(247,198,9),ccc3(252,234,30),ccc3(255,251,47)}
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCControlButton");
        local btnTag = tagNode:getTag();        
        cclog("btnTag == " .. btnTag)
        local index = btnTag - 1000
        local itemData = self.userInfo[index+1]
        if itemData == nil then return end
        local tempUid = itemData.uid;
        local function responseMethod(tag,gameData)
            game_scene:addPop("game_league_enemy_pop",{gameData = gameData,enterType = "game_league_rank"})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_see_player_info"), http_request_method.GET, {uid = tempUid},"world_one_see_player_info")
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1; --列
    params.totalItem = game_util:getTableLen(self.userInfo);
    params.direction = kCCScrollViewDirectionVertical;--纵向

    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_game_league_rank_item.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local user_head_node = ccbNode:nodeForName("m_icon_node");
            local btn_look = ccbNode:controlButtonForName("btn_look")--查看

            local label1 = ccbNode:labelTTFForName("label1")
            local label2 = ccbNode:labelTTFForName("label2")
            local label3 = ccbNode:labelTTFForName("label3")

            local itemData = self.userInfo[index+1]
            label1:setString(itemData.user_name)
            label2:setString(itemData.win_times)
            label3:setString(itemData.user_combat)

            user_head_node:removeAllChildrenWithCleanup(true)
            local role = itemData.user_role or 1
            local icon = game_util:createPlayerIconByRoleId(tostring(role));
            if icon then
                user_head_node:removeAllChildrenWithCleanup(true);
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setScale(0.6)
                user_head_node:addChild(icon);
            else
                cclog("tempFrontUser.role " .. role .. " not found !")
            end
            btn_look:setOpacity(0)
            btn_look:setTag(1000 + index)


            if index >= 19 and index == game_util:getTableLen(self.userInfo) - 1 and self.cur_page < 5 then
                local tipLabel = game_util:createLabelTTF({text = "Kéo xuống tạo mới",color = ccc3(250,180,0),fontSize = 12}); --下拉刷新
                tipLabel:setAnchorPoint(ccp(0.5,0.5))
                tipLabel:setPosition(ccp(itemSize.width*0.5,-20))
                cell:addChild(tipLabel,20,20)
            else
                local tempNode = cell:getChildByTag(20)
                if tempNode then
                    tempNode:removeFromParentAndCleanup(true)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
        elseif eventType == "refresh" and item then
            if self.cur_page < 4 then
                self.cur_page = self.cur_page + 1
                self:requestForHttp()
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    添加新数据  当前排行榜添加新数据
]]
function game_league_rank.requestForHttp(self)
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        local uid_ranks = json.decode(data:getNodeWithKey("uid_ranks"):getFormatBuffer())
        for i=1,game_util:getTableLen(uid_ranks) do
            table.insert(self.userInfo,uid_ranks[tostring(i)])
        end
        self:refreshUi()
    end
    local params = {}
    params.page = self.cur_page
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_get_team_rank"), http_request_method.GET, params,"world_one_get_team_rank")
end
--[[
    刷新
]]
function game_league_rank.refreshUi(self)
    self.show_table_node:removeAllChildrenWithCleanup(true);
    self.m_tableView2 = nil;
    self.m_tableView2 = self:createContentTable(self.show_table_node:getContentSize());
    self.show_table_node:addChild(self.m_tableView2,10,10);
    local index = (self.cur_page - 1) * 20
    game_util:setTableViewIndex(index,self.show_table_node,10,5)
end

--[[--
    初始化
]]
function game_league_rank.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.enterType = t_params.enterType
    self.cur_page = 1
    --格式化所有接口数据，返回统一的
    self:formatData(self.m_tGameData)
end
--[[
    格式化接口数据
]]
function game_league_rank.formatData(self,netData)
    self.userInfo = {}
    for i=1,game_util:getTableLen(self.m_tGameData.uid_ranks) do
        table.insert(self.userInfo,self.m_tGameData.uid_ranks[tostring(i)])
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_league_rank.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_league_rank;