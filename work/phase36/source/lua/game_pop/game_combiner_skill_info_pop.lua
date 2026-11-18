--- 信息

local game_combiner_skill_info_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    combiner_skill_cfg = nil,
    skill_story = nil,
    

};

--[[--
    销毁
]]
function game_combiner_skill_info_pop.destroy(self)
    -- body
    cclog("-----------------game_combiner_skill_info_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.combiner_skill_cfg = nil;
    self.skill_story = nil;
    
end
--[[--
    返回
]]
function game_combiner_skill_info_pop.back(self,type)
    game_scene:removePopByName("game_combiner_skill_info_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_combiner_skill_info_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " .. btnTag)
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_items_dialog.ccbi");
    ccbNode:controlButtonForName("btn_storeToHouse"):setVisible(false)
    local m_title_label = tolua.cast(ccbNode:objectForName("m_title_label"),"CCLabelTTF");
    local m_story_label = tolua.cast(ccbNode:objectForName("m_story_label"),"CCLabelTTF");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_info_btn = ccbNode:controlButtonForName("m_info_btn")
    local m_icon_spr = ccbNode:spriteForName("m_icon_spr")
    local m_title_name = ccbNode:spriteForName("m_title_name")
    m_info_btn:setVisible(false)
    m_title_name:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_pop_skill.png"));
    local icon = game_util:createItemIconByCfg(config_date)
    if self.combiner_skill_cfg then
        if self.combiner_skill_cfg["skill_icon"] then
            local iconName = self.combiner_skill_cfg["skill_icon"]
            local icon = CCSprite:create("icon/" .. iconName .. ".png");
            icon:setAnchorPoint(ccp(0.5,0.5))
            local size = m_icon_spr:getContentSize();
            icon:setPosition(ccp(size.width*0.5,size.height*0.5));
            m_icon_spr:addChild(icon,10)
        end
        if self.combiner_skill_cfg["skill_name"] then
            local skill_name = self.combiner_skill_cfg["skill_name"] or ""
            m_title_label:setString(skill_name);
        end
        if self.combiner_skill_cfg["skill_story"] and self.combiner_skill_cfg["effect"] then
            local skill_story = self.combiner_skill_cfg["skill_story"]
            local attr_effect = self.combiner_skill_cfg["effect"]
            attr_effect = string.format("%d",attr_effect)
            self.skill_story = string.gsub(skill_story,"effect",tostring(attr_effect));
            
        end

    end
    local boardSize = m_story_label:getDimensions()
    local tempNode = CCNode:create()
    tempNode:setContentSize(boardSize)
    m_story_label:getParent():addChild(tempNode)
    tempNode:setAnchorPoint(ccp(0.5,0.5))
    tempNode:setPosition(m_story_label:getPosition())
    local sc = game_util:createMulitLabel(tempNode, {text = tostring(self.skill_story) ,color = ccc3(225,225,225)}, true, GLOBAL_TOUCH_PRIORITY  - 100)

    local function onTouch( eventType,x,y )
        -- body
        if(eventType == "began")then
            if sc then
                local realPos = tempNode:getParent():convertToNodeSpace(ccp(x,y));
                if tempNode:boundingBox():containsPoint(realPos) then
                    return false
                end
            end
            -- cclog2("  0000000000000000000  ")
            self:back();
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);

    local touchLayer = CCLayer:create()
    m_root_layer:addChild(touchLayer)
    local function onTouch( eventType,x,y )
        if(eventType == "began")then
            return true;
        end
    end
    touchLayer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-9,true);
    touchLayer:setTouchEnabled(true);

    -- m_story_label:setString(itemStory);
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"),"CCControlButton");
    local m_left_btn = tolua.cast(ccbNode:objectForName("m_left_btn"),"CCControlButton");
    local m_right_btn = tolua.cast(ccbNode:objectForName("m_right_btn"),"CCControlButton");
    local m_batch_btn = ccbNode:controlButtonForName("m_batch_btn");
    
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    m_left_btn:setVisible(false)
    m_right_btn:setVisible(false)
    m_info_btn:setVisible(false)
    m_batch_btn:setVisible(false)
    m_batch_btn:setVisible(false)
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

function game_combiner_skill_info_pop.removePop(self)
    if self.m_popUi then
        self.m_popUi:removeFromParentAndCleanup(true);
        self.m_popUi = nil;
    end
end

--[[--
    刷新ui
]]
function game_combiner_skill_info_pop.refreshUi(self)

end

--[[--
    初始化
]]
function game_combiner_skill_info_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.combiner_skill_cfg = t_params.combiner_skill_cfg or nil;
    self.skill_story = "";
end

--[[--
    创建ui入口并初始化数据
]]
function game_combiner_skill_info_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_combiner_skill_info_pop;