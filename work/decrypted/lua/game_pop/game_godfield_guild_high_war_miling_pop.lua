--- 坠落之地
--- 元素密令
local game_godfield_guild_high_war_miling_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_pay_client=nil,
    m_tableView = nil,
};

--[[--
    销毁
]]
function game_godfield_guild_high_war_miling_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_miling_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_pay_client=nil;
    self.m_tableView = nil;
end
--[[--
    返回
]]
function game_godfield_guild_high_war_miling_pop.back(self)
    game_scene:removePopByName("game_godfield_guild_high_war_miling_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_miling_pop.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");

    self.m_cur_select_index = 1
    self.m_needRefreshViewPos = true
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 100 then -- 规则    
            local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
            local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(9))
            if itemCfg == nil then return end
            local openMsg = itemCfg:getNodeWithKey("des"):toStr();
            game_scene:addPop("game_godfield_detail_pop",{openMsg = openMsg, btn_touchPriority = 12, touchPriority = 12})
        elseif btnTag >= 101 and btnTag <= 102 then -- 一键领取
            local reward_type = 0 -- 1 付费 0 免费
            if btnTag == 102 then
                reward_type = 1
            end

            if btnTag == 101 and not self.m_can_get1 then
                return game_util:addMoveTips({text = "Điểm hiện tại không thể nhận thưởng!"})
            end

            if btnTag == 102 and not self.m_can_get2 then
                return game_util:addMoveTips({text = "Điểm hiện tại không thể nhận thưởng!"})
            end

            local function responseMethod( tag,gameData )
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local data = gameData:getNodeWithKey("data");
                    local reward = data:getNodeWithKey("reward")
                    if reward:getNodeCount() > 1 then
                        game_util:rewardTipsByJsonData(reward)
                    end
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                end
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_auto_get_war_reward"), http_request_method.GET, {reward_type = reward_type},"guild_high_war_auto_get_war_reward")
        elseif btnTag == 201 then -- 购买 
            local guild_high_war_card_cfg = getConfig(game_config_field.guild_high_war_card)
            guild_high_war_card_cfg = json.decode(guild_high_war_card_cfg:getFormatBuffer())
            local buy_id = 22
            for k,v in pairs(guild_high_war_card_cfg) do
                if tostring(v.version) == tostring(self.m_tGameData.version) and v.card_sort == 2 then
                    buy_id = v.buy_id
                    break
                end
            end
            self:checkAndPay(tostring(buy_id))
        elseif btnTag == 202 then -- 赠送   
            local function responseMethod( tag,gameData )
                game_scene:addPop("game_godfield_guild_high_war_miling_give_pop", {gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_player_index"), http_request_method.GET, nil,"guild_high_war_player_index")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_miling_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_gz_btn = ccbNode:controlButtonForName("m_gz_btn")
    self.m_gz_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)


    -- local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)

    self.label_tips = ccbNode:labelTTFForName("label_tips")
    local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
    local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(23))
    local openMsg = itemCfg:getNodeWithKey("des"):toStr();
    self.label_tips:setString(openMsg)

    self.node_rewards = ccbNode:nodeForName("node_rewards")

    self.m_yjlq_btn1 = ccbNode:controlButtonForName("m_yjlq_btn1")
    self.m_yjlq_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
    self.m_yjlq_btn2 = ccbNode:controlButtonForName("m_yjlq_btn2")
    self.m_yjlq_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)

    self.m_gm_btn = ccbNode:controlButtonForName("m_gm_btn")
    self.m_gm_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    local guild_high_war_card_cfg = getConfig(game_config_field.guild_high_war_card)
    guild_high_war_card_cfg = json.decode(guild_high_war_card_cfg:getFormatBuffer())
    local buy_id = 22
    for k,v in pairs(guild_high_war_card_cfg) do
        if tostring(v.version) == tostring(self.m_tGameData.version) and v.card_sort == 2 then
            buy_id = v.buy_id
            break
        end
    end
    local gameShopConfig = getConfig(game_config_field.charge);
    local moneyConfig = gameShopConfig:getNodeWithKey(tostring( buy_id ))
    game_util:setCCControlButtonTitle(self.m_gm_btn, "₫"..moneyConfig:getNodeWithKey("price"):toStr())

    self.m_zs_btn = ccbNode:controlButtonForName("m_zs_btn")
    self.m_zs_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    self.label_score = ccbNode:labelTTFForName("label_score")
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-11,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[
    去支付
]]
function game_godfield_guild_high_war_miling_pop.checkAndPay( self, payType )
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
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_war_index"), http_request_method.GET, {},"guild_high_war_war_index")
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
    self.m_pay_client = game_util:buySthByChargeIndex( payType, payCallBack)
