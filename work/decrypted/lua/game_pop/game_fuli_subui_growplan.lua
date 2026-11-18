---  福利 - 成长计划
local game_fuli_subui_growup = {
    m_node_awardview_board = nil,
    m_cur_rewardCount = nil,
    m_onceData = nil,
    m_guide_node = nil,
    m_parentCloseBtn = nil,
    m_cur_reward= nil,
    m_show_rewards = nil,
    node_buy_gift = nil,
    m_key_index = nil,
    m_sprite_aleradybuy = nil,
    m_btn_buy = nil,
    m_isVisible = nil,
    m_label_tips = nil,
    m_buy_flag = false,
    m_tableView = nil,
    m_pay_client = nil;
    m_aim_index = nil;
}

--[[--
    销毁ui
]]
function game_fuli_subui_growup.destroy(self)
    -- body
    cclog("----------------- game_fuli_subui_growup destroy-----------------"); 
    if self.closePay then
        self:closePay()
    end
    self.m_node_awardview_board = nil;
    self.m_cur_rewardCount = nil;
    self.m_onceData = nil;
    self.m_guide_node = nil;
    self.m_parentCloseBtn = nil;
    self.m_cur_reward = nil;
    self.m_show_rewards = nil;
    self.node_buy_gift = nil;
    self.m_key_index = nil;
    self.m_sprite_aleradybuy = nil;
    self.m_btn_buy = nil;
    self.m_isVisible = nil;
    self.m_label_tips = nil;
    self.m_buy_flag = false;
    self.m_tableView = nil;
    self.m_pay_client = nil;
    self.m_aim_index = nil;
end
--[[--
    返回
]]
function game_fuli_subui_growup.back(self,backType)
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_fuli_subui_growup.createUi(self)

   local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "createUi btnTag  ==  ")
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 3 then--切换到每日签到
            self.m_change_type = true
            self.m_show_tpye = 1
            self:refreshBtn()
        elseif btnTag == 4 then--切换到充值签到
            self.m_change_type = true
            self.m_show_tpye = 2
            self:refreshBtn()
        elseif btnTag == 1001 then   -- 购买计划
            if self.m_buy_flag == 1 then
                game_util:addMoveTips( {text = "已经购买成功，请稍后在邮箱查收礼包"} )
                return
            end
            self:checkAndPay()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_fuli_content_growup.ccbi");

    self.m_sprite_aleradybuy = ccbNode:spriteForName("m_sprite_aleradybuy")
    self.m_btn_buy = ccbNode:controlButtonForName("m_btn_buy")

    self.m_node_awardview_board = ccbNode:nodeForName("m_node_awardview_board")
    self.node_buy_gift = ccbNode:nodeForName("node_buy_gift")
    self.m_label_tips = ccbNode:labelTTFForName("m_label_tips")

    self.m_isVisible = true
    local touchLayer = CCLayer:create()
    ccbNode:addChild(touchLayer)
    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
         if eventType == "began" then 
            if self.m_isVisible ~= true then
                return false
            end
            local realPos = self.m_node_awardview_board:getParent():convertToNodeSpace(ccp(x,y));
            if self.m_node_awardview_board:boundingBox():containsPoint(realPos) then
                -- cclog2( "点在子UI界面上面 -- " )
                return false;
            end
            return true;  
        end 
    end
    touchLayer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 2,true);
    touchLayer:setTouchEnabled(true);
    self.m_btn_buy:setTouchPriority( GLOBAL_TOUCH_PRIORITY - 3 )
    return ccbNode;
end

--[[
    关闭支付
]]
function game_fuli_subui_growup.closePay( self )
    if self.m_pay_client and self.m_pay_client.destroy then
        self.m_pay_client:destroy()
        self.m_pay_client = nil
    end
end

