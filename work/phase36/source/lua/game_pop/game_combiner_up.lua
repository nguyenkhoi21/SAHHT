--召唤兽升级
local game_combiner_up ={
	m_layer_progress_bar = nil,
    maxExp = nil,
    m_material_id_table = nil,
    m_material_node = nil,
    m_add_btn = nil,
    m_up_btn = nil,
    m_node_progress_bar = nil,
    TouchLayer = nil,
    state = nil,
    m_list_view_bg = nil,
    AllMaterialTab = nil,
    m_curPageMaterial = nil,
    m_no_material_tips = nil,
}

--[[--
    销毁ui
]]
function game_combiner_up.destroy( self )
	-- body
	cclog("-----------------game_combiner_up destroy-----------------");
   self.m_layer_progress_bar = nil;
   self.maxExp = nil;
   self.m_material_id_table = nil;
   self.m_material_node = nil;
   self.m_add_btn = nil;
   self.m_up_btn = nil;
   self.m_node_progress_bar = nil;
   self.TouchLayer = nil;
   self.state = nil;
   self.m_list_view_bg = nil;
   self.AllMaterialTab = nil;
   self.m_curPageMaterial = nil;
   self.m_no_material_tips = nil;
end

--[[--
    返回
]]
function game_combiner_up.back(self,type)
    game_scene:removePopByName("game_combiner_up");
    if self.btnCallFunc then
        self.btnCallFunc()
    end
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_combiner_up.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 2 then
            if #self.m_material_id_table > 0 then
                local function responseMethod( tag,gameData )
                    local data = gameData:getNodeWithKey("data")
                    local dataTable = json.decode(data:getFormatBuffer()) or {}
                    game_data:setOneCombinerData(dataTable.beast_info,self.MyselNum)
                    -- cclog2(dataTable,"dataTabledataTable")
                    self.state = 2;
                    self:refreshUi()
                    self:responseSuccess()
                end
                local params = {}
                params.beast = self.MyselNum
                for k,v in pairs (self.m_material_id_table or {}) do
                    if params.materials == nil then
                        params.materials =  v .. "_" 
                    else
                        params.materials = params.materials .. v .. (k == #self.m_material_id_table and "" or "_") ;
                    end

                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("combiner_add_beast_exp"), http_request_method.GET, params,"combiner_add_beast_exp")
            else
                game_util:addMoveTips({text = "Chọn nguyên liệu!"});
            end
        elseif btnTag == 3 then
            self.state = 1;
            self:createMaterial();
            self:refreshFilterCardTableView();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_Monster_Summoning_up.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_material_node = ccbNode:nodeForName("m_material_node")
    self.m_add_btn = ccbNode:controlButtonForName("m_add_btn")
    self.m_up_btn = ccbNode:controlButtonForName("m_up_btn")
    self.m_level_lab = ccbNode:labelTTFForName("m_level_lab")
    self.m_Mylevel_lab = ccbNode:labelTTFForName("m_Mylevel_lab")
    self.TouchLayer = ccbNode:layerForName("formation_layer")
    self.patk_lab = ccbNode:labelTTFForName("m_num_lab1")
    self.def_lab = ccbNode:labelTTFForName("m_num_lab5")
    self.speed_lab = ccbNode:labelTTFForName("m_num_lab4")
    self.matk_lab = ccbNode:labelTTFForName("m_num_lab3")
    self.Hp_lab = ccbNode:labelTTFForName("m_num_lab2")
    self.m_hero_icon = ccbNode:nodeForName("m_hero_icon")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_no_material_tips = ccbNode:spriteForName("m_no_material_tips")
    -- 进度条
    self.m_layer_progress_bar = ccbNode:spriteForName("m_layer_progress_bar")
    self.m_node_progress_bar = ccbNode:nodeForName("m_node_progress_bar")
    local m_material_node,m_mate_tips = nil,nil;
    for i=1,6 do
        m_material_node = ccbNode:nodeForName("m_material_node_" .. i);
        m_mate_tips = ccbNode:spriteForName("m_mate_tips_" .. i);
        self.m_material_node_tab[i] = {m_material_node = m_material_node,m_mate_tips = m_mate_tips}
    end
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_add_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_up_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-11,true);
    self.m_root_layer:setTouchEnabled(true);
    
    local combiner_cfg = getConfig(game_config_field.combiner_base);
    local Mylevel = self.m_GameData["level"]
    local Myevo = self.m_GameData["evo"] or 0
    local combinerBase = json.decode(combiner_cfg:getNodeWithKey(Mylevel):getFormatBuffer()) or {}
    local needExp = combinerBase.exp or 0;
    self.m_level_lab:setString(Myevo .. "/" .. needExp)
    self:initHerolLayerTouch(self.TouchLayer);
    return ccbNode;
