require "shared.extern"

local guild_tou1_view = class("guildTou1View",require("like_oo.oo_popBase"));

guild_tou1_view.m_ccb = nil;
-- 公會名字
guild_tou1_view.m_gname = nil;			
-- 大陸名字
guild_tou1_view.m_worldName = nil;
-- 大陸說明
guild_tou1_view.m_worldDetail = nil;
-- 大陸圖片位置節點
guild_tou1_view.m_worldNode = nil;
-- 佔領時間
guild_tou1_view.m_firstTime = nil;
-- 佔領時長
guild_tou1_view.m_timeLong = nil;
-- 挑戰者加成比例
guild_tou1_view.m_leftParent = nil;
-- 佔領者加成比例
guild_tou1_view.m_rightParent = nil;


--場景創建函數
function guild_tou1_view:onCreate(  )
	-- body

	-- 此處添加自己的代碼，創建ui
	-- m_rootView 為當前view的根顯示節點
	self.m_ccb = luaCCBNode:create();
	local function onBack( target,event )
		-- body
		self:updataMsg(2);
	end
	local function onButtonClick( target,event )
		-- body
		cclog("------------ tou1 onButtonClick ");
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if(btnTag == 1)then
        	-- 捐獻按鈕
        	self:updataMsg( 3 );
        elseif(btnTag == 2)then
        	-- 獎勵詳情
        elseif(btnTag == 3)then
        	-- 歷史查看
        end
	end
	self.m_ccb:registerFunctionWithFuncName( "onBack",onBack );
	self.m_ccb:registerFunctionWithFuncName( "onButtonClick",onButtonClick );
	self.m_ccb:openCCBFile("ccb/pop_guild_tou1.ccbi");

	self.m_gname = tolua.cast(self.m_ccb:objectForName("m_gname"),"CCLabelTTF");
	self.m_worldName = tolua.cast(self.m_ccb:objectForName("m_worldName"),"CCLabelTTF");
	self.m_worldDetail = tolua.cast(self.m_ccb:objectForName("m_worldDetail"),"CCLabelTTF");
	self.m_worldNode = tolua.cast(self.m_ccb:objectForName("m_worldNode"),"CCNode");
	self.m_firstTime = tolua.cast(self.m_ccb:objectForName("m_firstTime"),"CCLabelTTF");
	self.m_timeLong = tolua.cast(self.m_ccb:objectForName("m_timeLong"),"CCLabelTTF");
	self.m_leftParent = tolua.cast(self.m_ccb:objectForName("m_leftParent"),"CCLabelTTF");
	self.m_rightParent = tolua.cast(self.m_ccb:objectForName("m_rightParent"),"CCLabelTTF");

	local uiData = self.m_control.m_data:getUIData()
	local ownerName = uiData.owner
	if ownerName == nil or ownerName == "" then
		self.m_gname:setString("Không")
	else 
		self.m_gname:setString(tostring(ownerName))
	end

	self.m_rootView:addChild(self.m_ccb);
end

function guild_tou1_view:onEnter(  )
	-- body
end

function guild_tou1_view:onCommand( command , data )
	-- body
	-- view內命令回調函數
	-- 發命令用updataCommand（參考oo_viewBase）;
end

return guild_tou1_view;