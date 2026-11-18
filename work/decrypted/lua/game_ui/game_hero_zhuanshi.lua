---  转世
local game_hero_zhuanshi = {
    m_tGameData = nil,
    animNode = nil,
    m_level_lab = nil,
    m_xiaoguoDes_lab1 = nil,
    m_jinjie_lab = nil,
    m_des_lab = nil,
    m_chooseP_btn = nil,
    m_chooseP1_btn = nil,
    m_task_node = nil,
    m_task_tab = nil,
    m_cailiao_node = nil,
    m_tableView_node = nil,
    m_huangtiao1_sp = nil,
    m_huangtiao2_sp = nil,
    m_zhuanshi_btn = nil,
    m_task_btn = nil,
    m_shilian_btn = nil,
    m_juexing_btn = nil,
    m_cardId = nil,
    m_card_world_step = nil,
    m_equip_tab = nil,
    m_mate_cost_label_tab = nil,
    content_node = nil,
    text_scroll = nil,
    m_gachaAnimTab = nil,
    m_root_layer = nil,
    m_mask_layer = nil,
    m_anim_node = nil,
    m_stone_node = nil,
    m_material_node_1 = nil,
    m_selEquipDataTab = nil,
    m_autoAdd_btn = nil,
    m_equipIdTable = nil,
    m_onlyId = nil,
    m_jindutiaoDi_sp = nil,
    m_equip_cfg = nil,
    m_afterlife_cfg = nil,
    m_fenjie_btn = nil,
    m_hero_afterPoint = nil,
    m_jundu_lab = nil,
    m_equipEn_sp = nil,
    m_isFull_flag = nil,
    score_max = nil,
};
--[[--
    销毁
]]
function game_hero_zhuanshi.destroy(self)
    -- body
    cclog("-----------------game_hero_zhuanshi destroy-----------------");
    self.m_tGameData = nil;
 	self.animNode = nil;
 	self.m_level_lab = nil;
 	self.m_xiaoguoDes_lab1 = nil;
 	self.m_jinjie_lab = nil;
 	self.m_des_lab = nil;
 	self.m_chooseP_btn = nil;
    self.m_chooseP1_btn = nil;
 	self.m_task_node = nil;
 	self.m_task_tab = nil;
 	self.m_cailiao_node = nil;
 	self.m_tableView_node = nil;
 	self.m_huangtiao1_sp = nil;
 	self.m_huangtiao2_sp = nil;
 	self.m_zhuanshi_btn = nil;
 	self.m_task_btn = nil;
    self.m_cardId = nil;
    self.m_card_world_step = nil;
    self.m_equip_tab = nil;
    self.m_mate_cost_label_tab = nil;
    self.content_node = nil;
    self.text_scroll = nil;
    self.m_gachaAnimTab = nil;
    self.m_root_layer = nil;
    self.m_mask_layer = nil;
    self.m_anim_node = nil;
    self.m_shilian_btn = nil;
    self.m_juexing_btn = nil;
    self.m_stone_node = nil;
    self.m_material_node_1 = nil;
    self.m_selEquipDataTab = nil;
    self.m_autoAdd_btn = nil;
    self.m_equipIdTable = nil;
    self.m_onlyId = nil;
    self.m_jindutiaoDi_sp = nil;
    self.m_equip_cfg = nil;
    self.m_afterlife_cfg = nil;
    self.m_fenjie_btn = nil;
    self.m_hero_afterPoint = nil;
    self.m_jundu_lab = nil;
    self.m_equipEn_sp = nil;
    self.m_isFull_flag = nil;
    self.score_max = nil;
end
--[[--
    返回
]]
function game_hero_zhuanshi.back(self,type)
   game_scene:enterGameUi("game_main_scene");
