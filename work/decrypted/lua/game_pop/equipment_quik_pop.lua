
-- 装备合成  一键进阶 new

local equipment_quik_pop = {
    m_popUi = nil,
    -- medal_tabel_view = nil,
    -- m_node = nil,
    m_close_btn = nil,
    m_metal_total_label = nil,
    gameData = nil,
    -- scrollView_tabel = nil,
    material_id = nil,
    material_type = nil,
    medal_icon1 = nil,
    medal_icon2 = nil,
    medal_icon3 = nil,
    back_groove = nil,
    m_materialDataTable = nil,
    m_btn2 = nil,
    Ex_targetId = nil,
    Ex1_targetId = nil,
    no_full_line = nil,
    full_line = nil,
    m_material_node_tab = nil,
    m_sel_btn2 = nil,
    daoju_need = nil,
    daoju_total = nil,
    daoju_num = nil,
    material_num = nil,
};
--[[--
    销毁ui
]]
function equipment_quik_pop.destroy(self)
    -- body
    cclog("-----------------equipment_quik_pop destroy-----------------");
    self.m_popUi = nil;
    -- self.medal_tabel_view = nil;
    self.m_node = nil;
    self.m_close_btn = nil;
    self.m_metal_total_label = nil;
    self.gameData = nil;
    -- self.scrollView_tabel = nil;
    self.material_id = nil;
    self.material_type = nil;
    self.medal_icon1 = nil;
    self.medal_icon2 = nil;
    self.medal_icon3 = nil;
    self.back_groove = nil;
    self.m_materialDataTable = nil;
    self.m_btn2 = nil;
    self.Ex_targetId = nil;
    self.Ex1_targetId = nil;
    self.no_full_line = nil;
    self.no_full_line = nil;
    self.m_material_node_tab = nil;
    self.m_sel_btn2 = nil;
    self.daoju_need = nil;
    self.daoju_total = nil;
    self.daoju_num = nil;
    self.material_num = nil;
end

--[[--
    返回
]]
function equipment_quik_pop.back(self,type)
    if type == "back" then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("equip_evolution",{selEquipId = self.selected_id},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui
]]
function equipment_quik_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 12 then--合成
            self:onSureFunc();
            -- cclog2("12121212121212")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_equipment_quik_pop.ccbi");
    -- self.medal_tabel_view = ccbNode:scrollViewForName("medal_tabel_view")
    -- self.m_node = ccbNode:nodeForName("m_node");
    -- self.m_node:setPosition(ccp(340.4,165))
    -- self.medal_tabel_view:setVisible(true)
    self.m_close_btn  = ccbNode:controlButtonForName("m_close_btn");
    self.m_btn2 = ccbNode:controlButtonForName("m_btn2");
    self.m_metal_total_label = ccbNode:labelBMFontForName("m_metal_total_label");
    -- self.scrollView_tabel = ccbNode:nodeForName("scrollView_tabel")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11);
    self.medal_icon1 = ccbNode:nodeForName("medal_node1")
    self.medal_icon2 = ccbNode:nodeForName("medal_node2")
    self.medal_icon3 = ccbNode:nodeForName("medal_node3")
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.mateial_node = ccbNode:nodeForName("mateial_node")
    self.back_groove = ccbNode:scale9SpriteForName("back_groove")
    self.back_groove:setVisible(false)
    local touchLayer = CCLayer:create()
    local function onTouch( eventType,x,y )
        if(eventType == "began")then
            return true;
        end
    end

    self.full_line = 0
    self.no_full_line = 0

    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
   
    -- self.scrollView_tabel
    self.m_root_layer:setTouchEnabled(true);
    self.m_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    -- self.scrollView_tabel:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    -- local touchLayer = CCLayer:create()
    -- self.m_root_layer:addChild(touchLayer)
    -- touchLayer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-9,true);
    -- touchLayer:setTouchEnabled(true);
    return ccbNode;
end

