---  组队战斗预备界面

local ui_teamTask_readyScene = {
    m_root_layer = nil,
    m_battle_btn_bg = nil,
    m_ccbNode = nil,

    m_btn_fight = nil,
    m_btn_porp = nil,
    m_btn_equip = nil,
    m_btn_invite = nil,
    m_btn_refresh = nil,
    m_btn_autoEmbattle = nil,

    m_sp_face = nil,
    m_label_level = nil,
    m_label_name = nil,
    m_label_combat = nil,
    m_label_refresh = nil,

    m_sptab_porpon = nil,
    m_sptab_porpclose = nil,
    m_sptab_equipon = nil,
    m_sptab_equipclose = nil,

    m_sp_teampos = {}, -- 左侧队伍背景图sp
    m_teampos = {}, -- 左侧队伍背景图坐标
    m_teampostag = {}, -- 左侧队伍标记
    -- m_waitpos = {}, -- 右侧候选坐标

    m_scroll_porp = nil, --属性scroll
    m_scroll_equip = nil,--装备scroll

    m_porp_node = nil,
    m_equip_node = nil,


    m_sel_card = nil, --选中的card信息
    m_sel_cardid = nil, --选中的cardid
    m_sel_cardteamid = nil,
    m_sel_heropos = nil, --拖动中的sp
    m_sel_tab = nil, 
    m_cardData = {}, --所有的数据
    m_waitdata = {}, --候选
    m_teamdata = {}, -- 已选数据 

    m_hero_splist = {}, --待选sp
    -- m_hero_splist_inteam = {}, --已配置sp

    cardwidth = nil,
    m_layer_left = nil,
    m_isdragging = false,

    m_life_label = nil,
    m_physical_atk_label = nil,
    m_magic_atk_label = nil,
    m_def_label = nil,
    m_speed_label = nil,
    m_fire_label = nil,
    m_water_label = nil,
    m_wind_label = nil,
    m_earth_label = nil,
    m_fire_dfs_label = nil,
    m_water_dfs_label = nil,
    m_wind_dfs_label = nil,
    m_earth_dfs_label = nil,
    m_life_label2 = nil,
    m_physical_atk_label2 = nil,
    m_magic_atk_label2 = nil,
    m_def_label2 = nil,
    m_speed_label2 = nil,
    m_fire_label2 = nil,
    m_water_label2 = nil,
    m_wind_label2 = nil,
    m_earth_label2 = nil,
    m_fire_dfs_label2 = nil,
    m_water_dfs_label2 = nil,
    m_wind_dfs_label2 = nil,
    m_earth_dfs_label2 = nil,

    m_equip={},
    m_gem={},
    m_magic={},
    m_ming = {},

    m_teamid = nil,

    m_shared = nil,
    m_selfticknum = nil,
    m_isfirst = true,
    m_pos_node = {},
};

--[[--
    销毁
]]
function ui_teamTask_readyScene.destroy(self)
    -- body
    cclog("-----------------ui_teamTask_readyScene destroy-----------------");
    self.m_root_layer = nil;

    self.m_battle_btn_bg = nil;
    self.m_ccbNode = nil;

    self.m_btn_fight = nil;
    self.m_btn_porp = nil;
    self.m_btn_equip = nil;
    self.m_btn_invite = nil;
    self.m_btn_refresh = nil;
    self.m_btn_autoEmbattle = nil;

    self.m_sp_face = nil;
    self.m_label_level = nil;
    self.m_label_name = nil;
    self.m_label_combat = nil;
    self.m_label_refresh = nil;
    self.m_sptab_porpon = nil;
    self.m_sptab_porpclose = nil;
    self.m_sptab_equipon = nil;
    self.m_sptab_equipclose = nil;

    self.m_sp_teampos = nil;
    self.m_teampos = nil;
    self.m_teampostag = nil;
    -- self.m_waitpos = nil;


    self.m_scroll_porp = nil;
    self.m_scroll_equip = nil;

    self.m_porp_node = nil;
    self.m_equip_node = nil;
    

    self.m_sel_card = nil;
    self.m_sel_cardid = nil;
    self.m_sel_cardteamid = nil;
    self.m_sel_heropos = nil;
    self.m_sel_tab = nil;
    self.m_cardData = nil;
    self.m_waitdata = nil; --候选
    self.m_teamdata = nil;

    self.m_hero_splist = nil;
    self.m_layer_left = nil;

    self.cardwidth =nil;
    self.m_isdragging = nil;

    --属性
    self.m_life_label = nil;
    self.m_physical_atk_label = nil;
    self.m_magic_atk_label = nil;
    self.m_def_label = nil;
    self.m_speed_label = nil;
    self.m_fire_label = nil;
    self.m_water_label = nil;
    self.m_wind_label = nil;
    self.m_earth_label = nil;
    self.m_fire_dfs_label = nil;
    self.m_water_dfs_label = nil;
    self.m_wind_dfs_label = nil;
    self.m_earth_dfs_label = nil;
    self.m_life_label2 = nil;
    self.m_physical_atk_label2 = nil;
    self.m_magic_atk_label2 = nil;
    self.m_def_label2 = nil;
    self.m_speed_label2 = nil;
    self.m_fire_label2 = nil;
    self.m_water_label2 = nil;
    self.m_wind_label2 = nil;
    self.m_earth_label2 = nil;
    self.m_fire_dfs_label2 = nil;
    self.m_water_dfs_label2 = nil;
    self.m_wind_dfs_label2 = nil;
    self.m_earth_dfs_label2 = nil;

    self.m_equip=nil;
    self.m_gem=nil;
    self.m_magic=nil;
    self.m_ming = nil;

    self.m_teamid =nil;
    self.m_shared = nil;
    self.m_selfticknum = nil;

    self.m_isfirst = nil;
    self.m_pos_node = nil;
end


--[[--
    返回
]]
function ui_teamTask_readyScene.back(self,type)
    if self.m_shared then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
        self.m_shared = nil
    end
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        game_scene:enterGameUi("game_TeamTask_main",{gameData = data})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_index"), http_request_method.GET, nil,"team_fight_index")
end


