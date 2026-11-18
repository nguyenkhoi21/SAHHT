local game_godfield_dart_des_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_vip_need_money_label = nil,
    m_next_vip_label = nil,
    m_list_view_bg = nil,
    m_vip_level = nil,
    m_vip_bar_node = nil,
    text_scroll = nil,
};
--[[--
    销毁ui
]]
function game_godfield_dart_des_pop.destroy(self)
    -- body
    cclog("-----------------ui_vip_pop destroy-----------------");

end
--[[--
    返回
]]
function game_godfield_dart_des_pop.back(self,backType)
    game_scene:removePopByName("game_godfield_dart_des_pop");
    local function responseMethod( tag,gameData )
        game_scene:enterGameUi("game_godfield_dart_main",{gameData = gameData})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_dart_mian"),http_request_method.GET,nil,"god_dart_mian")

end
--[[--
    读取ccbi创建ui
]]
function game_godfield_dart_des_pop.createUi(self)
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
    self.des_lable = ccbNode:labelTTFForName("des_lable");
    if t_params.notice then
      self.des_lable:setString(t_params.notice)  
    end
end


function game_godfield_dart_des_pop.refreshUi(self)

end
--[[--
    初始化
]]
function game_godfield_dart_des_pop.init(self,t_params)
    t_params = t_params or {};
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_dart_des_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_dart_des_pop;