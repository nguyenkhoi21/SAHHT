--新大富翁赌场
local game_newRichMan_gamble_pop = {
    m_tGameData = nil,

    m_select_index = nil,
    m_sprite_animLeft = nil,
    m_sprite_animRight = nil,
    m_sprite_Win1 = nil,
    m_sprite_Win2 = nil,
    m_label_times = nil,
    m_label_des1 = nil,
    m_label_des2 = nil,
    m_label_rewardNum = nil,
    m_tab_btn = nil,
    m_node_play2 = nil,
    m_node_play1 = nil,
    m_node_reward = nil,
    m_btn_sure  = nil,
    m_shared = nil,
    m_shared2 = nil,
    m_node_timeDown = nil,
    m_sprite_vs = nil,
    m_animFlag = nil,
    m_func_callback = nil,
    m_allNum = nil,

};
--[[--
    销毁ui
]]
function game_newRichMan_gamble_pop.destroy(self)
    -- body
    cclog("-----------------game_newRichMan_gamble_pop destroy-----------------");
    self.m_tGameData = nil;

    self.m_select_index = nil;
    self.m_sprite_animLeft = nil;
    self.m_sprite_animRight = nil;
    self.m_sprite_Win1 = nil;
    self.m_sprite_Win2 = nil;
    self.m_label_times = nil;
    self.m_label_des1 = nil;
    self.m_label_des2 = nil;
    self.m_label_rewardNum = nil;
    self.m_tab_btn = nil;
    self.m_node_play2 = nil;
    self.m_node_play1 = nil;
    self.m_node_reward = nil;
    self.m_btn_sure = nil;
    self.m_shared = nil;
    self.m_shared2 = nil;
    self.m_node_timeDown = nil;
    self.m_sprite_vs = nil;
    self.m_animFlag = nil;
    self.m_func_callback = nil;
    self.m_allNum = nil;
