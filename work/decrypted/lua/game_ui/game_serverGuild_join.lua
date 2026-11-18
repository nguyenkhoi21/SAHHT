--- 工会战_zwj

local game_serverGuild_join = {
    m_tGameData = nil,
    m_close_btn = nil,
    m_node_tableView = nil,
    node_num = nil,
    m_node_timeDown = nil,
    m_label_guildName1 = nil,
    m_label_guildNum = nil,
    m_label_guildCombat = nil,
    m_label_des1 = nil,
    m_label_des2 = nil,
};
--[[--
    销毁
]]
function game_serverGuild_join.destroy(self)
    -- body
    cclog("-----------------game_serverGuild_join destroy-----------------");
    self.m_tGameData = nil;
    self.m_close_btn = nil;
    self.m_node_tableView = nil;
    self.node_num = nil;
    self.m_node_timeDown = nil;
    self.m_label_guildName1 = nil;
    self.m_label_guildNum = nil;
    self.m_label_guildCombat = nil;
    self.m_label_des1 = nil;
    self.m_label_des2 = nil;
end



--[[--
    返回
]]
function game_serverGuild_join.back(self,type)
    self:destroy();
    require("like_oo.oo_controlBase"):openView("guild");
end
--[[--
    读取ccbi创建ui
]]
function game_serverGuild_join.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag ===== ")
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 2 then
            game_scene:addPop("game_serverGuild_employo_pop")
        elseif btnTag == 3 then
            game_scene:enterGameUi("game_server_guildbattle_toBattle")
        elseif btnTag == 4 then
            local function responseMethod( tag,gameData )
                game_scene:addPop("game_serverGuild_employoJoin_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_employ_pub_ed"), http_request_method.GET, {tp = 1},"new_guild_fight_employ_pub_ed")
        elseif btnTag == 5 then --报名接口
            local t_params = 
              {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                    local function responseMethod( tag,gameData )
                        game_util:addMoveTips({text = "Báo danh thành công"})

                        -- cclog2(gameData,"gameData= ==== ")
                        game_scene:enterGameUi("game_serverGuild_join",{gameData = gameData})
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_guild_fight_guild_sign_up"), http_request_method.GET, params,"new_guild_fight_guild_sign_up")
                    
                end,   --可缺省
                closeCallBack = function(target,event)
                    game_util:closeAlertView();
                end,
                cancelBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                end,
                cancelBtnText = "Hủy",
                onlyOneBtn = false,
                okBtnText = "OK",       --可缺省
                text = "是否花费100战旗进行报名？",      --可缺省
              }
              game_util:openAlertView(t_params);
            -- game_scene:addPop("game_serverGuild_enterMember_pop")
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_serverGuild_main.ccbi");
    -- cclog("zjr -----001-----")
    self.m_close_btn = ccbNode:controlButtonForName("m_back_btn");
    self.m_node_tableView = ccbNode:controlButtonForName("m_node_tableView")
    self.node_num = ccbNode:nodeForName("node_num")
    self.m_node_timeDown = ccbNode:nodeForName("m_node_timeDown")
    if self.m_leader then 
    end
    self.m_label_guildName1 = ccbNode:labelTTFForName("label_guildName1")
    self.m_label_guildNum = ccbNode:labelTTFForName("label_guildNum")
    self.m_label_guildCombat = ccbNode:labelTTFForName("label_guildCombat")
    self.m_label_des1 = ccbNode:labelTTFForName("label_des1")
    self.m_label_des2 = ccbNode:labelTTFForName("label_des2")
 

    return ccbNode;
end
--[[--

]]
function game_serverGuild_join.createTableView(self,viewSize)
    -- cclog("createTableView----")

    -- local showData = team_pk_rewardcfg or {}
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = game_util:getTableLen(self.m_tGameData.ass_info)
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            -- ccbNode:registerFunctionWithFuncName("onCellClick",onCellClick);
            ccbNode:openCCBFile("ccb/ui_serverGuild3_joinItem3.ccbi");
            -- ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = self.m_tGameData.ass_info[index + 1]
            local m_label_rank = ccbNode:labelTTFForName("m_label_rank")
            local m_label_name = ccbNode:labelTTFForName("m_label_name")
            local m_label_bossName = ccbNode:labelTTFForName("m_label_bossName")
            local m_label_num = ccbNode:labelTTFForName("m_label_num")
            local m_label_combat = ccbNode:labelTTFForName("m_label_combat")
            m_label_rank:setString(tostring(index + 1))
            m_label_name:setString(tostring(itemData.name))
            m_label_bossName:setString(tostring(itemData.owner_name))
            m_label_num:setString(tostring(itemData.player_num))
            m_label_combat:setString(tostring(itemData.combat))
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        end
    end
    return TableViewHelper:create(params);
