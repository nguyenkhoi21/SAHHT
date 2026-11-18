--装备锻造
local game_equip_forge = {
    m_tGameData = nil,
    m_table_view = nil,
    m_sel_btn = nil,
    star_node = nil,
    m_metal_total_label = nil,
    m_cost_metal_label = nil,
    m_ok_btn = nil,
    show_node = nil,
    m_select_id = nil,--选中的
    m_selEquipDataTab = nil,
    last_m_sel_img = nil,
    table_view_node = nil,
    m_anim_node = nil,
    m_tips_spr_1 = nil,
    m_cost_metal = nil,
    m_btn_table = nil,
    m_advanced_btn = nil,
    cur_level = nil, --当前锻造等级
    m_refresh_btn = nil,--刷新按钮
    property_node = nil,
    m_material_node = nil,
    property_table = nil,
    m_material_node_tab = nil,
    m_root_layer = nil,
    label_exp = nil,
    smallStone_num = nil,
    middleStone_num = nil,
    highStone_num = nil,
    maxExp = nil,
    curExp = nil,
    m_exp_table = nil,
    current_lv = nil,
    m_node_progress_bar = nil,
    m_layer_progress_bar = nil,
    m_reduce_button1 = nil,
    m_reduce_button2 = nil,
    m_reduce_button3= nil,
    -- ruduce_button_layer = nil,

    modulus_table = nil,
};
--[[--
    销毁ui
]]
function game_equip_forge.destroy(self)
    -- body
    cclog("-----------------game_equip_forge destroy-----------------");
    m_tGameData = nil;
    self.m_table_view = nil;
    self.m_sel_btn = nil;
    self.star_node = nil;
    self.m_metal_total_label = nil;
    self.m_cost_metal_label = nil;
    self.m_ok_btn = nil;
    self.show_node = nil;
    self.m_select_id = nil;
    self.m_selEquipDataTab = nil;
    self.last_m_sel_img = nil;
    self.table_view_node = nil;
    self.m_anim_node = nil;
    self.m_tips_spr_1 = nil;
    self.m_cost_core = nil;
    self.m_btn_table = nil;
    self.m_advanced_btn = nil;
    self.cur_level = nil; --当前锻造等级
    self.m_refresh_btn = nil;--刷新按钮
    self.property_node = nil;
    self.m_material_node = nil;
    self.property_table = nil;
    self.m_material_node_tab = nil;
    self.m_root_layer = nil;
    self.label_exp = nil;
    self.smallStone_num = nil;
    self.middleStone_num = nil;
    self.highStone_num = nil;
    self.maxExp = nil;
    self.curExp = nil;
    self.m_exp_table = nil;
    self.current_lv = nil;
    self.m_node_progress_bar = nil;
    self.m_layer_progress_bar = nil;
    self.m_reduce_button1 = nil;
    self.m_reduce_button2 = nil;
    self.m_reduce_button3= nil;
    -- self.ruduce_button_layer = nil;
    self.modulus_table = nil;
end

--[[--
    返回
]]
function game_equip_forge.back(self,backType)
      cclog("-----------------game_equip_forge back-----------------");    
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
    self:destroy();
    
end
--[[--
    读取ccbi创建ui
]]
function game_equip_forge.refreshLv( self )
    -- body
    if self.m_select_id then
        local itemData,itemCfg = game_data:getEquipDataById(tostring(self.m_select_id));
        self.current_lv = itemData.equip_forge_level.lv
    end
