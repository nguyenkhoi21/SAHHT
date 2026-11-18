--- 我是大富翁
local game_super_luck = {
  
    m_ccbNode = nil,
    m_curPage = nil,
    m_root_layer = nil,
    m_lattice_tab = nil,
    m_map_tab = nil,
    m_select1_btn = nil,
    m_select2_btn = nil,
    m_cur_pos = nil,
    m_sign = nil,
    m_sieve_sp = nil,
    m_btouzhi = nil,
    m_rank_list = nil,
    m_score_label = nil,
    m_ranking_label =nil, 
    m_glod_lable = nil,
    m_sieve_lable =nil,
    m_diamond_lable =nil,
    m_wdgr_label = nil,
    m_time_label = nil,
    m_bGo = nil,
    m_item_sp = nil,
    m_baction = nil,
    m_list_node = nil,
    m_melirew_label = nil,
  
};
--[[--
    销毁ui
]]
function game_super_luck.destroy(self)
    -- body
    cclog("-----------------game_super_luck destroy-----------------");
  
    self.m_curPage = nil;
    self.m_ccbNode = nil;
    self.m_root_layer = nil;
    self.m_lattice_tab = nil;
    self.m_map_tab = nil;
    self.m_select1_btn = nil;
    self.m_select2_btn = nil;
    self.m_cur_pos = nil;
    self.m_sign = nil;
    self.m_sieve_sp = nil;
    self.m_btouzhi = nil;
    self.m_rank_list = nil;
    self.m_score_label = nil;
    self.m_ranking_label = nil;
    self.m_glod_lable = nil;
    self.m_sieve_lable =nil;
    self.m_diamond_lable = nil;
    self.m_wdgr_label = nil;
    self.m_time_label = nil;
    self.m_bGo = nil;
    self.m_item_sp = nil;
    self.m_baction = nil;
    self.m_list_node = nil;
    self.m_melirew_label = nil;

    if self.m_shared then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
        self.m_shared = nil
    end
   
