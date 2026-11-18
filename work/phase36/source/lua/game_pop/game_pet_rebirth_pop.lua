--- game_pet_rebirth_pop信息  重生提示

local game_pet_rebirth_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_itemId = nil,
    m_callBackFunc = nil,
    m_openType = nil,

    itemData = nil,
    hero_id = nil,
    m_tParams = nil,

    m_text_label = nil,
    m_func_btn_1 = nil,
    m_func_btn_2 = nil,
    hero_icon_node = nil,
    m_btn_1 = nil,
    m_btn_2 = nil,
    m_close_btn = nil,

    show_node_btn = nil,
    show_node_label = nil,
    sliver_dir = nil,
    gold_dir = nil,

    sliver_dir_basis = nil,
    gold_dir_basis = nil,
    pet_id = nil,
};

--[[--
    销毁
]]
function game_pet_rebirth_pop.destroy(self)
    -- body
    cclog("-----------------game_pet_rebirth_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_itemId = nil;
    self.m_callBackFunc = nil;
    self.m_openType = nil;
    self.itemData = nil;
    self.hero_id = nil;
    self.m_tParams = nil;

    self.m_text_label = nil;
    self.m_func_btn_1 = nil;
    self.m_func_btn_2 = nil;
    self.hero_icon_node = nil;
    self.m_btn_1 = nil;
    self.m_btn_2 = nil;
    self.m_close_btn = nil;

    self.show_node_btn = nil;
    self.show_node_label = nil;
    self.sliver_dir = nil;
    self.gold_dir = nil;
    self.sliver_dir_basis = nil;
    self.gold_dir_basis = nil;
    self.pet_id = nil;
end
--[[--
    返回
]]
local quality_name = {"白","绿","蓝","紫","橙","红","黑","黑"}

function game_pet_rebirth_pop.back(self,type)
    game_scene:removePopByName("game_pet_rebirth_pop");

end
--[[--
    读取ccbi创建ui
]]
function game_pet_rebirth_pop.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/new_main_add_res.plist")
    local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(self.m_itemId));
    local ccbNode = luaCCBNode:create();

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 11 then
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local reward = json.decode(data:getNodeWithKey("reward"):getFormatBuffer())
                game_util:closeAlertView();
                -- self:back()
                game_scene:enterGameUi("game_pet_list_scene",{gameData = nil});
                game_util:rewardTipsByDataTable(reward);
            end
            if game_data:getItemCountByCid("3013") > 0 then
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pet_rebirth"), http_request_method.GET, {pet_id = self.pet_id},"pet_rebirth")
            else
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pet_rebirth"), http_request_method.GET, {pet_id = self.pet_id},"pet_rebirth")
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,       --可缺省
                    cancelBtnText = string_config.m_btn_cancel,
                    text = "Đá Tái Sinh Thú Nuôi không đủ, dùng 50 Xu tái sinh thú nuôi này nhé?",      --可缺省
                    onlyOneBtn = false,
                    touchPriority = GLOBAL_TOUCH_PRIORITY-13,
                }
                game_util:openAlertView(t_params)
            end
        elseif btnTag == 12 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_wanning_pop.ccbi");
    
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_text_label = ccbNode:labelTTFForName("m_text_label")
    self.m_text_label:setDimensions(CCSizeMake(172,130))
    self.m_text_label:setPosition(ccp(233,134))
    self.m_func_btn_1 = ccbNode:controlButtonForName("m_func_btn_1")
    self.m_func_btn_2 = ccbNode:controlButtonForName("m_func_btn_2")
    self.hero_icon_node = ccbNode:nodeForName("hero_icon_node")
    self.m_btn_1 = ccbNode:controlButtonForName("m_btn_1")
    self.m_btn_2 = ccbNode:controlButtonForName("m_btn_2")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")

    self.show_node_btn = ccbNode:nodeForName("show_node_btn")
    self.show_node_label = ccbNode:nodeForName("show_node_label")
    self.sliver_dir = ccbNode:labelTTFForName("sliver_dir")
    self.gold_dir = ccbNode:labelTTFForName("gold_dir")
    local ext_label = ccbNode:labelTTFForName("ext_label")
    ext_label:setVisible(true)

    self.m_func_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_func_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)

    game_util:setCCControlButtonTitle(self.m_btn_1,"Tái sinh")
    self.m_func_btn_1:setVisible(false)
    self.m_func_btn_2:setVisible(false)

    local petData,petCfg = game_data:getPetDataById(tostring(self.pet_id));
    self.hero_icon_node:removeAllChildrenWithCleanup(true)
    local animNode = game_util:createHeroListItemByCCB();
    game_util:setPetListItemInfoByTable(animNode,petData)
    self.hero_icon_node:addChild(animNode,10,10);


    local activeCfg = getConfig(game_config_field.notice_active)
    local itemCfg = activeCfg:getNodeWithKey( "165" )
    contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or "Hoạt động hấp dẫn chờ mọi người tham gia!"
    self.m_text_label:setString(contentText)

    local count = game_data:getItemCountByCid("3013")
    ext_label:setString("Đá Tái Sinh Thú Nuôi" .. count .. "viên")

    local function onTouch( eventType,x,y )
        -- body
        if(eventType == "began")then
            return true;
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    self.m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_pet_rebirth_pop.refreshUi(self)

end

--[[--
    初始化
]]
function game_pet_rebirth_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_tParams = t_params;
    self.pet_id = t_params.pet_id
end

--[[--
    创建ui入口并初始化数据
]]
function game_pet_rebirth_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_pet_rebirth_pop;