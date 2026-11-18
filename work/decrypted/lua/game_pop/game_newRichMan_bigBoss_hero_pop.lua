--深渊boss
local game_newRichMan_bigBoss_hero_pop = {
    m_tGameData = nil,
    m_sel_cardId = nil,
    m_occupation_icon= nil,
    m_btn_skin= nil,
    m_name_label= nil,
    m_race_label= nil,
    m_node_anim= nil,
    m_img_2= nil,

    m_btn_1= nil,
    m_btn_2= nil,
    m_btn_3= nil,
    m_btn_chanllge= nil,

    m_equip_node = nil,
    m_skill_node = nil,
    m_shuxing_node = nil,

    m_title_skillimp = nil,
    m_scroll_skill = nil,
    m_node_main_skill = nil,

    m_tempCard = nil,
    m_cardCfg = nil,

    m_curTab = nil,
    m_skill_tb ={},
    m_extraskill_tb ={},
    m_last_kuang =nil,

    m_sel_skill={},

    --属性
    m_level_label=nil,
    m_life_label=nil,
    m_def_label=nil,
    m_physical_atk_label=nil,
    m_speed_label=nil,
    m_magic_atk_label=nil,
    m_fire_label=nil,
    m_fire_dfs_label=nil,
    m_water_label=nil,
    m_water_dfs_label=nil,
    m_wind_label=nil,
    m_wind_dfs_label=nil,
    m_earth_label=nil,
    m_earth_dfs_label=nil,

    --装备层 保存sp
    m_sp_equip={},
    m_sp_gem={},
    m_sp_magic={},

    -- 具体内容id表 [k..""] = {id = v.."" , isbind=1}
    m_equip_list = {},
    m_gem_list = {},
    m_magic_list = {},

    m_porp = {},
    m_porp_withsuit = {},

    --装备层 保存button
    m_btn_equip = {},
    m_btn_gem = {},
    m_btn_magic = {},

    m_all_equip = {},
    m_all_gem = {},
    m_all_magic = {},


    m_equiplb={},
    m_gemlb={},
    m_magiclb={},
    m_sel_skill = {},
};
--[[--
    销毁ui
]]
function game_newRichMan_bigBoss_hero_pop.destroy(self)
    cclog("-----------------game_newRichMan_bigBoss_hero_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_sel_cardId = nil;
    self.m_occupation_icon= nil;
    self.m_btn_skin= nil;
    self.m_name_label= nil;
    self.m_race_label= nil;
    self.m_node_anim= nil;
    self.m_img_2= nil;

    self.m_btn_1= nil;
    self.m_btn_2= nil;
    self.m_btn_3= nil;
    self.m_btn_chanllge= nil;

    self.m_equip_node = nil;
    self.m_skill_node = nil;
    self.m_shuxing_node = nil;

    self.m_title_skillimp = nil;
    self.m_scroll_skill = nil;
    self.m_node_main_skill = nil;

    self.m_tempCard = nil;
    self.m_cardCfg = nil;

    self.m_curTab = nil;
    self.m_skill_tb =nil;
    self.m_extraskill_tb =nil;
    self.m_last_kuang =nil;
    self.m_sel_skill=nil;


    self.m_level_label=nil;
    self.m_life_label=nil;
    self.m_def_label=nil;
    self.m_physical_atk_label=nil;
    self.m_speed_label=nil;
    self.m_magic_atk_label=nil;
    self.m_fire_label=nil;
    self.m_fire_dfs_label=nil;
    self.m_water_label=nil;
    self.m_water_dfs_label=nil;
    self.m_wind_label=nil;
    self.m_wind_dfs_label=nil;
    self.m_earth_label=nil;
    self.m_earth_dfs_label=nil;

    self.m_sp_equip = nil;
    self.m_sp_gem = nil;
    self.m_sp_magic = nil;

    self.m_equip_list = nil;
    self.m_gem_list = nil;
    self.m_magic_list = nil;

    self.m_porp = nil;
    self.m_porp_withsuit = nil;

    self.m_btn_equip = nil;
    self.m_btn_gem = nil;
    self.m_btn_magic = nil;


    self.m_all_equip = nil;
    self.m_all_gem = nil;
    self.m_all_magic = nil;

    self.m_equiplb=nil;
    self.m_gemlb=nil;
    self.m_magiclb=nil;
    self.m_sel_skill = nil;
end

--[[--
    退出ui
]]
function game_newRichMan_bigBoss_hero_pop.back(self)
    game_scene:removePopByName("game_newRichMan_bigBoss_hero_pop")
end

--[[--
    创建ui
]]
function game_newRichMan_bigBoss_hero_pop.createUi(self)
    local ccbNode = luaCCBNode:create();

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode")
        local btnTag = tagNode:getTag()
        
        if btnTag == 1 then
            self:back()
        elseif btnTag == 2 then
            local function sendRequest()
                local function responseMethod(tag,gameData)
                    game_data:setBattleType("newRichManHero");
                    game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                end

                -- print(table.concat(spring, "_"))
                local _m_equip_list = {}
                local _m_gem_list = {}
                local _m_magic_list = {}
                local selskill = {}

                -- 选装备
                for i = 1,4 do
                    if self.m_equip_list[i..""] == nil then
                        table.insert(_m_equip_list,"0")
                    else
                        table.insert(_m_equip_list,self.m_equip_list[i..""]["id"])
                    end
                end

                -- 选宝石
                for i = 1,4 do
                    if self.m_gem_list[i..""] == nil then
                        table.insert(_m_gem_list,"0")
                    else
                        table.insert(_m_gem_list,self.m_gem_list[i..""]["id"])
                    end
                end

                -- 选法宝
                for i = 1,4 do
                    if self.m_magic_list[i..""] == nil then
                        table.insert(_m_magic_list,"0")
                    else
                        table.insert(_m_magic_list,self.m_magic_list[i..""]["id"])
                    end
                end

                -- 选技能
                for k,v in pairs(self.m_sel_skill) do
                    if k then
                        -- selskill[tonumber(v)] = v..""
                        table.insert(selskill,v)
                    end
                end

                if #selskill<3 then 
                    game_util:addMoveTips({text = "Tối thiểu chọn 3 kỹ năng"})
                    return
                end

                local params = {};
                params.card_id = self.m_sel_cardId
                params.gem=table.concat(_m_gem_list, "_")
                params.equip=table.concat(_m_equip_list, "_")
                params.talisman=table.concat(_m_magic_list, "_")
                params.skill_ids=table.concat(selskill, "_")

                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("depth_boss_fight"), http_request_method.GET, params,"depth_boss_fight")
            end
            sendRequest()
        elseif  btnTag == 3 then
            local function skinCallback()
                self:refreshUi(self.m_curTab)
            end

            game_scene:addPop("game_cardSkin_pop",{cardData = self.m_tempCard, c_id = self.m_tempCard.c_id,fromtype = "newRichMan_bigBoss_hero",callback = skinCallback})

        elseif  btnTag == 11 then
            self.curTab = 1
            self:refreshUi(self.curTab)
        elseif  btnTag == 12 then
            self.curTab = 2
            self:refreshUi(self.curTab)
        elseif  btnTag == 13 then
            self.curTab = 3
            self:refreshUi(self.curTab)
        end

    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_newRichMan_bigBoss_Arm.ccbi");
    local m_close_btn = ccbNode:controlButtonForName("m_btn_back")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)

    self.m_btn_chanllge = ccbNode:controlButtonForName("m_btn_chanllge")
    self.m_btn_chanllge:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)

    self.m_occupation_icon= ccbNode:spriteForName("m_occupation_icon")
    self.m_btn_skin= ccbNode:controlButtonForName("m_btn_skin")
    self.m_btn_skin:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)

    self.m_name_label= ccbNode:labelTTFForName("m_name_label")
    self.m_race_label= ccbNode:labelTTFForName("m_race_label")
    self.m_node_anim= ccbNode:nodeForName("m_node_anim")
    self.m_img_2= ccbNode:spriteForName("m_img_2")

    self.m_btn_1 = ccbNode:controlButtonForName("m_btn_1")
    self.m_btn_2 = ccbNode:controlButtonForName("m_btn_2")
    self.m_btn_3 = ccbNode:controlButtonForName("m_btn_3")
    self.m_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    self.m_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    self.m_btn_3:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)

    self.m_equip_node = ccbNode:nodeForName("m_equip_node")
    self.m_skill_node = ccbNode:nodeForName("m_skill_node")
    self.m_shuxing_node = ccbNode:nodeForName("m_shuxing_node")
    self.m_title_skillimp= ccbNode:spriteForName("m_title_skillimp")

    self.m_scroll_skill = ccbNode:scrollViewForName("m_scroll_skill")

    --属性
    self.m_level_label=ccbNode:labelTTFForName("m_level_label")
    self.m_life_label=ccbNode:labelTTFForName("m_life_label")
    self.m_def_label=ccbNode:labelTTFForName("m_def_label")
    self.m_physical_atk_label=ccbNode:labelTTFForName("m_physical_atk_label")
    self.m_speed_label=ccbNode:labelTTFForName("m_speed_label")
    self.m_magic_atk_label=ccbNode:labelTTFForName("m_magic_atk_label")
    self.m_fire_label=ccbNode:labelTTFForName("m_fire_label")
    self.m_fire_dfs_label=ccbNode:labelTTFForName("m_fire_dfs_label")
    self.m_water_label=ccbNode:labelTTFForName("m_water_label")
    self.m_water_dfs_label=ccbNode:labelTTFForName("m_water_dfs_label")
    self.m_wind_label=ccbNode:labelTTFForName("m_wind_label")
    self.m_wind_dfs_label=ccbNode:labelTTFForName("m_wind_dfs_label")
    self.m_earth_label=ccbNode:labelTTFForName("m_earth_label")
    self.m_earth_dfs_label=ccbNode:labelTTFForName("m_earth_dfs_label")
    self.m_sp_equip={}
    self.m_sp_gem={}
    self.m_sp_magic={}
    self.m_equiplb={}
    self.m_gemlb={}
    self.m_magiclb={}
    self.m_sp_equip["1"]= ccbNode:spriteForName("m_equip_1")
    self.m_sp_equip["2"]= ccbNode:spriteForName("m_equip_2")
    self.m_sp_equip["3"]= ccbNode:spriteForName("m_equip_3")
    self.m_sp_equip["4"]= ccbNode:spriteForName("m_equip_4")
    self.m_sp_gem["1"]= ccbNode:spriteForName("m_gem_1")
    self.m_sp_gem["2"]= ccbNode:spriteForName("m_gem_2")
    self.m_sp_gem["3"]= ccbNode:spriteForName("m_gem_3")
    self.m_sp_gem["4"]= ccbNode:spriteForName("m_gem_4")
    self.m_sp_magic["1"]= ccbNode:spriteForName("m_magic_1")
    self.m_sp_magic["2"]= ccbNode:spriteForName("m_magic_2")
    self.m_sp_magic["3"]= ccbNode:spriteForName("m_magic_3")
    self.m_sp_magic["4"]= ccbNode:spriteForName("m_magic_4")

    self.m_equiplb["1"] = ccbNode:labelTTFForName("m_equiplb_1")
    self.m_equiplb["2"] = ccbNode:labelTTFForName("m_equiplb_2")
    self.m_equiplb["3"] = ccbNode:labelTTFForName("m_equiplb_3")
    self.m_equiplb["4"] = ccbNode:labelTTFForName("m_equiplb_4")
    self.m_gemlb["1"] = ccbNode:labelTTFForName("m_gemlb_1")
    self.m_gemlb["2"] = ccbNode:labelTTFForName("m_gemlb_2")
    self.m_gemlb["3"] = ccbNode:labelTTFForName("m_gemlb_3")
    self.m_gemlb["4"] = ccbNode:labelTTFForName("m_gemlb_4")
    self.m_magiclb["1"] = ccbNode:labelTTFForName("m_magiclb_1")
    self.m_magiclb["2"] = ccbNode:labelTTFForName("m_magiclb_2")
    self.m_magiclb["3"] = ccbNode:labelTTFForName("m_magiclb_3")
    self.m_magiclb["4"] = ccbNode:labelTTFForName("m_magiclb_4")

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    m_root_layer:setTouchEnabled(true);

    self:createroleUi()

    self.m_ccbNode = ccbNode
    return ccbNode;