--[[--
    读取ccbi创建ui
]]
function ui_teamTask_readyScene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 11 then --属性
            self.m_sel_tab = 1
            self:refreshUi()
            self.m_btn_porp:setEnabled(self.m_sel_tab ~= 1)
            self.m_btn_equip:setEnabled(self.m_sel_tab ~= 2)
        elseif btnTag == 12 then --装备
            self.m_sel_tab = 2
            self:refreshUi()
            self.m_btn_porp:setEnabled(self.m_sel_tab ~= 1)
            self.m_btn_equip:setEnabled(self.m_sel_tab ~= 2)
        elseif btnTag == 21 then --一键布阵
            self.m_waitdata = {}
            self.m_teamdata = {}
            self.m_teampostag = {}
            for i=1,6 do
                self.m_teampostag[i] = "0"
            end
            for k,v in pairs(self.m_cardData) do
                self.m_teamdata[k]=v 
                self.m_teamdata[k]["teamid"] = tonumber(k)
                self.m_teampostag[tonumber(k)] = tostring(k)
            end
            self.m_sel_card = self.m_sel_card or self.m_teamdata["1"]
            self.m_sel_cardid = 1

            self:liezhen()
            self:refreshUi();
        elseif btnTag == 22 then --邀请
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                data = json.decode(data:getFormatBuffer())

                -- game_util:addMoveTips({text = "成功发送邀请"})
                self.m_teamid = self.m_teamid
                game_scene:addPop("ui_teamTask_invite_pop", {gameData = gameData,teamid = self.m_teamid})
            end
            local params = {};
            params.team_id = self.m_teamid
            -- http://203.86.67.226/genesis/api/?method=team_fight.invit_friend_index&user_token=h16505562
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_invit_friend_index"), http_request_method.GET, params,"team_fight_invit_friend_index")
        elseif btnTag == 23 then --刷新
            self:doRefresh()
        elseif btnTag == 999 then --出战
            if next(self.m_waitdata) then
                game_util:addMoveTips({text = "Cử người ra trận"})
                return
            end
            local readyStr = ""
            local num = 1
            for k,v in pairs(self.m_teampostag) do
                if v~="0" then
                    if readyStr == "" then
                        readyStr = readyStr .. self.m_cardData[v].conid
                    else
                        readyStr = readyStr .."_".. self.m_cardData[v].conid
                    end
                else
                    if readyStr == "" and  num == 1  then
                        if num == 1 then
                            readyStr = readyStr 
                            num = num+1
                        end
                    else
                        if num == 1 then
                            readyStr = readyStr
                            num = num+1
                        else
                            if num == 2 and readyStr == "" then
                                readyStr = readyStr .."-1"
                                num = num+1
                            else
                                readyStr = readyStr .."_-1"
                            end
                        end
                    end
                end
            end
            
            local function responseMethod(tag,gameData)
                if self.m_shared then
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
                    self.m_shared = nil
                end
                game_data:setBattleType("teamTask");
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData,backGroundName = "zuduichangjing"});
            end
            local params = {};
            if self.m_teamid == nil then
                cclog(" teamid = nil ")
                return
            end
            params.team_id = self.m_teamid
            params.align_1 = readyStr
            cclog(" teamid =  "  ..params.align_1)
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_battle"), http_request_method.GET, params,"team_fight_battle")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_teamTask_readyScene.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    self.m_battle_btn_bg = ccbNode:spriteForName("m_battle_btn_bg")
    local animArr = CCArray:create();
    animArr:addObject(CCScaleTo:create(1,0.9));
    animArr:addObject(CCScaleTo:create(1,1.0));
    self.m_battle_btn_bg:runAction(CCRepeatForever:create(CCSequence:create(animArr)))

    self.m_btn_fight = ccbNode:controlButtonForName("m_battle_btn")
    self.m_btn_porp = ccbNode:controlButtonForName("m_btntab_porp")
    self.m_btn_equip = ccbNode:controlButtonForName("m_btntab_equip")
    self.m_btn_porp:setOpacity(0)
    self.m_btn_equip:setOpacity(0)
    self.m_btn_invite = ccbNode:controlButtonForName("m_btn_invite")
    self.m_btn_refresh = ccbNode:controlButtonForName("m_btn_refresh")
    self.m_btn_refresh:setVisible(true)
    self.m_btn_autoEmbattle = ccbNode:controlButtonForName("m_btn_autoEmbattle")

    self.m_btn_fight:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    self.m_btn_porp:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    self.m_btn_equip:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    self.m_btn_invite:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    self.m_btn_refresh:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    self.m_btn_autoEmbattle:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)

    self.m_sp_face = ccbNode:spriteForName("m_sp_face")
    self.m_label_level = ccbNode:labelTTFForName("m_label_lv")
    self.m_label_name = ccbNode:labelTTFForName("m_label_name")
    self.m_label_combat = ccbNode:labelBMFontForName("m_combat_label")
    self.m_label_refresh = ccbNode:labelTTFForName("m_label_refresh")
    self.m_sptab_porpon = ccbNode:spriteForName("m_sptab_porpon")
    self.m_sptab_porpclose = ccbNode:spriteForName("m_sptab_porpclose")
    self.m_sptab_equipon = ccbNode:spriteForName("m_sptab_equipon")
    self.m_sptab_equipclose = ccbNode:spriteForName("m_sptab_equipclose")

    self.m_sp_teampos = {}
    self.m_sp_teampos[1] = ccbNode:spriteForName("m_pos_1")
    self.m_sp_teampos[2] = ccbNode:spriteForName("m_pos_2")
    self.m_sp_teampos[3] = ccbNode:spriteForName("m_pos_3")
    self.m_sp_teampos[4] = ccbNode:spriteForName("m_pos_4")
    self.m_sp_teampos[5] = ccbNode:spriteForName("m_pos_5")
    self.m_sp_teampos[6] = ccbNode:spriteForName("m_pos_6")

    self.m_pos_node = {}
    self.m_teampostag = {}
    self.m_teampos = {}
    for i=1,6 do
        self.m_pos_node[i] = ccbNode:nodeForName("m_pos_node_"..i) 

        self.m_teampostag[i] = "0"
    end

    self.m_scroll_porp = ccbNode:scrollViewForName("m_scroll_porp")
    self.m_scroll_equip = ccbNode:scrollViewForName("m_scroll_equip")

    local porpCcbNode = self:createPorpUI()
    self.m_scroll_porp:addChild(porpCcbNode)
    local equipCcbNode = self:createEquipUI()
    self.m_scroll_equip:addChild(equipCcbNode)

    self.m_layer_left = ccbNode:layerForName("m_layer_left")
    for k,v in pairs(self.m_sp_teampos) do
        local x1 = v:convertToWorldSpace(ccp(0,0)).x +10
        local x2 = x1 + v:getContentSize().width -10
        local y1 = v:convertToWorldSpace(ccp(0,0)).y +10
        local y2 = y1 + v:getContentSize().height -10
        local w  = v:getContentSize().width
        local h  = v:getContentSize().height
        self.m_teampos[k] = {x1 = x1 ,x2 = x2 ,y1 = y1 ,y2 = y2 ,id = k,w=w,h=h }
    end


    local offsetX = nil
    local offsetY = nil
    -- local beganTime = nil
    local function onTouchBegan(x, y)
        offsetX = nil
        offsetY = nil

        local heropos = {}
        for k,v in pairs(self.m_hero_splist) do
            local pos = {x1=0,x2=0,y1=0,y2=0}
            pos.x1 = v:convertToWorldSpace(ccp(0,0)).x
            pos.x2 = pos.x1 + v:getContentSize().width
            pos.y1 = v:convertToWorldSpace(ccp(0,0)).y
            pos.y2 = pos.y1 + v:getContentSize().height
            pos.id = k
            heropos[k..""] = pos
        end

        self.m_sel_heropos = nil
        for k,v in pairs(heropos) do
            if v.x1 < x and v.x2 > x and v.y1 < y  and v.y2 > y  then
                self.m_sel_card = self.m_cardData[v.id]
                self.m_sel_cardid = v.id
                self.m_sel_heropos = v
                offsetX = x-v.x1
                offsetY = y-v.y1
                cclog("choose   num  "..v.id)
                self.m_isdragging = true
                self.m_hero_splist[self.m_sel_heropos.id]:setVisible(true)
                self:refreshUi()
                return true
            end
        end

        return false
    end

    local function onTouchMoved(x, y)
        if self.m_sel_heropos then
            local pos = self.m_layer_left:convertToNodeSpace(ccp(x-offsetX,y-offsetY))
            self.m_hero_splist[self.m_sel_heropos.id]:setPosition(pos)
        end
    end

    local function onTouchEnded(x, y)
        self.m_isdragging = false
        if self.m_sel_heropos then
            for k,v in pairs(self.m_teampos) do
                if v.x1 < x and v.x2 > x  and  v.y1 < y  and v.y2 > y then --存在目标
                    -- for k1,v1 in pairs(self.m_teamdata) do
                        -- cclog("    $$$$$$$$$$      @@@@@@@@@@@  "..v1.teamid)
                        if self.m_sel_card.teamid == nil and  self.m_teampostag[tonumber(k)] == "0" then
                            -- 从待选拿出来 松手在空阵型
                            self.m_teamdata[self.m_sel_cardid..""] = self.m_sel_card
                            self.m_teamdata[self.m_sel_cardid..""]["teamid"]  = k..""
                            self.m_waitdata[self.m_sel_cardid..""] = nil
                            self.m_teampostag[tonumber(k)] = self.m_sel_cardid
                            local pos = self.m_layer_left:convertToNodeSpace(ccp(v.x1+v.w/10 , v.y1 + v.h/10 ))
                            self.m_hero_splist[self.m_sel_heropos.id]:setPosition(pos)
                            self.m_hero_splist[self.m_sel_heropos.id]:setVisible(false)
                            self:refreshUi()
                            return

                        elseif self.m_sel_card.teamid == nil and  self.m_teampostag[tonumber(k)] ~= "0" then
                            -- 从待选拿出来 松手在非空阵型
                            self.m_waitdata[self.m_teampostag[tonumber(k)]..""] = self.m_teamdata[self.m_teampostag[tonumber(k)]..""]
                            self.m_waitdata[self.m_teampostag[tonumber(k)]..""].teamid = nil
                            self.m_teamdata[self.m_teampostag[tonumber(k)]..""] = nil

                            self.m_teamdata[self.m_sel_cardid..""] = self.m_sel_card
                            self.m_teamdata[self.m_sel_cardid..""]["teamid"]  = k..""
                            self.m_waitdata[self.m_sel_cardid..""] = nil
                            self.m_teampostag[tonumber(k)] = self.m_sel_cardid
                            local pos = self.m_layer_left:convertToNodeSpace(ccp(v.x1+v.w/10 , v.y1 + v.h/10 ))
                            self.m_hero_splist[self.m_sel_heropos.id]:setPosition(pos)
                            self.m_hero_splist[self.m_sel_heropos.id]:setVisible(false)

                            self:refreshUi()
                            return
                        elseif self.m_sel_card.teamid ~= nil and  self.m_teampostag[tonumber(k)] == "0" then
                            -- 从阵型拿出来 松手在空阵型
                            self.m_teampostag[tonumber(self.m_teamdata[self.m_sel_cardid..""]["teamid"])] = "0"
                            self.m_teamdata[self.m_sel_cardid..""]["teamid"]  = k
                            self.m_teampostag[tonumber(k)] = self.m_sel_cardid
                            local pos = self.m_layer_left:convertToNodeSpace(ccp(v.x1+v.w/10 , v.y1 + v.h/10 ))
                            self.m_hero_splist[self.m_sel_heropos.id]:setPosition(pos)
                            self.m_hero_splist[self.m_sel_heropos.id]:setVisible(false)

                            self:refreshUi()
                            return

                        elseif self.m_sel_card.teamid ~= nil and  self.m_teampostag[tonumber(k)] ~= "0" and self.m_sel_card.teamid.."" == k.."" then
                            -- 从阵型拿出来 松手在原位置
                            local pos = self.m_layer_left:convertToNodeSpace(ccp(v.x1+v.w/10 , v.y1 + v.h/10 ))
                            self.m_hero_splist[self.m_sel_heropos.id]:setPosition(pos)
                            self.m_hero_splist[self.m_sel_heropos.id]:setVisible(false)

                            self:refreshUi()
                            return
                        elseif self.m_sel_card.teamid ~= nil and  self.m_teampostag[tonumber(k)] ~= "0" and self.m_sel_card.teamid.."" ~= k.."" then
                            -- 从阵型拿出来 松手在其他非空位置
                            local posSeltemp = self.m_teampos[tonumber(self.m_sel_card.teamid)]
                            local posSel = self.m_layer_left:convertToNodeSpace(ccp(posSeltemp.x1+posSeltemp.w/10 , posSeltemp.y1 + posSeltemp.h/10 ))
                            local posTarget = self.m_layer_left:convertToNodeSpace(ccp(v.x1+v.w/10 , v.y1 + v.h/10 ))
                            local idTarget = self.m_teampostag[tonumber(k)]

                            local tempselteamid = self.m_teamdata[self.m_sel_cardid..""]["teamid"]
                            self.m_teamdata[self.m_sel_cardid..""]["teamid"]  = k..""
                            self.m_teamdata[self.m_teampostag[tonumber(k)]..""]["teamid"] = tempselteamid

                            local tempselteampostag = self.m_teampostag[tonumber(tempselteamid)]
                            self.m_teampostag[tonumber(tempselteamid)] = self.m_teampostag[tonumber(k)]..""
                            self.m_teampostag[tonumber(k)] = tempselteampostag

                            self.m_hero_splist[idTarget]:setPosition(posSel)
                            self.m_hero_splist[self.m_sel_heropos.id]:setPosition(posTarget)

                            self.m_hero_splist[idTarget]:setVisible(false)
                            self.m_hero_splist[self.m_sel_heropos.id]:setVisible(false)

                            self:refreshUi()
                            return
                        end

                    return
                end
            end

            -- 剩下的是拖出阵型  不管本身有没有在阵型的
            self.m_teamdata[self.m_sel_cardid..""] = nil
            self.m_sel_card.teamid = nil
            self.m_waitdata[self.m_sel_cardid..""] = self.m_sel_card
            for k,v in pairs(self.m_teampostag) do
                if v.."" == self.m_sel_cardid.."" then
                    self.m_teampostag[k] ="0"
                end
            end
            self:refreshUi()
            return
        end
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
        elseif eventType == "moved" then
            return onTouchMoved(x, y)
        else
            return onTouchEnded(x, y)
        end
    end
    self.m_layer_left:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,false)
    self.m_layer_left:setTouchEnabled(true)

    return ccbNode;