end
function game_equip_forge.createUi(self)
    cclog("-----------------game_equip_forge createUi began-----------------");
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        cclog("-----------------game_equip_forge onMainBtnClick began-----------------");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 601 then 
            if self.smallStone_num and self.smallStone_num > 0 then 
                self.smallStone_num = self.smallStone_num - 1
                self.m_material_node_tab[1].m_stone_cost_label:setString(self.smallStone_num)
                self:ProgressTiemer(self.m_select_id)
            end
        elseif btnTag == 602 then 
            if self.middleStone_num and self.middleStone_num > 0 then 
                self.middleStone_num = self.middleStone_num - 1
                 self.m_material_node_tab[2].m_stone_cost_label:setString(self.middleStone_num)
                 self:ProgressTiemer(self.m_select_id)
            end
        elseif btnTag == 603 then 
            if self.highStone_num and self.highStone_num > 0 then 
                self.highStone_num = self.highStone_num - 1
                self.m_material_node_tab[3].m_stone_cost_label:setString(self.highStone_num)
                self:ProgressTiemer(self.m_select_id)
            end
        elseif btnTag == -1 then --刷新
            if self.m_select_id == nil then
                 game_util:addMoveTips({text = "Chọn trang bị muốn tạo mới!"})
            else
                local itemData,itemCfg = game_data:getEquipDataById(tostring(self.m_select_id));
                if itemData.equip_forge_level then
                    if itemData.equip_forge_level.lv > 0 then
                        local params = {}
                        params.equip_id = self.m_select_id
                        local function responseMethod( tag,gameData )
                            local function callback( data )
                                self.m_select_id = data
                                self:refreshUi()
                            end
                            game_scene:addPop("game_equip_forge_pop",{gameData = gameData,callback = callback});
                        end 
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_forge_index"), http_request_method.GET, params,"equip_forge_index")
                    else 
                         game_util:addMoveTips({text = "Không thể tạo mới khi level rèn 0!"})
                    end
                else
                    game_util:addMoveTips({text = "Không thể tạo mới khi level rèn 0!"})
                end
            end
        elseif btnTag == 101  then--开始精炼
            if self.m_select_id == nil then
                game_util:addMoveTips({text = "Chọn trang bị muốn rèn!"})
            elseif self.smallStone_num == 0 and self.middleStone_num ==0 and self.highStone_num == 0 then
                game_util:addMoveTips({text = "Thêm đá rèn!"})
            else
                local params = {}       
                params.forge_stone = self.smallStone_num .. "_" .. self.middleStone_num .. "_" .. self.highStone_num
                params.equip_id = self.m_select_id
                local addexp = self.smallStone_num * 10 + self.middleStone_num * 100 + self.highStone_num * 500
                local function responseMethod(tag,gameData)
                    -- cclog2(self.m_exp_table,"self.m_exp_table")
                    if self.m_exp_table then
                        local lv = self.m_exp_table.lv or 0
                        self:refreshLv()
                        if self.current_lv > lv then
                            game_util:addMoveTips({text = "Trang bị đã được rèn đến level" .. self.current_lv})
                        else
                            game_util:addMoveTips({text = "Đã tăng" .. addexp .. "EXP" })
                        end
                        self:refreshTips()
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_forge_level"), http_request_method.GET, params,"equip_forge_level")
                
            end            
        elseif  btnTag == 102 then --自动锻造
            if self.m_select_id == nil then
                 game_util:addMoveTips({text = "Chọn trang bị muốn rèn!"})
                 return
            end
            local needExp = self.maxExp - self.curExp
            if self.smallStone_num * 10 + self.middleStone_num *100 +self.highStone_num *500 >= needExp then 
                game_util:addMoveTips({text = "EXP đầy!"})
            else

            self.smallStone_num,self.middleStone_num,self.highStone_num = self:autoAdd(self.m_select_id,needExp)

            self:refreshTips(self.smallStone_num,self.middleStone_num,self.highStone_num)
            self.label_exp:setString(self.smallStone_num * 10 + self.middleStone_num * 100 + self.highStone_num *500 + self.curExp .. "/" .. self.maxExp)  
            end
        elseif btnTag >= 201 and btnTag <= 204 then--排序
            local index = btnTag - 200;
            for i=1,4 do
                self.m_btn_table[i]:setEnabled(true)
                self.m_btn_table[i]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_select.png"),CCControlStateNormal);
            end
            self.m_btn_table[index]:setEnabled(false)
            self.m_btn_table[index]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_selected.png"),CCControlStateDisabled);
            --切换table
            local typeTable = {"default","quality","lv","sort",};
            game_data:equipSortByTypeName(typeTable[index]);
            self:refreshUi();

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_equip_forge.ccbi");
    --装备相关
    self.table_view_node = ccbNode:nodeForName("table_view_node");
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn");
    self.star_node = ccbNode:nodeForName("star_node");
    self.m_metal_total_label = ccbNode:labelBMFontForName("m_metal_total_label");
    self.m_cost_metal_label = ccbNode:labelBMFontForName("m_cost_metal_label");
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn");
    self.show_node = ccbNode:nodeForName("show_node");
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")
    self.m_advanced_btn = ccbNode:controlButtonForName("m_advanced_btn");
    self.cur_level = ccbNode:labelTTFForName("cur_level");
    self.cur_level:setString("0")
    self.label_exp = ccbNode:labelTTFForName("label_exp");
    self.label_exp:setVisible(false)
    self.m_refresh_btn = ccbNode:controlButtonForName("m_refresh_btn");--刷新按钮
    self.cur_property1 = ccbNode:labelTTFForName("cur_property1");
    self.next_property1 = ccbNode:labelTTFForName("next_property1");
    self.cur_property2 = ccbNode:labelTTFForName("cur_property2");
    self.next_property2 = ccbNode:labelTTFForName("next_property2");
    self.cur_property3 = ccbNode:labelTTFForName("cur_property3");
    self.next_property3 = ccbNode:labelTTFForName("next_property3");
    self.property1 = ccbNode:labelTTFForName("property1");
    self.property2 = ccbNode:labelTTFForName("property2");
    self.property3 = ccbNode:labelTTFForName("property3");
    self.property_node = ccbNode:nodeForName("property_node");
    self.m_material_node = ccbNode:layerForName("m_material_node");
    self.m_reduce_button1 = ccbNode:controlButtonForName("m_reduce_button1")
    self.m_reduce_button1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 30);
    self.m_reduce_button2 = ccbNode:controlButtonForName("m_reduce_button2")
    self.m_reduce_button3 = ccbNode:controlButtonForName("m_reduce_button3")
    self.m_reduce_button2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 30);
    self.m_reduce_button3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 30);
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScale(resolution_config:getScale())
    self.property_node:setVisible(false)
    self.m_btn_table = {}
    self.property_table = {}
    self.m_material_node_tab = {}

    -- 进度条
    self.m_layer_progress_bar = ccbNode:spriteForName("m_layer_progress_bar")
    self.m_node_progress_bar = ccbNode:nodeForName("m_node_progress_bar")

    local property_node,property,cur_property,next_property,parentNode = nil;
    for i=1,3 do
        property = ccbNode:labelTTFForName("property" .. i);
        cur_property = ccbNode:labelTTFForName("cur_property" .. i);
        next_property = ccbNode:labelTTFForName("next_property" .. i);
        self.property_table[i] = {property = property, cur_property = cur_property, next_property = next_property}
    end
    local m_material_node,m_stone_cost_label,m_stone_total_label,parentNode = nil;
    for i=1,3 do
        m_material_node = ccbNode:spriteForName("m_material_node_" .. i);
        m_stone_cost_label = ccbNode:labelTTFForName("m_stone_cost_label_" .. i)
        m_stone_total_label = ccbNode:labelTTFForName("m_stone_total_label_" .. i)
        parentNode = m_material_node:getParent()
        self.m_material_node_tab[i] = {m_material_node = m_material_node,m_stone_cost_label = m_stone_cost_label,m_stone_total_label = m_stone_total_label,parentNode = parentNode}
    end
    for i=1,4 do
        self.m_btn_table[i] = ccbNode:controlButtonForName("m_table_tab_btn_"..i)
        self.m_btn_table[i]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_select.png"),CCControlStateNormal);
    end
    self:initMaterialLayerTouch(self.m_material_node)
    self.m_btn_table[1]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_selected.png"),CCControlStateNormal);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
   return ccbNode;
