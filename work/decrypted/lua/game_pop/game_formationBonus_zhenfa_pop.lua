--北斗七星
local game_formationBonus_zhenfa_pop = {
    m_tGameData = nil,
    m_formation_bonus = nil,
    m_tab_ui = nil,
    m_tab_curId = nil,
    m_pos = nil,
    m_label_curValue = nil,
    popBackFunC = nil
};
--[[--
    销毁ui
]]
function game_formationBonus_zhenfa_pop.destroy(self)
    -- body
    cclog("-----------------game_formationBonus_zhenfa_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_formation_bonus = nil;
    self.m_tab_ui = nil;
    self.m_tab_curId = nil;
    self.m_pos = nil;
    self.m_label_curValue = nil;
    self.popBackFunC = nil;

end
--[[--
    返回
]]
function game_formationBonus_zhenfa_pop.back(self,type)
    local params = {}
    params.pos = self.m_pos - 1
    local str = ""
    for i=1,8 do
        if self.m_tab_curId[i] then
            str = str .. self.m_tab_curId[i] .. (i == 8 and "" or "_") 
        else
            str = str .. 0 .. (i == 8 and "" or "_") 
        end
    end
    self.m_tGameData[tostring(self.m_pos-1)] = self.m_tab_curId
    game_data:setFormationBonusAdditionByJsonData(self.m_tGameData)
    params.cards = str
    if self.popBackFunC and tolua.type(self.popBackFunC) == "function" then
        self.popBackFunC()
    end
    if params.cards then 
        function responseMethod(tag,gameData)
            game_scene:removePopByName("game_formationBonus_zhenfa_pop")
            self:destroy()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_set_formation_bonus_addition"), http_request_method.GET, params,"cards_set_formation_bonus_addition")
    else
        game_scene:removePopByName("game_formationBonus_zhenfa_pop")
        self:destroy()
    end
end
--[[--
    读取ccbi创建ui
]]
function game_formationBonus_zhenfa_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag ==== ")
        if btnTag == 1 then--返回
            self:back()
        elseif btnTag == 2 then--自动添加
            self:autoAdd()
        end
    end
    ccbNode:registerFunctionWithFuncName("onBtnClick",onBtnClick);
    ccbNode:openCCBFile("ccb/ui_formation_bonus_pop.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_label_curValue = ccbNode:labelTTFForName("m_label_curValue")
    local m_close_btn  = ccbNode:controlButtonForName("m_close_btn")
    local m_btn_autoAdd  = ccbNode:controlButtonForName("m_btn_autoAdd")
    m_btn_autoAdd:setTag(2)
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    m_btn_autoAdd:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    local m_node_icon,m_sp_line = nil

    self.m_tab_ui = {}
    for i=1,8 do
        m_node_icon = ccbNode:nodeForName("m_node_icon" .. i)
        if i < 7 then
            m_sp_line = ccbNode:spriteForName("m_sp_line" .. i)
            m_sp_line:setVisible(false)
            self.m_tab_ui[i] = {m_node_icon = m_node_icon,m_sp_line = m_sp_line}
        else
            self.m_tab_ui[i] = {m_node_icon = m_node_icon}
        end
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
function game_formationBonus_zhenfa_pop.createIconAnim( self,parentNode )
    local function onAnimSectionEnd( animNode, theId,theLabelName )
         animNode:playSection(theLabelName);
    end
    local anim = game_util:createBlenderAnim("anim_zhenfajiacheng_effect2",1,true);
    anim:registerScriptTapHandler(onAnimSectionEnd)
    anim:playSection("impact");
    parentNode:addChild(anim,10,9)
end
function game_formationBonus_zhenfa_pop.createIconAnim2( self,parentNode )
    local function onAnimSectionEnd( animNode, theId,theLabelName )
         animNode:playSection(theLabelName);
    end
    local anim = game_util:createBlenderAnim("anim_zhenfajiacheng_effect1",1,true);
    anim:registerScriptTapHandler(onAnimSectionEnd)
    anim:playSection("impact");
    parentNode:addChild(anim)
end
function game_formationBonus_zhenfa_pop.createLineAnim( self,i )
    -- self.m_tab_ui[i].m_sp_line:setAnchorPoint(ccp(0,0.5))
    self.m_tab_ui[i].m_sp_line:setVisible(false)
    local arr = CCArray:create();
    local scaleTo1 = CCScaleTo:create(0.1,0)
    local function delyFunc2()
        self.m_tab_ui[i].m_sp_line:setVisible(true)
    end
    local scaleTo2 = CCScaleTo:create(0.5,1)
    arr:addObject(scaleTo1)
    arr:addObject(CCCallFunc:create(delyFunc2))
    arr:addObject(scaleTo2)
    self.m_tab_ui[i].m_sp_line:runAction(CCSequence:create(arr))

    
end
function game_formationBonus_zhenfa_pop.autoAdd( self )
    local cardtab = {}
    self.m_tGameData[tostring(self.m_pos-1)] = {0,0,0,0,0,0,0,0}
    game_data:setFormationBonusAdditionByJsonData(self.m_tGameData)
    cardtab = game_data:getCardsDataByBonus(self.m_pos);
    game_data:cardsSortByTypeNameWithTable("default",cardtab);
    local length = game_util:getTableLen(cardtab)
    self.m_tab_curId = {}
    for i=1,8 do
        local cardid = cardtab[length-i+1] or 0
        self.m_tab_curId[i] = cardid
    end
    self.m_tGameData[tostring(self.m_pos-1)] = self.m_tab_curId
    game_data:setFormationBonusAdditionByJsonData(self.m_tGameData)
    self:createStar()
    self:getAddRate()
    -- body
end
function game_formationBonus_zhenfa_pop.createStar( self,typeName )
    local StarData = self.m_formation_bonus["1"].card
    local length = game_util:getTableLen(StarData)
    local iconSize = self.m_tab_ui[1].m_node_icon:getContentSize()
    local function onBtnClick( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 999 then
            game_util:addMoveTips({text = "Thêm theo thứ tự"})
        else
            local btnCallFunc = function( target,event )
                    
            end
            local itemOnClick = function (typeName,id)
                if typeName == "exchanged" then
                    self.m_tab_curId[btnTag] = id
                    self:refreshUi("exchanged")
                elseif typeName == "unload" then
                    table.remove(self.m_tab_curId,btnTag)
                    self:refreshUi("unload")
                end
                self.m_tGameData[tostring(self.m_pos-1)] = self.m_tab_curId
                game_data:setFormationBonusAdditionByJsonData(self.m_tGameData)
                cclog2(game_data:setFormationBonusAdditionByJsonData(),"game_formationBonus_zhenfa_pop   self.m_tGameData ==== ")

            end
            game_scene:addPop("game_hero_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,openType = 6,pos = btnTag}) 
        end
        
    end
    for i=1,8 do
        self.m_tab_ui[i].m_node_icon:removeAllChildrenWithCleanup(true)

        if self.m_tab_curId and next(self.m_tab_curId) then
            local card = self.m_tab_curId[i]
            local _,itemCfg = game_data:getCardDataById(tostring(card));
            local tempHeadIcon = game_util:createCardIconByCfg(itemCfg)
            if tempHeadIcon then
                tempHeadIcon:setPosition(ccp(iconSize.width*0.5,iconSize.height*0.5));
                tempHeadIcon:setScale(0.75)
                if game_util:getTableLen(self.m_tab_curId) == 8 then
                    self:createIconAnim2(self.m_tab_ui[i].m_node_icon)
                end
                self.m_tab_ui[i].m_node_icon:addChild(tempHeadIcon,10,12);
                -- if game_util:getTableLen(self.m_tab_curId) < 8 then
                    self:createIconAnim(self.m_tab_ui[i].m_node_icon)
                -- end
                -- self:createIconAnim(self.m_tab_ui[i].m_node_icon)
            end
        end
        local button = game_util:createCCControlButton("public_weapon.png","",onBtnClick)
        button:setAnchorPoint(ccp(0.5,0.5))
        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
        button:setZoomOnTouchDown(false)
        button:setPosition( ccp(iconSize.width*0.5,iconSize.height*0.5) )
        button:setOpacity(0)
        
        if i <= #self.m_tab_curId + 1 then 
            button:setTag(i)
        else
            button:setTag(999)
        end
        self.m_tab_ui[i].m_node_icon:addChild(button)
        if i<7 then
            if i < #self.m_tab_curId and self.m_tab_curId[i] ~= 0  then
                if i == #self.m_tab_curId-1 and typeName ~= "unload" then
                    self:createLineAnim(i)
                else
                    self.m_tab_ui[i].m_sp_line:setVisible(true)
                end
            else
                self.m_tab_ui[i].m_sp_line:setVisible(false)
            end

        end
    end
end
function game_formationBonus_zhenfa_pop.getAddRate( self )
    local length = game_util:getTableLen(self.m_tab_curId)
    local addRate = 0 
    for i=1,length do
        if self.m_tab_curId[i] and self.m_tab_curId[i] ~= 0 then
            addRate = addRate + self.m_formation_bonus[tostring(i)].add_ability
        end
    end
    self.m_label_curValue:setString(tostring(addRate) .. "%")
    local tempTab = {}
    tempTab[self.m_pos] = addRate
    game_data:setFormationBounsData_AddTable(tempTab,self.m_pos)
end

--[[--
    刷新ui
]]
function game_formationBonus_zhenfa_pop.refreshUi(self,types)
    if types then
        self:createStar(types)
    else
        self:createStar()
    end
    self:getAddRate()


end
--[[--
    初始化
]]
function game_formationBonus_zhenfa_pop.init(self,t_params)
    t_params = t_params or {};
    -- if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
    --     self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    -- end
    local pos = t_params.pos or nil
    self.m_pos = pos or 1
    if pos then 
        self.m_tGameData  = game_data:getFormationBonusAdditionByJsonData()
        self.m_tab_curId = self.m_tGameData[tostring(pos-1)] or {}
    end
    self.m_formation_bonus = getConfig(game_config_field.formation_bonus);
    self.m_formation_bonus = json.decode(self.m_formation_bonus:getFormatBuffer()) or {}
    self.popBackFunC = t_params.popBackFunC;
    
end
--[[--
    创建ui入口并初始化数据
]]
function game_formationBonus_zhenfa_pop.create(self,t_params)
    self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi();
    return  m_popUi;
end
return game_formationBonus_zhenfa_pop;