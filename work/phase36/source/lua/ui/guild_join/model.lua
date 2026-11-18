require "shared.extern"

local guild_join_model = class( "guildJoinModel",require("like_oo.oo_dataBase") );

guild_join_model.defaultData = nil;
function guild_join_model:create( name )
	self.dataBase.create( self,name );
	self:getData( game_url.getUrlForKey("association_guild_all"),nil );
end
--對數據排下序
function guild_join_model:onCreate(  )

end
function guild_join_model:onEnter()
	-- local tempTable = {}
	-- for i=#self.m_data.data.guild_list,1,-1 do
	-- 	table.insert(tempTable,self.m_data.data.guild_list[i])
	-- end
	-- self.m_data.data.guild_list = tempTable
	self.defaultData = self.m_data.data.guild_list
end
-- 取得指定索引的公會基本信息
function guild_join_model:getGuildData( index )
	if(index>#self.m_data.data.guild_list)then
		return nil;
	end
	return self.m_data.data.guild_list[index];
end
--[[
	獲得back up
]]
function guild_join_model:getBackUp()
	return self.defaultData
end
-- 獲得公會總數
function guild_join_model:getGuildCount(  )
	-- util.printf(self.m_data.data.guild_list);
	return #self.m_data.data.guild_list;
end
function guild_join_model:getGuild(  )
	return self.m_data.data.guild_list;
end
--[[
	設置為原來的排序
]]
function guild_join_model:setDefaultData()
	self.m_data.data.guild_list = self.defaultData
end
--[[
	設置排序後的data
]]
function guild_join_model:setGuildData(tempData)
	self.m_data.data.guild_list = tempData
end
-- 獲得自己的形象名
function guild_join_model:getSelfIconName(  )
	local tempRole = game_data:getUserStatusDataByKey("role");
	local tempRoleDetail = self:getNativeData( "role_detail" );
	return "humen/" .. tempRoleDetail[tostring(tempRole)].img .. ".png";
end

-- 根據名字查找公會索引
function guild_join_model:findGuildWithName( name )

end



return guild_join_model;