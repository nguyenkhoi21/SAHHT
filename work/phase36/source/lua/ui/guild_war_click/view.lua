require "shared.extern"

local guild_war_click_view = class("guildWarClickView",require("like_oo.oo_popBase"));

guild_war_click_view.m_ccb = nil;

guild_war_click_view.m_button = {};

--場景創建函數
function guild_war_click_view:onCreate(  )
	-- body

	-- 此處添加自己的代碼，創建ui
	-- m_rootView 為當前view的根顯示節點
	self.m_ccb = luaCCBNode:create();

	local function onButtonClick( target,event )
		-- body
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        self:updataMsg(3,btnTag);
	end
	self.m_ccb:registerFunctionWithFuncName( "onButtonClick",onButtonClick );
	self.m_ccb:openCCBFile("ccb/pop_guild_war_click.ccbi");

	for i=1,3 do
		self.m_button[i] = tolua.cast(self.m_ccb:objectForName("m_button" .. tostring(i)),"CCControlButton");
		self.m_button[i]:setVisible(false);
	end
	local x,y = self.m_control.m_data:getPos();
	self.m_ccb:setPosition(ccp(x,y));
	self.m_rootView:addChild(self.m_ccb);
end

function guild_war_click_view:onEnter(  )
	-- body
	self:canClose(true);
end

function guild_war_click_view:onCommand( command , data )
	-- body
	-- view內命令回調函數
	-- 發命令用updataCommand（參考oo_viewBase）;
end

-- 顯示按鈕 1 攻擊 2,移動 3.佔領
function guild_war_click_view:showButton( id )
	-- body
	for i=1,3 do
		self.m_button[i]:setVisible(false);
	end
	cclog("---------- showButton " .. id);
	self.m_button[id]:setVisible(true);
end

return guild_war_click_view;