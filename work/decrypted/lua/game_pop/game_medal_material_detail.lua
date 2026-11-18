--- 勋章 材料 详情

local game_medal_material_detail = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,

    gameData = nil,
    material_id = nil,
    node_intro_msg_board = nil,
    story_label = nil,
    m_have_label = nil,
    m_icon_spr = nil,
    m_title_label = nil,
    openType = nil,
    material_type = nil,
};

--[[--
    销毁
]]
function game_medal_material_detail.destroy(self)
    -- body
    cclog("-----------------game_medal_material_detail destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;

    self.gameData = nil;
    self.material_id = nil;
    self.node_intro_msg_board = nil;
    self.story_label = nil;
    self.m_have_label = nil;
    self.m_icon_spr = nil;
    self.m_title_label = nil;
    self.openType = nil;
    self.material_type = nil;
end
--[[--
    返回
]]
function game_medal_material_detail.back(self,type)
    game_scene:removePopByName("game_medal_material_detail");
end
--[[--
    读取ccbi创建ui
]]
function game_medal_material_detail.createUi(self)
    local ccbNode = luaCCBNode:create();

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then--变卡
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_medal_make",{gameData = gameData,materialId = self.material_id,material_type = self.material_type});
                self:destroy()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("medal_index"), http_request_method.GET, nil,"medal_index")
        elseif btnTag == 3 then--获取--  跳转到钻石商城
            function shopOpenResponseMethod(tag,gameData)
                game_scene:enterGameUi("game_buy_item_scene",{gameData = gameData,page_index = "last"});
                self:destroy()
            end
            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("shop_open"), http_request_method.GET, {},"shop_open")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_medal_detail.ccbi");
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
    if self.openType == 2 then
        m_right_btn:setVisible(false)
        m_left_btn:setVisible(false)
    end

    self.node_intro_msg_board = ccbNode:nodeForName("node_intro_msg_board")
    self.story_label = ccbNode:labelTTFForName("story_label")

    self.m_have_label = ccbNode:labelTTFForName("m_have_label")
    self.m_icon_spr = ccbNode:spriteForName("m_icon_spr")

    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_medal_material_detail.refreshUi(self)
    --勋章信息
    self.node_intro_msg_board:removeAllChildrenWithCleanup(true)
    local materialCfg = getConfig(game_config_field.material);
    if self.material_id then
        local itemCfg = materialCfg:getNodeWithKey(tostring(self.material_id))
        local name = itemCfg:getNodeWithKey("name"):toStr()

        --说明
        local story = itemCfg:getNodeWithKey("des"):toStr()
        self.story_label:setString(story)
        
        --
        self.m_title_label:setString(name)
        local material = self.gameData["material"]
        local count = 0
        if material[tostring(self.material_id)] then
            count = material[tostring(self.material_id)]
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
function game_medal_material_detail.init(self,t_params)
    t_params = t_params or {};
    self.gameData = t_params.gameData
    self.material_id = t_params.material_id
    self.material_type = t_params.material_type
    self.openType = t_params.openType or 1
end

--[[--
    创建ui入口并初始化数据
]]
function game_medal_material_detail.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_medal_material_detail;