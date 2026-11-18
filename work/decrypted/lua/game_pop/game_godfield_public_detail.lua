--- 神域活动详细

local game_godfield_public_detail = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,

    title_label = nil,
    content_label = nil,
    award_node = nil,
    m_reward_btn = nil, 
    fuken_node = nil,
    content_node = nil,
    show_node = nil,
    text_scroll = nil,
    m_enterType = nil,
    m_openType = nil,
    callBackFunc = nil,
    m_cfgKey = nil,
    m_vision=nil,
};
--[[--
    销毁
]]
function game_godfield_public_detail.destroy(self)
    -- body
    cclog("-----------------game_godfield_public_detail destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;

    self.title_label = nil;
    self.content_label = nil;
    self.award_node = nil;
    self.m_reward_btn = nil;
    self.fuken_node = nil;
    self.content_node = nil;
    self.show_node = nil;
    self.text_scroll = nil;
    m_enterType = nil;
    self.m_openType = nil;
    self.callBackFunc = nil;
    self.m_cfgKey = nil;
    self.m_vision=nil ;
end
--[[--
    返回
]]
function game_godfield_public_detail.back(self,type)
    if self.callBackFunc then
        self:callBackFunc()
    end
    game_scene:removePopByName("game_godfield_public_detail");
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_public_detail.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_godfield_Arena_new_detail.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.content_node = ccbNode:nodeForName("m_list_node")
    self.text_scroll = ccbNode:scrollViewForName("text_scroll")
    self.text_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 4,true);
    self.m_root_layer:setTouchEnabled(true);

    local m_back_layer = ccbNode:layerForName("m_back_layer")
    local function onTouch2(eventType, x, y)
        if eventType == "began" then
            local realPos = m_back_layer:getParent():convertToNodeSpace(ccp(x,y));
            if not m_back_layer:boundingBox():containsPoint(realPos) then
            	self:back()
            end
            return true;

        elseif eventType == "ended" then
        end
    end
    m_back_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-5,true);
    m_back_layer:setTouchEnabled(true);


    return ccbNode;
end

--[[
    内容列表
]]
function game_godfield_public_detail.createContentTable(self,viewSize)
    local contentText = "";
    if self.m_openMsg then
        contentText = self.m_openMsg
	else
        local key = self.m_enterType or "110"
        local detailCfg = getConfig(game_config_field.notice_active);
        local detailCfgTab = json.decode(detailCfg:getFormatBuffer())
        local itemCfg = detailCfgTab[tostring(key)]
        contentText = itemCfg and itemCfg.word or ""
    end
    -- local tempLabel = game_util:createLabelTTF({text = contentText,color = ccc3(255,255,255),fontSize = 12})
    -- tempLabel:setDimensions(CCSizeMake(210,0))
    -- tempLabel:setAnchorPoint(ccp(0,0))
    -- tempLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
    -- tempLabel:setVerticalAlignment(kCCVerticalTextAlignmentTop)
    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(430,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    self.text_scroll:setContentSize(CCSizeMake(430,tempSize.height))
    -- if tempSize.height > viewSize.height then
        self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    -- end
    self.text_scroll:addChild(tempLabel)
end

--[[--
    刷新ui
]]
function game_godfield_public_detail.refreshUi(self)
    self:createContentTable(self.content_node:getContentSize())
end
--[[--
    初始化
]]
function game_godfield_public_detail.init(self,t_params)
    self.m_tParams = t_params or {};
    self.m_enterType = t_params.enterType or "110"
    self.m_openType = t_params.openType or "";
    self.m_openMsg = t_params.openMsg or nil
    self.callBackFunc = t_params.callBackFunc
    self.m_cfgKey = t_params.cfgKey;
    self.m_vision=t_params.vision
end
--[[--
    创建ui入口并初始化数据
]]
function game_godfield_public_detail.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_godfield_public_detail.callBackFunc(self)
    local callBackFunc = self.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc();
    end
end

return game_godfield_public_detail;