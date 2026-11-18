-- 雇佣兵
local game_godfield_guild_high_war_employ_guild_index = {
    m_tGameData = nil,
    m_step = nil,
    selectZcId = 1
}

--[[--
    销毁
]]
function game_godfield_guild_high_war_employ_guild_index.destroy(self)
    cclog("-----------------game_godfield_guild_high_war_employ_guild_index destroy-----------------")
    self.m_tGameData = nil
    self.m_step = nil
    self.ext = nil
    self.selectZcId = nil
end

--[[--
    返回
]]
function game_godfield_guild_high_war_employ_guild_index.back(self, type)
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
function game_godfield_guild_high_war_employ_guild_index.createUi(self)
    local ccbNode = luaCCBNode:create()
    local function onMainBtnClick(target, event)
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then --返回
            self:back()
        elseif btnTag == 200 then -- 规则
            local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
            local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(29))
            if itemCfg == nil then
                return
            end
            local openMsg = itemCfg:getNodeWithKey("des"):toStr()
            game_scene:addPop("game_godfield_detail_pop", {openMsg = openMsg})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick) --bind button on click event
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_employ_guild_index.ccbi")

    self.m_ccbNode = ccbNode

    return ccbNode
end

function game_godfield_guild_high_war_employ_guild_index:onEnter()
end

function game_godfield_guild_high_war_employ_guild_index.refreshUi(self)
    local employ_waiter = self.m_tGameData.employ_waiter or {}
    local employ_list = self.m_tGameData.employ_list or {}
    -- nd_leftList
    local nd_leftList = self.m_ccbNode:nodeForName("nd_leftList")
    nd_leftList:removeAllChildrenWithCleanup(true)
    local show_data = {{id = 1, tx = "Danh sách Xin"}, {id = 2, tx = "Danh sách Lính Đánh Thuê"}}
    local tb = self:createLeftList(nd_leftList:getContentSize(), show_data)
    nd_leftList:addChild(tb)
    tb:setScrollBarVisible(false)
    -- nd_waiters
    local nd_waiterList = self.m_ccbNode:nodeForName("nd_waiterList")
    nd_waiterList:removeAllChildrenWithCleanup(true)
    local tb = self:createWaiterList(nd_waiterList:getContentSize(), self.selectZcId == 1 and employ_waiter or employ_list)
    nd_waiterList:addChild(tb)
    tb:setScrollBarVisible(false)
    -- lb_max
    local lb_max = self.m_ccbNode:labelTTFForName("lb_max")
    lb_max:setString("Max số lượng Thuê: " .. #self.m_tGameData.employ_list .. "/" .. self.m_tGameData.max_num)
end

--[[--
    初始化
]]
function game_godfield_guild_high_war_employ_guild_index.init(self, t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
    else
        self.m_tGameData = {}
    end

    self.ext = t_params.ext or {}
end

--[[--
    创建入口
]]
function game_godfield_guild_high_war_employ_guild_index.create(self, t_params)
    self:init(t_params)
    local rootScene = CCScene:create()
    rootScene:addChild(self:createUi())
    self:refreshUi()
    return rootScene
end

function game_godfield_guild_high_war_employ_guild_index:createLeftList(viewSize, showData)
    local params = {}
    params.viewSize = viewSize
    params.row = 3 --行
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
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_employ_waiterLeftItem.ccbi")
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
            ccbNode:labelTTFForName("lb_name"):setString(data.tx)
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, cell)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell))
        local data = showData[index + 1]
        self.selectZcId = data.id
        self:refreshUi()
    end
    return TableViewHelper:create(params)
end

