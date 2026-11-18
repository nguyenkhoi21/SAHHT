--- 宠物强化

local game_pet_strengthen_pop = {
    m_popUi = nil,

    m_status = nil,
    m_levelUpValue = nil,
    m_can_up_flag = nil,
    curr_need_food = nil,
    curr_need_crystal = nil,
    m_need_level = nil,
    label_next = nil,
    m_list_view_bg2 = nil,
    m_cultureLevelTab = nil,
    node_progress_exp = nil,
    node_starts_board = nil,
    label_name = nil,
    label_level = nil,
    m_icon_node = nil,
    m_culture_sel_spr = nil,
    m_cost_crystal_label = nil,
    m_cost_food_label = nil,
    label_limit_info_2 = nil,
    m_attr_label_tab = nil,
    m_selHeroData = nil,
    m_curr_need_crystal_2 = nil,
    label_limit_info_2 = nil,
    curr_need_crystal = nil,
    m_maxCrystalLv = nil,
    label_name = nil,
    label_level = nil,
    m_icon_node = nil,
    m_num_have_label = nil,
};
--[[--
    销毁
]]
function game_pet_strengthen_pop.destroy(self)
    -- body
    cclog("-----------------game_pet_strengthen_pop destroy-----------------");
    self.m_popUi = nil;

    self.m_status = nil;
    self.m_levelUpValue = nil;
    self.m_can_up_flag = nil;
    self.curr_need_food = nil;
    self.curr_need_crystal = nil;
    self.m_need_level = nil;

    self.label_next = nil;
    self.m_list_view_bg2 = nil;
    self.m_cultureLevelTab = nil;
    self.node_progress_exp = nil;
    self.label_name = nil;
    self.label_level = nil;
    self.m_icon_node = nil;
    self.m_culture_sel_spr = nil;
    self.m_cost_crystal_label = nil;
    self.m_cost_food_label = nil;
    self.label_limit_info_2 = nil;
    self.m_attr_label_tab = nil;
    self.m_selHeroData = nil;
    self.m_curr_need_crystal_2 = nil;
    self.label_limit_info_2 = nil;
    self.curr_need_crystal = nil;
    self.m_maxCrystalLv = nil;
    self.label_name = nil;
    self.label_level = nil;
    self.m_icon_node = nil;
    self.node_starts_board = nil;
    self.m_num_have_label = nil;
end
--[[--
    返回
]]
function game_pet_strengthen_pop.back(self,type)
    local function callBackFunc()
        -- game_scene:removePopByName("game_pet_strengthen_pop");
        game_scene:enterGameUi("game_pet_list_scene",{gameData = nil,pet_id = self.m_selHeroId});
    end
    self:onSureFunc(callBackFunc);
end

local typeTable = {
    {type="hp",typeName="HP",dataKey="hp_crystal",bg_img = "njgz_shengming_up.png",lv = 1,cfgKey1="need_crstal_hp",cfgKey2 = "add_hp"},
    {type="patk",typeName="Vật công",dataKey="patk_crystal",bg_img = "njgz_wugong_up.png",lv = 1,cfgKey1="need_crstal_patk",cfgKey2 = "add_patk"},
    {type="matk",typeName="Ma công",dataKey="matk_crystal",bg_img = "njgz_mogong_up.png",lv = 1,cfgKey1="need_crstal_matk",cfgKey2 = "add_matk"},
    {type="def",typeName="Phòng ngự",dataKey="def_crystal",bg_img = "njgz_fangyu_up.png",lv = 1,cfgKey1="need_crstal_def",cfgKey2 = "add_def"},
    {type="speed",typeName="Tốc độ",dataKey="speed_crystal",bg_img = "njgz_sudu_up.png",lv = 1,cfgKey1="need_crstal_speed",cfgKey2 = "add_speed"},
};

