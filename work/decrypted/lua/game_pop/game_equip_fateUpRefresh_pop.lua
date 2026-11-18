
local game_equip_fateUpRefresh_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    black_layer = nil,
    m_tGameData = nil,
    m_lab_tab = nil,
    m_label_des = nil,
    m_node_tableView = nil,
    m_selEquipDataTab = nil,
    last_m_sel_img = nil,
    m_select_id = nil,
    m_node_equip = nil,
    m_tips_spr_1 = nil,
    m_callback = nil,
    m_node_anim = nil,
    openType = nil,
    equip_fate_cfg = nil,
    m_btn_tab = nil,
    m_select_index = nil,
    m_sp_xiaohao = nil,
    m_sp_shengyu = nil,
    m_currData = nil,
    m_next_data = nil,
    m_tab_fageGem = nil,--命运宝石
    m_node_fateGem = nil,
    gem_fate_cfg = nil,

};
--[[--
    销毁
]]
function game_equip_fateUpRefresh_pop.destroy(self)
    -- body
    cclog("-----------------game_equip_fateUpRefresh_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.black_layer = nil;
    self.m_tGameData = nil;
    self.m_lab_tab = nil;
    self.m_label_des = nil;
    self.m_node_tableView = nil;
    self.m_selEquipDataTab = nil;
    self.last_m_sel_img = nil;
    self.m_select_id = nil;
    self.m_node_equip = nil;
    self.m_tips_spr_1 = nil;
    self.m_callback = nil;
    self.m_node_anim = nil;
    self.openType = nil;
    self.equip_fate_cfg = nil;
    self.m_btn_tab = nil;
    self.m_select_index = nil;
    self.m_sp_xiaohao = nil;
    self.m_sp_shengyu = nil;
    self.m_currData = nil;
    self.m_next_data = nil;
    self.m_tab_fageGem = nil;
    self.m_node_fateGem = nil;
    self.gem_fate_cfg = nil;
end
--[[--
    返回
]]
function game_equip_fateUpRefresh_pop.back(self,type)
    if self.openType == "mainScene" then
        game_scene:enterGameUi("game_main_scene")
    else
        if self.callback and type(self.callback) == "function" then
           self.callback()
        end
        game_scene:removePopByName("game_equip_fateUpRefresh_pop");
        self:destroy();
    end
end
--[[--
    读取ccbi创建ui
]]
function game_equip_fateUpRefresh_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag == ")
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 101 or btnTag == 102 then
            if self.m_select_id then
                local params = {}
                params.equip_id =  self.m_select_id
                params.sort = self.m_select_index
                local function responseMethod( tag,gameData )
                    if gameData then
                        if gameData and tolua.type(gameData) == "util_json" then
                            local data = gameData and gameData:getNodeWithKey("data")
                            local needData = data and json.decode(data:getFormatBuffer()) or {}
                            -- cclog2(needData,"needData === ")
                            local needItemData = needData._client_cache_update.equip._equip.update[tostring(self.m_select_id)]
                            local level_up = needData.leveup_times
                            if level_up then
                                game_util:addMoveTips({text = "Trang bị đã nâng" .. level_up .. "cấp"})
                            end
                            self.m_currData = needItemData
                            self:refreshProperty(needItemData)
                            self:refreshUi()
                            self:addMoveLabel(needData.bind_data_temp,needData.fate_range)
                        end
                    end
                end
                if btnTag == 101 then
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("fate_equip_levelup"), http_request_method.GET, params,"fate_equip_levelup")
                else
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("auto_fate_equip_levelup"), http_request_method.GET, params,"auto_fate_equip_levelup")
                end
            else
                -- game_util:addMoveTips({text = "请先选择绑定的装备"})
                game_util:addMoveTips({text = "Chọn trang bị khóa định"})
            end
        elseif btnTag>200 and btnTag<204 then
            self.m_select_index = btnTag - 200
            for i=1,3 do
                game_util:setCCControlButtonBackground(self.m_btn_tab[i],"succinct_noselect.png")
            end
            game_util:setCCControlButtonBackground(self.m_btn_tab[btnTag-200],"succinct_selected.png")
            if self.m_currData then
                self:refreshProperty(self.m_currData)
            else
                self:refreshProperty(self.m_tGameData)
            end
        elseif btnTag > 500 and btnTag < 505 then --命运宝石
            local gemPosData = {0,0,0,0}
            if self.m_select_id then
                local itemData,itemCfg = game_data:getEquipDataById(self.m_select_id);
                gemPosData = util.table_copy(itemData.gem_fate)  or  {0,0,0,0}
                local oldGemId = gemPosData[btnTag-500] --获取原来位置的宝石id
                local itemOnClick = function (typeName,id)
                    if typeName == "exchanged" then --传给后端的变化过的宝石数据
                        if id then
                            gemPosData[btnTag - 500] = id
                        end
                    elseif typeName == "unload" then
                        gemPosData[btnTag - 500] = 0
                    end
                    local function responseMethod( tag,gameData )
                        local equip_info = gameData:getNodeWithKey("data"):getNodeWithKey("equip_info")
                        equip_info = json.decode(equip_info:getFormatBuffer()) or {}
                        -- if typeName == "exchanged" then
                        --     game_data:addFateGemDataByCid(oldGemId,1)
                        --     game_data:minusFateGemDataCid(id,1)
                        -- elseif typeName == "unload" then
                        --     game_data:addFateGemDataByCid(oldGemId,1)
                        -- end
                        self:refreshProperty(equip_info)
                        -- cclog2(equip_info,"equip_info-=-----------")
                        self:refreshGemPos(gemPosData,btnTag - 500)
                    end
                    local str = ""
                    for i=1,4 do
                        str = str .. (gemPosData[i] or "0") .. (i == 4 and "" or "_")
                    end
                    -- cclog2(str,"=============str ==========")
                    local params = {}
                    params.major = self.m_select_id

                    params.gem_fates = str
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gem_fate_using_gem_fate"), http_request_method.GET, params,"gem_fate_using_gem_fate")
                end
                local sort = 0 -- 可装备的宝石类型
                if btnTag == 501 then
                    sort = itemCfg:getNodeWithKey("sort"):toInt()
                else
                    sort = 5
                end
                game_scene:addPop("game_selectfateGem_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,sortBtnShow = false,selSort = sort,openType = 2})
            else
                -- game_util:addMoveTips({text = "请先选择绑定的装备"})
               game_util:addMoveTips({text = "Chọn trang bị khóa định"})
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_equip_fateUpgrade.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_node_fateGem = ccbNode:nodeForName("m_node_fateGem")
    self.m_sp_xiaohao = ccbNode:spriteForName("m_sp_xiaohao")
    self.m_sp_shengyu = ccbNode:spriteForName("m_sp_shengyu")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    local m_ok_btn1 = ccbNode:controlButtonForName("m_ok_btn1")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-18)
    m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-18)
    if m_ok_btn1 then
        m_ok_btn1:setVisible(game_data:isViewOpenByID(193))
        m_ok_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-18)
    end
    self.black_layer = ccbNode:layerForName("layer_color")
    self.black_layer:setVisible(false)
    self.m_label_refresh = ccbNode:labelTTFForName("m_label_refresh")
    self.m_label_des = ccbNode:labelTTFForName("m_label_des")
    self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")
    self.m_node_equip = ccbNode:nodeForName("m_node_equip")
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")
    self.m_node_anim = ccbNode:nodeForName("m_node_anim")
    self.m_node_anim:setVisible(false)
    self.m_btn_tab = {}
    local m_btn 
    for i=1,3 do
        m_btn = ccbNode:controlButtonForName("m_btn_" .. i)
        m_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-18)
        self.m_btn_tab[i] = m_btn

    end
    self.m_lab_tab = {}
    local m_label_num,m_label_porperty,m_label_surplus,m_label_refresh,m_label_anim
    for i=1,2 do
        m_label_num = ccbNode:labelTTFForName("m_label_num" .. i)
        m_label_refresh = ccbNode:labelTTFForName("m_label_refresh" .. i)
        m_label_porperty = ccbNode:labelTTFForName("m_label_porperty" .. i)
        m_label_surplus = ccbNode:labelTTFForName("m_label_surplus" .. i)
        m_label_anim = ccbNode:labelTTFForName("m_label_anim" .. i)
        self.m_lab_tab[i] = {m_label_anim = m_label_anim , m_label_refresh = m_label_refresh , m_label_num = m_label_num,m_label_porperty = m_label_porperty,m_label_surplus = m_label_surplus}
    end

    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScale(resolution_config:getScale())

    self.m_tab_fageGem = {}
    local m_btn_fateGem, m_sprite_can, m_node_equipIcon = nil,nil,nil
    for i=1,4 do
        m_btn_fateGem = ccbNode:controlButtonForName("m_btn_fateGem" .. i)
        m_sprite_can = ccbNode:spriteForName("m_sprite_can" .. i)
        m_btn_fateGem:setTouchPriority(GLOBAL_TOUCH_PRIORITY-18)
        m_sprite_can:setScale(0.8)
        m_sprite_can:runAction(game_util:createRepeatForeverFade());
        m_node_equipIcon = ccbNode:nodeForName("m_node_equipIcon" .. i)
        if not game_data:isViewOpenByID(500) then
            m_btn_fateGem:setVisible(false)
            m_sprite_can:setVisible(false)
            m_node_equipIcon:setVisible(false)
        end
        self.m_tab_fageGem[i] = {m_node_equipIcon = m_node_equipIcon, m_btn_fateGem = m_btn_fateGem, m_sprite_can = m_sprite_can}
    end
    

    local flag = true
    if flag then
        self.m_node_fateGem:setVisible(true)
    else
        self.m_node_fateGem:setVisible(false)
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end


    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-17,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

