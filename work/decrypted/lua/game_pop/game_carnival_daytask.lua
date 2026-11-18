--狂欢盛典 每日任务
-- Author: fan.xia
-- Date: 2019-05-15 11:41:15
--

--
-- Author: fan.xia
-- Date: 2019-03-27 10:16:50
--
local game_carnival_dailrecharge = {
	m_root_layer = nil,
    m_ccbNode = nil,
    m_quad_txt = nil,
    m_data = nil,
}

--[[--
    销毁
]]
function game_carnival_dailrecharge.destroy(self)
    -- body
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_quad_txt = nil;
    self.m_data = nil;
end

--[[--
    返回
]]
function game_carnival_dailrecharge.back(self,type)
    --回到activity
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = nil},{endCallFunc = function (  )
                self:destroy();
            end});
end


function game_carnival_dailrecharge.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
      
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_carnival_daytask.ccbi");

    self.m_ccbNode = ccbNode

    self.m_wread_node = ccbNode:nodeForName("m_wread_node")
    self.m_mask_node = ccbNode:nodeForName("m_mask_node")
    self.m_day_txt = ccbNode:labelTTFForName("m_day_txt")
   


    return ccbNode
end

--[[--
    创建列表
]]
function game_carnival_dailrecharge.createChallangeList( self, viewSize )
    local function onclick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();

        local function responseMethod(tag,gameData)
            local reward = gameData:getNodeWithKey("data"):getNodeWithKey("reward")
            local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
            cclog2(data,"data")
            self.m_data = data

            self:refreshUi()

            game_util:rewardTipsByJsonData(reward);
        end
        local params = {}
        params.active_id = btnTag
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("celebration_task_receive"), http_request_method.GET,params,"celebration_task_receive")
    end
   
    local itemCount = #self.m_showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 1;
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 2;
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height/params.row);
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell();
        if cell == nil then 
            cell = CCTableViewCell:new()
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onclick",onclick);
            ccbNode:openCCBFile("ccb/ui_carnival_tsak_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")   
            if ccbNode then 
                local showData = self.m_showData[index+1].data
                local state = self.m_showData[index+1].flag
                local id = self.m_showData[index+1].id
                local cur_num = self.m_showData[index+1].cur_num
                local need_num = self.m_showData[index+1].need_num

                local m_btn_reward = ccbNode:controlButtonForName("m_btn_reward")
                local m_wread_node = ccbNode:nodeForName("m_wread_node")
                local m_religq = ccbNode:spriteForName("m_religq")
                local m_item_count = ccbNode:labelTTFForName("m_item_count")
                local m_des = ccbNode:labelTTFForName("m_des")

                local icon,name,count = game_util:getRewardByItemTable(showData.reward[1])
                icon:setScale(0.8)
                m_item_count:setString(tostring(count))
                icon:setPosition(ccp(25,23))
                m_wread_node:addChild(icon)
                
                local str = showData.name.." ("..cur_num.."/"..need_num..")"
                m_btn_reward:setTag(tonumber(id))
                m_btn_reward:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
                m_des:setString(str)

                if state == 2 then  --已领取
                    m_religq:setVisible(true)
                    m_btn_reward:setEnabled(false)
                    m_btn_reward:setVisible(false)
                elseif state == 1 then
                    --todo
                    m_btn_reward:setColor(ccc3(255, 255, 255))
                    m_religq:setVisible(false)
                    m_btn_reward:setEnabled(true)
                    m_btn_reward:setVisible(true)
                elseif state == 0 then --不可领取
                    m_religq:setVisible(false)
                    m_btn_reward:setEnabled(false)
                    m_btn_reward:setVisible(true)
                    m_btn_reward:setColor(ccc3(88, 88, 88))
                end

            end

        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" then
            local info1 = self.m_showData[index+1].data.reward[1]
            if #info1 > 1 then
                local tempType = info1[1]
                if tempType == 6 then--道具
                    local itemId = info1[2]
                    game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
                elseif tempType == 7 then--装备
                    local equipId = info[2]
                    local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                    game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
                elseif tempType == 5 then--卡牌
                    local cId = info1[2]
                    game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
                else                   -- 食品
                    game_scene:addPop("game_food_info_pop",{itemData = info1})
                end
            end
        end
    end
    return TableViewHelper:create(params)
end

