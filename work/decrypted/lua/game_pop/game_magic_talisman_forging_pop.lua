--- 活动详细

local game_magic_talisman_forging_pop = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,

    m_close_btn = nil,
    m_label_des = nil,
    m_title = nil,
    m_scroll_des = nil,
    m_label_cost1 = nil,
    m_label_cost2 = nil,
    m_btn_ok = nil,
    m_btn_retain = nil,
    m_btn_abandon = nil,
    m_btn_once = nil,
    m_btn_five = nil,
    enterType = nil,
    m_selMagicId = nil,

    seldes = nil,
    m_node_tableview = nil,
    m_tableview = nil,
    m_fivechoose = 0,
    m_gain_icon1 = nil,
    m_gain_icon2 = nil,

    m_last_sp = nil,
    m_last_label = nil,
    callBackFunc = nil,
    m_label_new = nil,
};
--[[--
    销毁
]]
function game_magic_talisman_forging_pop.destroy(self)
    -- body
    cclog("-----------------game_magic_talisman_forging_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;

    self.m_close_btn = nil;
    self.m_label_des = nil;
    self.m_title = nil;
    self.m_scroll_des = nil;
    self.m_label_cost1 = nil;
    self.m_label_cost2 = nil;
    self.m_btn_ok = nil;
    self.m_btn_retain = nil;
    self.m_btn_abandon = nil;
    self.m_btn_once = nil;
    self.m_btn_five = nil;

    self.enterType = nil;
    self.m_selMagicId = nil;

    self.seldes = nil;
    self.m_node_tableview = nil;
    self.m_tableview = nil;
    self.m_fivechoose = 0;
    self.m_gain_icon1 = nil;
    self.m_gain_icon2 = nil;

    self.m_label_new = nil;
    self.m_last_sp = nil;
    self.m_last_label = nil;
    self.callBackFunc = nil;
end
--[[--
    返回
]]
function game_magic_talisman_forging_pop.back(self,type)
    if self.callBackFunc then
        self:callBackFunc()
    end
    game_scene:removePopByName("game_magic_talisman_forging_pop");
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_magic_talisman_forging_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        cclog("------------------  onclick ----------------------")
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 or btnTag ==403 or btnTag ==405 then
            self:back()
        elseif btnTag == 401 then --5
            self.m_label_new:setVisible(false)
            self.m_node_cost:setVisible(false)
            local function sendRequest()
                local function responseMethod(tag,gameData)
                    cclog("   5 times response ==============================================")
                    self.m_fivechoose  = 1
                    local list_forging = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()).list_forging
                    local temptb = {}
                    if self.enterType == "effect" then
                        for i=1,#list_forging do
                            table.insert(temptb , {id = i,effect =tonumber(list_forging[i].effect) , forging_id = tonumber(list_forging[i].forging_id) })
                            local sortFunc = function(a, b) return b.effect < a.effect end
                            table.sort( temptb, sortFunc )
                        end
                        self.m_fivechoose  = temptb[1].id
                    end

                    self.m_node_tableview =  ccbNode:nodeForName("m_node_tableview")
                    self.m_tableview = nil;
                    self.m_tableview = self:createTableView(self.m_node_tableview:getContentSize(),list_forging);
                    self.m_node_tableview:addChild(self.m_tableview);

                    self.m_btn_retain:setVisible(true)
                    self.m_btn_abandon:setVisible(true)
                    self.m_btn_once:setVisible(false)
                    self.m_btn_five:setVisible(false)
                    self.m_btn_ok:setVisible(false)
                end
                local params = {};
                params.talisman_id = self.m_selMagicId
                params.five_times = 1
                if self.enterType == "skill" then
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("talisman_forging"), http_request_method.GET, params,"talisman_forging")
                elseif self.enterType == "effect" then
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("talisman_forging_effect"), http_request_method.GET, params,"talisman_forging_effect")
                end
            end
            cclog("   5 times  ==============================================")
            sendRequest();

        elseif btnTag == 402 then --1
            self.m_label_new:setVisible(true)
            self.m_node_cost:setVisible(false)
            self.m_label_new:setString("")
            local function sendRequest()
                local function responseMethod(tag,gameData)
                    cclog("  1 time response ==============================================")
                    local list_forging = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()).list_forging

                    local forginglistCfg = json.decode(getConfig(game_config_field.talisman_forging_list):getFormatBuffer())
                    local _effect = list_forging[1]["effect"]..""
                    local _id = list_forging[1]["forging_id"]..""

                    local _str = string.gsub( forginglistCfg[_id]["des"], "effect", _effect)
                    -- self.m_label_des:setString(_str.."")
           
                    self.m_btn_retain:setVisible(false)
                    self.m_btn_abandon:setVisible(false)
                    self.m_btn_once:setVisible(false)
                    self.m_btn_five:setVisible(false)
                    self.m_btn_ok:setVisible(true)
                    self.m_label_new:setString(_str.."")

                end
                local params = {};
                params.talisman_id = self.m_selMagicId
                params.five_times = 0
                if self.enterType == "skill" then
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("talisman_forging"), http_request_method.GET, params,"talisman_forging")
                elseif self.enterType == "effect" then
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("talisman_forging_effect"), http_request_method.GET, params,"talisman_forging_effect")
                end
            end
            cclog("   1 time  ==============================================")
            sendRequest();


        elseif btnTag == 404 then --retain

            local function sendRequest()
                local function responseMethod(tag,gameData)
                    self:back()
                end
                local params = {};
                params.talisman_id = self.m_selMagicId
                params.num = self.m_fivechoose or 1
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("talisman_skill_save"), http_request_method.GET, params,"talisman_skill_save")
            end
            sendRequest();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_talisman_forging_pop.ccbi")
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    self.m_close_btn =  ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    self.m_label_des = ccbNode:labelTTFForName("m_label_des")
    -- self.m_label_des:setString("")
    self.m_title = ccbNode:spriteForName("m_title");
    self.m_node_cost = ccbNode:nodeForName("m_node_cost")
    self.m_node_cost:setVisible(true)
            
    self.m_label_new = ccbNode:labelTTFForName("m_label_new")
    self.m_label_new:setString("")
    self.m_label_new:setVisible(false)
    self.m_scroll_des = ccbNode:scrollViewForName("m_scroll_des")
    self.m_label_cost1 = ccbNode:labelTTFForName("m_label_cost1")
    self.m_label_cost2 = ccbNode:labelTTFForName("m_label_cost2")
    self.m_gain_icon1 = ccbNode:nodeForName("m_gain_icon1")
    self.m_gain_icon2 = ccbNode:nodeForName("m_gain_icon2")

    self.m_btn_ok =  ccbNode:controlButtonForName("m_btn_ok")
    self.m_btn_ok:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn_retain =  ccbNode:controlButtonForName("m_btn_retain")
    self.m_btn_retain:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn_abandon =  ccbNode:controlButtonForName("m_btn_abandon")
    self.m_btn_abandon:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn_once =  ccbNode:controlButtonForName("m_btn_once")
    self.m_btn_once:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_btn_five =  ccbNode:controlButtonForName("m_btn_five")
    self.m_btn_five:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end


