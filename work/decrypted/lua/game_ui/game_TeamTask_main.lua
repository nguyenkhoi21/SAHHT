local game_TeamTask_main = {
    boss_id = nil,
    m_fromtype = nil,
    m_fromteamid = nil,
    msg_boss_lv =nil,
    msg_boss_id =nil,
    msg_boss_type =nil,
    msg_boss_index = nil,
    msg_msg_id = nil,
    m_sp_team_boss_bg = nil,
    m_node_scrollreward = nil,
    m_btn_choose = nil,
    m_layer_reward = nil,
    m_node_target = nil,
    m_selectIndex_go = nil,

}

function game_TeamTask_main:destroy(  )
	-- bodyself.boss_id
    self.boss_id = nil;
    self.m_fromtype = nil;
    self.m_fromteamid = nil;
    self.msg_boss_lv =nil;
    self.msg_boss_id =nil;
    self.msg_boss_type =nil;
    self.msg_boss_index = nil;
    self.msg_msg_id = nil;
    self.m_sp_team_boss_bg = nil;
    self.m_node_scrollreward = nil;
    self.m_btn_choose = nil;
    self.m_layer_reward = nil;
    self.m_node_target = nil;
    self.m_selectIndex_go = nil;
end


function game_TeamTask_main:back()
	game_scene:enterGameUi("game_main_scene",{gameData = nil,  openPop = nil});
end

function game_TeamTask_main:createUi()
	local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then -- 返回
    		self:back()
    	elseif btnTag ==2 then -- 选择副本
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_teamTask_selTaskPop",{gameData = gameData,boss_id = self.m_selectIndex_go,boss_langid = self.boss_id,selIcon = self.m_selBossData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_team_index"), http_request_method.GET, {boss_id = self.m_selectIndex_go,boss_level = 1},"team_fight_team_index")

    	elseif btnTag == 3 then -- 队伍
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_teamTask_MyTeam",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_team_own"), http_request_method.GET, nil,"team_fight_team_own")
            
    	   -- game_teamTask_MyTeam
    	elseif btnTag == 4 then -- 领取奖励
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                game_util:rewardTipsByDataTable(data.reward)
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_get_reward"), http_request_method.GET, nil,"team_fight_get_reward")
    	elseif btnTag == 5 then -- 规则说明
            game_scene:addPop("game_active_limit_detail_pop",{enterType = "199"})
    	elseif btnTag == 12 then -- you
            self.m_selectRewardId = self.m_selectRewardId + 1
            self.m_selectRewardId = self.m_selectRewardId > 3 and 1 or self.m_selectRewardId
            self:refreshReward(self.m_selectData)
        elseif btnTag == 11 then -- zuo
            self.m_selectRewardId = self.m_selectRewardId - 1
            self.m_selectRewardId = self.m_selectRewardId < 1 and 3 or self.m_selectRewardId
            self:refreshReward(self.m_selectData)
        end
    end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    cclog("1231231232")
    ccbNode:openCCBFile("ccb/ui_teamTask_main.ccbi");
    cclog("456456456")
    self.m_des_lb = ccbNode:labelTTFForName("m_des_lb")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_reward_node = ccbNode:nodeForName("m_reward_node")
    self.m_task_node = ccbNode:nodeForName("m_task_node")
    self.m_sp_team_boss_bg = ccbNode:spriteForName("m_sp_team_boss_bg")
    self.m_bigreward_node = ccbNode:nodeForName("m_bigreward_node")
    self.m_reward_scroll = ccbNode:scrollViewForName("m_reward_scroll")
    self.m_btn_choose = ccbNode:controlButtonForName("m_btn_choose")
    self.m_node_target =  ccbNode:nodeForName("m_node_target")
    self.m_btn_choose:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
    self.m_reward_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    local m_reward_btn_right = ccbNode:controlButtonForName("m_reward_btn_right") 
    local m_reward_btn_left = ccbNode:controlButtonForName("m_reward_btn_left") 
    if m_reward_btn_left and m_reward_btn_right then
        m_reward_btn_right:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
        m_reward_btn_right:setOpacity(0)
        m_reward_btn_left:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
        m_reward_btn_left:setOpacity(0)
    end
    self.m_reward_title = ccbNode:spriteForName("m_reward_title")
        -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            local pos = self.m_node_target:convertToNodeSpace(ccp(x , y ))
            if pos.x>0 and pos.y < 0 then
                return true;--intercept event
            else
                return false
            end
        end
    end
    self.m_layer_reward = ccbNode:layerColorForName("m_layer_reward")
    self.m_layer_reward:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-4,true);
    self.m_layer_reward:setTouchEnabled(true);
    return ccbNode