end

function game_godfield_guild_high_war_miling_pop.closePay( self )
    if self.m_pay_client and self.m_pay_client.destroy then
        self.m_pay_client:destroy()
        self.m_pay_client = nil
    end
end

--[[--
    刷新ui
]]
function game_godfield_guild_high_war_miling_pop.refreshUi(self)
    self.m_can_get1 = false
    self.m_can_get2 = false
    local guild_high_war_card_cfg = getConfig(game_config_field.guild_high_war_card)
    guild_high_war_card_cfg = json.decode(guild_high_war_card_cfg:getFormatBuffer())

    local miling_info1 
    local miling_info2
    for k,v in pairs(guild_high_war_card_cfg) do
        if tostring(v.version) == tostring(self.m_tGameData.version) then
            if v.card_sort == 1 then
                miling_info1 = v
            elseif v.card_sort == 2 then
                miling_info2 = v
            end
        end
    end

    local reward_list = {}

    for i=1,30 do
        local level1 = miling_info1["level_"..i]
        local level2 = miling_info2["level_"..i]
        if not level1 then
            break
        end
        reward_list[i] = {reward1 = level1, reward2 = level2, day = i}
    end


    if self.m_tableView then
        self.m_lastTableViewPosX = self.m_tableView:getContentOffset().x
    end

    self.node_rewards:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createRewardTableView(self.node_rewards:getContentSize(), reward_list);
    self.node_rewards:addChild(self.m_tableView);
    self.m_tableView:setScrollBarVisible(false);
    -- 重置位置
    if self.m_lastTableViewPosX then
        local contentSize = self.m_tableView:getContentSize()
        self.m_lastTableViewPosX = math.max(-1 * contentSize.width, self.m_lastTableViewPosX)
        self.m_tableView:setContentOffset(ccp(math.min(self.m_lastTableViewPosX, 0), 0 ), false);
    end

    -- 可领取的最小index
    local cur_select_index1, cur_select_index2 = 1,1
    for i,v in ipairs(reward_list) do
        local score = v.day
        local flag1, flag2 = self:getRewardGodFlag(i)
        if score <= self.m_tGameData.score then
            cur_select_index1 = i
        end
        if score <= self.m_tGameData.score and not flag1 then
            cur_select_index1 = i
            break
        end
    end
    for i,v in ipairs(reward_list) do
        local score = v.day
        local flag1, flag2 = self:getRewardGodFlag(i)
        if score <= self.m_tGameData.score and self.m_tGameData.war_card == 1 then
            cur_select_index2 = i
        end
        if score <= self.m_tGameData.score and not flag2 and self.m_tGameData.war_card == 1 then
            cur_select_index2 = i
            break
        end
    end
    if cur_select_index2 > 0 and self.m_tGameData.war_card == 1 then 
        self.m_cur_select_index = math.min(cur_select_index1, cur_select_index2)
    else
        self.m_cur_select_index = cur_select_index1
    end

    if self.m_needRefreshViewPos then
        self.m_needRefreshViewPos = false
        local bg_width = self.node_rewards:getContentSize().width
        local view_width = self.m_tableView:getContentSize().width
        local offx = (self.m_cur_select_index-1) * self.m_ccbNode_size_width - 10
        local maxOffsetX = view_width- bg_width
        self.m_tableView:setContentOffset(ccp(math.max(-offx, -maxOffsetX ), 0), false)
    end
    

    local itemSize = CCSizeMake(self.node_rewards:getContentSize().width/5,self.node_rewards:getContentSize().height/1);
    for i,v in ipairs(reward_list) do
        local score = v.day
        local label_score = game_util:createLabelTTF({text = v.day, fontSize = 9})
        local spr_score_id 
        if score <= self.m_tGameData.score then
            spr_score_id = CCSprite:createWithSpriteFrameName("ml_jfjs03.png")
            label_score:setColor(ccc3(255,241,161))
        else
            spr_score_id = CCSprite:createWithSpriteFrameName("ml_jfjs02.png")
            label_score:setColor(ccc3(189,227,248))
        end
        spr_score_id:setPosition(ccp(itemSize.width*(i-1)+8,itemSize.height*0.5+12));
        self.m_tableView:addChild(spr_score_id,11,11);
        label_score:setPosition(ccp(spr_score_id:getContentSize().width/2, spr_score_id:getContentSize().height/2))
        spr_score_id:addChild(label_score,10,10)
    end
    
    if self.m_tGameData.war_card == 1 then
        game_util:setCCControlButtonEnabled(self.m_gm_btn, false)
    else
        game_util:setCCControlButtonEnabled(self.m_yjlq_btn2, false)
    end    

    self.label_score:setString("Số ngày hiện tại:"..self.m_tGameData.score)
    -- local offsetY = nil
    -- if self.m_tableView and self.m_tableView.getContentOffset then
    --     offsetY = self.m_tableView:getContentOffset().y
    -- end

    -- self.m_node_awardview_board:removeAllChildrenWithCleanup(true)
    -- self.m_tableView = self:createRewardTableView( self.m_node_awardview_board:getContentSize(), gameData )
    -- self.m_node_awardview_board:addChild( self.m_tableView, 10, 998 )
    -- if offsetY then
    --     self.m_tableView:setContentOffset( ccp( 0, offsetY ) )
    -- end

    -- if self.m_aim_index then
    --     game_util:setTableViewIndex( self.m_aim_index, self.m_node_awardview_board, 998, 3  )
    --     self.m_aim_index = nil
    -- end


    local guild_high_war_base_cfg = getConfig(game_config_field.guild_high_war_base)
    guild_high_war_base_cfg = guild_high_war_base_cfg:getNodeWithKey(tostring(self.m_tGameData.version));
    local freecard = guild_high_war_base_cfg:getNodeWithKey("freecard") and guild_high_war_base_cfg:getNodeWithKey("freecard"):toInt()
    if freecard then
        self.m_gm_btn:setVisible(freecard ~= 1)
        self.m_zs_btn:setVisible(freecard ~= 1)
    end
