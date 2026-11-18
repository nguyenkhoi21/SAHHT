local game_god_Star_pop = {
    m_root_layer = nil,
    des_lable = nil,
};
--[[--
    销毁ui
]]
function game_god_Star_pop:destroy()
    -- body
    cclog("-----------------game_god_Star_pop destroy-----------------");
    self.m_root_layer = nil;
    self.des_lable = nil;
end
--[[--
    返回
]]
function game_god_Star_pop:back(backType)
    game_scene:removePopByName("game_god_Star_pop");

end
--[[--
    读取ccbi创建ui
]]
function game_god_Star_pop:createUi(s)
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
    self.content_node = ccbNode:nodeForName("content_node")
    self.m_root_layer = ccbNode:layerForName('m_root_layer')
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_scroll_view = ccbNode:scrollViewForName("L_scroll_view")
    self.des_lable = ccbNode:labelTTFForName("des_lable");
    if self.t_params.notice then
      self.des_lable:setString(self.t_params.notice) 
      self.des_lable:setVisible(false) 
    end
    self.m_scroll_view:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1002)
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


function game_god_Star_pop:createContentTable(viewSize)
    local contentText = "";
    if self.m_openMsg then
        contentText = self.t_params.openMsg
    end
    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(240,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    self.m_scroll_view:setContentSize(CCSizeMake(viewSize.width,tempSize.height))
    self.m_scroll_view:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.m_scroll_view:addChild(tempLabel)
end


function game_god_Star_pop:refreshUi()
    self:createContentTable(self.content_node:getContentSize())
end
--[[--
    初始化
]]
function game_god_Star_pop:init(t_params)
    self.t_params = t_params or {};
end

--[[--
    创建ui入口并初始化数据
]]
function game_god_Star_pop:create(t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return game_god_Star_pop;