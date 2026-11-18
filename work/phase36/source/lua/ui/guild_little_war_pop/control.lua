require "shared.extern"

local guild_little_war_pop_control = class("guildLittleWarPopControl" , require("like_oo.oo_controlBase"));

function guild_little_war_pop_control:onCreate(  )
	-- body
	-- 初始化函數框架自動調用
	
end

function guild_little_war_pop_control:onEnter(  )
	-- body
	-- 創建view結束後調用，用來
	-- self.controlBase.onEnter( self );
	-- 添加自己代碼
	local playerArray = self.m_data:getPlayerArray();
	local camp = "s";
	local uid = game_data:getUserStatusDataByKey("uid");
	local player_status = self.m_data:getPlayerArray();
	for k,v in pairs(player_status) do
		if(v.l_or_r == self.m_data.m_camp)then
			if(k == uid)then
				camp = 's';
			else
				camp = 'f';
			end
		else
			camp = "o";
		end
		self.m_view:createPlayer(k,camp,v.x,v.y);
	end
	self.m_view:smallOrBig(true);
end

function guild_little_war_pop_control:onHandle( msg , data )
	-- body
	-- 消息響應函數
	-- 消息發送方法updataMsg（參考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 3)then
		-- move
		self.m_view:moveTo(data.uid,data.x,data.y);
	elseif(msg == 4)then
		-- death
		self.m_view:death(data.uid);
	elseif(msg == 5)then
		-- birth
		self.m_view:birth(data.uid,data.x,data.y);
	elseif(msg == 10)then
		-- 迷你地圖變小
		self.m_view:smallOrBig(true);
		self.m_view:setRoundNum(data);		
	elseif(msg == 11)then
		-- 迷你地圖變大
		self.m_view:smallOrBig(false);
	end
end




return guild_little_war_pop_control;