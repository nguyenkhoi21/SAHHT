--- 坠落之地
--- 宝箱弹版
local game_godfield_guild_high_war_box_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
};

--[[--
    销毁
]]
function game_godfield_guild_high_war_box_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_box_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
end
--[[--
    返回
]]
function game_godfield_guild_high_war_box_pop.back(self)
    game_scene:removePopByName("game_godfield_guild_high_war_box_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_box_pop.createUi(self)
    self.m_select_index = 1
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_box_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    self.label_title = ccbNode:labelTTFForName("label_title") 
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)

    self.node_rewards = ccbNode:nodeForName("node_rewards")

    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_godfield_guild_high_war_box_pop.refreshUi(self)
    local rewards
    if self.m_rewards then
        rewards = self.m_rewards
        self.label_title:setString(self.m_title)
    else
        local guild_high_war_box_cfg = getConfig(game_config_field.guild_high_war_box)
        local box_cfg = guild_high_war_box_cfg:getNodeWithKey(self.m_boxid)
        rewards = json.decode(box_cfg:getNodeWithKey("box_reward"):getFormatBuffer()) or {};
        if self.m_boxid == 1 then
            self.label_title:setString("Rương Báu Chí Tôn")
        elseif self.m_boxid == 2 then
            self.label_title:setString("Rương Báu Vàng")
        elseif self.m_boxid == 3 then
            self.label_title:setString("Rương Báu Bạc")
        else
            self.label_title:setString("Rương Báu Đồng")
        end
    end


    table.sort( rewards, function (data1, data2)
        local icon,name,count,rewardType,quality1 = game_util:getRewardByItemTable(data1, false)
        local icon,name,count,rewardType,quality2 = game_util:getRewardByItemTable(data2, false)
        return quality1 > quality2
    end )


    self.node_rewards:removeAllChildrenWithCleanup(true);
    -- self.node_rewards:setContentSize(CCSizeMake(math.min(#rewards*50, 250), 60))
    local tableView = self:createRewardTable(self.node_rewards:getContentSize(), rewards)
    self.node_rewards:addChild(tableView,10,10);     

end


function game_godfield_guild_high_war_box_pop.createRewardTable(self,viewSize,rewardList)
    local scale = scale or 0.5

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemCfg = rewardList[btnTag+1]
        game_util:lookItemDetal(itemCfg)
    end
    local count = #rewardList
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;
    params.column = math.min(count, 5); --列
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5,0.5))
            node:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            cell:addChild(node)
            local itemGift = rewardList[index+1]
            local icon,name,count = game_util:getRewardByItemTable(itemGift, false)
            if icon then
                icon:setScale(0.8)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,5))
                node:addChild(icon,10)
            end
            if name then
                local nameLabel = game_util:createLabelTTF({text = "x"..count})
                nameLabel:setColor(ccc3(250,180,0))
                nameLabel:setAnchorPoint(ccp(0.5, 0.5))
                nameLabel:setPosition(icon:getContentSize().width * 0.5, -6)
                icon:addChild(nameLabel, 11)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemCfg = rewardList[index+1]
            game_util:lookItemDetal(itemCfg)
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        
    end
    return TableViewHelper:create(params);
end

--[[--
    初始化
]]
function game_godfield_guild_high_war_box_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_boxid = t_params.boxid
    self.m_rewards = t_params.rewards
    self.m_title = t_params.title
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_guild_high_war_box_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_guild_high_war_box_pop;