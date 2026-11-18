--- 家园商店和仓库

local game_homeLand_shop_pop = {
    m_popUi = nil,
    m_close_btn = nil,
    m_node_tableView = nil,
    m_sprite_title = nil,
    m_type = nil,
    m_tab_btn = nil,
    m_select_tag = nil,
    m_cfg_homeland_adorn = nil,
    m_cfg_homeland_shop = nil,
    m_tab_totalData = nil,
    m_tGameData = nil,
    mBuildType = nil,
    m_selfAdorn = nil,
};
--[[--
    销毁ui
]]
function game_homeLand_shop_pop.destroy(self)
    -- body
    cclog("-----------------game_homeLand_shop_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_node_tableView = nil;
    self.m_close_btn = nil;
    self.m_sprite_title = nil;
    self.m_type = nil;
    self.m_tab_btn = nil;
    self.m_select_tag = nil;
    self.m_cfg_homeland_adorn = nil;
    self.m_cfg_homeland_shop = nil;
    self.m_tab_totalData = nil;
    self.m_tGameData = nil;
    self.mBuildType = nil;
    self.m_selfAdorn = nil;
end
--[[--
    返回
]]
function game_homeLand_shop_pop.back(self,backType)
    self:destroy()
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_homeLand_main",{gameData = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("homeland_index"), http_request_method.GET, nil,"homeland_index")
end
--[[--
    读取ccbi创建ui
]]
function game_homeLand_shop_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        
        elseif btnTag > 100 and btnTag < 104 then
            -- cclog("-----1-----")
            self.m_select_tag = btnTag
            for i=101,103 do
                local tempBtn = self.m_tab_btn[i-100]
                tempBtn:setHighlighted(self.m_select_tag == i);
                tempBtn:setEnabled(self.m_select_tag ~= i);
            end
            self:refreshUi()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_homeLand_shop_pop.ccbi");
    self.m_tab_btn = {}
    local m_btn = nil
    for i=1,3 do
        m_btn = ccbNode:controlButtonForName("m_btn" .. i)
        m_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
        self.m_tab_btn[i] = m_btn
    end
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
    self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")
    self.m_sprite_title = ccbNode:spriteForName("m_sprite_title")
    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建列表
]]
function game_homeLand_shop_pop.createTableView(self,viewSize)
    local curData = self.m_tab_totalData[self.m_select_tag - 100]
    -- cclog2(curData,"curData ---- ")
    -- cclog2(game_util:getTableLen(curData),"game_util:getTableLen(curData) ---- ")
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag > 200 and btnTag < 300 then --购买装饰
            local shopid = curData[btnTag - 200][1]
            local params = {}
            params.shop_id = shopid
            local function responseMethod(tag,gameData)
                cclog2(gameData,"gameData -buy--- ")
                local data = gameData:getNodeWithKey("data")
                local use_adorn = json.decode(data:getNodeWithKey("store"):getFormatBuffer()) 
                self.m_selfAdorn = use_adorn
                self:getConfigDataByType()
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("homeland_shop_buy"), http_request_method.GET, params,"homeland_shop_buy")
        elseif btnTag > 300 and btnTag < 400 then -- 预览
            local shopid = curData[btnTag - 300][1]
            -- cclog2(shopid,"shopId ----")
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_homeLand_main",{gameData = gameData,types = "look",lookId = shopid});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("homeland_index"), http_request_method.GET, nil,"homeland_index")
            
        elseif btnTag == 9999 then
            game_util:addMoveTips({text = "Đã mua vật phẩm này, hãy đến Kho sử dụng~"})
        end
        -- if btnTag == 1 then
            
        -- cclog2(curData[btnTag - 200],"curData[btnTag - 200] ====== ")
        -- end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 3; --列
    params.totalItem = game_util:getTableLen(curData);
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6;
    params.direction = kCCScrollViewDirectionHorizontal;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()

            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_homeLand_shopItem.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_node_scale = ccbNode:nodeForName("m_node_scale")
            local m_label_cost = ccbNode:labelTTFForName("m_label_cost")
            local m_cost_icon = ccbNode:spriteForName("m_cost_icon")
            local m_btn_look = ccbNode:controlButtonForName("m_btn_look")
            local m_btn_buy = ccbNode:controlButtonForName("m_btn_buy")
            m_btn_buy:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
            m_btn_buy:setTag(index + 201)
            m_btn_look:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
            m_btn_look:setTag(index + 301)
            local m_btn_select = ccbNode:controlButtonForName("m_btn_select")
            m_btn_select:setVisible(false)
            local m_node_cost = ccbNode:nodeForName("m_node_cost")
            -- cclog2(curData,"curData -------")
            m_node_scale:removeAllChildrenWithCleanup(true)
            local itemData = curData[index + 1][2]
            local price = itemData.price
            local iconName = self.m_cfg_homeland_adorn[tostring(itemData.adorn_id)].icon
            local itemType = itemData.type
            -- cclog2(iconName,"iconName ----")
            -- cclog2(itemType,"itemType ----")
            if itemType == 1 then
                m_btn_look:setVisible(true)
                m_btn_buy:setPosition(ccp(31,-53))
                local icon, name, count = game_util:getRewardByItemTable(price[1],_,true)
                if icon then
                    m_node_cost:addChild(icon)
                    icon:setScale(0.3) 
                    m_label_cost:setString(count)
                    local x,y = m_label_cost:getPosition()
                    m_node_cost:setPosition(ccp(x + m_label_cost:getContentSize().width,y))
                else

                end
                local spriteBg = CCSprite:createWithSpriteFrameName(tostring(iconName) .. ".png")
                spriteBg:setScale(0.15)
                m_node_scale:addChild(spriteBg)
            elseif itemType == 2 then
                local icon, name, count = game_util:getRewardByItemTable(price[1],_,true)
                if icon then
                    m_node_cost:addChild(icon)
                    icon:setScale(0.3) 
                    m_label_cost:setString(count)
                    local x,y = m_label_cost:getPosition()
                    m_node_cost:setPosition(ccp(x + m_label_cost:getContentSize().width,y))
                else

                end
                local itemSprite = CCSprite:createWithSpriteFrameName(iconName .. self.mBuildType .. ".png")
                if itemSprite then
                    m_node_scale:addChild(itemSprite)
                else

                end
                m_btn_look:setVisible(false)
                m_btn_buy:setPosition(ccp(-1,-53))
            elseif itemType == 3 then
                m_btn_look:setVisible(true)
                m_btn_buy:setPosition(ccp(31,-53))
                local icon, name, count = game_util:getRewardByItemTable(price[1],_,true)
                if icon then
                    m_node_cost:addChild(icon)
                    icon:setScale(0.3) 
                    m_label_cost:setString(count)
                    local x,y = m_label_cost:getPosition()
                    m_node_cost:setPosition(ccp(x + m_label_cost:getContentSize().width,y))
                else

                end
                local function stepEnd( animNode,theId,labelName )
                    game_anim:playSection(animNode,labelName)
                end
                local animFile = iconName
                local scaleNum = 0.1
                if animFile == "chaojitexiao_xuedi" then
                    animFile = "xuetexiao"
                elseif animFile == "chaojitexiao_meigui" then
                    animFile = "changjingtexiao"
                    scaleNum = 0.15
                end
                -- cclog2(animFile,"animFile 22------")

                local animShouzhi = zcAnimNode:create("changjingtexiao" .. ".swf.sam",1,"changjingtexiao" .. ".plist");
                animShouzhi:registerScriptTapHandler(stepEnd);
                animShouzhi:playSection(animFile .. "_1")
                m_node_scale:addChild(animShouzhi);
                animShouzhi:setScale(scaleNum)
                local viewSize = m_node_scale:getContentSize()
                animShouzhi:setPosition(ccp(viewSize.width * 0.5,viewSize.height * 0.5))
            end

            if self:isGetAdorn(self.m_selfAdorn,itemData.adorn_id) then
                game_util:setCCControlButtonBackground(m_btn_buy,"ui_homeLandSys_btnBuy2.png")
                m_btn_buy:setTouchEnabled(false)
                m_btn_look:setTag(9999)
            else
                game_util:setCCControlButtonBackground(m_btn_buy,"ui_homeLandSys_btnBuy.png")
                m_btn_buy:setTouchEnabled(true)
                m_btn_look:setTag(index + 301)
            end
            -- cclog2(iconName,"iconName ==== ")
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then
        end
    end
    return TableViewHelper:createGallery2(params);
