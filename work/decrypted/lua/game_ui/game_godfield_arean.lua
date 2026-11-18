---  城市地图

local game_godfield_arean = {
    m_tGameData = nil,
    root_map_node = nil,
    m_scroll_view = nil,
    m_back_btn = nil,
    m_btn_zhenxing = nil,
    m_btn_duihuan = nil,
    bg_layer = nil,
    maxOffsetX = nil,
    building_table = nil,
    select_building = nil,
    --building_tab = nil,
    m_label_timedown = nil,
    m_label_score = nil,
    conutdownTime = nil,
    buildingTag_tab = nil,
    touch_buildingTag = nil,
    m_playerAnimNode = nil,
    playerLayer = nil,
    win_sort = nil,
    is_enter = nil,
    random_num = nil,
    tobattle = nil,
    m_weekDay = nil,
    m_shuaxinshijian_lab = nil,
};

local building_offset = require("building_offset");

--[[--
    销毁
]]
function game_godfield_arean.destroy(self)
    cclog("-----------------game_godfield_arean destroy-----------------");
    self.root_map_node = nil;
    self.m_tGameData = nil;
    self.m_scroll_view = nil;
    self.m_back_btn = nil;
    self.m_btn_zhenxing = nil;
    self.m_btn_duihuan = nil;
    self.bg_layer = nil;
    self.maxOffsetX = nil;
    self.building_table = nil;
    self.select_building = nil;
    --self.building_tab = nil;
    self.m_label_timedown = nil;
    self.m_label_score = nil;
    self.conutdownTime = nil;
    self.buildingTag_tab = nil;
    self.touch_buildingTag = nil;
    self.m_playerAnimNode = nil;
    self.playerLayer = nil;
    self.win_sort = nil;
    self.is_enter = nil;
    self.random_num = nil;
    self.tobattle = nil;
    self.m_weekDay = nil;
    self.m_shuaxinshijian_lab = nil;

end
local building_tab = { 
    building_tab1 = {
    -- {title = "生产中心",img = "main_page_building1.png",offset = {841,532}}
        {buildingID = "0" , img = "ccbResources/godfield_build/godfield_build_1.png",colorFlag = -1 ,offset = {285,72.5},offset2 = {281.3,49.5},tag = "1000"},

        {buildingID = "1" ,img = "ccbResources/godfield_build/godfield_build_2.png",colorFlag = -1,offset = {120.5,151},offset2 = {115.3,131},tag = "1001"},

        {buildingID = "2" ,img = "ccbResources/godfield_build/godfield_build_3.png",colorFlag = -1,offset = {281.5,191},offset2 = {258.3,191},tag = "1002"},

        {buildingID = "3" ,img = "ccbResources/godfield_build/godfield_build_4.png",colorFlag = -1,offset = {327.5,144},offset2 = {326.3,124.5},tag = "1003"},

        {buildingID = "4" ,img = "ccbResources/godfield_build/godfield_build_5.png",colorFlag =-1,offset = {400,222.5},offset2 = {408.3,190},tag = "1004"},

        {buildingID = "5" ,img = "ccbResources/godfield_build/godfield_build_6.png",colorFlag = -1,offset = {427.5,53.5},offset2 = {431.3,43.5},tag = "1005"},

        {buildingID = "6" ,img = "ccbResources/godfield_build/godfield_build_7.png",colorFlag = -1,offset = {470,141.5},offset2 = {467.3,115.5},tag = "1006"},

        {buildingID = "7" ,img = "ccbResources/godfield_build/godfield_build_8.png",colorFlag = -1,offset = {627.5,210},offset2 = {624.8,170},tag = "1007"},

        {buildingID = "8" ,img = "ccbResources/godfield_build/godfield_build_9.png",colorFlag = -1,offset = {744.5,104},offset2 = {744.3,75.5},tag = "1008"},

        {buildingID = "9" ,img = "ccbResources/godfield_build/godfield_build_10.png",colorFlag = -1,offset = {618.5,83},offset2 = {621.7,47.5},tag = "1009"},
    },
     building_tab2 = {
    -- {title = "生产中心",img = "main_page_building1.png",offset = {841,532}}
        {buildingID = "0" , img = "ccbResources/godfield_build/godfield_build_2_10.png",colorFlag = -1 ,offset = {95.5,191},offset2 = {115.3,151},tag = "1000"},

        {buildingID = "1" ,img = "ccbResources/godfield_build/godfield_build_2_9.png",colorFlag = -1,offset = {260.3,57.3},offset2 = {281.3,49.5},tag = "1001"},

        {buildingID = "2" ,img = "ccbResources/godfield_build/godfield_build_2_8.png",colorFlag = -1,offset = {304,139.7},offset2 = {326.3,124.5},tag = "1002"},

        {buildingID = "3" ,img = "ccbResources/godfield_build/godfield_build_2_7.png",colorFlag = -1,offset = {260,208},offset2 = {258.3,191},tag = "1003"},

        {buildingID = "4" ,img = "ccbResources/godfield_build/godfield_build_2_2.png",colorFlag =-1,offset = {427,39},offset2 = {431.3,43.5},tag = "1004"},

        {buildingID = "5" ,img = "ccbResources/godfield_build/godfield_build_2_1.png",colorFlag = -1,offset = {459.7,133},offset2 = {467.3,115.5},tag = "1005"},

        {buildingID = "6" ,img = "ccbResources/godfield_build/godfield_build_2_6.png",colorFlag = -1,offset = {446.3,226},offset2 = {439.3,190},tag = "1006"},

        {buildingID = "7" ,img = "ccbResources/godfield_build/godfield_build_2_3.png",colorFlag = -1,offset = {608.5,58},offset2 = {621.7,47.5},tag = "1007"},

        {buildingID = "8" ,img = "ccbResources/godfield_build/godfield_build_2_4.png",colorFlag = -1,offset = {733,114},offset2 = {744.3,75.5},tag = "1008"},

        {buildingID = "9" ,img = "ccbResources/godfield_build/godfield_build_2_5.png",colorFlag = -1,offset = {640,209.7},offset2 = {624.8,170},tag = "1009"},
    },
 }
