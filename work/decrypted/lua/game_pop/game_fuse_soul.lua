-- 噬魂

local game_fuse_soul = {
    m_popUi = nil,
    m_root_layer = nil,
    m_list_view_bg = nil, --英魂列表
    gameData = nil,
    m_tableView = nil,
    m_title_label = nil,
    m_icon_spr = nil,
    m_have_label = nil, -- 当前等级
    m_soul_atk = nil, -- 当前能力
    m_uplevel_lab = nil, -- + 等级
    m_up_atk = nil, -- + 能力
    m_bar_bg = nil, --经验条效果
    m_exp_lab = nil, --经验
    soul_id = nil,
    soul_id_table = nil,
    select_id_table = nil,
    m_up_atk2 = nil,
    m_soul_atk2 = nil,
    abilty_node2 = nil,
};

--[[--
    销毁
]]
function game_fuse_soul.destroy(self)
    -- body
    cclog("-----------------game_fuse_soul destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_list_view_bg = nil;
    self.m_tableView = nil;
    self.gameData = nil;
    self.m_title_label = nil; 
    self.m_have_label = nil;
    self.m_icon_spr = nil;
    self.m_have_label = nil; -- 当前等级
    self.m_soul_atk = nil; -- 当前能力
    self.m_uplevel_lab = nil; -- + 等级
    self.m_up_atk = nil; -- + 能力
    self.m_bar_bg = nil; --经验条效果
    self.m_exp_lab = nil; --经验
    self.soul_id = nil;
    self.soul_id_table = nil;
    self.select_id_table = nil;
    self.m_up_atk2 = nil;
    self.m_soul_atk2 = nil;
    self.abilty_node2 = nil;
end
--[[--
    返回
]]
function game_fuse_soul.back(self,type)
    -- game_scene:removePopByName("game_fuse_soul");
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_soul_list",{gameData = gameData});
        self:destroy();
     end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_all_soul"), http_request_method.GET, nil,"soul_index")   
end
--[[--
    读取ccbi创建ui
]]
function game_fuse_soul.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then--升级
            local params = "major=" .. self.soul_id
            if #self.select_id_table > 0 then
                for i=1,#self.select_id_table do
                    params = params .. "&metal=" .. self.select_id_table[i]
                end
            else
                game_util:addMoveTips({text = "Xin thêm Anh Hồn!"})
                return
            end
            cclog2(params,"params")
            local function responseMethod(tag,gameData)
                -- cclog2(gameData,"gameData")
                --重置数据，刷新
                self.select_id_table = {}
                self:refreshUi()
                --加提示信息
                local itemData = game_data:getSoulData()[self.soul_id]
                local last_level = self.back_soul_data.lv
                if itemData.lv > last_level then
                    game_util:addMoveTips({text = "Nâng cấp thành công!"})
                else
                    game_util:addMoveTips({text = "Nuốt thành công!"})
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_eat_soul"), http_request_method.GET, params,"soul_eat_soul")
        elseif btnTag == 3 then--一键选择
            local function callBack(fuseType)
                cclog2(fuseType,"fuseType")
                self:quickAdd(fuseType)
            end
            game_scene:addPop("game_soul_cell_pop",{callBack = callBack})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_soul_combine_pop.ccbi");
    self.m_title_label = tolua.cast(ccbNode:objectForName("m_title_label"),"CCLabelTTF");
    self.m_soul_atk = tolua.cast(ccbNode:objectForName("m_soul_atk"),"CCLabelTTF");
    self.m_uplevel_lab = tolua.cast(ccbNode:objectForName("m_uplevel_lab"),"CCLabelTTF");
    self.m_up_atk = tolua.cast(ccbNode:objectForName("m_up_atk"),"CCLabelTTF");
    self.m_exp_lab = tolua.cast(ccbNode:objectForName("m_exp_lab"),"CCLabelTTF");
    self.m_bar_bg = ccbNode:nodeForName("m_bar_bg")
    self.abilty_node2 = ccbNode:nodeForName("abilty_node2")
    self.m_soul_atk2 = tolua.cast(ccbNode:objectForName("m_soul_atk2"),"CCLabelTTF");
    self.m_up_atk2 = tolua.cast(ccbNode:objectForName("m_up_atk2"),"CCLabelTTF");

    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local function onTouch( eventType,x,y )
        if(eventType == "began")then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-15,true);
    m_root_layer:setTouchEnabled(true)
    
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"),"CCControlButton");
    local m_left_btn = tolua.cast(ccbNode:objectForName("m_left_btn"),"CCControlButton");
    local m_right_btn = tolua.cast(ccbNode:objectForName("m_right_btn"),"CCControlButton");

    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 16);
    m_left_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-16);
    m_right_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-16)

    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_icon_spr = ccbNode:nodeForName("m_icon_spr")
   
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_fuse_soul.createSoulTableView(self,viewSize)
    local soulCfg = getConfig(game_config_field.soul_detail)
    local showData = game_data:getSoulData() or {}

    local tempSoulIdTable = util.table_copy(self.soul_id_table)
    --移除已经装备的英魂而不只是当前选中的
    local flag,k = game_util:idInTableById(self.soul_id,tempSoulIdTable);
    if flag and k ~= nil then
        table.remove(tempSoulIdTable,k);
    end

    local soulPos = {}
    for key,soulTable in pairs(game_data:getSoulPos()) do
        for k,v in pairs(soulTable) do
            if v ~= "0" and v ~= "-1" then
                -- soulPos[v] = 1
                local flag,pos = game_util:idInTableById(v,tempSoulIdTable);
                if flag and pos ~= nil then
                    table.remove(tempSoulIdTable,pos);
                end
            end
        end
    end

    --根据品质排序
    local function sortFunc(data1,data2)
        local itemData1 = showData[data1]
        local key1 = itemData1.s_id
        local itemCfg1 = soulCfg:getNodeWithKey(tostring(key1))
        local quality1 = itemCfg1:getNodeWithKey("quality"):toInt()

        local itemData2 = showData[data2]
        local key2 = itemData2.s_id
        local itemCfg2 = soulCfg:getNodeWithKey(tostring(key2))
        local quality2 = itemCfg2:getNodeWithKey("quality"):toInt()
        return quality1 < quality2
    end
    table.sort( tempSoulIdTable, sortFunc )

    local tableCount = game_util:getTableLen(tempSoulIdTable)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2; -- 行
    params.column = 5; -- 列
    params.totalItem = tableCount  -- 数量
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-16;
    local itemSize = CCSizeMake( viewSize.width/params.column, viewSize.height/params.row);
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_soul_icon_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then  -- 更新cell的内容
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local icon_node = ccbNode:nodeForName("icon_node")
            local label_lv = ccbNode:labelTTFForName("label_lv")
            local label_name = ccbNode:labelTTFForName("label_name")
            local select_sprite = ccbNode:spriteForName("select_sprite")


            icon_node:removeAllChildrenWithCleanup(true)

            local soul_id = tempSoulIdTable[index + 1]

            local itemData = showData[soul_id]
            local key = itemData.s_id

            local itemCfg = soulCfg:getNodeWithKey(tostring(key))
            local iconName = itemCfg:getNodeWithKey("icon"):toStr()
            local icon = game_util:createIconByName(iconName) 
            if icon then
                icon_node:addChild(icon)
            else
                cclog("icon not exist")
            end
            local name = itemCfg:getNodeWithKey("name"):toStr()
            label_name:setString(name)

            local quality = itemCfg:getNodeWithKey("quality"):toInt()
            label_name:setColor(SOUL_QUALITY_COLOR_TABLE[quality].color)

            local soul_lv = itemData.lv
            local max_level = itemCfg:getNodeWithKey("max_level"):toInt()
            label_lv:setString(soul_lv)
            local flag,k = game_util:idInTableById(soul_id,self.select_id_table);
            if flag then
                select_sprite:setVisible(true)
            else
                select_sprite:setVisible(false)
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, item )
        if eventType == "ended" and item then
            cclog("index == " .. index)
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local soul_id = tempSoulIdTable[index + 1]
            local select_sprite = ccbNode:spriteForName("select_sprite")

            local flag, k = game_util:idInTableById(soul_id, self.select_id_table)
            if flag and k ~= nil then
                table.remove(self.select_id_table, k)
                select_sprite:setVisible(false)
            else
                if #self.select_id_table < 50 then
                    local exp, maxExp = self:getExp()
                    local materialExp = 0
                    for k, v in pairs(self.select_id_table) do
                        local materialData = showData[v]
                        local key = materialData.s_id
                        local itemCfg = soulCfg:getNodeWithKey(tostring(key))
                        local cfg_exp = itemCfg:getNodeWithKey("exp"):toInt()
                        materialExp = materialExp + materialData.pre_exp + materialData.exp + cfg_exp
                    end
                    if materialExp + exp < maxExp then
                        table.insert(self.select_id_table, soul_id)
                        select_sprite:setVisible(true)
                    else
                        game_util:addMoveTips({text = "Số Anh Hùng đã đạt giới hạn!"})
                    end
                else
                    game_util:addMoveTips({text = "Số Anh Hùng đã đạt giới hạn!"})
                end
            end

            self:refreshSoulData()
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新列表
]]
function game_fuse_soul.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true)
    self.m_tableView = self:createSoulTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end
