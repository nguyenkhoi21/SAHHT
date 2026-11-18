
local game_server_guildbattle_point_pop = {
    m_root_layer = nil,
    node_tableView = nil,
    m_tGameData = nil,
    building_id = nil, --唯一id h1-1 || 1
    m_select_index = nil,
    m_isOnly = nil,
    m_ower_building = nil,
    m_isEnemy = nil,
    m_isManage = nil,
    m_step= nil,
    btn_tiren = nil,
    node_num = nil,
    building_cid = nil, --显示用的id  1，2，3，4，5
    btn_lookself = nil,-- 查看自己的阵容
    m_reward=nil,

};
--[[--
    销毁
]]
function game_server_guildbattle_point_pop.destroy(self)
    -- body
    cclog("-----------------game_server_guildbattle_point_pop destroy-----------------");
    self.m_root_layer = nil;
    self.node_tableView = nil;
    self.m_tGameData = nil;
    self.building_id = nil;
    self.m_select_index = nil;
    self.m_isOnly = nil;
    self.m_ower_building = nil;
    self.m_isManage = nil;
    self.m_isEnemy = nil;
    self.m_step = nil;
    self.btn_tiren = nil;
    self.node_num = nil;
    self.building_cid = nil;
    self.btn_lookself = nil;
    self.m_reward=nil;

end
--[[--
    返回
]]
function game_server_guildbattle_point_pop.back(self,toBattle)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    local params = {}
    local function responseMethod( tag,gameData )
        local data = gameData:getNodeWithKey("data")
        local step = data:getNodeWithKey("step"):toInt()
        if step == 100 then
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_server_guildbattle_toBattle",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_new_ui_index"), http_request_method.GET, nil,"new_guild_fight_new_ui_index")
        else
            game_scene:enterGameUi("game_server_guildbattle_battle",{gameData = gameData, isManage = self.m_isManage, toBattle = toBattle,openType = "index",reward=self.m_reward})
        end
        game_scene:removePopByName("game_server_guildbattle_point_pop");
        
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_battlefield_overview"), http_request_method.GET, params,"new_guild_fight_battlefield_overview")