--[[--

]]
function equipment_quik_pop.onSureFunc(self)
    local visibleFlag = game_data:isViewShowByID(170)
    if self.daoju_need ~= 0 and self.daoju_num == 0 and visibleFlag then
        local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            local params = {}
                            params.is_buy = 1
                            params.equip_id = game_data:getEquipCountByCid2(self.material_id-1 , self.m_selEquipId)
                            cclog2(params,"params = = =")
                            game_util:closeAlertView();
                            local function responseMethod(tag,gameData)
                                if gameData == nil then
                                    self.m_root_layer:setTouchEnabled(false);
                                    return;
                                end
                                self:responseSuccess();
                            end
                            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_evolution"), http_request_method.GET, params,"equip_evolution",true,true)
                        end,   --可缺省
                        okBtnText = string_config.m_btn_sure,       --可缺省
                        cancelBtnText = string_config.m_btn_cancel,
                        text =  "Tốn " .. self.daoju_total .. " Xu thêm đủ đạo cụ？",      --可缺省
                        onlyOneBtn = false,
                        touchPriority = GLOBAL_TOUCH_PRIORITY-12,
                    }
        game_util:openAlertView(t_params)
        -- self:refreshUi();
        return;
    elseif self.no_full_line ~= 0 then
        game_util:addMoveTips({text = "Không đủ tài nguyên!"});
        return;
    end
    --判断是否洗练，若材料是洗练过的，则提示一下
    local requestCode = 0;
    local function sendRequest()
        local function responseMethod(tag,gameData)
            if gameData == nil then
                self.m_root_layer:setTouchEnabled(false);
                return;
            end
            self:responseSuccess();
        end
        --equip_id = 
        local params = {};
        -- params.equip_id = self.material_id-1;
        params.equip_id = game_data:getEquipCountByCid2(self.material_id-1 , self.m_selEquipId)
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_evolution"), http_request_method.GET, params,"equip_evolution",true,true)
    end
    sendRequest();
    -- self:refreshUi();
end


--[[--
    
]]
function equipment_quik_pop.responseSuccess(self)
    local function responseEndFunc()
        self.m_root_layer:setTouchEnabled(false);
        game_sound:playUiSound("up_over")
        self:refreshUi();
        game_util:addMoveTips({text = "Đã tiến hóa trang bị！"});
        if self.Ex1_targetId and self.Ex_targetId then 
            local equipData = {lv = 1,c_id = self.Ex1_targetId,id = -1,pos = -1}
            game_scene:addPop("equipment_quik_pop",{tGameData = equipData,Ex_targetId = self.Ex_targetId, selected_id = self.selected_id});
        elseif self.Ex_targetId and self.material_id then 
            local equipData = {lv = 1,c_id = self.Ex_targetId,id = -1,pos = -1}
            game_scene:addPop("equipment_quik_pop",{tGameData = equipData, selected_id = self.selected_id});
        else
            game_scene:enterGameUi("equip_evolution",{selEquipId = self.selected_id});
        end
    end
    local rempveIndex = game_util:getTableLen(self.m_materialDataTable);
    local materialCount = rempveIndex;
    local animFile = "anim_icon_disappear"
    local function particleMoveEndCallFunc()
        cclog("tempParticle particleMoveEndCallFunc --------------------------")
    end
    for i=1,4 do
        -- local m_material_node = self.m_material_node_tab[i];
        if self.m_materialDataTable[i] then 
            local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
            if mAnimNode then
                local function onAnimSectionEnd(animNode, theId,theLabelName)
                    if theLabelName == "impact1" then
                        animNode:playSection("impact2");
                        local tempNode = self.m_material_node_tab[i]:getChildByTag(10)
                        if tempNode then
                            tempNode:setVisible(false);
                        end
                    else
                        mAnimNode:removeFromParentAndCleanup(true);
                        rempveIndex = rempveIndex - 1;
                        if rempveIndex == 0 then
                            responseEndFunc();
                            -- self.m_ccbNode:runAnimations("success_anim")
                        end
                    end
                end
                mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
                mAnimNode:playSection("impact1");
                local tempSize = self.m_material_node_tab[i]:getContentSize();
                mAnimNode:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                self.m_material_node_tab[i]:addChild(mAnimNode,100,100);
                local tempParticle = game_util:createParticleSystemQuad({fileName = "particle_fly_up"});
                if tempParticle then
                    -- local px , py = self.mateial_node:getContentSize();
                    game_util:addMoveAndRemoveAction({node = tempParticle,startNode = self.m_material_node_tab[i],endNode = self.m_sel_btn2,endCallFunc = particleMoveEndCallFunc,moveTime = 0.5,delayTime = 0.5})
                    game_scene:getPopContainer():addChild(tempParticle)
                end
            else
                responseEndFunc();
            end
        else

        end
    end
end


