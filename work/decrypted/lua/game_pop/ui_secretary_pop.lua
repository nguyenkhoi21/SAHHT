--- 活動

local ui_secretary_pop = {
    m_root_layer = nil,


    m_rlabel_showlevelinfo = nil,
};

local infos = {}
infos[1] = "Tăng năng lực đồng đội có thể tăng Lực chiến hữu hiệu"
infos[2] = "Có trang bị mạnh sẽ có thực lực mạnh"
infos[3] = "Thực lực của anh hùng là phần không thể lơ là"
infos[4] = "Cố gắng tham gia nhiều hoạt động nhận thêm tài nguyên"
infos[5] = "Chú trọng tiểu tiết mới có thể đi lên đỉnh thế giới"

--[[--
    銷毀ui
]]
function ui_secretary_pop.destroy(self)
    -- body
    cclog("-----------------ui_secretary_pop destroy-----------------");
    self.m_root_layer = nil;

    self.m_rlabel_showlevelinfo = nil;
end
--[[--
    返回
]]
function ui_secretary_pop.back(self,backType)
    game_scene:removePopByName("ui_secretary_pop");
end
--[[--
    讀取ccbi創建ui
]]
function ui_secretary_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("click btn tag === ", btnTag)
        if btnTag == 1 then
            self:back();
        elseif btnTag == 10 then  -- 去戰鬥
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("map_world_scene",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
        elseif btnTag == 101 then
            -- 夥伴詳情
            game_scene:addPop("ui_secretary_detaile", {showtype = "huoban"})
            self:back()
        elseif btnTag == 102 then
            -- 裝備
            game_scene:addPop("ui_secretary_detaile", {showtype = "equip"})
            self:back()
        elseif btnTag == 103 then
            -- 英雄
            game_scene:addPop("ui_secretary_detaile", {showtype = "hero"})
            self:back()
        elseif btnTag == 104 then
            -- 活動
                local chapterID_index = {}
                local function responseMethod(tag,gameData)
                    game_scene:addPop("ui_secretary_detaile", {showtype = "active", activeData = gameData})                   
                    self:back()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
        elseif btnTag == 105 then
            -- 鑽石商城
            game_scene:addPop("ui_secretary_detaile", {showtype = "shop"})
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_secretary_main.ccbi");

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    game_util:setControlButtonTitleBMFont(self.m_close_btn)
    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);

    self.m_conbtn_gotos = {}
    for i=1,5 do
        local btn = ccbNode:controlButtonForName("m_conbtn_goto" .. i)
        assert(btn)
        btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
        game_util:setControlButtonTitleBMFont(btn)
    end
    
    -- 信息
    for i=1,5 do
        local node = ccbNode:nodeForName("m_node_lableinfo" .. i)
        assert(node)
        local rlabel = game_util:createRichLabelTTF({text = infos[i],dimensions = CCSizeMake(node:getContentSize().width, 0),
            textAlignment = kCCTextAlignmentCenter,verticalTextAlignment = nil,fontSize = 12, color = ccc3(253, 249, 204)})
        -- rlabel:setAnchorPoint( node:getAnchorPoint() )
        rlabel:setPositionX( node:getContentSize().width * 0.5 )
        rlabel:setPositionY( node:getContentSize().height * 0.5 )
        node:addChild(rlabel)
        -- self.m_labelInfo[i] = ccbNode:labelTTFForName("m_label_infoicon" .. i)
        -- self.m_labelInfo[i] = rlabel
    end


    local m_node_showh = ccbNode:nodeForName("m_node_showh")
    local selfHalf = game_util:createOwnBigImgHalf()
    selfHalf:setAnchorPoint(ccp(0, 0))
    local scale = m_node_showh:getContentSize().width / selfHalf:getContentSize().width
    selfHalf:setScale(scale)
    m_node_showh:addChild(selfHalf, 10)
    m_node_showh:getParent():reorderChild(m_node_showh, 11)

    -- local m_sprite_showpeople = ccbNode:spriteForName("m_sprite_showpeople")
    -- m_sprite_showpeople:addChild(selfHalf, 10)
    -- m_sprite_showpeople:getParent():reorderChild(m_sprite_showpeople, 11)

    local m_conbtn_getReward = ccbNode:controlButtonForName("m_conbtn_getReward")
    m_conbtn_getReward:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    game_util:setControlButtonTitleBMFont(m_conbtn_getReward)
    m_conbtn_getReward:setOpacity(0)





    local showInfo = "Đạt cấp 20 có thể tham gia Thử Thách Sinh Tồn!"
    local level = game_data:getUserStatusDataByKey("level")
    local role_cfg = getConfig(game_config_field.role)
    local levelCfg = role_cfg:getNodeWithKey(tostring(level))
    -- print("levelCfg  === ", levelCfg:getFormatBuffer())
    -- local h = levelCfg:getNodeWithKey("helper")
    -- print(" levelCfg helper == ", h:getFormatBuffer(), "end")
    local x = json.decode(levelCfg:getFormatBuffer())
    -- print("helper  ===  ", x.helper)
    local helperInfo = self:getTableByStringAndKey(x.helper, ",")
    -- print("helperInfo  ==== ", json.encode(helperInfo))
    if #helperInfo >= 1 then 
        local index =  math.random(1, #helperInfo)
        showInfo = helperInfo[index] or showInfo
    end





    local m_label_showlevelinfo = ccbNode:labelTTFForName("m_label_showlevelinfo")
    m_label_showlevelinfo:setVisible(false)
    local rlabel = game_util:createRichLabelTTF({text = showInfo,dimensions = CCSizeMake(m_label_showlevelinfo:getContentSize().width, 0),
        textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = nil,fontSize = 12, color = ccc3(250, 250, 190)})
    rlabel:setAnchorPoint( m_label_showlevelinfo:getAnchorPoint() )
    rlabel:setPositionX( m_label_showlevelinfo:getPositionX() )
    rlabel:setPositionY( m_label_showlevelinfo:getPositionY() )
    m_label_showlevelinfo:getParent():addChild(rlabel)
    -- self.m_labelInfo[i] = ccbNode:labelTTFForName("m_label_infoicon" .. i)
    -- self.m_labelInfo[i] = rlabel
    self.m_rlabel_showlevelinfo = rlabel
    return ccbNode;
end


--[[--
    刷新ui
]]
function ui_secretary_pop.refreshUi(self)
    -- self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    -- local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize());
    -- self.m_list_view_bg:addChild(tableViewTemp);
end
--[[--
    初始化
]]
function ui_secretary_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
end

--[[--
    創建ui入口並初始化數據
]]
function ui_secretary_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

function ui_secretary_pop.getTableByStringAndKey( self, str, key )
    if not str or type(str) ~= "string" then return {} end
    local tstr = {}
    local pos = 1
    local index = 1
    for i=1,10 do
        local ps, pe = string.find(str, key, pos)
        -- print("get ", ps, pe)
        if not ps then print("not found") break end
        tstr[i] = string.sub(str,pos,ps-1)
        index = i + 1
        pos = pe + 1
    end
    -- print("pos == ",pos, " len == ", string.len(str))
    tstr[index] = string.sub(str,pos,string.len(str))

    -- for i,v in ipairs(tstr) do
    --     -- print("got == ", i,v)
    -- end
    return tstr
end

return ui_secretary_pop;