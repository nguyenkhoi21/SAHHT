---  

local game_limit_time_war_task = {
    m_popUi = nil,
};
--[[--
    销毁ui
]]
function game_limit_time_war_task.destroy(self)
    -- body
   
    self.m_popUi = nil;
end
--[[--
    返回
]]
function game_limit_time_war_task.back(self,backType)
   
    game_scene:removePopByName("game_limit_time_war_task");
end
--[[--
    读取ccbi创建ui
]]
function game_limit_time_war_task.createUi(self)
    local editText = "";
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        --cclog(btnTag,"btntag")
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 2 then
            if self.num_1:getString() == "1/1" then
                game_util:addMoveTips( {text = "Thẻ bài đã ra trận không cần lại ra trận"} )
                return
            end
            local c_id2 = self.m_data["tasks"][tostring(self.m_task_id)]["cards"]["need_cards"][1]
            local itemOnClick = function (typeName,id)
                if typeName == "exchanged" then
                    local cardData, selItemCfg = game_data:getCardDataById(tostring(id))
                    local data = self.m_data["tasks"][tostring(self.m_task_id)]["cards"]
                    local c_id = self:split(id, '-')
                    
                    if tonumber(c_id[1]) ~= c_id2 then
                        game_util:addMoveTips( {text = "Hãy chọn Anh Hùng thích hợp với bên trên"} )
                        return
                    end
                    
                    for i,v in ipairs(self.m_cards) do
                        if v == id then
                            game_util:addMoveTips( {text = "此英雄已上阵"} )
                            return
                        end
                    end

                    for i,v in ipairs(data["pick_cards"]) do
                        if v == id then
                            game_util:addMoveTips( {text = "此英雄已上阵"} )
                            return
                        end
                    end
                    
                    if cardData.super_step >= data["limit_evo"] and cardData.bre >= data["limit_break"] then
                        self.m_cards[#self.m_cards+1] = id
                        self.num_1:setString("1/1")
                    else
                        game_util:addMoveTips( {text = "Độ bồi dưỡng thẻ bài này không đủ"} ) -- Độ bồi dưỡng thẻ bài này không đủ
                    end
                  
                elseif typeName == "unload" then
                    
                end
            end
            game_scene:addPop("game_hero_select_pop",{itemOnClick = itemOnClick,openType = 13,material_cid = c_id2})
        elseif btnTag == 3 then
            if self.num_2:getString() == "1/1" then
                game_util:addMoveTips( {text = "Thẻ bài đã ra trận không cần lại ra trận"} )
                return
            end
            local c_id2 = self.m_data["tasks"][tostring(self.m_task_id)]["cards"]["need_cards"][2]
            local itemOnClick = function (typeName,id)
                if typeName == "exchanged" then
                    local cardData, selItemCfg = game_data:getCardDataById(tostring(id))
                    local data = self.m_data["tasks"][tostring(self.m_task_id)]["cards"]
                    local c_id = self:split(id, '-')
                    
                    if tonumber(c_id[1]) ~= c_id2 then
                        game_util:addMoveTips( {text = "Hãy chọn Anh Hùng thích hợp với bên trên"} )
                        return
                    end

                    for i,v in ipairs(self.m_cards) do
                        if v == id then
                            game_util:addMoveTips( {text = "Thẻ này đã ra trận"} )
                            return
                        end
                    end

                    for i,v in ipairs(data["pick_cards"]) do
                        if v == id then
                            game_util:addMoveTips( {text = "Thẻ này đã ra trận"} )
                            return
                        end
                    end
                    
                    if cardData.super_step >= data["limit_evo"] and cardData.bre >= data["limit_break"] then
                        self.m_cards[#self.m_cards+1] = id
                        self.num_2:setString("1/1")
                    else
                        game_util:addMoveTips( {text = "Độ bồi dưỡng thẻ bài này không đủ"} ) -- Độ bồi dưỡng thẻ bài này không đủ
                    end
                  
                elseif typeName == "unload" then
                    
                end
            end
            game_scene:addPop("game_hero_select_pop",{itemOnClick = itemOnClick,openType = 13,material_cid = c_id2})
        elseif btnTag == 4 then
            if self.num_3:getString() == "1/1" then
                game_util:addMoveTips( {text = "Thẻ bài đã ra trận không cần lại ra trận"} )
                return
            end
            local c_id2 = self.m_data["tasks"][tostring(self.m_task_id)]["cards"]["need_cards"][3]
            local itemOnClick = function (typeName,id)
                if typeName == "exchanged" then
                    local cardData, selItemCfg = game_data:getCardDataById(tostring(id))
                    local data = self.m_data["tasks"][tostring(self.m_task_id)]["cards"]
                    local c_id = self:split(id, '-')
                   
                    if tonumber(c_id[1]) ~= c_id2 then
                        game_util:addMoveTips( {text = "Hãy chọn Anh Hùng thích hợp với bên trên"} )
                        return
                    end

                    for i,v in ipairs(self.m_cards) do
                        if v == id then
                            game_util:addMoveTips( {text = "Thẻ này đã ra trận"} )
                            return
                        end
                    end

                    for i,v in ipairs(data["pick_cards"]) do
                        if v == id then
                            game_util:addMoveTips( {text = "Thẻ này đã ra trận"} )
                            return
                        end
                    end
                    
                    if cardData.super_step >= data["limit_evo"] and cardData.bre >= data["limit_break"] then
                        self.m_cards[#self.m_cards+1] = id
                        self.num_3:setString("1/1")
                    else
                        game_util:addMoveTips( {text = "Độ bồi dưỡng thẻ bài này không đủ"} )
                    end
                  
                elseif typeName == "unload" then
                    
                end
            end
            game_scene:addPop("game_hero_select_pop",{itemOnClick = itemOnClick,openType = 13,material_cid = c_id2})
        elseif btnTag == 5 then
            if self.num_4:getString() == "1/1" then
                game_util:addMoveTips( {text = "Thẻ bài đã ra trận không cần lại ra trận"} )
                return
            end
            local c_id2 = self.m_data["tasks"][tostring(self.m_task_id)]["cards"]["need_cards"][4]
            local itemOnClick = function (typeName,id)
                if typeName == "exchanged" then
                    local cardData, selItemCfg = game_data:getCardDataById(tostring(id))
                    local data = self.m_data["tasks"][tostring(self.m_task_id)]["cards"]
                    local c_id = self:split(id, '-')
                    
                    if tonumber(c_id[1]) ~= c_id2 then
                        game_util:addMoveTips( {text = "Hãy chọn Anh Hùng thích hợp với bên trên"} )
                        return
                    end

                    for i,v in ipairs(self.m_cards) do
                        if v == id then
                            game_util:addMoveTips( {text = "Thẻ này đã ra trận"} )
                            return
                        end
                    end

                    for i,v in ipairs(data["pick_cards"]) do
                        if v == id then
                            game_util:addMoveTips( {text = "Thẻ này đã ra trận"} )
                            return
                        end
                    end
                    
                    if cardData.super_step >= data["limit_evo"] and cardData.bre >= data["limit_break"] then
                        self.m_cards[#self.m_cards+1] = id
                        self.num_4:setString("1/1")
                    else
                        game_util:addMoveTips( {text = "Độ bồi dưỡng thẻ bài này không đủ"} )
                    end
                  
                elseif typeName == "unload" then
                    
                end
            end
            game_scene:addPop("game_hero_select_pop",{itemOnClick = itemOnClick,openType = 13,material_cid = c_id2})
        elseif btnTag == 6 then
            if #self.m_cards < 4 then
                game_util:addMoveTips( {text = "Hãy đưa Anh Hùng ra trận trước"} )
                return
            end
            local card_list = ""
            local need_cards = self.m_data["tasks"][tostring(self.m_task_id)]["cards"]["need_cards"]
            for i=1,4 do
                for j=1,4 do
                    local ad = self:split(self.m_cards[j], '-')
                    if need_cards[i] == tonumber(ad[1]) then
                        local temp = self.m_cards[j]
                        self.m_cards[j] = self.m_cards[i]
                        self.m_cards[i] = temp
                    end
                end
            end
            
            for i,v in ipairs(self.m_cards) do
                    card_list = card_list.."_"..v
            end
            local len = string.len(card_list)
            local cards = string.sub(card_list,2,len)
            local function responseMethod(tag,gameData)
                local data = json.decode(gameData:getFormatBuffer()).data
                if self.m_callBack then
                    self.m_callBack(data)
                    self:back();
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("limit_time_war_start_task"), http_request_method.GET, {task_id = self.m_task_id, card_list = cards},"limit_time_war_start_task")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_limit_time_war_task_pop.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local button_1 = ccbNode:controlButtonForName("button_1")
    local button_2 = ccbNode:controlButtonForName("button_2")
    local button_3 = ccbNode:controlButtonForName("button_3")
    local button_4 = ccbNode:controlButtonForName("button_4")
    local button_war = ccbNode:controlButtonForName("button_war")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10);
    button_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10);
    button_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10);
    button_3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10);
    button_4:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10);
    button_war:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10);

    self.card_1 = ccbNode:nodeForName("card_1")
    self.card_2 = ccbNode:nodeForName("card_2")
    self.card_3 = ccbNode:nodeForName("card_3")
    self.card_4 = ccbNode:nodeForName("card_4")
    self.card_name_1 = ccbNode:labelTTFForName("card_name_1")
    self.card_name_2 = ccbNode:labelTTFForName("card_name_2")
    self.card_name_3 = ccbNode:labelTTFForName("card_name_3")
    self.card_name_4 = ccbNode:labelTTFForName("card_name_4")

    self.num_1 = ccbNode:labelTTFForName("num_1")
    self.num_2 = ccbNode:labelTTFForName("num_2")
    self.num_3 = ccbNode:labelTTFForName("num_3")
    self.num_4 = ccbNode:labelTTFForName("num_4")

    self.task_sss = ccbNode:spriteForName("task_sss")
    self.item_node = ccbNode:nodeForName("item_node")
    self.tip_label = ccbNode:labelTTFForName("tip_label")
   
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end

    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