end
--[[--
    返回
]]
function game_super_luck.back(self,backType)
    if backType == "back" then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui    equipSortByTypeName
]]
function game_super_luck.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();

        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 2 then--排名奖励
            game_scene:addPop("game_super_luck_rankreward_pop",{version = self.m_data.version}) 
        elseif btnTag == 3 then --兑换商店
            local params = {}
            params.sort = 1
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) 
                game_scene:enterGameUi("game_super_luck_exchange_shop",{gameData = data})   
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_luck_shop_index"), http_request_method.GET, params,"super_luck_shop_index")
        elseif btnTag == 4 then -- 规则
             game_scene:addPop("game_super_luck_rule",{gameData = self.m_data.version}) 
        elseif btnTag == 5 then--投筛子
            if self.m_btouzhi then
                return
            end
            local luck = 0
            local map_tab = self.m_map_tab[tostring(self.m_cur_pos)]
            if map_tab.unit_content == 4 then
                luck = 1
            end

            local params = {}
            params.is_luck = luck
            self.m_sieve_sp:setVisible(false)
            local function responseMethod(tag,gameData)
                self.m_btouzhi = true
                local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) 
                --cclog2(data,"data")
                self.m_data = data
                if data.is_lucky then
                    self.m_bGo = data.luck_choose
                else
                    self.m_bGo = 0
                end

                self:refreshUi()
                if self.m_baction then
                    self:createAnimian(data.dice_step,data.reward)
                else
                    self:createAnimian2(data.dice_step,data.reward)
                end
                
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_luck_throw_dice"), http_request_method.GET, params,"super_luck_throw_dice")
        elseif btnTag == 6 then
            self:selectCellState()
        elseif btnTag == 7 then
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_super_luck.ccbi");

    for i=1,20 do
        local lattice = ccbNode:spriteForName("lattice_"..i)
        self.m_lattice_tab[#self.m_lattice_tab+1] = lattice
    end
    --英雄相关
    self.m_lattices_node = ccbNode:nodeForName("m_lattices_node")
    local close_btn = ccbNode:controlButtonForName("m_close_btn")
    close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    local m_paimraw_btn = ccbNode:controlButtonForName("m_paimraw_btn")
    m_paimraw_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    local m_duihshop_btn = ccbNode:controlButtonForName("m_duihshop_btn")
    m_duihshop_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    local m_help_btn = ccbNode:controlButtonForName("m_help_btn")
    m_help_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    local m_thrw_btn = ccbNode:controlButtonForName("m_thrw_btn")
    m_thrw_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_select1_btn = ccbNode:controlButtonForName("m_select1_btn")
    self.m_select1_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_select2_btn = ccbNode:controlButtonForName("m_select2_btn")
    --self.m_select2_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)

    self.m_score_label = ccbNode:labelTTFForName("m_score_label")
    self.m_ranking_label = ccbNode:labelTTFForName("m_ranking_label")
    self.m_glod_lable = ccbNode:labelTTFForName("m_glod_lable")
    self.m_sieve_lable = ccbNode:labelTTFForName("m_sieve_lable")
    self.m_diamond_lable = ccbNode:labelTTFForName("m_diamond_lable")
    self.m_wdgr_label = ccbNode:labelTTFForName("m_wdgr_label")
    self.m_time_label = ccbNode:labelTTFForName("m_time_label")
    self.m_melirew_label = ccbNode:labelTTFForName("m_melirew_label")

    self.m_sign = ccbNode:spriteForName("m_sign")
    self.m_sieve_sp = ccbNode:spriteForName("m_sieve")
    self.m_list_node = ccbNode:nodeForName("m_list_node")

    self.m_item_sp = ccbNode:spriteForName("m_item_sp")

    self.m_ccbNode = ccbNode
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_rank_list = ccbNode:layerForName("m_rank_list")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then

            realPos = self.m_lattices_node:convertToNodeSpace(ccp(x,y))
            for k,v in ipairs(self.m_lattice_tab) do
                local px,py = v:getPosition()
                if v:boundingBox():containsPoint(realPos) then
                    cclog("m_material_node click ==== " .. k)
                    local shop_reward_item = self.m_map_tab[tostring(k)]["unit_reward"][1];
                    if shop_reward_item then
                        local tempType = shop_reward_item[1]
                        if tempType == 6 then--道具
                            local itemId = shop_reward_item[2]
                            game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
                        elseif tempType == 7 then--装备
                            local equipId = shop_reward_item[2]
                            local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                            game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
                        elseif tempType == 5 then--卡牌
                            local cId = shop_reward_item[2]
                            game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
                        else
                            game_scene:addPop("game_food_info_pop",{itemData = shop_reward_item})
                        end
                    end
                    break;
                end
            end
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);

    if self.m_data.near_dice_point>0 and self.m_data.near_dice_point<7 then
        local png = "sieve_"..self.m_data.near_dice_point..".png"
        self.m_sieve_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(png))
    end
    
    self:refreshCardTableView()
   
    return ccbNode;
end

