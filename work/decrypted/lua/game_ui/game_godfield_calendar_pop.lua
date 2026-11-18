---  周日战报信息
local game_godfield_calendar_pop = {
    m_root_layer = nil,
    btn_close = nil,
    table_view_node = nil,
    m_zhuangtai_sp = nil,
    m_sprite_tab = nil,
    m_tGameData = nil,
    m_bg_sp = nil,
};

--[[--
    销毁
]]
function game_godfield_calendar_pop.destroy(self)
    cclog("--------game_godfield_calendar_pop  destroy ------")
    self.m_root_layer = nil;
    self.btn_close = nil;
    self.table_view_node = nil;
    self.m_zhuangtai_sp = nil;
    self.m_sprite_tab = nil;
    self.m_tGameData = nil;
    self.m_bg_sp = nil;
end
--[[--
    返回
]]
function game_godfield_calendar_pop.back(self,type)
    local function responseMethod( tag,gameData )
        local data = gameData:getNodeWithKey("data");
        data = json.decode(data:getFormatBuffer()) or {};
        game_scene:enterGameUi("game_godfield_main",{gameData = gameData})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")

end
--[[--
    读取ccbi创建ui
]]
function game_godfield_calendar_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local status = 0
        status = tonumber(self.m_tGameData.status)
        --cclog2(btnTag,"btnTag ==")
        if btnTag == 1 then --返回
            self:back();
        elseif btnTag == 0 then 
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_godfield_calendar.ccbi");
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    
    self.m_root_layer = ccbNode:layerForName("m_root_layer") 
    self.btn_close = ccbNode:controlButtonForName("m_back_btn")
    self.table_view_node = ccbNode:nodeForName("table_view_node")
    self.m_bg_sp = ccbNode:spriteForName("m_bg_sp")
    self.m_bg_sp:setScale(1)
    self.btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY-16)
    self.ccbNode = ccbNode
    self.m_sprite_tab = {}
    local m_zhenxingIcon,m_timeBg,m_time_lab,m_zhuangtai_sp = nil;
    for i=1,5 do
        m_zhenxingIcon = ccbNode:scale9SpriteForName("m_zhenxingIcon" .. i)
        --cclog2(m_zhenxingIcon,"m_zhenxingIcon")
        m_timeBg = ccbNode:scale9SpriteForName("m_timeBg" .. i)
        m_time_lab = ccbNode:labelTTFForName("m_time_lab" .. i)
        m_zhuangtai_sp = ccbNode:spriteForName("m_zhuangtai_sp" .. i)
        ----self:createSpriteButton(m_timeBg,i)
        self.m_sprite_tab[i] = {m_zhuangtai_sp = m_zhuangtai_sp ,m_time_lab = m_time_lab , m_zhenxingIcon = m_zhenxingIcon , m_timeBg = m_timeBg}
        
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 15,true);
    self.m_root_layer:setTouchEnabled(true);

    return ccbNode;