--[[--
    创建装备列表
]]
function equipment_quik_pop.createEquipTableView(self,viewSize,tableData)
    self.m_selListItem = nil;
    local itemsCount = #tableData;   ---3
    local totalItem = math.max(itemsCount%4 == 0 and itemsCount or math.floor(itemsCount/4+1)*4,4)
    local equipCfg = getConfig(game_config_field.equip);
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = itemsCount--totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createEquipItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < itemsCount then
                local tempId = tableData[index+1]
                -- cclog2(tempId,"kasjdlkjfk;;")
                local itemData,itemCfg = game_data:getEquipDataById(tempId);
                game_util:setEquipItemInfoByTable2(ccbNode,itemData);
                if self.m_selEquipId and self.m_selEquipId == tempId then
                    local m_sel_img = ccbNode:spriteForName("m_sel_img")
                    m_sel_img:setVisible(true);
                    self.m_selListItem = cell;
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= itemsCount then return end;
        if eventType == "ended" and cell then
            local tempId = tableData[index+1]
            if self.m_selEquipId == nil or self.m_selEquipId ~= tempId then
                if self.m_selListItem then
                    local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                    local m_sel_img = ccbNode:spriteForName("m_sel_img")
                    m_sel_img:setVisible(false);
                end
                self.m_selListItem = cell;
                self.m_selEquipId = tostring(tempId)
                -- self:refreshEquipInfo(self.m_selEquipId);
                -- cclog2("yijing dianjile  zhuagnbei ")
                -- self:refreshTips();
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                m_sel_img:setVisible(true);
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
        -- self.m_selListItem = nil;
    end
    -- cclog2(params,"params  sjadfljalsjdfkl")
    return TableViewHelper:create(params);
end


--[[
    创建滚动的装备列表
]]
function equipment_quik_pop.refreshEquipTableView( self )
    -- self.scrollView_tabel:removeAllChildrenWithCleanup(true);
    self.m_selEquipDataTab = game_data:getEquipDataByQuality2(self.material_type, self.material_id);
    -- self.scrollView_tabel:addChild(self:createEquipTableView(self.scrollView_tabel:getContentSize(),self.m_selEquipDataTab));
end
--[[--
    刷新ui
]]
function equipment_quik_pop.refreshUi(self)
    self:createEquipInfo()
    self:createMaterialInfo()
    -- self:refreshEquipTableView()
