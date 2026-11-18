--- 聚宝盆
local game_cornucopia_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_sprite_jindutiaoBg = nil,
    m_label_myScore = nil,
    m_label_des = nil,
    m_label_all = nil,
    m_node_screen = nil,
    m_node_screen2 = nil,
    m_node_screenRight = nil,
    m_node_screenRight2 = nil,
    m_curShowScreenInfo = nil,
    m_curShowScreenInfoRight = nil,
    m_tab_icon = nil,
    cfg_bowl_reward = nil,
    m_select_sort = nil,
    m_tGameData = nil,
    m_node_icon = nil,
    m_tab_btn = nil,
    m_animFlag = nil,
    m_sprite_btnLight = nil,
    m_sprite_bigLight = nil,
    m_btn_shit = nil,
    m_curCfg = nil,
};
--[[--
    销毁
]]
function game_cornucopia_pop.destroy(self)
    -- body
    cclog("-----------------game_cornucopia_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_sprite_jindutiaoBg = nil;
    self.m_label_myScore = nil;
    self.m_label_des = nil;
    self.m_node_screen = nil;
    self.m_node_screen2 = nil;
    self.m_node_screenRight = nil;
    self.m_node_screenRight2 = nil;
    self.m_curShowScreenInfo = nil;
    self.m_curShowScreenInfoRight = nil;
    self.m_tab_icon = nil;
    self.cfg_bowl_reward = nil;
    self.m_select_sort = nil;
    self.m_tGameData = nil;
    self.m_node_icon = nil;
    self.m_tab_btn = nil;
    self.m_animFlag = nil;
    self.m_sprite_btnLight = nil;
    self.m_sprite_bigLight = nil;
    self.m_btn_shit = nil;
    self.m_curCfg = nil;
end
--[[--
    返回
]]
function game_cornucopia_pop.back(self,type)
    game_scene:removePopByName("game_cornucopia_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_cornucopia_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog2(btnTag,"btnTag === ")
        if self.m_animFlag then
            return
        end
        if btnTag == 1 then
            self:back()
        elseif btnTag > 100 and btnTag < 104 then
            self.m_select_sort = btnTag - 100
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi()
                local posX,posY = self.m_tab_btn[self.m_select_sort]:getPosition()
                self.m_sprite_btnLight:setPosition(ccp(posX+15,posY+15))
                if self.m_select_sort> 2 then
                    self.m_sprite_bigLight:setVisible(true)
                else
                    self.m_sprite_bigLight:setVisible(false)
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("bowl_index"), http_request_method.GET, {sort = self.m_select_sort},"bowl_index")
        elseif btnTag == 104 then
            local cfg = getConfig(game_config_field.bowl)
            local msg = cfg:getNodeWithKey(tostring(self.m_tGameData.version)):getNodeWithKey("notice"):toStr()
            game_scene:addPop("game_active_limit_detail_pop",{openMsg = msg})
        elseif btnTag == 105 then --去充值
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                --game_scene:addPop("ui_vip_show_pop")

            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag == 106 then
            self:createMyRecord()
        elseif btnTag == 107 then
            self:createServerRecord()
        elseif btnTag == 201 then --抽一次
            self:choiceFunc(1)
        elseif btnTag == 202 then
            self:choiceFunc(10)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_game_cornucopia_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.m_sprite_jindutiaoBg = ccbNode:spriteForName("m_sprite_jindutiaoBg")
    self.m_label_myScore = ccbNode:labelTTFForName("m_label_myScore")
    self.m_label_des = ccbNode:labelTTFForName("m_label_des")
    self.m_label_all = ccbNode:labelTTFForName("m_label_all")
    self.m_node_screen = ccbNode:nodeForName("m_node_screen1")
    self.m_node_screen2 = ccbNode:nodeForName("m_node_screen2")
    self.m_node_screenRight = ccbNode:nodeForName("m_node_screenRight1")
    self.m_node_screenRight2 = ccbNode:nodeForName("m_node_screenRight2")
    self.m_node_icon = ccbNode:nodeForName("m_node_icon")
    self.m_sprite_btnLight = ccbNode:spriteForName("m_sprite_btnLight");
    self.m_sprite_bigLight = ccbNode:spriteForName("m_sprite_bigLight");
    self.m_sprite_bigLight:setVisible(false)
    local blendFunc = self.m_sprite_btnLight:getBlendFunc();
    blendFunc.src = GL_SRC_ALPHA;
    blendFunc.dst = GL_ONE;
    self.m_sprite_btnLight:setBlendFunc(blendFunc);

    self.m_tab_btn = {}
    for i=1,9 do
        local btn = ccbNode:controlButtonForName("m_btn_" .. i)
        btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
        self.m_tab_btn[i] = btn

    end
    self.m_tab_btn[9]:setVisible(false)
    for i=1,10 do
        local sprite_kuang = ccbNode:spriteForName("m_icon_sp" .. i)
        self.m_tab_icon[i] = sprite_kuang
    end
    local posX,posY = self.m_tab_btn[1]:getPosition()
    self.m_sprite_btnLight:setPosition(ccp(posX+15,posY+15))

    self.m_btn_shit = ccbNode:controlButtonForName("m_btn_shit")
    self.m_btn_shit:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)    
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    self:createServerRecord()
    self:createMyRecord()
    self.m_btn_shit:setOpacity(0)

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
function game_cornucopia_pop.choiceFunc( self,num )
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        if num == 1 then
            self:startAnim()
        elseif num == 10 then
           self:tenAnim()
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("bowl_choice"), http_request_method.GET, {num = num,sort = self.m_select_sort},"bowl_choice")
end
function game_cornucopia_pop.tenAnim( self )
    local function tempEndCallBack(  )
        local function popCallBack( num )
            self:choiceFunc(num)
        end 
        game_scene:addPop("game_cornucopia_reward_pop",{sort = 10,rewardTab = self.m_tGameData.gifts,popCallBack = popCallBack})
        self:refreshUi()
    end
    local tempParticle = game_util:createCocosParticleSystemQuad({name = "fireworks"});
    if tempParticle then
        game_util:addMoveAndRemoveAction({node = tempParticle,startNode = self.m_label_des,endNode = self.m_node_icon,endCallFunc = tempEndCallBack,moveTime = 0.3,delayTime = 1.5})
        game_scene:getPopContainer():addChild(tempParticle)
    end
