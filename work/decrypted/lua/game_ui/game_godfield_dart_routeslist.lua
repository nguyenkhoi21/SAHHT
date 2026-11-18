---  神域宇宙航线
local game_godfield_dart_routeslist = {
    m_autoRefreshScheduler = nil,
    m_tickFlag = nil,
    m_auto_time = nil,
    m_route_scroll_view = nil,
    m_transShipTable = nil,
    m_teamUidTab = nil,
    m_list_view_bg = nil,
    m_ship_list_view_node = nil,
    m_list_view_btn = nil,
    m_arrow_sprite = nil,
    m_new_battle_label = nil,
    m_clickFlag = nil,
};
--[[--
    销毁ui
]]
function game_godfield_dart_routeslist.destroy(self)
    cclog("----------------- game_dart_route destroy-----------------"); 
    -- if self.m_autoRefreshScheduler ~= nil then
    --     scheduler.unschedule(self.m_autoRefreshScheduler)
    --     self.m_autoRefreshScheduler = nil;
    -- end
    self.m_tickFlag = nil;
    self.m_auto_time = nil;
    self.m_route_scroll_view = nil;
    self.m_transShipTable = nil;
    self.m_teamUidTab = nil;
    self.m_list_view_bg = nil;
    self.m_ship_list_view_node = nil;
    self.m_list_view_btn = nil;
    self.m_arrow_sprite = nil;
    self.m_new_battle_label = nil;
    self.m_clickFlag = nil;
