---  ui模版
--首冲
local game_vipguide_pop = {
    m_node_reward = nil,
    m_rewardInfo = nil,
    m_root_layer = nil,
    m_conbtn_getReward = nil,
    m_ticonbuttons = nil,
    node_shouchong_bg = nil,
};
--[[--
    銷毀ui
]]
function game_vipguide_pop.destroy(self)
    -- body
    cclog("----------------- game_vipguide_pop destroy-----------------"); 
    self.m_node_reward = nil;
    self.m_rewardInfo = nil;
    self.m_root_layer = nil;
    self.m_conbtn_getReward = nil;
    self.m_ticonbuttons = nil;
    self.node_shouchong_bg = nil;
end
--[[--
    返回
]]
function game_vipguide_pop.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    讀取ccbi創建ui
]]
function game_vipguide_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- print("press button tag is ", btnTag)
        -- if btnTag == 1 then -- 關閉
        --     self:back()
        -- ( btnTag >= 51 and btnTag <= 55 ) or 
        if btnTag >= 251  then
            cclog("4564654646464646446464646464")
                local info = self.m_rewardInfo[btnTag - 50]
                if info then
                    local tempType = info[1]
                    if tempType == 6 then--道具
                        local itemId = info[2]
                        game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
                    elseif tempType == 7 then--裝備
                        local equipId = info[2]
                        local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                        game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
                    elseif tempType == 5 then--卡牌
                        local cId = info[2]
                        cclog("cId == " .. cId)
                        game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
                    else                   -- 食品
                        game_scene:addPop("game_food_info_pop",{itemData = info})
                    end
                end
        elseif  btnTag == 101 then

            local vipLevel = game_data:getUserStatusDataByKey("vip") or 0
            if vipLevel > 0 then
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data");
                    game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                    if self.m_conbtn_getReward then 
                        self.m_conbtn_getReward:setEnabled(false)
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_kfhd_getreward"), http_request_method.GET, {award_id = 1 },"active_kfhd_getreward")
            else
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("ui_vip",{gameData = gameData});
                    --game_scene:addPop("ui_vip_show_pop");
                    self:destroy();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
            end
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_vipguide_pop.ccbi");

    -- -- 光效 顯示
    -- local falsh_blindness = ccbNode:spriteForName("falsh_blindness")
    -- falsh_blindness:runAction(game_util:createRepeatForeverFade());

    -- 本層阻止觸摸傳導下一層
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end

    self.node_shouchong_bg = ccbNode:nodeForName("node_shouchong_bg")
    self.m_conbtn_getReward = ccbNode:controlButtonForName("m_conbtn_getReward")
    self.m_conbtn_getReward:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_rewardInfo = {}
    self.m_ticonbuttons = {}
    for i=1,4 do
        self.m_ticonbuttons[i] =  ccbNode:controlButtonForName("m_conbtn_icon2" .. i)
        self.m_ticonbuttons[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    end
    
    --奖励读配置
    local opening_cfg = getConfig(game_config_field.opening)
    local itemCfg = opening_cfg:getNodeWithKey(tostring(1))
    local reward = itemCfg:getNodeWithKey("reward");
    local info = json.decode(reward:getFormatBuffer())
    cclog2(info,"111111111111111")
    
    for i=1, #info do
        local icon,name,count = game_util:getRewardByItemTable(info[i]);
        local iin = reward:getNodeAt(i-1)
        self.m_rewardInfo[200 + i] = info[i]
        if icon then
            icon:setAnchorPoint(ccp(0.5, 0.5))
            icon:setPosition(self.m_ticonbuttons[i]:getPosition())
            self.m_ticonbuttons[i]:getParent():addChild(icon, -1, 20)
            if name then
                local blabelName = game_util:createLabelBMFont({text = name})
                if count then
                    local blabelCount = game_util:createLabelBMFont({text = string.format("x %d", count), fontSize})
                    blabelCount:setAnchorPoint(ccp(0.5, 1))
                    blabelCount:setPosition(icon:getContentSize().width * 0.5, icon:getContentSize().height-35)
                    icon:addChild(blabelCount, 11)
                end
            end
        end
    end
    

    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            local tempPos = self.node_shouchong_bg:getParent():convertToNodeSpace(ccp(x,y));
            local touchInnerFlag = self.node_shouchong_bg:boundingBox():containsPoint(tempPos)
            if not touchInnerFlag then
                self:back()
            end
            return true;
        end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    -- 重置按鈕出米優先級 防止被阻止

    
    -- local vipLevel = game_data:getUserStatusDataByKey("vip") or 0
    -- if vipLevel > 0 then  -- 可以領取獎勵時 領取獎勵
    --     game_util:setCCControlButtonTitle(self.m_conbtn_getReward, "Nhận")
    --     local falsh_blindness = ccbNode:spriteForName("falsh_blindness")
    --     if falsh_blindness then falsh_blindness:setVisible(true) end
    --     falsh_blindness:runAction(game_util:createRepeatForeverFade());
    -- end

    -- self.m_scrollv_showInfo = ccbNode:scrollViewForName("m_scrollv_showInfo");
    -- -- 重置 scrollview 觸摸優先級  防止被吞意外收穫
    -- self.m_scrollv_showInfo:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    -- local nodeSprite = ccbNode:nodeForName("m_node_sprite")


    -- local character_detail_cfg = getConfig(game_config_field.character_detail);
    -- local wuKongCfg = character_detail_cfg:getNodeWithKey(tostring(32900));   --首冲显示角色
    -- local animation = wuKongCfg:getNodeWithKey("animation"):toStr();
    -- local rgb = wuKongCfg:getNodeWithKey("rgb_sort"):toInt();
    -- local tempIcon = game_util:createImgByName("image_" .. animation,rgb, true, true)
    -- -- tempIcon:setFlipX(true)
    -- tempIcon:setScale(1.4)
    -- tempIcon:setAnchorPoint(ccp(0.53, 0))

    -- nodeSprite:addChild(tempIcon)

    -- do
    --     local size = self.m_scrollv_showInfo:getContentSize()

    --     local ccbNode = luaCCBNode:create();
    --     ccbNode:registerFunctionWithFuncName("onMainBtnClick",onBtnClick);
    --     ccbNode:openCCBFile("ccb/ui_vipguide_shownode.ccbi");

    --     -- local showNode = CCNode:create()
    --     -- showNode:setContentSize(ccbNode:getContentSize())
    --     -- ccbNode:setAnchorPoint(ccp(0, 0))
    --     -- ccbNode:setPositionY(ccbNode:getContentSize().height)
    --     -- showNode:addChild(ccbNode)

    --     self.m_scrollv_showInfo:getContainer():removeAllChildrenWithCleanup(true);
    --     self.m_scrollv_showInfo:getContainer():addChild(ccbNode)
    --     self.m_scrollv_showInfo:setContentSize(ccbNode:getContentSize())
    --     self.m_scrollv_showInfo:setDirection(kCCScrollViewDirectionVertical)

    --     -- -- scroll 出現的時候顯示成頂端
    --     local offsetY = ccbNode:getContentSize().height - self.m_scrollv_showInfo:getViewSize().height
    --     -- print("offsetY = ", offsetY)
    --     self.m_scrollv_showInfo:setContentOffset(ccp(0, -offsetY), false)

    --               -- 圖標按鈕
    --     self.m_ticonbuttons = {}
    --     for i=1,5 do
    --         self.m_ticonbuttons[i] =  ccbNode:controlButtonForName("m_conbtn_icon" .. i)
    --         self.m_ticonbuttons[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    --         -- self.m_ticonbuttons[i]:setVisible(false);
    --     end


    --     local vipshop_cfg = getConfig(game_config_field.vip_shop)
    --     local gifts = vipshop_cfg:getNodeWithKey(tostring( 2 ))
    --     local need_cost = gifts:getNodeWithKey("need_coin"):toInt()  or 48
    --     local m_label_showcost = ccbNode:labelTTFForName("m_label_showcost")
    --     m_label_showcost:setString(tostring(need_cost))

    --     local reward = gifts:getNodeWithKey("reward")
    --     self.m_rewardInfo = {}
    --     local rewardCount = reward:getNodeCount();

    --     -- 卡片按鈕設置
    --     for i=1, rewardCount do
    --         local icon,name,count = game_util:getRewardByItem(reward:getNodeAt(i-1),false);
    --         local iin = reward:getNodeAt(i-1)
    --         self.m_rewardInfo[i] = json.decode(iin:getFormatBuffer())
    --         if icon then
    --             icon:setAnchorPoint(ccp(0.5, 1))
    --             icon:setPosition(self.m_ticonbuttons[i]:getPosition())
    --             self.m_ticonbuttons[i]:getParent():addChild(icon, -1, 20)
                
    --             if name then
    --                 local blabelName = game_util:createLabelBMFont({text = name})
    --                 blabelName:setAnchorPoint(ccp(0.5, 1))
    --                 blabelName:setPosition(icon:getContentSize().width * 0.5,  6)
    --                 icon:addChild(blabelName, 10)
    --                 if count then
    --                     local blabelCount = game_util:createLabelBMFont({text = string.format("x%d", count), fontSize})
    --                     blabelCount:setAnchorPoint(ccp(0.5, 1))
    --                     blabelCount:setPosition(icon:getContentSize().width * 0.5, blabelName:getPositionY() - blabelName:getContentSize().height)
    --                     icon:addChild(blabelCount, 11)
    --                 end
    --             end
    --         end
    --     end

    --     do
    --           -- 圖標按鈕
    --         self.m_ticonbuttons = {}
    --         for i=1,5 do
    --             self.m_ticonbuttons[i] =  ccbNode:controlButtonForName("m_conbtn_icon2" .. i)
    --             self.m_ticonbuttons[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    --             -- self.m_ticonbuttons[i]:setVisible(false);
    --         end

    --         local info = {{5, 32900, 1}, {7,10001,1}}

    --         for i=1, #info do
    --             local icon,name,count = game_util:getRewardByItemTable(info[i]);
    --             local iin = reward:getNodeAt(i-1)
    --             self.m_rewardInfo[200 + i] = info[i]
    --             if icon then
    --                 icon:setAnchorPoint(ccp(0.5, 1))
    --                 icon:setPosition(self.m_ticonbuttons[i]:getPosition())
    --                 self.m_ticonbuttons[i]:getParent():addChild(icon, -1, 20)
                    
    --                 if name then
    --                     local blabelName = game_util:createLabelBMFont({text = name})
    --                     blabelName:setAnchorPoint(ccp(0.5, 1))
    --                     blabelName:setPosition(icon:getContentSize().width * 0.5,  6)
    --                     icon:addChild(blabelName, 10)
    --                     if count then
    --                         local blabelCount = game_util:createLabelBMFont({text = string.format("x%d", count), fontSize})
    --                         blabelCount:setAnchorPoint(ccp(0.5, 1))
    --                         blabelCount:setPosition(icon:getContentSize().width * 0.5, blabelName:getPositionY() - blabelName:getContentSize().height)
    --                         icon:addChild(blabelCount, 11)
    --                     end
    --                 end
    --             end
    --             end

    --         end

    -- end
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_vipguide_pop.refreshUi(self)
    -- local level_giftCfg = getConfig(game_config_field.level_gift)
    -- local level = game_data:getUserStatusDataByKey("level")
    -- local levelGift = level_giftCfg:getNodeWithKey(tostring( self.m_tData.level ))
    -- local reward = levelGift:getNodeWithKey("reward")
    -- local cost = levelGift:getNodeWithKey("coin"):toInt()
    -- local des = levelGift:getNodeWithKey("des")
end
--[[--
    初始化
]]
function game_vipguide_pop.init(self,t_params)
    t_params = t_params or {}
end
--[[--
    創建ui入口並初始化數據
]]
function game_vipguide_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_vipguide_pop;
