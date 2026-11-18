--- 装备信息

local game_equip_info_pop = {
    m_tGameData = nil,
    m_popUi = nil,
    m_fromUi = nil,
    m_ccbNode = nil,
    m_label_name = nil, -- 名称标题
    m_icon_spr = nil, --装备主图标
    m_level_label = nil, -- 等级
    m_root_layer = nil,
    m_close_btn = nil,
    m_node = nil, -- 右侧主界面 node
    m_scroll_main = nil,
    m_scrollview_ass = nil,
    m_suit_name_label = nil,
    m_btn_node = nil, --按钮集群层
    m_node_getbtn_bg = nil, --获得按钮层
    m_btn_fate = nil, -- 命运按钮
    m_conbtn_toget = nil, -- 获得按钮
    m_unbind_btn = nil, -- 解绑按钮
    m_TempNode1 = nil,
    m_TempNode2 = nil,

    m_openType = nil,
    m_callBack = nil,
    m_posEquipData = nil,
    m_togetFun = nil,
    m_suitEquipData = nil,
    m_sel_img = nil,
    fateEquipLock = nil,
    selHeroId = nil,
    m_curEquip_id = nil,
    curEquipData = nil,
    m_recast_atts = {},
    m_equipid = nil,
    m_is_equip_recast = false,
    recast_bind_id = nil,
    attrs = {},
    isnoneBtn = nil,
    touchLayer = nil,
    suitfromTeam = nil,
};

--[[--
    销毁
]]
function game_equip_info_pop.destroy(self)
    -- body
    cclog("-----------------game_equip_info_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_popUi = nil;
    self.m_fromUi = nil;
    self.m_ccbNode = nil;
    self.m_label_name = nil;
    self.m_icon_spr = nil;
    self.m_level_label = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_node = nil;
    self.m_scroll_main = nil;
    self.m_scrollview_ass = nil;
    self.m_suit_name_label = nil;
    self.m_btn_node = nil;
    self.m_node_getbtn_bg = nil;
    self.m_btn_fate = nil;
    self.m_conbtn_toget = nil;
    self.m_unbind_btn = nil;
    self.m_TempNode1 = nil;
    self.m_TempNode2 = nil;

    self.m_openType = nil;
    self.m_callBack = nil;
    self.m_posEquipData = nil;
    self.m_togetFun = nil;
    self.m_suitEquipData = nil;
    self.m_sel_img = nil;
    self.fateEquipLock = nil;
    self.selHeroId = nil;
    self.m_curEquip_id = nil;
    self.curEquipData = nil;
    self.m_recast_atts = {};
    self.m_equipid = nil;
    self.m_is_equip_recast = false;
    self.recast_bind_id = nil;
    self.attrs = nil;
    self.isnoneBtn = nil;
    self.touchLayer = nil;
    self.suitfromTeam = nil;
end
--[[--
    返回
]]
function game_equip_info_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    if self.fateEquipLock and self.fateEquipLock == true then
        self.m_callBack("fateEquipLock");
    end
    game_scene:removePopByName("game_equip_info_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_equip_info_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();

        if self.enterType == "storeHouse_get" and btnTag ~= 1 and btnTag ~= 311 then
            game_util:addMoveTips({text = "Không thể thao tác trong kho"})
            return
        end

        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 11 then--强化
            if self.m_callBack and type(self.m_callBack) == "function" then
                self.m_callBack("strengthen");
            end
            self:back();
        elseif btnTag == 12 then--进阶
            if self.m_callBack and type(self.m_callBack) == "function" then
                self.m_callBack("evolution");
            end
            self:back();
        elseif btnTag == 13 then--卸下
            if self.m_callBack and type(self.m_callBack) == "function" then
                self.m_callBack("unload");
            end
            self:back();
        elseif btnTag == 15 then-- 去获取
            if self.m_togetFun and type(self.m_togetFun) == "function" then
                self.m_togetFun();
            end
            self:back();
        elseif btnTag == 16 then
            local gameData = {equip_id = self.m_curEquip_id,selHeroId = self.selHeroId}
            local function callBack()
                self:back()
            end
            if self.curEquipData and self.curEquipData.bind_card and self.curEquipData.bind_card ~= "" then
                game_scene:addPop("game_equip_fateUpRefresh_pop",{gameData = self.curEquipData,callBack = callBack})
            else
                game_scene:addPop("game_equip_fateUpBilling_pop",{gameData = gameData,callBack = callBack})
            end
        elseif btnTag == 17 then
            local t_params = 
                {
                    title = "TIPS",
                    okBtnCallBack = function(target,event)
                        game_util:closeAlertView();

                        local params = {}
                        params.equip_id =  self.m_curEquip_id
                        local function responseMethod( tag,gameData )
                            if gameData then
                            game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"));
                              self:refreshUi()
                              -- game_util:addMoveTips({text = "解绑成功"})
                              self.m_unbind_btn:setVisible(false)
                            end
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("fate_equip_unbind"), http_request_method.GET, params,"fate_equip_unbind")
                      
                    end,   --可缺省
                    closeCallBack = function(target,event)
                        game_util:closeAlertView();
                    end,
                  okBtnText = "Xác nhận",       --可缺省
                  text = "Mở khóa xong không trả nguyên liệu đã đùng để nâng cấp vận mệnh, mở chứ？",      --可缺省
                }
            game_util:openAlertView(t_params);
        elseif btnTag == 311 then -- 仓库存入
            if self.enterType == "storeHouse_get" then
                cclog("[storeHouse] 点击仓库取出")
                local function responseMethod(tag,gameData)
                    game_util:addMoveTips({text = "Lấy ra thành công!"})
                    if self.m_callBack and type(self.m_callBack) == "function" then
                        self.m_callBack("storeToHouse_get");
                    end
                    self:back();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("storehouse_del_equip"), http_request_method.GET, {equip_ids = self.tempId},"storehouse_del_equip")
            elseif self.enterType == "storeHouse_save" then
                cclog("[storeHouse] 点击仓库存入")
                local function responseMethod(tag,gameData)
                    game_util:addMoveTips({text = "Cất vào thành công!"})
                    if self.m_callBack and type(self.m_callBack) == "function" then
                        self.m_callBack("storeToHouse_save");
                    end
                    self:back();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("storehouse_store_equip"), http_request_method.GET, {equip_ids = self.m_equipid},"storehouse_store_equip")
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event

    ccbNode:openCCBFile("ccb/ui_equip_info_pop_scroll.ccbi");
    -- if self.m_is_equip_recast then
    -- ccbNode:openCCBFile("ccb/ui_equip_info_pop_recast.ccbi");
    -- else
    --     ccbNode:openCCBFile("ccb/ui_equip_info_pop.ccbi");
    -- end
    ccbNode:controlButtonForName("btn_storeToHouse"):setVisible(false)
    self.btn_storeToHouse = ccbNode:controlButtonForName("btn_storeToHouse")
    self.btn_storeToHouse:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 16);
    if self.enterType == "storeHouse_get" then
        game_util:setCCControlButtonBackground(self.btn_storeToHouse, "storeHouse_4.png")
    elseif self.enterType == "storeHouse_save" then
        game_util:setCCControlButtonBackground(self.btn_storeToHouse, "storeHouse_2.png")
    end

    self.m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer")
    self.m_label_name = ccbNode:labelTTFForName("m_label_name")
    self.m_icon_spr = ccbNode:spriteForName("m_icon_spr")
    self.m_level_label = ccbNode:labelBMFontForName("m_level_label");
    self.m_node = ccbNode:nodeForName("m_node")
    self.m_scroll_main = ccbNode:scrollViewForName("m_scroll_main")
    self.m_scroll_main:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 16)
    self.m_scrollview_ass = ccbNode:scrollViewForName("m_scrollview_ass")
    self.m_scrollview_ass:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 16)

    self.m_suit_name_label = ccbNode:labelBMFontForName("m_suit_name_label")

    self.m_btn_node = ccbNode:nodeForName("m_btn_node");
    self.m_node_getbtn_bg = ccbNode:nodeForName("m_node_getbtn_bg");   -- 去获取装备按钮 board
    self.m_node_getbtn_bg:setVisible(false)

    self.m_btn_fate = ccbNode:controlButtonForName("m_btn_fate")
    self.m_btn_fate:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 16);



    self.m_unbind_btn = ccbNode:controlButtonForName("m_unbind_btn")
    self.m_unbind_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 16);
    self.m_conbtn_toget = ccbNode:controlButtonForName("m_conbtn_toget")  -- 去获取按钮
    game_util:setCCControlButtonTitle(self.m_conbtn_toget,"Đi lấy");
    self.m_conbtn_toget:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 16);
    self.m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"), "CCControlButton");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 16);

    local tempBtn = nil;
    for i=1,3 do
        tempBtn = ccbNode:controlButtonForName("m_btn" .. i)
        if tempBtn then
            tempBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 16);
            game_util:setControlButtonTitleBMFont(tempBtn)
        end
    end
    if self.m_openType == 3 or self.m_openType == 4 then
        tempBtn = ccbNode:controlButtonForName("m_btn3")
        game_util:setCCControlButtonTitle(tempBtn,"Trang bị");
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- self:back();
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-15,true);
    self.m_root_layer:setTouchEnabled(true);

    self.touchLayer = CCLayer:create();
    self:initEquipLayerTouch(self.touchLayer);
    ccbNode:addChild(self.touchLayer)

    local node_fuor_equip = ccbNode:nodeForName("node_fuor_equip");
    self.m_sel_img = CCSprite:createWithSpriteFrameName("public_light.png");
    self.m_sel_img:setVisible(false);
    self.m_sel_img:setScale(1.5);
    node_fuor_equip:addChild(self.m_sel_img)

    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[--
    
]]
function game_equip_info_pop.initEquipLayerTouch(self,formation_layer)
    local tempItem,selItem = nil,nil
    local realPos = nil;
    local tag = nil;
    local function onTouchBegan(x, y)
        -- CCTOUCHBEGAN event must return true
        selItem = nil;
        for i=1,4 do
            tempItem = self.m_ccbNode:spriteForName("m_suit_icon" .. i)
            if tempItem and tempItem:getParent():isVisible() then 
                realPos = tempItem:getParent():convertToNodeSpace(ccp(x,y));
                if tempItem:boundingBox():containsPoint(realPos) then
                    tag = i;
                    selItem = tempItem;
                    break;
                end
            end
        end
        return true
    end
    
    local function onTouchMoved(x, y)
    end
    
    local function onTouchEnded(x, y)
        if selItem then
            realPos = selItem:getParent():convertToNodeSpace(ccp(x,y));
            if selItem:boundingBox():containsPoint(realPos) then
                if self.enterType == "storeHouse_get" then
                    game_util:addMoveTips({text = "Không thể thao tác trong kho"})
                    return
                end
                self:equipInfo(tag)


                cclog("     onTouchEnded         ")
            end
        end
        tempItem = nil;
        tag = nil;
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-16)
    formation_layer:setTouchEnabled(true)
