---  幸运转盘
local game_homeLand_luckyTurn_pop = {
    m_root_layer = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_tGameData = nil,
    m_idTab = nil,

    btn_gacha = nil,
    btn_gacha_10 = nil,
    anim_node = nil,

    m_gachaAnimEndFlag = nil,
    m_delayTimeIndex = nil,
    m_mask_layer = nil,
    m_maxQuality = nil,
    m_maxQualityCardId = nil,
    m_ccbNode = nil,
    m_startFlag = nil,
    m_luckyTurntableRewardTab = nil,
    m_rotation_spri = nil,
    m_rewardTurntableType = nil,

    m_label_fenzuan = nil,
    m_label_num = nil,
    m_label_myNum = nil,
    m_label_coin = nil,
    m_label_refresh = nil,
    text_scroll2 = nil,
    content_node1 = nil,
    text_scroll1 = nil,
    content_node2 = nil,
    m_left = nil,
    m_cost = nil,

    m_cfg_homeland_roulette = nil,
};
--[[--
    销毁ui
]]
function game_homeLand_luckyTurn_pop.destroy(self)
    -- body
    cclog("----------------- game_homeLand_luckyTurn_pop destroy-----------------"); 
    self.m_root_layer = nil;
    self.m_popUi = nil;
    self.m_close_btn = nil;
    self.m_tGameData = nil;
    self.m_idTab = nil;

    self.left_time_node = nil;
    self.btn_gacha = nil;
    self.btn_gacha_10 = nil;
    self.anim_node = nil;

    self.m_gachaAnimEndFlag = nil;
    self.m_delayTimeIndex = nil;
    self.m_mask_layer = nil;
    self.m_maxQuality = nil;
    self.m_maxQualityCardId = nil;
    self.m_ccbNode = nil;
    self.m_startFlag = nil;
    self.m_luckyTurntableRewardTab = nil;
    self.m_rotation_spri = nil;
    self.m_rewardTurntableType = nil;

    self.m_label_fenzuan = nil;
    self.m_label_num = nil;
    self.m_label_myNum = nil;
    self.m_label_coin = nil;
    self.m_label_refresh = nil;

    self.text_scroll2 = nil;
    self.content_node1 = nil;
    self.text_scroll1 = nil;
    self.content_node2 = nil;
    self.m_left = nil;
    self.m_cost = nil;
    self.m_cfg_homeland_roulette = nil;
end

local rewardKeyTab = {action_point = 13,star = 14,food = 1,metal = 2,energy = 3,crystal = 4,coin = 9,
                      silver = 15,dirt_silver = 10,dirt_gold = 11,metalcore = 16,arena_point = 100,
                      grace = 17,grace_high = 18,adv_crystal = 20,wood = 31,soul_stone = 32,small_forge_stone = 33,
                      middle_forge_stone = 34,high_forge_stone = 35,pet_exp_ball = 26,pet_skill_stone = 27,equip_smelting = 28,
};
local rewardKeyTab2 = {cards = 5,item = 6,equip = 7,gem = 19,material = 29,medal = 30,soul = 36}

