--- 
local game_godfield_fenzhengzhenxing_pop = {
    m_root_layer = nil,
    -- m_label_server = nil,
    -- m_label_name = nil,
    -- m_label_level = nil,
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
    -- m_integral_lab = nil,
    -- m_win_lab = nil,
    win_per = nil,
    score = nil,
    table_node = nil,
    own_combat = nil,
    enemy_combat = nil,
    m_touch_layer = nil,
    cell_tab = nil,
    m_num_tab = nil,
    m_openType = nil,
};

--[[--
    销毁
]]
function game_godfield_fenzhengzhenxing_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_fenzhengzhenxing_pop destroy-----------------");
    self.m_root_layer = nil;
    -- self.m_label_server = nil;
    -- self.m_label_name = nil;
    -- self.m_label_level = nil;
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
    -- self.m_integral_lab = nil;
    -- self.m_win_lab = nil;
    self.win_per = nil;
    self.score = nil;
    self.table_node = nil;
    self.own_combat = nil;
    self.enemy_combat = nil;
    self.m_touch_layer = nil;
    self.cell_tab = nil;
    self.m_num_tab = nil;
    self.m_openType = nil;
end
--[[--
    返回
]]
function game_godfield_fenzhengzhenxing_pop.back(self)
    if self.m_openType == "godfield_teamboss" then
        local function responseMethod( tag,gameData )
            game_scene:enterGameUi("game_goefield_teamBoss",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
    elseif self.m_openType == "new_fenzheng" then
        local function responseMethod( tag,gameData )
            game_scene:enterGameUi("game_godfield_newFenzheng",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
    elseif self.m_openType == "fenzheng_main" then
        local function responseMethod( tag,gameData )
            game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, {},"team_pk_new_index")
    else 
        game_scene:removePopByName("game_godfield_fenzhengzhenxing_pop")
    end
    -- local function responseMethod( tag,gameData )
    --     game_scene:enterGameUi("game_godfield_fenzheng",{gameData = gameData})
    -- end
    -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, {},"team_pk_new_index")
    -- game_scene:removePopByName("game_godfield_fenzhengzhenxing_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_fenzhengzhenxing_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local team_index = 1;
        if 10<= btnTag and btnTag <= 12 then
            team_index = self.m_num_tab[btnTag-9];
            local function responseMethod(tag,gameData)
                if gameData then
                    game_scene:enterGameUi("game_god_adjustment",{gameData = gameData,openType=self.m_openType,team_index = team_index,myformation = self.m_num_tab});
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_upload_god_formation"), http_request_method.GET, nil,"god_field_upload_god_formation",true,true)
        end
        if btnTag == 100 then
            self:back();
        elseif btnTag == 101 then--战斗
           local function responseMethod( tag,gameData )
               game_scene:enterGameUi("game_goefield_teamBoss",{gameData = gameData})
           end
           network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_index"), http_request_method.GET, nil,"team_pk_new_index")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_fenzhengzhenxing_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_team_btn1,m_team_btn2,m_team_btn3
    local m_btn_tab = {}
    for i=1,3 do
        m_team_btn = ccbNode:controlButtonForName("m_team_btn" .. i)
        m_team_btn:setScale(0.75)
        m_team_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
        m_btn_tab[i] = {}
    end
    -- m_team_btn1 = ccbNode:controlButtonForName("m_team_btn1")
    -- m_team_btn2 = ccbNode:controlButtonForName("m_team_btn2")
    -- m_team_btn3 = ccbNode:controlButtonForName("m_team_btn3")

    self.m_btn_close = ccbNode:controlButtonForName("m_btn_close")
    self.m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn_attack = ccbNode:controlButtonForName("m_btn_attack")
    self.m_btn_attack:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn_attack:setVisible(false)
    self.m_label_zhandouli = ccbNode:labelTTFForName("m_label_combat");

    self.m_scrollview_tab = ccbNode:scale9SpriteForName("m_scrollview_tab");

    self.m_sprite_shengli = ccbNode:scale9SpriteForName("m_sprite_shengli")
    self.m_touch_layer = ccbNode:layerForName("m_touch_layer")
    self.m_sprite_shengli:setVisible(false)
    self.anim_node = ccbNode:nodeForName("anim_node")
    self.anim_node:setVisible(false)

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
function game_godfield_fenzhengzhenxing_pop.refreshUi(self)
    self:getCid()
    self.own_combat = {self.m_tGameData.god_combat_1,self.m_tGameData.god_combat_2,self.m_tGameData.god_combat_3}
    self.enemy_combat = {self.m_tGameData.enemy_god_combat_1,self.m_tGameData.enemy_god_combat_2,self.m_tGameData.enemy_god_combat_3}
    -- self.m_label_name:setString(self.m_tGameData.name)
    -- self.m_label_server:setString(self.m_tGameData.server_name)
    -- self.m_label_zhandouli:setString(self.m_tGameData.combat)
    -- self.m_label_level:setString(self.m_tGameData.level)
    self.m_touch_layer:removeAllChildrenWithCleanup(true);
    -- local tableView = self:createRankTable(self.m_touch_layer:getContentSize());
    -- tableView:setTouchEnabled(false)
    local function onMainBtnClick1( target,event )
    end
    for i=1,3 do
        local ccbNode = self:createCell()
        self:setCellInfo(ccbNode,onMainBtnClick1,self.m_num_tab[i]-1)
        ccbNode:setPosition(ccp(0,145-72*(i-1)))
        self.m_touch_layer:addChild(ccbNode,10,i)
        self.cell_tab[i] = {cell = ccbNode}
    end
    -- self.m_touch_layer:addChild(tableView,10,10);
    self:initCellTouch()


end

function game_godfield_fenzhengzhenxing_pop.getCid(self)
    self.cid = {};
    local god_field_ids = self.m_tGameData.god_field_ids
    for i =1,3 do
        local tab = god_field_ids[tostring(i)]
        local y = 1
        local adjust = {}

        for k,v in pairs(tab) do
            local ling = tostring(0)
            local yi = tostring(-1)
            if v ~= ling and v ~= yi then
                local x = v
                table.insert(adjust,v)
            end
        end
        self.cid[i] = adjust
    end
end

function game_godfield_fenzhengzhenxing_pop:createCell()
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        
    end 
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_fenzheng_zhenxinginfo2.ccbi");
    return ccbNode
end
function game_godfield_fenzhengzhenxing_pop:setCellInfo(ccbNode,onMainBtnClick1,index)
    local m_battle_count = ccbNode:labelTTFForName("m_battle_count")
    local m_team_count_lab = ccbNode:labelTTFForName("m_team_count_lab")
    local hero_node = ccbNode:nodeForName("enemy_info_node")
    local heroIcon = ccbNode:nodeForName("heroIcon")
    local m_btn_node = ccbNode:nodeForName("m_btn_node")
    local touchNode = ccbNode:nodeForName("m_touch_node")
    local my_comat = ccbNode:labelTTFForName("m_my_comat")
    local m_exchange_btn = ccbNode:controlButtonForName("m_exchange_btn")
    game_util:setCCControlButtonBackground(m_exchange_btn,"godfen_zhen" .. index+1 .. ".png")
    my_comat:setString(self.m_tGameData["god_combat_" .. tostring(index+1)]) --设置自己阵型战斗力
    self:getCid(); --得到cid
    local num_zhenxing = index+1
    local alignment_info = self.cid[num_zhenxing]
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemData = {}
        itemData = game_data:getCardDataById(alignment_info[btnTag])
        if itemData then
            game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 3})
        end
    end
    local character_detail_cfg = getConfig("character_detail");
    
    local nodeSize = hero_node:getContentSize()
    local length = math.min(#alignment_info,5)
    local dw = nodeSize.width / length
    local dx = dw / 2
    hero_node:removeAllChildrenWithCleanup(true)
    for i=1,math.min(5,#alignment_info) do
        local cardData,heroCfg = game_data:getCardDataById(alignment_info[i])
        if cardData and heroCfg then
            headIconSpr = game_util:createCardIconByCfg(heroCfg,cardData);
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
                m_btn_node:addChild(button);
            end
        end
    end
    -- cell_tab[index+1] = cell
end

function game_godfield_fenzhengzhenxing_pop.initCellTouch( self )
    -- cclog2(self.cell_tab,"cell_tab")
   local selItem = nil;
   local beganItem = nil;
   local endItem = nil;
   local touchBeginPoint = nil;
   local touchMoveFlag = false;
   local realPos = nil;
   local tempPosIndex = nil;
   local function onTouchBegan(x, y)
        -- cclog(x .. "x ==" .. y .. "y === ")
        if selItem then
           selItem:removeFromParentAndCleanup(true);
           selItem = nil;
        end
       touchMoveFlag = false;
       -- --cclog("onTouchBegan: %0.2f, %0.2f", x, y)
       touchBeginPoint = {x = x, y = y}
       
       -- CCTOUCHBEGAN event must return true
        
        for index = 1,3 do
            -- realPos = self.cell_tab[index].cell:getParent():convertToNodeSpace(ccp(x,y));
            realPos = self.m_touch_layer:convertToNodeSpace(ccp(x,y))
            beganItem = self.cell_tab[index].cell
            -- realPos = beganItem:convertToNodeSpace(ccp(x,y));
            local posx,posy = beganItem:getPosition()
             -- cclog("px == " .. posx .. " py ==" .. posy)
            -- local beganItemRealPos = beganItem:getParent():convertToNodeSpace(ccp(posx,posy))
            local rect = beganItem:boundingBox()
            -- cclog("rect x== " .. rect.origin.x)
            -- cclog("rect y== " .. rect.origin.y)
            -- cclog("rect w== " .. rect.size.width)
            -- cclog("rect h== " .. rect.size.height)
            -- cclog2(beganItem:boundingBox():containsPoint(realPos),"beganItem:boundingBox():containsPoint(realPos) ===")
            if beganItem and beganItem:boundingBox():containsPoint(realPos) then
                local function onMainBtnClick2()
                end
               tempPosIndex = index;
               -- cclog2(index,"index === ")
               local ccbNode = self:createCell()
               self:setCellInfo(ccbNode,onMainBtnClick2,self.m_num_tab[index]-1)
               -- cclog2(ccbNode,"ccbNode === ")
               selItem = ccbNode
               if selItem == nil then break end
               local pX,pY = beganItem:getPosition();
               selItem:setPosition(ccp(pX,pY));
               -- cclog2(math.floor(realPos.x)/350,"xxxx ")
               -- cclog2(pX,"pxxxx")
               local anchorPoint_x,anchorPoint_y
               anchorPoint_x = math.floor(realPos.x)/350
               -- anchorPoint_y = math.floor(realPos.y)/210
               selItem:setAnchorPoint(ccp(anchorPoint_x,0.5))
               -- self.m_touch_layer:addChild(selItem,11,11);
               self.m_ccbNode:addChild(selItem,100)
               selItem:setVisible(false);
               break;
            end
        end
        return true
   end
   
   local function onTouchMoved(x, y)
        -- cclog2(ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)),"ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) ===")
       --if ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 or touchMoveFlag == true then
            if selItem then
                realPos =  self.m_touch_layer:convertToNodeSpace(ccp(x,y))
                -- cclog("realPos == " .. realPos.x .. "  y " .. realPos.y)
                selItem:setPosition(ccp(x,y));
                selItem:setVisible(true);
            end
            touchMoveFlag = true;
       --end
   end
   
   local function onTouchEnded(x, y)
        realPos = self.m_touch_layer:convertToNodeSpace(ccp(x,y))
        local realMove = false
        if selItem and touchMoveFlag then
            if 0<math.floor(realPos.y) and math.floor(realPos.y) <73 then
                local x = self.m_num_tab[3]
                self.m_num_tab[3] = self.m_num_tab[tempPosIndex]
                self.m_num_tab[tempPosIndex] = x
                if tempPosIndex == 3 then
                    realMove = false
                else
                    realMove = true
                end
            elseif 73<=math.floor(realPos.y) and math.floor(realPos.y)  < 144 then
                 local x = self.m_num_tab[2]
                self.m_num_tab[2] = self.m_num_tab[tempPosIndex]
                self.m_num_tab[tempPosIndex] = x
                if tempPosIndex == 2 then
                    realMove = false
                else
                    realMove = true
                end
            elseif 144<= math.floor(realPos.y) and math.floor(realPos.y) <216 then
                local x = self.m_num_tab[1]
                self.m_num_tab[1] = self.m_num_tab[tempPosIndex]
                self.m_num_tab[tempPosIndex] = x
                if tempPosIndex == 1 then
                    realMove = false
                else
                    realMove = true
                end
            else

            end
            local function responseMethod( tag,gameData )
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local data = gameData:getNodeWithKey("data");
                    data = json.decode(data:getFormatBuffer())
                    -- self.m_tGameData = data
                    self.m_num_tab = data.team_pk_formation
                    self:refreshUi()
                end
            end
            local params = {}
            params.formation = tostring(self.m_num_tab[1] .. "&formation=" .. self.m_num_tab[2] .. "&formation=" .. self.m_num_tab[3])
            if realMove == true then
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_pk_new_team_pk_formation"), http_request_method.GET, params,"team_pk_new_team_pk_formation")
            end
        end
        if selItem then
            selItem:removeFromParentAndCleanup(true);
            selItem = nil;
        end
        realMove = false
        touchBeginPoint = nil;
        beganItem = nil;
        endItem = nil;
        tempPosIndex = nil;

   end
   
   local function onTouch(eventType, x, y)

       if eventType == "began" then
           return onTouchBegan(x, y)
           elseif eventType == "moved" then
           return onTouchMoved(x, y)
           else
           return onTouchEnded(x, y)
       end
   end
    self.m_touch_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10)
    self.m_touch_layer:setTouchEnabled(true)
end

--[[--
    初始化
]]
function game_godfield_fenzhengzhenxing_pop.init(self,t_params)
    self.cell_tab = {}
    self.m_num_tab = {}
    t_params = t_params or {};
    self.m_openType = t_params.openType or ""
 
    self.m_num_tab = t_params.formation
    self.sort  = t_params.sort
    self.win_flag = t_params.win_flag
    -- self.win_per = t_params.win_per or 0  --胜利率
    self.score = t_params.score or 0 --积分
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        self.alignment = self.m_tGameData.alignment
    else
        self.m_tGameData = {};
    end
   
    -- cclog2(self.gameData,"self.gameData")
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_fenzhengzhenxing_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_fenzhengzhenxing_pop;