end

--[[--
    equipInfo
]]
function game_equip_info_pop.equipInfo(self,posIndex)
    cclog("==================  build equipInfo view ====================")
    if self.m_suitEquipData == nil then 
        return
    end

    local tempData = self.m_suitEquipData[posIndex];
    if tempData == nil then return end

    local itemData = tempData.itemData or {lv = 1,openValue = 1}

    local itemCfg = tempData.itemCfg;
    local level = itemData.lv;
    
    self.m_curEquip_id = itemData.id or "0"
    self.curEquipData = itemData or {}

    if not self.m_TempNode1 then
        self.m_TempNode1 = CCNode:create()
        self.m_scroll_main:addChild(self.m_TempNode1,1001)
    else

        self.m_TempNode1:removeAllChildrenWithCleanup(true)

    end

    if not self.m_TempNode2 then
        self.m_TempNode2 = CCNode:create()
        self.m_scrollview_ass:addChild(self.m_TempNode2,1002)
    else
        self.m_TempNode2:removeAllChildrenWithCleanup(true)
    end

    local viewSize1 = self.m_scroll_main:getViewSize()
    local viewSize2 = self.m_scrollview_ass:getViewSize()
    local height1 = 0

    local recastlabel1 = nil
    local recastlabel2 = nil
    self.attrs = {}
    -- 普通属性
    local attrName1,value1,attrName2,value2,icon1,icon2,name1,name2  = game_util:getEquipAttributeValue(itemCfg,level,itemData)
    self.attrs[name1] ={value = tonumber(value1),id = PUBLIC_ABILITY_NAME_TABLE[name1]["typeValue"]}
    self.attrs[name2] ={value = tonumber(value2),id = PUBLIC_ABILITY_NAME_TABLE[name2]["typeValue"]}

    -- 附魔属性
    if  tempData.itemData ~= nil then 
        for k,v in pairs(tempData.itemData.atts) do
            local value = 0
            if self.attrs[k] then
                value = self.attrs[k]["value"] or 0
            end
            self.attrs[k] = {value = tonumber(v) + value ,id = PUBLIC_ABILITY_NAME_TABLE[k]["typeValue"]}
        end
    end
    -- 打造属性
    if  tempData.itemData ~= nil then 
        local build_atts = tempData.itemData.build_atts or {}
        for k,v in pairs(build_atts) do
            local value = 0
            if self.attrs[k] then
                value = self.attrs[k]["value"] or 0
            end
            self.attrs[k] = {value = tonumber(v) + value ,id = tonumber(PUBLIC_ABILITY_NAME_TABLE[k]["typeValue"])}
        end
    end

    local outtable = {}
    for k,v in pairs(self.attrs) do
        table.insert(outtable,{name = k, id = v.id ,value = v.value})
    end

    table.sort( outtable, function( a,b ) return a.id<b.id end)

    local icon_num = 1
    for i,v in ipairs(outtable) do
        local itemsp = CCSprite:create()
        self.m_TempNode1:addChild(itemsp)
        itemsp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(PUBLIC_ABILITY_NAME_TABLE[v.name]["icon"]))
        itemsp:setAnchorPoint(ccp(1,0))

        local itemlabel = CCLabelTTF:create(tostring(""),TYPE_FACE_TABLE.Arial_BoldMT,12)
        self.m_TempNode1:addChild(itemlabel)
        itemlabel:setAnchorPoint(ccp(0,0))
        itemlabel:setString(" " .. v.value)
        if icon_num == 1 then 
            height1 = height1 + 1.5* itemlabel:getContentSize().height
        end
        if icon_num ~= 1 then
            height1 = height1 + (icon_num)%2 *itemsp:getContentSize().height
        end
        itemsp:setPosition(ccp(itemsp:getContentSize().width *1.5  + ((icon_num-1)%2) *0.48 *viewSize1.width, -height1))
        itemlabel:setPosition(ccp(itemsp:getContentSize().width *1.5  + ((icon_num-1)%2) *0.48 *viewSize1.width, -height1))

        icon_num = icon_num +1
    end

    -- 重铸属性
    if itemData.is_equip_recast then 
        local tabledata = game_data:getEquipgetconfirmPropTable(itemData.recast_atts,itemData.recast_bind)
        for i=1,#tabledata do
            if not self.m_TempNode1:getChildByTag(tonumber(500+i)) then
                recastlabel1 = CCLabelTTF:create(tostring(""),TYPE_FACE_TABLE.Arial_BoldMT,12)
                self.m_TempNode1:addChild(recastlabel1,tonumber(500+i))
            else
                recastlabel1 = self.m_TempNode1:getChildByTag(tonumber(500+i))
            end

            if not self.m_TempNode1:getChildByTag(tonumber(500+i)) then
                recastlabel2 = CCLabelTTF:create(tostring(""),TYPE_FACE_TABLE.Arial_BoldMT,12)
                self.m_TempNode1:addChild(recastlabel2,tonumber(500+i))
            else
                recastlabel2 = self.m_TempNode1:getChildByTag(tonumber(500+i))
            end

            recastlabel1:setString(tabledata[i][1] )

            height1 = height1 + 1.5* recastlabel1:getContentSize().height

            recastlabel1:setAnchorPoint(ccp(0,0))
            recastlabel1:setPosition(ccp(viewSize1.width *0.05, -height1))

            recastlabel2:setString(tabledata[i][2])
            height1 = height1 + 1.1* recastlabel2:getContentSize().height

            recastlabel2:setAnchorPoint(ccp(0,0))
            recastlabel2:setPosition(ccp(viewSize1.width *0.05, -height1))

            if game_data:isTenEquipInHeroEquipTab(self.m_equipid,tabledata[i][3].."") then
                recastlabel1:setColor(ccc3(0,255,0))
                recastlabel2:setColor(ccc3(0,255,0))
            else
                recastlabel1:setColor(ccc3(155,155,155))
                recastlabel2:setColor(ccc3(155,155,155))
            end
        end

    end

    -- 2018春节套装属性

    local equip_add1 = itemCfg:getNodeWithKey("equip_add1") and  json.decode(itemCfg:getNodeWithKey("equip_add1"):getFormatBuffer()) or ""
    local occupation1 = itemCfg:getNodeWithKey("occupation1") and  json.decode(itemCfg:getNodeWithKey("occupation1"):getFormatBuffer()) or ""
    local effect =itemCfg:getNodeWithKey("effect"):toStr() --效果
    if effect.."" == "0" then effect = "" end
    local ocdes = itemCfg:getNodeWithKey("des"):toStr() --装备技能描述
    if occupation1 and next(occupation1) then
        local zhiye = {}
        local typename = ""
        for k,v in pairs(occupation1) do
            zhiye[#zhiye+1] = tonumber(v) or 0
            if k ~= 1 then typename = typename .." hay " end
            typename = typename..MAIN_OCCUPATION_TABLE[tonumber(v)+1].name
        end
        local outstr = ""
        if ocdes and ocdes ~= "" then
            -- for k,v in pairs(zhiye) do
            --     local sp =  CCSprite:createWithSpriteFrameName("public_ocupation" .. v .. ".png")
            --     self.m_TempNode1:addChild(sp)
            --     sp:setAnchorPoint(ccp(0,0.9))
            --     sp:setPosition(ccp(viewSize1.width *0.05 + (k+0.7)*sp:getContentSize().width*0.9, -height1))
            -- end
            local pos1 = string.find(ocdes,"occupation")
            local pos2 = string.find(ocdes,"effect")
            local str1 = string.sub(ocdes,0,pos1-1)
            local str2 = ""
            local str3 = ""
            if pos2 then
                str2 = string.sub(ocdes,pos1+10,pos2-1)
                str3 = string.sub(ocdes,pos2+6,-1)
            else
                str2 = string.sub(ocdes,pos1+10,-1)
            end
            outstr = outstr.. typename..str2..effect..str3
            local lbOutstr = CCLabelTTF:create(outstr,TYPE_FACE_TABLE.Arial_BoldMT,12)
            lbOutstr:setDimensions(CCSizeMake(160,110));
            self.m_TempNode1:addChild(lbOutstr)
            lbOutstr:setAnchorPoint(ccp(0,1))
            lbOutstr:setHorizontalAlignment(kCCTextAlignmentLeft)
            lbOutstr:setVerticalAlignment(kCCVerticalTextAlignmentTop)
            lbOutstr:setPosition(ccp(viewSize1.width *0.05, -height1))
            height1 = height1 + 1.5* lbOutstr:getContentSize().height
            local flag = game_data:isEquipInAllHeroEquipTab(itemData.id,zhiye) or false
            lbOutstr:setColor(flag and ccc3(255,186,0) or ccc3(155,155,155))
        end
    end
    self.m_TempNode1:setContentSize(CCSizeMake(viewSize1.width,height1))
    self.m_TempNode1:setAnchorPoint(ccp(0,0))
    self.m_TempNode1:setPosition(ccp(0,height1))

    self.m_scroll_main:setContentSize(CCSizeMake(self.m_scroll_main:getContentSize().width,height1))
    self.m_scroll_main:setContentOffset(ccp(0,viewSize1.height-height1),true)

    local sort = itemCfg:getNodeWithKey("sort"):toInt();
     -- 1：武器，2：饰品，3：防具，4：鞋子，0：杂物（不可装备）
    local name_str = itemCfg:getNodeWithKey("name"):toStr() .. "(" .. tostring(EQUIP_TYPE_NAME_TABLE["type_" ..tostring(sort)]) .. ")"
    self.m_label_name:setString(name_str)
    self.m_level_label:setString("Lv." ..level);

    local icon = game_util:createEquipIcon(itemCfg)
    if icon then
        local size = self.m_icon_spr:getContentSize();
        icon:setPosition(ccp(size.width*0.5,size.height*0.5));
        self.m_icon_spr:addChild(icon)
        if itemData.openValue then
            icon:setColor(ccc3(71,71,71));
            -- icon:setColor(ccc3(255,0,0));
            local tempBg = tolua.cast(icon:getChildByTag(1),"CCSprite")
            if tempBg then
                tempBg:setColor(ccc3(71,71,71));
                -- tempBg:setColor(ccc3(0,255,0));
            end
        end
    end

--==========
    local suit = itemCfg:getNodeWithKey("suit"):toStr();

    local showFlag = false;
    local suitCount,tempEquipData,_ = game_util:getEquipSuit(suit,self.m_posEquipData, self.m_equipData);
    self.m_suitEquipData = tempEquipData;
    self.m_ccbNode:runAnimations("m_enter_anim_2")
    local suitCfg = getConfig(game_config_field.suit);
    local suitItemCfg = suitCfg:getNodeWithKey(tostring(suit));
    -- local suitItemCfgtb = json.decode(suitCfg:getNodeWithKey(tostring(suit)):getFormatBuffer())
    if suitItemCfg then
        local label_2_title ,label_3_title ,label_4_title = ""

        local label_attr= ""
        local sprite_attr = nil
        local attType  = nil
        local attNum = 0
        local height2= 0

        for i = 2 ,4 do
            if i == 2 then 
                if not self.m_TempNode2:getChildByTag(tonumber(100+i)) then
                    label_2_title = CCLabelTTF:create(tostring("Khi trang bị 2 món:"),TYPE_FACE_TABLE.Arial_BoldMT,12)
                    self.m_TempNode2:addChild(label_2_title,tonumber(100+i))
                else
                    label_2_title = self.m_TempNode2:getChildByTag(tonumber(100+i))
                end
                height2 = height2 + label_2_title:getContentSize().height

                if i <= suitCount then
                    label_2_title:setColor(ccc3(0,255,0))
                else
                    label_2_title:setColor(ccc3(155,155,155))
                end
            end

            if i == 3 then 
                if not self.m_TempNode2:getChildByTag(tonumber(200+i)) then
                    label_2_title = CCLabelTTF:create(tostring("Khi trang bị 3 món:"),TYPE_FACE_TABLE.Arial_BoldMT,12)
                    self.m_TempNode2:addChild(label_2_title,tonumber(100+i))
                else
                    label_2_title = self.m_TempNode2:getChildByTag(tonumber(100+i))
                end
                height2 = height2 + label_2_title:getContentSize().height * 1.5

                if i <= suitCount then
                    label_2_title:setColor(ccc3(0,255,0))
                else
                    label_2_title:setColor(ccc3(155,155,155))
                end
            end

            if i == 4 then 
                if not self.m_TempNode2:getChildByTag(tonumber(300+i)) then
                    label_2_title = CCLabelTTF:create(tostring("Khi trang bị 4 món:"),TYPE_FACE_TABLE.Arial_BoldMT,12)
                    self.m_TempNode2:addChild(label_2_title,tonumber(100+i))
                else
                    label_2_title = self.m_TempNode2:getChildByTag(tonumber(100+i))
                end
                height2 = height2 + label_2_title:getContentSize().height* 1.5

                if i <= suitCount then
                    label_2_title:setColor(ccc3(0,255,0))
                else
                    label_2_title:setColor(ccc3(155,155,155))
                end
            end

            label_2_title:setAnchorPoint(ccp(0,0))
            label_2_title:setPosition(ccp(viewSize2.width *0.05, -height2))

            local effectItem =json.decode(suitItemCfg:getNodeWithKey("effect_" .. i):getFormatBuffer())
            for j = 1, #effectItem do
                if not self.m_TempNode2:getChildByTag(tonumber(1000+i*100 + j)) then
                    sprite_attr = CCSprite:create()
                    self.m_TempNode2:addChild(sprite_attr,tonumber(1000+i*100 + j))
                else
                    sprite_attr = self.m_TempNode2:getChildByTag(tonumber(1000+i*100 + j))
                end

                if not self.m_TempNode2:getChildByTag(tonumber(2000+i*100 + j+1)) then
                    label_attr = CCLabelTTF:create(tostring(""),TYPE_FACE_TABLE.Arial_BoldMT,12)
                    self.m_TempNode2:addChild(label_attr,tonumber(2000+i*100 + j))
                else
                    label_attr = self.m_TempNode2:getChildByTag(tonumber(2000+i*100 + j))
                end

                attType = effectItem[j][1]
                attNum = effectItem[j][2]

                sprite_attr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(PUBLIC_ABILITY_TABLE["ability_" .. attType].icon))
                label_attr:setString(tostring("+"..attNum))
                
                sprite_attr:setAnchorPoint(ccp(1,0))
                label_attr:setAnchorPoint(ccp(0,0))

                if (j%2) == 1 then
                    height2 = height2 + label_attr:getContentSize().height *1.2
                end
                sprite_attr:setPosition(ccp(sprite_attr:getContentSize().width *2  + ((j-1)%2) *0.45 *viewSize2.width, -height2))
                label_attr:setPosition(ccp(sprite_attr:getContentSize().width *2  + ((j-1)%2) *0.45 *viewSize2.width, -height2))

                if i<=suitCount then
                    label_attr:setColor(ccc3(0,255,0))
                    sprite_attr:setColor(ccc3(255,255,255))
                else
                    label_attr:setColor(ccc3(155,155,155))
                    sprite_attr:setColor(ccc3(155,155,155))
                end
            end
        end


        self.m_TempNode2:setContentSize(CCSizeMake(viewSize2.width,height2))
        self.m_TempNode2:setAnchorPoint(ccp(0,0))
        self.m_TempNode2:setPosition(ccp(0,height2))

        self.m_scrollview_ass:setContentSize(CCSizeMake(self.m_scrollview_ass:getContentSize().width,height2))
        -- self.m_scrollview_ass:setContentOffset(ccp(0,viewSize2.height-height2),true)
    end

