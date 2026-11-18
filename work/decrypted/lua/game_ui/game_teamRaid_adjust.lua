---  团队副本   阵型
local game_teamRaid_adjust = {
    m_sp_teampos = nil,
    m_pos_node = nil,
    m_teampostag = nil,
    m_teampos = nil,
    m_layer_left = nil,
    m_scroll_porp = nil,
    m_skill_node = nil,
    m_btntab_porp = nil,
    m_btntab_skill = nil,
    m_btn_autoEmbattle = nil,
    m_skillTab_node = nil,
    m_combat_label = nil,
    m_label_name = nil,
    m_label_lv = nil,
    m_sp_face = nil,
    m_began = nil,
    m_ended = nil,
    m_moveType = nil,
    m_selectIcon = nil,
    m_alignment = nil,
    m_hero_spList = nil,
    m_left_cards = nil,
    m_tGameData = nil,
    m_enterFlag = nil,
    m_Raid_id = nil,
    m_sel_tab = nil,
    m_heroList = nil,
    m_leftCardsTab = nil,
    m_waitPos = nil,

    m_life_label = nil,
    m_physical_atk_label = nil,
    m_magic_atk_label = nil,
    m_def_label = nil,
    m_speed_label = nil,
    m_fire_label = nil,
    m_water_label = nil,
    m_wind_label = nil,
    m_earth_label = nil,
    m_fire_dfs_label = nil,
    m_water_dfs_label = nil,
    m_wind_dfs_label = nil,
    m_earth_dfs_label = nil,
    m_life_label2 = nil,
    m_physical_atk_label2 = nil,
    m_magic_atk_label2 = nil,
    m_def_label2 = nil,
    m_speed_label2 = nil,
    m_fire_label2 = nil,
    m_water_label2 = nil,
    m_wind_label2 = nil,
    m_earth_label2 = nil,
    m_fire_dfs_label2 = nil,
    m_water_dfs_label2 = nil,
    m_wind_dfs_label2 = nil,
    m_earth_dfs_label2 = nil,
};

--[[--
    销毁
]]
function game_teamRaid_adjust.destroy(self)
    -- body
    cclog("-----------------game_teamRaid_adjust destroy-----------------");
    self.m_root_layer = nil;
    self.m_sp_teampos = nil;
    self.m_pos_node = nil;
    self.m_teampostag = nil;
    self.m_teampos = nil;
    self.m_layer_left = nil;
    self.m_scroll_porp = nil;
    self.m_skill_node = nil;
    self.m_btntab_porp = nil;
    self.m_btntab_skill = nil;
    self.m_btn_autoEmbattle = nil;
    self.m_skillTab_node = nil;
    self.m_combat_label = nil;
    self.m_label_name = nil;
    self.m_label_lv = nil;
    self.m_sp_face = nil;
    self.m_began = nil;
    self.m_ended = nil;
    self.m_moveType = nil;
    self.m_selectIcon = nil;
    self.m_alignment = nil;
    self.m_hero_spList = nil;
    self.m_left_cards = nil;
    self.m_tGameData = nil;
    self.m_enterFlag = nil;
    self.m_Raid_id = nil;
    self.m_sel_tab = nil;
    self.m_heroList = nil;
    self.m_leftCardsTab = nil;
    self.m_waitPos = nil;

    self.m_life_label = nil;
    self.m_physical_atk_label = nil;
    self.m_magic_atk_label = nil;
    self.m_def_label = nil;
    self.m_speed_label = nil;
    self.m_fire_label = nil;
    self.m_water_label = nil;
    self.m_wind_label = nil;
    self.m_earth_label = nil;
    self.m_fire_dfs_label = nil;
    self.m_water_dfs_label = nil;
    self.m_wind_dfs_label = nil;
    self.m_earth_dfs_label = nil;
    self.m_life_label2 = nil;
    self.m_physical_atk_label2 = nil;
    self.m_magic_atk_label2 = nil;
    self.m_def_label2 = nil;
    self.m_speed_label2 = nil;
    self.m_fire_label2 = nil;
    self.m_water_label2 = nil;
    self.m_wind_label2 = nil;
    self.m_earth_label2 = nil;
    self.m_fire_dfs_label2 = nil;
    self.m_water_dfs_label2 = nil;
    self.m_wind_dfs_label2 = nil;
    self.m_earth_dfs_label2 = nil;
end

