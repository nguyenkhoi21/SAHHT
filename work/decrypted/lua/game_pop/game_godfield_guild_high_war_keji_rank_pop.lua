--- 坠落之地
--- 科技排行榜
local game_godfield_guild_high_keji_war_rank_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_select_index = nil,
    m_rank_tableView = nil,

};

--[[--
    销毁
]]
function game_godfield_guild_high_keji_war_rank_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_keji_war_rank_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_select_index = nil;
    self.m_rank_tableView = nil;

end
--[[--
    返回
]]
function game_godfield_guild_high_keji_war_rank_pop.back(self)
    game_scene:removePopByName("game_godfield_guild_high_war_keji_rank_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_keji_war_rank_pop.createUi(self)
    self.m_itemActionFlag = true
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then -- 个人排行榜
            if self.m_select_index ~= btnTag - 100 then
                self.m_select_index = 1
                self:refreshUi()
            end
        elseif btnTag == 102 then -- 公会排行榜
            if self.m_select_index ~= btnTag - 100 then
                self.m_select_index = 2
                self:refreshUi()
            end
        elseif btnTag == 200 then -- 规则
            local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
            local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(27))
            if itemCfg == nil then return end
            local openMsg = itemCfg:getNodeWithKey("des"):toStr();
            game_scene:addPop("game_godfield_detail_pop",{openMsg = openMsg})
       
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_rank.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    self.label_title = ccbNode:labelTTFForName("label_title") 
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_des_btn = ccbNode:controlButtonForName("m_des_btn")
    self.m_des_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_rank1_btn = ccbNode:controlButtonForName("m_rank1_btn")
    self.m_rank1_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    game_util:setCCControlButtonTitle(self.m_rank1_btn,"BXH KHKT")

    self.m_rank2_btn = ccbNode:controlButtonForName("m_rank2_btn")
    self.m_rank2_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    game_util:setCCControlButtonTitle(self.m_rank2_btn,"Cột mốc KHKT")

    self.spr_zi = ccbNode:spriteForName("spr_zi")
    self.spr_zi1 = ccbNode:spriteForName("spr_zi1")
    self.spr_zi2 = ccbNode:spriteForName("spr_zi2")
    self.spr_zi3 = ccbNode:spriteForName("spr_zi3")
    self.spr_zi4 = ccbNode:spriteForName("spr_zi4")

    self.node_rank_list = ccbNode:nodeForName("node_rank_list")
   

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_godfield_guild_high_keji_war_rank_pop.refreshUi(self)
   
    local showData = {}
    if self.m_select_index == 1 then -- 科技排行榜
        for k,v in pairs(self.m_tGameData.rank_info) do
            showData[tonumber(k)] = v
        end
        game_util:setSpriteDisplayBySpriteFrameName(self.spr_zi, "phb_msz01.png")
        self.spr_zi:setPositionX(100)
        game_util:setSpriteDisplayBySpriteFrameName(self.spr_zi1, "phb_msz02.png")
        self.spr_zi1:setPositionX(189)

        game_util:setSpriteDisplayBySpriteFrameName(self.spr_zi2, "phb_msz03.png")
        self.spr_zi2:setPositionX(288)
        self.spr_zi2:setVisible(true)
        game_util:setSpriteDisplayBySpriteFrameName(self.spr_zi3, "phb_msz17.png")
        self.spr_zi3:setPositionX(375)
        self.spr_zi3:setVisible(true)
        game_util:setCCControlButtonBackground(self.m_rank1_btn,"yq_btn01.png")
        game_util:setCCControlButtonBackground(self.m_rank2_btn,"yq_btn02.png")
        self.spr_zi4:setVisible(false)
    else -- 科技里程碑
        local guild_high_war_sciencestar_cfg = getConfig(game_config_field.guild_high_war_sciencestar)
        guild_high_war_sciencestar_cfg = json.decode(guild_high_war_sciencestar_cfg:getFormatBuffer())
        for k,v in pairs(guild_high_war_sciencestar_cfg) do
            table.insert(showData, {id = k, cfg = v})
        end

        table.sort(showData,function(data1,data2) return tonumber(data1.id) < tonumber(data2.id) end)

        game_util:setSpriteDisplayBySpriteFrameName(self.spr_zi, "phb_msz18.png")
        self.spr_zi:setPositionX(120)
        game_util:setSpriteDisplayBySpriteFrameName(self.spr_zi1, "phb_msz16.png")
        self.spr_zi1:setPositionX(265)
        -- game_util:setSpriteDisplayBySpriteFrameName(self.spr_zi2, "phb_msz06.png")
        -- self.spr_zi2:setPositionX(332)
        self.spr_zi2:setVisible(false)
        self.spr_zi3:setVisible(false)
        game_util:setCCControlButtonBackground(self.m_rank1_btn,"yq_btn02.png")
        game_util:setCCControlButtonBackground(self.m_rank2_btn,"yq_btn01.png")
        self.spr_zi4:setVisible(false)
        -- self.spr_zi4:setPositionX(253)
    end


    if self.m_rank_tableView and self.m_select_index == self.m_select_index2 then
        self.m_lastTableViewPosY = self.m_rank_tableView:getContentOffset().y
    end

    self.node_rank_list:removeAllChildrenWithCleanup(true);
    self.m_rank_tableView = self:createRankTableView(self.node_rank_list:getContentSize(), showData);
    self.node_rank_list:addChild(self.m_rank_tableView);
    self.m_rank_tableView:setScrollBarVisible(false);
    
    -- 重置位置
    if self.m_lastTableViewPosY and self.m_select_index == self.m_select_index2 then
        local contentSize = self.m_rank_tableView:getContentSize()
        self.m_lastTableViewPosY = math.max(-1 * contentSize.height, self.m_lastTableViewPosY)
        self.m_rank_tableView:setContentOffset(ccp(0, self.m_lastTableViewPosY), false);
    end

    self.m_select_index2 = self.m_select_index
    if self.m_select_index == 1 then
        self.label_title:setString("BXH KHKT")
    else
        self.label_title:setString("Cột mốc KHKT")
    end
    self.m_itemActionFlag = false
