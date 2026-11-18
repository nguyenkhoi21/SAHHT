--
-- Author: fan.xia
-- Date: 2019-03-27 10:16:50
--
local game_shooting = {
	m_root_layer = nil,
    m_ccbNode = nil,
    m_bulletTab = nil,
    m_beganPos = nil,
    m_speed = nil,
    root_node = nil,
    m_shared = nil,
    m_animGun = nil,
    m_scoreMax = nil,
    m_huanbg = nil,
    m_dank = nil,
    m_scoreVer_txt = nil,
    m_layerColor = nil,
    mb_start = nil,
    m_shop_btn = nil,
    m_back_btn = nil,
    m_bulletNember = nil,
    m_shared2 = nil,
    m_btn_buchong = nil,
}

-- 8个方向
game_shooting.eDirection = {
    None = 0,
    U = 1,
    UR = 2,
    R = 3,
    DR = 4,
    D = 5,
    DL = 6,
    L = 7,
    UL = 8
}

game_shooting.eSpeed = {
    grade1 = 2,
    grade2 = 3,
    grade3 = 4
}

--[[--
    销毁
]]
function game_shooting.destroy(self)
    -- body
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_bulletTab = nil;
    self.m_beganPos = nil;
    self.m_speed = nil;
    self.root_node = nil;
    self.m_shared = nil;
    self.m_animGun = nil;
    self.m_scoreMax = nil;
    self.m_huanbg = nil;
    self.m_dank = nil;
    self.m_scoreVer_txt = nil;
    self.m_layerColor = nil;
    self.mb_start = nil;
    self.m_shop_btn = nil;
    self.m_back_btn = nil;
    self.m_bulletNember = nil;
    self.m_shared2 = nil;
    self.m_btn_buchong = nil;
end

--[[--
    返回
]]
function game_shooting.back(self,type)
    --回到activity
    if self.m_shared ~= 0 then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
    end
    if self.m_shared ~= 0 then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared2)
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = nil},{endCallFunc = function (  )
                self:destroy();
            end});
end

