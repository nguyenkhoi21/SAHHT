-- 天赋升级弹框
local ui_talent_skill_pop = {}
function ui_talent_skill_pop:destroy()
	cclog("------------------ ui_talent_skill_pop destroy -------------")
end

function ui_talent_skill_pop:back( )
	-- self:destroy();
	game_scene:removePopByName("ui_talent_skill_pop");
end


function ui_talent_skill_pop:createUi()
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target,"CCNode")
		local btnTag = tagNode:getTag()
		if btnTag == 1 then
			self:back()
		elseif btnTag == 101 then
			if self.m_skill_data.Can_up == false then game_util:addMoveTips({text = "Skill trước chưa đầy, không thể nâng cấp"}) return end
			if self.m_cost > self.m_skill_cost then 
				local t_params = 
                    {
                        title = "Nhắc nhở",
                        okBtnCallBack = function(target,event)
                            require("game_ui.game_pop_up_box").close();
                            self:back()
                        end,   --可缺省
                        okBtnText = "Đóng",       --可缺省
                        text = "Thất bại, không đủ đạo cụ",      --可缺省
                        onlyOneBtn = true,          --可缺省
                    }
                require("game_ui.game_pop_up_box").show(t_params);
                return
			end
			if self.m_skill_data.level == self.m_skill_data.max_level then game_util:addMoveTips({text = "Skill đã đầy cấp, không thể tăng"}) return end
			local t_params = {
	                title = string_config.m_title_prompt,
		            okBtnCallBack = function(target,event)
		                    game_util:closeAlertView();
					local function responseMethod(tag, gameData)
				    	if self.backCallFunc and gameData then
				    		game_util:addMoveTips({text = "Skill đã tăng"})
				    		-- cclog2(gameData)
				    		game_scene:removePopByName("ui_talent_skill_pop");
				    		self.backCallFunc(gameData)
				    	end
			    	end
			    	local params = {}
			    	params.talent_skill_id = self.m_skill_data.id
			    	params.c_id = self.check_card_id 
				    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("talentskill_traincardtalent"), http_request_method.GET, params,"talentskill_traincardtalent");
				end,   --可缺省
                cancelBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                end,
                okBtnText = "Xác nhận",       --可缺省
                cancelBtnText = "Hủy",
                onlyOneBtn = false,
                text ="                   Xác nhận nâng cấp",      --可缺省
                touchPriority = GLOBAL_TOUCH_PRIORITY-12,
            }
            game_util:openAlertView(t_params);
		elseif btnTag == 102 then
			if self.m_skill_data.Can_up == false then game_util:addMoveTips({text = "Skill trước chưa đầy, không thể nâng cấp"}) return end
			if self.m_cost > self.m_skill_cost then
				local t_params = 
                    {
                        title = "Nhắc nhở",
                        okBtnCallBack = function(target,event)
                            require("game_ui.game_pop_up_box").close();
                            self:back()
                        end,   --可缺省
                        okBtnText = "Đóng",       --可缺省
                        text = "Thất bại, không đủ đạo cụ",      --可缺省
                        onlyOneBtn = true,          --可缺省
                    }
                    require("game_ui.game_pop_up_box").show(t_params);
                    return
			end
			if self.m_skill_data.level == self.m_skill_data.max_level then game_util:addMoveTips({text = "Skill đã đầy cấp, không thể tăng"}) return end
		    
			local t_params = {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    game_util:closeAlertView();
				    local function responseMethod(tag, gameData)
				    	if self.backCallFunc and gameData then
				    		game_scene:removePopByName("ui_talent_skill_pop");
				    		game_util:addMoveTips({text = "Skill đã tăng"})
				    		-- cclog2(gameData)
				    		self.backCallFunc(gameData)
				    	end
			    	end
			    	local params = {}
			    	params.talent_skill_id = self.m_skill_data.id
			    	params.c_id = self.check_card_id 
			    	params.is_max = 1
				    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("talentskill_traincardtalent"), http_request_method.GET, params,"talentskill_traincardtalent");
				end,   --可缺省
                cancelBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                end,
                okBtnText = "Xác nhận",       --可缺省
                cancelBtnText = "Hủy",
                onlyOneBtn = false,
                text ="                Muốn nâng cấp nhanh?",      --可缺省
                touchPriority = GLOBAL_TOUCH_PRIORITY-12,
            }
            game_util:openAlertView(t_params);
		end
	end
	local ccbNode =  luaCCBNode:create();
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_talent_levelup_pop.ccbi")
	self.skill_name_lb = ccbNode:labelTTFForName("skill_name_lb")
	self.LV_lb = ccbNode:labelTTFForName("LV_lb")
	self.lb_msg = ccbNode:labelTTFForName("lb_msg")
	self.cost_lb = ccbNode:labelTTFForName("cost_lb")
	self.left_lb = ccbNode:labelTTFForName("left_lb")
	self.skill_sp = ccbNode:spriteForName("skill_sp")
	self.m_btn_close = ccbNode:controlButtonForName("m_btn_close")
	self.m_btn_levelup01 = ccbNode:controlButtonForName("m_btn_levelup01")
	self.m_btn_levelup02 = ccbNode:controlButtonForName("m_btn_levelup02")
	self.m_root_layer = ccbNode:layerForName("m_root_layer")
	self.m_cost_node = ccbNode:nodeForName("cost_node")
	self.m_left_node = ccbNode:nodeForName("left_node")
	self.m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_btn_levelup01:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
   	self.m_btn_levelup02:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode
	return ccbNode
