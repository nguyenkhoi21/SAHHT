--公会招募
local game_guild_employ_pop = {
	m_tGameData = nil,
	m_root_layer = nil,
	m_close_btn = nil,
	own_tab_node = nil,
	other_tab_node = nil,
	my_mercenary_count = nil, --自己的数量
	m_guild_teamData = nil, --自己派出的佣兵
}
function game_guild_employ_pop.destroy( self )
	self.m_tGameData = nil;
	self.m_root_layer = nil;
	self.m_close_btn = nil;
	self.own_tab_node = nil;
	self.other_tab_node = nil;
	self.my_mercenary_count = nil;
	self.m_guild_teamData = nil;
	cclog("--------game_guild_employ_pop.destory-------")
end
function game_guild_employ_pop.back( self )
	local temp = {}
	game_data:setGuildTeamData({})
    game_data:setGuildSelTeamId(temp);
	game_scene:removePopByName("game_guild_employ_pop");
    self:destroy();
end
function game_guild_employ_pop.createUi( self )
	local ccbNode = luaCCBNode:create()
	local function onMainBtnClick( target,event )
		local ccbNode = tolua.cast(target,"CCNode")
		local btnTag = ccbNode:getTag()
		if btnTag == 1 then 
			self:back()
		elseif btnTag == 33 then
		end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_guild_bingying_pop.ccbi")
	self.m_root_layer = ccbNode:layerForName('m_root_layer')
	self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
	self.own_tab_node = ccbNode:nodeForName("own_tab_node")
	self.other_tab_node = ccbNode:nodeForName("other_tab_node")
	self.my_mercenary_count = ccbNode:labelTTFForName("my_mercenary_count")
	local count = 0;
	if self.m_guild_teamData then
		count = #self.m_guild_teamData or 0;
	end
	
	self.my_mercenary_count:setString(count.."/5")
	self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)

	local function onTouch(eventType, x, y)
	    if eventType == "began" then
	        return true;
	    elseif eventType == "ended" then
	    end
	end
	self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true)
	self.m_root_layer:setTouchEnabled(true);
	return ccbNode
	-- body
end

function game_guild_employ_pop.addHeroMaterial( self )
	
end
--[[
    刷新
]]
function game_guild_employ_pop.refreshTableView(self)
   self.own_tab_node:removeAllChildrenWithCleanup(true)
   local tempRewardTable = self:createTabelView(self.own_tab_node:getContentSize());
   self.own_tab_node:addChild(tempRewardTable,10,10)

   self.other_tab_node:removeAllChildrenWithCleanup(true)
   local tempRewardTable2 = self:createOthersTableView(self.other_tab_node:getContentSize());
   self.other_tab_node:addChild(tempRewardTable2,10,10)
end

