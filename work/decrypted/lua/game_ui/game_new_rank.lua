---  新競技場
local game_new_rank = {
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
    銷毀ui
]]
function game_new_rank.destroy(self)
    cclog("-----------------game_new_rank destroy-----------------");
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
--[[
   戰鬥力排行        1
   等級排行          2
   競技場排行        3
   聯盟排行          4
   最強橙卡排行       5
   最強紫卡排行       6
   Boss戰排行          7
   生存大挑戰排行      8
   裝備強度排行       9
   世界收復排行       10
   統帥能力排行       11
   點贊排行          12
]]
local rank_name = {
    {title = "rank_combat_title.png",icon = "rank_combat_icon.png",url = "rank_combat",label1 = "rank_user_name.png",label2 = "rank_user_level.png",label3 = "rank_combat_label.png",sort = "combat"},--戰鬥力排行
    
    {title = "rank_level_title.png",icon = "rank_level_icon.png",url = "rank_level",label1 = "rank_user_name.png",label2 = "rank_user_level.png",label3 = "rank_combat_label.png",sort = "level"},--等級排行
    
    {title = "rank_title_arena.png",icon = "rank_arena_icon.png",url = "arena_top",label1 = "rank_user_name.png",label2 = "rank_guild_own.png",label3 = "rank_combat_label.png",sort = "arena"},--競技場排行
    
    {title = "rank_title.png",icon = "rank_guild_icon.png",url = "association_guild_all",label1 = "rank_chairman_name.png",label2 = "rank_guild_name.png",label3 = "rank_guild_research.png",sort = "association"},--聯盟排行
    
    {title = "rank_yellowcard_title.png",icon = "rank_yellowcard_icon.png",url = "user_top_rank",label1 = "rank_user_name.png",label2 = "rank_yellowcard_label.png",label3 = "rank_combat_label.png",sort = "orange_card"},--最強橙卡排行
    
    {title = "rank_purplecard_title.png",icon = "rank_purplecard_icon.png",url = "user_top_rank",label1 = "rank_user_name.png",label2 = "rank_purplecard_label.png",label3 = "rank_combat_label.png",sort = "purple_card"},--最強紫卡排行
    
    {title = "rank_boss_title.png",icon = "rank_boss_icon.png",url = "rank_boss",label1 = "rank_user_name.png",label2 = "rank_last_hurt.png",label3 = "rank_combat_label.png",sort = "worldboss"},--Boss戰排行
    
    {title = "rank_live_title.png",icon = "rank_live_icon.png",url = "active_top",label1 = "rank_user_name.png",label2 = "rank_max_level.png",label3 = "rank_combat_label.png",sort = "active"},--生存大挑戰排行
    
    {title = "rank_equip_title.png",icon = "rank_equip_icon.png",url = "user_top_rank",label1 = "rank_user_name.png",label2 = "rank_equip_label.png",label3 = "rank_combat_label.png",sort = "equipment"},--裝備強度排行
    
    {title = "rank_world_title.png",icon = "rank_world_icon.png",url = "user_top_rank",label1 = "rank_user_name.png",label2 = "rank_world_label.png",label3 = "rank_combat_label.png",sort = "world_regain"},--世界收復排行
    
    {title = "rank_commond_title.png",icon = "rank_commond_icon.png",url = "user_top_rank",label1 = "rank_user_name.png",label2 = "rank_commond_label.png",label3 = "rank_combat_label.png",sort = "commander"},--統帥能力排行
    
    {title = "rank_praise_title.png",icon = "rank_praise_icon.png",url = "user_top_rank",label1 = "rank_user_name.png",label2 = "rank_user_level.png",label3 = "rank_fans.png",sort = "like"},--點贊排行
}
--[[--
    返回
]]
function game_new_rank.back(self,backType)
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
    self:destroy(); 
end
--[[--
    讀取ccbi創建ui
]]
function game_new_rank.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 201 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_new_rank.ccbi");
    --排行榜的控件
    self.select_node = ccbNode:nodeForName("select_node");
    self.show_table_node = ccbNode:nodeForName("show_table_node");
    self.title_sprite = ccbNode:spriteForName("title_sprite");
    self.praise_label = ccbNode:labelTTFForName("praise_label");

    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScale(resolution_config:getScale())
    
    for i=1,3 do
        self.variable_label[i] = ccbNode:labelTTFForName("variable_label" .. i)
    end
    return ccbNode;
