--深渊boss
local game_newRichMan_bigBoss_pop = {
    m_tGameData = nil,
    m_anim_name = nil,
    m_sel_cardId = nil,
    m_selected_LightSp = nil,
    m_boss_skill_node = nil ,
    m_currentSkillTable = {},
    m_bigBossCfg = nil,
    m_big_reward_node = nil,
    m_reward_node = nil,
    big_boss_reward = nil,
    m_reward = nil,
    m_best_reward = nil,
    monopoly_big_boss_reward = nil,
    big_boss_best_reward= nil,
    m_skill_layer =  nil,
    m_btn_left =  nil,
    m_btn_right =  nil,
    m_hero_tableView = nil,
    m_hero_cur_page = nil,
};
--[[--
    销毁ui
]]
function game_newRichMan_bigBoss_pop.destroy(self)
    cclog("-----------------game_newRichMan_bigBoss_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_anim_name = nil;
    self.m_sel_cardId = nil;
    self.m_selected_LightSp = nil;
    self.m_boss_skill_node = nil;
    self.m_currentSkillTable ={};
    self.m_bigBossCfg = nil;
    self.m_big_reward_node = nil;
    self.m_reward_node = nil;
    self.big_boss_reward = nil;
    self.m_reward = nil;
    self.m_best_reward = nil;
    self.monopoly_big_boss_reward = nil;
    self.big_boss_best_reward = nil;
    self.m_skill_layer = nil;
    self.m_btn_left =  nil;
    self.m_btn_right =  nil;
    self.m_hero_tableView = nil;
    self.m_hero_cur_page = nil;
end
--[[--
    返回
]]
function game_newRichMan_bigBoss_pop.back(self)
    local t_params = 
    {
        title = "Nhắc nhở",
        okBtnCallBack = function(target,event)
        local function responseMethod(tag,gameData)
            require("game_ui.game_pop_up_box").close(); 
            game_scene:enterGameUi("game_newRichMan_main",{gameData = gameData});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("monopoly_index"), http_request_method.GET, nil,"monopoly_index")
        end,   --可缺省
        cancelBtnCallBack = function(target,event) cclog("rightBtnCallBack") require("game_ui.game_pop_up_box").close(); end,   --可缺省
        okBtnText = "Từ bỏ",       --可缺省
        cancelBtnText = "Hủy",
        text = "        Sau khi từ bỏ, không thể vào lại khiêu chiến！！",      --可缺省
        onlyOneBtn = false,          --可缺省
    }
    require("game_ui.game_pop_up_box").show(t_params);
