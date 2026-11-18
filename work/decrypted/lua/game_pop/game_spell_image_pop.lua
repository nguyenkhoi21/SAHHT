--拼图大作战
-- Author: fan.xia
-- Date: 2019-05-15 11:41:15
--

--
-- Author: fan.xia
-- Date: 2019-03-27 10:16:50
--
local game_spell_image_pop = {
	m_root_layer = nil,
    m_ccbNode = nil,
    m_quad_txt = nil,
    m_data = nil,
    m_tongyo_bg = nil,
    m_version = nil,
    m_jigsaw = nil,
}

--[[--
    销毁
]]
function game_spell_image_pop.destroy(self)
    -- body
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_quad_txt = nil;
    self.m_data = nil;
    self.m_version = nil;
    self.m_tongyo_bg = nil;
    self.m_jigsaw = nil;
    if self.m_shared then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
        self.m_shared = nil
    end
end

--[[--
    返回
]]
function game_spell_image_pop.back(self,type)
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = nil},{endCallFunc = function (  )
                self:destroy();
            end});
end

function game_spell_image_pop.createUi(self)
   local ccbNode = luaCCBNode:create();
   CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_daily_task_res.plist")
   CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_spell_image.plist")
   CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_carnival.plist")
    local getplzz = true
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 2 then
            function callBack(gameData)
                --cclog2(gameData,"gameData")
                self.m_data = gameData
                self:refreshUi()
            end
            function shopOpenResponseMethod(tag,gameData)
                game_scene:addPop("game_spell_wod",{gameData = gameData,callBack = callBack,version = self.m_version}) 
            end
            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("jigsaw_my_jigsaw_index"), http_request_method.GET, {},"jigsaw_my_jigsaw_index")
        elseif btnTag == 3 then  --合成拼图
            function shopOpenResponseMethod(tag,gameData)
            	self.m_data = json.decode(gameData:getFormatBuffer()).data
                self:refreshUi()
                game_util:addMoveTips({text = "Chúc mừng bạn đã ghép tranh xong, hãy nhận quà ở phía trái"})
        	end
            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("jigsaw_finish_jigsaw"), http_request_method.GET, {},"jigsaw_finish_jigsaw")
        elseif btnTag == 4 then  --获取拼图
            if getplzz then
                getplzz = false
                self.m_fb_btn:setVisible(true)
                self.m_rmhd_btn:setVisible(true)
            else
                getplzz = true
                self.m_fb_btn:setVisible(false)
                self.m_rmhd_btn:setVisible(false)
            end
        elseif btnTag == 5 then  --副本
            local function responseMethod(tag,gameData)       
                game_scene:addPop("game_activity_new_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
        elseif btnTag == 6 then --热门活动
            function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_charge_active",{gameData = gameData})
                self:destroy()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_active_show"), http_request_method.GET, {},"active_active_show")
        elseif btnTag == 7 then
            game_scene:addPop("game_spell_rule",{gameData = self.m_version})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_spell_pop.ccbi");

    self.m_ccbNode = ccbNode

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_list_node = ccbNode:nodeForName("m_list_node")
    self.m_pingtu_node = ccbNode:nodeForName("m_pingtu_node")
    -- self.m_tongyo_bg = ccbNode:scale9SpriteForName("m_tongyo_bg")
    -- self.m_hero_sp = ccbNode:spriteForName("m_hero_sp")
    
    self.m_hdtime_lab = ccbNode:labelTTFForName("m_hdtime_lab")
    -- --self.m_yubi_txt = ccbNode:labelTTFForName("m_yubi_txt")
    local m_back_btn = ccbNode:controlButtonForName("m_close_btn")
    local m_wen_btn = ccbNode:controlButtonForName("m_wen_btn")
    local m_wdpt_btn = ccbNode:controlButtonForName("m_wdpt_btn")  
    local m_djhc_btn = ccbNode:controlButtonForName("m_djhc_btn")
    local m_hqpt_btn = ccbNode:controlButtonForName("m_hqpt_btn")
    self.m_fb_btn = ccbNode:controlButtonForName("m_fb_btn")
    self.m_rmhd_btn = ccbNode:controlButtonForName("m_rmhd_btn")

    m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10)
    m_wen_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10)
    m_wdpt_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10)
    m_djhc_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10)
    m_hqpt_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10)
    self.m_fb_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10)
    self.m_rmhd_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10)

    local function onTouch(eventType, x, y)
        if eventType == "began" then

            return true;--intercept event
        end
    end

    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    self.m_root_layer:setTouchEnabled(true);

    return ccbNode
end