--[[--
    确定强化 无动画
]]
function game_pet_strengthen_pop.onSureFunc(self,callBackFunc)
    -- if #self.m_selIndexTab == 0 or self.m_selHeroId == nil or self.m_levelUpValue < 2 then
    if #self.m_selIndexTab == 0 or self.m_selHeroId == nil or self.m_levelUpValue < 1 then
        if callBackFunc then
            callBackFunc();
        end
        return
    end
    local function sendRequest()
        local function responseMethod(tag,gameData)
            self.m_status = 0;
            self.m_levelUpValue = 0;
            if gameData == nil then
                self:refreshHeroInfo(self.m_selHeroId);
                return;
            end
            game_scene:removeGuidePop();
            -- game_scene:getPopContainer():addChild(game_util:animSuccessCCBAnim(nil,"strengthen_success"));
            self:refreshHeroInfo(self.m_selHeroId);
            if callBackFunc then
                callBackFunc();
            end
        end
        -- card_id=1&type=def
        local params = "pet_id=" .. self.m_selHeroId
        local itemData = typeTable[self.m_selIndexTab[1]];
        local selType = itemData.type;
        for i=1,self.m_levelUpValue do
            params = params .. "&type=" .. selType
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pets_pet_strengthen"), http_request_method.GET, params,"pets_pet_strengthen",true,true)
    end
    sendRequest();
end

