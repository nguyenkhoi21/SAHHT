--- 敌人
local game_godfield_arean_enemy_pop = {
    m_root_layer = nil,
    m_label_server = nil,
    m_label_name = nil,
    m_label_level = nil,
    m_label_zhandouli = nil,
    m_btn_close = nil,
    m_btn_attack = nil,
    m_tGameData = nil,
    m_popUi = nil,
    -- enemy_info_node = nil,
    -- m_enemyIcon2 = nil,
    -- m_enemyIcon3 = nil,
    sort = nil,
    m_zhenxingIcon_1 = nil,
    cid = nil,
    heroIcon = nil,
    win_flag = nil,
    anim_node = nil,
    m_sprite_shengli = nil,
    m_scrollview_tab = nil,
    m_integral_lab = nil,
    m_win_lab = nil,
    win_per = nil,
    score = nil,
    table_node = nil,
    own_combat = nil,
    enemy_combat = nil,
    m_num_tab = nil,
    m_btn_tab = nil,
    m_select_index = nil,
    m_adjustFlag = nil,
    m_btn_pos_tab = nil,
    m_btn_node = nil,
};

--[[--
    销毁
]]
function game_godfield_arean_enemy_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_arean_enemy_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_label_server = nil;
    self.m_label_name = nil;
    self.m_label_level = nil;
    self.m_label_zhandouli = nil;
    self.m_btn_close = nil;
    self.m_btn_attack = nil;
    self.m_tGameData = nil;
    self.m_popUi = nil;
    -- self.enemy_info_node = nil;
    -- self.m_enemyIcon2 = nil;
    -- self.m_enemyIcon3 = nil;
    self.sort = nil;
    self.m_zhenxingIcon_1 = nil;
    self.cid = nil;
    self.heroIcon = nil;
    self.win_flag = nil;
    self.m_sprite_shengli = nil;
    self.anim_node = nil;
    self.m_scrollview_tab = nil;
    self.m_integral_lab = nil;
    self.m_win_lab = nil;
    self.win_per = nil;
    self.score = nil;
    self.table_node = nil;
    self.own_combat = nil;
    self.enemy_combat = nil;
    self.m_num_tab = nil;
    self.m_btn_tab = nil;
    self.m_select_index = nil;
    self.m_adjustFlag = nil;
    self.m_btn_pos_tab = nil;
    self.m_btn_node = nil;
end
--[[--
    返回
]]
function game_godfield_arean_enemy_pop.back(self)
    game_scene:removePopByName("game_godfield_arean_enemy_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_arean_enemy_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then
            self:back();
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
                        game_util:setCCControlButtonBackground(self.m_btn_tab[i],"godfen_zhen" .. self.m_num_tab[i]+(self.m_num_tab[i]*10) ..".png")
                        self.m_btn_tab[i]:setTouchEnabled(false)
                    else
                        game_util:setCCControlButtonBackground(self.m_btn_tab[i],"godfen_zhen" .. self.m_num_tab[i] ..".png")
                        self.m_btn_tab[i]:setTouchEnabled(true)
                    end
                end
            end

        elseif btnTag == 104 then--战斗
            local params = {}
            params.sort = self.sort
            local function responseMethod( tag,gameData )
                 if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local sort = self.sort
                    local data1 = gameData:getNodeWithKey("data");
                    data1 = json.decode(data1:getFormatBuffer())
                    local tempTab = util.table_copy(self.m_tGameData.god_field_ids)
                    for i=1,3 do
                        self.m_tGameData.god_field_ids[tostring(i)] = tempTab[tostring(self.m_num_tab[i])]
                    end
                    game_scene:enterGameUi("game_godfield_battle_big",{gameData = self.m_tGameData,data1 = data1,sort = sort})
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_god_field_battle"), http_request_method.GET, params,"god_field_god_field_battle")
        
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_enemy.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    self.m_btn_close = ccbNode:controlButtonForName("m_btn_close")
    self.m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn_attack = ccbNode:controlButtonForName("m_btn_attack")
    self.m_btn_attack:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_label_server = ccbNode:labelTTFForName("m_label_server");
    self.m_label_name = ccbNode:labelTTFForName("m_label_name");
    self.m_label_level = ccbNode:labelTTFForName("m_label_level");
    self.m_label_zhandouli = ccbNode:labelTTFForName("m_label_combat");
    self.m_btn_node = ccbNode:nodeForName("m_btn_node")
    self.m_scrollview_tab = ccbNode:scale9SpriteForName("m_scrollview_tab");
    self.m_integral_lab = ccbNode:labelTTFForName("m_integral_lab");
    self.m_win_lab = ccbNode:labelTTFForName("m_win_lab");
    self.m_integral_lab:setString(tostring(self.score));
    self.m_win_lab:setString(tostring(self.win_per));
    self.m_btn_tab = {}
    local m_btn 
    for i=1,3 do
        m_btn = ccbNode:controlButtonForName("m_teamNum_btn" .. i)
        m_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-13)
        self.m_btn_tab[i] = m_btn
    end
    self.m_sprite_shengli = ccbNode:scale9SpriteForName("m_sprite_shengli")

    self.m_sprite_shengli:setVisible(false)
    self.anim_node = ccbNode:nodeForName("anim_node")
    self.anim_node:setVisible(false)
    if self.win_flag ~= nil then
        self.m_btn_attack:setVisible(false)
        self:createBountyAnim()
        --self.m_sprite_shengli = nil;
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_godfield_arean_enemy_pop.refreshUi(self)
    self.own_combat = {self.m_tGameData.god_combat_1,self.m_tGameData.god_combat_2,self.m_tGameData.god_combat_3}
    self.enemy_combat = {self.m_tGameData.enemy_god_combat_1,self.m_tGameData.enemy_god_combat_2,self.m_tGameData.enemy_god_combat_3}
    self.m_label_name:setString(self.m_tGameData.name)
    self.m_label_server:setString(self.m_tGameData.server_name)
    self.m_label_zhandouli:setString(self.m_tGameData.combat)
    self.m_label_level:setString(self.m_tGameData.level)

    self.m_scrollview_tab:removeAllChildrenWithCleanup(true);
    local tableView = self:createRankTable(self.m_scrollview_tab:getContentSize());
    self.m_scrollview_tab:addChild(tableView,10,10);
    for i=1,3 do
        local posX,posY = self.m_btn_tab[i]:getPosition()
        self.m_btn_pos_tab[i] = {posX = posX,posY = posY}
        game_util:setCCControlButtonBackground(self.m_btn_tab[i],"godfen_zhen" .. self.m_num_tab[i] ..".png")
    end
   
