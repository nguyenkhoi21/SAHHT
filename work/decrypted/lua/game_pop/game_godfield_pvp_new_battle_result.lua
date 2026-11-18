local game_godfield_pvp_new_battle_result = {
	m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_callBackFunc = nil,
    m_tips_label = nil,
}

function game_godfield_pvp_new_battle_result.destroy(self)
    -- body
    cclog("-----------------game_godfield_pvp_new_battle_result destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_callBackFunc = nil;
    self.m_tips_label = nil;
end


function game_godfield_pvp_new_battle_result.back(self,type)
    local function responseMethod( tag,gameData )
        game_scene:enterGameUi("game_godfield_pvp_new_sec",{gameData = gameData,enterType = self.m_tGameData.teamIndex})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_team_index"), http_request_method.GET, {team_id = self.m_tGameData.teamIndex},"universe_arena_team_index")
end


function game_godfield_pvp_new_battle_result.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_Arena_new_battleResult.ccbi");
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    local function onTouch(eventType, x, y)
        if eventType == "began" then
        	self:back()
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    m_root_layer:setTouchEnabled(true);

    self.m_fight_sp = ccbNode:spriteForName("m_result_sp")

    self.m_paiming = ccbNode:labelTTFForName("m_paiming")
    self.m_paiming_lb = ccbNode:labelTTFForName("m_paiming_lb")
    self.m_score_lb = ccbNode:labelTTFForName("m_score_lb")
    self.m_huizhang_lb = ccbNode:labelTTFForName("m_huizhang_lb")
    self.m_paiming_sp = ccbNode:spriteForName("m_paiming_sp")
    self.m_score_sp = ccbNode:spriteForName("m_score_sp")
    self.m_huizhang_sp = ccbNode:spriteForName("m_huizhang_sp")

    self.m_ccbNode = ccbNode;
    return ccbNode;
end



function game_godfield_pvp_new_battle_result.refreshUi(self)
--[[
{
  rank_changed = 0
  isWin        = true
  grade_score  = 22
  teamIndex    = 3
  score        = 14
}
]]

    local result_file,score_file,rank_file = "pvp_jiesuan_faild","pvp_jiesuan_down","pvp_jiesuan_down"
    if self.m_tGameData.isWin == true then
        result_file = "pvp_jiesuan_succ"
	end
    if self.m_tGameData.score >= 0 then
        score_file = "pvp_jiesuan_up"
    end
    if self.m_tGameData.rank_changed >= 0 and self.m_tGameData.isWin == true then
        rank_file = "pvp_jiesuan_up"
    end


    local huizhang_flie = "pvp_shop_icon" .. self.m_tGameData.teamIndex
    local tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(result_file .. ".png"))
    local tempSpriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(score_file .. ".png"))
    local tempSpriteFrame3 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(huizhang_flie .. ".png"))
    local tempSpriteFrame4 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(rank_file .. ".png"))

    if tempSpriteFrame1 then
        self.m_fight_sp:setDisplayFrame(tempSpriteFrame1)
    end

    if tempSpriteFrame2 then
        self.m_score_sp:setDisplayFrame(tempSpriteFrame2)
    end

    if tempSpriteFrame3 then
        self.m_huizhang_sp:setDisplayFrame(tempSpriteFrame3)
    end

    if tempSpriteFrame4 then
        self.m_paiming_sp:setDisplayFrame(tempSpriteFrame4)
    end

	self.m_paiming_lb:setString(self.m_tGameData.rank_changed)
	self.m_score_lb:setString(self.m_tGameData.score)
	self.m_huizhang_lb:setString(self.m_tGameData.grade_score)
end


function game_godfield_pvp_new_battle_result.init(self,t_params)
    t_params = t_params or {};
    self.m_tGameData = game_data:getGodPvpBattleResult()
end


function game_godfield_pvp_new_battle_result.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_pvp_new_battle_result;