end
--[[--
    读取ccbi创建ui
]]
function game_hero_zhuanshi.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 101 then --选择要转世的伙伴
            self:addZhuanshiHero()
        elseif btnTag == 105 then --转世
            if self.m_material_NoEnough then
                game_util:addMoveTips({text = "Ko đủ nguyên liệu"})
                return
            end
            local flag = self:isNeedSelect(self.m_cardId)
            if flag then
                game_scene:addPop("ui_zhuanshi_select_pop",{id = self.m_cardId})
            else
                local function responseMethod( tag,gameData )
                    game_util:addMoveTips({text = "Đã chuyển thế"});
                   local data = gameData:getNodeWithKey("data")
                   local _client_cache_update = data:getNodeWithKey("_client_cache_update") 
                   local cards = _client_cache_update:getNodeWithKey("cards")
                   local cards1 = cards:getNodeWithKey("cards")
                   local update = cards1:getNodeWithKey("update")
                   update = json.decode(update:getFormatBuffer())
                   local id  = nil;
                   local heroData = {}
                   for k,v in pairs(update) do
                       id = k
                       heroData = v
                   end
                   self:createFirstHeroAnim(id);
                   self.m_anim_node:setVisible(false);
                   self:addGachaAnim();
                   game_data:setTeamByJsonData(data:getNodeWithKey("alignment"));
                end
                local params = {}
                params.major = self.m_cardId
                --cclog2(params,"params====")
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_card_world"), http_request_method.GET, params,"cards_card_world")
            end
        elseif btnTag == 106 then--自动添加
            self:autoAdd()
        elseif btnTag == 107 then 
            local function responseMethod( tag,gameData )
                local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                local point = data.after_world_point
                local metalNum = data.rewards.metal
                local enchantNum = data.rewards.enchant
                local metalcoreNum = data.rewards.metalcore
                local small_forge_stoneNum = data.rewards.small_forge_stone 
                local desStr = ""
                if metalcoreNum > 0 then
                    desStr = " Đá Tinh Luyện " .. metalcoreNum
                end
                if enchantNum > 0 then 
                    desStr = desStr .. " Mảnh Ma Quang " .. enchantNum
                end
                if small_forge_stoneNum > 0 then 
                    desStr = desStr .. " Đá Rèn.Thấp " .. small_forge_stoneNum 
                end
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        local function responseMethod1( tag,gameData )
                            game_util:closeAlertView();
                            local reward_data = gameData:getNodeWithKey("data")
                            local reward = reward_data:getNodeWithKey("rewards")
                            game_util:rewardTipsByJsonData(reward);
                            local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                            self.m_hero_afterPoint = data._client_cache_update.cards.cards.update[self.m_cardId].after_world_point
                            self:refreshProgress()
                            self.m_onlyId = {}
                            self.m_equipIdTable = {}
                            self:addEquipFromById()
                        end
                        local equipid_str = ""
                        for k,v in pairs(self.m_onlyId) do
                            equipid_str = equipid_str .. v .. (k == #self.m_onlyId and "" or "_")
                        end
                        local params = {}
                        params.major = self.m_cardId
                        params.materials = equipid_str
                        params.sure = 1
                        network.sendHttpRequest(responseMethod1,game_url.getUrlForKey("cards_add_after_world_point"), http_request_method.GET, params,"cards_add_after_world_point")
                    end,   --可缺省
                    cancelBtnCallBack = function(target,event)
                        game_util:closeAlertView();
                    end,
                    okBtnText = "Xác nhận",       --可缺省
                    cancelBtnText = "Hủy",
                    onlyOneBtn = false,
                    text = "Ngài sẽ được" .. point .. "điểm năng lượng  Thiết" .. metalNum .. desStr .. ",Xác nhận tách？",      --可缺省
                    touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                }
                game_util:openAlertView(t_params);
            end
            local equipid_str = ""
            for k,v in pairs(self.m_onlyId) do
                equipid_str = equipid_str .. v .. (k == #self.m_onlyId and "" or "_")
            end
            local params = {}
            params.major = self.m_cardId
            params.materials = equipid_str
            params.sure = 0
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_add_after_world_point"), http_request_method.GET, params,"cards_add_after_world_point")
        elseif btnTag == 201 or btnTag == 102 then--任务一
            if self.m_cardId ~= nil then
                local gameData,_ = game_data:getCardDataById(self.m_cardId)
                game_scene:enterGameUi("game_hero_zhuanshi_task",{gameData = gameData,openType = "zhuanshi",firstflag = true})
            else
                game_util:addMoveTips({text = "Chọn thẻ muốn chuyển thế"});
            end
        elseif btnTag == 202 or btnTag == 103 then--任务二
            if self.m_cardId ~= nil and self.m_card_world_step > 0  then
                game_scene:enterGameUi("game_hero_zhuanshiTask_map",{gameData = nil,major = self.m_cardId})
            end
        elseif btnTag == 203 or btnTag == 104 then--任务三
            if self.m_cardId ~= nil and self.m_card_world_step > 1  then
                game_scene:addPop("game_hero_zhuanshiTaskThree_pop",{gameData = nil,major = self.m_cardId})
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_hero_zhuanshi1.ccbi");
    local m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.animNode = ccbNode:nodeForName("animNode")
    self.m_level_lab = ccbNode:labelTTFForName("m_level_lab")
    self.m_xiaoguoDes_lab1 = ccbNode:labelTTFForName("m_xiaoguoDes_lab1")
    self.m_jinjie_lab = ccbNode:labelTTFForName("m_jinjie_lab")
    self.m_des_lab = ccbNode:labelTTFForName("m_des_lab")
    self.m_chooseP_btn = ccbNode:controlButtonForName("m_chooseP_btn")
    self.m_chooseP_btn:setVisible(false)
    self.m_chooseP1_btn = ccbNode:controlButtonForName("m_chooseP1_btn")
    self.m_task_node = ccbNode:nodeForName("m_task_node")
    self.m_cailiao_node = ccbNode:nodeForName("m_cailiao_node")
    self.m_tableView_node = ccbNode:nodeForName("m_tableView_node")
    self.m_huangtiao1_sp = ccbNode:spriteForName("m_huangtiao1_sp")
    self.m_huangtiao2_sp = ccbNode:spriteForName("m_huangtiao2_sp")
    self.m_mask_layer = ccbNode:layerColorForName("m_mask_layer");
    self.m_stone_node = ccbNode:spriteForName("m_stone_node")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node");
    self.m_zhuanshi_btn = ccbNode:controlButtonForName("m_zhuanshi_btn")
    self.m_task_btn = ccbNode:controlButtonForName("m_task_btn")
    self.m_shilian_btn = ccbNode:controlButtonForName("m_shilian_btn")
    self.m_juexing_btn = ccbNode:controlButtonForName("m_juexing_btn")
    self.m_material_node_1 = ccbNode:spriteForName("m_material_node_1")
    self.m_autoAdd_btn = ccbNode:controlButtonForName("m_autoAdd_btn")
    self.m_jindutiaoDi_sp = ccbNode:spriteForName("m_jindutiao_sp")
    self.m_fenjie_btn = ccbNode:controlButtonForName("m_fenjie_btn")
    self.m_equipEn_sp = ccbNode:spriteForName("m_equipEn_sp")
    self.m_jundu_lab = ccbNode:labelTTFForName("m_jundu_lab")

    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScale(resolution_config:getScale())
    
    self.m_task_btn:setVisible(true)
    self.m_zhuanshi_btn:setVisible(false)
    self.m_equipIdTable = {}
    self.m_task_tab = {}
    local m_clear_sp,m_gotask_btn,m_an_sp,m_taskDes_lab,m_huangtiao_sp = nil;
    for i=1,3 do
    	m_clear_sp = ccbNode:spriteForName("m_clear_sp" .. i)
        m_clear_sp:setVisible(false)
    	m_an_sp = ccbNode:spriteForName("m_an_sp" .. i)
    	m_huangtiao_sp = ccbNode:spriteForName("m_huangtiao_sp" .. i)
    	m_gotask_btn = ccbNode:controlButtonForName("m_gotask_btn" .. i)
    	m_taskDes_lab = ccbNode:labelTTFForName("m_taskDes_lab" .. i)
    	self.m_task_tab[i] = {m_clear_sp = m_clear_sp,m_an_sp = m_an_sp,m_huangtiao_sp = m_huangtiao_sp,m_gotask_btn = m_gotask_btn,m_taskDes_lab = m_taskDes_lab}
    end
    self.m_equip_tab = {}
    self.m_mate_cost_label_tab = {}

    local m_mate_cost_label,m_equip_node,m_mate_tips,m_equipLevel_lab = nil
    for i=1,5 do
        m_equip_node = ccbNode:spriteForName("m_equip_node" .. i)
        m_mate_tips = ccbNode:spriteForName("m_mate_tips_" .. i)
        m_equipLevel_lab = ccbNode:labelTTFForName("m_equipLevel_lab" .. i)
        self.m_equip_tab[i] = {m_equip_node = m_equip_node , m_mate_tips = m_mate_tips , m_equipLevel_lab = m_equipLevel_lab}
    end
    for i=1,2 do
        m_mate_cost_label = ccbNode:labelTTFForName("m_mate_cost_label_" .. i)
        self.m_mate_cost_label_tab[i] = {m_mate_cost_label = m_mate_cost_label}
    end
    local function onTouch2(eventType, x, y)
        if eventType == "began" then
                --self:removeGachaAnim()
                --self.m_anim_node:removeAllChildrenWithCleanup(true)
                self.m_anim_node:setVisible(false);
                self.m_mask_layer:setVisible(false);
                self.m_mask_layer:setTouchEnabled(false)
                self:refreshUi2()
            if self.m_mask_layer:isVisible() then
                return true;--intercept event
            else
                return false
            end
        end
    end
    self.m_mask_layer:setVisible(false);
    self.m_mask_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-20,true);
    self.m_mask_layer:setTouchEnabled(false)
    self.content_node = ccbNode:nodeForName("content_node")
    self.text_scroll = ccbNode:scrollViewForName("text_scroll")
    return ccbNode;
