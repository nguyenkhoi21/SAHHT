--- 新神域竞技场  二级界面

local game_godfield_pvp_new_sec = {
    m_tGameData = nil,
    m_close_btn = nil,
    m_ccbNode = nil,
    m_my_score = nil,
    m_all_count = nil,
    m_win = nil,
    m_fail = nil,
    m_shenglv = nil,
    m_my_rank = nil,
    m_next_score = nil,
    m_next_score2 = nil,
    m_zhenxing_node = nil,
    m_next_node = nil,
    m_my_combat = nil,
    enemy_info = nil,
    battle_flag = nil,
    btnFlag = nil,
    m_enterType = nil,
    m_zhushi= nil,
};
--[[--
    销毁
]]
function game_godfield_pvp_new_sec.destroy(self)
    -- body
    cclog("-----------------game_godfield_pvp_new_sec destroy-----------------");
    self.m_tGameData = nil;
    self.m_close_btn = nil;
    self.m_ccbNode = nil;
    self.m_my_score = nil;
    self.m_all_count = nil;
    self.m_win = nil;
    self.m_fail = nil;
    self.m_shenglv = nil;
    self.m_my_rank = nil;
    self.m_next_score = nil;
    self.m_next_score2 = nil;
    self.m_zhenxing_node = nil;
    self.m_next_node = nil;
    self.m_my_combat = nil;
    self.enemy_info = nil;
    self.battle_flag = nil;
    self.btnFlag = nil;
    self.m_enterType = nil;
    self.m_zhushi = nil;
    cclog("======================game_godfield_pvp_new_sec destroy=======================")
end
--[[--
    返回
]]
function game_godfield_pvp_new_sec.back(self,type)
    if self.m_shared then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared);
    end


    local function responseMethod( tag,gameData )
        game_scene:enterGameUi("game_godfield_pvp_new",{gameData = gameData})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_index"), http_request_method.GET, {},"universe_arena_index")

