local game_server_active_show = {
    selectIndex = nil,
    ver_table_node = nil,
    hor_table_node = nil,
    time_node = nil,
    title_sprite = nil,

    m_tGameData = nil,
    selectIndex = nil,
    showCfg = nil,
    indexTable = nil,
    m_tableView = nil,
    showIndex = nil,
    m_showExchangeIdTab = nil,
    typeid = nil,
    myIndex = nil,
    exchangeData = nil,
    m_tableView = nil,
    m_tableView2 = nil,
    m_tableView3 = nil,
    m_tableView4 = nil,
    m_tableView5 = nil,
    exchange_index = nil,--兑换类型，1是限时兑换，2是常规兑换
    m_current_Sort = nil,
};

function game_server_active_show:destroy()
    -- body
    cclog("----------------- game_server_active_show destroy-----------------"); 
    self.ver_table_node = nil;
    self.hor_table_node = nil;
    self.time_node = nil;
    self.title_sprite = nil;

    self.m_tGameData = nil;
    self.selectIndex = nil;
    self.showCfg = nil;
    self.indexTable = nil;
    self.m_tableView = nil;
    self.showIndex = nil;
    self.m_showExchangeIdTab = nil;
    self.typeid = nil;
    self.myIndex = nil;
    self.exchangeData = nil;
    self.m_tableView2 = nil;
    self.m_tableView3 = nil;
    self.m_tableView4 = nil;
    self.m_tableView5 = nil;
    self.exchange_index = nil;
    self.m_current_Sort = nil;
end




function game_server_active_show:back()
    game_scene:enterGameUi("game_main_scene",{gameData = nil})
end

--[[--
    读取ccbi创建ui
]]
function game_server_active_show.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- print("press button tag is ", btnTag)
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 11 then
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                self:destroy();
             --game_scene:addPop("ui_vip_show_pop")

            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_active_recharge.ccbi");

    self.ver_table_node = ccbNode:nodeForName("ver_table_node")
    self.hor_table_node = ccbNode:nodeForName("hor_table_node")
    self.time_node = ccbNode:nodeForName("time_node")
    self.title_sprite = ccbNode:spriteForName("title_sprite")
    local btn_recharge = ccbNode:controlButtonForName("btn_recharge")
    local m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    btn_recharge:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            local realPos = self.ver_table_node:getParent():convertToNodeSpace(ccp(x,y));
            if self.ver_table_node:boundingBox():containsPoint(realPos) then
                return false;
            end
            return true;  
        end 
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end





--[[
    横的table
]]
function game_server_active_show.createLandTable(self,viewSize,showPage)
    local tabCount = game_util:getTableLen(self.showCfg)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 4; --列
    params.showPoint = false
    params.totalItem = tabCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 1
    params.showPageIndex = showPage or 1
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create()            
            ccbNode:openCCBFile("ccb/ui_active_recharge_item2.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            
            local m_sprite_titleType = ccbNode:spriteForName("m_sprite_titleType")
            local banner_sprite = ccbNode:spriteForName("banner_sprite")
            local light_add = ccbNode:scale9SpriteForName("light_add")

            local itemData = self.showCfg[index+1]
            local banner = itemData.banner
            
            local mark = itemData.mark

            banner_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(banner .. ".png"))
            m_sprite_titleType:setVisible(true)
            if mark == 1 then--new图标
                m_sprite_titleType:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_announce_h2.png"))
            elseif mark == 2 then--hot
                m_sprite_titleType:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_announce_h1.png"))
            else
                m_sprite_titleType:setVisible(false)
            end
            if self.selectIndex == index + 1 then
                light_add:setVisible(true)
            else
                light_add:setVisible(false)
            end
        end
        return cell
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
            if self.selectIndex ~= index + 1 then
                self.selectIndex = index + 1
                -- self:refreshTable2()
                -- self:refreshLabel()
                self:refreshUi()
            end
        end
    end
    local tempTable = TableViewHelper:createGallery3(params);
    return tempTable
end

