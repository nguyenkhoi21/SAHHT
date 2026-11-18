--召唤兽升级
local game_combiner_heroup ={
    m_close_btn = nil,
	m_root_layer = nil,
    material_cid = nil,
    num_id = nil,
    quality = nil,
    m_GameData = nil,
    quality_config = nil,
    add_ability_type = nil,
    m_material_id_table = nil,
    m_materialCount = nil,
    m_status = nil,
    MyMaterial_tab = nil,
}

--[[--
    销毁ui
]]
function game_combiner_heroup.destroy( self )
	-- body
	cclog("-----------------game_combiner_heroup destroy-----------------");
   self.m_root_layer = nil;
   self.m_close_btn = nil;
   self.material_cid = nil; 
   self.num_id = nil; --神兽阶段id
   self.quality = nil; --神兽品质
   self.m_GameData = nil;
   self.quality_config = nil;
   self.add_ability_type = nil;--材料卡进阶加成种类
   self.m_material_id_table = nil;
   self.m_materialCount = nil; --本卡材料数量
   self.m_status = nil;
   self.MyMaterial_tab = nil;
end

--[[--
    返回
]]
function game_combiner_heroup.back(self,type)
    game_scene:removePopByName("game_combiner_heroup");
    if self.btnCallFunc then
        self.btnCallFunc()
    end
    -- self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_combiner_heroup.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 2 then --进阶
            local combiner_evo_Config = getConfig(game_config_field.combiner_evo)
            local combiner_evo_tab = combiner_evo_Config and json.decode( combiner_evo_Config:getFormatBuffer() ) or {}
            local evo_tab = combiner_evo_tab[tostring(self.num_id)];
            local Needlevel = evo_tab.level or 0;
            local Mylevel = self.m_GameData.level or 0;
            if Mylevel >= Needlevel then
                if self.m_status == 3 then
                    game_util:addMoveTips({text = "Thiếu nguyên liệu tiêu hao"});
                elseif self.m_status == 2 then
                    game_util:addMoveTips({text = "Lv thần thú đã đạt max!"});
                else
                    local function responseMethod(tag,gameData)
                        local data = gameData:getNodeWithKey("data")
                        local reward = data:getNodeWithKey("rewards")
                        local dataTable = json.decode(data:getFormatBuffer()) or {}
                        game_util:rewardTipsByJsonData(reward);
                        self.num_id = self.num_id + 1; --本界面材料卡品级数据+1
                        -- local myCombinerDate = game_data:getCombinerData();
                        -- local MyData = myCombinerDate[tostring(self.MyselNum)]
                        game_data:setOneCombinerData(dataTable.beast_info,self.MyselNum)
                        -- local beast_gods = MyData.beast_gods
                        -- beast_gods[tostring(self.material_cid)].quality_config = beast_gods[tostring(self.material_cid)].quality_config + 1; --全局材料卡品级数据+1
                        -- game_data:setCombinerData(myCombinerDate);
                        self:responseSuccess()
                        self:refreshUi();
                    end
                    local params = {};
                    for k,v in pairs (self.MyMaterial_tab or {}) do
                        if params.materials == nil then
                            params.materials =  v .. "_" 
                        else
                            params.materials = params.materials .. v .. (k == #self.MyMaterial_tab and "" or "_") ;
                        end

                    end
                    params.beast_god = self.material_cid
                    params.beast = self.MyselNum
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("combiner_up_beast_god"), http_request_method.GET, params,"combiner_up_beast_god")
                
                end
            else
                game_util:addMoveTips({text = "Lv thần thú không đủ!"});
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_Monster_Summoning_pinzhi.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_material_node = ccbNode:layerForName("m_material_node")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.hero_icon = ccbNode:spriteForName("m_hero_node")
    self.name_lab = ccbNode:labelBMFontForName("m_num_label_1")
    self.m_pinzhi_lab1 = ccbNode:labelTTFForName("m_pinzhi_lab1")
    self.m_pinzhi_lab2 = ccbNode:labelTTFForName("m_pinzhi_lab2")
    self.m_dengji_lab = ccbNode:labelTTFForName("m_dengji_lab")
    self.m_shuxing_lab1 = ccbNode:labelTTFForName("m_shuxing_lab1")
    self.m_shuxing_lab2 = ccbNode:labelTTFForName("m_shuxing_lab2")
    self.m_jinjie_btn = ccbNode:controlButtonForName("m_jinjie_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_jinjie_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    local m_material_node,m_mate_tips,m_mate_cost_label,m_mate_total_label,parentNode = nil;
    for i=1,4 do
        m_material_node = ccbNode:spriteForName("m_material_node_" .. i);
        m_mate_tips = ccbNode:spriteForName("m_mate_tips_" .. i);
        m_mate_cost_label = ccbNode:labelTTFForName("m_mate_cost_label_" .. i)
        m_mate_total_label = ccbNode:labelTTFForName("m_mate_total_label_" .. i)
        parentNode = m_material_node:getParent();
        self.m_material_node_tab[i] = {m_material_node = m_material_node,m_mate_tips = m_mate_tips,m_mate_cost_label = m_mate_cost_label,m_mate_total_label = m_mate_total_label,parentNode = parentNode}
    end
    self:initMaterialLayerTouch(self.m_material_node);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-11,true);
    self.m_root_layer:setTouchEnabled(true);
    

    return ccbNode;