end

--[[--
    创建角色ui
]]
function game_newRichMan_bigBoss_hero_pop.createroleUi(self)
    --主角动画
    local animFile = self.m_tempCard.animation
    local animNode = game_util:createAnimSequence(animFile,0,self.m_tempCard,self.m_cardCfg);
    if animNode then
        animNode:setRhythm(1);
        game_anim:playSection(animNode,anim_label_name_cfg.daiji)
        animNode:setAnchorPoint(ccp(0.5,0.5))
        self.m_node_anim:addChild(animNode)
    end

    --名称
    self.m_name_label:setString(self.m_cardCfg:getNodeWithKey("name"):toStr())

    --种族
    local race_cfg = getConfig(game_config_field.race)
    local race_item_cfg = race_cfg:getNodeWithKey(self.m_tempCard["race"])
    if race_item_cfg then
        self.m_race_label:setString(race_item_cfg:getNodeWithKey("name"):toStr())
    else
        self.m_race_label:setString("Không phân biệt chủng tộc")
    end

    --职业
    local occupation_cfg = getConfig(game_config_field.occupation)
    local occupation_item_cfg = occupation_cfg:getNodeWithKey(animFile)
    if occupation_item_cfg then
        local occupationType = occupation_item_cfg:toInt()
        local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation"..occupationType..".png")
        if spriteFrame then
            self.m_occupation_icon:setDisplayFrame(spriteFrame)
        end
    end

    if self.m_cardCfg:getNodeWithKey("is_skin")   then 
        if self.m_cardCfg:getNodeWithKey("is_skin"):toInt() ~= 0 then 
            skinId = self.m_cardCfg:getNodeWithKey("is_skin"):toInt()
            self.m_btn_skin:setVisible(true)
        end
    end

