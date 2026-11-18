--狂欢盛典
-- Author: fan.xia
-- Date: 2019-05-15 11:41:15
--

--
-- Author: fan.xia
-- Date: 2019-03-27 10:16:50
--
local game_carnival_pop = {
	m_root_layer = nil,
    m_ccbNode = nil,
    m_quad_txt = nil,
    m_data = nil,
    m_tongyo_bg = nil,
}

--[[--
    销毁
]]
function game_carnival_pop.destroy(self)
    -- body
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_quad_txt = nil;
    self.m_data = nil;
    self.m_tongyo_bg = nil;
    if self.m_shared then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
        self.m_shared = nil
    end
    
end

--[[--
    返回
]]
function game_carnival_pop.back(self,type)
    --回到activity
    for k,v in pairs(self.m_showContentViewUI) do
        if v.ui then
            v.ui:removeFromParentAndCleanup(true)
            v.ui_table:destroy()
            self.m_showContentViewUI[k] = nil
        end
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = nil},{endCallFunc = function (  )
                self:destroy();
            end});
end

--每日登陆  每日充值  连续充值  累计消费  每日任务

local testData = {} 
testData["1"] = {sort = 1, name = "login", img = "btn_login1.png", img2 = "btn_login2.png", createfunName = "createAnnouncementUI"}
testData["2"] = {sort = 2, name = "dayrecharge", img = "btn_dailrecharge1.png", img2 = "btn_dailrecharge2.png" , createfunName = "createVIPRewardUI"}
testData["3"] = {sort = 3, name = "lxrecharge", img = "btn_lxRecharge1.png", img2 = "btn_lxRecharge2.png" , createfunName = "createDailySignUI"}
testData["4"] = {sort = 4, name = "consumpt", img = "btn_consumption1.png", img2 = "btn_consumption2.png" , createfunName = "createQuartervipUI"}
testData["5"] = {sort = 5, name = "daytask", img = "btn_dailyTask1.png", img2 = "btn_dailyTask2.png" , createfunName = "createMonthvipUI"}


function game_carnival_pop.createUi(self)
   local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 2 then
            
        elseif btnTag == 3 then
            function shopOpenResponseMethod(tag,gameData)
            	game_scene:enterGameUi("game_shooting",{gameData = gameData}) 
        	end
            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("god_shot_index"), http_request_method.GET, {},"channel_active_recharge_index")
        elseif btnTag == 4 then
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
               -- game_scene:addPop("ui_vip_show_pop")
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_carnival_pop.ccbi");

    self.m_ccbNode = ccbNode

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_node_titlelist_board = ccbNode:nodeForName("m_node_titlelist_board")
    self.m_list_node = ccbNode:nodeForName("m_list_node")
    self.m_tongyo_bg = ccbNode:scale9SpriteForName("m_tongyo_bg")
    self.m_hero_sp = ccbNode:spriteForName("m_hero_sp")
    self.m_pay_btn = ccbNode:controlButtonForName("m_pay_btn")
    self.m_hdtime_lab = ccbNode:labelTTFForName("m_hdtime_lab")
    --self.m_yubi_txt = ccbNode:labelTTFForName("m_yubi_txt")
    local m_back_btn = ccbNode:controlButtonForName("m_close_btn")
    m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    self.m_pay_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
   
    local function onTouch(eventType, x, y)
        if eventType == "began" then

            return true;--intercept event
        end
    end

    self:createAnimian()

    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);

    return ccbNode
end

--[[
    选中福利的状态
]]
function game_carnival_pop.respondCellSelect( self, uiInfo )
     --cclog2(uiInfo, " uiInfo  ===  ")
    for k,v in pairs(self.m_showContentViewUI) do
        if v.ui and uiInfo.name ~= k  then
            v.ui:removeFromParentAndCleanup(true)
            v.ui_table:destroy()
            self.m_showContentViewUI[k] = nil
        elseif v.ui then
            local pY = v.ui:getPositionY()
            pY = math.ceil( pY % 1000 ) + 1000
            v.ui:setPositionY( pY )
            v.ui:setVisible(false)
        end
        if v.ui_table and  type(v.ui_table.setViewVisible) == "function" then
            v.ui_table:setViewVisible(false)
        end
    end
    if self.m_showContentViewUI[ uiInfo.name ] then
        local uiData = self.m_showContentViewUI[ uiInfo.name ]
        uiData.ui:setVisible(true)
        local pY = uiData.ui:getPositionY()
        pY = math.ceil( pY % 1000 )
        uiData.ui:setPositionY( pY )
        if uiData.ui_table and type(uiData.ui_table.setViewVisible) == "function" then
            uiData.ui_table:setViewVisible(true)
        end
    else
        local createfunName = uiInfo.createfunName
        
        if type(game_carnival_pop[createfunName]) == "function" then
            game_carnival_pop[uiInfo.createfunName](self, uiInfo.name, uiInfo.name )
        else
            -- assert(false)
        end
    end
