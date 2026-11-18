--- 坠落之地
--- 机遇
local game_godfield_guild_high_war_chance_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_select_index = nil,
};

--[[--
    销毁
]]
function game_godfield_guild_high_war_chance_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_chance_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_select_index = nil
end
--[[--
    返回
]]
function game_godfield_guild_high_war_chance_pop.back(self)
    game_scene:removePopByName("game_godfield_guild_high_war_chance_pop");
end

local spr_btns = {
    {{"Aquarius_btn02", "Aquarius_btn01"},{"Aries_btn02", "Aries_btn01"},{"Cancer_btn02", "Cancer_btn01"},{"Capricorn_btn02", "Capricorn_btn01"},{"Gemini_btn02", "Gemini_btn01"}},
    {{"Aquarius_btn04", "Aquarius_btn03"},{"Aries_btn04", "Aries_btn03"},{"Cancer_btn04", "Cancer_btn03"},{"Capricorn_btn04", "Capricorn_btn03"},{"Gemini_btn04", "Gemini_btn03"}},
    {{"Aquarius_btn06", "Aquarius_btn05"},{"Aries_btn06", "Aries_btn05"},{"Cancer_btn06", "Cancer_btn05"},{"Capricorn_btn06", "Capricorn_btn05"},{"Gemini_btn06", "Gemini_btn05"}}
}
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_chance_pop.createUi(self)
    local buildData = self.m_tGameData.info[tostring(self.m_buildingId)]
    self.m_select_index = buildData and buildData.sort ~= 0 and buildData.sort or 1
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag >= 101 and btnTag <= 103 then
            if self.m_select_index ~= btnTag - 100 then
                -- if (self.m_tGameData.max_city_lv >= btnTag - 100) or not self.m_isSelfFlag or (self:getChanceSort() >=  btnTag - 100) then
                    self.m_select_index = btnTag - 100
                    self:refreshUi()
                -- else
                --     game_util:addMoveTips({text = "我方公会占领了"..tostring(btnTag - 100).."级城才可解锁!"});
                -- end
            end
        elseif btnTag == 200 then -- 规则
            local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
            local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(6))
            if itemCfg == nil then return end
            local openMsg = itemCfg:getNodeWithKey("des"):toStr();
            game_scene:addPop("game_godfield_detail_pop",{openMsg = openMsg})
        elseif btnTag >= 301 and btnTag <= 305 then 
            
            local buildData = self.m_tGameData.info[tostring(self.m_buildingId)]
            -- 需判断是否有阵容队伍
            if not buildData then
                return game_util:addMoveTips({text = "Hãy cử đi 1 đội ngũ!"});
            end



            local position_id = btnTag - 300
            if buildData and buildData.sort == self.m_select_index and buildData.position_id == position_id then -- 已探索
                local time = buildData.time 
                local date = os.date("*t", time )
                local next_date = {}
                next_date.year = date.year
                next_date.month = date.month
                next_date.day = date.day + 1
                next_date.hour = 0
                next_date.min = 0
                next_date.sec = 0
                local next_day_time = os.time(next_date)
                local server_time = game_data:getUserStatusDataByKey("server_time")
                local guild_high_war_fate_cfg = getConfig(game_config_field.guild_high_war_fate)
                local fate_cfg = guild_high_war_fate_cfg:getNodeWithKey(buildData.fate_id)
                local type = fate_cfg:getNodeWithKey("type"):toInt()
                next_day_time = server_time
                if next_day_time > server_time then -- 未到出结果时间
                    game_util:addMoveTips({text = "Đang thám hiểm, ngày mai nhận kết quả thám hiểm!"});
                else
                    if buildData.fate_id > 0 then
                        local function callBackFunc(gameData)
                            self.m_tGameData = gameData
                            self:refreshUi()
                        end
                        local fate_cfg = guild_high_war_fate_cfg:getNodeWithKey(tostring(buildData.fate_id))
                        local type = fate_cfg:getNodeWithKey("type"):toInt()
                        game_scene:addPop("game_godfield_guild_high_war_chance_end_pop",{type = type, gift = buildData.gift, buildingId = self.m_buildingId, callBackFunc = callBackFunc, got_reward = self.m_tGameData.got_reward, is_win = buildData.is_win})
                    end
                end
            elseif buildData and buildData.position_id > 0 and buildData.time > 0 and buildData.sort > 0 then -- 已有探索
                local time = buildData.time 
                local date = os.date("*t", time )
                local next_date = {}
                next_date.year = date.year
                next_date.month = date.month
                next_date.day = date.day + 1
                next_date.hour = 0
                next_date.min = 0
                next_date.sec = 0
                local next_day_time = os.time(next_date)
                local server_time = game_data:getUserStatusDataByKey("server_time")
                local guild_high_war_fate_cfg = getConfig(game_config_field.guild_high_war_fate)
                local fate_cfg = guild_high_war_fate_cfg:getNodeWithKey(buildData.fate_id)
                local type = fate_cfg:getNodeWithKey("type"):toInt()
                next_day_time = server_time
                if next_day_time > server_time then -- 未到出结果时间
                    game_util:addMoveTips({text = "Đã có đội ngũ đang thám hiểm!"});
                else
                    game_util:addMoveTips({text = "Hãy xem kết quả thám hiểm trước!"});
                end
            else
                if not self.m_isSelfFlag or self.m_step == 2 or self.m_step == 3  then
                    return game_util:addMoveTips({text = "Chức năng chưa mở!"});
                end

                if self.m_step ~= 4 and self.m_step ~= 5 and self.m_step ~= 7 then
                    return game_util:addMoveTips({text = "Giai đoạn hiện tại không thể thám hiểm!"});
                end 

                if (self.m_tGameData.max_times-self.m_tGameData.times) <= 0 then
                    return game_util:addMoveTips({text = "Số lần thám hiểm đã đạt giới hạn!"});
                end


                -- if self.m_tGameData.max_city_lv < self.m_select_index then
                --     return game_util:addMoveTips({text = "当前城市等级不满足该层探索条件!"});
                -- end

                local need_list = {}
                for k,v in pairs(self.m_fate_list) do
                    if tonumber(v.cfg.sort) == tonumber(self.m_select_index) then
                        need_list = v.cfg.need
                        break
                    end
                end
                local icon,name,count = game_util:getRewardByItemTable(need_list[1], true)

                local function textColorFun(tempId)
                    return "fffba700"
                    -- local item = getConfig(game_config_field.item);
                    -- local itemCfg = item:getNodeWithKey(tostring(tempId));
                    -- local quality = itemCfg:getNodeWithKey("quality"):toInt();
                    -- if quality  then
                    --     return "HERO_QUALITY_COLOR_TABLE[quality].rgba"
                    -- end
                end
                
                local rich_text = ""
                local need_item = need_list[1]
                if game_data:getItemCountByCid(need_list[1][2]) >= need_list[1][3] then
                    rich_text = "Xác nhận dùng".."[color="..textColorFun(need_list[1][2]).."]"..name.."[/color]Đi thám hiểm không?"
                elseif need_list[2] then
                    for i,v in ipairs(need_list) do
                        if i > 1 and game_data:getItemCountByCid(v[2]) >= v[3] then
                            need_item = v
                            break
                        end
                    end
                    local icon,name2,count = game_util:getRewardByItemTable(need_item, true)
                    rich_text = "Xác định dùng huân chương thám hiểm cao cấp hơn".."([color="..textColorFun(need_item[2]).."]"..name2.."[/color])Đi thám hiểm không?"
                end
                
                if game_data:getItemCountByCid(need_item[2]) < need_item[3] then
                    return game_util:addMoveTips({text = "Không đủ đạo cụ để dùng, không thể thám hiểm!"});
                end

                local t_params = 
                    {
                        okBtnCallBack = function(target,event)
                            game_util:closeAlertView();
                            local params = {city_id = self.m_buildingId, sort_id = self.m_select_index, position_id = position_id}
                            local function responseMethod( tag, gameData )
                                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                                    local data = gameData:getNodeWithKey("data");
                                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                                end
                                self:refreshUi()
                            end
                            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_explore"), http_request_method.GET, params,"guild_high_war_explore")
                        end,   --可缺省
                        closeCallBack = function(target,event)
                            game_util:closeAlertView();
                        end,
                        okBtnText = "Xác định",       --可缺省
                        extBtnText = "Hủy",
                        text = "Có tiêu hao không"..name.."Đi thám hiểm không?",      --可缺省
                        rich_text = rich_text
                    }
                game_util:openAlertView(t_params);
            end
        elseif btnTag == 400 then -- 派遣
            if not self.m_isSelfFlag or self.m_step == 2 or self.m_step == 3 then
                return game_util:addMoveTips({text = "Chức năng chưa mở!"});
            end

            if self.m_step ~= 4 and self.m_step ~= 5 and self.m_step ~= 7 then
                return game_util:addMoveTips({text = "Giai đoạn hiện tại không được cử đi!"});
            end
            
            local hide_btn = false
            local buildData = self.m_tGameData.info[tostring(self.m_buildingId)]
            if buildData and buildData.position_id > 0 then -- 已有探索
                local time = buildData.time 
                local date = os.date("*t", time )
                local next_date = {}
                next_date.year = date.year
                next_date.month = date.month
                next_date.day = date.day + 1
                next_date.hour = 0
                next_date.min = 0
                next_date.sec = 0
                local next_day_time = os.time(next_date)
                local server_time = game_data:getUserStatusDataByKey("server_time")
                local guild_high_war_fate_cfg = getConfig(game_config_field.guild_high_war_fate)
                local fate_cfg = guild_high_war_fate_cfg:getNodeWithKey(buildData.fate_id)
                local type = fate_cfg:getNodeWithKey("type"):toInt()

                next_day_time = server_time
                -- if next_day_time > server_time then -- 未到出结果时间
                    hide_btn = true
                -- end
            end
            local function callBackFunc()
                local function responseMethod( tag, gameData )
                    local data = gameData:getNodeWithKey("data");
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_explore_index"), http_request_method.GET, {city_id = self.m_buildingId},"guild_high_war_explore_index")
            end

            local chance_formation_type = 2 -- 入驻
            if self.m_tGameData.info[tostring(self.m_buildingId)] then
                chance_formation_type = 1 -- 离开
            end
            local uid = game_data:getUserStatusDataByKey("uid")
            local function responseMethod( tag, gameData )
                game_scene:addPop("game_godfield_guild_high_war_formation_pop",{gameData = gameData, buildingId = self.m_buildingId, openPopType = "game_godfield_guild_high_war_chance_pop", callBackFunc = callBackFunc, chance_formation_type = chance_formation_type, hide_btn = hide_btn})                  
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_alignment_info"), http_request_method.GET, {t_uid = uid},"guild_high_war_alignment_info")
        elseif btnTag == 500 then -- 奖励预览
            game_scene:addPop("game_godfield_guild_high_war_box_pop",{rewards = self:getShowRewards(), title = "Xem thử phần thưởng"})                  
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_chance_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    self.label_title = ccbNode:labelTTFForName("label_title") 
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    self.m_des_btn = ccbNode:controlButtonForName("m_des_btn")
    self.m_des_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)

    self.m_btn1 = ccbNode:controlButtonForName("m_btn1")
    self.m_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    game_util:setCCControlButtonTitle(self.m_btn1,"Nguyện")
    self.m_btn2 = ccbNode:controlButtonForName("m_btn2")
    self.m_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    game_util:setCCControlButtonTitle(self.m_btn2,"Vận Mệnh")
    self.m_btn3 = ccbNode:controlButtonForName("m_btn3")
    self.m_btn3:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    game_util:setCCControlButtonTitle(self.m_btn3,"Thần Ân")
    
    self.m_des_btn = ccbNode:controlButtonForName("m_des_btn")
    self.m_des_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    self.m_pq_btn = ccbNode:controlButtonForName("m_pq_btn")
    self.m_pq_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    self.m_reward_btn = ccbNode:controlButtonForName("m_reward_btn")
    self.m_reward_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)

    self.label_times = ccbNode:labelTTFForName("label_times") -- 剩余次数

    self.m_qq_btns = {}
    self.m_spr_status = {}
    for i=1,5 do
        self.m_qq_btns[i] = ccbNode:controlButtonForName("m_qq_btn"..i)
        self.m_qq_btns[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
        self.m_spr_status[i] = ccbNode:spriteForName("spr_status"..i)
    end

    self.label_des = ccbNode:labelTTFForName("label_des")
    local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
    local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(13))
    local openMsg = itemCfg:getNodeWithKey("des"):toStr();
    self.label_des:setString(openMsg)

    local guild_high_war_fate_cfg = getConfig(game_config_field.guild_high_war_fate)
    guild_high_war_fate_cfg = json.decode(guild_high_war_fate_cfg:getFormatBuffer()) or {};
    local fate_list = {}
    for k,v in pairs(guild_high_war_fate_cfg) do
        if tostring(v.fate_id) == tostring(self.m_buildingId) then
            table.insert(fate_list, {id = k, cfg = v})
        end
    end
    self.m_fate_list = fate_list
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]