--=====================


    local m_suit_icon = self.m_ccbNode:spriteForName("m_suit_icon" .. posIndex)
    if m_suit_icon then
        local pX,pY = m_suit_icon:getPosition();
        local tempPos = m_suit_icon:getParent():convertToWorldSpace(ccp(pX,pY));
        self.m_sel_img:setVisible(true);
        self.m_sel_img:setPosition(ccp(pX,pY));
        -- cclog("posIndex = " .. posIndex)
        local suit = itemCfg:getNodeWithKey("suit"):toStr();
        -- cclog("suit = " .. suit)
        local suitCount,tempEquipData,_ = game_util:getEquipSuit(suit,self.m_posEquipData, self.m_equipData);
        -- print("suit info ==== ", json.encode(tempEquipData))
        local equipID = nil
        local equipCfg = getConfig(game_config_field.equip);
        local suitCfg = getConfig(game_config_field.suit);
        local suitItemCfg = suitCfg:getNodeWithKey(tostring(suit));
        -- print("suitItemCfg info ==== ", suitItemCfg:getFormatBuffer())
        if suitItemCfg then
            local part = suitItemCfg:getNodeWithKey("part")
            -- print("part info ==== ", part:getFormatBuffer())
            local partCount = part:getNodeCount();
            equipID = part:getNodeAt(posIndex - 1) and part:getNodeAt(posIndex - 1):toInt() or nil
            -- print("equipID info ==== ", equipID)
        end

        self.m_togetFun = nil

        if tempEquipData[posIndex] then
            if tempEquipData[posIndex].itemData == nil or self.m_openType == 4 then

                self.m_btn_fate:setVisible(false)
                -- cclog("tempEquipData[posIndex].itemData = " .. json.encode(tempEquipData[posIndex].itemData))
                --没有，按钮变成去获得
                local itemData = tempEquipData[posIndex].itemData
                self.m_togetFun = self:getGoToGetEquipFun( equipID )
                if self.m_togetFun then
                    self.m_node_getbtn_bg:setVisible(true)
                else
                    self.m_node_getbtn_bg:setVisible(false)
                end
                self.m_btn_node:setVisible(false);
            else
                if self.fateEquipLock and self.fateEquipLock == true and game_data:isViewShowByID(182) then
                    self.m_btn_fate:setVisible(true)
                else
                    self.m_btn_fate:setVisible(false)
                end
                if self.m_openType == 4 then
                    self.m_togetFun = self:getGoToGetEquipFun( equipID )
                    if  self.m_togetFun then
                        self.m_node_getbtn_bg:setVisible(true)
                    else
                        self.m_node_getbtn_bg:setVisible(false)
                    end
                    self.m_btn_node:setVisible(false);
                else  
                    self.m_btn_node:setVisible(true);
                    self.m_node_getbtn_bg:setVisible(false)
                end

                -- cclog("you zhe ge ", posIndex)
                -- cclog("tempEquipData[posIndex].itemData = " .. json.encode(tempEquipData[posIndex].itemData))
                -- --有，按钮是去强化等等等
            end
        end
    else
        self.m_togetFun = nil
        self.m_node_getbtn_bg:setVisible(false)
    end