end


function game_hero_zhuanshi:isNeedSelect(id)
    local cardData,cardCfg = game_data:getCardDataById(id)
    local afterLifeCfg = getConfig(game_config_field.afterlife)
    local selData = json.decode(afterLifeCfg:getNodeWithKey(cardData.c_id):getFormatBuffer())
    local zhuanshi_list = selData.afterlife_id or {}
    if #zhuanshi_list > 1 then
        return true
    end
    return false
end
--[[--
    自动添加
]]
function game_hero_zhuanshi.autoAdd( self )
    self.m_selEquipDataTab = game_data:getEquipIdTable();
    self.m_equipIdTable = {}
    self.m_onlyId = {}
    local equipCount = #self.m_selEquipDataTab
    local autoItemData = nil
    local autoSortId = nil
    local autoQuality = nil
    local autoExchange_id = nil
    local equipId = nil
    for i=1,#self.m_selEquipDataTab do
        local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipDataTab[equipCount - i + 1]);
        local sortId = itemCfg:getNodeWithKey("sort"):toInt()
        local quality = itemCfg:getNodeWithKey("quality"):toInt()
        local exchange_id = itemCfg:getNodeWithKey("exchange_id") and itemCfg:getNodeWithKey("exchange_id"):toInt() or nil
        local tempEquipId = itemData.c_id
        local existFlag,cardName = game_data:equipInEquipPos(sortId,itemData.id)
        local godexistFlag = game_data:godequipInEquipPos(sortId,itemData.id)
        local dataId = tostring(itemData.id);
        local m_tEquipPosData1 = game_data:getGodEquipPosData1();
        local m_tEquipPosData2 = game_data:getGodEquipPosData2();
        local m_tEquipPosData3 = game_data:getGodEquipPosData3();
        local godflag1 = game_util:godEquipeidInTableById(dataId,m_tEquipPosData1)
        local godflag2 = game_util:godEquipeidInTableById(dataId,m_tEquipPosData2)
        local godflag3 = game_util:godEquipeidInTableById(dataId,m_tEquipPosData3)

        if existFlag or godexistFlag then
        else
            local flag,k = game_util:idInTableById(tostring(itemData.id),self.m_equipIdTable);                    
            if flag and k ~= nil then
            elseif godflag1 == true or godflag2 == true or godflag3 == true then
            --过滤神域上的装备
            else 
                autoItemData = itemData
                autoSortId = sortId 
                autoQuality = quality
                autoExchange_id = exchange_id 
                equipId = tempEquipId
                if #self.m_equipIdTable <= 4 and quality >= 4 then
                    table.insert(self.m_equipIdTable,equipId)
                    table.insert(self.m_onlyId,dataId)
                    local point = self:getCurrentPower()
                    if point>=self.score_max then
                        self.m_isFull_flag = true 
                        break;
                    else
                        self.m_isFull_flag = false 
                    end
                end
            end
        end
    end
    if autoItemData then
        if #self.m_equipIdTable <= 5 then
            local num = #self.m_equipIdTable + 1
            self:addEquipFromById()
            self:refreshUi(self.m_tGameData)
        elseif #self.m_equipIdTable == 0 then
            game_util:addMoveTips({text = "Không có trang bị phù hợp!"});
        else
            local num = 5
            self:addEquipFromById()
            self:refreshUi(self.m_tGameData)
        end
    else
        game_util:addMoveTips({text = "Không có trang bị phù hợp!"});
    end
