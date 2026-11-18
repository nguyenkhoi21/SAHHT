---  神域商城

local game_godfield_shop = {
    m_tGameData = nil,
    m_moveFlag = nil,
    m_curPage = nil,
    m_list_view_bg = nil,
    m_num_label1 = nil,
    m_num_label2 = nil,
    integration = nil,
    god_integration = nil,
    m_openType = nil,
    m_zhengba_btn = nil,
    m_fenzheng_btn = nil,
    m_jingji_btn = nil,
};
--[[--
    销毁ui
]]
function game_godfield_shop.destroy(self)
    -- body
    cclog("-----------------game_godfield_shop destroy-----------------");
    --self.m_tGameData = nil;
    self.m_moveFlag = nil;
    self.m_curPage = nil;
    self.m_list_view_bg = nil;
    self.m_num_label1 = nil;
    self.m_num_label2 = nil;
    self.integration = nil;
    self.god_integration = nil;
    self.m_tGameData = nil;
    self.m_openType = nil;
    self.m_zhengba_btn = nil;
    self.m_fenzheng_btn = nil;
    self.m_jingji_btn = nil;
end
--[[--
    返回
]]
function game_godfield_shop.back(self,backType)
    if self.m_openType == "godfield_main" then
        local function responseMethod( tag,gameData )
             local data = gameData:getNodeWithKey("data");
                 data = json.decode(data:getFormatBuffer()) or {};
                 game_scene:enterGameUi("game_godfield_main",{gameData = gameData})
             end
         network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")
    elseif self.m_openType == "game_godfield_pvp_shop" then 
        local function responseMethod( tag,gameData )
            game_scene:enterGameUi("game_godfield_pvp",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_arena"), http_request_method.GET, {},"god_arena")
    elseif self.m_openType == "godfield_fenzheng" then 
        local function responseMethod( tag,gameData )
                game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
            end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, {},"team_pk_new_index")
    else
        local function responseMethod( tag,gameData )
            local data = gameData:getNodeWithKey("data");
            data = json.decode(data:getFormatBuffer()) or {};
            game_scene:enterGameUi("game_godfield_main",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")
    end
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_shop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog2(btnTag,"btnTag == ")
        -- cclog2(self.m_openType,"game_godfield_shop m_openType ===  ")
        if btnTag == 1 then
            self:back()
        elseif btnTag == 101 then
            -- local function responseMethod( tag,gameData )
            --     game_scene:enterGameUi("game_godfield_shop",{gameData = gameData,openType = "game_godfield_pvp"});
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_exchange_index"), http_request_method.GET, nil,"god_field_exchange_index")

        elseif btnTag == 102 then
            local function responseMethod( tag,gameData )
                game_scene:enterGameUi("game_godfield_pvp_shop",{gameData = gameData,openType = self.m_openType});  
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_arena_shop_index"), http_request_method.GET, params,"god_arena_shop_index")
        elseif btnTag == 103 then
            -- local function responseMethod( tag,gameData )
            --     game_scene:enterGameUi("game_team_pk_shop",{gameData = nil,openType = self.m_openType});
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_exchange_index"), http_request_method.GET, nil,"team_pk_exchange_index")
            game_util:addMoveTips({text = "Tạm thời chưa mở"});
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_godfield_shop.ccbi");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_num_label1 = ccbNode:labelTTFForName("m_num_label1")
    self.m_num_label2 = ccbNode:labelTTFForName("m_num_label2")
    self.m_zhengba_btn = ccbNode:controlButtonForName("m_zhengba_btn")
    self.m_fenzheng_btn = ccbNode:controlButtonForName("m_fenzheng_btn")
    self.m_jingji_btn = ccbNode:controlButtonForName("m_jingji_btn")
    self.m_jingji_btn:setColor(ccc3(100,100,100))
    self.m_fenzheng_btn:setColor(ccc3(100,100,100))
    self.m_zhengba_btn:setTouchEnabled(false)
    local touchBeginPoint = nil;
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self.m_moveFlag = false;
            touchBeginPoint = {x = x, y = y}
            return true;--intercept event
        elseif eventType == "moved" then
            if ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 then
                self.m_moveFlag = true;
            end
        end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建列表
]]
function game_godfield_shop.createTableView(self,viewSize)
    --local exchange_limit = self.m_tGameData.exchange_limit or {}
    local adventure_exchange_cfg = getConfig(game_config_field.god_field_exchange)
    local showData = {}
    local tempCount = adventure_exchange_cfg:getNodeCount()
    for i=1,tempCount do
        local itemCfg = adventure_exchange_cfg:getNodeAt(i-1)
        table.insert(showData,itemCfg:getKey())
    end
    table.sort(showData,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
    local itemsCount = #showData
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local function onMainBtnClick(target,event)
        if self.m_moveFlag == false and event == 32 then
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            local tempId = showData[btnTag + 1]
            local function responseMethod(tag,gameData)
                self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                local reward = self.m_tGameData.reward or {}
                game_util:rewardTipsByDataTable(reward)
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_exchange"), http_request_method.GET, {exchange_id = tempId},"god_field_exchange")
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    -- params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = totalItem;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_godfield_buy_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
            game_util:setCCControlButtonTitle(m_buy_btn,"Đổi")
            m_buy_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY+1);
        else
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
            m_buy_btn:setTag(index);
            if index < itemsCount then
                m_buy_btn:setVisible(true);
                m_spr_bg_up:setVisible(false);
                local m_node = ccbNode:nodeForName("m_node");
                m_node:removeAllChildrenWithCleanup(true);
                local m_cost_label = ccbNode:labelBMFontForName("m_cost_label")
                local m_name_label = ccbNode:labelTTFForName("m_name_label")
                local m_limit_label = ccbNode:labelBMFontForName("m_limit_label")
                local cd_node = ccbNode:nodeForName("cd_node")
                local m_cdTime = ccbNode:labelTTFForName("m_cdTime")
                local m_cost_icon_spr = ccbNode:spriteForName("m_cost_icon_spr")
                local tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("godfield_silver32.png")
                local tempSpriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("godfield_money32.png")
                local tempId = showData[index+1]

                local itemCfg = adventure_exchange_cfg:getNodeWithKey(tempId)
                local bought = self.m_tGameData["exchange_reward"][tostring(index+1)] or 0
                --cclog2(bought,"bought === ")
                local cost1 = itemCfg:getNodeWithKey("cost1"):toInt()
                local cost2 = itemCfg:getNodeWithKey("cost2"):toInt()

                local limits = itemCfg:getNodeWithKey("times"):toInt()
                local refreshType = itemCfg:getNodeWithKey("refresh"):toInt()
                local des = itemCfg:getNodeWithKey("des"):toStr()
                local reward = itemCfg:getNodeWithKey("reward")
                local haveTimes = math.max(0,limits-bought)
                --cclog2(haveTimes,"haveTimes ==")
                local rewardCount = reward:getNodeCount()
                if rewardCount > 0 then
                    m_name_label:setScale(0.8)
                    local icon,name,count = game_util:getRewardByItem(reward:getNodeAt(0));
                    if icon then
                        icon:setScale(0.9)
                        m_node:addChild(icon);
                    else
                        m_name_label:setString("");
                    end
                    if name then
                        if limits == -1 then
                            m_name_label:setString(name);
                        else
                            m_name_label:setString(name .. "(" .. haveTimes ..")")
                        end
                    else
                        m_name_label:setString("");
                    end
                    if count > 1 then
                        m_limit_label:setString("×" .. count)
                    else
                        -- if tempSpriteFrame then
                        --     m_cost_icon_spr:setScale(0.5)
                        --     m_cost_icon_spr:setDisplayFrame(tempSpriteFrame)
                        -- end
                        m_limit_label:setString("")
                    end
                else
                    m_name_label:setString("");
                end
                if cost1 ~= 0 then
                    m_cost_label:setString(tostring(cost1))
                    m_cost_icon_spr:setDisplayFrame(tempSpriteFrame2)
                else
                    m_cost_label:setString(tostring(cost2))
                    --m_cost_icon_spr:setScale(0.5)
                    m_cost_icon_spr:setDisplayFrame(tempSpriteFrame1)
                end
                if refreshType == 1 and haveTimes <= 0 and limits ~= -1 then
                    cd_node:setVisible(true)
                    m_cdTime:setString("Ngày mai tạo")
                    game_util:setCCControlButtonEnabled(m_buy_btn,false)
                elseif refreshType == 2 and haveTimes <= 0 and limits ~= -1 then
                    cd_node:setVisible(true)
                    m_cdTime:setString("Tuần sau tạo")
                    game_util:setCCControlButtonEnabled(m_buy_btn,false)
                elseif refreshType == 3 and haveTimes <= 0 and limits ~= -1 then
                    cd_node:setVisible(true)
                    m_cdTime:setString("Tháng sau tạo")
                    game_util:setCCControlButtonEnabled(m_buy_btn,false)
                else
                    cd_node:setVisible(false)
                    game_util:setCCControlButtonEnabled(m_buy_btn,true)
                end
            else
                local m_name_label = ccbNode:labelTTFForName("m_name_label")
                m_name_label:setString("");
                m_buy_btn:setVisible(false);
                m_spr_bg_up:setVisible(true);
            end
        else

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= itemsCount then return end;
        if eventType == "ended" and cell then
            local tempId = showData[index+1]
            local itemCfg = adventure_exchange_cfg:getNodeWithKey(tempId)
            local reward = itemCfg:getNodeWithKey("reward")
            local rewardCount = reward:getNodeCount()
            if rewardCount > 0 then
                game_util:lookItemDetal(json.decode(reward:getNodeAt(0):getFormatBuffer()))
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end

    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新
]]
function game_godfield_shop.refreshTableView(self)
     cclog("refreshTableView")
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tempTableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tempTableView);
end

--[[--
    刷新ui
]]
function game_godfield_shop.refreshUi(self)
    
    cclog("refreshUi")
    self:refreshTableView()
    local cur_score = self.m_tGameData.cur_score or 0
    local tempValue,_ = game_util:formatValueToString(cur_score,true)
    self.integration = self.m_tGameData.integration
    self.god_integration = self.m_tGameData.god_integration
    self.m_num_label1:setString(tostring(self.integration))
    self.m_num_label2:setString(tostring(self.god_integration))




    -- body
end
--[[--
    初始化
]]
function game_godfield_shop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
        -- self.integration = self.m_tGameData.integration
        -- self.god_integration = self.m_tGameData.god_integration

    end
    self.m_openType = t_params.openType or nil
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_shop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_godfield_shop;