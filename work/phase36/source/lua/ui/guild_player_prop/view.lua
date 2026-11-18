require "shared.extern"

local guild_player_prop_view = class("guildPlayerPropView",require("like_oo.oo_popBase"));

guild_player_prop_view.m_ccb = nil;
guild_player_prop_view.m_listNode = nil;

--場景創建函數
function guild_player_prop_view:onCreate(  )
	-- body

	-- 此處添加自己的代碼，創建ui
	-- m_rootView 為當前view的根顯示節點
	self.m_ccb = luaCCBNode:create();
	local function onBack( target,event )
		-- body
		cclog("------- function onBack");
		self:updataMsg(2);
	end
	local function onMainBtnClick( target,event )
		-- body
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if(btnTag == 11)then
        	-- 成員列表
        	self:updataMsg(11);
        elseif(btnTag == 13)then
        	-- 申請列表
            self:updataMsg(13);
        end
	end
	self.m_ccb:registerFunctionWithFuncName("onBack",onBack);
	self.m_ccb:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);

	self.m_ccb:openCCBFile("ccb/pop_new_guild_proplist.ccbi");

	self.m_listNode = tolua.cast(self.m_ccb:objectForName("m_listNode"),"CCNode");
	local tempTable = self:createTableView(self.m_listNode:getContentSize());
	self.m_listNode:addChild(tempTable);

	self.m_rootView:addChild(self.m_ccb);
end

function guild_player_prop_view:onEnter(  )
	-- body
end

function guild_player_prop_view:onCommand( command , data )
	-- body
	-- view內命令回調函數
	-- 發命令用updataCommand（參考oo_viewBase）;
end

function guild_player_prop_view:resetData(  )
    -- body
    self.m_listNode:removeAllChildrenWithCleanup(true);
    local tempTable = self:createTableView(self.m_listNode:getContentSize());
    self.m_listNode:addChild(tempTable);
end

function guild_player_prop_view:createTableView( viewSize )
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");

    -- local daily_award_cfg = getConfig(game_config_field.daily_award)
    -- local tGameData = game_data:getDailyAwardData();
    -- local score = tGameData.score;
    -- local reward = tGameData.reward;
    local params = {};
    params.viewSize = viewSize;
    params.row = 5; -- 行
    params.column = 1; -- 列
    -- params.totalItem = self.m_control.m_data:getGuildCount();
    params.totalItem = self.m_control.m_data:getPlayerCount();
    -- params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    params.touchPriority = 1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local tempItem = luaCCBNode:create();
            tempItem:openCCBFile("ccb/pop_new_guild_proplist_item.ccbi");
            cell:addChild(tempItem,10,10);
        end
        
        if cell then
            local tempItem = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local tempData = self.m_control.m_data:getPlayer(index+1);
            -- util.printf(tempData);
            cclog("------------------shop item-------------------1")
            -- 競技排名
            local m_pPkPost = tolua.cast(tempItem:objectForName("m_pPkPost"),"CCLabelTTF");
            m_pPkPost:setString(tostring(tempData.arena_rank));
            cclog("------------------shop item -------------------2")
            -- 玩家名稱
            local m_pName = tolua.cast(tempItem:objectForName("m_pName"),"CCLabelTTF");
            m_pName:setString(tempData.name);
            cclog("-------------------shop item------------------3")
            -- 玩家等級
            local m_pLv = tolua.cast(tempItem:objectForName("m_pLv"),"CCLabelTTF");
            m_pLv:setString(tostring(tempData.level));
            cclog("-------------------shop item------------------4")
            -- 玩家Vip等級
            local m_pVipLv = tolua.cast(tempItem:objectForName("m_pVipLv"),"CCLabelTTF");
            m_pVipLv:setString(tostring(tempData.vip));
            cclog("-------------------shop item------------------5")
            -- 玩家創建時間
            local m_pStartTime = tolua.cast(tempItem:objectForName("m_pStartTime"),"CCLabelTTF");
            m_pStartTime:setString(tempData.regist_time);
            cclog("-------------------shop item------------------6")
            -- 戰鬥力
            local m_pDate = tolua.cast(tempItem:objectForName("m_pDate"),"CCLabelTTF");
            m_pDate:setString(tostring(tempData.active_day));
            cclog("-------------------shop item------------------7")

        end
        cell:setTag(index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            -- self:refreshRewardDetail(item);
            self:updataMsg( 3,index+1,'this');
        end
    end
    return TableViewHelper:create(params);
end

return guild_player_prop_view;