end
--[[--
    读取ccbi创建ui
]]
function game_godfield_pvp_new_sec.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 11 then --匹配
            if self.m_begin_pk then
                if self.m_isCanBegin then
                    game_util:addMoveTips({text = "Đã bắt cặp thành công, đang vào chiến đấu"})
                else
                    if self.m_shared then
                        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared);
                    end
                    self.m_timer_lb:setVisible(false)
                    self.m_pipeizi_lb:setVisible(false)
                    game_util:setCCControlButtonBackground(self.m_btn_pk,"pvp_sec_btn_begin.png")
                    self.m_touch_layer:setTouchEnabled(false)
                    self.m_touch_layer:setVisible(false)
                    self.m_begin_pk = false
                end
            else
                -- game_util:setCCControlButtonBackground(self.m_btn_pk,"pvp_sec_btn_cancel.png")
                -- self.m_touch_layer:setTouchEnabled(true)
                -- self.m_touch_layer:setVisible(true)
                -- self.m_begin_pk = true
                self:beginBattle()
            end
        elseif btnTag == 13 then --阵型
            local function responseMethod( tag,gameData )
                game_scene:enterGameUi("game_godfield_pvp_new_adjust",{gameData = gameData,enterType = "game_godfield_pvp_new_sec",team_index = self.m_enterType})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_upload_god_formation"), http_request_method.GET, nil,"universe_arena_upload_god_formation")
 
        elseif btnTag == 25 then --兑换
            local function responseMethod( tag,gameData )
                game_scene:addPop("game_godfield_pvp_new_shop",{gameData = gameData,enterType = self.m_enterType})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_shop_index"), http_request_method.GET, {team_id = self.m_enterType},"universe_arena_shop_index")
        elseif btnTag == 24 then --排行
            local function responseMethod( tag,gameData )
                game_scene:addPop("game_godfield_pvp_new_rank",{gameData = gameData,enterType = self.m_enterType})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_get_rank_info"), http_request_method.GET, nil,"universe_arena_get_rank_info")
 
        elseif btnTag == 23 then --对战记录
            local function responseMethod( tag,gameData )
                game_scene:addPop("game_godfield_pvp_new_battleMsg",{gameData = gameData,enterType = self.m_enterType})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_get_battle_tips"), http_request_method.GET, {team_id = self.m_enterType},"universe_arena_get_battle_tips")
        elseif btnTag == 22 then --评分奖励
            local function responseMethod( tag,gameData )
                game_scene:addPop("game_godfield_pvp_new_score_rew",{gameData = gameData,enterType = self.m_enterType,team_score = self.m_tGameData.my_score})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_secore_reward_index"), http_request_method.GET, {team_id = self.m_enterType},"universe_arena_secore_reward_index")
        elseif btnTag == 21 then --排名奖励
            local function responseMethod( tag,gameData )
                game_scene:addPop("game_godfield_pvp_new_rank_rew",{gameData = gameData,enterType = self.m_enterType})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_get_rank_info"), http_request_method.GET, nil,"universe_arena_get_rank_info")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_Arena_new_sec.ccbi");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/god_pvp.plist");
    self.m_close_btn = ccbNode:controlButtonForName("m_back_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY)
    local m_theme_spriteFrame = {"pvp_main_p","pvp_main_w","pvp_main_h"}
    local m_theme_sp = ccbNode:spriteForName("m_theme_sp")
    local m_theme_sp2 = ccbNode:spriteForName("m_theme_sp2")
    local tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(m_theme_spriteFrame[self.m_enterType] .. "1.png"))
    local tempSpriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(m_theme_spriteFrame[self.m_enterType] .. "2.png"))
  	if tempSpriteFrame1 and tempSpriteFrame2 then
     	m_theme_sp:setDisplayFrame(tempSpriteFrame1)
     	m_theme_sp2:setDisplayFrame(tempSpriteFrame2)
  	end

    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    
    self.m_my_score = ccbNode:labelTTFForName("m_my_score")
    self.m_all_count = ccbNode:labelTTFForName("m_all_count")
    self.m_win = ccbNode:labelTTFForName("m_win")
    self.m_fail = ccbNode:labelTTFForName("m_fail")
    self.m_shenglv = ccbNode:labelTTFForName("m_shenglv")
    self.m_my_rank = ccbNode:labelTTFForName("m_my_rank")
    self.m_next_score = ccbNode:labelTTFForName("m_next_score")
    self.m_next_score2 = ccbNode:labelTTFForName("m_next_score2")
    self.m_zhenxing_node = ccbNode:nodeForName("m_zhenxing_node")
    self.m_next_node = ccbNode:nodeForName("m_next_node")
    self.m_my_combat = ccbNode:labelTTFForName("m_my_combat")
    -- self.m_zhushi =ccbNode:layerForName("m_zhushi")

    self.m_pipeizi_lb = ccbNode:labelTTFForName("m_pipeizi_lb")
    self.m_timer_lb = ccbNode:labelTTFForName("m_timer_lb")
    self.m_pipeizi_lb:setVisible(false)
    self.m_timer_lb:setVisible(false)

    for i=1,6 do
        local tempBtn = ccbNode:controlButtonForName("m_main_btn" .. i)
        if tempBtn then
            tempBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY)
        end
    end

    self.m_btn_pk = ccbNode:controlButtonForName("m_btn_pk")
    self.m_btn_pk:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_touch_layer = ccbNode:layerForName("m_touch_layer");
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        elseif eventType == "ended" then
        end
    end
    self.m_touch_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    self.m_touch_layer:setTouchEnabled(false);
    self.m_touch_layer:setVisible(false);


    self.m_ccbNode = ccbNode;
    return ccbNode;
end

function game_godfield_pvp_new_sec:battleAgain()
    local function responseMethod( tag,gameData )
        if gameData then
            local data = gameData:getNodeWithKey("data")
            local battle = data:getNodeWithKey("battle")
            if battle then
                return true,gameData
            else
                return false
            end
        else
            return false
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_universe_arena_battle"), http_request_method.GET, {team_id = self.m_enterType},"universe_arena_universe_arena_battle",false)
end

