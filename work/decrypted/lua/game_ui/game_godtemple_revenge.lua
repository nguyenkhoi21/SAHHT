---  仇人列表
cclog2 = cclog2 or function() end
local game_godtemple_revenge = {
    m_enemyList = nil,
    m_node_enemylist = nil,

    m_tableView = nil,
    m_tableViewPosY = nil,
    m_openType = nil,
}

--[[--
    销毁ui
]]
function game_godtemple_revenge.destroy(self)
    -- body
    cclog("----------------- game_godtemple_revenge destroy-----------------"); 
    self.m_enemyList = nil;
    self.m_node_enemylist = nil;
    self.m_tableView = nil;
    self.m_tableViewPosY = nil;
    self.m_openType = nil;
end
--[[--
    返回
]]
function game_godtemple_revenge.back(self,backType)
    local function responseMethod( tag,gameData )
        game_scene:enterGameUi("game_godtemple_main",{gameData =gameData})
        -- body
    end
    local params = {}
    params.is_reap = 0
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_temple_index"), http_request_method.GET, params,"god_field_temple_index")
end
--[[--
    读取ccbi创建ui
]]
function game_godtemple_revenge.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "pyramid index onMainBtnClick press button tag is ")
        if btnTag == 1 then -- 关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_enemy_list.ccbi");
    self.m_node_enemylist = ccbNode:nodeForName("m_node_enemylist")


    return ccbNode;
end



--[[
    创建仇人列表
]]
function game_godtemple_revenge.createTabelView( self, viewSize )
    local showData = self.m_enemyList or {}
    -- local showData = {{}, {}}
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        game_scene:addPop("game_godtemple_revenge_pop",{gameData = showData[btnTag]})
    end
    local tempCount = #showData
    local params = {};
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tempCount
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    params.viewSize = viewSize;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_godtemple_enemy_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")  
            local itemData = showData[index + 1]
            if ccbNode then 
                local itemData = showData[index + 1]
                -- cclog2(itemData,"itemData === ")
                local m_node_roleicon = ccbNode:nodeForName("m_node_roleicon")
                local m_label_name = ccbNode:labelTTFForName("m_label_name")
                local m_kuangdian_lab = ccbNode:labelTTFForName("m_kuangdian_lab")
                local m_get_btn = ccbNode:controlButtonForName("m_get_btn")
                m_get_btn:setTag(index + 1)
                -- 名字
                m_label_name:setString(itemData.object_name or "")
                local des = ""
                if itemData.temple_level == 1 then
                    des = "Mỏ thường"
                elseif itemData.temple_level == 2 then
                    des = "Mỏ trung"
                elseif itemData.temple_level == 3 then
                    des = "Mỏ cao cấp"
                end
                m_kuangdian_lab:setString(des)
                -- 头像
                m_node_roleicon:removeAllChildrenWithCleanup(true)
                local iconBoardSize = m_node_roleicon:getContentSize()
                local role = itemData.object_role or math.random(1, 5) 
                local tempIcon = game_util:createPlayerIconByRoleId(role)
                if tempIcon then
                    tempIcon:setScale(0.8);
                    tempIcon:setPosition(ccp(iconBoardSize.width*0.5, iconBoardSize.height*0.5));
                    m_node_roleicon:addChild(tempIcon)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
        
        end
    end
    local tableView = TableViewHelper:create(params);
    tableView:setScrollBarVisible(false);
    return tableView
end



--[[
    刷新数据
]]
function game_godtemple_revenge.refreshData( self, gameData )
end



--[[--
    刷新ui
]]
function game_godtemple_revenge.refreshUi( self )
    self.m_node_enemylist:removeAllChildrenWithCleanup(true)
    self.m_tableView = nil
    local tableview = self:createTabelView(self.m_node_enemylist:getContentSize())
    if tableview then 
        self.m_node_enemylist:addChild(tableview) 
        self.m_tableView = tableview
        if self.m_tableViewPosY then
            self.m_tableView:setContentOffset(ccp(0, self.m_tableViewPosY))
            self.m_tableViewPosY = nil
        end
    end
end

--[[
    格式化数据
]]
function game_godtemple_revenge.formatData( self )
    local m_enemyList = {}
    for i=1,4 do
        if next(self.m_gameData.farmer_team_info[tostring(i)].occupied_temple.revenge_object) then
            m_enemyList[i]= self.m_gameData.farmer_team_info[tostring(i)].occupied_temple.revenge_object
        end
    end

    self.m_enemyList = m_enemyList
    -- cclog2(self.m_enemyList,"m_enemyList === ")
end

--[[--
    初始化
]]
function game_godtemple_revenge.init(self,t_params)
    t_params = t_params or {}
    local gameData = t_params.gameData

    local data = gameData and gameData:getNodeWithKey("data")

    self.m_gameData = data and json.decode(data:getFormatBuffer()) or {}

    self:formatData()
    self.m_openType = t_params.openType or "";
end
--[[--
    创建ui入口并初始化数据
]]
function game_godtemple_revenge.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_godtemple_revenge