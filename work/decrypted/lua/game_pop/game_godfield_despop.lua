local game_godfield_despop = {
    m_root_layer = nil,
    des_lable = nil,
};
--[[--
    销毁ui
]]
function game_godfield_despop.destroy(self)
    -- body
    cclog("-----------------ui_vip_pop destroy-----------------");
    self.m_root_layer = nil;
    self.des_lable = nil;
end
--[[--
    返回
]]
function game_godfield_despop.back(self,backType)
    game_scene:removePopByName("game_godfield_dart_des_pop");
    local function responseMethod( tag,gameData )
        game_scene:enterGameUi("game_godfield_dart_main",{gameData = gameData})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_dart_mian"),http_request_method.GET,nil,"god_dart_mian")
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_despop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_dart_des_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName('m_root_layer')
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.des_lable = ccbNode:labelTTFForName("des_lable");
    if self.t_params.notice then
      self.des_lable:setString(self.t_params.notice)  
    end
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1002)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1001,true)
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode
end


function game_godfield_despop.refreshUi(self)

end
--[[--
    初始化
]]
function game_godfield_despop.init(self,t_params)
    self.t_params = t_params or {};
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_despop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_despop;