--[[--
    返回
]]
function game_homeLand_luckyTurn_pop.back(self,backType)
    game_scene:removePopByName("game_homeLand_luckyTurn_pop");
    -- local function endCallFunc()
    --     self:destroy();
    -- end
    -- game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_homeLand_luckyTurn_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 11 then--充值
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag == 12 then--查看详情

            local roulette_cfg = getConfig(game_config_field.roulette)
            local roulette_cfg_item = roulette_cfg:getNodeWithKey(tostring(self.m_tGameData.version))
            local active_msg = ""
            if roulette_cfg_item then
                active_msg = roulette_cfg_item:getNodeWithKey("instruction") and roulette_cfg_item:getNodeWithKey("instruction"):toStr()
            end
            game_scene:addPop("game_active_limit_detail_pop",{openMsg = active_msg})
            -- game_scene:addPop("game_active_limit_detail_pop",{openType = "game_homeLand_luckyTurn_pop",enterType = self.m_tGameData.version})
        elseif btnTag == 101 then--启动一次
            function responseMethod(tag,gameData)
                self.m_gachaAnimEndFlag = false;
                local pX,pY = tagNode:getPosition();
                local tempPos = tagNode:getParent():convertToWorldSpace(ccp(pX,pY))
                self.m_animStartPos = {x = tempPos.x,y = tempPos.y}
                local rewardRandom = ((self.m_tGameData.reward_index or 0) + 1)
                local rewardTab = self.m_tGameData.reward or {}
                if rewardTab[rewardRandom] then
                    self.m_rewardTurntableType = rewardTab[rewardRandom][1];
                end
                self.m_mask_layer:setTouchEnabled(true);
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:createRotationAnim("one");
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("hoemland_open_roulette"), http_request_method.GET, {},"hoemland_open_roulette")
        elseif btnTag == 102 then--启动10次
            function responseMethod(tag,gameData)
                self.m_gachaAnimEndFlag = false;
                local pX,pY = tagNode:getPosition();
                local tempPos = tagNode:getParent():convertToWorldSpace(ccp(pX,pY))
                self.m_animStartPos = {x = tempPos.x,y = tempPos.y}
                self.m_mask_layer:setTouchEnabled(true);
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:createRotationAnim("ten");
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("hoemland_open_roulette10"), http_request_method.GET, {},"hoemland_open_roulette10")
        elseif btnTag == 103 then--查看其他奖励
            game_scene:addPop("game_homeLand_luckyTurn_pop_reward_pop",{version = self.m_tGameData.version})
        elseif btnTag == 104 then--刷新
            function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi()
                game_util:addMoveTips({text = "Tạo mới thành công~"})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("hoemland_roulette_refresh"), http_request_method.GET, {},"hoemland_roulette_refresh")
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_homeLand_luckyTurn.ccbi");

    self.m_label_fenzuan = ccbNode:labelTTFForName("m_label_fenzuan");
    self.m_label_num = ccbNode:labelTTFForName("m_label_num");
    self.m_label_myNum = ccbNode:labelTTFForName("m_label_myNum");
    self.m_label_coin = ccbNode:labelTTFForName("m_label_coin");
    self.m_label_refresh = ccbNode:labelTTFForName("m_label_refresh")
    -- 光效 显示
    -- local falsh_blindness = ccbNode:spriteForName("falsh_blindness")
    -- falsh_blindness:runAction(game_util:createRepeatForeverFade());

    -- self.rank_node = ccbNode:nodeForName("rank_node");
    self.btn_gacha = ccbNode:controlButtonForName("m_btn_gacha");
    self.btn_gacha_10 = ccbNode:controlButtonForName("m_btn_gacha10");
    self.anim_node = ccbNode:nodeForName("anim_node");
    local m_btn_refresh = ccbNode:controlButtonForName("m_btn_refresh")
    m_btn_refresh:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
    self.m_mask_layer = ccbNode:layerColorForName("m_mask_layer");
    self.m_mask_layer:setOpacity(0);
    self.m_mask_layer:setVisible(true);
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_rotation_spri = ccbNode:spriteForName("m_rotation_spri")
    self.text_scroll1 = ccbNode:scrollViewForName("m_scroll_view_Secret1");
    self.text_scroll2 = ccbNode:scrollViewForName("m_scroll_view_Secret2");
    self.content_node1 = ccbNode:nodeForName("content_node1")
    self.content_node2 = ccbNode:nodeForName("content_node2")
    self.m_rotation_spri:setRotation(45+22.5);
    self.m_posIndex = 1;
    self.text_scroll1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    self.text_scroll2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    -- -- 本层阻止触摸传导下一层
    -- local function onTouch(eventType, x, y)     
    --     if eventType == "began" then 
    --         return true;  
    --     end 
    -- end
    -- self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    -- self.m_root_layer:setTouchEnabled(true);
    self:initLayerTouch(self.m_root_layer);
    -- 本层阻止触摸传导下一层
    local function onTouch2(eventType, x, y)     
        if eventType == "began" then 
            cclog("self.m_gachaAnimEndFlag === " .. tostring(self.m_gachaAnimEndFlag))
            if self.m_gachaAnimEndFlag == true then
                self.m_anim_node:removeAllChildrenWithCleanup(true);
                self.m_mask_layer:removeAllChildrenWithCleanup(true);
                self.m_mask_layer:setTouchEnabled(false);
                self.m_mask_layer:setOpacity(0);
                self:refreshUi()
            end
            return true;  
        end 
    end
    self.m_mask_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-6,true);
    self.m_mask_layer:setTouchEnabled(false);

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
    self.btn_gacha:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
    self.btn_gacha_10:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);

   
    -- game_util:setControlButtonTitleBMFont(m_other_reward_btn)
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

