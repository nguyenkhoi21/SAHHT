---  虫洞斗兽场地图

local game_wormhole_map = {
    m_Gamedata = nil,
    maptype = nil,
    m_sel_enemy = nil,
    m_map_cfg = nil,
    m_mapdata = nil,

    ---------
    m_sp_title = nil,
    m_lb_times  =   nil,
    m_lb_recards    =   nil,
    m_scroll_map    =   nil,
    m_lb_right_name     =   nil,
    m_lb_right_area     =   nil,
    m_lb_right_level    =   nil,
    m_lb_right_combats  =   nil,
    m_lb_right_union    =   nil,
    m_btn_challenge     =   nil,
    m_btn_inc = nil,

    m_ccbNode = nil,
    -- m_ccbNode2 = nil,
    m_node_content = nil,
    
    selfpos = nil,
    bigbossPos = {},
    tinybossPos = {},
    m_root_layer = nil,

    scnode = nil,
    targetEnemy = {},
    targetEnemydata = nil,

    targetPos = nil,

    selActionsp = nil,
    m_colosseum_limited_cfg = nil,
    m_tinyboss = {},
    m_times_cost = nil,

};
--[[--
    销毁
]]
function game_wormhole_map.destroy(self)
    -- body
    cclog("-----------------game_wormhole_map destroy-----------------");
    self.m_Gamedata = nil
    self.maptype = nil
    self.m_sel_enemy = nil
    self.m_map_cfg = nil
    self.m_mapdata = nil


    self.m_sp_title = nil
    self.m_lb_times  =   nil
    self.m_lb_recards    =   nil
    self.m_scroll_map    =   nil
    self.m_lb_right_name     =   nil
    self.m_lb_right_area     =   nil
    self.m_lb_right_level    =   nil
    self.m_lb_right_combats  =   nil
    self.m_lb_right_union    =   nil
    self.m_btn_challenge     =   nil
    self.m_btn_inc = nil
    self.m_ccbNode = nil
    -- self.m_ccbNode2 = nil
    self.m_node_content = nil
    self.selfpos = nil
    self.bigbossPos = nil
    self.tinybossPos = nil
    self.m_root_layer = nil
    self.scnode = nil
    self.targetEnemy = nil
    self.targetEnemydata = nil
    self.targetPos = nil
    self.selActionsp = nil
    self.m_colosseum_limited_cfg = nil

    self.m_tinyboss = nil
    self.m_times_cost = nil
end

local toptitle = {  "ui_wormhole_map_toptitle_xiajian.png",
                    "ui_wormhole_map_toptitle_liefeng.png",
                    "ui_wormhole_map_toptitle_ciyuan.png",
                    "ui_wormhole_map_toptitle_pingxing.png"
                }
local MAXLEN = 13
local ICONSIZE = 0
--[[--
    返回
]]
function game_wormhole_map.back(self,backType)
    self:destroy();
    local function responseMethod( tag,gameData )
        local data = gameData:getNodeWithKey("data");
        data = json.decode(data:getFormatBuffer()) or {}
        game_scene:enterGameUi("game_wormhole_main",{gameData = data});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_index"), http_request_method.GET, {},"wormholes_index")
