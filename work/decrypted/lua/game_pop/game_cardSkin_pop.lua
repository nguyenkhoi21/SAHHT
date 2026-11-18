--- 
local game_cardSkin_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_node_tableView = nil,
    m_close_btn = nil,
    m_cId = nil,
    m_tab_skinId = nil,
    m_cardData = nil,
    m_select_index = nil,
    m_label_attr = nil,
    m_sprite_icon1 = nil,
    m_sprite_icon2 = nil,
    m_node_attr = nil,
    m_skinData = nil,
    m_isUse_skin = nil,
    fromtype = nil,
    m_callback = nil,
};
--[[--
    销毁
]]
function game_cardSkin_pop.destroy(self)
    -- body
    cclog("-----------------game_cardSkin_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_node_tableView = nil;
    self.m_cId = nil;
    self.m_tab_skinId = nil;
    self.m_cardData = nil;
    self.m_select_index = nil;
    self.m_label_attr = nil;
    self.m_sprite_icon1 = nil;
    self.m_sprite_icon2 = nil;
    self.m_node_attr = nil;
    self.m_skinData = nil;
    self.m_isUse_skin = nil;
    self.fromtype = nil;
    self.m_callback = nil;
end
--[[--
    返回
]]
function game_cardSkin_pop.back(self,type)
    if self.fromtype == "newRichMan_bigBoss_hero" then
        self.m_callback()
        game_scene:removePopByName("game_cardSkin_pop")
    else
        game_scene:enterGameUi("game_main_scene",{gameData = nil});
    end
end
--[[--
    读取ccbi创建ui
]]
function game_cardSkin_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
            -- cclog2(btnTag,"btnTag ---- ")
        if btnTag == 1 then--关闭
            game_scene:removePopByName("game_cardSkin_pop")
        elseif btnTag == 2 then--  
            local params = {}
            params.skin_ids = ""
            local use_skin = game_data:getCurCardSkinData()
            for k,v in pairs(use_skin) do
                if tostring(self.m_isUse_skin) ~= tostring(v) then
                    params.skin_ids = params.skin_ids .. (k == 1 and "" or "_") .. v
                end
            end
            if self.m_select_index > 1 then 
                params.skin_ids = params.skin_ids .. (params.skin_ids == "" and "" or "_") .. self.m_tab_skinId[self.m_select_index]--
            else
                -- params.skin_ids = params.skin_ids .. (params.skin_ids == "" and "0" or "_0")
            end
            local function responseMethod(tag,gameData)
               -- cclog2(gameData,"gameData --- ")
               self:back()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_use_skin"), http_request_method.GET, params, "cards_use_skin")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_cardSkin_pop.ccbi");

    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    -- self.cost_label = ccbNode:labelBMFontForName("cost_label")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-16)
    self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")

    self.m_label_attr = ccbNode:labelTTFForName("m_label_attr")
    self.m_sprite_icon1 = ccbNode:spriteForName("m_sprite_icon1")
    self.m_sprite_icon2 = ccbNode:spriteForName("m_sprite_icon2")
    self.m_node_attr = ccbNode:nodeForName("m_node_attr")
    self.m_node_attr:setVisible(false)
    local btn_sure = ccbNode:controlButtonForName("m_btn_sure")
    btn_sure:setTouchPriority(GLOBAL_TOUCH_PRIORITY-16)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-16,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

function game_cardSkin_pop.refreshAttr( self, skinData )
    -- cclog2(skinData,"skinData ==== ")
    local spName = { "public_icon_phsc.png", "public_icon_mgc.png", "public_icon_dfs.png", "public_icon_speed.png","public_icon_hp.png"}
    for i=1,2 do
        local attrType = skinData[1]
        local attrValue = skinData[2]
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spName[attrType])
        if tempSpriteFrame then
           self.m_sprite_icon2:setDisplayFrame(tempSpriteFrame)
           self.m_sprite_icon1:setDisplayFrame(tempSpriteFrame)
        end
        self.m_label_attr:setString("+" .. tostring(attrValue))

    end

    -- body
end
function game_cardSkin_pop.getAllSkinId( self )
    local mySkinData = game_data:getCardSkinData()
    return mySkinData

