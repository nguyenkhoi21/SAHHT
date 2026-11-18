-- 团队副本    选择卡牌
local game_teamRaid_signUp_scene = {
    m_anim_node = nil,
    m_list_node = nil,
    text_scroll = nil,
    m_ccbNode = nil,
    m_selSprite = nil,
    m_tGameData = nil,
    m_cards_Tab = nil,
    m_EnterFlag = nil,
    m_EnterType = nil,
    m_maxCount = nil,
    m_raid_id = nil,
    m_page = nil,
    m_teamListIndex = nil,
    m_selectTab = nil,
    m_selectIndex = nil,
    m_flag1 = nil,
    m_flag2 = nil,
    m_flag3 = nil,
}
local attr_tab = {201,202,203,204}
local occu_tab = {1,2,3,4}
function game_teamRaid_signUp_scene:destroy(  )
	-- body
    cclog(" -----------   game_teamRaid_signUp_scene   destroy   -----------------   ")
    self.m_anim_node = nil;
    self.m_list_node = nil;
    self.text_scroll = nil;
    self.m_ccbNode = nil;
    self.m_selSprite = nil;
    self.m_tGameData = nil;
    self.m_cards_Tab = nil;
    self.m_EnterFlag = nil;
    self.m_EnterType = nil;
    self.m_maxCount = nil;
    self.m_raid_id = nil;
    self.m_page = nil;
    self.m_teamListIndex = nil;
    self.m_selectTab = nil;
    self.m_selectIndex = nil;
    self.m_flag1 = nil;
    self.m_flag2 = nil;
    self.m_flag3 = nil;
end

function game_teamRaid_signUp_scene:back(  )
	-- body
    local function responseMethod( tag, gameData )
        if gameData then
            if self.m_EnterType == "createPrivate" or self.m_EnterType == "createGuild" then
                game_scene:enterGameUi("game_teamRaid_main",{gameData = gameData,enterFlag = self.m_EnterFlag})
            elseif self.m_EnterType == "joinPrivate" or self.m_EnterType == "joinGuild" then
                game_scene:enterGameUi("game_teamRaid_main",{gameData = gameData,enterFlag = self.m_EnterFlag,page = self.m_page,openPopType = "team_list",selectIndex = self.m_teamListIndex})
            end
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_index"), http_request_method.GET, nil,"team_raid_index")
 
end

