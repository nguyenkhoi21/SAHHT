--- 装备锻造属性

local game_equip_forge_pop = {
    m_close_btn = nil,
    m_root_layer = nil,
    m_saveBtn = nil,
    m_refreshBtn = nil,
    temp_property_node = nil,
    cur_property_node = nil,
    m_arrow_sprite = nil,
    root_node = nil,
    layer_color = nil,
    m_tGameData = nil,
    m_temp_property_table = nil,
    m_cur_property_table = nil,
    m_stone_table = nil,
    m_sort = nil,
    m_have_smallStone = nil,
    m_have_middleStone = nil,
    m_have_highStone = nil,
    m_metal_total_label = nil,
    callback = nil,
    cost_metal = nil,
    cost_stone = nil,
    equip_set_cost = nil,
};
--[[--
    销毁ui
]]
function game_equip_forge_pop.destroy(self)
    -- body
    cclog("-----------------game_equip_forge_pop destroy-----------------");
    self.m_close_btn = nil;
    self.m_root_layer = nil;
    self.m_saveBtn = nil;
    self.m_refreshBtn = nil;
    self.temp_property_node = nil;
    self.cur_property_node = nil;
    self.m_arrow_sprite = nil;
    self.root_node = nil;
    self.layer_color = nil;
    self.m_tGameData = nil;
    self.m_temp_property_table = nil;
    self.m_cur_property_table = nil;
    self.m_stone_table = nil;
    self.m_sort = nil;
    self.m_have_smallStone = nil;
    self.m_have_middleStone = nil;
    self.m_have_highStone = nil;
    self.m_metal_total_label = nil;
    self.callback = nil;
    self.cost_metal = nil;
    self.cost_stone = nil;
    self.equip_set_cost = nil;

end
--[[--
    返回
]]
function  game_equip_forge_pop.back(self,backType)
    if self.callback and type(self.callback) == "function" then
        self.callback(self.m_tGameData.id)
    end
    game_scene:removePopByName("game_equip_forge_pop");
    -- game_scene:enterGameUi("game_equip_forge",{gameData = nil});
