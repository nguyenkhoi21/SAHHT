---  雇佣界面

local game_serverGuild_employo_pop = {
    m_tGameData = nil,
    m_label_num = nil,
    m_label_price1 = nil,
    m_curPrice = nil,
    m_tab_ui = nil,
    m_isManage = nil,
};
--[[--
    销毁ui
]]
function game_serverGuild_employo_pop.destroy(self)
    -- body
    cclog("-----------------game_serverGuild_employo_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_label_num = nil;
    self.m_label_price1 = nil;
    self.m_curPrice = nil;
    self.m_tab_ui = nil;
    self.m_isManage = nil;
   
end
--[[--
    返回
]]
function game_serverGuild_employo_pop.back(self,backType)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("game_serverGuild_employo_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_serverGuild_employo_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag === ")
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 or btnTag == 102 then
            if self.m_isManage then
                local function responseMethod( tag,gameData )
                    -- cclog2(gameData,"gameData -------- ")
                    game_scene:addPop("game_serverGuild_enterMember_pop",{gameData = gameData})
                end
                -- local params = {}
                -- params.coin = self.m_curPrice
                -- params.num = 2
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_employ_ground"), http_request_method.GET, params,"new_guild_fight_employ_ground")
            else
                game_util:addMoveTips({text = "您不是公会管理人员，无法进行此操作"})
            end
        elseif btnTag == 103 then
            if self.m_curPrice > self.m_tGameData.pub_info.coin then
                if self.m_curPrice > 1 then
                    self.m_curPrice = self.m_curPrice - 50
                    self:refreshUi()
                end
            else
                -- game_util:addMoveTips({text = "再点就打死你"})
            end
        elseif btnTag == 104 then 
            if self.m_curPrice < 500 then
                self.m_curPrice = self.m_curPrice + 50
                self:refreshUi()
            end
        elseif btnTag == 105 then
            if self.m_isManage then
                local function responseMethod( tag,gameData )
                    game_util:addMoveTips({text = "雇佣信息已成功发布"})
                    -- cclog2(gameData,"gameData ==== ")
                    self:back()
                end
                local params = {}
                params.coin = self.m_curPrice
                params.num = 2
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_pub_employ_message"), http_request_method.GET, params,"new_guild_fight_pub_employ_message")
            else
                game_util:addMoveTips({text = "您不是公会管理人员，无法进行此操作"})
            end
        elseif btnTag == 200 then --解锁
            if self.m_isManage then
                local function responseMethod( tag,gameData )
                    if gameData ~= nil and tolua.type(gameData) == "util_json" then
                        self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer());
                        self:refreshUi()
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_unlock_pos"), http_request_method.GET, params,"new_guild_fight_unlock_pos")
                
            else
                game_util:addMoveTips({text = "您不是公会管理人员，无法进行此操作"})
            end
            elseif btnTag == 999 then 
            game_util:addMoveTips({text = "该位置您已确定人选，不可以重新选择。"})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_serverGuild_employ.ccbi");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    local m_btn_noSelect1 = ccbNode:controlButtonForName("m_btn_noSelect1")
    m_btn_noSelect1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    local m_btn_sure = ccbNode:controlButtonForName("m_btn_sure")
    m_btn_sure:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    local m_btn_noSelect2 = ccbNode:controlButtonForName("m_btn_noSelect2")
    m_btn_noSelect2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
   --[[
    game_util:setCCControlButtonBackground(m_btn_noSelect2,"ui_serverGuild_mylogbtnBg.png")
    m_btn_noSelect2:setTag(101)
    ]] 
    self.m_tab_ui = {}
    local m_btn_noSelect,m_sprite_lock = nil,nil
    for i=1,2 do
        m_btn_noSelect = ccbNode:controlButtonForName("m_btn_noSelect" .. i)
        m_btn_noSelect:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
        m_btn_noSelect:setTag(200)
        m_sprite_lock = ccbNode:spriteForName("m_sprite_lock" .. i)
        self.m_tab_ui[i] = {m_btn_noSelect = m_btn_noSelect, m_sprite_lock = m_sprite_lock} 
    end
    -- cclog2(self.m_tab_ui,"m_tab_ui ==== ")
    local m_btn_add = ccbNode:controlButtonForName("m_btn_add")
    local m_btn_reduce = ccbNode:controlButtonForName("m_btn_reduce")
    m_btn_add:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    m_btn_reduce:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    m_btn_add:setOpacity(0)
    m_btn_reduce:setOpacity(0)



    local function onTouch( eventType, x, y )
        if eventType == "began" then
            return true;--intercept event
        end
    end
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    m_root_layer:registerScriptTouchHandler(onTouch, false, GLOBAL_TOUCH_PRIORITY-1, true)
    m_root_layer:setTouchEnabled(true);
    self.m_label_num = ccbNode:labelTTFForName("m_label_num")
    
    self.m_label_price1 = ccbNode:labelTTFForName("m_label_price1")
    return ccbNode;