end
--[[--
    材料装备
]]
function game_hero_zhuanshi.addEquipFromById( self)
    for i=1,5 do
        self.m_equip_tab[i].m_equip_node:removeAllChildrenWithCleanup(true)
    end
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        table.remove(self.m_equipIdTable,btnTag)
        table.remove(self.m_onlyId,btnTag)
        self.m_equip_tab[btnTag].m_equipLevel_lab:setVisible(false)
        local point = self:getCurrentPower()
        if point>=self.score_max then
            self.m_isFull_flag = true 
        else
            self.m_isFull_flag = false 
        end
        self:addEquipFromById()
    end
    local function onBtnCilck2( event,target )
        local  zhuanshiFlag  = self.m_zhuanshi_btn:isVisible()
        if self.m_isFull_flag == true or zhuanshiFlag == true then
            game_util:addMoveTips({text = "Năng lượng đã đầy"})
        else
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            local itemOnClick = function (id,dataId)
                table.insert(self.m_equipIdTable,id)
                table.insert(self.m_onlyId,dataId)
                local index = #self.m_equipIdTable
                self.m_equip_tab[index].m_equip_node:removeAllChildrenWithCleanup(true)
                local icon = game_util:createEquipIconByCid(id);
                if icon then
                    local lv = self:getEquipLevel(self.m_onlyId[index])
                    self.m_equip_tab[index].m_equipLevel_lab:setString("Lv. " .. lv)
                    self.m_equip_tab[index].m_equipLevel_lab:setVisible(true)
                    local tempSize = self.m_equip_tab[index].m_equip_node:getContentSize();
                    icon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                    self.m_equip_tab[index].m_equip_node:addChild(icon,10,10);
                    self.m_equip_tab[index].m_mate_tips:setVisible(false)
                    self:createButton(icon,onBtnCilck,index,nil,ccp(0.5,0.5))
                    local point = self:getCurrentPower()
                    if point>=self.score_max then
                        self.m_isFull_flag = true 
                    else
                        self.m_isFull_flag = false 
                    end
                    self:refreshProgress()
                end
            end
            game_scene:addPop("game_zhuanshi_equip_pop",{itemOnClick = itemOnClick,m_equipIdTable = self.m_equipIdTable,m_onlyId = self.m_onlyId})
        end
    end
    for i=1,5 do
       self.m_equip_tab[i].m_mate_tips:setVisible(true)
       self.m_equip_tab[i].m_equipLevel_lab:setVisible(false)
       self:createButton(self.m_equip_tab[i].m_mate_tips,onBtnCilck2,i,0.6,ccp(0.5,0.5),0)
    end
    local count = #self.m_equipIdTable
    if count > 0 then
        for i=1,count do
            local icon = game_util:createEquipIconByCid(self.m_equipIdTable[i]);
            if icon and i<6 then
                local lv = self:getEquipLevel(self.m_onlyId[i])
                self.m_equip_tab[i].m_equipLevel_lab:setString("Lv. " .. lv)
                self.m_equip_tab[i].m_equipLevel_lab:setVisible(true)
                local tempSize = self.m_equip_tab[i].m_equip_node:getContentSize();
                icon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                self.m_equip_tab[i].m_equip_node:addChild(icon,10,10);
                self.m_equip_tab[i].m_mate_tips:setVisible(false)
                self:createButton(icon,onBtnCilck,i,nil,ccp(0.5,0.5))
            end
        end
    end
    self:refreshProgress()