end

--初始化信息
function game_combiner_heroup.createDetail( self )
    -- body
    local itemId = self.material_cid;
    local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(itemId);
    local tempIcon = game_util:createCombinerCardIconByCid(itemId,false)
    local itemName = itemConfig:getNodeWithKey("name"):toStr() or "" --材料卡名字
    self.name_lab:setString(itemName);
    local combiner_evo_Config = getConfig(game_config_field.combiner_evo)
    local combiner_evo_tab = combiner_evo_Config and json.decode( combiner_evo_Config:getFormatBuffer() ) or {}
    local evo_tab = combiner_evo_tab[tostring(self.num_id)];
    self.m_pinzhi_lab1:setString(evo_tab.des);

    if tempIcon then
        local tempSize = self.hero_icon:getContentSize();
        tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
        self.hero_icon:addChild(tempIcon)
        local qualityTab = tonumber(evo_tab.quality) > 0 and HERO_QUALITY_COLOR_TABLE_3[tonumber(evo_tab.quality) +1]
        if qualityTab then
            local tempIconSize = tempIcon:getContentSize();
            local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
            img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
            tempIcon:addChild(img1,-1,-1)
        end
    else  
    end
    local ability_Num2 = 0;
    local qualityTab = tonumber(evo_tab.quality) > 0 and HERO_QUALITY_COLOR_TABLE_3[tonumber(evo_tab.quality) +1]
    if combiner_evo_tab[tostring(self.num_id+1)] then
        local evo_tab2 = combiner_evo_tab[tostring(self.num_id+1)];
        ability_Num2 = evo_tab2.nature or 0;
        local qualityTab2 = tonumber(evo_tab2.quality) > 0 and HERO_QUALITY_COLOR_TABLE_3[tonumber(evo_tab2.quality) +1]
        self.m_pinzhi_lab2:setString(evo_tab2.des)
        self.m_pinzhi_lab2:setColor(qualityTab2.color);
    else 
        self.m_pinzhi_lab1:setString("Đã đạt max");
        self.m_pinzhi_lab2:setString("");
        self.m_status = 2;
    end
    self.m_pinzhi_lab1:setColor(qualityTab.color);
    local Needlevel = evo_tab.level or 0;
    local Mylevel = self.m_GameData.level or 0;
    self.m_dengji_lab:setString(Needlevel .. "/" .. Mylevel);

    local beast_gods = self.m_GameData.beast_gods
    self.quality_config = beast_gods[tostring(self.material_cid)].quality_config --材料卡品质阶段
    self.add_ability_type = beast_gods[tostring(self.material_cid)].add_ability_type --材料卡进阶加成种类
    local abilityTab = tonumber(self.add_ability_type) > 0 and PUBLIC_ABILITY_TABLE[tostring("ability_" .. self.add_ability_type)];
    local ability_Num = evo_tab.nature or 0;
    self.m_shuxing_lab1:setString(abilityTab.name .. "+" .. ability_Num);
    self.m_shuxing_lab2:setString(abilityTab.name .. "+" .. ability_Num2);

end

