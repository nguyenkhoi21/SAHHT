--星域竞技场   兑换商店
local game_godfield_pvp_new_shop = {
	m_root_layer = nil,
	m_btn_back = nil,
	callback = nil,

    ccbNode = nil,
    m_icon_huizhang = nil,
    m_huizhang_count = nil,
    m_list_node = nil,
    m_tGameData = nil,
    m_selectd_index = nil,
    m_enterType = nil,
} 

function game_godfield_pvp_new_shop:destroy( )
    cclog("  --------- game_godfield_pvp_new_shop destroy ------------  ")
	self.m_root_layer = nil;
	self.m_btn_back = nil;
	self.callback = nil;


    self.ccbNode = nil;
    self.m_icon_huizhang = nil;
    self.m_huizhang_count = nil;
    self.m_list_node = nil;
    self.m_tGameData = nil;
    self.m_selectd_index = nil;
    self.m_enterType = nil;
end



function game_godfield_pvp_new_shop:back()
	if self.callback then
		self.callback()
	end
	game_scene:removePopByName("game_godfield_pvp_new_shop")
end



function game_godfield_pvp_new_shop:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
        self.m_enterType = btnTag
        self:refreshUi()
	end
	local ccbNode =  luaCCBNode:create();
    self.ccbNode = ccbNode
	ccbNode:registerFunctionWithFuncName("onMainClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_godfield_Arena_new_shop.ccbi")

    for i=1,3 do
        ccbNode:controlButtonForName("m_select_btn" .. i):setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
        ccbNode:controlButtonForName("m_select_btn" .. i):setOpacity(0)
    end
    self.m_icon_huizhang = ccbNode:spriteForName("m_icon_huizhang")
    self.m_huizhang_count = ccbNode:labelTTFForName("m_huizhang_count")
	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_list_node = ccbNode:nodeForName("m_list_node")
    local m_back_layer = ccbNode:layerForName("m_back_layer")
    local function onTouch2(eventType, x, y)
        if eventType == "began" then
            local realPos = m_back_layer:getParent():convertToNodeSpace(ccp(x,y));
            if not m_back_layer:boundingBox():containsPoint(realPos) then
            	self:back()
                return false;
            end
            return true;

        elseif eventType == "ended" then
        end
    end
    m_back_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-5,true);
    m_back_layer:setTouchEnabled(true);
	return ccbNode
end