--[[
    创建列表
]]
function game_guild_employ_pop.createTabelView(self,viewSize)

	local my_uid = game_data:getUserStatusDataByKey("uid") or nil;
	local my_cards = {};
	if my_uid then
		if self.m_tGameData and self.m_tGameData[tostring(my_uid)] and self.m_tGameData[tostring(my_uid)]["cards"] then
			my_cards = self.m_tGameData[tostring(my_uid)]["cards"];
			local temp = {}
			for k,v in pairs(my_cards) do
				table.insert(temp,k)
			end
			-- cclog2(temp,"temp=====")
			game_data:setGuildTeamData(temp,"game_guild_employ_pop === 1111");
		end
	end

	local function onBtnClick( target,event )
		-- body
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("press button tag is ", btnTag)
        if self.m_guild_teamData and self.m_guild_teamData[tonumber(btnTag)-10] then
        	local params = {};
        	params.card_id = self.m_guild_teamData[tonumber(btnTag)-10] 
        	local function responseMethod( tag,gameData )
        		local data = gameData:getNodeWithKey("data")
				self.m_tGameData = json.decode(data:getNodeWithKey("guild_employ"):getFormatBuffer()) or {};
		
				table.remove(self.m_guild_teamData,tonumber(btnTag)-10)
				local reward  = data:getNodeWithKey("reward")
				game_util:rewardTipsByJsonData(reward)
				game_data:setGuildTeamData(self.m_guild_teamData,"game_guild_employ_pop === 222");
            	self:refreshUi();
			end
			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_retreat_card"), http_request_method.GET,params,"association_retreat_card")
	          
        end
	end
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = 5
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create() 
            ccbNode:registerFunctionWithFuncName("onBtnClick",onBtnClick);
            ccbNode:openCCBFile("ccb/ui_guild_bingying_item2.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local head_node = ccbNode:nodeForName("head_node")
            local weichuzhan_node = ccbNode:nodeForName("weichuzhan_node")
            local chuzhan_node = ccbNode:nodeForName("chuzhan_node")
            local cool_down_btn = ccbNode:controlButtonForName("cool_down_btn");
            local time_node = ccbNode:nodeForName("time_node")
            local m_income = ccbNode:labelTTFForName("m_income")

            local server_time = game_data:getUserStatusDataByKey("server_time")

        	cool_down_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
        	cool_down_btn:setTag(11+index)
            head_node:removeAllChildrenWithCleanup(true)
            local spKuang = CCScale9Sprite:createWithSpriteFrameName("public_chengkuang.png");
            local m_lv_lab = ccbNode:labelTTFForName("m_lv");
            spKuang:setAnchorPoint(ccp(0,0))
            spKuang:setScale(0.7)
            head_node:addChild(spKuang);
            chuzhan_node:setVisible(false);
            weichuzhan_node:setVisible(true);
            if #self.m_guild_teamData > 0 and #self.m_guild_teamData > index then
            	chuzhan_node:setVisible(true);
            	weichuzhan_node:setVisible(false);
            	if #self.m_guild_teamData > 0 then
            		local card_id = self.m_guild_teamData[index+1]
            		local itemId = self:lua_string_split(card_id) or "4800"
            		local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(itemId);
		            local itemName = itemConfig:getNodeWithKey("name"):toStr() or "" --材料卡名字
		            local tempIcon = game_util:createCardIconByCid(itemId,false)
		            if tempIcon then
		                local tempSize = head_node:getContentSize();
		                tempIcon:setScale(0.7)
		                tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
		                head_node:addChild(tempIcon)
	                end
	                -- local income = my_cards[tostring(card_id)]["income"] or {};
					local dispatch_time = my_cards[tostring(card_id)]["dispatch_time"]or 0;
					local time = server_time - dispatch_time
					local curDate = game_util:formatTime(time)
					local timelab = game_util:createLabelTTF({text = curDate,color = ccc3(255,255,255),fontSize = 9});
                    timelab:setPosition(ccp(15,0))
                    if time_node:getChildByTag(13) then
                    	time_node:removeChildByTag(13,true)
                    end
                    time_node:addChild(timelab,13,13)
                   	
	                local m_lv = my_cards[tostring(card_id)]["lv"]or 0;
	                m_lv_lab:setString("Lv."..m_lv);

	                if my_cards[tostring(card_id)]["income"] and next(my_cards[tostring(card_id)]["income"]) then
	                	local icon,name,count = game_util:getRewardByItemTable( my_cards[tostring(card_id)]["income"])
	                	if icon then
	                		local incomeLab = name .. "x" .. count or ""
            				m_income:setString(incomeLab)
            			else
            				m_income:setString("Chưa có")
            			end
	                else
	                	m_income:setString("Chưa có")
	                end
            	end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            if self.m_guild_teamData and self.m_guild_teamData[index+1] then
            	local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");

            else
            	local btnCallFunc = function( target,event )
            
	            end
	            local itemOnClick = function (typeName,id)
	                if typeName == "unload" then
	                elseif typeName == "exchanged" then
	                	local flag = self:check_id(id)
	                	if flag == false then
	                		local params = {};
	                		params.card_id = id
	                		local function responseMethod( tag,gameData )
	                			local data = gameData:getNodeWithKey("data")
								self.m_tGameData = json.decode(data:getNodeWithKey("guild_employ"):getFormatBuffer()) or {};
		
								table.insert(self.m_guild_teamData,id)

								game_data:setGuildTeamData(self.m_guild_teamData,"game_guild_employ_pop === 333");     	
			                	self:refreshUi();
							end
							network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_dispatch_card"), http_request_method.GET,params,"association_dispatch_card")
	                	end
	                end
	            end
	            local cardsData = game_data:getTableCardsData()
	            game_scene:addPop("game_hero_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,openType = 8})
            end
                  
        end
    end
    return TableViewHelper:create(params);
end

function game_guild_employ_pop.createOthersTableView(self,viewSize)
	local all_data_tab = {} --有uid
	local other_data_tab = {}; --没有uid
	local my_uid = game_data:getUserStatusDataByKey("uid") or nil;
	all_data_tab = self.m_tGameData
    if all_data_tab then
    	for k,v in pairs(all_data_tab) do
    		if k == my_uid then
    		else
    			table.insert(other_data_tab,v)
    		end
    	end
    end
    -- cclog2(other_data_tab,"other_data_tab===")
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #other_data_tab ;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-10;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_guild_bingying_item.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5 - 10));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local player_name = ccbNode:labelTTFForName("player_name")
            local heroIcon = ccbNode:nodeForName("heroIcon")
            local lv_lab = ccbNode:labelTTFForName("lv_lab")
            local hero_node = ccbNode:nodeForName("enemy_info_node")
            local role = 1;
            local my_lv = 100;
            local p_name = "宝宝";
            if other_data_tab and other_data_tab[tonumber(index+1)] and other_data_tab[tonumber(index+1)]["info"] then
            	local info_Data = other_data_tab[tonumber(index+1)]
            	role = info_Data["info"]["role"];
            	my_lv = "Lv." .. info_Data["info"]["level"];
            	p_name = info_Data["info"]["name"];
            end
            lv_lab:setString(my_lv)
            player_name:setString(p_name)
            local icon = game_util:createPlayerIconByRoleId(tostring(role));
            if icon then
                heroIcon:removeAllChildrenWithCleanup(true);
                icon:setAnchorPoint(ccp(0,0))
                icon:setPosition(ccp(0,3))
                icon:setScale(0.7)
                heroIcon:addChild(icon);
            else
                cclog("tempFrontUser.role " .. role .. " not found !")
            end
            if other_data_tab and other_data_tab[index+1] and other_data_tab[index+1]["cards"] then
			    local cards_data = other_data_tab[index+1]["cards"]
			    local alignment_tab = {};
			    for k,v in pairs(cards_data) do
			    	table.insert(alignment_tab,v)
		            local function onBtnCilck( event,target )
		                local tagNode = tolua.cast(target, "CCNode");
		                local btnTag = tagNode:getTag();
		                local itemData = alignment_tab[btnTag];
		                if itemData then
		                    game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 3})
		                end
		            end
		            local character_detail_cfg = getConfig("character_detail");
		            local nodeSize = hero_node:getContentSize()
		            local dw = nodeSize.width / #alignment_tab
		            local dx = dw / 2
		            hero_node:removeAllChildrenWithCleanup(true)
		            for i=1,math.min(5,#alignment_tab) do

		                itemData = alignment_tab[i];
		                heroCfg = character_detail_cfg:getNodeWithKey(itemData.c_id);
		                if itemData and heroCfg then
		                    local headIconSpr = game_util:createCardIconByCfg(heroCfg,itemData);
		                    if headIconSpr then
		                        headIconSpr:setScale(0.7);
		                        headIconSpr:setPosition(ccp(dx + (i-1)*dw - 5,20));
		                        hero_node:addChild(headIconSpr,1,1);
		                        local combat = math.floor(itemData.combat) 
		                        local combatlab = game_util:createLabelTTF({text = combat,color = ccc3(255,255,255),fontSize = 10});
		                        headIconSpr:addChild(combatlab)
		                        combatlab:setAnchorPoint(ccp(0.5,0.5))
		                        combatlab:setPosition(ccp(20,52))
		                        local lv = "Lv."..itemData.lv
		                        local lvlab = game_util:createLabelBMFont({text = lv,color = ccc3(255,255,255),fontSize = 10});
		                        headIconSpr:addChild( lvlab)
		                        lvlab:setAnchorPoint(ccp(0.5,0.5))
		                        lvlab:setPosition(ccp(20,7))
		                        local call_price = heroCfg:getNodeWithKey("call_price"):toInt() 
		                        local count,name,icon = self:getCallPrice(call_price)
		                        if icon then
			                        local combatlab_cost = game_util:createLabelTTF({text = name ..  "x" ..count ,color = ccc3(255,255,255),fontSize = 8});
			                        combatlab_cost:setPosition(ccp(dx + (i-1)*dw - 5,0))
			                        hero_node:addChild(combatlab_cost)
			                    end
		                        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
		                        button:setTag(i)
		                        button:setOpacity(0)
		                        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
		                        button:setAnchorPoint(ccp(0.5,0.5))
		                        button:setPosition(ccp(dx + (i-1)*dw - 5,20))
		                        hero_node:addChild(button);

		                    end
		                end
		            end
			    end
			end
			
			
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));

        end
    end
    return TableViewHelper:create(params);