end


function game_TeamTask_main:createTaskTable(viewSize, tableData)
    tableData = tableData or {}
    local count = game_util:getTableLen(tableData)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 3 > count and count or 3 ; --列
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+20;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionHorizontal;--横向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_teamTask_taskItem.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then
            local itemData = tableData[index+1] or tableData[tostring(index+1)]
            local bgIndex = (index)%3 + 1
            local bgFile = "ui_new_TeamBoss_main_boss" .. bgIndex
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_sel_light = ccbNode:spriteForName("m_sel_light")
            local m_spriteBG = ccbNode:spriteForName("m_spriteBG")
            local m_img_node = ccbNode:nodeForName("m_img_node")
            if self.m_selectIndex == index+1 then
                self.m_selLight = m_sel_light
                self.m_selBG = m_spriteBG
                m_sel_light:setColor(ccc3(255,255,255))
                self:refreshLeftInfo(self.m_selectIndex)
                bgFile = bgFile .. "1"
            else
                m_sel_light:setColor(ccc3(100,100,100))
                bgFile = bgFile .. "2"
            end
            self.m_selectIndex_go = tableData[self.m_selectIndex].boss__index
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(bgFile .. ".png"))
            if tempSpriteFrame then
                m_spriteBG:setDisplayFrame(tempSpriteFrame)
            end
            m_spriteBG:removeAllChildrenWithCleanup(true)
            local halficon = self:createHalfImage(itemData.boss_id)
            m_spriteBG:addChild(halficon)
            halficon:setScale(0.8)
            halficon:setAnchorPoint(ccp(0.5,0.5))
            halficon:setPosition(ccp(m_spriteBG:getContentSize().width/2,m_spriteBG:getContentSize().height*3/5))

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            if self.m_selLight then
                self.m_selLight:setColor(ccc3(100,100,100))
            end
            if self.m_selBG then
                local bgIndex = (self.m_selectIndex - 1)%3 + 1
                local bgFile = "ui_new_TeamBoss_main_boss" .. bgIndex .. "2.png"
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(bgFile))
                if tempSpriteFrame then
                    self.m_selBG:setDisplayFrame(tempSpriteFrame)
                end
            end
            local ccb = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local selLight = ccb:spriteForName("m_sel_light")
            self.m_selLight = selLight
            selLight:setColor(ccc3(255,255,255))
            self.m_selectIndex = index+1
            self.m_selectIndex_go = tableData[self.m_selectIndex].boss__index

            local m_spriteBG = ccb:spriteForName("m_spriteBG")
            if m_spriteBG then
                self.m_selBG = m_spriteBG
                local bgIndex = (self.m_selectIndex - 1)%3 + 1
                local bgFile = "ui_new_TeamBoss_main_boss" .. bgIndex .. "1.png"
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(bgFile))
                if tempSpriteFrame then
                    m_spriteBG:setDisplayFrame(tempSpriteFrame)
                end
            end

            self:refreshLeftInfo(self.m_selectIndex)
        end
    end
    return TableViewHelper:create(params);
end

