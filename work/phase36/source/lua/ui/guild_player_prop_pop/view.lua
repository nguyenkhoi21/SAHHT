require "shared.extern"

local guild_player_prop_pop_view = class("guildPlayerPropPopView",require("like_oo.oo_popBase"));

guild_player_prop_pop_view.m_ccb = nil;
guild_player_prop_pop_view.m_playerName = nil;

--場景創建函數
function guild_player_prop_pop_view:onCreate(  )
	-- body

	-- 此處添加自己的代碼，創建ui
	-- m_rootView 為當前view的根顯示節點
	
	self.m_ccb = luaCCBNode:create();
	local function onButtonClick( target,event )
		-- body
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- btnTag 1.查看詳情 2.同意 3.拒絕
        self:updataMsg(btnTag+2);
	end
	self.m_ccb:registerFunctionWithFuncName("onButtonClick",onButtonClick);
	self.m_ccb:openCCBFile("ccb/pop_new_guild_proplist_pop.ccbi");
	self.m_playerName = tolua.cast(self.m_ccb:objectForName("m_playerName"),"CCLabelTTF");

	self.m_rootView:addChild(self.m_ccb);
end

function guild_player_prop_pop_view:onEnter(  )
	-- body
	self:canClose(true);
end

function guild_player_prop_pop_view:onCommand( command , data )
	-- body
	-- view內命令回調函數
	-- 發命令用updataCommand（參考oo_viewBase）;
end

return guild_player_prop_pop_view;