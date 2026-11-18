---  team pk 排行榜
local game_team_pk_rank = {
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
};
--[[--
    销毁ui
]]
function game_team_pk_rank.destroy(self)
    cclog("-----------------game_team_pk_rank destroy-----------------");
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
end

local rank_name = {
    {title = "rank_title.png",icon = "rank_guild_icon.png",url = "association_guild_all",label1 = "rank_chairman_name.png",label2 = "rank_guild_name.png",label3 = "teampk_score.png",sort = "association"},--联盟排行

}
--[[--
    返回
]]
function game_team_pk_rank.back(self,backType)
    -- game_scene:enterGameUi("game_main_scene",{gameData = nil});
    -- self:destroy(); 
    game_scene:setVisibleBroadcastNode(false);
    local association_id = game_data:getUserStatusDataByKey("association_id");
    if association_id == 0 then
        require("like_oo.oo_controlBase"):openView("guild_join");
    else
        require("like_oo.oo_controlBase"):openView("guild");
    end
end
--[[--
    读取ccbi创建ui
]]
function game_team_pk_rank.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 201 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_pk_rank.ccbi");
    --排行榜的控件
    self.select_node = ccbNode:nodeForName("select_node");
    self.show_table_node = ccbNode:nodeForName("show_table_node");
    self.title_sprite = ccbNode:spriteForName("title_sprite");
    self.praise_label = ccbNode:labelTTFForName("praise_label");
    for i=1,3 do
        self.variable_label[i] = ccbNode:labelTTFForName("variable_label" .. i)
    end
    return ccbNode;
end

--[[
    创建内容列表
]]
function game_team_pk_rank.createContentTable(self,viewSize)
    local parise_already_tab = {};

    local rankLabelName = {"rank_1st.png","rank_2nd.png","rank_3th.png"}
    local colorTab = {ccc3(247,198,9),ccc3(252,234,30),ccc3(255,251,47)}
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCControlButton");
        local btnTag = tagNode:getTag();        
        if btnTag >= 1000 and btnTag < 2000 then
            local index = btnTag - 1000

            local itemData = self.userInfo[tostring(index+1)]
            if itemData == nil then return end
            local tempUid = itemData.owner_uid;
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_player_info_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, {uid = tempUid},"user_info")
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
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
            ccbNode:openCCBFile("ccb/ui_new_rank_item.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local user_head_node = ccbNode:nodeForName("m_icon_node");
            local top_icon = ccbNode:spriteForName("top_icon");
            local btn_look = ccbNode:controlButtonForName("btn_look")--查看
            local btn_look_2 = ccbNode:controlButtonForName("btn_look_2")--查看
            local btn_parise = ccbNode:controlButtonForName("btn_parise")--点赞
            local m_sprite9_cellbg = ccbNode:scale9SpriteForName("m_sprite9_cellbg")
            local parise_already = ccbNode:spriteForName("parise_already")
            local rank_number = ccbNode:labelBMFontForName("rank_number")

            local itemData = self.userInfo[tostring(index+1)]

            btn_parise:setVisible(false)
            parise_already:setVisible(false)
            if index < 3 then
                top_icon:setVisible(true)
                rank_number:setVisible(false)
                top_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(rankLabelName[index+1]))
                m_sprite9_cellbg:setColor(colorTab[index+1])
            else
                top_icon:setVisible(false)
                rank_number:setVisible(true)
                rank_number:setString(index+1)
                m_sprite9_cellbg:setColor(ccc3(255,255,255))
            end
            user_head_node:removeAllChildrenWithCleanup(true)
            local role = itemData.owner_role or 1
            local icon = game_util:createPlayerIconByRoleId(tostring(role));
            local icon_alpha = game_util:createPlayerIconByRoleId(tostring(role));
            if icon then
                user_head_node:removeAllChildrenWithCleanup(true);
                icon_alpha:setAnchorPoint(ccp(0.5,0.5))
                icon_alpha:setPosition(ccp(7,4))
                icon_alpha:setOpacity(100)
                icon_alpha:setColor(ccc3(0,0,0))
                icon_alpha:setScale(0.9)
                user_head_node:addChild(icon_alpha)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(5,5))
                icon:setScale(0.9)
                user_head_node:addChild(icon);
            else
                cclog("tempFrontUser.role " .. role .. " not found !")
            end
            btn_look:setOpacity(0)
            btn_look:setTag(1000 + index)
            --设置不同排行榜的内容
            local variable_node = {}
            for i=1,3 do
                variable_node[i] = ccbNode:nodeForName("node_" .. i)
            end
            
            self:setRankData(variable_node[1],variable_node[2],variable_node[3],itemData,index)
            btn_look_2:setVisible(false);
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
        elseif eventType == "refresh" and item then

        end
    end
    return TableViewHelper:create(params);
