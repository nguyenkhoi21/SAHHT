--召唤兽出战
local game_combiner_gobattle ={
    m_root_layer = nil,
    m_close_btn = nil,
    table_view_node = nil,
    m_color_layer = nil,
    m_ok_btn = nil,
    m_material_node_tab = nil, -- 可出战的神兽
    m_material_skill_tab = nil, --添加的技能
    openTab = nil,
    status = nil, --标记技能是否可用
    flag = nil, --标记神兽出战状态
    skillidtab = nil, --神兽技能id
    fightFlag = nil,--神兽出战列表
}

--[[--
    销毁ui
]]
function game_combiner_gobattle.destroy( self )
    -- body
    cclog("-----------------game_combiner_gobattle destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.table_view_node = nil;
    self.m_color_layer = nil;
    self.m_ok_btn = nil;
    self.m_material_node_tab = nil;
    self.openTab = nil;
    self.m_material_skill_tab = nil;
    self.status = nil;
    self.flag = nil;
    self.skillidtab = nil;
    self.fightFlag = nil;
end

--[[--
    返回
]]
function game_combiner_gobattle.back(self,type)
    game_scene:removePopByName("game_combiner_gobattle");
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_combiner_gobattle.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 2 then
            local tempSkill = {};
            local tempIdTab = {};
            local paramsTab = nil;
            local params = {};
            if #self.m_material_skill_tab > 0 then
                for i=1,#self.m_material_skill_tab do
                    if self.m_material_skill_tab[i] then
                        table.insert(tempSkill,self.m_material_skill_tab[i][1])
                        table.insert(tempIdTab,self.m_material_skill_tab[i][2])
                    end
                end
                for i=1,#tempIdTab do
                    if paramsTab == nil then
                        paramsTab = tempIdTab[i] .. "_" .. tempSkill[i][1] 
                        if tempSkill[i][2] then
                            paramsTab = paramsTab .. "_" .. tempSkill[i][2]
                        end
                    else
                        paramsTab = paramsTab .. "&fight_beasts=" .. tempIdTab[i] .. "_" .. tempSkill[i][1] 
                        if tempSkill[i][2] then
                            paramsTab = paramsTab .. "_" .. tempSkill[i][2]
                        end
                    end
                end 
                -- cclog2(paramsTab,"paramsTabparamsTabparamsTabparamsTab")
                params.fight_beasts = paramsTab
                local function responseMethod( tag,gameData )
                    game_data:setCombinerfightData(tempIdTab);
                    self:back();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("combiner_update_fight_beast"), http_request_method.GET, params,"combiner_update_fight_beast")
        
                -- cclog2(params.fight_beasts,"params.fight_beasts=================")
            else
                -- game_util:addMoveTips({text = "请选择要出战的神兽！"})
                local function responseMethod( tag,gameData )
                    game_data:setCombinerfightData(tempIdTab);
                    self:back();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("combiner_update_fight_beast"), http_request_method.GET, nil,"combiner_update_fight_beast")
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_Monster_Summoning_gobattle.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.table_view_node = ccbNode:layerForName("m_list_view_bg")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_skill_list = ccbNode:layerForName("m_skill_list")
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-11,true);
    self.m_root_layer:setTouchEnabled(true);
    
    -- self:initMaterialLayerTouch(self.table_view_node)
    -- self.m_color_layer:setVisible(false)
    return ccbNode;
end