end
--[[--
    创建自己阵容的第一个卡牌的头像
]]
function game_godfield_arean_enemy_pop.createHeroIcon(self,cid,parentNode,index)
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local cardData = game_data:getCardDataById(cid[btnTag])
        if cardData then
            game_scene:addPop("game_hero_info_pop",{tGameData = cardData,openType = 3})
        end
    end
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
            headIconSpr:setAnchorPoint(ccp(0.5,0.5));
            headIconSpr:setPosition(ccp(20,17));
            parentNode:addChild(headIconSpr,1,1);
            --headIconSpr = game_util:createCardIconByCfg(heroCfg,cardData);                                                                                                                   :addChild(headIconSpr,1,1);
            local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
            button:setTag(index)
            button:setOpacity(0)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
            button:setAnchorPoint(ccp(0.5,0.5))
            button:setPosition(ccp(20,17));
            parentNode:addChild(button);
        end
    end
    -- end

end
--[[
    打击动画
]]
function game_godfield_arean_enemy_pop.createBountyAnim(self)
    self.anim_node:setVisible(true)
    --self.anim_node:setPosition(170,130)
    self.anim_node:removeAllChildrenWithCleanup(true)
    local function setOver(node)
        game_sound:playUiSound("stamp")
    end
    local function setSpiteVisible(sprite)
        sprite:setVisible(true)
    end
    local setOver = CCCallFuncN:create(setOver)
    local setSpiteVisible = CCCallFuncN:create(setSpiteVisible)
    local duang = nil
    --cclog2(self.win_flag,"createBountyAnim  === ")
    if self.win_flag == true then
        --cclog("shenglishenglishenglishenglishengli")
        duang = CCSprite:createWithSpriteFrameName("godfield_shengli.png")
    else
        --cclog("shibaibaibaibaibai")
        duang = CCSprite:createWithSpriteFrameName("godfield_shibai.png")
    end
    duang:setPosition(ccp(0,100))
    duang:setRotation(330)
    --duang:setScale(4)
    duang:setVisible(true)
    self.anim_node:addChild(duang)
    local arr = CCArray:create();
     arr:addObject(CCDelayTime:create(0.1));
            arr:addObject(setSpiteVisible)
            arr:addObject(CCScaleBy:create(0.5,0.5));
            arr:addObject(setOver);
    duang:runAction(CCSequence:create(arr));
    
end
function game_godfield_arean_enemy_pop.getCid(self)
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
--[[
    按钮移动
    index1 选中的按钮的index，index2 要交换的按钮的index
]]
function game_godfield_arean_enemy_pop.setbuttonAnim( self,index1,index2 )
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
    -- self.m_btn_tab[index2]:setVisible(false)
    self.m_btn_tab[index1]:runAction(CCSequence:create(animArr));