end
--[[--
    返回
]]
function game_newRichMan_gamble_pop.back(self,types, allNum)
    local function createAlertView( self, message, isOnly )
        local t_params = 
        {
          title = string_config.m_title_prompt,
          okBtnCallBack = function(target,event)
              if self.m_func_callback then
                local  reward = {}
                if isOnly then
                    reward = self.m_tGameData.reward
                    self:m_func_callback(self.m_tGameData.reward)
                else
                    local function responseMethod(tag,gameData)
                        self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                        local reward = nil;
                        if self.m_tGameData.reward then
                            reward = self.m_tGameData.reward
                            game_util:rewardTipsByDataTable(self.m_tGameData.reward)

                        end
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_give_up_guessing"), http_request_method.GET, nil,"monopoly_give_up_guessing")
                self:m_func_callback(reward)
                end
              end
              game_util:closeAlertView();
              self:m_func_callback(reward)
              game_scene:removePopByName("game_newRichMan_gamble_pop")
          end,   --可缺省
          closeCallBack = function(target,event)
             if isOnly then
                if self.m_func_callback then
                    -- cclog2(self.m_tGameData.reward,"---------2-------")
                    -- game_util:rewardTipsByDataTable(self.m_tGameData.reward)
                    self:m_func_callback(self.m_tGameData.reward)
                end
                game_scene:removePopByName("game_newRichMan_gamble_pop")
             end
              game_util:closeAlertView();
          end,

          okBtnText = string_config.m_btn_sure,       --可缺省
          cancelBtnText = string_config.m_btn_cancel,
          text = message,      --可缺省
           onlyOneBtn = isOnly,
          touchPriority = GLOBAL_TOUCH_PRIORITY-2,

        }
              game_util:openAlertView(t_params);
    end
    if types then
        local message = "Rất tiếc bạn chưa vượt ải xong, chỉ nhận được một số phần quà"
        createAlertView(self, message, true)
    
    elseif self.m_tGameData.reward and next(self.m_tGameData.reward) then
        local message = "Bạn đã nhận hết quà"
        createAlertView(self, message, true)
    else --提前终止
        local message = "Bạn đang ở: Vòng" .. self.m_tGameData.guessing_win_times .. ", từ bỏ chỉ nhận được một số phần quà, xác nhận?"
        createAlertView(self, message, false)
    end
    -- local function endCallFunc()
    --     self:destroy();
    -- end
    -- game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_newRichMan_gamble_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if self.m_animFlag == true then
            return
        end
        cclog2(btnTag,"btnTag ==== ")
        if btnTag == 5 then--返回
            self:back();
        elseif btnTag == 4 then
        elseif btnTag > 0 and btnTag < 4 then --奖励展示
            for i=1,3 do
                game_util:setCCControlButtonBackground(self.m_tab_btn[i].btn,"ui_newRichMan_selectDi.png")
                self.m_tab_btn[i].btn:setPreferredSize(CCSizeMake(43.5,45))
            end
            game_util:setCCControlButtonBackground(self.m_tab_btn[btnTag].btn,"ui_newRichMan_select.png")
            self.m_tab_btn[btnTag].btn:setPreferredSize(CCSizeMake(49.5,49.5))
            self.m_select_index = btnTag
            local params = {}
            params.num = btnTag

            local function responseMethod(tag,gameData)
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                    self:refreshSpriteStatus()
                    self.m_animFlag = true
                    self:createTimeDownAnim()
                else
                    self.m_animFlag = false
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_finger_guessing"), http_request_method.GET, params,"monopoly_finger_guessing",true,true)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_newRichMan_gamble_pop.ccbi");
    self.m_sprite_vs = ccbNode:spriteForName("m_sprite_vs")
    self.m_sprite_animLeft = ccbNode:spriteForName("m_sprite_animLeft")
    self.m_sprite_animRight = ccbNode:spriteForName("m_sprite_animRight")
    self.m_sprite_Win1 = ccbNode:spriteForName("m_sprite_Win1")
    self.m_sprite_Win2 = ccbNode:spriteForName("m_sprite_Win2")
    self.m_label_times = ccbNode:labelTTFForName("m_label_times")
    self.m_label_des1 = ccbNode:labelTTFForName("m_label_des1")
    self.m_label_des2 = ccbNode:labelTTFForName("m_label_des2")
    self.m_label_rewardNum = ccbNode:labelTTFForName("m_label_rewardNum")
    self.m_btn_sure = ccbNode:controlButtonForName("m_btn_sure")
    self.m_node_play2 = ccbNode:nodeForName("m_node_play2")
    self.m_node_play1 = ccbNode:nodeForName("m_node_play1")
    self.m_node_reward = ccbNode:nodeForName("m_node_reward")
    self.m_node_timeDown = ccbNode:nodeForName("m_node_timeDown")
    local m_close_btn = ccbNode:controlButtonForName("m_btn_back")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_btn_sure:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_btn_sure:setVisible(false)

    self.m_tab_btn = {}
    local btn = nil
    for i=1,3 do
        btn = ccbNode:controlButtonForName("m_btn_" .. i)
        btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
        self.m_tab_btn[i] = {btn = btn}
    end

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

function game_newRichMan_gamble_pop.getRewardNum( self, count, isGiveUp)
    for i=1,self.m_tGameData.guessing_win_times do
        count = count + count
    end
    if isGiveUp then
        count = count * 0.5
    else
    end
    -- cclog2(count,"count --- ")
    return count
end

function game_newRichMan_gamble_pop.createTimeDownAnim( self )
    local num = 2
    local function animLoop( i )
        local function animCallBack( spriteNum  )
            spriteNum:setVisible(false)
        end
        self.m_node_timeDown:removeAllChildrenWithCleanup(true)
        local spriteNum = CCSprite:createWithSpriteFrameName("vip_num_" .. i .. ".png")
        self.m_node_timeDown:addChild(spriteNum)
        local x,y = spriteNum:getPosition()
        local arrAnim = CCArray:create()
        local fadeOut = (CCFadeOut:create(0.9))
        local moveTo = (CCMoveTo:create(0.9,ccp(x,y+20)))
        local spawn = CCSpawn:createWithTwoActions(fadeOut,moveTo)
        arrAnim:addObject(spawn)
        arrAnim:addObject(CCCallFuncN:create(animCallBack))

        spriteNum:runAction(CCSequence:create(arrAnim))
    end
    self.m_shared2 = 0;
    function tick( dt )

        if num > 0 then
            animLoop(num)
        else
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared2);
            self.m_sprite_vs:setVisible(true)
            self:createAnim()
        end
        num = num - 1
    end
    animLoop(3)
    m_shared2 = scheduler.schedule(tick, 1, false)
   
