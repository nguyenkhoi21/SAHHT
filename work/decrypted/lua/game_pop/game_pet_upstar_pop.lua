---  宠物升星

local game_pet_upstar_pop = {
    m_popUi = nil,
    petId = nil,

    label_limit_info_1 = nil,
    label_limit_info_2 = nil,
    label_name = nil,
    label_level = nil,
    node_up_attrs = nil,
    label_per_start = nil,
    label_nex_start = nil,
    node_progress = nil,
    m_icon_node = nil,
    node_progress_exp = nil,
    node_starts_board = nil,
    num_have = nil,
    next_label = nil,
    resolve_id = nil,
    levelUp = nil,
    icon_node = nil,
};
--[[--
    销毁
]]
function game_pet_upstar_pop.destroy(self)
    -- body
    cclog("-----------------game_pet_upstar_pop destroy-----------------");
    self.m_popUi = nil;
    self.petId = nil;

    self.label_limit_info_1 = nil;
    self.label_limit_info_2 = nil;
    self.label_name = nil;
    self.label_level = nil;
    self.node_up_attrs = nil;
    self.label_per_start = nil;
    self.label_nex_start = nil;
    self.node_progress = nil;
    self.m_icon_node = nil;
    self.node_progress_exp = nil;
    self.node_starts_board = nil;
    self.num_have = nil;
    self.next_label = nil;
    self.resolve_id = nil;
    self.levelUp = nil;
    self.icon_node = nil;
end
--[[--
    返回
]]
function game_pet_upstar_pop.back(self,type)
    -- game_scene:removePopByName("game_pet_upstar_pop");
    game_scene:enterGameUi("game_pet_list_scene",{gameData = nil,pet_id = self.petId});
end
--[[--
    读取ccbi创建ui
]]
function game_pet_upstar_pop.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then 
            self:back()
        elseif btnTag == 2 then--up star
            local function responseMethod(tag,gameData)
                self.levelUp = 1
               local itemData,itemCfg = game_data:getPetDataById(self.petId)
               local star = itemData.star
               self:createStarAnim(star)
               -- self:refreshUi()
               -- self.itemCount
            end
            local params = {}
            params.pet_id = self.petId
            params.item = self.resolve_id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pets_pet_evolution"), http_request_method.GET, params,"pets_pet_evolution")
            -- self:createStarAnim(2)
        elseif btnTag == 3 then--buy material
            function shopOpenResponseMethod(tag,gameData)
                game_scene:enterGameUi("game_buy_item_scene",{gameData = gameData});
            end
            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("shop_open"), http_request_method.GET, {},"shop_open")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_pet_upstar_pop.ccbi");

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local btn_upgrade = ccbNode:controlButtonForName("btn_upgrade")
    local btn_upgrade_add = ccbNode:controlButtonForName("btn_upgrade_add")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")

    self.label_limit_info_1 = ccbNode:labelTTFForName("label_limit_info_1")
    self.label_limit_info_2 = ccbNode:labelTTFForName("label_limit_info_2")
    self.label_name = ccbNode:labelTTFForName("label_name")
    self.label_name:setScale(0.7)
    self.label_level = ccbNode:labelTTFForName("label_level")
    self.node_up_attrs = ccbNode:nodeForName("node_up_attrs")
    self.label_per_start = ccbNode:labelTTFForName("label_per_start")
    self.label_nex_start = ccbNode:labelTTFForName("label_nex_start")
    self.node_progress = ccbNode:nodeForName("node_progress")
    self.m_icon_node = ccbNode:nodeForName("m_icon_node")
    self.node_progress_exp = ccbNode:nodeForName("node_progress_exp")
    self.node_starts_board = ccbNode:nodeForName("node_starts_board")
    self.num_have = ccbNode:labelTTFForName("num_have")
    self.next_label = {}
    for i=1,5 do
        self.next_label[i] = ccbNode:labelTTFForName("label_next_" .. i)
    end

    -- self.icon_node = ccbNode:nodeForName("icon_node")
    -- self.icon_node:removeAllChildrenWithCleanup(true)
    -- local icon = game_util:getRewardByItemTable({27,0,1})
    -- if icon then
    --     self.icon_node:addChild(icon)
    -- end

    btn_upgrade:setTouchPriority(GLOBAL_TOUCH_PRIORITY-16)
    btn_upgrade_add:setTouchPriority(GLOBAL_TOUCH_PRIORITY-16)
    btn_upgrade_add:setVisible(game_data:isViewOpenByID(154))
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-16)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-15,true);
    m_root_layer:setTouchEnabled(true);

    return ccbNode;