end

function game_godfield_guild_high_war_miling_pop.getRewardGodFlag(self, id)
    local flag1 
    for k,v in pairs(self.m_tGameData.got_war_card_reward_free) do
        if tonumber(id) == tonumber(v) then
            flag1 =  true
        end
    end
    local flag2 
    for k,v in pairs(self.m_tGameData.got_war_card_reward) do
        if tonumber(id) == tonumber(v) then
            flag2 =  true
        end
    end
    return flag1, flag2
end

--[[--
    创建 进攻方/防守方 列表
]]
function game_godfield_guild_high_war_miling_pop.createRewardTableView(self,viewSize, showData)
    -- self.m_selTitleId = 1
    self.m_selListItem = nil;
    local cardsCount = #showData

    local totalItem = math.max(cardsCount%3 == 0 and cardsCount or math.floor(cardsCount/3+1)*3,3)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 5; --列
    params.totalItem = cardsCount --totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionHorizontal;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.itemActionFlag = false
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_miling_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            self.m_ccbNode_size_width = ccbNode:getContentSize().width
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local node_icon = ccbNode:nodeForName("node_icon")
            local node_item1 = ccbNode:nodeForName("node_item1")
            local node_icon1 = ccbNode:nodeForName("node_icon1")
            local node_bar = ccbNode:nodeForName("node_bar")
            local spr_score_id = ccbNode:spriteForName("spr_score_id")
            spr_score_id:setVisible(false)

            local reward1 = showData[index + 1].reward1
            local reward2 = showData[index + 1].reward2
            local score = showData[index + 1].day
            local flag1, flag2 = self:getRewardGodFlag(index + 1)
            local free_flag 
            if score <= self.m_tGameData.score and not flag1 then
                free_flag = true
                self.m_can_get1 = true
            end
            node_icon:removeAllChildrenWithCleanup(true);
            local m_tableView1 = self:createItemTable(node_icon:getContentSize(), reward1, 1, free_flag, index + 1, 0, flag1);
            node_icon:addChild(m_tableView1);
            m_tableView1:setScrollBarVisible(false);

            local flag 
            if score <= self.m_tGameData.score and not flag2 and self.m_tGameData.war_card == 1 then
                flag = true
                self.m_can_get2 = true
            end
            node_icon1:removeAllChildrenWithCleanup(true);
            local m_tableView2 = self:createItemTable(node_icon1:getContentSize(), reward2, 2, flag, index + 1, 1, flag2);
            node_icon1:addChild(m_tableView2);
            m_tableView2:setScrollBarVisible(false);
            

            node_bar:removeAllChildrenWithCleanup(true)
            local bar = game_util:createProgressTimer({fileName = "ml_jdt01.png",percentage = 0})
            bar:setPosition(ccp(node_bar:getContentSize().width/2, node_bar:getContentSize().height/2))
            node_bar:addChild(bar)
            local back_exp = 0
            if showData[index] then
                back_exp = showData[index].day
            end
            local exp = math.max(self.m_tGameData.score - back_exp, 0)
            local exp_max = math.max(score - back_exp, 0)
            bar:setPercentage(100*exp/exp_max);
           
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then

        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        -- self.m_selListItem = nil;
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end