--[[
    去支付
]]
function game_fuli_subui_growup.checkAndPay( self )
    function checkPay( )
        cclog2( self.m_tGameData.status, "   checkAndPay  ============================  end  self.m_tGameData.status  ===")
        if self.m_tGameData.status == 0 then
            local payCallBack = function ( code, msg )
                -- cclog2( code, "payCallBack  code    ====   " )
                -- cclog2( msg, "payCallBack  msg    ====   " )
                if code == "success" then
                    game_util:addMoveTips({text = "购买成功"})
                    self.m_buy_flag = 1
                    self:refreshNetData()
                    game_util:closeAlertView()
                elseif code == "failed" then
                    game_util:addMoveTips({text = "购买失败"})
                    game_util:closeAlertView()
                else
                    game_util:addMoveTips({text = "如您支付成功，请刷新界面"})
                    game_util:closeAlertView()
                end
            end 

            -- self:showRefreshTips()
            self:closePay()
            self.m_pay_client = game_util:buySthByChargeIndex( 12, payCallBack)
        end
    end
    -- cclog2("  start checkAndPay  ============================  start ")
    self:refreshNetData( checkPay )
end

--[[
    显示提示刷新弹框
]]
function game_fuli_subui_growup.showRefreshTips( self )
    local t_params = 
    {
        title = string_config.m_title_prompt,
        okBtnCallBack = function(target,event)
            game_util:closeAlertView()
        end,   --可缺省
        btnUseTTF = true,
        closeFlag = false,         --  是否可以点击关闭
        okBtnText = "刷新",         --可缺省
        text = "刷新数据后查看",      --可缺省
    }
    game_util:openAlertView(t_params)
end


