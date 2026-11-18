require "shared.extern"

local guild_player_list_option_control = class("guildPlayerListOptionControl",require("like_oo.oo_controlBase"));

function guild_player_list_option_control:onCreate(  )
	-- 初始化函數框架自動調用
end

function guild_player_list_option_control:onEnter(  )
	-- 創建view結束後調用，用來
	-- self.controlBase.onEnter( self );
	-- 添加自己代碼
end

function guild_player_list_option_control:onHandle( msg , data )
	-- 消息響應函數
	-- 消息發送方法updataMsg（參考oo_controlBase）view和control中都可以直接使用
	local function netDataBack( netData )
		self:updataMsg(2345,netData.data,"guild_player_list_pop");
		self:closeView();
	end
	if(msg == 1)then
		print( data );
	elseif(msg == 3)then		-- 玩家詳情
	    local function responseMethod(tag,gameData)
	        self:closeView();
	        game_scene:addPop("game_player_info_pop",{gameData = gameData})
	    end
	    local params = {};
	    params.uid = self.m_data:getUid();
	    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, params,"user_info")
	elseif(msg == 4)then		-- 升職
		self.m_data:getNetData( game_url.getUrlForKey("association_appoint_player") , {position = 2 , user_id = self.m_data:getUid()},netDataBack);
	elseif(msg == 5)then		-- 降職
		self.m_data:getNetData( game_url.getUrlForKey("association_appoint_player") , {position = 0 , user_id = self.m_data:getUid()},netDataBack);
	elseif(msg == 6)then		-- 踢出公會
		self.m_data:getNetData( game_url.getUrlForKey("association_remove_player") , {user_id = self.m_data:getUid()},netDataBack);
	elseif(msg == 7)then		-- 轉交會長
		self.m_data:getNetData( game_url.getUrlForKey("association_appoint_player") , {position = 1 , user_id = self.m_data:getUid()},netDataBack);
	elseif msg == 8 then		--解散工會
		local function myNetBackData(tag,gameData)
			self:goHome();
			game_util:addMoveTips({text = "Giải tán liên minh thành công!"})
		end
		local t_params = 
        {
            title = string_config.m_title_prompt,
            okBtnCallBack = function(target,event)
                self.m_data:getNetData( game_url.getUrlForKey("association_guild_destroy") , nil,myNetBackData);
                game_util:closeAlertView();
            end,   --可缺省
            okBtnText = "Xác định",      --可缺省
            text = "Xác định muốn giải tán liên minh? Liên minh giải tán xong, tất cả khoa kĩ đã nghiên cứu sẽ không tồn tại nữa! (Nếu trong liên minh vẫn còn hội viên khác tồn tại thì không thể giải tán liên minh)",      --可缺省
        }
        game_util:openAlertView(t_params);
    elseif msg == 9 then			  --退出公會
    	local function myNetBackData(tag,gameData)
			self:goHome();
			game_util:addMoveTips({text = "Thoát liên minh thành công"})
		end
		local t_params = 
        {
            title = string_config.m_title_prompt,
            okBtnCallBack = function(target,event)
                self.m_data:getNetData( game_url.getUrlForKey("association_guild_quit") , nil,myNetBackData);
                game_util:closeAlertView();
            end,   --可缺省
            okBtnText = "Xác định",      --可缺省
            text = "Bạn xác định muốn thoát liên minh? Thoát liên minh xong, tất cả điểm cống hiến sẽ biến mất.",      --可缺省
        }
        game_util:openAlertView(t_params);
	end
end

return guild_player_list_option_control;