end

--[[
    设置图片数字
]]
function game_serverGuild_join.createNumIcon(self,num,node)
    node:removeAllChildrenWithCleanup(true);
    if num >= 10 and num < 100 then
        local high = math.floor(num / 10)
        local low = math.floor(num % 10)

        local num_1 = CCSprite:createWithSpriteFrameName("vip_num_" .. high .. ".png")
        local num_2 = CCSprite:createWithSpriteFrameName("vip_num_" .. low .. ".png")
        num_1:setScale(0.5)
        num_2:setScale(0.5)
        num_1:setAnchorPoint(ccp(0.5,0.5))
        num_2:setAnchorPoint(ccp(0.5,0.5))

        num_1:setPosition(ccp(-10,0))
        num_2:setPosition(ccp(0,0))

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
            num_sprite:setAnchorPoint(ccp(0.5,0.5))
            num_sprite:setPosition(ccp(-15+(i-1)*15,0))
            node:addChild(num_sprite,10)
            num_sprite:setScale(0.5)
        end
    else
        local num_sprite = CCSprite:createWithSpriteFrameName("vip_num_" .. num .. ".png")
        num_sprite:setAnchorPoint(ccp(0.5,0.5))
        num_sprite:setPosition(ccp(0,0))
        node:addChild(num_sprite,10)
        num_sprite:setScale(0.5)
    end
end

function game_serverGuild_join.createTimeDown( self,parentNode,time_count_down,shwoType,isclose )
    local function timeEndFunc()
        require("like_oo.oo_controlBase"):openView("guild");
    end
    if parentNode:getChildByTag(101) then
        parentNode:removeChildByTag(101)
    end
    -- parentNode:removeAllChildrenWithCleanup(true)
    local shwoType = shwoType or 3
    local countdownLabel = game_util:createCountdownLabel(time_count_down,timeEndFunc,8, shwoType);
    countdownLabel:setColor(ccc3(255, 249, 255))
    countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    local tempcontent = parentNode:getContentSize()
    countdownLabel:setPosition(ccp(tempcontent.width*0.5,tempcontent.height*0.1))
    parentNode:addChild(countdownLabel,10,101) 
    -- body
end

--[[--
    刷新ui
]]
function game_serverGuild_join.refreshUi(self)
    local cfg_new_guild_version = getConfig(game_config_field.new_guild_version)
    local version = 1
    local des1 = cfg_new_guild_version:getNodeWithKey(tostring(version)):getNodeWithKey("des1"):toStr()
    local des2 = cfg_new_guild_version:getNodeWithKey(tostring(version)):getNodeWithKey("des2"):toStr()
    self.m_label_guildName1:setString(tostring(self.m_tGameData.self_ass_name))
    self.m_label_guildNum:setString(tostring(self.m_tGameData.self_player_num))
    self.m_label_guildCombat:setString(tostring(self.m_tGameData.self_combat))
    self.m_label_des1:setString(tostring(des1))
    self.m_label_des2:setString(tostring(des2))
    -- cclog("refreshUi -----001-----")
    if tonumber(self.m_tGameData.self_rank) > 0 then
        self:createNumIcon(tonumber(self.m_tGameData.self_rank),self.node_num)
    else

    end
    
    self:createTimeDown(self.m_node_timeDown,self.m_tGameData.remain_time, 1)
    self.m_node_tableView:removeAllChildrenWithCleanup(true)
    self.m_node_tableView:addChild(self:createTableView(self.m_node_tableView:getContentSize()))
end

--[[--
    初始化
]]
function game_serverGuild_join.init(self,t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_vip.plist")

   CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_serverGuild.plist");
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    

end

--[[--
    创建ui入口并初始化数据
]]
function game_serverGuild_join.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_serverGuild_join;