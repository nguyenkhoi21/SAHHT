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
    if tag ~= "user_guide" and tag ~= "guild_noLoading" then
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
        cclog("get http start ----- tag = " .. tag .. ";url = " .. url);
    else
        method = 1;
        if string.sub(url,string.len(url)) == "&" then
            url = url .. "kqg_cjxy=1"
        else
            url = url .. "&kqg_cjxy=1"
        end
        httpReq:setUrl(url)
        httpReq:setRequestData(params,string.len(params));
        cclog("post http start ----- tag = " .. tag .. ";url = ",url," ; params = ",params);
    end
    if callback then
        httpReq:registerScriptTapHandler(callback)
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
    if tag ~= "user_guide" and tag ~= "guild_noLoading" then
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