function game_shooting.createUi(self)
   local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 2 then
            if self.m_shared ~= 0 then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
            end
            if self.m_shared2 ~= 0 then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared2)
            end
            function responseMethod( tag,gameData )
                game_scene:enterGameUi("game_shooting_shop",{gameData = gameData})
                self:destroy();
            end
            local params = {}
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_shot_shop_index"), http_request_method.GET, params,"god_shot_shop_index")
        elseif btnTag == 3 then
            local extra_num = self.m_data.extra_num
            local max_num = self:getExtraNum() -- 最大次数
            if self.m_data.remain_num <= 0 then
                if extra_num + 1 <= max_num then 
                    game_util:addMoveTips({text = "Click vào Plus để mua thêm"})
                    return
                else
                    require("game_ui.game_pop_up_box").showAlertView("Số lần tham gia đã đạt tối đa")
                    return
                end
            end
            self:updataUI()
            self.m_btn_buchong:setVisible(false)
            self.m_start_btn:setVisible(false)
            self.m_back_btn:setVisible(false)
            self.m_shop_btn:setVisible(false)
            self.m_yuneb:setVisible(false)
            self.m_gun:setVisible(false)
            self.m_yunumber_txt:setVisible(false)
            self:createAnimianGun()

            local time = self:getShotTime()
            function tick( dt )
                time = time - 1
                if time <= 0 then
                    if self.m_shared ~= 0 then
                        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
                    end
                    if self.m_shared2 ~= 0 then
                        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared2)
                    end
                   
                    local function responseMethod(tag,gameData)
                        local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                        game_scene:addPop("game_shooting_pop",{data = data});
                    end
                    local params = {}
                    params.scores = self.m_scoreMax
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_shot_add_score"), http_request_method.GET, params,"god_shot_add_score")
                end
                self.m_time_txt:setString(time)
            end

            self.m_shared2 = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1 , false)
        elseif btnTag == 110 then 
            local extra_num = self.m_data.extra_num
            local max_num = self:getExtraNum() -- 最大次数
            if extra_num + 1 > max_num then 
                game_util:addMoveTips({text = "Không có số lần mua"})
                return
            end
            local function responseBuyMethod(tag,gameData1)
                game_util:closeAlertView();
                function shopOpenResponseMethod(tag,gameData)
                    game_scene:enterGameUi("game_shooting",{gameData = gameData}) 
                    game_util:addMoveTips({text = "Số lần+1"});
                end
                network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("god_shot_index"), http_request_method.GET, {},"channel_active_recharge_index")
            end
            local name,num = self:getNeedItemNameAndNum()
            local str = string.format( "Cần phải tiêu thụ%s%s cho lần mua này, bạn có chắc chắn về việc mua không?",num,name)
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    local params = {};
                    network.sendHttpRequest(responseBuyMethod,game_url.getUrlForKey("god_shot_exchange"), http_request_method.GET, params,"god_shot_exchange")
                end,   --可缺省
                okBtnText = "Xác định",       --可缺省
                cancelBtnText = "Hủy",
                text = str,
            }
            game_util:openAlertView(t_params);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_shooting.ccbi");

    self.m_ccbNode = ccbNode

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_layerColor = ccbNode:layerForName("m_layerColor")
    self.root_node = ccbNode:nodeForName("root_node")
    self.m_target = ccbNode:spriteForName("m_target")
    self.m_sight = ccbNode:spriteForName("m_sight")
    self.m_gun = ccbNode:spriteForName("m_gun")
    self.m_yuneb = ccbNode:spriteForName("m_yuneb")
    self.m_huanbg = ccbNode:spriteForName("m_huanbg")
    self.m_dank = ccbNode:spriteForName("m_dank")
    self.m_yunumber_txt = ccbNode:labelTTFForName("m_yunumber_txt")
    self.m_score_txt = ccbNode:labelTTFForName("m_score_txt")
    self.m_time_txt = ccbNode:labelTTFForName("m_time_txt")
    self.m_bulletnember_txt = ccbNode:labelTTFForName("m_bulletnember_txt")
    self.m_start_btn = ccbNode:controlButtonForName("m_start_btn")
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_shop_btn = ccbNode:controlButtonForName("m_shop_btn")
    self.m_shop_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_scoreVer_txt = ccbNode:labelBMFontForName("m_scoreVer_txt");
    self.m_btn_buchong = ccbNode:controlButtonForName("btn_buchong")
    self.m_btn_buchong:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)

    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScale(resolution_config:getScale())

    local layer = tolua.cast(self.m_layerColor,"CCSprite");
    layer:setOpacity(0)
    for i=1,5 do
        local bullet = ccbNode:spriteForName("m_bullet_"..i)
        table.insert(self.m_bulletTab,bullet)
    end

    return ccbNode
end

function game_shooting.initMaterialLayerTouch(self)
    local function onTouch(eventType, x, y)
        
        if eventType == "began" then
            if self.mb_start then
                return true
            end
            self.m_beganPos = ccp(x,y)
            self:updata(ccp(x,y),false)
            return true;
        elseif eventType == "moved" then
            if self.mb_start then
                return true
            end
            local speed = math.sqrt(math.pow((y-self.m_beganPos.y),2)+math.pow((x-self.m_beganPos.x),2))
            if speed < 50 then
                self.m_speed = self.eSpeed.grade1
            elseif speed > 50 and speed <150 then
                self.m_speed = self.eSpeed.grade2
            else
                self.m_speed = self.eSpeed.grade3
            end

            self:updata(ccp(x,y),true)
        else
            if self.mb_start then
                self:start()
                return
            end
            self:updata(ccp(x,y),false)
            self:createAnimian()
        end
    end

    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,false);
    self.m_root_layer:setTouchEnabled(true);
end