end

--[[--
    刷新装备ui
]]
function game_newRichMan_bigBoss_hero_pop.refreshEquipUi(self)
    --装备显示是否可装备
    for i=1,4 do
        local equipData = game_data:getEquipDataByEquipType(i, 2, self.m_all_equip)
        if next(equipData) then
            self.m_equiplb[i..""]:setVisible(true)
        end
    end

    --宝石显示是否可装备
    for i=1,4 do
        local gemData = game_data:getGemDataByGemType(i, self.m_all_gem);
        if next(gemData) then
            self.m_gemlb[i..""]:setVisible(true)
        end
    end

    --法宝显示是否可装备
    for i=1,4 do
        local selSort = i < 3 and 1 or 0
        local magicData = game_data:getMagicDataByMagicType(selSort,self.m_all_magic)
        if next(magicData) then
            self.m_magiclb[i..""]:setVisible(true)
        end
    end


    -- 展示装备 包含命运装备
    for k,v in pairs(self.m_equip_list) do
        local itemData,itemCfg = game_data:getEquipDataById(v.id)

        local icon,name = game_util:createEquipIconByCid(itemData.c_id)
        if self.m_sp_equip[k..""]:getChildByTag(tonumber(k)+1000) ~= nil then
            self.m_sp_equip[k..""]:removeChildByTag(tonumber(k)+1000, true)
        end
        self.m_sp_equip[k..""]:addChild(icon)

        self.m_equiplb[k..""]:setVisible(false)
        icon:setAnchorPoint(ccp(0,0))
        icon:setTag(tonumber(k)+1000)

        if v.isbind == 1 then
            local mingicon = CCSprite:createWithSpriteFrameName("public_icon_ming.png")
            self.m_sp_equip[k..""]:addChild(mingicon)
            mingicon:setPosition(ccp(40,40))
        end
    end

    -- 展示宝石
    for k,v in pairs(self.m_gem_list) do
        local icon,gemName = game_util:createGemIconByCid(v.id)
        if self.m_sp_gem[k..""]:getChildByTag(tonumber(k)+1000) ~= nil then
            self.m_sp_gem[k..""]:removeChildByTag(tonumber(k)+1000, true)
        end

        self.m_sp_gem[k..""]:addChild(icon)
        self.m_gemlb[k..""]:setVisible(false)
        icon:setAnchorPoint(ccp(0.5,0.5))
        icon:setPosition(ccp(self.m_sp_gem[k..""]:getContentSize().width/2,self.m_sp_gem[k..""]:getContentSize().height/2))
        icon:setTag(tonumber(k)+1000)
    end

    -- 展示法宝
    for k,v in pairs(self.m_magic_list) do
        local magicItemData,magicItemCfg = game_data:getMagicDataById(tostring(v.id))
        local icon = game_util:createMagicIcon(magicItemCfg)
        if self.m_sp_magic[k..""]:getChildByTag(tonumber(k)+1000) ~= nil then
            self.m_sp_magic[k..""]:removeChildByTag(tonumber(k)+1000, true)
        end

        self.m_sp_magic[k..""]:addChild(icon)
        self.m_magiclb[k..""]:setVisible(false)
        icon:setAnchorPoint(ccp(0,0))
        icon:setTag(tonumber(k)+1000)
    end

    local function onClick( event, target  )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local sort = tonumber(btnTag)%10

        local btnCallFunc = function( target,event )
        end
        local itemOnClick1 = function (typeName,eid)
            if typeName == "exchanged" then
                if eid then
                    if self.m_equip_list[sort..""] then
                        self:setPorpChangedByEquipChanged(self.m_porp, eid.."",false,sort)
                    end
                    game_scene:removePopByName("game_equip_select_pop")
                    self.m_equip_list[sort..""]= {id = eid.."" , isbind=0}

                    self:setPorpChangedByEquipChanged(self.m_porp, eid.."",true,sort)
                end
            elseif typeName == "unload" then
                self.m_equip_list[sort..""]= nil
                if self.m_sp_equip[sort..""]:getChildByTag(tonumber(sort)+1000) then
                    self.m_sp_equip[sort..""]:removeChildByTag(tonumber(sort)+1000, true)
                end
                if self.m_equip_list[sort..""] then
                    self:setPorpChangedByEquipChanged(self.m_porp, eid.."",false,sort)
                end
            end
            game_scene:removePopByName("game_equip_select_pop")
            self:refreshUi(self.m_curTab)
        end

        local itemOnClick2 = function (typeName,gid)
            if typeName == "exchanged" then
                if gid then
                    if self.m_gem_list[sort..""] then
                        self:setPorpChangedByGemChanged(self.m_porp, gid.."",false)
                    end
                    game_scene:removePopByName("gem_system_select_pop")
                    self.m_gem_list[sort..""]= {id = gid.."" , isbind=0}

                    self:setPorpChangedByGemChanged(self.m_porp, gid.."",true)
                end
            elseif typeName == "unload" then
                self.m_gem_list[sort..""]= nil
                if self.m_sp_gem[sort..""]:getChildByTag(tonumber(sort)+1000) then
                    self.m_sp_gem[sort..""]:removeChildByTag(tonumber(sort)+1000, true)
                end
                if self.m_gem_list[sort..""] then
                    self:setPorpChangedByGemChanged(self.m_porp, gid.."",false)
                end
            end
            game_scene:removePopByName("gem_system_select_pop")
            self:refreshUi(self.m_curTab)
        end

        local itemOnClick3 = function (typeName,mid)
            if typeName == "exchanged" then
                if mid then
                    if self.m_magic_list[sort..""] then
                        self:setPorpChangedByMagicChanged(self.m_porp, mid.."",false)
                    end
                    game_scene:removePopByName("game_magic_select_pop")
                    self.m_magic_list[sort..""]= {id = mid.."" , isbind=0}

                    self:setPorpChangedByMagicChanged(self.m_porp, mid.."",true)
                end
            elseif typeName == "unload" then
                self.m_magic_list[sort..""]= nil
                if self.m_sp_magic[sort..""]:getChildByTag(tonumber(sort)+1000) then
                    self.m_sp_magic[sort..""]:removeChildByTag(tonumber(sort)+1000, true)
                end
                if self.m_magic_list[sort..""] then
                    self:setPorpChangedByMagicChanged(self.m_porp, mid.."",false)
                end
            end
            game_scene:removePopByName("game_magic_select_pop")
            self:refreshUi(self.m_curTab)
        end

        if tonumber(btnTag) < 10 then --选装备
            local cardData,heroCfg=game_data:getCardDataById(self.m_sel_cardId)
            local bind_equip =  cardData.bind_equip or {}
            if not bind_equip[btnTag] or bind_equip[btnTag] == 0 then
                game_scene:addPop("game_equip_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick1,sortBtnShow = false,selSort = sort ,openType = 12,selHerocId = cardData.c_id,allData = self.m_all_equip})
            end
        elseif tonumber(btnTag) < 20  then --选宝石
            local gemdata = {}
            for k,v in pairs(self.m_all_gem) do
                gemdata[k] = v
            end
            for k,v in pairs(self.m_gem_list) do
                if gemdata[v.id..""] then
                    gemdata[v.id..""] = tonumber(gemdata[v.id..""])-1
                    if tonumber(gemdata[v.id..""]) == 0 then
                        gemdata[v.id..""] = nil
                    end
                end
            end

            game_scene:addPop("gem_system_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick2,sortBtnShow = false,selSort = sort,openType = 2,allData = gemdata})

        elseif tonumber(btnTag) < 30 then --选法宝
            local selSort = sort < 3 and 1 or 0
            local magicdata = {}
            for k,v in pairs(self.m_all_magic) do
                magicdata[k] = v
            end
            
            local havemagic  = {}

            for k,v in pairs(self.m_magic_list) do
                havemagic[v.id] = 1
            end

            for k,v in pairs(magicdata) do
                if havemagic[v] then
                    magicdata[k]=nil
                end
            end

            game_scene:addPop("game_magic_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick3,sortBtnShow = false,selSort = selSort,openType = 2,allData = magicdata})
        end
    end

    self.m_btn_equip = self.m_btn_equip or {}
    self.m_btn_gem = self.m_btn_gem  or {}
    self.m_btn_magic = self.m_btn_magic or {}
    --装备层
    if #self.m_btn_equip == 0 then
        for k,v in pairs(self.m_sp_equip) do
            local button = game_util:createCCControlButton("public_weapon.png","",onClick)
            v:addChild(button)
            button:setPosition(ccp(22,22))
            button:setTag(tonumber(k))
            button:setOpacity(0)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 7)
            table.insert(self.m_btn_equip,button)
        end
    end

    --💎层
    if #self.m_btn_gem == 0 then
        for k,v in pairs(self.m_sp_gem) do
            local button = game_util:createCCControlButton("public_weapon.png","",onClick)
            v:addChild(button)
            button:setPosition(ccp(22,22))
            button:setTag(tonumber(k)+10)
            button:setOpacity(0)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 7)
            table.insert(self.m_btn_gem,button)
        end
    end

    --法宝层
    if #self.m_btn_magic == 0 then
        for k,v in pairs(self.m_sp_magic) do
            local button = game_util:createCCControlButton("public_weapon.png","",onClick)
            v:addChild(button)
            button:setPosition(ccp(22,22))
            button:setTag(tonumber(k)+20)
            button:setOpacity(0)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 7)
            table.insert(self.m_btn_magic,button)
        end
    end

