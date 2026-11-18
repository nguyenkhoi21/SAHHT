require "shared.extern"

local guild_world_2_view = class("guildWorld2View",require("like_oo.oo_popBase"));

guild_world_2_view.m_ccb = nil;


-- 公會挑戰等待倒計時
guild_world_2_view.m_time = nil;

--場景創建函數
function guild_world_2_view:onCreate(  )
	-- body

	-- 此處添加自己的代碼，創建ui
	-- m_rootView 為當前view的根顯示節點
	self.m_ccb = luaCCBNode:create();

	self.m_ccb:openCCBFile("ccb/pop_guild_world_2.ccbi");

	self.m_time = tolua.cast(self.m_ccb:objectForName("m_time"),"CCLabelTTF");

	local tempTime = self.m_control.m_data:getResiTime();
	local tempDay = math.floor(tempTime/60/60/24);
	if(tempDay>0)then
		self.m_time:setString(tostring(tempDay) .. "Sau ngày");
	else
		local tempHour = math.floor(tempTime/60/60);
		if(tempHour>0)then
			self.m_time:setString(tostring(tempHour) .. "Sau giờ");
		else
			self.m_time:setString("Hiện tại");
		end
	end
	
	self.m_rootView:addChild(self.m_ccb);
	self:consumeTouch(false);
	self.m_ccb:setPosition(ccp(self.m_control.m_data:getPos()));
end

function guild_world_2_view:onEnter(  )
	-- body
end

function guild_world_2_view:onCommand( command , data )
	-- body
	-- view內命令回調函數
	-- 發命令用updataCommand（參考oo_viewBase）;
end



return guild_world_2_view;