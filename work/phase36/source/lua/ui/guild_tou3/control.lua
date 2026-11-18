require "shared.extern"

local guild_tou3_control = class("guildTou3Control" , require("like_oo.oo_controlBase"));

function guild_tou3_control:onCreate(  )
	-- body
	-- 初始化函數框架自動調用
	
end

function guild_tou3_control:onEnter(  )
	-- body
	-- 創建view結束後調用，用來
	-- self.controlBase.onEnter( self );
	-- 添加自己代碼
end

function guild_tou3_control:onHandle( msg , data )
	-- body
	-- 消息響應函數
	-- 消息發送方法updataMsg（參考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then
		self:closeView();
	elseif(msg == 3)then
		if(data<=0)then
			return;
		end
		local function dataCallBack( netdata )
			-- body
			self:openView("guild_tou2",{list_data=netdata,game_id = self.m_data:getGameId()});
			self:closeView();
			self:updataMsg(2,nil,"guild_tou1");
		end
		self.m_data:getNetData(game_url.getUrlForKey("association_con_flag"),{game_id=self.m_data:getGameId(),flag=data},dataCallBack);
	end
end




return guild_tou3_control;