end

--[[--
    刷新
]]
function game_combiner_up.refreshFilterCardTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil
    self:FilterAllMaterial();
    self.m_tableView = self:createFilterTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--
    创建筛选的列表
]]
function game_combiner_up.createFilterTableView(self,viewSize)
   
    local showHeroTable = self.AllMaterialTab or {};
    -- local cardsCount = #showHeroTable;
    local showHeroTable = {};
    for k,v in pairs(self.AllMaterialTab) do
        if not self.m_famousAllData[v] then
            showHeroTable[#showHeroTable + 1] = v
        end
    end
    local cardsCount = #showHeroTable;
    if cardsCount == 0 then
        self.m_no_material_tips:setVisible(true);
    end
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 11
    params.totalItem = cardsCount--totalItem;
    params.showPageIndex = self.m_curPageMaterial;
    params.direction = kCCScrollViewDirectionVertical;
    params.itemActionFlag = true;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createHeroListItemByCCB2();
            ccbNode:setScale(0.9)
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < cardsCount then
                local itemData,_ = game_data:getCardDataById(showHeroTable[cardsCount - index]);
                if itemData then
                    local heroId = itemData.id;
                    game_util:setHeroListItemInfoByTable2(ccbNode,itemData);
                    local flag,k = game_util:idInTableById(tostring(itemData.id),self.m_material_id_table)
                    if flag then
                        local m_sel_img = ccbNode:spriteForName("sprite_selected")
                        m_sel_img:setVisible(true);
                        local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                        sprite_back_alpha:setVisible(true);
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell) .. " ; cell:getUserData() = " .. tolua.type(cell:getUserData()));
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
                local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("sprite_selected")
                local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                local itemData,_ = game_data:getCardDataById(showHeroTable[cardsCount - index]);
                local heroId = tostring(itemData.id);
                local flag,k = game_util:idInTableById(heroId,self.m_material_id_table)
                if flag and k ~= nil then
                    -- cclog("remove select material hero id ==========" .. heroId);
                    table.remove(self.m_material_id_table,k);
                    m_sel_img:setVisible(false);
                    sprite_back_alpha:setVisible(false);
                    self:refreshFilterCardTableView();
                    self:refreshMaterial();
                    self:getCurrentPower();
                else
                    if #self.m_material_id_table < 6 then
                        -- cclog("add select material hero id ==========" .. heroId);
                        table.insert(self.m_material_id_table,heroId);
                        m_sel_img:setVisible(true);
                        sprite_back_alpha:setVisible(true);
                        self:refreshMaterial();
                        self:getCurrentPower();
                    end
                end
                -- print("---------------------------------m_material_id_table-----start");
                -- table.foreach(self.m_material_id_table,print);
                -- print("--------------------------------m_material_id_table------end");
        elseif eventType == "longClick" and cell then
            local itemData = showHeroTable[cardsCount - index].heroData;
            local function callBack(typeName)
                typeName = typeName or ""
                if typeName == "refresh" then
                    self:refreshFilterCardTableView();
                end
            end
            game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 1,callBack = callBack})
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPageMaterial = curPage;
    end
    return TableViewHelper:create(params);