end
--[[--
    获取装备等级
]]
function game_hero_zhuanshi.getEquipLevel( self,id)
    local itemData,itemCfg = game_data:getEquipDataById(id);
    local lv = itemData.lv
    return lv
end
--[[--
    创建按钮
]]
function game_hero_zhuanshi.createButton( self,icon,onBtnCilck,i,scale,AnchorPoint,opacity )
    local button = game_util:createCCControlButton("public_skill.png","",onBtnCilck)
    button:setAnchorPoint(AnchorPoint)
    button:setZoomOnTouchDown(false)
    button:setPosition( icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5 )
    if opacity then 
        button:setOpacity(opacity)
    else
        button:setOpacity(0)
    end
    if scale then 
       button:setScale(tonumber(scale))
    end
    button:setTag(i)
    icon:addChild(button,10)
end
--[[--
    获取当前装备能量值
]]
function game_hero_zhuanshi.getCurrentPower( self )
    local point = 0
    local chainEquipTab = {}
    local heroData,heroCfg = game_data:getCardDataById(self.m_cardId)
    local equip_cfg = getConfig(game_config_field.equip);
    local chain_cfg = getConfig(game_config_field.chain);
    local chain = heroCfg:getNodeWithKey("chain")
    local chainCount = chain:getNodeCount();
    for i=1,chainCount do
        local chainId = chain:getNodeAt(i-1):toStr();
        local chainItemCfg = chain_cfg:getNodeWithKey(chainId);
        if chainItemCfg then
            local data = chainItemCfg:getNodeWithKey("data")
            local dataCount = data:getNodeCount();
            local condition_sort = chainItemCfg:getNodeWithKey("condition_sort"):toInt();
            if dataCount > 0 then
                if condition_sort == 1 then
                    for i=1,dataCount do
                        local itemCfg = equip_cfg:getNodeWithKey(data:getNodeAt(i-1):toStr())
                        if itemCfg then
                            itemCfg = json.decode(itemCfg:getFormatBuffer())
                            local chain_id = itemCfg.chain_id
                            chainEquipTab[tostring(chain_id)] = 1
                        end
                    end
                end
            end
        end
    end
    if #self.m_equipIdTable > 0 then
        for k,v in pairs(self.m_equipIdTable) do
            local equipid = string.sub(v,1,3)
            if chainEquipTab[tostring(equipid)] then
                point = (point+ self.m_equip_cfg[tostring(v)].afterlife * 2.5)
            else
                point = point+ self.m_equip_cfg[tostring(v)].afterlife
            end
        end
    end
    return point + self.m_hero_afterPoint