function game_fuli_subui_growup.createRewardTableView( self, viewSize )
    local grow_gift_Cfg = getConfig(game_config_field.grow_gift); 
    local showData = self.m_show_rewards
    -- cclog2(showData, "showData  ====  ")

    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " ..btnTag)
        if btnTag > 1000 then--领奖按钮
            local index = btnTag - 1000
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                -- cclog("data = " .. data:getFormatBuffer())
                local reward = data:getNodeWithKey("reward")
                game_util:rewardTipsByJsonData(reward);
                self.m_tGameData = json.decode( data:getFormatBuffer() ) or self.m_tGameData
                self:refreshCurData()
                self:refreshUi()
            end
            local key = showData[ index ]
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("grow_gift_receive"), http_request_method.GET, {lv = key},"grow_gift_receive")
        else--挑战
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("map_world_scene",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
        end
    end
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag == " .. btnTag)
        local dataIndex = math.floor(btnTag / 1000)
        local rewardIndex = math.floor(btnTag % 10)
        
        local itemKey = showData[dataIndex + 1]
        local itemCfg = grow_gift_Cfg:getNodeWithKey( tostring(itemKey) )
        local reward = json.decode( itemCfg:getFormatBuffer() ) or {}
        reward = reward.reward
        game_util:lookItemDetal(reward[ rewardIndex ])
    end
    self.m_guide_node = nil
  local reward_pos = {
        {0.5},
        {0.4, 0.6},
        {0.3, 0.5, 0.7},
        {0.2, 0.4, 0.6, 0.8},
    }
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 1; --列
    params.totalItem = #showData;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    params.touchPriority = GLOBAL_TOUCH_PRIORITY ; --列
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_fuli_content_growup_item.ccbi");
            -- ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell ~= nil then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemKey = showData[ index + 1 ]
            local needLevel = tonumber( itemKey ) or 1
            local itemCfg = grow_gift_Cfg:getNodeWithKey( tostring(itemKey) )
            --
            local reward_node = ccbNode:nodeForName("reward_node")
            local btn_go = ccbNode:controlButtonForName("btn_go")
            btn_go:setTag( index + 1 )
            btn_go:setVisible(true)

            local blabel_title = ccbNode:labelBMFontForName("blabel_title")  -- 标题
            blabel_title:setString( "达到" .. tostring(itemKey) .. "级" )

            local particle = ccbNode:particleForName("particle")
            local m_sprite_aleradyget = ccbNode:spriteForName("m_sprite_aleradyget")
            m_sprite_aleradyget:setVisible(false)
            local m_scale9sprite_backboard = ccbNode:scale9SpriteForName("m_scale9sprite_backboard")
            btn_go:setTouchPriority( GLOBAL_TOUCH_PRIORITY -1)

            local playerLevel = game_data:getUserStatusDataByKey("level") or 1;
            reward_node:removeAllChildrenWithCleanup(true)
            particle:setVisible(false)

            local node_get_btn_anim = ccbNode:nodeForName("node_get_btn_anim")
            node_get_btn_anim:stopAllActions()
            node_get_btn_anim:setScale(0.9)
            node_get_btn_anim:removeAllChildrenWithCleanup(true)

            local isGet = game_util:valueInTeam( itemKey, self.m_tGameData.info  )
            if playerLevel >= needLevel and (not isGet) then--领奖按钮
                btn_go:removeAllChildrenWithCleanup(true)
                game_util:setCCControlButtonBackground(btn_go,"award_btn_get.png")
                if self.m_tGameData.status == 1 then
                    game_util:createPulseAnmi("award_btn_get.png",node_get_btn_anim)
                    btn_go:setTag( index + 1000 + 1 )
                else
                    game_util:setCCControlButtonEnabled( btn_go, false )
                end
                m_scale9sprite_backboard:setColor(ccc3(255, 255, 255))
            elseif isGet then
                m_scale9sprite_backboard:setColor(ccc3(255, 255, 255))
                m_sprite_aleradyget:setVisible(true)
                btn_go:setVisible(false)
            else
                m_scale9sprite_backboard:setColor(ccc3(155, 155, 155))
                btn_go:removeAllChildrenWithCleanup(true)
                -- btn_go:setVisible(false)
                game_util:setCCControlButtonBackground(btn_go,"award_btn_get.png")
                game_util:setCCControlButtonEnabled( btn_go, false )
            end
            local reward = json.decode( itemCfg:getFormatBuffer() ) or {}
            reward = reward.reward
            local tempSize = reward_node:getContentSize()
            local posTable = reward_pos[#reward]
            for i=1, #reward do
                local aim_pos = ccp( tempSize.width * posTable[i], tempSize.height * 0.6 )
                local bgLayer = CCLayerColor:create(ccc4(255,255,255,255),36,36);
                bgLayer:setAnchorPoint(ccp(0.5,0.5))
                bgLayer:ignoreAnchorPointForPosition(false);

                local bgSprite = CCSprite:createWithSpriteFrameName("public_faguang.png");
                bgSprite:setScale(0.6)
                bgSprite:setAnchorPoint(ccp(0.5,0.5))

                local itemRewardData = reward[i]
                local reward_icon,name,count = game_util:getRewardByItemTable(itemRewardData,true);
                if reward_icon then
                    reward_icon:setAnchorPoint(ccp(0.5,0.5))
                    reward_icon:setScale(0.6)
                    reward_icon:setPosition(aim_pos)
                    if status == 1 then--领奖按钮
                        reward_node:addChild(bgLayer)
                        reward_node:addChild(bgSprite)
                    end
                    reward_node:addChild(reward_icon)
                    bgLayer:setPosition( aim_pos )
                    bgSprite:setPosition( aim_pos )
                    --加查看按钮
                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                    -- button:setTag((index) * 10 + i)
                    button:setTag( i + index * 1000 )
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition( aim_pos )
                    button:setOpacity(0)
                    reward_node:addChild(button)
                    if reward_icon and count then
                        local label = game_util:createLabelTTF({text = "×"..count,color = ccc3(250,250,250),fontSize = 12})
                        label:setAnchorPoint(ccp(0.5,0))
                        label:setPosition(ccp( reward_icon:getContentSize().width * 0.5 ,-10))
                        reward_icon:addChild(label, 10)
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新ui
]]
function game_fuli_subui_growup.refreshUi(self)
    -- self:createOnlineReward()

    cclog2( "refreshUi  ===========================  "  )

    local offsetY = nil
    if self.m_tableView and self.m_tableView.getContentOffset then
        offsetY = self.m_tableView:getContentOffset().y
    end

    self.m_node_awardview_board:removeAllChildrenWithCleanup(true)
    self.m_tableView = self:createRewardTableView( self.m_node_awardview_board:getContentSize(), gameData )
    self.m_node_awardview_board:addChild( self.m_tableView, 10, 998 )
    if offsetY then
        self.m_tableView:setContentOffset( ccp( 0, offsetY ) )
    end

    if self.m_aim_index then
        game_util:setTableViewIndex( self.m_aim_index, self.m_node_awardview_board, 998, 3  )
        self.m_aim_index = nil
    end

    -- local count = self.m_onceData[self.m_cur_showawardType].getcount
    -- game_util:setTableViewIndex(count - 1,self.m_node_awardview_board,10, 3)

    -- 去购买计划按钮
    self.m_btn_buy:setVisible( self.m_tGameData.status == 0 )
    self.m_sprite_aleradybuy:setVisible( self.m_tGameData.status == 1 )


    local gameShopConfig = getConfig(game_config_field.charge);
    local grow_cfg = gameShopConfig:getNodeWithKey("13")   -- 配置 成长计划
    local msg = "Sau khi mua Kế hoạch Trưởng Thành sẽ nhận tổng cộng 12800 Kim Cương" -- 从现在开始只要花费128元购买超值成长计划，总计返还12800钻石
    -- if grow_cfg then 
    --     local des = grow_cfg:getNodeWithKey("des") and grow_cfg:getNodeWithKey("des"):toStr() or ""
    --     local cost = grow_cfg:getNodeWithKey("price") and grow_cfg:getNodeWithKey("price"):toInt() or 128
    --     msg = "从现在开始只要花费" .. tostring( cost ) .. "元购买超值成长计划，" .. tostring( des )
    -- end
    self.m_label_tips:setString(msg)
