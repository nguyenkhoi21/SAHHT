local game_worldTree_new_main = {
    m_time_node = nil,
    m_time_node2 = nil,
    m_tab_ui  = nil,
    m_lab_cost = nil,
    m_lab_num = nil,
    m_lab_surplse = nil,
    m_lab_odds = nil,
    m_lab_deslv = nil,
    m_lab_lv = nil,
    m_sp_jindutiaoBg = nil,
    m_sp_tree = nil,
    m_select_index = nil,
    m_layer_black = nil,
    m_tab_node = nil,
    m_node_tree = nil,
    m_anim_Flag = nil,
    m_node_reward = nil,
    m_tGameData = nil,
    world_tree_cfg = nil,
    world_tree_level_cfg = nil,
    m_final_rewards = nil,
    m_spblack_sp = nil,
    m_node_look = nil,
    m_sp_jiantou = nil,
    m_look_flag = nil,
    m_node_start = nil,
    m_node_end = nil,
};
--[[--
    销毁ui
]]
function game_worldTree_new_main.destroy(self)
    cclog(" ----------- game_worldTree_new_main destroy -------------- ")
    self.m_time_node = nil;
    self.m_time_node2 = nil;
    self.m_tab_ui  = nil;
    self.m_lab_cost = nil;
    self.m_lab_num = nil;
    self.m_lab_surplse = nil;
    self.m_lab_odds = nil;
    self.m_lab_deslv = nil;
    self.m_lab_lv = nil;
    self.m_sp_jindutiaoBg = nil;
    self.m_sp_tree = nil;
    self.m_select_index = nil;
    self.m_layer_black = nil;
    self.m_tab_node = nil;
    self.m_anim_Flag = nil;
    self.m_node_tree = nil;
    self.m_node_reward = nil;
    self.m_tGameData = nil;
    self.world_tree_cfg = nil;
    self.world_tree_level_cfg = nil;
    self.m_final_rewards = nil;
    self.m_spblack_sp = nil;
    self.m_node_look = nil;
    self.m_sp_jiantou = nil;
    self.m_look_flag = nil;
    self.m_node_start = nil;
    self.m_node_end = nil;


end
indexTab = {{1,1},{1,2},{1,3},{2,1},{2,2},{2,3},{3,1},{3,2},{3,3}};
--[[--
    返回
]]
function game_worldTree_new_main.back(self)
    game_scene:enterGameUi("game_main_scene")
end