end


--[[--
    创建 排行榜 列表
]]
function game_godfield_guild_high_keji_war_rank_pop.createRankTableView(self,viewSize, showData)
    
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local data = showData[btnTag]
        if self.m_tGameData.self_score < tonumber(data.id) then
            return game_util:addMoveTips({text = "Cống hiến hiện tại chưa đủ điều kiện nhận!"});
        end

        local function responseMethod( tag, gameData )
            local data = gameData:getNodeWithKey("data");
            local reward = data:getNodeWithKey("reward")
            if reward then
                game_util:rewardTipsByJsonData(reward)
            end
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            self:refreshUi()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_get_science_star"), http_request_method.GET, {score = data.id},"guild_high_war_get_science_star")
    end

    local cardsCount = #showData
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.totalItem = cardsCount --totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-10;
    params.itemActionFlag = self.m_itemActionFlag
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_rank_item1.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            local spr_rank_icon = ccbNode:spriteForName("spr_rank_icon")
            local node_rank_num = ccbNode:nodeForName("node_rank_num")
            node_rank_num:removeAllChildrenWithCleanup(true)
            local label_name = ccbNode:labelTTFForName("label_name")
            local label_lv = ccbNode:labelTTFForName("label_lv")
            local label_value = ccbNode:labelTTFForName("label_value")
            local label_tips = ccbNode:labelTTFForName("label_tips")
            label_tips:setString("Đã nhận")
            label_tips:setVisible(false)
            local node_rewards = ccbNode:nodeForName("node_rewards")
            node_rewards:removeAllChildrenWithCleanup(true)
            local m_btn1 = ccbNode:controlButtonForName("m_btn1")
            m_btn1:setVisible(false)
            m_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
            m_btn1:setTag(index + 1)
 
            local data = showData[index + 1]
            --个人排行榜才显示m_zan_btn
            if self.m_select_index == 1 then
                label_name:setPositionX(118.7)
                label_lv:setPositionX(217.2)
                label_value:setPositionX(302.1)
                label_value:setVisible(true)
               
                label_name:setString(data.name)
                label_value:setString(data.score)
                label_lv:setString(data.level or 1)

                local rank_icon = ""
                if (index + 1) == 1 then
                    rank_icon = "phb_icon03.png"
                elseif (index + 1) == 2 then
                    rank_icon = "phb_icon02.png"
                else
                    rank_icon = "phb_icon01.png"
                end
                game_util:setSpriteDisplayBySpriteFrameName(spr_rank_icon, rank_icon)
                spr_rank_icon:setVisible((index + 1)<4)
                
                local label_rank = game_util:createLabelBMFont({text = index + 1,fnt = "ccbResources/guild_high_war/sz_msz01.fnt"})
                label_rank:setPositionX(-5)
                node_rank_num:addChild(label_rank)
                node_rank_num:setVisible((index + 1)>3)

            else
                label_name:setPositionX(65.7)
                label_name:setString("Cống hiến KHKT cá nhân đạt đến"..data.id)
                -- node_yj:setPositionX(260.5)
                label_value:setVisible(false)
                label_lv:setVisible(false)
                node_rewards:setPositionX(194)
                node_rewards:setContentSize(CCSizeMake(math.min(#data.cfg.reward*50, 150), 50))
                local tableView = self:createRewardTable(node_rewards:getContentSize(), data.cfg.reward, nil, 0.7, true)
                node_rewards:addChild(tableView,10,10)
                m_btn1:setVisible(true)

                if self.m_tGameData.self_score >= tonumber(data.id) then
                    local flag = game_util:idInTableById(data.id,self.m_tGameData.got_sciencestar)
                    if flag then
                        m_btn1:setVisible(false)
                        label_tips:setVisible(true)
                    else
                        m_btn1:setColor(ccc3(255,255,255))
                        game_util:setCCControlButtonEnabled(m_btn1, true)
                    end
                else
                    m_btn1:setColor(ccc3(155,155,155))
                end

                spr_rank_icon:setVisible(false)
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


function game_godfield_guild_high_keji_war_rank_pop.createRewardTable(self,viewSize,rewardList, is_box, scale, show_name)
    local scale = scale or 0.5

    local count = #rewardList
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = count > 3 and 3 or count; --列
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
            local icon,name,count = game_util:getRewardByItemTable(itemGift, true)
            if icon then
                icon:setScale(scale)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,2))
                node:addChild(icon,10)
            end
            if name then
                local nameLabel = game_util:createLabelTTF({text = "x"..count})
                -- nameLabel:setColor(ccc3(250,180,0))
                nameLabel:setAnchorPoint(ccp(0.5, 0.5))
                nameLabel:setPosition(icon:getContentSize().width * 0.5, -5)
                icon:addChild(nameLabel, 11)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemCfg = rewardList[index+1]
            game_util:lookItemDetal(itemCfg)
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        
    end
    return TableViewHelper:create(params);
end

--[[--
    初始化
]]
function game_godfield_guild_high_keji_war_rank_pop.init(self,t_params)
    t_params = t_params or {};
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
function game_godfield_guild_high_keji_war_rank_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_guild_high_keji_war_rank_pop;