end

function game_fuli_subui_growup.setViewVisible( self, isVisible )
    self.m_isVisible = isVisible
end

function game_fuli_subui_growup.refreshCurData( self )
    local grow_gift_Cfg = getConfig(game_config_field.grow_gift); 
    self.m_show_rewards = {}
    local count = grow_gift_Cfg and grow_gift_Cfg:getNodeCount() or 0
    for i = 1, count do
        local itemCfg = grow_gift_Cfg:getNodeAt(i - 1)
        if itemCfg then
            local key = itemCfg:getKey()
            -- if not  game_util:valueInTeam( key, self.m_tGameData.info  ) then
                table.insert( self.m_show_rewards, key )
            -- end
        end
    end
    local sort_fun = function ( data1, data2 )
        return tonumber(data1) and tonumber(data2) and tonumber(data1) < tonumber(data2) or false
    end
    table.sort( self.m_show_rewards, sort_fun )
end

--[[
    刷新网络数据
]]
function game_fuli_subui_growup.refreshNetData( self, success_callfun )
    local function responseMethod(tag,gameData)
        -- cclog2( gameData, "gameData  msg    ====   " )
        self:initData( gameData )
        self:refreshUi()
        if type(success_callfun) == "function" then
            success_callfun()
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("grow_gift_index"), http_request_method.GET, nil,"grow_gift_index")
end

--[[
    初始化数据
]]
function game_fuli_subui_growup.initData( self, gameData )

    if gameData ~= nil and tolua.type(gameData) == "util_json" then
        local temp = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
        self.m_tGameData = temp
    end
    self:refreshCurData()
end

--[[--
    初始化
]]
function game_fuli_subui_growup.init(self,t_params)
    t_params = t_params or {};
    self.m_parentCloseBtn = t_params.parentCloseBtn
    self:initData( t_params.gameData )
    -- 指定显示
    self.m_aim_index = nil
    for i,v in ipairs( self.m_show_rewards ) do
        if not  game_util:valueInTeam( v, self.m_tGameData.info  ) then
            self.m_aim_index = i - 1
            break
        end
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_fuli_subui_growup.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi(); 
    return scene;
end




return game_fuli_subui_growup