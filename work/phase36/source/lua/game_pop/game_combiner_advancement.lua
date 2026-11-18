--召唤兽进阶
local game_combiner_advancement ={
    m_material_node_tab = nil,
    material_tab = nil,
    M_quality = nil,
    m_hero_name1 = nil,
    m_hero_name2 = nil,
    left_icon = nil,
    right_icon = nil,
    m_hero_lv1 = nil,
    m_hero_lv2 = nil,
    m_skill_lab = nil,
    m_tips_lab = nil,
    m_ab_num1 = nil,
    m_ab_num2 = nil,
}

--[[--
    销毁ui
]]
function game_combiner_advancement.destroy( self )
    -- body
    cclog("-----------------game_combiner_advancement destroy-----------------");
   self.m_material_node_tab = nil;
   self.material_tab = nil;
   self.M_quality = nil;
   self.m_hero_name1 = nil;
   self.m_hero_name2 = nil;
   self.left_icon = nil;
   self.right_icon = nil;
   self.m_hero_lv1 = nil;
   self.m_hero_lv2 = nil;
   self.m_skill_lab = nil;
   self.m_tips_lab = nil;
   self.m_ab_num1 = nil;
   self.m_ab_num2 = nil;
end

--[[--
    返回
]]
function game_combiner_advancement.back(self,type)
    
    game_scene:removePopByName("game_combiner_advancement");
    if self.btnCallFunc then
        self.btnCallFunc()
    end
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_combiner_advancement.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 2 then --进阶
            local function responseMethod( tag,gameData )
                local data = gameData:getNodeWithKey("data")
                local dataTable = json.decode(data:getFormatBuffer()) or {}
                game_data:setOneCombinerData(dataTable.beast_info,self.MyselNum)
                self:refreshUi()
                self:back();
            end
            local params = {}
            params.beast = self.MyselNum
            
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("combiner_up_beast_quality"), http_request_method.GET, params,"combiner_up_beast_quality")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_Monster_Summoning_jinjie.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_material_node = ccbNode:nodeForName("m_material_node")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_hero_name1 = ccbNode:labelTTFForName("m_hero_name1")
    self.m_hero_name2 = ccbNode:labelTTFForName("m_hero_name2")
    self.left_icon = ccbNode:spriteForName("left_icon")
    self.right_icon = ccbNode:spriteForName("right_icon")
    self.m_hero_lv1 = ccbNode:spriteForName("m_hero_lv1")
    self.m_hero_lv2 = ccbNode:spriteForName("m_hero_lv2")
    self.m_skill_lab = ccbNode:labelTTFForName("m_skill_lab")
    self.m_tips_lab = ccbNode:labelTTFForName("m_tips_lab")
    self.m_abillty_lab1 = ccbNode:labelTTFForName("m_abillty_lab1")
    self.m_abillty_lab2 = ccbNode:labelTTFForName("m_abillty_lab2")
    self.m_ab_num1 = ccbNode:labelTTFForName("m_ab_num1")
    self.m_ab_num2 = ccbNode:labelTTFForName("m_ab_num2")
    local m_material_node = nil;
    for i=1,5 do
        m_material_node = ccbNode:spriteForName("m_material_node_" .. i);
        self.m_material_node_tab[i] = {m_material_node = m_material_node}
    end
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-11,true);
    self.m_root_layer:setTouchEnabled(true);
    self.left_icon:setVisible(false)
    self.right_icon:setVisible(false)

    return ccbNode;
end