end
function game_cornucopia_pop.startAnim( self )
    self.m_animFlag = true
    local rewardIndex = self.m_tGameData.index
    self.m_node_icon:removeChildByTag(666,true)
    local m_scale9sprite_select = nil
    local iconSize = self.m_tab_icon[1]:getContentSize()
    local startPosX,startPosY = self.m_tab_icon[1]:getPosition()
    m_scale9sprite_select = CCScale9Sprite:createWithSpriteFrameName("public_light.png");
    self.m_node_icon:addChild(m_scale9sprite_select,10,666)
    m_scale9sprite_select:setPosition(ccp(startPosX,startPosY))
    m_scale9sprite_select:setScale(1.5)
    local delayTime = 0 --光圈转动的延迟时间
    -- math.randomseed(os.time())
    -- local random_num = math.random(1,10)
    local needStep = rewardIndex + 30 --需要走的步数
    local totalStep = 1 --当前走的步数
    local curPos = 1-- 当前位置

    local delayFlag = true
    local m_shared = 0
    function tick( dt )   
        if totalStep < needStep and delayFlag then
            delayFlag = false
            totalStep = totalStep + 1 
            curPos = curPos + 1
            curPos = curPos - (math.floor(curPos/10) * 10)
            local posIndex = curPos 
            if posIndex == 0 then
                posIndex = 10
            end
            local function callBackFunc(  )
                delayFlag = true
                local posX,posY = self.m_tab_icon[posIndex]:getPosition()
                m_scale9sprite_select:setPosition(ccp(posX,posY))
            end 
            local animArr = CCArray:create()
            local xishu = 0.009
            if totalStep > 19 then
                xishu = 0.005
            elseif totalStep > 9 then
                xishu = 0.007
            end
            delayTime = delayTime + xishu
            local delayAnim = CCDelayTime:create(delayTime)
            animArr:addObject(delayAnim)
            animArr:addObject(CCCallFunc:create(callBackFunc))
            m_scale9sprite_select:runAction(CCSequence:create(animArr))
            
        elseif totalStep == needStep then
            self.m_animFlag = false
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);
            self:refreshUi()
            local function popCallBack( num )
                self:choiceFunc(num)
            end 
            game_scene:addPop("game_cornucopia_reward_pop",{sort = 1,rewardTab = self.m_tGameData.gifts,popCallBack = popCallBack})
        else

        end
      
    end

    m_shared = scheduler.schedule(tick, 1/75, false)
