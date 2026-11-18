--公会招募
local game_guild_choose_employ_pop = {
	m_tGameData = nil,
	m_root_layer = nil,
	m_close_btn = nil,
	own_tab_node = nil,
	other_tab_node = nil,
	my_mercenary_count = nil, --自己的数量
	m_guild_teamData = nil, --自己派出的佣兵
	m_guild_other_teamData = nil,--借来的阵容
	sel_cards_data = nil,--选中的卡牌的数据
	temp_teamData = nil,--设置阵型用的
	team_index = nil,--阵型里面的序号
	m_openType = nil,
	employedTab = nil,
	m_bossId = nil,
}
function game_guild_choose_employ_pop.destroy( self )
	self.m_tGameData = nil;
	self.m_root_layer = nil;
	self.m_close_btn = nil;
	self.own_tab_node = nil;
	self.other_tab_node = nil;
	self.my_mercenary_count = nil;
	self.m_guild_teamData = nil; --自己的阵容
	self.m_guild_other_teamData = nil; --借来的阵容
	self.sel_cards_data = nil; --选中的卡牌的数据
	self.temp_teamData = nil;
	self.team_index = nil;--阵型里面的序号
	self.m_openType = nil;
	self.employedTab = nil;
	self.m_bossId = nil;
	cclog("--------game_guild_choose_employ_pop.destory-------")
end
function game_guild_choose_employ_pop.back( self )
	game_scene:removePopByName("game_guild_choose_employ_pop");
    self:destroy();
end
local formationPosTab = {{key="position_a",x=0.82,y=0.83},{key="position_b",x=0.82,y=0.5},{key="position_c",x=0.82,y=0.17},{key="position_d",x=0.5,y=0.83},{key="position_e",x=0.5,y=0.5},{key="position_f",x=0.5,y=0.17}};

function game_guild_choose_employ_pop.createUi( self )
	local ccbNode = luaCCBNode:create()
	local function onMainBtnClick( target,event )
		local ccbNode = tolua.cast(target,"CCNode")
		local btnTag = ccbNode:getTag()
		cclog2(btnTag,"btnTag === ")
		if btnTag == 1 then 
			if self.m_openType and self.m_openType == "formAdjustion" then
			    local count = 0
			    for k,v in pairs(self.sel_cards_data) do
			    	count = count + 1
			    end
			    if self.sel_cards_data and count > 0 then
			    	game_data:setGuildSelTeamData(self.sel_cards_data)
			    	game_scene:enterGameUi("game_guild_adjustment_formation",{gameData = nil,openType="game_guild_adjustment_formation",changeFlag = true});
					self:back()
				else
					game_util:addMoveTips({text="Chọn hero ra trận!"})
			    end
			else
				self:back()
			end
		elseif btnTag == 12 or btnTag == 11 then
		    -- cclog2(self.sel_cards_data,"self.sel_cards_data===")
		    local count = 0
		    for k,v in pairs(self.sel_cards_data) do
		    	count = count + 1
		    end
		    if self.sel_cards_data and count > 0 then
		    	game_data:setGuildSelTeamData(self.sel_cards_data)
		    	game_scene:enterGameUi("game_guild_adjustment_formation",{gameData = nil,openType="game_guild_adjustment_formation",changeFlag = true,bossId = self.m_bossId});
				self:back()
			else
				game_util:addMoveTips({text="Chọn hero ra trận!"})
		    end
		end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
	ccbNode:openCCBFile("ccb/ui_guild_buzhen_pop.ccbi")
	self.m_root_layer = ccbNode:layerForName('m_root_layer')
	self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
	self.own_tab_node = ccbNode:nodeForName("own_tab_node")
	self.other_tab_node = ccbNode:nodeForName("other_tab_node")
	self.my_mercenary_count = ccbNode:labelTTFForName("my_mercenary_count")
	self.other_mercenary_count = ccbNode:labelTTFForName("other_mercenary_count")
	local go_battle = ccbNode:controlButtonForName("go_battle")
	go_battle:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
	local left_btn = ccbNode:controlButtonForName("left_btn")
	left_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
	self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    self.my_mercenary_count:setString("0/5")
	self.other_mercenary_count:setString("0/3")
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

function game_guild_choose_employ_pop.addHeroMaterial( self )
	
