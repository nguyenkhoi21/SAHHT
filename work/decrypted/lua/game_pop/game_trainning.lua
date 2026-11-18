--- 龙虎榜 培养赛

local game_trainning = {
    m_tGameData=nil,
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    m_btn_huodongxiangqing = nil,
    m_btn_gethero = nil,
    m_time_node = nil,
    m_btn_rank = nil,
    m_btn_achievement = nil,
    m_server_label = {},
    m_name_label ={},
    m_label = {},
    m_reward_node = {},
    m_rank_reward_cfg = nil,
    m_version = nil,
    m_rank_table = nil,
    m_power_label = nil,
    m_rank_label = nil,
    m_show_rank_node = nil,
    m_tableView = nil,
   };
--[[--
    销毁
]]
function game_trainning.destroy(self)
    -- body
    cclog("-----------------game_trainning destroy-----------------");
    self.m_tGameData=nil;
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_btn_huodongxiangqing = nil;
    self.m_btn_gethero =nil;
    self.m_time_node = nil;
    self.m_btn_rank = nil;
    self.m_btn_achievement = nil;
    self.m_server_label = {};
    self.m_name_label = {};
    self.m_label = {};
    self.m_reward_node = {};
    self.m_rank_reward_cfg = nil;
    self.m_version = nil;
    self.m_rank_table =nil;
    self.m_power_label = nil;
    self.m_rank_label = nil;
    self.m_show_rank_node = nil;
    self.m_tableView = nil;
end
--[[--
    返回
]]
function game_trainning.back(self,type)
    -- game_scene:removePopByName("game_training");
    game_scene:enterGameUi("game_main_scene")
    -- cclog("lijiaxingnnnnnnnnnñ2222222")
    self:destroy();
    -- cclog("lijiaxingnnnnnnnnnñ333333")
end