--[[
    竖的table
]]
function game_server_active_show.createPorTable(self,viewSize)
    --取服务器数据
    local serverData = self.m_tGameData.show
    local itemShowData = serverData[tostring(self.myIndex)]
    local context = itemShowData.context
    local rechargeCfg = getConfig(game_config_field.server_active_recharge);
    local rechargeData = {}
    --改为不取配置，取服务器数据
    for k,v in pairs(context) do
        local itemFlag = v.flag
        if itemFlag ~= -1 then
            local itemCfg = rechargeCfg:getNodeWithKey(tostring(k))
            local itemData = json.decode(itemCfg:getFormatBuffer())
            itemData.id = k
            table.insert(rechargeData,itemData)
        end
    end
        
    local function sortFunc(itemData1,itemData2)
        local show_id1 = itemData1.show_id
        local show_id2 = itemData2.show_id
        return show_id1 < show_id2
    end
    table.sort( rechargeData, sortFunc )
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local charge_type = math.floor(btnTag / 100)
        local index = btnTag % 100
        local params = {}
        params.active_id = rechargeData[index+1].id
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local reward = data:getNodeWithKey("reward")
            game_util:rewardTipsByJsonData(reward);
            local tempData = json.decode(data:getFormatBuffer()) or {};
            self.m_tGameData.show[tostring(self.myIndex)].context = tempData.show
            self:refreshUi()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_server_active_recharge_receive"), http_request_method.GET, params,"active_server_active_recharge_receive")
    end

    local tabCount = game_util:getTableLen(rechargeData)

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
        local index = math.floor(btnTag / 100)
        local reward = rechargeData[index+1].reward
        local id = btnTag % 100
        local itemData = reward[id]
        game_util:lookItemDetal(itemData)
    end

    local nodeSizeW = 320
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tabCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY + 1
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_active_recharte_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            
            local tip_word_label = ccbNode:labelTTFForName("tip_word_label")
            local btn_go = ccbNode:controlButtonForName("btn_go")
            btn_go:removeAllChildrenWithCleanup(true)
            btn_go:setScale(1)

            local reward_layer = ccbNode:layerForName("reward_layer")
            local tip_time_label = ccbNode:labelTTFForName("tip_time_label")
            local time_lable = ccbNode:labelTTFForName("time_lable")
            -- self:initLayerTouch(reward_layer);

            local rewardNode = {}
            local addSprite = {}
            local reward = rechargeData[index+1].reward
            local show_time = rechargeData[index+1].show_time
            
            local rewardCount = game_util:getTableLen(reward)
            for i=1,5 do
                rewardNode[i] = ccbNode:nodeForName("reward_node_" .. i)
                addSprite[i] = ccbNode:spriteForName("sprite_" .. i)

                rewardNode[i]:removeAllChildrenWithCleanup(true)
                rewardNode[i]:setVisible(true)
                addSprite[i]:setVisible(true)
                local dw = nodeSizeW / rewardCount
                local dx = dw / 2
                if i <= rewardCount then
                    local rewardItem = reward[i]
                    local reward_icon,name,count = game_util:getRewardByItemTable(rewardItem,true);
                    if reward_icon then
                        reward_icon:setAnchorPoint(ccp(0.5,0.5))
                        reward_icon:setScale(0.7)

                        rewardNode[i]:addChild(reward_icon)

                        rewardNode[i]:setPosition(ccp(dx + (i-1)*dw,33))
                        addSprite[i]:setPosition(ccp(dx * 2 + (i-1)*dw ,33))

                        --加查看按钮
                        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                        button:setAnchorPoint(ccp(0.5,0.5))
                        button:setScale(0.7)
                        button:setTag(index * 100 + i)
                        button:setOpacity(0)
                        rewardNode[i]:addChild(button)

                        if name then
                            local nameLabel = game_util:createLabelTTF({text = name})
                            nameLabel:setColor(ccc3(250,180,0))
                            nameLabel:setAnchorPoint(ccp(0.5, 0.5))
                            nameLabel:setPosition(reward_icon:getContentSize().width * 0.5, -10)
                            reward_icon:addChild(nameLabel, 11)
                        end
                    end
                    
                else
                    rewardNode[i]:setVisible(false)
                    addSprite[i]:setVisible(false)
                end
            end
            addSprite[rewardCount]:setVisible(false)

            local id = rechargeData[index+1].id
            local flag = context[tostring(id)].flag
            -- btn_go:setVisible(false)
            local test1 = btn_go:getChildByTag(10)
            local test2 = btn_go:getChildByTag(11)
            if test1 and test2 then
                test1:removeFromParentAndCleanup(true)
                test2:removeFromParentAndCleanup(true)
            end
            if flag == 0 then--可领取
                -- btn_go:setVisible(true)
                btn_go:setEnabled(true)
                game_util:setCCControlButtonBackground(btn_go,"recharge_get.png")
                if test1 == nil and test2 == nil then
                    game_util:createPulseAnmi("recharge_get.png",btn_go)
                end
            elseif flag == 1 then--不可领取
                btn_go:setEnabled(false)
                game_util:setCCControlButtonBackground(btn_go,"recharge_loss.png")

            else
                game_util:setCCControlButtonBackground(btn_go,"recharge_already.png")
                btn_go:setEnabled(false)
            end
            --加服务器数据
            local repeatValue = rechargeData[index+1]["repeat"]
            local charge_type = rechargeData[index+1]["charge_type"]
            local des = rechargeData[index+1].des
            -- if repeatValue == 1 or charge_type == 2 then--重复为1 或者 charge_type为2的需要显示
            if charge_type == 2 then--改为只有charge_type为2的需要显示
                local now_value = context[tostring(id)].now_value or "0"
                local num = rechargeData[index+1].num
                des = des .. "(" .. now_value .. "/" .. num .. ")"
            end
            tip_word_label:setString(des or "")
            if show_time then
                time_lable:setVisible(true)
                tip_time_label:setString(show_time)
            else
                time_lable:setVisible(false)
                tip_time_label:setVisible(false)
            end
            --设置button索引   self.selectIndex * 100 + index
            btn_go:setTag(self.myIndex * 100 + index)
            --设置触摸
            
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then            
        end
    end
    return TableViewHelper:create(params);
