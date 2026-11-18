---  成员信息 职位调整

local game_serverGuild_task_pop = {
    m_tGameData = nil,
    m_label_des = nil,
    m_node_tableView = nil,
    m_select_index = nil,
    m_btn_one = nil,
    m_btn_guild = nil,
    m_rewardTips = nil,
}
--[[--
    销毁ui
]]
function game_serverGuild_task_pop.destroy(self)
    -- body
    cclog("-----------------game_serverGuild_task_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_label_des = nil;
    self.m_node_tableView = nil;
    self.m_select_index = nil;
    self.m_btn_one = nil;
    self.m_btn_guild = nil;
    self.m_rewardTips = nil;
   
end
--[[--
    返回
]]
function game_serverGuild_task_pop.back(self,backType)
    game_scene:removePopByName("game_serverGuild_task_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_serverGuild_task_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then
            self.m_btn_one:setHighlighted(true)
            self.m_btn_guild:setHighlighted(false)
            self.m_select_index = 1
            self:refreshUi()
        elseif btnTag == 102 then
            self.m_btn_one:setHighlighted(false)
            self.m_btn_guild:setHighlighted(true)
            self.m_select_index = 2
            self:refreshUi()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_serverGuild_task.ccbi");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    self.m_btn_one = ccbNode:controlButtonForName("m_btn_one")
    self.m_btn_one:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    self.m_btn_guild = ccbNode:controlButtonForName("m_btn_guild")
    self.m_btn_guild:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    self.m_btn_one:setHighlighted(true)
    self.m_label_des = ccbNode:labelTTFForName("m_label_des")
    self.m_label_des:setString("Đạt điều kiện có thể nhận quà tương ứng")
    self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")
    -- local m_btn_select = ccbNode:controlButtonForName("m_btn_select")
    -- m_btn_select:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    local function onTouch( eventType, x, y )
        if eventType == "began" then
            return true;--intercept event
        end
    end
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    m_root_layer:registerScriptTouchHandler(onTouch, false, GLOBAL_TOUCH_PRIORITY-1, true)
    m_root_layer:setTouchEnabled(true);
    self.m_label_des = ccbNode:labelTTFForName("m_label_des")
    return ccbNode;
end

function game_serverGuild_task_pop.createTableView(self,viewSize)
    local showData = self.m_tGameData[tostring(self.m_select_index)]
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 999 then
            game_util:addMoveTips({text = "Chưa hoàn thành nhiệm vụ, không thể nhận"})
        elseif btnTag == 888 then
            game_util:addMoveTips({text = "Bạn đã nhận phần quà này"})
        elseif btnTag > 200 then
            local reward_id = btnTag - 200
            local rewardCfg = getConfig(game_config_field.new_guild_reward_week)
            
            local rewardData = json.decode(rewardCfg:getNodeWithKey(tostring(reward_id)):getFormatBuffer())
            self:createRewardTipsPop(rewardData,1,tagNode)
        else
            local tp = "week"
            if self.m_select_index == 2 then
                tp = "month"
            end
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer())
                game_util:rewardTipsByDataTable(self.m_tGameData.reward)
                self:refreshUi()
                -- game_scene:enterGameUi("game_server_guildbattle_main",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_get_week_reward"), http_request_method.GET, {reward_id = showData[btnTag].id, tp = tp},"new_guild_fight_get_week_reward")
            
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.totalItem = game_util:getTableLen(showData)
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    params.showPageIndex = self.m_curPage;
    params.showPoint = false
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_serverGuild_taskItem.ccbi");
            -- ccbNode:setAnchorPoint(ccp(0.5,0.5));
            -- local offsetY = 0
            -- offsetY = math.floor(index/5)*7
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
           local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
           local itemData = showData[index + 1]
           local m_btn_get = ccbNode:controlButtonForName("m_btn_get")
           local m_label_task = ccbNode:labelTTFForName("m_label_task")
           local m_label_get1 = ccbNode:labelTTFForName("m_label_get1")
           local m_label_get2 = ccbNode:labelTTFForName("m_label_get2")
           m_label_task:setString(tostring(index + 1 ))
           m_btn_get:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
           local str_des = itemData.des
           m_label_task:setString(str_des)
           m_btn_get:setTag(index + 1)
           local tp = itemData.tp
           if tp == 0 then --不可以领取
                m_btn_get:setTag(999)
                m_btn_get:setColor(ccc3(80,80,80))
                m_label_get1:setVisible(false)
                m_label_get2:setVisible(false)
                m_btn_get:setVisible(true)
            elseif tp == 1 then -- 可以领取
                m_btn_get:setTag(index + 1)
                m_btn_get:setColor(ccc3(255,255,255))
                m_label_get1:setVisible(false)
                m_label_get2:setVisible(false)
                m_btn_get:setVisible(true)
            elseif tp == 2 then --已经领取
                m_btn_get:setTag(888)
                m_btn_get:setColor(ccc3(80,80,80))
                m_label_get1:setVisible(true)
                m_label_get2:setVisible(true)
                m_btn_get:setVisible(false)

            end

            local m_btn_box = ccbNode:controlButtonForName("m_btn_box")
            m_btn_box:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
            local rewardID = itemData.id
            m_btn_box:setTag(rewardID+200)

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        end
    end
   
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_serverGuild_task_pop.refreshUi(self)
   self.m_node_tableView:removeAllChildrenWithCleanup(true)
   local m_tableView = self:createTableView(self.m_node_tableView:getContentSize())
   self.m_tableView = m_tableView:getChildByTag(10)
   self.m_node_tableView:addChild(m_tableView)
end

function game_serverGuild_task_pop.createRewardTipsPop(self,data, reward_index,clickNode)
    if self.m_rewardTips then return end
    local tag = tag
    local data = data
    local reardNode = CCNode:create();
    local rewardHeight = 0;
    if data then
        local reward = data.week
        -- cclog2(reward,"reward ---- ")
        if reward then
            local rewardCount = game_util:getTableLen(reward) --reward:getNodeCount();
            -- cclog("rewardCount===== " .. rewardCount)
            rewardHeight = 30*rewardCount
            reardNode:setContentSize(CCSizeMake(100, rewardHeight))
            for i=1,rewardCount do
                local icon,name = game_util:getRewardByItemTable(reward[i],true);
                -- cclog("icon == " .. tostring(icon) .. " name = " .. tostring(icon))
                if icon then
                    icon:setScale(0.5);
                    icon:setPosition(ccp(30, rewardHeight - 30*(0.5 + i - 1)))
                    reardNode:addChild(icon)
                end
                if name then
                    local tempLabel = game_util:createLabelTTF({text = name,color = ccc3(250,180,0),fontSize = 10});
                    tempLabel:setPosition(ccp(80, rewardHeight - 30*(0.5 + i - 1)))
                    reardNode:addChild(tempLabel)
                end
            end
        end
    end
    local bgSpr = CCScale9Sprite:createWithSpriteFrameName("public_pop_box_back.png");
    local viewSize = CCSizeMake(130,30 + rewardHeight);
    bgSpr:setPreferredSize(viewSize);
    reardNode:setPositionY(10)
    bgSpr:addChild(reardNode)
    local arrow = CCSprite:createWithSpriteFrameName("public_pop_box_arror.png")
    local arrowSize = arrow:getContentSize();
    arrow:setPosition(ccp(viewSize.width*0.5,0));
    arrow:setRotation(-90);
    bgSpr:addChild(arrow);
    local titleLabel = game_util:createLabelTTF({text = "Thưởng",color = ccc3(250,180,0),fontSize = 14});
    titleLabel:setPosition(ccp(viewSize.width*0.5, viewSize.height - 10))
    bgSpr:addChild(titleLabel)
    local px,py = clickNode:getPosition();
    local tempSize = clickNode:getContentSize();
    bgSpr:setAnchorPoint(ccp(0.5,0));
    local pos = clickNode:getParent():convertToWorldSpace(ccp(px,py+arrowSize.height));
    bgSpr:setPosition(pos);
    if reward_index == 1 then
        arrow:setPositionX(viewSize.width*0.15 - 2);
        bgSpr:setPositionX(pos.x + bgSpr:getContentSize().width * 0.4 - 2);
    end
    self.m_rewardTips = CCLayer:create();
    self.m_rewardTips:addChild(bgSpr);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            if self.m_rewardTips then
                self.m_rewardTips:removeFromParentAndCleanup(true);
                self.m_rewardTips = nil;
            end
            return true;--intercept event
        end
    end
    self.m_rewardTips:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_rewardTips:setTouchEnabled(true);
    game_scene:getPopContainer():addChild(self.m_rewardTips);
end


--[[--
    初始化
]]
function game_serverGuild_task_pop.init(self,t_params)
    self.m_select_index = 1
    t_params = t_params or {};
    -- body
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer());
    end
  -- cclog2(self.m_tGameData,"m_tGameData ==== ")
end

--[[--
    创建ui入口并初始化数据
]]
function game_serverGuild_task_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_serverGuild_task_pop;