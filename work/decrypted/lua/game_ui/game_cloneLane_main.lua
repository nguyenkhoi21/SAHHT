---  克隆诡巷

local game_cloneLane_main = {
    m_tGameData = nil,
    m_ccbNode = nil,
    m_conutdownTime_node = nil,
    m_fanpai_node = nil,
    m_package_lab = nil,
    m_xingyunzhi_label = nil,
    m_fanpai_lab = nil,
    m_refresh_lab = nil,
    m_package_lab = nil,
    m_xipai_lab = nil,
    m_show_team = nil,
    m_show_node = nil,
    m_back_btn = nil,
    m_detail_btn = nil,
    m_information_btn = nil,
    m_current_btn = nil,
    m_refresh_btn = nil,
    m_start_btn = nil,
    m_package_btn = nil,
    btn_small_refresh = nil,
    m_luckyBox_btn = nil,
    m_secret_reward_node = nil,
    m_score_flag = nil,
    m_score = nil,
    m_score_max = nil,
    m_isXipai = nil,
    m_zjrAnim = nil,
    m_zjrAnim1 = nil,
    anim_node = nil,
    m_isPlayAnim = nil,
    cardTable = nil,
    m_pintu_sprite_tab = nil,
    icon_1 = nil,
    cardTeam_tab = nil,
    m_gachaAnimTab = nil,
    m_root_layer = nil,
    m_gachaAnimEndFlag = nil,
    m_show_team = nil,
    m_own_card_team = nil,
    m_card_team = nil,
    init_card_team = nil,
    m_open_times = nil,
    m_package_num = nil,
    m_version = nil,
    m_refresh_time = nil,
    m_allbtn_node = nil,
    m_other_node = nil,
    m_getCard_btn = nil,
    m_toptips_node = nil,
    m_scroll_view_tips = nil,
    m_tips_lab = nil,
    m_package_sp = nil,
    m_scroll_view_Secret = nil,
    m_zhedang_node = nil,
    m_new_gameData = nil,
    m_isgetAllCards = nil, 
    m_getPintuNum = nil,
    m_shangkuang_sp1 = nil,
    m_shangkuang_sp2 = nil,
    m_network_flag = nil,
    m_old_data = nil,
}
--[[--
    销毁ui
]]
function game_cloneLane_main.destroy(self)
    -- body
    cclog("-----------------game_cloneLane_main destroy-----------------");
    self.m_tGameData = nil;
    self.m_ccbNode = nil;
    self.m_conutdownTime_node = nil;
    self.m_fanpai_node = nil;
    self.m_package_lab = nil;
    self.m_xingyunzhi_label = nil;
    self.m_fanpai_lab = nil;
    self.m_refresh_lab = nil;
    self.m_package_lab = nil;
    self.m_xipai_lab = nil;
    self.m_show_team = nil;
    self.m_show_node = nil;
    self.m_back_btn = nil;
    self.m_detail_btn = nil;
    self.m_information_btn = nil;
    self.m_current_btn = nil;
    self.m_refresh_btn = nil;
    self.m_start_btn = nil;
    self.m_package_btn = nil;
    self.btn_small_refresh = nil;
    self.m_luckyBox_btn = nil;
    self.m_secret_reward_node = nil;
    self.m_score_flag = nil;
    self.m_score = nil;
    self.m_score_max = nil;
    self.m_isXipai = nil;
    self.m_zjrAnim = nil;
    self.m_zjrAnim1 = nil;
    self.anim_node = nil;
    self.m_isPlayAnim = nil;
    self.m_pintu_sprite_tab = nil;
    self.icon_1 = nil;
    self.m_gachaAnimTab = nil;
    self.m_root_layer = nil;
    self.m_gachaAnimEndFlag = nil;
    self.m_show_team = nil;
    self.m_own_card_team = nil;
    self.m_card_team = nil;
    self.init_card_team = nil;
    self.m_open_times = nil;
    self.m_package_num = nil;
    self.m_version = nil;
    self.m_refresh_time = nil;
    self.m_allbtn_node = nil;
    self.m_other_node = nil;
    self.m_getCard_btn = nil;
    self.m_toptips_node = nil;
    self.m_scroll_view_tips = nil;
    self.m_tips_lab = nil;
    self.m_package_sp = nil;
    self.m_scroll_view_Secret = nil;
    self.m_zhedang_node = nil;
    self.m_new_gameData = nil;
    self.m_isgetAllCards = nil;
    self.m_getPintuNum = nil;
    self.m_shangkuang_sp1 = nil;
    self.m_shangkuang_sp2 = nil;
    self.m_network_flag = nil;
end
--[[--
    返回
]]
function game_cloneLane_main.back(self,type)
    game_scene:enterGameUi("game_main_scene");
end
function game_cloneLane_main.createHeroListItemByCCB(self,heroData,kuangFlag,tag)
    local ccbNode = luaCCBNode:create();
    local kuangFlag = kuangFlag 
    ccbNode:openCCBFile("ccb/ui_cloneLane_cardsItem2.ccbi");
    ccbNode:setAnchorPoint(ccp(0.5,0.5));
    ccbNode:setScale(0.5)
    if ccbNode ~= nil and heroData ~= nil then
        self:setHeroListItemInfoByTable(ccbNode,heroData,kuangFlag,tag);
    end
    return ccbNode
end

function game_cloneLane_main.createHeroListItemByCCB2(self,heroData,kuangFlag,tag)
    local ccbNode = luaCCBNode:create();
    local kuangFlag = kuangFlag 
    ccbNode:openCCBFile("ccb/ui_cloneLane_cardsItem1.ccbi");
    ccbNode:setAnchorPoint(ccp(0.5,0.5));
    ccbNode:setScale(0.9)
    local sp_sprite  = ccbNode:spriteForName("m_spr_bg")
    sp_sprite:setVisible(false)
    if ccbNode ~= nil and heroData ~= nil then
        self:setQuanshenxiang(ccbNode,heroData,kuangFlag,tag);
    end
    return ccbNode
end

function game_cloneLane_main.setQuanshenxiang( self,ccbNode,heroDataTable,kuangFlag,tag )
    local cardId = heroDataTable.c_id;
    local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(cardId);
    if itemConfig then
        ccbNode:nodeForName("m_info_node"):setVisible(true);
    else
        ccbNode:nodeForName("m_info_node"):setVisible(false);
        return
    end
    local m_anim_node = tolua.cast(ccbNode:objectForName("m_anim_node"),"CCNode");
    m_anim_node:removeAllChildrenWithCleanup(true);
    local animation = itemConfig:getNodeWithKey("animation"):toStr();
    local rgb = itemConfig:getNodeWithKey("rgb_sort"):toInt();
    local animNode = game_util:createImgByName("image_" .. animation,rgb,nil,nil,wake_lv,itemConfig)
    animNode = game_util:createIdelAnim(animation,0,heroDataTable,itemConfig);
    if animNode then
        local animNodeSize = animNode:getContentSize();
        animNode:setAnchorPoint(ccp(0.5,0));
        m_anim_node:addChild(animNode);
        if kuangFlag == false then
            m_anim_node:setVisible(false)
        else
            m_anim_node:setVisible(true)
        end
    end
end

function game_cloneLane_main.setHeroListItemInfoByTable(self,ccbNode,heroDataTable,kuangFlag,tag)
    local cardId = heroDataTable.c_id;
    -- cclog("cardId ===" .. tostring(cardId))
    local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(cardId);
    if itemConfig then
        ccbNode:nodeForName("m_info_node"):setVisible(true);
    else
        ccbNode:nodeForName("m_info_node"):setVisible(false);
        return
    end
    local m_anim_node = tolua.cast(ccbNode:objectForName("m_anim_node"),"CCNode");
    local m_occupation_icon = ccbNode:spriteForName("m_occupation_icon")
    --m_anim_node:setTag(500);
    m_anim_node:removeAllChildrenWithCleanup(true);
    local quality = itemConfig:getNodeWithKey("quality"):toInt();
    local super_quality_1 = heroDataTable.super_quality_1 or 0
    local hero_quality_item = super_quality_1 > 0 and HERO_QUALITY_COLOR_TABLE_2[super_quality_1] or HERO_QUALITY_COLOR_TABLE[quality+1]
    if hero_quality_item then
        ccbNode:spriteForName("m_spr_bg"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(hero_quality_item.card_img));
    end
    local animation = itemConfig:getNodeWithKey("animation"):toStr();
    local rgb = itemConfig:getNodeWithKey("rgb_sort"):toInt();

    local animNode = game_util:createImgByName("image_" .. animation,rgb,nil,nil,wake_lv,itemConfig)
    -- local animNode = game_util:createPauseAnim(animation,0,heroDataTable,itemConfig);
    -- cclog("setHeroListItemInfoByTable animNode == " .. tostring(animNode))
    if animNode then
        local animNodeSize = animNode:getContentSize();
        animNode:setAnchorPoint(ccp(0.5,0));
        m_anim_node:addChild(animNode);
        if kuangFlag == false then
            m_anim_node:setVisible(false)
        else
            m_anim_node:setVisible(true)
            --m_occupation_icon:setVisible(true)
        end
        --cclog2(m_occupation_icon:isVisible(),"isVisible")
        -- cclog2(m_anim_node:isVisible(),"isVisible")
        -- animNode:setVisible(kuangFlag)
        -- m_anim_node:getParent():reorderChild(m_anim_node,-1);
    end
    local m_sel_img = ccbNode:spriteForName("m_sel_img")
    m_sel_img:setVisible(false)
    local m_team_img = ccbNode:spriteForName("m_team_img")
    if game_data:heroInTeamById(heroDataTable.id) then
        m_team_img:setVisible(true);
        m_team_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_played.png"));
    else
        if game_data:heroInAssistantById(heroDataTable.id) then
            m_team_img:setVisible(true);
            m_team_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_zhuzhanzhong.png"));
        else
            m_team_img:setVisible(false);
        end
    end
    local m_perfect_img = ccbNode:spriteForName("m_perfect_img")
    m_perfect_img:setVisible(false);

