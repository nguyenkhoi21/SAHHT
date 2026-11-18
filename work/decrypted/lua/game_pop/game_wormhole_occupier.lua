--- 虫洞斗兽场领主 战前准备

local game_wormhole_occupier = {
    gameData = nil,
    m_lb_name      = nil,
    m_lb_area      = nil,
    m_lb_level     = nil,
    m_lb_combats   = nil,
    m_lb_union     = nil,
    m_node_icons   = nil,
    m_btn_challenge = nil,

    m_node = nil,
    m_team = nil,
    m_node_icons = nil,
};
--[[--
    销毁
]]
function game_wormhole_occupier.destroy(self)
    -- body
    cclog("-----------------game_wormhole_occupier destroy-----------------");

    self.gameData       = nil
    self.m_lb_name      = nil
    self.m_lb_area      = nil
    self.m_lb_level     = nil
    self.m_lb_combats   = nil
    self.m_lb_union     = nil
    self.m_node_icons   = nil
    self.m_btn_challenge  = nil
    self.m_node = nil
    self.m_team = nil
    self.m_node_icons = nil
end
--[[--
    返回
]]
function game_wormhole_occupier.back(self,type)
    cclog("------------  remove game_wormhole_occupier")
    game_scene:removePopByName("game_wormhole_occupier");
end
--[[--
    读取ccbi创建ui
]]
function game_wormhole_occupier.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 99999 then--关闭
            self:back();
        elseif btnTag == 1 then--战斗
            local function responseMethod( tag,gameData )
                game_data:setBattleType("wormhole");
                game_data:setWormtype_battle(self.maptype)
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
            end
            local params = {}
            params.sort = self.sort
            params.pos_id = self.pos_id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_go_fight"), http_request_method.GET, params,"wormholes_go_fight")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_game_wormhole_occupier_pop.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_lb_name      = ccbNode:labelTTFForName("m_lb_name")
    self.m_lb_area      = ccbNode:labelTTFForName("m_lb_area")
    self.m_lb_level     = ccbNode:labelTTFForName("m_lb_level")
    self.m_lb_combats   = ccbNode:labelTTFForName("m_lb_combats")
    self.m_lb_union     = ccbNode:labelTTFForName("m_lb_union")
    self.m_node         = ccbNode:labelTTFForName("m_node")
    self.m_node_icons =  ccbNode:labelTTFForName("m_node_icons")
    ccbNode:controlButtonForName("m_close_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    ccbNode:controlButtonForName("m_btn_challenge"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_wormhole_occupier.refreshUi(self)
    self.m_lb_name   :setString(self.gameData.name   or "")
    self.m_lb_area   :setString(self.gameData.server or "")
    self.m_lb_level  :setString(self.gameData.level  or "")
    self.m_lb_combats:setString(self.gameData.combat or "")
    self.m_lb_union  :setString(self.gameData.guild ~= "" and self.gameData.guild  or "Không")

    local roleId = self.gameData.role
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
    if itemCfg then
        animName = itemCfg:getNodeWithKey("animation"):toStr();
    else
        animName = "role_soldier";
    end
    local tempAnim = game_util:createPlayerRoleAnimNew(animName,1)
    tempAnim:setScale(0.8)
    self.m_node:addChild(tempAnim)

    local heroCfg = nil
    local quality = nil
    local length = 0
    local node = CCNode:create()
    for i=1,#self.m_team do
        local itemCfg = self.character_detail_cfg:getNodeWithKey(self.m_team[i].c_id)
        -- cclog2(itemCfg)
        local icon = game_util:createCardIconByCfg(itemCfg,self.m_team[i])
        if icon then
            icon:setAnchorPoint(ccp(0,0.5))
            node:addChild(icon)
            icon:setPosition(ccp(length+2,0))
            icon:setScale(0.7)
            length = length + 1.1 * icon:getContentSize().width*0.7
        end
    end
    self.m_node_icons:addChild(node)
    node:setPosition(ccp(-0.5*length,0))


end

--[[--
    初始化
]]
function game_wormhole_occupier.init(self,t_params)
    t_params = t_params or {};
    -- body

    -- cclog2(t_params)
    self.maptype = t_params.maptype
    self.gameData = t_params.gameData
    self.m_team =  t_params.gameData.alignment_info
    self.sort = t_params.sort  
    self.pos_id = t_params.pos_id

    local uid =  t_params.gameData.uid
    local nametitle = string.sub(t_params.gameData.uid,0,(string.find(t_params.gameData.uid,"_")) and (string.find(t_params.gameData.uid,"_")-1) or 1)
    if nametitle == "robot" then
        self.character_detail_cfg = getConfig("constellation_enemy")
    else
        self.character_detail_cfg = getConfig(game_config_field.character_detail);
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_wormhole_occupier.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_wormhole_occupier;