function game_godfield_pvp_new_sec:beginBattle()



            local function responseMethod( tag,gameData )

                game_util:setCCControlButtonBackground(self.m_btn_pk,"pvp_sec_btn_cancel.png")
                self.m_touch_layer:setTouchEnabled(true)
                self.m_touch_layer:setVisible(true)
                self.m_begin_pk = true

                self.m_pipeizi_lb:setVisible(true)
                self.m_timer_lb:setVisible(true)
            
                local data = gameData:getNodeWithKey("data")
                local battle = data:getNodeWithKey("battle")
                local count = 0
                local str = "."
                self.m_lastBeginTime = 0
                self.m_newBeginTime = 10
                self.m_timer_lb:setString("0 Giây (Dự tính" .. self.m_newBeginTime .. " giây)")
                if not battle then
                    self.m_isCanBegin = false
                    self.m_begin_time = self.m_newBeginTime
                else
                    self.m_battleData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) 
                    self.m_begin_time = math.random(self.m_lastBeginTime+1,self.m_newBeginTime-5)
                    self.m_isCanBegin = true
                end
                cclog("    self.m_begin_time ===== " .. self.m_begin_time)
                local function tick(dt)
                    count = count + 1
                    if str == "." then
                        str = ".."
                    elseif str == ".." then
                        str = "..."
                    elseif str == "..." then
                        str = "."
                    end
                    self.m_pipeizi_lb:setString("Đang bắt cặp" .. str)
                    self.m_timer_lb:setString(count .. "Giây (Dự tính" .. self.m_newBeginTime .. " giây)")
                    if self.m_isCanBegin then
                        if count == self.m_begin_time then
                            if self.m_shared then
                                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared);
                            end
                            self.m_pipeizi_lb:setVisible(false)
                            self.m_timer_lb:setVisible(false)
                            game_util:addMoveTips({text = "Bắt đầu"})
                            game_scene:addPop("game_godfield_pvp_new_battle",{gameData = self.m_battleData,enterType = self.m_enterType})
                        end
                    else
                        if count == self.m_newBeginTime then
                            if self.m_newBeginTime >59 then
                                if self.m_shared then
                                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared);
                                end
                                self.m_pipeizi_lb:setVisible(false)
                                self.m_timer_lb:setVisible(false)
                                game_util:setCCControlButtonBackground(self.m_btn_pk,"pvp_sec_btn_begin.png")
                                self.m_touch_layer:setTouchEnabled(false)
                                self.m_touch_layer:setVisible(false)
                                self.m_begin_pk = false
                                game_util:addMoveTips({text = "Lần này bắt cặp thất bại, hãy thử lại"})  
                                return
                            end

                            local flag,data = self:battleAgain()
                               self.m_isCanBegin = flag
                            if flag then
                                self.m_battleData = json.decode(data:getNodeWithKey("data"):getFormatBuffer())
                                self.m_lastBeginTime = self.m_newBeginTime
                                self.m_newBeginTime = self.m_newBeginTime + 10
                                self.m_begin_time = math.random(self.m_lastBeginTime+1,self.m_newBeginTime-5)
                            else
                                self.m_lastBeginTime = self.m_newBeginTime
                                self.m_newBeginTime = self.m_newBeginTime + 10
                                self.m_begin_time = self.m_newBeginTime
                            end
                        end
                    end

                end
                self.m_shared = scheduler.schedule(tick, 1, false)
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("universe_arena_universe_arena_battle"), http_request_method.GET, {team_id = self.m_enterType},"universe_arena_universe_arena_battle")
end

function game_godfield_pvp_new_sec:addAnim(tempSp)
    local animArr = CCArray:create();
    animArr:addObject(CCFadeTo:create(1,70))
    animArr:addObject(CCFadeTo:create(1,255))
    tempSp:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
end
function game_godfield_pvp_new_sec:addAnim1(tempSp)
    local animArr = CCArray:create();
    animArr:addObject(CCFadeTo:create(1,200))
    animArr:addObject(CCFadeTo:create(1,50))
    animArr:addObject(CCFadeTo:create(1,255))
    tempSp:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
end
function game_godfield_pvp_new_sec:addAnim2(tempSp)
    local animArr = CCArray:create();
    animArr:addObject(CCFadeTo:create(1,100))
    animArr:addObject(CCFadeTo:create(1,255))
    animArr:addObject(CCFadeTo:create(1,200))
    tempSp:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
end

function game_godfield_pvp_new_sec:createZhenrongList()
    local position_x = {
        {0.5,},
        {0.35,0.65},
        {0.25,0.5,0.75},
        {0.2,0.4,0.6,0.8},
        {0.1,0.3,0.5,0.7,0.9},
    }
    local show_list = {}
    for k,v in pairs(self.m_tGameData.god_field_ids) do
        if v~="-1" and v ~= "0" then
            show_list[#show_list+1] = v
        end
    end
    local sPosition_x = position_x[#show_list]
    local viewSize = self.m_zhenxing_node:getContentSize()
    for i=1,#show_list do
        local itemData,itemCfg = game_data:getCardDataById(show_list[i])
        local headIconSpr = game_util:createCardIconByCid(itemData.c_id,itemData);
        headIconSpr:setScale(0.7)
        local function onBtnCilck( event,target )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            local itemData = game_data:getCardDataById(show_list[btnTag])
            if itemData then
                game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 3})
            end
        end
        local ccb = luaCCBNode:create()
        ccb:openCCBFile("ccb/ui_godfield_dart_zhenrong_item.ccbi")
        local icon_node = ccb:nodeForName("icon_node")
        icon_node:addChild(headIconSpr,1001,1001)
        headIconSpr:setAnchorPoint(ccp(0.5,0.5))
        headIconSpr:setPosition(ccp(0,0))
        ccb:setAnchorPoint(ccp(0.5,0.5))
        ccb:setPosition(ccp(viewSize.width*sPosition_x[i],viewSize.height*0.5))
        self.m_zhenxing_node:addChild(ccb)
        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        button:setOpacity(0)
        button:setTag(i)
        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY)
        button:setAnchorPoint(ccp(0.5,0.5))
        button:setPosition(ccp(0,0))
        icon_node:addChild(button); 
    end
