--- 坠落之地
--- 排行榜
local game_godfield_guild_high_war_rank_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_select_index = nil,
    m_rank_tableView = nil,

};

--[[--
    销毁
]]
function game_godfield_guild_high_war_rank_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_rank_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_select_index = nil;
    self.m_rank_tableView = nil;

end
--[[--
    返回
]]
function game_godfield_guild_high_war_rank_pop.back(self)
    game_scene:removePopByName("game_godfield_guild_high_war_rank_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_rank_pop.createUi(self)
    self.m_itemActionFlag = true
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then -- 个人排行榜
            if self.m_select_index ~= btnTag - 100 then
                local function responseMethod( tag,gameData )
                    game_scene:addPop("game_godfield_guild_high_war_rank_pop",{gameData = gameData, select_index = 1, group_id = self.m_group_id});
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_get_rank"), http_request_method.GET, {rank_type = 0, group_id = self.m_group_id, s_num = 1, e_num = 100},"guild_high_war_get_rank")
            end
        elseif btnTag == 102 then -- 公会排行榜
            if self.m_select_index ~= btnTag - 100 then
                local function responseMethod( tag,gameData )
                    game_scene:addPop("game_godfield_guild_high_war_rank_pop",{gameData = gameData, select_index = 2, group_id = self.m_group_id});
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_get_rank"), http_request_method.GET, {group_id = self.m_group_id , rank_type = 1},"guild_high_war_get_rank")
            end
        elseif btnTag == 200 then -- 规则
            local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
            local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(8))
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
    game_util:setCCControlButtonTitle(self.m_rank1_btn,"BXH cá nhân")

    self.m_rank2_btn = ccbNode:controlButtonForName("m_rank2_btn")
    self.m_rank2_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    game_util:setCCControlButtonTitle(self.m_rank2_btn,"BXH công hội")

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
function game_godfield_guild_high_war_rank_pop.refreshUi(self)
   
    local showData = {}
    if self.m_select_index == 1 then -- 个人排行榜
        for k,v in pairs(self.m_tGameData.rank) do
            showData[tonumber(k)] = v
        end
        game_util:setSpriteDisplayBySpriteFrameName(self.spr_zi1, "phb_msz02.png")
        self.spr_zi1:setPositionX(189)
        game_util:setSpriteDisplayBySpriteFrameName(self.spr_zi2, "phb_msz03.png")
        self.spr_zi2:setPositionX(288)
        game_util:setSpriteDisplayBySpriteFrameName(self.spr_zi3, "phb_msz04.png")
        self.spr_zi3:setPositionX(375)
        game_util:setCCControlButtonBackground(self.m_rank1_btn,"yq_btn01.png")
        game_util:setCCControlButtonBackground(self.m_rank2_btn,"yq_btn02.png")
        self.spr_zi4:setVisible(false)
    else -- 公会排行榜
        for k,v in pairs(self.m_tGameData.rank) do
            showData[tonumber(k)] = v
        end
        game_util:setSpriteDisplayBySpriteFrameName(self.spr_zi1, "phb_msz07.png")
        self.spr_zi1:setPositionX(165)
        game_util:setSpriteDisplayBySpriteFrameName(self.spr_zi2, "phb_msz06.png")
        self.spr_zi2:setPositionX(332)
        game_util:setSpriteDisplayBySpriteFrameName(self.spr_zi3, "phb_msz05.png")
        self.spr_zi3:setPositionX(405)
        game_util:setCCControlButtonBackground(self.m_rank1_btn,"yq_btn02.png")
        game_util:setCCControlButtonBackground(self.m_rank2_btn,"yq_btn01.png")
        self.spr_zi4:setVisible(true)
        self.spr_zi4:setPositionX(253)
    end


    if self.m_rank_tableView then
        self.m_lastTableViewPosY = self.m_rank_tableView:getContentOffset().y
    end

    self.node_rank_list:removeAllChildrenWithCleanup(true);
    self.m_rank_tableView = self:createRankTableView(self.node_rank_list:getContentSize(), showData);
    self.node_rank_list:addChild(self.m_rank_tableView);
    self.m_rank_tableView:setScrollBarVisible(false);
    
    -- 重置位置
    if self.m_lastTableViewPosY then
        local contentSize = self.m_rank_tableView:getContentSize()
        self.m_lastTableViewPosY = math.max(-1 * contentSize.height, self.m_lastTableViewPosY)
        self.m_rank_tableView:setContentOffset(ccp(0, self.m_lastTableViewPosY), false);
    end

    self.m_select_index2 = self.m_select_index
    self.label_title:setString(self.m_group_id.."XH số Chiến Trường")
    self.m_itemActionFlag = false
end


