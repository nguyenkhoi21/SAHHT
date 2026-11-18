require "shared.extern"

local guild_detail_pop_control = class("guildDetailPopControl",require("like_oo.oo_controlBase"));

function guild_detail_pop_control:onCreate(  )
	cclog("--------------- guild_mini_pop_control onCreate");
	
end

function guild_detail_pop_control:onEnter(  )
	local tx,ty = self.m_view.m_miniNode:getPosition();
	-- self:openView("guild_mini_pop",{data = self.m_data.m_data , x = tx , y = ty});
end

function guild_detail_pop_control:onHandle( msg , data )
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then 		-- 關閉消息
		self:closeView();
		-- self:updataMsg(3,nil,"guild_mini_pop");
	elseif(msg == 3)then 		-- 加入當前公會
		local function back( data )
			self:closeView();
			self:updataMsg(3,nil,"guild_mini_pop");
			game_util:addMoveTips({text = "Xin thành công, xin chờ hội trưởng đồng ý"})
		end
		self.m_data:getNetData(game_url.getUrlForKey("association_guild_join"),self.m_data.m_params,back);
	elseif(msg == 4)then 		-- 公會成員被點擊消息
	elseif(msg == 5)then		-- 公會mini彈框創建完畢
		cclog("--------------- yock Tạo cửa sổ mini liên minh hoàn tất");
		-- local tx,ty = self.m_view.m_miniNode:getPosition();
		-- self:updataMsg(2,{x = tx,y = ty},"guild_mini_pop");
	
	end
end

return guild_detail_pop_control;