--[[--
    返回
]]
function game_teamRaid_adjust.back(self,type)
    if self.m_shared then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
        self.m_shared = nil
    end

    local params = {}
    params.align_1 = ""
    for i=1,6 do
        local align = self.m_alignment[i]
        params.align_1 = params.align_1 .. (align and align.data.key or "0" ) .. ((i == 6) and "" or "_")
    end
    local function responseMethod( tag, gameData )
        if gameData then
            local tab = game_data:getTeamRaidMsg()
            local data = gameData:getNodeWithKey("data")
            local stage = data:getNodeWithKey("stage"):toInt()
            local stage_small = data:getNodeWithKey("stage_small") and data:getNodeWithKey("stage_small"):toInt()
            if stage and stage ~= 0 then
                if stage == 1 then
                    if stage_small == 1 then
                        game_scene:enterGameUi("game_teamRaid_first_scene",{gameData = gameData,enterFlag = self.m_enterFlag,battleType = tab.battleType})
                    elseif stage_small == 2 then
                        game_scene:enterGameUi("game_teamRaid_firstBoss_scene",{gameData = gameData,enterFlag = self.m_enterFlag,selectRow = tab.selectRow,selectCol = tab.selectCol})
                    end
                elseif stage == 2 then
                    if stage_small == 1 then
                        game_scene:enterGameUi("game_teamRaid_last_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                    elseif stage_small == 2 then
                        game_scene:enterGameUi("game_teamRaid_lastBoss_scene",{gameData = gameData,enterFlag = self.m_enterFlag,selectRow = tab.selectRow,selectCol = tab.selectCol})
                    end
                elseif stage == 3 then
                    game_scene:enterGameUi("game_teamRaid_third_scene",{gameData = gameData,enterFlag = self.m_enterFlag})
                elseif stage == 999 then
                    
                end
            else
                game_scene:enterGameUi("game_teamRaid_sec",{gameData = gameData,enterFlag = 1})
            end
        end
    end
    params.raid_id = self.m_Raid_id
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_set_aligment"), http_request_method.GET, params,"team_raid_set_aligment")
end


--[[--
    读取ccbi创建ui
]]
function game_teamRaid_adjust.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 11 then --属性
            self.m_sel_tab = 1
            self:refreshBtn()
        elseif btnTag == 12 then --技能
            self.m_sel_tab = 2
            self:refreshBtn()
        elseif btnTag == 21 then --一键布阵

            self:liezhen()
        end
            
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_teamRaid_adjust.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")


    self.m_sp_teampos = {}
    self.m_sp_teampos[1] = ccbNode:spriteForName("m_pos_1")
    self.m_sp_teampos[2] = ccbNode:spriteForName("m_pos_2")
    self.m_sp_teampos[3] = ccbNode:spriteForName("m_pos_3")
    self.m_sp_teampos[4] = ccbNode:spriteForName("m_pos_4")
    self.m_sp_teampos[5] = ccbNode:spriteForName("m_pos_5")
    self.m_sp_teampos[6] = ccbNode:spriteForName("m_pos_6")


    self.m_pos_node = {}
    self.m_teampostag = {}
    self.m_teampos = {}
    for i=1,6 do
        self.m_pos_node[i] = ccbNode:nodeForName("m_pos_node_"..i) 
        self.m_teampostag[i] = "0"
    end


    self.m_layer_left = ccbNode:layerForName("m_layer_left")
    for k,v in pairs(self.m_sp_teampos) do
        local x1 = v:convertToWorldSpace(ccp(0,0)).x +10
        local x2 = x1 + v:getContentSize().width -10
        local y1 = v:convertToWorldSpace(ccp(0,0)).y +10
        local y2 = y1 + v:getContentSize().height -10
        local w  = v:getContentSize().width
        local h  = v:getContentSize().height
        self.m_teampos[k] = {x1 = x1 ,x2 = x2 ,y1 = y1 ,y2 = y2 ,id = k,w=w,h=h }
    end


    self.m_scroll_porp = ccbNode:scrollViewForName("m_scroll_porp")
    self.m_skill_node = ccbNode:nodeForName("m_skill_node")
    self.m_btntab_porp = ccbNode:controlButtonForName("m_btntab_porp")
    self.m_btntab_skill = ccbNode:controlButtonForName("m_btntab_skill")
    self.m_btn_autoEmbattle = ccbNode:controlButtonForName("m_btn_autoEmbattle")
    self.m_skillTab_node = ccbNode:nodeForName("m_skillTab_node")

    self.m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
    self.m_label_name = ccbNode:labelTTFForName("m_label_name")
    self.m_label_lv = ccbNode:labelTTFForName("m_label_lv")
    self.m_sp_face = ccbNode:spriteForName("m_sp_face")

    local porpCcbNode = self:createPorpUI()
    local viewSize = porpCcbNode:getContentSize()
    self.m_scroll_porp:addChild(porpCcbNode)
    self.m_scroll_porp:setContentSize(viewSize)
    self.m_scroll_porp:setContentOffset(ccp(0,-52),true)


    local beganX,beganY = nil,nil
    local endedX,endedY = nil,nil
    local moveFlag = false
    local function onTouchBegan(x, y)
        moveFlag = false
    	for i=1,6 do
    		local tempItem = self.m_sp_teampos[i]
		    local realPos = tempItem:getParent():convertToNodeSpace(ccp(x,y)); 
            if tempItem:boundingBox():containsPoint(realPos) then
                if not self.m_alignment[i] then
                    return false
                end
            	self.m_moveType = 1
            	self.m_began = i
            	if self.m_alignment[i] then
                    local tempicon = self.m_hero_spList["sp" .. self.m_alignment[i].index].icon
                    self.m_selectIcon = tempicon
            	end
            	return true
            end
    	end
    	for j=1,game_util:getTableLen(self.m_left_cards) do
    		local tempItem = self.m_left_cards[j].icon
		    local realPos = tempItem:getParent():convertToNodeSpace(ccp(x,y)); 
            if tempItem:boundingBox():containsPoint(realPos) then
            	self.m_moveType = 2
            	self.m_began = j
            	self.m_selectIcon = tempItem
            	return true
            end
    	end
    	return false
    end
    local function onTouchMoved(x, y)
        moveFlag = true
        if self.m_selectIcon then
            self.m_selectIcon:setVisible(true)
            local pos = self.m_layer_left:convertToNodeSpace(ccp(x,y))
            self.m_selectIcon:setPosition(pos)
        end
    end

    local function onTouchEnded(x, y)
    	for i=1,6 do
    		local tempItem = self.m_sp_teampos[i]
		    local realPos = tempItem:getParent():convertToNodeSpace(ccp(x,y)); 
            if tempItem:boundingBox():containsPoint(realPos) then
                if not moveFlag and self.m_alignment[i] then
                    local index = self.m_alignment[i].index
                    self:refreshCardsInfo(index)
                    return
                end
            	self.m_ended = i
                if self.m_moveType == 1 and moveFlag then
                    self.m_ended = i
                    if self.m_selectIcon then
                        self.m_selectIcon:setVisible(false)
                    end
                    self:changedPosByindex(self.m_began,self.m_ended)
                    return
                elseif self.m_moveType == 2 and moveFlag then -- 
                    if self.m_selectIcon then
                        self.m_selectIcon:setVisible(false)
                    end
                    if not self.m_alignment[i] then
                        self.m_alignment[i] = self.m_left_cards[self.m_began]
                        self.m_hero_spList["sp" .. self.m_left_cards[self.m_began].index].icon:setVisible(false)
                        self.m_hero_spList["sp" .. self.m_left_cards[self.m_began].index].pos = i
                        local pos_node = self.m_pos_node[i]
                        pos_node:removeAllChildrenWithCleanup(true)
                        local tempFrame1 = CCSprite:createWithSpriteFrameName("dw_characterBg.png")
                        
                        local anim = self:createAnimByData(self.m_hero_spList["sp" .. self.m_left_cards[self.m_began].index].data)
                        if anim then
                            if tempFrame1 then
                                pos_node:addChild(tempFrame1)
                            end
                            pos_node:addChild(anim)
                            anim:setAnchorPoint(ccp(0.5,0.5))
                        end
                        self:refreshCardsPos()
                        self.m_moveType = 0
                        self.m_began = 0
                        self.m_selectIcon = nil
                        self.m_ended = 0
                        moveFlag = false
                        return
                    else
                        for j=1,6 do
                            if not self.m_alignment[j] then
                                local pos_node = self.m_pos_node[j]
                                self.m_alignment[j] = self.m_left_cards[self.m_began]
                                self.m_hero_spList["sp" .. self.m_left_cards[self.m_began].index].icon:setVisible(false)
                                self.m_hero_spList["sp" .. self.m_left_cards[self.m_began].index].pos = j
                                pos_node:removeAllChildrenWithCleanup(true)
                                local tempFrame1 = CCSprite:createWithSpriteFrameName("dw_characterBg.png")
                                
                                local anim = self:createAnimByData(self.m_hero_spList["sp" .. self.m_left_cards[self.m_began].index].data)
                                if anim then
                                    if tempFrame1 then
                                        pos_node:addChild(tempFrame1)
                                    end
                                    pos_node:addChild(anim)
                                    anim:setAnchorPoint(ccp(0.5,0.5))
                                end
                                self:refreshCardsPos()
                                self.m_moveType = 0
                                self.m_began = 0
                                self.m_selectIcon = nil
                                self.m_ended = 0
                                moveFlag = false
                                return
                            end
                        end
                    end
                end
            	return
            end
    	end
        for j=1,game_util:getTableLen(self.m_left_cards) do
            local tempItem = self.m_left_cards[j].icon
            local realPos = tempItem:getParent():convertToNodeSpace(ccp(x,y)); 
            if tempItem:boundingBox():containsPoint(realPos) then
                if not moveFlag then
                    local index1 = self.m_left_cards[j].index
                    self:refreshCardsInfo(index1)
                    return
                end

            end
        end

        if self.m_moveType == 1 and self.m_began ~= 0 then
            local pos_node = self.m_pos_node[self.m_began]
            if pos_node then
                pos_node:removeAllChildrenWithCleanup(true)
            end
            self.m_hero_spList["sp" .. self.m_alignment[self.m_began].index].pos = 0
            self.m_alignment[self.m_began] = nil
            self:refreshCardsPos()
            self.m_moveType = 0
            self.m_began = 0
            self.m_selectIcon = nil
            self.m_ended = 0
            moveFlag = false
            return
        end
        self:refreshCardsPos()
        self.m_moveType = 0
        self.m_began = 0
        self.m_selectIcon = nil
        self.m_ended = 0
        moveFlag = false
        return
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
    self.m_layer_left:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,false)
    self.m_layer_left:setTouchEnabled(true)
    return ccbNode;
