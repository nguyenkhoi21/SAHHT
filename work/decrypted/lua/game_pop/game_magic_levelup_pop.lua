-- 法宝修炼
local game_magic_levelup_pop = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,
    cost_coin = nil,
    cost_lushi = nil,
    m_sel_node = nil,
    m_level_lb = nil,
    m_detail1 = nil,
    m_detail2 = nil,
    m_pro_node = nil,
    m_btn_levelup = nil,
    m_btn_break = nil,
    m_progress = nil,
    m_fabao = nil,
    m_lushi = nil,
    m_tParams = nil,
    m_enterType = nil,
    m_openType = nil,
    m_openMsg = nil,
    callBackFunc = nil,
    m_selMagic = nil,
    m_talisman_level = nil,
    m_ccbNode = nil,
};
--[[--
    销毁
]]
function game_magic_levelup_pop.destroy(self)
    -- body
    cclog("-----------------game_magic_levelup_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;
    self.cost_coin = nil;
    self.cost_lushi = nil;
    self.m_sel_node = nil;
    self.m_level_lb = nil;
    self.m_detail1 = nil;
    self.m_detail2 = nil;
    self.m_pro_node = nil;
    self.m_btn_levelup = nil;
    self.m_btn_break = nil;
    self.m_progress = nil;
    self.m_fabao = nil;
    self.m_lushi = nil;
    self.m_tParams = nil;
    self.m_enterType = nil;
    self.m_openType = nil;
    self.m_openMsg = nil;
    self.callBackFunc = nil;
    self.m_selMagic = nil;
    self.m_talisman_level = nil;
    self.m_ccbNode = nil;
end

local lab_text = {
    attribute_node0 = {
        {old = "m_hp1",new = "m_hp2",name = "HP",base = "hp",},
        {old = "m_def1",new = "m_def2",name = "Phòng Ngự",base = "def",},
        {old = "m_dodge1",new = "m_dodge2",name = "Né",base = "dr",},
        {old = "m_speed1",new = "m_speed2",name = "Tốc Độ",base = "speed",},
    },
    attribute_node1 = {
        {old = "m_att1",new = "m_att2",name = "Vật Công",base = "patk",},
        {old = "m_hr1",new = "m_hr2",name = "Ma Công",base = "matk",},
        {old = "m_crit1",new = "m_crit2",name = "Bạo Kích",base = "crit",},--暴击
        {old = "m_hit1",new = "m_hit2",name = "Chính Xác",base = "hr",},--命中
    },
}
--[[--
    返回
]]
function game_magic_levelup_pop.back(self,type)
    if self.callBackFunc then
        self:callBackFunc()
    end
    game_scene:removePopByName("game_magic_levelup_pop");
    game_scene:enterGameUi("game_magic_evolution",{gameData = nil,openType = "game_function_pop"});
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_magic_levelup_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("----------------btn ====== " .. btnTag)
        if btnTag == 1 then
            self:back()
        elseif btnTag == 101 then
            local text = ""
            if self.cost_coin then
                text = text .. self.cost_coin .. "Xu" 
            end
            if self.cost_lushi > 0 then
                text = text .. (self.cost_coin and "và" or "")  .. self.cost_lushi .. "Tinh Hoa Đá Lò"
            end
            local t_params = {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        game_util:closeAlertView();
                        local function responseMethod( tag,gameData )
                            if gameData and tolua.type(gameData) == "util_json" then
                                local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                                self:refreshUi()
                            end
                        end
                        params = {}
                        params.is_buy = 0
                        if self.cost_coin then
                            params.is_buy = 1
                        end
                        params.talisman_id = self.m_selMagic
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("talisman_level_up_talisman"), http_request_method.GET, params,"talisman_level_up_talisman")
                    end,   --可缺省
                    cancelBtnCallBack = function(target,event)
                        game_util:closeAlertView();
                    end,
                    okBtnText = "OK",       --可缺省
                    cancelBtnText = "Hủy",
                    onlyOneBtn = false,
                    text ="    Tốn" .. text .. "để nâng cấp?",      --可缺省
                    touchPriority = GLOBAL_TOUCH_PRIORITY-12,
                }
                game_util:openAlertView(t_params);
        elseif btnTag == 102 then
            -- if self.m_sel_cost_id == nil or not self.m_sel_cost_id or self.m_sel_cost_id == "" then
            --     game_util:addMoveTips({text = "材料不足，无法完成升星"})
            --     return
            -- end
            if self.is_CanUp == false then
                game_util:addMoveTips({text = "Không đủ tài nguyên, không thể tăng sao"})
                return
            end
            local t_params = {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        game_util:closeAlertView();
                        local function responseMethod( tag,gameData )
                            if gameData and tolua.type(gameData) == "util_json" then
                                local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                                self.m_sel_cost_id = nil
                                self:refreshUi()
                            end
                        end

                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("talisman_talisman_break"), http_request_method.GET, {talisman_id = self.m_selMagic,tali_material = self.m_sel_cost_id},"talisman_talisman_break")
                    end,   --可缺省
                    cancelBtnCallBack = function(target,event)
                        game_util:closeAlertView();
                    end,
                    okBtnText = "OK",       --可缺省
                    cancelBtnText = "Hủy",
                    onlyOneBtn = false,
                    text ="    Xác nhận muốn tiến cấp?",      --可缺省
                    touchPriority = GLOBAL_TOUCH_PRIORITY-12,
                }
                game_util:openAlertView(t_params);
        elseif btnTag > 200 and btnTag < 300 then
            local index = btnTag - 200
            -- cclog2(self.m_meterial_break,"   self.m_meterial_break    ")
            local tempData = self.m_meterial_break[index][1]
            if tempData[1] == 49 then
                if self.m_sel_cost_id == nil then game_util:addMoveTips({text = "Không có Pháp Bảo khả dụng!"}) return end
                local itemData,itemCfg = game_data:getMagicDataById(self.m_sel_cost_id)

                game_scene:addPop("game_magic_info",{tGameData = itemData,magicType = itemCfg.talisman_type,isOpen = false})
            else
                game_util:lookItemDetal(tempData);
            end

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_magic_level_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");

    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_sel_node = ccbNode:nodeForName("m_sel_node")
    self.m_level_lb = ccbNode:labelTTFForName("level_lb")
    self.m_detail1 = ccbNode:labelTTFForName("m_detail1")
    self.m_detail2 = ccbNode:labelTTFForName("m_detail2")
    self.m_pro_node = ccbNode:nodeForName("m_pro_node")
    self.m_btn_levelup = ccbNode:controlButtonForName("m_btn_levelup")
    self.m_btn_break = ccbNode:controlButtonForName("m_btn_break")
    self.m_material_btn1 = ccbNode:controlButtonForName("material_btn1")
    self.m_material_btn2 = ccbNode:controlButtonForName("material_btn2")
    self.m_material_btn3 = ccbNode:controlButtonForName("material_btn3")
    self.m_material_btn1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_material_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_material_btn3:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn_levelup:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn_break:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    self.m_lv_begin = ccbNode:labelTTFForName("m_lv_begin")
    self.m_lv_end = ccbNode:labelTTFForName("m_lv_end")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode
    return ccbNode;