end
--[[--
    自动添加
]]

function game_equip_forge.autoAdd( self,m_select_id ,needExp)

    local total_Small_Stone = game_data:getUserStatusDataByKey("small_forge_stone")
    local total_Middle_Stone = game_data:getUserStatusDataByKey("middle_forge_stone")
    local total_High_Stone = game_data:getUserStatusDataByKey("high_forge_stone")
    local tempExp = 0
    local needExp = self.maxExp - self.curExp
    local smallStone = needExp/10
    if smallStone < total_Small_Stone  then
            self.smallStone_num = self.smallStone_num + smallStone
            tempExp = self.smallStone_num * 10
            
    elseif total_Small_Stone < smallStone and total_Small_Stone > 0 then
        self.smallStone_num = total_Small_Stone
        tempExp = self.smallStone_num * 10
    else
        local mStone = needExp - total_Small_Stone * 10
        local middleStone = math.modf(mStone/100)
        if mStone%100 ~= 0 then
            middleStone = math.modf(mStone/100) +1
        end 
        if  middleStone < total_Middle_Stone  then
            self.middleStone_num = self.middleStone_num + middleStone
            tempExp = total_Small_Stone * 10 + self.middleStone_num * 100
                 
        elseif total_Middle_Stone < middleStone and total_Middle_Stone > 0 then
            self.middleStone_num = total_Middle_Stone
            tempExp = self.middleStone_num * 100
        else 
            local hStone = needExp - total_Small_Stone * 10 - total_Middle_Stone * 100
            local highStone = math.modf(mStone/500)
            if hStone%500 ~= 0 then
                highStone = math.modf(mStone/500) +1
            end
            if highStone < total_High_Stone  then
                self.highStone_num = self.highStone_num + highStone
                tempExp = total_Small_Stone * 10 + total_Middle_Stone * 100 + self.highStone_num * 500
            else
                self.highStone_num = total_High_Stone
                tempExp = self.highStone_num * 500
                
            end     
        end
           
    end
    return self.smallStone_num,self.middleStone_num,self.highStone_num,tempExp
end


--[[--
    获取装备下级锻造属性
]]
function game_equip_forge.getNextProperty( self,m_select_id,propertyId,equip_forge_level,sort )
    local equip_set_random = getConfig(game_config_field.equip_set_random)
    equip_set_random = json.decode(equip_set_random:getFormatBuffer())
    local propertyId = propertyId
    local equip_forge_level = equip_forge_level + 1

    local sort = sort
    local NextProperty = 0
    local equip_set_level = getConfig(game_config_field.equip_set_level)

    local ability = equip_set_random[tostring(propertyId)].ability
    local quality = equip_set_random[tostring(propertyId)].quality
    local add_table = equip_set_level:getNodeWithKey(tostring(equip_forge_level))
    add_table = json.decode(add_table:getFormatBuffer())
    local addsort = tostring("add" .. quality)
    local add = add_table[addsort]
    local modulus = {1,0.9,0.6,0.9,6}
    local modulus2 = {0.005,0.003,0.002,0.001}

    if #self.modulus_table >= 9 then
        for i=1,5 do
            modulus[i] = self.modulus_table[i]
        end
        for i=1,4 do
            modulus2[i] = self.modulus_table[i + 5]
        end
    end

    if sort >= 1 and sort <= 5 then
        NextProperty = ability + add * modulus[sort]
        NextProperty = math.floor(NextProperty)
    else
        NextProperty = ability + add * modulus2[quality]

    end
    return NextProperty

