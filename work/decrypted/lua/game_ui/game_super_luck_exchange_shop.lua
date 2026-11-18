-- 大富翁兑换商店
-- Author: fan.xia
-- Date: 2019-04-01 14:24:43
--

local game_super_luck_exchange_shop = {
	m_root_layer = nil,
    m_ccbNode = nil,
    m_list_view = nil,
    m_tGameData = nil,
    m_lb_cost1 = nil,
    m_lb_gold = nil,
    m_yuzhou = nil,
    m_curzuanshiPage = nil,
}

--[[--
    销毁
]]
function game_super_luck_exchange_shop.destroy(self)
    -- body
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_list_view = nil;
    self.m_tGameData = nil;
    self.m_lb_cost1 = nil;
    self.m_lb_gold = nil;
    self.m_yuzhou = nil;
    self.m_curzuanshiPage = nil;
end

function game_super_luck_exchange_shop.back(self,type)
    --回到activity
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = nil},{endCallFunc = function (  )
                self:destroy();
            end});
end

function game_super_luck_exchange_shop.createUi(self)
   local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 2 then
            local params = {}
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_shot_shop_index"), http_request_method.GET, params,"god_shot_shop_index")
        elseif btnTag == 3 then
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_super_luck_exchange_shop.ccbi");

    self.m_ccbNode = ccbNode

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
   	self.m_list_view = ccbNode:layerForName("m_list_view")
    self.m_lb_gold = ccbNode:labelTTFForName("m_lb_gold")
    self.m_lb_cost1 = ccbNode:labelTTFForName("m_lb_cost1")
    self.m_lb_coin = ccbNode:labelTTFForName("m_lb_coin")
    
    return ccbNode
end

