---  神域押镖商店
local game_godfield_dart_shop = {
    m_tGameData = nil,
    m_list_view_bg = nil,
    m_free_refresh_label = nil,
    m_add_googs_node = nil,
    m_add_tips_label = nil,
    m_tips_label = nil,
    m_create_team_btn = nil,
    m_my_team = nil,
};
--[[--
    销毁ui
]]
function game_godfield_dart_shop.destroy(self)
    -- body
    cclog("-----------------game_godfield_dart_shop destroy-----------------");
    self.m_tGameData = nil;
    self.m_list_view_bg = nil;
    self.m_free_refresh_label = nil;
    self.m_add_googs_node = nil;
    self.m_add_tips_label = nil;
    self.m_tips_label = nil;
    self.m_create_team_btn = nil;
    self.m_my_team = nil;
end
--[[--
    返回
]]
function game_godfield_dart_shop.back(self,backType)
    local function responseMethod( tag,gameData )

            game_data:setDataByKeyAndValue("sel_dart_good",nil)

                game_scene:enterGameUi("game_godfield_dart_main",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_dart_mian"),http_request_method.GET,nil,"god_dart_mian")    
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_dart_shop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back()
        elseif btnTag == 2 then--刷新
            local shop_free_fresh_times = self.m_tGameData.shop_free_fresh_times or 0
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi()
                game_util:addMoveTips({text = "Tạo mới thành công"})
            end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_coin_shop_fresh"), http_request_method.GET, nil,"god_field_escort_coin_shop_fresh")
        elseif btnTag == 3 then--添加货物
            self:addGood();
        elseif btnTag == 4 then--背包
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_dart_goods",{gameData = self.m_tGameData,enterType = "look"})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_my_goods"), http_request_method.GET, nil,"escort_my_goods")
        elseif btnTag == 5 then--下一步
            local sel_dart_good = game_data:getDataByKey("sel_dart_good")
            if sel_dart_good == nil then
                -- game_util:addMoveTips({text = "请选择货物！"})
                self:addGood();
                return;
            else
                my_team ={}
                my_team.goods_id = sel_dart_good.goodId
                my_team.squad = self.squad_id
                cclog(my_team.squad,"qwertyui")
                local function responseMethod(tag,gameData)
                    game_data:setDataByKeyAndValue("sel_dart_good",nil)
                    game_scene:enterGameUi("game_godfield_dart_Shipsel",{gameData = gameData,my_team = my_team})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_choice_escort"), http_request_method.GET, nil,"god_field_choice_escort")
            end
 
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_dart_shop.ccbi");
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    
    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg")
    self.m_free_refresh_label = ccbNode:labelTTFForName("m_free_refresh_label")
    self.m_add_googs_node = ccbNode:nodeForName("m_add_googs_node")
    self.m_add_tips_label = ccbNode:labelTTFForName("m_add_tips_label")
    self.m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    self.m_create_team_btn = ccbNode:controlButtonForName("m_create_team_btn")

    return ccbNode;
end