end
--[[--
    读取ccbi创建ui
]]
function game_wormhole_map.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 99999 then
            self:back("back");
        elseif btnTag == 1 then
            if self.targetEnemydata == nil then
                game_util:addMoveTips({text = "Hãy chọn kẻ địch!"})
            else
                if self.targetEnemydata.server == "TINYBOSS" then
                    local t_params = {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            game_util:closeAlertView();
                            local function responseMethod( tag,gameData )
                                game_data:setBattleType("wormhole");
                                game_data:setWormtype_battle(self.maptype)
                                game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                            end
                            local params = {}
                            params.sort = self.maptype.maptype
                            params.pos_id = self.targetPos
                            -- cclog2(params.sort,"wormholes_go_fight  kong  sort    ")
                            -- cclog2(params.pos_id,"wormholes_go_fight     kong   pos_id  " )
                            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_go_fight"), http_request_method.GET, params,"wormholes_go_fight")
                        end,   --可缺省
                        cancelBtnCallBack = function(target,event)
                            game_util:closeAlertView();
                        end,
                        okBtnText = "Xác nhận",       --可缺省
                        cancelBtnText = "Hủy",
                        onlyOneBtn = false,
                        text ="Gặp phải Hổ cản đường, có bẻ răng không?",      --可缺省
                        touchPriority = GLOBAL_TOUCH_PRIORITY-12,
                    }
                    game_util:openAlertView(t_params);
                else
                    game_scene:addPop("game_wormhole_occupier", {gameData = self.targetEnemydata,sort= self.maptype.maptype ,pos_id = self.targetPos,maptype = self.maptype})
                end
            end

        elseif btnTag == 201 then
            -- 阵型
            local function responseMethod( tag,gameData )
                local data = gameData:getNodeWithKey("data");
                data = json.decode(data:getFormatBuffer()) or {}
                game_scene:enterGameUi("game_wormhole_adjustment_formation",{gameData = data,opentype = "map",maptype =self.maptype }); --先传一个table吧
                
            end
            local params = {}
            params.sort = self.maptype.maptype
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_get_sort_cards"), http_request_method.GET, params,"wormholes_get_sort_cards")

        elseif btnTag == 202 then
            -- 地图
            game_scene:addPop("game_wormhole_minimap", {gameData = self.m_mapdata,selfpos = self.selfpos,tinyboss = self.m_tinyboss})
            
        elseif btnTag == 203 then
            -- 增加次数
            self.m_times_cost = self.m_times_cost or 50
            local t_params = {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                    local function responseMethod( tag,gameData )
                        local data = gameData:getNodeWithKey("data");
                        data = json.decode(data:getFormatBuffer()) or {}
                
                        self.m_times_cost = data.need_next_coin
                        self.m_lb_times:setString("Số lần chiến đấu:"..data.remain_times.."/"..self.m_colosseum_limited_cfg:getNodeWithKey(self.maptype.maptype):getNodeWithKey("limited_time"):toStr())
                    end
                    local params = {}
                    params.sort = self.maptype.maptype
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_buy_point"), http_request_method.GET, params,"wormholes_buy_point")
                end,   --可缺省
                cancelBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                end,
                okBtnText = "Xác nhận",       --可缺省
                cancelBtnText = "Hủy",
                onlyOneBtn = false,
                text ="Có tiêu tiền không"..self.m_times_cost.."Kim Cương bổ sung 1 lần chiến đấu?",      --可缺省
                touchPriority = GLOBAL_TOUCH_PRIORITY-12,
            }
            game_util:openAlertView(t_params);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_wormhole_map.ccbi");
    self.m_ccbNode = ccbNode
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    -- ccbNode2:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    -- ccbNode2:openCCBFile("ccb/ui_game_wormhole_map_content.ccbi");
    -- self.m_ccbNode2 = ccbNode2

    self.m_sp_title = ccbNode:spriteForName("m_sp_title")
    self.m_lb_times  =   ccbNode:labelTTFForName("m_lb_times")
    self.m_lb_recards    =   ccbNode:labelTTFForName("m_lb_recards")
    self.m_scroll_map    =   ccbNode:scrollViewForName("m_scroll_map")
    self.m_lb_right_name     =   ccbNode:labelTTFForName("m_lb_right_name")
    self.m_lb_right_area     =   ccbNode:labelTTFForName("m_lb_right_area")
    self.m_lb_right_level    =   ccbNode:labelTTFForName("m_lb_right_level")
    self.m_lb_right_combats  =   ccbNode:labelTTFForName("m_lb_right_combats")
    self.m_lb_right_union    =   ccbNode:labelTTFForName("m_lb_right_union")
    self.m_btn_challenge     =   ccbNode:controlButtonForName("m_btn_challenge")
    self.m_btn_inc = ccbNode:controlButtonForName("m_btn_inc")

    ccbNode:controlButtonForName("m_btn_reward"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    ccbNode:controlButtonForName("m_btn_rank"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    ccbNode:controlButtonForName("m_btn_close"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    ccbNode:controlButtonForName("m_btn_inc"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    ccbNode:controlButtonForName("m_btn_challenge"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)

    -- self.m_node_content = self.m_ccbNode2:nodeForName("m_node_content")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- cclog("touch  began--------->>   ",x,y)
            local minx = self.m_scroll_map:convertToWorldSpace(ccp(0,0)).x
            local miny = self.m_scroll_map:convertToWorldSpace(ccp(0,0)).y
            local width = self.m_scroll_map:getViewSize().width
            local height = self.m_scroll_map:getViewSize().height
            if x > minx and y > miny and x < (minx + width ) and y < (miny + height )  then
                self:onTouchBegan(x, y)
            end
            return false
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);

    return ccbNode;
end
function game_wormhole_map:onTouchBegan(x, y)
    local realpos = self.scnode:convertToNodeSpace(ccp(x,y));

    -- 直捣黄龙
    if realpos.x > self.bigbossPos.x -ICONSIZE*0.5 and realpos.y > self.bigbossPos.y -ICONSIZE*0.5 and realpos.x< self.bigbossPos.x + ICONSIZE*0.5 and realpos.y < self.bigbossPos.y + ICONSIZE*0.5 then
        cclog(" touch   big boss")
        local t_params = {
            title = string_config.m_title_prompt,
            okBtnCallBack = function(target,event)
                game_util:closeAlertView();
                local function responseMethod( tag,gameData )
                    local battleData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer());
                    if battleData.battle.init then
                        game_data:setBattleType("wormhole");
                        game_data:setWormtype_battle(self.maptype)
                        game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                    end 
                end
                local bigx = math.floor((MAXLEN + 1 ) /2)
                local bigy = math.floor((MAXLEN + 1 ) /2)
                local params = {}
                params.sort = self.maptype.maptype
                params.pos_id = bigx.."-"..bigy
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_go_fight"), http_request_method.GET, params,"wormholes_go_fight")
            end,   --可缺省
            cancelBtnCallBack = function(target,event)
                game_util:closeAlertView();
            end,
            okBtnText = "Xác nhận",       --可缺省
            cancelBtnText = "Hủy",
            onlyOneBtn = false,
            text ="Đây là sào huyệt của BOSS khổng lồ, có muốn do thám không?",      --可缺省
            touchPriority = GLOBAL_TOUCH_PRIORITY-12,
        }
        game_util:openAlertView(t_params);
        return
    end

    for k,v in pairs(self.targetEnemy) do
        -- cclog("chakan  diren =============================")
        if v.num ~= 0 then
            if self.m_mapdata[v.num].sp:boundingBox():containsPoint(realpos) then
                local function responseMethod( tag,gameData )
                    local data = gameData:getNodeWithKey("data");
                    data = json.decode(data:getFormatBuffer()) or {}
                    if data.all_tiny_boss ~= nil then
                        for k,v in pairs(self.m_tinyboss) do
                            if data.all_tiny_boss[k] == nil then
                                if self.m_tinyboss[k].sp then
                                    self.m_tinyboss[k].sp:removeFromParentAndCleanup(true)
                                    self.m_tinyboss[k] = nil
                                end
                            end
                        end
                    end
                    if data.user_info == nil then
                        local t_params = {
                            title = string_config.m_title_prompt,
                            okBtnCallBack = function(target,event)
                                game_util:closeAlertView();
                                local function responseMethod( tag,gameData )
                                    local datanew = gameData:getNodeWithKey("data");
                                    datanew = json.decode(datanew:getFormatBuffer()) or {}
                                    local newpos = datanew.pos
                                    self.m_Gamedata.remain_times = datanew.remain_times
                                    self.m_Gamedata.own_score = datanew.score
                                    self.selfpos.x = tonumber(string.sub(newpos,0,string.find(newpos,"-")-1))
                                    self.selfpos.y = tonumber(string.sub(newpos,string.find(newpos,"-")+1,-1))
                                    self.m_lb_times:setString("Số lần chiến đấu: "..self.m_Gamedata.remain_times.."/"..self.m_colosseum_limited_cfg:getNodeWithKey(self.maptype.maptype):getNodeWithKey("limited_time"):toStr())      
                                    self.m_lb_recards        :setString("Điểm của tôi: "..self.m_Gamedata.own_score)  
                                    if self.selActionsp then  --先移除掉之前的
                                        self.selActionsp:stopActionByTag(100)
                                        local parent = self.selActionsp:getParent()
                                        parent:removeAllChildrenWithCleanup(true)
                                    end
                                    self.targetEnemydata = nil
                                    self.selActionsp = nil
                                    self.m_lb_right_name     :setString("------")
                                    self.m_lb_right_area     :setString("------")
                                    self.m_lb_right_level    :setString("------")
                                    self.m_lb_right_combats  :setString("------")
                                    self.m_lb_right_union    :setString("------")
                                    self:refreshUi()
                                end
                                local params = {}
                                params.sort = self.maptype.maptype
                                params.pos_id = self.targetPos
                                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_go_fight"), http_request_method.GET, params,"wormholes_go_fight")
                            end,   --可缺省
                            cancelBtnCallBack = function(target,event)
                                game_util:closeAlertView();
                            end,
                            okBtnText = "Xác nhận",       --可缺省
                            cancelBtnText = "Hủy",
                            onlyOneBtn = false,
                            text ="Mục tiêu không có ai, có Chiếm Lĩnh không?",      --可缺省
                            touchPriority = GLOBAL_TOUCH_PRIORITY-12,
                        }
                        game_util:openAlertView(t_params);
                        return
                    end
                    if next(data.user_info) then
                        if self.m_mapdata[v.num].sp:getChildByTag(101) == nil or data.user_info.uid ~= self.targetEnemydata.uid then --如果数据不一致
                            if self.selActionsp then  --先移除掉之前的
                                cclog("remove = ===========")
                                self.selActionsp:stopActionByTag(100)
                                local parent = self.selActionsp:getParent()
                                parent:removeAllChildrenWithCleanup(true)
                                self.selActionsp = nil
                            end
                            local newbg = CCSprite:createWithSpriteFrameName("ui_wormhole_map_icon_high_"..v.weight..".png")
                            self.m_mapdata[v.num].sp:addChild(newbg)
                            newbg:setPosition(ccp(self.m_mapdata[v.num].sp:getContentSize().width*0.5,self.m_mapdata[v.num].sp:getContentSize().height*0.5))
                            newbg:setTag(101)

                            local icon = nil
                            if data.user_info.server == "TINYBOSS" then
                                -- icon = CCSprite:createWithSpriteFrameName("ui_wormhole_map_icon_smallboss.png")
                            else
                                icon = game_util:createPlayerRoleGardenIconByRoleId(data.user_info.role or 1)
                                icon:setScale(0.7)
                                self.m_mapdata[v.num].sp:addChild(icon)
                                icon:setOpacity(0)
                                icon:setPosition(ccp(self.m_mapdata[v.num].sp:getContentSize().width*0.5,self.m_mapdata[v.num].sp:getContentSize().height*0.5))
                                local function lastFunc(node)
                                    self.targetEnemydata = nil
                                    self.selActionsp = nil
                                    self.m_mapdata[v.num].sp:removeAllChildrenWithCleanup(true)
                                    self.m_lb_right_name     :setString("------")
                                    self.m_lb_right_area     :setString("------")
                                    self.m_lb_right_level    :setString("------")
                                    self.m_lb_right_combats  :setString("------")
                                    self.m_lb_right_union    :setString("------")
                                end
                                local animArr = CCArray:create()
                                animArr:addObject(CCFadeIn:create(2))
                                animArr:addObject(CCDelayTime:create(10))
                                animArr:addObject(CCFadeOut:create(2))
                                animArr:addObject(CCCallFuncN:create(lastFunc))
                                local seqact = CCSequence:create(animArr)
                                seqact:setTag(1001)
                                icon:runAction(seqact)
                                self.selActionsp = icon
                            end
                            self.m_lb_right_name     :setString(data.user_info.name   or "" )
                            if data.user_info.server == "TINYBOSS" then
                                self.m_lb_right_area     :setString("------")
                                self.m_lb_right_level    :setString("------")
                                self.m_lb_right_combats  :setString("------")
                                self.m_lb_right_union    :setString("------")
                            else
                                self.m_lb_right_area     :setString(data.user_info.server or "" )
                                self.m_lb_right_level    :setString(data.user_info.level  or "" )
                                self.m_lb_right_combats  :setString(data.user_info.combat or "" )
                                self.m_lb_right_union    :setString(data.user_info.guild ~= "" and data.user_info.guild  or "Không" )
                            end
                        -- else
                            -- cclog(" repeate  click")
                        end
                        self.targetEnemydata = data.user_info
                    else
                        if self.selActionsp then  --先移除掉之前的
                            cclog("remove = ===========")
                            self.selActionsp:stopActionByTag(100)
                            local parent = self.selActionsp:getParent()
                            parent:removeAllChildrenWithCleanup(true)
                            self.selActionsp = nil
                        end

                        -- 直接显示空
                        self.targetEnemydata = {}
                        local newbg = CCSprite:createWithSpriteFrameName("ui_wormhole_map_icon_low_"..v.weight..".png")
                        self.m_mapdata[v.num].sp:addChild(newbg)
                        newbg:setPosition(ccp(self.m_mapdata[v.num].sp:getContentSize().width*0.5,self.m_mapdata[v.num].sp:getContentSize().height*0.5))
                        newbg:setTag(101)

                        local function lastFunc(node)
                            self.targetEnemydata = nil
                            self.selActionsp = nil
                            self.m_mapdata[v.num].sp:removeAllChildrenWithCleanup(true)
                            self.m_lb_right_name     :setString("------")
                            self.m_lb_right_area     :setString("------")
                            self.m_lb_right_level    :setString("------")
                            self.m_lb_right_combats  :setString("------")
                            self.m_lb_right_union    :setString("------")
                        end
                        local animArr = CCArray:create()
                        animArr:addObject(CCDelayTime:create(10))
                        animArr:addObject(CCCallFuncN:create(lastFunc))
                        local seqact = CCSequence:create(animArr)
                        seqact:setTag(1001)
                        newbg:runAction(seqact)
                        self.selActionsp = newbg
                    end
                    -- game_scene:enterGameUi("game_wormhole_main",{gameData = data});
                end
                local params = {}
                params.sort = self.maptype.maptype
                params.pos_id = v.x.."-"..v.y
                self.targetPos = v.x.."-"..v.y
                cclog("wormholes_get_user_info  ==>>>>   ",params.sort,params.pos_id)
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_get_user_info"), http_request_method.GET, params,"wormholes_get_user_info")
            end
        end
    end
    -- cclog("fun game_wormhole_map:onTouchBegan--------->>   ",realpos.x,realpos.y)
end

--[[--
    刷新ui
]]
function game_wormhole_map.refreshUi(self)
    -- self.maptype
    self.m_sp_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(toptitle[self.maptype.id]));

    self.m_lb_right_name     :setString(self.m_sel_enemy and "+" or "------")
    self.m_lb_right_area     :setString(self.m_sel_enemy and "+" or "------")
    self.m_lb_right_level    :setString(self.m_sel_enemy and "+" or "------")
    self.m_lb_right_combats  :setString(self.m_sel_enemy and "+" or "------")
    self.m_lb_right_union    :setString(self.m_sel_enemy and "+" or "------")
    self.m_lb_times          :setString("Số lần chiến đấu: "..self.m_Gamedata.remain_times.."/"..self.m_colosseum_limited_cfg:getNodeWithKey(self.maptype.maptype):getNodeWithKey("limited_time"):toStr())  
    self.m_lb_recards        :setString("Điểm của tôi: "..self.m_Gamedata.own_score)  

    local scview = self.m_scroll_map:getViewSize()
    local iconsize = 0
    -- self.scnode = self.m_scroll_map:getContainer():getChildByTag(99)
    if self.scnode then
        -- scnode:removeAllChildrenWithCleanup(true)
    else
        local sp = CCSprite:createWithSpriteFrameName("ui_wormhole_map_icon_block.png")
        iconsize = sp:getContentSize().width
        ICONSIZE = iconsize
        self.scnode = CCNode:create()
        self.scnode:setContentSize(CCSizeMake(iconsize*(MAXLEN+8), iconsize*(MAXLEN+6)))
        self.m_scroll_map:getContainer():addChild(self.scnode)
        self.m_scroll_map:getContainer():setContentSize(self.scnode:getContentSize())
        self.scnode:setPosition(ccp(0,0))
        self.scnode:setTag(99999)
    end
    --[[]]
    if self.m_mapdata[1].sp then
    else
        self.bigbossPos = {}
        for k,v in pairs(self.m_mapdata) do
            local sp = nil

            if v.weight == 7 then
                sp = CCSprite:createWithSpriteFrameName("ui_wormhole_map_icon_low_7.png")
            elseif v.weight >1 then
                sp = CCSprite:createWithSpriteFrameName("ui_wormhole_map_icon_low_"..v.weight..".png")
            elseif v.weight == 1 then
                sp = CCSprite:createWithSpriteFrameName("ui_wormhole_map_icon_ready.png")
            else
                sp = CCSprite:createWithSpriteFrameName("ui_wormhole_map_icon_block.png")
            end
            self.scnode:addChild(sp)
            self.m_mapdata[k].sp = sp

            sp:setAnchorPoint(ccp(0.5,0.5))
            local offsetx = v.x*iconsize  + iconsize*3.5
            local offsety = v.y*iconsize  + iconsize*2.5

            self.m_mapdata[k].offsetx = offsetx
            self.m_mapdata[k].offsety = offsety
            sp:setPosition(ccp(offsetx,offsety))

            if v.weight == 7 then
                self.bigbossPos.x = sp:getPositionX() 
                self.bigbossPos.y = sp:getPositionY() 
            end
        end
        -- bigboss
        local bigbosssp = CCSprite:createWithSpriteFrameName("ui_wormhole_map_icon_bigboss1.png")
        self.scnode:addChild(bigbosssp)
        bigbosssp:setAnchorPoint(ccp(0.5,0.5))
        bigbosssp:setPosition(ccp(self.bigbossPos.x,self.bigbossPos.y))
    end

    for k,v in pairs(self.m_tinyboss) do
        local tinysp = self.scnode:getChildByTag(2000+tonumber(k))
        if tinysp then
            tinysp:removeFromParentAndCleanup(true)
        end
        tinysp = CCSprite:createWithSpriteFrameName("ui_wormhole_map_icon_smallboss.png")
        self.scnode:addChild(tinysp)
        local tinynum = ( v.x -1 ) * MAXLEN + v.y
        tinysp:setAnchorPoint(ccp(0.5,0.5))
        tinysp:setPosition(self.m_mapdata[tinynum].sp:getPosition())
        tinysp:setTag(2000+tonumber(k))
        self.m_tinyboss[k].sp = tinysp
    end


    local mysp = self.scnode:getChildByTag(999)
    local flag1st = true
    if mysp then
        flag1st = false
        mysp:removeFromParentAndCleanup(true)
    end
    mysp = CCSprite:createWithSpriteFrameName("ui_wormhole_map_icon_self.png")
    self.scnode:addChild(mysp)
    local myposnum = ( self.selfpos.x -1 ) * MAXLEN + self.selfpos.y
    mysp:setAnchorPoint(ccp(0.5,0.5))
    mysp:setPosition(self.m_mapdata[myposnum].sp:getPosition())
    mysp:setTag(999)

    local offsetx = (self.m_mapdata[myposnum].offsetx - 3.8*iconsize)*-1
    local offsety = (self.m_mapdata[myposnum].offsety - 2.65*iconsize)*-1
    if flag1st then
        self.m_scroll_map:setContentOffset(ccp(offsetx,offsety),false)
    end

    self.targetEnemy = {}
    self.targetEnemy[1] = { x = self.selfpos.x - 1 , y = self.selfpos.y     , weight = 0} -- 离
    self.targetEnemy[2] = { x = self.selfpos.x - 1 , y = self.selfpos.y + 1 , weight = 0} -- 兑
    self.targetEnemy[3] = { x = self.selfpos.x     , y = self.selfpos.y + 1 , weight = 0} -- 乾
    self.targetEnemy[4] = { x = self.selfpos.x + 1 , y = self.selfpos.y + 1 , weight = 0} -- 巽
    self.targetEnemy[5] = { x = self.selfpos.x + 1 , y = self.selfpos.y     , weight = 0} -- 坎
    self.targetEnemy[6] = { x = self.selfpos.x + 1 , y = self.selfpos.y - 1 , weight = 0} -- 艮
    self.targetEnemy[7] = { x = self.selfpos.x     , y = self.selfpos.y - 1 , weight = 0} -- 坤
    self.targetEnemy[8] = { x = self.selfpos.x - 1 , y = self.selfpos.y - 1 , weight = 0} -- 震

    for k,v in pairs(self.targetEnemy) do
        if v.x <= 1  or v.x >= 13 or v.y <= 1  or v.y >= 13 then
            self.targetEnemy[k].num = 0
        else
            self.targetEnemy[k].num =  (v.x - 1 ) * MAXLEN + v.y
            self.targetEnemy[k].weight = self.m_mapdata[self.targetEnemy[k].num].weight
            if self.m_mapdata[self.targetEnemy[k].num].weight == 0 then
                self.targetEnemy[k].num = 0
                self.targetEnemy[k].weight = 0
            end
        end
    end
end
--[[--
    初始化
]]
function game_wormhole_map.init(self,t_params)
    self.maptype = t_params.maptype
    t_params = t_params.gameData or {};
    self.m_times_cost = t_params.need_coin

    self.m_Gamedata = t_params
    self.selfpos = {}
    self.selfpos.x = tonumber(string.sub(self.m_Gamedata.pos,0,string.find(self.m_Gamedata.pos,"-")-1))
    self.selfpos.y = tonumber(string.sub(self.m_Gamedata.pos,string.find(self.m_Gamedata.pos,"-")+1,-1))

    self.m_map_cfg = json.decode(getConfig(game_config_field.colosseum_mp):getFormatBuffer())
    self.m_colosseum_limited_cfg = getConfig(game_config_field.colosseum_limited)
    
    self.m_mapdata = {}

    local maptype = self.m_colosseum_limited_cfg:getNodeWithKey(self.maptype.maptype):getNodeWithKey("map_sort"):toInt()
    local list_id = 0
    for k,v in pairs(self.m_map_cfg) do
        if v.sort == maptype then
            list_id = tonumber(v.list_id)
            for kc,vc in pairs(v) do
                if kc ~= "list_id" and kc ~= "sort" and kc ~= "id" then
                    local max = MAXLEN
                    local x = list_id
                    -- if x == 0 then x = max end
                    local y = tonumber(string.sub(kc,7,-1))
                    local weight = 0 -- 不可用
                    if (x == 1 and y>0 and y<(max +1)) or (x == (max ) and y>0 and y<(max +1)) or
                        (y == 1 and x>0 and x<(max +1)) or (y == (max ) and x>0 and x<(max+1)) then
                        weight = 1
                    elseif (x == 2 and y>1 and y<(max - 0)) or (x == (max - 1) and y>1 and y<(max - 0)) or
                        (y == 2 and x>1 and x<(max - 0)) or (y == (max - 1) and x>1 and x<(max - 0)) then
                        weight = 2
                    elseif (x == 3 and y>2 and y<(max - 1)) or (x == (max - 2) and y>2 and y<(max - 1)) or
                        (y == 3 and x>2 and x<(max - 1)) or (y == (max - 2) and x>2 and x<(max - 1)) then
                        weight = 3
                    elseif (x == 4 and y>3 and y<(max - 2)) or (x == (max - 3) and y>3 and y<(max - 2)) or
                        (y == 4 and x>3 and x<(max - 2)) or (y == (max - 3) and x>3 and x<(max - 2)) then
                        weight = 4
                    elseif (x == 5 and y>4 and y<(max - 3)) or (x == (max - 4) and y>4 and y<(max - 3)) or
                        (y == 5 and x>4 and x<(max - 3)) or (y == (max - 4) and x>4 and x<(max - 3)) then
                        weight = 5
                    elseif (x == 6 and y>5 and y<(max - 4)) or (x == (max - 5) and y>5 and y<(max - 4)) or
                        (y == 6 and x>5 and x<(max - 4)) or (y == (max - 5) and x>5 and x<(max - 4)) then
                        weight = 6
                    else
                        weight = 7
                    end
                    if vc[1] == 2 then
                        weight = 0
                    end
                    self.m_mapdata[#self.m_mapdata+1] = {x = x , y = y,weight = weight,num =((x-1)*13+y) }
                end
            end
        end
    end
    table.sort( self.m_mapdata, function(a,b)
        return a.num<b.num
    end )

    self.m_tinyboss = t_params.all_tiny_boss
    for k,v in pairs(self.m_tinyboss) do
        self.m_tinyboss[k] = {}
        self.m_tinyboss[k].id = v
        self.m_tinyboss[k].x = tonumber(string.sub(v,0,string.find(v,"-")-1))
        self.m_tinyboss[k].y = tonumber(string.sub(v,string.find(v,"-")+1,-1))
    end
end
---  ui_wormhole_map_icon_smallboss.png
--[[--
    创建ui入口并初始化数据
]]
function game_wormhole_map.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_wormhole_map;