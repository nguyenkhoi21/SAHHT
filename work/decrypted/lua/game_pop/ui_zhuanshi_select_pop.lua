---  弹框选择
local ui_zhuanshi_select_pop = {
    m_list_view_bg = nil,
    m_back_btn = nil,
    m_popUi = nil,
    m_select_list_node = nil,
    m_sel_id = nil,
    m_zhuanshi_list = nil,
    m_character_detail = nil,
};
--[[--
    销毁
]]
function ui_zhuanshi_select_pop:destroy()
    cclog("-----------------ui_zhuanshi_select_pop destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_back_btn = nil;
    self.m_popUi = nil;

    self.m_select_list_node = nil;
    self.m_sel_id = nil;
    self.m_zhuanshi_list = nil;
    self.m_character_detail = nil;
end
 
--[[--
    返回
]]
function ui_zhuanshi_select_pop:back(type)
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_hero_zhuanshi",{gameData = nil,dispatch_data = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("offline_dispatch_index"), http_request_method.GET, nil,"offline_dispatch_index")
end
--[[--
    读取ccbi创建ui
]]
function ui_zhuanshi_select_pop:createUi()
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_zhuanshi_sel_pop.ccbi");
    self.m_select_list_node = ccbNode:nodeForName("m_select_list_node")
    self.m_back_btn = ccbNode:controlButtonForName("m_close_btn")
	self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4)
    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end


--[[--
    离线派遣
]]
function ui_zhuanshi_select_pop:createTableView(viewSize)
    local imgSelectTab = self.m_zhuanshi_list
    local count = #imgSelectTab

    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = (count < 3 and count or 3); --列
    params.totalItem = #imgSelectTab;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_hero_zhuanshi_sel_item.ccbi")
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_name_lb = ccbNode:labelTTFForName("m_name_lb")
            local m_anim_node = ccbNode:nodeForName("m_anim_node")
            local cardCfg = self.m_character_detail:getNodeWithKey(tostring(imgSelectTab[index+1]))
            m_name_lb:setString(cardCfg:getNodeWithKey("name"):toStr())
            local animName = cardCfg:getNodeWithKey("animation"):toStr()
            local anim = game_util:createIdelAnim(animName)
            if anim then
                anim:setAnchorPoint(ccp(0.5,0))
                anim:setScale(0.9)
                local function onAnimSectionEnd( animNode, theId,theLabelName )
                     animNode:playSection(theLabelName);
                end
                local anim_eff = game_util:createEffectAnim("zhujue_daiji",1,true);
                anim_eff:setAnchorPoint(ccp(0.5,0))
                anim_eff:setPositionY(-65)
                anim_eff:registerScriptTapHandler(onAnimSectionEnd)
                anim_eff:playSection("impact");
                m_anim_node:addChild(anim_eff,1,1)
                m_anim_node:addChild(anim,2,2)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local id = imgSelectTab[index+1]
            local cardCfg = self.m_character_detail:getNodeWithKey(tostring(id))
            game_scene:enterUi("game_hero_zhuanshi_scene",{selId = self.m_sel_id,c_id = id,cardCfg = cardCfg})
        end
    end

    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function ui_zhuanshi_select_pop:refreshUi()
    local tempList = self:createTableView(self.m_select_list_node:getContentSize())
    self.m_select_list_node:removeAllChildrenWithCleanup(true)
    if tempList then
        self.m_select_list_node:addChild(tempList)
    end
end


--[[--
    初始化
]]
function ui_zhuanshi_select_pop:init(t_params)
    t_params = t_params or {};
    self.m_sel_id = t_params.id
    if not self.m_sel_id then
        game_util:addMoveTips({text = "卡牌请选择卡牌"})
        return
    end
    local cardData,cardCfg = game_data:getCardDataById(self.m_sel_id)
    local afterLifeCfg = getConfig(game_config_field.afterlife)
    local selData = json.decode(afterLifeCfg:getNodeWithKey(cardData.c_id):getFormatBuffer())
    self.m_zhuanshi_list = selData.afterlife_id or {}
    self.m_character_detail = getConfig(game_config_field.character_detail)
end

--[[--
    创建ui入口并初始化数据
]]
function ui_zhuanshi_select_pop:create(t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return ui_zhuanshi_select_pop;