function game_shooting.createAnimian(self)
    self.m_root_layer:setTouchEnabled(false);
    local x,y = self.m_sight:getPosition()
    local animFile = "shenshe_zidan"
    local m_iAnim = zcAnimNode:create(animFile .. ".swf.sam",0,animFile .. ".plist");
    local function animEnd(animNode,theId,lableName)
        self:settlement()
    end
    m_iAnim:registerScriptTapHandler(animEnd);
    m_iAnim:playSection("zidanjiemian");
    m_iAnim:setScale(1);
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    m_iAnim:setPosition(ccp(x+25, y-45))
   
    self.root_node:addChild(m_iAnim,10,10)
end

function game_shooting.start( self )
    self.mb_start = false
    self.m_root_layer:setTouchEnabled(false)
    local layer = tolua.cast(self.m_layerColor,"CCSprite");
    layer:setOpacity(0)
    self.m_dank:setVisible(false)
    self.m_huanbg:setVisible(false)
    self.m_sight:setVisible(true)
    self:createAnimianGun()
end

function game_shooting.settlement( self )
    local score = 0
    self.m_root_layer:setTouchEnabled(true);
    local x,y = self.m_sight:getPosition()
    self.m_sight:setPosition(-100,-100)
    self.m_sight:setVisible(false)
    local px,py = self.m_target:getPosition()
    local node = self.root_node:getChildByTag(10)
    node:removeFromParentAndCleanup(true)

    local node = self.root_node:getChildByTag(9)
    node:removeFromParentAndCleanup(true)
    self.m_animGun = nil

    local speed = math.sqrt(math.pow((y-py),2)+math.pow((x-px),2))
    
    if speed > 0 and speed < 10 then
        score = 10
    elseif speed >= 10 and speed < 16 then
        score = 8
    elseif speed >= 16 and speed < 27 then
       score = 6
    elseif speed >= 27 and speed < 34 then
       score = 4
    elseif speed >= 34 and speed < 45 then
       score = 2
    else
        score = 0
    end
    
    self.m_scoreMax = self.m_scoreMax + score
    self.m_bulletNember = self.m_bulletNember - 1
    self.m_score_txt:setString(self.m_scoreMax)
    self.m_bulletnember_txt:setString(self.m_bulletNember)
    local layer = tolua.cast(self.m_layerColor,"CCSprite");
    layer:setOpacity(200)
    self.m_dank:setVisible(true)
    self.m_huanbg:setVisible(true)
    self.m_scoreVer_txt:setString(score)
    self.m_dank:setPosition(x,y)

    local count = 5 - self.m_bulletNember
    for i=1,count do
        local node = self.m_bulletTab[i]
        node:setVisible(false)
    end

    self.mb_start = true

    if self.m_bulletNember <= 0 then
        if self.m_shared ~= 0 then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
        end
        if self.m_shared ~= 0 then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared2)
        end
        
        local function responseMethod(tag,gameData)
            local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) 
            game_scene:addPop("game_shooting_pop",{data = data});
        end
        local params = {}
        params.scores = self.m_scoreMax
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_shot_add_score"), http_request_method.GET, params,"god_shot_add_score")
        return
    end
end

function game_shooting.createAnimianGun(self)
    local animFile = "shenshe_qiang"
    local visibleSize = CCDirector:sharedDirector():getWinSize();
    self.m_animGun = zcAnimNode:create(animFile .. ".swf.sam",0,animFile .. ".plist");
    local function animEnd(animNode,theId,lableName)
        self.m_sight:setPosition(visibleSize.width*0.5+82,visibleSize.height*0.2-5)
        self:initMaterialLayerTouch()
    end
    self.m_animGun:registerScriptTapHandler(animEnd);
    self.m_animGun:playSection("qiang");
    self.m_animGun:setScale(1);

    self.m_animGun:setPosition(ccp(visibleSize.width*0.5+80, visibleSize.height*0.4))
   
    self.root_node:addChild(self.m_animGun,10,9)

    
end

