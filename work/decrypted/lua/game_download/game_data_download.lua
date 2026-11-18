--- 數據下載
 
local game_data_download = {
    m_downloadCount = nil,
    m_downloadRef = nil;
    m_downloadEndCallFunc = nil;
    m_returnFlag = nil;
    m_downloadKeyTable = nil;
};
--[[--
    銷毀
]]
function game_data_download.destroy(self)
    self.m_downloadCount = nil;
    self.m_downloadRef = nil;
    self.m_configVerTable = nil;
    self.m_returnFlag = nil;
    self.m_downloadKeyTable = nil;
end
--[[--
    初始化
]]
function game_data_download.init(self,t_params)
    t_params = t_params or {};
    self.m_downloadEndCallFunc = t_params.endCallFunc;
    self.m_downloadRef = 0;
    self.m_returnFlag = true;
end
--[[--
    開始下載
]]
function game_data_download.start(self,t_params)
    self:init(t_params);
    -- self.m_downloadKeyTable = {"cards_open","school_open","leader_skill_open","laboratory_open","factory_factory_all","user_main_page","daily_award_all_reward"}
    self.m_downloadKeyTable = {"cards_open"}
    self.m_downloadCount = #self.m_downloadKeyTable;
    self.m_downloadRef = self.m_downloadCount;
    for i=1,#self.m_downloadKeyTable do
        self:downloadDataByKey(self.m_downloadKeyTable[i]) 
    end
    -- self:downloadDataByKey(self.m_downloadKeyTable[1])
    local payurl = game_url.getUrlForKey("pay_kubi") .. "&receipt-data=";
    if setChackUrl then
        setChackUrl(payurl);
        local function payEnd( msg )
            if(msg == "pay err")then
                -- iap不成功
            elseif(msg == "pay product err")then

            elseif(msg == "pay data ready")then
                -- 服務器驗證成功
            elseif(msg == "pay data err")then
                -- 服務器驗證單據錯誤
            else
                -- iap成功,msg為iap的boundle
                local selfUid = game_data:getUserStatusDataByKey('uid');
                local server_data,sindex = game_data:getServer()
                local serverId = server_data.server
                local orderIdCom = tostring(selfUid) .. "-" .. tostring(serverId) .. '-' .. tostring(self.m_index) .. '-' .. tostring(os.time());
                if game_data_statistics then
                    game_data_statistics:paySuccess({order = orderIdCom})
                end
            end
            registerCallBack(payEnd);
        end
    end
end
--[[--
    下載數據
]]
function game_data_download.downloadDataByKey(self,urlKey)
    if game_url.getUrlForKey(urlKey) == nil then
        return;
    end
    local function responseMethod(tag,gameData)
        self.m_downloadRef = self.m_downloadRef - 1;
        if gameData then
            if tag == "cards_open" then
                local data = gameData:getNodeWithKey("data");
                game_data:updateCardsOpenByJsonData(data);
            elseif tag == "school_open" then
                game_data:setSchoolDataByJsonData(gameData:getNodeWithKey("data"));
            elseif tag == "leader_skill_open" then
                game_data:setHarborDataByJsonData(gameData:getNodeWithKey("data"));
            elseif tag == "laboratory_open" then
                game_data:setLaboratoryDataByJsonData(gameData:getNodeWithKey("data"));
            elseif tag == "factory_factory_all" then
                game_data:setFactoryDataByJsonData(gameData:getNodeWithKey("data"));
            elseif tag == "user_main_page" then
                local data = gameData:getNodeWithKey("data");
                game_data:updateMainPageByJsonData(data);
            elseif tag == "daily_award_all_reward" then
                game_data:setDailyAwardDataByJsonData(gameData:getNodeWithKey("data"));
            end
        else
            cclog("tag error ==============" .. tag)
            self.m_returnFlag = false;
            if self.m_downloadRef == 0 then
                self:downloadDataEnd();
            end
            return;
        end
        if self.m_downloadRef == 0 then
            self:downloadDataEnd();
        else
        --     self:downloadDataByKey(self.m_downloadKeyTable[self.m_downloadCount - self.m_downloadRef + 1])
        end
    end
     -- 最後還可以接受2個參數
     -- loadingFlag : boolean 是否有loading
     -- retrunFlag  : boolean 網絡成功與否，都返回
     -- 返回的結果參考network 中的network.httpRequestCallback方法

    local params = {};
    if urlKey == "cards_open" then
        params.tel = game_data:getPhoneNum()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey(urlKey), http_request_method.GET, params, urlKey,true,true)
end
--[[--
    數據下載完成
]]
function game_data_download.downloadDataEnd(self)
    cclog("----------------------downloadData end ----------------------" .. tostring(self.m_returnFlag))
    game_guide_controller:init();
    if self.m_downloadEndCallFunc and type(self.m_downloadEndCallFunc) == "function" then
        self.m_downloadEndCallFunc(self.m_returnFlag);
        if self.m_returnFlag == true then
            game_data:init();
            game_data:initGlobalScheduler();
            game_button_open:init();
            if getPlatForm() == "platformCommon" then
                local userInfo = self:sendInfotoPlatform()
                require("shared.native_helper").sendInfoToPlatForm(userInfo)
            end
        end
        local serverData,index = game_data:getServer()
        local roleLevel = game_data:getUserStatusDataByKey("level") or 1;
        local roleName = game_data:getUserStatusDataByKey("show_name") or "name"
        local roleId = game_data:getUserStatusDataByKey("uid") or ""
        local params = {}
        params.server = serverData.server
        params.server_name = serverData.server_name
        params.level = roleLevel
        params.roleName = roleName
        params.roleId = roleId
        require("shared.native_helper").sendRoleInfo(params)
        cclog2("onGetAuthUserId............................")
    end
    self:destroy();
end
--[[
    第一次登陸發送給平台的東西
]]
function game_data_download.sendInfotoPlatform(self)
    local info = {}
    local selServerData,index = game_data:getServer()
    info.serverID = selServerData.server or "err"
    info.serverName = selServerData.server_name
    info.userName = game_data:getUserStatusDataByKey("show_name")
    info.userId = game_data:getUserStatusDataByKey("uid") or ""
    info.userLevel = game_data:getUserStatusDataByKey("level") or 1
    return info
end
return game_data_download;