end

function game_homeLand_shop_pop.createTableView2(self,viewSize)
    local curData = self.m_tab_totalData[self.m_select_tag - 100]
    -- cclog2(curData,"curData ---- ")
    -- cclog2(game_util:getTableLen(curData),"game_util:getTableLen(curData) ---- ")
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local shopid = 0 
        local params = {}
        if btnTag < 300 then --使用 
            params.adorn_id = curData[btnTag - 200][1]
            local function responseMethod(tag,gameData)
                -- cclog2(gameData,"gameData ---- ")
                game_util:addMoveTips({text = "Dùng thành công"})
                local data = gameData:getNodeWithKey("data")
                local use_adorn = json.decode(data:getNodeWithKey("use_adorn"):getFormatBuffer()) 
                self.m_selfAdorn = use_adorn
                self:getConfigDataByType()
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("homeland_use_adorn"), http_request_method.GET, params,"homeland_use_adorn")
        else -- 取消选用
            params.adorn_id = curData[btnTag - 300][1]
            
            local function responseMethod(tag,gameData)
                -- cclog2(gameData,"gameData ---- ")
                game_util:addMoveTips({text = "Hủy dùng"})
                local data = gameData:getNodeWithKey("data")
                local use_adorn = json.decode(data:getNodeWithKey("use_adorn"):getFormatBuffer()) 
                self.m_selfAdorn = use_adorn
                self:getConfigDataByType()
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("homeland_cancel_adorn"), http_request_method.GET, params,"homeland_cancel_adorn")
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 3; --列
    params.totalItem = game_util:getTableLen(curData);
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6;
    params.direction = kCCScrollViewDirectionHorizontal;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()

            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_homeLand_shopItem.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_node_scale = ccbNode:nodeForName("m_node_scale")
            m_node_scale:removeAllChildrenWithCleanup(true)
            local m_node_shop = ccbNode:nodeForName("m_node_shop")
            m_node_shop:setVisible(false)
            local m_btn_select = ccbNode:controlButtonForName("m_btn_select")
            m_btn_select:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
            m_btn_select:setTag(index + 201)
            local itemData = curData[index + 1][2]
            -- cclog2(curData,"curData -------")
            local price = itemData.price
            local iconName = itemData.icon
            
            local itemType = itemData.type
            -- cclog2(iconName,"iconName ----")
            -- cclog2(itemType,"itemType ----")
            if itemType == 1 then
                local spriteBg = CCSprite:createWithSpriteFrameName(tostring(iconName) .. ".png")
                spriteBg:setScale(0.15)
                m_node_scale:addChild(spriteBg)
            elseif itemType == 2 then

            
                local itemSprite = CCSprite:createWithSpriteFrameName(iconName .. self.mBuildType .. ".png")
                if itemSprite then
                    m_node_scale:addChild(itemSprite)
                else

                end
            elseif itemType == 3 then
                local function stepEnd( animNode,theId,labelName )
                    game_anim:playSection(animNode,labelName)
                end
                local animFile = iconName
                local scaleNum = 0.1
                if animFile == "chaojitexiao_xuedi" then
                    animFile = "xuetexiao"
                elseif animFile == "chaojitexiao_meigui" then
                    animFile = "changjingtexiao"
                    scaleNum = 0.15
                end
                -- cclog2(animFile,"animFile 22------")
                local animShouzhi = zcAnimNode:create("changjingtexiao" .. ".swf.sam",1,"changjingtexiao" .. ".plist");
                animShouzhi:registerScriptTapHandler(stepEnd);
                animShouzhi:playSection(animFile .. "_1")
                m_node_scale:addChild(animShouzhi);
                animShouzhi:setScale(scaleNum)
                local viewSize = m_node_scale:getContentSize()
                animShouzhi:setPosition(ccp(viewSize.width * 0.5,viewSize.height * 0.5))
            end
            if self:isGetAdorn(self.m_selfAdorn,curData[index + 1][1]) then
                game_util:setCCControlButtonBackground(m_btn_select,"ui_homeLandSys_btnCancel.png")
                -- m_btn_select:setTouchEnabled(false)
                m_btn_select:setTag(index + 301)
            else
                game_util:setCCControlButtonBackground(m_btn_select,"ui_homeLandSys_btnSelect.png")
                -- m_btn_select:setTouchEnabled(true)
                m_btn_select:setTag(index + 201)
            end
            -- cclog2(iconName,"iconName ==== ")
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then
        end
    end
    return TableViewHelper:createGallery2(params);
