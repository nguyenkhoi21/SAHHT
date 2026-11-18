--狂欢盛典 每日登陆
-- Author: fan.xia
-- Date: 2019-05-15 11:41:15
--

--
-- Author: fan.xia
-- Date: 2019-03-27 10:16:50
--
local game_carnival_login = {
	m_root_layer = nil,
    m_ccbNode = nil,
    m_quad_txt = nil,
    m_data = nil,
}

--[[--
    销毁
]]
function game_carnival_login.destroy(self)
    -- body
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_quad_txt = nil;
    self.m_data = nil;
end

--[[--
    返回
]]
function game_carnival_login.back(self,type)
    --回到activity
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = nil},{endCallFunc = function (  )
                self:destroy();
            end});
end


function game_carnival_login.createUi(self)
    local layer = CCLayerColor:create(ccc4(255, 255, 255, 0), 330, 210)
    layer:setAnchorPoint(ccp(0.5,0.5));
    layer:setPosition(ccp(5,0))
    self.m_layer = layer

    return layer
end


--[[--
    创建列表
]]
function game_carnival_login.createChallangeList( self, viewSize )
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
        params.which_day = btnTag
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("celebration_red_packet_receive"), http_request_method.GET,params,"celebration_red_packet_receive")
    end
    
    self.m_itemTab = {}
    local itemCount = #self.m_redpacket
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 4;
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 2;
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height/params.row);
    self.m_cellSize = itemSize
    self.m_cellCount = itemCount
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell();
        if cell == nil then 
            cell = CCTableViewCell:new()
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onclick",onclick);
            ccbNode:openCCBFile("ccb/ui_carnival_daylogin.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
            
        end
        if cell and index < itemCount then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")   
            if ccbNode then 
                local showData = self.m_redpacket[index+1]
                local state = self.m_data["show"][tostring(showData.day)].flag
                local m_color_layer = ccbNode:layerColorForName("m_color_layer")
                local m_btn_reward = ccbNode:controlButtonForName("m_btn_reward")
                local m_wread_node = ccbNode:nodeForName("m_wread_node")
                local m_received = ccbNode:spriteForName("m_received")
                local m_religq = ccbNode:spriteForName("m_religq")
                local m_des = ccbNode:labelTTFForName("m_des")
                
                m_btn_reward:setTag(index+1)
                m_btn_reward:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
                m_des:setString(tostring("Ngày thứ "..showData.day))

                self.m_tableView2 = nil
                m_wread_node:removeAllChildrenWithCleanup(true)
                self.m_tableView2 = self:createTableView(showData.reward,m_wread_node:getContentSize())
                m_wread_node:addChild(self.m_tableView2)

                if state == -1 then  --不可领取
                    m_religq:setVisible(false)
                    m_received:setVisible(false)
                    m_color_layer:setVisible(true)
                    m_btn_reward:setEnabled(false)
                elseif state == 1 then --可领取
                    m_color_layer:setVisible(false)
                    m_received:setVisible(false)
                    m_btn_reward:setEnabled(true)
                    m_religq:setVisible(false)
                elseif state == 2 then  --已领取
                    m_religq:setVisible(true)
                    local titleSpriteName = "received.png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( titleSpriteName )
                    if frame then
                        m_received:setDisplayFrame(frame)
                    end
                   m_received:setVisible(true)
                   m_color_layer:setVisible(true)
                   m_btn_reward:setEnabled(false)
                elseif state == 3 then  --已过期
                    m_religq:setVisible(false)
                    local titleSpriteName = "expired.png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( titleSpriteName )
                    if frame then
                        m_received:setDisplayFrame(frame)
                    end
                    m_received:setVisible(true)
                    m_color_layer:setVisible(true)
                    m_btn_reward:setEnabled(false)
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

function game_carnival_login.createTableView(self, data, viewSize)
    
    local cardsCount = #data
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = cardsCount -- totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
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
            cell:addChild(label,999)
            icon:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            cell:addChild(icon,10,10)
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true) 
            local icon,name,count = game_util:getRewardByItemTable(data[index+1])
            icon:setScale(0.8)
            local label = CCLabelTTF:create(tostring(count),TYPE_FACE_TABLE.Arial_BoldMT,12)
            label:setPosition(ccp(45,5))
            cell:addChild(label,999)
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
        self.m_curPage = curPage;
    end
    local tableView = TableViewHelper:create(params);
    return tableView
end

function game_carnival_login.refreshUi(self)
    self.m_layer:removeAllChildrenWithCleanup(true)
    local view = self:createChallangeList(self.m_layer:getContentSize())
    self.m_layer:addChild(view)
end

function game_carnival_login.init(self,t_params)
    self.m_data = json.decode(t_params.gameData:getFormatBuffer()).data
    local cb_redpacket = getConfig(game_config_field.cb_redpacket)
    local cfg = json.decode(cb_redpacket:getFormatBuffer())
    self.m_redpacket = {}

   for k,v in pairs(cfg) do
       if v.version == t_params.version then
           table.insert(self.m_redpacket,v )
       end
   end

   table.sort( self.m_redpacket, function ( a,b )
       return a.day<b.day
   end )

   -- cclog2(self.m_data,"m_data")
   -- cclog2(self.m_redpacket,"cb_redpacket")
end

--[[--
    创建ui入口并初始化数据
]]--
function game_carnival_login.create(self,t_params)
   cclog("----- game_carnival_login create --------")
    self:init(t_params);
    local popui = self:createUi();
    self:refreshUi()
  
    return popui
end

return game_carnival_login