function game_combiner_advancement.createInformation(self )
    local NumTab = {"Monster_Summoning_1.png","Monster_Summoning_2.png","Monster_Summoning_3.png"}
    local combiner_quality = self.m_GameData.quality
    if combiner_quality then
        local Com_cfg = getConfig(game_config_field.combiner_advanced):getNodeWithKey(combiner_quality);
        local combiner_info = Com_cfg and json.decode(Com_cfg:getFormatBuffer()) or {}
        local Mquality = combiner_info.quality or 1;
        local Mname = combiner_info.name or "";
        local Mdes = combiner_info.des or "";
        local Mtips = combiner_info.des1 or "";
        local nature = combiner_info.nature or {};
        if nature[1] then
            local abilityTab = tonumber(nature[1][1]) > 0 and PUBLIC_ABILITY_TABLE[tostring("ability_" .. nature[1][1])];
            self.m_abillty_lab1:setString(abilityTab.name)
            self.m_ab_num1:setString("+"..nature[1][2])
        end
        if nature[2] then
            local abilityTab = tonumber(nature[2][1]) > 0 and PUBLIC_ABILITY_TABLE[tostring("ability_" .. nature[2][1])];
            self.m_abillty_lab2:setString(abilityTab.name)
            self.m_ab_num2:setString("+"..nature[2][2])
        end
        self.m_skill_lab:setString(Mdes);
        self.m_tips_lab:setString(Mtips);
        local qualityTab = tonumber(Mquality) > 0 and HERO_QUALITY_COLOR_TABLE_3[tonumber(Mquality) +1]
        self.m_hero_name1:setString(Mname)
        self.m_hero_name1:setColor(qualityTab.color);
        if tonumber(combiner_quality)%100 < 5 then
            local qualityTab2 = tonumber(Mquality) > 0 and HERO_QUALITY_COLOR_TABLE_3[tonumber(Mquality) +2]
            self.m_hero_name2:setString(Mname)
            self.m_hero_name2:setColor(qualityTab2.color);
        elseif tonumber(combiner_quality)%100 < 7 then
            local qualityTab2 = tonumber(Mquality) > 0 and HERO_QUALITY_COLOR_TABLE_3[6]
            self.m_hero_name2:setString(Mname)
            self.m_hero_name2:setColor(qualityTab2.color);
            self.m_hero_lv1:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(NumTab[tonumber(Mquality)-4]));
            self.m_hero_lv2:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(NumTab[tonumber(Mquality)-3]));
            self.left_icon:setVisible(true)
            self.right_icon:setVisible(true)
        else
            self.m_hero_name2:setString("");
            self.right_icon:setVisible(false)
            self.m_status = 2;
        end
    end

    
end


function game_combiner_advancement:createMaterialIcon()
    local material_node_size = self.m_material_node:getContentSize();
        for i=1,#self.m_material_node_tab do
            local itemTab = self.m_material_node_tab[i]
            itemTab.m_material_node:removeAllChildrenWithCleanup(true);
            itemTab.m_material_node:setVisible(true)
            local itemId = tostring(self.material_tab[i])
            local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(itemId);
            local itemName = itemConfig:getNodeWithKey("name"):toStr() or "" --材料卡名字
            local tempIcon = game_util:createCombinerCardIconByCid(itemId,false)
            if tempIcon then
                local tempSize = itemTab.m_material_node:getContentSize();
                tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                itemTab.m_material_node:addChild(tempIcon)
                local super_quality_1 = self.M_quality[i] or 0;
                local qualityTab = super_quality_1 > 0 and HERO_QUALITY_COLOR_TABLE_3[super_quality_1 +1]
                if qualityTab then
                    local tempIconSize = tempIcon:getContentSize();
                    local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
                    img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
                    tempIcon:addChild(img1,-1,-1)
                end
            else
               
            end
        end
end


function game_combiner_advancement:refreshUi( )
    self.M_quality = {}
    self.material_tab = {};
    local myData = game_data:getCombinerData();
    self.m_GameData = myData[tostring(self.MyselNum)]
    if self.m_GameData.beast_gods then
        local beast_gods = self.m_GameData.beast_gods
        for k,v in pairs(beast_gods) do
            table.insert(self.material_tab,k)
            table.insert(self.M_quality,v.quality) --神兽品阶
        end
    end
    self:createMaterialIcon();
    self:createInformation();
end



--[[--
    初始化
]]
function game_combiner_advancement.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    self.m_material_node_tab = {};
    self.M_quality = {}
    self.material_tab = {};
    self.MyselNum = t_params.selNum;
    self.m_GameData = {};
    self.btnCallFunc = t_params.btnCallFunc;
    
end

--[[--
    创建ui入口并初始化数据
]]
function game_combiner_advancement.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_combiner_advancement;

