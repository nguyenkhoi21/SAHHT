--- 噩梦之塔

local game_nightmare_main = {
	m_back_btn = nil,
	m_scrollView_node = nil,
	m_scroll_view = nil,
    m_rules_btn = nil,
    m_formation_btn = nil,
    m_buildTab = nil,
    build_posTab = nil,
    m_cloud_node = nil,
    m_gameData = nil,
    m_reset_lab = nil,
    m_cango_lab = nil,
    m_history_lab = nil,
    m_currentNum_lab = nil,
    m_go_btn = nil,
    m_formation_btn = nil,
    new_fight_forever_cfg = nil,
    m_reward_tab = nil,
    m_needBlink_index = nil,
    m_current_stars = nil,
    m_root_layer = nil,
    touchMoveFlag = nil,
    select_building = nil,
};
--[[--
    销毁ui
]]
function game_nightmare_main.destroy(self)
	self.m_back_btn = nil;
	self.m_scrollView_node = nil;
	self.m_scroll_view = nil;
    self.m_rules_btn = nil;
    self.m_formation_btn = nil;
    self.m_buildTab = nil;
    self.build_posTab = nil;
    self.m_cloud_node = nil;
    self.m_gameData = nil;
    self.m_reset_lab = nil;
    self.m_cango_lab = nil;
    self.m_history_lab = nil;
    self.m_currentNum_lab = nil;
    self.m_go_btn = nil;
    self.m_formation_btn = nil;
    self.new_fight_forever_cfg  = nil;
    self.m_reward_tab = nil;
    self.m_needBlink_index = nil;
    self.m_current_stars = nil;
    self.m_root_layer = nil;
    self.touchMoveFlag = nil;
    self.select_building = nil;
end

--[[--
    返回
]]
function game_nightmare_main.back(self,type)
    game_scene:enterGameUi("game_main_scene");
end
local m_box_posTab = {ccp(56,163.5),ccp(88,98.5),ccp(180,138.5),ccp(275,181.5),ccp(287,131.5),
                        ccp(317.5,93),ccp(423,165),ccp(490,119.5),ccp(537.5,85.5),ccp(645.5,132.5),
                        ccp(733.5,183),ccp(773,145),ccp(786,97),ccp(880.5,160),ccp(958,123.5),
                        ccp(1010,96.5),ccp(1105,136),ccp(1201.5,183.5),ccp(1229.5,145),ccp(1248,97.5),
                        ccp(1330,148.5),ccp(1423,185.5),ccp(1385,110.5),ccp(1475,98),ccp(1565,130),
                        ccp(1687,189.5),ccp(1660,124),ccp(1780,121),ccp(1855,116),ccp(1921.5,96.5),
                        ccp(2001.5,139),ccp(2055.5,188.5),ccp(2150,161.5),ccp(2139,111.5),ccp(2042,90)
}
--[[--
    读取ccbi创建ui
]]
function game_nightmare_main.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
        	self:back()
        elseif btnTag == 102 then --查看规则
            game_scene:addPop("game_active_limit_detail_pop",{enterType = "175"})
        elseif btnTag == 103 then --阵型
            local function responseMethod(tag,gameData)
                if gameData then
                    game_scene:enterGameUi("game_god_adjustment",{gameData = gameData,openType="nightmare",});
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_upload_god_formation"), http_request_method.GET, nil,"god_field_upload_god_formation",true,true)
        elseif btnTag == 104 then -- 突进
            local function responseMethod(tag,gameData)
                if gameData then
                    local is_win = gameData:getNodeWithKey("data"):getNodeWithKey("battle_result"):getNodeWithKey("is_win"):toInt()
                    if is_win == 1 then
                        game_util:addMoveTips({text = "Bạn đã đột tiến thêm 1 tầng"})
                        local reward = gameData:getNodeWithKey("data"):getNodeWithKey("rewards")
                        game_util:rewardTipsByJsonData(reward)
                        local function responseMethod( tag,gameData )
                            if gameData then
                                local data = gameData:getNodeWithKey("data");
                                self.m_gameData = json.decode(data:getFormatBuffer()) or {};
                                self.m_needBlink_index  = self.m_gameData.current_stars
                                game_data:setNightmareSelectBuildIndex()
                                self:refreshUi()
                            end
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_fight_forever_index"), http_request_method.GET, nil,"new_fight_forever_index")   
                    else
                        game_util:addMoveTips({text = "Trong quá trình đột tiến chưa đánh bại đối thủ"})
                    end
                    game_util:setPlayerPropertyByCCBAndTableData2(ccbNode)
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_fight_forever_fast_fight"), http_request_method.GET, nil,"new_fight_forever_fast_fight",true,true)
        elseif btnTag == 105 then -- 重置
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                    local function responseMethod(tag,gameData)
                        if gameData then
                            local data = gameData:getNodeWithKey("data");
                            self.m_gameData = json.decode(data:getFormatBuffer()) or {};
                            game_data:setNightmareSelectBuildIndex()
                            self:refreshUi()
                        end
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_fight_forever_reset"), http_request_method.GET, nil,"new_fight_forever_reset",true,true)
                end,   --可缺省
                cancelBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                end,
                okBtnText = "Xác nhận",       --可缺省
                cancelBtnText = "Hủy",
                onlyOneBtn = false,
                text = "Xác nhận reset ải hiện tại?",      --可缺省
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            game_util:openAlertView(t_params);

          
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_nightmare.ccbi");
    game_util:setPlayerPropertyByCCBAndTableData2(ccbNode)
   	self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_scrollView_node = ccbNode:nodeForName("m_scrollView_node");
    self.m_rules_btn = ccbNode:controlButtonForName("m_rules_btn");
    self.m_formation_btn = ccbNode:controlButtonForName("m_formation_btn");
    self.m_reset_lab = ccbNode:labelTTFForName("m_reset_lab")
    self.m_cango_lab = ccbNode:labelTTFForName("m_cango_lab")
    self.m_history_lab = ccbNode:labelTTFForName("m_history_lab")
    self.m_currentNum_lab = ccbNode:labelTTFForName("m_currentNum_lab")
    self.m_go_btn = ccbNode:controlButtonForName("m_go_btn")
    self.m_formation_btn = ccbNode:controlButtonForName("")
    self.m_cloud_node  = ccbNode:nodeForName("m_cloud_node")
    self.m_root_layer  = ccbNode:layerForName("root_layer")
    return ccbNode;
