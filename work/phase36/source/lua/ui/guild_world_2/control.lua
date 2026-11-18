require "shared.extern"

local guild_world_2_control = class("guildWorld2Control" , require("like_oo.oo_controlBase"));

function guild_world_2_control:onCreate(  )
	-- body
	-- 初始化函數框架自動調用
	
end

function guild_world_2_control:onEnter(  )
	-- body
	-- 創建view結束後調用，用來
	-- self.controlBase.onEnter( self );
	-- 添加自己代碼
end

function guild_world_2_control:onHandle( msg , data )
	-- body
	-- 消息響應函數
	-- 消息發送方法updataMsg（參考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	end
end




return guild_world_2_control;