end
--[[--
    获取最大等级
]]
function game_equip_forge.maxLevel( self )
    local level_config = getConfig(game_config_field.equip_set_level)
    level_config = json.decode(level_config:getFormatBuffer())
    local maxLevel_table = {}
    for k,v in pairs(level_config) do
       
        table.insert(maxLevel_table,k)
    end
    local Maxlevel = math.max(unpack(maxLevel_table))
    return Maxlevel
    -- body
end
--[[
    获取装备属性2
]]
function game_equip_forge.getProperty2(self,m_select_id)
   
    if self.m_select_id then     
        self.property_node:setVisible(false)
        local itemData,itemCfg = game_data:getEquipDataById(tostring(self.m_select_id));
        self:ProgressTiemer(m_select_id)
        local maxLevel = self:maxLevel()
        if itemData.equip_forge_level.lv == maxLevel then
            local equip_forge_level = itemData.equip_forge_level or {}
            self.m_exp_table = util.table_copy(equip_forge_level)
            local propertyData = itemData.equip_forge          
            local propertyId_table = {}
            for k,v in pairs(propertyData) do
                
                table.insert(propertyId_table,k)

            end
            for i=1,3 do   
                local propertyId = propertyId_table[i] 
               
                local equip_set_random = getConfig(game_config_field.equip_set_random)
                equip_set_random = json.decode(equip_set_random:getFormatBuffer())
                local sort = equip_set_random[propertyId].sort
                local  enemy = equip_set_random[propertyId].enemy
                if enemy[1] == -1 then
                    self.property_table[i].property:setString("(Địch)\n" .. PUBLIC_ABILITY_TABLE["ability_" .. sort].name)
                else
                    self.property_table[i].property:setString(PUBLIC_ABILITY_TABLE["ability_" .. sort].name)
                end
                local propertyName = PUBLIC_ABILITY_TABLE["ability_" .. sort].attrName
                local forge_lv = itemData.equip_forge_level.lv
                cclog2(propertyData[tostring(propertyId)],"propertyData[tostring(propertyId)] === ")
                local forge_value = propertyData[tostring(propertyId)][propertyName] or 0
                cclog2(forge_value,"forge_value ==")
                -- forge_value = string.format("%.4f",tostring(forge_value))
                if enemy[1] == -1 then
                    forge_value = forge_value * 0.1
                    if sort > 5 and sort < 10 then
                        forge_value = string.format("%.2f",tostring(forge_value))
                        forge_value = forge_value .. "%"
                    end
                    self.property_table[i].cur_property:setString("-" .. forge_value )
                else
                    if sort > 5 and sort < 10 then
                        forge_value = string.format("%.2f",tostring(forge_value))
                        forge_value = forge_value .. "%"
                    end
                    self.property_table[i].cur_property:setString("+".. forge_value )
                end
               
                local color_id = equip_set_random[propertyId].quality
                if color_id == 1 then
                    self.property_table[i].property:setColor(ccc3(0,255,0))
                    self.property_table[i].cur_property:setColor(ccc3(0,255,0))
              


                elseif color_id == 2 then
                    self.property_table[i].property:setColor(ccc3(35,160,254)) 
                    self.property_table[i].cur_property:setColor(ccc3(35,160,254)) 
               
                elseif color_id == 3 then
                    self.property_table[i].property:setColor(ccc3(140,30,160)) 
                     self.property_table[i].cur_property:setColor(ccc3(140,30,160))  
                 
                elseif color_id ==4 then
                    self.property_table[i].property:setColor(ccc3(251,168,0)) 
                    self.property_table[i].cur_property:setColor(ccc3(251,168,0))  
                 
                end
                self.property_table[i].cur_property:setPosition(ccp(380,240 - i*24))
                self.property_table[i].property:setPosition(ccp(310,240 - i*24))
                self.property_node:setVisible(true)
                self.property_node:setPosition(ccp(35,-2))
                self.property_table[i].next_property:setVisible(false)

            end

        end

            
    end