end
function game_godfield_calendar_pop.createVsTableView( self,btnTag,viewSize,isLookBattle )
    local length = #self.m_tGameData.logs[tostring(btnTag)]
    if btnTag == 1 then
        length = 1
    end
    --cclog2(self.m_tGameData.logs[tostring(btnTag)],"self.m_tGameData.logs[tostring(btnTag)] == ")
    local params = {};
    --local m_tab = {}
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 2; --列
    params.totalItem = length
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-16
    params.itemActionFlag = true
    --params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_godfield_calendar_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0,0))
            ccbNode:setPosition(ccp(itemSize.width*0.5-110,itemSize.height*0.5-14));
            cell:addChild(ccbNode,10,10);
            cclog(viewSize)
        end
        if cell then

            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --local itemData = m_tab[index+1];
            -- local itemCfg = arena_award:getNodeWithKey(tostring(index+1))
            local m_label_name1 = ccbNode:labelTTFForName("m_label_name1")
            local m_label_name2 = ccbNode:labelTTFForName("m_label_name2")
            local m_label_guild1 = ccbNode:labelTTFForName("m_label_guild1")
            local m_label_guild2 = ccbNode:labelTTFForName("m_label_guild2")
            local times = self.m_tGameData.logs[tostring(btnTag)]
            --local x = times[index+1][tostring(index+1)]["defender"]
            local text_name2 = times[index+1][tostring(index+1)]["defender"]
            local text_name1 = times[index+1][tostring(index+1)]["attacker"]
            local text_guild1 = times[index+1][tostring(index+1)]["attacker_server"]
            local text_guild2 = times[index+1][tostring(index+1)]["defender_server"]
            m_label_name1:setString(tostring(text_name1))
            m_label_name2:setString(tostring(text_name2))
            m_label_guild1:setString(tostring(text_guild1))
            m_label_guild2:setString(tostring(text_guild2))
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item) 
        local screenShoot = game_util:createScreenShoot();
        screenShoot:retain();   
        if eventType == "ended" and item then
            if isLookBattle == true then
            local stage_id = tostring(btnTag)
            local times = index+1
            local params = {}
            params.stage_id = stage_id
            params.times = times
            local function responseMethod( tag,gameData )
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local function endCallFunc( )
                        screenShoot:release();
                        self:back()
                    end
                    local data1 = gameData:getNodeWithKey("data");
                    data1 = json.decode(data1:getFormatBuffer())
                    --cclog2(data1,"data1 == ")
                    game_data:setGodfieldData(data1)
                end
                game_scene:enterGameUi("game_godfield_battle_result",{gameData = gameData,screenShoot = screenShoot,mType = "calendar"},{endCallFunc = endCallFunc})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_final_battle_log"), http_request_method.GET, params,"god_field_final_battle_log")
            else
                game_util:addMoveTips({text = "Không thể xem khi chưa kết thúc！"})
            end
        end
    end
    return TableViewHelper:create(params);
    -- body
end
function game_godfield_calendar_pop.createSpriteButton( self,sprite,i,isLookBattle)
    local function onMainBtnClick( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- local status = 0
        -- status = tonumber(self.m_tGameData.status)
        if btnTag == 1 then
            local i = 5 
            self:refreshVsTableView(i,isLookBattle);
        elseif btnTag == 2 then
            local i = 4
            self:refreshVsTableView(i,isLookBattle);
        elseif btnTag == 3 then
            local i = 3 
            self:refreshVsTableView(i,isLookBattle);
        elseif btnTag == 4 then
            local i = 2 
            self:refreshVsTableView(i,isLookBattle);
        elseif btnTag == 5 then   
            local i = 1 
            self:refreshVsTableView(i,isLookBattle);
        end
    end
        local contentSize = sprite:getContentSize();
        local button = game_util:createCCControlButton("public_weapon.png","",onMainBtnClick)
        button:setPreferredSize(contentSize)
        button:setTag(i)
        button:setOpacity(0)
        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-16)
        button:setAnchorPoint(ccp(0,0))

        button:setPosition(ccp(sprite:getPositionX(),sprite:getPositionY()))
        sprite:getParent():addChild(button,10);
        -- sprite:addChild(button,10);
    
    -- body
end