end


function ui_teamTask_readyScene.liezhen(self)
    for k,v in pairs(self.m_sp_teampos) do
        local x1 = v:convertToWorldSpace(ccp(0,0)).x +10
        local x2 = x1 + v:getContentSize().width -10
        local y1 = v:convertToWorldSpace(ccp(0,0)).y +10
        local y2 = y1 + v:getContentSize().height -10
        local w  = v:getContentSize().width
        local h  = v:getContentSize().height
        self.m_teampos[k] = {x1 = x1 ,x2 = x2 ,y1 = y1 ,y2 = y2 ,id = k,w=w,h=h }
    end
    for k,v in pairs(self.m_teampos) do
        local pos = self.m_layer_left:convertToNodeSpace(ccp(v.x1+v.w/10 , v.y1 + v.h/10 ))


        if self.m_hero_splist and self.m_hero_splist[k..""] then
            self.m_hero_splist[k..""]:setPosition(pos)
            self.m_hero_splist[k..""]:setVisible(false)
        end
    end
end

function ui_teamTask_readyScene.createPorpUI(self)

    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_hero_info_item_forteam.ccbi");

    self.m_life_label=ccbNode:labelTTFForName("m_life_label")
    self.m_physical_atk_label=ccbNode:labelTTFForName("m_physical_atk_label")
    self.m_magic_atk_label=ccbNode:labelTTFForName("m_magic_atk_label")
    self.m_def_label=ccbNode:labelTTFForName("m_def_label")
    self.m_speed_label=ccbNode:labelTTFForName("m_speed_label")
    self.m_fire_label=ccbNode:labelTTFForName("m_fire_label")
    self.m_water_label=ccbNode:labelTTFForName("m_water_label")
    self.m_wind_label=ccbNode:labelTTFForName("m_wind_label")
    self.m_earth_label=ccbNode:labelTTFForName("m_earth_label")
    self.m_fire_dfs_label=ccbNode:labelTTFForName("m_fire_dfs_label")
    self.m_water_dfs_label=ccbNode:labelTTFForName("m_water_dfs_label")
    self.m_wind_dfs_label=ccbNode:labelTTFForName("m_wind_dfs_label")
    self.m_earth_dfs_label=ccbNode:labelTTFForName("m_earth_dfs_label")
    self.m_life_label2=ccbNode:labelTTFForName("m_life_label2")
    self.m_physical_atk_label2=ccbNode:labelTTFForName("m_physical_atk_label2")
    self.m_magic_atk_label2=ccbNode:labelTTFForName("m_magic_atk_label2")
    self.m_def_label2=ccbNode:labelTTFForName("m_def_label2")
    self.m_speed_label2=ccbNode:labelTTFForName("m_speed_label2")
    self.m_fire_label2=ccbNode:labelTTFForName("m_fire_label2")
    self.m_water_label2=ccbNode:labelTTFForName("m_water_label2")
    self.m_wind_label2=ccbNode:labelTTFForName("m_wind_label2")
    self.m_earth_label2=ccbNode:labelTTFForName("m_earth_label2")
    self.m_fire_dfs_label2=ccbNode:labelTTFForName("m_fire_dfs_label2")
    self.m_water_dfs_label2=ccbNode:labelTTFForName("m_water_dfs_label2")
    self.m_wind_dfs_label2=ccbNode:labelTTFForName("m_wind_dfs_label2")
    self.m_earth_dfs_label2=ccbNode:labelTTFForName("m_earth_dfs_label2")
    return ccbNode