----------------------------------------------------------------------------------------------------------------------------------------------
--[[--
    创建
]]
function game_homeLand_luckyTurn_pop.createOneReward(self,rewardTab,rewardTurntableType)
    -- assert(false)
    local ccbNode,quality = nil,3;
    if rewardTab then
        local rewardType = rewardTab[1]
        cclog("rewardType ================== " .. rewardType)
        if rewardType == 5 then--卡牌
            local cardData,heroCfg = game_data:getCardDataById(tostring(rewardTab[2]));
            if heroCfg then
                quality = heroCfg:getNodeWithKey("quality"):toInt()
            end
            ccbNode = game_util:createHeroListItemByCCB(cardData);
        -- elseif rewardType == 6 then--道具
        --     local ccbNode = game_util:createItemsItem();
        --     if ccbNode then
        --         self.m_anim_node:addChild(ccbNode);
        --     end
        elseif rewardType == 7 then--装备
            local itemData,itemCfg = game_data:getEquipDataById(tostring(rewardTab[2]));
            if itemCfg then
                local quality = itemCfg:getNodeWithKey("quality"):toInt()
            end
            ccbNode = game_util:createEquipItemByCCB(itemData);
        elseif rewardType == 19 then--装备
            local itemData,itemCfg = game_data:getGemDataById(tostring(rewardTab[2]));
            if itemCfg then
                quality = itemCfg:getNodeWithKey("quality"):toInt()
            end
            ccbNode = game_util:createGemItemByCCB({c_id = rewardTab[2],count = rewardTab[3]});
        else
            quality = 3;
            ccbNode = game_util:createItemsItem();
            if ccbNode then
                local m_user_btn = ccbNode:controlButtonForName("m_user_btn")
                m_user_btn:setVisible(false);
                local iCountText = ccbNode:labelBMFontForName("m_count");
                local m_name = ccbNode:labelTTFForName("m_name");
                local m_imgNode = ccbNode:nodeForName("m_imgNode")
                local m_story_label = ccbNode:labelTTFForName("m_story_label")
                iCountText:setString(tostring("x1"));
                m_imgNode:removeAllChildrenWithCleanup(true);
                local icon,name,count = game_util:getRewardByItemTable(rewardTab,false)
                if icon then
                    m_imgNode:addChild(icon)
                end
                if name then
                    m_name:setString(name);
                else
                    m_name:setString("");
                end
                if count then
                    iCountText:setString(tostring("x" .. tostring(count)));
                end
            end
        end
        rewardTurntableType = rewardTurntableType or rewardTab[4]
        if rewardTurntableType and rewardTurntableType < 3 and ccbNode then
            local tempSize = ccbNode:getContentSize();
            local tempSpr = CCSprite:createWithSpriteFrameName("xyzp_xianding_wenzi.png");
            tempSpr:setPosition(ccp(tempSize.width*0.25, tempSize.height*0.9))
            ccbNode:addChild(tempSpr,10,10)
        end
    end
    return ccbNode,quality;
end