--[[--
    
]]
function game_pet_strengthen_pop.refreshHeroAttr(self,petId,addLvFlag)
    if addLvFlag == nil then addLvFlag = false end
    if petId ~= nil and petId ~= "-1" then
        if self.m_status == 1 then
            local t_params = 
            {
                m_openType = 5,
                m_call_func = function()
                    self.m_can_up_flag = true
                    self:refreshTips()
                end
            }
            game_scene:addPop("game_normal_tips_pop",t_params)
            return
        elseif self.m_status == 2 then
            -- local t_params = 
            -- {
            --     m_openType = 8,
            --     m_call_func = function()
            --         self.m_can_up_flag = true
            --         self:refreshTips()
            --     end
            -- }
            -- game_scene:addPop("game_normal_tips_pop",t_params)
            game_util:addMoveTips({text = "Năng Tinh thú nuôi không đủ"})
            return
        elseif self.m_status == 3 then--高级能晶不足
            game_util:addMoveTips({text = "Năng Tinh cấp cao không đủ!"})
            return
        elseif self.m_status == 4 then--没达到等级要求
            game_util:addMoveTips({text = "Yêu cầu cấp  thú nuôi đến:" .. tostring(self.m_need_level) .. "cấp!"});
            return;
        end

        if self.m_levelUpValue == 0 and addLvFlag == false then
            self.m_levelUpValue = 0--1;
            self.m_can_up_flag = true;
        end
        local tempLevelUpValue = self.m_levelUpValue
        cclog("self.m_can_up_flag ======================= " .. tostring(self.m_can_up_flag))
        if addLvFlag and self.m_can_up_flag == true then
            tempLevelUpValue = tempLevelUpValue + 1;
        end
        local character_strengthen = getConfig(game_config_field.pet_strengthen);
        local cardData,heroCfg = game_data:getPetDataById(tostring(petId));
        local hp,patk,matk,def,speed = cardData.hp,cardData.patk,cardData.matk,cardData.def,cardData.speed
        local hp_crystal_lv,patk_crystal_lv,matk_crystal_lv,def_crystal_lv,speed_crystal_lv = cardData.hp_crystal,cardData.patk_crystal,cardData.matk_crystal,cardData.def_crystal,cardData.speed_crystal
        self.m_selHeroData = cardData;

        typeTable[1].lv=math.min(self.m_maxCrystalLv,hp_crystal_lv+tempLevelUpValue)
        typeTable[2].lv=math.min(self.m_maxCrystalLv,patk_crystal_lv+tempLevelUpValue)
        typeTable[3].lv=math.min(self.m_maxCrystalLv,matk_crystal_lv+tempLevelUpValue)
        typeTable[4].lv=math.min(self.m_maxCrystalLv,def_crystal_lv+tempLevelUpValue)
        typeTable[5].lv=math.min(self.m_maxCrystalLv,speed_crystal_lv+tempLevelUpValue)
        typeTable[1].lv1=hp_crystal_lv
        typeTable[2].lv1=patk_crystal_lv
        typeTable[3].lv1=matk_crystal_lv
        typeTable[4].lv1=def_crystal_lv
        typeTable[5].lv1=speed_crystal_lv

        local add_hp,add_patk,add_matk,add_def,add_speed = 0,0,0,0,0;
        local attrTab = {hp=0,patk=0,matk=0,def=0,speed=0};
        local hp_item_cfg = character_strengthen:getNodeWithKey(tostring(hp_crystal_lv));
        if hp_item_cfg then
            add_hp = hp_item_cfg:getNodeWithKey("add_hp"):toInt();
            attrTab.hp = add_hp;
        end
        local patk_item_cfg = character_strengthen:getNodeWithKey(tostring(patk_crystal_lv));
        if patk_item_cfg then
            add_patk = patk_item_cfg:getNodeWithKey("add_patk"):toInt();
            attrTab.patk = add_patk;
        end
        local matk_item_cfg = character_strengthen:getNodeWithKey(tostring(matk_crystal_lv));
        if matk_item_cfg then
            add_matk = matk_item_cfg:getNodeWithKey("add_matk"):toInt();
            attrTab.matk = add_matk;
        end
        local def_item_cfg = character_strengthen:getNodeWithKey(tostring(def_crystal_lv));
        if def_item_cfg then
            add_def = def_item_cfg:getNodeWithKey("add_def"):toInt();
            attrTab.def = add_def;
        end
        local speed_item_cfg = character_strengthen:getNodeWithKey(tostring(speed_crystal_lv));
        if speed_item_cfg then
            add_speed = speed_item_cfg:getNodeWithKey("add_speed"):toInt();
            attrTab.speed = add_speed;
        end
        local function setValueFunc()
            if self.m_can_up_flag == false then return end
            game_util:setAttributeLable2(self.m_attr_label_tab.hp[1],add_hp,add_hp,"+");
            game_util:setAttributeLable2(self.m_attr_label_tab.patk[1],add_patk,add_patk,"+");
            game_util:setAttributeLable2(self.m_attr_label_tab.matk[1],add_matk,add_matk,"+");
            game_util:setAttributeLable2(self.m_attr_label_tab.def[1],add_def,add_def,"+");
            game_util:setAttributeLable2(self.m_attr_label_tab.speed[1],add_speed,add_speed,"+");
        end
        local selIndex = self.m_selIndexTab[1]
        if selIndex then
            local need_food = 0;
            local need_crystal = 0;
            local need_crystal_2 = 0;
            self.curr_need_food = 0;
            self.curr_need_crystal = 0;
            self.m_curr_need_crystal_2 = 0;
            self.m_need_level = 0;
            local itemData = typeTable[selIndex];
            local typeName = itemData.type;
            local add_temp_value = -1;
            for lv=itemData.lv1+1,itemData.lv+1 do
                local crystal_item = character_strengthen:getNodeWithKey(tostring(lv));
                if crystal_item then
                    local need_level = crystal_item:getNodeWithKey("need_level")
                    if need_level then
                        self.m_need_level = need_level:toInt();
                    end
                    add_temp_value = crystal_item:getNodeWithKey(itemData.cfgKey2):toInt();
                    need_food = need_food + crystal_item:getNodeWithKey("need_food"):toInt();
                    local need_crstal = crystal_item:getNodeWithKey(itemData.cfgKey1);
                    cclog2(need_crstal,"need_crstal")
                    if need_crstal then
                        local crystal_type = need_crstal:getNodeAt(0):toInt();
                        if crystal_type == 1 then
                            -- need_crystal = need_crystal + need_crstal:getNodeAt(1):toInt();
                        elseif crystal_type == 2 then
                            need_crystal_2 = need_crystal_2 + need_crstal:getNodeAt(1):toInt();
                        elseif crystal_type == 3 then--宠物能晶
                            need_crystal = need_crystal + need_crstal:getNodeAt(1):toInt();
                        end
                    end
                    cclog("itemData.lv+1 ============== " .. (itemData.lv+1) .. " ; lv = " .. lv)
                    if lv == itemData.lv+1 then
                        self.curr_need_food = crystal_item:getNodeWithKey("need_food"):toInt();
                        if need_crstal then
                            local crystal_type = need_crstal:getNodeAt(0):toInt();
                            if crystal_type == 1 then
                                -- self.curr_need_crystal = need_crstal:getNodeAt(1):toInt();
                            elseif crystal_type == 2 then
                                self.m_curr_need_crystal_2 = need_crstal:getNodeAt(1):toInt();
                            elseif crystal_type == 3 then
                                self.curr_need_crystal = need_crstal:getNodeAt(1):toInt();
                            end
                        end
                        cclog2(self.curr_need_food,"self.curr_need_food")
                        cclog2(need_crstal,"need_crstal")   
                    end
                end
            end
            local function setValueFunc2()
                if self.m_can_up_flag == false then return end
                if add_temp_value ~= -1 then
                    game_util:setAttributeLable2(self.m_attr_label_tab[typeName][1],attrTab[typeName],add_temp_value,"+");
                end
            end
            self.m_needFood = need_food;
            self.m_needCrystal = need_crystal;
            self.m_needCrystal_2 = need_crystal_2;
            local totalFood = (game_data:getUserStatusDataByKey("food") or 0)
            local totalCrystal = (game_data:getUserStatusDataByKey("pet_crystal") or 0)
            local totalCrystal_2 = (game_data:getUserStatusDataByKey("adv_crystal") or 0)
            if (need_food - self.curr_need_food) > totalFood then
                self.m_can_up_flag = false;
                --换成统一的提示
                local t_params = 
                {
                    m_openType = 5,
                    m_call_func = function()
                        self.m_can_up_flag = true
                        self:refreshTips()
                    end
                }
                game_scene:addPop("game_normal_tips_pop",t_params)
            elseif need_crystal - self.curr_need_crystal > totalCrystal then
                -- self.m_can_up_flag = false;
                -- --换成统一提示
                -- local t_params = 
                -- {
                --     m_openType = 8,
                --     m_call_func = function()
                --         self.m_can_up_flag = true
                --         self:refreshTips()
                --     end
                -- }
                -- game_scene:addPop("game_normal_tips_pop",t_params)
                game_util:addMoveTips({text = "Năng Tinh thú nuôi không đủ"});
            elseif need_crystal_2 - self.m_curr_need_crystal_2 > totalCrystal_2 then
                game_util:addMoveTips({text = "Năng Tinh cấp cao không đủ"});
            else
                self.m_levelUpValue = math.min(self.m_maxCrystalLv - itemData.lv1,tempLevelUpValue);
                if tempLevelUpValue > (self.m_maxCrystalLv + 1 - itemData.lv1) then
                    game_util:addMoveTips({text = string_config.m_lv_is_max});
                end
                if tempLevelUpValue > 1 then
                    game_sound:playUiSound("up_success")
                end
            end
            cclog("self.m_levelUpValue ======== " .. self.m_levelUpValue .. " ;tempLevelUpValue == " .. tempLevelUpValue)
            setValueFunc();
            setValueFunc2();
        end
        self:refreshCultrueLevel();
    else
        self.m_needFood = 0;
        self.m_needCrystal = 0;
        self.curr_need_food = 0;
        self.curr_need_crystal = 0;
        local tempLabel = nil;
        for i=1,1 do
            game_util:resetAttributeLable2(self.m_attr_label_tab.hp[i]);
            game_util:resetAttributeLable2(self.m_attr_label_tab.patk[i]);
            game_util:resetAttributeLable2(self.m_attr_label_tab.matk[i]);
            game_util:resetAttributeLable2(self.m_attr_label_tab.def[i]);
            game_util:resetAttributeLable2(self.m_attr_label_tab.speed[i]);
        end
    end
    self:refreshTips();
