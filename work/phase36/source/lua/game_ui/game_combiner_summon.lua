--召唤兽
local game_combiner_summon ={
    m_material_node_tab = nil,
    material_tab = nil,
    MyMaterial_tab = nil,
    MyselNum = nil,
    Canuse = nil,
    m_name_sp = nil,
    m_hero_info = nil,
    skillIconTab = nil,
}

--[[--
    销毁ui
]]
function game_combiner_summon.destroy( self )
    -- body
    cclog("-----------------game_combiner_summon destroy-----------------");
   self.m_material_node_tab = nil; --材料node
   self.material_tab = nil; --需要的材料c_id
   self.MyMaterial_tab = nil; --拥有的要消耗的卡牌材料
   self.MyselNum = nil;--神兽编号
   self.Canuse = nil;--是否可以召唤
   self.m_name_sp = nil;
   self.m_hero_info = nil;--说明
   self.skillIconTab = nil;
    
end

--[[--
    返回
]]
function game_combiner_summon.back(self,type)
    -- local function endCallFunc()
    --     self:destroy();
    -- end
    -- game_scene:enterGameUi("game_combiner_main",{gameData = nil},{endCallFunc = endCallFunc});

    local function responseMethod(tag,gameData)
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_combiner_main",{gameData = gameData},{endCallFunc = endCallFunc});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("combiner_index"), http_request_method.GET, nil,"combiner_index")  
end
--[[--
    读取ccbi创建ui
]]
function game_combiner_summon.createUi(self)
    local ccbNode = luaCCBNode:create();
    local combiner_skill_detail_cfg = getConfig(game_config_field.combiner_skill_detail)
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 2 then --召唤兽
            self:selectCanUse();
            if self.Canuse == true then
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    local reward = data:getNodeWithKey("rewards")
                    local dataTable = json.decode(data:getFormatBuffer()) or {}
                    if dataTable.beast_info then
                        self.m_GameData = dataTable.beast_info;
                    end
                    game_data:setOneCombinerData(dataTable.beast_info,self.MyselNum);

                    game_util:rewardTipsByJsonData(reward);
                    game_scene:enterGameUi("game_combiner_detail",{gameData = self.m_GameData,MyselNum = self.MyselNum})
                end
                local params = {};
                params.beast = self.MyselNum;
                for k,v in pairs (self.MyMaterial_tab or {}) do
                    if params.materials == nil then
                        params.materials =  v .. "_" 
                    else
                        params.materials = params.materials .. v .. (k == 5 and "" or "_") ;
                    end

                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("combiner_open_fable_beast"), http_request_method.GET, params,"combiner_open_fable_beast")
            else
                game_util:addMoveTips({text = "Đủ thẻ nguyên liệu sẽ triệu hồi!"});
            end
        elseif btnTag == 11 then -- 一技能

            local combiner_skill_cfg = json.decode(combiner_skill_detail_cfg:getNodeWithKey(tostring(self.MyselNum.. 1 .."0")):getFormatBuffer())
            
            game_scene:addPop("game_combiner_skill_info_pop",{combiner_skill_cfg = combiner_skill_cfg})
        elseif btnTag == 12 then -- 二技能
            local combiner_skill_cfg = json.decode(combiner_skill_detail_cfg:getNodeWithKey(tostring(self.MyselNum.. 2 .."0")):getFormatBuffer())
            
            game_scene:addPop("game_combiner_skill_info_pop",{combiner_skill_cfg = combiner_skill_cfg})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_Monster_Summoning_weizhaohuan.ccbi");
    self.m_hero_node = ccbNode:nodeForName("m_hero_node")
    self.m_touch_layer = ccbNode:layerForName("m_touch_layer")
    self.m_material_node = ccbNode:nodeForName("m_material_node")
    self.m_name_node = ccbNode:nodeForName("m_name_node")
    self.m_hero_info = ccbNode:nodeForName("m_hero_info")
    self.m_skill_node1 = ccbNode:nodeForName("m_skill_node1")
    self.m_skill_node2 = ccbNode:nodeForName("m_skill_node2")
    self.skillIconTab = {self.m_skill_node1,self.m_skill_node2}
    local m_material_node,m_mate_tips = nil,nil;
    for i=1,5 do
        m_material_node = ccbNode:spriteForName("m_material_node_" .. i);
        m_mate_tips = ccbNode:labelBMFontForName("m_name_label_" .. i);
        self.m_material_node_tab[i] = {m_material_node = m_material_node,m_mate_tips = m_mate_tips}
    end
    self:initMaterialLayerTouch(self.m_touch_layer);
    self:createMaterialIcon();
    return ccbNode;
end