end
--[[
    猜拳动画
]]
function game_newRichMan_gamble_pop.createAnim( self )
    self.m_sprite_animLeft:setVisible(true)
    self.m_sprite_animRight:setVisible(true)
    self.m_shared = 0;
    local times = 23
    function tick( dt )
        times = times - 1
        local spriteNameIndex = times%3 + 1
        self.m_sprite_animLeft:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_newRichMan_" .. spriteNameIndex .. ".png"))
        self.m_sprite_animRight:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_newRichMan_" .. spriteNameIndex .. ".png"))
        if times <= 0 then
            local sys_num = self.m_tGameData.sys_num
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared);
            self.m_sprite_animLeft:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_newRichMan_" .. self.m_select_index .. ".png"))
            self.m_sprite_animRight:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_newRichMan_" .. sys_num .. ".png"))
            self:refreshLabel()
            local winFlag = self.m_tGameData.result
            -- cclog2(self.m_tGameData,"mm ------ ")
            self:refreshSpriteStatus(winFlag)
        end
    end
        
    self.m_shared = scheduler.schedule(tick, 1/10, false)
end

function game_newRichMan_gamble_pop.createPlayerImg( self )
    local leftSprite = CCSprite:create("img/image_changee.png");
    local rightSprite = CCSprite:create("img/image_houyi.png");
    rightSprite:setScaleX(-1)
    self.m_node_play1:addChild(leftSprite)
    self.m_node_play2:addChild(rightSprite)
end
function game_newRichMan_gamble_pop.refreshSpriteStatus( self, winFlag )
    self.m_sprite_Win1:setVisible(false)
    self.m_sprite_Win2:setVisible(false)
    self.m_sprite_animLeft:setVisible(false)
    self.m_sprite_animRight:setVisible(false)
    self.m_sprite_vs:setVisible(false)

    self.m_allNum = 0
    if winFlag then
        self.m_sprite_animLeft:setVisible(true)
        self.m_sprite_animRight:setVisible(true)
        -- self.m_sprite_vs:setVisible(true)
        if winFlag == "win" then
            if next(self.m_tGameData.reward) then
                self:back()
               
            else
                self.m_sprite_Win1:setVisible(true)
                self.m_sprite_Win2:setVisible(false)

                local function animEndCallFunc(  )
                    delay = nil
                    local t_params = 
                    {
                      title = string_config.m_title_prompt,
                      okBtnCallBack = function(target,event)
                          game_util:closeAlertView();
                          self:refreshLabel()
                          self:refreshSpriteStatus()
                          
                      end,   --可缺省
                      okBtnText = string_config.m_btn_sure,       --可缺省
                      text = "Bạn đã thắng vòng này, nhấp OK bắt đầu vòng sau",      --可缺省
                       onlyOneBtn = true,
                      touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                      closeCallBack = function(target,event)
                          game_util:closeAlertView();
                          self:refreshLabel()
                          self:refreshSpriteStatus()
                      end,

                    }
                    game_util:openAlertView(t_params);
                end
                local delay = luaCCBNode:create()
                local animArr = CCArray:create()
                animArr:addObject(CCDelayTime:create(0.5))
                animArr:addObject(CCCallFunc:create(animEndCallFunc))
                delay:runAction(CCSequence:create(animArr))
                self.m_sprite_animRight:addChild(delay)
                self.m_allNum = self.m_tGameData.guessing_win_times
                for i=1,3 do
                    game_util:setCCControlButtonBackground(self.m_tab_btn[i].btn,"ui_newRichMan_selectDi.png")
                    self.m_tab_btn[i].btn:setPreferredSize(CCSizeMake(43.5,45))
                end
            end
            
        elseif winFlag == "lose" then
            self.m_sprite_Win1:setVisible(false)
            self.m_sprite_Win2:setVisible(true)
            -- local allNum = self.m_tGameData.guessing_win_times
            self:back(true, self.m_allNum)
        else
            self.m_sprite_Win1:setVisible(false)
            self.m_sprite_Win2:setVisible(false)
            game_util:addMoveTips({text = "Hòa, đánh lần nữa"})
            for i=1,3 do
                game_util:setCCControlButtonBackground(self.m_tab_btn[i].btn,"ui_newRichMan_selectDi.png")
                self.m_tab_btn[i].btn:setPreferredSize(CCSizeMake(43.5,45))
            end
        end
    else
        
    end
    self.m_animFlag = false

