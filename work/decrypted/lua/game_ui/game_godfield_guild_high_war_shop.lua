---  坠落之地
---  商城
local game_godfield_guild_high_war_shop = {
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
    m_node_top_diamond = nil,
    m_exchange_log_tab = nil,
};
--[[--
    销毁ui
]]
function game_godfield_guild_high_war_shop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_shop destroy-----------------");
    self.m_tGameData = nil;
    self.m_moveFlag = nil;
    self.m_curPage = nil;
    self.m_list_view_bg = nil;
    self.m_num_label1 = nil;
    self.m_num_label2 = nil;
    self.integration = nil;
    self.god_integration = nil;
    self.m_openType = nil;
    self.m_zhengba_btn = nil;
    self.m_fenzheng_btn = nil;
    self.m_jingji_btn = nil;
    self.m_node_top_diamond = nil;
    self.m_exchange_log_tab = nil;
end
--[[--
    返回
]]
function game_godfield_guild_high_war_shop.back(self,backType)

    local function endCallFunc()
        self:destroy();
    end
    local function responseMethod( tag,gameData )
        game_scene:enterGameUi("game_godfield_guild_high_war_map",{gameData = gameData, group_id = self.m_group_id, map_offset = self.m_map_offset},{endCallFunc = endCallFunc})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_map_index"), http_request_method.GET, {group_id = self.m_group_id},"guild_high_war_map_index")
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_shop.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/guild_high_war.plist");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");

    self.m_select_index = 1
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog2(self.m_openType,"game_godfield_guild_high_war_shop m_openType ===  ")
        if btnTag == 1 then
            self:back()
        elseif btnTag == 101 then
            if self.m_select_index ~= 1 then
                self.m_select_index = 1
                self:refreshUi()
            end
            -- if self.m_openType ~= nil then
            --     local function responseMethod( tag,gameData )
            --         game_scene:enterGameUi("game_godfield_shop",{gameData = gameData,openType = self.m_openType});
            --     end
            --     network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_exchange_index"), http_request_method.GET, nil,"god_field_exchange_index")
            -- end
        elseif btnTag == 102 then
            if self.m_step ~= 5 and self.m_step ~= 6 and self.m_step ~= 11 then
                return game_util:addMoveTips({text = "Chỉ được mở trong GĐ Thu Hoạch"})
            end
            if self.m_select_index ~= 2 then
                self.m_select_index = 2
                self:refreshUi()
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_shop.ccbi");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_num_label1 = ccbNode:labelTTFForName("m_num_label1")
    self.m_num_label2 = ccbNode:labelTTFForName("m_num_label2")
    self.m_pvp_exchange = ccbNode:nodeForName("m_pvp_exchange")
    self.m_node_top_diamond = ccbNode:nodeForName("m_node_top_diamond");
    self.pointlab = ccbNode:labelTTFForName("m_num_label3");
    -- self.m_zhengba_btn = ccbNode:controlButtonForName("m_zhengba_btn")
    self.m_btbh_btn = ccbNode:controlButtonForName("m_btbh_btn") -- 暴徒百货
    self.m_fssd_btn = ccbNode:controlButtonForName("m_fssd_btn") -- 丰收盛典
    -- self.m_zhengba_btn:setColor(ccc3(100,100,100))
    -- self.m_fenzheng_btn:setColor(ccc3(100,100,100))
    -- self.m_jingji_btn:setTouchEnabled(false)
    self.money_icon1 = ccbNode:spriteForName("money_icon1")
    self.m_num_label1 = ccbNode:labelTTFForName("m_num_label1")
    self.money_icon2 = ccbNode:spriteForName("money_icon2")
    self.m_num_label2 = ccbNode:labelTTFForName("m_num_label2")

    local itemCfg = getConfig(game_config_field.item)
    self.money_icon1:setOpacity(0)
    itemCfg = itemCfg:getNodeWithKey(9100986)
    local cost_icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr()) --self:createEquipIcon(itemCfg)
    cost_icon:setPosition(ccp(self.money_icon1:getContentSize().width/2, self.money_icon1:getContentSize().height/2))
    self.money_icon1:addChild(cost_icon)

    local tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_icon_gold2.png")
    self.money_icon2:setDisplayFrame(tempSpriteFrame1)

    self.m_node_top_diamond:setVisible(true)
    self.m_pvp_exchange:setVisible(false)
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
function game_godfield_guild_high_war_shop.createTableView(self,viewSize)
    --local exchange_limit = self.m_tGameData.exchange_limit or {}
    local guild_high_war_shop_cfg = getConfig(game_config_field.guild_high_war_shop)
    local _guild_high_war_shop_cfg = json.decode(guild_high_war_shop_cfg:getFormatBuffer()) or {};
    local showData = {}

    -- self.m_select_index = 1
    for k,v in pairs(_guild_high_war_shop_cfg) do
        local shop_cfg = guild_high_war_shop_cfg:getNodeWithKey(k)
        if self.m_select_index == 1 and v.show_time == -1 then
            table.insert(showData,{cfg = shop_cfg, id = k})
        elseif self.m_select_index == 2 and v.show_time == 1 then
            table.insert(showData,{cfg = shop_cfg, id = k})
        end
    end

    -- local tempCount = adventure_exchange_cfg:getNodeCount()
    -- for i=1,tempCount do
    --     local itemCfg = adventure_exchange_cfg:getNodeAt(i-1)
    --     table.insert(showData,itemCfg:getKey())
    -- end
    table.sort(showData,function(data1,data2) return tonumber(data1.id) < tonumber(data2.id) end)
    local itemsCount = #showData
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local function onMainBtnClick(target,event)
        if self.m_moveFlag == false and event == 32 then
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();

            local tempId = showData[btnTag + 1].id
            local cfg = showData[btnTag + 1].cfg
            local show_level = cfg:getNodeWithKey("show_level"):toInt()
            if show_level and not self.m_tGameData.goods[tostring(tempId)] then
                return game_util:addMoveTips({text = "Cấp KHKT"..show_level.."Mở khóa"})
            end

            local function responseMethod(tag,gameData)
                self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                local reward = self.m_tGameData.reward or {}
                game_util:rewardTipsByDataTable(reward)
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_buy"), http_request_method.GET, {goods_id = tempId},"guild_high_war_buy")
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
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
            local m_spr_bg = ccbNode:spriteForName("m_spr_bg")
            local spr_kj = ccbNode:spriteForName("spr_kj")
            m_spr_bg:setColor(ccc3(255,255,255))
            m_buy_btn:setColor(ccc3(255,255,255))
            m_buy_btn:setTag(index);
            if index < itemsCount then
                m_buy_btn:setVisible(true);
                m_spr_bg_up:setVisible(false);
                local m_node = ccbNode:nodeForName("m_node");
                m_node:removeAllChildrenWithCleanup(true);
                local m_cost_label = ccbNode:labelBMFontForName("m_cost_label")
                local m_name_label = ccbNode:labelTTFForName("m_name_label")
                local m_limit_label = ccbNode:labelBMFontForName("m_limit_label")
                m_limit_label:setAnchorPoint(ccp(0.5,0.5));

                m_limit_label:setPositionX(m_node:getPositionX())

                local cd_node = ccbNode:nodeForName("cd_node")
                local m_cdTime = ccbNode:labelTTFForName("m_cdTime")
                local m_cost_icon_spr = ccbNode:spriteForName("m_cost_icon_spr")
                local spr_xg = ccbNode:spriteForName("spr_xg")
                
                local m_kj_label = ccbNode:labelBMFontForName("m_kj_label")
                local tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_icon_gold2.png")
                m_cost_icon_spr:setScale(0.4)
                local data = showData[index+1]

                local itemCfg = data.cfg
                local cost1 = itemCfg:getNodeWithKey("need_value"):toInt()
                local buy_limit = json.decode(itemCfg:getNodeWithKey("buy_limit"):getFormatBuffer())
                if buy_limit[1] then
                    spr_xg:setVisible(true)
                    if buy_limit[1] == 1 then
                        game_util:setSpriteDisplayBySpriteFrameName(spr_xg, "xiangou_icon02.png")
                    else
                        game_util:setSpriteDisplayBySpriteFrameName(spr_xg, "xiangou_icon01.png")
                    end
                else
                    spr_xg:setVisible(false)
                end              

                local show_level = itemCfg:getNodeWithKey("show_level"):toInt()
                spr_kj:setVisible(show_level > 0)
                m_kj_label:setString(show_level)
                local buy_times = self.m_tGameData.goods[tostring(data.id)] or 0
                local cur_value = buy_limit[2] and buy_limit[2]-buy_times or 0
                local haveTimes = math.max(0,cur_value);

                local reward = itemCfg:getNodeWithKey("shop_reward")
                local rewardCount = reward:getNodeCount()
                if rewardCount > 0 then
                    local icon,name,count = game_util:getRewardByItem(reward:getNodeAt(0));
                    if icon then
                        icon:setScale(0.9)
                        m_node:addChild(icon);
                    end

                    if not self.m_tGameData.goods[tostring(data.id)] then
                        icon:setColor(ccc3(155,155,155))
                        local spr_lock = CCSprite:createWithSpriteFrameName("public_bigLock.png")
                        spr_lock:setScale(1)
                        m_node:addChild(spr_lock,11)
                        m_spr_bg:setColor(ccc3(155,155,155))
                        m_buy_btn:setColor(ccc3(155,155,155))
                    end
                    if name then
                        if #buy_limit == 0 then
                            m_name_label:setString(name);
                        else
                            m_name_label:setString(name .. "(" .. haveTimes ..")")
                        end
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
                end

                if cost1 ~= 0 then
                    m_cost_label:setString(tostring(cost1))
                    local need_sort = itemCfg:getNodeWithKey("need_sort"):toInt()
                    if need_sort == 1 then
                        local itemCfg = getConfig(game_config_field.item)
                        m_cost_icon_spr:removeAllChildrenWithCleanup(true)
                        m_cost_icon_spr:setOpacity(0)
                        itemCfg = itemCfg:getNodeWithKey(9100986)
                        local cost_icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr()) --self:createEquipIcon(itemCfg)
                        cost_icon:setPosition(ccp(m_cost_icon_spr:getContentSize().width/2, m_cost_icon_spr:getContentSize().height/2))
                        m_cost_icon_spr:addChild(cost_icon)
                    else
                        m_cost_icon_spr:removeAllChildrenWithCleanup(true)
                        m_cost_icon_spr:setOpacity(255)
                        m_cost_icon_spr:setDisplayFrame(tempSpriteFrame1)
                    end
                end
                -- if refreshType == 1 and haveTimes <= 0 and limits ~= -1 then
                --     cd_node:setVisible(true)
                --     m_cdTime:setString("明日刷新")
                --     game_util:setCCControlButtonEnabled(m_buy_btn,false)
                -- elseif refreshType == 2 and haveTimes <= 0 and limits ~= -1 then
                --     cd_node:setVisible(true)
                --     m_cdTime:setString("下周刷新")
                --     game_util:setCCControlButtonEnabled(m_buy_btn,false)
                -- elseif refreshType == 3 and haveTimes <= 0 and limits ~= -1 then
                --     cd_node:setVisible(true)
                --     m_cdTime:setString("下月刷新")
                --     game_util:setCCControlButtonEnabled(m_buy_btn,false)
                -- else
                    cd_node:setVisible(false)
                    game_util:setCCControlButtonEnabled(m_buy_btn,true)
                -- end
            else
                local m_name_label = ccbNode:labelTTFForName("m_name_label")
                m_name_label:setString("");

                m_buy_btn:setVisible(false);
                m_spr_bg_up:setVisible(true);
                spr_kj:setVisible(false)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= itemsCount then return end;
        if eventType == "ended" and cell then
            local data = showData[index+1]
            local itemCfg = data.cfg
            local reward = itemCfg:getNodeWithKey("shop_reward")
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
function game_godfield_guild_high_war_shop.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tempTableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tempTableView);
end

--[[--
    刷新ui
]]
function game_godfield_guild_high_war_shop.refreshUi(self)
    
    self:refreshTableView()

    self.m_num_label1:setString(game_data:getItemCountByCid(9100986))
    self.m_num_label2:setString(game_data:getUserStatusDataByKey("coin"))

    if self.m_select_index == 1 then
        self.m_btbh_btn:setColor(ccc3(255,255,255))
        self.m_fssd_btn:setColor(ccc3(100,100,100))
    else
        self.m_btbh_btn:setColor(ccc3(100,100,100))
        self.m_fssd_btn:setColor(ccc3(255,255,255))
    end
end
--[[--
    初始化
]]
function game_godfield_guild_high_war_shop.init(self,t_params)
    t_params = t_params or {};
    self.m_group_id = t_params.group_id
    self.m_map_offset = t_params.map_offset
    self.m_step = t_params.step
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
    end
    -- self.m_openType = t_params.openType or nil
    -- self.m_exchange_log_tab = self.m_tGameData["exchange_log"] or {};
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_guild_high_war_shop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_godfield_guild_high_war_shop;