end
--[[--
    刷新卡组的动画
]]
function game_cloneLane_main.createRefreshAnim(self )
    self.anim_node:removeAllChildrenWithCleanup(true)
    self.m_show_node:removeAllChildrenWithCleanup(true)
    self.m_isPlayAnim = true
    --self:cardsGoBack()
    --self.m_zjrAnim = game_util:createAnimEffect("gacha_anim_kabao","gacha_anim_kabao",RanimCallBack);
    local function RanimCallBack( animNode, theId, theLabelName )
         --cclog("createRefreshAnim  == ")
        if  theLabelName == "shuaxin" then
            -- local texiaoAnim = self.createBlenderAnim( "gacha_anim_texiao.swf.sam", 1, "gacha_anim_texiao.plist", true )
            -- if texiaoAnim then
            --     local tempsize = self.anim_node:getContentSize()
            --     texiaoAnim:setAnchorPoint(ccp(0.5,0.5));
            --     texiaoAnim:setPosition(ccp(tempsize.width*0.5,tempsize.height*0.1));
            --     game_anim:playSection(texiaoAnim,"dakai2")
            --     texiaoAnim:playSection("dakai2")
            --     self.anim_node:addChild(texiaoAnim,11,11)
            -- end
            -- game_anim:playSection(animNode,"dakai2")
            -- animNode:playSection("dakai2")
            -- animNode:getParent():removeFromParentAndCleanup(true);
            self.anim_node:removeAllChildrenWithCleanup(true)
            self:cardsatMid()
            self:cardsGoBack()
        else
            animNode:getParent():removeFromParentAndCleanup(true);
            self.m_zjrAnim = nil
            self.m_isPlayAnim = false
        end
    end
    local z_zjrAnim = game_util:createAnimEffect("gacha_anim_kabao","gacha_anim_kabao",RanimCallBack,nil,true);
        if z_zjrAnim then
            local tempsize = self.anim_node:getContentSize()
            z_zjrAnim:setAnchorPoint(ccp(0.5,0.5));
            z_zjrAnim:setPosition(ccp(tempsize.width*0.5,tempsize.height*0.1));
            game_anim:playSection(z_zjrAnim,"shuaxin")
            self.anim_node:addChild(z_zjrAnim,10,10)
        end
    --cclog2(self.m_isPlayAnim," shua xin  ixanzhi  === ")
end
--[[--
    卡牌在中间

]]
function game_cloneLane_main.cardsatMid( self )
    self:createTenCards()
    for i=1,10 do
        self.m_show_node:getChildByTag(i):setPosition(ccp(20,-10))
    end
    -- body
end
--[[--
    卡牌飞回去
]]
function game_cloneLane_main.cardsGoBack( self )
    --self:createTenCards()
    self.m_isPlayAnim = true
    local animFile = nil

    local my_pos = {}
    for i=1,10 do
        local pos = self:setCircleByIndex(i)
        my_pos[i] = {pos = pos}
        --cclog2(my_pos[i],"my_pos == ")
    end
    for i=1,10 do
        local function RanimCallBack1( animNode, theId, theLabelName )
        if  theLabelName == "fanpai2" then
            self.m_show_node:getChildByTag(i):setVisible(true)
            --self:cardsGoBack()
            self.m_show_node:removeChildByTag(11,true)
            self.m_zjrAnim = nil
            self.m_isPlayAnim = false
        end
    end
    local z_zjrAnim = game_util:createAnimEffect("gacha_anim_guixiang_3","gacha_anim_guixiang_3",RanimCallBack1,nil,true);
    if z_zjrAnim then
        local tempsize = self.m_show_node:getChildByTag(i):getContentSize()
        z_zjrAnim:setAnchorPoint(ccp(0.5,0.5));
        z_zjrAnim:setPosition(my_pos[i].pos);
        z_zjrAnim:setScale(0.5)
        --game_anim:playSection(z_zjrAnim,"fanpai")
        self.m_show_node:addChild(z_zjrAnim,-1,11)
    end
    local animArr = CCArray:create();
    local function animEndCallFunc()
        self.m_show_node:getChildByTag(i):setVisible(false)
       game_anim:playSection(z_zjrAnim,"fanpai2")

    end
    animArr:addObject(CCMoveTo:create(0.2,(my_pos[i].pos)));
    animArr:addObject(CCCallFunc:create(animEndCallFunc));
    self.m_show_node:getChildByTag(i):runAction(CCSequence:create(animArr));
    end
    -- body
