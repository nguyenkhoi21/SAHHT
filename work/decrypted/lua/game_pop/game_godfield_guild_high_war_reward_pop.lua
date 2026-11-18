--- 坠落之地
--- 奖励
local game_godfield_guild_high_war_reward_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_select_index = nil,
    m_scoreReward_tableView1 = nil,
    m_scoreReward_tableView2 = nil,
};

--[[--
    销毁
]]
function game_godfield_guild_high_war_reward_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_reward_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_select_index = nil;
    self.m_scoreReward_tableView1 = nil;
    self.m_scoreReward_tableView2 = nil;
end
--[[--
    返回
]]
function game_godfield_guild_high_war_reward_pop.back(self)
    game_scene:removePopByName("game_godfield_guild_high_war_reward_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_reward_pop.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/godfield_main_res.plist");

    self.m_select_index2 = 1
    self.m_box_index = 1
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag >= 101 and btnTag <= 103 then -- 每日宝箱/占领积分/鲜血宝箱
            if self.m_select_index ~= btnTag - 100 then
                
                if btnTag - 100 == 1 then
                    local function responseMethod( tag, gameData )
                        self.m_select_index = btnTag - 100
                        game_scene:addPop("game_godfield_guild_high_war_reward_pop",{gameData = gameData, select_index = self.m_select_index})                  
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_box_index"), http_request_method.GET, nil,"guild_high_war_box_index")
                elseif btnTag - 100 == 2 then
                    local function responseMethod( tag, gameData )
                        self.m_select_index = btnTag - 100
                        game_scene:addPop("game_godfield_guild_high_war_reward_pop",{gameData = gameData, select_index = self.m_select_index})                  
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_get_rank"), http_request_method.GET, {rank_type = 1},"guild_high_war_get_rank")
                else
                    local function responseMethod( tag, gameData )
                        self.m_select_index = btnTag - 100
                        game_scene:addPop("game_godfield_guild_high_war_reward_pop",{gameData = gameData, select_index = self.m_select_index})                  
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_get_rank"), http_request_method.GET, {rank_type = 0},"guild_high_war_get_rank")
                end
            end
        elseif btnTag == 200 then -- 规则    
            local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
            local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(10))
            if itemCfg == nil then return end
            local openMsg = itemCfg:getNodeWithKey("des"):toStr();
            game_scene:addPop("game_godfield_detail_pop",{openMsg = openMsg, btn_touchPriority = 12, touchPriority = 12})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_reward_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    self.label_title = ccbNode:labelTTFForName("label_title") 
    self.label_title:setString("Thưởng")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_des_btn = ccbNode:controlButtonForName("m_des_btn")
    self.m_des_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)


    self.m_btn1 = ccbNode:controlButtonForName("m_btn1")
    self.m_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    game_util:setCCControlButtonTitle(self.m_btn1,"Rương Báu mỗi ngày")
    self.m_btn2 = ccbNode:controlButtonForName("m_btn2")
    self.m_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    game_util:setCCControlButtonTitle(self.m_btn2,"Điểm chiếm lĩnh")
    self.m_btn3 = ccbNode:controlButtonForName("m_btn3")
    self.m_btn3:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    game_util:setCCControlButtonTitle(self.m_btn3,"Rương Huyết Tinh")

    --每日宝箱
    self.node_1 = ccbNode:nodeForName("node_1")
    self.node_1:setVisible(false)
    self.node_box_select_list = ccbNode:nodeForName("node_box_select_list")
    self.node_box_reward_list = ccbNode:nodeForName("node_box_reward_list")
    self.label_box_name1 = ccbNode:labelTTFForName("label_box_name1")
    self.label_box_name2 = ccbNode:labelTTFForName("label_box_name2")
    self.label_box_name3 = ccbNode:labelTTFForName("label_box_name3")
    self.label_box_name4 = ccbNode:labelTTFForName("label_box_name4")

    --占领积分/鲜血宝箱
    self.node_2 = ccbNode:nodeForName("node_2")
    self.node_2:setVisible(false)
    self.node_reward_list = ccbNode:nodeForName("node_reward_list")
    self.node_icon = ccbNode:nodeForName("node_icon")
    self.label_name = ccbNode:labelTTFForName("label_name")
    self.label_score = ccbNode:labelTTFForName("label_score")
    self.label_rank = ccbNode:labelTTFForName("label_rank")

    self.label_tips = ccbNode:labelTTFForName("label_tips")
    local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
    local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(26))
    local openMsg = itemCfg:getNodeWithKey("des"):toStr();
    self.label_tips:setString(openMsg)

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
function game_godfield_guild_high_war_reward_pop.refreshUi(self)
    local association_id = self.m_tGameData.ass_id
    local uid = game_data:getUserStatusDataByKey("uid")
    self.label_tips:setVisible(self.m_select_index == 1)
    if self.m_select_index == 1 then -- 每日宝箱
        game_util:setCCControlButtonBackground(self.m_btn1,"yq_btn01.png")
        game_util:setCCControlButtonBackground(self.m_btn2,"yq_btn02.png")
        game_util:setCCControlButtonBackground(self.m_btn3,"yq_btn02.png")
        self.node_1:setVisible(true)
        self.node_2:setVisible(false)
        local select_list = {"Ngân Hà","Carina","Mặc Tử","Chức Nữ","Nhân Mã","Orion","Weber"}
        self.node_box_select_list:removeAllChildrenWithCleanup(true);
        self.m_select_tableView = self:createSelectTableView(self.node_box_select_list:getContentSize(), select_list);
        self.node_box_select_list:addChild(self.m_select_tableView);
        self.m_select_tableView:setScrollBarVisible(false);


        local max_count, cur_count = self:getBoxCountById(1)
        self.label_box_name1:setString("Chí Tôn:"..cur_count.."/"..max_count)
        local max_count, cur_count = self:getBoxCountById(2)
        self.label_box_name2:setString("Vàng:"..cur_count.."/"..max_count)
        local max_count, cur_count = self:getBoxCountById(3)
        self.label_box_name3:setString("Bạc:"..cur_count.."/"..max_count)
        local max_count, cur_count = self:getBoxCountById(4)
        self.label_box_name4:setString("Vàng Đồng:"..cur_count.."/"..max_count)


        local box_list = {}
        for k,v in pairs(self.m_tGameData.reward_record) do
            if tonumber(k) > 9*(self.m_select_index2-1) and tonumber(k) <= 9*self.m_select_index2 then
                table.insert(box_list, {data = v, index = k})
            end
        end

        table.sort(box_list,function(data1,data2) return tonumber(data1.index) < tonumber(data2.index) end)

        self.node_box_reward_list:removeAllChildrenWithCleanup(true);
        self.m_box_tableView = self:createBoxTableView(self.node_box_reward_list:getContentSize(), box_list);
        self.node_box_reward_list:addChild(self.m_box_tableView);
        self.m_box_tableView:setScrollBarVisible(false);

        for k,v in pairs(self.m_tGameData.reward_record) do
            if v.uid and uid == v.uid then
                self.m_today_times = 0
                break
            end
        end

    elseif self.m_select_index == 2 then -- 占领积分
        game_util:setCCControlButtonBackground(self.m_btn1,"yq_btn02.png")
        game_util:setCCControlButtonBackground(self.m_btn2,"yq_btn01.png")
        game_util:setCCControlButtonBackground(self.m_btn3,"yq_btn02.png")
        self.node_1:setVisible(false)
        self.node_2:setVisible(true)


        local self_rank_info = {}
        for k,v in pairs(self.m_tGameData.rank) do
            if v.guild_id == association_id then 
                self_rank_info = v
                break
            end
        end


        self.label_name:setString(self_rank_info.name or "")

        self.node_icon:removeAllChildrenWithCleanup(true);
        local icon_str = ""
        if tonumber(self_rank_info.icon) > 9 then
            icon_str = self_rank_info.icon
        else
            icon_str = "0"..self_rank_info.icon
        end

        local guild_icon = CCSprite:create("ccbResources/guild_high_war/" .. "gh_icon"..icon_str..".png");

        self.node_icon:addChild(guild_icon)
        self.label_score:setString("Điểm công hội:"..self.m_tGameData.self_score)
        self.label_rank:setString("XH công hội:"..self.m_tGameData.self_rank)


        if self.m_scoreReward_tableView1 then
            self.m_lastTableViewPosY1 = self.m_scoreReward_tableView1:getContentOffset().y
        end

        local guild_high_war_reward_season_cfg = getConfig(game_config_field.guild_high_war_reward_season)
        guild_high_war_reward_season_cfg = json.decode(guild_high_war_reward_season_cfg:getFormatBuffer())
        local reward_list = {}
        for k,v in pairs(guild_high_war_reward_season_cfg) do
            reward_list[tonumber(k)] = v
        end
        self.node_reward_list:removeAllChildrenWithCleanup(true);
        self.m_scoreReward_tableView1 = self:createScoreRewardTableView(self.node_reward_list:getContentSize(), reward_list,1);
        self.node_reward_list:addChild(self.m_scoreReward_tableView1);
        self.m_scoreReward_tableView1:setScrollBarVisible(false);

        -- 重置位置
        if self.m_lastTableViewPosY1 then
            local contentSize = self.m_scoreReward_tableView1:getContentSize()
            self.m_lastTableViewPosY1 = math.max(-1 * contentSize.height, self.m_lastTableViewPosY1)
            self.m_scoreReward_tableView1:setContentOffset(ccp(0, self.m_lastTableViewPosY1));
        end

    else -- 鲜血宝箱
        game_util:setCCControlButtonBackground(self.m_btn1,"yq_btn02.png")
        game_util:setCCControlButtonBackground(self.m_btn2,"yq_btn02.png")
        game_util:setCCControlButtonBackground(self.m_btn3,"yq_btn01.png")
        self.node_1:setVisible(false)
        self.node_2:setVisible(true)

        local show_name = game_data:getUserStatusDataByKey("show_name")
        self.label_name:setString(show_name)

        self.node_icon:removeAllChildrenWithCleanup(true)
        local role = game_data:getUserStatusDataByKey("role")
        local tempIcon = game_util:createPlayerIconByRoleId(role)
        self.node_icon:addChild(tempIcon)

        self.label_score:setString("Điểm Huyết Tinh"..self.m_tGameData.self_score)
        self.label_rank:setString("BXH Huyết Tinh"..self.m_tGameData.self_rank)

        if self.m_scoreReward_tableView2 then
            self.m_lastTableViewPosY2 = self.m_scoreReward_tableView1:getContentOffset().y
        end

        local guild_high_war_reward_person_cfg = getConfig(game_config_field.guild_high_war_reward_person)
        guild_high_war_reward_person_cfg = json.decode(guild_high_war_reward_person_cfg:getFormatBuffer())
        local reward_list = {}
        for k,v in pairs(guild_high_war_reward_person_cfg) do
            reward_list[tonumber(k)] = v
        end
        self.node_reward_list:removeAllChildrenWithCleanup(true);
        self.m_scoreReward_tableView2 = self:createScoreRewardTableView(self.node_reward_list:getContentSize(), reward_list,2);
        self.node_reward_list:addChild(self.m_scoreReward_tableView2);
        self.m_scoreReward_tableView2:setScrollBarVisible(false);

        -- 重置位置
        if self.m_lastTableViewPosY2 then
            local contentSize = self.m_scoreReward_tableView2:getContentSize()
            self.m_lastTableViewPosY2 = math.max(-1 * contentSize.height, self.m_lastTableViewPosY2)
            self.m_scoreReward_tableView2:setContentOffset(ccp(0, self.m_lastTableViewPosY2));
        end
    end
