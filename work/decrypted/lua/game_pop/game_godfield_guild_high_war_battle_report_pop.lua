--- 坠落之地
--- 战报
local game_godfield_guild_high_war_battle_report_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_select_index = nil,
};

--[[--
    销毁
]]
function game_godfield_guild_high_war_battle_report_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_battle_report_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_select_index = nil
end
--[[--
    返回
]]
function game_godfield_guild_high_war_battle_report_pop.back(self)
    game_scene:removePopByName("game_godfield_guild_high_war_battle_report_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_battle_report_pop.createUi(self)
    self.m_select_index = 1
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then -- 个人排行榜
            self.m_select_index = 1
            self:refreshUi()
        elseif btnTag == 102 then -- 公会排行榜
            self.m_select_index = 2   
            self:refreshUi()
        elseif btnTag == 200 then -- 规则
        
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_battle_report_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    self.label_title = ccbNode:labelTTFForName("label_title")
    self.label_title:setString("Chi tiết tình hình chiến đấu") 
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.label_tips = ccbNode:labelTTFForName("label_tips")
    self.label_tips:setString("") 
    self.node_news = ccbNode:nodeForName("node_news")


    
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
function game_godfield_guild_high_war_battle_report_pop.refreshUi(self)
    local showData = self.m_tGameData.info
    self.node_news:removeAllChildrenWithCleanup(true);
    self.m_report_tableView = self:createReportTableView(self.node_news:getContentSize(), showData);
    self.node_news:addChild(self.m_report_tableView);
    self.m_report_tableView:setScrollBarVisible(false);

end

--[[--
    创建 排行榜 列表
]]
function game_godfield_guild_high_war_battle_report_pop.createReportTableView(self,viewSize, showData)
    local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)

    self.m_selListItem = nil;
    local cardsCount = #showData

    local function onMainBtnClick( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local team_index = 1;
        if btnTag == 10 then
            
        end
        
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.totalItem = cardsCount 
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-10;
    params.itemActionFlag = true
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_battle_report_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local node_icon = ccbNode:nodeForName("node_icon")
            local label_name = ccbNode:labelTTFForName("label_name")
            local spr_win = ccbNode:spriteForName("spr_win")
            local label_guild_name1 = ccbNode:labelTTFForName("label_guild_name1")
            local label_player_name1 = ccbNode:labelTTFForName("label_player_name1")
            label_player_name1:setVisible(false)
            local spr_lose = ccbNode:spriteForName("spr_lose")
            local label_guild_name2 = ccbNode:labelTTFForName("label_guild_name2")
            local label_player_name2 = ccbNode:labelTTFForName("label_player_name2")
            label_player_name2:setVisible(false)

            local data = showData[index +1]
            local build_info = guild_high_war_build_cfg:getNodeWithKey(data.city)
            local city_name = build_info:getNodeWithKey("city_name"):toStr()
            label_name:setString(city_name)
            node_icon:removeAllChildrenWithCleanup(true)
            local city_icon = build_info:getNodeWithKey("city_icon"):toStr()
            local building = CCSprite:create("ccbResources/godfield_build/"..city_icon..".png")
            building:setScale(0.5)
            node_icon:addChild(building)
            local sort = build_info:getNodeWithKey("sort"):toInt()

            label_guild_name1:setString(data.att_guild_name)
            label_guild_name2:setString(data.def_guild_name)

            if data.is_win == 1 then --胜
                game_util:setSpriteDisplayBySpriteFrameName(spr_win, "gf_msz04.png")
                game_util:setSpriteDisplayBySpriteFrameName(spr_lose, "gf_msz03.png")
            else
                game_util:setSpriteDisplayBySpriteFrameName(spr_win, "gf_msz03.png")
                game_util:setSpriteDisplayBySpriteFrameName(spr_lose, "gf_msz04.png")
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


--[[--
    初始化
]]
function game_godfield_guild_high_war_battle_report_pop.init(self,t_params)
    t_params = t_params or {};
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
function game_godfield_guild_high_war_battle_report_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_guild_high_war_battle_report_pop;