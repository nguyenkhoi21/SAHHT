--英魂抽取
local game_soul_gacha={
	m_look_btn = nil,
	m_use_btn = nil,
	m_guize_btn = nil,
	m_purple_btn = nil,
	m_select_btn = nil,
	m_superSelect_btn = nil,
	m_zuanshi_lab = nil,
	m_need_food = nil,
	m_show_node = nil,
	circle_center = nil,
    m_ower_food= nil,
    statue =nil,

}

--[[--
    销毁ui
]]
function game_soul_gacha.destroy( self )
	-- body
	cclog("-----------------game_soul_gacha destroy-----------------");
	self.m_look_btn = nil;
	self.m_use_btn = nil;
	self.m_guize_btn = nil;
	self.m_purple_btn = nil;
	self.m_select_btn = nil;
	self.m_superSelect_btn = nil;
    self.m_zuanshi_lab = nil;
	self.m_need_food = nil;
	self.m_show_node = nil;
	self.circle_center = nil;
    self.m_ower_food= nil;
    self.statue=nil;
end

--[[--
    返回
]]
function game_soul_gacha.back(self,type)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_soul_gacha.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 104 then --附魂(进到阵型界面)   
            game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_main_scene"});
            self:destroy();
        elseif btnTag == 105 then --详情
            game_scene:addPop("game_active_limit_detail_pop",{enterType = "163"})
        elseif btnTag == 106 then --紫色同步
            local function responseMethod(tag, gameData )
                local data = gameData:getNodeWithKey("data")
                self.gameData = json.decode(data:getFormatBuffer()) or {}
                self.index = self.gameData.soul_rate
                -- self:setCircleByIndex();
                local statue = self.gameData.statue --神像
                local gacha_id = tonumber(statue .. 0 .. self.index)
                local foodTab = json.decode((getConfig(game_config_field.soul_gacha):getNodeWithKey(tostring(gacha_id))):getFormatBuffer()) or {}
                local need_food = foodTab.need_meet
                self.m_need_food:setString(tostring(need_food) or 1000)-- 获取食物消耗数量
                self:refreshUi()
            end     
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_increase_rate"), http_request_method.GET, nil,"soul_increase_rate")
        elseif btnTag == 107 then --抽取
            local function responseMethod(tag,gameData)
                --cclog2(gameData,"gameData")
                self:createExplode();
                local data = gameData:getNodeWithKey("data")
                local dataTable = json.decode(data:getFormatBuffer()) or {}
                self.index = dataTable.soul_rate  --品质
                self.statue = dataTable.statue --神像
                local gacha_id = tonumber(self.statue .. 0 .. self.index)
                local foodTab = json.decode((getConfig(game_config_field.soul_gacha):getNodeWithKey(tostring(gacha_id))):getFormatBuffer()) or {}
                local need_food = foodTab.need_meet
                self.m_need_food:setString(tostring(need_food) or 1000)-- 获取食物消耗数量
                self.add = 1   --数量
                local key =dataTable.reward.soul[1]
                local souldata = game_data:getSoulDataById(key)
                self.soul_id=souldata.s_id
                -- self.soul_table[#self.soul_table+1] = self.soul_id
                self.count = #self.soul_table
                if #self.soul_table >= 15 then
                    self.soul_table = {}
                end
                table.insert(self.soul_table,self.soul_id)
                --cclog2(self.count,"self.count======")
                -- if self.cleanFlag then
                --     self:cleanAll();
                -- else
                --     self:createSoulByData();
                -- end
                self:createSoulAnim(2)
                self:refreshUi()
            end   
            local statue_id = self.statue
            local params = {}
            params.statue_id = statue_id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_soul_gacha"), http_request_method.GET, params,"soul_index")
        elseif btnTag == 108 then --强力抽取
            local function responseMethod(tag, gameData )
                self:createExplode();
                local data = gameData:getNodeWithKey("data")
                local dataTable = json.decode(data:getFormatBuffer()) or {}
                self.index = dataTable.soul_rate  --品质
                -- for i=1,#dataTable.reward.soul  do
                --     local key =dataTable.reward.soul[i]
                --     local souldata = game_data:getSoulDataById(key)
                --     self.soul_id=souldata.s_id
                --     self.soul_table[#self.soul_table+1] = self.soul_id
                
                --     self.add = #self.soul_table  --添加数量
                --     self.count = #self.soul_table
                --     if self.cleanFlag then
                --         self:cleanAll();
                --     else
                --         self:createSoulByData();
                --     end
                -- end
                self.soul_table = {}
                for i=1,#dataTable.reward.soul  do
                    local key =dataTable.reward.soul[i]
                    local souldata = game_data:getSoulDataById(key)
                    self.soul_id=souldata.s_id
                    table.insert(self.soul_table,self.soul_id)
                end
                -- self.soul_table = dataTable.reward.soul
                self:createSoulAnim()
                self.soul_table = {}
                self:refreshUi()

                if self.statue ~=nil and self.index ~= nil then
                    -- cclog2(self.statue,"self.statue" .. self.index,"self.index")
                    local gacha_id = tonumber(self.statue .. 0 .. self.index)
                    local foodTab = json.decode((getConfig(game_config_field.soul_gacha):getNodeWithKey(tostring(gacha_id))):getFormatBuffer()) or {}
                    local need_food = foodTab.need_meet
                    self.m_need_food:setString(tostring(need_food) or 1000)-- 获取食物消耗数量
                end
            end 
            local statue_id = self.statue
            local params = {}
            params.statue_id = statue_id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_soul_gacha10"), http_request_method.GET, params,"soul_index")
        elseif btnTag == 109 then --英魂容器
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_soul_list",{gameData = gameData});
                self:destroy();
             end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_all_soul"), http_request_method.GET, nil,"soul_index")   
        elseif btnTag == 110 then --英魂图鉴
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_soul_illustrated_pop",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("soul_book"), http_request_method.GET, nil,"soul_book")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_soul_get.ccbi");
	self.m_use_btn = ccbNode:controlButtonForName("m_use_btn");--附魂
	self.m_guize_btn = ccbNode:controlButtonForName("m_guize_btn");--活动详情
	self.m_zise_btn = ccbNode:controlButtonForName("m_purple_btn");--紫色同步
	self.m_select_btn = ccbNode:controlButtonForName("m_select_btn");--抽取
	self.m_superSelect_btn = ccbNode:controlButtonForName("m_superSelect_btn");--强抽
	self.m_zuanshi_lab = ccbNode:labelTTFForName("m_zuanshi_lab");--消耗钻石数
	self.m_need_food = ccbNode:labelTTFForName("m_need_food");--消耗食物
	self.m_show_node = tolua.cast(ccbNode:objectForName("m_show_node"), "CCNode");--抽取展示
	self.circle_center = ccbNode:nodeForName("circle_center");

    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScale(resolution_config:getScale())
    
    local nametable = {"baiqiu","lvqiu","lanqiu","ziqiu","chengqiu"}
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        animNode:playSection(theLabelName);
    end
     for i = 1,5,1 do
        self["icon_"..i] = ccbNode:spriteForName("icon_"..i)
        local size =  self["icon_"..i]:getContentSize();
        local anime1 = game_util:createBlenderAnim(nametable[i],1,true);
        anime1:registerScriptTapHandler(onAnimSectionEnd)
        anime1:setPosition(ccp(size.width*0.5,size.height*0.5))
        anime1:playSection("impact@1")
        self["icon_"..i]:addChild(anime1)
        local anime2 = game_util:createBlenderAnim(nametable[i],2,true);
        anime2:registerScriptTapHandler(onAnimSectionEnd)
        anime2:setPosition(ccp(size.width*0.5,size.height*0.5))
        anime2:playSection("impact@a")
        --game_anim:playSection(anime2 , "impact@a");
        self["icon_"..i]:addChild(anime2)
    end
    self.m_show_node = ccbNode:nodeForName("m_show_node")
    self.m_ower_food = ccbNode:labelTTFForName("m_ower_food")
    
    if self.statue ~=nil and self.index ~= nil then
        local gacha_id = tonumber(self.statue .. 0 .. self.index)
        local foodTab = json.decode((getConfig(game_config_field.soul_gacha):getNodeWithKey(tostring(gacha_id))):getFormatBuffer()) or {}
        local need_food = foodTab.need_meet
        self.m_need_food:setString(tostring(need_food) or 1000)-- 获取食物消耗数量
    end            
    return ccbNode;
end

function game_soul_gacha:refreshUi( )
    self:setCircleByIndex()

    
    self.m_ower_food:setString(game_data:getUserStatusDataByKey("food") or 1)

    local PayCfg = getConfig(game_config_field.pay):getNodeWithKey("40"):getNodeWithKey("coin")
    local buyTimes = self.gameData.soul_times
    local payValue = 0
    if buyTimes >= PayCfg:getNodeCount() then
        payValue = PayCfg:getNodeAt(PayCfg:getNodeCount()-1):toInt()
    else
        payValue = PayCfg:getNodeAt(buyTimes):toInt()
    end
    -- cclog2(buyTimes,"buyTimes======")
    -- cclog2(payValue,"payValue======")
    self.m_zuanshi_lab:setString(payValue)
end

function game_soul_gacha:initPos(  )
  -- body
    local R = 590/2
    local a = 270
    for i = 1,5,1 do
        if i == self.index then
            a = 270 
        else
            -- a = 270 + math.abs(i - self.m_control.m_model.index)/(i - self.m_control.m_model.index) *(40 - 60/(2+math.abs(i - self.m_control.m_model.index)))
            a = 270 + (i - self.index)*(15-math.abs(i - self.index)*1)
        end
        print("x==="..R*math.cos(math.rad(a))..";y==="..R*math.sin(math.rad(a))..";"..tostring(self["icon_"..i]))
        self["icon_"..i]:setPosition(ccp(R*math.cos(math.rad(a)),R*math.sin(math.rad(a))))
        self["icon_"..i]:setScale(math.pow(0.88,math.abs(i - self.index)))
    end

end

function game_soul_gacha:setCircleByIndex(  )
    print("setCircleByIndex"..self.index)
    local R = 590/2
    local a = 270
    for i = 1,5,1 do
        if i == self.index then
            a = 270 
        else
            -- a = 270 + math.abs(i - self.m_control.m_model.index)/(i - self.m_control.m_model.index) *(40 - 60/(2+math.abs(i - self.m_control.m_model.index)))
            a = 270 + (i - self.index)*(15-math.abs(i - self.index)*1)
        end
        self["icon_"..i]:stopAllActions();
        print("x==="..R*math.cos(math.rad(a))..";y==="..R*math.sin(math.rad(a))..";"..tostring(self["icon_"..i]))
        self["icon_"..i]:runAction(CCMoveTo:create(0.2,ccp(R*math.cos(math.rad(a)),R*math.sin(math.rad(a))))  )
        self["icon_"..i]:runAction(CCScaleTo:create(0.2,math.pow(0.88,math.abs(i - self.index))) )  
    end
end

function game_soul_gacha:cleanAll(  )
  -- body
    local array = self.m_show_node:getChildren();
    local count = self.m_show_node:getChildrenCount();
    local size = self.m_show_node:getContentSize();
    for i = 1,count,1 do
        local object = tolua.cast(array:objectAtIndex(i-1),"CCSprite");
        object:runAction(CCMoveTo:create(0.1,ccp(size.width*0.66,size.height*1.7)))
    end
    local function newFunc(node)
        self.m_show_node:removeAllChildrenWithCleanup(true);
        self.cleanFlag = false
        self:createSoulByData();
    end
    local animArr = CCArray:create();
    animArr:addObject(CCDelayTime:create(0.1))
    animArr:addObject(CCCallFuncN:create(newFunc));
    self.m_show_node:runAction(CCSequence:create(animArr))
end

--[[
    创建奖励显示
]]
function game_soul_gacha.createSoulAnim(self,is_anim)
    is_anim = is_anim or 1
    local size = self.m_show_node:getContentSize();
    self.m_show_node:removeAllChildrenWithCleanup(true)

    local cfg = self.soul_detail
    for i=1,#self.soul_table do
        local id = self.soul_table[i]
        local data = json.decode(cfg:getNodeWithKey(tostring(id)):getFormatBuffer()) or {};
        local name = data.name
        local sp = game_util:createSoulAnimeByData(json.decode(cfg:getNodeWithKey(tostring(id)):getFormatBuffer()) or {})
        local label = CCLabelTTF:create(name,TYPE_FACE_TABLE.Arial_BoldMT,10);    --设置名字
        sp:setPosition(ccp(200,-105))
        label:setPosition(ccp(200,-125))
        local quality = data.quality
        label:setColor(HERO_QUALITY_COLOR_TABLE[quality].color)

        local pos1 = ccp(0,0)
        local pos2 = ccp(0,0)
        if i <= 8 then
            pos1 = ccp(size.width*i/9,size.height*1)
            pos2 = ccp(size.width*i/9,size.height*1-20)
        else
            pos1 = ccp(size.width*(i-7.5)/9,size.height*0.25)
            pos2 = ccp(size.width*(i-7.5)/9,size.height*0.25-20)
        end
        if is_anim == 1 then
            sp:runAction(CCMoveTo:create(0.2,pos1) )
            label:runAction(CCMoveTo:create(0.2,pos2) )  
        else
            if i == #self.soul_table then
                sp:runAction(CCMoveTo:create(0.2,pos1) )
                label:runAction(CCMoveTo:create(0.2,pos2) )  
            else
                sp:setPosition(pos1)
                label:setPosition(pos2)
            end
        end
        self.m_show_node:addChild(sp)
        self.m_show_node:addChild(label)
    end
end

function game_soul_gacha:createSoulByData(  )
    -- body
    -- if self.m_control.m_model.cleanFlag then
    --   self.gacha_show_node:removeAllChildrenWithCleanup(true);
    --   self.m_control.m_model.cleanFlag = false
    -- end
    local size = self.m_show_node:getContentSize();
    self.m_show_node:removeAllChildrenWithCleanup(true)
    local lim = math.min(15,self.count)
    local cfg = self.soul_detail
    --cclog2(cfg,"cfg========")
    print("lim---=="..lim..";add=="..self.add..";count===="..self.count)
    --cclog2( self.soul_table," self.soul_table")
    for i = lim-self.add+1,lim,1 do
        --cclog2(self.soul_table,"self.soul_table======")
        local id = self.soul_table[i]
        --cclog2(id,"id======")
        local data = json.decode(cfg:getNodeWithKey(tostring(id)):getFormatBuffer()) or {};
        local name = data.name
        --cclog2(name, "name======")
        local sp = game_util:createSoulAnimeByData(json.decode(cfg:getNodeWithKey(tostring(id)):getFormatBuffer()) or {})
        local label = CCLabelTTF:create(name,TYPE_FACE_TABLE.Arial_BoldMT,10);    --设置名字
        sp:setPosition(ccp(200,-105))
        label:setPosition(ccp(200,-125))
        local quality = data.quality
        label:setColor(HERO_QUALITY_COLOR_TABLE[quality].color)
        if i <= 8 then
          sp:runAction(CCMoveTo:create(0.2,ccp(size.width*i/9,size.height*1)) )
          label:runAction(CCMoveTo:create(0.2,ccp(size.width*i/9,size.height*1-20)) )  
        else
          sp:runAction(CCMoveTo:create(0.2,ccp(size.width*(i-7.5)/9,size.height*0.25)) )
          label:runAction(CCMoveTo:create(0.2,ccp(size.width*(i-7.5)/9,size.height*0.25-20)) )  
          -- sp:setPosition(ccp(size.width*(i-7.5)/9,size.height*0.25))
          -- label:setPosition(ccp(size.width*(i-7.5)/9,size.height*0.25-20))
        end
        self.m_show_node:addChild(sp)
        self.m_show_node:addChild(label)
        if i == 15 then
          self.cleanFlag = true
          self.count = 0
          self.soul_table = {}
        end
    end
end

--小球动画效果
function game_soul_gacha:createExplode(  )
    -- body
    local size =  self["icon_"..self.index]:getContentSize();
    local nametable = {"baiqiu","lvqiu","lanqiu","ziqiu","chengqiu"}
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        animNode:removeFromParentAndCleanup(true);
    end
    local anime1 = game_util:createBlenderAnim(nametable[self.index],1,true);
    anime1:registerScriptTapHandler(onAnimSectionEnd)
    anime1:setPosition(ccp(size.width*0.5,size.height*0.5))
    anime1:playSection("guang@1")
    self["icon_"..self.index]:addChild(anime1)
end

--[[--
    初始化
]]
function game_soul_gacha.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    --cclog2(t_params.soul_rate,"t_params======")
    self.index =t_params.soul_rate
    self.statue = t_params.statue
    --cclog2(t_params.statue,"t_params.statue=====")
    self.count = 0
    self.add = 0
    -- self.m_zuanshi_lab = 0
    self.soul_table = {}
    self.soul_gacha = getConfig(game_config_field.soul_gacha)
    --cclog2(self.soul_gacha,"self.soul_gacha=======")
    self.soul_detail = getConfig(game_config_field.soul_detail)
    self.cleanFlag = false;
    self.pay = getConfig(game_config_field.pay)
    --cclog2(self.pay,"pay")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_yinghun.plist");
    
end

--[[--
    创建ui入口并初始化数据
]]
function game_soul_gacha.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_soul_gacha;

