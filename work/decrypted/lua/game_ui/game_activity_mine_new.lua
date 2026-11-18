---  新挖矿

local game_activity_mine_new = {
    m_tGameData = nil,
    m_score_label = nil,
    m_mine_mun_label = nil,
    m_tips_label_1 = nil,
    m_tips_label_2 = nil,
    m_tips_label_3 = nil,
    m_hp_label = nil,
    m_tips_label_11 = nil,
    m_tips_label_12 = nil,
    m_tips_label_13 = nil,
    m_combat_label = nil,
};
--[[--
    销毁ui
]]
function game_activity_mine_new.destroy(self)
    -- body
    cclog("-----------------game_activity_mine_new destroy-----------------");
    self.m_tGameData = nil
    self.m_score_label = nil
    self.m_mine_mun_label = nil
    self.m_tips_label_1 = nil
    self.m_tips_label_2 = nil
    self.m_tips_label_3 = nil
    self.m_hp_label = nil
    self.m_tips_label_11 = nil
    self.m_tips_label_12 = nil
    self.m_tips_label_13 = nil
    self.m_combat_label = nil
end
--[[--
    返回
]]
function game_activity_mine_new.back(self,backType)
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"});
end
--[[--
    读取ccbi创建ui
]]
function game_activity_mine_new.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back()
        elseif btnTag == 101 then--排行榜
            local function responseMethod(tag,gameData)
               game_scene:addPop("game_activity_mine_rank_pop",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("mining_get_score_rank"), http_request_method.GET, nil,"mining_get_score_rank")
        elseif btnTag == 102 then--详细
            game_scene:addPop("game_activity_mine_detail_pop")
        elseif btnTag == 103 then
            game_scene:enterGameUi("game_activity_mine_shop",{gameData = self.m_tGameData});
        elseif btnTag == 104 then
            local function enterStage()
                local function responseMethod(tag,gameData)
                   game_scene:enterGameUi("game_activity_mine_game",{gameData = gameData});
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("mining_enter_stage"), http_request_method.GET, nil,"mining_enter_stage")
            end
            local remain_num = self.m_tGameData.remain_num or 0
            local is_end = self.m_tGameData.is_end or 0
            if is_end == 0 and remain_num < 1 then
                local canBuy,payValue = game_util:getCostCoinBuyTimes("33")
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        game_util:closeAlertView()
                        local function responseMethod(tag,gameData)
                            self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                            self:refreshUi()
                            game_util:addMoveTips({text = "Mua số lần thành công！"})--购买次数成功
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("mining_vip_pay_nums"), http_request_method.GET, nil,"mining_vip_pay_nums")
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,       --可缺省
                    cancelBtnText = string_config.m_btn_cancel,
                    text = "Xác nhận dùng" .. tostring(payValue) .. "xu mua 1 lần thám hiểm？",      --可缺省  是否花费   钻石购买一次探险吗？
                    onlyOneBtn = false,
                    touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                }
                game_util:openAlertView(t_params)
                return
            end
            enterStage()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_activity_mine_new.ccbi");
    self.m_score_label = ccbNode:labelTTFForName("m_score_label")
    self.m_mine_mun_label = ccbNode:labelTTFForName("m_mine_mun_label")
    self.m_tips_label_1 = ccbNode:labelTTFForName("m_tips_label_1")
    self.m_tips_label_2 = ccbNode:labelTTFForName("m_tips_label_2")
    self.m_tips_label_3 = ccbNode:labelTTFForName("m_tips_label_3")
    self.m_hp_label = ccbNode:labelTTFForName("m_hp_label")
    self.m_tips_label_11 = ccbNode:labelTTFForName("m_tips_label_11")
    self.m_tips_label_12 = ccbNode:labelTTFForName("m_tips_label_12")
    self.m_tips_label_13 = ccbNode:labelTTFForName("m_tips_label_13")
    self.m_combat_label = ccbNode:labelTTFForName("m_combat_label")
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_activity_mine_new.refreshUi(self)
    local daily_score = self.m_tGameData.daily_score or 0
    local remain_num = self.m_tGameData.remain_num or 0
    local hero_heart = self.m_tGameData.hero_heart or 0
    local hero_cur_atk = self.m_tGameData.hero_cur_atk or 0
    local hero_atk = self.m_tGameData.hero_atk or 0
    local add_heart_rate = self.m_tGameData.add_heart_rate or 0
    local atk_rate = self.m_tGameData.atk_rate or 0
    local level = game_data:getUserStatusDataByKey("level") or 1;
    self.m_score_label:setString(tostring(daily_score))
    self.m_mine_mun_label:setString("Số lần khai thác còn lại hôm nay：" .. tostring(remain_num))--今日剩余开采次数
    local hero_heart_temp,_ = game_util:formatValueToString(hero_heart,true)
    self.m_tips_label_3:setString(tostring(level) .. "*" .. tostring(add_heart_rate) .. " = Sinh mệnh" .. tostring(hero_heart_temp)) --生命力
    self.m_hp_label:setString(tostring(hero_heart_temp))
    local tempValue,_ = game_util:formatValueToString(hero_cur_atk,true)
    local tempValue2,_ = game_util:formatValueToString(hero_atk,true)
    local tempValue3,_ = game_util:formatValueToString(atk_rate,true)
    self.m_tips_label_13:setString(tostring(level) .. "+" .. tostring(tempValue) .. "/" .. tostring(tempValue3) .. " = Tấn công" .. tostring(tempValue2))  --攻击力
    self.m_combat_label:setString(tostring(tempValue2))
end
--[[--
    初始化
]]
function game_activity_mine_new.init(self,t_params)
    t_params = t_params or {};
    local gameData = t_params.gameData
    if tolua.type(gameData) == "util_json" then
        self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
    else
        self.m_tGameData = {}
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_activity_mine_new.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_activity_mine_new;