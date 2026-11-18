
local game_nightmare_enemy_pop = {
	m_close_btn = nil,
	m_root_layer = nil,
	m_task_lab = nil,
	m_challenge_btn = nil,
	m_shaodang_btn = nil,
	m_info_node = nil,
	new_fight_forever_cfg = nil,
	new_fight_fight_cfg = nil,
    new_fight_enemy_cfg = nil,
	m_btn_tab = nil,
	m_adjustFlag = nil,
	m_select_index = nil,
	m_num_tab = nil,
	m_btn_pos_tab = nil,
    cid = nil,
    own_combat = nil,
    open_index = nil,
    openType = nil,
    m_des_lab = nil,
}
--[[--
    销毁ui
]]
function game_nightmare_enemy_pop.destroy(self)
	self.m_close_btn = nil;
	self.m_root_layer = nil;
	self.m_task_lab = nil;
	self.m_challenge_btn = nil;
	self.m_shaodang_btn = nil;
	self.m_info_node = nil;
	self.new_fight_forever_cfg = nil;
	self.new_fight_fight_cfg = nil;
    self.new_fight_enemy_cfg = nil;
	self.m_btn_tab = nil;
	self.m_adjustFlag = nil;
	self.m_select_index = nil;
	self.m_num_tab = nil;
	self.m_btn_pos_tab = nil;
    self.cid = nil;
    self.own_combat = nil;
    self.open_index = nil;
    self.openType = nil;
    self.m_des_lab = nil;
end

--[[--
    返回
]]
function game_nightmare_enemy_pop.back(self,type)
    game_scene:removePopByName("game_nightmare_enemy_pop")
