---  虫洞 编队

local game_wormhole_adjustment_formation = {
    m_tGameData    = nil,
    m_ccbNode      = nil,
    m_ccbNode2     = nil,

    m_scroll_right = nil,
    m_btn_yijian = nil,

    m_shuxing_btn = nil,
    m_medal_btn = nil,
    m_soul_btn = nil,
    m_btn_saint_stone  = nil,
    m_replace_btn = nil,
    m_node_right =nil,
    m_sel_bg = nil,

    m_pos_sp = {},
    m_team_hero = {},
    m_pos = {}, 

    m_sel_pos = nil,

    m_formation_layer = nil,
    m_formation_layer2 = nil,

    m_data_cards = nil,

    m_team_count = nil,

    maptype = nil,

    m_lb_equip_tb ={},
    m_lb_gem_tb ={},
    m_lb_magic_tb ={},

    m_btn_equip_tb ={},
    m_btn_gem_tb ={},
    m_btn_magic_tb ={},

    m_sp_equip = {},
    m_sp_gem = {},
    m_sp_magic = {},

    m_sp_ming = {},
    -- m_equip_field = nil,
    -- m_gem_field = nil,
    -- m_talisman_field = nil,
    -- m_wormholes_formation = nil,
        
    m_equip_data = {},   -- hash
    m_gem_data = {},   -- hash
    m_talisman_data = {},   -- hash
    m_sp_skill = nil,
    skill_detail_cfg = nil,
    skillnode= nil,
    m_move_icon = nil,
    m_moveflag = nil,

    m_tTalismanWorm_add = {},
    m_tTalismanWorm_remove = {},
    m_tEquipWorm_add = {},
    m_tEquipWorm_remove = {},
};
--[[--
    销毁
]]
function game_wormhole_adjustment_formation.destroy(self)
    -- body
    cclog("-----------------game_wormhole_adjustment_formation destroy-----------------");

    self.m_tGameData    = nil;
    self.m_ccbNode      = nil;
    self.m_ccbNode2     = nil;
    self.m_scroll_right = nil;
    self.m_pos_sp = nil;
    self.m_team_hero = nil;
    self.m_pos = nil;
    self.m_btn_yijian = nil;
    self.m_shuxing_btn = nil;
    self.m_medal_btn = nil;
    self.m_soul_btn = nil;
    self.m_btn_saint_stone  = nil;
    self.m_node_right =nil

    self.m_sel_bg = nil;
    self.m_replace_btn = nil;

    self.m_formation_layer = nil;
    self.m_formation_layer2 = nil;
    self.m_sel_pos = nil

    self.m_data_cards = nil
    self.m_team_count = nil

    self.maptype = nil
    
    self.m_lb_equip_tb = nil
    self.m_lb_gem_tb = nil
    self.m_lb_magic_tb = nil

    self.m_btn_equip_tb = nil
    self.m_btn_gem_tb = nil
    self.m_btn_magic_tb = nil

    self.m_sp_equip = nil
    self.m_sp_gem = nil
    self.m_sp_magic = nil

    self.m_sp_ming = nil
    -- self.m_equip_field = nil
    -- self.m_gem_field = nil
    -- self.m_talisman_field = nil
    -- self.m_wormholes_formation = nil
    self.m_equip_data = nil
    self.m_gem_data = nil
    self.m_talisman_data = nil
    self.m_sp_skill = nil
    self.skill_detail_cfg = nil
    self.skillnode = nil
    self.m_move_icon = nil
    self.m_moveflag = nil
    self.m_tTalismanWorm_add = nil
    self.m_tTalismanWorm_remove = nil
    self.m_tEquipWorm_add = nil
    self.m_tEquipWorm_remove = nil
end
--[[--
    返回
]]
function game_wormhole_adjustment_formation.back(self,backType)
    local t_params = {
        title = string_config.m_title_prompt,
        okBtnCallBack = function(target,event)
            game_util:closeAlertView();
            if self.opentype == "map" then
                local function responseMethod( tag,gameData )
                    local id = self.maptype.id
                    local maptype = self.maptype.maptype
                    self:destroy(); 
                    local data = gameData:getNodeWithKey("data");
                    data = json.decode(data:getFormatBuffer()) or {}
                    game_scene:enterGameUi("game_wormhole_map",{gameData = data,maptype ={id =id,maptype = maptype }})
                end
                local params = {}
                params.sort = self.maptype.maptype
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_go_map"), http_request_method.GET, params,"wormholes_go_map")
            else
                local function responseMethod( tag,gameData )
                    self:destroy(); 
                    local data = gameData:getNodeWithKey("data");
                    data = json.decode(data:getFormatBuffer()) or {}
                    game_scene:enterGameUi("game_wormhole_main",{gameData = data});
                end

                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_index"), http_request_method.GET, {},"wormholes_index")
            end
        end,   --可缺省
        cancelBtnCallBack = function(target,event)
            game_util:closeAlertView();
        end,
        okBtnText = "Xác nhận",       --可缺省
        cancelBtnText = "Hủy",
        onlyOneBtn = false,
        text ="Bỏ qua lưu đội hình không?",      --可缺省
        touchPriority = GLOBAL_TOUCH_PRIORITY-12,
    }
    game_util:openAlertView(t_params);
