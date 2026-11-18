---  
local game_dispatch_depot_pop = {
    m_tGameData = nil,
    m_lab_num = nil,
    m_node_tableView = nil,
    btnCallFunc = nil,
};
--[[--
    销毁ui
]]
function game_dispatch_depot_pop.destroy(self)
    cclog("-----------------game_dispatch_depot_popdestroy-----------------");
    self.m_tGameData = nil;
    self.m_lab_num = nil;
    self.m_node_tableView = nil;
    self.btnCallFunc = nil;

end
--[[--
    返回
]]
function game_dispatch_depot_pop.back(self,backType)
    local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_dispatch_main",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("offline_dispatch_index"), http_request_method.GET, nil,"offline_dispatch_index")
end
--[[--
    读取ccbi创建ui
]]
function game_dispatch_depot_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag === ")
        if btnTag == 100 then
            self:back()
        elseif btnTag == 2 then--扩充仓库
            local pay = 10
            local dispatch_cfg = getConfig(game_config_field.dispatch_card)
            pay = dispatch_cfg:getNodeWithKey("1"):getNodeWithKey("buy_store"):toInt()
            local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        local function responseMethod( tag,gameData )
                            if gameData ~= nil and tolua.type(gameData) == "util_json" then
                                game_util:addMoveTips({text = "Đã mở rộng"})
                                self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                                self:refreshUi()
                            end
                        end 

                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("offline_dispatch_expand_store"), http_request_method.GET, nil,"offline_dispatch_expand_store")
                        game_util:closeAlertView();
                    end,   --可缺省
                    cancelBtnCallBack = function(target,event)
                        game_util:closeAlertView();
                    end,
                    okBtnText = "OK",       --可缺省
                    cancelBtnText = "Hủy",
                    onlyOneBtn = false,
                    text = "Tốn " .. pay .. "Xu mở rộng Kho？",      --可缺省
                    touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                }
                game_util:openAlertView(t_params);
            
        elseif btnTag == 3 then --自动收取
            local function responseMethod( tag,gameData )
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    -- game_util:addMoveTips({text = "派遣成功"})
                    self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                    game_util:rewardTipsByDataTable(self.m_tGameData.reward)
                    self:refreshUi()
                end
            end 
               -- if gameData == nil then 
               --   game_util:addMoveTips({text = "Không có quà để nhận"})
               --   return
               -- end    

            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("offline_dispatch_receive_store"), http_request_method.GET, nil,"offline_dispatch_receive_store")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_dispatch_depot_pop.ccbi");
    self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")
    self.m_lab_num = ccbNode:labelTTFForName("m_lab_num")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local m_btn_toBig = ccbNode:controlButtonForName("m_btn_toBig")
    local m_btn_autoGet = ccbNode:controlButtonForName("m_btn_autoGet")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    m_btn_toBig:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    m_btn_autoGet:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[
]]
function game_dispatch_depot_pop.createTableView(self,viewSize, data)
    local length = game_util:getTableLen(self.m_tGameData.store)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 6; --列
    params.totalItem = 5;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            -- ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            -- ccbNode:openCCBFile("ccb/ui_arena_rank_item.ccbi");
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            ccbNode:removeAllChildrenWithCleanup(true)
            local reward = self.m_tGameData.store[index+1]
            local icon,name,count = game_util:getRewardByItemTable(reward)
            if icon then
                icon:setScale(0.8)
                ccbNode:addChild(icon)
                local conutlab = "x" .. count
                local labelNum = CCLabelTTF:create(conutlab,TYPE_FACE_TABLE.Arial_BoldMT,10);
                labelNum:setPosition(ccp(20,-15))
                ccbNode:addChild(labelNum)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local reward = self.m_tGameData.store[index+1]
            if reward then
                game_util:lookItemDetal(reward)
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    刷新
]]
function game_dispatch_depot_pop.refreshUi(self)
    self.m_node_tableView:removeAllChildrenWithCleanup(true)
    self.m_node_tableView:addChild(self:createTableView(self.m_node_tableView:getContentSize()))
    local num1,num2 = 0,0
    num2 = self.m_tGameData.store_max
    if self.m_tGameData.store and next(self.m_tGameData.store) then
        for k,v in pairs(self.m_tGameData.store) do
            num1 = num1 + v[3]
        end
    end
    local str = "Kho(" .. num1 .. "/" .. num2 .. ")"
    self.m_lab_num:setString(str)
end

--[[--
    初始化
]]
function game_dispatch_depot_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil then
        self.m_tGameData = t_params.gameData
    end
 
end

--[[--
    创建ui入口并初始化数据
]]
function game_dispatch_depot_pop.create(self,t_params)
    self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi();
    return m_popUi;
end

return game_dispatch_depot_pop;