function game_godfield_calendar_pop.creteSpriteStatus( self )
    local status = nil;
    --cclog2(self.m_tGameData,"self.m_tGameData creteSpriteStatus ===")
    status = tonumber(self.m_tGameData.status)
    local x = 6
    for  i = 1,5 do
        if status> 0 and status<5 then
            local times = self.m_tGameData.logs[tostring(5)] 
            if next(times) then
                local temp_m_zhuangtai_sp = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_godfield_end.png")
                local temp_m_zhenxingIcon = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_godfield_hei2.png")
                local temp_m_timeBg = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_godfield_hui.png")
                --self.m_sprite_tab[i].m_time_lab:setColor(255,0,255)
                self.m_sprite_tab[x-5].m_zhenxingIcon:setSpriteFrame(temp_m_zhenxingIcon)
                self.m_sprite_tab[x-5].m_timeBg:setSpriteFrame(temp_m_timeBg)
                self.m_sprite_tab[x-5].m_zhuangtai_sp:setDisplayFrame(temp_m_zhuangtai_sp)
                self.m_sprite_tab[x-5].m_zhuangtai_sp:setVisible(true)
                local isLookBattle = true
                self:createSpriteButton(self.m_sprite_tab[x-5].m_timeBg,x-5,isLookBattle)
            else
                local temp_m_zhuangtai_sp = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_godfield_end.png")
                local temp_m_zhenxingIcon = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_godfield_lan2.png")
                local temp_m_timeBg = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_godfield_lan.png")
                --self.m_sprite_tab[i].m_time_lab:setColor(255,0,255)
                self.m_sprite_tab[x-5].m_zhenxingIcon:setSpriteFrame(temp_m_zhenxingIcon)
                self.m_sprite_tab[x-5].m_timeBg:setSpriteFrame(temp_m_timeBg)
                --cclog2(self.m_sprite_tab[x].m_zhuangtai_sp,"self.m_sprite_tab[i].m_zhuangtai_sp")
                self.m_sprite_tab[x-5].m_zhuangtai_sp:setVisible(false)
            end

        elseif x == status then

            local temp_m_zhuangtai_sp = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_godfield_doing.png")
            local temp_m_zhenxingIcon = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_godfield_lv2.png")
            local temp_m_timeBg = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_godfield_lv.png")
            --self.m_sprite_tab[i].m_time_lab:setColor(255,0,255)
            self.m_sprite_tab[x-5].m_zhenxingIcon:setSpriteFrame(temp_m_zhenxingIcon)
            self.m_sprite_tab[x-5].m_timeBg:setSpriteFrame(temp_m_timeBg)
            self.m_sprite_tab[x-5].m_zhuangtai_sp:setDisplayFrame(temp_m_zhuangtai_sp)
            self.m_sprite_tab[x-5].m_zhuangtai_sp:setVisible(true)
            local isLookBattle = false
            self:createSpriteButton(self.m_sprite_tab[x-5].m_timeBg,x-5,isLookBattle)

        elseif x < status then
            local temp_m_zhuangtai_sp = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_godfield_end.png")
            local temp_m_zhenxingIcon = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_godfield_hei2.png")
            local temp_m_timeBg = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_godfield_hui.png")
            --self.m_sprite_tab[i].m_time_lab:setColor(255,0,255)
            self.m_sprite_tab[x-5].m_zhenxingIcon:setSpriteFrame(temp_m_zhenxingIcon)
            self.m_sprite_tab[x-5].m_timeBg:setSpriteFrame(temp_m_timeBg)
            self.m_sprite_tab[x-5].m_zhuangtai_sp:setDisplayFrame(temp_m_zhuangtai_sp)
            self.m_sprite_tab[x-5].m_zhuangtai_sp:setVisible(true)
            local isLookBattle = true
            self:createSpriteButton(self.m_sprite_tab[x-5].m_timeBg,x-5,isLookBattle)
        else
            local temp_m_zhuangtai_sp = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_godfield_end.png")
            local temp_m_zhenxingIcon = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_godfield_lan2.png")
            local temp_m_timeBg = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_godfield_lan.png")
            --self.m_sprite_tab[i].m_time_lab:setColor(255,0,255)
            self.m_sprite_tab[x-5].m_zhenxingIcon:setSpriteFrame(temp_m_zhenxingIcon)
            self.m_sprite_tab[x-5].m_timeBg:setSpriteFrame(temp_m_timeBg)
            --cclog2(self.m_sprite_tab[x].m_zhuangtai_sp,"self.m_sprite_tab[i].m_zhuangtai_sp")
            self.m_sprite_tab[x-5].m_zhuangtai_sp:setVisible(false)
        end
        x = x+ 1
    end
    -- body
end
function game_godfield_calendar_pop.refreshVsTableView(self,i,isLookBattle)
    cclog("refreshVsTableView  === ")
    self.table_view_node:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createVsTableView(i,self.table_view_node:getContentSize(),isLookBattle);
    --cclog2(tableViewTemp,"tableViewTem === ")
    self.table_view_node:addChild(tableViewTemp,66);
end
--[[--
    刷新ui
]]
function game_godfield_calendar_pop.refreshUi(self)
   
    self:creteSpriteStatus()
end

--[[--
    初始化
]]
function game_godfield_calendar_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    --cclog2(t_params,"t_params === ")
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    elseif tolua.type(t_params.gameData) == "table" then
        self.m_tGameData = t_params.gameData
    end
    -- cclog("self.itemCfg == " .. json.encode(self.itemCfg))
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_calendar_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_godfield_calendar_pop;