
local game_serverGuild_employoJoin_pop = {
    m_tGameData = nil,
    m_node_tableView = nil,
    m_curPage = nil,
    m_label_page = nil,
    m_tableView = nil,
    m_nTotalPage = nil,
};
--[[--
    销毁ui
]]
function game_serverGuild_employoJoin_pop.destroy(self)
    -- body
    cclog("-----------------game_serverGuild_employoJoin_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_node_tableView = nil;
    self.m_curPage = nil;
    self.m_label_page = nil;
    self.m_tableView = nil;
    self.m_nTotalPage = nil;
   
end
--[[--
    返回
]]
function game_serverGuild_employoJoin_pop.back(self,backType)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("game_serverGuild_employoJoin_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_serverGuild_employoJoin_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag ======= ")
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then
            if self.m_curPage == 1 then
                return
            end
            local posX,posY = self.m_tableView:getContainer():getPosition();
            local tableViewSize = self.m_node_tableView:getContentSize()
            local curOffset = self.m_tableView:getContentOffset()
            self.m_tableView:setContentOffset(ccp(curOffset.x+tableViewSize.width,posY),false);
            self.m_curPage = self.m_curPage - 1
            self.m_label_page:setString("(" .. self.m_curPage .. "/" .. self.m_nTotalPage .. ")")
        elseif btnTag == 102 then
            if self.m_curPage == self.m_nTotalPage then
                return
            end
            local curOffset = self.m_tableView:getContentOffset()
            local posX,posY = self.m_tableView:getContainer():getPosition();
            local tableViewSize = self.m_node_tableView:getContentSize()
            self.m_tableView:setContentOffset(ccp(curOffset.x-tableViewSize.width,posY),false);
            self.m_curPage = self.m_curPage + 1
            self.m_label_page:setString("(" .. self.m_curPage .. "/" .. self.m_nTotalPage .. ")")
        elseif btnTag == 200 then --刷新
            local function responseMethod( tag,gameData )
                game_scene:addPop("game_serverGuild_employoJoin_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_employ_pub_ed"), http_request_method.GET, {tp = 1},"new_guild_fight_employ_pub_ed")
            
        elseif btnTag == 201 then
            local function responseMethod( tag,gameData )
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer())
                game_scene:addPop("game_serverGuild_myLog",{gameData = self.m_tGameData.my_info})

            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_employ_pub_ed"), http_request_method.GET, {tp = 1},"new_guild_fight_employ_pub_ed")
            

        elseif btnTag == 202 then

            local function responseMethod( tag,gameData )
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer())
                game_scene:addPop("game_serverGuild_employLog_pop",{gameData =  gameData})
                

            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_emeploy_list"), http_request_method.GET, nil,"new_guild_fight_emeploy_list")
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_serverGuild_employLog.ccbi");
    local m_btn_log = ccbNode:controlButtonForName("m_btn_log")
    m_btn_log:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    local m_btn_join = ccbNode:controlButtonForName("m_btn_join")
    m_btn_join:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    local m_btn_right = ccbNode:controlButtonForName("m_btn_right")
    m_btn_right:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    local m_btn_left = ccbNode:controlButtonForName("m_btn_left")
    m_btn_left:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    
    local m_btn_refresh = ccbNode:controlButtonForName("m_btn_refresh")
    m_btn_refresh:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")
    self.m_label_page = ccbNode:labelTTFForName("m_label_page")
    local function onTouch( eventType, x, y )
        if eventType == "began" then
            return true;--intercept event
        end
    end
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    m_root_layer:registerScriptTouchHandler(onTouch, false, GLOBAL_TOUCH_PRIORITY-1, true)
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