--[[--
    创建列表
]]
function game_super_luck_exchange_shop.createTableView(self,viewSize)    
	local userStatusData = game_data:getUserStatusData()
	
    local shop_data = {}
    local value,unit = game_util:formatValueToString(userStatusData.coin)
    local alue,nit = game_util:formatValueToString(userStatusData.universe_coin)

    local itemsData = game_data:getItemsData()
    local saizi_count = 0
    local gold_count = 0
    for k,v in pairs(itemsData) do
        if k == "511907" then
            for k,v in pairs(v) do
                saizi_count = saizi_count + v
            end
        end

        if k == "511906" then
            for l,g in pairs(v) do
                gold_count = gold_count + g
            end
        end
    end

    local value2,unit2 = game_util:formatValueToString(saizi_count)
    local value3,unit3 = game_util:formatValueToString(gold_count)

    self.m_lb_coin:setString(value..unit) 
    self.m_lb_gold:setString(value2..unit2) 
    self.m_lb_cost1:setString(value3..unit3) 

    for k,v in pairs(self.m_data.record) do
        if type(v)=="table" and v.reward then
            shop_data[#shop_data+1] = {cig = v,id = tonumber(k)}
        end
    end
  
    local itemsCount = #shop_data
    local function onCellBtnClick(target,event)

        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local Id = tostring(btnTag)
        function responseMethod( tag,gameData )
            local reward = gameData:getNodeWithKey("data"):getNodeWithKey("reward")
            local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
            --cclog2(data,"data")
            self.m_data = data

            self:refreshUi()

            game_util:rewardTipsByJsonData(reward);
        end

        local params = {}
        params.good_id = btnTag
        params.sort = 1
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_luck_shop_exchange"), http_request_method.GET, params,"super_luck_shop_exchange")
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = itemsCount;
    --params.showPoint = false
    params.showPageIndex = self.m_curzuanshiPage or 1
    params.touchPriority = GLOBAL_TOUCH_PRIORITY + 2
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_limit_shop_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_buy_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY+2);

        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_cost_icon_spr = ccbNode:spriteForName("m_cost_icon_spr");
            local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn");
            local m_title_label = ccbNode:labelBMFontForName("m_title_label")
            local m_cost_label = ccbNode:labelBMFontForName("m_cost_label")
            local m_buy_flag = ccbNode:labelBMFontForName("m_buy_flag")
            local m_num_label = ccbNode:labelBMFontForName("m_num_label")
            local m_imgNode = ccbNode:nodeForName("m_imgNode")
            local cd_node = ccbNode:nodeForName("cd_node")
            local m_info_node = ccbNode:nodeForName("m_info_node")
            local m_cdTime = ccbNode:labelTTFForName("m_cdTime")
            cd_node:setVisible(false)
            m_cdTime:setString("次日刷新")
            
            if index < itemsCount then
                local shop_cfg = shop_data[index+1]["cig"]
                local shopId = shop_data[index+1].id
                m_buy_btn:setTag(shopId);

                m_cost_icon_spr:setVisible(false)
                local item_node = m_info_node:getChildByTag(9999)
                if item_node then
                    item_node:removeFromParentAndCleanup(true)
                end

                if shop_cfg.need_sort == 2 then
                    local icon,name,count = game_util:getRewardByItemTable(shop_cfg["need_item"][1])
                    if icon then
                        icon:setPosition(m_cost_icon_spr:getPosition())
                        icon:setScale(0.35)
                        m_info_node:addChild(icon,1,9999) 
                    end
                    m_cost_icon_spr:setVisible(false)
                    --价格
                    m_cost_label:setString(count)
                   
                elseif shop_cfg.need_sort == 1 then
                    --钻石
                    --价格
                    local item_node = m_info_node:getChildByTag(9999)
                    if item_node then
                        item_node:removeFromParentAndCleanup(true)
                    end
                    m_cost_icon_spr:setVisible(true)
                    m_cost_label:setString(shop_cfg.need_value)
                end

                local icon,name,count = game_util:getRewardByItemTable(shop_cfg["reward"][1]);
                if icon then
                    icon:setScale(0.8)
                    m_imgNode:addChild(icon);
                    icon:setPosition(ccp(0,0))
                end
                if count then
                    m_num_label:setString("X"..count);
                end

                --刷新时间
                if shop_cfg.cur_num >= shop_cfg.sell_max then
                    if shop_cfg.sell_sort == 1 then --每日刷新
                        cd_node:setVisible(true)
                        m_buy_btn:setEnabled(false)
                    else
                        m_buy_btn:setEnabled(false)
                    end
                else
                    m_buy_btn:setEnabled(true)
                end

                local yud_num = shop_cfg.sell_max - shop_cfg.cur_num
                --库存
                m_title_label:setString("库存"..yud_num.."/"..shop_cfg.sell_max)

            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local shop_cfg = shop_data[index+1]["cig"]
            local shop_reward_item = shop_cfg["reward"][1]
          
            local tempType = shop_reward_item[1]
            if tempType == 6 then--道具
                local itemId = shop_reward_item[2]
                game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
            elseif tempType == 7 then--装备
                local equipId = shop_reward_item[2]
                local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
            elseif tempType == 5 then--卡牌
                local cId = shop_reward_item[2]
                game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
            else
                game_scene:addPop("game_food_info_pop",{itemData = shop_reward_item})
            end
        end
        
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curzuanshiPage = curPage or 1
    end
    return TableViewHelper:createGallery2(params);
end

function game_super_luck_exchange_shop.refreshUi(self)
    self.m_list_view:removeAllChildrenWithCleanup(true)
	local viewSize = self.m_list_view:getContentSize()
    local node = self:createTableView(viewSize)
    self.m_list_view:addChild(node)
end

function game_super_luck_exchange_shop.init(self,t_params)
    self.m_data = t_params.gameData
    --self.m_tGameData = json.decode(getConfig(game_config_field.shot_shop):getFormatBuffer())

    cclog2(self.m_data,"m_data")
end

--[[--
    创建ui入口并初始化数据
]]--
function game_super_luck_exchange_shop.create(self,t_params)
   cclog("----- game_super_luck_exchange_shop create --------")
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();

    return rootScene
end

return game_super_luck_exchange_shop