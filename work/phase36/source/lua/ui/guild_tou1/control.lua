require "shared.extern"

local guild_tou1_control = class("guildTou1Control" , require("like_oo.oo_controlBase"));

function guild_tou1_control:onCreate(  )
	-- body
	-- 初始化函數框架自動調用
	
end

function guild_tou1_control:onEnter(  )
	-- body
	-- 創建view結束後調用，用來
	-- self.controlBase.onEnter( self );
	-- 添加自己代碼
end

function guild_tou1_control:onHandle( msg , data )
	-- body
	-- 消息響應函數
	-- 消息發送方法updataMsg（參考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then
		self:closeView();
	elseif(msg == 3)then
		-- 投票消息
		self:openView("guild_tou3",self.m_data:getParams());
	end
end




return guild_tou1_control;