--[[--
    创建道具列表
]]
function game_godfield_dart_shop.createTableView(self,viewSize)
    local showDataTable = self.m_tGameData.shop_goods
    local showData = {}
    for k,v in pairs(showDataTable) do
        table.insert(showData,k)
    end
    table.sort(showData,function(data1,data2) return tonumber(data1) <  tonumber(data2) end)

    local itemsCount = #showData
    local pos = {{x=0.17,y=0.75},{x=0.5,y=0.75},{x=0.83,y=0.75},{x=0.3,y=0.25},{x=0.7,y=0.25}}
    -- local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();

        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local reward = data:getNodeWithKey("reward")
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            local buy_goods_id = tostring(self.m_tGameData.buy_goods_id or "")
            local goods = self.m_tGameData.goods or {}
            local buyGoodData = goods[buy_goods_id]
            if buyGoodData then
                game_data:setDataByKeyAndValue("sel_dart_good",{goodId = tostring(buy_goods_id),goodData = buyGoodData.goods[1]})
            end
            self:refreshUi()
            game_util:rewardTipsByJsonData(reward)
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_buy_goods"), http_request_method.GET, {goods_id = showData[btnTag]},"god_field_escort_buy_goods")
    end
    for i=1,5 do
        local p = ccp(viewSize.width*pos[i].x,viewSize.height*pos[i].y)
        local ccbNode = luaCCBNode:create()
        ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick)
        ccbNode:openCCBFile("ccb/ui_godfield_dart_shop_item.ccbi")
        ccbNode:setAnchorPoint(ccp(0.5,0.5));
        ccbNode:setPosition(p)
        ccbNode:setScale(0.9)
        self.m_list_view_bg:addChild(ccbNode)

        local itemData = showDataTable[showData[i]]
        local price = itemData.price
        local goods = itemData.goods[1]
        local icon,name,count = game_util:getRewardByItemTable(goods)
        local m_name_label = ccbNode:labelTTFForName("m_name_label")
        local m_icon = ccbNode:nodeForName("m_icon")
        local m_count = ccbNode:labelBMFontForName("m_count")
        local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
        local black_bg = ccbNode:layerColorForName("black_bg")
        local m_sell_off_sprite = ccbNode:spriteForName("m_sell_off_sprite")
        local m_sell_off_label = ccbNode:labelTTFForName("m_sell_off_label")
        m_buy_btn:setTag(i)
        m_icon:removeAllChildrenWithCleanup(true)
        m_count:setString(tostring(price))
        if icon then
            icon:setPosition(ccp(m_icon:getContentSize().width*0.5,m_icon:getContentSize().height*0.5))
            icon:setScale(0.75)
            m_icon:addChild(icon,10)
            if count then
                local countLabel = game_util:createLabelBMFont({text = "×" .. count});
                countLabel:setPosition(ccp(20,2))
                m_icon:addChild(countLabel,10)
            end
        end
        if name then
            m_name_label:setString(name)
        end
        local is_buy = itemData.is_buy
        if is_buy == 0 then--没买过
            black_bg:setVisible(false)
            m_buy_btn:setEnabled(true)
        else
            black_bg:setVisible(true)
            m_buy_btn:setEnabled(false)
        end
        local validity = itemData.validity or 0
        local off = itemData.off or 100
        if off < 100 then
            m_sell_off_sprite:setVisible(true)
            m_sell_off_label:setString(string.format("%.1fGiảm",off/10))
        else
            m_sell_off_sprite:setVisible(false)
        end
    end
    
end

function game_godfield_dart_shop.addGood(self)
    local function callBackFunc()
        self:refreshGood();
    end
    local function responseMethod(tag,gameData)
        game_scene:addPop("game_dart_goods",{gameData = self.m_tGameData,enterType = "select",callBackFunc = callBackFunc})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_my_goods"), http_request_method.GET, nil,"god_field_escort_my_goods")
end

function game_godfield_dart_shop.refreshGood(self)
    local sel_dart_good = game_data:getDataByKey("sel_dart_good")
    if sel_dart_good then
        local icon,name,count = game_util:getRewardByItemTable(sel_dart_good.goodData)
        if icon then
            self.m_add_googs_node:removeAllChildrenWithCleanup(true);
            self.m_add_googs_node:addChild(icon);
            local countLabel = game_util:createLabelBMFont({text = "×" .. tostring(count)});
            countLabel:setPosition(ccp(50,10))
            icon:addChild(countLabel,10)
        end
        game_util:setCCControlButtonBackground(self.m_create_team_btn,"dart_btn_quyunhuo.png")
    else
        game_util:setCCControlButtonBackground(self.m_create_team_btn,"dart_btn_tianjiahuowu.png")
    end  
end

--[[--
    刷新ui
]]
function game_godfield_dart_shop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self:createTableView(self.m_list_view_bg:getContentSize());
    local fresh_cost = self.m_tGameData.fresh_cost or 0
    self.m_free_refresh_label:setString(tostring(fresh_cost) .."/lần")
    self:refreshGood();
end
--[[--
    初始化
]]
function game_godfield_dart_shop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    end
    self.squad_id = t_params.squad
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_dart_shop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end


return game_godfield_dart_shop;
