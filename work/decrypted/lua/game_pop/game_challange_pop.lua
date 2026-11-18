--  ui模版

local game_challange_pop = {
    m_node_listbg = nil,
};
--[[--
    銷毀ui
]]
function game_challange_pop.destroy(self)
    -- body
    cclog("----------------- game_challange_pop destroy-----------------"); 
    self.m_node_listbg = nil;
end
--[[--
    返回
]]
function game_challange_pop.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    讀取ccbi創建ui
]]
function game_challange_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- print("press button tag is ", btnTag)
        if btnTag == 1 then -- 關閉
            self:back()
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_challange_pop.ccbi");

    self.m_node_listbg = ccbNode:nodeForName("m_node_listbg")

    -- -- 光效 顯示
    -- local falsh_blindness = ccbNode:spriteForName("falsh_blindness")
    -- falsh_blindness:runAction(game_util:createRepeatForeverFade());

    -- 本層阻止觸摸傳導下一層
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    -- 重置按鈕出米優先級 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    return ccbNode;
end

--[[--
    創建列表
]]
function game_challange_pop.createChallangeList( self, viewSize )
    -- body
    local itemCount = 3
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 3;
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height/params.row);
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell();
        if cell == nil then 
            cell = CCTableViewCell:new()
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_challange_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end

        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")    
            local m_sprie_wait = ccbNode:spriteForName("m_sprie_wait")
            local m_sprite_show = ccbNode:spriteForName("m_sprite_show")
            if m_sprie_wait and index == 0 then
                m_sprie_wait:setVisible(false)
            elseif m_sprite_show then
                m_sprite_show:setColor(ccc3(155, 155, 155))
            end

            local tempFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_challange_banner_" .. (index + 1) ..".png")
            if m_sprite_show and tempFrame then
                m_sprite_show:setDisplayFrame(tempFrame)
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" and cell then
            if index == 0 then
                -- 最牛玩家
                function shopOpenResponseMethod(tag,gameData)
                    game_scene:enterGameUi("game_topplayer_scene",{gameData = gameData})
                end
                network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("playerboss_index"), http_request_method.GET, {},"playerboss_index")
            elseif index == 1 then
                -- local text = string_config:getTextByKey("game_challange_active1")
                game_util:addMoveTips({text = "Kho báu Roger tháng 7 chưa mở"})   
            elseif index == 2 then
                local text = string_config:getTextByKey("game_challange_active2")
                game_util:addMoveTips({text = "Cứ điểm bảo vệ tháng 7 chưa mở"})   
            end
        end
    end
    return TableViewHelper:create(params)
end


--[[--
    刷新ui
]]
function game_challange_pop.refreshUi(self)
    self.m_node_listbg:removeAllChildrenWithCleanup(true)
    local view = self:createChallangeList(self.m_node_listbg:getContentSize())
    self.m_node_listbg:addChild(view)
end
--[[--
    初始化
]]
function game_challange_pop.init(self,t_params)
    t_params = t_params or {}
end
--[[--
    創建ui入口並初始化數據
]]
function game_challange_pop.create(self,t_params)
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_challange_pop
