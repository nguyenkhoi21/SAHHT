local game_TeamTask_checkHero_scene = {
	sellight = nil,
    m_seltab = nil,
    m_btn_porp = nil,
    m_btn_equip = nil,
    m_btn_skill = nil,
    m_node_porp = nil,
    m_node_equip = nil,
    m_node_skill = nil,
    m_sp_team_boss_bg = nil,

    m_boss_id = nil,
    m_boss_level= nil,
    m_selectIndex = nil,
    m_cardsTab = nil,
    m_ccbNode = nil,

    m_name_lb = nil,
    m_lv_lb = nil,
    m_short_story_label = nil,
    m_occupation_icon = nil,
    m_anim_node = nil,
    m_des_lb = nil,
    
    m_condition = nil,
    m_node_skillpos = nil,
    m_boss_type = nil,

    m_isMycreate = nil,
    m_teamid = nil,

    m_node_skillex = nil,

}

function game_TeamTask_checkHero_scene:destroy(  )
	-- body
    self.sellight = nil;
    self.m_seltab = nil;
    self.m_btn_porp  = nil;
    self.m_btn_equip = nil;
    self.m_btn_skill = nil;
    self.m_node_porp  = nil;
    self.m_node_equip = nil;
    self.m_node_skill = nil;
    self.m_sp_team_boss_bg = nil;

    self.m_boss_id = nil;
    self.m_boss_level= nil;
    self.m_selectIndex = nil;
    self.m_cardsTab = nil;

    self.m_ccbNode = nil;

    self.m_name_lb = nil;
    self.m_lv_lb = nil;
    self.m_short_story_label = nil;
    self.m_occupation_icon = nil;
    self.m_anim_node = nil;
    self.m_des_lb = nil;

    self.m_condition = nil;
    self.m_node_skillpos = nil;
    self.m_boss_type = nil;

    self.m_isMycreate = nil;
    self.m_teamid = nil;
    self.m_node_skillex = nil;
end


function game_TeamTask_checkHero_scene:back()
	-- game_scene:enterGameUi("game_main_scene",{gameData = nil,  openPop = nil});
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
            game_scene:enterGameUi("game_TeamTask_main",{gameData = data})
        end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_index"), http_request_method.GET, nil,"team_fight_index")
end

function game_TeamTask_checkHero_scene:createUi()
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then -- 返回
    		self:back()
    	elseif btnTag ==2 then -- 选定参战

            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    
                    local function responseMethod(tag,gameData)
                        local data = gameData:getNodeWithKey("data")
                        data = json.decode(data:getFormatBuffer())
                        if data and  data.team_info and next(data.team_info) and data.team_id and data.team_id ~= "" then
                            game_scene:enterGameUi("ui_teamTask_readyScene",{gameData = data,team_id = self.m_teamid })
                        else
                            game_util:addMoveTips({text = "Lập đội thất bại"})
                        end

                    end
                    local params = {}
                    
                    if self.m_isMycreate == 1 then
                        params.boss_id = self.m_boss_id 
                        params.boss_level = self.m_boss_level
                        params.cards_id = self.m_cardsTab[self.m_selectIndex].key
                        cclog(" create team to ready     params.cards_id  ----   "..params.cards_id)
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_creat_team"), http_request_method.GET, params,"team_fight_creat_team")
                    elseif self.m_isMycreate == 0 then
                        params.cards_id = self.m_cardsTab[self.m_selectIndex].key
                        params.team_id = self.m_teamid
                        cclog(" join team to ready       params.cards_id  ----   "..params.cards_id)
                        cclog(" join team to ready       params.team_id    ------   "..params.team_id)
                        -- api/?method=team_fight.join_team&cards_id=35400-1486746205-WuXgZH|h11234567&team_id=teamfight_2017/10/20_h11234566_1_1_3&user_token=h11234567
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_join_team"), http_request_method.GET, params,"team_fight_join_team")
                    end
                    game_util:closeAlertView();
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                text = "Sau khi chọn thẻ vào đội, không thể đổi thẻ hoặc thoát, xác định chứ?",      --可缺省
                onlyOneBtn = false,
            }
            game_util:openAlertView(t_params);

        elseif btnTag == 301 then -- 属性
            self.m_seltab = 1
            self:refreshLeftInfo(self.m_selectIndex)
        elseif btnTag == 302 then -- 装备
            self.m_seltab = 2
            self:refreshLeftInfo(self.m_selectIndex)
        elseif btnTag == 303 then -- 技能
            self.m_seltab = 3
            self:refreshLeftInfo(self.m_selectIndex)
    	
    	end
    end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_teamTask_checkHero_scene.ccbi");
    -- self.m_des_lb = ccbNode:labelTTFForName("m_des_lb")
    -- self.m_reward_node = ccbNode:nodeForName("m_reward_node")
    self.m_heroList_node = ccbNode:nodeForName("m_heroList_node")

    self.m_btn_porp = ccbNode:controlButtonForName("m_btn_porp")
    self.m_sp_team_boss_bg = ccbNode:spriteForName("m_sp_team_boss_bg")
    self.m_btn_equip = ccbNode:controlButtonForName("m_btn_equip")
    self.m_btn_skill = ccbNode:controlButtonForName("m_btn_skill")
    self.m_node_porp = ccbNode:nodeForName("m_node_porp")
    self.m_node_equip = ccbNode:nodeForName("m_node_equip")
    self.m_node_skill = ccbNode:nodeForName("m_node_skill")
    self.m_node_skillpos = ccbNode:nodeForName("m_node_skillpos")
    
    self.m_name_lb = ccbNode:labelTTFForName("m_name_lb")
    self.m_lv_lb = ccbNode:labelTTFForName("m_lv_lb")
    self.m_short_story_label = ccbNode:labelTTFForName("m_short_story_label")
    self.m_occupation_icon = ccbNode:spriteForName("m_occupation_icon")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_des_lb = ccbNode:labelTTFForName("m_des_lb")
    self.m_node_skillex = ccbNode:nodeForName("m_node_skillex")
    self.m_condition = ccbNode:nodeForName("m_condition")

    self.m_ccbNode = ccbNode
    return ccbNode
