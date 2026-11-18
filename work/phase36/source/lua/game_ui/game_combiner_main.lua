--召唤兽主界面
local game_combiner_main ={
    m_team_layer = nil,
    m_teamNodeTab = nil,
    openTab = nil,
    fight_flag = nil,
}

--[[--
    销毁ui
]]
function game_combiner_main.destroy( self )
    -- body
    cclog("-----------------game_combiner_main destroy-----------------");
    self.m_team_layer = nil;
    self.m_teamNodeTab = nil;
    self.openTab = nil;--神兽开关
    self.fight_flag = nil; -- 出战标记
end

--[[--
    返回
]]
function game_combiner_main.back(self,type)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_combiner_main.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 33 then --出战
            game_scene:addPop("game_combiner_gobattle",{gameData = nil,openTab = self.openTab})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_Monster_Summoning_main.ccbi");
    self.m_team_layer = ccbNode:layerForName("m_team_layer")
    self.m_list_node = ccbNode:nodeForName("m_list_node")
    local tempSpri = nil;
    local combinerCfg = getConfig(game_config_field.combiner)
    -- for i=1,4 do
    --     tempSpri = ccbNode:nodeForName("m_team_bg_" .. i);
    --     self.m_teamNodeTab[i] = tempSpri;
    --     local isShow = self.GameDate[tostring(i)].is_open
    --     local animNode = self:createCardAnimByData(combinerCfg:getNodeWithKey(tostring(i)))
    --     animNode:setScale(0.85)
    --     if isShow == 0 or isShow == "0"  then
    --         animNode:setColor(ccc3(0,0,0))
    --     end
    --     animNode:setPosition(ccp(45,0))
    --     tempSpri:removeAllChildrenWithCleanup(true)
    --     tempSpri:addChild(animNode,10,10);
    --     local nameSp = CCSprite:createWithSpriteFrameName("Monster_Summoning_title".. i .. ".png")
    --     local size = tempSpri:getContentSize()
    --     nameSp:setPosition(ccp(size.width/2,size.height + 60))
    --     tempSpri:addChild(nameSp)
    -- end
    -- self:initLayerTouch(self.m_team_layer);
    return ccbNode;
end

--[[
    获取小伙伴位置上的动画
]]
function game_combiner_main.createCardAnimByData( self,combinerCfg,animFlag)
    local animNode = nil;
    if combinerCfg then
        local ainmFile = combinerCfg:getNodeWithKey("animation"):toStr();
        animFlag = animFlag == nil and true or animFlag
        if animFlag then
            animNode = game_util:createIdelAnim(ainmFile,0,nil,combinerCfg);
        else
            animNode = game_util:createCardImgByCfg(combinerCfg);
        end
        if animNode then
            local itemSize = animNode:getContentSize();
            if animFlag == false then
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dw_light_down.png")
                if spriteFrame then
                    local tempSprite = CCSprite:createWithSpriteFrame(spriteFrame)
                    tempSprite:setAnchorPoint(ccp(0.5,0.1))
                    tempSprite:setPositionX(itemSize.width*0.5)
                    animNode:addChild(tempSprite)
                end
                local spriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dw_light_up.png")
                if spriteFrame2 then
                    local tempSprite = CCSprite:createWithSpriteFrame(spriteFrame2)
                    tempSprite:setAnchorPoint(ccp(0.5,0.1))
                    tempSprite:setPositionX(itemSize.width*0.5)
                    animNode:addChild(tempSprite,1000,1000)
                end
            else
                animNode:setRhythm(1);
            end
            animNode:setAnchorPoint(ccp(0.5,0));
            local occupation = 1
            local animation = combinerCfg:getNodeWithKey("animation"):toStr()
            local occupationCfg = getConfig(game_config_field.occupation)
            if occupationCfg:getNodeWithKey(animation) then
                occupation = occupationCfg:getNodeWithKey(animation):toInt()
            end
            animNode:setScale(1.2);
        end
    end
    return animNode
end

--[[--
    触摸
]]

--[[
function game_combiner_main.initLayerTouch(self,touch_layer)
    local tempItem,selItem,realPos
    local function onTouchBegan(x, y)
        -- CCTOUCHBEGAN event must return true
        selItem = nil;
        realPos = self.m_team_layer:convertToNodeSpace(ccp(x,y));
        for k,v in pairs(self.m_teamNodeTab) do
            tempItem = v
            if tempItem:boundingBox():containsPoint(realPos) then
                selItem = tempItem;
                break;
            end
        end
        return true
    end
    local function onTouchMoved(x, y)
    end
    local function onTouchEnded(x, y)
        realPos = self.m_team_layer:convertToNodeSpace(ccp(x,y));
        if selItem and selItem:boundingBox():containsPoint(realPos) then
            -- cclog("on click -----------------------------" .. selItem:getTag())
            local selNum = selItem:getTag();
            local num = tonumber(selNum - 10) or 0;
            local combinerData = self.GameDate[tostring(selNum - 10)]
            game_data:setCombinerData(self.GameDate);
            if self.openTab[num] == 0 or self.openTab[num] =="0" then
                local function callBack(typeName)
                    typeName = typeName or ""
                    if typeName == "refresh" then
                        -- self:refreshTeamLayer();
                    end
                end
                game_scene:enterGameUi("game_combiner_summon",{openType = 1,gameData = combinerData ,callBack = callBack, MyselNum = selNum - 10})
            else
                game_scene:enterGameUi("game_combiner_detail",{openType = 2,gameData = combinerData ,callBack = callBack, MyselNum = selNum - 10})
            end
        end
        tempItem = nil;
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
        elseif eventType == "moved" then
            return onTouchMoved(x, y)
        else
            return onTouchEnded(x, y)
        end
    end
    touch_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+140,false)
    touch_layer:setTouchEnabled(true)
end

]]