end

function game_combiner_up.setInformation( self )
    -- body
    local combinerCfg = getConfig(game_config_field.combiner);
    local Mycombiner = combinerCfg:getNodeWithKey(tostring(self.MyselNum));
    if Mycombiner then
        local combinerDate = Mycombiner and json.decode( Mycombiner:getFormatBuffer() ) or {}
        self.patk_lab:setString("+ " .. combinerDate.growth_patk)
        self.def_lab:setString("+ " .. combinerDate.growth_def)
        self.speed_lab:setString("+ " .. combinerDate.growth_speed)
        self.matk_lab:setString("+ " .. combinerDate.growth_matk)
        self.Hp_lab:setString("+ " .. combinerDate.growth_hp)
        local iconName = combinerDate.icon or "icon_bg_zuzhou"
        local icon = CCSprite:create("icon/" .. iconName .. ".png");
        icon:setAnchorPoint(ccp(0,0));
        self.m_hero_icon:addChild(icon)
    end
    local Mylevel = self.m_GameData["level"]
    self.m_Mylevel_lab:setString("Lv."..Mylevel);
    
end

--[[--
    
]]
function game_combiner_up.responseSuccess(self)
    local function responseEndFunc()
        -- self.m_root_layer:setTouchEnabled(false);
        game_sound:playUiSound("up_success")
        self.m_material_id_table = {};
        self:refreshUi();
        local ccbNode = game_util:animSuccessCCBAnim(nil,"lv_up")
        ccbNode:setPosition(ccp(-150,-150))
        self.m_material_node:addChild(ccbNode);
        
    end
    
    local rempveIndex = #self.m_material_id_table
    local materialCount = rempveIndex;
    local animFile = "anim_icon_disappear"
    local function particleMoveEndCallFunc()
        cclog("tempParticle particleMoveEndCallFunc --------------------------")
    end
    for i=1,6 do
        local m_material_node = self.m_material_node_tab[i].m_material_node;
        if i <= materialCount then 
            local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
            if mAnimNode then
                local function onAnimSectionEnd(animNode, theId,theLabelName)
                    if theLabelName == "impact1" then
                        animNode:playSection("impact2");
                        local tempNode = m_material_node:getChildByTag(10)
                        if tempNode then
                            tempNode:setVisible(false);
                        end
                    else
                        mAnimNode:removeFromParentAndCleanup(true);
                        rempveIndex = rempveIndex - 1;
                        if rempveIndex == 0 then
                            responseEndFunc();
                            -- self.m_ccbNode:runAnimations("success_anim")
                        end
                    end
                end
                mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
                mAnimNode:playSection("impact1");
                local tempSize = m_material_node:getContentSize();
                mAnimNode:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                m_material_node:addChild(mAnimNode,100,100);
                local tempParticle = game_util:createParticleSystemQuad({fileName = "particle_fly_up"});
                if tempParticle then
                    game_util:addMoveAndRemoveAction({node = tempParticle,startNode = m_material_node,endNode = self.m_hero_icon,endCallFunc = particleMoveEndCallFunc,moveTime = 0.5,delayTime = 0.5})
                    game_scene:getPopContainer():addChild(tempParticle)
                end
            else
                rempveIndex = rempveIndex - 1;
                if rempveIndex == 0 then
                    responseEndFunc();
                    -- self.m_ccbNode:runAnimations("success_anim")
                end
            end
        else
            
        end
    end
end