end


function game_TeamTask_checkHero_scene:createTaskTable(viewSize, tableData)
    tableData = tableData or {}
    local count = game_util:getTableLen(tableData)
    local charapter = getConfig(game_config_field.character_detail)
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+20;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionVertical; -- 纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_teamTask_teamItem.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5 - 10));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local root_node = ccbNode:nodeForName("root_node")
            local m_icon_node = ccbNode:spriteForName("m_icon_node")
            local sellight = ccbNode:spriteForName("light_add")

            root_node:removeAllChildrenWithCleanup(true)
            m_icon_node:removeAllChildrenWithCleanup(true)

            local itemData = tableData[index+1]
            local itemCfg = charapter:getNodeWithKey(itemData.cards_info_base.c_id)
            local icon = game_util:createCardIconByCfg(itemCfg,itemData.cards_info_base) 
            local name_after = game_util:getCardName(itemData.cards_info_base,itemCfg)
            local tempLabel = game_util:createLabelTTF({text = name_after,color = ccc3(230,160,0),fontSize = 9});
            if icon then
                local iconSize = icon:getContentSize()
                tempLabel:setPosition(ccp(iconSize.width*0.5,-10))
                icon:addChild(tempLabel)
                icon:setScale(0.9)
                icon:setPosition(ccp(0,18))
                icon:setAnchorPoint(ccp(0.5,0.5))
                m_icon_node:addChild(icon,10,10)

                if self.m_selectIndex == index +1 then
                    self.m_selIcon = m_icon_node
                    self.sellight = sellight
                    self.sellight:setVisible(true)
                else
                    sellight:setVisible(false)
                    m_icon_node:setVisible(true)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            if self.m_selIcon ~= nil then
                self.m_selIcon:setVisible(true)
                self.sellight:setVisible(false)
            end
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local m_icon_node = ccbNode:nodeForName("m_icon_node")
            local icon = tolua.cast(ccbNode:getChildByTag(10),"CCSprite")
            local sellight = ccbNode:spriteForName("light_add")
            self.sellight = sellight
            self.sellight:setVisible(true)
            self.m_selIcon = m_icon_node
            self.m_selectIndex = index + 1
            self:refreshLeftInfo(self.m_selectIndex)
        end
    end
    return TableViewHelper:create(params);
end