local pos = {
    {{x = 207,y = 107},{x = 244,y = 141},{x = 295,y = 115}},
    {{x = 178,y = 171},{x = 262,y = 216},{x = 354,y = 170},{x = 298,y = 162},{x = 184,y = 228},{x = 319,y = 239}},
    {{x = 110,y = 165},{x = 262,y = 216},{x = 404,y = 168},{x = 318,y = 166},{x = 160,y = 251},{x = 360,y = 258},{x = 198,y = 175},{x = 243,y = 272},{x = 316,y = 240}},
}
--[[--
    读取ccbi创建ui
]]
function game_worldTree_new_main.createUi(self)
    local ccbNode = luaCCBNode:create();
    self.m_ccbNode = ccbNode
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then
            self:back()
        elseif btnTag > 100 and btnTag < 200 then
            self.m_select_index = btnTag - 100
            self.m_get_node:setVisible(true)
            self.m_get_node:setPosition(ccp(self.m_pos[self.m_select_index].x,self.m_pos[self.m_select_index].y))
        elseif btnTag == 665 then
            game_scene:addPop("game_active_limit_detail_pop",{openMsg = self.m_version_msg.notice})
        elseif btnTag == 666 then
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                data = json.decode(data:getFormatBuffer())
                game_util:rewardTipsByDataTable(data.reward)
                self.m_get_node:setVisible(false)
                self:init({gameData = data})
                self:refreshUi()
                -- game_scene:enterGameUi("game_worldTree_new_mian",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_tree_new_get_level_reward"), http_request_method.GET, {sort = self.m_select_index},"world_tree_new_get_level_reward")
        elseif btnTag == 667 then
            self.m_get_node:setVisible(false)
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                --game_scene:addPop("ui_vip_show_pop")
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
            --network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag == 668 then  --祈福
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                self:init({gameData = gameData})
                game_util:addMoveTips({text = "Cầu phúc thành công"})   --祈福成功
                self:refreshUi()
                -- game_scene:enterGameUi("game_worldTree_new_mian",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_tree_new_bless"), http_request_method.GET, nil,"world_tree_new_bless")
        elseif btnTag == 669 then
            local x,_ = self.m_node_look:getPosition()
            if x < 0 then
                self.m_node_look:setPositionX(0)
                self.m_sp_jiantou:setScaleX(-0.6)
                self.m_node_reward:setVisible(true)
                self.m_sprite9_showboard1:setVisible(true)
            else
                local director = CCDirector:sharedDirector()
                local gl_view = director:getOpenGLView()
                local size = gl_view:getFrameSize()
                if device_platform == "ios" and size.width / size.height > 2.0 then
                    self.m_node_look:setPositionX(-100)
                else
                    self.m_node_look:setPositionX(-120)
                end
                
                self.m_sp_jiantou:setScaleX(0.6)
                self.m_node_reward:setVisible(false)
                self.m_sprite9_showboard1:setVisible(false)
            end
        elseif btnTag == 664 then
            local x,_ = self.m_node_look1:getPosition()
            local winSize = CCDirector:sharedDirector():getVisibleSize();
            if x < winSize.width-display.wt then
                self.m_node_look1:setPositionX(winSize.width-display.wt)
                self.m_sp_jiantou1:setScaleX(-0.6)
                self.m_node_reward1:setVisible(false)
                self.m_sprite9_showboard2:setVisible(false)
            else
                self.m_node_look1:setPositionX(winSize.width-120)
                self.m_sp_jiantou1:setScaleX(0.6)
                self.m_node_reward1:setVisible(true)
                self.m_sprite9_showboard2:setVisible(true)
            end   
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_worldTree_new.ccbi");
    self.m_time_node = ccbNode:nodeForName("m_time_node")
    self.m_time_node2 = ccbNode:nodeForName("m_time_node2")
    self.m_lab_qifu = ccbNode:labelTTFForName("m_lab_qifu")
    self.m_lab_juanzeng = ccbNode:labelTTFForName("m_lab_juanzeng")
    self.m_lab_surplse = ccbNode:labelTTFForName("m_lab_surplse")
    self.m_lab_odds = ccbNode:labelTTFForName("m_lab_odds")
    self.m_lab_deslv = ccbNode:labelTTFForName("m_lab_deslv")
    self.m_lab_lv = ccbNode:labelTTFForName("m_lab_lv")
    self.m_sp_jindutiaoBg = ccbNode:spriteForName("m_sp_jindutiaoBg")
    self.m_sprite9_showboard1 = ccbNode:scale9SpriteForName("m_sprite9_showboard1")
    self.m_sprite9_showboard2 = ccbNode:scale9SpriteForName("m_sprite9_showboard2")
    self.m_sprite9_showboard2:setVisible(false)
    self.m_sp_tree = ccbNode:spriteForName("m_sp_tree")
    self.m_layer_black = ccbNode:layerForName("m_layer_black")
    self.m_node_reward = ccbNode:nodeForName("m_node_reward")
    self.m_node_reward1 = ccbNode:nodeForName("m_node_reward1")
    self.m_node_reward1:setVisible(false)
    self.m_node_reward:setVisible(false)
    self.m_sprite9_showboard1:setVisible(false)
    self.m_node_look = ccbNode:nodeForName("m_node_look")
    self.m_node_look1 = ccbNode:nodeForName("m_node_look1")
    self.m_sp_jiantou = ccbNode:spriteForName("m_sp_jiantou")
    self.m_sp_jiantou1 = ccbNode:spriteForName("m_sp_jiantou1")
    self.m_node_start = ccbNode:nodeForName("m_node_start")
    self.m_node_end = ccbNode:nodeForName("m_node_end")
    self.m_spblack_sp = ccbNode:spriteForName("m_spblack_sp")
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    self.m_spblack_sp:setScaleX(1.4)
    local m_btn_look = ccbNode:controlButtonForName("m_btn_look")
    m_btn_look:setOpacity(0)
    local m_btn_look1 = ccbNode:controlButtonForName("m_btn_look1")
    m_btn_look1:setOpacity(0)
    self.m_active_timelb1 = ccbNode:labelTTFForName("m_active_timelb1")
    self.m_active_timelb2 = ccbNode:labelTTFForName("m_active_timelb2")
    self.m_fruitNode_tab = {}
    for i=1,9 do
        self.m_fruitNode_tab[i] = ccbNode:nodeForName("m_fruit_node" .. i)
    end

    local director = CCDirector:sharedDirector()
    local gl_view = director:getOpenGLView()
    local size = gl_view:getFrameSize()
    if device_platform == "ios" and size.width / size.height > 2.0 then
        self.m_node_look:setPositionX(-100)  
    end

    self.m_lab_deslv:setString("Đóng góp cho Yggdrasill, mỗi ngày được nhận quà trái cây, và còn thưởng level hấp dẫn!")
    self.m_get_node = ccbNode:nodeForName("m_get_node")
    self.m_get_node:setVisible(false)
    return ccbNode;
end


--[[

{
  order_daily          = 0
  lv                   = 4
  version              = 1
  final_reward         = {
    1 = 1
    2 = 2
  }
  level_reward         = {
  }
  contribution_num     = 0
  _client_cache_update = {
  }
  exp                  = 19
  bless                = 0
}

]]
function game_worldTree_new_main.setProgress( self )
    local expBg = self.m_sp_jindutiaoBg
    local expBgSize = expBg:getContentSize(); 
    local current_score = self.m_tGameData.exp
    local lv = math.min(self.m_tGameData.lv,game_util:getTableLen(self.m_WorldTreeCfg))
    local score_max = self.m_WorldTreeCfg[lv].exp
    local percentage = current_score/score_max * 100  
    local params = {}
    params.percentage = percentage
    params.fileName = "worldTree_jindutiao.png"
    local expBarAdd = game_util:createProgressTimer(params)
    expBg:removeAllChildrenWithCleanup(true)
    expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
    expBg:addChild(expBarAdd,2,1);
end


function game_worldTree_new_main:createTableView( viewSize )
    self.m_final_ccb = {}
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag(); 
        local flag = self.m_final_rewards[btnTag]
        if not flag then
            local function responseMethod( tag,gameData )
                if gameData and tolua.type(gameData) == "util_json" then
                    local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {}
                    game_util:rewardTipsByDataTable(data.reward)
                    self:init({gameData = gameData})
                    self:refreshUi()
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_tree_new_get_final_reward"), http_request_method.GET, {sort = btnTag},"world_tree_new_get_final_reward")
        else
            game_util:addMoveTips({text = "Đã nhận"})   --已领取
        end   
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = #self.m_WorldTreeCfg;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-9;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_worldTree_new_rewardItem.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(viewSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local item = self.m_WorldTreeCfg[index+1]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            self.m_final_ccb[index+1] = ccbNode
            local m_lv_lb = ccbNode:labelTTFForName("m_lv_lb")
            m_lv_lb:setString("Lv" .. item.level)
            local m_getReward_btn = ccbNode:controlButtonForName("m_getReward_btn")
            local m_reward_node = ccbNode:nodeForName("m_reward_node")
            local m_alreadyGet_sp = ccbNode:spriteForName("m_alreadyGet_sp")
            m_getReward_btn:setTag(index+1)
            if self.m_tGameData.lv >= item.level then
                m_getReward_btn:setEnabled(true);
                m_getReward_btn:setColor(ccc3(255,255,255))
            else
                m_getReward_btn:setEnabled(false);
                m_getReward_btn:setColor(ccc3(81,81,81))
            end
            if self.m_final_rewards[item.level] then
                m_getReward_btn:setVisible(false)
                m_alreadyGet_sp:setVisible(true)
            else
                m_getReward_btn:setVisible(true)
                m_alreadyGet_sp:setVisible(false)
            end
            self:createRewardWithTabAndNode(m_reward_node,item.final_reward,index+1,"final_reward")
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
    end
    return TableViewHelper:create(params);
end



function game_worldTree_new_main:createTableView2( viewSize )
    self.m_final_ccb = {}


    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = #self.m_WorldTreeCfg;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-9;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_worldTree_new_fruitItem.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(viewSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local item = self.m_WorldTreeCfg[index+1]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_lv_lb = ccbNode:labelTTFForName("m_lv_lb")
            m_lv_lb:setString("Quả Lv." .. item.level)  --1级果实
            local m_reward_node = ccbNode:nodeForName("m_reward_node")
            self:createRewardWithTabAndNode(m_reward_node,item.level_reward,index+1,"level_reward")
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
    end
    return TableViewHelper:create(params);
end


function game_worldTree_new_main:createRewardWithTabAndNode(node, rewTab, index,flag)
    local pos = {
        {0.5},
        {0.35,0.65},
        {0.2,0.5,0.8},
    }
    pos = pos[#rewTab]
    local viewSize = node:getContentSize()
    node:removeAllChildrenWithCleanup(true)
    local function onBtnClick( event, target  )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("press button tag is ", btnTag)
        local index = math.floor(btnTag/10)
        local index2 = math.floor(btnTag%10)
        local reward = self.m_WorldTreeCfg[index][flag][index2]
        game_util:lookItemDetal(reward)
    end 
    for k,v in pairs(rewTab) do
        local icon,name,count = game_util:getRewardByItemTable(v,true)
        if icon then
            icon:setScale(0.5)
            icon:setPosition(ccp(viewSize.width*pos[k],viewSize.height*0.5))
            node:addChild(icon)
            local lb = game_util:createLabelTTF({text = "×" .. count,color = ccc3(255,255,255),fontSize = 13})
            local iconSize = icon:getContentSize()
            lb:setAnchorPoint(ccp(0,0.5))
            lb:setPosition(ccp(iconSize.width+3,5))
            icon:addChild(lb)
            local button = game_util:createCCControlButton("public_weapon.png","",onBtnClick)
            button:setAnchorPoint(ccp(0.5,0.5))
            button:setScale(0.5)
            button:setPosition( icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5 )
            button:setOpacity(0)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
            icon:addChild(button)
            button:setTag(index*10+k)
        end
    end
end


function game_worldTree_new_main:refreshFinalReward()
    self.m_node_reward:removeAllChildrenWithCleanup(true)
    local tempTab = self:createTableView(self.m_node_reward:getContentSize())
    if tempTab then
        self.m_node_reward:addChild(tempTab)
    end
end

function game_worldTree_new_main:refreshFruitReward()
    self.m_node_reward1:removeAllChildrenWithCleanup(true)
    local tempTab = self:createTableView2(self.m_node_reward1:getContentSize())
    if tempTab then
        self.m_node_reward1:addChild(tempTab)
    end
end

function game_worldTree_new_main:createBroadCastMsg()
    local expBg = self.m_sp_jindutiaoBg
    expBarAdd = ExtProgressTime:createWithFrameName("worldTree_jindutiaoBg.png","worldTree_jindutiao.png");
    self.bar = expBarAdd
    self.bar:setScaleX(1);
    local expBgSize = expBg:getContentSize(); 
    expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
    self.bar:setAnchorPoint(ccp(0.5,0.5))
    expBg:removeAllChildrenWithCleanup(true)
    expBg:addChild(self.bar,2,1);
end


--[[--
    刷新ui
]]
function game_worldTree_new_main.refreshUi(self)

    self.m_active_timelb1:setString("Thời gian kết thúc:" .. self.m_version_msg.end_time) --活动结束时间:
    self.m_active_timelb2:setString("Thời gian kết thúc:" .. self.m_version_msg.end_time)
    self.m_state = self.m_tGameData.lv ~= 0 and self.m_WorldTreeCfg[self.m_tGameData.lv].state or 1
    local tempPos = pos[self.m_state]
    self.m_pos = tempPos
    for i=1,9 do
        self.m_ccbNode:controlButtonForName("m_fruit_btn" .. i):setOpacity(0)
        if self.m_tGameData.exp >= self.m_WorldTreeCfg[i].exp and self.m_level_rewards[tostring(i)]~=1 then
            self.m_fruitNode_tab[i]:setVisible(true)
            self.m_fruitNode_tab[i]:setPosition(ccp(tempPos[i].x,tempPos[i].y))
        else
            self.m_fruitNode_tab[i]:setVisible(false)
        end
    end
    for i=1,3 do
        self.m_ccbNode:spriteForName("m_sp_tree" .. i):setVisible(i==self.m_state)
    end

    self:createBroadCastMsg()

    local lv = math.min(self.m_tGameData.lv,game_util:getTableLen(self.m_WorldTreeCfg))
    local exp1 = (lv == 0) and 0 or self.m_WorldTreeCfg[lv].exp
    local exp2 = (lv == #self.m_WorldTreeCfg) and self.m_WorldTreeCfg[lv].exp or self.m_WorldTreeCfg[lv+1].exp
    local maxValue = exp2 - exp1
    local curValue = self.m_tGameData.exp - exp1
    self.bar:setMaxValue(maxValue)
    self.bar:setCurValue(curValue,false);
    self.m_lab_lv:setString("Lv." .. self.m_tGameData.lv .. "(" .. self.m_tGameData.exp .. "/" .. exp2 .. ")")
    local left_free_time = self.m_version_msg.free_times - self.m_tGameData.bless 
    self.m_lab_qifu:setString("Số lần miễn phí:" .. left_free_time .. "/" .. self.m_version_msg.free_times)  --免费次数
    local time = self:getBlessTimes(self.m_tGameData.order_daily)
    local left_bless_time = self.m_version_msg.limit_time - time
    left_bless_time = left_bless_time < 0 and 0 or left_bless_time
    local text = (time < 1 and self.m_version_msg.bless_first or self.m_version_msg.bless_next) .. "Xu(" .. (left_bless_time) .. "/" .. self.m_version_msg.limit_time .. "lần)"
    self.m_lab_juanzeng:setString(text)
    self:refreshFinalReward()
    self:refreshFruitReward()
end

function game_worldTree_new_main:getBlessTimes(order_daily)
    local times = 0
    if order_daily < 200 then
        times = 0
    else
        times = math.floor((order_daily - 200)/500) + 1
    end
    return times
end
--[[--
    初始化
]]
function game_worldTree_new_main.init(self,t_params)
    t_params = t_params or {}
    self.m_level_rewards = {}
    local gameData = t_params.gameData
    if gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = gameData and gameData:getNodeWithKey("data")
         self.m_tGameData = data and json.decode(data:getFormatBuffer()) or {}
    elseif  gameData and tolua.type(t_params.gameData) == "table" then
         self.m_tGameData = gameData
    end
    cclog2(self.m_tGameData)
    self.m_version = self.m_tGameData.version or 1
    local new_world_tree_level_cfg =  getConfig(game_config_field.new_world_tree_level);
    self.m_WorldTreeCfg = {}
    for k,v in pairs(json.decode(new_world_tree_level_cfg:getFormatBuffer())) do
        if v.version == self.m_version then
           self.m_WorldTreeCfg[v.level] = v 
        end
    end
    if #self.m_tGameData.level_reward > 0 then
        for k,v in pairs(self.m_tGameData.level_reward) do
            self.m_level_rewards[tostring(v)] = 1
        end
    end
    self.m_final_rewards = {}
    if #self.m_tGameData.final_reward > 0 then
        for k,v in pairs(self.m_tGameData.final_reward) do
            print(k,v)
            self.m_final_rewards[v] = 1
        end
    end
    local new_world_tree_cfg = getConfig(game_config_field.new_world_tree);
    local msg = json.decode(new_world_tree_cfg:getNodeWithKey(tostring(self.m_version)):getFormatBuffer())
    self.m_version_msg = msg
    self.m_state = 1
end

--[[--
    创建ui入口并初始化数据
]]
function game_worldTree_new_main.create(self,t_params)
    self:init(t_params);
    local scene = self:createUi();
    self:refreshUi();
    return scene
end

return game_worldTree_new_main;