end
--[[
    材料信息
]]
function equipment_quik_pop.createMaterialInfo(self)
    local temPx, temPy = self.mateial_node:getPosition();

    local basc_dx = 0

    local lineHeight = 0.45
    local tempSize = self.mateial_node:getContentSize()

    local itemCfg = getConfig(game_config_field.equip);    -- medalCfg
    local itemCfg_evolution = getConfig(game_config_field.equip_evolution);   ---  materialCfg
    local masterMaterialCfg = nil
    
    if self.material_id == nil then--取装备的
        masterMaterialCfg = itemCfg:getNodeWithKey(tostring(self.material_id))
    else--取材料的
        masterMaterialCfg = itemCfg_evolution:getNodeWithKey(tostring(self.material_id-1))
    end
    for i=1,3 do
        local tempCount = masterMaterialCfg:getNodeWithKey("equip_material_"..i) 
        if tempCount:getNodeCount() > 0 then
            self.material_num = self.material_num + 1;
            cclog2(masterMaterialCfg:getNodeWithKey("equip_material_"..i),"equip_material_equip_material_equip_material_")
        end
    end
    cclog2(self.material_num,"self.material_numself.material_numself.material_num")
    local temp_x = 0
    if self.material_num == 3 then
        temp_x = 25;
    end
    cclog2(temp_x,"+temp_x+temp_x+temp_x+temp_x+temp_x")
    -- local material_material = masterMaterialCfg:getNodeWithKey("material")
    --[[
        对icon的响应方法
    ]]
    local function onBtnCilckMain( event,target )--看主的
        cclog2("onBtnCilckMain")
    end
    --[[
        对材料里面第一个icon的相应方法
    ]]
    local function onBtnCilck1( event,target )
        local count1 = game_data:getEquipCountByCid(self.material_id-1)
        -- local need_count = item_material_cfg_temp:getNodeAt(2):toInt()
        local equip_material_item_cfg = masterMaterialCfg:getNodeWithKey("equip_material_1")
        local tempItemCfg = equip_material_item_cfg:getNodeAt(0);
        local materialId = tempItemCfg:getNodeAt(1):toInt();
        cclog2(count1,"count1count1count1count1wwwwwwwwwwwww")
        if self.material_id-1 == materialId and count == 1 then 
            count1 = 1
            cclog2(count1,"count1count1count1count1")
        end 
        if count1 < 0 or count1 == 0 then
            if ((self.material_id-1)%10) ~= 1 then
                if self.Ex_targetId then 
                    local equipData = {lv = 1,c_id = self.material_id-1,id = -1,pos = -1}
                    game_scene:addPop("equipment_quik_pop",{tGameData = equipData,Ex1_targetId = self.material_id,Ex_targetId = self.Ex_targetId, selected_id = self.selected_id});
                else
                    local equipData = {lv = 1,c_id = self.material_id-1,id = -1,pos = -1}
                    game_scene:addPop("equipment_quik_pop",{tGameData = equipData,Ex_targetId = self.material_id, selected_id = self.selected_id});
                end
            else
                -- game_util:addMoveTips({text = "本装备已是最低品质！"});
                local equipData = {lv = 1,c_id = self.material_id-1,id = -1,pos = -1}
                game_scene:addPop("game_equip_info_pop",{tGameData = equipData});

            end
        else
            game_util:addMoveTips({text = "Đã đủ trang bị này."});
        end
        -- end
    end
    --[[
        对icon的响应方法2
    ]]
    local function onBtnCilck( event,target )
        cclog2("onBtnCilck")
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
        local material_index = btnTag - 10
        local item_material = masterMaterialCfg:getNodeWithKey("equip_material_"..material_index)
        local item_material_cfg_temp = item_material:getNodeAt(0);
        local item_material_type = item_material_cfg_temp:getNodeAt(0):toInt();
        -- local item_material_type = item_material_cfg:getNodeAt(0):toInt();
        -- cclog2(item_material_type,"item_material_type == ")
        -- cclog2(item_material,"item_material == ")
        if item_material_type == 6 then
             game_scene:addPop("game_item_info_pop",{itemId = item_material_cfg_temp:getNodeAt(1):toInt(),openType = 2})
             -- cclog2("item_material_type == 6")
        else
            local count1 = game_data:getEquipCountByCid(item_material_cfg_temp:getNodeAt(1):toInt());
            local need_count = item_material_cfg_temp:getNodeAt(2):toInt()
            if self.material_id-1 == item_material_cfg_temp:getNodeAt(1):toInt() then 
                count1 = 0
            end
            if count1 < need_count then
                if (item_material_cfg_temp:getNodeAt(1):toInt()%10) ~= 1 then
                    if self.Ex_targetId then 
                        local equipData = {lv = 1,c_id = item_material_cfg_temp:getNodeAt(1):toInt(),id = -1,pos = -1}
                        game_scene:addPop("equipment_quik_pop",{tGameData = equipData,Ex1_targetId = self.material_id,Ex_targetId = self.Ex_targetId, selected_id = self.selected_id});
                    else
                        local equipData = {lv = 1,c_id = item_material_cfg_temp:getNodeAt(1):toInt(),id = -1,pos = -1}
                        game_scene:addPop("equipment_quik_pop",{tGameData = equipData,Ex_targetId = self.material_id, selected_id = self.selected_id});
                    end
                else
                    -- game_util:addMoveTips({text = "本装备已是最低品质！"});
                    local equipData = {lv = 1,c_id = item_material_cfg_temp:getNodeAt(1):toInt(),id = -1,pos = -1}
                    game_scene:addPop("game_equip_info_pop",{tGameData = equipData});

                end
            else
                game_util:addMoveTips({text = "Đã đủ trang bị này."});
            end
        end

    end
    --添加目标装备的icon和name
    local master_icon, master_icon_name = game_util:createEquipIconByCid(self.material_id)
    local master_icon_nameLab = game_util:createLabelTTF({text = master_icon_name,color = ccc3(255,255,255),fontSize = 10})
    -- master_icon_nameLab:setPosition(ccp(tempSize.width　* 0.5, tempSize.height * 0.5 -35))

    local dy = 16
    master_icon_nameLab:setPosition(ccp(tempSize.width * 0.5,tempSize.height * 0.5 + dy+20))
    master_icon:setPosition(ccp(tempSize.width * 0.5,tempSize.height * 0.5 + dy))
    master_icon:setScale(0.5);
    self:createTouchButton(onBtnCilckMain,master_icon,1)
    self.mateial_node:addChild(master_icon,100);
    self.mateial_node:addChild(master_icon_nameLab,100);
    self.m_sel_btn2 = master_icon
    -- 添加材料
    -- local equip_material_TB = {};
    local icon_basic = game_util:createEquipIconByCid(self.material_id-1);
    local count_basic = game_data:getEquipCountByCid(self.material_id-1);
    local m_mate_cost_label_basic = game_util:createLabelTTF({text = "",color = ccc3(255,255,255),fontSize = 8})
    local m_mate_total_label_basic = game_util:createLabelTTF({text = "",color = ccc3(255,255,255),fontSize = 8})
    local have_flag = false;
    local drawNode = ExtDrawNode:create(tempSize,0);
    local drawNode1 = ExtDrawNode:create(tempSize,0);
    drawNode:setPosition(ccp(0,0));
    drawNode1:setPosition(ccp(0,0));
    local equip_material_item_cfg_next = masterMaterialCfg:getNodeWithKey("equip_material_1")
    local tempItemCfg_next = equip_material_item_cfg_next:getNodeAt(0);
    local item_next_id = tempItemCfg_next:getNodeAt(1):toInt();
    local dy2 = 25
    self.full_line = 1;
    if 1 > count_basic then
        icon_basic:setColor(ccc3(151,151,151)); 
        self.m_status = 2;
        m_mate_cost_label_basic:setColor(ccc3(255, 0, 0))
        have_flag = false;
        self:drawLine(drawNode1,ccp(tempSize.width /( 2*self.material_num),tempSize.height*0.5 - dy2),ccp(tempSize.width /( 2*self.material_num),tempSize.height*0.5 - dy2+17),have_flag);
        self.mateial_node:addChild(drawNode)
        self.mateial_node:addChild(drawNode1)
        self.no_full_line = self.no_full_line + 1;
        self.daoju_num = self.daoju_num + 1;
    else
        m_mate_cost_label_basic:setColor(ccc3(255, 255, 255));
        have_flag = true;
        self:drawLine(drawNode1,ccp(tempSize.width /( 2*self.material_num),tempSize.height*0.5 - dy2),ccp(tempSize.width /( 2*self.material_num),tempSize.height*0.5 - dy2+17),have_flag);
        self.mateial_node:addChild(drawNode)
        self.mateial_node:addChild(drawNode1)
        count_basic = 1
    end
    m_mate_cost_label_basic:setString("1");
    m_mate_total_label_basic:setString(count_basic .."/");
    m_mate_cost_label_basic:setAnchorPoint(ccp(0,0.5))
    m_mate_total_label_basic:setAnchorPoint(ccp(1,0.5))
    self.m_materialDataTable[1] = {count = count_basic,materialId = self.material_id-1,materialType = 7};


    icon_basic:setPosition(ccp(tempSize.width /( 2*self.material_num),tempSize.height*0.5 - dy2));


    icon_basic:setScale(0.5)
    self.m_material_node_tab[1] = icon_basic
    -- ccp(icon_px+5, icon_py-15)
    m_mate_cost_label_basic:setPosition(ccp(tempSize.width /( 2*self.material_num),tempSize.height*0.5 - dy2-15))
    m_mate_total_label_basic:setPosition(ccp(tempSize.width /( 2*self.material_num),tempSize.height*0.5 - dy2-15))
    self.mateial_node:addChild(icon_basic,100)
    self.mateial_node:addChild(m_mate_cost_label_basic,100)
    self.mateial_node:addChild(m_mate_total_label_basic,100)
    self:createTouchButton(onBtnCilck1,icon_basic,(self.material_id-1)%10+10)  --对最上面的那个icon添加触摸事件
    local fast_material_cost = getConfig(game_config_field.fast_material_cost)
    local fast_material_cost_all = json.decode(fast_material_cost:getFormatBuffer()) or {}
    local i_index = 0
    for i=1,3 do
        
        local equip_material_item_cfg = masterMaterialCfg:getNodeWithKey("equip_material_" .. i)
        tempCount = equip_material_item_cfg:getNodeCount();
        if tempCount > 0 then
            local drawNode = ExtDrawNode:create(tempSize,0);
            drawNode:setPosition(ccp(0,0));
            self.mateial_node:addChild(drawNode);
            local drawNode1 = ExtDrawNode:create(tempSize,0);
            drawNode1:setPosition(ccp(0,0));
            self.mateial_node:addChild(drawNode1);
            local tempItemCfg = equip_material_item_cfg:getNodeAt(0);
            local materialType = tempItemCfg:getNodeAt(0):toInt();
            local materialId = tempItemCfg:getNodeAt(1):toStr();
            local materialId_num = tempItemCfg:getNodeAt(1):toInt();
            local costCount = tempItemCfg:getNodeAt(2):toInt();
            local count = 0;
            local icon = nil;
            if materialType == 6 then
                count = game_data:getItemCountByCid(materialId);
                icon = game_util:createItemIconByCid(materialId);
            else
                count = game_data:getEquipCountByCid(materialId,self.m_selEquipId);
                icon = game_util:createEquipIconByCid(materialId);
            end
            local m_mate_cost_label = game_util:createLabelTTF({text = "",color = ccc3(255,255,255),fontSize = 8})
            local m_mate_total_label = game_util:createLabelTTF({text = "",color = ccc3(255,255,255),fontSize = 8})

            if self.material_id-1 == materialId_num and count == 1 then 

                count = 0
            end 
            if costCount > count then
                self.m_status = 2;
                m_mate_cost_label:setColor(ccc3(255, 0, 0))
                if materialType == 6 then
                    self.daoju_need = self.daoju_need + 1
                    -- cclog2(table.getn(fast_material_cost_all),"fast_material_cost_alljfkljklj66666666666")
                    for k,v in pairs(fast_material_cost_all) do
                        local material_11 = v.material_1[1]
                        if material_11 then 
                            cclog2(material_11[2],"material_11[2]");
                            if material_11[2] == materialId_num then
                                self.daoju_total = (costCount-count)*v.cost + self.daoju_total
                                cclog2(self.daoju_total,"self.daoju_total ===")
                            end
                        end
                        -- if v.material_1[1][1] 
                    end
                    -- self.daoju_total = (costCount-count)*\
                else
                    self.daoju_num = self.daoju_num + 1;

                end
            else
                count = costCount
                m_mate_cost_label:setColor(ccc3(255, 255, 255));
            end
            m_mate_cost_label:setString(costCount);
            m_mate_total_label:setString(count.."/");
            self.m_materialDataTable[i+1] = {count = count,materialId = materialId,materialType = materialType};
            m_mate_cost_label:setAnchorPoint(ccp(0,0.5))
            m_mate_total_label:setAnchorPoint(ccp(1,0.5))
            self.mateial_node:addChild(m_mate_cost_label,100)
            self.mateial_node:addChild(m_mate_total_label,100)
            if icon then
                local tempSize = self.mateial_node:getContentSize();

                local icon_px = tempSize.width*(2*i+1) /( 2*self.material_num)
                local icon_py = tempSize.height*0.5-dy2
                icon:setPosition(ccp(icon_px , icon_py));

                i_index = i_index + 1;
                m_mate_cost_label:setPosition(ccp(icon_px, icon_py-15))
                m_mate_total_label:setPosition(ccp(icon_px, icon_py-15))
                icon:setScale(0.5)
                self:createTouchButton(onBtnCilck,icon,10 + i)
                self.mateial_node:addChild(icon,10,materialId);
                local have_fla = false;
                self.full_line = self.full_line + 1;
                if costCount > count then
                    self.no_full_line = self.no_full_line + 1;
                    icon:setColor(ccc3(151,151,151)); 
                    have_flag = false
                    self:drawLine(drawNode1,ccp(icon_px , icon_py),ccp(icon_px , icon_py+17),have_flag);
                else
                    have_flag = true
                    self:drawLine(drawNode1,ccp(icon_px , icon_py),ccp(icon_px , icon_py+17),have_flag);
                end
            self.m_material_node_tab[i+1] = icon
            end
        else
        end
        local totalMetal = game_data:getUserStatusDataByKey("metal") or 0
        game_util:setCostLable(self.m_metal_total_label,masterMaterialCfg:getNodeWithKey("metal"):toInt(),totalMetal);
        
    end
    --画主线
    if self.no_full_line ~= 0 then
        have_flag = false
        self:drawLine(drawNode,ccp(tempSize.width/( 2*self.material_num),tempSize.height*0.5-dy2+17),ccp(tempSize.width*(2*i_index+1) /( 2*self.material_num),tempSize.height*0.5-dy2+17),have_flag);       
        self:drawLine(drawNode,ccp(tempSize.width * 0.5,tempSize.height*0.5-dy2+17),ccp(tempSize.width * 0.5,tempSize.height * 0.5 + dy),have_flag);       
    else
        have_flag = true
        self:drawLine(drawNode,ccp(tempSize.width/( 2*self.material_num),tempSize.height*0.5-dy2+17),ccp(tempSize.width*(2*i_index+1) /( 2*self.material_num),tempSize.height*0.5-dy2+17),have_flag);       
        self:drawLine(drawNode,ccp(tempSize.width * 0.5,tempSize.height*0.5-dy2+17),ccp(tempSize.width * 0.5,tempSize.height * 0.5 + dy),have_flag);       
    end
