---  神域押镖
local game_godfield_dart_main = {
    m_reward_ndoe = nil,
    m_null_node = nil,
    m_ship_node = nil,
    m_dart_count_lable = nil,
    m_rob_count_lable = nil,
    m_time_label_1 = nil,
    m_time_label_2 = nil,
    m_rob_btn = nil,
    m_dart_btn = nil,
    m_detail_open_flag = nil,
    m_tGameData = nil,
    nil_ship = nil,
    godfieldescort = nil,
};
--[[--
    销毁ui
]]
function game_godfield_dart_main.destroy(self)
    cclog("----------------- game_dart_main destroy-----------------"); 
    self.m_reward_ndoe = nil;
    self.m_null_node = nil;
    self.m_ship_node = nil;
    self.m_dart_count_lable = nil;
    self.m_rob_count_lable = nil;
    self.m_time_label_1 = nil;
    self.m_time_label_2 = nil;
    self.m_rob_btn = nil;
    self.m_dart_btn = nil;
    self.m_detail_open_flag  = nil;
    self.m_tGameData = nil;
    self.nil_ship = nil;
    self.godfieldescort = nil;
end
--[[--
    返回
]]
function game_godfield_dart_main.back(self)
    game_scene:enterGameUi("game_godfield_mainBig",{});
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_dart_main.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog(btnTag)
        if btnTag == 1 then--返回
            self:back()
        elseif btnTag == 2 then--去打劫
            local function responseMethod( tag,gameData )
               game_scene:enterGameUi("game_godfield_dart_route",{gameData=gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_all_map"), http_request_method.GET, nil,"god_field_escort_all_map")
        elseif btnTag == 3 or btnTag == 101 then--去运货
            if self.nil_ship == 0 then
                game_util:addMoveTips( {text = "Đội đã đầy, không thể tạo!"})
                return
            elseif self.m_tGameData.vehicle_close < 0 then
                game_util:addMoveTips( {text = "Còn chưa đầy 20p, không thể vào!"})
                return 
            else
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_godfield_dart_shop",{gameData = gameData,squad = self.nil_ship});
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_shop_index"), http_request_method.GET, nil,"god_field_escort_shop_index")
            end
        elseif btnTag == 4 then--仇人

        elseif btnTag == 102 then--详情
            game_scene:addPop("game_godfield_despop",{notice=self.m_tGameData["notice"]})
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_dart_main.ccbi");
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScaleX(resolution_config:getScale())
    
    self.m_reward_ndoe = ccbNode:nodeForName("reward_ndoe")--奖励
    self.m_null_node = ccbNode:nodeForName("null_node")--暂无货船
    self.m_ship_node = ccbNode:nodeForName("Ship_node")--货船信息
    self.m_dart_count_lable = ccbNode:labelTTFForName("dart_count_lable")
    self.m_rob_count_lable = ccbNode:labelTTFForName("rob_count_lable")
    self.m_time_label_1 = ccbNode:labelTTFForName("m_time_label_1")
    self.m_time_label_1:setVisible(false)
    self.m_time_label_2 = ccbNode:labelTTFForName("m_time_label_2")
    self.m_time_label_2:setVisible(false)
    self.m_rob_btn = ccbNode:controlButtonForName("m_rob_btn")
    self.m_dart_btn = ccbNode:controlButtonForName("m_dart_btn")
    return ccbNode;
end
--[[
    创建货船列表
]]
function game_godfield_dart_main.createShipList( self,viewSize )
    local pos = {0.82,0.5,0.18}
    local god = self.godfieldescort
    local route = {}
    route[1]="Nguyên Sơ"
    route[2]="Nguyên Lực"
    route[3]="Nguyên Tố"
    route[4]="Linh Tính"
    route[5]="Sức Mạnh"
    route[6]="Lý Tính"
    if god == nil then
        self.m_null_node:setVisible(true)
        self.nil_ship = 1
        return
    else
        local list = {}
        for k,v in pairs(god) do
            print(k,v)
        end
        for i=1,3 do
            if god[tostring(i)] == nil and self.nil_ship == 0 then
                self.nil_ship = i
            elseif god[tostring(i)] ~= nil then
                list[#list+1] = god[tostring(i)] 
            end
        end
        self.m_null_node:setVisible(false)
        for i=1,#list do
            local ship_cfg = list[i]
            local time = ship_cfg.arrive_time
            local un_id = ship_cfg.map_id
            local goods = ship_cfg.goods
            local un = route[un_id]
            local ccbNode = luaCCBNode:create()
            ccbNode:openCCBFile("ccb/ui_godfield_dart_list_item.ccbi")
            local sp_node = ccbNode:nodeForName("sp_node")
            local timelable = ccbNode:labelTTFForName("timelable")
            local unilable = ccbNode:labelTTFForName("unilable")
            local bg_sp = ccbNode:spriteForName("bg_sp")
            bg_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("banner" .. i .. ".png"));
            local time = ship_cfg.arrive_time
            local tiems = string.format("%02d:%02d", math.floor(time/60), math.floor(time%60))
            timelable:setString(tostring(tiems))
            unilable:setString(un)
            local goods = list[i].goods.goods
            local imtecfg=goods[1]
            local icon ,name , count = game_util:getRewardByItemTable(imtecfg);
            if icon then
                local function onBtnClick( event, target)
                    game_util:lookItemDetal( imtecfg )
                end
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setScale(0.8)
                local pos = sp_node:getContentSize()
                icon:setPosition(ccp(pos.width/2,pos.height/2))
                sp_node:addChild(icon,10,10)
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnClick)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition( icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5 )
                button:setOpacity(0)
                button:setTag(i)
                icon:addChild(button)
            end
            local y = viewSize.height*pos[i]
            local x = viewSize.width*0.5
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(x+25,y))
            self.m_ship_node:addChild(ccbNode)
        end
    end
