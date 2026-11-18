--- 坠落之地
--- 战报
local game_godfield_guild_high_war_report_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_select_index = nil,
};

--[[--
    销毁
]]
function game_godfield_guild_high_war_report_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_report_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_select_index = nil
end
--[[--
    返回
]]
function game_godfield_guild_high_war_report_pop.back(self)
    game_scene:removePopByName("game_godfield_guild_high_war_report_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_report_pop.createUi(self)
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
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_report_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    self.label_title = ccbNode:labelTTFForName("label_title")
    self.label_title:setString("Tin nhắn") 
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    self.node_reports = ccbNode:nodeForName("node_reports")


    
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
function game_godfield_guild_high_war_report_pop.refreshUi(self)
    local showData = self.m_tGameData.info
    self.node_reports:removeAllChildrenWithCleanup(true);
    self.m_report_tableView = self:createReportTableView(self.node_reports:getContentSize(), showData);
    self.node_reports:addChild(self.m_report_tableView);
    self.m_report_tableView:setScrollBarVisible(false);
end

--[[--
    创建 排行榜 列表
]]
function game_godfield_guild_high_war_report_pop.createReportTableView(self,viewSize, showData)
    -- self.m_selTitleId = 1
    self.m_selListItem = nil;
    local cardsCount = #showData

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local team_index = 1;
        local function responseMethod( tag,gameData )
            local battle = gameData:getNodeWithKey("data"):getNodeWithKey("battle")
            if battle and battle:getNodeCount() > 0 then
                game_data:setBattleType("game_godfield_guild_high_war", {group_id = self.m_group_id});
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
            else
                local t_params = 
                    {
                        okBtnCallBack = function(target,event)
                            game_util:closeAlertView();
                        end,   --可缺省
                        okBtnText = "Xác định",       --可缺省
                        text = "Mất số liệu, Chiến đấu lần này lấy số liệu Chiến báo làm chuẩn",      --可缺省
                    }
                game_util:openAlertView(t_params);
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_record"), http_request_method.GET, {att_uid = showData[btnTag].att_uid , def_uid = showData[btnTag].def_uid, city_id = self.m_buildingId, group_id = self.m_group_id},"guild_high_war_record")

    end

    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = cardsCount --totalItem;
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

            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_report_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local node_rich = ccbNode:nodeForName("node_rich")
            local m_btn1 = ccbNode:controlButtonForName("m_btn1")
            m_btn1:setTag(index+1)
            m_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
            node_rich:removeAllChildrenWithCleanup(true)

            -- local news = "[color=ff00ff00]刚毅的布欧[/color]挑战[color=ff00ff00]大气的琳[/color]失败，[color=ff00ff00]刚毅的布欧[/color]。"
            local data = showData[index + 1]
            if data.def_uid and data.def_uid ~= "" then -- 有回放
                node_rich:setContentSize(CCSizeMake(195, 30))
                m_btn1:setVisible(true)
            else
                node_rich:setContentSize(CCSizeMake(240, 30))
                m_btn1:setVisible(false)
            end
            local news = data.des
            local reward_str = ""
            if data.gift then
                for i,v in ipairs(data.gift) do
                    local icon,name,count = game_util:getRewardByItemTable(v, false)
                    if i == #data.gift then
                        reward_str = reward_str..name.."x"..count .."!"
                    else
                        reward_str = reward_str..name.."x"..count .."、"
                    end
                end
                news = news..reward_str
            end
            local viewSize = node_rich:getContentSize();
            local tempLabel = game_util:createRichLabelTTF({text = news,dimensions = CCSizeMake(viewSize.width,0),textAlignment = kCCTextAlignmentLeft,
                verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 9})
       
            tempLabel:setPosition(ccp(viewSize.width/2,viewSize.height/2))
            node_rich:addChild(tempLabel)

            -- local news = "[color=ff00ff00]刚毅的布欧[/color]挑战[color=ff00ff00]大气的琳[/color]失败，[color=ff00ff00]刚毅的布欧[/color]。"
            -- local tempTipsLabel = CCRichLabelTTF:create(news,TYPE_FACE_TABLE.Arial_BoldMT,12);
            -- tempTipsLabel:setPosition(ccp(tempPosX+70,tempPosY))
            -- tempTipsLabel:setScale(0.8)
            -- ccbNode:addChild(tempTipsLabel
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
function game_godfield_guild_high_war_report_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_buildingId = t_params.buildingId
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
function game_godfield_guild_high_war_report_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_guild_high_war_report_pop;