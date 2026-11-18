-- 雇佣兵
local game_godfield_guild_high_war_employ_index = {
    m_tGameData = nil,
    m_step = nil,
    selectZcId = 1
}

--[[--
    销毁
]]
function game_godfield_guild_high_war_employ_index.destroy(self)
    cclog("-----------------game_godfield_guild_high_war_employ_index destroy-----------------")
    self.m_tGameData = nil
    self.m_step = nil
    self.ext = nil
    self.selectZcId = nil
end

--[[--
    返回
]]
function game_godfield_guild_high_war_employ_index.back(self, type)
    function responseMethod(tag, gameData)
        local data = gameData:getNodeWithKey("data")
        data = json.decode(data:getFormatBuffer()) or {}
        game_scene:enterGameUi("game_godfield_guild_high_war_main", {gameData = gameData})
    end
    network.sendHttpRequest(responseMethod, game_url.getUrlForKey("guild_high_war_index"), http_request_method.GET, {}, "guild_high_war_index")
end

--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_employ_index.createUi(self)
    local ccbNode = luaCCBNode:create()
    local function onMainBtnClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then --返回
            self:back()
        elseif btnTag == 200 then -- 规则
            local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
            local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(30))
            if itemCfg == nil then return end
            local openMsg = itemCfg:getNodeWithKey("des"):toStr();
            game_scene:addPop("game_godfield_detail_pop",{openMsg = openMsg})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick) --bind button on click event
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_employ_index.ccbi")

    self.m_ccbNode = ccbNode

    local guild_high_war_group = getConfig(game_config_field.guild_high_war_group)
    self.guild_high_war_group = json.decode(guild_high_war_group:getFormatBuffer()) or {}

    return ccbNode
end

function game_godfield_guild_high_war_employ_index:onEnter()
end

function game_godfield_guild_high_war_employ_index.refreshUi(self)
    -- 更新hire_limit
    self.cur_hire_limit = 0
    for k, v in pairs(self.guild_high_war_group) do
        if v.group_id == self.selectZcId and v.version == self.m_tGameData.version then
            self.cur_hire_limit = v.hire_limit
            break
        end
    end
    -- nd_zcList
    local nd_zcList = self.m_ccbNode:nodeForName("nd_zcList")
    nd_zcList:removeAllChildrenWithCleanup(true)
    local show_data = {}
    for k, v in pairs(self.m_tGameData.groups) do
        v.id = tonumber(k)
        table.insert(show_data, v)
    end
    table.sort(
        show_data,
        function(a, b)
            return a.id < b.id
        end
    )
    local tb = self:createZcList(nd_zcList:getContentSize(), show_data)
    nd_zcList:addChild(tb)
    tb:setScrollBarVisible(false)
    -- nd_zcGuildList
    local nd_zcGuildList = self.m_ccbNode:nodeForName("nd_zcGuildList")
    nd_zcGuildList:removeAllChildrenWithCleanup(true)
    local rank = self.m_tGameData.rank or {}
    local showData = {}
    for k, v in pairs(rank) do
        v._id = tonumber(k)
        table.insert(showData, v)
    end
    table.sort(
        showData,
        function(a, b)
            local hasEmploy1 = self.m_tGameData.employ_guild == a.guild_id and 1 or 0
            local hasEmploy2 = self.m_tGameData.employ_guild == b.guild_id and 1 or 0
            if hasEmploy1 == hasEmploy2 then
                return a._id < b._id
            else
                return hasEmploy1 > hasEmploy2
            end
        end
    )
    local tb = self:createZcGuildList(nd_zcGuildList:getContentSize(), showData)
    nd_zcGuildList:addChild(tb)
    tb:setScrollBarVisible(false)
end

--[[--
    初始化
]]
function game_godfield_guild_high_war_employ_index.init(self, t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
        self.selectZcId = self.m_tGameData.group_id or 1
    else
        self.m_tGameData = {}
    end

    self.ext = t_params.ext or {}
end

--[[--
    创建入口
]]
function game_godfield_guild_high_war_employ_index.create(self, t_params)
    self:init(t_params)
    local rootScene = CCScene:create()
    rootScene:addChild(self:createUi())
    self:refreshUi()
    return rootScene
end

function game_godfield_guild_high_war_employ_index:createZcList(viewSize, showData)
    local params = {}
    params.viewSize = viewSize
    params.row = 9 --行
    params.column = 1 --列
    params.totalItem = #showData --totalItem;
    params.direction = kCCScrollViewDirectionVertical
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 10
    params.itemActionFlag = true
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height / params.row)
    params.newCell = function(tableView, index)
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()

            local function onMainBtnClick(target, event)
                local tagNode = tolua.cast(target, "CCNode")
                local btnTag = tagNode:getTag()
            end
            ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick)
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_employ_zcItem.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5))
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10), "luaCCBNode")
            local data = showData[index + 1]

            -- sp_bg
            local sp_bg = ccbNode:spriteForName("sp_bg")
            local res = data.id == self.selectZcId and "yq_btn01.png" or "yq_btn02.png"
            sp_bg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(res))
            -- lb_name
            ccbNode:labelTTFForName("lb_name"):setString(data.id .. "Chiến trường số")
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, cell)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell))
        local data = showData[index + 1]

        local function responseMethod(tag, gameData)
            local data = gameData:getNodeWithKey("data")
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
            self.selectZcId = self.m_tGameData.group_id or 1
            self:refreshUi()
        end
        network.sendHttpRequest(responseMethod, game_url.getUrlForKey("guild_high_war_employ_index"), http_request_method.GET, {group_id = data.id}, "guild_high_war_get_guild_record")
    end
    return TableViewHelper:create(params)
