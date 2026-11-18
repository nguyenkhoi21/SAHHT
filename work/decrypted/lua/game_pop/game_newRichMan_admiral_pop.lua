--新大富翁神将
local game_newRichMan_admiral_pop = {
    m_tGameData = nil,
    m_node_hero = nil,
    m_node_reward = nil,
    m_label_des = nil,
    m_label_name = nil,
    m_label_num = nil,
    m_label_combat = nil,
    m_admiralId = nil,
    m_god_reward_times = nil,
    monopoly_enemy_cfg = nil,
    m_reward = nil,
    m_combat = nil,
    m_func_callback = nil,
};
--[[--
    销毁ui
]]
function game_newRichMan_admiral_pop.destroy(self)
    -- body
    cclog("-----------------game_newRichMan_admiral_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_node_hero = nil;
    self.m_node_reward = nil;
    self.m_label_des = nil;
    self.m_label_name = nil;
    self.m_label_num = nil;
    self.m_label_combat = nil;
    self.m_admiralId = nil;
    self.m_god_reward_times = nil;
    self.monopoly_enemy_cfg = nil;
    self.m_reward = nil;
    self.m_combat = nil;
   self.m_func_callback = nil;
end
--[[--
    返回
]]
function game_newRichMan_admiral_pop.back(self,type)
    if self.m_func_callback then
        self:m_func_callback()
    end
	game_scene:removePopByName("game_newRichMan_admiral_pop")
    -- local function endCallFunc()
    --     self:destroy();
    -- end
    -- game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_newRichMan_admiral_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if self.m_animFlag == true then
            return
        end
        cclog2(btnTag,"btnTag ==== ")
        if btnTag == 1 then--返回
            self:back();
        
        elseif btnTag == 2 then
            local function  responseMethod( tag, gameData )
                game_scene:addPop("game_newRichMan_formation_pop",{gameData = gameData, openType = "admiral",popCallBack = self.m_func_callback})
                self:back()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_formation_info"), http_request_method.GET, nil,"monopoly_formation_info")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_newRichMan_admiral_pop.ccbi");
    
    self.m_node_hero = ccbNode:nodeForName("m_node_hero")
    self.m_node_reward = ccbNode:nodeForName("m_node_reward")
    self.m_label_des = ccbNode:labelTTFForName("m_label_des")
    self.m_label_name = ccbNode:labelTTFForName("m_label_name")
    self.m_label_num = ccbNode:labelTTFForName("m_label_num")
    self.m_label_combat = ccbNode:labelTTFForName("m_label_combat")

    local m_close_btn = ccbNode:controlButtonForName("m_btn_back")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    local m_btn_challenge = ccbNode:controlButtonForName("m_btn_challenge")
    m_btn_challenge:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    m_root_layer:setTouchEnabled(true);
    self:refreshLabel()    
    return ccbNode;
end

function game_newRichMan_admiral_pop.createHeroAnim( self )
    self.m_node_hero:removeAllChildrenWithCleanup(true)
    local animNode = nil;
    
    local ainmFile = self.monopoly_enemy_cfg:getNodeWithKey(tostring(self.m_admiralId)):getNodeWithKey("animation"):toStr()
    animNode = game_util:createIdelAnim(ainmFile,0);
    if animNode then
        animNode:setRhythm(1);
        game_anim:playSection(animNode , anim_label_name_cfg.daiji);
        local itemSize = animNode:getContentSize();
        animNode:setAnchorPoint(ccp(0.5,0.5));
        animNode:setPosition(ccp(5,27))
    end
    self.m_node_hero:addChild(animNode);
    -- body
end
function game_newRichMan_admiral_pop.createReward( self )
    self.m_node_reward:removeAllChildrenWithCleanup(true) 
    local reward = self.m_reward
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        game_util:lookItemDetal(reward)
    end
    local icon,name,count = game_util:getRewardByItemTable(reward,nil,true)
    if icon then
        icon:setScale(0.75)
        self.m_node_reward:addChild(icon)
        local countlab = CCLabelTTF:create("x" .. count,TYPE_FACE_TABLE.Arial_BoldMT,10)
        self.m_node_reward:addChild(countlab)
        countlab:setPosition((ccp(25,-12)))
        local button = game_util:createCCControlButton("public_skill.png","",onBtnCilck)
        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
        button:setAnchorPoint(ccp(0,0))
        button:setZoomOnTouchDown(false)
        button:setOpacity(0)
        button:setScale(0.8)
        icon:addChild(button)
    end
    -- body
end
function game_newRichMan_admiral_pop.refreshLabel( self )
    self.m_label_des:setString("Mỗi ngày được nhận mảnh thần tướng 3 lần")
    local name = self.monopoly_enemy_cfg:getNodeWithKey(tostring(self.m_admiralId)):getNodeWithKey("enemy_name"):toStr()
    self.m_label_name:setString(name)
    self.m_label_num:setString("Số lần đánh còn:" ..  3 - self.m_god_reward_times)
    self.m_label_combat:setString(tostring(self.m_combat))

end
--[[--
    刷新ui
]]
function game_newRichMan_admiral_pop.refreshUi(self)
    self:createHeroAnim()
    self:createReward()
    self:refreshLabel()

end
--[[--
    初始化
]]
function game_newRichMan_admiral_pop.init(self,t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_vip.plist")

    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    if t_params.admiralId then
        self.m_admiralId = t_params.admiralId
    end
    if t_params.god_reward_times then
        self.m_god_reward_times = t_params.god_reward_times
    end
    self.monopoly_enemy_cfg = getConfig(game_config_field.monopoly_enemy)
    if t_params.reward then
        self.m_reward = t_params.reward
    end
    if t_params.combat then
        self.m_combat = t_params.combat

    end

    if t_params.popCallBack then
        self.m_func_callback = t_params.popCallBack
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_newRichMan_admiral_pop.create(self,t_params)
    self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi();

    return  m_popUi;
end
return game_newRichMan_admiral_pop;