end
function game_newRichMan_gamble_pop.refreshLabel(self)
    local currentTimes = self.m_tGameData.guessing_win_times
    self.m_label_times:setString("Vòng " .. currentTimes ..  "/5 ")
    self.m_label_des1:setString("Số quà hiện tại")
    self.m_label_des2:setString("Tiền cược lần này:")
    self.m_label_rewardNum:setString("1000 (Thịt)")
    self.m_label_rewardNum:setVisible(false)

    self.m_node_reward:removeAllChildrenWithCleanup(true)
    local rewardCfg = getConfig(game_config_field.monopoly_reward)
    rewardCfg = rewardCfg:getNodeWithKey("6"):getNodeWithKey("reward")
    rewardCfg = json.decode(rewardCfg:getFormatBuffer())

    local reward = rewardCfg[1]
    -- cclog2(reward,"rewrad ====== ")
    local posX1,posY1 = self.m_label_rewardNum:getPosition()
    local posX2,posY2 = self.m_label_des2:getPosition()
    -- cclog2({posX1,posY1}," 1 ----")
    -- cclog2({posX2,posY2}," 1 ----")
    local icon,name,count = game_util:getRewardByItemTable(reward,nil,true)
    local icon2,name2,count2 = game_util:getRewardByItemTable(reward,nil,true)
    local parentNode = self.m_label_times:getParent()
    if icon then
        icon:setScale(0.4)
        self.m_node_reward:addChild(icon, 21, 21)
        icon:setPosition(ccp(posX1-25,posY1-5))
        -- cclog2(count,"count === ")
        count = self:getRewardNum(count)
        local countlab = CCLabelTTF:create("x" .. count,TYPE_FACE_TABLE.Arial_BoldMT,10)
        self.m_node_reward:addChild(countlab, 20, 20)
        countlab:setPosition(ccp(posX1 + 10,posY1-5))
    end   
    if icon2 then
        icon2:setScale(0.4)
        self.m_node_reward:addChild(icon2, 23, 23)
        icon2:setPosition(ccp(posX2 + 60,posY2))
        count2 = self:getRewardNum(count2)
        local countlab = CCLabelTTF:create("x" .. count2,TYPE_FACE_TABLE.Arial_BoldMT,10)
        self.m_node_reward:addChild(countlab, 22, 22)
        countlab:setPosition(ccp(posX2 + 95,posY2))
    end
end
--[[--
    刷新ui
]]
function game_newRichMan_gamble_pop.refreshUi(self)
    self:createPlayerImg()
    self:refreshLabel()
    self:refreshSpriteStatus()



  -- 1 = 96
  -- 2 = 64
-- }
--   1 = 6
--   2 = -77
-- }
    

end
--[[--
    初始化
]]
function game_newRichMan_gamble_pop.init(self,t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_vip.plist")

    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    if t_params.popCallBack then
        self.m_func_callback = t_params.popCallBack
    end
    self.m_select_index = 0
    self.m_animFlag = false
end
--[[--
    创建ui入口并初始化数据
]]
function game_newRichMan_gamble_pop.create(self,t_params)
    self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi();

    return  m_popUi;
end
return game_newRichMan_gamble_pop;