end
--[[--
    读取ccbi创建ui
]]
function game_cloneLane_main.createUi(self)
    local ccbNode = luaCCBNode:create();
        local function onBtnClick( target,event )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            if btnTag == 100 then--返回
                if self.m_isPlayAnim == false then
                    if self.m_isPlayAnim == false then
                        self:back();
                    end
                end
            elseif btnTag == 101 then--详情
                --cclog2(self.m_isPlayAnim,"self.m_isPlayAnim ==== ")
                if self.m_isPlayAnim == false then
                    game_scene:addPop("game_active_limit_detail_pop",{openType = "game_cloneLane"})
                end
            elseif btnTag == 102 then--全服信息
                if self.m_isPlayAnim == false then
                    local function responseMethod( tag,gameData )
                        if gameData and tolua.type(gameData) == "util_json" then
                            local data = gameData:getNodeWithKey("data")
                            data= json.decode(data:getFormatBuffer())
                            local openMsg1 = data.logs
                            local openMsg = ""
                            local openMsg_tab = {}
                            local length = #openMsg1
                            for k,v in pairs(openMsg1) do
                                --cclog2(length,"length == ")
                                -- openMsg_tab[length] = v
                                -- length = length - 1
                                --openMsg = v .. "\n" .. openMsg
                                 openMsg = openMsg .. v .. "\n"
                            end
                            -- for k,v in pairs(openMsg_tab) do
                            --     openMsg = openMsg .. v .. "\n"
                            -- end
                            -- cclog2(openMsg1,"openMsg1")
                            -- cclog2(openMsg_tab,"openMsg_tab")
                            game_scene:addPop("game_active_limit_detail_pop",{openType = "game_cloneLane_allnews",openMsg = openMsg})
                        end
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("clone_lane_get_notice"), http_request_method.GET, nil,"clone_lane_get_notice")
                end
            elseif btnTag == 103 then--当前卡组
                if self.m_isPlayAnim == false then
                    local gameData = self.m_old_data
                    local isgetAllCards = self.m_isgetAllCards or false
                    game_scene:addPop("game_cloneLane_current",{gameData = gameData,isgetAllCards = isgetAllCards})
                end
            elseif btnTag == 104 then--刷新卡组
                if self.m_isPlayAnim == false then
                    local function responseMethod( tag,gameData )
                        self.m_isXipai = false
                       if gameData and tolua.type(gameData) == "util_json" then
                            local data = gameData:getNodeWithKey("data")
                            data= json.decode(data:getFormatBuffer())
                            self.m_tGameData = data
                            self.m_old_data = self.m_tGameData
                            self:refreshData()
                            self:refreshLabel()
                            self.m_isgetAllCards = false
                            self.m_start_btn:setVisible(true)
                            self.m_package_lab:setVisible(false)
                            self.m_package_sp:setVisible(false)
                            self.m_fanpai_node:setVisible(false)
                            self.m_isXipai = false
                            local index = 0
                            for i=1,10 do
                                local function sectionEnd( animNode, theId, theLabelName )
                                    --cclog2(index,"index")
                                    if theLabelName == "impact" then
                                        if index == 10 then
                                            self:createRefreshAnim()
                                        end
                                    end
                                end
                                local m_zjrAnim = game_util:createAnimEffect("gacha_anim_xiaoshi","gacha_anim_xiaoshi",sectionEnd);
                                if m_zjrAnim then
                                    local tempsize = self.m_show_node:getChildByTag(i):getContentSize()
                                    m_zjrAnim:setAnchorPoint(ccp(0.5,0.5));
                                    m_zjrAnim:setPosition(ccp(tempsize.width*0.5,tempsize.height*0.5));
                                    game_anim:playSection(m_zjrAnim,"impact")
                                    self.m_show_node:getChildByTag(i):addChild(m_zjrAnim,100)
                                    index = index + 1
                                end
                            end
                            game_util:addMoveTips({text = "Đã tạo mới thành công nhóm thẻ"})
                            self.m_getCard_btn:setVisible(false)
                        end
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("clone_lane_refresh_team"), http_request_method.GET, params,"clone_lane_refresh_team")
                end
            elseif btnTag == 105 then--刷新神秘奖励
                if self.m_isPlayAnim == false then
                    local t_params = 
                    {
                        title = "Nhắc nhở",
                        okBtnCallBack = function(target,event)
                            --cclog("rightBtnCallBack");
                            local function responseMethod( tag,gameData )
                               if gameData and tolua.type(gameData) == "util_json" then
                                    local data = gameData:getNodeWithKey("data")
                                    data= json.decode(data:getFormatBuffer())
                                    self.m_tGameData = data
                                    self:refreshData()
                                    local cardid = data.secret_reward[2] 
                                    --cclog2(cardid,"cardid")
                                    self:createSecretReward(cardid)
                                    --self:setPintuVisible()
                                    for i=1,9 do
                                        self.m_pintu_sprite_tab[i].m_pintu_sprite:setVisible(true)
                                        self.m_pintu_sprite_tab[i].m_pintu_sprite:removeAllChildrenWithCleanup(true)
                                    end
                                    game_util:addMoveTips({text = "Đã tạo mới thành công phần thưởng thần bí"})
                                end
                            end
                            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("clone_lane_refresh_secret"), http_request_method.GET, params,"clone_lane_refresh_secret") 
                            require("game_ui.game_pop_up_box").close(); 
                            --util_system:openUrlOutside(updataUrl);
                        end,   --可缺省
                        cancelBtnCallBack = function(target,event) 
                            --cclog("rightBtnCallBack") 
                            require("game_ui.game_pop_up_box").close();
                            
                        end,   --可缺省
                        okBtnText = "Xác nhận",       --可缺省
                        cancelBtnText = "Hủy",
                        text = "Tạo mới phần thưởng thần bí chứ?",      --可缺省
                        onlyOneBtn = true,          --可缺省
                    }
                    require("game_ui.game_pop_up_box").show(t_params);
                    
                end
            elseif btnTag == 106 then--开始洗牌
                if self.m_isPlayAnim == false then
                    self.m_isgetAllCards = false
                    self.m_isPlayAnim = true
                    self.m_package_btn:setVisible(false)
                    self.m_getCard_btn:setVisible(false)
                    self.m_package_lab:setVisible(false)
                    self.m_package_sp:setVisible(false)
                    self:startXiPai()
                    self:refreshUi(true)
                end
            elseif btnTag == 107 then--打包带走
                if self.m_isPlayAnim == false then
                    local function responseMethod( tag,gameData )
                        self.m_old_data = self.m_tGameData
                        local old_data = self.m_tGameData
                        self.m_isgetAllCards = true
                        if gameData and tolua.type(gameData) == "util_json" then
                            local data = gameData:getNodeWithKey("data")
                            data= json.decode(data:getFormatBuffer())

                            self.m_fanpai_node:setVisible(false)
                            self:createTenCards(old_data)
                            self.m_isXipai = false
                            self.m_new_gameData = data
                            self.m_tGameData = data
                            --cclog2(self.m_tGameData,"dabao   ====  ")
                            --self:refreshData()
                            self:refreshUi(true)
                            self:setPintuVisible()
                            --self:createSecretReward()
                            self:setProgress()
                            self.m_package_lab:setVisible(false)
                            self.m_package_sp:setVisible(false)
                            self.m_package_btn:setVisible(false)
                            --self.m_getCard_btn:setVisible(true)
                        end
                    end
                    --end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("clone_lane_pack"), http_request_method.GET, params,"clone_lane_pack")
                end
            elseif btnTag == 108 then--幸运牌盒
                if self.m_isPlayAnim == false then
                    local m_version = self.m_version
                    game_scene:addPop("game_cloneLane_luckyBox_pop",{m_version = m_version})
                end
            elseif btnTag == 109 then--重新发牌
                if self.m_isPlayAnim == false then
                    self.m_isgetAllCards = false
                    --cclog2(self.m_tGameData,"chognxin fapai ")
                    --self:refreshData()
                    self:refreshUi()
                    self.m_old_data = self.m_tGameData
                    
                    self.m_package_lab:setVisible(false)
                    self.m_package_sp:setVisible(false)
                    self.m_getCard_btn:setVisible(false)
                    local index = 0
                    for i=1,10 do
                        local function sectionEnd( animNode, theId, theLabelName )
                            if theLabelName == "impact" then
                                if index == 10 then
                                    self.m_isXipai= false
                                    
                                    --self.m_start_btn:setVisible(true)
                                    self:firstOpenAnim()
                                end
                            end
                        end
                        local m_zjrAnim = game_util:createAnimEffect("gacha_anim_xiaoshi","gacha_anim_xiaoshi",sectionEnd);
                        if m_zjrAnim then
                            local tempsize = self.m_show_node:getChildByTag(i):getContentSize()
                            m_zjrAnim:setAnchorPoint(ccp(0.5,0.5));
                            m_zjrAnim:setPosition(ccp(tempsize.width*0.5,tempsize.height*0.5));
                            game_anim:playSection(m_zjrAnim,"impact")
                            self.m_show_node:getChildByTag(i):addChild(m_zjrAnim,100)
                            index = index + 1
                        end
                    end
                    self.m_getCard_btn:setVisible(false)
                    self.m_package_btn:setVisible(false)
                    --self.m_start_btn:setVisible(true)
                end
            end
        end
    --end
    ccbNode:registerFunctionWithFuncName("onBtnClick",onBtnClick);
    ccbNode:openCCBFile("ccb/ui_clongLane_main1.ccbi");
    self.m_conutdownTime_node = ccbNode:nodeForName("m_conutdownTime_node")
    self.m_fanpai_node = ccbNode:nodeForName("m_fanpai_node")
    self.m_fanpai_node:setVisible(false)
    self.m_show_node = ccbNode:nodeForName("m_show_node")
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_detail_btn = ccbNode:controlButtonForName("m_detail_btn")
    self.m_information_btn = ccbNode:controlButtonForName("m_information_btn")
    self.m_current_btn = ccbNode:controlButtonForName("m_current_btn")
    self.m_refresh_btn = ccbNode:controlButtonForName("m_refresh_btn")
    self.m_other_node = ccbNode:nodeForName("m_other_node")
    self.m_scroll_view_tips = ccbNode:scrollViewForName("m_scroll_view_tips")
    self.m_tips_lab = ccbNode:labelTTFForName("m_tips_lab")
    self.m_allbtn_node = ccbNode:nodeForName("m_allbtn_node")
    self.m_start_btn = ccbNode:controlButtonForName("m_start_btn")
    self.m_package_btn = ccbNode:controlButtonForName("m_package_btn")
    self.m_getCard_btn = ccbNode:controlButtonForName("m_getCard_btn")
    self.m_toptips_node = ccbNode:controlButtonForName("m_toptips_node")
    self.m_package_sp = ccbNode:spriteForName("m_package_sp")
    self.m_getCard_btn:setTag(109)
    self.m_getCard_btn:setVisible(false)
    self.btn_small_refresh = ccbNode:controlButtonForName("btn_small_refresh")
    self.m_fanpai_lab = ccbNode:labelTTFForName("m_fanpai_lab")
    self.m_refresh_lab = ccbNode:labelTTFForName("m_refresh_lab")
    self.m_package_lab = ccbNode:labelTTFForName("m_package_lab")
    self.m_shangkuang_sp1 = ccbNode:spriteForName("m_shangkuang_sp1")
    self.m_shangkuang_sp2 = ccbNode:spriteForName("m_shangkuang_sp2")
    self.m_shangkuang_sp2:setVisible(false)
    self.m_mask_layer = ccbNode:layerColorForName("m_mask_layer");
    self.m_mask_layer:setVisible(false);
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_luckyBox_btn = ccbNode:controlButtonForName("m_luckyBox_btn")
    self.m_secret_reward_node = ccbNode:nodeForName("m_secret_reward_node")
    self.m_xingyunzhi_label = ccbNode:labelTTFForName("m_xingyunzhi_label")
    self.anim_node = ccbNode:nodeForName("anim_node")
    self.m_scroll_view_Secret = ccbNode:scrollViewForName("m_scroll_view_Secret");
    self.m_zhedang_node = ccbNode:nodeForName("m_zhedang_node")
    self.icon_1 = ccbNode:spriteForName("icon_1")
    
    local m_bg_sprite = ccbNode:spriteForName("m_bg_sprite")
    m_bg_sprite:setScale(resolution_config:getScale())

    local function onTouch2(eventType, x, y)
        if eventType == "began" then
            local new_card_count = #self.cardTeam_tab
            if new_card_count > 1 and self.m_gachaAnimEndFlag == true then
                    self:removeGachaAnim()
                self.m_mask_layer:setVisible(false);
            end
            if self.m_mask_layer:isVisible() then
                return true;--intercept event
            else
                return false
            end
        end
    end
    self.m_mask_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-20,true);
    self.m_mask_layer:setTouchEnabled(true)
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
    self.m_start_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
    self.m_package_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
    self.m_isPlayAnim = false
    self.m_pintu_sprite_tab = {}
    local m_pintu_sprite = nil
    for i=1,9 do
        m_pintu_sprite = ccbNode:spriteForName("m_pintu_sprite" .. i)
        m_pintu_sprite:setVisible(true)
        self.m_pintu_sprite_tab[i] = {m_pintu_sprite = m_pintu_sprite}
    end
    self.m_isXipai = false
    self:setTopTips()
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
function game_cloneLane_main.createScrollViewTips(self,scroll_view_tips,tipsStrTab,loopFlag,openType, fontColor, fontSize)
    openType = openType or 1;
    fontSize = fontSize or 10
    if scroll_view_tips == nil or scroll_view_tips:getParent() == nil then
        return;
    end
    tipsStrTab = tipsStrTab or {};
    if #tipsStrTab == 0 then
        scroll_view_tips:getParent():setVisible(false);
        return;
    else
        scroll_view_tips:getParent():setVisible(true);
    end
    loopFlag = loopFlag == nil and true or loopFlag
    scroll_view_tips:getContainer():removeAllChildrenWithCleanup(true);
    local showIndex = 1;
    local scroll_view_size = scroll_view_tips:getViewSize();
    local containerNode = CCNode:create();
    scroll_view_tips:addChild(containerNode)
    scroll_view_tips:setTouchEnabled(false);
    local function getMsg(showIndex)
        local msg = "";
        if type(tipsStrTab[showIndex]) == "string" then
            msg = tipsStrTab[showIndex];
        elseif type(tipsStrTab[showIndex]) == "table" then
            msg = tipsStrTab[showIndex].msg or "";
        end
        return msg;
    end
    --CCRichLabelTTF:create(getMsg(showIndex),TYPE_FACE_TABLE.Arial_BoldMT,fontSize);
    local tempTipsLabel = CCRichLabelTTF:create(getMsg(showIndex),TYPE_FACE_TABLE.Arial_BoldMT,fontSize);
    if tempTipsLabel and fontColor then
        tempTipsLabel:setColor(fontColor)
    end
    tempTipsLabel:setPosition(ccp(scroll_view_size.width*0.5,-scroll_view_size.height))
    containerNode:addChild(tempTipsLabel)
    local function backCallFunc( node )
        showIndex = showIndex + 1
        scroll_view_tips:getParent():setVisible(true);
        if showIndex > #tipsStrTab then
            if loopFlag == true then
                showIndex = 1;
            else
                tempTipsLabel:removeFromParentAndCleanup(true);
                scroll_view_tips:getParent():setVisible(false);
            end
        end
        tempTipsLabel:setString(getMsg(showIndex))
        tempTipsLabel:setPosition(ccp(scroll_view_size.width*0.5,-scroll_view_size.height))
    end
    local function visibleCallFunc( node )
        scroll_view_tips:getParent():setVisible(false);
    end
    local animArr = CCArray:create();
    animArr:addObject(CCEaseIn:create(CCMoveTo:create(0.5,ccp(scroll_view_size.width*0.5,scroll_view_size.height*0.5)),5));
    -- animArr:addObject(CCFadeOut:create(0.5));
    -- animArr:addObject(CCFadeIn:create(0.5));
    animArr:addObject(CCDelayTime:create(5));
    animArr:addObject(CCEaseIn:create(CCMoveTo:create(0.5,ccp(scroll_view_size.width*0.5,scroll_view_size.height*2)),5));
    if openType == 2 then
        animArr:addObject(CCCallFuncN:create(visibleCallFunc));
        animArr:addObject(CCDelayTime:create(5));
    end
    animArr:addObject(CCCallFuncN:create(backCallFunc));
    tempTipsLabel:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