end

function game_serverGuild_employo_pop.createProgress( self, parentNode )
    local expBg = parentNode
    local expBgSize = expBg:getContentSize(); 
    local current_score = 1

    local score_max = 2
    local percentage = current_score/score_max * 100 
    local label_exp = self.m_ccbNode:labelTTFForName("m_label_exp") 
    local params = {}
    params.percentage = percentage
    params.fileName = "ui_serverGuild_employJindutiao1.png"
    local expBarAdd = game_util:createProgressTimer(params)
    expBg:removeAllChildrenWithCleanup(true)
    expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
    expBg:addChild(expBarAdd,2,1);
end

--[[--
    刷新ui
]]
function game_serverGuild_employo_pop.refreshUi(self)

    self.m_label_price1:setString("Giá thuê:" .. self.m_curPrice)
    local alreadyNum = 0
    for i=1,tonumber(self.m_tGameData.pub_employ_num) do
        self.m_tab_ui[i].m_sprite_lock:setVisible(false)
        if self.m_tGameData.employed and self.m_tGameData.employed[i] then --该位置已经雇佣人了
            alreadyNum = alreadyNum + 1
            game_util:setCCControlButtonBackground(self.m_tab_ui[i].m_btn_noSelect,"ui_serverGuild_mylogbtnBg.png")
            self.m_tab_ui[i].m_btn_noSelect:setTag(999)
            game_util:setCCControlButtonTitle(self.m_tab_ui[i].m_btn_noSelect,self.m_tGameData.employed[i].name)
        else 
            game_util:setCCControlButtonBackground(self.m_tab_ui[i].m_btn_noSelect,"ui_serverGuild_employBtnSelect.png")
            game_util:setCCControlButtonTitle(self.m_tab_ui[i].m_btn_noSelect,"")
            self.m_tab_ui[i].m_btn_noSelect:setTag(i + 100)
        end
    end
    self.m_label_num:setString("公会当前拥有" .. self.m_tGameData.coin .. "钻石")
end
--[[--
    初始化
]]
function game_serverGuild_employo_pop.init(self,t_params)
    self.m_curPrice = 0
    t_params = t_params or {};
    -- body
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer());
    end
    if self.m_tGameData.pub_info and next(self.m_tGameData.pub_info) then
        self.m_curPrice = tonumber(self.m_tGameData.pub_info.coin)
    end
    self.m_isManage = self.m_tGameData.is_owner
    -- if t_params.isManage then
    --     self.m_isManage = t_params.isManage
    -- end
    -- cclog2(t_params.isManage,"t_params.isManage == = ")
    -- cclog2(self.m_tGameData,"m_tGameData ==== ")
end

--[[--
    创建ui入口并初始化数据
]]
function game_serverGuild_employo_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_serverGuild_employo_pop;