end

function game_nightmare_main.createBuild( self,view )
    self.m_buildTab = {}
    self.build_posTab =   {ccp(100,190),ccp(12,115),ccp(145,90),ccp(185,165),ccp(335,160),
                            ccp(245,77),ccp(378,95),ccp(510,175),ccp(470,64),ccp(595,85),
                            ccp(660,170),ccp(797,182),ccp(723,88),ccp(833,90),ccp(978,170),
                            ccp(920,57),ccp(1060,90),ccp(1120,168),ccp(1265,175),ccp(1170,87),
                            ccp(1290,90),ccp(1350,187),ccp(1460,145),ccp(1410,60),ccp(1520,85),
                            ccp(1610,175),ccp(1730,178),ccp(1700,70),ccp(1850,172),ccp(1860,60),
                            ccp(1963,93),ccp(1990,169),ccp(2095,180),ccp(2175,123),ccp(2083,80)}
    for i=1,35 do
        local build = CCSprite:create("ccbResources/nightmare_build/Nightmare_build" .. i ..".png")
        view:addChild(build,10)
        build:setTag(i)
        build:setPosition(self.build_posTab[i])
        if i <= self.m_gameData.max_chapter then
            build:setColor(ccc3(255,255,255))
        else
            build:setColor(ccc3(60,60,60))
        end
        self.m_buildTab[i] = build

        local illusion = CCSprite:createWithSpriteFrameName("Nightmare_illusion.png")
        view:addChild(illusion,9)
        illusion:setPosition(self.build_posTab[i])
        illusion:setAnchorPoint(ccp(0.1,0.2))
    end
    local startFlag = CCSprite:createWithSpriteFrameName("godfield_start.png")
    local endFlag = CCSprite:createWithSpriteFrameName("godfield_end.png")
    view:addChild(startFlag,10)
    view:addChild(endFlag,10)
    startFlag:setPosition(ccp(160,220))
    endFlag:setPosition(ccp(2073,80))
