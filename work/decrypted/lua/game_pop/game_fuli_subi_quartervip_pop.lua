---  季卡奖励

local game_fuli_subi_quartervip_pop = {

    m_gameData = nil,

    m_quarterData = nil,
    m_gameData = nil,
    m_root_ccbNode = nil,
    m_isQuarterVIP = nil,
    m_conbtn_buy = nil,
    m_sprite_alredygot = nil,
}

--[[--
    销毁ui
]]
function game_fuli_subi_quartervip_pop.destroy(self)
    -- body
    cclog("----------------- game_fuli_subi_quartervip_pop destroy-----------------"); 

    self.m_gameData = nil;
    self.m_quarterData = nil;
    self.m_gameData = nil;
    self.m_root_ccbNode = nil;
    self.m_isQuarterVIP = nil;
    self.m_conbtn_buy = nil;
    self.m_sprite_alredygot = nil;
end
--[[--
    返回
]]
function game_fuli_subi_quartervip_pop.back(self,backType)
        self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_fuli_subi_quartervip_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_fuli_content_quartervip_board.ccbi");
    self.m_root_ccbNode = ccbNode
    return ccbNode
end

function game_fuli_subi_quartervip_pop.createHalfImage( self, heroid, isflipX  )
    isflipX = isflipX or false
    heroid = heroid or 4660
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local wuKongCfg = character_detail_cfg:getNodeWithKey(tostring(heroid));
    local animation = wuKongCfg:getNodeWithKey("animation"):toStr();
    local rgb = wuKongCfg:getNodeWithKey("rgb_sort"):toInt();
    local tempIcon = game_util:createImgByName("image_" .. animation,rgb, true, isflipX)
    tempIcon:setScale(1.5)
    return tempIcon
end

function game_fuli_subi_quartervip_pop.showRewardOnNode( self, node, rewardData, day)
    rewardData = rewardData or {}
    function onBtnCilck( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local day = btnTag/100
        local index = btnTag%100
        game_util:lookItemDetal( rewardData[index] )
    end
    if #rewardData == 0 then return end
    local posx = {  {0.5}, {0.33, 0.66}, {0.2, 0.5, 0.8}, {0, 0.33, 0.66, 1} }
    local curPosx = posx[#rewardData]
    local size = node:getContentSize()
    for i=1, #rewardData do
        local rewardItem = rewardData[i]
        if rewardItem then
        local icon,name,count = game_util:getRewardByItemTable(rewardItem);
            if icon then
                icon:setAnchorPoint(ccp(0.5, 0.5))
                icon:setPosition( size.width * curPosx[i], size.height * 0.5 )
                icon:setScale(0.7)
                node:addChild(icon, -1, 20)
                if name and count then
                    local labelName = game_util:createLabelBMFont({text = name .. "x" .. count, fontSize = 22, color = ccc3(255, 255, 255)})
                    labelName:setAnchorPoint(ccp(0.5, 1))
                    labelName:setPosition(icon:getContentSize().width * 0.5,  0 )
                    icon:addChild(labelName, 10)
                end
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition( icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5 )
                button:setOpacity(0)
                -- button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
                icon:addChild(button)
                day = tonumber(day)
                button:setTag(day*100 + i)
            end
        end
    end
end

--[[--
    刷新ui
]]
function game_fuli_subi_quartervip_pop.refreshUi(self)

    self.m_root_ccbNode:removeChildByTag( 987 , true)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("press button tag is ", btnTag)

        if btnTag == 101 then -- 购买
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_scene:enterGameUi("ui_vip",{gameData = gameData,isBuy="active"});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag == 102 then -- 领取奖励
            
            local function responseMethod(tag,gameData)
                local data = gameData and gameData:getNodeWithKey("data")
                local tempData
                if data then
                    tempData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                    self.m_gameData = tempData["quarter_award"]
                end
                self.showDays=self.showDays+1
                -- self.m_conbtn_get:setVisible(false)
                -- self.m_conbtn_get:setEnabled(false)
                -- self.m_already:setVisible(true)
                self:refreshUi()
                game_util:rewardTipsByDataTable( tempData.reward or {} );
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("get_award"), http_request_method.GET, {tp="quarter"},"get_award")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);

    local quarReward = self.m_gameData.reward
    local count = game_util:getTableLen(quarReward) or 20
    local quarterData = self.m_gameData or {}
    local showDays = quarterData.days or 0
    self.showDays = showDays

    ccbNode:openCCBFile("ccb/ui_fuli_content_quartervip.ccbi");
    self.m_conbtn_get = ccbNode:controlButtonForName("m_conbtn_get")
    self.m_already=ccbNode:spriteForName("already")
    self.first_get_node=ccbNode:nodeForName("first_get_node")
    self.showaward_node=ccbNode:nodeForName("showaward_node")
    self.first_award_ndoe=ccbNode:nodeForName("first_award_ndoe")
    self.award_node=ccbNode:nodeForName("award_node")
    self.quarterlable=ccbNode:labelTTFForName("quarterlable")
    self.days_lable=ccbNode:labelTTFForName("days_lable")
    self.m_award_list_node=ccbNode:nodeForName("m_award_list_node")
    if self.m_award_list_node then
        self.m_award_list_node:removeAllChildrenWithCleanup(true)
        self.m_award_list_node:addChild(self:createlistTable(self.m_award_list_node:getContentSize()),19)
    end
    if quarterData.pay_dt == "" or (showDays >= count) or not self.m_isQuarterVIP then
        self.days_lable:setString("Tích lũy nhận 0 lần")
        self.m_conbtn_get:setVisible(false)
        self.m_conbtn_get:setEnabled(false)
        self.m_already:setVisible(false)
        self:showRewardOnNode(self.first_award_ndoe, self.rewardlist[1], tostring(quarterData.days))
    elseif quarterData.pay_dt ~="" and self.m_isQuarterVIP then
        self.first_get_node:removeFromParentAndCleanup(true)
        self.showaward_node:setPositionY(70)
        self.quarterlable:setPositionY(70)
        showDays = quarterData.days or 0
        local server_time = game_data:getUserStatusDataByKey("server_time")
        local serstr = game_util.timestampToDate(server_time)
        if quarterData.award_day == serstr or showDays == 90 then  -- 已领取
            self.m_conbtn_get:setEnabled(false)
            self.m_conbtn_get:setVisible(false)
            self.m_already:setVisible(true)
        else
            self.m_conbtn_get:setEnabled(true)
            self.m_conbtn_get:setVisible(true)
            self.m_already:setVisible(false)
            showDays = showDays + 1
        end
        self.days_lable:setString("Tích lũy nhận" .. tostring(self.showDays) .. "lần")
    end
    showDays = math.max(showDays,1)
    showDays = math.min(showDays,90)
    self:showRewardOnNode(self.award_node, self.m_quarterData[tostring(math.max(showDays,1))].reward, tostring(quarterData.days))
    self.m_root_ccbNode:addChild(ccbNode, 10, 987)
