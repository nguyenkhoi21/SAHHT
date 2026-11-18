--召唤兽详情
local game_combiner_detail ={
    M_quality = nil,
    material_tab = nil,
    m_touch_layer = nil,
    m_material_node = nil,
    m_material_node_tab = nil,
    beast_ability = nil,
    quality_config = nil,
    MyselNum = nil,
    m_name_title = nil,
    m_skill_node = nil,
    btnCallFunc = nil,
    m_chongsheng_btn=nil,
}

--[[--
    销毁ui
]]
function game_combiner_detail.destroy( self )
    -- body
    cclog("-----------------game_combiner_detail destroy-----------------");
   self.M_quality = nil;
   self.material_tab = nil;
   self.m_touch_layer = nil;
   self.m_material_node = nil;
   self.m_material_node_tab = nil;
   self.beast_ability = nil;
   self.quality_config = nil; --材料卡品阶
   self.MyselNum = nil;
   self.m_name_title = nil;
   self.m_skill_node = nil;
   self.btnCallFunc = nil;
   self.m_chongsheng_btn=nil;
end

--[[--
    返回
]]
function game_combiner_detail.back(self,type)

    local function responseMethod(tag,gameData)
        local function endCallFunc()
            if self.btnCallFunc then
                self.btnCallFunc()
            end
            self:destroy();
        end
        game_scene:enterGameUi("game_combiner_main",{gameData = gameData},{endCallFunc = endCallFunc});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("combiner_index"), http_request_method.GET, nil,"combiner_index")    
end
--[[--
    读取ccbi创建ui
]]
function game_combiner_detail.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 34 then --详情
            game_scene:addPop("game_active_limit_detail_pop",{enterType = "176"})
        elseif btnTag == 31 then --进阶
            local btnCallFunc = function( target,event )
                self:refreshUi();
            end
            game_scene:addPop("game_combiner_advancement",{gameData = nil,selNum = self.MyselNum,btnCallFunc = btnCallFunc})
        elseif btnTag == 32 then --升级
            local btnCallFunc = function( target,event )
                self:refreshUi();
            end
            game_scene:addPop("game_combiner_up",{gameData = nil,selNum = self.MyselNum,btnCallFunc = btnCallFunc})
        --TODO RIBIRTH
        elseif btnTag == 33 then --神兽重生
            local btnCallFunc = function( target,event )
                self:refreshUi();
            end
            game_scene:addPop("game_combiner_rebirth_pop",{gameData = nil,selNum = self.MyselNum,btnCallFunc = btnCallFunc})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_Monster_Summoning_zhaohuan.ccbi");
    self.m_hero_node = ccbNode:nodeForName("m_hero_node")
    self.m_touch_layer = ccbNode:layerForName("m_touch_layer")
    self.m_material_node = ccbNode:nodeForName("m_material_node")
    self.m_hero_lv = ccbNode:labelTTFForName("m_hero_lv")
    self.Hp_lab = ccbNode:labelTTFForName("m_num_lab1")
    self.speed_lab = ccbNode:labelTTFForName("m_num_lab5")
    self.matk_lab = ccbNode:labelTTFForName("m_num_lab4")
    self.patk_lab = ccbNode:labelTTFForName("m_num_lab3")
    self.def_lab = ccbNode:labelTTFForName("m_num_lab2")
    self.m_name_node = ccbNode:nodeForName("m_name_node")
    self.m_skill_node = ccbNode:nodeForName("m_skill_node")

    self.m_chongsheng_btn=ccbNode:controlButtonForName("m_chongsheng_btn")
    if game_data:isViewOpenByID(191) then  --重生开关控制 
        self.m_chongsheng_btn:setVisible(true)
    else
        self.m_chongsheng_btn:setVisible(false)
    end

    local m_material_node,m_mate_tips = nil,nil;
    for i=1,5 do
        m_material_node = ccbNode:spriteForName("m_material_node_" .. i);
        m_mate_tips = ccbNode:labelBMFontForName("m_name_label_" .. i);
        self.m_material_node_tab[i] = {m_material_node = m_material_node,m_mate_tips = m_mate_tips}
    end
    
    self:initMaterialLayerTouch(self.m_touch_layer);
    

    return ccbNode;
end