end
--[[--
    读取ccbi创建ui
]]
function game_nightmare_enemy_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
        	self:back()
        elseif btnTag >= 101 and btnTag <= 103 then
            if self.m_adjustFlag == true then
                for i=1,3 do
                    self.m_btn_tab[i]:setTouchEnabled(false)
                end
                self:setbuttonAnim(self.m_select_index,btnTag-100)
            else
                self.m_select_index = btnTag-100
                self.m_adjustFlag = true
                for i=1,3 do
                    if self.m_select_index and i == self.m_select_index then
                    	local btnimg = CCSprite:createWithSpriteFrameName("Nightmare_zhen11.png")
                        game_util:setCCControlButtonBackground(self.m_btn_tab[i],"Nightmare_zhen" .. self.m_num_tab[i]+(self.m_num_tab[i]*10) ..".png")
                        self.m_btn_tab[i]:setPreferredSize(CCSizeMake(115/2,111/2))
                        self.m_btn_tab[i]:setTouchEnabled(false)
                    else
                        game_util:setCCControlButtonBackground(self.m_btn_tab[i],"Nightmare_zhen" .. self.m_num_tab[i] ..".png")
                        self.m_btn_tab[i]:setTouchEnabled(true)
                    end
                end
            end
        elseif btnTag == 104 then --挑战
            local function responseMethod( tag,gameData )
                local data = gameData:getNodeWithKey("data");
                data = json.decode(data:getFormatBuffer()) or {};
                local data2 = {}

                local alignment_info = data.battle_result.enemy_alignment_info
                local god_field_ids = data.battle_result.god_field_ids
                local tempTab = util.table_copy(god_field_ids)
                for i=1,3 do
                    god_field_ids[tostring(i)] = tempTab[tostring(self.m_num_tab[i])]
                end
                data2 = {alignment_info = alignment_info,god_field_ids = god_field_ids}
                game_data:setNightmareReward(data.rewards)
                if self.opentype == "expedition" then
                    game_scene:enterGameUi("game_godfield_battle_big",{gameData = data2,data1 = data.battle_result,opentype = "expedition",nightmareReward = data.rewards})
                else
                    game_scene:enterGameUi("game_godfield_battle_big",{gameData = data2,data1 = data.battle_result,opentype = "nightmare",nightmareReward = data.rewards})
                end
            end
            local params = {}
            params.chapter = self.open_index
            params.fast_fight = 0
            if self.opentype == "expedition" then
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("nightmare_tower_fight"), http_request_method.GET, params,"nightmare_tower_fight")
            else
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_fight_forever_fight"), http_request_method.GET, params,"new_fight_forever_fight")
            end
        elseif btnTag == 105 then --扫荡
            local function responseMethod( tag,gameData )
                game_scene:addPop("auto_battle_over_pop",{gameData = gameData})
            end
            local params = {}
            params.chapter = self.open_index
            params.fast_fight = 1
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_fight_forever_fight"), http_request_method.GET, params,"new_fight_forever_fight")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_nightmare_enemy_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_task_lab = ccbNode:labelTTFForName("m_task_lab");
    self.m_challenge_btn = ccbNode:controlButtonForName("m_challenge_btn");
    self.m_shaodang_btn = ccbNode:controlButtonForName("m_shaodang_btn");
    self.m_info_node = ccbNode:nodeForName("m_info_node");
   	self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_des_lab = ccbNode:labelTTFForName("m_des_lab")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    self.m_shaodang_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
    self.m_challenge_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
   	self.m_btn_tab = {}
   	local m_btn 
   	for i=1,3 do
   	    m_btn = ccbNode:controlButtonForName("m_teamNum_btn" .. i)
   	    m_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
   	    self.m_btn_tab[i] = m_btn
   	end
   	local function onTouch(eventType, x, y)
   	    if eventType == "began" then
   	        return true;--intercept event
   	    end
   	end
   	self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
   	self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[
    按钮移动
    index1 选中的按钮的index，index2 要交换的按钮的index
]]
function game_nightmare_enemy_pop.setbuttonAnim( self,index1,index2 )
    local function animEndCallFunc(  )
        for i=1,3 do
            self.m_btn_tab[i]:setTouchEnabled(true)
        end
        local function responseMethod( tag,gameData )
            self.m_adjustFlag = false
            self.m_select_index = nil
            self.m_btn_tab[index2]:setPosition(ccp(self.m_btn_pos_tab[index2].posX,self.m_btn_pos_tab[index2].posY))
            self.m_btn_tab[index1]:setPosition(ccp(self.m_btn_pos_tab[index1].posX,self.m_btn_pos_tab[index1].posY))
            self:refreshUi()
        end
        local temp1 = self.m_num_tab[self.m_select_index]
        local temp2 = self.m_num_tab[index2]
        self.m_num_tab[self.m_select_index] = temp2
        self.m_num_tab[index2] = temp1
        local params = {}
        params.formation = tostring(self.m_num_tab[1] .. "&formation=" .. self.m_num_tab[2] .. "&formation=" .. self.m_num_tab[3])
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_update_battle_order"), http_request_method.GET, params,"god_field_update_battle_order",true,true)
    end 
    local animArr = CCArray:create()
    local move1 = CCMoveTo:create(0.5,ccp(self.m_btn_pos_tab[index2].posX,self.m_btn_pos_tab[index2].posY)) --选中的按钮的
    local move2 = CCMoveTo:create(0.5,ccp(self.m_btn_pos_tab[index1].posX,self.m_btn_pos_tab[index1].posY)) --交换的按钮的
    animArr:addObject(move1)
    animArr:addObject(CCCallFunc:create(animEndCallFunc));
    self.m_btn_tab[index2]:runAction(move2)
    self.m_btn_tab[index1]:runAction(CCSequence:create(animArr));
end
function game_nightmare_enemy_pop.createButton( self,i,parentNode,cid,heroData,myccp ,scale)
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local cardData
        if cid then
            cardData = game_data:getCardDataById(cid[btnTag])
            if cardData then
                game_scene:addPop("game_hero_info_pop",{tGameData = cardData,openType = 3})
            end
        elseif heroData then
           if tolua.type(heroData) == "util_json" then
               heroData = json.decode(heroData:getFormatBuffer()) or {};
           end
           game_scene:addPop("game_hero_info_pop",{tGameData = heroData,openType = 3})
        end
    end
    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
    button:setAnchorPoint(myccp)

    button:setZoomOnTouchDown(false)
    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    button:setPosition(ccp(20,17));
    button:setOpacity(0)
    button:setScale(scale)
    button:setTag(i)
    parentNode:addChild(button,11);