function game_TeamTask_main:refreshLeftInfo(index)
    --boss_id
    local data = self.m_gameData.boss_info[index] or self.m_gameData.boss_info[tostring(index)]
    local function onClick( event, target  )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 99 then
            game_util:lookItemDetal(data.rare_award[1])
        else
            game_util:lookItemDetal(data.reward[btnTag])
        end
    end
    if data then
        self.m_selectData = data
        self:refreshReward(data)
        -- self.m_bigreward_node:removeAllChildrenWithCleanup(true)

        -- local bigreward = data.rare_award
        -- local bigicon,bigname,bigcount = game_util:getRewardByItemTable(bigreward[1])
        -- if bigicon then
        --     self.m_bigreward_node:addChild(bigicon)
        --     bigicon:setAnchorPoint(ccp(0,0))
        --     bigicon:setScale(0.7)
        --     bigicon:setPosition(ccp(2,-2))
        --     local button = game_util:createCCControlButton("public_weapon.png","",onClick)
        --     self.m_bigreward_node:addChild(button)
        --     button:setAnchorPoint(ccp(0,0))
        --     button:setScale(0.7)
        --     button:setPosition(ccp(2,-2))
        --     button:setTag(99)
        --     button:setOpacity(0)
        --     if bigcount then
        --         local numLab = CCLabelTTF:create("x" .. bigcount,TYPE_FACE_TABLE.Arial_BoldMT,14)
        --         numLab:setAnchorPoint(ccp(0.5,0.5))
        --         bigicon:addChild(numLab,10,10)
        --         numLab:setScale(0.9)
        --         numLab:setPosition(ccp(bigicon:getContentSize().width/2,-7))
        --     end
        -- end

        self.boss_id = data.boss_id
        local bossCfg = self.m_bossInfoCfg:getNodeWithKey(tostring(self.boss_id))
        self.m_des_lb:setString(data.instruction)
        -- self.m_reward_node:removeAllChildrenWithCleanup(true)
        -- if self.m_node_scrollreward == nil then
        --     self.m_node_scrollreward = CCNode:create()
        --     self.m_reward_scroll:addChild(self.m_node_scrollreward)
        -- end
        -- self.m_node_scrollreward:removeAllChildrenWithCleanup(true)
        
        -- local reward = data.reward
        -- local viewSize = self.m_reward_scroll:getViewSize()
        -- local count = #reward
        -- local curwidth = 0
        -- local itemSizeWidth = viewSize.width/count
        -- for i=1,count do
        --     local icon,name,count = game_util:getRewardByItemTable(reward[i])
        --     if icon then
        --         self.m_node_scrollreward:addChild(icon)
        --         icon:setAnchorPoint(ccp(0.5,0.5))
        --         icon:setScale(0.6)
        --         icon:setPosition(ccp((i-1)*icon:getContentSize().width*0.7 + icon:getContentSize().width*0.5,viewSize.height*0.6))
            
        --         if count then
        --             local numLab = CCLabelTTF:create("x" .. count,TYPE_FACE_TABLE.Arial_BoldMT,14)
                    
        --             icon:addChild(numLab,10,10)
        --             numLab:setPosition(ccp(25,-7))
        --         end
        --         curwidth = icon:getContentSize().width+(i-1)*icon:getContentSize().width*0.7
        --     end

        --     local button = game_util:createCCControlButton("public_weapon.png","",onClick)
        --     self.m_node_scrollreward:addChild(button)
        --     button:setAnchorPoint(ccp(0.5,0.5))
        --     button:setScale(0.6)
        --     button:setPosition(ccp((i-1)*icon:getContentSize().width*0.7 + icon:getContentSize().width*0.5,viewSize.height*0.6))
        --     button:setTag(i)
        --     button:setOpacity(0)
        -- end

        -- self.m_node_scrollreward:setContentSize(CCSizeMake(curwidth,viewSize.height))
        -- self.m_reward_scroll:setContentSize(CCSizeMake(curwidth,viewSize.height))
        -- self.m_reward_scroll:setContentOffset(ccp(0,0),true)

        local anim = game_util:createIdelAnim(bossCfg:getNodeWithKey("animation"):toStr(),0,cardData,heroCfg,nil,nil,nil,true)
        self.m_selBossData = bossCfg
        if anim then
            self.m_anim_node:removeAllChildrenWithCleanup(true)
            self.m_sp_team_boss_bg:removeAllChildrenWithCleanup(true)
            local bossheight = anim:getContentSize().height
            local anim2 = game_util:createEffectAnim("zhujue_daiji",1,true) 
            local tarheight = self.m_sp_team_boss_bg:getContentSize().height*0.6
            local r = (tarheight*1.0)/(bossheight*1.0)

            anim:setScale(r+0.1)
            game_anim:playSection(anim2,"impact")
            self.m_anim_node:addChild(anim)
            self.m_sp_team_boss_bg:addChild(anim2)
            anim2:setAnchorPoint(ccp(0.5,0))
            anim2:setPosition(ccp(self.m_sp_team_boss_bg:getContentSize().width/2 -5,-34))
            anim:setAnchorPoint(ccp(0.5,0))
            anim:setPosition(ccp(0,0))
        end
    end