function game_equip_fateUpRefresh_pop.refreshGemPos(self,gemPosData,curPos)
    local equipdata,equipcfg = game_data:getEquipDataById(self.m_select_id)
    local equipSort = equipcfg:getNodeWithKey("sort"):toInt()
    if game_data:isViewOpenByID(500) then
        for i=1,4 do
            local sort = 0
            self.m_tab_fageGem[i].m_sprite_can:setVisible(false)
            if i == 1 then
                sort = equipSort
                
            else
                sort = 5 
            end
            local gemTab = game_data:getFateGemDataByGemType(sort)
            if gemTab and next(gemTab) then
                self.m_tab_fageGem[i].m_sprite_can:setVisible(true)
            end
        end
    end
    local tempNode = nil;
    if gemPosData then
        for i=1,4 do
            tempNode = self.m_tab_fageGem[i].m_node_equipIcon 
            tempNode:removeAllChildrenWithCleanup(true)
            if tempNode then
                local tempNodeSize = tempNode:getContentSize();
                local id = gemPosData[i];
                if id and tostring(id) ~= "0" then
                    local tempIcon,gemName = game_util:createFateGemIconByCid(id);
                    if tempIcon then
                        tempIcon:setPosition(ccp(tempNodeSize.width*0.5 ,tempNodeSize.height*0.5-2))
                        tempNode:addChild(tempIcon,10,10)
                        if curPos and curPos == i then
                            tempIcon:setScale(2.0);
                            local animArr = CCArray:create();
                            animArr:addObject(CCSpawn:createWithTwoActions(CCEaseIn:create(CCScaleTo:create(0.5,1.0),5),CCFadeIn:create(0.5)));
                            animArr:addObject(CCScaleTo:create(0.15,1.2));
                            animArr:addObject(CCScaleTo:create(0.15,0.65));
                            tempIcon:runAction(CCSequence:create(animArr));
                            self.m_selGemPos = nil;
                            tempIcon:setScale(0.65)
                        else
                            tempIcon:setScale(0.65)
                        end
                    end
                    if gemName then
                        local tempLabel = game_util:createLabelTTF({text = gemName,color = ccc3(250,255,0),fontSize = 10});
                        tempLabel:setPosition(ccp(tempNodeSize.width*0.5,6))
                        tempNode:addChild(tempLabel,11,11)
                    else
                        -- cclog("equipIndex == " .. i .. " ; equipId == " .. tostring(id));
                    end
                else
                    tempNode:removeAllChildrenWithCleanup(true)
                end
            end
        end
    else
        for i=1,4 do
            tempNode = self.m_tab_fageGem[i].m_node_equipIcon 
            tempNode:removeAllChildrenWithCleanup(true)
        end
    end