end
--[[--
    读取ccbi创建ui
]]
function  game_equip_forge_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then
            self:back();
      
        elseif  btnTag == 501 then --保留
             local params = {}
            params.equip_id = self.m_tGameData.id
            params.sort = self.sort
           
            params.is_save = 1
            local function responseMethod( tag,gameData )
                self:saveProperty(gameData)
                -- body
            end    
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_forge_refresh"), http_request_method.GET, params,"equip_forge_refresh")
        
        elseif  btnTag == 502 then --刷新
            local params = {}
            params.equip_id = self.m_tGameData.id
            params.sort = self.sort
            if self.sort == 0 and self.m_have_smallStone < 10 then
                --game_util:addMoveTips({text = "您的初级锻造石不足！赶紧充钱去~" })
            elseif self.sort == 1 and self.m_have_middleStone < 10 then
                --game_util:addMoveTips({text = "您的中级锻造石不足！赶紧充钱去~" })
            elseif self.sort == 2 and self.m_have_highStone < 10 then
                --game_util:addMoveTips({text = "您的高级锻造石不足！赶紧充钱去~" })
            elseif self.m_metal_total_label <2000 then
                --game_util:addMoveTips({text = "您的铁不足！赶紧充钱去~" })
            end
            params.is_save = 0
            local function responseMethod( tag,gameData )
                self:getTempProperty(gameData)
                -- body
            end    
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_forge_refresh"), http_request_method.GET, params,"equip_forge_refresh")
   
        elseif btnTag >= 104 and btnTag <= 106 then--select succinct mode
           
           
            --cclog2(equip_set_cost,"equip_set_cost ===")
            local index = btnTag - 100
            local stoneIndex = index - 3
            local costId = self.equip_set_cost:getNodeWithKey(tostring(stoneIndex))
            local cost = costId:getNodeWithKey("cost")
            cost = json.decode(cost:getFormatBuffer()) or {}
            local cost_stone_ID = cost[1]
            local cost_stone = cost_stone_ID[3]
            self.cost_stone:setString(tostring(cost_stone))
            local cost_metal_ID = cost[2]
            local cost_metal = cost_metal_ID[3]
            self.cost_metal:setString(tostring(cost_metal))
            self.sort = index - 4
            for i=4,6 do
                local stoneIndex1 = i - 3
                game_util:setCCControlButtonBackground(self.m_button[i],"equip_forge_noselect.png")
                self.m_stone_table[stoneIndex1]:setVisible(false)
            end
            game_util:setCCControlButtonBackground(self.m_button[index],"equip_forge_selected.png")
            self.m_stone_table[stoneIndex]:setVisible(true)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_equip_forge_pop.ccbi");
    self.layer_color = ccbNode:layerForName("layer_color")
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_saveBtn = ccbNode:controlButtonForName("m_saveBtn")
    self.m_refreshBtn = ccbNode:controlButtonForName("m_refreshBtn")
    self.cost_stone = ccbNode:labelTTFForName("cost_stone")
    self.cost_metal = ccbNode:labelTTFForName("cost_metal")
    self.m_saveBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_refreshBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_refreshBtn:setPosition(ccp(90,2))
    self.m_saveBtn:setVisible(false)
    self.temp_property_node = ccbNode:nodeForName("temp_property_node")
    -- local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    -- m_bg_sprite:setScale(resolution_config:getScale())
    self.cur_property_node = ccbNode:nodeForName("cur_property_node")
    self.cur_property_node:setPosition(ccp(100,120))

    self.m_arrow_sprite = ccbNode:spriteForName("m_arrow_sprite")
    self.m_cur_property_table = {}
    self.m_temp_property_table = {}
    self.m_button = {}
    self.m_stone_table = {}

    for i=4,6 do
        self.m_button[i] = ccbNode:controlButtonForName("m_button" .. i)
        -- cclog2(self.m_button[i],"self.m_button == " .. i)

    end
    self.m_button[4]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_button[5]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_button[6]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    game_util:setCCControlButtonBackground(self.m_button[4],"equip_forge_selected.png")
    local cur_property,cur_property_name = nil;
    for i=1,3 do 
        cur_property = ccbNode:labelTTFForName("cur_property" .. i)
        cur_property_name = ccbNode:labelTTFForName("cur_property_name" .. i)
        --cclog2(cur_property_name,"cur_property_name")
        self.m_cur_property_table[i] = {cur_property = cur_property, cur_property_name = cur_property_name}

    end
    local temp_property,temp_property_name = nil
    for i=1,3 do
        temp_property = ccbNode:labelTTFForName("temp_property" .. i)
      
        temp_property_name = ccbNode:labelTTFForName("temp_property_name" .. i)
     
        self.m_temp_property_table[i] = {temp_property = temp_property,temp_property_name = temp_property_name }
        --cclog2(self.m_temp_property_table[i],"self.m_temp_property_table[i] ==")
    end

    for i=1,3 do
        self.m_stone_table[i] = ccbNode:spriteForName("m_stone" .. i)
        self.m_stone_table[i]:setVisible(false)
    end
    self.m_stone_table[1]:setVisible(true)

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);

    return ccbNode;
end
--[[--
    保留新属性
]]
function game_equip_forge_pop.saveProperty( self,gameData )
    local data = gameData:getNodeWithKey("data");   
    local _client_cache_update = data:getNodeWithKey("_client_cache_update")
    local equip = _client_cache_update:getNodeWithKey("equip")
    local _equip = equip:getNodeWithKey("_equip")
    local update = _equip:getNodeWithKey("update")
    local num_data = update:getNodeWithKey(tostring(self.m_tGameData.id))
    local tempPropertyData = num_data:getNodeWithKey("equip_forge")
    local propertyData = json.decode(tempPropertyData:getFormatBuffer()) or {}
    num_data = json.decode(num_data:getFormatBuffer()) or {}
    local propertyId_table = {}
    for k,v in pairs(propertyData) do
        table.insert(propertyId_table,k)
    end
    for i=1,3 do   
        local propertyId = propertyId_table[i] 
        --cclog2(propertyId,"propertyId ==")
        local equip_set_random = getConfig(game_config_field.equip_set_random)
        equip_set_random = json.decode(equip_set_random:getFormatBuffer())
        local sort = equip_set_random[propertyId].sort
        local enemy = equip_set_random[propertyId].enemy
        if enemy[1] == -1 then
            self.m_cur_property_table[i].cur_property_name:setString("(Địch)\n" .. PUBLIC_ABILITY_TABLE["ability_" .. sort].name)
        else
            self.m_cur_property_table[i].cur_property_name:setString(PUBLIC_ABILITY_TABLE["ability_" .. sort].name)
        end
        
        local propertyName = PUBLIC_ABILITY_TABLE["ability_" .. sort].attrName
        local forge_lv =num_data.equip_forge_level.lv
        local forge_value = propertyData[tostring(propertyId)][propertyName] or 0
        -- forge_value = string.format("%.4f",tostring(forge_value))
        if enemy[1] == -1 then
            forge_value = forge_value * 0.1
            self.m_cur_property_table[i].cur_property:setString("-" .. forge_value)
        else
            self.m_cur_property_table[i].cur_property:setString("+" .. forge_value)
        end
        local color_id = equip_set_random[propertyId].quality
        if color_id == 1 then
            self.m_cur_property_table[i].cur_property_name:setColor(ccc3(0,255,0))
            self.m_cur_property_table[i].cur_property:setColor(ccc3(0,255,0))
    
        elseif color_id == 2 then
            self.m_cur_property_table[i].cur_property_name:setColor(ccc3(35,160,254)) 
            self.m_cur_property_table[i].cur_property:setColor(ccc3(35,160,254)) 
       
        elseif color_id == 3 then
            self.m_cur_property_table[i].cur_property_name:setColor(ccc3(150,100,255)) 
            self.m_cur_property_table[i].cur_property:setColor(ccc3(150,100,255))  
         
        elseif color_id ==4 then
            self.m_cur_property_table[i].cur_property_name:setColor(ccc3(251,168,0)) 
            self.m_cur_property_table[i].cur_property:setColor(ccc3(251,168,0))  
         
        end
    end
    self.temp_property_node:setVisible(false)
    --self.temp_property_node:setPosition(ccp(160,120))
    self.m_arrow_sprite:setVisible(false)
    self.cur_property_node:setPosition(ccp(100,120))
    self.m_saveBtn:setVisible(false)
    self.m_refreshBtn:setPosition(ccp(90,2))


    -- body
