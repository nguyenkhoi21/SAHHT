local game_expedition_select_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_listView_node = nil,
    m_current_index = nil,
    m_select_index = nil,
    m_real_index = nil,
    m_openType = nil,
    content_node = nil, 
    text_scroll = nil,
    m_openMsg = nil,
    m_des_lab = nil,
};
--[[--
    销毁
]]
function game_expedition_select_pop.destroy(self)
    -- body
    cclog("-----------------game_expedition_select_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_listView_node = nil;
    self.m_current_index = nil;
    self.m_select_index = nil;
    self.m_real_index = nil;
    self.m_openType = nil;
    self.content_node = nil;
    self.text_scroll = nil;
    self.m_openMsg = nil;
    self.m_des_lab = nil;
end
--[[--
    返回
]]
function game_expedition_select_pop.back(self,btnTag)
    if btnTag then
        local function responseMethod( tag,gameData )
            game_scene:enterGameUi("game_expedition_main",{gameData = gameData,selectIndex = btnTag});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("nightmare_tower_index"), http_request_method.GET, nil,"nightmare_tower_index")
    else
        game_scene:removePopByName("game_expedition_select_pop");
    end
end
--[[--
    读取ccbi创建ui
]]
function game_expedition_select_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_expedition_select_pop.ccbi");

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
    self.m_des_lab = ccbNode:labelTTFForName("m_des_lab")
    self.m_listView_node = ccbNode:layerForName("m_listView_node")
    self.m_top_sp = ccbNode:spriteForName("m_top_sp")


    self.content_node = ccbNode:nodeForName("content_node")
    local detail_label = ccbNode:labelTTFForName("detail_label")
    detail_label:setVisible(false)

    self.text_scroll = ccbNode:scrollViewForName("text_scroll")
    self.text_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY)


    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 1,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--
	创建列表
]]
function game_expedition_select_pop.createTableView( self,viewSize )
    local spriteTab = {}
	local function onBtnClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
		local btnTag = tagNode:getTag();
        if btnTag <= self.m_real_index then
            local imgFile = ""
            self.m_select_index = btnTag
            for i=1,20 do
                if i == btnTag then 
                    imgFile = "expedition_selectBg1.png"
                elseif i < self.m_real_index then
                    imgFile = "expedition_selecetBg2.png"
                else
                    imgFile = "expedition_noAttackBg.png"
                end
                spriteTab[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(imgFile));
            end
            self:back(btnTag)
        end
	end
	local totalItem = 20
	local params = {};
	local viewSize = viewSize
	params.viewSize = viewSize;
	params.row = 4;--行
	params.column = 5; --列
	params.totalItem = totalItem;
	params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
	params.direction = kCCScrollViewDirectionVertical
	local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
	self.m_cellSize = itemSize
	params.newCell = function(tableView,index) 
	    local cell = tableView:dequeueCell()
	    if cell == nil then
	        cell = CCTableViewCell:new()
	        cell:autorelease()
	        local ccbNode = luaCCBNode:create();
    		ccbNode:registerFunctionWithFuncName("onBtnClick",onBtnClick);--bind button on click event
	        ccbNode:openCCBFile("ccb/ui_expedition_select_item.ccbi")
	        ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
	        cell:addChild(ccbNode,10,10);
	    end
	    if cell then
    	  	local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_sel_img = ccbNode:spriteForName("m_sel_img")
            local m_select_sp = ccbNode:spriteForName("m_select_sp")
    	  	local m_select_lab = ccbNode:labelTTFForName("m_select_lab")
            local m_select_btn = ccbNode:controlButtonForName("m_select_btn")
            m_sel_img:setScale(0.8)
    	  	m_select_lab:setString("Tầng" .. index+1)
            m_select_btn:setTag(index+1)
            m_select_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-5)
    	  	local imgFile = ""

    	  	if index + 1 < self.m_real_index then
    	  		imgFile = "expedition_selecetBg2.png"
                m_sel_img:setVisible(true)
    	  	elseif index + 1 == self.m_real_index then
                imgFile = "expedition_selecetBg2.png"
                m_sel_img:setVisible(false)
            else
                m_sel_img:setVisible(false)
    	  		imgFile = "expedition_noAttackBg.png"
    	  	end
            if index + 1 == self.m_current_index then 
                imgFile = "expedition_selectBg1.png"
            end
    	  	m_select_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(imgFile));
            spriteTab[index+1] = m_select_sp
    	end
	    return cell;
	end
	return TableViewHelper:create(params);
end
--[[
    内容列表
]]
function game_expedition_select_pop.createContentTable(self,viewSize)
    local contentText = "";
    if self.m_openMsg then
        contentText = self.m_openMsg
    end
    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(282,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    self.text_scroll:setContentSize(CCSizeMake(210,tempSize.height))
    self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.text_scroll:addChild(tempLabel)
end
--[[--
    刷新ui
]]
function game_expedition_select_pop.refreshUi(self)
    if self.m_openType == "des" then
        self:createContentTable(self.content_node:getContentSize())
        self.m_des_lab:setVisible(false)
        self.m_top_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("expedition_ruleDes.png"));
    else
        self.m_des_lab:setVisible(true)
        self.m_listView_node:removeAllChildrenWithCleanup(true)
        local viewSize = self.m_listView_node:getContentSize()
        self.m_listView_node:addChild(self:createTableView(viewSize),10)
    end

end
--[[--
    初始化
]]
function game_expedition_select_pop.init(self,t_params)
    local t_params = t_params or {};
    self.m_current_index = t_params.currentIndex
    self.m_real_index = t_params.realIndex
    self.m_openType = t_params.openType
    self.m_openMsg = t_params.msg or nil
end
--[[--
    创建ui入口并初始化数据
]]
function game_expedition_select_pop.create(self,t_params)
    self:init(t_params);
    local m_popUi = self:createUi();
    self:refreshUi();
    return  m_popUi;
end
return game_expedition_select_pop;