end

--[[--
    刷新技能ui
]]
function game_newRichMan_bigBoss_hero_pop.refreshSkillUi(self)
    if self.m_node_main_skill then
        self.m_node_main_skill:removeAllChildrenWithCleanup(true)
    else
        self.m_node_main_skill = CCNode:create()
        self.m_scroll_skill:addChild(self.m_node_main_skill)
    end

    local skill_detail_cfg = getConfig(game_config_field.skill_detail)
    local height = 0
    local height2 = 0
    local default = 200

    self.m_sel_skill = self.m_sel_skill or {}
    local function onClick( event, target  )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();

        local tagId = (btnTag%100 + 300)..""

        self.m_sel_skill = self.m_sel_skill or {}

        local count = 0
        for k,v in pairs(self.m_sel_skill) do
            count = count +1
        end
        if self.m_node_main_skill:getChildByTag(tagId) == nil then
            return
        else
            if self.m_skill_tb[btnTag%100].avail.."" == "0"  then
                -- local canBuy,pay = game_util:getCostCoinBuyTimes(tonumber(tagId)-262) -- 4 - 42  5 - 43
                -- local t_params = 
                -- {
                --     title = string_config.m_title_prompt,
                --     okBtnCallBack = function(target,event)
                --         local function responseMethod( tag,gameData )
                --             if gameData ~= nil and tolua.type(gameData) == "util_json" then
                --                 game_util:addMoveTips({text = "解锁成功"})
                --                 local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {}
                                
                --                 local newskill = data.skill
                --                 self.m_skill_tb =data.skill or {}
                --                 for k,v in pairs(self.m_skill_tb) do
                --                     if v.s.."" == "0" then
                --                         self.m_skill_tb[k]=nil
                --                     end
                --                 end
                --                 self:refreshUi(2)
                --             end
                --         end 
                --         local params = {}
                --         params.card_id = self.m_sel_cardId
                --         params.skill_id = btnTag%10

                --         network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_unlock_skill"), http_request_method.GET, params,"cards_unlock_skill")
                --         game_util:closeAlertView();
                --     end,   --可缺省
                --     cancelBtnCallBack = function(target,event)
                --         game_util:closeAlertView();
                --     end,
                --     okBtnText = "确认",       --可缺省
                --     cancelBtnText = "取消",
                --     onlyOneBtn = false,
                --     text = "是否花费" .. pay .. "解锁该技能",      --可缺省
                --     touchPriority = GLOBAL_TOUCH_PRIORITY-7,
                -- }
                -- game_util:openAlertView(t_params);


            elseif count <3 and #self.m_skill_tb > 3 then
                self.m_node_main_skill:getChildByTag(tagId):setVisible(self.m_sel_skill[tagId]==nil)
                self.m_sel_skill[tagId] = self.m_sel_skill[tagId]==nil and btnTag%100 or nil
            elseif #self.m_skill_tb > 3 then
                if self.m_sel_skill[tagId]~=nil then
                    self.m_node_main_skill:getChildByTag(tagId):setVisible(self.m_sel_skill[tagId]==nil)
                    self.m_sel_skill[tagId] = self.m_sel_skill[tagId]==nil and btnTag%100 or nil
                else
                    game_util:addMoveTips({text = "Lựa chọn tối đa 3 kỹ năng."});
                    return
                end
            else
            end
        end
    end

    for i=1, #self.m_skill_tb do
        if i < 4 then
            local skillJsonData = skill_detail_cfg:getNodeWithKey(tostring(self.m_skill_tb[i].s))

            local skill_icon_spr = game_util:createSkillIconByCfg(skillJsonData,self.m_skill_tb[i].avail)
            self.m_node_main_skill:addChild(skill_icon_spr)

            if i == 1 then 
                -- height = skill_label_name:getContentSize().height *3.2
                height = skill_icon_spr:getContentSize().height/2
            end
            skill_icon_spr:setPosition(ccp(-20+i*70,default - height))
            skill_icon_spr:setTag(i+100)
            skill_icon_spr:setScale(0.8)

            local skill_icon_button = game_util:createCCControlButton("public_weapon.png","",onClick)
            self.m_node_main_skill:addChild(skill_icon_button)
            skill_icon_button:setPosition(ccp(-20+i*70,default - height))
            skill_icon_button:setTag(i+200)
            skill_icon_button:setOpacity(0)
            skill_icon_button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 7)


            local skill_label_name = game_util:createLabelTTF({text = skillJsonData:getNodeWithKey("skill_name"):toStr(),fontSize = 8}) 
            skill_icon_spr:addChild(skill_label_name)
            skill_label_name:setPosition(ccp(skill_icon_spr:getContentSize().width/2,skill_icon_spr:getContentSize().height*1.2))

            if self.m_skill_tb[i].avail.."" == "0" then
                local kuang_icon_spr = CCSprite:createWithSpriteFrameName("public_lock_icon.png")
                self.m_node_main_skill:addChild(kuang_icon_spr)
                kuang_icon_spr:setPosition(ccp(-20+i*70,default - height-1))
                kuang_icon_spr:setVisible(true)
                kuang_icon_spr:setTag(i+300)
            else
                local kuang_icon_spr = CCSprite:createWithSpriteFrameName("fight_icon_kuang.png")
                self.m_node_main_skill:addChild(kuang_icon_spr)
                kuang_icon_spr:setPosition(ccp(-9+i*70,default - height-11))
                kuang_icon_spr:setVisible(true)

                local tick_icon_spr = CCSprite:createWithSpriteFrameName("fight_icon_tick.png")
                self.m_node_main_skill:addChild(tick_icon_spr)
                tick_icon_spr:setPosition(ccp(-9+i*70,default - height-11))
                tick_icon_spr:setTag(i+300)

                if #self.m_skill_tb > 3 then
                    tick_icon_spr:setVisible(self.m_sel_skill[(i+300)..""]~=nil)
                else
                    tick_icon_spr:setVisible(true)
                end
            end

            if i == 3 then 
                height = skill_icon_spr:getContentSize().height *1.7
                height2 = height
            end
        else
            local skillJsonData = skill_detail_cfg:getNodeWithKey(tostring(self.m_skill_tb[i].s))

            local skill_icon_spr = game_util:createSkillIconByCfg(skillJsonData,self.m_skill_tb[i].avail)
            self.m_node_main_skill:addChild(skill_icon_spr)

            local skill_label_name = game_util:createLabelTTF({text = skillJsonData:getNodeWithKey("skill_name"):toStr(),fontSize = 8}) 
            skill_icon_spr:addChild(skill_label_name)
            skill_label_name:setPosition(ccp(skill_icon_spr:getContentSize().width/2,skill_icon_spr:getContentSize().height*1.2))

            skill_icon_spr:setPosition(ccp(-10+(i-3)*85,default - height))
            skill_icon_spr:setTag(i+100)
            skill_icon_spr:setScale(0.8)

            local skill_icon_button = game_util:createCCControlButton("public_weapon.png","",onClick)
            self.m_node_main_skill:addChild(skill_icon_button)
            skill_icon_button:setPosition(ccp(-10+(i-3)*85,default - height))
            skill_icon_button:setTag(i+200)
            skill_icon_button:setOpacity(0)
            skill_icon_button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 7)


            if self.m_skill_tb[i].avail.."" == "0" then
                local kuang_icon_spr = CCSprite:createWithSpriteFrameName("public_lock_icon.png")
                self.m_node_main_skill:addChild(kuang_icon_spr)
                kuang_icon_spr:setPosition(ccp(-10+(i-3)*85,default - height-1))
                kuang_icon_spr:setTag(i+300)
                kuang_icon_spr:setVisible(true)
            else
                local kuang_icon_spr = CCSprite:createWithSpriteFrameName("fight_icon_kuang.png")
                self.m_node_main_skill:addChild(kuang_icon_spr)
                kuang_icon_spr:setPosition(ccp(1+(i-3)*85,default - height-11))
                kuang_icon_spr:setVisible(true)

                local tick_icon_spr = CCSprite:createWithSpriteFrameName("fight_icon_tick.png")
                self.m_node_main_skill:addChild(tick_icon_spr)
                tick_icon_spr:setPosition(ccp(1+(i-3)*85,default - height-11))
                tick_icon_spr:setTag(i+300)
                if #self.m_skill_tb > 3 then
                    tick_icon_spr:setVisible(self.m_sel_skill[(i+300)..""]~=nil)
                else
                    tick_icon_spr:setVisible(true)
                end
            end

            if i == 5 then 
                height = height+30
            end
        end
    end
    -- height = skill_icon_spr:getContentSize().height *1.5
    if self.m_extraskill_tb and #self.m_extraskill_tb ~=0 then
        self.m_title_skillimp:setVisible(true)
        self.m_title_skillimp:setPosition(ccp(self.m_title_skillimp:getContentSize().width*2/3,default - height-11))

        height = height+25
        height2 = height
        for i=1, #self.m_extraskill_tb do
            -- cclog2(self.m_extraskill_tb)
            local skillJsonData = skill_detail_cfg:getNodeWithKey(tostring(self.m_extraskill_tb[i].s))
            -- local skill_label_name = game_util:createLabelTTF({text = skillJsonData:getNodeWithKey("skill_name"):toStr(),fontSize = 8}) 
            -- self.m_node_main_skill:addChild(skill_label_name)
            -- skill_label_name:setPosition(ccp(-10+i*85,default - height2))


            local skill_icon_spr = game_util:createSkillIconByCfg(skillJsonData,self.m_extraskill_tb[i].avail)
            self.m_node_main_skill:addChild(skill_icon_spr)

            if i == 1 then 
                height = height + skill_icon_spr:getContentSize().height *2/3
            end
            skill_icon_spr:setPosition(ccp(-10+i*85,default - height))
            skill_icon_spr:setTag(i+100)
            skill_icon_spr:setScale(0.8)


            local skill_label_name = game_util:createLabelTTF({text = skillJsonData:getNodeWithKey("skill_name"):toStr(),fontSize = 8}) 
            skill_icon_spr:addChild(skill_label_name)
            skill_label_name:setPosition(ccp(skill_icon_spr:getContentSize().width/2,skill_icon_spr:getContentSize().height*1.2))
        end
    end