--[[--
    材料层
]]
function game_combiner_detail.initMaterialLayerTouch(self,formation_layer)
    local tempItem,selItem = nil ,nil;
    local realPos = nil;
    local tag = nil;
    local function onTouchBegan(x, y)
        selItem = nil;
        realPos = self.m_touch_layer:convertToNodeSpace(ccp(x,y));
        for k,v in pairs(self.m_material_node_tab) do
            tempItem = v.m_material_node
            if tempItem:boundingBox():containsPoint(realPos) then
                selItem = tempItem;
                break;
            end
        end
        return true
    end
    
    local function onTouchMoved(x, y)
    end
    
    local function onTouchEnded(x, y)
        realPos = self.m_touch_layer:convertToNodeSpace(ccp(x,y));
        if selItem and selItem:boundingBox():containsPoint(realPos) then
            for k,v in pairs(self.m_material_node_tab) do
                if v.m_material_node:isVisible() and v.m_material_node:boundingBox():containsPoint(realPos) then
                    local btnCallFunc = function( target,event )
                        self:refreshUi();
                    end
                    local material_cid = self.material_tab[k];
                    local num_id = self.quality_config[k];
                    local M_quality = self.M_quality[k];
                    game_scene:addPop("game_combiner_heroup",{btnCallFunc = btnCallFunc,material_cid = material_cid,num_id = num_id,quality=M_quality,gameData = self.m_GameData,MyselNum = self.MyselNum})
                    
                    -- local itemOnClick = function (typeName,id)
                    --     if typeName == "unload" then

                    --     elseif typeName == "exchanged" then
                    --         self.MyMaterial_tab[k] = id
                    --     end
                    -- end
                    -- local cardsData = game_data:getTableCardsData()
                    -- game_scene:addPop("game_hero_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,openType = 5,material_cid = material_cid ,material_id = self.MyMaterial_tab[k]})
                    break;
                end
            end
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY)
    formation_layer:setTouchEnabled(true)
end

function game_combiner_detail:createMaterialIcon( )

    if self.m_name_node and self.MyselNum then
        local tempName
        if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("Monster_Summoning_title".. self.MyselNum .. ".png") then
            tempName = CCSprite:createWithSpriteFrameName("Monster_Summoning_title".. self.MyselNum .. ".png")
        else
            tempName = CCSprite:create("God_beast/" .. "Monster_Summoning_title".. self.MyselNum .. ".png")
        end
        tempName:setAnchorPoint(ccp(0.5,0.5))
        self.m_name_node:removeAllChildrenWithCleanup(true)
        self.m_name_node:addChild(tempName)
    end
    local combinerCfg = getConfig(game_config_field.combiner):getNodeWithKey(tostring(self.MyselNum));
    local OneCfg = json.decode(combinerCfg:getFormatBuffer()) or {}
    if OneCfg and OneCfg.img then
        local fileName = OneCfg.img
        local tempImg = CCSprite:create("img/" .. fileName .. ".png");
        if tempImg then
            self.m_hero_node:addChild(tempImg)
        end
    end

    self.m_hero_lv:setString("Lv." .. self.m_GameData.level)
    if self.m_GameData.hp and self.m_GameData.speed and self.m_GameData.matk and self.m_GameData.patk and self.m_GameData.def then
        self.Hp_lab:setString(self.m_GameData.hp);
        self.speed_lab:setString(self.m_GameData.speed);
        self.matk_lab:setString(self.m_GameData.matk);
        self.patk_lab:setString(self.m_GameData.patk);
        self.def_lab:setString(self.m_GameData.def);
    end
    local material_node_size = self.m_material_node:getContentSize();
        for i=1,#self.m_material_node_tab do
            local itemTab = self.m_material_node_tab[i]
            itemTab.m_material_node:removeAllChildrenWithCleanup(true);
            itemTab.m_material_node:setVisible(true)
            itemTab.m_mate_tips:setVisible(true)
            local itemId = tostring(self.material_tab[i])
            local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(itemId);
            local itemName = itemConfig:getNodeWithKey("name"):toStr() or "" --材料卡名字
            local tempIcon = game_util:createCombinerCardIconByCid(itemId,false)
            if tempIcon then
                local tempSize = itemTab.m_material_node:getContentSize();
                tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                itemTab.m_material_node:addChild(tempIcon)
                -- cclog2(itemName,"itemNameitemName")
                itemTab.m_mate_tips:setString(tostring(itemName))
                local super_quality_1 = self.M_quality[i] or 0;
                local qualityTab = super_quality_1 > 0 and HERO_QUALITY_COLOR_TABLE_3[super_quality_1 +1]
                if qualityTab then
                    local tempIconSize = tempIcon:getContentSize();
                    local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
                    img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
                    tempIcon:addChild(img1,-1,-1)
                end
            else
                -- itemTab.m_mate_tips:setString(tostring(itemName))
                -- if itemCount == 0 then
                --     itemTab.m_mate_tips:setOpacity(255)
                -- else
                --     itemTab.m_mate_tips:setOpacity(0)
                -- end
            end
        end
