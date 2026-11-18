---  挖矿

local game_activity_mine_game = {
    m_tGameData = nil,
    m_map_layer = nil,
    m_item_label_1 = nil,
    m_item_label_2 = nil,
    m_item_label_3 = nil,
    m_item_label_4 = nil,
    m_item_spri_1 = nil,
    m_item_spri_2 = nil,
    m_bar_bg = nil,
    m_bar_value_label = nil,
    m_combat_label = nil,
    m_tips_label_1 = nil,
    m_tips_label_2 = nil,
    m_bar = nil,
    m_key_coin = nil,
    m_weapon_coin = nil,
    m_key_label = nil,
    m_weapon_label = nil,
    m_temp_weapon_num = nil,
    m_temp_key_num = nil,
    m_weapon_or_key_anim_flag = nil,
    m_list_item_anim_flag = nil,
    m_selListItem = nil,
    m_temp_remain_blood = nil,
    m_temp_bar_parent_pos = nil
};
--[[--
    销毁ui
]]
function game_activity_mine_game.destroy(self)
    -- body
    cclog("-----------------game_activity_mine_game destroy-----------------");
    self.m_tGameData = nil
    self.m_map_layer = nil
    self.m_item_label_1 = nil
    self.m_item_label_2 = nil
    self.m_item_label_3 = nil
    self.m_item_label_4 = nil
    self.m_item_spri_1 = nil
    self.m_item_spri_2 = nil
    self.m_bar_bg = nil
    self.m_bar_value_label = nil
    self.m_combat_label = nil
    self.m_tips_label_1 = nil
    self.m_tips_label_2 = nil
    self.m_bar = nil
    self.m_key_coin = nil
    self.m_weapon_coin = nil
    self.m_key_label = nil
    self.m_weapon_label = nil
    self.m_temp_weapon_num = nil
    self.m_temp_key_num = nil
    self.m_weapon_or_key_anim_flag = nil
    self.m_list_item_anim_flag = nil
    self.m_selListItem = nil
    self.m_temp_remain_blood = nil
    self.m_temp_bar_parent_pos = nil
