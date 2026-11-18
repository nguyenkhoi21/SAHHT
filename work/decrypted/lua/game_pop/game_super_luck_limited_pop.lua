---  大富翁限时商店

local game_super_luck_limited_pop = {
    m_popUi = nil,
    m_version = nil,
    m_data = nil,

};
--[[--
    销毁ui
]]
function game_super_luck_limited_pop.destroy(self)
    -- body
    self.m_version = nil;
    self.m_popUi = nil;
    self.m_data = nil;
end
--[[--
    返回
]]
function game_super_luck_limited_pop.back(self,backType)
    game_scene:removePopByName("game_super_luck_limited_pop")
end
--[[--
    读取ccbi创建ui
]]
function game_super_luck_limited_pop.createUi(self)
    local editText = "";
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        game_util:closeAlertView();
                        self:back();
                    end,   --可缺省
                    closeCallBack = function(target,event)
                        game_util:closeAlertView();
                    end,
                    okBtnText = "Xác định",       --可缺省
                    text = "Đóng sẽ mất đi cơ hội mua hàng lần này, xác nhận Đóng?",      --可缺省
                }
                game_util:openAlertView(t_params);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_super_luck_limited_shop.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 13);
    self.m_list_node = ccbNode:nodeForName("m_list_node")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end

    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-13,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

function game_super_luck_limited_pop.createTableView(self, viewSize)
    local showData = {}
    for k,v in pairs(self.m_data["record"]) do
        if v.reward then
            local id = tonumber(k)
            showData[#showData+1] = {data = v,id = id}
        end
    end

    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
        local params = {}
        params.sort = 2
        params.good_id = btnTag
        local function responseMethod(tag,gameData)
            local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
            local reward = gameData:getNodeWithKey("data"):getNodeWithKey("reward")
            self.m_data = data
            game_util:rewardTipsByJsonData(reward)
            self:refreshUi()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_luck_shop_exchange"), http_request_method.GET, params,"super_luck_shop_exchange")
    end

    local cardsCount = 4
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 2; --列
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
            ccbNode:openCCBFile("ccb/ui_super_luck_limited_item.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell and index < cardsCount then
            local limit_tab = showData[index+1]["data"]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_item_node = ccbNode:nodeForName("m_item_node")
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            local m_price_label = ccbNode:labelTTFForName("m_price_label")
            local m_price2_label = ccbNode:labelTTFForName("m_price2_label")
            local m_pay_btn = ccbNode:controlButtonForName("m_pay_btn")
            m_pay_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 13)
            m_pay_btn:setTag(showData[index+1]["id"])

            local icon,name,count = game_util:getRewardByItemTable(limit_tab["reward"][1])
            local size = m_item_node:getContentSize()
            icon:setPosition(ccp(size.width*0.5,size.height*0.5))
            icon:setScale(0.7)
            m_item_node:addChild(icon)

            local label_temp = CCLabelTTF:create(tostring("x"..count),TYPE_FACE_TABLE.Arial_BoldMT,10)
            label_temp:setPosition(ccp(size.width-10,6))
            m_item_node:addChild(label_temp,2)

            local yud_num = limit_tab["sell_max"] - limit_tab["cur_num"]
            m_name_label:setString(name.."("..yud_num.."/"..limit_tab["sell_max"]..")")
            m_price_label:setString(limit_tab["original_price"])
            m_price2_label:setString(limit_tab["price"])
            
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" then
            local shop_reward_item = showData[index+1]["data"]["reward"][1]
            if shop_reward_item then
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
function game_super_luck_limited_pop.refreshUi(self)
    self.m_tableView2 = nil
    self.m_list_node:removeAllChildrenWithCleanup(true)
    self.m_tableView2 = self:createTableView(self.m_list_node:getContentSize())
    self.m_list_node:addChild(self.m_tableView2)
end
--[[--
    初始化
]]
function game_super_luck_limited_pop.init(self,t_params)
    local data = t_params.gameData or {};
    self.m_data = data
   --cclog2(data,"data")
end

--[[--
    创建ui入口并初始化数据
]]
function game_super_luck_limited_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_super_luck_limited_pop;