end
--[[
    
]]
function game_new_rank.createRankTableView(self,viewSize)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = game_util:getTableLen(rank_name);
    params.direction = kCCScrollViewDirectionVertical;--縱向

    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            -- ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_new_rank_item2.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local title_sprite = ccbNode:spriteForName("title_sprite")
            local rank_select = ccbNode:spriteForName("rank_select")
            if self.select_index == index + 1 then
                rank_select:setVisible(true)
            else
                rank_select:setVisible(false)
            end
            local spriteName = rank_name[index+1].icon
            title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteName));
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            if index + 1 ~= self.select_index then
                self.select_index = index + 1
                self:refreshUi()
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    創建內容列表
]]
function game_new_rank.createContentTable(self,viewSize)
    local parise_already_tab = {};

    local rankLabelName = {"rank_1st.png","rank_2nd.png","rank_3th.png"}
    local colorTab = {ccc3(247,198,9),ccc3(252,234,30),ccc3(255,251,47)}
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCControlButton");
        local btnTag = tagNode:getTag();        
        if btnTag >= 1000 and btnTag < 2000 then
            local index = btnTag - 1000

            local itemData = self.userInfo[index+1]
            if itemData == nil then return end
            local tempUid = itemData.uid;
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_player_info_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, {uid = tempUid},"user_info")
        elseif btnTag >= 2000 and btnTag < 3000 then
            local index = btnTag - 2000
            local itemData = self.userInfo[index+1]
            if itemData == nil then return end

            --點贊等級限制
            local myLevel = game_data:getUserStatusDataByKey("level")
            if myLevel < 20 then
                game_util:addMoveTips({text = "Cấp 20 mới có thể Like!"})
            else
                --點贊接口     url 連接 sort   url_sort
                local function responseMethod(tag,gameData)
                    itemData.parise_flag = true;
                    local data = gameData:getNodeWithKey("data")
                    local reward = data:getNodeWithKey("reward")
                    game_util:rewardTipsByJsonData(reward);
                    tagNode:setTouchEnabled(false);
                    local tempSpri = parise_already_tab[index]
                    if tempSpri then
                        tempSpri:setVisible(true);
                    end
                    self:refreshLabel();
                end
                local params = {};
                params.sort = rank_name[self.select_index].sort;
                params.rank_key = itemData.rank_key;
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_open_like"), http_request_method.GET, params,"user_open_like")
            end
        elseif btnTag >= 3000 then
            cclog("look card info ----------")
            local index = btnTag - 3000
            local itemData = self.userInfo[index+1]
            if itemData == nil then return end
            --查看卡牌     url 連接 sort   url_sort
            local function responseMethod(tag,gameData)
                itemData.parise_flag = true;
                local data = gameData:getNodeWithKey("data")
                local card = data:getNodeWithKey("card")
                if card then
                    local tempData = json.decode(card:getFormatBuffer());
                    game_scene:addPop("game_hero_info_pop",{tGameData = tempData,openType = 3})
                end
            end
            local params = {};
            params.sort = rank_name[self.select_index].sort;
            params.rank_key = itemData.rank_key;
            params.uid = itemData.uid;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_rank_one_cards_info"), http_request_method.GET, params,"user_rank_one_cards_info")
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = game_util:getTableLen(self.userInfo);
    params.direction = kCCScrollViewDirectionVertical;--縱向

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
            local btn_parise = ccbNode:controlButtonForName("btn_parise")--點贊
            local m_sprite9_cellbg = ccbNode:scale9SpriteForName("m_sprite9_cellbg")
            local parise_already = ccbNode:spriteForName("parise_already")
            local rank_number = ccbNode:labelBMFontForName("rank_number")

            local itemData = self.userInfo[index+1]

            local parise_flag = itemData.parise_flag == nil and false or itemData.parise_flag
            if parise_flag == false then
                parise_already:setVisible(false)
                btn_parise:setTouchEnabled(true)
            else
                parise_already:setVisible(true)
                btn_parise:setTouchEnabled(false)
            end
            parise_already_tab[index] = parise_already;
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
            local role = itemData.role or 1
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

                local title_icon = game_util:createTitleRes(itemData.title)
                if title_icon then
                    title_icon:setScale(0.8)
                    title_icon:setPositionY(-15)
                    user_head_node:addChild(title_icon)
                end
            else
                cclog("tempFrontUser.role " .. role .. " not found !")
            end
            btn_look:setOpacity(0)
            btn_look:setTag(1000 + index)
            btn_parise:setTag(2000 + index)
            btn_look_2:setTag(3000 + index)
            btn_look_2:setOpacity(0)
            if self.select_index == 12 then
                btn_parise:setVisible(false)
            else
                btn_parise:setVisible(true)
            end
            --設置不同排行榜的內容
            local variable_node = {}
            for i=1,3 do
                variable_node[i] = ccbNode:nodeForName("node_" .. i)
            end
            
            self:setRankData(variable_node[1],variable_node[2],variable_node[3],itemData,index)

            if self.select_index == 4 or self.select_index == 8 then

            else
                if index >= 19 and index == game_util:getTableLen(self.userInfo) - 1 and self.cur_page < 4 then
                    local tipLabel = game_util:createLabelTTF({text = "Kéo xuống tạo mới",color = ccc3(250,180,0),fontSize = 12});
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
            if self.select_index == 5 or self.select_index == 6 then--最強橙卡/紫卡
                btn_look_2:setVisible(true);
            else
                btn_look_2:setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
        elseif eventType == "refresh" and item then
            --翻頁  4 和 8 無 其他的都有
            if self.select_index == 4 or self.select_index == 8 then

            else
                if self.cur_page < 4 then
                    self.cur_page = self.cur_page + 1
                    self:requestForHttp()
                end
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    設置不同排行榜內容
]]
function game_new_rank.setRankData(self,node1,node2,node3,itemData,index)
    -- local function onBtnCilck( event,target )
    --     local tagNode = tolua.cast(target, "CCNode");
    --     local btnTag = tagNode:getTag();
    --     local itemData2 = self.userInfo[index+1]
    --     cclog2(itemData2,"itemData2")
    --     game_scene:addPop("game_hero_info_pop",{tGameData = itemData2,openType = 3})
    -- end
    local index = self.select_index
    node1:removeAllChildrenWithCleanup(true)
    node2:removeAllChildrenWithCleanup(true)
    node3:removeAllChildrenWithCleanup(true)
    local child1 = nil
    local child2 = nil
    local child3 = nil
    if index == 1 or index == 2 then--戰鬥力、等級
        local name = itemData.name
        local level = itemData.level
        local combat = itemData.combat
        child1 = game_util:createLabelTTF({text = name,fontSize = 12})
        child2 = game_util:createLabelTTF({text = level,fontSize = 12})
        child3 = game_util:createLabelBMFont({text = combat,fnt = "yellow_image_text.fnt"})
    elseif index == 4 then--聯盟  特殊
        local owner = itemData.owner
        local name = itemData.name
        local tech_lv = itemData.tech_lv
        child1 = game_util:createLabelTTF({text = owner,fontSize = 12})
        child2 = game_util:createLabelTTF({text = name,fontSize = 12})
        child3 = game_util:createLabelBMFont({text = tech_lv,fnt = "yellow_image_text.fnt"})
    elseif index == 3 then--競技場
        local name = itemData.name
        local guild_name = itemData.guild_name
        local combat = itemData.combat
        child1 = game_util:createLabelTTF({text = name,fontSize = 12})
        child2 = game_util:createLabelTTF({text = guild_name,fontSize = 12})
        child3 = game_util:createLabelBMFont({text = combat,fnt = "yellow_image_text.fnt"})
    elseif index == 7 or index == 9 or index == 10 or index == 11 then--boss
        local name = itemData.name
        local score = itemData.score
        local combat = itemData.combat
        child1 = game_util:createLabelTTF({text = name,fontSize = 12})
        child2 = game_util:createLabelTTF({text = score,fontSize = 12})
        child3 = game_util:createLabelBMFont({text = combat,fnt = "yellow_image_text.fnt"})
    elseif index == 8 then--生存大考驗
        local name = itemData.name
        local rank = itemData.rank
        local combat = itemData.combat
        child1 = game_util:createLabelTTF({text = name,fontSize = 12})
        child2 = game_util:createLabelTTF({text = rank,fontSize = 12})
        child3 = game_util:createLabelBMFont({text = combat,fnt = "yellow_image_text.fnt"})
    elseif index == 5 or index == 6 then--最強橙卡/紫卡
        local name = itemData.name
        local config_id = itemData.config_id
        local score = math.floor(itemData.score)
        child1 = game_util:createLabelTTF({text = name,fontSize = 12})
        local tempTab = {5,config_id,1}
        local icon,name,count = game_util:getRewardByItemTable(tempTab)
        child2 = icon
        child3 = game_util:createLabelBMFont({text = score,fnt = "yellow_image_text.fnt"})
        -- --加查看按鈕
        -- local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        -- button:setTag(index)
        -- button:setAnchorPoint(ccp(0.5,0.5))
        -- button:setOpacity(0)
        -- child2:addChild(button)
    -- elseif index == 9 then--裝備強化
        
    -- elseif index == 10 then--世界收復度
        
    -- elseif index == 11 then--統率能力

    elseif index == 12 then--點贊
        local name = itemData.name
        local level = itemData.level
        local score = itemData.score
        child1 = game_util:createLabelTTF({text = name,fontSize = 12})
        child2 = game_util:createLabelTTF({text = level,fontSize = 12})
        child3 = game_util:createLabelBMFont({text = score,fnt = "yellow_image_text.fnt"})
    end
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
function game_new_rank.refreshLabel(self)
    local parise_count = game_data:getUserStatusDataByKey("parise_count") or 0;
    local parise_max = game_data:getUserStatusDataByKey("parise_max") or 10;
    self.praise_label:setString("Like:" .. (parise_max - parise_count) .. "/" .. parise_max)
    for i=1,3 do
        local spriteName = rank_name[self.select_index]["label" .. i]
        self.variable_label[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteName))
    end