end


function game_TeamTask_main:refreshReward( data )

    local index = self.m_selectRewardId
    local keyStr = "ward" .. (index == 1 and "" or index)
    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring( "ui_new_TeamBoss_jiangli" .. index .. ".png"))
    if tempSpriteFrame then
        self.m_reward_title:setDisplayFrame(tempSpriteFrame)
    end

    local function onClick( event, target  )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 99 then
            game_util:lookItemDetal(data["rate_a" .. keyStr][1])
        else
            game_util:lookItemDetal(data["re" .. keyStr][btnTag])
        end
    end


    self.m_bigreward_node:removeAllChildrenWithCleanup(true)

    local bigreward = data["rare_a" .. keyStr]
    local bigicon,bigname,bigcount = game_util:getRewardByItemTable(bigreward[1])
    if bigicon then
        self.m_bigreward_node:addChild(bigicon)
        bigicon:setAnchorPoint(ccp(0,0))
        bigicon:setScale(0.7)
        bigicon:setPosition(ccp(2,-2))
        local button = game_util:createCCControlButton("public_weapon.png","",onClick)
        self.m_bigreward_node:addChild(button)
        button:setAnchorPoint(ccp(0,0))
        button:setScale(0.7)
        button:setPosition(ccp(2,-2))
        button:setTag(99)
        button:setOpacity(0)
        if bigcount then
            local numLab = CCLabelTTF:create("x" .. bigcount,TYPE_FACE_TABLE.Arial_BoldMT,14)
            numLab:setAnchorPoint(ccp(0.5,0.5))
            bigicon:addChild(numLab,10,10)
            numLab:setScale(0.9)
            numLab:setPosition(ccp(bigicon:getContentSize().width/2,-7))
        end
    end

    self.m_reward_node:removeAllChildrenWithCleanup(true)

    if self.m_node_scrollreward == nil then
        self.m_node_scrollreward = CCNode:create()
        self.m_reward_scroll:addChild(self.m_node_scrollreward)
    end
    self.m_node_scrollreward:removeAllChildrenWithCleanup(true)
    
    local reward = data["re" .. keyStr]
    local viewSize = self.m_reward_scroll:getViewSize()
    local count = #reward
    local curwidth = 0
    local itemSizeWidth = viewSize.width/count
    local width = 0
    for i=1,count do
        local icon,name,count = game_util:getRewardByItemTable(reward[i])
        if icon then
            self.m_node_scrollreward:addChild(icon)
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setScale(0.6)
            icon:setPosition(ccp((i-1)*icon:getContentSize().width*0.7 + icon:getContentSize().width*0.5,viewSize.height*0.6))
        
            if count then
                local numLab = CCLabelTTF:create("x" .. count,TYPE_FACE_TABLE.Arial_BoldMT,14)
                
                icon:addChild(numLab,10,10)
                numLab:setPosition(ccp(25,-7))
            end
            curwidth = icon:getContentSize().width+(i-1)*icon:getContentSize().width*0.7
        end

        local button = game_util:createCCControlButton("public_weapon.png","",onClick)
        self.m_node_scrollreward:addChild(button)
        button:setAnchorPoint(ccp(0.5,0.5))
        button:setScale(0.6)
        button:setPosition(ccp((i-1)*icon:getContentSize().width*0.7 + icon:getContentSize().width*0.5,viewSize.height*0.6))
        button:setTag(i)
        button:setOpacity(0)
        width = width + icon:getContentSize().width*0.7 + 3
    end
    self.m_reward_scroll:setContentSize(CCSizeMake(width, viewSize.height))
    self.m_reward_scroll:setContentOffset(ccp(0, 0), false)

end