end

------宝箱总数量，剩余数量
function game_godfield_guild_high_war_reward_pop.getBoxCountById(self,id)
    local count1 = 0
    local count2 = 0

    for k,v in pairs(self.m_tGameData.all_gift) do
        if v[2] and tonumber(v[2]) == tonumber(id) then
            count1 = count1 +  1
        end
    end
    for k,v in pairs(self.m_tGameData.reward_record) do
        if tonumber(v.box_id) == tonumber(id) then
            count1 = count1 + 1
            if v.got == 1 then
                count2 = count2 + 1
            end
        end
    end
    return count1, count1 - count2
end

--[[--
    创建 宝箱选择 列表
]]
function game_godfield_guild_high_war_reward_pop.createSelectTableView(self,viewSize, showData)
    -- self.m_selTitleId = 1
    self.m_selListItem = nil;
    local cardsCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 9;--行
    params.column = 1; --列
    params.totalItem = cardsCount;
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
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_reward_item3.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            local spr_bg = ccbNode:spriteForName("spr_bg")
            local label_name = ccbNode:labelTTFForName("label_name")

            if self.m_select_index2 == index + 1 then
                game_util:setSpriteDisplayBySpriteFrameName(spr_bg, "jl_bg02.png")
            else
                game_util:setSpriteDisplayBySpriteFrameName(spr_bg, "jl_bg01.png")
            end            

            local count = 0
            for k,v in pairs(self.m_tGameData.reward_record) do
                if tonumber(k) > 9*(index) and tonumber(k) <= 9*(index+1) and v.got == 0 then
                    count = count + 1
                end
            end

            label_name:setString(showData[index+ 1].."（"..count.."/9）")

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
            self.m_select_index2 = index + 1
            self:refreshUi()
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        -- self.m_selListItem = nil;
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end