end

--[[--
    刷新属性ui
]]
function game_newRichMan_bigBoss_hero_pop.refreshPropUi(self)
    local proptable = self:setPorpWithSuit()


    self.m_level_label:setString(math.floor(tonumber(proptable.lv))  or "")
    self.m_life_label:setString(math.floor(tonumber(proptable.hp))  or "")
    self.m_def_label:setString(math.floor(tonumber(proptable.def))  or "")
    self.m_physical_atk_label:setString(math.floor(tonumber(proptable.patk))  or "")
    self.m_speed_label:setString(math.floor(tonumber(proptable.speed))  or "")
    self.m_magic_atk_label:setString(math.floor(tonumber(proptable.matk))  or "")
    self.m_fire_label:setString(math.floor(tonumber(proptable.fire))  or "")
    self.m_fire_dfs_label:setString(math.floor(tonumber(proptable.fire_dfs))  or "")
    self.m_water_label:setString(math.floor(tonumber(proptable.water))  or "")
    self.m_water_dfs_label:setString(math.floor(tonumber(proptable.water_dfs))  or "")
    self.m_wind_label:setString(math.floor(tonumber(proptable.wind )) or "")
    self.m_wind_dfs_label:setString(math.floor(tonumber(proptable.wind_dfs )) or "")
    self.m_earth_label:setString(math.floor(tonumber(proptable.earth))  or "")
    self.m_earth_dfs_label:setString(math.floor(tonumber(proptable.earth_dfs))  or "")
