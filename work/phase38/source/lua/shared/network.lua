--- 網絡請求封裝
local network = {
    callbackFunc = {},
    loadingRef = 0;
}

local errorTab = {
    error_500 = "Máy chủ có lỗi, xin thử lại sau!",
    error_502 = "Máy chủ có lỗi, xin thử lại sau!",
}

--[[--
    打印所有的請求回調
]]
function network.printAllCallbackFunc()
    for k,v in pairs(network.callbackFunc) do
        cclog("printAllCallbackFunc tag = " .. k, "function = " .. type(v[1]));
    end
end
--[[--
    清除所有的請求回調
]]
function network.clearAllCallbackFunc()
    network.callbackFunc = {};
    network.loadingRef = 0;
    require("game_ui.game_loading").close();
end
--[[--
    網絡請求回調
]]
function network.httpRequestCallback(tag,response,contentLength)
    if tag ~= "user_guide" and tag ~= "guild_noLoading" and not (LOCAL_TEST_MODE and type(tag)=="string" and tag:match("^highway_qa_poll_%d+$")) then
        network.loadingRef = network.loadingRef - 1;
    end
    contentLength = contentLength or 0;
    local retrunFlag = false;
    local callbackTab = network.callbackFunc[tag];
    local status = "-100000"
    local all_config_version = "";
    cclog("responseMethod --------tag=%s,code=%d  ; callbackTab == %s",tag,response:getResponseCode(),tostring(callbackTab),contentLength);
    if response:isSucceed()==false then
        local responseCode = response:getResponseCode()
        local errorMsg = errorTab["error_" .. tostring(responseCode)];
        if errorMsg then
            require("game_ui.game_pop_up_box").showAlertView(errorMsg);
        else
            require("game_ui.game_pop_up_box").showAlertView(string_config.m_net_req_failed);
        end
        retrunFlag = true;
    else
        local buffer = response:getResponseDataBuffer();
        local gameData = util_json:new(buffer);
        
        if gameData and (not gameData:isEmpty()) then 
            -- body
            status = gameData:getNodeWithKey("status"):toStr();
            cclog2(status,"status ======")
            all_config_version = gameData:getNodeWithKey("all_config_version")
            if all_config_version then
                all_config_version = all_config_version:toStr();
            else
                all_config_version = "";
            end
            local client_upgrade = gameData:getNodeWithKey("client_upgrade");
            if(client_upgrade ~= nil)then
                local updataUrl = client_upgrade:getNodeWithKey("url"):toStr();
                local t_params = 
                {
                    title = "Nhắc nhở",
                    okBtnCallBack = function(target,event)
                        cclog("rightBtnCallBack");
                        require("game_ui.game_pop_up_box").close(); 
                        util_system:openUrlOutside(updataUrl);
                    end,   --可缺省
                    cancelBtnCallBack = function(target,event) cclog("rightBtnCallBack") require("game_ui.game_pop_up_box").close(); end,   --可缺省
                    okBtnText = "Cập nhật",       --可缺省
                    cancelBtnText = "Hủy",
                    text = client_upgrade:getNodeWithKey("msg"):toStr(),      --可缺省
                    onlyOneBtn = true,          --可缺省
                }
                require("game_ui.game_pop_up_box").show(t_params);
            else
                game_data:responseGameData(gameData);
                if LOCAL_TEST_MODE then
                    local statusNode = gameData:getNodeWithKey("user_status");
                    local powerNode = statusNode and statusNode:getNodeWithKey("combat");
                    if powerNode then game_data:setNewCombat(tonumber(powerNode:toStr()) or 0); end
                    local pointNode = statusNode and statusNode:getNodeWithKey("arena_point");
                    local rankNode = statusNode and statusNode:getNodeWithKey("arena_rank");
                    if pointNode then game_data.m_arenaPoint = pointNode:toInt(); end
                    if rankNode then game_data.m_arenaRank = rankNode:toInt(); end
                end

                if status == "0" then--正常 
                    game_scene:fillPropertyBarData();
                    if callbackTab ~= nil and type(callbackTab[1]) == "function" and gameData:getNodeWithKey("data") then
                        callbackTab[1](tag,gameData,contentLength,status,all_config_version);
                    else
                        print(callbackTab);
                        print(type(callbackTab));
                        cclog("error one----------" .. tag);
                        -- local msg = gameData:getNodeWithKey("msg");
                        -- require("game_ui.game_pop_up_box").showAlertView((not msg:isEmpty() and msg:toStr() ~= "null" and msg:toStr() ~= "") and msg:toStr() or string_config.m_data_error .. ";status=" ..status);
                        retrunFlag = true;
                    end
                elseif status == "9527" or status == "error_21" then--多設備登錄 提示  或者重新登錄
                    local t_params = 
                    {
                        title = "Nhắc nhở",
                        okBtnCallBack = function(target,event)
                            require("game_ui.game_pop_up_box").close();
                            game_scene:setVisibleBroadcastNode(false);
                            game:resourcesDownload();
                        end,   --可缺省
                        okBtnText = "Đăng nhập lại",       --可缺省
                        text = gameData:getNodeWithKey("msg"):toStr(),      --可缺省
                        onlyOneBtn = true,          --可缺省
                    }
                    require("game_ui.game_pop_up_box").show(t_params);
                    retrunFlag = true;
                elseif status == "-77777" then--挖矿结束
                    local t_params = 
                    {
                        title = "Nhắc nhở",
                        okBtnCallBack = function(target,event)
                            require("game_ui.game_pop_up_box").close();
                            game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"});
                        end,   --可缺省
                        okBtnText = "Đăng nhập lại",       --可缺省
                        text = gameData:getNodeWithKey("msg"):toStr(),      --可缺省
                        onlyOneBtn = true,          --可缺省
                    }
                    require("game_ui.game_pop_up_box").show(t_params);
                    retrunFlag = true;
                elseif status == "error_zodiac" then
                    cclog(status,"-=0-=0-=0-=0-=0-=0-=0-=0-=")
                    local t_params = 
                    {
                        title = "Tips",
                        okBtnCallBack = function(target,event)
                            require("game_ui.game_pop_up_box").close();
                            game_scene:enterGameUi("game_godfield_mainBig",{});
                        end,   --可缺省
                        okBtnText = "OK",       --可缺省
                        text = "Chưa đến giờ event,về giao diện Thần Vực",      --可缺省
                        onlyOneBtn = true,          --可缺省
                        closeFlag = false,
                    }
                    require("game_ui.game_pop_up_box").show(t_params);
                    retrunFlag = false;
                elseif status == "error_raid_stage" then
                    local t_params = 
                    {
                        title = "Nhắc nhở",
                        okBtnCallBack = function(target,event)
                            require("game_ui.game_pop_up_box").close();
                            local tab = game_data:getTeamRaidMsg()
                            local function responseMethod( tag, gameData )
                                if gameData then
                                    local data = gameData:getNodeWithKey("data")
                                    local stage = data:getNodeWithKey("stage"):toInt()
                                    local stage_small = data:getNodeWithKey("stage_small") and data:getNodeWithKey("stage_small"):toInt()
                                    if stage and stage ~= 0 then
                                        if stage == 1 then
                                            if stage_small == 1 then
                                                game_scene:enterGameUi("game_teamRaid_first_scene",{gameData = gameData,enterFlag = tab.enterFlag,battleType = tab.battleType})
                                            elseif stage_small == 2 then
                                                game_scene:enterGameUi("game_teamRaid_firstBoss_scene",{gameData = gameData,enterFlag = tab.enterFlag,selectRow = tab.selectRow,selectCol = tab.selectCol })
                                            end
                                        elseif stage == 2 then
                                            if stage_small == 1 then
                                                game_scene:enterGameUi("game_teamRaid_last_scene",{gameData = gameData,enterFlag = tab.enterFlag})
                                            elseif stage_small == 2 then
                                                game_scene:enterGameUi("game_teamRaid_lastBoss_scene",{gameData = gameData,enterFlag = tab.enterFlag,selectRow = tab.selectRow,selectCol = tab.selectCol })
                                            end
                                        elseif stage == 3 then
                                            game_scene:enterGameUi("game_teamRaid_third_scene",{gameData = gameData,enterFlag = tab.enterFlag})
                                        elseif stage == 999 then
                                            game_scene:addPop("game_teamRaid_result_pop",{gameData = gameData,enterFlag = tab.enterFlag})
                                        end
                                    else
                                        game_scene:enterGameUi("game_teamRaid_sec",{gameData = gameData,enterFlag = 1})
                                    end
                                end
                            end

                            local params = {}
                            params.raid_id = tab.raid_id
                            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_persion_raid_index"), http_request_method.GET, params,"team_raid_persion_raid_index")
                        end,
                        closeCallBack = function(target,event) 
                            require("game_ui.game_pop_up_box").close();
                            local tab = game_data:getTeamRaidMsg()
                            local function responseMethod( tag, gameData )
                                if gameData then
                                    local data = gameData:getNodeWithKey("data")
                                    local stage = data:getNodeWithKey("stage"):toInt()
                                    local stage_small = data:getNodeWithKey("stage_small") and data:getNodeWithKey("stage_small"):toInt()
                                    if stage and stage ~= 0 then
                                        if stage == 1 then
                                            if stage_small == 1 then
                                                game_scene:enterGameUi("game_teamRaid_first_scene",{gameData = gameData,enterFlag = tab.enterFlag,battleType = tab.battleType})
                                            elseif stage_small == 2 then
                                                game_scene:enterGameUi("game_teamRaid_firstBoss_scene",{gameData = gameData,enterFlag = tab.enterFlag,selectRow = tab.selectRow,selectCol = tab.selectCol })
                                            end
                                        elseif stage == 2 then
                                            if stage_small == 1 then
                                                game_scene:enterGameUi("game_teamRaid_last_scene",{gameData = gameData,enterFlag = tab.enterFlag})
                                            elseif stage_small == 2 then
                                                game_scene:enterGameUi("game_teamRaid_lastBoss_scene",{gameData = gameData,enterFlag = tab.enterFlag,selectRow = tab.selectRow,selectCol = tab.selectCol })
                                            end
                                        elseif stage == 3 then
                                            game_scene:enterGameUi("game_teamRaid_third_scene",{gameData = gameData,enterFlag = tab.enterFlag})
                                        elseif stage == 999 then
                                            game_scene:addPop("game_teamRaid_result_pop",{gameData = gameData,enterFlag = tab.enterFlag})
                                        end
                                    else
                                        game_scene:enterGameUi("game_teamRaid_sec",{gameData = gameData,enterFlag = 1})
                                    end
                                end
                            end

                            local params = {}
                            params.raid_id = tab.raid_id
                            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_raid_persion_raid_index"), http_request_method.GET, params,"team_raid_persion_raid_index")
                        end,
                        okBtnText = "Xác định", 
                        cancelBtnText = "Hủy",      --可缺省
                        text = gameData:getNodeWithKey("msg"):toStr(),      --可缺省
                        onlyOneBtn = true,          --可缺省
                        }
                    require("game_ui.game_pop_up_box").show(t_params);
                else
                    cclog("error two----------" .. tag);
                    local msg = gameData:getNodeWithKey("msg");
                    if not msg then
                        local data = json.decode(gameData:getFormatBuffer())
                        game_scene:addPop("game_error_pop",{errorStatus = status,errorMsg = data.data.message,tag = tag});
                        retrunFlag = true;
                    else
                        game_scene:addPop("game_error_pop",{errorStatus = status,errorMsg = msg:toStr(),tag = tag});
                        retrunFlag = true;
                    end
                end
            end
        else
            require("game_ui.game_pop_up_box").showAlertView(string_config.m_net_no_data);
            retrunFlag = true;
        end
        gameData:delete();
    end
    if network.loadingRef == 0 then
        require("game_ui.game_loading").close();
    end
    if retrunFlag and callbackTab ~= nil and (callbackTab[2] or callbackTab[3]) then
        callbackTab[1](tag,nil,contentLength,status,all_config_version);
    end
    network.callbackFunc[tag] = nil;
    cclog("http end ----- tag = " .. tag);