function game_super_luck.move(self, index,reward)
    local actionArr = CCArray:create()
    actionArr:addObject(CCDelayTime:create(1.0))
    local old_pos = self.m_data.old_pos
    local new_pos = self.m_data.new_pos
    local dice_step = self.m_data.dice_step

    local step = new_pos - old_pos
    if step>0 then
        for i=1,step do
            local lattice = self.m_lattice_tab[self.m_cur_pos+i]
            local x,y = lattice:getPosition()
            actionArr:addObject(CCMoveTo:create(0.2,ccp(x,y)))
        end
    else
        if old_pos+dice_step>20 then
            for i=old_pos,20 do
                local lattice = self.m_lattice_tab[i]
                local x,y = lattice:getPosition()
                actionArr:addObject(CCMoveTo:create(0.2,ccp(x,y)))
            end
            for i=1,new_pos do
                local lattice = self.m_lattice_tab[i]
                local x,y = lattice:getPosition()
                actionArr:addObject(CCMoveTo:create(0.2,ccp(x,y)))
            end
        else
            for i=-1,step,-1 do
                local lattice = self.m_lattice_tab[self.m_cur_pos+i]
                local x,y = lattice:getPosition()
                actionArr:addObject(CCMoveTo:create(0.2,ccp(x,y)))
            end
        end
    end
    
    function healthNoticeEnd()
        self.m_btouzhi = false
        self.m_cur_pos = self.m_data.cur_pos

        if self.m_bGo == 1 then
            game_util:addMoveTips({text = "恭喜您本次可直接到达终点"})
            local actionArr2 = CCArray:create()
            for i=1,20-new_pos do
                local lattice = self.m_lattice_tab[new_pos+i]
                local x,y = lattice:getPosition()
                actionArr2:addObject(CCMoveTo:create(0.2,ccp(x,y)))
            end
            local lattice = self.m_lattice_tab[1]
            local x,y = lattice:getPosition()
            actionArr2:addObject(CCMoveTo:create(0.2,ccp(x,y)))
            self.m_sign:runAction(CCSequence:create(actionArr2))
            return
        elseif self.m_bGo == 2 then
            game_util:addMoveTips({text = "恭喜您抽中前进格"})
        elseif self.m_bGo == 3 then
            game_util:addMoveTips({text = "很遗憾你抽中了后退格"})
        end

        local lattice = self.m_lattice_tab[self.m_cur_pos]
        local map_tab = self.m_map_tab[tostring(self.m_cur_pos)]
        if map_tab.unit_content==1 or map_tab.unit_content==2 then
            if self.m_cur_pos~=1 then
                lattice:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("lattice_1.png"))
            end
        end
        if map_tab.unit_content == 2 then
            game_util:rewardTipsByDataTable(reward.reward)
        end

        --限定奖励
        if map_tab.unit_content == 3 then
            game_util:rewardTipsByDataTable(reward.reward)
        end

        --限时奖励
        if map_tab.unit_content == 5 then
            local params = {}
            params.sort = 2
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) 
                game_scene:addPop("game_super_luck_limited_pop",{gameData = data})   
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_luck_shop_index"), http_request_method.GET, params,"super_luck_shop_index")
        end
    end
    actionArr:addObject(CCCallFuncN:create(healthNoticeEnd))
    self.m_sign:runAction(CCSequence:create(actionArr))
end

function game_super_luck.initMap(self)
    local map_tab = {}
    for i=1,20 do
        map_tab[#map_tab+1] = self.m_map_tab[tostring(i)]
    end

    table.sort(map_tab,function (a, b)
        return a.unit_id < b.unit_id
    end)
   
    for i=2,20 do
        local lattice = self.m_lattice_tab[i]
        local map_info = map_tab[i]
        local content = map_info.unit_content
        local clor = 2
        if content ~= 1 then
            clor = content
        end
        local png = "lattice_"..clor..".png"
        if png ~= "lattice_1.png" then
            lattice:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(png))
        end

        if i==self.m_cur_pos then
            if content==1 or content==2 then
                lattice:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("lattice_1.png"))
            end
            self.m_sign:setPosition(lattice:getPosition())
        end

        --奖励格
        if content == 2 and #map_info["unit_reward"] > 0 then
            local icon,name,count = game_util:getRewardByItemTable(map_info["unit_reward"][1])
            local size = lattice:getContentSize()
            local label_temp = CCLabelTTF:create(tostring("x"..count),TYPE_FACE_TABLE.Arial_BoldMT,10)
            label_temp:setPosition(ccp(size.width-20,16))
            lattice:addChild(label_temp,2)
            icon:setScale(0.6)
            icon:setPosition(ccp(size.width*0.5,size.height*0.5))
            lattice:addChild(icon)
        end

        if content == 3 then
            local sp = CCSprite:createWithSpriteFrameName("super_luck_reward_label.png")
            local size = lattice:getContentSize()
            sp:setPosition(ccp(size.width*0.5,size.height*0.5))
            lattice:addChild(sp)
        end

        if content == 4 then
            local sp = CCSprite:createWithSpriteFrameName("super_luck_yunqi_label.png")
            local size = lattice:getContentSize()
            sp:setPosition(ccp(size.width*0.5,size.height*0.5))
            lattice:addChild(sp)
        end

        if content == 5 then
            local sp = CCSprite:createWithSpriteFrameName("super_luck_shop_label.png")
            local size = lattice:getContentSize()
            sp:setPosition(ccp(size.width*0.5,size.height*0.5))
            lattice:addChild(sp)
        end
    end
end

