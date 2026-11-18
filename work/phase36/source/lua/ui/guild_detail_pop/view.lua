require "shared.extern"

local guild_detail_pop_view = class("guildDetailPopView",require("like_oo.oo_popBase"));

guild_detail_pop_view.m_ccb = nil;
guild_detail_pop_view.m_listNode = nil;
guild_detail_pop_view.m_miniNode = nil;
guild_detail_pop_view.btn_apply = nil;
guild_detail_pop_view.m_idLabel = nil;

function guild_detail_pop_view:create(  )
	local pop = self.popBase.create( self );

	local function onBack( target,event )
		self:updataMsg(2);			-- 發送關閉消息
	end

	local function onButtonClick( target,event )
		self:updataMsg(3)			-- 發送加入該公會消息
	end

	self.m_ccb = luaCCBNode:create();
	self.m_ccb:registerFunctionWithFuncName("onBack",onBack);
	self.m_ccb:registerFunctionWithFuncName("onButtonClick",onButtonClick);
	self.m_ccb:openCCBFile("ccb/pop_new_guild_detail.ccbi");
	self.m_listNode = tolua.cast(self.m_ccb:objectForName("m_listNode"),"CCNode");
	self.m_miniNode = tolua.cast(self.m_ccb:objectForName("m_miniNode"),"CCNode");

    self.btn_apply = tolua.cast(self.m_ccb:objectForName("btn_apply"),"CCControlButton")
    self.m_idLabel = tolua.cast(self.m_ccb:objectForName("m_idLabel"),"CCLabelTTF")
    self.m_idLabel:setString("(ID:" .. self.m_control.m_data:getId() .. ")")

    local openType = self.m_control.m_data:getOpenType()
    if openType == 2 then
        self.btn_apply:setVisible(false)
    end
    game_util:setControlButtonTitleBMFont(self.btn_apply)

	local tempTableView = self:createTableView(self.m_listNode:getContentSize());
	self.m_listNode:addChild(tempTableView);

	pop:addChild(self.m_ccb);
	return pop;
end

function guild_detail_pop_view:onCommand( command , data )
	
end
--[[
    改變按鈕狀態
]]
function guild_detail_pop_view:changeBtnState(state)
    -- if self.btn_apply == 1 then

    -- else
    --     self.btn_apply
    -- end
end
function guild_detail_pop_view:createTableView( viewSize )
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
    params.totalItem = self.m_control.m_data:getPlayerCount();
    params.touchPriority = 1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local tempItem = luaCCBNode:create();
            tempItem:openCCBFile("ccb/pop_new_guild_detail_item.ccbi");
            cell:addChild(tempItem,10,10);
        end
        
        if cell then
            local tempItem = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local tempData = self.m_control.m_data:getPlayer(index+1);

            -- 公會成員職位
            local m_ppost = tolua.cast(tempItem:objectForName("m_ppost"),"CCLabelTTF");
            if(tempData.title == "owner")then
                m_ppost:setString("Hội trưởng");
                m_ppost:setColor(ccc3(255,255,7))
            elseif(tempData.title == "vp")then
                m_ppost:setString("Hội phó");
                m_ppost:setColor(ccc3(232,86,7))
            else
                m_ppost:setString("Hội viên");
                m_ppost:setColor(ccc3(5,142,60))
            end
            -- 公會成員名字
            local m_pname = tolua.cast(tempItem:objectForName("m_pname"),"CCLabelTTF");
            m_pname:setString(tempData.name);
            -- 公會成員等級
            local m_plv = tolua.cast(tempItem:objectForName("m_plv"),"CCLabelTTF");
            m_plv:setString(tostring(tempData.level));
            -- 公會成員貢獻度
            local m_pcontri = tolua.cast(tempItem:objectForName("m_pcontri"),"CCLabelTTF");
            m_pcontri:setString(tostring(tempData.dedication));
            -- 公會成員在線狀態
            local m_ptype = tolua.cast(tempItem:objectForName("m_ptype"),"CCLabelTTF");
            local tempOnline = tonumber(tempData.online);
            if(tempOnline == 1)then
                m_ptype:setString("Online");
                m_ptype:setColor(ccc3(165,255,6))
            elseif(tempOnline == -1)then
                m_ptype:setString("Gần 20 ngày không online");
                m_ptype:setColor(ccc3(187,178,175))
            else
                m_ptype:setString("Offline");
                m_ptype:setColor(ccc3(187,178,175))
            end
        end
        cell:setTag(index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            -- self:refreshRewardDetail(item);
            self:updataMsg( 4,index,'this');
        end
    end
    return TableViewHelper:create(params);
end

return guild_detail_pop_view;