end
function game_cornucopia_pop.refreshLabel( self )
    local myScore = self.m_tGameData.score
    self.m_label_myScore:setString("Tích điểm của tôi:" .. myScore)
    local cost = self.m_curCfg[tostring(self.m_select_sort)].need_score1
    self.m_label_des:setString("Rút-1 tiêu hao" .. cost .. "Tích điểm")
    local limitTime = self.m_curCfg[tostring(self.m_select_sort)].limit_time
    local current_score = limitTime - self.m_tGameData.server_choice_times 
    self.m_label_all:setString("Số lần còn:" .. current_score)
end
--[[--
    设置进度条
]]
function game_cornucopia_pop.setProgress( self )
    local expBg = self.m_sprite_jindutiaoBg
    local expBgSize = expBg:getContentSize(); 
    local limitTime = self.m_curCfg[tostring(self.m_select_sort)].limit_time

    local current_score = limitTime - self.m_tGameData.server_choice_times 
    local score_max = limitTime--self.m_tGameData.code_coin or 200
    local percentage = current_score/score_max * 100  
    local params = {}
    params.percentage = percentage
    params.fileName = "ui_cornucopia_jindutiao2.png"
    local expBarAdd = game_util:createProgressTimer(params)
    expBg:removeAllChildrenWithCleanup(true)
    expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
    expBg:addChild(expBarAdd,2,1);
end

function game_cornucopia_pop.getCurRewardCfg( self )
    local curRewardCfg = {}
    for k,v in pairs(self.cfg_bowl_reward) do
        if tonumber(v.version) == tonumber(self.m_tGameData.version) then
            curRewardCfg[tostring(v.sort)] = v
        end
    end
    return curRewardCfg
end
function game_cornucopia_pop.createRewardIcon( self )
    local rewardTab = self.m_curCfg[tostring(self.m_select_sort)].reward

    function createButton( tag,parentNode )
        local function onBtnCilck( event,target )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            game_util:lookItemDetal(rewardTab[btnTag])
            
        end
        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        button:setZoomOnTouchDown(false)
        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY)
        button:setPosition(ccp(20,17));
        button:setOpacity(0)
        button:setScale(0.7)
        button:setTag(tag)
        parentNode:addChild(button,11);

    end
    for i=1,10 do

        self.m_tab_icon[i]:removeAllChildrenWithCleanup(true)
        local icon, _, count = game_util:getRewardByItemTable(rewardTab[i])
        local ttf = game_util:createLabelTTF({text = "×" .. count,color = ccc3(255,255,255),fontSize = 12});
        local size = icon:getContentSize()
        ttf:setAnchorPoint(ccp(1,0))
        ttf:setPosition(ccp(size.width -4,1))
        icon:addChild(ttf)
        icon:setScale(0.6)
        icon:setAnchorPoint(ccp(0,0))
        icon:setPosition(ccp(3.5,3.5))
        if icon then
            self.m_tab_icon[i]:addChild(icon)
        end
        createButton(i,self.m_tab_icon[i])
    end