-- 数据更新
function game_shooting.UpdateData(self,touchPos, isMove)
    local direction = self.eDirection.None
    local angle = 0
    local isNeedUpdate = false

    -- 按下 或 弹起 记录触摸点
    if not isMove then
        self._downPos = touchPos
    else -- 移动 更新角度
        isNeedUpdate = true
    end

    if isNeedUpdate then
        if self._downPos ~= nil and touchPos ~= nil then
            local centerPos = self._downPos
            -- 弧度 然后转 角度
            local radians = ccpToAngle(ccpSub(touchPos, centerPos))
            -- angle = radians*57.29577951 -- ((__ANGLE__) * 57.29577951f) // PI * 180 CC_RADIANS_TO_DEGREES
            angle = math.deg(radians)
            direction = self:AngleToDirection(angle)
        else
            print("downPos or touchPos is nil!")
        end
    end

    return direction, angle
end

function game_shooting.isMove(self,x,y)
    local size = CCDirector:sharedDirector():getVisibleSize()
    if x < 50 then
        return false
    end
    if x > size.width -50 then
        return false
    end
    if y < 50 then
        return false
    end
    if y > size.height - 50 then
        return false
    end

    return true
end

-- 角度转方向
function game_shooting.AngleToDirection(self,angle)
    local direction = self.eDirection.None
    if angle > -22.5 and angle <= 22.5 then
        direction = self.eDirection.R
    elseif angle > 22.5 and angle <= 67.5 then
        direction = self.eDirection.DR
    elseif angle > 67.5 and angle <= 112.5 then
        direction = self.eDirection.D
    elseif angle > 112.5 and angle <= 157.5 then
        direction = self.eDirection.DL
    elseif angle > 157.5 or angle <= -157.5 then  -- 特殊
        direction = self.eDirection.L
    elseif angle > -157.5 and angle <= -112.5 then
        direction = self.eDirection.UL
    elseif angle > -112.5 and angle <= -67.5 then
        direction = self.eDirection.U
    elseif angle > -67.5 and angle <= -22.5 then
        direction = self.eDirection.UR
    end

    return direction
end

function game_shooting.updata(self, touchPos, isMove)
    local direction, angle = self:UpdateData(touchPos, isMove)
    self.m_direction = direction
end

function game_shooting.updataUI(self)
    local size = CCDirector:sharedDirector():getVisibleSize()
    function tick( dt )
        local speedXY = self.m_speed*0.6
        --cclog(self.m_direction,"self.m_direction")
        if self.m_direction == self.eDirection.U then
            local posX,posY = self.m_sight:getPosition()
            local gunX,gunY = self.m_animGun:getPosition()
            if posY > 50 then
                self.m_sight:setPositionY(posY-self.m_speed)
                self.m_animGun:setPositionY(gunY-self.m_speed*0.1)
            end
        elseif self.m_direction == self.eDirection.UR then
            local posX,posY = self.m_sight:getPosition()
            local gunX,gunY = self.m_animGun:getPosition()
            if posX < size.width - 50 and posY > 50 then
                local pX = posX + speedXY
                local pY = posY - speedXY
                local gX = gunX + speedXY
                local gY = gunY - speedXY*0.1
                self.m_sight:setPosition(pX,pY) 
                self.m_animGun:setPosition(ccp(gX,gY))
            end
        elseif self.m_direction == self.eDirection.R then
            local posX,posY = self.m_sight:getPosition()
            local gunX,gunY = self.m_animGun:getPosition()
            if posX < size.width - 50 then
                self.m_sight:setPositionX(posX+self.m_speed)
                self.m_animGun:setPositionX(gunX+self.m_speed)
            end
        elseif self.m_direction == self.eDirection.DR then
            local posX,posY = self.m_sight:getPosition()
            local gunX,gunY = self.m_animGun:getPosition()
            local pX = posX + speedXY
            local pY = posY + speedXY
            local gX = gunX + speedXY
            local gY = gunY + speedXY*0.1
            if posX < size.width -50 and posY < size.height - 50 then
                self.m_sight:setPosition(pX,pY)
                self.m_animGun:setPosition(ccp(gX,gY))
            end
        elseif self.m_direction == self.eDirection.D then
            local posX,posY = self.m_sight:getPosition()
            local gunX,gunY = self.m_animGun:getPosition()
            if posY < size.height - 50 then
                self.m_sight:setPositionY(posY+self.m_speed)
                self.m_animGun:setPositionY(gunY+self.m_speed*0.1)
            end
        elseif self.m_direction == self.eDirection.DL then
            local posX,posY = self.m_sight:getPosition()
            local gunX,gunY = self.m_animGun:getPosition()
            if posX > 50 and posY < size.height - 50 then
                local pX = posX - speedXY
                local pY = posY + speedXY
                local gX = gunX - speedXY
                local gY = gunY + speedXY*0.1
                self.m_sight:setPosition(pX,pY)
                self.m_animGun:setPosition(ccp(gX,gY))
            end
        elseif self.m_direction == self.eDirection.L then
            local posX,posY = self.m_sight:getPosition()
            local gunX,gunY = self.m_animGun:getPosition()
            if posX > 50 then
                self.m_sight:setPositionX(posX-self.m_speed)   
                self.m_animGun:setPositionX(gunX-self.m_speed)  
            end
        elseif self.m_direction == self.eDirection.UL then
            local posX,posY = self.m_sight:getPosition()
            local gunX,gunY = self.m_animGun:getPosition()
            if posX > 50 and posY > 50 then
                local pX = posX - speedXY
                local pY = posY - speedXY
                local gX = gunX - speedXY
                local gY = gunY - speedXY*0.1
                self.m_sight:setPosition(pX,pY)
                self.m_animGun:setPosition(ccp(gX,gY))
            end
        end
    end

    self.m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0.01 , false)
    