end



function ui_teamTask_readyScene.createEquipUI(self)

    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_hero_info_item_forteamequip.ccbi");

    self.m_equip = {}
    self.m_gem = {}
    self.m_magic = {}
    self.m_ming = {}
    self.m_ming = {}
    for i=1,4 do
        self.m_equip[i]=ccbNode:spriteForName("m_equip_"..i)
        self.m_gem[i]=ccbNode:spriteForName("m_gem_"..i)
        self.m_magic[i]=ccbNode:spriteForName("m_magic_"..i)
        self.m_ming[i]=ccbNode:spriteForName("m_ming_"..i)
        self.m_ming[i]:setVisible(false)
    end
    return ccbNode

end

--[[
    手动刷新
]]
function ui_teamTask_readyScene.doRefresh(self)
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        data = json.decode(data:getFormatBuffer())
        self:init({gameData = data,team_id = self.m_teamid});
        self:refreshUi();

        self.m_shared = 0
        self.m_selfticknum = 15
        self.m_btn_refresh:setColor(ccc3(100,100,100))
        self.m_btn_refresh:setEnabled(false)
        function tick( dt )
            if self.m_selfticknum < 0 then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
                self.m_shared = nil
                self.m_btn_refresh:setColor(ccc3(255,255,255))
                self.m_btn_refresh:setEnabled(true)

                self.m_label_refresh:setVisible(false)
                -- self.m_label_refresh:setString(num.."s")
            else
                self.m_btn_refresh:setVisible(true)
                self.m_btn_refresh:setColor(ccc3(100,100,100))
                self.m_btn_refresh:setEnabled(false)

                self.m_label_refresh:setVisible(true)
                self.m_label_refresh:setString(self.m_selfticknum.."s")
            end
            self.m_selfticknum = self.m_selfticknum - 1
        end
        self.m_shared = scheduler.schedule(tick, 1, false)
    end

    local params = {};
    params.team_id =  self.m_teamid 
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_team_data"), http_request_method.GET, params,"team_fight_team_data")
end
--[[--
    刷新ui
]]
function ui_teamTask_readyScene.refreshUi(self)
    -- 属性
    self.m_scroll_porp:setVisible(self.m_sel_tab==1)
    self.m_scroll_equip:setVisible(self.m_sel_tab==2)
    self.m_sptab_porpon:setVisible(self.m_sel_tab==2)
    self.m_sptab_porpclose:setVisible(self.m_sel_tab==1)
    self.m_sptab_equipon:setVisible(self.m_sel_tab==1)
    self.m_sptab_equipclose:setVisible(self.m_sel_tab==2)
    self.m_btn_porp:setEnabled(self.m_sel_tab ~= 1)
    self.m_btn_equip:setEnabled(self.m_sel_tab ~= 2)

    self.m_scroll_porp:setContentOffset(ccp(0,-52),true)
    self.m_scroll_equip:setContentOffset(ccp(0,-29),true)

    self.m_life_label:setString(            math.floor(self.m_sel_card.cards_info.hp))
    self.m_physical_atk_label:setString(    math.floor(self.m_sel_card.cards_info.patk))
    self.m_magic_atk_label:setString(       math.floor(self.m_sel_card.cards_info.matk))
    self.m_def_label:setString(             math.floor(self.m_sel_card.cards_info.def))
    self.m_speed_label:setString(           math.floor(self.m_sel_card.cards_info.speed))
    self.m_fire_label:setString(            math.floor(self.m_sel_card.cards_info.fire))
    self.m_water_label:setString(           math.floor(self.m_sel_card.cards_info.water))
    self.m_wind_label:setString(            math.floor(self.m_sel_card.cards_info.wind))
    self.m_earth_label:setString(           math.floor(self.m_sel_card.cards_info.earth))
    self.m_fire_dfs_label:setString(        math.floor(self.m_sel_card.cards_info.fire_dfs))
    self.m_water_dfs_label:setString(       math.floor(self.m_sel_card.cards_info.water_dfs))
    self.m_wind_dfs_label:setString(        math.floor(self.m_sel_card.cards_info.wind_dfs))
    self.m_earth_dfs_label:setString(       math.floor(self.m_sel_card.cards_info.earth_dfs))

    self.m_life_label2:setString("+"..          math.floor(tonumber(self.m_sel_card.cards_info.hp)         )-math.floor(tonumber(self.m_sel_card.cards_info_base.hp)))
    self.m_physical_atk_label2:setString("+"..  math.floor(tonumber(self.m_sel_card.cards_info.patk)       )-math.floor(tonumber(self.m_sel_card.cards_info_base.patk)))
    self.m_magic_atk_label2:setString("+"..     math.floor(tonumber(self.m_sel_card.cards_info.matk)       )-math.floor(tonumber(self.m_sel_card.cards_info_base.matk)))
    self.m_def_label2:setString("+"..           math.floor(tonumber(self.m_sel_card.cards_info.def)        )-math.floor(tonumber(self.m_sel_card.cards_info_base.def)))
    self.m_speed_label2:setString("+"..         math.floor(tonumber(self.m_sel_card.cards_info.speed)      )-math.floor(tonumber(self.m_sel_card.cards_info_base.speed)))
    self.m_fire_label2:setString("+"..          math.floor(tonumber(self.m_sel_card.cards_info.fire)       )-math.floor(tonumber(self.m_sel_card.cards_info_base.fire)))
    self.m_water_label2:setString("+"..         math.floor(tonumber(self.m_sel_card.cards_info.water)      )-math.floor(tonumber(self.m_sel_card.cards_info_base.water)))
    self.m_wind_label2:setString("+"..          math.floor(tonumber(self.m_sel_card.cards_info.wind)       )-math.floor(tonumber(self.m_sel_card.cards_info_base.wind)))
    self.m_earth_label2:setString("+"..         math.floor(tonumber(self.m_sel_card.cards_info.earth)      )-math.floor(tonumber(self.m_sel_card.cards_info_base.earth)))
    self.m_fire_dfs_label2:setString("+"..      math.floor(tonumber(self.m_sel_card.cards_info.fire_dfs)   )-math.floor(tonumber(self.m_sel_card.cards_info_base.fire_dfs)))
    self.m_water_dfs_label2:setString("+"..     math.floor(tonumber(self.m_sel_card.cards_info.water_dfs)  )-math.floor(tonumber(self.m_sel_card.cards_info_base.water_dfs)))
    self.m_wind_dfs_label2:setString("+"..      math.floor(tonumber(self.m_sel_card.cards_info.wind_dfs)   )-math.floor(tonumber(self.m_sel_card.cards_info_base.wind_dfs)))
    self.m_earth_dfs_label2:setString("+"..     math.floor(tonumber(self.m_sel_card.cards_info.earth_dfs)  )-math.floor(tonumber(self.m_sel_card.cards_info_base.earth_dfs)))

    -- 装备
    if self.m_sel_tab == 2 then
        local function onClickequip( event, target  )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();

            local tempdata = {}
            for k,v in pairs(self.m_sel_card.custom_info.equip_info.equip_pos) do
                for k1,v1 in pairs(v) do
                    table.insert(tempdata,v1)
                end
            end

            local suitCfg = json.decode(getConfig(game_config_field.suit):getFormatBuffer())

            local suit = self.m_sel_card.custom_info.equip_info._equip[tempdata[btnTag]..""].suit or 0
            local suittable = {}
            local cursuitcfg = suitCfg[suit..""]
            if cursuitcfg then
                suittable = cursuitcfg.part
            end
            local cidtemp = {}
            for k,v in pairs(self.m_sel_card.custom_info.equip_info._equip) do
                cidtemp[v.c_id..""] = v.suit
            end
            for k,v in pairs(suittable) do
                if cidtemp[v..""] and cidtemp[v..""].."" == suit.."" then
                else
                    suittable[k] = 0
                end
            end

            game_scene:addPop("game_equip_info_pop",{
                                openType  = 12,
                                isnoneBtn = true,
                                suitfromTeam = suit.."",
                                posEquipData = suittable,
                                tGameData = self.m_sel_card.custom_info.equip_info._equip[tempdata[btnTag]..""]});

        end

        for k,v in pairs(self.m_equip) do
            if v:getChildren() then
                v:removeAllChildrenWithCleanup(true)
            end
            if self.m_sel_card.equip[k].c_id and self.m_sel_card.equip[k].c_id ~= "" then
                local icon = game_util:createEquipIconByCid(self.m_sel_card.equip[k].c_id)
                v:addChild(icon)
                icon:setAnchorPoint(ccp(0,0))
                self.m_ming[k]:setVisible(self.m_sel_card.equip[k].bind_card~=nil and self.m_sel_card.equip[k].bind_card~="" )
                local button = game_util:createCCControlButton("public_weapon.png","",onClickequip)
                v:addChild(button)
                button:setPosition(ccp(22,22))
                button:setTag(tonumber(k))
                button:setOpacity(0)
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)

            else
                self.m_ming[k]:setVisible(false)
            end
        end

        local function subStr(str,k)
            local b = string.reverse(str)
            local f = string.find(b, "-")
            if f then
                local len = string.len(str)
                local pos = len - f + 2
                return string.sub(str, pos,len) 
            else
                return str
            end
        end

        local function onClickgem( event, target  )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            local str = subStr(tostring(self.m_sel_card.gem[btnTag]),"-")
            game_scene:addPop("gem_system_info_pop",{tGameData = {count = 1,c_id = str},openType=4});
        end
        for k,v in pairs(self.m_gem) do
            if v:getChildren() then
                v:removeAllChildrenWithCleanup(true)
            end

            if v and v ~= "" then
                local str = subStr(tostring(self.m_sel_card.gem[k]),"-")
                local gemIcon,gemName = game_util:createGemIconByCid(str)
                if gemIcon then
                    v:addChild(gemIcon)
                    gemIcon:setAnchorPoint(ccp(0,0))
                    gemIcon:setPosition(ccp(4,4))
                    local button = game_util:createCCControlButton("public_weapon.png","",onClickgem)
                    v:addChild(button)
                    button:setPosition(ccp(22,22))
                    button:setTag(tonumber(k))
                    button:setOpacity(0)
                    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
                end
            end
        end

        local talisman = getConfig(game_config_field.talisman)
        local function onClicktalisman( event, target  )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();

            local tempdata = {}
            for k,v in pairs(self.m_sel_card.custom_info.talisman_info.talisman_pos) do
                for k1,v1 in pairs(v) do
                    table.insert(tempdata,v1)
                end
            end
            local selSort = 1
            if math.floor((btnTag+1)/2) < 3 then
                selSort = 1
            else
                selSort = 0
            end
            game_scene:addPop("game_magic_info_pop",{
                                isnoneBtn = true,
                                tGameData = self.m_sel_card.custom_info.talisman_info._talisman[tempdata[btnTag]],
                                forging_attr = self.m_sel_card.cards_info.talisman_skill_forging[btnTag],
                                magicType = selSort,});

        end
        for k,v in pairs(self.m_magic) do
            if v:getChildren() then
                v:removeAllChildrenWithCleanup(true)
            end

            if self.m_sel_card.magic[k].c_id and self.m_sel_card.magic[k].c_id ~= "" then
                local magicItemCfg = talisman:getNodeWithKey(tostring(self.m_sel_card.magic[k].c_id))
                local magicIcon = game_util:createMagicIcon(magicItemCfg);
                v:addChild(magicIcon)
                magicIcon:setAnchorPoint(ccp(0,0))
                local button = game_util:createCCControlButton("public_weapon.png","",onClicktalisman)
                v:addChild(button)
                button:setPosition(ccp(22,22))
                button:setTag(tonumber(k))
                button:setOpacity(0)
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
            end
        end
    end

    -- 待选人员
    local waitpos = {}
    for k,v in pairs(self.m_waitdata) do
        table.insert(waitpos , {id = tonumber(k)})
    end
    table.sort( waitpos, function(a,b) return a.id<b.id end )

    for k,v in pairs(waitpos) do
        v["x"] = 190 + (k-1)*self.cardwidth*1.1
        v["y"] = 8
    end

    self.m_hero_splist = self.m_hero_splist or {}
    if self.m_isdragging then
    else
        for k,v in pairs(waitpos) do
            if self.m_hero_splist[v.id..""] and self.m_waitdata[v.id..""] then
                self.m_hero_splist[v.id..""]:setAnchorPoint(ccp(0,0))
                self.m_hero_splist[v.id..""]:setPosition(ccp(v.x,v.y))
                self.m_hero_splist[v.id..""]:setVisible(true)
            elseif self.m_hero_splist[v.id..""] ==nil then
                local charapter = getConfig(game_config_field.character_detail)
                local itemCfg = charapter:getNodeWithKey(self.m_waitdata[v.id..""].cards_info.c_id)
                self.m_hero_splist[v.id..""] = game_util:createCardIconByCfg(itemCfg,self.m_waitdata[v.id..""].cards_info_base)
                self.m_layer_left:addChild(self.m_hero_splist[v.id..""])
                self.m_hero_splist[v.id..""]:setAnchorPoint(ccp(0,0))
                self.m_hero_splist[v.id..""]:setPosition(ccp(v.x,v.y))
                self.m_hero_splist[v.id..""]:setVisible(true)
                self.m_hero_splist[v.id..""]:setScale(0.8)
            end
        end
    end

    -- 在选人员
    local ttb = {}
    for k,v in pairs(self.m_teamdata) do
        ttb[v.teamid..""] = v.cards_info
        ttb[v.teamid..""].s_id = v.s_id
    end

    for k,v in pairs(self.m_pos_node) do
        if ttb[k..""] then
            local bgSprite = v:getChildByTag(tonumber(ttb[k..""].s_id))

            if bgSprite then
                bgSprite:setVisible(true)
            else
                if v:getChildren() then
                    v:removeAllChildrenWithCleanup(true)
                end

                local itemcfg = self:getCfgById(ttb[k..""].c_id)
                local itemdata = ttb[k..""]
                bgSprite = CCSprite:createWithSpriteFrameName("dw_characterBg.png")
                v:addChild(bgSprite)

                local icon = self:createCardAnimByData(itemdata,itemcfg)
                v:addChild(icon)
                icon:setPosition(ccp(0,-33))
                bgSprite:setTag(tonumber(ttb[k..""].s_id))
            end
        else
            if v:getChildren() then
                v:removeAllChildrenWithCleanup(true)
            end
        end

    end
    if self.m_isfirst then
        self.m_shared = 0
        self.m_selfticknum = 15
        self.m_btn_refresh:setVisible(true)
        self.m_btn_refresh:setColor(ccc3(100,100,100))
        self.m_btn_refresh:setEnabled(false)
        function tick( dt )
            if self.m_selfticknum < 0 then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
                self.m_shared = nil
                self.m_btn_refresh:setColor(ccc3(255,255,255))
                self.m_btn_refresh:setEnabled(true)

                self.m_label_refresh:setVisible(false)
                -- self.m_label_refresh:setString(num.."s")
            else
                self.m_btn_refresh:setColor(ccc3(100,100,100))
                self.m_btn_refresh:setEnabled(false)

                self.m_label_refresh:setVisible(true)
                self.m_label_refresh:setString(self.m_selfticknum.."s")
            end
            self.m_selfticknum = self.m_selfticknum - 1
        end
        self.m_shared = scheduler.schedule(tick, 1, false)
        self.m_isfirst = nil
    end

    --头像名字等级战力
    if self.m_sp_face:getChildren() then
        self.m_sp_face:removeAllChildrenWithCleanup(true)
    end
    -- local icon= CCSprite:create(MAIN_ROLE_ICON[tonumber(self.m_sel_card.role)].icon)
    local icon= CCSprite:create(MAIN_ROLE_ICON_R[tonumber(self.m_sel_card.role)].icon)
    self.m_sp_face:addChild(icon)
    if tonumber(self.m_sel_card.role) == 1 then
        icon:setPosition(ccp(self.m_sp_face:getContentSize().width/2-4,self.m_sp_face:getContentSize().height/2+5))
    elseif tonumber(self.m_sel_card.role) == 2 then
        icon:setPosition(ccp(self.m_sp_face:getContentSize().width/2+1,self.m_sp_face:getContentSize().height/2+8))
    elseif tonumber(self.m_sel_card.role) == 3 then
        icon:setPosition(ccp(self.m_sp_face:getContentSize().width/2,self.m_sp_face:getContentSize().height/2+8))
    elseif tonumber(self.m_sel_card.role) == 4 then
        icon:setPosition(ccp(self.m_sp_face:getContentSize().width/2-2,self.m_sp_face:getContentSize().height/2+8))
    elseif tonumber(self.m_sel_card.role) == 5 then
        icon:setPosition(ccp(self.m_sp_face:getContentSize().width/2,self.m_sp_face:getContentSize().height/2+6))
    end
    icon:setScale(0.8)

    self.m_label_name:setString(self.m_sel_card.name)
    self.m_label_level:setString(self.m_sel_card.levle)
    self.m_label_combat:setString(self.m_sel_card.combat)