end


function game_godfield_pvp_new_sec.refreshUi( self )
    -- body  
    local lv1,lv2,next_score = self:getLevel(self.m_tGameData.my_score)
    local m_main_sp = self.m_ccbNode:spriteForName("m_main_sp")
    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring("pvp_sec_icon" .. lv1 .. ".png"))
    if tempSpriteFrame then
        m_main_sp:setDisplayFrame(tempSpriteFrame)
    end
    local m_icon_di_node = self.m_ccbNode:nodeForName("m_icon_di_node")
    m_icon_di_node:removeAllChildrenWithCleanup(true)
    local tempS = CCSprite:create("ccbResources/ui_pvp_sec_guang" .. lv1 .. ".png")
    m_icon_di_node:addChild(tempS,1,1)

    -- if self.m_tGameData.fight_flag == 0 then --注释
    --     self.m_zhushi:setVisible(true)
    -- else
    --     self.m_zhushi:setVisible(false)
    -- end
    for i=1,5 do
        local xing_sp = self.m_ccbNode:spriteForName("m_xing_sp" .. i)
        if lv2 >= i then
            self:refreshXing(true,xing_sp,i)
        else
            self:refreshXing(false,xing_sp,i)
        end
    end
    if next_score ~= 0 then
        self.m_next_score:setString(tostring(next_score) .. "Điểm")
        self.m_next_score2:setString(tostring(next_score) .. "Điểm")
        self.m_next_node:setVisible(true)
    else
        self.m_next_node:setVisible(false)
    end
    self.m_my_score:setString(self.m_tGameData.my_score or "0")
    local all_count = self.m_tGameData.vin_times + self.m_tGameData.fail_times
    self.m_all_count:setString(tostring(all_count))
    self.m_win:setString(tostring(self.m_tGameData.vin_times))
    self.m_fail:setString(tostring(self.m_tGameData.fail_times))
    local shenglv = 0
    if all_count ~= 0 and self.m_tGameData.vin_times ~= 0 then
        shenglv = math.floor((self.m_tGameData.vin_times/all_count)*100)
    end
    self.m_shenglv:setString(tostring(shenglv) .. "%")
    self.m_my_rank:setString(self.m_tGameData.my_rank)
    self.m_zhenxing_node:removeAllChildrenWithCleanup(true)
    self:createZhenrongList()

    self.m_my_combat:setString(self.m_tGameData.combat or 0)
end

function game_godfield_pvp_new_sec:refreshXing(flag,xing_sp,index)
    local fileName = "pvp_sec_xingxing" .. (index == 3 and "1" or "2")
    fileName = fileName .. (flag and "2" or "1")
    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(fileName .. ".png")
    if tempSpriteFrame and xing_sp then
        xing_sp:setDisplayFrame(tempSpriteFrame)
    end

end

function game_godfield_pvp_new_sec:getLevel(myscore)
    myscore = myscore or self.m_tGameData.my_score
    local level = 0
    local next_score = 0
    local universe_arena_grade_cfg = getConfig(game_config_field.universe_arena_grade)
    universe_arena_grade = json.decode(universe_arena_grade_cfg:getFormatBuffer())
    for k,v in pairs(universe_arena_grade) do
        cclog2(k)
        local score = v.score
        if (score[1] <= myscore)  and myscore <= score[2] then
            level = k
            local next_l = universe_arena_grade[tostring(tonumber(k)+1)]
            if next_l~=nil then
                next_score = next_l.score[1]
            end
        end
    end
    local lv1 = math.ceil(level/5)
    local lv2 = level%5
    return lv1,lv2,next_score
end

--[[--
    初始化
]]
function game_godfield_pvp_new_sec.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        cclog2(self.m_tGameData)
    else
        self.m_tGameData = {};
    end

-- cclog2(self.m_tGameData,"self.m_tGameData-=---------")
    self.enemy_info = {}
    self.battle_flag = false;
    self.btnFlag = false;
    self.m_begin_pk = false;
    self.m_enterType = t_params.enterType or 1
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_pvp_new_sec.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_godfield_pvp_new_sec;