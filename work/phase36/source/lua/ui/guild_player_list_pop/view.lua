require "shared.extern"

local guild_player_list_pop_view = class("guildPlayerListPopView",require("like_oo.oo_popBase"));

guild_player_list_pop_view.m_ccb = nil;
guild_player_list_pop_view.m_listNode = nil;

guild_player_list_pop_view.last_select = nil;

--場景創建函數
function guild_player_list_pop_view:onCreate(  )
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
        elseif(btnTag == 12)then
        	-- 申請列表
            self:updataMsg(12);
        elseif(btnTag == 13) then--聯盟列表
            self:updataMsg(13);
        end
	end
	self.m_ccb:registerFunctionWithFuncName("onBack",onBack);
	self.m_ccb:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);

	self.m_ccb:openCCBFile("ccb/pop_new_guild_playerlist.ccbi");

	self.m_listNode = tolua.cast(self.m_ccb:objectForName("m_listNode"),"CCNode");

	local tempTable = self:createTableView(self.m_listNode:getContentSize());
	self.m_listNode:addChild(tempTable);

	self.m_rootView:addChild(self.m_ccb);
end

function guild_player_list_pop_view:onEnter(  )
	-- body
end

function guild_player_list_pop_view:onCommand( command , data )
	-- body
	-- view內命令回調函數
	-- 發命令用updataCommand（參考oo_viewBase）;
end

function guild_player_list_pop_view:updataItem(  )
    -- body
    self.m_listNode:removeAllChildrenWithCleanup(true);
    local tempTable = self:createTableView(self.m_listNode:getContentSize());
    self.m_listNode:addChild(tempTable);
end

function guild_player_list_pop_view:createTableView( viewSize )
    self.last_select = nil;
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
            tempItem:openCCBFile("ccb/pop_new_guild_playerlist_item.ccbi");
            cell:addChild(tempItem,10,10);
        end
        
        if cell then
            local tempItem = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local tempData = self.m_control.m_data:getPlayer(index+1);
            util.printf(tempData);
            cclog("------------------shop item-------------------1")
            -- 貢獻排名
            local m_pScPost = tolua.cast(tempItem:objectForName("m_pScPost"),"CCLabelTTF");
            m_pScPost:setString(tostring(tempData.dedication_rank));
            cclog("------------------shop item -------------------2")
            -- 競技排名
            local m_pPkPost = tolua.cast(tempItem:objectForName("m_pPkPost"),"CCLabelTTF");
            m_pPkPost:setString(tostring(tempData.arena_rank));
            cclog("-------------------shop item------------------3")
            -- 玩家名稱
            local m_pName = tolua.cast(tempItem:objectForName("m_pName"),"CCLabelTTF");
            m_pName:setString(tostring(tempData.name));
            cclog("-------------------shop item------------------4")
            -- 玩家等級
            local m_pLv = tolua.cast(tempItem:objectForName("m_pLv"),"CCLabelTTF");
            m_pLv:setString(tostring(tempData.level));
            cclog("-------------------shop item------------------5")
            -- 玩家職稱
            local m_pTitle = tolua.cast(tempItem:objectForName("m_pTitle"),"CCLabelTTF");
            local tempTitle = "";
            if(tempData.title == "owner")then
                tempTitle = "Hội trưởng";
                m_pTitle:setColor(ccc3(255,255,7))
            elseif(tempData.title == "vp")then
                tempTitle = "Hội phó";
                m_pTitle:setColor(ccc3(232,86,7))
            else
                tempTitle = "Hội viên";
                m_pTitle:setColor(ccc3(5,142,60))
            end
            m_pTitle:setString(tostring(tempTitle));
            cclog("-------------------shop item------------------6")
            -- 戰鬥力
            local m_pPower = tolua.cast(tempItem:objectForName("m_pPower"),"CCLabelTTF");
            m_pPower:setString(tostring(tempData.combat));
            cclog("-------------------shop item------------------7")
            -- 貢獻度
            local m_pScore = tolua.cast(tempItem:objectForName("m_pScore"),"CCLabelTTF");
            local max_contribution = tempData.max_contribution or tempData.dedication
            m_pScore:setString(tostring(max_contribution));
            cclog("-------------------shop item------------------8")
            -- 在線狀態 1 在線 0 不在線 －1離線20天以上
            local m_pType = tolua.cast(tempItem:objectForName("m_pType"),"CCLabelTTF");
            local tempType = "";
            if(tempData.online == 1)then
                tempType = "Online";
                m_pType:setColor(ccc3(165,255,6))
            elseif(tempData.online == 0)then
                tempType = "Offline";
                m_pType:setColor(ccc3(187,178,175))
            elseif(tempData.online == -1)then
                tempType = "Gần 20 ngày không online";
                m_pType:setColor(ccc3(187,178,175))
            end
            m_pType:setString(tempType);
            cclog("-------------------shop item------------------9")

            local sprite_select = tolua.cast(tempItem:objectForName("sprite_select"),"CCSprite")
            sprite_select:setVisible(false)
        end
        cell:setTag(index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            -- self:refreshRewardDetail(item);

            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local sprite_select = ccbNode:spriteForName("sprite_select");
            if self.last_select ~= sprite_select then
                if self.last_select then
                    self.last_select:setVisible(false)
                end
                sprite_select:setVisible(true)
                self.last_select = sprite_select
            end

            self:updataMsg( 3,index+1,'this');
        end
    end
    return TableViewHelper:create(params);
end

return guild_player_list_pop_view;