end
--[[--
    發送請求
]]
function network.sendHttpRequestNoLoading(callback, url, method ,params_ ,tag)
    if not method then method = "GET" end
    local params = "";
    if params_ ~= nil then
        if type(params_) == "table" then
            for k,v in pairs(params_) do
                params = params .. k .. "=" .. v .. "&";
            end
        elseif type(params_) == "string" then
            params = params_;
        end
    end
    local httpReq = CCHttpRequest:new()
    if string.upper(tostring(method)) == "GET" then
        method = 0;
        url = url .. "&" .. params;
        if string.sub(url,string.len(url)) == "&" then
            url = url .. "kqg_cjxy=1"
        else
            url = url .. "&kqg_cjxy=1"
        end
        httpReq:setUrl(url)
        if LOCAL_TEST_MODE then cclog("[LOCAL_HTTP] GET tag=" .. tag) else cclog("get http start ----- tag = " .. tag .. ";url = " .. url); end
    else
        method = 1;
        if string.sub(url,string.len(url)) == "&" then
            url = url .. "kqg_cjxy=1"
        else
            url = url .. "&kqg_cjxy=1"
        end
        httpReq:setUrl(url)
        httpReq:setRequestData(params,string.len(params));
        if LOCAL_TEST_MODE then cclog("[LOCAL_HTTP] POST tag=" .. tag) else cclog("post http start ----- tag = " .. tag .. ";url = ",url," ; params = ",params); end
    end
    if callback then
        local accountGeneration=network.localAccountGeneration or 0
        httpReq:registerScriptTapHandler(function(...)
            if accountGeneration~=(network.localAccountGeneration or 0)then return end
            callback(...)
        end)
    end
    httpReq:setRequestType(method)
    httpReq:setTag(tag)
    CCHttpClient:getInstance():send(httpReq)
    httpReq:release()
