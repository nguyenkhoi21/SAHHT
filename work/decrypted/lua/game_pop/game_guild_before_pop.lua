--- game_guild_before_pop信息

local game_guild_before_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    game_data = nil,
    open_text = nil,
    status_text = nil,
    tips_text = nil,
    btn_buy = nil,
    user_post = nil,
};

--[[--
    銷毀
]]
function game_guild_before_pop.destroy(self)
    -- body
    cclog("-----------------game_guild_before_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.game_data = nil;
    self.open_text = nil;
    self.status_text = nil;
    self.tips_text = nil;
    self.btn_buy = nil;
    self.user_post = nil;
end
--[[--
    返回
]]
function game_guild_before_pop.back(self,type)
    game_scene:removePopByName("game_guild_before_pop");
end
--[[--
    讀取ccbi創建ui
]]
function game_guild_before_pop.createUi(self)
    local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(self.m_itemId));
    local ccbNode = luaCCBNode:create();

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then--開啟或者是進入
            local guildboss_open = self.game_data.guildboss_open
            if guildboss_open == true then
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    local boss_info = data:getNodeWithKey("boss_info");
                    if boss_info:getNodeCount() == 0 then
                        game_util:addMoveTips({text = "\"Godzilla tấn công\"Chưa đến thời gian hoạt động!"});
                    else
                        local function callBackFunc()
                            self:destroy();
                            static_rootControl = nil;
                        end
                        game_scene:enterGameUi("game_guild_boss",{gameData = gameData})
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guildboss_index"), http_request_method.GET, nil,"guildboss_index")
            else
                local function responseMethod(tag,gameData)
                    self.game_data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guildboss_open"), http_request_method.GET, {try_open = "1"},"guildboss_open")
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_boss_before_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    local function onTouch( eventType,x,y )
        if(eventType == "began")then
            self:back();
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    
    self.btn_buy = ccbNode:controlButtonForName("btn_buy");
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"),"CCControlButton");

    self.open_text = ccbNode:labelTTFForName("open_text")
    self.status_text = ccbNode:labelTTFForName("status_text")
    self.tips_text = ccbNode:labelTTFForName("tips_text")

    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 25);
    self.btn_buy:setTouchPriority(GLOBAL_TOUCH_PRIORITY-25)

    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_guild_before_pop.refreshUi(self)
    local guildboss_open = self.game_data.guildboss_open
    if guildboss_open == true then--開啟
        self.open_text:setString("Godzilla tấn công đã mở")
        self.status_text:setString("Trạng thái: mở")
        self.status_text:setColor(ccc3(166,235,38))
        self.tips_text:setString("Thời gian mở BOSS  21:00")

        game_util:setCCControlButtonTitle(self.btn_buy,"Vào")
        game_util:setControlButtonTitleBMFont(self.btn_buy)
    else
        self.open_text:setString("Tiêu hao 50 cờ chiến mở")
        self.status_text:setString("Trạng thái: chưa mở")
        self.status_text:setColor(ccc3(192,26,1))
        self.tips_text:setString("Cần hội trưởng hoặc hội phó mở trước 20:45")

        game_util:setCCControlButtonTitle(self.btn_buy,"Mở")
        game_util:setControlButtonTitleBMFont(self.btn_buy)
        if self.user_post == "owner" or self.user_post == "vp" then
            self.btn_buy:setEnabled(true)
        else
            self.btn_buy:setEnabled(false)
        end
    end
end

--[[--
    初始化
]]
function game_guild_before_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.game_data = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
        -- cclog("self.game_data = " .. json.encode(self.game_data))
    end
    self.user_post = t_params.user_post
    cclog("self.user_post = " .. self.user_post)
end

--[[--
    創建ui入口並初始化數據
]]
function game_guild_before_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_guild_before_pop;