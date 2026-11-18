--- 坠落之地
--- 赠送密令
local game_godfield_guild_high_war_miling_give_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_pay_client=nil,
    m_tableView = nil,
};

--[[--
    销毁
]]
function game_godfield_guild_high_war_miling_give_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_miling_give_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_pay_client=nil;
    self.m_tableView = nil;
end
--[[--
    返回
]]
function game_godfield_guild_high_war_miling_give_pop.back(self)
    game_scene:removePopByName("game_godfield_guild_high_war_miling_give_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_miling_give_pop.createUi(self)
    self.m_select_index = 1
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
            
        elseif btnTag == 201 then -- 送1次  
            if #self.m_tGameData.player_info <= 0 then
                return game_util:addMoveTips({text = "Công hội hiện tại chưa có TV đạt điều kiện tặng"})
            end

            local guild_high_war_card_cfg = getConfig(game_config_field.guild_high_war_card)
            guild_high_war_card_cfg = json.decode(guild_high_war_card_cfg:getFormatBuffer())
            local buy_id = 23
            for k,v in pairs(guild_high_war_card_cfg) do
                if tostring(v.version) == tostring(self.m_tGameData.version) and v.card_sort == 3 then
                    buy_id = v.buy_id
                    break
                end
            end
            self:checkAndPay(tostring(buy_id))  
        elseif btnTag == 202 then -- 送5次      
            if #self.m_tGameData.player_info < 5 then
                return game_util:addMoveTips({text = "Mục tiêu có thể tặng hiện giờ ít hơn 5"})
            end 
            local guild_high_war_card_cfg = getConfig(game_config_field.guild_high_war_card)
            guild_high_war_card_cfg = json.decode(guild_high_war_card_cfg:getFormatBuffer())
            local buy_id = 24
            for k,v in pairs(guild_high_war_card_cfg) do
                if tostring(v.version) == tostring(self.m_tGameData.version) and v.card_sort == 4 then
                    buy_id = v.buy_id
                    break
                end
            end
            self:checkAndPay(tostring(buy_id))
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_miling_give_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)

    self.label_times = ccbNode:labelTTFForName("label_times") -- 可赠送次数：5次
    self.label_title = ccbNode:labelTTFForName("label_title")
    self.label_title:setString("DS Liên Minh")

    local label_times1 = ccbNode:labelTTFForName("label_times1")
    local label_times2 = ccbNode:labelTTFForName("label_times2")

    label_times1:setString("Tặng 1 lần")
    label_times2:setString("Tặng 5 lần")
    self.node_players = ccbNode:nodeForName("node_players")

    self.m_btn1 = ccbNode:controlButtonForName("m_btn1")
    self.m_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)

    local guild_high_war_card_cfg = getConfig(game_config_field.guild_high_war_card)
    guild_high_war_card_cfg = json.decode(guild_high_war_card_cfg:getFormatBuffer())
    local buy_id = 23
    for k,v in pairs(guild_high_war_card_cfg) do
        if tostring(v.version) == tostring(self.m_tGameData.version) and v.card_sort == 3 then
            buy_id = v.buy_id
            break
        end
    end
    local gameShopConfig = getConfig(game_config_field.charge);
    local moneyConfig = gameShopConfig:getNodeWithKey(tostring( buy_id ))
    game_util:setCCControlButtonTitle(self.m_btn1, "₫"..moneyConfig:getNodeWithKey("price"):toStr())


    self.m_btn2 = ccbNode:controlButtonForName("m_btn2")
    self.m_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
    local buy_id = 24
    for k,v in pairs(guild_high_war_card_cfg) do
        if tostring(v.version) == tostring(self.m_tGameData.version) and v.card_sort == 4 then
            buy_id = v.buy_id
            break
        end
    end
    local moneyConfig = gameShopConfig:getNodeWithKey(tostring( buy_id ))
    game_util:setCCControlButtonTitle(self.m_btn2, "₫"..moneyConfig:getNodeWithKey("price"):toStr())

    local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
    local label_tips = ccbNode:labelTTFForName("label_tips")
    local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(24))
    local openMsg = itemCfg:getNodeWithKey("des"):toStr();
    label_tips:setString(openMsg)
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-12,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end


