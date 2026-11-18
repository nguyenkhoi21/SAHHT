---  周日战报信息
local game_godfield_arena_success = {
    m_root_layer = nil,
    btn_close = nil,
    m_list_view_node = nil,
    m_tGameData = nil,
    m_logs = nil,
    rewardTips = nil,
    m_close_btn = nil,
};

--[[--
    销毁
]]
function game_godfield_arena_success.destroy(self)
    cclog("--------game_godfield_arena_success  destroy ------")
    self.m_root_layer = nil;
    self.btn_close = nil;
    self.m_list_view_node = nil;
    self.m_tGameData = nil;
    self.m_logs = nil;
    self.rewardTips = nil;
    self.m_close_btn = nil;
end
--[[--
    返回
]]
function game_godfield_arena_success.back(self,type)
    local stage_id = self.m_tGameData.current_stage
    local params = {}
    params.stage_id = stage_id
    local function responseMethod( tag,gameData )
        local data = gameData:getNodeWithKey("data");
        local reward = data:getNodeWithKey("reward")
        game_util:rewardTipsByJsonData(reward) 
        game_scene:removePopByName("game_godfield_arena_success");
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_arena_receive_stage_up_reward"), http_request_method.GET, params,"god_arena_receive_stage_up_reward")
         
   
end

--[[--
    返回
]]
function game_godfield_arena_success.back2(self,type)
    game_scene:removePopByName("game_godfield_arena_success");  

end
--[[--
    读取ccbi创建ui
]]
function game_godfield_arena_success.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then --返回
            self:back();
        elseif btnTag == 101 then --关闭
            self:back2();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_godfield_arena_jinji.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer") 
    self.btn_close = ccbNode:controlButtonForName("m_ok_btn")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_list_view_node = ccbNode:nodeForName("m_list_view_node")
    self.m_liansai_tip = ccbNode:labelTTFForName("m_liansai_tip")
    self.btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY-16)
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-16)
    self.ccbNode = ccbNode
    local tempViewSize = self.m_list_view_node:getContentSize()
    
    self.m_list_view_node:addChild(self:createVsTableView(tempViewSize))
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 15,true);
    self.m_root_layer:setTouchEnabled(true);

    return ccbNode;
end
function game_godfield_arena_success.createVsTableView( self,viewSize )
    
    self.rewardTips = {"Chúc mừng bạn đã vào được vòng đấu Đồng, đây là phần thưởng của bạn","Chúc mừng bạn đã vào được vòng đấu Bạc, đây là phần thưởng của bạn","Chúc mừng bạn đã vào được vòng đấu Gold, đây là phần thưởng của bạn","Chúc mừng bạn đã vào được vòng đấu Bạch Kim, đây là phần thưởng của bạn","Chúc mừng bạn đã vào được vòng đấu Kim Cương, đây là phần thưởng của bạn","Chúc mừng bạn đã vào được vòng đấu Vương Giả, đây là phần thưởng của bạn"}
    local reward = getConfig(game_config_field.godfield_arena_reward);
    local num = self.m_tGameData.current_stage or 1; --当前阶段
    local tips = " ";
    if self.rewardTips[tonumber(num)] then
        tips = self.rewardTips[tonumber(num)];
    end
    
    self.m_liansai_tip:setString(tips);
    reward = json.decode(reward:getNodeWithKey(num):getNodeWithKey("stage_reward"):getFormatBuffer())
    local showData = reward or {}
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 4; --列
    params.totalItem = #showData
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local icon,name,count = game_util:getRewardByItemTable(showData[index+1],false)
            if icon then
                icon:setScale(0.6);
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
                cell:addChild(icon)
            end
            if count then
                local tempLabel = game_util:createLabelBMFont({text = "×" .. count,color = ccc3(255,255,255),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.1))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(showData[index+1])
        end
    end
    return TableViewHelper:create(params);
    -- body
end


--[[--
    刷新ui
]]
function game_godfield_arena_success.refreshUi(self)

end

--[[--
    初始化
]]
function game_godfield_arena_success.init(self,t_params)
    t_params = t_params or {};
    -- body
    --cclog2(t_params,"t_params === ")
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    elseif tolua.type(t_params.gameData) == "table" then
        self.m_tGameData = t_params.gameData
    end

    self.m_logs = self.m_tGameData.logs or {}

    self.rewardTips = {}

end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_arena_success.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_arena_success;