end
--[[--
    获取刷新属性
]]
function game_equip_forge_pop.getTempProperty( self,gameData )
    local data = gameData:getNodeWithKey("data");   
    local _client_cache_update = data:getNodeWithKey("_client_cache_update")
    local equip = _client_cache_update:getNodeWithKey("equip")
    local _equip = equip:getNodeWithKey("_equip")
    local update = _equip:getNodeWithKey("update")
    local num_data = update:getNodeWithKey(tostring(self.m_tGameData.id))
    local tempPropertyData = num_data:getNodeWithKey("equip_forge_temp")
    local propertyData = json.decode(tempPropertyData:getFormatBuffer()) or {}
    num_data = json.decode(num_data:getFormatBuffer()) or {}
    local propertyId_table = {}
    for k,v in pairs(propertyData) do
        table.insert(propertyId_table,k)
    end
    for i=1,3 do   
        local propertyId = propertyId_table[i] 
        --cclog2(propertyId,"propertyId ==")
        local equip_set_random = getConfig(game_config_field.equip_set_random)
        equip_set_random = json.decode(equip_set_random:getFormatBuffer())
        local sort = equip_set_random[propertyId].sort
        local enemy = equip_set_random[propertyId].enemy
        if enemy[1] == -1 then
             self.m_temp_property_table[i].temp_property_name:setString("(Địch)\n" .. PUBLIC_ABILITY_TABLE["ability_" .. sort].name)
        else
             self.m_temp_property_table[i].temp_property_name:setString(PUBLIC_ABILITY_TABLE["ability_" .. sort].name)
        end
       
        local propertyName = PUBLIC_ABILITY_TABLE["ability_" .. sort].attrName
        local forge_lv =num_data.equip_forge_level.lv
        local forge_value = propertyData[tostring(propertyId)][propertyName] or 0
        -- forge_value = string.format("%.4f",tostring(forge_value))
        if enemy[1] == -1 then
            forge_value = forge_value * 0.1
            if sort > 5 and sort < 10 then
                forge_value = string.format("%.2f",tostring(forge_value))
                forge_value = forge_value .. "%"
            end
            self.m_temp_property_table[i].temp_property:setString("-" .. forge_value)
        else
            if sort > 5 and sort < 10 then
                forge_value = string.format("%.2f",tostring(forge_value))
                forge_value = forge_value .. "%"
            end
            self.m_temp_property_table[i].temp_property:setString("+" .. forge_value)
        end
        local color_id = equip_set_random[propertyId].quality
        if color_id == 1 then
            self.m_temp_property_table[i].temp_property_name:setColor(ccc3(0,255,0))
            self.m_temp_property_table[i].temp_property:setColor(ccc3(0,255,0))
    
        elseif color_id == 2 then
            self.m_temp_property_table[i].temp_property_name:setColor(ccc3(35,160,254)) 
            self.m_temp_property_table[i].temp_property:setColor(ccc3(35,160,254)) 
       
        elseif color_id == 3 then
            self.m_temp_property_table[i].temp_property_name:setColor(ccc3(150,100,255)) 
            self.m_temp_property_table[i].temp_property:setColor(ccc3(150,100,255))  
         
        elseif color_id ==4 then
            self.m_temp_property_table[i].temp_property_name:setColor(ccc3(251,168,0)) 
            self.m_temp_property_table[i].temp_property:setColor(ccc3(251,168,0))  
         
        end
    end
    self.temp_property_node:setVisible(true)
    self.temp_property_node:setPosition(ccp(160,120))
    self.m_arrow_sprite:setVisible(true)
    self.cur_property_node:setPosition(ccp(35,120))
    self.m_saveBtn:setVisible(true)
    self.m_refreshBtn:setPosition(ccp(140,2))