end
function game_nightmare_main.enterBuildingOrBox(self )
        local btnTag = self.select_building:getTag()
        if btnTag > 50  then
            local have_chapter_reward = self.m_gameData.have_chapter_reward
            local isGetFlag = have_chapter_reward[btnTag-49]
            if isGetFlag == 0 then
                local gameData = self.new_fight_forever_cfg[tostring(btnTag-50)].reward_show
                game_scene:addPop("game_nightmare_reward_pop",{gameData = gameData})
            elseif isGetFlag == 1 then
                local function responseMethod( tag,gameData )
                    local reward = gameData:getNodeWithKey("data"):getNodeWithKey("rewards")
                    game_util:rewardTipsByJsonData(reward)
                    local function responseMethod( tag,gameData )
                    if gameData then
                        self.m_needBlink_index = -1
                        local data = gameData:getNodeWithKey("data");
                        self.m_gameData = json.decode(data:getFormatBuffer()) or {};
                        local offsetX = self.m_scroll_view:getContentOffset().x
                        self:refreshUi(offsetX)
                    end
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_fight_forever_index"), http_request_method.GET, nil,"new_fight_forever_index")   
                end
                local params = {}
                params.chapter = btnTag - 50
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_fight_forever_reward"), http_request_method.GET,params,"new_fight_forever_reward")--周一到周五的界面
            elseif isGetFlag == 2 then
            end
        else
            game_data:setNightmareSelectBuildIndex(btnTag)
            local needStar = self.new_fight_forever_cfg[tostring(btnTag)].need_star
            if self.m_gameData.current_stars >= needStar then
                local function responseMethod( tag,gameData )
                    if gameData then
                        game_scene:addPop("game_nightmare_enemy_pop",{gameData = gameData,index = btnTag})
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_index"), http_request_method.GET, {},"god_field_index")--周一到周五的界面
            end
        end
end
function game_nightmare_main.createStar(self,i)
    local have_chapter_star = self.m_gameData.have_chapter_star
    local star = CCSprite:createWithSpriteFrameName("Nightmare_star2.png")
    star:setAnchorPoint(ccp(0.5,0.5))
    star:setPosition(28,7)
    self.m_buildTab[i]:addChild(star,10)
    local animArr = CCArray:create()
    animArr:addObject(CCScaleTo:create(0.1,0.1));
    animArr:addObject(CCScaleTo:create(0.5,2));
    animArr:addObject(CCScaleTo:create(0.5,1));
    if self.m_gameData.have_chapter_star[i+1] == 1 then
        local star = CCSprite:createWithSpriteFrameName("Nightmare_star1.png")
        star:setAnchorPoint(ccp(0.5,0.5))
        star:setPosition(28,7)
        self.m_buildTab[i]:addChild(star,11)
        if self.m_needBlink_index == -1 then -- 星星不闪
        elseif self.m_needBlink_index == 0 then --星星全闪
            star:runAction(CCSequence:create(animArr))
        else --指定的闪
            if i == self.m_needBlink_index then
                star:runAction(CCSequence:create(animArr))
            end
        end
    end
end
function game_nightmare_main.createBox( self,i,view )
    if i<36 then
        local have_chapter_reward = self.m_gameData.have_chapter_reward
        local isGetFlag = have_chapter_reward[i+1]
        local imgfile = ""
        if isGetFlag == 0 then
            imgfile = "Nightmare_box1.png"
        elseif isGetFlag == 1 then
            imgfile = "Nightmare_box2.png"
        elseif isGetFlag == 2 then
            imgfile = "Nightmare_box3.png"
        end
        local box = CCSprite:createWithSpriteFrameName(imgfile)
        view:addChild(box,10)
        -- local box_x = (self.build_posTab[i+1].x - self.build_posTab[i].x)/2 + self.build_posTab[i].x
        -- local box_y = (self.build_posTab[i+1].y - self.build_posTab[i].y)/2 + self.build_posTab[i].y
        box:setPosition(m_box_posTab[i])
        box:setTag(i+50)
        self.m_buildTab[i+50] = box
    end
    -- body
end