end
function game_godfield_dart_main.createRewardList( self ,viewSize)
    local rewardlist = self.m_tGameData.reward
    local pox = viewSize.width/#rewardlist
    function onBtnCilck( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        game_util:lookItemDetal( rewardlist[btnTag] )
    end
    for i=1,#rewardlist do
        local icon ,name , count = game_util:getRewardByItemTable(rewardlist[i]);
        if icon then
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setPosition(ccp(pox*i-pox/2,viewSize.height/2))
            icon:setScale(0.7)
            self.m_reward_ndoe:addChild(icon)
        
            if name and count then
                local labelName = game_util:createLabelBMFont({text = name .. "x" .. count, fontSize = 22, color = ccc3(255, 255, 255)})
                labelName:setAnchorPoint(ccp(0.5, 1))
                labelName:setPosition(icon:getContentSize().width * 0.5,  0 )
                icon:addChild(labelName, 10)
            end
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition( icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5 )
                button:setOpacity(0)
                button:setTag(i)
                icon:addChild(button)
        end
    end
end

--[[--
    刷新ui
]]
function game_godfield_dart_main.refreshUi(self)
    self.m_ship_node:removeAllChildrenWithCleanup(true)
    self:createShipList(self.m_ship_node:getContentSize())
    self:createRewardList(self.m_reward_ndoe:getContentSize())
    local msg = self.m_tGameData.msg or ""
    local weekly_rob_times = self.m_tGameData.weekly_rob_times or 0 --每周抢劫总次数
    local weekly_escort_times = self.m_tGameData.weekly_escort_times or 0 --每周运镖总次数
    if weekly_rob_times and weekly_escort_times then
        self.m_rob_count_lable:setString(weekly_rob_times .."lần")
        self.m_dart_count_lable:setString(weekly_escort_times .."lần")
    end
end
--[[--
    初始化
]]
function game_godfield_dart_main.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {}
    end
    if self.m_tGameData.godfieldescort then
        self.godfieldescort = self.m_tGameData.godfieldescort
    end
    self.m_detail_open_flag =false;
    self.nil_ship = 0;
end
--[[--
    创建ui入口并初始化数据
]]
function game_godfield_dart_main.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_godfield_dart_main