--[[--
    创建列表
]]
function game_spell_image_pop.createChallangeList( self, viewSize )
    local function onclick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        --cclog2(btnTag,"btnTag")

        local function responseMethod(tag,gameData)
            local reward = gameData:getNodeWithKey("data"):getNodeWithKey("reward")
            local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()).show or {};
            cclog2(data,"data")
            self.m_data = data

            self:refreshUi()

            game_util:rewardTipsByJsonData(reward)
        end
        local params = {}
        params.day = btnTag
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("jigsaw_get_jigsaw_reward"), http_request_method.GET, params,"jigsaw_get_jigsaw_reward")
    end

    local m_showData = {}
    for k,v in pairs(self.m_data.reward_info) do
       if type(v.reward)  == "table" then
           table.insert(m_showData,{data = v,day = k} )
       end
   end

   table.sort( m_showData, function ( a,b )
       return a.day<b.day
   end )
  
    local itemCount = #m_showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 1;
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 10;
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
            ccbNode:openCCBFile("ccb/ui_spell_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
   
        end
        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")   
            if ccbNode then 
                local showData = m_showData[index+1].data
                local flag = m_showData[index+1].data.flag
                local day = m_showData[index+1].day

                local m_btn_reward = ccbNode:controlButtonForName("m_btn_reward")
                m_btn_reward:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)
                local m_wread_node = ccbNode:nodeForName("m_wread_node")
                local m_religq = ccbNode:spriteForName("m_religq")
                local m_des = ccbNode:labelTTFForName("m_des")
                m_religq:setVisible(true)
                m_des:setString("Ngày thứ "..day)
                m_btn_reward:setTag(day)

                self.m_tableView2 = nil
                m_wread_node:removeAllChildrenWithCleanup(true)
                self.m_tableView2 = self:createTableView(showData.reward,m_wread_node:getContentSize())
                m_wread_node:addChild(self.m_tableView2)

                if flag == 0 then  --不可领取
                    m_religq:setVisible(false)
                    m_btn_reward:setEnabled(false)
                    m_btn_reward:setVisible(true)
                    m_btn_reward:setColor(ccc3(88,88,88))
                elseif flag == 1 then  --可领取
                    m_religq:setVisible(false)
                    m_btn_reward:setEnabled(true)
                    m_btn_reward:setVisible(true)
                    m_btn_reward:setColor(ccc3(255,255,255))
                elseif flag == 2 then  --已领取
                    m_religq:setVisible(true)
                    m_btn_reward:setEnabled(false)
                    m_btn_reward:setVisible(false)
                    m_btn_reward:setColor(ccc3(255,255,255))
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

function game_spell_image_pop.createTableView(self, data, viewSize)
    
    local cardsCount = #data
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 3; --列
    params.totalItem = cardsCount -- totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionHorizontal;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-10
    
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

function game_spell_image_pop.createPintu(self, viewSize)
    local index = 0
    local jigsaw_cig = getConfig( game_config_field.jigsaw )
    local jigsawTab = json.decode(jigsaw_cig:getFormatBuffer())
    local icon = jigsawTab[tostring(self.m_version)]["jigsaw_icon1"][1]
    for i=1,3 do
        for j=1,3 do

            index = index + 1
            local ccbNode = CCSprite:createWithSpriteFrameName(icon.."_js_1.png")  
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            local size = ccbNode:getContentSize()
            local y = size.height * i
            local x = size.height * j
            if i > 1 then
                y = y - 10
            end
            if j > 1 then
                x = x - 10
            end
            ccbNode:setPosition(ccp(x-35, -y+220))

            
            self.m_pingtu_node:addChild(ccbNode, 10, 10)
            local fileName = nil
            if self.m_data.jigsaw_log[index] == 0 then
                fileName = icon.."_js_"..index.."_"..index..".png"
            else
                fileName = icon.."_js_"..index..".png"
            end
            
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName))
            if tempSpriteFrame then
                ccbNode:setDisplayFrame(tempSpriteFrame)
            end
        end
    end
end


function game_spell_image_pop.refreshUi(self)
    self.m_list_node:removeAllChildrenWithCleanup(true)
    local view = self:createChallangeList(self.m_list_node:getContentSize())
    self.m_list_node:addChild(view)

    self.m_pingtu_node:removeAllChildrenWithCleanup(true)
    self:createPintu()
   
    local hours,minutes,seconds = nil
    if self.m_shared == nil then
        function tick()
            if self.m_data.remain_time > 0 then
                hours = math.floor(self.m_data.remain_time / 3600)
                minutes = math.floor((self.m_data.remain_time - hours * 3600)/ 60)
                seconds = math.floor(self.m_data.remain_time - 3600 * hours - 60 * minutes)
                hours = hours<10 and "0"..hours or ""..hours
                minutes = minutes<10 and "0"..minutes or ""..minutes
                seconds = seconds<10 and "0"..seconds or ""..seconds
                self.m_hdtime_lab:setString("CD: "..hours..":"..minutes..":"..seconds)
                self.m_data.remain_time = self.m_data.remain_time - 1
            else
                -- self:back()
                self.m_hdtime_lab:setString("CD: Event đã kết thúc")
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
                self.m_shared = nil
            end
            
        end
        self.m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1 , false)
    end
end

function game_spell_image_pop.init(self,t_params)
    self.m_data = json.decode(t_params.gameData:getFormatBuffer()).data
    self.m_showData = {}
    self.m_version = self.m_data.version

   -- cclog2(self.m_data,"m_data")
end

--[[--
    创建ui入口并初始化数据
]]--
function game_spell_image_pop.create(self,t_params)
   cclog("----- game_spell_image_pop create --------")
    self:init(t_params);
    local popui = self:createUi();
    self:refreshUi()
  
    return popui
end

return game_spell_image_pop