end
--[[
    详情
]]
function game_cornucopia_pop.createServerRecord( self )
    local viewSize = self.m_node_screen:getContentSize()
    self.m_node_screen2:stopAllActions()
    self.m_node_screen:stopAllActions()
    self.m_node_screen:removeChildByTag(998, true)
    self.m_node_screen2:removeAllChildrenWithCleanup(true)
    if self.m_curShowScreenInfo then
        self.m_curShowScreenInfo = false
    else
        self.m_curShowScreenInfo = true
    end
    local isFull = self.m_curShowScreenInfo

    local bgNode = CCNode:create()
    bgNode:setContentSize(viewSize)
    self.m_node_screen:addChild(bgNode,2,998);

    local sprTitle = CCSprite:createWithSpriteFrameName("ui_cornucopia_arrow.png")
    sprTitle:setPosition(viewSize.width * 0.5, viewSize.height * 0.2 + sprTitle:getContentSize().height * 0.5  + 2 )
    bgNode:addChild(sprTitle)
    sprTitle:setScaleY(1)

    if isFull then
        sprTitle:setPosition(ccp(viewSize.width * 0.5, viewSize.height * 1 + sprTitle:getContentSize().height * 0.5 - 2  ))
        sprTitle:setScaleY(-1)
    end

    local time = 0.5
  
    local tempBg = CCScale9Sprite:createWithSpriteFrameName("public_9_32X32.png")

    local posX,posY = self.m_btn_shit:getPosition()

    if isFull then
        self.m_btn_shit:setPosition(ccp(posX,posY + 148))
        self.m_tab_btn[8]:setTouchEnabled(false)
        tempBg:setContentSize(CCSizeMake(viewSize.width , viewSize.height * 1))
    else
        self.m_btn_shit:setPosition(ccp(153,-88))
        self.m_tab_btn[8]:setTouchEnabled(true)
        tempBg:setContentSize(CCSizeMake(viewSize.width , viewSize.height * 0.2))
    end

    tempBg:setPosition(viewSize.width * 0.5, 0)
    tempBg:setAnchorPoint(ccp(0.5, 0))
    bgNode:addChild(tempBg)

    local screen2Size = self.m_node_screen2:getContentSize()
    local msgViewSize = nil
    if isFull then
        msgViewSize = screen2Size
    else
        msgViewSize = CCSizeMake(screen2Size.width, screen2Size.height * 0.2)
    end
    local scrollView = CCScrollView:create(msgViewSize)
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:getContainer():removeAllChildrenWithCleanup(true)
    scrollView:setTouchEnabled(false)

    local msg = ""
    local server_record = self.m_tGameData.server_record
    for i=1,#server_record do
        msg = msg .. server_record[i] .. "\n"
    end
    -- if isFull then
    local node, msgLabel = self:createScrollLabel(CCSizeMake(msgViewSize.width, msgViewSize.height - 5), {text = msg}, GLOBAL_TOUCH_PRIORITY - 2)
    if node then self.m_node_screen2:addChild(node,3) end
end