end
--[[--
    创建自己阵容的第一个卡牌的头像
]]
function game_nightmare_enemy_pop.createHeroIcon(self,cid,parentNode,index)
    parentNode:removeAllChildrenWithCleanup(true)
    local nodeSize = parentNode:getContentSize()
    local itemId = nil;
    local cardData = nil;
    local itemIcon = nil;
    local headIconSpr = nil;
    local character_detail_cfg = getConfig("character_detail");
    local dw = nodeSize.height / 3
    local dx = dw / 2
    local cardData,heroCfg = game_data:getCardDataById(cid[index])
    if cardData and heroCfg then
        headIconSpr = game_util:createCardIconByCfg(heroCfg,cardData);
        if headIconSpr then
            headIconSpr:setScale(0.7);
            headIconSpr:setAnchorPoint(ccp(1,1));
            headIconSpr:setPosition(ccp(20,17));
            parentNode:addChild(headIconSpr,1,1);
            self:createButton(index,parentNode,cid,_,ccp(1,1),0.75)
        end
    end
end
--[[--
    获取敌人的id
]]
function game_nightmare_enemy_pop.getEnemyId( self,parentNode,i,m_comat_lab2)
    local fight_ID1 = self.new_fight_forever_cfg[tostring(self.open_index)].fight_ID
    local enemyIDTab1,enemyIDTab2,enemyIDTab3 = {},{},{}
    for i=1,15 do
       local enemyID = self.new_fight_fight_cfg[tostring(fight_ID1)]["position" .. i]
        if i<6 then
            table.insert(enemyIDTab1,enemyID)
        elseif i > 5 and i< 11 then
            table.insert(enemyIDTab2,enemyID)
        elseif i > 10 and i<16 then
            table.insert(enemyIDTab3,enemyID)
        end
    end
    local needTab 
    if i == 1 then
        needTab= enemyIDTab1 
    elseif i == 2 then
        needTab= enemyIDTab2 
    elseif i == 3 then
        needTab= enemyIDTab3 
    end

    local size = parentNode:getContentSize()
    local width = size.width/5
    local height = size.height
    local combat = 0
    for i=1,#needTab do
        local enemyData = self.new_fight_enemy_cfg:getNodeWithKey(tostring(needTab[i]))
        local headIconSpr = game_util:createCardIconByCfg(enemyData,enemyData);
        if headIconSpr then
            parentNode:addChild(headIconSpr,10)
            headIconSpr:setScale(0.70)
            headIconSpr:setAnchorPoint(ccp(1,1))
            headIconSpr:setPosition(ccp(width*(i-1)+37,height-4))
            self:createButton(i,headIconSpr,_,enemyData,ccp(0.4,0.4),1)
        end
        enemyData = json.decode(enemyData:getFormatBuffer())
        combat = enemyData.battle_point + combat
    end
    m_comat_lab2:setString(tostring(combat))
end
--[[--
    获取自己的cid
]]
function game_nightmare_enemy_pop.getCid(self)
    self.cid = {};
    local god_field_ids = self.m_tGameData.god_field_ids
    for i =1,3 do
        local tab = god_field_ids[tostring(i)]
        for k,v in pairs(tab) do
            local ling = tostring(0)
            local yi = tostring(-1)
            if v ~= ling and v ~= yi then
               --cclog2(i,"i === ")
                local x = v
                --cclog2(x,"xx= =x= =")
                self.cid[i] = x
                i = i+1
                break;
            end
        end
    end
