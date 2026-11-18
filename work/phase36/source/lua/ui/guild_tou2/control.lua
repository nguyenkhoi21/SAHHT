require "shared.extern"

local guild_tou2_control = class("guildTou2Control" , require("like_oo.oo_controlBase"));

function guild_tou2_control:onCreate(  )
	-- body
	-- 初始化函數框架自動調用
	
end

function guild_tou2_control:onEnter(  )
	-- body
	-- 創建view結束後調用，用來
	-- self.controlBase.onEnter( self );
	-- 添加自己代碼
end

function guild_tou2_control:onHandle( msg , data )
	-- body
	-- 消息響應函數
	-- 消息發送方法updataMsg（參考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then
		self:closeView();
	elseif(msg == 3)then
		self:openView("guild_tou1",{list_data=self.m_data:getListData(),game_id = self.m_data:getGameId()});
		self:closeView();
	elseif(msg == 4)then
		-- 臨時方法開始戰鬥
		cclog("---------- test start battle ");
		local function tempCallBack( netdata )
			-- body
		end
		self.m_data:getNetData(game_url.getUrlForKey("association_start_battle"),{game_id=self.m_data:getGameId()},tempCallBack);
	end
end




return guild_tou2_control;