function game_godfield_guild_high_war_employ_guild_index:createWaiterList(viewSize, showData)
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
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_employ_waiterItem.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5))
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then
            cell:setTag(index)
            local ccbNode = tolua.cast(cell:getChildByTag(10), "luaCCBNode")
            local data = showData[index + 1]

            -- 所在公会
            ccbNode:labelTTFForName("lb_oldGuild"):setString(data.association_name)
            game_util.adaptNodeScaleX(ccbNode:labelTTFForName("lb_oldGuild"), 65.6)
            -- 玩家名称
            ccbNode:labelTTFForName("lb_name"):setString(data.name)
            game_util.adaptNodeScaleX(ccbNode:labelTTFForName("lb_name"), 65.6)
            -- 等级
            ccbNode:labelTTFForName("lb_lv"):setString(data.level)
            game_util.adaptNodeScaleX(ccbNode:labelTTFForName("lb_lv"), 20)
            -- 战力
            ccbNode:labelTTFForName("lb_combat"):setString(data.combat)
            game_util.adaptNodeScaleX(ccbNode:labelTTFForName("lb_combat"), 60)

            ccbNode:nodeForName("nd_refuse"):setVisible(self.selectZcId == 1)
            ccbNode:nodeForName("nd_agree"):setVisible(self.selectZcId == 1)
            -- 拒绝
            local btn_refuse = ccbNode:controlButtonForName("btn_refuse")
            btn_refuse:addHandleOfControlEvent(
                function()
                    -- 拒绝申请
                    local function responseMethod(tag, gameData)
                        local data = gameData:getNodeWithKey("data")
                        data = json.decode(data:getFormatBuffer()) or {}
                        self.m_tGameData = data
                        self:refreshUi()
                    end
                    network.sendHttpRequest(responseMethod, game_url.getUrlForKey("guild_high_war_employ_refuse"), http_request_method.GET, {t_uid = data.uid}, "guild_high_war_employ_refuse")
                end,
                CCControlEventTouchUpInside
            )
            -- 同意
            local btn_agree = ccbNode:controlButtonForName("btn_agree")
            btn_agree:addHandleOfControlEvent(
                function()
                    local function responseMethod(tag, gameData)
                        local data = gameData:getNodeWithKey("data")
                        data = json.decode(data:getFormatBuffer()) or {}
                        self.m_tGameData = data
                        self:refreshUi()
                    end
                    network.sendHttpRequest(responseMethod, game_url.getUrlForKey("guild_high_war_employ_agree"), http_request_method.GET, {t_uid = data.uid}, "guild_high_war_employ_agree")
                end,
                CCControlEventTouchUpInside
            )
            -- 解雇
            local btn_noEmploy = ccbNode:controlButtonForName("btn_noEmploy")
            btn_noEmploy:setVisible(self.selectZcId == 2)
            btn_noEmploy:addHandleOfControlEvent(
                function()
                    local t_params = {
                        title = "Hiển thị",
                        okBtnCallBack = function(target, event)
                            local function responseMethod(tag, gameData)
                                local data = gameData:getNodeWithKey("data")
                                data = json.decode(data:getFormatBuffer()) or {}
                                self.m_tGameData = data
                                self:refreshUi()
                            end
                            network.sendHttpRequest(responseMethod, game_url.getUrlForKey("guild_high_war_employ_remove"), http_request_method.GET, {t_uid = data.uid}, "guild_high_war_employ_remove")
                            require("game_ui.game_pop_up_box").close();
                        end, --可缺省
                        cancelBtnCallBack = function(target, event)
                            require("game_ui.game_pop_up_box").close()
                        end, --可缺省
                        okBtnText = "Xác định", --可缺省
                        cancelBtnText = "Hủy",
                        text = "Xác định muốn Hủy Thuê Lính Đánh Thuê này?", --可缺省
                        onlyOneBtn = false --可缺省
                    }
                    require("game_ui.game_pop_up_box").show(t_params)
                end,
                CCControlEventTouchUpInside
            )
        end
        return cell
    end
    params.itemOnClick = function(eventType, index, cell)
    end
    return TableViewHelper:create(params)
end

function game_godfield_guild_high_war_employ_guild_index:getGuildItemStatus(data)
    local status = "canApply"
    local myUid = game_data:getUserStatusDataByKey("uid")
    if self.m_tGameData.employ_guild ~= "" then
        status = "hasEmploy" -- 玩家已经被雇佣
    elseif game_util:idInTableById(myUid, data.employ_black or {}) then
        status = "black" -- 当 玩家uid  在黑名单的时候  是退出过 不能再申请加入
    elseif game_util:idInTableById(myUid, data.employ_waiter or {}) then
        status = "hasApply" -- 已经申请加入
    elseif game_util.getTableLen(data.employ_list or {}) > 0 then
        status = "noEnoughPos" -- 已经无雇佣位置
    end
    return status
end

return game_godfield_guild_high_war_employ_guild_index
