--新大富翁排行
local ui_newRichMan_mainRank_pop = {
    m_tGameData = nil,
    m_node_tableView = nil,
    m_bossID = nil,
    m_label_hurt = nil,
    m_rankType = nil,
    m_sprite_anyThing = nil,
    m_select_index = nil,
    m_rank_page = nil,
    m_rank_data = nil,
    m_node_btn = nil,
};
--[[--
    销毁ui
]]
function ui_newRichMan_mainRank_pop.destroy(self)
    -- body
    cclog("-----------------ui_newRichMan_mainRank_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_node_tableView = nil;
    self.m_bossID = nil;
    self.m_label_hurt = nil;
    self.m_rankType = nil;
    self.m_sprite_anyThing = nil;
    self.m_select_index = nil;
    self.m_rank_page = nil;
    self.m_rank_data = nil;
    self.m_node_btn = nil;
end
local typeName = {"slots","energy","donation","prison","boss","boss","boss"}
local btnNameTab = {"ui_newRichMan_rank_btnRun.png","ui_newRichMan_rank_btnTili.png","ui_newRichMan_rank_btnTyrant.png","ui_newRichMan_rank_btnClose.png","ui_newRichMan_rank_btnBoss1.png","ui_newRichMan_rank_btnBoss2.png","ui_newRichMan_rank_btnBoss3.png"}
local bossIDTab = {"3800090","4800090","5800090"}
--[[--
    返回
]]
function ui_newRichMan_mainRank_pop.back(self,type)
	game_scene:removePopByName("ui_newRichMan_mainRank_pop")
end
--[[--
    读取ccbi创建ui
]]
function ui_newRichMan_mainRank_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if self.m_animFlag == true then
            return
        end
        cclog2(btnTag,"btnTag ==== ")
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag > 100 and btnTag < 105 then
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_newRichMan_mainRank.ccbi");
    
    self.m_node_tableView = ccbNode:nodeForName("m_node_tableView")
    self.m_sprite_anyThing = ccbNode:spriteForName("m_sprite_anyThing")
    self.m_label_hurt = ccbNode:labelTTFForName("m_label_hurt")
    local m_close_btn = ccbNode:controlButtonForName("m_btn_back")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_node_btn = ccbNode:nodeForName("m_node_btn")

    local viewSize =  self.m_node_btn:getContentSize()
    self.m_node_btn:removeAllChildrenWithCleanup(true)
    local textTableTemp = self:createBtnTableView(viewSize)
    textTableTemp:setScrollBarVisible(false)
    self.m_node_btn:addChild(textTableTemp,10,10)

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
function ui_newRichMan_mainRank_pop.createBtnTableView(self, viewSize )
    local function onCellClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
    end
    local selectImg = {}
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.totalItem = 7
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
           -- cclog("new index ================================" .. index);
           cell = CCTableViewCell:new()
           cell:autorelease()
           local ccbNode = luaCCBNode:create()    
           ccbNode:registerFunctionWithFuncName("onCellClick",onCellClick);        
           ccbNode:openCCBFile("ccb/ui_newRichMan_mainRank_btnitem.ccbi")
           ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
           cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_btn_rank = ccbNode:controlButtonForName("m_btn_rank")
            m_btn_rank:setTag(index + 1)
            -- m_btn_rank:setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
            local m_sprite_select = ccbNode:spriteForName("m_sprite_select")
            if index + 1 == self.m_select_index then
                m_sprite_select:setVisible(true)
            else
                m_sprite_select:setVisible(false)
            end
            local btnName = btnNameTab[index + 1]
            game_util:setCCControlButtonBackground(m_btn_rank,btnName)
            selectImg[index + 1] = m_sprite_select
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            if self.m_select_index == index + 1 then
                return
            end
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
            local m_sprite_select = ccbNode:spriteForName("m_sprite_select")
            for k,v in pairs(selectImg) do
                v:setVisible(false)
            end
            m_sprite_select:setVisible(true)
            if self.m_select_index ~= index + 1 then
                self.m_rank_page = 0
                self.m_rank_data = {}
            end
            self.m_select_index = index + 1
            -- cclog2(self.m_select_index,"click  index ==== ")
            self:refrshData(index + 1)
           
        end
       -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
    end
    return TableViewHelper:create(params);
end
function ui_newRichMan_mainRank_pop.createTableView(self, viewSize )
    local data = {}
    data = self.m_rank_data
    local totalCount = game_util:getTableLen(data)
	local params = {};
	params.viewSize = viewSize;
	params.row = 4;--行
	params.column = 1; --列
	params.totalItem = totalCount
	params.direction = kCCScrollViewDirectionVertical;
	params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
	local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
	params.newCell = function(tableView,index) 
	    local cell = tableView:dequeueCell()
	    if cell == nil then
	       cell = CCTableViewCell:new()
	       cell:autorelease()
	       local ccbNode = luaCCBNode:create()    
	       ccbNode:openCCBFile("ccb/ui_newRichMan_mainRank_item.ccbi")
	       ccbNode:setPosition(ccp(itemSize.width*0.4+8,itemSize.height*0.5));
	       cell:addChild(ccbNode,10,10);
	    end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local curdata = data[index + 1]
            local name = ""
            local guildName = ""
            local hurt = ""
            local roleId = 1
            local lv = ""
            if curdata then
                name = curdata.name
                guildName = curdata.server_id
                hurt = curdata.score
                roleId = curdata.role_id
                lv = curdata.level
            end
            local m_label_anything = ccbNode:labelTTFForName("m_label_anything")
            local m_label_name = ccbNode:labelTTFForName("m_label_name")
            local m_label_lv = ccbNode:labelTTFForName("m_label_lv")
            local m_sprite_rank = ccbNode:spriteForName("m_sprite_rank") 
            m_sprite_rank:setVisible(false)
            local m_sprite_bg1 = ccbNode:spriteForName("m_sprite_bg1") 
            local m_sprite_bg2 = ccbNode:spriteForName("m_sprite_bg2") 
            local m_node_hero = ccbNode:nodeForName("m_node_hero")
            local m_node_rank = ccbNode:nodeForName("m_node_rank")

            if index + 1 < 4 then
               m_sprite_bg1:setVisible(true)
               m_sprite_bg2:setVisible(false)
            else
               m_sprite_bg1:setVisible(false)
               m_sprite_bg2:setVisible(true)
            end
            self:createNum(m_node_rank, index + 1)
            self:createRoleIcon(m_node_hero,roleId)
            m_label_name:setString(guildName .. "-" .. name)
            m_label_lv:setString(lv)
            m_label_anything:setString(hurt)

            if self.m_rankType ~= "boss" then
                if index == totalCount - 1 and index >3 then
                    local tipLabel = game_util:createLabelTTF({text = "Kéo tạo mới",color = ccc3(250,180,0),fontSize = 12});
                    tipLabel:setAnchorPoint(ccp(0.5,0.5))
                    tipLabel:setPosition(ccp(itemSize.width*0.5,-20))
                    cell:addChild(tipLabel,20,20)
                else
                    local tempNode = cell:getChildByTag(20)
                    if tempNode then
                        tempNode:removeFromParentAndCleanup(true)
                    end
                end
            else
            end
	    end
	    return cell;
	end
	params.itemOnClick = function(eventType,index,item)
        -- cclog("-------------------zzz---------")
    	if eventType == "ended" and item then
        elseif eventType == "refresh" and item and self.m_rankType ~= "boss" then
            -- cclog("ssssss")
            self.m_rank_page = self.m_rank_page + 1
            self:requestForHttp()
        end
	   -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
	end
	return TableViewHelper:create(params);
end

--[[
    请求排行榜
]]
function ui_newRichMan_mainRank_pop.requestForHttp(self)
    local params = {}
    params.page = self.m_rank_page
    params.tp = self.m_rankType
    if self.m_rankType == "boss" then
        -- cclog2(self.m_select_index - 3,"self.m_select_index - 3 === ")
        params.boss_id = bossIDTab[self.m_select_index - 4]
    end
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
        for i=1,#self.m_tGameData.info do
            table.insert(self.m_rank_data,self.m_tGameData.info[i])
        end
        self:refreshUi()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_top"), http_request_method.GET, params ,"monopoly_top")
end

function ui_newRichMan_mainRank_pop.createRoleIcon( self, parentNode, roleId, name )
    parentNode:removeAllChildrenWithCleanup(true)
    local roleId = roleId or 1 
    local sprite_head = game_util:createRoleBigImgHalf(roleId)
    sprite_head:setScale(0.4)
    sprite_head:setAnchorPoint(ccp(0.5, 0.5))
    sprite_head:setPosition(ccp(0,0))
    parentNode:addChild(sprite_head)
end
function ui_newRichMan_mainRank_pop.refrshData( self,sort )
    self.m_rankType = typeName[sort]
    local params = {}
    params.tp = typeName[sort]
    params.page = self.m_rank_page

    if self.m_rankType == "boss" then
        params.boss_id = bossIDTab[self.m_select_index - 4]
        -- cclog2(params.boss_id,"params.boss_id === ")
        local function responseMethod( tag,gameData )
            self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
            for i=1,#self.m_tGameData.info do
                table.insert(self.m_rank_data,self.m_tGameData.info[i])
            end
            self:refreshUi()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_top"), http_request_method.GET, params,"monopoly_top")
    else
        local function responseMethod( tag,gameData )
             self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
             for i=1,#self.m_tGameData.info do
                 table.insert(self.m_rank_data,self.m_tGameData.info[i])
             end
             self:refreshUi()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_top"), http_request_method.GET, params,"monopoly_top")
    end
end
function ui_newRichMan_mainRank_pop.createNum( self,node,num )
   num = tonumber(num)
   node:removeAllChildrenWithCleanup(true);
   if num >= 10 and num < 100 then
       local high = math.floor(num / 10)
       local low = math.floor(num % 10)

       local num_1 = CCSprite:createWithSpriteFrameName("vip_num_" .. high .. ".png")
       local num_2 = CCSprite:createWithSpriteFrameName("vip_num_" .. low .. ".png")

       num_1:setAnchorPoint(ccp(0.5,0.5))
       num_2:setAnchorPoint(ccp(0.5,0.5))

       num_1:setPosition(ccp(-2,0))
       num_2:setPosition(ccp(10,0))
       num_1:setScale(0.5)
       num_2:setScale(0.5)
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
           num_sprite:setScale(0.4)
           num_sprite:setAnchorPoint(ccp(0.5,0.5))
           num_sprite:setPosition(ccp(-7+(i-1)*8,0))
           node:addChild(num_sprite,10)
       end
   else
    local num_sprite = nil
        if num > 3 then
            num_sprite = CCSprite:createWithSpriteFrameName("vip_num_" .. num .. ".png")
            num_sprite:setScale(0.75)
        else 
            local numName = "ui_newRichMan_rank_rank" .. num .. ".png"
            num_sprite = CCSprite:createWithSpriteFrameName(numName)
        end
        num_sprite:setAnchorPoint(ccp(0.5,0.5))
        num_sprite:setPosition(ccp(10,0))
        node:addChild(num_sprite,10)
   end
end

--[[--
    刷新ui
]]
function ui_newRichMan_mainRank_pop.refreshUi(self)

    if self.m_rankType == "boss" then
        self.m_sprite_anyThing:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_newRichMan_rank_titleHurt.png"))
    elseif self.m_rankType == "prison" then
        self.m_sprite_anyThing:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_newRichMan_rank_titleClose.png"))
    elseif self.m_rankType == "slots"  then
        self.m_sprite_anyThing:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_newRichMan_rank_titleNum.png"))
    elseif self.m_rankType == "energy"  then
        self.m_sprite_anyThing:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_newRichMan_rank_titleAcPoint.png"))
    elseif self.m_rankType == "donation"  then --膜拜
        self.m_sprite_anyThing:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_newRichMan_rank_titleTyrant.png"))
    end

	local hurt = 0
    local viewSize =  self.m_node_tableView:getContentSize()
    self.m_node_tableView:removeAllChildrenWithCleanup(true)
    local textTableTemp = self:createTableView(viewSize)
    textTableTemp:setScrollBarVisible(false)
    self.m_node_tableView:addChild(textTableTemp,10,10)

    local index = self.m_rank_page * 10
    game_util:setTableViewIndex(index,self.m_node_tableView,10,4)
end
--[[--
    初始化
]]
function ui_newRichMan_mainRank_pop.init(self,t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_vip.plist")

    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    if t_params.bossID then
    	self.m_bossID = t_params.bossID
    end
    self.m_rankType = "slots"
    self.m_select_index = 1
    self.m_rank_page = 0
    self.m_rank_data = {}
    for i=1,#self.m_tGameData.info do
        table.insert(self.m_rank_data,self.m_tGameData.info[i])
    end

end
--[[--
    创建ui入口并初始化数据
]]
function ui_newRichMan_mainRank_pop.create(self,t_params)
    self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi();

    return  m_popUi;
end
return ui_newRichMan_mainRank_pop;