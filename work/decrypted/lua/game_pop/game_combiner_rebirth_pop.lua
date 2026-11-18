--- game_combiner_rebirth_pop信息  重生提示

local game_combiner_rebirth_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
   
    m_tParams = nil,
    m_text_label = nil,
    m_func_btn_1 = nil,
    m_func_btn_2 = nil,
    hero_icon_node = nil,
    m_btn_1 = nil,
    m_btn_2 = nil,
    m_close_btn = nil,
    show_node_btn = nil,
    show_node_label = nil,
    selNum = nil,
};

--[[--
    销毁
]]
function game_combiner_rebirth_pop.destroy(self)
    -- body
    cclog("-----------------game_combiner_rebirth_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    
    self.m_tParams = nil;
    self.m_text_label = nil;
    self.m_func_btn_1 = nil;
    self.m_func_btn_2 = nil;
    self.hero_icon_node = nil;
    self.m_btn_1 = nil;
    self.m_btn_2 = nil;
    self.m_close_btn = nil;
    self.show_node_btn = nil;
    self.show_node_label = nil;
    self.selNum = nil;
end
--[[--
    返回
]]


function game_combiner_rebirth_pop.back(self,type)
    game_scene:removePopByName("game_combiner_rebirth_pop");
    if self.btnCallFunc then
        self.btnCallFunc()
    end
    
end
--[[--
    读取ccbi创建ui
]]
function game_combiner_rebirth_pop.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/new_main_add_res.plist")
    local ccbNode = luaCCBNode:create();

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 11 then  --重生
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                local dataTable = json.decode(data:getFormatBuffer()) or {};
                game_data:setOneCombinerData(dataTable.beast_info,self.selNum);--设置神兽数据
                local reward = json.decode(data:getNodeWithKey("reward"):getFormatBuffer());
                game_util:closeAlertView();
                self:back();
                game_util:addMoveTips({text = "Tái sinh thành công!"});
                
                --延时回调奖励弹出
                local function jumpout()
                    game_util:rewardTipsByDataTable(reward);
                end
                local funcNode=CCNode:create();
                game_scene:getPopContainer():addChild(funcNode);
                performWithDelay(funcNode,jumpout,1.0);
                
            end

            --确认框
            local t_params=
            {
            title=string_config.m_title_prompt,
            okBtnCallBack=function(target,event)
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("combiner_rebirth"), http_request_method.GET, {beast = self.selNum},"combiner_rebirth")
            end,
            okBtnText=string_config.m_btn_sure,
            cancelBtnText=string_config.m_btn_cancel,
            text="Sau khi tái sinh, Thần thú sẽ được đưa về trạng thái ban đầu. Bạn có chắc muốn tái sinh không?", -- 重生后神兽将恢复为最初的状态，确定重生吗？
            onlyOneBtn=false,
            touchPriority=GLOBAL_TOUCH_PRIORITY-13,

            }
            game_util:openAlertView(t_params);

      
           -- if game_data:getItemCountByCid("3013") > 0 then  --重生所需材料
               -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("combiner_rebirth"), http_request_method.GET, {beast = self.selNum},"combiner_rebirth")
            -- else
            --     local t_params = 
            --     {
            --         title = string_config.m_title_prompt,
            --         okBtnCallBack = function(target,event)
            --             network.sendHttpRequest(responseMethod,game_url.getUrlForKey("combiner_rebirth"), http_request_method.GET, {beast = self.selNum},"combiner_rebirth")
            --         end,   --可缺省
            --         okBtnText = string_config.m_btn_sure,       --可缺省
            --         cancelBtnText = string_config.m_btn_cancel,
            --         text = "当前拥有宠物重生石不足，是否花费50钻石重生该宠物？",      --可缺省
            --         onlyOneBtn = false,
            --         touchPriority = GLOBAL_TOUCH_PRIORITY-13,
            --     }
            --     game_util:openAlertView(t_params)
            --end
        elseif btnTag == 12 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_wanning_pop.ccbi");
    
    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.m_text_label = ccbNode:labelTTFForName("m_text_label");
    self.m_text_label:setDimensions(CCSizeMake(172,130));
    self.m_text_label:setPosition(ccp(233,134));
    self.m_func_btn_1 = ccbNode:controlButtonForName("m_func_btn_1");
    self.m_func_btn_2 = ccbNode:controlButtonForName("m_func_btn_2");
    self.hero_icon_node = ccbNode:nodeForName("hero_icon_node");
    self.m_btn_1 = ccbNode:controlButtonForName("m_btn_1");
    self.m_btn_2 = ccbNode:controlButtonForName("m_btn_2");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.show_node_btn = ccbNode:nodeForName("show_node_btn");
    self.show_node_label = ccbNode:nodeForName("show_node_label");
    local ext_label = ccbNode:labelTTFForName("ext_label");
    ext_label:setVisible(false);

    self.m_func_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_func_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);

    game_util:setCCControlButtonTitle(self.m_btn_1,"Tái sinh");
    self.m_func_btn_1:setVisible(false);
    self.m_func_btn_2:setVisible(false);

 


    --创建神兽动画
    self.hero_icon_node:removeAllChildrenWithCleanup(true);
    local animNode=self:createCardAnim(self.selNum);
    self.hero_icon_node:addChild(animNode,10,10);

    --获取重生说明配置
    local activeCfg = getConfig(game_config_field.notice_active);
    local itemCfg = activeCfg:getNodeWithKey( "180" ); --说明配置
    local contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or "Tái sinh Thần thú, hoàn trả tài nguyên như sau：\n1.Hoàn trả 80% Tuyệt Trần Tuyết Tinh đã tiêu hao.\n2.Hoàn trả toàn bộ thẻ nguyên liệu đã dùng để tiến cấp.\n3.Hoàn trả 80% thẻ nguyên liệu đã dùng để nâng cấp, dưới dạng thẻ nguyên liệu Thần thú."
    self.m_text_label:setString(contentText);

    -- local count = game_data:getItemCountByCid("3013")
    -- ext_label:setString("宠物重生石" .. count .. "块")

    local function onTouch( eventType,x,y )
        -- body
        if(eventType == "began")then
            return true;
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    self.m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--创建神兽动画
function game_combiner_rebirth_pop.createCardAnim(self,num)

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
            animNode:setAnchorPoint(ccp(0.5,0.5));
        end
    end
    return animNode;
end


--[[--
    刷新ui
]]
function game_combiner_rebirth_pop.refreshUi(self)

end

--[[--
    初始化
]]
function game_combiner_rebirth_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_tParams = t_params;
    self.selNum = t_params.selNum;
    self.btnCallFunc = t_params.btnCallFunc;
end

--[[--
    创建ui入口并初始化数据
]]
function game_combiner_rebirth_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_combiner_rebirth_pop;