end
--[[--
    读取ccbi创建ui
]]
function game_server_guildbattle_point_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 5 then --挑战
            if self.m_select_index == 0 then
                game_util:addMoveTips({text = "请先选择派遣阵容"})
            elseif self.building_id == 0 then
                game_util:addMoveTips({text = "选择地块错误"})
            elseif self.m_tGameData.owner_building and self.m_tGameData.owner_building[tostring(self.m_select_index)] then
                game_util:addMoveTips({text = "该阵容已被派遣"})
            else
                local function responseMethod( tag,gameData )
                    if gameData  then
                        local data = gameData:getNodeWithKey("data")
                        local has_battle = data:getNodeWithKey("has_battle"):toBool()
                        if has_battle then
                            game_data:setBattleType("serverGuildBattle");
                            game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                        else
                            game_util:addMoveTips({text = "恭喜您成功占领据点"})
                            local reward=json.decode(data:getNodeWithKey("reward"):getFormatBuffer());
                            self.m_reward=reward;
                            self:back(true)
                        end
                    end
                    -- game_scene:addPop("game_server_guildbattle_point_pop",{gameData = gameData}) 
                end
                local  params = {}
                params.building_id = self.building_id
                params.formation_id = self.m_select_index
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_battle"), http_request_method.GET, params,"new_guild_fight_battle")
            end
        elseif btnTag == 6 then --踢人按钮
            local params = {}
            params.only_one = 0 
            params.building_id = self.building_id
            local function responseMethod( tag,gameData )
                if gameData and tolua.type(gameData) == "util_json" then
                    local data = gameData:getNodeWithKey("data")
                    data = json.decode(data:getFormatBuffer())
                    self.m_tGameData = data
                    self.btn_tiren:setVisible(false)
                    self.node_tableView:removeAllChildrenWithCleanup(true)
                    local viewSize = self.node_tableView:getContentSize()
                    self.node_tableView:addChild(self:createTableView(viewSize),10,10)
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_building_info"), http_request_method.GET, params,"new_guild_fight_building_info")

        elseif btnTag == 7 then --查看自己的阵容
            local params = {}
            -- params.only_one = 1 
            -- params.building_id = self.building_id
            local function responseMethod( tag,gameData )
                local data = gameData:getNodeWithKey("data")
                data = json.decode(data:getFormatBuffer())
                self.m_tGameData = data
                -- self.btn_tiren:setVisible(false)
                if self.m_tGameData.owner_building then
                    self.m_ower_building = self.m_tGameData.owner_building
                end
                self.node_tableView:removeAllChildrenWithCleanup(true)
                local viewSize = self.node_tableView:getContentSize()
                self:createFormationList(self.node_tableView)
                -- game_scene:addPop("game_server_guildbattle_point_pop",{gameData = gameData, building_id = building_id, isOnly = isOnly, isManage = self.m_isManage, step = canGo, c_id = cid }) 
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_formation_info"), http_request_method.GET, nil,"new_guild_fight_formation_info")
        elseif btnTag == 11 or btnTag == 12 or btnTag == 13 then--
         
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_serverGuild_point_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    self.node_tableView = ccbNode:nodeForName("node_tableView")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
    
    local btn_attack = ccbNode:controlButtonForName("btn_attack")
    btn_attack:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
    btn_attack:setVisible(false)
    self.btn_tiren = ccbNode:controlButtonForName("btn_tiren")
    self.btn_tiren:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
    self.btn_tiren:setVisible(false)

    self.btn_lookself = ccbNode:controlButtonForName("btn_lookself")
    self.btn_lookself:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
    self.btn_lookself:setVisible(false)

    self.node_num = ccbNode:nodeForName("node_num")
    self.node_num:setVisible(false)
    -- if self.isOnly then
    --     btn_attack:setVisible(true)
    -- else
    --     btn_attack:setVisible(false)
    -- end
  
    if self.m_isEnemy then
        btn_attack:setVisible(true)
        self.btn_tiren:setVisible(false)
        self.btn_lookself:setVisible(false)
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-4,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[
    设置图片数字
]]
function game_server_guildbattle_point_pop.createNumIcon(self,num,node)
    node:removeAllChildrenWithCleanup(true);
    if num >= 10 and num < 100 then
        local high = math.floor(num / 10)
        local low = math.floor(num % 10)

        local num_1 = CCSprite:createWithSpriteFrameName("vip_num_" .. high .. ".png")
        local num_2 = CCSprite:createWithSpriteFrameName("vip_num_" .. low .. ".png")

        num_1:setAnchorPoint(ccp(0.5,0.5))
        num_2:setAnchorPoint(ccp(0.5,0.5))

        num_1:setPosition(ccp(-10,0))
        num_2:setPosition(ccp(10,0))

        node:addChild(num_1,10)
        node:addChild(num_2,10)
    elseif num >= 100 then
        local table = {1,0,0}
        local x = math.floor(num / 100)
        local y = math.floor((num - x*100) / 10)
        local z = num - x*100 - y*10
        table[1] = x
        table[2] = y
        table[3] = z
        for i=1,3 do
            local num_sprite = CCSprite:createWithSpriteFrameName("vip_num_" .. table[i] .. ".png")
            num_sprite:setAnchorPoint(ccp(0.5,0.5))
            num_sprite:setPosition(ccp(-15+(i-1)*20,0))
            node:addChild(num_sprite,10)
        end
    else
        local num_sprite = CCSprite:createWithSpriteFrameName("vip_num_" .. num .. ".png")
        num_sprite:setAnchorPoint(ccp(0.5,0.5))
        num_sprite:setPosition(ccp(0,0))
        local sprite_zi = CCSprite:createWithSpriteFrameName("serverGuild_zi.png")
        sprite_zi:setPosition(ccp(30,0))
        node:addChild(num_sprite,10)
        node:addChild(sprite_zi,10)
    end
    node:setScale(0.65)