end
--[[--
    设置上面的滚动提示
]]
function game_cloneLane_main.setTopTips(self)
    local tipsTab = {}
    local logs = self.m_tGameData.logs.logs
    for k,v in pairs(logs) do
        tipsTab[k] = v .. ""
    end
    self.m_scroll_view_tips:getContainer():removeAllChildrenWithCleanup(true)
    self:createScrollViewTips(self.m_scroll_view_tips,tipsTab)
end
--[[--
    设置进度条
]]
function game_cloneLane_main.setProgress( self )

    local expBg = self.icon_1
    local expBgSize = expBg:getContentSize(); 
    local current_score = self.m_tGameData.score
    local score_max = self.m_tGameData.score_max
    self.m_xingyunzhi_label:setString(current_score .. "/" .. score_max)
    local percentage = current_score/score_max * 100  
    local params = {}
    params.percentage = percentage
    params.fileName = "CL_jinduqiu2.png"
    params.type =  kCCProgressTimerTypeVerticalBarBT
    params.midpoint = ccp(expBgSize.width*0.5,0)
    params.barChangeRate = ccp(0,1)
    local expBarAdd = game_util:createProgressTimer(params)
    expBg:removeAllChildrenWithCleanup(true)
    expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
    expBg:addChild(expBarAdd,2,1);
    -- body