function game_combiner_gobattle:refreshCombinerInfo( index )
    local myData = game_data:getCombinerData();
    -- cclog2(myData,"myDatamyDatamyData")
    for k,v in pairs(self.m_material_node_tab) do
        local num = self.m_material_node_tab[k][1]
        local combiner_quality = myData[tostring(num)].quality;
        local Com_cfg = getConfig(game_config_field.combiner_advanced):getNodeWithKey(combiner_quality);
        local combiner_info = Com_cfg and json.decode(Com_cfg:getFormatBuffer()) or {}
        if self.m_material_node_tab[k][2] then
            if self.m_material_node_tab[k] then
                if self.m_material_node_tab[index] and self.m_material_node_tab[index][2] == 0 then
                    local skillTab = combiner_info.skill;
                    for i=1,#self.m_material_skill_tab do
                        if self.m_material_skill_tab[i] and self.m_material_skill_tab[i][2] == self.m_material_node_tab[index][1] then
                            table.remove(self.m_material_skill_tab,i)
                        end
                    end
                elseif self.m_material_node_tab[index] and self.m_material_node_tab[index][2] == 1 then
                    if k == index then
                        local skillTab = combiner_info.skill;
                        table.insert(self.m_material_skill_tab,{skillTab,self.m_material_node_tab[index][1]})
                    end
                end
                
             
            end
        end
    end
    self:createSkillIconList();
    -- cclog2(self.m_material_skill_tab,"self.m_material_skill_tabself.m_material_skill_tab")
    
end

function game_combiner_gobattle.createMonster(self,parentNode)
    self.m_selListItem = nil;
    local totalItem =  #self.m_material_node_tab --可出战的神兽个数
    local params = {};
    local viewSize = parentNode:getContentSize()
    params.viewSize = viewSize;
    params.row = 1;--行  
    if #self.m_material_node_tab < 4 then
        params.column = #self.m_material_node_tab;
    else
        params.column = 4; --列
    end
    params.totalItem = totalItem;
    params.offset =  -5
    params.isShow = false
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.direction = kCCScrollViewDirectionHorizontal
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = self:createHeroListItemByCCB(nil,index);
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local cardId = self.m_material_node_tab[index +1][1]
            local isOpen = self.m_material_node_tab[index +1][2]
            local itemData = {c_id = cardId}
            -- cclog2(itemData,"itemData---------")
            if itemData ~= nil then
                self:setHeroListItemInfoByTable(ccbNode,itemData,index);
            end
            local m_color_layer = ccbNode:layerColorForName("m_color_layer")
            if tonumber(isOpen) == 1 then
                m_color_layer:setVisible(false)
            else
                m_color_layer:setVisible(true)
            end
            if index < totalItem then
               
            end
               
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if index >= totalItem then return end;
        if eventType == "ended" and item then
        cclog2(index,"index=========")

        self.status = index +1
        local flag = 0;
        for k,v in pairs(self.m_material_node_tab) do
            if self.m_material_node_tab[k][2] == 1 then
                flag = flag + 1
            end
        end
        local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
        local m_color_layer = tolua.cast(ccbNode:objectForName("m_color_layer"),"CCLayerColor");
        if self.m_material_node_tab[index +1] and self.m_material_node_tab[index +1][2] == 0 then
            if flag < 2 then 
                self.m_material_node_tab[index +1][2] = 1
                m_color_layer:setVisible(false);
            else
                game_util:addMoveTips({text = "Không quá 2 thần thú ra trận"});
            end
        elseif self.m_material_node_tab[index +1] and self.m_material_node_tab[index +1][2] == 1 then
            self.m_material_node_tab[index +1][2] = 0
            m_color_layer:setVisible(true);
        end
        
        self:refreshCombinerInfo(self.status);
        
        end
    end
    return TableViewHelper:createGallery2(params);

end