--[[--
    返回
]]
function game_godfield_arean.back(self,type)
   local function responseMethod( tag,gameData )
        local data = gameData:getNodeWithKey("data");
            data = json.decode(data:getFormatBuffer()) or {};
            game_scene:enterGameUi("game_godfield_main",{gameData = gameData})
        end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_arean.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then --返回
            self:back();
        elseif btnTag == 101 then--阵型
           local function responseMethod(tag,gameData)
                if gameData then
                    game_scene:enterGameUi("game_god_adjustment",{gameData = gameData,openType="game_godfield_arean",});
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_upload_god_formation"), http_request_method.GET, nil,"god_field_upload_god_formation",true,true)
        
           
        elseif btnTag == 102 then--兑换
            local function responseMethod( tag,gameData )
                game_scene:enterGameUi("game_godfield_shop",{gameData = gameData,openType = "godfield_arean"});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_exchange_index"), http_request_method.GET, params,"god_field_exchange_index")
        elseif btnTag == 103 then--战报
            local function responseMethod( tag,gameData )
                game_scene:addPop("game_godfield_battleNews",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_get_own_logs"), http_request_method.GET, params,"god_field_get_own_logs")
            
        elseif btnTag == 104 then --排行榜

            local function responseMethod( tag,gameData )
                local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                game_scene:enterGameUi("game_godfield_rank",{gameData = data.god_integration_rank});

            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_god_integration_rank"), http_request_method.GET, params,"god_field_god_integration_rank")
            

        elseif btnTag == 105 then --购买船票
            if self.is_enter == false then
                local payCfg = getConfig(game_config_field.god_field_time);
                --cclog2(payCfg,"payCfg === ")
                payCfg = json.decode(payCfg:getFormatBuffer())
                --cclog2(payCfg["1"].cost,"payCfg === ")
                local payValue = payCfg["1"].cost
                local t_params = 
                        {
                            title = "Nhắc nhở",
                            okBtnCallBack = function(target,event)
                                require("game_ui.game_pop_up_box").close();
                                game_scene:setVisibleBroadcastNode(false);
                               local function responseMethod( tag,gameData )
                                    cclog2(gameData,"gameData")
                                    game_util:addMoveTips({text = "Đã mua!"})
                                    --self:refreshData()
                                end
                            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_buy_ship_ticket"), http_request_method.GET, params,"god_field_buy_ship_ticket")
                            end,   --可缺省
                            okBtnText = "Xác nhận",       --可缺省
                            text = "Tốn" .. payValue .. "Xu thần vực mua vé",      --可缺省
                            onlyOneBtn = true,          --可缺省
                        }
                        require("game_ui.game_pop_up_box").show(t_params);
                        retrunFlag = true;
            else
                game_util:addMoveTips({text = "Bạn đã mua vé, đợi đến thứ 7 vào nhé！"})
            end
        else

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_godfield_arean.ccbi");
   

    local root_map_node = tolua.cast(ccbNode:objectForName("root_map_node"), "CCNode");
    self.bg_layer = ccbNode:layerForName("bg_layer")

    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_btn_zhenxing = ccbNode:controlButtonForName("m_btn_zhenxing")
    self.m_btn_duihuan = ccbNode:controlButtonForName("m_btn_duihuan")
    self.m_label_score = ccbNode:labelTTFForName("m_label_score")
    self.playerLayer = ccbNode:layerForName("playerLayer")
    self.conutdownTime = ccbNode:nodeForName("conutdownTime")
    self.m_shuaxinshijian_lab = ccbNode:labelTTFForName("m_shuaxinshijian_lab")
    --cclog2(self.conutdownTime,"self.conutdownTime")
    self.m_scroll_rect = self.bg_layer:boundingBox()
    self.m_ccbNode = ccbNode;
    self:onEnter();

    -- self:createBuilding()
    return ccbNode;

end
function game_godfield_arean:createScrollContent( parentNode )
    local container = CCLayer:create()
    local size = parentNode:getContentSize()
    local view = CCScrollView:create(size, container)
    maxOffsetX = 0
    view:setAnchorPoint(ccp(0,0))
    container:setContentSize(CCSizeMake(size.width, size.height))
    view:setContentSize(CCSizeMake(1136, size.height))
    view:setContentOffset(ccp(0, 0));
    view:setTouchEnabled(false)
    view:setDirection(kCCScrollViewDirectionHorizontal)
    local background = CCSprite:create("ccbResources/godfield_build/godfield_build_BG.jpg")
    local map_ditu = CCSprite:create("ccbResources/godfield_build/godfield_build_ditu1.png")
    if self.random_num == 2 then
        map_ditu = CCSprite:create("ccbResources/godfield_build/godfield_build_ditu2.png")
    end
    view:addChild(background)
    view:addChild(map_ditu)
    self:createPlayerMapAnim(view,0)
    maxOffsetX = background:getContentSize().width - size.width
    return view
   
end
function game_godfield_arean:createBuildingPersonAnimMove_godfield(mAnimNode,pos,callBackFunc)
    if self.m_playerAnimNode == nil then 
        if callBackFunc and type(callBackFunc) == "function" then
            callBackFunc();
        end
        return;
    end
    --cclog2(self.m_playerAnimNode,"self.m_playerAnimNode")
    local zcAnimNode = self.zcAnimNode
    --cclog2(zcAnimNode,"zcAnimNode")
    self.m_playerAnimNode:stopAllActions();
    
    local pX,pY = self.m_playerAnimNode:getPosition();
    local offsetX,offsetY = pos.x - pX,pos.y - pY;
    if offsetX > 0 then
        if offsetY > 0 then--右上
            zcAnimNode:playSection("shangyou");
        elseif offsetY < 0 then--右下
            zcAnimNode:playSection("xiayou");
        else
            zcAnimNode:playSection("xiayouD");
        end
    else
        if offsetY > 0 then--左上
            zcAnimNode:playSection("shangzuo");
        elseif offsetY < 0 then--左下
            zcAnimNode:playSection("xiazuo");
        else
            zcAnimNode:playSection("xiazuo");
        end
    end
    local function animEndCallFunc()
        local curSectionName = zcAnimNode:getCurSectionName()
        if curSectionName == "shangyou" then
             zcAnimNode:playSection("xiayouD");
        elseif curSectionName == "xiayou" then
             zcAnimNode:playSection("xiayouD");
        elseif curSectionName == "shangzuo" then
             zcAnimNode:playSection("xiazuoD");
        elseif curSectionName == "xiazuo" then
             zcAnimNode:playSection("xiazuoD");
        end

        if callBackFunc and type(callBackFunc) == "function" then
            callBackFunc();
        end
    end
    local pix = math.sqrt(math.pow(pos.x - pX, 2) + math.pow(pos.y - pY, 2));
    local moveTime = 0;
    local animArr = CCArray:create();
    animArr:addObject(CCMoveTo:create(moveTime,pos));
    animArr:addObject(CCCallFunc:create(animEndCallFunc));
    self.m_playerAnimNode:runAction(CCSequence:create(animArr));
end
function game_godfield_arean:onEnter(  )
    local touchMoveFlag = false
    local selectFlag = false
    local selectIndex = nil
    local scrollviewOffset = nil
    local function layerTouch(eventType, x, y)
        if eventType == "began" then
            cclog("onTouchBegan: ", x, y)
            self.select_building = nil
            touchMoveFlag = false
            self.m_focus_block = nil
            selectFlag = false

            touch_start_x = x
            touch_start_y = y
            local touched = self.m_scroll_rect:containsPoint(ccp(x, y))
            scrollviewOffset = self.m_scroll_view:getContentOffset()
            
            for k,v in pairs(self.building_table) do
                local realPos = v:getParent():convertToNodeSpace(ccp(x,y));
                -- cclog2(ccp(x,y),"pos")
                -- cclog2(v:boundingBox(),"boundingBox")
                -- cclog2(realPos,"realPos")
                if v:boundingBox():containsPoint(realPos) then
                    self.touch_buildingTag = v:getTag()
                    --v:setScale(1.1)
                    self.select_building = v
                    selectFlag = true
                    selectIndex = k
                    break
                end
            end
            cclog2(touched,"touched")
            return touched
        elseif eventType == "moved" then
            -- cclog("onTouchMoved: ", x, y)
            --不让划出图片
            -- if scrollviewOffset.x + (x - touch_start_x) > -1136 and scrollviewOffset.x + (x - touch_start_x) < 0 then
            local srcollviewOffsetX = scrollviewOffset.x + (x - touch_start_x)
            -- cclog2(srcollviewOffsetX,"srcollviewOffsetX")
            if srcollviewOffsetX > 0 then
                srcollviewOffsetX = 0
            end
            if srcollviewOffsetX < - maxOffsetX then
                srcollviewOffsetX = - maxOffsetX
            end
            if self.select_building then
                local realPos = self.select_building:getParent():convertToNodeSpace(ccp(x,y));
                if self.select_building:boundingBox():containsPoint(realPos) then
                    
                else
                    self.select_building:setScale(1)
                    selectFlag = false
                end
            end
            if ccpDistance(ccp(touch_start_x,touch_start_y),ccp(x,y)) > 20 then
                touchMoveFlag = true
            end
            self.m_scroll_view:setContentOffset(ccp( srcollviewOffsetX, scrollviewOffset.y))
        elseif eventType == "ended" then
            if self.select_building then
                local realPos = self.select_building:getParent():convertToNodeSpace(ccp(x,y));
                self.select_building:setScale(1)
                if self.select_building:boundingBox():containsPoint(realPos) and touchMoveFlag == false then
                    --进入建筑
                    local gameData = self.m_tGameData.god_integration_rank
                    -- if os.date("%w",os.time()) == 7 then
                    --     game_util:addMoveTips({text = "周日未开启战斗模块"})
                    -- if self.is_enter == false and os.date("%w",os.time()) == 6 then
                    --     game_util:addMoveTips({text = "未购买船票，无法战斗"})

                    -- else
                    local function moveEndCallFunc( )
                        self:enterBuilding( self.select_building,self.touch_buildingTag )
                    end 
                    if self.m_playerAnimNode then
                         local pX,pY = self.select_building:getPosition();
                         self.lastPos = ccp(pX,pY+10)
                         self:createBuildingPersonAnimMove_godfield(self.m_playerAnimNode,ccp(pX,pY+10),moveEndCallFunc);
                    else
                         moveEndCallFunc()
                    end
                        
                    --end
                    --self.enterBuilding( self.select_building,self.touch_buildingTag )
                else
                    --self.enterBuilding( self.select_building,self.touch_buildingTag )
                end
                self.select_building = nil
            end
        end
    end
    
    self.bg_layer:registerScriptTouchHandler(layerTouch, false, 2, true)
    self.bg_layer:setTouchEnabled(true)

    --self:refreshUI()
end


function game_godfield_arean.createPlayerMapAnim(self,node,flag)
    -- if self.m_playerAnimNode then
    --     self.m_playerAnimNode:removeAllChildrenWithCleanup(true)
    --     self.m_playerAnimNode = 
    -- end
    if self.m_playerAnimNode == nil and node then

        local function onAnimSectionEnd(animNode2, theId,theLabelName)
            animNode2:playSection(theLabelName);
        end
        local pX,pY = node:getPosition();
        local animNode = game_util:createOwnRoleAnim();
        animNode:registerScriptTapHandler(onAnimSectionEnd)
        self.m_playerAnimNode = CCNode:create()
        self.m_playerAnimNode:addChild(animNode,10,100)
        self.zcAnimNode = animNode
        if self.m_playerAnimNode then
            if flag then
                self.m_playerAnimNode:setPosition(ccp(pX+35,pY +35))
            else
                self.m_playerAnimNode:setPosition(ccp(pX+60,pY + 60))
            end
            if self.lastPos then
                self.m_playerAnimNode:setPosition(self.lastPos)
            end
            self.m_playerAnimNode:setAnchorPoint(ccp(0.5,0));
            node:addChild(self.m_playerAnimNode,10,10)
        end
    end
end
function game_godfield_arean.enterBuilding(self,select_building,buildingTag)


    local sort = self.touch_buildingTag - 1000
    local enemy = "enemy_" .. sort 
    local win_flag = false
    if self.m_tGameData[enemy] ~= -1 then
        if self.win_sort ~= {}then
            for i,v in pairs(self.win_sort) do
                if sort == v then
                   win_flag = true
                end
            end
        end
        local params = {}
        params.sort = sort 
        local function responseMethod( target,gameData )

             game_scene:addPop("game_godfield_arean_enemy_pop",{gameData = gameData,sort = sort,win_flag = win_flag})
            -- body
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_see_enemy_info"), http_request_method.GET, params,"god_field_see_enemy_info")
    else
        local params = {}
        params.sort = sort 
        local function responseMethod( target,gameData )
             game_scene:addPop("game_godfield_arean_enemy_pop",{gameData = gameData,sort = sort})
            -- body
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_see_enemy_info"), http_request_method.GET, params,"god_field_see_enemy_info")
    end
end
--[[--
    刷新数据

]]
function game_godfield_arean.refreshData( self )
    cclog("refreshUi gameData === ==  == ")
    local function responseMethod( target,gameData )
        local gameData = gameData
        if gameData ~= nil and tolua.type(gameData) == "util_json" then
            local data = t_params.gameData:getNodeWithKey("data");
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};            
        end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")
    end