function game_trainning.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag ==1 then  --关闭
            -- cclog("lijiaxingnnnnnnnnnñ111111")
            self:back();
        elseif btnTag == 2 then  --活动详情
            game_scene:addPop("game_active_limit_detail_pop",{openType ="training",vision = self.m_version})
        elseif btnTag == 3 then --获取英雄 跳转热门活动
                function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_charge_active",{gameData = gameData})
                    self:destroy()
                end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_active_show"), http_request_method.GET, {},"active_active_show")
        elseif btnTag == 4 then  --排行奖励
            game_scene:addPop("game_trainning_rank_pop",{version = self.m_version})
        elseif btnTag == 5 then  --成就奖励
            local function responseMethod(tag,gameData)
                    game_scene:addPop("game_trainning_achievement_pop",{gameData = gameData,version =self.m_version});
             end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("trainning_reward"), http_request_method.GET, {training_type = "step"},"trainning_reward");
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_trainning_game.ccbi");  


    self.m_time_node = ccbNode:nodeForName("m_time_node")
    for i=1,3 do
       self.m_server_label[i]= ccbNode:labelTTFForName("m_server_label"..i)
       self.m_name_label[i]= ccbNode:labelTTFForName("m_name_label"..i)
       self.m_label[i]= ccbNode:labelTTFForName("m_label"..i)
       self.m_reward_node[i] = ccbNode:nodeForName("m_reward_node"..i)
       -- cclog2(self.m_rank_table,"#self.m_rank_table[i].reward-=----------22")
       -- cclog2(self.m_rank_table[tostring(i)].reward,"self.m_rank_table[i].reward-=----------")
       local tempTable =  self:createRewardTable(self.m_reward_node[i]:getContentSize(),#self.m_rank_table[i].reward,self.m_rank_table[i].reward)
        self.m_reward_node[i]:addChild(tempTable)
        if self.m_tGameData["data"].f_t_ranks[i] then 

            -- self.m_server_label[i]:setString(self.m_tGameData["data"].f_t_ranks[i].server_name.."\n"..self.m_tGameData["data"].f_t_ranks[i].name)
            self.m_label[i]:setVisible(false) 
            self.m_server_label[i]:setString(self.m_tGameData["data"].f_t_ranks[i].server_name)
            self.m_name_label[i]:setString(self.m_tGameData["data"].f_t_ranks[i].name)

        else
            self.m_label[i]:setString("Chưa kết toán")
            self.m_server_label[i]:setVisible(false) 
            self.m_name_label[i]:setVisible(false) 
            
        end
    end
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_show_rank_node = ccbNode:nodeForName("m_show_rank_node")


    self.m_rank_label = ccbNode:labelTTFForName("m_rank_label")
    self.m_power_label = ccbNode:labelTTFForName("m_power_label")
    self.m_close_btn=ccbNode:controlButtonForName("m_close_btn")
    self.m_btn_huodongxiangqing=ccbNode:controlButtonForName("m_btn_huodongxiangqing") 
    self.m_btn_rank=ccbNode:controlButtonForName("m_btn_rank")
    self.m_btn_achievement=ccbNode:controlButtonForName("m_btn_achievement")
    self.m_btn_gethero=ccbNode:controlButtonForName("m_btn_gethero")
    self.m_btn_rank:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_btn_huodongxiangqing:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_btn_achievement:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_btn_gethero:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    self.m_time_node:removeAllChildrenWithCleanup(true) --创建倒计时
    self:createTimeDown(self.m_time_node,self.m_tGameData["data"].r_time)

    local show_rank = self.m_tGameData["data"].show_ranks
    --创建排行榜
    self.m_show_rank_node:removeAllChildrenWithCleanup(true)
    self.m_tableView = self:createachieveTableView(self.m_show_rank_node:getContentSize(),show_rank);
    self.m_show_rank_node:addChild(self.m_tableView,10,10);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then

        end
    end
    --排名。及战力
    self.m_rank_label:setString(tostring(self.m_tGameData["data"].rank_own))
    self.m_power_label:setString(tostring(math.floor(self.m_tGameData["data"].combat_own)))

    --创建动画
    
    local m_trainning_cfg =json.decode(getConfig(game_config_field.training):getFormatBuffer()) 
    self.m_anim_node:removeAllChildrenWithCleanup(true)
    self:createAnimNode(m_trainning_cfg[tostring(self.m_version)].show[1][2])
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 1,true);
    self.m_root_layer:setTouchEnabled(true);


    return ccbNode;
end
function game_trainning.createachieveTableView( self,viewSize,show_rank )
    local activityCount = 5
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 5; --列
    params.totalItem = activityCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);

    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create()            
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end

        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemSize = ccbNode:getContentSize();
            ccbNode:removeAllChildrenWithCleanup(true)
            -- cclog("111111")
            -- cclog2(show_rank,"show_rank-=-------------")
            -- local show_table = show_rank:toStr()
            if show_rank[index+1] then 
                -- cclog("222222")
                local tempLabel = game_util:createRichLabelTTF({text = show_rank[index+1].rank.."."..show_rank[index+1].name.."("..show_rank[index+1].server_name..")---"..(math.floor(show_rank[index+1].combat)),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize=8})
                tempLabel:setPosition(ccp(itemSize.width*0.5-70, itemSize.height*0.5))

                tempLabel:setAnchorPoint(ccp(0,0));
                ccbNode:addChild(tempLabel,11);
            -- cell:addChild(ccbNode)
            end
        end
        return cell
    end
    params.itemOnClick = function(eventType,index,item)
        
    end
    return TableViewHelper:create(params);
end
function game_trainning.createTimeDown( self,parentNode,time_count_down,shwoType,isclose )
    
    local function timeEndFunc()
       
    end
    parentNode:removeAllChildrenWithCleanup(true)
    local shwoType = shwoType or 3
    local countdownLabel = game_util:createCountdownLabel(time_count_down,timeEndFunc,8, shwoType);
    -- countdownLabel:setColor(ccc3(74, 249, 69))
    -- countdownLabel:setColor(ccc3(0, 159, 0))
    countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    local tempcontent = parentNode:getContentSize()
    countdownLabel:setPosition(ccp(tempcontent.width*0.5+10,tempcontent.height*0.6))
    parentNode:addChild(countdownLabel,10,10) 