--[[--
    添加抽取好卡的动画
gacha_anim_1    蓝卡
daiji fanpai xunhuan

gacha_anim_2    紫卡
daiji daiji2 fanpai xunhuan

gacha_anim_3    橙卡
daiji daiji2 fanpai xunhuan
    一抽
]]
function game_homeLand_luckyTurn_pop.addOneAnim(self,quality)
    self:removeGachaAnim();
    -- quality = quality or 0;
    self.m_rewardTurntableType = self.m_rewardTurntableType or 3
    local animFile = "gacha_anim_1";
    if self.m_rewardTurntableType == 2 then
        animFile = "gacha_anim_2";
    elseif self.m_rewardTurntableType == 1 then
        animFile = "gacha_anim_3";
    end
    local m_iAnim = zcAnimNode:create(animFile .. ".swf.sam",0,animFile .. ".plist");
    local function animEnd(animNode,theId,lableName)
        if lableName == "daiji" then

        elseif lableName == "xunhuan" then
            animNode:playSection("xunhuan");
        elseif lableName == "fanpai" then
            game_sound:playUiSound("gacha")
            self.m_anim_node:setVisible(true);
            animNode:playSection("xunhuan");
            self.m_gachaAnimEndFlag = true;
        end
    end
    m_iAnim:registerScriptTapHandler(animEnd);
    m_iAnim:playSection("daiji");
    m_iAnim:setScale(1);
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    m_iAnim:setPosition(ccp(self.m_animStartPos.x, self.m_animStartPos.y))
    local function animEndCallFunc()
        m_iAnim:playSection("fanpai");
    end
    cclog("addGachaAnim ======================== " .. animFile);
    local animArr = CCArray:create();
    animArr:addObject(CCMoveTo:create(0.1,ccp(visibleSize.width*0.5, visibleSize.height*0.5)));
    animArr:addObject(CCCallFunc:create(animEndCallFunc));
    m_iAnim:runAction(CCSequence:create(animArr));
    -- m_iAnim:setPosition(ccp(visibleSize.width*0.5, visibleSize.height*0.5))
    -- game_scene:getPopContainer():addChild(m_iAnim,10,10);
    self.m_mask_layer:addChild(m_iAnim,10,10);
    self.m_gachaAnimTab[#self.m_gachaAnimTab+1] = m_iAnim
end
--[[
    十连抽
]]
function game_homeLand_luckyTurn_pop.addTenAnim(self,index,rewardTab)
    if index == 1 then
        self.m_delayTimeIndex = 0;
        self:removeGachaAnim();
    end
    local tempIndex = (index - 1) % 10 + 1
    if index > 1 and tempIndex == 1 then
        self.m_delayTimeIndex = 0;
        self:removeGachaAnim();
    end
    self.m_delayTimeIndex = self.m_delayTimeIndex + 1;
    local reward_count = #rewardTab;
    cclog2(rewardTab,"rewardTab --------")
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    local ccbNode,quality = self:createOneReward(rewardTab[index]);
    local rewardTurntableType = rewardTab[index][4]
    local animFile = "gacha_anim_1";
    quality = 1;
    if rewardTurntableType == 2 then
        quality = 4;
        animFile = "gacha_anim_2";
    elseif rewardTurntableType == 1 then
        animFile = "gacha_anim_3";
        quality = 4;
        game_sound:playUiSound("gacha")
    end
    local tempNode = CCNode:create();
    if ccbNode then
        ccbNode:setVisible(false);
        tempNode:addChild(ccbNode,100,100);
    end
    local m_iAnim = zcAnimNode:create(animFile .. ".swf.sam",0,animFile .. ".plist");
    local xunhuanCount = 1;
    local function animEnd(animNode,theId,lableName)
        if lableName == "daiji" then

        elseif lableName == "xunhuan" then
            xunhuanCount = xunhuanCount + 1;
            if xunhuanCount == 3 then
                animNode:playSection("daiji2");
                if tempIndex < 6 then
                    tempNode:runAction(CCMoveTo:create(0.1,ccp(visibleSize.width*(0.2*tempIndex - 0.1), visibleSize.height*0.75)))
                else
                    tempNode:runAction(CCMoveTo:create(0.1,ccp(visibleSize.width*(0.2*(tempIndex-5) - 0.1), visibleSize.height*0.25)))
                end
                index = index + 1;
                self.m_delayTimeIndex = 0;
                if index <= reward_count then
                    if index > 10 and tempIndex == 10 then
                        local function callback()
                            self:addTenAnim(index,rewardTab);
                        end
                        local animArr = CCArray:create();
                        animArr:addObject(CCDelayTime:create(2));
                        animArr:addObject(CCCallFunc:create(callback));
                        self.m_root_layer:runAction(CCSequence:create(animArr));
                    else
                        self:addTenAnim(index,rewardTab);
                    end
                else
                    self.m_gachaAnimEndFlag = true;
                end
            else
                animNode:playSection("xunhuan");
            end
        elseif lableName == "fanpai2" then
            if ccbNode then
                ccbNode:setVisible(true);
            end
            if quality > 3 then
                animNode:playSection("xunhuan");
            else
                animNode:playSection("daiji");
                if tempIndex < 6 then
                    tempNode:runAction(CCSpawn:createWithTwoActions(CCScaleTo:create(0.05,0.8),CCMoveTo:create(0.05,ccp(visibleSize.width*(0.2*tempIndex - 0.1), visibleSize.height*0.75))))
                else
                    tempNode:runAction(CCSpawn:createWithTwoActions(CCScaleTo:create(0.05,0.8),CCMoveTo:create(0.05,ccp(visibleSize.width*(0.2*(tempIndex-5) - 0.1), visibleSize.height*0.25))))
                end
            end
        end
    end
    m_iAnim:registerScriptTapHandler(animEnd);
    m_iAnim:playSection("daiji");
    tempNode:setPosition(ccp(self.m_animStartPos.x, self.m_animStartPos.y))
    local function animEndCallFunc()
        if quality > 3 then
        else
            index = index + 1;
            if index <= reward_count then
                if index > 10 and tempIndex == 10 then
                    local function callback()
                        self.m_mask_layer:reorderChild(tempNode,1)
                        self:addTenAnim(index,rewardTab);
                    end
                    local animArr = CCArray:create();
                    animArr:addObject(CCDelayTime:create(2));
                    animArr:addObject(CCCallFunc:create(callback));
                    self.m_root_layer:runAction(CCSequence:create(animArr));
                else
                    self:addTenAnim(index,rewardTab);
                end
            else
                self.m_gachaAnimEndFlag = true;
            end
        end
        m_iAnim:playSection("fanpai2");
    end
    cclog("addGachaAnim ======================== " .. animFile);
    local animArr = CCArray:create();
    animArr:addObject(CCDelayTime:create(0.01*self.m_delayTimeIndex));
    tempNode:setScale(0.8);
    animArr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.05,1),CCMoveTo:create(0.05,ccp(visibleSize.width*0.5, visibleSize.height*0.5))));
    animArr:addObject(CCCallFunc:create(animEndCallFunc));
    tempNode:runAction(CCSequence:create(animArr));
    tempNode:addChild(m_iAnim);
    self.m_mask_layer:addChild(tempNode,20+index,10);
    self.m_gachaAnimTab[#self.m_gachaAnimTab+1] = tempNode
end

--[[--
    移除抽取好卡的动画
]]
function game_homeLand_luckyTurn_pop.removeGachaAnim(self)
    self.m_mask_layer:removeAllChildrenWithCleanup(true);
    self.m_gachaAnimTab = {};
end

----------------------------------------------------------------------------------------------------------------------------------------------

--[[
    招募后刷新
]]
function game_homeLand_luckyTurn_pop.refreshLabel(self)
    --倒计时
    -- self.left_time_node:removeAllChildrenWithCleanup(true)
    -- local function timeEndFunc()
    --    self.left_time_node:removeAllChildrenWithCleanup(true)
    --    local tipsLabel = game_util:createLabelTTF({text = "已结束",color = ccc3(255,255,255),fontSize = 10});
    --     tipsLabel:setAnchorPoint(ccp(0.5,0.5))
    --     tipsLabel:setPosition(ccp(0,0))
    --     self.left_time_node:addChild(tipsLabel,10,12)
    -- end
    -- local countdownLabel = game_util:createCountdownLabel(tonumber(self.m_tGameData.remainder_time),timeEndFunc,8, 3);
    -- countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    -- countdownLabel:setPosition(ccp(0,0))
    -- self.left_time_node:addChild(countdownLabel,10,10)

    -- if tonumber(self.m_tGameData.remainder_time) <= 0 then
    --     countdownLabel:setTime(1)
    -- end
    local roulette_cfg = getConfig(game_config_field.homeland_roulette)
    local roulette_cfg_item = roulette_cfg:getNodeWithKey(tostring(self.m_tGameData.version))
    
    local cost1,cost10 = roulette_cfg_item:getNodeWithKey("price"):toInt(),roulette_cfg_item:getNodeWithKey("price_10"):toInt()
    self.m_label_fenzuan:setString("Đá Fancy của tôi:" .. tostring(game_data:getUserStatusDataByKey("pink_coin")))
    self.m_label_num:setString("Số lần rút:" .. self.m_tGameData.open_times)
    self.m_label_myNum:setString(tostring(cost1) .. "Đá Fancy")
    self.m_label_coin:setString(tostring(cost10) .. "Đá Fancy");
    local refresh_price = roulette_cfg_item:getNodeWithKey("refresh_price"):toInt()
    self.m_label_refresh:setString(tostring(refresh_price))

end
--[[

]]
function game_homeLand_luckyTurn_pop.createLuckyTurntableReward(self)
    self.anim_node:removeAllChildrenWithCleanup(true);
    self.m_luckyTurntableRewardTab = {};
    local tempSize = self.anim_node:getContentSize();
    local radius = tempSize.width*0.3;
    local tempValue = math.sqrt(radius*radius/2)
    cclog("radius == " .. radius .. " ; tempValue == " .. tempValue)
    -- local posTable = {{radius*0.9,radius*0.35},{radius*0.35,radius*0.9},{-radius*0.35,radius*0.9},{-radius*0.9,radius*0.35},
    --                   {-radius*0.9,-radius*0.35},{-radius*0.35,-radius*0.9},{radius*0.35,-radius*0.9},{radius*0.9,-radius*0.35}}
    local posTable = {
                      {-radius*0.9,-radius*0.35},{-radius*0.9,radius*0.35},{-radius*0.35,radius*0.9},{radius*0.35,radius*0.9},
                      {radius*0.9,radius*0.35},{radius*0.9,-radius*0.35},{radius*0.35,-radius*0.9},{-radius*0.35,-radius*0.9},
                    }

    local rewardTab = self.m_tGameData.reward or {};
    -- cclog2(rewardTab,"rewardTab =====")
    for index=1,math.min(8,#rewardTab) do
        local rewardItem = rewardTab[index]
        -- cclog2(rewardItem,"rewardItem  ===== ")
        local turntableRewardType = rewardItem[1]--1代表超级限时礼包,2代码限时礼包,3代表普通礼包
        local pX,pY = tempSize.width*0.5 + posTable[index][1], tempSize.height*0.5 + posTable[index][2]
        local icon,name,count = game_util:getRewardByItemTable(rewardItem[2],false)
        if icon then
            icon:setScale(0.55);
            -- icon:setPosition(ccp(pX,pY))
            icon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5))
            local sequence = CCSequence:createWithTwoActions(CCDelayTime:create(0.1*index), CCMoveTo:create(0.2,ccp(pX,pY)))
            icon:runAction(sequence)
            self.anim_node:addChild(icon)
            table.insert(self.m_luckyTurntableRewardTab,{parentNode = self.anim_node,rewardNode = icon,reward = rewardItem[2]})
            local tempIconSize = icon:getContentSize();
            if turntableRewardType == 1 or turntableRewardType == 2 then
                local tempSpr = CCSprite:createWithSpriteFrameName("public_faguang.png");
                tempSpr:setPosition(ccp(tempIconSize.width*0.5, tempIconSize.height*0.5))
                icon:addChild(tempSpr)
                -- local tempSpr = CCSprite:createWithSpriteFrameName("xyzp_xianding_wenzi.png");
                -- tempSpr:setPosition(ccp(tempIconSize.width*0.75, tempIconSize.height*0.9))
                -- icon:addChild(tempSpr,10,10)
            end
            if count then
                local tempLabel = game_util:createLabelTTF({text = "×" .. count,color = ccc3(255,255,255),fontSize = 12});
                tempLabel:setScale(1.25)
                tempLabel:setPosition(ccp(tempIconSize.width*0.5, 0))
                icon:addChild(tempLabel,100)
            end
        end
    end
