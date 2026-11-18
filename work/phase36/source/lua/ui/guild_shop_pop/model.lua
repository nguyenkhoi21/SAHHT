require "shared.extern"

local guild_shop_pop_model = class("guildShopPopModel",require("like_oo.oo_dataBase"));

function guild_shop_pop_model:onCreate(  )
	self:getData(game_url.getUrlForKey("association_shop"));
end

function guild_shop_pop_model:onEnter()
	-- cclog("self.m_data.data == " .. json.encode(self.m_data.data))
end

function guild_shop_pop_model:getItemCount(  )
	return #self.m_data.data.shop
end

function guild_shop_pop_model:getItem( index )
	return self.m_data.data.shop[index];
end

function guild_shop_pop_model:showTimeLayer( index )
	local tempItem = self:getItem(index);
	if(tempItem.total_num == -1)then
		return false;
	end
	if( tonumber(tempItem.remain_amount) <= 0 ) then
		return true;
	else
		return false;
	end
end
function guild_shop_pop_model:getShopLevel()
	return self.m_data.data.shop_lv
end
function guild_shop_pop_model:getItemIcon( index )
	local tempItem = self:getItem(index);
	local reward = tempItem.shop_reward[1];
	local icon,name,count = game_util:getRewardByItemTable(reward);
	return icon,name,count;
end

function guild_shop_pop_model:getScore(  )
	return game_data:getUserStatusDataByKey("association_dedication");
end



return guild_shop_pop_model;