end
--[[--
    读取ccbi创建ui
]]
function game_pet_strengthen_pop.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then 
            self:back()
        elseif btnTag == 2 then--strengthen
            if self.m_selIndexTab[1] == nil then
                game_util:addMoveTips({text = "Chọn thuộc tính cải tạo !"});
                return;
            end
            self:refreshHeroAttr(self.m_selHeroId,true);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event

    local function onCultureBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag > 20 and btnTag < 26 then
            self:onSureFunc();
            if self.m_selIndexTab[1] ~= btnTag - 20 then
                self.m_status = 0;
                self.m_levelUpValue = 0;
                self.m_selIndexTab[1] = btnTag - 20;
                self:refreshHeroAttr(self.m_selHeroId);
                self:refreshTips();
                self.m_culture_sel_spr:setVisible(true);
                local pX,pY = tagNode:getPosition();
                self.m_culture_sel_spr:setPosition(ccp(pX,pY));
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onCultureBtnClick",onCultureBtnClick);

    ccbNode:openCCBFile("ccb/ui_pet_strengthen_pop.ccbi");

    self.m_list_view_bg2 = ccbNode:layerForName("m_list_view_bg2")
    self.label_next = {}
    for i=1,5 do
        self.label_next[i] = ccbNode:labelTTFForName("label_next_" .. i)
        self.m_cultureLevelTab[i] = ccbNode:labelTTFForName("m_culture_level_" .. i);

        local changeButton = ccbNode:controlButtonForName("changeButton" .. i)
        changeButton:setTouchPriority(GLOBAL_TOUCH_PRIORITY-9)
    end
    self.node_progress_exp = ccbNode:nodeForName("node_progress_exp")
    self.node_starts_board = ccbNode:nodeForName("node_starts_board")
    self.label_name = ccbNode:labelTTFForName("label_name")
    self.label_level = ccbNode:labelTTFForName("label_level")
    self.m_icon_node = ccbNode:nodeForName("m_icon_node")
    self.m_culture_sel_spr = ccbNode:spriteForName("m_culture_sel_spr")
    self.m_cost_crystal_label = ccbNode:labelBMFontForName("m_cost_crystal_label")
    self.m_cost_food_label = ccbNode:labelBMFontForName("m_cost_food_label")
    self.label_limit_info_2 = ccbNode:labelTTFForName("label_limit_info_2")
    self.label_limit_info_1 = ccbNode:labelTTFForName("label_limit_info_1")
    self.m_num_have_label = ccbNode:labelTTFForName("m_num_have_label")
    self.label_limit_info_1:setString("")

    for i=1,1 do
        self.m_attr_label_tab.hp[i] = self.label_next[1]
        self.m_attr_label_tab.patk[i] = self.label_next[2]
        self.m_attr_label_tab.matk[i] = self.label_next[3]
        self.m_attr_label_tab.def[i] = self.label_next[4]
        self.m_attr_label_tab.speed[i] = self.label_next[5]
    end

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-9)
    local btn_upgrade = ccbNode:controlButtonForName("btn_upgrade")
    btn_upgrade:setTouchPriority(GLOBAL_TOUCH_PRIORITY-9)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-8,true);
    m_root_layer:setTouchEnabled(true);

    return ccbNode;
