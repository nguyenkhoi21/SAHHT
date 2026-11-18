---  神域押镖飞船选择
local game_godfield_dart_Shipsel = {
    isProtect = nil,
    m_list_view_bg = nil,
    des_lable = nil,
    count_lb = nil,
    sp_node = nil,
    m_tGameData = nil,
    good_id = nil,
    m_tickFlag = nil,
    check_id = nil,
    my_team = nil,
};
--[[--
    销毁ui
]]
function game_godfield_dart_Shipsel.destroy(self)
    cclog("----------------- game_godfield_dart_Shipsel destroy-----------------"); 
    self.isProtect = nil;
    self.m_list_view_bg= nil;
    self.des_lable= nil;
    self.count_lb = nil;
    self.sp_node = nil;
    self.m_tGameData = nil;
    self.good_id = nil;
    self.m_tickFlag = nil;
    self.check_id = nil;
    self.my_team = nil;
end

--[[--
    返回
]]
function game_godfield_dart_Shipsel.back(self)
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_godfield_dart_shop",{gameData = gameData});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_shop_index"), http_request_method.GET, nil,"god_field_escort_shop_index")
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_dart_Shipsel.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog(btnTag)
        if btnTag == 5 then
            self.my_team.buff_sort=self.check_id
            self.my_team.shield = self.isProtect
            local function responseMethod(tag,gameData)
                -- game_scene:addPop("game_godfield_dart_hire_pop",{gameData = gameData,my_team = self.my_team,open ="escort"})
                game_scene:addPop("game_godfield_dart_pop",{gameData = gameData,my_team = self.my_team,open ="escort"})
            end
            params={}
            params.keys = self.my_team.squad
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("god_field_escort_employ_ground"), http_request_method.GET,params,"god_field_escort_employ_ground")
        elseif btnTag == 1 then
            self:back()
        elseif btnTag == 2 then   
            if self.isProtect == 0 then 
                self.isProtect = 1
                self.fanghu:setVisible(true)
                if self.shield_num > 0 then
                    game_util:addMoveTips({text = "Dùng Tấm Chắn bảo vệ thuyền? Nhấp lần nữa hủy"})
                    self.count_lb:setString(self.shield_num-1 .. "Một")
                else
                   game_util:addMoveTips({text = "Bạn tốn" .. self.m_tGameData.coin .. "Xu mua Tấm Chắn bảo vệ thuyền, nhấp lần nữa hủy"}) 
                end
            elseif self.isProtect == 1 then
                self.isProtect = 0    
                self.fanghu:setVisible(false)
                game_util:addMoveTips({text = "Đã hủy Tấm Chắn"})
                if self.shield_num > 0 then
                    self.count_lb:setString(self.shield_num .. " cái")
                end
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_dart_shipsele.ccbi");
    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg")
    self.des_lable = ccbNode:labelTTFForName("des_lable")
    self.count_lb = ccbNode:labelTTFForName("count_lb") --防护罩数量
    self.sp_node = ccbNode:nodeForName("sp_node")
    self.shiled = ccbNode:spriteForName("shiled") --当前神域文字
    self.gold_sp = ccbNode:spriteForName("gold_sp")--钻石
    self.gold_cost = ccbNode:labelTTFForName("gold_cost") --花费钻石数
    if self.shield_num > 0 then
        self.count_lb:setVisible(true)
        self.count_lb:setString(self.shield_num)
        self.shiled:setVisible(true)
        self.gold_sp:setVisible(false)
        self.gold_cost:setVisible(false)
    else
        self.count_lb:setVisible(false)
        self.shiled:setVisible(false)
        self.gold_sp:setVisible(true)
        self.gold_cost:setVisible(true)
        self.gold_cost:setString(self.m_tGameData.coin)
    end
    self.fanghu = CCSprite:create("icon/icon_fanghu.png")
    self.fanghu:setScale(0.8)
    self.fanghu:setVisible(false)
    self.fanghu:setAnchorPoint(ccp(0.5,0.5))
    self.fanghu:setPosition(ccp(0,0))
    self.sp_node:addChild(self.fanghu,100,100)
    local cfg = self.m_tGameData[tostring(self.check_id)]
    self.des_lable:setString(cfg.des2)
    return ccbNode;
end




function game_godfield_dart_Shipsel.createShipList(self,viewSize)
    local select_list = {}
    local params = {}
    params.viewSize = viewSize
    params.row = 1
    params.column = 5;
    params.direction = kCCScrollViewDirectionHorizontal
    params.totalItem = 5
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1
    local itemSize = CCSizeMake(viewSize.width/5,viewSize.height/params.row)
    params.newCell = function ( tableView,index )
        local imtecfg = self.m_tGameData[tostring(index+1)]
        local cost = imtecfg["cost"]
        local  cell = tableView:dequeueCell()
            cell=CCTableViewCell:new()
            cell:autorelease()
            local ccbNod = luaCCBNode:create()
            ccbNod:openCCBFile("ccb/ui_godfield_dart_ship_item.ccbi")
            ccbNod:setScale(0.85)
            ccbNod:setAnchorPoint(ccp(0.5,0.5))
            ccbNod:setPosition(ccp(itemSize.width/2,itemSize.height/2))
            cell:addChild(ccbNod,10,10)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local item_sp = ccbNod:spriteForName("item_sp")
            item_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_ship_" .. index+1 .. ".png"));
            local select_sp = ccbNod:spriteForName("select_sp")
            select_list[#select_list+1] = select_sp
            local m_count = ccbNod:labelTTFForName("m_count")
            for k,v in pairs(cost) do
               local itemcfg = v

                local icon ,name , count = game_util:getRewardByItemTable(itemcfg);
                m_count:setString(name .. "×" .. count)
            end
            if index+1 == self.check_id then
                select_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("select_02.png"));
            else
                select_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("select_01.png"));
            end
            cell:setTag(index+1)
        return cell
    end
    params.itemOnClick = function (eventType, index,item )
        if eventType == "ended" and item then
            self.check_id = index + 1
            self:refreshUi()
            local cfg = self.m_tGameData[tostring(index+1)]
            self.des_lable:setString(cfg.des2)
        end
    end
    return TableViewHelper:create(params)
end
function game_godfield_dart_Shipsel.refreshUi( self )
    self.m_list_view_bg:removeAllChildrenWithCleanup(true)
    self.m_list_view_bg:addChild(self:createShipList(self.m_list_view_bg:getContentSize()),10,10)
    -- game_util:setTableViewIndex(self.check_id,self.m_list_view_bg,10,4)
end
--[[--
    初始化

]]
function game_godfield_dart_Shipsel.init(self,t_params)
    t_params = t_params or {}
    self.my_team = t_params.my_team
    if t_params.gameData ~= nil then
        if tolua.type(t_params.gameData) == "util_json" then
            local data = t_params.gameData:getNodeWithKey("data");
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            self.vehicle_is_ready = self.m_tGameData.vehicle_is_ready or false
        else
            self.m_tGameData = t_params.gameData;
        end
    else
        self.m_tGameData = {};
    end
    self.shield_num = self.m_tGameData.shield_num
    self.check_id = 1;
    self.isProtect = 0;
end
--[[--
    创建ui入口并初始化数据
]]

function game_godfield_dart_Shipsel.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_godfield_dart_Shipsel