end

--[[
    获取最大购买次数
]]
function game_shooting.getExtraNum( self )
    local shot = getConfig(game_config_field.shot)
    shot = json.decode(shot:getFormatBuffer())
     local version = self.m_data.version
    local cfg = shot[tostring(version)]
    return cfg.extra_num or 0
end

--[[
    获取消耗道具的名称 数量
]]
function game_shooting.getShotTime( self )
    local shot = getConfig(game_config_field.shot)
    shot = json.decode(shot:getFormatBuffer())
    local version = self.m_data.version
    local cfg = shot[tostring(version)]
    return cfg.time
end

--[[
    获取当前次数消耗
]]
function game_shooting.getNeedItem( self )
    local shot = getConfig(game_config_field.shot)
    shot = json.decode(shot:getFormatBuffer())
    local version = self.m_data.version
    local cfg = shot[tostring(version)]
    need_item = cfg.need_item

    local max_num = self:getExtraNum()
    local extra_num = self.m_data.extra_num
    if extra_num + 1 > max_num then
        return
    else
        return need_item[extra_num + 1]
    end
end

--[[
    获取消耗道具的名称 数量
]]
function game_shooting.getNeedItemNameAndNum( self )
    local item = self:getNeedItem()
    local icon,name,count = game_util:getRewardByItemTable(item);
    return name, count
end

function game_shooting.refreshUi(self)
    self.m_bulletnember_txt:setString(self.m_bulletNember)
    self.m_yunumber_txt:setString("Số lần còn："..self.m_data.remain_num) --剩余次数：

    local max_num = self:getExtraNum() -- 最大次数
    local extra_num = self.m_data.extra_num  -- 已兑换次数

    if self.m_data.remain_num == 0 then
        self.m_btn_buchong:setColor(ccc3(255, 255, 255));
        self.m_btn_buchong:setEnabled(true);
    else
        self.m_btn_buchong:setColor(ccc3(155, 155, 155));
        self.m_btn_buchong:setEnabled(false);
    end

end

function game_shooting.init(self,t_params)
    self.m_data = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
    self.m_bulletTab = {}
    self.m_speed = 0
    self.m_scoreMax = 0
    self.m_shared = 0;
    self.m_shared2 = 0
    self.m_bulletNember = 5
    self.mb_start = false
    self.m_direction = self.eDirection.None
end

--[[--
    创建ui入口并初始化数据
]]--
function game_shooting.create(self,t_params)
   cclog("----- game_shooting create --------")
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();

    return rootScene
end

return game_shooting