end

--[[--
    刷新按钮状态
]]
function game_pet_strengthen_pop.refreshTips(self)
    self.m_status = 0;
    -- if self.m_selHeroId then
    --     self.m_tips_spr_1:setVisible(false);
    --     -- self.m_tips_spr_2:setVisible(false);
    -- else
    --     self.m_tips_spr_1:setVisible(true);
    --     -- self.m_tips_spr_2:setVisible(false);
    -- end
    local totalFood = (game_data:getUserStatusDataByKey("food") or 0) - self.m_needFood + self.curr_need_food
    cclog("self.m_needFood === " .. self.m_needFood .. " ; self.curr_need_food == " .. self.curr_need_food)
    local value,unit = game_util:formatValueToString(totalFood);
    -- self.m_food_total_label:setString(value .. unit);
    game_util:setCostLable(self.m_cost_food_label,self.curr_need_food,totalFood);
    local totalCrystal = (game_data:getUserStatusDataByKey("pet_crystal") or 0) - self.m_needCrystal + self.curr_need_crystal
    cclog("self.m_needCrystal === " .. self.m_needCrystal .. " ; self.curr_need_crystal == " .. self.curr_need_crystal)
    local value,unit = game_util:formatValueToString(totalCrystal);
    self.m_num_have_label:setString(tostring(value .. unit))
    game_util:setCostLable(self.m_cost_crystal_label,self.curr_need_crystal,totalCrystal);
    -- local totalCrystal_2 = (game_data:getUserStatusDataByKey("adv_crystal") or 0) - self.m_needCrystal_2 + self.m_curr_need_crystal_2
    -- cclog("self.m_needCrystal_2 === " .. self.m_needCrystal_2 .. " ; self.m_curr_need_crystal_2 == " .. self.m_curr_need_crystal_2)
    -- local value,unit = game_util:formatValueToString(totalCrystal_2);
    -- self.m_crystal_total_label_2:setString(tostring(value .. unit))
    -- game_util:setCostLable(self.m_cost_crystal_label_2,self.m_curr_need_crystal_2,totalCrystal_2)

    if self.curr_need_food > totalFood then
        self.m_status = 1;
    elseif self.curr_need_crystal > totalCrystal then
        self.m_status = 2
    -- elseif self.m_curr_need_crystal_2 > totalCrystal_2 then
    --     self.m_status = 3
    else
        if self.m_selHeroData and self.m_selHeroData.lv < self.m_need_level then
            self.m_status = 4;--等级没达到要求
        end
    end
    cclog("self.m_can_up_flag ============= " .. tostring(self.m_can_up_flag))

    self.label_limit_info_2:setString(self.m_need_level .. "cấp trở lên")
