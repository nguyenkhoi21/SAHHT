--远征
local game_expedition_main = {
    m_gameData = nil,
    m_root_layer = nil,
    m_back_btn = nil,
    m_des_lab1 = nil,
    m_des_lab2 = nil,
    m_bg_nodeTab  = nil,
    tempNodeTab = nil,
    nodePosTab = nil,
    m_ui_node = nil,
    m_animFlag = nil,
    m_anim_node = nil,
    m_star_tab = nil,
    m_num_sp = nil,
    m_total_num = nil,
    m_current_num = nil,
    m_select_num = nil,
    fight_weak_cfg = nil,
    m_reward_node = nil,
    m_rule_btn = nil,
    m_chagllenge_btn = nil,
};
--[[--
    销毁
]]
function game_expedition_main.destroy(self)
    -- body
    cclog("-----------------game_expedition_main destroy-----------------");
    self.m_root_layer = nil;
    self.m_back_btn = nil;
    self.m_des_lab1 = nil;
    self.m_des_lab2 = nil;
    self.m_bg_nodeTab = nil;
    self.tempNodeTab = nil;
    self.nodePosTab = nil;
    self.m_ui_node = nil;
    self.m_animFlag = nil;
    self.m_anim_node = nil;
    self.m_star_tab = nil;
    self.m_num_sp = nil;
    self.m_total_num = nil;
    self.m_current_num = nil;
    self.m_select_num = nil;
    self.fight_weak_cfg = nil;
    self.m_reward_node = nil;
    self.m_gameData = nil;
    self.m_rule_btn = nil;
    self.m_chagllenge_btn = nil;
end
    
--[[--
    返回
]]
function game_expedition_main.back(self,type)
    game_scene:enterGameUi("game_main_scene",{gameData = nil})
end
--[[--
    读取ccbi创建ui
]]
function game_expedition_main.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then 
            self:back()
        elseif btnTag == 102 then
            local msg = self.fight_weak_cfg:getNodeWithKey(tostring(self.m_current_num)):getNodeWithKey("target_des2"):toStr()
            game_scene:addPop("game_expedition_select_pop",{openType = "des",msg = msg})
            -- game_scene:addPop("game_active_limit_detail_pop",{enterType = "177"})
        elseif btnTag == 103 then
            local function responseMethod( tag,gameData )
                if gameData then
                    game_scene:addPop("game_nightmare_enemy_pop",{gameData = gameData,index = self.m_current_num,openType = "expedition"})
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")--周一到周五的界面
        elseif btnTag == 201 or btnTag == 202 then
                if self.m_animFlag == false then
                    self:setBgMoveAnim(btnTag)
                end
                self:refreshUi()
        elseif btnTag == 203 then 
            local realIndex = self.m_gameData.max_chapter + 1 
            if realIndex <= self.m_total_num then
            else
                realIndex = self.m_total_num
            end
            game_scene:addPop("game_expedition_select_pop",{currentIndex = self.m_current_num,realIndex = realIndex})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_expedition.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_rule_btn = ccbNode:controlButtonForName("m_rule_btn")
    self.m_chagllenge_btn = ccbNode:controlButtonForName("m_chagllenge_btn")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_num_sp = ccbNode:spriteForName("m_num_sp")
    self.m_reward_node = ccbNode:nodeForName("m_reward_node")
    local m_up_btn = ccbNode:controlButtonForName("m_up_btn");
    local m_select_btn = ccbNode:controlButtonForName("m_select_btn");
    local m_down_btn = ccbNode:controlButtonForName("m_down_btn");
	m_up_btn:setOpacity(0)
	m_select_btn:setOpacity(0)
	m_down_btn:setOpacity(0)
	self.m_des_lab1 = ccbNode:labelTTFForName("m_des_lab1")
	self.m_des_lab2 = ccbNode:labelTTFForName("m_des_lab2")
	self.m_bg_nodeTab,self.tempNodeTab,self.nodePosTab= {},{},{}
	local m_bg_node,m_bg_sp
	for i=1,3 do
		m_bg_node = ccbNode:nodeForName("m_bg_node" .. i)
		self.m_bg_nodeTab[i] = m_bg_node
        self.tempNodeTab[i] = m_bg_node
        local x,y =  m_bg_node:getPosition()
        self.nodePosTab[i] = {x = x ,y = y}
	end
    local x = self.m_current_num%3 + 1
    for i=1,3 do
        local y = x + i 
        if y > 3 then
            y = y - 3 
        end
        local m_bg_sp1 =  CCSprite:create("ccbResources/expedition_bg" .. y .. ".png");
        self.m_bg_nodeTab[i]:addChild(m_bg_sp1,10)
        local kuang =  CCSprite:create("ccbResources/expedition_kuang.png");
        self.m_bg_nodeTab[i]:addChild(kuang,10)
    end

    self.m_star_tab = {}
    local m_star_sp
    for i=1,5 do
        m_star_sp = ccbNode:spriteForName("m_star_sp" .. i)
        self.m_star_tab[i] = m_star_sp
    end
    self.m_ui_node = ccbNode:nodeForName("m_ui_node")
    local m_btn_node = ccbNode:nodeForName("m_btn_node")
    local m_top_node = ccbNode:nodeForName("m_top_node")
    self.m_ui_node:getParent():reorderChild(self.m_ui_node, 6)
    m_top_node:getParent():reorderChild(m_top_node, 6)
    m_btn_node:getParent():reorderChild(m_btn_node, 6)
    return ccbNode;
