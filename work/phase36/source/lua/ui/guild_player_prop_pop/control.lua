require "shared.extern"

local guild_player_prop_pop = class("guildPlayerPropPop" , require("like_oo.oo_controlBase"));

function guild_player_prop_pop:onCreate(  )
	-- body
	-- 初始化函數框架自動調用
	
end

function guild_player_prop_pop:onEnter(  )
	-- body
	-- 創建view結束後調用，用來
	-- self.controlBase.onEnter( self );
	-- 添加自己代碼
end

function guild_player_prop_pop:onHandle( msg , data )
	-- body
	-- 消息響應函數
	-- 消息發送方法updataMsg（參考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then
		self:closeView();
	elseif(msg == 3)then
		-- 申請者詳情
		local function responseMethod(tag,gameData)
	        self:closeView();
	        game_scene:addPop("game_player_info_pop",{gameData = gameData})
	    end
	    local params = {};
	    params.uid = self.m_data:getUid();
	    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, params,"user_info")
	elseif(msg == 4)then
		-- 同意
		local function netDataCallBack( netData )
			-- body
			self:updataMsg( 1234 , netData.data , "parent" );
			self:updataMsg( 1234 , netData.data , "guild_player_prop");
			self:closeView();
		end
		self.m_data:getNetData(game_url.getUrlForKey("association_guild_agree"),{user_id=self.m_data:getUid()},netDataCallBack);
	elseif(msg == 5)then
		-- 拒絕
		local function netDataCallBack( netData )
			-- body
			self:updataMsg( 1234 , netData.data , "parent" );
			self:updataMsg( 1234 , netData.data , "guild_player_prop");
			self:closeView();
		end
		self.m_data:getNetData(game_url.getUrlForKey("association_guild_not_agree"),{user_id=self.m_data:getUid()},netDataCallBack);
	end
end

function guild_player_prop_pop:onUpdata(  )
	-- body
end




return guild_player_prop_pop;