end
--[[
    设置不同排行榜内容
]]
function game_team_pk_rank.setRankData(self,node1,node2,node3,itemData,index)
    local index = self.select_index
    node1:removeAllChildrenWithCleanup(true)
    node2:removeAllChildrenWithCleanup(true)
    node3:removeAllChildrenWithCleanup(true)
    local child1 = nil
    local child2 = nil
    local child3 = nil

    local owner = itemData.owner_name
    local name = itemData.association_name
    local score = itemData.score
    child1 = game_util:createLabelTTF({text = owner,fontSize = 12})
    child2 = game_util:createLabelTTF({text = name,fontSize = 12})
    child3 = game_util:createLabelBMFont({text = score,fnt = "yellow_image_text.fnt"})
    child3:setPositionX(15)

    if child1 ~= nil then
        node1:addChild(child1)
    end
    if child2 ~= nil then
        node2:addChild(child2)
    end
    if child3 ~= nil then
        node3:addChild(child3)
    end
end
--[[
    刷新label
]]
function game_team_pk_rank.refreshLabel(self)
    local parise_count = game_data:getUserStatusDataByKey("parise_count") or 0;
    local parise_max = game_data:getUserStatusDataByKey("parise_max") or 10;
    self.praise_label:setString("点赞:" .. (parise_max - parise_count) .. "/" .. parise_max)
    for i=1,3 do
        local spriteName = rank_name[self.select_index]["label" .. i]
        self.variable_label[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteName))
    end
end
--[[
    添加新数据  联盟数据
]]
function game_team_pk_rank.requestForHttp2(self)
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        local guild_list = json.decode(data:getNodeWithKey("guild_list"):getFormatBuffer())
        for i=1,#guild_list do
            table.insert(self.userInfo,guild_list[i])
        end
        self:refreshTab1()
    end
    local params = {}
    local url = rank_name[self.select_index].url
    local sort = rank_name[self.select_index].sort
    params.sort = sort
    params.page = self.cur_page
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey(url), http_request_method.GET, params,url)
end
--[[
    添加新数据  当前排行榜添加新数据
]]
function game_team_pk_rank.requestForHttp(self)
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        local top = json.decode(data:getNodeWithKey("top"):getFormatBuffer())
        for i=1,#top do
            table.insert(self.userInfo,top[i])
        end
        self:refreshTab1()
    end
    local params = {}
    local url = rank_name[self.select_index].url
    local sort = rank_name[self.select_index].sort
    params.sort = sort
    params.page = self.cur_page
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey(url), http_request_method.GET, params,url)
end

--[[
    刷新
]]
function game_team_pk_rank.firstRefreshUi(self)
    --联网重新取数据   切换排行榜
    local spriteName = rank_name[self.select_index].title
    self.title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteName));
    self:refreshLabel()
    self:refreshTab1()
end
--[[
    刷新表1
]]
function game_team_pk_rank.refreshTab1(self)
    self.show_table_node:removeAllChildrenWithCleanup(true);
    self.m_tableView2 = nil;
    self.m_tableView2 = self:createContentTable(self.show_table_node:getContentSize());
    self.show_table_node:addChild(self.m_tableView2,10,10);

    local index = self.cur_page * 20
    game_util:setTableViewIndex(index,self.show_table_node,10,5)
end

--[[--
    初始化
]]
function game_team_pk_rank.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.userInfo = self.m_tGameData.score_ranks
    self.select_index = t_params.index or 1
    self.variable_label = {}
    self.cur_page = 0
end

--[[--
    创建ui入口并初始化数据
]]
function game_team_pk_rank.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:firstRefreshUi();
    return scene;
end

return game_team_pk_rank;