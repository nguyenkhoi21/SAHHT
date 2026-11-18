require "shared.extern"

local guild_chat_view = class("guildChatView",require("like_oo.oo_popBase"));

guild_chat_view.m_ccb = nil;

--場景創建函數
function guild_chat_view:onCreate(  )
	-- body

	-- 此處添加自己的代碼，創建ui
	-- m_rootView 為當前view的根顯示節點
	self.m_ccb = luaCCBNode:create();
	local function onChatButtonClick( target,event )
		-- body
		cclog("---------- onChatButtonClick ");
		self:updataMsg(3);
	end
	self.m_ccb:registerFunctionWithFuncName("onChatButtonClick",onChatButtonClick);
	
	self.m_ccb:openCCBFile("ccb/pop_guild_chat_button.ccbi");

	self.m_rootView:addChild(self.m_ccb);
end

function guild_chat_view:onEnter(  )
	-- body
	self:consumeTouch(false);
end

function guild_chat_view:onCommand( command , data )
	-- body
	-- view內命令回調函數
	-- 發命令用updataCommand（參考oo_viewBase）;

end

return guild_chat_view;