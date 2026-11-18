--- 坠落之地
--- 探索成果
local game_godfield_guild_high_war_chance_end_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_select_index = nil,
};

--[[--
    销毁
]]
function game_godfield_guild_high_war_chance_end_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_chance_end_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_select_index = nil
end
--[[--
    返回
]]
function game_godfield_guild_high_war_chance_end_pop.back(self, need_callback)
    if need_callback then
        self:callBackFunc(self.m_tGameData)
    end
    game_scene:removePopByName("game_godfield_guild_high_war_chance_end_pop");
end


--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_chance_end_pop.createUi(self)
    self.m_select_index = 1
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 300 then -- 领取/确定
            if not self.m_got_reward or self.m_type ~= 2 then -- 可领取的成果
                local function responseMethod( tag, gameData )
                    if gameData ~= nil and tolua.type(gameData) == "util_json" then
                        local data = gameData:getNodeWithKey("data");
                        local reward = data:getNodeWithKey("reward")
                        if reward:getNodeCount() > 1 then
                            game_util:rewardTipsByJsonData(reward)
                        end
                        self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
                        self:back(true)
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_get_fate_reward"), http_request_method.GET, {city_id = self.m_buildingId},"guild_high_war_get_fate_reward")
            else
                self:back();
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    if ((self.m_type == 1 and self.m_is_win) or self.m_type == 4 or (self.m_type == 5 and self.m_is_win)) and #self.m_gift > 0 then
        ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_chance_end_pop1.ccbi");
    else
        ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_chance_end_pop2.ccbi");
    end
    
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    self.label_title = ccbNode:labelTTFForName("label_title") 
    self.label_title:setString("Thành quả thám hiểm")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)

    self.m_btn1 = ccbNode:controlButtonForName("m_btn1")
    self.m_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
    self.label_des = ccbNode:labelTTFForName("label_des") 
    
    if ((self.m_type == 1 and self.m_is_win) or self.m_type == 4 or (self.m_type == 5 and self.m_is_win)) and #self.m_gift > 0 then
        self.node_rewards = ccbNode:labelTTFForName("node_rewards") 
    end
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-12,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]

local tips_tab = {{32,36},{31},{33},{34},{35,37}}
function game_godfield_guild_high_war_chance_end_pop.refreshUi(self)
    local guild_high_war_text_cfg = getConfig(game_config_field.guild_high_war_text)
    local tips = tips_tab[self.m_type][1] or ""
    if #self.m_gift <= 0 then
        tips = tips_tab[self.m_type][2] or ""
    end
    if tips == "" then
        tips = tips_tab[self.m_type][1] or ""
    end

    if self.m_type == 1 or self.m_type == 5 then -- 战斗类型特殊判断
        if not self.m_is_win then
            tips = tips_tab[self.m_type][2] or ""
        end
    end

    local itemCfg = guild_high_war_text_cfg:getNodeWithKey(tostring(tips))
    local openMsg = itemCfg:getNodeWithKey("des"):toStr();
    self.label_des:setString(openMsg)

    --机遇类型，1普通挑战奖励（固定奖励较好），2对应坐牢，3对应白给，4对应直接奖励（随机），5对应精英怪奖励
    if ((self.m_type == 1 and self.m_is_win) or self.m_type == 4 or (self.m_type == 5 and self.m_is_win)) and #self.m_gift > 0 then
        local showData = self.m_gift
        self.node_rewards:removeAllChildrenWithCleanup(true);
        self.node_rewards:setContentSize(CCSizeMake(math.min(#showData*44, 250), 40))
        local tableView = self:createRewardTable(self.node_rewards:getContentSize(), showData, 0.6)
        self.node_rewards:addChild(tableView,10,10);
    end

end

function game_godfield_guild_high_war_chance_end_pop.createRewardTable(self,viewSize,rewardList,scale)
    local scale = scale or 0.5

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemCfg = rewardList[btnTag+1]
        game_util:lookItemDetal(itemCfg)
    end
    local count = #rewardList
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = count; --列
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionHorizontal;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5,0.5))
            node:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            cell:addChild(node)
            local itemGift = rewardList[index+1]
            local icon,name,count = game_util:getRewardByItemTable(itemGift, true)
            if icon then
                icon:setScale(scale)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,3))
                node:addChild(icon,10)
            end
            if name then
                local nameLabel = game_util:createLabelTTF({text = name})
                nameLabel:setColor(ccc3(250,180,0))
                nameLabel:setAnchorPoint(ccp(0.5, 0.5))
                nameLabel:setPosition(icon:getContentSize().width * 0.5, -7)
                icon:addChild(nameLabel, 11)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemCfg = rewardList[index+1]
            if not is_box then
                game_util:lookItemDetal(itemCfg)
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        
    end
    return TableViewHelper:create(params);
end

--[[--
    初始化
]]
function game_godfield_guild_high_war_chance_end_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_tParams = t_params
    self.m_type = t_params.type or 1 -- 结果类型
    self.m_gift = t_params.gift or {} -- 结果奖励
    self.m_buildingId = t_params.buildingId
    self.m_got_reward = t_params.got_reward
    self.m_is_win = t_params.is_win
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_guild_high_war_chance_end_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_godfield_guild_high_war_chance_end_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params)
    end
end

return game_godfield_guild_high_war_chance_end_pop;