end
--[[
    竖的table
]]
function game_godfield_arean_enemy_pop.createRankTable(self,viewSize)
    local changci = {"Trận 1","Trận 2","Trận 3"};
    local zhenxing = {"Đội\nhình\n1","Đội\nhình\n2","Đội\nhình\n3"};
    local function onMainBtnClick( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local team_index = 1;
        cclog2(btnTag,"btnTag === ")
        if btnTag == 10 then
            team_index = 1;
        elseif btnTag == 11 then
            team_index = 2;
        elseif btnTag == 12 then
            team_index = 3;
        end
        local function responseMethod(tag,gameData)
            if gameData then
                game_scene:enterGameUi("game_god_adjustment",{gameData = gameData,openType="game_godfield_arean",team_index = team_index});
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_upload_god_formation"), http_request_method.GET, nil,"god_field_upload_god_formation",true,true)
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = 3 ;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-10;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            -- ccbNode:registerFunctionWithFuncName("onBtnClick",onBtnClick);
            ccbNode:openCCBFile("ccb/ui_godfield_battle_info.ccbi");
            -- ccbNode:controlButtonForName("m_teamNum_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5 - 10));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_battle_count = ccbNode:labelTTFForName("m_battle_count")
            local hero_node = ccbNode:nodeForName("enemy_info_node")
            local heroIcon = ccbNode:nodeForName("heroIcon")
            local touchNode = ccbNode:nodeForName("m_touch_node")
            local my_comat = ccbNode:labelTTFForName("m_my_comat")
            local enemy_combat = ccbNode:labelTTFForName("m_di_comat")
            -- local m_teamNum_btn = ccbNode:controlButtonForName("m_teamNum_btn")
            -- game_util:setCCControlButtonBackground(m_teamNum_btn,"godfen_zhen" .. self.m_num_tab[index+1] ..".png")
            -- m_teamNum_btn:setTag(index+1)
            local m_team_btn = game_util:createCCControlButton("godfield_zhenxing.png","",onMainBtnClick)
            cclog2(self.m_num_tab[index+1],"self.m_num_tab[index+1] === ")
            m_team_btn:setTag(9+ tonumber(self.m_num_tab[index+1]))
            m_team_btn:setOpacity(255)
            m_team_btn:setScale(0.8)
            m_team_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-15)
            m_team_btn:setAnchorPoint(ccp(0.5,0.5))
            m_team_btn:setPosition(ccp(330,30))
            m_team_btn:setZoomOnTouchDown(false);
            touchNode:addChild(m_team_btn);
            -- self.m_btn_tab[index+1] = m_teamNum_btn
            m_battle_count:setString(changci[tonumber(index+1)]) --设置场次 
            -- m_team_count_lab:setString(zhenxing[tonumber(index+1)]) --设置阵型数
            my_comat:setString(self.own_combat[tonumber(self.m_num_tab[index+1])]) --设置自己阵型战斗力
            enemy_combat:setString(self.enemy_combat[tonumber(index+1)]) -- 设置敌方阵型战斗力
            self:getCid(); --得到cid
            self:createHeroIcon(self.cid,heroIcon,tonumber(self.m_num_tab[index+1])); --设置第一个头像
            
            local num_zhenxing = index+1
            num_zhenxing = tostring(num_zhenxing)
            local alignment_info = self.m_tGameData.alignment_info[num_zhenxing]
            local function onBtnCilck( event,target )
                local tagNode = tolua.cast(target, "CCNode");
                local btnTag = tagNode:getTag();
                local itemData = alignment_info[btnTag];
                if itemData then
                    game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 3})
                end
            end
            local character_detail_cfg = getConfig("character_detail");
            
            local nodeSize = hero_node:getContentSize()
            local dw = nodeSize.width / #alignment_info
            local dx = dw / 2
            hero_node:removeAllChildrenWithCleanup(true)
            for i=1,math.min(5,#alignment_info) do
                itemData = alignment_info[i];
                heroCfg = character_detail_cfg:getNodeWithKey(itemData.c_id);
                if itemData and heroCfg then
                    headIconSpr = game_util:createCardIconByCfg(heroCfg,itemData);
                    if headIconSpr then
                        headIconSpr:setScale(0.7);
                        headIconSpr:setPosition(ccp(dx + (i-1)*dw - 5,20));
                        hero_node:addChild(headIconSpr,1,1);

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
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));

        end
    end
    return TableViewHelper:create(params);
end

--[[--
    初始化
]]
function game_godfield_arean_enemy_pop.init(self,t_params)
    t_params = t_params or {};
    self.sort  = t_params.sort
    self.m_adjustFlag = false
    self.m_btn_pos_tab = {}
    self.win_flag = t_params.win_flag
    self.win_per = t_params.win_per or 0  --胜利率
    self.win_per = self.win_per*100 .."%"
    self.score = t_params.score or 0 --积分
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        self.alignment = self.m_tGameData.alignment
        self.m_num_tab = self.m_tGameData.formation_battle_order
    else
        self.m_tGameData = {};
    end
    if self.m_tGameData.score then
        self.score = self.m_tGameData.score or 0 
    end
    if self.m_tGameData.win_per then
        self.win_per = string.format("%.2f", self.m_tGameData.win_per) or 0
        self.win_per = self.win_per*100 .."%"
    end

   
    -- cclog2(self.gameData,"self.gameData")
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_arean_enemy_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_arean_enemy_pop;