end
--[[
    刷新
]]
function game_guild_choose_employ_pop.refreshTableView(self)
   self.own_tab_node:removeAllChildrenWithCleanup(true)
   local tempRewardTable = self:createTabelView(self.own_tab_node:getContentSize());
   self.own_tab_node:addChild(tempRewardTable,10,10)

   self.other_tab_node:removeAllChildrenWithCleanup(true)
   local tempRewardTable2 = self:createOthersTableView(self.other_tab_node:getContentSize());
   self.other_tab_node:addChild(tempRewardTable2,10,10)
end

--[[
    创建列表  自己的人
]]
function game_guild_choose_employ_pop.createTabelView(self,viewSize)
	local typeTable = {"default","quality","lv","profession"}
    game_data:cardsSortByTypeName3(typeTable[1]);
	local my_uid = game_data:getUserStatusDataByKey("uid") or nil;
	local my_cards = {};
	if my_uid then
		if self.m_tGameData and self.m_tGameData[tostring(my_uid)] and self.m_tGameData[tostring(my_uid)]["cards"] then
			my_cards = self.m_tGameData[tostring(my_uid)]["cards"];
		end
	end

	local cardsCount = game_data:getTeamCount();
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 2; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = cardsCount
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create() 
            -- ccbNode:registerFunctionWithFuncName("onBtnClick",onBtnClick);
            ccbNode:openCCBFile("ccb/ui_guild_buzhen_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width+3,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local head_node = ccbNode:nodeForName("head_node")
            local select_sprite = ccbNode:spriteForName("select_sprite")
            select_sprite:setScale(1.5)
            head_node:removeAllChildrenWithCleanup(true)
            local m_lv_lab = ccbNode:labelTTFForName("m_lv");
            if index < cardsCount then
            	local itemData,_ = game_data:getCardDataByIndex(index+1);
            	local level = "Lv."..itemData.lv
            	m_lv_lab:setString(level)
        		local itemId = self:lua_string_split(itemData.id) or "4800"
        		local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(itemId);
	            local itemName = itemConfig:getNodeWithKey("name"):toStr() or "" --材料卡名字
	            local tempIcon = game_util:createCardIconByCid(itemId,false)

	            if tempIcon then
	                local tempSize = head_node:getContentSize();
	                tempIcon:setScale(0.8)
	                tempIcon:setPosition(ccp(tempSize.width*0.5+1, tempSize.height*0.5+1))
	                head_node:addChild(tempIcon)
                end
                local curTab = game_data:getGuildGuildCurTeam()
                cclog2(self.m_guild_teamData,"m_guild_teamDatacreateTabelView ===")
                for k,v in pairs(curTab) do
                	if v == itemData.id then
                		select_sprite:setVisible(true)
                		-- table.insert(self.m_guild_teamData,itemData.id)	
                		self.sel_cards_data[tostring(itemData.id)] = itemData;
                		self.temp_teamData[tostring(itemData.id)] = self.team_index
                		self.team_index = self.team_index + 1
                		break
                	else
                		select_sprite:setVisible(false)
                	end
                end
            end

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
	        local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
	        local select_sprite = ccbNode:spriteForName("select_sprite")
            local itemData,_ = game_data:getCardDataByIndex(index+1);
            local c_idTab = {};
            for k,v in pairs(self.m_guild_other_teamData) do
            	local itemId = self:lua_string_split(v)
            	table.insert(c_idTab,itemId)
            end
            local flag,k = game_util:idInTableById(itemData.id,self.m_guild_teamData);
            local flag2,k2 = game_util:idInTableById(itemData.c_id,c_idTab);
            if flag and k ~= nil then
            	select_sprite:setVisible(false)
            	table.remove(self.m_guild_teamData,k);
            	self.sel_cards_data[tostring(itemData.id)] = nil;
            	self.temp_teamData[tostring(itemData.id)] = nil
            elseif game_util:getTableLen(self.m_guild_teamData) > 4 then
            	game_util:addMoveTips({text = "Tối đa chọn 5 thẻ của mình"});
            elseif flag2 and k2 ~= nil then
            	game_util:addMoveTips({text = "Không thể chọn hero giống nhau!"});
            else
            	select_sprite:setVisible(true)
            	table.insert(self.m_guild_teamData,itemData.id)
            	self.sel_cards_data[tostring(itemData.id)] = itemData;
            	self.temp_teamData[tostring(itemData.id)] = self.team_index
            	self.team_index = self.team_index + 1
            end
            game_data:setGuildFormationData(self.temp_teamData)

            self.my_mercenary_count:setString(#self.m_guild_teamData .. "/5")
            game_data:setGuildTeamData2(self.m_guild_teamData,"game_guild_choose_employ_pop ==== ");     	  
        end
    end

    return TableViewHelper:create(params);
end
function game_guild_choose_employ_pop.getCallPrice( self,call_price )
	local thiscount,thisName = "",""
	local guild_employ_cfg = json.decode(getConfig(game_config_field.guild_employ):getFormatBuffer()) or {}
	for i=1,game_util:getTableLen(guild_employ_cfg) do
		if call_price <= guild_employ_cfg[tostring(i)]["call_price"] then
			local reward = guild_employ_cfg[tostring(i)]["employ_price"]
			local icon,name,count = game_util:getRewardByItemTable(reward[1])
			thiscount = count
			thisName = name
			break
		end
	end
	return thiscount,thisName
end
function game_guild_choose_employ_pop.createOthersTableView(self,viewSize)
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
		                if btnTag == 99999 then
				            game_util:addMoveTips({text = "Bạn đã thuê thẻ này rồi"});
	                	else
			                local itemData = alignment_tab[btnTag];
			                -- cclog2(itemData,"itemData ~~~~~~~~~~~~~")
			                local parentNode = tagNode:getParent();
			                local select_sp = parentNode:getChildByTag(btnTag+10);
			                local c_idTab = {};
			                -- cclog2(self.m_guild_teamData,"self.m_guild_teamData ~~~~~~~~~~~~~~")
			                -- cclog2(self.m_guild_other_teamData,"self.m_guild_other_teamData ~~~~~~~~~~")
			                for k,v in pairs(self.m_guild_teamData) do
			                	local itemId = self:lua_string_split(v)
			                	table.insert(c_idTab,itemId)
			                end
			                local c_idTab2 = {};
			                for k,v in pairs(self.m_guild_other_teamData) do
			                	local itemId = self:lua_string_split(v)
			                	table.insert(c_idTab2,itemId)
			                end
			                -- cclog2(c_idTab,"c_idTab~~~~~~~~~~~")
			                -- cclog2(c_idTab2,"c_idTab2~~~~~~~~~~~~")
			                local  flag2,k2 = game_util:idInTableById(itemData.c_id,c_idTab2);
			                local flag,k = game_util:idInTableById(itemData.c_id,c_idTab);
				            -- if flag and k ~= nil then
				            -- 	game_util:addMoveTips({text = "不能选择相同的英雄！"});
				            -- else
				            	local flag1,k1 = game_util:idInTableById(itemData.id,self.m_guild_other_teamData);
				            	if flag1 and k1 ~= nil then
					            	select_sp:setVisible(false)
					            	table.remove(self.m_guild_other_teamData,k1);
					            	self.sel_cards_data[tostring(itemData.id)] = nil;
					            	self.temp_teamData[tostring(itemData.id)] = nil;
					            elseif flag and k ~= nil then
				            		game_util:addMoveTips({text = "Không thể chọn hero giống nhau!"});
					            elseif flag2 and k2 ~= nil then
				            	game_util:addMoveTips({text = "Không thể chọn hero giống nhau!"});
				            	elseif game_util:getTableLen(self.m_guild_other_teamData) > 2 then
					            	game_util:addMoveTips({text = "Tối đa thuê 3 thẻ"});
					            else
					            	select_sp:setVisible(true)
					            	table.insert(self.m_guild_other_teamData,itemData.id)
					            	self.sel_cards_data[tostring(itemData.id)] = itemData;
					            	self.temp_teamData[tostring(itemData.id)] = self.team_index
					            	self.team_index = self.team_index + 1
					            end
					            game_data:setGuildOtherTeamData(self.m_guild_other_teamData)
	            				self.other_mercenary_count:setString(#self.m_guild_other_teamData .. "/3")
				            	game_data:setGuildFormationData(self.temp_teamData)
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
		                        local isem = self:isEmployed(itemData.uid,itemData.id)
		                        local select_sp = CCSprite:createWithSpriteFrameName("guild_employ_gou.png");
				                select_sp:setPosition(ccp(dx + (i-1)*dw - 5,20))
				                select_sp:setScale(1.5)
				                hero_node:addChild(select_sp, 10);
				                select_sp:setTag(i+10);
				                select_sp:setVisible(false);
			                	local flag,k = game_util:idInTableById(itemData.id,self.m_guild_other_teamData);
			                	if flag and k ~= nil then
			    	            	select_sp:setVisible(true)
			    	            	self.sel_cards_data[tostring(itemData.id)] = itemData;
			    	            	self.temp_teamData[tostring(itemData.id)] = self.team_index
			    	            	self.team_index = self.team_index + 1
			    	            else
			    	            end
		                        local combat = math.floor(itemData.combat) 
		                        local combatlab = game_util:createLabelTTF({text = combat,color = ccc3(255,255,255),fontSize = 10});
		                        headIconSpr:addChild(combatlab)
		                        combatlab:setAnchorPoint(ccp(0.5,0.5))
		                        combatlab:setPosition(ccp(20,52))
		                        local lv = "Lv."..itemData.lv
		                        local lvlab = game_util:createLabelBMFont({text = lv,color = ccc3(255,255,255),fontSize = 10});
		                        headIconSpr:addChild(lvlab)
		                        lvlab:setAnchorPoint(ccp(0.5,0.5))
		                        lvlab:setPosition(ccp(20,7))
		                        local call_price = heroCfg:getNodeWithKey("call_price"):toInt() 
		                        local count,name = self:getCallPrice(call_price)
		                        local combatlab_cost = game_util:createLabelTTF({text = name.. "x" ..count ,color = ccc3(255,255,255),fontSize = 8});
		                        combatlab_cost:setPosition(ccp(dx + (i-1)*dw - 5,0))
		                        hero_node:addChild(combatlab_cost)
		                        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
		                        button:setOpacity(0)
		                        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
		                        button:setAnchorPoint(ccp(0.5,0.5))
		                        button:setPosition(ccp(dx + (i-1)*dw - 5,20))
		                        hero_node:addChild(button);
		                        if isem then
		                        	headIconSpr:setColor(ccc3(120,120,120))
		                        	button:setTag(99999)
		                        else
		                        	headIconSpr:setColor(ccc3(255,255,255))

		                        	button:setTag(i)
		                        end
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
function game_guild_choose_employ_pop.isEmployed( self,uid,id )
	if self.employedTab[tostring(uid)] then
		for k,v in pairs(self.employedTab[tostring(uid)]) do
			if tostring(v) == tostring(id) then
				return true
			end
		end
	end
	return false
	-- body
end
function game_guild_choose_employ_pop.check_id( self,teamData,id )
	-- body
	if teamData then
		
		for i,v in ipairs(teamData) do
			if tostring(v) == tostring(id) then
				return true
			end
		end
	end
	return false
end

--截取cid
function game_guild_choose_employ_pop.lua_string_split(self,str)
    local sub_str_tab = {};
    for mu_id in string.gmatch(str, "(%d+)-*") do
        table.insert(sub_str_tab, mu_id)
    end
    return sub_str_tab[1];
end

function game_guild_choose_employ_pop.refreshUi( self )
	self.other_mercenary_count:setString(#self.m_guild_other_teamData .. "/3")
	self.my_mercenary_count:setString(#self.m_guild_teamData .. "/5")  
	self:refreshTableView();
	local count = 0;


end

function game_guild_choose_employ_pop.init( self,t_params )
	t_params = t_params or {}
	self.m_bossId = t_params.bossId or 1
	cclog2(t_params.bossId,"id ----- ")
	self.m_openType = t_params.openType or nil
	self.m_guild_teamData = game_data:getGuildTeamData2() or {};
	self.m_guild_other_teamData = game_data:getGuildOtherTeamData() or {};
	self.m_tGameData = {};
	self.sel_cards_data = {};
	self.temp_teamData = {};
	self.employedTab = game_data:getUserStatusDataByKey("employed") or {}
	self.team_index = 0
	if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
		local data = t_params.gameData:getNodeWithKey("data")
		self.m_tGameData = json.decode(data:getNodeWithKey("guild_employ"):getFormatBuffer()) or {};
		game_data:setGuildTableCardsData(self.m_tGameData);
	end

end

function game_guild_choose_employ_pop.create( self,t_params )
	self:init(t_params)
	local scene = CCScene:create()
	-- local function wrapSceneWithTransition(scene,CCTRANSITIONMOVEINL)
 --        print("lua voiceStart -------------------------")
 --        local voiceResult = table.voiceResult
 --        CCLuaLog(voiceResult)
 --        self.m_editNode:setText(voiceResult);
 --    end

    -- require("shared.display").replaceScene(scene, CCTRANSITIONMOVEINL)
 scene:addChild(self:createUi())
	
	self:refreshUi()
	return scene
	-- body
end
return game_guild_choose_employ_pop;	