function game_nightmare_main.createScrollContent(self,parentNode)
    local posTab = {ccp(0,8),ccp(456,-10),ccp(912.5,-10),ccp(1369,-10),ccp(1825.5,-2),}
    local container = CCLayer:create()
    local size = parentNode:getContentSize()
    container:setContentSize(CCSizeMake(size.width, 602))
    local view = CCScrollView:create(size, container)
	self.m_scroll_view = view
	view:setAnchorPoint(ccp(0,0))
	view:setContentSize(CCSizeMake(2247, 602))
	view:setTouchEnabled(false)
    view:setContentOffset(ccp(0,0));
	view:setDirection(kCCScrollViewDirectionHorizontal)
    local width = math.floor(2247/5)+5
    for i=1,5 do
        local x = i
        if i>1 and i<5 then
            x = 2
        elseif x>4 then 
            x = 3
        end
        local map_ditu = CCSprite:create("ccbResources/nightmare_rold" .. x ..".png")
        map_ditu:setPosition(posTab[i])
        view:addChild(map_ditu)
    end
    self:createBuild(view)
    return view
end

--[[--
    创建触摸
]]
local touchBeginPoint = nil
local touchBeginPoint2 = nil
local scrollviewOffset = ccp(0,0)
function game_nightmare_main.createTouch( self)
    local touchMoveFlag = false
    local maxOffsetX = 2247 - self.m_scrollView_node:getContentSize().width
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            local touched = false
            touchMoveFlag = false
            touchBeginPoint = {x = x, y = y}
            touchBeginPoint2 = {x = x, y = y}
            local touched = self.m_scrollView_node:boundingBox():containsPoint(ccp(x, y))
            for k,v in pairs(self.m_buildTab) do
                local realPos = v:getParent():convertToNodeSpace(ccp(x,y));
                if v:boundingBox():containsPoint(realPos) then
                    v:setScale(1.1)
                    self.select_building = v
                    break
                end
            end
            return touched
        elseif eventType == "moved" then
            scrollviewOffset = self.m_scroll_view:getContentOffset()
            local srcollviewOffsetX = scrollviewOffset.x + (x - touchBeginPoint.x)
            
            if srcollviewOffsetX >= 0 then
                srcollviewOffsetX = 0
            end
            if srcollviewOffsetX < - maxOffsetX then
                srcollviewOffsetX = - maxOffsetX
            end
            if ccpDistance(ccp(touchBeginPoint2.x,touchBeginPoint2.y),ccp(x,y)) > 20 then
                touchMoveFlag = true
            end
            if srcollviewOffsetX >= - maxOffsetX and - maxOffsetX <= 0 then
                self.m_scroll_view:setContentOffset(ccp( srcollviewOffsetX,scrollviewOffset.y))
            end
            if self.select_building then
                local realPos = self.select_building:getParent():convertToNodeSpace(ccp(x,y));
                if self.select_building:boundingBox():containsPoint(realPos) then
                else
                    self.select_building:setScale(1)
                end
            end
            touchBeginPoint = {x=x,y=y}
        else
            if self.select_building then
                local realPos = self.select_building:getParent():convertToNodeSpace(ccp(x,y));
                self.select_building:setScale(1)
                if self.select_building:boundingBox():containsPoint(realPos) and touchMoveFlag == false then
                    --进入建筑
                    self:enterBuildingOrBox()
                else
                    
                end
                self.select_building = nil
            end
        end
    end
    
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY)
    self.m_root_layer:setTouchEnabled(true)
    -- body
end
--[[
    创建云层
]]
function game_nightmare_main.createCloud( self,node )
    -- 获得云层初始位置
    local buildIndex = 1
    for i=1,35 do
        local length = game_util:getTableLen(self.new_fight_forever_cfg)
        local needStar = self.new_fight_forever_cfg[tostring(i)].need_star
        -- cclog2(self.m_gameData.current_stars,"self.m_gameData.current_stars ==")
        if self.m_gameData.current_stars < needStar then
            buildIndex = i
            break
        elseif self.m_gameData.current_stars >= needStar and i == length then
            buildIndex = 9999
            break
        end
    end
    local function setCloudPosition(m,buildIndex)
        for i = 1,6-m do
            local m_cloud_sp = CCSprite:create(("ccbResources/Nightmare_cloud.png"))
            m_cloud_sp:setPosition(880/2*(i-1)+self.build_posTab[buildIndex-1].x+30,-25)
            m_cloud_sp:setAnchorPoint(ccp(0,0))
            node:addChild(m_cloud_sp)
        end
    end
    if buildIndex < 8 then
        setCloudPosition(1,buildIndex)
    elseif buildIndex > 7 and buildIndex < 15 then
        setCloudPosition(2,buildIndex)
    elseif buildIndex >14 and buildIndex <22 then
        setCloudPosition(3,buildIndex)
    elseif buildIndex > 21 and buildIndex <29 then 
        setCloudPosition(4,buildIndex)
    elseif buildIndex > 28 and buildIndex ~= 9999 then
        setCloudPosition(5,buildIndex)
    elseif buildIndex == 9999 then

    end