end

--[[
    创建一个UI
]]
function game_carnival_pop:createContentUI( name, params)
    local ui_content = require("game_pop." .. name)
    ui = ui_content:create( params )
    return ui, ui_content
end

--[[
    每日登陆页面
]]
function game_carnival_pop.createAnnouncementUI( self, key )
    local function responseMethod(tag,gameData)
        self.m_tongyo_bg:setVisible(true)
        self.m_pay_btn:setVisible(false)
        self.m_hero_sp:setPositionX(-200)
        self.m_hero_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("people2.png"))
       local ui, ui_table  = self:createContentUI( "game_carnival_login",{gameData = gameData, version = self.m_data["1"]["content"]["version"]} )
        self.m_showContentViewUI[key] = {ui = ui, ui_table = ui_table}
        self.m_list_node:addChild(ui)
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("celebration_red_packet_index"), http_request_method.GET,nil,"celebration_red_packet_index")
end

--[[
    每日充值
]]
function game_carnival_pop.createVIPRewardUI( self, key )
    local function responseMethod(tag,gameData)
        self.m_hero_sp:setPositionX(-175)
        self.m_hero_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("people3.png"))
        self.m_tongyo_bg:setVisible(true)
        self.m_pay_btn:setVisible(true)
        local ui, ui_table = self:createContentUI( "game_carnival_dailrecharge", {gameData = gameData,time = self.m_data["2"]["remain_time"]} )
        self.m_showContentViewUI[key] = {ui = ui, ui_table = ui_table}
        self.m_list_node:addChild(ui)
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("celebration_recharge_index"), http_request_method.GET,nil,"celebration_recharge_index")
end

--[[
    连续充值
]]
function game_carnival_pop.createDailySignUI( self, key )
    local function responseMethod(tag,gameData)
        self.m_tongyo_bg:setVisible(false)
        self.m_pay_btn:setVisible(false)
        self.m_hero_sp:setPositionX(-175)
        self.m_hero_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("people5.png"))
        local ui, ui_table = self:createContentUI( "game_carnival_lxrecharge", {gameData = gameData} )
        self.m_showContentViewUI[key] = {ui = ui, ui_table = ui_table}
        self.m_list_node:addChild(ui)
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("celebration_daily_recharge_index"), http_request_method.GET,nil,"celebration_daily_recharge_index")
end

--[[
    累计充值
]]
function game_carnival_pop.createQuartervipUI( self, key )
    local function responseMethod(tag,gameData)
        self.m_tongyo_bg:setVisible(true)
        self.m_pay_btn:setVisible(false)
        self.m_hero_sp:setPositionX(-175)
        self.m_hero_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("people4.png"))
        local ui, ui_table = self:createContentUI( "game_carnival_consumpt", {gameData = gameData,time = self.m_data["4"]["remain_time"]} )
        self.m_showContentViewUI[key] = {ui = ui, ui_table = ui_table}
        self.m_list_node:addChild(ui)
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("celebration_consume_index"), http_request_method.GET,nil,"celebration_consume_index")
end

--[[
    每日任务
]]
function game_carnival_pop.createMonthvipUI( self, key )
    local function responseMethod(tag,gameData)
        self.m_tongyo_bg:setVisible(false)
        self.m_pay_btn:setVisible(false)
        self.m_hero_sp:setPositionX(-175)
        self.m_hero_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("people1.png"))
        local ui, ui_table = self:createContentUI( "game_carnival_daytask", {gameData = gameData} )
        self.m_showContentViewUI[key] = {ui = ui, ui_table = ui_table}
        self.m_list_node:addChild(ui)
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("celebration_task_index"), http_request_method.GET,nil,"celebration_task_index")
end