end


function game_fuli_subi_quartervip_pop.createitem( self )
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_quartervip_award_item.ccbi");
    return ccbNode
end
function game_fuli_subi_quartervip_pop.createlistTable(self,viewSize)
    local list = self.diamondlist or {}
    local function onCellClick( target,event )
       
    end
    function onBtnCilck( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local day = btnTag/100
        local index = btnTag%100
        game_util:lookItemDetal( rewardData[index] )
    end
    local params ={}
    params.viewSize = viewSize
    params.column = 6
    params.row = 5
    params.direction = kCCScrollViewDirectionVertical; 
    params.totalItem=90    --数量
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row)
    params.newCell = function( tableView,index )
        local cell = tableView:dequeueCell()
        local itemcfg = list[index+1]
        local icon , name , count = nil,nil,nil
            cell=CCTableViewCell:new()
            cell:autorelease()
            icon , name , count = game_util:getRewardByItemTable(itemcfg)
            if icon then
                cell:addChild(icon,10,10)
            end
            if icon then
                    icon:setAnchorPoint(ccp(0.5, 0.5))
                    icon:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
                    icon:setScale(0.7)
                    if name and count then
                        local labelName = game_util:createLabelBMFont({text = name .. "x" .. count, fontSize = 22, color = ccc3(255, 255, 255)})
                        labelName:setAnchorPoint(ccp(0.5, 1))
                        labelName:setPosition(icon:getContentSize().width * 0.5,  10 )
                        icon:addChild(labelName, 10)
                    end
            end
        return cell
    end
    params.itemOnClick = function (index,item )
        
    end
    return TableViewHelper:create(params)
end
--[[
    创建奖励列表数据
]]
function game_fuli_subi_quartervip_pop.initraward( self)
    local quarterCfg = getConfig(game_config_field.quarter_award)
    -- self.m_quarterData = json.decode(quarterCfg and quarterCfg:getFormatBuffer()) or {}
    local rewardlist = {}
    local diamondlist = {}
    for i=1,90 do
        rewardlist[i]=self.m_quarterData[tostring(i)].reward
        diamondlist[i]=rewardlist[i][1]
    end
    -- cclog2(diamondlist,"diamondlist~~~~~")
    return diamondlist,rewardlist
end
--[[--
    初始化
]]
function game_fuli_subi_quartervip_pop.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" and t_params.gameData:getNodeWithKey("data") then
        local data = t_params.gameData:getNodeWithKey("data"):getNodeWithKey("quarter_award")
        self.m_gameData = json.decode(data:getFormatBuffer()) or {}
    end
    self.m_quarterData = self.m_gameData.reward
    self.version = self.m_gameData.version
    self.diamondlist,self.rewardlist =self:initraward()
    local quarterDays = game_util:getTableLen( self.m_quarterData )
    quarterData = self.m_gameData.quarter_award or {}
    self.quarterData=quarterData
    if quarterData.pay_dt ~= "" then
        self.m_isQuarterVIP = true
    else
        self.m_isQuarterVIP = false
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_fuli_subi_quartervip_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_fuli_subi_quartervip_pop