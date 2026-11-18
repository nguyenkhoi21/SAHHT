require "shared.extern"

local guild_other_view = class("guildOtherView",require("like_oo.oo_popBase"));

guild_other_view.m_ccb = nil;

-- 頭像節點
guild_other_view.m_head_icon_node = nil;
-- 頭銜節點
guild_other_view.m_title = nil;
-- 血條節點
guild_other_view.m_hpBg = nil;
-- 玩家名字
guild_other_view.m_pname = nil;
-- 玩家戰鬥力
guild_other_view.m_power = nil;

--場景創建函數
function guild_other_view:onCreate(  )
	-- body

	-- 此處添加自己的代碼，創建ui
	-- m_rootView 為當前view的根顯示節點
	self.m_ccb = luaCCBNode:create();

	self.m_ccb:openCCBFile("ccb/pop_guild_other.ccbi");

	self.m_head_icon_node = tolua.cast(self.m_ccb:objectForName("m_head_icon_node"),"CCNode");
	self.m_title = tolua.cast(self.m_ccb:objectForName("m_title"),"CCNode");
	self.m_hpBg = tolua.cast(self.m_ccb:objectForName("m_hpBg"),"CCSprite");
	self.m_pname = tolua.cast(self.m_ccb:objectForName("m_pname"),"CCLabelTTF");
	self.m_power = tolua.cast(self.m_ccb:objectForName("m_power"),"CCLabelTTF");

	self.m_rootView:addChild(self.m_ccb);
end

function guild_other_view:onEnter(  )
	-- body
end

function guild_other_view:onCommand( command , data )
	-- body
	-- view內命令回調函數
	-- 發命令用updataCommand（參考oo_viewBase）;
end

return guild_other_view;