--[[
    一键添加
]]
function game_fuse_soul.quickAdd(self,fuseType)
    self.select_id_table = {}
    local soulCfg = getConfig(game_config_field.soul_detail)
    local showData = game_data:getSoulData() or {}

    local tempSoulIdTable = util.table_copy(self.soul_id_table)
    local flag,k = game_util:idInTableById(self.soul_id,tempSoulIdTable);
    if flag and k ~= nil then
        table.remove(tempSoulIdTable,k);
    end

    local soulPos = {}
    for key,soulTable in pairs(game_data:getSoulPos()) do
        for k,v in pairs(soulTable) do
            if v ~= "0" and v ~= "-1" then
                -- soulPos[v] = 1
                local flag,pos= game_util:idInTableById(v,tempSoulIdTable);
                if flag and pos ~= nil then
                    table.remove(tempSoulIdTable,pos);
                end
            end
        end
    end

    --根据品质排序
    local function sortFunc(data1,data2)
        local itemData1 = showData[data1]
        local key1 = itemData1.s_id
        local itemCfg1 = soulCfg:getNodeWithKey(tostring(key1))
        local quality1 = itemCfg1:getNodeWithKey("quality"):toInt()

        local itemData2 = showData[data2]
        local key2 = itemData2.s_id
        local itemCfg2 = soulCfg:getNodeWithKey(tostring(key2))
        local quality2 = itemCfg2:getNodeWithKey("quality"):toInt()
        return quality1 < quality2
    end
    table.sort( tempSoulIdTable, sortFunc )

    local exp, maxExp = self:getExp()
    local materialExp = 0

    for i=1,#tempSoulIdTable do
        local soul_id = tempSoulIdTable[i]
        local itemData = showData[soul_id]
        local key = itemData.s_id
        local itemCfg = soulCfg:getNodeWithKey(tostring(key))
        local quality = itemCfg:getNodeWithKey("quality"):toInt()
        if quality == fuseType then
            if #self.select_id_table < 50 and (materialExp + exp < maxExp) then
                table.insert(self.select_id_table,soul_id)
                materialExp = materialExp + itemData.pre_exp + itemData.exp + itemCfg:getNodeWithKey("exp"):toInt()
            end
        end
    end
    self:refreshUi()