function game_TeamTask_main:refreshUi()
	-- body
    local tableView = self:createTaskTable(self.m_task_node:getContentSize(),self.m_gameData.boss_info)
    if tableView then
        self.m_task_node:removeAllChildrenWithCleanup(true)
        self.m_task_node:addChild(tableView)
    end

    if self.m_fromtype then
        local function responseMethod(tag,gameData)
            local bossCfg = self.m_bossInfoCfg:getNodeWithKey(tostring(self.msg_boss_id))
            game_scene:addPop("game_teamTask_selTaskPop",{gameData = gameData,boss_id = self.msg_boss_index,boss_langid =  self.msg_boss_id,selIcon = bossCfg,team_id = self.m_fromteamid,fromtype = "msg",msg_id = self.msg_msg_id})
        end

        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("team_fight_team_index"), http_request_method.GET, {boss_id = self.msg_boss_index,boss_level = self.msg_boss_lv,team_id = self.m_fromteamid,message_id = self.msg_msg_id},"team_fight_team_index")
    end
end

--半身像
function game_TeamTask_main.createHalfImage( self, heroid, isflipX  )

    isflipX = isflipX or false
    heroid = heroid or 4660
    local character_detail_cfg = getConfig(game_config_field.boss_info);


    local wuKongCfg = character_detail_cfg:getNodeWithKey(tostring(heroid));
    
    local animation = wuKongCfg:getNodeWithKey("animation"):toStr();
    -- local rgb = wuKongCfg:getNodeWithKey("rgb_sort"):toInt() or 0
    cclog2(animation,"animation-=-------------")
    local rgb = 0
    local tempIcon = game_util:createImgByName("image_" .. animation,rgb, true, isflipX)
    tempIcon:setScale(1.5)

    local tempSprite = CCSprite:createWithSpriteFrameName("ui_new_TeamBoss_light.png")
    tempSprite:setAnchorPoint(ccp(0.5,0.3))
    tempSprite:setPositionX(tempIcon:getContentSize().width*0.5)
    tempIcon:addChild(tempSprite,1000,1000)

    local tempSize = tempIcon:getContentSize();
    local wake_table = {"wake1","wake2","wake3","wake4","wake5","wake6","wake6","wake6","wake6","wake6","wake6"}
    local layer_table = {4,3,2,1,-1,-2,-3,-4,-5}--层级关系表
    local itemWakeCfg = wuKongCfg:getNodeWithKey(wake_table[1+1])
    if itemWakeCfg then
        local effectImg = itemWakeCfg:getNodeAt(0)
        if effectImg then
            for i=1,effectImg:getNodeCount() do
                local fileName = effectImg:getNodeAt(i-1):toStr()
                local splitTab = util.stringSplit(fileName,"_");
                local lastStr = splitTab[#splitTab]
                local layer = layer_table[tonumber(lastStr)]
                local effectNode = game_util:createUniversalAnim({animFile = fileName,loopFlag = true});
                if effectNode then
                    effectNode:setRhythm(1);
                    effectNode:setPosition(ccp(tempSize.width*0.5, 20))
                    if bFlipX ~= nil then
                        effectNode:setFlipX(bFlipX);
                    end
                    tempIcon:addChild(effectNode,layer)
                end
            end
        end
    end
    
    return tempIcon
end


function game_TeamTask_main:init( t_params )
	-- body
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_gameData = json.decode(t_params.gameData:getFormatBuffer()) or {};
    else
        self.m_gameData = {}
    end

    local gamedt = self.m_gameData.boss_info
    self.m_gameData.boss_info = {}
    for k,v in pairs(gamedt) do
        v.boss__index = tonumber(k)
        self.m_gameData.boss_info[#self.m_gameData.boss_info + 1] = v
    end

    table.sort( self.m_gameData.boss_info, function( a,b )
        return a.boss__index < b.boss__index
    end )

    self.m_selectIndex_go = t_params.index or 1
    self.m_selectIndex = 1
    self.m_bossInfoCfg = getConfig(game_config_field.boss_info)

    self.m_fromtype = t_params.fromtype
    self.m_fromteamid = t_params.team_id

    self.msg_boss_lv =t_params.boss_lv
    self.msg_boss_id =t_params.boss_id
    self.msg_boss_index =t_params.boss_index
    self.msg_boss_type = t_params.boss_type

    self.msg_msg_id = t_params.msg_id

    self.m_selectRewardId = 1
end

function game_TeamTask_main:create( t_params )
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end
return game_TeamTask_main