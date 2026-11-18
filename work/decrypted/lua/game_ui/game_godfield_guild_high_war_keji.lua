---  坠落之地
--- 科技/贡献
local game_godfield_guild_high_war_keji = {
    m_select_index = nil,
};


--[[--
    销毁
]]
function game_godfield_guild_high_war_keji.destroy(self)
    cclog("-----------------game_godfield_guild_high_war_keji destroy-----------------");
    self.m_select_index = nil;
end

--[[--
    返回
]]
function game_godfield_guild_high_war_keji.back(self,type)
    local function responseMethod( tag,gameData )
        game_scene:enterGameUi("game_godfield_guild_high_war_map",{gameData = gameData, group_id = self.m_group_id, map_offset = self.m_map_offset})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_map_index"), http_request_method.GET, {group_id = self.m_group_id},"guild_high_war_map_index")
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_keji.createUi(self)
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/godfield_main_res.plist");
    self.m_select_index = 1
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then --返回
            self:back();
        elseif btnTag == 101 then--科研
            self.m_select_index = 1
            self:refreshUi()
        elseif btnTag == 102 then--贡献
            self.m_select_index = 2
            self:refreshUi()
        elseif btnTag == 200 then--规则
            local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
            local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(7))
            if itemCfg == nil then return end
            local openMsg = itemCfg:getNodeWithKey("des"):toStr();
            game_scene:addPop("game_godfield_detail_pop",{openMsg = openMsg})
        elseif btnTag == 300 then--投入
            if self.m_count_flag == false then
                return game_util:addMoveTips({text = "Đánh nhiều ngày vậy rồi mà sao bạn chẳng có đạo cụ nào vậy?"})
            end
            local guild_high_war_science_cfg = getConfig(game_config_field.guild_high_war_science)
            local lv = math.min(self.m_tGameData.lv + 1, guild_high_war_science_cfg:getNodeCount())
            local science_info = guild_high_war_science_cfg:getNodeWithKey(lv)
            local free_times = science_info:getNodeWithKey("free_num"):toInt() - self.m_tGameData.science_free
            local contribute_type = 2
            if free_times > 0 then
                contribute_type = 1
            end
            local function responseMethod( tag,gameData )
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local data = gameData:getNodeWithKey("data");
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    game_util:addMoveTips({text = "Thêm vào thành công!"})
                end
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_contribute"), http_request_method.GET, {contribute_type = contribute_type},"guild_high_war_contribute")
        elseif btnTag == 400 then--科技排行
            local function responseMethod( tag,gameData )
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    game_scene:addPop("game_godfield_guild_high_war_keji_rank_pop",{gameData = gameData})
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_science_rank"), http_request_method.GET, nil,"guild_high_war_science_rank")
        elseif btnTag >= 601 and btnTag <= 610 then--星星
            game_scene:addPop("game_godfield_guild_high_war_keji_pop",{gameData = {lv = btnTag-600},})
        else

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_keji.ccbi");
    
    self.node_icon = ccbNode:nodeForName("node_icon") 
    self.label_name = ccbNode:labelTTFForName("label_name") -- 联盟名字
    self.label_rank = ccbNode:labelTTFForName("label_rank") -- 当前排名
    self.label_lv = ccbNode:labelTTFForName("label_lv") -- 科技等级
    self.label_des1 = ccbNode:labelTTFForName("label_des1") -- 描述
    self.label_des2 = ccbNode:labelTTFForName("label_des2") -- 描述
    self.label_tips = ccbNode:labelTTFForName("label_tips") -- 描述
    self.m_des_btn = ccbNode:controlButtonForName("m_des_btn") -- 规则按钮
    self.m_rank_btn = ccbNode:controlButtonForName("m_rank_btn") -- 科技排行按钮
    self.m_ky_btn = ccbNode:controlButtonForName("m_ky_btn") -- 科研页签按钮
    local label_ky_btn = ccbNode:labelTTFForName("label_ky_btn")
    label_ky_btn:setString("Nghiên cứu KHKT")
    self.m_gx_btn = ccbNode:controlButtonForName("m_gx_btn") -- 贡献页签按钮
    local label_gx_btn = ccbNode:labelTTFForName("label_gx_btn")
    label_gx_btn:setString("Cống Hiến")

    self.node_keji = ccbNode:nodeForName("node_keji") -- 科研
    local label_1 = ccbNode:labelTTFForName("label_1")
    label_1:setString("Cấp nghiên cứu KHKT")
    self.label_ky_lv = ccbNode:labelTTFForName("label_ky_lv") --科研等级
    self.m_stars = {}
    for i=1,10 do
        self.m_stars[i] = ccbNode:controlButtonForName("m_star_btn"..i)
    end

    self.node_gongxian = ccbNode:nodeForName("node_gongxian") -- 贡献
    self.m_tr_btn = ccbNode:controlButtonForName("m_tr_btn") -- 投入按钮
    self.label_gx_times_str = ccbNode:labelTTFForName("label_gx_times_str")
    
    self.label_gx_times1 = ccbNode:labelTTFForName("label_gx_times1")
    self.label_gx_times2 = ccbNode:labelTTFForName("label_gx_times2")

    self.node_bar = ccbNode:nodeForName("node_bar")
    self.label_gx_lv = ccbNode:labelTTFForName("label_gx_lv") -- 贡献等级
    self.label_gx_p = ccbNode:labelTTFForName("label_gx_p") -- 贡献度%

    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    
    self.m_ccbNode = ccbNode;
    -- self:onEnter();

    self.node_icon:removeAllChildrenWithCleanup(true);
    local icon_str = ""
    if tonumber(self.m_tGameData.icon) > 9 then
        icon_str = self.m_tGameData.icon
    else
        icon_str = "0"..self.m_tGameData.icon
    end
    local guild_icon = CCSprite:create("ccbResources/guild_high_war/" .. "gh_icon"..icon_str..".png");
    self.node_icon:addChild(guild_icon)
    self.label_name:setString(self.m_tGameData.name)

    self.label_rank:setString("XH hiện tại:".. self.m_tGameData.rank_info.self_rank)

    return ccbNode;