function game_godfield_guild_high_war_miling_pop.createItemTable(self,viewSize,rewardList,showCount, can_flag, reward_id, reward_type, is_got)
    local scale = scale or 0.5

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemCfg = rewardList[btnTag+1]
        game_util:lookItemDetal(itemCfg)
    end
    local count = #rewardList
    local params = {};
    params.viewSize = viewSize;
    params.row = showCount;
    params.column = 1; --列
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5,0.5))
            node:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            cell:addChild(node)

            if can_flag then
                local ml_klq = CCSprite:createWithSpriteFrameName("ml_klq.png")
                node:addChild(ml_klq,12)
            end

            local itemGift = rewardList[index+1]
            local icon,name,count = game_util:getRewardByItemTable(itemGift)
            if icon then
                icon:setScale(0.7)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,0))
                node:addChild(icon,10)
            end
            if count then
                local nameLabel = game_util:createLabelTTF({text = "x"..count})
                nameLabel:setColor(ccc3(255,255,255))
                nameLabel:setAnchorPoint(ccp(0.5, 0.5))
                nameLabel:setPosition(icon:getContentSize().width * 0.5, 5)
                icon:addChild(nameLabel, 11)
            end
            local tempIconSize = icon:getContentSize()
            if reward_type == 1 then
                if can_flag and self.m_tGameData.war_card == 1 then
                    icon:setColor(ccc3(255, 255, 255))
                    local anim2 = game_util:createEffectAnim("taozhuangjihuo",1,true,"gem")
                    anim2:setScale(0.65)
                    anim2:setPosition(ccp(1,0));
                    node:addChild(anim2,11,11)
                else
                    icon:setColor(ccc3(155, 155, 155))
                    if not is_got then
                        local spr_lock = CCSprite:createWithSpriteFrameName("public_bigLock.png")
                        spr_lock:setScale(0.4)
                        spr_lock:setPosition(ccp(12,12));
                        node:addChild(spr_lock,11)
                    end
                end
            else
                if can_flag then
                    icon:setColor(ccc3(255, 255, 255))
                    local anim2 = game_util:createEffectAnim("taozhuangjihuo",1,true,"gem")
                    anim2:setScale(0.65)
                    anim2:setPosition(ccp(1,0));
                    node:addChild(anim2,11,11)
                else
                    icon:setColor(ccc3(155, 155, 155))
                    if not is_got then
                        local spr_lock = CCSprite:createWithSpriteFrameName("public_bigLock.png")
                        spr_lock:setScale(0.4)
                        spr_lock:setPosition(ccp(12,12));
                        node:addChild(spr_lock,11)
                    end
                end
            end

            
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            if can_flag then
                local reward_type = reward_type -- 1 付费 0 免费
                local function responseMethod( tag,gameData )
                    if gameData ~= nil and tolua.type(gameData) == "util_json" then
                        local data = gameData:getNodeWithKey("data");
                        local reward = data:getNodeWithKey("reward")
                        if reward then
                            game_util:rewardTipsByJsonData(reward)
                        end
                        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    end
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_get_war_reward"), http_request_method.GET, {reward_type = reward_type, reward_id = reward_id},"guild_high_war_get_war_reward")
            else
                local itemCfg = rewardList[index+1]
                game_util:lookItemDetal(itemCfg)
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        
    end
    return TableViewHelper:create(params);
end

--[[--
    初始化
]]
function game_godfield_guild_high_war_miling_pop.init(self,t_params)
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
function game_godfield_guild_high_war_miling_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_guild_high_war_miling_pop;