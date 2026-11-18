local ui_guessing_football_achievement = {
    m_tGameData=nil,
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    m_end_time = nil,
    m_list_node = nil,
    m_id= {},
    m_get_list = {},
   };
--[[--
    销毁
]]
function ui_guessing_football_achievement.destroy(self)
    -- body
    cclog("-----------------ui_guessing_football_achievement destroy-----------------");
    self.m_tGameData=nil;
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_end_time = nil;
    self.m_list_node = nil;
    self.m_id  = {};
    self.m_end_time = {};
    
end
--[[--
    返回
]]
function ui_guessing_football_achievement.back(self,type)
    
    function shopOpenResponseMethod(tag,gameData)
        game_scene:removePopByName("ui_guessing_football_achievement");
        self:destroy();
        game_scene:addPop("ui_guessing_football_main",{gameData = gameData})
    end
     network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("world_cup_guess_index"), http_request_method.GET, {},"world_cup_guess_index")

end

function ui_guessing_football_achievement.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
            if self.m_flag ==true then 
                return 
            end
        if btnTag == 999 then
            self:back();
        elseif btnTag == 1 then 
           
       
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guessing_football_achievement.ccbi");  

    

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then

        end
    end

    self.m_list_node = ccbNode:nodeForName("m_list_node")


    self.m_close_btn=ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
   
    
    
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 6,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

function ui_guessing_football_achievement.createRewardTipsPop(self,data, reward_index,clickNode)
    -- if self.m_layer_reward then return end
    local tag = tag
    local data = data
    local reardNode = CCNode:create();
    local rewardHeight = 0;
    if data then
        local reward = data
        if reward then
            local rewardCount = game_util:getTableLen(reward) --reward:getNodeCount();
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
                    -- cclog("dsnfgdsnglnwobhrij")

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
    local titleLabel = game_util:createLabelTTF({text = "Phần thưởng",color = ccc3(250,180,0),fontSize = 14});
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
    self.m_layer_reward = CCLayer:create();
    self.m_layer_reward:addChild(bgSpr);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            if self.m_layer_reward then
                self.m_layer_reward:removeFromParentAndCleanup(true);
                self.m_layer_reward = nil;
            end
            return true;--intercept event
        
        end
    end
    self.m_layer_reward:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-6,true);
    self.m_layer_reward:setTouchEnabled(true);
    game_scene:getPopContainer():addChild(self.m_layer_reward);
end
function ui_guessing_football_achievement.createTableView(self,viewSize,showData)
    showData = showData or {}
    local showDataIds = {}
    for k,v in pairs(showData) do
        table.insert(showDataIds,k)
    end
    local one_piece_exchange_cfg = getConfig(game_config_field.server_one_piece_exchange)
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag ========== " .. btnTag)
        if  btnTag>=500 then 
            -- cclog2(self.world_achievement[btnTag-500]["reward"][1],"self.world_achievement[btnTag-500]-=-------")
            self:createRewardTipsPop(self.world_achievement[btnTag-500]["reward"],1,self.m_select[btnTag-500])
        else
            function responseMethod(tag,gameData )
                        -- body
                    if gameData then
                        local data = gameData:getNodeWithKey("data")
                        self.m_tGameData = json.decode(data:getFormatBuffer())
                        self.m_get_list = self.m_tGameData.achievement_log

                        game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"))
                        self:refreshUi()
                    end
                end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_cup_guess_get_achievement"), http_request_method.GET, {achieve_id = btnTag},"world_cup_guess_get_achievement")
        end
    end
    local params = {}
    params.viewSize = viewSize
    params.row = 3
    params.column = 1 -- 列
    params.direction = kCCScrollViewDirectionVertical
    params.totalItem = #self.m_id

    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);            
            ccbNode:openCCBFile("ccb/ui_guessing_football_ach_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0,0))
            ccbNode:setPosition(ccp(itemSize.width*0.1-40,itemSize.height*0.1-5));
            ccbNode:controlButtonForName("m_btn_get"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-6);
            ccbNode:controlButtonForName("m_reward_view"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-6);
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_ok_btn = ccbNode:controlButtonForName("m_btn_get")
            local m_reward_view = ccbNode:controlButtonForName("m_reward_view")
            local m_tips_label = ccbNode:labelTTFForName("m_label_des")
            local m_box  = ccbNode:spriteForName("m_box")
            m_reward_view:setOpacity(0)
            m_ok_btn:setTag(index+1)
            m_reward_view:setTag(index+501)
            self.m_select[index+1] =m_reward_view
            m_tips_label:setString("Từng có "..self.world_achievement[index+1].number.." Bình Xăng")
            if self.m_tGameData.oil_max >= self.world_achievement[index+1].number then 
                if self.m_get_list[tostring(index+1)] ~= 1 then 
                    m_box:setColor(ccc3(255,255,255))
                    m_ok_btn:setColor(ccc3(255,255,255))
                else
                    m_box:setColor(ccc3(100,100,100))
                    m_ok_btn:setColor(ccc3(100,100,100))
                end
            else
                m_box:setColor(ccc3(100,100,100))
                m_ok_btn:setColor(ccc3(100,100,100))
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
        end
    end
    return TableViewHelper:create(params);
end


function ui_guessing_football_achievement.refreshUi(self)      
    self.m_list_node:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_list_node:getContentSize());
    self.m_list_node:addChild(tableViewTemp,10,10);
end



--[[--
    初始化
]]
function ui_guessing_football_achievement.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil then
         self.m_tGameData = t_params.gameData
    end
    -- cclog2(self.m_tGameData,"self.m_tGameData = t_params.gameDatas-===-=-----")
    self.world_achievement = {}
    self.m_id = {}
    local world_achievement  = json.decode(getConfig(game_config_field.world_achievement):getFormatBuffer())
    self.world_achievement = world_achievement
    self.m_select = {} --存储前面宝箱按钮
    for k,v in pairs(world_achievement) do
        table.insert(self.m_id,k)
    end

    self.m_get_list = {}
    self.m_get_list = self.m_tGameData.achievement_log
    -- cclog2(self.m_get_list[tostring(1)],"self.m_get_list-=-------")

    for i=1,#self.m_id do
        self.world_achievement[i] = world_achievement[tostring(i)]
    end
end
--[[--
    创建ui入口并初始化数据
]]
function ui_guessing_football_achievement.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function ui_guessing_football_achievement.callBackFunc(self)
    local callBackFunc = self.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc();
    end
end

return ui_guessing_football_achievement;