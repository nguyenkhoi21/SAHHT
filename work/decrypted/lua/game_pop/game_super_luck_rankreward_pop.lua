---  大富翁排名奖励

local game_super_luck_rankreward_pop = {
    m_popUi = nil,
    m_version = nil,
    m_data = nil,
    m_list_node = nil,
    m_tableView2 = nil,

};
--[[--
    销毁ui
]]
function game_super_luck_rankreward_pop.destroy(self)
    -- body
    self.m_version = nil;
    self.m_popUi = nil;
    self.m_data = nil;
    self.m_list_node = nil;
    self.m_tableView2 = nil;
end
--[[--
    返回
]]
function game_super_luck_rankreward_pop.back(self,backType)
   
    game_scene:removePopByName("game_super_luck_rankreward_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_super_luck_rankreward_pop.createUi(self)
    local editText = "";
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回      
            self:back();    
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_super_luck_rankrewad.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 13);
    self.m_list_node = ccbNode:layerForName("m_list_layer")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end

    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-13,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

function game_super_luck_rankreward_pop.createTableView(self, viewSize)
    local sl_limit_time_shop = getConfig( game_config_field.sl_rank_reward )
    local limite_cig = json.decode(sl_limit_time_shop:getFormatBuffer())

    local showData = {}
    for k,v in pairs(limite_cig) do
        if v.version == self.m_version then
            showData[#showData+1] = {data = v,id = tonumber(k)}
        end
    end

    table.sort(showData,function (a, b)
        return a.id<b.id
    end)
  
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
        local params = {}
        params.sort = 2
        params.good_id = btnTag
        local function responseMethod(tag,gameData)
            local reward = gameData:getNodeWithKey("data"):getNodeWithKey("reward")
            game_util:rewardTipsByJsonData(reward)
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_luck_shop_exchange"), http_request_method.GET, params,"super_luck_shop_exchange")
    end

    local cardsCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = cardsCount -- totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-13
    
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
            ccbNode:openCCBFile("ccb/ui_super_luck_rankrewad_item.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);

        end
        if cell and index < cardsCount then
            local limit_tab = showData[index+1]["data"]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            
            local m_rank_label = ccbNode:labelTTFForName("m_rank_label")
            local m_list_node = ccbNode:nodeForName("m_list_node")

            self.m_tableView2 = nil
            m_list_node:removeAllChildrenWithCleanup(true)
            self.m_tableView2 = self:createTableView2(limit_tab.reward,m_list_node:getContentSize())
            m_list_node:addChild(self.m_tableView2)
            
            m_rank_label:setString("Hạng "..limit_tab.rank)

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" then
            
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
       -- self.m_curPage = curPage;
    end
    local tableView = TableViewHelper:create(params);
    return tableView
end

function game_super_luck_rankreward_pop.createTableView2(self, data, viewSize)
    
    local cardsCount = #data
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 5; --列
    params.totalItem = cardsCount -- totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionHorizontal;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-13
    
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            
        end
        if cell then
            local icon,name,count = game_util:getRewardByItemTable(data[index+1])
            icon:setScale(0.6)
            local label = CCLabelTTF:create(tostring(count),TYPE_FACE_TABLE.Arial_BoldMT,12)
            label:setPosition(ccp(45,5))
            icon:addChild(label,999)
            icon:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            cell:addChild(icon)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" then
           
           local info1 = data[index+1]
            if #info1 > 1 then
                local tempType = info1[1]
                if tempType == 6 then--道具
                    local itemId = info1[2]
                    game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
                elseif tempType == 7 then--装备
                    local equipId = info[2]
                    local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                    game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
                elseif tempType == 5 then--卡牌
                    local cId = info1[2]
                    game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
                else                   -- 食品
                    game_scene:addPop("game_food_info_pop",{itemData = info1})
                end
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
       -- self.m_curPage = curPage;
    end
    local tableView = TableViewHelper:create(params);
    return tableView
end

--[[--
    刷新ui
]]
function game_super_luck_rankreward_pop.refreshUi(self)
    self.m_tableView2 = nil
    self.m_list_node:removeAllChildrenWithCleanup(true)
    self.m_tableView2 = self:createTableView(self.m_list_node:getContentSize())
    self.m_list_node:addChild(self.m_tableView2)
end
--[[--
    初始化
]]
function game_super_luck_rankreward_pop.init(self,t_params)
    self.m_version = t_params.version or {};
   --cclog2(data,"data")
end

--[[--
    创建ui入口并初始化数据
]]
function game_super_luck_rankreward_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_super_luck_rankreward_pop;