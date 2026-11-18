--- 坠落之地
--- 据点弹版
local game_godfield_guild_high_war_base_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
};

--[[--
    销毁
]]
function game_godfield_guild_high_war_base_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_base_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
end
--[[--
    返回
]]
function game_godfield_guild_high_war_base_pop.back(self)
    -- if need_callback then
        self:callBackFunc(self.m_buildingId, self.m_tGameData.info)
    -- end
    game_scene:removePopByName("game_godfield_guild_high_war_base_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_base_pop.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/godfield_main_res.plist");
    self.m_select_index = 1
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 200 then -- 规则    
            local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
            local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)
            local build_info = guild_high_war_build_cfg:getNodeWithKey(self.m_buildingId)
            local sort = build_info:getNodeWithKey("sort"):toInt()
            local id = 2
            if sort == 2 then
                id = 5
            elseif sort == 3 then
                id = 4
            end
            local itemCfg = guild_high_war_word_cfg:getNodeWithKey(tostring(id))
            if itemCfg == nil then return end
            local openMsg = itemCfg:getNodeWithKey("des"):toStr();
            game_scene:addPop("game_godfield_detail_pop",{openMsg = openMsg, btn_touchPriority = 12, touchPriority = 12})
        elseif btnTag == 501 then
            self.m_select_index = 1
            self:refreshUi()
        elseif btnTag == 502 then
            self.m_select_index = 2
            self:refreshUi()
        elseif btnTag == 300 then--进入/挑战
            local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
            local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)
            local build_info = guild_high_war_build_cfg:getNodeWithKey(self.m_buildingId)
            local sort = build_info:getNodeWithKey("sort"):toInt()
            if self.m_step == 3 and sort == 1 and self:getCanCityFlag() then
                local declareFlag = self:getDeclareFlag()
                local declareTiems = self:getDeclareTimes()
                if declareTiems <= 0 then
                    return game_util:addMoveTips({text = "Đã hết số lần tuyên chiến!"});
                end
                local build_data = self.m_tGameData.info
                local association_id = self.m_tGameData.ass_id
                if (self.m_title == "owner" or self.m_title == "vp") and self.m_isSelfFlag then --会长/副会长可宣战
                    if build_data.att_guild and build_data.att_guild == association_id then -- 已宣战
                        game_util:addMoveTips({text = "Đã tuyên chiến!"});
                    else
                        local function responseMethod( tag, gameData )
                            local data = gameData:getNodeWithKey("data");
                            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                            if self.m_tGameData.change == 1 then
                                game_util:addMoveTips({text = "Tuyên chiến thành công!"});
                            else
                                game_util:addMoveTips({text = "Chiến lực LM thấp hơn LM tuyên chiến, thay thế thất bại!"});
                            end
                            self:refreshUi()
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_declare_war"), http_request_method.GET, {city_id = self.m_buildingId},"guild_high_war_declare_war")
                    end
                end

            else
                local flag = self:getCanBuildFlag()
                local city_level = build_info:getNodeWithKey("city_level"):toInt()
                if sort == 1 then -- 城市
                    local function responseMethod( tag, gameData )
                        game_scene:addPop("game_godfield_guild_high_war_battle_detail_pop",{gameData = gameData, buildingId = self.m_buildingId, prev_gameData = self.m_prev_gameData, step = self.m_step})
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_city_info"), http_request_method.GET, {group_id = self.m_group_id, city_id = self.m_buildingId},"guild_high_war_city_info")
                elseif sort == 2 then -- 机遇
                    -- if not self.m_isSelfFlag then --有人占领了3级城 或者 自己公会占领了2级城
                        local function responseMethod( tag, gameData )
                            game_scene:addPop("game_godfield_guild_high_war_chance_pop",{gameData = gameData, buildingId = self.m_buildingId, isSelfFlag = self.m_isSelfFlag,step = self.m_step})
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_explore_index"), http_request_method.GET, {city_id = self.m_buildingId},"guild_high_war_explore_index")
                    -- else
                    --     game_util:addMoveTips({text = "有公会占领了3级城或自己公会占领了2级城才可进入"});
                    -- end
                elseif sort == 3 then -- 资源
                    if city_level == 2 and (not flag and self.m_isSelfFlag) then --lv2资源占领了3级城 或者 自己公会占领了2级城
                        game_util:addMoveTips({text = "Thành phố cấp 3 bị chiếm hoặc sở hữu thành phố cấp 2 có thể vào"});
                    else
                        local function responseMethod( tag, gameData )
                            game_scene:addPop("game_godfield_guild_high_war_res_pop",{gameData = gameData, buildingId = self.m_buildingId, prev_gameData = self.m_prev_gameData, isSelfFlag = self.m_isSelfFlag})
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_city_info"), http_request_method.GET, {group_id = self.m_group_id, city_id = self.m_buildingId},"guild_high_war_city_info")
                    end
                end
            end
        elseif btnTag == 301 then -- 查看队伍
            local function responseMethod( tag, gameData )
                game_scene:addPop("game_godfield_guild_high_war_battle_detail_pop",{gameData = gameData, buildingId = self.m_buildingId, prev_gameData = self.m_prev_gameData, step = self.m_step})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_city_info"), http_request_method.GET, {group_id = self.m_group_id, city_id = self.m_buildingId},"guild_high_war_city_info")
        elseif btnTag == 302 then -- 进攻驻守
            local function callBackFunc()
                local function responseMethod( tag, gameData )
                    local data = gameData:getNodeWithKey("data");
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_city_info"), http_request_method.GET, {group_id = self.m_prev_gameData.group_id, city_id = self.m_buildingId},"guild_high_war_city_info")
            end

            local association_id = self.m_tGameData.ass_id
            local uid = game_data:getUserStatusDataByKey("uid")
            local att_type
            if association_id == self.m_tGameData.info.att_guild then
                att_type = 1 -- 宣战方
            elseif association_id == self.m_tGameData.info.def_guild then
                att_type = 2 -- 被宣战方
            end
            local function responseMethod( tag, gameData )
                game_scene:addPop("game_godfield_guild_high_war_formation_pop",{gameData = gameData, buildingId = self.m_buildingId, openPopType = "game_godfield_guild_high_war_base_pop", callBackFunc = callBackFunc, att_type = att_type})                  
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_alignment_info"), http_request_method.GET, {t_uid = uid},"guild_high_war_alignment_info")
        elseif btnTag == 400 then -- 战报
            local function responseMethod( tag, gameData )
                game_scene:addPop("game_godfield_guild_high_war_report_pop",{gameData = gameData, buildingId = self.m_buildingId, group_id = self.m_group_id})                  
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_high_war_get_city_record"), http_request_method.GET, {city_id = self.m_buildingId, group_id = self.m_group_id},"guild_high_war_get_city_record")
        elseif btnTag == 500 then -- buff
            game_scene:addPop("game_godfield_guild_high_war_buff_pop",{buildingId = self.m_buildingId})                  
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_base_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    self.label_title = ccbNode:labelTTFForName("label_title") 
    
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_des_btn = ccbNode:controlButtonForName("m_des_btn")
    self.m_des_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

    self.node_icon = ccbNode:nodeForName("node_icon")
    self.label_name = ccbNode:labelTTFForName("label_name")
    self.label_guild_name = ccbNode:labelTTFForName("label_guild_name") -- 所属联盟
    self.label_type = ccbNode:labelTTFForName("label_type") -- 据点类型
    self.label_des = ccbNode:labelTTFForName("label_des") -- 描述
    self.m_tz_btn = ccbNode:controlButtonForName("m_tz_btn") -- 挑战按钮
    self.m_tz_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_ckdw_btn = ccbNode:controlButtonForName("m_ckdw_btn") -- 查看队伍
    self.m_ckdw_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_jgzs_btn = ccbNode:controlButtonForName("m_jgzs_btn") -- 进攻驻守
    self.m_jgzs_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

    self.label_tips = ccbNode:labelTTFForName("label_tips") 
    self.label_tips:setString("Lợi tức cứ điểm")
    self.node_income = ccbNode:nodeForName("node_income") -- 据点收益资源
    local label_income_name1 = ccbNode:labelTTFForName("label_income_name1")
    label_income_name1:setString("Thần Thạch")
    local label_income_name2 = ccbNode:labelTTFForName("label_income_name2")
    label_income_name2:setString("Thánh Thạch")
    local label_income_name3 = ccbNode:labelTTFForName("label_income_name3")
    label_income_name3:setString("Hồn Thạch")
    self.node_income_items1 = ccbNode:nodeForName("node_income_items1")
    self.node_income_items2 = ccbNode:nodeForName("node_income_items2")
    self.node_income_items3 = ccbNode:nodeForName("node_income_items3")
    self.label_des_tips = ccbNode:labelTTFForName("label_des_tips") -- 据点收益描述
    self.m_zb_btn = ccbNode:controlButtonForName("m_zb_btn") -- 战报按钮
    self.m_zb_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

    self.m_buff_btn = ccbNode:controlButtonForName("m_buff_btn") -- buff按钮
    self.m_buff_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    
    self.node_1 = ccbNode:nodeForName("node_1")
    self.node_2 = ccbNode:nodeForName("node_2")
    self.spr_lv1 = ccbNode:spriteForName("spr_lv1")-- 资源型的遗迹等级
    self.label_lv1 = ccbNode:labelTTFForName("label_lv1")
    self.label_guild_name2 = ccbNode:labelTTFForName("label_guild_name2") -- 占领公会
    self.label_lv = ccbNode:labelTTFForName("label_lv") -- 遗迹等级
    self.label_score = ccbNode:labelTTFForName("label_score") -- 遗迹积分
    self.label_status = ccbNode:labelTTFForName("label_status") -- 遗迹状态
    self.label_ok = ccbNode:labelTTFForName("label_ok") -- 携带据点
    self.spr_ok = ccbNode:spriteForName("spr_ok") -- 携带据点
    self.m_btn1 = ccbNode:controlButtonForName("m_btn1")
    game_util:setCCControlButtonTitle(self.m_btn1,"Thuế cơ bản")
    self.m_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_btn2 = ccbNode:controlButtonForName("m_btn2")
    game_util:setCCControlButtonTitle(self.m_btn2,"Thuế lãnh thổ")
    self.m_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.label_tips2 = ccbNode:labelTTFForName("label_tips2")--每日宝箱奖励
    self.node_reward = ccbNode:nodeForName("node_reward")
    
    self.spr_wr_tips = ccbNode:spriteForName("spr_wr_tips")
    self.label_wr_tips = ccbNode:labelTTFForName("label_wr_tips")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_godfield_guild_high_war_base_pop.refreshUi(self)
    local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)
    local build_info = guild_high_war_build_cfg:getNodeWithKey(self.m_buildingId)

    local city_name = build_info:getNodeWithKey("city_name"):toStr()
    self.label_name:setString(city_name)
    self.node_icon:removeAllChildrenWithCleanup(true)
    local city_icon = build_info:getNodeWithKey("city_icon"):toStr()
    local building = CCSprite:create("ccbResources/godfield_build/"..city_icon..".png")
    -- building:setScale(0.7)
    self.node_icon:addChild(building)

    local city_des = build_info:getNodeWithKey("city_des"):toStr()
    self.label_des:setString(city_des)

    local sort = build_info:getNodeWithKey("sort"):toInt()
    if sort > 1 then
        if sort == 4 then
            building:setScale(0.9)
        else
            building:setScale(0.8)
        end
    else
        building:setScale(0.6)
    end

    --1城市 2资源3机遇4商店
    self.label_des_tips:setString("")
    self.node_income:setVisible(false)
    self.node_1:setVisible(false)
    self.node_2:setVisible(false)
    self.spr_wr_tips:setVisible(false)
    local type_str = "TP"

    local build_data = self.m_tGameData.info
    local association_id = self.m_tGameData.ass_id

    self.m_buff_btn:setVisible(sort == 1)

    if sort == 2 then
        self.label_title:setString("Chi tiết cứ điểm")
        self.spr_lv1:setVisible(false)
        type_str = "Kỳ ngộ"
        self.node_1:setVisible(true)
        if build_data.def_name and build_data.def_name ~= "" then
            self.label_guild_name:setString(build_data.def_name)
        else
            self.label_guild_name:setString("Tài nguyên")
        end
        local guild_high_war_word_cfg = getConfig(game_config_field.guild_high_war_word)
        local word_cfg = json.decode(guild_high_war_word_cfg:getFormatBuffer())
        local des = word_cfg["12"].des
        self.label_des_tips:setString(des)
        game_util:setCCControlButtonBackground(self.m_tz_btn, "godfield_jinru.png")
    elseif sort == 3 then
        self.label_title:setString("Chi tiết cứ điểm")
        type_str = "Tài nguyên"
        self.node_1:setVisible(true)

        local city_zone = json.decode(build_info:getNodeWithKey("city_zone"):getFormatBuffer())
        local def_guild = self.m_mapData[tostring(city_zone[1])].def_guild or ""
        local def_name = self.m_mapData[tostring(city_zone[1])].def_name or ""
        local flag = false
        for k,v in pairs(city_zone) do
            local buildData = self.m_mapData[tostring(v)]
            if def_guild ~= buildData.def_guild then -- 有其他公会
                flag = true
                break
            end
        end

        if not flag and def_guild ~= "" then
            self.label_guild_name:setString(def_name)
        else
            self.label_guild_name:setString("Chưa chiếm")
        end
        
        self.node_income:setVisible(true)
        local city_level = build_info:getNodeWithKey("city_level"):toInt()
        self.spr_lv1:setVisible(true)
        self.label_lv1:setString("Lv."..city_level)
        local guild_high_war_product_cfg = getConfig(game_config_field.guild_high_war_product)
        guild_high_war_product_cfg = json.decode(guild_high_war_product_cfg:getFormatBuffer())
        local product_cfg
        for k,v in pairs(guild_high_war_product_cfg) do
            if v.build_sort == 3 and v.bulid_level == city_level then
                product_cfg = v
                break
            end
        end
        self.node_income_items1:removeAllChildrenWithCleanup(true);
        self.node_income_items1:setContentSize(CCSizeMake(#product_cfg.product1*25, 40))
        local tableView = self:createRewardTable(self.node_income_items1:getContentSize(), product_cfg.product1)
        self.node_income_items1:addChild(tableView,10,10);

        self.node_income_items2:removeAllChildrenWithCleanup(true);
        self.node_income_items2:setContentSize(CCSizeMake(#product_cfg.product2*25, 40))
        local tableView = self:createRewardTable(self.node_income_items2:getContentSize(), product_cfg.product2)
        self.node_income_items2:addChild(tableView,10,10);

        self.node_income_items3:removeAllChildrenWithCleanup(true);
        self.node_income_items3:setContentSize(CCSizeMake(#product_cfg.product3*25, 40))
        local tableView = self:createRewardTable(self.node_income_items3:getContentSize(), product_cfg.product3)
        self.node_income_items3:addChild(tableView,10,10);
        game_util:setCCControlButtonBackground(self.m_tz_btn, "godfield_jinru.png")
    elseif sort == 4 then
        type_str = "Cửa Hàng"
    elseif sort == 1 then -- 城市
        self.label_title:setString("Chi tiết Thành Trì")
        self.node_2:setVisible(true)
        if build_data.def_name then
            self.label_guild_name2:setString(build_data.def_name ~= "" and build_data.def_name or "Quân phòng thủ")
        else
            self.label_guild_name2:setString("Quân phòng thủ")
        end
        local city_level = build_info:getNodeWithKey("city_level"):toInt()
        self.label_lv:setString("Lv."..city_level)
        local score = build_info:getNodeWithKey("score"):toStr()
        self.label_score:setString(score)

        if build_data.att_guild and build_data.att_guild ~= "" then
            self.label_status:setString(build_data.att_name.."Đã tuyên chiến")
        else
            self.label_status:setString("Chưa tuyên chiến")
        end

        guild_high_war_build_cfg = json.decode(guild_high_war_build_cfg:getFormatBuffer())
        local count = 0
        local build_cfg
        for k,v in pairs(guild_high_war_build_cfg) do
            if v.sort == 3 then
                for kk,vv in pairs(v.city_zone) do
                    if tostring(self.m_buildingId) == tostring(vv) then
                        build_cfg = v
                        break
                    end
                end
            end
        end
        
        if build_cfg then
            count = #build_cfg.city_zone
            if count == 1 then
                self.label_ok:setString(build_cfg.city_name)
            else
                self.label_ok:setString(tostring(1/count*100).."%"..build_cfg.city_name)
            end
            self.spr_ok:setVisible(count > 0)
        else
            self.spr_ok:setVisible(false)
        end
        
        if self.m_select_index == 1 then
            game_util:setCCControlButtonBackground(self.m_btn1, "godfield_Z7.png")
            game_util:setCCControlButtonBackground(self.m_btn2, "godfield_Z6.png")
            game_util:setCCControlButtonEnabled(self.m_btn1,true);
            self.m_btn1:setTitleColorForState(ccc3(158, 255, 255),CCControlStateNormal);
            game_util:setCCControlButtonEnabled(self.m_btn2,true);
            self.m_btn2:setTitleColorForState(ccc3(189, 227, 248),CCControlStateNormal);
            self.label_tips2:setString("Tài nguyên hộp báu")

            local box = json.decode(build_info:getNodeWithKey("box"):getFormatBuffer())

            self.node_reward:removeAllChildrenWithCleanup(true);
            self.node_reward:setContentSize(CCSizeMake(#box*50, 50))
            local tableView = self:createRewardTable(self.node_reward:getContentSize(), box, true, 0.7)
            self.node_reward:addChild(tableView,10,10);
        else
            game_util:setCCControlButtonBackground(self.m_btn1, "godfield_Z6.png")
            game_util:setCCControlButtonBackground(self.m_btn2, "godfield_Z7.png")
            game_util:setCCControlButtonEnabled(self.m_btn1,true);
            self.m_btn1:setTitleColorForState(ccc3(189, 227, 248),CCControlStateNormal);
            game_util:setCCControlButtonEnabled(self.m_btn2,true);
            self.m_btn2:setTitleColorForState(ccc3(158, 255, 255),CCControlStateNormal);
            self.label_tips2:setString("Phần thưởng Occupy")

            local city_level = build_info:getNodeWithKey("city_level"):toInt()
            local guild_high_war_product_cfg = getConfig(game_config_field.guild_high_war_product)
            guild_high_war_product_cfg = json.decode(guild_high_war_product_cfg:getFormatBuffer())
            local product_cfg
            for k,v in pairs(guild_high_war_product_cfg) do
                if v.build_sort == 1 and v.bulid_level == city_level then
                    product_cfg = v
                    break
                end
            end
            self.node_reward:removeAllChildrenWithCleanup(true);
            self.node_reward:setContentSize(CCSizeMake(#product_cfg.product1*50, 50))
            local tableView = self:createRewardTable(self.node_reward:getContentSize(), product_cfg.product1, nil, 0.7, true)
            self.node_reward:addChild(tableView,10,10)
        end
        
        self.spr_wr_tips:setVisible(true)
        local radiation = build_info:getNodeWithKey("radiation")
        if radiation then
           radiation = build_info:getNodeWithKey("radiation"):toStr()
        else
            radiation = "0"
        end
        self.label_wr_tips:setString("Độc tính Aether"..radiation.."%")
    end
    self.label_type:setString(type_str)
    -- self.label_combat:setString("11111111")

    local city_level = build_info:getNodeWithKey("city_level"):toInt()

    local flag = self:getCanBuildFlag()
    if sort == 1 then
        self.m_tz_btn:setVisible(false) 
    elseif sort == 2 then -- 机遇在任何阶段都可进入
        self.m_tz_btn:setVisible(true)    
        game_util:setCCControlButtonBackground(self.m_tz_btn, "godfield_jinru.png")
    elseif sort == 3 then 
        self.m_tz_btn:setVisible(true) -- lv1和lv2资源都展示进入按钮，在点击时拦截 
        game_util:setCCControlButtonBackground(self.m_tz_btn, "godfield_jinru.png")
        -- if city_level == 1 then -- lv1资源在任何阶段都可进入
        --     game_util:setCCControlButtonBackground(self.m_tz_btn, "godfield_jinru.png")
        -- elseif city_level == 2 then 
        --     if flag then --lv2资源占领了3级城 或者 自己公会占领了2级城
        --         self.m_tz_btn:setVisible(true)    
        --         game_util:setCCControlButtonBackground(self.m_tz_btn, "godfield_jinru.png")
        --     else
        --         self.m_tz_btn:setVisible(false)    
        --     end
        -- end
    end    

    
    if self.m_step == 2 then -- 准备阶段
        self.m_ckdw_btn:setVisible(false)
        self.m_jgzs_btn:setVisible(false)
        if not self.m_isSelfFlag and sort > 1 then -- 观众可以看
            self.m_tz_btn:setVisible(true)    
        end
    elseif self.m_step == 3 then -- 宣战阶段
        if (self.m_title == "owner" or self.m_title == "vp") and self.m_isSelfFlag and sort == 1 and self:getCanCityFlag() then --会长/副会长可宣战
            if build_data.def_guild and build_data.def_guild ~= association_id then -- 不是自己的城才显示宣战按钮
                self.m_tz_btn:setVisible(true)
                game_util:setCCControlButtonBackground(self.m_tz_btn, "xz_btn01.png")                
            end
        end
        
        if build_data.att_guild and build_data.att_guild == association_id then -- 已宣战
            game_util:setCCControlButtonBackground(self.m_tz_btn, "yxz_btn01.png")
        end

        local declareFlag = self:getDeclareFlag()
        local declareTiems = self:getDeclareTimes()
        if declareFlag or declareTiems <= 0 then
            self.m_tz_btn:setColor(ccc3(150,150,150))
        end
    elseif self.m_step == 4 then -- 布阵阶段
        if sort == 1 then
            if self.m_isSelfFlag and build_data.att_guild and build_data.att_guild ~= "" and (build_data.def_guild == association_id or build_data.att_guild == association_id) then -- 已宣战
                self.m_ckdw_btn:setVisible(true)
                self.m_jgzs_btn:setVisible(true)
            elseif build_data.att_guild and build_data.att_guild ~= "" then -- 有进攻方就是被宣战的
                self.m_ckdw_btn:setVisible(true) -- 只显示查看队伍
                local x,y = self.m_tz_btn:getPosition()
                self.m_ckdw_btn:setPosition(ccp(x,y))
            end
        end
    elseif self.m_step == 9 or self.m_step == 8 or self.m_step == 10 then -- 战斗阶段/战斗结算期/战前阶段
        if sort == 1 then -- 只显示查看队伍
            local build_info_data = self:getBuildInfoData()
            if build_data.att_info and #build_data.att_info == 0 and build_data.def_info and #build_data.def_info == 0 and build_info_data then -- 有战斗结果时
                self.m_ckdw_btn:setVisible(false)
            else
                self.m_ckdw_btn:setVisible(true)
            end
            local x,y = self.m_tz_btn:getPosition()
            self.m_ckdw_btn:setPosition(ccp(x,y))
        end
    elseif self.m_step == 5 or self.m_step == 6 or self.m_step == 7 or self.m_step == 11 then -- 丰收日阶段/丰收日-探索阶段/结算阶段/丰收夜
        if sort == 1 then 
            self.m_tz_btn:setVisible(false) 
            self.m_ckdw_btn:setVisible(false)
            self.m_jgzs_btn:setVisible(false)
        end
    end

   
end

---获得城市战斗情况
function game_godfield_guild_high_war_base_pop.getBuildInfoData(self)
    for k,v in pairs(self.m_prev_gameData.info or {}) do
        if tostring(self.m_buildingId) == tostring(v.city) then
            return v
        end
    end
end

--有公会占领了3级城 或者 自己公会占领了2级城
function game_godfield_guild_high_war_base_pop.getCanBuildFlag(self)
    local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)
    local association_id = self.m_tGameData.ass_id
    for k,v in pairs(self.m_mapData) do
        local build_info = guild_high_war_build_cfg:getNodeWithKey(k)
        local city_level = build_info:getNodeWithKey("city_level"):toInt()
        if city_level == 3 and v.def_guild and v.def_guild ~= "" then
            return true
        end

        if city_level == 2 and v.def_guild and v.def_guild == association_id then
            return true
        end
    end

end

-- 当前城市是否在所有的拥有的城的attack_point里
function game_godfield_guild_high_war_base_pop.getCanCityFlag(self)
    local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)
    local flag
    for k,v in pairs(self.m_city) do
        local build_info = guild_high_war_build_cfg:getNodeWithKey(k)
        local attack_point = json.decode(build_info:getNodeWithKey("attack_point"):getFormatBuffer())
        -- flag = tostring(self.m_buildingId) == tostring(k)
        -- if flag then
        --     break
        -- end
        for kk,vv in pairs(attack_point) do
            if tostring(self.m_buildingId) == tostring(vv) then
                flag = true
                break
            end
        end
        if flag then
            break
        end
    end

    local length = game_util:getTableLen(self.m_city)
    if length == 0 then -- 没有城池了
        local build_info = guild_high_war_build_cfg:getNodeWithKey(self.m_buildingId)
        local city_level = build_info:getNodeWithKey("city_level"):toInt()
        if city_level == 1 then
            flag = true
        end
    end

    return flag
end

--今日本城是否已宣战
function game_godfield_guild_high_war_base_pop.getDeclareFlag(self)
    local association_id = self.m_tGameData.ass_id
    local buildInfo = self.m_mapData[self.m_buildingId]
    if buildInfo and buildInfo.att_guild and buildInfo.att_guild == association_id then 
        return true
    end
end

---获取宣战次数
function game_godfield_guild_high_war_base_pop.getDeclareTimes(self)
    local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)
    local association_id = self.m_tGameData.ass_id
    local temp_list = {}
    local count = 0
    for k,v in pairs(self.m_mapData) do
        local build_info = guild_high_war_build_cfg:getNodeWithKey(k)
        local city_level = build_info:getNodeWithKey("city_level"):toInt()
        if v.def_guild and v.def_guild == association_id then
            temp_list[#temp_list + 1] = city_level
        end
        if v.att_guild and v.att_guild == association_id then
            count = count + 1
        end
    end

    table.sort( temp_list, function (data1, data2)
        return data1 < data2
    end )

    local times = (temp_list[#temp_list] or 1) - count
    return times
end


function game_godfield_guild_high_war_base_pop.createRewardTable(self,viewSize,rewardList, is_box, scale, show_name)
    local scale = scale or 0.5

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemCfg = rewardList[btnTag+1]
        game_util:lookItemDetal(itemCfg)
    end
    local count = #rewardList
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = count; --列
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionHorizontal;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5,0.5))
            node:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            cell:addChild(node)
            local itemGift = rewardList[index+1]
            if is_box then
                local icon,name
                if index+1 == 3 then
                    icon = CCSprite:create("icon/dj_icon12.png")
                    name = "Bạc"
                elseif index+1 == 2 then
                    icon = CCSprite:create("icon/dj_icon10.png")
                    name = "Vàng"
                elseif index+1 == 1 then
                    icon = CCSprite:create("icon/dj_icon11.png")
                    name = "Chí Tôn"
                end
                icon:setScale(scale)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,2))
                node:addChild(icon,10)
                local nameLabel = game_util:createLabelTTF({text = name.."x"..itemGift})
                nameLabel:setColor(ccc3(250,180,0))
                nameLabel:setAnchorPoint(ccp(0.5, 0.5))
                nameLabel:setPosition(icon:getContentSize().width * 0.5, -10)
                icon:addChild(nameLabel, 11)
            else
                local icon,name,count = game_util:getRewardByItemTable(itemGift, true)
                if icon then
                    icon:setScale(scale)
                    icon:setAnchorPoint(ccp(0.5,0.5))
                    icon:setPosition(ccp(0,2))
                    node:addChild(icon,10)
                end
                if name then
                    local nameLabel = game_util:createLabelTTF({text = show_name and name or "x"..count})
                    nameLabel:setColor(ccc3(250,180,0))
                    nameLabel:setAnchorPoint(ccp(0.5, 0.5))
                    nameLabel:setPosition(icon:getContentSize().width * 0.5, -10)
                    icon:addChild(nameLabel, 11)
                end

                local guild_high_war_build_cfg = getConfig(game_config_field.guild_high_war_build)
                local build_info = guild_high_war_build_cfg:getNodeWithKey(self.m_buildingId)
                local sort = build_info:getNodeWithKey("sort"):toInt()
                if self.m_select_index == 1 and sort == 3 then
                    local tips_name = "guild_high_war_bichu"
                    if itemGift[4] < 100 then
                        tips_name = "guild_high_war_gailv"
                    end
                    local tips = CCSprite:createWithSpriteFrameName(tips_name..".png")
                    tips:setAnchorPoint(ccp(1,0.5))
                    tips:setPosition(icon:getContentSize().width, 6)
                    icon:addChild(tips, 12)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemCfg = rewardList[index+1]
            if not is_box then
                game_util:lookItemDetal(itemCfg)
            else
                game_scene:addPop("game_godfield_guild_high_war_box_pop",{boxid = index+1})
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        
    end
    return TableViewHelper:create(params);
end
--[[--
    初始化
]]
function game_godfield_guild_high_war_base_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_tParams = t_params
    self.m_buildingId = t_params.build_id or 1
    self.m_step = t_params.step or 1
    self.m_prev_gameData = t_params.prev_gameData or {}
    self.m_title = self.m_prev_gameData.title or ""
    self.m_isSelfFlag = t_params.isSelfFlag or false
    self.m_mapData = self.m_prev_gameData.map or {}
    self.m_city = self.m_prev_gameData.city or {}
    self.m_group_id = self.m_prev_gameData.group_id
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end

end

--[[--
    回调方法
]]
function game_godfield_guild_high_war_base_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params)
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_godfield_guild_high_war_base_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_guild_high_war_base_pop;