end
--[[
    获取装备属性
]]
function game_equip_forge.getProperty(self,m_select_id)
   
    if self.m_select_id then     
        self.property_node:setVisible(false)
        local itemData,itemCfg = game_data:getEquipDataById(tostring(self.m_select_id));
        self:ProgressTiemer(m_select_id)
         local maxLevel = self:maxLevel()
        if itemData.equip_forge and next(itemData.equip_forge) and itemData.equip_forge_level.lv > 0 and itemData.equip_forge_level.lv < maxLevel then
            local equip_forge_level = itemData.equip_forge_level or {}
            self.m_exp_table = util.table_copy(equip_forge_level)
            -- cclog2(self.m_exp_table,"self.m_exp_table")
            local propertyData = itemData.equip_forge          
            local propertyId_table = {}
            for k,v in pairs(propertyData) do
                
                table.insert(propertyId_table,k)

            end
            local function sortfunction( data1,data2 )
                return tonumber(data1) < tonumber(data2)
            end
            table.sort( propertyId_table, sortfunction )
            for i=1,3 do   
                local propertyId = propertyId_table[i] 
                local equip_set_random = getConfig(game_config_field.equip_set_random)
                equip_set_random = json.decode(equip_set_random:getFormatBuffer())
                local sort = equip_set_random[propertyId].sort
                local enemy = equip_set_random[propertyId].enemy
                if enemy[1] == -1 then
                    self.property_table[i].property:setString("(Địch)\n" .. PUBLIC_ABILITY_TABLE["ability_" .. sort].name)
                else
                    self.property_table[i].property:setString(PUBLIC_ABILITY_TABLE["ability_" .. sort].name)
                end
               
                local propertyName = PUBLIC_ABILITY_TABLE["ability_" .. sort].attrName
                local forge_lv = itemData.equip_forge_level.lv
                cclog2(propertyData[tostring(propertyId)],"propertyData[tostring(propertyId)] 11=== ")
                local forge_value = propertyData[tostring(propertyId)][propertyName] or 0
                cclog2(forge_value,"forge_value11111 ")
                -- forge_value = string.format("%.4f",tostring(forge_value))
                if enemy[1] == -1 then
                    forge_value = forge_value * 0.1
                    if sort > 5 and sort < 10 then
                        forge_value = string.format("%.2f",tostring(forge_value))
                        forge_value = forge_value .. "%"
                    end
                    self.property_table[i].cur_property:setString("-" .. forge_value )
                else
                    if sort > 5 and sort < 10 then
                        forge_value = string.format("%.2f",tostring(forge_value))
                        forge_value = forge_value .. "%"
                    end
                    self.property_table[i].cur_property:setString("+" .. forge_value )
                end
                local NextProperty = self:getNextProperty(m_select_id,propertyId,forge_lv,sort)
                -- NextProperty = string.format("%.4f",NextProperty)
                if enemy[1] == -1 then
                    NextProperty = NextProperty * 0.1
                    if sort > 5 and sort < 10 then
                        NextProperty = string.format("%.2f",tostring(NextProperty))
                        NextProperty = NextProperty .. "%"
                    end
                    self.property_table[i].next_property:setString(tostring("Level kế -" .. NextProperty ))
                else
                    if sort > 5 and sort < 10 then
                        NextProperty = string.format("%.2f",tostring(NextProperty))
                        NextProperty = NextProperty .. "%"
                    end
                    self.property_table[i].next_property:setString(tostring("Level kế +" .. NextProperty ))
                end
                local color_id = equip_set_random[propertyId].quality
                if color_id == 1 then
                    self.property_table[i].property:setColor(ccc3(0,255,0))
                    self.property_table[i].cur_property:setColor(ccc3(0,255,0))
                    self.property_table[i].next_property:setColor(ccc3(0,255,0))
                elseif color_id == 2 then
                    self.property_table[i].property:setColor(ccc3(35,160,254)) 
                    self.property_table[i].cur_property:setColor(ccc3(35,160,254)) 
                    self.property_table[i].next_property:setColor(ccc3(35,160,254))
                elseif color_id == 3 then
                    self.property_table[i].property:setColor(ccc3(150,100,255)) 
                     self.property_table[i].cur_property:setColor(ccc3(150,100,255))  
                     self.property_table[i].next_property:setColor(ccc3(150,100,255))
                elseif color_id ==4 then
                    self.property_table[i].property:setColor(ccc3(251,168,0)) 
                    self.property_table[i].cur_property:setColor(ccc3(251,168,0))  
                    self.property_table[i].next_property:setColor(ccc3(251,168,0))
                end
                self.property_table[i].cur_property:setPosition(ccp(340,240 - i*24))
                self.property_table[i].property:setPosition(ccp(300,240 - i*24))
                self.property_table[i].next_property:setPosition(ccp(375,240 - i*24))
                self.property_node:setVisible(true)
                self.property_node:setPosition(ccp(23,-2))
                self.property_table[i].next_property:setVisible(true)
            end

        end

            
    end
