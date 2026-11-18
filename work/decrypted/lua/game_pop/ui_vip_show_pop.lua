--- vip特權
local ui_vip_show_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_pay_btn = nil,
    m_pay_btn2 = nil,
    vip_show_node = nil,
    rich_label_node = nil,
    vip_need_money_label = nil,
    next_vip_label = nil,
    select_index = nil,
    vip_level_label = nil,

    vip_bar_node = nil,
    select_index = nil,
    last_select = nil,
};
--[[--
    銷毀ui
]]
function ui_vip_show_pop.destroy(self)
    -- body
    cclog("-----------------ui_vip_show_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_pay_btn = nil;
    self.m_pay_btn2 = nil;
    self.vip_show_node = nil;
    self.rich_label_node = nil;
    self.vip_need_money_label = nil;
    self.next_vip_label = nil;
    self.select_index = nil;
    self.vip_level_label = nil;
    self.vip_bar_node = nil;
    self.select_index = nil;
    self.last_select = nil;
end
--[[--
    返回
]]
function ui_vip_show_pop.back(self,backType)
    game_scene:removePopByName("ui_vip_show_pop");
    
    if self.m_openType == "game_month_fund_pop" then
        game_scene:enterGameUi("game_main_scene",{gameData = nil,openPop = "game_month_fund_pop"},{endCallFunc = endCallFunc})
    else
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
    -- self:destroy()
end
--[[--
    讀取ccbi創建ui
]]
function ui_vip_show_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 200 then--刷新
            local function responseMethod(tag,gameData)
                self:refreshDimond()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag == 101 then
            -- self:back();
            
            if getPlatForm() == "platformCommon"then
                if getPlatFormExt() == "platform_haiwai" then
                    buy(bundle);
                    require("game_ui.game_loading").show();
                    local selfUid = game_data:getUserStatusDataByKey('uid');
                    local server_data,sindex = game_data:getServer()
                    local serverId = server_data.server
                    local orderIdCom = tostring(selfUid) .. "-" .. tostring(serverId) .. '-' .. tostring(index) .. '-'..tostring(os.time());
                    local amount = moneyConfig:getNodeWithKey("price"):toInt();
                    if game_data_statistics then
                        game_data_statistics:payBegan({order = orderIdCom,productId=tostring(index),productPrice=amount,currencyType = "CNY"})
                    end
                else
                    print("---------------- pay with coolpay --------------- ")

                    local params = {}
                    local server_data,sindex = game_data:getServer()
                    local serverId = server_data.server
                    local orderIdCom = tostring(game_data:getUserStatusDataByKey('uid')) .. "-" .. tostring(serverId) .. '-'.. tostring(os.time());

                    params.orderid = orderIdCom
                    params.userId = game_data:getUserStatusDataByKey("uid")
                    params.unit = 0 ; --moneyConfig:getNodeWithKey("price"):toInt()
                    params.description = "0" ; -- moneyConfig:getNodeWithKey("name"):toStr()
                    params.pructId = "1" ;-- tostring(index)
                    params.count = 1
                    -- params.extUrl = game_url.getUrlForKey("get_vivo_order_id") --為vivo使用
                    -- params.queryUrl = game_url.getUrlForKey("get_query_order") --為vivo使用

                    params.roleName = game_data:getUserStatusDataByKey("show_name") or ""-- 兄弟玩 獨家專享
                    params.roleLevel = game_data:getUserStatusDataByKey("level") or 1--兄弟玩 獨家專享

                    -- params.jinliUrl = game_url.getUrlForKey("get_jinli_order") --金立獨家專享

                    -- params.pay_respon_url = game_url.getUrlForKey("pay_respon_url")--動態獲得支付回調地址
                    
                    params.serverId = serverId

                    --海外安卓版添加产品Id
                    params.cost = "1" ; --moneyConfig:getNodeWithKey("cost"):toStr();
                    local function buyResult(data)
                        -- body
                        local result = data["result"]
                        -- cclog("--- buy result cod %d", result)
                        if result == 0 then 
                            if game_data_statistics then
                                game_data_statistics:paySuccess({order = orderIdCom})
                            end
                            if index == 1 then--提示月卡禮包
                                game_util:addMoveTipsForNative({text = "Thẻ tháng mua thành công, phần thưởng sẽ phát trong thư"})
                                self.month_award = 0
                            elseif index == 2 then--提示周卡禮包
                                game_util:addMoveTipsForNative({text = "Thẻ tuần mua thành công, phần thưởng sẽ phát trong thư"})
                                self.week_award = 0
                            else
                                game_util:addMoveTipsForNative({text = "Mua Xu thành công, xin nhấp tạo mới"})
                            end
                        elseif result == 1 then
                            if game_data_statistics then
                                game_data_statistics:payFailed({order = orderIdCom})
                            end
                            if data["errmsg"] ~= nil then
                                game_util:addMoveTipsForNative({text = data["errmsg"]})
                            else
                                game_util:addMoveTipsForNative({text = "Mua thất bại"})
                            end
                        elseif result == -1 then
                            if game_data_statistics then
                                game_data_statistics:payFailed({order = orderIdCom})
                            end
                            game_util:addMoveTipsForNative({text = "Giao dịch thất bại"})
                        else
                            if game_data_statistics then
                                game_data_statistics:payFailed({order = orderIdCom})
                            end
                        end
                    end
                    if game_data_statistics then
                        game_data_statistics:payBegan({order = orderIdCom,productId=tostring(index),productPrice=0,currencyType = "CNY"})
                    end
                    --require("shared.native_helper").buyProduct(params,buyResult)
                    game_scene:enterGameUi("ui_vip",{});
                end
            end
        elseif btnTag == 102 then
            self:back()
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local function endCallBackFunc(index)
                    self.vip_buy_step = index
                    cclog("index = " .. index)
                end
                game_scene:addPop("ui_vip_show_gift_pop",{gameData = json.decode(data:getNodeWithKey("vip_bought"):getFormatBuffer()),endCallBackFunc=endCallBackFunc,buy_index = self.vip_buy_step,vip_data = self.vip_data})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("shop_open"), http_request_method.GET, {},"shop_open")
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_vip_privilege.ccbi");

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_pay_btn = ccbNode:controlButtonForName("m_pay_btn")
    self.m_pay_btn2 = ccbNode:controlButtonForName("m_pay_btn2")
    self.vip_show_node = ccbNode:nodeForName("vip_show_node")
    self.rich_label_node = ccbNode:nodeForName("rich_label_node")

    self.vip_need_money_label = ccbNode:labelTTFForName("vip_need_money_label")
    self.next_vip_label = ccbNode:labelTTFForName("next_vip_label")
    self.vip_level_label = ccbNode:labelBMFontForName("vip_level_label")
    self.vip_bar_node = ccbNode:nodeForName("vip_bar_node")
    self.dimond_label = ccbNode:labelBMFontForName("diomond_label")
    self.btn_refresh = ccbNode:controlButtonForName("btn_refresh")
 
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_pay_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_pay_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.btn_refresh:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);

    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScale(resolution_config:getScale())

    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    m_root_layer:setTouchEnabled(true);

    self.vip_level_label:setString(tostring(game_data:getVipLevel()))
    local vipLevel = game_data:getVipLevel()
    local vipExp = game_data:getVipExp()
    local vipCfg = getConfig(game_config_field.vip);
    
    local vip_exp = 1
    local next_exp = 1
    if vipLevel == 10 then
        local max = vipCfg:getNodeWithKey("10"):getNodeWithKey("need_exp"):toInt()
        vip_exp = max
        next_exp = max

        self.vip_need_money_label:setString(0 .. " Xu")
        self.next_vip_label:setString("VIP10")
    else
        local need_exp = vipCfg:getNodeWithKey(tostring(vipLevel)):getNodeWithKey("need_exp"):toInt()
        local last_exp = vipCfg:getNodeWithKey(tostring(vipLevel)):getNodeWithKey("need_exp"):toInt()

        vip_exp = vipExp
        next_exp = need_exp

        local need_more = need_exp - vipExp
        self.vip_need_money_label:setString(need_more .. " Xu")
        self.next_vip_label:setString("VIP" .. (vipLevel + 1))
    end

    local bar = ExtProgressBar:createWithFrameName("vip_icon_bar.png","vip_icon_progress.png",CCSizeMake(180,15));
    bar:setMaxValue(next_exp);
    local itemSize = self.vip_bar_node:getContentSize();
    bar:setCurValue(vip_exp,false);
    bar:setAnchorPoint(ccp(0.5,0.5))
    bar:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
    self.vip_bar_node:addChild(bar,10)
    local barTTF = CCLabelTTF:create(vip_exp.."/"..next_exp,TYPE_FACE_TABLE.Arial_BoldMT,12);
    barTTF:setAnchorPoint(ccp(0.5,0.5))
    barTTF:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
    self.vip_bar_node:addChild(barTTF,10)

    self:createVipRichLabel(vipLevel)
    return ccbNode;
