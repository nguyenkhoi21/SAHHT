--
-- Author: fan.xia
-- Date: 2019-04-01 14:24:43
--

local game_shooting_shop = {
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
function game_shooting_shop.destroy(self)
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

function game_shooting_shop.back(self,type)
    --回到activity
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = nil},{endCallFunc = function (  )
                self:destroy();
            end});
end

function game_shooting_shop.createUi(self)
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
    ccbNode:openCCBFile("ccb/ui_shooting_shop.ccbi");

    self.m_ccbNode = ccbNode

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
   	self.m_list_view = ccbNode:layerForName("m_list_view")
    self.m_lb_gold = ccbNode:labelTTFForName("m_lb_gold")
    self.m_lb_cost1 = ccbNode:labelTTFForName("m_lb_cost1")
    self.m_yuzhou = ccbNode:spriteForName("m_yuzhou")
    local temp = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_icon_ybi.png")
    if temp then
        self.m_yuzhou:setDisplayFrame(temp)
    end
  
    return ccbNode
end

--[[--
    创建列表
]]
function game_shooting_shop.createTableView(self,viewSize)    
	local userStatusData = game_data:getUserStatusData()
	local level = userStatusData.level
    local shopCfg = self.m_tGameData
    local shop_data = {}
    local value,unit = game_util:formatValueToString(userStatusData.coin)
    local alue,nit = game_util:formatValueToString(userStatusData.universe_coin)

    self.m_lb_gold:setString(value..unit) 
    self.m_lb_cost1:setString(alue..nit) 
    
    for k,v in pairs(shopCfg) do
    	if level>=v.show_level[1] and level<=v.show_level[2] then
    		--等级限制
    		shop_data[#shop_data+1] = {cig = v ,id = k}
    		
    	end
    end
    cclog2(shop_data,"shop_data")
    local itemsCount = #shop_data
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local function onCellBtnClick(target,event)

        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local Id = tostring(btnTag)
        function responseMethod( tag,gameData )
            local reward = gameData:getNodeWithKey("data"):getNodeWithKey("reward")
            local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
            self.m_data = data["index"][2]

            self:refreshUi()

            game_util:rewardTipsByJsonData(reward);
        end

        local params = {}
        params.goods_id = btnTag
        params.count = 1
        cclog2(params,"params")
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_shot_shop_exchange"), http_request_method.GET, params,"god_shot_shop_exchange")
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
            local sold_out_node = ccbNode:nodeForName("sold_out_node")
            local sold_out_text = ccbNode:labelTTFForName("sold_out_text")
            sold_out_text:setString("Đã bán hết")
            sold_out_node:setVisible(false)

            
            if index < itemsCount then
                local shop_cfg = shop_data[index+1]["cig"]
                local shopId = shop_data[index+1].id
                m_buy_btn:setTag(shopId);

                local icon,name,count = game_util:getRewardByItemTable(shop_cfg["shop_reward"][1]);
                if icon then
                    icon:setScale(0.8)
                    m_imgNode:addChild(icon);
                    icon:setPosition(ccp(0,0))
                end
                if count then
                    m_num_label:setString(count);
                end

                local payCout = 0
                if self.m_data["show"][shopId] then
                    payCout = shop_cfg.sell_max - self.m_data["show"][shopId]
                else
                    payCout = 0
                end

                if self.m_data["show"][shopId] <= 0 and shop_cfg["sell_sort"] == 1 then
                    sold_out_node:setVisible(true)
                    m_buy_btn:setEnabled(false)
                else
                    m_buy_btn:setEnabled(true)
                    sold_out_node:setVisible(false)
                end
               
                if shop_cfg.need_sort == 2 then
                    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_icon_ybi.png")
                    if tempSpriteFrame then
                        m_cost_icon_spr:setDisplayFrame(tempSpriteFrame)
                    end

                    --价格
                    local count_pay = #(shop_cfg.need_price)
                    

                    if payCout >= count_pay then
                        cclog(count_pay,"count_pay")
                        m_cost_label:setString(shop_cfg.need_price[count_pay])
                    else
                        m_cost_label:setString(shop_cfg.need_price[payCout+1])
                    end
                elseif shop_cfg.need_sort == 1 then
                    --钻石
                    --价格
                    local count_pay = #(shop_cfg.need_value)

                    if payCout >= count_pay then

                        m_cost_label:setString(shop_cfg.need_value[count_pay])
                    else
                        m_cost_label:setString(shop_cfg.need_value[payCout+1])
                    end
                    
                end

                --库存
                local kuc = 0
                if self.m_data["show"][shopId] then
                    kuc = self.m_data["show"][shopId]
                else
                    kuc = shop_cfg.sell_max
                end
                m_title_label:setString("Kho"..kuc.."/"..shop_cfg.sell_max)

            else
                m_buy_btn:setVisible(false);
               
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local shop_cfg = shop_data[index+1]["cig"]
            local tempId = shop_data[index+1].id
            local shop_reward_item = shop_cfg["shop_reward"][1]
            local buy_max_count = shop_cfg.sell_max
    
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

function game_shooting_shop.refreshUi(self)
    self.m_list_view:removeAllChildrenWithCleanup(true)
	local viewSize = self.m_list_view:getContentSize()
    local node = self:createTableView(viewSize)
    self.m_list_view:addChild(node)
end

function game_shooting_shop.init(self,t_params)
    self.m_data = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
    self.m_tGameData = json.decode(getConfig(game_config_field.shot_shop):getFormatBuffer())

    cclog2(self.m_data,"self.m_data")
end

--[[--
    创建ui入口并初始化数据
]]--
function game_shooting_shop.create(self,t_params)
   cclog("----- game_shooting_shop create --------")
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();

    return rootScene
end

return game_shooting_shop