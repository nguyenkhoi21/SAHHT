--- 坠落之地
--- 科技弹版
local game_godfield_guild_high_war_keji_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
};

--[[--
    销毁
]]
function game_godfield_guild_high_war_keji_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_keji_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
end
--[[--
    返回
]]
function game_godfield_guild_high_war_keji_pop.back(self)
    game_scene:removePopByName("game_godfield_guild_high_war_keji_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_keji_pop.createUi(self)
    self.m_select_index = 1
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_keji_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    self.label_title = ccbNode:labelTTFForName("label_title") 
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    self.node_icon = ccbNode:nodeForName("node_icon")
    self.label_des = ccbNode:labelTTFForName("label_des")

    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_godfield_guild_high_war_keji_pop.refreshUi(self)

    local guild_high_war_science_cfg = getConfig(game_config_field.guild_high_war_science)
    local science_info = guild_high_war_science_cfg:getNodeWithKey(self.lv)
    self.label_title:setString("KHKT"..self.lv)
    self.node_icon:removeAllChildrenWithCleanup(true)
    local icon = CCSprite:createWithSpriteFrameName(science_info:getNodeWithKey("science_icon"):toStr()..".png")
    self.node_icon:addChild(icon)
    self.label_des:setString(science_info:getNodeWithKey("des"):toStr())
end



--[[--
    初始化
]]
function game_godfield_guild_high_war_keji_pop.init(self,t_params)
    t_params = t_params or {};
    self.lv = t_params.gameData.lv
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_guild_high_war_keji_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_guild_high_war_keji_pop;