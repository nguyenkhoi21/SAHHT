require "shared.extern"

local guild_player_list_option_view = class("guildPlayerListOptionView",require("like_oo.oo_popBase"));

guild_player_list_option_view.m_ccb = nil;
guild_player_list_option_view.m_playerName = nil;

guild_player_list_option_view.uid = nil;

--場景創建函數
function guild_player_list_option_view:onCreate(  )
	-- 此處添加自己的代碼，創建ui
	-- m_rootView 為當前view的根顯示節點
	self.m_ccb = luaCCBNode:create();
	local function onButtonClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        self:updataMsg(btnTag+2);
        -- btnTag 1.查看詳情 2.升職 3.降職 4.踢出公會 5.轉交會長	    6.會長解散公會  7.會員退出公會
	end
	self.m_ccb:registerFunctionWithFuncName( "onButtonClick",onButtonClick );
	local tempTitle = self.m_control.m_data:getTitle();
	local playerUid = self.m_control.m_data:getUid()
	local myUid = game_data:getUserStatusDataByKey("uid")	
	if(self.m_control.m_data:getMineTitle() == "owner")then
		if(tempTitle == "vp")then
			self.m_ccb:openCCBFile("ccb/pop_new_guild_playerlist_pop2.ccbi");
		elseif(tempTitle == "owner")then
			self.m_ccb:openCCBFile("ccb/pop_new_guild_playerlist_pop5.ccbi");
		else
			self.m_ccb:openCCBFile("ccb/pop_new_guild_playerlist_pop3.ccbi");
		end
	else
		if playerUid == myUid then
			self.m_ccb:openCCBFile("ccb/pop_new_guild_playerlist_pop6.ccbi");
		else
			self.m_ccb:openCCBFile("ccb/pop_new_guild_playerlist_pop4.ccbi");
		end
	end

	self.m_playerName = tolua.cast(self.m_ccb:objectForName("m_playerName"),"CCLabelTTF");
	self.m_playerName:setString(self.m_control.m_data:getPlayerName());

	self.m_rootView:addChild(self.m_ccb);
end

function guild_player_list_option_view:onEnter(  )
	self:canClose(true);
end

function guild_player_list_option_view:onCommand( command , data )
	-- view內命令回調函數
	-- 發命令用updataCommand（參考oo_viewBase）;
end

return guild_player_list_option_view;