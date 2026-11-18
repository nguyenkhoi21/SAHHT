--- 敌人信息弹出
local game_serverGuild_morale_pop = {
    m_tGameData = nil,
    tab_ui = nil,
    label_max = nil,
    label_coin = nil,
    index_select = nil,


};

--[[--
    销毁
]]
function game_serverGuild_morale_pop:destroy()
    -- body
    cclog("-----------------game_serverGuild_morale_pop destroy-----------------");
    self.m_tGameData = nil;
    self.tab_ui = nil;
    self.label_coin = nil;
    self.label_max = nil;
    self.index_select = nil;
end
--[[--
    返回
]]
function game_serverGuild_morale_pop:back(type)
    game_scene:removePopByName("game_serverGuild_morale_pop");
end
local buff_value = {"phsc", "mgc", "speed", "dfs", "hp",}
--[[--
    读取ccbi创建ui
]]
function game_serverGuild_morale_pop:createUi()
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then--增加士气
            local function responseMethod( tag, gameData )
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local data = gameData:getNodeWithKey("data")
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
                    self:refreshUi()
                end
            end
            local params = {}
            params.tp = buff_value[self.index_select]
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_buy_buff"), http_request_method.GET, params,"new_guild_fight_buy_buff",true,true)
        elseif btnTag == 3 then--重置
            local function responseMethod( tag,gameData )
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local data = gameData:getNodeWithKey("data")
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
                    self:refreshUi()
                end
            end
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_clear_user_buff"), http_request_method.GET, nil,"new_guild_fight_clear_user_buff")
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = "是否进行重置，重置后所有加成清零。",      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            game_util:openAlertView(t_params)
            
        elseif btnTag == 5 then
            local function responseMethod( tag,gameData )
                local building_id = self.building_id
                game_scene:addPop("game_server_guildbattle_point_pop",{gameData = gameData,building_id = building_id, isOnly = true, isEnemy = true}) 
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_formation_info"), http_request_method.GET, nil,"new_guild_fight_formation_info")
        elseif btnTag > 10 then
            self.index_select = btnTag - 10
            for i=1,5 do
                self.tab_ui[i].sprite_select:setVisible(false)
            end 
            self.tab_ui[self.index_select].sprite_select:setVisible(true)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_serverGuild_morale_pop.ccbi");
    local btn_addmorale = ccbNode:controlButtonForName("btn_addmorale")
    btn_addmorale:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)

    local btn_restart = ccbNode:controlButtonForName("btn_restart")
    btn_restart:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)

    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)

    self.label_max = ccbNode:labelTTFForName("label_max")
    self.label_coin = ccbNode:labelTTFForName("label_coin")

    self.tab_ui = {}
    local label_add, sprite_select, sprite_jidutiao, btn_add = nil, nil, nil, nil;
    for i=1,5 do
        label_add = ccbNode:labelTTFForName("label_add" .. i)
        sprite_select = ccbNode:spriteForName("sprite_select" .. i)
        sprite_jidutiao = ccbNode:spriteForName("sprite_jidutiao" .. i)
        btn_add = ccbNode:controlButtonForName("btn_add" .. i)
        self.tab_ui[i] = {label_add = label_add, sprite_select = sprite_select, sprite_jidutiao= sprite_jidutiao, btn_add = btn_add}
        sprite_select:setVisible(false)
        btn_add:setTag(i + 10)
        btn_add:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    end
    self.tab_ui[1].sprite_select:setVisible(true)
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        return true;
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-2,true)
    m_root_layer:setTouchEnabled(true)
    return ccbNode;
end

function game_serverGuild_morale_pop.createProgress( self )
    local buffTab,_ = self:getAddData()
    for i=1,5 do
        local expBg = self.tab_ui[i].sprite_jidutiao
        local expBgSize = expBg:getContentSize(); 
        local current_score = buffTab[tostring(i)] or 0
        local score_max = 100
        local percentage = current_score/score_max * 100 
        self.tab_ui[i].label_add:setString(current_score .. "%") 
        local params = {}
        params.percentage = percentage
        params.fileName = "serverGuild_jindutiao2.png"
        params.type =  kCCProgressTimerTypeVerticalBarBT
        params.midpoint = ccp(expBgSize.width*0.5,0)
        params.barChangeRate = ccp(0,1)
        local expBarAdd = game_util:createProgressTimer(params)
        expBg:removeAllChildrenWithCleanup(true)
        expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
        expBg:addChild(expBarAdd,2,1);
    end
end
function game_serverGuild_morale_pop.getAddData( self )
    local buffTab = {}
    local totalAdd = 0
    for k,v in pairs(self.m_tGameData.user_buff) do
        if k == "hp" then
            buffTab["5"] = v
        elseif k == "phsc" then
            buffTab["1"] = v
        elseif k == "mgc" then
            buffTab["2"] = v
        elseif k == "speed" then
            buffTab["3"] = v
        elseif k == "dfs" then
            buffTab["4"] = v
        end
        totalAdd = totalAdd + v
    end
    return buffTab, totalAdd
end
function game_serverGuild_morale_pop.refreshUi(self)
    self:createProgress()
    local _,totalAdd = self:getAddData()
    local new_guild_time = getConfig(game_config_field.new_guild_time)
    local tempData = new_guild_time:getNodeWithKey("1")
    local buff_buy_times = tempData:getNodeWithKey("buff_buy_times"):toInt()
    local buff_buy_rate = tempData:getNodeWithKey("buff_buy_rate"):toInt()
    local allAdd = buff_buy_times * buff_buy_rate
    local canAdd = allAdd - totalAdd
    self.label_max:setString(tostring(canAdd) .. "%")

    local new_guild_time = getConfig(game_config_field.new_guild_fight)
    local costData = new_guild_time:getNodeWithKey("4")
    costData = json.decode(costData:getFormatBuffer())
    local costCoin = costData.cost[1][3]
    self.label_coin:setString(tostring(costCoin))
end



--[[--
    初始化
]]
function game_serverGuild_morale_pop.init(self,t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_server_pyramid_n_res.plist");
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
    end
    self.index_select = 1
 
end

--[[--
    创建ui入口并初始化数据
]]
function game_serverGuild_morale_pop:create(t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_serverGuild_morale_pop;