end

function game_magic_levelup_pop:createProgress()
   local bar = ExtProgressTime:createWithFrameName("magic_progress1.png","magic_progress2.png");
    bar:setScaleX(1);
    bar:setMaxValue(10)
    bar:setAnchorPoint(ccp(0.5,0.5))
    local viewSize = self.m_pro_node:getContentSize()
    bar:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
    self.m_pro_node:addChild(bar,10)
    local talisman_level = self.m_talisman_level
    for i=1,10 do
        local v = talisman_level[tostring(i)]
        local k = i
        local ccb = luaCCBNode:create();
        ccb:openCCBFile("ccb/ui_magic_star.ccbi");
        local star = ccb:spriteForName("star")
        local zuduan = ccb:spriteForName("zuduan")
        if v.is_star and ( v.is_star == 1 or v.is_star == "1" ) then
            star:setVisible(true)
        else
            star:setVisible(false)
        end
        if k == 10 or k == "10" then
            zuduan:setVisible(false)
        end
        self.m_pro_node:addChild(ccb,11)
        ccb:setPosition(ccp(viewSize.width*(k/10),viewSize.height*0.5))
    end

    -- for k,v in pairs(talisman_level) do

    -- end
    self.m_progress = bar
end

--[[--
    刷新ui
]]
function game_magic_levelup_pop.refreshUi(self)
    if not self.m_progress then
        self:createProgress()
    end
    self.m_sel_node:removeAllChildrenWithCleanup(true)
    if self.m_selMagic then
        local itemData = game_data:getMagicDataById(self.m_selMagic)
        if itemData then
            -- local lv = 
            self.m_progress:setCurValue(itemData.lv,false)
            self.m_sel_node:addChild(game_util:createMagicItemByCCB(itemData))
            -- self.m_sel_node:setScale(0.85)
            self:refreshDetail(itemData)
            cclog2(itemData)
            -- self.m_lv_begin:setString()
            -- self.m_lv_end:setString()
        else
            game_util:addMoveTips({text = "Quay về chọn Pháp Bảo tiến cấp!"});
        end
    else
        game_util:addMoveTips({text = "Quay về chọn Pháp Bảo tiến cấp!"});
    end
    -- self.m_lv_begin:setString()
    -- self.m_lv_end:setString()