end
--[[--
    创建进度条
]]
function game_hero_zhuanshi.setJindutiao( self )
    -- self.m_jundu_lab:setString("0/0")
    local expBg = self.m_jindutiaoDi_sp
    local expBgSize = expBg:getContentSize(); 
    local current_score = self:getCurrentPower() 
    
    local percentage = current_score/self.score_max * 100 
    self.m_jundu_lab:setString(current_score .. "/" .. self.score_max)
    -- self.m_animNode:removeAllChildrenWithCleanup(true) 
    if self.m_hero_afterPoint >= self.score_max then
        self.m_autoAdd_btn:setVisible(false)
        self.m_fenjie_btn:setVisible(false)
        self.m_zhuanshi_btn:setVisible(true)
    else
        self.m_autoAdd_btn:setVisible(true)
        self.m_fenjie_btn:setVisible(true)
        self.m_zhuanshi_btn:setVisible(false)
    end 
    local params = {}
    params.percentage = percentage
    params.fileName = "zhuanshi_jindutiao1.png"
    local expBarAdd = game_util:createProgressTimer(params)
    expBg:removeAllChildrenWithCleanup(true)
    expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
    expBg:addChild(expBarAdd,11,11);
end

--[[--
    移除抽取好卡的动画
]]
function game_hero_zhuanshi.removeGachaAnim(self)
    self.m_mask_layer:removeAllChildrenWithCleanup(true);
    self.m_gachaAnimTab = {};