end

function game_godfield_guild_high_war_employ_index:createZcGuildList(viewSize, showData)
    local params = {}
    params.viewSize = viewSize
    params.row = 4 --行
    params.column = 1 --列
    params.totalItem = #showData --totalItem;
    params.direction = kCCScrollViewDirectionVertical
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 10
    params.itemActionFlag = true
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height / params.row)
    params.newCell = function(tableView, index)
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()

            local function onMainBtnClick(target, event)
                local tagNode = tolua.cast(target, "CCNode")
                local btnTag = tagNode:getTag()
            end
            ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick)
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_employ_zcGuildItem.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5))
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10), "luaCCBNode")
            local data = showData[index + 1]
            -- 公会人数
            local nd_memberNums = ccbNode:nodeForName("nd_memberNums")
            nd_memberNums:removeAllChildrenWithCleanup(true)
            local label_memberNums = game_util:createLabelBMFont({text = data.player_num, fnt = "ccbResources/guild_high_war/sz_msz01.fnt"})
            nd_memberNums:addChild(label_memberNums)
            -- 名称
            ccbNode:labelTTFForName("lb_name"):setString(data.name)
            -- 战力
            ccbNode:labelTTFForName("lb_combat"):setString(data.combat)
            -- lb_remain
            ccbNode:labelTTFForName("lb_remain"):setString((self.cur_hire_limit - #data.employ_list) .. "/" .. #data.employ_waiter)
            -- btn_status
            local btn_status = ccbNode:controlButtonForName("btn_status")
            local status = self:getGuildItemStatus(data)
            btn_status:setEnabled(status == "canApply" or status == "hasEmployByThisGuild" or status == "hasApply")
            btn_status:setColor((status == "canApply" or status == "hasEmployByThisGuild") and ccc3(255, 255, 255) or ccc3(128, 128, 128))
            if status == "canApply" or status == "hasEmployByThisGuild" or status == "black" or status == "hasApply" then
                if status == "canApply" or status == "black" then
                    game_util:setCCControlButtonBackground(btn_status, "ytyb_sq.png")
                end
                if status == "hasEmployByThisGuild" then
                    game_util:setCCControlButtonBackground(btn_status, "ytyb_lk.png")
                end
                if status == "hasApply" then
                    game_util:setCCControlButtonBackground(btn_status, "ytyb_ysq.png")
                end

                btn_status:addHandleOfControlEvent(
                    function()
                        if status == "canApply" then
                            local function responseMethod(tag, gameData)
                                gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                                self.m_tGameData = gameData
                                game_util:addMoveTips({text = "Xin Thuê thành công"})
                                self:refreshUi()
                            end
                            network.sendHttpRequest(
                                responseMethod,
                                game_url.getUrlForKey("guild_high_war_employ_join"),
                                http_request_method.GET,
                                {guild_id = data.guild_id},
                                "guild_high_war_employ_join"
                            )
                        elseif status == "hasEmployByThisGuild" then
                            local t_params = {
                                title = "Hiển thị",
                                okBtnCallBack = function(target, event)
                                    -- 解雇
                                    local function responseMethod(tag, gameData)
                                        gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                                        self.m_tGameData = gameData
                                        game_util:addMoveTips({text = "Thành công bị hủy Thuê"})
                                        self:refreshUi()
                                    end
                                    network.sendHttpRequest(
                                        responseMethod,
                                        game_url.getUrlForKey("guild_high_war_employ_quit"),
                                        http_request_method.GET,
                                        {guild_id = data.guild_id},
                                        "guild_high_war_employ_quit"
                                    )
                                    require("game_ui.game_pop_up_box").close()
                                end, --可缺省
                                cancelBtnCallBack = function(target, event)
                                    require("game_ui.game_pop_up_box").close()
                                end, --可缺省
                                okBtnText = "Xác định", --可缺省
                                cancelBtnText = "Hủy",
                                text = "Xác nhận muốn rời khỏi Công Hội này? Sau khi rời khỏi sẽ không thể gia nhập lại Công Hội này", --可缺省
                                onlyOneBtn = false --可缺省
                            }
                            require("game_ui.game_pop_up_box").show(t_params)
                        elseif status == "black" then
                            game_util:addMoveTips({text = "Bạn đã rời khỏi Công Hội này, kì này không thể lại gia nhập Công Hội này"})
                        elseif status == "hasApply" then
                            game_util:addMoveTips({text = "Bạn đã xin rồi, hãy đợi thông báo"})
                        end
                    end,
                    CCControlEventTouchUpInside
                )
            end
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, cell)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell))
        -- local data = showData[index + 1]
        -- local status = self:getGuildItemStatus(data)
        -- if status == "canApply" then

        -- end
    end
    return TableViewHelper:create(params)
end

function game_godfield_guild_high_war_employ_index:getGuildItemStatus(data)
    local status = "canApply"
    local myUid = game_data:getUserStatusDataByKey("uid")
    if self.m_tGameData.employ_guild ~= "" then
        status = self.m_tGameData.employ_guild == data.guild_id and "hasEmployByThisGuild" or "hasEmploy" -- 玩家已经被雇佣
    elseif game_util:idInTableById(myUid, data.employ_black or {}) then
        status = "black" -- 当 玩家uid  在黑名单的时候  是退出过 不能再申请加入
    elseif game_util:idInTableById(myUid, data.employ_waiter or {}) then
        status = "hasApply" -- 已经申请加入
    elseif game_util.getTableLen(data.employ_list or {}) > 0 then
        status = "noEnoughPos" -- 已经无雇佣位置
    end
    return status
end

return game_godfield_guild_high_war_employ_index