end

-- 创建卡牌动画
function game_teamRaid_adjust:createAnimByData( data )

    local data = data
    local charapter = getConfig(game_config_field.character_detail)
    local heroData = data.cards_info
    local c_id = heroData and heroData.c_id
    local heroCfg = charapter:getNodeWithKey(tostring(c_id))
    return self:createCardAnimByData(heroData,heroCfg)
end

function game_teamRaid_adjust.createCardAnimByData( self, heroData,heroCfg,animFlag)
    local animNode = nil;
    local character_ID = -1;
    if heroData and heroCfg then
        character_ID = heroCfg:getNodeWithKey("character_ID"):toInt();
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        animFlag = animFlag == nil and true or animFlag
        if animFlag then
            animNode = game_util:createIdelAnim(ainmFile,0,heroData,heroCfg);
        else
            animNode = game_util:createCardImgByCfg(heroCfg);
        end
        if animNode then
            local itemSize = animNode:getContentSize();
            if animFlag == false then
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dw_light_down.png")
                if spriteFrame then
                    local tempSprite = CCSprite:createWithSpriteFrameName(spriteFrame)
                    tempSprite:setAnchorPoint(ccp(0.5,0.1))
                    tempSprite:setPositionX(itemSize.width*0.5)
                    animNode:addChild(tempSprite)
                end
                local spriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dw_light_up.png")
                if spriteFrame2 then
                    local tempSprite = CCSprite:createWithSpriteFrameName(spriteFrame2)
                    tempSprite:setAnchorPoint(ccp(0.5,0.1))
                    tempSprite:setPositionX(itemSize.width*0.5)
                    animNode:addChild(tempSprite,1000,1000)
                end
            else
                animNode:setRhythm(1);
            end
            animNode:setAnchorPoint(ccp(0.5,0));
            local name_after = heroData.step < 1 and "" or ("+" .. heroData.step);
            local tempLabel = CCLabelTTF:create("Lv." .. heroData.lv .. "/" .. heroData.level_max .. "\n" .. name_after,TYPE_FACE_TABLE.Arial_BoldMT,10);
            tempLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
            tempLabel:setPosition(ccp(itemSize.width*0.5 - 50,108));
            tempLabel:setAnchorPoint(ccp(0,0.5));
            animNode:addChild(tempLabel,100,100)

            local occupation_cfg = getConfig(game_config_field.occupation);
            local occupation_item_cfg = occupation_cfg:getNodeWithKey(ainmFile)
            if occupation_item_cfg then
                local occupationType = occupation_item_cfg:toInt();
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupationType .. ".png")
                if spriteFrame then
                    local occupation_icon = CCSprite:createWithSpriteFrame(spriteFrame)
                    occupation_icon:setPosition(ccp(itemSize.width*0.5 + 56,110));
                    occupation_icon:setAnchorPoint(ccp(1,0.5));
                    animNode:addChild(occupation_icon);
                end
            end
            animNode:setScale(0.66);
        end
    end
    return animNode,character_ID