end
--[[
    添加新數據  當前排行榜添加新數據
]]
function game_new_rank.requestForHttp(self)
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
function game_new_rank.refreshUi(self)
    --聯網重新取數據   切換排行榜
    function responseMethod(tag,gameData)
        if gameData then
            local data = gameData:getNodeWithKey("data");
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            self:formatData(self.m_tGameData)
            --切換完table重置當前頁
            self.cur_page = 0
            self:refreshTab2()
            local spriteName = rank_name[self.select_index].title
            self.title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteName));
            self:refreshLabel()
            self:refreshTab1()
        end
    end
    local params = {}
    local url = rank_name[self.select_index].url
    local sort = rank_name[self.select_index].sort
    params.sort = sort
    params.page = 0
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey(url), http_request_method.GET, params,url,true,true)
end
--[[
    刷新
]]
function game_new_rank.firstRefreshUi(self)
    --聯網重新取數據   切換排行榜
    self:refreshTab2()
    local spriteName = rank_name[self.select_index].title
    self.title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteName));
    self:refreshLabel()
    self:refreshTab1()
end
--[[
    刷新表1
]]
function game_new_rank.refreshTab1(self)
    -- local pX,pY;
    -- if self.m_tableView2 then
    --     pX,pY = self.m_tableView2:getContainer():getPosition();
    -- end
    self.show_table_node:removeAllChildrenWithCleanup(true);
    self.m_tableView2 = nil;
    self.m_tableView2 = self:createContentTable(self.show_table_node:getContentSize());
    self.show_table_node:addChild(self.m_tableView2,10,10);
    -- if pX and pY then
    --     self.m_tableView2:setContentOffset(ccp(pX,pY), false);
    -- end
    local index = self.cur_page * 20
    game_util:setTableViewIndex(index,self.show_table_node,10,5)