end
--[[--
    返回
]]
function game_activity_mine_game.back(self,backType)
    local function responseMethod(tag,gameData)
       game_scene:enterGameUi("game_activity_mine_new",{gameData = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("mining_task_index"), http_request_method.GET, nil,"mining_task_index")
end
--[[--
    读取ccbi创建ui
]]
function game_activity_mine_game.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_activity_mine_game.ccbi");
    self.m_map_layer = ccbNode:layerForName("m_map_layer")
    self.m_item_label_1 = ccbNode:labelTTFForName("m_item_label_1")
    self.m_item_label_2 = ccbNode:labelTTFForName("m_item_label_2")
    self.m_item_label_3 = ccbNode:labelTTFForName("m_item_label_3")
    self.m_item_label_4 = ccbNode:labelTTFForName("m_item_label_4")
    self.m_item_spri_1 = ccbNode:spriteForName("m_item_spri_1")
    self.m_item_spri_2 = ccbNode:spriteForName("m_item_spri_2")
    self.m_bar_bg = ccbNode:spriteForName("m_bar_bg")
    local pX,pY = self.m_bar_bg:getParent():getPosition() 
    self.m_temp_bar_parent_pos = {x = pX,y = pY}
    self.m_bar_value_label = ccbNode:labelTTFForName("m_bar_value_label")
    self.m_combat_label = ccbNode:labelTTFForName("m_combat_label")
    self.m_tips_label_1 = ccbNode:labelTTFForName("m_tips_label_1")
    self.m_tips_label_2 = ccbNode:labelTTFForName("m_tips_label_2")    
    self.m_key_coin = ccbNode:spriteForName("m_key_coin")
    self.m_weapon_coin = ccbNode:spriteForName("m_weapon_coin")
    self.m_key_label = ccbNode:labelTTFForName("m_key_label")
    self.m_weapon_label = ccbNode:labelTTFForName("m_weapon_label")
    local bar = ExtProgressTime:createWithFrameName("mining_bar_bg2.png","mining_bar_bg1.png")
    self.m_bar_bg:addChild(bar,10,10);
    self.m_bar = bar
    game_util:setPlayerPropertyByCCBAndTableData2(ccbNode)
    local m_player_name = ccbNode:labelTTFForName("m_player_name")
    local m_lv_label = ccbNode:labelTTFForName("m_lv_label")
    local m_vip_label = ccbNode:labelTTFForName("m_vip_label")
    local m_head_icon_node = ccbNode:nodeForName("m_head_icon_node")
    local user_status = game_data:getUserStatusData();
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(user_status.role));
    local tempSpr = game_util:createPlayerIconByCfg(itemCfg)
    if tempSpr then
        tempSpr:setScale(0.75);
        tempSpr:setPosition(ccp(31, 29));
        m_head_icon_node:addChild(tempSpr);
    end
    m_vip_label:setString("VIP" .. tostring(user_status.vip))
    m_player_name:setString(tostring(user_status.show_name))
    m_lv_label:setString(tostring(user_status.level));
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
            if self.m_selListItem then
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode")
                local m_sel_spri = ccbNode:spriteForName("m_sel_spri")
                m_sel_spri:setVisible(false)
                self.m_selListItem = nil
            end
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+1);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建列表
]]
function game_activity_mine_game.createTableView(self,viewSize)
    self.m_selListItem = nil
    local adventure_stage_cfg = getConfig(game_config_field.adventure_stage)
    local lands = self.m_tGameData.lands or {}
    local totalItem = 30
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 6; --列
    -- params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = totalItem;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_activity_mine_game_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            if self.m_list_item_anim_flag then
                ccbNode:setScale(0)
                -- ccbNode:runAction(CCScaleTo:create(0.5,1))
                local arr = CCArray:create()
                arr:addObject(CCDelayTime:create(0.025*index))
                arr:addObject(CCScaleTo:create(0.25,1))
                ccbNode:runAction(CCSequence:create(arr))
            end
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_attr_node_1 = ccbNode:nodeForName("m_attr_node_1")
            local m_attr_node_2 = ccbNode:nodeForName("m_attr_node_2")
            local m_item_label_1 = ccbNode:labelTTFForName("m_item_label_1")
            local m_item_label_2 = ccbNode:labelTTFForName("m_item_label_2")
            local m_item_bg = ccbNode:spriteForName("m_item_bg")
            local m_item_node = ccbNode:spriteForName("m_item_node")
            m_item_node:removeAllChildrenWithCleanup(true)
            local landItem = lands[tostring(index+1)] or {}
            local locked = landItem.locked or 1 -- 1锁住，0未锁
            local stage_status = landItem.stage_status or 1 -- 1. 可以点击　　2. 灰色不可点击　3. 已经激活  4. 已经点击过 
            local atk = landItem.atk
            local hp = landItem.hp
            local sort = landItem.sort or 0
            m_attr_node_1:setVisible(false)
            m_attr_node_2:setVisible(false)
            local icon = landItem.icon or ""
            local itemBgName = "mining_item_bg1.png"
            local tempSpriteFrame = nil
            if locked == 1 then
                local mining_fork = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("mining_fork.png")
                if mining_fork then
                    local m_item_img = CCSprite:createWithSpriteFrame(mining_fork)
                    m_item_node:addChild(m_item_img)
                end
            end
            if stage_status == 1 then
                itemBgName = "mining_item_bg2.png"
            elseif stage_status == 2 then
                itemBgName = "mining_item_bg1.png"
            elseif stage_status == 3 then
                itemBgName = "mining_item_bg2.png"
                if locked == 0 then
                    if atk and hp then
                        m_attr_node_1:setVisible(true)
                        m_attr_node_2:setVisible(true)
                        m_item_label_1:setString(tostring(atk))
                        m_item_label_2:setString(tostring(hp))
                    end
                    if icon ~= "" then
                        local iconSpri = game_util:createIconByName(icon)
                        if iconSpri then
                            itemBgName = "mining_item_bg3.png"
                            if sort == 5 then--门
                                local key_num = self.m_tGameData.key_num or 0 -- 钥匙
                                if key_num < 1 then
                                    iconSpri:setColor(ccc3(88,88,88))
                                end
                            end
                            m_item_node:addChild(iconSpri)
                        end
                    end
                end
            elseif stage_status == 4 then
                itemBgName = "mining_item_bg3.png"
            end
            -- local tempLabel = game_util:createLabel({text = "status:" .. stage_status .. "\nlocked:" .. locked})
            -- m_item_node:addChild(tempLabel)
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(itemBgName)
            if tempSpriteFrame then
                m_item_bg:setDisplayFrame(tempSpriteFrame)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        local landItem = lands[tostring(index+1)] or {}
        if eventType == "began" and cell then
            local stage_status = landItem.stage_status or 1 -- 1. 可以点击　　2. 灰色不可点击　3. 已经激活  4. 已经点击过 
            if stage_status == 1 or stage_status == 3 then
                local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
                local m_sel_spri = ccbNode:spriteForName("m_sel_spri")
                m_sel_spri:setVisible(true)
                self.m_selListItem = cell
            end
        elseif eventType == "ended" and cell then
            local locked = landItem.locked or 1
            local stage_status = landItem.stage_status or 1 -- 1. 可以点击　　2. 灰色不可点击　3. 已经激活  4. 已经点击过 
            if stage_status == 1 then 
                if locked == 1 then
                    game_util:addMoveTips({text = "Đã kích hoạt, đánh bại quái vật xung\n quanh có thể tìm kiếm khu vực này"}) --已经激活,击败周围怪物方可探索该区域
                    return
                end
                -- game_util:addMoveTips({text = "可以点击"})
            elseif stage_status == 2 then
                -- game_util:addMoveTips({text = "灰色不可点击"})
                return
            elseif stage_status == 3 then
                if locked == 1 then
                    game_util:addMoveTips({text = "Đã kích hoạt, đánh bại quái vật xung\n quanh có thể tìm kiếm khu vực này"})
                    return
                else
                    -- game_util:addMoveTips({text = "已经激活"})
                end
            elseif stage_status == 4 then
                -- game_util:addMoveTips({text = "已经点击过该区域"})
                return
            end
            self:miningClickStage(index,landItem,cell,itemSize)
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function game_activity_mine_game.refreshTableView(self)
    self.m_map_layer:removeAllChildrenWithCleanup(true);
    local tempTableView = self:createTableView(self.m_map_layer:getContentSize());
    tempTableView:setMoveFlag(false)
    tempTableView:setScrollBarVisible(false)
    self.m_map_layer:addChild(tempTableView);
    self.m_list_item_anim_flag = false