end

-- 交换位置
function game_teamRaid_adjust:changedPosByindex(index1 , index2)
    local tab1 = self.m_alignment[index1] or {}
    local tab2 = self.m_alignment[index2] or {}
    self.m_alignment[index1] = util.table_copy(tab2)
    self.m_alignment[index2] = util.table_copy(tab1)
    local tempItem1 = self.m_pos_node[index1]
    local tempItem2 = self.m_pos_node[index2]

    tempItem1:removeAllChildrenWithCleanup(true)
    tempItem2:removeAllChildrenWithCleanup(true)
    local tempFrame1 = CCSprite:createWithSpriteFrameName("dw_characterBg.png")
    local tempFrame2 = CCSprite:createWithSpriteFrameName("dw_characterBg.png")


    if tab2 and tab2.index then
        local anim1 = self:createAnimByData(self.m_hero_spList["sp" .. tab2.index].data)
        if anim1 then
            if tempFrame1 then
                tempItem1:addChild(tempFrame1)
            end
            tempItem1:addChild(anim1)
            anim1:setAnchorPoint(ccp(0.5,0.5))
        end
    else
        self.m_alignment[index1] = nil
    end
    if tab1 and tab1.index then
        local anim1 = self:createAnimByData(self.m_hero_spList["sp" .. tab1.index].data)
        if anim1 then
            if tempFrame2 then
                tempItem2:addChild(tempFrame2)
            end
            anim1:setAnchorPoint(ccp(0.5,0.5))
            tempItem2:addChild(anim1)
        end
    else
        self.m_alignment[index2] = nil
    end