end
--[[
    会长踢人的界面
]]
function game_server_guildbattle_point_pop.createTableView( self, viewSize )
    self:createNumIcon(self.building_cid,self.node_num)
    self.node_num:setVisible(true)
    self.btn_lookself:setVisible(true)
    self.btn_tiren:setVisible(false)
    -- cclog("createTableView ----z-----")
    local team_data = self.m_tGameData.owner_info
    -- cclog2(team_data,"team_data ==== ")

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag === ")

        local function responseMethod( tag,gameData )
            if gameData and tolua.type(gameData) == "util_json" then
                local data = gameData:getNodeWithKey("data")
                data = json.decode(data:getFormatBuffer())
                self.m_tGameData = data
                self.node_tableView:removeAllChildrenWithCleanup(true)
                local viewSize = self.node_tableView:getContentSize()
                self.node_tableView:addChild(self:createTableView(viewSize),10,10)
            end
        end
        local params = {}
        params.building_id = self.building_id
        params.owner_id = self.m_tGameData.owner_info[btnTag].owner_id
        -- cclog2(params.owner_id , 'params.owner_id  ====')

        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_remove_building"), http_request_method.GET, params,"new_guild_fight_remove_building")
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = game_util:getTableLen(team_data) 
    if params.totalItem == 0 then
        game_util:addMoveTips({text = "当前据点无人驻防"})
    end
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            local ccbNode = luaCCBNode:create()
            cell = CCTableViewCell:new()
            cell:autorelease()
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
            ccbNode:openCCBFile("ccb/ui_godfield_star_zhenxingitem.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0,itemSize.height*0));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local btn_chexiao = ccbNode:controlButtonForName("L_btn_chexiao")
            local btn_zhenxing = ccbNode:controlButtonForName("L_btn_zhenxing")
            local table_view_node = ccbNode:nodeForName("table_view_node")
            local L_zhadnouli_lb = ccbNode:labelTTFForName("L_zhadnouli_lb")
            local lab_name = ccbNode:labelTTFForName("lab_name")
            btn_chexiao:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
            lab_name:setVisible(true)
            btn_chexiao:setVisible(true)
            btn_zhenxing:setVisible(false)
            btn_chexiao:setTag(index + 1)
            if self.m_isManage then
                btn_chexiao:setVisible(true)
            else
                btn_chexiao:setVisible(false)
            end
            -- cclog2(team_data[index + 1],"zzz --------")
            local itemData = team_data[index + 1]["alignment_info"]

            local name = team_data[index + 1].name or ""
            local combat = team_data[index + 1].combat or ""
            L_zhadnouli_lb:setString(tostring(combat))
            lab_name:setString(name)
            table_view_node:removeAllChildrenWithCleanup(true)
            table_view_node:addChild(self:createAllIcon(table_view_node:getContentSize(),itemData))
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then
          
        end
    end

    return TableViewHelper:create(params);
    -- body
end
--[[
    创建会长踢人界面的阵容icon
]]
function game_server_guildbattle_point_pop:createAllIcon(viewSize,teamData)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_server_pyramid_n_res.plist")
    
    local character_detail_cfg = getConfig("character_detail")
    local heroCfg = nil
    -- local team = self.m_tGameData["building_info"].alignment_info or {}
    local showData = {}
    if teamData and next(teamData) then
        for k,v in pairs(teamData) do
            if v.c_id then
                table.insert(showData,v)
            end
        end
    else
        return
    end
    -- cclog2(showData,"showData")
    local itemCount =game_util:getTableLen(showData)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    if itemCount > 5 then
        params.column = 5;
    else
        params.column = itemCount;
    end 
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 3;
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height/params.row);
    self.m_cellSize = itemSize
    self.m_cellCount = itemCount
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell();
        if cell == nil then 
            cell = CCTableViewCell:new()
            cell:autorelease();
        end
        if cell then  
            cell:removeAllChildrenWithCleanup(true)
            local itemData = showData[index + 1]
            -- cclog2(itemData,"itemCount------------")
            if itemData and itemData.c_id then
                heroCfg = character_detail_cfg:getNodeWithKey(itemData.c_id);
                -- cclog2(heroCfg,"heightfdnsajkfhbdbgndflskbhvdas" .. index + 1)
                if itemData and heroCfg then
                    headIconSpr = game_util:createCardIconByCfg(heroCfg,itemData);
                    if headIconSpr then
                        headIconSpr:setScale(0.8);
                        headIconSpr:setPosition(itemSize.width * 0.5, itemSize.height * 0.5);
                        cell:addChild(headIconSpr,1,1);

                        local node = headIconSpr:getChildByTag(1)
                        if node then
                            node:setVisible(false)
                        end

                        local sprBoard = CCSprite:createWithSpriteFrameName("ui_pyramid_n_kuang3.png")
                        if sprBoard then
                            sprBoard:setPosition(itemSize.width * 0.5, itemSize.height * 0.5)
                            sprBoard:setScale(0.8);
                            cell:addChild(sprBoard, 20, 20)
                        end
                    end
                end
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" then
            local itemData = showData[index + 1]
            if itemData then
                game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 3})
            else 
                game_util:addMoveTips({text = "卡片信息错误！"})
            end
        end
    end
    return TableViewHelper:create(params) 
