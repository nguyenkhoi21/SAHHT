--- 坠落之地
--- 玩家弹版
local game_godfield_guild_high_war_player_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
};

--[[--
    销毁
]]
function game_godfield_guild_high_war_player_pop.destroy(self)
    -- body
    cclog("-----------------game_godfield_guild_high_war_player_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
end
--[[--
    返回
]]
function game_godfield_guild_high_war_player_pop.back(self)
    game_scene:removePopByName("game_godfield_guild_high_war_player_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_godfield_guild_high_war_player_pop.createUi(self)
    self.m_select_index = 1
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_player_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    self.label_title = ccbNode:labelTTFForName("label_title") 
    self.label_title:setString("Thông tin người chơi")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)

    self.node_icon = ccbNode:nodeForName("node_icon")
    self.label_name = ccbNode:labelTTFForName("label_name")
    self.label_qf = ccbNode:labelTTFForName("label_qf") -- 区服
    self.label_combat = ccbNode:labelTTFForName("label_combat") -- 战斗力
    self.label_guild = ccbNode:labelTTFForName("label_guild") -- 所属联盟
    self.node_teams = ccbNode:nodeForName("node_teams") -- 玩家阵容
    self.m_tz_btn = ccbNode:controlButtonForName("m_tz_btn")
    self.m_tz_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-12,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_godfield_guild_high_war_player_pop.refreshUi(self)

    self.node_icon:removeAllChildrenWithCleanup(true)
    local tempIcon = game_util:createPlayerIconByRoleId(self.m_tGameData.icon or 1)
    self.node_icon:addChild(tempIcon)
    self.label_name:setString(self.m_tGameData.name or "")
    self.label_qf:setString(self.m_tGameData.server or "")
    self.label_combat:setString(self.m_tGameData.combat or "")
    self.label_guild:setString(self.m_tGameData.guild_name or "")


    self.node_teams:removeAllChildrenWithCleanup(true);
    local tableView = self:createTeamTable(self.node_teams:getContentSize());
    self.node_teams:addChild(tableView,10,10);

end

function game_godfield_guild_high_war_player_pop.createTeamTable(self,viewSize)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = 3;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_godfield_guild_high_war_team_item.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local node_team = ccbNode:nodeForName("node_team")
            local spr_team = ccbNode:spriteForName("spr_team")
            game_util:setSpriteDisplayBySpriteFrameName(spr_team, "yjzt_msz1"..(index + 1)..".png")   
            
            local cards = {}
            for k,v in pairs(self.m_tGameData.alignments[tostring(index + 1)]) do
                if k < 7 and k > 0 and v ~= "0" and v ~= "-1" then
                    table.insert(cards, v)
                end
            end

            local count = #cards
            local viewSize = node_team:getContentSize()
            local px = viewSize.width/count
            local character_detail_cfg = getConfig(game_config_field.character_detail);
            for k,v in pairs(cards) do
                local itemData = self.m_tGameData.alignment_info[v]
                itemData.super_quality_1 = itemData.evo
                local headIconSpr = game_util:createCardIconByCid(itemData.c_id,itemData);
                headIconSpr:setScale(0.8)
                local function onBtnCilck( event,target )
                    local itemData = self.m_tGameData.alignment_info[v]
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
                node_team:addChild(ccb)
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                button:setOpacity(0)
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition(ccp(0,0))
                icon_node:addChild(button);    
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end

--[[--
    初始化
]]
function game_godfield_guild_high_war_player_pop.init(self,t_params)
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
function game_godfield_guild_high_war_player_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_godfield_guild_high_war_player_pop;