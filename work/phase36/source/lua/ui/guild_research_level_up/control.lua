require "shared.extern"

local guild_research_level_up_control = class("guildResearchLevelUpControl" , require("like_oo.oo_controlBase"));

function guild_research_level_up_control:onCreate(  )
	-- body
	-- 初始化函數框架自動調用
	
end

function guild_research_level_up_control:onEnter(  )
	-- body
	-- 創建view結束後調用，用來
	self.controlBase.onEnter( self );
	-- 添加自己代碼
end

function guild_research_level_up_control:getFlag( id )
	local tempFlag = {
		"guild",
		"shop",
		"",
		"gvg_player",
		"gvg_monster",
		"gvg_home",
		"map",
		"boss"
	}
	return tempFlag[id];
end
function guild_research_level_up_control:getFlagName(id)
	local tempFlagName = {
		"Liên minh",
		"Cửa hàng liên minh",
		"Nhiệm vụ liên minh",
		"Năng lực đội viên",
		"Năng lực bảo vệ",
		"Lượng HP nhà chính",
		"Bản đồ trung lập",
		"BOSS thế giới"
	}
	return tempFlagName[id];
end

function guild_research_level_up_control:onHandle( msg , data )
	-- body
	-- 消息響應函數
	-- 消息發送方法updataMsg（參考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then
		self:closeView();
	elseif(msg == 3)then
		-- 升級消息
		local tempId = self.m_data:getId();
		local tempFlag = self:getFlag(tempId);
		local tempFlagName = self:getFlagName(tempId);

		function netDataCallBack( netData )
			-- body
			self.m_data.m_data.lv = self.m_data:getCurLv()+1;
			self:updataMsg(1234,netData.data,"parent");
			self:updataMsg(1234,netData.data.guild,"guild_research_pop");
			self.m_view:resetData();

			--升級效果
			game_util:addMoveTips({text = "Nâng cấp thành công!".. tempFlagName .. "Cấp+1"})
		end
		self.m_data:getNetData(game_url.getUrlForKey("association_levelup"),{flag = tempFlag},netDataCallBack);
	end
end




return guild_research_level_up_control;