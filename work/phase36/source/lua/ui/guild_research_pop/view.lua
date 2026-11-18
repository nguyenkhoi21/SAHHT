require "shared.extern"

local guild_research_pop_view = class("guildResearchPopView",require("like_oo.oo_popBase"));

guild_research_pop_view.m_ccb = nil;
guild_research_pop_view.m_money = nil;
guild_research_pop_view.m_glv = {};

guild_research_pop_view.lv_sprite = {};
guild_research_pop_view.tech_btn = {};

--場景創建函數
function guild_research_pop_view:onCreate(  )
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
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        self:updataMsg(btnTag+2);
	end
	local function onMainBtnClick( target,event )
		
	end
	self.m_ccb:registerFunctionWithFuncName("onBack",onBack);
	self.m_ccb:registerFunctionWithFuncName("onButtonClick",onButtonClick);
	self.m_ccb:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
	self.m_ccb:openCCBFile("ccb/pop_guild_research.ccbi");

	self.m_rootView:addChild(self.m_ccb);

	self.m_money = tolua.cast(self.m_ccb:objectForName("m_money"),"CCLabelTTF");
	self:resetData();
end

function guild_research_pop_view:resetData(  )
	local openCfg = self.m_control.m_data:getTechOpenCfg()

	self.m_money:setString(tostring(self.m_control.m_data:getMoney()));

	local tempGuildData = self.m_control.m_data:getGuildData();
	for i=1,8 do
		self.m_glv[i] = tolua.cast(self.m_ccb:objectForName("m_glv_" .. tostring(i)),"CCLabelTTF");

		self.m_glv[i]:setString(tostring(self.m_control.m_data:getLvWithIndex(i)));

		--開啟條件
		self.lv_sprite[i] = tolua.cast(self.m_ccb:objectForName("lv_sprite_" .. tostring(i)),"CCSprite")
		self.tech_btn[i] = tolua.cast(self.m_ccb:objectForName("tech_btn_" .. tostring(i)),"CCControlButton")
		local itemCfg = openCfg[tostring(i)]
		local open_level = itemCfg["open_level"]
		if open_level == -1 then 
			self.lv_sprite[i]:setVisible(false)
			self.tech_btn[i]:setEnabled(false)
			self.m_glv[i]:setVisible(false)

			self.tech_btn[i]:setColor(ccc3(76,76,76))
			local label = game_util:createLabelBMFont({text = "Tạm thời chưa mở", color = ccc3(255,241,44)})
			label:setAnchorPoint(ccp(0.5,0.5));
			label:setPosition(ccp(self.tech_btn[i]:getContentSize().width*0.5,-5))
			self.tech_btn[i]:addChild(label)
		elseif open_level > tempGuildData then
			self.lv_sprite[i]:setVisible(false)
			self.tech_btn[i]:setEnabled(false)
			self.m_glv[i]:setVisible(false)

			self.tech_btn[i]:setColor(ccc3(76,76,76)) 
			local label = game_util:createLabelBMFont({text = "Cấp " .. open_level .. " mở", color = ccc3(255,241,44)})
			label:setAnchorPoint(ccp(0.5,0.5));
			label:setPosition(ccp(self.tech_btn[i]:getContentSize().width*0.5,-5))
			self.tech_btn[i]:addChild(label)
		else 
			self.lv_sprite[i]:setVisible(true)
			self.tech_btn[i]:setEnabled(true)
			self.m_glv[i]:setVisible(true)
		end
	end
end

function guild_research_pop_view:onEnter(  )
	-- body
end

function guild_research_pop_view:onCommand( command , data )
	-- body
	-- view內命令回調函數
	-- 發命令用updataCommand（參考oo_viewBase）;
end


return guild_research_pop_view;