end

--[[--
  
]]
function game_homeLand_luckyTurn_pop.initLayerTouch(self,formation_layer)
    local realPos = nil;
    local touchBeginPoint = nil;
    local touchMoveFlag = false;
    local function onTouchBegan(x, y)
        touchMoveFlag = false;
        touchBeginPoint = {x = x, y = y}
        return true
    end
    
    local function onTouchMoved(x, y)
        if touchMoveFlag == false and ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 then
            touchMoveFlag = true;
        end
    end
    
    local function onTouchEnded(x, y)
        if not touchMoveFlag then
            for k,v in pairs(self.m_luckyTurntableRewardTab) do
                realPos = v.parentNode:convertToNodeSpace(ccp(x,y));
                if v.rewardNode and v.rewardNode:boundingBox():containsPoint(realPos) then
                    game_util:lookItemDetal(v.reward)
                end
            end
        end
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
        elseif eventType == "moved" then
            return onTouchMoved(x, y)
        else
            return onTouchEnded(x, y)
        end
    end
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-4,true)
    formation_layer:setTouchEnabled(true)
end

--[[

]]
function game_homeLand_luckyTurn_pop.createRotationAnim(self,turntableType)
    if self.m_startFlag == true then
        return;
    end
    self.m_startFlag = true;
    local angle_value = 360/8
    local rewardRandom = ((self.m_tGameData.reward_index or 0) + 1)--math.random(1,8)
    cclog("rewardRandom = " .. rewardRandom .. " ; reward_index = " .. ((self.m_tGameData.reward_index or 0) + 1))
    local totalStep = 8*5+rewardRandom;
    local stepValue = 1;
    local decelerationCount = 4;
    local rotation = self.m_rotation_spri:getRotation();
    local posIndex = self.m_posIndex;
    local m_shared = 0;
    local dtime = 0;
    function tick( dt )        
        if posIndex > totalStep - decelerationCount and posIndex < totalStep then
            dtime = dtime + dt;
            if dtime > dt*2*(posIndex - totalStep + decelerationCount) then
                cclog("********************" .. (2*(posIndex - totalStep + decelerationCount)))
                dtime = 0;
                rotation = rotation + angle_value;
                self.m_rotation_spri:setRotation(rotation)
                posIndex = posIndex + 1;
            end
        elseif posIndex == totalStep then
            dtime = dtime + dt;
            if dtime > 1.0 then
                stepValue = 2;
            end
        else
            rotation = rotation + angle_value;
            self.m_rotation_spri:setRotation(rotation)
            posIndex = posIndex + 1;
        end
        if stepValue == 2 then
            self.m_posIndex = posIndex%8 == 0 and 8 or posIndex%8;
            scheduler.unschedule(m_shared)
            self.m_startFlag = false;
            self.m_mask_layer:setOpacity(200);
            self.m_anim_node:removeAllChildrenWithCleanup(true);
            self.m_anim_node:setVisible(false);
            if turntableType == "one" then
                local rewardTab = {};
                local gain_reward = self.m_tGameData.gain_reward or {}
                for k,v in pairs(rewardKeyTab) do
                    local tempValue = gain_reward[k]
                    if tempValue and tempValue > 0 then
                        table.insert(rewardTab,{v,0,tempValue})
                    end
                end
                for rewardKey,rewardType in pairs(rewardKeyTab2) do
                    local tempTab = gain_reward[rewardKey] or {}
                    if tempTab[1] then
                        table.insert(rewardTab,{rewardType,tempTab[1],1})
                    end
                end
                -- game_util:rewardTipsByDataTable(self.m_tGameData.gain_reward or {});
                if #rewardTab > 0 then
                    local rewardType = rewardTab[1][1]
                    if rewardType == 5 or rewardType == 7 or rewardType == 19 then
                        local ccbNode,quality = self:createOneReward(rewardTab[1],self.m_rewardTurntableType);
                        if ccbNode then
                            self.m_anim_node:addChild(ccbNode);
                        end                        
                        self:addOneAnim(quality);
                    else
                        local function callBackFunc()
                            self.m_mask_layer:setTouchEnabled(false);
                            self:refreshUi()
                        end
                        game_util:rewardTipsByDataTable(self.m_tGameData.gain_reward or {},callBackFunc);
                        self.m_mask_layer:setOpacity(0);
                    end
                else
                    local function callBackFunc()
                        self.m_mask_layer:setTouchEnabled(false);
                        self:refreshUi()
                    end
                    game_util:rewardTipsByDataTable(self.m_tGameData.gain_reward or {},callBackFunc);
                    self.m_mask_layer:setOpacity(0);
                end
            else
                local rewardTab = self.m_tGameData.gifts or {}
                -- cclog2(rewardTab," start  rewardTab -----")
                if #rewardTab > 0 then
                    self:addTenAnim(1,rewardTab);
                else
                    self.m_gachaAnimEndFlag = true;
                    self:refreshUi()
                end
            end
            -- self:refreshUi()
        end
    end
    m_shared = scheduler.schedule(tick, 1/60, false)