end
--[[--
	创建地图
]]
function game_nightmare_main.createMap(self)
    if self.m_scroll_view then
        self.m_scroll_view:getContainer():removeAllChildrenWithCleanup(true)
    end
    self.m_scroll_view = self:createScrollContent(self.m_scrollView_node)
    self.m_scrollView_node:addChild(self.m_scroll_view)
    local node = CCNode:create();
    self.m_scroll_view:addChild(node,12)
    self:createCloud(node)
end
--[[--
    刷新label
]]
function game_nightmare_main.refreshLabel( self )
    if self.m_gameData and next(self.m_gameData) then
        local user_reset = self.m_gameData.user_reset or 0 
        self.m_current_stars = self.m_gameData.current_stars or 0
        local max_chapter = self.m_gameData.max_chapter or 0 --当前关卡
        local historical_max_chapter = self.m_gameData.historical_max_chapter or 0
        self.m_reset_lab:setString("Số lần reset: " .. tostring(user_reset))
        local cangoChapter = historical_max_chapter - 3
        if cangoChapter < 0 then
            cangoChapter = 0
        end
        self.m_cango_lab:setString("Đột tiến đến: " .. tostring(cangoChapter))
        self.m_history_lab:setString("Tầng cao nhất: " .. tostring(historical_max_chapter))
        self.m_currentNum_lab:setString(tostring(self.m_current_stars))
    end
end
function game_nightmare_main.setCurrentOffset( self,pos )
    local maxOffsetX = 2247 - self.m_scrollView_node:getContentSize().width
    local realpos  = self.m_scroll_view:getParent():convertToNodeSpace(pos)
    local currenOffset = realpos.x - 235
    if -currenOffset > 0 then 
        currenOffset = 0 
    elseif -currenOffset < -maxOffsetX then
        currenOffset = maxOffsetX
    end
    self.m_scroll_view:setContentOffset(ccp(-currenOffset,0),false)
end 
--[[--
    刷新ui
]]
function game_nightmare_main.refreshUi(self,openBoxFlag)
	self:createMap()
    self:refreshLabel()
    for i=1,35 do
        self:createStar(i)
        self:createBox(i,self.m_scroll_view)
    end
    if openBoxFlag  then
        self.m_scroll_view:setContentOffset(ccp(openBoxFlag,0))
    else
        if game_data:getNightmareSelectBuildIndex() then
            self:setCurrentOffset(self.build_posTab[game_data:getNightmareSelectBuildIndex()])
        else
            if self.m_gameData.max_chapter and self.m_gameData.max_chapter > 0 and self.m_gameData.max_chapter < 36 then
                self:setCurrentOffset(self.build_posTab[self.m_gameData.max_chapter])
            else
                self.m_scroll_view:setContentOffset(ccp(0,0),true)
            end
        end
    end
    self:createTouch()
end
--[[--
    初始化
]]
function game_nightmare_main.init(self,t_params)
    t_params = t_params or {};
    local reward = t_params.reward or game_data:getNightmareReward()
    if reward and next(reward) then
         game_util:rewardTipsByDataTable(reward);
    end
    game_data:setNightmareReward()
    self.build_posTab = {}
    self.m_reward_tab = {}
    self.touchMoveFlag = false
    self.m_needBlink_index = 0
    self.new_fight_forever_cfg = json.decode(getConfig(game_config_field.new_fight_forever):getFormatBuffer())
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_gameData = json.decode(data:getFormatBuffer()) or {};
        if game_data:getNightmareSelectBuildIndex() then
            self.m_needBlink_index = game_data:getNightmareSelectBuildIndex()
        end
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_nightmare_main.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_nightmare_main;