function game_cornucopia_pop.createMyRecord( self )
    local viewSize = self.m_node_screenRight:getContentSize()
    self.m_node_screenRight2:stopAllActions()
    self.m_node_screenRight:stopAllActions()
    self.m_node_screenRight:removeChildByTag(998, true)
    self.m_node_screenRight2:removeAllChildrenWithCleanup(true)
    if self.m_curShowScreenInfoRight then
        self.m_curShowScreenInfoRight = false
    else
        self.m_curShowScreenInfoRight = true
    end
    local isFull = self.m_curShowScreenInfoRight

    local bgNode = CCNode:create()
    bgNode:setContentSize(viewSize)
    self.m_node_screenRight:addChild(bgNode, 2, 998);

    local time = 0.5
  
    local tempBg = CCScale9Sprite:createWithSpriteFrameName("public_9_32X32.png")

    if isFull then
        tempBg:setVisible(true)
        self.m_btn_shit:setVisible(false)
        tempBg:setContentSize(CCSizeMake(viewSize.width, viewSize.height * 1))
    else
        self.m_btn_shit:setVisible(true)

        tempBg:setVisible(false)
        tempBg:setContentSize(CCSizeMake(viewSize.width * 0 , viewSize.height * 1))
    end

    tempBg:setPosition(viewSize.width * 0.5, 0)
    tempBg:setAnchorPoint(ccp(0.5, 0))
    bgNode:addChild(tempBg)

    local screen2Size = self.m_node_screenRight2:getContentSize()
    local msgViewSize = nil
    if isFull then
        msgViewSize = screen2Size
        self.m_tab_btn[8]:setVisible(false)
        self.m_tab_btn[9]:setVisible(true)
    else
        self.m_tab_btn[8]:setVisible(true)
        self.m_tab_btn[9]:setVisible(false)
        msgViewSize = CCSizeMake(screen2Size.width*0, screen2Size.height * 1)
    end
    local scrollView = CCScrollView:create(msgViewSize)
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:getContainer():removeAllChildrenWithCleanup(true)
    scrollView:setTouchEnabled(false)

    local msg = ""
    local my_record = self.m_tGameData.self_recod
    for i=1,#my_record do
        msg = msg .. my_record[i] .. "\n"
    end
    -- if isFull then
    local node, msgLabel = self:createScrollLabel(CCSizeMake(msgViewSize.width, msgViewSize.height - 5), {text = msg}, GLOBAL_TOUCH_PRIORITY - 2)
    if node then self.m_node_screenRight2:addChild(node,3) end
end

function game_cornucopia_pop.createScrollLabel( self, boardSize, params, touchPriority  )
    params = params or {}
    if not boardSize then return end
    local scrollView = CCScrollView:create(boardSize)
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:getContainer():removeAllChildrenWithCleanup(true)
    scrollView:setTouchEnabled(true)
    if touchPriority then scrollView:setTouchPriority(touchPriority  ) end
    local text = params.text or ""
    local tempLabel = game_util:createRichLabelTTF({text = text,dimensions = CCSizeMake(boardSize.width  ,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(255,255,255),fontSize = 10})
    local tempSize = tempLabel:getContentSize();
    tempLabel:setAnchorPoint(ccp(0, 0.99))
    tempLabel:setPosition(ccp(0, 0))
    scrollView:setContentSize(CCSizeMake(boardSize.width + 15, tempSize.height))
    scrollView:setContentOffset(ccp(0, boardSize.height - tempSize.height), false)
    scrollView:setPosition(ccp(2, 2))
    scrollView:addChild(tempLabel, 0, 998)
    return scrollView, tempLabel
end
--[[--
    刷新ui
]]
function game_cornucopia_pop.refreshUi(self)
    self:createRewardIcon()
    self:setProgress()
    self:refreshLabel()
    self.m_node_icon:removeChildByTag(667, true)
    if self.m_select_sort > 1 then
        local function onAnimSectionEnd1(animNode, theId,theLabelName)
            animNode:playSection(theLabelName)
        end
        local anim = game_util:createBlenderAnim("biankuanghuoyan", 1, true);
        game_anim:playSection(anim, "impact");
        anim:registerScriptTapHandler(onAnimSectionEnd1)
        anim:setPosition(ccp(0,-4))
        self.m_node_icon:addChild(anim,66,667)
    end
end
--[[--
    初始化
]]
function game_cornucopia_pop.init(self,t_params)
    self.cfg_bowl_reward = json.decode(getConfig(game_config_field.bowl_reward):getFormatBuffer()) 
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_curShowScreenInfo = true
    self.m_curShowScreenInfoRight = true
    self.m_select_sort = 1
    self.m_tab_icon = {}
    self.m_curCfg = self:getCurRewardCfg()
end
--[[--
    创建ui入口并初始化数据
]]
function game_cornucopia_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_cornucopia_pop;