end



function game_combiner_detail:refreshUi( )

    self:refreshCombinerDate();
    
    self:createMaterialIcon();
    self.m_skill_node:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createSkillIconTableView(self.m_skill_node:getContentSize());
    self.m_skill_node:addChild(tableViewTemp);
end

--[[--
    创建列表
]]
function game_combiner_detail.createSkillIconTableView(self,viewSize)
    local combiner_skill_detail_cfg = getConfig(game_config_field.combiner_skill_detail)
    local MySkillNum = self.m_GameData.skill or {};

    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = #MySkillNum; --列
    params.totalItem = #MySkillNum
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_Monster_Summoning_gobattle_item2.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setScale(1.5)
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then
            local combiner_skill_cfg = json.decode(combiner_skill_detail_cfg:getNodeWithKey(tostring(MySkillNum[index +1])):getFormatBuffer())
            -- cclog2(itemData,"itemData---------")
            -- cclog2(combiner_skill_cfg,"combiner_skill_cfgcombiner_skill_cfg")
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_skill_node = tolua.cast(ccbNode:objectForName("m_skill_node"),"CCNode");
            local skillIconName = "public_zi"
            if combiner_skill_cfg.skill_icon then
                skillIconName = combiner_skill_cfg.skill_icon; --对的
            else
                skillIconName = "public_zi"
            end
            
            local skillIcon = CCSprite:create("icon/" .. skillIconName .. ".png");
            if skillIcon then
                skillIcon:setAnchorPoint(ccp(0,0))
                skillIcon:setScale(0.43)
                skillIcon:setPosition(ccp(3,3));
                m_skill_node:addChild(skillIcon);
            end

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local combiner_skill_cfg = json.decode(combiner_skill_detail_cfg:getNodeWithKey(tostring(MySkillNum[index +1])):getFormatBuffer())
            game_scene:addPop("game_combiner_skill_info_pop",{combiner_skill_cfg = combiner_skill_cfg})
        end
    end
    return TableViewHelper:create(params);
end


function game_combiner_detail.setSkillListItemInfoByTable( self,ccbNode,skillData)
    -- body
    -- local skillIconName = skillData.skill_icon or "public_zi.png";
    local skillIconName = "public_zi.png"
    local skillIcon = CCSprite:createWithSpriteFrameName(skillIconName)
    local m_skill_node = tolua.cast(ccbNode:objectForName("m_skill_node"),"CCNode");
    m_skill_node:addChild(skillIcon);
end

function game_combiner_detail.refreshCombinerDate( self )
    local myCombinerDate = game_data:getCombinerData();
    local MyData = myCombinerDate[tostring(self.MyselNum)]
    self.m_GameData = MyData;
    self.material_tab = {}
    self.M_quality = {}
    self.quality_config = {}
    if self.m_GameData.beast_gods then
        local beast_gods = self.m_GameData.beast_gods
        for k,v in pairs(beast_gods) do
            table.insert(self.material_tab,k)
            table.insert(self.M_quality,v.quality)
            table.insert(self.quality_config,v.quality_config)
        end
    end
end

--[[--
    初始化
]]
function game_combiner_detail.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    self.m_GameData = {};
    self.m_material_node_tab = {}
    self.material_tab = {}
    self.M_quality = {}
    self.quality_config = {}
    self.beast_ability = {}
    self.MyselNum = t_params.MyselNum
    self.btnCallFunc = t_params.btnCallFunc
    
end

--[[--
    创建ui入口并初始化数据
]]
function game_combiner_detail.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_combiner_detail;