end
--[[--
    设置拼图块是否显示
]]
function game_cloneLane_main.setPintuVisible( self,tag )
    for i=1,9 do
        --self.m_pintu_sprite_tab[i].m_pintu_sprite:removeAllChildrenWithCleanup(false)
        self.m_pintu_sprite_tab[i].m_pintu_sprite:removeAllChildrenWithCleanup(true)
    end
    --cclog2(self.m_tGameData.secret_land,"self.m_tGameData.secret_lan  === ")
    if next(self.m_tGameData.secret_land) then
        local secret_land_tab =self.m_tGameData.secret_land
        --cclog2(#secret_land_tab,"secret_land_tab  setPintuVisible== ")
        if #secret_land_tab == 9 and tag ~= true then
            self.m_isPlayAnim = true
            local m_zjrAnim 
            local function secFUN( animNode, theId, theLabelName )
                if theLabelName == "impact" then
                    self.m_secret_reward_node:setVisible(true)
                    self.m_zhedang_node:setVisible(false)
                    self.m_scroll_view_Secret:setVisible(false)
                    self.m_shangkuang_sp2:setVisible(true)
                    self.m_shangkuang_sp1:setVisible(false)
                    game_anim:playSection(m_zjrAnim,"impact2")
                    for i=1,9 do
                        self.m_pintu_sprite_tab[i].m_pintu_sprite:setVisible(false)
                    end
                elseif theLabelName == "impact2" then
                    animNode:getParent():removeAllChildrenWithCleanup(true)
                    self.m_isPlayAnim = false
                    self:addRewardCardAnim(self.m_tGameData.secret_reward[2])
                end
            end
             m_zjrAnim = game_util:createAnimEffect("anim_shenmikapai","anim_shenmikapai",secFUN, nil, true);
            if m_zjrAnim then
                local tempsize = self.m_secret_reward_node:getContentSize()
                m_zjrAnim:setAnchorPoint(ccp(0.5,0.5));
                m_zjrAnim:setPosition(ccp(tempsize.width*0.5,tempsize.height*0.5));
                game_anim:playSection(m_zjrAnim,"impact")
                self.m_secret_reward_node:addChild(m_zjrAnim,100)
            end
        else
            self.m_secret_reward_node:setVisible(false)
            self.m_scroll_view_Secret:setVisible(true)
            self.m_zhedang_node:setVisible(true)
            self.m_shangkuang_sp1:setVisible(true)
            self.m_shangkuang_sp2:setVisible(false)
            for k,v in pairs(self.m_tGameData.secret_land) do
                if self.m_pintu_sprite_tab[v].m_pintu_sprite:isVisible() == true then
                    self.m_isPlayAnim = true
                    local function secFUN( animNode, theId, theLabelName )
                        if theLabelName == "impact" then
                            self.m_isPlayAnim = false
                            self.m_pintu_sprite_tab[v].m_pintu_sprite:setVisible(false)
                        else
                            animNode:getParent():removeAllChildrenWithCleanup(true)
                            self.m_pintu_sprite_tab[v].m_pintu_sprite:removeAllChildrenWithCleanup(true)
                        end
                    end
                    local m_zjrAnim = game_util:createAnimEffect("anim_kapaipintu","anim_kapaipintu",secFUN);
                    if m_zjrAnim then
                        local tempsize = self.m_pintu_sprite_tab[v].m_pintu_sprite:getContentSize()
                        m_zjrAnim:setAnchorPoint(ccp(0.5,0.5));
                        m_zjrAnim:setPosition(ccp(tempsize.width*0.5,tempsize.height*0.5));
                        game_anim:playSection(m_zjrAnim,"impact")
                        self.m_pintu_sprite_tab[v].m_pintu_sprite:addChild(m_zjrAnim,100)
                    end
                end
            end
        end
    else
        for i=1,9 do
            self.m_pintu_sprite_tab[i].m_pintu_sprite:setVisible(true)
            self.m_pintu_sprite_tab[i].m_pintu_sprite:removeAllChildrenWithCleanup(false)
        end
        self.m_secret_reward_node:removeAllChildrenWithCleanup(true)
        -- self.m_scroll_view_Secret:getContainer():removeAllChildrenWithCleanup(true)
        self.m_shangkuang_sp1:setVisible(true)
        self.m_shangkuang_sp2:setVisible(false)
    end
end
function game_cloneLane_main.addRewardCardAnim(self,tempId)
    self.m_isPlayAnim = true
    local cardId = tempId 
    local cardData = {c_id=cardId,}
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(tempId));
    local currentUiName = game_scene:getCurrentUiName();
    local game_active_limit_pop = game_scene:getPopByName("game_active_limit_pop")
    if cardData == nil or heroCfg == nil or currentUiName == "game_gacha_scene" or game_active_limit_pop ~= nil then return false end
    local quality = heroCfg:getNodeWithKey("quality"):toInt();
    local animFile = "gacha_anim_1";
    if quality == 3 then
        animFile = "gacha_anim_2";
    elseif quality > 3 then
        animFile = "gacha_anim_3";
    else
        return false;
    end
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    local m_root_layer = CCLayerColor:create(ccc4(0, 0, 0, 100), visibleSize.width, visibleSize.height)
    local m_iAnim = zcAnimNode:create(animFile .. ".swf.sam",0,animFile .. ".plist");
    local function animEnd(animNode,theId,lableName)
        if lableName == "daiji" then
        elseif lableName == "xunhuan" then
            animNode:playSection("xunhuan");
            self.m_isPlayAnim = false
        elseif lableName == "fanpai" then
            game_sound:playUiSound("gacha")
            animNode:playSection("xunhuan");
            local animNode = self:createHeroListItemByCCB(cardData);
            animNode:setScale(1)
            if animNode then
                animNode:setPosition(ccp(visibleSize.width*0.5, visibleSize.height*0.5))
                self.m_secret_reward_node:setVisible(false)
                self.m_scroll_view_Secret:setVisible(true)
                self.m_zhedang_node:setVisible(true)
                self.m_shangkuang_sp1:setVisible(true)
                self.m_shangkuang_sp2:setVisible(false)
                -- for i=1,9 do
                --     self.m_pintu_sprite_tab[i].m_pintu_sprite:setVisible(true)
                -- end
                m_root_layer:addChild(animNode,20,20)
            end
        end
    end
    m_iAnim:registerScriptTapHandler(animEnd);
    m_iAnim:playSection("daiji");
    m_iAnim:setScale(1);
    m_iAnim:setPosition(ccp(visibleSize.width*0.5, visibleSize.width*0.5))
    local function animEndCallFunc()
        m_iAnim:playSection("fanpai");
    end
    local animArr = CCArray:create();
    animArr:addObject(CCMoveTo:create(0.1,ccp(visibleSize.width*0.5, visibleSize.height*0.5)));
    animArr:addObject(CCCallFunc:create(animEndCallFunc));
    m_iAnim:runAction(CCSequence:create(animArr));
    m_root_layer:addChild(m_iAnim,10,10);
    local function onTouch(eventType, x, y)
        -- cclog("began 121212   ")
        if self.m_isPlayAnim == false then
            if eventType == "began" then
                -- cclog("began =======   ")
                m_root_layer:removeFromParentAndCleanup(true);
                self:createSecretReward()
                return true;--intercept event
            end
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 100,true);
    m_root_layer:setTouchEnabled(true);
    game_scene:getPopContainer():addChild(m_root_layer,1000,1000);
    return true;
end

function game_cloneLane_main.createTimeDown( self )
    local time_count_down = self.m_tGameData.time_count_down
    if self.m_tGameData.time_count_down then
        local function timeEndFunc()
        end 
        local countdownLabel = game_util:createCountdownLabel(time_count_down,timeEndFunc,8, 1);
        countdownLabel:setColor(ccc3(0, 255, 0))
        countdownLabel:setAnchorPoint(ccp(0.5,0.5))
        local tempcontent = self.m_conutdownTime_node:getContentSize()
        countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.65))
        self.m_conutdownTime_node:addChild(countdownLabel,10,10) 
    end
    -- body
end
--[[--
    神秘奖励
]]
function game_cloneLane_main.createSecretReward(self,m_cardId)
    self.m_secret_reward_node:removeAllChildrenWithCleanup(true)
    self.m_scroll_view_Secret:getContainer():removeAllChildrenWithCleanup(true)
    self.m_shangkuang_sp1:setVisible(true)
    self.m_shangkuang_sp2:setVisible(false)
    local secret_reward =  self.m_tGameData.secret_reward
    local cardId = m_cardId or secret_reward[2] 
    local itemData = {c_id=cardId,}
    local itemSize = self.m_secret_reward_node:getContentSize()
    local card_ccbNode = self:createHeroListItemByCCB2(itemData,1);
    card_ccbNode:setPosition(itemSize.width*0.5,itemSize.height*0.35)
    self.m_secret_reward_node:addChild(card_ccbNode,10,10)
    self.m_secret_reward_node:setVisible(false)
    local card_ccbNode2 = self:createHeroListItemByCCB2(itemData,1);
    self.m_scroll_view_Secret:addChild(card_ccbNode2,10,10)
    self.m_scroll_view_Secret:setTouchEnabled(false)
    local posX,posY = card_ccbNode2:getPosition()
    card_ccbNode2:setPosition(ccp(posX-20,posY-40))
    self.m_zhedang_node:setVisible(true)
end

function game_cloneLane_main.createBlenderAnim( sam , id , plist , isblender )
    -- body
    local anim = zcAnimNode:create( sam , id , plist );
    if(isblender)then
        local blendFunc = anim:getBlendFunc();
        blendFunc.src = GL_SRC_ALPHA;
        blendFunc.dst = GL_ONE;
        anim:setBlendFunc(blendFunc);
    end
    return anim;
end

--[[--
    开始洗牌
]]
function game_cloneLane_main.startXiPai( self )
    self.m_start_btn:setVisible(false)
    -- self.m_package_btn:setVisible(true)
    self.m_isPlayAnim = true
    local pos = {-20,-10,0,10,20,30,40,50,60,70}
    local startPos = {}
    local function sectionEnd( animNode, theId, theLabelName )
        if theLabelName == "xipai" then
            local texiaoAnim = self.createBlenderAnim( "gacha_anim_texiao.swf.sam", 1, "gacha_anim_texiao.plist", true )
            if texiaoAnim then
                local tempsize = self.anim_node:getContentSize()
                texiaoAnim:setAnchorPoint(ccp(0.5,0.5));
                texiaoAnim:setPosition(ccp(tempsize.width*0.5,tempsize.height*0.1-20));
                game_anim:playSection(texiaoAnim,"dakai3")
                self.anim_node:addChild(texiaoAnim,11,11)
            end
            game_anim:playSection(animNode,"dakai3")
            for i=1,10 do
                local card_ccbNode = self.m_show_node:getChildByTag(i)
                local animArr = CCArray:create();
                if i<6 then
                    animArr:addObject(CCMoveTo:create(0.1,(ccp(pos[5],80))));
                    animArr:addObject(CCDelayTime:create(1-i * 0.1));   
                    animArr:addObject(CCMoveTo:create(0.5,(ccp(startPos[i].posX,startPos[i].posY))));
                else
                    animArr:addObject(CCMoveTo:create(0.1,(ccp(pos[5],80))));
                    animArr:addObject(CCDelayTime:create((i-1) * 0.1));
                    animArr:addObject(CCMoveTo:create(0.5,(ccp(startPos[i].posX,startPos[i].posY))));
                end
                local button = game_util:createCCControlButton("CL_cardsBg.png","",onBtnCilck)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setScale(2)
                button:setZoomOnTouchDown(false)
                button:setPosition( card_ccbNode:getContentSize().width * 0.5, card_ccbNode:getContentSize().height * 0.5 )
                button:setOpacity(255)
                card_ccbNode:addChild(button)
                card_ccbNode:runAction(CCSequence:create(animArr));

            end
        elseif theLabelName == "dakai3" then
            self.m_isXipai = true
            self.m_package_btn:setVisible(true)
            self.m_package_lab:setVisible(true)
            self.m_package_sp:setVisible(true)
            self:createTenCards()
            self.m_isPlayAnim = false
        end
    end

    local function moveEndFunc( node )
        local z_zjrAnim = game_util:createAnimEffect("gacha_anim_kabao","gacha_anim_kabao",sectionEnd,nil,true);
        if z_zjrAnim then
            local tempsize = self.anim_node:getContentSize()
            z_zjrAnim:setAnchorPoint(ccp(0.5,0.5));
            z_zjrAnim:setPosition(ccp(tempsize.width*0.5,tempsize.height*0.1-20));
            game_anim:playSection(z_zjrAnim,"xipai")
            self.anim_node:addChild(z_zjrAnim,10,10)
        end
        
        self.m_isXipai = true
    end

    for i=1,10 do
        local x,y = self.m_show_node:getChildByTag(i):getPosition()
        startPos[i] = {posX = x, posY = y}
        local animArr = CCArray:create();
        if i<6 then
            animArr:addObject(CCDelayTime:create(1-i * 0.1));
            animArr:addObject(CCMoveTo:create(0.5,(ccp(pos[i],80))));
            animArr:addObject(CCDelayTime:create(0.2));
        else
            animArr:addObject(CCDelayTime:create((i-1) * 0.1));
            animArr:addObject(CCMoveTo:create(0.5,(ccp(pos[i],80))));
            animArr:addObject(CCDelayTime:create(0.2));
            if i == 10 then
                local moveEnd = CCCallFuncN:create(moveEndFunc);
                animArr:addObject(moveEnd)
            end
        end
        self.m_show_node:getChildByTag(i):runAction(CCSequence:create(animArr));
        
    end
    self.m_start_btn:setVisible(false)
    -- self.m_package_lab:setVisible(true)
    -- self.m_package_sp:setVisible(true)
    self.m_fanpai_node:setVisible(true)