function game_teamRaid_signUp_scene:createUi(  ) -- test_touch
	-- body
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
        	self:back()
    	elseif btnTag == 2 then  -- 确认选择
            if #self.m_selectTab < 1 then
                game_util:addMoveTips({text = "Hãy chọn ít nhất 1 Thẻ trước!",new_color = ccc3(123,255,255)})
                return
            end
            local t_params = 
            {
                title = "Nhắc nhở",
                okBtnCallBack = function(target,event)
                    require("game_ui.game_pop_up_box").close(); 
                    local params = {}
                    if self.m_EnterType == "createPrivate" or self.m_EnterType == "createGuild" then
                        params.choose_card = self.m_selectTab[1]
                        params.type = self.m_EnterFlag
                        local function responseMethod( tag, gameData )
                            if gameData then
                                game_scene:enterGameUi("game_teamRaid_sec",{gameData = gameData,enterFlag = self.m_EnterFlag})
                                game_util:addMoveTips({text = "Thành lập thành công",new_color = ccc3(123,255,255)})
                            end
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_create_group"), http_request_method.GET, params,"team_raid_create_group")
                    elseif self.m_EnterType == "joinPrivate" or self.m_EnterType == "joinGuild" then
                        params.cards_ids = ""
                        for i=1,#self.m_selectTab do
                            params.cards_ids = params.cards_ids .. self.m_selectTab[i] .. (i == #self.m_selectTab and "" or "_")
                        end
                        params.type = self.m_EnterFlag
                        params.raid_id = self.m_raid_id
                        local function responseMethod( tag, gameData )
                            if gameData then
                                game_scene:enterGameUi("game_teamRaid_main",{gameData = gameData,enterFlag = self.m_EnterFlag,page = self.m_page,openPopType = "team_list",selectIndex = self.m_teamListIndex})
                                game_util:addMoveTips({text = "Báo danh thành công!",new_color = ccc3(123,255,255)})
                                
                            end
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_apply_for_raid"), http_request_method.GET, params,"team_raid_apply_for_raid")
                    end
                end,   --可缺省
                cancelBtnCallBack = function(target,event) cclog("rightBtnCallBack") require("game_ui.game_pop_up_box").close(); end,   --可缺省
                okBtnText = "Xác định",       --可缺省
                onlyOneBtn = false,          --可缺省
                cancelBtnText = "Hủy",
                text = "Bạn xác định muốn báo danh chứ?",      --可缺省
            }
            require("game_ui.game_pop_up_box").show(t_params);
                

    	elseif btnTag == 3 then  -- 已选卡牌
            game_scene:addPop("game_teamRaid_selectCards_pop",{selectCards = self.m_selectTab,allGameData = util.table_copy(self.m_tGameData)})
    	elseif btnTag == 4 then  -- 属性
            self.m_sel_tab = 1 
            self:refreshAttrBtn()
    	elseif btnTag == 5 then  -- 技能
            self.m_sel_tab = 2
            self:refreshAttrBtn()
    	elseif btnTag == 6 then  -- 左

    	elseif btnTag == 7 then  -- 右

        elseif btnTag == 8 then  -- 确认取消选择按钮
            self.m_selectFlag = not self.m_selectFlag
            local filename = self.m_selectFlag and "ui_teamRaid_new_btn_cancle.png" or "ui_teamRaid_new_btn_ok.png"
            game_util:setCCControlButtonBackground(self.m_select_btn,filename,filename,filename)
            if self.m_selectCCB then
                local m_sel_img = self.m_selectCCB:spriteForName("m_sel_img")
                if m_sel_img:isVisible() then
                    m_sel_img:setVisible(false)
                else
                    m_sel_img:setVisible(true)
                end
                -- if flag then  -- 移除
                --     table.remove(self.m_selectTab, key)
                --     m_sel_img:setVisible(false)
                -- else   -- 添加
                --     if game_util:getTableLen(self.m_selectTab) < self.m_maxCount then
                --         self.m_selectTab[#self.m_selectTab+1] = itemData.id
                --         m_sel_img:setVisible(true)
                --     else
                --         game_util:addMoveTips({text = "已选卡牌已达上限！",new_color = ccc3(123,255,255)})
                --     end
             end
    	end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_teamRaid_signUp.ccbi");
    local m_btn_close = ccbNode:controlButtonForName("m_btn_close")
    m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    local m_btn_ok = ccbNode:controlButtonForName("m_btn_ok")
    m_btn_ok:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    local m_btn_select = ccbNode:controlButtonForName("m_btn_select")
    m_btn_select:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.m_btn_detail = ccbNode:controlButtonForName("m_btn_detail")
    self.m_btn_detail:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.m_btn_skill = ccbNode:controlButtonForName("m_btn_skill")
    self.m_btn_skill:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    local m_jiantou_zuo = ccbNode:controlButtonForName("m_jiantou_zuo")
    m_jiantou_zuo:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
	m_jiantou_zuo:setOpacity(0)

    local m_jiantou_you = ccbNode:controlButtonForName("m_jiantou_you")
    m_jiantou_you:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
	m_jiantou_you:setOpacity(0)
    self.m_select_btn = ccbNode:controlButtonForName("m_select_btn")
    self.m_select_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_select_btn:setVisible(false)
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")

    self.m_list_node = ccbNode:nodeForName("m_list_node")
    self.text_scroll = ccbNode:scrollViewForName("text_scroll")
    self.text_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY-999)

    self.m_scroll_porp = ccbNode:scrollViewForName("m_scroll_porp")
    local porpCcbNode = self:createPorpUI()
    local viewSize = porpCcbNode:getContentSize()
    self.m_scroll_porp:addChild(porpCcbNode)
    self.m_scroll_porp:setContentSize(viewSize)
    self.m_scroll_porp:setContentOffset(ccp(0,-185),true)

    self.m_attr_node = ccbNode:nodeForName("m_attr_node")
    self.m_skill_node = ccbNode:nodeForName("m_skill_node")
    self.m_skillTab_node = ccbNode:nodeForName("m_skillTab_node")

    self.m_ccbNode = ccbNode;
    return ccbNode
end




function game_teamRaid_signUp_scene.createPorpUI(self)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_teamRaid_info_item.ccbi");

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


function game_teamRaid_signUp_scene:refreshAttrBtn(  )
    -- body
    self:setCCControlButtonEnabled(self.m_btn_detail,(self.m_sel_tab ~= 1))
    self:setCCControlButtonEnabled(self.m_btn_skill,(self.m_sel_tab ~= 2))
    self.m_attr_node:setVisible(self.m_sel_tab == 1)
    self.m_skill_node:setVisible(self.m_sel_tab == 2)
end
function game_teamRaid_signUp_scene.setCCControlButtonEnabled(self,btn,enabled)
    if btn == nil then return end
    if enabled == true then
        btn:setColor(ccc3(155, 155, 155));
        btn:setEnabled(true);
    else
        btn:setColor(ccc3(255, 255, 255));
        btn:setEnabled(false);
    end
end

function game_teamRaid_signUp_scene:refreshCardInfo(  )
	-- body
    self:refreshCardsInfo(self.m_selectIndex)
end


function game_teamRaid_signUp_scene:createTableView( viewSize ,tempTable )
	-- body
	local tempTable = tempTable or {}
	local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 5; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = #tempTable
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 1
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_teamRaid_hero_item1.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local itemData = tempTable[index+1]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_sel_sprite = ccbNode:spriteForName("m_sel_sprite")
            local m_icon_node = ccbNode:nodeForName("m_icon_node")
            local m_sel_img = ccbNode:spriteForName("m_sel_img")
            if self.m_selectIndex == index+1 then
            	m_sel_sprite:setVisible(true)
            	self.m_selSprite = m_sel_sprite
            else
            	m_sel_sprite:setVisible(false)
            end
            local flag,key = self:checkValueInTable(itemData.id, self.m_selectTab)

            if flag then
            	m_sel_img:setVisible(true)
            else
            	m_sel_img:setVisible(false)
            end
            local icon = game_util:createCardIconByCid(itemData.cards_info.c_id,itemData.cards_info)
            m_icon_node:removeAllChildrenWithCleanup(true)
            if icon then
                icon:setScale(0.5)
                m_icon_node:addChild(icon)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
        local itemData = tempTable[index+1]
    	if eventType == "ended" then
            local flag,key = self:checkValueInTable(itemData.id, self.m_selectTab)
            -- self.m_select_btn:setVisible(true)
            -- self.m_selectFlag = flag
            -- local filename = flag and "ui_teamRaid_new_btn_cancle.png" or "ui_teamRaid_new_btn_ok.png"
            -- game_util:setCCControlButtonBackground(self.m_select_btn,filename,filename,filename)
            -- if flag then

            -- end
    		if self.m_selectIndex == index+1 then
                if self.m_flag3 then
                    self.m_flag3 = false
                    game_util:addMoveTips({text = "Nhấn lại lần nữa để hủy Thẻ đã chọn!",new_color = ccc3(123,255,255)})
                end
    			local m_sel_img = ccbNode:spriteForName("m_sel_img")
    			if flag then  -- 移除
                    table.remove(self.m_selectTab, key)
    				m_sel_img:setVisible(false)
    			else   -- 添加
    				if game_util:getTableLen(self.m_selectTab) < self.m_maxCount then
	    				self.m_selectTab[#self.m_selectTab+1] = itemData.id
	    				m_sel_img:setVisible(true)
	    			else
	    				game_util:addMoveTips({text = "Thẻ đã chọn đã đạt giới hạn tối đa!",new_color = ccc3(123,255,255)})
	    			end
    			end
    		else
                if self.m_flag1 then
                    self.m_flag1 = false
                    game_util:addMoveTips({text = "Nhận lại lần nữa để chọn Thẻ!",new_color = ccc3(123,255,255)})
                end
    			if self.m_selSprite then
    				self.m_selSprite:setVisible(false)
    			end
    			local m_sel_sprite = ccbNode:spriteForName("m_sel_sprite")
    			m_sel_sprite:setVisible(true)
    			self.m_selSprite = m_sel_sprite
    			self.m_selectIndex = index + 1
    			self:refreshCardInfo()
                self.m_selectCCB = ccbNode 
    		end
    	end
    end
    return TableViewHelper:create(params);
end


function game_teamRaid_signUp_scene:refreshCardsInfo( index )
    -- body
    local cardsData = self.m_selectCardsTab[index] or {}
    self.m_anim_node:removeAllChildrenWithCleanup(true)
    if not cardsData then
        return 
    end

    local anim = self:createAnimByData(cardsData)
    if anim then
        anim:setAnchorPoint(ccp(0.5,0))
        self.m_anim_node:addChild(anim)
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


function game_teamRaid_signUp_scene:refreshSkillNode( cardsData )
    -- body
    local posTab = {
        {{x=0.5,y = 0.5}},
        {{x=0.25,y = 0.5},{x=0.75,y = 0.5}},
        {{x=0.17,y = 0.5},{x=0.5,y = 0.5},{x=0.83,y = 0.5}},
        {{x=0.25,y = 0.75},{x=0.75,y = 0.75},{x=0.25,y = 0.25},{x=0.75,y = 0.25}},
        {{x=0.17,y = 0.7},{x=0.5,y = 0.7},{x=0.83,y = 0.7},{x=0.25,y = 0.2},{x=0.75,y = 0.2}},
    }
    local cards_info = cardsData.cards_info or {}
    self.m_skillTab_node:removeAllChildrenWithCleanup(true)
    local skillTab = {}
    local extra_skill = cards_info.extra_skill
    for i=1,5 do
        local cardsSkill = cards_info["s_" .. i]
        if cardsSkill then
            skillTab[#skillTab+1] = cardsSkill
        end
    end
    local pos = posTab[#skillTab]
    local viewSize = self.m_skillTab_node:getContentSize()
    for i=1,#skillTab do
        local skill = skillTab[i]
        local icon,name = game_util:createSkillIconByCid(skill.s, skill.avail)
        if icon then
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setScale(0.55)
            icon:setPosition(ccp(viewSize.width*pos[i].x, viewSize.height*pos[i].y))
            self.m_skillTab_node:addChild(icon)
            local tempLabel = game_util:createLabelTTF({text = name, textAlignment = textAlignment,verticalTextAlignment = verticalTextAlignment,fontSize = 11})
            if tempLabel then
                icon:addChild(tempLabel)
                tempLabel:setAnchorPoint(ccp(0.5,1))
                tempLabel:setPosition(ccp(icon:getContentSize().width*0.5,18-icon:getContentSize().height*0.5))
            end
        end
    end
end
-- 创建卡牌动画
function game_teamRaid_signUp_scene:createAnimByData( data )

    local data = data
    local charapter = getConfig(game_config_field.character_detail)
    local heroData = data.cards_info
    local c_id = heroData and heroData.c_id
    local heroCfg = charapter:getNodeWithKey(tostring(c_id))
    return self:createCardAnimByData(heroData,heroCfg)
end

function game_teamRaid_signUp_scene.createCardAnimByData( self, heroData,heroCfg,animFlag)
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
                    local tempSprite = CCSprite:createWithSpriteFrame(spriteFrame)
                    tempSprite:setAnchorPoint(ccp(0.5,0.1))
                    tempSprite:setPositionX(itemSize.width*0.5)
                    animNode:addChild(tempSprite)
                end
                local spriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dw_light_up.png")
                if spriteFrame2 then
                    local tempSprite = CCSprite:createWithSpriteFrame(spriteFrame2)
                    tempSprite:setAnchorPoint(ccp(0.5,0.1))
                    tempSprite:setPositionX(itemSize.width*0.5)
                    animNode:addChild(tempSprite,1000,1000)
                end
            else
                animNode:setRhythm(1);
            end
            animNode:setAnchorPoint(ccp(0.5,0));

            local occupation_cfg = getConfig(game_config_field.occupation);
            local occupation_item_cfg = occupation_cfg:getNodeWithKey(ainmFile)
            if occupation_item_cfg then
                local occupationType = occupation_item_cfg:toInt();
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupationType .. ".png")
                -- if spriteFrame then
                --     local occupation_icon = CCSprite:createWithSpriteFrame(spriteFrame)
                --     occupation_icon:setPosition(ccp(itemSize.width*0.5 + 57,98));
                --     occupation_icon:setAnchorPoint(ccp(1,0.5));
                --     animNode:addChild(occupation_icon);
                -- end
            end
            animNode:setScale(0.66);
        end
    end
    return animNode,character_ID
end

function game_teamRaid_signUp_scene:selectCardsByType(  )
    -- body
    local tempTab = {}
    local screenType = self.m_selectScreenType or 0
    cclog2(screenType,"    selectCardsByType     ")
    if screenType == 0 then
        return util.table_copy(self.m_cards_Tab)
    else
        if screenType > 200 then  -- 属性筛选
            for k,v in pairs(self.m_cards_Tab) do
                local cards_info = v.cards_info
                local cardId = cards_info.c_id;
                local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(cardId);
                local card_attr = itemConfig:getNodeWithKey("card_attr") and itemConfig:getNodeWithKey("card_attr"):toInt() or 0
                if screenType == card_attr then
                    tempTab[#tempTab+1] = v
                end
            end
        elseif screenType < 200 and screenType > 0 then  -- 职业筛选
            for k,v in pairs(self.m_cards_Tab) do
                local cardId = v.cards_info.c_id;
                local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(cardId);
                if itemConfig:getNodeWithKey("is_skin") then
                    if itemConfig:getNodeWithKey("is_skin"):toInt() ~= 0 then
                        local skinID = itemConfig:getNodeWithKey("is_skin"):toInt()
                        local flag = game_util:isWearSkin(skinID)
                        if flag then
                            local character_detail_cfg = getConfig(game_config_field.character_detail);
                            itemConfig = character_detail_cfg:getNodeWithKey(tostring(skinID));
                        end
                    end
                end
                local animation = itemConfig:getNodeWithKey("animation"):toStr();
                local occupation_cfg = getConfig(game_config_field.occupation);
                local occupation_item_cfg = occupation_cfg:getNodeWithKey(animation)
                local occupation_item_cfg2 = itemConfig:getNodeWithKey("occupation_shade")
                if occupation_item_cfg then
                    local occupationType = occupation_item_cfg:toInt();
                    if occupationType >=0 and occupationType <4 then 
                        if occupationType == screenType-1 then
                            tempTab[#tempTab+1] = v
                        end
                    else
                        local occupationType2 = occupation_item_cfg2:toInt();
                        if occupationType2 == screenType-1 then
                            tempTab[#tempTab+1] = v
                        end
                    end
                end
            end
        end
    end
    return tempTab
end

function game_teamRaid_signUp_scene:checkValueInTable( value, tempTable )
    -- body
    for k,v in pairs(tempTable) do
        if value == v then
            return true,k
        end
    end
    return false
end


function game_teamRaid_signUp_scene:refreshTableVIew(  )
	-- body
    self.m_selSprite = nil
    self.m_selectIndex = 0
    local tempTab = self:selectCardsByType()
    if #tempTab > 0 then
        -- self.m_selectIndex = 1
    end
    self.m_select_btn:setVisible(false)
    self.m_selectCardsTab = util.table_copy(tempTab)
	local tempTableView = self:createTableView(self.m_list_node:getContentSize(),tempTab)
	self.m_list_node:removeAllChildrenWithCleanup(true)
	if tempTableView then
		self.m_list_node:addChild(tempTableView)
	end
end



function game_teamRaid_signUp_scene:refreshBtn( flag )
	-- body
	local flag = flag or 0
	local function onBtnCilck( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if self.m_selectScreenType == btnTag then
            self.m_selectScreenType = 0
        else
            if self.m_flag2 then
                self.m_flag2 = false
                game_util:addMoveTips({text = "Nhấn lại lần nữa để xem toàn bộ Thẻ có thể dùng!",new_color = ccc3(123,255,255)})
            end
            self.m_selectScreenType = btnTag
        end
        self:refreshBtn(self.m_selectScreenType)
    end
	for i=1,4 do
		local fileName1 = "ui_teamRaid_sec_iconbg2.png"
		local fileName2 = "ui_teamRaid_sec_iconbg2.png"
		local attrNode = self.m_ccbNode:spriteForName("m_attr_node" .. i)
		local occuNode = self.m_ccbNode:spriteForName("m_occu_node" .. i)
		if attr_tab[i] and PUBLIC_ABILITY_TABLE["ability_" .. attr_tab[i]] then
			attrNode:setVisible(true)
			attrNode:removeAllChildrenWithCleanup(true)
			local attrIcon = CCSprite:createWithSpriteFrameName(PUBLIC_ABILITY_TABLE["ability_" .. attr_tab[i]].icon);
		    if attrIcon then
		        attrNode:addChild(attrIcon)
		        local viewSize = attrNode:getContentSize()
		        attrIcon:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
		    	local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition( attrIcon:getContentSize().width * 0.5, attrIcon:getContentSize().height * 0.5 )
                button:setOpacity(0)
                button:setScale(0.4)
 	         	button:setZoomOnTouchDown(false);
                button:setTag(attr_tab[i])
				button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
                attrIcon:addChild(button)
		    end
		    if attr_tab[i] == flag then
		    	fileName1 = "ui_teamRaid_sec_iconbg22.png"
		    end
		    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName1))
		    if tempSpriteFrame then
		        attrNode:setDisplayFrame(tempSpriteFrame)
		    end
		else
			attrNode:setVisible(false)
		end

		if occu_tab[i] then
			local occuIcon = CCSprite:createWithSpriteFrameName("public_ocupation" .. i-1 .. ".png");
			occuNode:setVisible(true)
			if occuIcon then
		        occuNode:addChild(occuIcon)
		        local viewSize = occuNode:getContentSize()
		        occuIcon:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
		    	local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition( occuIcon:getContentSize().width * 0.5, occuIcon:getContentSize().height * 0.5 )
                button:setOpacity(0)
                button:setScale(0.4)
 	         	button:setZoomOnTouchDown(false);
                button:setTag(occu_tab[i])
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
                occuIcon:addChild(button)
		    end
		    if occu_tab[i] == flag then
		    	fileName2 = "ui_teamRaid_sec_iconbg22.png"
		    end
		    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName2))
		    if tempSpriteFrame then
		        occuNode:setDisplayFrame(tempSpriteFrame)
		    end
		else
			occuNode:setVisible(false)
		end

	end
    self:refreshTableVIew()


end
function game_teamRaid_signUp_scene:refreshUi(  )
	-- body
    self:refreshBtn()
	self:refreshAttrBtn()

end

function game_teamRaid_signUp_scene:init( t_params )
	-- body
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
       local data = t_params.gameData:getNodeWithKey("data")
       self.m_tGameData = json.decode(data:getFormatBuffer())
    end
    local cards_data = self.m_tGameData.cards_data
    self.m_cards_Tab = {}
    for k,v in pairs(cards_data) do
        self.m_cards_Tab[#self.m_cards_Tab+1] = v
        self.m_cards_Tab[#self.m_cards_Tab].id = k
    end
    self.m_EnterFlag = t_params.enterFlag or 2
    self.m_EnterType = t_params.enterType or ""
    if self.m_EnterType == "createPrivate" or self.m_EnterType == "createGuild" then
        self.m_maxCount = 1
    elseif self.m_EnterType == "joinPrivate" or self.m_EnterType == "joinGuild" then
        self.m_maxCount = 5
    end
    self.m_raid_id = t_params.raid_id
    self.m_page = t_params.page
    self.m_teamListIndex = t_params.selectIndex
    self.m_selectTab = {}
    self.m_selectIndex = 0
    self.m_sel_tab = 1
    self.m_flag1 = true
    self.m_flag2 = true
    self.m_flag3 = true

end

function game_teamRaid_signUp_scene:create( t_params )
	-- body
	local scene = CCLayer:create()
	self:init(t_params)
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end

return game_teamRaid_signUp_scene