end

--创建增加的数值动画
function game_equip_fateUpRefresh_pop.addMoveLabel( self,tempData,range )
    local itemData,itemCfg = game_data:getEquipDataById(tostring(self.m_select_id));
    local name1 = itemCfg:getNodeWithKey("ability1"):toStr()
    local name2 = itemCfg:getNodeWithKey("ability2"):toStr()
    local function getSign( value )
        if tonumber(value) > 0 then
            return tostring("+" .. value)
        else
            return tostring(value)
        end
        -- body
    end
    local str1,str2,tempname1,tempname2
    for k,v in pairs(range) do
        if k == name1 then
            tempname1 = PUBLIC_ABILITY_TABLE["ability_" .. tonumber(k)].name
            str1 = tempname1 .. ": " .. getSign(v[1]) .. "% ~ " ..getSign(v[2]) .. "%"
        else
            tempname2 = PUBLIC_ABILITY_TABLE["ability_" .. tonumber(k)].name
            str2 = tempname2 .. ": " .. getSign(v[1]) .. "% ~ " .. getSign(v[2]) .. "%"
        end
    end
    if tempData[tostring(name1)] then
        self.m_lab_tab[1].m_label_refresh:setString(tempname1 .. ":" .. getSign(tempData[tostring(name1)]) .. "%")
        self.m_lab_tab[1].m_label_anim:setString(getSign(tempData[tostring(name1)]) .. "%")
    else
        self.m_lab_tab[1].m_label_anim:setString("")
    end
    
    if tempData[tostring(name2)] then
        self.m_lab_tab[2].m_label_refresh:setString(tempname2 .. ":" .. getSign(tempData[tostring(name2)]) .. "%")
        self.m_lab_tab[2].m_label_anim:setString(getSign(tempData[tostring(name2)]) .. "%")
    else
         self.m_lab_tab[2].m_label_anim:setString("")
    end
    
    self.m_node_anim:setVisible(true)
    local function delayTimeCallFunc(  )
        self.m_node_anim:setVisible(false)
        self.m_node_anim:runAction(CCMoveBy:create(0.1,ccp(0,-15)))
        self.m_lab_tab[1].m_label_refresh:setString(str1)
        self.m_lab_tab[2].m_label_refresh:setString(str2)
    end
    local animArr = CCArray:create()
    animArr:addObject(CCDelayTime:create(0.3))
    animArr:addObject(CCMoveBy:create(0.6, ccp(0, 15)))
    animArr:addObject(CCCallFuncN:create(delayTimeCallFunc))
    self.m_node_anim:runAction(CCSequence:create(animArr))