function game_combiner_heroup.createMaterial( self )
    -- body
    self.m_materialDataTable = {};
    local combiner_evo_Config = getConfig(game_config_field.combiner_evo)
    local combiner_evo_tab = combiner_evo_Config and json.decode( combiner_evo_Config:getFormatBuffer() ) or {}
    -- cclog2(combiner_evo_tab,"combiner_evo_tabcombiner_evo_tab")
    local evo_tab = combiner_evo_tab[tostring(self.num_id)];
    local material = evo_tab.advanced_item;
    self.m_materialCount = evo_tab.advanced --本卡材料数量
    if tonumber(self.m_materialCount) >0 then
        local materialItem = {5,tonumber(self.material_cid),tonumber(self.m_materialCount)}
        table.insert(material,1,materialItem);
    end
    local tempCount = #material or 0;
    self.material_Count = tempCount;
    if material then
        local material_node_size = self.m_material_node:getContentSize();
        local itemWidth = material_node_size.width/4
        local startX = material_node_size.width*0.5 - itemWidth*0.5*(tempCount - 1)

        local material_node_item,m_material_node,m_mate_tips,m_mate_cost_label,m_mate_total_label
        local equip_material_item_cfg = nil,nil
        local materialId,materialType = nil,nil
        for i=1,4 do
            material_node_item = self.m_material_node_tab[i];
            material_node_item.parentNode:setPositionX(startX + itemWidth*(i - 1))
            m_material_node = material_node_item.m_material_node
            m_mate_tips = material_node_item.m_mate_tips
            m_mate_cost_label = material_node_item.m_mate_cost_label
            m_mate_total_label = material_node_item.m_mate_total_label
            m_material_node:removeAllChildrenWithCleanup(true);
            local material_item = material[i]
            if material_item then
                m_mate_tips:setVisible(false);
                m_mate_cost_label:getParent():setVisible(true);
                materialType = tonumber(material_item[1])
                materialId = tonumber(material_item[2])
                local costCount = tonumber(material_item[3])
                local count = 0;
                local icon = nil;
                if materialType == 6 then
                    count = game_data:getItemCountByCid(materialId);
                    icon = game_util:createItemIconByCid(materialId);
                elseif materialType == 5 then
                    local tempTab = game_data:getCardsDataByCombinerTemple(materialId);
                    count = #tempTab
                    icon = game_util:createCardIconByCid(materialId);
                end
                if costCount > count then
                    self.m_status = 3;
                    m_mate_cost_label:setColor(ccc3(255, 0, 0))
                else
                    m_mate_cost_label:setColor(ccc3(255, 255, 255));
                end
                m_mate_cost_label:setString(costCount);
                m_mate_total_label:setString(count);
                self.m_materialDataTable[i] = {count = count,materialId = materialId,materialType = materialType};
                if icon then
                    local tempSize = m_material_node:getContentSize();
                    icon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                    m_material_node:addChild(icon,10,10);
                    if costCount > count then
                        icon:setColor(ccc3(151,151,151));                        
                    end
                end
            else
                -- m_mate_tips:setVisible(true);
                -- m_mate_cost_label:setString("0");
                -- m_mate_total_label:setString("0");
                -- m_mate_cost_label:setColor(ccc3(255, 255, 255));
                m_mate_cost_label:getParent():setVisible(false);
            end
        end
    else

    end
end