end

function game_cloneLane_main.getZorder( self,i )
    local zorder = 0 
    if i > 5 then 
        zorder = 11-i
    else
        zorder = i
    end
    return zorder
end
--[[--
    开场动画
]]
function game_cloneLane_main.firstOpenAnim( self )
    self.m_isPlayAnim = true
    self.m_allbtn_node:setVisible(false)
    self.m_other_node:setVisible(false)
    self.m_package_sp:setVisible(false)
    self.m_package_lab:setVisible(false)
    self.m_getCard_btn:setVisible(false)
    self.m_show_node:removeAllChildrenWithCleanup(true)
    
    local function sectionEnd( animNode, theId, theLabelName )
       
         animNode = self.m_zjrAnim
        if theLabelName == "kaichang" then
            game_anim:playSection(animNode,"daiji1")
            local function onBtnCilck( event, target )
                local tagNode = tolua.cast(target, "CCNode");
                game_anim:playSection(animNode,"impact1")
                tagNode:setVisible(false)
            end
            local button = game_util:createCCControlButton("CL_cardsBg.png","",onBtnCilck)
            button:setAnchorPoint(ccp(0.5,0.5))
            button:setScale(2)
            button:setZoomOnTouchDown(false)
            button:setOpacity(0)
            button:setVisible(true)
            button:setPosition( animNode:getContentSize().width * 0.5, animNode:getContentSize().height * 0.5 )
            animNode:addChild(button)
        elseif  theLabelName == "daiji1" then
            game_anim:playSection(animNode,"daiji1")
        elseif  theLabelName == "impact1" then
            local texiaoAnim = self.createBlenderAnim( "gacha_anim_texiao.swf.sam", 1, "gacha_anim_texiao.plist", true )
            if texiaoAnim then
                local tempsize = self.anim_node:getContentSize()
                texiaoAnim:setAnchorPoint(ccp(0.5,0.5));
                texiaoAnim:setPosition(ccp(tempsize.width*0.5,tempsize.height*0.1-20));
                game_anim:playSection(texiaoAnim,"dakai1")
                self.anim_node:addChild(texiaoAnim,11,11)
            end
            game_anim:playSection(animNode,"dakai1")
            self:cardsatMid()
            self:cardsGoBack()
            self.m_allbtn_node:setVisible(true)
            self.m_other_node:setVisible(true)
           
        else
            self.anim_node:removeAllChildrenWithCleanup(true)
            self.m_zjrAnim = nil
            self.m_isPlayAnim = false
            self.m_start_btn:setVisible(true)
            self.m_package_lab:setVisible(false)
        end
    end
    self.m_zjrAnim = game_util:createAnimEffect("gacha_anim_kabao","gacha_anim_kabao",sectionEnd);
    if self.m_zjrAnim then
        local tempsize = self.anim_node:getContentSize()
        self.m_zjrAnim:setAnchorPoint(ccp(0.5,0.5));
        self.m_zjrAnim:setPosition(ccp(tempsize.width*0.5,tempsize.height*0.1));
        game_anim:playSection(self.m_zjrAnim,"kaichang")
        self.anim_node:addChild(self.m_zjrAnim)
    end
end
--[[--
    刷新数据    
]]  
function game_cloneLane_main.refreshData( self )
    self.cardTeam_tab = self.m_tGameData.card_team
    self.m_card_team = self.m_tGameData.card_team or {}
    self.m_show_team = self.m_tGameData.show_team or {}
    self.own_card_team = self.m_tGameData.own_card_team or {}
    self.init_card_team = self.m_tGameData.one_times or false
    self.m_open_times = self.m_tGameData.open_times or 1
    self.m_package_num = #self.m_card_team or 10
    self.m_version = self.m_tGameData.version or 1
    self.m_refresh_time = self.m_tGameData.refresh_times or 1
end

function game_cloneLane_main.refreshLabel( self )
    local clone_lane_config = getConfig(game_config_field.clone_lane)
    clone_lane_config = json.decode(clone_lane_config:getFormatBuffer())
    local price_tab = clone_lane_config[tostring(self.m_version)].price
    local price_all_tab = clone_lane_config[tostring(self.m_version)].price_all
    
    local price = price_tab[tonumber(self.m_open_times)+1] or 300
    --cclog2(price_all_tab,"price_all_tab ===")
    --cclog2(self.m_package_num,"m_package_num === ")
    local price_all = price_all_tab[11-tonumber(self.m_package_num)] or 0
    if self.m_refresh_time > -1 and self.m_refresh_time<5  then
        local refresh_tab = clone_lane_config[tostring(self.m_version)].cost
        local refresh_cost = refresh_tab[tonumber(self.m_refresh_time)+1]
        self.m_refresh_lab:setString(tostring(refresh_cost))
        -- cclog2(refresh_cost,"cost === ")
    else
        self.m_refresh_lab:setString("300")
    end
    local des = clone_lane_config[tostring(self.m_version)].des
    local des1 = clone_lane_config[tostring(self.m_version)].des_1
    if self.m_tGameData.score < self.m_tGameData.score_max then
        self.m_tips_lab:setString(des)
        self.m_tips_lab:setColor(ccc3(255,255,255))
    else
        self.m_tips_lab:setString(des1)
        self.m_tips_lab:setColor(ccc3(0,255,0))
    end

    self.m_package_lab:setString(tostring(price_all))
    self.m_fanpai_lab:setString(tostring(price))
    
    -- body