end


--[[--
    初始化
]]
function ui_teamTask_readyScene.init(self,t_params)
    t_params = t_params or {};
    -- body
    local equip_cfg = getConfig(game_config_field.equip)
    self.m_cardData = {}
    self.m_teamdata = self.m_teamdata or {}
    self.m_waitdata = self.m_waitdata or {}
    local sort = nil
    for k,v in pairs(t_params.gameData.team_info) do
        for k1,v1 in pairs(v) do
            self.m_cardData[tostring(k)] = v1
            self.m_cardData[tostring(k)]["s_id"] = k
            self.m_cardData[tostring(k)]["conid"] = k1

            --装备
            self.m_cardData[tostring(k)]["equip"] = {{c_id="",bind_card=""},{c_id="",bind_card=""},{c_id="",bind_card=""},{c_id="",bind_card=""}}

            for e,ev in pairs(self.m_cardData[tostring(k)].custom_info.equip_info._equip) do
                sort = equip_cfg:getNodeWithKey(ev.c_id..""):getNodeWithKey("sort"):toStr()
                self.m_cardData[tostring(k)]["equip"][tonumber(sort)].c_id=ev.c_id
                self.m_cardData[tostring(k)]["equip"][tonumber(sort)].bind_card=ev.bind_card
            end

            --宝石
            for kgem,vgem in pairs(self.m_cardData[tostring(k)].custom_info.gem_pos) do
                self.m_cardData[tostring(k)]["gem"] = vgem
            end

            --法宝
            self.m_cardData[tostring(k)]["magic"] = {{c_id=""},{c_id=""},{c_id=""},{c_id=""}}

            local talispos = nil
            for ktalisman,vtalisman in pairs(self.m_cardData[tostring(k)].custom_info.talisman_info.talisman_pos) do
                talispos = vtalisman
            end

            for t,tv in pairs(talispos) do
                if tv ~= "" and self.m_cardData[tostring(k)].custom_info.talisman_info._talisman[tv..""] then
                    self.m_cardData[tostring(k)]["magic"][t].c_id = self.m_cardData[tostring(k)].custom_info.talisman_info._talisman[tv].c_id
                end
            end

            if self.m_waitdata[tostring(k)] == nil and self.m_teamdata[tostring(k)] == nil then
                self.m_waitdata[tostring(k)] = v1
                self.m_waitdata[tostring(k)]["s_id"] = k

                self.m_cardData[tostring(k)]["equip"] = {{c_id="",bind_card=""},{c_id="",bind_card=""},{c_id="",bind_card=""},{c_id="",bind_card=""}}

                for e,ev in pairs(self.m_cardData[tostring(k)].custom_info.equip_info._equip) do
                    sort = equip_cfg:getNodeWithKey(ev.c_id..""):getNodeWithKey("sort"):toStr()
                    self.m_cardData[tostring(k)]["equip"][tonumber(sort)].c_id=ev.c_id
                    self.m_cardData[tostring(k)]["equip"][tonumber(sort)].bind_card=ev.bind_card
                end

                --宝石
                for kgem,vgem in pairs(self.m_cardData[tostring(k)].custom_info.gem_pos) do
                    self.m_cardData[tostring(k)]["gem"] = vgem
                end

                --法宝
                self.m_cardData[tostring(k)]["magic"] = {{c_id=""},{c_id=""},{c_id=""},{c_id=""}}

                local talispos1 = nil
                for kmagic,vmagic in pairs(self.m_cardData[tostring(k)].custom_info.talisman_info.talisman_pos) do
                    talispos1 = vmagic
                end
                for t1,tv1 in pairs(talispos1) do
                    if tv1 ~= ""  and self.m_cardData[tostring(k)].custom_info.talisman_info._talisman[tv1..""] then
                        self.m_cardData[tostring(k)]["magic"][t1].c_id = self.m_cardData[tostring(k)].custom_info.talisman_info._talisman[tv1].c_id
                    end
                end

                self.m_waitdata[tostring(k)]["attacker_info"] = nil
            end
            self.m_cardData[tostring(k)]["attacker_info"] = nil
        end
    end

    self.m_sel_card = self.m_sel_card or self.m_waitdata["1"]
    self.cardwidth = self.cardwidth or game_util:createCardIconByCid(self.m_sel_card.cards_info.c_id):getContentSize().width*0.8
    self.m_sel_tab = self.m_sel_tab or 1
    self.m_teamid = t_params.team_id or t_params.gameData.team_id

