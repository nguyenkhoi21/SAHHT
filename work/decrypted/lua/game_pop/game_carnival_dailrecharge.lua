--狂欢盛典  每日充值
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
    cclog("game_carnival_dailrecharge.destroy")
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_quad_txt = nil;
    self.m_data = nil;
    -- if self.m_shared then
    --     CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
    --     self.m_shared = nil
    -- end
end

--[[--
    返回
]]
function game_carnival_dailrecharge.back(self,type)
    --回到activity
   
end


function game_carnival_dailrecharge.createUi(self)
    local layer = CCLayerColor:create(ccc4(255, 255, 255, 0), 330, 200)
    layer:setAnchorPoint(ccp(0.5,0.5));
    layer:setPosition(ccp(5,5));
    self.m_layer = layer

    local label = CCLabelTTF:create("",TYPE_FACE_TABLE.Arial_BoldMT,10)
    label:setColor(ccc3(255,255,0))
    label:setPosition(ccp(250,210))
    layer:addChild(label,999)
    
    -- if self.m_shared == nil then
    --     function tick()
    --         if self.m_time > 0 then
    --             hours = math.floor(self.m_time / 3600)
    --             minutes = math.floor((self.m_time - hours * 3600)/ 60)
    --             seconds = math.floor(self.m_time - 3600 * hours - 60 * minutes)
    --             hours = hours<10 and "0"..hours or ""..hours
    --             minutes = minutes<10 and "0"..minutes or ""..minutes
    --             seconds = seconds<10 and "0"..seconds or ""..seconds
    --             label:setString("本页活动倒计时: "..hours..":"..minutes..":"..seconds)
    --             self.m_time = self.m_time - 1
    --         else
    --             -- self:back()
    --             label:setString("本页活动倒计时: 活动已结束")
    --             CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
    --             self.m_shared = nil
    --         end
            
    --     end
    --     self.m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1 , false)
    -- end

    return layer
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
            --cclog2(data,"data")
            self.m_data = data.show

            self:refreshUi()

            game_util:rewardTipsByJsonData(reward);
        end
        local params = {}
        params.active_id = btnTag
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("celebration_recharge_receive"), http_request_method.GET,params,"celebration_recharge_receive")
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
            ccbNode:openCCBFile("ccb/ui_carnival_dayrecharge.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
            
        end
        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")   
            if ccbNode then 
                local showData = self.m_showData[index+1].data
                local id = self.m_showData[index+1].id

                local state = self.m_data[id]["content"].reward_flag

                local m_color_layer = ccbNode:layerColorForName("m_color_layer")
                local m_btn_reward = ccbNode:controlButtonForName("m_btn_reward")
                local m_wread_node = ccbNode:nodeForName("m_wread_node")
                local m_religq = ccbNode:spriteForName("m_religq")
                local m_des = ccbNode:labelTTFForName("m_des")
                local m_time = ccbNode:labelTTFForName("m_time")
                
                m_btn_reward:setTag(tonumber(id))
                m_btn_reward:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
                m_des:setString(showData.des.."("..self.m_data[id]["content"]["now_value"].."/"..showData.num..")")
                m_time:setString(showData.show_time)

                self.m_tableView2 = nil
                m_wread_node:removeAllChildrenWithCleanup(true)
                self.m_tableView2 = self:createTableView(showData.reward,m_wread_node:getContentSize())
                m_wread_node:addChild(self.m_tableView2)

                if state == 2 then  --已领取
                    m_religq:setVisible(true)
                    m_btn_reward:setEnabled(false)
                    m_btn_reward:setVisible(false)
                elseif state == 1 then
                    --todo
                    m_btn_reward:setColor(ccc3(88, 88, 88))
                    m_religq:setVisible(false)
                    m_btn_reward:setEnabled(false)
                    m_btn_reward:setVisible(true)
                elseif state == 0 then  --可以领取
                    m_religq:setVisible(false)
                    m_btn_reward:setEnabled(true)
                    m_btn_reward:setVisible(true)
                    m_btn_reward:setColor(ccc3(255, 255, 255))
                end

            end

        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" then
          
        end
    end
    return TableViewHelper:create(params)
end

function game_carnival_dailrecharge.createTableView(self, data, viewSize)
    
    local cardsCount = #data
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
            local icon,name,count = game_util:getRewardByItemTable(data[index+1])
            icon:setScale(0.8)
            local label = CCLabelTTF:create(tostring(count),TYPE_FACE_TABLE.Arial_BoldMT,12)
            label:setPosition(ccp(45,5))
            icon:addChild(label,999)
            icon:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            cell:addChild(icon,10,10)
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local icon,name,count = game_util:getRewardByItemTable(data[index+1])
            icon:setScale(0.8)
            local label = CCLabelTTF:create(tostring(count),TYPE_FACE_TABLE.Arial_BoldMT,12)
            label:setPosition(ccp(45,5))
            icon:addChild(label,999)
            icon:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            cell:addChild(icon,10,10)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" then
           
           local info1 = data[index+1]
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
    params.pageChangedCallFunc = function(totalPage,curPage)
       -- self.m_curPage = curPage;
    end
    local tableView = TableViewHelper:create(params);
    return tableView
end

function game_carnival_dailrecharge.refreshUi(self)
    self.m_showData = {}

   for k,v in pairs(self.m_data) do
       if v.show_flag == 1 then
           table.insert(self.m_showData,{data = self.cb_recharge[k] ,id = k})
       end
   end

   table.sort( self.m_showData, function ( a,b )
       return a.data.show_id<b.data.show_id
   end )
   
    self.m_layer:removeChildByTag(11, true)
  --  self.m_layer:removeAllChildrenWithCleanup(true)
    local view = self:createChallangeList(self.m_layer:getContentSize())
    self.m_layer:addChild(view,1,11)
end

function game_carnival_dailrecharge.init(self,t_params)
    self.m_data = json.decode(t_params.gameData:getFormatBuffer()).data
    self.m_time = t_params.time
    local cb_recharge = getConfig(game_config_field.cb_recharge)
    self.cb_recharge = json.decode(cb_recharge:getFormatBuffer())

     -- cclog2(self.m_data,"m_data")
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