--[[--
    创建 宝箱 列表
]]
function game_godfield_guild_high_war_reward_pop.createBoxTableView(self,viewSize, showData)
    local cardsCount = #showData

    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 3; --列
    params.totalItem = cardsCount;
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
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_reward_item1.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            local node_box = ccbNode:nodeForName("node_box")
            local node_icon = ccbNode:nodeForName("node_icon")
            local label_status = ccbNode:labelTTFForName("label_status")
            local data = showData[index + 1]
            local icon 
            node_icon:removeAllChildrenWithCleanup(true)
            if data.data.got == 0 then
                label_status:setString("Chưa mở")
                icon = CCSprite:createWithSpriteFrameName("godfield_silver.png")
                label_status:setColor(ccc3(200,232,249))
            else
                local guild_high_war_box_cfg = getConfig(game_config_field.guild_high_war_box)
                local box_cfg = guild_high_war_box_cfg:getNodeWithKey(data.data.box_id)
                if box_cfg:getNodeWithKey("box_icon") then
                    local box_icon = box_cfg:getNodeWithKey("box_icon"):toStr()
                    icon = CCSprite:create("icon/"..box_icon..".png")
                    icon:setColor(ccc3(150,150,150))
                else
                    icon = CCSprite:create("icon/dj_icon09.png")
                    icon:setColor(ccc3(150,150,150))
                end
                label_status:setString("Đã mở")
                label_status:setColor(ccc3(101,118,125))
            end
            node_icon:addChild(icon)
            local node_open = ccbNode:nodeForName("node_open")
            node_open:setVisible(data.data.got ~= 0)
            local label_name = ccbNode:labelTTFForName("label_name")
            label_name:setString(data.data.name)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
            if self.m_today_times == 0 then
                return game_util:addMoveTips({text = "Số lần còn lại hôm nay không đủ!"});
            end
            local data = showData[index + 1]
            if data.data.got == 0 then -- 未领取
                local function responseMethod( tag,gameData )
                    if gameData ~= nil and tolua.type(gameData) == "util_json" then
                        local data = gameData:getNodeWithKey("data");
                        game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    end
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_select_reward"), http_request_method.GET, {gift_id = data.index},"guild_high_war_select_reward")
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        -- self.m_selListItem = nil;
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end


