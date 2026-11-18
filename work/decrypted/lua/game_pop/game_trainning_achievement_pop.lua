--- 龙虎榜 培养赛

local game_trainning_achievement_pop = {
    m_tGameData=nil,
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    m_select ={},
    m_show_node = nil,
    m_types = nil,
    m_show_table ={},
    m_tableView = nil,
    m_key_table = nil,
    m_layer = nil,
   };
--[[--
    销毁
]]
function game_trainning_achievement_pop.destroy(self)
    -- body
    cclog("-----------------game_trainning_achievement_pop destroy-----------------");
    self.m_tGameData=nil;
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_select ={};
    self.m_show_node = nil;
    self.m_types = nil;
    self.m_show_table ={};  
    self.m_tableView = nil;
    self.m_key_table = nil;
    self.m_layer = nil;

end
--[[--
    返回
]]
function game_trainning_achievement_pop.back(self,type)
    game_scene:removePopByName("game_trainning_achievement_pop");
    -- game_scene:addPop("game_training")
    -- cclog("lijiaxingnnnnnnnnnñ2222222")
    self:destroy();
    -- cclog("lijiaxingnnnnnnnnnñ333333")
end

function game_trainning_achievement_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag ==1 then  --关闭
            self:back();
        elseif btnTag == 2  then --进阶
            self.m_types = 1 
            self.m_select[1]:setTouchEnabled(false)
            self.m_select[2]:setTouchEnabled(true)
            self.m_select[3]:setTouchEnabled(true)
            self.m_select[1]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_trainning_btn_jinjie1.png"),CCControlStateNormal);
            self.m_select[2]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_trainning_btn_chaojinhua2.png"),CCControlStateNormal);
            self.m_select[3]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_trainning_btn_zhuansheng2.png"),CCControlStateNormal);
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer())
                self.m_show_table = self.m_tGameData.all_reward
                -- self.m_show_table[tostring(self.m_key_table[index+1].step)].reward
                self:refreshUi()

                
             end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("trainning_reward"), http_request_method.GET, {training_type = "step"},"trainning_reward");
        elseif btnTag == 3 then  --超进化
            self.m_types =2 
            self.m_select[1]:setTouchEnabled(true)
            self.m_select[2]:setTouchEnabled(false)
            self.m_select[3]:setTouchEnabled(true)
            self.m_select[1]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_trainning_btn_jinjie2.png"),CCControlStateNormal);
            self.m_select[2]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_trainning_btn_chaojinhua1.png"),CCControlStateNormal);
            self.m_select[3]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_trainning_btn_zhuansheng2.png"),CCControlStateNormal);
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer())
                self.m_show_table = self.m_tGameData.all_reward
                self:refreshUi()
                    
             end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("trainning_reward"), http_request_method.GET, {training_type = "super_step"},"trainning_reward");
            

        elseif  btnTag == 4 then --转生
            self.m_types =3 
            self.m_select[1]:setTouchEnabled(true)
            self.m_select[2]:setTouchEnabled(true)
            self.m_select[3]:setTouchEnabled(false)
            self.m_select[1]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_trainning_btn_jinjie2.png"),CCControlStateNormal);
            self.m_select[2]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_trainning_btn_chaojinhua2.png"),CCControlStateNormal);
            self.m_select[3]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_trainning_btn_zhuansheng1.png"),CCControlStateNormal);
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer())
                self.m_show_table = self.m_tGameData.all_reward
                self:refreshUi()
                    
             end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("trainning_reward"), http_request_method.GET, {training_type = "bre"},"trainning_reward");
            


        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_trainning_achievement_pop.ccbi");  

    for i=1,3 do
        self.m_select[i] = ccbNode:controlButtonForName("m_select"..i)
        self.m_select[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY-13)
    end
    self.m_show_node = ccbNode:nodeForName("m_show_node")


    self.m_close_btn=ccbNode:controlButtonForName("m_close_btn")
    
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-13)

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    -- self.m_layer = ccbNode:layerForName("m_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then

        end
    end
    -- local function onTouch1(eventType, x, y)
    --     if eventType == "began" then
    --         -- return true;
    --     elseif eventType == "ended" then

    --     end
    -- end

    -- self.m_layer:registerScriptTouchHandler(onTouch1,false,GLOBAL_TOUCH_PRIORITY-10,true);
    -- self.m_layer:setTouchEnabled(true);
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end




function game_trainning_achievement_pop.refreshUi(self)    
    -- cclog("5675656756656")
    if self.m_types ==1 then 
        self.m_show_node:removeAllChildrenWithCleanup(true)
        self.m_tableView = self:createachieveTableView1(self.m_show_node:getContentSize());
        self.m_show_node:addChild(self.m_tableView,10,10);
    elseif self.m_types ==2  then 
        self.m_show_node:removeAllChildrenWithCleanup(true)
        self.m_tableView = self:createachieveTableView2(self.m_show_node:getContentSize());
        self.m_show_node:addChild(self.m_tableView,10,10);
    elseif self.m_types ==3  then 
        self.m_show_node:removeAllChildrenWithCleanup(true)
        self.m_tableView = self:createachieveTableView3(self.m_show_node:getContentSize());
        self.m_show_node:addChild(self.m_tableView,10,10);
    end
end
function game_trainning_achievement_pop.createRewardTable(self,viewSize,count1,rewardList)
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
    params.totalItem = count1;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionHorizontal;
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
            if   count1  == 1  then 
                if icon then
                icon:setScale(0.8)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.05))
                node:addChild(icon,10)
                end
                -- if name and count then
                --     local itemSize = node:getContentSize();
                --     local tempLabel = game_util:createLabelTTF({text = name.."x"..count,color = ccc3(255,255,255),fontSize = 8});
                --     tempLabel:setPosition(ccp(itemSize.width*0.5+30, itemSize.height*0.1-21))
                --     node:addChild(tempLabel,11);
                -- end
                 if name and count then
                    local itemSize = node:getContentSize();
                    local tempLabel = game_util:createLabelTTF({text ="x"..count,color = ccc3(255,255,255),fontSize = 10});
                    tempLabel:setPosition(ccp(itemSize.width*0.5+45, itemSize.height*0.1-12))
                    node:addChild(tempLabel,11);
                end
            else
                if icon then
                icon:setScale(0.8)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,2))
                node:addChild(icon,10)
                end
                -- if name and count then
                --     local itemSize = node:getContentSize();
                --     local tempLabel = game_util:createLabelTTF({text = name.."x"..count,color = ccc3(255,255,255),fontSize = 8});
                --     tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.1-21))
                --     node:addChild(tempLabel,11);
                -- end
                if name and count then
                    local itemSize = node:getContentSize();
                    local tempLabel = game_util:createLabelTTF({text = "x"..count,color = ccc3(255,255,255),fontSize = 10});
                    tempLabel:setPosition(ccp(itemSize.width*0.5+18, itemSize.height*0.1-12))
                    node:addChild(tempLabel,11);
                end
            end
            

            -- if count then
            --     local itemSize = node:getContentSize();
            --     local tempLabel = game_util:createLabelTTF({text = "x"..count,color = ccc3(255,255,255),fontSize = 8});
            --     tempLabel:setPosition(ccp(itemSize.width*0.9+20, itemSize.height*0.1-15))
            --     node:addChild(tempLabel,12);
            -- end


            local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
            button:setAnchorPoint(ccp(0.5,0.5))
            if count1 == 1 then
                button:setPosition(node:getContentSize().width * 0.5+35, node:getContentSize().height * 0.5)
            else
                button:setPosition(node:getContentSize().width * 0.5, node:getContentSize().height * 0.5)
            end
            button:setOpacity(0)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 15)
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
function game_trainning_achievement_pop.createachieveTableView1( self,viewSize )
    
    local function onCellBtnClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        -- cclog("btnTag = " .. btnTag)
        if btnTag > 100 and btnTag < 110 then
            index = btnTag-100
            if self.m_show_table[tostring(self.m_key_table[index].step)].flag[1] == 0 then --未达成条件
                    game_util:addMoveTips({text = "Bạn chưa đạt điều kiện này!"});
            else
                if self.m_show_table[tostring(self.m_key_table[index].step)].flag[2] == 1 then  --已领取 
                    game_util:addMoveTips({text = "Bạn đã nhận phần thưởng này!"});
                else
                    local function responseMethod(tag,gameData)
                        local data = gameData:getNodeWithKey("data")
                        -- cclog2(data,"data-=------------")
                        game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"))

                        local function responseMethod(tag,gameData)
                            local data = gameData:getNodeWithKey("data")
                            self.m_tGameData = json.decode(data:getFormatBuffer())
                            self.m_show_table ={}
                            self.m_show_table = self.m_tGameData.all_reward
                            self:refreshUi()
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("trainning_reward"), http_request_method.GET, {training_type = "step"},"trainning_reward");
                    -- local data = gameData:getNodeWithKey("data")
                    -- self.m_tGameData = json.decode(data:getFormatBuffer())
                    -- self.m_show_table = self.m_tGameData.all_reward

                    end
                    -- game_util:rewardTipsByJsonData(data:getNodeWithKey("all_reward"):getNodeWithKey(tostring(self.m_key_table[index+1].step)):getNodeWithKey("reward"))

                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("trainning_get_reward"), http_request_method.GET, {training_type = "step",training_level =self.m_key_table[index].step },"trainning_get_reward");
           
                end
            end
            -- cclog2(index,"index123-=---------------")
            
        end
    end
    local activityCount = #self.m_key_table
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 1; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 11; --列
    params.totalItem = activityCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);

    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create() 
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);           
            ccbNode:openCCBFile("ccb/ui_trainning_achieve_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0,0.5))
            ccbNode:setPosition(ccp(0,itemSize.height*0.5-2));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_btn_lingqu"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)

        end

        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_reward_node = ccbNode:nodeForName("m_reward_node")
            local m_limit_label = ccbNode:labelTTFForName("m_limit_label")
            local m_num_label = ccbNode:labelTTFForName("m_num_label")
            local m_btn_lingqu = ccbNode:controlButtonForName("m_btn_lingqu")
            m_btn_lingqu:setTag(101+index)
            -- m_btn_lingqu:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
            -- cclog2(index,"index-=-=------------")
            m_limit_label:setString("Tiến cấp đạt\n"..self.m_key_table[index+1].step.." Cấp X có thể nhận")
            m_num_label:setString("Số người đã đạt:"..self.m_show_table[tostring(self.m_key_table[index+1].step)].total)
            m_btn_lingqu:setColor(ccc3(255,255,255))
            if self.m_show_table[tostring(self.m_key_table[index+1].step)].flag[1] == 0 then
                m_btn_lingqu:setColor(ccc3(100,100,100))
            end
            if self.m_show_table[tostring(self.m_key_table[index+1].step)].flag[2] == 1 then
                m_btn_lingqu:setColor(ccc3(100,100,100))
            end
            m_reward_node:removeAllChildrenWithCleanup(true)
            local tempTable =  self:createRewardTable(m_reward_node:getContentSize(),#self.m_show_table[tostring(self.m_key_table[index+1].step)].reward,self.m_show_table[tostring(self.m_key_table[index+1].step)].reward)
            m_reward_node:addChild(tempTable)
        end
        return cell
    end
    return TableViewHelper:create(params);
end
function game_trainning_achievement_pop.chaojinhua( self,num )
    -- body
    local string = ""
    if num == 0 then 
        string = "Cam"
    elseif num == 1 then 
        string = "Cam+"
    elseif num == 2 then 
        string = "Cam++"
    elseif num == 3 then 
        string = "Đỏ"
    elseif num == 4 then 
        string = "Đỏ+"
    elseif num == 5 then 
        string = "Đỏ++"
    elseif num == 6 then 
        string = "Vàng"
    elseif num == 7 then 
        string = "Vàng+"
    elseif num == 8 then 
        string = "Vàng++"
    end
    return string
end

function game_trainning_achievement_pop.createachieveTableView2( self,viewSize )
    local function onCellBtnClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " .. btnTag)
        if btnTag > 100 and btnTag < 110 then
            index = btnTag-100
            if self.m_show_table[tostring(self.m_key_table[index].super_step)].flag[1] == 0 then --未达成条件
                    game_util:addMoveTips({text = "Bạn chưa đạt điều kiện này!"});
            else
                if self.m_show_table[tostring(self.m_key_table[index].super_step)].flag[2] == 1 then  --已领取 
                    game_util:addMoveTips({text = "Bạn đã nhận phần thưởng này!"});
                else
                    local function responseMethod(tag,gameData)
                        local data = gameData:getNodeWithKey("data")
                        -- cclog2(data,"data-=------------")
                        game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"))
                        local function responseMethod(tag,gameData)
                            local data = gameData:getNodeWithKey("data")
                            self.m_tGameData = json.decode(data:getFormatBuffer())
                            self.m_show_table ={}
                            self.m_show_table = self.m_tGameData.all_reward
                            self:refreshUi()
                        end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("trainning_reward"), http_request_method.GET, {training_type = "super_step"},"trainning_reward");
                    -- local data = gameData:getNodeWithKey("data")
                    -- self.m_tGameData = json.decode(data:getFormatBuffer())
                    -- self.m_show_table = self.m_tGameData.all_reward
                   
                    -- game_util:rewardTipsByJsonData(data:getNodeWithKey("all_reward"):getNodeWithKey(tostring(self.m_key_table[index+1].step)):getNodeWithKey("reward"))

                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("trainning_get_reward"), http_request_method.GET, {training_type = "super_step",training_level =self.m_key_table[index].super_step },"trainning_get_reward");
            
                end
            end
            -- cclog2(index,"index123-=---------------")
            
        end
    end
    local activityCount = #self.m_key_table
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 1; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 11; --列
    params.totalItem = activityCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);

    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create()            
           ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);           
            ccbNode:openCCBFile("ccb/ui_trainning_achieve_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0,0.5))
            ccbNode:setPosition(ccp(0,itemSize.height*0.5-2));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_btn_lingqu"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
        end

        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_reward_node = ccbNode:nodeForName("m_reward_node")
            local m_limit_label = ccbNode:labelTTFForName("m_limit_label")
            local m_num_label = ccbNode:labelTTFForName("m_num_label")
            local m_btn_lingqu = ccbNode:controlButtonForName("m_btn_lingqu")

            m_limit_label:setString("Siêu tiến hóa đến\n"..self:chaojinhua(self.m_key_table[index+1].super_step).."Có thể nhận")
            m_num_label:setString("Số người đã đạt:"..self.m_show_table[tostring(self.m_key_table[index+1].super_step)].total)
            m_btn_lingqu:setTag(101+index)
            m_btn_lingqu:setColor(ccc3(255,255,255))
            if self.m_show_table[tostring(self.m_key_table[index+1].super_step)].flag[2] == 1 then
                m_btn_lingqu:setColor(ccc3(100,100,100))
            end
            if self.m_show_table[tostring(self.m_key_table[index+1].super_step)].flag[1] == 0 then
                m_btn_lingqu:setColor(ccc3(100,100,100))
            end
            m_reward_node:removeAllChildrenWithCleanup(true)
            local tempTable =  self:createRewardTable(m_reward_node:getContentSize(),#self.m_key_table[index+1].reward_super_step,self.m_key_table[index+1].reward_super_step)
            m_reward_node:addChild(tempTable)
        end
        return cell
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
            -- if index ~= self.m_cur_selectitem_index then
            -- --     self.m_selected_index = index+1
            --     -- self:refreshUi()
            --     -- self:selectCellState(item , index)
            --     if game_data.setLeatestActivityIndex then game_data:setLeatestActivityIndex( showData[index + 1].activeIndex ) end
            --     self:setActiveContent(self.m_cur_selectitem_index + 1)
            -- end
        end
    end
    return TableViewHelper:create(params);
end
function game_trainning_achievement_pop.createachieveTableView3( self,viewSize )
    local function onCellBtnClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " .. btnTag)
        if btnTag > 100 and btnTag < 110 then
            index = btnTag-100
            -- cclog2(index,"index123-=---------------")
            if self.m_show_table[tostring(self.m_key_table[index].bre)].flag[1] == 0 then --未达成条件
                    game_util:addMoveTips({text = "Bạn chưa đạt điều kiện này!"});
            else
                if self.m_show_table[tostring(self.m_key_table[index].bre)].flag[2] == 1 then  --已领取 
                    game_util:addMoveTips({text = "Bạn đã nhận phần thưởng này!"});
                else
                    local function responseMethod(tag,gameData)
                        local data = gameData:getNodeWithKey("data")
                        -- cclog2(data,"data-=------------")
                        game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"))
                        local function responseMethod(tag,gameData)
                            local data = gameData:getNodeWithKey("data")
                            self.m_tGameData = json.decode(data:getFormatBuffer())
                            self.m_show_table ={}
                            self.m_show_table = self.m_tGameData.all_reward
                            self:refreshUi()
                        end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("trainning_reward"), http_request_method.GET, {training_type = "bre"},"trainning_reward");
                   end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("trainning_get_reward"), http_request_method.GET, {training_type = "bre",training_level =self.m_key_table[index].bre },"trainning_get_reward");
                end
            end        
        end
    end
    local activityCount = #self.m_key_table
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 1; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 11; --列
    params.totalItem = activityCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);

    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create()            
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);           
            ccbNode:openCCBFile("ccb/ui_trainning_achieve_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0,0.5))
            ccbNode:setPosition(ccp(0,itemSize.height*0.5-2));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_btn_lingqu"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
        end

        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_reward_node = ccbNode:nodeForName("m_reward_node")
            local m_limit_label = ccbNode:labelTTFForName("m_limit_label")
            local m_num_label = ccbNode:labelTTFForName("m_num_label")
            local m_btn_lingqu = ccbNode:controlButtonForName("m_btn_lingqu")

            m_limit_label:setString("Chuyển sinh đến\n"..self.m_key_table[index+1].bre.." Chuyển X có thể nhận")
            m_num_label:setString("Số người đã đạt:"..self.m_show_table[tostring(self.m_key_table[index+1].bre)].total)
            m_btn_lingqu:setTag(101+index)
            m_btn_lingqu:setColor(ccc3(255,255,255))

            if self.m_show_table[tostring(self.m_key_table[index+1].bre)].flag[2] == 1 then
                m_btn_lingqu:setColor(ccc3(100,100,100))
            end
            if self.m_show_table[tostring(self.m_key_table[index+1].bre)].flag[1] == 0 then
                m_btn_lingqu:setColor(ccc3(100,100,100))
            end
            m_reward_node:removeAllChildrenWithCleanup(true)
            local tempTable =  self:createRewardTable(m_reward_node:getContentSize(),#self.m_key_table[index+1].reward_bre,self.m_key_table[index+1].reward_bre)
            m_reward_node:addChild(tempTable)
        end
        return cell
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
            -- if index ~= self.m_cur_selectitem_index then
            -- --     self.m_selected_index = index+1
            --     -- self:refreshUi()
            --     -- self:selectCellState(item , index)
            --     if game_data.setLeatestActivityIndex then game_data:setLeatestActivityIndex( showData[index + 1].activeIndex ) end
            --     self:setActiveContent(self.m_cur_selectitem_index + 1)
            -- end
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    初始化
]]
function game_trainning_achievement_pop.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil then
        local data = t_params.gameData:getNodeWithKey("data");
         self.m_tGameData = json.decode(data:getFormatBuffer())
    else
        self.m_tGameData = {};
    end
   self.m_types = 1 -- 默认进阶
    -- cclog2(self.m_tGameData,"self.m_tGameData-=---------")
    self.m_version = t_params.version
    self.m_show_table ={}
    self.m_show_table = self.m_tGameData.all_reward
    -- cclog2(self.m_show_table,"self.m_show_table-=---------")
    self.m_key_table = {}
    -- for k,v in pairs(self.m_show_table) do
    --    self.m_key_table[num] = k
    --    num = num+1
    -- end

    self.m_achieve_cfg =json.decode(getConfig(game_config_field.achieve):getFormatBuffer())
    -- cclog2(self.m_achieve_cfg,"self.m_achieve_cfg-=---------") 
    local num =1 

    for k,v in pairs(self.m_achieve_cfg) do
        if v.version == self.m_version then 
            self.m_key_table[num] = v
            num = num+1
        end
    end
    local function sortfunction(data1,data2)
        -- return tonumber(data1) < tonumber(data2)
       
        return tonumber(data1.step) < tonumber(data2.step)
    end
    table.sort( self.m_key_table, sortfunction )
    -- cclog2(self.m_key_table,"self.m_key_table-=---------")
end
--[[--
    创建ui入口并初始化数据
]]
function game_trainning_achievement_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end



return game_trainning_achievement_pop;