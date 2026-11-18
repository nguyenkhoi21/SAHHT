---  外域排行榜
local game_fenzheng_rank = {
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
    m_num = nil,
    open_type = nil,
};
--[[--
    销毁ui
]]
function game_fenzheng_rank.destroy(self)
    cclog("-----------------game_fenzheng_rank destroy-----------------");
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
    self.m_num = nil;
    self.open_type = nil;
end
--[[
   战斗力排行        1
   金字塔           2
   运镖             3
   回廊             4
]]
local rank_name = {
    {title = "rank_combat_title.png",icon = "space_battle_power.png",url = "open_door_rank",sort = "combat"},--战斗力排行
    
    {title = "rank_level_title.png",icon = "space_goldtower.png",url = "open_door_rank",sort = "pyramid"},--金字塔
    
    {title = "rank_title_arena.png",icon = "space_guard.png",url = "open_door_rank",sort = "escort"},--运镖
    
    {title = "rank_title.png",icon = "space_huilang.png",url = "open_door_rank",sort = "maze"},--回廊
}
--[[--
    返回
]]
function game_fenzheng_rank.back(self,backType) 
    if self.open_type == "fenzheng" then
        local function responseMethod( tag,gameData )
            game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, {},"team_pk_new_index")
    else

        local function responseMethod( tag,gameData )
            game_scene:enterGameUi("game_godfield_arean",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")
    end
end
--[[--
    读取ccbi创建ui
]]
function game_fenzheng_rank.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 200 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfiled_rank.ccbi");
    local variable_label2 = ccbNode:spriteForName("variable_label2")
    local variable_label1 = ccbNode:spriteForName("variable_label1")
    local m_yinying_sp1 = ccbNode:spriteForName("m_yinying_sp1")
    local m_yinying_sp2 = ccbNode:spriteForName("m_yinying_sp2")
    local m_yinying_sp3 = ccbNode:spriteForName("m_yinying_sp3")
    local m_yinying_sp4 = ccbNode:spriteForName("m_yinying_sp4")
    local m_server_name = ccbNode:spriteForName("m_server_name")
    local m_server_score = ccbNode:spriteForName("m_server_score")

    variable_label2:setVisible(false)
    variable_label1:setVisible(false)
    m_yinying_sp1:setVisible(false)
    m_yinying_sp2:setVisible(false)
    m_yinying_sp3:setVisible(false)
    m_yinying_sp4:setVisible(false)
    m_server_name:setVisible(true)
    m_server_score:setVisible(true)
    self.show_table_node = ccbNode:nodeForName("show_tabel_node");
    self.title_sprite = ccbNode:spriteForName("title_sprite");
    self:refreshTab()
    return ccbNode;
end

--[[
    创建内容列表
]]
function game_fenzheng_rank.createContentTable(self,viewSize)
    local parise_already_tab = {};
    local rankLabelName = {"rank_1st.png","rank_2nd.png","rank_3th.png"}
    local colorTab = {ccc3(247,198,9),ccc3(252,234,30),ccc3(255,251,47)}
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCControlButton");
        local btnTag = tagNode:getTag();        
        if btnTag >= 1000 and btnTag < 2000 and self.open_type ~= "fenzheng" then
            local index = btnTag - 1000

            local itemData = self.m_tGameData[index+1]
            if itemData == nil then return end
            local tempUid = itemData.uid;
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_player_info_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, {uid = tempUid},"user_info")
        elseif btnTag >= 2000 and btnTag < 3000 then

        elseif btnTag >= 3000 then
            
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1; --列
    params.totalItem =  self.m_num
    params.direction = kCCScrollViewDirectionVertical;--纵向

    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_space_rank_item.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local itemData = self.m_tGameData[tostring(index+1)]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local user_head_node = ccbNode:nodeForName("m_icon_node");
            local top_icon = ccbNode:spriteForName("top_icon");
            local btn_look = ccbNode:controlButtonForName("btn_look")--查看
            local m_sprite9_cellbg = ccbNode:scale9SpriteForName("m_sprite9_cellbg")
            local m_sprite9_cellbg2 = ccbNode:scale9SpriteForName("m_sprite9_cellbg2")

            local rank_number = ccbNode:labelBMFontForName("rank_number")
            local label1 = ccbNode:labelTTFForName("label1")
            local label2 = ccbNode:labelTTFForName("label2")
            label2:setVisible(false)
            local posx,posy = label1:getPosition()
            label1:setPosition(ccp(55,posy))
            local label3 = ccbNode:labelTTFForName("label3")
            local Ser = tostring(itemData.server_name)
            label1:setString(tostring(itemData.server_name))
            -- label2:setString(tostring(itemData.level))
            label3:setString(tostring(itemData.score))    
            --cclog2(self.m_tGameData,"tableview  itmedata")
            if index < 3 then
                top_icon:setVisible(true)
                rank_number:setVisible(false)
                top_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(rankLabelName[index+1]))
                -- m_sprite9_cellbg:setColor(colorTab[index+1])
                m_sprite9_cellbg:setVisible(false)
                m_sprite9_cellbg2:setVisible(true)
            else
                top_icon:setVisible(false)
                rank_number:setVisible(true)
                rank_number:setString(index+1)
                m_sprite9_cellbg:setVisible(true)
                m_sprite9_cellbg2:setVisible(false)
                -- m_sprite9_cellbg:setColor(ccc3(255,255,255))
            end
            user_head_node:removeAllChildrenWithCleanup(true)
            -- local role = itemData.role or 1
            -- local icon = game_util:createPlayerIconByRoleId(tostring(role));
            -- local icon_alpha = game_util:createPlayerIconByRoleId(tostring(role));
            -- if icon then
            --     user_head_node:removeAllChildrenWithCleanup(true);
            --     icon_alpha:setAnchorPoint(ccp(0.5,0.5))
            --     icon_alpha:setPosition(ccp(7,4))
            --     icon_alpha:setOpacity(100)
            --     icon_alpha:setColor(ccc3(0,0,0))
            --     icon_alpha:setScale(0.9)
            --     user_head_node:addChild(icon_alpha)
            --     icon:setAnchorPoint(ccp(0.5,0.5))
            --     icon:setPosition(ccp(5,5))
            --     icon:setScale(0.9)
            --     user_head_node:addChild(icon);
            -- else
            --     cclog("tempFrontUser.role " .. role .. " not found !")
            -- end
            btn_look:setOpacity(0)
            btn_look:setTag(1000 + index)
            --设置不同排行榜的内容
            -- local variable_node = {}
            -- for i=1,3 do
            --     variable_node[i] = ccbNode:nodeForName("node_" .. i)
            -- end
            
            -- self:setRankData(variable_node[1],variable_node[2],variable_node[3],itemData,index)

            if index >= 19 and index == game_util:getTableLen(self.userInfo) - 1 and self.cur_page < 4 then
                local tipLabel = game_util:createLabelTTF({text = "Kéo tạo mới",color = ccc3(250,180,0),fontSize = 12});
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
            -- -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            -- local itemData = self.m_tGameData[tostring(index+1)]
            -- if itemData == nil then return end
            -- local tempUid = itemData.uid;
            -- local function responseMethod(tag,gameData)
            --     game_scene:addPop("game_player_info_pop",{gameData = gameData})
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, {uid = tempUid},"user_info")
        end
    end
    return TableViewHelper:create(params);
