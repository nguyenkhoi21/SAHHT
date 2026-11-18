--新大富翁路霸
local game_newRichMan_tyrant_pop = {
    m_tGameData = nil,
    m_label_curNum = nil,
    m_label_myNum = nil,
    m_btn_jump  = nil,
    m_func_callback = nil,
    m_node_play2 = nil,
    m_node_play1 = nil,
    m_tab_diceNode = nil,
    m_result = nil,
    m_animFlag = nil,
    m_node = nil,
    m_node_num = nil,
    mainSelf = nil,
};
--[[--
    销毁ui
]]
function game_newRichMan_tyrant_pop.destroy(self)
    cclog("-----------------game_newRichMan_tyrant_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_label_curNum = nil;
    self.m_label_myNum = nil;
    self.m_btn_jump = nil;
    self.m_func_callback = nil;
    self.m_node_play2 = nil;
    self.m_node_play1 = nil;
    self.m_tab_diceNode = nil;
    self.m_result = nil;
    self.m_animFlag = nil;
    self.m_node = nil;
    self.m_node_num = nil;
    self.mainSelf = nil;

end
--[[--
    返回
]]
function game_newRichMan_tyrant_pop.back(self,types)
    if self.m_func_callback then
        if self.m_result == "lose" then --输了
            self:m_func_callback(nil,true)
        else --赢了或者平了了
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_newRichMan_main",{gameData = gameData,reward = reward});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_index"), http_request_method.GET, nil,"monopoly_index")
        end
    end
    if self.mainSelf then
        self.mainSelf.m_animFlag = false
        self.mainSelf.m_tGameData.need_fight = self.m_tGameData.need_fight
        self.mainSelf.m_tGameData.need_donation = self.m_tGameData.need_donation
    end
    game_scene:removePopByName("game_newRichMan_tyrant_pop")
end
--[[--
    读取ccbi创建ui
]]
function game_newRichMan_tyrant_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if self.m_animFlag == true then
            return
        end
        -- cclog2(btnTag,"btnTag ==== ")
        if btnTag == 5 then--返回
            self:back();
        elseif btnTag == 101 then
            local function responseMethod(tag,gameData)
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                    self.m_result = self.m_tGameData.result
                    -- cclog2(self.m_result,"m_result ==== ")
                    
                    for i=1,3 do
                        local function animEndCallFunc( )
                            self.m_tab_diceNode[i]:setVisible(true)
                            cclog2(self.m_tGameData.slots[i],"self.m_tGameData.slots[i]-=-=-------")
                            self:createDiecAnim(self.m_tab_diceNode[i],self.m_tGameData.slots[i])
                        end 
                        -- self.m_tab_diceNode[i]:setVisible(false)
                        local animArr = CCArray:create()
                        animArr:addObject(CCMoveTo:create(0.01,ccp(self.m_tab_diceNode[i]:getPositionX(),self.m_tab_diceNode[i]:getPositionY())))
                        animArr:addObject(CCCallFunc:create(animEndCallFunc))
                        self.m_tab_diceNode[i]:runAction(CCSequence:create(animArr))
                    end
                    self.m_animFlag = true
                else
                    self.m_animFlag = false
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_slot_battle"), http_request_method.GET, nil,"monopoly_slot_battle",true,true)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_newRichMan_tyrant_pop.ccbi");
    self.m_label_curNum = ccbNode:labelTTFForName("m_label_curNum")
    self.m_label_myNum = ccbNode:labelTTFForName("m_label_myNum")
    self.m_btn_jump = ccbNode:controlButtonForName("m_btn_jump")
    local m_close_btn = ccbNode:controlButtonForName("m_btn_back")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_btn_jump:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_node_play2 = ccbNode:nodeForName("m_node_play2")
    self.m_node_play1 = ccbNode:nodeForName("m_node_play1")
    self.m_node_num = ccbNode:nodeForName("m_node_num")

    self.m_tab_diceNode = {}
    local diceNode = nil
    for i=1,3 do
        diceNode = ccbNode:nodeForName("m_node_anim" .. i)
        self.m_tab_diceNode[i] = diceNode
    end

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    m_root_layer:setTouchEnabled(true);
    self.m_node = ccbNode
    return ccbNode;
end

function game_newRichMan_tyrant_pop.createPlayerImg( self )
    local leftSprite = CCSprite:create("img/image_suolong.png");
    local rightSprite = CCSprite:create("img/image_nvdi.png");
    rightSprite:setScaleX(-1)
    self.m_node_play1:addChild(leftSprite)
    self.m_node_play2:addChild(rightSprite)
end

function game_newRichMan_tyrant_pop.createDiecAnim( self, parentNode, i, isFirst )
    parentNode:setVisible(true)
    parentNode:removeAllChildrenWithCleanup(true)
    local function RanimCallBack( animNode, theId, theLabelName )
        local parent = animNode:getParent()
        if theLabelName == "tou" then
            animNode:playSection("daiji" .. i) 
        elseif theLabelName == "diao" then
            animNode:playSection("daiji" .. i) 
        elseif theLabelName == "daiji" .. i then
            animNode:playSection(tostring(i))
        else
            parentNode:setVisible(true)
            if isFirst then
            elseif i == self.m_tGameData.slots[3] then
                local num = 0
                if self.m_tGameData.slots then
                    for k,v in pairs(self.m_tGameData.slots) do
                        num = v + num
                    end
                    self:addMoveTips({text = tostring(num)})
                end
            end
        end
    end
    local z_zjrAnim = game_util:createAnimEffect("touzi","touzi",RanimCallBack,nil,true);
    if z_zjrAnim then
        local tempsize = parentNode:getContentSize()
        local animName = "tou"
        if isFirst then
            animName = "daiji" .. i
        else
            animName = "diao"
        end
        z_zjrAnim:playSection(animName)
        parentNode:addChild(z_zjrAnim,10,10)
    end