end
function game_homeLand_shop_pop.isGetAdorn( self,myAdornTab,adornId )
    if myAdornTab[tostring(adornId)] then  
        return true
    end
    return false
end
function game_homeLand_shop_pop.getConfigDataByType( self )
    local tempTab = {}
    self.m_tab_totalData = {}
    local playerLv = game_data:getUserStatusDataByKey("level")
    -- cclog2(self.m_selfAdorn,"m_selfAdorn ----- ")
    if self.m_type == "shop" then
        for shopId,v in pairs(self.m_cfg_homeland_shop) do
            if not(self.m_tab_totalData[v.type]) then
                self.m_tab_totalData[v.type] = {}
            end
            local uplv,downLv = v.show_level[1][2],v.show_level[1][1]
            if tonumber(playerLv)>= downLv and tonumber(playerLv) < uplv then
                table.insert(self.m_tab_totalData[v.type],{shopId,v})
            end
        end
        for adornId,num in pairs(self.m_selfAdorn) do
            tempTab[tostring(adornId)] = "1"
        end

    elseif self.m_type == "capot" then
        
        local dataTab = self.m_tGameData.store
        for c_id,v in pairs(dataTab) do

            local types = self.m_cfg_homeland_adorn[tostring(c_id)].type
            if not(self.m_tab_totalData[types]) then
                self.m_tab_totalData[types] = {}
            end
            table.insert(self.m_tab_totalData[types],{c_id,self.m_cfg_homeland_adorn[tostring(c_id)]})
        end
        for types,adornId in pairs(self.m_selfAdorn) do
            tempTab[tostring(adornId)] = "1"
        end
    end
    -- cclog2(tempTab,"tempTab =====")
    self.m_selfAdorn = tempTab
    