function game_combiner_gobattle.setHeroListItemInfoByTable(self,ccbNode,heroDataTable,index)
    local cardId = heroDataTable.c_id;
    local itemConfig = getConfig(game_config_field.combiner):getNodeWithKey(cardId);
    ccbNode:nodeForName("m_info_node"):setVisible(true);
    local m_img_node = tolua.cast(ccbNode:objectForName("m_img_node"),"CCNode");
    m_img_node:removeAllChildrenWithCleanup(true);
    local img = itemConfig:getNodeWithKey("combine_ani"):toStr();
    -- local rgb = itemConfig:getNodeWithKey("rgb_sort"):toInt();
    local imgItem
    if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(img .. ".png")) then
        imgItem = CCSprite:createWithSpriteFrameName(img .. ".png")
    else
        imgItem = CCSprite:create("God_beast/" .. img .. ".png")
    end
    local imgNodeSize = m_img_node:getContentSize();
    if imgItem then
        imgItem:setPosition(ccp(imgNodeSize.width*0.5,imgNodeSize.height* 0.5))
        m_img_node:addChild(imgItem);
    end
    local m_color_layer = ccbNode:layerColorForName("m_color_layer")
    m_color_layer:setVisible(true)   
    if self.m_material_node_tab[cardId] and self.m_material_node_tab[cardId][2] == 1 then
        m_color_layer:setVisible(false)
    end
    -- if self.skillidtab[cardId] and  self.skillidtab[cardId][1] then
    --     local skill = self.skillidtab[cardId][1]
    --     local skillConfig = getConfig(game_config_field.combiner_skill_detail):getNodeWithKey(skill);
    --     local skillIconName = skillConfig:getNodeWithKey("skill_icon"):toStr();
    --     local skillIcon = CCSprite:create("icon/" .. skillIconName .. ".png");    -- img
    --     local m_skill_img1 = tolua.cast(ccbNode:objectForName("m_skill_img1"),"CCNode");
    --     -- local NodeSize = m_skill_img1:getContentSize();
    --     skillIcon:setAnchorPoint(ccp(0,0))
    --     skillIcon:setScale(0.37)
    --     skillIcon:setPosition(ccp(3,2));
    --     m_skill_img1:addChild(skillIcon)
    -- end
    -- if self.skillidtab[cardId] and  self.skillidtab[cardId][2] then
    --     local skill = self.skillidtab[cardId][2]
    --     local skillConfig = getConfig(game_config_field.combiner_skill_detail):getNodeWithKey(skill);
    --     local skillIconName = skillConfig:getNodeWithKey("skill_icon"):toStr();
    --     local skillIcon = CCSprite:create("icon/" .. skillIconName .. ".png");
    --     local m_skill_img2 = tolua.cast(ccbNode:objectForName("m_skill_img2"),"CCNode");
    --     -- local NodeSize = m_skill_img2:getContentSize();
    --     skillIcon:setAnchorPoint(ccp(0,0))
    --     skillIcon:setScale(0.37)
    --     skillIcon:setPosition(ccp(3,2));
    --     -- m_skill_img2:setPosition(ccp(NodeSize.width,NodeSize.height* 0.6))
    --     m_skill_img2:addChild(skillIcon)
    -- end
        for j=1,2 do
            if self.skillidtab[index+1] and  self.skillidtab[index+1][j] then
                local skill = self.skillidtab[index+1][j]
                local skillConfig = getConfig(game_config_field.combiner_skill_detail):getNodeWithKey(skill);
                local skillIconName = skillConfig:getNodeWithKey("skill_icon"):toStr();
                local skillIcon = CCSprite:create("icon/" .. skillIconName .. ".png");    -- img
                local m_skill_img1 = tolua.cast(ccbNode:objectForName("m_skill_img" .. j),"CCNode");
                -- local NodeSize = m_skill_img1:getContentSize();
                skillIcon:setAnchorPoint(ccp(0,0))
                skillIcon:setScale(0.37)
                skillIcon:setPosition(ccp(3,2));
                m_skill_img1:addChild(skillIcon)
            end
        end
    

end

function game_combiner_gobattle.createSkillIcon( self,parentNode)
    -- self.m_material_skill_tab 
    local tempSkill = {};
    for i=1,#self.m_material_skill_tab do
        for j=1,2 do
            if self.m_material_skill_tab[i][j] then
                table.insert(tempSkill,self.m_material_skill_tab[i][1][j])
            end
        end
    end
    local totalItem =  #tempSkill --可出战的神兽个数
    local params = {};
    local viewSize = parentNode:getContentSize()
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = #tempSkill; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.direction = kCCScrollViewDirectionHorizontal
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then 
            cell = CCTableViewCell:new()
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_Monster_Summoning_gobattle_item2.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local skillConfig = getConfig(game_config_field.combiner_skill_detail):getNodeWithKey(tempSkill[index+1]);
            local skillIconName = skillConfig:getNodeWithKey("skill_icon"):toStr();
            local m_skill_node = tolua.cast(ccbNode:objectForName("m_skill_node"),"CCNode");
            local imgItem = CCSprite:create("icon/" .. skillIconName .. ".png");
            imgItem:setAnchorPoint(ccp(0,0))
            imgItem:setScale(0.43)
            imgItem:setPosition(ccp(3,3));
            imgItem:setAnchorPoint(ccp(0,0))
            m_skill_node:addChild(imgItem)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        end
    end
    return TableViewHelper:create(params);