end



--[[--
    刷新ui
]]
function game_newRichMan_bigBoss_hero_pop.refreshUi(self,curTab)
    if curTab == 2 then
        self:refreshSkillUi()
        self.m_btn_1:setColor(ccc3(100,100,100))
        self.m_btn_2:setColor(ccc3(255,255,255))
        self.m_btn_3:setColor(ccc3(100,100,100))
    elseif curTab == 3 then
        self:refreshPropUi()
        self.m_btn_1:setColor(ccc3(100,100,100))
        self.m_btn_2:setColor(ccc3(100,100,100))
        self.m_btn_3:setColor(ccc3(255,255,255))
    else
        self:refreshEquipUi()
        self.m_btn_1:setColor(ccc3(255,255,255))
        self.m_btn_2:setColor(ccc3(100,100,100))
        self.m_btn_3:setColor(ccc3(100,100,100))
    end
    self.m_equip_node:setVisible(curTab == 1)
    self.m_skill_node:setVisible(curTab == 2)
    self.m_shuxing_node:setVisible(curTab == 3)
end

--[[
    增加装备对属性的变化
]]

function game_newRichMan_bigBoss_hero_pop.setPorpChangedByEquipChanged(self,tabledata,equipId,isIncreased ,sort)

    local itemData,itemCfg = game_data:getEquipDataById(equipId.."")
    -- 增加装备基础属性

    local attrName1,value1,attrName2,value2,icon1,icon2,name1,name2  = game_util:getEquipAttributeValue(itemCfg,itemData.lv,itemData)

    local ability1name = name1 ..""
    local ability2name = name2 ..""
    if isIncreased then
        self.m_porp[ability1name] = (self.m_porp[ability1name] or 0) + tonumber(value1)
        self.m_porp[ability2name] = (self.m_porp[ability2name] or 0) + tonumber(value2)
    else
        self.m_porp[ability1name] = (self.m_porp[ability1name] or 0) - tonumber(value1)
        self.m_porp[ability2name] = (self.m_porp[ability2name] or 0) - tonumber(value2)
    end

    -- 增加附魔
    if itemData.atts then
        for k,v in pairs(itemData.atts) do
            if PUBLIC_ABILITY_NAME_TABLE[k..""] and self.m_porp[k..""] then
                self.m_porp[k..""] = (self.m_porp[k..""] or 0) + tonumber(v)
            end
        end
    end

    -- 增加打造
    if itemData.build_atts then
        for k,v in pairs(itemData.build_atts) do
            if PUBLIC_ABILITY_NAME_TABLE[k..""] and self.m_porp[k..""] then
                self.m_porp[k..""] = (self.m_porp[k..""] or 0) + tonumber(v)
            end
        end
    end

    -- 增加重铸 
    if itemData.recast_atts then
        for k,v in pairs(itemData.recast_atts) do
            if k.."" == itemData.c_id.."" then
                for k1,v1 in pairs(v) do
                    if PUBLIC_ABILITY_NAME_TABLE[k1..""] and self.m_porp[k1..""] then
                        self.m_porp[k1..""] = (self.m_porp[k1..""]  or 0)+ tonumber(v1)
                    end
                end
            end
        end
    end