--[[--
    确定强化
]]
function game_combiner_up.onSureFunc(self)
    
    local function sendRequest()
        local function responseMethod(tag,gameData)
            if gameData == nil then
                -- self.m_root_layer:setTouchEnabled(false);
                return;
            end
            self:responseSuccess();
        end
        --major=100&metal=101&
        -- local params = "major=" .. self.m_selHeroId .. "&pos=" .. self.m_up_skill_index
        -- table.foreach(self.m_material_id_table,function(k,v)
        --     params = params .. "&metal=" .. v;
        -- end);
        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_card_skill_levelup"), http_request_method.GET, params,"cards_card_skill_levelup",true,true)
    end
end

function game_combiner_up.FilterAllMaterial(self)
    -- body
    local Qidtemp = game_data:getCardsDataByCombinerQuality(3);
    game_data:cardsSortByTypeNameWithTable("quality",Qidtemp);
    self.AllMaterialTab = Qidtemp
end

function game_combiner_up.createMaterial( self )
    -- body
    self.m_material_id_table = {};
    local Qidtemp = game_data:getCardsDataByCombinerQuality(3);
    game_data:cardsSortByTypeNameWithTable("quality",Qidtemp);
    local count = #Qidtemp ;
    for i = (count -5),count do
        self.m_material_id_table[i-count+6] = Qidtemp[i];
    end
    self:refreshMaterial();
end

--[[--
    刷新材料列表
]]
function game_combiner_up.refreshMaterial(self)
    
    local tempHeadIcon = nil;
    local m_material_node,m_mate_tips = nil,nil;
    local tempSize = nil;
    for index=1,#self.m_material_node_tab do
        m_material_node = self.m_material_node_tab[index].m_material_node;
        m_mate_tips = self.m_material_node_tab[index].m_mate_tips;
        m_material_node:removeAllChildrenWithCleanup(true);
        if self.m_material_id_table[index] ~= nil then
            local card_id = tostring(self.m_material_id_table[index])
            local cardData,cardCfg = game_data:getCardDataById(card_id)
            tempHeadIcon = game_util:createCardIconByCfg(cardCfg,cardData);
            if tempHeadIcon then
                tempSize = m_material_node:getContentSize();
                tempHeadIcon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                m_material_node:addChild(tempHeadIcon,10,10);
            end
            m_mate_tips:setVisible(false);
        else
            m_mate_tips:setVisible(true);
            if self.m_selHeroId ~= nil then

            end
        end
    end
    if self.state == 2 then
    else
        self:getCurrentPower( );
    end
    
end

--[[--
    技能层
]]
function game_combiner_up.initHerolLayerTouch(self,formation_layer)
    local items = formation_layer:getChildren();
    local itemCount = items:count();
    local tempItem = nil;
    local realPos = nil;
    local tag = nil;
    local function onTouchBegan(x, y)
        return true
    end
    local function onTouchMoved(x, y)
    end
    local function onTouchEnded(x, y)
        -- cclog("initHeroLayerTouch onTouchEnded --")
        
        tempItem = nil;
        tag = nil;
        realPos = self.m_material_node:convertToNodeSpace(ccp(x,y));
        for k,v in pairs(self.m_material_node_tab) do
            if v.m_material_node:boundingBox():containsPoint(realPos) then
                -- cclog("m_material_node click ==== " .. k)
                if self.m_material_id_table[k] ~= nil then
                    table.remove(self.m_material_id_table,k);
                    self:refreshMaterial();
                    self:refreshFilterCardTableView();
                    self:getCurrentPower();
                end
                
                break;
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 22)
    formation_layer:setTouchEnabled(true)
end

--[[--
    获得添加得材料的总经验值表
]]