end
--[[--
    进入界面 创建十张卡牌

]]
function game_cloneLane_main.createTenCards(self,old_data)
    self.m_show_node:removeAllChildrenWithCleanup(true);

    self.m_zjrAnim1 = {}
    local function RanimCallBack1( animNode, theId, theLabelName )
        --animNode = self.m_zjrAnim1
        local parent = animNode:getParent()
        local tag = parent:getTag()
        
        if theLabelName == "fanpai2" then
            --cclog2(tag,"tag")
            -- for i=1,10 do
                -- self.m_show_node:getChildByTag(tag):setVisible(true)
            -- end
            self.cardTable[tag].cardnode_1:setVisible(true)
            if tag == 10 then
                self.m_getCard_btn:setVisible(true)
            end

            game_anim:playSection(parent,"xunhuan")
        elseif theLabelName == "xunhuan" then
            parent:removeAllChildrenWithCleanup(true)
            self.m_isPlayAnim = false
            
        end
    end
    for i=1,10 do
        local card_ccbNode = nil;
        local zorder  = self:getZorder(i)
        local button = nil;
        --cclog2(self.own_card_team,"self.own_card_team  == ")
        if next(self.own_card_team)  and old_data == nil then --看是否有反过来的牌
            --cclog2(old_data,"old_data === ")
            self.m_isXipai = true
            self.m_fanpai_node:setVisible(true)
            self.m_start_btn:setVisible(false)
            self.m_package_lab:setVisible(true)
            self.m_package_sp:setVisible(true)
            for k,v in pairs(self.m_tGameData.own_card_team) do
                --未翻过的卡牌 背面
                if tonumber(k+1) ~= i  then
                    card_ccbNode = self:createCards(i,false)
                    card_ccbNode:setPosition(self:setCircleByIndex(i))
                    button = self:createCardsButton2(i,false,card_ccbNode)
                    self.m_show_node:addChild(card_ccbNode,zorder,i)
                else
                -- 已翻过的卡牌 正面 如果有 结束本次遍历，防止重复进入↑的函数
                    card_ccbNode = self:createCards(i,true,true)
                    card_ccbNode:setPosition(self:setCircleByIndex(i))
                    button = self:createCardsButton2(i,true,card_ccbNode)
                    self.m_show_node:addChild(card_ccbNode,zorder,i)
                    self.m_zjrAnim = game_util:createAnimEffect("gacha_anim_guixiang_3", "gacha_anim_guixiang_3", sectionEnd)
                    if self.m_zjrAnim then
                        local tempsize = card_ccbNode:getContentSize()
                        self.m_zjrAnim:setAnchorPoint(ccp(0.5,0.5));
                        self.m_zjrAnim:setPosition(self:setCircleByIndex(i));
                        self.m_zjrAnim:setScale(0.5)
                        game_anim:playSection(self.m_zjrAnim,"xunhuan")
                        self.m_show_node:addChild(self.m_zjrAnim,zorder-1,i)
                    end
                    break
                end
            end
        elseif self.m_isXipai == false then
            self.m_package_lab:setVisible(false)
            self.m_package_sp:setVisible(false)
            card_ccbNode = self:createCards(i,true)
            card_ccbNode:setPosition(self:setCircleByIndex(i))
            button = self:createCardsButton2(i,true,card_ccbNode)
            self.m_show_node:addChild(card_ccbNode,zorder,i)
        elseif old_data then
            -- local function RanimCallBack1( animNode, theId, theLabelName )
            --     --animNode = self.m_zjrAnim1
            --     if theLabelName == "fanpai2" then
            --         --for i=1,10 do
            --             self.m_show_node:getChildByTag(i):setVisible(true)
            --         --end
                    
            --         game_anim:playSection(animNode:getParent(),"xunhuan")
            --     elseif theLabelName == "xunhuan" then
            --         animNode:getParent():removeAllChildrenWithCleanup(true)
            --     end
            -- end
            card_ccbNode = self:createCards(i,_,_,old_data)
            card_ccbNode:setPosition(self:setCircleByIndex(i))
            button = self:createCardsButton2(i,true,card_ccbNode)
            self.m_show_node:addChild(card_ccbNode,zorder,i)
            self.m_isPlayAnim = true
            self.m_zjrAnim1[i] = game_util:createAnimEffect("gacha_anim_guixiang_3", "gacha_anim_guixiang_3", RanimCallBack1)
            self.m_zjrAnim1[i]:setTag(i)
            if self.m_zjrAnim1[i] then
                local tempsize = card_ccbNode:getContentSize()
                self.m_zjrAnim1[i]:setAnchorPoint(ccp(0.5,0.5));
                self.m_zjrAnim1[i]:setPosition(self:setCircleByIndex(i));
                self.m_zjrAnim1[i]:setScale(0.5)
                self.m_show_node:getChildByTag(i):setVisible(false)
                
                local animArr = CCArray:create();
                local function animEndCallFunc()
                --self.m_show_node:getChildByTag(i):setVisible(false)
                   game_anim:playSection(self.m_zjrAnim1[i],"fanpai2")

                end
                animArr:addObject(CCDelayTime:create(0.1 * i));
                animArr:addObject(CCCallFunc:create(animEndCallFunc));
                self.m_show_node:getChildByTag(i):runAction(CCSequence:create(animArr));
                self.m_show_node:addChild(self.m_zjrAnim1[i],zorder-1)
            end
        else
            card_ccbNode = self:createCards(i,false)
            card_ccbNode:setPosition(self:setCircleByIndex(i))
            button = self:createCardsButton2(i,false,card_ccbNode)
            self.m_show_node:addChild(card_ccbNode,zorder,i)
        end
        --self.m_show_node:addChild(card_ccbNode,zorder,i)
        self.cardTable[i] = {cardnode_1 = card_ccbNode,cardnode_1_zorder = zorder,cardnode_1_button = button}
    end
        --cclog2(self.cardTable[i],"cardTable i ==== ")
end
--[[--
    创建卡牌

]]
function game_cloneLane_main.createCards( self,index ,flag,oneTrue,old_data)
    local cardid = 8100
    if flag == true then -- 创建正面有人的卡牌
        if oneTrue then
        --cclog2(index,"index == ") 
            cardid = self.m_tGameData.own_card_team[tostring(index-1)][2]
        else 
            cardid = self.m_show_team[tonumber(index)][2]
        end
        local itemData = {c_id=cardid,}
        local card_ccbNode = self:createHeroListItemByCCB(itemData,true);
        return card_ccbNode
    elseif old_data then 
        --cclog2(old_data,"old_data createCards ==")
        cardid = old_data.show_team[tonumber(index)][2]
        local itemData = {c_id=cardid,}
        local card_ccbNode = self:createHeroListItemByCCB(itemData,true);
        return card_ccbNode
    else --flag == false then --创建背面没人的卡牌
        cardid = self.m_show_team[tonumber(index)][2]
        local itemData = {c_id=cardid,}--背面不展示，所以是任意有效的cid都可以
        local card_ccbNode = self:createHeroListItemByCCB(itemData,false);
        return card_ccbNode
    end    
    -- body
end
--[[--
    创建卡牌按钮 
]]
function game_cloneLane_main.createCardsButton2( self,i,flag,card_ccbNode )
    function onBtnCilck( event, target )
        if self.m_isXipai == false then
            game_util:addMoveTips({text = "Xin chẻ bài trước!"})
        else
            -- cclog2(self.m_network_flag,"self.m_network_fla === ")
            -- cclog2(self.m_isPlayAnim,"self.m_isPlayAnim ")
            if self.m_isPlayAnim == false and self.m_network_flag == false then
                local tagNode = tolua.cast(target, "CCNode");
                local btnTag = tagNode:getTag();
                print("press button tag is ", btnTag)
                local function responseMethod(tag,gameData )
                    if gameData and tolua.type(gameData) == "util_json" then
                        self.m_network_flag = false
                        local data = gameData:getNodeWithKey("data")
                        data= json.decode(data:getFormatBuffer())
                        self.m_tGameData = data
                        self.m_old_data = self.m_tGameData
                        --self:refreshData()
                        self:refreshUi(true)
                        self:setPintuVisible()
                        --self:createSecretReward()
                        if data.own_card_team then
                            local tempnode = self.m_show_node:getChildByTag(btnTag)
                            local tempnode_zorder = self:getZorder(btnTag)
                            self.m_show_node:reorderChild(tempnode,tempnode_zorder)
                            local cardid =  data.own_card_team[tostring(btnTag-1)][2]
                            local itemData = {c_id=cardid,}
                            local itemSize = self.m_show_node:getContentSize()
                            local openCard_node = self:createHeroListItemByCCB(itemData,true,1);
                            openCard_node:setPosition(self:setCircleByIndex(btnTag))
                            openCard_node:setVisible(false)
                            local function sectionEnd( animNode, theId, theLabelName )
                                animNode = self.m_zjrAnim
                                if theLabelName == "daiji" then
                                    openCard_node:setVisible(true)
                                    game_anim:playSection(animNode,"fanpai2")
                                elseif theLabelName == "daiji2" then
                                    openCard_node:setVisible(true)
                                    game_anim:playSection(animNode,"daiji2")

                                elseif theLabelName == "xunhuan" then
                                    self.cardTable[btnTag].cardnode_1 = nil;
                                    
                                    if #self.m_tGameData.card_team == 0 then
                                        self.m_old_data = self.m_tGameData
                                        local function responseMethod( tag,gameData )
                                            local data = gameData:getNodeWithKey("data")
                                            data= json.decode(data:getFormatBuffer())
                                            self.m_isgetAllCards = true
                                            self.m_new_gameData = data
                                            self.m_tGameData = data
                                            self:refreshData()
                                            self.m_isXipai= false
                                            self.m_refresh_lab:setVisible(true)
                                            self.m_getCard_btn:setVisible(true)
                                            self.m_package_lab:setVisible(false)
                                            self.m_package_sp:setVisible(false)
                                            self.m_package_btn:setVisible(false)
                                        end
                                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("clone_lane_clean_data"), http_request_method.GET, params,"clone_lane_clean_data")
                                    end
                                elseif theLabelName == "fanpai" then
                                    openCard_node:setVisible(true)
                                    game_anim:playSection(animNode,"xunhuan")
                                    self.m_isPlayAnim = false
                                end
                            end
                            self.m_zjrAnim = game_util:createAnimEffect("gacha_anim_guixiang_3", "gacha_anim_guixiang_3", sectionEnd)
                            if self.m_zjrAnim then
                                local tempsize = self.m_show_node:getChildByTag(btnTag):getContentSize()
                                self.m_zjrAnim:setAnchorPoint(ccp(0.5,0.5));
                                self.m_zjrAnim:setPosition(ccp(tempsize.width*0.5,tempsize.height*0.5));
                                self.m_isPlayAnim = true
                                game_anim:playSection(self.m_zjrAnim,"fanpai")
                                tempnode:addChild(self.m_zjrAnim,11,22)
                            end
                            local openCard_node_zorder = self:getZorder(btnTag)
                            self.m_show_node:addChild(openCard_node,openCard_node_zorder,btnTag)

                        end
                        self.own_card_team = self.m_tGameData.own_card_team
                        --cclog2(#self.m_tGameData.card_team,"self.#self.cardTeam_tab#self.cardTeam_tab.score --")
                    else
                        self.m_network_flag = false
                        self.m_isPlayAnim = false
                    end
                    
                end
                local params = {}
                params.sort = btnTag-1
                self.m_network_flag = true
                --require("game_ui.game_loading").show({opacity = 1}); 
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("clone_lane_draw"), http_request_method.GET, params,"clone_lane_draw",false,true)
            end
        end
    end
    local button = game_util:createCCControlButton("CL_cardsBg.png","",onBtnCilck)
    button:setAnchorPoint(ccp(0.5,0.5))
    button:setScale(2)
    button:setZoomOnTouchDown(false)
    button:setPosition( card_ccbNode:getContentSize().width * 0.5, card_ccbNode:getContentSize().height * 0.5 )
    if i<5 then
        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-(1+i))
    else
        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-(1-i))
    end
    button:setTag(i)
    if flag == true then --按钮透明度设置为0
        button:setOpacity(0)
    else --按钮遮挡卡牌
        button:setOpacity(255)
    end
    card_ccbNode:addChild(button)
    return button