end

--[[--
    刷新ui
]]
function game_pet_upstar_pop.refreshUi(self)
    local itemData,itemCfg = game_data:getPetDataById(self.petId)
    local name = itemCfg:getNodeWithKey("name"):toStr()
    self.label_name:setString(name)
    self.label_level:setString("LV." .. itemData.lv .. "/" .. itemData.level_max)
    self.m_icon_node:removeAllChildrenWithCleanup(true)
    local tempIcon = game_util:createCardIconByCfg(itemCfg,itemData)
    if tempIcon then
        tempIcon:setScale(0.75);
        self.m_icon_node:addChild(tempIcon)
    end
    --star
    self:createStar(itemData.star)
    --exp
    self.node_progress_exp:removeAllChildrenWithCleanup(true)
    local pet_base = getConfig(game_config_field.pet_base)
    local pet_base_item = pet_base:getNodeWithKey(tostring(itemData.lv))
    local maxExp = math.floor(pet_base_item:getNodeWithKey("exp"):toInt())
    local bar = ExtProgressTime:createWithFrameName("ui_pet_jindutiaoA1.png","ui_pet_jindutiaoA2.png");
    bar:addLabelTTF(CCLabelTTF:create(itemData.exp .. "/" .. maxExp,TYPE_FACE_TABLE.Arial_BoldMT,12));
    self.node_progress_exp:addChild(bar,10,10);
    bar:setMaxValue(maxExp);
    bar:setCurValue(itemData.exp,false);

    self.label_per_start:setString("+" .. itemData.star)
    self.label_nex_start:setString("+" .. math.min(itemData.star + 1,5))

    local pet_evolution = getConfig(game_config_field.pet_evolution)
    -- local evo_itemCfg = pet_evolution:getNodeWithKey(tostring(itemData.star))
    local evo_itemCfg = pet_evolution:getNodeWithKey(tostring(math.min(itemData.star + 1,5)))
    local player_level = evo_itemCfg:getNodeWithKey("player_level"):toInt()
    local need_level = evo_itemCfg:getNodeWithKey("need_level"):toInt()
    self.label_limit_info_1:setString(player_level .. "cấp trở lên")
    self.label_limit_info_2:setString(need_level .. "cấp trở lên")
    self.label_limit_info_1:setScale(0.7)
    self.label_limit_info_2:setScale(0.7)
    --item
    --item id
    local resolve_id = itemCfg:getNodeWithKey("resolve_id"):toInt()
    local itemCount = game_data:getItemCountByCid(tostring(resolve_id))
    self.resolve_id = resolve_id
    self.num_have:setString(itemCount)

    --evo effect
    local petType = itemCfg:getNodeWithKey("type"):toInt()

    local next_star = 1
    if itemData.star < 5 then
        next_star = itemData.star + 1
    end
    local evo_next_cfg = pet_evolution:getNodeWithKey(tostring(next_star))
    local nextEff = evo_next_cfg:getNodeWithKey("type" .. petType)       --{patk,matk,def,speed,hp}
    for i=1,5 do
        local eff = nextEff:getNodeAt((4+i)%5):toInt()
        self.next_label[i]:setString("+" .. eff)
    end
    --evo material
    self.node_progress:removeAllChildrenWithCleanup(true)
    local upStarExp = 0
    local upExp = 0
    if itemData.star == 5 then

    else
        upStarExp = pet_evolution:getNodeWithKey(tostring(next_star)):getNodeWithKey("exp"):toInt()
    end
    local evobar = ExtProgressTime:createWithFrameName("ui_pet_jindutiaoA4.png","ui_pet_jindutiaoA3.png");
    local label = CCLabelTTF:create(upExp .. "/" .. upStarExp,TYPE_FACE_TABLE.Arial_BoldMT,12);
    label:setColor(ccc3(255,255,60))
    evobar:addLabelTTF(label)
    self.node_progress:addChild(evobar,10,10);
    evobar:setMaxValue(upStarExp);
    evobar:setCurValue(upExp,false);

    -- self.levelUp = 1
    local last_pet_base_item = pet_evolution:getNodeWithKey(tostring(math.max(itemData.star,1)))
    local last_maxExp = math.floor(last_pet_base_item:getNodeWithKey("exp"):toInt())
    evobar:registerScriptBarHandler(function(extBar)
        if self.levelUp == 1 then
            evobar:setMaxValue(last_maxExp);
            evobar:setCurValue(0,false);    
            evobar:setCurValue(last_maxExp,true);    
            self.levelUp = 2
        elseif self.levelUp == 2 then
            evobar:setMaxValue(upStarExp);
            evobar:setCurValue(0,false);
            evobar:setCurValue(upExp,false);
        end
    end);
    evobar:setCurValue(0,false);
    evobar:setCurValue(upExp,true);