end

--[[
    竖的table2
]]
function game_server_active_show.createPorTable2(self,viewSize)
    --取服务器数据
    local serverData = self.m_tGameData.show
    local itemShowData = serverData[tostring(self.myIndex)]
    local context = itemShowData.context
    local rechargeCfg = getConfig(game_config_field.server_active_consume);
    local rechargeData = {}
    --改为不取配置，取服务器数据
    for k,v in pairs(context) do
        local itemFlag = v.flag
        if itemFlag ~= -1 then
            local itemCfg = rechargeCfg:getNodeWithKey(tostring(k))
            local itemData = json.decode(itemCfg:getFormatBuffer())
            itemData.id = k
            table.insert(rechargeData,itemData)
        end
    end
    local function sortFunc(itemData1,itemData2)
        local show_id1 = itemData1.show_id
        local show_id2 = itemData2.show_id
        return show_id1 < show_id2
    end
    table.sort( rechargeData, sortFunc )
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local charge_type = math.floor(btnTag / 100)
        local index = btnTag % 100
        local params = {}
        params.active_id = rechargeData[index+1].id
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local reward = data:getNodeWithKey("reward")
            game_util:rewardTipsByJsonData(reward);
            local tempData = json.decode(data:getFormatBuffer()) or {};
            self.m_tGameData.show[tostring(self.myIndex)].context = tempData.show
            self:refreshUi()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_server_active_consume_receive"), http_request_method.GET, params,"active_server_active_consume_receive")
    end

    local tabCount = game_util:getTableLen(rechargeData)

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
        local index = math.floor(btnTag / 100)
        local reward = rechargeData[index+1].reward
        local id = btnTag % 100
        local itemData = reward[id]
        game_util:lookItemDetal(itemData)
    end

    local nodeSizeW = 320
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tabCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY + 1
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_active_recharte_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local tip_word_label = ccbNode:labelTTFForName("tip_word_label")
            local btn_go = ccbNode:controlButtonForName("btn_go")
            local reward_layer = ccbNode:layerForName("reward_layer")
            local tip_time_label = ccbNode:labelTTFForName("tip_time_label")
            local time_lable = ccbNode:labelTTFForName("time_lable")
            local rewardNode = {}
            local addSprite = {}
            local reward = rechargeData[index+1].reward
            local show_time = rechargeData[index + 1].show_time
            
            local rewardCount = game_util:getTableLen(reward)
            for i=1,5 do
                rewardNode[i] = ccbNode:nodeForName("reward_node_" .. i)
                addSprite[i] = ccbNode:spriteForName("sprite_" .. i)
                rewardNode[i]:removeAllChildrenWithCleanup(true)
                rewardNode[i]:setVisible(true)
                addSprite[i]:setVisible(true)
                local dw = nodeSizeW / rewardCount
                local dx = dw / 2
                if i <= rewardCount then
                    local rewardItem = reward[i]
                    local reward_icon,name,count = game_util:getRewardByItemTable(rewardItem,true);
                    if reward_icon then
                        reward_icon:setAnchorPoint(ccp(0.5,0.5))
                        reward_icon:setScale(0.7)

                        rewardNode[i]:addChild(reward_icon)

                        rewardNode[i]:setPosition(ccp(dx + (i-1)*dw,33))
                        addSprite[i]:setPosition(ccp(dx * 2 + (i-1)*dw ,33))
                        --加查看按钮
                        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                        button:setAnchorPoint(ccp(0.5,0.5))
                        button:setScale(0.7)
                        button:setTag(index * 100 + i)
                        button:setOpacity(0)
                        rewardNode[i]:addChild(button)
                        if name then
                            local nameLabel = game_util:createLabelTTF({text = name})
                            nameLabel:setColor(ccc3(250,180,0))
                            nameLabel:setAnchorPoint(ccp(0.5, 0.5))
                            nameLabel:setPosition(reward_icon:getContentSize().width * 0.5, -10)
                            reward_icon:addChild(nameLabel, 11)
                        end
                    end
                    
                else
                    rewardNode[i]:setVisible(false)
                    addSprite[i]:setVisible(false)
                end
            end
            addSprite[rewardCount]:setVisible(false)

            local id = rechargeData[index+1].id
            local flag = context[tostring(id)].flag
            -- btn_go:setVisible(false)
            local test1 = btn_go:getChildByTag(10)
            local test2 = btn_go:getChildByTag(11)
            if test1 and test2 then
                test1:removeFromParentAndCleanup(true)
                test2:removeFromParentAndCleanup(true)
            end
            if flag == 0 then--可领取
                -- btn_go:setVisible(true)
                btn_go:setEnabled(true)
                game_util:setCCControlButtonBackground(btn_go,"recharge_get.png")
                if test1 == nil and test2 == nil then
                    game_util:createPulseAnmi("recharge_get.png",btn_go)
                end
            elseif flag == 1 then--不可领取
                btn_go:setEnabled(false)
                game_util:setCCControlButtonBackground(btn_go,"recharge_loss.png")
            else
                -- btn_go:setVisible(true)
                game_util:setCCControlButtonBackground(btn_go,"recharge_already.png")
                btn_go:setEnabled(false)
            end
            --加服务器数据
            local repeatValue = rechargeData[index+1]["repeat"]
            -- local charge_type = rechargeData[index+1]["charge_type"]
            local des = rechargeData[index+1].des
            -- if repeatValue == 1 or charge_type == 2 then--重复为1 或者 charge_type为2的需要显示
            -- if charge_type == 2 then--改为只有charge_type为2的需要显示
                local now_value = context[tostring(id)].now_value or "0"
                local num = rechargeData[index+1].num
                des = des .. "(" .. now_value .. "/" .. num .. ")"
            -- end
            tip_word_label:setString(des)
            if show_time then
                time_lable:setVisible(true)
                tip_time_label:setString(show_time)
            else
                time_lable:setVisible(false)
                tip_time_label:setVisible(false)
            end
            --设置button索引   self.selectIndex * 100 + index
            btn_go:setTag(self.myIndex * 100 + index)
            --设置触摸
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