function game_super_luck.createAnimian(self,index,reward)
    local animFile = "rengtouzi"
    local m_iAnim = zcAnimNode:create(animFile .. ".swf.sam",0,animFile .. ".plist");
    local function animEnd(animNode,theId,lableName)
        local node = self.m_root_layer:getChildByTag(102)
        node:removeFromParentAndCleanup(true)
        m_iAnim:removeFromParentAndCleanup(true)
        self:createAnimian2(index,reward)
    end
    m_iAnim:registerScriptTapHandler(animEnd);
    m_iAnim:playSection("impact");
    m_iAnim:setScale(1);
    m_iAnim:setPosition(ccp(300,155))

    self.m_root_layer:addChild(m_iAnim,10,102)
end

function game_super_luck.createAnimian2(self,index,reward)
    local animFile = "touzi_1_11"
    local m_iAnim = zcAnimNode:create(animFile .. ".swf.sam",0,animFile .. ".plist");
    local function animEnd(animNode,theId,lableName)
        local node = self.m_root_layer:getChildByTag(103)
        node:removeFromParentAndCleanup(true)
        m_iAnim:removeFromParentAndCleanup(true)
        local lattice = self.m_lattice_tab[self.m_cur_pos]
        local map_tab = self.m_map_tab[tostring(self.m_cur_pos)]
        if map_tab.unit_content==1 or map_tab.unit_content==2 then
            if self.m_cur_pos~=1 then
                lattice:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("lattice_2.png"))
            end
        end
        self:move(index,reward)

        self.m_sieve_sp:setVisible(true)
        local png = "sieve_"..index..".png"
        self.m_sieve_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(png))
    end
    m_iAnim:registerScriptTapHandler(animEnd);
    m_iAnim:playSection("impact");
    m_iAnim:setScale(1);
    m_iAnim:setPosition(ccp(518,92))
  
    self.m_root_layer:addChild(m_iAnim,10,103)
end

--[[--
    刷新
]]
function game_super_luck.refreshCardTableView(self)
    self.m_rank_list:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil
    self.m_tableView = self:createTableView(self.m_rank_list:getContentSize())
    self.m_rank_list:addChild(self.m_tableView)

    self.m_list_node:removeAllChildrenWithCleanup(true);
    self.m_tableView2 = nil
    self.m_tableView2 = self:createTableView2(self.m_list_node:getContentSize())
    self.m_list_node:addChild(self.m_tableView2)
end

function game_super_luck.selectCellState(self, index)
    if self.m_baction then
        self.m_baction = false
        self.m_select2_btn:setVisible(false)
    else
        self.m_baction = true
        self.m_select2_btn:setVisible(true)
    end
end