--[[--
    创建 排行榜 列表
]]
function game_godfield_guild_high_war_rank_pop.createRankTableView(self,viewSize, showData)
    
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
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_rank_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            local spr_rank_icon = ccbNode:spriteForName("spr_rank_icon")
            local node_rank_num = ccbNode:nodeForName("node_rank_num")
            local label_name = ccbNode:labelTTFForName("label_name")
            local label_lv = ccbNode:labelTTFForName("label_lv")
            local label_value = ccbNode:labelTTFForName("label_value")
            local node_yj = ccbNode:nodeForName("node_yj")
            local node_yj_icon1 = ccbNode:nodeForName("node_yj_icon1")
            local label_yj_num1 = ccbNode:labelTTFForName("label_yj_num1")
            local node_yj_icon2 = ccbNode:nodeForName("node_yj_icon2")
            local label_yj_num2 = ccbNode:labelTTFForName("label_yj_num2")
            local node_yj_icon3 = ccbNode:nodeForName("node_yj_icon3")
            local label_yj_num3 = ccbNode:labelTTFForName("label_yj_num3")
            -- local m_zan_btn = ccbNode:controlButtonForName("m_zan_btn")
            -- m_zan_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
            local node_btn_zan = ccbNode:nodeForName("node_btn_zan")
            local label_zan_num = ccbNode:labelTTFForName("label_zan_num")
            label_zan_num:setVisible(false)
            node_btn_zan:removeAllChildrenWithCleanup(true)
            
            
            local data = showData[index + 1]
            --个人排行榜才显示m_zan_btn
            if self.m_select_index == 1 then
                label_name:setPositionX(118.7)
                label_lv:setPositionX(217.2)
                label_value:setPositionX(302.1)
                label_value:setVisible(true)
                local guild_high_war_base_cfg = getConfig(game_config_field.guild_high_war_base)
                local base_cfg = guild_high_war_base_cfg:getNodeWithKey(self.m_tGameData.version)
                local max_daily_num = base_cfg:getNodeWithKey("daily_num"):toStr()
                local now_num = max_daily_num - #self.m_tGameData.like_log -- 今日点赞剩余次数

                local function onBtnCilck( event,target )        
                    if now_num <= 0 then
                        return game_util:addMoveTips({text = "Không đủ số lần Like hôm nay!"});
                    elseif game_util:valueInTeam(data.uid, self.m_tGameData.like_log) then -- 已点赞这个玩家
                        return game_util:addMoveTips({text = "Đã like người chơi này!"});
                    end

                    local function responseMethod( tag,gameData )
                        if gameData ~= nil and tolua.type(gameData) == "util_json" then
                            game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("reward"));
                            self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                        end
                        self:refreshUi()
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_dolike"), http_request_method.GET, {t_uid = data.uid, group_id = self.m_group_id},"guild_high_war_dolike")
                end
                local m_team_btn = game_util:createCCControlButton("phb_dz01.png","",onBtnCilck)
                m_team_btn:setTag(index + 1)
                m_team_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
                m_team_btn:setAnchorPoint(ccp(0.5,0.5))
                node_btn_zan:addChild(m_team_btn)
                label_zan_num:setString(data.like)

                node_yj:setVisible(false)
                -- label_lv:setVisible(true)
                label_name:setString(data.name)
                label_value:setString(data.score)
                label_lv:setString(data.level or 1)
                m_team_btn:setVisible(data.like == 0)

                m_team_btn:setVisible(true)
                if now_num <= 0 then
                    m_team_btn:setColor(ccc3(150,150,150))
                elseif game_util:valueInTeam(data.uid, self.m_tGameData.like_log) then -- 已点赞这个玩家
                    m_team_btn:setColor(ccc3(150,150,150))
                else
                    m_team_btn:setColor(ccc3(255,255,255))
                end
            else
                label_name:setPositionX(95.7)
                node_yj:setPositionX(260.5)
                label_value:setPositionX(331.1)
                label_lv:setPositionX(181.2)
                node_btn_zan:setVisible(false)
                node_yj:setVisible(true)
                -- label_lv:setVisible(false)
                label_lv:setString(data.combat)
                node_yj_icon1:removeAllChildrenWithCleanup(true)
                local icon1 = CCSprite:create("ccbResources/guild_high_war/gonghui_icon02.png")
                icon1:setScale(0.4)
                node_yj_icon1:addChild(icon1)
                node_yj_icon2:removeAllChildrenWithCleanup(true)
                local icon2 = CCSprite:create("ccbResources/guild_high_war/gonghui_icon12.png")
                icon2:setScale(0.4)
                node_yj_icon2:addChild(icon2)
                node_yj_icon3:removeAllChildrenWithCleanup(true)
                local icon3 = CCSprite:create("ccbResources/guild_high_war/gonghui_icon09.png")
                icon3:setScale(0.4)
                node_yj_icon3:addChild(icon3)
                label_yj_num1:setString("x"..(data.city_count["3"] or 0))
                label_yj_num2:setString("x"..(data.city_count["2"] or 0))
                label_yj_num3:setString("x"..(data.city_count["1"] or 0))
                label_name:setString(data.name)
                label_value:setString(data.score)

            end

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
            node_rank_num:removeAllChildrenWithCleanup(true)
            local label_rank = game_util:createLabelBMFont({text = index + 1,fnt = "ccbResources/guild_high_war/sz_msz01.fnt"})
            label_rank:setPositionX(-5)
            node_rank_num:addChild(label_rank)
            node_rank_num:setVisible((index + 1)>3)
           
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


--[[--
    初始化
]]
function game_godfield_guild_high_war_rank_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_select_index = t_params.select_index or 1
    self.m_group_id = t_params.group_id 
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
function game_godfield_guild_high_war_rank_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_guild_high_war_rank_pop;