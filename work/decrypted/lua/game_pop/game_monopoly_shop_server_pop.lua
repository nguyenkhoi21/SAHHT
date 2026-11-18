

local game_monopoly_shop_server_pop = {
    m_tGameData = nil,
    m_curPage = nil,
    m_list_node = nil,
    m_num_lab = nil,
};
--[[--
    销毁ui
]]
function game_monopoly_shop_server_pop.destroy(self)
    -- body
    cclog("-----------------game_monopoly_shop_server_pop destroy-----------------");
    --self.m_tGameData = nil;
    self.m_curPage = nil;
    self.m_list_node = nil;
    self.m_tGameData = nil;
    self.m_num_lab = nil;
end
--[[--
    返回
]]
function game_monopoly_shop_server_pop.back(self,backType)
    local function responseMethod(tag,gameData)
        game_scene:addPop("game_monopoly_server_pop",{gameData = gameData,screenShoot = screenShoot});
        game_scene:removePopByName("game_monopoly_shop_server_pop")
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_super_tycoon_active_index"), http_request_method.GET, nil,"server_super_tycoon_active_index")
end
--[[--
    读取ccbi创建ui
]]
function game_monopoly_shop_server_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 201 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_monopoly_pop.ccbi");
    self.m_list_node = ccbNode:nodeForName("m_list_node")
    -- local m_icon_sp = ccbNode:spriteForName("m_icon_sp")
    --  -- CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(imgName1));
    -- local icon_sp = CCSprite:create("icon/" .. self.m_richman_plot["1"].item_icon .. ".png");
    -- local x,y = m_icon_sp:getPosition()
    -- icon_sp:setScale(0.5)
    -- icon_sp:setPosition(ccp(x,y))
    -- m_icon_sp:getParent():addChild(icon_sp)
    -- m_icon_sp:setVisible(false)
    local touchBeginPoint = nil;
    local function onTouch(eventType, x, y)
        if eventType == "began" then
             return true;
         elseif eventType == "ended" then
         end
    end
    local btn_back = ccbNode:controlButtonForName("btn_back")
    btn_back:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_num_lab = ccbNode:labelTTFForName("m_num_lab")
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-2,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建列表
]]
function game_monopoly_shop_server_pop.createTableView(self,viewSize)
    -- local exchange_limit = self.m_tGameData.bought_goods or {}
    local adventure_exchange_cfg = getConfig(game_config_field.server_richman_shop)
    local showData = {}
    local m_id_table = {}
    local tempCount = adventure_exchange_cfg:getNodeCount()
    for i=1,tempCount do
        local itemCfg = adventure_exchange_cfg:getNodeAt(i-1)
        if itemCfg:getNodeWithKey("value_sorts"):toInt() == 1 then
            table.insert(showData,itemCfg:getKey())
            table.insert(m_id_table,i)
        end
    end
    -- cclog2(m_id_table,"m_id_table === ")
    table.sort(showData,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
    local itemsCount = #showData
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local tempId = showData[btnTag + 1]
        local function responseMethod(tag,gameData)
            self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
            local reward = self.m_tGameData.rewards or {}
            game_util:rewardTipsByDataTable(reward)
            self:refreshUi()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_super_tycoon_active_buy"), http_request_method.GET, {shop_type = 1,goods_id = tempId},"server_super_tycoon_active_buy")
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    -- params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = totalItem;
    params.showPageIndex = self.m_curPage;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2
    local itemSize = CCSizeMake(viewSize.width/params.column-5,viewSize.height/params.row+10);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_monopoly_buy_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5-5));
            cell:addChild(ccbNode,10,10);
            local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
            m_buy_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
            local m_duihuan_sp = ccbNode:spriteForName("m_duihuan_sp")
            local m_cost_icon_spr = ccbNode:spriteForName("m_cost_icon_spr")
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            local icon_sp = CCSprite:create("icon/" .. self.m_richman_plot["1"].item_icon .. ".png");
            local x,y = m_cost_icon_spr:getPosition()
            icon_sp:setScale(0.5)
            icon_sp:setPosition(ccp(x,y))
            m_cost_icon_spr:getParent():addChild(icon_sp)
            m_cost_icon_spr:setVisible(false)
            if index < itemsCount then
                m_buy_btn:setVisible(true);
                m_buy_btn:setTag(index);
                m_spr_bg_up:setVisible(false);
                m_duihuan_sp:setVisible(true)
                local m_node = ccbNode:nodeForName("m_node");
                m_node:removeAllChildrenWithCleanup(true);
                local m_cost_label = ccbNode:labelBMFontForName("m_cost_label")
                local m_limit_label = ccbNode:labelBMFontForName("m_limit_label")
                local cd_node = ccbNode:nodeForName("cd_node")

                local m_cdTime = ccbNode:labelTTFForName("m_cdTime")
                local tempId = showData[index+1]
                local itemCfg = adventure_exchange_cfg:getNodeWithKey(tempId)
                local limits = itemCfg:getNodeWithKey("sell_max"):toInt()
                local bought = self.m_tGameData.bought_goods[tostring(m_id_table[index+1])] or 0
                local refreshType = itemCfg:getNodeWithKey("value_sorts"):toInt()
                local reward = itemCfg:getNodeWithKey("shop_reward")
                local costValue = itemCfg:getNodeWithKey("need_value"):toInt()

                m_cost_label:setString(tostring(costValue))
                local haveTimes = math.max(0,limits-bought)
                local rewardCount = reward:getNodeCount()
                if rewardCount > 0 then
                    local icon,name,count = game_util:getRewardByItem(reward:getNodeAt(0));
                    if icon then
                        icon:setScale(0.9)
                        m_node:addChild(icon);
                    end
                    if name then
                        if limits == -1 then
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
                if refreshType == 1 and haveTimes <= 0 and limits ~= -1 then
                    cd_node:setVisible(true)
                    m_cdTime:setString("Mai tạo mới")
                    -- game_util:setCCControlButtonEnabled(m_buy_btn,false)
                elseif refreshType == 2 and haveTimes <= 0 and limits ~= -1 then
                    cd_node:setVisible(true)
                    m_cdTime:setString("Tuần sau tạo mới")
                    -- game_util:setCCControlButtonEnabled(m_buy_btn,false)
                elseif refreshType == 3 and haveTimes <= 0 and limits ~= -1 then
                    cd_node:setVisible(true)
                    m_cdTime:setString("Tháng sau tạo mới")
                    -- game_util:setCCControlButtonEnabled(m_buy_btn,false)
                else
                    cd_node:setVisible(false)
                    -- game_util:setCCControlButtonEnabled(m_buy_btn,true)
                end
            else
                m_buy_btn:setVisible(false);
                m_duihuan_sp:setVisible(false)
                m_spr_bg_up:setVisible(true);
                icon_sp:setVisible(false)
                m_name_label:setString("");
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= itemsCount then return end;
        if eventType == "ended" and cell then
            local tempId = showData[index+1]
            local itemCfg = adventure_exchange_cfg:getNodeWithKey(tempId)
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
function game_monopoly_shop_server_pop.refreshTableView(self)
    self.m_list_node:removeAllChildrenWithCleanup(true);
    local tempTableView = self:createTableView(self.m_list_node:getContentSize());
    self.m_list_node:addChild(tempTableView);
end

--[[--
    刷新ui
]]
function game_monopoly_shop_server_pop.refreshUi(self)
    self:refreshTableView()
    self.m_num_lab:setString("HC hiện còn:" .. tostring(self.m_tGameData.medal))
end
--[[--
    初始化
]]
function game_monopoly_shop_server_pop.init(self,t_params)
    self.m_richman_plot = json.decode(getConfig(game_config_field.server_richman_plot):getFormatBuffer())
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
    elseif t_params.gameData ~= nil and tolua.type(t_params.gameData) == "table" then
        self.m_tGameData = t_params.gameData
    end
    self.m_openType = t_params.openType or nil
end

--[[--
    创建ui入口并初始化数据
]]
function game_monopoly_shop_server_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_monopoly_shop_server_pop;