function game_carnival_dailrecharge.createTableView(self, viewSize)
    
    local cardsCount = #self.m_showScore
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 5; --列
    params.totalItem = cardsCount -- totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionHorizontal;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2
    
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            --ccbNode:registerFunctionWithFuncName("onclick",onclick);
            ccbNode:openCCBFile("ccb/ui_carnival_taskscore_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)

        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            if ccbNode then
                local m_wread_node = ccbNode:nodeForName("m_wread_node")
                local m_received = ccbNode:spriteForName("m_received")
                local m_religq = ccbNode:spriteForName("m_religq")
                local m_des = ccbNode:labelTTFForName("m_des")
                local m_wrid_count = ccbNode:labelTTFForName("m_wrid_count")

                local showData = self.m_showScore[index+1].data
                local state = self.m_showScore[index+1].flag

                local str = "Điểm:"..showData.sort
                m_des:setString(str)

                local icon,name,count = game_util:getRewardByItemTable(showData.reward[1])
                icon:setScale(0.7)
                m_wread_node:addChild(icon)
                m_wrid_count:setString(tostring(count))

                if index == cardsCount-1 then
                    m_religq:setVisible(false)
                else
                    m_religq:setVisible(true)
                end

                if state == 1 then  --可领取
                    m_received:setVisible(true)
                    icon:setColor(ccc3(255,255,255))
                else
                    m_received:setVisible(false)
                    icon:setColor(ccc3(88,88,88))
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" then
           if self.m_showScore[index+1].flag == 1 then
                local function responseMethod(tag,gameData)
                    local reward = gameData:getNodeWithKey("data"):getNodeWithKey("reward")
                    local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                    --cclog2(data,"data")
                    self.m_data = data
        
                    self:refreshUi()
        
                    game_util:rewardTipsByJsonData(reward);
                end
                local params = {}
                params.reward_id = self.m_showScore[index+1].id
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("celebration_task_score_receive"), http_request_method.GET,params,"celebration_task_score_receive")
           else
               local info1 = self.m_showScore[index+1].data.reward[1]
                local tempType = info1[1]
                if tempType == 6 then--道具
                    local itemId = info1[2]
                    game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
                elseif tempType == 7 then--装备
                    local equipId = info[2]
                    local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                    game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
                elseif tempType == 5 then--卡牌
                    local cId = info1[2]
                    game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
                else                   -- 食品
                    game_scene:addPop("game_food_info_pop",{itemData = info1})
                end
           end
           
            
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
       -- self.m_curPage = curPage;
    end
    local tableView = TableViewHelper:create(params);
    return tableView
end

function game_carnival_dailrecharge.refreshUi(self)
    self.m_showData = {}
    self.m_showScore = {}

    for k,v in pairs(self.m_data.task_record) do
        if self.cb_task[k] then
            table.insert(self.m_showData,{data = self.cb_task[k], flag = v.flag, id = k, cur_num = v.cur_num,need_num = v.need_num})
        end
    end

    table.sort( self.m_showData, function ( a,b )
        return a.id<b.id
    end )
    
    for k,v in pairs(self.m_data.score_record) do
        if self.cb_task_reward[k] then
            table.insert(self.m_showScore,{data = self.cb_task_reward[k], flag = v.flag, id = k})
        end
    end

    table.sort( self.m_showScore, function ( a,b )
        return a.data.sort<b.data.sort
    end )

    self.m_mask_node:removeAllChildrenWithCleanup(true)
    local view = self:createChallangeList(self.m_mask_node:getContentSize())
    self.m_mask_node:addChild(view)

    self.m_wread_node:removeAllChildrenWithCleanup(true)
    local view = self:createTableView(self.m_wread_node:getContentSize())
    self.m_wread_node:addChild(view)

    self.m_day_txt:setString("Tích điểm hiện tại:"..self.m_data.score)
    self.m_day_txt:setPositionX(15)
end

function game_carnival_dailrecharge.init(self,t_params)
    self.m_data = json.decode(t_params.gameData:getFormatBuffer()).data
    local cb_task_reward = getConfig(game_config_field.cb_task_reward)

    self.cb_task_reward = json.decode(cb_task_reward:getFormatBuffer())
    local cb_task = getConfig(game_config_field.cb_task)
    self.cb_task = json.decode(cb_task:getFormatBuffer())


    -- cclog2(self.m_data,"m_data")
    -- cclog2(self.m_showScore,"m_showScore")
    -- cclog2(self.m_showData,"m_showData")
end

--[[--
    创建ui入口并初始化数据
]]--
function game_carnival_dailrecharge.create(self,t_params)
   cclog("----- game_carnival_dailrecharge create --------")
    self:init(t_params);
    local popui = self:createUi();
    self:refreshUi()
  
    return popui
end

return game_carnival_dailrecharge