end

-- 一键布阵
function game_teamRaid_adjust.liezhen(self)
    for i=1,#self.m_left_cards do
        for j=1,6 do
            if not self.m_alignment[j] then
                self.m_alignment[j] = self.m_left_cards[i]
                local pos_node = self.m_pos_node[j]
                pos_node:removeAllChildrenWithCleanup(true)
                local tempFrame1 = CCSprite:createWithSpriteFrameName("dw_characterBg.png")
                local anim = self:createAnimByData(self.m_hero_spList["sp" .. self.m_left_cards[i].index].data)
                if anim then
                    if tempFrame1 then
                        pos_node:addChild(tempFrame1)
                    end
                    pos_node:addChild(anim)
                    anim:setAnchorPoint(ccp(0.5,0.5))
                end
                self.m_hero_spList["sp" .. self.m_left_cards[i].index].pos = j
                break
            end
        end
    end
    self:refreshCardsPos()
end


function game_teamRaid_adjust.createPorpUI(self)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_hero_info_item_forteam.ccbi");

    self.m_life_label = ccbNode:labelTTFForName("m_life_label")
    self.m_physical_atk_label = ccbNode:labelTTFForName("m_physical_atk_label")
    self.m_magic_atk_label = ccbNode:labelTTFForName("m_magic_atk_label")
    self.m_def_label = ccbNode:labelTTFForName("m_def_label")
    self.m_speed_label = ccbNode:labelTTFForName("m_speed_label")
    self.m_fire_label = ccbNode:labelTTFForName("m_fire_label")
    self.m_water_label = ccbNode:labelTTFForName("m_water_label")
    self.m_wind_label = ccbNode:labelTTFForName("m_wind_label")
    self.m_earth_label = ccbNode:labelTTFForName("m_earth_label")
    self.m_fire_dfs_label = ccbNode:labelTTFForName("m_fire_dfs_label")
    self.m_water_dfs_label = ccbNode:labelTTFForName("m_water_dfs_label")
    self.m_wind_dfs_label = ccbNode:labelTTFForName("m_wind_dfs_label")
    self.m_earth_dfs_label = ccbNode:labelTTFForName("m_earth_dfs_label")
    self.m_life_label2 = ccbNode:labelTTFForName("m_life_label2")
    self.m_physical_atk_label2 = ccbNode:labelTTFForName("m_physical_atk_label2")
    self.m_magic_atk_label2 = ccbNode:labelTTFForName("m_magic_atk_label2")
    self.m_def_label2 = ccbNode:labelTTFForName("m_def_label2")
    self.m_speed_label2 = ccbNode:labelTTFForName("m_speed_label2")
    self.m_fire_label2 = ccbNode:labelTTFForName("m_fire_label2")
    self.m_water_label2 = ccbNode:labelTTFForName("m_water_label2")
    self.m_wind_label2 = ccbNode:labelTTFForName("m_wind_label2")
    self.m_earth_label2 = ccbNode:labelTTFForName("m_earth_label2")
    self.m_fire_dfs_label2 = ccbNode:labelTTFForName("m_fire_dfs_label2")
    self.m_water_dfs_label2 = ccbNode:labelTTFForName("m_water_dfs_label2")
    self.m_wind_dfs_label2 = ccbNode:labelTTFForName("m_wind_dfs_label2")
    self.m_earth_dfs_label2 = ccbNode:labelTTFForName("m_earth_dfs_label2")
    return ccbNode