function game_combiner_heroup.selectOwnMaterial( self )
    -- body
    local combiner_evo_Config = getConfig(game_config_field.combiner_evo)
    local combiner_evo_tab = combiner_evo_Config and json.decode( combiner_evo_Config:getFormatBuffer() ) or {}
    -- cclog2(combiner_evo_tab,"combiner_evo_tabcombiner_evo_tab")
    local evo_tab = combiner_evo_tab[tostring(self.num_id)];
    local material = evo_tab.advanced_item;
    self.m_materialCount = evo_tab.advanced --本卡材料数量

    if self.m_materialCount >0 then
        local cardtab = {};
        self.MyMaterial_tab = {};
        cardtab = game_data:getCardsDataByCombinerTemple(self.material_cid);
        local cardnum = #cardtab
        game_data:cardsSortByTypeNameWithTable("lv",cardtab);
        self.MymaterialCount = tonumber(#cardtab) or 0  --实际拥有卡牌的数量
        for i=1,self.m_materialCount do
            table.insert(self.MyMaterial_tab,cardtab[cardnum - self.m_materialCount + i]);
        end
        -- if cardtab[count] and self.m_materialCount == 1 then
        --     table.insert(self.MyMaterial_tab,cardtab[count]);
        -- elseif self.m_materialCount == 2 then
        --     table.insert(self.MyMaterial_tab,cardtab[count]);
        --     table.insert(self.MyMaterial_tab,cardtab[count-1]);
        -- end
    end
   
end

--[[--
    
]]
function game_combiner_heroup.responseSuccess(self)
    local function responseEndFunc()
        self.m_root_layer:setTouchEnabled(false);
        game_sound:playUiSound("up_success")
        self:refreshUi();
        self.m_material_node:addChild(game_util:animSuccessCCBAnim(nil,"lv_up"));
        
    end
    
    local rempveIndex = self.material_Count
    local materialCount = rempveIndex;
    local animFile = "anim_icon_disappear"
    local function particleMoveEndCallFunc()
        -- cclog("tempParticle particleMoveEndCallFunc --------------------------")
    end
    for i=1,4 do
        local m_material_node = self.m_material_node_tab[i].m_material_node;
        if i <= materialCount then 
            local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
            if mAnimNode then
                local function onAnimSectionEnd(animNode, theId,theLabelName)
                    if theLabelName == "impact1" then
                        animNode:playSection("impact2");
                        local tempNode = m_material_node:getChildByTag(10)
                        if tempNode then
                            tempNode:setVisible(false);
                        end
                    else
                        mAnimNode:removeFromParentAndCleanup(true);
                        rempveIndex = rempveIndex - 1;
                        if rempveIndex == 0 then
                            responseEndFunc();
                            -- self.m_ccbNode:runAnimations("success_anim")
                        end
                    end
                end
                mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
                mAnimNode:playSection("impact1");
                local tempSize = m_material_node:getContentSize();
                mAnimNode:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                m_material_node:addChild(mAnimNode,100,100);
                local tempParticle = game_util:createParticleSystemQuad({fileName = "particle_fly_up"});
                if tempParticle then
                    game_util:addMoveAndRemoveAction({node = tempParticle,startNode = m_material_node,endNode = self.hero_icon,endCallFunc = particleMoveEndCallFunc,moveTime = 0.5,delayTime = 0.5})
                    game_scene:getPopContainer():addChild(tempParticle)
                end
            else
                rempveIndex = rempveIndex - 1;
                if rempveIndex == 0 then
                    responseEndFunc();
                    -- self.m_ccbNode:runAnimations("success_anim")
                end
            end
        else
            
        end
    end
end

function game_combiner_heroup.refreshUi( self )
    local myCombinerDate = game_data:getCombinerData();
    local MyData = myCombinerDate[tostring(self.MyselNum)]
    self.m_GameData = MyData;
    self:createDetail();
    self:selectOwnMaterial();
    self:createMaterial();
    
end

--[[--
    材料层
]]
function game_combiner_heroup.initMaterialLayerTouch(self,formation_layer)
    local tempItem = nil;
    local realPos = nil;
    local tag = nil;
    local function onTouchBegan(x, y)
        -- CCTOUCHBEGAN event must return true
        return true
    end
    
    local function onTouchMoved(x, y)
    end
    
    local function onTouchEnded(x, y)
        -- cclog("m_material_node click ==== ")
        realPos = self.m_material_node:convertToNodeSpace(ccp(x,y));
        for k,v in pairs(self.m_material_node_tab) do
            if v.parentNode:isVisible() and v.parentNode:boundingBox():containsPoint(realPos) then
                -- cclog("m_material_node click ==== " .. k)
                local tempData = self.m_materialDataTable[k];
                if self.material_cid and tempData then
                    if tempData.materialType == 6 then
                        game_scene:addPop("game_item_info_pop",{itemId = tempData.materialId,openType = 3})
                    elseif tempData.materialType == 5 then
                        game_scene:addPop("game_hero_info_pop",{cId = tostring(tempData.materialId),openType = 4})
                    end
                end
                break;
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 22)
    formation_layer:setTouchEnabled(true)
end


--[[--
    初始化
]]
function game_combiner_heroup.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    self.num_id = t_params.num_id or 1; 
    self.material_cid = t_params.material_cid or 1;
    self.quality = t_params.quality or 1;
    self.m_material_node_tab = {};
    self.MyselNum = t_params.MyselNum or 0;
    self.m_status = 0;
    self.MyMaterial_tab = {};
    self.m_GameData = {};
    self.btnCallFunc = t_params.btnCallFunc
    self.material_Count = 0 ; --材料总数
end

--[[--
    创建ui入口并初始化数据
]]
function game_combiner_heroup.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_combiner_heroup;