end


--[[
    增加💎对属性的变化
]]
function game_newRichMan_bigBoss_hero_pop.setPorpChangedByGemChanged(self,tabledata,equipId,isIncreased)
    local itemData,itemCfg = game_data:getGemDataById(equipId)
    local attrName1,value1,icon1,attrName2,value2,icon2,ability1,ability2 = game_util:getGemAttributeValue(itemCfg)

    local ability1name = PUBLIC_ABILITY_TABLE["ability_"..ability1]["attrName"] .. ""
    local ability2name = ""
    if ability2 ~= 0 then 
        ability2name = PUBLIC_ABILITY_TABLE["ability_"..ability2]["attrName"] .. ""
    end

    if isIncreased then
        self.m_porp[ability1name] = (self.m_porp[ability1name] or 0)+ tonumber(value1)
        if ability2 ~= 0 then 
            self.m_porp[ability2name] = (self.m_porp[ability2name] or 0) + tonumber(value2)
        end
    else
        self.m_porp[ability1name] = (self.m_porp[ability1name] or 0) - tonumber(value1)
        if ability2 ~= 0 then 
            self.m_porp[ability2name] = (self.m_porp[ability2name] or 0) - tonumber(value2)
        end
    end
end



--[[
    增加法宝对属性的变化
]]
function game_newRichMan_bigBoss_hero_pop.setPorpChangedByMagicChanged(self,tabledata,equipId,isIncreased)
    local itemData,itemCfg = game_data:getMagicDataById(equipId)

    if isIncreased then
        self.m_porp.hp = self.m_porp.hp + (itemCfg["base_hp"] + itemData.lv * itemCfg["growth_hp"])
        self.m_porp.def = self.m_porp.def + (itemCfg["base_def"] + itemData.lv * itemCfg["growth_def"])
        self.m_porp.speed = self.m_porp.speed + (itemCfg["base_speed"] + itemData.lv * itemCfg["growth_speed"])
        self.m_porp.patk = self.m_porp.patk + (itemCfg["base_patk"] + itemData.lv * itemCfg["growth_patk"])
        self.m_porp.matk = self.m_porp.matk + (itemCfg["base_matk"] + itemData.lv * itemCfg["growth_matk"])
    else
        self.m_porp.hp = self.m_porp.hp - (itemCfg["base_hp"] + itemData.lv * itemCfg["growth_hp"])
        self.m_porp.def = self.m_porp.def - (itemCfg["base_def"] + itemData.lv * itemCfg["growth_def"])
        self.m_porp.speed = self.m_porp.speed - (itemCfg["base_speed"] + itemData.lv * itemCfg["growth_speed"])
        self.m_porp.patk = self.m_porp.patk - (itemCfg["base_patk"] + itemData.lv * itemCfg["growth_patk"])
        self.m_porp.matk = self.m_porp.matk - (itemCfg["base_matk"] + itemData.lv * itemCfg["growth_matk"])
    end
end


function game_newRichMan_bigBoss_hero_pop.setPorpWithSuit(self)

    local equip_suit = {}
    for k,v in pairs(self.m_equip_list) do
        local itemData,itemCfg = game_data:getEquipDataById(v.id.."")
        if itemCfg:getNodeWithKey("suit") and itemCfg:getNodeWithKey("suit"):toStr() ~= "" then
            local suitid = itemCfg:getNodeWithKey("suit"):toStr()
            if equip_suit[suitid] then
                equip_suit[suitid] = equip_suit[suitid] + 1
            else
                equip_suit[suitid] = 1
            end
        end
    end

    local porptb = self.m_porp
    local effectItem = nil

    for k,v in pairs(equip_suit) do
        local suitItemCfg = getConfig(game_config_field.suit):getNodeWithKey(tostring(k))
        if tonumber(v) == 2 then
            effectItem =json.decode(suitItemCfg:getNodeWithKey("effect_" .. v):getFormatBuffer())
            for j = 1, #effectItem do
                porptb[PUBLIC_ABILITY_TABLE["ability_" .. effectItem[j][1]].attrName] = porptb[PUBLIC_ABILITY_TABLE["ability_" .. effectItem[j][1]].attrName] + tonumber(effectItem[j][2])
            end
        end

        if  tonumber(v) == 3 then
            effectItem =json.decode(suitItemCfg:getNodeWithKey("effect_" .. v):getFormatBuffer())
            for j = 1, #effectItem do
                porptb[PUBLIC_ABILITY_TABLE["ability_" .. effectItem[j][1]].attrName] = porptb[PUBLIC_ABILITY_TABLE["ability_" .. effectItem[j][1]].attrName] + tonumber(effectItem[j][2])
            end
        end
        
        if  tonumber(v) == 4 then
            effectItem =json.decode(suitItemCfg:getNodeWithKey("effect_" .. v):getFormatBuffer())
            for j = 1, #effectItem do
                porptb[PUBLIC_ABILITY_TABLE["ability_" .. effectItem[j][1]].attrName] = porptb[PUBLIC_ABILITY_TABLE["ability_" .. effectItem[j][1]].attrName] + tonumber(effectItem[j][2])
            end
        end
    end

    return porptb