end

function game_combiner_gobattle.refreshUi( self )
    self.table_view_node:removeAllChildrenWithCleanup(true);
    self.table_view_node:addChild(self:createMonster(self.table_view_node))
    
        for k,v in pairs(self.m_material_node_tab) do
            if self.m_material_node_tab[k] then
                if self.m_material_node_tab[k][2] and self.m_material_node_tab[k][2] == 1 then
                    self:refreshCombinerInfo(tonumber(k));
                end
            end
        end
    
    
end

function game_combiner_gobattle.createSkillIconList( self )
    
    self.m_skill_list:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createSkillIcon(self.m_skill_list);
    self.m_skill_list:addChild(self.m_tableView);
end

function game_combiner_gobattle.createHeroListItemByCCB(self,heroData,index)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_Monster_Summoning_gobattle_item.ccbi");
    self.m_color_layer = ccbNode:layerColorForName("m_color_layer")
    local imgItem = CCSprite:createWithSpriteFrameName("Monster_Summoning_di4.png")
    self.m_color_layer:addChild(imgItem);
    local size = self.m_color_layer:getContentSize();
    imgItem:setPosition(ccp(size.width/2,size.height/2))
    self.m_color_layer:setVisible(true)
    ccbNode:setAnchorPoint(ccp(0.5,0.5));
    ccbNode:setScale(1)
    local sp_sprite  = ccbNode:spriteForName("m_spr_bg")
    sp_sprite:setVisible(true)
    if ccbNode ~= nil and heroData ~= nil then
        self:setHeroListItemInfoByTable(ccbNode,heroData,index);
    end
    return ccbNode
end



--[[--
    初始化
]]
function game_combiner_gobattle.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    -- cclog2(self.gameData,"self.gameDataself.gameDataself.gameDatas")
    self.m_material_node_tab = {}
    self.openTab = t_params.openTab or {};
    -- cclog2(self.openTab,"self.openTabself.openTabself.openTab")
    self.m_material_skill_tab = {};
    self.skillidtab = {};
    self.m_tableView = nil;
    self.status = 0;
    self.flag = 0;
    self.fightFlag = game_data:getCombinerfightData() or {};
    -- cclog2(self.fightFlag,"self.self.self.self.")
    local myData = game_data:getCombinerData();
    for k,v in pairs(self.openTab) do
        if tonumber(v) == 1 then
            table.insert(self.m_material_node_tab,{k,0})
        end
    end
    -- cclog2(self.m_material_node_tab,"self.m_material_node_tabself.m_material_node_tab")
    for k,v in pairs(self.m_material_node_tab) do
        for i=1,#self.fightFlag do
            if #self.fightFlag >0 and tonumber(self.fightFlag[i]) == tonumber(self.m_material_node_tab[k][1]) then
                self.m_material_node_tab[k][2] = 1
            end
        end
    end
    
    -- cclog2(self.m_material_node_tab,"self.m_material_node_tabself.m_material_node_tab")
    for k,v in pairs(self.m_material_node_tab) do
        local num = self.m_material_node_tab[k][1]
        local combiner_quality = myData[tostring(num)].quality;
        local Com_cfg = getConfig(game_config_field.combiner_advanced):getNodeWithKey(combiner_quality);
        local combiner_info = Com_cfg and json.decode(Com_cfg:getFormatBuffer()) or {}
        table.insert(self.skillidtab,combiner_info.skill) --所有可用的技能id
    end
     -- cclog2(self.skillidtab,"self.skillidtabself.skillidtab")
end

--[[--
    创建ui入口并初始化数据
]]
function game_combiner_gobattle.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_combiner_gobattle;