end
--[[--
    获取当前属性
]]
function game_equip_forge_pop.getProperty(self)
    --cclog2(self.m_tGameData,"self.m_tGameData ===")    
    if  next(self.m_tGameData.equip_forge) then
        local propertyData = self.m_tGameData.equip_forge
        --cclog2(propertyData,"propertyData ===")         
        local propertyId_table = {}
        for k,v in pairs(propertyData) do
            
            table.insert(propertyId_table,k)
        end
        --cclog2(propertyId_table,"propertyId_table===")
        for i=1,3 do   
            local propertyId = propertyId_table[i] 
           
            local equip_set_random = getConfig(game_config_field.equip_set_random)
            equip_set_random = json.decode(equip_set_random:getFormatBuffer())
            local sort = equip_set_random[propertyId].sort
            local enemy = equip_set_random[propertyId].enemy
            if enemy[1] == -1 then
                self.m_cur_property_table[i].cur_property_name:setString("(Địch)\n" .. PUBLIC_ABILITY_TABLE["ability_" .. sort].name)
            else
                self.m_cur_property_table[i].cur_property_name:setString(PUBLIC_ABILITY_TABLE["ability_" .. sort].name)
            end
            local propertyName = PUBLIC_ABILITY_TABLE["ability_" .. sort].attrName
            local forge_lv = self.m_tGameData.equip_forge_level.lv
            local forge_value = propertyData[tostring(propertyId)][propertyName] or 0
            -- forge_value = string.format("%.4f",tostring(forge_value))
            if enemy[1] == -1 then
                forge_value = forge_value * 0.1
                if sort > 5 and sort < 10 then
                    forge_value = string.format("%.2f",tostring(forge_value))
                    forge_value = forge_value .. "%"
                end
                self.m_cur_property_table[i].cur_property:setString("-" .. forge_value)
            else
                if sort > 5 and sort < 10 then
                    forge_value = string.format("%.2f",tostring(forge_value))
                    forge_value = forge_value .. "%"
                end
                self.m_cur_property_table[i].cur_property:setString("+" .. forge_value)
            end
            local color_id = equip_set_random[propertyId].quality
            if color_id == 1 then
                self.m_cur_property_table[i].cur_property_name:setColor(ccc3(0,255,0))
                self.m_cur_property_table[i].cur_property:setColor(ccc3(0,255,0))
        
            elseif color_id == 2 then
                self.m_cur_property_table[i].cur_property_name:setColor(ccc3(35,160,254)) 
                self.m_cur_property_table[i].cur_property:setColor(ccc3(35,160,254)) 
           
            elseif color_id == 3 then
                self.m_cur_property_table[i].cur_property_name:setColor(ccc3(150,100,255)) 
                self.m_cur_property_table[i].cur_property:setColor(ccc3(150,100,255))  
             
            elseif color_id ==4 then
                self.m_cur_property_table[i].cur_property_name:setColor(ccc3(251,168,0)) 
                self.m_cur_property_table[i].cur_property:setColor(ccc3(251,168,0))  
             
            end
        end
    else
        
    end
    -- body
end
--[[-- 
    刷新

]]
function  game_equip_forge_pop.refreshUi(self)
    self.cur_property_node:setVisible(true)
    self.temp_property_node:setVisible(false)
    self.m_arrow_sprite:setVisible(false)
    self:getProperty()
    self.m_have_smallStone = game_data:getUserStatusDataByKey("small_forge_stone")
    self.m_have_middleStone = game_data:getUserStatusDataByKey("middle_forge_stone")
    self.m_have_highStone = game_data:getUserStatusDataByKey("high_forge_stone")
    self.m_metal_total_label = game_data:getUserStatusDataByKey("metal") or 0
end

--[[--
    初始化
]]
function  game_equip_forge_pop.init(self,t_params)
  cclog("-----------------game_equip_forge_pop init-----------------");
     t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.sort = 0
    self.callback = t_params.callback or nil
    self.equip_set_cost = getConfig(game_config_field.equip_set_cost)
end

--[[--
    创建ui入口并初始化数据
]]
function  game_equip_forge_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi() 
    self:refreshUi()
    return self.m_popUi;
end

return  game_equip_forge_pop;