end

--[[--
    刷新
]]
function game_pet_strengthen_pop.refreshCultrueLevel(self)
    local character_strengthen = getConfig(game_config_field.pet_strengthen);
    for i=1,5 do
        local itemData = typeTable[i];
        local m_level_label = self.m_cultureLevelTab[i]
        if self.m_selIndexTab[1] == i then
            if itemData.lv >= self.m_maxCrystalLv then-- itemData.lv >= 20
                m_level_label:setString("Lv.MAX")
            else
                m_level_label:setString("Lv." .. math.min(itemData.lv,self.m_maxCrystalLv));
            end
        else
            if itemData.lv1 >= self.m_maxCrystalLv then-- itemData.lv >= 20
                m_level_label:setString("Lv.MAX")
            else
                m_level_label:setString("Lv." .. math.min(itemData.lv1 or 0,self.m_maxCrystalLv));
            end
        end
    end
end

--[[--
    刷新ui
]]
function game_pet_strengthen_pop.refreshUi(self)
    local itemData,itemCfg = game_data:getPetDataById(self.m_selHeroId)
    local name = itemCfg:getNodeWithKey("name"):toStr()
    self.label_name:setString(name)
    self.label_level:setString("LV." .. itemData.lv .. "/" .. itemData.level_max)
    self.m_icon_node:removeAllChildrenWithCleanup(true)
    local tempIcon = game_util:createCardIconByCfg(itemCfg,itemData)
    if tempIcon then
        self.m_icon_node:addChild(tempIcon)
    end
    --star
    self:createStar(itemData.star)
    --exp
    self.node_progress_exp:removeAllChildrenWithCleanup(true)
    local pet_base = getConfig(game_config_field.pet_base)
    local pet_base_item = pet_base:getNodeWithKey(tostring(itemData.lv))
    local maxExp = math.floor(pet_base_item:getNodeWithKey("exp"):toInt())
    local bar = ExtProgressTime:createWithFrameName("ui_pet_jindutiaoA1.png","ui_pet_jindutiaoA2.png");
    bar:addLabelTTF(CCLabelTTF:create(itemData.exp .. "/" .. maxExp,TYPE_FACE_TABLE.Arial_BoldMT,12));
    self.node_progress_exp:addChild(bar,10,10);
    bar:setMaxValue(maxExp);
    bar:setCurValue(itemData.exp,false);

    self:refreshHeroInfo(self.m_selHeroId);
    self:refreshTips()