end

function game_trainning.createAnimNode(self,cardId)
        -- local character_detail_cfg = getConfig(game_config_field.character_detail);
        -- local heroCfg = character_detail_cfg:getNodeWithKey(tostring(cardId));
        -- local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        -- local animNode = nil
        -- animNode = game_util:createIdelAnim(ainmFile,0,cardData,heroCfg);

        local cardData,heroCfg = game_data:getCardDataById(tostring(cardId));
        local character_detail_cfg = getConfig(game_config_field.character_detail);
        local itemCfg = character_detail_cfg:getNodeWithKey(tostring(cardId));
        if itemCfg == nil then return end
        local animFile = itemCfg:getNodeWithKey("animation"):toStr();
        local anim = nil
    -- if skillID == 5 then
    --     self.m_layer_bofang:setVisible(true)
    --     self.m_btn_bofang:setVisible(true)
    --     anim  = game_util:createAnimSequence2(animFile,0,nil,itemCfg,1)
    -- else
        -- self.m_layer_bofang:setVisible(false)
        -- self.m_btn_bofang:setVisible(false)
        anim  = game_util:createAnimSequence2(animFile,0,nil,itemCfg,3)
        if anim then
            anim:setRhythm(1);
            anim:setAnchorPoint(ccp(0.5,0));
            anim:setScale(0.85);
            self.m_anim_node:addChild(anim);
        end
end
--[[
    奖励列表
]]
function game_trainning.createRewardTable(self,viewSize,count,rewardList)
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemCfg = rewardList[btnTag+1]
        game_util:lookItemDetal(itemCfg)
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 2; --列
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
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
            local itemGift = rewardList[index+1]
            local icon,name,count = game_util:getRewardByItemTable(itemGift)
            -- cclog2(name,"name-=-------------")
            if icon then
                icon:setScale(0.5)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,2))
                node:addChild(icon,10)
            end
            if count  then 
                local itemSize = node:getContentSize();
                local tempLabel = game_util:createLabelTTF({text = "x"..count,color = ccc3(255,255,255),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.8+8, itemSize.height*0.1-8))
                node:addChild(tempLabel,11);
            end


            local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
            button:setAnchorPoint(ccp(0.5,0.5))
            button:setPosition(node:getContentSize().width * 0.5, node:getContentSize().height * 0.5)
            button:setOpacity(0)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5)
            node:addChild(button)
            button:setTag( index )

            cell:addChild(node)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemCfg = rewardList[index+1]
            game_util:lookItemDetal(itemCfg)
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        
    end
    return TableViewHelper:create(params);
end


function game_trainning.refreshUi(self)       
end



--[[--
    初始化
]]
function game_trainning.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil then
        local data = t_params.gameData:getNodeWithKey("data");
         self.m_tGameData = json.decode(data:getFormatBuffer())
    else
        self.m_tGameData = {};
    end
    -- cclog2(t_params,"t_params-=-------------")
    -- cclog2(self.m_tGameData,"self.m_tGameData-=-----------")
    self.m_version = self.m_tGameData["data"].version
    self.m_rank_reward_cfg =json.decode(getConfig(game_config_field.rank_reward):getFormatBuffer()) 
    -- cclog2(self.m_rank_reward_cfg ,"self.m_rank_reward_cfg -=---------------")
    self.m_rank_table = {}
    for k,v in pairs(self.m_rank_reward_cfg) do
       if v.version == self.m_version then 
            k = k%7
            if k%7 == 0 then 
                k =7 
            end
            self.m_rank_table[k] =v
       end
    end
    -- cclog2(self.m_rank_table,"self.m_rank_table-=-----------")
end
--[[--
    创建ui入口并初始化数据
]]
function game_trainning.create(self,t_params)
    self:init(t_params);
    -- self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    -- self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]

return game_trainning;