end
--[[--
    创建装备列表
]]
function game_equip_forge.createEquipTableView(self,viewSize,tableData)
    cclog("-----------------game_equip_forge createEquipTableView-----------------");
    self.last_m_sel_img = nil;
    self.m_selEquipDataTab = game_data:getEquipIdTable();
    local equipCount = #self.m_selEquipDataTab;
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = equipCount;
    params.itemActionFlag = true;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = game_util:createEquipItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < equipCount then
                local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipDataTab[index+1]);
                game_util:setEquipItemInfoByTable2(ccbNode,itemData);
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                if itemData.id == self.m_select_id then
                    m_sel_img:setVisible(true);
                    self.last_m_sel_img = m_sel_img
                else
                    m_sel_img:setVisible(false);
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local m_sel_img = ccbNode:spriteForName("m_sel_img")
            local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipDataTab[index+1]);
            if itemData.id ~= self.m_select_id then
                if self.last_m_sel_img then
                    self.last_m_sel_img:setVisible(false)
                end
                self.property_node:setVisible(true)
                m_sel_img:setVisible(true)
                self.label_exp:setVisible(true)
                self.m_select_id = itemData.id
                self.last_m_sel_img = m_sel_img
                -- cclog2(self.m_select_id,"m_select_id")
                self:refreshTips()
            end
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    点击添加锻造石
]]
function game_equip_forge.initMaterialLayerTouch(self,formation_layer)
    local tempItem = nil;
    local realPos = nil;
    local tag = nil; 
    local function onTouchBegan(x, y)
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        for k,v in pairs(self.m_material_node_tab) do
            tempItem = v.parentNode;
            if tempItem:boundingBox():containsPoint(realPos) then
                tag =  v.m_material_node:getTag();
                --cclog("onTouchBegan tag " .. tag)
            end
        end
        return true
    end
    
    local function onTouchMoved(x, y)
    end
    
    local function onTouchEnded(x, y)
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        local maxLevel = self:maxLevel()

        for k,v in pairs(self.m_material_node_tab) do
            local tempItem = v.parentNode;
            if tempItem:boundingBox():containsPoint(realPos) then
                --cclog("initSkillLayerTouch onTouchEnded ------- tag == " .. tag)
                local maxLevel1 = self.maxLevel()
                if self.current_lv then
                    if self.current_lv < maxLevel1 then
                        if tag == 1 and (self.smallStone_num * 10 + self.middleStone_num * 100 + self.highStone_num *500 + self.curExp) < self.maxExp then
                            local totalnum = game_data:getUserStatusDataByKey("small_forge_stone")
                            if totalnum > 0 then
                                self.smallStone_num = self.smallStone_num + 1
                            
                                if self.smallStone_num >= totalnum then
                                  self.smallStone_num =  totalnum
                                end
    
                                self.m_material_node_tab[1].m_stone_cost_label:setString(self.smallStone_num)
                                self:ProgressTiemer(self.m_select_id)
                                self.label_exp:setString(self.smallStone_num * 10 + self.middleStone_num * 100 + self.highStone_num *500 + self.curExp .. "/" .. self.maxExp) 
                            else 
                                game_util:addMoveTips({text = "Không đủ Đá Rèn thô!"});
                            end
    
                        elseif tag == 2 and (self.smallStone_num * 10 + self.middleStone_num * 100 + self.highStone_num *500 + self.curExp) < self.maxExp then
                            local totalnum = game_data:getUserStatusDataByKey("middle_forge_stone")
                            if totalnum > 0 then
                                self.middleStone_num = self.middleStone_num+ 1
                            
                                if self.middleStone_num >= totalnum then
                                    self.middleStone_num =  totalnum
                                end
                                self.m_material_node_tab[2].m_stone_cost_label:setString(self.middleStone_num)
                                 self:ProgressTiemer(self.m_select_id)
                                 self.label_exp:setString(self.smallStone_num * 10 + self.middleStone_num * 100 + self.highStone_num *500 + self.curExp .. "/" .. self.maxExp) 
                            else
                                 game_util:addMoveTips({text = "Không đủ Đá Rèn trung!"});
                            end
                        elseif tag == 3 and (self.smallStone_num * 10 + self.middleStone_num * 100 + self.highStone_num *500 + self.curExp) < self.maxExp then
                            local totalnum = game_data:getUserStatusDataByKey("high_forge_stone")
                            if totalnum > 0 then
                                self.highStone_num = self.highStone_num + 1
                            
                                if self.highStone_num >= totalnum then
                                    self.highStone_num =  totalnum
                                end
                                self.m_material_node_tab[3].m_stone_cost_label:setString(self.highStone_num)
                                 self:ProgressTiemer(self.m_select_id)
                                 self.label_exp:setString(self.smallStone_num * 10 + self.middleStone_num * 100 + self.highStone_num *500 + self.curExp .. "/" .. self.maxExp) 
                            else
                                game_util:addMoveTips({text = "Không đủ Đá Rèn cao cấp!"});
                            end 
                        else
                             game_util:addMoveTips({text = "Đã đủ EXP!"});
                        end
                    end
                end
            end
        end
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY)
    formation_layer:setTouchEnabled(true)