end
--[[
    星星显示
]]
function game_pet_strengthen_pop.createStar(self,star)
    self.node_starts_board:removeAllChildrenWithCleanup(true)
    for i=1,5 do
        local star_back = CCSprite:createWithSpriteFrameName("ui_pet_xingxing2.png")
        self.node_starts_board:addChild(star_back)
        star_back:setPosition(ccp(20 + (i-1) * 15,9))
        if i <= star then
            local star = CCSprite:createWithSpriteFrameName("ui_pet_xingxing1.png")
            self.node_starts_board:addChild(star)
            star:setPosition(ccp(20 + (i-1) * 15,9))
        end
    end
end

--[[--
    属性宠物信息
]]
function game_pet_strengthen_pop.refreshHeroInfo(self,petId)
    self.m_selHeroId = petId;
    if petId ~= nil and petId ~= "-1" then
        local cardData,heroCfg = game_data:getPetDataById(tostring(petId));
        local attrTab = {"hp_crystal","patk_crystal","matk_crystal","def_crystal","speed_crystal"}
        local attrCfg = {"add_hp","add_patk","add_matk","add_def","add_speed"}
        -- local starCount = cardData.star
        -- local character_strengthen = getConfig(game_config_field.pet_strengthen);
        -- local character_strengthen_count = character_strengthen:getNodeCount();

        -- self.m_maxCrystalLv = character_strengthen_count;
        -- self:refreshHeroAttr(petId);

        local pet_strengthen = getConfig(game_config_field.pet_strengthen)
        local strengValue = {0,0,0,0,0,0}
        for i=1,5 do
            -- self.label_next[i]:setString(cardData[attrTab[i]])
            local strengLv = cardData[attrTab[i]]

            self.m_cultureLevelTab[i]:setString("Lv." .. strengLv)

            if strengLv > 0 then
                local itemStreng = pet_strengthen:getNodeWithKey(tostring(strengLv))
                strengValue[i] = itemStreng:getNodeWithKey(attrCfg[i]):toInt()
            end

            self.label_next[i]:setString("+" .. strengValue[i])
        end
    else
        -- self:refreshTips();
    end

end

--[[--
    初始化
]]
function game_pet_strengthen_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_attr_label_tab = {hp={},matk={},patk={},def={},speed={}};
    self.m_cultureLevelTab = {}
    self.m_selHeroId = t_params.petId
    self.m_selIndexTab = {}
    self.m_levelUpValue = 0;
    self.m_needFood = 0;
    self.m_needCrystal = 0;
    self.curr_need_food = 0;
    self.curr_need_crystal = 0;
    self.m_needCrystal_2 = 0;
    self.m_curr_need_crystal_2 = 0;
    self.m_maxCrystalLv = 20;
    self.m_need_level = 0;
end

--[[--
    创建ui入口并初始化数据
]]
function game_pet_strengthen_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_pet_strengthen_pop;