end
--[[--
    刷新ui
]]
function game_godfield_arean.refreshUi(self)
    -- self:onEnter()
    self.win_sort = self.m_tGameData.win_sort
    self.is_enter = self.m_tGameData.is_enter
    self.m_weekDay = self.m_tGameData.weekday 
        --cclog2(self.win_sort, "init  win sort ==== ")
    self.alignment = self.m_tGameData.alignment
    if self.m_tGameData.score then
        self.m_label_score:setString(self.m_tGameData.score)
    else
        self.m_label_score:setString("0")
    end
    self.conutdownTime:removeAllChildrenWithCleanup(true)
    local time_count_down = self.m_tGameData.time_count_down
     self:createBuilding()
    if self.m_tGameData.time_count_down and self.m_tGameData.m_tGameData ~= -1 and self.m_tGameData.time_count_down ~= 0 then
        self.m_shuaxinshijian_lab:setVisible(true)
        local function timeEndFunc()
            -- self.lastPos = nil;
            --self:destroy()
            local time_down_random = self.m_tGameData.time_count_down
            local function responseMethod( tag,gameData )
                math.randomseed(time_down_random)
                self.random_num = math.random(1,2)
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local data = gameData:getNodeWithKey("data");
                    self.m_tGameData = json.decode(data:getFormatBuffer()) 
                    self:refreshUi()
                end
            end
                
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")
        end
        local countdownLabel = game_util:createCountdownLabel(time_count_down + 10,timeEndFunc,8, 1);
        countdownLabel:setColor(ccc3(255, 255, 255))
        countdownLabel:setAnchorPoint(ccp(0.5,0.5))
        local tempcontent = self.conutdownTime:getContentSize()
        countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.6))
        self.conutdownTime:addChild(countdownLabel,10,10) 
    else
        self.m_shuaxinshijian_lab:setVisible(false)
    end
   
   
