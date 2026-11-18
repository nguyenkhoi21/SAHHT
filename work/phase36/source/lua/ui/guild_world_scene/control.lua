require "shared.extern"

local guild_world_scene_control = class("guildWorldSceneControl" , require("like_oo.oo_controlBase"));

guild_world_scene_control.m_warType = {};



function guild_world_scene_control:onCreate(  )
	-- body
	-- 初始化函數框架自動調用
	
end

function guild_world_scene_control:onEnter(  )
	-- body
	-- 創建view結束後調用，用來
	-- self.controlBase.onEnter( self );
	-- 添加自己代碼
	for i=1,4 do
		local tempData = self.m_data:getDataForId(i);
		local wx,wy = self.m_view:getWorldPos(i);
		self.m_warType[i] = tempData.game_status;
		if(tempData.game_status == 0)then
			-- 不能報名
			if(tempData.owner ~= "")then
				self:openView("guild_world_1",{data = tempData , x = wx , y = wy});
			end
		elseif(tempData.game_status == 1)then
			-- 可以報名
			self:openView("guild_world_2",{data = tempData , x = wx , y = wy});
		elseif(tempData.game_status == 2)then
			-- 等待戰鬥
			self:openView("guild_world_3",{data = tempData , x = wx , y = wy});
		elseif(tempData.game_status == 3)then
			-- 戰鬥中
			self:openView("guild_world_3",{data = tempData , x = wx , y = wy});
		end
	end
	-- if(self.m_data:showWin())then
	-- 	self:openView("guild_end_pop");
	-- end
end

function guild_world_scene_control:onHandle( msg , data )
	-- body
	-- 消息響應函數
	-- 消息發送方法updataMsg（參考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then
		self:openView("guild");
	elseif(msg == 3)then	
		local tempType = self.m_warType[data];
		if(tempType == 0)then
			-- 不能報名
			return;
		elseif(tempType == 1)then
			-- 可以報名
			self.m_data:getGuildFlagList(data);
		elseif(tempType == 2)then
			-- 等待戰鬥
			self:openView("guild_war",{game_id = data});
		elseif(tempType == 3)then
			-- 戰鬥中
			self:openView("guild_war",{game_id = data});
		end
	elseif( msg == 5 )then
		-- 已經得到公會列表數據
		if(self.m_data:isFirst() and self.m_data:isOwner())then
			self:openView("guild_tou1",{list_data=self.m_data.m_guildListData,game_id = data});
		else
			self:openView("guild_tou2",{list_data=self.m_data.m_guildListData,game_id = data});
		end
	end
end









return guild_world_scene_control;


