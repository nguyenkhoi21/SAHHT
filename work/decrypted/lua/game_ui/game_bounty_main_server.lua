--- game_bounty_main_server信息

local game_bounty_main_server = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,

    count_down_node = nil,
    progress_node =nil,
    table_node = nil,
    score = nil,
    m_screenShoot = nil,
    guang_table = nil,
};

--[[--
    销毁
]]
function game_bounty_main_server.destroy(self)
    -- body
    cclog("-----------------game_bounty_main_server destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;

    self.count_down_node = nil;
    self.progress_node =nil;
    self.table_node = nil;
    self.score = nil;
    self.m_screenShoot = nil;
    self.guang_table = nil;
end
--[[--
    返回
]]
function game_bounty_main_server.back(self,type)
    -- game_scene:removePopByName("game_bounty_main_server");
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_bounty_main_server.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 11 then
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                -- self:destroy();
                --game_scene:addPop("ui_vip_show_pop");
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag == 12 then
            local bounty_order = getConfig(game_config_field.server_bounty_order)
            local orderCfg = bounty_order:getNodeWithKey(tostring(self.gameData.version))
            local notice = orderCfg:getNodeWithKey("notice"):toStr()
            game_scene:addPop("game_active_limit_detail_pop",{openMsg = notice})
        elseif btnTag == 100 then
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_bounty_main.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    self.count_down_node = ccbNode:nodeForName("count_down_node")
    self.progress_node = ccbNode:nodeForName("progress_node")
    self.table_node = ccbNode:nodeForName("table_node")
    self.score = {}
    self.guang_table = {}
    for i=1,3 do
        self.score[i] = ccbNode:labelTTFForName("score" .. i)
        self.guang_table[i] = ccbNode:spriteForName("guang" .. i)
        self.guang_table[i]:runAction(game_util:createRepeatForeverFade());
        self.guang_table[i]:setVisible(false)
    end
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local btn_add = ccbNode:controlButtonForName("btn_add")
    local btn_detail = ccbNode:controlButtonForName("btn_detail")
    local btn_recharge = ccbNode:controlButtonForName("btn_recharge")
    local function onTouch( eventType,x,y )
        if(eventType == "began")then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);

    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    btn_add:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    btn_recharge:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    btn_detail:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    m_root_layer:setTouchEnabled(true);
    
    if self.m_screenShoot then
        local tempSize = m_root_layer:getContentSize();
        self.m_screenShoot:setPosition( tempSize.width*0.5, tempSize.height*0.5 );
        m_root_layer:addChild(self.m_screenShoot,-1);
    end

    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_bounty_main_server.refreshUi(self)
    local function timeOverCallFun()
        
    end
    local timeLabel = game_util:createCountdownLabel(self.gameData.time_count_down,timeOverCallFun)
    timeLabel:setAnchorPoint(ccp(0.5,0.5))
    timeLabel:setPosition(ccp(0,0))
    self.count_down_node:removeAllChildrenWithCleanup(true)
    self.count_down_node:addChild(timeLabel)

    local bounty_order = getConfig(game_config_field.server_bounty_order)
    local orderCfg = bounty_order:getNodeWithKey(tostring(self.gameData.version))
    local maxValue = orderCfg:getNodeWithKey("charge_num3"):toInt()

    local bar = ExtProgressTime:createWithFrameName("bounty_progress_back.png","bounty_progress.png")
    local score = {0,0,0}
    for i=1,3 do
        local values = orderCfg:getNodeWithKey("charge_num" .. i):toInt()
        self.score[i]:setString(values)
        score[i] = values

        if self.gameData.rechange_cost >= values then
            self.guang_table[i]:setVisible(true)
        end
    end
    --分段取
    local value = self.gameData.rechange_cost
    value = game_util:getSectionBarValue(self.gameData.rechange_cost,score)
    -- if self.gameData.rechange_cost < score[1] then
    --     value = (self.gameData.rechange_cost * maxValue) / (3 * score[1])
    -- elseif self.gameData.rechange_cost >= score[1] and self.gameData.rechange_cost < score[2] then
    --     value = math.min((maxValue / 3) + ((self.gameData.rechange_cost - score[1]) * 2 * maxValue) / (3 * score[2]),maxValue * 2 / 3)
    -- elseif self.gameData.rechange_cost >= score[2] then
    --     value = (2 * maxValue / 3) + (self.gameData.rechange_cost - score[2]) * 2 / 3 
    -- end
    -- for i=1,section-1 do
    --     self.guang_table[i]
    -- end

    bar:setMaxValue(maxValue);
    bar:setCurValue(value,false);
    bar:setAnchorPoint(ccp(0.5,0.5));
    bar:setPosition(ccp(0,-1));
    self.progress_node:addChild(bar,-1,10);

    local barTTF = CCLabelTTF:create(self.gameData.rechange_cost.."/"..maxValue,TYPE_FACE_TABLE.Arial_BoldMT,12);
    barTTF:setAnchorPoint(ccp(0.5,0.5))
    self.progress_node:addChild(barTTF,10)

    self.table_node:removeAllChildrenWithCleanup(true)
    local tableViewTemp = self:createTableView(self.table_node:getContentSize());
    tableViewTemp:setTouchEnabled(false)
    self.table_node:addChild(tableViewTemp);