end
--[[--
    读取ccbi创建ui
]]
function game_newRichMan_bigBoss_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if self.m_animFlag == true then
            return
        end
        -- cclog2(btnTag,"btnTag ==== ")
        if btnTag == 1 or  btnTag == 4  then--返回
            self:back();
        elseif btnTag == 2 then
            game_scene:addPop("game_active_limit_detail_pop",{enterType = "196"})
        elseif btnTag == 3 then
            if not self.m_sel_cardId then
                game_util:addMoveTips({text = "Hãy chọn thẻ bài sử dụng!"})
                return
            end

            local function responseMethod(tag,gameData)
                if  gameData then
                    local data = gameData:getNodeWithKey("data")
                    self.m_tGameData["skill_data"] = json.decode(data:getFormatBuffer()) or {}
                    game_scene:addPop("game_newRichMan_bigBoss_hero_pop",{cardId = self.m_sel_cardId ,gameData = util.table_copy(self.m_tGameData)})
                end
            end
            local params = {}
            params.card_id = self.m_sel_cardId
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("depth_select_skill_index"), http_request_method.GET, params,"depth_select_skill_index",true,true)

        elseif btnTag == 101 then
            local cx, cy = self.m_hero_tableView:getContainer():getPosition();
            self.m_hero_cur_page = cx/250

            if self.m_hero_cur_page<0 then
                self.m_hero_cur_page = self.m_hero_cur_page + 1
            end
            self.m_hero_tableView:setContentOffset(ccp(250 * self.m_hero_cur_page,cy), false);
        elseif btnTag == 102 then
            local cx, cy = self.m_hero_tableView:getContainer():getPosition();
            self.m_hero_cur_page = cx/250
            if (self.m_hero_cur_page * -1 +1 )*5< #self.m_tGameData.can_use_cards then
                self.m_hero_cur_page = self.m_hero_cur_page - 1
            end

            self.m_hero_tableView:setContentOffset(ccp(250 * self.m_hero_cur_page,cy), false);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_newRichMan_bigBossPop.ccbi");

    ccbNode:controlButtonForName("m_btn_back"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    ccbNode:controlButtonForName("m_detail_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    ccbNode:controlButtonForName("m_challenge_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    ccbNode:controlButtonForName("m_giveup_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_big_reward_node = ccbNode:nodeForName("m_big_reward_node")
    self.m_reward_node = ccbNode:nodeForName("m_reward_node")
    self.m_skill_layer = ccbNode:layerForName("m_skill_layer")
    self.m_anim_name = ccbNode:labelTTFForName("m_anim_name")
    self.m_node_anim = ccbNode:nodeForName("m_node_anim")
    self.m_type_lb_node = ccbNode:nodeForName("m_type_lb_node")
    self.m_boss_skill_node = ccbNode:nodeForName("m_boss_skill_node")
    self.m_hero_list = ccbNode:nodeForName("m_hero_list")
    self.m_btn_left =  ccbNode:controlButtonForName("m_btn_left")
    self.m_btn_right =  ccbNode:controlButtonForName("m_btn_right")

    self.m_btn_left:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_btn_right:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    self.m_btn_left:setOpacity(0)
    self.m_btn_right:setOpacity(0)
-- cclog("233333333")

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
-- cclog("4444444444")

    self:InitSkillIcon()
    -- self:initSkillLayerTouch(self.m_skill_layer,ccbNode)
-- cclog("555555")
    
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    m_root_layer:setTouchEnabled(true);
    self.m_node = ccbNode
    

    return ccbNode;
end

--[[
	可用英雄列表
]]

function game_newRichMan_bigBoss_pop:createTableView(viewSize,data)
	local showData = data or {}

	local color = {ccc3(219,12,3),ccc3(232,156,57),ccc3(199,42,247),ccc3(99,165,249),ccc3(145,253,145),ccc3(145,253,145)}
    local arena_award = getConfig(game_config_field.arena_award);
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 5; --列
    params.totalItem = #showData
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    params.direction = kCCScrollViewDirectionHorizontal;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_newRichMan_bigBoss_heroItem.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
        	local cardId = showData[index+1]
            local cardData,cardCfg = game_data:getCardDataById(cardId)
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local light_add = ccbNode:spriteForName("light_add")
            local m_icon_node = ccbNode:nodeForName("m_icon_node")
            m_icon_node:removeAllChildrenWithCleanup(true)
            light_add:setVisible(false)
            if self.m_sel_cardId == cardId then
                self.m_selected_LightSp = light_add
            	light_add:setVisible(true)
            else
                light_add:setVisible(false)
            end
            local quality = cardData.quality or cardCfg:getNodeWithKey("quality"):toInt()
            local icon = game_util:createIconByName(cardCfg:getNodeWithKey("img"):toStr(),tonumber(quality)+1)
            if icon then
            	icon:setScale(0.8)
				icon:setAnchorPoint(ccp(0.5,0.5))
				m_icon_node:addChild(icon)
			end
            for k,v in pairs(self.m_UsedCard) do
                if cardId.."" == k.."" then
                    icon:setColor(ccc3(100,100,100))
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)        
        if eventType == "ended" and item then

            local id = showData[index+1]
            if self.m_UsedCard[id] then
                game_util:addMoveTips({text = "该卡牌已经使用过了，请重新选择卡牌"})
                if self.m_selected_LightSp then
                    self.m_selected_LightSp:setVisible(false)
                    self.m_selected_LightSp = nil
                    self.m_sel_cardId = nil
                end
                return
            end
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local light_add = ccbNode:spriteForName("light_add")

            if light_add then
                if self.m_sel_cardId ~= id then
                    if self.m_selected_LightSp then
                        self.m_selected_LightSp:setVisible(false)
                        self.m_selected_LightSp = nil
                    end
                    self.m_sel_cardId = id
                    light_add:setVisible(true)
                    self.m_selected_LightSp = light_add
                end
            end
        end
    end
    return TableViewHelper:create(params);
end


function game_newRichMan_bigBoss_pop:InitSkillIcon( )
    -- body
    local cardData = self.m_tGameData
    local skill_detail_cfg = getConfig("skill_detail");
    local skillJsonData = nil;
    local skillItem = nil;

    local m_boss_skill = {}
    for k,v in pairs(cardData.boss_skill) do
        if v ~= nil and v ~= "0" then
            table.insert(m_boss_skill,v)
        end
    end
    local skilldata = {}

    function onClick( event, target  )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        game_scene:addPop("skills_activation_pop",{skillData = skilldata[btnTag..""],selHeroId=-1,posIndex = tonumber(btnTag)%10})
    end
    -- cclog("66666666")
    for i=1,#m_boss_skill do
        skillItem = m_boss_skill[i];
        if skillItem ~= "0" then
            local skill_icon_spr_bg = self.m_skill_layer:getChildByTag(i)
            local skillid = self.m_bigBossCfg[tostring(skillItem)][1]
            -- cclog2(skillid,"skillid-=--------")
            -- cclog2(skillItem,"skillItem-=--------")
            -- cclog2(skill_detail_cfg,"skill_detail_cfg-=--------")
            skillJsonData = skill_detail_cfg:getNodeWithKey(skillid);
            -- cclog2(skillJsonData,"skillJsonData-=--------")
    -- cclog("77777777")


            local icon_size = skill_icon_spr_bg:getContentSize();
            local skill_icon_spr = game_util:createSkillIconByCfg(skillJsonData);
            if skill_icon_spr then
                skill_icon_spr:setPosition(ccp(icon_size.width*0.5,icon_size.height*0.5));
                skill_icon_spr_bg:addChild(skill_icon_spr);
            end
            skill_icon_spr_bg:setVisible(true)

            local skill_icon_button = game_util:createCCControlButton("public_weapon.png","",onClick)
            skill_icon_spr_bg:addChild(skill_icon_button)
            skill_icon_button:setPosition(ccp(27,27))
            skill_icon_button:setTag(i+200)
            skill_icon_button:setOpacity(0)
            skill_icon_button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4)
    -- cclog("88888888")

            local tempLabel = nil;
            tempLabel = game_util:createLabelTTF({text = skillJsonData:getNodeWithKey("skill_name"):toStr()})
            if namePosType == nil or namePosType == 1 then
                tempLabel:setPosition(ccp(icon_size.width*0.5,-icon_size.height*0.1));
            else
                tempLabel:setPosition(ccp(icon_size.width*0.5,icon_size.height*1.1));
            end
            skill_icon_spr_bg:addChild(tempLabel,10,11);
            if skillJsonData then
                self.m_currentSkillTable[i] = skillItem;
            end

            skilldata[(i+200)..""] = {avail = 2,lv    = 1,s     = skillid,exp   = 0}
        end
    end
end
--[[
	刷新boss信息
]]
function game_newRichMan_bigBoss_pop:refreshBossInfo()
    -- cclog2(self.m_bigBossCfg,"self.m_bigBossCfg-=-----------")
	self.m_anim_name:setString(self.m_bigBossCfg.name)
	self.m_node_anim:removeAllChildrenWithCleanup(true)
    local ainmFile = self.m_bigBossCfg.animation

    -- local animNode = game_util:createAnimSequence(ainmFile,0);
    local animNode = game_util:createSortNode(ainmFile .. ".swf.sam",0,ainmFile .. ".plist");
    if animNode then
        animNode:setRhythm(1);
        game_anim:playSection(animNode , anim_label_name_cfg.daiji);
        animNode:setAnchorPoint(ccp(0.5,0.5));
        self.m_node_anim:addChild(animNode);

	    local function animEnd(animNode,theId,labelName)
	        animNode:playSection(anim_label_name_cfg.daiji);
	    end
	    animNode:registerScriptTapHandler(animEnd);
    end


    local boss_type = self.m_tGameData.boss_type

	self.m_type_lb_node:removeAllChildrenWithCleanup(true)
    local str = self:getBossTypeStr(boss_type)
    if str ~= "" then
	    local tempStr = game_util:createRichLabelTTF({text = str,dimensions = CCSizeMake(0,15),textAlignment = kCCTextAlignmentLeft, verticalTextAlignment = kCCVerticalTextAlignmentCenter,fontSize = 9})
	    tempStr:setAnchorPoint(ccp(0,0.5))
	    self.m_type_lb_node:addChild(tempStr);
	end

end

function game_newRichMan_bigBoss_pop:getBossTypeStr(boss_type)
	--绿 [color=ff00C000]&[/color]  白 [color=ffFFFFFF]&[/color]  淡蓝 [color=ff6DFFFF]&[/color]  黄 [color=ffFFFF00]&[/color]  红 [color=ffED0000]&[/color]
	local str = ""
	if boss_type["race"] then -- 绿色
		str = "[color=ff00C000]".. RACE_SORT_TAB["type_" .. boss_type["race"]].name .."[/color]"
	end
	if boss_type["sex"] then --淡蓝色
		str = str .. (str=="" and "" or "[color=ffFFFFFF]&[/color]") .. "[color=ff6DFFFF]" .. (boss_type["sex"] == 0 and "Nhân vật nữ" or "Nhân vật nam") .. "[/color]"
	end
	if boss_type["bre"] then --黄色
		str = str .. (str=="" and "" or "[color=ffFFFFFF]&[/color]") .. "[color=ffFFFF00]Chuyển sinh cao hơn" .. boss_type["bre"] .. "[/color]"
	end
	if boss_type["super_step"] then --红色
		str = str .. (str=="" and "" or "[color=ffFFFFFF]&[/color]") .. "[color=ffED0000]Siêu tiến hóa cao hơn" .. HERO_QUALITY_COLOR_TABLE_2[boss_type["super_step"]].name .. "[/color]"
	end
	return str
end

function game_newRichMan_bigBoss_pop.createRewardTable(self,viewSize,count,rewardList)


    -- local function onBtnCilck( event,target )
    --     local tagNode = tolua.cast(target, "CCNode");
    --     local btnTag = tagNode:getTag();
    --     local itemCfg = rewardList[btnTag+1]
    --     game_util:lookItemDetal(itemCfg)
    -- end

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;
    params.column = 2; --列
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-4;
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
            local itemGift = rewardList[index+1]
            local icon,name,count = game_util:getRewardByItemTable(itemGift)
            if icon then
                icon:setScale(0.7)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,0))
                node:addChild(icon,10)
            end

            if itemGift.big then
                local anim1 = game_util:createEffectAnim("zikuang",1,true)
                -- anim1:setScale(1.4)
                node:addChild(anim1,10,20)
            end

            cell:addChild(node)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)

        if eventType == "ended" and item then
            local itemCfg = rewardList[index+1]
            game_util:lookItemDetal(itemCfg)
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_newRichMan_bigBoss_pop.refreshUi(self)
	self:refreshBossInfo()
	self.m_hero_list:removeAllChildrenWithCleanup(true)

    self.m_hero_cur_page = 0
	if #self.m_tGameData.can_use_cards > 0 then
        self.m_hero_tableView = self:createTableView(self.m_hero_list:getContentSize(),self.m_tGameData.can_use_cards)
		if self.m_hero_tableView  then
			self.m_hero_list:addChild(self.m_hero_tableView ,10,10)
		end
	end
    self.m_big_reward_node:removeAllChildrenWithCleanup(true)
    self.m_reward_node:removeAllChildrenWithCleanup(true)

    local bigrewarddata = self.big_boss_best_reward.reward
    for k,v in pairs(bigrewarddata) do
        v["big"] = 1
    end
