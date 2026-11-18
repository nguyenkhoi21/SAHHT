--狂欢盛典
-- Author: fan.xia
-- Date: 2019-05-15 11:41:15
--

--
-- Author: fan.xia
-- Date: 2019-03-27 10:16:50
--
local game_carnival_lxrecharge = {
	m_root_layer = nil,
    m_ccbNode = nil,
    m_quad_txt = nil,
    m_data = nil,
    m_version = nil,
}

--[[--
    销毁
]]
function game_carnival_lxrecharge.destroy(self)
    -- body
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_quad_txt = nil;
    self.m_data = nil;
    self.m_version = nil;
end

--[[--
    返回
]]
function game_carnival_lxrecharge.back(self,type)
    --回到activity
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = nil},{endCallFunc = function (  )
                self:destroy();
            end});
end


function game_carnival_lxrecharge.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--
            local function responseMethod(tag,gameData)
                local reward = gameData:getNodeWithKey("data"):getNodeWithKey("reward")
                local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {}
                self.m_data = data
                
                self:refreshUi()
                game_util:rewardTipsByJsonData(reward)
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("celebration_daily_recharge_receive"), http_request_method.GET, nil,"celebration_daily_recharge_receive")
        elseif btnTag == 2 then
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                --game_scene:addPop("ui_vip_show_pop")
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag == 3 then 
            game_scene:addPop("game_carnival_rule_pop",{version = self.m_version}) 
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_carnival_lxrecharge.ccbi");

    self.m_ccbNode = ccbNode

    self.m_touch_layer = ccbNode:layerForName("m_touch_layer")
    self.m_wread_node = ccbNode:nodeForName("m_wread_node")
    self.m_large_reward = ccbNode:nodeForName("m_large_reward")
    self.m_des = ccbNode:labelTTFForName("m_des")
    self.m_day_txt = ccbNode:labelTTFForName("m_day_txt")
    self.m_religq = ccbNode:spriteForName("m_religq")
    self.m_btn_lingqu = ccbNode:controlButtonForName("m_btn_lingqu")
    self.m_btn_lingqu:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    self.m_btn_pay = ccbNode:controlButtonForName("m_btn_pay")
    self.m_btn_pay:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    local m_btn_reward = ccbNode:controlButtonForName("m_btn_reward")
    m_btn_reward:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            local realPos = self.m_touch_layer:convertToNodeSpace(ccp(x,y))
            --print(realPos.x.."  "..realPos.y)
            if self.m_large_reward:boundingBox():containsPoint(realPos) then
                
                local info1 = self.m_data["show"]["large_reward"][1]
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
            return true;
        end
    end

    self.m_touch_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    self.m_touch_layer:setTouchEnabled(true);

    return ccbNode
end

--[[--
    创建列表
]]
function game_carnival_lxrecharge.createChallangeList( self, viewSize )
    local function onclick( target,event )
       
    end

    local icon,name,count = game_util:getRewardByItemTable(self.m_data["show"]["large_reward"][1])
    local label = CCLabelTTF:create(tostring(count),TYPE_FACE_TABLE.Arial_BoldMT,12)
    label:setPosition(ccp(45,5))
    icon:addChild(label,999)
    icon:setPosition(ccp(icon:getContentSize().width*0.5,icon:getContentSize().height*0.5))
    self.m_large_reward:addChild(icon)
   
    local itemCount = #self.m_showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 4;
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 2;
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height/params.row);
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell();
        if cell == nil then 
            cell = CCTableViewCell:new()
            cell:autorelease();
            local icon,name,count = game_util:getRewardByItemTable(self.m_showData[index+1])
            icon:setScale(0.8)
            local label = CCLabelTTF:create(tostring(count),TYPE_FACE_TABLE.Arial_BoldMT,12)
            label:setPosition(ccp(45,5))
            icon:addChild(label,999)
            icon:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            cell:addChild(icon,10,10)
        end
        if cell then  
            cell:removeAllChildrenWithCleanup(true)
            local icon,name,count = game_util:getRewardByItemTable(self.m_showData[index+1])
            icon:setScale(0.8)
            local label = CCLabelTTF:create(tostring(count),TYPE_FACE_TABLE.Arial_BoldMT,12)
            label:setPosition(ccp(45,5))
            icon:addChild(label,999)
            icon:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            cell:addChild(icon,10,10)

        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" then
            local info1 = self.m_showData[index+1]
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

function game_carnival_lxrecharge.refreshUi(self)
    self.m_wread_node:removeAllChildrenWithCleanup(true)
    local view = self:createChallangeList(self.m_wread_node:getContentSize())
    self.m_wread_node:addChild(view)

    self.m_day_txt:setString("Thiên số đã nạp kỳ này："..self.m_data.show.has_recharge_days)

    if self.m_data["show"].receive_flag == 2 then  --已领取
        local node_size = self.m_wread_node:getContentSize()
        local recesp =  CCSprite:createWithSpriteFrameName("received.png")
        recesp:setPosition(ccp(node_size.width*0.5,node_size.height*0.5))
        self.m_wread_node:addChild(recesp, 10)
        self.m_btn_pay:setVisible(false)
        self.m_btn_lingqu:setVisible(false)
        self.m_religq:setVisible(true)
    elseif self.m_data["show"].receive_flag == 0 then
        self.m_btn_pay:setVisible(true)
        self.m_btn_lingqu:setVisible(false)
        self.m_religq:setVisible(false)
    elseif self.m_data["show"].receive_flag == 1 then --可领取
        self.m_btn_pay:setVisible(false)
        self.m_btn_lingqu:setVisible(true)
        self.m_religq:setVisible(false)
    end

    local str = nil
    if self.m_data["show"]["num_type"] == 1 then
        str = "元"
    else
        str = "xu "
    end

    self.m_des:setString("Tích nạp"..self.m_data["show"]["need_num"]..str.."sẽ nhận được quà dưới đây（"..self.m_data["show"]["recharge_num"].."/"..self.m_data["show"]["need_num"].."）")
end

function game_carnival_lxrecharge.init(self,t_params)
    self.m_data = json.decode(t_params.gameData:getFormatBuffer()).data
    self.m_version = self.m_data.show.version
    self.m_showData = {}

    self.m_showData = self.m_data["show"]["cur_day_reward"]

    --cclog2(self.m_data,"m_data")
  
end

--[[--
    创建ui入口并初始化数据
]]--
function game_carnival_lxrecharge.create(self,t_params)
   cclog("----- game_carnival_lxrecharge create --------")
    self:init(t_params);
    local popui = self:createUi();
    self:refreshUi()
  
    return popui
end

return game_carnival_lxrecharge