function game_server_active_show.refreshTable1(self)
    self.hor_table_node:removeAllChildrenWithCleanup(true);
     local tempTable
    if self.selectIndex < 5 then
        tempTable = self:createLandTable(self.hor_table_node:getContentSize(),1);

    elseif self.selectIndex >4 and self.selectIndex <9 then 
        tempTable = self:createLandTable(self.hor_table_node:getContentSize(),2);

    elseif self.selectIndex >8 and self.selectIndex <11 then
        tempTable = self:createLandTable(self.hor_table_node:getContentSize(),3);
    end
    self.hor_table_node:addChild(tempTable,10,10);
end


function game_server_active_show.refreshTable6(self,sort)
    local pX,pY;


    if self.m_tableView5 then
        pX,pY = self.m_tableView5:getContainer():getPosition();
    end

    if sort == self.m_current_Sort then
    else
        pX = 0
        pY = 0
    end
    self.m_current_Sort = sort
    self.ver_table_node:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil;
    self.m_tableView2 = nil;
    self.m_tableView3 = nil;
    self.m_tableView4 = nil;
    self.m_tableView5 = nil;
    self.m_tableView5 = self:createPorTable(self.ver_table_node:getContentSize());
    self.ver_table_node:addChild(self.m_tableView5,10,10);
    if pX and pY then
        self.m_tableView5:setContentOffset(ccp(pX,pY), false);
    end