end

--[[--
    弹框
]]

function tipNotEnough(isEliteOpen, goto)
    local text = ""
    local chaT = ""
    if goto then
        local chapter_cfg = getConfig(game_config_field.chapter)
        for i=1,#goto do
            local itemCfg = chapter_cfg:getNodeWithKey(tostring(goto[i]))
            print(" itemCfg  info is == ", itemCfg:getFormatBuffer())
            local name = itemCfg:getNodeWithKey("chapter_name"):toStr()
            local space = i==1 and "" or " "
            chaT = chaT .. space .. name
        end
    end

    if isEliteOpen then
        text = "" .. chaT .. "Chưa mở, trang bị rơi ở…" .. chaT 
    else
        text = "Ải Tinh Anh chưa mở, trang bị rơi ở Ải Tinh Anh" .. chaT
    end
    local t_params = 
                    {
                        title = "Nhắc nhở",
                        okBtnCallBack = function(target,event)
                            require("game_ui.game_pop_up_box").close(); 
                        end,   --可缺省
                        text = text,
                        onlyOneBtn = true,          --可缺省
                    }
    require("game_ui.game_pop_up_box").show(t_params);
    -- require("game_ui.game_pop_up_box").showAlertView(msg or "等级不足，升级后解锁新功能");
end


--[[-- 
    获取去获得按钮
]]
function game_equip_info_pop.getGoToGetEquipFun( self, equip_id )
    -- print( "getGoToGetEquipFun equip_id == ", equip_id )
    if not equip_id then return end
    local getFun = nil
    local equip_detail_cfg = getConfig(game_config_field.equip);
    local equip_book_cfg = getConfig(game_config_field.equip_book);
    local equip_book_item_cfg = equip_book_cfg:getNodeWithKey( tostring(equip_id) )
    if equip_book_item_cfg == nil then return end
    local equip_id = equip_book_item_cfg:getNodeWithKey("equip_id"):toStr()
    local itemCfg = equip_detail_cfg:getNodeWithKey(equip_id)
    local gotoS = equip_book_item_cfg:getNodeWithKey("go_to")
    -- print("goto == ", equip_book_item_cfg:getFormatBuffer(), "  --  ")
    local goto = gotoS and json.decode(gotoS:getFormatBuffer())
    if itemCfg then
        -- print("goto == ", goto and json.encode(goto)) 
        if goto and type(goto) == "table" then
            gotoCount = #goto
        end
        local getFun = nil
        if gotoCount >0 then
            -- print(" ======== 1", id)
            local id = nil
            local openCha = game_data:getChapterTabByKey("openDifficult")
            for i=1, gotoCount do
                local ch1 = string.sub(tostring(goto[i]), 1, 3) or "1"
                if not id and openCha[ch1] then
                    id = ch1
                end
            end
            -- print(" ======== 2", id)
            if  not game_button_open:getOpenFlagByBtnId(800) then
            -- print(" ======== 3", id)
                getFun = function ()
                    -- print(  " 精英关卡还没有开启哦！！！  ",  json.encode( goto ) )
                    tipNotEnough(false, goto)
                end
                return getFun
            elseif id then
                -- print( " ididid ", id)
                ch1 = tonumber( id ) or 1
                getFun = function ()
                    local function responseMethod(tag,gameData)
                        game_data:setMapType()
                        game_scene:enterGameUi("map_world_scene",{gameData = gameData, chapterSwitchTo = "hard", assign_hard_chapter = ch1});
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
                end
                return getFun
            else
                -- print( " 关卡还没有开启哦！！！ ", id)
                getFun = function ()
                    -- print(  " 关卡还没有开启哦！！！  ",  json.encode( goto ) )
                    tipNotEnough(true, goto)
                end
                return getFun
            end
        end
    end
    return getFun