function game_magic_talisman_forging_pop.setTabledata(self,index,ccbNode,tableData)
    local sp = ccbNode:spriteForName("m_sp");
    local label = ccbNode:labelTTFForName("m_label");

    local forginglistCfg = json.decode(getConfig(game_config_field.talisman_forging_list):getFormatBuffer())
    local _effect = tableData.effect..""
    local _id = tableData.forging_id..""
    local _str = string.gsub( forginglistCfg[_id]["des"], "effect", _effect)

    -- m_sp:setString(tostring(itemData1));
    -- if self.enterType == "effect" then
    --     if index == 1 then 
    --         self.m_fivechoose  = tableData.id
    --     end
    -- else
    --     self.m_fivechoose  = 1
    -- end

    if index == self.m_fivechoose then
        -- self.m_label_des:setString(tostring(_str..""))
        -- sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ball1.png"))
        sp:setVisible(true)
        label:setString(tostring(_str..""))
        label:setColor(ccc3(0,255,0))

        self.m_last_sp = sp
        self.m_last_label = label
    else
        label:setString(tostring(_str..""))
        label:setColor(ccc3(255,255,255))
    end
end



--[[
    内容列表
]]
function game_magic_talisman_forging_pop.createTableView(self,viewSize,tableData)

    cclog("-----------------game_magic_talisman_forging_pop createTableView-----------------");
    -- self.last_m_sel_img2 = nil;
    local itemsCount = #tableData;
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = itemsCount;
    params.itemActionFlag = true;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_talisman_forging_pop_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < itemsCount then
                self:setTabledata(index+1,ccbNode,tableData[index+1]);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= itemsCount then return end;
        if eventType == "ended" and cell then
            local tempId = index+1
            if tempId~= self.m_fivechoose then 
                -- self.m_last_sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ball2.png"))
                self.m_last_sp:setVisible(false)
                self.m_last_label:setColor(ccc3(255,2555,255))

                local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
                local sp = ccbNode:spriteForName("m_sp");
                local label = ccbNode:labelTTFForName("m_label");

                local forginglistCfg = json.decode(getConfig(game_config_field.talisman_forging_list):getFormatBuffer())
                local _effect = tableData[tempId].effect..""
                local _id = tableData[tempId].forging_id..""
                local _str = string.gsub( forginglistCfg[_id]["des"], "effect", _effect)

                -- self.m_label_des:setString(tostring(_str..""))
                -- sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ball1.png"))
                sp:setVisible(true)
                -- label:setString(tostring(_str..""))
                label:setColor(ccc3(0,255,0))
                self.m_last_sp = sp
                self.m_last_label = label
                -- if self.enterType == "effect" then
                --     if index == 1 then 
                --         self.m_fivechoose  = tableData[tempId].id
                --     end
                -- else
                --     self.m_fivechoose  = tempId
                -- end
                self.m_fivechoose  = tempId
            end
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新ui
]]
function game_magic_talisman_forging_pop.refreshUi(self)
    local itemData,selCfg1 = game_data:getMagicDataById(self.m_selMagicId)
    if self.enterType == "skill" then 
        self.m_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("title_talisman_forging_skill.png"))
        self.m_btn_ok:setVisible(false)
        self.m_btn_retain:setVisible(false)
        self.m_btn_abandon:setVisible(false)
        self.m_btn_once:setVisible(true)
        self.m_btn_five:setVisible(true)

        local forginglistCfg = json.decode(getConfig(game_config_field.talisman):getFormatBuffer())
        local icon1,name1,count1 = game_util:getRewardByItemTable(forginglistCfg[itemData.c_id..""]["talisman_forging"][1],false)
        local icon2,name2,count2 = game_util:getRewardByItemTable(forginglistCfg[itemData.c_id..""]["talisman_forging1"][1],false)

        self.m_gain_icon1:addChild(icon1)
        self.m_gain_icon2:addChild(icon2)
        self.m_gain_icon1:setScale(0.4)
        self.m_gain_icon2:setScale(0.4)

        self.m_label_cost1:setString(count1)
        self.m_label_cost2:setString(count2)

    elseif self.enterType == "effect" then 
        self.m_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("title_talisman_forging_effect.png"))
        self.m_btn_ok:setVisible(false)
        self.m_btn_retain:setVisible(false)
        self.m_btn_abandon:setVisible(false)
        self.m_btn_once:setVisible(true)
        self.m_btn_five:setVisible(true)

        local forginglistCfg = json.decode(getConfig(game_config_field.talisman):getFormatBuffer())
        local icon1,name1,count1 = game_util:getRewardByItemTable(forginglistCfg[itemData.c_id..""]["talisman_forging2"][1],false)
        local icon2,name2,count2 = game_util:getRewardByItemTable(forginglistCfg[itemData.c_id..""]["talisman_forging3"][1],false)

        self.m_gain_icon1:addChild(icon1);
        self.m_gain_icon2:addChild(icon2);
        self.m_gain_icon1:setScale(0.4)
        self.m_gain_icon2:setScale(0.4)

        self.m_label_cost1:setString(count1)
        self.m_label_cost2:setString(count2)
    end

    local itemData,itemCfg = game_data:getMagicDataById(self.m_selMagicId)

    if itemData.is_forging then
        local forginglistCfg = json.decode(getConfig(game_config_field.talisman_forging_list):getFormatBuffer())
        local _effect = itemData.forging_attr.effect..""
        local _id = itemData.forging_attr.forging_id..""
        local _str = string.gsub( forginglistCfg[_id]["des"], "effect", _effect)
        self.m_label_des:setString(_str.."")
    else
        self.m_label_des:setString("Không")
    end

    -- self:createContentTable(self.content_node:getContentSize())
end
--[[--
    初始化
]]
function game_magic_talisman_forging_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    self.enterType = t_params.enterType
    self.m_selMagicId = t_params.talisman_id
    self.callBackFunc = t_params.callBackFunc
end
--[[--
    创建ui入口并初始化数据
]]
function game_magic_talisman_forging_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_magic_talisman_forging_pop.callBackFunc(self)
    local callBackFunc = self.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc();
    end
end

return game_magic_talisman_forging_pop;