--[[--
    材料层
]]
function game_combiner_summon.initMaterialLayerTouch(self,formation_layer)
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
                    
                    local material_cid = self.material_tab[k];
                    local btnCallFunc = function( target,event )
            
                    end
                    local itemOnClick = function (typeName,id)
                        if typeName == "unload" then

                        elseif typeName == "exchanged" then
                            self.MyMaterial_tab[k] = id
                        end
                    end
                    local cardsData = game_data:getTableCardsData()
                    game_scene:addPop("game_hero_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,openType = 5,material_cid = material_cid ,material_id = self.MyMaterial_tab[k]})
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



function game_combiner_summon:refreshUi( )
    self:addSkillIcon();
end

function game_combiner_summon.addSkillIcon( self )
    -- body
    local combiner_skill_detail_cfg = getConfig(game_config_field.combiner_skill_detail)
    local combiner_skill_cfg  = nil;
    local skillIconName = nil
    if self.MyselNum then
        for i=1,2 do
            combiner_skill_cfg = json.decode(combiner_skill_detail_cfg:getNodeWithKey(tostring(self.MyselNum.. i.."0")):getFormatBuffer())
            if combiner_skill_cfg.skill_icon then
                skillIconName = combiner_skill_cfg.skill_icon; --对的
            else
                skillIconName = "public_zi"
            end
            local skillIcon = CCSprite:create("icon/" .. skillIconName .. ".png");
            if skillIcon then
                skillIcon:setAnchorPoint(ccp(0,0))
                skillIcon:setScale(0.48)
                skillIcon:setPosition(ccp(3,3));
                self.skillIconTab[i]:addChild(skillIcon);
            end
        end
        
    end 
end

function game_combiner_summon:createMaterialIcon( )

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
            tempImg:setColor(ccc3(0,0,0))
            tempImg:setPosition(ccp(0,20))
            self.m_hero_node:addChild(tempImg)
        end
    end
    local labelsize = CCSizeMake(self.m_hero_info:getContentSize().width,self.m_hero_info:getContentSize().height);
    local scrollView = CCScrollView:create(labelsize);
    -- scrollView:setPositionY(5)
    scrollView:setDirection(kCCScrollViewDirectionVertical);
    if OneCfg and OneCfg.story then
        local story = OneCfg.story or ""
        local hero_info = game_util:createRichLabelTTF({text = story,dimensions = labelsize,textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = nil,color = ccc3(221,221,192)})
        hero_info:setAnchorPoint(ccp(0, 0));
        scrollView:addChild(hero_info)
        self.m_hero_info:addChild(scrollView,2,2);
    else
    end

    local material_node_size = self.m_material_node:getContentSize();
        for i=1,#self.m_material_node_tab do
            local itemTab = self.m_material_node_tab[i]
            itemTab.m_material_node:removeAllChildrenWithCleanup(true);
            itemTab.m_material_node:setVisible(true)
            itemTab.m_mate_tips:setVisible(true)
            local itemId = tostring(self.material_tab[i])
             --cclog2(itemId,"1234567887653")
            local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(itemId);
            local itemName = itemConfig:getNodeWithKey("name"):toStr() or "" --材料卡名字
            local tempIcon = game_util:createCardIconByCid(itemId,false)
            if tempIcon then
                local tempSize = itemTab.m_material_node:getContentSize();
                tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                itemTab.m_material_node:addChild(tempIcon)
                -- cclog2(itemName,"itemNameitemName")
                itemTab.m_mate_tips:setString(tostring(itemName))
                local isShow = false;
                local MyMaterical = {};
                if self.MyMaterial_tab[i] ~= "0" and self.MyMaterial_tab[i] ~= 0 then
                     MyMaterical = self:lua_string_split(self.MyMaterial_tab[i]);
                    if itemId == MyMaterical[1] then
                        isShow = true;
                    else
                        isShow = false;
                    end
                else
                    isShow = false;
                end
                
                if isShow == false then
                    tempIcon:setColor(ccc3(81,81,81))
                    itemTab.m_mate_tips:setOpacity(255)
                else
                    itemTab.m_mate_tips:setOpacity(0)
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

--截取cid
function game_combiner_summon.lua_string_split(self,str)
    local sub_str_tab = {};
    for mu_id in string.gmatch(str, "(%d+)-*") do
        table.insert(sub_str_tab, mu_id)
    end
    return sub_str_tab;
end

function game_combiner_summon.selectOwnMaterial( self )
    -- body
    for k,v in pairs(self.material_tab) do
        local cardtab = {};
        cardtab = game_data:getCardsDataByCombinerTemple(v);
        game_data:cardsSortByTypeNameWithTable("lv",cardtab);
        local count = tonumber(#cardtab) or 1
        if cardtab[count] then
            table.insert(self.MyMaterial_tab,k,cardtab[count]);
        else
            table.insert(self.MyMaterial_tab,k,"0");
        end
    end
end

function game_combiner_summon.selectCanUse( self )

    for k,v in pairs(self.MyMaterial_tab) do
        if v ~= "0" and v ~= 0 then
            self.Canuse = true;
        else
            self.Canuse = false; 
        end
    end

end



--[[--
    初始化
]]
function game_combiner_summon.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    self.m_material_node_tab = {}
    self.material_tab = {}
    self.MyMaterial_tab = {}
    self.MyselNum = t_params.MyselNum or 0;
    self.Canuse = false;
    self.skillIconTab = {};
    local myData = game_data:getCombinerData();
    self.m_GameData = myData[tostring(self.MyselNum)]
    -- cclog2(self.m_GameData,"1234567887653")
    if self.m_GameData.beast_gods then
        local beast_gods = self.m_GameData.beast_gods
        for k,v in pairs(beast_gods) do
            table.insert(self.material_tab,k)
        end
    end
    self:selectOwnMaterial();
    
end

--[[--
    创建ui入口并初始化数据
]]
function game_combiner_summon.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_combiner_summon;