end

--[[--
    刷新ui
]]
function game_homeLand_shop_pop.refreshUi(self)
    self.m_node_tableView:removeAllChildrenWithCleanup(true);
   
    if self.m_type == "shop" then
        self.m_sprite_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_homeLandSys_titleHomeShop.png"));
        local tableViewTemp = self:createTableView(self.m_node_tableView:getContentSize());
        self.m_node_tableView:addChild(tableViewTemp);
    elseif self.m_type == "capot" then
        self.m_sprite_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_homeLandSys_titleCangku.png"));
        local tableViewTemp = self:createTableView2(self.m_node_tableView:getContentSize());
        self.m_node_tableView:addChild(tableViewTemp);
    end

    self.m_tab_btn[self.m_select_tag-100]:setHighlighted(true);
end
--[[--
    初始化
]]
function game_homeLand_shop_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_tab_totalData = {}
    if t_params.types then
        self.m_type = t_params.types
    end

    if t_params.gameData then
        local data = t_params.gameData:getNodeWithKey("data")
        data = json.decode(data:getFormatBuffer())
        self.m_tGameData = data
    end
    self.m_selfAdorn = {}
    if t_params.use_adorn then
        self.m_selfAdorn = t_params.use_adorn
    end
    self.m_select_tag = 101
    self.m_cfg_homeland_adorn = json.decode(getConfig(game_config_field.homeland_adorn):getFormatBuffer())
    self.m_cfg_homeland_shop = json.decode(getConfig(game_config_field.homeland_shop):getFormatBuffer())
    self:getConfigDataByType()
    self.mBuildType = 2
end

--[[--
    创建ui入口并初始化数据
]]
function game_homeLand_shop_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return game_homeLand_shop_pop;