end

--[[--
    equipDetail
]]
function game_equip_info_pop.equipDetail(self)
    cclog("================================     game_equip_info_pop.equipDetail()    ==================")
    if self.m_tGameData == nil then return end

    if not self.m_TempNode1  then
        self.m_TempNode1 = CCNode:create()
        self.m_scroll_main:addChild(self.m_TempNode1,1001)
    else
        self.m_TempNode1:removeAllChildrenWithCleanup(true)
    end

    if not self.m_TempNode2 then
        self.m_TempNode2 = CCNode:create()
        self.m_scrollview_ass:addChild(self.m_TempNode2,1002)
    else
        self.m_TempNode2:removeAllChildrenWithCleanup(true)
    end

    -- self.m_TempNode1:removeAllChildrenWithCleanup(true)
    -- self.m_TempNode2:removeAllChildrenWithCleanup(true)

    local viewSize1 = self.m_scroll_main:getViewSize()
    local viewSize2 = self.m_scrollview_ass:getViewSize()
    local height1 ,height2= 0

    local equipCfg = getConfig(game_config_field.equip);
    local itemCfg = equipCfg:getNodeWithKey(tostring(self.m_tGameData.c_id));
    self.attrs = {}

    local function setEquipInfo()
        cclog("=========================  function setEquipInfo()  =========================")
        local level = self.m_tGameData.lv
        local recastlabel1 = nil
        local recastlabel2 = nil
        
        -- 普通属性
        local attrName1,value1,attrName2,value2,icon1,icon2,name1,name2 = game_util:getEquipAttributeValue(itemCfg,level,self.m_tGameData);
        self.attrs[name1] ={value = tonumber(value1),id = PUBLIC_ABILITY_NAME_TABLE[name1]["typeValue"]}
        self.attrs[name2] ={value = tonumber(value2),id = PUBLIC_ABILITY_NAME_TABLE[name2]["typeValue"]}
        

        -- 附魔属性
        if self.m_tGameData.is_enchant then 
            for k,v in pairs(self.m_tGameData.atts) do
                local value = 0
                if self.attrs[k] then
                    value = self.attrs[k]["value"] or 0
                end
                self.attrs[k] = {value = tonumber(v) + value ,id = PUBLIC_ABILITY_NAME_TABLE[k]["typeValue"]}
            end
        end

        -- 打造属性
        if  self.m_tGameData.build_atts then 
            local build_atts = self.m_tGameData.build_atts or {}
            for k,v in pairs(build_atts) do
                local value = 0
                if self.attrs[k] then
                    value = self.attrs[k]["value"] or 0
                end
                self.attrs[k] = {value = tonumber(v) + value ,id = PUBLIC_ABILITY_NAME_TABLE[k]["typeValue"]}
            end
        end

        local outtable = {}
        for k,v in pairs(self.attrs) do
            table.insert(outtable,{name = k, id = v.id ,value = v.value})
        end

        table.sort( outtable, function( a,b ) return a.id<b.id end)

        local icon_num = 1
        for i,v in ipairs(outtable) do
            local itemsp = CCSprite:create()
            self.m_TempNode1:addChild(itemsp)
            itemsp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(PUBLIC_ABILITY_NAME_TABLE[v.name]["icon"]))
            itemsp:setAnchorPoint(ccp(1,0))

            local itemlabel = CCLabelTTF:create(tostring(""),TYPE_FACE_TABLE.Arial_BoldMT,12)
            self.m_TempNode1:addChild(itemlabel)
            itemlabel:setAnchorPoint(ccp(0,0))
            itemlabel:setString(" " .. v.value)
            if icon_num == 1 then 
                height1 = height1 + 1.5* itemlabel:getContentSize().height
            end
            if icon_num ~= 1 then
                height1 = height1 + (icon_num)%2 *itemsp:getContentSize().height
            end
            itemsp:setPosition(ccp(itemsp:getContentSize().width *1.5  + ((icon_num-1)%2) *0.48 *viewSize1.width, -height1))
            itemlabel:setPosition(ccp(itemsp:getContentSize().width *1.5  + ((icon_num-1)%2) *0.48 *viewSize1.width, -height1))

            icon_num = icon_num +1
        end

        -- 重铸属性
        if self.m_is_equip_recast then 
            local tabledata = game_data:getEquipgetconfirmPropTable(self.m_recast_atts,self.recast_bind_id)
            for i=1,#tabledata do
                if not self.m_TempNode1:getChildByTag(tonumber(500+i)) then
                    recastlabel1 = CCLabelTTF:create(tostring(""),TYPE_FACE_TABLE.Arial_BoldMT,12)
                    self.m_TempNode1:addChild(recastlabel1,tonumber(500+i))
                else
                    recastlabel1 = self.m_TempNode1:getChildByTag(tonumber(500+i))
                end

                if not self.m_TempNode1:getChildByTag(tonumber(500+i)) then
                    recastlabel2 = CCLabelTTF:create(tostring(""),TYPE_FACE_TABLE.Arial_BoldMT,12)
                    self.m_TempNode1:addChild(recastlabel2,tonumber(500+i))
                else
                    recastlabel2 = self.m_TempNode1:getChildByTag(tonumber(500+i))
                end

                recastlabel1:setString(tabledata[i][1] )

                height1 = height1 + 1.5* recastlabel1:getContentSize().height

                recastlabel1:setAnchorPoint(ccp(0,0))
                recastlabel1:setPosition(ccp(viewSize1.width *0.05, -height1))

                recastlabel2:setString(tabledata[i][2])
                height1 = height1 + 1.1* recastlabel2:getContentSize().height

                recastlabel2:setAnchorPoint(ccp(0,0))
                recastlabel2:setPosition(ccp(viewSize1.width *0.05, -height1))

                if game_data:isTenEquipInHeroEquipTab(self.m_equipid,tabledata[i][3].."") then
                    recastlabel1:setColor(ccc3(0,255,0))
                    recastlabel2:setColor(ccc3(0,255,0))
                else
                    recastlabel1:setColor(ccc3(155,155,155))
                    recastlabel2:setColor(ccc3(155,155,155))
                end
            end
        end

        -- 2018春节套装属性
        local equip_add1 = itemCfg:getNodeWithKey("equip_add1") and  json.decode(itemCfg:getNodeWithKey("equip_add1"):getFormatBuffer()) or ""
        local occupation1 = itemCfg:getNodeWithKey("occupation1") and  json.decode(itemCfg:getNodeWithKey("occupation1"):getFormatBuffer()) or ""
        local effect =itemCfg:getNodeWithKey("effect"):toStr() --效果
        if effect.."" == "0" then effect = "" end
        local ocdes = itemCfg:getNodeWithKey("des"):toStr() --装备技能描述
        if occupation1 and next(occupation1) then
            local zhiye = {}
            local typename = ""
            for k,v in pairs(occupation1) do
                zhiye[#zhiye+1] = tonumber(v) or 0
                if k ~= 1 then typename = typename .." hay " end
                typename = typename..MAIN_OCCUPATION_TABLE[tonumber(v)+1].name
            end
            local outstr = ""
            if ocdes and ocdes ~= "" then
                -- for k,v in pairs(zhiye) do
                --     local sp =  CCSprite:createWithSpriteFrameName("public_ocupation" .. v .. ".png")
                --     self.m_TempNode1:addChild(sp)
                --     sp:setAnchorPoint(ccp(0,0.9))
                --     sp:setPosition(ccp(viewSize1.width *0.05 + (k+0.7)*sp:getContentSize().width*0.9, -height1))
                -- end
                local pos1 = string.find(ocdes,"occupation")
                local pos2 = string.find(ocdes,"effect")
                local str1 = string.sub(ocdes,0,pos1-1)
                local str2 = ""
                local str3 = ""
                if pos2 then
                    str2 = string.sub(ocdes,pos1+10,pos2-1)
                    str3 = string.sub(ocdes,pos2+6,-1)
                else
                    str2 = string.sub(ocdes,pos1+10,-1)
                end
                outstr = outstr.. typename..str2..effect..str3
                local lbOutstr = CCLabelTTF:create(outstr,TYPE_FACE_TABLE.Arial_BoldMT,12)
                lbOutstr:setDimensions(CCSizeMake(160,110));
                self.m_TempNode1:addChild(lbOutstr)
                lbOutstr:setAnchorPoint(ccp(0,1))
                lbOutstr:setHorizontalAlignment(kCCTextAlignmentLeft)
                lbOutstr:setVerticalAlignment(kCCVerticalTextAlignmentTop)
                lbOutstr:setPosition(ccp(viewSize1.width *0.05, -height1))
                height1 = height1 + 1.5* lbOutstr:getContentSize().height
                local flag = game_data:isEquipInAllHeroEquipTab(self.m_tGameData.id,zhiye) or false
                lbOutstr:setColor(flag and ccc3(255,186,0) or ccc3(155,155,155))
            end
        end

        self.m_TempNode1:setContentSize(CCSizeMake(viewSize1.width,height1))
        self.m_TempNode1:setAnchorPoint(ccp(0,0))
        self.m_TempNode1:setPosition(ccp(0,height1))

        self.m_scroll_main:setContentSize(CCSizeMake(self.m_scroll_main:getContentSize().width,height1))
        self.m_scroll_main:setContentOffset(ccp(0,viewSize1.height-height1),true)
        --====
        local sort = itemCfg:getNodeWithKey("sort"):toInt();
         -- 1：武器，2：饰品，3：防具，4：鞋子，0：杂物（不可装备）
        self.m_label_name:setString(itemCfg:getNodeWithKey("name"):toStr() .. "(" .. tostring(EQUIP_TYPE_NAME_TABLE["type_" ..tostring(sort)]) .. ")");
        self.m_level_label:setString("Lv." ..level);
        local icon = game_util:createEquipIcon(itemCfg)
        if icon then
            local size = self.m_icon_spr:getContentSize();
            icon:setPosition(ccp(size.width*0.5,size.height*0.5));
            self.m_icon_spr:addChild(icon)
        end
    end

    local suit = itemCfg:getNodeWithKey("suit"):toStr();

    if self.m_openType == 12 then -- 从组队而来
        suit = self.suitfromTeam
    end

    if suit ~= "0" then --套装界面
        local showFlag = false;
        local suitCount,tempEquipData,_
        if self.m_openType == 12 then -- 从组队而来
            suitCount,tempEquipData,_ = game_util:getEquipSuit(self.suitfromTeam,self.m_posEquipData, self.m_equipData);
            suitCount = 0
            local equip_id = nil
            for k,v in pairs(self.m_posEquipData) do
                if v~= 0 then
                    local cursuit = json.decode(equipCfg:getNodeWithKey(v..""):getFormatBuffer()).suit
                    if cursuit.."" == self.suitfromTeam.."" then
                        suitCount = suitCount +1
                        tempEquipData[k].itemData = {}
                    end
                end
            end
        else
            suitCount,tempEquipData,_ = game_util:getEquipSuit(suit,self.m_posEquipData, self.m_equipData);
        end
        self.m_suitEquipData = tempEquipData;
        self.m_ccbNode:runAnimations("m_enter_anim_2")
        local suitCfg = getConfig(game_config_field.suit);
        local suitItemCfg = suitCfg:getNodeWithKey(tostring(suit));

        if suitItemCfg then

            local label_2_title ,label_3_title ,label_4_title = ""
            local label_attr= ""
            local sprite_attr = nil
            local attType  = nil
            local attNum = 0

            local height2  = 0 
            for i = 2 ,4 do
                if i == 2 then 
                    if not self.m_TempNode2:getChildByTag(tonumber(100+i)) then
                        label_2_title = CCLabelTTF:create(tostring("Khi trang bị 2 món:"),TYPE_FACE_TABLE.Arial_BoldMT,12)
                        self.m_TempNode2:addChild(label_2_title,tonumber(100+i))
                    else
                        label_2_title = self.m_TempNode2:getChildByTag(tonumber(100+i))
                    end
                    height2 = height2 + label_2_title:getContentSize().height

                    if i <= suitCount then
                        label_2_title:setColor(ccc3(0,255,0))
                    else
                        label_2_title:setColor(ccc3(155,155,155))
                    end
                end

                if i == 3 then 
                    if not self.m_TempNode2:getChildByTag(tonumber(200+i)) then
                        label_2_title = CCLabelTTF:create(tostring("Khi trang bị 3 món:"),TYPE_FACE_TABLE.Arial_BoldMT,12)
                        self.m_TempNode2:addChild(label_2_title,tonumber(100+i))
                    else
                        label_2_title = self.m_TempNode2:getChildByTag(tonumber(100+i))
                    end
                    height2 = height2 + label_2_title:getContentSize().height * 1.5

                    if i <= suitCount then
                        label_2_title:setColor(ccc3(0,255,0))
                    else
                        label_2_title:setColor(ccc3(155,155,155))
                    end
                end

                if i == 4 then 
                    if not self.m_TempNode2:getChildByTag(tonumber(300+i)) then
                        label_2_title = CCLabelTTF:create(tostring("Khi trang bị 4 món:"),TYPE_FACE_TABLE.Arial_BoldMT,12)
                        self.m_TempNode2:addChild(label_2_title,tonumber(100+i))
                    else
                        label_2_title = self.m_TempNode2:getChildByTag(tonumber(100+i))
                    end
                    height2 = height2 + label_2_title:getContentSize().height* 1.5

                    if i <= suitCount then
                        label_2_title:setColor(ccc3(0,255,0))
                    else
                        label_2_title:setColor(ccc3(155,155,155))
                    end
                end

                label_2_title:setAnchorPoint(ccp(0,0))
                label_2_title:setPosition(ccp(viewSize2.width *0.05, -height2))

                local effectItem =json.decode(suitItemCfg:getNodeWithKey("effect_" .. i):getFormatBuffer())
                for j = 1, #effectItem do
                    if not self.m_TempNode2:getChildByTag(tonumber(1000+i*100 + j)) then
                        sprite_attr = CCSprite:create()
                        self.m_TempNode2:addChild(sprite_attr,tonumber(1000+i*100 + j))
                    else
                        sprite_attr = self.m_TempNode2:getChildByTag(tonumber(1000+i*100 + j))
                    end

                    if not self.m_TempNode2:getChildByTag(tonumber(2000+i*100 + j+1)) then
                        label_attr = CCLabelTTF:create(tostring(""),TYPE_FACE_TABLE.Arial_BoldMT,12)
                        self.m_TempNode2:addChild(label_attr,tonumber(2000+i*100 + j))
                    else
                        label_attr = self.m_TempNode2:getChildByTag(tonumber(2000+i*100 + j))
                    end

                    attType = effectItem[j][1]
                    attNum = effectItem[j][2]
                    sprite_attr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(PUBLIC_ABILITY_TABLE["ability_" .. attType].icon))
                    label_attr:setString(tostring("+"..attNum))
                    
                    sprite_attr:setAnchorPoint(ccp(1,0))
                    label_attr:setAnchorPoint(ccp(0,0))

                    if (j%2) == 1 then
                        height2 = height2 + label_attr:getContentSize().height *1.2
                    end
                    sprite_attr:setPosition(ccp(sprite_attr:getContentSize().width *2  + ((j-1)%2) *0.45 *viewSize2.width, -height2))
                    label_attr:setPosition(ccp(sprite_attr:getContentSize().width *2  + ((j-1)%2) *0.45 *viewSize2.width, -height2))

                    if i<=suitCount then
                        label_attr:setColor(ccc3(0,255,0))
                        sprite_attr:setColor(ccc3(255,255,255))
                    else
                        label_attr:setColor(ccc3(155,155,155))
                        sprite_attr:setColor(ccc3(155,155,155))
                    end
                end
            end
            self.m_TempNode2:setContentSize(CCSizeMake(viewSize2.width,height2))
            self.m_TempNode2:setAnchorPoint(ccp(0,0))
            self.m_TempNode2:setPosition(ccp(0,height2))
            self.m_scrollview_ass:setContentSize(CCSizeMake(self.m_scrollview_ass:getContentSize().width,height2))
            self.m_scrollview_ass:setContentOffset(ccp(0,viewSize2.height-height2),true)
            for i=1,4 do
                local m_suit_icon = self.m_ccbNode:spriteForName("m_suit_icon" .. i)
                local size = m_suit_icon:getContentSize();
                if tempEquipData[i] then
                    local tempEquipCfg = tempEquipData[i].itemCfg;
                    if tempEquipCfg then
                        local icon = game_util:createEquipIcon(tempEquipCfg)
                        if icon then
                            icon:setPosition(ccp(size.width*0.5,size.height*0.5));
                            m_suit_icon:addChild(icon)
                            if tempEquipData[i].itemData == nil then
                                icon:setColor(ccc3(71,71,71));
                                --没有的显示灰色
                                local tempBg = tolua.cast(icon:getChildByTag(1),"CCSprite")
                                if tempBg then
                                    tempBg:setColor(ccc3(71,71,71));
                                end
                            else
                                if self.m_tGameData.id == tempEquipData[i].itemData.id then
                                    showFlag = true;
                                    self:equipInfo(i);
                                end
                            end
                        end
                    end
                end
            end
            self.m_suit_name_label:setString(suitItemCfg:getNodeWithKey("name"):toStr());
        else
            self.m_suit_name_label:setString("");
        end
        if showFlag == false then
            setEquipInfo();
        end
    else
        self.m_ccbNode:runAnimations("m_enter_anim_1")
        setEquipInfo();
    end