end
--[[
    創建vip特權的rich label
]]
function ui_vip_show_pop.createVipRichLabel(self,vip_level)
    local itemSize = self.rich_label_node:getContentSize()
    local vipCfg = getConfig(game_config_field.vip);
    local itemCfg = vipCfg:getNodeWithKey(tostring(vip_level))
    local showMsg = itemCfg:getNodeWithKey("story"):toStr()
    local richLabel = game_util:createRichLabelTTF({text = showMsg,dimensions = itemSize,textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})
    richLabel:setAnchorPoint(ccp(0.5,0.5))
    richLabel:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))

    self.rich_label_node:removeAllChildrenWithCleanup(true)
    self.rich_label_node:addChild(richLabel,10,10)
end
--[[--
    創建活動列表
]]
function ui_vip_show_pop.createTableView(self,viewSize)
    local vipCfg = getConfig(game_config_field.vip);
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = vipCfg:getNodeCount();
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 11;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/vip_packs_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell ~= nil then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local select_light = ccbNode:scale9SpriteForName("select_light")
            local packs_node = ccbNode:nodeForName("packs_node")
            local privilege_node = ccbNode:nodeForName("privilege_node")
            local sprite_alpha = ccbNode:spriteForName("sprite_alpha")

            packs_node:setVisible(false)
            privilege_node:setVisible(true)
            sprite_alpha:setVisible(false)
            local vip_level_label = ccbNode:labelBMFontForName("vip_level_label_2") 
            vip_level_label:setString(tostring(index))

            if index == self.select_index then
                select_light:setVisible(true)
                self.last_select = select_light
            else
                select_light:setVisible(false)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local select_light = ccbNode:scale9SpriteForName("select_light")

            if select_light ~= self.last_select then
                select_light:setVisible(true)
                self.last_select:setVisible(false)

                self.select_index = index
                self.last_select = select_light
                self:createVipRichLabel(self.select_index)
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    刷新钻石
]]
function ui_vip_show_pop.refreshDimond(self)
    self.dimond_label:setString(tostring(game_data:getUserStatusDataByKey("coin")))
end
--[[--
    刷新ui
]]
function ui_vip_show_pop.refreshUi(self)
    self.vip_show_node:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.vip_show_node:getContentSize());
    tableViewTemp:setScrollBarVisible(false)
    self.vip_show_node:addChild(tableViewTemp,10,10);

    local showIndex = game_data:getVipLevel()
    if showIndex > 7 then
        showIndex = 7
    end
    if showIndex < 4 then
        showIndex = 0
    end
    game_util:setTableViewIndex(showIndex,self.vip_show_node,10,5)
    self:refreshDimond()
end
--[[--
    初始化
]]
function ui_vip_show_pop.init(self,t_params)
    t_params = t_params or {};
    self.select_index = game_data:getVipLevel()
    self.m_openType = t_params.openType or ""
end

--[[--
    創建ui入口並初始化數據
]]
function ui_vip_show_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return ui_vip_show_pop;