end

--[[--
    初始化
]]
function game_newRichMan_bigBoss_hero_pop.init(self,t_params)
    self.m_curTab = 1
    t_params = t_params or {}
    self.m_sel_cardId = t_params.cardId;
    self.m_tGameData = t_params.gameData or {}

    self.m_tempCard,self.m_cardCfg,_ = game_data:getCardDataById(self.m_sel_cardId)

    self.m_skill_tb =t_params.gameData.skill_data.skill or {}
    self.m_extraskill_tb ={}

    for k,v in pairs(self.m_skill_tb) do
        if v.s.."" == "0" then
            self.m_skill_tb[k]=nil
        end
    end
    self.m_sel_skill = {}
    if #self.m_skill_tb == 3 then
        self.m_sel_skill={1,2,3}
    else
        local skillId = {}
        for k,v in pairs(self.m_skill_tb) do
            skillId[v.s] = k
        end
        for i=1,3 do
            local skill = self.m_tempCard["s_" .. i]
            if skillId[skill.s] then
                self.m_sel_skill[tostring(skillId[skill.s]+300)] = i
            end
        end
    end
    for k,v in pairs(self.m_tempCard.skill_mapping or {}) do
        if v.."" == "s_4" or  v.."" == "s_5" then
            if self.m_tempCard[v..""].s.."" ~= "0" and self.m_tempCard[v..""].avail.."" ~= "0" then
                table.insert(self.m_extraskill_tb, {s = self.m_tempCard[v..""].s ,  avail= self.m_tempCard[v..""].avail ,  lv= self.m_tempCard[v..""].lv , exp= self.m_tempCard[v..""].exp } )
            end
        end
    end

    self.m_all_equip = t_params.gameData.allequip or {}
    self.m_all_gem = t_params.gameData.allgem or {}
    self.m_all_magic = t_params.gameData.alltalisman or {}

    --初始化属性表
    self.m_porp = {}
    self.m_porp.lv          = tonumber(self.m_tempCard.lv or 0)
    self.m_porp.hp          = tonumber(self.m_tempCard.hp or 0)
    self.m_porp.def         = tonumber(self.m_tempCard.def or 0)
    self.m_porp.patk        = tonumber(self.m_tempCard.patk or 0)
    self.m_porp.speed       = tonumber(self.m_tempCard.speed or 0)
    self.m_porp.matk        = tonumber(self.m_tempCard.matk or 0)
    self.m_porp.fire        = tonumber(self.m_tempCard.fire or 0)
    self.m_porp.fire_dfs    = tonumber(self.m_tempCard.fire_dfs or 0)
    self.m_porp.water       = tonumber(self.m_tempCard.water or 0)
    self.m_porp.water_dfs   = tonumber(self.m_tempCard.water_dfs or 0)
    self.m_porp.wind        = tonumber(self.m_tempCard.wind or 0)
    self.m_porp.wind_dfs    = tonumber(self.m_tempCard.wind_dfs or 0)
    self.m_porp.earth       = tonumber(self.m_tempCard.earth or 0)
    self.m_porp.earth_dfs   = tonumber(self.m_tempCard.earth_dfs or 0)
    local cards_with_equip = t_params.gameData.cards_with_equip
    local tempEquip,tempGem,tempMagic = {},{},{}
    if cards_with_equip and cards_with_equip[self.m_sel_cardId] then
        tempEquip = cards_with_equip[self.m_sel_cardId].equip_pos
        tempGem = cards_with_equip[self.m_sel_cardId].gem_pos
        tempMagic = cards_with_equip[self.m_sel_cardId].talisman_pos
    end
    if tempEquip and tempGem and tempMagic then
        for k,v in pairs(tempEquip) do
            print(k,v)
        end
    end

    self.m_equip_list = {}
    self.m_gem_list = {}
    self.m_magic_list = {}

    for k,v in pairs(tempEquip) do
        if tostring(v) ~= "0" and tostring(v) ~= "-1" then
            local itemData,itemCfg = game_data:getEquipDataById(v)
            self.m_equip_list[k] = itemData
            self.m_equip_list[k].id = v
        end
    end

    for k,v in pairs(tempGem) do
        if tostring(v) ~= "0" and tostring(v) ~= "-1" then
            self.m_gem_list[k] = {}
            self.m_gem_list[k].id = v
        end
    end

    for k,v in pairs(tempMagic) do
        if tostring(v) ~= "0" and tostring(v) ~= "-1" then
            local itemData,itemCfg = game_data:getMagicDataById(v)
            self.m_magic_list[k] = itemData
            self.m_magic_list[k].id = v
        end
    end
    --绑定装备
    if self.m_tempCard.bind_equip then
        for k,v in pairs(self.m_tempCard.bind_equip) do
            if v.."" ~= "0" then
                self.m_equip_list[k..""] = {id = v.."" , isbind=1}

                self:setPorpChangedByEquipChanged(self.m_porp,v.."",true)
            end
        end
    end

end

--[[--
    创建ui入口并初始化数据
]]
function game_newRichMan_bigBoss_hero_pop.create(self,t_params)
    self:init(t_params)
    local m_popUi = self:createUi()
    self:refreshUi(self.m_curTab)
    return  m_popUi
end

return game_newRichMan_bigBoss_hero_pop;