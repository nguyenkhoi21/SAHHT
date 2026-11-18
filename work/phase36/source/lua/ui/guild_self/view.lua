require "shared.extern"

local guild_self_view = class("guildSelfView",require("like_oo.oo_popBase"));

guild_self_view.m_ccb = nil;

-- 頭像代替節點
guild_self_view.m_head_icon_node = nil;
-- 頭銜代替節點
guild_self_view.m_title = nil;
-- vip等級標籤
guild_self_view.m_vip_label = nil;
-- 玩家等級標籤
guild_self_view.m_lv_label = nil;
-- 玩家名字
guild_self_view.m_player_name = nil;
-- 血條背景ccsprite
guild_self_view.m_exp_bar_bg = nil;
-- 血條數字
guild_self_view.m_exp_label = nil;
-- 金錢數字
guild_self_view.m_gem_label = nil;

--場景創建函數
function guild_self_view:onCreate(  )
	-- body

	-- 此處添加自己的代碼，創建ui
	-- m_rootView 為當前view的根顯示節點
	self.m_ccb = luaCCBNode:create();

	local function onMainBtnClick( target,event )
		-- body
	end
	self.m_ccb:registerFunctionWithFuncName( "onMainBtnClick",onMainBtnClick );
	self.m_ccb:openCCBFile("ccb/pop_guild_self.ccbi");

	self.m_head_icon_node = tolua.cast(self.m_ccb:objectForName("m_head_icon_node"),"CCNode");
	self.m_title = tolua.cast(self.m_ccb:objectForName("m_title"),"CCNode");
	self.m_vip_label = tolua.cast(self.m_ccb:objectForName("m_vip_label"),"CCLabelTTF");
	self.m_lv_label = tolua.cast(self.m_ccb:objectForName("m_lv_label"),"CCLabelTTF");
	self.m_player_name = tolua.cast(self.m_ccb:objectForName("m_player_name"),"CCLabelTTF");
	self.m_exp_bar_bg = tolua.cast(self.m_ccb:objectForName("m_exp_bar_bg"),"CCSprite");
	self.m_exp_label = tolua.cast(self.m_ccb:objectForName("m_exp_label"),"CCLabelTTF");
	self.m_gem_label = tolua.cast(self.m_ccb:objectForName("m_gem_label"),"CCLabelTTF");

	self.m_rootView:addChild(self.m_ccb);
end

function guild_self_view:onEnter(  )
	-- body
end

function guild_self_view:onCommand( command , data )
	-- body
	-- view內命令回調函數
	-- 發命令用updataCommand（參考oo_viewBase）;
end

return guild_self_view;