end

--[[--
    刷新ui
]]
function game_equip_info_pop.refreshUi(self)
    self:equipDetail();

    -- print("self.m_openType ==  ", self.m_openType, self.m_togetFun)
    self.m_node_getbtn_bg:setVisible(false)
    if self.m_openType == 1 then
        self.m_btn_node:setVisible(false);
        -- self.m_btn_node:setVisible(true);
    elseif self.m_openType == 11 then
        if self.m_togetFun then
            self.m_node_getbtn_bg:setVisible(true)
        end
        self.m_btn_node:setVisible(false);
    elseif self.m_openType == 4 then
        self.m_btn_node:setVisible(false);
        self.m_node_getbtn_bg:setVisible(true)
    else
        self.m_btn_node:setVisible(true);
    end
    if not self.m_togetFun then
        self.m_node_getbtn_bg:setVisible(false)
    end
    self.m_unbind_btn:setVisible(false)
    if self.fateEquipLock and self.fateEquipLock == true and game_data:isViewShowByID(182) then
        if self.curEquipData and self.curEquipData.bind_card and self.curEquipData.bind_card ~= "" then
            self.m_unbind_btn:setVisible(true)
        else
            self.m_unbind_btn:setVisible(false)

        end
        self.m_btn_fate:setVisible(true)

    else
        self.m_btn_fate:setVisible(false)

    end
    if self.isnoneBtn then
        self.m_btn_node:setVisible(false)
        self.m_btn_fate:setVisible(false)
        self.m_node_getbtn_bg:setVisible(false)
        self.touchLayer:setTouchEnabled(false)
    end

    -- 仓库存入 itemData.bind_card or itemData.bind_card ~= "" 
    local equipCfg = getConfig(game_config_field.equip);
    local itemCfg = equipCfg:getNodeWithKey(tostring(self.m_tGameData.c_id));
    local canStore = true
    if self.m_tGameData.bind_card and self.m_tGameData.bind_card ~= "" then -- 装备已绑定
        canStore = false
    end
    if game_data:isEquipInHeroEquipTab(self.m_tGameData.id) then -- 该装备已被主角穿戴
        canStore = false
    end
    local existFlag,_ = game_data:equipInEquipPos(itemCfg:getNodeWithKey("sort"):toInt(),self.m_tGameData.id)
    if existFlag then -- 该装备已上阵
        canStore = false
    end
    local bonusEquipFlag,_ = game_data:equipInBonus(itemCfg:getNodeWithKey("sort"):toInt(),self.m_tGameData.id)
    if bonusEquipFlag then -- 该装备在阵法中
        canStore = false
    end
    local godflag = game_data:godequipInEquipPos(itemCfg:getNodeWithKey("sort"):toInt(),self.m_tGameData.id)
    if godflag then -- 该装备在神域中
        canStore = false
    end
    local existFlag_wormhole = game_data:isinEquipWormholeByid(self.m_tGameData.id)
    if existFlag_wormhole then -- 该装备在虫洞中
        canStore = false
    end

    if self.enterType ~= "storeHouse_get" and self.enterType ~= "storeHouse_save" then
        canStore = false
    end
    self.btn_storeToHouse:setVisible(canStore)
end

--[[--
    初始化
]]
function game_equip_info_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.fateEquipLock = t_params.fateEquipLock
    self.m_tGameData = t_params.tGameData;
    self.m_fromUi = t_params.fromUi;
    self.m_openType = t_params.openType or 1;
    self.m_callBack = t_params.callBack;
    self.m_posEquipData = t_params.posEquipData;
    self.m_equipData = t_params.equipData
    self.selHeroId = t_params.selHeroId
    self.m_recast_atts = t_params.tGameData.recast_atts
    self.m_equipid = t_params.tGameData.id
    self.tempId = t_params.tempId
    self.m_is_equip_recast = t_params.tGameData.is_equip_recast;
    self.recast_bind_id = t_params.tGameData.recast_bind
    self.isnoneBtn = t_params.isnoneBtn
    self.suitfromTeam = t_params.suitfromTeam

    if self.m_openType == 11 then
        self.m_togetFun = self:getGoToGetEquipFun( self.m_tGameData.c_id )
    end
    self.enterType = t_params.enterType
end

--[[--
    创建ui入口并初始化数据
]]
function game_equip_info_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_equip_info_pop;