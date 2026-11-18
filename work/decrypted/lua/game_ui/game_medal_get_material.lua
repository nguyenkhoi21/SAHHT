-- 勋章材料合成  new

local game_medal_get_material = {
    m_popUi = nil,

    gameData = nil,
    master_material_id = nil,

    gameData = nil,
    material_type = nil,
    material_id = nil,
    medal_node = nil,
    name_label = nil,
    node_intro_msg = nil,
    medal_icon1 = nil,
    medal_icon2 = nil,
    medal_icon3 = nil,
    mateial_node = nil,
    count_label = nil,
    first_name_label = nil,
    back_groove = nil,
    m_animFlag = nil,
};
--[[--
    销毁ui
]]
function game_medal_get_material.destroy(self)
    -- body
    cclog("-----------------game_medal_get_material destroy-----------------");
    self.m_popUi = nil;

    self.gameData = nil;
    self.master_material_id = nil;

    self.gameData = nil;
    self.material_type = nil;
    self.material_id = nil;
    self.medal_node = nil;
    self.name_label = nil;
    self.node_intro_msg = nil;
    self.medal_icon1 = nil;
    self.medal_icon2 = nil;
    self.medal_icon3 = nil;
    self.mateial_node = nil;
    self.count_label = nil;
    self.first_name_label = nil;
    self.back_groove = nil;
    self.m_animFlag = nil;
end

--[[--
    返回
]]
function game_medal_get_material.back(self,type)
    local function responseMethod(tag,gameData)
        -- game_scene:enterGameUi("game_medal_fusion",{gameData = gameData,selectId = tostring(self.material_type)});
        game_scene:enterGameUi("game_medal_charts",{gameData = gameData});
        self:destroy()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_index"), http_request_method.GET, nil,"medal_index")
end
--[[--
    读取ccbi创建ui
]]
function game_medal_get_material.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 102 then--合成
            --分合成勋章和材料
            if self.material_id ~= nil then
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    self.gameData = json.decode(data:getFormatBuffer()) or {};
                    local reward = data:getNodeWithKey("reward")
                    game_util:rewardTipsByJsonData(reward);
                    self.m_animFlag = false
                    self:refreshUi()
                end
                local params = {}
                params.material_id = self.material_id
                params.num = 1
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_synthesis_material"), http_request_method.GET, params,"medal_synthesis_material")
            else--合成勋章
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    self.gameData = json.decode(data:getFormatBuffer()) or {};
                    local reward = data:getNodeWithKey("reward")
                    game_util:rewardTipsByJsonData(reward);
                    -- game_util:addMoveTips({text = "开始合成！"})
                    -- self.m_animFlag = false
                    self:refreshUi()
                end
                local params = {}
                params.medal_id = self.material_type
                params.num = 1
                params.sort = 1
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_synthesis_medal"), http_request_method.GET, params,"medal_synthesis_medal")
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_medal_get.ccbi");
    
    self.medal_node = ccbNode:nodeForName("medal_node")
    self.name_label = ccbNode:labelTTFForName("name_label")
    self.node_intro_msg_board = ccbNode:nodeForName("node_intro_msg_board")
    -- self.medal_icon1 = ccbNode:spriteForName("medal_icon1")
    -- self.medal_icon2 = ccbNode:spriteForName("medal_icon2")
    -- self.medal_icon3 = ccbNode:spriteForName("medal_icon3")
    self.medal_icon1 = ccbNode:nodeForName("medal_node1")
    self.medal_icon2 = ccbNode:nodeForName("medal_node2")
    self.medal_icon3 = ccbNode:nodeForName("medal_node3")
    self.mateial_node = ccbNode:nodeForName("mateial_node")
    self.count_label = ccbNode:labelTTFForName("count_label")
    self.first_name_label = ccbNode:labelTTFForName("first_name_label")
    self.back_groove = ccbNode:scale9SpriteForName("back_groove")

    return ccbNode;
end