end


function game_godfield_guild_high_war_keji:onEnter(  )
    
end

--[[--
    刷新ui
]]
function game_godfield_guild_high_war_keji.refreshUi(self)
    local guild_high_war_science_cfg = getConfig(game_config_field.guild_high_war_science)
    local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
    local lv = math.min(self.m_tGameData.lv + 1, guild_high_war_science_cfg:getNodeCount())

    local des_id1,des_id2
    local science_info1 = guild_high_war_science_cfg:getNodeWithKey(lv)
    local science_info2 = guild_high_war_science_cfg:getNodeWithKey(self.m_tGameData.lv <= 0 and 1 or self.m_tGameData.lv)
    if self.m_select_index == 1 then -- 科研
        self.m_des_btn:setVisible(true)
        game_util:setCCControlButtonBackground(self.m_ky_btn,"godfield_Z7.png")
        game_util:setCCControlButtonBackground(self.m_gx_btn,"godfield_Z6.png")
        self.node_keji:setVisible(true)
        self.node_gongxian:setVisible(false)

        self.label_ky_lv:setString(self.m_tGameData.lv)

        des_id1 = 20
        des_id2 = 21
    else -- 贡献
        self.m_des_btn:setVisible(false)
        game_util:setCCControlButtonBackground(self.m_ky_btn,"godfield_Z6.png")
        game_util:setCCControlButtonBackground(self.m_gx_btn,"godfield_Z7.png")
        self.node_keji:setVisible(false)
        self.node_gongxian:setVisible(true)

        self.label_gx_lv:setString("LV."..self.m_tGameData.lv)

        self.m_ccbNode:nodeForName("node4"):setVisible(false)
        self.m_ccbNode:nodeForName("node5"):setVisible(false)
        self.m_ccbNode:nodeForName("node6"):setVisible(false)
        local science_info_item = json.decode(science_info2:getNodeWithKey("item"):getFormatBuffer())        
        local price = json.decode(science_info2:getNodeWithKey("price"):getFormatBuffer())
        local node = self.m_ccbNode:nodeForName("node"..#science_info_item)
        node:setVisible(true)
        self.m_count_flag = false --是否有至少一种道具
        for i,v in ipairs(science_info_item) do
            local node_item = self.m_ccbNode:nodeForName("node_"..#science_info_item.."_"..i)
            node_item:removeAllChildrenWithCleanup(true)
            local icon,name,count = game_util:getRewardByItemTable(v,true)
            icon:setScale(0.8)
            node_item:addChild(icon)
            local function onBtnCilck1( event,target )
                game_util:lookItemDetal(v)
            end
            local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck1)
            button:setScale(0.8)
            button:setOpacity(0)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
            button:setAnchorPoint(ccp(0.5,0.5))
            button:setPosition(ccp(0,0))
            node_item:addChild(button);

            local node_count = CCNode:create()
            node_count:setPositionY(-24)
            node_item:addChild(node_count)
            local _,ownCount = game_data:getMetalByTable(v,0,0);
            local color = ccc3(200,232,249)
            if ownCount < count then
                color = ccc3(244,1,2)
            else
                self.m_count_flag = true
            end
            local countLabel1 = game_util:createLabelTTF({text = ownCount,color = color,fontSize = 12});
            countLabel1:setAnchorPoint(ccp(0,0.5))
            local countLabel2 = game_util:createLabelTTF({text = "/"..count,color = ccc3(200,232,249),fontSize = 12});
            countLabel2:setAnchorPoint(ccp(0,0.5))
            node_count:setContentSize(CCSizeMake(countLabel1:getContentSize().width+countLabel2:getContentSize().width, countLabel1:getContentSize().height))
            node_count:setAnchorPoint(ccp(0.5,0.5))
            countLabel1:setPosition(ccp(0,countLabel1:getContentSize().height/2))
            node_count:addChild(countLabel1)
            countLabel2:setPosition(ccp(countLabel1:getContentSize().width,countLabel1:getContentSize().height/2))
            node_count:addChild(countLabel2)

            local priceLabel = game_util:createLabelBMFont({text = "+" .. price[i]})
            priceLabel:setAnchorPoint(ccp(1,0.5))
            priceLabel:setPosition(ccp(18,-10))
            node_item:addChild(priceLabel)
        end

        local exp = self.m_tGameData.score
        self.label_gx_p:setString(exp.."/"..science_info1:getNodeWithKey("need_price"):toInt())

        self.node_bar:removeAllChildrenWithCleanup(true)
        local bar = game_util:createProgressTimer({fileName = "kyjm_jdt02.png",percentage = 0})
        self.node_bar:addChild(bar)
        bar:setPercentage(100*exp/science_info1:getNodeWithKey("need_price"):toInt());

        local free_times = science_info2:getNodeWithKey("free_num"):toInt() - self.m_tGameData.science_free
        local value_num = json.decode(science_info2:getNodeWithKey("value_num"):getFormatBuffer())
        local charge_tiems = math.min(self.m_tGameData.charge_times, 3) - self.m_tGameData.science_charge
        self.label_gx_times_str:setString("Số lần Cống Hiến còn:"..tostring(free_times + charge_tiems))
        des_id1 = 18
        des_id2 = 19
    end

    local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(des_id1))
    local openMsg = itemCfg:getNodeWithKey("des"):toStr();
    self.label_des1:setString(openMsg)
    local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(des_id2))
    local openMsg = itemCfg:getNodeWithKey("des"):toStr();
    self.label_des2:setString(openMsg)
    

    local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(28))
    local openMsg = itemCfg:getNodeWithKey("des"):toStr();
    self.label_tips:setString(openMsg)
    self.label_lv:setString("Cấp KHKT".. self.m_tGameData.lv)

    for i=1,10 do
        if i <= self.m_tGameData.lv then
            game_util:setCCControlButtonBackground(self.m_stars[i], "ky_ty03.png")
        else
            game_util:setCCControlButtonBackground(self.m_stars[i], "ky_ty02.png")
        end
    end

end


--[[--
    初始化
]]
function game_godfield_guild_high_war_keji.init(self,t_params)
    t_params = t_params or {};
    self.m_group_id = t_params.group_id
    self.m_map_offset = t_params.map_offset
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
end

     
--[[--
    创建入口
]]
function game_godfield_guild_high_war_keji.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    return rootScene;
end
return game_godfield_guild_high_war_keji;