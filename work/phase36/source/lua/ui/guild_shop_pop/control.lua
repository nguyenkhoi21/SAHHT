require "shared.extern"

local guild_shop_pop_control = class("guildShopPopControl",require("like_oo.oo_controlBase"));

function guild_shop_pop_control:onHandle( msg , data )
	if(msg == 1)then
		print( data );
	elseif( msg == 2 )then   -- 關閉
		self:closeView();
	elseif( msg == 3 )then   -- 查看詳情

	elseif( msg == 4 )then   -- 指定對像購買 data 為商品索引
		cclog("------ buy " .. tostring(data));
		local itemData = self.m_data:getItem(data);
		if(self.m_data:showTimeLayer(data))then
			game_util:addMoveTips({text = "Vật phẩm này đã bán hết"})
			return;
		end
		local function netDataCallBack( netData )
			self.m_data.m_data.data.shop = netData.data.shop.shop;
			self.m_view:setScore(self.m_data:getScore());
			cclog("netData == " .. json.encode(netData.data))
			game_util:rewardTipsByDataTable(netData.data.association_buy_commodity);
			self.m_view:updataItem();

			--更新數據到guild
			self:updataMsg( 1235 , self.m_data:getScore() , "parent" )		
		end
		self.m_data:getNetData( game_url.getUrlForKey("association_buy_commodity"),{commodity_id = itemData.id},netDataCallBack);
	elseif( msg == 5 )then   -- 指定對象的詳情 data 為商品索引 
		cclog("------ detail " .. tostring(data));
		local index = data
		-- local tempItem = self.m_data:getItem(index);
		-- local rewardItem = tempItem.shop_reward[1]
		-- local item_type = rewardItem[1]

		-- if item_type == 5 then
		-- 	local hero_cid = rewardItem[2]
  --           game_scene:addPop("game_hero_info_pop",{cId = tostring(hero_cid),openType = 4})
		-- else
		-- 	local tempIcon,tempName,tempCount = self.m_data:getItemIcon(index);
		-- 	if tempName == nil then
		-- 		tempName = ""
		-- 	end
		-- 	game_util:addMoveTips({text = tempName .. "×" .. tempCount})
		-- end
		self.m_view:onLookFunc(index)
	end
end

return guild_shop_pop_control;