--[[--
    创建卡槽列表
]]
function game_super_luck.createTableView(self,viewSize)
    local all_rank_info = self.m_data.all_rank_info
    local showData = {}
    for i,v in pairs(all_rank_info) do
        showData[#showData+1] = {data=v, name=i}
    end
    --cclog2(showData,"showData")

    table.sort(showData, function(a,b)
         return a.data.rank < b.data.rank
    end)
 
    local cardsCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = cardsCount -- totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1
    
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()
            ccbNode:openCCBFile("ccb/ui_super_luck_rank_item.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < cardsCount then
                local rankTab = showData[index+1]
               local m_rank_label = ccbNode:labelTTFForName("m_rank_label")
               local m_name_label = ccbNode:labelTTFForName("m_name_label")
               local m_score_label = ccbNode:labelTTFForName("m_score_label")

               m_rank_label:setString(rankTab.data.rank)
               m_name_label:setString(rankTab.name)
               m_score_label:setString(rankTab.data.scores)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then

        elseif eventType == "longClick" and cell then
    
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    local tableView = TableViewHelper:create(params);
    return tableView
end

function game_super_luck.createTableView2(self,viewSize)
    local limit_reward = self.m_data.limit_reward
    local showData = {}
    
    local dexs = 0
    for k,v in pairs(limit_reward) do
        if v.reward then
            showData[#showData+1] = {data=v.reward,count = v.remain_num}
        end
    end
    local cardsCount = #showData

    for i=1,cardsCount do
        if showData[i].count<=0 then
            dexs = dexs + 1
        end
    end

    if dexs == cardsCount then
        self.m_melirew_label:setVisible(true)
    else
        self.m_melirew_label:setVisible(false)
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 2; --列
    params.totalItem = cardsCount -- totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1
    
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            if index < cardsCount then
                local icon,name,count = game_util:getRewardByItemTable(showData[index+1]["data"])
                icon:setScale(0.65)
                local label = CCLabelTTF:create(tostring("X"..count.."X"..showData[index+1]["count"]),TYPE_FACE_TABLE.Arial_BoldMT,14)
                label:setPosition(ccp(22,-7))
                icon:addChild(label,999)
                icon:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
                cell:addChild(icon)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
            local info1 = showData[index+1]["data"]
            if #info1 > 1 then
                local tempType = info1[1]
                if tempType == 6 then--道具
                    local itemId = info1[2]
                    game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
                elseif tempType == 7 then--装备
                    local equipId = info[2]
                    local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                    game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
                elseif tempType == 5 then--卡牌
                    local cId = info1[2]
                    game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
                else                   -- 食品
                    game_scene:addPop("game_food_info_pop",{itemData = info1})
                end
            end
        elseif eventType == "longClick" and cell then
    
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    local tableView = TableViewHelper:create(params);
    return tableView
end


--[[--
    刷新ui
]]
function game_super_luck.refreshUi(self)
    self:refreshCardTableView()
    local itemsData = game_data:getItemsData()
    local saizi_count = 0
    local gold_count = 0
    for k,v in pairs(itemsData) do
        if k == "511907" then
            for k,v in pairs(v) do
                saizi_count = saizi_count + v
            end
        end

        if k == "511906" then
            for l,g in pairs(v) do
                gold_count = gold_count + g
            end
        end
    end

    local totalFood = game_data:getUserStatusDataByKey("coin") or 0
    local value,unit = game_util:formatValueToString(totalFood)
    local value2,unit2 = game_util:formatValueToString(saizi_count)
    local value3,unit3 = game_util:formatValueToString(gold_count)
    
    self.m_score_label:setString("Tích điểm hiện tại："..self.m_data.self_rank_info.scores)
    self.m_ranking_label:setString("Xếp hạng tích điểm: Chưa có："..self.m_data.self_rank_info.rank)
    self.m_glod_lable:setString(value3..unit3)
    self.m_sieve_lable:setString(value2..unit2)
    self.m_diamond_lable:setString(value..unit)

    -- self.m_time_label

    local icon,name,count = game_util:getRewardByItemTable(self.m_data.throw_consume[1],false,1)

    local x,y = self.m_item_sp:getPosition()
    self.m_item_sp:setVisible(false)
    icon:setPosition(ccp(x,y))
    icon:setScale(0.35)
    self.m_root_layer:addChild(icon)
    self.m_wdgr_label:setString("X"..count)

    local hours,minutes,seconds = nil
    if self.m_shared == nil then
        function tick()
            if self.m_data.remain_time > 0 then
                hours = math.floor(self.m_data.remain_time / 3600)
                minutes = math.floor((self.m_data.remain_time - hours * 3600)/ 60)
                seconds = math.floor(self.m_data.remain_time - 3600 * hours - 60 * minutes)
                hours = hours<10 and "0"..hours or ""..hours
                minutes = minutes<10 and "0"..minutes or ""..minutes
                seconds = seconds<10 and "0"..seconds or ""..seconds
                self.m_time_label:setString("CD event: "..hours..":"..minutes..":"..seconds)
                self.m_data.remain_time = self.m_data.remain_time - 1
            else
                -- self:back()
                --self.m_time_label:setString("倒计时: 活动已结束")
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_shared)
                self.m_shared = nil
            end
            
        end
        self.m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1 , false)
    end
    
end

--[[--
    初始化
]]
function game_super_luck.init(self,t_params)
    local params = t_params.gameData or {};
    self.m_lattice_tab = {}
    self.m_btouzhi = false
    self.m_baction = true
  
    self.m_data = json.decode(params:getNodeWithKey("data"):getFormatBuffer())
    self.m_cur_pos = self.m_data.cur_pos
    self.m_map_tab = self.m_data["map_info"]
    
    --cclog2(self.m_data,"m_data")
end

--[[--
    创建ui入口并初始化数据
]]
function game_super_luck.create(self,t_params)
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:initMap();
    self:refreshUi();
    return uiNode;
end

return game_super_luck;