end
--[[
    画线
]]
function equipment_quik_pop.drawLine(self,drawNode,startPos,endPos,flag)
    if flag then
        drawNode:drawLine(startPos, endPos, 2, ccc4f(255/255, 238/255, 0, 1));
    else
        drawNode:drawLine(startPos, endPos, 2, ccc4f(0.2,0.2,0.2,1));
    end
end
--[[--
    创建一个接受触摸事件的button
]]
function equipment_quik_pop.createTouchButton( self, fun, parent, tag , anchorX, anchorY)
    if not parent then return end
    local button = game_util:createCCControlButton("public_weapon.png","",fun)
    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
    local tempSize = parent:getContentSize()
    button:setAnchorPoint(ccp(0.5,0.5))
    button:setPosition(ccp(tempSize.width * (anchorX or 0.5), tempSize.height* (anchorY or 0.5)))
    button:setOpacity(0)
    parent:addChild(button,1,tag)
    button:setTag(tag)
end
--[[
    装备信息
]]
function equipment_quik_pop.createEquipInfo( self )
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog2("btnTag", btnTag)

        if btnTag == 1 then--刷新
            self.material_num = 1;
            self.mateial_node:removeAllChildrenWithCleanup(true);
            self:refreshUi()
        elseif btnTag == 2 then--本界面刷新
            self.mateial_node:removeAllChildrenWithCleanup(true);
            local equipData = {lv = 1,c_id = self.Ex_targetId,id = -1,pos = -1}
            game_scene:addPop("equipment_quik_pop",{tGameData = equipData, selected_id = self.selected_id});
        elseif btnTag == 3 then
            self.mateial_node:removeAllChildrenWithCleanup(true);
            local equipData = {lv = 1,c_id = self.Ex1_targetId,id = -1,pos = -1}
            game_scene:addPop("equipment_quik_pop",{tGameData = equipData,Ex_targetId = self.Ex_targetId, selected_id = self.selected_id});
        elseif btnTag == 4 then
            self.mateial_node:removeAllChildrenWithCleanup(true);
            local equipData = {lv = 1,c_id = self.Ex1_targetId,id = -1,pos = -1}
            game_scene:addPop("equipment_quik_pop",{tGameData = equipData,Ex_targetId = self.Ex_targetId, selected_id = self.selected_id});
        end
    end
    -- body
    if self.Ex_targetId and self.material_id and self.Ex1_targetId then
        --第一个icon
        local itemCfg1 = getConfig(game_config_field.equip):getNodeWithKey(tostring(self.Ex_targetId));
        local icon1 = game_util:createEquipIcon(itemCfg1)
        -- cclog2(self.Ex_targetId,"self.material_id  ~~~~")
        -- cclog2(itemCfg1,"itemCfg  ~~~~~  ")
        local iconSize1 = self.medal_icon1:getContentSize()
        icon1:setPosition(ccp(iconSize1.width*0.5, iconSize1.height*0.5))
        icon1:setScale(0.5)        
        self.medal_icon1:addChild(icon1,10,10)
        --第二个icon
        local itemCfg2 = getConfig(game_config_field.equip):getNodeWithKey(tostring(self.Ex1_targetId));
        local icon2 = game_util:createEquipIcon(itemCfg2)
        -- cclog2(self.Ex1_targetId,"self.material_id  ~~~~")
        -- cclog2(itemCfg2,"itemCfg  ~~~~~  ")
        local iconSize2 = self.medal_icon2:getContentSize()
        icon2:setPosition(ccp(iconSize2.width*0.5, iconSize2.height*0.5))
        icon2:setScale(0.5)        
        self.medal_icon2:addChild(icon2,10,10)
        --第三个icon
        local itemCfg = getConfig(game_config_field.equip):getNodeWithKey(tostring(self.material_id));
        local icon = game_util:createEquipIcon(itemCfg)
        -- cclog2(self.material_id,"self.material_id  ~~~~")
        -- cclog2(itemCfg,"itemCfg  ~~~~~  ")
        local iconSize = self.medal_icon3:getContentSize()
        icon:setPosition(ccp(iconSize.width*0.5, iconSize.height*0.5))
        icon:setScale(0.5)        
        self.medal_icon3:addChild(icon,10,10)
        --加小条条
        self.back_groove:setVisible(true)
        self.back_groove:setPreferredSize(CCSizeMake(12,70));
        self:createTouchButton(onBtnCilck,self.medal_icon1,3)
        self:createTouchButton(onBtnCilck,self.medal_icon2,4)
        self:createTouchButton(onBtnCilck,self.medal_icon3,1)
    elseif self.Ex_targetId and self.material_id then
        --第一个icon
        local itemCfg1 = getConfig(game_config_field.equip):getNodeWithKey(tostring(self.Ex_targetId));
        local icon1 = game_util:createEquipIcon(itemCfg1)
        -- cclog2(self.Ex_targetId,"self.material_id  ~~~~")
        -- cclog2(itemCfg1,"itemCfg  ~~~~~  ")
        local iconSize1 = self.medal_icon1:getContentSize()
        icon1:setPosition(ccp(iconSize1.width*0.5, iconSize1.height*0.5))
        icon1:setScale(0.5)        
        self.medal_icon1:addChild(icon1,10,10)
        --第二个icon
        local itemCfg = getConfig(game_config_field.equip):getNodeWithKey(tostring(self.material_id));
        local icon = game_util:createEquipIcon(itemCfg)
        -- cclog2(self.material_id,"self.material_id  ~~~~")
        -- cclog2(itemCfg,"itemCfg  ~~~~~  ")
        local iconSize = self.medal_icon1:getContentSize()
        icon:setPosition(ccp(iconSize.width*0.5, iconSize.height*0.5))
        icon:setScale(0.5)        
        self.medal_icon2:addChild(icon,10,10)
        --加小条条
        self.back_groove:setVisible(true)
        self.back_groove:setPreferredSize(CCSizeMake(12,35));
        self:createTouchButton(onBtnCilck,self.medal_icon1,2)
        self:createTouchButton(onBtnCilck,self.medal_icon2,1)
    elseif self.material_id then
        local itemCfg = getConfig(game_config_field.equip):getNodeWithKey(tostring(self.material_id));
        local icon = game_util:createEquipIcon(itemCfg)
        -- cclog2(self.material_id,"self.material_id  ~~~~")
        -- cclog2(itemCfg,"itemCfg  ~~~~~  ")
        local iconSize = self.medal_icon1:getContentSize()
        icon:setPosition(ccp(iconSize.width*0.5, iconSize.height*0.5))
        icon:setScale(0.5)        
        self.medal_icon1:addChild(icon,10,10)
        self:createTouchButton(onBtnCilck,self.medal_icon1,1)
    end
