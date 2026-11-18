--- 押镖宇宙
local game_godfield_maspop = {
    m_goods_node = nil,
    table_view_node = nil,
    m_ship_sp = nil,
    name_lable = nil,
    lv_lable = nil,
    qufu_lable = nil,
    combat_lable = nil,
    union_lable = nil,
};

--[[--
    销毁
]]
function game_godfield_maspop.destroy(self)
    -- body
    cclog("-----------------game_godfield_maspop destroy-----------------");
    self.m_goods_node = nil;
    self.table_view_node = nil;
    self.m_ship_sp = nil;
    self.name_lable = nil;
    self.lv_lable = nil;
    self.qufu_lable = nil;
    self.combat_lable = nil;
    self.union_lable = nil;
end
--[[--
    返回
]]
function game_godfield_maspop.back(self,type)
    game_scene:removePopByName("game_godfield_dart_msgpop");
    -- self.m_callBackFunc()
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_maspop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 5 then
            if self.shield ~= "0" then
                game_util:addMoveTips( {text = "Tàu chiến địch có tấm chắn, không thể cướp!"})
            elseif self.rob_free_times == 0 then
                game_util:addMoveTips( {text = "Bạn đã hết số lần cướp!"})
            elseif self.m_tGameData.rob_times > 2 then
                game_util:addMoveTips( {text = "Tàu bay đã bị cướp hơn 3 lần rồi, hãy đổi chiếc khác!"})
            else
                local my_uid = game_data:getUserStatusDataByKey("uid") or ""
                local is_rob = false
                for k,v in pairs(self.rob_list) do
                    if my_uid == v then
                        game_util:addMoveTips( {text = "Tàu này đã bị bạn cướp qua, hãy đổi chiếc khác!"})
                        is_rob = true
                        return
                    end
                end

                if not is_rob then
                    local function responseMethod(tag,gameData)
                        game_scene:addPop("game_godfield_dart_pop",{gameData = gameData,vehicle_captain_uid = self.vehicle_captain_uid,open ="rob"})
                    end
                    params={}
                    params.keys = 1
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_employ_ground"), http_request_method.GET,params,"god_field_escort_employ_ground")
                end
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_dart_ship_pop.ccbi");
    self.m_goods_node=ccbNode:nodeForName("m_goods_node")
    self.table_view_node=ccbNode:nodeForName("table_view_node")
    self.m_ship_sp = ccbNode:spriteForName("m_ship_sp")
    self.name_lable = ccbNode:labelTTFForName("name_lable")
    self.lv_lable = ccbNode:labelTTFForName("lv_lable")
    self.qufu_lable = ccbNode:labelTTFForName("qufu_lable")
    self.combat_lable = ccbNode:labelTTFForName("combat_lable")
    self.union_lable = ccbNode:labelTTFForName("union_lable")    
    self.m_root_layer = ccbNode:layerForName('m_root_layer')
    self.rob_btn = ccbNode:controlButtonForName("rob_btn")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_ship_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_ship_" .. self.m_tGameData.buff_sort .. ".png"))
    if self.isMine then
       self.rob_btn:setVisible(false) 
    end
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-7)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-6,true)
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
function game_godfield_maspop.createGoods( self )
    local itemcfg = self.gods
    local icon ,name , count = game_util:getRewardByItemTable(itemcfg);
    function onBtnCilck( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        game_util:lookItemDetal( itemcfg )
    end
    if icon then
        icon:setAnchorPoint(ccp(0.5,0.5))
        icon:setPosition(ccp(0,0))
        icon:setScale(0.9)
        self.m_goods_node:addChild(icon)
        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        button:setAnchorPoint(ccp(0.5,0.5))
        button:setPosition( icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5 )
        button:setOpacity(0)
        icon:addChild(button)
    end 
end
function game_godfield_maspop.refreshUi(self)
    if self.msg then
        self.qufu_lable:setString(self.msg.server_name)
        self.name_lable:setString(self.msg.name)
        self.lv_lable:setString(self.msg.level)
        self.combat_lable:setString(self.msg.combat)
        self.union_lable:setString(self.msg.guild_name)
    end
    self.table_view_node:removeAllChildrenWithCleanup(true)
    self:createZhenRongList(self.table_view_node:getContentSize())
    self:createGoods()
    -- self:createzhenrongitem()
end

function game_godfield_maspop.createZhenRongList( self , viewSize)
    local posx = {0.1,0.3,0.5,0.7,0.9}
    local cards_data = self.m_tGameData.attacker_info.cards
    cclog(#cards_data,"=============")
    local ligin = self.m_tGameData.attacker_info.alignment_1_cards
    local cards = {}
    for k,v in pairs(ligin) do
        table.insert(cards,cards_data[v])
    end

    local count = #cards
    local px = viewSize.width/count
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    for k,v in pairs(cards) do
        local itemData = v
        local heroCfg = character_detail_cfg:getNodeWithKey(tostring(itemData.c_id)); 
        local headIconSpr = game_util:createCardIconByCfg(heroCfg,itemData);
        headIconSpr:setScale(0.8)

        local function onBtnCilck( event,target )
            local itemData = v
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
        self.table_view_node:addChild(ccb)
        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        -- if isem then
        --     button:setTag(999)
        --     employed_layer:setVisible(true)
        -- else
        --     button:setTag(i)
        --     employed_layer:setVisible(false)
        -- end
        button:setOpacity(0)
        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-7)
        button:setAnchorPoint(ccp(0.5,0.5))
        button:setPosition(ccp(0,0))
        icon_node:addChild(button);    
    end
end


--[[--
    初始化
]]
function game_godfield_maspop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData then
        self.m_tGameData = t_params.gameData
        cclog2(self.m_tGameData,"game_godfield_maspop self.m_tGameData ")
        self.rob_list = self.m_tGameData.rob_list or {}
        self.rob_free_times = t_params.rob_free_times or 0
        cclog(self.rob_free_times,"self.rob_free_times--------")
        self.isMine = t_params.isMine
        self.vehicle_captain_uid = self.m_tGameData.enemy
        self.members = self.m_tGameData.members_info
        self.shield = self.m_tGameData.shield
        for k,v in pairs(self.members) do
            self.msg = v
            self.uid = k
        end
        self.goods = self.m_tGameData.goods
        for k,v in pairs(self.goods) do
            self.goods1 = v
        end
        self.goods_table = self.goods1.goods
        for k,v in pairs(self.goods_table) do
            self.gods = v
        end
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_maspop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_maspop;