end

function game_homeLand_luckyTurn_pop.createLogs( self, parentNode, bigParentNode, logs)
    parentNode:getContainer():removeAllChildrenWithCleanup(true);
    local viewSize = bigParentNode:getContentSize()
    local contentText = ""
    -- local openMsg1 = self.m_tGameData.fight_log
    -- local fight_times = self.dispatch_item_cfg[tostring(self.m_select_index)].fight_times
    -- local openMsg = ""
    -- local openMsg_tab = {}
    -- local length = #openMsg1
    -- for k,v in pairs(openMsg1) do
    --     openMsg = openMsg .. v .. "\n"
    -- end
    contentText = logs

    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(169,0),textAlignment = kCCTextAlignmentLeft, verticalTextAlignment = kCCVerticalTextAlignmentCenter,fontSize = 9})
    local tempSize = tempLabel:getContentSize()
    parentNode:setContentSize(CCSizeMake(170,tempSize.height))
    parentNode:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    parentNode:setDirection(kCCScrollViewDirectionVertical)
    parentNode:addChild(tempLabel)
end


--[[--
    刷新
]]
-- function game_homeLand_luckyTurn_pop.refreshTableView(self)
--     self.rank_node:removeAllChildrenWithCleanup(true);
--     self.m_tableView = self:createTableView(self.rank_node:getContentSize());
--     self.m_tableView:setScrollBarVisible(true);
--     self.rank_node:addChild(self.m_tableView,10,10);
-- end