end
--[[--
    刷新ui
]]
function game_fuse_soul.refreshUi(self)
    local allSoulData = game_data:getSoulData() or {}
    self.soul_id_table = {}

    -- self.soul_id_table = game_data:getYingHunSidData()
    for k,v in pairs(allSoulData) do
        table.insert(self.soul_id_table,k)
    end
    self:refreshTableView();

    self:refreshSoulData()
end

--[[
    刷新当前选中soul的属性
]]
function game_fuse_soul.refreshSoulData(self)
    local soulCfg = getConfig(game_config_field.soul_detail)
    local soulExpCfg = getConfig(game_config_field.soul_exp)

    local itemData = game_data:getSoulData()[self.soul_id]
    self.back_soul_data = util.table_copy(itemData)
    self.m_icon_spr:removeAllChildrenWithCleanup(true)
    local key = itemData.s_id
    local itemCfg = soulCfg:getNodeWithKey(tostring(key))

    local iconName = itemCfg:getNodeWithKey("icon"):toStr()
    local icon = game_util:createIconByName(iconName) 
    if icon then
        icon:setScale(1.2)
        self.m_icon_spr:addChild(icon)
    else
        cclog("icon not exist")
    end

    local materialExp = 0
    local showData = game_data:getSoulData()
    for k,v in pairs(self.select_id_table) do
        local materialData = showData[v]
        local key = materialData.s_id
        local itemCfg = soulCfg:getNodeWithKey(tostring(key))
        local cfg_exp = itemCfg:getNodeWithKey("exp"):toInt()
        materialExp = materialExp + materialData.pre_exp + materialData.exp + cfg_exp
    end
    cclog2(materialExp,"materialExp")

    local level = itemData.lv
    local exp = itemData.exp

    local max_exp = 0
    local expCount = soulExpCfg:getNodeCount()
    local max_level = itemCfg:getNodeWithKey("max_level"):toInt()
    local exp_type = 1
    if level + 1 <= max_level then
        local itemExpCfg = soulExpCfg:getNodeWithKey(tostring(level + 1))
        exp_type = itemCfg:getNodeWithKey("exp_type"):toInt()
        max_exp = itemExpCfg:getNodeWithKey("need_exp_type" .. exp_type):toInt()
    end

    local name = itemCfg:getNodeWithKey("name"):toStr()
    self.m_title_label:setString(name .. " LV." .. level)
    self.m_uplevel_lab:setString("")

    local des = itemCfg:getNodeWithKey("des"):toStr()

    local value = itemCfg:getNodeWithKey("value"):toInt()
    local level_add = itemCfg:getNodeWithKey("level_add"):toFloat()
    local abilityType = itemCfg:getNodeWithKey("ability"):toInt()

    if itemCfg:getNodeWithKey("des2") then 
        local des2 = itemCfg:getNodeWithKey("des2"):toStr()

        local value2 = itemCfg:getNodeWithKey("value2"):toInt()
        local level_add2 = itemCfg:getNodeWithKey("level_add2"):toFloat()
        local abilityType2 = itemCfg:getNodeWithKey("ability2"):toInt()
    end
    if abilityType2 and abilityType2 ~= 0 then
        if abilityType2 < 6 or abilityType2>200 then
            abilityText2 = "+" .. math.floor(value2+level*level_add2)
        else
            local percent2 = string.format("%.1f", value2+level*level_add2)
            abilityText2 = "+" .. percent2 .. "%"
        end
        self.m_soul_atk2:setString(des2 .. abilityText2)
        self.m_up_atk2:setString("")
    else
        self.abilty_node2:setVisible(false)
    end
    local abilityText = ""
    if abilityType < 6 or abilityType>200 then
        abilityText = "+" .. math.floor(value+level*level_add)
    else
        local percent = string.format("%.1f", value+level*level_add)
        abilityText = "+" .. percent .. "%"
    end
    self.m_soul_atk:setString(des .. abilityText)
    self.m_up_atk:setString("")
    self.m_exp_lab:setString(exp .. "/" .. max_exp)

    self.m_bar_bg:removeAllChildrenWithCleanup(true)
    local bar = ExtProgressTime:createWithFrameName("yinghun_pro_back.png","yinghun_pro.png")
    bar:setMaxValue(max_exp);
    bar:setCurValue(exp,false);
    bar:setAnchorPoint(ccp(0.5,0.5));
    self.m_bar_bg:addChild(bar,1,10);

    --预判升级
    local nextLevel,nextExp,nextMaxExp = 0,0,0
    local function getNextData(nowLevel,allExp,cur_max)
        if allExp - cur_max < 0 then--不够升级
            -- cclog("nowLevel == " .. nowLevel .. "  allExp == " .. allExp .. "  cur_max == " .. cur_max)
            nextLevel,nextExp,nextMaxExp = nowLevel,allExp,cur_max
        else
            if nowLevel + 1 < max_level then
                local tempLevel = nowLevel + 1
                local nowTotalExp = allExp - cur_max
                -- cclog2(tempLevel,"tempLevel")
                local itemExpCfg = soulExpCfg:getNodeWithKey(tostring(tempLevel + 1))
                local now_cur_max = itemExpCfg:getNodeWithKey("need_exp_type" .. exp_type):toInt()
                -- cclog2(now_cur_max,"now_cur_max")
                getNextData(tempLevel,nowTotalExp,now_cur_max)
            else
                local finalLevel = max_level
                local nowTotalExp = allExp - cur_max
                local finalExpCfg = soulExpCfg:getNodeWithKey(tostring(finalLevel))
                local finalMax = finalExpCfg:getNodeWithKey("need_exp_type" .. exp_type):toInt()
                nextLevel,nextExp,nextMaxExp = finalLevel,math.min(finalMax,nowTotalExp),finalMax
            end
        end
    end
    if materialExp > 0 then
        local totalExp = exp + materialExp
        getNextData(level,totalExp,max_exp)
        cclog("nextLevel == " .. nextLevel .. "  nextExp == " .. nextExp .. "  nextMaxExp == " .. nextMaxExp)
        bar:setMaxValue(nextMaxExp)
        bar:setCurValue(nextExp,false);
        self.m_uplevel_lab:setString("+" .. nextLevel - level)
        local upText = ""
        if abilityType < 6 or abilityType>200 then
            upText = "+" .. level_add * (nextLevel - level)
        else
            local nextValue = level_add * (nextLevel - level) 
            upText = "+" .. string.format("%.1f",tostring(nextValue)) .. "%"
        end
        self.m_up_atk:setString(upText)

        local upText2 = ""
        if abilityType2 and abilityType2 ~= 0 then
            if abilityType2 < 6 or abilityType2>200 then
                upText2 = "+" .. level_add2 * (nextLevel - level)
            else
                local nextValue2 = level_add2 * (nextLevel - level) 
                upText2 = "+" .. string.format("%.1f",tostring(nextValue2)) .. "%"
            end
            self.m_up_atk2:setString(upText2)
        else
            self.m_up_atk2:setString("")
        end

        self.m_exp_lab:setString(nextExp .. "/" .. nextMaxExp)
    end


    game_util:centerTwoLabel(self.m_title_label, self.m_uplevel_lab, 159 )
    game_util:centerTwoLabel(self.m_soul_atk, self.m_up_atk, 159 )
    game_util:centerTwoLabel(self.m_soul_atk2, self.m_up_atk2, 159 )