--[[--
    创建列表
]]
function game_carnival_pop.createChallangeList( self, viewSize )
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag")
    end
    
    self.m_itemTab = {}
    local itemCount = #self.m_showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 3;
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
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_carnival_title_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then  
            self.m_itemTab[index+1] = cell
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")   
            if ccbNode then 
                local m_thgon = ccbNode:spriteForName("m_thgon")
                local m_sprite_title = ccbNode:spriteForName("m_sprite_title")
                local m_anim_node = ccbNode:nodeForName("m_anim_node")
                if self.m_cur_selectitem_index == index then
                    self.m_cur_selectcell = cell
                end

                local animFile = "kuanghuanshengdian"
                local m_iAnim = zcAnimNode:create(animFile .. ".swf.sam",0,animFile .. ".plist");
                local function animEnd(animNode,theId,lableName)
                   m_iAnim:playSection("impact1");
                end
                m_iAnim:registerScriptTapHandler(animEnd);
                m_iAnim:playSection("impact1");
                m_iAnim:setScale(1);
                m_iAnim:setPosition(ccp(0, 0))
                m_anim_node:addChild(m_iAnim,100)

                local titleSpriteName = self.m_showData[index + 1].img or ""
                local titleSpriteName2 = self.m_showData[index + 1].img2 or ""
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( titleSpriteName )
                local frame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( titleSpriteName2 )
                if m_sprite_title and frame and frame2 then
                    m_sprite_title:setDisplayFrame( frame )
                    m_thgon:setDisplayFrame(frame2)
                end

            end

        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" then
            self:selectCellState(index)
        end
    end
    return TableViewHelper:create(params)
end

function game_carnival_pop.selectCellState(self, index)
    for k,v in pairs(self.m_itemTab) do
        local ccbNode = tolua.cast(v:getChildByTag(10),"luaCCBNode")
        local m_thgon = ccbNode:spriteForName("m_thgon")
        local m_sprite_title = ccbNode:spriteForName("m_sprite_title")
        local m_anim_node = ccbNode:nodeForName("m_anim_node")
        if k == index+1 then
            m_thgon:setVisible(true)
            m_anim_node:setVisible(true)
            m_sprite_title:setVisible(false)
        else
            m_thgon:setVisible(false)
            m_anim_node:setVisible(false)
            m_sprite_title:setVisible(true)
        end
    end

    self:respondCellSelect(self.m_showData[index + 1])
end


function game_carnival_pop.createAnimian(self)
   
    
end


function game_carnival_pop.refreshUi(self)
   -- self.m_node_titlelist_board:removeAllChildrenWithCleanup(true)
    local view = self:createChallangeList(self.m_node_titlelist_board:getContentSize())
    self.m_node_titlelist_board:addChild(view)
    self:selectCellState(0)

    local hours,minutes,seconds = nil
    if self.m_shared == nil then
        function tick()
            if self.m_data["1"].remain_time > 0 then
                hours = math.floor(self.m_data["1"].remain_time / 3600)
                minutes = math.floor((self.m_data["1"].remain_time - hours * 3600)/ 60)
                seconds = math.floor(self.m_data["1"].remain_time - 3600 * hours - 60 * minutes)
                hours = hours<10 and "0"..hours or ""..hours
                minutes = minutes<10 and "0"..minutes or ""..minutes
                seconds = seconds<10 and "0"..seconds or ""..seconds
                self.m_hdtime_lab:setString("CD: "..hours..":"..minutes..":"..seconds)
                self.m_data["1"].remain_time = self.m_data["1"].remain_time - 1
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

function game_carnival_pop.init(self,t_params)
   self.m_data = json.decode(t_params.gameData:getFormatBuffer()).data.show
   self.m_showData = {}
   self.m_showContentViewUI = {}

   for k,v in pairs(self.m_data) do
       if v.can_show == 1 then
        cclog2(k)
           table.insert(self.m_showData,testData[k] )
       end
   end

   table.sort( self.m_showData, function ( a,b )
       return a.sort<b.sort
   end )

   -- cclog2(self.m_showData,"m_showData")
   -- cclog2(self.m_data,"m_data")
end

--[[--
    创建ui入口并初始化数据
]]--
function game_carnival_pop.create(self,t_params)
   cclog("----- game_carnival_pop create --------")
    self:init(t_params);
    local popui = self:createUi();
    self:refreshUi()
  
    return popui
end

return game_carnival_pop