end

function game_expedition_main.setBgMoveAnim( self,btnTag )

    local height = self.nodePosTab[3].x-self.nodePosTab[2].x
    local firstNode = self.tempNodeTab[1] --上
    local secondNode = self.tempNodeTab[2]--中
    local thirdNode = self.tempNodeTab[3]--下
    if btnTag == 201 then --向下滚动
        if self.m_current_num + 1 <= self.m_gameData.max_chapter + 1 and self.m_current_num + 1 <= self.m_total_num then
            self.m_animFlag = true
            self.m_ui_node:setVisible(false)
            self.m_current_num  = self.m_current_num + 1
            local function delyFunc(  )
                thirdNode:setPosition(ccp(self.nodePosTab[1].x,self.nodePosTab[1].y+101))
                local aimPos1 = ccp(self.nodePosTab[1].x,self.nodePosTab[1].y)
                thirdNode:runAction(CCMoveTo:create(0.4,aimPos1))
                self.tempNodeTab = {}
                self.tempNodeTab[1] = thirdNode
                self.tempNodeTab[2] = firstNode
                self.tempNodeTab[3] = secondNode
                for i=1,3 do
                    self.tempNodeTab[i]:getParent():reorderChild(self.tempNodeTab[i], 5-i)
                end
                local function tempCallBack(  )
                    self.m_ui_node:setVisible(true)
                    self.m_animFlag = false
                end 
                local arr =  CCArray:create()
                arr:addObject(CCDelayTime:create(0.6));
                arr:addObject(CCCallFunc:create(tempCallBack));
                self.m_ui_node:runAction(CCSequence:create(arr))
            end
            local animArr = CCArray:create()
            local aimPos = ccp(self.nodePosTab[3].x,self.nodePosTab[3].y -101)
            animArr:addObject(CCMoveTo:create(0.5,aimPos));
            animArr:addObject(CCCallFunc:create(delyFunc));
            thirdNode:runAction(CCSequence:create(animArr))
            secondNode:runAction(CCMoveTo:create(1,ccp(self.nodePosTab[3].x,self.nodePosTab[3].y)))
            firstNode:runAction(CCMoveTo:create(1,ccp(self.nodePosTab[2].x,self.nodePosTab[2].y)))
        else
            game_util:addMoveTips({text = "Không thể đi lên"})
        end
    else --向上滚动
        if self.m_current_num - 1 > 0 then
            self.m_animFlag = true
            self.m_ui_node:setVisible(false)
            self.m_current_num  = self.m_current_num - 1
            local function delyFunc(  )
                firstNode:setPosition(ccp(self.nodePosTab[3].x,self.nodePosTab[3].y+101))
                local aimPos1 = ccp(self.nodePosTab[3].x,self.nodePosTab[3].y)
                firstNode:runAction(CCMoveTo:create(0.4,aimPos1))
                self.tempNodeTab = {}
                self.tempNodeTab[1] = secondNode
                self.tempNodeTab[2] = thirdNode
                self.tempNodeTab[3] = firstNode
                for i=1,3 do
                    self.tempNodeTab[i]:getParent():reorderChild(self.tempNodeTab[i], 5-i)
                end
                local function tempCallBack(  )
                    self.m_ui_node:setVisible(true)
                    self.m_animFlag = false
                end 
                local arr =  CCArray:create()
                arr:addObject(CCDelayTime:create(0.6));
                arr:addObject(CCCallFunc:create(tempCallBack));
                self.m_ui_node:runAction(CCSequence:create(arr))
            end
            local animArr = CCArray:create()
            local aimPos = ccp(self.nodePosTab[1].x,self.nodePosTab[1].y +101)
            animArr:addObject(CCMoveTo:create(0.5,aimPos));
            animArr:addObject(CCCallFunc:create(delyFunc));
            firstNode:runAction(CCSequence:create(animArr))
            secondNode:runAction(CCMoveTo:create(1,ccp(self.nodePosTab[1].x,self.nodePosTab[1].y)))
            thirdNode:runAction(CCMoveTo:create(1,ccp(self.nodePosTab[2].x,self.nodePosTab[2].y)))
        else
            game_util:addMoveTips({text = "Không thể lùi lại"})

        end
    end