end
function game_godfield_arean.addAttackIcon( building ,buildingTag )
    -- body
    buildingSize = building:getContentSize()
    local zhandou = CCSprite:create("ccbResources/godfield_build/godfield_gongji.png")
    buildingTag = tonumber(buildingTag);
    if buildingTag == 1000 then
        zhandou:setScale(0.7)
        zhandou:setPosition(ccp(buildingSize.width*0.5-5,buildingSize.height*0.8+5))
        building:addChild(zhandou)
   
    else
        zhandou:setScale(0.7)
        zhandou:setPosition(ccp(buildingSize.width*0.5,buildingSize.height*0.1))
        building:addChild(zhandou)
    end

end
--[[--
    创建建筑物
]]
function game_godfield_arean.createBuilding(self)
    local buildingName = ("building_tab" .. self.random_num)
    -- cclog2(building_tab,"building_ta ==== ")
    --self.building_tab  = buildingName 
    self.building_table = {}
   
    self.bg_layer:removeAllChildrenWithCleanup(true);
    if self.m_playerAnimNode then
        self.m_playerAnimNode = nil
    end
    self.m_scroll_view =  self:createScrollContent(self.bg_layer)

    self.bg_layer:addChild(self.m_scroll_view)
    for k,v in pairs(building_tab[tostring(buildingName)]) do
        local buildingTag = v.tag
        local colorFlag = v.colorFlag
        local building = CCSprite:create(v.img)
        local enemy_num = tostring("enemy_" .. k-1)
        colorFlag = self.m_tGameData[enemy_num]
        building:setAnchorPoint(ccp(0.5,0.5))
        local buildingSize = building:getContentSize()
        building:setPosition(ccp(v.offset[1] - buildingSize.width*0.5-29,320 - v.offset[2] - buildingSize.height*0.5+1))
        if colorFlag == -1 then
            building:setColor(ccc3(30,30,30))
            local zhandou = CCSprite:create("ccbResources/godfield_build/godfield_gongji.png")
            zhandou:setScale(0.7)
            local temp_iconSize = zhandou:getContentSize()
            
            zhandou:setPosition(ccp(v.offset2[1] - temp_iconSize.width*0.5-29,320 - v.offset2[2] - temp_iconSize.height*0.5+1))
            self.m_scroll_view:addChild(zhandou,2)
        end
       
        --building:setPosition(ccp(v.offset[1],v.offset[2]))
        self.m_scroll_view:addChild(building,1,buildingTag)
        table.insert( self.building_table, building )
    end
end

--[[--
    初始化
]]
function game_godfield_arean.init(self,t_params)
    t_params = t_params or {};
    self.m_buildingTable = {};
    local x = os.date("%w",os.time())
    self.random_num = t_params.random_num or 2
    self.m_touchRef = 0;
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        self.win_sort = self.m_tGameData.win_sort
        self.is_enter = self.m_tGameData.is_enter 
        --cclog2(self.win_sort, "init  win sort ==== ")
        self.alignment = self.m_tGameData.alignment
    else
        self.m_tGameData = {};
    end
        self.buildingTag_tab = {}
    -- self.m_label_score = 
    -- self.m_label_timedown =
end

     
  


--[[--
    创建入口
]]
function game_godfield_arean.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    -- self:openBuildingDetailPop();
    -- self:showMainSceneTips();
    return rootScene;
end
return game_godfield_arean;