function game_serverGuild_employoJoin_pop.createTableView(self,viewSize)
    local btnTab = {}
    local function onCellClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag()

        local t_params = 
          {
            title = string_config.m_title_prompt,
            okBtnCallBack = function(target,event)
                game_util:closeAlertView();
                local params = {} 
                cclog2(self.m_tGameData.info[btnTag].guild_id,"---1----")
                -- cclog2(self.m_tGameData.info[tostring(btnTag)].guild_id,"---1----")
                params.ass_id = self.m_tGameData.info[btnTag].guild_id
                local function responseMethod(tag,gameData)
                    game_util:addMoveTips({text = "申请成功"})
                    -- cclog2(gameData,"gameData =------- ")
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_sign_up_employ"), http_request_method.GET, params,"new_guild_fight_sign_up_employ")
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
            text = "是否申请该工会雇佣",      --可缺省
          }
          game_util:openAlertView(t_params);
        -- for i=1,game_util:getTableLen(btnTab) do
        --     -- cclog(i .. "---i ---- ")
        --     -- cclog(btnTag .. "---btnTag ---- ")
        --     btnTab[i]:setHighlighted(i==btnTag)
        -- end
    end 
    -- local showData = team_pk_rewardcfg or {}
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = game_util:getTableLen(self.m_tGameData.info)
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+2;
    params.showPageIndex = self.m_curPage;
    params.showPoint = false
    params.direction = kCCScrollViewDirectionHorizontal;
    local onePageCount = params.row * params.column;
    local m_nCurPage = 1;
    local m_nTotalPage = 1;
    m_nTotalPage = ((params.totalItem % onePageCount == 0) and (params.totalItem / onePageCount) or (params.totalItem / onePageCount + 1));
    m_nTotalPage = math.floor(m_nTotalPage);
    if m_nTotalPage == 0 then
        m_nTotalPage = 1
    end
    self.m_nTotalPage = m_nTotalPage
    self.m_label_page:setString("(" .. self.m_curPage .. "/" .. m_nTotalPage .. ")")
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellClick",onCellClick);
            ccbNode:openCCBFile("ccb/ui_serverGuild_employItem2.ccbi");
            -- ccbNode:setAnchorPoint(ccp(0.5,0.5));
            -- local offsetY = 0
            -- offsetY = math.floor(index/5)*7
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
           local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
           local itemData = self.m_tGameData.info[index + 1]
           local m_label_rank = ccbNode:labelTTFForName("m_label_rank")
           m_label_rank:setString(tostring(index + 1 ))
           local m_label_guild = ccbNode:labelTTFForName("m_label_guild")
           m_label_guild:setString(tostring( itemData.name ))
           local m_label_guildBoss = ccbNode:labelTTFForName("m_label_guildBoss")
           m_label_guildBoss:setString(tostring( itemData.owner_name ))
           local m_label_coin = ccbNode:labelTTFForName("m_label_coin")
           m_label_coin:setString(tostring( itemData.coin ))
           local m_label_num = ccbNode:labelTTFForName("m_label_num")
           m_label_num:setString(tostring( itemData.num ))

           local m_btn_select = ccbNode:controlButtonForName("m_btn_select")
           m_btn_select:setTag(index + 1)
           -- btnTab[index + 1] = m_btn_select
           m_btn_select:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
        self.m_label_page:setString("(" .. self.m_curPage .. "/" .. m_nTotalPage .. ")")
    end
    return TableViewHelper:createGallery(params);
end
--[[--
    刷新ui
]]
function game_serverGuild_employoJoin_pop.refreshUi(self)
   self.m_node_tableView:removeAllChildrenWithCleanup(true)
   local m_tableView = self:createTableView(self.m_node_tableView:getContentSize())
   self.m_tableView = m_tableView:getChildByTag(10)
   self.m_node_tableView:addChild(m_tableView)
end
--[[--
    初始化
]]
function game_serverGuild_employoJoin_pop.init(self,t_params)
    self.m_curPage = 1
    t_params = t_params or {};
    -- body
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer());
    end
    self.m_selGuildId = t_params.guildId;
  
end

--[[--
    创建ui入口并初始化数据
]]
function game_serverGuild_employoJoin_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_serverGuild_employoJoin_pop;