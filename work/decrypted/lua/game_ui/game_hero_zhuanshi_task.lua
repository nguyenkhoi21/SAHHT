---  转世
local game_hero_zhuanshi_task = {
    m_tGameData = nil,
    m_task_tab = nil,
    m_major = nil,
    m_userData = nil,
    m_exp_label = nil,
    m_lightning_label = nil,
    m_card_world_task = nil,
    falg = nil,
    firstflag = nil,
    secondflag = nil,
};
--[[--
    销毁
]]
function game_hero_zhuanshi_task.destroy(self)
    -- body
    cclog("-----------------game_hero_zhuanshi_task destroy-----------------");
    self.m_tGameData = nil;
 	self.m_task_tab = nil;
    self.m_major = nil;
    self.m_userData = nil;
    self.m_exp_label = nil;
    self.m_lightning_label = nil;
    self.card_world_task = nil;
    self.falg = nil;
    self.firstflag = nil;
    self.secondflag = nil;
end
--[[--
    返回
]]
function game_hero_zhuanshi_task.back(self)
    game_scene:enterGameUi("game_hero_zhuanshi",{gameData = self.m_tGameData});
end
--[[--
    读取ccbi创建ui
]]
function game_hero_zhuanshi_task.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )

        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag ==  ")
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 12 then --伙伴
            game_scene:enterGameUi("game_hero_list",{gameData = nil,openType = "zhuanshi",showIndex= 1,zhuanshiData = self.m_tGameData});
            self:destroy();
        elseif btnTag == 13 then --阵型
            game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="zhuanshi",zhuanshiData = self.m_tGameData});
            self:destroy();
        elseif btnTag == 100 then--装备
            game_scene:enterGameUi("equipment_list",{gameData = nil,openType = "zhuanshi",showIndex= 1,zhuanshiData = self.m_tGameData});
            self:destroy();
        elseif btnTag == 101 then --选择要转世的伙伴
            -- cclog("addSelHeroUi posIndex ==" .. tostring(posIndex))
            self:addZhuanshiHero()
        elseif btnTag == 200 then--刷新
        elseif 200 < btnTag and btnTag < 208 then--任务一
            self:sendMyHttpRequest(btnTag)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_hero_zhuanshi_task.ccbi");
    game_util:setPlayerPropertyByCCBAndTableData2(ccbNode)
    local m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_exp_label = ccbNode:labelBMFontForName("m_exp_label")
    self.m_lightning_label = ccbNode:labelBMFontForName("m_lightning_label")
    self.m_task_tab = {}
    local m_clear_sp,m_gotask_btn,m_an_sp,m_taskDes_lab,m_huangtiao_sp,m_taskdi_sp = nil;
    for i=1,7 do
        m_taskdi_sp = ccbNode:spriteForName("m_taskdi_sp" .. i)
    	m_clear_sp = ccbNode:spriteForName("m_clear_sp" .. i)
        m_clear_sp:setVisible(false)
    	m_an_sp = ccbNode:spriteForName("m_an_sp" .. i)
    	m_huangtiao_sp = ccbNode:spriteForName("m_huangtiao_sp" .. i)
    	m_gotask_btn = ccbNode:controlButtonForName("m_gotask_btn" .. i)
    	m_taskDes_lab = ccbNode:labelTTFForName("m_taskDes_lab" .. i)
    	self.m_task_tab[i] = {m_clear_sp = m_clear_sp,m_an_sp = m_an_sp,m_huangtiao_sp = m_huangtiao_sp,m_gotask_btn = m_gotask_btn,m_taskDes_lab = m_taskDes_lab,m_taskdi_sp = m_taskdi_sp}
    end
    self.m_task_tab[1].m_an_sp:setVisible(false)
    self.m_task_tab[1].m_huangtiao_sp:setVisible(false)

    --cclog2(self.m_task_tab,"tab gogo ")

    return ccbNode;
end
--[[--
    设置关卡名称
]]
function game_hero_zhuanshi_task.setName( self )
    local afterlife_chapter = getConfig(game_config_field.afterlife_chapter);
    afterlife_chapter = json.decode(afterlife_chapter:getFormatBuffer())
   --cclog2(afterlife_chapter,"afterlife_chapter======")
    for i=1,7 do
        local des = afterlife_chapter[tostring(i)].des
        self.m_task_tab[i].m_taskDes_lab:setString(des)
    end
    -- body
end
--[[--
    获取战斗数据
]]
function game_hero_zhuanshi_task.sendMyHttpRequest( self,i )
    local function responseMethod( tag,gameData )
        --cclog2(gameData,"gameData -===  ")
        game_data:setBattleType("zhuanshi");
        game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
    end
    local params = {}
    params.chapter = i-200
    params.major = self.m_major
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_card_world_fight"), http_request_method.GET, params,"active_card_world_fight")