end

function game_server_active_show.refreshTable2(self)
    local pX,pY;
    if self.m_tableView3 then
        pX,pY = self.m_tableView3:getContainer():getPosition();
    end
    self.ver_table_node:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil;
    self.m_tableView2 = nil;
    self.m_tableView3 = nil;
    self.m_tableView4 = nil;
    self.m_tableView5 = nil;
    self.m_tableView3 = self:createPorTable(self.ver_table_node:getContentSize());
    self.ver_table_node:addChild(self.m_tableView3,10,10);
    if pX and pY then
        self.m_tableView3:setContentOffset(ccp(pX,pY), false);
    end
end

function game_server_active_show.refreshTable4(self,sort)
    local pX,pY;
    if self.m_tableView2 then
        pX,pY = self.m_tableView2:getContainer():getPosition();
    end
    if sort == self.m_current_Sort then
    else
        pX = 0
        pY = 0
    end
    self.m_current_Sort = sort
    self.ver_table_node:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil;
    self.m_tableView2 = nil;
    self.m_tableView3 = nil;
    self.m_tableView4 = nil;
    self.m_tableView5 = nil;
    self.m_tableView2 = self:createPorTable2(self.ver_table_node:getContentSize());
    self.ver_table_node:addChild(self.m_tableView2,10,10);
    if pX and pY then
        self.m_tableView2:setContentOffset(ccp(pX,pY), false);
    end
end
--[[--
    刷新ui
]]
function game_server_active_show.refreshUi(self)
    self.myIndex = self.showCfg[self.selectIndex].id
    if game_util:getTableLen(self.m_tGameData.show) ~= 0 then
        self:refreshTable1()
        local sort = self.showCfg[self.selectIndex].sort
        -- if sort > 0 and sort < 3 then--充值活动
        if sort == 1 then--单笔充值
            self:refreshTable2()
        elseif sort == 2 or sort == 6 or sort == 7 then--累计充值
            self:refreshTable6(sort)
        elseif sort == 4  or sort == 8 then--消耗活动
            self:refreshTable4(sort)
        elseif sort == 3 then--兑换中心
            -- local function responseMethod(tag,gameData)
            --     local data = gameData:getNodeWithKey("data")
            --     self.exchangeData = json.decode(data:getFormatBuffer())
            --     self.exchange_index = 1
            --     self:refreshTable3()
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("omni_exchange_lastcount"), http_request_method.GET, nil,"omni_exchange_lastcount")
        elseif sort == 5 then--常规兑换
            -- local function responseMethod(tag,gameData)
            --     local data = gameData:getNodeWithKey("data")
            --     self.exchangeData = json.decode(data:getFormatBuffer())
            --     self.exchange_index = 2
            --     self:refreshTable5()
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("normal_exchange_index"), http_request_method.GET, nil,"normal_exchange_index")
        end
    end
    -- self:refreshLabel()
end
--[[--
    初始化
]]
function game_server_active_show.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.selectIndex = 1
    self.m_current_Sort = 0
    self.showCfg = {}
    self.indexTable = {}
    local showCfg = getConfig(game_config_field.server_active_show)
    --取服务器数据来确定显示
    local serverShow = self.m_tGameData.show
    for i=1,game_util:getTableLen(serverShow) do
        local itemData = serverShow[tostring(i)]
        if itemData then
            local showFlag = itemData.flag
            if showFlag == 1 then
                local itemCfg = showCfg:getNodeWithKey(tostring(i))
                local itemItemCfg = json.decode(itemCfg:getFormatBuffer())
                itemItemCfg.id = i
                table.insert(self.showCfg,itemItemCfg)--存数据
            end
        end
    end
    if game_util:getTableLen(self.showCfg) > 0 then
        self.myIndex = self.showCfg[self.selectIndex].id
    end
    self.typeid = t_params.typeid or 1 ;

end



--[[--
    创建ui入口并初始化数据
]]
function game_server_active_show.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    if game_util:getTableLen(self.showCfg) > 0 then
        self:refreshUi();
    end
    return scene;
end

return game_server_active_show