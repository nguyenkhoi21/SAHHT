-- 英魂选择界面
local game_soul_select_pop = {
    m_list_view_bg = nil,
    m_tableView = nil,
    m_selSort = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_title_label = nil,
    m_popUi = nil,
    m_func_btn = nil,
    callBackFunc = nil,
    soulPos = nil,
    itemSoulData = nil,
    gameData = nil,
    soul_sort = nil,
    changeType = nil,
    sort = nil,
    flag = nil,
};
--[[--
    销毁ui
]]
function game_soul_select_pop.destroy(self)
    -- body
    cclog("-----------------game_soul_select_pop destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_tableView = nil;
    self.m_selSort = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_title_label = nil;
    self.m_popUi = nil;
    self.m_func_btn = nil;
    self.callBackFunc = nil;
    self.soulPos = nil;
    self.itemSoulData = nil;
    self.gameData = nil;
    self.soul_sort = nil;
    self.changeType = nil;
    self.sort = nil;
    self.flag = nil;
end

--[[--
    返回
]]
function game_soul_select_pop.back(self,type)
    game_scene:removePopByName("game_soul_select_pop")
end
--[[--
    读取ccbi创建ui
]]
function game_soul_select_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 2 then
            local function btnCallBack(btnTag)
                cclog("btnCallBack ===========btnTag===" .. btnTag)
                local function responseMethod(tag,gameData)
                    if btnTag == 2 then
                        self.sort = 0  --按品质排
                    elseif btnTag == 1 then
                        self.sort = 1  --按id排
                    end
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_soul_index"), http_request_method.GET, nil,"soul_index")
            end
            game_scene:addPop("game_sort_pop",{btnTitleTab = {{sortName = "Mặc định",sortType = 1},{sortName = "Phẩm chất",sortType = 0}},btnCallFunc = btnCallBack,currentSortType = self.sort})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_list.ccbi");
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    -- self.m_sort_btn:setVisible(false)
    self.m_func_btn = ccbNode:controlButtonForName("m_func_btn")
    self.m_func_btn:setVisible(true)
    game_util:setCCControlButtonTitle(self.m_func_btn,"Nhận được Anh Hồn")
    self.m_title_label = ccbNode:labelBMFontForName("m_title_label")
    self.m_title_label:setString("Danh sách Anh Hồn")
    self.m_func_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12);
    self.m_func_btn:setVisible(false)
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
    self.m_sort_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-11,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建装备列表
]]
function game_soul_select_pop.createTableView(self,viewSize)
    local soulCfg = getConfig(game_config_field.soul_detail)
    --应该取客户端数据，然后控制上下勋章
    local tableData = game_data:getSoulData()

    local showDataKey = {}
    for k,v in pairs(tableData) do
        table.insert( showDataKey, k )
    end
    --排下序
    self.soulIdPos = {}
    for key,soulTable in pairs(game_data:getSoulPos()) do
        for k,v in pairs(soulTable) do
            if v ~= "0" and v ~= "-1" then
                self.soulIdPos[v] = 1
            end
        end
    end
    --先判断是否穿在身上
    local flag1,flag2
    local function sortFunc(data1,data2)
        local itemData1 = tableData[data1]
        local itemData2 = tableData[data2]
        local s_id1 = itemData1.s_id
        local s_id2 = itemData2.s_id
        local itemCfg1 = soulCfg:getNodeWithKey(tostring(s_id1))
        local itemCfg2 = soulCfg:getNodeWithKey(tostring(s_id2))
        
        local exp1 = tableData[data1].exp + tableData[data1].pre_exp
        local exp2 = tableData[data2].exp + tableData[data2].pre_exp

        flag1 = self.soulIdPos[data1] or 0
        flag2 = self.soulIdPos[data2] or 0
        if flag1 == flag2 then
            if self.sort == 0 then--按品质排序
                local quality1 = itemCfg1:getNodeWithKey("quality"):toInt()
                local quality2 = itemCfg2:getNodeWithKey("quality"):toInt()
                return quality1 > quality2
            else
                if s_id1 == s_id2 then
                    return tonumber(exp1) > tonumber(exp2)
                else
                    return s_id1 > s_id2
                end
            end
        else
            return flag1 > flag2
        end
    end
    table.sort( showDataKey, sortFunc )

    local itemsCount = game_util:getTableLen(showDataKey) + 1
    local totalItem = itemsCount
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = itemsCount
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- print("sdfgsgsgdfohdfhod")
            local ccbNode = game_util:createSoulItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            
            -- if index < itemsCount then
                if index == 0 then
                    m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg2.png"))
                    m_spr_bg_up:setVisible(true);
                    ccbNode:nodeForName("m_info_node"):setVisible(false);
                else
                    m_spr_bg_up:setVisible(false);
                    local key = showDataKey[index]
                    local itemData = {}
                    itemData.c_id = key
                    local count = tableData[tostring(key)]
                    itemData.count = count
                    game_util:setSoulItemInfoByTable(ccbNode,itemData);

                   local m_team_img = ccbNode:spriteForName("m_team_img")
                    local m_team_name = ccbNode:labelTTFForName("m_team_name")
                    local is_equip,cardName = nil,nil
                    if self.flag == true then

                        is_equip,cardName = game_data:soulInGodSoulPos(key)
                    else
                        cclog2(self.flag,"flag===")
                        is_equip,cardName = game_data:soulInSoulPos(key)
                        cclog2(key,"key")
                    end
                    if is_equip then
                        m_team_img:setVisible(true)
                        m_team_name:setString(cardName)
                    else
                        m_team_img:setVisible(false)
                    end
                    -- if self.soulIdPos[key] then
                    --     m_team_img:setVisible(true)
                    --     m_team_name:setString("已装备")
                    -- else
                    --     m_team_img:setVisible(false)
                    -- end
                end
            -- else
            --     m_spr_bg_up:setVisible(true);
            --     ccbNode:nodeForName("m_info_node"):setVisible(false);
            -- end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
            if index == 0 then
                self.callBackFunc("unload","0");
                self:back();
            else
                local key = showDataKey[index]
                local s_id=tableData[key].s_id
                local soulCfg = getConfig(game_config_field.soul_detail);
                local souldata3 = soulCfg:getNodeWithKey(tostring(s_id));
                local sort = souldata3:getNodeWithKey("sort"):toInt();
                -- cclog2(sort,"sort======")
                -- cclog2(self.itemSoulData,"self.itemSoulData====")
                if self.soulIdPos[key] then
                    game_util:addMoveTips({text = "Anh Hồn này đã được mặc!"})
                else
                    if self.itemSoulData then
                        for i=1,#self.itemSoulData do
                            local soulId = self.itemSoulData[i]
                            local soulSata,soulCfg = game_data:getSoulDataById(soulId)
                            if soulSata and soulCfg then
                                local haveSort = soulCfg:getNodeWithKey("sort"):toInt();
                                --判断是否是换
                                if haveSort == sort then
                                    if self.changeType == 1 then
                                        game_util:addMoveTips({text = "Không thể mặc cùng 1 loại Anh Hồn!"})
                                        return
                                    elseif self.changeType == 2 then
                                        local id = self.itemSoulData[self.soulPos]
                                        local soulData,soulCfg = game_data:getSoulDataById(id)
                                        local select_sort = soulCfg:getNodeWithKey("sort"):toInt()
                                        -- cclog2(select_sort,"select_sort")
                                        if sort ~= select_sort then
                                            game_util:addMoveTips({text = "Không thể mặc cùng 1 loại Anh Hồn!"})
                                            return
                                        end
                                    end
                                end
                            end
                            -- if key == self.itemSoulData[i] or self.soul_sort == sort then
                            --     game_util:addMoveTips({text = "不能装备同一种英魂！"})
                            --     return
                            -- end
                        end
                    end
                    self.callBackFunc("exchange",key);
                    self:back()
                end
            end
        end
    end
    return TableViewHelper:createGallery2(params);
