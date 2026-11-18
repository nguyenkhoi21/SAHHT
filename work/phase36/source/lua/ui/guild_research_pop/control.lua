require "shared.extern"

local guild_research_pop_control = class("guildResearchPopControl",require("like_oo.oo_controlBase"));


function guild_research_pop_control:onCreate(  )
	-- body
	-- 初始化函數框架自動調用
	
end

function guild_research_pop_control:onEnter(  )
	-- body
	-- 創建view結束後調用，用來
	-- 添加自己代碼
end

function guild_research_pop_control:onHandle( msg , data )
	-- body
	-- 消息響應函數
	-- 消息發送方法updataMsg（參考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then
		self:closeView();
	elseif(msg >= 3 and msg <= 10)then
		local tempLv = self.m_data:getLvWithIndex(msg-2);
		if(self.m_data:canLevelup())then
			self:openView("guild_research_level_up",{ id=msg-2,lv=tempLv });
		else
			self:openView("guild_research_level",{ id=msg-2,lv=tempLv });
		end
	elseif(msg == 1234)then
		self.m_data.m_data = data;
		self.m_view:resetData();
	end
end

return guild_research_pop_control;