end
--[[--
    进度条
]]
function game_equip_forge.ProgressTiemer(self,m_select_id)
    local expBg = self.m_layer_progress_bar
    local expBgSize = expBg:getContentSize(); 
    if self.maxExp then
        local percentage = self.curExp/self.maxExp * 100  
        self.label_exp:setString(self.curExp .. "/" .. self.maxExp)     
        local expBarAdd = game_util:createProgressTimer({fileName = "zbdz_jindutiao.png",percentage = percentage})
        expBg:removeAllChildrenWithCleanup(true)
        expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
        expBg:addChild(expBarAdd,2,1);

        local tempExp = self.smallStone_num * 10 + self.middleStone_num * 100 + self.highStone_num *500 + self.curExp or 0
        local temp_percentage = (self.smallStone_num * 10 + self.middleStone_num * 100 + self.highStone_num *500 + self.curExp)/self.maxExp *100
        temp_percentage = math.min(100,temp_percentage)
        local bar = game_util:createProgressTimer({fileName = "zbdz_jindutiao2.png",percentage = temp_percentage})
        bar:runAction(CCProgressFromTo:create(1,percentage,temp_percentage));
        -- local animArr = CCArray:create();
        --     animArr:addObject(CCBlink:create(2,2));
        --     bar:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
        self.label_exp:setString(self.smallStone_num * 10 + self.middleStone_num * 100 + self.highStone_num *500 + self.curExp .. "/" .. self.maxExp)    
        bar:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
        if self.smallStone_num * 10 > 0 or self.middleStone_num > 0 or self.highStone_num > 0 then

            -- local array = CCArray:create();
            -- local x = (self.smallStone_num * 10 + self.middleStone_num * 100 + self.highStone_num *500 + self.curExp)/self.maxExp * 100
            -- cclog2(x, "xxx")
            -- if x > 100 then
            --     x = 100
            -- end
            -- array:addObject(CCProgressFromTo:create(1,self.curExp,x));
            -- cclog("laile ma alalala11111111")
            -- bar:runAction(CCSequence:create(array));    
            -- cclog("laile ma alalala22222222") 
        end
        expBg:addChild(bar,1,2);
       
    end
end
--[[
    设置星星
]]
function game_equip_forge.setStarPos(self,index)
    cclog("-----------------game_equip_forge setStarPos-----------------");
     self.star_node:removeAllChildrenWithCleanup(true)
    for i=1,10 do
        local star = nil
        if i < index + 1 and i<4 then
            star = CCSprite:createWithSpriteFrameName("equip_forge_dengjieqiu2.png");
        elseif i < index + 1 and i<7 then
            star = CCSprite:createWithSpriteFrameName("equip_forge_dengjieqiu.png");
        elseif i < index + 1 and i<9 then
            star = CCSprite:createWithSpriteFrameName("equip_forge_dengjieqiu1.png");
        elseif i < index + 1 and i<11 then
            star = CCSprite:createWithSpriteFrameName("equip_forge_dengjieqiu3.png"); 

                   
        elseif i == index + 1 and i<4 then
            star = CCSprite:createWithSpriteFrameName("equip_forge_dengjieqiu2.png");
            local animArr = CCArray:create();
            animArr:addObject(CCFadeTo:create(1,50));
            animArr:addObject(CCFadeTo:create(1,150));
            star:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
        elseif i == index + 1 and i<7 then
            star = CCSprite:createWithSpriteFrameName("equip_forge_dengjieqiu.png");
            local animArr = CCArray:create();
            animArr:addObject(CCFadeTo:create(1,50));
            animArr:addObject(CCFadeTo:create(1,150));
            star:runAction(CCRepeatForever:create(CCSequence:create(animArr)));    
        elseif i == index + 1 and i<9 then
            star = CCSprite:createWithSpriteFrameName("equip_forge_dengjieqiu1.png");
            local animArr = CCArray:create();
            animArr:addObject(CCFadeTo:create(1,50));
            animArr:addObject(CCFadeTo:create(1,150));
            star:runAction(CCRepeatForever:create(CCSequence:create(animArr)));   
        elseif i == index + 1 and i<11 then
            star = CCSprite:createWithSpriteFrameName("equip_forge_dengjieqiu3.png");
            local animArr = CCArray:create();
            animArr:addObject(CCFadeTo:create(1,50));
            animArr:addObject(CCFadeTo:create(1,150));
            star:runAction(CCRepeatForever:create(CCSequence:create(animArr)));   
        else
            star = CCSprite:createWithSpriteFrameName("equip_forge_quan.png");
            
        end
        if star then
            star:setAnchorPoint(ccp(0.5,0.5))
            star:setPosition(ccp(20 * ( (i-1) % 5),32 - 20 * math.floor( (i-1) / 5)))
            self.star_node:addChild(star,10,i)
        end
    end