--[[--
    刷新ui
]]
function game_medal_get_material.refreshUi(self)
    self:createMedalInfo()
    self:createMaterialInfo()

    --每个勋章的状态
    self.first_name_label:setString("")
    local first_receive_uids = self.gameData.first_receive_uids
    local player = first_receive_uids[tostring(self.material_type)]
    local user_name = ""
    if player and player.user_name then
        user_name = player.user_name
    end
    self.first_name_label:setString(user_name)
end
--[[
    材料信息
]]
function game_medal_get_material.createMaterialInfo(self)
    local iconPos = {
        {0.5},
        {0.318,0.682},
        {0.136,0.5,0.864},
        {0.136,0.378,0.62,0.864},
        {0.06,0.28,0.5,0.72,0.94}
    }
    local lineHeight = 0.45
    local tempSize = self.mateial_node:getContentSize()
    local medalCfg = getConfig(game_config_field.medal);
    local materialCfg = getConfig(game_config_field.material);

    -- local masterMaterialCfg = materialCfg:getNodeWithKey(tostring(self.material_id))
    local masterMaterialCfg = nil
    if self.material_id == nil then--取勋章的
        masterMaterialCfg = medalCfg:getNodeWithKey(tostring(self.material_type))
    else--取材料的
        masterMaterialCfg = materialCfg:getNodeWithKey(tostring(self.material_id))
    end

    local material_material = masterMaterialCfg:getNodeWithKey("material")
    local totalCount = math.min(material_material:getNodeCount(),5)

    local function onBtnCilckMain( event,target )--看主的
        if self.material_id ~= nil then--只看材料
            game_scene:addPop("game_medal_material_detail",{gameData = self.gameData,material_id = self.material_id,openType = 2})
        end
    end

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag", btnTag)

        local material_index = btnTag - 10

        local item_material = material_material:getNodeAt(material_index-1):toInt()
        if self.material_id == nil then
            local pX,pY = target:getParent():getPosition()
            -- print(pX,pY)
            self.tempIcon = {id = item_material,pos = ccp(pX,pY)}
            self.material_id = item_material
            self.m_animFlag = true
            self:refreshUi()
        else
            local itemMaterialCfg = materialCfg:getNodeWithKey(tostring(item_material))
            local tempMaterial = itemMaterialCfg:getNodeWithKey("material")
            if tempMaterial:getNodeCount() == 0 then--显示详情
                game_scene:addPop("game_medal_material_detail",{gameData = self.gameData,material_id = item_material,material_type = self.material_type})
            else--再次跳转
                self.master_material_id = self.material_id
                local pX,pY = target:getParent():getPosition()
                self.tempIcon = {id = item_material,pos = ccp(pX,pY)}
                self.material_id = item_material
                self.m_animFlag = true
                self:refreshUi()
            end
        end
    end

    local function setUI()
        self.mateial_node:removeAllChildrenWithCleanup(true)
        local drawNode = ExtDrawNode:create(tempSize,0);
        drawNode:setPosition(ccp(0,0));
        self.mateial_node:addChild(drawNode);
        --材料
        local masterMaterialIcon,name = game_util:createMedalIcon(masterMaterialCfg)
        
        if masterMaterialIcon then
            masterMaterialIcon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.8))
            masterMaterialIcon:setScale(0.8)
            self.mateial_node:addChild(masterMaterialIcon,10,10)
            --加名字
            local master_name_label = game_util:createLabelTTF({text = name,color = ccc3(255,255,0)})
            master_name_label:setPosition(ccp(tempSize.width*0.5,tempSize.height*1.08))
            self.mateial_node:addChild(master_name_label,11,11)

            self:createTouchButton(onBtnCilckMain,masterMaterialIcon,1)
        end

        local have_count = 0
        for i=1,totalCount do
            local item_material = material_material:getNodeAt(i-1):toInt()
            local itemMaterialCfg = materialCfg:getNodeWithKey(tostring(item_material))
            local itemMaterialIcon = game_util:createMedalIcon(itemMaterialCfg)
            if itemMaterialIcon then
                local width_px = iconPos[totalCount][i]
                itemMaterialIcon:setPosition(ccp(tempSize.width*width_px,tempSize.height*0.14))
                itemMaterialIcon:setScale(0.8)
                self.mateial_node:addChild(itemMaterialIcon,10,10 + i)
                self:createTouchButton(onBtnCilck,itemMaterialIcon,10 + i)

                local have_flag = true
                --加数量
                local count = 0
                --判断数量
                local material = self.gameData.material
                if material[tostring(item_material)] then--有则是有
                    have_count = have_count + 1
                    count = material[tostring(item_material)]
                else
                    itemMaterialIcon:setColor(ccc3(81,81,81))
                    have_flag = false
                    
                    --没有的去判断下时候子节点可以合成
                    local tempMaterial = itemMaterialCfg:getNodeWithKey("material")
                    if tempMaterial:getNodeCount() > 0 then--判断是否都有
                        local child_count = 0
                        for n=1,tempMaterial:getNodeCount() do
                            local childMaterialId = tempMaterial:getNodeAt(n-1):toInt()
                            local child_num = 0
                            if material[tostring(childMaterialId)] then
                                child_num = material[tostring(childMaterialId)]
                            end
                            if child_num > 0 then
                                child_count = child_count + 1
                            end
                        end
                        if child_count == tempMaterial:getNodeCount() then
                            -- local tip_label = game_util:createLabelTTF({text = "可合成",color = ccc3(0,255,0)})
                            -- tip_label:setPosition(ccp(23,-10))
                            -- itemMaterialIcon:addChild(tip_label,10)
                            --改成发光特效
                            local light = CCSprite:createWithSpriteFrameName("medal_light.png");
                            light:setScale(1.4)
                            light:setPosition(ccp(itemMaterialIcon:getContentSize().width*0.5,itemMaterialIcon:getContentSize().height*0.5))
                            light:runAction(game_util:createRepeatForeverFade())
                            itemMaterialIcon:addChild(light,-1)
                        end
                    end
                    
                end
                local tip_label = game_util:createLabelTTF({text = count .. "/1",color = ccc3(0,255,0)})
                tip_label:setPosition(ccp(23,-10))
                itemMaterialIcon:addChild(tip_label,10)
                --画线
                self:drawLine(drawNode,ccp(tempSize.width*width_px,tempSize.height*0.14),ccp(tempSize.width*width_px,tempSize.height*lineHeight),have_flag);
                --横线
                --横线需要单独判断一下第一个满足，第二个不满足的情况
                if i == 2 then
                    local first_material = material_material:getNodeAt(0):toInt()
                    if material[tostring(first_material)] then--有则是有
                        have_flag = true
                    end
                end
                self:drawLine(drawNode,ccp(tempSize.width*width_px,tempSize.height*lineHeight),ccp(tempSize.width*0.5,tempSize.height*lineHeight),have_flag);
            end
        end
        local main_flag = true
        if have_count < totalCount then
            main_flag = false 
        end
        --最后画主线
        self:drawLine(drawNode,ccp(tempSize.width*0.5,tempSize.height*0.8),ccp(tempSize.width*0.5,tempSize.height*lineHeight),main_flag);
    end

    -- cclog2(self.tempIcon,"self.tempIcon")
    if self.tempIcon then--播个动画
        local itemMaterialCfg = materialCfg:getNodeWithKey(tostring(self.tempIcon.id))
        local itemMaterialIcon = game_util:createMedalIcon(itemMaterialCfg)
        itemMaterialIcon:setScale(0.8)
        itemMaterialIcon:setPosition(self.tempIcon.pos)
        self.mateial_node:addChild(itemMaterialIcon,100)
        -- itemMaterialIcon:runAction(CCMoveTo:create(0.2,ccp(tempSize.width*0.5,tempSize.height*0.8)))

        local animArr = CCArray:create();
        animArr:addObject(CCMoveTo:create(0.35,ccp(tempSize.width*0.5,tempSize.height*0.8)))
        animArr:addObject(CCCallFuncN:create(setUI));
        local sequence = CCSequence:create(animArr);
        itemMaterialIcon:runAction(sequence); 
    else
        setUI()
    end

    --动画
    local animArr = CCArray:create();
    if self.tempIcon ~= nil then
        animArr:addObject(CCDelayTime:create(0.35));
    end
    animArr:addObject(CCFadeIn:create(1));
    local sequence = CCSequence:create(animArr);
    self.mateial_node:runAction(sequence)
    self.tempIcon = nil