end
--[[
    刷新表2
]]
function game_new_rank.refreshTab2(self)
    local pX,pY;
    if self.m_tableView then
        pX,pY = self.m_tableView:getContainer():getPosition();
    end
    self.select_node:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil;
    self.m_tableView = self:createRankTableView(self.select_node:getContentSize());
    self.select_node:addChild(self.m_tableView,33,33);
    if pX and pY then
        self.m_tableView:setContentOffset(ccp(pX,pY), false);
    end
    if self.first_flag == true then
        self.first_flag = false
        game_util:setTableViewIndex(self.select_index-1,self.select_node,33,5)
    end
end
--[[--
    初始化
]]
function game_new_rank.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.praise = 10
    self.select_index = t_params.index or 1
    self.variable_label = {}
    self.cur_page = 0

    self.first_flag = true
    --格式化所有接口數據，返回統一的
    self:formatData(self.m_tGameData)
end
--[[
    格式化接口數據
]]
function game_new_rank.formatData(self,netData)
    local index = self.select_index
    -- if index == 1 or index == 2 or index == 3 or index == 7 or index == 5 or index == 6 or index == 9 then--戰鬥力。等級
    --     self.userInfo = self.m_tGameData.top
    if index == 4 then--聯盟排行
        self.userInfo = self.m_tGameData.guild_list
    elseif index == 8 then--生存大考驗
        self.userInfo = self.m_tGameData.users
    else
        self.userInfo = self.m_tGameData.top
    end
end
--[[--
    創建ui入口並初始化數據
]]
function game_new_rank.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:firstRefreshUi();
    return scene;
end

return game_new_rank;