end

--[[--
    初始化
]]
function game_fuse_soul.init(self,t_params)
    t_params = t_params or {};
    self.soul_id = t_params.soul_id
    self.soul_id_table = {}--t_params.soul_id_table--排好序的
    self.select_id_table = {}
    
end

--[[--
    创建ui入口并初始化数据
]]
function game_fuse_soul.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

function game_fuse_soul.getExp(self)
    local soulCfg = getConfig(game_config_field.soul_detail)
    local soulExpCfg = getConfig(game_config_field.soul_exp)
    local itemData = game_data:getSoulData()[self.soul_id]
    local key = itemData.s_id
    local itemCfg = soulCfg:getNodeWithKey(tostring(key))
    local max_exp = 0
    local max_level = itemCfg:getNodeWithKey("max_level"):toInt()
    local level = itemData.lv
    local exp = itemData.exp
    local exp_type = itemCfg:getNodeWithKey("exp_type"):toInt() or 1
    -- if level + 1 <= max_level then
    --     local itemExpCfg = soulExpCfg:getNodeWithKey(tostring(max_level))
    --     exp_type = itemCfg:getNodeWithKey("exp_type"):toInt()
    --     max_exp = itemExpCfg:getNodeWithKey("need_exp_type" .. exp_type):toInt()
    -- end
    -- return exp, max_exp

    -- 计算所有等级的经验值总和
    local allMaxExp = 0
    for i=1,max_level do
        local itemExpCfg = soulExpCfg:getNodeWithKey(tostring(i))
        local max_exp = itemExpCfg:getNodeWithKey("need_exp_type" .. exp_type):toInt()
        allMaxExp = allMaxExp + max_exp
    end
    -- 计算共有多少经验值
    local allCurExp = exp
    for i=1,level do
        local itemExpCfg = soulExpCfg:getNodeWithKey(tostring(i))
        local max_exp = itemExpCfg:getNodeWithKey("need_exp_type" .. exp_type):toInt()
        allCurExp = allCurExp + max_exp
    end
    return allCurExp, allMaxExp
end

return game_fuse_soul;