function game_combiner_up.getCurrentPower( self )
    local point = 0
    local chainEquipTab = {}
    local hero_cid,heroData,hero_price,all_price = nil,nil,nil,0;
    local hero_cfg = getConfig(game_config_field.character_detail);
    local combiner_cfg = getConfig(game_config_field.combiner_base);
    if #self.m_material_id_table > 0 then
        for k,v in pairs(self.m_material_id_table) do
            hero_cid = self:lua_string_split(v)
            heroData = json.decode(hero_cfg:getNodeWithKey(hero_cid):getFormatBuffer() ) or {}
            hero_price = heroData.call_price;
            if hero_price then
                all_price = all_price + hero_price;
            end
            -- cclog2(all_price,"all_price=========" .. k)
        end
    end
    local Mylevel = self.m_GameData["level"]
    local combinerBase = json.decode(combiner_cfg:getNodeWithKey(Mylevel):getFormatBuffer()) or {}
    local needExp = combinerBase.exp or 0;
    self.maxExp = needExp;
    local Myevo = self.m_GameData["exp"] or 0
    self.evo = tonumber(all_price) + tonumber(Myevo);
    self.curExp = math.min(self.evo,tonumber(needExp));
    self.m_level_lab:setString(self.evo .. "/" .. needExp)
    self:ProgressTiemer()
    return all_price;
end
--截取cid
function game_combiner_up.lua_string_split(self,str)
    local sub_str_tab = {};
    for mu_id in string.gmatch(str, "(%d+)-*") do
        table.insert(sub_str_tab, mu_id)
    end
    return sub_str_tab[1];
end

--[[--
    获取最大等级
]]
function game_combiner_up.maxLevel( self )
    local level_config = getConfig(game_config_field.combiner_base)
    level_config = json.decode(level_config:getFormatBuffer())
    local maxLevel_table = {}
    for k,v in pairs(level_config.level) do
       
        table.insert(maxLevel_table,k)
    end
    local Maxlevel = math.max(unpack(maxLevel_table))
    return Maxlevel
end

--[[--
    进度条
]]
function game_combiner_up.ProgressTiemer(self)
    local expBg = self.m_layer_progress_bar
    local expBgSize = expBg:getContentSize(); 
    if self.maxExp then
        local Myevo = self.m_GameData["evo"] or 0
        local percentage = Myevo/self.maxExp * 100  
        -- self.label_exp:setString(self.curExp .. "/" .. self.maxExp)     
        local expBarAdd = game_util:createProgressTimer({fileName = "Monster_Summoning_jindutiao.png",percentage = percentage})
        expBg:removeAllChildrenWithCleanup(true)
        expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
        expBg:addChild(expBarAdd,2,1);
        local tempExp = self.curExp or 0
        local temp_percentage = self.curExp/self.maxExp *100
        local bar = game_util:createProgressTimer({fileName = "Monster_Summoning_jindutiao.png",percentage = temp_percentage})
        if self.state ~= 0 then
            bar:runAction(CCProgressFromTo:create(1,percentage,temp_percentage));
        end
        -- self.label_exp:setString(self.smallStone_num * 10 + self.middleStone_num * 100 + self.highStone_num *500 + self.curExp .. "/" .. self.maxExp)    
        bar:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
        expBg:addChild(bar,1,2);
       
    end
end



function game_combiner_up:refreshUi( )
    local myCombinerDate = game_data:getCombinerData();
    local MyData = myCombinerDate[tostring(self.MyselNum)]
    self.m_GameData = MyData;
    self:refreshMaterial();
    self:FilterAllMaterial();
    self:refreshFilterCardTableView();
    if self.state == 2 then
        self:setInformation();
    else
        self:getCurrentPower();
        self:setInformation();
    end
    
end



--[[--
    初始化
]]
function game_combiner_up.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    self.MyselNum = t_params.selNum
    self.btnCallFunc = t_params.btnCallFunc
    self.m_material_node_tab = {};
    self.m_material_id_table = {};
    self.AllMaterialTab = {};
    local myCombinerDate = game_data:getCombinerData();
    local MyData = myCombinerDate[tostring(self.MyselNum)]
    self.m_GameData = MyData;
    self.state = 0 ;
    self.m_famousAllData = game_data:getFamousAllData()

end

--[[--
    创建ui入口并初始化数据
]]
function game_combiner_up.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_combiner_up;