--[[
    去支付
]]
function game_godfield_guild_high_war_miling_give_pop.checkAndPay( self, payType )
    local payCallBack = function ( code, msg )
        if code == "success" then
            game_util:addMoveTips({text = "Mua thành công"})
            function responseMethod(tag,gameData)
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                    self.m_tGameData = data
                    self:refreshUi()
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_player_index"), http_request_method.GET, {},"guild_high_war_player_index")
            game_util:closeAlertView()
        elseif code == "failed" then
            game_util:addMoveTips({text = "Mua thất bại"})
            game_util:closeAlertView()
        else
            game_util:addMoveTips({text = "Nếu bạn thanh toán thành công, hãy làm mới giao diện"})
            game_util:closeAlertView()
        end
        
    end 
    self:closePay()
    self.m_pay_client = game_util:buySthByChargeIndex( payType, payCallBack) --补签
end

function game_godfield_guild_high_war_miling_give_pop.closePay( self )
    if self.m_pay_client and self.m_pay_client.destroy then
        self.m_pay_client:destroy()
        self.m_pay_client = nil
    end
end
--[[--
    刷新ui
]]
function game_godfield_guild_high_war_miling_give_pop.refreshUi(self)

    if self.m_tableView then
        self.m_lastTableViewPosX = self.m_tableView:getContentOffset().x
    end

    self.node_players:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createRewardTableView(self.node_players:getContentSize(), self.m_tGameData.player_info);
    self.node_players:addChild(self.m_tableView);
    self.m_tableView:setScrollBarVisible(false);
    -- 重置位置
    if self.m_lastTableViewPosX then
        local contentSize = self.m_tableView:getContentSize()
        self.m_lastTableViewPosX = math.max(-1 * contentSize.width, self.m_lastTableViewPosX)
        self.m_tableView:setContentOffset(ccp(math.min(self.m_lastTableViewPosX, 0), 0 ));
    end

    self.label_times:setString("Số lần có thể tặng:"..self.m_tGameData.war_card_num)

end


--[[--
    创建 进攻方/防守方 列表
]]
function game_godfield_guild_high_war_miling_give_pop.createRewardTableView(self,viewSize, showData)
    -- self.m_selTitleId = 1
    self.m_selListItem = nil;
    local cardsCount = #showData

    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = cardsCount --totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.itemActionFlag = false
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            local function onMainBtnClick( target,event )
            local tagNode = tolua.cast(target, "CCNode");
                local btnTag = tagNode:getTag();
                local data = showData[btnTag]
                local function responseMethod( tag,gameData )
                    if gameData ~= nil and tolua.type(gameData) == "util_json" then
                        local data = gameData:getNodeWithKey("data");
                        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                        game_util:addMoveTips({text = "Tặng thành công"})
                    end
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_send_war_card"), http_request_method.GET, {t_uid = data.uid},"guild_high_war_send_war_card")
            end
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_miling_give_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
           
            local label_rank1 = ccbNode:labelTTFForName("label_rank1") -- 贡献排行
            local label_rank2 = ccbNode:labelTTFForName("label_rank2") -- 竞技排名
            local label_name = ccbNode:labelTTFForName("label_name") -- 名字
            local label_lv = ccbNode:labelTTFForName("label_lv") -- 等级
            local label_zw = ccbNode:labelTTFForName("label_zw") -- 职位
            local label_zgxd = ccbNode:labelTTFForName("label_zgxd")  -- 总贡献度
            local label_conmbat = ccbNode:labelTTFForName("label_conmbat") -- 战斗力
            local m_zs_btn = ccbNode:controlButtonForName("m_zs_btn")
            m_zs_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
            m_zs_btn:setTag(index + 1)
            local data = showData[index + 1]
            label_name:setString(data.name)
            label_lv:setString(data.level)
            label_conmbat:setString(data.combat)
            label_rank1:setString(data.rank)
            label_zgxd:setString(data.score)
            if(data.title == "owner")then
                label_zw:setString("Hội Trưởng");
            elseif(data.title == "vp")then
                label_zw:setString("Phó Hội Trưởng");
            else
                label_zw:setString("Hội Viên");
            end

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then

            --     local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
            --     local m_select_sprite = ccbNode:spriteForName("m_select_sprite")
            --     m_select_sprite:setVisible(false);
            -- end
            -- self.m_selListItem = cell
            -- self.m_selTitleId = index + 1
            -- local titleData = self.m_title_tab[index+1]
            -- self.m_selTitleData = titleData
            -- local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
            -- local m_select_sprite = ccbNode:spriteForName("m_select_sprite")
            -- m_select_sprite:setVisible(true);
            -- self:refreshUi()
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        -- self.m_selListItem = nil;
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end


--[[--
    初始化
]]
function game_godfield_guild_high_war_miling_give_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_guild_high_war_miling_give_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_guild_high_war_miling_give_pop;