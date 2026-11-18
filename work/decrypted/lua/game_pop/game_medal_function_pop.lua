-- 勋章选择去练卡还是变卡

local game_medal_function_pop = {
    m_close_btn = nil,
    m_goto_btn_1 = nil,
    m_goto_btn_2 = nil,
    gameData = nil,
    material_id = nil,

    gameData = nil,
    material_id = nil,
    material_type = nil,
    material_make_table = nil,
};
--[[--
    销毁ui
]]
function game_medal_function_pop.destroy(self)
    -- body
    cclog("-----------------game_medal_function_pop destroy-----------------");
    self.m_close_btn = nil;
    self.m_goto_btn_1 = nil;
    self.m_goto_btn_2 = nil;

    self.gameData = nil;
    self.material_id = nil;
    self.material_type = nil;
    self.material_make_table = nil;
end

--[[--
    返回
]]
function game_medal_function_pop.back(self,type)
    game_scene:removePopByName("game_medal_function_pop")
end
--[[--
    读取ccbi创建ui
]]
function game_medal_function_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 11 then--练卡
            game_scene:enterGameUi("game_medal_refining",{gameData = self.gameData,material_type = self.material_type,material_make_table = self.material_make_table})
        elseif btnTag == 12 then--变卡
            -- game_scene:enterGameUi("game_medal_make",{gameData = self.gameData})
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_medal_make",{gameData = gameData,materialId = self.material_id});
                self:back();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_index"), http_request_method.GET, nil,"medal_index")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_medal_select_pop.ccbi");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)

    self.m_goto_btn_1 = ccbNode:controlButtonForName("m_goto_btn_1")
    self.m_goto_btn_2 = ccbNode:controlButtonForName("m_goto_btn_2")

    self.m_goto_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
    self.m_goto_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)

    local materialCfg = getConfig(game_config_field.material)
    local itemCfg = materialCfg:getNodeWithKey(tostring(self.material_id))
    local material = itemCfg:getNodeWithKey("material")
    if material:getNodeCount() == 0 then--不可炼制
        self.m_goto_btn_1:setEnabled(false)
        game_util:setCCControlButtonTitle(self.m_goto_btn_1,"Không thể luyện")
    elseif material:getNodeCount() > 0 then--判断材料够不够
        local have_count = 0
        for i=1,material:getNodeCount() do
            local itemMaterial = material:getNodeAt(i-1):toInt()
            local materialData = self.gameData["material"]
            if materialData[tostring(itemMaterial)] and materialData[tostring(itemMaterial)] > 0 then
                have_count = have_count + 1
            end
        end
        -- if have_count == material:getNodeCount() then--材料都有
            self.material_make_table[1] = self.material_id
            self.material_make_table[2] = material:getNodeAt(0):toStr()
            self.material_make_table[3] = material:getNodeAt(1):toStr()
            self.material_make_table[4] = material:getNodeAt(2):toStr()
        -- elseif have_count < material:getNodeCount() then--不足
        --     -- self.m_goto_btn_1:setEnabled(false)
        --     self.m_goto_btn_1:setEnabled(true)
            -- game_util:setCCControlButtonTitle(self.m_goto_btn_1,"材料不足")
        -- end
    end

    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-11,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_medal_function_pop.refreshUi(self)

end
--[[--
    初始化
]]
function game_medal_function_pop.init(self,t_params)
    t_params = t_params or {};
    self.gameData = t_params.gameData
    self.material_id = t_params.material_id
    self.material_type = t_params.material_type
    self.material_make_table = {}
end

--[[--
    创建ui入口并初始化数据
]]
function game_medal_function_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_medal_function_pop;