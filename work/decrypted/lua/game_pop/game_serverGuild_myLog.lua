--  个人申请记录

local game_serverGuild_myLog = {
    m_tGameData = nil,
    m_label_des = nil,
    m_node_tableView = nil,
    m_select_index = nil,
    m_btn_one = nil,
    m_btn_guild = nil,
}
--[[--
    销毁ui
]]
function game_serverGuild_myLog.destroy(self)
    -- body
    cclog("-----------------game_serverGuild_myLog destroy-----------------");
    self.m_tGameData = nil;
    self.m_label_des = nil;
    self.m_node_tableView = nil;
    self.m_select_index = nil;
    self.m_btn_one = nil;
    self.m_btn_guild = nil;
   
end
--[[--
    返回
]]
function game_serverGuild_myLog.back(self,backType)
    game_scene:removePopByName("game_serverGuild_myLog");
end
--[[--
    读取ccbi创建ui
]]
function game_serverGuild_myLog.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then
            self.m_btn_one:setHighlighted(true)
            self.m_btn_guild:setHighlighted(false)

        elseif btnTag == 102 then
            self.m_btn_one:setHighlighted(false)
            self.m_btn_guild:setHighlighted(true)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_serverGuild_myLog.ccbi");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)

    self.m_node_tableView = ccbNode:nodeForName("m_node_tableVIew")
    -- local m_btn_select = ccbNode:controlButtonForName("m_btn_select")
    -- m_btn_select:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    local function onTouch( eventType, x, y )
        if eventType == "began" then
            return true;--intercept event
        end
    end
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    m_root_layer:registerScriptTouchHandler(onTouch, false, GLOBAL_TOUCH_PRIORITY-2, true)
    m_root_layer:setTouchEnabled(true);
    self.m_label_des = ccbNode:labelTTFForName("m_label_des")
    return ccbNode;
end

function game_serverGuild_myLog.createTableView(self,viewSize)
    -- local showData = team_pk_rewardcfg or {}
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.totalItem = game_util:getTableLen(self.m_tGameData)
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    params.showPageIndex = self.m_curPage;
    params.showPoint = false
    local function onCellClick( target, event )
       local tagNode = tolua.cast(target, "CCNode");
       local btnTag = tagNode:getTag();
       local ass_id = self.m_tGameData[btnTag].ass_id
       local t_params = 
         {
            title = string_config.m_title_prompt,
            okBtnCallBack = function(target,event)
                game_util:closeAlertView();
                local function responseMethod( tag, gameData )
                    game_util:addMoveTips({text = "取消成功"})
                    local infoData  = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer());
                    self.m_tGameData = infoData.my_info
                    self:refreshUi()
    
                    -- cclog(gameData,"gameData ==== ")
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_give_up_sign_up_employ"), http_request_method.GET, {ass_id = ass_id},"new_guild_fight_give_up_sign_up_employ")
            end,   --可缺省
           closeCallBack = function(target,event)
               game_util:closeAlertView();
           end,
           cancelBtnCallBack = function(target,event)
               game_util:closeAlertView();
           end,
           cancelBtnText = "Hủy",
           onlyOneBtn = false,
           okBtnText = "OK",       --可缺省
           text = "是否放弃申请该工会？",      --可缺省
         }
         game_util:openAlertView(t_params);
    end
    -- params.direction = kCCScrollViewDirectionHorizontal;
    -- local onePageCount = params.row * params.column;
    -- local m_nCurPage = 1;
    -- local m_nTotalPage = 1;
    -- m_nTotalPage = ((params.totalItem % onePageCount == 0) and (params.totalItem / onePageCount) or (params.totalItem / onePageCount + 1));
    -- m_nTotalPage = math.floor(m_nTotalPage);
    -- self.m_nTotalPage = m_nTotalPage
    -- self.m_label_page:setString("(" .. self.m_curPage .. "/" .. m_nTotalPage .. ")")
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellClick",onCellClick);
            ccbNode:openCCBFile("ccb/ui_serverGuild_myLogItem.ccbi");
            -- ccbNode:setAnchorPoint(ccp(0.5,0.5));
            -- local offsetY = 0
            -- offsetY = math.floor(index/5)*7
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
           local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
           local itemData = self.m_tGameData[index + 1]
           local m_label_name = ccbNode:labelTTFForName("m_label_name")
           m_label_name:setString(tostring(itemData.ass_name ))
           local m_label_price = ccbNode:labelTTFForName("m_label_price")
           m_label_price:setString(tostring(itemData.coin ))
           local m_label_num = ccbNode:labelTTFForName("m_label_num")
           m_label_num:setString(tostring(index + 1 ))
           local m_btn_x = ccbNode:controlButtonForName("m_btn_x")
           m_btn_x:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
           m_btn_x:setTag(index + 1 )
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        end
    end
   
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_serverGuild_myLog.refreshUi(self)
   self.m_node_tableView:removeAllChildrenWithCleanup(true)
   local m_tableView = self:createTableView(self.m_node_tableView:getContentSize())
   self.m_tableView = m_tableView:getChildByTag(10)
   self.m_node_tableView:addChild(m_tableView)
end


--[[--
    初始化
]]
function game_serverGuild_myLog.init(self,t_params)
    self.m_select_index = 1
    t_params = t_params or {};
    -- body
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer());
    elseif t_params.gameData ~= nil and tolua.type(t_params.gameData) == "table" then
        self.m_tGameData = t_params.gameData
    end
  
end

--[[--
    创建ui入口并初始化数据
]]
function game_serverGuild_myLog.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_serverGuild_myLog;