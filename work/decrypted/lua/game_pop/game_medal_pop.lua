--- 勋章  信息

local game_medal_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,

    openType = nil,
    gameData = nil,
    material_type = nil,
    material_make_table = nil,
    m_title_label = nil,
    node_intro_msg_board = nil,
    m_have_label = nil,
    m_icon_spr = nil,
};

--[[--
    销毁
]]
function game_medal_pop.destroy(self)
    -- body
    cclog("-----------------game_medal_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;

    self.openType = nil;
    self.gameData = nil;
    self.material_type = nil;
    self.material_make_table = nil;
    self.m_title_label = nil;
    self.node_intro_msg_board = nil;
    self.m_have_label = nil;
    self.m_icon_spr = nil;
end
--[[--
    返回
]]
function game_medal_pop.back(self,type)
    game_scene:removePopByName("game_medal_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_medal_pop.createUi(self)
    local ccbNode = luaCCBNode:create();

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then--勋章合成
            local function responseMethod(tag,gameData)
                -- game_scene:enterGameUi("game_medal_fusion",{gameData = gameData,selectId = tostring(self.material_type)});
                --直接跳转到碎片合成
                game_scene:enterGameUi("game_medal_get_material",{gameData = gameData,material_type = tostring(self.material_type)});
                self:destroy()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_index"), http_request_method.GET, nil,"medal_index")
        elseif btnTag == 3 then--改为跳转到阵型
            -- self:back()
            game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_main_scene"});
            self:destroy();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_medal_pop.ccbi");
    self.m_title_label = tolua.cast(ccbNode:objectForName("m_title_label"),"CCLabelTTF");
    local m_story_label = tolua.cast(ccbNode:objectForName("m_story_label"),"CCLabelTTF");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    local function onTouch( eventType,x,y )
        if(eventType == "began")then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    
    
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"),"CCControlButton");
    local m_left_btn = tolua.cast(ccbNode:objectForName("m_left_btn"),"CCControlButton");
    local m_right_btn = tolua.cast(ccbNode:objectForName("m_right_btn"),"CCControlButton");

    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    m_left_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11);
    m_right_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    self.node_intro_msg_board = ccbNode:nodeForName("node_intro_msg_board")

    self.m_have_label = ccbNode:labelTTFForName("m_have_label")
    self.m_icon_spr = ccbNode:spriteForName("m_icon_spr")
    if self.openType == 2 then
        m_left_btn:setVisible(false)
        m_right_btn:setVisible(false)
    end
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_medal_pop.refreshUi(self)
    --勋章信息
    self.node_intro_msg_board:removeAllChildrenWithCleanup(true)
    local medalCfg = getConfig(game_config_field.medal);
    if self.material_type then
        local itemCfg = medalCfg:getNodeWithKey(tostring(self.material_type))
        local name = itemCfg:getNodeWithKey("name"):toStr()
        local medalNameLabel = game_util:createLabelTTF({text = name,color = ccc3(254,212,11)})
        medalNameLabel:setPosition(ccp(10,60))
        medalNameLabel:setAnchorPoint(ccp(0,0.5))
        self.node_intro_msg_board:addChild(medalNameLabel)

        --属性
        local effect = itemCfg:getNodeWithKey("effect")
        for i=1,3 do
            local itemEffect = effect:getNodeAt(i-1)
            local ability = itemEffect:getNodeAt(0):toInt()
            local value = itemEffect:getNodeAt(1):toInt()

            local abilityItem = PUBLIC_ABILITY_TABLE["ability_" .. ability]
            local abilityLabel = game_util:createLabelTTF({text = abilityItem.name .. "+" .. value})
            if ability > 0 and ability < 6 then
                abilityLabel:setColor(ccc3(31,231,13))
            else
                abilityLabel:setColor(ccc3(245,0,10))
            end
            abilityLabel:setPosition(ccp(70,80 - i * 20))
            abilityLabel:setAnchorPoint(ccp(0,0.5))
            self.node_intro_msg_board:addChild(abilityLabel)
        end

        --
        self.m_title_label:setString(name)
        local medal = self.gameData["_medal"]
        local count = 0
        if medal[tostring(self.material_type)] then
            count = medal[tostring(self.material_type)]
        end
        self.m_have_label:setString("Có:" .. count)

        local tempSize = self.m_icon_spr:getContentSize()
        -- local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr())
        local icon = game_util:createMedalIcon(itemCfg)
        icon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
        self.m_icon_spr:removeAllChildrenWithCleanup(true)
        self.m_icon_spr:addChild(icon,10,10)
    end
end

--[[--
    初始化
]]
function game_medal_pop.init(self,t_params)
    t_params = t_params or {};
    self.gameData = t_params.gameData

    self.material_type = t_params.material_type--根据id区分是哪个勋章的材料
    self.material_make_table = t_params.material_make_table or {}
    self.openType = t_params.openType or 1
end

--[[--
    创建ui入口并初始化数据
]]
function game_medal_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_medal_pop;