end
--[[--
    發送請求
]]
function network.sendHttpRequest(callback, url, method ,params_ ,tag , loadingFlag, retrunFlag,noresFlag)
    -- pet_vn_contract: cấp request_id trước serialize, giữ nguyên khóa khi retry HTTP.
    if LOCAL_TEST_MODE and type(url)=="string" then
        local action=url:match("[?&]method=pets%.([%w_]+)")
        local writes={["pet_culture"]=true,["pet_evolution"]=true,["pet_strengthen"]=true,["pet_skill_levelup"]=true,["activate_pos"]=true,["set_pet_formation"]=true,["activate_pet_follow_pos"]=true,["set_pet_follow_formation"]=true}
        if action and action~="index" and not writes[action] then
            game_util:addMoveTips({text=action=="pet_rebirth" and "Tái Sinh PET còn thiếu quy tắc hoàn gốc; chưa tiêu đá hoặc Xu." or "Tẩy tỷ lệ PET còn thiếu quy tắc bốc số gốc; chưa tiêu mảnh."});return
        end
        if action and writes[action] then
            network.petSequence=(network.petSequence or 0)+1
            local key=tostring(os.time()).."-pet-"..network.petSequence.."-"..math.random(100000,999999)
            if type(params_)=="string" then
                if not params_:find("request_id=",1,true) then params_=params_.."&request_id="..key end
            else params_=params_ or {};params_.request_id=params_.request_id or key end
        end
    end

    -- phase37_aether_contract: method từ URL, không dựa vào tag đôi khi trùng.
    if LOCAL_TEST_MODE and type(url)=="string" then
        local action=url:match("[?&]method=guild_high_war%.([%w_]+)")
        local reads={["index"]=true,["map_index"]=true,["alignment_info"]=true,["upload_formation"]=true,["employ_index"]=true,["employ_guild_index"]=true,["shop_index"]=true,["get_rank"]=true,["city_info"]=true,["get_guild_record"]=true,["get_city_record"]=true,["record"]=true,["science_index"]=true,["science_rank"]=true,["box_index"]=true,["war_index"]=true,["player_index"]=true,["explore_index"]=true};local writes={["employ_join"]=true,["employ_agree"]=true,["employ_refuse"]=true,["employ_quit"]=true,["employ_remove"]=true,["set_formation"]=true,["stationed"]=true,["set_fight_alignment"]=true,["set_first_alignment"]=true,["declare_war"]=true,["buy"]=true,["dolike"]=true,["contribute"]=true,["get_science_star"]=true,["select_reward"]=true,["get_war_reward"]=true,["auto_get_war_reward"]=true,["send_war_card"]=true,["simulate_purchase"]=true,["stationed_source"]=true,["declare_war_source"]=true,["down_alignment_source"]=true,["stationed_fate"]=true,["down_alignment_fate"]=true,["explore"]=true,["get_fate_reward"]=true}
        if action and not reads[action] and not writes[action] then
            game_util:addMoveTips({text="Mục Aether này còn thiếu thuật toán nguồn; chưa tiêu vật phẩm hoặc phát thưởng."});return
        end
        if action and writes[action] then
            network.aetherSequence=(network.aetherSequence or 0)+1
            local key=tostring(os.time()).."-aether-"..network.aetherSequence.."-"..math.random(100000,999999)
            if type(params_)=="string"then
                if not params_:find("request_id=",1,true)then params_=params_.."&request_id="..key end
            else params_=params_ or {};params_.request_id=params_.request_id or key end
        end
    end


    if LOCAL_TEST_MODE and type(url)=="string"then
        local action=url:match("[?&]method=([^&]+)")or ""
        local supported={
            ["homeland.index"]=true,["homeland.store_index"]=true,["homeland.visit"]=true,["homeland.friends"]=true,
            ["fable_beast.index"]=true,["fable_beast.rebirth_preview"]=true,["homeland.sowing"]=true,["homeland.havest"]=true,["homeland.auto_havest"]=true,["homeland.shop_buy"]=true,["homeland.use_adorn"]=true,["homeland.cancel_adorn"]=true,["fable_beast.open_fable_beast"]=true,["fable_beast.add_beast_exp"]=true,["fable_beast.up_beast_god"]=true,["fable_beast.update_fight_beast"]=true,["fable_beast.up_beast_quality"]=true,["fable_beast.fable_beast_rebirth"]=true
        }
        if (action:match("^homeland%.") or action:match("^fable_beast%.")) and not supported[action] then
            game_util:addMoveTips({text="Mục này còn thiếu quy tắc gốc; chưa tiêu tài nguyên hoặc nhận thưởng."})
            return
        end
    end
    -- phase36_alliance_nonce: method lấy từ URL, vì like_oo dùng URL làm tag.
    if LOCAL_TEST_MODE and type(url)=="string"then
        local allianceMethod=url:match("[?&]method=([^&]+)")
        local writes={["association.guild_create"]=true,["association.guild_join"]=true,["association.guild_agree"]=true,["association.guild_not_agree"]=true,["association.guild_quit"]=true,["association.guild_destroy"]=true,["association.appoint_player"]=true,["association.remove_player"]=true,["association.add_notice"]=true,["association.dedicate"]=true,["association.levelup"]=true,["association.buy_commodity"]=true,["association.add_msg"]=true,["homeland.sowing"]=true,["homeland.havest"]=true,["homeland.auto_havest"]=true,["homeland.shop_buy"]=true,["homeland.use_adorn"]=true,["homeland.cancel_adorn"]=true,["fable_beast.open_fable_beast"]=true,["fable_beast.add_beast_exp"]=true,["fable_beast.up_beast_god"]=true,["fable_beast.update_fight_beast"]=true,["fable_beast.up_beast_quality"]=true,["fable_beast.fable_beast_rebirth"]=true}
        if writes[allianceMethod]then
            network.localContentSequence=(network.localContentSequence or 0)+1
            local key=tostring(os.time()).."-alliance-"..network.localContentSequence.."-"..math.random(100000,999999)
            if type(params_)=="string"then
                if not params_:find("request_id=",1,true)then params_=params_.."&request_id="..key end
            else
                params_=params_ or {};params_.request_id=params_.request_id or key
            end
        end
    end

    if LOCAL_TEST_MODE and type(tag)=="string" and tag:match("^highway_") then params_=params_ or {};params_.local_play="pool-v1" end
    if LOCAL_TEST_MODE then
        if type(params_) == "string" then
            params_=params_.."&client_content=phase30-v1"
        else
            params_=params_ or {};params_.client_content="phase30-v1"
        end
    end

    if LOCAL_TEST_MODE and ((type(url) == "string" and (string.match(url,"[?&]method=([^&]+)") == "soul.soul_gacha" or string.match(url,"[?&]method=([^&]+)") == "soul.soul_gacha10")) or tag == "item_use" or tag == "factory_equip_levelup" or tag == "equip_levelup" or tag == "fate_equip_bind" or tag == "fate_equip_unbind" or tag == "fate_equip_levelup" or tag == "auto_fate_equip_levelup" or tag == "gacha_get_gacha" or tag == "shop_buy" or tag == "shop_vip_store_buy" or tag == "cards_buy_skin" or tag == "cards_use_skin" or tag == "cards_card_world" or tag == "laboratory_level_up" or tag == "tutorial_opening_complete" or tag == "god_field_set_god_field" or tag == "god_field_god_field_battle" or tag == "god_field_exchange" or tag == "god_field_buy_ship_ticket" or tag == "god_field_update_battle_order" or tag == "universe_arena_set_god_field" or tag == "universe_arena_buy_goods" or tag == "universe_arena_get_reward" or tag == "universe_arena_universe_arena_battle" or tag == "item_exchange" or tag == "zodiac_battle" or tag == "zodiac_remove_floor_pos" or tag == "zodiac_set_adjustment" or (type(tag)=="string" and (tag:match("^highway_buy_%d+$") or tag:match("^highway_trans_%d+$"))) or (type(tag)=="string" and (tag:match("^highway_betting_%d+$") or tag:match("^highway_add_power_%d+$") or tag:match("^highway_add_buff_%d+$"))) or tag == "friend_apply_friend" or tag == "friend_add_friend" or tag == "friend_read_message" or tag == "friend_remove_friend" or tag == "friend_battle" or tag == "friend_send_gift" or tag == "friend_send_message" or tag == "friend_del_message" or tag == "talisman_level_up_talisman" or tag == "talisman_talisman_break" or tag == "talisman_sell" or tag == "talisman_forging" or tag == "talisman_forging_effect" or tag == "talisman_skill_save" or tag == "gem_synthesis" or tag == "gem_evolution" or tag == "gem_upgrade" or tag == "gem_resolve" or tag == "god_stone_synthesis" or tag == "god_stone_alignment" or tag == "soul_eat_soul" or tag == "soul_sell_soul" or tag == "soul_soul_gacha" or tag == "soul_soul_gacha10" or tag == "soul_increase_rate" or tag == "medal_synthesis_medal" or tag == "medal_synthesis_material" or tag == "medal_exchange_material" or tag == "medal_train_material" or tag == "cards_activate_assistant" or tag == "cards_activate_destiny" or tag == "cards_activate_bonus_formation" or tag == "cards_activate_assistant_effect" or tag == "cards_set_bonus_formation" or tag == "cards_set_formation_bonus_addition" or tag == "card_rebirth" or tag == "gem_fate_empowering" or tag == "gem_fate_printing" or tag == "gem_fate_transfer" or tag == "cards_inherit" or tag == "element_break" or tag == "cards_card_break" or tag == "cards_card_evolution" or tag == "cards_make_soul" or tag == "cards_super_evolution" or tag == "sacrifice_grace_exchange" or tag == "normal_exchange_normal_exchange" or tag == "local_redeem_ticket" or tag == "gem_fate_synthesis_gem_fate" or tag == "gem_fate_using_gem_fate") then
        network.localContentSequence=(network.localContentSequence or 0)+1
        local key=tostring(os.time()).."-content-"..tostring(network.localContentSequence).."-"..tostring(math.random(100000,999999))
        if type(params_) == "string" then
            if not string.find(params_,"request_id=",1,true) then params_=params_.."&request_id="..key end
        else
            params_=params_ or {};params_.request_id=params_.request_id or key
        end
    end
    if LOCAL_TEST_MODE and (tag == "arena_battle" or tag == "arena_buy_count") then
        params_ = params_ or {};
        network.localBattleSequence = (network.localBattleSequence or 0) + 1;
        params_.request_id = params_.request_id or (tostring(os.time()) .. "-" .. tostring(network.localBattleSequence) .. "-" .. tostring(math.random(100000,999999)));
    end

    if LOCAL_TEST_MODE and tag == "private_city_recapture" and type(params_) == "table" then
        network.localBattleSequence = (network.localBattleSequence or 0) + 1;
        params_.request_id = params_.request_id or (tostring(os.time()) .. "-" .. tostring(network.localBattleSequence) .. "-" .. tostring(math.random(100000,999999)));
    end

    if tag ~= "user_guide" and tag ~= "guild_noLoading" and not (LOCAL_TEST_MODE and type(tag)=="string" and tag:match("^highway_qa_poll_%d+$")) then
        if loadingFlag == nil or loadingFlag == true then 
            require("game_ui.game_loading").show(); 
        else
            require("game_ui.game_loading").show({opacity = 0});
        end
        network.loadingRef = network.loadingRef + 1;
    end
    if retrunFlag == nil then retrunFlag = false end
    if network.callbackFunc[tag] == nil then
        local callbackParam = {};
        callbackParam[1] = callback;
        callbackParam[2] = retrunFlag;
        callbackParam[3] = noresFlag;
        network.callbackFunc[tag] = callbackParam;
    end
    network.sendHttpRequestNoLoading(network.httpRequestCallback,url,method,params_,tag);
end

return network