end
function game_guild_employ_pop.getCallPrice( self,call_price )
	local thiscount,thisName,thisIcon = "","",""
	local guild_employ_cfg = json.decode(getConfig(game_config_field.guild_employ):getFormatBuffer()) or {}
	for i=1,game_util:getTableLen(guild_employ_cfg) do
		if call_price <= guild_employ_cfg[tostring(i)]["call_price"] then
			local reward = guild_employ_cfg[tostring(i)]["employ_price"]
			local icon,name,count = game_util:getRewardByItemTable(reward[1])
			thiscount = count
			thisName = name
			thisIcon = icon
			break
		end
	end
	return thiscount,thisName,thisIcon
end
function game_guild_employ_pop.check_id( self,id )
	-- body
	if self.m_guild_teamData then
		
		for i,v in ipairs(self.m_guild_teamData) do
			if v == id then
				return true
			end
		end
	end
	return false
end

--截取cid
function game_guild_employ_pop.lua_string_split(self,str)
    local sub_str_tab = {};
    for mu_id in string.gmatch(str, "(%d+)-*") do
        table.insert(sub_str_tab, mu_id)
    end
    return sub_str_tab[1];
end

function game_guild_employ_pop.refreshUi( self )
	self:refreshTableView();
	local count = 0;
	if self.m_guild_teamData then
		count = #self.m_guild_teamData or 0;
	end
	self.my_mercenary_count:setString(count.."/5")
end

function game_guild_employ_pop.init( self,t_params )
	t_params = t_params or {}
	self.m_guild_teamData = {};
	self.m_tGameData = {};
	if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
		local data = t_params.gameData:getNodeWithKey("data")
		self.m_tGameData = json.decode(data:getNodeWithKey("guild_employ"):getFormatBuffer()) or {};
		local my_uid = game_data:getUserStatusDataByKey("uid") or nil;
		local my_cards = {};
		if my_uid then
			if self.m_tGameData and self.m_tGameData[tostring(my_uid)] and self.m_tGameData[tostring(my_uid)]["cards"] then
				my_cards = self.m_tGameData[tostring(my_uid)]["cards"];
				for k,v in pairs(my_cards) do
					table.insert(self.m_guild_teamData,k)
				end
			end
		end
	end	
end

function game_guild_employ_pop.create( self,t_params )
	self:init(t_params)
	local scene = CCScene:create()
	scene:addChild(self:createUi())
	self:refreshUi()
	return scene
	-- body
end
return game_guild_employ_pop;