require "shared.extern"

local guild_war_click_control = class("guildWarClickControl" , require("like_oo.oo_controlBase"));

function guild_war_click_control:onCreate(  )
	-- body
	-- 初始化函數框架自動調用
	
end

function guild_war_click_control:onEnter(  )
	-- body
	-- 創建view結束後調用，用來
	-- self.controlBase.onEnter( self );
	-- 添加自己代碼
	self.m_view:showButton(self.m_data:getFlag( ));
end

function guild_war_click_control:onHandle( msg , data )
	-- body
	-- 消息響應函數
	-- 消息發送方法updataMsg（參考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 3)then
		if(data == 1)then
			local lx,ly = self.m_data:getLogicPos();
			self:updataMsg(100,{m_x = lx, m_y = ly},"parent");
			self:closeView();
		elseif(data == 2)then
			local lx,ly = self.m_data:getLogicPos();
			self:updataMsg(100,{m_x = lx, m_y = ly},"parent");
			self:closeView();
		elseif(data == 3)then
			local lx,ly = self.m_data:getLogicPos();
			self:updataMsg(100,{m_x = lx, m_y = ly},"parent");
			self:closeView();
		end
	end
end




return guild_war_click_control;