end
--[[--
    创建装备列表
]]
function game_equip_fateUpRefresh_pop.createEquipTableView(self,viewSize)
    cclog("-----------------game_equip_forge createEquipTableView-----------------");
    self.last_m_sel_img = nil;
    self.m_selEquipDataTab =  game_data:getEquipIDByFate();
    self.m_selEquipDataTab = game_data:equipSortByTypeName(nil, self.m_selEquipDataTab);
    local equipCount = #self.m_selEquipDataTab;
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1; --列
    params.totalItem = equipCount;
    params.itemActionFlag = true;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-18
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = game_util:createEquipItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < equipCount then
                local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipDataTab[index+1]);
                -- cclog2(self.m_selEquipDataTab[index+1],"self.m_selEquipDataTab[index+1] =====")
                game_util:setEquipItemInfoByTable2(ccbNode,itemData);
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                if itemData.id == self.m_select_id then
                    m_sel_img:setVisible(true);
                    self.last_m_sel_img = m_sel_img
                else
                    m_sel_img:setVisible(false);
                end
                
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local m_sel_img = ccbNode:spriteForName("m_sel_img")
            local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipDataTab[index+1]);
            if itemData and itemData.id ~= self.m_select_id then
                if self.last_m_sel_img then
                    self.last_m_sel_img:setVisible(false)
                end
                -- self.property_node:setVisible(true)
                m_sel_img:setVisible(true)
                -- self.label_exp:setVisible(true)
                self.m_select_id = itemData.id
                self.last_m_sel_img = m_sel_img
                self.m_currData = itemData
                self:refreshProperty(itemData)
                self:refreshTips()
                self:refreshGemPos(itemData.gem_fate)
                -- cclog2(self.m_select_id,"m_select_id")
            end
        end
    end
    return TableViewHelper:create(params);