function game_TeamTask_checkHero_scene:refreshLeftInfo(index)
    --boss_id
    self.m_btn_porp:setEnabled(self.m_seltab~=1)
    self.m_btn_equip:setEnabled(self.m_seltab~=2)
    self.m_btn_skill:setEnabled(self.m_seltab~=3)
    self.m_node_porp:setVisible(self.m_seltab==1)
    self.m_node_equip:setVisible(self.m_seltab==2)
    self.m_node_skill:setVisible(self.m_seltab==3)
    local data = self.m_cardsTab[index] or self.m_cardsTab[tostring(index)]
    if data then
        if self.m_seltab == 1 then
            self.m_ccbNode:labelTTFForName("m_life_label"):setString(math.floor(data.cards_info.hp))
            self.m_ccbNode:labelTTFForName("m_physical_atk_label"):setString(math.floor(data.cards_info.patk))
            self.m_ccbNode:labelTTFForName("m_magic_atk_label"):setString(math.floor(data.cards_info.matk))
            self.m_ccbNode:labelTTFForName("m_def_label"):setString(math.floor(data.cards_info.def))
            self.m_ccbNode:labelTTFForName("m_speed_label"):setString(math.floor(data.cards_info.speed))
            self.m_ccbNode:labelTTFForName("m_fire_label"):setString(math.floor(data.cards_info.fire))
            self.m_ccbNode:labelTTFForName("m_water_label"):setString(math.floor(data.cards_info.water))
            self.m_ccbNode:labelTTFForName("m_wind_label"):setString(math.floor(data.cards_info.wind))
            self.m_ccbNode:labelTTFForName("m_earth_label"):setString(math.floor(data.cards_info.earth))
            self.m_ccbNode:labelTTFForName("m_fire_dfs_label"):setString(math.floor(data.cards_info.fire_dfs))
            self.m_ccbNode:labelTTFForName("m_water_dfs_label"):setString(math.floor(data.cards_info.water_dfs))
            self.m_ccbNode:labelTTFForName("m_wind_dfs_label"):setString(math.floor(data.cards_info.wind_dfs))
            self.m_ccbNode:labelTTFForName("m_earth_dfs_label"):setString(math.floor(data.cards_info.earth_dfs))
            self.m_ccbNode:labelTTFForName("m_life_label2"):setString("+"..math.floor(tonumber(data.cards_info.hp))-math.floor(tonumber(data.cards_info_base.hp)))
            self.m_ccbNode:labelTTFForName("m_physical_atk_label2"):setString("+"..math.floor(tonumber(data.cards_info.patk))-math.floor(tonumber(data.cards_info_base.patk)))
            self.m_ccbNode:labelTTFForName("m_magic_atk_label2"):setString("+"..math.floor(tonumber(data.cards_info.matk))-math.floor(tonumber(data.cards_info_base.matk)))
            self.m_ccbNode:labelTTFForName("m_def_label2"):setString("+"..math.floor(tonumber(data.cards_info.def))-math.floor(tonumber(data.cards_info_base.def)))
            self.m_ccbNode:labelTTFForName("m_speed_label2"):setString("+"..math.floor(tonumber(data.cards_info.speed))-math.floor(tonumber(data.cards_info_base.speed)))
            self.m_ccbNode:labelTTFForName("m_fire_label2"):setString("+"..math.floor(tonumber(data.cards_info.fire))-math.floor(tonumber(data.cards_info_base.fire)))
            self.m_ccbNode:labelTTFForName("m_water_label2"):setString("+"..math.floor(tonumber(data.cards_info.water))-math.floor(tonumber(data.cards_info_base.water)))
            self.m_ccbNode:labelTTFForName("m_wind_label2"):setString("+"..math.floor(tonumber(data.cards_info.wind))-math.floor(tonumber(data.cards_info_base.wind)))
            self.m_ccbNode:labelTTFForName("m_earth_label2"):setString("+"..math.floor(tonumber(data.cards_info.earth))-math.floor(tonumber(data.cards_info_base.earth)))
            self.m_ccbNode:labelTTFForName("m_fire_dfs_label2"):setString("+"..math.floor(tonumber(data.cards_info.fire_dfs))-math.floor(tonumber(data.cards_info_base.fire_dfs)))
            self.m_ccbNode:labelTTFForName("m_water_dfs_label2"):setString("+"..math.floor(tonumber(data.cards_info.water_dfs))-math.floor(tonumber(data.cards_info_base.water_dfs)))
            self.m_ccbNode:labelTTFForName("m_wind_dfs_label2"):setString("+"..math.floor(tonumber(data.cards_info.wind_dfs))-math.floor(tonumber(data.cards_info_base.wind_dfs)))
            self.m_ccbNode:labelTTFForName("m_earth_dfs_label2"):setString("+"..math.floor(tonumber(data.cards_info.earth_dfs))-math.floor(tonumber(data.cards_info_base.earth_dfs)))
        elseif self.m_seltab == 2 then
            local talismandata = {"","","",""}

            local function onClickequip( event, target  )
                local tagNode = tolua.cast(target, "CCNode");
                local btnTag = tagNode:getTag();

                local tempdata = {}
                for k,v in pairs(data.custom_info.equip_info.equip_pos) do
                    for k1,v1 in pairs(v) do
                        table.insert(tempdata,v1)
                    end
                end

                local suitCfg = json.decode(getConfig(game_config_field.suit):getFormatBuffer())

                local suit = data.custom_info.equip_info._equip[tempdata[btnTag]..""].suit or 0
                local suittable = {}
                local cursuitcfg = suitCfg[suit..""]
                if cursuitcfg then
                    suittable = cursuitcfg.part
                end
                local cidtemp = {}
                for k,v in pairs(data.custom_info.equip_info._equip) do
                    cidtemp[v.c_id..""] = v.suit
                end
                for k,v in pairs(suittable) do
                    if cidtemp[v..""] and cidtemp[v..""].."" == suit.."" then
                    else
                        suittable[k] = 0
                    end
                end
                game_scene:addPop("game_equip_info_pop",{
                            openType  = 12,
                            isnoneBtn = true,
                            suitfromTeam = suit.."",
                            posEquipData = suittable,
                            tGameData = data.custom_info.equip_info._equip[tempdata[btnTag]..""]});

            end

            for k,v in pairs(data.custom_info.equip_info.equip_pos) do
                for k1,v1 in pairs(v) do
                    self.m_ccbNode:spriteForName("m_equip_"..k1):removeAllChildrenWithCleanup(true)
                    if data.custom_info.equip_info._equip[v1..""] and data.custom_info.equip_info._equip[v1..""].c_id then
                        local icon = game_util:createEquipIconByCid(data.custom_info.equip_info._equip[v1..""].c_id)
                        self.m_ccbNode:spriteForName("m_equip_"..k1):addChild(icon)
                        icon:setAnchorPoint(ccp(0,0))
                        self.m_ccbNode:spriteForName("m_ming_"..k1):setVisible(data.custom_info.equip_info._equip[v1..""].bind_card and data.custom_info.equip_info._equip[v1..""].bind_card ~= "")
                        local button = game_util:createCCControlButton("public_weapon.png","",onClickequip)
                        self.m_ccbNode:spriteForName("m_equip_"..k1):addChild(button)
                        button:setPosition(ccp(22,22))
                        button:setTag(tonumber(k1))
                        button:setOpacity(0)
                        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
                    else
                        self.m_ccbNode:spriteForName("m_ming_"..k1):setVisible(false)
                    end
                end
            end

            local function subStr(str,k)
                local b = string.reverse(str)
                local f = string.find(b, "-")
                if f then
                    local len = string.len(str)
                    local pos = len - f + 2
                    return string.sub(str, pos,len) 
                else
                    return str
                end
            end

            local gemdata = {}
                -- cclog2(data,"data-=-=----------")
                -- cclog2(data.custom_info,"data.custom_info-=-=----------")
                -- cclog2(data.custom_info.gem_pos,"data.custom_info.gem_pos-=-=----------")
                -- cclog2(data.custom_info.gem_pos.gem_pos,"data.custom_info.gem_pos.gem_pos-=-=----------")
            -- for k,v in pairs(data.custom_info.gem_pos.gem_pos) do
            for k,v in pairs(data.custom_info.gem_pos) do
                for k1,v1 in pairs(v) do
                    table.insert(gemdata,v1)
                end
            end

            local function onClickgem( event, target  )
                local tagNode = tolua.cast(target, "CCNode");
                local btnTag = tagNode:getTag();
                local str = subStr(tostring(gemdata[btnTag]),"-")
                game_scene:addPop("gem_system_info_pop",{tGameData = {count = 1,c_id = str},openType=4});
            end

            for k,v in pairs(gemdata) do
                local str = subStr(tostring(v),"-")
                self.m_ccbNode:spriteForName("m_gem_"..k):removeAllChildrenWithCleanup(true)
                if str and str ~="" then
                    cclog("     str   "  ..str)
                    local gemIcon,gemName = game_util:createGemIconByCid(str)
                    if  gemIcon  then
                        self.m_ccbNode:spriteForName("m_gem_"..k):addChild(gemIcon)
                        gemIcon:setAnchorPoint(ccp(0,0))
                        gemIcon:setPosition(ccp(4,4))
                        local button = game_util:createCCControlButton("public_weapon.png","",onClickgem)
                        self.m_ccbNode:spriteForName("m_gem_"..k):addChild(button)
                        button:setPosition(ccp(4,4))
                        button:setAnchorPoint(ccp(0,0))
                        button:setTag(tonumber(k))
                        button:setOpacity(0)
                        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
                    end
                end
            end

            local talisman = getConfig(game_config_field.talisman)
            local function onClicktalisman( event, target  )
                local tagNode = tolua.cast(target, "CCNode");
                local btnTag = tagNode:getTag();

                local tempdata = {}
                for k,v in pairs(data.custom_info.talisman_info.talisman_pos) do
                    for k1,v1 in pairs(v) do
                        table.insert(tempdata,v1)
                    end
                end
                local selSort = 1
                if math.floor((btnTag+1)/2) < 3 then
                    selSort = 1
                else
                    selSort = 0
                end
                game_scene:addPop("game_magic_info_pop",{
                                    isnoneBtn = true,
                                    tGameData = data.custom_info.talisman_info._talisman[tempdata[btnTag]],
                                    forging_attr = data.cards_info.talisman_skill_forging[btnTag],
                                    magicType = selSort,});
            end

            for k,v in pairs(data.custom_info.talisman_info.talisman_pos) do
                for k1,v1 in pairs(v) do
                    self.m_ccbNode:spriteForName("m_magic_"..k1):removeAllChildrenWithCleanup(true)
                    if data.custom_info.talisman_info._talisman[v1] and data.custom_info.talisman_info._talisman[v1].c_id and data.custom_info.talisman_info._talisman[v1].c_id.."" ~= "" then

                        local itemCfg = talisman:getNodeWithKey(tostring(data.custom_info.talisman_info._talisman[v1].c_id))
                        local icon = game_util:createMagicIcon(itemCfg)
                        icon:setAnchorPoint(ccp(0,0))
                        self.m_ccbNode:spriteForName("m_magic_"..k1):addChild(icon)
                        local button = game_util:createCCControlButton("public_weapon.png","",onClicktalisman)
                        self.m_ccbNode:spriteForName("m_magic_"..k1):addChild(button)
                        button:setAnchorPoint(ccp(0,0))
                        button:setTag(tonumber(k1))
                        button:setOpacity(0)
                        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
                    end
                end
            end
        elseif self.m_seltab == 3 then
            local skilldata = {}
            local skilldatasort = {}
            skilldata["1"] = {tb = data.cards_info.s_1 or {},id = 1}
            skilldata["2"] = {tb = data.cards_info.s_2 or {},id = 2}
            skilldata["3"] = {tb = data.cards_info.s_3 or {},id = 3}
            skilldata["4"] = {tb = data.cards_info.s_4 or {},id = 4}
            skilldata["5"] = {tb = data.cards_info.s_5 or {},id = 5}
            for k,v in pairs(skilldata) do
                if v.tb.avail and v.tb.s then
                    if  v.tb.avail.."" ~= "2" or v.tb.s == "0" then
                        skilldata[k] = nil
                    else
                        table.insert(skilldatasort,v)
                    end
                end
            end
            table.sort( skilldatasort, function( a,b )
                return a.id < b.id
            end )

            self.m_node_skillex:setVisible(#skilldatasort > 3)

            local function onClickBtn( event, target  )
                local tagNode = tolua.cast(target, "CCNode");
                local btnTag = tagNode:getTag();
                game_scene:addPop("skills_activation_pop",{skillData = skilldatasort[btnTag].tb,selHeroId=-1,posIndex = tonumber(btnTag)%10})
            end

            self.m_node_skillpos:removeAllChildrenWithCleanup(true)
            for k,v in pairs(skilldatasort) do
                local skill_detail_cfg = getConfig(game_config_field.skill_detail)
                local skillJsonData = skill_detail_cfg:getNodeWithKey(tostring(v.tb.s))
                local skill_icon_spr = game_util:createSkillIconByCfg(skillJsonData,v.tb.avail)
                local width = skill_icon_spr:getContentSize().width/2
                self.m_node_skillpos:addChild(skill_icon_spr)
                local skill_icon_button = game_util:createCCControlButton("public_weapon.png","",onClickBtn)
                self.m_node_skillpos:addChild(skill_icon_button)
                skill_icon_button:setTag(k)
                skill_icon_button:setOpacity(0)
                skill_icon_button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
                if k<4 then
                    skill_icon_spr:setPosition(ccp(-10+k*80 , 130))
                    skill_icon_button:setPosition(ccp(-10+k*80 , 130))
                else
                    skill_icon_spr:setPosition(ccp(-10+(k-3)*80 , 30))
                    skill_icon_button:setPosition(ccp(-10+(k-3)*80 , 30))
                end
                skill_icon_spr:setScale(0.8)

                local skill_label_name = game_util:createLabelTTF({text = skillJsonData:getNodeWithKey("skill_name"):toStr(),fontSize = 8}) 
                skill_icon_spr:addChild(skill_label_name)
                skill_label_name:setPosition(ccp(skill_icon_spr:getContentSize().width/2,skill_icon_spr:getContentSize().height*1.2))
            end
        end

    end

end

function game_TeamTask_checkHero_scene:refreshTableView()
	-- body
	local cardDataTab = {}
	for k,v in pairs(self.m_gameData.all_cards) do
		cardDataTab[#cardDataTab+1] = v
		cardDataTab[#cardDataTab].key = k
	end  
	self.m_cardsTab = cardDataTab
	local tableView = self:createTaskTable(self.m_heroList_node:getContentSize(),cardDataTab)

    if tableView then
        self:refreshLeftInfo(self.m_selectIndex)
        self.m_heroList_node:removeAllChildrenWithCleanup(true)
        self.m_heroList_node:addChild(tableView)
    end
end


function game_TeamTask_checkHero_scene:refreshUi()
	-- body

    self:refreshTableView()

    local animFile = self.m_bigBossCfg.animation

    local strtb = self:getBossTypeStr(self.m_boss_type)
    -- self.m_des_lb:setString(str)


    if #strtb == 1 then
        local label = game_util:createLabelTTF({text = strtb[1],fontSize = 10}) 
        self.m_condition:addChild(label)
        label:setPosition(15,self.m_condition:getContentSize().height-label:getContentSize().height)
        label:setAnchorPoint(ccp(0,0.5))

    else
        for k,v in pairs(strtb) do
            local label = game_util:createLabelTTF({text =k..". ".. strtb[k],fontSize = 10}) 
            self.m_condition:addChild(label)
            label:setPosition(15,self.m_condition:getContentSize().height-label:getContentSize().height*k)
            label:setAnchorPoint(ccp(0,0.5))
        end
    end

    self.m_name_lb:setString(self.m_bigBossCfg.name.."")
    self.m_lv_lb:setString(self.m_boss_level.."")


    local race_cfg = getConfig(game_config_field.race)
    local race_item_cfg = race_cfg:getNodeWithKey(self.m_bigBossCfg["race"])
    if race_item_cfg then
        self.m_short_story_label:setString(race_item_cfg:getNodeWithKey("name"):toStr())
    else
        self.m_short_story_label:setString("Vô chủng tộc")
    end

    local occupation_cfg = getConfig(game_config_field.occupation)
    local occupation_item_cfg = occupation_cfg:getNodeWithKey(animFile)
    if occupation_item_cfg then
        local occupationType = occupation_item_cfg:toInt()
        local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation"..occupationType..".png")
        if spriteFrame then
            self.m_occupation_icon:setDisplayFrame(spriteFrame)
        end
    end

    -- local anim = game_util:createIdelAnim(animFile,0)

    local anim = game_util:createIdelAnim(animFile,0,nil,nil,nil,nil,nil,true)
    if anim then
        self.m_anim_node:removeAllChildrenWithCleanup(true)
        self.m_sp_team_boss_bg:removeAllChildrenWithCleanup(true)
        local bossheight = anim:getContentSize().height
        local tarheight = self.m_sp_team_boss_bg:getContentSize().height*0.6
        local r = (tarheight*1.0)/(bossheight*1.0)

        anim:setScale(r+0.1)
        anim:setAnchorPoint(ccp(0.5,0))
        self.m_anim_node:addChild(anim)
    end
end

function game_TeamTask_checkHero_scene:getBossTypeStr(boss_type)
    --绿 [color=ff00C000]&[/color]  白 [color=ffFFFFFF]&[/color]  淡蓝 [color=ff6DFFFF]&[/color]  黄 [color=ffFFFF00]&[/color]  红 [color=ffED0000]&[/color]
    -- local str = ""
    local strtb = {}
    if boss_type["race"] then -- 绿色
        -- str =  RACE_SORT_TAB["type_" .. boss_type["race"]].name ..",  "
        table.insert(strtb,RACE_SORT_TAB["type_" .. boss_type["race"]].name)
    end
    if boss_type["sex"] then --淡蓝色
        -- str = str .. (boss_type["sex"] == 0 and "女性角色" or "男性角色") ..",  "
        table.insert(strtb,(boss_type["sex"] == 0 and "Nhân vật nữ" or "Nhân vật nam"))
    end
    if boss_type["bre"] then --黄色
        -- str = str ..  "转生高于" .. boss_type["bre"]..",  "
        table.insert(strtb,"Chuyển sinh cao hơn" .. boss_type["bre"])
    end
    if boss_type["super_step"] then --红色
        -- str = str .. "超进化高于" .. HERO_QUALITY_COLOR_TABLE_2[boss_type["super_step"]].name 
        table.insert(strtb,"Siêu tiến hóa cao hơn" .. HERO_QUALITY_COLOR_TABLE_2[boss_type["super_step"]].name )
    end
    return strtb
end


-- function game_TeamTask_checkHero_scene:getBossTypeStr(boss_type)
--     --绿 [color=ff00C000]&[/color]  白 [color=ffFFFFFF]&[/color]  淡蓝 [color=ff6DFFFF]&[/color]  黄 [color=ffFFFF00]&[/color]  红 [color=ffED0000]&[/color]
--     local str = ""
--     if boss_type["race"] then -- 绿色
--         str = "[color=ff00C000]".. RACE_SORT_TAB["type_" .. boss_type["race"]].name .."[/color]"
--     end
--     if boss_type["sex"] then --淡蓝色
--         str = str .. (str=="" and "" or "[color=ffFFFFFF]&[/color]") .. "[color=ff6DFFFF]" .. (boss_type["sex"] == 0 and "女性角色" or "男性角色") .. "[/color]"
--     end
--     if boss_type["bre"] then --黄色
--         str = str .. (str=="" and "" or "[color=ffFFFFFF]&[/color]") .. "[color=ffFFFF00]转生高于" .. boss_type["bre"] .. "[/color]"
--     end
--     if boss_type["super_step"] then --红色
--         str = str .. (str=="" and "" or "[color=ffFFFFFF]&[/color]") .. "[color=ffED0000]超进化高于" .. HERO_QUALITY_COLOR_TABLE_2[boss_type["super_step"]].name .. "[/color]"
--     end
--     return str
-- end


function game_TeamTask_checkHero_scene:init( t_params )
	-- body

    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    else
        self.m_gameData = {}
    end
    -- cclog2(self.m_gameData,"game_TeamTask_checkHero_scene  m_gameData ")
    self.m_selectIndex = t_params.index or 1
    
    self.m_boss_id = t_params.boss_id
    self.m_boss_level = t_params.boss_level 

    self.m_seltab = 1
    self.boss_type = self.m_gameData.all_cards
    self.m_boss_langid = t_params.boss_langid

    self.m_boss_type = self.m_gameData.boss_type
    self.m_isMycreate = t_params.isMycreate
    self.m_teamid = t_params.team_id

    self.chapter_info_boss = getConfig(game_config_field.chapter_info);
    self.m_bigBossCfg = json.decode(getConfig(game_config_field.boss_info):getNodeWithKey(self.m_boss_langid):getFormatBuffer())
end

function game_TeamTask_checkHero_scene:create( t_params )
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end
return game_TeamTask_checkHero_scene