end


function ui_talent_skill_pop:refreshUi()
	local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(self.m_skill_data.img .. ".png")
    if tempSpriteFrame then
        self.skill_sp:setDisplayFrame(tempSpriteFrame)
    end
	if self.m_skill_data then
		self.skill_name_lb:setString(self.m_skill_data.name)
		self.LV_lb:setString("LV . " .. self.m_skill_data.level)
		self.lb_msg:setString(self.m_skill_data.story)
		if self.m_level < self.m_skill_data.max_level then
			self.cost_lb:setString(self.cost[self.m_level + 1])
		else
			self.cost_lb:setString(self.cost[self.m_level])
		end
		self.left_lb:setString(self.m_skill_cost)
	end
    if self.m_cost_id then
	    local config_date = getConfig(game_config_field.item);
	    local itemCfg = config_date:getNodeWithKey(tostring(self.m_cost_id));
	    if itemCfg == nil then return end
    	local itemImg = itemCfg:getNodeWithKey("icon"):toStr();
    	local itemName = itemCfg:getNodeWithKey("name"):toStr();
    	local icon1 = CCSprite:create("icon/" .. itemImg .. ".png")
    	local icon2 = CCSprite:create("icon/" .. itemImg .. ".png")
    	if icon1 and icon2 then
    	    icon1:setScale(0.5)
	    	icon2:setScale(0.5)
			icon1:setPosition(ccp(0,0))
			icon2:setPosition(ccp(0,0))
			self.m_cost_node:addChild(icon1)
			self.m_left_node:addChild(icon2)
		end
    end
end


function ui_talent_skill_pop:init(t_params)
	self.m_skill_data = t_params.skill_data
	self.cost =  self.m_skill_data.add_cost[1]
	self.m_level = self.m_skill_data.level
	self.m_skill_cost = t_params.skill_cost or 0
	self.backCallFunc = t_params.backCallFunc
	self.check_card_id = t_params .check_card_id 
	self.m_cost_id = t_params.cost_id or 2
 	if self.m_level < self.m_skill_data.max_level then
		self.m_cost = self.cost[self.m_level + 1]
	else
		self.m_cost = self.cost[self.m_level]
	end
end


function ui_talent_skill_pop:create(t_params)
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
end

return ui_talent_skill_pop