end
--[[--
    返回
]]
function game_godfield_dart_routeslist.back(self)
    local function responseMethod( tag,gameData )
        if gameData == nil then return end
        self:destroy()
        game_scene:enterGameUi("game_godfield_dart_main",{gameData = gameData})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_dart_mian"),http_request_method.GET,nil,"god_dart_mian")
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_dart_routeslist.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog(btnTag)
        if btnTag == 1 then--返回
            self:back()
        elseif btnTag == 2 then--战斗记录
            local function responseMethod(tag,gameData)
                self.m_tickFlag = true;
                if gameData == nil then return end
                game_scene:addPop("game_godfield_dart_log",{gameData = gameData,logType = "battle_log"})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_battle_message"), http_request_method.GET, nil,"god_field_escort_battle_message",true,true)
        elseif btnTag == 4 then--航线
            local function responseMethod( tag,gameData )
               game_scene:enterGameUi("game_godfield_dart_route",{gameData=gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_all_map"), http_request_method.GET, nil,"god_field_escort_all_map")
        elseif btnTag == 111 then
            if self.isopen then
                self.isopen = false
                self.btn_node:setScale(1)
                self.m_list_node:setPositionX(-160)
            else
                self.isopen = true
                self.btn_node:setScaleX(-1)
                self.m_list_node:setPositionX(0)
            end
        elseif btnTag == 222 then
            local function responseMethod(tag,gameData)
                if gameData == nil then return end
                self:init({gameData = gameData,index = self.index})
                self:refreshUi()
            end
            t_params = {}
            t_params.map_id = self.index
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_map_index"), http_request_method.GET, nil,"god_field_escort_map_index")
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_dart_shiplist.ccbi");
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    
    self.list_node={}
    for i=1,8 do
        self.list_node[i]={}
        for j=1,3 do
            local s = "ship_node_" .. i .. "_" .. j 
            local x = ccbNode:nodeForName(s)
            if x then
                self.list_node[i][j] = x 
            end
        end
        cclog(#self.list_node[i],"self.list_node")
    end
    self.list_node[1][3]:setScale(1)
    self.list_switch = ccbNode:controlButtonForName("m_list_switch")
    self.btn_node = ccbNode:nodeForName("btn_node")
    self.m_list_node = ccbNode:nodeForName("m_list_node")
    self.m_routes_list_node = ccbNode:nodeForName("m_routes_list_node")
    self.click_layer = ccbNode:layerForName("click_layer")
    if self.isopen then
        self.btn_node:setScaleX(-1)
        self.m_list_node:setPositionX(0)
    else
        self.btn_node:setScale(1)
        self.m_list_node:setPositionX(-160)
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        elseif eventType == "end" then
        end
    end
    self.list_switch:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
    self.click_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-4,false);
    self.click_layer:setTouchEnabled(true);
    return ccbNode;
end

-- function game_godfield_dart_routeslist.autoRefreshUi(self)
--     self.m_tickFlag = false;    
--     local function responseMethod(tag,gameData)
--         self.m_tickFlag = true;
--         if gameData == nil then
--             return;
--         end
--         self:init({gameData = gameData,index = self.index})
--         self:refreshUi()
--     end
--     t_params = {}
--     t_params.map_id = self.index
--     network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_map_index"), http_request_method.GET, nil,"god_field_escort_map_index")
-- end

function game_godfield_dart_routeslist.refreshUi( self )
    -- body
    
    self:createlist()
    self.m_routes_list_node:removeAllChildrenWithCleanup(true)
    self.m_routes_list_node:addChild(self:createShipList(self.m_routes_list_node:getContentSize()))
    -- if self.m_autoRefreshScheduler == nil then
    --     function tick( dt )     
    --         if self.m_tickFlag == false then return end
    --         if self.m_auto_time > 0 then
    --             self.m_auto_time = self.m_auto_time - 1;
    --         else
    --             self.m_auto_time = 5;
    --             self:autoRefreshUi();
    --         end
    --     end
    --     self.m_autoRefreshScheduler = scheduler.schedule(tick, 1, false)
    -- end
end
function game_godfield_dart_routeslist.getPos( self,index ,time)
    local endpos = {}
    endpos[1]=ccp(267,248)
    endpos[2]=ccp(260,214)
    endpos[3]=ccp(259,185)
    endpos[4]=ccp(275,158)
    endpos[5]=ccp(304,149)
    endpos[6]=ccp(336,150)
    endpos[7]=ccp(367,153)
    endpos[8]=ccp(367,172)
    local beganpos = {}
    beganpos[1]=ccp(84,275)
    beganpos[2]=ccp(67,206)
    beganpos[3]=ccp(79,137)
    beganpos[4]=ccp(112,65)
    beganpos[5]=ccp(214,46)
    beganpos[6]=ccp(317,32)
    beganpos[7]=ccp(412,50)
    beganpos[8]=ccp(474,75)
    local sc1 =(time / 1200)
    local sc = 1 - sc1
    local began_pos = beganpos[index]
    local end_pos = endpos[index]
    local x =(end_pos.x - began_pos.x)*sc
    local y =(end_pos.y - began_pos.y)*sc
    local pos = ccp(beganpos[index].x+x,beganpos[index].y+y)
    return pos , sc1
end
function game_godfield_dart_routeslist.createlist( self )
    local scale1 = {{x=-0.65,y=0.65},{x=-0.65,y=0.65},{x=-0.65,y=0.65}}
    local scale2 = {{x=0.65,y=0.65},{x=0.65,y=0.65},{x=0.65,y=0.65}}
    local rotate = {-15,-30,-45,-60,-90,-110,110,100,}
    for j=1,#self.ship_lists do
        for i=1,#self.ship_lists[j] do 
            local function onclickFunc(target,event )
                local tagNode = tolua.cast(target, "CCNode");
                local btnTag = tagNode:getTag();
                local i = math.floor(btnTag%10)
                local j = math.floor(btnTag/10)
                local uid = self.m_uidlist[btnTag]
                local my_uid = game_data:getUserStatusDataByKey("uid") or nil;
                gameData = self.lists[uid] or {}
                local isMine = false
                local e_uid = gameData["member"]
                for k,v in pairs(e_uid) do
                    e_uid=v
                end
                if my_uid == e_uid then
                    isMine = true
                end
                gameData.isMine = isMine
                gameData.enemy = uid
                game_scene:addPop("game_godfield_dart_msgpop",{gameData = gameData,isMine = isMine,rob_free_times = self.rob_free_times})
            end
            local ccbNode = luaCCBNode:create()
            ccbNode:registerFunctionWithFuncName("onMainClick",onclickFunc)
            ccbNode:openCCBFile("ccb/ui_godfield_dart_shipTestItem.ccbi")
            local btn =ccbNode:nodeForName("sp_node")
            local shipitem = ccbNode:controlButtonForName("shipitem")
            shipitem:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
            local jiaobiao = ccbNode:spriteForName("jiaobiao")
            local icfg = self.ship_lists[j][i]
            local uid_data = icfg["member"]
            for k,v in pairs(uid_data) do
                uid = v
            end
            if uid == self.my_uid then
                jiaobiao:setVisible(true)
            else
                jiaobiao:setVisible(false)
            end
            game_util:setCCControlButtonBackground(shipitem,"dart_ship_" .. icfg.buff_sort .. ".png")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(0,0))
            if j > 6 then
                btn:setScaleX(scale2[i].x)
                btn:setScaleY(scale2[i].y)
            else
                btn:setScaleX(scale1[i].x)
                btn:setScaleY(scale1[i].y)
            end
            btn:setRotation(rotate[j])
            local x = j+(i-1)*8
            local msg = icfg["members_info"][uid]
            local name = msg.name
            local server_time =game_data:getUserStatusDataByKey("server_time") or 0
            local time = icfg.arrive_time - server_time
            local tiems = string.format("%02d:%02d", math.floor(time/60), math.floor(time%60))
            local msgLabel = nil
            if uid == self.my_uid then
                jiaobiao:setVisible(true)
                msgLabel = CCLabelTTF:create(tiems .. "sau sẽ đến nơi",TYPE_FACE_TABLE.Arial_BoldMT,10);
            else
                jiaobiao:setVisible(false)
                msgLabel = CCLabelTTF:create(name,TYPE_FACE_TABLE.Arial_BoldMT,10);
            end
            msgLabel:setPosition(ccp(0,-20))
            local pos , sc = self:getPos(j,time)
            self.list_node[j][i]:setPosition(pos)
            local sca = 1
            if sc < 1 and sc >0.75 then
                sca= 0.8
              elseif sc < 0.75 and sc >0.4 then
                sca=0.65
              elseif sc < 0.4 and sc >0 then 
                sca=0.5
            end
            ccbNode:setScale(sca)
            shipitem:setTag(x)
            self.list_node[j][i]:removeAllChildrenWithCleanup(true)
            self.list_node[j][i]:addChild(msgLabel)
            self.list_node[j][i]:addChild(ccbNode)
        end
    end
end
function game_godfield_dart_routeslist.createShipList(self,viewSize)
    local lists = self.lists
    local shiplists = {}
    local shipuid = {}
    for k,v in pairs(lists) do
        shiplists[#shiplists+1] = v
        shipuid[#shipuid+1] = k
    end
    local params = {}
    params.viewSize = viewSize
    params.column = 1
    params.row = 4
    params.direction = kCCScrollViewDirectionVertical
    params.totalItem = #shiplists
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-4;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row)
    params.newCell = function( tableView,index )
        local cell = tableView:dequeueCell()
        local itemcfg = shiplists[index+1]
        local members = itemcfg.members_info
        local msg = {}
        for k,v in pairs(members) do
            msg = v
        end
        if cell == nil then
            cell=CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()
            ccbNode:openCCBFile("ccb/ui_godfield_dart_plist_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width/2,itemSize.height/2))
            cell:addChild(ccbNode,101,101)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(101),"luaCCBNode")
            local ship_sp = ccbNode:spriteForName("ship_sp")
            local ship_name_sp = ccbNode:spriteForName("ship_name_sp")
            local name_lable = ccbNode:labelTTFForName("name_lable")
            name_lable:setString(msg.name)
            ship_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_ship_" .. itemcfg.buff_sort .. ".png"))
            ship_name_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_ship_wenzi_0" .. itemcfg.buff_sort .. ".png"))
        end
        return cell
    end
    params.itemOnClick=function (eventType,index,item )
        if eventType == "ended" and item then
            local my_uid = game_data:getUserStatusDataByKey("uid") or nil;
            gameData = shiplists[index+1] or {}
            local uid = shipuid[index+1]
            local isMine = false
            local e_uid = gameData["member"]
            for k,v in pairs(e_uid) do
                e_uid=v
            end
            if my_uid == e_uid then
                isMine = true
            end
            gameData.isMine = isMine
            gameData.enemy = uid
            game_scene:addPop("game_godfield_dart_msgpop",{gameData = gameData,isMine = isMine})
        end
    end
    return TableViewHelper:create(params)
end
-- --[[--
--     初始化
-- ]]
function game_godfield_dart_routeslist.init(self,t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_dart3.plist");
    t_params = t_params or {}
    self.index = t_params.index or 1
    self.my_uid = game_data:getUserStatusDataByKey("uid") or ""
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {}
    end
    cclog(self.m_tGameData.rob_free_times,"selfself.m_tGameData.rob_free_times")
    self.rob_free_times = self.m_tGameData.rob_free_times or 0
    self.lists= self.m_tGameData["vehicle_info"]
    local i,j = 1,0
    self.m_uidlist={}
    self.ship_lists = {}
    for k,v in pairs(self.lists) do
        if j<8 then
            j=j+1
        else
            j=0
            i=i+1
        end
        self.ship_lists[j]=self.ship_lists[j] or {}
        self.ship_lists[j][i]=v
        self.m_uidlist[#self.m_uidlist+1]=k
    end
    self.isopen = self.isopen or false
    self.m_auto_time =self.m_auto_time or 5;
end
--[[--
    创建ui入口并初始化数据
]]
function game_godfield_dart_routeslist.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_godfield_dart_routeslist