end
--[[
    local lab_text = {
        attribute_node0 = {
            {old = "m_hp1",new = "m_hp2",name = "生命",base = "hp",},
            {old = "m_def1",new = "m_def1",name = "防御",base = "def",},
            {old = "m_dodge1",new = "m_dodge1",name = "闪避",base = "dr",},
            {old = "m_speed1",new = "m_speed1",name = "速度",base = "speed",},
        },
        attribute_node1 = {
            {old = "m_att1",new = "m_att1",name = "物攻",base = "patk",},
            {old = "m_hr1",new = "m_hr1",name = "魔攻",base = "matk",},
            {old = "m_crit1",new = "m_crit1",name = "暴击",base = "crit",},
            {old = "m_hit1",new = "m_hit1",name = "命中",base = "hr",},
        },
    }
]]

function game_magic_levelup_pop:refreshDetail(itemData)
    local talisman_break = getConfig(game_config_field.talisman_break);
    local talisman = getConfig(game_config_field.talisman);
    local magicCfg1 = json.decode(talisman:getNodeWithKey(itemData.c_id):getFormatBuffer())
    local selCfg2 = nil
    if talisman_break:getNodeWithKey(itemData.c_id) then
        selCfg2 = json.decode(talisman_break:getNodeWithKey(itemData.c_id):getFormatBuffer())
        local value1 = math.floor(itemData.lv/10)
        local value2 = itemData.lv%10

        if itemData.lv > value1*10 or (itemData.lv == value1*10 and magicCfg1.star ~= 5 and magicCfg1.star ~= 4) then
            self.m_progress:setCurValue(value2,false)
            self.m_lv_begin:setString("Lv." .. tostring(10*value1))
            self.m_lv_end:setString("Lv." .. tostring(10*value1 + 10))
        end
    else
        self:back()
        game_util:addMoveTips({text = "Pháp Bảo đã luyện đến cao nhất!"})
        return
    end
    local magicCfg2 = nil
    magicCfg1.lv = itemData.lv
    if selCfg2.talisman_level == itemData.lv then
        self.m_level_lb:setString("HQ tiến cấp:")
        -- cclog("-----------------")
        self.m_ccbNode:nodeForName("m_jinjie_node"):setVisible(true)
        self.m_ccbNode:nodeForName("m_shengji_node"):setVisible(false)
        magicCfg2 = json.decode(talisman:getNodeWithKey(magicCfg1.talisman_break):getFormatBuffer())
        magicCfg2.lv = itemData.lv
        self:refresLevelup2(itemData,magicCfg1)
        self.m_material_btn1:setVisible(true)
        self.m_material_btn2:setVisible(true)
        self.m_material_btn3:setVisible(true)
    else--m_shengji_node
        -- cclog("==================")
        self.m_level_lb:setString("HQ nâng cấp:")
        self.m_ccbNode:nodeForName("m_jinjie_node"):setVisible(false)
        self.m_ccbNode:nodeForName("m_shengji_node"):setVisible(true)
        magicCfg2 = json.decode(talisman:getNodeWithKey(itemData.c_id):getFormatBuffer())
        magicCfg2.lv = itemData.lv + 1
        self:refresLevelup1(itemData,magicCfg1)
        self.m_material_btn1:setVisible(false)
        self.m_material_btn2:setVisible(false)
        self.m_material_btn3:setVisible(false)
    end
    self.m_ccbNode:nodeForName("attribute_node0"):setVisible(false)
    self.m_ccbNode:nodeForName("attribute_node1"):setVisible(false)
    self.m_ccbNode:nodeForName("attribute_node" .. magicCfg1.talisman_type):setVisible(true)
    local tempTab = lab_text["attribute_node" .. magicCfg1.talisman_type]
    for k,v in pairs(tempTab) do
        local lb1 = self.m_ccbNode:labelTTFForName(v.old)
        local lb2 = self.m_ccbNode:labelTTFForName(v.new)
        local value1 = magicCfg1["base_" .. v.base] + magicCfg1["growth_" .. v.base] * magicCfg1.lv
        local value2 = magicCfg2["base_" .. v.base] + magicCfg2["growth_" .. v.base] * magicCfg2.lv
        if v.base == "dr" or v.base == "crit" or v.base == "hr" then
            value1 = tostring(value1) .. "%"
            value2 = tostring(value2) .. "%"
        else
            value1 = tostring(value1)
            if string.len(value1) > 3 then
                value1 = tonumber(value1)/1000 .. "k"
            end
            value2 = tostring(value2)
            if string.len(value2) > 3 then
                value2 = tonumber(value2)/1000 .. "k"
            end
        end
        lb1:setString(value1)
        lb2:setString(value2)
    end
    local str1 = string.gsub( magicCfg1.des, "effect", magicCfg1["effect"], 1)
    local str2 = string.gsub( magicCfg2.des, "effect", magicCfg2["effect"], 1)
    self.m_detail1:setString(str1)
    self.m_detail2:setString(str2)