end
--[[--
    读取ccbi创建ui
]]
function game_wormhole_adjustment_formation.createUi(self)
    local ccbNode = luaCCBNode:create();
    local ccbNode2 = luaCCBNode:create();
    self.m_pos_sp = {};
    self.m_pos = {};
    self.m_team_hero = self.m_team_hero or {};
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 99999 then
            self:back("back");
        elseif btnTag == 1 then -- 进入地图
            if not next(self.m_team_hero) then
                game_util:addMoveTips({text = "Hãy đưa Anh Hùng ra trận!"})
            else
                    -- game_scene:enterGameUi("game_wormhole_map",{maptype = self.maptype    });
                    --[[]]
                local function responseMethod(tag,gameData)
                    game_data:addEquipWormholeBytable(self.m_tEquipWorm_add or {})
                    game_data:removeEquipWormholeBytable(self.m_tEquipWorm_remove or {})
                    game_data:addTalismanWormholeBytable(self.m_tTalismanWorm_add or {})
                    game_data:removeTalismanWormholeBytable(self.m_tTalismanWorm_remove or {})
                    local function responseMethod( tag,gameData )
                        local data = gameData:getNodeWithKey("data");
                        data = json.decode(data:getFormatBuffer()) or {}
                        game_scene:enterGameUi("game_wormhole_map",{gameData = data,maptype ={id =self.maptype.id,maptype = self.maptype.maptype }}); --先传一个table吧
                        
                    end
                    local params = {}
                    params.sort = self.maptype.maptype
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_go_map"), http_request_method.GET, params,"wormholes_go_map")
                end

                local wormholes_formation = "wormholes_formation="
                local equip = ""
                local gem = ""
                local talisman = ""
                local isfirsthole = 1
                for i=1,9 do
                    if self.m_team_hero[i] then
                        if i == 1 then
                            wormholes_formation = wormholes_formation..self.m_team_hero[i].id
                        else
                            wormholes_formation = wormholes_formation.."_"..self.m_team_hero[i].id
                        end
                    else
                        if i == 1 then
                            wormholes_formation = wormholes_formation.."0"
                            isfirsthole = 0
                        else
                            if isfirsthole == 1 then
                                wormholes_formation = wormholes_formation.."_0"
                                isfirsthole = 0
                            else
                                wormholes_formation = wormholes_formation.."_-1"
                            end
                        end
                    end
                    equip = equip.."&equip_"..i.."="
                    gem = gem.."&gem_"..i.."="
                    talisman = talisman.."&talisman_"..i.."="
                    if self.m_team_hero[i] then
                        for j=1, 4 do
                            if j == 1 then
                                equip = equip..self.m_team_hero[i].equip[j]
                                gem = gem..self.m_team_hero[i].gem[j]
                                talisman = talisman..self.m_team_hero[i].talisman[j]
                            else
                                equip = equip.."_"..self.m_team_hero[i].equip[j]
                                gem = gem.."_"..self.m_team_hero[i].gem[j]
                                talisman = talisman.."_"..self.m_team_hero[i].talisman[j]
                            end
                        end
                    else
                        equip = equip.."0_0_0_0"
                        gem = gem.."0_0_0_0"
                        talisman = talisman.."0_0_0_0"
                    end

                    -- equip = equip.."&equip_"..i.."=0_0_0_0"
                    -- gem = gem.."&gem_"..i.."=0_0_0_0"
                    -- talisman = talisman.."&talisman_"..i.."=0_0_0_0"
                end
                local params = wormholes_formation..equip..gem..talisman.."&sort="..self.maptype.maptype
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wormholes_set_sort_field"), http_request_method.POST, params,"wormholes_set_sort_field")
                --]]
            end

        elseif btnTag == 2 then -- 上阵
            self:addSelHeroUi( self.m_sel_pos)
            
        elseif btnTag == 3 then -- 一键换装
            if self.m_sel_pos == nil or self.m_team_hero[self.m_sel_pos] == nil then
                game_util:addMoveTips({text = "Hãy chọn Anh Hùng!"})
            else
                self:autoMatchEquip()
                self:refreshUi()
            end
            
        elseif btnTag == 104 or btnTag == 102 or  btnTag == 103 then -- 
            game_util:addMoveTips({text = "Chức năng chưa mở, hãy cùng chờ đợi nhé! "})

            
        elseif btnTag == 101 then --属性
            if self.m_sel_pos == nil or self.m_team_hero[self.m_sel_pos] == nil then
                game_util:addMoveTips({text = "Hãy chọn Anh Hùng!"})
            end


        elseif btnTag == 1101 or btnTag == 1102 or btnTag == 1103 or btnTag == 1104 then

            local btnCallFunc = function( target,event )
            end
            local itemOnClick = function (typeName,eid)
                local oldeid = self.m_team_hero[self.m_sel_pos].equip[btnTag%1100]
                if typeName == "exchanged" then
                    if oldeid.."" ~= "0" then
                        self.m_equip_data[oldeid..""] = 1
                        if self.m_tEquipWorm_add[oldeid] then
                            self.m_tEquipWorm_add[oldeid] = nil
                        else
                            self.m_tEquipWorm_remove[oldeid] = 1
                        end
                    end
                    self.m_team_hero[self.m_sel_pos].equip[btnTag%1100] = eid..""
                    self.m_equip_data[eid..""] = nil
                    if self.m_tEquipWorm_remove[eid] then
                        self.m_tEquipWorm_remove[eid] = nil
                    else
                        self.m_tEquipWorm_add[eid] = 1
                    end
                elseif typeName == "unload" then
                    if oldeid.."" ~= "0" then
                        self.m_equip_data[oldeid..""] = 1
                        if self.m_tEquipWorm_add[oldeid] then
                            self.m_tEquipWorm_add[oldeid] = nil
                        else
                            self.m_tEquipWorm_remove[oldeid] = 1
                        end
                    end
                    self.m_team_hero[self.m_sel_pos].equip[btnTag%1100] = "0"
                end
                game_scene:removePopByName("game_equip_select_pop")
                self:refreshUi(self.m_curTab)
            end
            
            local cardData,heroCfg=game_data:getCardDataById(self.m_team_hero[self.m_sel_pos].id)
            local bind_equip =  cardData.bind_equip or {}
            if not bind_equip[btnTag] or bind_equip[btnTag] == 0 then
                local alldata = self:revTable(self.m_equip_data)
                game_scene:addPop("game_equip_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,sortBtnShow = false,selSort = btnTag%1100 ,openType = 12,selHerocId = cardData.c_id,allData = alldata})
            end

        elseif btnTag == 1201 or btnTag == 1202 or btnTag == 1203 or btnTag == 1204 then
            local btnCallFunc = function( target,event )
            end
            local itemOnClick = function (typeName,gid)
                local oldgid = self.m_team_hero[self.m_sel_pos].gem[btnTag%1200]
                if typeName == "exchanged" then
                    if oldgid.."" ~= "0" then
                        if self.m_gem_data[oldgid] then 
                            self.m_gem_data[oldgid] = self.m_gem_data[oldgid] + 1
                        else
                            self.m_gem_data[oldgid] = 1
                        end
                    end
                    self.m_team_hero[self.m_sel_pos].gem[btnTag%1200] = gid..""
                    -- self.m_team_hero[self.m_sel_pos].equip[btnTag%1100] = eid..""
                    self.m_gem_data[gid] = self.m_gem_data[gid] - 1
                    if self.m_gem_data[gid] <= 0 then
                        self.m_gem_data[gid] = nil
                    end
                elseif typeName == "unload" then
                    if oldgid.."" ~= "0" then
                        if self.m_gem_data[oldgid] then 
                            self.m_gem_data[oldgid] = self.m_gem_data[oldgid] + 1
                        else
                            self.m_gem_data[oldgid] = 1
                        end
                    end
                    self.m_team_hero[self.m_sel_pos].gem[btnTag%1200] = "0"
                end
                game_scene:removePopByName("gem_system_select_pop")
                self:refreshUi(self.m_curTab)
            end
            local selSort = (btnTag%1200) < 2 and 1 or 2
            -- local alldata = self:revTable(self.m_gem_data)
            game_scene:addPop("gem_system_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,sortBtnShow = false,selSort = selSort,openType = 2,allData = self.m_gem_data})


        elseif btnTag == 1301 or btnTag == 1302 or btnTag == 1303 or btnTag == 1304 then
            local btnCallFunc = function( target,event )
            end
            local itemOnClick = function (typeName,tid)
                local oldtid = self.m_team_hero[self.m_sel_pos].talisman[btnTag%1300]
                if typeName == "exchanged" then
                    if oldtid.."" ~= "0" then
                        self.m_talisman_data[oldtid] = 1
                        if self.m_tTalismanWorm_add[oldtid] then
                            self.m_tTalismanWorm_add[oldtid] = nil
                        else
                            self.m_tTalismanWorm_remove[oldtid] = 1
                        end
                    end
                    self.m_team_hero[self.m_sel_pos].talisman[btnTag%1300] = tid..""
                    self.m_talisman_data[tid] = nil
                    -- self.m_tTalismanWorm_add[tid] = 1
                    if self.m_tTalismanWorm_remove[tid] then
                        self.m_tTalismanWorm_remove[tid] = nil
                    else
                        self.m_tTalismanWorm_add[tid] = 1
                    end
                elseif typeName == "unload" then
                    if oldtid.."" ~= "0" then
                        self.m_talisman_data[oldtid] = 1
                        if self.m_tTalismanWorm_add[oldtid] then
                            self.m_tTalismanWorm_add[oldtid] = nil
                        else
                            self.m_tTalismanWorm_remove[oldtid] = 1
                        end
                    end
                    self.m_team_hero[self.m_sel_pos].talisman[btnTag%1300] = "0"
                end
                game_scene:removePopByName("game_magic_select_pop")
                self:refreshUi(self.m_curTab)
            end
            local selSort = (btnTag%1300) < 3 and 1 or 0
            local alldata = self:revTable(self.m_talisman_data)
            game_scene:addPop("game_magic_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,sortBtnShow = false,selSort = selSort,openType = 2,allData = alldata})


        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_wormhole_adjustment_formation.ccbi");


    ccbNode2:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode2:openCCBFile("ccb/ui_game_wormhole_adjustment_formation_right.ccbi");

    self.m_ccbNode  = ccbNode
    self.m_ccbNode2  = ccbNode2
    
    for i=1,9 do
        self.m_pos_sp[i] = ccbNode:nodeForName("m_pos_"..i)
        self.m_pos[i] = {x = self.m_pos_sp[i]:convertToWorldSpace(ccp(0,0)).x , y = self.m_pos_sp[i]:convertToWorldSpace(ccp(0,0)).y}
    end

    self.m_scroll_right = ccbNode:scrollViewForName("m_scroll_right")
    self.m_sel_bg = ccbNode:spriteForName("m_sel_bg")
    self.m_replace_btn = ccbNode:controlButtonForName("m_replace_btn")
    self.m_replace_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    ccbNode:controlButtonForName("m_btn_go"):setOpacity(0)
    ccbNode:controlButtonForName("m_btn_go"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    ccbNode:controlButtonForName("m_back_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    self.m_formation_layer = ccbNode:layerForName("m_formation_layer")
    self.m_formation_layer2 = ccbNode:layerForName("m_formation_layer2")

    -- ccb2
    self.m_node_right = ccbNode2:nodeForName("m_node_right")
    self.m_sp_skill = ccbNode:nodeForName("m_sp_skill")
    self.m_btn_yijian = ccbNode:controlButtonForName("m_btn_yijian")
    -- self.m_sp_skill:setOpacity(0)

    -- self.skillnode = CCNode:create()
    -- self.m_sp_skill:addChild(self.skillnode)

    self.m_lb_equip_tb = {}
    self.m_lb_gem_tb = {}
    self.m_lb_magic_tb = {}
 
    self.m_btn_equip_tb = {}
    self.m_btn_gem_tb = {}
    self.m_btn_magic_tb = {}

    self.m_sp_equip = {}
    self.m_sp_gem = {}
    self.m_sp_magic = {}
    self.m_sp_ming = {}

    self.m_tTalismanWorm_add = self.m_tTalismanWorm_add or {}
    self.m_tTalismanWorm_remove = self.m_tTalismanWorm_remove or {}
    self.m_tEquipWorm_add = self.m_tEquipWorm_add or {}
    self.m_tEquipWorm_remove = self.m_tEquipWorm_remove or {}

    for i=1,4 do
        self.m_lb_equip_tb[i] = ccbNode:labelTTFForName("m_lb_equip_"..i)
        self.m_lb_gem_tb[i] = ccbNode:labelTTFForName("m_lb_gem_"..i)
        self.m_lb_magic_tb[i] = ccbNode:labelTTFForName("m_lb_magic_"..i)
        self.m_btn_equip_tb[i] = ccbNode:controlButtonForName("m_btn_equip_"..i)
        self.m_btn_gem_tb[i] = ccbNode:controlButtonForName("m_btn_gem_"..i)
        self.m_btn_magic_tb[i] = ccbNode:controlButtonForName("m_btn_magic_"..i)
        self.m_sp_ming[i] = ccbNode:spriteForName("m_sp_ming_"..i)

        self.m_sp_equip[i] = ccbNode:controlButtonForName("m_equip_"..i)
        self.m_sp_gem[i] = ccbNode:controlButtonForName("m_gem_"..i)
        self.m_sp_magic[i] = ccbNode:controlButtonForName("m_magic_"..i)
        self.m_btn_equip_tb[i] :setOpacity(0)
        self.m_btn_gem_tb[i] :setOpacity(0)
        self.m_btn_magic_tb[i] :setOpacity(0)
    end

    self.m_sel_bg:setPosition(self.m_pos_sp[1]:getPosition())
    self.m_sel_pos = 1

    local offsetX = nil
    local offsetY = nil
    local touchpos = {}
    local function onTouchBegan(x, y)
        offsetX = 0
        offsetY = 0
        touchpos.x = x 
        touchpos.y = y
        self.m_moveflag = false
        if x>(self.m_pos[3].x+self.m_pos_sp[3]:getContentSize().width) then
            return false
        end
        for k,v in pairs(self.m_pos) do
            if x>v.x and x<v.x+82 and y >v.y and y<v.y+82 then
                offsetX = x - v.x
                offsetY = y - v.y
                self.m_moveflag = true
                self.m_sel_bg:setPosition(self.m_pos_sp[k]:getPosition())
                if self.m_sel_pos ~= k then
                    self.m_sel_pos = k
                    game_util:setCCControlButtonTitle(self.m_replace_btn,self.m_team_hero[self.m_sel_pos]==nil and "上阵" or "替换")
                    self:refreshUi()
                end
            end
        end
        return self.m_moveflag
    end

    local function onTouchMoved(x, y)
        if ccpDistance(ccp(touchpos.x,touchpos.y),ccp(x,y)) > 20 or self.m_moveflag == true then
            local pos = self.m_formation_layer2:convertToNodeSpace(ccp(x-offsetX,y-offsetY))
            if self.m_move_icon then
                self.m_move_icon:setPosition(pos)
            else
                if self.m_team_hero[self.m_sel_pos] then
                    local heroData,heroCfg = game_data:getCardDataById(self.m_team_hero[self.m_sel_pos].id)
                    self.m_move_icon = self:createCardAnimByData(heroData,heroCfg)
                    if self.m_move_icon then
                        self.m_formation_layer2:addChild(self.m_move_icon)
                        self.m_move_icon:setPosition(pos)
                        self.m_move_icon:setAnchorPoint(ccp(0,0))
                    end
                end
            end
        end
    end

    local function onTouchEnded(x, y)
        self.m_moveflag = false
        if self.m_move_icon then
            self.m_move_icon:removeFromParentAndCleanup(true)
            self.m_move_icon = nil
            for k,v in pairs(self.m_pos) do
                if x>v.x and x<v.x+82 and y >v.y and y<v.y+82 then
                    if k == self.m_sel_pos then -- 在原位置
                    elseif self.m_team_hero[k] == nil then -- 空位置
                        self.m_team_hero[k] = self.m_team_hero[self.m_sel_pos]
                        self.m_team_hero[self.m_sel_pos] = nil
                        self.m_sel_bg:setPosition(self.m_pos_sp[k]:getPosition())
                        self.m_sel_pos = k
                    elseif self.m_team_hero[k] ~= nil then -- 有人
                        local temp = self.m_team_hero[k]
                        self.m_team_hero[k] = self.m_team_hero[self.m_sel_pos]
                        self.m_team_hero[self.m_sel_pos] = temp
                        self.m_sel_bg:setPosition(self.m_pos_sp[k]:getPosition())
                        self.m_sel_pos = k
                    end
                end
            end
            game_util:setCCControlButtonTitle(self.m_replace_btn,self.m_team_hero[self.m_sel_pos]==nil and "上阵" or "替换")
            self:refreshUi()
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
    self.m_formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_formation_layer:setTouchEnabled(true);
    return ccbNode;
end


function game_wormhole_adjustment_formation:addSelHeroUi(posIndex)
    cclog("--------game_wormhole_adjustment_formation  addSelHeroUi --------")
    self.m_team_count = 0
    for k,v in pairs(self.m_team_hero) do
        if k < 7 then
            self.m_team_count = self.m_team_count + 1
        end
    end
    if self.m_team_count >=5 and self.m_team_hero[self.m_sel_pos]== nil and self.m_sel_pos < 7 then -- 煮阵5个且当前无人则
        game_util:addMoveTips({text = "Đội hình cơ sở đã đầy 5 người, không thể tiếp tục tăng thêm. Hãy thử thay đồng đội hoặc thêm đồng đội vào vị trí dự bị!"})
        return
    end

    local btnCallFunc = function( target,event )
        
    end
    local itemOnClick = function (typeName,id)
        if typeName == "exchanged" then
            for k,v in pairs(self.m_team_hero) do
                if id == v.id then
                    self.m_team_hero[k] = nil
                end
            end
            local equip = {"0","0","0","0"}
            local cardData,heroCfg=game_data:getCardDataById(id)
            local cid = cardData.c_id
            local bind_equip = {0,0,0,0}
            cardData.bind_equip = cardData.bind_equip or {0,0,0,0}
            for k,v in pairs(cardData.bind_equip) do
                bind_equip[k] = v
            end

            for i=1,4 do
                if bind_equip[i] == nil then
                    equip[i] = ""
                elseif  bind_equip[i] == 0 or bind_equip[i] == "0" then
                    bind_equip[i] = nil
                else
                    equip[i] = bind_equip[i]..""
                end
            end
            if self.m_team_hero[self.m_sel_pos] then
                for k,v in pairs(self.m_team_hero[self.m_sel_pos].equip) do
                    if self.m_team_hero[self.m_sel_pos].bind_equip[k] then
                    else
                        self.m_equip_data[v..""] = 1
                    end
                end
                for k,v in pairs(self.m_team_hero[self.m_sel_pos].gem) do
                    if v ~= "0" then
                        if self.m_gem_data[v] then
                            self.m_gem_data[v] = self.m_gem_data[v] + 1
                        else
                            self.m_gem_data[v] = 1
                        end
                    end
                end
                for k,v in pairs(self.m_team_hero[self.m_sel_pos].talisman) do
                    if v ~= "0" then
                        self.m_talisman_data[v] = 1
                    end
                end
            end
            self.m_team_hero[self.m_sel_pos] = {id = id ,cid = cid , equip = equip,gem = {"0","0","0","0"},talisman = {"0","0","0","0"},bind_equip=bind_equip}
            game_util:setCCControlButtonTitle(self.m_replace_btn,"Thay")
        elseif typeName == "unload" then
            for k,v in pairs(self.m_team_hero[self.m_sel_pos].equip) do
                if self.m_team_hero[self.m_sel_pos].bind_equip[k] then
                else
                    self.m_equip_data[v..""] = 1
                end
            end
            for k,v in pairs(self.m_team_hero[self.m_sel_pos].gem) do
                if v ~= "0" then
                    if self.m_gem_data[v] then
                        self.m_gem_data[v] = self.m_gem_data[v] + 1
                    else
                        self.m_gem_data[v] = 1
                    end
                end
            end
            for k,v in pairs(self.m_team_hero[self.m_sel_pos].talisman) do
                if v ~= "0" then
                    self.m_talisman_data[v] = 1
                end
            end
            self.m_team_hero[self.m_sel_pos] = nil   
            game_util:setCCControlButtonTitle(self.m_replace_btn,"上阵")
        end
        self:refreshUi()
    end

    local out_carddatas = {}
    local out_carddatas1 = {}
    local selcidtb = {}
    local others = {}
    for k,v in pairs(self.m_team_hero) do
        if k ~= self.m_sel_pos then
            selcidtb[#selcidtb + 1] = v.cid
            others[#others +1] = v.id
        end
    end
    for k,v in pairs(self.m_data_cards) do
        out_carddatas[#out_carddatas + 1] = v
    end

    for k,v in pairs(out_carddatas) do
        for k1,v1 in pairs(selcidtb) do
            if v1 == v.cid then
                out_carddatas[k] = nil
                break
            end
        end
    end
    for k,v in pairs(out_carddatas) do
        out_carddatas1[#out_carddatas1 + 1] = v.id
    end
    game_scene:addPop("game_hero_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,openType = 10 ,data = out_carddatas1,others = others,readycards = {self.m_team_hero[self.m_sel_pos] ~= nil and self.m_team_hero[self.m_sel_pos].id or nil}})
end

--[[--
    刷新ui
]]
function game_wormhole_adjustment_formation.refreshUi(self)
    -- self.m_sp_skill:setOpacity(0)
    cclog("========================================  refreshUi")
    if self.m_team_hero[self.m_sel_pos] then
        game_util:setCCControlButtonTitle(self.m_replace_btn,"Thay")
        if self.m_team_hero[self.m_sel_pos] and self.m_team_hero[self.m_sel_pos].bind_equip then
            local num = next(self.m_team_hero[self.m_sel_pos].bind_equip)
            self.m_btn_yijian:setVisible(num == nil)
        else
            self.m_btn_yijian:setVisible(false)
        end
    else
        game_util:setCCControlButtonTitle(self.m_replace_btn,"Ra trận")
        self.m_btn_yijian:setVisible(false)
    end

    
    for k,v in pairs(self.m_pos_sp) do
        v:removeAllChildrenWithCleanup(true)
        if self.m_team_hero[k] then
            local node = CCNode:create()
            v:addChild(node)
            node:setPosition(ccp(v:getContentSize().width/2,v:getContentSize().height/2))
            bgSprite = CCSprite:createWithSpriteFrameName("dw_characterBg.png")
            local heroData,heroCfg = game_data:getCardDataById(self.m_team_hero[k].id)
            local icon = self:createCardAnimByData(heroData,heroCfg)
            if icon then
                node:addChild(bgSprite)
                node:addChild(icon)
                icon:setPosition(ccp(0,-33))
            end
        end
    end

    for i=1,4 do
        if self.m_sp_equip[i]:getChildByTag(100001) then
            self.m_sp_equip[i]:removeChildByTag(100001,true)
        end
        if self.m_sp_gem[i]:getChildByTag(100001) then
            self.m_sp_gem[i]:removeChildByTag(100001,true)
        end
        if self.m_sp_magic[i]:getChildByTag(100001) then
            self.m_sp_magic[i]:removeChildByTag(100001,true)
        end
    end
    if self.m_sp_skill then
        for i=2000,2020 do
            local sp = self.m_sp_skill:getChildByTag(i)
            if sp then
                sp:removeFromParentAndCleanup(true) 
            end
        end
    end

    if self.m_team_hero[self.m_sel_pos] then

        local equipflag = {"0","0","0","0"}
        local gemflag = {"0","0","0","0"}
        local magicflag = {"0","0","0","0"}

        local cardData,heroCfg = game_data:getCardDataById(self.m_team_hero[self.m_sel_pos].id)

        local skilltb = {}
        if cardData.s_1 and (cardData.s_1.avail.."" == "2" and cardData.s_1.s..""~= "0") then
            skilltb[#skilltb+1]={tb = cardData.s_1 , id = 1}
        end
        if cardData.s_2 and (cardData.s_2.avail.."" == "2" and cardData.s_2.s..""~= "0") then
            skilltb[#skilltb+1]={tb = cardData.s_2 , id = 2}
        end
        if cardData.s_3 and (cardData.s_3.avail.."" == "2" and cardData.s_3.s..""~= "0") then
            skilltb[#skilltb+1]={tb = cardData.s_3 , id = 3}
        end
        if cardData.s_4 and (cardData.s_4.avail.."" == "2" and cardData.s_4.s..""~= "0") then
            skilltb[#skilltb+1]={tb = cardData.s_4 , id = 4}
        end
        if cardData.s_5 and (cardData.s_5.avail.."" == "2" and cardData.s_5.s..""~= "0") then
            skilltb[#skilltb+1]={tb = cardData.s_5 , id = 5}
        end

        if cardData.extra_skill and next(cardData.extra_skill) then
            if cardData.extra_skill.s_4 and (cardData.extra_skill.s_4.avail.."" == "2" and cardData.extra_skill.s_4.s..""~= "0") then
                skilltb[#skilltb+1]={tb = cardData.extra_skill.s_4 , id = 6}
            end
            if cardData.extra_skill.s_5 and (cardData.extra_skill.s_5.avail.."" == "2" and cardData.extra_skill.s_5.s..""~= "0") then
                skilltb[#skilltb+1]={tb = cardData.extra_skill.s_5 , id = 7}
            end
        end

        -- 装备
        -- local equipTable = game_data:getEquipIdTable()
        local equipTable = self:revTable(self.m_equip_data)
        local itemData, itemCfg = nil, nil
        for i,v in ipairs(equipTable) do
            itemData, itemCfg = game_data:getEquipDataById(tostring(v))
            if itemData then
                local equipSort = itemCfg:getNodeWithKey("sort") and itemCfg:getNodeWithKey("sort"):toInt() or 0
                local canUseFlag = true
                -- if itemData.bind_card and itemData.bind_card ~= "" then
                --     canUseFlag = false
                -- end
                if self:equipInOthers(tostring(v)) then
                    canUseFlag = false
                end
                if canUseFlag and equipflag[tonumber(equipSort)] then
                    equipflag[tonumber(equipSort)] = "1"
                end
            end
        end
        self.m_team_hero[self.m_sel_pos].bind_equip = self.m_team_hero[self.m_sel_pos].bind_equip or {}
        for i=1,4 do
            if self.m_team_hero[self.m_sel_pos].bind_equip[i] then
                equipflag[i] = 0
            end
        end

        -- 宝石
        -- local gemTable = game_data:getGemIdTable()
        -- local gemdata = game_data:getGemData()
        local gemdata = self.m_gem_data
        for k,v in pairs(gemdata) do
            local itemData,itemCfg= game_data:getGemDataById(k,gemdata)
            local gemSort = itemCfg:getNodeWithKey("career") and itemCfg:getNodeWithKey("career"):toInt() or 0
            local canUseFlag = true
            if self:gemInOthers(tostring(k)) then
                canUseFlag = false
            end
            if canUseFlag then
                if tonumber(gemSort) == 1 then
                    gemflag[1] = "1"
                else
                    gemflag[2] = "1"
                    gemflag[3] = "1"
                    gemflag[4] = "1"
                end
            end
        end

        -- 法宝
        -- local magicdata = game_data:getMagicData()
        local magicdata = self:revTable(self.m_talisman_data)

        for k,v in pairs(magicdata) do
            local itemdata = game_data:getMagicDataById(v)
            itemCfg = self.talismanCfg:getNodeWithKey(itemdata.c_id)
            talisman_type = itemCfg:getNodeWithKey("talisman_type") and itemCfg:getNodeWithKey("talisman_type"):toInt() or 0
            local canUseFlag = true
            if self:talismanInOthers(tostring(k)) then
                canUseFlag = false
            end
            if canUseFlag then
                if tonumber(talisman_type) == 1 then
                    magicflag[1] = "1"
                    magicflag[2] = "1"
                else
                    magicflag[3] = "1"
                    magicflag[4] = "1"
                end
            end

        end

        for i=1,4 do
            -- 装备
            local e_id = self.m_team_hero[self.m_sel_pos].equip[i]
            local e_id = self.m_team_hero[self.m_sel_pos].equip[i]
            if e_id.."" == "0" then
                if equipflag[i] == "1" then
                    self.m_lb_equip_tb[i]:setVisible(true)
                    self.m_btn_equip_tb[i]:setEnabled(true)
                    self.m_sp_ming[i]:setVisible(false)
                else
                    self.m_lb_equip_tb[i]:setVisible(false)
                    self.m_btn_equip_tb[i]:setEnabled(false)
                    self.m_sp_ming[i]:setVisible(false)
                end
            else
                if self.m_team_hero[self.m_sel_pos].bind_equip[i] then
                    self.m_lb_equip_tb[i]:setVisible(false)
                    self.m_btn_equip_tb[i]:setEnabled(false)
                    self.m_sp_ming[i]:setVisible(true)
                else
                    self.m_lb_equip_tb[i]:setVisible(false)
                    self.m_btn_equip_tb[i]:setEnabled(true)
                    self.m_sp_ming[i]:setVisible(false)
                end

                local itemData_,itemCfg_ = game_data:getEquipDataById(e_id)
                if itemData_ then
                    local icon,name = game_util:createEquipIconByCid(itemData_.c_id)
                    if icon then
                        self.m_sp_equip[i]:addChild(icon)
                        icon:setAnchorPoint(ccp(0,0))
                        icon:setTag(100001)
                    end
                end
            end

            -- 宝石
            local g_id = self.m_team_hero[self.m_sel_pos].gem[i]
            if g_id.."" == "0" then
                if gemflag[i] == "1" then
                    self.m_lb_gem_tb[i]:setVisible(true)
                    self.m_btn_gem_tb[i]:setEnabled(true)
                else
                    self.m_lb_gem_tb[i]:setVisible(false)
                    self.m_btn_gem_tb[i]:setEnabled(false)
                end
            else
                self.m_lb_gem_tb[i]:setVisible(false)
                self.m_btn_gem_tb[i]:setEnabled(true)
                --  显示装上宝石
                local _, gemId = game_util:getRealGemLvAndCid(g_id)
                if gemId then
                    local icon,gemName = game_util:createGemIconByCid(gemId)
                    if icon then
                        self.m_sp_gem[i]:addChild(icon)
                        icon:setAnchorPoint(ccp(0.5,0.5))
                        icon:setPosition(ccp(self.m_sp_gem[i]:getContentSize().width/2,self.m_sp_gem[i]:getContentSize().height/2))
                        icon:setTag(100001)
                    end
                end
            end

            -- 法宝
            local t_id = self.m_team_hero[self.m_sel_pos].talisman[i]
            if t_id.."" == "0" then
                if magicflag[i] == "1" then
                    self.m_lb_magic_tb[i]:setVisible(true)
                    self.m_btn_magic_tb[i]:setEnabled(true)
                else
                    self.m_lb_magic_tb[i]:setVisible(false)
                    self.m_btn_magic_tb[i]:setEnabled(false)
                end
            else
                self.m_lb_magic_tb[i]:setVisible(false)
                self.m_btn_magic_tb[i]:setEnabled(true)
                --  显示装上法宝
                local magicItemData,magicItemCfg = game_data:getMagicDataById(t_id)
                if magicItemCfg then
                    local icon = game_util:createMagicIcon(magicItemCfg)
                    if icon then
                        self.m_sp_magic[i]:addChild(icon)
                        icon:setAnchorPoint(ccp(0,0))
                        icon:setTag(100001)
                    end
                end
            end
        end
        local function onClickBtn( event, target  )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            game_scene:addPop("skills_activation_pop",{skillData = skilltb[tonumber(btnTag)%2010].tb,selHeroId=-1,posIndex = tonumber(btnTag)%2010})
        end

        if next(skilltb) then
            for k,v in pairs(skilltb) do
                local skillJsonData = self.skill_detail_cfg:getNodeWithKey(tostring(v.tb.s))
                local skill_icon_spr = game_util:createSkillIconByCfg(skillJsonData,v.tb.avail)
                local width = skill_icon_spr:getContentSize().width/2
                self.m_sp_skill:addChild(skill_icon_spr)
                skill_icon_spr:setAnchorPoint(ccp(0,0))
                local skill_icon_button = game_util:createCCControlButton("public_weapon.png","",onClickBtn)
                self.m_sp_skill:addChild(skill_icon_button)
                skill_icon_button:setTag(k)
                skill_icon_button:setOpacity(0)
                self.m_sp_skill:setScale(0.75)
                skill_icon_spr:setScale(0.8)
                -- skill_icon_button:setScale(0.8)
                skill_icon_button:setAnchorPoint(ccp(0,0))
                local skill_label_name = game_util:createLabelTTF({text = skillJsonData:getNodeWithKey("skill_name"):toStr(),fontSize = 8}) 
                skill_icon_spr:addChild(skill_label_name)
                skill_label_name:setPosition(ccp(skill_icon_spr:getContentSize().width/2,skill_icon_spr:getContentSize().height*1.2))
                if k<5 then
                    skill_icon_spr      :setPosition(ccp((k-1)*55 +5 , 0))
                    skill_icon_button   :setPosition(ccp((k-1)*55 +5 , 0))
                else
                    skill_icon_spr      :setPosition(ccp((k-5)*55 +5 , -1*60))
                    skill_icon_button   :setPosition(ccp((k-5)*55 +5 , -1*60))
                end
                skill_icon_spr      :setTag(2000+k)
                skill_icon_button   :setTag(2010+k)
            end
        end
    else --- 没人
        for i=1,4 do
            if self.m_sp_equip[i]:getChildByTag(100001) then
                self.m_sp_equip[i]:removeChildByTag(100001,true)
            end
            if self.m_sp_gem[i]:getChildByTag(100001) then
                self.m_sp_gem[i]:removeChildByTag(100001,true)
            end
            if self.m_sp_magic[i]:getChildByTag(100001) then
                self.m_sp_magic[i]:removeChildByTag(100001,true)
            end
            self.m_lb_equip_tb[i]:setVisible(false)
            self.m_btn_equip_tb[i]:setEnabled(false)
            self.m_lb_gem_tb[i]:setVisible(false)
            self.m_btn_gem_tb[i]:setEnabled(false)
            self.m_lb_magic_tb[i]:setVisible(false)
            self.m_btn_magic_tb[i]:setEnabled(false)
            self.m_sp_ming[i]:setVisible(false)
        end
    end

    local height1 = self.m_node_right:getContentSize().height
    local viewsize = self.m_scroll_right:getViewSize()
    self.m_scroll_right:setContentOffset(ccp(0,viewsize.height-height1),true)
end

--[[
    自动穿装备
]]
function game_wormhole_adjustment_formation.autoMatchEquip( self )
    -- 暂时定为 让他每次点换装都不一样
    local tempequip = self.m_team_hero[self.m_sel_pos].equip
    self.m_team_hero[self.m_sel_pos].equip = {"0","0","0","0"}
    local itemdata , itemCfg = nil
    local cid = {0,0,0,0}
    -- cclog2(self.m_equip_data,"self.m_equip_data")
    for k,v in pairs(self.m_equip_data) do
        itemdata, itemcfg = game_data:getEquipDataById(k)
        if itemcfg then
            local sort = itemcfg:getNodeWithKey("sort"):toInt()
            if cid[sort] < itemdata.c_id then
                cid[sort] = itemdata.c_id
                self.m_team_hero[self.m_sel_pos].equip[sort] = k
            end
        end
    end
    for k,v in pairs(self.m_team_hero[self.m_sel_pos].equip) do
        if self.m_equip_data[v..""] then
            self.m_equip_data[v..""] = nil
        end
    end
    for k,v in pairs(tempequip) do
        if v ~= "0" then
            self.m_equip_data[v..""] = 1
        end
    end
end


function game_wormhole_adjustment_formation.equipInOthers( self,item_id)
    ---todo
    return false
end

function game_wormhole_adjustment_formation.gemInOthers( self,item_id)
    ---todo
    return false
end

function game_wormhole_adjustment_formation.talismanInOthers( self,item_id)
    ---todo
    return false
end

function game_wormhole_adjustment_formation.createCardAnimByData( self, heroData,heroCfg,animFlag)
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
    初始化
]]
function game_wormhole_adjustment_formation.init(self,t_params)
    self.maptype = t_params.maptype
    self.opentype = t_params.opentype
    t_params = t_params.gameData or {};
    --t_params.can_use_cards
    self.m_data_cards = {}

    for k,v in pairs(t_params.can_use_cards) do
        local idata = game_data:getCardDataById(v)
        if idata then
            self.m_data_cards[#self.m_data_cards + 1] = {id = v,cid = idata.c_id}
        end
    end

    local cannot_use_equip       = t_params.cannot_use_equip or {}
    local cannot_use_talisman    = t_params.cannot_use_talisman or {}
    local can_use_gem            = t_params.can_use_gem or {}

    self.m_team_count = 0

    self.m_team_hero = {}
    if next(t_params.wormholes_field) then
        local equip_field = t_params.wormholes_field.equip
        for k,v in pairs(equip_field) do
            for k1,v1 in pairs(v) do
                equip_field[k][k1] = v1..""
            end
        end
        local gem_field = t_params.wormholes_field.gem
        local talisman_field = t_params.wormholes_field.talisman
        local wormholes_formation = t_params.wormholes_field.wormholes_formation
        if next(wormholes_formation) then
            for k,v in pairs(wormholes_formation) do
                if v ~= "0" and v ~= "-1" then
                    local cardData,heroCfg=game_data:getCardDataById(v)
                    if cardData.bind_equip == nil then
                        cardData.bind_equip = {"0","0","0","0"}
                    end
                    local cid = cardData.c_id
                    local bind_equip = {"0","0","0","0"}
                    for k1,v1 in pairs(bind_equip) do
                        if cardData.bind_equip[k1] then
                            bind_equip[k1] = cardData.bind_equip[k1]
                        end
                    end
                    for i=1,4 do
                        if bind_equip[i] then
                            if bind_equip[i] == 0  or bind_equip[i] == "0"  then
                                bind_equip[i] = nil
                            else
                                equip_field[k..""][i] = bind_equip[i]..""
                            end
                        end
                    end
                    self.m_team_hero[k] = {id = v ,cid = cid,equip = equip_field[k..""],gem = gem_field[k..""],talisman = talisman_field[k..""],bind_equip = bind_equip}
                end
            end
        end
    end
    self.charapter_cfg = getConfig(game_config_field.character_detail)
    self.equipCfg = getConfig(game_config_field.equip)
    self.gemCfg = getConfig(game_config_field.gem)
    self.talismanCfg = getConfig(game_config_field.talisman)
    self.skill_detail_cfg = getConfig(game_config_field.skill_detail)

    -- 整理数据

    --装备
    local edata = game_data:getEquipIdTable()
    local itemdata__, itemcfg__ = nil
    self.m_equip_data = {}
    for k,v in pairs(edata) do
        itemdata__, itemcfg__ = game_data:getEquipDataById(v)
        if itemdata__.bind_card and itemdata__.bind_card ~= "" then --去掉命运绑定装
        else
            self.m_equip_data[v..""] = 1
        end
    end

    for k,v in pairs(cannot_use_equip) do --清理掉其他战场
        if self.m_equip_data[v..""] then
            self.m_equip_data[v..""] = nil
        end
    end
    for k,v in pairs(self.m_team_hero) do --清理掉其他在线装备
        for k1,v1 in pairs(v.equip) do
            if v1.."" ~= "0" then
                self.m_equip_data[v1..""] = nil
            end
        end
    end

    -- cclog2(self.m_equip_data,"self.m_equip_data2222222")
    --法宝
    local tdata = game_data:getMagicIdTable()
    self.m_talisman_data = {}
    for k,v in pairs(tdata) do
        self.m_talisman_data[v] = 1
    end
    for k,v in pairs(cannot_use_talisman) do --清理掉其他战场
        if self.m_talisman_data[v] then
            self.m_talisman_data[v] = nil
        end
    end
    for k,v in pairs(self.m_team_hero) do --清理掉其他在线装备
        for k1,v1 in pairs(v.talisman) do
            if self.m_talisman_data[v1] ~= "0" then
                self.m_talisman_data[v1] = nil
            end
        end
    end


    --宝石
    self.m_gem_data = can_use_gem
end

function game_wormhole_adjustment_formation.revTable(self,tableIn)
    local tableOut = {}
    for k,v in pairs(tableIn) do
        tableOut[#tableOut+1] = k
    end
    return tableOut
end

--[[--
    创建ui入口并初始化数据
]]
function game_wormhole_adjustment_formation.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_wormhole_adjustment_formation;