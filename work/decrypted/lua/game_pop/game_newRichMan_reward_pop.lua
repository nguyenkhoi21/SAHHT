--新大富翁拼图奖励信息
local game_newRichMan_reward_pop = {
    m_tGameData = nil,
    m_node_tableView = nil,
   
   
};
--[[--
    销毁ui
]]
function game_newRichMan_reward_pop.destroy(self)
    cclog("-----------------game_newRichMan_reward_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_node_tableView = nil;
end
--[[--
    返回
]]
function game_newRichMan_reward_pop.back(self,type)
    game_scene:removePopByName("game_newRichMan_reward_pop")
end
--[[--
    读取ccbi创建ui
]]
function game_newRichMan_reward_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back()
        elseif btnTag == 2 then
            local function responseMethod(tag,gameData)
                self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                game_util:rewardTipsByDataTable(self.m_tGameData.reward)
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_get_puzzle_reward"), http_request_method.GET, nil,"monopoly_get_puzzle_reward")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_Chrismas_map_pop.ccbi");
    self.m_node_tableView = ccbNode:nodeForName("m_maplist_node")

    local m_close_btn = ccbNode:controlButtonForName("btn_back")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)   
     local m_btn_get = ccbNode:controlButtonForName("m_btn_get")
    m_btn_get:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    m_btn_get:setVisible(true)
    local m_sp_title = ccbNode:spriteForName("m_sp_title")
    m_sp_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_puzzles_rewadTitle.png"))

    m_sp_title:setVisible(true)


    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-2,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end



function game_newRichMan_reward_pop.createRewardTableView( self, viewSize )
    local rewardCfg = getConfig(game_config_field.monopoly_reward)
    rewardCfg = rewardCfg:getNodeWithKey("5"):getNodeWithKey("reward")
    rewardCfg = json.decode(rewardCfg:getFormatBuffer())
    local rewardTab = rewardCfg
    self.m_select_index = 0
    self.m_select_item = nil;
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 4; --列
    params.totalItem = game_util:getTableLen(rewardTab) 
    params.direction = kCCScrollViewDirectionHorizontal;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
           -- cclog("new index ================================" .. index);
           cell = CCTableViewCell:new()
           cell:autorelease()
           local ccbNode = luaCCBNode:create()    
           ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
           cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            ccbNode:removeAllChildrenWithCleanup(true)
            cclog2(rewardTab[index + 1],"rewardTab-=-------------")
            
            local icon,name,count = game_util:getRewardByItemTable(rewardTab[index + 1])
            cclog2(icon,"icon-=----------")
            if icon then
                ccbNode:addChild(icon)
                icon:setScale(0.8)
                local countlab = CCLabelTTF:create("x" .. count,TYPE_FACE_TABLE.Arial_BoldMT,10)
                icon:addChild(countlab,10,10)
                countlab:setPosition(ccp(40,0))
            else
                ccbNode:removeAllChildrenWithCleanup(true)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            game_util:lookItemDetal(rewardTab[index + 1])
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_newRichMan_reward_pop.refreshUi(self)
    self.m_node_tableView:removeAllChildrenWithCleanup(true)
    local viewSize = self.m_node_tableView:getContentSize()
    self.m_node_tableView:addChild(self:createRewardTableView(viewSize))
end
--[[--
    初始化
]]
function game_newRichMan_reward_pop.init(self,t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_newRichMan_pintu.plist")
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    self.m_select_index = 0
end
--[[--
    创建ui入口并初始化数据
]]
function game_newRichMan_reward_pop.create(self, t_params)
    self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi();
    return  m_popUi;
end
return game_newRichMan_reward_pop;