end
--[[--
    创建
]]
function game_hero_zhuanshi.addGachaAnim(self)
    self:removeGachaAnim();
    self.m_mask_layer:setVisible(true);
    local animFile = "gacha_anim_3";
    local m_iAnim = zcAnimNode:create(animFile .. ".swf.sam",0,animFile .. ".plist");
    local function animEnd(animNode,theId,lableName)
        if lableName == "daiji" then

        elseif lableName == "xunhuan" then
            animNode:playSection("xunhuan");
        elseif lableName == "fanpai" then
            game_sound:playUiSound("gacha")
            self.m_anim_node:setVisible(true);
            self.m_mask_layer:setTouchEnabled(true)
            animNode:playSection("xunhuan");
        end
    end
    m_iAnim:registerScriptTapHandler(animEnd);
    m_iAnim:playSection("daiji");
    m_iAnim:setScale(1);
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    m_iAnim:setPosition(ccp(visibleSize.width*0.9, visibleSize.height*0.1))
    local function animEndCallFunc()
        m_iAnim:playSection("fanpai");
    end
    cclog("addGachaAnim ======================== " .. animFile);
    local animArr = CCArray:create();
    animArr:addObject(CCMoveTo:create(0.1,ccp(visibleSize.width*0.5, visibleSize.height*0.5)));
    animArr:addObject(CCCallFunc:create(animEndCallFunc));
    m_iAnim:runAction(CCSequence:create(animArr));
    self.m_mask_layer:addChild(m_iAnim,10,10);
    self.m_gachaAnimTab[#self.m_gachaAnimTab+1] = m_iAnim
end
function game_hero_zhuanshi.createFirstHeroAnim(self,cardId)
    self.m_anim_node:removeAllChildrenWithCleanup(true);
        local cardData,heroCfg = game_data:getCardDataById(tostring(cardId));
        if heroCfg == nil then return end

        local animNode = game_util:createHeroListItemByCCB(cardData);
        if animNode then
            self.m_anim_node:addChild(animNode);
        end
end
--[[--
    获取对应卡牌的命运装备
]]
function game_hero_zhuanshi.getEquipId(self)
    local heroData,_ = game_data:getCardDataById(self.m_cardId)
    local lifeid = tostring(heroData.c_id)
    local tab = self.m_afterlife_cfg[lifeid].afterlife_material
     cclog2(tab,"tab===")
    local equip_tab = {}
    local material = {}
    local x = 1
    local x = 1
    for i=1,#tab do
        if tab[i][1] == 7 then
            equip_tab[x] = {id = tab[i][2],neednum = tab[i][3]} 
            local icon = game_util:createEquipIconByCid(tab[1][2]);
            if icon then
                local tempSize = self.m_equipEn_sp:getContentSize();
                icon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                self.m_equipEn_sp:addChild(icon,10,10)
            end
            x = x + 1
        else
            material = {id = tab[i][2],neednum = tab[i][3]}
        end

    end
    --cclog2(material,"material===")
    return equip_tab,material
end
--[[--
    转世装备
]]
function game_hero_zhuanshi.createHeroEquip( self )
    local equip_tab,material = self:getEquipId()
    local materialIcon=  game_util:createItemIconByCid(material.id);
    --cclog2(materialIcon,"materialIcon==")
    local materialcount = game_data:getItemCountByCid(material.id);
    --cclog2(materialcount,"materialcount==")
    function onBtnCilck( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 5 then
            local tempTable = {}
            tempTable[1] = 6
            tempTable[2] = material.id
            game_util:lookItemDetal(tempTable)
        elseif btnTag == 6 then
            local tempTable = {}
            tempTable[1] = 6
            tempTable[2] = 3100
            game_util:lookItemDetal(tempTable)
        end
    end
    if materialIcon then
        local tempSize = self.m_stone_node:getContentSize();
        materialIcon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
        self.m_stone_node:addChild(materialIcon,10,10);
        self:createButton(materialIcon,onBtnCilck,6,nil,ccp(1.5,0.5),0)
        if materialcount < material.neednum then
            self.m_mate_cost_label_tab[2].m_mate_cost_label:setColor(ccc3(255,50,50))
        end
        self.m_mate_cost_label_tab[2].m_mate_cost_label:setString(tostring(materialcount) .. "/" .. tostring(material.neednum))
        self:createButton(materialIcon,onBtnCilck,5,nil,ccp(0.5,0.5))
    end
    self.m_mate_cost_label_tab[1].m_mate_cost_label:setString("1/1")
end
--[[--
    创建内容详情
]]
function game_hero_zhuanshi.createText( self,viewSize,contentText )
    local contentText = contentText or ""
    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(210,0),textAlignment = kCCTextAlignmentLeft,
    verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    self.text_scroll:setContentSize(CCSizeMake(210,tempSize.height))
    self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.text_scroll:addChild(tempLabel)
end
--[[--
    添加卡牌
]]
function game_hero_zhuanshi.addZhuanshiHero(self)
    local btnCallFunc = function( target,event )
            
    end
    local itemOnClick = function (id)
        self.m_chooseP_btn:setVisible(true)
        self.m_chooseP1_btn:setVisible(false)
        self.m_cardId = id
        game_data:setZhuanshiCardId(id)
        self.m_onlyId = {}
        self.m_equipIdTable = {}
        self.m_isFull_flag = false
        local heroData,heroCfg = game_data:getCardDataById(self.m_cardId)
        local lifeid = tostring(heroData.c_id)
        self.score_max = self.m_afterlife_cfg[lifeid].afterlife_point or 10000
        self.m_card_world_step = heroData.card_world_step or 0
        if heroData.after_world_point then
            self.m_hero_afterPoint = heroData.after_world_point
        else
            self.m_hero_afterPoint = 0
        end
        self:refreshUi(heroData)
        self:addEquipFromById()
    end
    game_scene:addPop("game_hero_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,openType = 3})
end
function game_hero_zhuanshi.setTaskBtnStatus( self )
    if self.m_card_world_step == 0 then
        self.m_task_node:setVisible(true)
        self.m_cailiao_node:setVisible(false)
        self.m_task_btn:setVisible(true)
        self.m_huangtiao1_sp:setVisible(true)
        self.m_huangtiao2_sp:setVisible(true)
        for i=2,3 do
            self.m_task_tab[i].m_an_sp:setVisible(true)
            self.m_task_tab[i].m_huangtiao_sp:setVisible(true)
            self.m_task_tab[i-1].m_clear_sp:setVisible(false)
        end
        self.m_task_tab[1].m_an_sp:setVisible(false)
        self.m_task_tab[1].m_huangtiao_sp:setVisible(false)

    elseif self.m_card_world_step == 1 then
        self.m_task_node:setVisible(true)
        self.m_cailiao_node:setVisible(false)
        self.m_task_btn:setVisible(false)
        self.m_shilian_btn:setVisible(true)
        self.m_huangtiao1_sp:setVisible(true)
        self.m_huangtiao2_sp:setVisible(true)
        self.m_task_tab[2].m_clear_sp:setVisible(false)
        self.m_task_tab[3].m_an_sp:setVisible(true)
        self.m_task_tab[3].m_huangtiao_sp:setVisible(true)
        for i=1,2 do
            self.m_task_tab[i].m_an_sp:setVisible(false)
            self.m_task_tab[i].m_huangtiao_sp:setVisible(false)
        end
        self.m_task_tab[1].m_clear_sp:setVisible(true)
        
    elseif self.m_card_world_step == 2 then
        self.m_shilian_btn:setVisible(false)
        self.m_task_node:setVisible(true)
        self.m_cailiao_node:setVisible(false)
        self.m_task_btn:setVisible(false)
        self.m_huangtiao1_sp:setVisible(true)
        self.m_huangtiao2_sp:setVisible(true)
        self.m_juexing_btn:setVisible(true)
        for i=1,3 do
            self.m_task_tab[i].m_an_sp:setVisible(false)
            self.m_task_tab[i].m_huangtiao_sp:setVisible(false)
        end
        self.m_task_tab[1].m_clear_sp:setVisible(true)
        self.m_task_tab[2].m_clear_sp:setVisible(true)
    elseif self.m_card_world_step == 3 then
        self:createHeroEquip()
        self.m_task_node:setVisible(false)
        self.m_cailiao_node:setVisible(true)
        self.m_juexing_btn:setVisible(false)
        self.m_shilian_btn:setVisible(false)
        self.m_task_btn:setVisible(false)
        self.m_huangtiao1_sp:setVisible(false)
        self.m_huangtiao2_sp:setVisible(false)
    end
end
--[[--
    创建卡牌动画
]]
function game_hero_zhuanshi.createHeroAnim(self)
    self.animNode:removeAllChildrenWithCleanup(true)
    local card_ccbNode = self:setQuanshenxiang();
    self.animNode:addChild(card_ccbNode,10,10)
end

function game_hero_zhuanshi.setQuanshenxiang(self)
    local animNode = nil;
    local heroData,heroCfg = game_data:getCardDataById(self.m_cardId)
    if heroData and heroCfg then
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        animNode = game_util:createIdelAnim(ainmFile,0,heroData,heroCfg);
        if animNode then
            animNode:setRhythm(1);
            game_anim:playSection(animNode , anim_label_name_cfg.daiji);
            local itemSize = animNode:getContentSize();
            animNode:setAnchorPoint(ccp(0.5,0));
        end
    end
    return animNode;
end
function game_hero_zhuanshi.refreshProgress( self )
    self:setJindutiao()
end
--[[--
    刷新ui
]]
function game_hero_zhuanshi.refreshUi(self,heroData)
    self.m_des_lab:setVisible(false)
    if heroData then
        self.m_chooseP_btn:setVisible(true)
        self.m_chooseP1_btn:setVisible(false)
        self.m_des_lab:setVisible(true)
        self:createHeroAnim()
        self:setTaskBtnStatus()
        local heroData,heroCfg = game_data:getCardDataById(self.m_cardId)
        local lifeid = tostring(heroData.c_id)
        local tab = self.m_afterlife_cfg[lifeid].des1
        local tab2 = self.m_afterlife_cfg[lifeid].des2
        self.m_des_lab:setString(tab)
        self.m_xiaoguoDes_lab1:setString(tab2)

        for i=1,3 do
            local mission = self.m_afterlife_cfg[lifeid]["mission" .. i]
            if mission then
                self.m_task_tab[i].m_taskDes_lab:setString(mission)
            end
        end
    end
end
--[[--
    转世后的刷新
]]
function game_hero_zhuanshi.refreshUi2( self )
    self.m_cardId = nil
    self.m_chooseP1_btn:setVisible(true)
    self.m_chooseP_btn:setVisible(false)
    self.animNode:removeAllChildrenWithCleanup(true)
    self.m_des_lab:setString("")
    self.m_task_node:setVisible(true)
    self.m_task_btn:setVisible(true)
    self.m_cailiao_node:setVisible(false)
    self.m_huangtiao1_sp:setVisible(true)
    self.m_huangtiao2_sp:setVisible(true)
    for i=1,3 do
        self.m_task_tab[i].m_clear_sp:setVisible(false)
        self.m_task_tab[i].m_an_sp:setVisible(true)
        self.m_task_tab[i].m_huangtiao_sp:setVisible(true)
    end
end
--[[--
    初始化
]]
function game_hero_zhuanshi.init(self,t_params)
    self.m_gachaAnimTab = {}
    t_params = t_params or {};
    self.m_tGameData = {}
    self.score_max = 10000
    self.m_isFull_flag = true
    if t_params.dispatch_data ~= nil and tolua.type(t_params.dispatch_data) == "util_json" then
        local data = t_params.dispatch_data:getNodeWithKey("data") 
        local all_align =json.decode(data:getNodeWithKey("all_align"):getFormatBuffer()) or {};
        if all_align then
            game_data:setDispatchCard(all_align)
        end
    end
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local temp = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
        self.m_tGameData = temp
    elseif t_params.gameData ~= nil and tolua.type(t_params.gameData) == "table" then
        self.m_tGameData =  t_params.gameData
    end
    self.m_onlyId = {}
    self.m_equip_cfg = json.decode(getConfig(game_config_field.equip):getFormatBuffer())
    cclog2(m_equip_cfg,"m_equip_cfg=======")
    self.m_afterlife_cfg = json.decode(getConfig(game_config_field.afterlife):getFormatBuffer())
    cclog2(m_afterlife_cfg,"m_afterlife_cfg==")
    self.m_hero_afterPoint = 0
end

--[[--
    创建ui入口并初始化数据
]]
function game_hero_zhuanshi.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self.m_jundu_lab:setString("")
    for i=1,5 do
        self.m_equip_tab[i].m_equipLevel_lab:setVisible(false)
    end
    if next(self.m_tGameData) then
        self.m_cardId = self.m_tGameData.id
        self.m_card_world_step = self.m_tGameData.card_world_step or 0
        self:refreshUi(self.m_tGameData);
    else
        self:refreshUi();
    end
    return scene;
end

return game_hero_zhuanshi;