end

--[[--
    创建卡牌位置
]]
function game_cloneLane_main:setCircleByIndex( index )

    local R = 230
    local a = 200
    local i = index-1
     -- a = 270 + math.abs(i - self.m_control.m_model.index)/(i - self.m_control.m_model.index) *(40 - 60/(2+math.abs(i - self.m_control.m_model.index)))
     a = 190+(i*16)
        
        --self["icon_"..i]:runAction(CCMoveTo:create(0.2,ccp(R*math.cos(math.rad(a)),R*math.sin(math.rad(a))))  )
    if index>5 then
        i = i+1
        a = 190+(i*16)
        return ccp(R/1.3*math.cos(math.rad(a))+45,R/2*math.sin(math.rad(a))+25)
    else
        return ccp(R/1.3*math.cos(math.rad(a))-5,R/2*math.sin(math.rad(a))+25)
    end
end
function game_cloneLane_main.removeGachaAnim(self)
    self.m_mask_layer:removeAllChildrenWithCleanup(true);
    self.m_gachaAnimTab = {};
end
function game_cloneLane_main.addGachaAnim2(self,index)
    self.m_mask_layer:setVisible(true);
    local m_delayTimeIndex = 0.5 + 1;
      local tempIndex = (index - 1) % 10 + 1
    if index > 1 and tempIndex == 1 then
        m_delayTimeIndex = 0;
        self:removeGachaAnim();
    end
    local new_card_count = #self.cardTeam_tab
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    local itemData = {c_id=self.cardTeam_tab[index][2],}
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local itemCfg = character_detail_cfg:getNodeWithKey(tostring(self.cardTeam_tab[index][2]));
    local quality =itemCfg:getNodeWithKey("quality"):toInt()
    local animFile = "gacha_anim_1";
    if quality == 3 then
        animFile = "gacha_anim_2";
    elseif quality > 3 then
        animFile = "gacha_anim_3";
        game_sound:playUiSound("gacha")
    end
    local tempNode = CCNode:create();
    local m_iAnim = zcAnimNode:create(animFile .. ".swf.sam",0,animFile .. ".plist");
    local xunhuanCount = 1;
    local function animEnd(animNode,theId,lableName)
        if lableName == "daiji" then

        elseif lableName == "xunhuan" then
            xunhuanCount = xunhuanCount + 1;
            if xunhuanCount == 3 then
                animNode:playSection("daiji2");
                if tempIndex < 6 then
                    tempNode:runAction(CCMoveTo:create(0.1,ccp(visibleSize.width*(0.2*tempIndex - 0.1), visibleSize.height*0.75)))
                else
                    tempNode:runAction(CCMoveTo:create(0.1,ccp(visibleSize.width*(0.2*(tempIndex-5) - 0.1), visibleSize.height*0.25)))
                end
                index = index + 1;
                m_delayTimeIndex = 0;
                if index <= new_card_count then
                    if index > 10 and tempIndex == 10 then
                        local function callback()
                            self:addGachaAnim2(index);
                        end
                        local animArr = CCArray:create();
                        animArr:addObject(CCDelayTime:create(2));
                        animArr:addObject(CCCallFunc:create(callback));
                        self.m_root_layer:runAction(CCSequence:create(animArr));
                    else
                        self:addGachaAnim2(index);
                    end
                else
                    self.m_gachaAnimEndFlag = true;
                end
            else
                animNode:playSection("xunhuan");
                --animNode:setRhythm(0.5)
            end
        elseif lableName == "fanpai2" then
            local ccbNode = self:createHeroListItemByCCB(itemData);
            ccbNode:setScale(0.7)
            tempNode:addChild(ccbNode);
            if quality > 3 then
                animNode:playSection("xunhuan");
                animNode:setRhythm(0.5)
            else
                animNode:playSection("daiji");
                if tempIndex < 6 then
                    tempNode:runAction(CCSpawn:createWithTwoActions(CCScaleTo:create(0.05,0.8),CCMoveTo:create(0.05,ccp(visibleSize.width*(0.2*tempIndex - 0.1), visibleSize.height*0.75))))
                else
                    tempNode:runAction(CCSpawn:createWithTwoActions(CCScaleTo:create(0.05,0.8),CCMoveTo:create(0.05,ccp(visibleSize.width*(0.2*(tempIndex-5) - 0.1), visibleSize.height*0.25))))
                end
                -- index = index + 1;
                -- if index <= new_card_count then
                --     self:addGachaAnim2(index);
                -- end
            end
        end
    end
    m_iAnim:registerScriptTapHandler(animEnd);
    m_iAnim:playSection("daiji");
    tempNode:setPosition(ccp(20,80))
    local function animEndCallFunc()
        if quality > 3 then
        else
            index = index + 1;
            if index <= new_card_count then
                if index > 10 and tempIndex == 10 then
                    local function callback()
                        self:addGachaAnim2(index);
                    end
                    local animArr = CCArray:create();
                    animArr:addObject(CCDelayTime:create(2));
                    animArr:addObject(CCCallFunc:create(callback));
                    self.m_root_layer:runAction(CCSequence:create(animArr));
                else
                    self:addGachaAnim2(index);
                end
            else
                self.m_gachaAnimEndFlag = true;
            end
        end
        m_iAnim:playSection("fanpai2");
    end
    --cclog("addGachaAnim ======================== " .. animFile);
    local animArr = CCArray:create();
    animArr:addObject(CCDelayTime:create(0.01*m_delayTimeIndex));
    tempNode:setScale(0.8);
    animArr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.05,1),CCMoveTo:create(0.05,ccp(visibleSize.width*0.5, visibleSize.height*0.5))));
    animArr:addObject(CCCallFunc:create(animEndCallFunc));
    tempNode:runAction(CCSequence:create(animArr));
    tempNode:addChild(m_iAnim);
    self.m_mask_layer:addChild(tempNode,10,10);
    self.m_gachaAnimTab[#self.m_gachaAnimTab+1] = tempNode
end
function game_cloneLane_main.createPop(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag ==1 then--关闭
            if self.m_popUi then
                self.m_popUi:removeFromParentAndCleanup(true);
                self.m_popUi = nil;
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_gacha_reward_pop.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_list_view_bg:addChild(self:createCardTableView(m_list_view_bg:getContentSize()))
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+1,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_cloneLane_main.refreshUi(self,old_Secret)
    self:refreshData()
    self:refreshLabel()
    self:setProgress()
    --self:setPintuVisible()
    if old_Secret ~= true then
        self:createSecretReward()
    end
end

--[[--
    初始化
]]
function game_cloneLane_main.init(self,t_params)
    t_params = t_params or {};
    self.cardTable = {};
    self.cardTeam_tab = {};
    self.m_gachaAnimTab = {};
    self.m_gachaAnimEndFlag = false;
    self.m_isPlayAnim = false;
    self.m_network_flag = false;
    -- body
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
        self.m_old_data = self.m_tGameData or {}
        self.cardTeam_tab = self.m_tGameData.card_team
        self.m_card_team = self.m_tGameData.card_team or {}
        self.m_show_team = self.m_tGameData.show_team or {}
        self.own_card_team = self.m_tGameData.own_card_team or {}
        self.init_card_team = self.m_tGameData.one_times or false
    else
        self.m_tGameData = {};
    end
    --cclog2(#self.cardTeam_tab,"self.cardTeam_tab  === ")
end

--[[--
    创建ui入口并初始化数据
]]
function game_cloneLane_main.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    if self.init_card_team == true then
        self.m_start_btn:setVisible(false)
        self.m_package_btn:setVisible(false)
        self.m_getCard_btn:setVisible(false)
        self:firstOpenAnim()
    else
        self:createTenCards()
    end
    self:createTimeDown()
    self:refreshUi();
    self:setPintuVisible(true)
    return scene;
end

return game_cloneLane_main;