-- cclog("999999999")
    local tempTable1 = self:createRewardTable(self.m_big_reward_node:getContentSize(),#bigrewarddata,bigrewarddata)
    self.m_big_reward_node:addChild(tempTable1)
-- cclog("1212121212")
   
    local tempTable2 = self:createRewardTable(self.m_reward_node:getContentSize(),#self.big_boss_reward.reward,self.big_boss_reward.reward)
    self.m_reward_node:addChild(tempTable2)

end


function game_newRichMan_bigBoss_pop:getUsedCardTab(cardTab)
    local tempCardTab = cardTab or {}
    local usedCard = {}
    for k,v in pairs(tempCardTab) do
        usedCard[v] = 1
    end
    return usedCard
end
--[[--
    初始化
]]
function game_newRichMan_bigBoss_pop.init(self,t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_vip.plist")
    t_params = t_params or {};
    if t_params.gameData ~= nil then
        if tolua.type(t_params.gameData) == "util_json" then
            self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
        else
            self.m_tGameData = t_params.gameData
        end
    end
    local monopoly_big_boss_reward = getConfig(game_config_field.monopoly_big_boss_reward);
    self.monopoly_big_boss_reward = json.decode(monopoly_big_boss_reward:getNodeWithKey(self.m_tGameData.boss_key):getFormatBuffer())

    local  reward = self.m_tGameData.reward_id
    local  best_reward = self.m_tGameData.best_reward_id

    local big_boss_reward = getConfig(game_config_field.big_boss_reward);
    self.big_boss_reward = json.decode(big_boss_reward:getNodeWithKey(tostring(reward)):getFormatBuffer())
    self.big_boss_best_reward = json.decode(big_boss_reward:getNodeWithKey(tostring(best_reward[1])):getFormatBuffer())

    self.m_UsedCard = self:getUsedCardTab(self.m_tGameData.used_cards)
    local monopoly_big_boss = getConfig(game_config_field.monopoly_big_boss);
    -- cclog2(self.m_tGameData,"self.m_tGameData-=--------")
    -- cclog2(monopoly_big_boss,"monopoly_big_boss-=--------")
    self.m_bigBossCfg = json.decode(monopoly_big_boss:getNodeWithKey(self.m_tGameData.boss_key):getFormatBuffer())
    self.m_cards_with_equip = self.m_tGameData.cards_with_equip
end
--[[--
    创建ui入口并初始化数据
]]
function game_newRichMan_bigBoss_pop.create(self,t_params)
    self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi();
    return  m_popUi;
end
return game_newRichMan_bigBoss_pop;