end
--[[
    星星显示
]]
function game_pet_upstar_pop.createStar(self,star)
    self.node_starts_board:removeAllChildrenWithCleanup(true)
    for i=1,5 do
        local star_back = CCSprite:createWithSpriteFrameName("ui_pet_xingxing2.png")
        self.node_starts_board:addChild(star_back)
        star_back:setPosition(ccp(20 + (i-1) * 15,9))
        if i <= star then
            local star = CCSprite:createWithSpriteFrameName("ui_pet_xingxing1.png")
            self.node_starts_board:addChild(star)
            star:setPosition(ccp(20 + (i-1) * 15,9))
        end
    end
end
--[[
    星星动画
]]
function game_pet_upstar_pop.createStarAnim(self,index)
    local star = CCSprite:createWithSpriteFrameName("ui_pet_xingxing1.png")
    star:setPosition(ccp(20 + (index-1) * 15,9))
    local function setOver(node)
        game_sound:playUiSound("stamp")

        local lastStar = self.node_starts_board:getChildByTag(999)
        if lastStar then
            lastStar:removeFromParentAndCleanup(true)
        end
    end
    local function setSpiteVisible(sprite)
        star:setVisible(true)
    end
    self.node_starts_board:addChild(star,100,999)
    local setOver = CCCallFuncN:create(setOver)
    local setSpiteVisible = CCCallFuncN:create(setSpiteVisible)
    star:setScale(4)
    star:setVisible(false)
    local arr = CCArray:create();
    arr:addObject(setSpiteVisible)
    arr:addObject(CCScaleBy:create(0.5,0.25));
    arr:addObject(setOver);
    star:runAction(CCSequence:create(arr));

    local function endFunc(node)
        local lastGuang = self.m_icon_node:getChildByTag(999)
        if lastGuang then
            lastGuang:removeFromParentAndCleanup(true)
        end
        self:refreshUi()
    end
    local guang = CCSprite:createWithSpriteFrameName("public_faguang_2.png")
    guang:setScale(0.7)
    self.m_icon_node:addChild(guang,-1,999)

    local actionArr = CCArray:create()
    actionArr:addObject(CCFadeOut:create(1))
    actionArr:addObject(CCCallFuncN:create(endFunc))
    guang:runAction(CCSequence:create(actionArr))
end
--[[--
    初始化
]]
function game_pet_upstar_pop.init(self,t_params)
    t_params = t_params or {};
    self.petId = t_params.petId
    self.itemCount = 0
    self.levelUp = 0
end

--[[--
    创建ui入口并初始化数据
]]
function game_pet_upstar_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_pet_upstar_pop;