end
--[[
   自己阵容的icon
]]
function game_server_guildbattle_point_pop:createZhenRongList(team_index,viewSize,parend_node)
    local cards = {}
    local temp = self.m_tGameData.formation[tostring(team_index)]
    for k,v in pairs(temp.card_ids) do
        if k < 7 and k > 0 and v ~= "0" and v ~= "-1" then
            table.insert(cards,v)
        end
    end
    local count = #cards
    local px = viewSize.width/count
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    for k,v in pairs(cards) do
        local itemData = game_data:getCardDataById(v)
        local heroCfg = character_detail_cfg:getNodeWithKey(tostring(itemData.c_id)); 
        local headIconSpr = game_util:createCardIconByCfg(heroCfg,itemData);
        headIconSpr:setScale(0.8)
        local function onBtnCilck( event,target )
            if itemData then
                game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 3})
            end
        end
        local ccb = luaCCBNode:create()
        ccb:openCCBFile("ccb/ui_godfield_dart_zhenrong_item.ccbi")
        local icon_node = ccb:nodeForName("icon_node")
        icon_node:addChild(headIconSpr,1001,1001)
        headIconSpr:setAnchorPoint(ccp(0.5,0.5))
        headIconSpr:setPosition(ccp(0,0))
        ccb:setAnchorPoint(ccp(0.5,0.5))
        ccb:setPosition(ccp(px*(k-0.5),viewSize.height*0.5))
        parend_node:addChild(ccb)
        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        button:setOpacity(0)
        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
        button:setAnchorPoint(ccp(0.5,0.5))
        button:setPosition(ccp(0,0))
        icon_node:addChild(button);    
    end
end
--[[
    自己阵容的界面
]]

function game_server_guildbattle_point_pop.createFormationList(self, parentNode)
    cclog("-----createFormationList------")
    self.btn_lookself:setVisible(false)
    if self.m_isEnemy then
        self.btn_tiren:setVisible(false)
    else
        self.btn_tiren:setVisible(true)
    end
	local pos = {0.7,0.35,0}
	local viewSize = parentNode:getContentSize()
    local temp = game_data:getGodCardsPosData()
    local leftBtnTab = {}
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag ==== ")
        if btnTag < 4 then --左侧阵型按钮，变色用的
            for i=1,3 do
                if i == btnTag then
                    game_util:setCCControlButtonBackground(leftBtnTab[i],"godfen_zhen" .. btnTag .. btnTag .. ".png")
                else
                    game_util:setCCControlButtonBackground(leftBtnTab[i],"godfen_zhen" .. i .. ".png")
                end
            end
            self.m_select_index = btnTag
        elseif btnTag < 20 then --撤销
            local function responseMethod( tag,gameData )
                if gameData and tolua.type(gameData) == "util_json" then
                    local data = gameData:getNodeWithKey("data")
                    data = json.decode(data:getFormatBuffer())
                    self.m_tGameData = data
                    if self.m_tGameData.owner_building then
                        self.m_ower_building = self.m_tGameData.owner_building
                    end
                    self.node_tableView:removeAllChildrenWithCleanup(true)
                    local viewSize = self.node_tableView:getContentSize()
                    self:createFormationList(self.node_tableView)
                    game_util:addMoveTips({text = "队伍撤回成功"})
                end
                -- self:refreshUi()
            end
            local params = {}
            params.formation_id = btnTag - 10
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_give_up_building"), http_request_method.GET, params,"new_guild_fight_give_up_building")
        else
            --if self.m_step  then-- 派遣
                local function responseMethod( tag,gameData )
                    -- cclog2(gameData,"gameData ==== ")
                    if gameData and tolua.type(gameData) == "util_json" then
                        local data = gameData:getNodeWithKey("data")
                        data = json.decode(data:getFormatBuffer())
                        self.m_tGameData = data
                        if self.m_tGameData.owner_building then
                            self.m_ower_building = self.m_tGameData.owner_building
                        end
                        self.node_tableView:removeAllChildrenWithCleanup(true)
                        local viewSize = self.node_tableView:getContentSize()
                        self:createFormationList(self.node_tableView)
                        game_util:addMoveTips({text = "队伍驻扎成功"})
                    end
                    -- self:refreshUi()
                end
                local params = {}
                params.building_id = self.building_id
                params.formation_id = btnTag - 20
                params.force = 1
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_select_building"), http_request_method.GET, params,"new_guild_fight_select_building")
            --else
                --game_util:addMoveTips({text = "当前阶段不可以驻扎"})
            --end
        end
    end
	for i=1,3 do
        local curData = temp[tostring(i)]
        local ccbNode = luaCCBNode:create()

		ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
		ccbNode:openCCBFile("ccb/ui_godfield_star_zhenxingitem.ccbi")
        local btn_leftZhenxing = ccbNode:controlButtonForName("L_zhenxing")
        local L_btn_chexiao = ccbNode:controlButtonForName("L_btn_chexiao")
        local btn_zhushou = ccbNode:controlButtonForName("btn_zhushou")
        local L_btn_zhenxing = ccbNode:controlButtonForName("L_btn_zhenxing")
        L_btn_zhenxing:setVisible(false)
        btn_zhushou:setVisible(true)
        btn_leftZhenxing:setTag(i)
        game_util:setCCControlButtonBackground(btn_leftZhenxing,"godfen_zhen" .. i .. ".png")
        leftBtnTab[i] = btn_leftZhenxing
        L_btn_chexiao:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5)
        btn_leftZhenxing:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5)
        L_btn_chexiao:setTag(10 + i)
        btn_zhushou:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5)
        btn_zhushou:setTag(20 + i)
        if self.m_ower_building and self.m_ower_building[tostring(i)] then
            btn_zhushou:setVisible(false)
            L_btn_chexiao:setVisible(true)
        else
            btn_zhushou:setVisible(true)
            L_btn_chexiao:setVisible(false)
        end
        if self.m_isEnemy then
            btn_zhushou:setVisible(false)
            -- L_btn_zhenxing:setVisible(true)
        else

        end
        local label_combat = ccbNode:labelTTFForName("L_zhadnouli_lb")
        local str_combat = ""
        if  self.m_tGameData.formation[tostring(i)] then
            str_combat = self.m_tGameData.formation[tostring(i)].combat
        end
        
        label_combat:setString(str_combat)
		ccbNode:setPosition(ccp(-3,viewSize.height*pos[i]))
		parentNode:addChild(ccbNode,10,10)


        local lab_name = ccbNode:labelTTFForName("lab_name")
        lab_name:setVisible(true)      
        local cishu = self.m_tGameData.team_battle_times[tostring(i)] or 0
        lab_name:setString("已战斗次数:" .. cishu)  
        local table_view_node = ccbNode:nodeForName("table_view_node")
        table_view_node:removeAllChildrenWithCleanup(true)
        self:createZhenRongList(i,table_view_node:getContentSize(),table_view_node)
	end