end


function game_soul_select_pop.createTableView2(self,viewSize)
    local soulCfg = getConfig(game_config_field.soul_detail)
    --应该取客户端数据，然后控制上下勋章
    local tableData = game_data:getSoulData()

    local showDataKey = {}
    for k,v in pairs(tableData) do
        table.insert( showDataKey, k )
    end
    --排下序
    self.soulIdPos = {}
    local tempAllsoul = game_data:getAllGodSoulPosData();
    for i=1,3 do
        for key,soulTable in pairs(tempAllsoul[i]) do
            for k,v in pairs(soulTable) do
                if v ~= "0" and v ~= "-1" then
                    self.soulIdPos[v] = 1
                end
            end
        end
    end
    
    --先判断是否穿在身上
    local flag1,flag2
    local function sortFunc(data1,data2)
        local itemData1 = tableData[data1]
        local itemData2 = tableData[data2]
        local s_id1 = itemData1.s_id
        local s_id2 = itemData2.s_id
        local itemCfg1 = soulCfg:getNodeWithKey(tostring(s_id1))
        local itemCfg2 = soulCfg:getNodeWithKey(tostring(s_id2))
        
        local exp1 = tableData[data1].exp + tableData[data1].pre_exp
        local exp2 = tableData[data2].exp + tableData[data2].pre_exp

        flag1 = self.soulIdPos[data1] or 0
        flag2 = self.soulIdPos[data2] or 0
        if flag1 == flag2 then
            if self.sort == 0 then--按品质排序
                local quality1 = itemCfg1:getNodeWithKey("quality"):toInt()
                local quality2 = itemCfg2:getNodeWithKey("quality"):toInt()
                return quality1 > quality2
            else
                if s_id1 == s_id2 then
                    return tonumber(exp1) > tonumber(exp2)
                else
                    return s_id1 > s_id2
                end
            end
        else
            return flag1 > flag2
        end
    end
    table.sort( showDataKey, sortFunc )

    local itemsCount = game_util:getTableLen(showDataKey) + 1
    local totalItem = itemsCount
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = itemsCount
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- print("sdfgsgsgdfohdfhod")
            local ccbNode = game_util:createSoulItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            
            -- if index < itemsCount then
                if index == 0 then
                    m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg2.png"))
                    m_spr_bg_up:setVisible(true);
                    ccbNode:nodeForName("m_info_node"):setVisible(false);
                else
                    m_spr_bg_up:setVisible(false);
                    local key = showDataKey[index]
                    local itemData = {}
                    itemData.c_id = key
                    local count = tableData[tostring(key)]
                    itemData.count = count
                    game_util:setSoulItemInfoByTable(ccbNode,itemData);

                    local m_team_img = ccbNode:spriteForName("m_team_img")
                    local m_team_name = ccbNode:labelTTFForName("m_team_name")
                    local is_equip,cardName = nil,nil
                    if self.flag == true then
                        is_equip,cardName = game_data:soulInGodSoulPos(key)
                    else
                        is_equip,cardName = game_data:soulInSoulPos(key)
                    end
                    if is_equip then
                        m_team_img:setVisible(true)
                        m_team_name:setString(cardName)
                    else
                        m_team_img:setVisible(false)
                    end
                    -- if self.soulIdPos[key] then
                    --     m_team_img:setVisible(true)
                    --     m_team_name:setString("已装备")
                    -- else
                    --     m_team_img:setVisible(false)
                    -- end
                end
            -- else
            --     m_spr_bg_up:setVisible(true);
            --     ccbNode:nodeForName("m_info_node"):setVisible(false);
            -- end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
            if index == 0 then
                self.callBackFunc("unload","0");
                self:back();
            else
                local key = showDataKey[index]
                local s_id=tableData[key].s_id
                local soulCfg = getConfig(game_config_field.soul_detail);
                local souldata3 = soulCfg:getNodeWithKey(tostring(s_id));
                local sort = souldata3:getNodeWithKey("sort"):toInt();
                -- cclog2(sort,"sort======")
                -- cclog2(self.itemSoulData,"self.itemSoulData====")
                if self.soulIdPos[key] then
                    game_util:addMoveTips({text = "Anh Hồn này đã được mặc!"})
                else
                    if self.itemSoulData then
                        for i=1,#self.itemSoulData do
                            local soulId = self.itemSoulData[i]
                            local soulSata,soulCfg = game_data:getSoulDataById(soulId)
                            if soulSata and soulCfg then
                                local haveSort = soulCfg:getNodeWithKey("sort"):toInt();
                                --判断是否是换
                                if haveSort == sort then
                                    if self.changeType == 1 then
                                        game_util:addMoveTips({text = "Không thể mặc cùng 1 loại Anh Hồn!"})
                                        return
                                    elseif self.changeType == 2 then
                                        local id = self.itemSoulData[self.soulPos]
                                        local soulData,soulCfg = game_data:getSoulDataById(id)
                                        local select_sort = soulCfg:getNodeWithKey("sort"):toInt()
                                        -- cclog2(select_sort,"select_sort")
                                        if sort ~= select_sort then
                                            game_util:addMoveTips({text = "Không thể mặc cùng 1 loại Anh Hồn!"})
                                            return
                                        end
                                    end
                                end
                            end
                            -- if key == self.itemSoulData[i] or self.soul_sort == sort then
                            --     game_util:addMoveTips({text = "不能装备同一种英魂！"})
                            --     return
                            -- end
                        end
                    end
                    self.callBackFunc("exchange",key);
                    self:back()
                end
            end
        end
    end
    return TableViewHelper:createGallery2(params);
end
--[[--
    刷新列表
]]
function game_soul_select_pop.refreshTableView(self,sort)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true)
    self.m_selSort = sort;
    if self.flag == true then
        self.m_tableView = self:createTableView2(self.m_list_view_bg:getContentSize());
    else
        self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    end
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--
    刷新ui
]]
function game_soul_select_pop.refreshUi(self)
    self:refreshTableView(self.m_selSort);
end
--[[--
    初始化
]]
function game_soul_select_pop.init(self,t_params)
    t_params = t_params or {};
    -- if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
    --     self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    -- end
    self.callBackFunc = t_params.callBackFunc
    self.soulPos = t_params.soulPos
    self.itemSoulData = t_params.itemSoulData
    -- cclog2(self.itemSoulData,"self.itemSoulData")
    self.soul_sort = t_params.soul_sort
    self.changeType = t_params.changeType
    self.flag = t_params.flag or false
    self.soulIdPos = {}
    self.sort = 1
end

--[[--
    创建ui入口并初始化数据
]]
function game_soul_select_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_soul_select_pop;