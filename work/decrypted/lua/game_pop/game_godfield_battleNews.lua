---  竞技场战报信息
local game_godfield_battleNews = {
    m_root_layer = nil,
    btn_close = nil,
    m_list_view_node = nil,
    m_tGameData = nil,
    m_logs = nil,

};

--[[--
    销毁
]]
function game_godfield_battleNews.destroy(self)
    cclog("--------game_godfield_battleNews  destroy ------")
    self.m_root_layer = nil;
    self.btn_close = nil;
    self.m_list_view_node = nil;
    self.m_tGameData = nil;
    self.m_logs = nil;
end
--[[--
    返回
]]
function game_godfield_battleNews.back(self,type)
    game_scene:removePopByName("game_godfield_battleNews");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_battleNews.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 101 then --返回
            self:back();
        elseif btnTag == 1 then 
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_godfield_battle_news.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer") 
    self.btn_close = ccbNode:controlButtonForName("btn_close")
    self.m_list_view_node = ccbNode:nodeForName("m_list_view_node")
    self.btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY-16)
    self.ccbNode = ccbNode
    local tempViewSize = self.m_list_view_node:getContentSize()
    
    self.m_list_view_node:addChild(self:createVsTableView(tempViewSize))
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 15,true);
    self.m_root_layer:setTouchEnabled(true);

    return ccbNode;
end
function game_godfield_battleNews.createVsTableView( self,viewSize )
    local length = #self.m_tGameData.logs
    --cclog2(self.m_tGameData.logs[tostring(btnTag)],"self.m_tGameData.logs[tostring(btnTag)] == ")
    local params = {};
    --local m_tab = {}
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1; --列
    params.totalItem = length
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-16
    --params.itemActionFlag = true
    --params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_godfield_battleNews_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0,0))
            ccbNode:setPosition(ccp(50,itemSize.height*0+20));
            local news = self.m_tGameData.logs[tonumber(index+1)]
            local news_label = ccbNode:labelTTFForName("m_label_name")
            news_label:setVisible(false)
            local tempPosX,tempPosY = news_label:getPosition()
            local tempTipsLabel = CCRichLabelTTF:create(news,TYPE_FACE_TABLE.Arial_BoldMT,12);
            tempTipsLabel:setPosition(ccp(tempPosX+70,tempPosY))
            tempTipsLabel:setScale(0.8)
            ccbNode:addChild(tempTipsLabel)
            cell:addChild(ccbNode,10,10);
            --cclog(viewSize)
        end
        if cell then

        end
        return cell;
    end
    -- params.itemOnClick = function(eventType,index,item)    
        
    -- end
    return TableViewHelper:create(params);
    -- body
end


--[[--
    刷新ui
]]
function game_godfield_battleNews.refreshUi(self)

end

--[[--
    初始化
]]
function game_godfield_battleNews.init(self,t_params)
    t_params = t_params or {};
    -- body
    --cclog2(t_params,"t_params === ")
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    elseif tolua.type(t_params.gameData) == "table" then
        self.m_tGameData = t_params.gameData
    end

    self.m_logs = self.m_tGameData.logs or {}
    --cclog2( self.m_tGameData.logs,"self.itemCfg == " )
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_battleNews.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_battleNews;