end
function game_equip_fateUpRefresh_pop.refreshProperty( self,itemData )
    if itemData then
        local tempProperty = itemData.bind_temp or ""
        local itemData,itemCfg = game_data:getEquipDataById(tostring(self.m_select_id));
        local name1 = itemCfg:getNodeWithKey("ability1"):toInt()
        local name2 = itemCfg:getNodeWithKey("ability2"):toInt()
        local propertyName1 = PUBLIC_ABILITY_TABLE["ability_" .. tonumber(name1)].name
        local propertyName2 = PUBLIC_ABILITY_TABLE["ability_" .. tonumber(name2)].name
        self.m_lab_tab[1].m_label_porperty:setString(propertyName1)
        self.m_lab_tab[2].m_label_porperty:setString(propertyName2)
        local value1,value2 = self:getFateGemData(itemData.gem_fate)
        cclog2(value1,"value1-=---------")
        cclog2(value2,"value2-=---------")
        self.m_lab_tab[1].m_label_num:setString(tostring(itemData.bind_data[tostring(name1)]+ value1) .. "%")
        self.m_lab_tab[2].m_label_num:setString(tostring(itemData.bind_data[tostring(name2)]+ value2) .. "%")
        -- cclog("name1 === " .. name1 .. "   name2 === " .. name2 )
        local sort1,sort2 = 0
        local _,itemCfg = game_data:getEquipDataById(itemData.id);
        itemCfg = json.decode(itemCfg:getFormatBuffer())
        local length = game_util:getTableLen(self.equip_fate_cfg)
        for i = 1,length do
            if itemCfg then 
                if tonumber(self.equip_fate_cfg[tostring(i)].equip_quality) == tonumber(itemCfg.quality) then
                    if itemData.bind_data[tostring(name1)] <= self.equip_fate_cfg[tostring(i)]["refresh_range1"] then
                        sort1 = self.equip_fate_cfg[tostring(i)]["refresh"]
                        local nextNum = i + 1
                        if i == length then
                            nextNum = length
                        end
                        self.m_next_data[1] = self.equip_fate_cfg[tostring(nextNum)]["refresh_equip_fate_range"]
                        break
                    end
                end
            end
        end
        for i = 1,length do
            if itemCfg then 
                if tonumber(self.equip_fate_cfg[tostring(i)].equip_quality) == tonumber(itemCfg.quality) then
                    if itemData.bind_data[tostring(name2)] <= self.equip_fate_cfg[tostring(i)]["refresh_range2"] then
                        sort2 = self.equip_fate_cfg[tostring(i)]["refresh"]
                        local nextNum = i + 1
                        if i == length then
                            nextNum = length
                        end
                        self.m_next_data[2] = self.equip_fate_cfg[tostring(nextNum)]["refresh_equip_fate_range"]
                        break
                    end
                    
                end
            end
        end
        local  cost = sort1[self.m_select_index] + sort2[self.m_select_index]
        self.m_lab_tab[1].m_label_surplus:setString(tostring(cost))
        local spriteName = {"public_icon_destinyStone1.png","public_icon_destinyStone2.png","public_icon_destinyStone3.png"}
        self.m_sp_shengyu:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteName[self.m_select_index]))
        self.m_sp_xiaohao:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteName[self.m_select_index]))
        local str1,str2 = "","";
        str1 = propertyName1 .. ":" .. self.m_next_data[1][self.m_select_index][1] .. "~" .. self.m_next_data[1][self.m_select_index][2]
        str2 = propertyName2 .. ":" ..  self.m_next_data[2][self.m_select_index][1] .. "~" .. self.m_next_data[2][self.m_select_index][2]
        self.m_lab_tab[1].m_label_refresh:setString(str1)
        self.m_lab_tab[2].m_label_refresh:setString(str2)


        local desdinyName = {"min_fate_stone","mid_fate_stone","max_fate_stone"}
        local desdiny = game_data:getUserStatusDataByKey(desdinyName[self.m_select_index])
        
        self.m_lab_tab[2].m_label_surplus:setString(tostring(desdiny))
    else
        local desdinyName = {"min_fate_stone","mid_fate_stone","max_fate_stone"}
        local desdiny = game_data:getUserStatusDataByKey(desdinyName[self.m_select_index])
        self.m_lab_tab[2].m_label_surplus:setString(tostring(desdiny))
    end
end
function game_equip_fateUpRefresh_pop.getFateGemData( self,gemFateData )
    local value1,value2 = 0,0 --value1装备的特殊属性，value2血量
    local gem_fate_cfg = getConfig(game_config_field.equip_gem_fate)
    if gemFateData and next(gemFateData) then
        for i=1,4 do
            if gemFateData[i] ~= 0 then
                local cId = game_util.bloodStone.gem.getCId(gemFateData[i])
                local itemCfgData = gem_fate_cfg:getNodeWithKey(cId)
                local team = itemCfgData:getNodeWithKey("team"):toInt()
                local num = tonumber(itemCfgData:getNodeWithKey("value"):toStr())
                if team == 5 then
                    value2 = num + value2
                else
                    value1 = num + value1
                end
            end
        end
    end
    return value1,value2
