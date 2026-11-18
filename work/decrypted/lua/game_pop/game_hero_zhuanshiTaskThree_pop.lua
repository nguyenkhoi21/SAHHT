--- 转世第三关弹窗

local game_hero_zhuanshiTaskThree_pop = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,
    animNode = nil,
    m_cardId = nil,
    m_go_btn = nil,
    m_giveup_btn = nil,
    m_tittle_lab = nil,
    m_task_lab1 = nil,
    m_guanqia_lab = nil,
    m_des_lab = nil,
};
--[[--
    销毁
]]
function game_hero_zhuanshiTaskThree_pop.destroy(self)
    -- body
    cclog("-----------------game_hero_zhuanshiTaskThree_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;
    self.animNode = nil;
    self.m_cardId = nil;
    self.m_go_btn = nil;
    self.m_giveup_btn = nil;
    self.m_tittle_lab = nil;
    self.m_task_lab1 = nil;
    self.m_guanqia_lab = nil;
    self.m_des_lab = nil;
end
    
--[[--
    返回
]]
function game_hero_zhuanshiTaskThree_pop.back(self,type)
    game_scene:removePopByName("game_hero_zhuanshiTaskThree_pop");
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_hero_zhuanshiTaskThree_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then
            
        elseif btnTag == 102 then 
            self:back()
        elseif btnTag == 103 then
            local gameData1,_ = game_data:getCardDataById(self.m_cardId)
            game_data:setZhuanshiTask1Data(gameData1)
            local afterlife =  getConfig(game_config_field.afterlife)
            afterlife = json.decode(afterlife:getFormatBuffer()) or {};
            
            local chapterId = tostring(gameData1.c_id)
            local lifecfg = afterlife[chapterId]

            local buildingId = lifecfg.building
            local city =  string.sub(buildingId,1,3)
            local function responseMethod( tag,gameData )
                game_data:setBattleType("zhuanshiTask2");
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
            end
            local params = {}
            params.city = city
            params.building = buildingId
            params.card_id = self.m_cardId
            params.step_n = 0
            --cclog2(params,"params========")
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_recapture"), http_request_method.GET, params,"private_city_recapture")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_hero_zhuanshi_task3pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer1");
    self.animNode = ccbNode:nodeForName("animNode")
    -- local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    -- m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_go_btn = ccbNode:controlButtonForName("m_go_btn")
    self.m_go_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_giveup_btn = ccbNode:controlButtonForName("m_giveup_btn")
    self.m_giveup_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_tittle_lab = ccbNode:labelTTFForName("m_tittle_lab")
    self.m_task_lab1 = ccbNode:labelTTFForName("m_task_lab1")
    self.m_guanqia_lab = ccbNode:labelTTFForName("m_guanqia_lab")
    self.m_des_lab = ccbNode:labelTTFForName("m_des_lab")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

function game_hero_zhuanshiTaskThree_pop.createHeroAnim(self)
    self.animNode:removeAllChildrenWithCleanup(true)
    local card_ccbNode = self:setQuanshenxiang();
    self.animNode:addChild(card_ccbNode,10,10)
end

function game_hero_zhuanshiTaskThree_pop.setQuanshenxiang(self)
    local animNode = nil;
    local heroData,heroCfg = game_data:getCardDataById(self.m_cardId)
    if heroData and heroCfg then
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        --local animNode = game_util:createPauseAnim(animation,0,heroDataTable,itemConfig);
        animNode = game_util:createIdelAnim(ainmFile,0,heroData,heroCfg);
        heroCfg = json.decode(heroCfg:getFormatBuffer())
        local name = heroCfg.name
        self.m_tittle_lab:setString(name .. "thí luyện của  -NV thức tỉnh")
        local afterlife = getConfig(game_config_field.afterlife);
        afterlife = json.decode(afterlife:getFormatBuffer())
        local id = tostring(heroData.c_id)
        local des3 = afterlife[id].des3
        self.m_des_lab:setString(name .. des3)
        if animNode then
        --     animNode:setRhythm(1);
        --     game_anim:playSection(animNode , anim_label_name_cfg.daiji);
        --     local itemSize = animNode:getContentSize();
            animNode:setAnchorPoint(ccp(0.5,0));
        end
    end
    return animNode;
end
--[[--
    创建关卡名
]]
function game_hero_zhuanshiTaskThree_pop.createName(self)
    local afterlife = getConfig(game_config_field.afterlife);
    local heroData,heroCfg = game_data:getCardDataById(self.m_cardId)
    local id = tostring(heroData.c_id)
    local building = afterlife:getNodeWithKey(tostring(id)):getNodeWithKey("building"):toStr()
    local map_main_story = getConfig(game_config_field.map_main_story);
    local orderId = string.sub(building,2,3)
    orderId = tonumber(orderId) + 1
    local stage_name = map_main_story:getNodeWithKey(tostring(orderId)):getNodeWithKey("stage_name"):toStr()
    local chapter = getConfig(game_config_field.chapter);
    local itemCfg = chapter:getNodeWithKey(string.sub(building,1,2))
    local bigName = itemCfg:getNodeWithKey("chapter_name"):toStr()
    self.m_guanqia_lab:setString(bigName .. stage_name)

    local map_title_detail = getConfig(game_config_field.map_title_detail);
    local title_name =  map_title_detail:getNodeWithKey(tostring(building)):getNodeWithKey("title_name"):toStr()
    self.m_task_lab1:setString("Hoàn thành" .. title_name .. "1 lần sẽ có thể vào chuyển thế")
end
--[[--
    刷新ui
]]
function game_hero_zhuanshiTaskThree_pop.refreshUi(self)
    self:createHeroAnim()
    self:createName()
end
--[[--
    初始化
]]
function game_hero_zhuanshiTaskThree_pop.init(self,t_params)
    self.m_cardId = t_params.major or 0

end
--[[--
    创建ui入口并初始化数据
]]
function game_hero_zhuanshiTaskThree_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_hero_zhuanshiTaskThree_pop;