function game_limit_time_war_task.createCard(self,cardId,node,label)
    if cardId == "" then
        return
    end
   
    local character_detail_cfg = getConfig(game_config_field.character_detail)
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(cardId))
    label:setString(heroCfg:getNodeWithKey("name"):toStr())
    animNode = game_util:createCardImgByCfg(heroCfg);
    animNode:setScale(0.7)
    node:addChild(animNode);

end

function game_limit_time_war_task.split(self,s, p)
    if not s then
        return ""
    end
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end


--[[--
    刷新ui
]]
function game_limit_time_war_task.refreshUi(self)
    local need_cards = self.m_data["tasks"][tostring(self.m_task_id)]["cards"]["need_cards"]
    local cards = self.m_data["tasks"][tostring(self.m_task_id)]["cards"]
    self:createCard(need_cards[1],self.card_1,self.card_name_1)
    self:createCard(need_cards[2],self.card_2,self.card_name_2)
    self:createCard(need_cards[3],self.card_3,self.card_name_3)
    self:createCard(need_cards[4],self.card_4,self.card_name_4)

    local level = self.m_data["tasks"][tostring(self.m_task_id)]["level"]
    local key = "reward_s"
    local fileName = "limit_time_war_s1.png"
    if level == "s" then
        key = "reward_s"
        fileName = "limit_time_war_s1.png"
    elseif level == "ss" then
        key = "reward_ss"
        fileName = "limit_time_war_s2.png"
    else
        key = "reward_sss"
        fileName = "limit_time_war_s3.png"
    end
    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(fileName))
    self.task_sss:setDisplayFrame(tempSpriteFrame)

    local icon,name,count = game_util:getRewardByItemTable(self.m_replace_cfg[self.m_task_id][key][1],false)
    local label = CCLabelTTF:create("X"..count,TYPE_FACE_TABLE.Arial_BoldMT,16)
    icon:setScale(0.8)
    label:setPosition(40,10)
    icon:addChild(label,99,99)
    self.item_node:addChild(icon)

    self.tip_label:setString("Thẻ bài NV lần này yêu cầu: Chuyển Thế "..cards["limit_break"].." cấp trở lên, Siêu Tiến Hóa "..cards["limit_evo"].." cấp trở lên")

end
--[[--
    初始化
]]
function game_limit_time_war_task.init(self,t_params)
    local data = t_params.gameData or {};
    self.m_data = data
    self.m_callBack = t_params.callback
    self.m_task_id = t_params.task_id
    self.m_cards = {}

    local cfg_rank =  getConfig(game_config_field.chuzheng_task)
    local task_data = json.decode(cfg_rank:getFormatBuffer())

    local cfg_version =  getConfig(game_config_field.chuzheng_version)
    local version_data = json.decode(cfg_version:getFormatBuffer())

    self.m_task = version_data[tostring(self.m_data["version"])]["task"]

    self.m_replace_cfg = {}
    for i,v in ipairs(self.m_task) do
        self.m_replace_cfg[v] = task_data[tostring(v)]
    end
    
    cclog2(self.m_data,"data")
end

--[[--
    创建ui入口并初始化数据
]]
function game_limit_time_war_task.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_limit_time_war_task;