end
function game_bounty_main_server.createTableView(self,viewSize)
    local bounty_order = getConfig(game_config_field.server_bounty_order);
    local orderCfg = bounty_order:getNodeWithKey(tostring(self.gameData.version))
    local function onCellClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        local index = btnTag        
        if game_util:idInTableById(index,self.gameData.is_ok) then--all task done but not receive
            local screenShoot = self.m_screenShoot
            screenShoot:retain()
            local function responseMethod(tag,gameData)
                local reward = gameData:getNodeWithKey("data"):getNodeWithKey("reward")
                game_util:rewardTipsByJsonData(reward);

                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    self.gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                end
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_bounty_order_get_big_reward"), http_request_method.GET, {type = index},"server_bounty_order_get_big_reward")
        else
            local bounty_order = getConfig(game_config_field.server_bounty_order)
            local orderCfg = bounty_order:getNodeWithKey(tostring(self.gameData.version))
            local openFlag = false
            local values = orderCfg:getNodeWithKey("charge_num" .. index):toInt()
            if self.gameData.rechange_cost >= values then
                openFlag = true
            end
            local screenShoot = self.m_screenShoot
            screenShoot:retain()
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_bounty_task_server",{gameData = gameData,screenShoot = screenShoot,lookType = index,openFlag = openFlag})
                screenShoot:release()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_bounty_order_task_index"), http_request_method.GET, {type = index},"server_bounty_order_task_index")
        end
    end
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local rewardShow = orderCfg:getNodeWithKey("reward_show_" .. btnTag):getNodeAt(0)
        local rewardShowTable = json.decode(rewardShow:getFormatBuffer()) or {}
        game_util:lookItemDetal(rewardShowTable)
    end
    local params = {};
    local title = {"bounty_titles.png","bounty_titless.png","bounty_titlesss.png"}
    local back = {}
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 3; --列
    params.totalItem = 3;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-3;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionHorizontal;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellClick",onCellClick);
            ccbNode:openCCBFile("ccb/ui_bounty_main_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            ccbNode:controlButtonForName("btn_detail"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-4);
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            local btn_detail = ccbNode:controlButtonForName("btn_detail")
            local complete = ccbNode:spriteForName("complete")
            local icon_sprite = ccbNode:spriteForName("icon_sprite")
            local icon_node = ccbNode:layerForName("icon_node")
            local title_sprite = ccbNode:spriteForName("title_sprite")
            local light_sprite = ccbNode:spriteForName("light_sprite")
            local number = ccbNode:labelTTFForName("m_number")


            title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(title[index+1]))
            icon_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("bounty_icon" .. (index+1) .. ".png"))
            light_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("bounty_light" .. (index+1) .. ".png"))
            
            local values = orderCfg:getNodeWithKey("charge_num" .. index + 1):toInt()
            if self.gameData.rechange_cost >= values then
                light_sprite:runAction(game_util:createRepeatForeverFade());
                light_sprite:setVisible(true)
            else
                light_sprite:stopAllActions()
                light_sprite:setVisible(false)
            end

            btn_detail:setTag(index+1)

            local rewardShow = orderCfg:getNodeWithKey("reward_show_" .. index+1):getNodeAt(0)
            local icon,name,count = game_util:getRewardByItem(rewardShow)
            icon_node:removeAllChildrenWithCleanup(true)
            if icon then
                icon:setScale(0.7)
                icon_node:addChild(icon)
            end
            if count then
                number:setString("x"..count)
                -- local color = count > ownCount and ccc3(77,77,77) or ccc3(0,255,0)
                -- local tempLabel = game_util:createLabelTTF({text ="x"..count ,color = ccc3(255,255,255),fontSize = 8});
                -- tempLabel:setPosition(ccp(itemSize.width*0.9, itemSize.height*0.1))
                -- icon_node:addChild(tempLabel,1)
            end
            --look detail 
            local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
            button:setTag(index+1)
            button:setOpacity(0)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
            button:setAnchorPoint(ccp(0.5,0.5))
            icon_node:addChild(button);

            if game_util:idInTableById(index+1,self.gameData.big_reward) then--reward had received
                complete:setVisible(true)
                btn_detail:setEnabled(false)
                game_util:setCCControlButtonTitle(btn_detail,"Đã nhận");
            elseif game_util:idInTableById(index+1,self.gameData.is_ok) then--all task done but not receive
                complete:setVisible(true)
                btn_detail:setEnabled(true)
                game_util:setCCControlButtonTitle(btn_detail,"Nhận");
            else
                complete:setVisible(false)
                btn_detail:setEnabled(true)
                game_util:setCCControlButtonTitle(btn_detail,"Chi tiết nhiệm vụ");
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
    
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        
    end
    return TableViewHelper:create(params);
end
--[[--
    初始化
]]
function game_bounty_main_server.init(self,t_params)
    t_params = t_params or {};
    -- self.gameData = t_params.gameData
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    self.m_screenShoot = t_params.screenShoot
end
--[[--
    创建ui入口并初始化数据
]]
function game_bounty_main_server.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    return rootScene;
end

return game_bounty_main_server;