end
--[[--
	创建列表
]]
function game_nightmare_enemy_pop.createTableView( self,viewSize )
	local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local team_index = btnTag
        local function responseMethod(tag,gameData)
            if gameData then
                if self.opentype == "expedition" then
                    game_scene:enterGameUi("game_god_adjustment",{gameData = gameData,openType="expedition",team_index = team_index});
                else
                    game_scene:enterGameUi("game_god_adjustment",{gameData = gameData,openType="nightmare",team_index = team_index});
                end
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_upload_god_formation"), http_request_method.GET, nil,"god_field_upload_god_formation",true,true)
		-- body
	end
	local totalItem = 3
	local params = {};
	params.viewSize = viewSize;
	params.row = 3;--行
	params.column = 1; --列
	params.totalItem = totalItem;
	params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
	params.direction = kCCScrollViewDirectionVertical
	local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row-30);
	params.newCell = function(tableView,index) 
	    local cell = tableView:dequeueCell()
	    if cell == nil then
	        cell = CCTableViewCell:new()
	        cell:autorelease()
	        local ccbNode = luaCCBNode:create();
    		ccbNode:registerFunctionWithFuncName("onBtnClick",onBtnClick);
	        ccbNode:openCCBFile("ccb/ui_nightmare_enemy_pop_info.ccbi")       
	        ccbNode:setPosition(ccp(itemSize.width*0,itemSize.height*0));
	        cell:addChild(ccbNode,10,10);
	    end
	    if cell then
	    	local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_own_node = ccbNode:nodeForName("m_own_node")
            local m_comat_lab1 = ccbNode:labelTTFForName("m_comat_lab1")
            local m_comat_lab2 = ccbNode:labelTTFForName("m_comat_lab2")
            local enemy_info_node = ccbNode:nodeForName("enemy_info_node")
            local m_formation_btn = ccbNode:controlButtonForName("m_formation_btn")
            m_formation_btn:setTag(tonumber(self.m_num_tab[index+1]))
            m_formation_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
            m_comat_lab1:setString(self.own_combat[tonumber(self.m_num_tab[index+1])]) 
            self:getCid()
            self:createHeroIcon(self.cid,m_own_node,tonumber(self.m_num_tab[index+1]))
            self:getEnemyId(enemy_info_node,index+1,m_comat_lab2)
	    end
	    return cell;
	end
	return TableViewHelper:create(params);
end
--[[--
    刷新label
]]
function game_nightmare_enemy_pop.refreshLabel( self )

end
--[[--
    刷新ui
]]
function game_nightmare_enemy_pop.refreshUi(self)
    self.own_combat = {self.m_tGameData.god_combat_1,self.m_tGameData.god_combat_2,self.m_tGameData.god_combat_3}

	self.m_info_node:removeAllChildrenWithCleanup(true)
	local viewSize = self.m_info_node:getContentSize()

	self.m_info_node:addChild(self:createTableView(viewSize)) 
	for i=1,3 do
	    local posX,posY = self.m_btn_tab[i]:getPosition()
	    self.m_btn_pos_tab[i] = {posX = posX,posY = posY}
	    local btnimg = CCSprite:createWithSpriteFrameName("Nightmare_zhen1.png")
	    game_util:setCCControlButtonBackground(self.m_btn_tab[i],"Nightmare_zhen" .. self.m_num_tab[i] ..".png")
	    self.m_btn_tab[i]:setPreferredSize(CCSizeMake(97/2,85/2))
	end
    if self.opentype == "expedition" then
        self.m_des_lab:setVisible(false)
        self.m_task_lab:setVisible(false)
    else
    	local des = ""
    	des = self.new_fight_forever_cfg[tostring(self.open_index)].target_des
    	self.m_task_lab:setString(des)
    end
end

--[[--
    初始化
]]
function game_nightmare_enemy_pop.init(self,t_params)
    t_params = t_params or {};
    self.opentype = t_params.openType or nil
    self.m_btn_pos_tab = {}
    self.cid = {}
    self.own_combat = {}
    self.open_index = 0
    self.open_index = t_params.index
    self.m_adjustFlag = false
    self.m_select_index = 0
    self.m_num_tab = {1,2,3}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        self.m_num_tab = self.m_tGameData.formation_battle_order
    end
    if self.opentype == "expedition" then
        self.new_fight_forever_cfg = json.decode(getConfig(game_config_field.fight_weak):getFormatBuffer())
        self.new_fight_enemy_cfg = getConfig(game_config_field.nightmare_enemy)
        self.new_fight_fight_cfg = json.decode(getConfig(game_config_field.fight_position):getFormatBuffer())
    else
        self.new_fight_forever_cfg = json.decode(getConfig(game_config_field.new_fight_forever):getFormatBuffer())
        self.new_fight_enemy_cfg = getConfig(game_config_field.new_fight_enemy)
        self.new_fight_fight_cfg = json.decode(getConfig(game_config_field.new_fight_fight):getFormatBuffer())
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_nightmare_enemy_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end
return game_nightmare_enemy_pop;