end


function game_teamRaid_adjust:refreshCardsInfo( index )
    -- body
    local cardsDataTab = self.m_hero_spList["sp" .. index]
    local cardsData = cardsDataTab.data

    self.m_combat_label:setString(cardsData.combat)
    self.m_label_name:setString(cardsData.name)
    -- self.m_label_lv:setString(cardsData.level)
    local icon= CCSprite:create(MAIN_ROLE_ICON_R[tonumber(cardsData.role)].icon)
    self.m_sp_face:removeAllChildrenWithCleanup(true)
    if icon then
        self.m_sp_face:addChild(icon)
        if tonumber(cardsData.role) == 1 then
            icon:setPosition(ccp(self.m_sp_face:getContentSize().width/2-4,self.m_sp_face:getContentSize().height/2+5))
        elseif tonumber(cardsData.role) == 2 then
            icon:setPosition(ccp(self.m_sp_face:getContentSize().width/2+1,self.m_sp_face:getContentSize().height/2+8))
        elseif tonumber(cardsData.role) == 3 then
            icon:setPosition(ccp(self.m_sp_face:getContentSize().width/2,self.m_sp_face:getContentSize().height/2+8))
        elseif tonumber(cardsData.role) == 4 then
            icon:setPosition(ccp(self.m_sp_face:getContentSize().width/2-2,self.m_sp_face:getContentSize().height/2+8))
        elseif tonumber(cardsData.role) == 5 then
            icon:setPosition(ccp(self.m_sp_face:getContentSize().width/2,self.m_sp_face:getContentSize().height/2+6))
        end
        icon:setScale(0.8)
    end
    self.m_life_label:setString(            math.floor(cardsData.cards_info.hp))
    self.m_physical_atk_label:setString(    math.floor(cardsData.cards_info.patk))
    self.m_magic_atk_label:setString(       math.floor(cardsData.cards_info.matk))
    self.m_def_label:setString(             math.floor(cardsData.cards_info.def))
    self.m_speed_label:setString(           math.floor(cardsData.cards_info.speed))
    self.m_fire_label:setString(            math.floor(cardsData.cards_info.fire))
    self.m_water_label:setString(           math.floor(cardsData.cards_info.water))
    self.m_wind_label:setString(            math.floor(cardsData.cards_info.wind))
    self.m_earth_label:setString(           math.floor(cardsData.cards_info.earth))
    self.m_fire_dfs_label:setString(        math.floor(cardsData.cards_info.fire_dfs))
    self.m_water_dfs_label:setString(       math.floor(cardsData.cards_info.water_dfs))
    self.m_wind_dfs_label:setString(        math.floor(cardsData.cards_info.wind_dfs))
    self.m_earth_dfs_label:setString(       math.floor(cardsData.cards_info.earth_dfs))

    self.m_life_label2:setString("+"..          math.floor(tonumber(cardsData.cards_info.hp)         )-math.floor(tonumber(cardsData.cards_info_base.hp)))
    self.m_physical_atk_label2:setString("+"..  math.floor(tonumber(cardsData.cards_info.patk)       )-math.floor(tonumber(cardsData.cards_info_base.patk)))
    self.m_magic_atk_label2:setString("+"..     math.floor(tonumber(cardsData.cards_info.matk)       )-math.floor(tonumber(cardsData.cards_info_base.matk)))
    self.m_def_label2:setString("+"..           math.floor(tonumber(cardsData.cards_info.def)        )-math.floor(tonumber(cardsData.cards_info_base.def)))
    self.m_speed_label2:setString("+"..         math.floor(tonumber(cardsData.cards_info.speed)      )-math.floor(tonumber(cardsData.cards_info_base.speed)))
    self.m_fire_label2:setString("+"..          math.floor(tonumber(cardsData.cards_info.fire)       )-math.floor(tonumber(cardsData.cards_info_base.fire)))
    self.m_water_label2:setString("+"..         math.floor(tonumber(cardsData.cards_info.water)      )-math.floor(tonumber(cardsData.cards_info_base.water)))
    self.m_wind_label2:setString("+"..          math.floor(tonumber(cardsData.cards_info.wind)       )-math.floor(tonumber(cardsData.cards_info_base.wind)))
    self.m_earth_label2:setString("+"..         math.floor(tonumber(cardsData.cards_info.earth)      )-math.floor(tonumber(cardsData.cards_info_base.earth)))
    self.m_fire_dfs_label2:setString("+"..      math.floor(tonumber(cardsData.cards_info.fire_dfs)   )-math.floor(tonumber(cardsData.cards_info_base.fire_dfs)))
    self.m_water_dfs_label2:setString("+"..     math.floor(tonumber(cardsData.cards_info.water_dfs)  )-math.floor(tonumber(cardsData.cards_info_base.water_dfs)))
    self.m_wind_dfs_label2:setString("+"..      math.floor(tonumber(cardsData.cards_info.wind_dfs)   )-math.floor(tonumber(cardsData.cards_info_base.wind_dfs)))
    self.m_earth_dfs_label2:setString("+"..     math.floor(tonumber(cardsData.cards_info.earth_dfs)  )-math.floor(tonumber(cardsData.cards_info_base.earth_dfs)))

    self:refreshSkillNode(cardsData)