end

function game_magic_levelup_pop:refresLevelup1(itemData,itemCfg)
    self.m_fabao = game_data:getItemCountByCid(264) or 0 --法宝精华
    self.m_lushi = game_data:getItemCountByCid(265) or 0 --炉石精华
    local value,unit = game_util:formatValueToString(self.m_lushi);
    self.m_ccbNode:labelTTFForName("all_count"):setString("×" .. value .. unit)
    local cost = self.m_talisman_level[tostring(itemData.lv+1)].exp[1][3]
    self.m_ccbNode:labelTTFForName("cost_count"):setString("Tinh Hoa Đá Lò×" .. cost)
    if cost > self.m_lushi then
        self.cost_coin = (cost - self.m_lushi)*(tonumber(self.m_talisman_level[tostring(itemData.lv+1)].exp_price))
        self.cost_lushi = self.m_lushi
    else
        self.cost_coin = nil
        self.cost_lushi = cost
    end
end

function game_magic_levelup_pop:refresLevelup2(itemData,itemCfg)
    self.m_fabao = game_data:getItemCountByCid(264) or 0 --法宝精华
    self.m_lushi = game_data:getItemCountByCid(265) or 0 --炉石精华
    local talisman_break = getConfig(game_config_field.talisman_break)
    local break_cfg = json.decode(talisman_break:getNodeWithKey(itemData.c_id):getFormatBuffer());
    self.m_meterial_break = {break_cfg.talisman_material_1,break_cfg.talisman_material_2,break_cfg.talisman_material_3}
    local icon1,name1,count1 = game_util:getRewardByItemTable(break_cfg.talisman_material_1[1]);
    local id1 = break_cfg.talisman_material_1[1][2]
    local id,count = game_data:getMagicIDByType(itemData,id1)--炉石精华
    self.is_CanUp = true
    if icon1 then
        self.m_ccbNode:nodeForName("m_cost_sp1"):addChild(icon1)
        self.m_ccbNode:labelTTFForName("m_mate_cost_label_1"):setString(count1)
        if id ~= nil then
            self.m_sel_cost_id = id
            self.m_ccbNode:labelTTFForName("m_mate_total_label_1"):setString(count)
        else
            self.is_CanUp = false
            self.m_sel_cost_id = nil
            self.m_ccbNode:labelTTFForName("m_mate_total_label_1"):setString("0")
        end
    end
    local icon2,name2,count2 = game_util:getRewardByItemTable(break_cfg.talisman_material_2[1]);
    local _,myCount2 = game_data:getMetalByTable(break_cfg.talisman_material_2[1])
    if icon2 then
        if count2 > myCount2 then
            self.is_CanUp = false
        end
        local value,unit = game_util:formatValueToString(myCount2);
        self.m_ccbNode:nodeForName("m_cost_sp2"):addChild(icon2)
        self.m_ccbNode:labelTTFForName("m_mate_cost_label_2"):setString(count2)
        self.m_ccbNode:labelTTFForName("m_mate_total_label_2"):setString(value .. unit)
    end
    local icon3,name3,count3 = game_util:getRewardByItemTable(break_cfg.talisman_material_3[1]);
    local _,myCount3 = game_data:getMetalByTable(break_cfg.talisman_material_3[1])
    if icon3 then
        if count3 > myCount3 then
            self.is_CanUp = false
        end
        local value,unit = game_util:formatValueToString(myCount3);
        self.m_ccbNode:labelTTFForName("m_mate_total_label_3"):setString(value .. unit)
        self.m_ccbNode:labelTTFForName("m_mate_cost_label_3"):setString(count3)
        self.m_ccbNode:nodeForName("m_cost_sp3"):addChild(icon3)
    end

end
--[[--
    初始化
]]
function game_magic_levelup_pop.init(self,t_params)
    self.m_fabao = game_data:getItemCountByCid(264) or 0 --法宝精华
    self.m_lushi = game_data:getItemCountByCid(265) or 0 --炉石精华
    self.m_tParams = t_params or {};
    self.m_enterType = t_params.enterType or "110"
    self.m_openType = t_params.openType or "";
    self.m_openMsg = t_params.openMsg or nil
    self.callBackFunc = t_params.callBackFunc or nil
    self.m_cfgKey = t_params.cfgKey or nil;
    self.m_selMagic = t_params.magic_id
    self.m_talisman_level = json.decode(getConfig(game_config_field.talisman_level):getFormatBuffer());
end
--[[--
    创建ui入口并初始化数据
]]
function game_magic_levelup_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_magic_levelup_pop.callBackFunc(self)
    local callBackFunc = self.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc();
    end
end

return game_magic_levelup_pop;