end
--[[
    画线
]]
function game_medal_get_material.drawLine(self,drawNode,startPos,endPos,flag)
    if flag then
        drawNode:drawLine(startPos, endPos, 2, ccc4f(255/255, 238/255, 0, 1));
    else
        drawNode:drawLine(startPos, endPos, 2, ccc4f(0.2,0.2,0.2,1));
    end
end
--[[--
    创建一个接受触摸事件的button
]]
function game_medal_get_material.createTouchButton( self, fun, parent, tag , anchorX, anchorY)
    if not parent then return end
    local button = game_util:createCCControlButton("public_weapon.png","",fun)
    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
    local tempSize = parent:getContentSize()
    button:setAnchorPoint(ccp(0.5,0.5))
    button:setPosition(ccp(tempSize.width * (anchorX or 0.5), tempSize.height* (anchorY or 0.5)))
    button:setOpacity(0)
    parent:addChild(button,1,tag)
    button:setTag(tag)
end
--[[
    勋章信息
]]
function game_medal_get_material.createMedalInfo(self)
    self.node_intro_msg_board:removeAllChildrenWithCleanup(true)
    local medalCfg = getConfig(game_config_field.medal);
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag", btnTag)

        if btnTag == 1 then--显示勋章
            self.material_id = nil
            self.master_material_id = nil
            self.m_animFlag = true
            self:refreshUi()
        elseif btnTag == 2 then--本界面刷新
            self.material_id = self.master_material_id
            self.master_material_id = nil
            self.m_animFlag = true
            self:refreshUi()
        end
    end
    if self.material_type then
        local itemCfg = medalCfg:getNodeWithKey(tostring(self.material_type))
        local name = itemCfg:getNodeWithKey("name"):toStr()
        local medalNameLabel = game_util:createLabelTTF({text = name,color = ccc3(254,212,11)})
        medalNameLabel:setPosition(ccp(10,60))
        medalNameLabel:setAnchorPoint(ccp(0.5,0.5))
        
        local medal = self.gameData["_medal"]
        self.name_label:setString(name)

        local count = 0
        if medal[tostring(self.material_type)] then
            count = medal[tostring(self.material_type)]
        end
        self.count_label:setString(count)

        --属性
        local tempSize = self.node_intro_msg_board:getContentSize()
        local effect = itemCfg:getNodeWithKey("effect")
        for i=1,3 do
            local itemEffect = effect:getNodeAt(i-1)
            local ability = itemEffect:getNodeAt(0):toInt()
            local value = itemEffect:getNodeAt(1):toInt()

            local abilityItem = PUBLIC_ABILITY_TABLE["ability_" .. ability]
            local abilityLabel = game_util:createLabelTTF({text = "· " .. abilityItem.name .. "+" .. value})
            if ability > 0 and ability < 6 then
                abilityLabel:setColor(ccc3(31,231,13))
            else
                abilityLabel:setColor(ccc3(245,0,10))
            end
            abilityLabel:setPosition(ccp(tempSize.width * 0.5,80 - i * 20))
            abilityLabel:setAnchorPoint(ccp(0.5,0.5))
            self.node_intro_msg_board:addChild(abilityLabel)
        end

        local iconSize = self.medal_icon1:getContentSize()
        self.medal_icon1:removeAllChildrenWithCleanup(true)
        self.medal_icon2:removeAllChildrenWithCleanup(true)
        self.medal_icon3:removeAllChildrenWithCleanup(true)
        --勋章
        -- local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr())
        local icon = game_util:createMedalIcon(itemCfg)
        icon:setPosition(ccp(iconSize.width*0.5, iconSize.height*0.5))
        icon:setScale(0.6)
        
        self.medal_icon1:addChild(icon,10,10)

        self.medal_node:removeAllChildrenWithCleanup(true)
        local medalIcon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr())
        -- local medalIcon = game_util:createMedalIcon(itemCfg)
        medalIcon:setScale(1.1)
        self.medal_node:removeAllChildrenWithCleanup(true)
        self.medal_node:addChild(medalIcon,10,10)
        --材料
        local materialCfg = getConfig(game_config_field.material);

        --修改，默认是勋章合成
        if self.material_id == nil then
            self.back_groove:setVisible(false)
            icon:setColor(ccc3(255,255,255))
        else
            icon:setColor(ccc3(81,81,81))
            self.back_groove:setVisible(true)
            local itemCfg2 = materialCfg:getNodeWithKey(tostring(self.material_id))
            local icon2 = game_util:createMedalIcon(itemCfg2)
            icon2:setScale(0.6)
            icon2:setPosition(ccp(iconSize.width*0.5, iconSize.height*0.5))

            if self.master_material_id == nil then
                self.back_groove:setPreferredSize(CCSizeMake(12,55));
                self.medal_icon2:addChild(icon2)
            else
                self.back_groove:setPreferredSize(CCSizeMake(12,110));

                local itemCfg3 = materialCfg:getNodeWithKey(tostring(self.master_material_id))
                local icon3 = game_util:createMedalIcon(itemCfg3)
                icon3:setScale(0.6)
                icon3:setPosition(ccp(iconSize.width*0.5, iconSize.height*0.5))

                self.medal_icon2:addChild(icon3)

                self.medal_icon3:addChild(icon2)

                icon3:setColor(ccc3(81,81,81))
            end
        end
        self:createTouchButton(onBtnCilck,self.medal_icon1,1)
        self:createTouchButton(onBtnCilck,self.medal_icon2,2)

        --[[
        local itemCfg2 = materialCfg:getNodeWithKey(tostring(self.material_id))
        -- local icon2 = game_util:createIconByName(itemCfg2:getNodeWithKey("icon"):toStr())
        local icon2 = game_util:createMedalIcon(itemCfg2)
        icon2:setScale(0.6)
        icon2:setPosition(ccp(iconSize.width*0.5, iconSize.height*0.5))
        
        --材料的材料
        if self.master_material_id == nil then
            self.medal_icon2:setVisible(false)
        else
            self.medal_icon2:setVisible(true)
            local itemCfg3 = materialCfg:getNodeWithKey(tostring(self.master_material_id))
            -- local icon3 = game_util:createIconByName(itemCfg3:getNodeWithKey("icon"):toStr())
            local icon3 = game_util:createMedalIcon(itemCfg3)
            icon3:setScale(0.6)
            icon3:setPosition(ccp(iconSize.width*0.5, iconSize.height*0.5))

            self.medal_icon2:addChild(icon3,10,10)
        end
        --材料始终放在第三个上
        self.medal_icon3:removeAllChildrenWithCleanup(true)
        self.medal_icon3:addChild(icon2,10,10)

        self:createTouchButton(onBtnCilck,self.medal_icon1,1)
        self:createTouchButton(onBtnCilck,self.medal_icon2,2)
        ]]
    end
end
--[[--
    初始化
]]
function game_medal_get_material.init(self,t_params)
    t_params = t_params or {};
    -- self.gameData = t_params.gameData
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    self.material_type = t_params.material_type or 1
    self.material_id = t_params.material_id or nil
    self.master_material_id = t_params.master_id or nil
    self.tempIcon = nil
    self.m_animFlag = false
end

--[[--
    创建ui入口并初始化数据
]]
function game_medal_get_material.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_medal_get_material;