--[[--
    创建列表
]]
function game_godfield_pvp_new_shop.createTableView(self,viewSize)
    local showData = self:getShopDataByIndex(self.m_enterType)
    local buy_goods = self.m_tGameData.exchange_log[tostring(self.m_enterType)]
    table.sort(showData,function(data1,data2) return tonumber(data1.id) < tonumber(data2.id) end)
    local itemsCount = #showData
    local totalItem = math.max(itemsCount%4 == 0 and itemsCount or math.floor(itemsCount/4+1)*4,4)
    local function onMainBtnClick(target,event)
        if event == 32 then
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            local tempId = btnTag
            local function responseMethod(tag,gameData)
                self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                local reward = self.m_tGameData.reward or {}
                game_util:rewardTipsByDataTable(reward)
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_buy_goods"), http_request_method.GET, {team_id = self.m_enterType,goods_id = tempId},"universe_arena_buy_goods")
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6;
    params.totalItem = totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_godfield_Arena_new_shop_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local itemData = showData[index+1]
            cclog2(itemData,"itemData-=-------------")
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            ccbNode:setScale(0.9)
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
            local cd_node = ccbNode:nodeForName("cd_node")
            cd_node:setVisible(false)
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            if index < itemsCount then
                m_buy_btn:setTag(itemData.id);
                m_buy_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6);
                m_buy_btn:setVisible(true);
                m_spr_bg_up:setVisible(false);
                local icon,name,count = game_util:getRewardByItemTable(itemData.reward[1]);
                local m_node = ccbNode:nodeForName("m_node");
                local m_cdTime = ccbNode:labelTTFForName("m_cdTime")
                m_node:removeAllChildrenWithCleanup(true);
                if icon then
                    icon:setScale(0.9)
                    m_node:addChild(icon);
                end
                local m_cost_icon_spr = ccbNode:spriteForName("m_cost_icon_spr");
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring("pvp_shop_icon" .. self.m_enterType .. ".png"))
                if tempSpriteFrame then
                    m_cost_icon_spr:setDisplayFrame(tempSpriteFrame)
                    m_cost_icon_spr:setScale(0.6)
                end
                local m_cost_label = ccbNode:labelBMFontForName("m_cost_label")
                m_cost_label:setString(itemData["arena_" .. self.m_enterType])
                local m_limit_label = ccbNode:labelBMFontForName("m_limit_label")
                m_limit_label:setVisible(false)

                local times = itemData.times
                local buy_times = buy_goods[tostring(itemData.id)] and buy_goods[tostring(itemData.id)].times or 0
                local left_times = times - buy_times
                local refresh = itemData.refresh
                if times > 0 then
                    m_name_label:setString(name .. "(" .. left_times ..")")
                else
                    m_name_label:setString(name)
                end
                cclog("   goods_id  is  " .. itemData.id .. "  all  buy  times  is  " .. times .. "   buy times is  " .. buy_times .. "    left times is   " .. left_times .. "    refresh  is  " .. refresh )
                if times > 0 and buy_times > 0 and left_times < 1 and refresh ~= 0 then
                    cd_node:setVisible(true)
                    if refresh == 1 then
                        m_cdTime:setString("Tạo mới mỗi ngày")
                        game_util:setCCControlButtonEnabled(m_buy_btn,false)
                    elseif refresh == 2 then
                        m_cdTime:setString("Tạo mới tuần sau")
                        game_util:setCCControlButtonEnabled(m_buy_btn,false)
                    elseif refresh == 3 then
                        m_cdTime:setString("Tạo mới tháng sau")
                        game_util:setCCControlButtonEnabled(m_buy_btn,false)
                    end
                else
                    cd_node:setVisible(false)
                    game_util:setCCControlButtonEnabled(m_buy_btn,true)
                end

            else
                m_name_label:setString("");
                m_buy_btn:setVisible(false);
                m_spr_bg_up:setVisible(true);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= itemsCount then return end;
        if eventType == "ended" and cell then
            -- local tempData = showData[index+1]
            -- local itemCfg = adventure_exchange_cfg:getNodeWithKey(tempId)
            -- local reward = itemCfg:getNodeWithKey("shop_reward")
            -- local rewardCount = reward:getNodeCount()
            -- if rewardCount > 0 then
            --     game_util:lookItemDetal(tempData.reward[1])
            -- end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end

    -- return TableViewHelper:createGallery2(params);
    return TableViewHelper:create(params);
end

function game_godfield_pvp_new_shop:getShopDataByIndex(index)
    local universe_arena_shop = getConfig(game_config_field.universe_arena_shop)
    universe_arena_shop = json.decode(universe_arena_shop:getFormatBuffer())
    local tempTab = {}
    for k,v in pairs(universe_arena_shop) do
        if v["arena_" .. index] and v["arena_" .. index] ~= 0 then
            v.id = k
            tempTab[#tempTab+1] = v
        end
    end
    return tempTab
end


function game_godfield_pvp_new_shop:refreshBtn(index)
    self.m_selectd_index = index
    local filesName = {"pvp_shop_pier","pvp_shop_wuerlun","pvp_shop_hatuomo"}
    for i=1,3 do
        local tempSp = self.ccbNode:spriteForName("m_select_sp" .. i)
        local fileName = filesName[i]
        local m_select_btn = self.ccbNode:controlButtonForName("m_select_btn" .. i)
        if i == index then
            fileName = fileName .. "2"
            m_select_btn:setTouchEnabled(false)
        else
            fileName = fileName .. "1"
            m_select_btn:setTouchEnabled(true)
        end
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName .. ".png"))
        if tempSpriteFrame then
            tempSp:setDisplayFrame(tempSpriteFrame)
        end
    end
end



function game_godfield_pvp_new_shop:refreshUi()
    self:refreshBtn(self.m_enterType)
    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring("pvp_shop_icon" .. self.m_enterType .. ".png"))
    if tempSpriteFrame then
        self.m_icon_huizhang:setDisplayFrame(tempSpriteFrame)
    end
    self.m_huizhang_count:setString(self.m_tGameData.grade_score[tostring(self.m_enterType)])
	self.m_list_node:removeAllChildrenWithCleanup(true)
	local tempTab = self:createTableView(self.m_list_node:getContentSize())
	if tempTab then
		self.m_list_node:addChild(tempTab)
	end
end


function game_godfield_pvp_new_shop:init(t_params)

	t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        cclog2(self.m_tGameData,"  game_godfield_pvp_new_shop   ")
    else
        self.m_tGameData = {};
    end

    self.m_enterType = t_params.enterType or 1

end



function game_godfield_pvp_new_shop:create(t_params)
	local scene = CCScene:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end


return game_godfield_pvp_new_shop