end
--[[
    
]]
function game_activity_mine_game.miningClickStage(self,index,landItem,cell,itemSize)
    local icon = landItem.icon or ""
    local sort = landItem.sort or 0
    local stage_status = landItem.stage_status or 1 -- 1. 可以点击　　2. 灰色不可点击　3. 已经激活  4. 已经点击过 
    local function responseMethod(tag,gameData)
        local pX,pY = cell:getPosition()
        local startPos = cell:getParent():convertToWorldSpace(ccp(pX+itemSize.width*0.5,pY+itemSize.height*0.5))
        if stage_status == 1 or (stage_status == 3 and sort == 6) then
            local actionName = nil
            if stage_status == 3 and sort == 6 then
                actionName = "impact1"  -- impact  打开  impact1      打人 
            end
            local tempAnim = game_util:createUniversalAnim({animFile = "anim_saolei",rhythm = 1.0,loopFlag = false,animCallFunc = nil,endCallFunc = nil,actionName = actionName});
            if tempAnim then
                tempAnim:setScale(0.75)
                tempAnim:setPosition(startPos)
                game_scene:getPopContainer():addChild(tempAnim)
            end
        end
        self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
        local remain_blood = self.m_tGameData.remain_blood or 0 -- 剩余血量
        if remain_blood > 0 then
            local reward = self.m_tGameData.reward or {}
            game_util:rewardTipsByDataTable(reward)
        else
            game_scene:addPop("game_activity_mine_over_pop",{gameData = self.m_tGameData})
        end
        self.m_weapon_or_key_anim_flag = false
        local weapon_num = self.m_tGameData.weapon_num or 0 -- 武器
        local key_num = self.m_tGameData.key_num or 0 -- 钥匙
        if weapon_num > self.m_temp_weapon_num or key_num > self.m_temp_key_num then
            local iconSpri = game_util:createIconByName(icon)
            if iconSpri then
                self.m_weapon_or_key_anim_flag = true
                iconSpri:setPosition(startPos)
                local endPos = ccp(0,0)
                if weapon_num > self.m_temp_weapon_num then
                    local pX,pY = self.m_weapon_coin:getPosition()
                    endPos = self.m_weapon_coin:getParent():convertToWorldSpace(ccp(pX,pY))
                end
                if key_num > self.m_temp_key_num then
                    local pX,pY = self.m_key_coin:getPosition()
                    endPos = self.m_key_coin:getParent():convertToWorldSpace(ccp(pX,pY))
                end
                local function remove_node( node )
                    node:removeFromParentAndCleanup(true);
                    self:refreshWeaponAndKey()
                end
                local arr = CCArray:create()
                arr:addObject(CCEaseIn:create(CCMoveTo:create(1,endPos),5))
                arr:addObject(CCScaleTo:create(0.3,0.75))
                arr:addObject(CCCallFuncN:create(remove_node))
                iconSpri:runAction(CCSequence:create(arr))
                game_scene:getPopContainer():addChild(iconSpri)
            end
        end
        self.m_temp_weapon_num = weapon_num
        self.m_temp_key_num = key_num
        if sort == 5 then--门
            self.m_list_item_anim_flag = true
        end
        self:refreshUi()
    end
    require("game_ui.game_loading").show({opacity = 1}); 
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("mining_click_stage"), http_request_method.GET, {pos = index + 1},"mining_click_stage")
end
--[[
    
]]
function game_activity_mine_game.refreshWeaponAndKey(self)
    local weapon_num = self.m_tGameData.weapon_num or 0 -- 武器
    local key_num = self.m_tGameData.key_num or 0 -- 钥匙
    if key_num > 0 then
        self.m_key_coin:setColor(ccc3(255,255,255))
        -- self.m_key_label:setString(tostring(key_num))
    else
        self.m_key_coin:setColor(ccc3(88,88,88))
        -- self.m_key_label:setString("")
    end
    if weapon_num > 0 then
        self.m_weapon_coin:setColor(ccc3(255,255,255))
        -- self.m_weapon_label:setString(tostring(weapon_num))
    else
        self.m_weapon_coin:setColor(ccc3(88,88,88))
        -- self.m_weapon_label:setString("")
    end