function game_combiner_main:createTableview(viewSize)
    local combinerCfg = getConfig(game_config_field.combiner)
    local params = {};
    params.row = 1;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = combinerCfg:getNodeCount()
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 1;
    params.viewSize = viewSize;
    params.offset =  -5
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        local isShow
        if self.GameDate[tostring(index + 1)] then
            isShow = self.GameDate[tostring(index + 1)].is_open
        else
            isShow = 0
            self.GameDate[tostring(index + 1)] = {}
            self.GameDate[tostring(index + 1)].is_open = 0
            self.openTab[index + 1] = 0
        end
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5-2));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            ccbNode:removeAllChildrenWithCleanup(true)
            local animNode = self:createCardAnimByData(combinerCfg:getNodeWithKey(tostring(index + 1)))
            local nameSp
            if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring("Monster_Summoning_title".. index + 1 .. ".png")) then
                nameSp = CCSprite:createWithSpriteFrameName("Monster_Summoning_title".. index + 1 .. ".png")
            else
                nameSp = CCSprite:create("God_beast/" .. "Monster_Summoning_title".. index + 1 .. ".png")
            end
            -- local nameSp = CCSprite:createWithSpriteFrameName("Monster_Summoning_title".. index + 1 .. ".png")
            local bgSp1 = CCSprite:createWithSpriteFrameName("Monster_Summoning_cellbg.png")
            local bgSp2 = CCSprite:createWithSpriteFrameName("Monster_Summoning_cellguang.png")
            if bgSp1 and bgSp2 then
                bgSp1:setPosition(ccp(0,-88))
                bgSp2:setPosition(ccp(0,6))
                -- bgSp2:setScale(2)
                ccbNode:addChild(bgSp2,10,10);
                ccbNode:addChild(bgSp1,10,10);
            end
            if animNode then
                if isShow == 0 or isShow == "0"  then
                    animNode:setColor(ccc3(0,0,0))
                end
                animNode:setPosition(ccp(0,-88))
                animNode:setScale(0.85)
                ccbNode:addChild(animNode,10,10);
            end
            if nameSp then
                nameSp:setPosition(ccp(0,100))
                ccbNode:addChild(nameSp,10,10);
            end
            
        end
        return cell;
    end

    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local combinerData = self.GameDate[tostring(index + 1)]
            game_data:setCombinerData(self.GameDate);
            local isShow = self.GameDate[tostring(index + 1)].is_open
            -- cclog2(combinerData)
            if isShow == 0 or isShow == "0"  then
                -- cclog("-------------------")
                game_scene:enterGameUi("game_combiner_summon",{openType = 1,gameData = combinerData , MyselNum = index + 1})
            else
                -- cclog("====================")
                game_scene:enterGameUi("game_combiner_detail",{openType = 2,gameData = combinerData , MyselNum = index + 1})
            end
        end
    end
    return TableViewHelper:createGallery2(params);
end
--[[--
    刷新
]]
function game_combiner_main.refreshTeamLayer(self)
    local tempNode;
    for i=1,4 do
        local animNode = self:createCardAnim(i);
        tempNode = self.m_teamNodeTab[i]
        if animNode and tempNode then
            tempNode:removeAllChildrenWithCleanup(true);
            local tempSize = self.m_teamNodeTab[i]:getContentSize();
            animNode:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.13));
            tempNode:addChild(animNode,1,1);
            if self.GameDate[tostring(i)].is_open == 0 then
                -- local bgLayer = CCLayerColor:create(ccc4(255,255,255,255),36,36);
                -- bgLayer:setAnchorPoint(ccp(0.5,0.5))
                -- bgLayer:ignoreAnchorPointForPosition(false);
                -- animNode:addChild(bgLayer)
                animNode:setColor(ccc3(0,0,0))
            else
                animNode:setColor(ccc3(255,255,255))
            end
        end
    end
end

function game_combiner_main.createCardAnim(self,num)

    local combiner_detail_cfg = getConfig(game_config_field.combiner);
    local heroCfg = combiner_detail_cfg:getNodeWithKey(tostring(num));
    local animNode = nil;
    if heroCfg then
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        animNode = game_util:createIdelAnim(ainmFile,0,nil,heroCfg);
        if animNode then
            animNode:setRhythm(1);
            game_anim:playSection(animNode , anim_label_name_cfg.daiji);
            local itemSize = animNode:getContentSize();
            animNode:setAnchorPoint(ccp(0.5,0));
        end
    end
    return animNode;
end

function game_combiner_main:refreshUi( )
    for i=1,game_util:getTableLen(self.GameDate) do
        self.openTab[i] = self.GameDate[tostring(i)].is_open
    end
    -- cclog2(self.openTab)
    self.m_list_node:addChild(self:createTableview(self.m_list_node:getContentSize()))
end


--[[--
    初始化
]]
function game_combiner_main.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    self.m_teamNodeTab = {};
    self.GameDate = self.gameData.fable_beasts
     cclog2(self.GameDate,"--haha")
    self.fight_flag = self.gameData.fight_beast or nil
    self.openTab = {};
    game_data:setCombinerData(self.GameDate);
    game_data:setCombinerfightData(self.fight_flag)
end

--[[--
    创建ui入口并初始化数据
]]
function game_combiner_main.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_combiner_main;