end

--[[--
    初始化
]]
function equipment_quik_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.Ex_targetId and t_params.Ex1_targetId then
        cclog2("enter too   sdjaflkjljsldkjfaksdf")
        self.Ex_targetId = t_params.Ex_targetId;
        self.Ex1_targetId = t_params.Ex1_targetId;
    elseif t_params.Ex_targetId then
        cclog2("enter too   sdjaflkjljsldkjfaksdf")
        self.Ex_targetId = t_params.Ex_targetId;
    end
    if t_params.selected_id then
        self.selected_id = t_params.selected_id
    end
    self.gameData = t_params.tGameData
    self.material_id = t_params.tGameData.c_id or nil
    self.equip_id = t_params.tGameData.id or nil
    local itemCfg = getConfig(game_config_field.equip)
    -- cclog2(itemCfg,"itemCfgitemCfgitemCfgitemCfgitemCfg=== = === ")
    local itemCfg_equip = itemCfg:getNodeWithKey(tostring(self.material_id))
    self.material_type = itemCfg_equip:getNodeWithKey("quality"):toInt();
    -- cclog2(self.material_type,"self.material_typeself.material_typeself.material_type=== = === ")
    self.tempIcon = nil
    self.m_materialDataTable = {};
    self.m_material_node_tab = {};
    self.m_sel_btn2 = nil;
    self.daoju_total = 0;
    self.daoju_need = 0;
    self.daoju_num = 0;
    self.material_num = 1;
end

--[[--
    创建ui入口并初始化数据
]]
function equipment_quik_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return equipment_quik_pop;