end

function ui_teamTask_readyScene.getCfgById(self,c_id)
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(c_id));
    local skinHeroCfg = heroCfg
    if heroCfg:getNodeWithKey("is_skin") then
        if heroCfg:getNodeWithKey("is_skin"):toInt() ~= 0 then
            local skinID = heroCfg:getNodeWithKey("is_skin"):toInt()
            local flag = game_util:isWearSkin(skinID)
            if flag then
                skinHeroCfg = character_detail_cfg:getNodeWithKey(tostring(skinID));
            end
        end
    end
    return skinHeroCfg
end

function ui_teamTask_readyScene.createCardAnimByData( self, heroData,heroCfg,animFlag)
    local animNode = nil;
    local character_ID = -1;
    if heroData and heroCfg then
        character_ID = heroCfg:getNodeWithKey("character_ID"):toInt();
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        animFlag = animFlag == nil and true or animFlag
        if animFlag then
            animNode = game_util:createIdelAnim(ainmFile,0,heroData,heroCfg);
        else
            animNode = game_util:createCardImgByCfg(heroCfg);
        end
        if animNode then
            local itemSize = animNode:getContentSize();
            if animFlag == false then
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dw_light_down.png")
                if spriteFrame then
                    local tempSprite = CCSprite:createWithSpriteFrame(spriteFrame)
                    tempSprite:setAnchorPoint(ccp(0.5,0.1))
                    tempSprite:setPositionX(itemSize.width*0.5)
                    animNode:addChild(tempSprite)
                end
                local spriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dw_light_up.png")
                if spriteFrame2 then
                    local tempSprite = CCSprite:createWithSpriteFrame(spriteFrame2)
                    tempSprite:setAnchorPoint(ccp(0.5,0.1))
                    tempSprite:setPositionX(itemSize.width*0.5)
                    animNode:addChild(tempSprite,1000,1000)
                end
            else
                animNode:setRhythm(1);
            end
            animNode:setAnchorPoint(ccp(0.5,0));
            -- animNode:setScale(0.7);
            local name_after = heroData.step < 1 and "" or ("+" .. heroData.step);
            local tempLabel = CCLabelTTF:create("Lv." .. heroData.lv .. "/" .. heroData.level_max .. "\n" .. name_after,TYPE_FACE_TABLE.Arial_BoldMT,10);
            tempLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
            tempLabel:setPosition(ccp(itemSize.width*0.5 - 50,97));
            tempLabel:setAnchorPoint(ccp(0,0.5));
            animNode:addChild(tempLabel,100,100)
            -- local tempLabel = CCLabelTTF:create(heroCfg:getNodeWithKey("name"):toStr(),TYPE_FACE_TABLE.Arial_BoldMT,10);
            -- tempLabel:setPosition(ccp(itemSize.width*0.5 + 50,95));
            -- tempLabel:setAnchorPoint(ccp(1,0.5));
            -- animNode:addChild(tempLabel,100,100)
            -- game_util:setHeroNameColorByQuality(tempLabel,heroCfg);
            local occupation_cfg = getConfig(game_config_field.occupation);
            local occupation_item_cfg = occupation_cfg:getNodeWithKey(ainmFile)
            if occupation_item_cfg then
                local occupationType = occupation_item_cfg:toInt();
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupationType .. ".png")
                if spriteFrame then
                    local occupation_icon = CCSprite:createWithSpriteFrame(spriteFrame)
                    occupation_icon:setPosition(ccp(itemSize.width*0.5 + 57,98));
                    occupation_icon:setAnchorPoint(ccp(1,0.5));
                    animNode:addChild(occupation_icon);
                end
            end
            animNode:setScale(0.66);
        end
    end
    return animNode,character_ID
end

--[[--
    创建ui入口并初始化数据
]]
function ui_teamTask_readyScene.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());

    self:refreshUi();
    return rootScene;
end

return ui_teamTask_readyScene;