end
--[[
    设置图片数字
]]
function game_newRichMan_tyrant_pop.createNumIcon(self,num,node)
    num = tonumber(num)
    node:removeAllChildrenWithCleanup(true);
    if num >= 10 and num < 100 then
        local high = math.floor(num / 10)
        local low = math.floor(num % 10)

        local num_1 = CCSprite:createWithSpriteFrameName("vip_num_" .. high .. ".png")
        local num_2 = CCSprite:createWithSpriteFrameName("vip_num_" .. low .. ".png")

        num_1:setAnchorPoint(ccp(0.5,0.5))
        num_2:setAnchorPoint(ccp(0.5,0.5))

        num_1:setPosition(ccp(-2,0))
        num_2:setPosition(ccp(10,0))

        node:addChild(num_1,10)
        node:addChild(num_2,10)
    elseif num >= 100 then
        local table = {1,0,0}
        local x = math.floor(num / 100)
        local y = math.floor((num - x*100) / 10)
        local z = num - x*100 - y*10
        table[1] = x
        table[2] = y
        table[3] = z
        for i=1,3 do
            local num_sprite = CCSprite:createWithSpriteFrameName("vip_num_" .. table[i] .. ".png")
            num_sprite:setAnchorPoint(ccp(0.5,0.5))
            num_sprite:setPosition(ccp(-15+(i-1)*20,0))
            node:addChild(num_sprite,10)
        end
    else
        local num_sprite = CCSprite:createWithSpriteFrameName("vip_num_" .. num .. ".png")
        num_sprite:setAnchorPoint(ccp(0.5,0.5))
        num_sprite:setPosition(ccp(5,0))
        node:addChild(num_sprite,10)
    end
end
function game_newRichMan_tyrant_pop.addMoveTips(self,t_params)
    t_params = t_params or {};
    t_params.text = t_params.text or ""
    local winSize = CCDirector:sharedDirector():getWinSize();
    local tempnode = luaCCBNode:create()
    tempnode:setPosition(ccp(winSize.width*0.5, winSize.height*0.55))
    self:createNumIcon(tonumber(t_params.text),tempnode)
    local function remove_node( node )
        self.m_animFlag = false

        self:refrehLabel()
        node:removeFromParentAndCleanup(true);
        if self.m_result == "win" or self.m_result == "draw" then
            self:createAlearts()
        elseif self.m_result == "lose" then --输了
            self:back()
        end
    end
    local remove = CCCallFuncN:create(remove_node);
    local arr = CCArray:create();
    arr:addObject(CCEaseIn:create(CCMoveTo:create(1,ccp(winSize.width*0.5,winSize.height*0.7)),5));
    arr:addObject(CCDelayTime:create(1));
    arr:addObject(remove);
    tempnode:runAction(CCSequence:create(arr));
    self.m_node:addChild(tempnode,999999,9999999)
end
function game_newRichMan_tyrant_pop.createAlearts( self )
    local msg = "Bạn đã đánh thắng Lộ Bá, và trở thành Lộ Bá mới ở đây"
    if self.m_result == "win" then
    else
        msg = "Bạn và Lộ Bá hòa nhau, có thể đi qua đây"
    end
    local t_params = 
    {
        title = "Nhắc nhở",
        okBtnCallBack = function(target,event)
            require("game_ui.game_pop_up_box").close();
            self:back()
        end,   --可缺省
        closeCallBack = function(target,event)
            require("game_ui.game_pop_up_box").close();
            self:back()
        end,
        okBtnText = "Xác nhận", 
        text = msg,--"很遗憾，您未能挑战成功，需要捐献" .. count .. name .. "来膜拜此地块占领玩家 ，否则要等待十分钟",      --可缺省
    }
    require("game_ui.game_pop_up_box").show(t_params);
end
function game_newRichMan_tyrant_pop.refrehLabel( self )
    local myNum,curNum = 0,0
    if self.m_tGameData.slots then
        for k,v in pairs(self.m_tGameData.slots) do
            myNum = v + myNum
        end
    end
    if self.m_tGameData.building_info and self.m_tGameData.building_info.slot_info and next(self.m_tGameData.building_info.slot_info[2]) then
        for k,v in pairs(self.m_tGameData.building_info.slot_info[2]) do
            curNum = v + curNum
        end
    end
    if myNum == 0 then
        self.m_label_myNum:setVisible(false)
    else
        self:createNumIcon(myNum,self.m_node_num) 
        self.m_label_myNum:setVisible(false)
    end
    if curNum == 0 then
        self.m_label_curNum:setVisible(false)
    else
        self.m_label_curNum:setVisible(true)
    end
    self.m_label_myNum:setString(tostring(myNum))
    self.m_label_curNum:setString("Điểm Lôi Chủ:" .. tostring(curNum))
end
--[[--
    刷新ui
]]
function game_newRichMan_tyrant_pop.refreshUi(self)
    self:createPlayerImg()
    for i=1,3 do
        self:createDiecAnim(self.m_tab_diceNode[i],6,true)
    end
    self:refrehLabel()
end
--[[--
    初始化
]]
function game_newRichMan_tyrant_pop.init(self,t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_vip.plist")
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    if t_params.popCallBack then
        self.m_func_callback = t_params.popCallBack
    end
    if t_params.mainSelf then
        self.mainSelf = t_params.mainSelf
    end
    self.m_animFlag = false
end
--[[--
    创建ui入口并初始化数据
]]
function game_newRichMan_tyrant_pop.create(self,t_params)
    self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi();

    return  m_popUi;
end
return game_newRichMan_tyrant_pop;