end
function game_equip_fateUpRefresh_pop.refreshTips(self)
    -- self.m_lab_tab[1].m_label_refresh:setString("")
    -- self.m_lab_tab[2].m_label_refresh:setString("")

    if self.m_select_id then
        local itemData,itemCfg = game_data:getEquipDataById(tostring(self.m_select_id));
        local st_lv = itemData.st_lv
        local sort = itemCfg:getNodeWithKey("sort"):toInt()
        --self:getProperty(self,m_select_id)
        local ccbNode = game_util:createEquipItemByCCB(itemData);
        self.m_node_equip:removeAllChildrenWithCleanup(true)
        self.m_node_equip:addChild(ccbNode,10,10);
        self.m_tips_spr_1:setVisible(false);
        self.m_node_equip:removeAllChildrenWithCleanup(true)
        self.m_node_equip:addChild(ccbNode,10,10);
        self.m_tips_spr_1:setVisible(false);

    else
        self.m_tips_spr_1:setVisible(true);
        self.m_node_equip:removeAllChildrenWithCleanup(true)
    end

end
function game_equip_fateUpRefresh_pop.refreshUi( self )
    self.m_node_tableView:removeAllChildrenWithCleanup(true);
    local m_tableView = self:createEquipTableView(self.m_node_tableView:getContentSize(),self.m_selEquipDataTab);
    self.m_node_tableView:addChild(m_tableView);

    -- self.m_label_des:setString("  提高的百分比数值为该本命角色身上除命运装备升级功能外的所有数值")
        self.m_label_des:setString("Trị số tỉ lệ % tăng lên là tất cả trị số trên người nhân vật trừ tính năng nâng cấp trang bị vận mệnh")


    for i=1,3 do
        game_util:setCCControlButtonBackground(self.m_btn_tab[i],"succinct_noselect.png")
    end
    game_util:setCCControlButtonBackground(self.m_btn_tab[self.m_select_index],"succinct_selected.png")
   
    -- 自适应滑动到选定装备位置
    if self.m_select_id then
        local index = 1
        for i=1,#self.m_selEquipDataTab do
            if self.m_selEquipDataTab[i] == tostring(self.m_select_id) then
                index = i
                break
            end
        end

        local offset = m_tableView:getContentOffset()
        local viewSize = self.m_node_tableView:getContentSize()
        local totalItem = #self.m_selEquipDataTab
        local column = 1 
        local row = 4
        local itemSize = CCSizeMake(viewSize.width/column,viewSize.height/row);
        m_tableView:setContentOffset(ccp(offset.x, 0 + viewSize.height - (totalItem - index + 1) * itemSize.height))
    end

end

--[[--
    初始化
]]
function game_equip_fateUpRefresh_pop.init(self,t_params)
    self.m_selEquipDataTab = {}
    self.m_tGameData = t_params.gameData
    self.m_callback = t_params.callBack
    local equip_fate = getConfig(game_config_field.equip_fate)
    self.equip_fate_cfg = json.decode(equip_fate:getFormatBuffer()) or {}
    self.m_select_index = 1
    self.m_next_data = {}
    self.gem_fate_cfg = json.decode(getConfig(game_config_field.equip_gem_fate):getFormatBuffer());

    -- local consume = equip_fate:getNodeWithKey("1"):getNodeWithKey("refresh"):toInt()
    -- self.m_lab_tab[1].m_label_surplus:setString(tostring(consume))



    
end

--[[--
    创建ui入口并初始化数据
]]
function game_equip_fateUpRefresh_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self.openType = t_params.openType or nil
    if self.m_tGameData and self.m_tGameData.id then
        local itemData = game_data:getEquipDataById(self.m_tGameData.id)
        self.m_select_id = self.m_tGameData.id
        self:refreshProperty(itemData)
        self:refreshGemPos(itemData.gem_fate)
        self:refreshTips()
    end
    self:refreshUi()
    local desdinyName = {"min_fate_stone","mid_fate_stone","max_fate_stone"}
    local desdiny = game_data:getUserStatusDataByKey(desdinyName[self.m_select_index])
    self.m_lab_tab[2].m_label_surplus:setString(tostring(desdiny))
    return self.m_popUi;
end
return game_equip_fateUpRefresh_pop;