end
function game_cardSkin_pop.createTableView( self )
    local sp_tab = {}
    local params = {};
    local viewSize = self.m_node_tableView:getContentSize();
    params.viewSize = viewSize
    params.row = 1;--行
    params.column = 2; --列
    params.totalItem = 2 
    params.direction = kCCScrollViewDirectionHorizontal;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 16 
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    local function onCellBtnClick( target, event  )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local character_skin = getConfig(game_config_field.character_skin)
        local costData = character_skin:getNodeWithKey(tostring(self.m_tab_skinId[btnTag])):getNodeWithKey("open_cost")
        -- cclog2(costData,"costData ==== ")
        costData = json.decode(costData:getFormatBuffer())
        --cclog2(costData[1],"costData-=-==-=--------------")
        local icon, name, count = game_util:getRewardByItemTable(costData[1])
        local t_params = 
        {
            title = "Nhắc nhở",
            okBtnCallBack = function(target,event)
                require("game_ui.game_pop_up_box").close();
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    local skin = data:getNodeWithKey("skin")
                    skin = json.decode(skin:getFormatBuffer())
                    self.m_select_index = 2
                    -- self:refreshAttr(skin)
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_buy_skin"), http_request_method.GET, {skin_id = self.m_tab_skinId[btnTag] },"cards_buy_skin")
            end,   --可缺省
            okBtnText = "Xác nhận",       --可缺省
            text ="Tốn" .. count .. name .. "mở khóa skill?", 
            cancelBtnCallBack = function(target,event)
                game_util:closeAlertView();
            end,
            cancelBtnText = "Hủy",
            onlyOneBtn = false,     --可缺省
            closeFlag = false,
        }
        require("game_ui.game_pop_up_box").show(t_params);
    end
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_cardSkin_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_node_hero = ccbNode:nodeForName("m_node_hero")
            m_node_hero:removeAllChildrenWithCleanup(true)
            local character_detail_cfg = getConfig(game_config_field.character_detail);
            local itemId = self.m_tab_skinId[index + 1]
            local heroCfg = character_detail_cfg:getNodeWithKey(tostring(itemId));
            --cclog2(character_detail_cfg,"character_detail_cfg-=------------123-=-=")
            --cclog2(heroCfg,"heroCfg-=-=-=----------")
            --cclog2(itemId,"itemId-=-=-=----------")
            local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
            local animNode = game_util:createIdelAnim(ainmFile,0);
            if animNode then
                animNode:setRhythm(1);
                game_anim:playSection(animNode , anim_label_name_cfg.daiji);
                animNode:setAnchorPoint(ccp(0.5,0));
                animNode:setPosition(ccp(0,-75))
                m_node_hero:addChild(animNode);
            end
            local m_sp_light = ccbNode:spriteForName("m_sp_light")
            local m_label_name = ccbNode:labelTTFForName("m_label_name")
            local heroName = heroCfg:getNodeWithKey("name"):toStr()
            m_label_name:setString(heroName)
            -- m_sp_light:setVisible(false)
            sp_tab[tostring(index + 1)] = m_sp_light
            local flag = game_util:isWearSkin(itemId)
            if flag then
                self.m_isUse_skin = itemId
            end
            -- cclog2(self.m_select_index,"m_select_index --- ")
            if index+1 == self.m_select_index  then
                m_sp_light:setVisible(true)    
            else
                m_sp_light:setVisible(false)    
            end
           
            local btn_lock = ccbNode:controlButtonForName("m_btn_lock")
            btn_lock:setTag(index + 1)
            btn_lock:setTouchPriority(GLOBAL_TOUCH_PRIORITY-16)
            local allSkinId  = self:getAllSkinId()
            local skinFlag = false
            for k,v in pairs(allSkinId) do
                if tostring(k) == tostring(itemId) then
                    skinFlag = true
                    break
                else
                    skinFlag = false
                end
            end
            if index > 0 and skinFlag == false then
                btn_lock:setVisible(true)
                animNode:setColor(ccc3(50,50,50))
            else
                animNode:setColor(ccc3(255,255,255))
                btn_lock:setVisible(false)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if eventType == "ended" and cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            for k,v in pairs(sp_tab) do
                v:setVisible(false)
            end
            local m_sp_light = ccbNode:spriteForName("m_sp_light")
            m_sp_light:setVisible(true)
            self.m_select_index = index + 1
            local itemId = self.m_tab_skinId[index + 1]
            if index > 0 then
                local allSkinId  = self:getAllSkinId()
                for k,v in pairs(allSkinId) do
                    self.m_node_attr:setVisible(true)
                    if tostring(k) == tostring(itemId) then
                        self:refreshAttr(v)
                    else
                    end
                end
            else
                self.m_node_attr:setVisible(false)
            end
        end
    end
    return TableViewHelper:create(params);
end


--[[--
    刷新ui
]]
function game_cardSkin_pop.refreshUi(self)

    -- cclog2(self.m_select_index," ==001------")
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(self.m_cId));
    table.insert(self.m_tab_skinId,self.m_cId)
    if heroCfg:getNodeWithKey("is_skin") then
        if heroCfg:getNodeWithKey("is_skin") ~= 0 then
            table.insert(self.m_tab_skinId,heroCfg:getNodeWithKey("is_skin"):toInt())
        end
    end

    local itemId = self.m_tab_skinId[2]
    -- cclog2(itemId,"itemId ----")
    local flag = game_util:isWearSkin(itemId)
    -- cclog2(flag,"flag ---")
    if flag then 
        self.m_select_index = 2
    else
        self.m_select_index = 1
    end
    
    self.m_node_tableView:removeAllChildrenWithCleanup(true)
    local tableView = self:createTableView()
    self.m_node_tableView:addChild(tableView)


    if self.m_select_index > 1 then
        local allSkinId  = self:getAllSkinId()
        for k,v in pairs(allSkinId) do
            self.m_node_attr:setVisible(true)
            if tostring(k) == tostring(itemId) then
                self:refreshAttr(v)
            else
            end
        end
    else
        self.m_node_attr:setVisible(false)
    end
end
--[[--
    初始化
]]
function game_cardSkin_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    self.m_skinData = {}
    -- cclog("self.m_tParams == " .. json.encode(self.m_tParams))
    self.openType = t_params.openType or 1
    self.m_cId = t_params.c_id
    self.m_tab_skinId = {}
    self.m_cardData = {}
    if t_params.cardData then
        self.m_cardData = t_params.cardData
    end
    self.m_select_index = 1
    self.m_isUse_skin = ""
    self.fromtype = t_params.fromtype
    --cclog2(t_params)
    self.m_callback = t_params.callback
end
--[[--
    创建ui入口并初始化数据
]]
function game_cardSkin_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_cardSkin_pop;