--[[--
    创建 积分奖励预览 列表
]]
function game_godfield_guild_high_war_reward_pop.createScoreRewardTableView(self,viewSize, showData,sort)
    -- self.m_selTitleId = 1
    self.m_selListItem = nil;
    local cardsCount = #showData

    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.totalItem = cardsCount;
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
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_reward_item2.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            local node_rewards = ccbNode:nodeForName("node_rewards")
            local label_score = ccbNode:labelTTFForName("label_score")
            local data = showData[index + 1]
            node_rewards:removeAllChildrenWithCleanup(true);
            local m_tableView1 = self:createItemTable(node_rewards:getContentSize(), data.reward);
            node_rewards:addChild(m_tableView1);
            m_tableView1:setScrollBarVisible(false);
            
            if sort == 1 then
                if index+1 == cardsCount then
                    label_score:setString(data.need.."điểm trở lên")
                else
                    label_score:setString(data.need.."điểm")
                end
            else
                if data.rank[1] == data.rank[2] then
                    label_score:setString("Thứ"..data.rank[1])
                else
                    label_score:setString("Thứ"..data.rank[1].."~"..data.rank[2])
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
        -- self.m_selListItem = nil;
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end



function game_godfield_guild_high_war_reward_pop.createItemTable(self,viewSize,rewardList)
    
    local count = #rewardList
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 3; --列
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionHorizontal;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5,0.5))
            node:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            cell:addChild(node)
            local itemGift = rewardList[index+1]

            local icon,name,count = game_util:getRewardByItemTable(itemGift)
            if icon then
                icon:setScale(0.7)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,0))
                node:addChild(icon,10)
            end
            if count then
                local nameLabel = game_util:createLabelTTF({text = "x"..count})
                nameLabel:setColor(ccc3(255,255,255))
                nameLabel:setAnchorPoint(ccp(0.5, 0.5))
                nameLabel:setPosition(icon:getContentSize().width * 0.5, 5)
                icon:addChild(nameLabel, 11)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemCfg = rewardList[index+1]
            if not is_box then
                game_util:lookItemDetal(itemCfg)
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        
    end
    return TableViewHelper:create(params);
end


--[[--
    初始化
]]
function game_godfield_guild_high_war_reward_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_today_times = 1
    self.m_select_index = t_params.select_index or 1
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
function game_godfield_guild_high_war_reward_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_guild_high_war_reward_pop;