function game_godfield_guild_high_war_chance_pop.refreshUi(self)
    local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)
    local build_info = guild_high_war_build_cfg:getNodeWithKey(self.m_buildingId)
    local city_name = build_info:getNodeWithKey("city_name"):toStr()
    self.label_title:setString(city_name)
    self.m_pq_btn:setVisible(self.m_isSelfFlag)
    self.label_times:setString("Hiện còn"..math.max(self.m_tGameData.max_times-self.m_tGameData.times, 0).."Số lần cơ hội thám hiểm")
    if self.m_select_index == 1 then
        game_util:setCCControlButtonBackground(self.m_btn1,"yq_btn01.png")
        game_util:setCCControlButtonBackground(self.m_btn2,"yq_btn02.png")
        game_util:setCCControlButtonBackground(self.m_btn3,"yq_btn02.png")
    elseif self.m_select_index == 2 then
        game_util:setCCControlButtonBackground(self.m_btn1,"yq_btn02.png")
        game_util:setCCControlButtonBackground(self.m_btn2,"yq_btn01.png")
        game_util:setCCControlButtonBackground(self.m_btn3,"yq_btn02.png")
    else
        game_util:setCCControlButtonBackground(self.m_btn1,"yq_btn02.png")
        game_util:setCCControlButtonBackground(self.m_btn2,"yq_btn02.png")
        game_util:setCCControlButtonBackground(self.m_btn3,"yq_btn01.png")
    end


    local guild_high_war_fate_cfg = getConfig(game_config_field.guild_high_war_fate)
    for i=1,5 do
        self.m_qq_btns[i]:removeAllChildrenWithCleanup(true)
        local sprite = CCSprite:create("ccbResources/guild_high_war/"..spr_btns[self.m_select_index][i][1]..".png")
        local tempSize = self.m_qq_btns[i]:getPreferredSize();
        sprite:setPosition(ccp(tempSize.width/2, tempSize.height/2))
        sprite:setScale(0.6)
        self.m_qq_btns[i]:addChild(sprite)

        self.m_spr_status[i]:setVisible(false)
        local buildData = self.m_tGameData.info[tostring(self.m_buildingId)]
        if buildData then
            if buildData.sort == self.m_select_index and buildData.position_id == i then
                local time = buildData.time 
                local date = os.date("*t", time )
                local next_date = {}
                next_date.year = date.year
                next_date.month = date.month
                next_date.day = date.day + 1
                next_date.hour = 0
                next_date.min = 0
                next_date.sec = 0
                local next_day_time = os.time(next_date)
                local server_time = game_data:getUserStatusDataByKey("server_time")
                self.m_spr_status[i]:setVisible(true)
                local fate_cfg = guild_high_war_fate_cfg:getNodeWithKey(buildData.fate_id)
                local type = fate_cfg:getNodeWithKey("type"):toInt()
                next_day_time = server_time
                if next_day_time > server_time then -- 未到出结果时间
                    game_util:setSpriteDisplayBySpriteFrameName(self.m_spr_status[i], "ts_icon03.png")
                else
                    
                    if buildData.fate_id > 0 then
                        local fate_cfg = guild_high_war_fate_cfg:getNodeWithKey(buildData.fate_id)
                        local type = fate_cfg:getNodeWithKey("type"):toInt()
                        if type == 2 then -- 坐牢
                            game_util:setSpriteDisplayBySpriteFrameName(self.m_spr_status[i], "ts_icon02.png")
                        else
                            game_util:setSpriteDisplayBySpriteFrameName(self.m_spr_status[i], "ts_icon01.png")
                        end
                    end
                end
            end 
        end
    end
end

-- 获取当前城市正在进行中机遇的sort
function game_godfield_guild_high_war_chance_pop.getChanceSort(self)
    local buildData = self.m_tGameData.info[tostring(self.m_buildingId)]
    local sort = 1
    if buildData and buildData.sort > 1 then
        sort = buildData.sort
    end
    return sort
end

function game_godfield_guild_high_war_chance_pop.getShowRewards(self)
    local rewards = {}
    local temp_rewards = {}
    for k,v in pairs(self.m_fate_list) do
        if v.cfg.sort == self.m_select_index then
            for kk,vv in pairs(v.cfg.reward) do
                if type(vv) == "table" and not game_util:valueInTeam(vv[1]..","..vv[2]..","..vv[3],temp_rewards) then
                    table.insert(temp_rewards, vv[1]..","..vv[2]..","..vv[3])
                    table.insert(rewards, {vv[1],vv[2],vv[3]})
                end
            end
        end
    end
    return rewards
end

--[[--
    初始化
]]
function game_godfield_guild_high_war_chance_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_buildingId = t_params.buildingId
    self.m_isSelfFlag = t_params.isSelfFlag
    self.m_step = t_params.step
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
function game_godfield_guild_high_war_chance_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_guild_high_war_chance_pop;