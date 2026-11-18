---  跨服擂台赛报名
local game_league_signup = {
    m_tGameData = nil,

    countdown_tips = nil,
    league_type = nil,
    league_rank = nil,
    countdown_node = nil,
    sprite_change =nil,
    syn_node = nil,
};
--[[--
    销毁ui
]]
function game_league_signup.destroy(self)
    cclog("----------------- game_league_signup destroy-----------------"); 
    self.m_tGameData = nil;

    self.countdown_tips = nil;
    self.league_type = nil;
    self.league_rank = nil;
    self.countdown_node = nil;
    self.sprite_change = nil;
    self.syn_node = nil;
end
--[[--
    返回
]]
function game_league_signup.back(self)
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_league_signup.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- print("press button tag is ", btnTag)
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 101 then--排行榜
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_league_rank",{gameData = gameData,enterType = "game_league_signup"})                
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_get_team_rank"), http_request_method.GET, {page = 1},"world_one_get_team_rank")
        elseif btnTag == 102 then
            if self.m_tGameData.stage == 1 then--报名
                local function responseMethod(tag,gameData)
                    game_util:addMoveTips({text = "Đăng kí thành công"}) --报名成功！
                    local data = gameData:getNodeWithKey("data");
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_enroll"), http_request_method.GET, nil,"world_one_enroll")
            elseif self.m_tGameData.stage == 3 then--进入联赛
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_league_main",{gameData = gameData})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_enter_game"), http_request_method.GET, nil,"world_one_enter_game")
            elseif self.m_tGameData.stage == 5 then--不让进
                game_util:addMoveTips({text = "Vòng đấu đã kết thúc"}) --联赛已经结束！
            end
        elseif btnTag == 103 then--同步数据
            if self.m_tGameData.syn_time > 0 then
                local function responseMethod(tag,gameData)
                    game_util:addMoveTips({text = "Tăng tốc thành công!"}) --加速成功！
                    local data = gameData:getNodeWithKey("data");
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    game_util:closeAlertView();
                    self:refreshUi()
                end
                local canBuy,payValue = game_util:getCostCoinBuyTimes(35)
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_remove_syn_time"), http_request_method.GET, nil,"world_one_remove_syn_time")
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,       --可缺省
                    cancelBtnText = string_config.m_btn_cancel,
                    text = "Xác nhận dùng" .. payValue .. "Xu tăng tốc",      --可缺省 是否花费 钻石来加速？
                    onlyOneBtn = false,
                    touchPriority = GLOBAL_TOUCH_PRIORITY-20,
                }
                game_util:openAlertView(t_params);
            else
                local function responseMethod(tag,gameData)
                    game_util:addMoveTips({text = "Tư liệu đồng bộ thành công."}) --同步数据成功！
                    local data = gameData:getNodeWithKey("data");
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_syn_user_info"), http_request_method.GET, nil,"world_one_syn_user_info")
            end
        elseif btnTag == 2 then--奖励
            game_scene:addPop("game_league_reward_pop",{})
        elseif btnTag == 3 then--兑换
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_league_shop",{gameData = gameData,enterType = "game_league_signup"})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_one_exchange_index"), http_request_method.GET, nil,"world_one_exchange_index")
        elseif btnTag == 4 then--说明
            game_scene:addPop("game_active_limit_detail_pop",{ enterType = "151"})
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_league_signup.ccbi");

    self.countdown_tips = ccbNode:spriteForName("countdown_tips")
    self.league_type = ccbNode:labelTTFForName("league_type")
    self.league_rank = ccbNode:labelTTFForName("league_rank")
    self.countdown_node = ccbNode:nodeForName("countdown_node")
    self.sprite_change = ccbNode:spriteForName("sprite_change")
    self.syn_node = ccbNode:nodeForName("syn_node")
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_league_signup.refreshUi(self)
    self.league_rank:setString(self.m_tGameData.win_times)
    self.countdown_node:removeAllChildrenWithCleanup(true)
    local function timeOverCallFun()
        self:back()
        game_util:addMoveTips({text = "Giai đoạn này đã kết thúc, vui lòng đợi"}) --本阶段已结束，请等待！
    end
    local timeLabel = game_util:createCountdownLabel(self.m_tGameData.time_count_down,timeOverCallFun,12,3)
    timeLabel:setAnchorPoint(ccp(0.5,0.5))
    timeLabel:setColor(ccc3(190,253,60))
    timeLabel:setPosition(ccp(0,0))
    self.countdown_node:addChild(timeLabel)

    local stage_name = {"Thanh Đồng","Bạch Ngân","Hoàng Kim"} --青铜 白银 黄金
    if self.m_tGameData.stage_id > 0 then
        self.league_type:setString(stage_name[self.m_tGameData.stage_id])
    else
        self.league_type:setString("Thanh Đồng")
    end
    --stage  1  报名  3  战斗   5   结算   2、4提示不让进
    local tempSpriteFrame = nil
    local changeSpriteFrame = nil
    if self.m_tGameData.stage == 1 then
        tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_league_l_signup.png")
        if self.m_tGameData.is_enroll == true then--已报名
            changeSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_lleague_b_signed.png")
        else
            changeSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_lleague_b_sign.png")
        end
    elseif self.m_tGameData.stage == 3 then
        tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_league_l_active.png")
        changeSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_league_b_in.png")
    elseif self.m_tGameData.stage == 5 then
        tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_league_l_end.png")
        changeSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_league_b_in.png")
    end
    if tempSpriteFrame then
        self.countdown_tips:setDisplayFrame(tempSpriteFrame)
    end
    if changeSpriteFrame then
        self.sprite_change:setDisplayFrame(changeSpriteFrame)
    end

    --同步倒计时
    self.syn_node:removeAllChildrenWithCleanup(true)
    if self.m_tGameData.syn_time > 0 then
        local function timeOverCallFun2()
            self.m_tGameData.syn_time = 0
            self.syn_node:removeAllChildrenWithCleanup(true)
        end
        local timeLabel2 = game_util:createCountdownLabel(self.m_tGameData.syn_time,timeOverCallFun2)

        timeLabel2:setAnchorPoint(ccp(0.5,0.5))
        timeLabel2:setColor(ccc3(190,253,60))
        timeLabel2:setPosition(ccp(0,0))
        self.syn_node:addChild(timeLabel2)
    end
end
--[[--
    初始化
]]
function game_league_signup.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_league_signup.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_league_signup