end


function game_teamRaid_adjust:refreshSkillNode( cardsData )
    -- body
    local posTab = {
        {{x=0.5,y = 0.5}},
        {{x=0.25,y = 0.5},{x=0.75,y = 0.5}},
        {{x=0.17,y = 0.5},{x=0.5,y = 0.5},{x=0.83,y = 0.5}},
        {{x=0.25,y = 0.75},{x=0.75,y = 0.75},{x=0.25,y = 0.25},{x=0.75,y = 0.25}},
        {{x=0.17,y = 0.75},{x=0.5,y = 0.75},{x=0.83,y = 0.75},{x=0.25,y = 0.25},{x=0.75,y = 0.25}},
    }
    local cards_info = cardsData.cards_info or {}
    self.m_skillTab_node:removeAllChildrenWithCleanup(true)
    local skillTab = {}
    local extra_skill = cards_info.extra_skill
    for i=1,5 do
        -- if i < 4 then
            local cardsSkill = cards_info["s_" .. i]
            if cardsSkill then
                skillTab[#skillTab+1] = cardsSkill
            end
    --     else
    --         local cardsSkill = extra_skill["s_" .. i]
    --         if cardsSkill then
    --             skillTab[#skillTab+1] = cardsSkill
    --         end
    --     end
    end
    cclog2(skillTab)
    local pos = posTab[#skillTab]
    local viewSize = self.m_skillTab_node:getContentSize()
    for i=1,#skillTab do
        local skill = skillTab[i]
        local icon,name = game_util:createSkillIconByCid(skill.s, skill.avail)
        if icon then
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setScale(0.65)
            icon:setPosition(ccp(viewSize.width*pos[i].x, viewSize.height*pos[i].y))
            self.m_skillTab_node:addChild(icon)
            local tempLabel = game_util:createLabelTTF({text = name, textAlignment = textAlignment,verticalTextAlignment = verticalTextAlignment,fontSize = 11})
            if tempLabel then
                icon:addChild(tempLabel)
                tempLabel:setAnchorPoint(ccp(0.5,1))
                tempLabel:setPosition(ccp(icon:getContentSize().width*0.5,15-icon:getContentSize().height*0.5))
            end
        end
    end
end


function game_teamRaid_adjust:refreshBtn(  )
	-- body
    self:setCCControlButtonEnabled(self.m_btntab_porp,(self.m_sel_tab ~= 1))
    self:setCCControlButtonEnabled(self.m_btntab_skill,(self.m_sel_tab ~= 2))
    self.m_scroll_porp:setVisible(self.m_sel_tab == 1)
    self.m_skill_node:setVisible(self.m_sel_tab == 2)
end


function game_teamRaid_adjust.setCCControlButtonEnabled(self,btn,enabled)
    if btn == nil then return end
    if enabled == true then
        btn:setColor(ccc3(155, 155, 155));
        btn:setEnabled(true);
    else
        btn:setColor(ccc3(255, 255, 255));
        btn:setEnabled(false);
    end
end


function game_teamRaid_adjust:refreshAlignment(  )
    -- body
    for i=1,6 do
        local tempTab = self.m_alignment[i]
        local pos_node = self.m_pos_node[i]
        pos_node:removeAllChildrenWithCleanup(true)
        local tempFrame1 = CCSprite:createWithSpriteFrameName("dw_characterBg.png")

        if tempTab then
            local anim = self:createAnimByData(tempTab.data)
            if anim then
                if tempFrame1 then
                    pos_node:addChild(tempFrame1)
                end
                pos_node:addChild(anim)
                anim:setAnchorPoint(ccp(0.5,0.5))
            end
        end
    end
end

--[[--
    刷新ui
]]
function game_teamRaid_adjust.refreshUi(self)
    -- 属性
    self:refreshBtn()
    self:refreshCardsList()
    self:refreshCardsPos()
    self:refreshAlignment()
    if self.m_left_cards[1] then
        self:refreshCardsInfo(self.m_left_cards[1].index)
    else
        for i=1,6 do
            if self.m_alignment[i] then
                self:refreshCardsInfo(self.m_alignment[i].index)
                break
            end
        end
    end
end

function game_teamRaid_adjust:refreshCardsList()

	-- body
    local alignment = self.m_tGameData.alignment or {}
    local tempAlign = {}
    for k,v in pairs(alignment) do
        if tostring(v) ~= "0" then
            tempAlign[v] = k
        end
    end
	local index = 1
	self.m_hero_spList = {}
	for i=1,#self.m_heroList do
		local data = self.m_heroList[i]
		local icon = game_util:createCardIconByCid(data.cards_info.c_id,data.cards_info)
		if icon then
			self.m_hero_spList["sp" .. i] = {}
			self.m_hero_spList["sp" .. i].icon = icon
			self.m_hero_spList["sp" .. i].index = i

            self.m_hero_spList["sp" .. i].data = util.table_copy(data)
			self.m_layer_left:addChild(icon)
            if tempAlign[data.key] then
                self.m_hero_spList["sp" .. i].pos = tempAlign[data.key]
                self.m_alignment[tempAlign[data.key]] = util.table_copy(self.m_hero_spList["sp" .. i])
            else
                self.m_hero_spList["sp" .. i].pos = 0
            end
            icon:setScale(0.7)
		end
	end
end

function game_teamRaid_adjust:refreshCardsPos()
	-- body
	self.m_left_cards = {}
	local index = 1
	for i=1,game_util:getTableLen(self.m_hero_spList) do
		local tab = self.m_hero_spList["sp" .. i]
		if tab.pos == 0 then
			tab.icon:setVisible(true)
			self.m_left_cards[#self.m_left_cards + 1] = util.table_copy(tab)
			local icon = tab.icon
			local pos = self.m_waitPos[index].pos
			icon:setPosition(ccp(pos.x,pos.y))
			icon:setScale(0.7)
			index = index + 1
		else
			tab.icon:setVisible(false)
		end
	end
end
--[[--
    初始化
]]
function game_teamRaid_adjust.init(self,t_params)

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_team_info_res.plist");

    t_params = t_params or {};
    -- body
    local equip_cfg = getConfig(game_config_field.equip)
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
       local data = t_params.gameData:getNodeWithKey("data")
       self.m_tGameData = json.decode(data:getFormatBuffer())
    end
    self.m_enterFlag = t_params.enterFlag
    self.m_Raid_id = t_params.raid_id or ""
    self.m_sel_tab = 1
    local all_cards_info = self.m_tGameData.all_cards_info or {}
    self.m_heroList = {}
    self.m_leftCardsTab = self.m_tGameData.all_cards_info
    local card = {}
    for k,v in pairs(all_cards_info) do
        self.m_heroList[#self.m_heroList+1] = v
    	self.m_heroList[#self.m_heroList].key = k
    end
    -- for i=1,5 do
    -- 	self.m_heroList[i] = util.table_copy(card) 
    -- end
    self.m_alignment = self.m_tGameData.alignment or {}
    for k,v in pairs(self.m_alignment) do
    	if self.m_leftCardsTab[v] then
    		self.m_leftCardsTab[v] = nil
    	end
    end
    self.m_waitPos = {}
    for i=1,5 do
    	local temp = {}
        temp.x= 220 + (i-1)*30*1.3
        temp.y = 20
        self.m_waitPos[i] = {}
        self.m_waitPos[i].pos = temp
    end
    self.m_alignment = {}
    self.m_moveType = nil
    self.m_began = nil
    self.m_ended = nil
end

--[[--
    创建ui入口并初始化数据
]]
function game_teamRaid_adjust.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    return rootScene;
end

return game_teamRaid_adjust;