end
function game_expedition_main.createReward( self )
    self.m_reward_node:removeAllChildrenWithCleanup(true)
    local rewardTab = self.fight_weak_cfg:getNodeWithKey(tostring(self.m_current_num)):getNodeWithKey("reward_show")
    rewardTab = json.decode(rewardTab:getFormatBuffer()) or {}
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        game_util:lookItemDetal(rewardTab[btnTag])
    end
    local size = self.m_reward_node:getContentSize()
    
    local reward_num = game_util:getTableLen(rewardTab)
    local x = math.ceil(reward_num/2) -- 判断总数是奇数偶数 来决定icon的位置
    local y = reward_num%2
    local width = size.width/reward_num
    for i=1,reward_num do
        local reward = rewardTab[i]
        local icon,name,count = game_util:getRewardByItemTable(reward)
        if icon then
            icon:setScale(0.6)
            icon:setAnchorPoint(ccp(0.5,0.5))
            local countlab = CCLabelTTF:create("x" .. count,TYPE_FACE_TABLE.Arial_BoldMT,10)
            self.m_reward_node:addChild(countlab)
            if y == 0 then
                icon:setPosition(width/2+(i-1)*size.width/reward_num ,20)
                countlab:setPosition(width/2+(i-1)*size.width/reward_num,0)
            elseif y == 1 then
                icon:setPosition(size.width/2 + (i-x)*width,20)
                countlab:setPosition(size.width/2 + (i-x)*width,0)
            end
            self.m_reward_node:addChild(icon)
            
            local button = game_util:createCCControlButton("public_skill.png","",onBtnCilck)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY+1)
            button:setAnchorPoint(ccp(0,0))
            button:setZoomOnTouchDown(false)
            button:setOpacity(0)
            button:setScale(0.8)
            button:setTag(i)
            icon:addChild(button)
        end
    end
end
function game_expedition_main.createHeroAnim(self)
    self.m_anim_node:removeAllChildrenWithCleanup(true)
    local card_ccbNode = self:setQuanshenxiang();
    self.m_anim_node:addChild(card_ccbNode,10,10)
end
function game_expedition_main.createStar( self,i )
    local i = i
    local x = math.floor(i/2)
    local y = i%2
    for i=1,5 do
        self.m_star_tab[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("expedition_star2.png"));

        if i < x+1 then
            self.m_star_tab[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("expedition_star1.png"));
        end
        if y == 1 and i == x + 1 then
            self.m_star_tab[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("expedition_halfStar.png"));
        end
    end
end
function game_expedition_main.setQuanshenxiang(self)
    local fightID = self.fight_weak_cfg:getNodeWithKey(tostring(self.m_current_num)):getNodeWithKey("fight_ID"):toInt()
    local fight_position = getConfig(game_config_field.fight_position)
    enemy_ID = fight_position:getNodeWithKey(tostring(fightID)):getNodeWithKey("position15"):toInt()
    local nightmare_enemy = getConfig(game_config_field.nightmare_enemy)
    local bossID = nightmare_enemy:getNodeWithKey(tostring(enemy_ID)):getNodeWithKey("c_id"):toInt()
    local animNode = nil;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(bossID));
    if  heroCfg then
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        animNode = game_util:createPauseAnim(ainmFile,0,heroData,heroCfg);
        if animNode then
            animNode:setAnchorPoint(ccp(0.5,0));
        end
    end
    return animNode;
end
--[[--
    刷新ui
]]
function game_expedition_main.refreshUi(self)
    self:createReward()
    local des1 = self.fight_weak_cfg:getNodeWithKey(tostring(self.m_current_num)):getNodeWithKey("target_des1"):toStr()

    self.m_des_lab1:setString(des1)
    self.m_des_lab2:setString("5h sáng thứ 2 mỗi tuần sẽ tự reset")
    self:createHeroAnim()
    local hard = self.fight_weak_cfg:getNodeWithKey(tostring(self.m_current_num)):getNodeWithKey("is_hard"):toInt()
    self:createStar(hard)
    self.m_num_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(self.m_current_num .. ".png"));
    if self.m_current_num <= self.m_gameData.max_chapter then
        self.m_rule_btn:setPosition(ccp(74,-65))
        self.m_chagllenge_btn:setVisible(false)
    else
        self.m_rule_btn:setPosition(ccp(31,-65))
        self.m_chagllenge_btn:setVisible(true)
    end
end
--[[--
    初始化
]]
function game_expedition_main.init(self,t_params)
    self.m_animFlag = false
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_gameData = json.decode(data:getFormatBuffer()) or {};
    end
    self.fight_weak_cfg = getConfig(game_config_field.fight_weak)
    local tempCfg = json.decode(self.fight_weak_cfg:getFormatBuffer()) 
    self.m_total_num = math.min(game_util:getTableLen(tempCfg),20)
    self.m_current_num = t_params.selectIndex or self.m_gameData.max_chapter + 1
    if self.m_current_num > self.m_total_num then
        self.m_current_num = self.m_total_num
    end
    local reward = t_params.reward or game_data:getNightmareReward()
    if reward and next(reward) then
        game_util:rewardTipsByDataTable(reward);
    end
    game_data:setNightmareReward()
end
--[[--
    创建ui入口并初始化数据
]]
function game_expedition_main.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end
return game_expedition_main;