end



--[[
    刷新表
]]
function game_fenzheng_rank.refreshTab(self)
    local pX,pY;
    if self.m_tableView then
        pX,pY = self.m_tableView:getContainer():getPosition();
    end
    self.show_table_node:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil;
    self.m_tableView = self:createContentTable(self.show_table_node:getContentSize());
    self.show_table_node:addChild(self.m_tableView,33,33);
    if pX and pY then
        self.m_tableView:setContentOffset(ccp(pX,pY), false);
    end
    -- if self.first_flag == true then
    --     self.first_flag = false
    --     if self.select_node then 
    --         game_util:setTableViewIndex(self.select_index-1,self.select_node,33,5)
    --     end
    -- end
end
--[[--
    初始化
]]
function game_fenzheng_rank.init(self,t_params)
    t_params = t_params or {}
    self.m_tGameData = t_params.gameData 
    self.open_type = t_params.backtype
    local params = {}
    -- cclog2(self.m_tGameData,"m_tGameData === ")
    for k,v in pairs(self.m_tGameData) do
        print(k,v)
        table.insert( params, k )
    end
    self.m_num = #params
    --格式化所有接口数据，返回统一的
    --self:formatData(self.m_tGameData)
end
--[[
    格式化接口数据
]]

--[[--
    创建ui入口并初始化数据
]]
function game_fenzheng_rank.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    --self:firstRefreshUi();
    return scene;
end

return game_fenzheng_rank;