--[[
    刷新奖励
]]
function game_homeLand_luckyTurn_pop.refreshRewardTableView(self)
   -- self.reward_table_node:removeAllChildrenWithCleanup(true)
   -- local tempRewardTable = self:createRewardTabelView(self.reward_table_node:getContentSize());
   -- if tempRewardTable then self.reward_table_node:addChild(tempRewardTable,10,10) end
   -- self.reward_table_node2:removeAllChildrenWithCleanup(true)
   -- local tempRewardTable = self:createRewardTabelView2(self.reward_table_node2:getContentSize());
   -- if tempRewardTable then self.reward_table_node2:addChild(tempRewardTable,10,10) end
end
--[[--
    刷新ui
]]
function game_homeLand_luckyTurn_pop.refreshUi(self)
    -- self:refreshTableView();
    self:refreshLabel();
    self:createLuckyTurntableReward();
    local logs1,logs2 = "",""
    for i=1,game_util:getTableLen(self.m_tGameData.server_log) do
        local _,name = game_util:getRewardByItemTable(self.m_tGameData.server_log[i]["reward"][1])
        -- cclog2(i,"i ====== zjr -----")
        logs1 = logs1 .. "Chúc mừng" .. self.m_tGameData.server_log[i]["name"] .. "Được" .. name .. self.m_tGameData.server_log[i]["ts"] .. "\n"
    end
    for i=1,game_util:getTableLen(self.m_tGameData.self_log) do
        local _,name = game_util:getRewardByItemTable(self.m_tGameData.self_log[i]["reward"][1])
        logs2 = logs2 .. "Chúc mừng" .. self.m_tGameData.self_log[i]["name"] .. "Được" .. name .. self.m_tGameData.self_log[i]["ts"] .. "\n"
    end
    self:createLogs(self.text_scroll1,self.content_node1,logs1)
    self:createLogs(self.text_scroll2,self.content_node2,logs2)
end
--[[--
    初始化
]]
function game_homeLand_luckyTurn_pop.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_cfg_homeland_roulette = json.decode(getConfig(game_config_field.homeland_roulette):getFormatBuffer()) 

    self.m_gachaAnimEndFlag = false;
    self.m_startFlag = false;
    self.m_luckyTurntableRewardTab = {};
end
--[[--
    创建ui入口并初始化数据
]]
function game_homeLand_luckyTurn_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();

   
    return self.m_popUi;
end



return game_homeLand_luckyTurn_pop;