end

--[[--
    刷新ui
]]
function game_activity_mine_game.refreshUi(self)
    self:refreshTableView()
    local layer_num = self.m_tGameData.layer_num or 0 -- 当前层数
    local round_num = self.m_tGameData.round_num or 0 -- 回合数
    local kill_enemy_num = self.m_tGameData.kill_enemy_num or 0 -- 杀死怪物数
    local bottle_num = self.m_tGameData.bottle_num or 0 -- 血瓶总数
    local remain_blood = self.m_tGameData.remain_blood or 0 -- 剩余血量
    local max_blood = self.m_tGameData.max_blood or 100 -- 英雄最大血量
    local fight_force = self.m_tGameData.fight_force or 0 -- 战斗力
    self.m_bar:setCurValue(math.min(100,100*remain_blood/math.max(max_blood,1)),false)
    self.m_bar_value_label:setString(tostring(remain_blood) .. "/" .. tostring(max_blood))
    if self.m_temp_remain_blood ~= remain_blood then
        local tempNode = self.m_bar_bg:getParent()
        tempNode:stopAllActions()
        tempNode:setPosition(ccp(self.m_temp_bar_parent_pos.x,self.m_temp_bar_parent_pos.y))
        local animArr = CCArray:create();
        animArr:addObject(CCMoveTo:create(0.1,ccp(self.m_temp_bar_parent_pos.x-5,self.m_temp_bar_parent_pos.y)))
        animArr:addObject(CCMoveTo:create(0.1,ccp(self.m_temp_bar_parent_pos.x+5,self.m_temp_bar_parent_pos.y)))
        animArr:addObject(CCMoveTo:create(0.1,ccp(self.m_temp_bar_parent_pos.x,self.m_temp_bar_parent_pos.y)))
        tempNode:runAction(CCSequence:create(animArr))
        self.m_temp_remain_blood = remain_blood
    end
    self.m_item_label_1:setString(tostring(layer_num))
    self.m_item_label_2:setString(tostring(round_num))
    self.m_item_label_3:setString(tostring(kill_enemy_num))
    self.m_item_label_4:setString(tostring(bottle_num))
    local tempValue,_ = game_util:formatValueToString(fight_force,true)
    self.m_combat_label:setString(tostring(tempValue))
    if not self.m_weapon_or_key_anim_flag then
        self:refreshWeaponAndKey()
    end
end
--[[--
    初始化
]]
function game_activity_mine_game.init(self,t_params)
    t_params = t_params or {};
    local gameData = t_params.gameData
    if tolua.type(gameData) == "util_json" then
        self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
    else
        self.m_tGameData = {}
    end
    self.m_temp_weapon_num = self.m_tGameData.weapon_num or 0
    self.m_temp_key_num = self.m_tGameData.key_num or 0
    self.m_temp_remain_blood = self.m_tGameData.remain_blood or 0
    self.m_weapon_or_key_anim_flag = false
    self.m_list_item_anim_flag = true
end

--[[--
    创建ui入口并初始化数据
]]
function game_activity_mine_game.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_activity_mine_game;