end
--[[--
    刷新列表
]]
function game_equip_forge.refreshEquipTableView(self)
    cclog("-----------------game_equip_forge refreshEquipTableView-----------------");
    self.table_view_node:removeAllChildrenWithCleanup(true);
    self.m_selEquipDataTab = game_data:getEquipIdTable();
    self.m_tableView = self:createEquipTableView(self.table_view_node:getContentSize(),self.m_selEquipDataTab);
    self.table_view_node:addChild(self.m_tableView);
    self:maxLevel()

end
--[[--
    刷新tips
]]
function game_equip_forge.refreshTips(self,small,middle,high)
    cclog("-----------------game_equip_forge refreshTips----------------");
 if self.m_select_id then
        local itemData,itemCfg = game_data:getEquipDataById(tostring(self.m_select_id));
        local forge_lv = 0
        local exp = 0
        if itemData.equip_forge_level then
            forge_lv = itemData.equip_forge_level.lv or 0
            exp = itemData.equip_forge_level.exp
        end
        
        self.cur_level:setString(tostring(forge_lv))
        self.curExp = exp
        local st_lv = itemData.st_lv
        local sort = itemCfg:getNodeWithKey("sort"):toInt()
        self:setStarPos(forge_lv)
        self.show_node:setVisible(true)
        --self:getProperty(self,m_select_id)
        local ccbNode = game_util:createEquipItemByCCB(itemData);
        self.m_anim_node:removeAllChildrenWithCleanup(true)
        self.m_anim_node:addChild(ccbNode,10,10);
        self.m_tips_spr_1:setVisible(false);
        --self.label_exp:setString(curExp .. "/" .. maxExp)
        self.smallStone_num = small or 0
        self.middleStone_num = middle or 0;
        self.highStone_num = high or 0;
        self.m_material_node_tab[1].m_stone_total_label:setString(game_data:getUserStatusDataByKey("small_forge_stone") or 0)
        self.m_material_node_tab[2].m_stone_total_label:setString(game_data:getUserStatusDataByKey("middle_forge_stone") or 0)
        self.m_material_node_tab[3].m_stone_total_label:setString(game_data:getUserStatusDataByKey("high_forge_stone") or 0)
        self.m_material_node_tab[1].m_stone_cost_label:setString(self.smallStone_num)
        self.m_material_node_tab[2].m_stone_cost_label:setString(self.middleStone_num)
        self.m_material_node_tab[3].m_stone_cost_label:setString(self.highStone_num)
        local maxLevel = self:maxLevel()
        if forge_lv >= 0 and forge_lv < maxLevel then
            local expConfig = getConfig(game_config_field.equip_set_level)
            local need_maxExp = expConfig:getNodeWithKey(tostring(forge_lv)+1)
            need_maxExp = json.decode(need_maxExp:getFormatBuffer()) or {}
            self.maxExp = need_maxExp.need
            self.label_exp:setString(self.curExp .. "/" .. self.maxExp)
            self.current_lv = forge_lv
            self:ProgressTiemer(self.m_select_id)
            self.label_exp:setVisible(true)
            self:getProperty(self.m_select_id)
        else

            self.label_exp:setVisible(false)
            self:getProperty2(self.m_select_id)

        end
       
        self.m_anim_node:removeAllChildrenWithCleanup(true)
        self.m_anim_node:addChild(ccbNode,10,10);
        self.m_tips_spr_1:setVisible(false);

    else
        self.m_tips_spr_1:setVisible(true);
        self.m_anim_node:removeAllChildrenWithCleanup(true)
        self.show_node:setVisible(false)
    end
end

--[[--
    刷新ui
]]
function game_equip_forge.refreshUi(self)
    cclog("-----------------game_equip_forge refreshUi-----------------");
    local totalMetal = game_data:getUserStatusDataByKey("metal") or 0
    local value,unit = game_util:formatValueToString(totalMetal);
    self.m_metal_total_label:setString(tostring(value .. unit));

    --local totalMetalCore = game_data:getUserStatusDataByKey("metalcore") or 0
    --local value2,unit2 = game_util:formatValueToString(totalMetalCore);
    -- self.m_refining_total_label:setString(tostring(value2 .. unit2))

    self:refreshEquipTableView()
    self:refreshTips()
end
--[[--
    初始化
]]
function game_equip_forge.init(self,t_params)
    cclog("-----------------game_equip_forge init-----------------");
     t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.enterType = t_params.enterType or 0
    self.m_select_id = t_params.m_select_id or nil;
    self.last_m_sel_img = nil;
    self.m_exp_table = {lv = 0}
    --数值比率读配置
    self.modulus_table = {}
    local equip_set_rate = getConfig(game_config_field.equip_set_rate)
    for i=1,equip_set_rate:getNodeCount() do
        local itemCfg = equip_set_rate:getNodeWithKey(tostring(i))
        local rate_num = itemCfg:getNodeWithKey("rate_num"):toFloat()
        table.insert(self.modulus_table,rate_num)
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_equip_forge.create(self,t_params)
    cclog("-----------------game_equip_forge create-----------------");
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end

return game_equip_forge;