end

--[[--
    刷新ui
]]
function game_server_guildbattle_point_pop.refreshUi(self)
	self.node_tableView:removeAllChildrenWithCleanup(true)
	local viewSize = self.node_tableView:getContentSize()
	local a = 1
	local tableView = nil
	if self.m_isOnly then --自己的三个阵型去站位 
        if self.m_isEnemy then
            self.btn_tiren:setVisible(false)
        else
            -- if self.m_isManage then
            self.btn_tiren:setVisible(true)
            -- end
            if self.building_cid then
                self:createNumIcon(self.building_cid,self.node_num)
                self.node_num:setVisible(true)
            end
        end
		self:createFormationList(self.node_tableView)

	else --会长进来，踢人的
        self.btn_tiren:setVisible(false)
        self.node_tableView:addChild(self:createTableView(viewSize),10,10)
	end
    -- cclog2(self.m_isManage,"self.m_isManage ===")

	-- self.node_tableView:addChild(tableView,10,10)
end

--[[--
    初始化
]]
function game_server_guildbattle_point_pop.init(self,t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_vip.plist")
    self.m_tGameData = {};
    t_params = t_params or {};
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        data = json.decode(data:getFormatBuffer())
        self.m_tGameData = data
    end
    self.building_id = 0 
    if t_params.building_id then
        self.building_id = t_params.building_id
    end
    self.m_ower_building = {}
    self.m_isOnly = false
    if t_params.isOnly then
        self.m_isOnly = true
        if self.m_tGameData.owner_building then
            self.m_ower_building = self.m_tGameData.owner_building
        end
    end
    self.m_isEnemy = false
    if t_params.isEnemy then
        self.m_isEnemy = t_params.isEnemy
    end
    self.m_isManage = false
    -- if t_params.isManage then
    --     self.m_isManage = t_params.isManage
    -- end
    self.m_isManage = game_data:getServerGuildIsManage()
    self.m_select_index = 0
    self.m_step = nil
    self.building_cid = nil
    if t_params.c_id then
        self.building_cid = t_params.c_id
    end
    if t_params.step then
        self.m_step = t_params.step
    end 
end

--[[--
    创建ui入口并初始化数据
]]
function game_server_guildbattle_point_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_server_guildbattle_point_pop;