end
--[[--
    获取数据
]]
-- function game_hero_zhuanshi.getCardData( self )
--     local function responseMethod( tag,gameData )
--         cclog2(gameData,"gameData -===  ")
--         -- body
--     end
--     local params = {}
--     params.major = self.m_cardId
--     network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_card_world"), http_request_method.GET, params,"cards_card_world")
--     -- body
-- end
--[[--
    设置按钮状态
]]
function game_hero_zhuanshi_task.setTaskBtnStatus( self )
    if self.m_card_world_task == 0 then
        if self.firstflag == true then
            local function endCallFunc()
            end
            local t_params = {};
            t_params.endCallFunc = endCallFunc;
            local afterlife = getConfig(game_config_field.afterlife)
            afterlife = json.decode(afterlife:getFormatBuffer())
            local heroData,heroCfg = game_data:getCardDataById(self.m_major)
            local lifeid = tostring(heroData.c_id)
            local dramaId = afterlife[lifeid].drama_id
            t_params.dramaId = dramaId;
            cclog2(t_params,"drama t_params======")
            game_scene:addPop("drama_dialog_pop",t_params);
        end
        self.m_task_tab[1].m_taskdi_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zhuanshi_tasking.png"))
    elseif self.m_card_world_task == 1 then
        self.m_task_tab[1].m_taskdi_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zhuanshi_tasked.png"))
        self.m_task_tab[2].m_taskdi_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zhuanshi_tasking.png"))
        self.m_task_tab[1].m_clear_sp:setVisible(true)
        self.m_task_tab[2].m_an_sp:setVisible(false)
        self.m_task_tab[2].m_huangtiao_sp:setVisible(false)
    elseif self.m_card_world_task == 2 then
        for i=1,2 do
            self.m_task_tab[i].m_taskdi_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zhuanshi_tasked.png"))
            self.m_task_tab[i].m_clear_sp:setVisible(true)
            self.m_task_tab[i+1].m_an_sp:setVisible(false)
            self.m_task_tab[i+1].m_huangtiao_sp:setVisible(false)
        end
        self.m_task_tab[3].m_taskdi_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zhuanshi_tasking.png"))
    elseif self.m_card_world_task == 3 then
        for i=1,3 do
            self.m_task_tab[i].m_taskdi_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zhuanshi_tasked.png"))
            self.m_task_tab[i].m_clear_sp:setVisible(true)
            self.m_task_tab[i+1].m_an_sp:setVisible(false)
            self.m_task_tab[i+1].m_huangtiao_sp:setVisible(false)
        end
        self.m_task_tab[4].m_taskdi_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zhuanshi_tasking.png"))
    elseif self.m_card_world_task == 4 then
        for i=1,4 do
            self.m_task_tab[i].m_taskdi_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zhuanshi_tasked.png"))
            self.m_task_tab[i].m_clear_sp:setVisible(true)
            self.m_task_tab[i+1].m_an_sp:setVisible(false)
            self.m_task_tab[i+1].m_huangtiao_sp:setVisible(false)
        end
        self.m_task_tab[5].m_taskdi_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zhuanshi_tasking.png"))
    elseif self.m_card_world_task == 5 then
        for i=1,5 do
            self.m_task_tab[i].m_taskdi_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zhuanshi_tasked.png"))
            self.m_task_tab[i].m_clear_sp:setVisible(true)
            self.m_task_tab[i+1].m_an_sp:setVisible(false)
            self.m_task_tab[i+1].m_huangtiao_sp:setVisible(false)
        end
        self.m_task_tab[6].m_taskdi_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zhuanshi_tasking.png"))
    elseif self.m_card_world_task == 6 then
        for i=1,6 do
            self.m_task_tab[i].m_taskdi_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zhuanshi_tasked.png"))
            self.m_task_tab[i].m_clear_sp:setVisible(true)
            self.m_task_tab[i+1].m_an_sp:setVisible(false)
            self.m_task_tab[i+1].m_huangtiao_sp:setVisible(false)
        end
        self.m_task_tab[7].m_taskdi_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zhuanshi_tasking.png"))
    elseif self.m_card_world_task == 7 then 
        for i=1,7 do
            self.m_task_tab[i].m_taskdi_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zhuanshi_tasked.png"))
            self.m_task_tab[i].m_clear_sp:setVisible(true)
            if i<7 then
                self.m_task_tab[i+1].m_an_sp:setVisible(false)
                self.m_task_tab[i+1].m_huangtiao_sp:setVisible(false)
            end
        end
    end
    -- body
end

--[[--
    刷新ui
]]
function game_hero_zhuanshi_task.refreshUi(self)
    self:setTaskBtnStatus()
    self:setName()
    if self.falg == true and  self.secondflag == true then
        local t_params = 
        {
            title = "Nhắc nhở",
            okBtnCallBack = function(target,event)
                require("game_ui.game_pop_up_box").close();
                self:back()
               -- game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"});
            end,   --可缺省
            okBtnText = "Trở về",       --可缺省
            text = "Đã xong tất cả 7 ải của NV kịch bản",     --可缺省
            onlyOneBtn = true,          --可缺省
        }
        require("game_ui.game_pop_up_box").show(t_params);
    end
end
--[[--
    初始化
]]
function game_hero_zhuanshi_task.init(self,t_params)
    t_params = t_params or {};
    self.falg = t_params.falg or false
    self.firstflag = t_params.firstflag or false
    --self.m_major = t_params.major or 1 
    --cclog2(self.m_major,"self.m_major === ")
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local temp = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
        self.m_tGameData = temp
    elseif t_params.gameData ~= nil and tolua.type(t_params.gameData) == "table" then
        self.m_tGameData = t_params.gameData
    end
    self.m_major = self.m_tGameData.id or 1
    local gameData,_ = game_data:getCardDataById(self.m_major)
    game_data:setZhuanshiTask1Data(gameData)
    self.m_tGameData = gameData
    self.m_card_world_task = self.m_tGameData.card_world_task or 0
    if self.m_card_world_task and self.m_card_world_task <= 6 then 
        self.secondflag = false
    elseif self.m_card_world_task > 6 then
        self.secondflag = true
    else
        self.secondflag = false
    end
    --cclog("self.m_tGameData == " .. json.encode(self.m_tGameData))
end

--[[--
    创建ui入口并初始化数据
]]
function game_hero_zhuanshi_task.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_hero_zhuanshi_task;
