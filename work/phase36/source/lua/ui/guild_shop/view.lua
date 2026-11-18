require "shared.extern"

local guild_Shop_view = class("guildShopView",require("like_oo.oo_popBase"));

guild_Shop_view.m_ccb = nil;

function guild_Shop_view:create(  )
	-- body
	local pop = self.popBase.create( self );
	local function onButtonClick( target,event )
		-- body
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if(btnTag==1)then  -- 查看公會詳情按鈕
        	self:updataMsg( 2 )
        elseif(btnTag==2)then    -- 公會申請加入按鈕
        	self:updataMsg( 3 );
        end
	end
	cclog("------------ guild_join_pop_view:create");
	self.m_ccb = luaCCBNode:create();

	self.m_ccb:registerFunctionWithFuncName( "onButtonClick",onButtonClick );
	self.m_ccb:openCCBFile("ccb/ui_guild_shop.ccbi");

	pop:addChild(self.m_ccb);
	return pop;
end


return guild_Shop_view;