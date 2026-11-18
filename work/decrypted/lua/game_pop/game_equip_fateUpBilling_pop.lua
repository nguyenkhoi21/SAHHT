--- 当前卡组

local game_equip_fateUpBilling_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    black_layer = nil,
    m_tGameData = nil,
    m_callback = nil,
    m_label_des = nil,
};
--[[--
    销毁
]]
function game_equip_fateUpBilling_pop.destroy(self)
    -- body
    cclog("-----------------game_equip_fateUpBilling_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.black_layer = nil;
    m_tGameData = nil;
    self.m_callback = nil;
    self.m_label_des = nil;
end
--[[--
    返回
]]
function game_equip_fateUpBilling_pop.back(self,type)
    if self.m_callback and tolua.type(self.m_callback) == "function" then
       self.m_callback()
    end
    game_scene:removePopByName("game_equip_fateUpBilling_pop");
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_equip_fateUpBilling_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag == ")
        if btnTag == 100 then--关闭
            self:back();
        elseif btnTag == 501 then
        	local params = {}
        	params.equip_id = self.m_tGameData.equip_id
        	params.card_id = self.m_tGameData.selHeroId
        	local function responseMethod( tag,gameData )
                self:back()
        	end
        	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("fate_equip_bind"), http_request_method.GET, params,"fate_equip_bind")

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_equip_fateBilling_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
   	local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local m_saveBtn = ccbNode:controlButtonForName("m_saveBtn")
    self.m_label_des = ccbNode:labelTTFForName("m_label_des")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-17)
    m_saveBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-17)
    self.black_layer = ccbNode:layerForName("layer_color")
    self.black_layer:setVisible(false)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end

    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-17,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

function game_equip_fateUpBilling_pop.refreshUi(self)
   local cost = 10
   local equip_fate = getConfig(game_config_field.equip_fate)
   cost = equip_fate:getNodeWithKey("1"):getNodeWithKey("cost"):toInt()
   cclog2(cost,"cost === ")
   self.m_label_des:setString("Xác định tiêu hao" .. cost .. "Đá Vận Mệnh sẽ khóa trang bị trên người nhân vật, khóa xong sẽ ko thể đổi trang bị")

end
--[[--
    初始化
]]
function game_equip_fateUpBilling_pop.init(self,t_params)
	self.m_tGameData = t_params.gameData
    self.m_callback = t_params.callBack
end

--[[--
    创建ui入口并初始化数据
]]
function game_equip_fateUpBilling_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi()
    return self.m_popUi;
end
return game_equip_fateUpBilling_pop;