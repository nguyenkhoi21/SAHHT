--- 坠落之地
--- buff弹版
local game_godfield_guild_high_war_buff_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
};

--[[--
    销毁
]]
function game_godfield_guild_high_war_buff_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_buff_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
end
--[[--
    返回
]]
function game_godfield_guild_high_war_buff_pop.back(self)
    game_scene:removePopByName("game_godfield_guild_high_war_buff_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_buff_pop.createUi(self)
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
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_buff_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    self.label_title = ccbNode:labelTTFForName("label_title") 
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)

    self.label_title:setString("Chi tiết Buff")
    self.label_buff1 = ccbNode:labelTTFForName("label_buff1")
    self.label_buff2 = ccbNode:labelTTFForName("label_buff2")
    self.label_buff1:setColor(ccc3(200,232,249))
    self.label_buff2:setColor(ccc3(200,232,249))
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-12,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end


--[[--
    刷新ui
]]
function game_godfield_guild_high_war_buff_pop.refreshUi(self)

    local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)
    local build_info = guild_high_war_build_cfg:getNodeWithKey(self.m_buildingId)
    local buffs = json.decode(build_info:getNodeWithKey("buff1"):getFormatBuffer()) or {};
 
    local buff_tab = {[1] = "Tấn công vật lý", [2] = "Tấn công ma pháp", [5] = "HP tối đa"}
    if #buffs > 1 then
        local buff1 = buffs[1]
        self.label_buff1:setString("Quân phòng thủ TP này nhận được"..buff1[2].."%"..buff_tab[buff1[1]].."Tăng")
        local buff2 = buffs[2]
        self.label_buff2:setString("Quân phòng thủ TP này nhận được"..buff2[2].."%"..buff_tab[buff2[1]].."Tăng")
    else
        self.label_buff1:setPositionY(58)
        self.label_buff2:setVisible(false)
        local buff1 = buffs[1]
        self.label_buff1:setString("Quân phòng thủ TP này nhận được"..buff1[2].."%"..buff_tab[buff1[1]].."Tăng")
    end

end



--[[--
    初始化
]]
function game_godfield_guild_high_war_buff_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_buildingId = t_params.buildingId
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_guild_high_war_buff_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_guild_high_war_buff_pop;