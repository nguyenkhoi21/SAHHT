require "shared.extern"

local guild_world_1_view = class("guildWorld1View",require("like_oo.oo_popBase"));

guild_world_1_view.m_ccb = nil;

-- 公會名字
guild_world_1_view.m_gname = nil;

--場景創建函數
function guild_world_1_view:onCreate(  )
	-- body

	-- 此處添加自己的代碼，創建ui
	-- m_rootView 為當前view的根顯示節點
	self.m_ccb = luaCCBNode:create();

	self.m_ccb:openCCBFile("ccb/pop_guild_world_1.ccbi");
	
	self.m_gname = tolua.cast(self.m_ccb:objectForName("m_gname"),"CCLabelTTF");

	self.m_rootView:addChild(self.m_ccb);
	self:consumeTouch(false);
	self.m_ccb:setPosition(ccp(self.m_control.m_data:getPos()));
end

function guild_world_1_view:onEnter(  )
	-- body
end

function guild_world_1_view:onCommand( command , data )
	-- body
	-- view內命令回調函數
	-- 發命令用updataCommand（參考oo_viewBase）;
end

return guild_world_1_view;