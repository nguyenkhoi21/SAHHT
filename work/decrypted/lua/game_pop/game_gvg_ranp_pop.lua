--- 戰場即時排名
local game_gvg_rank_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    
    show_table_node = nil,
    title_sprite = nil,
    m_close_btn = nil,
    m_tGameData = nil,
    enterType = nil,
    callBackFunc = nil,
};
--[[--
    銷毀
]]
function game_gvg_rank_pop.destroy(self)
    -- body
    cclog("-----------------game_gvg_rank_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    
    self.show_table_node = nil;
    self.title_sprite = nil;
    self.m_close_btn = nil;
    self.m_tGameData = nil;
    self.enterType = nil;
    self.callBackFunc = nil;
end
--[[--
    返回
]]
function game_gvg_rank_pop.back(self,type)
    -- game_scene:removePopByName("game_gvg_rank_pop");
    -- self:destroy();
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        local sort = data:getNodeWithKey("sort"):toInt()
        if sort == 1 then--外圍戰佈陣開啟
            game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 1});
        elseif sort == 2 then--外圍戰戰爭開始
            game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 2});
        elseif sort == 3 then--內城佈陣開始
            game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 3});
        elseif sort == 4 then--內城戰開始
            game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 4});
        elseif sort == 5 then
            
        elseif sort == -1 then--公會戰未開啟
            game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
        else
            game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = sort});
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_index"), http_request_method.GET, nil,"guild_gvg_index")
end
--[[--
    讀取ccbi創建ui
]]
function game_gvg_rank_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--關閉
            self:back();
        else--查看攻擊
            local index = btnTag - 100
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_gvg_rank_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    self.show_table_node = ccbNode:nodeForName("show_table_node")
    self.title_sprite = ccbNode:spriteForName("title_sprite")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    self.title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(self.enterType .. ".png"));
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end

    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[
    排行榜
]]
function game_gvg_rank_pop.createRankTable(self,viewSize)
    local rankLabelName = {"rank_1st.png","rank_2nd.png","rank_3th.png"}
    local colorTab = {ccc3(247,198,9),ccc3(252,234,30),ccc3(255,251,47)}
    local rankTable = self.m_tGameData.top
    local tabCount = game_util:getTableLen(rankTable)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.totalItem = tabCount;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_new_rank_item.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local user_head_node = ccbNode:nodeForName("m_icon_node");
            local top_icon = ccbNode:spriteForName("top_icon");
            local btn_look = ccbNode:controlButtonForName("btn_look")--查看
            local btn_look_2 = ccbNode:controlButtonForName("btn_look_2")--查看
            local btn_parise = ccbNode:controlButtonForName("btn_parise")--點贊
            local m_sprite9_cellbg = ccbNode:scale9SpriteForName("m_sprite9_cellbg")
            local parise_already = ccbNode:spriteForName("parise_already")
            local rank_number = ccbNode:labelBMFontForName("rank_number")

            local itemData = rankTable[index+1]
            cclog2(itemData,"itemData")
            --隱藏
            parise_already:setVisible(false)
            btn_look:setVisible(false)
            btn_look_2:setVisible(false)
            btn_parise:setVisible(false)
            ----
            if index < 3 then
                top_icon:setVisible(true)
                rank_number:setVisible(false)
                top_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(rankLabelName[index+1]))
                m_sprite9_cellbg:setColor(colorTab[index+1])
            else
                top_icon:setVisible(false)
                rank_number:setVisible(true)
                rank_number:setString(index+1)
                m_sprite9_cellbg:setColor(ccc3(255,255,255))
            end
            user_head_node:removeAllChildrenWithCleanup(true)
            local role = itemData.role or 1
            local icon = game_util:createPlayerIconByRoleId(tostring(role));
            local icon_alpha = game_util:createPlayerIconByRoleId(tostring(role));
            if icon then
                user_head_node:removeAllChildrenWithCleanup(true);
                icon_alpha:setAnchorPoint(ccp(0.5,0.5))
                icon_alpha:setPosition(ccp(7,4))
                icon_alpha:setOpacity(100)
                icon_alpha:setColor(ccc3(0,0,0))
                icon_alpha:setScale(0.9)
                user_head_node:addChild(icon_alpha)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(5,5))
                icon:setScale(0.9)
                user_head_node:addChild(icon);
            else
                cclog("tempFrontUser.role " .. role .. " not found !")
            end
            
            --設置不同排行榜的內容
            local variable_node = {}
            for i=1,3 do
                variable_node[i] = ccbNode:nodeForName("node_" .. i)
                variable_node[i]:removeAllChildrenWithCleanup(true)
            end
            variable_node[3]:setPosition(ccp(351,25))
            local name = itemData.name
            local guild_name = itemData.guild_name
            local score = itemData.score
            local child1 = game_util:createLabelTTF({text = name,fontSize = 12})
            local child2 = game_util:createLabelTTF({text = guild_name,fontSize = 12})
            local child3 = game_util:createLabelTTF({text = score,fontSize = 12})

            variable_node[1]:addChild(child1)
            variable_node[2]:addChild(child2)
            variable_node[3]:addChild(child3)


            if index >= 19 and index == game_util:getTableLen(self.m_tGameData.top) - 1 and self.cur_page < 4 then
                local tipLabel = game_util:createLabelTTF({text = "Kéo xuống tạo mới",color = ccc3(250,180,0),fontSize = 12});
                tipLabel:setAnchorPoint(ccp(0.5,0.5))
                tipLabel:setPosition(ccp(itemSize.width*0.5,-20))
                cell:addChild(tipLabel,20,20)
            else
                local tempNode = cell:getChildByTag(20)
                if tempNode then
                    tempNode:removeFromParentAndCleanup(true)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
        elseif eventType == "refresh" and item then
            if self.cur_page < 4 then
                self.cur_page = self.cur_page + 1
                self:requestForHttp()
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    添加新數據  當前排行榜添加新數據
]]
function game_gvg_rank_pop.requestForHttp(self)
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        local top = json.decode(data:getNodeWithKey("top"):getFormatBuffer())
        -- self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        for i=1,#top do
            table.insert(self.m_tGameData.top,top[i])
        end
        self:refreshUi()
    end
    local params = {}
    params.page = self.cur_page
    if self.enterType == "gvg_att_rank" then
        params.sort = "attacker"
    else
        params.sort = "defender"
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_top_rank"), http_request_method.GET, params,"guild_gvg_top_rank")
end
--[[--
    刷新ui
]]
function game_gvg_rank_pop.refreshUi(self)
    --排行榜
    self.show_table_node:removeAllChildrenWithCleanup(true)
    local tableView = self:createRankTable(self.show_table_node:getContentSize());
    self.show_table_node:addChild(tableView,10,10);
end

--[[--
    初始化
]]
function game_gvg_rank_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        -- local top = data:getNodeWithKey("top")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    cclog2(self.m_tGameData,"gameData")
    self.enterType = t_params.enterType or "gvg_att_rank"
    self.cur_page = 0
end
--[[--
    創建ui入口並初始化數據
]]
function game_gvg_rank_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回調方法
]]
function game_gvg_rank_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return game_gvg_rank_pop;